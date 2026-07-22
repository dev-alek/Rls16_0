block-level on error undo, throw.
/*

Чистка БД. Счета-фактуры.

Автор: Ростовцев Александр
Дата создания: 03/10/2025
Author: Aleksandr Rostovtsev
Creation date: 10/03/25
*/

&scop Tables Счета-фактуры с историей
/*&scop Tables schet-fact-doc ~*/
/*schet-fact-doc-attr ~        */
/*schet-fact-line ~            */
/*schet-fact-line-attr ~       */
/*c-schet-fact-doc ~           */
/*c-schet-fact-line ~          */
/*factur-connect ~             */
/*factur-connect-attr ~        */
/*factur-connect-line ~        */
/*factur-connect-line-attr     */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 03/10/2025":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00240000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00240000.p $".
define variable vss-description as character no-undo init "Файл пирога чистки БД.".
{ cmp/str-glbl.i }
{ cleandb/defs.i }

define buffer schet-fact-doc     for ub.schet-fact-doc.
define buffer buf_schet-fact-doc for ub.schet-fact-doc.

on delete of ub.schet-fact-doc override do: end.

for each buf_clients no-lock where 
         buf_clients.db-num <> ?
:
  for each schet-fact-doc no-lock where 
          schet-fact-doc.obj-type  = buf_clients.obj-type
      and schet-fact-doc.obj-code  = buf_clients.obj-code 
      and schet-fact-doc.fact-date < vardate-actual-docs 
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    run cleanTables in this-procedure.
    { cleandb/delmainrec.i schet-fact-doc}
  end.
end.

{cleandb/setresval.i}
return vResult.


procedure cleanTables :
  define buffer factur-connect           for ub.factur-connect.
  define buffer factur-connect-attr      for ub.factur-connect-attr.
  define buffer factur-connect-line      for ub.factur-connect-line.
  define buffer factur-connect-line-attr for ub.factur-connect-line-attr.
  on delete of ub.factur-connect               override do: end.
  on delete of ub.factur-connect-attr          override do: end.
  on delete of ub.factur-connect-line          override do: end.
  on delete of ub.factur-connect-line-attr     override do: end.


  {cleandb/dellinkrec.i 
    schet-fact-doc-attr  
    " where schet-fact-doc-attr.doc-code = schet-fact-doc.doc-code and schet-fact-doc-attr.db-num   = schet-fact-doc.db-num"
  }
  {cleandb/dellinkrec.i 
    schet-fact-line  
    " where schet-fact-line.doc-code = schet-fact-doc.doc-code and schet-fact-line.db-num   = schet-fact-doc.db-num"
  }
  {cleandb/dellinkrec.i 
    c-schet-fact-line  
    " where c-schet-fact-line.doc-code = schet-fact-doc.doc-code and c-schet-fact-line.db-num   = schet-fact-doc.db-num"
  }
  {cleandb/dellinkrec.i 
    schet-fact-line-attr  
    " where schet-fact-line-attr.doc-code = schet-fact-doc.doc-code and schet-fact-line-attr.db-num   = schet-fact-doc.db-num"
  }
  {cleandb/dellinkrec.i 
    c-schet-fact-doc  
    " where c-schet-fact-doc.doc-code = schet-fact-doc.doc-code and c-schet-fact-doc.db-num   = schet-fact-doc.db-num"
  }
  for each factur-connect exclusive-lock where
           factur-connect.factur-doc-code = schet-fact-doc.doc-code 
       and factur-connect.db-num          = schet-fact-doc.db-num
  :
    for each factur-connect-attr exclusive-lock where
             factur-connect-attr.db-num       = factur-connect.db-num
         and factur-connect-attr.connect-code = factur-connect.connect-code
    :
      delete factur-connect-attr.
      vDeleted = vDeleted + 1.
    end.
    for each factur-connect-line exclusive-lock where
             factur-connect-line.db-num       =  factur-connect.db-num
         and factur-connect-line.connect-code = factur-connect.connect-code
    :
      delete factur-connect-line.
      vDeleted = vDeleted + 1.
    end.
    for each factur-connect-line-attr exclusive-lock where
             factur-connect-line-attr.db-num       =  factur-connect.db-num
         and factur-connect-line-attr.connect-code = factur-connect.connect-code
    :
      delete factur-connect-line-attr.
      vDeleted = vDeleted + 1.
    end.
    delete factur-connect.
    vDeleted = vDeleted + 1.
  end.
end procedure.