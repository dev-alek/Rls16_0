block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: uinqinr.p $
$Archive: utl/uinqinr.p $

Утилита по исправлению внутренних расходов, сделаных в офисе запросом.

Автор: Суслов Алексей Юрьевич
Дата создания: 04/12/06
Author: Alexey Suslov
Creation date: 04/12/06

Глюк от 30 мая 2003 года
*/
{ cmp/str-glbl.i }
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_trn-doc for ub.trn-doc.
define buffer bf_parts   for ub.parts.
on write of ub.trn-doc override do:
end.
do on error undo, return error return-value :
  find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-error.
  if not available bf_trn-doc then do:
    message "Документ: " pardoc-code " не найден." view-as alert-box.
    return error.
  end.
  if bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} and
     bf_trn-doc.cr-db-num    = 0                  and
     bf_trn-doc.status_      <> {&fact}           and
     bf_trn-doc.status_      <> {&inquiry}        then do:
     find first bf_parts where bf_parts.out-code = bf_trn-doc.doc-code no-error.
     if available bf_parts then do:
       message "К документу " pardoc-code " есть привязанные партии." skip
               "Данный документ не может быть обработан данной утилитой." view-as alert-box.
       return error.
     end.
     else do:
       assign
         bf_trn-doc.status_ = {&inquiry}
         bf_trn-doc.flag_   = yes.
     end.
 end.
 else do:
   message "Этот документ не может быть обработан данной утилитой." view-as alert-box.
   return error.
 end.
end.