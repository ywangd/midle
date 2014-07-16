pro ExprParser::parse_argument
    ; argument : ternary_expr ['=' ternary_expr]
    ; Note the keyword argument really should be ident '=' ternary_expr
    ; It is set this way to avoid ambiguity. The expr before '=' will
    ; be checked programmatically to make sure it is ident for keyword
    ; argument.
end

pro ExprParser::parse_arglist
    ; arglist : argument (',' argument)*
end

pro ExprParser::parse_sliceop
    ; sliceop : ':' (ternary_expr | '*') [':' (ternary_expr | '*')]
end

pro ExprParser::parse_idx
    ; idx : (ternary_expr | '*') [sliceop]
end

pro ExprParser::parse_idxlist
    ; idxlist : idx (, idx)*
end

pro ExprParser::parse_trailer
    ; trailer : (arglist) | [idxlist] | '.' IDENT
end

pro ExprParser::parse_atom
    ; atom : (...) | [...] | {...} | IDENT | NUMBER | STRING | !NULL |
end

pro ExprParser::parse_power
    ; power : atom trailer* ['^' factor]
end

pro ExprParser::parse_factor
    ; factor : ('+' | '-' | 'NOT' | '~') factor | power
end

pro ExprParser::parse_term_expr
    ; * / MOD # ##
end

pro ExprParser::parse_arith_expr
    ; + - < > 
end

pro ExprParser::parse_relational_expr
end

pro ExprParser::parse_bitwise_expr
    ; bitwise_expr : relational_expr (bitwise_op relational_expr)
    ; bitwise_op : 'AND' | 'OR' | 'XOR'
end

pro ExprParser::parse_logical_expr
    ; logical_expr : bitwise_expr (logical_op bitwise_expr)*
    ; logical_op : '&&' | '||'
end


pro ExprParser::parse_ternary_expr
    ; ternary_expr : logical_expr ['?' logical_expr ':' logical_expr]
    parse_logical_expr
    self.getToken
    if self.token eq self.lexer.TOKEN.T_QMARK then begin
        parse_logical_expr
        self.matchToken, self.lexer.TOKEN.T_COLON
        parse_logical_expr
    endif
end


pro ExprParser::parse, line
    self.lexer.feed, line
    self.parse_ternary_expr
    return, 1
end

pro ExprParser::getToken
    self.token = self.lexer.getToken()
    self.lexeme = self.lexer.getLexeme()
end

pro ExprParser::cleanup
end


function ExprParser::init
    self.lexer = ExprLexer()
    return, 1
end


pro ExprParser__define, class
    class = {ExprParser, inherits IDL_Object, $
        lexer: Obj_New(), $
        token: 0,
        lexeme: ''}
end

