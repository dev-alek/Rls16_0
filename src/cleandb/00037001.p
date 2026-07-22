block-level on error undo, throw.
/*

Чистка УБД. Документы  инв. счетчиков ТРК

Автор: Ростовцев Александр
Дата создания: 12/09/2025
Author: Aleksandr Rostovtsev
Creation date: 09/12/25
*/

&scop Tables Документы  инв. счетчиков ТРК
/*&scop Tables icnt-doc ~*/
/*icnt-line              */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: Sep 25 2025 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00037001.p $":U .
define variable vss-archive     as character no-undo init "$Archive: clendb/00037001.p $".
define variable vss-description as character no-undo init "Чистка УБД.".
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i  }
{ cleandb/defs.i }

define variable v-beg-fact-order as integer no-undo .

define buffer icnt-doc       for ub.icnt-doc.
define buffer buf_icnt-doc   for ub.icnt-doc.
define buffer next-icnt-doc  for ub.icnt-doc.
define buffer icnt-line      for ub.icnt-line.
define buffer next-icnt-line for ub.icnt-line.
define variable varfind-next-line as logical no-undo.

on delete of ub.icnt-doc  override do: end.

run day-begin-fact-order in this-procedure
    ( input vardate-actual-docs
     ,output v-beg-fact-order)
.

for each buf_clients no-lock
   where buf_clients.db-num <> ?
:
    for each icnt-doc no-lock where 
             icnt-doc.obj-type  =  buf_clients.obj-type 
         and icnt-doc.obj-code  =  buf_clients.obj-code 
         and icnt-doc.status_   =  {&fact}
         and icnt-doc.fact-date < vardate-actual-docs              
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
    icnt-line:
    for each icnt-line exclusive-lock where 
             icnt-line.doc-code = icnt-doc.doc-code 
    :
      varfind-next-line = no.
      for first next-icnt-doc where next-icnt-doc.obj-type   = icnt-doc.obj-type   and
                                    next-icnt-doc.obj-code   = icnt-doc.obj-code   and
                                    next-icnt-doc.status_    = {&fact}                 and
                                    next-icnt-doc.fact-order > icnt-doc.fact-order no-lock,
          first next-icnt-line where next-icnt-line.doc-code    = next-icnt-doc.doc-code and
                                     next-icnt-line.obj-type    = icnt-line.obj-type     and
                                     next-icnt-line.obj-code    = icnt-line.obj-code     and
                                     next-icnt-line.pump-code   = icnt-line.pump-code    and
                                     next-icnt-line.nozzle-code = icnt-line.nozzle-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        varfind-next-line = yes.
      end.
      if varfind-next-line = no then do:
        run cleanTable in this-procedure.
        { cleandb/delmainrec.i icnt-doc}
        leave icnt-line.
      end.
    end.
  end.
end.
{cleandb/setresval.i}
return vResult.

procedure cleanTable:
  {cleandb/dellinkrec.i 
    icnt-line  
    " where icnt-line.doc-code = icnt-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
    doc-attr  
    " where doc-attr.doc-code = icnt-doc.doc-code"
  }
  {cleandb/dellinkrec.i 
    c-doc-attr  
    " where c-doc-attr.doc-code = icnt-doc.doc-code"
  }
end procedure.