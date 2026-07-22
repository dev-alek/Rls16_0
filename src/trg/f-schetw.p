block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись банковского счета

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.fin-schet OLD old_fin-schet.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись банковского счета".
{ cmp/vssrevis.i "substitute('&1|&2', ub.fin-schet.host-code, ub.fin-schet.code-schet) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ gbl/clntattr.i }


define variable v-date as date      no-undo .
define variable v-time as integer   no-undo .
define variable v-cmp  as character no-undo .
define buffer buf_c-fin-schet for ub.c-fin-schet.
define buffer buf_sysconf     for ub.sysconf.
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
    run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-ttype) no-error.
    if v-value = "no"  then 
    do:   
      find first buf_sysconf no-lock where
        buf_sysconf.host-code = ub.fin-schet.host-code.
      if buf_sysconf.firm-db-num <> g#db-num then 
      do:
        message
          vss-workfile vss-revision vss-description skip
          "Нельзя изменять запись СЧЕТА в БД, отличной от главной БД фирмы" skip
          "Номер текущей БД" g#db-num "Номер главной БД фирмы" buf_sysconf.firm-db-num
          view-as alert-box error .
        undo main-block, return error .
      end.
    end.
  end.

  buffer-compare old_fin-schet
    to ub.fin-schet
    case-sensitive
    save result in v-cmp
    .

  if not g#news and v-cmp <> "":U then 
  do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-fin-schet.
    buffer-copy old_fin-schet to buf_c-fin-schet
      assign
      buf_c-fin-schet.host-code         =  ub.fin-schet.host-code
      buf_c-fin-schet.code-schet         = ub.fin-schet.code-schet
      buf_c-fin-schet.chip-num           = next-value (s-corr-chip, {&db-name_schema})
      buf_c-fin-schet.corr-time          = v-time
      buf_c-fin-schet.corr-user-db-num   = g#db-num
      buf_c-fin-schet.corr-user-name     = g#userid
      buf_c-fin-schet.corr-date          = v-date
      .
  end.
  if v-cmp <> "":U then
    run str/callnews.p
      (input "fin-schet"
      ,input (buffer ub.fin-schet:handle)
      ).

  if g#oxml = yes
    then 
  do:
    run str/calloxml.p (
      input {&nwsdochs_action_update}
      , input {&table_fin-schet}
      , input ( buffer ub.fin-schet:handle )
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