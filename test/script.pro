; Test input script
a = indgen(3,4,5)
b = a + 42 ; this is a comment
h = h{ $

    'x': 2.2, $
    'y': 4.2, $
    'z': ('Hello', 'World') $

    }

h['xx'] = h.x + h.x 

h.z.add, '!'

h.z.add, b


