; docformat = 'rst'

;+
; A demo GUI application implementing a MIDLE console that can run in IDL
; Virtual Machine. 
; Hit 'Return' to execute code. Ctrl-P and Ctrl-N to navigate through input
; history.
; 
; :Author:
; 	Yang Wang (ywangd@gmail.com)
;-

pro midle_console_input, event

    if event.type eq 0 then begin
        if event.ch eq 10 then begin ; Return key is pressed
            ; get info first
            widget_control, event.top, get_uvalue=info, /no_copy
            ; get code input
            widget_control, event.id, get_value=code
            ; Add to history only if it is different from the last code input 
            if n_elements(info.history) eq 0 || (info.history)[-1] ne code then info.history.add, code
            info.history_idx = 0
            ; Number of lines in session log file before execution
            nlines0 = file_lines(info.session_log)
            env = info.env
            ret = midle(code, env)
            info.env = env
            ; Flush for any cached output
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
            ; Reset the input
            widget_control, event.id, set_value=''
            ; Echo the output
            widget_control, info.echo, set_value=[code, isa(ret, /null) ? '!NULL' : string(ret, /print), lines], /append
            ; Scroll the echo window if necessary
            widget_control, info.echo, get_value=echo_lines
            top_line = n_elements(echo_lines) - 30
            if top_line gt 0 then widget_control, info.echo, set_text_top_line = top_line+1
            ; put info back
            widget_control, event.top, set_uvalue=info, /no_copy
            
        endif else if event.ch eq 16 then begin ; ctrl-p
            widget_control, event.top, get_uvalue=info, /no_copy
            if n_elements(info.history) gt abs(info.history_idx) then begin
                if info.history_idx eq 0 then begin
                    widget_control, event.id, get_value=code
                    info.buffer = code
                endif 
                info.history_idx -= 1
                code = (info.history)[info.history_idx]
                widget_control, event.id, set_value=code
                widget_control, event.id, set_text_select=strlen(code)
            endif
            widget_control, event.top, set_uvalue=info, /no_copy
            
        endif else if event.ch eq 14 then begin ; ctrl-n
            widget_control, event.top, get_uvalue=info, /no_copy
            if info.history_idx lt 0 then begin
                info.history_idx += 1
                if info.history_idx eq 0 then code = info.buffer else code = (info.history)[info.history_idx]
                widget_control, event.id, set_value=code
                widget_control, event.id, set_text_select=strlen(code)
            endif
            widget_control, event.top, set_uvalue=info, /no_copy
            
        endif
    endif
    
end


pro midle_console_exit, event
    widget_control, event.top, /destroy
end


pro midle_console_tlb_handler, event
end

pro midle_console_cleanup, tlb
    journal
end


pro main
    
    tlb = widget_base(column=1, tlb_size_event=0, title='MIDLE Console', mbar=menubarID)
    mid_file = widget_button(menubarID, Value='File', /menu)
    mid_exit = widget_button(mid_file, Value='Exit', event_pro='midle_console_exit')
    
    xsize_workable_area = 120
    echo = widget_text(tlb, uname='echo', xsize=xsize_workable_area, ysize=30, /scroll)
    input = widget_text(tlb, xsize=xsize_workable_area, ysize=1, /editable, /all_event, event_pro='midle_console_input')
    
    session_log = filepath('midle_session.pro', root=getenv('IDL_TMPDIR'))
    print, 'Session Logfile: ', session_log
    
    info = dictionary()
    info.env = dictionary()
    info.history = list()
    info.history_idx = 0
    info.buffer = ''
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

