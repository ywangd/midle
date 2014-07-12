

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


pro ExprParser::nextc
    ; lookahead_pos is always 1 ahead of the char
    ; always return char as uppercase
    self.char = strupcase(strmid(self.buffer, self.lookahead_pos, 1))
    self.lookahead_pos += 1
end


pro ExprParser::matchc, c
    self.nextc
    if self.char ne c then self.error, 'syntax error - ' + c + ' expected'
end


function ExprParser::getLexeme
    return, strmid(self.buffer, self.start_pos, self.lookahead_pos - 1 - self.start_pos)
end

function ExprParser::keywordLookup
    lexeme = strupcase(self.getLexeme())
    if self.keywords.haskey(lexeme) then begin
        return, self.keywords[lexeme]
    endif else begin
        return, -1
    endelse
end

pro ExprParser::error, msg
    on_error, 1
    message, string(self.lookahead_pos-1, self.char, msg, $
        format='("ERROR: column ", I0, " [", A1, "] ", A)')
end


function ExprParser::processScientificNotation, notation

    if self.char eq '+' || self.char eq '-' then begin
        self.nextc
        if ~isDigit(self.char) then self.error, "Digits expected"
    endif

    while isDigit(self.char) do begin
        self.nextc
    endwhile

    if notation eq 'E' then return, self.TOKEN.T_FLOAT else return, self.TOKEN.T_DOUBLE
end


function ExprParser::processFraction
    while isDigit(self.char) do begin
        self.nextc
    endwhile

    if strupcase(self.char) eq 'E' || strupcase(self.char) eq 'D' then begin
        self.nextc
        return, self.processScientificNotation(strupcase(self.char))
    endif

    return, self.TOKEN.T_FLOAT

end


; When getToken returns, self.char points to the first character in the buffer
; that is not processed. lookahead_pos is one position further to the right.
function ExprParser::getToken

    while isWhite(self.char) do self.nextc

    self.start_pos = self.lookahead_pos - 1

    case 1 of

        self.char eq '': return, self.TOKEN.T_EOL

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
                            return, self.TOKEN.T_UINT
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
                        return, self.TOKEN.T_INT
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

        ; identifier
        isAlpha(self.char) || self.char eq '_': begin
            while 1 do begin
                self.nextc
                if ~(isAlnum(self.char) || self.char eq '_') then begin
                    token = self.keywordLookup()
                    if token ne -1 then begin
                        return, token
                    endif else begin
                        return, self.TOKEN.T_IDENT
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
                        return, self.TOKEN.T_SYSV
                    endif
                endwhile
            endif else begin
                self.error, 'letter expected'
            endelse

        end

        else: self.error, "Bad character"


    endcase
end


function ExprParser::parse, line
    self.buffer = line
    self.lookahead_pos = 0L
    self.nextc

    repeat begin
        token = self.getToken()
        print, strupcase((self.TOKEN.where(token))[0]), self.getLexeme(), $
            format='(A-12, A)'
    endrep until token eq self.TOKEN.T_EOL

    return, 0
end


pro ExprParser::cleanup
end


function ExprParser::init

    self.TOKEN = Dict()
    self.TOKEN.T_EOL = 0
    self.TOKEN.T_NULL = 256
    self.TOKEN.T_BYTE = 257
    self.TOKEN.T_INT =  258
    self.TOKEN.T_UINT = 259
    self.TOKEN.T_LONG = 260
    self.TOKEN.T_ULONG = 261
    self.TOKEN.T_LONG64 = 262
    self.TOKEN.T_ULONG64 = 263
    self.TOKEN.T_FLOAT = 264
    self.TOKEN.T_DOUBLE = 265
    self.TOKEN.T_STRING = 266
    self.TOKEN.T_ADD = 271
    self.TOKEN.T_SUB = 272
    self.TOKEN.T_MUL = 273
    self.TOKEN.T_DIV = 274
    self.TOKEN.T_MOD = 275
    self.TOKEN.T_EXP = 276
    self.TOKEN.T_BNOT = 291
    self.TOKEN.T_BAND = 292
    self.TOKEN.T_BOR = 293
    self.TOKEN.T_BXOR = 294
    self.TOKEN.T_LNOT = 301
    self.TOKEN.T_LAND = 302
    self.TOKEN.T_LOR = 303
    self.TOKEN.T_EQ = 311
    self.TOKEN.T_NE = 312
    self.TOKEN.T_GE = 313
    self.TOKEN.T_GT = 314
    self.TOKEN.T_LE = 315
    self.TOKEN.T_LT = 316
    self.TOKEN.T_MAX = 321
    self.TOKEN.T_MIN = 322
    self.TOKEN.T_DOT = 331
    self.TOKEN.T_ARROW = 332
    self.TOKEN.T_COLON = 333
    self.TOKEN.T_COMMA = 334
    self.TOKEN.T_LPAREN = 341
    self.TOKEN.T_RPAREN = 342
    self.TOKEN.T_LBRACKET = 343
    self.TOKEN.T_RBRACKET = 344
    self.TOKEN.T_IDENT = 401
    self.TOKEN.T_SYSV = 411

    self.keywords = Hash()
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

    return, 1
end


pro ExprParser__define, class

    class = {ExprParser, inherits IDL_Object, $
        buffer: '', $
        lookahead_pos: 0L, $
        char: '', $
        start_pos: 0L, $
        TOKEN: obj_new(), $
        keywords: obj_new() $

    }

end

