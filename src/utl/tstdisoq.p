block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: tstdisoq.p $
$Archive: utl/tstdisoq.p $

Проверки правильности архивов по дисконтным картам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/14/05
Author: Bakhtadze Natalya
Creation date: 10/14/05

*/

define input parameter parparentproc as widget-handle no-undo .

define input parameter p-mode      as character no-undo .
DEFINE INPUT PARAMETER test-number as integer no-undo.
DEFINE INPUT PARAMETER f-d-card as char no-undo.
DEFINE INPUT PARAMETER dctype as integer no-undo.
define input parameter p-view-mode as integer no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
/*1 показывать все 0 показывать только ошибочные*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: tstdisoq.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/tstdisoq.p $":U .
define variable vss-description as character no-undo init "Проверки правильности архивов по дисконтным картам".
{ cmp/vssrevis.i }


DEFINE SHARED STREAM TEST.
{ cmp/str-glbl.i }
{ gbl/waitfram.i }
{ str/vchk-pay.i "NEW SHARED" "obj" }
{ str/saledcdf.i " NEW SHARED "  }
{ cmp/library.i }
{ rep/r-sale.i }
{ rep/r-cost.i }
{ str/clc-dcpc.i }
{ gbl/getcntxt.i def }


DEFINE VARiable rabota as logical no-undo.
define variable t-code like ub.doc-line.doc-code.
define variable ret-code like ub.doc-line.doc-code.
define variable ret-doc-code like ub.doc-line.doc-code.
define variable cre-pay   like ub.cash-pay.cdpay-code no-undo.
define variable cre-pay-base   like ub.dis-obj.pay-tot-base no-undo.
define variable cre-pay-rubl     like ub.dis-obj.pay-tot-rubl   no-undo.
define variable chk-exch as decimal no-undo.
define variable chk-exch-rubl as decimal no-undo.
define variable chk-exch-base as decimal no-undo.
define variable v-rate   as decimal no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo.
/*из dis-obj*/
define variable do-obj-code as integer no-undo.
define variable do-chk-num as integer no-undo.
define variable do-gds-sum-rubl as decimal no-undo.
define variable do-disc-sum-rubl as decimal no-undo.
define variable do-pay-sum-rubl as decimal no-undo.
define variable do-gds-sum-base as decimal no-undo.
define variable do-disc-sum-base as decimal no-undo.
define variable do-pay-sum-base as decimal no-undo.
/*из dis-host*/
define variable dh-chk-num as integer no-undo.
define variable dh-gds-sum-rubl as decimal no-undo.
define variable dh-disc-sum-rubl as decimal no-undo.
define variable dh-pay-sum-rubl as decimal no-undo.
define variable dh-gds-sum-base as decimal no-undo.
define variable dh-disc-sum-base as decimal no-undo.
define variable dh-pay-sum-base as decimal no-undo.
/*из payment*/
define variable p-pay-sum-rubl as decimal no-undo.
define variable p-pay-sum-base as decimal no-undo.
/*из dis-card*/
define variable saldo-rubl as decimal no-undo.
define variable saldo-base as decimal no-undo.
define variable ii as integer no-undo.
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-curr-r-b as character no-undo .
define variable accum-tot-rubl     like ub.chk-pay.tot-rubl no-undo .
define variable accum-tot-base     like ub.chk-pay.tot-rubl no-undo .
define variable accum-cre-pay-base like ub.chk-pay.tot-rubl no-undo .
define variable accum-cre-pay-rubl like ub.chk-pay.tot-rubl no-undo .

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
define variable p-doc-code          as character no-undo .
define variable p-sign              as integer no-undo .
define variable p-direction         as integer no-undo .
define variable par-sign            as integer no-undo .
define variable sign                as integer no-undo init 1.
define variable par-direction       as integer no-undo .
define variable x_start-date        as date no-undo .
define variable x_end-date          as date no-undo .
define variable v-time              as integer no-undo .
define variable v-time2             as integer no-undo .
define variable v-ok                as logical no-undo .
define variable v-host-code         like ub.sysconf.host-code no-undo .
define variable new-d-pcnt           like ub.dis-card.d-pcnt no-undo .
define variable old-d-pcnt           like ub.dis-card.d-pcnt no-undo .
define variable for-sum             as decimal no-undo .
DEFINE VARIABLE from-card           as decimal no-undo.
define variable v-chk-num as integer no-undo .
define variable v-chk-num-do as integer no-undo .
define variable v-ref-list          as character no-undo .
define variable v-sum-id            as character no-undo .
define variable v-dt-code           as integer no-undo .
define variable v-chk-doc-sum-id    as character no-undo .
define variable v-algo-num          as character no-undo .
define variable v-for-what          as character no-undo .
define variable v-can-sum           as logical no-undo .
define variable v-can-calc          as logical no-undo .
define variable v-netto-sum         as decimal no-undo .
define variable v-netto-sum-do      as decimal no-undo .
define variable v-cond              as character no-undo .
define variable v-date-from         as date no-undo .
define variable v-date-to           as date no-undo .



define buffer buf_trn-doc for ub.trn-doc.
define buffer bf_trn-doc for ub.trn-doc.
define buffer buf_ret-doc for ub.trn-doc.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_dis-obj for ub.dis-obj.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_shop for ub.shop.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_inkas for ub.inkas .
define buffer buf_temp-d-card for temp-d-card.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_payment for ub.payment.
define buffer buf_curr-shop for ub.curr-shop.
define buffer buf_dis-card-type-attr for ub.dis-card-type-attr.
define buffer buf_clients for ub.clients.
define buffer buf_prop-ref for ub.prop-ref.

define temp-table temp-inkas no-undo like ub.inkas.

{ gbl/curr-r-b.i
  v-curr-r-b
}
if p-obj-code <> 0 then do:
 { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
end.

{ gbl/getcntxt.i get }

_main:
do
on error undo, return error
:
if p-mode = "all" then do:
  { utl/tstdisoq.i all }
end.
else do:
  { utl/tstdisoq.i     }
end.


end. /*doe*/