/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функции выяснения  смарт маршрутизации по ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/10/08
Author: Bakhtadze Natalya
Creation date: 07/10/08

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

function dc-smart_is-this-correct RETURNS CHARACTER
  ( INPUT p-dt-code AS INTEGER
  , INPUT p-table-name AS CHARACTER
  , INPUT p-db-num AS INTEGER
  , INPUT p-type AS CHARACTER
  , INPUT p-emitent-host-code AS INTEGER
  , INPUT p-obj-type AS CHARACTER
   ,input p-obj-code AS INTEGER
   ,INPUT p-d-card AS CHARACTER
    ) :
define VARIABLE v-dtm-code AS INTEGER NO-UNDO.
define VARIABLE v-smart-nws AS INTEGER NO-UNDO.
define VARIABLE v-obj-db-num AS INTEGER NO-UNDO INIT -1.
DEFINE BUFFER buf_dis-obj FOR ub.dis-obj.
DEFINE BUFFER buf_hist-nws-option FOR ub.hist-nws-option.
DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.
DEFINE BUFFER buf_clients FOR ub.clients.
IF p-db-num = 0 THEN  RETURN "+".
IF p-table-name = {&TABLE_dis-obj} THEN DO:
  { gbl/objdbnum.i p-obj-type p-obj-code v-obj-db-num  NO-ERROR}
  IF v-obj-db-num = p-db-num THEN RETURN "+".
END.

IF p-dt-code = 0 THEN DO:
  v-dtm-code = 1.
END.
ELSE DO:
   FIND FIRST buf_prop-ref NO-LOCK WHERE
            buf_prop-ref.dt-code = p-dt-code NO-ERROR.
  IF AVAILABLE buf_prop-ref  THEN DO:
    v-dtm-code = buf_prop-ref.dtm-code.
  END.
END.
find first buf_HIST-NWS-OPTION WHERE
      buf_HIST-NWS-OPTION.db-num = 0
      and buf_hist-nws-option.table-name = p-table-name
      and buf_hist-nws-option.host-code = p-emitent-host-code
      and buf_hist-nws-option.obj-type = '':U
      and buf_hist-nws-option.obj-code = 0
      and buf_hist-nws-option.key#_one = 1
      and buf_hist-nws-option.charkey_one = p-type
      and buf_hist-nws-option.subject-group = {&table_c-dc-hist} NO-ERROR.

IF NOT AVAILABLE buf_hist-nws-option THEN v-smart-nws = -1.
ELSE v-smart-nws = buf_hist-nws-option.smart-nws .
IF v-smart-nws = INTEGER({&hn-is-on}) THEN DO:
  FOR EACH buf_dis-obj NO-LOCK WHERE
           buf_Dis-obj.d-card = p-d-card,
      FIRST buf_clients NO-LOCK WHERE
          buf_Clients.obj-type = buf_dis-obj.obj-type
       AND buf_clients.obj-code = buf_dis-obj.obj-code
      AND buf_clients.db-num =  p-db-num:
     LEAVE.
  END.
  IF AVAILABLE buf_dis-obj THEN RETURN "+".
  RETURN "-".
END.
IF v-smart-nws = INTEGER({&hn-is-smart2}) THEN RETURN "-".
RETURN "+".   /* Function return value. */

END FUNCTION.

/* $Workfile$ e n d */