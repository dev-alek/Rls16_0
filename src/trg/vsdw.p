block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись ВСД

Автор: Морозов Александр Сергеевич
Дата создания: 04/23/18
Author: Morozov Alexandr
Creation date: 04/23/18


*/

TRIGGER PROCEDURE FOR WRITE OF ub.vsd OLD oldvsd.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись ВСД".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }


main-block:
do
on error  undo main-block, return error substitute("&1. error &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on endkey undo main-block, return error substitute("&1. endkey")
on stop   undo main-block, return error substitute("&1. stop")
:

  define buffer buf_vsd-attr for ub.vsd-attr.
  
  if not g#news 
  then do:
    run str/callnews.p
      (input {&table_vsd}
      ,input (buffer ub.vsd:handle)
      ) no-error.
  
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно маршрутизировать vsd для отправки в новости" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo , return error return-value .
    end.
    for each buf_vsd-attr exclusive-lock where buf_vsd-attr.ID = ub.vsd.ID and buf_vsd-attr.db-num = ub.vsd.db-num:  
      run str/callnews.p
        (input {&table_vsd-attr}
        ,input (buffer buf_vsd-attr:handle)
        ) no-error.
    
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно маршрутизировать vsd для отправки в новости" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo , return error return-value .
      end.
    end.
  end.

end.
