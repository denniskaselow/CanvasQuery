part of canvas_query;

/**
 * Create a [CanvasQuery] object using a [selector]. The [selector] can be a
 * a String that should be used to query the DOM or an existing [CanvasElement]
 * or [ImageElement] that should be wrapped.
 *
 * To create a new [CanvasQuery] object with a specific size the [selector]
 * argument will take an [int] argoument for the width.
 *
 * If no argument is given, the size of the window will be used for the new
 * [CanvasElement].
 */
CanvasQuery cq([var selector, int height]) {
  var canvas;
  if (null == selector || selector is int) {
    int width = (selector != null ? selector : window.innerWidth);
    height = (height != null ? height : window.innerHeight);
    canvas = new CanvasElement(width: width, height: height);
  } else if (selector is String) {
    canvas = query(selector);
  } else if (selector is ImageElement) {
    canvas = CanvasTools.createCanvas(selector);
  } else if (selector is CanvasQuery) {
    return selector;
  } else {
    canvas = selector;
  }
  return new CanvasQuery(canvas);
}

/**
 * The [CanvasQuery] class is a wrapper around [CanvasElement] and
 * [CanvasRenderingContext2D].
 */
class CanvasQuery implements CanvasRenderingContext2D {
  CanvasElement _canvas;
  CanvasRenderingContext2D _context;
  CanvasElement get canvas => _canvas;
  CanvasRenderingContext2D get context2d => _context;
  CanvasQuery(this._canvas) {
    _context = _canvas.context2d;
  }
  CanvasQuery.forWindow() {
    _canvas = new CanvasElement(width: window.innerWidth, height: window.innerHeight);
    _context = _canvas.context2d;
    window.onResize.listen((e) {
      _canvas.width = window.innerWidth;
      _canvas.height = window.innerHeight;
    });
  }
  CanvasQuery.query(String selector) : this(query(selector));
  CanvasQuery.forSize(int width, int height) : this(new CanvasElement(width: width, height: height));
  CanvasQuery.forImage(ImageElement img) : this(CanvasTools.createCanvas(img));

  dynamic noSuchMethod(InvocationMirror im) => im.invokeOn(_context);

  /** Appends the canvas to [element]. */
  void appendTo(Element element) {
    element.append(_canvas);
  }

  /**
   * Replaces the wrapped [CanvasElement] and [CanvasRenderingContext2D] in this
   * [CanvasQuery] object and in the DOM.
   */
  void replaceWith(CanvasQuery other) {
    _canvas.replaceWith(other.canvas);
    _canvas = other.canvas;
    _context = other.context2d;
  }

  /** Blends the canvas of this object onto [what] using [mode] and [mix]. */
  void blendOn(CanvasElement what, BlendFunction mode, [num mix = 1]) => CanvasTools.blend(what, this.canvas, mode, mix);
  /**
   * Blends the object [what] ([CanvasQuery], {CanvasElement], [ImageElement] or
   * color) onto this canvas using [mode] and [mix].
   */
  void blend(var what, BlendFunction mode, [num mix = 1]) {
    if (what is String) {
      blendColor(what, mode, mix);
    } else {
      CanvasTools.blend(this.canvas, what, mode, mix);
    }
  }
  /** Blends the color [what] onto this canvas using [mode] and [mix]. */
  void blendColor(String color, BlendFunction mode, [num mix = 1]) => blend(_createCanvas(color), mode, mix);
  /**
   * Blends the object [what] ([CanvasQuery], {CanvasElement], [ImageElement] or
   * color) onto this canvas using [mode] and [mix].
   */
  void blendSpecial(var what, SpecialBlendFunction mode, [num mix = 1]) {
    if (what is String) {
      blendSpecialColor(what, mode, mix);
    } else {
      CanvasTools.blendSpecial(this.canvas, what, mode, mix);
    }
  }
  /** Blends the color [what] onto this canvas using [mode] and [mix]. */
  void blendSpecialColor(String color, SpecialBlendFunction mode, [num mix = 1]) => blendSpecial(_createCanvas(color), mode, mix);

  CanvasElement _createCanvas(String color) => new CanvasElement(width: _canvas.width, height: _canvas.height)
                                                                ..context2d.fillStyle = color
                                                                ..context2d.fillRect(0, 0, _canvas.width, _canvas.height);
  /** Draws a circls at [x], [y] with [radius]. */
  void circle(num x, num y, num radius) => _context.arc(x, y, radius, 0, PI * 2, true);

  /** Crops the canvas. */
  void crop(int x, int y, int width, int height) {
    var canvas = new CanvasElement(width: width, height: height);
    var context = canvas.context2d;

    context.drawImageScaledFromSource(_canvas, x, y, width, height, 0, 0, width, height);
    _canvas.width = width;
    _canvas.height = height;
    clear();
    _context.drawImage(canvas, 0, 0);
  }

  /**
   * Resizes the canvas. If only [width] or [height] is passed, the image will
   * be resized proportionally.
   */
  void resize(int width, int height) {
    int w, h;
    if (height == null) {
      if(_canvas.width > width) {
        h = (_canvas.height * (width / _canvas.width)).toInt();
        w = width;
      } else {
        w = _canvas.width;
        h = _canvas.height;
      }
    } else if (width == null) {
      if(_canvas.height > height) {
        w = (_canvas.width * (height / _canvas.height)).toInt();
        h = height;
      } else {
        w = _canvas.width;
        h = _canvas.height;
      }
    }

    var resized = new CanvasQuery.forSize(w, h)..drawImageScaledFromSource(_canvas, 0, 0, _canvas.width, _canvas.height, 0, 0, w, h);
    _canvas = resized._canvas;
    _context = resized._context;
  }

  /**
   * Trim the canvas using [color] as the transparent color. If no [color] is
   * provided transparent pixels will be used to determine the size of the
   * trimmed canvas.
   */
  void trim({String color}) {
    bool transparent;
    List<int> targetColor;

    if (color != null) {
      targetColor = new Color.fromHex(color).toArray();
      transparent = targetColor[4] == 255 ? true : false;
    } else transparent = true;

    var sourceData = _context.getImageData(0, 0, _canvas.width, _canvas.height);
    var sourcePixels = sourceData.data;

    var bound = [_canvas.width, _canvas.height, 0, 0];

    for(var i = 0, len = sourcePixels.length; i < len; i += 4) {
      if(transparent) {
        if(sourcePixels[i + 3] == 0) continue;
      } else if(sourcePixels[i + 0] == color[0] && sourcePixels[i + 1] == color[1] && sourcePixels[i + 2] == color[2]) continue;
      var x = (i ~/ 4) % _canvas.width;
      var y = (i ~/ 4) ~/ _canvas.width;

      if(x < bound[0]) bound[0] = x;
      if(x > bound[2]) bound[2] = x;

      if(y < bound[1]) bound[1] = y;
      if(y > bound[3]) bound[3] = y;
    }

    if (bound[2] == 0 || bound[3] == 0) {
    } else {
      crop(bound[0], bound[1], bound[2] - bound[0] + 1, bound[3] - bound[1] + 1);
    }
  }

  /**
   * Resizes the canvas by using [pixelSize] to resize each pixel (no bluring).
   */
  void resizePixel(int pixelSize) {

    var sourceData = _context.getImageData(0, 0, _canvas.width, _canvas.height);
    var sourcePixels = sourceData.data;
    var canvas = new CanvasElement(width: _canvas.width * pixelSize, height: _canvas.height * pixelSize);
    var context = canvas.context2d;

    for(var i = 0, len = sourcePixels.length; i < len; i += 4) {
      if(sourcePixels[i + 3] == 0) continue;
      context.fillStyle = rgbToHex(sourcePixels[i + 0], sourcePixels[i + 1], sourcePixels[i + 2]);

      var x = (i ~/ 4) % _canvas.width;
      var y = (i ~/ 4) ~/ _canvas.width;

      context.fillRect(x * pixelSize, y * pixelSize, pixelSize, pixelSize);
    }

    _context = context;
    _canvas = canvas;
    // creates blurry images in Firefox, works fine in Chrome
//    var x = 0, y = 0;
//
//    canvas.width = _canvas.width * pixelSize | 0;
//    canvas.height = _canvas.height * pixelSize | 0;
//
//    while(x < _canvas.width) {
//      y = 0;
//      while(y < _canvas.height) {
//        context.drawImageScaledFromSource(_canvas, x, y, 1, 1, x * pixelSize, y * pixelSize, pixelSize, pixelSize);
//        y++;
//      }
//      x++;
//    }
//
//    _canvas = canvas;
//    _context = context;
  }

  /**
   * Reduces the colors of the image to the colors in the [palette].
   */
  void matchPalette(List<String> palette) {
    var imgData = _context.getImageData(0, 0, _canvas.width, _canvas.height);

    var rgbPalette = new List<Color>(palette.length);
    for(var i = 0; i < palette.length; i++) {
      rgbPalette[i] = new Color.fromHex(palette[i]);
    }

    for(var i = 0; i < imgData.data.length; i += 4) {
      var difList = new List<int>(rgbPalette.length);
      for(var j = 0; j < rgbPalette.length; j++) {
        var rgbVal = rgbPalette[j];
        var rDif = (imgData.data[i] - rgbVal.r).abs(),
            gDif = (imgData.data[i + 1] - rgbVal.g).abs(),
            bDif = (imgData.data[i + 2] - rgbVal.b).abs();
        difList[j] = rDif + gDif + bDif;
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

  /** Returns the colors used in the image. */
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

  /** Pixelizes the canvas. */
  void pixelize([int size = 4]) {
    if (_canvas.width < size) size = _canvas.width;
    var imageSmoothingEnabled = _context.imageSmoothingEnabled;
    _context.imageSmoothingEnabled = false;

    var scale = (_canvas.width / size) / _canvas.width;
    var temp = new CanvasQuery.forSize(_canvas.width, _canvas.height);
    var normal = new Rect(0, 0, _canvas.width, _canvas.height);
    var shrunk = new Rect(0, 0, (_canvas.width * scale).toInt(), (_canvas.height * scale).toInt());

    temp._context.drawImageToRect(_canvas, shrunk, sourceRect: normal);
    clear();
    _context.drawImageToRect(temp.canvas, normal, sourceRect: shrunk);

    _context.imageSmoothingEnabled = imageSmoothingEnabled;
  }

  /**
   * Returns a mask containing [true] for every pixel that does not have color [hexColor].
   * The mask will contain [true] for every other pixel if [inverted] is set to [true].
   */
  List<bool> colorToMask(String hexColor, {bool inverted: false}) {
    Color color = new Color.fromHex(hexColor);
    var sourceData = _context.getImageData(0, 0, _canvas.width, _canvas.height);
    var sourcePixels = sourceData.data;

    var mask = new List<bool>(sourcePixels.length ~/ 4);

    for(var i = 0; i < sourcePixels.length; i += 4) {
      if(sourcePixels[i + 0] == color.r && sourcePixels[i + 1] == color.g && sourcePixels[i + 2] == color.b) mask[i ~/ 4] = inverted;
      else mask[i ~/ 4] = !inverted;
    }

    return mask;
  }

  /**
   * Returns a grayscale maks of the canvas. Each value in the returned list
   * will be the average of the RGB-values.
   */
  List<int> grayscaleToMask() {
    var sourceData = _context.getImageData(0, 0, _canvas.width, _canvas.height);
    var sourcePixels = sourceData.data;

    var mask = new List<int>(sourcePixels.length ~/ 4);

    for(var i = 0; i < sourcePixels.length; i += 4) {
      mask[i~/4] = (sourcePixels[i + 0] + sourcePixels[i + 1] + sourcePixels[i + 2]) ~/ 3;
    }

    return mask;
  }

  /**
   * Convert grayscale of an image to its transparency.
   * Light pixels become opaque. Dark pixels become transparent.
   */
  void grayscaleToAlpha() {
    var sourceData = _context.getImageData(0, 0, _canvas.width, _canvas.height);
    var sourcePixels = sourceData.data;

    for(var i = 0, len = sourcePixels.length; i < len; i += 4) {
      sourcePixels[i + 3] = (sourcePixels[i + 0] + sourcePixels[i + 1] + sourcePixels[i + 2]) ~/ 3;

      sourcePixels[i + 0] = sourcePixels[i + 1] = sourcePixels[i + 2] = 255;
    }

    _context.putImageData(sourceData, 0, 0);
  }

  void applyMask(List mask) {
    var sourceData = _context.getImageData(0, 0, _canvas.width, _canvas.height);
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
    var colorMode = null != hexColorGradient ? "gradient" : "normal";

    var color = new Color.fromHex(hexColor);
    var colorB;
    if (null != hexColorGradient) {
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

  /** Clears the canvas with [color]. Calls clearRect if no color is passed. */
  void clear({String color}) {
    if(null != color) {
      _context.fillStyle = color;
      _context.fillRect(0, 0, _canvas.width, _canvas.height);
    } else {
      _context.clearRect(0, 0, _canvas.width, _canvas.height);
    }
  }

  /** Creates a new [CanvasElement] with the same size and content as this canvas. */
  CanvasElement copy() {
    var result = new CanvasElement(width: _canvas.width, height: _canvas.height);
    result.context2d.drawImage(_canvas, 0, 0);
    return result;
  }

  /** Sets the hue, saturation and lightness of the image. */
  void setHslAsList(List<num> hsl) => setHsl(hue: hsl[0], saturation: hsl[1], lightness: hsl[2]);
  /** Sets the [hue], [saturation] and [lightness] of the image. */
  void setHsl({num hue, num saturation, num lightness}) {
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

  /** Shifts the hue, saturation and lightness of the image by the passes amount. */
  void shiftHslAsList(List<num> hsl) => shiftHsl(hue: hsl[0], saturation: hsl[1], lightness: hsl[2]);
  /** Shifts the [hue], [saturation] and [lightness] of the image by the passes amount. */
  void shiftHsl({num hue, num saturation, num lightness}) {
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

      h = hIn == null ? hsl[0] : wrapValue(hsl[0] + hIn, 0.0, 1.0);
      s = sIn == null ? hsl[1] : limitValue(hsl[1] + sIn, 0.0, 1.0);
      l = lIn == null ? hsl[2] : limitValue(hsl[2] + lIn, 0.0, 1.0);

      newPixel = hslToRgb(h, s, l);

      pixels[i + 0] = newPixel[0];
      pixels[i + 1] = newPixel[1];
      pixels[i + 2] = newPixel[2];
    }
    _context.putImageData(data, 0, 0);
  }

  /** Replaces the hue of [src] with [dst]. */
  void replaceHue(double src, double dst) {
    var data = _context.getImageData(0, 0, _canvas.width, _canvas.height);
    var pixels = data.data;
    var h, hsl, newPixel;

    for(var i = 0, len = pixels.length; i < len; i += 4) {
      hsl = rgbToHsl(pixels[i + 0], pixels[i + 1], pixels[i + 2]);

      if ((hsl[0] - src).abs() < 0.05) h = wrapValue(dst, 0, 1); else h = hsl[0];

      newPixel = hslToRgb(h, hsl[1], hsl[2]);

      pixels[i + 0] = newPixel[0];
      pixels[i + 1] = newPixel[1];
      pixels[i + 2] = newPixel[2];
    }

    _context.putImageData(data, 0, 0);
  }

  /** Inverts the colors of the image. */
  void invert(src, dst) {
    var data = _context.getImageData(0, 0, _canvas.width, _canvas.height);
    var pixels = data.data;

    for(var i = 0, len = pixels.length; i < len; i += 4) {
      pixels[i + 0] = 255 - pixels[i + 0];
      pixels[i + 1] = 255 - pixels[i + 1];
      pixels[i + 2] = 255 - pixels[i + 2];
    }

    _context.putImageData(data, 0, 0);
  }

  /** Create a rect with rounded corners. */
  void roundRect(num x, num y, num width, num height, num radius) {
    _context..beginPath()
      ..moveTo(x + radius, y)
      ..lineTo(x + width - radius, y)
      ..quadraticCurveTo(x + width, y, x + width, y + radius)
      ..lineTo(x + width, y + height - radius)
      ..quadraticCurveTo(x + width, y + height, x + width - radius, y + height)
      ..lineTo(x + radius, y + height)
      ..quadraticCurveTo(x, y + height, x, y + height - radius)
      ..lineTo(x, y + radius)
      ..quadraticCurveTo(x, y, x + radius, y)
      ..closePath();
  }

  /**
   * Passed [text] will be written at [x], [y] and will be wrapped at [maxWidth].
   */
  void wrappedText(String text, int x, int y, [int maxWidth]) {

    var words = text.split(" ");

    var regexp = new RegExp(r"(\d+)");
    var h = int.parse(regexp.firstMatch(font).group(0)) * 2;

    var ox = 0;
    var oy = 0;

    var lines = new List<String>.from([""]);
    if (null != maxWidth) {
      var line = 0;

      for(var i = 0; i < words.length; i++) {
        var word = "${words[i]} ";
        var wordWidth = _context.measureText(word).width;

        if(ox + wordWidth > maxWidth) {
          lines.add("");
          line++;
          ox = 0;
        }

        lines[line] = "${lines[line]}$word";

        ox += wordWidth;
      }
    } else {
      lines = [text];
    }

    for(var i = 0; i < lines.length; i++) {
      var oy = (y + i * h * 0.6).toInt();

      var text = lines[i];

      _context.fillText(text, x, oy);
    }
  }

  /**
   * Returns a map of the 'height' and 'width' of a given [text]. If [maxWidth]
   * is given, the [text] will be wrapped.
   */
  Map<String, int> textBoundaries(String text, [num maxWidth]) {
    var words = text.split(" ");

    var regexp = new RegExp(r"(\d+)");
    var h = int.parse(regexp.firstMatch(font).group(0)) * 2;

    var ox = 0;
    var oy = 0;

    var lines = new List<String>.from([""]);
    if (null != maxWidth) {
      var line = 0;

      for(var i = 0; i < words.length; i++) {
        var word = "${words[i]} ";
        var wordWidth = _context.measureText(word).width;

        if(ox + wordWidth > maxWidth) {
          lines.add("");
          line++;
          ox = 0;
        }

        lines[line] = "${lines[line]}$word";

        ox += wordWidth;
      }
    } else {
      var lines = [text];
      maxWidth = _context.measureText(text).width;
    }

    return {
      "height": (lines.length * h * 0.6).toInt(),
      "width": maxWidth
    };
  }

  void paperBag(num x, num y, num width, num height, num blowX, num blowY) {
    _context..beginPath()
      ..moveTo(x, y)
      ..quadraticCurveTo(x + width / 2, y + height * blowY, x + width, y)
      ..quadraticCurveTo(x + width - width * blowX, y + height / 2, x + width, y + height)
      ..quadraticCurveTo(x + width / 2, y + height - height * blowY, x, y + height)
      ..quadraticCurveTo(x + width * blowX, y + height / 2, x, y)
      ..closePath();
  }

  /**
   * Creates an expandable area with borders from [image].
   * [x], [y], [width], [height] are the values for the border.
   * [top], [right], [bottom], [left] are the boundaries of the border in the
   * [image].
   */
  void borderImage(var image, num x, num y, num width, num height, num top, num right, num bottome, num left, {bool fill: false, String fillColor}) {
    _context
      /* top */
      ..drawImageScaledFromSource(image, left, 0, image.width - left - right, top, x + left, y, width - left - right, top)
      /* bottom */
      ..drawImageScaledFromSource(image, left, image.height - bottome, image.width - left - right, bottome, x + left, y + height - bottome, width - left - right, bottome)
      /* left */
      ..drawImageScaledFromSource(image, 0, top, left, image.height - bottome - top, x, y + top, left, height - bottome - top)
      /* right */
      ..drawImageScaledFromSource(image, image.width - right, top, right, image.height - bottome - top, x + width - right, y + top, right, height - bottome - top)
      /* top-left */
      ..drawImageScaledFromSource(image, 0, 0, left, top, x, y, left, top)
      /* top-right */
      ..drawImageScaledFromSource(image, image.width - right, 0, right, top, x + width - right, y, right, top)
      /* bottom-right */
      ..drawImageScaledFromSource(image, image.width - right, image.height - bottome, right, bottome, x + width - right, y + height - bottome, right, bottome)
      /* bottom-left */
      ..drawImageScaledFromSource(image, 0, image.height - bottome, left, bottome, x, y + height - bottome, left, bottome);

    if (null != fillColor) {
      _context..fillStyle = fillColor
          ..fillRect(x + left, y + top, width - left - right, height - top - bottome);
    } else if (fill) {
      _context.drawImageScaledFromSource(image, left, top, image.width - right - left, image.height - bottome - top, x + left, y + top, width - left - right, height - top - bottome);
    }
  }

  /**
   * Convolve an image using [matrix].
   * See [www.html5rocks.com/en/tutorials/canvas/imagefilters/].
   */
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
    var weights = new List<double>(matrix.length);
    for(var cy = 0; cy < matrixSize; cy++) {
      for(var cx = 0; cx < matrixSize; cx++) {
        var index = cy * matrixSize + cx;
        weights[index] = matrix[index] / divide;
      }
    }
    return weights;
  }

  /** Blurs an image. */
  void blur({num mix: 1}) => convolve([1, 1, 1, 1, 1, 1, 1, 1, 1], mix: mix, divide: 9);
  /** Applies a gaussian blur to an image. */
  void gaussianBlur({num mix: 1}) => convolve([0.00000067, 0.00002292, 0.00019117, 0.00038771, 0.00019117, 0.00002292, 0.00000067,
                                               0.00002292, 0.00078633, 0.00655965, 0.01330373, 0.00655965, 0.00078633, 0.00002292,
                                               0.00019117, 0.00655965, 0.05472157, 0.11098164, 0.05472157, 0.00655965, 0.00019117,
                                               0.00038771, 0.01330373, 0.11098164, 0.22508352, 0.11098164, 0.01330373, 0.00038771,
                                               0.00019117, 0.00655965, 0.05472157, 0.11098164, 0.05472157, 0.00655965, 0.00019117,
                                               0.00002292, 0.00078633, 0.00655965, 0.01330373, 0.00655965, 0.00078633, 0.00002292,
                                               0.00000067, 0.00002292, 0.00019117, 0.00038771, 0.00019117, 0.00002292, 0.00000067], mix : mix);
  /** Sharpens the image. */
  void sharpen({num mix: 1}) => convolve([0, -1, 0, -1, 5, -1, 0, -1, 0], mix : mix);
  /** Pixels with a grayscale value beyond [threashold] will become transparent. */
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

  /** Sepia filter. */
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

  void onDropImage(callback(ImageElement image)) {
    document.onDrop.listen((MouseEvent e) {
      e.stopPropagation();
      e.preventDefault();

      var file = e.dataTransfer.files[0];

      if (!file.type.startsWith('image/')) return false;
      var reader = new FileReader();

      reader.onLoad.listen((ProgressEvent pe) {
        var image = new ImageElement();

        image.onLoad.listen((e3) {
          callback(image);
        });

        image.src = reader.result;
      });

      reader.readAsDataUrl(file);

    });

    document.onDragOver.listen((e) {
      e.preventDefault();
    });
  }
}
