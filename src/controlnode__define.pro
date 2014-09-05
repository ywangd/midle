; docformat = 'rst'

;+
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function ControlNode::eval, env
    message, block='MIDLE_PROGRAM_CONTROL', name=self.control_name
    return, 0
end

function ControlNode::print_helper
    return, string(self.name(), self.control_name, format='(A, " ''",A,"''")')
end

function ControlNode::init, lexer, control_name
    if ~self->AstNode::init(lexer) then return, 0
    self.control_name = control_name
    return, 1
end

pro ControlNode__define, class
    class = {ControlNode, inherits AstNode, $
        control_name: ''}
end
