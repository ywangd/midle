; docformat = 'rst'

;+
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function TerneryOpNode::eval, env
    @ast_error_handler

    predicate = self.operands[0].eval(env)
    val_true = self.operands[1].eval(env)
    val_false = self.operands[2].eval(env)
    
    return, predicate ? val_true : val_false
end

function TerneryOpNode::print_helper
    return, string(self.name(), format='(A, " ''? :''")')
end

function TerneryOpNode::init, start_pos, node_predicate, node_true, node_false
    if ~self->AstNode::init(start_pos) then return, 0
    self.operands.add, node_predicate
    self.operands.add, node_true
    self.operands.add, node_false
    return, 1
end

pro TerneryOpNode__define, class
    class = {TerneryOpNode, inherits AstNode }
end
