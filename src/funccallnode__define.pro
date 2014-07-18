
function FuncCallNode::print_helper
    return, string(self.name(), format='(A)')
end


function FuncCallNode::init, start_pos, func, arglist
    if ~self->AstNode::init(start_pos) then return, 0
    self.operands.add, func
    self.operands.add, arglist
    return, 1
end

pro FuncCallNode__define, class
    class = {FuncCallNode, inherits AstNode }
end