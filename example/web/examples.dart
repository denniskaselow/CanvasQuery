library examples;

import 'dart:async';
import 'dart:html';
import 'dart:collection';

import 'package:canvas_query/canvas_query.dart';

part 'src/coloring.dart';
part 'src/blending.dart';
part 'src/border.dart';
part 'src/wrapped_text.dart';
part 'src/masking.dart';
part 'src/convolve.dart';

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

Future<ImageElement> loadImage(String src) {
  var image = new ImageElement();
  image.src = src;
  var completer = new Completer<ImageElement>();
  image.onLoad.listen((e) => completer.complete(image));
  return completer.future;
}
