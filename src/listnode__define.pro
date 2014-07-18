

function ListNode::eval, env

    TOKEN = self.TOKEN

    if self.operator eq TOKEN.T_LBRACKET then begin
        
        catch, theError
        if theError ne 0 then begin
            catch, /cancel
            if !error_state.name eq 'IDL_M_TYPCNVERR' then begin
                self.error, 'Array elements cannot be converted to the same type'
            endif
        endif

        ; Manually concatenate the array instead of using list.toArray()
        ; because the function call convert everything to the type of the
        ; first element. So if the first element is int and second is float,
        ; the final product is an int array, which is wrong.
        ;
        ; The items are always concatenated on an added dimension after the
        ; last dimension. For an example, a list of [3,2] arrays are concatenated
        ; into array of [3,2,n], where n is the new added dimension
        ;
        ret = []
        nitems = self.operands.count()
        if nitems gt 0 then begin
            dims = !NULL
            foreach operand, self.operands do begin
                item = operand.eval(env)
                if dims eq !NULL then begin
                    dims = size(item, /dimensions)
                endif else begin
                    if ~array_equal(size(item, /dimensions), dims) then $
                        self.error, 'Unable to concatenate arrays of different dimensions'
                endelse

                if isa(dims, /scalar) then begin
                    ret = [ret, item]
                endif else begin
                    ret = [ret, reform(item, n_elements(item))]
                endelse

            endforeach
            if ~isa(dims, /scalar) then ret = reform(ret, [dims, nitems])
        endif

    endif else if self.operator eq TOKEN.T_LCURLY then begin
        
        ret = hash()
        for i = 0, self.operands.count()-1, 2 do begin
            key = (self.operands[i]).eval(env)
            val = (self.operands[i+1]).eval(env)
            if isa(key, /number, /scalar) || isa(key, 'String', /scalar) then begin
                ret[key] = val
            endif else begin
                self.error, 'Invalid Hash key ' + strtrim(key,2)
            endelse
        endfor

    endif else begin  ; 'T_LPAREN
        
        ret = list()
        foreach operand, self.operands do ret.add, operand.eval(env)
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