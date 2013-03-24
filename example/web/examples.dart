import 'dart:async';
import 'dart:html';
import 'dart:collection';

import 'package:canvas_query/canvas_query.dart';

var showcases = {'coloring': coloring, 'blending': blending, 'border': border};

void main() {

  window.setImmediate(() {
    showcases.forEach((key, value) => showShowcase(key, value));
  });
}

void showShowcase(String showcase, Function showcaseFunction) {
  Element navEntry = query("#show_$showcase");
  navEntry.onClick.listen((_) {
    showcases.keys.forEach((section) {
      query("#$section").style.display = 'none';
      query("#show_$section").classes.remove('highlight');
    });
    var parent = query("div#$showcase");
    parent.style.display = 'block';
    navEntry.classes.add('highlight');
    if ('true' != parent.dataset['init']) {
      showcaseFunction(parent);
      parent.dataset['init'] = 'true';
    }
  });
}

void coloring(DivElement parent) {
  var image = new ImageElement();
  image.src = 'ships.png';
  image.onLoad.listen((e) {
    var current = cq(image)..canvas.classes.add('example');
    current.appendTo(parent);

    InputElement hueSlider = query("#hue");
    InputElement saturationSlider = query("#saturation");
    InputElement lightnessSlider = query("#lightness");
    hueSlider.onChange.listen((_) =>  updateHsl(image, hueSlider, saturationSlider, lightnessSlider, current));
    saturationSlider.onChange.listen((_) => updateHsl(image, hueSlider, saturationSlider, lightnessSlider, current));
    lightnessSlider.onChange.listen((_) => updateHsl(image, hueSlider, saturationSlider, lightnessSlider, current));
  });
}

void updateHsl(ImageElement image, InputElement hueSlider, InputElement saturationSlider, InputElement lightnessSlider, CanvasQuery current) {
  var hue = hueSlider.value;
  var sat = saturationSlider.value;
  var light = lightnessSlider.value;
  var next = cq(image)..shiftHsl(hue: double.parse(hue),
                    saturation: double.parse(sat),
                    lightness: double.parse(light))
                      ..canvas.title = 'cq.shiftHsl(hue: $hue, saturation: $sat, lightness: $light);'
                      ..canvas.classes.add('example');
  current.replaceWith(next);
  current = next;
}

void blending(DivElement parent) {
  ImageElement below, above;
  Future.wait([loadImage('below.png'), loadImage('above.png')]).then((images) {
    below = images[0];
    above = images[1];
    blendAll(below, above, 0.5, parent);
  });
}

void blendAll(below, above, mix, DivElement parent) {
  parent.children.forEach((child) => null == child ? null : child.remove());
  for (String functionName in blendFunction.keys) {
    exampleBlend(below, above, functionName, mix, parent);
  }
  for (String functionName in specialBlendFunction.keys) {
    exampleBlendSpecial(below, above, functionName, mix, parent);
  }
}

void exampleBlend(below, above, functionName, mix, DivElement parent) {
  var function = blendFunction[functionName];
  cq(below)..blend(above, function, mix)
           ..appendTo(parent)
           ..canvas.title = 'cq.blend(above, Blend.$functionName, $mix);'
           ..canvas.classes.add('example');
}

void exampleBlendSpecial(below, above, functionName, mix, parent) {
  var function = specialBlendFunction[functionName];
  cq(below)..blendSpecial(above, function, mix)
           ..appendTo(parent)
           ..canvas.title = 'cq.blendSpecial(above, Blend.$functionName, $mix);'
           ..canvas.classes.add('example');
}

Future<ImageElement> loadImage(String src) {
  var image = new ImageElement();
  image.src = src;
  var completer = new Completer<ImageElement>();
  image.onLoad.listen((e) => completer.complete(image));
  return completer.future;
}

void border(DivElement parent) {
  var image = new ImageElement();
  image.src = 'border.png';
  image.onLoad.listen((e) {
    parent..append(image)
          ..appendHtml("<br />can be turned into<br />");
    cq(300, 150)..borderImage(image, 0, 0, 300, 150, 6, 6, 6, 6, fillColor: 'red')
                ..borderImage(image, 15, 15, 240, 50, 6, 6, 6, 6, fillColor: 'green')
                ..borderImage(image, 15, 75, 240, 50, 6, 6, 6, 6, fillColor: 'blue')
                ..borderImage(image, 270, 15, 20, 110, 6, 6, 6, 6, fill: true)
                ..appendTo(parent)
                ..canvas.title = '''
cq..borderImage(image, 0, 0, 100, 100, 6, 6, 6, 6, fillColor: 'grey')
  ..borderImage(image, 15, 15, 240, 50, 6, 6, 6, 6, fillColor: 'green')
  ..borderImage(image, 15, 75, 240, 50, 6, 6, 6, 6, fillColor: 'blue')
  ..borderImage(image, 270, 15, 20, 110, 6, 6, 6, 6, fill: true);
''';
  });
}

var blendFunction = {
  'normal':Blend.normal,
  'overlay': Blend.overlay,
  'hardLight': Blend.hardLight,
  'softLight': Blend.softLight,
  'dodge': Blend.dodge,
  'burn': Blend.burn,
  'multiply': Blend.multiply,
  'divide': Blend.divide,
  'screen': Blend.screen,
  'grainExtract': Blend.grainExtract,
  'grainMerge': Blend.grainMerge,
  'difference': Blend.difference,
  'addition': Blend.addition,
  'substract': Blend.substract,
  'darkenOnly': Blend.darkenOnly,
  'lightenOnly': Blend.lightenOnly
};

var specialBlendFunction = {
  'color': Blend.color,
  'hue': Blend.hue,
  'value': Blend.value,
  'saturation': Blend.saturation
};