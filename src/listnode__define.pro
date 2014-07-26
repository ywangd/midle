; docformat = 'rst'

;+
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function ListNode::eval, env
    @ast_error_handler

    TOKEN = self.lexer.TOKEN

    if self.operator eq TOKEN.T_HASH_LCURLY then begin
        
        ret = hash()
        for i = 0, self.operands.count()-1, 2 do begin
            key = (self.operands[i]).eval(env)
            if isa(key, /number, /scalar) || isa(key, 'String', /scalar) then begin
                ret[key] = (self.operands[i+1]).eval(env)
            endif else begin
                message, 'Invalid Hash key:' + strtrim(key,2), /noname
            endelse
        endfor

    endif else if self.operator eq TOKEN.T_LCURLY then begin
        
        ret = {}
        for i = 0, self.operands.count()-1, 2 do begin
            key = self.operands[i]
            if ~isa(key, 'IdentNode') then message, 'Invalid structure field name', /noname
            keyName = key.eval(env, /lexeme)
            ret = create_struct(ret, keyName, (self.operands[i+1]).eval(env))
        endfor
        
    endif else begin  ; 'T_LPAREN
        ret = list()
        foreach operand, self.operands do ret.add, operand.eval(env)
    endelse

    return, ret
end

function ListNode::print_helper
    return, string(self.name(), strupcase((self.lexer.TOKEN.where(self.operator))[0]), $
        format='(A, " ''",A,"''")')
end


function ListNode::init, start_pos, operator, node
    if ~self->AstNode::init(start_pos) then return, 0
    self.operator = operator
    if n_elements(node) ne 0 then self.operands.add, node
    return, 1
end

pro ListNode__define, class
    class = {ListNode, inherits AstNode, $
        operator: 0 }
end
