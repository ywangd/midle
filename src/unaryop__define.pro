


function UnaryOp::eval, env
    TOKEN = env.__TOKEN__
    val = self.operands[0].eval(env)
    case self.operator of
        TOKEN.T_ADD: 
        TOKEN.T_SUB: val = -val
        TOKEN.T_LNOT: val = ~val
        TOKEN.T_BNOT: val = not val
        else: self.error, 'Unrecognized operator ' + self.operator
    endcase
    return, val
end

function UnaryOp::print_helper
    return, string(typename(self), self.operator, format='(A, " ''",I0,"''")')
end

function UnaryOp::init, operator, node
    if ~self->AstNode::init() then return, 0
    self.operator = operator
    self.operands.add, node
    return, 1
end

pro UnaryOp__define, class
    class = {UnaryOp, inherits AstNode, $
        operator: ''}
end