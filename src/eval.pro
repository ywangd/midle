
function eval, line, env, ast=ast

    parser = ExprParser()
    ast = parser.parse(line)
    
    res = ast.eval(env)
    return, res

end