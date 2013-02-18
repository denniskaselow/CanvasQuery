import 'dart:async';
import 'dart:html';

import 'package:canvas_query/canvas_query.dart';


void main() {
  window.setImmediate(() {
    coloring();
    blending();
  });
}

void coloring() {
  var image = new ImageElement();
  image.src = 'ships.png';
  image.onLoad.listen((e) {
    for (num i = 0; i < 0.99; i += 0.1) {
      CanvasQuery cq = new CanvasQuery.forImage(image);
      cq.shiftHsl(i, null, null);
      cq.appendTo(query("div#coloring"));
    }
  });
}

void blending() {
  ImageElement below, above;
  Future.wait([loadImage('below.png'), loadImage('above.png')]).then((images) {
    below = images[0];
    above = images[1];
    blendAll(below, above, 0.5);
  });
}

blendAll(below, above, mix) {
  var parent = query("div#blending");
  parent.children.forEach((child) => null == child ? null : child.remove());
  cq(below)..blend(above, BlendFunctions.normal, mix)..appendTo(parent);
  cq(below)..blend(above, BlendFunctions.overlay, mix)..appendTo(parent);
  cq(below)..blend(above, BlendFunctions.hardLight, mix)..appendTo(parent);
  cq(below)..blend(above, BlendFunctions.softLight, mix)..appendTo(parent);
  cq(below)..blend(above, BlendFunctions.dodge, mix)..appendTo(parent);
  cq(below)..blend(above, BlendFunctions.burn, mix)..appendTo(parent);
  cq(below)..blend(above, BlendFunctions.multiply, mix)..appendTo(parent);
  cq(below)..blend(above, BlendFunctions.divide, mix)..appendTo(parent);
  cq(below)..blend(above, BlendFunctions.screen, mix)..appendTo(parent);
  cq(below)..blend(above, BlendFunctions.grainExtract, mix)..appendTo(parent);
  cq(below)..blend(above, BlendFunctions.grainMerge, mix)..appendTo(parent);
  cq(below)..blend(above, BlendFunctions.difference, mix)..appendTo(parent);
  cq(below)..blend(above, BlendFunctions.addition, mix)..appendTo(parent);
  cq(below)..blend(above, BlendFunctions.substract, mix)..appendTo(parent);
  cq(below)..blend(above, BlendFunctions.darkenOnly, mix)..appendTo(parent);
  cq(below)..blend(above, BlendFunctions.lightenOnly, mix)..appendTo(parent);
  cq(below)..blendSpecial(above, SpecialBlendFunctions.color, mix)..appendTo(parent);
  cq(below)..blendSpecial(above, SpecialBlendFunctions.hue, mix)..appendTo(parent);
  cq(below)..blendSpecial(above, SpecialBlendFunctions.value, mix)..appendTo(parent);
  cq(below)..blendSpecial(above, SpecialBlendFunctions.saturation, mix)..appendTo(parent);
}

Future<ImageElement> loadImage(String src) {
  var image = new ImageElement();
  image.src = src;
  var completer = new Completer<ImageElement>();
  image.onLoad.listen((e) => completer.complete(image));
  return completer.future;
}