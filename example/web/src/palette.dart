part of examples;

var dawnpaletteCq;
var nespaletteCq;

void palette(DivElement parent) {
  Future.wait([loadImage('dawnbringerspalette.png'), loadImage('nespalette.png'), loadImage('farminglpc.png')]).then((images) {
    var dawnpaletteImg = images[0];
    var nespaletteImg = images[1];
    var image = images[2];
    var dawnpalette = cq(dawnpaletteImg).getPalette();
    var nespalette = cq(nespaletteImg).getPalette();
    dawnpaletteCq = cq(dawnpaletteImg)..resizePixel(16);
    nespaletteCq = cq(nespaletteImg)..resizePixel(8);
    cq(image)..appendTo(parent);
    cq(image)..matchPalette(dawnpalette)
             ..canvas.onMouseMove.listen(showDawnPalette)
             ..canvas.onMouseOut.listen(hidePalette)
             ..appendTo(parent);
    cq(image)..matchPalette(nespalette)
             ..canvas.onMouseMove.listen(showNesPalette)
             ..canvas.onMouseOut.listen(hidePalette)
             ..appendTo(parent);
  });
}

void showDawnPalette(MouseEvent e) {
  showPalette(e, dawnpaletteCq.canvas);
}

void showNesPalette(MouseEvent e) {
  showPalette(e, nespaletteCq.canvas);
}

void showPalette(MouseEvent e, CanvasElement palette) {
  int x = e.client.x;
  int y = e.client.y;
  DivElement div = query('#tooltip');
  var canvas = div.query('canvas');
  if (null == canvas || canvas != palette) {
    if (null != canvas) {
      canvas.remove();
    }
    div.append(palette);
  }
  div..style.display = 'block'
     ..style.top = '${y}px'
     ..style.left = '${x}px'
     ..append(palette);
}

void hidePalette(MouseEvent e) {
  query('#tooltip').style.display = 'none';
}