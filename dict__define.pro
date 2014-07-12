function Dict::haskey, theKey
    return, self->Hash::haskey(strlowcase(theKey))
end

pro Dict::getProperty, _ref_extra=extra
    foreach tag, extra, idx do begin
        (scope_varfetch(tag, /ref_extra)) = self[strlowcase(tag)]
    endforeach
end

pro Dict::setProperty, _extra=extra
    foreach tag, tag_names(extra), idx do begin
        self[strlowcase(tag)] = extra.(idx)
    endforeach
end

function Dict::init, inputHash
    if ~(self->hash::init()) then return, 0

    if n_elements(inputHash) ne 0 then begin
        foreach val, inputHash, key do begin
            if ~isa(key, 'STRING') then message, 'Keys must be valid IDL names'
            key_cleaned = strlowcase(idl_validname(key))
            if key_cleaned eq '' then message, 'Keys must be valid IDL names'
            self[key_cleaned] = val
        endforeach
        obj_destroy, inputHash
    endif 

    return, 1
end

pro Dict__define, class
    class = {Dict, inherits Hash}
        
end

