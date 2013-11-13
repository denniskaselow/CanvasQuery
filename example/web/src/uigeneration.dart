part of examples;

void uigeneration(DivElement parent) {
  var ui = cq(500, 300);
  ui..appendTo(parent)
    ..textBaseline = "top"
    ..lineWidth = 5
    ..strokeStyle = 'black'
    ..fillStyle = 'black'
    ..font = '16px Verdana';

  var uitext = querySelector('textarea#uitext');
  var text;
  text = uitext.value;
  uitext.onKeyUp.listen((data) {
    text = uitext.value;
  });

  var startGameText = 'START GAME';
  var instructionsText = 'INSTRUCTIONS';
  var border = 6;
  var maxWidth = 400;
  var buttonWidth = 300;
  var buttonHeight = 40;
  var sgButtonRect = new Rectangle(100, 20, buttonWidth, buttonHeight);
  var instrButtonRect = new Rectangle(100, 70, buttonWidth, buttonHeight);
  var sgSize = ui.textBoundaries(startGameText);
  var instrSize = ui.textBoundaries(instructionsText);
  var showSelection = false;
  var ySelection = null;
  loadImage('border.png').then((image) {
    ui.framework.onRender.listen((step) {
      var dynSize = ui.textBoundaries(text, maxWidth);
      ui..clear()
        ..roundRect(5, 5, 490, 290, 20, strokeStyle: "#080D73", fillStyle: '#A69500')
        ..borderImage(image, 100, 20, buttonWidth, buttonHeight, border, border, border, border, fillStyle: ySelection == 20 ? '#FFE500' : '#FFF173')
        ..borderImage(image, 100, 70, buttonWidth, buttonHeight, border, border, border, border, fillStyle: ySelection == 70 ? '#FFE500' : '#FFF173')
        ..borderImage(image, 50, 120, 2*border + dynSize.width, 2*border + dynSize.height, border, border, border, border, fillStyle: '#BFB030')
        ..gradientText(startGameText, 100 + (buttonWidth - sgSize.width)~/2, 20 + (buttonHeight - sgSize.height)~/2, [0, 'blue', 1, 'red'])
        ..gradientText(instructionsText, 100 + (buttonWidth - instrSize.width)~/2, 70 + (buttonHeight - instrSize.height)~/2, [0, 'red', 0.5, 'green', 1, 'blue'])
        ..wrappedText(text, 50 + border, 120 + border, maxWidth)
        ;
      if (showSelection) {
        ui..paperBag(40, ySelection, 40, 40, 0.7 * sin(step.lastTick/200), 0.5 * sin(step.lastTick/200).abs(), fillStyle: '#FFAA40')
          ..paperBag(420, ySelection, 40, 40, 0.7 * sin(step.lastTick/200), 0.5 * sin(step.lastTick/200).abs(), fillStyle: '#FFAA40');
      }
    });
    ui.framework.onMouseMove.listen((pos) {
      if (sgButtonRect.containsPoint(pos)) {
        showSelection = true;
        ySelection = 20;
      } else if (instrButtonRect.containsPoint(pos)) {
        showSelection = true;
        ySelection = 70;
      } else {
        showSelection = false;
        ySelection = null;
      }
    });
  });
}