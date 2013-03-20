part of canvas_query;

class CanvasTools {

  static void blend(CanvasElement below, var above, BlendFunction blendingFunction, [num mix = 1]) {
    _initBlend(below, above, mix, (pixels, belowPixels, abovePixels, mix) {
      _blend(pixels, belowPixels, abovePixels, mix, blendingFunction);
    });
  }

  static void blendSpecial(CanvasElement below, var above, SpecialBlendFunction blendingFunction, [num mix = 1]) {
    _initBlend(below, above, mix, (pixels, belowPixels, abovePixels, mix) {
      _blendSpecial(pixels, belowPixels, abovePixels, mix, blendingFunction);
    });
  }

  static CanvasElement _initBlend(CanvasElement below, var above, num mix, Function blendingFunction(Uint8ClampedArray pixels, Uint8ClampedArray belowPixels, Uint8ClampedArray abovePixels, num mix)) {
    var belowCtx = below.context2d;
    var aboveCtx = cq(above).canvas.context2d;

    var belowData = belowCtx.getImageData(0, 0, below.width, below.height);
    var aboveData = aboveCtx.getImageData(0, 0, above.width, above.height);

    var imageData = createImageData(below.width, below.height);

    blendingFunction(imageData.data, belowData.data, aboveData.data, mix);

    below.context2d.putImageData(imageData, 0, 0);
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

  static CanvasElement createCanvas(ImageElement img) {
    var result = new CanvasElement(width: img.width, height: img.height);
    result.context2d.drawImage(img, 0, 0);
    return result;
  }

  static ImageData createImageData(int width, int height) {
    return new CanvasElement().context2d.createImageData(width, height);
  }

  /* https://gist.github.com/3781251 */

  static List<int> mousePosition(MouseEvent event) {
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
      mouseY = event.page.x;
    }
    // IE8 and below doesn't support event.pageX
    else if(null != event.client.x || null != event.client.y) {
      mouseX = event.client.x + document.body.scrollLeft + document.documentElement.scrollLeft;
      mouseY = event.client.y + document.body.scrollTop + document.documentElement.scrollTop;
    }
    // Subtract the offset from the mouse coordinates
    coordX = mouseX - totalOffsetX;
    coordY = mouseY - totalOffsetY;

    return [coordX, coordY];
  }
}
