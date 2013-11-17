# Changelog
##0.2.1
### Bugfix
* fixed bug for functions that expect a CanvasWindingRule as optional parameter
##0.2.0
### API
* added functionality to `Color`
* renamed `CqWrapper` to `CanvasQuery`
* removed convolution effects from `CanvasQuery`, added new method `effects` that
can be used to access them
### Internal
* added version constraint for release of Dart