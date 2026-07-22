block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

триггер на удаление ставки налога

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.tax-rate.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "триггер на удаление ставки налога".
{ cmp/vssrevis.i "substitute('&1|&2'
                         , ub.tax-rate.tax-code
                         , ub.tax-rate.rate-code
                         ) " }


{ cmp/trg-def.i }
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


    FIND FIRST ub.tax-rate-value NO-LOCK
                              where ub.tax-rate-value.tax-code = ub.tax-rate.tax-code AND
                                        ub.tax-rate-value.rate-code = ub.tax-rate.rate-code NO-ERROR.
    IF AVAIL ub.tax-rate-value then do:
        message "По ставке налога с данным кодом имеются значения ставок!" skip
                "Удаление невозможно!" view-as alert-box ERROR.
      undo main-block, return error.
    end.
    FIND FIRST ub.tax-rate-gds NO-LOCK
                              where ub.tax-rate-gds.tax-code = ub.tax-rate.tax-code AND
                                        ub.tax-rate-gds.rate-code = ub.tax-rate.rate-code NO-ERROR.
    IF AVAIL ub.tax-rate-gds then do:
        message "Имеются товары с данным кодом ставки налога!" skip
                "Удаление невозможно!" view-as alert-box ERROR.
      undo main-block, return error.
    end.
    if not g#news then do:
      run cur-time in this-procedure(output v-date, output v-time).
      create buf_c-tax-rate.
      buffer-copy ub.tax-rate to buf_c-tax-rate
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
      buffer-copy tax-rate to buf_c-tax-hist
      assign
      buf_c-tax-hist.action =  integer({&hn-delete})
      buf_c-tax-hist.subject = {&table_tax-rate}
      buf_c-tax-hist.is-news = no
      buf_c-tax-hist.corr-time          = v-time
      buf_c-tax-hist.corr-user-db-num   = g#db-num
      buf_c-tax-hist.corr-user-name     = g#userid
      buf_c-tax-hist.corr-date          = v-date
      .
    end.
    run nws/cmd-del.p
      ( input {&table_tax-rate}
       ,input (buffer ub.tax-rate:handle)
       ,input "":U
      ) no-error .
    if error-status :error then do:
      undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_tax-rate}
        , input ( buffer ub.tax-rate:handle )
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