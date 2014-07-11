

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


pro ExpParser::nextc
    ; lookahead_pos is always 1 ahead of the char
    ; always return char as uppercase
    self.char = strupcase(strmid(self.buffer, self.lookahead_pos, 1))
    self.lookahead_pos += 1
end

function ExpParser::getLexeme
    return, strmid(self.buffer, self.start_pos, self.lookahead_pos - 1 - self.start_pos)
end

pro ExpParser::error, msg
    message, string(self.lookahead_pos-1, self.char, msg, $
        format='("ERROR: column ", I0, " [", A1, "] ", A)')
end


function ExpParser::processScientificNotation, notation

    if self.char eq '+' || self.char eq '-' then begin
        self.nextc
        if ~isDigit(self.char) then self.error, "Digits expected"
    endif

    while isDigit(self.char) do begin
        self.nextc
    endwhile

    if notation eq 'E' then return, self.T_FLOAT else return, self.T_DOUBLE
end


function ExpParser::processFraction
    while isDigit(self.char) do begin
        self.nextc
    endwhile

    if strupcase(self.char) eq 'E' || strupcase(self.char) eq 'D' then begin
        self.nextc
        return, self.processScientificNotation(strupcase(self.char))
    endif

    return, self.T_FLOAT

end


function ExpParser::getToken

    while isWhite(self.char) do self.nextc

    self.start_pos = self.lookahead_pos - 1

    print, 'start_pos is', self.start_pos

    case 1 of

        self.char eq '': return, self.T_EOL

        self.char eq '+': begin
            self.nextc
            return, self.T_ADD
        end

        self.char eq '-': begin
            self.nextc
            return, self.T_SUB
        end

        self.char eq '*': begin
            self.nextc
            return, self.T_MUL
        end

        self.char eq '/': begin
            self.nextc
            return, self.T_DIV
        end

        self.char eq '^': begin
            self.nextc
            return, self.T_EXP
        end

        self.char eq '~': begin
            self.nextc
            return, self.T_LNOT
        end

        self.char eq '.': begin
            ; The dot is at the begining of a token. So it must be a decimal point.
            self.nextc
            return, self.processFraction()
        end

        isDigit(self.char): begin
            self.nextc
            while ~isWhite(self.char) do begin
                case 1 of

                    self.char eq 'B': begin
                        self.nextc
                        return, self.T_BYTE
                    end

                    self.char eq 'S': begin
                        self.nextc
                        return, self.T_INT
                    end

                    self.char eq 'U': begin
                        self.nextc
                        if self.char eq 'L' then begin
                            self.nextc
                            if self.char eq 'L' then begin
                                self.nextc
                                return, self.T_ULONG64
                            endif else begin
                                return, self.T_ULONG
                            endelse
                        endif else if self.char eq 'S' then begin
                            self.nextc
                            return, self.T_UINT
                        endif else begin
                            return, self.T_UINT
                        endelse
                    end

                    self.char eq 'L': begin
                        self.nextc
                        if self.char eq 'L' then begin
                            self.nextc
                            return, self.T_LONG64
                        endif else begin
                            return, self.T_LONG
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

                        print, 'here ', self.char, self.lookahead_pos, self.T_INT
                        return, self.T_INT
                    end

                endcase ; end case char
            endwhile  ; end while not whitespaces
        end  ; end of isDigit

        else: self.error, "Bad character"


    endcase
end


function ExpParser::parse, line
    self.buffer = line
    self.lookahead_pos = 0L
    self.nextc

    repeat begin
        token = self.getToken()
        print, self.getLexeme(), token, ' end pos is ', self.lookahead_pos
    endrep until token eq self.T_EOL

    return, 0
end


pro ExpParser::cleanup
end


function ExpParser::init
    self.symbol_table = hash()
    self.TOKEN.T_NULL = 0
    self.TOKEN.T_BYTE = 256
    self.TOKEN.T_INT =  257
    self.TOKEN.T_UINT = 258
    self.TOKEN.T_LONG = 259
    self.TOKEN.T_ULONG = 260
    self.TOKEN.T_LONG64 = 261
    self.TOKEN.T_ULONG64 = 262
    self.TOKEN.T_FLOAT = 263
    self.TOKEN.T_DOUBLE = 264
    self.TOKEN.T_STRING = 265
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

    return, 1
end


pro ExpParser__define, class

    class = {ExpParser, inherits IDL_Object, $
        symbol_table: hash(), $
        buffer: '', $
        lookahead_pos: 0L, $
        char: '', $
        start_pos: 0L, $
        TOKEN: obj_new() $

    }

end
