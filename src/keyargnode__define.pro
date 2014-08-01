; docformat = 'rst'

;+
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function KeyargNode::eval, env
    @ast_error_handler

    name = self.operands[0]
    if isa(name, 'IdentNode') then begin
        name = name.eval(env, /lexeme)
    endif else begin
        message, 'Invalid keyword argument', /noname
    endelse
    return, create_struct(name, (self.operands[1]).eval(env))
end

function KeyargNode::print_helper
    return, self.name()
end


function KeyargNode::init, lexer, name, val
    if ~self->AstNode::init(lexer) then return, 0
    self.operands.add, name
    self.operands.add, val
    return, 1
end

pro KeyargNode__define, class
    class = {KeyargNode, inherits AstNode }
end
