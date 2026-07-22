/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инклюд пересчета документа пересортицы

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 07/27/06


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define input parameter parmode     as character          no-undo.
define input parameter parrec-line as recid              no-undo.
define input parameter parhave-exp as logical initial no no-undo.
define variable varvalue                        as   character                             no-undo.
define variable vartype                         as   character                             no-undo.
define buffer bf-rc_doc-line       for ub.doc-line.
define buffer bf-rc_goods          for ub.goods.
define buffer bf-rc_parts          for ub.parts.
define buffer bf-rc-exp_parts      for ub.parts.
define buffer bf-rc-inc_parts      for ub.parts.
define buffer bf-expp_trn-doc-sum  for ub.trn-doc-sum.
define buffer bf-incp_trn-doc-sum  for ub.trn-doc-sum.
define buffer bf-expp_doc-line-sum for ub.doc-line-sum.
define buffer bf-incp_doc-line-sum for ub.doc-line-sum.
do on error undo, return error return-value :
find first bf-rc_doc-line where recid(bf-rc_doc-line) = parrec-line.
find first bf-rc_goods    where bf-rc_goods.artic     = bf-rc_doc-line.artic     and
                                bf-rc_goods.prod-type = bf-rc_doc-line.prod-type and
                                bf-rc_goods.prod-code = bf-rc_doc-line.prod-code no-lock.
{ str/reclcinv.i
  parmode
  parrec-line
  bf_trn-doc.doc-code
  vartot-docold
  vartot-rublold
  vartotal-doc-line_tot-ovold
  vartotal-doc-line_fact-rublold
  vartotal-doc-line_fact-baseold
  vartotal-doc-line_fact-qntyold
  vartotal-doc-line_doc-qntyold
  vartotal-doc-line_cli-qntyold
  vartotal-parts_fact-baseold
  vartotal-parts_fact-rublold
  vartotal-parts_fact-qntyold
  no-error
}
if error-status:error then do:
  undo, return error substitute("Ошибка при обсчете линии по товару ", bf-rc_doc-line.artic, bf-rc_doc-line.prod-type, bf-rc_doc-line.prod-code) .
end.
if parmode <> "delete" then do:
  find first bf-expp_doc-line-sum where bf-expp_doc-line-sum.doc-code = bf-rc_doc-line.doc-code
                                    and bf-expp_doc-line-sum.gds-code = bf-rc_goods.gds-code
                                    and bf-expp_doc-line-sum.sum-type = {&sum-expense-parts} exclusive-lock no-error.
  if not available bf-expp_doc-line-sum and
     parhave-exp = yes              then do:
    create bf-expp_doc-line-sum.
    assign
      bf-expp_doc-line-sum.doc-code     = bf_trn-doc.doc-code
      bf-expp_doc-line-sum.ext-doc-type = bf_trn-doc.ext-doc-type
      bf-expp_doc-line-sum.obj-type     = bf_trn-doc.obj-type
      bf-expp_doc-line-sum.obj-code     = bf_trn-doc.obj-code
      bf-expp_doc-line-sum.gds-code     = bf-rc_goods.gds-code
      bf-expp_doc-line-sum.sum-type     = {&sum-expense-parts}
    .
  end.
  find first bf-incp_doc-line-sum where bf-incp_doc-line-sum.doc-code = bf-rc_doc-line.doc-code
                                    and bf-incp_doc-line-sum.gds-code = bf-rc_goods.gds-code
                                    and bf-incp_doc-line-sum.sum-type = {&sum-income-parts} exclusive-lock no-error.
  if not available bf-incp_doc-line-sum and
     not parhave-exp                        then do:
    create bf-incp_doc-line-sum.
    assign
      bf-incp_doc-line-sum.doc-code     = bf_trn-doc.doc-code
      bf-incp_doc-line-sum.ext-doc-type = bf_trn-doc.ext-doc-type
      bf-incp_doc-line-sum.obj-type     = bf_trn-doc.obj-type
      bf-incp_doc-line-sum.obj-code     = bf_trn-doc.obj-code
      bf-incp_doc-line-sum.gds-code     = bf-rc_goods.gds-code
      bf-incp_doc-line-sum.sum-type     = {&sum-income-parts}
    .
  end.
end.
if parmode <> "old":u then do:
  if parmode <> "delete" then do:
    if parhave-exp = yes then do:
      assign
        bf-expp_doc-line-sum.fact-qnty           = 0
        bf-expp_doc-line-sum.cost-sum-base       = 0
        bf-expp_doc-line-sum.cost-sum-rubl       = 0
        bf-expp_doc-line-sum.cost-vat-base       = 0
        bf-expp_doc-line-sum.cost-vat-rubl       = 0
        bf-expp_doc-line-sum.cost-slt-base       = 0
        bf-expp_doc-line-sum.cost-slt-rubl       = 0
        bf-expp_doc-line-sum.cost-road-tax-base  = 0
        bf-expp_doc-line-sum.cost-road-tax-rubl  = 0
        bf-expp_doc-line-sum.cost-excise-base    = 0
        bf-expp_doc-line-sum.cost-excise-rubl    = 0
        bf-expp_doc-line-sum.cost-transport-base = 0
        bf-expp_doc-line-sum.cost-transport-rubl = 0
        bf-expp_doc-line-sum.cost-other-base     = 0
        bf-expp_doc-line-sum.cost-other-rubl     = 0
        bf-expp_doc-line-sum.sale-sum-base       = 0
        bf-expp_doc-line-sum.sale-sum-rubl       = 0
        bf-expp_doc-line-sum.sale-vat-base       = 0
        bf-expp_doc-line-sum.sale-vat-rubl       = 0
        bf-expp_doc-line-sum.sale-slt-base       = 0
        bf-expp_doc-line-sum.sale-slt-rubl       = 0
        bf-expp_doc-line-sum.sale-road-tax-base  = 0
        bf-expp_doc-line-sum.sale-road-tax-rubl  = 0
        bf-expp_doc-line-sum.sale-excise-base    = 0
        bf-expp_doc-line-sum.sale-excise-rubl    = 0
        bf-expp_doc-line-sum.sale-transport-base = 0
        bf-expp_doc-line-sum.sale-transport-rubl = 0
        bf-expp_doc-line-sum.sale-other-base     = 0
        bf-expp_doc-line-sum.sale-other-rubl     = 0
      .
    end.
    else do:
      assign
        bf-incp_doc-line-sum.fact-qnty           = 0
        bf-incp_doc-line-sum.cost-sum-base       = 0
        bf-incp_doc-line-sum.cost-sum-rubl       = 0
        bf-incp_doc-line-sum.cost-vat-base       = 0
        bf-incp_doc-line-sum.cost-vat-rubl       = 0
        bf-incp_doc-line-sum.cost-slt-base       = 0
        bf-incp_doc-line-sum.cost-slt-rubl       = 0
        bf-incp_doc-line-sum.cost-road-tax-base  = 0
        bf-incp_doc-line-sum.cost-road-tax-rubl  = 0
        bf-incp_doc-line-sum.cost-excise-base    = 0
        bf-incp_doc-line-sum.cost-excise-rubl    = 0
        bf-incp_doc-line-sum.cost-transport-base = 0
        bf-incp_doc-line-sum.cost-transport-rubl = 0
        bf-incp_doc-line-sum.cost-other-base     = 0
        bf-incp_doc-line-sum.cost-other-rubl     = 0
        bf-incp_doc-line-sum.sale-sum-base       = 0
        bf-incp_doc-line-sum.sale-sum-rubl       = 0
        bf-incp_doc-line-sum.sale-vat-base       = 0
        bf-incp_doc-line-sum.sale-vat-rubl       = 0
        bf-incp_doc-line-sum.sale-slt-base       = 0
        bf-incp_doc-line-sum.sale-slt-rubl       = 0
        bf-incp_doc-line-sum.sale-road-tax-base  = 0
        bf-incp_doc-line-sum.sale-road-tax-rubl  = 0
        bf-incp_doc-line-sum.sale-excise-base    = 0
        bf-incp_doc-line-sum.sale-excise-rubl    = 0
        bf-incp_doc-line-sum.sale-transport-base = 0
        bf-incp_doc-line-sum.sale-transport-rubl = 0
        bf-incp_doc-line-sum.sale-other-base     = 0
        bf-incp_doc-line-sum.sale-other-rubl     = 0
      .
    end.
    for each bf-rc_parts where bf-rc_parts.out-code  = bf_trn-doc.doc-code   and
                               bf-rc_parts.obj-type  = bf_trn-doc.obj-type   and
                               bf-rc_parts.obj-code  = bf_trn-doc.obj-code   and
                               bf-rc_parts.artic     = bf-rc_goods.artic     and
                               bf-rc_parts.prod-type = bf-rc_goods.prod-type and
                               bf-rc_parts.prod-code = bf-rc_goods.prod-code on error undo, return error return-value :
      for each tt-clcparts :
        delete tt-clcparts.
      end.
      create tt-clcparts.
      buffer-copy bf-rc_parts to tt-clcparts.
      run clcprtsl_calc-parts in this-procedure
         (input recid(tt-clcparts),
          input yes,
          input no,
          input bf-rc_doc-line.road-tax,
          input bf-rc_doc-line.excise,
          input bf-rc_doc-line.VAT-pc,
          input bf-rc_doc-line.cons-vat-pc,
          input bf-rc_doc-line.SLT-pc,
          input bf_trn-doc.base-rate,
          input bf_trn-doc.base-scale,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?
         ).
      find first tt-allsum where tt-allsum.sum-type = {&sum-general}.
      if bf-rc_parts.in-code <> bf-rc_parts.out-code then do:
        if parhave-exp = yes then do:
          assign
            bf-expp_doc-line-sum.fact-qnty           = bf-expp_doc-line-sum.fact-qnty            - tt-allsum.fact-qnty
            bf-expp_doc-line-sum.cost-sum-base       = bf-expp_doc-line-sum.cost-sum-base        - tt-allsum.sum-dsc-base-acc
            bf-expp_doc-line-sum.cost-sum-rubl       = bf-expp_doc-line-sum.cost-sum-rubl        - tt-allsum.sum-dsc-rubl-acc
            bf-expp_doc-line-sum.cost-vat-base       = bf-expp_doc-line-sum.cost-vat-base        - tt-allsum.vat-base-acc
            bf-expp_doc-line-sum.cost-vat-rubl       = bf-expp_doc-line-sum.cost-vat-rubl        - tt-allsum.vat-rubl-acc
            bf-expp_doc-line-sum.cost-slt-base       = bf-expp_doc-line-sum.cost-slt-base        - tt-allsum.slt-base-acc
            bf-expp_doc-line-sum.cost-slt-rubl       = bf-expp_doc-line-sum.cost-slt-rubl        - tt-allsum.slt-rubl-acc
            bf-expp_doc-line-sum.cost-road-tax-base  = bf-expp_doc-line-sum.cost-road-tax-base   - tt-allsum.road-tax-base-acc
            bf-expp_doc-line-sum.cost-road-tax-rubl  = bf-expp_doc-line-sum.cost-road-tax-rubl   - tt-allsum.road-tax-rubl-acc
            bf-expp_doc-line-sum.cost-excise-base    = bf-expp_doc-line-sum.cost-excise-base     - tt-allsum.excise-base-acc
            bf-expp_doc-line-sum.cost-excise-rubl    = bf-expp_doc-line-sum.cost-excise-rubl     - tt-allsum.excise-rubl-acc
            bf-expp_doc-line-sum.cost-transport-base = bf-expp_doc-line-sum.cost-transport-base  - tt-allsum.transport-base-acc
            bf-expp_doc-line-sum.cost-transport-rubl = bf-expp_doc-line-sum.cost-transport-rubl  - tt-allsum.transport-rubl-acc
            bf-expp_doc-line-sum.cost-other-base     = bf-expp_doc-line-sum.cost-other-base      - tt-allsum.other-base-acc
            bf-expp_doc-line-sum.cost-other-rubl     = bf-expp_doc-line-sum.cost-other-rubl      - tt-allsum.other-rubl-acc
            bf-expp_doc-line-sum.sale-sum-base       = bf-expp_doc-line-sum.sale-sum-base        - tt-allsum.sum-dsc-base-doc
            bf-expp_doc-line-sum.sale-sum-rubl       = bf-expp_doc-line-sum.sale-sum-rubl        - tt-allsum.sum-dsc-rubl-doc
            bf-expp_doc-line-sum.sale-vat-base       = bf-expp_doc-line-sum.sale-vat-base        - tt-allsum.vat-base-doc
            bf-expp_doc-line-sum.sale-vat-rubl       = bf-expp_doc-line-sum.sale-vat-rubl        - tt-allsum.vat-rubl-doc
            bf-expp_doc-line-sum.sale-slt-base       = bf-expp_doc-line-sum.sale-slt-base        - tt-allsum.slt-base-doc
            bf-expp_doc-line-sum.sale-slt-rubl       = bf-expp_doc-line-sum.sale-slt-rubl        - tt-allsum.slt-rubl-doc
            bf-expp_doc-line-sum.sale-road-tax-base  = bf-expp_doc-line-sum.sale-road-tax-base   - tt-allsum.road-tax-base-doc
            bf-expp_doc-line-sum.sale-road-tax-rubl  = bf-expp_doc-line-sum.sale-road-tax-rubl   - tt-allsum.road-tax-rubl-doc
            bf-expp_doc-line-sum.sale-excise-base    = bf-expp_doc-line-sum.sale-excise-base     - tt-allsum.excise-base-doc
            bf-expp_doc-line-sum.sale-excise-rubl    = bf-expp_doc-line-sum.sale-excise-rubl     - tt-allsum.excise-rubl-doc
          .
        end.
      end.
      else do:
        if not parhave-exp = yes then do:
          assign
            bf-incp_doc-line-sum.fact-qnty           = bf-incp_doc-line-sum.fact-qnty            + tt-allsum.fact-qnty
            bf-incp_doc-line-sum.cost-sum-base       = bf-incp_doc-line-sum.cost-sum-base        + tt-allsum.sum-dsc-base-acc
            bf-incp_doc-line-sum.cost-sum-rubl       = bf-incp_doc-line-sum.cost-sum-rubl        + tt-allsum.sum-dsc-rubl-acc
            bf-incp_doc-line-sum.cost-vat-base       = bf-incp_doc-line-sum.cost-vat-base        + tt-allsum.vat-base-acc
            bf-incp_doc-line-sum.cost-vat-rubl       = bf-incp_doc-line-sum.cost-vat-rubl        + tt-allsum.vat-rubl-acc
            bf-incp_doc-line-sum.cost-slt-base       = bf-incp_doc-line-sum.cost-slt-base        + tt-allsum.slt-base-acc
            bf-incp_doc-line-sum.cost-slt-rubl       = bf-incp_doc-line-sum.cost-slt-rubl        + tt-allsum.slt-rubl-acc
            bf-incp_doc-line-sum.cost-road-tax-base  = bf-incp_doc-line-sum.cost-road-tax-base   + tt-allsum.road-tax-base-acc
            bf-incp_doc-line-sum.cost-road-tax-rubl  = bf-incp_doc-line-sum.cost-road-tax-rubl   + tt-allsum.road-tax-rubl-acc
            bf-incp_doc-line-sum.cost-excise-base    = bf-incp_doc-line-sum.cost-excise-base     + tt-allsum.excise-base-acc
            bf-incp_doc-line-sum.cost-excise-rubl    = bf-incp_doc-line-sum.cost-excise-rubl     + tt-allsum.excise-rubl-acc
            bf-incp_doc-line-sum.cost-transport-base = bf-incp_doc-line-sum.cost-transport-base  + tt-allsum.transport-base-acc
            bf-incp_doc-line-sum.cost-transport-rubl = bf-incp_doc-line-sum.cost-transport-rubl  + tt-allsum.transport-rubl-acc
            bf-incp_doc-line-sum.cost-other-base     = bf-incp_doc-line-sum.cost-other-base      + tt-allsum.other-base-acc
            bf-incp_doc-line-sum.cost-other-rubl     = bf-incp_doc-line-sum.cost-other-rubl      + tt-allsum.other-rubl-acc
            bf-incp_doc-line-sum.sale-sum-base       = bf-incp_doc-line-sum.sale-sum-base        + tt-allsum.sum-dsc-base-doc
            bf-incp_doc-line-sum.sale-sum-rubl       = bf-incp_doc-line-sum.sale-sum-rubl        + tt-allsum.sum-dsc-rubl-doc
            bf-incp_doc-line-sum.sale-vat-base       = bf-incp_doc-line-sum.sale-vat-base        + tt-allsum.vat-base-doc
            bf-incp_doc-line-sum.sale-vat-rubl       = bf-incp_doc-line-sum.sale-vat-rubl        + tt-allsum.vat-rubl-doc
            bf-incp_doc-line-sum.sale-slt-base       = bf-incp_doc-line-sum.sale-slt-base        + tt-allsum.slt-base-doc
            bf-incp_doc-line-sum.sale-slt-rubl       = bf-incp_doc-line-sum.sale-slt-rubl        + tt-allsum.slt-rubl-doc
            bf-incp_doc-line-sum.sale-road-tax-base  = bf-incp_doc-line-sum.sale-road-tax-base   + tt-allsum.road-tax-base-doc
            bf-incp_doc-line-sum.sale-road-tax-rubl  = bf-incp_doc-line-sum.sale-road-tax-rubl   + tt-allsum.road-tax-rubl-doc
            bf-incp_doc-line-sum.sale-excise-base    = bf-incp_doc-line-sum.sale-excise-base     + tt-allsum.excise-base-doc
            bf-incp_doc-line-sum.sale-excise-rubl    = bf-incp_doc-line-sum.sale-excise-rubl     + tt-allsum.excise-rubl-doc
          .
        end.
      end.
    end.
  end.
  { str/tdat-val.i
    bf_trn-doc.doc-code
    {&trdcattr-addsum}
    varvalue
    vartype
    }
  if lookup ({&sum-expense-parts}, varvalue) = 0 then do:
    { str/tdat-wrt.i
      bf_trn-doc.doc-code
      {&trdcattr-addsum}
      "varvalue + min(varvalue, ',') + {&sum-expense-parts}"
      }
  end.
  find first bf-expp_trn-doc-sum where bf-expp_trn-doc-sum.doc-code = bf_trn-doc.doc-code  and
                                       bf-expp_trn-doc-sum.sum-type = {&sum-expense-parts} exclusive-lock no-error.
  if not available bf-expp_trn-doc-sum then do:
    create bf-expp_trn-doc-sum.
    assign
      bf-expp_trn-doc-sum.doc-code     = bf_trn-doc.doc-code
      bf-expp_trn-doc-sum.ext-doc-type = bf_trn-doc.ext-doc-type
      bf-expp_trn-doc-sum.obj-type     = bf_trn-doc.obj-type
      bf-expp_trn-doc-sum.obj-code     = bf_trn-doc.obj-code
      bf-expp_trn-doc-sum.sum-type     = {&sum-expense-parts}.
  end.
  if lookup ({&sum-income-parts}, varvalue) = 0 then do:
    { str/tdat-wrt.i
      bf_trn-doc.doc-code
      {&trdcattr-addsum}
      "varvalue + min(varvalue, ',') + {&sum-income-parts}"
      }
  end.
  find first bf-incp_trn-doc-sum where bf-incp_trn-doc-sum.doc-code = bf_trn-doc.doc-code and
                                       bf-incp_trn-doc-sum.sum-type = {&sum-income-parts} exclusive-lock no-error.
  if not available bf-incp_trn-doc-sum then do:
    create bf-incp_trn-doc-sum.
    assign
      bf-incp_trn-doc-sum.doc-code     = bf_trn-doc.doc-code
      bf-incp_trn-doc-sum.ext-doc-type = bf_trn-doc.ext-doc-type
      bf-incp_trn-doc-sum.obj-type     = bf_trn-doc.obj-type
      bf-incp_trn-doc-sum.obj-code     = bf_trn-doc.obj-code
      bf-incp_trn-doc-sum.sum-type     = {&sum-income-parts}.
  end.
  if parhave-exp = yes then do:
    assign
      bf-expp_trn-doc-sum.fact-qnty           = bf-expp_trn-doc-sum.fact-qnty           +  (if parmode <> "delete" then bf-expp_doc-line-sum.fact-qnty           else 0) - varoldfact-qnty-exp
      bf-expp_trn-doc-sum.cost-sum-base       = bf-expp_trn-doc-sum.cost-sum-base       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-sum-base       else 0) - varoldcost-sum-base-exp
      bf-expp_trn-doc-sum.cost-sum-rubl       = bf-expp_trn-doc-sum.cost-sum-rubl       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-sum-rubl       else 0) - varoldcost-sum-rubl-exp
      bf-expp_trn-doc-sum.cost-vat-base       = bf-expp_trn-doc-sum.cost-vat-base       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-vat-base       else 0) - varoldcost-vat-base-exp
      bf-expp_trn-doc-sum.cost-vat-rubl       = bf-expp_trn-doc-sum.cost-vat-rubl       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-vat-rubl       else 0) - varoldcost-vat-rubl-exp
      bf-expp_trn-doc-sum.cost-slt-base       = bf-expp_trn-doc-sum.cost-slt-base       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-slt-base       else 0) - varoldcost-slt-base-exp
      bf-expp_trn-doc-sum.cost-slt-rubl       = bf-expp_trn-doc-sum.cost-slt-rubl       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-slt-rubl       else 0) - varoldcost-slt-rubl-exp
      bf-expp_trn-doc-sum.cost-road-tax-base  = bf-expp_trn-doc-sum.cost-road-tax-base  +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-road-tax-base  else 0) - varoldcost-road-tax-base-exp
      bf-expp_trn-doc-sum.cost-road-tax-rubl  = bf-expp_trn-doc-sum.cost-road-tax-rubl  +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-road-tax-rubl  else 0) - varoldcost-road-tax-rubl-exp
      bf-expp_trn-doc-sum.cost-excise-base    = bf-expp_trn-doc-sum.cost-excise-base    +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-excise-base    else 0) - varoldcost-excise-base-exp
      bf-expp_trn-doc-sum.cost-excise-rubl    = bf-expp_trn-doc-sum.cost-excise-rubl    +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-excise-rubl    else 0) - varoldcost-excise-rubl-exp
      bf-expp_trn-doc-sum.cost-transport-base = bf-expp_trn-doc-sum.cost-transport-base +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-transport-base else 0) - varoldcost-transport-base-exp
      bf-expp_trn-doc-sum.cost-transport-rubl = bf-expp_trn-doc-sum.cost-transport-rubl +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-transport-rubl else 0) - varoldcost-transport-rubl-exp
      bf-expp_trn-doc-sum.cost-other-base     = bf-expp_trn-doc-sum.cost-other-base     +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-other-base     else 0) - varoldcost-other-base-exp
      bf-expp_trn-doc-sum.cost-other-rubl     = bf-expp_trn-doc-sum.cost-other-rubl     +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-other-rubl     else 0) - varoldcost-other-rubl-exp
      bf-expp_trn-doc-sum.sale-sum-base       = bf-expp_trn-doc-sum.sale-sum-base       +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-sum-base       else 0) - varoldsale-sum-base-exp
      bf-expp_trn-doc-sum.sale-sum-rubl       = bf-expp_trn-doc-sum.sale-sum-rubl       +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-sum-rubl       else 0) - varoldsale-sum-rubl-exp
      bf-expp_trn-doc-sum.sale-vat-base       = bf-expp_trn-doc-sum.sale-vat-base       +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-vat-base       else 0) - varoldsale-vat-base-exp
      bf-expp_trn-doc-sum.sale-vat-rubl       = bf-expp_trn-doc-sum.sale-vat-rubl       +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-vat-rubl       else 0) - varoldsale-vat-rubl-exp
      bf-expp_trn-doc-sum.sale-slt-base       = bf-expp_trn-doc-sum.sale-slt-base       +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-slt-base       else 0) - varoldsale-slt-base-exp
      bf-expp_trn-doc-sum.sale-slt-rubl       = bf-expp_trn-doc-sum.sale-slt-rubl       +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-slt-rubl       else 0) - varoldsale-slt-rubl-exp
      bf-expp_trn-doc-sum.sale-road-tax-base  = bf-expp_trn-doc-sum.sale-road-tax-base  +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-road-tax-base  else 0) - varoldsale-road-tax-base-exp
      bf-expp_trn-doc-sum.sale-road-tax-rubl  = bf-expp_trn-doc-sum.sale-road-tax-rubl  +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-road-tax-rubl  else 0) - varoldsale-road-tax-rubl-exp
      bf-expp_trn-doc-sum.sale-excise-base    = bf-expp_trn-doc-sum.sale-excise-base    +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-excise-base    else 0) - varoldsale-excise-base-exp
      bf-expp_trn-doc-sum.sale-excise-rubl    = bf-expp_trn-doc-sum.sale-excise-rubl    +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-excise-rubl    else 0) - varoldsale-excise-rubl-exp
      bf-expp_trn-doc-sum.sale-transport-base = bf-expp_trn-doc-sum.sale-transport-base +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-transport-base else 0) - varoldsale-transport-base-exp
      bf-expp_trn-doc-sum.sale-transport-rubl = bf-expp_trn-doc-sum.sale-transport-rubl +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-transport-rubl else 0) - varoldsale-transport-rubl-exp
      bf-expp_trn-doc-sum.sale-other-base     = bf-expp_trn-doc-sum.sale-other-base     +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-other-base     else 0) - varoldsale-other-base-exp
      bf-expp_trn-doc-sum.sale-other-rubl     = bf-expp_trn-doc-sum.sale-other-rubl     +  (if parmode <> "delete" then bf-expp_doc-line-sum.sale-other-rubl     else 0) - varoldsale-other-rubl-exp
    .
  end.
  else do:
    assign
      bf-incp_trn-doc-sum.fact-qnty           = bf-incp_trn-doc-sum.fact-qnty           +  (if parmode <> "delete" then bf-incp_doc-line-sum.fact-qnty           else 0) - varoldfact-qnty-inp
      bf-incp_trn-doc-sum.cost-sum-base       = bf-incp_trn-doc-sum.cost-sum-base       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-sum-base       else 0) - varoldcost-sum-base-inp
      bf-incp_trn-doc-sum.cost-sum-rubl       = bf-incp_trn-doc-sum.cost-sum-rubl       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-sum-rubl       else 0) - varoldcost-sum-rubl-inp
      bf-incp_trn-doc-sum.cost-vat-base       = bf-incp_trn-doc-sum.cost-vat-base       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-vat-base       else 0) - varoldcost-vat-base-inp
      bf-incp_trn-doc-sum.cost-vat-rubl       = bf-incp_trn-doc-sum.cost-vat-rubl       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-vat-rubl       else 0) - varoldcost-vat-rubl-inp
      bf-incp_trn-doc-sum.cost-slt-base       = bf-incp_trn-doc-sum.cost-slt-base       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-slt-base       else 0) - varoldcost-slt-base-inp
      bf-incp_trn-doc-sum.cost-slt-rubl       = bf-incp_trn-doc-sum.cost-slt-rubl       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-slt-rubl       else 0) - varoldcost-slt-rubl-inp
      bf-incp_trn-doc-sum.cost-road-tax-base  = bf-incp_trn-doc-sum.cost-road-tax-base  +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-road-tax-base  else 0) - varoldcost-road-tax-base-inp
      bf-incp_trn-doc-sum.cost-road-tax-rubl  = bf-incp_trn-doc-sum.cost-road-tax-rubl  +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-road-tax-rubl  else 0) - varoldcost-road-tax-rubl-inp
      bf-incp_trn-doc-sum.cost-excise-base    = bf-incp_trn-doc-sum.cost-excise-base    +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-excise-base    else 0) - varoldcost-excise-base-inp
      bf-incp_trn-doc-sum.cost-excise-rubl    = bf-incp_trn-doc-sum.cost-excise-rubl    +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-excise-rubl    else 0) - varoldcost-excise-rubl-inp
      bf-incp_trn-doc-sum.cost-transport-base = bf-incp_trn-doc-sum.cost-transport-base +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-transport-base else 0) - varoldcost-transport-base-inp
      bf-incp_trn-doc-sum.cost-transport-rubl = bf-incp_trn-doc-sum.cost-transport-rubl +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-transport-rubl else 0) - varoldcost-transport-rubl-inp
      bf-incp_trn-doc-sum.cost-other-base     = bf-incp_trn-doc-sum.cost-other-base     +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-other-base     else 0) - varoldcost-other-base-inp
      bf-incp_trn-doc-sum.cost-other-rubl     = bf-incp_trn-doc-sum.cost-other-rubl     +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-other-rubl     else 0) - varoldcost-other-rubl-inp
      bf-incp_trn-doc-sum.sale-sum-base       = bf-incp_trn-doc-sum.sale-sum-base       +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-sum-base       else 0) - varoldsale-sum-base-inp
      bf-incp_trn-doc-sum.sale-sum-rubl       = bf-incp_trn-doc-sum.sale-sum-rubl       +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-sum-rubl       else 0) - varoldsale-sum-rubl-inp
      bf-incp_trn-doc-sum.sale-vat-base       = bf-incp_trn-doc-sum.sale-vat-base       +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-vat-base       else 0) - varoldsale-vat-base-inp
      bf-incp_trn-doc-sum.sale-vat-rubl       = bf-incp_trn-doc-sum.sale-vat-rubl       +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-vat-rubl       else 0) - varoldsale-vat-rubl-inp
      bf-incp_trn-doc-sum.sale-slt-base       = bf-incp_trn-doc-sum.sale-slt-base       +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-slt-base       else 0) - varoldsale-slt-base-inp
      bf-incp_trn-doc-sum.sale-slt-rubl       = bf-incp_trn-doc-sum.sale-slt-rubl       +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-slt-rubl       else 0) - varoldsale-slt-rubl-inp
      bf-incp_trn-doc-sum.sale-road-tax-base  = bf-incp_trn-doc-sum.sale-road-tax-base  +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-road-tax-base  else 0) - varoldsale-road-tax-base-inp
      bf-incp_trn-doc-sum.sale-road-tax-rubl  = bf-incp_trn-doc-sum.sale-road-tax-rubl  +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-road-tax-rubl  else 0) - varoldsale-road-tax-rubl-inp
      bf-incp_trn-doc-sum.sale-excise-base    = bf-incp_trn-doc-sum.sale-excise-base    +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-excise-base    else 0) - varoldsale-excise-base-inp
      bf-incp_trn-doc-sum.sale-excise-rubl    = bf-incp_trn-doc-sum.sale-excise-rubl    +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-excise-rubl    else 0) - varoldsale-excise-rubl-inp
      bf-incp_trn-doc-sum.sale-transport-base = bf-incp_trn-doc-sum.sale-transport-base +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-transport-base else 0) - varoldsale-transport-base-inp
      bf-incp_trn-doc-sum.sale-transport-rubl = bf-incp_trn-doc-sum.sale-transport-rubl +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-transport-rubl else 0) - varoldsale-transport-rubl-inp
      bf-incp_trn-doc-sum.sale-other-base     = bf-incp_trn-doc-sum.sale-other-base     +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-other-base     else 0) - varoldsale-other-base-inp
      bf-incp_trn-doc-sum.sale-other-rubl     = bf-incp_trn-doc-sum.sale-other-rubl     +  (if parmode <> "delete" then bf-incp_doc-line-sum.sale-other-rubl     else 0) - varoldsale-other-rubl-inp
    .
  end.
end.
else do:
  if parhave-exp then do:
    assign
      varoldfact-qnty-exp            = bf-expp_doc-line-sum.fact-qnty
      varoldcost-sum-base-exp        = bf-expp_doc-line-sum.cost-sum-base
      varoldcost-sum-rubl-exp        = bf-expp_doc-line-sum.cost-sum-rubl
      varoldcost-vat-base-exp        = bf-expp_doc-line-sum.cost-vat-base
      varoldcost-vat-rubl-exp        = bf-expp_doc-line-sum.cost-vat-rubl
      varoldcost-slt-base-exp        = bf-expp_doc-line-sum.cost-slt-base
      varoldcost-slt-rubl-exp        = bf-expp_doc-line-sum.cost-slt-rubl
      varoldcost-road-tax-base-exp   = bf-expp_doc-line-sum.cost-road-tax-base
      varoldcost-road-tax-rubl-exp   = bf-expp_doc-line-sum.cost-road-tax-rubl
      varoldcost-excise-base-exp     = bf-expp_doc-line-sum.cost-excise-base
      varoldcost-excise-rubl-exp     = bf-expp_doc-line-sum.cost-excise-rubl
      varoldcost-transport-base-exp  = bf-expp_doc-line-sum.cost-transport-base
      varoldcost-transport-rubl-exp  = bf-expp_doc-line-sum.cost-transport-rubl
      varoldcost-other-base-exp      = bf-expp_doc-line-sum.cost-other-base
      varoldcost-other-rubl-exp      = bf-expp_doc-line-sum.cost-other-rubl
      varoldsale-sum-base-exp        = bf-expp_doc-line-sum.sale-sum-base
      varoldsale-sum-rubl-exp        = bf-expp_doc-line-sum.sale-sum-rubl
      varoldsale-vat-base-exp        = bf-expp_doc-line-sum.sale-vat-base
      varoldsale-vat-rubl-exp        = bf-expp_doc-line-sum.sale-vat-rubl
      varoldsale-slt-base-exp        = bf-expp_doc-line-sum.sale-slt-base
      varoldsale-slt-rubl-exp        = bf-expp_doc-line-sum.sale-slt-rubl
      varoldsale-road-tax-base-exp   = bf-expp_doc-line-sum.sale-road-tax-base
      varoldsale-road-tax-rubl-exp   = bf-expp_doc-line-sum.sale-road-tax-rubl
      varoldsale-excise-base-exp     = bf-expp_doc-line-sum.sale-excise-base
      varoldsale-excise-rubl-exp     = bf-expp_doc-line-sum.sale-excise-rubl
      varoldsale-transport-base-exp  = bf-expp_doc-line-sum.sale-transport-base
      varoldsale-transport-rubl-exp  = bf-expp_doc-line-sum.sale-transport-rubl
      varoldsale-other-base-exp      = bf-expp_doc-line-sum.sale-other-base
      varoldsale-other-rubl-exp      = bf-expp_doc-line-sum.sale-other-rubl
     .
   end.
   else do:
    assign
      varoldfact-qnty-exp            = 0
      varoldcost-sum-base-exp        = 0
      varoldcost-sum-rubl-exp        = 0
      varoldcost-vat-base-exp        = 0
      varoldcost-vat-rubl-exp        = 0
      varoldcost-slt-base-exp        = 0
      varoldcost-slt-rubl-exp        = 0
      varoldcost-road-tax-base-exp   = 0
      varoldcost-road-tax-rubl-exp   = 0
      varoldcost-excise-base-exp     = 0
      varoldcost-excise-rubl-exp     = 0
      varoldcost-transport-base-exp  = 0
      varoldcost-transport-rubl-exp  = 0
      varoldcost-other-base-exp      = 0
      varoldcost-other-rubl-exp      = 0
      varoldsale-sum-base-exp        = 0
      varoldsale-sum-rubl-exp        = 0
      varoldsale-vat-base-exp        = 0
      varoldsale-vat-rubl-exp        = 0
      varoldsale-slt-base-exp        = 0
      varoldsale-slt-rubl-exp        = 0
      varoldsale-road-tax-base-exp   = 0
      varoldsale-road-tax-rubl-exp   = 0
      varoldsale-excise-base-exp     = 0
      varoldsale-excise-rubl-exp     = 0
      varoldsale-transport-base-exp  = 0
      varoldsale-transport-rubl-exp  = 0
      varoldsale-other-base-exp      = 0
      varoldsale-other-rubl-exp      = 0
     .

   end.
   if not parhave-exp then do:
     assign
       varoldfact-qnty-inp            =   bf-incp_doc-line-sum.fact-qnty
       varoldcost-sum-base-inp        =   bf-incp_doc-line-sum.cost-sum-base
       varoldcost-sum-rubl-inp        =   bf-incp_doc-line-sum.cost-sum-rubl
       varoldcost-vat-base-inp        =   bf-incp_doc-line-sum.cost-vat-base
       varoldcost-vat-rubl-inp        =   bf-incp_doc-line-sum.cost-vat-rubl
       varoldcost-slt-base-inp        =   bf-incp_doc-line-sum.cost-slt-base
       varoldcost-slt-rubl-inp        =   bf-incp_doc-line-sum.cost-slt-rubl
       varoldcost-road-tax-base-inp   =   bf-incp_doc-line-sum.cost-road-tax-base
       varoldcost-road-tax-rubl-inp   =   bf-incp_doc-line-sum.cost-road-tax-rubl
       varoldcost-excise-base-inp     =   bf-incp_doc-line-sum.cost-excise-base
       varoldcost-excise-rubl-inp     =   bf-incp_doc-line-sum.cost-excise-rubl
       varoldcost-transport-base-inp  =   bf-incp_doc-line-sum.cost-transport-base
       varoldcost-transport-rubl-inp  =   bf-incp_doc-line-sum.cost-transport-rubl
       varoldcost-other-base-inp      =   bf-incp_doc-line-sum.cost-other-base
       varoldcost-other-rubl-inp      =   bf-incp_doc-line-sum.cost-other-rubl
       varoldsale-sum-base-inp        =   bf-incp_doc-line-sum.sale-sum-base
       varoldsale-sum-rubl-inp        =   bf-incp_doc-line-sum.sale-sum-rubl
       varoldsale-vat-base-inp        =   bf-incp_doc-line-sum.sale-vat-base
       varoldsale-vat-rubl-inp        =   bf-incp_doc-line-sum.sale-vat-rubl
       varoldsale-slt-base-inp        =   bf-incp_doc-line-sum.sale-slt-base
       varoldsale-slt-rubl-inp        =   bf-incp_doc-line-sum.sale-slt-rubl
       varoldsale-road-tax-base-inp   =   bf-incp_doc-line-sum.sale-road-tax-base
       varoldsale-road-tax-rubl-inp   =   bf-incp_doc-line-sum.sale-road-tax-rubl
       varoldsale-excise-base-inp     =   bf-incp_doc-line-sum.sale-excise-base
       varoldsale-excise-rubl-inp     =   bf-incp_doc-line-sum.sale-excise-rubl
       varoldsale-transport-base-inp  =   bf-incp_doc-line-sum.sale-transport-base
       varoldsale-transport-rubl-inp  =   bf-incp_doc-line-sum.sale-transport-rubl
       varoldsale-other-base-inp      =   bf-incp_doc-line-sum.sale-other-base
       varoldsale-other-rubl-inp      =   bf-incp_doc-line-sum.sale-other-rubl
     .
  end.
  else do:
     assign
       varoldfact-qnty-inp            = 0
       varoldcost-sum-base-inp        = 0
       varoldcost-sum-rubl-inp        = 0
       varoldcost-vat-base-inp        = 0
       varoldcost-vat-rubl-inp        = 0
       varoldcost-slt-base-inp        = 0
       varoldcost-slt-rubl-inp        = 0
       varoldcost-road-tax-base-inp   = 0
       varoldcost-road-tax-rubl-inp   = 0
       varoldcost-excise-base-inp     = 0
       varoldcost-excise-rubl-inp     = 0
       varoldcost-transport-base-inp  = 0
       varoldcost-transport-rubl-inp  = 0
       varoldcost-other-base-inp      = 0
       varoldcost-other-rubl-inp      = 0
       varoldsale-sum-base-inp        = 0
       varoldsale-sum-rubl-inp        = 0
       varoldsale-vat-base-inp        = 0
       varoldsale-vat-rubl-inp        = 0
       varoldsale-slt-base-inp        = 0
       varoldsale-slt-rubl-inp        = 0
       varoldsale-road-tax-base-inp   = 0
       varoldsale-road-tax-rubl-inp   = 0
       varoldsale-excise-base-inp     = 0
       varoldsale-excise-rubl-inp     = 0
       varoldsale-transport-base-inp  = 0
       varoldsale-transport-rubl-inp  = 0
       varoldsale-other-base-inp      = 0
       varoldsale-other-rubl-inp      = 0
     .

  end.
end.
end.