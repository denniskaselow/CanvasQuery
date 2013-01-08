library CanvasTools;

import 'dart:math';

typedef int BlendFunction(int a, int b);

class BlendFunctions {
  static int normal(int a, int b) => b;
  
  static int overlay(int a, int b) {
    a ~/= 255;
    b ~/= 255;
    var result = 0;
  
    if(a < 128) result = 2 * a * b;
    else result = 1 - 2 * (1 - a) * (1 - b);
  
    return min(255, max(0, result * 255 | 0));
  }
  
  static int hardLight(int a, int b) => BlendFunctions.overlay(b, a);
  
  static int softLight(int a, int b) {
    a ~/= 255;
    b ~/= 255;
  
    var v = (1 - 2 * b) * (a * a) + 2 * b * a;
    return limitValue(v * 255, 0, 255);
  }
  
  static int dodge(int a, int b) => 256 * a ~/ (255 - b + 1);
  static int burn(int a, int b) => 255 - 256 * (255 - a) ~/ (b + 1);
  static int multiply(int a, int b) => b * a ~/ 255;
  static int divide(int a, int b) => limitValue(256 * a ~/ (b + 1), 0, 255);
  static int screen(int a, int b) => 255 - (255 - b) * (255 - a) ~/ 255;
  static int grainExtract(int a, int b) => limitValue(a - b + 128, 0, 255);
  static int grainMerge(int a, int b) => limitValue(a + b - 128, 0, 255);
  static int difference(int a, int b) => (a - b).abs();
  static int addition(int a, int b) => min(a + b, 255);
  static int substract(int a, int b) => max(a - b, 0);
  static int darkenOnly(int a, int b) => min(a, b);
  static int lightenOnly(int a, int b) => max(a, b);
  
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

int limitValue(int value, int min, int max) => value < min ? min : value > max ? max : value;

/* author: http://mjijackson.com/ */
List<int> rgbListToHsl(List<int> rgb) => rgbToHsl(rgb[0], rgb[1], rgb[2]);
List<int> rgbToHsl(int r, int g, int b) {
  r ~/= 255;
  g ~/= 255;
  b ~/= 255;
  int maxv = max(max(r, g), b),
      minv = min(min(r, g), b);
  num h, s, l = (maxv + minv) / 2;

  if(maxv == minv) {
    h = s = 0; // achromatic
  } else {
    num d = maxv - minv;
    s = l > 0.5 ? d / (2 - maxv - minv) : d / (maxv + minv);
    switch(maxv) {
      case r:
        h = (g - b) / d + (g < b ? 6 : 0);
        break;
      case g:
        h = (b - r) / d + 2;
        break;
      case b:
        h = (r - g) / d + 4;
        break;
    }
    h /= 6;
  }

  return [h, s, l];
}
/* author: http://mjijackson.com/ */
List<int> hslToRgb(int h, int s, int l) {
  int r, g, b;

  if(s == 0) {
    r = g = b = l; // achromatic
  } else {
    Function hue2rgb = (p, q, t) {
      if(t < 0) t += 1;
      if(t > 1) t -= 1;
      if(t < 1 / 6) return p + (q - p) * 6 * t;
      if(t < 1 / 2) return q;
      if(t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
      return p;
    };

    num q = l < 0.5 ? l * (1 + s) : l + s - l * s;
    num p = 2 * l - q;
    r = hue2rgb(p, q, h + 1 / 3);
    g = hue2rgb(p, q, h);
    b = hue2rgb(p, q, h - 1 / 3);
  }

  return [r * 255 | 0, g * 255 | 0, b * 255 | 0];
}


List<int> rgbListToHsv(List<int> rgb) => rgbToHsv(rgb[0], rgb[1], rgb[2]);
List<int> rgbToHsv(int r, int g, int b) {
  r = r ~/ 255;
  g = g ~/ 255;
  b = b ~/ 255;
  var maxv = max(max(r, g), b),
      minv = min(min(r, g), b);
  var h, s, v = maxv;

  var d = maxv - minv;
  s = maxv == 0 ? 0 : d / maxv;

  if(maxv == minv) {
    h = 0; // achromatic
  } else {
    switch(maxv) {
      case r:
        h = (g - b) / d + (g < b ? 6 : 0);
        break;
      case g:
        h = (b - r) / d + 2;
        break;
      case b:
        h = (r - g) / d + 4;
        break;
    }
    h /= 6;
  }

  return [h, s, v];
}

List<int> hsvToRgb(int h, int s, int v) {
  int r, g, b;

  int i = (h * 6).floor();
  int f = h * 6 - i;
  int p = v * (1 - s);
  int q = v * (1 - f * s);
  int t = v * (1 - (1 - f) * s);

  switch(i % 6) {
    case 0:
      r = v; g = t; b = p;
      break;
    case 1:
      r = q; g = v; b = p;
      break;
    case 2:
      r = p; g = v; b = t;
      break;
    case 3:
      r = p; g = q; b = v;
      break;
    case 4:
      r = t; g = p; b = v;
      break;
    case 5:
      r = v; g = p; b = q;
      break;
  }

  return [r * 255, g * 255, b * 255];
}