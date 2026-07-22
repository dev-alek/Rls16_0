block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: calc-hd.p $
$Archive: str/calc-hd.p $

Пересчет шапки документа в учетных ценах, расчет величины автоматической переоценки

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/

define input parameter v-doc-code like ub.trn-doc.doc-code no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: calc-hd.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/calc-hd.p $":U .
define variable vss-description as character no-undo initial "Пересчет шапки документа в учетных ценах, расчет величины автоматической переоценки":U .

{ cmp/vssrevis.i "substitute('&1':U,v-doc-code)" }
{ cmp/str-glbl.i }
{ str/lib-trn.i  }

define variable v-total-doc-line_tot-ov    like ub.trn-doc.tot-ov    no-undo.
define variable v-total-doc-line_fact-rubl like ub.trn-doc.fact-rubl no-undo.
define variable v-total-doc-line_fact-base like ub.trn-doc.fact-base no-undo.
define variable v-total-doc-line_fact-qnty like ub.trn-doc.fact-qnty no-undo.
define variable v-total-doc-line_doc-qnty  like ub.trn-doc.doc-qnty  no-undo.
define variable v-total-doc-line_cli-qnty  like ub.trn-doc.cli-qnty  no-undo.
define variable v-total-trn-doc_tot-ov     like ub.trn-doc.tot-ov    no-undo.
define variable v-total-trn-doc_fact-rubl  like ub.trn-doc.fact-rubl no-undo.
define variable v-total-trn-doc_fact-base  like ub.trn-doc.fact-base no-undo.
define variable v-total-trn-doc_fact-qnty  like ub.trn-doc.fact-qnty no-undo.
define variable v-total-trn-doc_doc-qnty   like ub.trn-doc.doc-qnty  no-undo.
define variable v-total-trn-doc_cli-qnty   like ub.trn-doc.cli-qnty  no-undo.

define buffer bf_goods for ub.goods.

do on error undo, return error return-value :
  assign
    v-total-trn-doc_tot-ov    = 0
    v-total-trn-doc_fact-rubl = 0
    v-total-trn-doc_fact-base = 0
    v-total-trn-doc_fact-qnty = 0
    v-total-trn-doc_doc-qnty  = 0
    v-total-trn-doc_cli-qnty  = 0
  .
  find first ub.trn-doc exclusive-lock where
             ub.trn-doc.doc-code = v-doc-code.

  if ub.trn-doc.doc-type <> {&inventory} then do:
    assign
      ub.trn-doc.doc-qnty  = 0.
  end.
  assign
    ub.trn-doc.fact-qnty = 0
    ub.trn-doc.cli-qnty  = 0
    ub.trn-doc.fact-base = 0
    ub.trn-doc.fact-rubl = 0
    ub.trn-doc.tot-ov    = 0
  .

  for each ub.doc-line no-lock where
           ub.doc-line.doc-code = ub.trn-doc.doc-code
  on error undo, return error return-value :
    find first bf_goods no-lock where
               bf_goods.artic     = ub.doc-line.artic     and
               bf_goods.prod-type = ub.doc-line.prod-type and
               bf_goods.prod-code = ub.doc-line.prod-code no-error.
    if not available bf_goods then do:
      return error substitute( "Не найден товар &1 &2 &3."
                             , ub.doc-line.artic
                             , ub.doc-line.prod-type
                             , ub.doc-line.prod-code ).
    end.
    { str/acc-cost.i
        ub.doc-line.obj-type
        ub.doc-line.obj-code
        ub.doc-line.doc-code
        ub.doc-line.artic
        ub.doc-line.prod-type
        ub.doc-line.prod-code
        ub.doc-line.cli-qnty
        ub.doc-line.doc-qnty
        ub.doc-line.fact-qnty
        ub.doc-line.price-base
        ub.doc-line.price-rubl
        "''"
        v-total-doc-line_tot-ov
        v-total-doc-line_fact-rubl
        v-total-doc-line_fact-base
        v-total-doc-line_fact-qnty
        v-total-doc-line_doc-qnty
        v-total-doc-line_cli-qnty
        no-error
     }
     if error-status :error then do:
       return error return-value.
     end.
     assign
       v-total-trn-doc_tot-ov    = v-total-trn-doc_tot-ov    + v-total-doc-line_tot-ov
       v-total-trn-doc_fact-rubl = v-total-trn-doc_fact-rubl + v-total-doc-line_fact-rubl
       v-total-trn-doc_fact-base = v-total-trn-doc_fact-base + v-total-doc-line_fact-base
       v-total-trn-doc_fact-qnty = v-total-trn-doc_fact-qnty + v-total-doc-line_fact-qnty
       v-total-trn-doc_doc-qnty  = v-total-trn-doc_doc-qnty  + v-total-doc-line_doc-qnty
       v-total-trn-doc_cli-qnty  = v-total-trn-doc_cli-qnty  + v-total-doc-line_cli-qnty
     .
  end. /* for each doc-line */

  { str/ass-cost.i
      recid(ub.trn-doc)
      v-total-trn-doc_tot-ov
      v-total-trn-doc_fact-rubl
      v-total-trn-doc_fact-base
      v-total-trn-doc_fact-qnty
      v-total-trn-doc_doc-qnty
      v-total-trn-doc_cli-qnty
      0
      0
      0
      0
      0
      0
      no-error
  }
  if error-status :error then do:
    undo, return error return-value.
  end.
end. /* on error */