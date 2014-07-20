

function IdxlistNode::eval, env, shp, isRanges=isRanges
    nd = self.operands.count()
    if nd eq 0 || nd gt 8 then self.error, 'Invalid number of dimensions (must be from 1 to 8)'
    
    ; Special case of a single * as index
    if nd eq 1 then begin
        idxlist = list((self.operands[0]).eval(env, shp, 0, /onlyIndex))
        isRanges = [0]
        return, idxlist
    endif
    
    isRanges = []
    idxlist = list()
    foreach operand, self.operands, idx do begin
        idxlist.add, operand.eval(env, shp, idx, isRange=isR)
        isRanges = [isRanges, isR]
    endforeach
    
    return, idxlist
end

function IdxlistNode::print_helper
    return, string(self.name(), self.operands.count(), format='(A, " ''",I0,"''")')
end


function IdxlistNode::init, start_pos
    if ~self->AstNode::init(start_pos) then return, 0
    return, 1
end

pro IdxlistNode__define, class
    class = {IdxlistNode, inherits AstNode }
end