; docformat = 'rst'

;+
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function SysvarNode::eval, env
    case strupcase(self.lexeme) of
        '!C': return, !C
        '!COLOR': return, !COLOR
        '!CONST': return, !CONST
        '!CPU': return, !CPU
        '!D': return, !D
        '!DEBUG_PROCESS_EVENTS': return, !DEBUG_PROCESS_EVENTS
        '!DIR': return, !DIR
        '!DLM_PATH': return, !DLM_PATH
        '!DPI': return, !DPI
        '!DTOR': return, !DTOR
        '!EDIT_INPUT': return, !EDIT_INPUT
        '!ERROR_STATE': return, !ERROR_STATE
        '!EXCEPT': return, !EXCEPT
        '!HELP_PATH': return, !HELP_PATH
        '!IDLDT_TEMPSTRING': return, !IDLDT_TEMPSTRING
        '!JOURNAL': return, !JOURNAL
        '!MAKE_DLL': return, !MAKE_DLL
        '!MAP': return, !MAP
        '!MORE': return, !MORE
        '!MOUSE': return, !MOUSE
        ; !NULL is supported separated by the dedicate NullNode 
        '!ORDER': return, !ORDER
        '!P': return, !P
        '!PATH': return, !PATH
        '!PI': return, !PI
        '!PROMPT': return, !PROMPT
        '!QUIET': return, !QUIET
        '!RADEG': return, !RADEG
        '!VALUES': return, !VALUES
        '!VERSION': return, !VERSION
        '!WARN': return, !WARN
        '!X': return, !X
        '!Y': return, !Y
        '!Z': return, !Z
        else: self.error, 'Unrecognized system variable: ' + self.lexeme
    endcase
end

function SysvarNode::print_helper
    return, string(self.name(), self.lexeme, format='(A, " ''",A,"''")')
end


function SysvarNode::init, start_pos, lexeme
    if ~self->AstNode::init(start_pos) then return, 0
    self.lexeme = lexeme
    return, 1
end

pro SysvarNode__define, class
    class = {SysvarNode, inherits AstNode, $
        lexeme: '' }
end
