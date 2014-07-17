
function eval, line, env, ast=ast

    if n_elements(env) eq 0 then begin
        env = Dict()
    endif
    if ~env.haskey('__TOKEN__') then env['__TOKEN__'] = getTokenCodes()
    
    parser = ExprParser()
    ast = parser.parse(line)
    
    res = ast.eval(env)
    return, res

end