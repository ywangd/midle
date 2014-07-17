# A mini IDL expression interpreter in IDL

* Limited support for IDL expression evaluation
  + Variables, including limited support of system variables
  + Datatypes Support
    * Numbers (Only decimal, no Hex or Oct): 
        - BYTE (B), INT (default, S), UINT (US), LONG (L), ULONG (UL), LONG64 (LL), ULONG64 (ULL)
    * !NULL and its equivalents, e.g. []
    * FLOAT, DOUBLE (scientific notation included)
    * STRING (single and double quoted)
    * STRUCT is not supported as object types are preferred.
    * List, Hash types are considered as Function calls. 
        - Hash is also supported by using extended syntax (see details in Added
          Features)
  + Operators including
    * Mathematical: +, - (unary and binary), *, /, mod, ^
    * Matrix: #, ##
    * Bitwise: or, and, not, xor
    * Logical: &&, ||, ~
    * Relational: EQ, NE, GE, GT, LE, LT
    * Mimimum and Maximum: <, >
    * Others: ?:, [::], (), ., ->
  + Function calls
    * Up to three positional arguments and unlimited input keyword arguments
  + Bracket indexing (array, hash)
    * This can be solved by the ND routines. However it is quite heavy weighted.

* Added (incompatible) Features
    * Chaining method calls without extra paranthesis, e.g. a.b().x()
    * Chaining subscripts without extra paranthesis, e.g. a[5:*][2:9]
    * {key: val, ...} for building Hash literals
    * (val1, val2, ...) for building List literals
