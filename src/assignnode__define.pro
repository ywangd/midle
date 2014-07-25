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
    ;   2. identifier with non-chaining subscript, e.g. a[42,22]
    ;   3. identifier of structure with dot notation for field access and non-chaining subscript,
    ;      e.g. s.x[0] = 99 where s = {x: indgen(10)}
    ;   4. identifier with dot notation for indexing a hash like object or struct, e.g. h.x

    if n_elements(env) eq 0 then env = Dictionary()

    if isa(lhs, 'IdentNode') then begin
        varname = lhs.eval(env, /lexeme)
        env[varname] = rhsval

    endif else if isa(lhs, 'SubscriptNode') then begin
        host = lhs.eval_lhs(env, subs=subs, list_of_indexnode=list_of_indexnode)
        nsubs = list_of_indexnode.count()
        
        ; Check whether the assignment is to an array element inside a structure
        if isa(host, 'MemberNode') then begin
            
            structHost = host.eval_lhs(env, member=structField)
            if ~isa(structHost, 'IdentNode') then self.error, 'Invalid LHS variable for assignment'
            structHostName = structHost.eval(env, /lexeme)
            structHostVal = structHost.eval(env)
            if ~isa(structHostVal, 'Struct') then self.error, 'Invalid LHS variable for assignment'
            
            if isa(structField, 'IdentNode') then begin
                structFieldName = structField.eval(env, /lexeme)
                idxToStruct = where(tag_names(structHostVal) eq strupcase(structFieldName), count)
                if count eq 0 then self.error, 'Struct field does not exist: ' + structFieldName
                idxToStruct = idxToStruct[0]
            endif else begin
                idxToStruct = structField.eval(env)
            endelse
            
            ; Calcualte the indices for the assignment values
            shp = size(host.eval(env), /dimension)
            if isa(shp, /scalar) then shp = [1]
            idxlist = subs.eval(env, isRanges=isRanges)
            index = arraycut(lindgen(shp), isRanges, idxlist)
            
            structHostVal.(idxToStruct)[index] = rhsval
            env[structHostName] = structHostVal
            
        endif else begin ; for subscripts to identifiers
            
            if ~isa(host, 'IdentNode') then self.error, 'Invalid LHS variable for assignment'
            hostName = host.eval(env, /lexeme)
            if ~env.haskey(hostName) then self.error, 'Undefined variable: ' + hostName

            ; Hash and List are references and can be retrieved safely without creating
            ; new copies
            hostVal = env[hostName]
            ii = 0 & parentVal = hostVal
            ; Error handling for subscript range error
            catch, theError
            if theError ne 0 then begin
                catch, /cancel
                if !error_state.name eq 'IDL_M_ILLGL_RANGE' then begin
                    self.error, 'Illegal subscript range'
                endif else message, /reissue_last
            endif
            while (isa(hostVal, 'Hash') || isa(hostVal, 'List')) && ii lt nsubs do begin
                index = list_of_indexnode[ii]
                sub = index.eval(env, isRange=isr)
                ; Build the range subscripts from its start, end spec
                if isr then sub = (lindgen(hostVal.count()))[sub[0]:sub[1]:sub[2]]
                ii += 1
                parentVal = hostVal
                if (isa(hostVal, 'Hash') && hostVal.haskey(sub)) || (isa(hostVal, 'List') && max(sub) lt hostVal.count()) then begin
                    hostVal = hostVal[sub]
                endif else begin
                    if ii eq nsubs then break else self.error, 'Key does not exist: ' + sub
                endelse
            endwhile
            ; If the program reach here, it is either at the end of the subscripts or
            ; the current child/grand child element is no longer a Hash or List
            if ii ge nsubs then begin
                parentVal[sub] = rhsval
            endif else begin
                shp = size(hostVal, /dimension)
                if isa(shp, /scalar) then shp = [1]
                idxlist = subs.eval(env, isRanges=isRanges, fromIndex=ii)
                index = arraycut(lindgen(shp), isRanges, idxlist)
                
                if ii eq 0 then begin ; an array subscript directly in env
                    env[hostName, index] = rhsval
                endif else begin ; an array subscript inside a list or hash
                    parentVal[sub, index] = rhsval
                endelse
            endelse
        endelse
        

    endif else if isa(lhs, 'MemberNode') then begin
        host = lhs.eval_lhs(env, member=member)
        if ~isa(host, 'IdentNode') then self.error, 'Invalid LHS variable for assignment'
        hostName = host.eval(env, /lexeme)
        if ~env.haskey(hostName) then self.error, 'Variable ' + hostName + ' does not exist'

        if isa(env[hostName], 'Hash') then begin
            if ~isa(member, 'IdentNode') then self.error, 'Invalid object property name'
            memberName = member.eval(env, /lexeme)
            env[hostName, memberName] = rhsval

        endif else if isa(env[hostName], 'Struct') then begin
            if isa(member, 'IdentNode') then begin
                memberName = member.eval(env, /lexeme)
                tempVar = env[hostName]
                idx = where(tag_names(tempVar) eq strupcase(memberName), count)
                if count gt 0 then begin
                    tempVar.(idx[0]) = rhsval
                    env[hostName] = tempVar
                endif else begin
                    self.error, 'Field ' + memberName + ' does not exist'
                endelse

            endif else begin
                memberVal = member.eval(env)
                if n_elements(memberVal) eq 1 then begin
                    tempVar = env[hostName]
                    tempVar.(memberVal) = rhsval
                    env[hostName] = tempVar
                endif else begin
                    self.error, 'Field indexing must be a scalar or one element array'
                endelse
            endelse
        endif

    endif else begin
        self.error, 'Invalid LHS variable for assignment'
    endelse

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
