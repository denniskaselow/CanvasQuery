part of examples;

void coloring(DivElement parent) {
  loadImage('ships.png').then((image) {
    var current = cq(image)..canvas.classes.add('example');
    current.appendTo(parent);

    InputElement hueSlider = querySelector("#hue");
    InputElement saturationSlider = querySelector("#saturation");
    InputElement lightnessSlider = querySelector("#lightness");
    hueSlider.onChange.listen((_) =>  updateHsl(image, hueSlider, saturationSlider, lightnessSlider, current));
    saturationSlider.onChange.listen((_) => updateHsl(image, hueSlider, saturationSlider, lightnessSlider, current));
    lightnessSlider.onChange.listen((_) => updateHsl(image, hueSlider, saturationSlider, lightnessSlider, current));
  });
}

void updateHsl(ImageElement image, InputElement hueSlider, InputElement saturationSlider, InputElement lightnessSlider, CanvasQuery current) {
  var hue = hueSlider.value;
  var sat = saturationSlider.value;
  var light = lightnessSlider.value;
  var next = cq(image)..shiftHsl(hue: double.parse(hue),
                                  saturation: double.parse(sat),
                                  lightness: double.parse(light))
                      ..canvas.classes.add('example');
  current.replaceWith(next);
}