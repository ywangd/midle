# MIDLE - A Mini IDL Statement Evaluator in IDL
Evaluate IDL statements without `EXECUTE`, i.e. virtual machine safe. It is
*almost* a replacement of `EXECUTE`.

MIDLE implements its own parser and evaluates broad categories of IDL statements
without resorting to the power of `EXECUTE`. It even adds additional language
features such as syntax for HASH and LIST literals, higher level array
concatenation, bettering support for chaining function/method calls and
subscripts. It does, however, has limitations due to the limit of IDL language
itself, notably output arguments and object property access (object method
calls are OK). It also deliberately leaves out some IDL features by design.

MIDLE requires IDL 8.0 or up (8.3 is recommended).

## Motivation
A file containing a list of IDL assignment statements is a good candidate as a
input or configuration file to IDL packages. This, however, indicates `EXECUTE`
has to be used to process the file, which is not desirable due to the fact that
`EXECUTE` cannot run in IDL virtual machines.

MIDLE is designed to fill the gap. It first starts by focusing only the right
hand side of the `=` sign, i.e. the expression. I later decided to support full
assignment statements as well as procedure calls. It now has a much broader scope
than what it is originated from.

It is also worth to note that MIDLE is not envisioned to be fast or memory
efficient (at least not now). For situations where `EXECUTE` is needed, you
are hardly looking for performance anyway (if you are, you may want to
re-think the design of the program). As a semi-replacement of `EXECUT`, MIDLE 
is meant to be flexible and it is pretty good at its own job.

## Installation
1. Get the code from the git repo:

    ```Bash
    $ git clone git@github.com:ywangd/midle.git
    ```

2. Add the `src` folder to your IDL path. This can be done by setup the
   `IDL_PATH` environment variable, or use the `preference` menu in IDE, or some
   other ways your prefer.

IDL 8.0 or up is required as 8.0 features (e.g. `!NULL`, `Hash`, `List`, `isa`)
are used extensively in the code. Version 8.3 is recommended for the new
`Dictionary` class. However, a drop-in replacement of `Dictionary` class is
provided with the package so MIDLE can be used with 8.0, 8.1 and 8.2. If you
have IDL 8.3, it is recommended to remove the `dictionary__define.pro` file to
ensure the built-in `Dictionary` class is used.

## Usage
To use MIDLE, simply pass a string of IDL statement or expression to the
function `midle`. Here is the classic Hello World example:
```IDL
print, midle('"Hello, World!"')
```

The second argument can be used to pass values to variables in the expression.
This argument, named as `env` variable for the rest of the article, represents
the runtime environment for variables. It can be either a structure or a hash
like object. 
```IDL
env = {num: 50}
print, midle('indgen(2,3,4, start=num)', env)

env = hash('x', 42)
print, midle('indgen(x)', env)
```

Procedure call is supported. Note that a procedure call always returns the
`!NULL` value.
```IDL
print, midle('plot, indgen(50, start=100), /ynozero')
```

Almost all arithmetic, logical, bitwise, relational, matrix, ternary operators
are supported. The exceptions are compound operators such as `++`, `+=`.
```IDL
print, midle('-2.2 - 2 mod ((42. + 22) ^ 2 > 3 - 4.2) * 2.2 / 2.4')

env = {x: 42}
print, midle('x eq 42 ? indgen(5, start=x) : indgen(5)', env)
```

Assignments are supported. Note that all variable creation and modification is
done against the `env` variable, not to the scope where MIDLE is called. 
For an example, the following code creates a variable `x` in the `env` variable,
if the `env` variable itself is not defined, it will be created by the code.
```IDL
print, midle('x = 42', env)
print, env.x  ; output 42

print, midle('h = Hash()', env)
print, midle('h["a"] = indgen(3,4,5)', env)
print, midle('h["a", 0, 1, 2] = 420', env)
print, (env.a)[0,1,2]  ; output 420
```

List literal
```IDL
print, midle('("this", "is", "a", "list", "literal", 42)')
```

Hash literal
```IDL
print, midle('h{"x": 42, "y": 22, "description": "This is a hash literal"}')
```

Nested list and hash
```IDL
print, midle('(4.2d3, "String", "A Hash next", h{"x": 4.2, "y": 2.2})')
```

Chaining
```IDL
print, midle('list(indgen(10)[0:*:2][2:4], /extract).count()')
```

Higher level array concatenation
```IDL
env = {a: indgen(6,5,4,3,2), b: indgen(6,5,4,3,2, start=720)}
help, midle('[ [[[[a]]]], [[[[b]]]] ]', env)
```

## Missing Features
The missing features fall into two categories. The first category is *By Design*
that means they are deliberately left out to narrow the scope of MIDLE so it can
focus on more important targets. Alternatives can be found for most of them. The
second category is caused by IDL's limitations and cannot be technically
overcome (please let me know if there are ways to add them). 

### By Design
- Hex and Oct literals not supported
- Only anonymous structure is supported. This means no named structure, no
   inheritance.
- Compound operators not supported, i.e. `++`, `--`, `+=`, `-=`, etc.
- Pointer and pointer de-reference not supported, i.e. `*pointer`
- The `->` operator not supported as most times it can be replaced by `.`
- Creation and assignment of system variables
- Parenthesis over assignment statement not supported, i.e. `x = (y = 42)`

### By IDL's limitations
- Output positional and keyword arguments not supported
- Object property access using dot notation, i.e. `object.property`
    * The dot notation can be used with Hash like object to get the value of
        using property's name as a key, i.e. `someHash.x` is equal to
        `someHash['x']`
- Up to nine positional arguments and unlimited input keyword arguments are
    supported
- Cannot obtain values for user defined system variables (built-in system
  variables are OK)


## Added Features (Incompatibility)
Valid MIDLE expressions are mostly valid IDL expression as well. However, there
are a few exceptions due to MIDLE's added features. User can easily choose to
not use them or use parenthesis to enforce IDL's default behaviours. Many of the
added features are inspired by [Python](https://www.python.org/).

### List literal
List literals can be written the same way as tuples in Python, i.e.
`(42,"xyz")` is equal to `list(42,"xyz")`. Note a trailing comma is needed to
create a single element list, i.e. `(42,)` creates a one-element list, while
`(42)` is just a scalar number 42. A pair of empty parenthesis, `()`, creates an
empty list.

### Hash literal
Hash literals can be written using a variant of structure literal by prefixing a
letter `h` to the left curly bracket, i.e. `h{}` creates an empty Hash and is
equal to `hash()`. The keys to hash literals must be string or number, i.e.
`h{"x": 4.2, 5: "y"}` is equal to `hash("x", 4.2, 5, "y")`.

### Higher level of array concatenation
IDL only supports up to three level of brackets for performing array
concatenation while an array can have up to eight dimensions. This means `[
[[a]], [[b]] ]` is legal in IDL for concatenating array on the third dimension,
while `[ [[[a]]], [[[b]]] ]` yields an error while trying concatenating on the
fourth dimension. 

This limitation is lifted in MIDLE. Up to eight level of brackets is now
supported. MIDLE delegates the array concatenation task to an utility program
called `arrayconcat`, which can also be used as standalone program.

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

### Associativity of the power operator
The power operator, `^`, has right associativity in MIDLE, while it has left
associativity in IDL. This means an expression of `2^3^2` equals to `2^(3^2)`
in MIDLE, but equals to `(2^3)^2` in IDL. 
I think it is more common for this operator to have right associativity, as in
FORTRAN and Python. If you don't like this behaviour, use parenthesis to enforce
associativity.


## Known issues


## Contributing
- Check any open issues or open a new issue to start discussions about your
  ideas of features and/or bugs
- Fork the repository, make changes, and send pull requests


