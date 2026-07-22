
/*------------------------------------------------------------------------
    File        : init-shift-period.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : user
    Created     : Mon Mar 03 12:49:12 MSK 2025
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

block-level on error undo, throw.

{ cmp/str-glbl.i }
{ ref/gds-attr.i }
{ str/placelib.i }

define input parameter p-rid-list as character no-undo .

define buffer buf_place for ub.place .
define buffer buf_pl-gds for ub.pl-gds .
define buffer buf_place-attr for ub.place-attr .
define buffer buf_rvs-doc for ub.rvs-doc .
define buffer buf_rvs-line for ub.rvs-line .

define variable ii as integer no-undo .
define variable v-value as character no-undo .
define variable par-type as character no-undo .
define variable v-ok as logical no-undo .
/* ***************************  Main Block  *************************** */

find first sys-ctrl no-lock no-error.
if not available sys-ctrl then return error return-value .



if p-rid-list = "all"
then do :
  for each buf_place no-lock :
    find first buf_pl-gds no-lock where buf_pl-gds.pl-code = buf_place.pl-code no-error .
    if not available buf_pl-gds then next .
    
    &scop proc-name gds-attr-value
    {&run_proc_attr-lib}
      (input  buf_pl-gds.gds-code
      ,input  {&attr-fuel-type}
      ,output v-value
      ,output par-type) no-error.
    if v-value = "lgas"
    or v-value = "metan"
    or v-value = "propan"
    then next .
    
    run placelib_get-attr  ( input {&place-com-tanks}
                            ,input buf_place.obj-code
                            ,input buf_place.obj-type
                            ,input buf_place.pl-code
                            ,output v-value
                            ,output v-ok      ) no-error.
    if v-ok
    and v-value > ""
    then do :
      run placelib_get-attr  ( input {&place-is-main}
                              ,input buf_place.obj-code
                              ,input buf_place.obj-type
                              ,input buf_place.pl-code
                              ,output v-value
                              ,output v-ok      ) no-error.
      if v-ok
      and v-value > ""
      and logical(v-value)
      then do :
      end .
      else do :
        next .
      end .
    end .
    
    run init_ .
  end .
end .
else do :
  do ii = 1 to num-entries(p-rid-list) :
    for first buf_place no-lock where recid(buf_place) = integer(entry(ii, p-rid-list)) :
      find first buf_pl-gds no-lock where buf_pl-gds.pl-code = buf_place.pl-code no-error .
      if not available buf_pl-gds then next .
      
      &scop proc-name gds-attr-value
      {&run_proc_attr-lib}
        (input  buf_pl-gds.gds-code
        ,input  {&attr-fuel-type}
        ,output v-value
        ,output par-type) no-error.
      if v-value = "lgas"
      or v-value = "metan"
      or v-value = "propan"
      then next .
      
      run placelib_get-attr  ( input {&place-com-tanks}
                              ,input buf_place.obj-code
                              ,input buf_place.obj-type
                              ,input buf_place.pl-code
                              ,output v-value
                              ,output v-ok      ) no-error.
      if v-ok
      and v-value > ""
      then do :
        run placelib_get-attr  ( input {&place-is-main}
                                ,input buf_place.obj-code
                                ,input buf_place.obj-type
                                ,input buf_place.pl-code
                                ,output v-value
                                ,output v-ok      ) no-error.
        if v-ok
        and v-value > ""
        and logical(v-value)
        then do :
        end .
        else do :
          next .
        end .
      end .
      
      run init_ .
    end .
  end .
end .

procedure init_ :
  for each buf_rvs-doc no-lock where buf_rvs-doc.obj-type = buf_place.obj-type
                                 and buf_rvs-doc.obj-code = buf_place.obj-code
                                 and buf_rvs-doc.status_  = {&fact}
                                 and buf_rvs-doc.rvs-type = {&rvs-shift}
                                 use-index shift :
    find first buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                      and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                                      and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
                                      and buf_rvs-line.pl-code  = buf_pl-gds.pl-code
                                      and buf_rvs-line.gds-code = buf_pl-gds.gds-code
                                      no-error .
    if available buf_rvs-line
    then do :
      find first buf_place-attr exclusive-lock where buf_place-attr.obj-type = buf_place.obj-type
                                                 and buf_place-attr.obj-code = buf_place.obj-code
                                                 and buf_place-attr.pl-code  = buf_place.pl-code
                                                 and buf_place-attr.attr-code = "init-shift-period-rvs"
                                                 no-error .
      if not available buf_place-attr
      then do :
        create buf_place-attr .
        assign
          buf_place-attr.obj-type = buf_place.obj-type
          buf_place-attr.obj-code = buf_place.obj-code
          buf_place-attr.pl-code  = buf_place.pl-code
          buf_place-attr.attr-code = "init-shift-period-rvs"
        .
      end .
      assign buf_place-attr.attr-value = buf_rvs-doc.rvs-code .
      
      leave .
    end .
  end .
end procedure .