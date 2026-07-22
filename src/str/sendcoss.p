block-level on error undo, throw.
/*

$Revision: 848c16a0bcdd, 3040, rls $
$Author: SSlivenko $
$Date: Чт май 12 16:29:48 2022 +0300 $
$Workfile: sendcoss.p $
$Archive: str/sendcoss.p $

Отсылка данных по справочнику ОСС

Автор: Морозов Александр Сергеевич
Дата создания: 02/14/14
Author: Alexandr Morozov
Creation date: 02/14/14

Input:

Output:

*/
using ibs.th.ref.bpa.*.

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter i-obj-code like ub.shop.obj-code no-undo.
DEFINE INPUT PARAMETER action as char no-undo.
DEFINE INPUT PARAMETER selective as integer no-undo.
/*по оплатам выборочно или все!*/
define input parameter pSubs as character no-undo .
/*список recid cash-pay если selective = yes*/
define input parameter p-log-file-name as character no-undo .
define input-output parameter p-view-log as logical no-undo .


define variable vss-revision    as character no-undo init "$Revision: 848c16a0bcdd, 3040, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Чт май 12 16:29:48 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sendcoss.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sendcoss.p $":U .
define variable vss-description as character no-undo init "Отсылка данных по справочнику ОСС".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }
{ str/cdsnddef.i }
{ bge/bgelib.i }
{ str/cd-xml.i }

define variable v-host-code          like ub.sysconf.host-code no-undo .
define variable v-cp-is-use          as logical   no-undo .

FIND FIRST ub.cash-desk NO-LOCK WHERE
           ub.cash-desk.db-num = g#db-num AND
           (ub.cash-desk.pos-type = {&cd-type-IBM}
            AND
            ub.cash-desk.obj-code = i-obj-code)
           OR
           (ub.cash-desk.pos-type = {&cd-type-IBM-XML}
           AND
           ub.cash-desk.obj-code = i-obj-code)
            No-error.
IF not avail(cash-desk) then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!&1 справочника ОСС реализуется только для касс &2 &3 "
                          , (if action begins "U" then "Передача" else "Удаление")
                          , {&cd-type-ibm}
                          , {&cd-type-ibm-xml}
                        )
                                        ).
  return.
end.
if action = "D" then 
do:
  message
    "Вы действительно хотите удалить с кассы записи справочника платежных агентов/операторов?"
    view-as alert-box QUESTION buttons YES-NO update glog.
  if not glog then return.
end.
if action = "DD" then action = "D" .
if action = "UU" then action = "U" .
{ str/putc-oss.i }
/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/
if pSubs = "" then do:
{ str/cd-cyoss.i }
end.

RUN SENDING no-error.
{ str/cd-seoss.i }

assign
  log-file-name = p-log-file-name
  .

{ gbl/hostcode.i {&shop} i-obj-code v-host-code }

if error-status:error then 
do:
  run write-log-and-file in p-log-handle (
    input 1
    , input log-file-name
    , input 1
    , input substitute( "!!!Ошибки при отсылке справочника платежные агенты/операторы на кассы  маг&1:&2&3 &4"
    , i-obj-code
    , {&new-line}
    , error-status:get-message(1)
    , return-value
    )
    ).

  assign
    v-view-log = yes
    .
end.
  finally :
    run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("&1", {&new-line})
    ).
    define variable v-save-file-name as character no-undo .
    v-save-file-name = substitute("&1send-cd.log", ibs.th.gbl.gbl-inipar:logDir) .
    OS-APPEND value(log-file-name) value(v-save-file-name).
    OS-DELETE value(log-file-name).
  end finally .
