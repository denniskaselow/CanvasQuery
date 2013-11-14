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
    canvas = querySelector(selector);
  } else if (selector is ImageElement) {
    canvas = CqTools.createCanvas(selector);
  } else if (selector is CanvasQuery) {
    return selector;
  } else {
    canvas = selector;
  }
  return new CanvasQuery(canvas);
}

/**
 * Wrapper around [CanvasElement] and [CanvasRenderingContext2D] offering
 * additional functionality.
 */
class CanvasQuery extends Object with CanvasQueryMixin {
  CanvasRenderingContext2D get context2D => _context;
  /**
   * Wrap an existing [CanvasElement].
   */
  CanvasQuery(CanvasElement canvas) {
    _canvas = canvas;
    _context = canvas.context2D;
    _framework = new CqFramework._(this);
  }
  /**
   * Creates and wrap a [CanvasElement] covering the whole window. Resizing included.
   */
  CanvasQuery.forWindow() {
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
  CanvasQuery.query(String selector) : this(querySelector(selector));
  /**
   * Creates and wraps a [CanvasElement] with the given [width] and [height].
   */
  CanvasQuery.forSize(int width, int height) : this(new CanvasElement(width: width, height: height));
  /**
   * Creates and wraps a [CanvasElement] using the given image.
   */
  CanvasQuery.forImage(ImageElement img) : this(CqTools.createCanvas(img));
}
