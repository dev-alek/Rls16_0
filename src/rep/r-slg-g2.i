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

  assign  Counter1  = Counter1 + 1 .
  { rep/repfrm.i disp Counter1 }

   DO ii = 1 TO num-entries( p_cli-list ) :
     find first buf_clients where recid(buf_clients) = integer(entry(ii, p_cli-list)) no-error.
     if not avail buf_clients then next .
    assign
      beg-qnty  = 0
      end-qnty  = 0
      sale-qnty = 0
      in-qnty   = 0
    .
/*    for each buf_stk-supp-line no-lock*/
/*      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type*/
/*        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code*/
/*        and buf_stk-supp-line.cli-type  = buf_clients.obj-type*/
/*        and buf_stk-supp-line.cli-code  = buf_clients.obj-code*/
/*        and buf_stk-supp-line.artic     = buf_goods.artic*/
/*        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type*/
/*        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code*/
/*        and buf_stk-supp-line.fact-order  <= v-fact-order-start*/
/*        and buf_stk-supp-line.sum-type  = {&arh-cost}*/
/*        and buf_stk-supp-line.cat-id    = '##,##'*/
/*      :*/
/*    message*/
/*      buf_stk-supp-line.fact-qnty  skip*/
/*      buf_stk-supp-line.fact-order  v-fact-order-start skip*/
/*      buf_stk-supp-line.sum-type   {&arh-cost} skip*/
/*      view-as alert-box.*/
/*    end.*/
    /* нужны остатки на начало */
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order  <= v-fact-order-start
        and buf_stk-supp-line.sum-type  = {&arh-cost}
/*        and buf_stk-supp-line.cat-id    = '##,##'*/
/*      use-index art-ot */
      no-error .

    if available buf_stk-supp-line then do:
      assign
        in-qnty = buf_stk-supp-line.fact-qnty
      .
    end .

    /* нужны обороты ПРИХОДОВ от ПОСТАВ. */
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order < v-fact-order-end
        and buf_stk-supp-line.sum-type  = {&arh-sadt} + {&TDEDT_Pri_Vnesh}
/*        and buf_stk-supp-line.cat-id    = '##,##'*/
/*      use-index art-ot */
      no-error .

    if available buf_stk-supp-line then do:
      assign
        end-qnty = buf_stk-supp-line.fact-qnty
      .
    end.
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order <= v-fact-order-start
        and buf_stk-supp-line.sum-type  = {&arh-sadt} + {&TDEDT_Pri_Vnesh}
/*        and buf_stk-supp-line.cat-id    = '##,##'*/
/*      use-index art-ot */
      no-error .

    if available buf_stk-supp-line then do:
      assign
        beg-qnty = buf_stk-supp-line.fact-qnty
      .
    end.

    assign
      in-qnty = in-qnty + end-qnty - beg-qnty
    .

    /* продано через кассу */
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order < v-fact-order-end
        and buf_stk-supp-line.sum-type  = {&arh-sadt} + {&TDEDT_Ras_Vnesh_Kass}
/*        and buf_stk-supp-line.cat-id    = '##,##'*/
/*      use-index art-ot */
      no-error .

    if available buf_stk-supp-line then do:
      assign
        sale-qnty = buf_stk-supp-line.fact-qnty
      .
    end.

    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order <= v-fact-order-start
        and buf_stk-supp-line.sum-type  = {&arh-sadt} + {&TDEDT_Ras_Vnesh_Kass}
/*        and buf_stk-supp-line.cat-id    = '##,##'*/
/*      use-index art-ot */
      no-error .

    if available buf_stk-supp-line then do:
      assign
        sale-qnty = sale-qnty - buf_stk-supp-line.fact-qnty
      .
    end.

    if sale-qnty <> 0 or in-qnty <> 0 then do:
      find first temp-GrSales1
        where temp-GrSales1.obj-type   = buf_gds-obj.obj-type
          and temp-GrSales1.obj-code   = buf_gds-obj.obj-code
          and temp-GrSales1.grp-code   = buf_goods.grp-code
      no-error .
      if not available temp-GrSales1 then do:
        create temp-GrSales1 .
        run grplib-get-full-name in this-procedure ( input buf_goods.grp-code,output temp-GrSales1.full-grp-name) .
        assign
          temp-GrSales1.obj-type  = buf_gds-obj.obj-type
          temp-GrSales1.obj-code  = buf_gds-obj.obj-code
          temp-GrSales1.grp-name  = entry ( num-entries( right-trim(buf_goods.grp-name, {&delim-grp}), {&delim-grp} ) , buf_goods.grp-name, {&delim-grp} )
          temp-GrSales1.grp-code  = buf_goods.grp-code
          temp-GrSales1.in-qnty   = 0
          temp-GrSales1.sale-qnty = 0
        .
      end.
      if in-qnty <> 0   then assign temp-GrSales1.sale-qnty = temp-GrSales1.sale-qnty + 1 .
      if sale-qnty <> 0 then assign temp-GrSales1.in-qnty   = temp-GrSales1.in-qnty   + 1 .
    end.

  end.


  /* $Workfile$ e n d */