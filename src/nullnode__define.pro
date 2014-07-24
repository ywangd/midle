; docformat = 'rst'

;+
; Represent the !NULL value. Note the !NULL value can take different
; literal forms, such as [], {} and !NULL.
; 
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function NullNode::eval, env
    return, !NULL
end

function NullNode::print_helper
    return, string(self.name(), self.lexeme, format='(A, " ''",A,"''")')
end


function NullNode::init, start_pos, lexeme
    if ~self->AstNode::init(start_pos) then return, 0
    self.lexeme = lexeme
    return, 1
end

pro NullNode__define, class
    class = {NullNode, inherits AstNode, $
        lexeme: '' }
end