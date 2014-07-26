; docformat = 'rst'

;+
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function IdentNode::eval, env, lexeme=lexeme
    @ast_error_handler

    if keyword_set(lexeme) then begin
        return, self.lexeme 
    endif else begin
        if ~env.haskey(self.lexeme) then message, 'Undefined variable: ' + self.lexeme, /noname
        return, env[self.lexeme]
    endelse
end

function IdentNode::print_helper
    return, string(self.name(), self.lexeme, format='(A, " ''",A,"''")')
end


function IdentNode::init, start_pos, lexeme
    if ~self->AstNode::init(start_pos) then return, 0
    self.lexeme = lexeme
    return, 1
end

pro IdentNode__define, class
    class = {IdentNode, inherits AstNode, $
        lexeme: '' }
end
