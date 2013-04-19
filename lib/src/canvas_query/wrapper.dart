part of canvas_query;

/**
 * Create a [CqWrapper] object using a [selector]. The [selector] can be a
 * a String that should be used to query the DOM or an existing [CanvasElement]
 * or [ImageElement] that should be wrapped.
 *
 * To create a new [CqWrapper] object with a specific size the [selector]
 * argument will take an [int] argoument for the width.
 *
 * If no argument is given, the size of the window will be used for the new
 * [CanvasElement].
 */
CqWrapper cq([var selector, int height]) {
  var canvas;
  if (null == selector || selector is int) {
    int width = (selector != null ? selector : window.innerWidth);
    height = (height != null ? height : window.innerHeight);
    canvas = new CanvasElement(width: width, height: height);
  } else if (selector is String) {
    canvas = query(selector);
  } else if (selector is ImageElement) {
    canvas = CqTools.createCanvas(selector);
  } else if (selector is CqWrapper) {
    return selector;
  } else {
    canvas = selector;
  }
  return new CqWrapper(canvas);
}

/**
 * Wrapper around [CanvasElement] and [CanvasRenderingContext2D] offering
 * additional functionality.
 */
class CqWrapper implements CanvasRenderingContext2D {
  static final Pattern _whitespacePattern = new RegExp((r'\s+'));
  CanvasElement _canvas;
  CanvasRenderingContext2D _context;
  CqFramework _framework;
  /// The wrapped [CanvasElement].
  CanvasElement get canvas => _canvas;
  /// The wrapped [CanvasRenderingContext2D].
  CanvasRenderingContext2D get context2d => _context;
  /// The [CqFramework] to access several Event-[Stream]s.
  CqFramework get framework => _framework;
  /**
   * Wrap an existing [CanvasElement].
   */
  CqWrapper(this._canvas) {
    _context = _canvas.context2D;
    _framework = new CqFramework._(this);
  }
  /**
   * Creates and wrap a [CanvasElement] covering the whole window. Resizing included.
   */
  CqWrapper.forWindow() {
    _canvas = new CanvasElement(width: window.innerWidth, height: window.innerHeight);
    _context = _canvas.context2D;
    window.onResize.listen((e) {
      _canvas.width = window.innerWidth;
      _canvas.height = window.innerHeight;
    });
  }
  /**
   * Queries a {CanvasElement] from the DOM and wraps it.
   */
  CqWrapper.query(String selector) : this(query(selector));
  /**
   * Creates and wraps a [CanvasElement] with the given [width] and [height].
   */
  CqWrapper.forSize(int width, int height) : this(new CanvasElement(width: width, height: height));
  /**
   * Creates and wraps a [CanvasElement] using the given image.
   */
  CqWrapper.forImage(ImageElement img) : this(CqTools.createCanvas(img));

  /**
   * Delegates to the wrapped [CanvasRenderingContext2D].
   */
  dynamic noSuchMethod(Invocation im) => im.invokeOn(_context);

  /**
   * Appends the canvas to [element].
   */
  void appendTo(Element element) {
    element.append(_canvas);
  }

  /**
   * Replaces the wrapped [CanvasElement] and [CanvasRenderingContext2D] in this
   * [CqWrapper] object and in the DOM.
   */
  void replaceWith(CqWrapper other) {
    _canvas.replaceWith(other.canvas);
    _canvas = other.canvas;
    _context = other.context2d;
  }

  /**
   * Blends the canvas of this object onto [what] using [mode] and [mix].
   */
  void blendOn(CanvasElement what, BlendFunction mode, [num mix = 1]) => CqTools.blend(what, this.canvas, mode, mix);
  /**
   * Blends the object [what] ([CqWrapper], [CanvasElement], [ImageElement] or
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
   * Blends the object [what] ([CqWrapper], [CanvasElement], [ImageElement] or
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
                                                                ..context2D.fillRect(0, 0, _canvas.width, _canvas.height);

  /**
   * Calls [stroke()] if [strokeStyle] is set.
   * Calls [fill()] if [fillStyle] is set.
   * The values of strokeStyle and fillStyle on the wrapped
   * [CanvasRenderingContext2D] will only be changed for the call
   * to this function and will be reset afterwards.
   */
  void strokeAndFill({String strokeStyle, String fillStyle}) {
    if (null != strokeStyle) {
      var tmp = _context.strokeStyle;
      _context..strokeStyle = strokeStyle
              ..stroke()
              ..strokeStyle = tmp;
    }
    if (null != fillStyle) {
      var tmp = _context.fillStyle;
      _context..fillStyle = fillStyle
              ..fill()
              ..fillStyle = tmp;
    }
  }

  /**
   * Draws a circls at [x], [y] with [radius].
   */
  void circle(num x, num y, num radius, {String strokeStyle, String fillStyle}) {
    _context.beginPath();
    _context.arc(x, y, radius, 0, PI * 2, true);
    _context.closePath();
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

    var resized = new CqWrapper.forSize(w, h)..drawImageScaledFromSource(_canvas, 0, 0, _canvas.width, _canvas.height, 0, 0, w, h);
    _canvas = resized._canvas;
    _context = resized._context;
  }

  /**
   * Trims the canvas using [color] as the transparent color. If no [color] is
   * provided transparent pixels will be used to determine the size of the
   * trimmed canvas.
   *
   * Returns a [Rect] with the trim boundaries or null if nothing was trimmed.
   */
  Rect trim({String color}) {
    bool transparent;
    List<int> targetColor;
    var boundary;

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
      boundary = new Rect(bound[0], bound[1], bound[2] - bound[0], bound[3] - bound[1]);

      crop(bound[0], bound[1], bound[2] - bound[0] + 1, bound[3] - bound[1] + 1);
    }
    return boundary;
  }

  /**
   * Resizes the canvas by using [pixelSize] to resize each pixel (no bluring).
   */
  void resizePixel(int pixelSize) {

    var sourceData = _context.getImageData(0, 0, _canvas.width, _canvas.height);
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

  /**
   * Returns a [List<String>] of the colors used in the canvas.
   */
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

  /**
   * Pixelizes the canvas.
   */
  void pixelize([int size = 4]) {
    if (_canvas.width < size) size = _canvas.width;
    var imageSmoothingEnabled = _context.imageSmoothingEnabled;
    _context.imageSmoothingEnabled = false;

    var scale = (_canvas.width / size) / _canvas.width;
    var temp = new CqWrapper.forSize(_canvas.width, _canvas.height);
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
   * Converts grayscale of an image to its transparency.
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

  /**
   * Applies a mask.
   * For a mask of [bool] every [true] value will turn a pixel transparent.
   * For a grayscalemask of [int] values, black will turn a pixel transparent.
   */
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

  /**
   * Fills the canvas using [hexColor] for [true] and
   * [hexColorGradient] for [false] bits in the [mask]. If the mask is a
   * grayscale, a gradient between both colors will be created.
   */
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

  /**
   * Clears the canvas with [color]. Calls [clearRect()] if no color is passed.
   */
  void clear({String color}) {
    if(null != color) {
      _context.fillStyle = color;
      _context.fillRect(0, 0, _canvas.width, _canvas.height);
    } else {
      _context.clearRect(0, 0, _canvas.width, _canvas.height);
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

  /**
   * Replaces the hue of 0<=[src]<=1 with 0<=[dst]<=1.
   */
  void replaceHue(num src, num dst) {
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

  /**
   * Inverts the colors of the image.
   */
  void invert() {
    var data = _context.getImageData(0, 0, _canvas.width, _canvas.height);
    var pixels = data.data;

    for(var i = 0, len = pixels.length; i < len; i += 4) {
      pixels[i + 0] = 255 - pixels[i + 0];
      pixels[i + 1] = 255 - pixels[i + 1];
      pixels[i + 2] = 255 - pixels[i + 2];
    }

    _context.putImageData(data, 0, 0);
  }

  /**
   * Creates a rect with rounded corners.
   */
  void roundRect(num x, num y, num width, num height, num radius, {String strokeStyle, String fillStyle}) {
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
    var oldFillStyle = _context.fillStyle;

    for(var i = 0; i < lines.length; i++) {
      var oy = (y + i * h * 0.6).toInt();
      var lingrad = _context.createLinearGradient(0, oy, 0, (oy + h * 0.6).toInt());

      for(var j = 0; j < gradient.length; j += 2) {
        lingrad.addColorStop(gradient[j], gradient[j + 1]);
      }
      _context..fillStyle = lingrad
              ..fillText(lines[i], x, oy);
    }
    _context.fillStyle = oldFillStyle;
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
      _context.fillText(line, x, oy);
    }
  }

  /**
   * Returns a [Rect] with the size of a given [text]. If [maxWidth]
   * is given, the [text] will be wrapped.
   */
  Rect textBoundaries(String text, [num maxWidth]) {
    var regexp = new RegExp(r"(\d+)");
    var h = int.parse(regexp.firstMatch(font).group(0)) * 2;
    List<String> lines = getLines(text, maxWidth);
    if (null == maxWidth) {
      maxWidth = _context.measureText(text).width;
    }
    return new Rect(0, 0, maxWidth, (lines.length * h * 0.6).toInt());
  }

  /**
   * Splits the [text] at [maxWidth] and returns a list of lines.
   */
  List<String> getLines(String text, [num maxWidth]) {
    var words = text.split(_whitespacePattern);

    var ox = 0;
    var oy = 0;

    var lines = new List<String>.from([""]);
    var spaceWidth = _context.measureText(" ").width;
    if (null != maxWidth) {
      maxWidth += spaceWidth;
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
    return lines;
  }

  /**
   * Creates a paper bag shaped path.
   */
  void paperBag(num x, num y, num width, num height, num blowX, num blowY, {String strokeStyle, String fillStyle}) {
    _context..beginPath()
      ..moveTo(x, y)
      ..quadraticCurveTo(x + width / 2, y + height * blowY, x + width, y)
      ..quadraticCurveTo(x + width - width * blowX, y + height / 2, x + width, y + height)
      ..quadraticCurveTo(x + width / 2, y + height - height * blowY, x, y + height)
      ..quadraticCurveTo(x + width * blowX, y + height / 2, x, y)
      ..closePath();
    strokeAndFill(strokeStyle: strokeStyle, fillStyle: fillStyle);
  }

  /**
   * Creates an expandable area with borders from [image].
   * [x], [y], [width], [height] are the values for the border.
   * [top], [right], [bottom], [left] are the boundaries of the border in the
   * [image].
   */
  void borderImage(var image, num x, num y, num width, num height, num top, num right, num bottom, num left, {bool fill: false, String fillStyle}) {
    _context
      /* top */
      ..drawImageScaledFromSource(image, left, 0, image.width - left - right, top, x + left, y, width - left - right, top)
      /* bottom */
      ..drawImageScaledFromSource(image, left, image.height - bottom, image.width - left - right, bottom, x + left, y + height - bottom, width - left - right, bottom)
      /* left */
      ..drawImageScaledFromSource(image, 0, top, left, image.height - bottom - top, x, y + top, left, height - bottom - top)
      /* right */
      ..drawImageScaledFromSource(image, image.width - right, top, right, image.height - bottom - top, x + width - right, y + top, right, height - bottom - top)
      /* top-left */
      ..drawImageScaledFromSource(image, 0, 0, left, top, x, y, left, top)
      /* top-right */
      ..drawImageScaledFromSource(image, image.width - right, 0, right, top, x + width - right, y, right, top)
      /* bottom-right */
      ..drawImageScaledFromSource(image, image.width - right, image.height - bottom, right, bottom, x + width - right, y + height - bottom, right, bottom)
      /* bottom-left */
      ..drawImageScaledFromSource(image, 0, image.height - bottom, left, bottom, x, y + height - bottom, left, bottom);

    if (null != fillStyle) {
      var oldFillStyle = _context.fillStyle;
      _context..fillStyle = fillStyle
              ..fillRect(x + left, y + top, width - left - right, height - top - bottom)
              ..fillStyle = oldFillStyle;
    } else if (fill) {
      _context.drawImageScaledFromSource(image, left, top, image.width - right - left, image.height - bottom - top, x + left, y + top, width - left - right, height - top - bottom);
    }
  }

  /**
   * Convolve an image using [matrix].
   * See <www.html5rocks.com/en/tutorials/canvas/imagefilters/>.
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
    var output = CqTools.createImageData(_canvas.width, _canvas.height);
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

  /**
   * Blurs an image.
   */
  void blur({num mix: 1}) => convolve([1, 1, 1, 1, 1, 1, 1, 1, 1], mix: mix, divide: 9);
  /**
   * Applies a gaussian blur to an image.
   */
  void gaussianBlur({num mix: 1}) => convolve([0.00000067, 0.00002292, 0.00019117, 0.00038771, 0.00019117, 0.00002292, 0.00000067,
                                               0.00002292, 0.00078633, 0.00655965, 0.01330373, 0.00655965, 0.00078633, 0.00002292,
                                               0.00019117, 0.00655965, 0.05472157, 0.11098164, 0.05472157, 0.00655965, 0.00019117,
                                               0.00038771, 0.01330373, 0.11098164, 0.22508352, 0.11098164, 0.01330373, 0.00038771,
                                               0.00019117, 0.00655965, 0.05472157, 0.11098164, 0.05472157, 0.00655965, 0.00019117,
                                               0.00002292, 0.00078633, 0.00655965, 0.01330373, 0.00655965, 0.00078633, 0.00002292,
                                               0.00000067, 0.00002292, 0.00019117, 0.00038771, 0.00019117, 0.00002292, 0.00000067], mix : mix);
  /**
   * Sharpens the image.
   */
  void sharpen({num mix: 1}) => convolve([0, -1, 0, -1, 5, -1, 0, -1, 0], mix : mix);
  /**
   * Pixels with a grayscale value beyond [threshold] will become transparent.
   */
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

  /**
   * Sepia filter.
   */
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

typedef void NewlineCallback(int x, int y);
