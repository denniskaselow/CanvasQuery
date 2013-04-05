part of examples;

var dawnpaletteCq;
var nespaletteCq;

var paletteData = {'dawnbringer': {'name': 'Dawnbringer', 'res': 'dawnbringerpalette.png', 'url': 'http://www.pixeljoint.com/forum/forum_posts.asp?TID=12795'},
               'nes': {'name': 'NES', 'res': 'nespalette.png', 'url': 'http://en.wikipedia.org/wiki/File:NES_palette.png'},
               'pal': {'name': 'PAL', 'res': 'palpalette.png', 'url': 'http://en.wikipedia.org/wiki/File:Atari2600_PAL_palette.png'},
               'sega': {'name': 'SEGA', 'res': 'mastersystempalette.png', 'url': 'http://en.wikipedia.org/wiki/File:RGB_6bits_palette.png'}};

var imageData = {'dawnbringer' : {'name': 'Dawnbringer', 'res': 'dawnbringermockup.png', 'url': 'http://www.pixeljoint.com/forum/forum_posts.asp?TID=12795'},
                 'farming': {'name': 'Farming', 'res': 'farminglpc.png', 'url': 'http://opengameart.org/content/farming-tilesets-magic-animations-and-ui-elements'}};

void palette(DivElement parent) {
  SelectElement paletteSelect = query('#paletteselect');
  SelectElement imageSelect = query('#imageselect');
  paletteSelect.append(new OptionElement('None', '', true, true));

  var loader = new List<Future<ImageElement>>();
  loader.addAll(initDropdown(paletteSelect, paletteData));
  loader.addAll(initDropdown(imageSelect, imageData));

  Future.wait(loader).then((_) {
    var paletteInfo = new DivElement();
    var link = new AnchorElement();
    paletteInfo..classes.add('credits')
               ..appendText('Palette: ')
               ..append(link);

    var currentCq = cq(imageData[imageSelect.value]['img']);
    currentCq..appendTo(parent);

    void updateExample(_) {
      var palleteSelection = paletteSelect.value;
      var selectedImage = imageData[imageSelect.value]['img'];
      var nextCq = cq(selectedImage);
      if ("" == palleteSelection) {
        currentCq.replaceWith(nextCq);
        paletteInfo.remove();
      } else {
        var palette = cq(paletteData[palleteSelection]['img']).getPalette();
        paletteInfo.style.width = '${selectedImage.width}px';
        currentCq.replaceWith(nextCq..matchPalette(palette)..canvas.title = '.matchPalette(palette)');
        link.href = paletteData[palleteSelection]['url'];
        link.text = '${paletteData[palleteSelection]['name']}';
        parent.append(paletteInfo);
      }
    }

    paletteSelect.onChange.listen(updateExample);
    imageSelect.onChange.listen(updateExample);
  });

}

initDropdown(SelectElement dropdown, Map<String, Map<String, dynamic>> data) {
  var futures = new List<Future<ImageElement>>();
  data.forEach((key, item) {
    var completer = new Completer();
    futures.add(completer.future);
    loadImage(item['res']).then((image) {
      item['img'] = image;
      dropdown.append(new OptionElement(item['name'], key, false, false));
      completer.complete(image);
    });
  });
  return futures;
}