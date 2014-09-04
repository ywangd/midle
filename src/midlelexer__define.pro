; docformat = 'rst'

;+
; The lexer of MIDLE.
;
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function isWhite, c
    b = byte(c)
    if b eq 32B || b eq 9B then return, 1 else return, 0
end


function isDigit, c
    if c ge '0' && c le '9' then return, 1 else return, 0
end


function isAlpha, c
    if (c ge 'A' && c le 'Z') || (c ge 'a' && c le 'z') then return, 1 else return, 0
end


function isAlnum, c
    if isDigit(c) || isAlpha(c) then return, 1 else return, 0
end

pro MidleLexer::nextNonwhite
    while isWhite(self.char) do self.nextc
end

pro MidleLexer::nextEOL
    while self.char ne string(10B) do self.nextc
end

; The continuation symbol ingores any trailing characters and read until a
; non-empty, non-comment, and non-$ line is found.
; A $ line is a line starts with a $ symbol excluding preceeding whitespaces
pro MidleLexer::nextContinuation
    repeat begin
        self.nextEOL
        self.nextc
        self.nextNonwhite
    endrep until (self.char ne '$' && self.char ne ';' && self.char ne string(10B))
end

pro MidleLexer::nextc
    ; lookahead_pos is always 1 ahead of the char
    ; always return char as uppercase

    if self.lookahead_pos gt self.buflen then begin
        if self.lineno lt self.lines.count() -1 then begin
            self.lineno += 1
            self.buffer = (self.lines)[self.lineno]
            self.buflen = strlen(self.buffer)
            self.lookahead_pos = 0L
        endif else begin
            self.char = ''  ; end of file reached
            return
        endelse
    endif

    self.char = strupcase(strmid(self.buffer, self.lookahead_pos, 1))
    self.lookahead_pos += 1
    if self.char eq '' then self.char = string(10B)

end


pro MidleLexer::matchc, c
    self.nextc
    if self.char ne c then message, 'Bad character: ' + c + ' expected', /noname
end


function MidleLexer::getLexeme
    return, strmid(self.buffer, self.start_pos, self.lookahead_pos - 1 - self.start_pos)
end

function MidleLexer::keywordLookup
    lexeme = strupcase(self.getLexeme())
    if self.keywords.haskey(lexeme) then begin
        return, self.keywords[lexeme]
    endif else begin
        return, -1
    endelse
end

pro MidleLexer::showError, msg
    print
    print, !error_state.msg_prefix, '[SyntaxError] ', msg
    print, !error_state.msg_prefix, 'Line ', strtrim(self.lineno+1,2) + ', Col ', strtrim(self.lookahead_pos,2)
    print, self.getLine(self.lineno)
    leadingSpace = ''
    if self.lookahead_pos-1 gt 0 then leadingSpace = strjoin(replicate(' ', self.lookahead_pos-1))
    print, leadingSpace, '^'
    print

end


function MidleLexer::processScientificNotation, notation

    if self.char eq '+' || self.char eq '-' then begin
        self.nextc
        ; If + or - is seen, a digit is required to follow.
        ; Otherwise digit is optional as 42D or 42E are both valid.
        if ~isDigit(self.char) then message, "Digits expected", /noname
    endif

    while isDigit(self.char) do begin
        self.nextc
    endwhile

    if notation eq 'E' then return, self.TOKEN.T_FLOAT else return, self.TOKEN.T_DOUBLE
end


function MidleLexer::processFraction
    while isDigit(self.char) do begin
        self.nextc
    endwhile

    if strupcase(self.char) eq 'E' || strupcase(self.char) eq 'D' then begin
        notation = strupcase(self.char)
        self.nextc
        return, self.processScientificNotation(notation)
    endif

    return, self.TOKEN.T_FLOAT

end


; When getToken returns, self.char points to the first character in the buffer
; that is not processed. lookahead_pos is one position further to the right.
function MidleLexer::getToken
    catch, theError
    if theError ne 0 then begin
        catch, /cancel
        self.showError, !error_state.msg
        message, 'MIDLE_LEXER_ERR - ' + !error_state.msg, /noprint, /noname, /noprefix
    endif

    self.nextNonwhite
    ; We can check the line continuation and comments before checking for any
    ; other tokens because no tokens begins with a $ or ; or &
    if self.char eq '$' then begin
        self.nextContinuation
    endif else if self.char eq '&' then begin
        self.char = string(10B)  ; & is effectively an EOL
    endif else if self.char eq ';' then begin
        self.nextEOL
    endif
    
    self.start_pos = self.lookahead_pos - 1
    
    case 1 of
    
        self.char eq '': return, self.TOKEN.T_EOF
        self.char eq string(10B): begin
            self.nextc
            return, self.TOKEN.T_EOL
        end
    
        self.char eq '+': begin
            self.nextc
            return, self.TOKEN.T_ADD
        end
    
        self.char eq '-': begin
            self.nextc
            if self.char eq '>' then begin
                self.nextc
                return, self.TOKEN.T_ARROW
            endif else begin
                return, self.TOKEN.T_SUB
            endelse
        end
    
        self.char eq '*': begin
            self.nextc
            return, self.TOKEN.T_MUL
        end
    
        self.char eq '/': begin
            self.nextc
            return, self.TOKEN.T_DIV
        end
    
        self.char eq '^': begin
            self.nextc
            return, self.TOKEN.T_EXP
        end
    
        self.char eq '>': begin
            self.nextc
            return, self.TOKEN.T_MAX
        end
    
        self.char eq '<': begin
            self.nextc
            return, self.TOKEN.T_MIN
        end
    
        self.char eq '?': begin
            self.nextc
            return, self.TOKEN.T_QMARK
        end
    
        self.char eq ',': begin
            self.nextc
            return, self.TOKEN.T_COMMA
        end
    
        self.char eq ':': begin
            self.nextc
            return, self.TOKEN.T_COLON
        end
    
        self.char eq '~': begin
            self.nextc
            return, self.TOKEN.T_LNOT
        end
    
        self.char eq '=': begin
            self.nextc
            return, self.TOKEN.T_ASSIGN
        end
    
        self.char eq '(': begin
            self.nextc
            return, self.TOKEN.T_LPAREN
        end
    
        self.char eq ')': begin
            self.nextc
            return, self.TOKEN.T_RPAREN
        end
    
        self.char eq '[': begin
            self.nextc
            return, self.TOKEN.T_LBRACKET
        end
    
        self.char eq ']': begin
            self.nextc
            return, self.TOKEN.T_RBRACKET
        end
    
        self.char eq '{': begin
            self.nextc
            return, self.TOKEN.T_LCURLY
        end
    
        self.char eq '}': begin
            self.nextc
            return, self.TOKEN.T_RCURLY
        end
    
        self.char eq '|': begin
            self.matchc, '|'
            self.nextc
            return, self.TOKEN.T_LOR
        end
    
        self.char eq '&': begin
            self.matchc, '&'
            self.nextc
            return, self.TOKEN.T_LAND
        end
    
        ; If a dot is followed by a number, it is a decimal.
        ; Otherwise it is a dot operator
        self.char eq '.': begin
            self.nextc
            if isDigit(self.char) then begin
                return, self.processFraction()
            endif else begin
                return, self.TOKEN.T_DOT
            endelse
        end
    
        isDigit(self.char): begin
            self.nextc
            while 1 do begin
                case 1 of
    
                    self.char eq 'B': begin
                        self.nextc
                        return, self.TOKEN.T_BYTE
                    end
    
                    self.char eq 'S': begin
                        self.nextc
                        return, self.TOKEN.T_INT
                    end
    
                    self.char eq 'U': begin
                        self.nextc
                        if self.char eq 'L' then begin
                            self.nextc
                            if self.char eq 'L' then begin
                                self.nextc
                                return, self.TOKEN.T_ULONG64
                            endif else begin
                                return, self.TOKEN.T_ULONG
                            endelse
                        endif else if self.char eq 'S' then begin
                            self.nextc
                            return, self.TOKEN.T_UINT
                        endif else begin
                            return, self.TOKEN.T_UINT_AUTO
                        endelse
                    end
    
                    self.char eq 'L': begin
                        self.nextc
                        if self.char eq 'L' then begin
                            self.nextc
                            return, self.TOKEN.T_LONG64
                        endif else begin
                            return, self.TOKEN.T_LONG
                        endelse
                    end
    
                    self.char eq '.': begin
                        self.nextc
                        return, self.processFraction()
                    end
    
                    self.char eq 'E': begin
                        self.nextc
                        return, self.processScientificNotation('E')
                    end
    
                    self.char eq 'D': begin
                        self.nextc
                        return, self.processScientificNotation('D')
                    end
    
                    isDigit(self.char): self.nextc  ; multi-digits number
    
                    else: begin
                        return, self.TOKEN.T_INT_AUTO
                    end
    
                endcase ; end case char
            endwhile  ; end while not whitespaces
        end  ; end of isDigit
    
        self.char eq '"' || self.char eq '''': begin
            quote = self.char
            self.nextc
            while 1 do begin
                if self.char eq quote then begin
                    self.nextc
                    if self.char eq quote then begin ; escaped quote
                        self.nextc
                    endif else begin
                        return, self.TOKEN.T_STRING
                    endelse
                endif else begin
                    self.nextc
                endelse
            endwhile
        end
    
        ; identifier, keywords and pecial synatical sugars
        isAlpha(self.char) || self.char eq '_': begin
            while 1 do begin
                self.nextc
                if ~(isAlnum(self.char) || self.char eq '_') then begin
                    ; Special Hash literal
                    if strupcase(self.getLexeme()) eq 'H' && self.char eq '{' then begin
                        self.nextc
                        return, self.TOKEN.T_HASH_LCURLY
                    endif else begin
                        token = self.keywordLookup()
                        if token ne -1 then begin
                            return, token  ; keyword
                        endif else begin
                            return, self.TOKEN.T_IDENT
                        endelse
                    endelse
                endif
            endwhile
        end
    
        ; system variable
        self.char eq '!': begin
            self.nextc
            if isAlpha(self.char) then begin
                while 1 do begin
                    self.nextc
                    if ~(isAlnum(self.char) || self.char eq '_') then begin
                        if self.getLexeme() eq '!NULL' then return, self.TOKEN.T_NULL else return, self.TOKEN.T_SYSV
                    endif
                endwhile
            endif else begin
                message, 'Bad character: A letter expected.', /noname
            endelse
    
        end
    
        else: message, "Bad character", /noname
    
    endcase
    
end

function MidleLexer::lex, lines
    self.feed, lines
    ret = list()
    repeat begin
        token = self.getToken()
        t = strupcase((self.TOKEN.where(token))[0])
        s = self.getLexeme()
        ret.add, [t, s]
    endrep until token eq self.TOKEN.T_EOF

    return, ret
end


pro MidleLexer::feed, lines
    self.lines.remove, /all

    self.lines.add, lines, /extract
    self.buffer = (self.lines)[0]
    self.buflen = strlen(self.buffer)
    self.lineno = 0
    self.lookahead_pos = 0L
    self.nextc
end


function MidleLexer::getLine, idx
    return, self.lines[idx]
end


pro MidleLexer::getProperty, lineno=lineno, lookahead_pos=lookahead_pos, char=char, $
    start_pos=start_pos, TOKEN=TOKEN, buffer=buffer
    lineno = self.lineno
    lookahead_pos = self.lookahead_pos
    char = self.char
    start_pos = self.start_pos
    if arg_present(TOKEN) then TOKEN = self.TOKEN
    if arg_present(buffer) then buffer = self.buffer
end


pro MidleLexer::cleanup
end


function MidleLexer::init, lines
    self.lines = list()

    if n_elements(lines) ne 0 then begin
        self.lines.add, lines, /extract
        self.buffer = (self.lines)[0]
        self.buflen = strlen(self.buffer)
        self.lineno = 0
        self.lookahead_pos = 0L
        self.nextc
    endif

    self.TOKEN = getTokenCodes()

    self.keywords = hash()
    self.keywords['MOD'] = self.TOKEN.T_MOD
    self.keywords['NOT'] = self.TOKEN.T_BNOT
    self.keywords['AND'] = self.TOKEN.T_BAND
    self.keywords['OR'] = self.TOKEN.T_BOR
    self.keywords['EQ'] = self.TOKEN.T_EQ
    self.keywords['NE'] = self.TOKEN.T_NE
    self.keywords['GE'] = self.TOKEN.T_GE
    self.keywords['GT'] = self.TOKEN.T_GT
    self.keywords['LE'] = self.TOKEN.T_LE
    self.keywords['LT'] = self.TOKEN.T_LT
    
    self.keywords['IF'] = self.TOKEN.T_IF
    self.keywords['ELSE'] = self.TOKEN.T_ELSE
    self.keywords['THEN'] = self.TOKEN.T_THEN
    self.keywords['BEGIN'] = self.TOKEN.T_BEGIN
    self.keywords['FOR'] = self.TOKEN.T_FOR
    self.keywords['FOREACH'] = self.TOKEN.T_FOREACH
    self.keywords['DO'] = self.TOKEN.T_DO
    self.keywords['BREAK'] = self.TOKEN.T_BREAK
    self.keywords['CONTINUE'] = self.TOKEN.T_CONTINUE
    self.keywords['END'] = self.TOKEN.T_END
    self.keywords['ENDIF'] = self.TOKEN.T_ENDIF
    self.keywords['ENDELSE'] = self.TOKEN.T_ENDELSE
    self.keywords['ENDFOR'] = self.TOKEN.T_ENDFOR
    self.keywords['ENDFOREACH'] = self.TOKEN.T_ENDFOREACH

    return, 1
end


pro MidleLexer__define, class

    class = {MidleLexer, inherits IDL_Object, $
        lines: list(), $
        buffer: '', $
        buflen: 0L, $
        lineno: 0L, $
        lookahead_pos: 0L, $
        char: '', $
        start_pos: 0L, $
        TOKEN: obj_new(), $
        keywords: obj_new() $

    }

end

