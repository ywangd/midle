; A custom implementation of Dictionary of IDL 8.3, so that some programs 
; can run with 8.2 
; Keys must be valid IDL variable names
; Case insensitive

function Dictionary::haskey, theKey
    return, self->Hash::haskey(strlowcase(theKey))
end

pro Dictionary::_overloadBracketsLeftSide, objref, value, isrange, $
    sub1, sub2, sub3, sub4, sub5, sub6, sub7, sub8

    if ~isa(sub1, 'STRING') || idl_validname(sub1) ne sub1 then $
        message, 'Keys must be valid IDL names'
    sub1 = strlowcase(sub1)
    self->hash::_overloadBracketsLeftSide, objref, value, isrange, sub1, sub2, sub3, sub4, sub5, sub6, sub7, sub8

end

function Dictionary::_overloadBracketsRightSide, isRange, $
    sub1, sub2, sub3, sub4, sub5, sub6, sub7, sub8

    if ~isa(sub1, 'STRING') || idl_validname(sub1) ne sub1 then $
        message, 'Keys must be valid IDL names'
    sub1 = strlowcase(sub1)
    return, self->hash::_overloadBracketsRightSide(isRange, sub1, sub2, sub3, sub4, sub5, sub6, sub7, sub8)

end

pro Dictionary::getProperty, _ref_extra=extra
    foreach tag, strlowcase(extra), idx do begin
        (scope_varfetch(tag, /ref_extra)) = self[tag]
    endforeach
end

pro Dictionary::setProperty, _extra=extra
    tags = strlowcase(tag_names(extra))
    foreach tag, tags, idx do begin
        self[tag] = extra.(idx)
    endforeach
end

function Dictionary::init, inputHash
    if ~(self->hash::init()) then return, 0

    if n_elements(inputHash) ne 0 then begin
        foreach val, inputHash, key do begin
            if ~isa(key, 'STRING') || idl_validname(key) ne key then $
                message, 'Keys must be valid IDL names'
            self[strlowcase(key)] = val
        endforeach
        obj_destroy, inputHash
    endif

    return, 1
end

pro Dictionary__define, class
    class = {Dictionary, inherits hash}

end

