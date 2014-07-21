# A Mini IDL Expression Evaluator (MIDLE) in IDL

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
    * Chaining method calls without extra paranthesis, e.g. a().x(), a.b().x()
    * Chaining subscripts without extra paranthesis, e.g. a[5:*][2:9]
    * Higher level array concatenation. IDL only supports three levels. 
        - For an example, `[[[[1]]],[[[2]]]]` is not allowed by IDL, while it
          is legal for the interpreter and evaluates to a array of shape
          [1,1,1,2]
    * {key: val, ...} for building Hash literals
    * (val1, val2, ...) for building List literals
        - Note a comma is needed at the end of the list to create an one-element
          list. For an example, (42) is just a integer 42, while (42,) equals to
          list(42)

* Unsupported IDL features
    * Output positional and keyword arguments
    * Compound operators, such as +=, ++ etc.
    * Parenthesis over assignment statement, i.e. a = (b = 42)

