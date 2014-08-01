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
        if self.try_proc then begin
            catch, theError
            if theError ne 0 then begin
                catch, /cancel
                if !error_state.name eq 'IDL_M_UPRO_UNDEF' then begin
                    goto, GET_VAR
                endif else message, /reissue_last
            endif
            call_procedure, self.lexeme
            return, !NULL
        endif
        GET_VAR:
        if ~env.haskey(self.lexeme) then message, 'Undefined variable: ' + self.lexeme, /noname
        return, env[self.lexeme]
    endelse
end

function IdentNode::print_helper
    return, string(self.name(), self.lexeme, format='(A, " ''",A,"''")')
end

pro IdentNode::setProperty, try_proc=try_proc, _extra=extra
    if n_elements(try_proc) ne 0 then self.try_proc = try_proc
    self->AstNode::setProperty, _extra=extra
end

pro IdentNode::getProperty, try_proc=try_proc, _ref_extra=extra
    if arg_present(try_proc) then try_proc = self.try_proc
    self->AstNode::getProperty, _extra=extra
end


function IdentNode::init, lexer, lexeme
    if ~self->AstNode::init(lexer) then return, 0
    self.lexeme = lexeme
    self.try_proc = 0
    return, 1
end

pro IdentNode__define, class
    class = {IdentNode, inherits AstNode, $
        lexeme: '', $
        try_proc: 0 }
end
