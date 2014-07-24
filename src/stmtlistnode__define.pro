; docformat = 'rst'

;+
; The statment list node is the top level node of the syntax tree.
;  
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function StmtListNode::eval, env
    ret = !NULL
    foreach node, self.operands, ii do ret = node.eval(env)
    return, ret
end

function StmtListNode::print_helper
    return, self.name()
end

function StmtListNode::init, start_pos
    if ~self->AstNode::init(start_pos) then return, 0
    return, 1
end

pro StmtListNode__define, class
    class = {StmtListNode, inherits AstNode }
end