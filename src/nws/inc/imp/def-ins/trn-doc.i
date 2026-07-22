/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_doc-line                for ub.doc-line.
define buffer buf_doc-line-attr           for ub.doc-line-attr.
define buffer buf_inv-line                for ub.inv-line.
define buffer buf_doc-line-sum            for ub.doc-line-sum.
define buffer buf_inv-doc                 for ub.inv-doc.
define buffer buf_goods                   for ub.goods .
define buffer buf_trn-doc-sum             for ub.trn-doc-sum.
define buffer buf_gds-dtl                 for ub.gds-dtl.
define buffer buf_parts                   for ub.parts.
define buffer buf_marking-lines           for ub.marking-lines.
define buffer buf_gen-attr                for ub.gen-attr.
define buffer buf_doc-prts                for ub.doc-prts.
define buffer buf_doc-pl                  for ub.doc-pl.
define buffer buf_doc-pl-attr             for ub.doc-pl-attr.
define buffer buf_doc-pl-pump             for ub.doc-pl-pump.
define buffer buf_parts-attr              for ub.parts-attr.
define buffer buf_parts-supp              for ub.parts-supp.
define buffer buf_parts-root              for ub.parts-root.
define buffer buf_doc-attr                for ub.doc-attr.
define buffer buf_ord-chain               for ub.ord-chain.
define buffer buf_doc-fbr-gds             for ub.doc-fbr-gds.
define buffer buf_arh-trn-doc-contract    for ub.arh-trn-doc-contract.
define buffer buf-rc_arh-trn-doc-contract for ub.arh-trn-doc-contract.

define variable varrecalc-arh-trn-doc as logical no-undo.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.

for each locb-doc-line
on error  undo, return error
:
  delete locb-doc-line.
end.

for each locb-doc-line-attr
on error  undo, return error
:
  delete locb-doc-line-attr.
end.
for each locb-inv-doc
on error  undo, return error
:
  delete locb-inv-doc.
end.
for each locb-trn-doc-sum
on error  undo, return error
:
  delete locb-trn-doc-sum.
end.

for each locb-inv-line
on error  undo, return error
:
  delete locb-inv-line.
end.
for each locb-doc-line-sum
on error  undo, return error
:
  delete locb-doc-line-sum.
end.

for each locb-gds-dtl
on error  undo, return error
:
  delete locb-gds-dtl.
end.
for each locb-parts
on error  undo, return error
:
  delete locb-parts.
end.
for each locb-parts-attr
on error  undo, return error
:
  delete locb-parts-attr.
end.
for each locb-parts-root
on error  undo, return error
:
  delete locb-parts-root.
end.
for each locb-parts-supp
on error  undo, return error
:
  delete locb-parts-supp.
end.
for each locb-doc-prts
on error  undo, return error
:
  delete locb-doc-prts.
end.
for each locb-doc-pl
on error  undo, return error
:
  delete locb-doc-pl.
end.
for each locb-doc-pl-pump
on error  undo, return error
:
  delete locb-doc-pl-pump.
end.
for each locbt-doc-attr
on error  undo, return error
:
  delete locbt-doc-attr.
end.
for each locb-ord-chain
on error  undo, return error
:
  delete locb-ord-chain.
end.

for each locb-doc-fbr-gds
on error  undo, return error
:
  delete locb-doc-fbr-gds.
end.

for each locb-arh-trn-doc-contract
on error undo, return error
:
  delete locb-arh-trn-doc-contract.
end.

for each locb-gen-attr
on error  undo, return error
:
  delete locb-gen-attr.
end.

for each locb-marking-lines
on error  undo, return error
:
  delete locb-marking-lines.
end.