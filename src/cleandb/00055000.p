block-level on error undo, throw.
/*

Чистка УБД. Документы производства, Документы план-меню

Автор: Ростовцев Александр
Дата создания: 16/09/2025
Author: Aleksandr Rostovtsev
Creation date: 09/16/25
*/

&scop Tables Документы производства с историей ~
Документы план-меню c историей
/*&scop Tables fbr-doc ~*/
/*fbr-line ~            */
/*c-fbr-doc ~           */
/*c-fbr-line ~          */
/*fbr-pln ~             */
/*fbr-pln-line ~        */
/*c-fbr-pln ~           */
/*c-fbr-pln-line ~      */
/*fbr-history ~         */
/*recipe-develop ~      */
/*c-recipe-develop ~    */  
/*fbr-recipe-gds        */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: Sep 15 2025 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00055000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00055000.p $".
define variable vss-description as character no-undo init "Чистка УБД.".
{ cmp/str-glbl.i }
{ cleandb/defs.i }

define buffer fbr-doc      for ub.fbr-doc.
define buffer buf_fbr-doc  for ub.fbr-doc.
define buffer fbr-pln      for ub.fbr-pln.
define buffer buf_fbr-pln  for ub.fbr-pln.

on delete of ub.fbr-doc override do: end.
on delete of ub.fbr-pln override do: end.

for each buf_clients no-lock
    where buf_clients.db-num <> ?
:
  for each fbr-doc no-lock
     where fbr-doc.obj-type  = buf_clients.obj-type
       and fbr-doc.obj-code  = buf_clients.obj-code
       and fbr-doc.fact-date < vardate-actual-docs
  on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    run cleanFbrTable in this-procedure.
    { cleandb/delmainrec.i fbr-doc}
  end.
  for each fbr-pln no-lock
     where fbr-pln.obj-type  = buf_clients.obj-type
       and fbr-pln.obj-code  = buf_clients.obj-code
       and fbr-pln.fact-date < vardate-actual-docs
  on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    run cleanPlnTable in this-procedure.
    { cleandb/delmainrec.i fbr-pln}
  end.
end.

{cleandb/setresval.i}
return vResult.

procedure cleanFbrTable :
  define buffer fbr-line       for ub.fbr-line.
  define buffer fbr-recipe     for ub.fbr-recipe.
  
  on delete of ub.fbr-line   override do: end.
  on delete of ub.fbr-recipe override do: end.
  
  for each fbr-line exclusive-lock
     where fbr-line.doc-code = fbr-doc.doc-code
  :
    if fbr-line.recipe-code <> ? and
       fbr-line.recipe-code <> "":U
    then do:
      if fbr-line.is-comp = yes
      then do:
        {cleandb/dellinkrec.i 
          recipe-develop  
          "where recipe-develop.recipe-code = fbr-line.recipe-code 
             and recipe-develop.doc-code = fbr-line.doc-code"
        }
        {cleandb/dellinkrec.i 
          c-recipe-develop  
          "where c-recipe-develop.recipe-code = fbr-line.recipe-code 
             and c-recipe-develop.doc-code = fbr-line.doc-code"
        }
        for each fbr-recipe exclusive-lock
           where fbr-recipe.doc-code    = fbr-line.doc-code
             and fbr-recipe.recipe-code = fbr-line.recipe-code
        :
          {cleandb/dellinkrec.i 
            fbr-recipe-gds  
            "where fbr-recipe-gds.doc-code = fbr-recipe.doc-code 
               and fbr-recipe-gds.recipe-code = fbr-recipe.recipe-code"
          }
          delete fbr-recipe.
          vDeleted = vDeleted + 1.
        end.
      end.
    end.
    delete fbr-line.
    vDeleted = vDeleted + 1.
  end. 

  {cleandb/dellinkrec.i 
    doc-attr  
    "where doc-attr.doc-code = fbr-doc.doc-code"
  }

  {cleandb/dellinkrec.i 
    c-fbr-doc  
    "where c-fbr-doc.doc-code = fbr-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
    c-doc-attr  
    "where c-doc-attr.doc-code = fbr-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
    c-fbr-line  
    "where c-fbr-line.doc-code = fbr-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
    fbr-history  
    "where fbr-history.obj-type = fbr-doc.obj-type ~
and fbr-history.obj-code = fbr-doc.obj-code ~
and fbr-history.doc-code = fbr-doc.doc-code"
  }
end procedure.

procedure cut-pln-table :
  define buffer fbr-pln-line   for ub.fbr-pln-line.
  
  on delete of ub.fbr-pln-line override do: end.
  
  {cleandb/dellinkrec.i 
    c-fbr-pln  
    " where c-fbr-pln.doc-code  = fbr-pln.doc-code"
  }

  for each fbr-pln-line exclusive-lock
     where fbr-pln-line.doc-code = fbr-pln.doc-code
  :
    {cleandb/dellinkrec.i 
      c-fbr-pln-line  
      " where c-fbr-pln-line.doc-code     = fbr-pln.doc-code and~
              c-fbr-pln-line.fbr-obj-type = fbr-pln-line.fbr-obj-type  and~
              c-fbr-pln-line.fbr-obj-code = fbr-pln-line.fbr-obj-code  and~
              c-fbr-pln-line.gds-code     = fbr-pln-line.gds-code      and~
              c-fbr-pln-line.recipe-code  = fbr-pln-line.recipe-code"
    }
    delete fbr-pln-line.
    vDeleted = vDeleted + 1.
  end.

  {cleandb/dellinkrec.i 
    fbr-history  
    " where fbr-history.obj-type = fbr-pln.obj-type~
        and fbr-history.obj-code = fbr-pln.obj-code~
        and fbr-history.doc-code = fbr-pln.doc-code"
  }
end procedure.
