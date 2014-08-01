; docformat = 'rst'

;+
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function FuncCallNode::eval, env
    compile_opt logical_predicate
    @ast_error_handler

    func = self.operands[0]
    p = (self.operands[1]).eval(env, k=k)
    nk = n_elements(k)
    
    if isa(func, 'IdentNode') then begin
        funcname = func.eval(env, /lexeme)
        catch, theError
        if theError ne 0 then begin
            catch, /cancel
            if !error_state.name eq 'IDL_M_UPRO_UNDEF' then begin
                case p.count() of
                    0: return, nk ? call_function('obj_new', funcname, _extra=k) : call_function('obj_new', funcname)
                    1: return, nk ? call_function('obj_new', funcname, p[0], _extra=k) : call_function('obj_new', funcname, p[0])
                    2: return, nk ? call_function('obj_new', funcname, p[0], p[1],  _extra=k) : call_function('obj_new', funcname, p[0], p[1])
                    3: return, nk ? call_function('obj_new', funcname, p[0], p[1], p[2], _extra=k) : call_function('obj_new', funcname, p[0], p[1], p[2])
                    4: return, nk ? call_function('obj_new', funcname, p[0], p[1], p[2], p[3], _extra=k) : call_function('obj_new', funcname, p[0], p[1], p[2], p[3])
                    5: return, nk ? call_function('obj_new', funcname, p[0], p[1], p[2], p[3], p[4], _extra=k) : call_function('obj_new', funcname, p[0], p[1], p[2], p[3], p[4])
                    6: return, nk ? call_function('obj_new', funcname, p[0], p[1], p[2], p[3], p[4], p[5], _extra=k) : call_function('obj_new', funcname, p[0], p[1], p[2], p[3], p[4], p[5])
                    7: return, nk ? call_function('obj_new', funcname, p[0], p[1], p[2], p[3], p[4], p[5], p[6], _extra=k) : call_function('obj_new', funcname, p[0], p[1], p[2], p[3], p[4], p[5], p[6])
                    8: return, nk ? call_function('obj_new', funcname, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], _extra=k) : call_function('obj_new', funcname, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7])
                    9: return, nk ? call_function('obj_new', funcname, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], _extra=k) : call_function('obj_new', funcname, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8])
                    else: message, 'Too many positional arguments', /noname
                endcase
            endif else message, /reissue_last
        endif
        case p.count() of
            0: return, nk ? call_function(funcname, _extra=k) : call_function(funcname) 
            1: return, nk ? call_function(funcname, p[0], _extra=k) : call_function(funcname, p[0])
            2: return, nk ? call_function(funcname, p[0], p[1],  _extra=k) : call_function(funcname, p[0], p[1])
            3: return, nk ? call_function(funcname, p[0], p[1], p[2], _extra=k) : call_function(funcname, p[0], p[1], p[2])
            4: return, nk ? call_function(funcname, p[0], p[1], p[2], p[3], _extra=k) : call_function(funcname, p[0], p[1], p[2], p[3])
            5: return, nk ? call_function(funcname, p[0], p[1], p[2], p[3], p[4], _extra=k) : call_function(funcname, p[0], p[1], p[2], p[3], p[4])
            6: return, nk ? call_function(funcname, p[0], p[1], p[2], p[3], p[4], p[5], _extra=k) : call_function(funcname, p[0], p[1], p[2], p[3], p[4], p[5])
            7: return, nk ? call_function(funcname, p[0], p[1], p[2], p[3], p[4], p[5], p[6], _extra=k) : call_function(funcname, p[0], p[1], p[2], p[3], p[4], p[5], p[6])
            8: return, nk ? call_function(funcname, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], _extra=k) : call_function(funcname, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7])
            9: return, nk ? call_function(funcname, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], _extra=k) : call_function(funcname, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8])
            else: message, 'Too many positional arguments', /noname
        endcase
        
    endif else if isa(func, 'MemberNode') then begin
        objref = func.eval(env, member=member, /lexeme)
        case p.count() of
            0: return, nk ? call_method(member, objref, _extra=k) : call_method(member, objref)
            1: return, nk ? call_method(member, objref, p[0], _extra=k) : call_method(member, objref, p[0])
            2: return, nk ? call_method(member, objref, p[0], p[1],  _extra=k) : call_method(member, objref, p[0], p[1])
            3: return, nk ? call_method(member, objref, p[0], p[1], p[2], _extra=k) : call_method(member, objref, p[0], p[1], p[2])
            4: return, nk ? call_method(member, objref, p[0], p[1], p[2], p[3], _extra=k) : call_method(member, objref, p[0], p[1], p[2], p[3])
            5: return, nk ? call_method(member, objref, p[0], p[1], p[2], p[3], p[4], _extra=k) : call_method(member, objref, p[0], p[1], p[2], p[3], p[4])
            6: return, nk ? call_method(member, objref, p[0], p[1], p[2], p[3], p[4], p[5], _extra=k) : call_method(member, objref, p[0], p[1], p[2], p[3], p[4], p[5])
            7: return, nk ? call_method(member, objref, p[0], p[1], p[2], p[3], p[4], p[5], p[6], _extra=k) : call_method(member, objref, p[0], p[1], p[2], p[3], p[4], p[5], p[6])
            8: return, nk ? call_method(member, objref, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], _extra=k) : call_method(member, objref, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7])
            9: return, nk ? call_method(member, objref, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], _extra=k) : call_method(member, objref, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8])
            else: message, 'Too many positional arguments', /noname
        endcase
    endif else begin
        message, 'Invalid function call', /noname
    endelse

end


function FuncCallNode::print_helper
    return, string(self.name(), format='(A)')
end


function FuncCallNode::init, lexer, func, arglist
    if ~self->AstNode::init(lexer) then return, 0
    self.operands.add, func
    self.operands.add, arglist
    return, 1
end

pro FuncCallNode__define, class
    class = {FuncCallNode, inherits AstNode }
end
