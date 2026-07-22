block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории финансового док-та

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-fin-doc .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории финансового док-та ".
{ cmp/vssrevis.i "substitute('&1|&2|&3', ub.c-fin-doc.host-code, ub.c-fin-doc.fin-doc-code, ub.c-fin-doc.chip-num) " }
{ cmp/trg-def.i }


define variable v-obj-db-num as integer no-undo init -1.
define buffer buf_fin-doc for ub.fin-doc.
define buffer buf_sysconf for ub.sysconf.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  find first buf_sysconf no-lock where
            buf_sysconf.host-code = ub.c-fin-doc.host-code no-error .
    if not available buf_sysconf then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на фирму" skip
      "код фирмы" ub.c-fin-doc.host-code skip
      view-as alert-box error .
      undo main-block, return error.
    end.
  if ub.c-fin-doc.obj-type <> ''
  or ub.c-fin-doc.obj-code <> 0 then do:
    { gbl/objdbnum.i ub.c-fin-doc.obj-type ub.c-fin-doc.obj-code v-obj-db-num }
  end.
  if not g#news then do:
    if not (buf_sysconf.firm-db-num = g#db-num
           or
           v-obj-db-num  = g#db-num)
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя создавать записи истории ПЛАТЕЖА в БД, отличной от главной БД фирмы и/или объекта" skip
      "код фирмы" ub.c-fin-doc.host-code skip
      "текущая БД" g#db-num skip
      "главная БД фирмы" buf_sysconf.firm-db-num
      "БД объекта" v-obj-db-num
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if not g#news then do:
  run str/callnews.p
      (input {&table_c-fin-doc}
    ,input (buffer ub.c-fin-doc:handle)
    ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-fin-doc}
        , input ( buffer ub.c-fin-doc:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.