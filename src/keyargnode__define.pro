
function KeyargNode::print_helper
    return, self.name()
end


function KeyargNode::init, start_pos
    if ~self->AstNode::init(start_pos) then return, 0
    return, 1
end

pro KeyargNode__define, class
    class = {KeyargNode, inherits AstNode }
end