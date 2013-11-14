part of canvas_query;

class Effects {
  CanvasQuery cq;

  Effects(this.cq);

  get _canvas => cq.canvas;
  get _context => cq.context2D;

  /**
   * Convolve an image using [matrix].
   * See <www.html5rocks.com/en/tutorials/canvas/imagefilters/>.
   */
  void convolve(List<num> matrix, {num mix: 1, num divide: 1}) {
    var sourceData = _context.getImageData(0, 0, _canvas.width, _canvas.height);
    var matrixSize = (sqrt(matrix.length) + 0.5).toInt();
    var halfMatrixSize = matrixSize ~/ 2;
    var src = sourceData.data;
    var sw = sourceData.width;
    var sh = sourceData.height;
    var w = sw;
    var h = sh;
    var output = CqTools.createImageData(_canvas.width, _canvas.height);
    var dst = output.data;
    var weights = divide == 1 ? matrix : _calculateWeights(matrix, matrixSize, divide);

    for(var y = 1; y < h - 1; y++) {
      for(var x = 1; x < w - 1; x++) {
        var dstOff = (y * w + x) * 4;
        double r = 0.0, g = 0.0, b = 0.0, a = 0.0;
        for(var cy = 0; cy < matrixSize; cy++) {
          for(var cx = 0; cx < matrixSize; cx++) {
            var scy = y + cy - halfMatrixSize;
            var scx = x + cx - halfMatrixSize;
            if(scy >= 0 && scy < sh && scx >= 0 && scx < sw) {
              var srcOff = (scy * sw + scx) * 4;
              var wt = weights[cy * matrixSize + cx];
              r += src[srcOff + 0] * wt;
              g += src[srcOff + 1] * wt;
              b += src[srcOff + 2] * wt;
              a += src[srcOff + 3] * wt;
            }
          }
        }
        dst[dstOff + 0] = mixIt(src[dstOff + 0], r, mix).toInt();
        dst[dstOff + 1] = mixIt(src[dstOff + 1], g, mix).toInt();
        dst[dstOff + 2] = mixIt(src[dstOff + 2], b, mix).toInt();
        dst[dstOff + 3] = src[dstOff + 3];
      }
    }

    _context.putImageData(output, 0, 0);
  }

  List<double> _calculateWeights(List<num> matrix, int matrixSize, num divide) {
    var weights = new List<double>(matrix.length);
    for(var cy = 0; cy < matrixSize; cy++) {
      for(var cx = 0; cx < matrixSize; cx++) {
        var index = cy * matrixSize + cx;
        weights[index] = matrix[index] / divide;
      }
    }
    return weights;
  }

  /**
   * Blurs an image.
   */
  void blur({num mix: 1}) => convolve([1, 1, 1, 1, 1, 1, 1, 1, 1], mix: mix, divide: 9);
  /**
   * Applies a gaussian blur to an image.
   */
  void gaussianBlur({num mix: 1}) => convolve([0.00000067, 0.00002292, 0.00019117, 0.00038771, 0.00019117, 0.00002292, 0.00000067,
                                               0.00002292, 0.00078633, 0.00655965, 0.01330373, 0.00655965, 0.00078633, 0.00002292,
                                               0.00019117, 0.00655965, 0.05472157, 0.11098164, 0.05472157, 0.00655965, 0.00019117,
                                               0.00038771, 0.01330373, 0.11098164, 0.22508352, 0.11098164, 0.01330373, 0.00038771,
                                               0.00019117, 0.00655965, 0.05472157, 0.11098164, 0.05472157, 0.00655965, 0.00019117,
                                               0.00002292, 0.00078633, 0.00655965, 0.01330373, 0.00655965, 0.00078633, 0.00002292,
                                               0.00000067, 0.00002292, 0.00019117, 0.00038771, 0.00019117, 0.00002292, 0.00000067], mix : mix);
  /**
   * Sharpens the image.
   */
  void sharpen({num mix: 1}) => convolve([0, -1, 0, -1, 5, -1, 0, -1, 0], mix : mix);
  /**
   * Pixels with a grayscale value beyond [threshold] will become transparent.
   */
  void threshold(num threshold) {
    var data = _context.getImageData(0, 0, _canvas.width, _canvas.height);
    var pixels = data.data;
    int r, g, b;

    for(var i = 0; i < pixels.length; i += 4) {
      r = pixels[i];
      g = pixels[i + 1];
      b = pixels[i + 2];
      var v = (0.2126 * r + 0.7152 * g + 0.0722 * b >= threshold) ? 255 : 0;
      pixels[i] = pixels[i + 1] = pixels[i + 2] = v.toInt();
    }

    _context.putImageData(data, 0, 0);
  }

  /**
   * Sepia filter.
   */
  void sepia() {
    var data = _context.getImageData(0, 0, _canvas.width, _canvas.height);
    var pixels = data.data;

    for(var i = 0; i < pixels.length; i += 4) {
      pixels[i + 0] = limitValue((pixels[i + 0] * .393) + (pixels[i + 1] * .769) + (pixels[i + 2] * .189), 0, 255).toInt();
      pixels[i + 1] = limitValue((pixels[i + 0] * .349) + (pixels[i + 1] * .686) + (pixels[i + 2] * .168), 0, 255).toInt();
      pixels[i + 2] = limitValue((pixels[i + 0] * .272) + (pixels[i + 1] * .534) + (pixels[i + 2] * .131), 0, 255).toInt();
    }

    _context.putImageData(data, 0, 0);
  }
}