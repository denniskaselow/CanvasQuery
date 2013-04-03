part of examples;

var colors = ['red', 'blue', 'yellow', 'green', 'black', 'white'];

void framework(DivElement parent) {
  var defaultWidth = 500;
  var defaultHeight = 300;
  var buffer = cq(defaultWidth, defaultHeight);
  var display = cq(defaultWidth, defaultHeight);
  var draw = false;
  var currentColor = 0;
  display..canvas.style.backgroundColor = 'white'
         ..appendTo(parent);
  var framework = display.framework;
  Point pos;
  framework.onMouseMove((position) => pos = position);
  framework.onRender((delta, lastTick) {
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
  framework.onMouseDown((_, {button}) {
    if (0 == button) {
      draw = true;
    }
  });
  framework.onMouseUp((_, {button}) {
    if (0 == button) {
      draw = false;
    }
  });
  framework.onKeyDown((keyCode) {
    if (keyCode == KeyCode.LEFT) {
      currentColor = (currentColor - 1) % colors.length;
    } else if (keyCode == KeyCode.RIGHT) {
      currentColor = (currentColor + 1) % colors.length;
    }
  });
  framework.onDropImage((image) {
    buffer.canvas..width = image.width
                 ..height = image.height;
    display.canvas..width = image.width
                  ..height = image.height;
    buffer.drawImage(image, 0, 0);
  });
  framework.onSwipe((direction) {
    if (direction == 'down' && colors[currentColor] == 'white') {
      buffer.canvas..width = defaultWidth
                   ..height = defaultHeight;
      display.canvas..width = defaultWidth
                    ..height = defaultHeight;
      buffer.clear();
    }
  });
}