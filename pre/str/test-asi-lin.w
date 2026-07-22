DEFINE TEMP-TABLE tt-rvs-line NO-UNDO LIKE rvs-line
field meas-calc-qnty     AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0
field meas-calc-dens     AS DECIMAL FORMAT "9.9999":U INITIAL 0
field meas-cli-calc-qnty AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0
field izmer-density      AS DECIMAL FORMAT "9.9999":U INITIAL 0
field calc-add-mass      AS DECIMAL FORMAT "->>,>>>,>>9.9":U INITIAL 0
field calc-vol           AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0
field sum-mass           AS DECIMAL FORMAT "->>,>>>,>>9.9":U INITIAL 0
field sum-vol            AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0
field fact-calc-add-mass AS DECIMAL FORMAT "->>,>>>,>>9.9":U INITIAL 0
field fact-calc-vol      AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0
field fact-sum-mass      AS DECIMAL FORMAT "->>,>>>,>>9.9":U INITIAL 0
field fact-sum-vol       AS DECIMAL FORMAT "->>,>>>,>>9":U INITIAL 0
field temp-izm-vol       as decimal format "->>>9.9":U initial ?
field test-asi-diff      as decimal format ">>>9.99":U initial ?
field pomi-density       AS DECIMAL FORMAT "9.9999":U INITIAL 0
field asi-pomi-density   AS DECIMAL FORMAT "9.9999":U INITIAL 0
.
define new shared temp-table tt-temps-tab no-undo
  field ii as integer
  field key_ as character
  field temperature as decimal format "->>>9.9"
  index pi
    as primary unique
    ii
.
define new shared temp-table tt-temps no-undo
  field ii as integer
  field key_ as character
  field temperature as decimal format "->>>9.9"
  index pi
    as primary unique
    ii
.
define new shared temp-table tt-dens no-undo
  field ii as integer
  field key_ as character
  field density as decimal format "9.9999"
  index pi
    as primary unique
    ii
.
define new shared temp-table tt-dens-temp no-undo
  field ii as integer
  field key_ as character
  field density as decimal format "9.9999"
  field temperature as decimal format "->>>9.9"
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
define variable vss-description as character no-undo initial "Экран работы со строкой проверки корректности работы АСИ в резервуаре":U.
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
function getCalibrationBelt returns character
  (
  input iObjType as character,
  input iObjCode as integer,
  input iPlCode  as integer,
  input iLevelNP as decimal,
  input iLevelWater as decimal
  )
:
  define variable vCalibBelt      as  character         no-undo.
  define buffer   buf_pl-level-mm for ub.pl-level-mm.
  for each buf_pl-level-mm where
           buf_pl-level-mm.obj-type = iObjType
       and buf_pl-level-mm.obj-code = iObjCode
       and buf_pl-level-mm.pl-code  = iPlCode
       and ((buf_pl-level-mm.min-level <= iLevelNP and buf_pl-level-mm.max-level >= iLevelNP) or
            (buf_pl-level-mm.min-level <= iLevelWater and buf_pl-level-mm.max-level >= iLevelWater))
      no-lock
      break by buf_pl-level-mm.zone by buf_pl-level-mm.level:
    if first-of(buf_pl-level-mm.zone) then do:
      vCalibBelt = substitute("&1&2;&3=",vCalibBelt, buf_pl-level-mm.min-level,buf_pl-level-mm.max-level).
    end.
    vCalibBelt = substitute("&1&2&3",vCalibBelt, if buf_pl-level-mm.level = 1 then "" else ";", trim(string(buf_pl-level-mm.capacity / 1000, ">>>>>9.999"))).
    if last-of(buf_pl-level-mm.zone) and not last(buf_pl-level-mm.zone) then
      vCalibBelt = substitute("&1&2",vCalibBelt, chr(10)).
  end.
  return vCalibBelt.
end.
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
define variable v-hand-input-dnst as logical no-undo initial no .
define variable v-hand-input-tmp as logical no-undo initial no .
define variable v-hand-input-lvl as logical no-undo initial no .
define variable place-diameter    as decimal no-undo .
define variable pl-dens-sr-izm    as integer no-undo .
define variable pl-level-sr-izm   as integer no-undo .
define variable pl-temp-sr-izm    as integer no-undo .
define variable place-type        as integer no-undo.
define variable place-SI          as integer no-undo.
define variable v-revision-mode   as logical no-undo init no .
define variable v-first-enter     as logical no-undo init yes .
define variable v-POkMI-result-attr     as character no-undo.
define variable v-POkMI-warnings        as character no-undo init "" .
define variable v-value           as character no-undo.
define variable v-ok              as logical   no-undo.
define VARIABLE ii as integer no-undo .
define variable vAutomationDegree as integer no-undo extent 3 init [2,1,3].
define variable v-test-asi-type   as character no-undo .
define variable vLabel as handle no-undo .
define buffer buf_goods        for ub.goods .
define buffer buf_rvs-doc      for ub.rvs-doc.
define buffer buf_doc-attr     for ub.doc-attr .
define buffer buf_rvs-line     for ub.rvs-line .
define buffer bf_pl-level      for ub.pl-level.
define buffer buf-nxt_pl-level for ub.pl-level.
define buffer buf2_place       for ub.place.
define buffer dnst_sr-izmerenia for sr-izmerenia .
define buffer tmp_sr-izmerenia for sr-izmerenia .
define buffer lvl_sr-izmerenia for sr-izmerenia .
define stream sinp .
define stream outstream.
DEFINE BUTTON b-calc-diff
     LABEL "Расчёт проверки"
     SIZE 18 BY .88.
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
DEFINE BUTTON b-temperature
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Установка температуры"
     SIZE 3 BY .87.
DEFINE BUTTON b-density
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Установка плотности"
     SIZE 3 BY .87.
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
define variable v-mi-tmp-dnst as integer no-undo .
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
DEFINE VARIABLE delta-mass-qnty AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Отн. погр. изм. массы НП"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE abs-delta-mass-qnty AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Абс. погр. изм. массы НП"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE abs-delta-mass-add-qnty AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Абс. погр. изм. массы в трубопр."
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
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
     SIZE 55 BY 21.75.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 51 BY 21.75.
DEFINE QUERY Dialog-Frame FOR
      tt-rvs-line SCROLLING.
define variable hide-text-dop-si as character no-undo .
DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     b-POkMI-result at row 1 col 87
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
     tt-rvs-line.system-qnty AT ROW 2.25 COL 34 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Объем расчетно-книжный (л)"
          VIEW-AS FILL-IN
          SIZE 19 BY .88
     tt-rvs-line.system-cli-qnty AT ROW 2.25 COL 90 COLON-ALIGNED
          FORMAT "->>,>>>,>>9.9":U
          LABEL "Масса расчетно-книжная (кг)"
          VIEW-AS FILL-IN
          SIZE 19 BY .88
     tt-rvs-line.orig-system-qnty AT ROW 3.25 COL 34 COLON-ALIGNED
          FORMAT "->>,>>>,>>9":U
          LABEL "Первоначально (л)"
          VIEW-AS FILL-IN
          SIZE 19 BY .88
          FGCOLOR 4
     tt-rvs-line.orig-system-cli-qnty AT ROW 3.25 COL 90 COLON-ALIGNED
          FORMAT "->>,>>>,>>9.9":U
          LABEL "Первоначально (кг)"
          VIEW-AS FILL-IN
          SIZE 19 BY .88
          FGCOLOR 4
     tt-rvs-line.measure-qnty AT ROW 6.75 COL 28.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-measure-qnty AT ROW 6.75 COL 90 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.meas-calc-qnty AT ROW 7.75 COL 34 COLON-ALIGNED WIDGET-ID 20
          LABEL "Остаток рассчит. по измер."
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.measure-tc-qnty AT ROW 8.75 COL 28.25 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-measure-tc-qnty AT ROW 8.75 COL 90 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.density AT ROW 18.75 COL 32 COLON-ALIGNED FORMAT "9.9999"
          LABEL "Измер. Плотность НП (г/см3)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-density AT ROW 18.75 COL 90 COLON-ALIGNED FORMAT "9.9999"
          LABEL "Плотность НП (г/см3)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.asi-pomi-density AT ROW 19.75 COL 2 WIDGET-ID 14
          FORMAT "9.9999"
          LABEL "Плотность с АСИ прив. к ст. усл. (г/см3)"
          VIEW-AS FILL-IN
          SIZE 10 BY .88
     tt-rvs-line.meas-calc-dens AT ROW 10.75 COL 35  WIDGET-ID 8
          FORMAT "9.9999"
          LABEL "Плотность расчит. по измер. (г/см3)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.izmer-density AT ROW 9.75 COL 90 COLON-ALIGNED WIDGET-ID 24
          FORMAT "9.9999"
          LABEL "Плотность НП в резервуаре (г/см3)"
          VIEW-AS FILL-IN
          SIZE 10 BY .88
     b-density at row 9.75 col 104
     tt-rvs-line.temp-izm-vol AT ROW 10.75 COL 90 COLON-ALIGNED WIDGET-ID 4
          LABEL "Температура НП в резервуаре (°С)"
          VIEW-AS FILL-IN
          SIZE 10 BY .88
     b-temperature at row 10.75 col 104
     b-calc-diff at row 12 col 65 WIDGET-ID 206
     tt-rvs-line.test-asi-diff AT ROW 13 COL 56 WIDGET-ID 34
          LABEL "Расхождение значения по плотности НП (кг/м3)"
          VIEW-AS FILL-IN
          SIZE 7 BY .88
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
     tt-rvs-line.brutto-qnty AT ROW 12.75 COL 28.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-brutto-qnty AT ROW 12.75 COL 73.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.brutto-tc-qnty AT ROW 13.75 COL 28.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-brutto-tc-qnty AT ROW 13.75 COL 73.5 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     varmeasure-water-qnty AT ROW 25.75 COL 28.13 COLON-ALIGNED
     varstate-water-qnty AT ROW 25.75 COL 85 COLON-ALIGNED
     varsum-vol AT ROW 26.75 COL 28.13 COLON-ALIGNED
     varstate-sum-vol AT ROW 26.75 COL 85 COLON-ALIGNED
     tt-rvs-line.calc-vol AT ROW 16.75 COL 32 COLON-ALIGNED
          LABEL "Рассч. Объем НП (л)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.fact-calc-vol AT ROW 16.75 COL 90 COLON-ALIGNED
          LABEL "Объем НП (л)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.measure-cli-qnty AT ROW 17.75 COL 32 COLON-ALIGNED
          FORMAT "->>,>>>,>>9.9":U
          LABEL "Измер. Масса НП (кг)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-measure-cli-qnty AT ROW 17.75 COL 90 COLON-ALIGNED
          FORMAT "->>,>>>,>>9.9":U
          LABEL "Масса НП (кг)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         CANCEL-BUTTON b-cancel.
DEFINE FRAME Dialog-Frame
     tt-rvs-line.meas-cli-calc-qnty AT ROW 16.75 COL 34 COLON-ALIGNED WIDGET-ID 10
          LABEL "Масса расчит. по измер. (кг)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.brutto-cli-qnty AT ROW 17.75 COL 28.13 COLON-ALIGNED
          FORMAT "->>,>>>,>>9.9":U
          LABEL "Измер. брутто масса (кг)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.state-brutto-cli-qnty AT ROW 17.75 COL 73.5 COLON-ALIGNED
          FORMAT "->>,>>>,>>9.9":U
          LABEL "Факт брутто масса (кг)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.sum-vol AT ROW 22.75 COL 28.13 COLON-ALIGNED
          LABEL "Общий Объем НП (л)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.sum-mass AT ROW 23.75 COL 28.13 COLON-ALIGNED
          LABEL "Общая Масса НП (кг)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.fact-sum-vol AT ROW 22.75 COL 85 COLON-ALIGNED
          LABEL "Общий Объем НП (л)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     tt-rvs-line.fact-sum-mass AT ROW 23.75 COL 85 COLON-ALIGNED
          LABEL "Общая Масса НП (кг)"
          VIEW-AS FILL-IN
          SIZE 13 BY .88
     varmeasure-water-cli-qnty AT ROW 25.75 COL 28.13 COLON-ALIGNED
     varstate-water-cli-qnty AT ROW 25.75 COL 85 COLON-ALIGNED
     tt-rvs-line.level-petrol AT ROW 19.75 COL 30 COLON-ALIGNED
          FORMAT ">>,>>9.9":U
          LABEL "Измер. уровень топлива (см)"
          VIEW-AS FILL-IN
          SIZE 9 BY .88
     tt-rvs-line.state-level-petrol AT ROW 19.75 COL 90 COLON-ALIGNED
          FORMAT ">>,>>9.9":U
          LABEL "Факт уровень топлива (см)"
          VIEW-AS FILL-IN
          SIZE 9 BY .88
     tt-rvs-line.level-total AT ROW 6.75 COL 28 COLON-ALIGNED
          FORMAT ">>,>>9.9":U
          LABEL "Измер. общий уровень (см)"
          VIEW-AS FILL-IN
          SIZE 9 BY .88
     tt-rvs-line.state-level-total AT ROW 6.75 COL 90 COLON-ALIGNED
          FORMAT ">>,>>9.9":U
          LABEL "Факт общий уровень (см)"
          VIEW-AS FILL-IN
          SIZE 9 BY .88
     tt-rvs-line.level-water AT ROW 7.75 COL 28 COLON-ALIGNED
          FORMAT ">>,>>9.9":U
          LABEL "Измер. уровень воды (см)"
          VIEW-AS FILL-IN
          SIZE 5 BY .88
     tt-rvs-line.state-level-water AT ROW 7.75 COL 90 COLON-ALIGNED
          FORMAT ">>,>>9.9":U
          LABEL "Факт уровень воды (см)"
          VIEW-AS FILL-IN
          SIZE 9 BY .88
     tt-rvs-line.temperature AT ROW 8.75 COL 28 COLON-ALIGNED
          FORMAT "->>9.9":U
          LABEL "Измер. Температура (°С)"
          VIEW-AS FILL-IN
          SIZE 9 BY .88
     tt-rvs-line.state-temperature AT ROW 8.75 COL 90 COLON-ALIGNED
          FORMAT "->>9.9":U
          LABEL "Температура НП при измер. плотн. (°С)"
          VIEW-AS FILL-IN
          SIZE 9 BY .88
     tt-rvs-line.meas-mh-qnty AT ROW 24.75 COL 28.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY .88
     tt-rvs-line.state-mh-qnty AT ROW 29.25 COL 15.5 COLON-ALIGNED
          LABEL "Оборот по ТРК"
          VIEW-AS FILL-IN
          SIZE 10 BY .88
     tt-rvs-line.meas-am-qnty AT ROW 25.75 COL 28.13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY .88
     tt-rvs-line.state-am-qnty AT ROW 29.25 COL 55.5 COLON-ALIGNED
          LABEL "Сумма оборота по ТРК"
          VIEW-AS FILL-IN
          SIZE 10 BY .88
     tt-rvs-line.meas-cf-qnty AT ROW 26.75 COL 29.13 COLON-ALIGNED
          LABEL "Измеренное кол-во наливов"
          VIEW-AS FILL-IN
          SIZE 17 BY .88
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         CANCEL-BUTTON b-cancel.
DEFINE FRAME Dialog-Frame
     tt-rvs-line.state-cf-qnty AT ROW 29.25 COL 95.5 COLON-ALIGNED
          LABEL "Количество наливов"
          VIEW-AS FILL-IN
          SIZE 10 BY .88
     delta-mass-qnty AT ROW 19.75 COL 90 COLON-ALIGNED  WIDGET-ID 22
     abs-delta-mass-qnty AT ROW 20.75 COL 90 COLON-ALIGNED  WIDGET-ID 22
     CriticalDif AT ROW 4.25 COL 34 COLON-ALIGNED WIDGET-ID 2
     RECT-2 AT ROW 6.5 COL 54.25
     RECT-3 AT ROW 6.5 COL 2
     SPACE(58.61) SKIP(2.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Документ проверки корректности работы АСИ в резервуаре"
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
  release rvs-line-attr no-error .
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-POkMI-result IN FRAME Dialog-Frame
DO:
  message v-POkMI-result-attr view-as alert-box information .
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
  if v-revision-mode
  then do :
    if v-mi-dnst > 0
    and v-mi-tmp > 0
    then do :
      enable
        tt-rvs-line.state-level-total
        tt-rvs-line.state-level-water
        b-temperature
        b-density
      with frame Dialog-Frame.
    end .
  end .
  else do :
    if ((pl-rvd-lvl and v-mi-lvl > 0) or not pl-rvd-lvl)
    and ((pl-rvd-dens and v-mi-dnst > 0) or not pl-rvd-dens)
    and ((pl-rvd-temp and v-mi-tmp > 0) or not pl-rvd-temp)
    then do :
      if pl-rvd-lvl
      then do :
        enable
          tt-rvs-line.state-level-total
          tt-rvs-line.state-level-water
        with frame Dialog-Frame.
      end .
      if pl-rvd-dens
      then do :
        enable
          b-density
        with frame Dialog-Frame.
      end .
      if pl-rvd-temp
      then do :
        enable
          b-temperature
        with frame Dialog-Frame.
      end .
    end .
  end .
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
    if v-mi-dnst:screen-value <> "?"
    then do :
      if integer(v-mi-dnst:screen-value) <> v-node-code
      then do :
        v-mi-tmp-dnst = 0 .
      end .
    end .
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
  if rdc-value = 'pomi-rn'
  then do :
    if string(v-mi-dnst) <> v-old-val
    then do :
      v-mi-tmp-dnst = 0 .
      tt-rvs-line.izmer-density = 0 .
      tt-rvs-line.state-temperature = ? .
    end .
    display tt-rvs-line.izmer-density tt-rvs-line.state-temperature with frame Dialog-Frame.
    if v-revision-mode
    then do :
      if v-mi-lvl > 0
      and v-mi-tmp > 0
      then do :
        enable
          tt-rvs-line.state-level-total
          tt-rvs-line.state-level-water
          b-temperature
          b-density
        with frame Dialog-Frame.
      end .
    end .
    else do :
      if ((pl-rvd-lvl and v-mi-lvl > 0) or not pl-rvd-lvl)
      and ((pl-rvd-dens and v-mi-dnst > 0) or not pl-rvd-dens)
      and ((pl-rvd-temp and v-mi-tmp > 0) or not pl-rvd-temp)
      then do :
        if pl-rvd-lvl
        then do :
          enable
            tt-rvs-line.state-level-total
            tt-rvs-line.state-level-water
          with frame Dialog-Frame.
        end .
        if pl-rvd-dens
        then do :
          enable
            b-density
          with frame Dialog-Frame.
        end .
        if pl-rvd-temp
        then do :
          enable
            b-temperature
          with frame Dialog-Frame.
        end .
      end .
    end .
    if dnst_sr-izmerenia.sr-temperature
    and v-mi-dnst <> v-mi-tmp
    and b-mi-tmp:sensitive
    then do :
        v-mi-tmp = v-mi-dnst .
        v-mi-tmp:screen-value = v-mi-dnst:screen-value .
        v-mi-tmp-name = v-mi-dnst-name .
        apply "leave" to v-mi-tmp in frame Dialog-Frame .
    end .
  end .
  else do :
    if string(v-mi-dnst) <> v-old-val
    then do :
      tt-rvs-line.state-density = 0 .
    end .
    display tt-rvs-line.state-density with frame Dialog-Frame.
    if v-revision-mode
    then do :
      if v-mi-lvl > 0
      and v-mi-tmp > 0
      then do :
        enable
          tt-rvs-line.state-level-total
          tt-rvs-line.state-level-water
          tt-rvs-line.state-temperature
          tt-rvs-line.state-density
        with frame Dialog-Frame.
      end .
    end .
    else do :
      if ((pl-rvd-lvl and v-mi-lvl > 0) or not pl-rvd-lvl)
      and ((pl-rvd-dens and v-mi-dnst > 0) or not pl-rvd-dens)
      and ((pl-rvd-temp and v-mi-tmp > 0) or not pl-rvd-temp)
      then do :
        if pl-rvd-lvl
        then do :
          enable
            tt-rvs-line.state-level-total
            tt-rvs-line.state-level-water
          with frame Dialog-Frame.
        end .
        if pl-rvd-dens
        then do :
          enable
            tt-rvs-line.state-density
          with frame Dialog-Frame.
        end .
        if pl-rvd-temp
        then do :
          enable
            tt-rvs-line.state-temperature
          with frame Dialog-Frame.
        end .
      end .
    end .
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
    tt-rvs-line.temp-izm-vol = ? .
  end .
  display tt-rvs-line.temp-izm-vol with frame Dialog-Frame.
  if v-revision-mode
  then do :
    if v-mi-dnst > 0
    and v-mi-lvl > 0
    then do :
      enable
        tt-rvs-line.state-level-total
        tt-rvs-line.state-level-water
        b-temperature
        b-density
      with frame Dialog-Frame.
    end .
  end .
  else do :
    if ((pl-rvd-lvl and v-mi-lvl > 0) or not pl-rvd-lvl)
    and ((pl-rvd-dens and v-mi-dnst > 0) or not pl-rvd-dens)
    and ((pl-rvd-temp and v-mi-tmp > 0) or not pl-rvd-temp)
    then do :
      if pl-rvd-lvl
      then do :
        enable
          tt-rvs-line.state-level-total
          tt-rvs-line.state-level-water
        with frame Dialog-Frame.
      end .
      if pl-rvd-dens
      then do :
        enable
          b-density
        with frame Dialog-Frame.
      end .
      if pl-rvd-temp
      then do :
        enable
          b-temperature
        with frame Dialog-Frame.
      end .
    end .
  end .
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
ON CHOOSE OF b-calc-diff IN FRAME Dialog-Frame
DO:
  case v-test-asi-type :
    when "test-asi_dens-place"
    then do :
      if tt-rvs-line.izmer-density = ?
      or tt-rvs-line.izmer-density <= 0
      then do :
        message "Заполнены не все поля, необходимые для расчета! Введите плотность." view-as alert-box information .
        return no-apply .
      end .
      assign tt-rvs-line.test-asi-diff = abs(tt-rvs-line.density - tt-rvs-line.izmer-density) * 1000 .
      display tt-rvs-line.test-asi-diff with frame Dialog-Frame .
      if tt-rvs-line.test-asi-diff > 1.7
      then tt-rvs-line.test-asi-diff:fgcolor = RED_COLOR .
      else tt-rvs-line.test-asi-diff:fgcolor = 0 .
      run str/test-asi-result.w (input "Результат расчета проверки корректности работы канала плотности НП АСИ резервуара",
                                 input "Плотность НП по замерам АСИ в резервуаре (г/см3)|Плотность НП измеренная (г/см3)|Расхождение значения по плотности НП (г/см3)|Расхождение значения по плотности НП (кг/м3)",
                                 input substitute("&1,&2,&3,&4", tt-rvs-line.density, tt-rvs-line.izmer-density, tt-rvs-line.test-asi-diff / 1000, tt-rvs-line.test-asi-diff)
                                 ) .
    end .
    when "test-asi_dens-pump"
    then do :
      run pomi-calc .
      if return-value = "need-data"
      or return-value = "pomi-error"
      then return no-apply .
      assign tt-rvs-line.test-asi-diff = abs(tt-rvs-line.asi-pomi-density - tt-rvs-line.pomi-density) * 1000 .
      display tt-rvs-line.test-asi-diff with frame Dialog-Frame .
      if tt-rvs-line.test-asi-diff > 1.7
      then tt-rvs-line.test-asi-diff:fgcolor = RED_COLOR .
      else tt-rvs-line.test-asi-diff:fgcolor = 0 .
      run str/test-asi-result.w (input "Результат расчета проверки корректности работы канала плотности НП АСИ резервуара",
                                 input "Плотность НП с АСИ, приведенная к стандартным условиям (г/см3)|Плотность НП измеренная и приведенная к стандартным условиям (г/см3)|Расхождение значения по плотности НП (г/см3)|Расхождение значения по плотности НП (кг/м3)",
                                 input substitute("&1,&2,&3,&4", tt-rvs-line.asi-pomi-density, tt-rvs-line.pomi-density, tt-rvs-line.test-asi-diff / 1000, tt-rvs-line.test-asi-diff)
                                 ) .
    end .
    when "test-asi_mass"
    then do :
      run pomi-calc .
      if return-value = "need-data"
      or return-value = "pomi-error"
      then return no-apply .
      assign tt-rvs-line.test-asi-diff = abs((tt-rvs-line.measure-cli-qnty - tt-rvs-line.state-measure-cli-qnty) / tt-rvs-line.state-measure-cli-qnty) * 100 .
      display tt-rvs-line.test-asi-diff with frame Dialog-Frame .
      if tt-rvs-line.test-asi-diff > 0.65
      then tt-rvs-line.test-asi-diff:fgcolor = RED_COLOR .
      else tt-rvs-line.test-asi-diff:fgcolor = 0 .
      run str/test-asi-result.w (input "Результат расчета проверки корректности работы АСИ по массе НП",
                                 input "Измеренная масса НП по расчетам АСИ (кг)|Масса НП по расчетам ПОкМИ (кг)|Расхождение значения по массе НП (кг)|Расхождение значения по массе НП (%)",
                                 input substitute("&1,&2,&3,&4", tt-rvs-line.measure-cli-qnty, tt-rvs-line.state-measure-cli-qnty, ABS(tt-rvs-line.state-measure-cli-qnty - tt-rvs-line.measure-cli-qnty), tt-rvs-line.test-asi-diff)
                                 ) .
    end .
  end case .
end .
procedure pomi-calc:
define variable v-proc as character no-undo.
define variable v-pokmi-dll-version as character no-undo .
define variable v-code            as character no-undo.
define variable ii                as integer   no-undo.
define variable place-ratio-error as decimal no-undo.
define variable dens-prov         as decimal no-undo format "9.9999999999":U.
define variable CalibTable        as character no-undo initial "".
define variable CalibBelt         as character no-undo initial "".
define variable ToolType          as integer no-undo.
define variable LevelToolType          as integer no-undo.
define variable A_LevelMeasurementTool  as decimal no-undo.
define variable DeltaAbs_H              as decimal no-undo.
define variable DeltaAbs_H_Water        as decimal no-undo.
define variable DeltaAbs_R              as decimal no-undo.
define variable DeltaAbs_Tv             as decimal no-undo.
define variable DeltaAbs_Tr             as decimal no-undo.
define variable DeltaOtn_N              as decimal no-undo init 0.05 .
define variable DeltaOtn_K              as decimal no-undo.
define variable A_Reservoir             as decimal no-undo init 0.0000125 .
define variable DeadZone_Reservoir      as decimal no-undo.
define variable DeltaOtn_H              as decimal no-undo.
define variable DeltaOtn_H_Water        as decimal no-undo.
define variable DeltaOtn_R              as decimal no-undo.
define variable ToolAutomationLevel_H   as integer no-undo.
define variable ToolAutomationLevel_H_Water as integer no-undo.
define variable ToolAutomationLevel_R   as integer no-undo.
define variable ToolAutomationLevel_Tv  as integer no-undo.
define variable ToolAutomationLevel_Tr  as integer no-undo.
define variable DeltaAbs_H_CalcType     as integer no-undo.
define variable DeltaAbs_H_Water_CalcType   as integer no-undo.
define variable temp-for-pomi           as integer no-undo.
define variable error-string            as character no-undo.
define variable v-is-meas               as logical no-undo.
define variable v-mm-density            as decimal no-undo.
define variable place-ponton            as logical no-undo .
define variable place-ponton-mass       as decimal no-undo .
define variable place-ponton-height     as decimal no-undo .
define variable DeltaV1                 as decimal no-undo .
define variable DeltaV2                 as decimal no-undo .
define variable WaterDeltaV1            as decimal no-undo .
define variable WaterDeltaV2            as decimal no-undo .
define variable Tv                      as decimal no-undo .
define variable Tr                      as decimal no-undo .
define variable R                       as decimal no-undo .
define variable v-POkMI-result          as character no-undo.
define buffer buf_sr-izmerenia for sr-izmerenia .
define buffer dens_sr-izmerenia for sr-izmerenia .
define buffer temp_sr-izmerenia for sr-izmerenia .
define buffer level_sr-izmerenia for sr-izmerenia .
define buffer temp-dens_sr-izmerenia for sr-izmerenia .
define buffer buf_place     for ub.place.
define buffer water1_pl-level  for ub.pl-level .
define buffer water2_pl-level  for ub.pl-level .
define buffer total1_pl-level  for ub.pl-level .
define buffer total2_pl-level  for ub.pl-level .
define buffer buf_pl-level-attr for ub.pl-level-attr .
define buffer bf_goods for ub.goods .
define buffer bf_place for ub.place .
define variable vErr as character no-undo .
define variable vWrn as character no-undo .
define variable vDllVersion as character no-undo .
define variable V_total      as decimal no-undo .
define variable V_water      as decimal no-undo .
define variable DeltaV       as decimal no-undo .
define variable Vcy          as decimal no-undo .
define variable Rcy          as decimal no-undo .
define variable V_product    as decimal no-undo .
define variable V            as decimal no-undo .
define variable Rv           as decimal no-undo .
define variable M            as decimal no-undo .
define variable CTL_base_alt as decimal no-undo .
define variable CPL_base_alt as decimal no-undo .
define variable CTPL_base_alt as decimal no-undo .
define variable Fp_base_alt  as decimal no-undo .
define variable CTL_obs_base as decimal no-undo .
define variable CPL_obs_base as decimal no-undo .
define variable CTPL_obs_base as decimal no-undo .
define variable Fp_obs_base  as decimal no-undo .
define variable DeltaOtn_Vcy as decimal no-undo .
define variable DeltaOtn_Vm  as decimal no-undo .
define variable DeltaOtn_M   as decimal no-undo .
define variable VolumetricExpansion as decimal no-undo .
  assign frame Dialog-Frame tt-rvs-line.state-level-total   .
  assign frame Dialog-Frame tt-rvs-line.state-level-water   .
  assign frame Dialog-Frame tt-rvs-line.state-temperature   .
  assign frame Dialog-Frame tt-rvs-line.izmer-density       .
  assign frame Dialog-Frame tt-rvs-line.temp-izm-vol       .
  assign frame Dialog-Frame CriticalDif .
  assign frame Dialog-Frame delta-mass-qnty .
  _trpomi :
    do on error undo, return :
    if tt-rvs-line.izmer-density = ? or tt-rvs-line.izmer-density = 0 then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите плотность измер.для ПОкМИ"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.izmer-density in frame Dialog-Frame.
      undo _trpomi, return "need-data" .
    end.
    if tt-rvs-line.state-level-total = ? or tt-rvs-line.state-level-total = 0 then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите факт. общий уровень"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-level-total in frame Dialog-Frame.
      undo _trpomi, return "need-data" .
    end.
    if tt-rvs-line.state-level-water = ? then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите факт. уровень воды"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-level-water in frame Dialog-Frame.
      undo _trpomi, return "need-data" .
    end.
    if tt-rvs-line.state-temperature = ?
    then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите температуру"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.state-temperature in frame Dialog-Frame.
      undo _trpomi, return "need-data" .
    end.
    if tt-rvs-line.temp-izm-vol = ?
    then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите температуру измерения объема"
      view-as alert-box error.
      apply "entry" to tt-rvs-line.temp-izm-vol in frame Dialog-Frame.
      undo _trpomi, return "need-data" .
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
        when "place-dead-high" then do :
          if v-ok then DeadZone_Reservoir = decimal(v-value) .
        end.
        when "place-ponton" then do :
          if v-ok then place-ponton = logical(v-value) .
        end.
        when "place-ponton-mass" then do :
          if v-ok then place-ponton-mass = decimal(v-value) .
        end.
        when "place-ponton-height" then do :
          if v-ok then place-ponton-height = decimal(v-value) .
        end.
      end case.
    end.
    if tt-rvs-line.state-level-water > 0
    then do :
      find last water1_pl-level no-lock where water1_pl-level.pl-code  = tt-rvs-line.pl-code
                                          and water1_pl-level.obj-code = tt-rvs-line.obj-code
                                          and water1_pl-level.obj-type = tt-rvs-line.obj-type
                                          and water1_pl-level.pl-level <= tt-rvs-line.state-level-water
                                          no-error .
      if available water1_pl-level
      then do :
        WaterDeltaV1 = ? .
        for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = water1_pl-level.pl-code
                                              and buf_pl-level-attr.obj-code = water1_pl-level.obj-code
                                              and buf_pl-level-attr.obj-type = water1_pl-level.obj-type
                                              and buf_pl-level-attr.pl-level = water1_pl-level.pl-level
                                              and buf_pl-level-attr.attr-code = "deltaV"
                                              :
          WaterDeltaV1 = decimal(buf_pl-level-attr.attr-value) no-error .
        end .
      end .
      if available water1_pl-level
      and water1_pl-level.pl-level <> tt-rvs-line.state-level-water
      then do :
        find first water2_pl-level no-lock where water2_pl-level.pl-code  = tt-rvs-line.pl-code
                                            and water2_pl-level.obj-code = tt-rvs-line.obj-code
                                            and water2_pl-level.obj-type = tt-rvs-line.obj-type
                                            and water2_pl-level.pl-level >= tt-rvs-line.state-level-water
                                            no-error .
        if available water2_pl-level
        then do :
          WaterDeltaV2 = ? .
          for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = water2_pl-level.pl-code
                                                and buf_pl-level-attr.obj-code = water2_pl-level.obj-code
                                                and buf_pl-level-attr.obj-type = water2_pl-level.obj-type
                                                and buf_pl-level-attr.pl-level = water2_pl-level.pl-level
                                                and buf_pl-level-attr.attr-code = "deltaV"
                                                :
            WaterDeltaV2 = decimal(buf_pl-level-attr.attr-value) no-error .
          end .
        end .
      end .
    end .
    find last total1_pl-level no-lock where total1_pl-level.pl-code  = tt-rvs-line.pl-code
                                        and total1_pl-level.obj-code = tt-rvs-line.obj-code
                                        and total1_pl-level.obj-type = tt-rvs-line.obj-type
                                        and total1_pl-level.pl-level <= tt-rvs-line.state-level-total
                                        no-error .
    if not available total1_pl-level
    then do :
      find first bf_goods no-lock where bf_goods.gds-code = tt-rvs-line.gds-code no-error .
      find first bf_place no-lock where bf_place.pl-code = tt-rvs-line.pl-code no-error .
      message
        substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Запуск ПОкМИ невозможен.'
                   ,(if available bf_place then bf_place.loc1 else "?")
                   ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                   ,(if available bf_goods then bf_goods.gds-name else "?") )
      view-as alert-box .
      undo _trpomi, return "need-data" .
    end .
    DeltaOtn_K = ? .
    for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total1_pl-level.pl-code
                                          and buf_pl-level-attr.obj-code = total1_pl-level.obj-code
                                          and buf_pl-level-attr.obj-type = total1_pl-level.obj-type
                                          and buf_pl-level-attr.pl-level = total1_pl-level.pl-level
                                          and buf_pl-level-attr.attr-code = "tarir-delta"
                                          :
      DeltaOtn_K = decimal(buf_pl-level-attr.attr-value) .
    end .
    if DeltaOtn_K = ? then DeltaOtn_K = 0.25 .
    DeltaV1 = ? .
    for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total1_pl-level.pl-code
                                          and buf_pl-level-attr.obj-code = total1_pl-level.obj-code
                                          and buf_pl-level-attr.obj-type = total1_pl-level.obj-type
                                          and buf_pl-level-attr.pl-level = total1_pl-level.pl-level
                                          and buf_pl-level-attr.attr-code = "deltaV"
                                          :
      DeltaV1 = decimal(buf_pl-level-attr.attr-value) no-error .
    end .
    find first total2_pl-level no-lock where total2_pl-level.pl-code  = tt-rvs-line.pl-code
                                        and total2_pl-level.obj-code = tt-rvs-line.obj-code
                                        and total2_pl-level.obj-type = tt-rvs-line.obj-type
                                        and total2_pl-level.pl-level > tt-rvs-line.state-level-total
                                        no-error .
    if not available total2_pl-level
    then do :
      find first bf_goods no-lock where bf_goods.gds-code = tt-rvs-line.gds-code no-error .
      find first bf_place no-lock where bf_place.pl-code = tt-rvs-line.pl-code no-error .
      message
        substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Запуск ПОкМИ невозможен.'
                   ,(if available bf_place then bf_place.loc1 else "?")
                   ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                   ,(if available bf_goods then bf_goods.gds-name else "?") )
      view-as alert-box .
      undo _trpomi, return "need-data" .
    end .
    DeltaV2 = ? .
    for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total2_pl-level.pl-code
                                          and buf_pl-level-attr.obj-code = total2_pl-level.obj-code
                                          and buf_pl-level-attr.obj-type = total2_pl-level.obj-type
                                          and buf_pl-level-attr.pl-level = total2_pl-level.pl-level
                                          and buf_pl-level-attr.attr-code = "deltaV"
                                          :
      DeltaV2 = decimal(buf_pl-level-attr.attr-value) no-error .
    end .
    if available water1_pl-level
    then do :
      CalibTable = Substitute("&1=&2", water1_pl-level.pl-level, (water1_pl-level.pl-qnty / 1000)) + (if WaterDeltaV1 > 0 then ("=" + trim(string(WaterDeltaV1, ">>9.9999"))) else "") + chr(10) .
    end .
    if available water2_pl-level
    then do :
      CalibTable = CalibTable + Substitute("&1=&2", water2_pl-level.pl-level, (water2_pl-level.pl-qnty / 1000)) + (if WaterDeltaV2 > 0 then ("=" + trim(string(WaterDeltaV2, ">>9.9999"))) else "") + chr(10) .
    end .
    CalibTable = CalibTable + Substitute("&1=&2", total1_pl-level.pl-level, (total1_pl-level.pl-qnty / 1000)) + (if DeltaV1 > 0 then ("=" + trim(string(DeltaV1, ">>9.9999"))) else "") + chr(10) .
    CalibTable = CalibTable + Substitute("&1=&2", total2_pl-level.pl-level, (total2_pl-level.pl-qnty / 1000)) + (if DeltaV2 > 0 then ("=" + trim(string(DeltaV2, ">>9.9999"))) else "") .
    CalibBelt = getCalibrationBelt(
        tt-rvs-line.obj-type,
        tt-rvs-line.obj-code,
        tt-rvs-line.pl-code,
        tt-rvs-line.state-level-total,
        if tt-rvs-line.state-level-water <> ? then tt-rvs-line.state-level-water else 0
    ).
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
        undo _trpomi, return "need-data" .
      end.
      else do :
        find first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = place-si no-error.
        if not available buf_sr-izmerenia then do :
          message
          "Ошибка работы с библиотекой ПОкМИ"
          substitute( 'Не найдено средство измерения с кодом &1', place-si ) skip
          view-as alert-box error.
          undo _trpomi, return "need-data" .
        end.
        else do :
          assign
            ToolType               = buf_sr-izmerenia.sr-type-id
            A_LevelMeasurementTool = buf_sr-izmerenia.sr-temp-line
            ToolAutomationLevel_H  = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
            ToolAutomationLevel_H_Water = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
            DeltaAbs_H             = buf_sr-izmerenia.sr-abs-err-neft-water
            DeltaAbs_H_Water       = buf_sr-izmerenia.sr-abs-err-water
            ToolAutomationLevel_R  = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
            DeltaAbs_R             = buf_sr-izmerenia.sr-abs-err-dens
            ToolAutomationLevel_Tv = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
            DeltaAbs_Tv            = buf_sr-izmerenia.sr-abs-err-temp-vol
            ToolAutomationLevel_Tr = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
            DeltaAbs_Tr            = buf_sr-izmerenia.sr-abs-err-temp-dens
            DeltaOtn_N             = 0.05
            DeltaOtn_H             = buf_sr-izmerenia.sr-relative-err-neft-water
            DeltaOtn_H_Water       = buf_sr-izmerenia.sr-relative-err-water
            DeltaOtn_R             = buf_sr-izmerenia.sr-relative-err-dens
            DeltaAbs_H_CalcType    = buf_sr-izmerenia.sr-type-level-measuring + 1
            DeltaAbs_H_Water_CalcType = buf_sr-izmerenia.sr-type-level-measuring + 1
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
        undo _trpomi, return "need-data" .
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
          undo _trpomi, return "need-data" .
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
        message
          substitute ("Для складского места &1 не заданно дополнительное средство измерения плотности",tt-rvs-line.pl-code)
        view-as alert-box error.
        undo _trpomi, return "need-data" .
      end .
      else
      if v-mi-dnst <> place-si
      or not available buf_sr-izmerenia
      then do :
        find first dens_sr-izmerenia no-lock where dens_sr-izmerenia.node-code = v-mi-dnst no-error.
        if not available dens_sr-izmerenia then do :
          message
          "Ошибка работы с библиотекой ПОкМИ"
          substitute( 'Не найдено средство измерения с кодом &1', v-mi-dnst ) skip
          view-as alert-box error.
          undo _trpomi, return "need-data" .
        end.
        else do :
          assign
            ToolType               = dens_sr-izmerenia.sr-type-id
            DeltaAbs_R             = dens_sr-izmerenia.sr-abs-err-dens
            DeltaOtn_R             = dens_sr-izmerenia.sr-relative-err-dens
          .
        end.
      end .
    end .
    if pl-rvd-temp
    or v-revision-mode
    then do :
      if v-mi-tmp = 0
      or v-mi-tmp = ?
      then do :
        message
          substitute ("Для складского места &1 не заданно дополнительное средство измерения температуры",tt-rvs-line.pl-code)
        view-as alert-box error.
        undo _trpomi, return "need-data" .
      end .
      else
      if v-mi-tmp <> place-si
      or not available buf_sr-izmerenia
      then do :
        find first temp_sr-izmerenia no-lock where temp_sr-izmerenia.node-code = v-mi-tmp no-error.
        if not available temp_sr-izmerenia then do :
          message
          "Ошибка работы с библиотекой ПОкМИ"
          substitute( 'Не найдено средство измерения с кодом &1', v-mi-tmp ) skip
          view-as alert-box error.
          undo _trpomi, return "need-data" .
        end.
        else do :
          assign
            DeltaAbs_Tv            = temp_sr-izmerenia.sr-abs-err-temp-vol
            DeltaAbs_Tr            = temp_sr-izmerenia.sr-abs-err-temp-dens
            ToolAutomationLevel_Tr = vAutomationDegree[temp_sr-izmerenia.sr-type-izm + 1]
          .
        end.
      end .
    end .
    if v-mi-tmp-dnst > 0
    and v-mi-tmp-dnst <> v-mi-tmp
    then do :
      for first temp-dens_sr-izmerenia no-lock where temp-dens_sr-izmerenia.node-code = v-mi-tmp-dnst :
        assign
          DeltaAbs_Tr = temp-dens_sr-izmerenia.sr-abs-err-temp-dens when temp-dens_sr-izmerenia.sr-abs-err-temp-dens > 0
          ToolAutomationLevel_Tr = vAutomationDegree[temp-dens_sr-izmerenia.sr-type-izm + 1]
        .
      end .
    end .
    if available level_sr-izmerenia
    then assign
      LevelToolType = level_sr-izmerenia.sr-type-level-measuring
      ToolAutomationLevel_H  = vAutomationDegree[level_sr-izmerenia.sr-type-izm + 1]
      ToolAutomationLevel_H_Water = vAutomationDegree[level_sr-izmerenia.sr-type-izm + 1]
      DeltaAbs_H_CalcType = level_sr-izmerenia.sr-type-level-measuring + 1
      DeltaAbs_H_Water_CalcType = level_sr-izmerenia.sr-type-level-measuring + 1
    .
    else assign
      LevelToolType = buf_sr-izmerenia.sr-type-level-measuring
      ToolAutomationLevel_H  = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
      ToolAutomationLevel_H_Water = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
      DeltaAbs_H_CalcType = buf_sr-izmerenia.sr-type-level-measuring + 1
      DeltaAbs_H_Water_CalcType = buf_sr-izmerenia.sr-type-level-measuring + 1
    .
    if avail temp_sr-izmerenia then
      ToolAutomationLevel_Tv = vAutomationDegree[temp_sr-izmerenia.sr-type-izm + 1].
    else
      ToolAutomationLevel_Tv = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1].
    if avail dens_sr-izmerenia then
      ToolAutomationLevel_R  = vAutomationDegree[dens_sr-izmerenia.sr-type-izm + 1].
    else
      ToolAutomationLevel_R = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1].
    if available dens_sr-izmerenia
    and dens_sr-izmerenia.sr-type-izm = 3
    and dens_sr-izmerenia.sr-temperature
    then do :
      DeltaAbs_Tr = dens_sr-izmerenia.sr-abs-err-temp-dens .
      ToolAutomationLevel_Tr = vAutomationDegree[dens_sr-izmerenia.sr-type-izm + 1].
    end .
    if DeltaAbs_H       = ? then DeltaAbs_H = 0 .
    if DeltaAbs_H_Water = ? then DeltaAbs_H_Water = 0 .
    if DeltaAbs_R       = ? then DeltaAbs_R = 0 .
    if DeltaAbs_Tv      = ? then DeltaAbs_Tv = 0 .
    if DeltaAbs_Tr      = ? then DeltaAbs_Tr = 0 .
    if DeltaOtn_N       = ? then DeltaOtn_N = 0 .
    if DeltaOtn_H       = ? then DeltaOtn_H = 0 .
    if DeltaOtn_H_Water = ? then DeltaOtn_H_Water = 0 .
    if DeltaOtn_R       = ? then DeltaOtn_R = 0 .
    if LevelToolType    = ? then LevelToolType = 0 .
    if ToolType         = ? then ToolType = 0 .
    if A_LevelMeasurementTool      = ? then A_LevelMeasurementTool = 0 .
    if ToolAutomationLevel_Tr      = ? then ToolAutomationLevel_Tr =0.
    if ToolAutomationLevel_H       = ? then ToolAutomationLevel_H = 0.
    if ToolAutomationLevel_H_Water = ? then ToolAutomationLevel_H_Water = 0.
    if ToolAutomationLevel_Tv      = ? then ToolAutomationLevel_Tv = 0.
    if ToolAutomationLevel_R       = ? then ToolAutomationLevel_R = 0.
    if DeltaAbs_H_CalcType         = ? then DeltaAbs_H_CalcType = 0.
    if DeltaAbs_H_Water_CalcType   = ? then DeltaAbs_H_Water_CalcType = 0.
    if tt-rvs-line.state-level-water = 0
    then do :
      ToolAutomationLevel_H_Water = 3 .
      DeltaAbs_H_Water_CalcType = 1 .
      DeltaAbs_H_Water = 0 .
      DeltaOtn_H_Water = 0 .
    end .
    if LevelToolType > 0
    then do :
      MM57
        (input tt-rvs-line.state-level-total * 10,
         input LevelToolType,
         output DeltaAbs_H,
         output vErr,
         output vWrn,
         output vDllVersion)
      .
      OUTPUT stream outstream to value ("pomi.log") append.
      PUT STREAM outstream unformatted
                  "    " SKIP
                  "    " SKIP
                  cur-time-string()           FORMAT "x(16)"    SKIP
                  'Процедура             "CMethodOfMetering57"'       SKIP
                  'Версия dll: '            vDllVersion   skip
                  'CODE_PL                = ' tt-rvs-line.pl-code                           SKIP
                  'H                      = ' tt-rvs-line.state-level-total * 10                  SKIP
                  'ToolType               = ' LevelToolType                                      SKIP
                      SKIP SKIP
      .
      output stream outstream close.
      if trim(vErr) > "" then do :
        output stream outstream to value ("pomi.log")  append.
        put stream outstream vErr format "X(1024)" skip.
        output stream outstream close.
        message substitute('Ошибка работы библиотеки ПОкМИ &1', vErr) view-as alert-box .
        undo _trpomi, return "pomi-error" .
      end.
      else do :
        OUTPUT stream outstream to value ("pomi.log")  append.
        PUT STREAM outstream unformatted
            "DeltaAbs_H = " DeltaAbs_H  SKIP
        .
        OUTPUT stream outstream close.
      end .
    end .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input tt-rvs-line.obj-type
  , input tt-rvs-line.obj-code
  ) .
    if not error-status :error then do:
      if ptrlprop-temp-for-pomi = 1 then temp-for-pomi = 15 .
                                    else temp-for-pomi = 20 .
    end.
    assign
      Tr = tt-rvs-line.state-temperature
      Tv = if tt-rvs-line.temp-izm-vol <> ? then tt-rvs-line.temp-izm-vol else tt-rvs-line.state-temperature
      R = ( tt-rvs-line.izmer-density * 1000 )
    .
    for first rvs-line-attr no-lock where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
                                      and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
                                      and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
                                      and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
                                      and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
                                      and rvs-line-attr.attr-code = "Tr"
                                      :
      assign Tr = decimal(rvs-line-attr.attr-value) .
    end .
    for first rvs-line-attr no-lock where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
                                      and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
                                      and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
                                      and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
                                      and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
                                      and rvs-line-attr.attr-code = "Tv"
                                      :
      assign Tv = decimal(rvs-line-attr.attr-value) .
    end .
    for first rvs-line-attr no-lock where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
                                      and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
                                      and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
                                      and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
                                      and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
                                      and rvs-line-attr.attr-code = "R"
                                      :
      assign R = decimal(rvs-line-attr.attr-value) * 1000 .
    end .
    find first buf_place no-lock
         where buf_place.obj-code = tt-rvs-line.obj-code
           and buf_place.obj-type = tt-rvs-line.obj-type
           and buf_place.pl-code  = tt-rvs-line.pl-code no-error.
    if place-type = 1 then do :
      v-proc = "CMethodOfMetering13" .
      MM13
        (input 0.0,
         input 0.0,
         input 0.0,
         input 0.0,
         input tt-rvs-line.state-level-total * 10,
         input (if tt-rvs-line.state-level-water <> ? then tt-rvs-line.state-level-water * 10 else 0.0),
         input CalibTable,
         input CalibBelt,
         input 0.0,
         input 0.0,
         input Tv,
         input Tr,
         input R,
         input temp-for-pomi,
         input ToolType,
         input DeltaOtn_K,
         input DeadZone_Reservoir,
         input A_Reservoir,
         input A_LevelMeasurementTool,
         input ToolAutomationLevel_H,
         input ToolAutomationLevel_H_Water,
         input ToolAutomationLevel_R,
         input ToolAutomationLevel_Tv,
         input ToolAutomationLevel_Tr,
         input DeltaAbs_H_CalcType,
         input DeltaAbs_H_Water_CalcType,
         input DeltaAbs_H,
         input DeltaAbs_H_Water,
         input DeltaAbs_R,
         input DeltaAbs_Tv,
         input DeltaAbs_Tr,
         input DeltaOtn_N,
         input 1,
         input 2,
         input 2,
         output V_total,
         output V_water,
         output DeltaV,
         output V_product,
         output Vcy,
         output Rcy,
         output V,
         output CTL_base_alt,
         output CPL_base_alt,
         output CTPL_base_alt,
         output Fp_base_alt,
         output CTL_obs_base,
         output CPL_obs_base,
         output CTPL_obs_base,
         output Fp_obs_base,
         output Rv,
         output DeltaOtn_Vcy,
         output DeltaOtn_Vm,
         output M,
         output DeltaOtn_M,
         output VolumetricExpansion,
         output vErr,
         output vWrn,
         output vDllVersion)
      no-error .
    end.
    else do :
      v-proc = "CMethodOfMetering6" .
      MM6
        (input tt-rvs-line.state-level-total * 10,
         input (if tt-rvs-line.state-level-water <> ? then tt-rvs-line.state-level-water * 10 else 0.0),
         input CalibTable,
         input CalibBelt,
         input 0.0,
         input Tv,
         input Tr,
         input R,
         input temp-for-pomi,
         input ToolType,
         input DeltaOtn_K,
         input DeadZone_Reservoir,
         input A_Reservoir,
         input A_LevelMeasurementTool,
         input ToolAutomationLevel_H,
         input ToolAutomationLevel_H_Water,
         input ToolAutomationLevel_R,
         input ToolAutomationLevel_Tv,
         input ToolAutomationLevel_Tr,
         input DeltaAbs_H_CalcType,
         input DeltaAbs_H_Water_CalcType,
         input DeltaAbs_H,
         input DeltaAbs_H_Water,
         input DeltaAbs_R,
         input DeltaAbs_Tv,
         input DeltaAbs_Tr,
         input DeltaOtn_N,
         input 1,
         input 2,
         input 2,
         output V_total,
         output V_water,
         output DeltaV,
         output V_product,
         output Vcy,
         output Rcy,
         output V,
         output CTL_base_alt,
         output CPL_base_alt,
         output CTPL_base_alt,
         output Fp_base_alt,
         output CTL_obs_base,
         output CPL_obs_base,
         output CTPL_obs_base,
         output Fp_obs_base,
         output Rv,
         output DeltaOtn_Vcy,
         output DeltaOtn_Vm,
         output M,
         output DeltaOtn_M,
         output VolumetricExpansion,
         output vErr,
         output vWrn,
         output vDllVersion)
      no-error .
    end.
    OUTPUT stream outstream to value ("pomi.log") append.
    PUT STREAM outstream unformatted
      "    " SKIP
      "    " SKIP
      cur-time-string()           FORMAT "x(16)"    SKIP
      'Процедура   "'              v-proc       '"'               FORMAT "x(128)"   SKIP
      'Версия dll: '              vDllVersion                           SKIP
      'CODE_PL                     = ' tt-rvs-line.pl-code                      SKIP
      'H                           = ' tt-rvs-line.state-level-total * 10 SKIP
      'H_water                     = ' (if tt-rvs-line.state-level-water <> ? then tt-rvs-line.state-level-water * 10 else 0.0) SKIP
      'CalibrationTable            = ' CalibTable                    SKIP
      'CalibrationBelt             = ' CalibBelt                    SKIP
      'ToolAutomationLevel_H       = ' ToolAutomationLevel_H     SKIP
      'ToolAutomationLevel_H_Water = ' ToolAutomationLevel_H_Water    SKIP
      'ToolAutomationLevel_R       = ' ToolAutomationLevel_R     SKIP
      'ToolAutomationLevel_Tv      = ' ToolAutomationLevel_Tv    SKIP
      'ToolAutomationLevel_Tr      = ' ToolAutomationLevel_Tr    SKIP
      'DeltaAbs_H_CalcType         = ' DeltaAbs_H_CalcType       SKIP
      'DeltaAbs_H_Water_CalcType   = ' DeltaAbs_H_Water_CalcType SKIP
      'Tv                          = ' round(Tv, 2)              SKIP
      'Tr                          = ' round(Tr, 2)              SKIP
      'R                           = ' round(R, 2)               SKIP
      'Tcy                         = ' temp-for-pomi                       SKIP
      'ToolType                    = ' ToolType                            SKIP
      'DeadZone_Reservoir          = ' DeadZone_Reservoir                  SKIP
      'DeltaOtn_K                  = ' DeltaOtn_K                          SKIP
      'A_Reservoir                 = ' A_Reservoir                         SKIP
      'A_LevelMeasurementTool      = ' A_LevelMeasurementTool              skip
      'DeltaAbs_H                  = ' DeltaAbs_H                          SKIP
      'DeltaAbs_H_Water            = ' DeltaAbs_H_Water                    SKIP
      'DeltaAbs_R                  = ' DeltaAbs_R                          SKIP
      'DeltaAbs_Tv                 = ' DeltaAbs_Tv                         SKIP
      'DeltaAbs_Tr                 = ' DeltaAbs_Tr                         SKIP
      'DeltaOtn_N                  = ' DeltaOtn_N                          SKIP
      'Round_M                     = ' 1                                   SKIP
      'Round_T                     = ' 2                                   SKIP
      'Round_R                     = ' 2                                   SKIP
    .
    if place-type = 1
    and place-ponton
    then do :
      put stream outstream unformatted
        "Rprov                  = " 0.0 skip
        "Mpokr                  = " 0.0 skip
        "Vdisp                  = " 0.0 skip
        "CoverFloatingHeight    = " 0.0 skip
      .
    end.
    output stream outstream close.
    if trim(vErr) > "" then do :
      error-string = substitute("~nРезервуар: &1.~n", if avail buf_place then buf_place.loc1 else "")
                   + replace(vErr,";0x","~n0x") .
      output stream outstream to value ("pomi.log")  append.
      put stream outstream error-string format "X(1024)" skip.
      message
      substitute('Ошибка работы библиотеки ПОкМИ. &1',error-string)
      view-as alert-box error.
      output stream outstream close.
      undo _trpomi, return "pomi-error" .
    end.
    else do :
      v-mm-density = Rv / 1000 .
      varstate-water-qnty = V_water * 1000 .
      assign
        tt-rvs-line.state-measure-qnty     = V * 1000
        tt-rvs-line.state-measure-cli-qnty = M
        tt-rvs-line.state-brutto-qnty      = tt-rvs-line.state-measure-qnty + varstate-water-qnty
        tt-rvs-line.state-density          = v-mm-density
        tt-rvs-line.pomi-density           = (Rcy / 1000)
      .
      assign
        tt-rvs-line.fact-calc-add-mass = tt-rvs-line.state-add-qnty * tt-rvs-line.state-density
        tt-rvs-line.fact-calc-vol = tt-rvs-line.state-measure-qnty
        tt-rvs-line.fact-sum-vol = tt-rvs-line.fact-calc-vol + tt-rvs-line.state-add-qnty
        tt-rvs-line.fact-sum-mass = tt-rvs-line.fact-calc-add-mass + tt-rvs-line.state-measure-cli-qnty
        varstate-sum-vol = varstate-water-qnty + tt-rvs-line.fact-calc-vol
      .
      tt-rvs-line.state-brutto-cli-qnty  = tt-rvs-line.state-brutto-qnty * tt-rvs-line.state-density .
      if  tt-rvs-line.state-measure-cli-qnty > 200000 then delta-mass-qnty = 0.5 . else delta-mass-qnty = 0.65.
      abs-delta-mass-qnty = tt-rvs-line.state-measure-cli-qnty * delta-mass-qnty / 100 .
      display
          delta-mass-qnty
          tt-rvs-line.state-density
          tt-rvs-line.fact-calc-vol
          abs-delta-mass-qnty
          varstate-sum-vol
          varstate-water-qnty
      with frame Dialog-Frame .
      find first rvs-line-attr exclusive-lock
            where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
              and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
              and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
              and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
              and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
              and rvs-line-attr.attr-code = "pokmi-water-qnty" no-error.
      if available rvs-line-attr then do :
        rvs-line-attr.attr-value = string(V_water * 1000) .
      end.
      else do :
        create rvs-line-attr.
          assign
              rvs-line-attr.obj-code   = tt-rvs-line.obj-code
              rvs-line-attr.obj-type   = tt-rvs-line.obj-type
              rvs-line-attr.gds-code   = tt-rvs-line.gds-code
              rvs-line-attr.pl-code    = tt-rvs-line.pl-code
              rvs-line-attr.rvs-code   = tt-rvs-line.rvs-code
              rvs-line-attr.attr-code  = "pokmi-water-qnty"
              rvs-line-attr.attr-value = string(V_water * 1000)
          .
      END.
      assign
        v-POkMI-result =
          "V_total             = " + string(V_total)       + chr(10) +
          "V_water             = " + string(V_water)       + chr(10) +
          "DeltaV              = " + string(DeltaV)         + chr(10) +
          "Vcy                 = " + string(Vcy)           + chr(10) +
          "Rcy                 = " + string(Rcy)            + chr(10) +
          "V_product           = " + string(V_product)      + chr(10) +
          "V                   = " + string(V)              + chr(10) +
          "Rv                  = " + string(Rv)               + chr(10) +
          "M                   = " + string(M)                 + chr(10) +
          "CTL_base_alt        = " + string(CTL_base_alt)  + chr(10) +
          "CPL_base_alt        = " + string(CPL_base_alt)  + chr(10) +
          "CTPL_base_alt       = " + string(CTPL_base_alt)  + chr(10) +
          "Fp_base_alt         = " + string(Fp_base_alt)   + chr(10) +
          "CTL_obs_base        = " + string(CTL_obs_base)  + chr(10) +
          "CPL_obs_base        = " + string(CPL_obs_base)  + chr(10) +
          "CTPL_obs_base       = " + string(CTPL_obs_base)  + chr(10) +
          "Fp_obs_base         = " + string(Fp_obs_base)   + chr(10) +
          "DeltaOtn_Vcy        = " + string(DeltaOtn_Vcy)  + chr(10) +
          "DeltaOtn_Vm         = " + string(DeltaOtn_Vm)   + chr(10) +
          "DeltaOtn_M          = " + string(DeltaOtn_M)       + chr(10) +
          "VolumetricExpansion = " + string(VolumetricExpansion) + chr(10) +
          "Warnings            = " + vWrn
      .
      OUTPUT stream outstream to value ("pomi.log")  append.
      PUT STREAM outstream unformatted v-POkMI-result skip .
      OUTPUT stream outstream close.
      assign
        v-POkMI-result-attr =
          "Масса НП, кг: " + string(M, "->>,>>>,>>9.9":U) + chr(10) +
          "Относительная погрешность измерения массы нефтепродукта, %: "  + string(DeltaOtn_M, "->>,>>9.99":U) + chr(10) +
          "Плотность, приведенная к стандартным условиям, г/см3: " + string((Rcy / 1000), "9.9999":U) + chr(10) +
          "Объем, приведенный к стандартным условиям, л: " + string((Vcy * 1000), "->>,>>>,>>9":U) + chr(10) +
          "Объем НП при температуре его измерения, л: " + string((V * 1000), "->>,>>>,>>9":U) + chr(10) +
          "Объем воды, л: " + string((V_water * 1000), "->>,>>>,>>9":U)
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
end procedure .
ON CHOOSE OF b-temperature IN FRAME Dialog-Frame
DO:
  define buffer temp_sr-izmerenia for sr-izmerenia .
  define buffer dens_sr-izmerenia for sr-izmerenia .
  define variable vOk as logical no-undo .
  define variable v-out-temp as decimal no-undo .
  define variable v-calc-type as integer no-undo init 1 .
  define variable v-izm-temps as character no-undo .
  define variable v-izm-temps-tab as character no-undo .
  if pl-rvd-temp
  or v-revision-mode
  then do :
    find first temp_sr-izmerenia no-lock where temp_sr-izmerenia.node-code = v-mi-tmp no-error.
  end .
  else do :
    find first temp_sr-izmerenia no-lock where temp_sr-izmerenia.node-code = place-si no-error.
  end .
  if not available temp_sr-izmerenia
  then do :
    message "Для резервуара не задано основное средство измерения или средство измерения температуры!" view-as alert-box .
    return no-apply .
  end .
  if not temp_sr-izmerenia.sr-temperature
  then do :
    message "Средство измерения " string(temp_sr-izmerenia.node-code) " не может измерять температуру!" view-as alert-box .
    return no-apply .
  end .
  if temp_sr-izmerenia.sr-type-izm = 2
  then do :
    message "Средство измерения температуры " string(temp_sr-izmerenia.node-code) " является измерительной системой! Значение температуры определяется показателями СИ." view-as alert-box .
    return no-apply .
  end .
  for first rvs-line-attr no-lock where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
                                    and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
                                    and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
                                    and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
                                    and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
                                    and rvs-line-attr.attr-code = "temp-calc-type"
                                    :
    v-calc-type = integer(rvs-line-attr.attr-value) .
  end .
  run str/rvs-lin-temperature.w (input temp_sr-izmerenia.sr-type-izm,
                                 input place-type,
                                 input place-diameter,
                                 input (if place-type = 1 then ((tt-rvs-line.state-level-total - tt-rvs-line.state-level-water) * 10) else (tt-rvs-line.state-level-total * 10)),
                                 input-output v-calc-type,
                                 output v-out-temp,
                                 output vOk)
                                 .
  if vOk
  then do :
    if tt-rvs-line.temp-izm-vol <> v-out-temp
    then do :
      assign tt-rvs-line.test-asi-diff = ? .
    end .
    tt-rvs-line.temp-izm-vol = v-out-temp .
    display tt-rvs-line.temp-izm-vol with frame Dialog-Frame .
    assign v-hand-input-tmp = true .
    find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
           and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
           and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
           and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
           and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
           and rvs-line-attr.attr-code = "temp-calc-type" no-error.
    if not available rvs-line-attr then do :
      create rvs-line-attr.
      assign
        rvs-line-attr.obj-code  = tt-rvs-line.obj-code
        rvs-line-attr.obj-type  = tt-rvs-line.obj-type
        rvs-line-attr.gds-code  = tt-rvs-line.gds-code
        rvs-line-attr.pl-code   = tt-rvs-line.pl-code
        rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
        rvs-line-attr.attr-code = "temp-calc-type"
        rvs-line-attr.attr-value = string(v-calc-type)
      .
    end.
    else do :
      rvs-line-attr.attr-value = string(v-calc-type) .
    end.
    if pl-rvd-temp
    and not pl-rvd-dens
    then do :
      tt-rvs-line.state-temperature = v-out-temp .
      display tt-rvs-line.state-temperature with frame Dialog-Frame .
    end .
    if (pl-rvd-temp
    and pl-rvd-dens)
    or v-revision-mode
    then do :
      find first rvs-line-attr no-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "state-temp-changed" no-error.
      if available rvs-line-attr
      and logical(rvs-line-attr.attr-value)
      then do : end .
      else do :
        tt-rvs-line.state-temperature = v-out-temp .
        display tt-rvs-line.state-temperature with frame Dialog-Frame .
      end .
    end .
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
    v-izm-temps-tab = string(temp_sr-izmerenia.sr-type-izm) + ";" .
    if temp_sr-izmerenia.sr-type-izm = 0
    then do :
      for each tt-temps-tab no-lock by tt-temps-tab.ii descending :
        v-izm-temps-tab = v-izm-temps-tab + string(tt-temps-tab.temperature) + "," .
      end .
    end .
    else do :
      for each tt-temps-tab no-lock by tt-temps-tab.ii :
        v-izm-temps-tab = v-izm-temps-tab + string(tt-temps-tab.temperature) + "," .
      end .
    end .
    v-izm-temps-tab = trim(v-izm-temps-tab, ",") .
    find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
           and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
           and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
           and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
           and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
           and rvs-line-attr.attr-code = "izm-temps-tab" no-error.
    if not available rvs-line-attr then do :
      create rvs-line-attr.
      assign
        rvs-line-attr.obj-code  = tt-rvs-line.obj-code
        rvs-line-attr.obj-type  = tt-rvs-line.obj-type
        rvs-line-attr.gds-code  = tt-rvs-line.gds-code
        rvs-line-attr.pl-code   = tt-rvs-line.pl-code
        rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
        rvs-line-attr.attr-code = "izm-temps-tab"
        rvs-line-attr.attr-value = v-izm-temps-tab
      .
    end.
    else do :
      rvs-line-attr.attr-value = v-izm-temps-tab .
    end.
    if pl-rvd-dens
    or v-revision-mode
    then do :
      find first dens_sr-izmerenia no-lock where dens_sr-izmerenia.node-code = v-mi-dnst no-error.
    end .
    else do :
      find first dens_sr-izmerenia no-lock where dens_sr-izmerenia.node-code = place-si no-error.
    end .
    if available dens_sr-izmerenia
    and dens_sr-izmerenia.sr-type-izm = 0
    then do :
      v-izm-temps = string(dens_sr-izmerenia.sr-type-izm) + ";" .
      for each tt-temps no-lock by tt-temps.ii descending :
        v-izm-temps = v-izm-temps + string(tt-temps.temperature) + "," .
      end .
      v-izm-temps = trim(v-izm-temps, ",") .
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "izm-temps" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "izm-temps"
          rvs-line-attr.attr-value = v-izm-temps
        .
      end.
      else do :
        rvs-line-attr.attr-value = v-izm-temps .
      end.
    end .
  end .
END.
ON CHOOSE OF b-density IN FRAME Dialog-Frame
DO:
  define buffer dens_sr-izmerenia for sr-izmerenia .
  define variable vOk as logical no-undo .
  define variable v-out-dens as decimal no-undo .
  define variable v-out-temp as decimal no-undo .
  define variable v-izm-temps as character no-undo .
  define variable v-izm-denses as character no-undo .
  define variable v-calc-type as integer no-undo init 1 .
  if pl-rvd-dens
  or v-revision-mode
  then do :
    find first dens_sr-izmerenia no-lock where dens_sr-izmerenia.node-code = v-mi-dnst no-error.
  end .
  else do :
    find first dens_sr-izmerenia no-lock where dens_sr-izmerenia.node-code = place-si no-error.
  end .
  if not available dens_sr-izmerenia
  then do :
    message "Для резервуара не задано основное средство измерения или средство измерения плотности!" view-as alert-box .
    return no-apply .
  end .
  if not dens_sr-izmerenia.sr-density
  then do :
    message "Средство измерения " string(dens_sr-izmerenia.node-code) " не может измерять плотность!" view-as alert-box .
    return no-apply .
  end .
  if dens_sr-izmerenia.sr-type-izm = 2
  then do :
    message "Средство измерения плотности " string(dens_sr-izmerenia.node-code) " является измерительной системой! Значение плотности определяется показателями СИ." view-as alert-box .
    return no-apply .
  end .
  if dens_sr-izmerenia.sr-type-izm = 0
  then do :
    for first rvs-line-attr no-lock where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
                                      and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
                                      and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
                                      and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
                                      and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
                                      and rvs-line-attr.attr-code = "dens-calc-type"
                                      :
      v-calc-type = integer(rvs-line-attr.attr-value) .
    end .
    run str/rvs-lin-density.w (input dens_sr-izmerenia.sr-type-izm,
                               input place-type,
                               input place-diameter,
                               input (if place-type = 1 then ((tt-rvs-line.state-level-total - tt-rvs-line.state-level-water) * 10) else (tt-rvs-line.state-level-total * 10)),
                               input-output v-calc-type,
                               output v-out-dens,
                               output vOk)
                               .
    if vOk
    then do :
      if tt-rvs-line.izmer-density <> v-out-dens
      then do :
        assign tt-rvs-line.test-asi-diff = ? .
      end .
      assign
        tt-rvs-line.izmer-density = v-out-dens
        tt-rvs-line.state-density = tt-rvs-line.izmer-density
      .
      display tt-rvs-line.izmer-density tt-rvs-line.state-density with frame Dialog-Frame .
      assign v-hand-input-dnst = true .
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "dens-calc-type" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "dens-calc-type"
          rvs-line-attr.attr-value = string(v-calc-type)
        .
      end.
      else do :
        rvs-line-attr.attr-value = string(v-calc-type) .
      end.
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
      v-izm-denses = string(dens_sr-izmerenia.sr-type-izm) + ";" .
      for each tt-dens no-lock by tt-dens.ii descending :
        v-izm-denses = v-izm-denses + string(tt-dens.density) + "," .
      end .
      v-izm-denses = trim(v-izm-denses, ",") .
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "izm-denses" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "izm-denses"
          rvs-line-attr.attr-value = v-izm-denses
        .
      end.
      else do :
        rvs-line-attr.attr-value = v-izm-denses .
      end.
    end .
  end .
  if dens_sr-izmerenia.sr-type-izm = 1
  then do :
    v-mi-tmp-dnst = v-mi-tmp .
    for first rvs-line-attr no-lock where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
                                      and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
                                      and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
                                      and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
                                      and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
                                      and rvs-line-attr.attr-code = "mi-tmp-dnst"
                                      :
      v-mi-tmp-dnst = integer(rvs-line-attr.attr-value) .
    end .
    if v-mi-tmp-dnst = ? then v-mi-tmp-dnst = 0 .
    run str/rvs-lin-dens-temp.w (input parparentproc,
                                 input dens_sr-izmerenia.sr-type-izm,
                                 input place-type,
                                 input place-diameter,
                                 input tt-rvs-line.state-level-total * 10,
                                 input-output v-mi-tmp-dnst,
                                 output v-out-dens,
                                 output v-out-temp,
                                 output vOk)
                                 .
    if vOk
    then do :
      if tt-rvs-line.izmer-density <> v-out-dens
      then do :
        assign tt-rvs-line.test-asi-diff = ? .
      end .
      assign
        tt-rvs-line.izmer-density = v-out-dens
        tt-rvs-line.state-density = tt-rvs-line.izmer-density
      .
      display tt-rvs-line.izmer-density tt-rvs-line.state-density with frame Dialog-Frame .
      assign v-hand-input-dnst = true .
      assign v-hand-input-tmp = true .
      tt-rvs-line.state-temperature = v-out-temp .
      display tt-rvs-line.state-temperature with frame Dialog-Frame .
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "mi-tmp-dnst" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "mi-tmp-dnst"
          rvs-line-attr.attr-value = string(v-mi-tmp-dnst)
        .
      end.
      else do :
        rvs-line-attr.attr-value = string(v-mi-tmp-dnst) .
      end.
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
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "state-temp-changed" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "state-temp-changed"
          rvs-line-attr.attr-value = string(yes)
        .
      end.
      else do :
        rvs-line-attr.attr-value = string(yes) .
      end.
      v-izm-temps = string(dens_sr-izmerenia.sr-type-izm) + ";" .
      v-izm-denses = string(dens_sr-izmerenia.sr-type-izm) + ";" .
      for each tt-dens-temp no-lock by tt-dens-temp.ii :
        v-izm-temps = v-izm-temps + string(tt-dens-temp.temperature) + "," .
        v-izm-denses = v-izm-denses + string(tt-dens-temp.density) + "," .
      end .
      v-izm-temps = trim(v-izm-temps, ",") .
      v-izm-denses = trim(v-izm-denses, ",") .
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "izm-temps" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "izm-temps"
          rvs-line-attr.attr-value = v-izm-temps
        .
      end.
      else do :
        rvs-line-attr.attr-value = v-izm-temps .
      end.
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "izm-denses" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "izm-denses"
          rvs-line-attr.attr-value = v-izm-denses
        .
      end.
      else do :
        rvs-line-attr.attr-value = v-izm-denses .
      end.
    end .
  end .
END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
  define variable v-water     as decimal   no-undo .
  define variable v-water-cli as decimal   no-undo .
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define buffer buf_doc-pl for ub.doc-pl .
  define buffer buf_place for ub.place .
  define buffer buf_doc-pl-attr for doc-pl-attr .
  define buffer buf_sr-izmerenia for sr-izmerenia .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  buf_rvs-doc.obj-type
  ,input  buf_rvs-doc.obj-code
  ,output v-shift-date
  ,output v-shift-num
  ,output v-shift-name
  ) no-error .
  if tt-rvs-line.test-asi-diff = ?
  then do :
    message "Сохранение введенных параметров НП невозможно." skip (1)
            "Не выполнен расчет проверки корректности работы канала плотности НП АСИ резервуара." skip
            'Нажмите кнопку "Расчёт проверки" и повторите попытку.'
    view-as alert-box information.
    apply "entry" to b-calc-diff in frame Dialog-Frame.
    return no-apply.
  end .
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
  run volume-water in this-procedure               no-error.
  if error-status :error then do: return no-apply. end.
  run chg-density  in this-procedure               no-error.
  if error-status :error then do: return no-apply. end.
  assign frame Dialog-Frame tt-rvs-line.state-measure-tc-qnty tt-rvs-line.state-brutto-tc-qnty tt-rvs-line.state-temperature.
  assign tt-rvs-line.state-level-petrol = tt-rvs-line.state-level-total - tt-rvs-line.state-level-water .
  buffer-copy tt-rvs-line to buf_rvs-line.
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
         and rvs-line-attr.attr-code = "temp-izm-vol" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "temp-izm-vol"
      rvs-line-attr.attr-value = string(tt-rvs-line.temp-izm-vol)
    .
  end.
  else do :
    rvs-line-attr.attr-value = string(tt-rvs-line.temp-izm-vol) .
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
         and rvs-line-attr.attr-code = "pomi-density" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "pomi-density"
      rvs-line-attr.attr-value = string(tt-rvs-line.pomi-density)
    .
  end.
  else do :
    rvs-line-attr.attr-value = string(tt-rvs-line.pomi-density) .
  end.
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
         and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
         and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
         and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
         and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
         and rvs-line-attr.attr-code = "test-asi-diff" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = tt-rvs-line.obj-code
      rvs-line-attr.obj-type  = tt-rvs-line.obj-type
      rvs-line-attr.gds-code  = tt-rvs-line.gds-code
      rvs-line-attr.pl-code   = tt-rvs-line.pl-code
      rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
      rvs-line-attr.attr-code = "test-asi-diff"
      rvs-line-attr.attr-value = string(tt-rvs-line.test-asi-diff)
    .
  end.
  else do :
    rvs-line-attr.attr-value = string(tt-rvs-line.test-asi-diff) .
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
    for first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = place-si :
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "main-mi-name" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          rvs-line-attr.attr-code = "main-mi-name"
          rvs-line-attr.attr-value = buf_sr-izmerenia.sr-model
        .
      end.
      else do :
        rvs-line-attr.attr-value = buf_sr-izmerenia.sr-model .
      end.
    end .
  end .
release rvs-line-attr no-error .
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
ON LEAVE OF tt-rvs-line.state-density IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-rvs-line.state-density <> tt-rvs-line.state-density then do:
     assign frame Dialog-Frame tt-rvs-line.state-density.
     run chg-density no-error.
     if error-status:error then return no-apply.
     if tarir-value = 'yes'
     then do :
       run local-tarir("state-level-total") .
     end.
     assign v-hand-input-dnst = true .
  end.
END.
ON LEAVE OF tt-rvs-line.izmer-density IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-rvs-line.izmer-density <> tt-rvs-line.izmer-density then do:
    if input frame Dialog-Frame tt-rvs-line.izmer-density = ?
      or ( buf_goods.unit-base <> buf_goods.unit-cli
          and ( input frame Dialog-Frame tt-rvs-line.izmer-density < 0
                or input frame Dialog-Frame tt-rvs-line.izmer-density >= 1
              )
        )
      or ( buf_goods.unit-base = buf_goods.unit-cli
          and input frame Dialog-Frame tt-rvs-line.izmer-density <> 1
        )
    then do:
      message "Неверно определена плотность топлива измер. для ПОкМИ." view-as alert-box error.
      apply "entry" to tt-rvs-line.izmer-density .
      return no-apply.
    end.
    assign frame Dialog-Frame tt-rvs-line.izmer-density.
    assign tt-rvs-line.test-asi-diff = ? .
    assign v-hand-input-dnst = true .
  end.
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
    assign tt-rvs-line.test-asi-diff = ? .
    run level-water in this-procedure ( input no )  .
    RUN local-tarir ("state-level-total").
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
    if v-mi-tmp > 0
    then
      enable b-temperature with frame Dialog-Frame.
    if v-mi-dnst > 0
    then
      enable b-density with frame Dialog-Frame.
  end .
  else do :
    disable b-temperature with frame Dialog-Frame .
    disable b-density with frame Dialog-Frame .
  end .
  if input frame Dialog-Frame tt-rvs-line.state-level-total <> tt-rvs-line.state-level-total then do:
    assign v-hand-input-lvl = true .
    empty temp-table tt-temps .
    empty temp-table tt-dens .
    empty temp-table tt-dens-temp .
    find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "izm-temps" no-error.
    if available rvs-line-attr
    then do :
      rvs-line-attr.attr-value = "0;" .
    end .
    find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "izm-denses" no-error.
    if available rvs-line-attr
    then do :
      rvs-line-attr.attr-value = "0;" .
    end .
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
    assign tt-rvs-line.test-asi-diff = ? .
    run level-water in this-procedure ( input no )  .
    RUN local-tarir ("state-level-total").
  end.
END.
ON return OF tt-rvs-line.state-level-total IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON leave OF tt-rvs-line.state-measure-cli-qnty IN FRAME Dialog-Frame
DO:
  assign frame Dialog-Frame tt-rvs-line.state-measure-cli-qnty .
  if not tt-rvs-line.fact-calc-vol:sensitive
  and rdc-value <> 'pomi-rn'
  then do :
    assign
      tt-rvs-line.state-measure-qnty = tt-rvs-line.state-measure-cli-qnty / tt-rvs-line.state-density
      tt-rvs-line.fact-calc-vol = tt-rvs-line.state-measure-qnty
      varstate-sum-vol = (if varstate-water-qnty <> ? then varstate-water-qnty else 0) + tt-rvs-line.fact-calc-vol
      tt-rvs-line.fact-sum-mass = tt-rvs-line.fact-calc-add-mass + tt-rvs-line.state-measure-cli-qnty
      tt-rvs-line.state-brutto-qnty     = tt-rvs-line.state-measure-qnty + (if varstate-water-qnty <> ? then varstate-water-qnty else 0)
      tt-rvs-line.state-brutto-cli-qnty = tt-rvs-line.state-measure-cli-qnty + (if varstate-water-qnty <> ? then varstate-water-qnty else 0)
    .
    display tt-rvs-line.state-measure-cli-qnty tt-rvs-line.fact-calc-vol varstate-sum-vol with frame Dialog-Frame.
  end .
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
ON LEAVE OF tt-rvs-line.state-temperature IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-rvs-line.state-temperature <> tt-rvs-line.state-temperature then do:
    assign tt-rvs-line.test-asi-diff = ? .
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
             "Не найдена строка проверки корректности работы АСИ в резервуаре с recid " parrec-rvs-line " ."
     view-as alert-box error.
     return error.
  end.
  find first buf_rvs-doc exclusive-lock
    where buf_rvs-doc.rvs-code = buf_rvs-line.rvs-code
    .
  find first buf_doc-attr no-lock where buf_doc-attr.doc-code = buf_rvs-doc.rvs-code
                                    and buf_doc-attr.attr-code = "test-asi-type"
                                    no-error .
  if not available buf_doc-attr
  then do :
    message "Неверно переданы параметры."
             "Не известен тип проверки корректности работы АСИ в резервуаре с recid " parrec-rvs-line " ."
     view-as alert-box error.
     return error.
  end .
  v-test-asi-type = buf_doc-attr.attr-value .
  case v-test-asi-type :
    when "test-asi_dens-place"
    then do :
      if buf_rvs-line.density = ?
      or buf_rvs-line.density <= 0
      then do :
        message "Сначала проведите измерение плотности с помощью АСИ!"
        view-as alert-box .
        return .
      end .
    end .
    when "test-asi_dens-pump"
    then do :
      if buf_rvs-line.density = ?
      or buf_rvs-line.density <= 0
      then do :
        message "Сначала проведите измерение плотности с помощью АСИ!"
        view-as alert-box .
        return .
      end .
    end .
    when "test-asi_mass"
    then do :
      if buf_rvs-line.measure-cli-qnty = ?
      or buf_rvs-line.measure-cli-qnty <= 0
      then do :
        message "Сначала проведите измерение массы с помощью АСИ!"
        view-as alert-box .
        return .
      end .
    end .
  end case .
  create tt-rvs-line.
  buffer-copy buf_rvs-line to tt-rvs-line.
  RUN enable_UI IN THIS-PROCEDURE.
  hide
    tt-rvs-line.orig-system-qnty
    tt-rvs-line.orig-system-cli-qnty
    tt-rvs-line.system-qnty
    tt-rvs-line.system-cli-qnty
    tt-rvs-line.meas-mh-qnty
    tt-rvs-line.state-mh-qnty
    tt-rvs-line.state-am-qnty
    tt-rvs-line.meas-cf-qnty
    tt-rvs-line.state-cf-qnty
    tt-rvs-line.state-add-qnty
    CriticalDif
    abs-delta-mass-add-qnty
  in frame Dialog-Frame.
  run placelib_get-attr  ( input "place-type"
                            ,input tt-rvs-line.obj-code
                            ,input tt-rvs-line.obj-type
                            ,input tt-rvs-line.pl-code
                            ,output v-value
                            ,output v-ok      ) no-error.
  if v-ok then place-type = integer(v-value) .
  if parmode <> 'ИЗМЕНЕНИЕ':U then do:
     disable tt-rvs-line.state-measure-qnty tt-rvs-line.state-measure-tc-qnty tt-rvs-line.state-density tt-rvs-line.state-brutto-qnty tt-rvs-line.state-brutto-tc-qnty tt-rvs-line.state-measure-cli-qnty tt-rvs-line.state-brutto-cli-qnty tt-rvs-line.state-level-petrol tt-rvs-line.state-level-total tt-rvs-line.state-level-water tt-rvs-line.state-temperature tt-rvs-line.temp-izm-vol tt-rvs-line.state-mh-qnty tt-rvs-line.state-am-qnty tt-rvs-line.state-cf-qnty tt-rvs-line.izmer-density with frame Dialog-Frame.
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
  RUN gbl/conf-rd.p ("rdc-dnst", "", "", 0, "", "", "", NO, OUTPUT rdc-value, OUTPUT rdc-type) NO-ERROR.
  run gbl/conf-rd.p ("tarir", "", "", 0, "", "", "", no, output tarir-value, output tarir-type) no-error.
  run volume-measure-water in this-procedure                 no-error.
  run level-measure-water  in this-procedure                 no-error.
  run volume-water         in this-procedure                 no-error.
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
  hide
      tt-rvs-line.meas-calc-qnty
      tt-rvs-line.meas-calc-dens
      tt-rvs-line.meas-cli-calc-qnty
      tt-rvs-line.meas-am-qnty
      tt-rvs-line.meas-cf-qnty
      tt-rvs-line.meas-mh-qnty
      tt-rvs-line.level-petrol
      tt-rvs-line.state-level-petrol
      tt-rvs-line.brutto-cli-qnty
      tt-rvs-line.state-brutto-cli-qnty
      tt-rvs-line.meas-cli-calc-qnty
      varmeasure-water-cli-qnty
      varstate-water-cli-qnty
      tt-rvs-line.brutto-tc-qnty
      tt-rvs-line.state-brutto-tc-qnty
      tt-rvs-line.brutto-qnty
      tt-rvs-line.state-brutto-qnty
      tt-rvs-line.meas-calc-dens
      tt-rvs-line.measure-tc-qnty
      tt-rvs-line.state-measure-tc-qnty
      tt-rvs-line.measure-qnty
      tt-rvs-line.state-measure-qnty
      tt-rvs-line.meas-calc-qnty
      tt-rvs-line.add-qnty
      tt-rvs-line.calc-add-mass
      tt-rvs-line.fact-calc-add-mass
      tt-rvs-line.sum-mass
      tt-rvs-line.sum-vol
      tt-rvs-line.fact-sum-mass
      tt-rvs-line.fact-sum-vol
      tt-rvs-line.asi-pomi-density
      in frame Dialog-Frame.
  if rdc-value <>  "pomi-rn" then do :
    hide
      tt-rvs-line.izmer-density
      delta-mass-qnty
      abs-delta-mass-qnty
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
      tt-rvs-line.state-brutto-qnty
      tt-rvs-line.state-brutto-cli-qnty
    with frame Dialog-Frame.
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
          when "temp-izm-vol" then do :
            tt-rvs-line.temp-izm-vol = decimal(rvs-line-attr.attr-value) .
          end.
          when "delta-mass-qnty" then do :
            delta-mass-qnty = decimal(rvs-line-attr.attr-value) .
          end.
          when "CriticalDif" then do :
            CriticalDif = decimal(rvs-line-attr.attr-value) .
          end.
          when "test-asi-diff" then do :
            tt-rvs-line.test-asi-diff = decimal(rvs-line-attr.attr-value) .
          end.
          when "pomi-density" then do :
            tt-rvs-line.pomi-density = decimal(rvs-line-attr.attr-value) .
          end.
          when "asi-pomi-density" then do :
            tt-rvs-line.asi-pomi-density = decimal(rvs-line-attr.attr-value) .
          end.
        end case.
  end.
  release rvs-line-attr no-error .
  if rdc-value =  "pomi-rn" then do :
    display
      tt-rvs-line.izmer-density
      delta-mass-qnty
    with frame Dialog-Frame.
  end.
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
    for first rvs-line-attr no-lock where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
                                      and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
                                      and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
                                      and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
                                      and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
                                      and rvs-line-attr.attr-code = "mi-tmp-dnst"
                                      :
      v-mi-tmp-dnst = integer(rvs-line-attr.attr-value) .
    end .
  end .
  assign tt-rvs-line.calc-vol = tt-rvs-line.measure-qnty .
  assign varsum-vol = tt-rvs-line.brutto-qnty .
  assign
    tt-rvs-line.fact-calc-vol = tt-rvs-line.state-measure-qnty
    varstate-sum-vol = tt-rvs-line.state-brutto-qnty
  .
  if tt-rvs-line.state-measure-qnty = ? then tt-rvs-line.state-measure-qnty = tt-rvs-line.fact-calc-vol .
  abs-delta-mass-qnty = tt-rvs-line.state-measure-cli-qnty * delta-mass-qnty / 100 .
  display
    tt-rvs-line.calc-vol
    varsum-vol
    tt-rvs-line.fact-calc-vol
    varstate-sum-vol
    tt-rvs-line.temp-izm-vol
    tt-rvs-line.test-asi-diff
  with frame Dialog-Frame.
  if rdc-value = 'pomi-rn'
  then do :
    display
      abs-delta-mass-qnty
    with frame Dialog-Frame.
  end.
  else
  if tt-rvs-line.density = ? and parmode = 'ИЗМЕНЕНИЕ':U and tarir-value <> "yes"
  then do :
    enable
      tt-rvs-line.fact-calc-vol
      varstate-water-qnty
    with frame Dialog-Frame.
  end.
  if parmode <> 'ИЗМЕНЕНИЕ':U then do:
    disable tt-rvs-line.izmer-density with frame Dialog-Frame.
    disable tt-rvs-line.temp-izm-vol with frame Dialog-Frame.
    disable b-temperature b-density b-calc-diff with frame Dialog-Frame.
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
    if v-test-asi-type = "test-asi_dens-pump"
    then do :
      display tt-rvs-line.asi-pomi-density with frame Dialog-Frame.
    end .
    if v-test-asi-type = "test-asi_mass"
    then do :
      if tt-rvs-line.test-asi-diff > 0.65
      then tt-rvs-line.test-asi-diff:fgcolor = RED_COLOR .
      else tt-rvs-line.test-asi-diff:fgcolor = 0 .
    end .
    else do :
      if tt-rvs-line.test-asi-diff > 1.7
      then tt-rvs-line.test-asi-diff:fgcolor = RED_COLOR .
      else tt-rvs-line.test-asi-diff:fgcolor = 0 .
    end .
  end.
  else do :
    disable
      tt-rvs-line.izmer-density
      tt-rvs-line.state-temperature
      tt-rvs-line.state-density
      v-mi-lvl b-mi-lvl v-mi-lvl-name
      v-mi-dnst b-mi-dnst v-mi-dnst-name
      v-mi-tmp b-mi-tmp v-mi-tmp-name
    with frame Dialog-Frame.
    enable b-calc-diff with frame Dialog-Frame.
    case v-test-asi-type :
      when "test-asi_dens-place"
      then do :
        assign pl-rvd-dens = yes .
        if tt-rvs-line.state-level-total = ?
        or tt-rvs-line.state-level-total <= 0
        then do :
          assign
            tt-rvs-line.state-level-total = tt-rvs-line.level-total
            tt-rvs-line.state-level-water = tt-rvs-line.level-water
            tt-rvs-line.state-temperature = tt-rvs-line.temperature
          .
          if tt-rvs-line.temp-izm-vol = ? then tt-rvs-line.temp-izm-vol = tt-rvs-line.state-temperature .
          display
            tt-rvs-line.state-level-total
            tt-rvs-line.state-level-water
            tt-rvs-line.state-temperature
            tt-rvs-line.temp-izm-vol
          with frame Dialog-Frame.
        end .
        vLabel = tt-rvs-line.izmer-density:SIDE-LABEL-HANDLE.
        vLabel:fgcolor = RED_COLOR .
        if tt-rvs-line.test-asi-diff > 1.7
        then tt-rvs-line.test-asi-diff:fgcolor = RED_COLOR .
        else tt-rvs-line.test-asi-diff:fgcolor = 0 .
        disable
          tt-rvs-line.state-level-total
          tt-rvs-line.state-level-water
          b-temperature
        with frame Dialog-Frame.
        if v-mi-dnst > 0
        and tt-rvs-line.state-level-total > 0
        then
          enable b-density with frame Dialog-Frame.
        enable
          v-mi-dnst b-mi-dnst v-mi-dnst-name
        with frame Dialog-Frame.
      end .
      when "test-asi_dens-pump"
      then do :
        assign
          pl-rvd-dens = yes
          pl-rvd-temp = yes
        .
        if tt-rvs-line.state-level-total = ?
        or tt-rvs-line.state-level-total <= 0
        then do :
          assign
            tt-rvs-line.state-level-total = tt-rvs-line.level-total
            tt-rvs-line.state-level-water = tt-rvs-line.level-water
          .
          display
            tt-rvs-line.state-level-total
            tt-rvs-line.state-level-water
          with frame Dialog-Frame.
        end .
        if tt-rvs-line.state-level-water = ?
        then do :
          assign tt-rvs-line.state-level-water = 0 .
          display tt-rvs-line.state-level-water with frame Dialog-Frame.
        end .
        display tt-rvs-line.asi-pomi-density with frame Dialog-Frame.
        vLabel = tt-rvs-line.izmer-density:SIDE-LABEL-HANDLE.
        vLabel:fgcolor = RED_COLOR .
        vLabel = tt-rvs-line.temp-izm-vol:SIDE-LABEL-HANDLE.
        vLabel:fgcolor = RED_COLOR .
        if tt-rvs-line.test-asi-diff > 1.7
        then tt-rvs-line.test-asi-diff:fgcolor = RED_COLOR .
        else tt-rvs-line.test-asi-diff:fgcolor = 0 .
        disable
          tt-rvs-line.state-level-total
          tt-rvs-line.state-level-water
        with frame Dialog-Frame.
        if v-mi-dnst > 0
        and tt-rvs-line.state-level-total > 0
        then
          enable b-density with frame Dialog-Frame.
        if v-mi-tmp > 0
        and tt-rvs-line.state-level-total > 0
        then
          enable b-temperature with frame Dialog-Frame.
        enable
          v-mi-dnst b-mi-dnst v-mi-dnst-name
          v-mi-tmp b-mi-tmp v-mi-tmp-name
        with frame Dialog-Frame.
      end .
      when "test-asi_mass"
      then do :
        assign
          pl-rvd-dens = yes
          pl-rvd-temp = yes
          pl-rvd-lvl  = yes
        .
        assign tt-rvs-line.test-asi-diff:label = "Расхождение значения по массе НП (%)" .
        vLabel = tt-rvs-line.izmer-density:SIDE-LABEL-HANDLE.
        vLabel:fgcolor = RED_COLOR .
        vLabel = tt-rvs-line.temp-izm-vol:SIDE-LABEL-HANDLE.
        vLabel:fgcolor = RED_COLOR .
        vLabel = tt-rvs-line.state-level-total:SIDE-LABEL-HANDLE.
        vLabel:fgcolor = RED_COLOR .
        vLabel = tt-rvs-line.state-level-water:SIDE-LABEL-HANDLE.
        vLabel:fgcolor = RED_COLOR .
        if tt-rvs-line.test-asi-diff > 0.65
        then tt-rvs-line.test-asi-diff:fgcolor = RED_COLOR .
        else tt-rvs-line.test-asi-diff:fgcolor = 0 .
        if v-mi-dnst > 0
        and tt-rvs-line.state-level-total > 0
        then
          enable b-density with frame Dialog-Frame.
        if v-mi-lvl > 0
        then
          enable tt-rvs-line.state-level-total tt-rvs-line.state-level-water with frame Dialog-Frame.
        if v-mi-tmp > 0
        and tt-rvs-line.state-level-total > 0
        then
          enable b-temperature with frame Dialog-Frame.
        enable
          v-mi-lvl b-mi-lvl v-mi-lvl-name
          v-mi-dnst b-mi-dnst v-mi-dnst-name
          v-mi-tmp b-mi-tmp v-mi-tmp-name
        with frame Dialog-Frame.
      end .
    end case .
    hide
      hide-text-dop-si
    in frame Dialog-Frame.
  end.
  if v-test-asi-type = "test-asi_dens-place"
  then do :
    assign
      v-mi-lvl = ?
      v-mi-lvl-name = "?"
      v-mi-lvl-name:screen-value = ""
      v-mi-tmp = ?
      v-mi-tmp-name = "?"
      v-mi-tmp-name:screen-value = ""
    .
  end .
  if v-test-asi-type = "test-asi_dens-pump"
  then do :
    assign
      v-mi-lvl = ?
      v-mi-lvl-name = "?"
      v-mi-lvl-name:screen-value = ""
    .
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
  if rdc-value <> 'pomi-rn'
  then do :
    hide
      b-temperature
      b-density
      tt-rvs-line.temp-izm-vol
      b-POkMI-result
    in frame Dialog-Frame.
    if parmode = 'ИЗМЕНЕНИЕ':U
    then do :
      enable
        tt-rvs-line.state-density
        tt-rvs-line.state-temperature
        tt-rvs-line.state-measure-cli-qnty
        tt-rvs-line.state-level-total
        tt-rvs-line.state-level-water
        tt-rvs-line.fact-calc-vol
      with frame Dialog-Frame.
    end .
  end .
  define variable sr-type-temp as integer no-undo .
  define variable sr-type-temp-tab as integer no-undo .
  define variable sr-type-dens as integer no-undo .
  define variable v-izm-temps-attr as character no-undo .
  define variable v-izm-temps-tab-attr as character no-undo .
  define variable v-izm-denses-attr as character no-undo .
  define variable it as integer no-undo .
  define variable id as integer no-undo .
  define variable ikey as integer no-undo .
  find first rvs-line-attr no-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "izm-temps-tab" no-error.
  if available rvs-line-attr then do :
    sr-type-temp-tab = integer(entry(1, rvs-line-attr.attr-value, ";")) no-error .
    v-izm-temps-tab-attr = entry(2, rvs-line-attr.attr-value, ";") no-error .
  end .
  case sr-type-temp-tab :
    when 0
    then do :
      ikey = num-entries(v-izm-temps-tab-attr) .
      do it = 1 to num-entries(v-izm-temps-tab-attr) :
        find first tt-temps-tab no-lock where tt-temps-tab.ii = ikey no-error .
        if not available tt-temps-tab
        then do :
          create tt-temps-tab .
          assign
            tt-temps-tab.ii = ikey
            tt-temps-tab.key_ = "t" + string(ikey)
            tt-temps-tab.temperature = decimal(entry(it, v-izm-temps-tab-attr))
          .
        end .
        ikey = ikey - 1 .
      end .
    end .
    when 1
    then do :
      do it = 1 to num-entries(v-izm-temps-tab-attr) :
        find first tt-temps-tab no-lock where tt-temps-tab.ii = it no-error .
        if not available tt-temps-tab
        then do :
          if place-type = 1
          and it = 3
          then do :
            tt-temps-tab.key_ = "tср" no-error .
          end .
          create tt-temps-tab .
          assign
            tt-temps-tab.ii = it
            tt-temps-tab.temperature = decimal(entry(it, v-izm-temps-tab-attr))
          .
          case it :
            when 1 then tt-temps-tab.key_ = "tн" .
            when 2 then tt-temps-tab.key_ = "tср" .
            when 3 then tt-temps-tab.key_ = "tв" .
          end case .
          if place-type = 1
          and it = 2
          then do :
            tt-temps-tab.key_ = "tв" no-error .
          end .
        end .
      end .
    end .
  end case .
  find first rvs-line-attr no-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "izm-temps" no-error.
  if available rvs-line-attr then do :
    sr-type-temp = integer(entry(1, rvs-line-attr.attr-value, ";")) no-error .
    v-izm-temps-attr = entry(2, rvs-line-attr.attr-value, ";") no-error .
  end .
  find first rvs-line-attr no-lock
           where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
             and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
             and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
             and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
             and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
             and rvs-line-attr.attr-code = "izm-denses" no-error.
  if available rvs-line-attr then do :
    sr-type-dens = integer(entry(1, rvs-line-attr.attr-value, ";")) no-error .
    v-izm-denses-attr = entry(2, rvs-line-attr.attr-value, ";") no-error .
  end .
  case sr-type-temp :
    when 0
    then do :
      ikey = num-entries(v-izm-temps-attr) .
      do it = 1 to num-entries(v-izm-temps-attr) :
        find first tt-temps no-lock where tt-temps.ii = ikey no-error .
        if not available tt-temps
        then do :
          create tt-temps .
          assign
            tt-temps.ii = ikey
            tt-temps.key_ = "t" + string(ikey)
            tt-temps.temperature = decimal(entry(it, v-izm-temps-attr))
          .
        end .
        ikey = ikey - 1 .
      end .
    end .
    when 1
    then do :
      do it = 1 to num-entries(v-izm-temps-attr) :
        find first tt-temps no-lock where tt-temps.ii = it no-error .
        if not available tt-temps
        then do :
          if place-type = 1
          and it = 3
          then do :
            tt-temps.key_ = "tср" no-error .
          end .
          create tt-temps .
          assign
            tt-temps.ii = it
            tt-temps.temperature = decimal(entry(it, v-izm-temps-attr))
          .
          case it :
            when 1 then tt-temps.key_ = "tн" .
            when 2 then tt-temps.key_ = "tср" .
            when 3 then tt-temps.key_ = "tв" .
          end case .
          if place-type = 1
          and it = 2
          then do :
            tt-temps.key_ = "tв" no-error .
          end .
        end .
      end .
    end .
  end case .
  case sr-type-dens :
    when 0
    then do :
      ikey = num-entries(v-izm-denses-attr) .
      do id = 1 to num-entries(v-izm-denses-attr) :
        find first tt-dens no-lock where tt-dens.ii = ikey no-error .
        if not available tt-dens
        then do :
          create tt-dens .
          assign
            tt-dens.ii = ikey
            tt-dens.key_ = "P" + string(ikey) + (if ikey = 1 then "(низ)" else "")
            tt-dens.density = decimal(entry(id, v-izm-denses-attr))
          .
        end .
        ikey = ikey - 1 .
      end .
    end .
    when 1
    then do :
      do id = 1 to num-entries(v-izm-denses-attr) :
        find first tt-dens-temp no-lock where tt-dens-temp.ii = id no-error .
        if not available tt-dens-temp
        then do :
          create tt-dens-temp .
          assign
            tt-dens-temp.ii = id
            tt-dens-temp.density = decimal(entry(id, v-izm-denses-attr))
          .
          tt-dens-temp.temperature = decimal(entry(id, v-izm-temps-attr)) no-error .
          case id :
            when 1 then tt-dens-temp.key_ = "Pн" .
            when 2 then tt-dens-temp.key_ = "Pср" .
            when 3 then tt-dens-temp.key_ = "Pв" .
          end case .
        end .
      end .
    end .
  end case .
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
if tt-rvs-line.fact-calc-vol:sensitive
then
  tt-rvs-line.state-measure-cli-qnty = tt-rvs-line.state-measure-qnty * tt-rvs-line.state-density
.
else
assign
  tt-rvs-line.state-measure-qnty = tt-rvs-line.state-measure-cli-qnty / tt-rvs-line.state-density
  tt-rvs-line.fact-calc-vol = tt-rvs-line.state-measure-qnty
.
assign
  tt-rvs-line.state-brutto-cli-qnty = tt-rvs-line.state-measure-cli-qnty + (if varstate-water-qnty <> ? then varstate-water-qnty else 0)
  tt-rvs-line.fact-calc-add-mass = tt-rvs-line.state-add-qnty  * tt-rvs-line.state-density
  tt-rvs-line.fact-sum-mass = tt-rvs-line.fact-calc-add-mass + tt-rvs-line.state-measure-cli-qnty
  varstate-sum-vol = tt-rvs-line.state-brutto-qnty
.
display tt-rvs-line.state-measure-cli-qnty tt-rvs-line.fact-calc-vol varstate-sum-vol with frame Dialog-Frame.
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
    DISPLAY tt-rvs-line.measure-qnty tt-rvs-line.state-measure-qnty
          tt-rvs-line.meas-calc-qnty tt-rvs-line.measure-tc-qnty tt-rvs-line.state-measure-tc-qnty
          tt-rvs-line.density tt-rvs-line.state-density
          tt-rvs-line.meas-calc-dens tt-rvs-line.izmer-density
          tt-rvs-line.brutto-qnty tt-rvs-line.state-brutto-qnty
          tt-rvs-line.brutto-tc-qnty tt-rvs-line.state-brutto-tc-qnty
          tt-rvs-line.measure-cli-qnty tt-rvs-line.state-measure-cli-qnty
          tt-rvs-line.meas-cli-calc-qnty tt-rvs-line.temp-izm-vol
          tt-rvs-line.brutto-cli-qnty tt-rvs-line.state-brutto-cli-qnty
          tt-rvs-line.level-petrol tt-rvs-line.state-level-petrol
          tt-rvs-line.level-total tt-rvs-line.state-level-total
          tt-rvs-line.level-water tt-rvs-line.state-level-water
          tt-rvs-line.temperature tt-rvs-line.state-temperature
          tt-rvs-line.meas-mh-qnty tt-rvs-line.state-mh-qnty
          tt-rvs-line.meas-am-qnty tt-rvs-line.state-am-qnty
          tt-rvs-line.meas-cf-qnty tt-rvs-line.state-cf-qnty
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-cancel b-help RECT-2 RECT-3 tt-rvs-line.state-measure-qnty
         tt-rvs-line.state-density
         tt-rvs-line.state-brutto-qnty tt-rvs-line.state-brutto-cli-qnty
         tt-rvs-line.state-level-petrol tt-rvs-line.state-level-total
         tt-rvs-line.state-temperature
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
  tt-rvs-line.state-level-petrol = input frame Dialog-Frame tt-rvs-line.state-level-total - input frame Dialog-Frame tt-rvs-line.state-level-water .
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
        bf_pl-level.pl-qnty @ tt-rvs-line.fact-calc-vol
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
          bf_pl-level.pl-qnty + (buf-nxt_pl-level.pl-qnty - bf_pl-level.pl-qnty) * (varlevel-sm-q - trunc(varlevel-sm-q, 0)) @ tt-rvs-line.fact-calc-vol
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
                  display tt-rvs-line.fact-calc-vol + varstate-water-qnty  @ varstate-sum-vol
                      with frame Dialog-Frame.
          end.
          else
          do:
              assign
                  varstate-water-qnty = bf_pl-level.pl-qnty  .
              display  varstate-water-qnty with frame Dialog-Frame.
              display tt-rvs-line.fact-calc-vol + varstate-water-qnty  @ varstate-sum-vol
                      with frame Dialog-Frame.
          end.
      end.
          else do:
              assign
                  varstate-water-qnty = 0  .
              display  varstate-water-qnty with frame Dialog-Frame.
              display tt-rvs-line.fact-calc-vol @ varstate-sum-vol
              with frame Dialog-Frame.
          end.
      assign
        tt-rvs-line.fact-calc-vol
        tt-rvs-line.fact-calc-vol = tt-rvs-line.fact-calc-vol - varstate-water-qnty
        tt-rvs-line.state-measure-qnty = tt-rvs-line.fact-calc-vol
        tt-rvs-line.state-brutto-qnty = tt-rvs-line.state-measure-qnty + varstate-water-qnty
      .
        display tt-rvs-line.fact-calc-vol with frame Dialog-Frame.
        if tt-rvs-line.state-density <> 0 and
            tt-rvs-line.state-density <> ? then
        do:
            run chg-density.
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
       tt-rvs-line.state-measure-cli-qnty = input frame Dialog-Frame tt-rvs-line.fact-calc-vol * tt-rvs-line.state-density .
       tt-rvs-line.fact-sum-mass = tt-rvs-line.state-measure-cli-qnty + tt-rvs-line.fact-calc-add-mass .
    tt-rvs-line.fact-sum-vol = tt-rvs-line.fact-calc-vol + tt-rvs-line.state-add-qnty .
    varstate-sum-vol = input frame Dialog-Frame tt-rvs-line.fact-calc-vol + varstate-water-qnty .
    display
      tt-rvs-line.fact-sum-vol
      tt-rvs-line.state-measure-cli-qnty
      tt-rvs-line.fact-sum-mass
      varstate-sum-vol
    with frame Dialog-Frame.
    run volume-water.
  end.
end.
END PROCEDURE.
PROCEDURE volume-measure-water :
  display ? @ varmeasure-water-qnty with frame Dialog-Frame.
  for first rvs-line-attr no-lock
        where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          and rvs-line-attr.attr-code = "measure-water-qnty"
  :
    display decimal(rvs-line-attr.attr-value) @ varmeasure-water-qnty with frame Dialog-Frame.
  end .
END PROCEDURE.
PROCEDURE volume-water :
if rdc-value <>  "pomi-rn"
then do :
end.
else do :
  for first rvs-line-attr no-lock
        where rvs-line-attr.obj-code  = tt-rvs-line.obj-code
          and rvs-line-attr.obj-type  = tt-rvs-line.obj-type
          and rvs-line-attr.gds-code  = tt-rvs-line.gds-code
          and rvs-line-attr.pl-code   = tt-rvs-line.pl-code
          and rvs-line-attr.rvs-code  = tt-rvs-line.rvs-code
          and rvs-line-attr.attr-code = "pokmi-water-qnty"
  :
    display decimal(rvs-line-attr.attr-value) @ varstate-water-qnty with frame Dialog-Frame.
  end .
end .
END PROCEDURE.
