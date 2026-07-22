block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление справочника товаров Меркурий

Автор: Морозов Александр Сергеевич
Дата создания: 04/23/18
Author: Morozov Alexandr
Creation date: 04/23/18


*/

TRIGGER PROCEDURE FOR DELETE OF ub.gds-mercury .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление справочника соответсвия товаров mercury товарам TH".
{ cmp/trg-def.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  for each ub.gds-mercury-attr exclusive-lock where ub.gds-mercury-attr.ID = ub.gds-mercury.ID and ub.gds-mercury-attr.db-num = ub.gds-mercury.db-num:
  
    delete ub.gds-mercury-attr.
  
  end.
  
  if not g#news 
  then do:
    run nws/cmd-del.p
      ( input {&table_gds-mercury}
       ,input (buffer ub.gds-mercury:handle)
       ,input "":U
      ) no-error .
  
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно маршрутизировать удаление gds-mercury для отправки в новости" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo , return error return-value .
    end.
  end.
end.
