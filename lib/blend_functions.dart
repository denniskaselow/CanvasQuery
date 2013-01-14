library blend_functions;

import 'dart:math';

import 'package:canvas_query/color_tools.dart';

typedef int BlendFunction(int a, int b);
typedef List<int> SpecialBlendFunction(List<int> a, List<int> b);

class BlendFunctions {
  static int normal(int a, int b) => b;

  static int overlay(num a, num b) {
    a /= 255;
    b /= 255;
    var result = 0;

    if (a < 0.5) result = 2 * a * b;
    else result = 1 - 2 * (1 - a) * (1 - b);

    return min(255, max(0, result * 255)).toInt();
  }

  static int hardLight(int a, int b) => BlendFunctions.overlay(b, a);

  static int softLight(num a, num b) {
    a /= 255;
    b /= 255;

    var v = ((1 - 2 * b) * a + 2 * b) * a;
    return limitValue((v * 255).toInt(), 0, 255);
  }

  static int dodge(int a, int b) => min(256 * a ~/ (255 - b + 1), 255);
  static int burn(int a, int b) => 255 - min(256 * (255 - a) ~/ (b + 1), 255);
  static int multiply(int a, int b) => b * a ~/ 255;
  static int divide(int a, int b) => min(256 * a ~/ (b + 1), 255);
  static int screen(int a, int b) => 255 - (255 - b) * (255 - a) ~/ 255;
  static int grainExtract(int a, int b) => limitValue(a - b + 128, 0, 255);
  static int grainMerge(int a, int b) => limitValue(a + b - 128, 0, 255);
  static int difference(int a, int b) => (a - b).abs();
  static int addition(int a, int b) => min(a + b, 255);
  static int substract(int a, int b) => max(a - b, 0);
  static int darkenOnly(int a, int b) => min(a, b);
  static int lightenOnly(int a, int b) => max(a, b);
}

class SpecialBlendFunctions {

  static List<int> color(List<int> a, List<int> b) {
    var aHSL = rgbListToHsl(a);
    var bHSL = rgbListToHsl(b);

    return hslToRgb(bHSL[0], bHSL[1], aHSL[2]);
  }

  static List<int> hue(List<int> a, List<int> b) {
    var aHSV = rgbListToHsv(a);
    var bHSV = rgbListToHsv(b);

    if(bHSV[1] == 0) return hsvToRgb(aHSV[0], aHSV[1], aHSV[2]);
    else return hsvToRgb(bHSV[0], aHSV[1], aHSV[2]);
  }

  static List<int> value(List<int> a, List<int> b) {
    var aHSV = rgbListToHsv(a);
    var bHSV = rgbListToHsv(b);

    return hsvToRgb(aHSV[0], aHSV[1], bHSV[2]);
  }

  static List<int> saturation(List<int> a, List<int> b) {
    var aHSV = rgbListToHsv(a);
    var bHSV = rgbListToHsv(b);

    return hsvToRgb(aHSV[0], bHSV[1], aHSV[2]);
  }
}

num limitValue(num value, num min, num max) => value < min ? min : value > max ? max : value;
num mixIt(num a, num b, num ammount) => a + (b - a) * ammount;
num wrapValue(num value, num min, num max) {
  if(value < min) {
    value = max + (value - min);
  } else if(value > max) {
    value = min + (value - max);
  }
  return value;
}