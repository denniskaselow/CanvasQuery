part of examples;

void wrappedText(DivElement parent) {
  cq(300, 300)..font = '16px Verdana'
              ..wrappedText('''Lorem ipsum dolor sit amet, consectetur adipiscing 
elit. In elementum sapien ac turpis tempus pellentesque. Nulla non tellus purus, 
in iaculis tortor. Integer facilisis varius nibh, sit amet tempus nunc hendrerit 
non. Maecenas arcu ante, semper eget venenatis eu, commodo sed purus. Vivamus a 
mi nunc, sed vestibulum lacus.''', 20, 40, maxWidth: 260)
              ..strokeRect(10, 10, 280, 280)
              ..canvas.title = '.wrappedText(\'...\', 20, 40, maxWidth: 260);'
              ..appendTo(parent);
}