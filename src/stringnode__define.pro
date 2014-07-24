; docformat = 'rst'

;+
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function StringNode::eval, env
    val = strmid(self.lexeme, 1, strlen(self.lexeme)-2)
    ; process escaped quotes
    quote = strmid(self.lexeme, 0, 1)
    escape = quote + quote
    return, strjoin(strsplit(val, escape, /extract, /regex, /preserve_null), quote) 
end

function StringNode::print_helper
    return, string(self.name(), self.lexeme, format='(A, " ''",A,"''")')
end


function StringNode::init, start_pos, lexeme
    if ~self->AstNode::init(start_pos) then return, 0
    self.lexeme = lexeme
    return, 1
end

pro StringNode__define, class
    class = {StringNode, inherits AstNode, $
        lexeme: '' }
end