# A mini IDL expression parser in IDL

* Limited support for IDL expression
  + Variables, including system variables
  + Datatypes including: 
    * NULL
    * BYTE (B), INT (default, S), UINT (US), LONG (L), ULONG (UL), LONG64 (LL), ULONG64 (ULL)
    * FLOAT, DOUBLE (scientific notation included)
    * STRING (single and double quoted)
    * NOTE: List, Hash, Object are considered as Function calls. Struct is not
      supported as object types are prefered.
  + Operators including
    * Mathematical: +, - (unary and binary), *, /, mod, ^
    * BItwise: or, and, not, xor
    * Logical: &&, ||, ~
    * Relational: EQ, NE, GE, GT, LE, LT
    * Matrix: #, ##
    * Mimimum and Maximum: <, >
    * Others: ?:, [::], (), ., ->
  + Function calls
    * Positional and keyword type arguments
    * Expression as argument

