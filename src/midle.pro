
function midle, line, _env, ast=ast

    ast = parse(line)
    
    env = n_elements(_env) eq 0 ? !NULL : _env
    
    if isa(env, 'Struct') then env = Dictionary(env)
    
    res = ast.eval(env)
    
    return, res

end