
function ExprParser::parse_argument
    ; argument : ternary_expr ['=' ternary_expr] | '/' IDENT
    ; Note the keyword argument really should be ident '=' ternary_expr
    ; It is set this way to avoid ambiguity. The expr before '=' will
    ; be checked programmatically to make sure it is ident for keyword
    ; argument.
    if self.tag eq self.TOKEN.T_DIV then begin
        self.matchToken, self.tag
        if self.tag eq self.TOKEN.T_IDENT then begin
            node = KeyargNode(self.lexer.start_pos, $
                IdentNode(self.lexer.start_pos, self.lexeme), NumberNode(self.lexer.start_pos, '1', 2))
            self.matchToken, self.TOKEN.T_IDENT
        endif else begin
            self.error, 'identifier expected for keyword argument'
        endelse
    endif else begin
        node = self.parse_ternary_expr()
        if self.tag eq self.token.t_assign then begin
            if ~isa(node, 'IdentNode') then self.error, 'identifier expected for keyword argument'
            self.matchToken, self.tag
            node = KeyargNode(self.lexer.start_pos, node, self.parse_ternary_expr())
        endif
    endelse
    
    return, node
    
end

function ExprParser::parse_arglist
    ; arglist : argument (',' argument)*
    node = ArglistNode(self.lexer.start_pos)
    node.add, self.parse_argument()
    while self.tag eq self.TOKEN.T_COMMA do begin
        self.matchToken, self.tag
        node.add, self.parse_argument()
    endwhile
    return, node
end

function ExprParser::parse_deflist, operator
    ; deflist : ternary_expr : ternary_expr (',' ternary_expr : ternary_expr) [',']
    ; The key of Hash literal must be String or Number, this is checked during eval
    node = ListNode(self.lexer.start_pos, operator)
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

function ExprParser::parse_sliceop, node
    ; sliceop : ':' (ternary_expr | '*') [':' (ternary_expr | '*')]
    self.matchToken, self.TOKEN.T_COLON
    if self.tag eq self.TOKEN.T_MUL then begin
        node.add, WildcardNode(self.lexer.start_pos, self.lexeme)
        self.matchToken, self.TOKEN.T_MUL
    endif else begin
        node.add, self.parse_ternary_expr()
    endelse
    if self.tag eq self.TOKEN.T_COLON then begin
        self.matchToken, self.token.t_colon
        if self.tag eq self.TOKEN.T_MUL then begin
            node.add, WildcardNode(self.lexer.start_pos, self.lexeme)
            self.matchToken, self.TOKEN.T_MUL
        endif else begin
            node.add, self.parse_ternary_expr()
        endelse
    endif
    return, node
end

function ExprParser::parse_idx
    ; idx : (ternary_expr | '*') [sliceop]
    ; The indices must be integers. Ths is ensured during eval.
    node = IndexNode(self.lexer.start_pos)
    if self.tag eq self.TOKEN.T_MUL then begin
        node.add, WildcardNode(self.lexer.start_pos, self.lexeme)
        self.matchToken, self.tag
    endif else begin
        node.add, self.parse_ternary_expr()
    endelse
    if self.tag eq self.TOKEN.T_COLON then begin
        node = self.parse_sliceop(node)
    endif
    return, node
end

function ExprParser::parse_idxlist
    ; idxlist : idx (, idx)*
    node = IdxlistNode(self.lexer.start_pos)
    node.add, self.parse_idx()
    while self.tag eq self.TOKEN.T_COMMA do begin
        self.matchToken, self.tag
        node.add, self.parse_idx()
    endwhile
    return, node
end

function ExprParser::parse_array_literal
    ; array_literal : '[' array_literal ']' | ternary_expr (',' '[' array_literal ']' | ternary_expr)*
    node = ArrayLiteralNode(self.lexer.start_pos)
    
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


function ExprParser::parse_trailer
    ; trailer : (arglist) | [idxlist] | '.' IDENT

    if self.tag eq self.TOKEN.T_LPAREN then begin

        self.matchToken, self.tag
        if self.tag ne self.TOKEN.T_RPAREN then begin
            node = self.parse_arglist()
        endif else begin
            node = ArglistNode(self.lexer.start_pos)
        endelse
        self.matchToken, self.TOKEN.T_RPAREN

    endif else if self.tag eq self.TOKEN.T_LBRACKET then begin
        self.matchToken, self.tag
        if self.tag ne self.TOKEN.T_RBRACKET then begin
            node = self.parse_idxlist()
        endif else begin
            self.error, 'Invalid subscript'
        endelse
        self.matchToken, self.TOKEN.T_RBRACKET

    endif else begin ; T_DOT
        self.matchToken, self.TOKEN.T_DOT
        if self.tag ne self.TOKEN.T_IDENT then begin
            self.error, 'identifier expected'
        endif else begin
            node = IdentNode(self.lexer.start_pos, self.lexeme)
            self.matchToken, self.TOKEN.T_IDENT
        endelse
    endelse
    return, node
end

function ExprParser::parse_atom
    ; atom : (...) | [...] | {...} | IDENT | NUMBER | STRING | !NULL | SYSVAR
    if self.tag eq self.TOKEN.T_LPAREN then begin
        self.matchToken, self.tag
        if self.tag ne self.TOKEN.T_RPAREN then begin
            node = self.parse_expr_list(self.TOKEN.T_LPAREN, self.TOKEN.T_RPAREN)
        endif else begin
            node = ListNode(self.lexer.start_pos, self.TOKEN.T_LPAREN)
        endelse
        self.matchToken, self.TOKEN.T_RPAREN
        
    endif else if self.tag eq self.TOKEN.T_LBRACKET then begin
        self.matchToken, self.tag
        if self.tag ne self.TOKEN.T_RBRACKET then begin
            node = self.parse_array_literal()
        endif else begin
            node = NullNode(self.lexer.start_pos, '[]')
        endelse
        self.matchToken, self.TOKEN.T_RBRACKET
        
    endif else if self.tag eq self.TOKEN.T_LCURLY then begin
        self.matchToken, self.tag
        if self.tag ne self.TOKEN.T_RCURLY then begin
            node = self.parse_deflist(self.TOKEN.T_LCURLY)
        endif else begin
            node = ListNode(self.lexer.start_pos, self.TOKEN.T_LCURLY)
        endelse
        self.matchToken, self.TOKEN.T_RCURLY
        
    endif else if self.tag eq self.TOKEN.T_HASH_LCURLY then begin  ; hash literal
        self.matchToken, self.tag
        if self.tag ne self.TOKEN.T_RCURLY then begin
            node = self.parse_deflist(self.TOKEN.T_HASH_LCURLY)
        endif else begin
            node = ListNode(self.lexer.start_pos, self.TOKEN.T_HASH_LCURLY)
        endelse
        self.matchToken, self.TOKEN.T_RCURLY
        
    endif else if self.tag eq self.TOKEN.T_IDENT then begin
        node = IdentNode(self.lexer.start_pos, self.lexeme)
        self.getToken
        
    endif else if (typeCode = self.numberCode(self.tag)) ne -1 then begin
        node = NumberNode(self.lexer.start_pos, self.lexeme, typeCode)
        self.getToken
        
    endif else if self.tag eq self.TOKEN.T_STRING then begin
        node = StringNode(self.lexer.start_pos, self.lexeme)
        self.getToken
        
    endif else if self.tag eq self.TOKEN.T_NULL then begin
        node = NullNode(self.lexer.start_pos, self.lexeme)
        self.getToken
        
    endif else if self.tag eq self.TOKEN.T_SYSV then begin
        node = SysvarNode(self.lexer.start_pos, self.lexeme)
        self.getToken
        
    endif else begin
        self.error, 'Unrecognized token ' + self.lexeme
    endelse

    return, node
end

function ExprParser::parse_power
    ; power : atom trailer* ['^' factor]
    node = self.parse_atom()

    while self.isTrailerOperator(self.tag) do begin
        tag = self.tag
        ; Note the tag is not matched here because the trailer products include
        ; brackets etc.
        ;node = self.parse_trailer()
        if self.tag eq self.TOKEN.T_LPAREN then begin
            node = FuncCallNode(self.lexer.start_pos, node, self.parse_trailer())
        endif else if self.tag eq self.TOKEN.T_LBRACKET then begin
            node = SubscriptNode(self.lexer.start_pos, node, self.parse_trailer())
        endif else begin ; T_DOT
            node = MemberNode(self.lexer.start_pos, node, self.parse_trailer())
        endelse

    endwhile

    if self.tag eq self.TOKEN.T_EXP then begin
        self.matchToken, (tag = self.tag)
        node = BinOpNode(self.lexer.start_pos, tag, node, self.parse_factor())
    endif

    return, node
end

function ExprParser::parse_factor
    ; factor : ('+' | '-' | 'NOT' | '~') factor | power
    if self.isUnaryOperator(self.tag) then begin
        self.matchToken, (tag = self.tag)
        node = UnaryOpNode(self.lexer.start_pos, tag, self.parse_factor())
    endif else begin
        node = self.parse_power()
    endelse
    return, node
end

function ExprParser::parse_term_expr
    ; * / MOD # ##
    node = self.parse_factor()
    while self.isTermOperator(self.tag) do begin
        self.matchToken, (tag = self.tag)
        node = BinOpNode(self.lexer.start_pos, tag, node, self.parse_factor())
    endwhile
    return, node
end

function ExprParser::parse_arith_expr
    ; + - < >
    node = self.parse_term_expr()
    while self.isArithOperator(self.tag) do begin
        self.matchToken, (tag = self.tag)
        node = BinOpNode(self.lexer.start_pos, tag, node, self.parse_term_expr())
    endwhile
    return, node
end

function ExprParser::parse_relational_expr
    ; relational_expr : arith_expr (relation_op arith_expr)*
    node = self.parse_arith_expr()
    while self.isRelationOperator(self.tag) do begin
        self.matchToken, (tag = self.tag)
        node = BinOpNode(self.lexer.start_pos, tag, node, self.parse_arith_expr())
    endwhile
    return, node
end

function ExprParser::parse_bitwise_expr
    ; bitwise_expr : relational_expr (bitwise_op relational_expr)*
    ; bitwise_op : 'AND' | 'OR' | 'XOR'
    node = self.parse_relational_expr()
    while self.isBitWiseOperator(self.tag) do begin
        self.matchToken, (tag = self.tag)
        node = BinOpNode(self.lexer.start_pos, tag, node, self.parse_relational_expr())
    endwhile
    return, node
end

function ExprParser::parse_logical_expr
    ; logical_expr : bitwise_expr (logical_op bitwise_expr)*
    ; logical_op : '&&' | '||'
    node = self.parse_bitwise_expr()
    while self.isLogicalOperator(self.tag) do begin
        self.matchToken, (tag = self.tag)
        node = BinOpNode(self.lexer.start_pos, tag, node, self.parse_bitwise_expr())
    endwhile
    return, node
end


function ExprParser::parse_ternary_expr
    ; ternary_expr : logical_expr ['?' logical_expr ':' logical_expr]
    node = self.parse_logical_expr()
    if self.tag eq self.TOKEN.T_QMARK then begin
        self.matchToken, self.tag
        node_true = self.parse_logical_expr()
        self.matchToken, self.TOKEN.T_COLON
        node_false = self.parse_logical_expr()
        node = TerneryOpNode(self.lexer.start_pos, node, node_true, node_false)
    endif
    return, node
end

function ExprParser::parse_expr_list, ldelimiter, rdelimiter
    ; expr_list : ternary_expr (',' ternary_expr)* [',']
    
    node = self.parse_ternary_expr()
    
    while self.tag eq self.TOKEN.T_COMMA do begin
        self.matchToken, self.tag
        if ~isa(node, 'ListNode') then begin
            node = ListNode(self.lexer.start_pos, ldelimiter, node)
        endif
        ; An optional comma is allowed at the end. This is important as it is required
        ; to defferiate whether the code is a number (1) or a list (1,)
        if self.tag ne rdelimiter then node.add, self.parse_ternary_expr() else break
    endwhile
    
    return, node
end


; At the end of each parse function, self.tag always points to the next
; un-processed token.
function ExprParser::parse, line
    self.lexer.feed, line
    self.getToken
    if self.tag eq self.TOKEN.T_EOL then message, 'no code found'
    node = self.parse_ternary_expr()
    if self.tag ne self.TOKEN.T_EOL then begin
        self.error, 'erroneous trailing characters'
    endif
    return, node
end


pro ExprParser::error, msg
    message, 'ParserError: ' + msg
end

function ExprParser::numberCode, tag
    case tag of
        self.TOKEN.T_BYTE: typeCode = 1
        self.TOKEN.T_INT: typeCode = 2
        self.TOKEN.T_UINT: typeCode = 12
        self.TOKEN.T_LONG: typeCode = 3
        self.TOKEN.T_ULONG: typeCode = 13
        self.TOKEN.T_LONG64: typeCode = 14
        self.TOKEN.T_ULONG64: typeCode = 15
        self.TOKEN.T_FLOAT: typeCode = 4
        self.TOKEN.T_DOUBLE: typeCode = 5
        else: typeCode = -1
    endcase
    return, typeCode
end

function ExprParser::isTrailerOperator, operator
    if operator eq self.TOKEN.T_LPAREN || operator eq self.TOKEN.T_LBRACKET || operator eq self.TOKEN.T_DOT then return, 1 else return, 0
end

function ExprParser::isUnaryOperator, operator
    if where([self.TOKEN.T_ADD, self.TOKEN.T_SUB, self.TOKEN.T_BNOT, self.TOKEN.T_LNOT] eq operator, /null) ne !NULL then return, 1 else return, 0
end

function ExprParser::isTermOperator, operator
    if where([self.TOKEN.T_MUL, self.TOKEN.T_DIV, self.TOKEN.T_MOD, self.TOKEN.T_HASH, self.TOKEN.T_DHASH] eq operator, /null) ne !NULL then return, 1 else return, 0
end

function ExprParser::isArithOperator, operator
    if where([self.TOKEN.T_ADD, self.TOKEN.T_SUB, self.TOKEN.T_MIN, self.TOKEN.T_MAX] eq operator, /null) ne !NULL then return, 1 else return, 0
end

function ExprParser::isRelationOperator, operator
    if where([self.TOKEN.T_EQ, self.TOKEN.T_NE, self.TOKEN.T_GE, self.TOKEN.T_GT, self.TOKEN.T_LE, self.TOKEN.T_LT] eq operator, /null) ne !NULL then return, 1 else return, 0

end

function ExprParser::isBitWiseOperator, operator
    if operator eq self.TOKEN.T_BAND || operator eq self.TOKEN.T_BOR || operator eq self.TOKEN.T_BXOR then return, 1 else return, 0
end

function ExprParser::isLogicalOperator, operator
    if operator eq self.TOKEN.T_LAND || operator eq self.TOKEN.T_LOR then return, 1 else return, 0
end

pro ExprParser::matchToken, tag
    if self.tag ne tag then begin
        self.error, self.lexeme
    endif
    self.getToken
end


pro ExprParser::getToken
    self.tag = self.lexer.getToken()
    self.lexeme = self.lexer.getLexeme()
end

pro ExprParser::cleanup
end


function ExprParser::init
    self.TOKEN = getTokenCodes()
    self.lexer = ExprLexer()
    return, 1
end


pro ExprParser__define, class
    class = {ExprParser, inherits IDL_Object, $
        TOKEN: obj_new(), $
        lexer: obj_new(), $
        tag: 0, $
        lexeme: ''}
end

