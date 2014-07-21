
function MemberNode::eval, env, member=member, lexeme=lexeme
    objref = (self.operands[0]).eval(env)
    
    member = self.operands[1]
    if isa(member, 'IdentNode') then begin
        member = member.eval(env, /lexeme)
    endif else begin
        self.error, 'Invalid object property'
    endelse
    
    if keyword_set(lexeme) then begin
        return, objref
    endif else begin
        ; does not seem to be possible to get the property with a string as its name?
        self.error, 'Object property access is not supported'
    endelse
    
end


function MemberNode::print_helper
    return,self.name()
end


function MemberNode::init, start_pos, object, member
    if ~self->AstNode::init(start_pos) then return, 0
    self.operands.add, object
    self.operands.add, member
    return, 1
end

pro MemberNode__define, class
    class = {MemberNode, inherits AstNode }
end