

function IdentNode::eval, env
    return, env[self.lexeme]
end

function IdentNode::print_helper
    return, string('IDENT', self.lexeme, format='(A, " ''",A,"''")')
end


function IdentNode::init, lexeme
    if ~self->AstNode::init() then return, 0
    self.lexeme = lexeme
    return, 1
end

pro IdentNode__define, class
    class = {IdentNode, inherits AstNode, $
        lexeme: '' }
end