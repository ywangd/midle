; docformat = 'rst'

;+
; :Author:
;   Yang Wang (ywangd@gmail.com)
;-

function SubscriptNode::eval, env
    compile_opt logical_predicate
    @ast_error_handler
    
    collection = (self.operands[0]).eval(env)
    subs =  self.operands[1] ; the IdxlistNode
    nsubs = subs.operands.count()
    
    ; For Hash or list, only the first subscript is applied to the collection itself.
    ; The rest of the subscripts, if any, are applied to the child elements.
    currentIndex = 0
    while (isa(collection, 'List') || isa(collection, 'Hash')) && currentIndex lt nsubs do begin
        thisSub = (subs.operands)[currentIndex].eval(env, isRange=isr)
        if isr then begin
            collection = collection[thisSub[0]:thisSub[1]:thisSub[2]]
        endif else begin
            collection = collection[thisSub]
        endelse
        currentIndex += 1
    endwhile
    
    ; End the program flow if we have exhausted the number of subscripts
    if currentIndex eq nsubs  then return, collection
    
    ; If program reaches here, the collection should now be a regular array 
    ; Use what is left of the subscripts and treat the first subscript as the first dimension.
    ; Note that hash or list can nest subscript arrays but not vice versa.
    ; That is IDL does not support indexing directly into a list that is a member of an array.
    ; E.g. this is illegal a = [list(1,2,3)] & print, a[0,1]
    
    ; Evalulate what is left of the subscripts
    idxlist = subs.eval(env, fromIndex=currentIndex, isRanges=isRanges)
    
    collection = arraycut(collection, isRanges, idxlist)
    
    return, collection
    
end


function SubscriptNode::print_helper
    return, self.name()
end


function SubscriptNode::init, lexer, collection, idxlist
    if ~self->AstNode::init(lexer) then return, 0
    self.operands.add, collection
    self.operands.add, idxlist
    return, 1
end

pro SubscriptNode__define, class
    class = {SubscriptNode, inherits AstNode }
end
