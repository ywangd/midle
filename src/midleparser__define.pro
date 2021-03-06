; docformat = 'rst'

;+
; The parser of MIDLE.
; 
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function MidleParser::parse_argument
    ; argument : ternary_expr ['=' ternary_expr] | '/' IDENT
    ; Note the keyword argument really should be ident '=' ternary_expr
    ; It is set this way to avoid ambiguity. The expr before '=' will
    ; be checked programmatically to make sure it is ident for keyword
    ; argument.
    if self.tag eq self.TOKEN.T_DIV then begin
        self.matchToken, self.tag
        if self.tag eq self.TOKEN.T_IDENT then begin
            node = KeyargNode(self.lexer, $
                IdentNode(self.lexer, self.lexeme), NumberNode(self.lexer, '1', 2))
            self.matchToken, self.TOKEN.T_IDENT
        endif else begin
            message, 'Identifier expected for keyword argument', /noname
        endelse
    endif else begin
        node = self.parse_ternary_expr()
        if self.tag eq self.TOKEN.T_ASSIGN then begin
            if ~isa(node, 'IdentNode') then message, 'Identifier expected for keyword argument', /noname
            self.matchToken, self.tag
            node = KeyargNode(self.lexer, node, self.parse_ternary_expr())
        endif
    endelse

    return, node

end

function MidleParser::parse_arglist
    ; arglist : argument (',' argument)*
    node = ArglistNode(self.lexer)
    node.add, self.parse_argument()
    while self.tag eq self.TOKEN.T_COMMA do begin
        self.matchToken, self.tag
        node.add, self.parse_argument()
    endwhile
    return, node
end

function MidleParser::parse_deflist, operator
    ; deflist : ternary_expr : ternary_expr (',' ternary_expr : ternary_expr) [',']
    ; The key of Hash literal must be String or Number, this is checked during eval
    node = ListNode(self.lexer, operator)
    node.add, self.parse_ternary_expr()
    self.matchToken, self.TOKEN.T_COLON
    node.add, self.parse_ternary_expr()
    while self.tag eq self.TOKEN.T_COMMA do begin
        self.matchToken, self.tag
        ; An optional comma at the end
        if self.tag ne self.TOKEN.T_RCURLY then begin
            node.add, self.parse_ternary_expr()
            self.matchToken, self.TOKEN.T_COLON
            node.add, self.parse_ternary_expr()
        endif else break
    endwhile
    return, node
end

function MidleParser::parse_sliceop, node
    ; sliceop : ':' (ternary_expr | '*') [':' (ternary_expr | '*')]
    self.matchToken, self.TOKEN.T_COLON
    if self.tag eq self.TOKEN.T_MUL then begin
        node.add, WildcardNode(self.lexer, self.lexeme)
        self.matchToken, self.TOKEN.T_MUL
    endif else begin
        node.add, self.parse_ternary_expr()
    endelse
    if self.tag eq self.TOKEN.T_COLON then begin
        self.matchToken, self.token.t_colon
        if self.tag eq self.TOKEN.T_MUL then begin
            node.add, WildcardNode(self.lexer, self.lexeme)
            self.matchToken, self.TOKEN.T_MUL
        endif else begin
            node.add, self.parse_ternary_expr()
        endelse
    endif
    return, node
end

function MidleParser::parse_idx
    ; idx : (ternary_expr | '*') [sliceop]
    ; The indices must be integers. Ths is ensured during eval.
    node = IndexNode(self.lexer)
    if self.tag eq self.TOKEN.T_MUL then begin
        node.add, WildcardNode(self.lexer, self.lexeme)
        self.matchToken, self.tag
    endif else begin
        node.add, self.parse_ternary_expr()
    endelse
    if self.tag eq self.TOKEN.T_COLON then begin
        node = self.parse_sliceop(node)
    endif
    return, node
end

function MidleParser::parse_idxlist
    ; idxlist : idx (, idx)*
    node = IdxlistNode(self.lexer)
    node.add, self.parse_idx()
    while self.tag eq self.TOKEN.T_COMMA do begin
        self.matchToken, self.tag
        node.add, self.parse_idx()
    endwhile
    return, node
end

function MidleParser::parse_array_literal
    ; array_literal : '[' array_literal ']' | ternary_expr (',' '[' array_literal ']' | ternary_expr)*
    node = ArrayLiteralNode(self.lexer)

    if self.tag eq self.TOKEN.T_LBRACKET then begin
        self.matchToken, self.tag
        node.add, self.parse_array_literal()
        self.matchToken, self.TOKEN.T_RBRACKET
    endif else begin
        node.add, self.parse_ternary_expr()
    endelse

    while self.tag eq self.TOKEN.T_COMMA do begin
        self.matchToken, self.tag
        if self.tag ne self.TOKEN.T_RBRACKET then begin
            if self.tag eq self.token.t_lbracket then begin
                self.matchToken, self.tag
                node.add, self.parse_array_literal()
                self.matchToken, self.token.t_rbracket
            endif else begin
                node.add, self.parse_ternary_expr()
            endelse
        endif
    endwhile
    return, node
end


function MidleParser::parse_trailer
    ; trailer : (arglist) | [idxlist] | '.' (IDENT | '(' ternary_expr ')' )

    if self.tag eq self.TOKEN.T_LPAREN then begin

        self.matchToken, self.tag
        if self.tag ne self.TOKEN.T_RPAREN then begin
            node = self.parse_arglist()
        endif else begin
            node = ArglistNode(self.lexer)
        endelse
        self.matchToken, self.TOKEN.T_RPAREN

    endif else if self.tag eq self.TOKEN.T_LBRACKET then begin
        self.matchToken, self.tag
        if self.tag ne self.TOKEN.T_RBRACKET then begin
            node = self.parse_idxlist()
        endif else begin
            message, 'Invalid subscript', /noname
        endelse
        self.matchToken, self.TOKEN.T_RBRACKET

    endif else begin ; T_DOT
        self.matchToken, self.TOKEN.T_DOT
        if self.tag eq self.TOKEN.T_LPAREN then begin  ; index access of struct
            self.matchToken, self.TOKEN.T_LPAREN
            node = self.parse_ternary_expr()
            self.matchToken, self.TOKEN.T_RPAREN
        endif else if self.tag eq self.TOKEN.T_IDENT then begin
            node = IdentNode(self.lexer, self.lexeme)
            self.matchToken, self.TOKEN.T_IDENT
        endif else begin
            message, 'Identifier expected', /noname
        endelse
    endelse
    return, node
end


function MidleParser::parse_expr_list, ldelimiter, rdelimiter
    ; expr_list : ternary_expr (',' ternary_expr)* [',']

    node = self.parse_ternary_expr()

    while self.tag eq self.TOKEN.T_COMMA do begin
        self.matchToken, self.tag
        if ~isa(node, 'ListNode') then begin
            node = ListNode(self.lexer, ldelimiter, node)
        endif
        ; An optional comma is allowed at the end. This is important as it is required
        ; to defferiate whether the code is a number (1) or a list (1,)
        if self.tag ne rdelimiter then node.add, self.parse_ternary_expr() else break
    endwhile

    return, node
end


function MidleParser::parse_atom
    ; atom : (...) | [...] | {...} | h{...} | IDENT | NUMBER | STRING | !NULL | SYSVAR
    if self.tag eq self.TOKEN.T_LPAREN then begin
        self.matchToken, self.tag
        if self.tag ne self.TOKEN.T_RPAREN then begin
            node = self.parse_expr_list(self.TOKEN.T_LPAREN, self.TOKEN.T_RPAREN)
        endif else begin
            node = ListNode(self.lexer, self.TOKEN.T_LPAREN)
        endelse
        self.matchToken, self.TOKEN.T_RPAREN

    endif else if self.tag eq self.TOKEN.T_LBRACKET then begin
        self.matchToken, self.tag
        if self.tag ne self.TOKEN.T_RBRACKET then begin
            node = self.parse_array_literal()
        endif else begin
            node = NullNode(self.lexer, '[]')
        endelse
        self.matchToken, self.TOKEN.T_RBRACKET

    endif else if self.tag eq self.TOKEN.T_LCURLY then begin
        self.matchToken, self.tag
        if self.tag ne self.TOKEN.T_RCURLY then begin
            node = self.parse_deflist(self.TOKEN.T_LCURLY)
        endif else begin
            node = NullNode(self.lexer, '{}')
        endelse
        self.matchToken, self.TOKEN.T_RCURLY

    endif else if self.tag eq self.TOKEN.T_HASH_LCURLY then begin  ; hash literal
        self.matchToken, self.tag
        if self.tag ne self.TOKEN.T_RCURLY then begin
            node = self.parse_deflist(self.TOKEN.T_HASH_LCURLY)
        endif else begin
            node = ListNode(self.lexer, self.TOKEN.T_HASH_LCURLY)
        endelse
        self.matchToken, self.TOKEN.T_RCURLY

    endif else if self.tag eq self.TOKEN.T_IDENT then begin
        node = IdentNode(self.lexer, self.lexeme)
        self.getToken

    endif else if (typeCode = self.numberCode(self.tag)) ne !NULL then begin
        node = NumberNode(self.lexer, self.lexeme, typeCode)
        self.getToken

    endif else if self.tag eq self.TOKEN.T_STRING then begin
        node = StringNode(self.lexer, self.lexeme)
        self.getToken

    endif else if self.tag eq self.TOKEN.T_NULL then begin
        node = NullNode(self.lexer, self.lexeme)
        self.getToken

    endif else if self.tag eq self.TOKEN.T_SYSV then begin
        node = SysvarNode(self.lexer, self.lexeme)
        self.getToken

    endif else begin
        message, 'Unrecognized token: ' + self.lexeme, /noname
    endelse

    return, node
end

function MidleParser::parse_power
    ; power : atom trailer* ['^' factor]
    node = self.parse_atom()

    while self.isTrailerOperator(self.tag) do begin
        tag = self.tag
        ; Note the tag is not matched here because the trailer products include
        ; brackets etc.
        ;node = self.parse_trailer()
        if self.tag eq self.TOKEN.T_LPAREN then begin
            node = FuncCallNode(self.lexer, node, self.parse_trailer())
        endif else if self.tag eq self.TOKEN.T_LBRACKET then begin
            node = SubscriptNode(self.lexer, node, self.parse_trailer())
        endif else begin ; T_DOT
            node = MemberNode(self.lexer, node, self.parse_trailer())
        endelse

    endwhile

    if self.tag eq self.TOKEN.T_EXP then begin
        self.matchToken, (tag = self.tag)
        node = BinOpNode(self.lexer, tag, node, self.parse_factor())
    endif

    return, node
end

function MidleParser::parse_factor
    ; factor : ('+' | '-' | 'NOT' | '~') factor | power
    if self.isUnaryOperator(self.tag) then begin
        self.matchToken, (tag = self.tag)
        node = UnaryOpNode(self.lexer, tag, self.parse_factor())
    endif else begin
        node = self.parse_power()
    endelse
    return, node
end

function MidleParser::parse_term_expr
    ; * / MOD # ##
    node = self.parse_factor()
    while self.isTermOperator(self.tag) do begin
        self.matchToken, (tag = self.tag)
        node = BinOpNode(self.lexer, tag, node, self.parse_factor())
    endwhile
    return, node
end

function MidleParser::parse_arith_expr
    ; + - < >
    node = self.parse_term_expr()
    while self.isArithOperator(self.tag) do begin
        self.matchToken, (tag = self.tag)
        node = BinOpNode(self.lexer, tag, node, self.parse_term_expr())
    endwhile
    return, node
end

function MidleParser::parse_relational_expr
    ; relational_expr : arith_expr (relation_op arith_expr)*
    node = self.parse_arith_expr()
    while self.isRelationOperator(self.tag) do begin
        self.matchToken, (tag = self.tag)
        node = BinOpNode(self.lexer, tag, node, self.parse_arith_expr())
    endwhile
    return, node
end

function MidleParser::parse_bitwise_expr
    ; bitwise_expr : relational_expr (bitwise_op relational_expr)*
    ; bitwise_op : 'AND' | 'OR' | 'XOR'
    node = self.parse_relational_expr()
    while self.isBitWiseOperator(self.tag) do begin
        self.matchToken, (tag = self.tag)
        node = BinOpNode(self.lexer, tag, node, self.parse_relational_expr())
    endwhile
    return, node
end

function MidleParser::parse_logical_expr
    ; logical_expr : bitwise_expr (logical_op bitwise_expr)*
    ; logical_op : '&&' | '||'
    node = self.parse_bitwise_expr()
    while self.isLogicalOperator(self.tag) do begin
        self.matchToken, (tag = self.tag)
        node = BinOpNode(self.lexer, tag, node, self.parse_bitwise_expr())
    endwhile
    return, node
end


function MidleParser::parse_ternary_expr
    ; ternary_expr : logical_expr ['?' logical_expr ':' logical_expr]
    node = self.parse_logical_expr()
    if self.tag eq self.TOKEN.T_QMARK then begin
        self.matchToken, self.tag
        node_true = self.parse_logical_expr()
        self.matchToken, self.TOKEN.T_COLON
        node_false = self.parse_logical_expr()
        node = TerneryOpNode(self.lexer, node, node_true, node_false)
    endif
    return, node
end

function MidleParser::parse_body, end_label
    ; body: 'BEGIN' stmt_list 'ENDXXX' | stmt
    if self.tag eq self.TOKEN.T_BEGIN then begin
        self.matchToken, self.TOKEN.T_BEGIN
        self.matchToken, self.TOKEN.T_EOL
        node = self.parse_stmt_list(end_label)
    endif else begin
        node = self.parse_stmt()
    endelse
    
    return, node
end


function MidleParser::parse_stmt
    ; stmt : ternary_expr | proc_call | assign_stmt | if_stmt | for_stmt | foreach_stmt | break_stmt | continue_stmt 
    ; if_stmt: 'IF' ternary_expr 'THEN' body
    
    case (self.tag) of
        self.TOKEN.T_IF: begin
            self.matchToken, self.TOKEN.T_IF
            
            node_predicate = self.parse_ternary_expr()
            self.matchToken, self.TOKEN.T_THEN
            node_then = self.parse_body(self.TOKEN.T_ENDIF)
            
            if self.tag eq self.TOKEN.T_ELSE then begin
                self.matchToken, self.TOKEN.T_ELSE
                node_else = self.parse_body(self.TOKEN.T_ENDELSE)
            endif else node_else = !NULL
            
            node = IfNode(self.lexer, node_predicate, node_then, node_else)

        end
        
        self.TOKEN.T_FOR: begin
            self.matchToken, self.TOKEN.T_FOR
            if self.tag eq self.TOKEN.T_IDENT then begin
                node_loopvar = IdentNode(self.lexer, self.lexeme)
                self.matchToken, self.TOKEN.T_IDENT
            endif else begin
                message, 'Identifier expected for loop variable', /noname
            endelse
            self.matchToken, self.TOKEN.T_ASSIGN
            node_start = self.parse_ternary_expr()
            self.matchToken, self.TOKEN.T_COMMA
            node_end = self.parse_ternary_expr()
            if self.tag eq self.TOKEN.T_COMMA then begin
                self.matchToken, self.TOKEN.T_COMMA
                node_step = self.parse_ternary_expr()
            endif else node_step = NumberNode(self.lexer, '1', 2)
            self.matchToken, self.TOKEN.T_DO
            node_loopbody = self.parse_body(self.TOKEN.T_ENDFOR)
            node = ForNode(self.lexer, node_loopvar, node_start, node_end, node_step, node_loopbody)
        end
        
        self.TOKEN.T_FOREACH: begin
            self.matchToken, self.TOKEN.T_FOREACH
            if self.tag eq self.TOKEN.T_IDENT then begin
                node_loopvar = IdentNode(self.lexer, self.lexeme)
                self.matchToken, self.TOKEN.T_IDENT
            endif else begin
                message, 'Identifier expected for loop variable', /noname
            endelse
            self.matchToken, self.TOKEN.T_COMMA
            node_looplist = self.parse_ternary_expr()
            if self.tag eq self.TOKEN.T_COMMA then begin
                self.matchToken, self.TOKEN.T_COMMA
                if self.tag eq self.TOKEN.T_IDENT then begin
                    node_loopidx = IdentNode(self.lexer, self.lexeme)
                    self.matchToken, self.TOKEN.T_IDENT
                endif else begin
                    message, 'Identifier expected for loop index', /noname
                endelse
            endif else node_loopidx = !NULL
            self.matchToken, self.TOKEN.T_DO
            node_loopbody = self.parse_body(self.TOKEN.T_ENDFOREACH)
            node = ForeachNode(self.lexer, node_loopvar, node_looplist, node_loopidx, node_loopbody)
        end
        
        self.TOKEN.T_BREAK: begin
            self.matchToken, self.TOKEN.T_BREAK
            node = ControlNode(self.lexer, 'MIDLE_PC_BREAK')
            if ~self.is_in_loop() then message, 'Cannot BREAK from the main level'
        end
        
        self.TOKEN.T_CONTINUE: begin
            self.matchToken, self.TOKEN.T_CONTINUE
            node = ControlNode(self.lexer, 'MIDLE_PC_CONTINUE')
            if ~self.is_in_loop() then message, 'Cannot CONTINUE from the main level'
        end
        
        else: begin
            node = self.parse_ternary_expr()

            if self.tag eq self.TOKEN.T_COMMA then begin
                self.matchToken, self.TOKEN.T_COMMA
                node = ProcCallNode(self.lexer, node, self.parse_arglist())

            endif else if self.tag eq self.TOKEN.T_ASSIGN then begin
                self.matchToken, self.TOKEN.T_ASSIGN
                node = AssignNode(self.lexer, node, self.parse_ternary_expr())
            endif

            ; A dangling identifier could be either a proc call or a variable
            if isa(node, 'IdentNode') then node.try_proc = 1
            
        end
    endcase
    
    return, node
    
end


function MidleParser::parse_stmt_list, end_label
    ; stmt_list : (stmt EOL)* (EOF | ENDXXX)
    
    if n_elements(end_label) eq 0 then end_label = self.TOKEN.T_EOF
    
    stmt_list = StmtListNode(self.lexer)
    ; Parse till the end of file is reached
    while (self.tag ne end_label) && (self.tag ne self.TOKEN.T_END)  do begin
        
        if self.tag ne self.TOKEN.T_EOL then begin ; ignore empty lines
            node = self.parse_stmt()
            stmt_list.add, node
        endif
        
        ; An EOL is required to end a statement or an empty line
        self.matchToken, self.TOKEN.T_EOL

    endwhile
    
    ; Consume the proper end label
    self.matchToken, self.tag

    return, stmt_list
end



; At the end of each parse function, self.tag always points to the next
; un-processed token.
function MidleParser::parse, lines

    define_msgblk, prefix='MIDLE_PC_', 'MIDLE_PROGRAM_CONTROL', $
        ['BREAK', 'CONTINUE'], $
        ['BREAK: %s', 'CONTINUE: %s'], $
        /ignore_duplicate
    
    catch, theError
    if theError ne 0 then begin
        catch, /cancel
        self.showError, !error_state.msg
        message, 'MIDLE_PARSER_ERR - ' + !error_state.msg, /noprint, /noname, /noprefix
    endif

    self.lexer.feed, lines
    
    self.getToken ; Read the first token
    
    stmt_list = self.parse_stmt_list()
    
    if self.tag ne self.TOKEN.T_EOF then begin
        self.matchToken, self.TOKEN.T_EOL
        if self.tag ne self.TOKEN.T_EOF then message, 'Unreachable code'
        self.matchToken, self.TOKEN.T_EOF
    endif
    
    return, stmt_list

end


function MidleParser::is_in_loop
    callstacks = scope_traceback(/structure)
    callstacks = reverse(callstacks.routine)
    foreach cs, callstacks do if cs eq 'MIDLEPARSER::PARSE_BODY' then return, 1
    return, 0
end


pro MidleParser::showError, msg
    print
    print, !error_state.msg_prefix, '[SyntaxError] ', msg
    print, !error_state.msg_prefix, 'Line ', strtrim(self.lexer.lineno+1,2) + ', Col ', strtrim(self.lexer.start_pos+1,2)
    print, self.lexer.getLine(self.lexer.lineno)
    leadingSpace = ''
    if self.lexer.start_pos gt 0 then leadingSpace = strjoin(replicate(' ', self.lexer.start_pos))
    print, leadingSpace, '^'
    print
end

function MidleParser::numberCode, tag
    case tag of
        self.TOKEN.T_BYTE: typeCode = 1
        self.TOKEN.T_INT: typeCode = 2
        self.TOKEN.T_INT_AUTO: typeCode = -2
        self.TOKEN.T_UINT: typeCode = 12
        self.TOKEN.T_UINT_AUTO: typeCode = -12
        self.TOKEN.T_LONG: typeCode = 3
        self.TOKEN.T_ULONG: typeCode = 13
        self.TOKEN.T_LONG64: typeCode = 14
        self.TOKEN.T_ULONG64: typeCode = 15
        self.TOKEN.T_FLOAT: typeCode = 4
        self.TOKEN.T_DOUBLE: typeCode = 5
        else: typeCode = !NULL
    endcase
    return, typeCode
end

function MidleParser::isTrailerOperator, operator
    if operator eq self.TOKEN.T_LPAREN || operator eq self.TOKEN.T_LBRACKET || operator eq self.TOKEN.T_DOT then return, 1 else return, 0
end

function MidleParser::isUnaryOperator, operator
    if where([self.TOKEN.T_ADD, self.TOKEN.T_SUB, self.TOKEN.T_BNOT, self.TOKEN.T_LNOT] eq operator, /null) ne !NULL then return, 1 else return, 0
end

function MidleParser::isTermOperator, operator
    if where([self.TOKEN.T_MUL, self.TOKEN.T_DIV, self.TOKEN.T_MOD, self.TOKEN.T_HASH, self.TOKEN.T_DHASH] eq operator, /null) ne !NULL then return, 1 else return, 0
end

function MidleParser::isArithOperator, operator
    if where([self.TOKEN.T_ADD, self.TOKEN.T_SUB, self.TOKEN.T_MIN, self.TOKEN.T_MAX] eq operator, /null) ne !NULL then return, 1 else return, 0
end

function MidleParser::isRelationOperator, operator
    if where([self.TOKEN.T_EQ, self.TOKEN.T_NE, self.TOKEN.T_GE, self.TOKEN.T_GT, self.TOKEN.T_LE, self.TOKEN.T_LT] eq operator, /null) ne !NULL then return, 1 else return, 0

end

function MidleParser::isBitWiseOperator, operator
    if operator eq self.TOKEN.T_BAND || operator eq self.TOKEN.T_BOR || operator eq self.TOKEN.T_BXOR then return, 1 else return, 0
end

function MidleParser::isLogicalOperator, operator
    if operator eq self.TOKEN.T_LAND || operator eq self.TOKEN.T_LOR then return, 1 else return, 0
end

pro MidleParser::matchToken, tag
    if self.tag ne tag then begin
        message, 'Bad token' , /noname
    endif
    self.getToken
end


pro MidleParser::getToken
    self.tag = self.lexer.getToken()
    self.lexeme = self.lexer.getLexeme()
end

pro MidleParser::cleanup
end


function MidleParser::init
    self.TOKEN = getTokenCodes()
    self.lexer = MidleLexer()
    return, 1
end


pro MidleParser__define, class
    class = {MidleParser, inherits IDL_Object, $
        TOKEN: obj_new(), $
        lexer: obj_new(), $
        tag: 0, $
        lexeme: ''}
end

