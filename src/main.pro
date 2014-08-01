
pro midle_console_input, event
    widget_control, event.id, get_value=code
    widget_control, event.top, get_uvalue=info, /no_copy
    
    
    nlines0 = file_lines(info.session_log)
    
    env = info.env
    ret = midle(code, env)
    info.env = env
    
    flush, !journal
    openr, lun, info.session_log, /get_lun
    skip_lun, lun, nlines0, /lines
    lines = []
    theLine = ''
    while ~eof(lun) do begin
        readf, lun, theLine
        if strmid(theLine, 0, 1) eq ';' then theLine = strmid(theLine, 1)
        lines = [lines, theLine]
    endwhile
    free_lun, lun
    
    widget_control, event.id, set_value=''
    widget_control, info.echo, set_value=[code, isa(ret, /null) ? '!NULL' : string(ret, /print), lines], /append
    widget_control, info.echo, get_value=echo_lines
    top_line = n_elements(echo_lines) - 30
    if top_line gt 0 then widget_control, info.echo, set_text_top_line = top_line+1
    
    widget_control, event.top, set_uvalue=info, /no_copy
end


pro midle_console_exit, event
    widget_control, event.top, /destroy
    print, 'bye'
end


pro midle_console_tlb_handler, event
end

pro midle_console_cleanup, tlb
    journal
    print, 'cleanup'
end

;+
; :Description:
;    A test GUI for running in Virtual Machine.
;-
pro main
    
    tlb = widget_base(column=1, tlb_size_event=0, title='MIDLE Console', mbar=menubarID)
    mid_file = widget_button(menubarID, Value='File', /menu)
    mid_exit = widget_button(mid_file, Value='Exit', event_pro='midle_console_exit')
    
    xsize_workable_area = 120
    echo = widget_text(tlb, uname='echo', xsize=xsize_workable_area, ysize=30, /scroll)
    input = widget_text(tlb, xsize=xsize_workable_area, ysize=1, /editable, event_pro='midle_console_input')
    
    session_log = filepath('midle_session.pro', root=getenv('IDL_TMPDIR'))
    print, 'Session Log: ', session_log
    
    info = dictionary()
    info.env = dictionary()
    info.echo = echo
    info.session_log = session_log
    
    widget_control, tlb, set_uvalue=info, /no_copy
    widget_control, tlb, /realize
    
    xmanager, 'midle_console', tlb, /no_block, event_handler='midle_console_tlb_handler', cleanup='midle_console_cleanup'
    
    journal, session_log
    flush, !journal
    openr, lun, session_log, /get_lun
    lines = []
    theLine = ''
    while ~eof(lun) do begin
        readf, lun, theLine
        lines = [lines, theLine]
    endwhile
    free_lun, lun
    widget_control, echo, set_value=lines

end

main

end

