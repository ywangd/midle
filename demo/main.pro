; docformat = 'rst'

;+
; A demo that shows how MIDLE can be used as a script engine for a GUI application.
; The demo is based on the example provided by the offical IDL document available at
; http://www.exelisvis.com/docs/translate_method.html
; 
; :Author:
; 	Yang Wang (ywangd@gmail.com)
;-

pro set_sun_color, o, color
    o.fill_color = color
    o.color = color
end

pro set_background_color, o, color
    o.background_color = color
end

pro midledemo_handler, event
end

pro midledemo_cleanup, event
end

pro midle_popup, event
    gl = event.top
    widget_control, gl, get_uvalue=env, /no_copy
    midlegui, env=env, group_leader=gl
    help, env
    widget_control, gl, set_uvalue=env, /no_copy
end

pro main
    ; Create the widgets.

    wBase = widget_base(/column)
    wDraw = widget_window(wBase,  x_scroll_size=600, y_scroll_size=450)
    pop = widget_button(wBase, value='Click to Access MIDLE Console', event_pro='midle_popup')
    widget_control, wBase, /realize
    xmanager, 'midledemo', wBase, /no_block, event_handler='midledemo_handler', cleanup='midledemo_cleanup'
    ; Retrieve the newly-created Window object.
    widget_control, wDraw, get_value=oWin
    ; Make sure this is the current window
    oWin.select

    ; Create the data.
    x = findgen(100)
    y = 20 * sin(x*2*!PI/25.0) * exp(-0.01*x)

    ; Draw the sky and sea.
    p = plot(x, y, xrange=[0,99], yrange=[-40,100], $
        /current, $
        window_title='Demo of MIDLE Script Engine', $
        fill_level=-40, $
        axis_style=0, margin=0, $
        ; dimensions=[500,400], $
        background_color="light sky blue", $
        /fill_background, fill_color="sea green", transparency=100)
        
    ; Draw the sun
    sun = ellipse(0.9, 1, fill_color="yellow", color="yellow")

    ; The points to draw the boat
    xx = 0.5*[-22,-19,-12,-7,8,13,18,23,0.5,0.5, $
        13,8,0.5,0.5,8,3,-2,-7,0,0,-7,-12,0,0]
    yy = 2*[3,-0.7,-1,-1.5,-1.5,-0.7,0.5,3,3,5, $
        5,13,13,15,15,20,20,15,15,13,13,5,5,3]
    ; Draw the boat. Give a Z value to put the boat on top.
    boat = polygon(xx,yy,1,/data,fill_color="burlywood", clip=0)

    env = Dictionary('p', p, 'boat', boat, 'sun', sun)
    
    widget_control, wBase, set_uvalue=env, /no_copy
    
end


