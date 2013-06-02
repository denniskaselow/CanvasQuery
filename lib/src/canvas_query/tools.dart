part of canvas_query;

class CqTools {

  /// Returns if the userAgent of the browser belong to a mobile browser.
  static final bool mobile = window.navigator.userAgent.contains(r'Android|webOS|iPhone|iPad|iPod|BlackBerry|Windows Phone');

  /**
   * Blends [below] with [above] using [blendingFunction].
   */
  static void blend(CanvasElement below, var above, BlendFunction blendingFunction, [num mix = 1]) {
    _initBlend(below, above, mix, (pixels, belowPixels, abovePixels, mix) {
      _blend(pixels, belowPixels, abovePixels, mix, blendingFunction);
    });
  }

  /**
   * Blends [below] with [above] using [blendingFunction].
   */
  static void blendSpecial(CanvasElement below, var above, SpecialBlendFunction blendingFunction, [num mix = 1]) {
    _initBlend(below, above, mix, (pixels, belowPixels, abovePixels, mix) {
      _blendSpecial(pixels, belowPixels, abovePixels, mix, blendingFunction);
    });
  }

  static CanvasElement _initBlend(CanvasElement below, var above, num mix, Function blendingFunction(List<int> pixels, List<int> belowPixels, List<int> abovePixels, num mix)) {
    var belowCtx = below.context2D;
    var aboveCtx = cq(above).canvas.context2D;

    var belowData = belowCtx.getImageData(0, 0, below.width, below.height);
    var aboveData = aboveCtx.getImageData(0, 0, above.width, above.height);

    var imageData = createImageData(below.width, below.height);

    blendingFunction(imageData.data, belowData.data, aboveData.data, mix);

    below.context2D.putImageData(imageData, 0, 0);
  }

  static _blendSpecial(List<int> pixels, List<int> belowPixels, List<int> abovePixels, num mix, SpecialBlendFunction blendingFunction) {
    for(int i = 0; i < belowPixels.length; i += 4) {
      var rgb = blendingFunction([belowPixels[i + 0], belowPixels[i + 1], belowPixels[i + 2]], [abovePixels[i + 0], abovePixels[i + 1], abovePixels[i + 2]]);

      pixels[i + 0] = belowPixels[i + 0] + ((rgb[0] - belowPixels[i + 0]) * mix).toInt();
      pixels[i + 1] = belowPixels[i + 1] + ((rgb[1] - belowPixels[i + 1]) * mix).toInt();
      pixels[i + 2] = belowPixels[i + 2] + ((rgb[2] - belowPixels[i + 2]) * mix).toInt();

      pixels[i + 3] = belowPixels[i + 3];
    }
  }

  static _blend(List<int> pixels, List<int> belowPixels, List<int> abovePixels, num mix, BlendFunction blendingFunction) {
    for(int i = 0; i < belowPixels.length; i += 4) {
      int r = blendingFunction(belowPixels[i + 0], abovePixels[i + 0]);
      int g = blendingFunction(belowPixels[i + 1], abovePixels[i + 1]);
      int b = blendingFunction(belowPixels[i + 2], abovePixels[i + 2]);

      pixels[i + 0] = belowPixels[i + 0] + ((r - belowPixels[i + 0]) * mix).toInt();
      pixels[i + 1] = belowPixels[i + 1] + ((g - belowPixels[i + 1]) * mix).toInt();
      pixels[i + 2] = belowPixels[i + 2] + ((b - belowPixels[i + 2]) * mix).toInt();

      pixels[i + 3] = belowPixels[i + 3];
    }
  }

  /**
   * Draws an [img] on a [CanvasElement] and returns the canvas.
   */
  static CanvasElement createCanvas(ImageElement img) {
    var result = new CanvasElement(width: img.width, height: img.height);
    result.context2D.drawImage(img, 0, 0);
    return result;
  }

  /**
   * Creates an [ImageData] object for the size of [width] and [height].
   */
  static ImageData createImageData(int width, int height) {
    return new CanvasElement().context2D.createImageData(width, height);
  }

  /**
   * Calculates the position of the mouse.
   *
   * See <https://gist.github.com/3781251>
   */
  static Point mousePosition(UIEvent event) {
    var totalOffsetX = 0,
        totalOffsetY = 0,
        coordX = 0,
        coordY = 0,
        mouseX = 0,
        mouseY = 0;

    Element currentElement = event.currentTarget;

    // Traversing the parents to get the total offset
    do {
      totalOffsetX += currentElement.offset.left;
      totalOffsetY += currentElement.offset.top;
    }
    while (null != (currentElement = currentElement.offsetParent));
    // Use pageX to get the mouse coordinates
    if(null != event.page.x || null != event.page.y) {
      mouseX = event.page.x;
      mouseY = event.page.y;
    }
    // Subtract the offset from the mouse coordinates
    coordX = mouseX - totalOffsetX;
    coordY = mouseY - totalOffsetY;

    return new Point(coordX, coordY);
  }
}
