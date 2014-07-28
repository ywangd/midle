; docformat = 'rst'

;+
; Mini IDL Evaluator (MIDLE) in many cases provides an alternative to IDL's
; EXECUTE command. 
;
; :Author:
; 	Yang Wang (ywangd@gmail.com)
;-

;+
; :Description:
;    The functional interface of MIDLE.
;
; :Params:
;    _lines_or_file : in, required, type=String
;       Lines of IDL statements or file containing IDL statements.
;    _env : in, optional, type=Object
;       The runtime environment for variable lookup. It is either a hash like
;       object or a structure.
;
; :Keywords:
;    file : in, optional, type=boolean
;       If this keyword is set, the first positional parameter is treated as
;       a filename. Otherwise it is treated as strings of IDL codes.
;    ast : out, optional, type=Object
;       The abstract syntax tree object of the input code.
;    error : out, optional, type=String
;       Containing error message if there is error during evaluation. Equals
;       to !NULL if no error.
;
;-
function midle, _lines_or_file, _env, file=file, ast=ast, error=error
    compile_opt logical_predicate
    
    error = !NULL
    catch, theError
    if theError ne 0 then begin
        catch, /cancel
        error = !error_state.msg
        if ~(!error_state.name eq 'IDL_M_USER_ERR' && strmid(!error_state.msg,0,6) eq 'MIDLE_') then begin
            print, !error_state.msg_prefix, '[Error] ', !error_state.msg
        endif
        return, !NULL
    endif
    
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
        message, 'The Runtime Environment Variable must be either a Hash or Struct', /noname
    endelse
    
    ast = parse(lines)
    res = ast.eval(env)

    if isa(_env, 'Struct') then _env = env.toStruct() else _env = env

    return, res

end

;+
; :Description:
;    The procedurecal interface of MIDLE.
;-
pro midle, _lines_or_file, _env, file=file, ast=ast, error=error
    
    !NULL = midle(_lines_or_file, _env, file=file, ast=ast, error=error)
    
end


;+
; :Description:
;    Entry routine of Virtual Machine Application. Only for testing purpose.
;-
pro main
    
    midle, 'a = h{"x": (1,42), "y": "Hello World"}', env
    
    ok = dialog_message(string(env, /print))

end



