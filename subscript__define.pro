
function Subscript::print_helper
    return, string(typename(self), format='(A)')
end


function Subscript::init, collection, idxlist
    if ~self->AstNode::init() then return, 0
    self.operands.add, collection
    self.operands.add, idxlist
    return, 1
end

pro Subscript__define, class
    class = {Subscript, inherits AstNode }
end