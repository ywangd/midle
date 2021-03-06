; docformat = 'rst'

;+
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function UnaryOpNode::eval, env
    @ast_error_handler

    TOKEN = self.lexer.TOKEN
    val = self.operands[0].eval(env)
    case self.operator of
        TOKEN.T_ADD: 
        TOKEN.T_SUB: val = -val
        TOKEN.T_LNOT: val = ~val
        TOKEN.T_BNOT: val = not val
        else: message, 'Unrecognized operator', /noname
    endcase
    return, val
end

function UnaryOpNode::print_helper
    return, string(self.name(), strupcase((self.lexer.TOKEN.where(self.operator))[0]), $
        format='(A, " ''",A,"''")')
end

function UnaryOpNode::init, lexer, operator, node
    if ~self->AstNode::init(lexer) then return, 0
    self.operator = operator
    self.operands.add, node
    return, 1
end

pro UnaryOpNode__define, class
    class = {UnaryOpNode, inherits AstNode, $
        operator: 0}
end
