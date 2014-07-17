
function Funccall::print_helper
    return, string(typename(self), format='(A)')
end


function Funccall::init, func, arglist
    if ~self->AstNode::init() then return, 0
    self.operands.add, func
    self.operands.add, arglist
    return, 1
end

pro Funccall__define, class
    class = {Funccall, inherits AstNode }
end