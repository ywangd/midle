
pro AstNode::error, msg
    message, string(self.colno, msg, format='("[Col ", I0, "] ", A)')
end


function AstNode::eval, env
    message, 'This method must be overidden'
end


pro AstNode::add, node
    self.operands.add, node
end

function AstNode::print_helper
    return, typename(self)
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

pro AstNode::cleanup
end

function AstNode::init
    if ~self->IDL_Object::init() then return, 0
    self.operands = list()
    return, 1
end

pro AstNode__define, class
    class = {AstNode, inherits IDL_Object, $
        operands: obj_new(), $
        lineno: 0L, $
        colno: 0L }
end


a = astnode()
a.add, astnode()
b = binop('+')
b.add, astnode()
c = astnode()
c.add, astnode()
b.add, c
a.add, b
a.add, astnode()
print, a
end