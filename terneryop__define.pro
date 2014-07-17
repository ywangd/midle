


function TerneryOp::eval, env
    predicate = self.operands[0].eval(env)
    val_true = self.operands[1].eval(env)
    val_false = self.operands[2].eval(env)
    
    return, predicate ? val_true : val_false
end

function TerneryOp::print_helper
    return, string(typename(self), format='(A, " ''? :''")')
end

function TerneryOp::init, node_predicate, node_true, node_false
    if ~self->AstNode::init() then return, 0
    self.operands.add, node_predicate
    self.operands.add, node_true
    self.operands.add, node_false
    return, 1
end

pro TerneryOp__define, class
    class = {TerneryOp, inherits AstNode }
end