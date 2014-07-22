

function parse, lines
    
    p = MidleParser()
    ast = p.parse(lines)
    return, ast
end