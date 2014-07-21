
function KeyargNode::eval, env
    name = self.operands[0]
    if isa(name, 'IdentNode') then begin
        name = name.eval(env, /lexeme)
    endif else begin
        self.error, 'Invalid keyword argument' 
    endelse
    return, create_struct(name, (self.operands[1]).eval(env))
end

function KeyargNode::print_helper
    return, self.name()
end


function KeyargNode::init, start_pos, name, val
    if ~self->AstNode::init(start_pos) then return, 0
    self.operands.add, name
    self.operands.add, val
    return, 1
end

pro KeyargNode__define, class
    class = {KeyargNode, inherits AstNode }
end