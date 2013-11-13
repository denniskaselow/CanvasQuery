part of examples;

void blending(DivElement parent) {
  ImageElement below, above;
  int count = 0;
  loadImages(['below.png', 'above.png']).then((images) {
    below = images[0];
    above = images[1];
    InputElement mixSlider = querySelector("#mix");
    blendAll(mixSlider, below, above, parent);
    mixSlider.onChange.listen((_) {
      parent.querySelectorAll("canvas").forEach((canvas) => canvas.remove());
      blendAll(mixSlider, below, above, parent);
    });
  });
}

void blendAll(InputElement mixSlider, ImageElement below, ImageElement above, DivElement parent) {
  mixSlider.disabled = true;
  double mix = double.parse(mixSlider.value);
  for (String functionName in blendFunction.keys) {
    exampleBlend(below, above, functionName, mix, parent);
  }
  for (String functionName in specialBlendFunction.keys) {
    exampleBlendSpecial(below, above, functionName, mix, parent);
  }
  mixSlider.disabled = false;
}

void exampleBlend(below, above, String functionName, num mix, DivElement parent) {
  var function = blendFunction[functionName];
  cq(below)..blend(above, function, mix)
           ..appendTo(parent)
           ..canvas.title = '.blend(above, Blend.$functionName, $mix);'
           ..canvas.classes.add('example');
}

void exampleBlendSpecial(below, above, String functionName, num mix, DivElement parent) {
  var function = specialBlendFunction[functionName];
  cq(below)..blendSpecial(above, function, mix)
           ..appendTo(parent)
           ..canvas.title = '.blendSpecial(above, Blend.$functionName, $mix);'
           ..canvas.classes.add('example');
}

var blendFunction = {
  'normal':Blend.normal,
  'overlay': Blend.overlay,
  'hardLight': Blend.hardLight,
  'softLight': Blend.softLight,
  'dodge': Blend.dodge,
  'burn': Blend.burn,
  'multiply': Blend.multiply,
  'divide': Blend.divide,
  'screen': Blend.screen,
  'grainExtract': Blend.grainExtract,
  'grainMerge': Blend.grainMerge,
  'difference': Blend.difference,
  'addition': Blend.addition,
  'substract': Blend.substract,
  'darkenOnly': Blend.darkenOnly,
  'lightenOnly': Blend.lightenOnly
};

var specialBlendFunction = {
  'color': Blend.color,
  'hue': Blend.hue,
  'value': Blend.value,
  'saturation': Blend.saturation
};