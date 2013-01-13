import "package:canvas_query/blend_functions.dart";
import "package:unittest/unittest.dart";


main() {
  group('BlendFunctions', () {
    test('normal returns second argument', () {
      int a = 50, b = 100;
      expect(BlendFunctions.normal(a, b), equals(b));
    });
    test('overlay returns correct result for a <= 128', () {
      int a = 51, b = 204;
      expect(BlendFunctions.overlay(a, b), equals(81));
    });
    test('overlay returns correct result for a > 128', () {
      int a = 204, b = 51;
      expect(BlendFunctions.overlay(a, b), equals(173));
    });
    test('hardLight returns correct result for a <= 128', () {
      int a = 51, b = 204;
      expect(BlendFunctions.hardLight(a, b), equals(173));
    });
    test('hardLight returns correct result for a > 128', () {
      int a = 204, b = 51;
      expect(BlendFunctions.hardLight(a, b), equals(81));
    });
    test('softLight', () {
      int a = 50, b = 100;
      expect(BlendFunctions.softLight(a, b), equals(41));
    });
    test('dodge devides a by inverted b', () {
      expect(BlendFunctions.dodge(50, 100), equals(82));
    });
    test('dodge has max value of 255', () {
      expect(BlendFunctions.dodge(200, 200), equals(255));
    });
    test('burn', () {
      expect(BlendFunctions.burn(200, 200), equals(185));
    });
    test('burn has min value of 0', () {
      expect(BlendFunctions.burn(50, 100), equals(0));
    });
    test('multiply 51/255 * 102/255 = 20/255', () {
      expect(BlendFunctions.multiply(51, 102), equals(20));
    });
    test('divide (153/255) / (204/255) = 191/255', () {
      expect(BlendFunctions.divide(153, 204), equals(191));
    });
    test('divide has max value of 255', () {
      expect(BlendFunctions.divide(200, 100), equals(255));
    });
    test('screen 1 - (255-204)/255 * (255-102)/255 = 225/255', () {
      expect(BlendFunctions.screen(102, 204), equals(225));
    });
    test('grainExtract', () {
      expect(BlendFunctions.grainExtract(50, 100), equals(78));
    });
    test('grainExtract has max value of 255', () {
      expect(BlendFunctions.grainExtract(250, 50), equals(255));
    });
    test('grainExtract has min value of 0', () {
      expect(BlendFunctions.grainExtract(0, 200), equals(0));
    });
    test('grainMerge', () {
      expect(BlendFunctions.grainMerge(50, 100), equals(22));
    });
    test('grainMerge has max value of 255', () {
      expect(BlendFunctions.grainMerge(250, 250), equals(255));
    });
    test('grainMerge has min value of 0', () {
      expect(BlendFunctions.grainMerge(0, 0), equals(0));
    });
    test('difference returns absolute difference', () {
      expect(BlendFunctions.difference(50, 100), equals(50));
      expect(BlendFunctions.difference(100, 50), equals(50));
    });
    test('addition returns sum of values', () {
      expect(BlendFunctions.addition(50, 100), equals(150));
    });
    test('addition returns max value of 255', () {
      expect(BlendFunctions.addition(150, 150), equals(255));
    });
    test('substract', () {
      expect(BlendFunctions.substract(200, 50), equals(150));
    });
    test('substract has min value of 0', () {
      expect(BlendFunctions.substract(50, 100), equals(0));
    });
    test('darkenOnly uses max value of a and b', () {
      expect(BlendFunctions.darkenOnly(50, 150), equals(50));
      expect(BlendFunctions.darkenOnly(150, 50), equals(50));
    });
    test('lightenOnly uses min value of a and b', () {
      expect(BlendFunctions.lightenOnly(50, 150), equals(150));
      expect(BlendFunctions.lightenOnly(150, 50), equals(150));
    });
  });
  group('SpecialBlendFunctions basics', () {
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
  });
}
