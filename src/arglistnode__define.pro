; docformat = 'rst'

;+
; :Author:
; 	Yang Wang (ywangd@gmail.com)
;-

function ArglistNode::eval, env, keyargs=keyargs
    
    posargs = list()
    keyargs = {}
    
    foreach arg, self.operands do begin
        if isa(arg, 'KeyargNode') then begin
            keyargs = create_struct(keyargs, arg.eval(env))
        endif else begin
            posargs.add, arg.eval(env)
        endelse
    endforeach
    
    return, posargs
end


function ArglistNode::print_helper
    return, string(self.name(), self.operands.count(), format='(A, " ''",I0,"''")')
end


function ArglistNode::init, lexer
    if ~self->AstNode::init(lexer) then return, 0
    return, 1
end

pro ArglistNode__define, class
    class = {ArglistNode, inherits AstNode }
end
