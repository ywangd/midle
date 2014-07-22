

function parse, line
    
    p = MidleParser()
    ast = p.parse(line)
    return, ast
end