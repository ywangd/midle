;+
; :Description:
;    Read the input file and recursively expand any file inclusion in place.
;    File inclusion is denoted by a leading @ symbol, e.g. @included_file.
;    
; :Author:
;   Yang Wang (ywangd@gmail.com)
;
; :Returns:
;   A string array containing contents from the given file and any included file.
;   
; :Params:
;    _filename : in, required, type=String
;       The input file to read
;
;-
function midleRead, _filename

    hits = file_search(_filename, count=count, /fully_qualify_path)
    if count eq 0 then message, 'file not found: ' + _filename

    filename = hits[0]
    path = file_dirname(filename)

    nlines = file_lines(filename)
    lines = strarr(nlines)
    openr, lun, filename, /get_lun
    readf, lun, lines
    free_lun, lun

    ; Search for the lines that are file includes
    ; The includes can take the form either with or without quotes
    ; e.g.
    ;    @example
    ;    @"example"
    ;    @'example'
    ; Any things that are not part of the include directive
    ; will be completely ignored.
    pattern = '^ *@("[^"]*"|''[^'']*''|[^ ;]*)'
    pos = stregex(lines, pattern, length=length)
    idx = where(pos ge 0, count)

    ; Expand any included files
    offset = 0L
    for ii=0, count-1 do begin

        ; The working index, note the addition of offset to count included lines
        ; However, the un-offsetted idx should still be used to index pos and length
        thisIdx = idx[ii] + offset

        ; get the included file name
        incfile = strtrim(strmid(lines[thisIdx], pos[idx[ii]], length[idx[ii]]),2)
        incfile = strmid(incfile, 1) ; get rid of @
        qchar = strmid(incfile, 0, 1) ; Do we have quotation around the included file?
        if qchar eq '"' or qchar eq '''' then $
            incfile = strtrim(strmid(incfile, 1, strlen(incfile)-2), 2)
        ;
        if incfile eq '' then message, 'include filename cannot be empty'

        ; Get the path qualified filename of the included file
        if strmid(incfile, 0, 1) eq '.' then begin ; leading dot indicates relative path for all OS
            incfile = filepath(incfile, root=path)
        endif else begin ; otherwise check system dependant absolute path syntax
            if (!VERSION.os_family eq 'Windows' && strmid(incfile, 1, 1) ne ':') $
                || strmid(incfile, 0, 1) ne '/' then incfile = filepath(incfile, root=path)
        endelse

        ; Recursively get the lines of the include file
        incLines = midleRead(incfile)

        ; insert the lines of the included file into proper position
        ; of the final lines array.
        if thisIdx gt 0 then h = lines[0:thisIdx-1] else h = []
        t = lines[thisIdx+1:*]
        lines = [h, incLines, t]
        ; We need to offset the subsequent index for the number of lines inserted
        ; and the one line removed
        offset += n_elements(incLines) - 1

    endfor

    return, lines

end

