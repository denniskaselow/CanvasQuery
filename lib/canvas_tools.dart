import 'dart:html';
import 'dart:math';

part 'src/blend_functions.dart';

class CanvasTools {

  static CanvasElement blend(CanvasElement below, CanvasElement above, BlendFunction blendingFunction, [num mix = 1]) {
    _initBlend(below, above, mix, (pixels, belowPixels, abovePixels, mix) {
      _blend(pixels, belowPixels, abovePixels, mix, blendingFunction);
    });
  }

  static CanvasElement blendSpecial(CanvasElement below, CanvasElement above, SpecialBlendFunction blendingFunction, [num mix = 1]) {
    _initBlend(below, above, mix, (pixels, belowPixels, abovePixels, mix) {
      _blendSpecial(pixels, belowPixels, abovePixels, mix, blendingFunction);
    });
  }

  static CanvasElement _initBlend(CanvasElement below, CanvasElement above, num mix, Function blendingFunction(Uint8ClampedArray pixels, Uint8ClampedArray belowPixels, Uint8ClampedArray abovePixels, num mix)) {
    var belowCtx = below.context2d;
    var aboveCtx = above.context2d;

    var belowData = belowCtx.getImageData(0, 0, below.width, below.height);
    var aboveData = aboveCtx.getImageData(0, 0, above.width, above.height);

    var imageData = createImageData(below.width, below.height);

    blendingFunction(imageData.data, belowData.data, aboveData.data, mix);

    below.context2d.putImageData(imageData, 0, 0);

    return below;
  }

  static _blendSpecial(Uint8ClampedArray pixels, Uint8ClampedArray belowPixels, Uint8ClampedArray abovePixels, num mix, SpecialBlendFunction blendingFunction) {
    for(var i = 0, len = belowPixels.length; i < len; i += 4) {
      var rgb = blendingFunction([belowPixels[i + 0], belowPixels[i + 1], belowPixels[i + 2]], [abovePixels[i + 0], abovePixels[i + 1], abovePixels[i + 2]]);

      pixels[i + 0] = belowPixels[i + 0] + (rgb[0] - belowPixels[i + 0]) * mix;
      pixels[i + 1] = belowPixels[i + 1] + (rgb[1] - belowPixels[i + 1]) * mix;
      pixels[i + 2] = belowPixels[i + 2] + (rgb[2] - belowPixels[i + 2]) * mix;

      pixels[i + 3] = belowPixels[i + 3];
    }
  }

  static _blend(Uint8ClampedArray pixels, Uint8ClampedArray belowPixels, Uint8ClampedArray abovePixels, num mix, BlendFunction blendingFunction) {
    for(var i = 0, len = belowPixels.length; i < len; i += 4) {
      var r = blendingFunction(belowPixels[i + 0], abovePixels[i + 0]);
      var g = blendingFunction(belowPixels[i + 1], abovePixels[i + 1]);
      var b = blendingFunction(belowPixels[i + 2], abovePixels[i + 2]);

      pixels[i + 0] = belowPixels[i + 0] + (r - belowPixels[i + 0]) * mix;
      pixels[i + 1] = belowPixels[i + 1] + (g - belowPixels[i + 1]) * mix;
      pixels[i + 2] = belowPixels[i + 2] + (b - belowPixels[i + 2]) * mix;

      pixels[i + 3] = belowPixels[i + 3];
    }
  }

  static ImageData createImageData(int width, int height) {
    return new CanvasElement().context2d.createImageData(width, height);
  }
}
