
function SubscriptNode::eval, env
    
    collection = (self.operands[0]).eval(env)
    nsubs = (self.operands[1]).operands.count()
    
    ; For Hash or list, only the first subscript is applied to the collection itself.
    ; The rest of the subscripts, if any, are applied to the child elements.
    currentIndex = 0
    while (isa(collection, 'List') || isa(collection, 'Hash')) && currentIndex lt nsubs do begin
        idxlist = (self.operands[1]).eval(env, [n_elements(collection)], fromIndex=currentIndex, toIndex=currentIndex)
        collection = collection[idxlist[0]]
        currentIndex += 1
    endwhile
    
    ; End the program flow if we have exhausted the number of subscripts
    if currentIndex eq nsubs  then return, collection
    
    ; If program reaches here, collections should now be a regular array 
    ; Use what is left of the subscripts and treat the first subscript as the first dimension.
    ; Note that hash or list can nest subscript arrays but not vice versa.
    ; That is IDL does not support indexing directly into a list that is a member of an array.
    ; E.g. this is illegal a = [list(1,2,3)] & print, a[0,1]
    shp = size(collection, /dimension)
    nd = n_elements(shp)
    ; Scalar is the same as array of dimension [1]
    if isa(shp, /scalar) then shp = [1]
    ; Padding 1 to the shape so it becomes full 8 dimensions
    ; This is for the convenience of subsequent subscripts calculations
    if n_elements(shp) lt 8 then shp = [shp, replicate(1, 8-n_elements(shp))]
    
    ; Evalulate what is left of the subscripts
    idxlist = (self.operands[1]).eval(env, shp, fromIndex=currentIndex, isRanges=isRanges)
    
    if max(isRanges) gt 0 then begin
        if idxlist.count() lt nd then idxlist.add, replicate(0, nd-idxlist.count()), /extract
        foreach index, idxlist, ii do begin
            if ii lt nd then begin
                collection = yw_slice_nd(collection, index, dimension=ii+1)
            endif else begin
                if n_elements(index) eq 1 && index[0] eq 0 $
                    then continue $
                    else self.error, 'Invalid subscript range' 
            endelse
        endforeach
        
    endif else begin
        case idxlist.count() of
            1: collection = collection[idxlist[0]]
            2: collection = collection[idxlist[0], idxlist[1]]
            3: collection = collection[idxlist[0], idxlist[1], idxlist[2]]
            4: collection = collection[idxlist[0], idxlist[1], idxlist[2], idxlist[3]]
            5: collection = collection[idxlist[0], idxlist[1], idxlist[2], idxlist[3], idxlist[4]]
            6: collection = collection[idxlist[0], idxlist[1], idxlist[2], idxlist[3], idxlist[4], idxlist[5]]
            7: collection = collection[idxlist[0], idxlist[1], idxlist[2], idxlist[3], idxlist[4], idxlist[5], idxlist[6]]
            8: collection = collection[idxlist[0], idxlist[1], idxlist[2], idxlist[3], idxlist[4], idxlist[5], idxlist[6], idxlist[7]]
        endcase
    endelse
    
    return, collection
    
end


function SubscriptNode::print_helper
    return, self.name()
end


function SubscriptNode::init, start_pos, collection, idxlist
    if ~self->AstNode::init(start_pos) then return, 0
    self.operands.add, collection
    self.operands.add, idxlist
    return, 1
end

pro SubscriptNode__define, class
    class = {SubscriptNode, inherits AstNode }
end