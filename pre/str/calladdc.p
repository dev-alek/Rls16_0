block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: calladdc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/calladdc.p $":U .
define variable vss-description as character no-undo init "Процедура запуска режимов Список допрасходов".
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
define variable bttns          as character   no-undo .
define variable par-mode       as character   no-undo .
define variable pardoc-rec     as recid no-undo.
define variable par-host-code  like ub.clients.obj-code no-undo.
define variable p-obj-code     like ub.clients.obj-code no-undo.
define variable p-obj-type     like ub.clients.obj-type no-undo.
define variable p-doc-type     as character no-undo .
define variable p-status_      as character no-undo .
define variable p-char         as character no-undo .
define variable rid-list       as character no-undo .
case p-mode :
  when "1"  then do:
    assign
      par-mode      = "status"
      p-status_     = 'новый':U
      bttns         = "b-add,b-chg,b-del"
      par-host-code = v-cntxt-host-code-obj
      p-obj-code    = v-cntxt-obj-code
      p-obj-type    = v-cntxt-obj-type
    .
  end.
  when "4"  then do:
    assign
      par-mode      = "status"
      p-status_     = 'закрыт':U
      bttns         = ""
      par-host-code = v-cntxt-host-code-obj
      p-obj-code    = v-cntxt-obj-code
      p-obj-type    = v-cntxt-obj-type
    .
  end.
  when "2"  then do:
    assign
      par-mode      = "status"
      p-status_     = 'факт':U
      bttns         = ""
      par-host-code = v-cntxt-host-code-obj
      p-obj-code    = v-cntxt-obj-code
      p-obj-type    = v-cntxt-obj-type
    .
  end.
  when "3"  then do:
    assign
      par-mode      = 'объ':U
      p-status_     = 'все':U
      bttns         = "b-add,b-chg,b-del"
      par-host-code = v-cntxt-host-code-obj
      p-obj-code    = v-cntxt-obj-code
      p-obj-type    = v-cntxt-obj-type
    .
  end.
  when "11"  then do:
    assign
      par-mode      = "status-firm"
      p-status_     = 'новый':U
      bttns         = "b-add,b-chg,b-del"
      par-host-code = v-cntxt-host-code-obj
      p-obj-code    = v-cntxt-obj-code
      p-obj-type    = v-cntxt-obj-type
    .
  end.
  when "14"  then do:
    assign
      par-mode      = "status-firm"
      p-status_     = 'закрыт':U
      bttns         = ""
      par-host-code = v-cntxt-host-code-obj
      p-obj-code    = v-cntxt-obj-code
      p-obj-type    = v-cntxt-obj-type
    .
  end.
  when "12"  then do:
    assign
      par-mode      = "status-firm"
      p-status_     = 'факт':U
      bttns         = ""
      par-host-code = v-cntxt-host-code-obj
      p-obj-code    = v-cntxt-obj-code
      p-obj-type    = v-cntxt-obj-type
    .
  end.
  when "13"  then do:
    assign
      par-mode      = "firm"
      p-status_     = 'все':U
      bttns         = "b-add,b-chg,b-del"
      par-host-code = v-cntxt-host-code-obj
      p-obj-code    = v-cntxt-obj-code
      p-obj-type    = v-cntxt-obj-type
    .
  end.
end case.
run str/add-docs.w (
   input ParParentProc
  ,input bttns
  ,input par-mode
  ,input pardoc-rec
  ,input par-host-code
  ,input p-obj-code
  ,input p-obj-type
  ,input p-doc-type
  ,input p-status_
  ,input p-char
  ,output  rid-list
  ) no-error .
  if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
  end.
