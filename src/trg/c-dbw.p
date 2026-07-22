block-level on error undo, throw.
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории конфигурационного параметра

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/16/05
Author: Dmitry Ukhanov
Creation date: 11/16/05
*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-db .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории конфигурационного параметра".
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

  run str/callnews.p
    (input {&table_c-db}
    ,input (buffer ub.c-db:handle)
    ) no-error .
  if error-status:error then do:
    undo main-block, return error return-value .
  end.

  if g#oxml = yes then do:
    run str/calloxml.p
      ( input {&nwsdochs_action_update}
      , input {&table_c-db}
      , input ( buffer ub.c-db:handle )
      ) no-error.
    if error-status :error then do:
      undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                            , {&new-line}
                            , vss-workfile
                            , return-value
                            , error-status :get-message ( 1 ) ).
    end.
  end.
end.