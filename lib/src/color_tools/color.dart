part of color_tools;

/**
 * Simple class to represent a color in RGBA.
 */
class Color {
  int r, g, b, a;

  /**
   * Creates a [Color] from a hex string.
   */
  Color.fromHex(String hex, [this.a = 255]) {
    var rgb = hexToRgb(hex);
    r = rgb[0];
    g = rgb[1];
    b = rgb[2];
  }
  /**
   * Creates a [Color] from RGB values.
   */
  Color.fromRgb(this.r, this.g, this.b, [this.a = 255]);

  /**
   * Creates a list of the RGBA values.
   */
  List<int> toArray() => [r, g, b, a];
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
  List<double> toHsl() => rgbToHsl(r, g, b);
  /**
   * Creates a list of HSV values.
   */
  List<double> toHsv() => rgbToHsv(r, g, b);
}