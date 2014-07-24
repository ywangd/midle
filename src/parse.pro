;+
; :Description:
;    Parse the given string arrays and build the syntax tree.
;
; :Author:
;   Yang Wang (ywangd@gmail.com)
;
; :Params:
;    lines : in, required, type=String
;       Strings of IDL codes.
;
;-
function parse, lines
    
    p = MidleParser()
    ast = p.parse(lines)
    return, ast
end