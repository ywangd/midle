
function SubscriptNode::print_helper
    return, string(self.name(), format='(A)')
end


function SubscriptNode::init, start_pos, collection, idxlist
    if ~self->AstNode::init(start_pos) then return, 0
    self.operands.add, collection
    self.operands.add, idxlist
    return, 1
end

pro SubscriptNode__define, class
    class = {SubscriptNode, inherits AstNode }
end