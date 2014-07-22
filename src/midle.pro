
function midle, lines, _env, ast=ast

    if n_elements(_env) eq 0 then begin
        env = Dictionary()
    endif else if isa(_env, 'Struct') then begin
        env = Dictionary(_env)
    endif else if isa(_env, 'Hash') then begin
        if ~isa(_env, 'Dictionary') then begin
            env = Dictionary()
            foreach v, _env, k do env[k] = v
        endif else env = _env
    endif else begin
        message, 'Runtime environment must be either a Hash or Struct'
    endelse

    ast = parse(lines)
    res = ast.eval(env)

    if isa(_env, 'Struct') then _env = env.toStruct() else _env = env

    return, res

end


pro midle, lines, _env, ast=ast
    
    !NULL = midle(lines, _env, ast=ast)
    
end