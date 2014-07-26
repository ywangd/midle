; docformat = 'rst'

;+
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

; The range index returned from this method is a range spec, not the actual
; list of numbers, i.e. it takes form of [start, end, step]
function IndexNode::eval, env, isRange=isRange
    compile_opt logical_predicate
    @ast_error_handler

    isRange = 0
    
    if self.operands.count() eq 1 then begin ; subscript has only one element, i.e. 1 or 'x', etc, or *
        if isa(self.operands[0], 'WildcardNode') then begin
            index = [0,-1,1]
            isRange = 1
        endif else begin
            index = (self.operands[0]).eval(env)
        endelse

    endif else begin ; subscript has 2 or more elements, i.e. 0:9, 0:9:2

        isRange = 1
        if isa(self.operands[0], 'WildcardNode') then message, 'Invalid *:n subscript', /noname
        
        index = [(self.operands[0]).eval(env)]
        index = [index, isa(self.operands[1], 'WildcardNode') ? -1 : (self.operands[1]).eval(env)]
        
        if self.operands.count() gt 2 then begin
            if ~isa(self.operands[2], 'WildcardNode') then begin
                index = [index, (self.operands[2]).eval(env)]
            endif else begin
                message, 'Invalid n:n:* subscript', /noname
            endelse
        endif else index = [index, 1]

    endelse

    return, index
end

function IndexNode::print_helper
    return, self.name()
end

function IndexNode::init, start_pos
    if ~self->AstNode::init(start_pos) then return, 0
    return, 1
end

pro IndexNode__define, class
    class = {IndexNode, inherits AstNode }
end
