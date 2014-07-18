
function MemberNode::print_helper
    return, string(self.name(), format='(A)')
end


function MemberNode::init, start_pos, object, name
    if ~self->AstNode::init(start_pos) then return, 0
    self.operands.add, object
    self.operands.add, name
    return, 1
end

pro MemberNode__define, class
    class = {MemberNode, inherits AstNode }
end