part of examples;

void masking(DivElement parent) {
  ImageElement image, maskImg;
  loadImages(['farminglpc.png', 'mask.png']).then((images) {
    image = images[0];
    maskImg = images[1];
    parent..append(image)
          ..appendText('+')
          ..append(maskImg)
          ..appendHtml('<br />=<br />');
    var cqMaskImg = cq(maskImg);
    List<int> grayscaleMask = cqMaskImg.grayscaleToMask();
    List<bool> colorMask = cqMaskImg.colorToMask('#000000');
    cq(image)..applyMask(grayscaleMask)
             ..canvas.title = '''
List<int> grayscaleMask = cq(maskImg).grayscaleToMask();\n
cq(image).applyMask(grayscaleMask)'''
             ..appendTo(parent);
    cq(image)..applyMask(colorMask)
             ..canvas.title = '''
List<int> colorMask = cq(maskImg).colorToMask('#000000');\n
cq(image).applyMask(colorMask)'''
             ..appendTo(parent);
  });
}