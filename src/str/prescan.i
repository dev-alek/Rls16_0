/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка документа перед использованием мобильного сканера для ФАКТ приемки

Автор: Чернова Светлана Александровна
Дата создания: 03/24/05
Author: Svetlana Chernova
Creation date: 03/24/05

Автор1: Суслов Алексей Юрьевич

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure prescan:
define input parameter parrec-doc as recid no-undo.
define buffer ps_trn-doc  for ub.trn-doc.
define buffer ps_doc-line for ub.doc-line.
define buffer ps_gds-dtl  for ub.gds-dtl.
define buffer ps_parts    for ub.parts.
define variable to-null as logical no-undo.
define variable g-log   as logical no-undo.
do on error undo, return error return-value :
find first ps_trn-doc where recid (ps_trn-doc) = parrec-doc.
if (ps_trn-doc.doc-type = {&income} and
    ps_trn-doc.status_  = {&wayb}   and
    ps_trn-doc.flag_)                     or
   (can-do ({&expense_write-off_return}, ps_trn-doc.doc-type) and
    ps_trn-doc.status_ = {&permitted}                            ) then do:
  if can-find (first ps_doc-line where ps_doc-line.doc-code   = ps_trn-doc.doc-code and
                                       ps_doc-line.fact-qnty <> 0 no-lock)          then do:
    assign
      to-null = yes.
  end.
  else do:
    assign
      to-null = no.
  end.
  assign
    g-log = no.
  if to-null then do:
    message "Для приемки товара с использованием мобильного сканера"
            "фактические количества товара в документе должны быть обнулены." skip
            "При повторном использовании сканера для того же документа обнуление не требуется." skip (2)
            "Обнулить ФАКТ количества в документе ?"
    view-as alert-box question buttons yes-no update g-log.
  end.
  else do:
    message "В документе все ФАКТ количества нулевые."
             "Сделать их равными количествам товара по документу ?"
    view-as alert-box question buttons yes-no update g-log.
  end.
  if g-log then do:
    for each ps_doc-line where ps_doc-line.doc-code = ps_trn-doc.doc-code on error undo, return error return-value :
      assign
        ps_doc-line.fact-qnty = (if to-null then 0 else ps_doc-line.doc-qnty).
      { str/lnfactqt.i
        parparentproc
        recid(ps_doc-line)
        no
        ps_trn-doc.status_
        ps_trn-doc.flag_
        no-error }
      if error-status:error then do:
        undo, return error substitute("Ошибка при изменении &1 фактического количества по товару: &2 &3 &4 ",
                                      return-value,
                                      ps_doc-line.artic,
                                      ps_doc-line.prod-type,
                                      ps_doc-line.prod-code).
      end.
    end.

    for each ps_gds-dtl where ps_gds-dtl.doc-code = ps_trn-doc.doc-code:
      assign
        ps_gds-dtl.fact-qnty  = (if to-null then 0 else ps_gds-dtl.doc-qnty).
    end.
    for each ps_parts where ps_parts.out-code = ps_trn-doc.doc-code:
      assign
        ps_parts.fact-qnty = if to-null then 0 else ps_parts.qnty.
    end.
  end.
end.
end.
end procedure.
/* $Workfile$ e n d */