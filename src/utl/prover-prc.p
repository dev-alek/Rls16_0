block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: prover-prc.p $
$Archive: utl/prover-prc.p $

Проверка Архива по товарам ПРОДАЖНОЙ ЦЕНЫ

Автор: Чернова Светлана Александровна
Дата создания: 04/05/10
Author: Svetlana Chernova
Creation date: 04/05/10

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: prover-prc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/prover-prc.p $":U .
define variable vss-description as character no-undo init "Проверка Архива по товарам ПРОДАЖНОЙ ЦЕНЫ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i   }
{ trg/prdoclib.i }
{ str/prl-vat.i  }

define variable v-total-crsa-fact-qnty  as decimal   no-undo .
define variable v-cur-base              as decimal   no-undo .
define variable v-cur-VAT-base          as decimal   no-undo .
define variable v-cur-SLT-base          as decimal   no-undo .
define variable v-cur-road-tax-base     as decimal   no-undo .
define variable v-cur-excise-base       as decimal   no-undo .
define variable v-kol                   as integer   no-undo .

define buffer buf_ot-line for ub.ot-line  .

&scoped-define log-filename "verarh-prc.txt":U
define stream out-stream.
output stream out-stream to {&log-filename} .
v-kol = 0 .
for each ub.clients no-lock where ub.clients.db-num > 0 :



for each  ub.price-doc no-lock where
          ub.price-doc.obj-code = ub.clients.obj-code and
          ub.price-doc.obj-type = ub.clients.obj-type and
          ub.price-doc.status_  = {&act-overvalue} ,
    each  ub.price-list no-lock where
          ub.price-list.doc-num =  ub.price-doc.doc-num and
          ub.price-list.main-price  = true  by ub.price-doc.fact-order :

find first buf_ot-line no-lock where
           buf_ot-line.doc-code      = ub.price-list.doc-num   and
           buf_ot-line.artic         = ub.price-list.artic     and
           buf_ot-line.prod-type     = ub.price-list.prod-type and
           buf_ot-line.prod-code     = ub.price-list.prod-code and
           buf_ot-line.sum-type      = {&arh-crsa}             and
           buf_ot-line.obj-type      = ub.price-doc.obj-type   and
           buf_ot-line.obj-code      = ub.price-doc.obj-code   and
           buf_ot-line.ext-doc-type  = {&TDEDT_Overturn}       no-error .

         if not available buf_ot-line then next.
        v-cur-base = 0.
        run  prdoclib-calc-ov in this-procedure
            (input  recid(ub.price-list)    /* p-price-list-recid  */
            ,output v-total-crsa-fact-qnty  /* p-fact-qnty         */
            ,output v-cur-base              /* p-cur-base          */
            ,output v-cur-VAT-base          /* p-cur-VAT-base      */
            ,output v-cur-SLT-base          /* p-cur-SLT-base      */
            ) no-error .
            if error-status :error then do:
           put stream out-stream unformatted
           return-value
           error-status :get-message(1)
           skip
           .
          end.
        if buf_ot-line.sum-rubl <> v-cur-base then do:
           put stream out-stream unformatted
           ub.clients.obj-type
           ub.clients.obj-code
           " артикул: "  buf_ot-line.artic  " №переоценки: " buf_ot-line.doc-code " " buf_ot-line.fact-qnty skip
           'ARH ' buf_ot-line.sum-rubl "    UCH " v-cur-base
           .
           v-kol = v-kol + 1 .
        run  prdoclib-calc-fact-sale in this-procedure
            (input  recid(ub.price-list)    /* p-price-list-recid  */
            ,output v-total-crsa-fact-qnty  /* p-fact-qnty         */
            ,output v-cur-base              /* p-cur-base          */
            ,output v-cur-VAT-base          /* p-cur-VAT-base      */
            ,output v-cur-SLT-base          /* p-cur-SLT-base      */
            ,output v-cur-VAT-base          /* p-cur-VAT-base      */
            ,output v-cur-SLT-base          /* p-cur-SLT-base      */
            ) no-error .
            if error-status :error then do:
           put stream out-stream unformatted
           return-value
           error-status :get-message(1)
           skip
           .
           end.
           put stream out-stream unformatted
            " F-S " v-cur-base skip
            ' дата пересчета с ' string ( (ub.price-doc.fact-date - 1 ) , "99/99/9999" ) skip
           return-value
           error-status :get-message(1)
           skip
           .
          leave.
        end.
end.
end.
output stream out-stream close.


message 'все'
    'Пересчитать с инициализацией'
    v-kol
    'объектов'

 view-as alert-box information .