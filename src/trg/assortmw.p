block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на изменение таблицы assortment-matrix-attr


Автор: Чернова Светлана Александровна
Дата создания: 11/01/07
Author: Svetlana Chernova
Creation date: 11/01/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.assortment-matrix-attr old old-assortment-matrix-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на изменение таблицы assortment-matrix-attr".


{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

/* Отправка по новостям */
  if g#db-num = 0 or ( g#db-num <> 0 and g#news = false )  then do:
      run str/callnews.p
        (input "assortment-matrix-attr"
        ,input (buffer ub.assortment-matrix-attr:handle)
        ) no-error .
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при передаче в новости" skip
          return-value skip
          view-as alert-box error .
          return error.
      end.
  end.

  if g#db-num = 0 and g#news then do:    /* прием в ГБД */
     if new ( ub.assortment-matrix-attr ) or
        ub.assortment-matrix-attr.attr-value <> old-assortment-matrix-attr.attr-value then do:
          run str/callnews.p
            (input "assortment-matrix-attr"
            ,input (buffer ub.assortment-matrix-attr:handle)
            ) no-error .
          if error-status:error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при передаче в новости" skip
              return-value skip
              view-as alert-box error .
              return error.
          end.
       end.
  end.

end. /* main-block */