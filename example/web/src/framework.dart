part of examples;

var colors = ['red', 'blue', 'yellow', 'green', 'black', 'white'];

void framework(DivElement parent) {
  var defaultWidth = 500;
  var defaultHeight = 300;
  var draw = false;
  var currentColor = 0;
  Point pos;
  var buffer = cq(defaultWidth, defaultHeight);
  var display = cq(defaultWidth, defaultHeight);
  display..canvas.style.backgroundColor = 'white'
         ..appendTo(parent);
  var framework = display.framework;
  framework.onMouseMove.listen((position) => pos = position);
  framework.onRender.listen((_) {
    if (null != pos) {
      if (draw) {
        buffer..circle(pos.x, pos.y, 15)
              ..fillStyle = colors[currentColor]
              ..fill();
      }
      display..clear(color: 'white')
             ..globalAlpha = 1
             ..drawImage(buffer.canvas, 0, 0)
             ..globalAlpha = 0.2
             ..circle(pos.x, pos.y, 15)
             ..fillStyle = colors[currentColor]
             ..fill();
    }
  });
  framework.onMouseDown.listen((e) {
    if (0 == e.button) {
      draw = true;
    }
  });
  framework.onMouseUp.listen((e) {
    if (0 == e.button) {
      draw = false;
    }
  });
  framework.onKeyDown.listen((keyCode) {
    if (keyCode == KeyCode.LEFT) {
      currentColor = (currentColor - 1) % colors.length;
    } else if (keyCode == KeyCode.RIGHT) {
      currentColor = (currentColor + 1) % colors.length;
    }
  });
  framework.onDropImage.listen((image) {
    buffer.canvas..width = image.width
                 ..height = image.height;
    display.canvas..width = image.width
                  ..height = image.height;
    buffer.drawImage(image, 0, 0);
  }).onError((error) => window.alert(error.error));
  framework.onSwipe().listen((direction) {
    if (direction == 'down' && colors[currentColor] == 'white') {
      buffer.canvas..width = defaultWidth
                   ..height = defaultHeight;
      display.canvas..width = defaultWidth
                    ..height = defaultHeight;
      buffer.clear();
    }
  });
}