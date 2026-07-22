block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление знаечния ставки налога

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.tax-rate-value.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление знаечния ставки налога".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7'
                         , ub.tax-rate-value.tax-code
                         , ub.tax-rate-value.rate-code
                         , ub.tax-rate-value.corr-user-db-num
                         , ub.tax-rate-value.chip-num
                         , ub.tax-rate-value.host-code
                         , ub.tax-rate-value.obj-type
                         , ub.tax-rate-value.obj-code
                         ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-tax-hist for ub.c-tax-hist.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    assign
    ub.tax-rate-value.chip-num           = next-value(s-corr-chip, {&db-name_schema})
    ub.tax-rate-value.corr-time          = v-time
    ub.tax-rate-value.corr-user-db-num   = g#db-num
    ub.tax-rate-value.corr-user-name     = g#userid
    ub.tax-rate-value.corr-date          = v-date
    .
    create buf_c-tax-hist.
    buffer-copy tax-rate-value to buf_c-tax-hist
    assign
    buf_c-tax-hist.action = integer({&hn-delete})
    buf_c-tax-hist.subject = {&table_tax-rate-value}
    buf_c-tax-hist.is-news = no
    .
  end.
/* маршрутизация */
  run nws/cmd-del.p
    ( input {&table_tax-rate-value}
     ,input (buffer ub.tax-rate-value:handle)
     ,input "":U
    ) no-error .
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_tax-rate-value}
        , input ( buffer ub.tax-rate-value:handle )
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