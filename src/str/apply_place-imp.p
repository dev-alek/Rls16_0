
/*------------------------------------------------------------------------
    File        : apply_place-imp.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : SlivenkoSA
    Created     : May 19 12:28:07 2025
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

block-level on error undo, throw.


define input parameter p-obj-type like ub.place-imp.obj-type no-undo .
define input parameter p-obj-code like ub.place-imp.obj-code no-undo .
define input parameter p-pl-code like ub.place-imp.pl-code no-undo .
define input parameter p-table-version like ub.place-imp.table-version no-undo .

define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

define buffer buf_place-imp for ub.place-imp .
define buffer buf_pl-level-imp for ub.pl-level-imp .
define buffer buf_pl-level-mm-imp for ub.pl-level-mm-imp .
define buffer buf_place for ub.place .
define buffer buf_place-attr for ub.place-attr .
define buffer buf_pl-level for ub.pl-level .
define buffer buf_pl-level-attr for ub.pl-level-attr .
define buffer buf_pl-level-mm for ub.pl-level-mm .

define variable v-ok as logical no-undo .
define variable v-today as date no-undo .
define variable v-time as integer no-undo .

{ str/placelib.i }
{ gbl/cur-time.i }
/* ***************************  Main Block  *************************** */

do on error undo, return error return-value :
  
  find first buf_place-imp no-lock where buf_place-imp.obj-type = p-obj-type
                                     and buf_place-imp.obj-code = p-obj-code
                                     and buf_place-imp.pl-code  = p-pl-code
                                     and buf_place-imp.table-version = p-table-version
                                     no-error .
  if not available buf_place-imp
  then do :
    return .
  end .
  
  find first buf_place exclusive-lock where buf_place.obj-type = buf_place-imp.obj-type
                                        and buf_place.obj-code = buf_place-imp.obj-code
                                        and buf_place.pl-code  = buf_place-imp.pl-code
                                        no-error .
  if not available buf_place
  then do :
    return error error-status:get-message(1).
  end .    
  
  if buf_place-imp.max-qnty <> ? then assign buf_place.max-qnty = buf_place-imp.max-qnty .
  
  if buf_place-imp.d-qnty <> ?
  then do :
    run placelib_write-attr  (input {&dead-balance}
        ,input buf_place.obj-code
        ,input buf_place.obj-type
        ,input buf_place.pl-code
        ,input string(buf_place-imp.d-qnty)
        ,output v-ok      )
    no-error.
  end .
  
  if buf_place-imp.tank-d <> ?
  then do :
    run placelib_write-attr  (input {&place-diameter}
        ,input buf_place.obj-code
        ,input buf_place.obj-type
        ,input buf_place.pl-code
        ,input string(buf_place-imp.tank-d)
        ,output v-ok      )
    no-error.
  end .
  
  if buf_place-imp.dc-height <> ?
  then do :
    run placelib_write-attr  (input {&place-dead-high}
        ,input buf_place.obj-code
        ,input buf_place.obj-type
        ,input buf_place.pl-code
        ,input string(buf_place-imp.dc-height)
        ,output v-ok      )
    no-error.
  end .
  
  if buf_place-imp.dnsty <> ?
  then do :
    run placelib_write-attr  (input {&place-dens-prov}
        ,input buf_place.obj-code
        ,input buf_place.obj-type
        ,input buf_place.pl-code
        ,input string(buf_place-imp.dnsty)
        ,output v-ok      )
    no-error.
  end .
  
  if buf_place-imp.main-mi-code <> ?
  then do :
    run placelib_write-attr  (input {&place-SI}
        ,input buf_place.obj-code
        ,input buf_place.obj-type
        ,input buf_place.pl-code
        ,input string(buf_place-imp.main-mi-code)
        ,output v-ok      )
    no-error.
  end .
  
  if buf_place-imp.position <> ?
  then do :
    run placelib_write-attr  (input {&place-local}
        ,input buf_place.obj-code
        ,input buf_place.obj-type
        ,input buf_place.pl-code
        ,input string(buf_place-imp.position)
        ,output v-ok      )
    no-error.
  end .
  
  if buf_place-imp.tank-tk <> ?
  then do :
    run placelib_write-attr  (input {&place-temp-coef}
        ,input buf_place.obj-code
        ,input buf_place.obj-type
        ,input buf_place.pl-code
        ,input string(buf_place-imp.tank-tk)
        ,output v-ok      )
    no-error.
  end .
  
  if buf_place-imp.pontoon <> ?
  then do :
    run placelib_write-attr  (input {&place-ponton}
        ,input buf_place.obj-code
        ,input buf_place.obj-type
        ,input buf_place.pl-code
        ,input (if buf_place-imp.pontoon = 1 then string(yes) else string(no))
        ,output v-ok      )
    no-error.
  end .
  
  if buf_place-imp.wght-pntn <> ?
  then do :
    run placelib_write-attr  (input {&place-ponton-mass}
        ,input buf_place.obj-code
        ,input buf_place.obj-type
        ,input buf_place.pl-code
        ,input string(buf_place-imp.wght-pntn)
        ,output v-ok      )
    no-error.
  end .
  
  if buf_place-imp.srfcng-pntn <> ?
  then do :
    run placelib_write-attr  (input {&place-ponton-height}
        ,input buf_place.obj-code
        ,input buf_place.obj-type
        ,input buf_place.pl-code
        ,input string(buf_place-imp.srfcng-pntn)
        ,output v-ok      )
    no-error.
  end .
  
  find first buf_pl-level-imp no-lock where buf_pl-level-imp.obj-type = buf_place-imp.obj-type
                                        and buf_pl-level-imp.obj-code = buf_place-imp.obj-code
                                        and buf_pl-level-imp.pl-code  = buf_place-imp.pl-code
                                        and buf_pl-level-imp.table-version = buf_place-imp.table-version
                                        no-error .
  if available buf_pl-level-imp
  then do :
    for each buf_pl-level exclusive-lock where buf_pl-level.obj-type = buf_place.obj-type
                                           and buf_pl-level.obj-code = buf_place.obj-code
                                           and buf_pl-level.pl-code  = buf_place.pl-code
    :
      for each buf_pl-level-attr exclusive-lock where buf_pl-level-attr.obj-type  = buf_place.obj-type
                                                  and buf_pl-level-attr.obj-code  = buf_place.obj-code
                                                  and buf_pl-level-attr.pl-code   = buf_place.pl-code
                                                  and buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
      :
        delete buf_pl-level-attr.
      end.
      delete buf_pl-level .
    end .
    for each buf_pl-level-imp no-lock where buf_pl-level-imp.obj-type = buf_place-imp.obj-type
                                        and buf_pl-level-imp.obj-code = buf_place-imp.obj-code
                                        and buf_pl-level-imp.pl-code  = buf_place-imp.pl-code
                                        and buf_pl-level-imp.table-version = buf_place-imp.table-version
    :
      create buf_pl-level .
      buffer-copy buf_pl-level-imp to buf_pl-level .
      
      if buf_pl-level-imp.tarir-delta <> ?
      then do :
        find first buf_pl-level-attr exclusive-lock where buf_pl-level-attr.obj-type  = buf_place-imp.obj-type
                                                      and buf_pl-level-attr.obj-code  = buf_place-imp.obj-code
                                                      and buf_pl-level-attr.pl-code   = buf_place-imp.pl-code
                                                      and buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
                                                      and buf_pl-level-attr.attr-code = "tarir-delta"
                                                      no-error .
        if not available buf_pl-level-attr
        then do :
          create buf_pl-level-attr .
          assign
            buf_pl-level-attr.obj-type  = buf_place-imp.obj-type
            buf_pl-level-attr.obj-code  = buf_place-imp.obj-code
            buf_pl-level-attr.pl-code   = buf_place-imp.pl-code
            buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
            buf_pl-level-attr.attr-code = "tarir-delta"
          .
        end.
        assign buf_pl-level-attr.attr-value = string(buf_pl-level-imp.tarir-delta).
      end .
      if buf_pl-level-imp.deltaV > 0
      then do :
        find first buf_pl-level-attr exclusive-lock where buf_pl-level-attr.obj-type  = buf_place-imp.obj-type
                                                      and buf_pl-level-attr.obj-code  = buf_place-imp.obj-code
                                                      and buf_pl-level-attr.pl-code   = buf_place-imp.pl-code
                                                      and buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
                                                      and buf_pl-level-attr.attr-code = "deltaV"
                                                      no-error .
        if not available buf_pl-level-attr
        then do :
          create buf_pl-level-attr .
          assign
            buf_pl-level-attr.obj-type  = buf_place-imp.obj-type
            buf_pl-level-attr.obj-code  = buf_place-imp.obj-code
            buf_pl-level-attr.pl-code   = buf_place-imp.pl-code
            buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
            buf_pl-level-attr.attr-code = "deltaV"
          .
        end.
        assign buf_pl-level-attr.attr-value = string(buf_pl-level-imp.deltaV).
      end .
    end .
  end .
  
  find first buf_pl-level-mm-imp no-lock where buf_pl-level-mm-imp.obj-type = buf_place-imp.obj-type
                                           and buf_pl-level-mm-imp.obj-code = buf_place-imp.obj-code
                                           and buf_pl-level-mm-imp.pl-code  = buf_place-imp.pl-code
                                           and buf_pl-level-mm-imp.table-version = buf_place-imp.table-version
                                           no-error .
  if available buf_pl-level-mm-imp
  then do :
    for each buf_pl-level-mm exclusive-lock where buf_pl-level-mm.obj-type = buf_place.obj-type
                                              and buf_pl-level-mm.obj-code = buf_place.obj-code
                                              and buf_pl-level-mm.pl-code  = buf_place.pl-code
    :
      delete buf_pl-level-mm .
    end .
    for each buf_pl-level-mm-imp no-lock where buf_pl-level-mm-imp.obj-type = buf_place-imp.obj-type
                                           and buf_pl-level-mm-imp.obj-code = buf_place-imp.obj-code
                                           and buf_pl-level-mm-imp.pl-code  = buf_place-imp.pl-code
                                           and buf_pl-level-mm-imp.table-version = buf_place-imp.table-version
    :
      create buf_pl-level-mm .
      buffer-copy buf_pl-level-mm-imp to buf_pl-level-mm .
    end .
  end .
  
  run placelib_write-attr  (input {&current-table-version}
      ,input buf_place.obj-code
      ,input buf_place.obj-type
      ,input buf_place.pl-code
      ,input string(buf_place-imp.table-version)
      ,output v-ok      )
  no-error.
  
  run placelib_write-attr  (input {&message-table-version}
      ,input buf_place.obj-code
      ,input buf_place.obj-type
      ,input buf_place.pl-code
      ,input "applied"
      ,output v-ok      )
  no-error.
  
  run cur-time in this-procedure (
        output v-today
      , output v-time
  ).
  
  find current buf_place-imp exclusive-lock .
  assign
    buf_place-imp.status_ = 1
    buf_place-imp.corr-date = v-today
    buf_place-imp.corr-time = v-time
  .
  validate buf_place-imp .
  
  run str/prep1C-status-cal-tbl.p (input buf_place-imp.table-version,
                                   input buf_place-imp.pl-code,
                                   input buf_place-imp.corr-date,
                                   input buf_place-imp.corr-time,
                                   input buf_place-imp.status_)
                                   no-error .
  
end .