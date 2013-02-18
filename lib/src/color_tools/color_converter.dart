part of color_tools;

List<int> hexToRgb(String hex) {
  return [int.parse('0x${hex[1]}${hex[2]}'), int.parse('0x${hex[3]}${hex[4]}'), int.parse('0x${hex[5]}${hex[6]}')];
}

String rgbToHex(int r, int g, int b) {
  return '#${((1 << 24) + (r << 16) + (g << 8) + b).toRadixString(16).substring(1, 7)}';
}

/* author: http://mjijackson.com/ */
List<double> rgbListToHsl(List<int> rgb) => rgbToHsl(rgb[0], rgb[1], rgb[2]);
List<double> rgbToHsl(int red, int green, int blue) {
  final double r = red / 255;
  final double g = green / 255;
  final double b = blue / 255;
  double maxv = max(max(r, g), b),
      minv = min(min(r, g), b);
  double h, s, l = (maxv + minv) / 2;

  if(maxv == minv) {
    h = s = 0.0; // achromatic
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
List<int> hslListToRgb(List<num> hsl) => hslToRgb(hsl[0], hsl[1], hsl[2]);
List<int> hslToRgb(num hue, num saturation, num lightness) {
  double h = hue.toDouble();
  double s = saturation.toDouble();
  double l = lightness.toDouble();
  double r;
  double g;
  double b;

  if(s == 0.0) {
    r = g = b = l; // achromatic
  } else {
    Function hue2rgb = (num p, num q, num t) {
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

  return [(r * 255 + 0.5).toInt(), (g * 255 + 0.5).toInt(), (b * 255 + 0.5).toInt()];
}


List<double> rgbListToHsv(List<int> rgb) => rgbToHsv(rgb[0], rgb[1], rgb[2]);
List<double> rgbToHsv(int red, int green, int blue) {
  final double r = red / 255;
  final double g = green / 255;
  final double b = blue / 255;
  double maxv = max(max(r, g), b),
      minv = min(min(r, g), b);
  double h, s, v = maxv.toDouble();

  var d = maxv - minv;
  s = maxv == 0.0 ? 0.0 : d / maxv;

  if(maxv == minv) {
    h = 0.0; // achromatic
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

List<int> hsvListToRgb(List<num> hsv) => hsvToRgb(hsv[0], hsv[1], hsv[2]);
List<int> hsvToRgb(num hue, num saturation, num value) {
  double h = hue.toDouble();
  double s = saturation.toDouble();
  double v = value.toDouble();
  double r, g, b;

  int i = (h * 6).toInt();
  double f = h * 6 - i;
  double p = v * (1 - s);
  double q = v * (1 - f * s);
  double t = v * (1 - (1 - f) * s);

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

  return [(r * 255 + 0.5).toInt(), (g * 255 + 0.5).toInt(), (b * 255 + 0.5).toInt()];
}