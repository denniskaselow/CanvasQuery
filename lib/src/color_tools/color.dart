part of color_tools;

class Color {
  int r, g, b, a;

  Color.fromHex(String hex, [this.a]) {
    var rgb = hexToRgb(hex);
    r = rgb[0];
    g = rgb[0];
    b = rgb[0];
  }
  Color.fromRgb(this.r, this.g, this.b, [this.a = 1]);

  List<int> toArray() => [r, g, b, a];
  String toRgb() => "rgb($r,$g,$b)";
  String toRgba() => "rgb($r,$g,$b,$a)";
  String toHex() => rgbToHex(r, g, b);
  List<double> toHsl() => rgbToHsl(r, g, b);
  List<double> toHsv() => rgbToHsv(r, g, b);
}