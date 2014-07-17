
function Member::print_helper
    return, string(typename(self), format='(A)')
end


function Member::init, object, name
    if ~self->AstNode::init() then return, 0
    self.operands.add, object
    self.operands.add, name
    return, 1
end

pro Member__define, class
    class = {Member, inherits AstNode }
end