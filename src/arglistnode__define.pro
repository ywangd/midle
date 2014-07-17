
function ArglistNode::print_helper
    return, string(typename(self), self.operands.count(), format='(A, " ''",I0,"''")')
end


function ArglistNode::init
    if ~self->AstNode::init() then return, 0
    return, 1
end

pro ArglistNode__define, class
    class = {ArglistNode, inherits AstNode }
end