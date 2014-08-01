; docformat = 'rst'

;+
; The statment list node is the top level node of the syntax tree.
;  
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function StmtListNode::eval, env
    @ast_error_handler

    ret = !NULL
    foreach node, self.operands, ii do ret = node.eval(env)
    return, ret
end

function StmtListNode::print_helper
    return, self.name()
end

function StmtListNode::init, lexer
    if ~self->AstNode::init(lexer) then return, 0
    return, 1
end

pro StmtListNode__define, class
    class = {StmtListNode, inherits AstNode }
end
