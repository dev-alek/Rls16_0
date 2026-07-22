block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: 2014/01/27 14:27:46 $
$Workfile: calc-trn.p $
$Archive: gbl/calc-trn.p $

Пересчет накладных по ее RECID без shared переменных.

Автор: Чернова Светлана Александровна
Дата создания: 10/05/06
Author: Svetlana Chernova
Creation date: 10/05/06

create Суслов А.
*/

define input parameter parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter parrec-doc as recid no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: 2014/01/27 14:27:46 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: calc-trn.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/calc-trn.p $":U .
define variable vss-description as character no-undo initial "Пересчет накладных по ее RECID без shared переменных.":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/lib-trn.i  }
{ gbl/waitfram.i noprocess }

define buffer t-doc for ub.trn-doc.
define variable v-recalc as logical   no-undo .

find t-doc exclusive-lock where recid(t-doc) = parrec-doc.
t-doc.bge-date = ? .
if t-doc.doc-type = {&income} and
   not t-doc.internal         then do:
   { str/calc-in.i
     parparentproc
     recid(t-doc)
     this-procedure
     no-error
   }
end.
else do:
  if t-doc.doc-type = {&inventory} then do:
    { str/calc-inv.i
      recid(t-doc)
      this-procedure
      no-error
    }
    if t-doc.status_ = {&fact} then do:
      run utl/uaddsum.p (
                       input t-doc.doc-code
                      ,input no
                      ,input no
                      ,input no
                       ).
    end.
  end.
  else do:
     if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} and
        ( (t-doc.status_ = {&wayb} and t-doc.flag_ = true ) or
           t-doc.status_ = {&permitted} or
           t-doc.status_ = {&fact} )
     then v-recalc = false .
     else v-recalc = true  .

    { str/calc-out.i
      recid(t-doc)
      v-recalc
      this-procedure
      no-error
    }
  end.
end.
if error-status :error then do:
   message "Ошибка при пересчете документа!!!" skip
           "calc-trn.p" skip
           error-status :get-message(1) skip
           return-value
           view-as alert-box error.
   return error.
end.