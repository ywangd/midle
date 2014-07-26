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


function WildcardNode::init, start_pos, lexeme
    if ~self->AstNode::init(start_pos) then return, 0
    self.lexeme = lexeme
    return, 1
end

pro WildcardNode__define, class
    class = {WildcardNode, inherits AstNode, $
        lexeme: '' }
end
