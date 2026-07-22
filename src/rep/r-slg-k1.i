/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по продажам ниже учетной цены

Автор: Демин Алексей Сергеевич
Дата создания: 03/23/06
Author: Alexey Demin
Creation date: 03/23/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


  if buf_gds-obj.last-doc = ? then next .
  /*  if buf_gds-obj.first-doc > x-date-end then  next .*/
  if buf_gds-obj.last-doc < x-date-start and buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .

  assign Counter1 = Counter1 + 1.
  { rep/repfrm.i disp Counter1 }

  /* продажи за период */
  for each buf_doc-line no-lock
    where buf_doc-line.obj-type     = buf_gds-obj.obj-type
      and buf_doc-line.obj-code     = buf_gds-obj.obj-code
      and buf_doc-line.prod-type    = buf_goods.prod-type
      and buf_doc-line.prod-code    = buf_goods.prod-code
      and buf_doc-line.artic        = buf_goods.artic
      and buf_doc-line.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
      and buf_doc-line.status_      = {&fact}
      and buf_doc-line.fact-order   >= v-fact-order-start
      and buf_doc-line.fact-order   < v-fact-order-end
    :
    run r-cost in this-procedure ( input buf_doc-line.doc-code, input buf_doc-line.artic, input buf_doc-line.prod-type, input buf_doc-line.prod-code,
               output p-fact-qnty, output t-dec, output t-dec,output t-dec, output p-cost-rubl, output t-dec, output t-dec, output t-dec
              ,output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec ) no-error .
    run r-sale in this-procedure ( input buf_doc-line.doc-code, input buf_doc-line.artic, input buf_doc-line.prod-type, input buf_doc-line.prod-code,
               output p-fact-qnty, output t-dec, output t-dec,output t-dec, output p-sale-rubl, output t-dec, output t-dec, output t-dec
              ,output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec, output t-dec ) no-error .
/*    message*/
/*      buf_goods.artic buf_doc-line.doc-code skip*/
/*      p-cost-rubl p-sale-rubl  skip*/
/*      p-fact-qnty buf_doc-line.fact-qnty*/
/*      view-as alert-box.*/
    assign
      p-sale-rubl = - p-sale-rubl
      p-cost-rubl = - p-cost-rubl
    .
    if p-sale-rubl < p-cost-rubl then do: /* продаж < закуп, надо учитывать */
      find first temp-DiscSales
        where temp-DiscSales.obj-type     = buf_gds-obj.obj-type
          and temp-DiscSales.obj-code     = buf_gds-obj.obj-code
          and temp-DiscSales.artic        = buf_goods.artic
          and temp-DiscSales.prod-type    = buf_goods.prod-type
          and temp-DiscSales.prod-code    = buf_goods.prod-code
      no-error .
      if available temp-DiscSales then do:
        assign
          temp-DiscSales.qnty     = temp-DiscSales.qnty     + buf_doc-line.fact-qnty
          temp-DiscSales.sum-cost = temp-DiscSales.sum-cost + p-cost-rubl
          temp-DiscSales.sum-sale = temp-DiscSales.sum-sale + p-sale-rubl
          temp-DiscSales.sum-del  = temp-DiscSales.sum-cost - temp-DiscSales.sum-sale
        .
      end.
      else do:
        create temp-DiscSales .
        { gbl/gdsbcode.i  buf_goods.gds-code  ?  temp-DiscSales.b-code  no-error }
        run grplib-get-full-name in this-procedure ( input buf_goods.grp-code,output temp-DiscSales.full-grp-name) .
        assign
          temp-DiscSales.obj-type  = buf_gds-obj.obj-type
          temp-DiscSales.obj-code  = buf_gds-obj.obj-code
          temp-DiscSales.artic     = buf_goods.artic
          temp-DiscSales.prod-type = buf_goods.prod-type
          temp-DiscSales.prod-code = buf_goods.prod-code
          temp-DiscSales.grp-name  = entry ( num-entries( right-trim(buf_goods.grp-name, {&delim-grp}), {&delim-grp} ) , buf_goods.grp-name, {&delim-grp} )
          temp-DiscSales.unit-base = buf_goods.unit-base
          temp-DiscSales.grp-code  = buf_goods.grp-code
          temp-DiscSales.qnty      = buf_doc-line.fact-qnty
          temp-DiscSales.sum-cost  = p-cost-rubl
          temp-DiscSales.sum-sale  = p-sale-rubl
          temp-DiscSales.sum-del   = temp-DiscSales.sum-cost - temp-DiscSales.sum-sale
        .
        if g#gds-engl then assign temp-DiscSales.gds-name = buf_goods.engl-name.
        else               assign temp-DiscSales.gds-name = buf_goods.gds-name.
      end.
    end.
  end.


  /* $Workfile$ e n d */