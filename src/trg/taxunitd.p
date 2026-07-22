block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление связки налог-тип ед изм

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.tax-units.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление связки налог-тип ед изм".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-tax-units for ub.c-tax-units.
define buffer buf_c-tax-hist for ub.c-tax-hist.


define buffer b_tax for ub.tax.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  FIND FIRST b_tax No-LOCK WHERE
             b_tax.tax-code = ub.tax-units.tax-code No-ERROR.
  if not avail b_tax then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найден налог при удалении связки налог-тип ед.изм" skip
    "Код налога" ub.tax-units.tax-code skip
    "Тип ед.изм" ub.tax-units.type
    view-as alert-box error .
    undo main-block, return error .
  end.
  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-tax-units.
    assign
    buf_c-tax-units.tax-code           = ub.tax-units.tax-code
    buf_c-tax-units.type               = ub.tax-units.type
    buf_c-tax-units.chip-num           = next-value(s-corr-chip, {&db-name_schema})
    buf_c-tax-units.corr-time          = v-time
    buf_c-tax-units.corr-user-db-num   = g#db-num
    buf_c-tax-units.corr-user-name     = g#userid
    buf_c-tax-units.corr-date          = v-date
    .
    create buf_c-tax-hist.
    buffer-copy buf_c-tax-units to buf_c-tax-hist
    assign
    buf_c-tax-hist.action =  integer({&hn-delete})
    buf_c-tax-hist.subject = {&table_tax-units}
    buf_c-tax-hist.is-news = no
    .
  end.
  run nws/cmd-del.p
    ( input {&table_tax-units}
     ,input (buffer ub.tax-units:handle)
     ,input "":U
    ) no-error .
  if error-status :error then do:
    undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_tax-units}
        , input ( buffer ub.tax-units:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.