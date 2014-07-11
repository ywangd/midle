
pro Dict::getProperty, _ref_extra=extra
    foreach tag, extra, idx do begin
        (scope_varfetch(tag, /ref_extra)) = self.content(strlowcase(tag))
    endforeach
end

pro Dict::setProperty, _extra=extra
    foreach tag, tag_names(extra), idx do begin
        self.content[strlowcase(tag)] = extra.(idx)
    endforeach
end


function Dict::init
    self.content = hash()
    return, 1
end


pro Dict__define, class
    class = {Dict, inherits IDL_Object, $
        content: obj_new() }
end