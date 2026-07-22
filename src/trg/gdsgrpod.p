block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление gds-grp-obj

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06


*/

TRIGGER PROCEDURE FOR DELETE OF ub.gds-grp-obj.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление gds-grp-obj".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                                    ,ub.gds-grp-obj.node-code
                                    ,ub.gds-grp-obj.host-code
                                    ,ub.gds-grp-obj.obj-type
                                    ,ub.gds-grp-obj.obj-code
                                    )" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/gds-grph.i }


main-block :
do
on error undo main-block, return error return-value
:

  if ub.gds-grp-obj.host-code = 0
  and ub.gds-grp-obj.obj-type = "":U
  and ub.gds-grp-obj.obj-code = 0
  then do:
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя удалить корневую запись параметров группы товара" skip
    "код группы" ub.gds-grp-obj.node-code
    view-as alert-box error .
    undo, return error.
  end.

  run nws/cmd-del.p
    ( input "gds-grp-obj":U
     ,input (buffer ub.gds-grp-obj:handle)
     ,input "":U
    ) no-error .
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.

  if not g#news then do:
    run gds-grph_write-gds-grp-obj-proc   in this-procedure (
                                                      buffer ub.gds-grp-obj
                                                      ,integer({&hn-delete})
                                                      ,"":U /*p-source-type*/
                                                      ,"":U
                                                      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_gds-grp-obj}
        , input ( buffer ub.gds-grp-obj:handle )
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