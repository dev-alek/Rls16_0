block-level on error undo, throw.
/*

Чистка УБД. Заказы.

Автор: Ростовцев Александр
Дата создания: 18/09/2025
Author: Aleksandr Rostovtsev
Creation date: 09/18/25
*/


&scop Tables Заказы с историей
/*&scop Tables order-doc ~*/
/*order-doc-attr ~       */
/*order-line ~           */
/*order-line-attr ~      */
/*c-order-head ~         */
/*c-order-doc ~          */
/*c-order-doc-attr ~     */
/*c-order-line ~         */
/*c-order-line-attr      */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: Sep 15 2025 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00043000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00127000.p $".
define variable vss-description as character no-undo init "Чистка УБД.".
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i  }
{ cleandb/defs.i }

define variable orderStatus  as class ibs.th.str.order.sts.order no-undo .

define buffer order-doc      for ub.order-doc  .
define buffer buf_order-doc  for ub.order-doc  .

on delete of ub.order-doc               override do: end.

orderStatus =  new ibs.th.str.order.sts.order().

for each buf_clients no-lock
   where buf_clients.db-num <> ?
:
  for each order-doc no-lock where
           order-doc.order-date < vardate-actual-docs
       and order-doc.sts = orderStatus:DeliveryCompleted:KeyIntDB
       and order-doc.db-num  = buf_clients.db-num
      use-index date-sts
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    run cleanTable in this-procedure .
    { cleandb/delmainrec.i order-doc}
  end.
end.

{cleandb/setresval.i}
return vResult.

procedure cleanTable :
  {cleandb/dellinkrec.i 
     order-doc-attr  
     "where order-doc-attr.db-num   = order-doc.db-num
        and order-doc-attr.doc-code = order-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     order-line  
     "where order-line.db-num = order-doc.db-num
        and order-line.doc-code = order-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     order-line-attr  
     "where order-line-attr.db-num   = order-doc.db-num
        and order-line-attr.doc-code = order-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     c-order-head  
     "where c-order-head.db-num   = order-doc.db-num
        and c-order-head.doc-code = order-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     c-order-doc  
     "where c-order-doc.db-num   = order-doc.db-num
        and c-order-doc.doc-code = order-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     c-order-doc-attr  
     "where c-order-doc-attr.db-num   = order-doc.db-num
        and c-order-doc-attr.doc-code = order-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     c-order-line  
     "where c-order-line.db-num   = order-doc.db-num
        and c-order-line.doc-code = order-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
     c-order-line-attr  
     "where c-order-line-attr.db-num   = order-doc.db-num
        and c-order-line-attr.doc-code = order-doc.doc-code"
  }
end procedure. 

