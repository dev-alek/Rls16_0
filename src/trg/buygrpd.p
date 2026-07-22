block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление группы покупателей

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
TRIGGER PROCEDURE FOR DELETE OF ub.buyer-group.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Удаление группы покупателей".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

do
on error undo, return error
:
/*
for each ub.buyer-in-buyer-group exclusive-lock where
         ub.buyer-in-buyer-group.bgr-id     = ub.buyer-group.bgr-id    and
         ub.buyer-in-buyer-group.bgr-db-num = ub.buyer-group.bgr-db-num   :
    delete ub.buyer-in-buyer-group.
end.
for each ub.c-buyer-in-buyer-group exclusive-lock where
         ub.c-buyer-in-buyer-group.bgr-id     = ub.buyer-group.bgr-id    and
         ub.c-buyer-in-buyer-group.bgr-db-num = ub.buyer-group.bgr-db-num   :
    delete ub.c-buyer-in-buyer-group.
end.
for each ub.c-buyer-group exclusive-lock where
         ub.c-buyer-group.bgr-id     = ub.buyer-group.bgr-id    and
         ub.c-buyer-group.bgr-db-num = ub.buyer-group.bgr-db-num   :
    delete ub.c-buyer-group.
end.

run nws/cmd-del.p
  ( input "buyer-group":U
  ,input (buffer ub.buyer-group:handle)
  ,input "":U
  ) no-error .
if error-status :error then do:
  return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
end.
 */
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_buyer-group}
        , input ( buffer ub.buyer-group:handle )
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