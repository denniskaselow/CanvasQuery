part of examples;

void convolve(DivElement parent) {
  loadImage('farminglpc.png').then((image) {
    cq(image)..canvas.classes.add('example')
             ..canvas.title = 'This is the source image'
             ..appendTo(parent);
    parent.appendHtml('<br />');
    cq(image)..canvas.classes.add('example')
             ..effects.blur()
             ..canvas.title = '.effects.blur()'
             ..appendTo(parent);
    cq(image)..canvas.classes.add('example')
             ..effects.sharpen()
             ..canvas.title = '.effects.sharpen()'
             ..appendTo(parent);
    cq(image)..canvas.classes.add('example')
             ..effects.convolve([0, 1, 0, 1, -4, 1, 0, 1, 0])
             ..canvas.title = '.effects.convolve([0, 1, 0, 1, -4, 1, 0, 1, 0])'
             ..appendTo(parent);
    cq(image)..canvas.classes.add('example')
             ..effects.convolve([1/2])
             ..canvas.title = '.effects.convolve([1/2])'
             ..appendTo(parent);
    cq(image)..canvas.classes.add('example')
             ..effects.convolve([2])
             ..canvas.title = '.effects.convolve([2])'
             ..appendTo(parent);
    cq(image)..canvas.classes.add('example')
             ..effects.convolve([1/2, 2, 1/9, 2, 1/9, -2, 1/9, -2, -1/2])
             ..canvas.title = '.effects.convolve([1/2, 2, 1/9, 2, 1/9, -2, 1/9, -2, -1/2])'
             ..appendTo(parent);
  });
}