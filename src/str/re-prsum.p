block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: re-prsum.p $
$Archive: str/re-prsum.p $

Пересчет цен в документе по суммовой группе

Автор: Чернова Светлана Александровна
Дата создания: 05/10/06
Author: Svetlana Chernova
Creation date: 05/10/06

Множ.прайс листы


*/
define input  parameter parparentproc as handle no-undo .
define input  parameter p-doc-code as character no-undo .
define output parameter p-update as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: re-prsum.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/re-prsum.p $":U .
define variable vss-description as character no-undo init "Пересчет цен в документе по суммовой группе".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/mpl-auto.i }
{ trg/factord.i }
define variable  v-sum as decimal   no-undo .
define buffer bf_gds-dtl for ub.gds-dtl  .
define buffer buf_trn-doc for ub.trn-doc  .

define variable v-main-b-code     as integer   no-undo .
define variable v-b-code          as integer   no-undo .
define variable v-fact-order      as decimal   no-undo .
define variable v-plt-id          as integer   no-undo .
define variable v-plt-db-num      as integer   no-undo .
define variable v-pdf-id          as integer   no-undo .
define variable v-pdf-db-num      as integer   no-undo .
define variable v-sale-price-base as decimal   no-undo .
define variable v-sale-price-rubl as decimal   no-undo .
define variable v-road-tax-base   as decimal   no-undo .
define variable v-road-tax-rubl   as decimal   no-undo .
define variable v-excise-base     as decimal   no-undo .
define variable v-excise-rubl     as decimal   no-undo .


define buffer buf_sum-group  for ub.sum-group  .
define buffer buf_sum-in-sum-group  for ub.sum-in-sum-group  .
define buffer next_sum-in-sum-group for ub.sum-in-sum-group  .

define buffer buf_price-list-type for ub.price-list-type  .
define buffer buf_price-doc-forming-gds-sum for ub.price-doc-forming-gds-sum  .
define buffer buf_goods for ub.goods  .

define temp-table temp-sumgrp no-undo
field sgr-db-num as integer
field sgr-id     as integer
field sum1       as decimal
field sum2       as decimal
index pi
sgr-db-num
sgr-id
sum1
sum2
.

p-update = true .



/*1. Подсчет суммы по накладной по стартовым ценам */
v-sum = 0 .
find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-doc-code no-error .
 run fact-order-mpl  in this-procedure (
     input  buf_trn-doc.doc-date ,
     input  buf_trn-doc.obj-type ,
     input  buf_trn-doc.obj-code ,
     output v-fact-order ) no-error .
     if error-status :error then
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "fact-order-mpl"
       view-as alert-box error
     .

   for each bf_gds-dtl no-lock where
            bf_gds-dtl.doc-code = p-doc-code
             :
            find first buf_goods no-lock where
                       buf_goods.artic = bf_gds-dtl.artic and
                       buf_goods.prod-type = bf_gds-dtl.prod-type and
                       buf_goods.prod-code = bf_gds-dtl.prod-code .
      if bf_gds-dtl.ov = false then do:
    /* для товаров у которых цена по приоритету sum  */
       { gbl/gdsbcode.i buf_goods.gds-code ?              v-main-b-code }
       { gbl/gdsbcode.i buf_goods.gds-code bf_gds-dtl.prt-code v-b-code }

        run mpl-autoprice in this-procedure
          (input   false
          ,input   buf_trn-doc.cli-type
          ,input   buf_trn-doc.cli-code
          ,input   v-main-b-code
          ,input   v-b-code
          ,input   buf_trn-doc.obj-type
          ,input   buf_trn-doc.obj-code
          ,input   bf_gds-dtl.fact-qnty
          ,input   0
          ,input   string(buf_trn-doc.pay-code)  /* вид оплаты */
          ,input   ""                            /* тип кассового платежа */
          ,input   v-fact-order
          ,output  v-plt-id
          ,output  v-plt-db-num
          ,output  v-pdf-id
          ,output  v-pdf-db-num
          ,output  v-sale-price-base
          ,output  v-sale-price-rubl
          ,output  v-road-tax-base
          ,output  v-road-tax-rubl
          ,output  v-excise-base
          ,output  v-excise-rubl
          ) no-error .
             if error-status :error then message v-sale-price-rubl buf_goods.gds-name 1 error-status :get-message(1) skip v-pdf-db-num.
          end.
          else do:
            assign
              v-sale-price-base = bf_gds-dtl.price-base
              v-sale-price-rubl = bf_gds-dtl.price-rubl
            .
          end.
          v-sum = v-sum + ( v-sale-price-rubl * bf_gds-dtl.fact-qnty ) .
   end.

/* message v-sum 'v-sum' . */

empty TEMP-TABLE temp-sumgrp .
for each buf_sum-in-sum-group no-lock where
         buf_sum-in-sum-group.stts = 0 and
         buf_sum-in-sum-group.ssg-summa <= v-sum :

    find first buf_sum-group no-lock  where
               buf_sum-group.sgr-db-num = buf_sum-in-sum-group.sgr-db-num and
               buf_sum-group.sgr-id     = buf_sum-in-sum-group.sgr-id     and
               buf_sum-group.stts       = 0
               no-error .
    find first next_sum-in-sum-group no-lock where
               next_sum-in-sum-group.sgr-db-num = buf_sum-in-sum-group.sgr-db-num and
               next_sum-in-sum-group.sgr-id     = buf_sum-in-sum-group.sgr-id     and
               next_sum-in-sum-group.ssg-summa  >=  v-sum  and
               next_sum-in-sum-group.ssg-summa  >=  buf_sum-in-sum-group.ssg-summa
               no-error .
     if available next_sum-in-sum-group then do:
      find first temp-sumgrp where
                temp-sumgrp.sgr-db-num = buf_sum-in-sum-group.sgr-db-num and
                temp-sumgrp.sgr-id     = buf_sum-in-sum-group.sgr-id     and
                temp-sumgrp.sum1       = buf_sum-in-sum-group.ssg-summa  and
                temp-sumgrp.sum2       = next_sum-in-sum-group.ssg-summa  no-error .

        if not available temp-sumgrp then do:
            create temp-sumgrp.
            assign
              temp-sumgrp.sgr-db-num = buf_sum-in-sum-group.sgr-db-num
              temp-sumgrp.sgr-id     = buf_sum-in-sum-group.sgr-id
              temp-sumgrp.sum1       = buf_sum-in-sum-group.ssg-summa
              temp-sumgrp.sum2       = next_sum-in-sum-group.ssg-summa
            .
        end.
     end.
     else do:
      find first temp-sumgrp where
                 temp-sumgrp.sgr-db-num = buf_sum-in-sum-group.sgr-db-num and
                 temp-sumgrp.sgr-id     = buf_sum-in-sum-group.sgr-id     and
                 temp-sumgrp.sum1       = buf_sum-in-sum-group.ssg-summa  and
                 temp-sumgrp.sum2       = ?
                 no-error .

        if not available temp-sumgrp then do:
            create temp-sumgrp.
            assign
              temp-sumgrp.sgr-db-num = buf_sum-in-sum-group.sgr-db-num
              temp-sumgrp.sgr-id     = buf_sum-in-sum-group.sgr-id
              temp-sumgrp.sum1       = buf_sum-in-sum-group.ssg-summa
              temp-sumgrp.sum2       = ?
            .
        end.
     end.
end.


if not can-find ( first temp-sumgrp ) then do:
   p-update = false .
   return .
end.


   for each bf_gds-dtl exclusive-lock where
            bf_gds-dtl.doc-code = p-doc-code and
            bf_gds-dtl.ov = false :
            /*message 'bf_gds-dtl.ov' bf_gds-dtl.ov
                     bf_gds-dtl.artic.
                     */
            find first buf_goods no-lock where
                       buf_goods.artic = bf_gds-dtl.artic and
                       buf_goods.prod-type = bf_gds-dtl.prod-type and
                       buf_goods.prod-code = bf_gds-dtl.prod-code .
    /* для товаров у которых цена по приоритету sum  */
       { gbl/gdsbcode.i buf_goods.gds-code ?                   v-main-b-code }
       { gbl/gdsbcode.i buf_goods.gds-code bf_gds-dtl.prt-code v-b-code }

        run mpl-autoprice in this-procedure
          (input true
          ,input   buf_trn-doc.cli-type
          ,input   buf_trn-doc.cli-code
          ,input   v-main-b-code
          ,input   v-b-code
          ,input   buf_trn-doc.obj-type
          ,input   buf_trn-doc.obj-code
          ,input   0    /* колличественные не нужны */
          ,input   v-sum
          ,input   string(buf_trn-doc.pay-code)  /* вид оплаты */
          ,input   ""                            /* тип кассового платежа */
          ,input   v-fact-order
          ,output  v-plt-id
          ,output  v-plt-db-num
          ,output  v-pdf-id
          ,output  v-pdf-db-num
          ,output  v-sale-price-base
          ,output  v-sale-price-rubl
          ,output  v-road-tax-base
          ,output  v-road-tax-rubl
          ,output  v-excise-base
          ,output  v-excise-rubl
          ).
   find first buf_price-list-type no-lock where
              buf_price-list-type.plt-db-num = v-plt-db-num and
              buf_price-list-type.plt-id     = v-plt-id no-error .
    if available buf_price-list-type then do:
       find first temp-sumgrp where
                  temp-sumgrp.sgr-db-num = buf_price-list-type.sgr-db-num and
                  temp-sumgrp.sgr-id     = buf_price-list-type.sgr-id no-error .
          if available temp-sumgrp then do:
              assign
                  bf_gds-dtl.price-base = v-sale-price-base
                  bf_gds-dtl.price-rubl = v-sale-price-rubl
                  bf_gds-dtl.plt-id     = v-plt-id
                  bf_gds-dtl.plt-db-num = v-plt-db-num
                  bf_gds-dtl.pdf-id     = v-pdf-id
                  bf_gds-dtl.pdf-db     = v-pdf-db-num
                 bf_gds-dtl.ov = true
                  p-update = true
              .
               release bf_gds-dtl .

              end.
          end.
     end.