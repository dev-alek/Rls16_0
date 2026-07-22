block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: eventlib.p $
$Archive: gbl/eventlib.p $

Библиотека логмрования событий на кассе и в СВ

Автор: Белоусов Илья Александрович
Дата создания: 12/03/08
Author: Ilia Belousov
Creation date: 12/03/08

Input:

Output:

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: eventlib.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/eventlib.p $":U .
define variable vss-description as character no-undo init "Библиотека логмрования событий на кассе и в СВ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/eventlib.i   }

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

define variable v-log-level    as integer INIT -1  no-undo.  /* -1 логирование не считано, 0 - нет логирования */



/*==========================================================================*/
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
      v-trans-id = NEXT-VALUE(s-cd-events-log, {&db-name_schema})
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
end. /* do on error */
end procedure. /* eventlib-event-log */



/*==========================================================================*/
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

end. /* do on error */
end procedure. /* init-log */



/*==========================================================================*/
procedure send-cctv-prisma :

do
on error undo, return error
:

end. /* do on error */
end procedure. /* send-cctv-prisma */




/*==========================================================================*/
procedure send-cctv-intel :

do
on error undo, return error
:

end. /* do on error */
end procedure. /* send-cctv-intel */