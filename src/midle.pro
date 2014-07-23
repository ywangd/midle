
function midle, _lines_or_file, _env, file=file, ast=ast
    compile_opt logical_predicate
    
    if keyword_set(file) then lines = midleRead(_lines_or_file) else lines = _lines_or_file

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


pro midle, _lines_or_file, _env, file=file, ast=ast
    
    !NULL = midle(_lines_or_file, _env, file=file, ast=ast)
    
end