block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ord-db.p $
$Archive: cus/ord-db.p $

Список номеров БД по заказу ОРЦ

Автор: Чернова Светлана Александровна
Дата создания: 04/25/06
Author: Svetlana Chernova
Creation date: 04/25/06

*/
define input  parameter p-doc like ub.ord-doc.doc-code no-undo . /* уникальный ключ*/
define output parameter p-db  as character no-undo .             /* список БД*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-db.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-db.p $":U .
define variable vss-description as character no-undo init "Список номеров БД по по поставкам".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
define variable  p-db1  as character no-undo .
define variable  p-db2  as character no-undo .


define buffer buf_ord-doc for ub.ord-doc.
define buffer b_clients  for ub.clients .
define buffer c_clients  for ub.clients .

main-block :
do on error undo main-block, return error
:
p-db  = "" .
p-db1 = "0".
p-db2 = "0" .
find first buf_ord-doc no-lock where  buf_ord-doc.doc-code  = p-doc  .

/* база объекта */
      find first b_clients  no-lock where  b_clients.obj-type = buf_ord-doc.obj-type and
                                           b_clients.obj-code = buf_ord-doc.obj-code  .
      if available b_clients then
                    p-db1 = string(b_clients.db-num) .
                    else
                    p-db1 = "0" .

/* база контрагента */
          find first c_clients  no-lock where  c_clients.obj-type = buf_ord-doc.cli-type and
                                               c_clients.obj-code = buf_ord-doc.cli-code  .
          if available c_clients then
              p-db2 = string(c_clients.db-num) .
              else
              p-db2 = "0" .


  if g#db-num = 0 then do: /* ГБД */
    case buf_ord-doc.status_ :
      when {&ord-req} then do: /* запрос */
         p-db = p-db2 .
      end.
      when {&ord-per} then do: /* разр */
         p-db = p-db1 .
      end.
      when {&ord-ship} then do: /* отгруж */
         p-db = p-db1 .
      end.
      when {&fact} then do: /* факт */
         p-db = p-db2 .
      end.
    end case.
  end.
  else do:
  /* удаленка  всегда в ГБД */
    p-db = "0" .
  end.

  /* задавим текущую бд */
  if g#db-num = integer(p-db) then p-db = "".

 /*
  message "db в которые пошел заказ " p-db skip  buf_ord-doc.status_ skip
  'тек g#db-num' g#db-num skip
  buf_ord-doc.doc-code
  .
  */

 end.

/* $Workfile: ord-db.p $ e n d */
