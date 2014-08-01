
pro midle_console_input, event
    widget_control, event.id, get_value=code
    widget_control, event.top, get_uvalue=env, /no_copy
    
    ret = midle(code, env)
    
    widget_control, event.id, set_value=''
    echo = widget_info(event.top, find_by_uname='echo')
    widget_control, echo, get_value=echovalue
    echovalue = [echovalue, code, isa(ret, /null) ? '!NULL' : string(ret, /print)]
    widget_control, echo, set_value=echovalue
    widget_control, event.top, set_uvalue=env, /no_copy
end


pro midle_console_exit, event
    widget_control, event.top, /destroy
end


pro midle_console_tlb_handler, event
end

pro midle_console_cleanup, tlb
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
    echo = widget_text(tlb, uname='echo', xsize=xsize_workable_area, ysize=40)
    input = widget_text(tlb, xsize=xsize_workable_area, ysize=1, /editable, event_pro='midle_console_input')
    
    env = dictionary()
    widget_control, tlb, set_uvalue=env, /no_copy
    widget_control, tlb, /realize
    
    xmanager, 'midle_console', tlb, /no_block, event_handler='midle_console_tlb_handler', cleanup='midle_console_cleanup'
    

end

main

end

