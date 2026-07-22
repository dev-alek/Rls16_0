block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Тригер на запись истории связи егаис справочника поставщиков с контрагентами TH

Автор: Хныкин Павел Андреевич
Дата создания: 05/28/08
Author: Pavel Khnykin
Creation date: 05/28/08

*/

trigger procedure for write of ub.c-egais-clients.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Тригер на запись истории связи егаис справочника поставщиков с контрагентами TH".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                            , ub.c-egais-clients.supp-id
                            , ub.c-egais-clients.corr-user-db-num
                            , ub.c-egais-clients.chip-num
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
  run str/callnews.p ( input {&table_c-egais-clients}
                    , input (buffer ub.c-egais-clients:handle)
                    ) no-error .
  if error-status:error then do:
      undo main-block , return error substitute( "&1 &2 &3&4&5&4&6&4&7"
                                               , vss-workfile
                                               , vss-revision
                                               , vss-description
                                               , {&new-line}
                                               , "Ошибка при передаче в новости"
                                               , error-status :get-message(1)
                                               , return-value
                                               ) .
  end.

  if g#oxml = yes
  then do:
    run str/calloxml.p ( input {&nwsdochs_action_update}
                       , input {&table_c-egais-clients}
                       , input ( buffer ub.c-egais-clients:handle )
                       ) no-error .
    if error-status :error
    then do:
      undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                                   , {&new-line}
                                   , vss-workfile
                                   , return-value
                                   , error-status :get-message ( 1 )
                                   ) .
    end.
  end.

end.
