
function lex, line
    lexer = MidleLexer()
    stream = lexer.lex(line)
    
    return, stream
end