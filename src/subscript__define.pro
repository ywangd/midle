
function Subscript::print_helper
    return, string(typename(self), format='(A)')
end


function Subscript::init, start_pos, collection, idxlist
    if ~self->AstNode::init(start_pos) then return, 0
    self.operands.add, collection
    self.operands.add, idxlist
    return, 1
end

pro Subscript__define, class
    class = {Subscript, inherits AstNode }
end