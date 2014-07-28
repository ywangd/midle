; docformat = 'rst'

;+
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function NumberNode::eval, env
    @ast_error_handler

    ; Byte is special as Fix to byte produces the ascii codes of letters in the string
    ; So the string has to be convert to int first then convert to byte.
    if self.typeCode eq 1 then begin
        ret = byte(fix(self.lexeme))
        
    endif else if self.typeCode ge 0 then begin
        ret = fix(self.lexeme, type=self.typeCode)
        
    endif else begin ; type code less than zero for auto promoting numbers
        if self.typeCode eq -2 then begin ; auto-promoting integer
            ret = fix(self.lexeme, type=14)
            if ret ge -32767s && ret le 32767s then begin
                ret = fix(ret, type=2)
            endif else if ret ge -2147483647L && ret le 2147483647L then begin
                ret = fix(ret, type=3)
            endif
        endif else if self.typeCode eq -12 then begin
            ret = fix(self.lexeme, type=15)
            if ret le 65535us then begin
                ret = fix(ret, type=12) 
            endif else if ret le 4294967295ul then begin
                ret = fix(ret, type=13)
            endif
        endif
    endelse
    
    return, ret
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
