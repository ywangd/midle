

function ListNode::eval, env
    TOKEN = self.TOKEN
    
    theList = list()
    foreach operand, self.operands do begin
        theList.add, operand.eval(env)
    endforeach
    
    catch, theError
    if theError ne 0 then begin
        catch, /cancel
        if !error_state.name eq 'IDL_M_TYPCNVERR' then begin
            self.error, 'Array elements cannot be converted to the same type'
        endif
    endif
    
    if self.operator eq TOKEN.T_LBRACKET then begin
        
        ; Manually concatenate the array instead of using theList.toArray()
        ; because the function call convert everything to the type of the
        ; first element. So if the first element is int and second is float,
        ; the final product is an int array, which is wrong.
        ret = []
        foreach item, theList do begin
            ret = [ret, item]
        endforeach
        
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
        
    endif else begin
        ret = theList
    endelse
    
    return, ret
end

function ListNode::print_helper
    return, string(self.name(), strupcase(self.TOKEN.where(self.operator)), format='(A, " ''",A,"''")')
end


function ListNode::init, start_pos, operator, node
    if ~self->AstNode::init(start_pos) then return, 0
    self.operator = operator
    if n_elements(node) ne 0 then self.operands.add, node
    return, 1
end

pro ListNode__define, class
    class = {ListNode, inherits AstNode, $
        operator: '' }
end