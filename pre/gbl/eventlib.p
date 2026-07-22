block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: eventlib.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/eventlib.p $":U .
define variable vss-description as character no-undo init "Библиотека логмрования событий на кассе и в СВ".
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#eventlib as handle no-undo.
if valid-handle (g#eventlib)
and g#eventlib <> this-procedure :handle
and g#eventlib :get-signature('library_testproc':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки" skip
    g#eventlib skip
    g#eventlib :type skip
    g#eventlib :file-name skip
    valid-handle(g#eventlib) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error return-value .
end.
else do:
  assign
    g#eventlib = this-procedure :handle
  .
end.
if this-procedure :persistent <> true
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка запуска библиотеки" program-name(1) skip
    "Попытка запустить ее как обычную процедуру" skip
    view-as alert-box error .
end.
on delete of this-procedure do:
  assign
    g#eventlib = ?
  .
end.
define variable v-log-level    as integer INIT -1  no-undo.
procedure eventlib-event-log :
define input parameter p-log-level      as integer    no-undo .
define input parameter p-db-num         as integer    no-undo .
define input parameter p-action-item-id as CHARACTER  no-undo .
define input parameter p-cash-num       as integer    no-undo .
define input parameter p-cd-mode        as CHARACTER  no-undo .
define input parameter p-chk-type       as integer    no-undo .
define input parameter p-d-card         as CHARACTER  no-undo .
define input parameter p-description    as CHARACTER  no-undo .
define input parameter p-discnt         as DECIMAL    no-undo .
define input parameter p-doc-code       as CHARACTER  no-undo .
define input parameter p-doc-qnty       as DECIMAL    no-undo .
define input parameter p-event-date     as DATE       no-undo .
define input parameter p-event-id       as integer    no-undo .
define input parameter p-event-time     as integer    no-undo .
define input parameter p-event-type     as CHARACTER  no-undo .
define input parameter p-gds-code       as integer    no-undo .
define input parameter p-obj-type       as character  no-undo .
define input parameter p-obj-code       as integer    no-undo .
define input parameter p-pay-card       as CHARACTER  no-undo .
define input parameter p-pos-type       as CHARACTER  no-undo .
define input parameter p-price          as DECIMAL    no-undo .
define input parameter p-shift-date     as DATE       no-undo .
define input parameter p-shift-name     as CHARACTER  no-undo .
define input parameter p-shift-num      as integer    no-undo .
define input parameter p-src-code       as CHARACTER  no-undo .
define input parameter p-tot-sum        as DECIMAL    no-undo .
define input parameter p-user-id        as CHARACTER  no-undo .
define buffer buf_cd-event-log      for ub.cd-event-log .
define variable v-trans-id       as int64      no-undo .
do
on error undo, return error
:
   IF v-log-level < (p-log-level + 1)
   THEN DO:
      RETURN.
   END.
   ASSIGN
      v-trans-id = NEXT-VALUE(s-cd-events-log, ub)
   .
   CREATE buf_cd-event-log.
   ASSIGN
      buf_cd-event-log.db-num          = p-db-num
      buf_cd-event-log.trans-id        = v-trans-id
      buf_cd-event-log.action-item-id  = p-action-item-id
      buf_cd-event-log.cash-num        = p-cash-num
      buf_cd-event-log.cd-mode         = p-cd-mode
      buf_cd-event-log.chk-type        = p-chk-type
      buf_cd-event-log.d-card          = p-d-card
      buf_cd-event-log.description     = p-description
      buf_cd-event-log.discnt          = p-discnt
      buf_cd-event-log.doc-code        = p-doc-code
      buf_cd-event-log.doc-qnty        = p-doc-qnty
      buf_cd-event-log.event-date      = p-event-date
      buf_cd-event-log.event-id        = p-event-id
      buf_cd-event-log.event-time      = p-event-time
      buf_cd-event-log.event-type      = p-event-type
      buf_cd-event-log.gds-code        = p-gds-code
      buf_cd-event-log.obj-code        = p-obj-code
      buf_cd-event-log.obj-type        = p-obj-type
      buf_cd-event-log.pay-card        = p-pay-card
      buf_cd-event-log.pos-type        = p-pos-type
      buf_cd-event-log.price           = p-price
      buf_cd-event-log.shift-date      = IF p-shift-date = ? THEN TODAY ELSE p-shift-date
      buf_cd-event-log.shift-name      = p-shift-name
      buf_cd-event-log.shift-num       = p-shift-num
      buf_cd-event-log.src-code        = p-src-code
      buf_cd-event-log.tot-sum         = p-tot-sum
      buf_cd-event-log.user-id         = p-user-id
   .
end.
end procedure.
procedure eventlib-log-level :
define input parameter p-log-level as integer          no-undo.
define output parameter p-ok as logical          no-undo.
do
on error undo, return error
:
   ASSIGN
      v-log-level = p-log-level
      p-ok        = TRUE
   .
end.
end procedure.
procedure send-cctv-prisma :
do
on error undo, return error
:
end.
end procedure.
procedure send-cctv-intel :
do
on error undo, return error
:
end.
end procedure.
