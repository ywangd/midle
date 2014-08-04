# MIDLE - A Mini IDL Evaluator in IDL
Evaluate IDL statements and expressions without `EXECUTE`, i.e. virtual machine
safe. It can be an alternative to `EXECUTE` in many cases.

MIDLE implements its own parser and evaluates simple IDL statements and
expressions without resorting to the power of `EXECUTE`. It even adds
[additional language features](#added-features) such as syntax for HASH and LIST
literals, higher level array concatenation, bettering support for chaining
function/method calls and subscripts. 

MIDLE is however not without limitations. Some limitations are due to the limit
of IDL language itself, notably output arguments and object property access
(object method calls are OK). Others are deliberately set by design to meet the
scope of MIDLE, notably program control constructs. Please refer to [Missing
Features](#missing-features) section for details.

MIDLE requires IDL 8.0 or up (8.3 is recommended).

## Motivation
The original motivation came from the wish to use a file containing a list of
IDL assignments as a configuration/input file to IDL packages. This, however,
indicates `EXECUTE` has to be used to process the file, which is not ideal due
to the fact that the IDL virtual machine does not allow `EXECUTE`.

MIDLE is designed to fill the gap. It initially focused only on the
right-hand-side of the `=` sign, i.e. the expression and was later decided to
support full assignment statements as well as procedure calls. It now has a
broader scope than what it was originated from. 
It is even possible to use MIDLE as a simple scripting engine to GUI
applications running in IDL virtual machine and expose some powers of the
underlying IDL language to end users who do not own IDL licenses.

It is also worth to note that MIDLE is not envisioned to be fast or memory
efficient (at least not now). For situations where `EXECUTE` is needed, you
are hardly looking for performance anyway (if you are, you may want to
re-think the design of the program). As a semi-replacement of `EXECUT`, MIDLE is
meant to be flexible and it is pretty good at its own job. In addition, MIDLE
does not re-compile any routines, which means it could be faster than `EXECUTE`
in some situations.

## Installation
1. Get the code from the git repo:

    ```Bash
    $ git clone git@github.com:ywangd/midle.git
    ```

2. Add the `src` folder to your IDL path. This can be done by either setup the
   `IDL_PATH` environment variable, or use the `preference` menu in IDE, or some
   other ways your prefer.

IDL 8.0 or up is required as 8.0 features (e.g. `!NULL`, `Hash`, `List`, `isa`)
are used extensively. Version 8.3 is recommended for the new `Dictionary` class.
A drop-in replacement of the `Dictionary` class is provided with the package so
MIDLE can run with 8.0, 8.1 and 8.2. If you have access to IDL 8.3, remove
`dictionary.pro` to ensure the built-in `Dictionary` class is used.

## Usage
The basic usage is to simply pass a string of IDL statement or expression to
`midle`. Here is the classic Hello World example:
```IDL
print, midle('"Hello, World!"')
```
A procedure interface is also available if the return value is of no interest.
```IDL
midle, 'print, "Hello, World!"'
```

An array of strings can be passed to MIDLE and they will be evaluated in order:
```IDL
midle, ['print, "STAR"', 'print, "WARS"']
```

Multiple statements can be written in one line and separated by `&`:
```IDL
midle, 'print, "STAR" & print, "WARS"'
```


MIDLE also takes a filename and evaluates its content line by line. If `input1`
contains following content:
```IDL
; This line is a comment
print, 'A long time ago ', $
    'in a galaxy far, far away ...'
print, 'STAR'  ; trailing comments 
print, 'WARS'
```

Note that comments and line continuation are both permitted. To evaluate the
file, specify the filename and set the `file` keyword.
```IDL
midle, 'input1', /file
```

An input file can optionally contain other input files by using the `@`
directive. For an example, the content of file `input2` is as follows:
```IDL
print, 'before input1'
@input1
print, 'after input1'
```

The file inclusion can be nested and MIDLE will recursively expand all file
inclusions. The file to be included can be given as relative path as shown above
or as a full qualified path such as `@/home/user/input1`. If file name or path
contains whitespace, double or single quotes can be used as `@"/home/user/input
1"`. Note that expansion of included files is done in a pre-process step and is
not a function of the parser. This also means the `@` directive can only be used
in file input.


A second argument can be used to pass values to variables in the expression.
This argument, called `env` variable for the rest of the document, is the
runtime environment for variable lookup. It can be either a structure or a hash
like object. 
```IDL
env = {num: 50}
print, midle('indgen(2,3,4, start=num)', env)

env = hash('x', 42)
print, midle('indgen(x)', env)
```

Procedure call is supported. Note that a procedure call always returns the
`!NULL` value if the function version of MIDLE is used.
```IDL
print, midle('plot, indgen(50, start=100), /ynozero')
```
Alternatively, the procedure version can be used:
```IDL
midle, 'plot, indgen(50, start=100), /ynozero'
```


Almost all arithmetic, logical, bitwise, relational, matrix, ternary operators
are supported. The exceptions are compound operators such as `++`, `+=` and
pointer de-reference `*pointer`.
```IDL
print, midle('-2.2 - 2 mod ((42. + 22) ^ 2 > 3 - 4.2) * 2.2 / 2.4')

env = {x: 42}
print, midle('x eq 42 ? indgen(5, start=x) : indgen(5)', env)
```

Assignments are supported. Note that all variable creation and modification is
done against the `env` variable, not to the scope where MIDLE is called (unlike
`EXECUTE`). 
For an example, the following code creates a variable `x` in the `env` variable,
if the `env` variable itself is not defined, it will be created by MIDLE.
```IDL
print, midle('x = 42', env)
print, env.x  ; output 42

print, midle('h = Hash()', env)
print, midle('h["a"] = indgen(3,4,5)', env)
print, midle('h["a", 0, 1, 2] = 420', env)
print, (env.a)[0,1,2]  ; output 420
```

List literal is written by list the items inside a pair of parenthesis:
```IDL
print, midle('("this", "is", "a", "list", "literal", 42)')
```

Hash literal is written in a way similar to IDL structure, but prefixing a
letter `h` before the left curly bracket. In addition, the keys must be either
string or number.
```IDL
print, midle('h{"x": 42, "y": 22, "description": "This is a hash literal"}')
```

Nested list and hash:
```IDL
print, midle('(4.2d3, "String", "A Hash next", h{"x": 4.2, "y": 2.2})')
```

Higher level array concatenation:
```IDL
env = {a: indgen(6,5,4,3,2), b: indgen(6,5,4,3,2, start=720)}
help, midle('[ [[[[a]]]], [[[[b]]]] ]', env)  ; concatenate on the 5th dimension
```

Function/method calls and subscripts can be chained without the need of extra
pairs of parenthesis (as expected in other modern languages): 
```IDL
print, midle('indgen(10)[0:*:2]')
print, midle('list(indgen(3,4,5,6)[*,0:3:2,4,*][2,*,0,0:5:2], /extract).count()')
```

Subscripts and dot notations can be chained for the left-hand-side variable of
assignment statements as well. This allows direct assignment to list items
where the list itself is inside an array:
```IDL
midle, 'b = [(1,2,3), (4,5,6), h{}, (7,8,9)]', env
midle, 'b[1][1] = 42', env
midle, 'b[2]["st"] = {x: indgen(3,4,5), y: 42, z: indgen(3,5)}', env
midle, 'b[2]["st"].x[1,2,3] = 99', env
```

The `ast` output keyword can be used to obtain the Abstract Syntax Tree object
of the given statements/expressions.
```IDL
print, midle('-2.2 - 2 mod 42. + 22 ^ 2 > 3 - 4.2 * 2.2 / 2.4', ast=ast)
```

You can print the `ast` object (`print, ast`) to get a hierarchical view of the
syntax tree.
```
STMTLIST
  +-- BINOP 'T_SUB'
        +-- BINOP 'T_MAX'
              +-- BINOP 'T_ADD'
                    +-- BINOP 'T_SUB'
                          +-- UNARYOP 'T_SUB'
                                +-- NUMBER '2.2'
                          +-- BINOP 'T_MOD'
                                +-- NUMBER '2'
                                +-- NUMBER '42.'
                    +-- BINOP 'T_EXP'
                          +-- NUMBER '22'
                          +-- NUMBER '2'
              +-- NUMBER '3'
        +-- BINOP 'T_DIV'
              +-- BINOP 'T_MUL'
                    +-- NUMBER '4.2'
                    +-- NUMBER '2.2'
              +-- NUMBER '2.4'
```

You can also evaluate the `ast` object to get the result again.
```IDL
print, ast.eval()
```

The `error` output keyword can be used to check whether the call to MIDLE is
successful. It will be `!NULL` if the call succeeds. Or it will be a string
containing the error message.
```IDL
print, midle('42 + a', error=error)  ; varaible a is undefined
```
The content of `error` is now `MIDLE_RUNTIME_ERR - Undefined variable: a`.

A demo GUI application is also available to showcase how MIDLE can run
interactively in IDL virtual machine. The entry routine of the GUI application
is named **MAIN**, which runs automatically in IDL virtual machine. 

## <a name="missing-features"></a>Missing Features
The missing features fall into two broad categories. The first category is *By
Design* which means they are deliberately left out to narrow the scope of MIDLE
so it can focus on more important tasks. The second category is a result of
IDL's own limitations and cannot be technically circumvented (please let me
know if there are ways to add them). 

### By Design
- Program control constructs are not supported. This means no support for
  `IF...THEN...ELSE`, `CASE`, `SWITCH`, `WHILE`, `REPEAT`, `FOR`, `FOREACH`,
  `GOTO`, etc.
- No support for routine definitions, i.e. `PRO`, `FUNCTION` (`EXECUTE` does not
  support them either).
- Hex and Oct literals are not supported
- Only anonymous structure is supported. This means no named structure, no
  inheritance.
- Compound operators are not supported, i.e. `++`, `--`, `+=`, `-=`, etc.
- Pointer de-reference is not supported, i.e. `*pointer`
- The `->` operator is not supported as most times it can be replaced by `.`
- Creation and assignment of system variables are not supported (their values
  are readable)
- Parenthesis over assignment statement are not supported, i.e. `x = (y = 42)`
- Variable name cannot have the `$` character

### By IDL's limitations
- Output positional and keyword arguments are not supported (I really wanted to
  support these. But it is just impossible in IDL.)
- Object property access using dot notation, i.e. `object.property` are not
  supported
    * The dot notation can be used with Hash like object to get the value by
      using the property's name as the key, i.e. `someHash.x` is equal to
      `someHash['x']`
- Up to nine positional arguments and unlimited input keyword arguments are
  supported
- Cannot obtain values for user defined system variables (built-in system
  variables are OK)


## <a name="added-features"></a>Added Features
Valid MIDLE expressions are mostly valid IDL expression as well. However, there
are a few exceptions due to MIDLE's added features. User can easily choose to
not use them or use parenthesis to enforce IDL's default behaviours. Many of the
added features are inspired by the [Python](https://www.python.org/) language.

### List literal
List literals can be written the same way as tuples in Python, i.e.
`(42,"xyz")` is equal to `list(42,"xyz")`. Note a trailing comma is needed to
create a single element list, i.e. `(42,)` creates a single-element list, while
`(42)` is just a scalar number 42. A pair of empty parenthesis, `()`, creates an
empty list.

### Hash literal
Hash literals can be written using a variant of structure literal by prefixing a
letter `h` to the left curly bracket, i.e. `h{}` creates an empty Hash and is
equal to `hash()`. The keys to hash literals must be either string or number,
i.e.  `h{"x": 4.2, 5: "y"}` is equal to `hash("x", 4.2, 5, "y")`.

### Higher level of array concatenation
IDL only supports up to three level of brackets for performing array
concatenation while an array can have up to eight dimensions. This means `[
[[a]], [[b]] ]` is legal in IDL for concatenating array on the third dimension,
while `[ [[[a]]], [[[b]]] ]` yields an error while trying concatenating on the
fourth dimension. 

This limitation is lifted in MIDLE. Up to eight level of brackets is now
supported. MIDLE delegates the array concatenation task to an utility program
called `arrayconcat`, which can also be used as standalone program.

### Better support for chaining function/method calls and subscripts
Parenthesis are often required in IDL if you want to chain a few calls and
subscripts. For an example, say we have a hash variable `h` as `hash('x',3,
'y',5,'z',3)`, the expression `h.where(3)[0]` is illegal in IDL. To chain the
method call and subscript, an extra pair of parenthesis has to be used like
`(h.where(3))[0]`. Now let's try `h.where(3).count()`. Apparently it is illegal
in IDL. However even after adding extra pair of parenthesis,
`(h.where(3)).count()`, the expression is still invalid (error message is
`Subscripts are not allowed with object properties`).

With MIDLE, it is legal to write chaining calls and subscripts without the
eye-irritating parenthesis. It is more in line with other modern languages like
Python.

### Associativity of the power operator
The power operator, `^`, has right associativity in MIDLE, while it has left
associativity in IDL. This means an expression of `2^3^2` equals to `2^(3^2)`
in MIDLE, but equals to `(2^3)^2` in IDL. 
I think it is more common for this operator to have right associativity, as in
FORTRAN and Python. If you don't like this behaviour, use parenthesis to enforce
associativity.

## Documentation
[IDLdoc](https://github.com/mgalloy/idldoc) is used for code level documentation
(not much yet). The documentation can be generated by running `midledoc` in the
`docs` folder (`mg_src_root` from [mglib](https://github.com/mgalloy/mglib) is
required).

## Testing
[mgunit](https://github.com/mgalloy/mgunit) is used for testing. Add the `test`
folder in your IDL path and run `mgunit, 'midle_ut'` (`mg_src_root` is required
as well). The unit test file has some more example ussages of MIDLE.


## Known issues
* File inclusion leads to incorrect line number for error report. 

## Contributing
- Check any open issues or open a new issue to start discussions about your
  ideas of features and/or bugs
- Fork the repository, make changes, and send pull requests


