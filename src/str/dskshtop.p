block-level on error undo, throw.
/*

$Revision: 79dbeab10a26, 2672, rls $
$Author: Ostroukhov $
$Date: Вт ноя 17 10:53:20 2020 +0300 $
$Workfile: dskshtop.p $
$Archive: str/dskshtop.p $

Проверка корректности открытия смены на объекте с точки зрения кассы и продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/18/06
Author: Bakhtadze Natalya
Creation date: 01/18/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-silent as logical no-undo .
DEFINE INPUT PARAMETER p-obj-type like ub.shift-obj.obj-type no-undo.
DEFINE INPUT PARAMETER p-obj-code like ub.shift-obj.obj-code no-undo.
DEFINE INPUT PARAMETER p-shift-date like ub.shift-obj.shift-date no-undo.
DEFINE INPUT PARAMETER p-shift-num like ub.shift-obj.shift-num no-undo.
define input parameter p-shift-name like ub.shift-obj.shift-name no-undo.


define variable vss-revision    as character no-undo init "$Revision: 79dbeab10a26, 2672, rls $":u .
define variable vss-author      as character no-undo init "$Author: Ostroukhov $":u .
define variable vss-date        as character no-undo init "$Date: Вт ноя 17 10:53:20 2020 +0300 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: dskshtop.p $":u .
define variable vss-archive     as character no-undo init "$Archive: str/dskshtop.p $":u .
define variable vss-description as character no-undo init "Проверка корректности открытия смены на объекте с точки зрения кассы и продаж" .
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ gbl/cur-time.i }

define variable last-shift-date like ub.chk-doc.shift-date no-undo.
define variable last-shift-num like ub.chk-doc.shift-num no-undo.
define variable loc#log as logical no-undo.
define variable vreason as character no-undo.
define variable v-recid as recid no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_cash-desk for ub.cash-desk.


/*докачать все чеки*/
run str/diallog.w (  input parparentproc
              , input this-procedure
              , input 'str/get-chkf.p':U
              , input (p-obj-type + {&delim-par} + string(p-obj-code) + {&delim-par} +
                string(0)  + {&delim-par} + string(0) + {&delim-par} + string(- 1) + {&delim-par} +
                string(p-shift-num) + {&delim-par} + replace(string(p-shift-date, "99/99/9999"), {&slash-char} , "":U)
                )

              , input (if p-silent then yes else no) /*p-auto-go*/
              , input '':U
              , input 'Прием чеков с касс') no-error .


IF error-status:error then do:
    return error "Ошибка при получении почты с касс".
end.

/*проверка нет ли неучтенных чеков в которых не указана смена*/

{ gbl/getcntxt.i get }

for each buf_chk-doc No-LOCK WHERE
        buf_chk-doc.obj-type = p-obj-type
    AND buf_chk-doc.obj-code = p-obj-code
    AND buf_chk-doc.shift-date = ?
    AND buf_chk-doc.out-code = ?
    AND buf_chk-doc.shift-name = '':U  :
  vreason = substitute("На объекте &1&2 имеются неучтенные чеки,&2в которых не указана смена"
                        ,p-obj-type
                        ,p-obj-code
                        ,{&new-line}).
   return error vreason.
end.


/*
пока не будем проверять неучтенные чеки по уже закрытым сменам!!!!
закоментарено!!!
loc#log = no.
FOR EACH buf_chk-doc No-LOCK where
                  buf_chk-doc.obj-type = p-obj-type AND
                  buf_chk-doc.obj-code = p-obj-code AND
                  buf_chk-doc.out-code = ?
                  ,
        FIRST buf_shift-obj No-LOCK WHERE
                   buf_shift-obj.obj-type = buf_chk-doc.obj-type AND
                   buf_shift-obj.obj-type = buf_chk-doc.obj-type AND
                   buf_shift-obj.shift-date = buf_chk-doc.shift-date AND
                   buf_shift-obj.shift-num = buf_chk-doc.shift-num AND
                   buf_shift-obj.status_<> {&sht-closed}:
    if buf_chk-doc.office = {&gds-goods} or buf_chk-doc.office = {&gds-office} then NEXT.
    assign
    loc#log = yes
    last-shift-date = buf_shift-obj.shift-date
    last-shift-num = buf_shift-obj.shift-num
    .
    LEAVE.
END.
if loc#log then do:
    vreason = "На объекте " + p-obj-type + " " + string(p-obj-code) + " имеются неошибочные неучтенные чеки," + {&new-line} +
                    "по закрытой смене N " + string(p-shift-num) + " за "  + string(p-shift-date, "99/99/9999").
    return error vreason.
end.
*/

_cashdesk:
FOR EACH buf_cash-desk No-LOCK WHERE
         buf_cash-desk.db-num = v-cntxt-db-num and
         buf_cash-desk.obj-code = p-obj-code and
         buf_cash-desk.cash-on = yes:
  if buf_cash-desk.autonomy = integer({&cd-manager}) then next _cashdesk.
  run cur-time in this-procedure ( output v-today, output v-time).
  run str/shftccr.p (
                       INPUT p-obj-type
                      ,INPUT p-obj-code
                      ,INPUT buf_cash-desk.cash-num
                      ,INPUT p-shift-date
                      ,INPUT p-shift-num
                      ,input string(p-shift-num) /*истинный номер мы все равно не знаем*/
                      ,INPUT p-shift-name
                      ,input v-time
                      ,INPUT 0
                      ,INPUT {&obj-shift-open}
                      ,OUTPUT v-recid
                      ) no-error.

  if error-status:error then do:
      vreason = substitute("Ошибка при открытии смены на кассе N &1", buf_cash-desk.cash-num).
      undo _cashdesk, return error vreason.
  end.
END.