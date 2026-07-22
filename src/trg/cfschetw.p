block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории банковского счета

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/20/03
Author: Bakhtadze Natalya
Creation date: 10/20/03

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-fin-schet OLD old_c-fin-schet.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории банковского счета".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4' ~
                               , ub.c-fin-schet.host-code ~
                               , ub.c-fin-schet.code-schet  ~
                               , ub.c-fin-schet.corr-user-db-num  ~
                               , ub.c-fin-schet.chip-num) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }

define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_sysconf   for ub.sysconf.
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
    find first buf_fin-schet no-lock where
      buf_fin-schet.host-code = c-fin-schet.host-code
      AND buf_fin-schet.code-schet = c-fin-schet.code-schet no-error .
    if not available buf_fin-schet then 
    do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильная ссылка на БАНКОВСКИЙ СЧЕТА" skip
        "код фирмы" c-fin-schet.host-code skip
        "код счета" c-fin-schet.code-schet
        view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  find first buf_sysconf no-lock where
    buf_sysconf.host-code = c-fin-schet.host-code no-error .
  if not available buf_sysconf then 
  do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на фирму" skip
      "код фирмы" c-fin-schet.host-code skip
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
          "Нельзя создавать записи истории БАНКОВСКОГО СЧЕТА в БД, отличной от главной БД фирмы" skip
          "код фирмы" c-fin-schet.host-code skip
          "текущая БД" g#db-num skip
          "главная БД фирмы" buf_sysconf.firm-db-num
          view-as alert-box error .
        undo main-block, return error.
      end.
    end.
  end.

  run str/callnews.p
    (input {&table_c-fin-schet}
    ,input (buffer ub.c-fin-schet:handle)
    ).
  if g#oxml = yes
    then 
  do:
    run str/calloxml.p (
      input {&nwsdochs_action_update}
      , input {&table_c-fin-schet}
      , input ( buffer ub.c-fin-schet:handle )
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