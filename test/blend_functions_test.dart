import "package:canvas_tools/blend_functions.dart";
import "package:unittest/unittest.dart";


main() {
  test('RGB to HSL to RGB', () {
    int r = 80;
    int g = 160;
    int b = 240;
    List<int> rgb = hslListToRgb(rgbToHsl(r, g, b));

    expect(rgb[0], equals(r));
    expect(rgb[1], equals(g));
    expect(rgb[2], equals(b));
  });
  test('RGB to HSV to RGB', () {
    int r = 80;
    int g = 160;
    int b = 240;
    List<int> rgb = hsvListToRgb(rgbToHsv(r, g, b));

    expect(rgb[0], equals(r));
    expect(rgb[1], equals(g));
    expect(rgb[2], equals(b));
  });
}
