
function KeyargNode::print_helper
    return, string(typename(self), self.operands[0], format='(A, " ''",A,"''")')
end


function KeyargNode::init
    if ~self->AstNode::init() then return, 0
    return, 1
end

pro KeyargNode__define, class
    class = {KeyargNode, inherits AstNode }
end