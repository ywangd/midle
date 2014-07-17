

function ListNode::eval, env
    TOKEN = env.__TOKEN__
    
    theList = list()
    foreach operand, self.operands do begin
        theList.add, operand.eval(env)
    endforeach
    
    catch, theError
    if theError ne 0 then begin
        catch, /cancel
        if !error_state.name eq 'IDL_M_USER_ERR' then begin
            self.error, 'Array elements cannot be converted to the same type'
        endif
    endif
    
    if self.operator eq TOKEN.T_LBRACKET then begin
        theList = theList.toArray()
    endif else if self.operator eq TOKEN.T_LCURLY then begin
        ret = hash()
        for i = 0, theList.count()-1, 2 do begin
            key = theList[i]
            val = theList[i+1]
            if isa(key, /number, /scalar) || isa(key, 'String', /scalar) then begin
                ret[key] = val
            endif else begin
                self.error, 'Invalid Hash key ' + strtrim(key,2)
            endelse
        endfor
        return, ret
    endif
    
    return, theList
end

function ListNode::print_helper
    return, string(typename(self), self.operator, format='(A, " ''",A,"''")')
end


function ListNode::init, operator, node
    if ~self->AstNode::init() then return, 0
    self.operator = operator
    if n_elements(node) ne 0 then self.operands.add, node
    return, 1
end

pro ListNode__define, class
    class = {ListNode, inherits AstNode, $
        operator: '' }
end