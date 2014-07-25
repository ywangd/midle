# MIDLE Changelog

## Version 0.1.1 2014-07-25
* **Improve**: Subscripting array is optimized by creating a separated function
  `arraycut`. This eliminates the need for creating `SubscriptNode` during
  evaluation of `AssignNode`, which was a band-aid solution.
* **Improve**: Error handling for type conversion during array concatenation
* **Improve**: Documentations
* **BugFix**: Assignment can also be done to a slice of list, e.g.
  `someList[3:5] = someVal`

## Version 0.1.0 2014-07-24
* First public release
