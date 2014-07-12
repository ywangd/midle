pro test_lexer

    p = ExprParser()
    
    a = p.parse('1 + 42 + 42. + .42 + 42.42 + 42L + 42D + 42e2 + 42D2 + 42LL + 42UL + 42ULL')

    a = p.parse('a + a.b + "Hello World "" " + "OK"')

end

pro ExprParser_ut::setup
    self.parser = ExprParser()
end

function ExprParser_ut::getTokenList
    lexeme_list = []
    token_list = []
    repeat begin
        token = self.parser.getToken()
        lexeme_list = [lexeme_list, par
        strupcase((self.TOKEN.where(token))[0]), self.getLexeme(),
    endrep until token eq 0
end

function ExprParser_ut::testLexer
    assert

    return, 1
end

pro ExprParser_ut__define, class
    class = { ExprParser_ut__define, inherits MGutTestCase }
end
