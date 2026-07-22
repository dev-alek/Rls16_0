block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rcv-db.p $
$Archive: cus/rcv-db.p $

Список номеров БД по по поставкам

Автор: Чернова Светлана Александровна
Дата создания: 04/12/02
Author: Svetlana Chernova
Creation date: 04/12/02

Creation date: 04/12/02 5:52

*/
define input  parameter p-doc like ub.ord-doc-rcv.doc-code no-undo .  /* уникальный ключ*/
define input  parameter p-rcv like ub.ord-doc-rcv.rcv-code no-undo .  /* уникальный ключ*/
define output parameter p-db  as character no-undo .                  /* список БД*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rcv-db.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/rcv-db.p $":U .
define variable vss-description as character no-undo init "Список номеров БД по по поставкам".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

define variable  p-db1  as integer no-undo .
define variable  p-db2  as integer no-undo .

define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
define buffer b_clients  for ub.clients .
define buffer c_clients  for ub.clients .

main-block :
do on error undo main-block, return error
:
p-db  = "" .
p-db1 = 0 .
p-db2 = 0 .
find first buf_ord-doc-rcv no-lock where  buf_ord-doc-rcv.doc-code  = p-doc  and
                                          buf_ord-doc-rcv.rcv-code  = p-rcv   no-error .
      if error-status :error then do:
       p-db = "0".
       return.
      end.
      find first b_clients  no-lock where  b_clients.obj-type = buf_ord-doc-rcv.obj-type and
                                           b_clients.obj-code = buf_ord-doc-rcv.obj-code no-error  .

      if available b_clients then
                    p-db1 = b_clients.db-num .
                    else
                    p-db1 = 0 .

      If buf_ord-doc-rcv.doc-type = "in":U  or
         buf_ord-doc-rcv.doc-type = {&ord-req}
          then do: /* Если поставка внутренняя то ее еще в базу контрагента */
          find first c_clients  no-lock where  c_clients.obj-type = buf_ord-doc-rcv.cli-type and
                                               c_clients.obj-code = buf_ord-doc-rcv.cli-code  .
          if available c_clients then
              p-db2 = c_clients.db-num .
              else
              p-db2 = 0 .
              if p-db1  = ? then  p-db1 = 0 .
              if p-db2  = ? then  p-db2 = 0 .
              if p-db1 = p-db2 then  p-db = string(p-db2) .
                               else  p-db = string(p-db1) + {&delim-nws} + string(p-db2) .
      end.
      else do:
          if p-db1  = ?  or  p-db1  = 0  then  do:
                  p-db1 = 0 .
                  p-db = string(p-db1) .
             end.
           else do:
             p-db = string(p-db1) + {&delim-nws} + "0" .
           end.
      end.

 /* задавим текущую базу */
 case lookup(string(g#db-num), p-db , {&delim-nws}) :
      when 1 then do:
         if num-entries(p-db, {&delim-nws}) = 2 then do:
           p-db = entry(2, p-db, {&delim-nws}) .
         end.
         else do:
           p-db = "".
         end.
      end.
      when 2 then do:
        p-db = entry(1, p-db, {&delim-nws}) .
      end.
 end case.

  /* Для поставок от заказов ОО из удаленок всегда еще  посылать в 0 */
  /*if g#db-num <> 0 and buf_ord-doc-rcv.doc-type = {&ord-req}  and lookup('0', p-db , {&delim-nws}) = 0 then do:
      p-db = string(p-db) + {&delim-nws} + "0" .
  end.
  */
  if g#db-num <> 0  then do:
     p-db = "0" .
  end.
   /*  message "Отправляется поставка в БД " p-db  skip "из БД " g#db-num. */
 end.

/* $Workfile: rcv-db.p $ e n d */