; docformat = 'rst'

;+
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function IdentNode::eval, env, lexeme=lexeme
    catch, theError
    if theError ne 0 then begin
        catch, /cancel
        if !error_state.name eq 'IDL_M_USER_ERR' && strmid(!error_state.msg, 0, 18) eq 'Key does not exist' then begin
            self.error, 'Undefined variable: ' + self.lexeme
        endif else begin
            message, /reissue_last
        endelse
    endif
    if keyword_set(lexeme) then return, self.lexeme else return, env[self.lexeme]
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
