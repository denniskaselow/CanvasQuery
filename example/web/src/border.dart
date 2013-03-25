part of examples;

void border(DivElement parent) {
  parent..appendHtml("using roundRect:<br />");
  cq(300, 150)..roundRect(10, 10, 280, 130, 50)
              ..lineWidth = 3
              ..strokeStyle = 'red'
              ..stroke()
              ..fillStyle = 'blue'
              ..fill()
              ..canvas.title = '.roundRect(10, 10, 280, 130, 50)'
              ..appendTo(parent);
  var image = new ImageElement();
  image.src = 'border.png';
  image.onLoad.listen((e) {
    parent..appendHtml("<br />using borderImage:<br />")
          ..append(image)
          ..appendHtml("<br />can be turned into<br />");
    cq(300, 150)..borderImage(image, 0, 0, 300, 150, 6, 6, 6, 6, fillColor: 'red')
                ..borderImage(image, 15, 15, 240, 50, 6, 6, 6, 6, fillColor: 'green')
                ..borderImage(image, 15, 75, 240, 50, 6, 6, 6, 6, fillColor: 'blue')
                ..borderImage(image, 270, 15, 20, 110, 6, 6, 6, 6, fill: true)
                ..appendTo(parent)
                ..canvas.title = '''
..borderImage(image, 0, 0, 100, 100, 6, 6, 6, 6, fillColor: 'grey')
..borderImage(image, 15, 15, 240, 50, 6, 6, 6, 6, fillColor: 'green')
..borderImage(image, 15, 75, 240, 50, 6, 6, 6, 6, fillColor: 'blue')
..borderImage(image, 270, 15, 20, 110, 6, 6, 6, 6, fill: true);
''';
  });
}