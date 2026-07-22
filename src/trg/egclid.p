block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Тригер на удаление связи егаис справочника поставщиков с контрагентами TH

Автор: Хныкин Павел Андреевич
Дата создания: 05/28/08
Author: Pavel Khnykin
Creation date: 05/28/08

*/

trigger procedure for delete of ub.egais-clients.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Тригер на удаление связи егаис справочника поставщиков с контрагентами TH".
{ cmp/vssrevis.i "substitute('&1'
                            , ub.egais-clients.supp-id
                            )"
}
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  define buffer buf_sys-ctrl        for ub.sys-ctrl.
  define buffer buf_c-egais-clients for ub.c-egais-clients.

  define variable v-date as date    no-undo .
  define variable v-time as integer no-undo .

  find first buf_sys-ctrl no-lock no-error .
  if not available buf_sys-ctrl
  then do:
    undo main-block, return error substitute("Не найдена запись sys-ctrl для БД!") .
  end.

  run cur-time in this-procedure(output v-date, output v-time).

  create buf_c-egais-clients.
  buffer-copy ub.egais-clients to buf_c-egais-clients
  assign
    buf_c-egais-clients.chip-num         = next-value (s-egais, {&db-name_schema})
    buf_c-egais-clients.corr-time        = v-time
    buf_c-egais-clients.corr-date        = v-date
    buf_c-egais-clients.corr-user-db-num = buf_sys-ctrl.db-num
    buf_c-egais-clients.corr-user-name   = g#userid
  .

  run nws/cmd-del.p ( input {&table_egais-clients}
                    , input (buffer ub.egais-clients:handle)
                    , input ""
                    ) no-error .
  if error-status :error
  then do:
    undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4"
                                            , vss-workfile
                                            , {&new-line}
                                            , return-value
                                            , error-status :get-message(1)
                                            ) .
  end.

  if g#oxml = yes
  then do:
    run str/calloxml.p ( input {&nwsdochs_action_delete}
                       , input {&table_egais-clients}
                       , input ( buffer ub.egais-clients:handle )
                       ) no-error .
    if error-status :error
    then do:
      undo main-block, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                                              , {&new-line}
                                              , vss-workfile
                                              , return-value
                                              , error-status :get-message ( 1 )
                                              ).
    end.
  end.
end.
