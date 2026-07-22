/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

формирование таблички с партиями для просмотра из списка поставщиков CLI_all и v-suppl  Отчет по поставщику (товары)

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


find goods no-lock
  where goods.artic = parts.artic
    and goods.prod-type = parts.prod-type
    and goods.prod-code = parts.prod-code
 no-error  .

assign
  l-date = parts.fact-date
  qnty_sale = 0
.

for each b-parts no-lock
  where b-parts.artic     = parts.artic
    and b-parts.prod-type = parts.prod-type
    and b-parts.prod-code = parts.prod-code
    and b-parts.status_ = yes
    and b-parts.doc-type = {&expense}
  , each  parts-attr no-lock where
          parts-attr.gds-code = goods.gds-code and
          parts-attr.in-code = parts.in-code and
          parts-attr.part-code = parts.part-code
, each trn-doc no-lock
  where trn-doc.doc-code = b-parts.out-code
    and trn-doc.internal = no
    and trn-doc.fact-date >= from-date
    and trn-doc.fact-date <= to-date
  break by b-parts.fact-date:

  if last-of( b-parts.fact-date ) then do:
    assign
      qnty_sale = qnty_sale + 1
    .
  end.
  if last( b-parts.fact-date ) and l-date - 1 < b-parts.fact-date then do:
    assign
      l-date = b-parts.fact-date + 1
    .
  end.
end.

assign
  out-qnty = 0
.
for each b-parts no-lock
  where b-parts.artic     = parts.artic
    and b-parts.prod-type = parts.prod-type
    and b-parts.prod-code = parts.prod-code
    and b-parts.status_   = yes
    and b-parts.out-code <> parts.in-code
  , each  parts-attr no-lock where
          parts-attr.gds-code  = goods.gds-code and
          parts-attr.in-code   = b-parts.in-code and
          parts-attr.part-code = b-parts.part-code

 , each trn-doc no-lock
   where trn-doc.doc-code = b-parts.out-code
     and trn-doc.fact-date >= from-date
     and trn-doc.fact-date <= to-date
  :
   if trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} or trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} or
      trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} or trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} then do:
     if trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} or
        trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} then do:
       assign
         out-qnty = out-qnty - b-parts.fact-qnty
       .
     end.
     else do:
       assign
         out-qnty = out-qnty + b-parts.fact-qnty
       .
     end.
     /* message out-qnty b-parts.fact-qnty  b-parts.out-code . */

  end.
end.
for each b-parts no-lock
  where b-parts.artic     = parts.artic
    and b-parts.prod-type = parts.prod-type
    and b-parts.prod-code = parts.prod-code
    and b-parts.rsrv-free = yes

  , each  parts-attr no-lock where
          parts-attr.gds-code  = goods.gds-code and
          parts-attr.in-code   = b-parts.in-code and
          parts-attr.part-code = b-parts.part-code


  :
    accumulate b-parts.fact-qnty (total).
end.

assign
  free-qnty = (accum total b-parts.fact-qnty)
.

for each b-parts no-lock
  where b-parts.artic = parts.artic
    and b-parts.prod-type = parts.prod-type
    and b-parts.prod-code = parts.prod-code
    and b-parts.status_ = no
    and b-parts.doc-type = {&income}
  , each  parts-attr no-lock where
          parts-attr.gds-code = goods.gds-code and
          parts-attr.in-code   = b-parts.in-code and
          parts-attr.part-code = b-parts.part-code

 , each trn-doc no-lock
  where trn-doc.doc-code = b-parts.out-code
    and trn-doc.internal = yes
    /* and trn-doc.fact-date >= from-date */
    /* and trn-doc.fact-date <= to-date   */

  :
  accumulate b-parts.qnty (total).
end.

assign
  free-qnty = free-qnty + (accum total b-parts.qnty)
.

for each b-parts no-lock
  where b-parts.artic = parts.artic
    and b-parts.prod-type = parts.prod-type
    and b-parts.prod-code = parts.prod-code
    and b-parts.status_ = no
    and b-parts.doc-type = {&return}
  , each  parts-attr no-lock where
          parts-attr.gds-code = goods.gds-code and
          parts-attr.in-code   = b-parts.in-code and
          parts-attr.part-code = b-parts.part-code

 , each trn-doc no-lock
  where trn-doc.doc-code = b-parts.out-code
    and trn-doc.internal = yes
    /* and trn-doc.fact-date >= from-date */
    /* and trn-doc.fact-date <= to-date   */
  :
  accumulate
    b-parts.qnty (total)
  .
end.

assign
  free-qnty = free-qnty + (accum total b-parts.qnty)
.

if free-qnty > 0 then do:
  assign
    l-date = today + 1
  .
end.

{ str/in-vatp.i calc-parts parts. " " g }

if  out-qnty <> 0 or (parts.fact-date >= from-date AND parts.fact-date <= to-date) then do:
  accumulate
    parts.fact-qnty (total)
    parts.fact-qnty * parts.price-rubl (total)
    parts.fact-qnty * parts.price-base (total)
    out-qnty (total)
    out-qnty * parts.price-rubl (total)
    out-qnty * parts.price-base (total)
    free-qnty (total)
    free-qnty * vat-rubl-loc (total)
    free-qnty * vat-base-loc (total)
    free-qnty * price-rubl-with-tax-loc (total)
    free-qnty * price-base-with-tax-loc (total)
  .

  if  prev-exch-code <> ? and prev-exch-code <> parts.exch-code then do:
    assign  v-can-print-cli = false .
  end.
  assign prev-exch-code = parts.exch-code .
  find first parts-attr no-lock where
          parts-attr.gds-code = goods.gds-code and
          parts-attr.in-code   = parts.in-code and
          parts-attr.part-code = parts.part-code no-error .

  create suppl-parts.
  assign
    suppl-parts.artic = parts.artic
    suppl-parts.prod-type = parts.prod-type
    suppl-parts.prod-code = parts.prod-code
    suppl-parts.gds-code  = goods.gds-code
    suppl-parts.gds-name  = goods.gds-name
    suppl-parts.doc-type  = parts.doc-type
    suppl-parts.in-code  = parts.in-code
    suppl-parts.out-code = parts.out-code
    suppl-parts.fact-date = parts.fact-date
    suppl-parts.price0-base = parts.price-base
    suppl-parts.price0-rubl = parts.price-rubl
    suppl-parts.price-cli = parts.price-cli / parts.cli-base-rate
    suppl-parts.obj-type = parts.obj-type
    suppl-parts.obj-code = parts.obj-code
    suppl-parts.part-code = parts.part-code
    suppl-parts.in-qnty = parts.fact-qnty
    suppl-parts.in-sum0-rubl = parts.fact-qnty * parts.price-rubl
    suppl-parts.in-sum0-base = parts.fact-qnty * parts.price-base
    suppl-parts.in-sum-cli = parts.fact-qnty * parts.price-cli / parts.cli-base-rate
    suppl-parts.out-qnty = out-qnty
    suppl-parts.out-sum0-rubl = out-qnty * parts.price-rubl
    suppl-parts.out-sum0-base = out-qnty * parts.price-base
    suppl-parts.out-sum-cli = out-qnty * parts.price-cli / parts.cli-base-rate
    suppl-parts.free-qnty = free-qnty
    suppl-parts.free-NDS0-rubl = free-qnty * vat-rubl-loc
    suppl-parts.free-NDS0-base = free-qnty * vat-base-loc
    suppl-parts.free-sum0-rubl = free-qnty * price-rubl-with-tax-loc
    suppl-parts.free-sum0-base = free-qnty * price-base-with-tax-loc
    suppl-parts.free-sum-cli = free-qnty * parts.price-cli / parts.cli-base-rate
    suppl-parts.qnty-sale = qnty_sale
    suppl-parts.fs-date = parts.fact-date
    suppl-parts.ls-date = l-date
  .
end.


/* $Workfile$ e n d */