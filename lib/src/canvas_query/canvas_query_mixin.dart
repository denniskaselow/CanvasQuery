part of canvas_query;

class CanvasQueryMixin implements CanvasRenderingContext2D {
  static final Pattern _whitespacePattern = new RegExp((r'\s+'));
  CanvasElement _canvas;
  CqFramework _framework;
  Effects _effects;
  /// The wrapped [CanvasRenderingContext2D].
  /// The [CqFramework] to access several Event-[Stream]s.
  CqFramework get framework => _framework;
  /// The [Effects] object to apply effects to the wrapped [CanvasElement].
  Effects get effects {
    if (null == _effects) _effects = new Effects(this);
    return _effects;
  }

  /**
   * Appends the canvas to [element].
   */
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
    _context = other.context2D;
  }

  /**
   * Blends the canvas of this object onto [what] using [mode] and [mix].
   */
  void blendOn(CanvasElement what, BlendFunction mode, [num mix = 1]) => CqTools.blend(what, this.canvas, mode, mix);
  /**
   * Blends the object [what] ([CanvasQuery], [CanvasElement], [ImageElement] or
   * color) onto this canvas using [mode] and [mix].
   */
  void blend(var what, BlendFunction mode, [num mix = 1]) {
    if (what is String) {
      blendColor(what, mode, mix);
    } else {
      CqTools.blend(this.canvas, what, mode, mix);
    }
  }
  /**
   * Blends the color [what] onto this canvas using [mode] and [mix].
   */
  void blendColor(String color, BlendFunction mode, [num mix = 1]) => blend(_createCanvas(color), mode, mix);
  /**
   * Blends the object [what] ([CanvasQuery], [CanvasElement], [ImageElement] or
   * color) onto this canvas using [mode] and [mix].
   */
  void blendSpecial(var what, SpecialBlendFunction mode, [num mix = 1]) {
    if (what is String) {
      blendSpecialColor(what, mode, mix);
    } else {
      CqTools.blendSpecial(this.canvas, what, mode, mix);
    }
  }
  /**
   * Blends the color [what] onto this canvas using [mode] and [mix].
   */
  void blendSpecialColor(String color, SpecialBlendFunction mode, [num mix = 1]) => blendSpecial(_createCanvas(color), mode, mix);

  CanvasElement _createCanvas(String color) => new CanvasElement(width: _canvas.width, height: _canvas.height)
                                                                ..context2D.fillStyle = color
                                                                ..context2D.fillRect(0, 0, _canvas.width, _canvas.height);  CanvasRenderingContext2D _context;

  /**
   * Calls [stroke()] if [strokeStyle] is set.
   * Calls [fill()] if [fillStyle] is set.
   * The values of strokeStyle and fillStyle on the wrapped
   * [CanvasRenderingContext2D] will only be changed for the call
   * to this function and will be reset afterwards.
   */
  void strokeAndFill({String strokeStyle, String fillStyle}) {
    if (null != strokeStyle) {
      var tmp = this.strokeStyle;
      this.strokeStyle = strokeStyle;
      stroke();
      this.strokeStyle = tmp;
    }
    if (null != fillStyle) {
      var tmp = this.fillStyle;
      this.fillStyle = fillStyle;
      fill();
      this.fillStyle = tmp;
    }
  }

  /**
   * Draws a circls at [x], [y] with [radius].
   */
  void circle(num x, num y, num radius, {String strokeStyle, String fillStyle}) {
    beginPath();
    arc(x, y, radius, 0, PI * 2, true);
    closePath();
    strokeAndFill(strokeStyle: strokeStyle, fillStyle: fillStyle);
  }

  /**
   * Crops the canvas.
   */
  void crop(int x, int y, int width, int height) {
    var canvas = new CanvasElement(width: width, height: height);
    var context = canvas.context2D;

    context.drawImageScaledFromSource(_canvas, x, y, width, height, 0, 0, width, height);
    _canvas.width = width;
    _canvas.height = height;
    clear();
    drawImage(canvas, 0, 0);
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
   * Trims the canvas using [color] as the transparent color. If no [color] is
   * provided transparent pixels will be used to determine the size of the
   * trimmed canvas.
   *
   * Returns a [Rectangle] with the trim boundaries or null if nothing was trimmed.
   */
  Rectangle trim({String color}) {
    bool transparent;
    List<int> targetColor;
    var boundary;

    if (color != null) {
      targetColor = new Color.fromHex(color).toArray();
      transparent = targetColor[3] == 1.0 ? false : true;
    } else transparent = true;

    var sourceData = getImageData(0, 0, _canvas.width, _canvas.height);
    var sourcePixels = sourceData.data;

    var bound = [_canvas.width, _canvas.height, 0, 0];

    for(var i = 0, len = sourcePixels.length; i < len; i += 4) {
      if(transparent) {
        if(sourcePixels[i + 3] == 0) continue;
      } else if(sourcePixels[i + 0] == targetColor[0] && sourcePixels[i + 1] == targetColor[1] && sourcePixels[i + 2] == targetColor[2]) continue;
      var x = (i ~/ 4) % _canvas.width;
      var y = (i ~/ 4) ~/ _canvas.width;

      if(x < bound[0]) bound[0] = x;
      if(x > bound[2]) bound[2] = x;

      if(y < bound[1]) bound[1] = y;
      if(y > bound[3]) bound[3] = y;
    }

    if (bound[2] == 0 || bound[3] == 0) {
    } else {
      boundary = new Rectangle(bound[0], bound[1], bound[2] - bound[0], bound[3] - bound[1]);

      crop(bound[0], bound[1], bound[2] - bound[0] + 1, bound[3] - bound[1] + 1);
    }
    return boundary;
  }

  /**
   * Resizes the canvas by using [pixelSize] to resize each pixel (no bluring).
   */
  void resizePixel(int pixelSize) {

    var sourceData = getImageData(0, 0, _canvas.width, _canvas.height);
    var sourcePixels = sourceData.data;
    var canvas = new CanvasElement(width: _canvas.width * pixelSize, height: _canvas.height * pixelSize);
    var context = canvas.context2D;

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
    var imgData = getImageData(0, 0, _canvas.width, _canvas.height);

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

    putImageData(imgData, 0, 0);
  }

  /**
   * Returns a [List<String>] of the colors used in the canvas.
   */
  List<String> getPalette() {
    var palette = new List<String>();
    var sourceData = getImageData(0, 0, _canvas.width, _canvas.height);
    var sourcePixels = sourceData.data;

    for(var i = 0; i < sourcePixels.length; i += 4) {
      if(0 != sourcePixels[i + 3]) {
        var hex = rgbToHex(sourcePixels[i + 0], sourcePixels[i + 1], sourcePixels[i + 2]);
        if(palette.indexOf(hex) == -1) palette.add(hex);
      }
    }

    return palette;
  }

  /**
   * Pixelizes the canvas.
   */
  void pixelize([int size = 4]) {
    if (_canvas.width < size) size = _canvas.width;
    var tmp = imageSmoothingEnabled;
    imageSmoothingEnabled = false;

    var scale = (_canvas.width / size) / _canvas.width;
    var temp = new CanvasQuery.forSize(_canvas.width, _canvas.height);
    var normal = new Rectangle(0, 0, _canvas.width, _canvas.height);
    var shrunk = new Rectangle(0, 0, (_canvas.width * scale).toInt(), (_canvas.height * scale).toInt());

    temp.drawImageToRect(_canvas, shrunk, sourceRect: normal);
    clear();
    drawImageToRect(temp.canvas, normal, sourceRect: shrunk);

    imageSmoothingEnabled = tmp;
  }

  /**
   * Returns a mask containing [true] for every pixel that does not have color [hexColor].
   * The mask will contain [true] for every other pixel if [inverted] is set to [true].
   */
  List<bool> colorToMask(String hexColor, {bool inverted: false}) {
    Color color = new Color.fromHex(hexColor);
    var sourceData = getImageData(0, 0, _canvas.width, _canvas.height);
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
    var sourceData = getImageData(0, 0, _canvas.width, _canvas.height);
    var sourcePixels = sourceData.data;

    var mask = new List<int>(sourcePixels.length ~/ 4);

    for(var i = 0; i < sourcePixels.length; i += 4) {
      mask[i~/4] = (sourcePixels[i + 0] + sourcePixels[i + 1] + sourcePixels[i + 2]) ~/ 3;
    }

    return mask;
  }

  /**
   * Converts grayscale of an image to its transparency.
   * Light pixels become opaque. Dark pixels become transparent.
   */
  void grayscaleToAlpha() {
    var sourceData = getImageData(0, 0, _canvas.width, _canvas.height);
    var sourcePixels = sourceData.data;

    for(var i = 0, len = sourcePixels.length; i < len; i += 4) {
      sourcePixels[i + 3] = (sourcePixels[i + 0] + sourcePixels[i + 1] + sourcePixels[i + 2]) ~/ 3;

      sourcePixels[i + 0] = sourcePixels[i + 1] = sourcePixels[i + 2] = 255;
    }

    putImageData(sourceData, 0, 0);
  }

  /**
   * Applies a mask.
   * For a mask of [bool] every [true] value will turn a pixel transparent.
   * For a grayscalemask of [int] values, black will turn a pixel transparent.
   */
  void applyMask(List mask) {
    var sourceData = getImageData(0, 0, _canvas.width, _canvas.height);
    var sourcePixels = sourceData.data;

    var mode = mask is List<bool> ? "bool" : "byte";

    for(var i = 0, len = sourcePixels.length; i < len; i += 4) {
      var value = mask[i ~/ 4];

      if(mode == "bool") sourcePixels[i + 3] = value ? 255 : 0;
      else sourcePixels[i + 3] = value;
    }

    putImageData(sourceData, 0, 0);
  }

  /**
   * Fills the canvas using [hexColor] for [true] and
   * [hexColorGradient] for [false] bits in the [mask]. If the mask is a
   * grayscale, a gradient between both colors will be created.
   */
  void fillMask(List mask, String hexColor, [String hexColorGradient]) {

    var sourceData = getImageData(0, 0, _canvas.width, _canvas.height);
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

    putImageData(sourceData, 0, 0);
  }

  /**
   * Clears the canvas with [color]. Calls [clearRect()] if no color is passed.
   */
  void clear({String color}) {
    if(null != color) {
      fillStyle = color;
      fillRect(0, 0, _canvas.width, _canvas.height);
    } else {
      clearRect(0, 0, _canvas.width, _canvas.height);
    }
  }

  /**
   * Creates a new [CanvasElement] with the same size and content as this canvas.
   */
  CanvasElement copy() {
    var result = new CanvasElement(width: _canvas.width, height: _canvas.height);
    result.context2D.drawImage(_canvas, 0, 0);
    return result;
  }

  /**
   * Sets the hue, saturation and lightness of the image.
   */
  void setHslAsList(List<num> hsl) => setHsl(hue: hsl[0], saturation: hsl[1], lightness: hsl[2]);
  /**
   * Sets the [hue], [saturation] and [lightness] of the image.
   */
  void setHsl({num hue, num saturation, num lightness}) {
    double hIn = null == hue ? null : limitValue(hue, 0, 1).toDouble();
    double sIn = null == saturation ? null : limitValue(saturation, 0, 1).toDouble();
    double lIn = null == lightness ? null : limitValue(lightness, 0, 1).toDouble();

    var data = getImageData(0, 0, _canvas.width, _canvas.height);
    var pixels = data.data;
    double h, s, l;
    List<double> hsl;
    List<int> newPixel;

    for(var i = 0, len = pixels.length; i < len; i += 4) {
      hsl = rgbToHsl(pixels[i + 0], pixels[i + 1], pixels[i + 2]);

      h = hIn == null ? hsl[0] : hIn;
      s = sIn == null ? hsl[1] : sIn;
      l = lIn == null ? hsl[2] : lIn;

      newPixel = hslToRgb(h, s, l);

      pixels[i + 0] = newPixel[0];
      pixels[i + 1] = newPixel[1];
      pixels[i + 2] = newPixel[2];
    }

    putImageData(data, 0, 0);
  }

  /**
   * Shifts the hue, saturation and lightness of the image by the passes amount.
   * */
  void shiftHslAsList(List<num> hsl) => shiftHsl(hue: hsl[0], saturation: hsl[1], lightness: hsl[2]);
  /**
   * Shifts the [hue], [saturation] and [lightness] of the image by the passes amount.
   */
  void shiftHsl({num hue, num saturation, num lightness}) {
    double hIn = null == hue ? null : hue.toDouble();
    double sIn = null == saturation ? null : saturation.toDouble();
    double lIn = null == lightness ? null : lightness.toDouble();

    var data = getImageData(0, 0, _canvas.width, _canvas.height);
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
    putImageData(data, 0, 0);
  }

  /**
   * Replaces the hue of 0<=[src]<=1 with 0<=[dst]<=1.
   */
  void replaceHue(num src, num dst) {
    var data = getImageData(0, 0, _canvas.width, _canvas.height);
    var pixels = data.data;
    var h, hsl, newPixel;

    for(var i = 0, len = pixels.length; i < len; i += 4) {
      hsl = rgbToHsl(pixels[i + 0], pixels[i + 1], pixels[i + 2]);

      if ((hsl[0] - src).abs() < 0.05) h = wrapValue(dst, 0, 1);
      else h = hsl[0];

      newPixel = hslToRgb(h, hsl[1], hsl[2]);

      pixels[i + 0] = newPixel[0];
      pixels[i + 1] = newPixel[1];
      pixels[i + 2] = newPixel[2];
    }

    putImageData(data, 0, 0);
  }

  /**
   * Inverts the colors of the image.
   */
  void invert() {
    var data = getImageData(0, 0, _canvas.width, _canvas.height);
    var pixels = data.data;

    for(var i = 0, len = pixels.length; i < len; i += 4) {
      pixels[i + 0] = 255 - pixels[i + 0];
      pixels[i + 1] = 255 - pixels[i + 1];
      pixels[i + 2] = 255 - pixels[i + 2];
    }

    putImageData(data, 0, 0);
  }

  /**
   * Creates a rect with rounded corners.
   */
  void roundRect(num x, num y, num width, num height, num radius, {String strokeStyle, String fillStyle}) {
    beginPath();
    moveTo(x + radius, y);
    lineTo(x + width - radius, y);
    quadraticCurveTo(x + width, y, x + width, y + radius);
    lineTo(x + width, y + height - radius);
    quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
    lineTo(x + radius, y + height);
    quadraticCurveTo(x, y + height, x, y + height - radius);
    lineTo(x, y + radius);
    quadraticCurveTo(x, y, x + radius, y);
    closePath();
    strokeAndFill(strokeStyle: strokeStyle, fillStyle: fillStyle);
  }

  /**
   * Creates a [text] with [gradient] colors. If a [maxWidth] is set the [text]
   * will wrap around at [maxWidth].
   * The [gradient] is a list of color stops and colors.
   * E.g.
   *     [0, '#000000', 0.5, '#FF0000', 1, '#0000FF']
   */
  void gradientText(String text, int x, int y, List gradient, [num maxWidth]) {
    var regexp = new RegExp(r"(\d+)");
    var h = int.parse(regexp.firstMatch(font).group(0)) * 2;
    var lines = getLines(text, maxWidth);
    var oldFillStyle = fillStyle;

    for(var i = 0; i < lines.length; i++) {
      var oy = (y + i * h * 0.6).toInt();
      var lingrad = createLinearGradient(0, oy, 0, (oy + h * 0.6).toInt());

      for(var j = 0; j < gradient.length; j += 2) {
        lingrad.addColorStop(gradient[j], gradient[j + 1]);
      }
      fillStyle = lingrad;
      fillText(lines[i], x, oy);
    }
    fillStyle = oldFillStyle;
  }

  /**
   * Writes [text] at [x], [y] and wraps at [maxWidth].
   *
   * The [nlCallback] will be called before a line is written.
   */
  void wrappedText(String text, int x, int y, num maxWidth, {NewlineCallback nlCallback}) {
    var regexp = new RegExp(r"(\d+)");
    var h = int.parse(regexp.firstMatch(font).group(0)) * 2;
    var lines = getLines(text, maxWidth);

    for(var i = 0; i < lines.length; i++) {
      var oy = (y + i * h * 0.6).toInt();
      if (null != nlCallback) {
        nlCallback(x, oy);
      }
      var line = lines[i];
      fillText(line, x, oy);
    }
  }

  /**
   * Returns a [Rectangle] with the size of a given [text]. If [maxWidth]
   * is given, the [text] will be wrapped.
   */
  Rectangle textBoundaries(String text, [num maxWidth]) {
    var regexp = new RegExp(r"(\d+)");
    var h = int.parse(regexp.firstMatch(font).group(0)) * 2;
    List<String> lines = getLines(text, maxWidth);
    if (null == maxWidth) {
      maxWidth = measureText(text).width;
    }
    return new Rectangle(0, 0, maxWidth, (lines.length * h * 0.6).toInt());
  }

  /**
   * Splits the [text] at [maxWidth] and returns a list of lines.
   */
  List<String> getLines(String text, [num maxWidth]) {
    var words = text.split(_whitespacePattern);

    var ox = 0;
    var oy = 0;

    var lines = new List<String>.from([""]);
    var spaceWidth = measureText(" ").width;
    if (null != maxWidth) {
      maxWidth += spaceWidth;
      var line = 0;
      for(var i = 0; i < words.length; i++) {
        var word = "${words[i]} ";
        var wordWidth = measureText(word).width;

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
    return lines;
  }

  /**
   * Creates a paper bag shaped path.
   */
  void paperBag(num x, num y, num width, num height, num blowX, num blowY, {String strokeStyle, String fillStyle}) {
    beginPath();
    moveTo(x, y);
    quadraticCurveTo(x + width / 2, y + height * blowY, x + width, y);
    quadraticCurveTo(x + width - width * blowX, y + height / 2, x + width, y + height);
    quadraticCurveTo(x + width / 2, y + height - height * blowY, x, y + height);
    quadraticCurveTo(x + width * blowX, y + height / 2, x, y);
    closePath();
    strokeAndFill(strokeStyle: strokeStyle, fillStyle: fillStyle);
  }

  /**
   * Creates an expandable area with borders from [image].
   * [x], [y], [width], [height] are the values for the border.
   * [top], [right], [bottom], [left] are the boundaries of the border in the
   * [image].
   */
  void borderImage(var image, num x, num y, num width, num height, num top, num right, num bottom, num left, {bool fill: false, String fillStyle}) {
    /* top */
    drawImageScaledFromSource(image, left, 0, image.width - left - right, top, x + left, y, width - left - right, top);
    /* bottom */
    drawImageScaledFromSource(image, left, image.height - bottom, image.width - left - right, bottom, x + left, y + height - bottom, width - left - right, bottom);
    /* left */
    drawImageScaledFromSource(image, 0, top, left, image.height - bottom - top, x, y + top, left, height - bottom - top);
    /* right */
    drawImageScaledFromSource(image, image.width - right, top, right, image.height - bottom - top, x + width - right, y + top, right, height - bottom - top);
    /* top-left */
    drawImageScaledFromSource(image, 0, 0, left, top, x, y, left, top);
    /* top-right */
    drawImageScaledFromSource(image, image.width - right, 0, right, top, x + width - right, y, right, top);
    /* bottom-right */
    drawImageScaledFromSource(image, image.width - right, image.height - bottom, right, bottom, x + width - right, y + height - bottom, right, bottom);
    /* bottom-left */
    drawImageScaledFromSource(image, 0, image.height - bottom, left, bottom, x, y + height - bottom, left, bottom);

    if (null != fillStyle) {
      var oldFillStyle = this.fillStyle;
      this.fillStyle = fillStyle;
      fillRect(x + left, y + top, width - left - right, height - top - bottom);
      this.fillStyle = oldFillStyle;
    } else if (fill) {
      drawImageScaledFromSource(image, left, top, image.width - right - left, image.height - bottom - top, x + left, y + top, width - left - right, height - top - bottom);
    }
  }

  // properties and functions of [CanvasRenderingContext2D]
  // not using noSuchMethod for smaller and faster code
  double get backingStorePixelRatio => _context.backingStorePixelRatio;
  CanvasElement get canvas => _canvas;
  Path get currentPath => _context.currentPath;
  get fillStyle =>  _context.fillStyle;
  String get font =>  _context.font;
  num get globalAlpha => _context.globalAlpha;
  String get globalCompositeOperation => _context.globalCompositeOperation;
  bool get imageSmoothingEnabled => _context.imageSmoothingEnabled;
  String get lineCap => _context.lineCap;
  num get lineDashOffset => _context.lineDashOffset;
  String get lineJoin => _context.lineJoin;
  num get lineWidth => _context.lineWidth;
  num get miterLimit => _context.miterLimit;
  num get shadowBlur => _context.shadowBlur;
  String get shadowColor => _context.shadowColor;
  num get shadowOffsetX => _context.shadowOffsetX;
  num get shadowOffsetY => _context.shadowOffsetY;
  get strokeStyle => _context.strokeStyle;
  String get textAlign => _context.textAlign;
  String get textBaseline => _context.textBaseline;

  void set currentPath(Path value) { _context.currentPath = value; }
  void set fillStyle(value) { _context.fillStyle = value; }
  void set font(String value) { _context.font = value; }
  void set globalAlpha(num value) { _context.globalAlpha = value; }
  void set globalCompositeOperation(String value) { _context.globalCompositeOperation = value; }
  void set imageSmoothingEnabled(bool value) { _context.imageSmoothingEnabled = value; }
  void set lineCap(String value) { _context.lineCap = value; }
  void set lineDashOffset(num value) { _context.lineDashOffset = value; }
  void set lineJoin(String value) { _context.lineJoin = value; }
  void set lineWidth(num value) { _context.lineWidth = value; }
  void set miterLimit(num value) { _context.miterLimit = value; }
  void set shadowBlur(num value) { _context.shadowBlur = value; }
  void set shadowColor(String value) { _context.shadowColor = value; }
  void set shadowOffsetX(num value) { _context.shadowOffsetX = value; }
  void set shadowOffsetY(num value) { _context.shadowOffsetY = value; }
  void set strokeStyle(value) { _context.strokeStyle = value; }
  void set textAlign(String value) { _context.textAlign = value; }
  void set textBaseline(String value) { _context.textBaseline = value; }

  void arc(num x, num y, num radius, num startAngle, num endAngle, [bool anticlockwise = false]) => _context.arc(x, y, radius, startAngle, endAngle);
  void arcTo(num x1, num y1, num x2, num y2, num radius) => _context.arcTo(x1, y1, x2, y2, radius);
  void beginPath() => _context.beginPath();
  void bezierCurveTo(num cp1x, num cp1y, num cp2x, num cp2y, num x, num y) => _context.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x, y);
  void clearRect(num x, num y, num width, num height) => _context.clearRect(x, y, width, height);
  void clip([String winding]) {
    if (null == winding) {
      _context.clip();
    } else {
      _context.clip(winding);
    }
  }
  void closePath() => _context.closePath();
  ImageData createImageData(num sw, num sh) => _context.createImageData(sw, sh);
  ImageData createImageDataFromImageData(ImageData imagedata) => _context.createImageDataFromImageData(imagedata);
  CanvasGradient createLinearGradient(num x0, num y0, num x1, num y1) => _context.createLinearGradient(x0, y0, x1, y1);
  CanvasPattern createPattern(CanvasElement canvas, String repetitionType) =>  _context.createPattern(canvas, repetitionType);
  CanvasPattern createPatternFromImage(ImageElement image, String repetitionType) => _context.createPatternFromImage(image, repetitionType);
  CanvasGradient createRadialGradient(num x0, num y0, num r0, num x1, num y1, num r1) => _context.createRadialGradient(x0, y0, r0, x1, y1, r1);
  bool drawCustomFocusRing(Element element) => _context.drawCustomFocusRing(element);
  void drawImage(CanvasImageSource source, num destX, num destY) => _context.drawImage(source, destX, destY);
  void drawImageScaled(CanvasImageSource source, num destX, num destY, num destWidth, num destHeight) => _context.drawImageScaled(source, destX, destY, destWidth, destHeight);
  void drawImageScaledFromSource(CanvasImageSource source, num sourceX, num sourceY, num sourceWidth, num sourceHeight, num destX, num destY, num destWidth, num destHeight) => _context.drawImageScaledFromSource(source, sourceX, sourceY, sourceWidth, sourceHeight, destX, destY, destWidth, destHeight);
  void drawImageToRect(CanvasImageSource source, Rectangle destRect, {Rectangle sourceRect}) => _context.drawImageToRect(source, destRect, sourceRect: sourceRect);
  void drawSystemFocusRing(Element element) => _context.drawSystemFocusRing(element);
  void ellipse(num x, num y, num radiusX, num radiusY, num rotation, num startAngle, num endAngle, bool anticlockwise) => _context.ellipse(x, y, radiusX, radiusY, rotation, startAngle, endAngle, anticlockwise);
  void fill([String winding]) {
    if (null == winding) {
      _context.fill();
    } else {
      _context.fill(winding);
    }
  }
  void fillRect(num x, num y, num width, num height) => _context.fillRect(x, y, width, height);
  void fillText(String text, num x, num y, [num maxWidth]) => _context.fillText(text, x, y, maxWidth);
  Canvas2DContextAttributes getContextAttributes() => _context.getContextAttributes();
  ImageData getImageData(num sx, num sy, num sw, num sh) => _context.getImageData(sx, sy, sw, sh);
  ImageData getImageDataHD(num sx, num sy, num sw, num sh) => _context.getImageDataHD(sx, sy, sw, sh);
  List<num> getLineDash() => _context.getLineDash();
  bool isPointInPath(num x, num y, [String winding]) {
    if (null == winding) {
      _context.isPointInPath(x, y);
    } else {
      _context.isPointInPath(x, y, winding);
    }
  }
  bool isPointInStroke(num x, num y) => _context.isPointInStroke(x, y);
  void lineTo(num x, num y) => _context.lineTo(x, y);
  TextMetrics measureText(String text) => _context.measureText(text);
  void moveTo(num x, num y) => _context.moveTo(x, y);
  void putImageData(ImageData imagedata, num dx, num dy, [num dirtyX, num dirtyY, num dirtyWidth, num dirtyHeight]) => _context.putImageData(imagedata, dx, dy, dirtyX, dirtyY, dirtyWidth, dirtyHeight);
  void putImageDataHD(ImageData imagedata, num dx, num dy, [num dirtyX, num dirtyY, num dirtyWidth, num dirtyHeight]) => _context.putImageDataHD(imagedata, dx, dy, dirtyX, dirtyY, dirtyWidth, dirtyHeight);
  void quadraticCurveTo(num cpx, num cpy, num x, num y) => _context.quadraticCurveTo(cpx, cpy, x, y);
  void rect(num x, num y, num width, num height) => _context.rect(x, y, width, height);
  void resetTransform() => _context.resetTransform();
  void restore() => _context.restore();
  void rotate(num angle) => _context.rotate(angle);
  void save() => _context.save();
  void scale(num sx, num sy) => _context.scale(sx, sy);
  void setFillColorHsl(int h, num s, num l, [num a = 1]) => _context.setFillColorHsl(h, s, l, a);
  void setFillColorRgb(int r, int g, int b, [num a = 1]) => _context.setFillColorRgb(r, g, b, a);
  void setLineDash(List<num> dash) => _context.setLineDash(dash);
  void setStrokeColorHsl(int h, num s, num l, [num a = 1]) => _context.setStrokeColorHsl(h, s, l, a);
  void setStrokeColorRgb(int r, int g, int b, [num a = 1]) => _context.setStrokeColorRgb(r, g, b, a);
  void setTransform(num m11, num m12, num m21, num m22, num dx, num dy) => _context.setTransform(m11, m12, m21, m22, dx, dy);
  void stroke() => _context.stroke();
  void strokeRect(num x, num y, num width, num height) => _context.strokeRect(x, y, width, height);
  void strokeText(String text, num x, num y, [num maxWidth]) => _context.strokeText(text, x, y, maxWidth);
  void transform(num m11, num m12, num m21, num m22, num dx, num dy) => _context.transform(m11, m12, m21, m22, dx, dy);
  void translate(num tx, num ty) => _context.translate(tx, ty);
}

typedef void NewlineCallback(int x, int y);