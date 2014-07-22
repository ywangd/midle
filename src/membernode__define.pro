
function MemberNode::eval_lhs, env, member=member
    host = self.operands[0]
    member = self.operands[1]
    return, host
end


function MemberNode::eval, env, member=member, lexeme=lexeme
    host = (self.operands[0]).eval(env)

    if ~isa(host, 'Objref') && ~isa(host, 'Struct') then self.error, 'Incorrect data type for member access'

    indexingStruct = 0
    member = self.operands[1]
    if isa(member, 'IdentNode') then begin
        member = member.eval(env, /lexeme)
    endif else if isa(host, 'Struct') then begin
        member = member.eval(env)
        indexingStruct = 1
    endif else begin
        self.error, 'Invalid object property'
    endelse

    if keyword_set(lexeme) then begin
        return, host

    endif else begin

        if isa(host, 'Hash') then begin
            return, host[member]

        endif else if isa(host, 'Struct') then begin
            if indexingStruct eq 1 then begin
                return, host.(member)
            endif else begin
                idx = where(tag_names(host) eq strupcase(member), count)
                if count gt 0 then begin
                    return, host.(idx[0])
                endif else begin
                    self.error, 'Field does not exist: ' + member
                endelse
            endelse

        endif else begin
            ; Impossible to get a property by a string as its name?
            self.error, 'Property access is not supported for class type ' + typename(host)
        endelse

    endelse

end


function MemberNode::print_helper
    return,self.name()
end


function MemberNode::init, start_pos, host, member
    if ~self->AstNode::init(start_pos) then return, 0
    self.operands.add, host
    self.operands.add, member
    return, 1
end

pro MemberNode__define, class
    class = {MemberNode, inherits AstNode }
end