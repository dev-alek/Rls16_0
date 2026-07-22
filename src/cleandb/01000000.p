block-level on error undo, throw.
/*

Чистка БД. УПД. 

Автор: Ростовцев Александр
Дата создания: 13/10/2025
Author: Aleksandr Rostovtsev
Creation date: 10/13/25
*/

&scop Tables Упд с историей
/*&scop Tables utd ~     */
/*utd-attr ~             */
/*utd-err ~              */
/*utd-err-attr ~         */
/*utd-line ~             */
/*utd-line-attr ~        */
/*utd-marking-line ~     */
/*utd-marking-line-attr ~*/
/*c-utd-head ~           */
/*c-utd ~                */
/*c-utd-attr ~           */
/*c-utd-err ~            */
/*c-utd-err-attr ~       */
/*c-utd-line ~           */
/*c-utd-line-attr ~      */
/*c-utd-marking-line ~   */
/*c-utd-marking-line-attr*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 13.10.2025 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 01000000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/01000000.p $".
define variable vss-description as character no-undo init "Чистка УБД..".
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cleandb/defs.i }


define buffer utd            for ub.utd.
define buffer buf_utd        for ub.utd.

on delete of ub.utd       override do: end.

for each buf_clients no-lock where 
         buf_clients.db-num <> ?
:
  for each utd no-lock
     where utd.host-code    = buf_clients.host-code
       and utd.DocumentDate < vardate-actual-docs
       and utd.sts          = 8
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    run cleanTable in this-procedure.
    { cleandb/delmainrec.i utd}
  end.
end.

{cleandb/setresval.i}
return vResult.

procedure cleanTable:
  {cleandb/dellinkrec.i 
    utd-attr  
    " where utd-attr.db-num = utd.db-num 
        and utd-attr.doc-id = utd.doc-id"
  }
  {cleandb/dellinkrec.i 
    utd-err  
    " where utd-err.db-num = utd.db-num 
        and utd-err.doc-id = utd.doc-id"
  }
  {cleandb/dellinkrec.i 
    utd-err-attr  
    " where utd-err-attr.db-num = utd.db-num 
        and utd-err-attr.doc-id = utd.doc-id"
  }
  {cleandb/dellinkrec.i 
    utd-lines  
    " where utd-lines.db-num = utd.db-num 
        and utd-lines.doc-id = utd.doc-id"
  }
  {cleandb/dellinkrec.i 
    utd-lines-attr  
    " where utd-lines-attr.db-num = utd.db-num 
        and utd-lines-attr.doc-id = utd.doc-id"
  }
  {cleandb/dellinkrec.i 
    utd-marking-lines  
    " where utd-marking-lines.db-num = utd.db-num 
        and utd-marking-lines.doc-id = utd.doc-id"
  }
  {cleandb/dellinkrec.i 
    utd-marking-lines-attr  
    " where utd-marking-lines-attr.db-num = utd.db-num 
        and utd-marking-lines-attr.doc-id = utd.doc-id"
  }
  {cleandb/dellinkrec.i 
    c-utd  
    " where c-utd.db-num = utd.db-num 
        and c-utd.doc-id = utd.doc-id"
  }
  {cleandb/dellinkrec.i 
    c-utd-head  
    " where c-utd-head.db-num = utd.db-num 
        and c-utd-head.doc-id = utd.doc-id"
  }
  {cleandb/dellinkrec.i 
    c-utd-attr  
    " where c-utd-attr.db-num = utd.db-num 
        and c-utd-attr.doc-id = utd.doc-id"
  }
  {cleandb/dellinkrec.i 
    c-utd-err  
    " where c-utd-err.db-num = utd.db-num 
        and c-utd-err.doc-id = utd.doc-id"
  }
  {cleandb/dellinkrec.i 
    c-utd-err-attr  
    " where c-utd-err-attr.db-num = utd.db-num 
        and c-utd-err-attr.doc-id = utd.doc-id"
  }
  {cleandb/dellinkrec.i 
    c-utd-lines  
    " where c-utd-lines.db-num = utd.db-num 
        and c-utd-lines.doc-id = utd.doc-id"
  }
  {cleandb/dellinkrec.i 
    c-utd-lines-attr  
    " where c-utd-lines-attr.db-num = utd.db-num 
        and c-utd-lines-attr.doc-id = utd.doc-id"
  }
  {cleandb/dellinkrec.i 
    c-utd-marking-lines  
    " where c-utd-marking-lines.db-num = utd.db-num 
        and c-utd-marking-lines.doc-id = utd.doc-id"
  }
  {cleandb/dellinkrec.i 
    c-utd-marking-lines-attr  
    " where c-utd-marking-lines-attr.db-num = utd.db-num 
        and c-utd-marking-lines-attr.doc-id = utd.doc-id"
  }
end procedure.