block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список БД для Маршрутизации price-all

Автор: Чернова Светлана Александровна
Дата создания: 07/01/08
Author: Svetlana Chernova
Creation date: 07/01/08

*/
define input  parameter p-rowid as rowid no-undo .
define output parameter p-db    as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список БД для Маршрутизации price-all".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ ref/xobjgrp.i  }


define buffer buf_price-all   for ub.price-all  .
define variable v-db as integer   no-undo .
define variable v-par-m as character no-undo .

main-block :
do on error undo main-block, return error
:
p-db  = "" .
find first buf_price-all   no-lock where rowid(buf_price-all) = p-rowid  no-error .
if error-status :error then return .

find first ub.global-state no-lock no-error .
if error-status :error then return error return-value .

find first ub.global-state-attr no-lock where
           ub.global-state-attr.gls-id =  ub.global-state.gls-id and
           ub.global-state-attr.attr-code = {&attr-pal-nws} no-error .
if available ub.global-state-attr then
        v-par-m =  ub.global-state-attr.attr-value .
   else v-par-m = ''.

  if v-par-m = 'yes' then do:
     /* Ходят только в свою БД */
      if g#db-num = 0 then do: /* ГБД */
          { gbl/objdbnum.i
            buf_price-all.obj-type
            buf_price-all.obj-code
            v-db
            no-error
          }
          if error-status :error then p-db = "".
          p-db = string(v-db) .
          if v-db = 0 then p-db = "".
      end.
      else do:
      /* удаленка  всегда в ГБД */
        p-db = "0" .
      end.
  end.
  else do:
    run trg/pdf-db.p ( input  buf_price-all.plt-db-num ,
                       input  buf_price-all.plt-id     ,
                       output p-db
                      ).
  end.
 end.