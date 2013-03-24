import "package:canvas_query/blend_functions.dart";
import "package:unittest/unittest.dart";


main() {
  group('BlendFunctions', () {
    test('normal returns second argument', () {
      int a = 50, b = 100;
      expect(Blend.normal(a, b), equals(b));
    });
    test('overlay returns correct result for a <= 128', () {
      int a = 51, b = 204;
      expect(Blend.overlay(a, b), equals(81));
    });
    test('overlay returns correct result for a > 128', () {
      int a = 204, b = 51;
      expect(Blend.overlay(a, b), equals(173));
    });
    test('hardLight returns correct result for a <= 128', () {
      int a = 51, b = 204;
      expect(Blend.hardLight(a, b), equals(173));
    });
    test('hardLight returns correct result for a > 128', () {
      int a = 204, b = 51;
      expect(Blend.hardLight(a, b), equals(81));
    });
    test('softLight', () {
      int a = 50, b = 100;
      expect(Blend.softLight(a, b), equals(41));
    });
    test('dodge devides a by inverted b', () {
      expect(Blend.dodge(50, 100), equals(82));
    });
    test('dodge has max value of 255', () {
      expect(Blend.dodge(200, 200), equals(255));
    });
    test('burn', () {
      expect(Blend.burn(200, 200), equals(185));
    });
    test('burn has min value of 0', () {
      expect(Blend.burn(50, 100), equals(0));
    });
    test('multiply 51/255 * 102/255 = 20/255', () {
      expect(Blend.multiply(51, 102), equals(20));
    });
    test('divide (153/255) / (204/255) = 191/255', () {
      expect(Blend.divide(153, 204), equals(191));
    });
    test('divide has max value of 255', () {
      expect(Blend.divide(200, 100), equals(255));
    });
    test('screen 1 - (255-204)/255 * (255-102)/255 = 225/255', () {
      expect(Blend.screen(102, 204), equals(225));
    });
    test('grainExtract', () {
      expect(Blend.grainExtract(50, 100), equals(78));
    });
    test('grainExtract has max value of 255', () {
      expect(Blend.grainExtract(250, 50), equals(255));
    });
    test('grainExtract has min value of 0', () {
      expect(Blend.grainExtract(0, 200), equals(0));
    });
    test('grainMerge', () {
      expect(Blend.grainMerge(50, 100), equals(22));
    });
    test('grainMerge has max value of 255', () {
      expect(Blend.grainMerge(250, 250), equals(255));
    });
    test('grainMerge has min value of 0', () {
      expect(Blend.grainMerge(0, 0), equals(0));
    });
    test('difference returns absolute difference', () {
      expect(Blend.difference(50, 100), equals(50));
      expect(Blend.difference(100, 50), equals(50));
    });
    test('addition returns sum of values', () {
      expect(Blend.addition(50, 100), equals(150));
    });
    test('addition returns max value of 255', () {
      expect(Blend.addition(150, 150), equals(255));
    });
    test('substract', () {
      expect(Blend.substract(200, 50), equals(150));
    });
    test('substract has min value of 0', () {
      expect(Blend.substract(50, 100), equals(0));
    });
    test('darkenOnly uses max value of a and b', () {
      expect(Blend.darkenOnly(50, 150), equals(50));
      expect(Blend.darkenOnly(150, 50), equals(50));
    });
    test('lightenOnly uses min value of a and b', () {
      expect(Blend.lightenOnly(50, 150), equals(150));
      expect(Blend.lightenOnly(150, 50), equals(150));
    });
  });
}
