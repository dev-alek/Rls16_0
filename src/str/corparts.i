/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры для пересчета документа 'коррекции учетных цен'

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич


*/
procedure corparts_clc-doc :
define input parameter parrec-id as recid no-undo.
define buffer bf_trn-doc  for ub.trn-doc.
define buffer bf_doc-line for ub.doc-line.
do on error undo, return error return-value :
find first bf_trn-doc where recid(bf_trn-doc) = parrec-id no-lock.
assign
  bf_trn-doc.fact-rubl       = 0
  bf_trn-doc.fact-base       = 0
  bf_trn-doc.vat-rubl        = 0
  bf_trn-doc.vat-base        = 0
  bf_trn-doc.slt-rubl        = 0
  bf_trn-doc.slt-base        = 0
  bf_trn-doc.road-tax        = 0
  bf_trn-doc.tot-transp   = 0
  bf_trn-doc.tot-other       = 0.
for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code on error undo, return error return-value :
   run corparts_clc-line in this-procedure  (recid (bf_doc-line), "create":u) no-error.
   if error-status:error then do:
     return error substitute ("Ошибка &1 &2 &3 при пересчете линии документа &4. Товар &5 &6 &7.", return-value, error-status:get-message(1), error-status:get-message(2), bf_doc-line.doc-code, bf_doc-line.artic, bf_doc-line.prod-type, bf_doc-line.prod-code).
   end.
end.
end. /*do*/
end procedure.

procedure corparts_clc-line :
define input parameter parrec-id as recid     no-undo.
define input parameter parmode   as character no-undo.
define buffer bf_doc-line   for ub.doc-line.
define buffer bf_trn-doc    for ub.trn-doc.
define buffer bf_parts      for ub.parts.
define buffer bf_goods      for ub.goods.
define buffer bf_parts-root for ub.parts-root.
define variable varr-b      as character no-undo.
define variable varr-btype  as character no-undo.
do on error undo, return error return-value :
  find first bf_doc-line where recid(bf_doc-line) = parrec-id no-lock.
  for each bf_parts where bf_parts.out-code  = bf_doc-line.doc-code
                      and bf_parts.obj-type  = bf_doc-line.obj-type
                      and bf_parts.obj-code  = bf_doc-line.obj-code
                      and bf_parts.artic     = bf_doc-line.artic
                      and bf_parts.prod-type = bf_doc-line.prod-type
                      and bf_parts.prod-code = bf_doc-line.prod-code no-lock on error undo, return error return-value :
    run corparts_clc-parts in this-procedure (input recid(bf_parts), input parmode) no-error.
    if error-status:error then do:
      return error substitute ("Ошибка при пересчете партии документа &1 с кодом &2 товара &3 &4 &5.", bf_parts.out-code, bf_parts.part-code, bf_parts.artic, bf_parts.prod-type, bf_parts.prod-code).
    end.
  end.
  assign
    bf_doc-line.price-base     = 0
    bf_doc-line.price-rubl     = 0
    bf_doc-line.road-tax       = 0
    bf_doc-line.transport-base = 0
    bf_doc-line.transport-rubl = 0
    bf_doc-line.other-base     = 0
    bf_doc-line.other-rubl     = 0.
end.
end procedure.

procedure corparts_clc-parts :
define input parameter parrec-id as recid     no-undo.
define input parameter parmode   as character no-undo.
define variable varsign as integer no-undo.
define variable varvat-pc-buyer-doc like ub.doc-line.vat-pc no-undo.
define variable varvat-pc-sale-doc  like ub.doc-line.vat-pc no-undo.
define variable varslt-pc-sale-doc  like ub.doc-line.vat-pc no-undo.
define variable varvat-pc-acc       like ub.doc-line.vat-pc no-undo.
define variable varslt-pc-acc       like ub.doc-line.vat-pc no-undo.
define variable varr-b      as character no-undo.
define variable varr-btype  as character no-undo.
define buffer bf_parts    for ub.parts.
define buffer bf_doc-line for ub.doc-line.
define buffer bf_trn-doc  for ub.trn-doc.
do on error undo, return error return-value :

  { gbl/curr-r-b.i
    varr-b
  }

  find first bf_parts   where recid(bf_parts) = parrec-id no-lock.
  find first bf_trn-doc where bf_trn-doc.doc-code = bf_parts.out-code no-lock.
  find first bf_doc-line where bf_doc-line.doc-code  = bf_trn-doc.doc-code
                           and bf_doc-line.artic     = bf_parts.artic
                           and bf_doc-line.prod-type = bf_parts.prod-type
                           and bf_doc-line.prod-code = bf_parts.prod-code no-lock.
  if parmode <> "create":u and
     parmode <> "delete":u then do:
    return error substitute ("Неверный параметр parmode &1 передан процедуре corparts_clc-parts.", parmode).
  end.
  if parmode = "create":u then do:
    assign
      varsign = 1.
  end.
  else do:
    assign
      varsign = -1.
  end.
  for each tt-clcparts :
    delete tt-clcparts.
  end.
  create tt-clcparts.
  buffer-copy bf_parts to tt-clcparts.
  run clcprtsl_calc-parts in this-procedure
    (input recid(tt-clcparts),
     input yes,
     input no,
     input bf_doc-line.road-tax,
     input bf_doc-line.excise,
     input bf_doc-line.vat-pc,
     input bf_doc-line.cons-vat-pc,
     input bf_doc-line.slt-pc,
     input bf_trn-doc.base-rate,
     input bf_trn-doc.base-scale,
     input varr-b,
     input ?,
     input ?,
     input ?,
     input ?,
     input ?,
     input ?
     ) no-error.
  if error-status:error then do:
    return error substitute ("Ошибка при расчете партии с кодом &1 документа &2 товар &3 &4 &5.", bf_parts.part-code, bf_parts.out-code, bf_parts.artic, bf_parts.prod-type, bf_parts.prod-code).
  end.
  find first tt-allsum where tt-allsum.sum-type = {&sum-general}.
  assign
    bf_trn-doc.fact-rubl      = bf_trn-doc.fact-rubl      + varsign * bf_parts.price-rubl     * bf_parts.fact-qnty
    bf_trn-doc.fact-base      = bf_trn-doc.fact-base      + varsign * bf_parts.price-base     * bf_parts.fact-qnty
    bf_trn-doc.vat-rubl       = bf_trn-doc.vat-rubl       + varsign * tt-allsum.vat-rubl-doc  * bf_parts.fact-qnty
    bf_trn-doc.vat-base       = bf_trn-doc.vat-base       + varsign * tt-allsum.vat-base-doc  * bf_parts.fact-qnty
    bf_trn-doc.slt-rubl       = bf_trn-doc.slt-rubl       + varsign * tt-allsum.slt-rubl-doc  * bf_parts.fact-qnty
    bf_trn-doc.slt-base       = bf_trn-doc.slt-base       + varsign * tt-allsum.slt-base-doc  * bf_parts.fact-qnty
    bf_trn-doc.road-tax       = bf_trn-doc.road-tax       + varsign * bf_parts.road-tax-rubl  * bf_parts.fact-qnty
    bf_trn-doc.tot-transp     = bf_trn-doc.tot-transp     + varsign * bf_parts.transport-rubl * bf_parts.fact-qnty
    bf_trn-doc.tot-other      = bf_trn-doc.tot-other      + varsign * bf_parts.other-rubl     * bf_parts.fact-qnty.
end.
end procedure.