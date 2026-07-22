block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: auaddsum.p $
$Archive: utl/auaddsum.p $

Расчет сумм для всех закрытых документов инвентаризации данной БД

Автор: Суслов Алексей Юрьевич
Дата создания: 09/19/05
Author: Alexey Suslov
Creation date: 09/19/05

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: auaddsum.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/auaddsum.p $":U .
define variable vss-description as character no-undo init "Утилита по расчету дополнительных сумм по документу".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/trdcalib.i }
{ gbl/waitfram.i noprocess }
define buffer bf_trn-doc  for ub.trn-doc.
define buffer bf_clients  for ub.clients.
define buffer bf_db       for ub.db.
define variable varvalue       like ub.doc-attr.attr-value no-undo.
define variable vartype        as character                no-undo.
do on error undo, return error return-value :
run waitfram-show in this-procedure ("").
for each bf_db on error undo, return error return-value :
  for each bf_clients where bf_clients.db-num = bf_db.db-num on error undo, return error return-value :
    for each bf_trn-doc where bf_trn-doc.obj-type = bf_clients.obj-type and
                              bf_trn-doc.obj-code = bf_clients.obj-code and
                              bf_trn-doc.internal = no                  and
                              bf_trn-doc.doc-type = {&inventory}        and
                              bf_trn-doc.status_  = {&fact}             on error undo, return error return-value :
       run waitfram-show in this-procedure (substitute ("Объект: &1 &2. Документ &3.", bf_clients.obj-type, bf_clients.obj-code, bf_trn-doc.doc-code)).
       { str/tdat-val.i
           bf_trn-doc.doc-code
           {&trdcattr-addsum}
           varvalue
           vartype
           no-error
       }
       if error-status:error then do:
         message "Ошибка при считывании атрибутов документа " bf_trn-doc.doc-code " ." skip
                 "Прерываем расчет сумм." skip
                 return-value skip
                 error-status:get-message(1)
         view-as alert-box.
         return error.
       end.
       if lookup ({&sum-before-doc},  varvalue) = 0 or
          lookup ({&sum-general-doc}, varvalue) = 0 or
          lookup ({&sum-after-doc},   varvalue) = 0 then do:
          run utl/uaddsum.p (input bf_trn-doc.doc-code, no, ?, ?) no-error.
          if error-status:error then do:
            message "Ошибка при расчете сумм документа " bf_trn-doc.doc-code " ." skip
                    "Прерываем расчет сумм." skip
                    return-value skip
                    error-status:get-message(1)
            view-as alert-box.
            return error.
          end.
       end.
    end.
  end.
end.
run waitfram-hide in this-procedure.
end.
