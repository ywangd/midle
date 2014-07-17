
function NullNode::eval, env
    return, !NULL
end

function NullNode::print_helper
    return, string('NULL', self.lexeme, format='(A, " ''",A,"''")')
end


function NullNode::init, lexeme
    if ~self->AstNode::init() then return, 0
    self.lexeme = lexeme
    return, 1
end

pro NullNode__define, class
    class = {NullNode, inherits AstNode, $
        lexeme: '' }
end