block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись банковской выписки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/02/05
Author: Bakhtadze Natalya
Creation date: 08/02/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.fin-statement OLD buffer oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись банковской выписки".
{ cmp/vssrevis.i "substitute('&1|&2', ub.fin-statement.host-code, ub.fin-statement.sttm-code) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ trg/factord.i }
{ trg/finsttmh.i }


define variable v-creating-hist as logical no-undo .
define variable v-cmp as character no-undo .

define buffer buf_sysconf  for ub.sysconf.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    find first buf_sysconf no-lock.
    if buf_sysconf.firm-db-num <> g#db-num
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя изменять запись БАНКОВСКОЙ ВЫПИСКИ в БД, отличной от главной БД фирмы" skip
      "Номер текущей БД" g#db-num "Номер главной БД фирмы" buf_sysconf.firm-db-num
      view-as alert-box error .
      undo main-block, return error .
    end.
  end.
  if not g#news
  and not new(ub.fin-statement)
  and (ub.fin-statement.status_ <> {&fin-new}
       or oldb.status_ <> {&fin-new}
       ) then do:
    buffer-compare oldb
    to ub.fin-statement
    case-sensitive
    save result in v-cmp
    .
    if v-cmp <> "":U then do:
      assign
      v-creating-hist = yes
      .
      run write-fin-statement-history in this-procedure (buffer oldb).
    end.
  end.
  if v-creating-hist
  or
  (oldb.status_ <> ub.fin-statement.status_
  AND not new(ub.fin-statement)) then do:
    run str/callnews.p
      (input {&table_fin-statement}
      ,input (buffer ub.fin-statement:handle)
      ).
  end.


    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_fin-statement}
        , input ( buffer ub.fin-statement:handle )
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