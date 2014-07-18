

function NumberNode::eval, env
    return, fix(self.lexeme, type=self.typeCode)
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