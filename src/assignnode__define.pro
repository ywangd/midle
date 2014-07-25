; docformat = 'rst'

;+
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function AssignNode::eval, env
    lhs = self.operands[0]
    rhs = self.operands[1]

    rhsval = rhs.eval(env)

    ; lhs must be one of the followings:
    ;   1. identifier
    ;   2. identifier with subscript, e.g. a[42,22]
    ;   3. identifier of structure with dot notation for field access subscript,
    ;      e.g. s.x[0] = 99 where s = {x: indgen(10)}
    ;   4. identifier with dot notation for indexing a hash like object or struct, e.g. h.x

    if n_elements(env) eq 0 then env = Dictionary()

    target = lhs
    targetVal = rhsval

    ; Recusively process any subscripts, dots till an identifier is reached
    while ~isa(target, 'IdentNode') do begin

        if isa(target, 'SubscriptNode') then begin
            host = (target.operands)[0]
            hostVal = host.eval(env)
            subs = (target.operands)[1]
            list_of_indexnode = subs.operands
            nsubs = list_of_indexnode.count()
            
            ; Get any hash or list element till a non-hash/list reached or subscripts exhausted
            ii = 0 & parentVal = hostVal & curVal = hostVal
            while (isa(curVal, 'Hash') || isa(curVal, 'List')) && ii lt nsubs do begin
                index = list_of_indexnode[ii]
                sub = index.eval(env, isRange=isr)
                ; Build the range subscripts from its start, end spec
                if isr then sub = (lindgen(curVal.count()))[sub[0]:sub[1]:sub[2]]
                parentVal = curVal
                if ii eq nsubs -1 then curVal[sub] = targetVal else curVal = curVal[sub]
                ii += 1
            endwhile

            ; If the program reach here, it is either at the end of the subscripts or
            ; the current collection element is no longer a Hash or List
            if ii lt nsubs then begin
                shp = size(curVal, /dimension)
                if isa(shp, /scalar) then shp = [1]
                idxlist = subs.eval(env, isRanges=isRanges, fromIndex=ii)
                index = arraycut(lindgen(shp), isRanges, idxlist)
                curVal[index] = targetVal
                if ii eq 0 then begin ; an array subscript directly in env
                    targetVal = curVal
                endif else begin ; an array subscript inside a list or hash
                    parentVal[sub] = curVal
                    ; the value put back to next loop is the this loop's top level hash/list
                    targetVal = hostVal
                endelse
            endif else begin
                targetVal = hostVal
            endelse

            target = host

        endif else if isa(target, 'MemberNode') then begin
            host = (target.operands)[0]
            member = (target.operands)[1]
            hostVal = host.eval(env)

            if isa(hostVal, 'Hash') then begin
                memberName = member.eval(env, /lexeme)
                hostVal[memberName] = targetVal

            endif else if isa(hostVal, 'Struct') then begin
                if isa(member, 'IdentNode') then begin  ; struct.field
                    memberName = member.eval(env, /lexeme)
                    idx = where(tag_names(hostVal) eq strupcase(memberName), count)
                    if count gt 0 then hostVal.(idx[0]) = targetVal else self.error, 'Field does not exist: ' + memberName
                endif else begin  ; struct.(index)
                    memberVal = member.eval(env)
                    hostVal.(memberVal) = targetVal
                endelse

            endif else begin
                self.error, 'Invalid LHS variable for assignment'
            endelse

            target = host
            targetVal = hostVal

        endif else begin
            self.error, 'Invalid LHS variable for assignment'
        endelse

    endwhile

    ; An identifier is reached, we are now at the top level of the LHS variable
    ; It should be directly under the env variable
    varname = target.eval(env, /lexeme)
    env[varname] = targetVal

    return, rhsval

end


function AssignNode::print_helper
    return, self.name()
end

function AssignNode::init, start_pos, lhs, rhs
    if ~self->AstNode::init(start_pos) then return, 0
    self.operands.add, lhs
    self.operands.add, rhs
    return, 1
end


pro AssignNode__define, class
    class = {AssignNode, inherits AstNode }
end
