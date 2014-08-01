; docformat = 'rst'

;+
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function IdxlistNode::eval, env, fromIndex=fromIndex, toIndex=toIndex, isRanges=isRanges
    @ast_error_handler
    
    nd = self.operands.count()
    
    if n_elements(fromIndex) eq 0 then fromIndex = 0
    if n_elements(toIndex) eq 0 then toIndex = nd - 1
    
    if fromIndex gt toIndex || (toIndex - fromIndex) ge 8 then message, 'Invalid number of dimensions', /noname
        
    isRanges = []
    idxlist = list()
    for idx = fromIndex, toIndex do begin
        operand = self.operands[idx]
        idxlist.add, operand.eval(env, isRange=isr)
        isRanges = [isRanges, isr]
    endfor
    
    return, idxlist
end

function IdxlistNode::print_helper
    return, string(self.name(), self.operands.count(), format='(A, " ''",I0,"''")')
end


function IdxlistNode::init, lexer
    if ~self->AstNode::init(lexer) then return, 0
    return, 1
end

pro IdxlistNode__define, class
    class = {IdxlistNode, inherits AstNode }
end
