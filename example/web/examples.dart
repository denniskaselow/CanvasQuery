library examples;

import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'package:canvas_query/canvas_query.dart';

part 'src/coloring.dart';
part 'src/blending.dart';
part 'src/masking.dart';
part 'src/convolve.dart';
part 'src/palette.dart';
part 'src/framework.dart';
part 'src/uigeneration.dart';

var showcases = {'coloring': coloring, 'blending': blending,
                 'masking': masking, 'convolve': convolve,
                 'palette': palette, 'framework': framework,
                 'uigeneration': uigeneration};

void main() {
  showcases.forEach((key, value) => showShowcase(key, value));
}

void showShowcase(String showcase, Function showcaseFunction) {
  Element navEntry = querySelector("#show_$showcase");
  navEntry.onClick.listen((_) {
    showcases.keys.forEach((section) {
      querySelector("#$section").style.display = 'none';
      querySelector("#show_$section").classes.remove('highlight');
    });
    var parent = querySelector("div#$showcase");
    parent.style.display = 'block';
    navEntry.classes.add('highlight');
    if ('true' != parent.dataset['init']) {
      showcaseFunction(parent);
      parent.dataset['init'] = 'true';
    }
  });
}

Future<List<ImageElement>> loadImages(List<String> imageNames) {
  var futures = new List<Future<ImageElement>>();
  imageNames.forEach((imageName) => futures.add(loadImage(imageName)));
  return Future.wait(futures);
}

Future<ImageElement> loadImage(String src) {
  var image = new ImageElement();
  var completer = new Completer<ImageElement>();
  image.onLoad.listen((e) => completer.complete(image));
  image.src = src;
  return completer.future;
}
