# MIDLE Changelog

## Version 0.4.0 2014-09-08
* **New Feature**: Limited support of selected program control constructs
  (IF/ELSE, FOR, FOREACH, CONTINUE, BREAK).
* **New Feature**: Add midlegui to provide a GUI console and facilitate the
  usage of MIDLE as a script engine.
* **Improve**: The demo GUI application is now a solid example of how MIDLE
  console can be used to control the host application.

## Version 0.3.0 2014-08-04
* **New Feature**: A demo GUI is added to showcase how MIDLE can be used in IDL
  Virtual Machine.
* **Bug Fix**: A dangling variable can also be a procedure call with no
  arguments in addition to be just a variable.

## Version 0.2.0 2014-07-28
* **New Feature**: Subscripts and dot notations can now also be chained for the
  left-hand-side variable of assignments. This allows direct assignment to an
  item of a list where the list itself is inside an array.
* **Improve**: Error handling. MIDLE now always provide helpful information
  if the error is due to the input string of code. It also always return the
  error message through the error output keyword.
* **Bug Fix**: Implicit integer and unsigned integer are now auto-promoted to
  their corresponding LONG and LONG64 types when necessary.

## Version 0.1.1 2014-07-25
* **Improve**: Subscripting array is optimized by creating a separated function
  `arraycut`. This eliminates the need for creating `SubscriptNode` during
  evaluation of `AssignNode`, which was a band-aid solution.
* **Improve**: Error handling for type conversion during array concatenation
* **Improve**: Documentations
* **Bug Fix**: Assignment can also be done to a slice of list, e.g.
  `someList[3:5] = someVal`

## Version 0.1.0 2014-07-24
* First public release
