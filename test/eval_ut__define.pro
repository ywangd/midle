
function array_equal_exact, a1, a2
    return, array_equal(a1, a2) and (array_equal(size(a1), size(a2))) 
end

function Eval_ut::test_datatypes
    assert, isa(eval('42B'), 'BYTE'), 'BYTE'
    assert, isa(eval('42'), 'INT'), 'INT'
    assert, isa(eval('42S'), 'INT'), 'INT'
    assert, isa(eval('42U'), 'UINT'), 'UINT'
    assert, isa(eval('42US'), 'UINT'), 'UINT'
    assert, isa(eval('42L'), 'LONG'), 'LONG'
    assert, isa(eval('42UL'), 'ULONG'), 'ULONG'
    assert, isa(eval('42LL'), 'LONG64'), 'LONG64'
    assert, isa(eval('42ULL'), 'ULONG64'), 'ULONG64'
    assert, isa(eval('42.0'), 'FLOAT'), 'FLOAT'
    assert, isa(eval('42.E'), 'FLOAT'), 'FLOAT'
    assert, isa(eval('42D'), 'DOUBLE'), 'DOUBLE'
    assert, isa(eval('42.E3'), 'FLOAT'), 'FLOAT scientific'
    assert, isa(eval('42.D3'), 'DOUBLE'), 'DOUBLE scientific'
    assert, isa(eval('.42D+3'), 'DOUBLE'), 'DOUBLE scientific +'
    assert, isa(eval('42.D-3'), 'DOUBLE'), 'DOUBLE scientific -'

    assert, isa(eval('"Hello"'), 'STRING'), 'STRING'
    assert, isa(eval('!NULL'), 'UNDEFINED'), 'UNDEFINED'
    assert, isa(eval('[]'), 'UNDEFINED'), 'UNDEFINED'
    assert, isa(eval('{}'), 'UNDEFINED'), 'UNDEFINED'
    assert, isa(eval('{x:42}'), 'STRUCT'), 'STRUCT'
    assert, isa(eval('()'), 'LIST'), 'LIST'
    assert, isa(eval('h{}'), 'HASH'), 'HASH'

    return, 1
end

function Eval_ut::test_dimension

    assert, isa(eval('1'), /scalar) eq 1, 'Scalar'
    assert, array_equal(size(eval('[1]'), /dim), [1]), 'Single element vector'
    
    assert, array_equal(size(eval('[1,2,3,4]'), /dim), [4]), 'Horizontal vector'
    
    assert, array_equal(size(eval('[[1],[2]]'), /dim), [1,2]), 'Vertical vector'
    
    assert, array_equal(size(eval('[[[1]]]'), /dim), [1]), 'Redundant brakcets (concatenate to !NULL)'
    assert, array_equal(size(eval('[ [[0,1],[2,3],[5,6]] ]'), /dim), [2,3]), 'Redundant brackets'
    assert, array_equal(size(eval('[ [[[[1]]]], [2] ]'), /dim), [1,2]), 'Redundant brackets'
    
    assert, array_equal(size(eval('[ [[1]], [[2]] ]'), /dim), [1,1,2]), 'Three level concatenation'
    assert, array_equal(size(eval('[ [[[1]]], [[[2]]] ]'), /dim), [1,1,1,2]), 'Four level concatenation'
    
    assert, array_equal(size(eval('[[1,2,3], [3,4,5]]'), /dim), [3,2]), '3x2'
    
    assert, array_equal( $
        size(eval('[[[0,1],[2,3],[4,5]],[[6,7],[8,9],[10,11]],[[12,13],[14,15],[16,17]],[[18,19],[20,21],[22,23]]]'), /dim), $
        [2,3,4]), $
        '2x3x4'
        
    assert, array_equal( $
        size(eval('[ [[0,1],[2,3],[5,6]], [8,9] ]'), /dim), $
        [2,4]), $
        'Seemingly wierd'
    
    assert, array_equal( $
        size(eval('[ [8,9], [[0,1],[2,3],[5,6]] ]'), /dim), $
        [2,4]), $
        'Seemingly wierd'

    assert, array_equal( $
        size(eval('[ [[1,2]], [[3,4]] ]'), /dim), $
        [2,1,2]), $
        'Three level concatenation'
        
    assert, array_equal( $
        size(eval('[ [[[1,2]]],[[[3,4]]] ]'), /dim), $
        [2,1,1,2]), $
        'Four level concatenation'
    
    return, 1
end

function Eval_ut::test_subscripts
    a = lindgen(5,4,3,2)
    env = Hash('a', a)
    
    assert, array_equal_exact(eval('a[42]', env), a[42])
    assert, array_equal_exact(eval('a[[22,42,24]]', env), a[[22,42,24]])
    assert, array_equal_exact(eval('a[*]', env), a[*])
    assert, array_equal_exact(eval('a[1:15]', env), a[1:15])
    assert, array_equal_exact(eval('a[3:110:3]', env), a[3:110:3])
    
    assert, array_equal_exact(eval('a[[1,2],[1,2]]', env), a[[1,2],[1,2]])
    assert, array_equal_exact(eval('a[[1,2],[1,2],0]', env), a[[1,2],[1,2],0])
    assert, array_equal_exact(eval('a[[1,2],[1,2],*]', env), a[[1,2],[1,2],*])
    assert, array_equal_exact(eval('a[[1,2],[1,2],0:2,*]', env), a[[1,2],[1,2],0:2,*])
    
    assert, array_equal_exact(eval('a[0:4:2,*,[0,2],*]', env), a[0:4:2,*,[0,2],*])
    
    a = hash("x", hash("q", indgen(3,4), "r", list(5, indgen(3,4,5,start=90),7)), "y", 2, "z", list(3, 4, indgen(3,4,5),8,[list('h','e'),list('w','d')])) 
    env = Hash('a', a)
    assert, eval('a["x","r",1,2,3]', env) eq a["x","r",1,2,3]
    
    assert, array_equal_exact(eval('a["x","r",1,*]', env), a["x","r",1,*])
    
    assert, array_equal_exact(eval('a["x","r",1,1:2,1:3]', env), a["x","r",1,1:2,1:3])
    
    assert, array_equal_exact(eval('a["x","r",1,5:25]', env), a["x","r",1,5:25])
    
    assert, array_equal_exact(eval('a["x","r",1,1:2,1:3,0:3:2]', env), a["x","r",1,1:2,1:3,0:3:2])
    
    assert, array_equal_exact(eval('a["x","r",1,[1,2],[2,3]]', env), a["x","r",1,[1,2],[2,3]])
    
    assert, array_equal_exact(eval('a["x","r",1,[1,2],[2,3],*]', env), a["x","r",1,[1,2],[2,3],*])
    
    assert, min(eval('a["z",4,0]', env) eq a["z",4,0]) eq 1

    return, 1
end

function Eval_ut::test_values

    assert, eval('42b') eq 42b
    assert, eval('42') eq 42
    assert, eval('42s') eq 42s
    assert, eval('42u') eq 42u
    assert, eval('42us') eq 42us
    assert, eval('42l') eq 42l
    assert, eval('42uL') eq 42uL
    assert, eval('42ll') eq 42ll
    assert, eval('42ull') eq 42ull
    assert, eval('42.') eq 42.
    assert, eval('42.42') eq 42.42
    assert, eval('.42') eq .42
    assert, eval('42.e3') eq 42.e3
    assert, eval('42.d-3') eq 42.d-3
    assert, eval("'Hello'") eq 'Hello'
    assert, eval("'Hello ""'") eq "Hello """
    assert, eval("'Hello '''") eq 'Hello ''', 'Single quote escape'
    assert, eval('"Hello """') eq "Hello """, 'Double quote escape'
    assert, eval('!PI') eq !PI

    assert, array_equal(eval('[42]'), [42]), 'Single integer vector'
    assert, array_equal(eval('[42, 42.42]'), [42, 42.42]), 'Mixed float vector'
    assert, array_equal(eval('["Hello", "World"]'), ["Hello", "World"]), 'String array'
    
    assert, array_equal_exact($
        eval('[[[0,1],[2,3],[4,5]],[[6,7],[8,9],[10,11]],[[12,13],[14,15],[16,17]],[[18,19],[20,21],[22,23]]]'), $
        indgen(2,3,4)), $
        '3D array'
    
    assert, array_equal_exact( $
        eval('[ [[0,1],[2,3],[5,6]], [8,9] ]'), $
        [ [[0,1],[2,3],[5,6]], [8,9] ]), $
        'Seemingly weird'
     
    st = eval('{x: 42.0, y: "Hello", z: 42}')   
    assert, isa(st, 'Struct') && st.x eq 42.0 && st.y eq 'Hello' && st.z eq 42
    
    assert, min(eval('(42, "Hello")') eq list(42, "Hello")) eq 1, 'List values'
    assert, n_elements(eval('h{"x": 42.0, 42: "Hello", "Y": 42}') eq hash("x", 42.0, 42, "Hello", "Y", 42)) eq 3, $
        'Hash values'

    return, 1
end

function Eval_ut::test_arith
    assert, eval('42 + 22') eq 42 + 22
    assert, eval('42 - 22') eq 42 - 22
    assert, eval('42 * 22') eq 42 * 22
    assert, eval('42 / 22.') eq 42 / 22.
    assert, eval('42 mod 22') eq 42 mod 22
    assert, eval('1 ? 42 : 22') eq (42 eq 42 ? 42 : 22)
    assert, eval('0 ? 42 : 22') eq (42 eq 22 ? 42 : 22)
    assert, eval('42 > 22') eq (42 > 22)
    assert, eval('42. < 22') eq (42. < 22)
    assert, eval('4^2') eq 4^2
    assert, eval('-42.') eq -42.
    assert, eval('+42.') eq +42.
    assert, eval('--42') eq 42
    assert, eval('-+42') eq -42

    assert, eval('-2.2 - 2 mod 42. + 22 ^ 2 > 3 - 4.2 * 2.2 / 2.4') eq (-2.2 - 2 mod 42. + 22 ^ 2 > 3 - 4.2 * 2.2 / 2.4), $
        'Arith operator precedence'
    assert, eval('-2.2 - 2 mod ((42. + 22) ^ 2 > 3 - 4.2) * 2.2 / 2.4') eq (-2.2 - 2 mod ((42. + 22) ^ 2 > 3 - 4.2) * 2.2 / 2.4), $
        'Arith operator precedence with parentheis'

    assert, array_equal_exact($
        eval('[2.2, 4.2, 42] + [4.2, 22, .42] * [0.22, 22.22, 4.222]'), $
        [2.2, 4.2, 42] + [4.2, 22, .42] * [0.22, 22.22, 4.222]), $
        'Arith operators on vectors'

    assert, array_equal_exact($
        eval('([2.2, 4.2, 42] + [4.2, 22, .42]) * [0.22, 22.22, 4.222]'), $
        ([2.2, 4.2, 42] + [4.2, 22, .42]) * [0.22, 22.22, 4.222]), $
        'Arith operators on vectors with parenthesis'

    return, 1
end

function Eval_ut::test_funccall
    assert, array_equal_exact(eval('indgen(3,4,5)'), indgen(3,4,5))
    assert, array_equal_exact(eval('sindgen(3,4,5, start=10)'), sindgen(3,4,5, start=10))
    assert, array_equal_exact(eval('dist(10,10)'), dist(10,10)) 
    assert, eval('a.count()', {a: list(1,2,3,4,5)}) eq 5
    assert, eval('a.where(5)[0]', {a: list(1,2,3,4,5)}) eq 4 
    
    return, 1
end

function Eval_ut::test_member
    assert, eval('a.x', {a: Hash("x", 42, "y", 22)}) eq 42
    assert, eval('h{"x": 42, "y": 22}.x') eq 42
    assert, eval('Dictionary("x", 42, "y", 22).x') eq 42
    assert, eval('a.x', {a: {x: 42, y: 22}}) eq 42
    assert, eval('{x: 42, y: 22}.x') eq 42
    
    return, 1
end


pro Eval_ut__define, class
    class = { Eval_ut, inherits MGutTestCase }
end
