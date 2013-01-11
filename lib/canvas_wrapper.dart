library canvas_wrapper;

import 'dart:html';

import 'package:canvas_tools/canvas_tools.dart';


class CanvasWrapper implements CanvasElement {
  final CanvasElement _canvas;
  CanvasElement get canvas => _canvas;
  CanvasWrapper(this._canvas);
  CanvasWrapper.forWindow() : _canvas = new CanvasElement(width: window.innerWidth, height: window.innerHeight) {
    window.on.resize.add((e) {
      _canvas.width = window.innerWidth;
      _canvas.height = window.innerHeight;
    });
  }
  CanvasWrapper.query(String selector) : _canvas = query(selector);
  CanvasWrapper.forSize(int width, int height) : _canvas = new CanvasElement(width: width, height: height);
  CanvasWrapper.forImage(ImageElement img) : _canvas = CanvasTools.createCanvas(img);

  dynamic noSuchMethod(InvocationMirror im) {
    im.invokeOn(_canvas);
  }
}
