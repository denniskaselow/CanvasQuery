part of canvas_query;

class CanvasWrapper implements CanvasElement {
  CanvasElement _canvas;
  CanvasRenderingContext2D _context;
  CanvasElement get canvas => _canvas;
  CanvasRenderingContext2D get context2d => _context;
  CanvasWrapper(this._canvas) {
    _context = _canvas.context2d;
  }
  CanvasWrapper.forWindow() {
    _canvas = new CanvasElement(width: window.innerWidth, height: window.innerHeight);
    _context = _canvas.context2d;
    window.on.resize.add((e) {
      _canvas.width = window.innerWidth;
      _canvas.height = window.innerHeight;
    });
  }
  CanvasWrapper.query(String selector) : this(query(selector));
  CanvasWrapper.forSize(int width, int height) : this(new CanvasElement(width: width, height: height));
  CanvasWrapper.forImage(ImageElement img) : this(CanvasTools.createCanvas(img));

  dynamic noSuchMethod(InvocationMirror im) => im.invokeOn(_canvas);

  void appendTo(Element element) => element.append(_canvas);

  void blendOn(CanvasElement what, BlendFunction mode, [num mix = 1]) => CanvasTools.blend(what, this, mode, mix);
  void blend(CanvasElement what, BlendFunction mode, [num mix = 1]) => CanvasTools.blend(this, what, mode, mix);
  void blendSpecial(CanvasElement what, SpecialBlendFunction mode, [num mix = 1]) => CanvasTools.blendSpecial(this, what, mode, mix);
  void blendColor(String color, BlendFunction mode, [num mix = 1]) => blend(_createCanvas(color), mode, mix);
  void blendSpecialColor(String color, SpecialBlendFunction mode, [num mix = 1]) => blendSpecial(_createCanvas(color), mode, mix);

  CanvasElement _createCanvas(String color) => new CanvasWrapper.forSize(_canvas.width, _canvas.height)
                                                                .._context.fillStyle = color
                                                                .._context.fillRect(0, 0, width, height);

  void crop(int x, int y, int width, int height) {
    _context.drawImage(_canvas, x, y, width, height, 0, 0, width, height);
    _canvas.width = width;
    _canvas.height = height;
  }

  void resize(int width, int height) {
    var resized = new CanvasWrapper.forSize(width, height)..drawImage(_canvas, 0, 0, _canvas.width, _canvas.height, 0, 0, width, height);
    _canvas = resized._canvas;
    _context = resized._context;
  }

  void matchPalette(List<String> palette) {
    var imgData = _context.getImageData(0, 0, _canvas.width, _canvas.height);

    var rgbPalette = new List<Color>.fixedLength(palette.length);
    for(var i = 0; i < palette.length; i++) {
      rgbPalette.add(new Color.fromHex(palette[i]));
    }

    for(var i = 0; i < imgData.data.length; i += 4) {
      var difList = new List<int>.fixedLength(rgbPalette.length);
      for(var j = 0; j < rgbPalette.length; j++) {
        var rgbVal = rgbPalette[j];
        var rDif = (imgData.data[i] - rgbVal.r).abs(),
            gDif = (imgData.data[i + 1] - rgbVal.g).abs(),
            bDif = (imgData.data[i + 2] - rgbVal.b).abs();
        difList.add(rDif + gDif + bDif);
      }

      var closestMatch = 0;
      for(var j = 0; j < palette.length; j++) {
        if(difList[j] < difList[closestMatch]) {
          closestMatch = j;
        }
      }

      var paletteRgb = hexToRgb(palette[closestMatch]);
      imgData.data[i] = paletteRgb[0];
      imgData.data[i + 1] = paletteRgb[1];
      imgData.data[i + 2] = paletteRgb[2];
    }

    _context.putImageData(imgData, 0, 0);
  }

  List<String> getPalette() {
    var palette = new List<String>();
    var sourceData = _context.getImageData(0, 0, _canvas.width, _canvas.height);
    var sourcePixels = sourceData.data;

    for(var i = 0; i < sourcePixels.length; i += 4) {
      if(0 != sourcePixels[i + 3]) {
        var hex = rgbToHex(sourcePixels[i + 0], sourcePixels[i + 1], sourcePixels[i + 2]);
        if(palette.indexOf(hex) == -1) palette.add(hex);
      }
    }

    return palette;
  }

  void pixelize([int size = 4]) {
    if (_canvas.width < size) size = _canvas.width;
    var webkitImageSmoothingEnabled = _context.webkitImageSmoothingEnabled;
    _context.webkitImageSmoothingEnabled = false;

    var scale = (_canvas.width / size) / _canvas.width;
    var temp = new CanvasWrapper.forSize(_canvas.width, _canvas.height);

    temp._context.drawImage(_canvas, 0, 0, _canvas.width, _canvas.height, 0, 0, (_canvas.width * scale).toInt(), (_canvas.height * scale).toInt());
    clear();
    _context.drawImage(temp.canvas, 0, 0, (_canvas.width * scale).toInt(), (_canvas.height * scale).toInt(), 0, 0, _canvas.width, _canvas.height);

    _context.webkitImageSmoothingEnabled = webkitImageSmoothingEnabled;
  }


  List<bool> colorToMask(String hexColor) {
    Color color = new Color.fromHex(hexColor);
    var sourceData = _context.getImageData(0, 0, _canvas.width, _canvas.height);
    var sourcePixels = sourceData.data;

    var mask = new List<bool>.fixedLength(sourcePixels.length ~/ 4);

    for(var i = 0; i < sourcePixels.length; i += 4) {
      if(sourcePixels[i + 0] == color.r && sourcePixels[i + 1] == color.g && sourcePixels[i + 2] == color.b) mask.add(false);
      else mask.add(true);
    }

    return mask;
  }

  List<int> grayscaleToMask(String hexColor) {
    Color color = new Color.fromHex(hexColor);
    var sourceData = _context.getImageData(0, 0, _canvas.width, _canvas.height);
    var sourcePixels = sourceData.data;

    var mask = new List<int>.fixedLength(sourcePixels.length ~/ 4);

    for(var i = 0; i < sourcePixels.length; i += 4) {
      mask.add((sourcePixels[i + 0] + sourcePixels[i + 1] + sourcePixels[i + 2]) ~/ 3);
    }

    return mask;
  }

  void applyMask(List mask) {
    var sourceData = this.context.getImageData(0, 0, this.canvas.width, this.canvas.height);
    var sourcePixels = sourceData.data;

    var mode = mask is List<bool> ? "bool" : "byte";

    for(var i = 0, len = sourcePixels.length; i < len; i += 4) {
      var value = mask[i ~/ 4];

      if(mode == "bool") sourcePixels[i + 3] = value ? 255 : 0;
      else sourcePixels[i + 3] = value;
    }

    _context.putImageData(sourceData, 0, 0);
  }

  void fillMask(List mask, String hexColor, [String hexColorGradient]) {

    var sourceData = _context.getImageData(0, 0, _canvas.width, _canvas.height);
    var sourcePixels = sourceData.data;

    var maskType = mask is List<bool> ? "bool" : "byte";
    var colorMode = ?hexColorGradient ? "gradient" : "normal";

    var color = new Color.fromHex(hexColor);
    var colorB;
    if (?hexColorGradient) {
      colorB = new Color.fromHex(hexColorGradient);
    }

    for(var i = 0, len = sourcePixels.length; i < len; i += 4) {
      var value = mask[i ~/ 4];

      if (maskType == "byte") value /= 255;
      else value = value ? 1 : 0;

      if(colorMode == "normal") {
        if(0 != value) {
          sourcePixels[i + 0] = color.r;
          sourcePixels[i + 1] = color.g;
          sourcePixels[i + 2] = color.b;
          sourcePixels[i + 3] = (value * 255).toInt();
        }
      } else {
        sourcePixels[i + 0] = (color.r + (colorB.r - color.r) * value).toInt();
        sourcePixels[i + 1] = (color.g + (colorB.g - color.g) * value).toInt();
        sourcePixels[i + 2] = (color.b + (colorB.b - color.b) * value).toInt();
        sourcePixels[i + 3] = 255;
      }
    }

    _context.putImageData(sourceData, 0, 0);
  }

  void clear([String color]) {
    if(null != color) {
      _context.fillStyle = color;
      _context.fillRect(0, 0, _canvas.width, _canvas.height);
    } else {
      _context.clearRect(0, 0, _canvas.width, _canvas.height);
    }
  }


  CanvasElement copy() {
    var result = new CanvasElement(width: _canvas.width, height: _canvas.height);
    result.context2d.drawImage(_canvas, 0, 0);
    return result;
  }

  void set fillStyle(String fillStyle) {
    _context.fillStyle = fillStyle;
  }

  void set strokeStyle(String strokeStyle) {
    _context.strokeStyle = strokeStyle;
  }

  void setHslAsList(List<num> hsl) => setHsl(hsl[0], hsl[1], hsl[2]);
  void setHsl(num hue, num saturation, num lightness) {
    double hIn = null == hue ? null : hue.toDouble();
    double sIn = null == saturation ? null : saturation.toDouble();
    double lIn = null == lightness ? null : lightness.toDouble();

    var data = _context.getImageData(0, 0, _canvas.width, _canvas.height);
    var pixels = data.data;
    double h, s, l;
    List<double> hsl;
    List<int> newPixel;

    for(var i = 0, len = pixels.length; i < len; i += 4) {
      hsl = rgbToHsl(pixels[i + 0], pixels[i + 1], pixels[i + 2]);

      h = hIn == null ? hsl[0] : limitValue(hIn, 0, 1);
      s = sIn == null ? hsl[1] : limitValue(sIn, 0, 1);
      l = lIn == null ? hsl[2] : limitValue(lIn, 0, 1);

      newPixel = hslToRgb(h, s, l);

      pixels[i + 0] = newPixel[0];
      pixels[i + 1] = newPixel[1];
      pixels[i + 2] = newPixel[2];
    }

    _context.putImageData(data, 0, 0);
  }

  void shiftHslAsList(List<num> hsl) => shiftHsl(hsl[0], hsl[1], hsl[2]);
  void shiftHsl(num hue, num saturation, num lightness) {
    double hIn = null == hue ? null : hue.toDouble();
    double sIn = null == saturation ? null : saturation.toDouble();
    double lIn = null == lightness ? null : lightness.toDouble();

    var data = _context.getImageData(0, 0, _canvas.width, _canvas.height);
    var pixels = data.data;
    double h, s, l;
    List<double> hsl;
    List<int> newPixel;

    for(var i = 0, len = pixels.length; i < len; i += 4) {
      hsl = rgbToHsl(pixels[i + 0], pixels[i + 1], pixels[i + 2]);

      h = hIn == null ? hsl[0] : wrapValue(hsl[0] + hIn, 0, 1);
      s = sIn == null ? hsl[1] : limitValue(hsl[1] + sIn, 0, 1);
      l = lIn == null ? hsl[2] : limitValue(hsl[2] + lIn, 0, 1);

      newPixel = hslToRgb(h, s, l);

      pixels[i + 0] = newPixel[0];
      pixels[i + 1] = newPixel[1];
      pixels[i + 2] = newPixel[2];
    }
    _context.putImageData(data, 0, 0);
  }

  /* www.html5rocks.com/en/tutorials/canvas/imagefilters/ */

  void convolve(List<num> matrix, {num mix: 1, num divide: 1}) {

    var sourceData = _context.getImageData(0, 0, _canvas.width, _canvas.height);
    var matrixSize = (sqrt(matrix.length) + 0.5).toInt();
    var halfMatrixSize = matrixSize ~/ 2;
    var src = sourceData.data;
    var sw = sourceData.width;
    var sh = sourceData.height;
    var w = sw;
    var h = sh;
    var output = CanvasTools.createImageData(_canvas.width, _canvas.height);
    var dst = output.data;
    var weights = divide == 1 ? matrix : _calculateWeights(matrix, matrixSize, divide);

    for(var y = 1; y < h - 1; y++) {
      for(var x = 1; x < w - 1; x++) {

        var dstOff = (y * w + x) * 4;
        double r = 0.0, g = 0.0, b = 0.0, a = 0.0;
        for(var cy = 0; cy < matrixSize; cy++) {
          for(var cx = 0; cx < matrixSize; cx++) {
            var scy = y + cy - halfMatrixSize;
            var scx = x + cx - halfMatrixSize;
            if(scy >= 0 && scy < sh && scx >= 0 && scx < sw) {
              var srcOff = (scy * sw + scx) * 4;
              var wt = weights[cy * matrixSize + cx];
              r += src[srcOff + 0] * wt;
              g += src[srcOff + 1] * wt;
              b += src[srcOff + 2] * wt;
              a += src[srcOff + 3] * wt;
            }
          }
        }
        dst[dstOff + 0] = mixIt(src[dstOff + 0], r, mix).toInt();
        dst[dstOff + 1] = mixIt(src[dstOff + 1], g, mix).toInt();
        dst[dstOff + 2] = mixIt(src[dstOff + 2], b, mix).toInt();
        dst[dstOff + 3] = src[dstOff + 3];
      }
    }

    _context.putImageData(output, 0, 0);
  }

  List<double> _calculateWeights(List<num> matrix, int matrixSize, num divide) {
    var weights = new List<double>.fixedLength(matrix.length);
    for(var cy = 0; cy < matrixSize; cy++) {
      for(var cx = 0; cx < matrixSize; cx++) {
        var index = cy * matrixSize + cx;
        weights[index] = matrix[index] / divide;
      }
    }
    return weights;
  }

  void blur({num mix: 1}) => convolve([1, 1, 1, 1, 1, 1, 1, 1, 1], mix: mix, divide: 9);
  void gaussianBlur({num mix: 1}) => convolve([0.00000067, 0.00002292, 0.00019117, 0.00038771, 0.00019117, 0.00002292, 0.00000067,
                                               0.00002292, 0.00078633, 0.00655965, 0.01330373, 0.00655965, 0.00078633, 0.00002292,
                                               0.00019117, 0.00655965, 0.05472157, 0.11098164, 0.05472157, 0.00655965, 0.00019117,
                                               0.00038771, 0.01330373, 0.11098164, 0.22508352, 0.11098164, 0.01330373, 0.00038771,
                                               0.00019117, 0.00655965, 0.05472157, 0.11098164, 0.05472157, 0.00655965, 0.00019117,
                                               0.00002292, 0.00078633, 0.00655965, 0.01330373, 0.00655965, 0.00078633, 0.00002292,
                                               0.00000067, 0.00002292, 0.00019117, 0.00038771, 0.00019117, 0.00002292, 0.00000067], mix : mix);
  void sharpen({num mix: 1}) => convolve([0, -1, 0, -1, 5, -1, 0, -1, 0], mix : mix);
  void threshold(num threshold) {
    var data = _context.getImageData(0, 0, _canvas.width, _canvas.height);
    var pixels = data.data;
    int r, g, b;

    for(var i = 0; i < pixels.length; i += 4) {
      r = pixels[i];
      g = pixels[i + 1];
      b = pixels[i + 2];
      var v = (0.2126 * r + 0.7152 * g + 0.0722 * b >= threshold) ? 255 : 0;
      pixels[i] = pixels[i + 1] = pixels[i + 2] = v.toInt();
    }

    _context.putImageData(data, 0, 0);
  }

  void sepia() {
    var data = _context.getImageData(0, 0, _canvas.width, _canvas.height);
    var pixels = data.data;

    for(var i = 0; i < pixels.length; i += 4) {
      pixels[i + 0] = limitValue((pixels[i + 0] * .393) + (pixels[i + 1] * .769) + (pixels[i + 2] * .189), 0, 255).toInt();
      pixels[i + 1] = limitValue((pixels[i + 0] * .349) + (pixels[i + 1] * .686) + (pixels[i + 2] * .168), 0, 255).toInt();
      pixels[i + 2] = limitValue((pixels[i + 0] * .272) + (pixels[i + 1] * .534) + (pixels[i + 2] * .131), 0, 255).toInt();
    }

    _context.putImageData(data, 0, 0);
  }
}
