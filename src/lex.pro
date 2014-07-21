
function lex, line
    lexer = ExprLexer()
    stream = lexer.lex(line)
    
    return, stream
end