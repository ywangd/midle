
pro ExprLexer_ut::setup
    self.lexer = ExprLexer()
end

function ExprLexer_ut::test_lexer_1
    self.lexer.feed, 'a + a.b + "Hello World "" " + "OK" + "" '
    tokenlist = ['T_IDENT','T_ADD','T_IDENT','T_DOT','T_IDENT','T_ADD','T_STRING','T_ADD','T_STRING','T_ADD','T_STRING','T_EOL']
    symbollist = ['a','+','a','.','b','+','"Hello World "" "','+','"OK"','+','""','']
    idx = 0
    repeat begin
        token = self.lexer.getToken()
        t = strupcase((self.lexer.TOKEN.where(token))[0])
        s = self.lexer.getLexeme()
        assert, t eq tokenlist[idx], 'incorrect token %s', t
        assert, s eq symbollist[idx], 'incorrect symbol %s', s
        idx += 1
    endrep until token eq self.lexer.TOKEN.T_EOL

    return, 1
end


function ExprLexer_ut::test_lexer_2
    self.lexer.feed, '1 42 42. .42 42.42 42L 42D 42e2 42D2 42LL 42UL 42ULL'
    tokenlist = ['T_INT','T_INT','T_FLOAT','T_FLOAT','T_FLOAT','T_LONG','T_DOUBLE','T_FLOAT','T_DOUBLE','T_LONG64','T_ULONG','T_ULONG64','T_EOL']
    symbollist = ['1','42','42.','.42','42.42','42L','42D','42e2','42D2','42LL','42UL','42ULL','']
    idx = 0
    repeat begin
        token = self.lexer.getToken()
        t = strupcase((self.lexer.TOKEN.where(token))[0])
        s = self.lexer.getLexeme()
        assert, t eq tokenlist[idx], 'incorrect token %s', t
        assert, s eq symbollist[idx], 'incorrect symbol %s', s
        idx += 1
    endrep until token eq self.lexer.TOKEN.T_EOL

    return, 1
end


pro ExprLexer_ut__define, class
    class = { ExprLexer_ut, inherits MGutTestCase, $
        lexer: Obj_New()}
end

