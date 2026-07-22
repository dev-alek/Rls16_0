block-level on error undo, throw.
/*

Чистка УБД. Документы на кассе.

Автор: Ростовцев Александр
Дата создания: 17/09/2025
Author: Aleksandr Rostovtsev
Creation date: 09/17/25
*/

&scop Tables Документы на кассе с историей
/*&scop Tables cd-doc ~*/
/*cd-doc-attr ~        */
/*c-cd-doc ~           */
/*cd-doc-line ~        */
/*cd-doc-line-attr ~   */
/*c-cd-doc-line ~      */
/*cd-event-log ~       */
/*cd-event-log-attr    */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: Sep 17 2025  $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00061000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00061000.p $":U .
define variable vss-description as character no-undo init "Чистка УБД1.".

{ cmp/str-glbl.i }
{ cleandb/defs.i }

define buffer cd-doc            for ub.cd-doc.
define buffer buf_cd-doc        for ub.cd-doc.
define buffer cd-event-log      for ub.cd-event-log.
define buffer buf_cd-event-log  for ub.cd-event-log.

on delete of ub.cd-doc            override do: end.
on delete of ub.cd-event-log      override do: end.

for each buf_clients no-lock
    where buf_clients.db-num <> ?
:
  for each cd-doc no-lock where 
           cd-doc.obj-type    = buf_clients.obj-type 
       and cd-doc.obj-code    = buf_clients.obj-code 
       and cd-doc.datekey_one < vardate-actual-docs
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    run cleanTable in this-procedure.
    { cleandb/delmainrec.i cd-doc}
  end.
  for each cd-event-log no-lock where 
           cd-event-log.obj-type   = buf_clients.obj-type  
       and cd-event-log.obj-code   = buf_clients.obj-code 
       and cd-event-log.event-date < vardate-actual-docs
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    {cleandb/dellinkrec.i 
      cd-event-log-attr  
      "where cd-event-log-attr.db-num   = cd-event-log.db-num~ 
         and cd-event-log-attr.trans-id = cd-event-log.trans-id"
    }
    { cleandb/delmainrec.i cd-event-log }
  end.
end.
{cleandb/setresval.i}
return vResult.

procedure cleanTable :
  {cleandb/dellinkrec.i 
    cd-doc-attr  
    "where cd-doc-attr.obj-type = cd-doc.obj-type~
       and cd-doc-attr.obj-code = cd-doc.obj-code~
       and cd-doc-attr.pos-type = cd-doc.pos-type~
       and cd-doc-attr.doc-type = cd-doc.doc-type~
       and cd-doc-attr.doc-code = cd-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
    cd-doc-line  
    "where cd-doc-line.obj-type = cd-doc.obj-type~
       and cd-doc-line.obj-code = cd-doc.obj-code~
       and cd-doc-line.pos-type = cd-doc.pos-type~
       and cd-doc-line.doc-type = cd-doc.doc-type~
       and cd-doc-line.doc-code = cd-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
    cd-doc-line-attr 
    "where cd-doc-line-attr.obj-type = cd-doc.obj-type~
       and cd-doc-line-attr.obj-code = cd-doc.obj-code~
       and cd-doc-line-attr.pos-type = cd-doc.pos-type~
       and cd-doc-line-attr.doc-type = cd-doc.doc-type~
       and cd-doc-line-attr.doc-code = cd-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
    c-cd-doc 
    "where c-cd-doc.obj-type = cd-doc.obj-type~
       and c-cd-doc.obj-code = cd-doc.obj-code~
       and c-cd-doc.pos-type = cd-doc.pos-type~
       and c-cd-doc.doc-type = cd-doc.doc-type~
       and c-cd-doc.doc-code = cd-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
    c-cd-doc-line 
    "where c-cd-doc-line.obj-type = cd-doc.obj-type~
       and c-cd-doc-line.obj-code = cd-doc.obj-code~
       and c-cd-doc-line.pos-type = cd-doc.pos-type~
       and c-cd-doc-line.doc-type = cd-doc.doc-type~
       and c-cd-doc-line.doc-code = cd-doc.doc-code"
  }
end procedure.