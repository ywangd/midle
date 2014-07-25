; docformat = 'rst'

;+
; The purpose of this routine is to concatenate two arrays along any given
; dimension. 
; 
; The idea is to reform the input arrays to 3-D arrays with the 2nd dimension 
; being the dimension to be concatecated and concatenate on the dimension.
; 
; The results are reformed back to the desired shape after concatenation.
;   The advantage is that the function is not limited by the number of brackets
; while performing concatenation (IDL allows up to 3 levels of brackets).
;
; :Author:
;   Yang Wang (ywangd@gmail.com)
;
; :Keywords:
;   dimension : in, optional, type=int, default=1
;       The 1-based dimension index where the concatenation is performed.
;
;-
function arrayconcat, a1, a2, dimension=dimension

    ; If any of the array is !NULL, simply return the simple concatenation
    if n_elements(a1) eq 0 || n_elements(a2) eq 0 then return, [a1, a2]
    if n_elements(dimension) eq 0 then dimension=1

    on_ioerror, ERR  ; handle type conversion error when concatenating

    switch dimension of
        1: return, [a1, a2]
        2: return, [[a1], [a2]]
        3: return, [[[a1]], [[a2]]]
        4:
        5:
        6:
        7:
        8: begin
            s1 = size(a1) & nd1 = s1[0] & shp1 = nd1 eq 0 ? [1] : s1[1:nd1]
            s2 = size(a2) & nd2 = s2[0] & shp2 = nd2 eq 0 ? [1] : s2[1:nd2]

            ; Number of dimension of the result
            nd = nd1 > nd2 > dimension
            shp1 = n_elements(shp1) eq nd ? shp1 : [shp1, replicate(1,nd - n_elements(shp1))]
            shp2 = n_elements(shp2) eq nd ? shp2 : [shp2, replicate(1,nd - n_elements(shp2))]

            ; Check whether dimensions agree
            idx = where((shp1 eq shp2) eq 0, count)
            if count gt 1 || (count eq 1 && idx[0] + 1 ne dimension) then $
                message, 'Dimensions do not agree for concatenate'

            ; Shape of the result
            shp = shp1 & shp[dimension-1] += shp2[dimension-1]

            take = dimension eq 1 ? 1 : product(shp[0:dimension-2], /preserve_type)
            tail = dimension eq nd ? 1 : product(shp[dimension:nd-1], /preserve_type)

            ; Concatenate the arrays by reforming them to sub 3D arrays
            conc = [[reform(a1,take,shp1[dimension-1],tail)], [reform(a2,take,shp2[dimension-1],tail)]]

            ; Reform back to the original shape
            return, reform(conc, shp)
        end

        else: message, 'Invalid dimension (min: 1, max: 8)'
    endswitch
    
    ERR:
    message, !error_state.msg, /noprefix, /noname, /noprint

end

