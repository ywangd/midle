
function IndexNode::eval, env, shp, idxdim, onlyIndex=onlyIndex, isRange=isRange
    compile_opt logical_predicate
    
    if keyword_set(onlyIndex) then uplimit = product(shp, /preserve_type) else uplimit = shp[idxdim]

    isRange = 0
    if self.operands.count() eq 1 then begin
        if isa(self.operands[0], 'WildcardNode') then begin
            index = lindgen(uplimit)
            isRange = 1
        endif else begin
            index = (self.operands[0]).eval(env)
        endelse
        
    endif else begin
        
        isRange = 1
        if isa(self.operands[0], 'WildcardNode') then self.error, 'Invalid *:n subscript'
        sidx = (self.operands[0]).eval(env)
        eidx = isa(self.operands[1], 'WildcardNode') ? uplimit-1 : (self.operands[1]).eval(env)
        if self.operands.count() eq 2 then begin
            step = 1
        endif else if ~isa(self.operands[2], 'WildcardNode') then begin
            step = (self.operands[2]).eval(env)
        endif else begin
            self.error, 'Invalid n:n:* subscript'
        endelse
        
        index = (lindgen(uplimit))[sidx:eidx:step]

    endelse
    
    return, index
end

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