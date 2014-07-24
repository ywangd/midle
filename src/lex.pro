; docformat = 'rst'

;+
; Build token stream of given strings. This function is for debug only.
; 
; :Author:
; 	Yang Wang (ywangd@gmail.com)
;-

function lex, lines
    lexer = MidleLexer()
    stream = lexer.lex(lines)
    
    return, stream
end