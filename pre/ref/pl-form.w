DEFINE BUFFER locked_place FOR place.
DEFINE TEMP-TABLE tt-place NO-UNDO LIKE place.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode        as character no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-pl-code like ub.clients.obj-code no-undo .
define input-output parameter p-rep-rec     as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Карточка складского места" .
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
function is-sug returns logical
        (input p-gds-code as integer):
define variable result as logical no-undo.
define variable c-value as character no-undo.
define variable c-type as character no-undo.
do on error undo, return error:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  'fuel-type':U
      ,output c-value
      ,output c-type) no-error.
end.
result = logical(c-value = 'lgas':U) no-error.
return result.
end function.
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
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
define variable v-tab-order       as CHARACTER no-undo .
define variable v-code            as character no-undo .
define variable v-value           as character no-undo .
define variable v-ok              as logical   no-undo .
define variable ii                as integer   no-undo .
define variable v-rvd-on          as logical   no-undo init no .
define variable v-rvd-off         as logical   no-undo init no .
define variable v-rvd-dnsty-on    as logical   no-undo .
define variable v-rvd-lvl-on      as logical   no-undo .
define variable v-rvd-temp-on     as logical   no-undo .
define variable v-rvd-is-meas-on  as logical   no-undo .
define variable v-rvd-reason-on   as character no-undo .
define variable v-ITSM-num-on     as character no-undo .
define variable v-oper-fio-on     as character no-undo .
define variable v-rvd-reason-off  as character no-undo .
define variable v-ITSM-num-off    as character no-undo .
define variable v-oper-fio-off    as character no-undo .
define variable v-main-mi-old     as integer   no-undo .
define variable v-dnst-mi-old     as integer   no-undo .
define variable v-tmp-mi-old      as integer   no-undo .
define variable v-lvl-mi-old      as integer   no-undo .
define variable is-main           as logical   no-undo .
define variable v-com-vessel-changed as logical no-undo init no .
define variable v-gate-valve-tanks-changed as logical no-undo init no .
define variable v-old-auto-gate-valve as logical no-undo .
define variable v-not-gas-place   as logical no-undo .
define variable v-sug-place       as logical no-undo .
define buffer com_place for ub.place .
define buffer com_place-attr for ub.place-attr .
define buffer osn_sr-izmerenia for sr-izmerenia .
define buffer dnst_sr-izmerenia for sr-izmerenia .
define buffer tmp_sr-izmerenia for sr-izmerenia .
define buffer lvl_sr-izmerenia for sr-izmerenia .
define buffer dop_sr-izmerenia for sr-izmerenia .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE BUTTON r-sr-izm
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-sr-izm"
     SIZE 3 BY .88.
DEFINE BUTTON b-mi-dnst
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-mi-dnst"
     SIZE 3 BY .88.
DEFINE BUTTON b-mi-tmp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-mi-tmp"
     SIZE 3 BY .88.
DEFINE BUTTON b-mi-lvl
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-mi-lvl"
     SIZE 3 BY .88.
DEFINE BUTTON b-com-tanks
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-mi-dnst"
     SIZE 3 BY .88.
DEFINE BUTTON b-gate-valve-tanks
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-mi-dnst"
     SIZE 3 BY .88.
DEFINE VARIABLE dead-balance AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0
     LABEL "Мертвый остаток(л)"
     VIEW-AS FILL-IN
     SIZE 11.63 BY 1 NO-UNDO.
DEFINE VARIABLE water-level AS integer FORMAT ">>>>>9":U INITIAL 0
     LABEL "Допустимый уровень воды(мм)"
     VIEW-AS FILL-IN
     SIZE 11.63 BY 1 NO-UNDO.
DEFINE VARIABLE dens-prov AS DECIMAL FORMAT "9.9999999999" INITIAL 0
     LABEL "Плотность при поверке резервуара(г/см3)"
     VIEW-AS FILL-IN
     SIZE 18 BY 1 NO-UNDO.
DEFINE VARIABLE error-mass AS DECIMAL FORMAT "9.99":U INITIAL 0.15
     LABEL "Погр.изм.массы в трубопр. (%)"
     VIEW-AS FILL-IN
     SIZE-PIXELS 93 BY 24 NO-UNDO.
DEFINE VARIABLE place-diameter AS DECIMAL FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "Диаметр резервуара(мм)"
     VIEW-AS FILL-IN
     SIZE 11.63 BY 1 NO-UNDO.
DEFINE VARIABLE place-ratio-error AS DECIMAL FORMAT "9.99":U INITIAL 0.25
     LABEL "Относительная погрешность составления калибровочной таблицы"
     VIEW-AS FILL-IN
     SIZE 18 BY 1 NO-UNDO.
DEFINE VARIABLE place-temp-coef AS DECIMAL FORMAT "9.9999999999":U INITIAL 0.0000125
     LABEL "Темп. коэф. линейного расширения материала стенки рез-ра(1/°С)"
     VIEW-AS FILL-IN
     SIZE 18 BY 1 NO-UNDO.
DEFINE VARIABLE place-dead-high AS DECIMAL FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "Высота мертвой полости(мм)"
     VIEW-AS FILL-IN
     SIZE 11.63 BY 1 NO-UNDO.
DEFINE VARIABLE place-si AS INTEGER FORMAT ">>>>>9":U INITIAL 0
     LABEL "Основное средство измерения"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE v-mi-dnst AS INTEGER FORMAT ">>>>>9":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE v-mi-tmp AS INTEGER FORMAT ">>>>>9":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE v-mi-lvl AS INTEGER FORMAT ">>>>>9":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE place-si-name AS character FORMAT "X(10)":U
     LABEL "Основное средство измерения"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE v-mi-lvl-name AS character FORMAT "X(10)":U
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE v-mi-dnst-name AS character FORMAT "X(10)":U
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE v-mi-tmp-name AS character FORMAT "X(10)":U
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE place-twice-code AS CHARACTER FORMAT "x(8)"
     LABEL "Коды связанных резервуаров"
     VIEW-AS FILL-IN
     SIZE 18 BY 1 NO-UNDO.
DEFINE VARIABLE place-passp-num AS CHARACTER FORMAT "x(256)"
     LABEL "Номер резервуара по паспорту"
     VIEW-AS FILL-IN
     SIZE 45 BY 1 NO-UNDO.
DEFINE VARIABLE place-passp-type AS CHARACTER FORMAT "x(256)"
     LABEL "Тип резервуара по паспорту"
     VIEW-AS FILL-IN
     SIZE 45 BY 1 NO-UNDO.
DEFINE VARIABLE place-locat AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Наземный", 1,
"Подземный", 2
     SIZE 25.5 BY .92 NO-UNDO.
DEFINE VARIABLE place-type AS INTEGER initial 2
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Вертикальный", 1,
"Горизонтальный", 2
     SIZE 34.5 BY .92 NO-UNDO.
DEFINE VARIABLE rvd-dnstv AS LOGICAL INITIAL no
     LABEL "Плотность"
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY 1 NO-UNDO.
DEFINE VARIABLE rvd-lvl AS LOGICAL INITIAL no
     LABEL "Уровень"
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY 1 NO-UNDO.
DEFINE VARIABLE rvd-tmp AS LOGICAL INITIAL no
     LABEL "Температура"
     VIEW-AS TOGGLE-BOX
     SIZE 13.5 BY 1 NO-UNDO.
DEFINE VARIABLE t-asi-srtif AS LOGICAL INITIAL no
     LABEL "АСИ сертифицировано"
     VIEW-AS TOGGLE-BOX
     SIZE 22.13 BY 1 NO-UNDO.
DEFINE VARIABLE t-place-virtual AS LOGICAL INITIAL no
     LABEL "Виртуальный резервуар"
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY 1 NO-UNDO.
DEFINE VARIABLE t-ponton AS LOGICAL INITIAL no
     LABEL "Понтон:"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE ponton-mass AS DECIMAL FORMAT ">>>>>>9.999":U INITIAL ? decimals 3
     LABEL "Масса понтона(кг)"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE ponton-height AS DECIMAL FORMAT ">>>>>>9.9":U INITIAL ? decimals 1
     LABEL "Высота всплытия(мм)"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE t-com-vessel AS LOGICAL INITIAL no
     LABEL "Сообщающиеся резервуары:"
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY 1 NO-UNDO.
DEFINE VARIABLE t-gate-valve AS LOGICAL INITIAL no
     LABEL "Задвижка:"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE com-tanks AS CHARACTER FORMAT "x(15)"
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE gate-valve-tanks AS CHARACTER FORMAT "x(15)"
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE v-is-main AS character FORMAT "x(11)"
     LABEL ""
     VIEW-AS fill-in
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE t-auto-gate-valve AS LOGICAL INITIAL no
     LABEL "Автоматическая задвижка"
     VIEW-AS TOGGLE-BOX
     SIZE 25 BY 1 NO-UNDO.
DEFINE FRAME d-pl-form
     b-exit AT ROW 1 COL 2
     b-quit AT ROW 1 COL 12
     B-hist AT ROW 1 COL 66.63
     b-help AT ROW 1 COL 76.63
     tt-place.loc1 AT ROW 3 COL 10 COLON-ALIGNED
          LABEL "Коорд&1"
          VIEW-AS FILL-IN
          SIZE 11.63 BY 1
     tt-place.loc2 AT ROW 3 COL 30.63 COLON-ALIGNED
          LABEL "Коорд&2"
          VIEW-AS FILL-IN
          SIZE 11.63 BY 1
     tt-place.loc3 AT ROW 3 COL 52.5 COLON-ALIGNED
          LABEL "Коорд&3"
          VIEW-AS FILL-IN
          SIZE 11.63 BY 1
     tt-place.loc4 AT ROW 3 COL 88.01 RIGHT-ALIGNED
          LABEL "Коорд&4"
          VIEW-AS FILL-IN
          SIZE 11.63 BY 1
     tt-place.pl-name AT ROW 4.25 COL 10 COLON-ALIGNED
          LABEL "Название"
          VIEW-AS FILL-IN
          SIZE 77 BY 1
     t-place-virtual AT ROW 5.46 COL 35.5 WIDGET-ID 28
     t-asi-srtif AT ROW 5.46 COL 66.88 WIDGET-ID 22
     tt-place.is-meas AT ROW 5.5 COL 10
          LABEL "Измеряется приборами"
          VIEW-AS TOGGLE-BOX
          SIZE 23.63 BY 1
     tt-place.pl-code AT ROW 6.75 COL 5.63 COLON-ALIGNED format "99999999999"
          LABEL "Код"
          VIEW-AS FILL-IN
          SIZE 12.93 BY 1
     rvd-dnstv AT ROW 6.75 COL 35 WIDGET-ID 40
     rvd-lvl AT ROW 6.75 COL 52 WIDGET-ID 44
     rvd-tmp AT ROW 6.75 COL 68 WIDGET-ID 46
     "Доп. средства измерения:" VIEW-AS TEXT
          SIZE 24 BY .75 AT ROW 7.7 COL 7 WIDGET-ID 50
     v-mi-dnst AT ROW 7.7 COL 33 COLON-ALIGNED WIDGET-ID 52 no-label
     v-mi-dnst-name AT ROW 7.7 COL 33 COLON-ALIGNED WIDGET-ID 52 no-label
     b-mi-dnst AT ROW 7.7 COL 48 RIGHT-ALIGNED
     v-mi-lvl AT ROW 7.7 COL 50 COLON-ALIGNED WIDGET-ID 52 no-label
     v-mi-lvl-name AT ROW 7.7 COL 50 COLON-ALIGNED WIDGET-ID 52 no-label
     b-mi-lvl AT ROW 7.7 COL 65 RIGHT-ALIGNED
     v-mi-tmp AT ROW 7.7 COL 66 COLON-ALIGNED WIDGET-ID 52 no-label
     v-mi-tmp-name AT ROW 7.7 COL 66 COLON-ALIGNED WIDGET-ID 52 no-label
     b-mi-tmp AT ROW 7.7 COL 81 RIGHT-ALIGNED
     tt-place.issue-year AT ROW 8.71 COL 21.63 COLON-ALIGNED
          LABEL "Год выпуска"
          VIEW-AS FILL-IN
          SIZE 11.63 BY 1
     place-type AT ROW 8.71 COL 88 RIGHT-ALIGNED NO-LABEL WIDGET-ID 8
     tt-place.start-date AT ROW 9.71 COL 21.63 COLON-ALIGNED
          LABEL "Ввод в эксплуатацию"
          VIEW-AS FILL-IN
          SIZE 11.63 BY 1
     place-locat AT ROW 9.71 COL 88 RIGHT-ALIGNED NO-LABEL WIDGET-ID 30
     t-ponton at row 10.81 col 2
     ponton-mass at row 10.81 col 18
     ponton-height  at row 10.81 col 50
     tt-place.add-qnty AT ROW 11.92 COL 30.63 COLON-ALIGNED
          LABEL "Объем трубопровода(л)"
          VIEW-AS FILL-IN
          SIZE 11.63 BY 1
     error-mass AT ROW 11.92 COL 75.38 COLON-ALIGNED WIDGET-ID 38
     tt-place.max-qnty AT ROW 12.92 COL 30.63 COLON-ALIGNED
          LABEL "Макс. кол-во в резервуаре(л)"
          VIEW-AS FILL-IN
          SIZE 11.63 BY 1
     place-si AT ROW 12.92 COL 75.38 COLON-ALIGNED WIDGET-ID 16
     r-sr-izm AT ROW 12.92 COL 90 RIGHT-ALIGNED
     place-si-name AT ROW 12.92 COL 75.38 COLON-ALIGNED
     dead-balance AT ROW 13.92 COL 30.63 COLON-ALIGNED WIDGET-ID 18
     water-level AT ROW 14.92 COL 30.63 COLON-ALIGNED WIDGET-ID 58
     place-diameter AT ROW 13.92 COL 75.38 COLON-ALIGNED WIDGET-ID 18
     place-dead-high at row 15.25 COL 88 RIGHT-ALIGNED
     place-temp-coef at row 16.25 COL 88 RIGHT-ALIGNED
     dens-prov AT ROW 17.25 COL 88 RIGHT-ALIGNED
     t-auto-gate-valve at row 18.25 col 3
     place-twice-code AT ROW 18.25 COL 88 RIGHT-ALIGNED WIDGET-ID 24
     t-com-vessel at row 19.25 col 20
     com-tanks at row 19.25 col 65 no-label
     b-com-tanks at row 19.25 col 85
     v-is-main at row 19.25 col 5 no-label
     t-gate-valve at row 20.25 col 20
     gate-valve-tanks at row 20.25 col 65 no-label
     b-gate-valve-tanks at row 20.25 col 85
     place-passp-num at row 21.5 col 88 right-aligned
     place-passp-type at row 22.5 col 88 right-aligned
     tt-place.chk-max-qnty AT ROW 24 COL 3 WIDGET-ID 2
          LABEL "Проверять макс. допустимое кол-во товара на месте хранения"
          VIEW-AS TOGGLE-BOX
          SIZE 62.63 BY .83
     tt-place.PS AT ROW 25 COL 2 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 87 BY 4
     "Тип резервуара:" VIEW-AS TEXT
          SIZE 15.63 BY .75 AT ROW 8.71 COL 37 WIDGET-ID 12
     "РВД:" VIEW-AS TEXT
          SIZE 8 BY 1 AT ROW 6.75 COL 27 WIDGET-ID 42
     "Расположение резервуара:" VIEW-AS TEXT
          SIZE 24.75 BY .92 AT ROW 9.75 COL 37 WIDGET-ID 34
     SPACE(30.12) SKIP(16.65)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Складское место".
ASSIGN
       FRAME d-pl-form:SCROLLABLE       = FALSE.
ON CHOOSE OF b-exit IN FRAME d-pl-form
DO:
define variable vOk as logical no-undo .
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
assign
  tt-place.pl-name
  tt-place.loc1
  tt-place.loc2
  tt-place.loc3
  tt-place.loc4
  tt-place.ps
  tt-place.add-qnty
  tt-place.is-meas
  tt-place.max-qnty
  tt-place.start-date
  tt-place.issue-year
  tt-place.chk-max-qnty
  t-place-virtual
  t-asi-srtif
  place-locat
  error-mass
  rvd-dnstv
  rvd-lvl
  rvd-tmp
  place-si
  v-mi-dnst
  v-mi-lvl
  v-mi-tmp
  ponton-mass
  ponton-height
  t-com-vessel
  t-auto-gate-valve
.
if v-mi-dnst = ? then v-mi-dnst = 0 .
if v-mi-lvl = ?  then v-mi-lvl = 0 .
if v-mi-tmp = ? then v-mi-tmp = 0 .
if input frame d-pl-form dens-prov <> dens-prov then
do:
  if input frame d-pl-form dens-prov = ?
    or (  input frame d-pl-form dens-prov <= 0
    or input frame d-pl-form dens-prov >= 1
    )
    then
  do:
    message "Неверно определена плотность при поверке резервуара" view-as alert-box error.
    apply "entry" to dens-prov .
    return no-apply.
  end.
  assign frame d-pl-form dens-prov.
end.
if place-type:screen-value = "1"
and t-ponton:screen-value = "yes"
then do :
  if ponton-mass = 0
  or ponton-mass = ?
  then do :
    message "Не указана масса понтона для вертикального резервуара с понтоном." skip
            "Сохранение невозможно." skip
            "Укажите массу понтона."
    view-as alert-box error.
    apply "entry" to ponton-mass .
    return no-apply.
  end .
  if ponton-height = 0
  or ponton-height = ?
  then do :
    message "Не указана высота всплытия понтона для вертикального резервуара с понтоном." skip
            "Сохранение невозможно." skip
            "Укажите высоту всплытия понтона."
    view-as alert-box error.
    apply "entry" to ponton-height .
    return no-apply.
  end .
end .
if t-com-vessel:screen-value = "yes"
then do :
  if com-tanks:screen-value = ""
  then do :
    message "Укажите сообщающийся резервуар!" view-as alert-box error.
    return no-apply.
  end .
end .
if rvd-dnstv <> rvd-tmp
and ((available dnst_sr-izmerenia and dnst_sr-izmerenia.sr-type-izm = 0 and dnst_sr-izmerenia.sr-density and dnst_sr-izmerenia.sr-temperature)
  or (available tmp_sr-izmerenia and tmp_sr-izmerenia.sr-type-izm = 0 and tmp_sr-izmerenia.sr-density and tmp_sr-izmerenia.sr-temperature))
then do :
  message "Бизнес-процессом не предусмотрено использование неравнозначных положений разрешения РВД по параметрам температура и плотность, " +
          "если дополнительное автоматизированное СИ предназначено для измерения обоих параметров. " +
          "Сохранение неравнозначных положений разрешения РВД по параметрам температура и плотность запрещено. " +
          "Установите разрешение РВД для температуры и плотности в равнозначные положения."
  view-as alert-box .
  return no-apply.
end .
if available dnst_sr-izmerenia
and available tmp_sr-izmerenia
and dnst_sr-izmerenia.node-code <> tmp_sr-izmerenia.node-code
and ((dnst_sr-izmerenia.sr-density and dnst_sr-izmerenia.sr-temperature)
  or (tmp_sr-izmerenia.sr-density and tmp_sr-izmerenia.sr-temperature))
then do :
  message "Нельзя устанавливать разные дополнительные СИ по плотности и температуре, если одно из них измеряет оба параметра." skip
          "Сохранение невозможно."
  view-as alert-box .
  return no-apply.
end .
if place-si = ? or place-si = 0
then do :
  message "Не указано основное средство измерения! Вы уверены, что хотите закончить настройку складского места?"
  view-as alert-box question buttons yes-no update vOk .
  if not vOk
  then
    return no-apply .
end .
else do :
  find first sr-izmerenia no-lock where sr-izmerenia.node-code = place-si .
  if sr-izmerenia.sr-level
  and sr-izmerenia.sr-density
  and sr-izmerenia.sr-temperature
  and sr-izmerenia.sr-Weight
  then do : end .
  else do :
    message "Выбранное основное средство измерения не настроено на измерение всех параметров! Вы уверены, что хотите закончить настройку складского места?"
    view-as alert-box question buttons yes-no update vOk .
    if not vOk
    then
      return no-apply .
  end .
end .
if rvd-dnstv
then do :
  if v-mi-dnst = ? or v-mi-dnst = 0
  then do :
    message "Не указано вспомогательное средство измерения плотности. Вы уверены, что хотите закончить настройку складского места?"
    view-as alert-box question buttons yes-no update vOk .
    if not vOk
    then
      return no-apply .
  end .
  else do :
    find first sr-izmerenia no-lock where sr-izmerenia.node-code = v-mi-dnst .
    if not sr-izmerenia.sr-density
    then do :
      message "Выбранное дополнительно средство измерения для плотности не настроено на измерение плотности! Вы уверены, что хотите закончить настройку складского места?"
      view-as alert-box question buttons yes-no update vOk .
      if not vOk
      then
        return no-apply .
    end .
  end .
end .
if rvd-tmp
then do :
  if v-mi-tmp = ? or v-mi-tmp = 0
  then do :
    message "Не указано вспомогательное средство измерения температуры. Вы уверены, что хотите закончить настройку складского места?"
    view-as alert-box question buttons yes-no update vOk .
    if not vOk
    then
      return no-apply .
  end .
  else do :
    find first sr-izmerenia no-lock where sr-izmerenia.node-code = v-mi-tmp .
    if not sr-izmerenia.sr-temperature
    then do :
      message "Выбранное дополнительно средство измерения для температуры не настроено на измерение температуры! Вы уверены, что хотите закончить настройку складского места?"
      view-as alert-box question buttons yes-no update vOk .
      if not vOk
      then
        return no-apply .
    end .
  end .
end .
if rvd-lvl
then do :
  if v-mi-lvl = ? or v-mi-lvl = 0
  then do :
    message "Не указано вспомогательное средство измерения уровня. Вы уверены, что хотите закончить настройку складского места?"
    view-as alert-box question buttons yes-no update vOk .
    if not vOk
    then
      return no-apply .
  end .
  else do :
    find first sr-izmerenia no-lock where sr-izmerenia.node-code = v-mi-lvl .
    if not sr-izmerenia.sr-level
    then do :
      message "Выбранное дополнительно средство измерения для уровня не настроено на измерение уровня! Вы уверены, что хотите закончить настройку складского места?"
      view-as alert-box question buttons yes-no update vOk .
      if not vOk
      then
        return no-apply .
    end .
  end .
end .
if p-mode = 'ДОБАВЛЕНИЕ':U
then do :
  message "Внимание! После подтверждения завершения работы по вводу данных дальнейшая корректировка контролируемых параметров резервуара будет возможна только в ИС УРТ. Подтвердите завершение работы!"
  view-as alert-box question buttons yes-no update vOk .
  if not vOk
  then
    return no-apply .
end .
run ref/place01.p
  ( input-output p-rep-rec
  , input p-mode
  , input no
  , input tt-place.obj-type
  , input tt-place.obj-code
  , input tt-place.pl-code
  , input tt-place.loc1
  , input tt-place.loc2
  , input tt-place.loc3
  , input tt-place.loc4
  , input tt-place.pl-name
  , input tt-place.ps
  , input tt-place.add-qnty
  , input tt-place.is-meas
  , input tt-place.max-qnty
  , input tt-place.issue-year
  , input tt-place.start-date
  , input tt-place.chk-max-qnty
  ) no-error.
if error-status:error then
do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame d-pl-form:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return no-apply.
    end.
    hh = hh:next-sibling.
  end.
end.
  undo, return no-apply.
end.
else
do :
  find first ub.place no-lock where recid(ub.place) = p-rep-rec .
  ii = 0.
  do ii = 1 to num-entries('place-type,place-SI,place-diameter,dead-balance,water-level,dens-prov,place-virtual,place-twice-code,place-sert-urov,place-local,place-error-mass,place-asi-sertif,place-rvd-dnsty,place-rvd-lvl,place-rvd-tmp,place-SI-dens,place-SI-level,place-SI-temp,place-passp-num,place-passp-type,place-dead-high,place-temp-coef,disable-water-alarm,disable-level-alarm,place-ponton,place-ponton-mass,place-ponton-height,place-com-vessel,place-com-tanks,place-is-main,place-gate-valve,place-gate-valve-tanks,place-auto-gate-valve':u,','):
    v-code = entry(ii,'place-type,place-SI,place-diameter,dead-balance,water-level,dens-prov,place-virtual,place-twice-code,place-sert-urov,place-local,place-error-mass,place-asi-sertif,place-rvd-dnsty,place-rvd-lvl,place-rvd-tmp,place-SI-dens,place-SI-level,place-SI-temp,place-passp-num,place-passp-type,place-dead-high,place-temp-coef,disable-water-alarm,disable-level-alarm,place-ponton,place-ponton-mass,place-ponton-height,place-com-vessel,place-com-tanks,place-is-main,place-gate-valve,place-gate-valve-tanks,place-auto-gate-valve':u) .
    case v-code :
        when "place-type" then
            do :
                v-value = place-type:screen-value .
            end.
        when "place-SI" then
            do :
                v-value = place-si:screen-value .
            end.
        when "place-diameter" then
            do :
                v-value =  place-diameter:screen-value.
            end.
        when "dead-balance" then
            do :
                v-value =  dead-balance:screen-value.
            end.
        when "water-level" then
            do :
                v-value =  water-level:screen-value.
            end.
        when "dens-prov" then
            do :
                v-value = dens-prov:screen-value .
            end.
        when "place-virtual" then
            do :
                v-value = t-place-virtual:screen-value .
            end.
        when "place-twice-code" then
            do:
                v-value = place-twice-code:screen-value .
            end.
        when "place-error-mass" then
            do:
                v-value = error-mass:screen-value .
            end.
        when "place-local" then
            do:
                v-value = place-locat:screen-value .
            end.
        when "place-asi-sertif" then
            do:
                v-value = t-asi-srtif:screen-value .
            end.
        when "place-rvd-dnsty" then
            do:
                v-value = rvd-dnstv:screen-value .
            end.
        when "place-rvd-lvl" then
            do:
                v-value = rvd-lvl:screen-value .
            end.
        when "place-rvd-tmp" then
            do:
                v-value = rvd-tmp:screen-value .
            end.
        when "place-SI-dens" then
            do:
                v-value = v-mi-dnst:screen-value .
            end.
        when "place-SI-temp" then
            do:
                v-value = v-mi-tmp:screen-value .
            end.
        when "place-SI-level" then
            do:
                v-value = v-mi-lvl:screen-value .
            end.
        when "place-passp-num" then
            do:
                v-value = place-passp-num:screen-value .
            end.
        when "place-passp-type" then
            do:
                v-value = place-passp-type:screen-value .
            end.
        when "place-dead-high" then
            do:
                v-value = place-dead-high:screen-value .
            end.
        when "place-temp-coef" then
            do:
                v-value = place-temp-coef:screen-value .
            end.
        when "place-ponton" then
            do:
                v-value = t-ponton:screen-value .
            end.
        when "place-ponton-mass" then
            do:
                v-value = ponton-mass:screen-value .
            end.
        when "place-ponton-height" then
            do:
                v-value = ponton-height:screen-value .
            end.
        when "place-com-vessel" then
            do:
                v-value = t-com-vessel:screen-value .
            end.
        when "place-com-tanks" then
            do:
                v-value = com-tanks .
            end.
        when "place-gate-valve" then
            do:
                v-value = t-gate-valve:screen-value .
            end.
        when "place-gate-valve-tanks" then
            do:
                v-value = gate-valve-tanks .
            end.
        when "place-is-main" then
            do:
                v-value = if is-main then "yes" else "no" .
            end.
        when "place-auto-gate-valve" then
            do:
                v-value = t-auto-gate-valve:screen-value .
            end.
    end case.
    run placelib_write-attr  (input v-code
      ,input p-obj-code
      ,input p-obj-type
      ,input ub.place.pl-code
      ,input v-value
      ,output v-ok      ) no-error.
  end.
  if (not v-old-auto-gate-valve or v-com-vessel-changed)
  and t-auto-gate-valve
  and is-main
  then do :
    run placelib_write-attr  (input "place-current"
      ,input p-obj-code
      ,input p-obj-type
      ,input com_place.pl-code
      ,input "yes"
      ,output v-ok      ) no-error.
    if not v-com-vessel-changed
    then do :
      do ii = 1 to num-entries(com-tanks) :
        for first com_place no-lock where com_place.obj-type = p-obj-type
                                      and com_place.obj-code = p-obj-code
                                      and com_place.loc1 = entry(ii, com-tanks)
                                      and com_place.status_ = ""
        :
          run placelib_write-attr  (input "place-auto-gate-valve"
            ,input p-obj-code
            ,input p-obj-type
            ,input com_place.pl-code
            ,input "yes"
            ,output v-ok      ) no-error.
          run placelib_write-attr  (input "place-current"
            ,input p-obj-code
            ,input p-obj-type
            ,input com_place.pl-code
            ,input "no"
            ,output v-ok      ) no-error.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'ref-event':U
  ,input  buffer com_place:handle
  ,input  buffer com_place:handle
  ,input ''
  ,input ''
  ) no-error .
        end .
      end .
    end .
  end .
  if v-old-auto-gate-valve
  and not t-auto-gate-valve
  and is-main
  and not v-com-vessel-changed
  then do :
    run placelib_write-attr  (input "place-current"
      ,input p-obj-code
      ,input p-obj-type
      ,input com_place.pl-code
      ,input "no"
      ,output v-ok      ) no-error.
    do ii = 1 to num-entries(com-tanks) :
      for first com_place no-lock where com_place.obj-type = p-obj-type
                                    and com_place.obj-code = p-obj-code
                                    and com_place.loc1 = entry(ii, com-tanks)
                                    and com_place.status_ = ""
      :
        run placelib_write-attr  (input "place-auto-gate-valve"
          ,input p-obj-code
          ,input p-obj-type
          ,input com_place.pl-code
          ,input "no"
          ,output v-ok      ) no-error.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'ref-event':U
  ,input  buffer com_place:handle
  ,input  buffer com_place:handle
  ,input ''
  ,input ''
  ) no-error .
      end .
    end .
  end .
  define variable v-cv-place as character no-undo .
  define variable v-com-place-attr-changed as logical no-undo .
  if v-com-vessel-changed
  then do :
    for each com_place-attr exclusive-lock where com_place-attr.obj-type = p-obj-type
                                             and com_place-attr.obj-code = p-obj-code
                                             and com_place-attr.attr-code = "place-com-tanks"
                                             and com_place-attr.attr-value > ""
    :
      v-com-place-attr-changed = no .
      ii_ :
      do ii = 1 to num-entries(com_place-attr.attr-value) :
        if entry(ii, com_place-attr.attr-value) = tt-place.loc1
        then do :
          com_place-attr.attr-value = trim(replace((com_place-attr.attr-value + ","), (tt-place.loc1 + ","), ""), ",") .
          v-com-place-attr-changed = yes .
          leave ii_ .
        end .
      end .
      if com_place-attr.attr-value = ""
      then do :
        run placelib_write-attr  (input "place-com-vessel"
          ,input p-obj-code
          ,input p-obj-type
          ,input com_place-attr.pl-code
          ,input "no"
          ,output v-ok      ) no-error.
        run placelib_write-attr  (input "place-is-main"
          ,input p-obj-code
          ,input p-obj-type
          ,input com_place-attr.pl-code
          ,input "no"
          ,output v-ok      ) no-error.
        run placelib_write-attr  (input "place-auto-gate-valve"
          ,input p-obj-code
          ,input p-obj-type
          ,input com_place-attr.pl-code
          ,input "no"
          ,output v-ok      ) no-error.
        run placelib_write-attr  (input "place-current"
          ,input p-obj-code
          ,input p-obj-type
          ,input com_place-attr.pl-code
          ,input "no"
          ,output v-ok      ) no-error.
        v-com-place-attr-changed = yes .
      end .
      if v-com-place-attr-changed
      then do :
        for first com_place no-lock where com_place.obj-type = p-obj-type
                                      and com_place.obj-code = p-obj-code
                                      and com_place.pl-code  = com_place-attr.pl-code
        :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'ref-event':U
  ,input  buffer com_place:handle
  ,input  buffer com_place:handle
  ,input ''
  ,input ''
  ) no-error .
        end .
      end .
    end .
    if com-tanks > ""
    then do :
      do ii = 1 to num-entries(com-tanks) :
        for first com_place no-lock where com_place.obj-type = p-obj-type
                                      and com_place.obj-code = p-obj-code
                                      and com_place.loc1 = entry(ii, com-tanks)
                                      and com_place.status_ = ""
        :
          run placelib_write-attr  (input "place-com-vessel"
            ,input p-obj-code
            ,input p-obj-type
            ,input com_place.pl-code
            ,input "yes"
            ,output v-ok      ) no-error.
          v-cv-place = replace(com-tanks, com_place.loc1, tt-place.loc1) .
          run placelib_write-attr  (input "place-com-tanks"
            ,input p-obj-code
            ,input p-obj-type
            ,input com_place.pl-code
            ,input v-cv-place
            ,output v-ok      ) no-error.
          run placelib_write-attr  (input "place-is-main"
            ,input p-obj-code
            ,input p-obj-type
            ,input com_place.pl-code
            ,input "no"
            ,output v-ok      ) no-error.
          if is-main
          then do :
            if t-auto-gate-valve
            then do :
              run placelib_write-attr  (input "place-auto-gate-valve"
                ,input p-obj-code
                ,input p-obj-type
                ,input com_place.pl-code
                ,input "yes"
                ,output v-ok      ) no-error.
              run placelib_write-attr  (input "place-current"
                ,input p-obj-code
                ,input p-obj-type
                ,input com_place.pl-code
                ,input "no"
                ,output v-ok      ) no-error.
            end .
            else do :
              run placelib_write-attr  (input "place-auto-gate-valve"
                ,input p-obj-code
                ,input p-obj-type
                ,input com_place.pl-code
                ,input "no"
                ,output v-ok      ) no-error.
            end .
          end .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'ref-event':U
  ,input  buffer com_place:handle
  ,input  buffer com_place:handle
  ,input ''
  ,input ''
  ) no-error .
          if error-status :error
            then
          do:
            message
              error-status:get-message(1) skip
              return-value
              view-as alert-box error .
            return no-apply .
          end.
        end .
      end .
    end .
  end .
  define variable v-gv-place as character no-undo .
  if v-gate-valve-tanks-changed
  then do :
    for each com_place-attr exclusive-lock where com_place-attr.obj-type = p-obj-type
                                             and com_place-attr.obj-code = p-obj-code
                                             and com_place-attr.attr-code = "place-gate-valve-tanks"
                                             and com_place-attr.attr-value > ""
    :
      ii_ :
      do ii = 1 to num-entries(com_place-attr.attr-value) :
        if entry(ii, com_place-attr.attr-value) = tt-place.loc1
        then do :
          com_place-attr.attr-value = trim(replace((com_place-attr.attr-value + ","), (tt-place.loc1 + ","), ""), ",") .
          leave ii_ .
        end .
      end .
      if com_place-attr.attr-value = ""
      then do :
        run placelib_write-attr  (input "place-gate-valve"
          ,input p-obj-code
          ,input p-obj-type
          ,input com_place-attr.pl-code
          ,input "no"
          ,output v-ok      ) no-error.
      end .
      for first com_place no-lock where com_place.obj-type = p-obj-type
                                    and com_place.obj-code = p-obj-code
                                    and com_place.pl-code  = com_place-attr.pl-code
      :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'ref-event':U
  ,input  buffer com_place:handle
  ,input  buffer com_place:handle
  ,input ''
  ,input ''
  ) no-error .
      end .
    end .
    if gate-valve-tanks > ""
    then do :
      do ii = 1 to num-entries(gate-valve-tanks) :
        for first com_place no-lock where com_place.obj-type = p-obj-type
                                      and com_place.obj-code = p-obj-code
                                      and com_place.loc1 = entry(ii, gate-valve-tanks)
                                      and com_place.status_ = ""
        :
          run placelib_write-attr  (input "place-gate-valve"
            ,input p-obj-code
            ,input p-obj-type
            ,input com_place.pl-code
            ,input "yes"
            ,output v-ok      ) no-error.
          v-gv-place = replace(gate-valve-tanks, com_place.loc1, tt-place.loc1) .
          run placelib_write-attr  (input "place-gate-valve-tanks"
            ,input p-obj-code
            ,input p-obj-type
            ,input com_place.pl-code
            ,input v-gv-place
            ,output v-ok      ) no-error.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'ref-event':U
  ,input  buffer com_place:handle
  ,input  buffer com_place:handle
  ,input ''
  ,input ''
  ) no-error .
          if error-status :error
            then
          do:
            message
              error-status:get-message(1) skip
              return-value
              view-as alert-box error .
            return no-apply .
          end.
        end .
      end .
    end .
  end .
  define variable v-rvd-params-on as character no-undo .
  define variable v-rvd-params-off as character no-undo .
  define variable v-shift-num as integer no-undo .
  define variable v-shift-date as date no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  v-rvd-params-on = "" .
  v-rvd-params-off = "" .
  v-shift-num = 0 .
  define variable v-mi-par-list as character no-undo .
  define variable v-mi-old-val-list as character no-undo .
  define variable v-mi-new-val-list as character no-undo .
  v-mi-par-list = "" .
  v-mi-old-val-list = "" .
  v-mi-new-val-list = "" .
  define variable v-userlog-value as character no-undo .
  v-shift-date = ? .
  for first buf_shift-obj
      where buf_shift-obj.obj-type = p-obj-type
        and buf_shift-obj.obj-code = p-obj-code
        and buf_shift-obj.status_ = 'тек':U
      use-index stts :
    assign
      v-shift-date = buf_shift-obj.shift-date
      v-shift-num  = buf_shift-obj.shift-num
    .
  end.
  if v-shift-date = ? then v-shift-date = today .
  if v-rvd-dnsty-on = rvd-dnstv
  and v-rvd-lvl-on = rvd-lvl
  and v-rvd-temp-on = rvd-tmp
  and v-rvd-is-meas-on = tt-place.is-meas
  then do :
    if v-main-mi-old = place-si
    and v-dnst-mi-old = v-mi-dnst
    and v-lvl-mi-old = v-mi-lvl
    and v-tmp-mi-old = v-mi-tmp
    then do :
    end .
    else do :
      if v-main-mi-old <> place-si
      then do :
        assign
          v-mi-par-list = "m" + ","
          v-mi-old-val-list = string(v-main-mi-old) + ","
          v-mi-new-val-list = string(place-si) + ","
        .
      end .
      if v-dnst-mi-old <> v-mi-dnst
      then do :
        assign
          v-mi-par-list = v-mi-par-list + "p" + ","
          v-mi-old-val-list = v-mi-old-val-list + string(v-dnst-mi-old) + ","
          v-mi-new-val-list = v-mi-new-val-list + string(v-mi-dnst) + ","
        .
      end .
      if v-lvl-mi-old <> v-mi-lvl
      then do :
        assign
          v-mi-par-list = v-mi-par-list + "l" + ","
          v-mi-old-val-list = v-mi-old-val-list + string(v-lvl-mi-old) + ","
          v-mi-new-val-list = v-mi-new-val-list + string(v-mi-lvl) + ","
        .
      end .
      if v-tmp-mi-old <> v-mi-tmp
      then do :
        assign
          v-mi-par-list = v-mi-par-list + "t"
          v-mi-old-val-list = v-mi-old-val-list + string(v-tmp-mi-old)
          v-mi-new-val-list = v-mi-new-val-list + string(v-mi-tmp)
        .
      end .
      assign
        v-mi-par-list = trim(v-mi-par-list, ",")
        v-mi-old-val-list = trim(v-mi-old-val-list, ",")
        v-mi-new-val-list = trim(v-mi-new-val-list, ",")
      .
      run trg/userlog.p (
              input 'mi-change-1C'
            , input ("Изменение средств измерений на объекте " +
                    p-obj-type + string(p-obj-code) +
                    " рез. " + string(p-pl-code) + ": " +
                    v-mi-par-list + ";" +
                    v-mi-old-val-list + ";" +
                    v-mi-new-val-list +
                    chr(3) +
                    p-obj-type + chr(6) +
                    string(p-obj-code) + chr(6) +
                    string(v-shift-date) + chr(6) +
                    string(v-shift-num) + chr(6) +
                    string(p-pl-code) + chr(6) +
                    v-mi-par-list + chr(6) +
                    v-mi-old-val-list + chr(6) +
                    v-mi-new-val-list + chr(6) +
                    string(v-main-mi-old) + chr(6) +
                    string(place-SI) + chr(6) +
                    string(v-dnst-mi-old) + chr(6) +
                    string(v-mi-dnst) + chr(6) +
                    string(v-lvl-mi-old) + chr(6) +
                    string(v-mi-lvl) + chr(6) +
                    string(v-tmp-mi-old) + chr(6) +
                    string(v-mi-tmp)   )
            , input ?
            , input ?
            , input ""
            ) no-error.
      if error-status :error
      then do:
          message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
      end.
    end .
  end .
  else do :
    if v-rvd-on
    then do :
      if v-rvd-dnsty-on <> rvd-dnstv
      and rvd-dnstv = yes
      then do :
        v-rvd-params-on = "p" + "," .
      end .
      if v-rvd-temp-on <> rvd-tmp
      and rvd-tmp = yes
      then do :
        v-rvd-params-on = v-rvd-params-on + "T" + "," .
      end .
      if v-rvd-lvl-on <> rvd-lvl
      and rvd-lvl = yes
      then do :
        v-rvd-params-on = v-rvd-params-on + "l" + "," .
      end .
      if v-rvd-is-meas-on <> tt-place.is-meas
      and tt-place.is-meas = no
      then do :
        v-rvd-params-on = v-rvd-params-on + "F" .
      end .
      v-rvd-params-on = trim(v-rvd-params-on, ",") .
      v-rvd-params-on = trim(v-rvd-params-on) .
      if v-rvd-params-on > ""
      then do :
        v-userlog-value = ("Установка РВД на объекте " +
                          p-obj-type + string(p-obj-code) +
                          " рез. " + string(p-pl-code) + ": " +
                          v-rvd-params-on + ";" +
                          "yes" + ";" +
                          v-rvd-reason-on + ";" +
                          v-ITSM-num-on + ";" +
                          v-oper-fio-on +
                          chr(3) +
                          p-obj-type + chr(6) +
                          string(p-obj-code) + chr(6) +
                          string(v-shift-date) + chr(6) +
                          string(v-shift-num) + chr(6) +
                          string(p-pl-code) + chr(6) +
                          v-rvd-params-on + chr(6) +
                          "yes" + chr(6) +
                          v-rvd-reason-on + chr(6) +
                          v-ITSM-num-on + chr(6) +
                          v-oper-fio-on + chr(6) +
                          string(rvd-tmp) + chr(6) +
                          string(rvd-dnstv) + chr(6) +
                          string(rvd-lvl) + chr(6) +
                          string(tt-place.is-meas)  )
                          .
        if v-main-mi-old = place-si
        and v-dnst-mi-old = v-mi-dnst
        and v-lvl-mi-old = v-mi-lvl
        and v-tmp-mi-old = v-mi-tmp
        then do :
        end .
        else do :
          if v-main-mi-old <> place-si
          then do :
            assign
              v-mi-par-list = "m" + ","
              v-mi-old-val-list = string(v-main-mi-old) + ","
              v-mi-new-val-list = string(place-si) + ","
            .
          end .
          if v-dnst-mi-old <> v-mi-dnst
          then do :
            assign
              v-mi-par-list = v-mi-par-list + "p" + ","
              v-mi-old-val-list = v-mi-old-val-list + string(v-dnst-mi-old) + ","
              v-mi-new-val-list = v-mi-new-val-list + string(v-mi-dnst) + ","
            .
          end .
          if v-lvl-mi-old <> v-mi-lvl
          then do :
            assign
              v-mi-par-list = v-mi-par-list + "l" + ","
              v-mi-old-val-list = v-mi-old-val-list + string(v-lvl-mi-old) + ","
              v-mi-new-val-list = v-mi-new-val-list + string(v-mi-lvl) + ","
            .
          end .
          if v-tmp-mi-old <> v-mi-tmp
          then do :
            assign
              v-mi-par-list = v-mi-par-list + "t"
              v-mi-old-val-list = v-mi-old-val-list + string(v-tmp-mi-old)
              v-mi-new-val-list = v-mi-new-val-list + string(v-mi-tmp)
            .
          end .
          assign
            v-mi-par-list = trim(v-mi-par-list, ",")
            v-mi-old-val-list = trim(v-mi-old-val-list, ",")
            v-mi-new-val-list = trim(v-mi-new-val-list, ",")
          .
          run trg/userlog.p (
                  input 'mi-change'
                , input ("Изменение средств измерений на объекте " +
                        p-obj-type + string(p-obj-code) +
                        " рез. " + string(p-pl-code) + ": " +
                        v-mi-par-list + ";" +
                        v-mi-old-val-list + ";" +
                        v-mi-new-val-list +
                        chr(3) +
                        p-obj-type + chr(6) +
                        string(p-obj-code) + chr(6) +
                        string(v-shift-date) + chr(6) +
                        string(v-shift-num) + chr(6) +
                        string(p-pl-code) + chr(6) +
                        v-mi-par-list + chr(6) +
                        v-mi-old-val-list + chr(6) +
                        v-mi-new-val-list   )
                , input ?
                , input ?
                , input ""
                ) no-error.
          if error-status :error
          then do:
              message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
          end.
          v-userlog-value = v-userlog-value + chr(6) +
                            "" + chr(6) +
                            string(v-main-mi-old) + chr(6) +
                            string(place-SI) + chr(6) +
                            string(v-dnst-mi-old) + chr(6) +
                            string(v-mi-dnst) + chr(6) +
                            string(v-lvl-mi-old) + chr(6) +
                            string(v-mi-lvl) + chr(6) +
                            string(v-tmp-mi-old) + chr(6) +
                            string(v-mi-tmp)
                            .
        end .
        run trg/userlog.p (
                input 'rvd-reasons'
              , input v-userlog-value
              , input ?
              , input ?
              , input ""
              ) no-error.
        if error-status :error
        then do:
            message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
        end.
        run placelib_write-attr  (input "place-need-RVD-rvs"
                                  ,input p-obj-code
                                  ,input p-obj-type
                                  ,input ub.place.pl-code
                                  ,input string(yes)
                                  ,output v-ok      ) no-error.
      end .
    end .
    if v-rvd-off
    then do :
      if v-rvd-dnsty-on <> rvd-dnstv
      and rvd-dnstv = no
      then do :
        v-rvd-params-off = "p" + "," .
      end .
      if v-rvd-temp-on <> rvd-tmp
      and rvd-tmp = no
      then do :
        v-rvd-params-off = v-rvd-params-off + "T" + "," .
      end .
      if v-rvd-lvl-on <> rvd-lvl
      and rvd-lvl = no
      then do :
        v-rvd-params-off = v-rvd-params-off + "l" + "," .
      end .
      if v-rvd-is-meas-on <> tt-place.is-meas
      and tt-place.is-meas = yes
      then do :
        v-rvd-params-off = v-rvd-params-off + "F" .
      end .
      v-rvd-params-off = trim(v-rvd-params-off, ",") .
      v-rvd-params-off = trim(v-rvd-params-off) .
      if v-rvd-params-off > ""
      then do :
        v-userlog-value = ("Снятие РВД на объекте " +
                          p-obj-type + string(p-obj-code) +
                          " рез. " + string(p-pl-code) + ": " +
                          v-rvd-params-off + ";" +
                          "no" + ";" +
                          v-rvd-reason-off + ";" +
                          v-ITSM-num-off + ";" +
                          v-oper-fio-off +
                          chr(3) +
                          p-obj-type + chr(6) +
                          string(p-obj-code) + chr(6) +
                          string(v-shift-date) + chr(6) +
                          string(v-shift-num) + chr(6) +
                          string(p-pl-code) + chr(6) +
                          v-rvd-params-off + chr(6) +
                          "no" + chr(6) +
                          v-rvd-reason-off + chr(6) +
                          v-ITSM-num-off + chr(6) +
                          v-oper-fio-off + chr(6) +
                          string(rvd-tmp) + chr(6) +
                          string(rvd-dnstv) + chr(6) +
                          string(rvd-lvl) + chr(6) +
                          string(tt-place.is-meas)  )
                          .
        if v-main-mi-old = place-si
        and v-dnst-mi-old = v-mi-dnst
        and v-lvl-mi-old = v-mi-lvl
        and v-tmp-mi-old = v-mi-tmp
        then do :
        end .
        else do :
          if v-main-mi-old <> place-si
          then do :
            assign
              v-mi-par-list = "m" + ","
              v-mi-old-val-list = string(v-main-mi-old) + ","
              v-mi-new-val-list = string(place-si) + ","
            .
          end .
          if v-dnst-mi-old <> v-mi-dnst
          then do :
            assign
              v-mi-par-list = v-mi-par-list + "p" + ","
              v-mi-old-val-list = v-mi-old-val-list + string(v-dnst-mi-old) + ","
              v-mi-new-val-list = v-mi-new-val-list + string(v-mi-dnst) + ","
            .
          end .
          if v-lvl-mi-old <> v-mi-lvl
          then do :
            assign
              v-mi-par-list = v-mi-par-list + "l" + ","
              v-mi-old-val-list = v-mi-old-val-list + string(v-lvl-mi-old) + ","
              v-mi-new-val-list = v-mi-new-val-list + string(v-mi-lvl) + ","
            .
          end .
          if v-tmp-mi-old <> v-mi-tmp
          then do :
            assign
              v-mi-par-list = v-mi-par-list + "t"
              v-mi-old-val-list = v-mi-old-val-list + string(v-tmp-mi-old)
              v-mi-new-val-list = v-mi-new-val-list + string(v-mi-tmp)
            .
          end .
          assign
            v-mi-par-list = trim(v-mi-par-list, ",")
            v-mi-old-val-list = trim(v-mi-old-val-list, ",")
            v-mi-new-val-list = trim(v-mi-new-val-list, ",")
          .
          run trg/userlog.p (
                  input 'mi-change'
                , input ("Изменение средств измерений на объекте " +
                        p-obj-type + string(p-obj-code) +
                        " рез. " + string(p-pl-code) + ": " +
                        v-mi-par-list + ";" +
                        v-mi-old-val-list + ";" +
                        v-mi-new-val-list +
                        chr(3) +
                        p-obj-type + chr(6) +
                        string(p-obj-code) + chr(6) +
                        string(v-shift-date) + chr(6) +
                        string(v-shift-num) + chr(6) +
                        string(p-pl-code) + chr(6) +
                        v-mi-par-list + chr(6) +
                        v-mi-old-val-list + chr(6) +
                        v-mi-new-val-list   )
                , input ?
                , input ?
                , input ""
                ) no-error.
          if error-status :error
          then do:
              message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
          end.
          v-userlog-value = v-userlog-value + chr(6) +
                            "" + chr(6) +
                            string(v-main-mi-old) + chr(6) +
                            string(place-SI) + chr(6) +
                            string(v-dnst-mi-old) + chr(6) +
                            string(v-mi-dnst) + chr(6) +
                            string(v-lvl-mi-old) + chr(6) +
                            string(v-mi-lvl) + chr(6) +
                            string(v-tmp-mi-old) + chr(6) +
                            string(v-mi-tmp)
                            .
        end .
        run trg/userlog.p (
                input 'rvd-reasons'
              , input v-userlog-value
              , input ?
              , input ?
              , input ""
              ) no-error.
        if error-status :error
        then do:
            message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
        end.
      end .
    end .
  end .
  if tt-place.is-meas
  and not rvd-dnstv
  and not rvd-tmp
  and not rvd-lvl
  then do :
    run placelib_write-attr  (input "place-need-RVD-rvs"
                              ,input p-obj-code
                              ,input p-obj-type
                              ,input ub.place.pl-code
                              ,input string(no)
                              ,output v-ok      ) no-error.
  end .
end.
if AVAILABLE (ub.place) then
do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'ref-event':U
  ,input  buffer ub.place:handle
  ,input  buffer ub.place:handle
  ,input ''
  ,input ''
  ) no-error .
  if error-status :error
    then
  do:
    message
      error-status:get-message(1) skip
      return-value
      view-as alert-box error .
    return no-apply .
  end.
end.
END.
ON CHOOSE OF B-hist IN FRAME d-pl-form
DO:
    define variable v-rid-list as character no-undo.
    run ref/cplchist.w
      ( input parparentproc
      , input p-obj-type
      , input p-obj-code
      , input "":u
      , input "one":u
      , input tt-place.obj-type
      , input tt-place.obj-code
      , input tt-place.pl-code
      , input 0
      , input 0
      , input 0
      , input '':u
      , input-output v-rid-list
      ) no-error .
  END.
ON CHOOSE OF b-quit IN FRAME d-pl-form
DO:
  define variable vlog as logical no-undo .
  message "Все введенные данные будут утеряны. Вы уверены, что хотите отказаться от внесенных изменений?"
  view-as alert-box question buttons yes-no update vlog .
  if not vlog then return no-apply .
  p-rep-rec = ?.
END.
ON LEAVE OF dens-prov IN FRAME d-pl-form
DO:
  if input frame d-pl-form dens-prov <> dens-prov then do:
    if input frame d-pl-form dens-prov = ?
      or (  input frame d-pl-form dens-prov <= 0
            or input frame d-pl-form dens-prov >= 1
              )
    then do:
      message "Неверно определена плотность при поверке резервуара" view-as alert-box error.
      apply "entry" to dens-prov .
      return no-apply.
    end.
    assign frame d-pl-form dens-prov.
  end.
if AVAILABLE (ub.place) then
do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'ref-event':U
  ,input  buffer ub.place:handle
  ,input  buffer ub.place:handle
  ,input ''
  ,input ''
  ) no-error .
  if error-status :error
    then
  do:
    message
      error-status:get-message(1) skip
      return-value
      view-as alert-box error .
    return no-apply .
  end.
end.
END.
ON VALUE-CHANGED OF rvd-dnstv IN FRAME d-pl-form
DO:
  define variable vlog as logical no-undo .
  define variable v-tmp-old-val as character no-undo .
  v-tmp-old-val = rvd-tmp:screen-value .
  if available dnst_sr-izmerenia
  and dnst_sr-izmerenia.sr-type-izm = 0
  and dnst_sr-izmerenia.sr-density
  and dnst_sr-izmerenia.sr-temperature
  and rvd-dnstv:screen-value <> rvd-tmp:screen-value
  then do :
    message "Бизнес-процессом не предусмотрено использование неравнозначных положений разрешения РВД по параметрам температура и плотность, " +
            "если автоматизированное СИ для одного из них предназначено для измерения обоих. " +
            "Сохранение неравнозначных положений разрешения РВД по параметрам температура и плотность запрещено. " +
            "Установить значение " + (if rvd-dnstv:screen-value = "yes" then "'Да'" else "'Нет'") + " для РВД по температуре автоматически?"
    view-as alert-box question buttons yes-no update vlog .
    if vlog
    then do :
      rvd-tmp:screen-value = rvd-dnstv:screen-value .
    end .
  end .
  if p-mode =  'ИЗМЕНЕНИЕ':U then
  do:
    if rvd-dnstv:screen-value = "yes" then do:
      if not v-rvd-on
      and not v-rvd-dnsty-on
      then do :
        message "Для установки разрешения РВД необходимо указать причину перехода на РВД, номер заявки в ITSM, ФИО инициатора заявки."
        view-as alert-box question buttons ok-cancel update vlog .
        if not vlog
        then do :
          rvd-dnstv:screen-value = "no" .
          rvd-tmp:screen-value = v-tmp-old-val .
          return no-apply .
        end .
        v-rvd-reason-on = ? .
        run ref/rvd-reasons.w (input parparentproc,
                               input 0,
                               output v-rvd-reason-on,
                               output v-ITSM-num-on,
                               output v-oper-fio-on)
                               .
        if v-rvd-reason-on = ?
        then do :
          rvd-dnstv:screen-value = "no" .
          rvd-tmp:screen-value = v-tmp-old-val .
          return no-apply .
        end .
        v-rvd-on = yes .
      end .
    end.
    else do:
      if not v-rvd-off
      and v-rvd-dnsty-on
      then do :
        message "Для снятия разрешения РВД необходимо указать причину перехода на АВД, номер заявки в ITSM, ФИО инициатора заявки."
        view-as alert-box question buttons ok-cancel update vlog .
        if not vlog
        then do :
          rvd-dnstv:screen-value = "yes" .
          rvd-tmp:screen-value = v-tmp-old-val .
          return no-apply .
        end .
        v-rvd-reason-off = ? .
        run ref/rvd-reasons.w (input parparentproc,
                               input 0,
                               output v-rvd-reason-off,
                               output v-ITSM-num-off,
                               output v-oper-fio-off)
                               .
        if v-rvd-reason-off = ?
        then do :
          rvd-dnstv:screen-value = "yes" .
          rvd-tmp:screen-value = v-tmp-old-val .
          return no-apply .
        end .
        v-rvd-off = yes .
      end .
    end.
  end.
END.
ON VALUE-CHANGED OF rvd-lvl IN FRAME d-pl-form
DO:
  define variable vlog as logical no-undo .
  if p-mode =  'ИЗМЕНЕНИЕ':U then
  do:
    if rvd-lvl:screen-value = "yes" then do:
      if not v-rvd-on
      and not v-rvd-lvl-on
      then do :
        message "Для установки разрешения РВД необходимо указать причину перехода на РВД, номер заявки в ITSM, ФИО инициатора заявки."
        view-as alert-box question buttons ok-cancel update vlog .
        if not vlog
        then do :
          rvd-lvl:screen-value = "no" .
          return no-apply .
        end .
        v-rvd-reason-on = ? .
        run ref/rvd-reasons.w (input parparentproc,
                               input 0,
                               output v-rvd-reason-on,
                               output v-ITSM-num-on,
                               output v-oper-fio-on)
                               .
        if v-rvd-reason-on = ?
        then do :
          rvd-lvl:screen-value = "no" .
          return no-apply .
        end .
        v-rvd-on = yes .
      end .
    end.
    else do:
      if not v-rvd-off
      and v-rvd-lvl-on
      then do :
        message "Для снятия разрешения РВД необходимо указать причину перехода на АВД, номер заявки в ITSM, ФИО инициатора заявки."
        view-as alert-box question buttons ok-cancel update vlog .
        if not vlog
        then do :
          rvd-lvl:screen-value = "yes" .
          return no-apply .
        end .
        v-rvd-reason-off = ? .
        run ref/rvd-reasons.w (input parparentproc,
                               input 0,
                               output v-rvd-reason-off,
                               output v-ITSM-num-off,
                               output v-oper-fio-off)
                               .
        if v-rvd-reason-off = ?
        then do :
          rvd-lvl:screen-value = "yes" .
          return no-apply .
        end .
        v-rvd-off = yes .
      end .
    end.
  end.
END.
ON VALUE-CHANGED OF rvd-tmp IN FRAME d-pl-form
DO:
  define variable vlog as logical no-undo .
  define variable v-dnst-old-val as character no-undo .
  v-dnst-old-val = rvd-dnstv:screen-value .
  if available tmp_sr-izmerenia
  and tmp_sr-izmerenia.sr-type-izm = 0
  and tmp_sr-izmerenia.sr-temperature
  and tmp_sr-izmerenia.sr-density
  and rvd-tmp:screen-value <> rvd-dnstv:screen-value
  then do :
    message "Бизнес-процессом не предусмотрено использование неравнозначных положений разрешения РВД по параметрам температура и плотность, " +
            "если автоматизированное СИ для одного из них предназначено для измерения обоих. " +
            "Сохранение неравнозначных положений разрешения РВД по параметрам температура и плотность запрещено. " +
            "Установить значение " + (if rvd-tmp:screen-value = "yes" then "'Да'" else "'Нет'") + " для РВД по плотности автоматически?"
    view-as alert-box question buttons yes-no update vlog .
    if vlog
    then do :
      rvd-dnstv:screen-value = rvd-tmp:screen-value .
    end .
  end .
  if p-mode =  'ИЗМЕНЕНИЕ':U then
  do:
    if rvd-tmp:screen-value = "yes" then do:
      if not v-rvd-on
      and not v-rvd-temp-on
      then do :
        message "Для установки разрешения РВД необходимо указать причину перехода на РВД, номер заявки в ITSM, ФИО инициатора заявки."
        view-as alert-box question buttons ok-cancel update vlog .
        if not vlog
        then do :
          rvd-tmp:screen-value = "no" .
          rvd-dnstv:screen-value = v-dnst-old-val .
          return no-apply .
        end .
        v-rvd-reason-on = ? .
        run ref/rvd-reasons.w (input parparentproc,
                               input 0,
                               output v-rvd-reason-on,
                               output v-ITSM-num-on,
                               output v-oper-fio-on)
                               .
        if v-rvd-reason-on = ?
        then do :
          rvd-tmp:screen-value = "no" .
          rvd-dnstv:screen-value = v-dnst-old-val .
          return no-apply .
        end .
        v-rvd-on = yes .
      end .
    end.
    else do:
      if not v-rvd-off
      and v-rvd-temp-on
      then do :
        message "Для снятия разрешения РВД необходимо указать причину перехода на АВД, номер заявки в ITSM, ФИО инициатора заявки."
        view-as alert-box question buttons ok-cancel update vlog .
        if not vlog
        then do :
          rvd-tmp:screen-value = "yes" .
          rvd-dnstv:screen-value = v-dnst-old-val .
          return no-apply .
        end .
        v-rvd-reason-off = ? .
        run ref/rvd-reasons.w (input parparentproc,
                               input 0,
                               output v-rvd-reason-off,
                               output v-ITSM-num-off,
                               output v-oper-fio-off)
                               .
        if v-rvd-reason-off = ?
        then do :
          rvd-tmp:screen-value = "yes" .
          rvd-dnstv:screen-value = v-dnst-old-val .
          return no-apply .
        end .
        v-rvd-off = yes .
      end .
    end.
  end.
END.
ON VALUE-CHANGED OF tt-place.is-meas IN FRAME d-pl-form
DO:
  define variable vlog as logical no-undo .
    if tt-place.is-meas:screen-value = "yes" then do:
      if not v-rvd-off
      and not v-rvd-is-meas-on
      and p-mode = 'ИЗМЕНЕНИЕ':U
      then do :
        message "Для снятия разрешения РВД необходимо указать причину перехода на АВД, номер заявки в ITSM, ФИО инициатора заявки."
        view-as alert-box question buttons ok-cancel update vlog .
        if not vlog
        then do :
          tt-place.is-meas:screen-value = "no" .
          return no-apply .
        end .
        v-rvd-reason-off = ? .
        run ref/rvd-reasons.w (input parparentproc,
                               input 0,
                               output v-rvd-reason-off,
                               output v-ITSM-num-off,
                               output v-oper-fio-off)
                               .
        if v-rvd-reason-off = ?
        then do :
          tt-place.is-meas:screen-value = "no" .
          return no-apply .
        end .
        v-rvd-off = yes .
      end .
      enable t-asi-srtif with frame d-pl-form .
    end.
    else do:
      if not v-rvd-on
      and v-rvd-is-meas-on
      and p-mode = 'ИЗМЕНЕНИЕ':U
      then do :
        message "Для установки разрешения РВД необходимо указать причину перехода на РВД, номер заявки в ITSM, ФИО инициатора заявки."
        view-as alert-box question buttons ok-cancel update vlog .
        if not vlog
        then do :
          tt-place.is-meas:screen-value = "yes" .
          return no-apply .
        end .
        v-rvd-reason-on = ? .
        run ref/rvd-reasons.w (input parparentproc,
                               input 0,
                               output v-rvd-reason-on,
                               output v-ITSM-num-on,
                               output v-oper-fio-on)
                               .
        if v-rvd-reason-on = ?
        then do :
          tt-place.is-meas:screen-value = "yes" .
          return no-apply .
        end .
        v-rvd-on = yes .
      end .
      disable t-asi-srtif with frame d-pl-form .
    end.
END.
ON value-changed OF place-type IN FRAME d-pl-form
DO:
  if place-type:screen-value = "1"
  then do :
    if p-mode = 'ДОБАВЛЕНИЕ':U
    then do :
      enable t-ponton with frame d-pl-form .
      if t-ponton:screen-value = "yes"
      then do :
        enable ponton-mass ponton-height with frame d-pl-form .
      end .
      else do :
        disable ponton-mass ponton-height with frame d-pl-form .
      end .
    end .
  end .
  if place-type:screen-value = "2"
  then do :
    disable t-ponton ponton-mass ponton-height with frame d-pl-form .
  end .
END.
ON value-changed OF t-ponton IN FRAME d-pl-form
DO:
  if t-ponton:screen-value = "yes"
  then do :
    enable ponton-mass ponton-height with frame d-pl-form .
  end .
  else do :
    disable ponton-mass ponton-height with frame d-pl-form .
  end .
END.
ON value-changed OF t-com-vessel IN FRAME d-pl-form
DO:
  if t-com-vessel:screen-value = "yes"
  then do :
    enable b-com-tanks with frame d-pl-form .
    disable t-gate-valve b-gate-valve-tanks with frame d-pl-form .
    if v-not-gas-place
    then do :
      display t-auto-gate-valve with frame d-pl-form.
      if is-main
      then do :
        enable t-auto-gate-valve with frame d-pl-form.
      end .
    end .
  end .
  else do :
    if is-main
    and num-entries(com-tanks) > 1
    then do :
      message substitute('Резервуар №&1 отмечен как "Главный", изменение связки сообщающихся резервуаров невозможно! Исключите из связки все "Не главные" резервуары!', tt-place.loc1)
      view-as alert-box .
      t-com-vessel:screen-value = "yes" .
      return no-apply .
    end .
    if com-tanks > ""
    then do :
      message "Сообщающиеся резервуары будут разъединены! Вы уверены?" view-as alert-box question buttons yes-no update v-ok .
      if v-ok
      then do :
        com-tanks = "" .
        display com-tanks with frame d-pl-form .
        disable b-com-tanks with frame d-pl-form .
        hide v-is-main in frame d-pl-form .
      end .
      else do :
        t-com-vessel:screen-value = "yes" .
        return no-apply .
      end .
    end .
    if v-sug-place
    then do :
      enable t-gate-valve b-gate-valve-tanks with frame d-pl-form .
    end .
    hide t-auto-gate-valve in frame d-pl-form.
  end .
  v-com-vessel-changed = yes .
END.
ON value-changed OF t-auto-gate-valve IN FRAME d-pl-form
DO:
  if t-auto-gate-valve:screen-value = "no"
  then do :
    message "Чек-бокс «Автоматическая задвижка» будет выключен. Расчет плотности не будет рассчитываться на основании анализа убыли объема в резервуаре! Вы уверены?" view-as alert-box question buttons yes-no update v-ok .
    if not v-ok
    then do :
      t-auto-gate-valve:screen-value = "yes" .
      return no-apply .
    end .
  end .
END.
ON value-changed OF t-gate-valve IN FRAME d-pl-form
DO:
  if t-gate-valve:screen-value = "yes"
  then do :
    enable b-gate-valve-tanks with frame d-pl-form .
    disable t-com-vessel b-com-tanks with frame d-pl-form .
  end .
  else do :
    if gate-valve-tanks > ""
    then do :
      gate-valve-tanks = "" .
      display gate-valve-tanks with frame d-pl-form .
      disable b-gate-valve-tanks with frame d-pl-form .
    end .
    enable t-com-vessel b-com-tanks with frame d-pl-form .
  end .
  v-gate-valve-tanks-changed = yes .
END.
ON CHOOSE OF r-sr-izm IN FRAME d-pl-form
DO:
  define variable v-node-code as integer no-undo.
  define variable v-sr-type as character no-undo.
  v-node-code = 0 .
  run ref/sr-izm.w (input parparentproc ,
                    input "b-sel"       ,
                    input 'ПРОСМОТР':U     ,
                    input ""            ,
                    input ""            ,
                    input-output v-node-code,
                    output v-sr-type) no-error.
  if v-node-code <> 0 and v-node-code <> ? then do :
    place-si = v-node-code.
    place-si:screen-value = string(v-node-code).
    find first osn_sr-izmerenia no-lock where osn_sr-izmerenia.node-code = place-si .
    apply "leave" to place-si in frame d-pl-form .
  end.
END.
on entry of place-si-name IN FRAME d-pl-form
do:
  apply "entry" to place-si in frame d-pl-form.
end .
on entry of place-si IN FRAME d-pl-form
do:
  hide place-si-name in frame d-pl-form.
end .
on return of place-si IN FRAME d-pl-form
do:
  apply "leave" to place-si IN FRAME d-pl-form .
end .
on del of place-si in frame d-pl-form
do :
  place-si = ? .
  place-si:screen-value = "?" .
end .
on leave of place-si IN FRAME d-pl-form
do:
  define variable v-old-val as character no-undo .
  v-old-val = string(place-si) .
  find first osn_sr-izmerenia no-lock where osn_sr-izmerenia.node-code = integer(place-si:screen-value) no-error .
  if not available osn_sr-izmerenia
  then do :
    if place-si:screen-value <> "?"
    and place-si:screen-value <> "0"
    then do :
      message ("Не найдено средство измерения с кодом " + place-si:screen-value) view-as alert-box .
      place-si:screen-value = v-old-val .
    end .
    return .
  end .
  place-si-name = osn_sr-izmerenia.sr-model .
  display place-si-name with frame d-pl-form.
  enable place-si-name with frame d-pl-form.
  assign place-si .
end .
ON CHOOSE OF b-mi-dnst IN FRAME d-pl-form
DO:
  define variable v-node-code as integer no-undo.
  define variable v-sr-type-id as character no-undo.
  define variable v-sr-type-izm as character no-undo .
  v-node-code = 0 .
    v-sr-type-izm = "0,1" .
  run ref/sr-izm.w (input parparentproc ,
                    input "b-sel"       ,
                    input 'ПРОСМОТР':U     ,
                    input v-sr-type-izm ,
                    input "dnst"        ,
                    input-output v-node-code,
                    output v-sr-type-id) no-error.
  if v-node-code <> 0 and v-node-code <> ? then do :
    v-mi-dnst = v-node-code.
    v-mi-dnst:screen-value = string(v-node-code).
    find first dnst_sr-izmerenia no-lock where dnst_sr-izmerenia.node-code = v-mi-dnst .
    apply "leave" to v-mi-dnst in frame d-pl-form .
  end.
END.
on entry of v-mi-dnst-name IN FRAME d-pl-form
do:
  apply "entry" to v-mi-dnst in frame d-pl-form.
end .
on entry of v-mi-dnst IN FRAME d-pl-form
do:
  hide v-mi-dnst-name in frame d-pl-form.
end .
on return of v-mi-dnst IN FRAME d-pl-form
do:
  apply "leave" to v-mi-dnst IN FRAME d-pl-form .
end .
on del of v-mi-dnst in frame d-pl-form
do :
  v-mi-dnst = 0 .
  v-mi-dnst:screen-value = "0" .
end .
on leave of v-mi-dnst IN FRAME d-pl-form
do:
  define variable vlog as logical no-undo .
  define variable v-old-val as character no-undo .
  v-old-val = string(v-mi-dnst) .
  if v-mi-dnst:screen-value = "?" then v-mi-dnst:screen-value = "0" .
  find first dnst_sr-izmerenia no-lock where dnst_sr-izmerenia.node-code = integer(v-mi-dnst:screen-value) no-error .
  if not available dnst_sr-izmerenia
  then do :
    if v-mi-dnst:screen-value <> "?"
    and v-mi-dnst:screen-value <> "0"
    then do :
      message ("Не найдено средство измерения с кодом " + v-mi-dnst:screen-value) view-as alert-box .
      v-mi-dnst:screen-value = v-old-val .
    end .
    return .
  end .
  else do :
    if dnst_sr-izmerenia.sr-type-izm = 2
    then do :
      message "Средство измерения является Измерительной Системой!" view-as alert-box .
      v-mi-dnst:screen-value = v-old-val .
      return .
    end .
    if not dnst_sr-izmerenia.sr-density
    then do :
      message "Средство измерения НЕ измеряет плотность!" view-as alert-box .
      v-mi-dnst:screen-value = v-old-val .
      return .
    end .
    if dnst_sr-izmerenia.sr-type-izm = 0
    and dnst_sr-izmerenia.sr-density
    and dnst_sr-izmerenia.sr-temperature
    and rvd-dnstv:screen-value <> rvd-tmp:screen-value
    then do :
      message "Бизнес-процессом не предусмотрено использование неравнозначных положений разрешения РВД по параметрам температура и плотность, " +
              "если автоматизированное СИ для одного из них предназначено для измерения обоих. " +
              "Сохранение неравнозначных положений разрешения РВД по параметрам температура и плотность запрещено. " +
              "Установить значение " + (if rvd-dnstv:screen-value = "yes" then "'Да'" else "'Нет'") + " для РВД по температуре автоматически?"
      view-as alert-box question buttons yes-no update vlog .
      if vlog
      then do :
        rvd-tmp:screen-value = rvd-dnstv:screen-value .
      end .
    end .
  end .
  v-mi-dnst-name = dnst_sr-izmerenia.sr-model .
  display v-mi-dnst-name with frame d-pl-form.
  enable v-mi-dnst-name with frame d-pl-form.
  assign v-mi-dnst .
  if dnst_sr-izmerenia.sr-temperature
  then do :
      v-mi-tmp = v-mi-dnst .
      v-mi-tmp:screen-value = v-mi-dnst:screen-value .
      v-mi-tmp-name = v-mi-dnst-name .
      find first tmp_sr-izmerenia no-lock where tmp_sr-izmerenia.node-code = v-mi-tmp .
      display v-mi-tmp-name with frame d-pl-form.
      enable v-mi-tmp-name with frame d-pl-form.
  end .
end .
ON CHOOSE OF b-mi-lvl IN FRAME d-pl-form
DO:
  define variable v-node-code as integer no-undo.
  define variable v-sr-type as character no-undo.
  v-node-code = 0 .
  run ref/sr-izm.w (input parparentproc ,
                    input "b-sel"       ,
                    input 'ПРОСМОТР':U     ,
                    input "0,1"         ,
                    input "lvl"         ,
                    input-output v-node-code,
                    output v-sr-type) no-error.
  if v-node-code <> 0 and v-node-code <> ? then do :
    v-mi-lvl = v-node-code.
    v-mi-lvl:screen-value = string(v-node-code).
    find first lvl_sr-izmerenia no-lock where lvl_sr-izmerenia.node-code = v-mi-lvl .
    apply "leave" to v-mi-lvl in frame d-pl-form .
  end.
END.
on entry of v-mi-lvl-name IN FRAME d-pl-form
do:
  apply "entry" to v-mi-lvl in frame d-pl-form.
end .
on entry of v-mi-lvl IN FRAME d-pl-form
do:
  hide v-mi-lvl-name in frame d-pl-form.
end .
on return of v-mi-lvl IN FRAME d-pl-form
do:
  apply "leave" to v-mi-lvl IN FRAME d-pl-form .
end .
on del of v-mi-lvl in frame d-pl-form
do :
  v-mi-lvl = 0 .
  v-mi-lvl:screen-value = "0" .
end .
on leave of v-mi-lvl IN FRAME d-pl-form
do:
  define variable v-old-val as character no-undo .
  v-old-val = string(v-mi-lvl) .
  if v-mi-lvl:screen-value = "?" then v-mi-lvl:screen-value = "0".
  find first lvl_sr-izmerenia no-lock where lvl_sr-izmerenia.node-code = integer(v-mi-lvl:screen-value) no-error .
  if not available lvl_sr-izmerenia
  then do :
    if v-mi-lvl:screen-value <> "?"
    and v-mi-lvl:screen-value <> "0"
    then do :
      message ("Не найдено средтсво измерения с кодом " + v-mi-lvl:screen-value) view-as alert-box .
      v-mi-lvl:screen-value = v-old-val .
    end .
    return .
  end .
  else do :
    if lvl_sr-izmerenia.sr-type-izm = 2
    then do :
      message "Средство измерения является Измерительной Системой!" view-as alert-box .
      v-mi-lvl:screen-value = v-old-val .
      return .
    end .
    if not lvl_sr-izmerenia.sr-level
    then do :
      message "Средство измерения НЕ измеряет уровень!" view-as alert-box .
      v-mi-lvl:screen-value = v-old-val .
      return .
    end .
  end .
  v-mi-lvl-name = lvl_sr-izmerenia.sr-model .
  display v-mi-lvl-name with frame d-pl-form.
  enable v-mi-lvl-name with frame d-pl-form.
  assign v-mi-lvl .
end .
ON CHOOSE OF b-mi-tmp IN FRAME d-pl-form
DO:
  define variable v-node-code as integer no-undo.
  define variable v-sr-type-id as character no-undo.
  define variable v-sr-type-izm as character no-undo .
  v-node-code = 0 .
    v-sr-type-izm = "0,1" .
  run ref/sr-izm.w (input parparentproc ,
                    input "b-sel"       ,
                    input 'ПРОСМОТР':U     ,
                    input v-sr-type-izm ,
                    input "tmp"         ,
                    input-output v-node-code,
                    output v-sr-type-id) no-error.
  if v-node-code <> 0 and v-node-code <> ? then do :
    v-mi-tmp = v-node-code.
    v-mi-tmp:screen-value = string(v-node-code).
    find first tmp_sr-izmerenia no-lock where tmp_sr-izmerenia.node-code = v-mi-tmp .
    apply "leave" to v-mi-tmp in frame d-pl-form .
  end.
END.
on entry of v-mi-tmp-name IN FRAME d-pl-form
do:
  apply "entry" to v-mi-tmp in frame d-pl-form.
end .
on entry of v-mi-tmp IN FRAME d-pl-form
do:
  hide v-mi-tmp-name in frame d-pl-form.
end .
on return of v-mi-tmp IN FRAME d-pl-form
do:
  apply "leave" to v-mi-tmp IN FRAME d-pl-form .
end .
on del of v-mi-tmp in frame d-pl-form
do :
  v-mi-tmp = 0   .
  v-mi-tmp:screen-value = "0" .
end .
on del of v-mi-dnst in frame d-pl-form
do :
  v-mi-dnst = 0  .
  v-mi-dnst:screen-value = "0" .
end .
on del of v-mi-lvl in frame d-pl-form
do :
  v-mi-lvl = 0   .
  v-mi-lvl:screen-value = "0" .
end .
on leave of v-mi-tmp IN FRAME d-pl-form
do:
  define variable vlog as logical no-undo .
  define variable v-old-val as character no-undo .
  v-old-val = string(v-mi-tmp) .
  if v-mi-tmp:screen-value =  "?" then v-mi-tmp:screen-value = "0" .
  find first tmp_sr-izmerenia no-lock where tmp_sr-izmerenia.node-code = integer(v-mi-tmp:screen-value) no-error .
  if not available tmp_sr-izmerenia
  then do :
    if v-mi-tmp:screen-value <> "?"
    and v-mi-tmp:screen-value <> "0"
    then do :
      message ("Не найдено средтсво измерения с кодом " + v-mi-tmp:screen-value) view-as alert-box .
      v-mi-tmp:screen-value = v-old-val .
    end .
    return .
  end .
  else do :
    if tmp_sr-izmerenia.sr-type-izm = 2
    then do :
      message "Средство измерения является Измерительной Системой!" view-as alert-box .
      v-mi-tmp:screen-value = v-old-val .
      return .
    end .
    if not tmp_sr-izmerenia.sr-temperature
    then do :
      message "Средство измерения НЕ измеряет температуру!" view-as alert-box .
      v-mi-tmp:screen-value = v-old-val .
      return .
    end .
    if tmp_sr-izmerenia.sr-type-izm = 0
    and tmp_sr-izmerenia.sr-temperature
    and tmp_sr-izmerenia.sr-density
    and rvd-tmp:screen-value <> rvd-dnstv:screen-value
    then do :
      message "Бизнес-процессом не предусмотрено использование неравнозначных положений разрешения РВД по параметрам температура и плотность, " +
              "если автоматизированное СИ для одного из них предназначено для измерения обоих. " +
              "Сохранение неравнозначных положений разрешения РВД по параметрам температура и плотность запрещено. " +
              "Установить значение " + (if rvd-tmp:screen-value = "yes" then "'Да'" else "'Нет'") + " для РВД по плотности автоматически?"
      view-as alert-box question buttons yes-no update vlog .
      if vlog
      then do :
        rvd-dnstv:screen-value = rvd-tmp:screen-value .
      end .
    end .
  end .
  v-mi-tmp-name = tmp_sr-izmerenia.sr-model .
  display v-mi-tmp-name with frame d-pl-form.
  enable v-mi-tmp-name with frame d-pl-form.
  assign v-mi-tmp .
  if tmp_sr-izmerenia.sr-density
  then do :
      v-mi-dnst = v-mi-tmp .
      v-mi-dnst:screen-value = v-mi-tmp:screen-value .
      v-mi-dnst-name = v-mi-tmp-name .
      find first dnst_sr-izmerenia no-lock where dnst_sr-izmerenia.node-code = v-mi-dnst .
      display v-mi-dnst-name with frame d-pl-form.
      enable v-mi-dnst-name with frame d-pl-form.
  end .
end .
ON CHOOSE OF b-com-tanks IN FRAME d-pl-form
DO:
  define variable place-list as character no-undo .
  define buffer cv_place for ub.place .
  define buffer cv_place-attr for ub.place-attr .
  define buffer buf_pl-gds for ub.pl-gds .
  define buffer cv_pl-gds for ub.pl-gds .
  find first buf_pl-gds no-lock where buf_pl-gds.obj-type = tt-place.obj-type
                                  and buf_pl-gds.obj-code = tt-place.obj-code
                                  and buf_pl-gds.pl-code = tt-place.pl-code
                                  no-error .
  if not available buf_pl-gds
  then do :
    return no-apply .
  end .
  run ref/pl-list.w (
                 input parparentproc
                ,input "b-sel,b-mark"
                ,input p-obj-type
                ,input p-obj-code
                ,input 'объект':U
               , input-output place-list).
  if place-list = "cancel"
  then do :
    place-list = '' .
  end .
  if place-list <> '':U then do:
    com-tanks = "" .
    do ii = 1 to num-entries(place-list) :
      find first cv_place no-lock where recid(cv_place) = integer(entry(ii, place-list)) .
      if cv_place.obj-type = tt-place.obj-type
      and cv_place.obj-code = tt-place.obj-code
      and cv_place.pl-code = tt-place.pl-code
      then do :
        message "Нельзя связать резервуар с самим собой!" view-as alert-box .
        next .
      end .
      find first cv_pl-gds no-lock where cv_pl-gds.obj-type = cv_place.obj-type
                                     and cv_pl-gds.obj-code = cv_place.obj-code
                                     and cv_pl-gds.pl-code = cv_place.pl-code
                                     no-error .
      if not available cv_pl-gds
      then do :
        message "Нельзя связать резервуар с резервуаром, на котором нет товара!" view-as alert-box .
        next .
      end .
      if cv_pl-gds.gds-code <> buf_pl-gds.gds-code
      then do :
        message substitute("В сообщающихся резервуарах должен быть указан один товар! Связь с резервуаром №&1 не установлена!", cv_place.loc1) view-as alert-box .
        next .
      end .
      if cv_pl-gds.fact-qnty <> 0
      or cv_pl-gds.free-qnty <> 0
      or cv_pl-gds.cli-free-qnty <> 0
      or cv_pl-gds.cli-fact-qnty <> 0
      then do :
        message substitute("На резервуаре №&1 имеются расчетно-книжные остатки! Связь сообщающихся резервуаров не установлена!", cv_place.loc1) view-as alert-box .
        next .
      end .
      find first cv_place-attr no-lock where cv_place-attr.obj-type = cv_place.obj-type
                                         and cv_place-attr.obj-code = cv_place.obj-code
                                         and cv_place-attr.pl-code  = cv_place.pl-code
                                         and cv_place-attr.attr-code = "place-com-tanks"
                                         no-error .
      if available cv_place-attr
      and cv_place-attr.attr-value > ""
      then do :
        message substitute("Резервуар №&1 уже привязан к резервуару №&2. Связь сообщающихся резервуаров не установлена!", cv_place.loc1, cv_place-attr.attr-value) view-as alert-box .
        next .
      end .
      find first cv_place-attr no-lock where cv_place-attr.obj-type = cv_place.obj-type
                                         and cv_place-attr.obj-code = cv_place.obj-code
                                         and cv_place-attr.pl-code  = cv_place.pl-code
                                         and cv_place-attr.attr-code = "place-gate-valve"
                                         no-error .
      if available cv_place-attr
      and logical(cv_place-attr.attr-value)
      then do :
        message substitute("Резервуар №&1 имеет задвижку. Связь сообщающихся резервуаров не установлена!", cv_place.loc1) view-as alert-box .
        next .
      end .
      if can-find(first pl-pump-nozzle no-lock where pl-pump-nozzle.obj-type = cv_pl-gds.obj-type
                                                 and pl-pump-nozzle.obj-code = cv_pl-gds.obj-code
                                                 and pl-pump-nozzle.pl-code  = cv_pl-gds.pl-code )
      then do :
        message "В сообщающихся резервуарах должна быть одна связка Резервуар – ТРК – Пистолеты по объекту! Связь сообщающихся резервуаров не установлена!" view-as alert-box .
        next .
      end .
      com-tanks = com-tanks + cv_place.loc1 + "," .
    end .
    com-tanks = trim(com-tanks, ",") .
    display com-tanks with frame d-pl-form .
    if com-tanks > ""
    then do :
      is-main = yes .
      v-is-main = "Главный" .
      display v-is-main with frame d-pl-form .
      if v-not-gas-place
      then do :
        enable t-auto-gate-valve with frame d-pl-form .
      end .
    end .
  end.
  v-com-vessel-changed = yes .
END.
ON CHOOSE OF b-gate-valve-tanks IN FRAME d-pl-form
DO:
  define variable place-list as character no-undo .
  define buffer gv_place for ub.place .
  define buffer gv_place-attr for ub.place-attr .
  define buffer buf_pl-gds for ub.pl-gds .
  define buffer gv_pl-gds for ub.pl-gds .
  find first buf_pl-gds no-lock where buf_pl-gds.obj-type = tt-place.obj-type
                                  and buf_pl-gds.obj-code = tt-place.obj-code
                                  and buf_pl-gds.pl-code = tt-place.pl-code
                                  no-error .
  if not available buf_pl-gds
  then do :
    return no-apply .
  end .
  run ref/pl-list.w (
                 input parparentproc
                ,input "b-sel,b-mark"
                ,input p-obj-type
                ,input p-obj-code
                ,input 'объект':U
               , input-output place-list).
  if place-list = "cancel"
  then do :
    place-list = '' .
  end .
  if place-list <> '':U then do:
    gate-valve-tanks = "" .
    do ii = 1 to num-entries(place-list) :
      find first gv_place no-lock where recid(gv_place) = integer(entry(ii, place-list)) .
      if gv_place.obj-type = tt-place.obj-type
      and gv_place.obj-code = tt-place.obj-code
      and gv_place.pl-code = tt-place.pl-code
      then do :
        message "Нельзя связать резервуар с самим собой!" view-as alert-box .
        next .
      end .
      find first gv_pl-gds no-lock where gv_pl-gds.obj-type = gv_place.obj-type
                                     and gv_pl-gds.obj-code = gv_place.obj-code
                                     and gv_pl-gds.pl-code = gv_place.pl-code
                                     no-error .
      if not available gv_pl-gds
      then do :
        message "Нельзя связать резервуар с резервуаром, на котором нет товара!" view-as alert-box .
        next .
      end .
      if gv_pl-gds.gds-code <> buf_pl-gds.gds-code
      then do :
        message substitute("В резервуарах должен быть указан один товар! Связь с резервуаром №&1 не установлена!", gv_place.loc1) view-as alert-box .
        next .
      end .
      find first gv_place-attr no-lock where gv_place-attr.obj-type = gv_place.obj-type
                                         and gv_place-attr.obj-code = gv_place.obj-code
                                         and gv_place-attr.pl-code  = gv_place.pl-code
                                         and gv_place-attr.attr-code = "place-gate-valve-tanks"
                                         no-error .
      if available gv_place-attr
      and gv_place-attr.attr-value > ""
      then do :
        message substitute("Резервуар №&1 уже привязан к резервуару №&2. Связь задвижкой не установлена!", gv_place.loc1, gv_place-attr.attr-value) view-as alert-box .
        next .
      end .
      find first gv_place-attr no-lock where gv_place-attr.obj-type = gv_place.obj-type
                                         and gv_place-attr.obj-code = gv_place.obj-code
                                         and gv_place-attr.pl-code  = gv_place.pl-code
                                         and gv_place-attr.attr-code = "place-com-tanks"
                                         no-error .
      if available gv_place-attr
      and gv_place-attr.attr-value > ""
      then do :
        message substitute("Резервуар №&1 сообщающийся с резервуаром №&2. Связь задвижкой не установлена!", gv_place.loc1, gv_place-attr.attr-value) view-as alert-box .
        next .
      end .
      gate-valve-tanks = gate-valve-tanks + gv_place.loc1 + "," .
    end .
    gate-valve-tanks = trim(gate-valve-tanks, ",") .
    display gate-valve-tanks with frame d-pl-form .
  end.
  v-gate-valve-tanks-changed = yes .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-pl-form:PARENT eq ?
  THEN FRAME d-pl-form:PARENT = ACTIVE-WINDOW.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-pl-form
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame d-pl-form
do:
  apply "help":u to frame d-pl-form .
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame d-pl-form:width - 0.3
                fh            = frame d-pl-form:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
ON WINDOW-CLOSE OF FRAME d-pl-form do :
  define variable vlog as logical no-undo .
  message "Все введенные данные будут утеряны. Вы уверены, что хотите отказаться от внесенных изменений?"
  view-as alert-box question buttons yes-no update vlog .
  if not vlog then return no-apply .
  p-rep-rec = ?.
  APPLY "END-ERROR":U TO SELF.
end .
on "F2" ANYWHERE do:
  define variable vlog as logical no-undo .
  message "Все введенные данные будут утеряны. Вы уверены, что хотите отказаться от внесенных изменений?"
  view-as alert-box question buttons yes-no update vlog .
  if not vlog then return no-apply .
  p-rep-rec = ?.
end .
on "ESC" ANYWHERE do:
  define variable vlog as logical no-undo .
  message "Все введенные данные будут утеряны. Вы уверены, что хотите отказаться от внесенных изменений?"
  view-as alert-box question buttons yes-no update vlog .
  if not vlog then return no-apply .
  p-rep-rec = ?.
end .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  if self:type = "TOGGLE-BOX" then
  self:BGCOLOR = ?.
  assign
  ii = lookup(self:name, v-tab-order).
  assign
  ii = ii + 1
  v-next-widget-name = entry(ii, v-tab-order)
  no-error .
  if error-status:error then do:
    assign
    ii = 1
    v-next-widget-name = entry( ii, v-tab-order)
    .
  end.
  assign
  fh = frame d-pl-form:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        if hh:type = "TOGGLE-BOX":U then do:
          assign
          hh:BGcolor = 1
          .
        end.
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
        APPLY "TAB" to hh.
        return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
end.
END.
ON BACK-TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  assign
  ii = lookup(self:name, v-tab-order).
  .
  assign
  ii = (if ii = 1
        then  num-entries(v-tab-order)
        else ii - 1
        )
  v-next-widget-name = entry(ii, v-tab-order)
  .
  assign
  fh = frame d-pl-form:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        if hh:type = "TOGGLE-BOX":U then do:
          assign
          hh:BGcolor = 1
          .
        end.
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
      APPLY "BACK-TAB" to hh.
      return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
  end.
END.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON RETURN ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
  if v-tab-order <> '' then do:
    assign
    ii = lookup(self:name, v-tab-order).
    if ii = num-entries(v-tab-order) then do:
        APPLY 'CHOOSE' TO b-exit in frame d-pl-form.
        return no-apply.
    end.
    if self:type <> "BUTTON" and
      self:type <> "EDITOR"  then do:
      run proc-move-forward in this-procedure .
      return no-apply.
    end.
    if self:type = "BUTTON" then do:
      APPLY "CHOOSE" to self.
    end.
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame d-pl-form:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return no-apply.
        end.
        else do:
          APPLY "TAB" to hh.
          return no-apply.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
END.
procedure proc-move-forward :
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
do
on error undo, return error
:
  if v-tab-order <> '' then do:
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = lookup(self:name, v-tab-order).
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame d-pl-form:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return.
        end.
        else do:
          assign
          ii = ii + 1
          v-next-widget-name = entry(ii, v-tab-order)
          no-error .
          if error-status:error then do:
            assign
            ii = 1
            v-next-widget-name = entry( ii, v-tab-order)
            .
          end.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
end.
end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON STOP    UNDO MAIN-BLOCK,  LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if p-mode <> 'ИЗМЕНЕНИЕ':U
    and p-mode <> 'ДОБАВЛЕНИЕ':U
    and p-mode <> 'ПРОСМОТР':U then
  do:
    message
      vss-workfile vss-revision vss-description skip
      "Неверный параметр вызова p-mode" p-mode
      view-as alert-box ERROR.
    return error.
  end.
  case p-mode:
    when 'ИЗМЕНЕНИЕ':U then do:
      find first locked_place exclusive-lock
        where recid (locked_place) = p-rep-rec
        no-error .
    end.
    when 'ПРОСМОТР':U then do:
      find first locked_place no-lock
        where recid( locked_place ) = p-rep-rec
        no-error .
      if not available locked_place then do:
        find first locked_place no-lock
          where locked_place.obj-type = p-obj-type
            and locked_place.obj-code = p-obj-code
            and locked_place.pl-code  = p-pl-code
          no-error .
      end.
    end.
  end case.
  if not available locked_place
    and  p-mode <> 'ДОБАВЛЕНИЕ':U
    then
  do:
    message
      vss-workfile vss-revision vss-description skip
      substitute ("Не найдена запись СКЛАДСКОГО МЕСТА &1 &2&3", p-pl-code, p-obj-type, p-obj-code ) skip
      view-as alert-box error .
    undo, return error.
  end.
  for each tt-place:
    delete tt-place.
  end.
  create tt-place.
  if p-mode = 'ДОБАВЛЕНИЕ':U then
  do:
    assign
      tt-place.obj-type = p-obj-type
      tt-place.obj-code = p-obj-code
      .
  end.
  else
  do:
    buffer-copy locked_place to tt-place.
  end.
  v-rvd-is-meas-on = tt-place.is-meas .
  if p-mode <> 'ПРОСМОТР':U then
  do :
    if ( tt-place.max-qnty = 0
      or tt-place.max-qnty = ?
      )
      then
    do:
      assign
        tt-place.chk-max-qnty = false
        .
    end.
  end.
  ii = 0.
  do ii = 1 to num-entries('place-type,place-SI,place-diameter,dead-balance,water-level,dens-prov,place-virtual,place-twice-code,place-sert-urov,place-local,place-error-mass,place-asi-sertif,place-rvd-dnsty,place-rvd-lvl,place-rvd-tmp,place-SI-dens,place-SI-level,place-SI-temp,place-passp-num,place-passp-type,place-dead-high,place-temp-coef,disable-water-alarm,disable-level-alarm,place-ponton,place-ponton-mass,place-ponton-height,place-com-vessel,place-com-tanks,place-is-main,place-gate-valve,place-gate-valve-tanks,place-auto-gate-valve':u,','):
    v-code = entry(ii,'place-type,place-SI,place-diameter,dead-balance,water-level,dens-prov,place-virtual,place-twice-code,place-sert-urov,place-local,place-error-mass,place-asi-sertif,place-rvd-dnsty,place-rvd-lvl,place-rvd-tmp,place-SI-dens,place-SI-level,place-SI-temp,place-passp-num,place-passp-type,place-dead-high,place-temp-coef,disable-water-alarm,disable-level-alarm,place-ponton,place-ponton-mass,place-ponton-height,place-com-vessel,place-com-tanks,place-is-main,place-gate-valve,place-gate-valve-tanks,place-auto-gate-valve':u) .
    run placelib_get-attr  ( input v-code
      ,input p-obj-code
      ,input p-obj-type
      ,input locked_place.pl-code
      ,output v-value
      ,output v-ok      ) no-error.
    case v-code :
      when "place-type" then do :
        if v-ok then place-type = integer(v-value) .
      end.
      when "place-SI" then do :
        if v-ok
        then do :
          place-si = integer(v-value) .
          v-main-mi-old = place-si .
          if v-main-mi-old = ? then v-main-mi-old = 0 .
        end .
      end.
      when "place-diameter" then do :
        if v-ok then place-diameter = decimal(v-value) .
      end.
      when "dead-balance" then do :
        if v-ok then dead-balance = decimal(v-value) .
      end.
      when "water-level" then do :
        if v-ok then water-level = integer(v-value) .
      end.
      when "dens-prov" then do :
        if v-ok then dens-prov = decimal(v-value) .
      end.
      when "place-virtual" then do :
        if v-ok then t-place-virtual = logical(v-value) .
      end.
      when "place-twice-code" then do:
        if v-ok then place-twice-code = v-value .
      end.
      when "place-local" then do :
        if v-ok then place-locat = integer(v-value) .
      end.
      when "place-error-mass" then do :
        if v-value = "" then
        do:
          v-value = "0.15" .
          run placelib_write-attr  (input v-code
            ,input p-obj-code
            ,input p-obj-type
            ,input locked_place.pl-code
            ,input v-value
            ,output v-ok      ) no-error.
        end.
        if v-ok then error-mass = decimal(v-value) .
      end.
      when "place-asi-sertif" then do :
        if v-value = "" then v-value = "no" .
        if v-ok then t-asi-srtif = logical(v-value) .
      end.
      when "place-rvd-dnsty" then do :
        if v-ok
        then do :
          rvd-dnstv = logical(v-value) .
          v-rvd-dnsty-on = rvd-dnstv .
        end .
      end.
      when "place-rvd-lvl" then do :
        if v-ok
        then do :
          rvd-lvl = logical(v-value) .
          v-rvd-lvl-on = rvd-lvl .
        end.
      end.
      when "place-rvd-tmp" then do :
        if v-ok
        then do :
          rvd-tmp = logical(v-value) .
          v-rvd-temp-on = rvd-tmp .
        end .
      end.
      when "place-SI-dens" then do :
        if v-ok
        then do :
          v-mi-dnst = integer(v-value) .
          v-dnst-mi-old = v-mi-dnst .
          if v-dnst-mi-old = ? then v-dnst-mi-old = 0 .
          find first dnst_sr-izmerenia no-lock where dnst_sr-izmerenia.node-code = v-mi-dnst no-error .
        end .
      end.
      when "place-SI-level" then do :
        if v-ok
        then do :
          v-mi-lvl = integer(v-value) .
          v-lvl-mi-old = v-mi-lvl .
          if v-lvl-mi-old = ? then v-lvl-mi-old = 0 .
          find first lvl_sr-izmerenia no-lock where lvl_sr-izmerenia.node-code = v-mi-lvl no-error .
        end .
      end.
      when "place-SI-temp" then do :
        if v-ok
        then do :
          v-mi-tmp = integer(v-value) .
          v-tmp-mi-old = v-mi-tmp .
          if v-tmp-mi-old = ? then v-tmp-mi-old = 0 .
          find first tmp_sr-izmerenia no-lock where tmp_sr-izmerenia.node-code = v-mi-tmp no-error .
        end .
      end.
      when "place-passp-num" then do:
        if v-ok then place-passp-num = v-value .
      end.
      when "place-passp-type" then do:
        if v-ok then place-passp-type = v-value .
      end.
      when "place-dead-high" then do:
        if v-ok then place-dead-high = decimal(v-value) .
      end.
      when "place-temp-coef" then do:
        if v-ok then place-temp-coef = decimal(v-value) .
      end.
      when "place-ponton" then do :
        if v-ok then t-ponton = logical(v-value) .
      end.
      when "place-ponton-mass" then do:
        if v-ok then ponton-mass = decimal(v-value) no-error .
      end.
      when "place-ponton-height" then do:
        if v-ok then ponton-height = decimal(v-value) no-error .
      end.
      when "place-com-vessel" then do :
        if v-ok then t-com-vessel = logical(v-value) .
      end.
      when "place-com-tanks" then do:
        if v-ok then com-tanks = v-value no-error .
      end.
      when "place-is-main" then do:
        if v-ok then is-main = logical(v-value) no-error .
      end.
      when "place-gate-valve" then do :
        if v-ok then t-gate-valve = logical(v-value) .
      end.
      when "place-gate-valve-tanks" then do:
        if v-ok then gate-valve-tanks = v-value no-error .
      end.
      when "place-auto-gate-valve" then do :
        if v-ok
        then do :
          t-auto-gate-valve = logical(v-value) .
          v-old-auto-gate-valve = t-auto-gate-valve .
        end .
      end.
    end case.
  end.
  run Myenable in this-procedure .
  wait-for go of frame d-pl-form.
end.
run disable_UI in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME d-pl-form.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY t-place-virtual t-asi-srtif rvd-dnstv rvd-lvl rvd-tmp place-type
          place-locat error-mass place-si dead-balance water-level place-diameter
          dens-prov place-twice-code v-mi-dnst
          v-mi-lvl v-mi-tmp place-passp-num place-passp-type
          place-dead-high place-temp-coef
          t-ponton ponton-mass ponton-height
      WITH FRAME d-pl-form.
  IF AVAILABLE tt-place THEN
    DISPLAY tt-place.loc1 tt-place.loc2 tt-place.loc3 tt-place.loc4
          tt-place.pl-name tt-place.is-meas tt-place.pl-code tt-place.issue-year
          tt-place.start-date tt-place.add-qnty tt-place.max-qnty tt-place.PS tt-place.chk-max-qnty
      WITH FRAME d-pl-form.
  ENABLE b-exit b-quit B-hist b-help tt-place.loc1 tt-place.loc2 tt-place.loc3
         tt-place.loc4 tt-place.pl-name t-place-virtual tt-place.is-meas
         rvd-dnstv rvd-lvl rvd-tmp tt-place.issue-year place-type
         tt-place.start-date place-locat tt-place.add-qnty error-mass
         tt-place.max-qnty place-si r-sr-izm dead-balance water-level place-diameter
         dens-prov place-twice-code tt-place.chk-max-qnty
         tt-place.PS place-passp-num place-passp-type place-dead-high place-temp-coef
         t-ponton ponton-mass ponton-height
      WITH FRAME d-pl-form.
END PROCEDURE.
PROCEDURE Myenable :
  run enable_UI in this-procedure .
  assign
    v-tab-order = "loc1,loc2,loc3,loc4,pl-name,is-meas,"
                  + "issue-year,start-date,add-qnty,max-qnty,"
                  + "ps,place-type,place-SI,r-sr-izm,v-mi-dnst,b-mi-dnst,v-mi-lvl,b-mi-lvl,v-mi-tmp,b-mi-tmp,"
                  + "place-diameter,dead-balance,place-dead-high,place-temp-coef,dens-prov,t-place-virtual,place-twice-code,t-sert-urov,place-passp-num,place-passp-type".
  if p-mode = 'ПРОСМОТР':U then do:
    disable
      all
      with frame d-pl-form .
    hide
      b-exit
      in frame d-pl-form .
    assign
      b-quit:label  = "&Выход"
      b-quit:column = 1
      .
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then
  do:
    hide
      tt-place.pl-code
      in frame d-pl-form .
  end.
  assign
    frame d-pl-form:title = substitute("Складское место &1 на объекте : &2&3 &4", tt-place.pl-code, p-obj-type, p-obj-code, p-mode)
    .
  if tt-place.is-meas then do:
    enable t-asi-srtif with frame d-pl-form .
  end.
  enable v-mi-dnst b-mi-dnst with frame d-pl-form .
  enable v-mi-lvl b-mi-lvl with frame d-pl-form .
  enable v-mi-tmp b-mi-tmp with frame d-pl-form .
  for first dop_sr-izmerenia no-lock where dop_sr-izmerenia.node-code = v-mi-lvl :
    v-mi-lvl-name = dop_sr-izmerenia.sr-model .
    display v-mi-lvl-name with frame d-pl-form.
  end .
  if p-mode <> 'ПРОСМОТР':U then enable v-mi-lvl-name with frame d-pl-form.
  if v-mi-lvl = 0 then v-mi-lvl = ? .
  for first dop_sr-izmerenia no-lock where dop_sr-izmerenia.node-code = v-mi-dnst :
    v-mi-dnst-name = dop_sr-izmerenia.sr-model .
    display v-mi-dnst-name with frame d-pl-form.
  end .
  if p-mode <> 'ПРОСМОТР':U then enable v-mi-dnst-name with frame d-pl-form.
  if v-mi-dnst = 0 then v-mi-dnst = ? .
  for first dop_sr-izmerenia no-lock where dop_sr-izmerenia.node-code = v-mi-tmp :
    v-mi-tmp-name = dop_sr-izmerenia.sr-model .
    display v-mi-tmp-name with frame d-pl-form.
  end .
  if p-mode <> 'ПРОСМОТР':U then enable v-mi-tmp-name with frame d-pl-form.
  if v-mi-tmp = 0 then v-mi-tmp = ? .
  for first sr-izmerenia no-lock where sr-izmerenia.node-code = place-si :
    place-si-name = sr-izmerenia.sr-model .
    display place-si-name with frame d-pl-form.
  end .
  if p-mode <> 'ПРОСМОТР':U then enable place-si-name with frame d-pl-form.
  if place-si = 0 then place-si = ? .
  apply "value-changed" to place-type .
  hide t-com-vessel com-tanks b-com-tanks v-is-main gate-valve-tanks t-gate-valve b-gate-valve-tanks t-auto-gate-valve in frame d-pl-form .
  if p-mode = 'ИЗМЕНЕНИЕ':U
  then do :
    disable
      place-locat
      tt-place.max-qnty
      dead-balance
      place-si
      place-si-name
      r-sr-izm
      place-diameter
      place-dead-high
      place-temp-coef
      dens-prov
    with frame d-pl-form .
    if place-type = 1
    then do :
      disable
        t-ponton
        ponton-mass
        ponton-height
      with frame d-pl-form .
    end .
  end .
  run check-sug-NP-par .
END PROCEDURE.
PROCEDURE check-sug-NP-par :
  define buffer buf_pl-gds for ub.pl-gds .
  define variable c-value as character no-undo .
  define variable c-type  as character no-undo .
  v-not-gas-place = no .
  v-sug-place = no .
  find first buf_pl-gds no-lock where buf_pl-gds.obj-type = tt-place.obj-type
                                  and buf_pl-gds.obj-code = tt-place.obj-code
                                  and buf_pl-gds.pl-code = tt-place.pl-code
                                  no-error .
  if not available buf_pl-gds
  then do :
    return .
  end .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
    (input  buf_pl-gds.gds-code
    ,input  'fuel-type':U
    ,output c-value
    ,output c-type)
  no-error.
  if c-value = 'lgas':U
  then do :
    v-sug-place = yes .
    display t-com-vessel com-tanks b-com-tanks v-is-main gate-valve-tanks t-gate-valve b-gate-valve-tanks with frame d-pl-form.
    enable t-com-vessel t-gate-valve with frame d-pl-form.
    if t-com-vessel
    then do :
      if is-main then v-is-main = "Главный" . else v-is-main = "Не главный" .
      display v-is-main with frame d-pl-form.
      enable com-tanks b-com-tanks with frame d-pl-form.
      com-tanks:read-only in frame d-pl-form = yes.
      if com-tanks > "" then disable b-com-tanks with frame d-pl-form.
      disable t-gate-valve b-gate-valve-tanks with frame d-pl-form.
    end .
    if t-gate-valve
    then do :
      enable b-gate-valve-tanks with frame d-pl-form.
      disable t-com-vessel b-com-tanks with frame d-pl-form.
    end .
  end .
  else
  if c-value = 'metan':U
  or c-value = 'propan':U
  then do :
  end .
  else do :
    v-not-gas-place = yes .
    display t-com-vessel com-tanks b-com-tanks v-is-main with frame d-pl-form.
    enable t-com-vessel with frame d-pl-form.
    if t-com-vessel
    then do :
      if is-main then v-is-main = "Главный" . else v-is-main = "Не главный" .
      display v-is-main with frame d-pl-form.
      enable com-tanks b-com-tanks with frame d-pl-form.
      com-tanks:read-only in frame d-pl-form = yes.
      if com-tanks > "" then disable b-com-tanks with frame d-pl-form.
      display t-auto-gate-valve with frame d-pl-form.
      if is-main
      then do :
        enable t-auto-gate-valve with frame d-pl-form.
      end .
      else do :
        disable t-auto-gate-valve with frame d-pl-form.
      end .
    end .
  end .
END PROCEDURE.
