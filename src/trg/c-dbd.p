block-level on error undo, throw.
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории конфигурационного параметра

Автор: Уханов Дмитрий Юрьевич
Дата создания: 12/01/08
Author: Dmitry Ukhanov
Creation date: 12/01/08

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-db.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление записи истории конфигурационного параметра".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                                 , ub.c-db.db-num
                                 , ub.c-db.corr-user-db-num
                                 , ub.c-db.chip-num
                                 ) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  message
    vss-workfile vss-revision vss-description skip
    "Нельзя удалять запись истории БД"
    view-as alert-box error .
  undo main-block, return error .
end.

/* $Workfile$ e n d */