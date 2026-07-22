block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-atrlst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/g-atrlst.p $":U .
define variable vss-description as character no-undo init "Пакетное изменение по списку глобальных атрибутов товара".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable parhost-code like ub.sysconf.host-code no-undo .
define variable parobj-type like ub.clients.obj-type no-undo .
define variable parobj-code like ub.clients.obj-code no-undo .
define variable pardelete-ok as logical no-undo .
DEFINE VARIABLE var-object as character no-undo init 'goods-attr':U.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION CIntBinS RETURNS CHARACTER(input vl_int as integer):
def var vl_bin as char no-undo init "".
if vl_int < 0 OR vl_int = ? then return ?.
do while vl_int > 0:
  assign
  vl_bin = (if vl_int modulo 2 = 0
              then "0":U
              else "1":U) + vl_bin
  vl_int = truncate(vl_int / 2,0).
end.
return fill( "0":U, 32 - length(vl_bin)) + vl_bin .
END FUNCTION.
FUNCTION BinMask RETURNS LOGICAL(input vl_int as integer,
                                 input vl_binm as character):
DEFINE VARIABLE vl_bin as character no-undo.
DEFINE VARIABLE ii as integer no-undo.
DEFINE VARIABLE ii-len as integer no-undo.
DEFINE VARIABLE ii-lenm as integer no-undo.
DEFINE VARIABLE mchar as character no-undo.
DEFINE VARIABLE ichar as character no-undo.
if vl_binm = ? then return ?.
vl_bin = CIntBinS(vl_int).
if vl_bin = ? then return ?.
assign
vl_binm = LEFT-TRIM(vl_binm, "X":U)
ii-lenm = LENGTH(vl_binm)
ii-len = LENGTH(vl_bin) - ii-lenm
.
if II-LENM > 32 THEN RETURN ?.
DO II = 1 to II-LENm:
  assign
  mchar = SUBSTR(vl_binm, ii, 1)
  ichar = SUBSTR(vl_bin, ii + ii-len, 1)
  .
  IF not (MCHAR = "0":u or MCHAR = "1":u or MCHAR = "X":u) then return ?.
  IF ichar <> mchar AND mchar <> "X":U then return no.
END.
return yes.
END FUNCTION.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define SHARED temp-table temp-attr no-undo
field attr-code like ub.gds-obj-attr.attr-code
field attr-value like ub.gds-obj-attr.attr-value
field host-code as integer
field obj-type as character
field obj-code as integer
field user-can-edit as log
field code as char
field action as logical
field other-inf as character
index pi is  unique primary
attr-code host-code obj-type obj-code ASCENDING
index action
action
.
procedure tempattr-value :
 do
  on error undo, return error
  :
    define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define input  parameter p-host-code as integer no-undo .
    define input  parameter p-obj-type as character no-undo .
    define input  parameter p-obj-code as integer no-undo .
    define input  parameter p-mode      as character no-undo .
    define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_temp-attr for temp-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable jj               as integer   no-undo .
    define variable v-spr            as logical   no-undo .
    define variable v-spr-name       as character no-undo .
    define variable v-spr-param      as character no-undo .
    define variable v-setted         as logical   no-undo .
    case var-object:
      when 'gds-obj-attr':U
      then do:
        run gdsoattr-name in this-procedure
          (input  p-code
          ,output p-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'gds-host-attr':U
      then do:
        run gdshattr-name in this-procedure
          (input  p-code
          ,output p-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'clients-attr':U
      then do:
        run clntattr-code in this-procedure
          (input  p-code
          ,output p-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'goods-attr':U
      then do:
        run gds-attr-name in this-procedure
          (input  p-code
          ,output p-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      otherwise do:
        undo, return error .
      end.
    end case.
    if error-status :error
    then do:
      undo, return error return-value .
    end.
    if v-user-can-edit
    then do:
      do jj = 1 to num-entries(v-other, chr(47)):
        if entry(1, entry(jj, v-other, chr(47)), "=":U) = "spr":U then do:
          assign
          v-spr-name = entry(2, entry(jj, v-other, chr(47)), "=":U)
          .
        end.
        if entry(1, entry(jj, v-other, chr(47)), "=":U) = "spr-param":U then do:
          assign
          v-spr-param = entry(2, entry(jj, v-other, chr(47)), "=":U)
          .
        end.
     end.
      if v-spr-name <> "":U then do:
        if p-mode = "change":U
        then do:
          find first buf_temp-attr no-lock where
                    buf_temp-attr.attr-code = p-code
                and buf_temp-attr.host-code = p-host-code
                and buf_temp-attr.obj-type = p-obj-type
                and buf_temp-attr.obj-code = p-obj-code
            no-error .
          if avail buf_temp-attr then do:
            assign
              p-value =  buf_temp-attr.attr-value
            .
          end.
          else do:
            assign
              p-value = if p-type = 'L':U then "no":U else ""
            .
          end.
        end.
        CASE var-object:
          when 'gds-obj-attr':U then do:
            if v-spr-param = "":U then do:
              run value (
                          v-spr-name)
                          in this-procedure (
                                                input 0
                                              ,input parobj-type
                                              ,input parobj-code
                                              ,input-output p-value
                                              ,output v-setted) no-error .
            end.
            else do:
              run value (
                          v-spr-name)
                          in this-procedure (
                                                input 0
                                              ,input parobj-type
                                              ,input parobj-code
                                              ,input v-spr-param
                                              ,input-output p-value
                                              ,output v-setted) no-error .
            end.
            if error-status :error then do:
              undo, return error "Неизвестный справочник для получения значения атрибут товара на объекте" + " " + p-code .
            end.
          end.
          when 'clients-attr':U then do:
          if v-spr-param = "":U then do:
            run   value ( v-spr-name ) in this-procedure
                (  input 0
                  ,input parobj-type
                  ,input parobj-code
                  ,input-output p-value
                  ,output v-setted )
                  no-error .
          end.
          end.
          END CASE.
        if v-setted = no then do:
          return "not-set":U.
        end.
        assign
        v-spr = yes
        .
      end.
    end.
    if not v-spr then do:
      find first buf_temp-attr no-lock where
                buf_temp-attr.attr-code = p-code
            and buf_temp-attr.host-code = p-host-code
            and buf_temp-attr.obj-type = p-obj-type
            and buf_temp-attr.obj-code = p-obj-code
        no-error .
      if avail buf_temp-attr then do:
        assign
          p-value =  buf_temp-attr.attr-value
        .
      end.
      else do:
        assign
          p-value = if p-type = 'L':U then "no":U else ""
        .
      end.
    end.
  end.
end procedure.
procedure tempattr-write :
  do
  on error undo, return error
  :
    define input parameter p-add      as logical no-undo .
    define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define input parameter p-host-code as integer no-undo .
    define input parameter p-obj-type as character no-undo .
    define input parameter p-obj-code as integer no-undo .
    define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
    define input parameter p-action   like temp-attr.action no-undo .
    define buffer buf_temp-attr for temp-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable var-region  as character no-undo.
    DEFINE VARIABLE v-sel-vals as character no-undo .
    DEFINE VARIABLE v-sel-labels as character no-undo .
    define variable varhost-code like ub.sysconf.host-code no-undo.
    define variable varobj-type like ub.clients.obj-type no-undo.
    define variable varobj-code like ub.clients.obj-code no-undo.
    define variable choice as integer no-undo .
    case var-object:
      when 'gds-obj-attr':U
      then do:
        run gdsoattr-name in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'gds-host-attr':U
      then do:
        run gdshattr-name in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'clients-attr':U
      then do:
        run clntattr-code in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'goods-attr':U
      then do:
        run gds-attr-name in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      otherwise do:
        undo, return error .
      end.
    END CASE.
    if error-status :error then do:
      undo, return error return-value .
    end.
    if not v-user-can-edit then do:
      message
      "Запрещено редактировать атрибут" v-label
      view-as alert-box error .
      undo, return error.
    end.
    find first buf_temp-attr exclusive-lock where
               buf_temp-attr.attr-code = p-code
            and buf_temp-attr.host-code = p-host-code
            and buf_temp-attr.obj-type = p-obj-type
            and buf_temp-attr.obj-code = p-obj-code no-error .
    if not available buf_temp-attr then do:
      create buf_temp-attr .
      assign
        buf_temp-attr.attr-code = p-code
        buf_temp-attr.host-code = p-host-code
        buf_temp-attr.obj-type = p-obj-type
        buf_temp-attr.obj-code = p-obj-code
        buf_temp-attr.attr-value = p-value
        buf_temp-attr.action = p-action
        buf_temp-attr.code = v-label
        buf_temp-attr.other-inf = v-other
        no-error
      .
    end.
    ELSE
    ASSIGN
    buf_temp-attr.attr-value = p-value no-error.
  end.
end procedure.
procedure tempattr-exist :
  do
  on error undo, return error
  :
    define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define input parameter p-host-code as integer no-undo .
    define input parameter p-obj-type as character no-undo .
    define input parameter p-obj-code as integer no-undo .
    define output parameter p-exist    as logical no-undo .
    define output parameter p-action as logical no-undo .
    define buffer buf_temp-attr for temp-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-range          as integer   no-undo .
    case var-object:
      when 'gds-obj-attr':U then do:
        run gdsoattr-name in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'gds-host-attr':U
      then do:
        run gdshattr-name in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'clients-attr':U
      then do:
        run clntattr-code in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'goods-attr':U then do:
        run gds-attr-name in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      otherwise do:
        undo, return error .
      end.
    end case.
    if error-status :error
    then do:
      undo, return error return-value .
    end.
    find first buf_temp-attr no-lock where
               buf_temp-attr.attr-code = p-code
            and buf_temp-attr.host-code = p-host-code
            and buf_temp-attr.obj-type = p-obj-type
            and buf_temp-attr.obj-code = p-obj-code no-error .
    if available buf_temp-attr then do:
      P-EXIST = YES.
      p-action = buf_temp-attr.action.
    end.
  end.
end procedure.
procedure tempattr-delete :
  do
  on error undo, return error
  :
    define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define input parameter p-host-code as integer no-undo .
    define input parameter p-obj-type as character no-undo .
    define input parameter p-obj-code as integer no-undo .
    define output parameter p-deleted  as logical no-undo .
    define buffer buf_temp-attr for temp-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-range          as integer   no-undo .
    case var-object:
      when 'gds-obj-attr':U
      then do:
        run gdsoattr-name in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'gds-host-attr':U
      then do:
        run gdshattr-name in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'clients-attr':U
      then do:
        run clntattr-code in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      when 'goods-attr':U
      then do:
        run gds-attr-name in this-procedure
          (input  p-code
          ,output v-type
          ,output v-format
          ,output v-label
          ,output v-user-can-edit
          ,output v-output-display
          ,output v-other
          ) no-error .
      end.
      otherwise do:
        undo, return error .
      end.
    END CASE.
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_temp-attr exclusive-lock where
               buf_temp-attr.attr-code = p-code
            and buf_temp-attr.host-code = p-host-code
            and buf_temp-attr.obj-type = p-obj-type
            and buf_temp-attr.obj-code = p-obj-code no-error .
    if not available buf_temp-attr then do:
      P-DELETED = NO.
    end.
    ELSE DO:
       delete buf_temp-attr.
       P-DELETED = YES.
    END.
  end.
end procedure.
define variable v-no-ask as logical no-undo .
define variable v-view-log as logical no-undo .
define variable log-file-name                as character      no-undo init "g-atrlst.txt".
define variable v-stop                       as logical        no-undo .
define variable v-choice as integer no-undo .
DEFINE VARIABLE num-rec as integer no-undo .
DEFINE VARIABLE num-rec-ok as integer no-undo .
define variable v-mes as character no-undo .
define variable v-ok as logical no-undo .
assign
parhost-code = integer(entry(1, p-parameter, chr(4)))
parobj-type  = entry(2, p-parameter, chr(4))
parobj-code = integer(entry(3, p-parameter, chr(4)))
pardelete-ok = logical(entry(4, p-parameter, chr(4)))
no-error
.
if error-status:error then do:
 run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При изменении глобальных атрибутов товара по списку товаров произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action7   as character no-undo .
  define variable v-printed7       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При изменении глобальных атрибутов товара по списку товаров произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'g-atrlst.txt')
    ,input  7
    ,output v-user-action7
    ,output v-printed7
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'g-atrlst.txt').
end.
  return .
end.
run write-log  in p-log-handle(
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Изменение глобальных атрибутов товара по списку товаров")).
_gds-list:
for each gds-list
  ON ERROR undo, NEXT:
    num-rec = num-rec + 1.
    v-ok = false.
    run check-actg in this-procedure (
                                       input gds-list.grp-code
                                      ,input gds-list.gds-code
                                      ,input parobj-code
                                      ,input parobj-type
                                      ,output v-ok )  no-error .
    if v-ok = true then do :
      run do-changes in this-procedure (
                                        input gds-list.gds-code
                                        ) no-error .
    end.
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input return-value
                                          ).
      assign
      v-view-log = yes.
      if v-no-ask  then do:
        run gbl/d-askw.w (
                      input "Изменение глобальных атрибутов товара  по списку товаров"
                      ,input substitute("Товар с кодом &1 - не удалось провести изменение атрибутов товара на объекте"
                                      , gds-list.gds-code
                                      )
                      ,input "|"
                      ,input ("Продолжить|" +
                            "Продолжить и больше не запрашивать подтверждения на продолжение|" +
                            "Прекратить")
                      ,input "||"
                      ,input 1
                      ,input 3
                      ,output v-choice).
        if v-choice = 3 then do:
          leave.
        end.
        if v-choice = 2 then do:
          assign
          v-no-ask = yes.
        end.
      end.
    end.
    else do:
      num-rec-ok = num-rec-ok + 1.
      if pardelete-ok then delete gds-list.
    end.
    run show-counter in p-log-handle .
    run write-counter in p-log-handle (substitute("Обработано &1 из них успешно &2"
                                                , num-rec
                                                , num-rec-ok
                                                )) no-error.
    run get-stop-state in p-log-handle (
        output v-stop
    ).
    if v-stop then do:
      leave _gds-list.
    end.
END.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пакетное изменение глобальных атрибутов по списку товаров завершено: из &1 товаров списка успешно изменено &2", num-rec, num-rec-ok )).
.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При изменении атрибутов товара на объекте по списку товаров произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action9   as character no-undo .
  define variable v-printed9       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При изменении атрибутов товара на объекте по списку товаров произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'g-atrlst.txt')
    ,input  7
    ,output v-user-action9
    ,output v-printed9
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'g-atrlst.txt').
end.
procedure do-changes :
define input parameter pargds-code like ub.goods.gds-code no-undo .
DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE var-deleted as logical no-undo .
define variable v-check as character no-undo .
define variable v-correct as logical no-undo .
define variable v-error-code as character no-undo .
define variable jj as integer no-undo .
    _main:
  do
  on error undo, return error
  :
    _temp-attr:
    for each temp-attr no-lock
        on error undo _main, return error:
      do jj = 1 to num-entries(temp-attr.other-inf, chr(47)):
        if entry(1, entry(jj, temp-attr.other-inf, chr(47)), "=":U) = "check-ext":U then do:
          assign
          v-check = string(entry(2, entry(jj, temp-attr.other-inf, chr(47)), "=":U))
          .
        end.
      end.
      if v-check <> "":U then do:
        assign
        v-correct = no
        v-error-code = "":U.
        run value(v-check)(
                          input pargds-code
                          ,input attr-value
                          ,input (if temp-attr.action = yes then 'ИЗМЕНЕНИЕ':U else 'удаление':U)
                          ,output v-correct
                          ,output v-error-code) no-error.
        if error-status:error
        or not v-correct  then do:
          assign v-mes = substitute("товар с кодом &1: ошибка при проверке корректности задаваемого значения глобального атрибута товара &2&3:&4 &4&3"  +                    "Обратитесь к администратору системы"                     , gds-list.gds-code                    , temp-attr.attr-value                    , chr(10)                        , error-status:get-message(1)                    , return-value ).
          undo _main, return error v-mes.
        end.
      end.
      CASE temp-attr.action:
        when yes then do:
          run gds-attr-write in this-procedure(
                                                input pargds-code,
                                                input temp-attr.attr-code,
                                                input temp-attr.attr-value
                                                    )  no-error.
           if error-status:error  then do:
             assign v-mes = substitute("товар с кодом &1: ошибка при записи глобального атрибута товара &2&3:&4 &5&3"  +                    "Обратитесь к администратору системы"                     , gds-list.gds-code                    , temp-attr.attr-value                    , chr(10)                        , error-status:get-message(1)                    , return-value ).
             undo _main, return error v-mes.
           end.
        end.
        when no then do:
          var-deleted = no.
          run gds-attr-delete in this-procedure(
                                                input pargds-code,
                                                input temp-attr.attr-code,
                                                output var-deleted
                                                    )  no-error.
           if error-status:error  then do:
             assign v-mes = substitute("товар с кодом &1: ошибка при удалении глобального атрибута товара &2&3:&4 &5&3"  +                    "Обратитесь к администратору системы"                     , gds-list.gds-code                    , temp-attr.attr-value                    , chr(10)                        , error-status:get-message(1)                    , return-value ).
             undo _main, return error v-mes.
           end.
         end.
      END CASE.
    end.
  end.
end procedure.
procedure check-actg :
define input parameter p-grp-code as integer no-undo.
define input parameter p-gds-code as integer no-undo.
define input parameter p-obj-code as integer no-undo.
define input parameter p-obj-type as character no-undo.
define output parameter p-ok as logical no-undo.
define variable glog as logical no-undo.
do
on error undo, return error
:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  p-grp-code
    ,input  0
    ,input  false
    ,output glog
    )  .
end.
    if glog then do:
      assign
        p-ok = true.
    end.
    else do :
      find first gds-grp no-lock
           where gds-grp.node-code = p-grp-code no-error.
      v-mes = substitute("товар с кодом &1, &2&3: У вас отсутствует глобальное право на изменение товара в привязке к группе товаров &4"
                   , p-gds-code
                   , p-obj-type
                   , p-obj-code
                   , (string(gds-grp.node-code) + " " + gds-grp.node-name)
                    ).
      undo,return error v-mes.
    end.
end.
end procedure.
