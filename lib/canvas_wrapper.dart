library canvas_wrapper;

import 'dart:html';

import 'package:canvas_tools/canvas_tools.dart';

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

  void pixelize([int size = 4]) {
    var webkitImageSmoothingEnabled = _context.webkitImageSmoothingEnabled;
    _context.webkitImageSmoothingEnabled = false;

    var scale = (_canvas.width / size) / _canvas.width;
    var temp = new CanvasWrapper.forSize(_canvas.width, _canvas.height);

    temp._context.drawImage(_canvas, 0, 0, _canvas.width, _canvas.height, 0, 0, (_canvas.width * scale).toInt(), (_canvas.height * scale).toInt());
    clear();
    _context.drawImage(temp.canvas, 0, 0, (_canvas.width * scale).toInt(), (_canvas.height * scale).toInt(), 0, 0, _canvas.width, _canvas.height);

    _context.webkitImageSmoothingEnabled = webkitImageSmoothingEnabled;
  }

  void clear([String color]) {
    if(null != color) {
      _context.fillStyle = color;
      _context.fillRect(0, 0, this.canvas.width, this.canvas.height);
    } else {
      _context.clearRect(0, 0, this.canvas.width, this.canvas.height);
    }
  }

}
