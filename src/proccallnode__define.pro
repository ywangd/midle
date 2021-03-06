; docformat = 'rst'

;+
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function ProcCallNode::eval, env
    compile_opt logical_predicate
    @ast_error_handler

    proc = self.operands[0]
    p = (self.operands[1]).eval(env, k=k)
    nk = n_elements(k)

    if isa(proc, 'IdentNode') then begin
        procname = proc.eval(env, /lexeme)
        case p.count() of
            0: if nk then call_procedure, procname, _extra=k else call_procedure, procname
            1: if nk then call_procedure, procname, p[0], _extra=k else call_procedure, procname, p[0]
            2: if nk then call_procedure, procname, p[0], p[1],  _extra=k else call_procedure, procname, p[0], p[1]
            3: if nk then call_procedure, procname, p[0], p[1], p[2], _extra=k else call_procedure, procname, p[0], p[1], p[2]
            4: if nk then call_procedure, procname, p[0], p[1], p[2], p[3], _extra=k else call_procedure, procname, p[0], p[1], p[2], p[3]
            5: if nk then call_procedure, procname, p[0], p[1], p[2], p[3], p[4], _extra=k else call_procedure, procname, p[0], p[1], p[2], p[3], p[4]
            6: if nk then call_procedure, procname, p[0], p[1], p[2], p[3], p[4], p[5], _extra=k else call_procedure, procname, p[0], p[1], p[2], p[3], p[4], p[5]
            7: if nk then call_procedure, procname, p[0], p[1], p[2], p[3], p[4], p[5], p[6], _extra=k else call_procedure, procname, p[0], p[1], p[2], p[3], p[4], p[5], p[6]
            8: if nk then call_procedure, procname, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], _extra=k else call_procedure, procname, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]
            9: if nk then call_procedure, procname, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], _extra=k else call_procedure, procname, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8]
            else: message, 'Too many positional arguments', /noname
        endcase

    endif else if isa(proc, 'MemberNode') then begin
        objref = proc.eval(env, member=member, /lexeme)
        case p.count() of
            0: if nk then call_method, member, objref, _extra=k else call_method, member, objref
            1: if nk then call_method, member, objref, p[0], _extra=k else call_method, member, objref, p[0]
            2: if nk then call_method, member, objref, p[0], p[1],  _extra=k else call_method, member, objref, p[0], p[1]
            3: if nk then call_method, member, objref, p[0], p[1], p[2], _extra=k else call_method, member, objref, p[0], p[1], p[2]
            4: if nk then call_method, member, objref, p[0], p[1], p[2], p[3], _extra=k else call_method, member, objref, p[0], p[1], p[2], p[3]
            5: if nk then call_method, member, objref, p[0], p[1], p[2], p[3], p[4], _extra=k else call_method, member, objref, p[0], p[1], p[2], p[3], p[4]
            6: if nk then call_method, member, objref, p[0], p[1], p[2], p[3], p[4], p[5], _extra=k else call_method, member, objref, p[0], p[1], p[2], p[3], p[4], p[5]
            7: if nk then call_method, member, objref, p[0], p[1], p[2], p[3], p[4], p[5], p[6], _extra=k else call_method, member, objref, p[0], p[1], p[2], p[3], p[4], p[5], p[6]
            8: if nk then call_method, member, objref, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], _extra=k else call_method, member, objref, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]
            9: if nk then call_method, member, objref, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], _extra=k else call_method, member, objref, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8]
            else: message, 'Too many positional arguments', /noname
        endcase
    endif else begin
        message, 'Invalid procedure call', /noname
    endelse

    return, !NULL
end


function ProcCallNode::print_helper
    return, string(self.name(), format='(A)')
end


function ProcCallNode::init, lexer, proc, arglist
    if ~self->AstNode::init(lexer) then return, 0
    self.operands.add, proc
    self.operands.add, arglist
    return, 1
end

pro ProcCallNode__define, class
    class = {ProcCallNode, inherits AstNode }
end
