; docformat = 'rst'

;+
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function ArrayLiteralNode::eval, env
    compile_opt logical_predicate
    @ast_error_handler
    
    ; Evalulate the list item and record the level of concatenation
    ; Level of concatenation is the minimum level of child nodes plus one.
    ; Only ArrayLiteralNode has the level attribute. If all child nodes are
    ; not ArrayLiteralNode, the parent's level is 1. If the child nodes have
    ; both ArrayLiteralNode and non-ArrayLiteralNode, the parent's level is 0.
    ; The algorithm can be better understood with the aid of a tree diagram.    
    items = list()
    hasArrayLiteralChild = 0
    hasNonArrayLiteralChild = 0
    level = 99
    foreach operand, self.operands do begin
        items.add, operand.eval(env)
        if isa(operand, 'ArrayLiteralNode') then begin
            hasArrayLiteralChild = 1
            level = (level lt operand.level) ? level : operand.level
        endif else begin
            hasNonArrayLiteralChild = 1
        endelse
    endforeach

    ; Note the ArrayLiteralNode have at least one child node. This is ensured
    ; by the parser as all empty [] is parsed to be !NULL directly.
    if hasArrayLiteralChild && hasNonArrayLiteralChild then begin ; mixed content
        self.level = 0
    endif else if hasNonArrayLiteralChild eq 1 then begin ; only non-array-literal nodes
        self.level = 1
    endif else begin ; only array-literal nodes
        self.level = level + 1
    endelse
    
    ; Level 0 is the same as level 1 for concatenation. Their difference is
    ; only meaningful to the parents when calculating parent's level.
    ret = []
    foreach item, items do begin
        ret = arrayconcat(ret, item, dimension=self.level eq 0 ? 1 : self.level)
    endforeach
    
    return, ret
    
end


function ArrayLiteralNode::print_helper
    return, self.name()
end

pro ArrayLiteralNode::getProperty, level=level
    level = self.level
end


function ArrayLiteralNode::init, lexer
    if ~self->AstNode::init(lexer) then return, 0
    return, 1
end

pro ArrayLiteralNode__define, class
    class = {ArrayLiteralNode, inherits AstNode, $
        level: 0}
end
