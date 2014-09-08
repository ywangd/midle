; docformat = 'rst'

;+
; A GUI application implementing a MIDLE console. 
; In main editor:
;   F5 - Run
;   Ctrl-F5 - Run selection
; In command input line:
;   Return - Run
;   Ctrl-P - previous command 
;   Ctrl-N - next command
; 
; :Author:
; 	Yang Wang (ywangd@gmail.com)
;-

pro midlegui_eval, info, code, log_history=log_history
    if keyword_set(log_history) then begin
        ; Add to history only if it is different from the last code input 
        if n_elements(info.history) eq 0 || (info.history)[-1] ne code then info.history.add, code
        info.history_idx = 0
    endif
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

    ; Echo the output
    widget_control, info.echo, set_value=[isa(ret, /null) ? '!NULL' : string(ret, /print), lines], /append
    ; Scroll the echo window if necessary
    widget_control, info.echo, get_value=echo_lines
    top_line = n_elements(echo_lines) - 10
    if top_line gt 0 then widget_control, info.echo, set_text_top_line = top_line+1
end

pro midlegui_open, event
    widget_control, event.top, get_uvalue=info, /no_copy
    filename = dialog_pickfile(/read, path=file_dirname(info.filename), title='Select MIDLE script file')
    if filename ne '' then begin
        openr, lun, filename, /get_lun
        lines = []
        theLine = ''
        while ~eof(lun) do begin
            readf, lun, theLine
            lines = [lines, theLine]
        endwhile
        free_lun, lun
        widget_control, info.editor, set_value=lines
        info.filename = filename
    endif
    widget_control, event.top, set_uvalue=info, /no_copy
end

pro midlegui_save, event
    widget_control, event.top, get_uvalue=info, /no_copy
    widget_control, info.editor, get_value=code
    if info.filename eq '' then begin
        filename = dialog_pickfile(/write, title='Save script')
        if filename ne '' then info.filename = filename
    endif
    if info.filename ne '' then begin
        openw, lun, info.filename, /get_lun
        foreach line, code do printf, lun, line
        free_lun, lun
    endif
    widget_control, event.top, set_uvalue=info, /no_copy
end

pro midlegui_saveas, event
    widget_control, event.top, get_uvalue=info, /no_copy
    filename = dialog_pickfile(/write, title='Save script as')
    if filename ne '' then begin
        info.filename = filename
        midlegui_save, event
    endif
    widget_control, event.top, set_uvalue=info, /no_copy
end

pro midlegui_run, event
    widget_control, event.top, get_uvalue=info, /no_copy
    widget_control, info.editor, get_value=code
    midlegui_eval, info, code
    widget_control, event.top, set_uvalue=info, /no_copy
end

pro midlegui_runsel, event
    widget_control, event.top, get_uvalue=info, /no_copy
    widget_control, info.editor, get_value=code
    pos = widget_info(info.editor, /text_select)
    codesel = strmid(code, pos[0], pos[1])
    midlegui_eval, info, codesel
    widget_control, event.top, set_uvalue=info, /no_copy
end

pro midlegui_about, event
    ok = dialog_message('Mini IDL Evaluator Console', title='About', /information, dialog_parent=event.top)
end

pro midlegui_cmdline, event

    if event.type eq 0 then begin
        if event.ch eq 10 then begin ; Return key is pressed
            ; get info first
            widget_control, event.top, get_uvalue=info, /no_copy
            ; get code input
            widget_control, event.id, get_value=code
            ; Evalulate the code
            midlegui_eval, info, code, /log_history
            ; Reset the input
            widget_control, event.id, set_value=''
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


pro midlegui_exit, event
    widget_control, event.top, /destroy
end


pro midlegui_tlb_handler, event
end

pro midlegui_cleanup, tlb
    journal
end


pro midlegui, group_leader=group_leader
    
    tlb = widget_base(column=1, tlb_size_event=0, title='MIDLE Console', mbar=menubarID, $
        tlb_frame_attr=1, group_leader=group_leader)

    mid_file = widget_button(menubarID, Value='File', /menu)
    mid_open = widget_button(mid_file, Value='Open...', accelerator='Alt+O', event_pro='midlegui_open') 
    mid_save = widget_button(mid_file, Value='Save', accelerator='Alt+S', event_pro='midlegui_save') 
    mid_save = widget_button(mid_file, Value='Save As...', event_pro='midlegui_saveas') 
    mid_exit = widget_button(mid_file, Value='Exit', /separator, accelerator='Alt+X', event_pro='midlegui_exit')
    
    mid_runm = widget_button(menubarID, Value='Run', /menu)
    mid_run = widget_button(mid_runm, Value='Run', accelerator='F5', event_pro='midlegui_run') 
    mid_runsel = widget_button(mid_runm, Value='Run selection', accelerator='Ctrl+F5', event_pro='midlegui_runsel') 

    mid_help = widget_button(menubarID, Value='Help', /menu)
    mid_about = widget_button(mid_help, Value='About', event_pro='midlegui_about') 

    xsize_workable_area = 120
    editor = widget_text(tlb, uname='editor', xsize=xsize_workable_area, ysize=30, /scroll, /editable)
    echo = widget_text(tlb, uname='echo', xsize=xsize_workable_area, ysize=10, /scroll)
    cmdline = widget_text(tlb, xsize=xsize_workable_area, ysize=1, /editable, /all_event, event_pro='midlegui_cmdline')
    
    session_log = filepath('midle_session.pro', root=getenv('IDL_TMPDIR'))
    print, 'Session Logfile: ', session_log
    
    info = dictionary()
    info.env = dictionary()
    info.history = list()
    info.history_idx = 0
    info.buffer = ''
    info.editor = editor
    info.echo = echo
    info.session_log = session_log
    info.filename = ''
    
    widget_control, tlb, set_uvalue=info, /no_copy
    widget_control, tlb, /realize
    
    xmanager, 'midlegui', tlb, /no_block, event_handler='midlegui_tlb_handler', cleanup='midlegui_cleanup'
    
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

