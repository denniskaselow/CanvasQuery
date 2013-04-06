Canvas Query
============

[![Build Status](https://drone.io/github.com/denniskaselow/CanvasQuery/status.png)](https://drone.io/github.com/denniskaselow/CanvasQuery/latest)

* extended canvas for gamedevelopers
* easy setup for a game loop, rendering loop, mouse, touch and keyboard

```dart
cq(640, 480)
  ..drawImage(image, 0, 0)
  ..fillStyle('#ff0000')
  ..fillRect(64, 64, 32, 32)
  ..blur()
  ..appendTo(query('body'));
```

# Overview

[Reference Manual](http://denniskaselow.github.io/CanvasQuery/docs/canvas_query.html)  
[Examples](http://denniskaselow.github.io/CanvasQuery/examples.html)

# Getting started

## Creating wrapper

### From existing canvas

```dart
cq(canvas);
```

### From image

```dart
cq(image);
```

### From CSS Selector

```dart
cq('#canvas');
cq('.image');
```


### Empty

```dart
cq(320, 240);
```

### Fullscreen

```dart
cq();
```

* CqWrapper supports all CanvasRenderingContext2D methods and properties by using noSuchMethod.

You can still access the original context and canvas element

```dart
cq('#something').canvas;
cq('#something').context;
```

## Clone

Any change done to the wrapper will be applied to the original provided (or created) canvas element. Whenever you want to break the chain reaction and get a fresh copy use .clone() method:

```dart
var clone = cq().clone()..setHsl(...);
```

## Appending

If you want to insert your canvas to the document body use the .appendTo() method:

```dart
cq(320, 240)..fillStyle = '#00ff00'
            ..fill(0, 0)
            ..appendTo(query('body'));
```

# Help

If you have any question ask them [here](https://github.com/denniskaselow/CanvasQuery/issues/new)

Credits
=======

* [Przemyslaw Sikorski / rezoner](http://rezoner.net) for creating the original javascript version of CanvasQuery