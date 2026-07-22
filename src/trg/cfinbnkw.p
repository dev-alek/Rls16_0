block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории банка

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/20/03
Author: Bakhtadze Natalya
Creation date: 10/20/03

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-fin-bank OLD old_c-fin-bank.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории банка".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4' ~
                  ,ub.c-fin-bank.host-code ~
                  ,ub.c-fin-bank.code-bank ~
                  ,ub.c-fin-bank.corr-user-db-num ~
                  ,ub.c-fin-bank.chip-num) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }

define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_sysconf  for ub.sysconf.
define variable v-value as character no-undo.
define variable v-ttype as character no-undo.

main-block:
do
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :

  if not g#news then 
  do:
    /*проверим реляционность*/
    find first buf_fin-bank no-lock where
      buf_fin-bank.host-code = c-fin-bank.host-code
      AND buf_fin-bank.code-bank = c-fin-bank.code-bank no-error .
    if not available buf_fin-bank then 
    do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильная ссылка на БАНК" skip
        "код фирмы" c-fin-bank.host-code skip
        "код банка" c-fin-bank.code-bank
        view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  find first buf_sysconf no-lock where
    buf_sysconf.host-code = c-fin-bank.host-code no-error .
  if not available buf_sysconf then 
  do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на фирму" skip
      "код фирмы" c-fin-bank.host-code skip
      view-as alert-box error .
    undo main-block, return error.
  end.
  if not g#news then 
  do:
    run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-ttype) no-error.
    if v-value = "no"  then 
    do:   
      if buf_sysconf.firm-db-num <> g#db-num then 
      do:
        message
          vss-workfile vss-revision vss-description skip
          "Нельзя создавать записи истории БАНКа в БД, отличной от главной БД фирмы" skip
          "код фирмы" c-fin-bank.host-code skip
          "текущая БД" g#db-num skip
          "главная БД фирмы" buf_sysconf.firm-db-num
          view-as alert-box error .
        undo main-block, return error.
      end.
    end.
  end.

  run str/callnews.p
    (input {&table_c-fin-bank}
    ,input (buffer ub.c-fin-bank:handle)
    ).

  if g#oxml = yes
    then 
  do:
    run str/calloxml.p (
      input {&nwsdochs_action_update}
      , input {&table_c-fin-bank}
      , input ( buffer ub.c-fin-bank:handle )
      ) no-error.
    if error-status :error
      then 
    do:
      undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
        , {&new-line}
        , vss-workfile
        , return-value
        , error-status :get-message ( 1 ) ).
    end.
  end.
end.