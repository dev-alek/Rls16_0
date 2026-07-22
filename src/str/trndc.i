/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Расчет сумм по ДК в накладной

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/25/05
Author: Bakhtadze Natalya
Creation date: 01/25/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then
define variable v-fact-qnty         like ub.ot-line.fact-qnty       no-undo .
define variable v-vat-pc            like ub.doc-line.vat-pc         no-undo .
define variable v-slt-pc            like ub.doc-line.slt-pc         no-undo .
define variable v-sum-base          like ub.ot-line.sum-base        no-undo .
define variable v-sum-rubl          like ub.ot-line.sum-rubl        no-undo .
define variable v-vat-base          like ub.ot-line.vat-base        no-undo .
define variable v-vat-rubl          like ub.ot-line.vat-rubl        no-undo .
define variable v-slt-base          like ub.ot-line.slt-base        no-undo .
define variable v-slt-rubl          like ub.ot-line.slt-rubl        no-undo .
define variable v-road-tax-base     like ub.ot-line.road-tax-base   no-undo .
define variable v-road-tax-rubl     like ub.ot-line.road-tax-rubl   no-undo .
define variable v-transport-base    like ub.ot-line.transport-base  no-undo .
define variable v-transport-rubl    like ub.ot-line.transport-rubl  no-undo .
define variable v-other-base        like ub.ot-line.other-base      no-undo .
define variable v-other-rubl        like ub.ot-line.other-rubl      no-undo .
define variable v-excise-base       like ub.ot-line.excise-base     no-undo .
define variable v-excise-rubl       like ub.ot-line.excise-rubl     no-undo .
DEFINE VARIABLE accumdl-sum-rubl as decimal no-undo .
DEFINE VARIABLE accumdl-sum-base as decimal no-undo .
&else

if v-cntxt-db-num = 0 then do:

  FOR EACH buf_doc-line no-lock where
          buf_doc-line.doc-code = p-doc-code
     On error undo _main, return error:

    run r-sale in this-procedure (
                                    input p-doc-code
                                   ,input buf_doc-line.artic
                                   ,input buf_doc-line.prod-type
                                   ,input buf_doc-line.prod-code

                                   ,output v-fact-qnty
                                   ,output v-vat-pc
                                   ,output v-slt-pc
                                   ,output v-sum-base
                                   ,output v-sum-rubl
                                   ,output v-vat-base
                                   ,output v-vat-rubl
                                   ,output v-slt-base
                                   ,output v-slt-rubl
                                   ,output v-road-tax-base
                                   ,output v-road-tax-rubl
                                   ,output v-transport-base
                                   ,output v-transport-rubl
                                   ,output v-other-base
                                   ,output v-other-rubl
                                   ,output v-excise-base
                                   ,output v-excise-rubl
                                    ) .
      assign
      temp-d-card.pay-tot-rubl = temp-d-card.pay-tot-rubl + {&sign} abs( v-sum-rubl)
      temp-d-card.pay-tot-base = temp-d-card.pay-tot-base + {&sign} abs( v-sum-base)
      temp-d-card.gds-tot-rubl = temp-d-card.gds-tot-rubl + {&sign} abs( (v-sum-rubl + v-other-rubl))
      temp-d-card.gds-tot-base = temp-d-card.gds-tot-base + {&sign} abs( (v-sum-base + v-other-base))
      temp-d-card.gds-dis-rubl = temp-d-card.gds-dis-rubl + {&sign} abs( v-other-rubl)
      temp-d-card.gds-dis-base = temp-d-card.gds-dis-base + {&sign} abs( v-other-base)
      .
      run r-cost in this-procedure (
                                    input p-doc-code
                                   ,input buf_doc-line.artic
                                   ,input buf_doc-line.prod-type
                                   ,input buf_doc-line.prod-code

                                   ,output v-fact-qnty
                                   ,output v-vat-pc
                                   ,output v-slt-pc
                                   ,output v-sum-base
                                   ,output v-sum-rubl
                                   ,output v-vat-base
                                   ,output v-vat-rubl
                                   ,output v-slt-base
                                   ,output v-slt-rubl
                                   ,output v-road-tax-base
                                   ,output v-road-tax-rubl
                                   ,output v-transport-base
                                   ,output v-transport-rubl
                                   ,output v-other-base
                                   ,output v-other-rubl
                                   ,output v-excise-base
                                   ,output v-excise-rubl
                                    ) .

    assign
    temp-d-card.gds-tot-r0 = temp-d-card.gds-tot-r0 + {&sign} abs( v-sum-rubl)
    temp-d-card.gds-tot-b0 = temp-d-card.gds-tot-b0 + {&sign} abs( v-sum-base)
    .
  END. /* FOR EACH buf_doc-line ... */
end.
if v-curr-r-b = {&r-b-base} then
assign
temp-d-card.gds-tot-r-b = temp-d-card.gds-tot-base
temp-d-card.gds-dis-r-b = temp-d-card.gds-dis-base
temp-d-card.sum-tot-r-b = temp-d-card.sum-tot-base
.
else
assign
temp-d-card.gds-tot-r-b = temp-d-card.gds-tot-rubl
temp-d-card.gds-dis-r-b = temp-d-card.gds-dis-rubl
temp-d-card.sum-tot-r-b = temp-d-card.sum-tot-rubl
.
&if "{1}" = "test" &then
  find first vchk-pay no-lock where
            vchk-pay.d-card   = temp-d-card.d-card
        AND vchk-pay.pay-code = bf_trn-doc.pay-code
        AND vchk-pay.curr-code = bf_trn-doc.exch-code
        AND vchk-pay.doc-date  = 01/01/1990
        AND vchk-pay.cre-pay   = (cre-pay = bf_trn-doc.pay-code) no-error .
  if not available vchk-pay then do:
&endif
    create vchk-pay.
    assign
    vchk-pay.d-card   = temp-d-card.d-card
    vchk-pay.doc-date = bf_trn-doc.exch-date
    vchk-pay.pay-code = bf_trn-doc.pay-code
    vchk-pay.curr-code = bf_trn-doc.exch-code
    vchk-pay.cre-pay   =  no
    vchk-pay.exch-rate = bf_trn-doc.exch-rate
    vchk-pay.base-rate = bf_trn-doc.base-rate
    vchk-pay.tot-base =  temp-d-card.pay-tot-base
    vchk-pay.tot-rubl =  temp-d-card.pay-tot-rubl
    vchk-pay.tot-sum =  (if bf_trn-doc.exch-code = 0 then temp-d-card.pay-tot-rubl else temp-d-card.pay-tot-base)
    .
&if "{1}" = "test" &then
  end.
&endif

&endif   /*если не def*/

/* $Workfile$ e n d */