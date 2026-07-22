block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись события лока ресурса

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/15/07
Author: Bakhtadze Natalya
Creation date: 05/15/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.who-lk.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись события лока ресурса".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4':u
                            ,ub.who-lk.resource#_id
                            ,ub.who-lk.lk-type
                            ,ub.who-lk.corr-user-db-num
                            ,ub.who-lk.chip-num
                            )" }
{ cmp/trg-def.i }
define variable v-mes as character no-undo .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news
  and ub.who-lk.corr-user-db-num <> g#db-num then do:
    run vss-get-parameters( output v-mes) .
    message
    vss-workfile vss-revision vss-description skip
    "Ставится лок" v-mes skip
    "Нельзя ставить лок для чужой БД" skip
    "Номер БД удаляемого лока" ub.who-lk.corr-user-db-num
    "Номер текущей БД" g#db-num
    view-as alert-box error .
    undo main-block, return error .
  end.


  if not g#news
  or g#db-num = 0
  then do:
    run str/callnews.p
      (input {&table_who-lk}
      ,input (buffer ub.who-lk:handle)
      ).
  end.
  if g#oxml = yes
  then do:
      run str/calloxml.p (
            input {&nwsdochs_action_update}
          , input {&table_who-lk}
          , input ( buffer ub.who-lk:handle )
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