block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись для таблицы ставки налогов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.tax-rate OLD old-tax-rate.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись для таблицы ставки налогов".
{ cmp/vssrevis.i "substitute('&1|&2'
                         , ub.tax-rate.tax-code
                         , ub.tax-rate.rate-code
                         ) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-tax-rate for ub.c-tax-rate.
define buffer buf_c-tax-hist for ub.c-tax-hist.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


find first ub.tax No-LOCK WHERE
            ub.tax.tax-code = ub.tax-rate.tax-code No-ERROR.
 if not avail ub.tax then do:
    message
        vss-workfile vss-revision vss-description skip
        "Не найден налог при записи ставки налога" skip
        "Код налога" ub.tax-rate.tax-code skip
        "Код ставки" ub.tax-rate.rate-code
        view-as alert-box error .
      undo main-block, return error .
 end.
 if ub.tax.individual then do:
    message
        vss-workfile vss-revision vss-description skip
        "Нельзя ввести ставки к индивидульному налогу" skip
        "Код налога" ub.tax-rate.tax-code skip
        "Код ставки" ub.tax-rate.rate-code
        view-as alert-box error .
      undo main-block, return error .

 end.
 if not g#news then do:
  if ub.tax-rate.status_ = {&deleted-status} then do:
    if can-find(first ub.tax-rate-value No-LOCK WHERE
                      ub.tax-rate-value.tax-code = ub.tax-rate.tax-code AND
                      ub.tax-rate-value.rate-code = ub.tax-rate.rate-code AND
                      ub.tax-rate-value.status_ = {&current-status}) then do:
      message
          vss-workfile vss-revision vss-description skip
          "Нельзя удалить ставку если есть неудаленные значения к ставке" skip
          "Код налога" ub.tax-rate.tax-code skip
          "Код ставки" ub.tax-rate.rate-code
          view-as alert-box error .
        undo main-block, return error .
    end.
  end.
 end.

  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-tax-rate.
    buffer-copy old-tax-rate to buf_c-tax-rate
    assign
    buf_c-tax-rate.tax-code           = ub.tax-rate.tax-code
    buf_c-tax-rate.rate-code           = ub.tax-rate.rate-code
    buf_c-tax-rate.chip-num           = next-value(s-corr-chip, {&db-name_schema})
    buf_c-tax-rate.corr-time          = v-time
    buf_c-tax-rate.corr-user-db-num   = g#db-num
    buf_c-tax-rate.corr-user-name     = g#userid
    buf_c-tax-rate.corr-date          = v-date
    .
    create buf_c-tax-hist.
    buffer-copy buf_c-tax-rate to buf_c-tax-hist
    assign
    buf_c-tax-hist.action = (if new (ub.tax-rate-value )
                            then integer({&hn-create})
                            else integer({&hn-update}))
    buf_c-tax-hist.subject = {&table_tax-rate}
    buf_c-tax-hist.is-news = no
    .
  end.


  run str/callnews.p
    (input {&table_tax-rate}
    ,input (buffer ub.tax-rate:handle)
    ).

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_tax-rate}
        , input ( buffer ub.tax-rate:handle )
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