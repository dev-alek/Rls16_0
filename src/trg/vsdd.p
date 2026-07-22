block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаления ВСД

Автор: Морозов Александр Сергеевич
Дата создания: 04/23/18
Author: Morozov Alexandr
Creation date: 04/23/18


*/

TRIGGER PROCEDURE FOR DELETE OF ub.vsd.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаления ВСД".
{ cmp/trg-def.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  for each ub.vsd-attr exclusive-lock where ub.vsd-attr.ID = ub.vsd.ID and ub.vsd-attr.db-num = ub.vsd.db-num:
  
    delete ub.vsd-attr.
  
  end.
  
  if not g#news 
  then do:
    run nws/cmd-del.p
      ( input {&table_vsd}
       ,input (buffer ub.vsd:handle)
       ,input "":U
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно маршрутизировать удаление vsd для отправки в новости" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo , return error return-value .
    end.
  end.


end.
