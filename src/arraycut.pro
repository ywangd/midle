; docformat = 'rst'

;+
; :Author:
; 	Yang Wang (ywangd@gmail.com)
;-

;+
; :Description:
;    This function is similar to IDL_Object's _overloadBracketsRightSide.
;    The input array `_a` is subsetted using the given subX arguments.
;
; :Params:
;    _a : in, required, type=any
;       
;    isRanges : in, required, type=int
;       A vector with length equals to the number of subX arguments passed 
;       or equals to the length of sub1 if sub1 is a list.
;    sub1 : in, required
;       The subscript spec to the first dimension. Or it can be a list
;       containing subscript specs of all dimensions. All other subX 
;       arguments are ignored if sub1 is a list. 
;       http://www.exelisvis.com/docs/Overloading_the_Array_In.html
;       Read for more information about subscript and subscript ranges. 
;
;-
function arraycut, _a, isRanges, sub1, sub2, sub3, sub4, sub5, sub6, sub7, sub8

    ; If the first sub parameter is a list, all other sub parameters are ignored
    if isa(sub1, 'List') then begin
        theList = sub1
        foreach li, theList, ii do begin
            (scope_varfetch('sub' + strtrim(ii+1,2))) = li
        endforeach
    endif

    shp = size(_a, /dimension)
    if isa(shp, /scalar) then shp = [1] ; scalar is the same as 1 elment array
    nd = n_elements(shp)

    nsubs = n_elements(isRanges)

    subs = list()

    ; Special case when only one subsript and it is of range type.
    ; This kind subscript indexes to all elements in an array, not
    ; just the first dimension
    if nsubs eq 1 && isRanges[0] eq 1 then begin
        subs.add, (lindgen(product(shp, /preserve_type)))[sub1[0]:sub1[1]:(n_elements(sub1) eq 2 ? 1 : sub1[2])]
        isRanges[0] = 0
    endif else begin
        foreach isr, isRanges, ii do begin
            if isr eq 1 then begin
                r = scope_varfetch('sub' + strtrim(ii+1,2))
                if ii lt nd then begin
                    subs.add, (lindgen(shp[ii]))[r[0]:r[1]:(n_elements(r) eq 2 ? 1 : r[2])]
                endif else begin
                    ; Number of subscripts is larger than number of dimension.
                    ; Therefore the subscript has to be 0:0 or 0:-1
                    if r[0] ne 0 || (r[1] ne -1 && r[1] ne 0) then message, 'Invalid subscript range'
                endelse
            endif else begin
                idx = scope_varfetch('sub' + strtrim(ii+1,2))
                if ii lt nd then begin
                    subs.add, idx
                endif else begin
                    if max(idx) gt 0 then message, 'Invalid subscript range'
                endelse
            endelse
        endforeach
    endelse

    if max(isRanges) gt 0 then begin  ; at least one subscript is range
        ; Range type subscripts are different from non-range type, even when their values
        ; are the same. For an example, an 2x2 array is indgen(2,2).
        ; array[[0,1],[0,1]] is not the same as array[*,*], though the * range is translated
        ; to 0,1 which is the same to the non-range subscripts.

        ; If the number of subscripts is less than number of dimension, pad 0 to the end
        if subs.count() lt nd then subs.add, replicate(0, nd-subs.count()), /extract
        a = _a
        foreach sub, subs, ii do a = yw_slice_nd(a, sub, dimension=ii+1)

    endif else begin ; non-range subscript
        case nsubs of
            1: a = _a[subs[0]]
            2: a = _a[subs[0], subs[1]]
            3: a = _a[subs[0], subs[1], subs[2]]
            4: a = _a[subs[0], subs[1], subs[2], subs[3]]
            5: a = _a[subs[0], subs[1], subs[2], subs[3], subs[4]]
            6: a = _a[subs[0], subs[1], subs[2], subs[3], subs[4], subs[5]]
            7: a = _a[subs[0], subs[1], subs[2], subs[3], subs[4], subs[5], subs[6]]
            8: a = _a[subs[0], subs[1], subs[2], subs[3], subs[4], subs[5], subs[6], subs[7]]
        endcase
    endelse

    return, a

end