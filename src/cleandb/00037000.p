block-level on error undo, throw.
/*

Чистка БД. Документы сверки с историей. 

Автор: Ростовцев Александр
Дата создания: 12/09/2025
Author: Aleksandr Rostovtsev
Creation date: 09/12/25
*/

&scop Tables Документы сверки с историей
/*&scop Tables rvs-doc ~*/
/*rvs-doc-attr ~        */
/*rvs-line ~            */
/*rvs-line-attr ~       */
/*rvs-line-pump ~       */
/*rvs-line-pump-attr ~  */
/*rvs-pump ~            */
/*rvs-pump-attr         */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: Sep 12 2025 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00037000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00037000.p $".
define variable vss-description as character no-undo init "Чистка УБД..".
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i  }
{ cleandb/defs.i }


define variable v-beg-fact-order as integer no-undo .
define buffer rvs-doc            for ub.rvs-doc.
define buffer buf_rvs-doc        for ub.rvs-doc.

on delete of ub.rvs-doc       override do: end.

run day-begin-fact-order in this-procedure
  ( input vardate-actual-docs
    ,output v-beg-fact-order
  ).

for each buf_clients no-lock
   where buf_clients.db-num <> ?
:
  for each rvs-doc no-lock
     where rvs-doc.obj-type   = buf_clients.obj-type
       and rvs-doc.obj-code   = buf_clients.obj-code
       and rvs-doc.status_    = {&fact}
       and rvs-doc.fact-order < v-beg-fact-order
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    run cleanTable in this-procedure.
    { cleandb/delmainrec.i rvs-doc}
  end.
end.

{cleandb/setresval.i}
return vResult.

procedure cleanTable:
  {cleandb/dellinkrec.i 
    rvs-line  
    " where rvs-line.rvs-code = rvs-doc.rvs-code"
  }
  {cleandb/dellinkrec.i 
    rvs-line-attr 
    " where rvs-line-attr.rvs-code = rvs-doc.rvs-code"
  }
  {cleandb/dellinkrec.i 
    rvs-line-pump 
    " where rvs-line-pump.rvs-code = rvs-doc.rvs-code"
  }
  {cleandb/dellinkrec.i 
    rvs-line-pump-attr 
    " where rvs-line-pump-attr.rvs-code = rvs-doc.rvs-code"
  }
  {cleandb/dellinkrec.i 
    rvs-pump 
    " where rvs-pump.rvs-code = rvs-doc.rvs-code"
  }
  {cleandb/dellinkrec.i 
    rvs-pump-attr 
    " where rvs-pump-attr.rvs-code = rvs-doc.rvs-code"
  }
  {cleandb/dellinkrec.i 
    rvs-doc-attr 
    " where rvs-doc-attr.rvs-code = rvs-doc.rvs-code"
  }
  {cleandb/dellinkrec.i 
    doc-attr  
    " where doc-attr.doc-code = rvs-doc.rvs-code"
  }
  {cleandb/dellinkrec.i 
    c-doc-attr  
    " where c-doc-attr.doc-code = rvs-doc.rvs-code"
  }
  {cleandb/dellinkrec.i 
    c-rvs-doc 
    " where c-rvs-doc.rvs-code = rvs-doc.rvs-code"
  }
  {cleandb/dellinkrec.i 
    c-rvs-line  
    " where c-rvs-line.rvs-code = rvs-doc.rvs-code"
  }
  {cleandb/dellinkrec.i 
    c-rvs-line-pump  
    " where c-rvs-line-pump.rvs-code = rvs-doc.rvs-code"
  }
end procedure.