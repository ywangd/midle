# MIDLE - A Mini IDL Expression Evaluator in IDL
Evaluate IDL expression without using `EXECUTE`, i.e. virtual machine safe.

MIDLE implements its own parser and evaluates broad categories of IDL
expressions without relying on the power of `EXECUTE`. It even adds additional
language features such as syntax for HASH and LIST literals, bettering chaining
support for method call chaining and subscript, higher level array
concatenation. It also has limitations due to either the power of IDL language
itself or deliberately left out by design, notably output argument and generic
object property access.

MIDLE requires IDL 8.0 or up (8.3 is recommended).

## Motivation
A file containing a list of IDL assignment statements is a good candidate as a
input or configuration file to IDL packages. This, however, indicates `EXECUTE`
has to be used to process the file, which is not desirable due to the fact that
`EXECUTE` cannot run in IDL virtual machines.

MIDLE is designed to fill the gap. Specifically it focuses on solving the right
hand side of the `=` sign, i.e. the expression. The left hand side is not in the
scope of MIDLE. For convenience, a routine is provided to support the process of
simple variable assignment statements.

It is also worth to note that MIDLE is not envisioned to be fast or memory
efficient. But it is pretty good at its own job.

## Installation
Add the `src` folder to your IDL path. This can be done by either setup the
`IDL_PATH` environment variable or use the preference in IDE.

## Usage
To use MIDLE, just pass a string of IDL expression to `eval`. The classic Hello
World example:
```IDL
print, eval('"Hello, World!"')
```

The second argument can be used to give values to variables in the expression:
```IDL
print, eval('indgen(2,3,4, start=num)', {num: 50})
```

List and Hash literal
```IDL
print, eval('(4.2d3, "String", "A Hash next", h{"x": 4.2, "y": 2.2})')
```

Chaining
```IDL
print, eval('list(indgen(10)[0:*:2][2:4], /extract).count()')
```

Higher level array concatenation
```IDL
help, eval('[ [[[[a]]]], [[[[b]]]] ]', {a: indgen(6,5,4,3,2), b: indgen(6,5,4,3,2, start=720)})
```

## Missing Features
The missing features fall into two categories. The first category is *By Design*
that means they are deliberately left out to narrow the scope of MIDLE so it can
focus on more important targets. Alternatives can be found for most of them. The
second category is caused by IDL's own limitation and cannot be technically
overcome (please let me know if there are ways to add them). 

* By Design
    - Hex and Oct literals not supported
    - Only anonymous structure is supported. This means no named structure, no
      inheritance.
    - Compound operators not supported, i.e. `++`, `--`, `+=`, `-=`, etc.
    - Pointer and pointer de-reference not supported, i.e. `*pointer`
    - The `->` operator not supported as most times it can be replaced by `.`
    - Parenthesis over assignment statement not supported, i.e. `x = (y = 42)`

* By IDL's own limitation
    - Output positional and keyword arguments
    - Object property access using dot notation, i.e. `object.property`
        * The dot notation can be used with Hash like object to get the value of
          using property's name as a key, i.e. `someHash.x` is equal to
          `someHash['x']`
    - Up to nine positional arguments and unlimited input keyword arguments are
      supported


## Added Features (Incompatibility)
Valid MIDLE expressions are mostly valid IDL expression as well. However, there
are a few exceptions due to MIDLE's added features. User can easily choose to
not use them or use parenthesis to enforce IDL's default behaviours. Many of the
added features are inspired by [Python](https://www.python.org/).

### List literal
List literals can be written the same way as tuples in Python, i.e.
`(42,"xyz")` is equal to `list(42,"xyz")`. Note a trailing comma is needed to
create a single element list, i.e. `(42,)` creates a list of a single element of
number 42, while `(42)` is just a number 42. A pair of empty parenthesis, `()`,
creates an empty list.

### Hash literal
Hash literals can be written using a variant of structure literal by prefixing a
letter `h` to the left curly bracket, i.e. `h{}` creates an empty Hash and is
equal to `hash()`. The keys to hash literals must be string or number, i.e.
`h{"x": 4.2, 5: "y"}` is equal to `hash("x", 4.2, 5, "y")`.

### Associativity of the power operator
The power operator, `^`, has right associativity in MIDLE, while it has left
associativity in IDL. This means an expression of `2^3^2` equals to `2^(3^2)`
in MIDLE, but equals to `(2^3)^2` in IDL. 
I think it is more common for this operator to have right associativity, as in
FORTRAN and Python. If you don't like this behaviour, use parenthesis to enforce
associativity.

### Better chaining for function/method calls and subscripts
Often parenthesis are required in IDL if you want to chain a few calls and
subscripts. For an example, say we have a hash `h` as `hash('x',3,
'y',5,'z',3)`, the expression `h.where(3)[0]` is illegal in IDL. To chain the
method call and subscript, an extra pair of parenthesis has to be used like
`(h.where(3))[0]`. Now let's try `h.where(3).count()`. Apparently it is illegal
in IDL. However even after adding extra pair of parenthesis,
`(h.where(3)).count()`, it is still invalid (error message is `Subscripts are
not allowed with object properties`). 

With MIDLE, it is legal to write chaining calls and subscripts without the
eye-irritating parenthesis. It is more in line with other modern languages like
Python.

### Higher level of array concatenation
IDL only supports up to three level of brackets for performing array
concatenation while an array can have up to eight dimensions. This means `[
[[a]], [[b]] ]` is legal in IDL for concatenating array on the third dimension,
while `[ [[[a]]], [[[b]]] ]` yields an error while trying concatenating on the
fourth dimension. 

This limitation is lifted in MIDLE. Up to eight level of brackets is now
supported. MIDLE delegates the array concatenation task to an utility program
called `arrayconcat`, which can also be used as standalone program if
interested.


## Documentation


* Limited support for IDL expression evaluation
  + Variables, including limited support of system variables
  + Datatypes Support
    * Numbers (Only decimal, no Hex or Oct): 
        - BYTE (B), INT (default, S), UINT (US), LONG (L), ULONG (UL), LONG64 (LL), ULONG64 (ULL)
    * !NULL
    * FLOAT, DOUBLE (scientific notation included)
    * STRING (single and double quoted)
    * Structure
        - Only anonymous struct (no name, no inherits)
    * List, Hash types are considered as Function calls. 
        - List and Hash are also supported by using extended literal syntax
          (see details in Added Features) 
  + Operators including
    * Mathematical: +, - (unary and binary), *, /, mod, ^
    * Matrix: #, ##
    * Bitwise: or, and, not, xor
    * Logical: &&, ||, ~
    * Relational: EQ, NE, GE, GT, LE, LT
    * Mimimum and Maximum: <, >
    * Others: ?:, [::], (), ., ->
  + Bracket indexing (array, hash)
  + Function calls
    * Up to nine positional arguments and unlimited input keyword arguments
  + Object property access (dot notation) only works for Hash-like objects or structure.

* Incompatible and Additional Features
    * The exponential operator has right associativity in MIDLE but has left
      associativity in IDL.
    * Chaining method calls without extra parenthesis, e.g. a().x(), a.b().x()
    * Chaining subscripts without extra parenthesis, e.g. a[5:*][2:9]
    * Higher level array concatenation. IDL only supports three levels. 
        - For an example, `[[[[1]]],[[[2]]]]` is not allowed by IDL, while it
          is legal for the interpreter and evaluates to a array of shape
          [1,1,1,2]
    * h{key: val, ...} for building Hash literals
    * (val1, val2, ...) for building List literals
        - Note a comma is needed at the end of the list to create an one-element
          list. For an example, (42) is just a integer 42, while (42,) equals to
          list(42)

* Unsupported IDL features
    * Output positional and keyword arguments
    * Compound operators, such as +=, ++ etc.
    * Parenthesis over assignment statement, i.e. a = (b = 42)

