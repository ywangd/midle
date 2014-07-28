; docformat = 'rst'

;+
; The token codes used by MIDLE.
; 
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function getTokenCodes

    TOKEN = Dictionary()
    TOKEN.T_EOF = 0
    TOKEN.T_EOL = 10
    TOKEN.T_NULL = 256
    TOKEN.T_BYTE = 257
    TOKEN.T_INT =  258
    TOKEN.T_INT_AUTO = 267 ; auto-promoting integer
    TOKEN.T_UINT = 259
    TOKEN.T_UINT_AUTO = 268 ; auto-promoting unsigned integer
    TOKEN.T_LONG = 260
    TOKEN.T_ULONG = 261
    TOKEN.T_LONG64 = 262
    TOKEN.T_ULONG64 = 263
    TOKEN.T_FLOAT = 264
    TOKEN.T_DOUBLE = 265
    TOKEN.T_STRING = 266
    TOKEN.T_ADD = 271
    TOKEN.T_SUB = 272
    TOKEN.T_MUL = 273
    TOKEN.T_DIV = 274
    TOKEN.T_MOD = 275
    TOKEN.T_EXP = 276
    TOKEN.T_HASH = 277
    TOKEN.T_DHASH = 278
    TOKEN.T_BNOT = 291
    TOKEN.T_BAND = 292
    TOKEN.T_BOR = 293
    TOKEN.T_BXOR = 294
    TOKEN.T_LNOT = 301
    TOKEN.T_LAND = 302
    TOKEN.T_LOR = 303
    TOKEN.T_EQ = 311
    TOKEN.T_NE = 312
    TOKEN.T_GE = 313
    TOKEN.T_GT = 314
    TOKEN.T_LE = 315
    TOKEN.T_LT = 316
    TOKEN.T_MAX = 321
    TOKEN.T_MIN = 322
    TOKEN.T_QMARK = 323
    TOKEN.T_DOT = 331
    TOKEN.T_ARROW = 332
    TOKEN.T_COLON = 333
    TOKEN.T_COMMA = 334
    TOKEN.T_ASSIGN = 335
    TOKEN.T_SEMICOLON = 336
    TOKEN.T_DOLLAR = 337
    TOKEN.T_LPAREN = 341
    TOKEN.T_RPAREN = 342
    TOKEN.T_LBRACKET = 343
    TOKEN.T_RBRACKET = 344
    TOKEN.T_LCURLY = 345
    TOKEN.T_RCURLY = 346
    TOKEN.T_HASH_LCURLY = 347
    TOKEN.T_IDENT = 401
    TOKEN.T_SYSV = 411
    
    return, TOKEN
end
