block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Тригер на удаление Группа объектов для ценообразовани

Автор: Чернова Светлана Александровна
Дата создания: 11/21/05
Author: Svetlana Chernova
Creation date: 11/21/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.grp-obj-price.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Тригер на удаление Группа объектов для ценообразования ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  for each  ub.db-grp-obj-price exclusive-lock where
            ub.db-grp-obj-price.gop-db-num = ub.grp-obj-price.gop-db-num    and
            ub.db-grp-obj-price.gop-id     = ub.grp-obj-price.gop-id
            :
            delete ub.db-grp-obj-price.
  end.

  for each  ub.host-grp-obj-price exclusive-lock where
            ub.host-grp-obj-price.gop-db-num = ub.grp-obj-price.gop-db-num    and
            ub.host-grp-obj-price.gop-id     = ub.grp-obj-price.gop-id
            :
           delete ub.host-grp-obj-price.
  end.

  for each  ub.obj-grp-obj-price exclusive-lock where
            ub.obj-grp-obj-price.gop-db-num = ub.grp-obj-price.gop-db-num    and
            ub.obj-grp-obj-price.gop-id     = ub.grp-obj-price.gop-id
            :
           delete  ub.obj-grp-obj-price.
  end.
  if g#db-num = 0 or ( g#db-num <> 0 and g#news = false  )  then do:
      run nws/cmd-del.p
       ( input {&table_grp-obj-price},
         input (buffer ub.grp-obj-price:handle),
         input "":U )
      no-error .
      if error-status :error then
         return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи grp-obj-price. &1&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_grp-obj-price}
        , input ( buffer ub.grp-obj-price:handle )
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


