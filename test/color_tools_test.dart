import "package:canvas_query/color_tools.dart";
import "package:unittest/unittest.dart";


main() {
  group('color conversion', () {
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
    test('#000000 to [0, 0, 0]', () {
      List<int> rgb = hexToRgb('#000000');
      expect(rgb[0], equals(0));
      expect(rgb[1], equals(0));
      expect(rgb[2], equals(0));
    });
    test('#FFFFff to [255, 255, 255]', () {
      List<int> rgb = hexToRgb('#FFFFff');
      expect(rgb[0], equals(255));
      expect(rgb[1], equals(255));
      expect(rgb[2], equals(255));
    });
    test('[0, 0, 0] to #000000', () {
      String hex = rgbToHex(0, 0, 0);
      expect(hex, equals('#000000'));
    });
    test('[255, 255, 255] to #ffffff', () {
      String hex = rgbToHex(255, 255, 255);
      expect(hex, equals('#ffffff'));
    });
  });
}
