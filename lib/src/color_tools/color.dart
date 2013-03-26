part of color_tools;

class Color {
  int r, g, b, a;

  Color.fromHex(String hex, [this.a = 255]) {
    var rgb = hexToRgb(hex);
    r = rgb[0];
    g = rgb[1];
    b = rgb[2];
  }
  Color.fromRgb(this.r, this.g, this.b, [this.a = 255]);

  List<int> toArray() => [r, g, b, a];
  String toRgb() => "rgb($r,$g,$b)";
  String toRgba() => "rgb($r,$g,$b,$a)";
  String toHex() => rgbToHex(r, g, b);
  List<double> toHsl() => rgbToHsl(r, g, b);
  List<double> toHsv() => rgbToHsv(r, g, b);
}