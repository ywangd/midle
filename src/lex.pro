
function lex, lines
    lexer = MidleLexer()
    stream = lexer.lex(lines)
    
    return, stream
end