; docformat = 'rst'

;+
; The purpose of this routine is to return the indices of arbitrary slices on
; arbitrary dimension of an array.
; 
;   The routine is modified from JD Smith's slice_nd. The feature of this 
; routine is that the slice is not limited to be a single slice. Multiple 
; slices can be retrieved if a vector is passed in the position of the `slice`
; parameter.
; 
;   NOTE that the dimension keyword parameter starts from 1 as the first
; dimension (while JD Smith's slice_nd counts dimension from 0).
; 
; :Author:
;   Yang Wang (ywangd@gmail.com)
;
; :Returns:
;   The indices of the slices.
;
; :Params:
;   array : in, required, type=any
;       The input array for slicing
;   slice : in, required, type=integer
;       The indices for taking slices on the dimension. Ranges from 0 to size
;       of the dimension minus one. Can be either a scalar or vector.
;
; :Keywords:
;   dimension : in, optional, type=integer, default=1
;       The dimension where the slices are taken. Starts from 1 for the first
;       dimension.
;
; :Examples:
; ::
;
;   a = lindgen(5,4,3,2)
;   help, yw_slice_nd(a, 1, dim=2)
;   help, yw_slice_nd(a, [0,2], dim=2)
;
;-
function yw_slice_nd, array, slice, dimension=dim

    compile_opt logical_predicate, strictarrsubs

    if n_elements(dim) eq 0 then dim=1
    ;
    nslices = n_elements(slice)
    ;
    shape = size(array, /dimensions)
    ndims = n_elements(shape)
    
    if max(slice) ge shape[dim-1] then message, 'Invalid slicing index'
    ;
    ; Special case for input array is a vector
    if ndims eq 1 then return, array[slice]

    ; Normal cases
    take = dim eq 1 ? 1 : product(shape[0:dim-2], /preserve_type)
    skip = take*shape[dim-1]

    t = [take, nslices, dim eq ndims ? 1 : product(shape[dim:ndims-1], /preserve_type)]

    shape[dim-1] = nslices

    ind = rebin(transpose([slice]*take), take, nslices, t[2], /sample) $
        + rebin(lindgen(t[0]), t, /sample) $
        + skip*rebin(lindgen(1,1,t[2]), t, /sample)

    ind = reform(ind, shape, /overwrite)

    return, array[ind]

end

