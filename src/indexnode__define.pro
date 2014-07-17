
function IndexNode::print_helper
    return, string(typename(self), self.operands.count(), format='(A, " ''",I0,"''")')
end


function IndexNode::init
    if ~self->AstNode::init() then return, 0
    return, 1
end

pro IndexNode__define, class
    class = {IndexNode, inherits AstNode }
end