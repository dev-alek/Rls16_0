define temp-table tt-shift no-undo
  field shift-date like ub.shift-obj.shift-date
  field shift-num  like ub.shift-obj.shift-num
  field shift-name like ub.shift-obj.shift-name
.
define temp-table tt-shift-1 no-undo
  field shift-date like ub.shift-obj.shift-date
  field shift-num  like ub.shift-obj.shift-num
  field shift-name like ub.shift-obj.shift-name
.
define temp-table tt-shift-2 no-undo
  field shift-date like ub.shift-obj.shift-date
  field shift-num  like ub.shift-obj.shift-num
  field shift-name like ub.shift-obj.shift-name
.
define temp-table tt-pl-gds no-undo
  field pl-code like ub.place.pl-code
  field loc1 like ub.place.loc1
  field gds-code like ub.goods.gds-code
  field gds-name like ub.goods.gds-name
.
define temp-table tt-place no-undo
  field pl-code like ub.place.pl-code
.
define input parameter parparentproc as handle no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-shift-periods.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-shift-periods.p $":U .
define variable vss-description as character no-undo init "Отчет Контроль плотности НП".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gds-attr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure placelib_write-attr:
define input  parameter p-code     like ub.place-attr.attr-code .
define input  parameter p-obj-code like ub.place-attr.obj-code .
define input  parameter p-obj-type like ub.place-attr.obj-type .
define input  parameter p-pl-code  like ub.place-attr.pl-code .
define input  parameter p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if not available buf_place-attr then do :
        create buf_place-attr.
        assign
          buf_place-attr.attr-code   = p-code
          buf_place-attr.attr-value  = p-value
          buf_place-attr.obj-code    = p-obj-code
          buf_place-attr.obj-type    = p-obj-type
          buf_place-attr.pl-code     = p-pl-code
        .
        p-ok = true.
     end.
     else do:
        buf_place-attr.attr-value  = p-value .
        p-ok = true.
     end.
  end.
end.
procedure placelib_get-attr:
define input  parameter  p-code     like ub.place-attr.attr-code .
define input  parameter  p-obj-code like ub.place-attr.obj-code .
define input  parameter  p-obj-type like ub.place-attr.obj-type .
define input  parameter  p-pl-code  like ub.place-attr.pl-code .
define output parameter  p-value    like ub.place-attr.attr-value .
define output parameter  p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr no-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
       p-value = buf_place-attr.attr-value.
       p-ok = true.
     end.
     else do :
       p-ok = false.
     end.
  end.
end.
procedure placelib_del-attr:
define input parameter  p-code     like ub.place-attr.attr-code .
define input parameter  p-obj-code like ub.place-attr.obj-code .
define input parameter  p-obj-type like ub.place-attr.obj-type .
define input parameter  p-pl-code  like ub.place-attr.pl-code .
define input parameter  p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
        delete buf_place-attr.
        p-ok = true.
     end.
  end.
end.
define variable num-rvs as integer no-undo init 0 .
define variable choosed-shift-recid as recid no-undo init ? .
define variable shift-recid-list as character no-undo .
define variable gds-recid-list as character no-undo .
define variable pl-recid-list as character no-undo .
define variable gds-recid-list-full as character no-undo .
define variable pl-recid-list-full as character no-undo .
define buffer buf_shift-obj for ub.shift-obj .
define buffer prev_shift-obj for ub.shift-obj .
define buffer buf_place for ub.place .
define buffer buf_pl-gds for ub.pl-gds .
define buffer buf_goods for ub.goods .
function shift-name returns character
  ( input p-shift-num like ub.shift-obj.shift-num, input p-shift-name  like ub.shift-obj.shift-name) forward.
DEFINE BUTTON b-goods
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-goods"
     SIZE 3 BY .86.
DEFINE BUTTON b-place
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-place"
     SIZE 3 BY .86.
DEFINE BUTTON b-shift-1
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-shift-1"
     SIZE 3 BY .86.
DEFINE BUTTON b-shift-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-shift-2"
     SIZE 3 BY .86.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK
     LABEL "Выполнить"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE VARIABLE rs-goods AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 15 BY 2.14 NO-UNDO.
DEFINE VARIABLE rs-obj AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Текущий", 1
     SIZE 15 BY .95 NO-UNDO.
DEFINE VARIABLE rs-place AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 15 BY 2.14 NO-UNDO.
DEFINE VARIABLE rs-shift AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "По сменам", 1,
"Выборочно", 2
     SIZE 15 BY 2.14 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 28 BY 3.33.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 28 BY 1.71.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 28 BY 3.33.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 28 BY 3.33.
DEFINE QUERY br-pl-gds FOR
      tt-pl-gds SCROLLING.
DEFINE QUERY br-shift FOR
      tt-shift SCROLLING.
DEFINE BROWSE br-pl-gds
  QUERY br-pl-gds DISPLAY
      tt-pl-gds.loc1 format "X(2)" column-label "Резервуар"
    tt-pl-gds.gds-name format "X(30)" column-label "НП"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 26.4 BY 7.38 ROW-HEIGHT-CHARS .57 FIT-LAST-COLUMN.
DEFINE BROWSE br-shift
  QUERY br-shift DISPLAY
      tt-shift.shift-date format "99.99.9999" column-label "Дата"
      shift-name (tt-shift.shift-num, tt-shift.shift-name) format "X(6)" column-label "Номер"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 26.4 BY 5.19 ROW-HEIGHT-CHARS .57 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.24 COL 2
     Btn_Cancel AT ROW 1.24 COL 17
     br-shift AT ROW 2.95 COL 33 WIDGET-ID 300
     rs-shift AT ROW 3.62 COL 5.8 NO-LABEL WIDGET-ID 4
     b-shift-1 AT ROW 3.67 COL 21.6 WIDGET-ID 32
     b-shift-2 AT ROW 4.71 COL 21.6 WIDGET-ID 34
     rs-obj AT ROW 7.43 COL 5.6 NO-LABEL WIDGET-ID 12
     br-pl-gds AT ROW 9.1 COL 33 WIDGET-ID 200
     rs-goods AT ROW 9.86 COL 5.4 NO-LABEL WIDGET-ID 20
     b-goods AT ROW 11 COL 21.2 WIDGET-ID 36
     rs-place AT ROW 13.86 COL 5.4 NO-LABEL WIDGET-ID 26
     b-place AT ROW 15.05 COL 21.2 WIDGET-ID 38
     " Выбор периода" VIEW-AS TEXT
          SIZE 16.4 BY .62 AT ROW 2.57 COL 8.6 WIDGET-ID 2
          FGCOLOR 12
     " Выбор резервуаров НП" VIEW-AS TEXT
          SIZE 22.6 BY .62 AT ROW 12.86 COL 5 WIDGET-ID 30
          FGCOLOR 12
     " Выбор объекта" VIEW-AS TEXT
          SIZE 16.4 BY .62 AT ROW 6.52 COL 7.6 WIDGET-ID 10
          FGCOLOR 12
     " Выбор топливных товаров" VIEW-AS TEXT
          SIZE 25 BY .62 AT ROW 8.86 COL 4.4 WIDGET-ID 18
          FGCOLOR 12
     RECT-1 AT ROW 2.91 COL 3 WIDGET-ID 8
     RECT-2 AT ROW 6.91 COL 3 WIDGET-ID 14
     RECT-3 AT ROW 9.19 COL 3 WIDGET-ID 16
     RECT-4 AT ROW 13.19 COL 3 WIDGET-ID 24
     SPACE(30.39) SKIP(0.47)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Отчет Контроль плотности НП"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-goods IN FRAME Dialog-Frame
DO:
  assign rs-goods = 2 .
  display rs-goods with frame Dialog-Frame .
  run select-gds .
  OPEN QUERY br-pl-gds FOR EACH tt-pl-gds by tt-pl-gds.loc1 .    OPEN QUERY br-shift FOR EACH tt-shift by tt-shift.shift-date desc by tt-shift.shift-num desc .
END.
ON CHOOSE OF b-place IN FRAME Dialog-Frame
DO:
  define variable ii as integer no-undo .
  define variable v-value as character no-undo .
  define variable v-type as character no-undo .
  define variable v-ok as logical no-undo .
  define variable tmp-pl-list as character no-undo .
  assign rs-place = 2 .
  display rs-place with frame Dialog-Frame .
  assign tmp-pl-list = pl-recid-list-full .
  empty temp-table tt-place .
  run ref/pl-list.w (
     input parparentproc
    ,input "b-sel,b-mark"
    ,input p-obj-type
    ,input p-obj-code
    ,input 'объект':U + chr(4) + "np-list"
    ,input-output tmp-pl-list).
  if tmp-pl-list = "cancel"
  then do :
    return no-apply .
  end .
  assign
    pl-recid-list = tmp-pl-list
    pl-recid-list-full = pl-recid-list
  .
  do ii = 1 to num-entries(pl-recid-list) :
    find first buf_place no-lock where recid(buf_place) = integer(entry(ii, pl-recid-list)) no-error .
    if available buf_place
    then do :
      create tt-place .
      assign tt-place.pl-code = buf_place.pl-code .
    end .
  end .
  empty temp-table tt-pl-gds .
  do ii = 1 to num-entries(gds-recid-list) :
    find first buf_goods no-lock where recid(buf_goods) = integer(entry(ii, gds-recid-list)) no-error .
    if available buf_goods
    then do :
      for each buf_pl-gds no-lock where buf_pl-gds.gds-code = buf_goods.gds-code
                                    and buf_pl-gds.obj-type = p-obj-type
                                    and buf_pl-gds.obj-code = p-obj-code,
        first buf_place where buf_place.pl-code = buf_pl-gds.pl-code
      :
                if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
          (input  buf_pl-gds.gds-code
          ,input  'fuel-type':U
          ,output v-value
          ,output v-type) no-error.
        if v-value = "lgas"
        or v-value = "metan"
        or v-value = "propan"
        then next .
        run placelib_get-attr  ( input "place-com-tanks"
                                ,input buf_place.obj-code
                                ,input buf_place.obj-type
                                ,input buf_place.pl-code
                                ,output v-value
                                ,output v-ok      ) no-error.
        if v-ok
        and v-value > ""
        then do :
          run placelib_get-attr  ( input "place-is-main"
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
        create tt-pl-gds .
        assign
          tt-pl-gds.pl-code  = buf_place.pl-code
          tt-pl-gds.loc1     = buf_place.loc1
          tt-pl-gds.gds-code = buf_goods.gds-code
          tt-pl-gds.gds-name = buf_goods.gds-name
        .
      end .
    end .
  end .
  for each tt-pl-gds :
    find first tt-place where tt-place.pl-code = tt-pl-gds.pl-code no-error .
    if not available tt-place
    then delete tt-pl-gds .
  end .
  run find-old-pl-gds .
  OPEN QUERY br-pl-gds FOR EACH tt-pl-gds by tt-pl-gds.loc1 .    OPEN QUERY br-shift FOR EACH tt-shift by tt-shift.shift-date desc by tt-shift.shift-num desc .
END.
ON CHOOSE OF b-shift-1 IN FRAME Dialog-Frame
DO:
  assign rs-shift = 1 .
  display rs-shift with frame Dialog-Frame .
  run str/sht-all.w
                  ( input parparentproc
                   ,input p-obj-type
                   ,input p-obj-code
                   ,input "b-sel"
                   ,input "obj":U
                   ,input p-obj-type
                   ,input p-obj-code
                   ,input ""
                   ,input-output shift-recid-list ).
  if error-status:error
  then do :
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при выборе смены"  skip
      error-status :get-message( 1 ) skip
      return-value skip
      view-as alert-box error
    .
    return no-apply.
  end.
  if shift-recid-list =  "":U
  then do :
    return no-apply .
  end.
  empty temp-table tt-shift-1 .
  assign choosed-shift-recid = integer (shift-recid-list) .
  find first buf_shift-obj where recid (buf_shift-obj) = choosed-shift-recid no-lock.
  if buf_shift-obj.status_ <> 'зкр':U
  then do :
    message "Выберите закрытую смену!" view-as alert-box .
    return no-apply .
  end .
  create tt-shift-1 .
  assign
    tt-shift-1.shift-date = buf_shift-obj.shift-date
    tt-shift-1.shift-num  = buf_shift-obj.shift-num
    tt-shift-1.shift-name = buf_shift-obj.shift-name
    num-rvs = 1
  .
  for each prev_shift-obj no-lock where prev_shift-obj.obj-type = p-obj-type
                                    and prev_shift-obj.obj-code = p-obj-code
                                    and prev_shift-obj.status_  = 'зкр':U
                                    and ( prev_shift-obj.shift-date < buf_shift-obj.shift-date
                                      or prev_shift-obj.shift-date = buf_shift-obj.shift-date
                                        and prev_shift-obj.shift-num  < buf_shift-obj.shift-num
                                    )
                                    by prev_shift-obj.fact-order desc
  :
    create tt-shift-1 .
    assign
      tt-shift-1.shift-date = prev_shift-obj.shift-date
      tt-shift-1.shift-num  = prev_shift-obj.shift-num
      tt-shift-1.shift-name = prev_shift-obj.shift-name
      num-rvs = num-rvs + 1
    .
    if num-rvs = 7
    then leave .
  end .
  empty temp-table tt-shift .
  for each tt-shift-1 :
    create tt-shift .
    buffer-copy tt-shift-1 to tt-shift .
  end .
  run find-old-pl-gds .
  OPEN QUERY br-pl-gds FOR EACH tt-pl-gds by tt-pl-gds.loc1 .    OPEN QUERY br-shift FOR EACH tt-shift by tt-shift.shift-date desc by tt-shift.shift-num desc .
END.
ON CHOOSE OF b-shift-2 IN FRAME Dialog-Frame
DO:
  define variable ii as integer no-undo .
  assign rs-shift = 2 .
  display rs-shift with frame Dialog-Frame .
  run str/sht-all.w
                  ( input parparentproc
                   ,input p-obj-type
                   ,input p-obj-code
                   ,input "b-sel,b-mark"
                   ,input "obj":U
                   ,input p-obj-type
                   ,input p-obj-code
                   ,input ""
                   ,input-output shift-recid-list ).
  if error-status:error
  then do :
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при выборе смены"  skip
      error-status :get-message( 1 ) skip
      return-value skip
      view-as alert-box error
    .
    return no-apply.
  end.
  if shift-recid-list =  "":U
  then do :
    return no-apply .
  end.
  empty temp-table tt-shift-2 .
  do ii = 1 to num-entries(shift-recid-list) :
    find first buf_shift-obj no-lock where recid(buf_shift-obj) = integer(entry(ii, shift-recid-list)) no-error .
    if available buf_shift-obj
    and buf_shift-obj.status_ = 'зкр':U
    then do :
      create tt-shift-2 .
      assign
        tt-shift-2.shift-date = buf_shift-obj.shift-date
        tt-shift-2.shift-num  = buf_shift-obj.shift-num
        tt-shift-2.shift-name = buf_shift-obj.shift-name
      .
    end .
    if available buf_shift-obj
    and not buf_shift-obj.status_ = 'зкр':U
    then do :
      message "Выберите закрытую смену!" view-as alert-box .
    end .
  end .
  empty temp-table tt-shift .
  for each tt-shift-2 :
    create tt-shift .
    buffer-copy tt-shift-2 to tt-shift .
  end .
  run find-old-pl-gds .
  OPEN QUERY br-pl-gds FOR EACH tt-pl-gds by tt-pl-gds.loc1 .    OPEN QUERY br-shift FOR EACH tt-shift by tt-shift.shift-date desc by tt-shift.shift-num desc .
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
  empty temp-table tt-shift .
  case rs-shift :
    when 1
    then do :
      find first tt-shift-1 no-error .
      if not available tt-shift-1
      then do :
        message "Не выбрана ни одна смена!" view-as alert-box .
        return no-apply .
      end .
      for each tt-shift-1 :
        create tt-shift .
        buffer-copy tt-shift-1 to tt-shift .
      end .
    end .
    when 2
    then do :
      find first tt-shift-2 no-error .
      if not available tt-shift-2
      then do :
        message "Не выбрана ни одна смена!" view-as alert-box .
        return no-apply .
      end .
      for each tt-shift-2 :
        create tt-shift .
        buffer-copy tt-shift-2 to tt-shift .
      end .
    end .
  end case .
  find first tt-pl-gds no-error .
  if not available tt-pl-gds
  then do :
    message "Список товаров/резервуаров пуст!" view-as alert-box .
    return no-apply .
  end .
  run rep/r-shift-periods.p (input parparentproc,
                             input table tt-shift,
                             input table tt-pl-gds)
                             .
END.
ON VALUE-CHANGED OF rs-goods IN FRAME Dialog-Frame
DO:
  define variable ii as integer no-undo .
  define variable v-value as character no-undo .
  define variable v-type as character no-undo .
  define variable v-ok as logical no-undo .
  assign rs-goods .
  assign rs-place = 1 .
  display rs-place with frame Dialog-Frame .
  if rs-goods = 1
  then do :
    run init-pl-gds .
  end .
  if rs-goods = 2
  then do :
    empty temp-table tt-pl-gds .
    do ii = 1 to num-entries(gds-recid-list):
      find first buf_goods where recid(buf_goods) = integer(entry(ii, gds-recid-list)) no-lock no-error.
      if available buf_goods
      then do:
        for each buf_pl-gds no-lock where buf_pl-gds.gds-code = buf_goods.gds-code
                                      and buf_pl-gds.obj-type = p-obj-type
                                      and buf_pl-gds.obj-code = p-obj-code,
          first buf_place where buf_place.pl-code = buf_pl-gds.pl-code
        :
                    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
            (input  buf_pl-gds.gds-code
            ,input  'fuel-type':U
            ,output v-value
            ,output v-type) no-error.
          if v-value = "lgas"
          or v-value = "metan"
          or v-value = "propan"
          then next .
          run placelib_get-attr  ( input "place-com-tanks"
                                  ,input buf_place.obj-code
                                  ,input buf_place.obj-type
                                  ,input buf_place.pl-code
                                  ,output v-value
                                  ,output v-ok      ) no-error.
          if v-ok
          and v-value > ""
          then do :
            run placelib_get-attr  ( input "place-is-main"
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
          create tt-pl-gds .
          assign
            tt-pl-gds.pl-code  = buf_place.pl-code
            tt-pl-gds.loc1     = buf_place.loc1
            tt-pl-gds.gds-code = buf_goods.gds-code
            tt-pl-gds.gds-name = buf_goods.gds-name
          .
        end .
      end.
    end.
    run find-old-pl-gds .
  end .
  OPEN QUERY br-pl-gds FOR EACH tt-pl-gds by tt-pl-gds.loc1 .    OPEN QUERY br-shift FOR EACH tt-shift by tt-shift.shift-date desc by tt-shift.shift-num desc .
END.
ON VALUE-CHANGED OF rs-place IN FRAME Dialog-Frame
DO:
  define variable ii as integer no-undo .
  define variable v-value as character no-undo .
  define variable v-type as character no-undo .
  define variable v-ok as logical no-undo .
  assign rs-place .
  if rs-place = 1
  then do :
    empty temp-table tt-pl-gds .
    do ii = 1 to num-entries(gds-recid-list) :
      find first buf_goods no-lock where recid(buf_goods) = integer(entry(ii, gds-recid-list)) no-error .
      if available buf_goods
      then do :
        for each buf_pl-gds no-lock where buf_pl-gds.gds-code = buf_goods.gds-code
                                      and buf_pl-gds.obj-type = p-obj-type
                                      and buf_pl-gds.obj-code = p-obj-code,
          first buf_place where buf_place.pl-code = buf_pl-gds.pl-code
        :
                    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
            (input  buf_pl-gds.gds-code
            ,input  'fuel-type':U
            ,output v-value
            ,output v-type) no-error.
          if v-value = "lgas"
          or v-value = "metan"
          or v-value = "propan"
          then next .
          run placelib_get-attr  ( input "place-com-tanks"
                                  ,input buf_place.obj-code
                                  ,input buf_place.obj-type
                                  ,input buf_place.pl-code
                                  ,output v-value
                                  ,output v-ok      ) no-error.
          if v-ok
          and v-value > ""
          then do :
            run placelib_get-attr  ( input "place-is-main"
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
          create tt-pl-gds .
          assign
            tt-pl-gds.pl-code  = buf_place.pl-code
            tt-pl-gds.loc1     = buf_place.loc1
            tt-pl-gds.gds-code = buf_goods.gds-code
            tt-pl-gds.gds-name = buf_goods.gds-name
          .
        end .
      end .
    end .
    assign
      pl-recid-list-full = pl-recid-list
      pl-recid-list = ""
    .
    for each tt-pl-gds no-lock break by tt-pl-gds.pl-code :
      if first-of(tt-pl-gds.pl-code)
      then do :
        for first place where place.pl-code = tt-pl-gds.pl-code :
          assign pl-recid-list = pl-recid-list + string(recid(place)) + "," .
        end .
      end .
    end .
    assign pl-recid-list = trim(pl-recid-list, ",") .
  end .
  if rs-place = 2
  then do :
    empty temp-table tt-place .
    do ii = 1 to num-entries(pl-recid-list) :
      find first buf_place no-lock where recid(buf_place) = integer(entry(ii, pl-recid-list)) no-error .
      if available buf_place
      then do :
        create tt-place .
        assign tt-place.pl-code = buf_place.pl-code .
      end .
    end .
    for each tt-pl-gds :
      find first tt-place where tt-place.pl-code = tt-pl-gds.pl-code no-error .
      if not available tt-place
      then delete tt-pl-gds .
    end .
  end .
  run find-old-pl-gds .
  OPEN QUERY br-pl-gds FOR EACH tt-pl-gds by tt-pl-gds.loc1 .    OPEN QUERY br-shift FOR EACH tt-shift by tt-shift.shift-date desc by tt-shift.shift-num desc .
END.
ON VALUE-CHANGED OF rs-shift IN FRAME Dialog-Frame
DO:
  assign rs-shift .
  if rs-shift = 1
  then do :
    empty temp-table tt-shift .
    for each tt-shift-1 :
      create tt-shift .
      buffer-copy tt-shift-1 to tt-shift .
    end .
  end .
  if rs-shift = 2
  then do :
    empty temp-table tt-shift .
    for each tt-shift-2 :
      create tt-shift .
      buffer-copy tt-shift-2 to tt-shift .
    end .
  end .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run init_ .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY rs-shift rs-obj rs-goods rs-place
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 RECT-2 RECT-3 RECT-4 Btn_OK Btn_Cancel br-shift rs-shift
         b-shift-1 b-shift-2 rs-obj br-pl-gds rs-goods b-goods rs-place b-place
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-pl-gds FOR EACH tt-pl-gds by tt-pl-gds.loc1 .    OPEN QUERY br-shift FOR EACH tt-shift by tt-shift.shift-date desc by tt-shift.shift-num desc .
END PROCEDURE.
PROCEDURE find-old-pl-gds :
  define variable ii as integer no-undo .
  define buffer buf_shift-period for ub.shift-period .
  define buffer buf_goods for ub.goods .
  define buffer buf_place for ub.place .
  for each tt-shift :
    for each buf_shift-period no-lock where buf_shift-period.obj-type = p-obj-type
                                        and buf_shift-period.obj-code = p-obj-code
                                        and buf_shift-period.shift-date = tt-shift.shift-date
                                        and buf_shift-period.shift-num  = tt-shift.shift-num
    :
      find first tt-pl-gds where tt-pl-gds.gds-code = buf_shift-period.gds-code
                             and tt-pl-gds.pl-code  = buf_shift-period.pl-code
                             no-error .
      if available tt-pl-gds then next .
      do ii = 1 to num-entries(gds-recid-list-full):
        find first buf_goods where recid(buf_goods) = integer(entry(ii, gds-recid-list-full)) no-lock no-error.
        if available buf_goods
        and buf_goods.gds-code = buf_shift-period.gds-code
        then do :
          create tt-pl-gds .
          assign
            tt-pl-gds.gds-code = buf_goods.gds-code
            tt-pl-gds.gds-name = buf_goods.gds-name
          .
          for first buf_place no-lock where buf_place.obj-type = p-obj-type
                                        and buf_place.obj-code = p-obj-code
                                        and buf_place.pl-code  = buf_shift-period.pl-code
          :
            assign
              tt-pl-gds.pl-code = buf_place.pl-code
              tt-pl-gds.loc1    = buf_place.loc1
            .
          end .
        end .
      end .
      find first tt-pl-gds where tt-pl-gds.gds-code = buf_shift-period.gds-code
                             and tt-pl-gds.pl-code  = buf_shift-period.pl-code
                             no-error .
      if available tt-pl-gds then next .
      do ii = 1 to num-entries(pl-recid-list-full):
        find first buf_place where recid(buf_place) = integer(entry(ii, pl-recid-list-full)) no-lock no-error.
        if available buf_place
        and buf_place.obj-type = buf_shift-period.obj-type
        and buf_place.obj-code = buf_shift-period.obj-code
        and buf_place.pl-code  = buf_shift-period.pl-code
        then do :
          create tt-pl-gds .
          assign
            tt-pl-gds.pl-code = buf_place.pl-code
            tt-pl-gds.loc1    = buf_place.loc1
          .
          for first buf_goods no-lock where buf_goods.gds-code  = buf_shift-period.gds-code
          :
            assign
              tt-pl-gds.gds-code = buf_goods.gds-code
              tt-pl-gds.gds-name = buf_goods.gds-name
            .
          end .
        end .
      end .
    end .
  end .
END PROCEDURE.
PROCEDURE init-pl-gds :
  define variable v-value as character no-undo .
  define variable v-type as character no-undo .
  define variable v-ok as logical no-undo .
  define buffer place for ub.place .
  define buffer goods for ub.goods .
  empty temp-table tt-pl-gds .
  assign
    pl-recid-list = ""
    gds-recid-list = ""
  .
  for each buf_place no-lock where buf_place.obj-type = p-obj-type
                               and buf_place.obj-code = p-obj-code
  :
    find first buf_pl-gds no-lock where buf_pl-gds.pl-code = buf_place.pl-code no-error .
    if not available buf_pl-gds
    then do :
      assign pl-recid-list-full = pl-recid-list-full + string(recid(buf_place)) + "," .
      next .
    end .
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  buf_pl-gds.gds-code
      ,input  'fuel-type':U
      ,output v-value
      ,output v-type) no-error.
    if v-value = "lgas"
    or v-value = "metan"
    or v-value = "propan"
    then next .
    run placelib_get-attr  ( input "place-com-tanks"
                            ,input buf_place.obj-code
                            ,input buf_place.obj-type
                            ,input buf_place.pl-code
                            ,output v-value
                            ,output v-ok      ) no-error.
    if v-ok
    and v-value > ""
    then do :
      run placelib_get-attr  ( input "place-is-main"
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
    assign pl-recid-list-full = pl-recid-list-full + string(recid(buf_place)) + "," .
    create tt-pl-gds .
    assign
      tt-pl-gds.pl-code  = buf_place.pl-code
      tt-pl-gds.loc1     = buf_place.loc1
      tt-pl-gds.gds-code = buf_pl-gds.gds-code
    .
    for first buf_goods no-lock where buf_goods.gds-code = buf_pl-gds.gds-code :
      assign tt-pl-gds.gds-name = buf_goods.gds-name .
    end .
  end .
  assign pl-recid-list-full = trim(pl-recid-list-full, ",") .
  for each tt-pl-gds no-lock break by tt-pl-gds.pl-code :
    if first-of(tt-pl-gds.pl-code)
    then do :
      for first place where place.pl-code = tt-pl-gds.pl-code :
        assign pl-recid-list = pl-recid-list + string(recid(place)) + "," .
      end .
    end .
  end .
  assign pl-recid-list = trim(pl-recid-list, ",") .
  for each tt-pl-gds no-lock break by tt-pl-gds.gds-code :
    if first-of(tt-pl-gds.gds-code)
    then do :
      for first goods where goods.gds-code = tt-pl-gds.gds-code :
        assign gds-recid-list = gds-recid-list + string(recid(goods)) + "," .
      end .
    end .
  end .
  assign
    gds-recid-list = trim(gds-recid-list, ",")
    gds-recid-list-full = gds-recid-list
  .
  run find-old-pl-gds .
END PROCEDURE.
PROCEDURE init_ :
  empty temp-table tt-shift-1 .
  empty temp-table tt-shift-2 .
  find last buf_shift-obj no-lock where buf_shift-obj.obj-type = p-obj-type
                                    and buf_shift-obj.obj-code = p-obj-code
                                    and buf_shift-obj.status_  = 'зкр':U
                                    use-index stts
                                    no-error.
  if not available buf_shift-obj
  then do :
    message "Нет закрытой смены на объекте!" view-as alert-box .
    apply "choose" to Btn_Cancel in frame Dialog-Frame .
  end .
  create tt-shift-1 .
  assign
    tt-shift-1.shift-date = buf_shift-obj.shift-date
    tt-shift-1.shift-num  = buf_shift-obj.shift-num
    tt-shift-1.shift-name = buf_shift-obj.shift-name
    choosed-shift-recid = recid(buf_shift-obj)
    num-rvs = 1
  .
  for each prev_shift-obj no-lock where prev_shift-obj.obj-type = p-obj-type
                                    and prev_shift-obj.obj-code = p-obj-code
                                    and prev_shift-obj.status_  = 'зкр':U
                                    and ( prev_shift-obj.shift-date < buf_shift-obj.shift-date
                                      or prev_shift-obj.shift-date = buf_shift-obj.shift-date
                                        and prev_shift-obj.shift-num  < buf_shift-obj.shift-num
                                    )
                                    by prev_shift-obj.fact-order desc
  :
    create tt-shift-1 .
    assign
      tt-shift-1.shift-date = prev_shift-obj.shift-date
      tt-shift-1.shift-num  = prev_shift-obj.shift-num
      tt-shift-1.shift-name = prev_shift-obj.shift-name
      num-rvs = num-rvs + 1
    .
    if num-rvs = 7
    then leave .
  end .
  for each tt-shift-1 :
    create tt-shift .
    buffer-copy tt-shift-1 to tt-shift .
  end .
  run init-pl-gds .
END PROCEDURE.
PROCEDURE select-gds :
  define buffer goods for goods.
  define buffer pl-gds for pl-gds.
  define buffer place for place.
  define variable vRecId        as recid     no-undo.
  define variable vAnswer       as logical   no-undo.
  define variable vI            as integer   no-undo.
  define variable v-value as character no-undo .
  define variable v-type as character no-undo .
  define variable v-ok as logical no-undo .
  run ref/gds-ref.p (
                     input parparentproc
                    ,input "b-mark,b-sel"
                    ,input 'все':U
                    ,input "only-np"
                    ,input ?
                    ,input ?
                    ,input ?
                    ,input ?
                    ,input ?
                    ,input p-obj-type
                    ,input p-obj-code
                    ,input ?
                    ,output gds-recid-list).
  if gds-recid-list = "" and can-find(first tt-pl-gds) then do:
    message "Не было выбрано ни одного товара. Очистить список ранее выбранных товаров?"
    view-as alert-box QUESTION buttons YES-NO update vAnswer.
    if not vAnswer then return .
  end.
  empty temp-table tt-pl-gds .
  do vI = 1 to num-entries(gds-recid-list):
    vRecId = integer(entry(vI, gds-recid-list)).
    find first goods where recid(goods) = vRecId no-lock no-error.
    if available goods
    then do:
      for each pl-gds no-lock where pl-gds.gds-code = goods.gds-code
                                and pl-gds.obj-type = p-obj-type
                                and pl-gds.obj-code = p-obj-code,
        first place where place.pl-code = pl-gds.pl-code
      :
                if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
          (input  pl-gds.gds-code
          ,input  'fuel-type':U
          ,output v-value
          ,output v-type) no-error.
        if v-value = "lgas"
        or v-value = "metan"
        or v-value = "propan"
        then next .
        run placelib_get-attr  ( input "place-com-tanks"
                                ,input place.obj-code
                                ,input place.obj-type
                                ,input place.pl-code
                                ,output v-value
                                ,output v-ok      ) no-error.
        if v-ok
        and v-value > ""
        then do :
          run placelib_get-attr  ( input "place-is-main"
                                  ,input place.obj-code
                                  ,input place.obj-type
                                  ,input place.pl-code
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
        create tt-pl-gds .
        assign
          tt-pl-gds.pl-code  = place.pl-code
          tt-pl-gds.loc1     = place.loc1
          tt-pl-gds.gds-code = goods.gds-code
          tt-pl-gds.gds-name = goods.gds-name
        .
      end .
    end.
  end.
  assign pl-recid-list = "" .
  for each tt-pl-gds no-lock break by tt-pl-gds.pl-code :
    if first-of(tt-pl-gds.pl-code)
    then do :
      for first place where place.pl-code = tt-pl-gds.pl-code :
        assign pl-recid-list = pl-recid-list + string(recid(place)) + "," .
      end .
    end .
  end .
  assign
    pl-recid-list = trim(pl-recid-list, ",")
    pl-recid-list-full = pl-recid-list
  .
  assign
    gds-recid-list-full = gds-recid-list
    gds-recid-list = ""
  .
  for each tt-pl-gds no-lock break by tt-pl-gds.gds-code :
    if first-of(tt-pl-gds.gds-code)
    then do :
      for first goods where goods.gds-code = tt-pl-gds.gds-code :
        assign gds-recid-list = gds-recid-list + string(recid(goods)) + "," .
      end .
    end .
  end .
  assign gds-recid-list = trim(gds-recid-list, ",") .
  run find-old-pl-gds .
END PROCEDURE.
function shift-name returns character
  ( input p-shift-num like ub.shift-obj.shift-num, input p-shift-name  like ub.shift-obj.shift-name ):
  define variable result as character no-undo.
  result = string(p-shift-num, ">9") + " (" + p-shift-name + ")" .
  return result.
end function.
