part of canvas_query;

typedef void StepCallback(num delta, num lastTick);
typedef void PositionCallback(Point pos);
typedef void MouseEventCallback(Point pos, {int button});
typedef void KeyCodeCallback(int keyCode);
typedef void SwipeEventCallback(String direction);
typedef void ImageCallback(ImageElement image);
typedef void ResizeCallback(int width, int height);

class CqFramework {
  CqWrapper cqWrapper;
  CqFramework._(this.cqWrapper);
  CanvasElement get canvas => cqWrapper.canvas;
  Point mousePosition(UIEvent e) => CqTools.mousePosition(e);
  bool get mobile => CqTools.mobile;

  void onStep(StepCallback callback, Duration interval) {
    var lastTick = window.performance.now();

    new Timer.periodic(interval, (_) {
      var delta = window.performance.now() - lastTick;
      lastTick = window.performance.now();
      callback(delta, lastTick);
    });
  }

  void onRender(StepCallback callback) {
    var lastTick = window.performance.now();

    step(_) {
      var delta = window.performance.now() - lastTick;
      lastTick = window.performance.now();
      window.animationFrame.then(step);
      callback(delta, lastTick);
    };

    window.animationFrame.then(step);
  }

  void onMouseMove(PositionCallback callback) {
    Stream<UIEvent> stream;
    if (mobile) {
      stream = canvas.onTouchMove;
    } else {
      stream = canvas.onMouseMove;
    }
    stream.listen((e) {
      callback(mousePosition(e));
    });
  }

  void onMouseDown(MouseEventCallback callback) {
    Stream<UIEvent> stream;
    if (mobile) {
      stream = canvas.onTouchStart;
    } else {
      stream = canvas.onMouseDown;
    }
    stream.listen((e) {
      e.preventDefault();
      callback(mousePosition(e), button: e.button);
    });
  }

  void onMouseUp(MouseEventCallback callback) {
    Stream<UIEvent> stream;
    if (mobile) {
      stream = canvas.onTouchEnd;
    } else {
      stream = canvas.onMouseUp;
    }
    stream.listen((e) {
      callback(mousePosition(e), button: e.button);
    });
  }


  void onSwipe(SwipeEventCallback callback, {num threshold: 35, num timeout: 350}) {
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
        callback(swipeDir);
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
  }

  void onKeyDown(KeyCodeCallback callback) {
    window.onKeyDown.listen((e) {
      callback(e.keyCode);
    });
  }

  void onKeyUp(KeyCodeCallback callback) {
    document.onKeyUp.listen((e) {
      callback(e.keyCode);
    });
  }

  void onResize(ResizeCallback callback) {
    window.onResize.listen((e) {
      callback(window.innerWidth, window.innerHeight);
    });

    callback(window.innerWidth, window.innerHeight);
  }

  void onDropImage(ImageCallback callback) {
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
