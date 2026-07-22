block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список БД для Маршрутизации Цен

Автор: Чернова Светлана Александровна
Дата создания: 07/01/08
Author: Svetlana Chernova
Creation date: 07/01/08

*/
define input  parameter p-plt-db as integer   no-undo .
define input  parameter p-plt-id as integer   no-undo .
define output parameter p-db     as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список БД для Маршрутизации Цен".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ ref/xobjgrp.i  }


define buffer buf_price-list-type   for ub.price-list-type  .

main-block :
do on error undo main-block, return error
:
p-db  = "" .
find first buf_price-list-type   no-lock where
           buf_price-list-type.plt-id      = p-plt-id and
           buf_price-list-type.plt-db-num  = p-plt-db no-error .
if error-status :error then return .
run metod-gop-obj in this-procedure
   ( 0 ,
     buf_price-list-type.gop-id ,
     buf_price-list-type.gop-db-num
     ).

  if g#db-num = 0 then do: /* ГБД */
     for each x_obj-group where
              x_obj-group.db-num > 0
               break by x_obj-group.db-num :
        if first-of(x_obj-group.db-num) then do:
           p-db  = p-db + string(x_obj-group.db-num) + {&delim-nws} .
        end.
     end.
     p-db  = trim (p-db , {&delim-nws} ) .
  end.
  else do:
  /* удаленка  всегда в ГБД */
    p-db = "0" .
  end.

 end.