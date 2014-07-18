
function IdxlistNode::print_helper
    return, string(typename(self), self.operands.count(), format='(A, " ''",I0,"''")')
end


function IdxlistNode::init, start_pos
    if ~self->AstNode::init(start_pos) then return, 0
    return, 1
end

pro IdxlistNode__define, class
    class = {IdxlistNode, inherits AstNode }
end