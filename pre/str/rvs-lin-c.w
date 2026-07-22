DEFINE TEMP-TABLE tt-rvs-line NO-UNDO LIKE c-rvs-line
field meas-calc-qnty     AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0
field meas-calc-dens     AS DECIMAL FORMAT "9.9999999999":U INITIAL 0
field meas-cli-calc-qnty AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0
field izmer-density      AS DECIMAL FORMAT "9.9999999999":U INITIAL 0
.
define  input parameter parparentproc   as handle    no-undo .
define  input parameter p-code-rec-line as recid     no-undo .
define  input parameter parmode         as character no-undo .
define  input parameter partitle        as character no-undo .
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Экран работы со строкой сверки":U.
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable ptrlprop-denstclc      as character no-undo initial 'shft_rvs-inc':U .
define variable ptrlprop-inpptrl       as character no-undo initial 'weight':U .
define variable ptrlprop-expptrl       as character no-undo initial 'volume':U .
define variable ptrlprop-autopump      as logical   no-undo initial false .
define variable ptrlprop-avtinvpm      as logical   no-undo initial false .
define variable ptrlprop-rvsnmter      as logical   no-undo initial false .
define variable ptrlprop-olddens       as logical   no-undo initial false .
define variable ptrlprop-invclipt      as integer   no-undo initial ? .
define variable ptrlprop-algrvspt      as integer   no-undo initial 1 .
define variable ptrlprop-temp-for-pomi as integer   no-undo initial 1 .
define variable ptrlprop-algoincome as integer no-undo init 0.
define variable ptrlprop-mand-choice-autocar as logical no-undo init false.
define variable ptrlprop-Delta-mass-horiz      as character no-undo .
define variable ptrlprop-Delta-mass-vert       as character no-undo .
define variable ptrlprop-calc-free-vol as logical no-undo init false.
define variable ptrlprop-calc-free-vol-sug as logical no-undo init false.
define variable ptrlprop-trn-reas-sug as logical no-undo init true.
define variable ptrlprop-rvd-own-nb as logical no-undo init false.
define variable ptrlprop-qr-scan-time as integer no-undo init 5000 .
define variable ptrlprop-block-nozzle as logical no-undo init false.
define variable ptrlprop-timeout-block-nozzle as integer no-undo init 5 .
define variable ptrlprop-autopump-skip-time as integer no-undo init 0 .
procedure get-ptrl-prop :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1 (get-ptrl-prop). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-ptrl-prop). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-ptrl-prop). endkey", vss-workfile )
  :
    define variable par-type          as character no-undo.
    define variable v-value-character as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as integer   no-undo .
    define variable v-value-logical   as logical   no-undo .
    for each thbjattr_thbj-attr
    :
      delete thbjattr_thbj-attr .
    end.
    run adm/shattri.p
      ( input "get":U
      , input p-obj-type
      , input p-obj-code
      , input 'petrol':U
      , input  ""
      , output v-value-character
      , output v-value-date
      , output v-value-decimal
      , output v-value-integer
      , output v-value-logical
      , output par-type
      , input-output table thbjattr_thbj-attr
      ) no-error .
    for each thbjattr_thbj-attr
    on error undo, return error return-value
    :
      case thbjattr_thbj-attr.prop-code :
        when 'denstclc':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-denstclc = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'expptrl':U then do:
          if lookup( thbjattr_thbj-attr.property-value-character, 'volume,weight,volume+,weight+':U ) > 0
            and thbjattr_thbj-attr.prop-value-type = 'character':U
          then do:
            assign
              ptrlprop-expptrl = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'inpptrl':U then do:
          if lookup( thbjattr_thbj-attr.property-value-character, 'volume,weight,volume+,weight+':U ) > 0
            and thbjattr_thbj-attr.prop-value-type = 'character':U
          then do:
            assign
              ptrlprop-inpptrl = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'autopump':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-autopump = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'rvsnmter':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-rvsnmter = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'avtinvpm':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-avtinvpm = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'invclipt':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-invclipt = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'olddens':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-olddens = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'algrvspt':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-algrvspt = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'temp-for-pomi':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-temp-for-pomi = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'algoincome':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-algoincome = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'mand-choice-autocar':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-mand-choice-autocar = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'block-nozzle':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-block-nozzle = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'timeout-block-nozzle':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-timeout-block-nozzle = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'Delta-mass-horiz':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-Delta-mass-horiz = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'Delta-mass-vert':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-Delta-mass-vert = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'calc-free-vol':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-calc-free-vol = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'calc-free-vol-sug':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-calc-free-vol-sug = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'trn-reas-sug':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-trn-reas-sug = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
              when 'rvd-own-nb':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-rvd-own-nb = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'qr-scan-time':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-qr-scan-time = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'autopump-skip-time':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-autopump-skip-time = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
      end case.
      delete thbjattr_thbj-attr .
    end.
  end.
  return .
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable g-log        as logical   no-undo.
define variable varexpptr    as character no-undo.
define variable vardata-type as character no-undo.
define variable varlog       as logical   no-undo.
define variable v-return-val as character no-undo initial "":U .
define variable v-min-dens   as decimal   no-undo.
define variable v-max-dens   as decimal   no-undo.
define variable v-attr-type  as character no-undo.
define variable v-gds-ptrl-densities as character no-undo.
define variable pomi-licvalue as character no-undo init 'no':U.
define variable pomi-lictype  as character no-undo.
define variable v-value           as character no-undo.
define variable v-ok              as logical   no-undo.
define buffer buf_goods       for ub.goods .
define buffer bf_rvs-doc      for ub.c-rvs-doc.
define buffer bf_pl-level     for ub.pl-level.
define buffer bf-nxt_pl-level for ub.pl-level.
define buffer buf2_place      for ub.place.
define stream outstream.
DEFINE BUTTON b-calc
     LABEL "Рассчитать"
     SIZE 13 BY .88.
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-save AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE mass-float-cov AS DECIMAL FORMAT ">>,>>9.999":U INITIAL 0
     LABEL "Масса плавающего покрытия"
     VIEW-AS FILL-IN
     SIZE 13 BY .88 NO-UNDO.
DEFINE VARIABLE varmeasure-water-cli-qnty AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0
     LABEL "Вес воды"
     VIEW-AS FILL-IN
     SIZE 13 BY .88 NO-UNDO.
DEFINE VARIABLE varmeasure-water-qnty AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0
     LABEL "Измер. вода"
     VIEW-AS FILL-IN
     SIZE 13 BY .88 NO-UNDO.
DEFINE VARIABLE varstate-water-cli-qnty AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0
     LABEL "Факт вес воды"
     VIEW-AS FILL-IN
     SIZE 13 BY .88 NO-UNDO.
DEFINE VARIABLE varstate-water-qnty AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0
     LABEL "Факт вода"
     VIEW-AS FILL-IN
     SIZE 13 BY .88 NO-UNDO.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 52.25 BY 21.71.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 47.88 BY 21.75.
DEFINE QUERY Dialog-Frame FOR
      tt-rvs-line SCROLLING.
DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     tt-rvs-line.system-qnty AT ROW 2.25 COL 26 COLON-ALIGNED
          LABEL "Объем расчетно-книжный"
          VIEW-AS FILL-IN
          SIZE 19 BY .88
     tt-rvs-line.system-cli-qnty AT ROW 2.25 COL 74 COLON-ALIGNED
          LABEL "Вес расчетно-книжный"
          VIEW-AS FILL-IN
          SIZE 19 BY .88
     tt-rvs-line.orig-system-qnty AT ROW 3.25 COL 25 COLON-ALIGNED
          LABEL "Первоначально"
          VIEW-AS FILL-IN
          SIZE 19 BY .88
          FGCOLOR 4
     tt-rvs-line.orig-system-cli-qnty AT ROW 3.25 COL 73 COLON-ALIGNED
          LABEL "Первоначально"
          VIEW-AS FILL-IN
          SIZE 19 BY .88
          FGCOLOR 4
     tt-rvs-line.measure-qnty AT ROW 4.75 COL 28.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-measure-qnty AT ROW 4.75 COL 73.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.meas-calc-qnty AT ROW 5.75 COL 34 COLON-ALIGNED WIDGET-ID 20
          LABEL "Остаток рассчит. по измер."
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.measure-tc-qnty AT ROW 6.75 COL 28.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-measure-tc-qnty AT ROW 6.75 COL 73.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.density AT ROW 7.75 COL 28.25 COLON-ALIGNED FORMAT "9.9999999999"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-density AT ROW 7.75 COL 73.25 COLON-ALIGNED FORMAT "9.9999999999"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     b-calc AT ROW 7.75 COL 89 WIDGET-ID 6
     tt-rvs-line.meas-calc-dens AT ROW 8.75 COL 34 COLON-ALIGNED WIDGET-ID 8
          LABEL "Плотность расчит. по измер."
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.izmer-density AT ROW 8.75 COL 79 COLON-ALIGNED WIDGET-ID 4
          LABEL "Плотность измер.для ПО МИ"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.add-qnty AT ROW 9.75 COL 28.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-add-qnty AT ROW 9.75 COL 73.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.brutto-qnty AT ROW 10.75 COL 28.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-brutto-qnty AT ROW 10.75 COL 73.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.brutto-tc-qnty AT ROW 11.75 COL 28.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-brutto-tc-qnty AT ROW 11.75 COL 73.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     varmeasure-water-qnty AT ROW 12.75 COL 28.13 COLON-ALIGNED
     varstate-water-qnty AT ROW 12.75 COL 73.5 COLON-ALIGNED
     tt-rvs-line.measure-cli-qnty AT ROW 13.75 COL 28.13 COLON-ALIGNED
          LABEL "Измер. вес"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-measure-cli-qnty AT ROW 13.75 COL 73.5 COLON-ALIGNED
          LABEL "Факт вес"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         CANCEL-BUTTON b-cancel.
DEFINE FRAME Dialog-Frame
     tt-rvs-line.meas-cli-calc-qnty AT ROW 14.75 COL 34 COLON-ALIGNED WIDGET-ID 10
          LABEL "Вес расчит. по измер."
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.brutto-cli-qnty AT ROW 15.75 COL 28.13 COLON-ALIGNED
          LABEL "Измер. брутто вес"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-brutto-cli-qnty AT ROW 15.75 COL 73.5 COLON-ALIGNED
          LABEL "Факт брутто вес"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     varmeasure-water-cli-qnty AT ROW 16.75 COL 28.13 COLON-ALIGNED
     varstate-water-cli-qnty AT ROW 16.75 COL 73.5 COLON-ALIGNED
     tt-rvs-line.level-petrol AT ROW 17.75 COL 28.13 COLON-ALIGNED
          LABEL "Измер. уровень топлива"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-level-petrol AT ROW 17.75 COL 73.5 COLON-ALIGNED format ">>,>>9.999"
          LABEL "Факт уровень топлива"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.level-total AT ROW 18.75 COL 28.13 COLON-ALIGNED
          LABEL "Измер. общий уровень"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-level-total AT ROW 18.75 COL 73.5 COLON-ALIGNED format ">>,>>9.999"
          LABEL "Факт общий уровень"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.level-water AT ROW 19.75 COL 28.13 COLON-ALIGNED
          LABEL "Измер. уровень воды"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-level-water AT ROW 19.75 COL 73.5 COLON-ALIGNED format ">>,>>9.999"
          LABEL "Факт уровень воды"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.temperature AT ROW 20.75 COL 28.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-temperature AT ROW 20.75 COL 73.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.temp-layer1 AT ROW 21.75 COL 8.5 COLON-ALIGNED
          LABEL "ИзмT1"
          VIEW-AS FILL-IN
          SIZE 8 BY .88
     tt-rvs-line.temp-layer2 AT ROW 21.75 COL 23.88 COLON-ALIGNED
          LABEL "ИзмT2"
          VIEW-AS FILL-IN
          SIZE 8 BY .88
     tt-rvs-line.temp-layer3 AT ROW 21.75 COL 39.25 COLON-ALIGNED
          LABEL "ИзмT3"
          VIEW-AS FILL-IN
          SIZE 8 BY .88
     tt-rvs-line.state-temp-layer1 AT ROW 21.75 COL 54.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 8 BY .88
     tt-rvs-line.state-temp-layer2 AT ROW 21.75 COL 71.63 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 8 BY .88
     tt-rvs-line.state-temp-layer3 AT ROW 21.75 COL 87.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 8 BY .88
     tt-rvs-line.meas-mh-qnty AT ROW 22.75 COL 28.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY .88
     tt-rvs-line.state-mh-qnty AT ROW 22.75 COL 73.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY .88
     tt-rvs-line.meas-am-qnty AT ROW 23.75 COL 28.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY .88
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         CANCEL-BUTTON b-cancel.
DEFINE FRAME Dialog-Frame
     tt-rvs-line.state-am-qnty AT ROW 23.75 COL 73.5 COLON-ALIGNED
          LABEL "Факт сумма оборота"
          VIEW-AS FILL-IN
          SIZE 17 BY .88
     tt-rvs-line.meas-cf-qnty AT ROW 24.75 COL 29.13 COLON-ALIGNED
          LABEL "Измеренное кол-во наливов"
          VIEW-AS FILL-IN
          SIZE 17 BY .88
     tt-rvs-line.state-cf-qnty AT ROW 24.75 COL 74.5 COLON-ALIGNED
          LABEL "Факт кол-во наливов"
          VIEW-AS FILL-IN
          SIZE 17 BY .88
     mass-float-cov AT ROW 26.5 COL 54 COLON-ALIGNED WIDGET-ID 2
     RECT-2 AT ROW 4.54 COL 50.25
     RECT-3 AT ROW 4.5 COL 2
     SPACE(53.36) SKIP(2.95)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Документ сверки"
         CANCEL-BUTTON b-cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  assign
    v-return-val = "cancel"
  .
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame
DO:
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    v-return-val = "cancel"
  .
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-calc IN FRAME Dialog-Frame
DO:
define variable v-mm as com-handle.
define variable v-proc as character no-undo.
define variable v-code            as character no-undo.
define variable ii                as integer   no-undo.
define variable place-type        as integer no-undo.
define variable place-SI          as integer no-undo.
define variable place-diameter    as decimal no-undo.
define variable place-ratio-error as decimal no-undo.
define variable dens-prov         as decimal no-undo format "9.9999999999":U.
define variable CalibTable        as character no-undo initial "".
define variable ToolType          as integer no-undo.
define variable A_LevelMeasurementTool  as decimal no-undo.
define variable DeltaAbs_H              as decimal no-undo.
define variable DeltaAbs_H_Water        as decimal no-undo.
define variable DeltaAbs_R              as decimal no-undo.
define variable DeltaAbs_Tv             as decimal no-undo.
define variable DeltaAbs_Tr             as decimal no-undo.
define variable DeltaOtn_N              as decimal no-undo.
define variable DeltaOtn_K              as decimal no-undo.
define variable temp-for-pomi           as integer no-undo.
define variable error-string            as character no-undo.
define variable v-is-meas               as logical no-undo.
define variable v-mm-density            as decimal no-undo.
define buffer buf_sr-izmerenia for ub.sr-izmerenia .
define buffer buf_place     for ub.place.
  assign frame Dialog-Frame tt-rvs-line.state-level-total   .
  assign frame Dialog-Frame tt-rvs-line.state-level-water   .
  assign frame Dialog-Frame tt-rvs-line.state-temp-layer1   .
  assign frame Dialog-Frame tt-rvs-line.state-temp-layer2   .
  assign frame Dialog-Frame tt-rvs-line.state-temp-layer3   .
  assign frame Dialog-Frame tt-rvs-line.state-temperature   .
  assign frame Dialog-Frame tt-rvs-line.izmer-density       .
  assign frame Dialog-Frame mass-float-cov                  .
  _trpomi :
    do on error undo, return no-apply :
    do ii = 1 to num-entries('place-type,place-SI,place-diameter,dead-balance,water-level,dens-prov,place-virtual,place-twice-code,place-sert-urov,place-local,place-error-mass,place-asi-sertif,place-rvd-dnsty,place-rvd-lvl,place-rvd-tmp,place-SI-dens,place-SI-level,place-SI-temp,place-passp-num,place-passp-type,place-dead-high,place-temp-coef,disable-water-alarm,disable-level-alarm,place-ponton,place-ponton-mass,place-ponton-height,place-com-vessel,place-com-tanks,place-is-main,place-gate-valve,place-gate-valve-tanks,place-auto-gate-valve':u,','):
      v-code = entry(ii,'place-type,place-SI,place-diameter,dead-balance,water-level,dens-prov,place-virtual,place-twice-code,place-sert-urov,place-local,place-error-mass,place-asi-sertif,place-rvd-dnsty,place-rvd-lvl,place-rvd-tmp,place-SI-dens,place-SI-level,place-SI-temp,place-passp-num,place-passp-type,place-dead-high,place-temp-coef,disable-water-alarm,disable-level-alarm,place-ponton,place-ponton-mass,place-ponton-height,place-com-vessel,place-com-tanks,place-is-main,place-gate-valve,place-gate-valve-tanks,place-auto-gate-valve':u) .
      run placelib_get-attr  ( input v-code
                              ,input tt-rvs-line.obj-code
                              ,input tt-rvs-line.obj-type
                              ,input tt-rvs-line.pl-code
                              ,output v-value
                              ,output v-ok      ) no-error.
      case v-code :
        when "place-type" then do :
          if v-ok then place-type = integer(v-value) .
        end.
        when "place-SI" then do :
          if v-ok then place-si = integer(v-value) .
        end.
        when "place-diameter" then do :
          if v-ok then place-diameter = decimal(v-value) .
        end.
        when "dens-prov" then do :
          if v-ok then dens-prov = decimal(v-value) .
        end.
      end case.
    end.
    for last pl-level no-lock
        where pl-level.pl-code  = tt-rvs-line.pl-code
          and pl-level.obj-code = tt-rvs-line.obj-code
          and pl-level.obj-type = tt-rvs-line.obj-type by pl-level.pl-level
          :
          CalibTable = Substitute("&1=&2","1",(pl-level.pl-qnty / (pl-level.pl-level))) .
    end.
    for each  pl-level no-lock
        where pl-level.pl-code  = tt-rvs-line.pl-code
          and pl-level.obj-code = tt-rvs-line.obj-code
          and pl-level.obj-type = tt-rvs-line.obj-type by pl-level.pl-level
          :
          if CalibTable = "" then CalibTable = Substitute("&1=&2",(pl-level.pl-level ),pl-level.pl-qnty ) .
                            else CalibTable = CalibTable + ";" + Substitute("&1=&2",(pl-level.pl-level ),pl-level.pl-qnty ) .
    end.
    CalibTable = CalibTable + ";" + fill(chr(32),(2048 - length(CalibTable))).
    if place-si  = 0 then do :
      message
        substitute ("Для складского места &1 не заданно средство измерения",tt-rvs-line.pl-code)
      view-as alert-box error.
      undo _trpomi, return no-apply.
    end.
    else do :
      find first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = place-si no-error.
      if not available buf_sr-izmerenia then do :
        message
        "Ошибка работы с библиотекой ПО МИ"
        substitute( 'Не найдено средство измерения с кодом &1', place-si ) skip
        view-as alert-box error.
        undo _trpomi, return no-apply.
      end.
      else do :
        assign
          ToolType               = buf_sr-izmerenia.sr-type-id
          A_LevelMeasurementTool = buf_sr-izmerenia.sr-temp-line
          DeltaAbs_H             = buf_sr-izmerenia.sr-abs-err-neft-water
          DeltaAbs_H_Water       = buf_sr-izmerenia.sr-abs-err-water
          DeltaAbs_R             = buf_sr-izmerenia.sr-abs-err-dens
          DeltaAbs_Tv            = buf_sr-izmerenia.sr-abs-err-temp-vol
          DeltaAbs_Tr            = buf_sr-izmerenia.sr-abs-err-temp-dens
          DeltaOtn_N             = buf_sr-izmerenia.sr-otnos
          .
      end.
    end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input tt-rvs-line.obj-type
  , input tt-rvs-line.obj-code
  ) .
    if not error-status :error then do:
      if ptrlprop-temp-for-pomi = 1 then temp-for-pomi = 15 .
                                    else temp-for-pomi = 20 .
    end.
    find first buf_place no-lock
         where buf_place.obj-code = tt-rvs-line.obj-code
           and buf_place.obj-type = tt-rvs-line.obj-type
           and buf_place.pl-code  = tt-rvs-line.pl-code no-error.
    if buf_place.is-meas  = yes then do :
      if place-type = 1 then do :
        v-proc = "Rosneft.MethodOfMetering13" .
        DeltaOtn_K = 0.20 .
      end.
      else do :
        v-proc = "Rosneft.MethodOfMetering6" .
        DeltaOtn_K = 0.25 .
      end.
    end.
    else do :
      if place-type = 1 then do :
        v-proc = "Rosneft.MethodOfMetering12" .
        DeltaOtn_K = 0.20 .
      end.
      else do :
        v-proc = "Rosneft.MethodOfMetering5" .
        DeltaOtn_K = 0.25 .
      end.
    end.
    if tt-rvs-line.izmer-density = ? or tt-rvs-line.izmer-density = 0 then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПО МИ"        skip
        "Введите плотность измер.для ПО МИ"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.izmer-density in frame Dialog-Frame.
      undo _trpomi, return .
    end.
    if tt-rvs-line.state-level-total = ? then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПО МИ"        skip
        "Введите факт. общий уровень"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-level-total in frame Dialog-Frame.
      undo _trpomi, return .
    end.
    if tt-rvs-line.state-level-water = ? then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПО МИ"        skip
        "Введите факт. уровень топлива"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-level-petrol in frame Dialog-Frame.
      undo _trpomi, return .
    end.
    if tt-rvs-line.state-temp-layer1 = ? then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПО МИ"        skip
        "Введите Т1"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-temp-layer1 in frame Dialog-Frame.
      undo _trpomi, return .
    end.
    if tt-rvs-line.state-temp-layer2 = ? then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПО МИ"        skip
        "Введите Т2"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-temp-layer2 in frame Dialog-Frame.
      undo _trpomi, return .
    end.
    if tt-rvs-line.state-temp-layer3 = ? then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПО МИ"        skip
        "Введите Т3"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-temp-layer3 in frame Dialog-Frame.
      undo _trpomi, return .
    end.
    if tt-rvs-line.state-temperature = ? then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПО МИ"        skip
        "Введите температуру"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-temperature in frame Dialog-Frame.
      undo _trpomi, return .
    end.
    RELEASE OBJECT v-mm NO-ERROR.
    v-mm = ?.
    CREATE value(v-proc) v-mm no-error.
    IF ERROR-STATUS:ERROR
    OR NOT VALID-HANDLE(v-mm)
    THEN DO:
      message
      "Не удается подключиться к COM-серверу библиотеки для работы с ПО МИ "
      view-as alert-box error.
      enable
        tt-rvs-line.state-density
        tt-rvs-line.state-measure-qnty
      with frame Dialog-Frame.
      RELEASE OBJECT v-mm NO-ERROR.
      v-mm = ?.
      undo _trpomi, return no-apply .
    END.
    ELSE DO :
      ASSIGN
        v-mm:H                      = integer( tt-rvs-line.state-level-total) * 10
        v-mm:H_water                = integer( tt-rvs-line.state-level-water) * 10
        v-mm:CalibrationTable       = CalibTable
        v-mm:Tr                     = tt-rvs-line.state-temperature
        v-mm:R                      = ( tt-rvs-line.izmer-density * 1000 )
        v-mm:Tcy                    = temp-for-pomi
        v-mm:ToolType               = ToolType
        v-mm:DeltaOtn_K             = DeltaOtn_K
        v-mm:A_Reservoir            = 0.0000125
        v-mm:DeltaAbs_H             = DeltaAbs_H
        v-mm:DeltaAbs_H_Water       = DeltaAbs_H_Water
        v-mm:DeltaAbs_R             = DeltaAbs_R
        v-mm:DeltaAbs_Tv            = DeltaAbs_Tv
        v-mm:DeltaAbs_Tr            = DeltaAbs_Tr
        v-mm:DeltaOtn_N             = DeltaOtn_N
      .
      output stream outstream to value ("pomi.log")  append.
      put stream outstream
                                      cur-time-string()                  format "x(16)"  skip
          'Процедура                ' v-proc                             format "x(128)" skip
          'H                      = ' ( tt-rvs-line.state-level-total * 10 )             skip
          'H_water                = ' ( tt-rvs-line.state-level-water * 10 )             skip
          'CalibrationTable       = ' CalibTable                        format "x(2048)" skip
          'Tr                     = ' tt-rvs-line.state-temperature                      skip
          'R                      = ' ( tt-rvs-line.izmer-density * 1000 )               skip
          'Tcy                    = ' temp-for-pomi                                      skip
          'ToolType               = ' ToolType                                           skip
          'DeltaOtn_K             = ' DeltaOtn_K                                         skip
          'A_Reservoir            = ' 0.0000125                                          skip
          'DeltaAbs_H             = ' DeltaAbs_H                                         skip
          'DeltaAbs_H_Water       = ' DeltaAbs_H_Water                                   skip
          'DeltaAbs_R             = ' DeltaAbs_R                                         skip
          'DeltaAbs_Tv            = ' DeltaAbs_Tv                                        skip
          'DeltaAbs_Tr            = ' DeltaAbs_Tr                                        skip
          'DeltaOtn_N             = ' DeltaOtn_N                                         skip
      .
      if place-type = 1 then do :
        v-mm:Rprov = ( dens-prov * 1000 ) .
        v-mm:Mpokr = mass-float-cov .
        put stream outstream
          "v-mm:Rprov             = " ( dens-prov * 1000 ) skip
          "v-mm:Mpokr             = " mass-float-cov skip
        .
      end.
      find first buf_place no-lock
          where buf_place.obj-code = tt-rvs-line.obj-code
            and buf_place.obj-type = tt-rvs-line.obj-type
            and buf_place.pl-code  = tt-rvs-line.pl-code no-error.
      if buf_place.is-meas  = yes then do :
         v-mm:Tv = tt-rvs-line.state-temperature .
      end.
      else do :
        if place-type <> 1 then do :
          v-mm:D = place-diameter .
          put stream outstream
            "v-mm:D                      = " place-diameter                skip
          .
        end.
        assign
          v-mm:T_lower                = tt-rvs-line.state-temp-layer1
          v-mm:T_middle               = tt-rvs-line.state-temp-layer2
          v-mm:T_upper                = tt-rvs-line.state-temp-layer3
          v-mm:A_LevelMeasurementTool = A_LevelMeasurementTool
        .
        put stream outstream
          "v-mm:T_lower                = " tt-rvs-line.state-temp-layer1 skip
          "v-mm:T_middle               = " tt-rvs-line.state-temp-layer2 skip
          "v-mm:T_upper                = " tt-rvs-line.state-temp-layer3 skip
          "v-mm:A_LevelMeasurementTool = " A_LevelMeasurementTool        skip
        .
      end.
      output stream outstream close.
      v-mm:Exec() .
      if v-mm:Result <> 0 then do :
        error-string = v-mm:ResultDetail .
        output stream outstream to value ("pomi.log")  append.
        put stream outstream error-string format "X(1024)" skip.
        message
        substitute('Ошибка работы библиотеки ПО МИ. &1',error-string)
        view-as alert-box error.
        RELEASE OBJECT v-mm NO-ERROR.
        v-mm = ?.
        output stream outstream close.
        undo _trpomi, return no-apply .
      end.
      else do :
        v-mm-density = decimal(v-mm:Rcy) / 1000 .
        assign
          tt-rvs-line.state-measure-qnty     = v-mm:Vcy
          tt-rvs-line.state-density          = v-mm-density
          tt-rvs-line.state-measure-cli-qnty = tt-rvs-line.state-measure-qnty * tt-rvs-line.state-density
        .
        display
          tt-rvs-line.state-measure-qnty
          tt-rvs-line.state-density
          tt-rvs-line.state-measure-cli-qnty
         with frame Dialog-Frame .
        output stream outstream to value ("pomi.log")  append.
        put stream outstream
        "v-mm:Vcy"  tt-rvs-line.state-measure-qnty     skip
        "v-mm:Rcy"  tt-rvs-line.state-density          skip .
        output stream outstream close.
        run volume-water no-error.
        if error-status :error then do :
                                 enable
                                   tt-rvs-line.state-density
                                   tt-rvs-line.state-measure-qnty
                                   tt-rvs-line.state-add-qnty
                                   tt-rvs-line.state-brutto-qnty
                                   tt-rvs-line.state-brutto-cli-qnty
                                 with frame Dialog-Frame.
                                 undo _trpomi, return .
                               end.
        run chg-density no-error.
        if error-status :error then do :
                                 enable
                                   tt-rvs-line.state-density
                                   tt-rvs-line.state-measure-qnty
                                   tt-rvs-line.state-add-qnty
                                   tt-rvs-line.state-brutto-qnty
                                   tt-rvs-line.state-brutto-cli-qnty
                                 with frame Dialog-Frame.
                                 undo _trpomi, return .
                               end.
        run weath-water no-error.
        if error-status:error then do :
                                enable
                                  tt-rvs-line.state-density
                                  tt-rvs-line.state-measure-qnty
                                  tt-rvs-line.state-add-qnty
                                  tt-rvs-line.state-brutto-qnty
                                  tt-rvs-line.state-brutto-cli-qnty
                                with frame Dialog-Frame.
                                undo _trpomi, return .
                              end.
      end.
    END.
  end.
  enable
    tt-rvs-line.state-density
    tt-rvs-line.state-measure-qnty
    tt-rvs-line.state-add-qnty
    tt-rvs-line.state-brutto-qnty
    tt-rvs-line.state-brutto-cli-qnty
  with frame Dialog-Frame.
END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
  define variable v-water     as decimal   no-undo .
  define variable v-water-cli as decimal   no-undo .
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if input frame Dialog-Frame tt-rvs-line.state-measure-qnty >
     input frame Dialog-Frame tt-rvs-line.state-brutto-qnty  then do:
     message "Объем топлива больше общего объема."
     view-as alert-box error.
     apply "entry" to tt-rvs-line.state-measure-qnty in frame Dialog-Frame.
     return no-apply.
  end.
  assign
    v-water     = input frame Dialog-Frame tt-rvs-line.state-brutto-qnty - input frame Dialog-Frame tt-rvs-line.state-measure-qnty
    v-water-cli = input frame Dialog-Frame tt-rvs-line.state-brutto-cli-qnty - input frame Dialog-Frame tt-rvs-line.state-measure-cli-qnty
  .
  if ( v-water <> ?
       and v-water <> 0
       and ( v-water-cli = ?
             or v-water-cli = 0
           )
     )
     or
     ( v-water-cli <> ?
       and v-water-cli <> 0
       and ( v-water = ?
             or v-water = 0
           )
     )
  then do:
     message
       substitute( "Объем воды (&1) не соответствует его весу (&2)!", v-water, v-water-cli )
       view-as alert-box error.
     return no-apply.
  end.
  find first c-rvs-line where recid(c-rvs-line) =  p-code-rec-line no-error.
  run level-water  in this-procedure ( input yes ) no-error.
  if error-status :error then do:
    apply "ENTRY":U to tt-rvs-line.state-level-petrol in frame Dialog-Frame.
    return no-apply.
  end.
  run volume-water in this-procedure               no-error.
  if error-status :error then do: return no-apply. end.
  run chg-density  in this-procedure               no-error.
  if error-status :error then do: return no-apply. end.
  run weath-water  in this-procedure               no-error.
  if error-status :error then do: return no-apply. end.
  assign frame Dialog-Frame tt-rvs-line.state-measure-tc-qnty tt-rvs-line.state-add-qnty tt-rvs-line.state-brutto-tc-qnty tt-rvs-line.state-temperature tt-rvs-line.state-temp-layer1 tt-rvs-line.state-temp-layer2 tt-rvs-line.state-temp-layer3.
  buffer-copy tt-rvs-line to c-rvs-line.
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "izmer-density" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "izmer-density"
      rvs-line-attr.attr-value = string(tt-rvs-line.izmer-density)
    .
  end.
  else do :
    rvs-line-attr.attr-value = string(tt-rvs-line.izmer-density) .
  end.
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "mass-float-cov" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "mass-float-cov"
      rvs-line-attr.attr-value = string(mass-float-cov) .
    .
  end.
  else do :
    rvs-line-attr.attr-value = string(mass-float-cov) .
  end.
END.
ON LEAVE OF tt-rvs-line.state-add-qnty IN FRAME Dialog-Frame
DO:
  assign frame Dialog-Frame tt-rvs-line.state-add-qnty.
END.
ON return OF tt-rvs-line.state-add-qnty IN FRAME Dialog-Frame
DO:
  apply "entry" to tt-rvs-line.state-brutto-qnty in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-rvs-line.state-brutto-cli-qnty IN FRAME Dialog-Frame
DO:
if input frame Dialog-Frame tt-rvs-line.state-brutto-cli-qnty <> tt-rvs-line.state-brutto-cli-qnty then do:
  run weath-water no-error.
  if error-status:error then return no-apply.
end.
END.
ON return OF tt-rvs-line.state-brutto-cli-qnty IN FRAME Dialog-Frame
DO:
  apply "entry" to tt-rvs-line.state-level-petrol in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-rvs-line.state-brutto-qnty IN FRAME Dialog-Frame
DO:
if input frame Dialog-Frame tt-rvs-line.state-brutto-qnty <> tt-rvs-line.state-brutto-qnty then do:
  run volume-water no-error.
  if error-status:error then return no-apply.
end.
END.
ON return OF tt-rvs-line.state-brutto-qnty IN FRAME Dialog-Frame
DO:
  apply "entry" to tt-rvs-line.state-measure-tc-qnty in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-rvs-line.state-brutto-tc-qnty IN FRAME Dialog-Frame
DO:
  assign frame Dialog-Frame tt-rvs-line.state-brutto-tc-qnty.
END.
ON return OF tt-rvs-line.state-brutto-tc-qnty IN FRAME Dialog-Frame
DO:
  apply "entry" to tt-rvs-line.state-brutto-cli-qnty in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-rvs-line.state-density IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-rvs-line.state-density <> tt-rvs-line.state-density then do:
     run chg-density no-error.
     if error-status:error then return no-apply.
     run weath-water no-error.
     if error-status:error then return no-apply.
  end.
END.
ON return OF tt-rvs-line.state-density IN FRAME Dialog-Frame
DO:
  apply "entry" to tt-rvs-line.state-add-qnty in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-rvs-line.izmer-density IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-rvs-line.izmer-density <> tt-rvs-line.izmer-density then do:
    if input frame Dialog-Frame tt-rvs-line.izmer-density = ?
      or ( buf_goods.unit-base <> buf_goods.unit-cli
          and ( input frame Dialog-Frame tt-rvs-line.izmer-density <= 0
                or input frame Dialog-Frame tt-rvs-line.izmer-density >= 1
              )
        )
      or ( buf_goods.unit-base = buf_goods.unit-cli
          and input frame Dialog-Frame tt-rvs-line.izmer-density <> 1
        )
    then do:
      message "Неверно определена плотность топлива измер. для ПО МИ." view-as alert-box error.
      apply "entry" to tt-rvs-line.izmer-density .
      return no-apply.
    end.
    assign frame Dialog-Frame tt-rvs-line.izmer-density.
  end.
END.
ON RETURN OF tt-rvs-line.izmer-density IN FRAME Dialog-Frame
DO:
  apply "entry" to tt-rvs-line.state-level-petrol in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-rvs-line.state-level-petrol IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-rvs-line.state-level-petrol <> tt-rvs-line.state-level-petrol then do:
    RUN local-tarir ("state-level-petrol").
    run level-water in this-procedure ( input no )  .
  end.
END.
ON return OF tt-rvs-line.state-level-petrol IN FRAME Dialog-Frame
DO:
  apply "entry" to tt-rvs-line.state-level-total in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-rvs-line.state-level-total IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-rvs-line.state-level-total <> tt-rvs-line.state-level-total then do:
    RUN local-tarir ("state-level-total").
    run level-water in this-procedure ( input no )  .
  end.
END.
ON return OF tt-rvs-line.state-level-total IN FRAME Dialog-Frame
DO:
  apply "entry" to tt-rvs-line.state-temperature in frame Dialog-Frame.
  return no-apply.
END.
ON return OF tt-rvs-line.state-measure-cli-qnty IN FRAME Dialog-Frame
DO:
  apply "entry" to tt-rvs-line.state-brutto-cli-qnty in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-rvs-line.state-measure-qnty IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-rvs-line.state-measure-qnty <> tt-rvs-line.state-measure-qnty then do:
     run volume-water no-error.
     if error-status:error then return no-apply.
     if tt-rvs-line.state-density <> 0 and
        tt-rvs-line.state-density <> ? then do:
        run chg-density no-error.
        if error-status:error then return no-apply.
        run weath-water no-error.
        if error-status:error then return no-apply.
     end.
  end.
END.
ON return OF tt-rvs-line.state-measure-qnty IN FRAME Dialog-Frame
DO:
  apply "entry" to tt-rvs-line.state-measure-tc-qnty in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-rvs-line.state-measure-tc-qnty IN FRAME Dialog-Frame
DO:
  assign frame Dialog-Frame tt-rvs-line.state-measure-tc-qnty.
END.
ON return OF tt-rvs-line.state-measure-tc-qnty IN FRAME Dialog-Frame
DO:
  apply "entry" to tt-rvs-line.state-density in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-rvs-line.state-temp-layer1 IN FRAME Dialog-Frame
DO:
    assign frame Dialog-Frame tt-rvs-line.state-temp-layer1.
END.
ON return OF tt-rvs-line.state-temp-layer1 IN FRAME Dialog-Frame
DO:
  apply "entry" to tt-rvs-line.state-temp-layer2 in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-rvs-line.state-temp-layer2 IN FRAME Dialog-Frame
DO:
    assign frame Dialog-Frame tt-rvs-line.state-temp-layer2.
END.
ON return OF tt-rvs-line.state-temp-layer2 IN FRAME Dialog-Frame
DO:
  apply "entry" to tt-rvs-line.state-temp-layer3 in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-rvs-line.state-temp-layer3 IN FRAME Dialog-Frame
DO:
    assign frame Dialog-Frame tt-rvs-line.state-temp-layer3.
END.
ON return OF tt-rvs-line.state-temp-layer3 IN FRAME Dialog-Frame
DO:
  if pomi-licvalue  = "yes" then do:
    apply "entry" to mass-float-cov in frame Dialog-Frame.
    return no-apply.
  end.
  else do :
    apply "entry" to b-save in frame Dialog-Frame.
    return no-apply.
  end.
END.
ON return OF mass-float-cov IN FRAME Dialog-Frame
DO:
  apply "entry" to b-calc in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-rvs-line.state-temperature IN FRAME Dialog-Frame
DO:
    assign frame Dialog-Frame tt-rvs-line.state-temperature.
END.
ON return OF tt-rvs-line.state-temperature IN FRAME Dialog-Frame
DO:
  apply "entry" to tt-rvs-line.state-temp-layer1 in frame Dialog-Frame.
  return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
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
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
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
     find first c-rvs-line where recid(c-rvs-line) =  p-code-rec-line no-lock no-error.
  if not available c-rvs-line then do:
     message "Неверно переданы параметры."
             "Не найдена строка сверка " p-code-rec-line " ."
     view-as alert-box error.
     return error.
  end.
  create tt-rvs-line.
  buffer-copy c-rvs-line to tt-rvs-line.
  release rvs-line.
  find first bf_rvs-doc where bf_rvs-doc.rvs-code = tt-rvs-line.rvs-code.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_gtexpptr in g#lib-trn3 (  input bf_rvs-doc.host-code ,
                        input bf_rvs-doc.obj-type ,
                        input bf_rvs-doc.obj-code ,
                        input yes ,
                        input no ,
                       output varexpptr ) no-error .
  if error-status :error or lookup( varexpptr, 'volume,weight,volume+,weight+':U ) = 0 then do: assign varexpptr = ?. end.
  RUN enable_UI IN THIS-PROCEDURE.
  if tt-rvs-line.system-qnty <> tt-rvs-line.orig-system-qnty
    and tt-rvs-line.system-cli-qnty <> tt-rvs-line.orig-system-cli-qnty
  then do:
    assign
      tt-rvs-line.orig-system-cli-qnty :label in frame Dialog-Frame = "":U
    .
  end.
  if tt-rvs-line.system-qnty <> tt-rvs-line.orig-system-qnty then do:
    display
      tt-rvs-line.orig-system-qnty
      with frame Dialog-Frame.
  end.
  else do:
    hide
      tt-rvs-line.orig-system-qnty
      in frame Dialog-Frame.
  end.
  if tt-rvs-line.system-cli-qnty <> tt-rvs-line.orig-system-cli-qnty then do:
    display
      tt-rvs-line.orig-system-cli-qnty
      with frame Dialog-Frame.
  end.
  else do:
    hide
      tt-rvs-line.orig-system-cli-qnty
      in frame Dialog-Frame.
  end.
  if parmode <> 'ИЗМЕНЕНИЕ':U then do:
     disable tt-rvs-line.state-measure-qnty tt-rvs-line.state-measure-tc-qnty tt-rvs-line.state-density tt-rvs-line.state-add-qnty tt-rvs-line.state-brutto-qnty tt-rvs-line.state-brutto-tc-qnty tt-rvs-line.state-measure-cli-qnty tt-rvs-line.state-brutto-cli-qnty tt-rvs-line.state-level-petrol tt-rvs-line.state-level-total tt-rvs-line.state-level-water tt-rvs-line.state-temperature tt-rvs-line.state-temp-layer1 tt-rvs-line.state-temp-layer2 tt-rvs-line.state-temp-layer3 tt-rvs-line.state-mh-qnty tt-rvs-line.state-am-qnty tt-rvs-line.state-cf-qnty tt-rvs-line.izmer-density with frame Dialog-Frame.
  end.
  else
    do:
      find first buf2_place no-lock where
                 buf2_place.obj-code = tt-rvs-line.obj-code and
                 buf2_place.obj-type = tt-rvs-line.obj-type and
                 buf2_place.pl-code  = tt-rvs-line.pl-code
      no-error.
      case bf_rvs-doc.rvs-type:
        when 'перед_док':U or when 'после_док':U then
        do:
          if available buf2_place then
          do:
            if buf2_place.is-meas = yes then
            do:
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-on-doc_upd-revision':U
    ,input  'object':U
    ,input  bf_rvs-doc.host-code
    ,input  bf_rvs-doc.obj-type
    ,input  bf_rvs-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g-log
    )  .
end.
             end.
             else
             do:
               g-log = yes.
             end.
          end.
        end.
        when 'смена':U
        then do:
            if available buf2_place then do :
                if buf2_place.is-meas then do :
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-shift_upd-revision':U
    ,input  'object':U
    ,input  bf_rvs-doc.host-code
    ,input  bf_rvs-doc.obj-type
    ,input  bf_rvs-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g-log
    )  .
end.
                end.
                else do :
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-shift_upd-immeas':U
    ,input  'object':U
    ,input  bf_rvs-doc.host-code
    ,input  bf_rvs-doc.obj-type
    ,input  bf_rvs-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g-log
    )  .
end.
                end.
            end.
        end.
        when 'контроль':U
        then do:
            if available buf2_place then do :
                if buf2_place.is-meas then do :
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-control_upd-revision':U
    ,input  'object':U
    ,input  bf_rvs-doc.host-code
    ,input  bf_rvs-doc.obj-type
    ,input  bf_rvs-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g-log
    )  .
end.
                end.
                else do :
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-control_upd-immeas':U
    ,input  'object':U
    ,input  bf_rvs-doc.host-code
    ,input  bf_rvs-doc.obj-type
    ,input  bf_rvs-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g-log
    )  .
end.
                end.
            end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный тип сверки" skip
            "Тип документа" bf_rvs-doc.rvs-type skip
            "Код документа" bf_rvs-doc.rvs-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .
     if not g-log then do:
        disable tt-rvs-line.state-measure-qnty tt-rvs-line.state-measure-tc-qnty tt-rvs-line.state-density tt-rvs-line.state-add-qnty tt-rvs-line.state-brutto-qnty tt-rvs-line.state-brutto-tc-qnty tt-rvs-line.state-measure-cli-qnty tt-rvs-line.state-brutto-cli-qnty tt-rvs-line.state-level-petrol tt-rvs-line.state-level-total tt-rvs-line.state-level-water tt-rvs-line.state-temperature tt-rvs-line.state-temp-layer1 tt-rvs-line.state-temp-layer2 tt-rvs-line.state-temp-layer3 tt-rvs-line.state-mh-qnty tt-rvs-line.state-am-qnty tt-rvs-line.state-cf-qnty tt-rvs-line.izmer-density with frame Dialog-Frame.
     end.
  end.
  if parmode <> 'ИЗМЕНЕНИЕ':U then do:
    disable b-save with frame Dialog-Frame.
  end.
  run volume-measure-water in this-procedure                 no-error.
  run weath-measure-water  in this-procedure                 no-error.
  run level-measure-water  in this-procedure                 no-error.
  run volume-water         in this-procedure                 no-error.
  run weath-water          in this-procedure                 no-error.
  run level-water          in this-procedure ( input no )  .
  find first buf_goods no-lock
    where buf_goods.gds-code = tt-rvs-line.gds-code
    .
  if buf_goods.unit-base = buf_goods.unit-cli then do:
    assign
      tt-rvs-line.density       = 1.0
      tt-rvs-line.state-density = 1.0
    .
    disable
      tt-rvs-line.density
      tt-rvs-line.state-density
      with frame Dialog-Frame.
  end.
  if pomi-licvalue = "no" then do :
    hide
      tt-rvs-line.meas-calc-qnty
      tt-rvs-line.meas-calc-dens
      tt-rvs-line.meas-cli-calc-qnty
      tt-rvs-line.izmer-density
      mass-float-cov
      b-calc
      in frame Dialog-Frame.
  end.
  else  do :
    view
      tt-rvs-line.izmer-density
    in frame Dialog-Frame.
    enable
      tt-rvs-line.izmer-density
    with frame Dialog-Frame.
    disable
      tt-rvs-line.state-density
      tt-rvs-line.state-measure-qnty
      tt-rvs-line.state-add-qnty
      tt-rvs-line.state-brutto-qnty
      tt-rvs-line.state-brutto-cli-qnty
    with frame Dialog-Frame.
    for each rvs-line-attr no-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         :
          case rvs-line-attr.attr-code :
            when "meas-calc-qnty" then do :
              tt-rvs-line.meas-calc-qnty = decimal(rvs-line-attr.attr-value) .
            end.
            when "meas-calc-dens" then do :
              tt-rvs-line.meas-calc-dens = decimal(rvs-line-attr.attr-value) .
            end.
            when "meas-cli-calc-qnty" then do :
              tt-rvs-line.meas-cli-calc-qnty = decimal(rvs-line-attr.attr-value) .
            end.
            when "izmer-density" then do :
              tt-rvs-line.izmer-density = decimal(rvs-line-attr.attr-value) .
            end.
            when "mass-float-cov" then do :
              mass-float-cov = decimal(rvs-line-attr.attr-value) .
            end.
          end case.
    end.
    display
      tt-rvs-line.meas-calc-qnty
      tt-rvs-line.meas-calc-dens
      tt-rvs-line.meas-cli-calc-qnty
      tt-rvs-line.izmer-density
      mass-float-cov
    with frame Dialog-Frame.
    run placelib_get-attr  ( input "place-type"
                            ,input tt-rvs-line.obj-code
                            ,input tt-rvs-line.obj-type
                            ,input tt-rvs-line.pl-code
                            ,output v-value
                            ,output v-ok      ) no-error.
    if v-ok then do :
      if integer(v-value) <> 1 then
      hide
        mass-float-cov
      in frame Dialog-Frame.
    end.
  end.
  if parmode <> 'ИЗМЕНЕНИЕ':U then do:
     disable tt-rvs-line.izmer-density with frame Dialog-Frame.
     disable mass-float-cov with frame Dialog-Frame.
     disable b-calc with frame Dialog-Frame.
  end.
  assign frame Dialog-Frame :title = frame Dialog-Frame :title + " - " + parmode
                                    + " - " +  partitle.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
return v-return-val .
PROCEDURE chg-density :
if input frame Dialog-Frame tt-rvs-line.state-density = ?
  or ( buf_goods.unit-base <> buf_goods.unit-cli
       and ( input frame Dialog-Frame tt-rvs-line.state-density <= 0
             or input frame Dialog-Frame tt-rvs-line.state-density >= 1
           )
     )
  or ( buf_goods.unit-base = buf_goods.unit-cli
       and input frame Dialog-Frame tt-rvs-line.state-density <> 1
     )
then do:
   message "Неверно определена плотность топлива." view-as alert-box error.
   return error.
end.
run gds-attr-value in this-procedure
  ( input  buf_goods.gds-code
  ,input  'gds-ptrl-densities':U
  ,output v-gds-ptrl-densities
  ,output v-attr-type
  ) .
  if v-gds-ptrl-densities <> "" and v-gds-ptrl-densities <> ? then do:
    assign
      v-min-dens = decimal(replace(entry(1, v-gds-ptrl-densities, "-":U ), "кг\л", "":U))
      v-max-dens = decimal(replace(entry(2, v-gds-ptrl-densities, "-":U ), "кг\л":U, "":U))
    no-error .
    if (input frame Dialog-Frame tt-rvs-line.state-density) < v-min-dens
    or (input frame Dialog-Frame tt-rvs-line.state-density) > v-max-dens
    then do:
      message
        substitute("Введенное значение плотности находится вне заданного диапазона: &1.",
        v-gds-ptrl-densities )
        view-as alert-box error .
      return error.
    end.
  end.
assign frame Dialog-Frame tt-rvs-line.state-density.
assign
  tt-rvs-line.state-measure-cli-qnty = tt-rvs-line.state-measure-qnty * tt-rvs-line.state-density
.
display tt-rvs-line.state-measure-cli-qnty with frame Dialog-Frame.
if tt-rvs-line.state-measure-cli-qnty > tt-rvs-line.state-brutto-cli-qnty then do:
  message "Измеренный вес больше веса брутто. Подставить измеренный вес в вес брутто?"
  view-as alert-box question buttons yes-no update varlog.
  if varlog = yes then do:
    assign
      tt-rvs-line.state-brutto-cli-qnty = tt-rvs-line.state-measure-cli-qnty.
    display tt-rvs-line.state-brutto-cli-qnty with frame Dialog-Frame.
  end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-rvs-line SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY varmeasure-water-qnty varstate-water-qnty varmeasure-water-cli-qnty
          varstate-water-cli-qnty mass-float-cov
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-rvs-line THEN
    DISPLAY tt-rvs-line.system-qnty tt-rvs-line.system-cli-qnty
          tt-rvs-line.orig-system-qnty tt-rvs-line.orig-system-cli-qnty
          tt-rvs-line.measure-qnty tt-rvs-line.state-measure-qnty
          tt-rvs-line.meas-calc-qnty tt-rvs-line.measure-tc-qnty tt-rvs-line.state-measure-tc-qnty
          tt-rvs-line.density tt-rvs-line.state-density
          tt-rvs-line.meas-calc-dens tt-rvs-line.izmer-density
          tt-rvs-line.add-qnty tt-rvs-line.state-add-qnty
          tt-rvs-line.brutto-qnty tt-rvs-line.state-brutto-qnty
          tt-rvs-line.brutto-tc-qnty tt-rvs-line.state-brutto-tc-qnty
          tt-rvs-line.measure-cli-qnty tt-rvs-line.state-measure-cli-qnty
          tt-rvs-line.meas-cli-calc-qnty
          tt-rvs-line.brutto-cli-qnty tt-rvs-line.state-brutto-cli-qnty
          tt-rvs-line.level-petrol tt-rvs-line.state-level-petrol
          tt-rvs-line.level-total tt-rvs-line.state-level-total
          tt-rvs-line.level-water tt-rvs-line.state-level-water
          tt-rvs-line.temperature tt-rvs-line.state-temperature
          tt-rvs-line.temp-layer1 tt-rvs-line.temp-layer2
          tt-rvs-line.temp-layer3 tt-rvs-line.state-temp-layer1
          tt-rvs-line.state-temp-layer2 tt-rvs-line.state-temp-layer3
          tt-rvs-line.meas-mh-qnty tt-rvs-line.state-mh-qnty
          tt-rvs-line.meas-am-qnty tt-rvs-line.state-am-qnty
          tt-rvs-line.meas-cf-qnty tt-rvs-line.state-cf-qnty
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-cancel b-help RECT-2 RECT-3 tt-rvs-line.state-measure-qnty
         tt-rvs-line.state-density b-calc tt-rvs-line.state-add-qnty
         tt-rvs-line.state-brutto-qnty tt-rvs-line.state-brutto-cli-qnty
         tt-rvs-line.state-level-petrol tt-rvs-line.state-level-total
         tt-rvs-line.state-temperature tt-rvs-line.state-temp-layer1
         tt-rvs-line.state-temp-layer2 tt-rvs-line.state-temp-layer3
         mass-float-cov
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE level-measure-water :
display input frame Dialog-Frame tt-rvs-line.level-total -
        input frame Dialog-Frame tt-rvs-line.level-petrol @
        tt-rvs-line.level-water with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE level-water :
  define input parameter p-mode as logical no-undo.
  define variable is_OK as logical no-undo initial yes.
  if input frame Dialog-Frame tt-rvs-line.state-level-petrol >
     input frame Dialog-Frame tt-rvs-line.state-level-total  then do:
    assign is_OK = no.
    if p-mode = yes then do:
      message "Уровень топлива больше значения общего уровня." view-as alert-box error.
      return error.
    end.
  end.
  display input frame Dialog-Frame tt-rvs-line.state-level-total  -
          input frame Dialog-Frame tt-rvs-line.state-level-petrol @
                                    tt-rvs-line.state-level-water
  with frame Dialog-Frame.
  if is_OK = yes then do:
    assign frame Dialog-Frame tt-rvs-line.state-level-water
                               tt-rvs-line.state-level-petrol
                               tt-rvs-line.state-level-total.
  end.
END PROCEDURE.
PROCEDURE local-tarir :
DEFINE INPUT PARAMETER paraction AS CHARACTER NO-UNDO.
DEFINE VARIABLE varlevel-sm-q AS DECIMAL NO-UNDO.
define variable vartarirvalue as character no-undo.
define variable vartarirtype  as character no-undo.
define variable varlevel-sm   as integer   no-undo.
define buffer bf_place for ub.place.
run gbl/conf-rd.p ("tarir", "", "", 0, "", "", "", no, output vartarirvalue, output vartarirtype) no-error.
if vartarirvalue = "yes" then do:
  CASE paraction:
    WHEN "state-level-total" THEN DO:
      ASSIGN
        varlevel-sm-q = input frame Dialog-Frame tt-rvs-line.state-level-total.
    END.
    WHEN "state-level-petrol" THEN DO:
      ASSIGN
        varlevel-sm-q = input frame Dialog-Frame tt-rvs-line.state-level-petrol.
    END.
  END CASE.
  assign
    varlevel-sm = trunc (varlevel-sm-q, 0).
  find first bf_place where bf_place.pl-code = tt-rvs-line.pl-code no-lock.
  find first bf_pl-level where bf_pl-level.obj-type = tt-rvs-line.obj-type      and
                               bf_pl-level.obj-code = tt-rvs-line.obj-code      and
                               bf_pl-level.pl-code  = bf_place.pl-code          and
                               bf_pl-level.pl-level = varlevel-sm            no-error.
  if not available bf_pl-level then do:
    message "Вычисляем объем резервуаров через градуировочные таблицы. Для резервуара " bf_place.loc1 " не задан объем для уровня " varlevel-sm view-as alert-box error.
    return no-apply.
  end.
  else do:
    if varlevel-sm = varlevel-sm-q then do:
      if error-status:error then return no-apply.
      display bf_pl-level.pl-qnty @ tt-rvs-line.state-brutto-qnty bf_pl-level.pl-qnty @ tt-rvs-line.state-measure-qnty with frame Dialog-Frame.
    end.
    else do:
      assign
        varlevel-sm = varlevel-sm + 1.
      find first bf-nxt_pl-level where bf-nxt_pl-level.obj-type = tt-rvs-line.obj-type   and
                                       bf-nxt_pl-level.obj-code = tt-rvs-line.obj-code   and
                                       bf-nxt_pl-level.pl-code  = bf_place.pl-code       and
                                       bf-nxt_pl-level.pl-level = varlevel-sm            no-error.
      if not available bf-nxt_pl-level then do:
        message "Вычисляем объем резервуаров через градуировочные таблицы. Для резервуара " bf_place.loc1 " не задан объем для уровня " varlevel-sm " измерение " varlevel-sm-q view-as alert-box error.
        return no-apply.
      end.
      else do:
        display bf_pl-level.pl-qnty + (bf-nxt_pl-level.pl-qnty - bf_pl-level.pl-qnty) * (varlevel-sm-q - trunc(varlevel-sm-q, 0)) @ tt-rvs-line.state-brutto-qnty
                bf_pl-level.pl-qnty + (bf-nxt_pl-level.pl-qnty - bf_pl-level.pl-qnty) * (varlevel-sm-q - trunc(varlevel-sm-q, 0)) @ tt-rvs-line.state-measure-qnty with frame Dialog-Frame.
      end.
    end.
    assign
      tt-rvs-line.state-brutto-qnty = input frame Dialog-Frame tt-rvs-line.state-measure-qnty.
    display tt-rvs-line.state-brutto-qnty with frame Dialog-Frame.
    if tt-rvs-line.state-density <> 0 and
        tt-rvs-line.state-density <> ? then do:
        run chg-density.
        run weath-water.
    end.
    CASE paraction:
      WHEN "state-level-total" THEN DO:
        DISPLAY input frame Dialog-Frame tt-rvs-line.state-level-total @ tt-rvs-line.state-level-petrol WITH FRAME Dialog-Frame.
      END.
      WHEN "state-level-petrol" THEN DO:
        DISPLAY input frame Dialog-Frame tt-rvs-line.state-level-petrol @ tt-rvs-line.state-level-total WITH FRAME Dialog-Frame.
      END.
    END CASE.
    run volume-water.
  end.
end.
END PROCEDURE.
PROCEDURE volume-measure-water :
display input frame Dialog-Frame tt-rvs-line.brutto-qnty -
        input frame Dialog-Frame tt-rvs-line.measure-qnty @
        varmeasure-water-qnty with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE volume-water :
display input frame Dialog-Frame tt-rvs-line.state-brutto-qnty -
        input frame Dialog-Frame tt-rvs-line.state-measure-qnty @
        varstate-water-qnty with frame Dialog-Frame.
        assign frame Dialog-Frame tt-rvs-line.state-brutto-qnty
                                   tt-rvs-line.state-measure-qnty.
END PROCEDURE.
PROCEDURE weath-measure-water :
display input frame Dialog-Frame tt-rvs-line.brutto-cli-qnty -
        input frame Dialog-Frame tt-rvs-line.measure-cli-qnty @
        varmeasure-water-cli-qnty with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE weath-water :
if input frame Dialog-Frame tt-rvs-line.state-measure-cli-qnty >
   input frame Dialog-Frame tt-rvs-line.state-brutto-cli-qnty then do:
   message "Вес топлива больше общего веса."
   view-as alert-box error.
   return error.
end.
display input frame Dialog-Frame tt-rvs-line.state-brutto-cli-qnty -
        input frame Dialog-Frame tt-rvs-line.state-measure-cli-qnty @
        varstate-water-cli-qnty with frame Dialog-Frame.
assign frame Dialog-Frame tt-rvs-line.state-brutto-cli-qnty
                           tt-rvs-line.state-measure-cli-qnty.
END PROCEDURE.
