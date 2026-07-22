    DEFINE INPUT  PARAMETER parParentProc AS WIDGET-HANDLE NO-UNDO.
    DEFINE INPUT  PARAMETER bttns         AS CHARACTER     NO-UNDO.
    DEFINE INPUT  PARAMETER iGds-code     AS INTEGER       NO-UNDO.
    define INPUT  PARAMETER loc-mode      as character     no-undo .
    DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision$":U .
    DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author$":U .
    DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date$":U .
    DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile$":U .
    DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive$":U .
    DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "Изображения".
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE verify-ini-entry:
DEFINE INPUT  PARAMETER ini-key-name     as character no-undo.
DEFINE INPUT  PARAMETER ini-section-name as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text   as character no-undo.
DEFINE INPUT  PARAMETER silence          as logical no-undo.
DEFINE OUTPUT PARAMETER ini-entry-value  as character no-undo INIt ?.
define variable v-mess as character no-undo .
get-key-value section ini-section-name key ini-key-name value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "spl"
then
get-key-value section ini-section-name key "splall" value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "sav"
then
get-key-value section ini-section-name key "savall" value ini-entry-value.
if ini-entry-value = ? then do:
  assign
  v-mess = substitute("Ошибка ini - файла:&1Секция &2&1Ключ &3&1&4"
                    , chr(10)
                    , ini-section-name
                    , ini-key-name
                    , error-msg-text).
    if not silence then do:
      message
      v-mess
      view-as alert-box ERROR  .
      return error.
    end.
    else do:
      return error v-mess.
    end.
end.
END PROCEDURE.
PROCEDURE verify-file:
DEFINE INPUT  PARAMETER filename       as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text as character no-undo.
DEFINE INPUT  PARAMETER silence        as logical no-undo.
DEFINE OUTPUT PARAMETER found          as logical no-undo.
file-info:file-name = filename.
found = NOT (file-info:full-pathname = ?).
if NOT found  then do:
  if not silence then do:
    message error-msg-text
    view-as alert-box ERROR.
    return error.
  end.
  else return error error-msg-text.
end.
END PROCEDURE.
DEFINE TEMP-TABLE ttImgBar NO-UNDO
    FIELD fID    AS CHARACTER
    FIELD fFrame AS HANDLE
    FIELD fImage AS HANDLE
    FIELD fXPix  AS INTEGER
    FIELD fTrgs  AS HANDLE
    FIELD fFile  AS CHARACTER
    FIELD fNum   AS INTEGER
    INDEX i1 fXPix
    INDEX i2 fID
    INDEX i3 fNum
    .
DEFINE VARIABLE mBoxForAdd     AS INTEGER     NO-UNDO INITIAL 0.
DEFINE VARIABLE mImageSID      AS INTEGER     NO-UNDO.
DEFINE VARIABLE mImageMax      AS INTEGER     NO-UNDO.
DEFINE VARIABLE mImgBarFrame   AS HANDLE      NO-UNDO.
DEFINE VARIABLE mImgBarLib     AS HANDLE      NO-UNDO.
DEFINE VARIABLE mImgSlider     AS HANDLE      NO-UNDO.
DEFINE VARIABLE mImgSliderTrgs AS HANDLE      NO-UNDO.
DEFINE VARIABLE mImageCurID    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImageCurNum   AS INTEGER     NO-UNDO.
DEFINE VARIABLE mImageList     AS LONGCHAR    NO-UNDO.
DEFINE VARIABLE mLogical       AS LOGICAL     NO-UNDO.
DEFINE VARIABLE mEnab          AS LOGICAL     NO-UNDO.
    if loc-mode <> 'ПРОСМОТР':U then
    mEnab = yes.
    else mEnab = no.
    .
if loc-mode = 'ПРОСМОТР':U then do:
DEFINE VARIABLE mF_select_photo AS LOGICAL     NO-UNDO.
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_select_photo':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output mF_select_photo
    )  .
end.
IF NOT mF_select_photo THEN RETURN.
end.
else do:
DEFINE VARIABLE mF_update_photo AS LOGICAL     NO-UNDO.
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_update_photo':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output mF_update_photo
    )  .
end.
end.
DEFINE VARIABLE mImagePath     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImageDir      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImagePreDir   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImageTrash    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mPhotomgd      AS LOGICAL     NO-UNDO.
DEFINE VARIABLE mImagePh       AS LOGICAL     NO-UNDO.
define variable v-param-types   as character  no-undo.
define variable v-value-char    as character  no-undo.
define variable v-val-date      as date       no-undo.
define variable v-val-decimal   as decimal    no-undo.
define variable v-val-integer   as integer    no-undo.
define variable v-val-logical   as logical    no-undo.
define variable v-tthd          as handle     no-undo.
RUN imagelist_loaddef IN THIS-PROCEDURE NO-ERROR.
PROCEDURE imagelist_loaddef:
    DEFINE VARIABLE vPar-val       AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vPar-type      AS CHARACTER   NO-UNDO.
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'photo':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output vPar-val
  ,output vPar-type
  ) no-error .
        mImagePh = LOOKUP (vPar-val, "true,yes":U) > 0.
    IF mImagePh THEN .
    ELSE RETURN.
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'ph-dir':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  NO
  ,output vPar-val
  ,output vPar-type
  ) no-error .
    IF LENGTH (vPar-val) = 0 THEN
        RUN verify-ini-entry("ph-dir":U, "REP-SETS":U, "":U, YES, OUTPUT vPar-val) NO-ERROR.
    IF LENGTH (vPar-val) = 0 THEN vPar-val = "c:\temp\":U.
    ASSIGN
        mImagePath   = RIGHT-TRIM (vPar-val, "~\~/":U)
        mImagePath   = mImagePath + (IF LENGTH (mImagePath) > 0 THEN "\":U ELSE "":U)
        mImagePreDir = mImagePath
        mImageDir    = mImagePreDir
        mImageTrash  = mImagePath + "trash\":U
        .
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
            run adm/shattri.p (
        input "get":U
        ,input  '':U
        ,input  0
        ,input  'gds-ref':U
        ,input  'shema-foto':U
        ,output v-value-char
        ,output v-val-date
        ,output v-val-decimal
        ,output v-val-integer
        ,output v-val-logical
        ,output v-param-types
        ,INPUT-OUTPUT table-handle v-tthd
        ) no-error.
        delete object v-tthd.
        mPhotomgd = IF v-val-integer = 2 then yes else no.
END PROCEDURE.
PROCEDURE imagelist_decode:
    DEFINE INPUT  PARAMETER iImageList AS LONGCHAR  NO-UNDO.
    DEFINE INPUT  PARAMETER iImageGdsCode AS int    NO-UNDO.
    DEFINE OUTPUT PARAMETER oImageList AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE vCh                AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vInt               AS INTEGER   NO-UNDO.
    ASSIGN
        oImageList = iImageList
        .
    DO vInt = 1 TO NUM-ENTRIES (iImageList, ",":U):
        vCh =ENTRY (vInt, iImageList, ",":U).
        IF SUBSTRING (vCh, 1, 2) = "~\~\":U THEN .
        ELSE
        DO:
            ASSIGN
                vCh = REPLACE (vCh, "~/":U, "\":U)
                vCh = REPLACE (vCh, "~\":U, "\":U)
                .
            IF SUBSTRING (vCh, 2, 2) = ":\":U OR vCh BEGINS mImageDir THEN .
            ELSE vCh = mImagePreDir + (if mPhotomgd then string(iImageGdsCode) + "\":U else '':U ) +  vCh.
            ENTRY (vInt, oImageList, ",":U) = vCh.
        END.
    END.
END PROCEDURE.
PROCEDURE imagelist_encode:
    DEFINE INPUT  PARAMETER iImageList AS LONGCHAR  NO-UNDO.
    DEFINE OUTPUT PARAMETER oImageList AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE vCh                AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vInt               AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vLen               AS INTEGER   NO-UNDO.
    ASSIGN
        oImageList = iImageList
        vLen       = LENGTH (mImageDir)
        .
    DO vInt = 1 TO NUM-ENTRIES (iImageList, ",":U):
        vCh =ENTRY (vInt, iImageList, ",":U).
        IF LENGTH (vCh) > 0 AND vLen > 0 AND vCh BEGINS mImageDir THEN
            ENTRY (vInt, oImageList, ",":U) =
                SUBSTRING (vCh, vLen + 1).
    END.
END PROCEDURE.
IF mImagePh THEN .
    ELSE RETURN.
IF mPhotomgd THEN
    mImageDir = SUBSTITUTE ("&1&2\":U, mImagePreDir, iGds-code).
RUN verify-file (mImagePath,
    "Не найден каталог " + mImagePath + chr(10) +
    "параметр конфигурации ph-dir",
    NO, OUTPUT mLogical) NO-ERROR.
IF ERROR-STATUS:ERROR OR NOT mLogical THEN RETURN ERROR.
FUNCTION ImgXPix RETURNS INTEGER
  (iNum AS INTEGER)  FORWARD.
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 9 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход ":L
     SIZE 12 BY 1.
DEFINE VARIABLE F-FileName AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN NATIVE
     SIZE 63.5 BY 1 NO-UNDO.
DEFINE IMAGE CurrentImage
     STRETCH-TO-FIT RETAIN-SHAPE
     SIZE 62.5 BY 15.5.
DEFINE RECTANGLE f-Marker
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 4.25 BY .13.
DEFINE VARIABLE t-preview AS LOGICAL INITIAL no
     LABEL "Preview"
     VIEW-AS TOGGLE-BOX
     SIZE 11.5 BY .58 NO-UNDO.
DEFINE FRAME d-images
     b-exit AT ROW 1 COL 1
     b-add AT ROW 1 COL 13
     b-del AT ROW 1 COL 22.13
     t-preview AT ROW 20.25 COL 52.5 WIDGET-ID 20
     F-FileName AT ROW 21 COL 1 NO-LABEL WIDGET-ID 12
     CurrentImage AT ROW 5.25 COL 1.5 WIDGET-ID 2
     f-Marker AT ROW 2.08 COL 1.13 WIDGET-ID 16
     SPACE(59.86) SKIP(19.86)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Изображения":L.
DEFINE FRAME FrameX
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 2.25
         SIZE 5 BY .75 WIDGET-ID 100.
ASSIGN FRAME FrameX:FRAME = FRAME d-images:HANDLE.
ASSIGN
       FRAME d-images:SCROLLABLE       = FALSE.
ASSIGN
       F-FileName:READ-ONLY IN FRAME d-images        = TRUE.
ON CURSOR-LEFT OF FRAME d-images
ANYWHERE DO:
    mImgSlider:SCREEN-VALUE = STRING (INTEGER (mImgSlider:SCREEN-VALUE) - 1) NO-ERROR.
    APPLY "VALUE-CHANGED":U TO mImgSlider.
    RETURN NO-APPLY.
END.
ON CURSOR-RIGHT OF FRAME d-images
ANYWHERE DO:
    mImgSlider:SCREEN-VALUE = STRING (INTEGER (mImgSlider:SCREEN-VALUE) + 1) NO-ERROR.
    APPLY "VALUE-CHANGED":U TO mImgSlider.
    RETURN NO-APPLY.
END.
ON BACK-TAB OF FRAME FrameX
ANYWHERE DO:
  APPLY "ENTRY":U    TO SELF.
  APPLY "TAB":U      TO b-del IN FRAME d-images.
  APPLY "BACK-TAB":U TO FOCUS.
  RETURN NO-APPLY.
END.
ON TAB OF FRAME FrameX
ANYWHERE DO:
  APPLY "ENTRY":U TO SELF.
  APPLY "TAB":U   TO b-del IN FRAME d-images.
  RETURN NO-APPLY.
END.
ON CHOOSE OF b-add IN FRAME d-images
DO:
  IF NOT mF_update_photo THEN RETURN NO-APPLY.
  DEFINE VARIABLE vFile AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE vLog  AS LOGICAL     NO-UNDO.
  SYSTEM-DIALOG GET-FILE vFile
      FILTERS         "Картинки" "*.jpg,*.png,*.bmp,*.gif":U,         "Картинки *.jpg" "*.jpg":U,         "Картинки *.png" "*.png":U,         "Картинки *.bmp" "*.bmp":U,         "Картинки *.gif" "*.gif":U,         "Все файлы" "*.*":U
      MUST-EXIST
      TITLE "Выбор файла"
      UPDATE vLog
      .
  IF NOT vLog THEN RETURN NO-APPLY.
  RUN ImageAdd IN THIS-PROCEDURE (vFile).
END.
ON CHOOSE OF b-del IN FRAME d-images
DO:
  IF NOT mF_update_photo THEN RETURN NO-APPLY.
  RUN ImageDel IN THIS-PROCEDURE.
END.
ON VALUE-CHANGED OF t-preview IN FRAME d-images
DO:
  DEFINE BUFFER ttImgBar FOR ttImgBar.
  IF SELF:CHECKED = NO THEN RETURN NO-APPLY.
  IF SELF:SENSITIVE THEN
  DO:
      MESSAGE
          "Установить выбранное изображение в качестве используемого для предварительного просмотра?" SKIP (1)
          "(Изображение будет перемещено в начало списка)"
          VIEW-AS ALERT-BOX QUESTION BUTTONS OK-CANCEL TITLE "Вопрос" UPDATE vLog AS LOGICAL.
      IF vLog <> YES THEN
      DO:
          SELF:CHECKED = NO.
          RETURN NO-APPLY.
      END.
  END.
  FOR FIRST ttImgBar WHERE ttImgBar.fID = mImageCurID:
      ttImgBar.fFrame:X = 0.
      RUN DynaTrig IN THIS-PROCEDURE (ttImgBar.fFrame, "END-MOVE":U) NO-ERROR.
  END.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-images:PARENT eq ?
THEN FRAME d-images:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME d-images APPLY "END-ERROR":U TO SELF.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
if mF_select_photo <> no or mF_update_photo <> no then do:
    RUN enable_ui.
    WAIT-FOR GO OF FRAME d-images.
end.
END.
DELETE PROCEDURE mImgSliderTrgs NO-ERROR.
FOR EACH ttImgBar:
    DELETE PROCEDURE ttImgBar.fTrgs NO-ERROR.
    DELETE OBJECT ttImgBar.fImage   NO-ERROR.
    DELETE OBJECT ttImgBar.fFrame   NO-ERROR.
    DELETE ttImgBar.
END.
RUN disable_ui.
PROCEDURE disable_UI :
  HIDE FRAME d-images.
  HIDE FRAME FrameX.
END PROCEDURE.
PROCEDURE DynaTrig :
    DEFINE INPUT PARAMETER iHandle  AS HANDLE    NO-UNDO.
    DEFINE INPUT PARAMETER iTrigger AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vInt AS INTEGER NO-UNDO.
    DEFINE BUFFER ttImgBar FOR ttImgBar.
    CASE iHandle:NAME:
        WHEN "ImgSlider":U THEN
            CASE iTrigger:
                WHEN "VALUE-CHANGED":U THEN
                    FOR FIRST ttImgBar NO-LOCK WHERE ttImgBar.fNum = INTEGER (iHandle:SCREEN-VALUE):
                        RUN DynaTrig IN THIS-PROCEDURE (ttImgBar.fFrame, "SELECTION":U) NO-ERROR.
                    END.
            END CASE.
        WHEN "Image":U THEN
            CASE iTrigger:
                WHEN "END-MOVE":U THEN
                DO:
                    FOR FIRST ttImgBar WHERE ttImgBar.fID = iHandle:PRIVATE-DATA:
                        ttImgBar.fXPix = iHandle:X.
                    END.
                    ASSIGN
                        vInt       = mImageMax
                        mImageList = "":U
                        .
                    FOR EACH ttImgBar BY ttImgBar.fXPix DESCENDING:
                        ASSIGN
                            ttImgBar.fFrame:X = ImgXPix (vInt)
                            ttImgBar.fNum     = vInt
                            vInt              = vInt - 1
                            .
                    END.
                    FOR EACH ttImgBar:
                        ttImgBar.fXPix = ttImgBar.fFrame:X.
                    END.
                    ASSIGN
                        mImageCurID  = "":U
                        mImageCurNum = 0
                        .
                    RUN DynaTrig IN THIS-PROCEDURE (iHandle, "SELECTION":U) NO-ERROR.
                    RUN ImageListDump IN THIS-PROCEDURE.
                END.
                WHEN "SELECTION":U THEN
                    IF mImageCurID <> iHandle:PRIVATE-DATA THEN
                        RUN SelectImage IN THIS-PROCEDURE (?, iHandle:PRIVATE-DATA) NO-ERROR.
                WHEN "MOUSE-SELECT-DBLCLICK":U THEN
                DO:
                    IF mImageCurID <> iHandle:PRIVATE-DATA THEN
                        RUN SelectImage IN THIS-PROCEDURE (?, iHandle:PRIVATE-DATA) NO-ERROR.
                    IF f-FileName:SCREEN-VALUE IN FRAME d-images = "":U THEN
                        APPLY "CHOOSE":U TO b-add.
                    RETURN NO-APPLY.
                END.
            END CASE.
    END CASE.
END PROCEDURE.
PROCEDURE enable_UI :
    ENABLE
        b-exit
        b-add     WHEN loc-mode <> 'ПРОСМОТР':U
        b-del     WHEN loc-mode <> 'ПРОСМОТР':U
        f-marker
        t-preview WHEN loc-mode <> 'ПРОСМОТР':U
        WITH FRAME  d-images.
    DISPLAY f-marker WITH FRAME d-images.
    RUN ImgBarInit IN THIS-PROCEDURE.
    RUN ImageListLoad IN THIS-PROCEDURE.
    RUN SensButtons   IN THIS-PROCEDURE.
    IF mBoxForAdd = 8 OR (mBoxForAdd = 0 AND mImageMax = 0) THEN
    RUN ImgBarAdd IN THIS-PROCEDURE ("":U).
    RUN ImgSlider IN THIS-PROCEDURE.
    RUN SelectImage IN THIS-PROCEDURE (1, ?) NO-ERROR.
 END PROCEDURE.
PROCEDURE ImageAdd :
DEFINE INPUT PARAMETER iFile AS CHARACTER NO-UNDO.
    DEFINE BUFFER ttImgBar FOR ttImgBar.
    DEFINE VARIABLE vNum  AS INTEGER     NO-UNDO.
    DEFINE VARIABLE vFile AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vTmp  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vInt  AS INTEGER     NO-UNDO.
    DEFINE VARIABLE vCh2  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vExt  AS CHARACTER   NO-UNDO.
    RUN verify-file (mImagePreDir, "":U, YES, OUTPUT mLogical) NO-ERROR.
    IF ERROR-STATUS:ERROR OR NOT mLogical THEN
    DO:
        OS-CREATE-DIR VALUE (mImagePreDir).
        IF OS-ERROR <> 0 THEN
        DO:
            MESSAGE SUBSTITUTE ("Ошибка &1 создания поддиректории~n&2",
                                OS-ERROR, mImagePreDir)
                VIEW-AS ALERT-BOX ERROR.
            RETURN NO-APPLY.
        END.
    END.
    RUN verify-file (mImageDir, "":U, YES, OUTPUT mLogical) NO-ERROR.
    IF ERROR-STATUS:ERROR OR NOT mLogical THEN
    DO:
        OS-CREATE-DIR VALUE (mImageDir).
        IF OS-ERROR <> 0 THEN
        DO:
            MESSAGE SUBSTITUTE ("Ошибка &1 создания поддиректории~n&2",
                                OS-ERROR, mImageDir)
                VIEW-AS ALERT-BOX ERROR.
            RETURN NO-APPLY.
        END.
    END.
    IF iFile BEGINS mImageDir THEN vFile = iFile.
    ELSE
    DO:
        ASSIGN
            vTmp = SUBSTRING (iFile, 1 +
                MAXIMUM (R-INDEX (iFile, "~\":U), R-INDEX (iFile, "~/":U)))
            vInt = R-INDEX (vTmp, ".":U)
            vExt = SUBSTRING (vTmp, vInt)
            vTmp = SUBSTRING (vTmp, 1, vInt - 1)
            vFile = mImageDir + vTmp + vExt
            .
        IF SEARCH (vFile) <> ? THEN
        bl0:
        DO:
            MESSAGE
                "Файл с таким именем уже существует" SKIP
                vFile SKIP (1)
                "Сгенерировать новое имя файла и продолжить?"
                VIEW-AS ALERT-BOX WARNING BUTTONS OK-CANCEL
                TITLE "Предупреждение" UPDATE mLogical.
            IF mLogical = NO THEN RETURN NO-APPLY.
            DO WHILE YES:
                bl1:
                DO:
                    vInt = R-INDEX (vTmp, "#":U).
                    IF vInt > 0 THEN
                    DO:
                        vCh2 = SUBSTRING (vTmp, vInt + 1).
                        IF LENGTH (TRIM (vCh2, "0123456789":U)) = 0 THEN
                        DO:
                            ASSIGN
                                vTmp  = SUBSTRING (vTmp, 1, vInt) +
                                    STRING (INTEGER (vCh2) + 1)
                                vFile = mImageDir + vTmp + vExt
                                .
                            LEAVE bl1.
                        END.
                    END.
                    ASSIGN
                        vTmp  = vTmp + "#1":U
                        vFile = mImageDir + vTmp + vExt
                        .
                END.
                IF SEARCH (vFile) = ? THEN LEAVE bl0.
            END.
        END.
        OS-COPY VALUE (iFile) VALUE (vFile).
        IF OS-ERROR <> 0 THEN
        DO:
            MESSAGE SUBSTITUTE ("Ошибка &1 копирования файла~n&2~n&3",
                                OS-ERROR, iFile, vFile)
                VIEW-AS ALERT-BOX ERROR.
            RETURN NO-APPLY.
        END.
    END.
    FOR LAST ttImgBar WHERE ttImgBar.fFile = "":U:
        ASSIGN
            vNum           = ttImgBar.fNum
            ttImgBar.fFile = vFile
            .
        ttImgBar.fImage:LOAD-IMAGE (vFile) NO-ERROR.
    END.
    IF vNum = 0 THEN
    DO:
        RUN ImgBarAdd IN THIS-PROCEDURE (vFile).
        vNum = mImageMax.
    END.
    IF mBoxForAdd = 8 OR (mBoxForAdd = 0 AND mImageMax = 0) THEN
        RUN ImgBarAdd IN THIS-PROCEDURE ("":U).
    RUN ImgSlider IN THIS-PROCEDURE.
    RUN SelectImage IN THIS-PROCEDURE (vNum, ?).
    RUN ImageListDump IN THIS-PROCEDURE.
    RUN SensButtons IN THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE ImageDel :
DEFINE VARIABLE vNum   AS INTEGER     NO-UNDO.
DEFINE VARIABLE vFile1 AS CHARACTER   NO-UNDO.
DEFINE VARIABLE vFile2 AS CHARACTER   NO-UNDO.
DEFINE VARIABLE vExt   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE vInt   AS INTEGER     NO-UNDO.
    DEFINE BUFFER ttImgBar FOR ttImgBar.
    MESSAGE
        "Удалить изображение?" SKIP
        VIEW-AS ALERT-BOX QUESTION BUTTONS OK-CANCEL
        TITLE "Вопрос" UPDATE mLogical.
    IF mLogical = NO THEN RETURN NO-APPLY.
    RUN verify-file (mImageTrash, "":U, YES, OUTPUT mLogical) NO-ERROR.
    IF ERROR-STATUS:ERROR OR NOT mLogical THEN
    DO:
        OS-CREATE-DIR VALUE (mImageTrash).
        IF OS-ERROR <> 0 THEN
        DO:
            MESSAGE SUBSTITUTE ("Ошибка &1 создания поддиректории~n&2",
                                OS-ERROR, mImageTrash)
                VIEW-AS ALERT-BOX ERROR.
            RETURN NO-APPLY.
        END.
    END.
    ASSIGN
        vFile1 = F-FileName:SCREEN-VALUE IN FRAME d-images
        vFile2 = SUBSTRING (vFile1, 1 +
                MAXIMUM (R-INDEX (vFile1, "~\":U), R-INDEX (vFile1, "~/":U)))
        vInt   = R-INDEX (vFile2, ".":U)
        vExt   = SUBSTRING (vFile2, vInt)
        vFile2 = SUBSTRING (vFile2, 1, vInt - 1)
        vFile2 = mImageTrash + vFile2 + " ":U +
                REPLACE (STRING (NOW, "99999999 hh:mm:ss":U), ":":U, "":U) + vExt
        .
    OS-RENAME VALUE (vFile1) VALUE (vFile2).
    IF OS-ERROR <> 0 AND LENGTH (SEARCH (vFile1)) > 0 THEN
    DO:
        MESSAGE SUBSTITUTE ("Ошибка &1 перемещения файла~n&2~n&3",
                                OS-ERROR, vFile1, vFile2)
            VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    FOR FIRST ttImgBar WHERE ttImgBar.fID = mImageCurID:
        DELETE PROCEDURE ttImgBar.fTrgs NO-ERROR.
        DELETE OBJECT ttImgBar.fImage   NO-ERROR.
        DELETE OBJECT ttImgBar.fFrame   NO-ERROR.
        IF ttImgBar.fNum = mImageMax THEN vNum = mImageMax - 1.
        ELSE vNum = ttImgBar.fNum + 1.
        mImageMax = mImageMax - 1.
        DELETE ttImgBar.
    END.
    IF mImageMax = 0 THEN
    DO:
        IF mBoxForAdd = 8 OR (mBoxForAdd = 0 AND mImageMax = 0) THEN
        RUN ImgBarAdd IN THIS-PROCEDURE ("":U).
        vNum = mImageMax.
    END.
    RUN ImgSlider IN THIS-PROCEDURE.
    ASSIGN
        mImageCurID  = "":U
        mImageCurNum = 0
        .
    RUN SelectImage IN THIS-PROCEDURE (vNum, ?).
    FOR FIRST ttImgBar NO-LOCK WHERE ttImgBar.fNum = vNum:
        RUN DynaTrig IN THIS-PROCEDURE (ttImgBar.fFrame, "END-MOVE":U) NO-ERROR.
    END.
    IF mImageMax = 0 THEN
    DO:
        CurrentImage:LOAD-IMAGE ("":U) IN FRAME d-images NO-ERROR.
        RUN ImageListDump IN THIS-PROCEDURE.
    END.
    RUN SensButtons IN THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE ImageListDump :
  IF NOT mF_update_photo THEN RETURN.
    DEFINE BUFFER ttImgBar FOR ttImgBar.
    mImageList = "":U.
    FOR EACH ttImgBar NO-LOCK:
        IF LENGTH (ttImgBar.fFile) > 0 THEN
            mImageList =
                (IF LENGTH (mImageList) > 0 THEN
                    mImageList + ",":U ELSE "":U)
                + ttImgBar.fFile
            .
    END.
    RUN imagelist_encode IN THIS-PROCEDURE (INPUT mImageList, OUTPUT mImageList).
    RUN gds-attr-write (iGds-code, "image-list":U, mImageList).
END PROCEDURE.
PROCEDURE ImageListLoad :
    DEFINE VARIABLE vImageList AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vInt       AS INTEGER     NO-UNDO.
    RUN gds-attr-value (iGds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
    mImageList = "":U.
    RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, iGds-code, OUTPUT vImageList).
    DO vInt = 1 TO NUM-ENTRIES (vImageList, ",":U):
        vCh =ENTRY (vInt, vImageList, ",":U).
        RUN ImgBarAdd IN THIS-PROCEDURE (vCh).
    END.
END PROCEDURE.
PROCEDURE ImgBarAdd PRIVATE :
    DEFINE INPUT PARAMETER iFile AS CHARACTER NO-UNDO.
    DEFINE BUFFER ttImgBar FOR ttImgBar.
    CREATE ttImgBar.
    ASSIGN
        mImageSID      = mImageSID + 1
        mImageMax      = mImageMax + 1
        ttImgBar.fXPix = ImgXPix (mImageMax)
        ttImgBar.fID   = STRING (mImageSID)
        ttImgBar.fNum  = mImageMax
        ttImgBar.fFile = iFile
        .
    RUN ref\dynatrig.p PERSISTENT SET ttImgBar.fTrgs.
    CREATE FRAME ttImgBar.fFrame ASSIGN
        NAME             = "Image":U
        THREE-D          = YES
        FRAME            = mImgBarFrame
        PRIVATE-DATA     = ttImgBar.fID
        WIDTH-PIXELS     = 34
        HEIGHT-PIXELS    = mImgBarFrame:HEIGHT-PIXELS - 2
        Y                = 0
        X                = ttImgBar.fXPix
        MOVABLE          = YES AND mEnab
        SELECTABLE       = YES
        MANUAL-HIGHLIGHT = YES
        HIDDEN           = NO
        SENSITIVE        = YES
        VISIBLE          = YES
    TRIGGERS:
        ON "END-MOVE":U  ANYWHERE PERSISTENT RUN DynaTrig IN ttImgBar.fTrgs
            ("END-MOVE":U ).
        ON "SELECTION":U ANYWHERE PERSISTENT RUN DynaTrig IN ttImgBar.fTrgs
            ("SELECTION":U).
        ON "MOUSE-SELECT-DBLCLICK":U ANYWHERE PERSISTENT RUN DynaTrig IN ttImgBar.fTrgs
            ("MOUSE-SELECT-DBLCLICK":U).
    END TRIGGERS.
    RUN SetHandle IN ttImgBar.fTrgs (ttImgBar.fFrame).
    CREATE IMAGE ttImgBar.fImage ASSIGN
        FRAME          = ttImgBar.fFrame
        WIDTH-PIXELS   = 32
        HEIGHT-PIXELS  = 32
        STRETCH-TO-FIT = YES
        RETAIN-SHAPE   = YES
        VISIBLE        = YES
        .
    ttImgBar.fImage:LOAD-IMAGE (ttImgBar.fFile) NO-ERROR.
    IF LENGTH (ttImgBar.fFile) > 0 THEN
        mImageList =
            (IF LENGTH (mImageList) > 0 THEN mImageList + ",":U ELSE "":U)
            + ttImgBar.fFile.
    RELEASE ttImgBar.
END PROCEDURE.
PROCEDURE ImgBarInit PRIVATE :
    DEFINE VARIABLE vBorderTop     AS INTEGER   NO-UNDO.
    IF NOT VALID-HANDLE (mImgBarFrame) THEN
    DO:
        RUN ref\dynatrig.p PERSISTENT SET mImgSliderTrgs.
        mImgBarFrame = FRAME FrameX:HANDLE.
        ASSIGN
            mImgBarFrame:WIDTH-PIXELS  = FRAME d-images:VIRTUAL-WIDTH-PIXELS - 16
            mImgBarFrame:HEIGHT-PIXELS = 2 + (34) + vBorderTop
            mImgBarFrame:HIDDEN        = NO
            mImgBarFrame:SENSITIVE     = YES
            mImgBarFrame:VISIBLE       = YES
            .
        DO WITH FRAME d-images:
            ASSIGN
                f-marker:WIDTH-PIXELS = 34
                f-marker:X            = 1
                f-marker:Y            = MAX (1, mImgBarFrame:Y - f-marker:HEIGHT-PIXELS)
                .
        END.
    END.
END PROCEDURE.
PROCEDURE ImgSlider :
    DEFINE VARIABLE vMax AS INTEGER INITIAL 2 NO-UNDO.
    IF mImageMax > 1 THEN
    DO:
        IF VALID-HANDLE (mImgSlider) THEN DELETE OBJECT mImgSlider.
        vMax = mImageMax.
    END.
    IF NOT VALID-HANDLE (mImgSlider) THEN
    DO:
        CREATE SLIDER mImgSlider ASSIGN
            NAME             = "ImgSlider":U
            TIC-MARKS        = "TOP":U
            FREQUENCY        = 1
            HORIZONTAL       = TRUE
            FRAME            = FRAME d-images:HANDLE
            MAX-VALUE        = vMax
            MIN-VALUE        = 1
            HEIGHT-PIXELS    = mImgBarFrame:HEIGHT-PIXELS + 26
            WIDTH-PIXELS     = ImgXPix (vMax) + 34
            X                = mImgBarFrame:X
            Y                = mImgBarFrame:Y
            NO-CURRENT-VALUE = YES
            TRIGGERS:
                ON "VALUE-CHANGED":U  ANYWHERE PERSISTENT RUN DynaTrig IN mImgSliderTrgs
                    ("VALUE-CHANGED":U).
            END TRIGGERS.
        RUN SetHandle IN mImgSliderTrgs (mImgSlider:HANDLE).
    END.
    IF mImageMax > 1 THEN
        ASSIGN
            mImgSlider:HIDDEN    = NO
            mImgSlider:SENSITIVE = YES
            mImgSlider:VISIBLE   = YES
            .
    ELSE
        ASSIGN
            mImgSlider:HIDDEN    = YES
            mImgSlider:SENSITIVE = NO
            mImgSlider:VISIBLE   = NO
            .
    mImgSlider:MOVE-TO-BOTTOM ().
END PROCEDURE.
PROCEDURE SelectImage :
    DEFINE INPUT PARAMETER iNum AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER iID  AS CHARACTER NO-UNDO.
    DEFINE BUFFER ttImgBar FOR ttImgBar.
    FOR EACH ttImgBar NO-LOCK:
        IF ttImgBar.fNum = iNum OR ttImgBar.fID = iID THEN
        DO WITH FRAME d-images:
            ASSIGN
                f-marker:X               = ttImgBar.fFrame:X
                f-FileName:SCREEN-VALUE  = ttImgBar.fFile
                mImgSlider:SCREEN-VALUE  = STRING (ttImgBar.fNum)
                ttImgBar.fFrame:SELECTED = NO
                mImageCurID              = ttImgBar.fID
                mImageCurNum             = ttImgBar.fNum
                t-preview:CHECKED        = (ttImgBar.fNum = 1)
                t-preview:SENSITIVE      = (ttImgBar.fNum > 1) AND mEnab
                .
            CurrentImage:LOAD-IMAGE (ttImgBar.fFile) NO-ERROR.
        END.
        ELSE
            ttImgBar.fFrame:SELECTED = NO.
    END.
END PROCEDURE.
PROCEDURE SensButtons :
    DO WITH FRAME d-images:
        ASSIGN
            b-add:SENSITIVE = (ImgXPix (mImageMax + 1) + 34 < mImgBarFrame:WIDTH-PIXELS)
                AND mEnab
            b-del:SENSITIVE = mImageMax > 0
                AND mEnab
            .
    END.
END PROCEDURE.
FUNCTION ImgXPix RETURNS INTEGER
  (iNum AS INTEGER) :
  RETURN 1 + (iNum - 1) * (34 + 3).
END FUNCTION.
