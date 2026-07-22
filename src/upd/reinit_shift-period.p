
/*------------------------------------------------------------------------
    File        : 1Csendplace.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : SSlivenko
    Created     : Wed Nov 26 12:34:59 MSK 2025
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

block-level on error undo, throw.

define input  parameter parparentproc as handle no-undo.
define input  parameter iparam        as character no-undo.
define output parameter oOk           as logical no-undo.

{ cmp/str-glbl.i } 
{ ref/gds-attr.i }
{ str/placelib.i }

define buffer buf_shift-period for ub.shift-period .
define buffer buf_place for ub.place .
define buffer buf_pl-gds for ub.pl-gds .

define variable place-list as character no-undo .
define variable v-value as character no-undo .
define variable par-type as character no-undo .
define variable v-ok as logical no-undo .
/* ***************************  Main Block  *************************** */

place_ :
for each buf_place no-lock :
  find first buf_pl-gds no-lock where buf_pl-gds.pl-code = buf_place.pl-code no-error .
  if not available buf_pl-gds then next place_ .
  
  &scop proc-name gds-attr-value
  {&run_proc_attr-lib}
    (input  buf_pl-gds.gds-code
    ,input  {&attr-fuel-type}
    ,output v-value
    ,output par-type) no-error.
  if v-value = "lgas"
  or v-value = "metan"
  or v-value = "propan"
  then next place_ .
  
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
      next place_ .
    end .
  end .
  
  find first buf_shift-period no-lock where buf_shift-period.obj-type = buf_place.obj-type
                                        and buf_shift-period.obj-code = buf_place.obj-code
                                        and buf_shift-period.gds-code = buf_pl-gds.gds-code
                                        and buf_shift-period.pl-code  = buf_pl-gds.pl-code
  no-error .
  if not available buf_shift-period
  then do :
    assign place-list = place-list + string(recid(buf_place)) + "," .
  end .
end .
place-list = trim(place-list, ",") .
if place-list > ""
then do :
  run utl/init-shift-period.p (input place-list) .
end .

oOk = true.
