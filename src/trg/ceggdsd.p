block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Тригер на удаление истории связи егаис справочника АП с товаром TH

Автор: Хныкин Павел Андреевич
Дата создания: 05/28/08
Author: Pavel Khnykin
Creation date: 05/28/08

*/

trigger procedure for delete of ub.c-egais-gds.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Тригер на удаление истории связи егаис справочника АП с товаром TH".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                            , ub.c-egais-gds.alpr-id
                            , ub.c-egais-gds.corr-user-db-num
                            , ub.c-egais-gds.chip-num
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
  undo main-block, return error substitute( "&1 &2 &3&4&5"
                                          , vss-workfile
                                          , vss-revision
                                          , vss-description
                                          , "Нельзя удалять запись ИСТОРИЯ ПРИВЯЗКИ ЕГАИС АП"
                                          ) .

end.
