part of examples;

void coloring(DivElement parent) {
  var image = new ImageElement();
  image.onLoad.listen((e) {
    var current = cq(image)..canvas.classes.add('example');
    current.appendTo(parent);

    InputElement hueSlider = query("#hue");
    InputElement saturationSlider = query("#saturation");
    InputElement lightnessSlider = query("#lightness");
    hueSlider.onChange.listen((_) =>  updateHsl(image, hueSlider, saturationSlider, lightnessSlider, current));
    saturationSlider.onChange.listen((_) => updateHsl(image, hueSlider, saturationSlider, lightnessSlider, current));
    lightnessSlider.onChange.listen((_) => updateHsl(image, hueSlider, saturationSlider, lightnessSlider, current));
  });
  image.src = 'ships.png';
}

void updateHsl(ImageElement image, InputElement hueSlider, InputElement saturationSlider, InputElement lightnessSlider, CanvasQuery current) {
  var hue = hueSlider.value;
  var sat = saturationSlider.value;
  var light = lightnessSlider.value;
  var next = cq(image)..shiftHsl(hue: double.parse(hue),
                                  saturation: double.parse(sat),
                                  lightness: double.parse(light))
                      ..canvas.title = '.shiftHsl(hue: $hue, saturation: $sat, lightness: $light);'
                      ..canvas.classes.add('example');
  current.replaceWith(next);
}