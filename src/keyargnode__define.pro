
function KeyargNode::print_helper
    return, string(typename(self), self.operands[0], format='(A, " ''",A,"''")')
end


function KeyargNode::init, start_pos
    if ~self->AstNode::init(start_pos) then return, 0
    return, 1
end

pro KeyargNode__define, class
    class = {KeyargNode, inherits AstNode }
end