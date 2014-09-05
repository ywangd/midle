; docformat = 'rst'

;+
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function ForNode::run_body, env, loopvar, start, end_, step 

    ret = !NULL
    for i = start, end_, step do begin
        env[loopvar] = i
        @program_control_handler
        ret = self.operands[4].eval(env)
    endfor
    return, ret
    
end

function ForNode::eval, env
    @ast_error_handler

    loopvar = self.operands[0].eval(env, /lexeme)
    start = self.operands[1].eval(env)
    end_ = self.operands[2].eval(env)
    step = self.operands[3].eval(env)

    return, self.run_body(env, loopvar, start, end_, step)
end

function ForNode::print_helper
    return, self.name()
end

function ForNode::init, lexer, node_loopvar, node_start, node_end, node_step, node_loopbody
    if ~self->AstNode::init(lexer) then return, 0
    self.operands.add, node_loopvar
    self.operands.add, node_start
    self.operands.add, node_end
    self.operands.add, node_step
    self.operands.add, node_loopbody
    return, 1
end

pro ForNode__define, class
    class = {ForNode, inherits AstNode }
end
