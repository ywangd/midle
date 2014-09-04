; docformat = 'rst'

;+
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function IfNode::eval, env
    @ast_error_handler
    compile_opt logical_predicate

    predicate = self.operands[0].eval(env)
    
    ret = !NULL
    if predicate then begin
        ret = self.operands[1].eval(env) 
    endif else begin
        if n_elements(self.operands) eq 3 then ret = self.operands[2].eval(env)
    endelse
    
    return, ret
end

function IfNode::print_helper
    return, string(self.name(), format='(A, " ''IF''")')
end

function IfNode::init, lexer, node_predicate, node_then, node_else
    if ~self->AstNode::init(lexer) then return, 0
    self.operands.add, node_predicate
    self.operands.add, node_then
    if node_else ne !NULL then self.operands.add, node_else
    return, 1
end

pro IfNode__define, class
    class = {IfNode, inherits AstNode }
end
