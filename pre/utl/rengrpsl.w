define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Выбор шкалы для сортировки признаков".
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
define temp-table temp-prt-root no-undo     field node-code  as integer label 'Код'     field node-name like gds-prt.node-name format 'x(40)' label 'Название'     index pk is primary unique node-code     index ie1 node-name     .
define variable v-node-code as integer   no-undo .
define variable v-level     as integer   no-undo .
define query temp-prt-root for temp-prt-root .
define browse temp-prt-root query temp-prt-root
       display temp-prt-root.node-name
       with size 45 by 13.7 no-labels separators .
define button b-exit auto-go default
     LABEL "&Выход"
     SIZE 10 BY 1.
define button b-sel
     LABEL "Вы&бор"
     SIZE 10 BY 1.
define button b-help
    label "Помо&щь"
     SIZE 10 BY 1.
define FRAME f-rengd
  b-exit        AT ROW  1   COL  1
  b-sel         AT ROW  1   COL 11
  b-help        AT ROW  1   COL 21
  "Редактирование названий признаков шкалы"  AT ROW  2   COL 1
  temp-prt-root AT ROW  4   COL  1
WITH VIEW-AS DIALOG-BOX SCROLLABLE SIDE-LABELS THREE-D DEFAULT-BUTTON b-exit TITLE "".
on choose of b-sel
or return of temp-prt-root
or default-action of temp-prt-root
do:
  if available temp-prt-root
  then do:
    run utl/ren-grp.w
      (input temp-prt-root.node-code
      ) .
  end.
end.
do
on error undo, return error return-value
:
  define buffer buf_sys-ctrl for ub.sys-ctrl .
  find first buf_sys-ctrl no-lock .
  if buf_sys-ctrl.db-num <> 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Процедура переименования признака шкалы может запускаться только в ГБД"
      view-as alert-box error .
    undo, return error .
  end.
  run fill-temp-table in this-procedure .
  open query temp-prt-root for each temp-prt-root .
  enable
    temp-prt-root b-exit b-sel b-help
    with frame f-rengd.
  apply 'entry':u to temp-prt-root .
  wait-for go of frame f-rengd.
end.
procedure fill-temp-table :
  define buffer buf_gds-prt for ub.gds-prt .
  define buffer buf_temp-prt-root for temp-prt-root .
  do
  on error undo, return error return-value
  :
    define variable v-prt-level as integer   no-undo .
    for each buf_gds-prt no-lock
      where buf_gds-prt.root = true
        and buf_gds-prt.node-name <> '_Пустая шкала':U
    on error undo, return error
    :
      create buf_temp-prt-root .
      assign
        buf_temp-prt-root.node-code = buf_gds-prt.node-code
        buf_temp-prt-root.node-name = buf_gds-prt.node-name
      .
    end.
  end.
end procedure.
