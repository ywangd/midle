; docformat = 'rst'

;+
; Unit tests for MIDLE.
; 
; :Author:
; 	Yang Wang (ywangd@gmail.com)
;-


function array_equal_exact, a1, a2
    return, array_equal(a1, a2) and (array_equal(size(a1), size(a2))) 
end

function Midle_ut::test_datatypes
    assert, isa(midle('42B'), 'BYTE'), 'BYTE'
    assert, isa(midle('42'), 'INT'), 'INT'
    assert, isa(midle('42S'), 'INT'), 'INT'
    assert, isa(midle('42U'), 'UINT'), 'UINT'
    assert, isa(midle('42US'), 'UINT'), 'UINT'
    assert, isa(midle('42L'), 'LONG'), 'LONG'
    assert, isa(midle('42UL'), 'ULONG'), 'ULONG'
    assert, isa(midle('42LL'), 'LONG64'), 'LONG64'
    assert, isa(midle('42ULL'), 'ULONG64'), 'ULONG64'
    assert, isa(midle('42.0'), 'FLOAT'), 'FLOAT'
    assert, isa(midle('42.E'), 'FLOAT'), 'FLOAT'
    assert, isa(midle('42D'), 'DOUBLE'), 'DOUBLE'
    assert, isa(midle('42.E3'), 'FLOAT'), 'FLOAT scientific'
    assert, isa(midle('42.D3'), 'DOUBLE'), 'DOUBLE scientific'
    assert, isa(midle('.42D+3'), 'DOUBLE'), 'DOUBLE scientific +'
    assert, isa(midle('42.D-3'), 'DOUBLE'), 'DOUBLE scientific -'
    
    assert, isa(midle('32768'), 'LONG'), 'Auto promoting to LONG'
    assert, isa(midle('2147483648'), 'LONG64'), 'Auto promoting to LONG64'
    
    assert, isa(midle('65536u'), 'ULONG'), 'Auto promoting to ULONG'
    assert, isa(midle('4294967296u'), 'ULONG64'), 'Auto promoting to ULONG64'

    assert, isa(midle('"Hello"'), 'STRING'), 'STRING'
    assert, isa(midle('!NULL'), 'UNDEFINED'), 'UNDEFINED'
    assert, isa(midle('[]'), 'UNDEFINED'), 'UNDEFINED'
    assert, isa(midle('{}'), 'UNDEFINED'), 'UNDEFINED'
    assert, isa(midle('{x:42}'), 'STRUCT'), 'STRUCT'
    assert, isa(midle('()'), 'LIST'), 'LIST'
    assert, isa(midle('h{}'), 'HASH'), 'HASH'

    return, 1
end

function Midle_ut::test_dimension

    assert, isa(midle('1'), /scalar) eq 1, 'Scalar'
    assert, array_equal(size(midle('[1]'), /dim), [1]), 'Single element vector'
    
    assert, array_equal(size(midle('[1,2,3,4]'), /dim), [4]), 'Horizontal vector'
    
    assert, array_equal(size(midle('[[1],[2]]'), /dim), [1,2]), 'Vertical vector'
    
    assert, array_equal(size(midle('[[[1]]]'), /dim), [1]), 'Redundant brakcets (concatenate to !NULL)'
    assert, array_equal(size(midle('[ [[0,1],[2,3],[5,6]] ]'), /dim), [2,3]), 'Redundant brackets'
    assert, array_equal(size(midle('[ [[[[1]]]], [2] ]'), /dim), [1,2]), 'Redundant brackets'
    
    assert, array_equal(size(midle('[ [[1]], [[2]] ]'), /dim), [1,1,2]), 'Three level concatenation'
    assert, array_equal(size(midle('[ [[[1]]], [[[2]]] ]'), /dim), [1,1,1,2]), 'Four level concatenation'
    
    assert, array_equal(size(midle('[[1,2,3], [3,4,5]]'), /dim), [3,2]), '3x2'
    
    assert, array_equal( $
        size(midle('[[[0,1],[2,3],[4,5]],[[6,7],[8,9],[10,11]],[[12,13],[14,15],[16,17]],[[18,19],[20,21],[22,23]]]'), /dim), $
        [2,3,4]), $
        '2x3x4'
        
    assert, array_equal( $
        size(midle('[ [[0,1],[2,3],[5,6]], [8,9] ]'), /dim), $
        [2,4]), $
        'Seemingly wierd'
    
    assert, array_equal( $
        size(midle('[ [8,9], [[0,1],[2,3],[5,6]] ]'), /dim), $
        [2,4]), $
        'Seemingly wierd'

    assert, array_equal( $
        size(midle('[ [[1,2]], [[3,4]] ]'), /dim), $
        [2,1,2]), $
        'Three level concatenation'
        
    assert, array_equal( $
        size(midle('[ [[[1,2]]],[[[3,4]]] ]'), /dim), $
        [2,1,1,2]), $
        'Four level concatenation'
    
    return, 1
end

function Midle_ut::test_subscripts
    a = lindgen(5,4,3,2)
    env = Hash('a', a)
    
    assert, array_equal_exact(midle('a[42]', env), a[42]), '1'
    assert, array_equal_exact(midle('a[[22,42,24]]', env), a[[22,42,24]]), '2'
    assert, array_equal_exact(midle('a[*]', env), a[*]), '3'
    assert, array_equal_exact(midle('a[1:15]', env), a[1:15]), '4'
    assert, array_equal_exact(midle('a[3:110:3]', env), a[3:110:3]), '5'
    
    assert, array_equal_exact(midle('a[[1,2],[1,2]]', env), a[[1,2],[1,2]]), '6'
    assert, array_equal_exact(midle('a[[1,2],[1,2],0]', env), a[[1,2],[1,2],0]), '7'
    assert, array_equal_exact(midle('a[[1,2],[1,2],*]', env), a[[1,2],[1,2],*]), '8'
    assert, array_equal_exact(midle('a[[1,2],[1,2],0:2,*]', env), a[[1,2],[1,2],0:2,*]), '9'
    
    assert, array_equal_exact(midle('a[0:4:2,*,[0,2],*]', env), a[0:4:2,*,[0,2],*]), '10'
    
    assert, array_equal_exact(midle('a[0:4:2,*,1,*,0,0,0,0]', env), a[0:4:2,*,1,*,0,0,0,0]), '11'
    assert, array_equal_exact(midle('a[0:4:2,*,1,*,0,*,0:0,0:-1]', env), a[0:4:2,*,1,*,0,*,0:0,0:-1]), '11'
    
    a = hash("x", hash("q", indgen(3,4), "r", list(5, indgen(3,4,5,start=90),7)), "y", 2, "z", list(3, 4, indgen(3,4,5),8,[list('h','e'),list('w','d')]))
    env = Hash('a', a)
    assert, midle('a["x","r",1,2,3]', env) eq a["x","r",1,2,3], '12'
    
    assert, array_equal_exact(midle('a["x","r",1,*]', env), a["x","r",1,*]), '13'
    
    assert, array_equal_exact(midle('a["x","r",1,1:2,1:3]', env), a["x","r",1,1:2,1:3]), '14'
    
    assert, array_equal_exact(midle('a["x","r",1,5:25]', env), a["x","r",1,5:25]), '15'
    
    assert, array_equal_exact(midle('a["x","r",1,1:2,1:3,0:3:2]', env), a["x","r",1,1:2,1:3,0:3:2]), '16'
    
    assert, array_equal_exact(midle('a["x","r",1,[1,2],[2,3]]', env), a["x","r",1,[1,2],[2,3]]), '17'
    
    assert, array_equal_exact(midle('a["x","r",1,[1,2],[2,3],*]', env), a["x","r",1,[1,2],[2,3],*]), '18'
    
    assert, min(midle('a["z",4,0]', env) eq a["z",4,0]) eq 1, '19'

    return, 1
end

function Midle_ut::test_values

    assert, midle('42b') eq 42b
    assert, midle('42') eq 42
    assert, midle('42s') eq 42s
    assert, midle('42u') eq 42u
    assert, midle('42us') eq 42us
    assert, midle('42l') eq 42l
    assert, midle('42uL') eq 42uL
    assert, midle('42ll') eq 42ll
    assert, midle('42ull') eq 42ull
    assert, midle('42.') eq 42.
    assert, midle('42.42') eq 42.42
    assert, midle('.42') eq .42
    assert, midle('42.e3') eq 42.e3
    assert, midle('42.d-3') eq 42.d-3
    assert, midle("'Hello'") eq 'Hello'
    assert, midle("'Hello ""'") eq "Hello """
    assert, midle("'Hello '''") eq 'Hello ''', 'Single quote escape'
    assert, midle('"Hello """') eq "Hello """, 'Double quote escape'
    assert, midle('!PI') eq !PI

    assert, array_equal(midle('[42]'), [42]), 'Single integer vector'
    assert, array_equal(midle('[42, 42.42]'), [42, 42.42]), 'Mixed float vector'
    assert, array_equal(midle('["Hello", "World"]'), ["Hello", "World"]), 'String array'
    
    assert, array_equal_exact($
        midle('[[[0,1],[2,3],[4,5]],[[6,7],[8,9],[10,11]],[[12,13],[14,15],[16,17]],[[18,19],[20,21],[22,23]]]'), $
        indgen(2,3,4)), $
        '3D array'
    
    assert, array_equal_exact( $
        midle('[ [[0,1],[2,3],[5,6]], [8,9] ]'), $
        [ [[0,1],[2,3],[5,6]], [8,9] ]), $
        'Seemingly weird'
     
    st = midle('{x: 42.0, y: "Hello", z: 42}')   
    assert, isa(st, 'Struct') && st.x eq 42.0 && st.y eq 'Hello' && st.z eq 42
    
    assert, min(midle('(42, "Hello")') eq list(42, "Hello")) eq 1, 'List values'
    assert, n_elements(midle('h{"x": 42.0, 42: "Hello", "Y": 42}') eq hash("x", 42.0, 42, "Hello", "Y", 42)) eq 3, $
        'Hash values'

    return, 1
end

function Midle_ut::test_arith
    assert, midle('42 + 22') eq 42 + 22
    assert, midle('42 - 22') eq 42 - 22
    assert, midle('42 * 22') eq 42 * 22
    assert, midle('42 / 22.') eq 42 / 22.
    assert, midle('42 mod 22') eq 42 mod 22
    assert, midle('1 ? 42 : 22') eq (42 eq 42 ? 42 : 22)
    assert, midle('0 ? 42 : 22') eq (42 eq 22 ? 42 : 22)
    assert, midle('42 > 22') eq (42 > 22)
    assert, midle('42. < 22') eq (42. < 22)
    assert, midle('4^2') eq 4^2
    assert, midle('-42.') eq -42.
    assert, midle('+42.') eq +42.
    assert, midle('--42') eq 42
    assert, midle('-+42') eq -42

    assert, midle('-2.2 - 2 mod 42. + 22 ^ 2 > 3 - 4.2 * 2.2 / 2.4') eq (-2.2 - 2 mod 42. + 22 ^ 2 > 3 - 4.2 * 2.2 / 2.4), $
        'Arith operator precedence'
    assert, midle('-2.2 - 2 mod ((42. + 22) ^ 2 > 3 - 4.2) * 2.2 / 2.4') eq (-2.2 - 2 mod ((42. + 22) ^ 2 > 3 - 4.2) * 2.2 / 2.4), $
        'Arith operator precedence with parentheis'

    assert, array_equal_exact($
        midle('[2.2, 4.2, 42] + [4.2, 22, .42] * [0.22, 22.22, 4.222]'), $
        [2.2, 4.2, 42] + [4.2, 22, .42] * [0.22, 22.22, 4.222]), $
        'Arith operators on vectors'

    assert, array_equal_exact($
        midle('([2.2, 4.2, 42] + [4.2, 22, .42]) * [0.22, 22.22, 4.222]'), $
        ([2.2, 4.2, 42] + [4.2, 22, .42]) * [0.22, 22.22, 4.222]), $
        'Arith operators on vectors with parenthesis'

    return, 1
end

function Midle_ut::test_more_operators

    assert, midle('1 && 1') eq (1 && 1)
    assert, midle('1 && 0') eq (1 && 0)
    assert, midle('42 || 1') eq (42 || 1)
    assert, midle('0 || 42') eq (0 || 42)
    assert, midle('~42') eq ~42
    assert, midle('~0') eq ~0
    
    assert, midle('1 and 0') eq (1 and 0)
    assert, midle('5 and 7') eq (5 and 7)
    assert, midle('5 or 7') eq (5 or 7)
    assert, midle('not (42 and 22) or (22 and 0)') eq (not (42 and 22) or (22 and 0))
    
    assert, midle('42 eq 42') eq (42 eq 42)
    assert, midle('42 gt 22') eq (42 gt 22)
    assert, midle('22 lt 42') eq (22 lt 42)

    return, 1
end

function Midle_ut::test_funccall
    assert, array_equal_exact(midle('indgen(3,4,5)'), indgen(3,4,5))
    assert, array_equal_exact(midle('sindgen(3,4,5, start=10)'), sindgen(3,4,5, start=10))
    assert, array_equal_exact(midle('dist(10,10)'), dist(10,10)) 
    assert, midle('a.count()', {a: list(1,2,3,4,5)}) eq 5
    assert, midle('a.where(5)[0]', {a: list(1,2,3,4,5)}) eq 4 
    
    return, 1
end

function Midle_ut::test_member
    assert, midle('a.x', {a: Hash("x", 42, "y", 22)}) eq 42
    assert, midle('h{"x": 42, "y": 22}.x') eq 42
    assert, midle('Dictionary("x", 42, "y", 22).x') eq 42
    assert, midle('a.x', {a: {x: 42, y: 22}}) eq 42
    assert, midle('{x: 42, y: 22}.x') eq 42
    
    return, 1
end

function Midle_ut::test_assignment
    env = Dictionary()
    assert, midle('x = 42', env) eq 42
    assert, env.x eq 42
    
    assert, array_equal_exact(midle('a = indgen(10)', env), indgen(10))
    assert, array_equal_exact(env.a, indgen(10))
    
    assert, midle('a[3] = 42', env) eq 42
    assert, env["a", 3] eq 42, '1'
    
    midle, 'h = h{}', env
    midle, 'h["x"] = (42, indgen(3,4,5), 22, "hello", "world")', env
    assert, midle('h["x", 4] = "life"', env) eq 'life', '2'
    assert, env["h", "x", 4] eq 'life'
    assert, midle('h["x", 1, 2, 3] = 99', env) eq 99
    assert, env["h", "x", 1, 2, 3] eq 99
    assert, midle('h["x", 1, 0:1, *, 0:4:2] = 42', env) eq 42
    assert, array_equal_exact(env["h", "x", 1, 0:1, *, 0:4:2], make_array(2,4,3, value=42))
    
    midle, 'st = {x: 4.2, y: 2.2}', env
    assert, midle('st.y = 4.2', env) eq 4.2
    assert, env["st"].(1) eq 4.2
    assert, midle('st.(0) = 2.2', env) eq 2.2
    assert, env["st"].(0) eq 2.2
    
    midle, 'st = {x: 4.2, y: indgen(3,4,5)}', env
    assert, midle('st.y[1,2,3] = 99', env) eq 99
    assert, env["st"].(1)[1,2,3] eq 99
    assert, midle('st.y[0:1, *, 0:4:2] = 42', env) eq 42
    assert, array_equal_exact(env["st"].(1)[0:1, *, 0:4:2], make_array(2,4,3, value=42))
    
    midle, 'b = [(1,2,3), (4,5,6), h{}, (7,8,9)]', env
    assert, midle('b[1][1] = 42', env) eq 42
    assert, ((env.b)[1])[1] eq 42
    midle, 'b[2]["st"] = {x: indgen(3,4,5), y: 42, z: indgen(3,5)}', env
    assert, midle('b[2]["st"].x[1,2,3] = 99', env) eq 99
    assert, (((env.b)[2])['st']).(0)[1,2,3] eq 99
    midle, 'b[2]["st"].z[[0,2],0:4:2] = 99', env
    assert, array_equal_exact((((env.b)[2])['st']).(2)[[0,2],0:4:2], make_array(2,3, value=99))
    
    return, 1
end

function Midle_ut::test_file
    midle, filepath('input01', root=mg_src_root()), env, /file
    assert, array_equal_exact(env.a, indgen(3,4,5))
    assert, array_equal_exact((env.h)['z', 3], indgen(3,4,5)+42)
    assert, (env.h)['x'] eq 2.2
    assert, (env.h)['y'] eq 4.2
    assert, (env.h)['x'] + (env.h)['x'] eq (env.h)['xx']
    
    env = Dictionary()
    midle, filepath('input02', root=mg_src_root()), env, /file
    assert, array_equal_exact(env.a, indgen(3,4,5)), 'include'
    assert, array_equal_exact((env.h)['z', 3], indgen(3,4,5)+42)
    assert, (env.h)['x'] eq 42
    assert, (env.h)['y'] eq 22
    st = (env.h)['st']
    assert, st.x eq 42
    assert, st.y eq 22
    
    return, 1
end


pro Midle_ut__define, class
    class = { Midle_ut, inherits MGutTestCase }
end
