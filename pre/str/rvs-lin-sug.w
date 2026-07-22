DEFINE TEMP-TABLE tt-rvs-line NO-UNDO LIKE rvs-line
field meas-calc-qnty     AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0
field meas-calc-dens     AS DECIMAL FORMAT "9.9999":U INITIAL 0
field meas-cli-calc-qnty AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0
field izmer-density      AS DECIMAL FORMAT "9.9999":U INITIAL 0
field calc-add-mass      AS DECIMAL FORMAT "->>,>>>,>>9.9":U INITIAL 0
field sum-mass           AS DECIMAL FORMAT "->>,>>>,>>9.9":U INITIAL 0
field sum-vol            AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0
field fact-calc-add-mass AS DECIMAL FORMAT "->>,>>>,>>9.9":U INITIAL 0
field fact-sum-mass      AS DECIMAL FORMAT "->>,>>>,>>9.9":U INITIAL 0
field fact-sum-vol       AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0
field vol-pf-sug         AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0
field state-vol-pf-sug   AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0
field dens-pf-sug        AS DECIMAL FORMAT "9.9999":U INITIAL 0
field state-dens-pf-sug  AS DECIMAL FORMAT "9.9999":U INITIAL 0
field pressure-sug       AS DECIMAL FORMAT ">>>>>9.99999":U INITIAL 0
field state-pressure-sug AS DECIMAL FORMAT ">>>>>9.99999":U INITIAL 0
.
define new shared temp-table tt-sug-struct no-undo
  field ii as integer
  field key_ as character
  field val_ as decimal format ">>9.<<"
  index pi
    as primary unique
    ii
.
define  input parameter parparentproc   as handle    no-undo .
define  input parameter parrec-rvs-line as recid     no-undo .
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-initiator  as character no-undo.
case true:
  when g#auto then v-initiator = "Auto".
  when g#news then v-initiator = "Nws".
  when g#esys then v-initiator = "Esys".
  otherwise v-initiator = "User".
end case.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
function MM6 returns logical
  (
  input H as decimal,
  input H_water as decimal,
  input CalibrationTable as character,
  input CalibrationBelt as character,
  input P0 as decimal,
  input Tv as decimal,
  input Tr as decimal,
  input R as decimal,
  input Tcy as decimal,
  input ToolType as integer,
  input DeltaOtn_K as decimal,
  input DeadZone_Reservoir as decimal,
  input A_Reservoir as decimal,
  input A_LevelMeasurementTool as decimal,
  input ToolAutomationLevel_H as integer,
  input ToolAutomationLevel_H_Water as integer,
  input ToolAutomationLevel_R as integer,
  input ToolAutomationLevel_Tv as integer,
  input ToolAutomationLevel_Tr as integer,
  input DeltaAbs_H_CalcType as integer,
  input DeltaAbs_H_Water_CalcType as integer,
  input DeltaAbs_H as decimal,
  input DeltaAbs_H_Water as decimal,
  input DeltaAbs_R as decimal,
  input DeltaAbs_Tv as decimal,
  input DeltaAbs_Tr as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output V_total as decimal,
  output V_water as decimal,
  output DeltaV as decimal,
  output V_product as decimal,
  output Vcy as decimal,
  output Rcy as decimal,
  output V as decimal,
  output CTL_base_alt as decimal,
  output CPL_base_alt as decimal,
  output CTPL_base_alt as decimal,
  output Fp_base_alt as decimal,
  output CTL_obs_base as decimal,
  output CPL_obs_base as decimal,
  output CTPL_obs_base as decimal,
  output Fp_obs_base as decimal,
  output Rv as decimal,
  output DeltaOtn_Vcy as decimal,
  output DeltaOtn_Vm as decimal,
  output M as decimal,
  output DeltaOtn_M as decimal,
  output VolumetricExpansion as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt6"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 56
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", H).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", H_water).
  hCall:SET-PARAMETER(6, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(7, "CHARACTER", "INPUT", CalibrationBelt).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", P0).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", Tv).
  hCall:SET-PARAMETER(10, "DOUBLE", "INPUT", Tr).
  hCall:SET-PARAMETER(11, "DOUBLE", "INPUT", R).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", Tcy).
  hCall:SET-PARAMETER(13, "LONG", "INPUT", ToolType).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", DeltaOtn_K).
  hCall:SET-PARAMETER(15, "DOUBLE", "INPUT", DeadZone_Reservoir).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", A_Reservoir).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", A_LevelMeasurementTool).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", ToolAutomationLevel_H).
  hCall:SET-PARAMETER(19, "LONG", "INPUT", ToolAutomationLevel_H_Water).
  hCall:SET-PARAMETER(20, "LONG", "INPUT", ToolAutomationLevel_R).
  hCall:SET-PARAMETER(21, "LONG", "INPUT", ToolAutomationLevel_Tv).
  hCall:SET-PARAMETER(22, "LONG", "INPUT", ToolAutomationLevel_Tr).
  hCall:SET-PARAMETER(23, "LONG", "INPUT", DeltaAbs_H_CalcType).
  hCall:SET-PARAMETER(24, "LONG", "INPUT", DeltaAbs_H_Water_CalcType).
  hCall:SET-PARAMETER(25, "DOUBLE", "INPUT", DeltaAbs_H).
  hCall:SET-PARAMETER(26, "DOUBLE", "INPUT", DeltaAbs_H_Water).
  hCall:SET-PARAMETER(27, "DOUBLE", "INPUT", DeltaAbs_R).
  hCall:SET-PARAMETER(28, "DOUBLE", "INPUT", DeltaAbs_Tv).
  hCall:SET-PARAMETER(29, "DOUBLE", "INPUT", DeltaAbs_Tr).
  hCall:SET-PARAMETER(30, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(31, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(32, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(33, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(34, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(35, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(36, "DOUBLE", "OUTPUT", V_total).
  hCall:SET-PARAMETER(37, "DOUBLE", "OUTPUT", V_water).
  hCall:SET-PARAMETER(38, "DOUBLE", "OUTPUT", DeltaV).
  hCall:SET-PARAMETER(39, "DOUBLE", "OUTPUT", V_product).
  hCall:SET-PARAMETER(40, "DOUBLE", "OUTPUT", Vcy).
  hCall:SET-PARAMETER(41, "DOUBLE", "OUTPUT", Rcy).
  hCall:SET-PARAMETER(42, "DOUBLE", "OUTPUT", V).
  hCall:SET-PARAMETER(43, "DOUBLE", "OUTPUT", CTL_base_alt).
  hCall:SET-PARAMETER(44, "DOUBLE", "OUTPUT", CPL_base_alt).
  hCall:SET-PARAMETER(45, "DOUBLE", "OUTPUT", CTPL_base_alt).
  hCall:SET-PARAMETER(46, "DOUBLE", "OUTPUT", Fp_base_alt).
  hCall:SET-PARAMETER(47, "DOUBLE", "OUTPUT", CTL_obs_base).
  hCall:SET-PARAMETER(48, "DOUBLE", "OUTPUT", CPL_obs_base).
  hCall:SET-PARAMETER(49, "DOUBLE", "OUTPUT", CTPL_obs_base).
  hCall:SET-PARAMETER(50, "DOUBLE", "OUTPUT", Fp_obs_base).
  hCall:SET-PARAMETER(51, "DOUBLE", "OUTPUT", Rv).
  hCall:SET-PARAMETER(52, "DOUBLE", "OUTPUT", DeltaOtn_Vcy).
  hCall:SET-PARAMETER(53, "DOUBLE", "OUTPUT", DeltaOtn_Vm).
  hCall:SET-PARAMETER(54, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(55, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:SET-PARAMETER(56, "DOUBLE", "OUTPUT", VolumetricExpansion).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM7 returns logical
  (
  input M1 as decimal,
  input M2 as decimal,
  input H1 as decimal,
  input H2 as decimal,
  input H1_water as decimal,
  input H2_water as decimal,
  input CalibrationTable as character,
  input CalibrationBelt as character,
  input Tv1 as decimal,
  input Tv2 as decimal,
  input Tr1 as decimal,
  input Tr2 as decimal,
  input R1 as decimal,
  input R2 as decimal,
  input ToolType1 as integer,
  input ToolType2 as integer,
  input DeltaOtn_K as decimal,
  input OperDirection as integer,
  input ToolAutomationLevel_H1 as integer,
  input ToolAutomationLevel_H2 as integer,
  input ToolAutomationLevel_H_Water1 as integer,
  input ToolAutomationLevel_H_Water2 as integer,
  input ToolAutomationLevel_R1 as integer,
  input ToolAutomationLevel_R2 as integer,
  input ToolAutomationLevel_Tv1 as integer,
  input ToolAutomationLevel_Tv2 as integer,
  input ToolAutomationLevel_Tr1 as integer,
  input ToolAutomationLevel_Tr2 as integer,
  input DeltaAbs_H_CalcType1 as integer,
  input DeltaAbs_H_CalcType2 as integer,
  input DeltaAbs_H_Water_CalcType1 as integer,
  input DeltaAbs_H_Water_CalcType2 as integer,
  input DeltaAbs_H1 as decimal,
  input DeltaAbs_H2 as decimal,
  input DeltaAbs_H_Water1 as decimal,
  input DeltaAbs_H_Water2 as decimal,
  input DeltaAbs_R1 as decimal,
  input DeltaAbs_R2 as decimal,
  input DeltaAbs_Tv1 as decimal,
  input DeltaAbs_Tv2 as decimal,
  input DeltaAbs_Tr1 as decimal,
  input DeltaAbs_Tr2 as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output V_total1 as decimal,
  output V_total2 as decimal,
  output V_water1 as decimal,
  output V_water2 as decimal,
  output Delta_V1 as decimal,
  output Delta_V2 as decimal,
  output M as decimal,
  output DeltaOtn_M as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt7"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 59
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", M1).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", M2).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", H1).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", H2).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", H1_water).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", H2_water).
  hCall:SET-PARAMETER(10, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(11, "CHARACTER", "INPUT", CalibrationBelt).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", Tv1).
  hCall:SET-PARAMETER(13, "DOUBLE", "INPUT", Tv2).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", Tr1).
  hCall:SET-PARAMETER(15, "DOUBLE", "INPUT", Tr2).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", R1).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", R2).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", ToolType1).
  hCall:SET-PARAMETER(19, "LONG", "INPUT", ToolType2).
  hCall:SET-PARAMETER(20, "DOUBLE", "INPUT", DeltaOtn_K).
  hCall:SET-PARAMETER(21, "LONG", "INPUT", OperDirection).
  hCall:SET-PARAMETER(22, "LONG", "INPUT", ToolAutomationLevel_H1).
  hCall:SET-PARAMETER(23, "LONG", "INPUT", ToolAutomationLevel_H2).
  hCall:SET-PARAMETER(24, "LONG", "INPUT", ToolAutomationLevel_H_Water1).
  hCall:SET-PARAMETER(25, "LONG", "INPUT", ToolAutomationLevel_H_Water2).
  hCall:SET-PARAMETER(26, "LONG", "INPUT", ToolAutomationLevel_R1).
  hCall:SET-PARAMETER(27, "LONG", "INPUT", ToolAutomationLevel_R2).
  hCall:SET-PARAMETER(28, "LONG", "INPUT", ToolAutomationLevel_Tv1).
  hCall:SET-PARAMETER(29, "LONG", "INPUT", ToolAutomationLevel_Tv2).
  hCall:SET-PARAMETER(30, "LONG", "INPUT", ToolAutomationLevel_Tr1).
  hCall:SET-PARAMETER(31, "LONG", "INPUT", ToolAutomationLevel_Tr2).
  hCall:SET-PARAMETER(32, "LONG", "INPUT", DeltaAbs_H_CalcType1).
  hCall:SET-PARAMETER(33, "LONG", "INPUT", DeltaAbs_H_CalcType2).
  hCall:SET-PARAMETER(34, "LONG", "INPUT", DeltaAbs_H_Water_CalcType1).
  hCall:SET-PARAMETER(35, "LONG", "INPUT", DeltaAbs_H_Water_CalcType2).
  hCall:SET-PARAMETER(36, "DOUBLE", "INPUT", DeltaAbs_H1).
  hCall:SET-PARAMETER(37, "DOUBLE", "INPUT", DeltaAbs_H2).
  hCall:SET-PARAMETER(38, "DOUBLE", "INPUT", DeltaAbs_H_Water1).
  hCall:SET-PARAMETER(39, "DOUBLE", "INPUT", DeltaAbs_H_Water2).
  hCall:SET-PARAMETER(40, "DOUBLE", "INPUT", DeltaAbs_R1).
  hCall:SET-PARAMETER(41, "DOUBLE", "INPUT", DeltaAbs_R2).
  hCall:SET-PARAMETER(42, "DOUBLE", "INPUT", DeltaAbs_Tv1).
  hCall:SET-PARAMETER(43, "DOUBLE", "INPUT", DeltaAbs_Tv2).
  hCall:SET-PARAMETER(44, "DOUBLE", "INPUT", DeltaAbs_Tr1).
  hCall:SET-PARAMETER(45, "DOUBLE", "INPUT", DeltaAbs_Tr2).
  hCall:SET-PARAMETER(46, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(47, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(48, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(49, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(50, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(51, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(52, "DOUBLE", "OUTPUT", V_total1).
  hCall:SET-PARAMETER(53, "DOUBLE", "OUTPUT", V_total2).
  hCall:SET-PARAMETER(54, "DOUBLE", "OUTPUT", V_water1).
  hCall:SET-PARAMETER(55, "DOUBLE", "OUTPUT", V_water2).
  hCall:SET-PARAMETER(56, "DOUBLE", "OUTPUT", Delta_V1).
  hCall:SET-PARAMETER(57, "DOUBLE", "OUTPUT", Delta_V2).
  hCall:SET-PARAMETER(58, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(59, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM13 returns logical
 (
  input Mpokr as decimal,
  input Rprov as decimal,
  input Vdisp as decimal,
  input CoverFloatingHeight as decimal,
  input H as decimal,
  input H_water as decimal,
  input CalibrationTable as character,
  input CalibrationBelt as character,
  input P0 as decimal,
  input Pv as decimal,
  input Tv as decimal,
  input Tr as decimal,
  input R as decimal,
  input Tcy as decimal,
  input ToolType as integer,
  input DeltaOtn_K as decimal,
  input DeadZone_Reservoir as decimal,
  input A_Reservoir as decimal,
  input A_LevelMeasurementTool as decimal,
  input ToolAutomationLevel_H as integer,
  input ToolAutomationLevel_H_Water as integer,
  input ToolAutomationLevel_R as integer,
  input ToolAutomationLevel_Tv as integer,
  input ToolAutomationLevel_Tr as integer,
  input DeltaAbs_H_CalcType as integer,
  input DeltaAbs_H_Water_CalcType as integer,
  input DeltaAbs_H as decimal,
  input DeltaAbs_H_Water as decimal,
  input DeltaAbs_R as decimal,
  input DeltaAbs_Tv as decimal,
  input DeltaAbs_Tr as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output V_total as decimal,
  output V_water as decimal,
  output DeltaV as decimal,
  output V_product as decimal,
  output Vcy as decimal,
  output Rcy as decimal,
  output V as decimal,
  output CTL_base_alt as decimal,
  output CPL_base_alt as decimal,
  output CTPL_base_alt as decimal,
  output Fp_base_alt as decimal,
  output CTL_obs_base as decimal,
  output CPL_obs_base as decimal,
  output CTPL_obs_base as decimal,
  output Fp_obs_base as decimal,
  output Rv as decimal,
  output DeltaOtn_Vcy as decimal,
  output DeltaOtn_Vm as decimal,
  output M as decimal,
  output DeltaOtn_M as decimal,
  output VolumetricExpansion as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt13"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 61
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", Mpokr).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", Rprov).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", Vdisp).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", CoverFloatingHeight).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", H).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", H_water).
  hCall:SET-PARAMETER(10, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(11, "CHARACTER", "INPUT", CalibrationBelt).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", P0).
  hCall:SET-PARAMETER(13, "DOUBLE", "INPUT", Pv).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", Tv).
  hCall:SET-PARAMETER(15, "DOUBLE", "INPUT", Tr).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", R).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", Tcy).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", ToolType).
  hCall:SET-PARAMETER(19, "DOUBLE", "INPUT", DeltaOtn_K).
  hCall:SET-PARAMETER(20, "DOUBLE", "INPUT", DeadZone_Reservoir).
  hCall:SET-PARAMETER(21, "DOUBLE", "INPUT", A_Reservoir).
  hCall:SET-PARAMETER(22, "DOUBLE", "INPUT", A_LevelMeasurementTool).
  hCall:SET-PARAMETER(23, "LONG", "INPUT", ToolAutomationLevel_H).
  hCall:SET-PARAMETER(24, "LONG", "INPUT", ToolAutomationLevel_H_Water).
  hCall:SET-PARAMETER(25, "LONG", "INPUT", ToolAutomationLevel_R).
  hCall:SET-PARAMETER(26, "LONG", "INPUT", ToolAutomationLevel_Tv).
  hCall:SET-PARAMETER(27, "LONG", "INPUT", ToolAutomationLevel_Tr).
  hCall:SET-PARAMETER(28, "LONG", "INPUT", DeltaAbs_H_CalcType).
  hCall:SET-PARAMETER(29, "LONG", "INPUT", DeltaAbs_H_Water_CalcType).
  hCall:SET-PARAMETER(30, "DOUBLE", "INPUT", DeltaAbs_H).
  hCall:SET-PARAMETER(31, "DOUBLE", "INPUT", DeltaAbs_H_Water).
  hCall:SET-PARAMETER(32, "DOUBLE", "INPUT", DeltaAbs_R).
  hCall:SET-PARAMETER(33, "DOUBLE", "INPUT", DeltaAbs_Tv).
  hCall:SET-PARAMETER(34, "DOUBLE", "INPUT", DeltaAbs_Tr).
  hCall:SET-PARAMETER(35, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(36, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(37, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(38, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(39, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(40, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(41, "DOUBLE", "OUTPUT", V_total).
  hCall:SET-PARAMETER(42, "DOUBLE", "OUTPUT", V_water).
  hCall:SET-PARAMETER(43, "DOUBLE", "OUTPUT", DeltaV).
  hCall:SET-PARAMETER(44, "DOUBLE", "OUTPUT", V_product).
  hCall:SET-PARAMETER(45, "DOUBLE", "OUTPUT", Vcy).
  hCall:SET-PARAMETER(46, "DOUBLE", "OUTPUT", Rcy).
  hCall:SET-PARAMETER(47, "DOUBLE", "OUTPUT", V).
  hCall:SET-PARAMETER(48, "DOUBLE", "OUTPUT", CTL_base_alt).
  hCall:SET-PARAMETER(49, "DOUBLE", "OUTPUT", CPL_base_alt).
  hCall:SET-PARAMETER(50, "DOUBLE", "OUTPUT", CTPL_base_alt).
  hCall:SET-PARAMETER(51, "DOUBLE", "OUTPUT", Fp_base_alt).
  hCall:SET-PARAMETER(52, "DOUBLE", "OUTPUT", CTL_obs_base).
  hCall:SET-PARAMETER(53, "DOUBLE", "OUTPUT", CPL_obs_base).
  hCall:SET-PARAMETER(54, "DOUBLE", "OUTPUT", CTPL_obs_base).
  hCall:SET-PARAMETER(55, "DOUBLE", "OUTPUT", Fp_obs_base).
  hCall:SET-PARAMETER(56, "DOUBLE", "OUTPUT", Rv).
  hCall:SET-PARAMETER(57, "DOUBLE", "OUTPUT", DeltaOtn_Vcy).
  hCall:SET-PARAMETER(58, "DOUBLE", "OUTPUT", DeltaOtn_Vm).
  hCall:SET-PARAMETER(59, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(60, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:SET-PARAMETER(61, "DOUBLE", "OUTPUT", VolumetricExpansion).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM14 returns logical
  (
  input M1 as decimal,
  input M2 as decimal,
  input H1 as decimal,
  input H2 as decimal,
  input H1_water as decimal,
  input H2_water as decimal,
  input CalibrationTable as character,
  input CalibrationBelt as character,
  input Tv1 as decimal,
  input Tv2 as decimal,
  input Tr1 as decimal,
  input Tr2 as decimal,
  input R1 as decimal,
  input R2 as decimal,
  input ToolType1 as integer,
  input ToolType2 as integer,
  input DeltaOtn_K as decimal,
  input OperDirection as integer,
  input ToolAutomationLevel_H1 as integer,
  input ToolAutomationLevel_H2 as integer,
  input ToolAutomationLevel_H_Water1 as integer,
  input ToolAutomationLevel_H_Water2 as integer,
  input ToolAutomationLevel_R1 as integer,
  input ToolAutomationLevel_R2 as integer,
  input ToolAutomationLevel_Tv1 as integer,
  input ToolAutomationLevel_Tv2 as integer,
  input ToolAutomationLevel_Tr1 as integer,
  input ToolAutomationLevel_Tr2 as integer,
  input DeltaAbs_H_CalcType1 as integer,
  input DeltaAbs_H_CalcType2 as integer,
  input DeltaAbs_H_Water_CalcType1 as integer,
  input DeltaAbs_H_Water_CalcType2 as integer,
  input DeltaAbs_H1 as decimal,
  input DeltaAbs_H2 as decimal,
  input DeltaAbs_H_Water1 as decimal,
  input DeltaAbs_H_Water2 as decimal,
  input DeltaAbs_R1 as decimal,
  input DeltaAbs_R2 as decimal,
  input DeltaAbs_Tv1 as decimal,
  input DeltaAbs_Tv2 as decimal,
  input DeltaAbs_Tr1 as decimal,
  input DeltaAbs_Tr2 as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output V_total1 as decimal,
  output V_total2 as decimal,
  output V_water1 as decimal,
  output V_water2 as decimal,
  output Delta_V1 as decimal,
  output Delta_V2 as decimal,
  output M as decimal,
  output DeltaOtn_M as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt14"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 59
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", M1).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", M2).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", H1).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", H2).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", H1_water).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", H2_water).
  hCall:SET-PARAMETER(10, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(11, "CHARACTER", "INPUT", CalibrationBelt).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", Tv1).
  hCall:SET-PARAMETER(13, "DOUBLE", "INPUT", Tv2).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", Tr1).
  hCall:SET-PARAMETER(15, "DOUBLE", "INPUT", Tr2).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", R1).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", R2).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", ToolType1).
  hCall:SET-PARAMETER(19, "LONG", "INPUT", ToolType2).
  hCall:SET-PARAMETER(20, "DOUBLE", "INPUT", DeltaOtn_K).
  hCall:SET-PARAMETER(21, "LONG", "INPUT", OperDirection).
  hCall:SET-PARAMETER(22, "LONG", "INPUT", ToolAutomationLevel_H1).
  hCall:SET-PARAMETER(23, "LONG", "INPUT", ToolAutomationLevel_H2).
  hCall:SET-PARAMETER(24, "LONG", "INPUT", ToolAutomationLevel_H_Water1).
  hCall:SET-PARAMETER(25, "LONG", "INPUT", ToolAutomationLevel_H_Water2).
  hCall:SET-PARAMETER(26, "LONG", "INPUT", ToolAutomationLevel_R1).
  hCall:SET-PARAMETER(27, "LONG", "INPUT", ToolAutomationLevel_R2).
  hCall:SET-PARAMETER(28, "LONG", "INPUT", ToolAutomationLevel_Tv1).
  hCall:SET-PARAMETER(29, "LONG", "INPUT", ToolAutomationLevel_Tv2).
  hCall:SET-PARAMETER(30, "LONG", "INPUT", ToolAutomationLevel_Tr1).
  hCall:SET-PARAMETER(31, "LONG", "INPUT", ToolAutomationLevel_Tr2).
  hCall:SET-PARAMETER(32, "LONG", "INPUT", DeltaAbs_H_CalcType1).
  hCall:SET-PARAMETER(33, "LONG", "INPUT", DeltaAbs_H_CalcType2).
  hCall:SET-PARAMETER(34, "LONG", "INPUT", DeltaAbs_H_Water_CalcType1).
  hCall:SET-PARAMETER(35, "LONG", "INPUT", DeltaAbs_H_Water_CalcType2).
  hCall:SET-PARAMETER(36, "DOUBLE", "INPUT", DeltaAbs_H1).
  hCall:SET-PARAMETER(37, "DOUBLE", "INPUT", DeltaAbs_H2).
  hCall:SET-PARAMETER(38, "DOUBLE", "INPUT", DeltaAbs_H_Water1).
  hCall:SET-PARAMETER(39, "DOUBLE", "INPUT", DeltaAbs_H_Water2).
  hCall:SET-PARAMETER(40, "DOUBLE", "INPUT", DeltaAbs_R1).
  hCall:SET-PARAMETER(41, "DOUBLE", "INPUT", DeltaAbs_R2).
  hCall:SET-PARAMETER(42, "DOUBLE", "INPUT", DeltaAbs_Tv1).
  hCall:SET-PARAMETER(43, "DOUBLE", "INPUT", DeltaAbs_Tv2).
  hCall:SET-PARAMETER(44, "DOUBLE", "INPUT", DeltaAbs_Tr1).
  hCall:SET-PARAMETER(45, "DOUBLE", "INPUT", DeltaAbs_Tr2).
  hCall:SET-PARAMETER(46, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(47, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(48, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(49, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(50, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(51, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(52, "DOUBLE", "OUTPUT", V_total1).
  hCall:SET-PARAMETER(53, "DOUBLE", "OUTPUT", V_total2).
  hCall:SET-PARAMETER(54, "DOUBLE", "OUTPUT", V_water1).
  hCall:SET-PARAMETER(55, "DOUBLE", "OUTPUT", V_water2).
  hCall:SET-PARAMETER(56, "DOUBLE", "OUTPUT", Delta_V1).
  hCall:SET-PARAMETER(57, "DOUBLE", "OUTPUT", Delta_V2).
  hCall:SET-PARAMETER(58, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(59, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM26A returns logical
  (
  input Type as integer,
  input Diameter as decimal,
  input Length as decimal,
  input Width as decimal,
  input Circumference as decimal,
  input Wall as decimal,
  output Area as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt26A"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 12
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "LONG", "INPUT", Type).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", Diameter).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", Length).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", Width).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", Circumference).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", Wall).
  hCall:SET-PARAMETER(10, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(11, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(12, "DOUBLE", "OUTPUT", Area).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM31N returns logical
  (
  input V_real as decimal,
  input DeltaCorrectionType as integer,
  input CalibrationTable as character,
  input DeltaH as decimal,
  input NeckArea as decimal,
  input Tv as decimal,
  input Tr as decimal,
  input R as decimal,
  input Tcy as decimal,
  input Pr as decimal,
  input Pv as decimal,
  input ToolType as integer,
  input A_Reservoir as decimal,
  input DeltaOtn_V as decimal,
  input ToolAutomationLevel_R as integer,
  input ToolAutomationLevel_Tv as integer,
  input ToolAutomationLevel_Tr as integer,
  input DeltaAbs_R as decimal,
  input DeltaOtn_R as decimal,
  input DeltaAbs_Tv as decimal,
  input DeltaAbs_Tr as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output DeltaV_GT as decimal,
  output DeltaV as decimal,
  output Vcy as decimal,
  output Rcy as decimal,
  output Rcy20 as decimal,
  output V as decimal,
  output CTL_base_alt as decimal,
  output CPL_base_alt as decimal,
  output CTPL_base_alt as decimal,
  output Fp_base_alt as decimal,
  output CTL_obs_base as decimal,
  output CPL_obs_base as decimal,
  output CTPL_obs_base as decimal,
  output Fp_obs_base as decimal,
  output VolumetricExpansion as decimal,
  output Rv as decimal,
  output DeltaOtn_Vcy as decimal,
  output M as decimal,
  output DeltaOtn_M as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt31N"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 49
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", V_real).
  hCall:SET-PARAMETER(5, "LONG", "INPUT", DeltaCorrectionType).
  hCall:SET-PARAMETER(6, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", DeltaH).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", NeckArea).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", Tv).
  hCall:SET-PARAMETER(10, "DOUBLE", "INPUT", Tr).
  hCall:SET-PARAMETER(11, "DOUBLE", "INPUT", R).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", Tcy).
  hCall:SET-PARAMETER(13, "DOUBLE", "INPUT", Pr).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", Pv).
  hCall:SET-PARAMETER(15, "LONG", "INPUT", ToolType).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", A_Reservoir).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", DeltaOtn_V).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", ToolAutomationLevel_R).
  hCall:SET-PARAMETER(19, "LONG", "INPUT", ToolAutomationLevel_Tv).
  hCall:SET-PARAMETER(20, "LONG", "INPUT", ToolAutomationLevel_Tr).
  hCall:SET-PARAMETER(21, "DOUBLE", "INPUT", DeltaAbs_R).
  hCall:SET-PARAMETER(22, "DOUBLE", "INPUT", DeltaOtn_R).
  hCall:SET-PARAMETER(23, "DOUBLE", "INPUT", DeltaAbs_Tv).
  hCall:SET-PARAMETER(24, "DOUBLE", "INPUT", DeltaAbs_Tr).
  hCall:SET-PARAMETER(25, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(26, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(27, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(28, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(29, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(30, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(31, "DOUBLE", "OUTPUT", DeltaV_GT).
  hCall:SET-PARAMETER(32, "DOUBLE", "OUTPUT", DeltaV).
  hCall:SET-PARAMETER(33, "DOUBLE", "OUTPUT", Vcy).
  hCall:SET-PARAMETER(34, "DOUBLE", "OUTPUT", Rcy).
  hCall:SET-PARAMETER(35, "DOUBLE", "OUTPUT", Rcy20).
  hCall:SET-PARAMETER(36, "DOUBLE", "OUTPUT", V).
  hCall:SET-PARAMETER(37, "DOUBLE", "OUTPUT", CTL_base_alt).
  hCall:SET-PARAMETER(38, "DOUBLE", "OUTPUT", CPL_base_alt).
  hCall:SET-PARAMETER(39, "DOUBLE", "OUTPUT", CTPL_base_alt).
  hCall:SET-PARAMETER(40, "DOUBLE", "OUTPUT", Fp_base_alt).
  hCall:SET-PARAMETER(41, "DOUBLE", "OUTPUT", CTL_obs_base).
  hCall:SET-PARAMETER(42, "DOUBLE", "OUTPUT", CPL_obs_base).
  hCall:SET-PARAMETER(43, "DOUBLE", "OUTPUT", CTPL_obs_base).
  hCall:SET-PARAMETER(44, "DOUBLE", "OUTPUT", Fp_obs_base).
  hCall:SET-PARAMETER(45, "DOUBLE", "OUTPUT", VolumetricExpansion).
  hCall:SET-PARAMETER(46, "DOUBLE", "OUTPUT", Rv).
  hCall:SET-PARAMETER(47, "DOUBLE", "OUTPUT", DeltaOtn_Vcy).
  hCall:SET-PARAMETER(48, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(49, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM53 returns logical
  (
  input H as decimal,
  input CalibrationTable as character,
  input T as decimal,
  input R_liquid as decimal,
  input R_gas as decimal,
  input A_Reservoir as decimal,
  input DeltaOtn_K as decimal,
  input DeltaOtn_K_full as decimal,
  input DeltaAbs_H as decimal,
  input DeltaAbs_R_liquid as decimal,
  input DeltaAbs_R_gas as decimal,
  input Use_DeltaOtn_R_liquid_IN as integer,
  input DeltaOtn_R_liquid_IN as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output C_HN as decimal,
  output C_HN_delta as decimal,
  output C_full as decimal,
  output V_liquid as decimal,
  output V_gas as decimal,
  output M_liquid as decimal,
  output M_gas as decimal,
  output M as decimal,
  output Kf as decimal,
  output DeltaOtn_H as decimal,
  output DeltaOtn_R_liquid as decimal,
  output DeltaOtn_R_gas as decimal,
  output DeltaOtn_M_liquid as decimal,
  output DeltaOtn_M_gas as decimal,
  output DeltaOtn_M as decimal,
  output H_min_liquid as decimal,
  output H_min as decimal,
  output A as decimal,
  output B as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt53"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 41
  .
  if DeltaOtn_R_liquid_IN = 0.42
  then
    DeltaOtn_R_liquid_IN = DeltaOtn_R_liquid_IN - 0.0000000001
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", H).
  hCall:SET-PARAMETER(5, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", T).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", R_liquid).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", R_gas).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", A_Reservoir).
  hCall:SET-PARAMETER(10, "DOUBLE", "INPUT", DeltaOtn_K).
  hCall:SET-PARAMETER(11, "DOUBLE", "INPUT", DeltaOtn_K_full).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", DeltaAbs_H).
  hCall:SET-PARAMETER(13, "DOUBLE", "INPUT", DeltaAbs_R_liquid).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", DeltaAbs_R_gas).
  hCall:SET-PARAMETER(15, "SHORT", "INPUT", Use_DeltaOtn_R_liquid_IN).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", DeltaOtn_R_liquid_IN).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(19, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(20, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(21, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(22, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(23, "DOUBLE", "OUTPUT", C_HN).
  hCall:SET-PARAMETER(24, "DOUBLE", "OUTPUT", C_HN_delta).
  hCall:SET-PARAMETER(25, "DOUBLE", "OUTPUT", C_full).
  hCall:SET-PARAMETER(26, "DOUBLE", "OUTPUT", V_liquid).
  hCall:SET-PARAMETER(27, "DOUBLE", "OUTPUT", V_gas).
  hCall:SET-PARAMETER(28, "DOUBLE", "OUTPUT", M_liquid).
  hCall:SET-PARAMETER(29, "DOUBLE", "OUTPUT", M_gas).
  hCall:SET-PARAMETER(30, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(31, "DOUBLE", "OUTPUT", Kf).
  hCall:SET-PARAMETER(32, "DOUBLE", "OUTPUT", DeltaOtn_H).
  hCall:SET-PARAMETER(33, "DOUBLE", "OUTPUT", DeltaOtn_R_liquid).
  hCall:SET-PARAMETER(34, "DOUBLE", "OUTPUT", DeltaOtn_R_gas).
  hCall:SET-PARAMETER(35, "DOUBLE", "OUTPUT", DeltaOtn_M_liquid).
  hCall:SET-PARAMETER(36, "DOUBLE", "OUTPUT", DeltaOtn_M_gas).
  hCall:SET-PARAMETER(37, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:SET-PARAMETER(38, "DOUBLE", "OUTPUT", H_min_liquid).
  hCall:SET-PARAMETER(39, "DOUBLE", "OUTPUT", H_min).
  hCall:SET-PARAMETER(40, "DOUBLE", "OUTPUT", A).
  hCall:SET-PARAMETER(41, "DOUBLE", "OUTPUT", B).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM55 returns logical
  (
  input R15 as decimal,
  input T as decimal,
  input Round_R as integer,
  input Round_T as integer,
  output R as decimal,
  output CTL as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt55"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 11
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", R15).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", T).
  hCall:SET-PARAMETER(6, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(7, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(8, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(9, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(10, "DOUBLE", "OUTPUT", R).
  hCall:SET-PARAMETER(11, "DOUBLE", "OUTPUT", CTL).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM56 returns logical
  (
  input M_type as integer,
  input M as decimal extent 16,
  input T as decimal,
  input P_type as integer,
  input P_extra as decimal,
  input P_atmosphere as decimal,
  input M_pseudo as decimal,
  input R_pseudo as decimal,
  input Round_T as integer,
  input Round_R as integer,
  output R as decimal,
  output P_vapor as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt56"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 17
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "LONG", "INPUT", M_type).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", M).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", T).
  hCall:SET-PARAMETER(7, "LONG", "INPUT", P_type).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", P_extra).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", P_atmosphere).
  hCall:SET-PARAMETER(10, "DOUBLE", "INPUT", M_pseudo).
  hCall:SET-PARAMETER(11, "DOUBLE", "INPUT", R_pseudo).
  hCall:SET-PARAMETER(12, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(13, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(14, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(15, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(16, "DOUBLE", "OUTPUT", R).
  hCall:SET-PARAMETER(17, "DOUBLE", "OUTPUT", P_vapor).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM57 returns logical
  (
  input H as decimal,
  input ToolType as integer,
  output DeltaAbs_H as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt57"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 8
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", H).
  hCall:SET-PARAMETER(5, "LONG", "INPUT", ToolType).
  hCall:SET-PARAMETER(6, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(7, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(8, "DOUBLE", "OUTPUT", DeltaAbs_H).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
define variable g-log        as logical   no-undo.
define variable g-log2       as logical   no-undo.
define variable varlog       as logical   no-undo.
define variable v-return-val as character no-undo initial "":U .
define variable v-min-dens   as decimal   no-undo.
define variable v-max-dens   as decimal   no-undo.
define variable v-attr-type  as character no-undo.
define variable v-gds-ptrl-densities as character no-undo.
define variable rdc-value as character no-undo .
define variable rdc-type  as character no-undo.
define variable tarir-value as character no-undo .
define variable tarir-type  as character no-undo.
define variable pl-asi-sertif as logical no-undo .
define variable pl-rvd-dens as logical no-undo .
define variable pl-rvd-lvl as logical no-undo .
define variable pl-rvd-temp as logical no-undo .
define variable pl-error-mass as decimal no-undo .
define variable v-hand-input-dnst as logical no-undo initial no .
define variable v-hand-input-tmp as logical no-undo initial no .
define variable v-hand-input-lvl as logical no-undo initial no .
define variable v-sug-struct-val as character no-undo .
define variable v-POkMI-result-attr     as character no-undo.
define variable v-POkMI-warnings        as character no-undo init "" .
define variable place-diameter    as decimal no-undo .
define variable pl-dens-sr-izm    as integer no-undo .
define variable pl-level-sr-izm   as integer no-undo .
define variable pl-temp-sr-izm    as integer no-undo .
define variable v-dnst-mi-old     as integer no-undo .
define variable v-tmp-mi-old      as integer no-undo .
define variable v-lvl-mi-old      as integer no-undo .
define variable is-main-tank      as logical no-undo .
define variable place-SI          as integer no-undo.
define variable v-revision-mode   as logical no-undo init no .
define variable v-first-enter     as logical no-undo init yes .
define variable v-value           as character no-undo.
define variable v-ok              as logical   no-undo.
define VARIABLE ii as integer no-undo .
define variable twice-place-data as character no-undo .
define buffer buf_goods        for ub.goods .
define buffer buf_rvs-doc      for ub.rvs-doc.
define buffer buf_rvs-doc-attr for ub.rvs-doc-attr .
define buffer buf_rvs-line     for ub.rvs-line .
define buffer bf_pl-level      for ub.pl-level.
define buffer buf-nxt_pl-level for ub.pl-level.
define buffer buf2_place       for ub.place.
define buffer bf_place         for ub.place.
define buffer buf_trn-doc      for ub.trn-doc .
define buffer dnst_sr-izmerenia for sr-izmerenia .
define buffer tmp_sr-izmerenia for sr-izmerenia .
define buffer lvl_sr-izmerenia for sr-izmerenia .
define stream sinp .
define stream outstream.
DEFINE BUTTON b-calc
     LABEL "Рассчитать"
     SIZE 13 BY .88.
DEFINE BUTTON b-POkMI-result
     LABEL "Результаты ПОкМИ"
     SIZE 17 BY 1 .
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
DEFINE BUTTON b-mi-lvl
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     label ""
     tooltip "уровня"
     SIZE 3 BY .87.
DEFINE BUTTON b-mi-dnst
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     label ""
     tooltip "плотности"
     SIZE 3 BY .87.
DEFINE BUTTON b-mi-tmp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     label ""
     tooltip "температуры"
     SIZE 3 BY .87.
DEFINE VARIABLE v-mi-lvl AS integer FORMAT ">>>>>9":U
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE v-mi-dnst AS integer FORMAT ">>>>>9":U
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE v-mi-tmp AS integer FORMAT ">>>>>9":U
     LABEL ""
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
DEFINE BUTTON b-sug-struct
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Состав СУГ"
     SIZE 3 BY .87.
DEFINE BUTTON b-rez
     LABEL "&Резервуары"
     SIZE 12 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE delta-mass-qnty AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Отн. погр. изм. массы СУГ (ПОкМИ)"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE abs-delta-mass-qnty AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Абс. погр. изм. массы СУГ (ПОкМИ)"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE abs-delta-mass-add-qnty AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Абс. погр. изм. массы в трубопр."
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
define variable level-prc as decimal format ">>9.99":U initial ? .
define variable str-level-prc as character format "X(28)" .
define variable str-level-total as character format "X(28)" .
define variable str-level-sug as character format "X(28)" .
define variable str-level-water as character format "X(28)" .
define variable str-level-total-fact as character format "X(28)" .
define variable str-level-sug-fact as character format "X(28)" .
define variable str-level-water-fact as character format "X(28)" .
DEFINE VARIABLE CriticalDif AS DECIMAL FORMAT "->>,>>>,>>9.9":U INITIAL ?
     LABEL "Сверхнормативные расхождения"
     VIEW-AS FILL-IN
     SIZE 13 BY .88 NO-UNDO.
DEFINE VARIABLE varmeasure-water-cli-qnty AS DECIMAL FORMAT "->>,>>>,>>9.9":U INITIAL 0
     LABEL "Масса воды (кг)"
     VIEW-AS FILL-IN
     SIZE 13 BY .88 NO-UNDO.
DEFINE VARIABLE varmeasure-water-qnty AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0
     LABEL "Объем воды (л)"
     VIEW-AS FILL-IN
     SIZE 13 BY .88 NO-UNDO.
DEFINE VARIABLE varstate-water-cli-qnty AS DECIMAL FORMAT "->>,>>>,>>9.9":U INITIAL 0
     LABEL "Факт масса воды (кг)"
     VIEW-AS FILL-IN
     SIZE 13 BY .88 NO-UNDO.
DEFINE VARIABLE varsum-vol AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0
     LABEL "Объем наполнения (л)"
     VIEW-AS FILL-IN
     SIZE 13 BY .88 NO-UNDO.
DEFINE VARIABLE varstate-sum-vol AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0
     LABEL "Объем наполнения (л)"
     VIEW-AS FILL-IN
     SIZE 13 BY .88 NO-UNDO.
DEFINE VARIABLE varstate-water-qnty AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0
     LABEL "Объем воды (л)"
     VIEW-AS FILL-IN
     SIZE 13 BY .88 NO-UNDO.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 54 BY 24.75.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 52 BY 24.75.
DEFINE QUERY Dialog-Frame FOR
      tt-rvs-line SCROLLING.
define variable hide-text-dop-si as character no-undo .
DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-rez at row 1 col 21
     b-help AT ROW 1 COL 21
     b-POkMI-result at row 1 col 90
     "Доп. средства измерения:" at row 5.25 col 11
       view-as text
       size 25 by .88
     hide-text-dop-si at row 5.25 col 11
       view-as text
       size 25 by .88 no-label
     v-mi-dnst at row 5.25 col 40 label "p"
     v-mi-dnst-name at row 5.25 col 40 label "p"
     b-mi-dnst at row 5.25 col 54
     v-mi-lvl at row 5.25 col 58 label "l"
     v-mi-lvl-name at row 5.25 col 58 label "l"
     b-mi-lvl at row 5.25 col 72
     v-mi-tmp at row 5.25 col 76 label "T"
     v-mi-tmp-name at row 5.25 col 76 label "T"
     b-mi-tmp at row 5.25 col 90
     tt-rvs-line.system-qnty AT ROW 2.25 COL 10
          FORMAT "->>,>>>,>>9":U
          LABEL "Объем расчетно-книжный (л)"
          VIEW-AS FILL-IN
          SIZE 19 BY .88
     tt-rvs-line.system-cli-qnty AT ROW 2.25 COL 74 COLON-ALIGNED
          LABEL "Вес расчетно-книжный (кг)"
          FORMAT "->>,>>>,>>9.9":U
          VIEW-AS FILL-IN
          SIZE 19 BY .88
     tt-rvs-line.orig-system-qnty AT ROW 3.25 COL 25 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Первоначально (л)"
          VIEW-AS FILL-IN
          SIZE 19 BY .88
          FGCOLOR 4
     tt-rvs-line.orig-system-cli-qnty AT ROW 3.25 COL 73 COLON-ALIGNED
          FORMAT "->>,>>>,>>9.9":U
          LABEL "Первоначально (кг)"
          VIEW-AS FILL-IN
          SIZE 19 BY .88
          FGCOLOR 4
     tt-rvs-line.measure-qnty AT ROW 6.75 COL 35 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Измер. остаток (л)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-measure-qnty AT ROW 6.75 COL 90 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Факт ост. общ. ЖФ+ПФ (л)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.measure-tc-qnty AT ROW 16.75 COL 35 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Измер. объем СУГ ЖФ (л)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-measure-tc-qnty AT ROW 16.75 COL 90 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Объем СУГ ЖФ (л)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.vol-pf-sug AT ROW 17.75 COL 35 COLON-ALIGNED
          LABEL "Измер. объем СУГ ПФ (л)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-vol-pf-sug AT ROW 17.75 COL 90 COLON-ALIGNED
          LABEL "Объем СУГ ПФ (л)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.density AT ROW 19.75 COL 35 COLON-ALIGNED FORMAT "9.9999"
          LABEL "Измер. Плотность ЖФ (г/см3)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-density AT ROW 19.75 COL 90 COLON-ALIGNED FORMAT "9.9999"
          LABEL "Плотность ЖФ (г/см3)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     b-calc AT ROW 23.75 COL 65 WIDGET-ID 6
     b-sug-struct at row 20.25 col 104.8
     tt-rvs-line.dens-pf-sug AT ROW 20.75 COL 35 COLON-ALIGNED FORMAT "9.9999"
          LABEL "Измер. плотность ПФ (г/см3)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-dens-pf-sug AT ROW 20.75 COL 90 COLON-ALIGNED FORMAT "9.9999"
          LABEL "Плотность ПФ (г/см3)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.add-qnty AT ROW 12.75 COL 35 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Объем в трубопроводе (л)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.calc-add-mass AT ROW 13.75 COL 35 COLON-ALIGNED
          LABEL "Рассч. Масса в трубопроводе (кг)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.fact-calc-add-mass AT ROW 13.75 COL 90 COLON-ALIGNED
          LABEL "Рассч. Масса в трубопроводе (кг)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     abs-delta-mass-add-qnty AT ROW 14.75 COL 90 COLON-ALIGNED
     tt-rvs-line.state-add-qnty AT ROW 12.75 COL 90 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Объем в трубопроводе (л)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.brutto-qnty AT ROW 12.75 COL 35 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Общий объём СУГ ЖФ (л)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-brutto-qnty AT ROW 12.75 COL 90 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Факт объём (л)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     varmeasure-water-qnty AT ROW 27.75 COL 35 COLON-ALIGNED
     varstate-water-qnty AT ROW 27.75 COL 90 COLON-ALIGNED
     varsum-vol AT ROW 28.75 COL 35 COLON-ALIGNED
     varstate-sum-vol AT ROW 28.75 COL 90 COLON-ALIGNED
     tt-rvs-line.measure-qnty AT ROW 16.75 COL 35 COLON-ALIGNED
          LABEL "Измер. объем СУГ ЖФ (л)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-measure-qnty AT ROW 16.75 COL 90 COLON-ALIGNED
          LABEL "Объем СУГ ЖФ (л)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.measure-cli-qnty AT ROW 18.75 COL 35 COLON-ALIGNED
          FORMAT "->>,>>>,>>9.9":U
          LABEL "Измер. Масса СУГ (кг)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-measure-cli-qnty AT ROW 18.75 COL 90 COLON-ALIGNED
          FORMAT "->>,>>>,>>9.9":U
          LABEL "Масса СУГ (кг)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         CANCEL-BUTTON b-cancel.
DEFINE FRAME Dialog-Frame
     tt-rvs-line.brutto-cli-qnty AT ROW 17.75 COL 35 COLON-ALIGNED
          FORMAT "->>,>>>,>>9.9":U
          LABEL "Общая масса (кг)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-brutto-cli-qnty AT ROW 17.75 COL 90 COLON-ALIGNED
          FORMAT "->>,>>>,>>9.9":U
          LABEL "Факт общая масса (кг)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.sum-vol AT ROW 24.75 COL 35 COLON-ALIGNED
          LABEL "Общий Объем СУГ ЖФ (л)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.sum-mass AT ROW 25.75 COL 35 COLON-ALIGNED
          LABEL "Общая Масса СУГ (кг)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.fact-sum-vol AT ROW 24.75 COL 90 COLON-ALIGNED
          LABEL "Общий Объем СУГ ЖФ (л)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.fact-sum-mass AT ROW 25.75 COL 90 COLON-ALIGNED
          LABEL "Общая Масса СУГ (кг)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     varmeasure-water-cli-qnty AT ROW 27.75 COL 28.13 COLON-ALIGNED
     varstate-water-cli-qnty AT ROW 27.75 COL 90 COLON-ALIGNED
     tt-rvs-line.level-petrol AT ROW 8.75 COL 30 COLON-ALIGNED format ">>,>>9.9"
          LABEL "Измер. уровень СУГ (см)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-level-petrol AT ROW 8.75 COL 90 COLON-ALIGNED format ">>,>>9.9"
          LABEL "Факт уровень СУГ (см)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.level-total AT ROW 6.75 COL 30 COLON-ALIGNED
          FORMAT ">>,>>9.9":U
          LABEL "Измер. общий уровень (см)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-level-total AT ROW 6.75 COL 90 COLON-ALIGNED format ">>,>>9.9"
          LABEL "Факт общий уровень (см)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.level-water AT ROW 7.75 COL 30 COLON-ALIGNED
          FORMAT ">>,>>9.9":U
          LABEL "Измер. уровень воды (см)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-level-water AT ROW 7.75 COL 90 COLON-ALIGNED format ">>,>>9.9"
          LABEL "Факт уровень воды (см)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     str-level-sug AT ROW 8.75 COL 30 COLON-ALIGNED
          LABEL "Измер. уровень СУГ (см)"
          VIEW-AS FILL-IN
          SIZE 20 BY .88
     str-level-sug-fact AT ROW 8.75 COL 90 COLON-ALIGNED
          LABEL "Факт уровень СУГ (см)"
          VIEW-AS FILL-IN
          SIZE 20 BY .88
     str-level-total AT ROW 6.75 COL 30 COLON-ALIGNED
          LABEL "Измер. общий уровень (см)"
          VIEW-AS FILL-IN
          SIZE 20 BY .88
     str-level-total-fact AT ROW 6.75 COL 90 COLON-ALIGNED
          LABEL "Факт общий уровень (см)"
          VIEW-AS FILL-IN
          SIZE 20 BY .88
     str-level-water AT ROW 7.75 COL 30 COLON-ALIGNED
          LABEL "Измер. уровень воды (см)"
          VIEW-AS FILL-IN
          SIZE 20 BY .88
     str-level-water-fact AT ROW 7.75 COL 90 COLON-ALIGNED
          LABEL "Факт уровень воды (см)"
          VIEW-AS FILL-IN
          SIZE 20 BY .88
     tt-rvs-line.temperature AT ROW 9.75 COL 30 COLON-ALIGNED
          FORMAT "->>9.9":U
          LABEL "Температура средняя (°С)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-temperature AT ROW 9.75 COL 90 COLON-ALIGNED
          FORMAT "->>9.9":U
          LABEL "Температура продукта в рез. (°С)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.meas-mh-qnty AT ROW 23.75 COL 29.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY .88
     tt-rvs-line.state-mh-qnty AT ROW 32.75 COL 15.5 COLON-ALIGNED
          LABEL "Оборот по ТРК"
          VIEW-AS FILL-IN
          SIZE 10 BY .88
     tt-rvs-line.meas-am-qnty AT ROW 31.75 COL 29.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY .88
     tt-rvs-line.state-am-qnty AT ROW 32.75 COL 55.5 COLON-ALIGNED
          LABEL "Сумма оборота по ТРК"
          VIEW-AS FILL-IN
          SIZE 10 BY .88
     tt-rvs-line.meas-cf-qnty AT ROW 32.75 COL 30.13 COLON-ALIGNED
          LABEL "Измеренное кол-во наливов"
          VIEW-AS FILL-IN
          SIZE 17 BY .88
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         CANCEL-BUTTON b-cancel.
DEFINE FRAME Dialog-Frame
     tt-rvs-line.state-cf-qnty AT ROW 32.75 COL 95.5 COLON-ALIGNED
          LABEL "Количество наливов"
          VIEW-AS FILL-IN
          SIZE 10 BY .88
     tt-rvs-line.pressure-sug AT ROW 29.75 COL 35 COLON-ALIGNED
          LABEL "Изм. давление (МПа)"
          VIEW-AS FILL-IN
          SIZE 17 BY .88
     tt-rvs-line.state-pressure-sug AT ROW 29.75 COL 90 COLON-ALIGNED
          LABEL "Давление (МПа)"
          VIEW-AS FILL-IN
          SIZE 10 BY .88
     level-prc at row 30.75 COL 90 COLON-ALIGNED
          label "Уровень наполнения (%)"
          VIEW-AS FILL-IN
          SIZE 6 BY .88
     delta-mass-qnty AT ROW 21.75 COL 90 COLON-ALIGNED  WIDGET-ID 22
     abs-delta-mass-qnty AT ROW 22.75 COL 90 COLON-ALIGNED  WIDGET-ID 22
     CriticalDif AT ROW 4.25 COL 34 COLON-ALIGNED WIDGET-ID 2
     RECT-2 AT ROW 6.5 COL 54
     RECT-3 AT ROW 6.5 COL 2
     SPACE(2) SKIP(1)
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
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
ON CHOOSE OF b-POkMI-result IN FRAME Dialog-Frame
DO:
  if trim(v-POkMI-warnings) > ""
  then do :
    message (v-POkMI-result-attr + chr(10) + " " + chr(10) + " " + chr(10) + "Предупреждения:" + chr(10) + v-POkMI-warnings) view-as alert-box information .
  end .
  else do :
    message v-POkMI-result-attr view-as alert-box information .
  end .
END.
ON CHOOSE OF b-mi-lvl IN FRAME Dialog-Frame
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
    apply "leave" to v-mi-lvl in frame Dialog-Frame .
  end.
END.
on entry of v-mi-lvl-name IN FRAME Dialog-Frame
do:
  apply "entry" to v-mi-lvl in frame Dialog-Frame.
end .
on entry of v-mi-lvl IN FRAME Dialog-Frame
do:
  hide v-mi-lvl-name in frame Dialog-Frame.
end .
on return of v-mi-lvl IN FRAME Dialog-Frame
do:
  apply "leave" to v-mi-lvl IN FRAME Dialog-Frame .
end .
on del, backspace, "?" of v-mi-lvl in frame Dialog-Frame
do :
  v-mi-lvl = ? .
  v-mi-lvl:screen-value = "?" .
end .
on leave of v-mi-lvl IN FRAME Dialog-Frame
do:
  define variable v-old-val as character no-undo .
  v-old-val = string(v-mi-lvl) .
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
  display v-mi-lvl-name with frame Dialog-Frame.
  enable v-mi-lvl-name with frame Dialog-Frame.
  assign v-mi-lvl .
  if string(v-mi-lvl) <> v-old-val
  then do :
    tt-rvs-line.state-level-total = 0 .
    tt-rvs-line.state-level-water = 0 .
  end .
  display tt-rvs-line.state-level-total tt-rvs-line.state-level-water with frame Dialog-Frame.
  enable
    tt-rvs-line.state-level-total
    tt-rvs-line.state-level-water
    tt-rvs-line.state-temperature
    b-sug-struct
  with frame Dialog-Frame.
  apply "leave" to tt-rvs-line.state-level-total in frame Dialog-Frame .
end .
ON CHOOSE OF b-mi-dnst IN FRAME Dialog-Frame
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
    apply "leave" to v-mi-dnst in frame Dialog-Frame .
  end.
END.
on entry of v-mi-dnst-name IN FRAME Dialog-Frame
do:
  apply "entry" to v-mi-dnst in frame Dialog-Frame.
end .
on entry of v-mi-dnst IN FRAME Dialog-Frame
do:
  hide v-mi-dnst-name in frame Dialog-Frame.
end .
on return of v-mi-dnst IN FRAME Dialog-Frame
do:
  apply "leave" to v-mi-dnst IN FRAME Dialog-Frame .
end .
on del, backspace, "?" of v-mi-dnst in frame Dialog-Frame
do :
  v-mi-dnst = ? .
  v-mi-dnst:screen-value = "?" .
end .
on leave of v-mi-dnst IN FRAME Dialog-Frame
do:
  define variable vlog as logical no-undo .
  define variable v-old-val as character no-undo .
  v-old-val = string(v-mi-dnst) .
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
  end .
  v-mi-dnst-name = dnst_sr-izmerenia.sr-model .
  display v-mi-dnst-name with frame Dialog-Frame.
  enable v-mi-dnst-name with frame Dialog-Frame.
  assign v-mi-dnst .
  if dnst_sr-izmerenia.sr-temperature
  and v-mi-dnst <> v-mi-tmp
  and b-mi-tmp:sensitive
  then do :
      v-mi-tmp = v-mi-dnst .
      v-mi-tmp:screen-value = v-mi-dnst:screen-value .
      v-mi-tmp-name = v-mi-dnst-name .
      apply "leave" to v-mi-tmp in frame Dialog-Frame .
  end .
  apply "leave" to tt-rvs-line.state-level-total in frame Dialog-Frame .
end .
ON CHOOSE OF b-mi-tmp IN FRAME Dialog-Frame
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
    apply "leave" to v-mi-tmp in frame Dialog-Frame .
  end.
END.
on entry of v-mi-tmp-name IN FRAME Dialog-Frame
do:
  apply "entry" to v-mi-tmp in frame Dialog-Frame.
end .
on entry of v-mi-tmp IN FRAME Dialog-Frame
do:
  hide v-mi-tmp-name in frame Dialog-Frame.
end .
on return of v-mi-tmp IN FRAME Dialog-Frame
do:
  apply "leave" to v-mi-tmp IN FRAME Dialog-Frame .
end .
on del, backspace, "?" of v-mi-tmp in frame Dialog-Frame
do :
  v-mi-tmp = ? .
  v-mi-tmp:screen-value = "?" .
end .
on leave of v-mi-tmp IN FRAME Dialog-Frame
do:
  define variable vlog as logical no-undo .
  define variable v-old-val as character no-undo .
  v-old-val = string(v-mi-tmp) .
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
  end .
  v-mi-tmp-name = tmp_sr-izmerenia.sr-model .
  display v-mi-tmp-name with frame Dialog-Frame.
  enable v-mi-tmp-name with frame Dialog-Frame.
  assign v-mi-tmp .
  if string(v-mi-tmp) <> v-old-val
  then do :
    tt-rvs-line.state-temperature = 0 .
  end .
  display tt-rvs-line.state-temperature  with frame Dialog-Frame.
  if tmp_sr-izmerenia.sr-density
  and v-mi-tmp <> v-mi-dnst
  and b-mi-dnst:sensitive
  then do :
      v-mi-dnst = v-mi-tmp .
      v-mi-dnst:screen-value = v-mi-tmp:screen-value .
      v-mi-dnst-name = v-mi-tmp-name .
      apply "leave" to v-mi-dnst in frame Dialog-Frame .
  end .
  apply "leave" to tt-rvs-line.state-level-total in frame Dialog-Frame .
end .
ON CHOOSE OF b-calc IN FRAME Dialog-Frame
DO:
define variable v-mm as com-handle.
define variable v-proc as character no-undo.
define variable v-pokmi-dll-version as character no-undo .
define variable v-code            as character no-undo.
define variable ii                as integer   no-undo.
define variable place-type        as integer no-undo.
define variable place-SI          as integer no-undo.
define variable place-diameter    as decimal no-undo.
define variable place-ratio-error as decimal no-undo.
define variable dens-prov         as decimal no-undo format "9.9999999999":U.
define variable CalibTable        as character no-undo initial "".
define variable ToolType          as integer no-undo.
define variable LevelToolType          as integer no-undo.
define variable A_LevelMeasurementTool  as decimal no-undo.
define variable DeltaAbs_H              as decimal no-undo.
define variable DeltaAbs_H_Water        as decimal no-undo.
define variable DeltaAbs_R_liquid          as decimal no-undo.
define variable DeltaAbs_R_gas    as decimal no-undo.
define variable DeltaAbs_Tv             as decimal no-undo.
define variable DeltaAbs_Tr             as decimal no-undo.
define variable DeltaOtn_N              as decimal no-undo init 0.05 .
define variable DeltaOtn_H              as decimal no-undo.
define variable DeltaOtn_H_Water        as decimal no-undo.
define variable DeltaOtn_R              as decimal no-undo.
define variable DeltaOtn_K              as decimal no-undo.
define variable DeltaOtn_K_Full         as decimal no-undo.
define variable Use_DeltaOtn_R_liquid_IN as logical no-undo.
define variable DeltaOtn_R_liquid_IN    as decimal no-undo.
define variable A_Reservoir             as decimal no-undo init 0.0000125 .
define variable temp-for-pomi           as integer no-undo.
define variable error-string            as character no-undo.
define variable v-is-meas               as logical no-undo.
define variable v-mm-density            as decimal no-undo.
define variable DeltaV1                 as decimal no-undo .
define variable DeltaV2                 as decimal no-undo .
define variable DeltaVSugFull           as decimal no-undo .
define variable vErr as character no-undo .
define variable vWrn as character no-undo .
define variable vDllVersion as character no-undo .
define variable C_HN              as decimal no-undo .
define variable C_HN_delta        as decimal no-undo .
define variable C_full            as decimal no-undo .
define variable V_liquid          as decimal no-undo .
define variable V_gas             as decimal no-undo .
define variable M_liquid          as decimal no-undo .
define variable M_gas             as decimal no-undo .
define variable M                 as decimal no-undo .
define variable Kf                as decimal no-undo .
define variable DeltaOtn_R_liquid as decimal no-undo .
define variable DeltaOtn_R_gas    as decimal no-undo .
define variable DeltaOtn_M_liquid as decimal no-undo .
define variable DeltaOtn_M_gas    as decimal no-undo .
define variable DeltaOtn_M        as decimal no-undo .
define variable H_min_liquid      as decimal no-undo .
define variable H_min             as decimal no-undo .
define variable A                 as decimal no-undo .
define variable B                 as decimal no-undo .
define buffer buf_sr-izmerenia for ub.sr-izmerenia .
define buffer dens_sr-izmerenia for ub.sr-izmerenia .
define buffer temp_sr-izmerenia for ub.sr-izmerenia .
define buffer level_sr-izmerenia for ub.sr-izmerenia .
define buffer buf_place     for ub.place.
define buffer full_pl-level for ub.pl-level .
define buffer sug1_pl-level for ub.pl-level .
define buffer sug2_pl-level for ub.pl-level .
define buffer buf_pl-level-attr for ub.pl-level-attr .
define buffer bf_goods for ub.goods .
define buffer bf_place for ub.place .
  assign frame Dialog-Frame tt-rvs-line.state-level-total   .
  assign frame Dialog-Frame tt-rvs-line.state-level-water   .
  assign frame Dialog-Frame tt-rvs-line.state-temperature   .
  assign frame Dialog-Frame CriticalDif .
  _trpomi :
    do on error undo, return no-apply :
    if tt-rvs-line.state-density = ? or tt-rvs-line.state-density = 0 then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите плотность ЖФ "
      view-as alert-box error.
      undo _trpomi, return .
    end.
    if tt-rvs-line.state-dens-pf-sug = ? or tt-rvs-line.state-dens-pf-sug = 0 then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите плотность ПФ "
      view-as alert-box error.
      undo _trpomi, return .
    end.
    if tt-rvs-line.state-level-total = ? or tt-rvs-line.state-level-total = 0 then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите факт. общий уровень"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-level-total in frame Dialog-Frame.
      undo _trpomi, return .
    end.
    if tt-rvs-line.state-level-water = ? then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите факт. уровень воды"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-level-water in frame Dialog-Frame.
      undo _trpomi, return .
    end.
    if tt-rvs-line.state-temperature = ? then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите температуру"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-temperature in frame Dialog-Frame.
      undo _trpomi, return .
    end.
    if tt-rvs-line.state-pressure-sug = ? then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите давление"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-pressure-sug in frame Dialog-Frame.
      undo _trpomi, return .
    end.
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
    find last sug1_pl-level no-lock
        where sug1_pl-level.pl-code  = tt-rvs-line.pl-code
          and sug1_pl-level.obj-code = tt-rvs-line.obj-code
          and sug1_pl-level.obj-type = tt-rvs-line.obj-type
          and sug1_pl-level.pl-level <= tt-rvs-line.state-level-total
          no-error .
    if not available sug1_pl-level
    then do :
      find first bf_goods no-lock where bf_goods.gds-code = tt-rvs-line.gds-code no-error .
      find first bf_place no-lock where bf_place.pl-code = tt-rvs-line.pl-code no-error .
      message
        substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Запуск ПОкМИ невозможен.'
                   ,(if available bf_place then bf_place.loc1 else "?")
                   ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                   ,(if available bf_goods then bf_goods.gds-name else "?") )
      view-as alert-box .
      undo _trpomi, return .
    end .
    DeltaOtn_K = ? .
    for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = sug1_pl-level.pl-code
                                          and buf_pl-level-attr.obj-code = sug1_pl-level.obj-code
                                          and buf_pl-level-attr.obj-type = sug1_pl-level.obj-type
                                          and buf_pl-level-attr.pl-level = sug1_pl-level.pl-level
                                          and buf_pl-level-attr.attr-code = "tarir-delta"
                                          :
      DeltaOtn_K = decimal(buf_pl-level-attr.attr-value) .
    end .
    if DeltaOtn_K = ? then DeltaOtn_K = 0.25 .
    DeltaV1 = ? .
    for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = sug1_pl-level.pl-code
                                          and buf_pl-level-attr.obj-code = sug1_pl-level.obj-code
                                          and buf_pl-level-attr.obj-type = sug1_pl-level.obj-type
                                          and buf_pl-level-attr.pl-level = sug1_pl-level.pl-level
                                          and buf_pl-level-attr.attr-code = "deltaV"
                                          :
      DeltaV1 = decimal(buf_pl-level-attr.attr-value) no-error .
    end .
    find first sug2_pl-level no-lock
        where sug2_pl-level.pl-code  = tt-rvs-line.pl-code
          and sug2_pl-level.obj-code = tt-rvs-line.obj-code
          and sug2_pl-level.obj-type = tt-rvs-line.obj-type
          and sug2_pl-level.pl-level > tt-rvs-line.state-level-total
          no-error .
    if not available sug2_pl-level
    then do :
      find first bf_goods no-lock where bf_goods.gds-code = tt-rvs-line.gds-code no-error .
      find first bf_place no-lock where bf_place.pl-code = tt-rvs-line.pl-code no-error .
      message
        substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Запуск ПОкМИ невозможен.'
                   ,(if available bf_place then bf_place.loc1 else "?")
                   ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                   ,(if available bf_goods then bf_goods.gds-name else "?") )
      view-as alert-box .
      undo _trpomi, return .
    end .
    DeltaV2 = ? .
    for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = sug2_pl-level.pl-code
                                          and buf_pl-level-attr.obj-code = sug2_pl-level.obj-code
                                          and buf_pl-level-attr.obj-type = sug2_pl-level.obj-type
                                          and buf_pl-level-attr.pl-level = sug2_pl-level.pl-level
                                          and buf_pl-level-attr.attr-code = "deltaV"
                                          :
      DeltaV2 = decimal(buf_pl-level-attr.attr-value) no-error .
    end .
    find last full_pl-level no-lock
        where full_pl-level.pl-code  = tt-rvs-line.pl-code
          and full_pl-level.obj-code = tt-rvs-line.obj-code
          and full_pl-level.obj-type = tt-rvs-line.obj-type
          no-error .
    if not available full_pl-level
    then do :
      find first bf_goods no-lock where bf_goods.gds-code = tt-rvs-line.gds-code no-error .
      find first bf_place no-lock where bf_place.pl-code = tt-rvs-line.pl-code no-error .
      message
        substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Запуск ПОкМИ невозможен.'
                   ,(if available bf_place then bf_place.loc1 else "?")
                   ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                   ,(if available bf_goods then bf_goods.gds-name else "?") )
      view-as alert-box .
      undo _trpomi, return .
    end .
    DeltaOtn_K_Full = ? .
    for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = full_pl-level.pl-code
                                          and buf_pl-level-attr.obj-code = full_pl-level.obj-code
                                          and buf_pl-level-attr.obj-type = full_pl-level.obj-type
                                          and buf_pl-level-attr.pl-level = full_pl-level.pl-level
                                          and buf_pl-level-attr.attr-code = "tarir-delta"
                                          :
      DeltaOtn_K_Full = decimal(buf_pl-level-attr.attr-value) .
    end .
    if DeltaOtn_K_Full = ? then DeltaOtn_K_Full = 0.25 .
    DeltaVSugFull = ? .
    for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = full_pl-level.pl-code
                                          and buf_pl-level-attr.obj-code = full_pl-level.obj-code
                                          and buf_pl-level-attr.obj-type = full_pl-level.obj-type
                                          and buf_pl-level-attr.pl-level = full_pl-level.pl-level
                                          and buf_pl-level-attr.attr-code = "deltaV"
                                          :
      DeltaVSugFull = decimal(buf_pl-level-attr.attr-value) no-error .
    end .
    CalibTable = Substitute("&1=&2", sug1_pl-level.pl-level, (sug1_pl-level.pl-qnty / 1000)) + (if DeltaV1 > 0 then ("=" + trim(string(DeltaV1, ">>9.9999"))) else "") + chr(10) .
    CalibTable = CalibTable + Substitute("&1=&2", sug2_pl-level.pl-level, (sug2_pl-level.pl-qnty / 1000)) + (if DeltaV2 > 0 then ("=" + trim(string(DeltaV2, ">>9.9999"))) else "") + chr(10) .
    CalibTable = CalibTable + Substitute("&1=&2", full_pl-level.pl-level, (full_pl-level.pl-qnty / 1000)) + (if DeltaVSugFull > 0 then ("=" + trim(string(DeltaVSugFull, ">>9.9999"))) else "") .
    if (pl-rvd-lvl
    and pl-rvd-dens
    and pl-rvd-temp)
    or v-revision-mode
    then do : end .
    else do :
      if place-si = 0
      or place-si = ?
      then do :
        message
          substitute ("Для складского места &1 не заданно средство измерения",tt-rvs-line.pl-code)
        view-as alert-box error.
        undo _trpomi, return no-apply.
      end.
      else do :
        find first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = place-si no-error.
        if not available buf_sr-izmerenia then do :
          message
          "Ошибка работы с библиотекой ПОкМИ"
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
            DeltaAbs_R_liquid         = buf_sr-izmerenia.sr-abs-err-dens-lgas-liquid
            DeltaAbs_R_gas   = buf_sr-izmerenia.sr-abs-err-dens-lgas-vapor
            DeltaOtn_R             = buf_sr-izmerenia.sr-relative-err-dens
            Use_DeltaOtn_R_liquid_IN = buf_sr-izmerenia.sr-relative-err-dens-lgas-liquid <> ?
            DeltaOtn_R_liquid_IN     = buf_sr-izmerenia.sr-relative-err-dens-lgas-liquid
            DeltaOtn_N             = 0.05
            .
        end.
      end.
    end.
    if pl-rvd-lvl
    or v-revision-mode
    then do :
      if v-mi-lvl = 0
      or v-mi-lvl = ?
      then do :
        message
          substitute ("Для складского места &1 не заданно дополнительное средство измерения уровня",tt-rvs-line.pl-code)
        view-as alert-box error.
        undo _trpomi, return no-apply.
      end .
      else
      if v-mi-lvl <> place-si
      or not available buf_sr-izmerenia
      then do :
        find first level_sr-izmerenia no-lock where level_sr-izmerenia.node-code = v-mi-lvl no-error.
        if not available level_sr-izmerenia then do :
          message
          "Ошибка работы с библиотекой ПОкМИ"
          substitute( 'Не найдено средство измерения с кодом &1', v-mi-lvl ) skip
          view-as alert-box error.
          undo _trpomi, return no-apply.
        end.
        else do :
          assign
            A_LevelMeasurementTool = level_sr-izmerenia.sr-temp-line
            DeltaAbs_H             = level_sr-izmerenia.sr-abs-err-neft-water
            DeltaAbs_H_Water       = level_sr-izmerenia.sr-abs-err-water
            DeltaOtn_H             = level_sr-izmerenia.sr-relative-err-neft-water
            DeltaOtn_H_Water       = level_sr-izmerenia.sr-relative-err-water
          .
        end.
      end .
    end .
    if pl-rvd-dens
    or v-revision-mode
    then do :
      if v-mi-dnst = 0
      or v-mi-dnst = ?
      then do :
      end .
      else
      if v-mi-dnst <> place-si
      or not available buf_sr-izmerenia
      then do :
        find first dens_sr-izmerenia no-lock where dens_sr-izmerenia.node-code = v-mi-dnst no-error.
        if not available dens_sr-izmerenia then do :
          message
          "Ошибка работы с библиотекой ПОкМИ "
          substitute( 'Не найдено средство измерения с кодом &1', pl-dens-sr-izm ) skip
          view-as alert-box error.
          undo _trpomi, return no-apply.
        end.
        else do :
          assign
            DeltaAbs_R_liquid            = dens_sr-izmerenia.sr-abs-err-dens-lgas-liquid
            DeltaAbs_R_gas      = dens_sr-izmerenia.sr-abs-err-dens-lgas-vapor
            Use_DeltaOtn_R_liquid_IN  = dens_sr-izmerenia.sr-relative-err-dens-lgas-liquid <> ?
            DeltaOtn_R_liquid_IN      = dens_sr-izmerenia.sr-relative-err-dens-lgas-liquid
          .
        end.
      end .
    end .
    if DeltaAbs_H       = ? then DeltaAbs_H = 0 .
    if DeltaAbs_H_Water = ? then DeltaAbs_H_Water = 0 .
    if DeltaAbs_R_liquid   = ? then DeltaAbs_R_liquid = 0 .
    if DeltaAbs_R_gas   = ? then DeltaAbs_R_gas = 0 .
    if DeltaAbs_Tv      = ? then DeltaAbs_Tv = 0 .
    if DeltaAbs_Tr      = ? then DeltaAbs_Tr = 0 .
    if DeltaOtn_N       = ? then DeltaOtn_N = 0 .
    if DeltaOtn_H       = ? then DeltaOtn_H = 0 .
    if DeltaOtn_H_Water = ? then DeltaOtn_H_Water = 0 .
    if DeltaOtn_R       = ? then DeltaOtn_R = 0 .
    if LevelToolType    = ? then LevelToolType = 0 .
    if A_LevelMeasurementTool = ? then A_LevelMeasurementTool = 0 .
    if Use_DeltaOtn_R_liquid_IN = ? then Use_DeltaOtn_R_liquid_IN = false.
    if DeltaOtn_R_liquid_IN = ? then DeltaOtn_R_liquid_IN = 0.
    find first buf_place no-lock
         where buf_place.obj-code = tt-rvs-line.obj-code
           and buf_place.obj-type = tt-rvs-line.obj-type
           and buf_place.pl-code  = tt-rvs-line.pl-code no-error.
    v-proc = "CMethodOfMetering53" .
    MM53
      (input tt-rvs-line.state-level-total * 10,
       input CalibTable,
       input tt-rvs-line.state-temperature,
       input tt-rvs-line.state-density * 1000,
       input tt-rvs-line.state-dens-pf-sug * 1000,
       input A_Reservoir,
       input DeltaOtn_K,
       input DeltaOtn_K,
       input DeltaAbs_H,
       input DeltaAbs_R_liquid,
       input DeltaAbs_R_gas,
       input (if Use_DeltaOtn_R_liquid_IN then -1 else 0),
       input DeltaOtn_R_liquid_IN,
       input DeltaOtn_N,
       input 1,
       input 2,
       input 2,
       output C_HN,
       output C_HN_delta,
       output C_full,
       output V_liquid,
       output V_gas,
       output M_liquid,
       output M_gas,
       output M,
       output Kf,
       output DeltaOtn_H,
       output DeltaOtn_R_liquid,
       output DeltaOtn_R_gas,
       output DeltaOtn_M_liquid,
       output DeltaOtn_M_gas,
       output DeltaOtn_M,
       output H_min_liquid,
       output H_min,
       output A,
       output B,
       output vErr,
       output vWrn,
       output vDllVersion)
    no-error .
    assign varstate-water-qnty .
    OUTPUT stream outstream to value ("pomi.log") append.
            PUT STREAM outstream unformatted
            "    " SKIP
            "    " SKIP
            cur-time-string()           FORMAT "x(16)"    SKIP
            'Процедура             '                 v-proc                      FORMAT "x(128)"   SKIP
            'Версия dll: '              v-pokmi-dll-version                              SKIP
            'CODE_PL                = ' tt-rvs-line.pl-code                           SKIP
            'H                      = ' tt-rvs-line.state-level-total * 10                    SKIP
            'CalibrationTable       = ' CalibTable                    SKIP
            'T                      = ' tt-rvs-line.state-temperature               SKIP
            'R_liquid               = ' trim(string(tt-rvs-line.state-density * 1000, ">>>9.9<"))                         SKIP
            'R_gas                  = ' trim(string(tt-rvs-line.state-dens-pf-sug * 1000, ">>>9.9<"))        SKIP
            'A_Reservoir            = ' A_Reservoir                                   SKIP
            'DeltaOtn_K             = ' DeltaOtn_K                                    SKIP
            'DeltaOtn_K_Full        = ' DeltaOtn_K_Full                               SKIP
            'DeltaAbs_H             = ' DeltaAbs_H                                    SKIP
            'DeltaAbs_R_liquid      = ' DeltaAbs_R_liquid                             SKIP
            'DeltaAbs_R_gas         = ' DeltaAbs_R_gas                                SKIP
            'DeltaOtn_N             = ' DeltaOtn_N                                    SKIP
            'Use_DeltaOtn_R_liquid_IN = ' Use_DeltaOtn_R_liquid_IN                    SKIP
            'DeltaOtn_R_liquid_IN     = ' DeltaOtn_R_liquid_IN                        SKIP
            'Round_M                = ' 1                                   SKIP
            'Round_T                = ' 2                                   SKIP
            'Round_R                = ' 2                                   SKIP
    .
    output stream outstream close.
    if trim(vErr) > "" then do :
      error-string = substitute("~nРезервуар: &1.~n", buf_place.loc1) + replace(vErr,";0x","~n0x") .
      output stream outstream to value ("pomi.log")  append.
      put stream outstream error-string format "X(1024)" skip.
      message
      substitute('Ошибка работы библиотеки ПОкМИ. &1',error-string)
      view-as alert-box error.
      output stream outstream close.
      undo _trpomi, return no-apply .
    end.
    else do :
      if C_HN = 0 then
      do:
        error-string = "Ошибка входного параметра CalibrationTable. Библеотека ПОкМИ вернула C_HN = 0." .
        output stream outstream to value ("pomi.log")  append.
        put stream outstream error-string skip.
        message
          substitute('Ошибка входных параметров в библиотеку ПОкМИ.~n &1',error-string)
          view-as alert-box error
        .
        output stream outstream close.
        undo _trpomi, return no-apply .
      end.
      assign
        tt-rvs-line.state-measure-qnty      = V_liquid * 1000
        tt-rvs-line.state-measure-tc-qnty   = V_liquid * 1000
        tt-rvs-line.state-vol-pf-sug        = V_gas * 1000
        tt-rvs-line.state-measure-cli-qnty  = M
      .
      assign
        tt-rvs-line.fact-calc-add-mass = tt-rvs-line.state-add-qnty * tt-rvs-line.state-density
        tt-rvs-line.fact-sum-vol = tt-rvs-line.state-measure-qnty + tt-rvs-line.state-add-qnty
        tt-rvs-line.fact-sum-mass = tt-rvs-line.fact-calc-add-mass + tt-rvs-line.state-measure-cli-qnty
        varstate-sum-vol = input frame Dialog-Frame varstate-water-qnty + tt-rvs-line.state-measure-qnty
      .
      abs-delta-mass-add-qnty = tt-rvs-line.fact-calc-add-mass * pl-error-mass / 100 .
      tt-rvs-line.state-brutto-qnty = tt-rvs-line.fact-sum-vol .
      tt-rvs-line.state-brutto-cli-qnty  = tt-rvs-line.state-brutto-qnty * tt-rvs-line.state-density .
      if  tt-rvs-line.state-measure-cli-qnty > 200000 then delta-mass-qnty = 0.5 . else delta-mass-qnty = 0.65.
      abs-delta-mass-qnty = tt-rvs-line.state-measure-cli-qnty * delta-mass-qnty / 100 .
      display
      delta-mass-qnty
      tt-rvs-line.state-density
      tt-rvs-line.state-measure-cli-qnty
      tt-rvs-line.state-measure-qnty
      tt-rvs-line.fact-sum-vol
      tt-rvs-line.fact-sum-mass
      tt-rvs-line.fact-calc-add-mass
      tt-rvs-line.state-vol-pf-sug
      abs-delta-mass-add-qnty
      abs-delta-mass-qnty
      varstate-sum-vol
       with frame Dialog-Frame .
      output stream outstream to value ("pomi.log")  append.
      put stream outstream unformatted
        "C_HN              = " C_HN    skip
        "C_HN_delta        = " C_HN_delta          skip
        "C_full            = " C_full SKIP
        "V_liquid          = " V_liquid  SKIP
        "V_gas             = " V_gas   SKIP
        "M_liquid          = " M_liquid  SKIP
        "M_gas             = " M_gas  SKIP
        "M                 = " M   SKIP
        "Kf                = " Kf  SKIP
        "DeltaOtn_H        = " DeltaOtn_H SKIP
        "DeltaOtn_R_liquid = " DeltaOtn_R_liquid  SKIP
        "DeltaOtn_R_gas    = " DeltaOtn_R_gas  SKIP
        "DeltaOtn_M_liquid = " DeltaOtn_M_liquid SKIP
        "DeltaOtn_M_gas    = " DeltaOtn_M_gas  SKIP
        "DeltaOtn_M        = " DeltaOtn_M  SKIP
        "H_min_liquid      = " H_min_liquid  SKIP
        "H_min             = " H_min  SKIP
        "A                 = " A  SKIP
        "B                 = " B  SKIP SKIP
        "Warnings          = " vWrn   SKIP
      .
      output stream outstream close.
      assign
        v-POkMI-result-attr =
          "Общая масса СУГ, кг: " + string(M, "->>,>>>,>>9.9":U) + chr(10) +
          "Относительная погрешность измерения массы СУГ, %: "  + string(DeltaOtn_M, ">>>>>>>9.99") + chr(10) +
          "Объем ЖФ СУГ, л: " + string((V_liquid * 1000), "->>,>>>,>>9":U) + chr(10) +
          "Объем ПФ СУГ, л: " + string((V_gas * 1000), "->>,>>>,>>9":U) + chr(10)
        v-POkMI-warnings = vWrn
      .
      find first rvs-line-attr exclusive-lock
            where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
              and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
              and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
              and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
              and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
              and rvs-line-attr.attr-code = "POkMI-result" no-error.
      if available rvs-line-attr then do :
        rvs-line-attr.attr-value = v-POkMI-result-attr .
      end.
      else do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "POkMI-result"
          rvs-line-attr.attr-value = v-POkMI-result-attr
        .
      end.
      find first rvs-line-attr exclusive-lock
            where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
              and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
              and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
              and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
              and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
              and rvs-line-attr.attr-code = "POkMI-warnings" no-error.
      if available rvs-line-attr then do :
        rvs-line-attr.attr-value = v-POkMI-warnings .
      end.
      else do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "POkMI-warnings"
          rvs-line-attr.attr-value = v-POkMI-warnings
        .
      end.
      enable
        b-POkMI-result
      with frame Dialog-Frame.
      run volume-water no-error.
      if error-status :error then do :
        undo _trpomi, return .
      end.
      run chg-density no-error.
      if error-status :error then do :
        undo _trpomi, return .
      end.
      run weath-water no-error.
      if error-status :error then do :
        undo _trpomi, return .
      end.
    end.
  end.
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "is-calc" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "is-calc"
    .
  end.
  rvs-line-attr.attr-value = "yes" .
  release rvs-line-attr no-error .
END.
ON CHOOSE OF b-rez IN FRAME Dialog-Frame
DO:
  if twice-place-data > ""
  then do :
    message twice-place-data view-as alert-box information .
  end.
  else do :
    message "Нет данных" view-as alert-box .
  end.
END.
ON CHOOSE OF b-sug-struct IN FRAME Dialog-Frame
DO:
  define variable v-out-dens    as decimal no-undo .
  define variable v-out-dens-pf as decimal no-undo .
  define variable vOk           as logical no-undo .
  if tt-rvs-line.state-temperature = ?
  then do :
    message "Введите температуру!" view-as alert-box .
    return no-apply .
  end .
  if tt-rvs-line.state-pressure-sug = ?
  then do :
    message "Введите давление!" view-as alert-box .
    return no-apply .
  end .
  run str/rvs-lin-sug-struct.w (input tt-rvs-line.obj-type,
                                input tt-rvs-line.obj-code,
                                input tt-rvs-line.pl-code,
                                input tt-rvs-line.gds-code,
                                input tt-rvs-line.rvs-code,
                                input tt-rvs-line.state-temperature,
                                input tt-rvs-line.state-pressure-sug,
                                output v-out-dens,
                                output v-out-dens-pf,
                                output vOk)
                                .
  if vOk
  then do :
    assign
      tt-rvs-line.state-density     = v-out-dens
      tt-rvs-line.state-dens-pf-sug = v-out-dens-pf
    .
    assign v-hand-input-dnst = true .
    find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "is-calc" no-error.
    if available rvs-line-attr
    then do :
      rvs-line-attr.attr-value = string(no) .
    end .
    display tt-rvs-line.state-density tt-rvs-line.state-dens-pf-sug with frame Dialog-Frame .
  end .
END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
  define variable v-water     as decimal   no-undo .
  define variable v-water-cli as decimal   no-undo .
  define variable v-free-vol  as decimal   no-undo .
  define variable v-vid-action        as integer no-undo .
  define variable v-vid-param         as longchar no-undo .
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable v-shift-date like ub.shift-obj.shift-date no-undo .
  define variable v-shift-num  like ub.shift-obj.shift-num no-undo .
  define variable v-shift-name like ub.shift-obj.shift-name no-undo.
  define variable v-rvd-reason   as character no-undo .
  define variable v-ITSM-num     as character no-undo .
  define variable v-oper-fio     as character no-undo .
  define buffer olddens-rvs-line-attr for ub.rvs-line-attr .
  define variable v-is-olddens as logical no-undo initial no .
  define buffer buf_doc-pl for ub.doc-pl .
  define buffer buf_place for ub.place .
  define buffer buf_doc-pl-attr for doc-pl-attr .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  buf_rvs-doc.obj-type
  ,input  buf_rvs-doc.obj-code
  ,output v-shift-date
  ,output v-shift-num
  ,output v-shift-name
  ) no-error .
  if tt-rvs-line.state-measure-qnty > tt-rvs-line.state-brutto-qnty
  then do:
     message "Объем топлива больше общего объема."
     view-as alert-box error.
     apply "entry" to tt-rvs-line.state-measure-qnty in frame Dialog-Frame.
     return no-apply.
  end.
  if rdc-value = "pomi-rn"
  and b-calc:sensitive
  then do :
    find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
           and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
           and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
           and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
           and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
           and rvs-line-attr.attr-code = "is-calc" no-error.
    if not available rvs-line-attr
    or (available rvs-line-attr and rvs-line-attr.attr-value <> "yes")
    then do :
      message "Сохранение введенных параметров СУГ невозможно." skip (1)
              "Не выполнено приведение параметров СУГ к стандартной температуре." skip
              'Нажмите кнопку "Рассчитать" и повторите попытку.'
      view-as alert-box information.
      apply "entry" to b-calc in frame Dialog-Frame.
      return no-apply.
    end.
  end.
  find first buf_rvs-line
    where recid(buf_rvs-line) =  parrec-rvs-line
    no-error.
  find first buf_rvs-doc no-lock
    where buf_rvs-doc.rvs-code = tt-rvs-line.rvs-code
    .
  run level-water in this-procedure
    ( input yes
    ) no-error.
  if error-status :error then do:
    apply "ENTRY":U to tt-rvs-line.state-level-total in frame Dialog-Frame.
    return no-apply.
  end.
  run chg-density  in this-procedure               no-error.
  if error-status :error then do: return no-apply. end.
  run weath-water  in this-procedure               no-error.
  if error-status :error then do: return no-apply. end.
  assign frame Dialog-Frame tt-rvs-line.state-measure-tc-qnty tt-rvs-line.state-add-qnty tt-rvs-line.state-temperature.
  assign
    tt-rvs-line.state-brutto-qnty = tt-rvs-line.state-measure-qnty + varstate-water-qnty
    tt-rvs-line.state-brutto-cli-qnty = tt-rvs-line.state-measure-cli-qnty + varstate-water-qnty
    tt-rvs-line.state-level-petrol = tt-rvs-line.state-level-total - tt-rvs-line.state-level-water
  .
  if not rdc-value = "pomi-rn"
  then do :
    if tt-rvs-line.state-temperature = ?
    then do :
      message "Не заполнено обязательное поле «Температура средняя»" view-as alert-box .
      return no-apply .
    end .
  end .
  buffer-copy tt-rvs-line to buf_rvs-line.
  if v-revision-mode
  and rdc-value = "pomi-rn"
  then do :
    find first buf_place no-lock
         where buf_place.obj-code = tt-rvs-line.obj-code
           and buf_place.obj-type = tt-rvs-line.obj-type
           and buf_place.pl-code  = tt-rvs-line.pl-code no-error.
    find first buf_rvs-doc-attr exclusive-lock where buf_rvs-doc-attr.rvs-code = buf_rvs-doc.rvs-code
                                                 and buf_rvs-doc-attr.attr-code = "rvd-reason"
                                                 no-error .
    if available buf_rvs-doc-attr
    then do :
      v-rvd-reason = entry(1, buf_rvs-doc-attr.attr-value, chr(4)) .
      v-ITSM-num = entry(2, buf_rvs-doc-attr.attr-value, chr(4)) .
      v-oper-fio = entry(3, buf_rvs-doc-attr.attr-value, chr(4)) .
    end .
    else do :
      run ref/rvd-reasons.w (input parparentproc,
                             input -1,
                             output v-rvd-reason,
                             output v-ITSM-num,
                             output v-oper-fio)
                             .
      if v-rvd-reason = ?
      then do :
        return no-apply .
      end .
      create buf_rvs-doc-attr .
      assign
        buf_rvs-doc-attr.rvs-code = buf_rvs-doc.rvs-code
        buf_rvs-doc-attr.attr-code = "rvd-reason"
        buf_rvs-doc-attr.attr-value = v-rvd-reason + chr(4) +
                                    v-ITSM-num + chr(4) +
                                    v-oper-fio + chr(4)
      .
    end .
    find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
           and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
           and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
           and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
           and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
           and rvs-line-attr.attr-code = "rvd-reason" no-error.
    if not available rvs-line-attr then do :
      create rvs-line-attr.
      assign
        rvs-line-attr.obj-code  = tt-rvs-line.obj-code
        rvs-line-attr.obj-type  = tt-rvs-line.obj-type
        rvs-line-attr.gds-code  = tt-rvs-line.gds-code
        rvs-line-attr.pl-code   = tt-rvs-line.pl-code
        rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
        rvs-line-attr.attr-code = "rvd-reason"
      .
    end.
    if v-mi-dnst = ? then v-mi-dnst = 0 .
    if v-mi-lvl = ? then v-mi-lvl = 0 .
    if v-mi-tmp = ? then v-mi-tmp = 0 .
    if place-SI = ? then place-SI = 0 .
    if pl-dens-sr-izm = ? then pl-dens-sr-izm = 0 .
    if pl-level-sr-izm = ? then pl-level-sr-izm = 0 .
    if pl-temp-sr-izm = ? then pl-temp-sr-izm = 0 .
    rvs-line-attr.attr-value = ("Установка РВД на объекте " +
                                  buf_rvs-doc.obj-type + string(buf_rvs-doc.obj-code) +
                                  " сверка " + buf_rvs-doc.rvs-code + " " +
                                  " рез. " + string(tt-rvs-line.pl-code) + ": " +
                                  "p,T,l" + ";" +
                                  "yes" + ";" +
                                  v-rvd-reason + ";" +
                                  v-ITSM-num + ";" +
                                  v-oper-fio +
                                  chr(3) +
                                  buf_rvs-doc.obj-type + chr(6) +
                                  string(buf_rvs-doc.obj-code) + chr(6) +
                                  string(v-shift-date) + chr(6) +
                                  string(v-shift-num) + chr(6) +
                                  string(tt-rvs-line.pl-code) + chr(6) +
                                  "p,T,l" + chr(6) +
                                  "yes" + chr(6) +
                                  v-rvd-reason + chr(6) +
                                  v-ITSM-num + chr(6) +
                                  v-oper-fio + chr(6) +
                                  string(yes) + chr(6) +
                                  string(yes) + chr(6) +
                                  string(yes) + chr(6) +
                                  string(buf_place.is-meas) + chr(6) +
                                  buf_rvs-doc.rvs-code + chr(6) +
                                  string(place-SI) + chr(6) +
                                  string(place-SI) + chr(6) +
                                  string(pl-dens-sr-izm) + chr(6) +
                                  string(v-mi-dnst) + chr(6) +
                                  string(pl-level-sr-izm) + chr(6) +
                                  string(v-mi-lvl) + chr(6) +
                                  string(pl-temp-sr-izm) + chr(6) +
                                  string(v-mi-tmp) )
                                  .
  end .
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
  if rdc-value = "pomi-rn"
  then do :
    find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
           and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
           and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
           and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
           and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
           and rvs-line-attr.attr-code = "mi-lvl" no-error.
    if not available rvs-line-attr then do :
      create rvs-line-attr.
      assign
        rvs-line-attr.obj-code  = tt-rvs-line.obj-code
        rvs-line-attr.obj-type  = tt-rvs-line.obj-type
        rvs-line-attr.gds-code  = tt-rvs-line.gds-code
        rvs-line-attr.pl-code   = tt-rvs-line.pl-code
        rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
        rvs-line-attr.attr-code = "mi-lvl"
        rvs-line-attr.attr-value = string(v-mi-lvl)
      .
    end.
    else do :
      rvs-line-attr.attr-value = string(v-mi-lvl) .
    end.
    find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
           and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
           and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
           and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
           and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
           and rvs-line-attr.attr-code = "mi-dnst" no-error.
    if not available rvs-line-attr then do :
      create rvs-line-attr.
      assign
        rvs-line-attr.obj-code  = tt-rvs-line.obj-code
        rvs-line-attr.obj-type  = tt-rvs-line.obj-type
        rvs-line-attr.gds-code  = tt-rvs-line.gds-code
        rvs-line-attr.pl-code   = tt-rvs-line.pl-code
        rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
        rvs-line-attr.attr-code = "mi-dnst"
        rvs-line-attr.attr-value = string(v-mi-dnst)
      .
    end.
    else do :
      rvs-line-attr.attr-value = string(v-mi-dnst) .
    end.
    find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
           and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
           and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
           and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
           and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
           and rvs-line-attr.attr-code = "mi-tmp" no-error.
    if not available rvs-line-attr then do :
      create rvs-line-attr.
      assign
        rvs-line-attr.obj-code  = tt-rvs-line.obj-code
        rvs-line-attr.obj-type  = tt-rvs-line.obj-type
        rvs-line-attr.gds-code  = tt-rvs-line.gds-code
        rvs-line-attr.pl-code   = tt-rvs-line.pl-code
        rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
        rvs-line-attr.attr-code = "mi-tmp"
        rvs-line-attr.attr-value = string(v-mi-tmp)
      .
    end.
    else do :
      rvs-line-attr.attr-value = string(v-mi-tmp) .
    end.
  end .
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "input-type-p" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "input-type-p"
    .
  end.
  if buf_rvs-line.density = ? or buf_rvs-line.density = 0
  then do :
    rvs-line-attr.attr-value = "р" .
  end.
  else do :
    if v-hand-input-dnst
    then do :
      if rvs-line-attr.attr-value = "а" then rvs-line-attr.attr-value = "ак" .
      if rvs-line-attr.attr-value = "ф" then rvs-line-attr.attr-value = "фк" .
    end.
    else do :
      find first olddens-rvs-line-attr no-lock
           where olddens-rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and olddens-rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and olddens-rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and olddens-rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and olddens-rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and olddens-rvs-line-attr.attr-code = "is-olddens" no-error.
      if available olddens-rvs-line-attr
      then do :
        v-is-olddens = logical(olddens-rvs-line-attr.attr-value) no-error.
        if error-status:error then v-is-olddens = no .
      end.
      else do :
        v-is-olddens = no .
      end.
      if v-is-olddens and
      (rvs-line-attr.attr-value = "а" or rvs-line-attr.attr-value = "ф")
      then rvs-line-attr.attr-value = "п" .
    end.
  end.
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "input-type-t" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "input-type-t"
    .
  end.
  if buf_rvs-line.temperature = ?
  then do :
    rvs-line-attr.attr-value = "р" .
  end.
  else do :
    if v-hand-input-tmp
    then do :
      if rvs-line-attr.attr-value = "а" then rvs-line-attr.attr-value = "ак" .
      if rvs-line-attr.attr-value = "ф" then rvs-line-attr.attr-value = "фк" .
    end.
    else do :
      find first olddens-rvs-line-attr no-lock
           where olddens-rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and olddens-rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and olddens-rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and olddens-rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and olddens-rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and olddens-rvs-line-attr.attr-code = "is-olddens" no-error.
      if available olddens-rvs-line-attr
      then do :
        v-is-olddens = logical(olddens-rvs-line-attr.attr-value) no-error.
        if error-status:error then v-is-olddens = no .
      end.
      else do :
        v-is-olddens = no .
      end.
      if v-is-olddens and
      (rvs-line-attr.attr-value = "а" or rvs-line-attr.attr-value = "ф")
      then rvs-line-attr.attr-value = "п" .
    end.
  end.
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "input-type-l" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "input-type-l"
    .
  end.
  if buf_rvs-line.temperature = ?
  then do :
    rvs-line-attr.attr-value = "р" .
  end.
  else do :
    if v-hand-input-lvl
    then do :
      if rvs-line-attr.attr-value = "а" then rvs-line-attr.attr-value = "ак" .
      if rvs-line-attr.attr-value = "ф" then rvs-line-attr.attr-value = "фк" .
    end.
  end.
  find first rvs-line-attr exclusive-lock
      where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      and rvs-line-attr.attr-code = "delta-mass-qnty" no-error.
  if available rvs-line-attr then
  do :
      rvs-line-attr.attr-value = string(delta-mass-qnty)  .
  end.
  else
  do :
      create rvs-line-attr.
      assign
        rvs-line-attr.obj-code   = tt-rvs-line.obj-code
        rvs-line-attr.obj-type   = tt-rvs-line.obj-type
        rvs-line-attr.gds-code   = tt-rvs-line.gds-code
        rvs-line-attr.pl-code    = tt-rvs-line.pl-code
        rvs-line-attr.rvs-code   = tt-rvs-line.rvs-code
        rvs-line-attr.attr-code  = "delta-mass-qnty"
        rvs-line-attr.attr-value = string( delta-mass-qnty)
      .
  end.
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "vol-pf-sug" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "vol-pf-sug"
      rvs-line-attr.attr-value = string(tt-rvs-line.vol-pf-sug)
    .
  end.
  else do :
    rvs-line-attr.attr-value = string(tt-rvs-line.vol-pf-sug) .
  end.
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "state-vol-pf-sug" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "state-vol-pf-sug"
      rvs-line-attr.attr-value = string(tt-rvs-line.state-vol-pf-sug)
    .
  end.
  else do :
    rvs-line-attr.attr-value = string(tt-rvs-line.state-vol-pf-sug) .
  end.
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "dens-pf-sug" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "dens-pf-sug"
      rvs-line-attr.attr-value = string(tt-rvs-line.dens-pf-sug)
    .
  end.
  else do :
    rvs-line-attr.attr-value = string(tt-rvs-line.dens-pf-sug) .
  end.
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "state-dens-pf-sug" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "state-dens-pf-sug"
      rvs-line-attr.attr-value = string(tt-rvs-line.state-dens-pf-sug)
    .
  end.
  else do :
    rvs-line-attr.attr-value = string(tt-rvs-line.state-dens-pf-sug) .
  end.
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "pressure-sug" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "pressure-sug"
      rvs-line-attr.attr-value = string(tt-rvs-line.pressure-sug)
    .
  end.
  else do :
    rvs-line-attr.attr-value = string(tt-rvs-line.pressure-sug) .
  end.
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "state-pressure-sug" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "state-pressure-sug"
      rvs-line-attr.attr-value = string(tt-rvs-line.state-pressure-sug)
    .
  end.
  else do :
    rvs-line-attr.attr-value = string(tt-rvs-line.state-pressure-sug) .
  end.
  if delta-mass-qnty = ? or delta-mass-qnty > 0.65 or delta-mass-qnty <= 0 then delta-mass-qnty = 0.65 .
  find first rvs-line-attr exclusive-lock
      where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      and rvs-line-attr.attr-code = "delta-mass-qnty" no-error.
  if available rvs-line-attr then
  do :
      rvs-line-attr.attr-value = string(delta-mass-qnty)  .
  end.
  else
  do :
      create rvs-line-attr.
      assign
          rvs-line-attr.obj-code   = tt-rvs-line.obj-code
          rvs-line-attr.obj-type   = tt-rvs-line.obj-type
          rvs-line-attr.gds-code   = tt-rvs-line.gds-code
          rvs-line-attr.pl-code    = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code   = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code  = "delta-mass-qnty"
          rvs-line-attr.attr-value = string(delta-mass-qnty)
          .
  end.
  abs-delta-mass-qnty = tt-rvs-line.state-measure-cli-qnty * delta-mass-qnty / 100 .
  find first rvs-line-attr exclusive-lock
      where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      and rvs-line-attr.attr-code = "abs-delta-mass-qnty" no-error.
  if available rvs-line-attr then
  do :
      rvs-line-attr.attr-value = string(abs-delta-mass-qnty)  .
  end.
  else
  do :
      create rvs-line-attr.
      assign
          rvs-line-attr.obj-code   = tt-rvs-line.obj-code
          rvs-line-attr.obj-type   = tt-rvs-line.obj-type
          rvs-line-attr.gds-code   = tt-rvs-line.gds-code
          rvs-line-attr.pl-code    = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code   = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code  = "abs-delta-mass-qnty"
          rvs-line-attr.attr-value = string(abs-delta-mass-qnty)
          .
  end.
  find first rvs-line-attr exclusive-lock
      where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      and rvs-line-attr.attr-code = "hand-save" no-error.
  if available rvs-line-attr then
  do :
      rvs-line-attr.attr-value = string(yes)  .
  end.
  else
  do :
      create rvs-line-attr.
      assign
          rvs-line-attr.obj-code   = tt-rvs-line.obj-code
          rvs-line-attr.obj-type   = tt-rvs-line.obj-type
          rvs-line-attr.gds-code   = tt-rvs-line.gds-code
          rvs-line-attr.pl-code    = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code   = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code  = "hand-save"
          rvs-line-attr.attr-value = string(yes)
          .
  end.
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "first-enter" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "first-enter"
      rvs-line-attr.attr-value = string(no) .
    .
  end.
  else do :
    rvs-line-attr.attr-value = string(no) .
  end.
  release rvs-line-attr no-error .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input tt-rvs-line.obj-type
  , input tt-rvs-line.obj-code
  ) .
  if buf_rvs-doc.rvs-type = 'перед_док':U
  then do :
    if ptrlprop-calc-free-vol-sug
    then do:
      find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_rvs-doc.out-code no-error .
      if available buf_trn-doc
      and buf_trn-doc.reason-code = 99
      then do :
        is-main-tank = no .
        run placelib_get-attr  ( input "place-com-tanks"
                                ,input tt-rvs-line.obj-code
                                ,input tt-rvs-line.obj-type
                                ,input tt-rvs-line.pl-code
                                ,output v-value
                                ,output v-ok      ) no-error.
        if v-ok
        and v-value > ""
        then do :
          run placelib_get-attr  ( input "place-is-main"
                                  ,input tt-rvs-line.obj-code
                                  ,input tt-rvs-line.obj-type
                                  ,input tt-rvs-line.pl-code
                                  ,output v-value
                                  ,output v-ok      ) no-error.
          if v-ok
          and v-value > ""
          and logical(v-value)
          then do :
            is-main-tank = yes .
          end .
        end .
        else do :
          is-main-tank = yes .
        end .
        if is-main-tank
        then do :
          find first buf_doc-pl no-lock where buf_doc-pl.obj-type   = tt-rvs-line.obj-type
            and buf_doc-pl.obj-code   = tt-rvs-line.obj-code
            and buf_doc-pl.gds-code   = tt-rvs-line.gds-code
            and buf_doc-pl.pl-code    = tt-rvs-line.pl-code
            and buf_doc-pl.out-code   = buf_rvs-doc.out-code
            no-error .
          if not available buf_doc-pl
          then do :
            message "В накладной для товара " string(tt-rvs-line.gds-code) " нет распределения по местам хранения!" view-as alert-box .
            return no-apply .
          end .
          find first buf_place no-lock where buf_place.obj-code = tt-rvs-line.obj-code
            and buf_place.obj-type = tt-rvs-line.obj-type
            and buf_place.pl-code  = tt-rvs-line.pl-code
            no-error.
          assign
            v-free-vol = 0.85 * buf_place.max-qnty - tt-rvs-line.state-measure-qnty
          .
          if v-free-vol >= buf_doc-pl.fact-qnty
          then do :
            find first buf_doc-pl-attr exclusive-lock
              where buf_doc-pl-attr.obj-code  = buf_doc-pl.obj-code
              and buf_doc-pl-attr.obj-type  = buf_doc-pl.obj-type
              and buf_doc-pl-attr.gds-code  = buf_doc-pl.gds-code
              and buf_doc-pl-attr.pl-code   = buf_doc-pl.pl-code
              and buf_doc-pl-attr.out-code  = buf_doc-pl.out-code
              and buf_doc-pl-attr.attr-code = "free-vol-exceed" no-error.
            if available buf_doc-pl-attr
            then do :
              buf_doc-pl-attr.attr-value = string(no)  .
            end.
            else do :
              create buf_doc-pl-attr.
              assign
                buf_doc-pl-attr.obj-code   = buf_doc-pl.obj-code
                buf_doc-pl-attr.obj-type   = buf_doc-pl.obj-type
                buf_doc-pl-attr.gds-code   = buf_doc-pl.gds-code
                buf_doc-pl-attr.pl-code    = buf_doc-pl.pl-code
                buf_doc-pl-attr.out-code   = buf_doc-pl.out-code
                buf_doc-pl-attr.attr-code  = "free-vol-exceed"
                buf_doc-pl-attr.attr-value = string(no)
                .
            end.
          end .
          else do :
            run ref/message_volue.w(input string(round(buf_doc-pl.fact-qnty, 0)) ,
              input buf_place.loc1,
              input string(round(v-free-vol, 0)),
              input false) no-error .
            find first buf_doc-pl-attr exclusive-lock
              where buf_doc-pl-attr.obj-code  = buf_doc-pl.obj-code
              and buf_doc-pl-attr.obj-type  = buf_doc-pl.obj-type
              and buf_doc-pl-attr.gds-code  = buf_doc-pl.gds-code
              and buf_doc-pl-attr.pl-code   = buf_doc-pl.pl-code
              and buf_doc-pl-attr.out-code  = buf_doc-pl.out-code
              and buf_doc-pl-attr.attr-code = "free-vol-exceed" no-error.
            if available buf_doc-pl-attr then
            do :
              buf_doc-pl-attr.attr-value = string(yes)  .
            end.
            else
            do :
              create buf_doc-pl-attr.
              assign
                buf_doc-pl-attr.obj-code   = buf_doc-pl.obj-code
                buf_doc-pl-attr.obj-type   = buf_doc-pl.obj-type
                buf_doc-pl-attr.gds-code   = buf_doc-pl.gds-code
                buf_doc-pl-attr.pl-code    = buf_doc-pl.pl-code
                buf_doc-pl-attr.out-code   = buf_doc-pl.out-code
                buf_doc-pl-attr.attr-code  = "free-vol-exceed"
                buf_doc-pl-attr.attr-value = string(yes)
                .
            end.
          end .
        end .
      end .
    end .
  end.
  if buf_rvs-doc.rvs-type = 'после_док':U then
  do:
    find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_rvs-doc.out-code no-error .
    find first buf_place no-lock where buf_place.obj-code = tt-rvs-line.obj-code
      and buf_place.obj-type = tt-rvs-line.obj-type
      and buf_place.pl-code  = tt-rvs-line.pl-code
    no-error.
    assign v-free-vol = 0.85 * buf_place.max-qnty .
    if tt-rvs-line.fact-sum-vol > 0
    then do :
      if v-free-vol >= tt-rvs-line.fact-sum-vol
      then do :
        find first buf_doc-pl-attr exclusive-lock
          where buf_doc-pl-attr.obj-code  = tt-rvs-line.obj-code
          and buf_doc-pl-attr.obj-type  = tt-rvs-line.obj-type
          and buf_doc-pl-attr.gds-code  = tt-rvs-line.gds-code
          and buf_doc-pl-attr.pl-code   = tt-rvs-line.pl-code
          and buf_doc-pl-attr.out-code  = buf_rvs-doc.out-code
          and buf_doc-pl-attr.attr-code = "free-vol-exceed-after" no-error.
        if available buf_doc-pl-attr
        then do :
          assign buf_doc-pl-attr.attr-value = string(no)  .
        end.
        else do :
          create buf_doc-pl-attr.
          assign
            buf_doc-pl-attr.obj-code   = tt-rvs-line.obj-code
            buf_doc-pl-attr.obj-type   = tt-rvs-line.obj-type
            buf_doc-pl-attr.gds-code   = tt-rvs-line.gds-code
            buf_doc-pl-attr.pl-code    = tt-rvs-line.pl-code
            buf_doc-pl-attr.out-code   = buf_rvs-doc.out-code
            buf_doc-pl-attr.attr-code  = "free-vol-exceed-after"
            buf_doc-pl-attr.attr-value = string(no)
          .
        end.
      end .
      else do :
        find first buf_doc-pl-attr exclusive-lock
          where buf_doc-pl-attr.obj-code  = tt-rvs-line.obj-code
          and buf_doc-pl-attr.obj-type  = tt-rvs-line.obj-type
          and buf_doc-pl-attr.gds-code  = tt-rvs-line.gds-code
          and buf_doc-pl-attr.pl-code   = tt-rvs-line.pl-code
          and buf_doc-pl-attr.out-code  = buf_rvs-doc.out-code
          and buf_doc-pl-attr.attr-code = "free-vol-exceed-after" no-error.
        if available (buf_doc-pl-attr)
        then do :
          assign buf_doc-pl-attr.attr-value = string(yes) .
        end .
        else do :
          create buf_doc-pl-attr.
          assign
            buf_doc-pl-attr.obj-code   = tt-rvs-line.obj-code
            buf_doc-pl-attr.obj-type   = tt-rvs-line.obj-type
            buf_doc-pl-attr.gds-code   = tt-rvs-line.gds-code
            buf_doc-pl-attr.pl-code    = tt-rvs-line.pl-code
            buf_doc-pl-attr.out-code   = buf_rvs-doc.out-code
            buf_doc-pl-attr.attr-code  = "free-vol-exceed-after"
            buf_doc-pl-attr.attr-value = string(yes)
          .
        end.
      end.
    end.
  end.
  define variable v-mi-par-list      as character no-undo .
  define variable v-mi-par-list-text as character no-undo .
  define variable v-mi-old-val-list  as character no-undo .
  define variable v-mi-new-val-list  as character no-undo .
  v-mi-par-list = "" .
  v-mi-old-val-list = "" .
  v-mi-new-val-list = "" .
  if rdc-value = "pomi-rn"
  then do :
    if v-dnst-mi-old = v-mi-dnst
    and v-lvl-mi-old = v-mi-lvl
    and v-tmp-mi-old = v-mi-tmp
    then do :
    end .
    else do :
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
        v-mi-par-list-text = v-mi-par-list
      .
      v-mi-par-list-text = replace(v-mi-par-list-text, "p", " плотность") .
      v-mi-par-list-text = replace(v-mi-par-list-text, "l", " уровень") .
      v-mi-par-list-text = replace(v-mi-par-list-text, "t", " температура") .
      run trg/userlog.p (
              input 'mi-change'
            , input ("Изменение средств измерений на объекте " +
                    buf_rvs-doc.obj-type + string(buf_rvs-doc.obj-code) +
                    "в сверке " + string(buf_rvs-doc.rvs-code) +
                    " рез. " + string(tt-rvs-line.pl-code) + ": " +
                    v-mi-par-list + ";" +
                    v-mi-old-val-list + ";" +
                    v-mi-new-val-list +
                    chr(3) +
                    buf_rvs-doc.obj-type + chr(6) +
                    string(buf_rvs-doc.obj-code) + chr(6) +
                    string(v-shift-date) + chr(6) +
                    string(v-shift-num) + chr(6) +
                    string(tt-rvs-line.pl-code) + chr(6) +
                    v-mi-par-list + chr(6) +
                    v-mi-old-val-list + chr(6) +
                    v-mi-new-val-list + chr(6) +
                    string(buf_rvs-doc.rvs-code)   )
            , input ?
            , input ?
            , input ""
            ) no-error.
      if error-status :error
      then do:
          message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
      end.
      define variable v-log as logical no-undo .
      find first buf_place no-lock
           where buf_place.obj-code = tt-rvs-line.obj-code
             and buf_place.obj-type = tt-rvs-line.obj-type
             and buf_place.pl-code  = tt-rvs-line.pl-code no-error.
      message
        "Для параметра/ов" v-mi-par-list-text " изменены дополнительные средства измерения. Сохранить выбранные средства измерения"
        v-mi-par-list-text " в качестве средств измерения по умолчанию для резервуара " buf_place.loc1 " " buf_place.pl-name "?"
      view-as alert-box question buttons yes-no update v-log .
      if v-log
      then do :
        if v-dnst-mi-old <> v-mi-dnst
        then do :
          run placelib_write-attr  ( input "place-SI-dens"
                                    ,input buf_place.obj-code
                                    ,input buf_place.obj-type
                                    ,input buf_place.pl-code
                                    ,input string(v-mi-dnst)
                                    ,output v-ok      ) no-error.
        end .
        if v-lvl-mi-old <> v-mi-lvl
        then do :
          run placelib_write-attr  ( input "place-SI-level"
                                    ,input buf_place.obj-code
                                    ,input buf_place.obj-type
                                    ,input buf_place.pl-code
                                    ,input string(v-mi-lvl)
                                    ,output v-ok      ) no-error.
        end .
        if v-tmp-mi-old <> v-mi-tmp
        then do :
          run placelib_write-attr  ( input "place-SI-temp"
                                    ,input buf_place.obj-code
                                    ,input buf_place.obj-type
                                    ,input buf_place.pl-code
                                    ,input string(v-mi-tmp)
                                    ,output v-ok      ) no-error.
        end .
      end .
    end .
  end .
  v-vid-action = 56 .
  v-vid-param =
          "Initiator=" + v-initiator + chr(4) +
          "SHOP_NUM=" + string(buf_rvs-doc.obj-code) + chr(4) +
          "DocType=" + string(buf_rvs-doc.rvs-type) + chr(4) +
          "DocNum=" + string(buf_rvs-doc.rvs-code) + chr(4) +
          "SHIFT_NUM_DOC=" + (if string(buf_rvs-doc.shift-num) = ? then '' else string(buf_rvs-doc.shift-num)) + (if string(buf_rvs-doc.shift-date) = ? then '' else string(buf_rvs-doc.shift-date, "99999999")) + chr(4) +
          "SHIFT_NUM=" + (if string(v-shift-num) = ? then '' else string(v-shift-num)) + (if string(v-shift-date) = ? then '' else string(v-shift-date, "99999999")) + chr(4) +
          "PlCode=" + string( tt-rvs-line.pl-code) + chr(4) +
          "RESULT=0" + chr(4) +
          "Temperature=" +  (if string(tt-rvs-line.state-temperature) = ? then '' else string(tt-rvs-line.state-temperature)) + chr(4) +
          "StateDensity="        +  (if string(tt-rvs-line.state-density) = ? then '' else string(tt-rvs-line.state-density)) + chr(4) +
          "StateMeasureQnty="    +  (if string( tt-rvs-line.state-measure-qnty) = ? then '' else string( tt-rvs-line.state-measure-qnty)) + chr(4) +
          "StateBruttoQnty="  +  (if string(  tt-rvs-line.state-brutto-qnty) = ? then '' else string(  tt-rvs-line.state-brutto-qnty)) + chr(4) +
          "StateMeasureCliQnty=" +  (if string(  tt-rvs-line.state-measure-cli-qnty) = ? then '' else string(  tt-rvs-line.state-measure-cli-qnty)) + chr(4) +
          "StateBruttoCliQnty=" +  (if string(  tt-rvs-line.state-brutto-cli-qnty) = ? then '' else string(   tt-rvs-line.state-brutto-cli-qnty)) + chr(4) +
          "StateLevelTotal="  +  (if string(  tt-rvs-line.state-level-total) = ? then '' else string(  tt-rvs-line.state-level-total)) + chr(4) +
          "StateLevelPetrol=" +  (if string(  tt-rvs-line.state-level-petrol) = ? then '' else string( tt-rvs-line.state-level-petrol)) + chr(4) +
          "StateLevelWater=" +  (if string(  tt-rvs-line.state-level-water) = ? then '' else string(  tt-rvs-line.state-level-water)) + chr(4) +
          "StateMeasureTcQnty="  +  (if string(  tt-rvs-line.state-measure-tc-qnty  ) = ? then '' else string(   tt-rvs-line.state-measure-tc-qnty  )) + chr(4) +
          "StateBruttoTcQnty="  +  (if string(  tt-rvs-line.state-brutto-tc-qnty  ) = ? then '' else string(    tt-rvs-line.state-brutto-tc-qnty  )) + chr(4) +
          "Description=".
  run trg/userlog.p (
      input 'create':U
      , input 'rvs-doc':U
      , input ( buffer buf_rvs-doc:handle )
      , input v-vid-action
      , input v-vid-param
      ) no-error.
  if error-status :error
  then do:
    message substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
        , chr(10)
        , vss-workfile
        , return-value
        , error-status :get-message ( 1 ) )
    view-as alert-box.
    return no-apply.
  end.
END.
ON LEAVE OF tt-rvs-line.state-add-qnty IN FRAME Dialog-Frame
DO:
  assign frame Dialog-Frame tt-rvs-line.state-add-qnty.
END.
ON LEAVE OF tt-rvs-line.state-pressure-sug IN FRAME Dialog-Frame
DO:
  assign frame Dialog-Frame tt-rvs-line.state-pressure-sug.
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
end.
END.
ON return OF tt-rvs-line.state-brutto-qnty IN FRAME Dialog-Frame
DO:
  apply "entry" to tt-rvs-line.state-measure-tc-qnty in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-rvs-line.state-density IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-rvs-line.state-density <> tt-rvs-line.state-density then do:
    assign tt-rvs-line.state-density .
    tt-rvs-line.fact-calc-add-mass = tt-rvs-line.state-add-qnty * tt-rvs-line.state-density .
    tt-rvs-line.fact-sum-mass = tt-rvs-line.state-measure-cli-qnty + tt-rvs-line.fact-calc-add-mass .
    display tt-rvs-line.fact-sum-mass tt-rvs-line.fact-calc-add-mass with frame Dialog-Frame .
    assign v-hand-input-dnst = true .
    find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "is-calc" no-error.
    if available rvs-line-attr
    then do :
      rvs-line-attr.attr-value = string(no) .
    end .
  end.
END.
ON LEAVE OF varstate-water-qnty IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame varstate-water-qnty <> varstate-water-qnty then do:
     assign varstate-sum-vol = input frame Dialog-Frame tt-rvs-line.state-measure-qnty + input frame Dialog-Frame varstate-water-qnty .
     display varstate-sum-vol with frame Dialog-Frame.
  end.
END.
ON LEAVE OF tt-rvs-line.state-measure-qnty IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-rvs-line.state-measure-qnty <> tt-rvs-line.state-measure-qnty then do:
     assign tt-rvs-line.state-measure-qnty .
     tt-rvs-line.fact-sum-vol = input frame Dialog-Frame tt-rvs-line.state-measure-qnty + input frame Dialog-Frame tt-rvs-line.state-add-qnty .
     varstate-sum-vol = input frame Dialog-Frame tt-rvs-line.state-measure-qnty + (if input frame Dialog-Frame varstate-water-qnty = ? then 0 else input frame Dialog-Frame varstate-water-qnty) .
     display tt-rvs-line.fact-sum-vol varstate-sum-vol with frame Dialog-Frame.
     if tt-rvs-line.state-density <> 0 and
        tt-rvs-line.state-density <> ? then do:
        run chg-density no-error.
        if error-status:error then return no-apply.
        run weath-water no-error.
        if error-status:error then return no-apply.
     end.
     abs-delta-mass-add-qnty = tt-rvs-line.fact-calc-add-mass * pl-error-mass / 100 no-error .
     display  abs-delta-mass-add-qnty with frame Dialog-Frame.
  end.
END.
ON return OF tt-rvs-line.state-density IN FRAME Dialog-Frame
DO:
  apply "entry" to tt-rvs-line.state-add-qnty in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-rvs-line.state-level-water IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-rvs-line.state-level-water <> tt-rvs-line.state-level-water then do:
      assign v-hand-input-lvl = true .
      find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "is-calc" no-error.
      if available rvs-line-attr
      then do :
        rvs-line-attr.attr-value = string(no) .
      end .
      run level-water in this-procedure ( input no )  .
      tt-rvs-line.state-level-petrol = input frame Dialog-Frame tt-rvs-line.state-level-total - input frame Dialog-Frame tt-rvs-line.state-level-water .
      display tt-rvs-line.state-level-petrol with frame Dialog-Frame.
  end.
END.
ON return OF tt-rvs-line.state-level-petrol IN FRAME Dialog-Frame
DO:
  apply "entry" to tt-rvs-line.state-level-total in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-rvs-line.state-level-total IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-rvs-line.state-level-total <> ?
  and input frame Dialog-Frame tt-rvs-line.state-level-total > 0
  then do :
    if (pl-rvd-temp or v-revision-mode)
    and rdc-value = "pomi-rn"
    then do :
        enable tt-rvs-line.state-temperature with frame Dialog-Frame.
    end .
    if (pl-rvd-dens or v-revision-mode)
    and rdc-value = "pomi-rn"
    then do :
        enable b-sug-struct with frame Dialog-Frame.
    end .
    if ((pl-rvd-dens and pl-rvd-temp)
     or v-revision-mode)
    and v-mi-dnst > 0
    and v-mi-tmp > 0
    and rdc-value = "pomi-rn"
    then do :
      find first dnst_sr-izmerenia no-lock where dnst_sr-izmerenia.node-code = v-mi-dnst no-error .
      find first tmp_sr-izmerenia no-lock where tmp_sr-izmerenia.node-code = v-mi-tmp no-error .
      if available dnst_sr-izmerenia
      and available tmp_sr-izmerenia
      and dnst_sr-izmerenia.node-code <> tmp_sr-izmerenia.node-code
      and ((dnst_sr-izmerenia.sr-density and dnst_sr-izmerenia.sr-temperature)
        or (tmp_sr-izmerenia.sr-density and tmp_sr-izmerenia.sr-temperature))
      then do :
        disable tt-rvs-line.state-temperature with frame Dialog-Frame .
        disable b-sug-struct with frame Dialog-Frame .
      end .
    end .
  end .
  else do :
    if rdc-value = "pomi-rn"
    then
      disable tt-rvs-line.state-temperature with frame Dialog-Frame .
    disable b-sug-struct with frame Dialog-Frame .
  end .
  if input frame Dialog-Frame tt-rvs-line.state-level-total <> tt-rvs-line.state-level-total then do:
      find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
           and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
           and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
           and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
           and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
           and rvs-line-attr.attr-code = "is-calc" no-error.
      if available rvs-line-attr
      then do :
        rvs-line-attr.attr-value = string(no) .
      end .
      assign v-hand-input-lvl = true .
      run level-water in this-procedure ( input no )  .
      tt-rvs-line.state-level-petrol = input frame Dialog-Frame tt-rvs-line.state-level-total - input frame Dialog-Frame tt-rvs-line.state-level-water .
      display tt-rvs-line.state-level-petrol with frame Dialog-Frame.
  end.
END.
ON return OF tt-rvs-line.state-level-total IN FRAME Dialog-Frame
DO:
  apply "entry" to tt-rvs-line.state-temperature in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-rvs-line.state-measure-qnty IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-rvs-line.state-measure-qnty <> tt-rvs-line.state-measure-qnty then do:
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
ON LEAVE OF tt-rvs-line.state-measure-cli-qnty IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-rvs-line.state-measure-cli-qnty <> tt-rvs-line.state-measure-cli-qnty then do:
    assign tt-rvs-line.state-measure-cli-qnty .
    tt-rvs-line.fact-sum-mass = tt-rvs-line.state-measure-cli-qnty + (tt-rvs-line.state-add-qnty * tt-rvs-line.state-density) .
    display tt-rvs-line.fact-sum-mass with frame Dialog-Frame .
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
ON LEAVE OF tt-rvs-line.state-temperature IN FRAME Dialog-Frame
DO:
    if input frame Dialog-Frame tt-rvs-line.state-temperature <> tt-rvs-line.state-temperature then do:
      assign v-hand-input-tmp = true .
      find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
           and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
           and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
           and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
           and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
           and rvs-line-attr.attr-code = "is-calc" no-error.
      if available rvs-line-attr
      then do :
        rvs-line-attr.attr-value = string(no) .
      end .
    end .
    assign frame Dialog-Frame tt-rvs-line.state-temperature.
END.
ON return OF tt-rvs-line.state-temperature IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if parmode = 'ИЗМЕНЕНИЕ':U then do:
    find first buf_rvs-line exclusive-lock
      where recid(buf_rvs-line) = parrec-rvs-line
      no-error.
  end.
  else do:
    find first buf_rvs-line no-lock
      where recid(buf_rvs-line) = parrec-rvs-line
      no-error.
  end.
  if not available buf_rvs-line then do:
     message "Неверно переданы параметры."
             "Не найдена строка сверки с recid " parrec-rvs-line " ."
     view-as alert-box error.
     return error.
  end.
  create tt-rvs-line.
  buffer-copy buf_rvs-line to tt-rvs-line.
  find first buf_rvs-doc exclusive-lock
    where buf_rvs-doc.rvs-code = tt-rvs-line.rvs-code
    .
  RUN enable_UI IN THIS-PROCEDURE.
  define variable str       as character no-undo .
  define variable str1      as character no-undo .
  find first rvs-line-attr exclusive-lock
        where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          and rvs-line-attr.attr-code = "twice-place-data" no-error.
  if available rvs-line-attr then do :
    twice-place-data = trim(rvs-line-attr.attr-value) .
    twice-place-data = trim(twice-place-data, chr(10)) .
    display b-rez with frame Dialog-Frame.
    enable b-rez with frame Dialog-Frame.
    assign
      str-level-total       = ""
      str-level-total-fact  = ""
      str-level-sug         = ""
      str-level-sug-fact    = ""
      str-level-water       = ""
      str-level-water-fact  = ""
      str-level-prc         = ""
    .
    find first place no-lock where place.obj-type = tt-rvs-line.obj-type
                               and place.obj-code = tt-rvs-line.obj-code
                               and place.pl-code  = tt-rvs-line.pl-code
                               no-error .
    do ii = 1 to num-entries(twice-place-data, chr(10)) :
      str = entry(ii, twice-place-data, chr(10)) .
      str1 = trim(entry(1, str, ":")) no-error.
      if error-status:error then next .
      if str1 = "Общий уровень"
      then do :
        str-level-total = str-level-total + "," + trim(entry(2, str, ":")) .
      end.
      if str1 = "Уровень СУГ"
      then do :
        str-level-sug = str-level-sug + "," + trim(entry(2, str, ":")) .
      end.
      if str1 = "Уровень воды"
      then do :
        str-level-water = str-level-water + "," + trim(entry(2, str, ":")) .
      end.
    end.
    assign
      str-level-total = trim(str-level-total, ",")
      str-level-total = trim(str-level-total)
      str-level-sug = trim(str-level-sug, ",")
      str-level-sug = trim(str-level-sug)
      str-level-water = trim(str-level-water, ",")
      str-level-water = trim(str-level-water)
      str-level-total-fact = str-level-total
      str-level-sug-fact = str-level-sug
      str-level-water-fact = str-level-water
    .
    hide
      tt-rvs-line.level-petrol
      tt-rvs-line.state-level-petrol
      tt-rvs-line.level-water
      tt-rvs-line.state-level-water
      tt-rvs-line.level-total
      tt-rvs-line.state-level-total
    in frame Dialog-Frame.
    display
      str-level-total
      str-level-total-fact
      str-level-sug
      str-level-sug-fact
      str-level-water
      str-level-water-fact
    with frame Dialog-Frame.
  end.
  else do :
    hide b-rez in frame Dialog-Frame.
    hide
      str-level-total
      str-level-total-fact
      str-level-sug
      str-level-sug-fact
      str-level-water
      str-level-water-fact
    in frame Dialog-Frame.
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
  run placelib_get-attr  ( input "place-rvd-dnsty"
                            ,input tt-rvs-line.obj-code
                            ,input tt-rvs-line.obj-type
                            ,input tt-rvs-line.pl-code
                            ,output v-value
                            ,output v-ok      ) no-error.
  if not v-ok then pl-rvd-dens = no.
  else pl-rvd-dens = logical(v-value) .
  run placelib_get-attr  ( input "place-rvd-lvl"
                            ,input tt-rvs-line.obj-code
                            ,input tt-rvs-line.obj-type
                            ,input tt-rvs-line.pl-code
                            ,output v-value
                            ,output v-ok      ) no-error.
  if not v-ok then pl-rvd-lvl = no.
  else pl-rvd-lvl = logical(v-value) .
  run placelib_get-attr  ( input "place-rvd-tmp"
                            ,input tt-rvs-line.obj-code
                            ,input tt-rvs-line.obj-type
                            ,input tt-rvs-line.pl-code
                            ,output v-value
                            ,output v-ok      ) no-error.
  if not v-ok then pl-rvd-temp = no.
  else pl-rvd-temp = logical(v-value) .
  if parmode <> 'ИЗМЕНЕНИЕ':U then do:
     disable tt-rvs-line.state-measure-qnty tt-rvs-line.state-measure-tc-qnty tt-rvs-line.state-density tt-rvs-line.state-add-qnty tt-rvs-line.state-brutto-qnty tt-rvs-line.state-measure-cli-qnty tt-rvs-line.state-brutto-cli-qnty tt-rvs-line.state-level-petrol tt-rvs-line.state-level-total tt-rvs-line.state-level-water tt-rvs-line.state-temperature tt-rvs-line.state-mh-qnty tt-rvs-line.state-am-qnty tt-rvs-line.state-cf-qnty tt-rvs-line.izmer-density with frame Dialog-Frame.
     disable b-sug-struct with frame Dialog-Frame.
  end.
  else
    do:
      find first buf2_place no-lock where
                 buf2_place.obj-code = tt-rvs-line.obj-code and
                 buf2_place.obj-type = tt-rvs-line.obj-type and
                 buf2_place.pl-code  = tt-rvs-line.pl-code
      no-error.
      case buf_rvs-doc.rvs-type:
        when 'перед_док':U or when 'после_док':U then
        do:
          if available buf2_place then
          do:
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-control_upd-revision':U
    ,input  'object':U
    ,input  buf_rvs-doc.host-code
    ,input  buf_rvs-doc.obj-type
    ,input  buf_rvs-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g-log2
    )  .
end.
            if g-log2
            then do :
              v-revision-mode = yes .
            end .
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-on-doc_upd-revision':U
    ,input  'object':U
    ,input  buf_rvs-doc.host-code
    ,input  buf_rvs-doc.obj-type
    ,input  buf_rvs-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g-log
    )  .
end.
            if g-log
            then do :
            end .
            else do :
              if buf2_place.is-meas
              and not pl-rvd-dens
              and not pl-rvd-lvl
              and not pl-rvd-temp
              then do :
              end .
              else do :
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-control_upd-immeas':U
    ,input  'object':U
    ,input  buf_rvs-doc.host-code
    ,input  buf_rvs-doc.obj-type
    ,input  buf_rvs-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g-log
    )  .
end.
              end .
            end .
          end.
        end.
        when 'смена':U
        then do:
            if available buf2_place then do :
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-shift_upd-revision':U
    ,input  'object':U
    ,input  buf_rvs-doc.host-code
    ,input  buf_rvs-doc.obj-type
    ,input  buf_rvs-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g-log
    )  .
end.
              if g-log
              then do :
                v-revision-mode = yes .
              end .
              else do :
                if buf2_place.is-meas
                and not pl-rvd-dens
                and not pl-rvd-lvl
                and not pl-rvd-temp
                then do :
                end.
                else do :
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-shift_upd-immeas':U
    ,input  'object':U
    ,input  buf_rvs-doc.host-code
    ,input  buf_rvs-doc.obj-type
    ,input  buf_rvs-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g-log
    )  .
end.
                end.
              end .
            end.
        end.
        when 'контроль':U
        then do:
            if available buf2_place then do :
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-control_upd-revision':U
    ,input  'object':U
    ,input  buf_rvs-doc.host-code
    ,input  buf_rvs-doc.obj-type
    ,input  buf_rvs-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g-log
    )  .
end.
              if g-log
              then do :
                v-revision-mode = yes .
              end .
              else do :
                if buf2_place.is-meas
                and not pl-rvd-dens
                and not pl-rvd-lvl
                and not pl-rvd-temp
                then do :
                end.
                else do :
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-control_upd-immeas':U
    ,input  'object':U
    ,input  buf_rvs-doc.host-code
    ,input  buf_rvs-doc.obj-type
    ,input  buf_rvs-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g-log
    )  .
end.
                end.
              end .
            end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный тип сверки" skip
            "Тип документа" buf_rvs-doc.rvs-type skip
            "Код документа" buf_rvs-doc.rvs-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .
     if not g-log then do:
        message "Недостаточно прав для редактирования!" view-as alert-box error .
        undo, return .
     end.
  end.
  run placelib_get-attr  ( input "place-SI"
                          ,input tt-rvs-line.obj-code
                          ,input tt-rvs-line.obj-type
                          ,input tt-rvs-line.pl-code
                          ,output v-value
                          ,output v-ok      ) no-error.
  if v-ok
  then place-si = integer(v-value) .
  else place-si = ? .
  run placelib_get-attr  ( input "place-SI-temp"
                          ,input tt-rvs-line.obj-code
                          ,input tt-rvs-line.obj-type
                          ,input tt-rvs-line.pl-code
                          ,output v-value
                          ,output v-ok      ) no-error.
  if v-ok
  then pl-temp-sr-izm = integer(v-value) .
  else pl-temp-sr-izm = ? .
  run placelib_get-attr  ( input "place-SI-dens"
                          ,input tt-rvs-line.obj-code
                          ,input tt-rvs-line.obj-type
                          ,input tt-rvs-line.pl-code
                          ,output v-value
                          ,output v-ok      ) no-error.
  if v-ok
  then pl-dens-sr-izm = integer(v-value) .
  else pl-dens-sr-izm = ? .
  run placelib_get-attr  ( input "place-SI-level"
                          ,input tt-rvs-line.obj-code
                          ,input tt-rvs-line.obj-type
                          ,input tt-rvs-line.pl-code
                          ,output v-value
                          ,output v-ok      ) no-error.
  if v-ok
  then pl-level-sr-izm = integer(v-value) .
  else pl-level-sr-izm = ? .
  if parmode <> 'ИЗМЕНЕНИЕ':U then do:
    disable b-save with frame Dialog-Frame.
  end.
  else do :
    if pl-rvd-dens <> pl-rvd-temp
    then do :
      find first tmp_sr-izmerenia no-lock where tmp_sr-izmerenia.node-code = pl-temp-sr-izm no-error .
      find first dnst_sr-izmerenia no-lock where dnst_sr-izmerenia.node-code = pl-dens-sr-izm no-error .
      if (available tmp_sr-izmerenia and tmp_sr-izmerenia.sr-type-izm = 0 and tmp_sr-izmerenia.sr-density and tmp_sr-izmerenia.sr-temperature)
      or (available dnst_sr-izmerenia and dnst_sr-izmerenia.sr-type-izm = 0 and dnst_sr-izmerenia.sr-density and dnst_sr-izmerenia.sr-temperature)
      then do :
        message "Бизнес-процессом не предусмотрено использование неравнозначных положений разрешения РВД по параметрам температура и плотность, "
                "если дополнительное автоматизированное СИ предназначено для измерения обоих параметров." skip
                "Подайте заявку в службу поддержки для приведения параметров в соответствие требованиям бизнес-процесса."
        view-as alert-box .
      end .
    end .
  end .
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
      RUN gbl/conf-rd.p ("rdc-dnst", "", "", 0, "", "", "", NO, OUTPUT rdc-value, OUTPUT rdc-type) NO-ERROR.
      run gbl/conf-rd.p ("tarir", "", "", 0, "", "", "", no, output tarir-value, output tarir-type) no-error.
  hide
      tt-rvs-line.meas-am-qnty
      tt-rvs-line.meas-cf-qnty
      tt-rvs-line.meas-mh-qnty
      tt-rvs-line.brutto-cli-qnty
      tt-rvs-line.state-brutto-cli-qnty
      varmeasure-water-cli-qnty
      varstate-water-cli-qnty
      tt-rvs-line.brutto-qnty
      tt-rvs-line.state-brutto-qnty
      tt-rvs-line.measure-tc-qnty
      tt-rvs-line.state-measure-tc-qnty
      tt-rvs-line.measure-qnty
      tt-rvs-line.state-measure-qnty
      tt-rvs-line.izmer-density
      in frame Dialog-Frame.
  if rdc-value <>  "pomi-rn" then do :
    hide
      tt-rvs-line.izmer-density
      b-calc
      in frame Dialog-Frame.
  end.
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
      when "delta-mass-qnty" then do :
        delta-mass-qnty = decimal(rvs-line-attr.attr-value) .
      end.
      when "CriticalDif" then do :
        CriticalDif = decimal(rvs-line-attr.attr-value) .
      end.
      when "vol-pf-sug" then do :
        tt-rvs-line.vol-pf-sug = decimal(rvs-line-attr.attr-value) .
      end.
      when "state-vol-pf-sug" then do :
        tt-rvs-line.state-vol-pf-sug = decimal(rvs-line-attr.attr-value) .
      end.
      when "dens-pf-sug" then do :
        tt-rvs-line.dens-pf-sug = decimal(rvs-line-attr.attr-value) .
      end.
      when "state-dens-pf-sug" then do :
        tt-rvs-line.state-dens-pf-sug = decimal(rvs-line-attr.attr-value) .
      end.
      when "pressure-sug" then do :
        tt-rvs-line.pressure-sug = decimal(rvs-line-attr.attr-value) .
      end.
      when "state-pressure-sug" then do :
        tt-rvs-line.state-pressure-sug = decimal(rvs-line-attr.attr-value) .
      end.
      when "sug-water-qnty" then do :
        varmeasure-water-qnty = decimal(rvs-line-attr.attr-value) .
        varstate-water-qnty = varmeasure-water-qnty .
      end.
    end case.
  end.
  release rvs-line-attr no-error .
  display
    CriticalDif
  with frame Dialog-Frame.
  find first rvs-line-attr no-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "first-enter" no-error.
  if available rvs-line-attr
  then do :
    v-first-enter = logical(rvs-line-attr.attr-value) .
  end .
  else do :
    v-first-enter = yes .
  end .
  find first bf_place no-lock where bf_place.obj-type = tt-rvs-line.obj-type
                               and bf_place.obj-code = tt-rvs-line.obj-code
                               and bf_place.pl-code  = tt-rvs-line.pl-code
                               .
  run placelib_get-attr  ( input "place-asi-sertif"
                            ,input tt-rvs-line.obj-code
                            ,input tt-rvs-line.obj-type
                            ,input tt-rvs-line.pl-code
                            ,output v-value
                            ,output v-ok      ) no-error.
  if not v-ok
  then pl-asi-sertif = no.
  else
  if v-value > ""
  then pl-asi-sertif = logical(v-value) .
  else pl-asi-sertif = no.
  run placelib_get-attr  ( input "place-diameter"
                          ,input tt-rvs-line.obj-code
                          ,input tt-rvs-line.obj-type
                          ,input tt-rvs-line.pl-code
                          ,output v-value
                          ,output v-ok      ) no-error.
  if v-ok
  then place-diameter = decimal(v-value) .
  else place-diameter = ? .
  if rdc-value =  "pomi-rn"
  then do :
    define buffer dop_sr-izmerenia for sr-izmerenia .
    find first rvs-line-attr no-lock
          where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
            and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
            and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
            and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
            and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
            and rvs-line-attr.attr-code = "mi-lvl" no-error.
    if available rvs-line-attr
    then do :
      v-mi-lvl = integer(rvs-line-attr.attr-value) .
    end .
    else do :
      v-mi-lvl = pl-level-sr-izm .
    end .
    for first dop_sr-izmerenia no-lock where dop_sr-izmerenia.node-code = v-mi-lvl :
      v-mi-lvl-name = dop_sr-izmerenia.sr-model .
      display v-mi-lvl-name with frame Dialog-Frame.
    end .
    if parmode = 'ИЗМЕНЕНИЕ':U then enable v-mi-lvl-name with frame Dialog-Frame.
    if v-mi-lvl = 0 then v-mi-lvl = ? .
    find first rvs-line-attr no-lock
          where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
            and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
            and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
            and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
            and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
            and rvs-line-attr.attr-code = "mi-dnst" no-error.
    if available rvs-line-attr
    then do :
      v-mi-dnst = integer(rvs-line-attr.attr-value) .
    end .
    else do :
      v-mi-dnst = pl-dens-sr-izm .
    end .
    for first dop_sr-izmerenia no-lock where dop_sr-izmerenia.node-code = v-mi-dnst :
      v-mi-dnst-name = dop_sr-izmerenia.sr-model .
      display v-mi-dnst-name with frame Dialog-Frame.
    end .
    if parmode = 'ИЗМЕНЕНИЕ':U then enable v-mi-dnst-name with frame Dialog-Frame.
    if v-mi-dnst = 0 then v-mi-dnst = ? .
    find first rvs-line-attr no-lock
          where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
            and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
            and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
            and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
            and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
            and rvs-line-attr.attr-code = "mi-tmp" no-error.
    if available rvs-line-attr
    then do :
      v-mi-tmp = integer(rvs-line-attr.attr-value) .
    end .
    else do :
      v-mi-tmp = pl-temp-sr-izm .
    end .
    for first dop_sr-izmerenia no-lock where dop_sr-izmerenia.node-code = v-mi-tmp :
      v-mi-tmp-name = dop_sr-izmerenia.sr-model .
      display v-mi-tmp-name with frame Dialog-Frame.
    end .
    if parmode = 'ИЗМЕНЕНИЕ':U then enable v-mi-tmp-name with frame Dialog-Frame.
    if v-mi-tmp = 0 then v-mi-tmp = ? .
    assign
      v-dnst-mi-old = v-mi-dnst
      v-tmp-mi-old  = v-mi-tmp
      v-lvl-mi-old  = v-mi-lvl
    .
  end .
  run placelib_get-attr  ( input "place-error-mass"
                            ,input tt-rvs-line.obj-code
                            ,input tt-rvs-line.obj-type
                            ,input tt-rvs-line.pl-code
                            ,output v-value
                            ,output v-ok      ) no-error.
  if not v-ok then pl-error-mass = ?.
  else pl-error-mass = decimal(v-value) .
  assign tt-rvs-line.calc-add-mass = tt-rvs-line.add-qnty * input frame Dialog-Frame tt-rvs-line.density .
  assign tt-rvs-line.sum-vol = tt-rvs-line.measure-qnty + tt-rvs-line.add-qnty .
  assign tt-rvs-line.sum-mass = tt-rvs-line.calc-add-mass + tt-rvs-line.measure-cli-qnty .
  assign varsum-vol = input frame Dialog-Frame varmeasure-water-qnty + tt-rvs-line.measure-qnty .
  assign
    tt-rvs-line.fact-calc-add-mass = tt-rvs-line.state-add-qnty * input frame Dialog-Frame tt-rvs-line.state-density
    tt-rvs-line.fact-sum-vol = tt-rvs-line.state-measure-qnty + tt-rvs-line.state-add-qnty
    tt-rvs-line.fact-sum-mass = tt-rvs-line.fact-calc-add-mass + tt-rvs-line.state-measure-cli-qnty
    tt-rvs-line.state-brutto-qnty = tt-rvs-line.fact-sum-vol
    varstate-sum-vol = input frame Dialog-Frame varstate-water-qnty + tt-rvs-line.state-measure-qnty
  .
  abs-delta-mass-add-qnty = tt-rvs-line.fact-calc-add-mass * pl-error-mass / 100 .
  abs-delta-mass-qnty = tt-rvs-line.state-measure-cli-qnty * delta-mass-qnty / 100 .
  if tt-rvs-line.level-total = 0
  or tt-rvs-line.level-total = ?
  then do :
    find first place no-lock where place.obj-type = tt-rvs-line.obj-type
                               and place.obj-code = tt-rvs-line.obj-code
                               and place.pl-code  = tt-rvs-line.pl-code
                               .
    tt-rvs-line.level-total = place.max-qnty .
    tt-rvs-line.state-level-total = tt-rvs-line.level-total .
  end.
  if tt-rvs-line.state-dens-pf-sug = ?
  or tt-rvs-line.state-dens-pf-sug = 0
  then do :
    tt-rvs-line.state-dens-pf-sug = tt-rvs-line.dens-pf-sug .
  end.
  if tt-rvs-line.state-pressure-sug = ?
  or tt-rvs-line.state-pressure-sug = 0
  then do :
    tt-rvs-line.state-pressure-sug = tt-rvs-line.pressure-sug .
  end.
  if tt-rvs-line.state-measure-qnty = tt-rvs-line.fact-sum-vol
  then do :
    tt-rvs-line.fact-sum-vol = tt-rvs-line.fact-sum-vol + tt-rvs-line.state-add-qnty .
  end.
  if tt-rvs-line.state-measure-cli-qnty = tt-rvs-line.state-brutto-cli-qnty
  then do :
    tt-rvs-line.state-brutto-cli-qnty = tt-rvs-line.state-brutto-cli-qnty + (tt-rvs-line.state-add-qnty * tt-rvs-line.state-density) .
  end.
  if tt-rvs-line.measure-qnty = tt-rvs-line.sum-vol
  then do :
    tt-rvs-line.sum-vol = tt-rvs-line.sum-vol + tt-rvs-line.add-qnty .
  end.
  if tt-rvs-line.measure-cli-qnty = tt-rvs-line.brutto-cli-qnty
  then do :
    tt-rvs-line.brutto-cli-qnty = tt-rvs-line.brutto-cli-qnty + (tt-rvs-line.add-qnty * tt-rvs-line.density) .
  end.
  level-prc = (tt-rvs-line.state-level-petrol + tt-rvs-line.state-level-water) / tt-rvs-line.state-level-total * 100 .
  display
    tt-rvs-line.calc-add-mass
    tt-rvs-line.measure-qnty
    tt-rvs-line.sum-vol
    tt-rvs-line.sum-mass
    varsum-vol
    tt-rvs-line.fact-calc-add-mass
    tt-rvs-line.state-measure-qnty
    tt-rvs-line.fact-sum-vol
    tt-rvs-line.fact-sum-mass
    varstate-sum-vol
    abs-delta-mass-add-qnty
    abs-delta-mass-qnty
    delta-mass-qnty
    tt-rvs-line.vol-pf-sug
    tt-rvs-line.state-vol-pf-sug
    tt-rvs-line.dens-pf-sug
    tt-rvs-line.state-dens-pf-sug
    tt-rvs-line.pressure-sug
    tt-rvs-line.state-pressure-sug
    varmeasure-water-qnty
    varstate-water-qnty
    level-prc
  with frame Dialog-Frame.
  hide
    level-prc
  in frame Dialog-Frame.
  run weath-measure-water  in this-procedure                 no-error.
  run level-measure-water  in this-procedure                 no-error.
  run weath-water          in this-procedure                 no-error.
  run level-water          in this-procedure ( input no )  .
  empty temp-table tt-sug-struct .
  find first rvs-line-attr no-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "sug-struct" no-error.
  if available rvs-line-attr
  then do :
    v-sug-struct-val = rvs-line-attr.attr-value .
    do ii = 1 to num-entries(v-sug-struct-val) :
      create tt-sug-struct .
      assign
        tt-sug-struct.ii = ii - 1
        tt-sug-struct.val_ = decimal(entry(ii, v-sug-struct-val))
      .
      case tt-sug-struct.ii :
        when 0  then tt-sug-struct.key_ = "метан" .
        when 1  then tt-sug-struct.key_ = "этан" .
        when 2  then tt-sug-struct.key_ = "пропан" .
        when 3  then tt-sug-struct.key_ = "н-бутан" .
        when 4  then tt-sug-struct.key_ = "и-бутан" .
        when 5  then tt-sug-struct.key_ = "н-пентан" .
        when 6  then tt-sug-struct.key_ = "и-пентан" .
        when 7  then tt-sug-struct.key_ = "н-гексан" .
        when 8  then tt-sug-struct.key_ = "н-гептан" .
        when 9  then tt-sug-struct.key_ = "н-октан" .
        when 10 then tt-sug-struct.key_ = "н-нонан" .
        when 11 then tt-sug-struct.key_ = "н-декан" .
        when 12 then tt-sug-struct.key_ = "азот" .
        when 13 then tt-sug-struct.key_ = "диоксид углерода" .
        when 14 then tt-sug-struct.key_ = "Сероводород" .
        when 15 then tt-sug-struct.key_ = "Псевдокомпонент" .
      end case .
    end .
  end .
  error-status:error = false .
  if rdc-value = 'pomi-rn'
  then do :
    display
      delta-mass-qnty
      abs-delta-mass-qnty
    with frame Dialog-Frame.
  end.
  else
  if tt-rvs-line.density = ? and parmode = 'ИЗМЕНЕНИЕ':U and tarir-value <> "yes"
  then do :
    enable
      tt-rvs-line.state-measure-qnty
      varstate-water-qnty
    with frame Dialog-Frame.
  end.
  if parmode <> 'ИЗМЕНЕНИЕ':U then do:
    disable tt-rvs-line.izmer-density with frame Dialog-Frame.
    disable b-calc b-sug-struct with frame Dialog-Frame.
    if rdc-value =  "pomi-rn"
    then do :
      hide
        hide-text-dop-si
      in frame Dialog-Frame.
    end .
    else do :
      hide
        v-mi-lvl b-mi-lvl v-mi-lvl-name
        v-mi-dnst b-mi-dnst v-mi-dnst-name
        v-mi-tmp b-mi-tmp v-mi-tmp-name
      in frame Dialog-Frame.
      display
        hide-text-dop-si
      with frame Dialog-Frame.
    end .
  end.
  else do :
    disable
      tt-rvs-line.state-temperature
      tt-rvs-line.state-level-petrol
      tt-rvs-line.state-level-water
      tt-rvs-line.state-level-total
      tt-rvs-line.state-add-qnty
      varstate-water-qnty
      b-sug-struct
      b-calc
    with frame Dialog-Frame.
    enable
      tt-rvs-line.state-measure-qnty
    with frame Dialog-Frame.
    if bf_place.is-meas
    then do :
      disable
        tt-rvs-line.state-measure-qnty
        tt-rvs-line.state-density
        tt-rvs-line.state-measure-cli-qnty
      with frame Dialog-Frame.
      if rdc-value = 'pomi-rn'
      then do :
        enable b-calc with frame Dialog-Frame.
      end .
      if pl-rvd-dens and rdc-value = 'pomi-rn'
      then do :
        if v-first-enter
        then do :
          tt-rvs-line.state-density = 0 .
          display tt-rvs-line.state-density tt-rvs-line.state-temperature with frame Dialog-Frame.
        end .
          enable b-sug-struct with frame Dialog-Frame.
      end.
      else do :
        disable b-sug-struct with frame Dialog-Frame.
      end.
      if pl-rvd-lvl
      then do :
        if rdc-value = 'pomi-rn'
        then do :
          if v-first-enter
          then do :
            tt-rvs-line.state-level-total = 0 .
            tt-rvs-line.state-level-water = 0 .
            display tt-rvs-line.state-level-total tt-rvs-line.state-level-water with frame Dialog-Frame.
          end .
          if v-mi-lvl > 0
          then
            enable
              tt-rvs-line.state-level-total
              tt-rvs-line.state-level-water
              tt-rvs-line.state-temperature
              b-sug-struct
            with frame Dialog-Frame.
        end .
        else do :
          enable
            tt-rvs-line.state-level-total
            tt-rvs-line.state-level-water
            tt-rvs-line.state-temperature
            tt-rvs-line.state-density
          with frame Dialog-Frame.
        end .
      end.
      else do :
        disable tt-rvs-line.state-level-total tt-rvs-line.state-level-water with frame Dialog-Frame.
      end.
      if pl-rvd-temp
      then do :
        if rdc-value = 'pomi-rn'
        then do :
          if v-first-enter
          then do :
            tt-rvs-line.state-temperature = ? .
            display tt-rvs-line.state-temperature with frame Dialog-Frame.
          end .
        end .
        else do :
          enable tt-rvs-line.state-temperature with frame Dialog-Frame.
        end .
      end.
      else do :
        disable tt-rvs-line.state-temperature with frame Dialog-Frame.
      end.
    end .
    else do :
      enable
        tt-rvs-line.state-temperature
        tt-rvs-line.state-measure-qnty
        tt-rvs-line.state-density
        tt-rvs-line.state-measure-cli-qnty
      with frame Dialog-Frame.
    end .
    if rdc-value = 'pomi-rn'
    then do :
      enable
        v-mi-lvl b-mi-lvl v-mi-lvl-name
        v-mi-dnst b-mi-dnst v-mi-dnst-name
        v-mi-tmp b-mi-tmp v-mi-tmp-name
      with frame Dialog-Frame.
      hide
        hide-text-dop-si
      in frame Dialog-Frame.
      tt-rvs-line.state-density:fgcolor = RED_COLOR .
      tt-rvs-line.state-dens-pf-sug:fgcolor = RED_COLOR .
      tt-rvs-line.state-level-total:fgcolor = RED_COLOR .
      tt-rvs-line.state-level-water:fgcolor = RED_COLOR .
      tt-rvs-line.state-temperature:fgcolor = RED_COLOR .
      tt-rvs-line.state-pressure-sug:fgcolor = RED_COLOR .
    end .
    else do :
      hide
        v-mi-lvl b-mi-lvl v-mi-lvl-name
        v-mi-dnst b-mi-dnst v-mi-dnst-name
        v-mi-tmp b-mi-tmp v-mi-tmp-name
      in frame Dialog-Frame.
      display
        hide-text-dop-si
      with frame Dialog-Frame.
    end .
  end.
  if v-revision-mode
  and v-first-enter
  and rdc-value = 'pomi-rn'
  then do :
    assign
      tt-rvs-line.state-level-total = 0
      tt-rvs-line.state-level-water = 0
      tt-rvs-line.state-density = 0
      tt-rvs-line.state-temperature = ?
    .
    display
      tt-rvs-line.state-level-total
      tt-rvs-line.state-level-water
      tt-rvs-line.state-density
      tt-rvs-line.state-temperature
    with frame Dialog-Frame.
    disable
      b-sug-struct
      tt-rvs-line.state-temperature
      tt-rvs-line.state-density
    with frame Dialog-Frame.
  end .
  if rdc-value = 'pomi-rn'
  and parmode = 'ИЗМЕНЕНИЕ':U
  then do :
    if v-revision-mode
    then do :
      if v-mi-lvl > 0
      then do :
        enable
          tt-rvs-line.state-level-total
          tt-rvs-line.state-level-water
        with frame Dialog-Frame.
      end .
      else do :
        disable
          tt-rvs-line.state-level-total
          tt-rvs-line.state-level-water
        with frame Dialog-Frame.
      end .
    end .
    else do :
      if not pl-rvd-temp
      then do :
        disable v-mi-tmp b-mi-tmp v-mi-tmp-name with frame Dialog-Frame.
      end .
      if not pl-rvd-dens
      then do :
        disable v-mi-dnst b-mi-dnst v-mi-dnst-name with frame Dialog-Frame.
      end .
      if not pl-rvd-lvl
      then do :
        disable v-mi-lvl b-mi-lvl v-mi-lvl-name with frame Dialog-Frame.
      end .
      if pl-rvd-lvl
      and v-mi-lvl > 0
      then do :
        enable
          tt-rvs-line.state-level-total
          tt-rvs-line.state-level-water
        with frame Dialog-Frame.
      end .
      else do :
        disable
          tt-rvs-line.state-level-total
          tt-rvs-line.state-level-water
        with frame Dialog-Frame.
      end .
    end .
  end .
  if parmode = 'ИЗМЕНЕНИЕ':U
  then do :
    enable tt-rvs-line.state-pressure-sug with frame Dialog-Frame.
    apply "leave" to tt-rvs-line.state-level-total in frame Dialog-Frame .
    if pl-rvd-dens
    and pl-rvd-temp
    and v-mi-dnst > 0
    and v-mi-tmp > 0
    then do :
      find first dnst_sr-izmerenia no-lock where dnst_sr-izmerenia.node-code = v-mi-dnst no-error .
      find first tmp_sr-izmerenia no-lock where tmp_sr-izmerenia.node-code = v-mi-tmp no-error .
      if available dnst_sr-izmerenia
      and available tmp_sr-izmerenia
      and dnst_sr-izmerenia.node-code <> tmp_sr-izmerenia.node-code
      and ((dnst_sr-izmerenia.sr-density and dnst_sr-izmerenia.sr-temperature)
        or (tmp_sr-izmerenia.sr-density and tmp_sr-izmerenia.sr-temperature))
      then do :
        message "Бизнес-процессом не предусмотрено использование разных дополнительных СИ по параметрам температура и плотность, при условии, что одно из установленных дополнительных СИ, предназначено для измерения обоих параметров." skip
                "Установите для температуры и плотности соответствующие требованиям дополнительные СИ."
        view-as alert-box .
        disable tt-rvs-line.state-temperature with frame Dialog-Frame .
        disable b-sug-struct with frame Dialog-Frame .
      end .
    end .
  end .
  find first rvs-line-attr no-lock
        where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          and rvs-line-attr.attr-code = "POkMI-result" no-error.
  if available rvs-line-attr then do :
    v-POkMI-result-attr = rvs-line-attr.attr-value .
    enable
      b-POkMI-result
    with frame Dialog-Frame.
  end.
  else do :
    disable
      b-POkMI-result
    with frame Dialog-Frame.
  end.
  for first rvs-line-attr no-lock
        where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          and rvs-line-attr.attr-code = "POkMI-warnings"
  :
    v-POkMI-warnings = rvs-line-attr.attr-value .
  end .
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
   message "Неверно определена плотность топлива." skip buf_goods.unit-base skip buf_goods.unit-cli skip tt-rvs-line.state-density view-as alert-box error.
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
abs-delta-mass-add-qnty = tt-rvs-line.fact-calc-add-mass * pl-error-mass / 100 no-error .
display tt-rvs-line.state-measure-cli-qnty tt-rvs-line.fact-calc-add-mass with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-rvs-line SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY varmeasure-water-qnty varstate-water-qnty varmeasure-water-cli-qnty
          varstate-water-cli-qnty delta-mass-qnty varstate-sum-vol varsum-vol
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-rvs-line THEN
    DISPLAY tt-rvs-line.system-qnty tt-rvs-line.system-cli-qnty
          tt-rvs-line.orig-system-qnty tt-rvs-line.orig-system-cli-qnty
          tt-rvs-line.measure-qnty tt-rvs-line.state-measure-qnty
          tt-rvs-line.measure-tc-qnty tt-rvs-line.state-measure-tc-qnty
          tt-rvs-line.vol-pf-sug tt-rvs-line.state-vol-pf-sug
          tt-rvs-line.dens-pf-sug tt-rvs-line.state-dens-pf-sug
          tt-rvs-line.pressure-sug tt-rvs-line.state-pressure-sug
          tt-rvs-line.density tt-rvs-line.state-density
          tt-rvs-line.izmer-density
          tt-rvs-line.add-qnty tt-rvs-line.state-add-qnty
          tt-rvs-line.brutto-qnty tt-rvs-line.state-brutto-qnty
          tt-rvs-line.measure-cli-qnty tt-rvs-line.state-measure-cli-qnty
          tt-rvs-line.brutto-cli-qnty tt-rvs-line.state-brutto-cli-qnty
          tt-rvs-line.level-petrol tt-rvs-line.state-level-petrol
          tt-rvs-line.level-total tt-rvs-line.state-level-total
          tt-rvs-line.level-water tt-rvs-line.state-level-water
          tt-rvs-line.temperature tt-rvs-line.state-temperature
          tt-rvs-line.meas-mh-qnty tt-rvs-line.state-mh-qnty
          tt-rvs-line.meas-am-qnty tt-rvs-line.state-am-qnty
          tt-rvs-line.meas-cf-qnty tt-rvs-line.state-cf-qnty
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-cancel b-help RECT-2 RECT-3 tt-rvs-line.state-measure-tc-qnty
         tt-rvs-line.state-density b-calc b-sug-struct tt-rvs-line.state-add-qnty tt-rvs-line.state-measure-cli-qnty
         tt-rvs-line.state-brutto-qnty tt-rvs-line.state-brutto-cli-qnty
         tt-rvs-line.state-level-petrol tt-rvs-line.state-level-total
         tt-rvs-line.state-temperature
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE level-measure-water :
END PROCEDURE.
PROCEDURE level-water :
  define input parameter p-mode as logical no-undo.
  define variable is_OK as logical no-undo initial yes.
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
define buffer buf_place for ub.place.
define variable  v-file-name as character no-undo.
define variable v-delta-mas-qnty as decimal no-undo.
define variable v-full-name as character no-undo.
    define variable tt-level-water     as integer no-undo.
    define variable tt-level-water-dec as decimal no-undo.
    define variable v-water-qnty       as decimal no-undo.
    define buffer bf-water-nxt_pl-level for pl-level.
    define variable varlevel-sm-water as decimal no-undo.
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
  find first buf_place no-lock
    where buf_place.pl-code = tt-rvs-line.pl-code
    .
  find first bf_pl-level
    where bf_pl-level.obj-type = tt-rvs-line.obj-type
      and bf_pl-level.obj-code = tt-rvs-line.obj-code
      and bf_pl-level.pl-code  = buf_place.pl-code
      and bf_pl-level.pl-level = varlevel-sm
    no-error.
  if not available bf_pl-level then do:
    message "Вычисляем объем резервуаров через градуировочные таблицы. Для резервуара " buf_place.loc1 " не задан объем для уровня " varlevel-sm view-as alert-box error.
    return no-apply.
  end.
  else do:
    if varlevel-sm = varlevel-sm-q then do:
      if error-status:error then return no-apply.
      display
        bf_pl-level.pl-qnty @ tt-rvs-line.state-measure-qnty
        bf_pl-level.pl-qnty + tt-rvs-line.state-add-qnty @ tt-rvs-line.fact-sum-vol
        with frame Dialog-Frame.
    end.
    else do:
      assign
        varlevel-sm = varlevel-sm + 1.
      find first buf-nxt_pl-level
        where buf-nxt_pl-level.obj-type = tt-rvs-line.obj-type
          and buf-nxt_pl-level.obj-code = tt-rvs-line.obj-code
          and buf-nxt_pl-level.pl-code  = buf_place.pl-code
          and buf-nxt_pl-level.pl-level = varlevel-sm
        no-error.
      if not available buf-nxt_pl-level then do:
        message "Вычисляем объем резервуаров через градуировочные таблицы. Для резервуара " buf_place.loc1 " не задан объем для уровня " varlevel-sm " измерение " varlevel-sm-q view-as alert-box error.
        return no-apply.
      end.
      else do:
        display
          bf_pl-level.pl-qnty + (buf-nxt_pl-level.pl-qnty - bf_pl-level.pl-qnty) * (varlevel-sm-q - trunc(varlevel-sm-q, 0)) @ tt-rvs-line.state-measure-qnty
          bf_pl-level.pl-qnty + (buf-nxt_pl-level.pl-qnty - bf_pl-level.pl-qnty) * (varlevel-sm-q - trunc(varlevel-sm-q, 0)) + tt-rvs-line.state-add-qnty @ tt-rvs-line.fact-sum-vol
          with frame Dialog-Frame.
      end.
    end.
      if  tt-rvs-line.state-level-water <> 0 then
      do:
          find first bf_pl-level where bf_pl-level.obj-type = tt-rvs-line.obj-type      and
              bf_pl-level.obj-code = tt-rvs-line.obj-code      and
              bf_pl-level.pl-code  = buf_place.pl-code          and
              bf_pl-level.pl-level = tt-rvs-line.state-level-water           no-error.
          if not available bf_pl-level then
          do:
                  assign
                      varlevel-sm-water = tt-rvs-line.state-level-water  + 1.
                  for each  bf-water-nxt_pl-level where bf-water-nxt_pl-level.obj-type = tt-rvs-line.obj-type  and
                      bf-water-nxt_pl-level.obj-code = tt-rvs-line.obj-code  and
                      bf-water-nxt_pl-level.pl-code  = buf_place.pl-code  and
                      bf-water-nxt_pl-level.pl-level  <  varlevel-sm-water   and
                      bf-water-nxt_pl-level.pl-level > tt-rvs-line.state-level-water  - 1 no-lock  :
                      v-water-qnty = abs (  abs (v-water-qnty )  -  bf-water-nxt_pl-level.pl-qnty / 10 )  .
                      if  bf-water-nxt_pl-level.pl-level > tt-rvs-line.state-level-water  - 1 and bf-water-nxt_pl-level.pl-level < tt-rvs-line.state-level-water  then
                      do:
                          tt-level-water =  bf-water-nxt_pl-level.pl-qnty.
                          tt-level-water-dec =  tt-rvs-line.state-level-water - bf-water-nxt_pl-level.pl-level .
                      end.
                  end.
                  varstate-water-qnty =  tt-level-water +  tt-level-water-dec *  v-water-qnty * 10  .
                  display  varstate-water-qnty with frame Dialog-Frame.
                  display tt-rvs-line.state-measure-qnty + tt-rvs-line.state-add-qnty + varstate-water-qnty  @ varstate-sum-vol
                      with frame Dialog-Frame.
          end.
          else
          do:
              assign
                  varstate-water-qnty = bf_pl-level.pl-qnty  .
              display  varstate-water-qnty with frame Dialog-Frame.
              display tt-rvs-line.state-measure-qnty + tt-rvs-line.state-add-qnty + varstate-water-qnty  @ varstate-sum-vol
                      with frame Dialog-Frame.
          end.
      end.
          else do:
              assign
                  varstate-water-qnty = 0  .
              display  varstate-water-qnty with frame Dialog-Frame.
              display tt-rvs-line.state-measure-qnty + tt-rvs-line.state-add-qnty @ varstate-sum-vol
              with frame Dialog-Frame.
          end.
      assign
        tt-rvs-line.state-brutto-qnty = input frame Dialog-Frame tt-rvs-line.state-measure-qnty + varstate-water-qnty.
        if tt-rvs-line.state-density <> 0 and
            tt-rvs-line.state-density <> ? then
        do:
            run chg-density.
            run weath-water.
        end.
      if rdc-value = "pomi-rn"  then do:
        run placelib_get-attr in this-procedure  (
            input "place-type"
            ,input tt-rvs-line.obj-code
            ,input tt-rvs-line.obj-type
            ,input tt-rvs-line.pl-code
            ,output v-value
            ,output v-ok      ) no-error.
        if v-ok then
        do :
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input tt-rvs-line.obj-type
  ,input tt-rvs-line.obj-code
  ,input 'petrol':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
            if integer(v-value) = 1 then
            do:
                for each thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = 'Delta-mass-vert':U:
                    assign
                        v-full-name = thbjattr_thbj-attr.property-value-character .
                end.
            end.
            else
            do:
                for each thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = 'Delta-mass-horiz':U:
                    assign
                        v-full-name = thbjattr_thbj-attr.property-value-character .
                end.
            end.
            do ii = 1 to NUM-ENTRIES(v-full-name,chr(10)):
                v-file-name = string(entry(ii,v-full-name,chr(10))).
                if    tt-rvs-line.state-level-petrol = decimal ( entry(1, v-file-name, ";")  )  then
                do:
                    v-delta-mas-qnty =  decimal( entry(2, v-file-name, ";") ) no-error.
                end.
            end.
        end.
        if v-delta-mas-qnty > 0.65 then v-delta-mas-qnty = 0.65 .
        delta-mass-qnty = v-delta-mas-qnty.
        display  delta-mass-qnty with frame Dialog-Frame.
        end.
    abs-delta-mass-add-qnty = tt-rvs-line.fact-calc-add-mass * pl-error-mass / 100 no-error .
    if tt-rvs-line.state-measure-cli-qnty = ?
    then do :
       tt-rvs-line.state-measure-cli-qnty = input frame Dialog-Frame tt-rvs-line.state-measure-qnty * tt-rvs-line.state-density .
       tt-rvs-line.fact-sum-mass = tt-rvs-line.state-measure-cli-qnty + tt-rvs-line.fact-calc-add-mass .
    end.
    varstate-sum-vol = input frame Dialog-Frame tt-rvs-line.state-measure-qnty + varstate-water-qnty .
    display  abs-delta-mass-add-qnty  tt-rvs-line.state-measure-cli-qnty tt-rvs-line.fact-sum-mass varstate-sum-vol with frame Dialog-Frame.
    run volume-water.
  end.
end.
END PROCEDURE.
PROCEDURE volume-measure-water :
display input frame Dialog-Frame tt-rvs-line.sum-vol -
        input frame Dialog-Frame tt-rvs-line.measure-qnty -
        input frame Dialog-Frame tt-rvs-line.add-qnty @
        varmeasure-water-qnty with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE volume-water :
if input frame Dialog-Frame tt-rvs-line.fact-sum-vol -
   input frame Dialog-Frame tt-rvs-line.state-measure-qnty -
   input frame Dialog-Frame tt-rvs-line.state-add-qnty <> ?
then
display input frame Dialog-Frame tt-rvs-line.fact-sum-vol -
        input frame Dialog-Frame tt-rvs-line.state-measure-qnty -
        input frame Dialog-Frame tt-rvs-line.state-add-qnty @
        varstate-water-qnty with frame Dialog-Frame.
else
if tt-rvs-line.fact-sum-vol -
   tt-rvs-line.state-measure-qnty -
   tt-rvs-line.state-add-qnty <> ?
then
display tt-rvs-line.fact-sum-vol - tt-rvs-line.state-measure-qnty - tt-rvs-line.state-add-qnty @
        varstate-water-qnty with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE weath-measure-water :
END PROCEDURE.
PROCEDURE weath-water :
END PROCEDURE.
