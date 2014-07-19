
function IndexNode::print_helper
    return, self.name()
end


function IndexNode::init, start_pos
    if ~self->AstNode::init(start_pos) then return, 0
    return, 1
end

pro IndexNode__define, class
    class = {IndexNode, inherits AstNode }
end