block-level on error undo, throw.
/*

Чистка УБД. Мат. ценности с историей.

Автор: Ростовцев Александр
Дата создания: 17/09/2025
Author: Aleksandr Rostovtsev
Creation date: 09/17/25
*/

&scop Tables Мат. ценности
/*&scop Tables wth-doc ~*/
/*wth-doc-attr ~        */
/*wth-line ~            */
/*wth-line-attr ~       */
/*wth-dtl ~             */
/*wth-dtl-attr ~        */
/*wth-parts ~           */
/*wth-parts-attr ~      */
/*chk-doc ~             */
/*chk-doc-attr ~        */
/*c-chk-doc ~           */
/*c-chk-doc-attr ~      */
/*chk-pay ~             */
/*c-chk-pay ~           */
/*chk-pay-attr          */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 17/09/2025":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00193000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00193000.p $".
define variable vss-description as character no-undo init "Файл пирога чистки БД.".

define buffer wth-doc for ub.wth-doc.
define buffer buf_wth-doc for ub.wth-doc.

define stream LogStream.

on delete of ub.wth-doc   override do: end.

{ cmp/str-glbl.i }
{ cleandb/defs.i }

for each buf_clients no-lock
   where buf_clients.db-num <> ?
:
  for each wth-doc no-lock where
           wth-doc.host-code = buf_clients.host-code
       and wth-doc.obj-type  = buf_clients.obj-type
       and wth-doc.obj-code  = buf_clients.obj-code
       and wth-doc.status_   = {&fact}
       and wth-doc.fact-date < vardate-actual-docs
  use-index stat-fact
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) 
  :
    run cleanTables in this-procedure.
    { cleandb/delmainrec.i wth-doc}
  end.
end.

{cleandb/setresval.i}
return vResult.

procedure cleanTables :
    {cleandb/dellinkrec.i 
      wth-doc-attr 
      " where wth-doc-attr.doc-code = wth-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
      wth-line
      " where wth-line.doc-code = wth-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
      wth-line-attr
      " where wth-line-attr.doc-code = wth-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
      wth-dtl
      " where wth-dtl.doc-code = wth-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
      wth-dtl-attr
      " where wth-dtl-attr.doc-code = wth-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
      wth-parts      
      " where wth-parts.out-code = wth-doc.doc-code"
    }
/*  в коде эта таблица вообще не используется              */
/*    {cleandb/dellinkrec.i                                */
/*      wth-parts-attr                                     */
/*      " where wth-parts-attr.doc-code = wth-doc.doc-code"*/
/*    }                                                    */
    {cleandb/dellinkrec.i 
      chk-doc
      " where chk-doc.out-code = wth-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
      c-chk-doc      
      " where c-chk-doc.out-code = wth-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
      chk-doc-attr
      " where chk-doc-attr.out-code = wth-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
      c-chk-doc-attr 
      " where c-chk-doc-attr.out-code = wth-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
      chk-pay
      " where chk-pay.out-code = wth-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
      c-chk-pay
      " where c-chk-pay.out-code = wth-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
      chk-pay-attr
      " where chk-pay-attr.out-code = wth-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
      doc-attr 
      " where doc-attr.doc-code = wth-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
      c-doc-attr 
      " where c-doc-attr.doc-code = wth-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
      c-wth-doc 
      " where c-wth-doc.doc-code = wth-doc.doc-code"
    }
    {cleandb/dellinkrec.i 
      c-wth-line 
      " where c-wth-line.doc-code = wth-doc.doc-code"
    }
    
    define buffer c-wth-dtl     for ub.c-wth-dtl.
    on delete of ub.c-wth-dtl    override do: end.
    for each c-wth-dtl exclusive-lock
       where c-wth-dtl.doc-code         = wth-doc.doc-code
    on error undo, return error
    :
      {cleandb/dellinkrec.i 
        c-wth-parts 
        "where c-wth-parts.obj-type = wth-doc.obj-type
           and c-wth-parts.obj-code = wth-doc.obj-code
           and c-wth-parts.w-p-code = c-wth-dtl.w-p-code
           and c-wth-parts.wth-code = c-wth-dtl.wth-code
           and c-wth-parts.par-code = c-wth-dtl.par-code
           and c-wth-parts.out-code = wth-doc.doc-code"
      }
      delete c-wth-dtl.
      vDeleted = vDeleted + 1.
    end.  /* for each c-wth-dtl */
end procedure.