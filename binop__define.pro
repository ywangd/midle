


function BinOp::eval, env
    TOKEN = env.__TOKEN__
    val1 = self.operands[0].eval(env)
    val2 = self.operands[1].eval(env)
    case self.operator of
        TOKEN.T_ADD: val = val1 + val2
        TOKEN.T_SUB: val = val1 - val2
        TOKEN.T_MUL: val = val1 * val2
        TOKEN.T_DIV: val = val1 / val2
        TOKEN.T_MOD: val = val1 mod val2
        TOKEN.T_HASH: val = val1 # val2
        TOKEN.T_DHASH: val = val1 ## val2
        TOKEN.T_EXP: val = val1 ^ val2
        TOKEN.T_MIN: val = val1 < val2
        TOKEN.T_MAX: val = val1 > val2
        TOKEN.T_BOR: val = val1 or val2
        TOKEN.T_BAND: val = val1 and val2
        TOKEN.T_BXOR: val = val1 xor val2
        TOKEN.T_LAND: val = val1 && val2
        TOKEN.T_LOR: val = val1 || val2
        TOKEN.T_EQ: val = val1 eq val2
        TOKEN.T_NE: val = val1 ne val2
        TOKEN.T_GE: val = val1 ge val2
        TOKEN.T_GT: val = val1 gt val2
        TOKEN.T_LE: val = val1 le val2
        TOKEN.T_LT: val = val1 lt val2
        else: self.error, 'Unrecognized operator ' + self.operator
    endcase
    return, val
end


function BinOp::print_helper
    return, string(typename(self), self.operator, format='(A, " ''",I0,"''")')
end


function BinOp::init, operator, lnode, rnode
    if ~self->AstNode::init() then return, 0
    self.operator = operator
    self.operands.add, lnode
    self.operands.add, rnode
    return, 1
end

pro BinOp__define, class
    class = {BinOp, inherits AstNode, $
        operator: ''}
end