block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление ставки налога

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.tax-rate-gds.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "триггер на удаление ставки налога".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7':u,ub.tax-rate-gds.fact-order,ub.tax-rate-gds.gds-code,ub.tax-rate-gds.host-code,ub.tax-rate-gds.obj-code,ub.tax-rate-gds.obj-type,ub.tax-rate-gds.rate-code,ub.tax-rate-gds.tax-code)" }
{ cmp/trg-def.i }
{ gbl/cur-time.i }

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-host-code like ub.sysconf.host-code no-undo .

define buffer buf_c-gds-hist for ub.c-gds-hist.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

    run cur-time in this-procedure(output v-date, output v-time).
    assign
    ub.tax-rate-gds.chip-num           = next-value (s-gds-chip, {&db-name_schema})
    ub.tax-rate-gds.corr-time          = v-time
    ub.tax-rate-gds.corr-user-db-num   = g#db-num
    ub.tax-rate-gds.corr-user-name     = (if g#news then {&nts-user} else g#userid)
    ub.tax-rate-gds.corr-user-name     = (if g#news
                                        then {&nts-user}
                                        else (if g#esys
                                              then {&esys-user}
                                              else g#userid)
                                        )
    ub.tax-rate-gds.corr-date          = v-date
    .
    { gbl/hostcode.i ub.tax-rate-gds.obj-type ub.tax-rate-gds.obj-code v-host-code }
    create buf_c-gds-hist.
    buffer-copy ub.tax-rate-gds to buf_c-gds-hist
    assign
    buf_c-gds-hist.action = integer({&hn-delete})
    buf_c-gds-hist.subject = {&table_tax-rate-gds}
    buf_c-gds-hist.host-code = v-host-code
    buf_c-gds-hist.is-news  = g#news
    buf_c-gds-hist.source-type = (if g#news
                                  then {&hn-source-db}
                                  else (if g#esys
                                        then {&hn-source-esys}
                                        else "":U)
                                  )
    buf_c-gds-hist.source-ref = (if g#news
                                  then string(g#news-source-db)
                                  else (if g#esys
                                        then string(g#esys-source-esys)
                                        else "":U)
                                  )
    .
    run nws/cmd-del.p
      ( input {&table_tax-rate-gds}
       ,input (buffer ub.tax-rate-gds:handle)
       ,input "":U
      ) no-error .
    if error-status :error then do:
      undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_tax-rate-gds}
        , input ( buffer ub.tax-rate-gds:handle )
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