part of examples;

var dawnpaletteCq;
var nespaletteCq;

var paletteData = {'dawnbringer': {'url': 'http://www.pixeljoint.com/forum/forum_posts.asp?TID=12795', 'factor': 16},
               'nes': {'url': 'http://en.wikipedia.org/wiki/File:NES_palette.png'}, 'factor': 8};

void palette(DivElement parent) {
  Future.wait([loadImage('dawnbringerpalette.png'), loadImage('nespalette.png'), loadImage('farminglpc.png')]).then((images) {
    paletteData['dawnbringer']['img'] = images[0];
    paletteData['nes']['img'] = images[1];
    var farmingImg = images[2];
    var farmingCq = cq(farmingImg);
    farmingCq..appendTo(parent);

    SelectElement select = query('#paletteselect');
    select.queryAll('option').forEach((option) {
      option.onMouseOver.listen((e) {
        showPalette(e, cq(paletteData[option.value]['img'])..resizePixel(paletteData[option.value]['factor']));
      });
    });
    select.onChange.listen((_) {
      var selection = select.value;
      if ("" == selection) {
        farmingCq.replaceWith(cq(farmingImg));
      } else {
        var palette = cq(paletteData[selection]['img']).getPalette();
        farmingCq.replaceWith(cq(farmingImg)..matchPalette(palette));
      }
    });

//    var dawnpalette = cq(dawnpaletteImg).getPalette();
//    var nespalette = cq(nespaletteImg).getPalette();
//    dawnpaletteCq = cq(dawnpaletteImg)..resizePixel(16);
//    nespaletteCq = cq(nespaletteImg)..resizePixel(8);
//    DivElement container = new DivElement();
//    container.style.width = '300px';
//    cq(image)..matchPalette(dawnpalette)
//             ..canvas.onMouseMove.listen(showDawnPalette)
//             ..canvas.onMouseOut.listen(hidePalette)
//             ..drawImage(dawnpaletteCq.canvas, 0, 0)
//             ..appendTo(container);
//    DivElement credits = new DivElement();
//    credits.classes.add('credits');
//    credits.appendHtml('''
//<a href="http://www.pixeljoint.com/forum/forum_posts.asp?TID=12795">DawnBringer's palette</a>
//''');
//    container.append(credits);
//    parent.append(container);
//    cq(image)..matchPalette(nespalette)
//             ..canvas.onMouseMove.listen(showNesPalette)
//             ..canvas.onMouseOut.listen(hidePalette)
//             ..drawImage(nespaletteCq.canvas, 0, 0)
//             ..appendTo(parent);
  });
}

void showDawnPalette(MouseEvent e) {
  showPalette(e, dawnpaletteCq.canvas);
}

void showNesPalette(MouseEvent e) {
  showPalette(e, nespaletteCq.canvas);
}

void showPalette(MouseEvent e, CanvasQuery palette) {
  int x = e.client.x;
  int y = e.client.y;
  DivElement div = query('#tooltip');
  var canvas = div.query('canvas');
  if (null == canvas || canvas != palette.canvas) {
    if (null != canvas) {
      canvas.remove();
    }
  }
  div..style.display = 'block'
     ..style.top = '${y}px'
     ..style.left = '${x}px'
     ..append(palette.canvas);
}

void hidePalette(MouseEvent e) {
  query('#tooltip').style.display = 'none';
}