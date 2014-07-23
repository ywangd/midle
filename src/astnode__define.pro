
pro AstNode::error, msg
    message, string(self.colno, msg, format='("RuntimeError [Col ", I0, "] ", A)')
end


function AstNode::eval, env
    message, 'This method must be overidden'
end

function AstNode::name
    name = strupcase(typename(self))
    idx = strpos(name, 'NODE')
    if idx ge 0 then name = strmid(name, 0, idx)
    return, name
end

pro AstNode::add, node
    self.operands.add, node
end

function AstNode::print_helper
    return, self.name()
end

function AstNode::_overloadImpliedPrint, varname, sublevel
    return, self._overloadPrint(sublevel)
end

function AstNode::_overloadPrint, sublevel
    if n_elements(sublevel) eq 0 then sublevel = 0
    
    ret = [self.print_helper()]
    if sublevel gt 0 then ret = '  +-- ' + ret
    foreach operand, self.operands do begin
        subret = operand._overloadPrint(sublevel+1)
        if sublevel gt 0 then subret = '      ' + subret
        ret = [ret, subret]
    endforeach
    
    return, sublevel eq 0 ? transpose(ret) : ret
end

function AstNode::getOperand, idx
    return, (self.operands)[idx]
end

pro AstNode::setProperty, lineno=lineno, colno=colno
    if n_elements(lineno) ne 0 then self.lineno = lineno
    if n_elements(colno) ne 0 then self.colno = colno
end

pro AstNode::getProperty, lexer=lexer, lineno=lineno, colno=colno, operands=operands
    if arg_present(lexer) then lexer = self.lexer
    lineno = self.lineno
    colno = self.colno
    if arg_present(operands) then operands = self.operands
end


pro AstNode::cleanup
end

function AstNode::init, lexer
    if ~self->IDL_Object::init() then return, 0
    self.lexer = lexer
    self.lineno = self.lexer.lineno
    self.colno = self.lexer.start_pos
    self.operands = list()
    return, 1
end

pro AstNode__define, class
    class = {AstNode, inherits IDL_Object, $
        lexer: obj_new(), $
        operands: obj_new(), $
        lineno: 0L, $
        colno: 0L }
end

