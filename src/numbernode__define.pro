; docformat = 'rst'

;+
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function NumberNode::eval, env
    ; Byte is special as Fix to byte produces the ascii codes of letters in the string
    ; So the string has to be convert to int first then convert to byte.
    if self.typeCode eq 1 then begin
        return, byte(fix(self.lexeme))
    endif else begin
        return, fix(self.lexeme, type=self.typeCode)
    endelse
end

function NumberNode::print_helper
    return, string(self.name(), self.lexeme, format='(A, " ''",A,"''")')
end

function NumberNode::init, start_pos, lexeme, typeCode
    if ~self->AstNode::init(start_pos) then return, 0
    self.lexeme = lexeme
    self.typeCode = typeCode
    return, 1
end

pro NumberNode__define, class
    class = {NumberNode, inherits AstNode, $
        lexeme: '', $
        typeCode: '' }
end