; docformat = 'rst'

;+
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function ForeachNode::run_body, env, loopvar, looplist, loopidx

    ret = !NULL
    foreach v, looplist, i do begin
        env[loopvar] = v
        if loopidx ne !NULL then env[loopidx] = i
        @program_control_handler
        ret = self.operands[2].eval(env)
    endforeach
    return, ret

end

function ForeachNode::eval, env
    @ast_error_handler

    loopvar = self.operands[0].eval(env, /lexeme)
    looplist = self.operands[1].eval(env)
    if n_elements(self.operands) eq 4 then loopidx = self.operands[3].eval(env, /lexeme) else loopidx = !NULL

    return, self.run_body(env, loopvar, looplist, loopidx)
end

function ForeachNode::print_helper
    return, self.name()
end

function ForeachNode::init, lexer, node_loopvar, node_looplist, node_loopidx, node_loopbody
    if ~self->AstNode::init(lexer) then return, 0
    self.operands.add, node_loopvar
    self.operands.add, node_looplist
    self.operands.add, node_loopbody
    if node_loopidx ne !NULL then self.operands.add, node_loopidx
    return, 1
end

pro ForeachNode__define, class
    class = {ForeachNode, inherits AstNode }
end
