part of canvas_query;

class CqFramework {
  CqWrapper cqWrapper;
  CqFramework._(this.cqWrapper);
  CanvasElement get canvas => cqWrapper.canvas;
  Point mousePosition(UIEvent e) => CqTools.mousePosition(e);
  bool get mobile => CqTools.mobile;

  Stream<CqStep> onStep(Duration interval) {
    var controller = new StreamController<CqStep>();
    var lastTick = window.performance.now();

    new Timer.periodic(interval, (_) {
      var delta = window.performance.now() - lastTick;
      lastTick = window.performance.now();
      controller.add(new CqStep(delta, lastTick));
    });
    return controller.stream;
  }

  Stream<CqStep> get onRender {
    var controller = new StreamController<CqStep>();
    var lastTick = window.performance.now();

    step(_) {
      var delta = window.performance.now() - lastTick;
      lastTick = window.performance.now();
      window.animationFrame.then(step);
      controller.add(new CqStep(delta, lastTick));
    };

    window.animationFrame.then(step);
    return controller.stream;
  }

  Stream<Point> get onMouseMove {
    Stream<UIEvent> stream;
    if (mobile) {
      stream = canvas.onTouchMove;
    } else {
      stream = canvas.onMouseMove;
    }
    return stream.map((e) => mousePosition(e));
  }

  Stream<CqMouseEvent> get onMouseDown {
    var controller = new StreamController<CqMouseEvent>();
    Stream<UIEvent> stream;
    if (mobile) {
      stream = canvas.onTouchStart;
    } else {
      stream = canvas.onMouseDown;
    }
    stream.listen((e) {
      e.preventDefault();
      controller.add(new CqMouseEvent(mousePosition(e), e.button));
    });
    return controller.stream;
  }

  Stream<CqMouseEvent> get onMouseUp {
    Stream<UIEvent> stream;
    if (mobile) {
      stream = canvas.onTouchEnd;
    } else {
      stream = canvas.onMouseUp;
    }
    return stream.map((e) => new CqMouseEvent(mousePosition(e), e.button));
  }

  /** Returns a [Stream] of swipe direction. */
  Stream<String> onSwipe({num threshold: 35, num timeout: 350}) {
    var controller = new StreamController<String>();
    var swipeSP = 0;
    var swipeST = 0;
    var swipeEP = 0;
    var swipeET = 0;

    swipeStart(e) {
      e.preventDefault();
      swipeSP = mousePosition(e);
      swipeST = window.performance.now();
    }

    swipeUpdate(e) {
      e.preventDefault();
      swipeEP = mousePosition(e);
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
    if (mobile) {
      canvas.onTouchStart.listen((e) => swipeStart(e));
      canvas.onTouchMove.listen((e) => swipeUpdate(e));
      canvas.onTouchEnd.listen((e) => swipeEnd(e));
    } else {
      canvas.onMouseDown.listen((e) => swipeStart(e));
      canvas.onMouseMove.listen((e) => swipeUpdate(e));
      canvas.onMouseUp.listen((e) => swipeEnd(e));
    }
    return controller.stream;
  }

  /** Returns a stream of [KeyCode]. */
  Stream<int> get onKeyDown => document.onKeyDown.map((e) => e.keyCode);
  /** Returns a stream of [KeyCode]. */
  Stream<int> get onKeyUp => document.onKeyUp.map((e) => e.keyCode);
  /** Returns a Stream of [Rect] for the new size of the window. */
  Stream<Rect> get onResize => window.onResize.map((_) => new Rect(0, 0, window.innerWidth, window.innerHeight));
  /** Returns a [Stream} of dropped [ImageElement]. */
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

class CqMouseEvent {
  final Point position;
  final int button;
  CqMouseEvent(this.position, this.button);
}

class CqStep {
  final double delta, lastTick;
  CqStep(this.delta, this.lastTick);
}