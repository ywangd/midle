
function PlaceholderNode::print_helper
    TOKEN = getTokenCodes()
    return, string('PLACEHOLDER', strupcase((TOKEN.where(self.tag))[0]), self.lexeme, $
        format='(A, " [", A-10, "''", A, "'']")')
end


function PlaceholderNode::init, tag, lexeme
    if ~self->AstNode::init() then return, 0
    self.tag = tag
    self.lexeme = lexeme
    return, 1
end

pro PlaceholderNode__define, class
    class = {PlaceholderNode, inherits AstNode, $
        tag: 0L, $
        lexeme: '' }
end