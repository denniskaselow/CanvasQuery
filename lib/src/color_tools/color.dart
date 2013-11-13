part of color_tools;

/**
 * Simple class to represent a color in RGBA.
 */
class Color {
  int r, g, b;
  double a;

  /**
   * Creates a [Color] from another [Color].
   */
  Color.fromColor(Color other) {
    r = other.r;
    g = other.g;
    b = other.b;
    a = other.a;
  }
  /**
   * Creates a [Color] from a hex string.
   */
  Color.fromHex(String hex, [this.a = 1.0]) {
    var rgb = hexToRgb(hex);
    r = rgb[0];
    g = rgb[1];
    b = rgb[2];
  }
  /**
   * Creates a [Color] from RGB values.
   */
  Color.fromRgb(this.r, this.g, this.b, [this.a = 1.0]);

  /**
   * Creates a [Color] from HSL values.
   */
  Color.fromHsl(num h, num s, num l, [this.a = 1.0]) {
    _setRgbFromHsl(h, s, l);
  }

  /**
   * Creates a [Color] from HSV values.
   */
  Color.fromHsv(num h, num s, num v, [this.a = 1.0]) {
    var rgb = hsvToRgb(h, s, v);
    r = rgb[0];
    g = rgb[1];
    b = rgb[2];
  }

  /**
   * Creates a list of the RGBA values.
   */
  List<num> toArray() => [r, g, b, a];
  /**
   * Creates a RGB string.
   */
  String toRgb() => "rgb($r,$g,$b)";
  /**
   * Creates a RGBA string.
   */
  String toRgba() => "rgba($r,$g,$b,$a)";
  /**
   * Creates a hex string.
   */
  String toHex() => rgbToHex(r, g, b);
  /**
   * Creates a list of HSL values.
   */
  List<double> toHsl() => rgbToHsl(r, g, b)..add(a);
  /**
   * Creates a list of HSV values.
   */
  List<double> toHsv() => rgbToHsv(r, g, b)..add(a);

  /**
   * Shifts the hue, saturation and lightness of the color by the passed amount.
   */
  void shiftHsl({double h, double s, double l}) {
    var hsl = toHsl();

    h = h == null ? hsl[0] : wrapValue(hsl[0] + h, 0.0, 1.0);
    s = s == null ? hsl[1] : limitValue(hsl[1] + s, 0.0, 1.0);
    l = l == null ? hsl[2] : limitValue(hsl[2] + l, 0.0, 1.0);

    _setRgbFromHsl(h, s, l);
  }

  /**
   * Sets the hue, saturation and lightness of the color by the passed amount.
   */
  void setHsl({double h, double s, double l}) {
    var hsl = toHsl();

    h = h == null ? hsl[0] : limitValue(h, 0.0, 1.0);
    s = s == null ? hsl[1] : limitValue(s, 0.0, 1.0);
    l = l == null ? hsl[2] : limitValue(l, 0.0, 1.0);

    _setRgbFromHsl(h, s, l);
  }

  void mix(Color other, double mix) {
    r = r + ((other.r - r) * mix).toInt();
    g = g + ((other.g - g) * mix).toInt();
    b = b + ((other.b - b) * mix).toInt();
  }


  _setRgbFromHsl(double h, double s, double l) {
    var rgb = hslToRgb(h, s, l);
    r = rgb[0];
    g = rgb[1];
    b = rgb[2];
  }
}