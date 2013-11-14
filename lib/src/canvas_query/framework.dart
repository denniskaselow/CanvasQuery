part of canvas_query;

/**
 * A simple framework for easy access to events created by the canvas.
 */
class CqFramework {
  /// The [CanvasQuery] of this object.
  final CanvasQuery cq;
  CqFramework._(this.cq);
  CanvasElement get _canvas => cq.canvas;
  Point _mousePosition(UIEvent e) => CqTools.mousePosition(e);
  bool get _mobile => CqTools.mobile;

  /**
   * Fires a [CqStepEvent] every time [interval] has passed.
   *
   * Can be used for game logic. Will fire new events even if the browser
   * tab is inactive.
   */
  Stream<CqStepEvent> onStep(Duration interval) {
    var controller = new StreamController<CqStepEvent>();
    var lastTick = window.performance.now();

    new Timer.periodic(interval, (_) {
      var delta = window.performance.now() - lastTick;
      lastTick = window.performance.now();
      controller.add(new CqStepEvent(delta, lastTick));
    });
    return controller.stream;
  }

  /**
   * Fires a [CqStepEvent] when `window.animationFrame`'s future executes.
   *
   * Can be used for rendering. Will not fire events while the browser tab is
   * inactive.
   */
  Stream<CqStepEvent> get onRender {
    var controller = new StreamController<CqStepEvent>();
    var lastTick = window.performance.now();

    step(_) {
      var delta = window.performance.now() - lastTick;
      lastTick = window.performance.now();
      window.animationFrame.then(step);
      controller.add(new CqStepEvent(delta, lastTick));
    };

    window.animationFrame.then(step);
    return controller.stream;
  }

  /**
   * Fires a [CqUiEvent] when an `onMouseMove` or an `onTouchMove` event
   * is fired.
   */
  Stream<Point> get onMouseMove {
    Stream<UIEvent> stream;
    if (_mobile) {
      stream = _canvas.onTouchMove;
    } else {
      stream = _canvas.onMouseMove;
    }
    return stream.map((e) => _mousePosition(e));
  }

  /**
   * Fires a [CqUiEvent] when an `onMouseDown` or an `onTouchSouch` event
   * is fired.
   */
  Stream<CqUiEvent> get onMouseDown {
    var controller = new StreamController<CqUiEvent>();
    Stream<UIEvent> stream;
    if (_mobile) {
      stream = _canvas.onTouchStart;
    } else {
      stream = _canvas.onMouseDown;
    }
    stream.listen((UIEvent e) {
      e.preventDefault();
      controller.add(new CqUiEvent(_mousePosition(e), e.which));
    });
    return controller.stream;
  }

  /**
   * Fires a [CqUiEvent] when an `onMouseUp` or an `onTouchEnd` event
   * is fired.
   */
  Stream<CqUiEvent> get onMouseUp {
    Stream<UIEvent> stream;
    if (_mobile) {
      stream = _canvas.onTouchEnd;
    } else {
      stream = _canvas.onMouseUp;
    }
    return stream.map((e) => new CqUiEvent(_mousePosition(e), e.which));
  }

  /**
   * Returns a [Stream] of swipe direction.
   */
  Stream<String> onSwipe({num threshold: 35, num timeout: 350}) {
    var controller = new StreamController<String>();
    Point swipeSP;
    var swipeST = 0;
    Point swipeEP;
    var swipeET = 0;

    swipeStart(e) {
      e.preventDefault();
      swipeSP = _mousePosition(e);
      swipeST = window.performance.now();
    }

    swipeUpdate(e) {
      e.preventDefault();
      swipeEP = _mousePosition(e);
      swipeET = window.performance.now();
    }

    swipeEnd(e) {
      e.preventDefault();

      var xDif = (swipeSP.x - swipeEP.x);
      var yDif = (swipeSP.y - swipeEP.y);
      var x = (xDif * xDif);
      var y = (yDif * yDif);
      var swipeDist = sqrt(x + y);
      var swipeTime = (swipeET - swipeST);
      var swipeDir = null;

      if(swipeDist > threshold && swipeTime < timeout) {
        if(xDif.abs() > yDif.abs()) {
          if(xDif > 0) {
            swipeDir = "left";
          } else {
            swipeDir = "right";
          }
        } else {
          if(yDif > 0) {
            swipeDir = "up";
          } else {
            swipeDir = "down";
          }
        }
        controller.add(swipeDir);
      }
    }
    if (_mobile) {
      _canvas.onTouchStart.listen((e) => swipeStart(e));
      _canvas.onTouchMove.listen((e) => swipeUpdate(e));
      _canvas.onTouchEnd.listen((e) => swipeEnd(e));
    } else {
      _canvas.onMouseDown.listen((e) => swipeStart(e));
      _canvas.onMouseMove.listen((e) => swipeUpdate(e));
      _canvas.onMouseUp.listen((e) => swipeEnd(e));
    }
    return controller.stream;
  }

  /**
   * Returns a stream of [KeyCode].
   */
  Stream<int> get onKeyDown => document.onKeyDown.map((e) => e.keyCode);
  /**
   * Returns a stream of [KeyCode].
   */
  Stream<int> get onKeyUp => document.onKeyUp.map((e) => e.keyCode);
  /**
   * Returns a Stream of [Rectangle] for the new size of the window.
   */
  Stream<Rectangle> get onResize => window.onResize.map((_) => new Rectangle(0, 0, window.innerWidth, window.innerHeight));
  /**
   * Returns a [Stream} of dropped [ImageElement].
   */
  Stream<ImageElement> get onDropImage {
    var controller = new StreamController<ImageElement>();
    document.onDrop.listen((MouseEvent e) {
      e.stopPropagation();
      e.preventDefault();

      var file = e.dataTransfer.files[0];

      if (!file.type.startsWith('image/')) {
        controller.addError('unexpected filetype, "${file.name}" is not an image');
        return;
      }
      var reader = new FileReader();

      reader.onLoad.listen((ProgressEvent pe) {
        var image = new ImageElement();

        image.onLoad.listen((e3) {
          controller.add(image);
        });

        image.src = reader.result;
      });

      reader.readAsDataUrl(file);

    });

    document.onDragOver.listen((e) {
      e.preventDefault();
    });
    return controller.stream;
  }
}

/**
 * Event that is produced by some of the Streams in [CqFramework] with basic
 * information about a mouse event.
 */
class CqUiEvent {
  /// Position of the mouse when the event was triggered.
  final Point position;
  /// Button that was used when the event was triggered.
  final int which;
  CqUiEvent(this.position, this.which);
}

/**
 * Event that is produced by some of the Streams in [CqFramework] with timing
 * data.
 */
class CqStepEvent {
  /// Milliseconds since the last [CqStepEvent].
  final double delta;
  /// Tick of the current [CqStepEvent].
  final double lastTick;
  CqStepEvent(this.delta, this.lastTick);
}