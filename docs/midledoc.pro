
pro midledoc

    root = file_dirname(mg_src_root())
    
    changesFile = filepath('CHANGES.md', root=root)
    
    openr, lun, changesFile, /get_lun
    line = ''
    while ~eof(lun) do begin
        readf, lun, line
        if strmid(line, 0, 10) eq '## Version' then begin
            fields = strsplit(line, /extract)
            version = fields[2]
            releaseDate = fields[3]
            break
        endif
    endwhile
    free_lun, lun

    idldoc, root=filepath('src', root=root), $
        output=filepath('docs', root=root), $
        title='Documentation for MIDLE v'+ version, $
        subTitle='release date: ' + releaseDate, $
        ;/statistics, index_level=1, $
        overview=filepath('overview',root=mg_src_root()), $
        /embed, /nosource, $
        format_style='rst', markup_style='rst'


end