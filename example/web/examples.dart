import 'dart:async';
import 'dart:html';
import 'dart:collection';

import 'package:canvas_query/canvas_query.dart';

var showcases = {'coloring': coloring, 'blending': blending,
                 'border': border, 'wrappedtext': wrappedText,
                 'masking': masking, 'convolve': convolve};

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
  image.src = 'ships.png';
}

void blending(DivElement parent) {
  ImageElement below, above;
  int count = 0;
  Future.wait([loadImage('below.png'), loadImage('above.png')]).then((images) {
    below = images[0];
    above = images[1];
    InputElement mixSlider = query("#mix");
    blendAll(mixSlider, below, above, parent);
    mixSlider.onChange.listen((_) {
      parent.queryAll("canvas").forEach((canvas) => canvas.remove());
      blendAll(mixSlider, below, above, parent);
    });
  });
}

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

void masking(DivElement parent) {
  ImageElement image, maskImg;
  int count = 0;
  Future.wait([loadImage('farminglpc.png'), loadImage('mask.png')]).then((images) {
    image = images[0];
    maskImg = images[1];
    parent..append(image)
          ..appendText('+')
          ..append(maskImg)
          ..appendHtml('<br />=<br />');
    var cqMaskImg = cq(maskImg);
    List<int> grayscaleMask = cqMaskImg.grayscaleToMask();
    List<int> colorMask = cqMaskImg.colorToMask('#000000');
    cq(image)..applyMask(grayscaleMask)
             ..canvas.title = '''
List<int> grayscaleMask = cq(maskImg).grayscaleToMask();\n
cq(image).applyMask(grayscaleMask)'''
             ..appendTo(parent);
    cq(image)..applyMask(colorMask)
             ..canvas.title = '''
List<int> colorMask = cq(maskImg).colorToMask('#000000');\n
cq(image).applyMask(colorMask)'''
             ..appendTo(parent);
  });
}

void convolve(DivElement parent) {
  var image = new ImageElement();
  image.onLoad.listen((e) {
    cq(image)..canvas.classes.add('example')
             ..canvas.title = 'This is the source image'
             ..appendTo(parent);
    parent.appendHtml('<br />');
    cq(image)..canvas.classes.add('example')
             ..blur()
             ..canvas.title = '.blur()'
             ..appendTo(parent);
    cq(image)..canvas.classes.add('example')
             ..sharpen()
             ..canvas.title = '.sharpen()'
             ..appendTo(parent);
    cq(image)..canvas.classes.add('example')
             ..convolve([0, 1, 0, 1, -4, 1, 0, 1, 0])
             ..canvas.title = '.convolve([0, 1, 0, 1, -4, 1, 0, 1, 0])'
             ..appendTo(parent);
    cq(image)..canvas.classes.add('example')
             ..convolve([1/2])
             ..canvas.title = '.convolve([1/2])'
             ..appendTo(parent);
    cq(image)..canvas.classes.add('example')
             ..convolve([2])
             ..canvas.title = '.convolve([2])'
             ..appendTo(parent);
    cq(image)..canvas.classes.add('example')
             ..convolve([1/2, 2, 1/9, 2, 1/9, -2, 1/9, -2, -1/2])
             ..canvas.title = '.convolve([1/2, 2, 1/9, 2, 1/9, -2, 1/9, -2, -1/2])'
             ..appendTo(parent);
  });
  image.src = 'farminglpc.png';
}

void wrappedText(DivElement parent) {
  cq(300, 300)..font = '16px Verdana'
              ..wrappedText('''Lorem ipsum dolor sit amet, consectetur adipiscing 
elit. In elementum sapien ac turpis tempus pellentesque. Nulla non tellus purus, 
in iaculis tortor. Integer facilisis varius nibh, sit amet tempus nunc hendrerit 
non. Maecenas arcu ante, semper eget venenatis eu, commodo sed purus. Vivamus a 
mi nunc, sed vestibulum lacus.''', 20, 40, 260)
              ..strokeRect(10, 10, 280, 280)
              ..canvas.title = '.wrappedText(\'...\', 20, 40, 260);'
              ..appendTo(parent);
}



void updateHsl(ImageElement image, InputElement hueSlider, InputElement saturationSlider, InputElement lightnessSlider, CanvasQuery current) {
  var hue = hueSlider.value;
  var sat = saturationSlider.value;
  var light = lightnessSlider.value;
  var next = cq(image)..shiftHsl(hue: double.parse(hue),
                                  saturation: double.parse(sat),
                                  lightness: double.parse(light))
                      ..canvas.title = '.shiftHsl(hue: $hue, saturation: $sat, lightness: $light);'
                      ..canvas.classes.add('example');
  current.replaceWith(next);
}

void blendAll(InputElement mixSlider, ImageElement below, ImageElement above, DivElement parent) {
  mixSlider.disabled = true;
  double mix = double.parse(mixSlider.value);
  for (String functionName in blendFunction.keys) {
    exampleBlend(below, above, functionName, mix, parent);
  }
  for (String functionName in specialBlendFunction.keys) {
    exampleBlendSpecial(below, above, functionName, mix, parent);
  }
  mixSlider.disabled = false;
}

void exampleBlend(below, above, String functionName, num mix, DivElement parent) {
  var function = blendFunction[functionName];
  cq(below)..blend(above, function, mix)
           ..appendTo(parent)
           ..canvas.title = '.blend(above, Blend.$functionName, $mix);'
           ..canvas.classes.add('example');
}

void exampleBlendSpecial(below, above, String functionName, num mix, DivElement parent) {
  var function = specialBlendFunction[functionName];
  cq(below)..blendSpecial(above, function, mix)
           ..appendTo(parent)
           ..canvas.title = '.blendSpecial(above, Blend.$functionName, $mix);'
           ..canvas.classes.add('example');
}

Future<ImageElement> loadImage(String src) {
  var image = new ImageElement();
  image.src = src;
  var completer = new Completer<ImageElement>();
  image.onLoad.listen((e) => completer.complete(image));
  return completer.future;
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