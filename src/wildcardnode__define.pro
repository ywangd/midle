; docformat = 'rst'

;+
; Wildcard in subscripts, e.g. a[*]
; 
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function WildcardNode::print_helper
    return, string(self.name(), self.lexeme, format='(A, " ''",A,"''")')
end


function WildcardNode::init, lexer, lexeme
    if ~self->AstNode::init(lexer) then return, 0
    self.lexeme = lexeme
    return, 1
end

pro WildcardNode__define, class
    class = {WildcardNode, inherits AstNode, $
        lexeme: '' }
end
