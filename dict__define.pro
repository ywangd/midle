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


pro Dict__define, class
    class = {Dict, inherits Hash}
        
end
