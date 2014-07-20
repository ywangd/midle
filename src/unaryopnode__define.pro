


function UnaryOpNode::eval, env
    TOKEN = self.TOKEN
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

function UnaryOpNode::print_helper
    return, string(self.name(), strupcase((self.TOKEN.where(self.operator))[0]), $
        format='(A, " ''",A,"''")')
end

function UnaryOpNode::init, start_pos, operator, node
    if ~self->AstNode::init(start_pos) then return, 0
    self.operator = operator
    self.operands.add, node
    return, 1
end

pro UnaryOpNode__define, class
    class = {UnaryOpNode, inherits AstNode, $
        operator: 0}
end