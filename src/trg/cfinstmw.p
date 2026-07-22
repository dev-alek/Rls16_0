block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер за запись истории банковской выписки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/28/05
Author: Bakhtadze Natalya
Creation date: 07/28/05

*/


TRIGGER PROCEDURE FOR WRITE OF ub.c-fin-statement.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер за запись истории банковской выписки".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
             , ub.c-fin-statement.host-code
             , ub.c-fin-statement.sttm-code
             , ub.c-fin-statement.corr-user-db-num
             , ub.c-fin-statement.chip-num) " }
{ cmp/trg-def.i }

define buffer buf_fin-doc for ub.fin-doc.
define buffer buf_sysconf for ub.sysconf.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  find first buf_sysconf no-lock where
            buf_sysconf.host-code = ub.c-fin-statement.host-code no-error .
    if not available buf_sysconf then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на фирму" skip
      "код фирмы" ub.c-fin-statement.host-code skip
      view-as alert-box error .
      undo main-block, return error.
    end.
  if not g#news then do:
    if buf_sysconf.firm-db-num <> g#db-num
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя создавать записи истории ВЫПИСКИ в БД, отличной от главной БД фирмы" skip
      "код фирмы" ub.c-fin-statement.host-code skip
      "текущая БД" g#db-num skip
      "главная БД фирмы" buf_sysconf.firm-db-num
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.

  run str/callnews.p
    (input "c-fin-statement"
    ,input (buffer ub.c-fin-statement:handle)
    ).
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-fin-statement}
        , input ( buffer ub.c-fin-statement:handle )
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