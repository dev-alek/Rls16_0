block-level on error undo, throw.
/*

$Revision: 2df3cb32ffae, 112, rls $
$Author: EShklyar $
$Date: Tue Dec 23 19:14:15 2014 +0300 $
$Workfile: invddsum.p $
$Archive: utl/invddsum.p $

Утилита пересчета дополнительных сумм по одной инвентаризации

Автор: Гридчина Полина Дмитриевна
Дата создания: 12/04/11
Author: Alexey Suslov
Creation date: 12/04/11


*/

define input parameter pardoc-code               like ub.trn-doc.doc-code no-undo.

define variable vss-revision    as character no-undo initial "$Revision: 2df3cb32ffae, 112, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Tue Dec 23 19:14:15 2014 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: invddsum.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/invddsum.p $":U .
define variable vss-description as character no-undo initial "Утилита по расчету дополнительных сумм по документу":U .

def var p-ok as log no-undo.
for first ub.trn-doc where ub.trn-doc.doc-code = pardoc-code:
   p-ok = yes.
   for each ub.doc-line-sum where  ub.doc-line-sum.doc-code = pardoc-code:
      delete ub.doc-line-sum.
   end.
   run utl/uaddsum.p(pardoc-code,yes,yes,no) no-error.
   if error-status:error then do:
       message error-status:get-message(1) view-as alert-box.
       return.
   end.
end.
  if not p-ok then message "Документ не найден" view-as alert-box error.