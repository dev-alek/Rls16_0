block-level on error undo, throw.
/*

Чистка БД. Документы доп.расходов.

Автор: Ростовцев Александр
Дата создания: 03/10/2025
Author: Aleksandr Rostovtsev
Creation date: 10/03/25
*/

&scop Tables Документы доп.расходов с историей
/*&scop Tables add-doc ~*/
/*add-line ~            */
/*add-trn ~             */
/*add-trn-attr ~        */
/*c-add-doc ~           */
/*c-add-line            */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 03/10/2025":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00230000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00230000.p $".
define variable vss-description as character no-undo init "Файл пирога чистки БД.".
{ cmp/str-glbl.i }
{ cleandb/defs.i }

define buffer add-doc                for ub.add-doc                  .
define buffer buf_add-doc            for ub.add-doc                  .

on delete of ub.add-doc               override do: end.

for each buf_clients no-lock
   where buf_clients.db-num <> ?
:
  for each add-doc no-lock where 
           add-doc.obj-type   = buf_clients.obj-type
       and add-doc.obj-code   = buf_clients.obj-code 
       and add-doc.status_    = {&act-overvalue}
       and add-doc.fact-date  < vardate-actual-docs
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    run cleanTables in this-procedure.
    { cleandb/delmainrec.i add-doc}
  end.
end.

{cleandb/setresval.i}
return vResult.


procedure cleanTable :
  {cleandb/dellinkrec.i 
    c-add-doc  
    " where c-add-doc.doc-code = add-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
    add-line  
    " where add-line.doc-code = add-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
    c-add-line  
    " where c-add-line.doc-code = add-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
    add-trn  
    " where add-trn.doc-code = add-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
    add-trn-attr  
    " where add-trn-attr.doc-code = add-doc.doc-code"
  }
end procedure.