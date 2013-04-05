part of examples;

void convolve(DivElement parent) {
  loadImage('farminglpc.png').then((image) {
    cq(image)..canvas.classes.add('example')
             ..canvas.title = 'This is the source image'
             ..appendTo(parent);
    parent.appendHtml('<br />');
    cq(image)..canvas.classes.add('example')
             ..blur()
             ..canvas.title = '.blur()'
             ..appendTo(parent);
    cq(image)..canvas.classes.add('example')
             ..sharpen()
             ..canvas.title = '.sharpen()'
             ..appendTo(parent);
    cq(image)..canvas.classes.add('example')
             ..convolve([0, 1, 0, 1, -4, 1, 0, 1, 0])
             ..canvas.title = '.convolve([0, 1, 0, 1, -4, 1, 0, 1, 0])'
             ..appendTo(parent);
    cq(image)..canvas.classes.add('example')
             ..convolve([1/2])
             ..canvas.title = '.convolve([1/2])'
             ..appendTo(parent);
    cq(image)..canvas.classes.add('example')
             ..convolve([2])
             ..canvas.title = '.convolve([2])'
             ..appendTo(parent);
    cq(image)..canvas.classes.add('example')
             ..convolve([1/2, 2, 1/9, 2, 1/9, -2, 1/9, -2, -1/2])
             ..canvas.title = '.convolve([1/2, 2, 1/9, 2, 1/9, -2, 1/9, -2, -1/2])'
             ..appendTo(parent);
  });
}