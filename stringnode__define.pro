
function StringNode::eval, env
    return, strmid(self.lexeme, 1, strlen(self.lexeme)-2)
end

function StringNode::print_helper
    return, string('STRING', self.lexeme, format='(A, " ''",A,"''")')
end


function StringNode::init, lexeme
    if ~self->AstNode::init() then return, 0
    self.lexeme = lexeme
    return, 1
end

pro StringNode__define, class
    class = {StringNode, inherits AstNode, $
        lexeme: '' }
end