
function StringNode::eval, env
    return, strmid(self.lexeme, 1, strlen(self.lexeme)-2)
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