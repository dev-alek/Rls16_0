/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет Анализ продаж

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

  assign
    v-qnty      = 0
    v-ostat     = 0
    v-sum-sale  = 0
    v-sum-cost  = 0
    v-qnty1     = 0
    v-ostat1    = 0
    v-sum-sale1 = 0
    v-sum-cost1 = 0
    p-sale-rubl = 0
    p-cost-rubl = 0
    p-fact-qnty = 0
  .

  if x-SET_PAY_TYPE = 1 then assign sfind = {&arh-crsa} .
  else                       assign sfind = {&arh-cost} .

  /* нужны остатки на конец рабочего периода */
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = sfind
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order  < v-fact-order-end
    use-index category no-error .
  if available buf_stk-line then  assign v-ostat  = buf_stk-line.sum-rubl .

  /* нужны остатки на конец сравнительного периода */
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = sfind
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order  < v-fact-order-end1
    use-index category no-error .
  if available buf_stk-line then  assign v-ostat1  = buf_stk-line.sum-rubl .



  /* продажи за рабочий период */
  find last buf_stk-line no-lock   /* закуп - конец */
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = {&arh-csdt} + {&TDEDT_Ras_Vnesh_Kass}
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      v-sum-cost  = - buf_stk-line.sum-rubl
      v-qnty      = - buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock   /* продажа - конец */
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Ras_Vnesh_Kass}
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end
    use-index category no-error .
  if available buf_stk-line then  assign  v-sum-sale  = - buf_stk-line.sum-rubl  .

  find last buf_stk-line no-lock    /* закуп - начало */
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = {&arh-csdt} + {&TDEDT_Ras_Vnesh_Kass}
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      v-sum-cost  = v-sum-cost + buf_stk-line.sum-rubl
      v-qnty      = v-qnty     + buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock   /* продаж - начало */
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Ras_Vnesh_Kass}
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start
    use-index category no-error .
  if available buf_stk-line then  assign  v-sum-sale  = v-sum-sale + buf_stk-line.sum-rubl  .


  /* продажи за сравнительный период */
  find last buf_stk-line no-lock   /* закуп - конец */
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = {&arh-csdt} + {&TDEDT_Ras_Vnesh_Kass}
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end1
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      v-sum-cost1  = - buf_stk-line.sum-rubl
      v-qnty1      = - buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock   /* продажа - конец */
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Ras_Vnesh_Kass}
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end1
    use-index category no-error .
  if available buf_stk-line then assign  v-sum-sale1  = - buf_stk-line.sum-rubl  .

  find last buf_stk-line no-lock    /* закуп - начало */
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = {&arh-csdt} + {&TDEDT_Ras_Vnesh_Kass}
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start1
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      v-sum-cost1  = v-sum-cost1 + buf_stk-line.sum-rubl
      v-qnty1      = v-qnty1     + buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock    /* продаж - начало */
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Ras_Vnesh_Kass}
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start1
    use-index category no-error .
  if available buf_stk-line then assign  v-sum-sale1  = v-sum-sale1 + buf_stk-line.sum-rubl  .


  /* ****************************************************************************************** */

  if x-return = yes then do: /* учет возвратов */
    /* возврат за рабочий период */
    find last buf_stk-line no-lock   /* закуп - конец */
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = {&arh-csdt} + {&TDEDT_Vozvrat_Vnesh_Kass}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end
      use-index category no-error .
    if available buf_stk-line then do:
      assign
        v-sum-cost  = v-sum-cost - buf_stk-line.sum-rubl
        v-qnty      = v-qnty - buf_stk-line.fact-qnty
      .
    end.
    find last buf_stk-line no-lock   /* продажа - конец */
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh_Kass}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end
      use-index category no-error .
    if available buf_stk-line then  assign  v-sum-sale  = v-sum-sale - buf_stk-line.sum-rubl  .

    find last buf_stk-line no-lock    /* закуп - начало */
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = {&arh-csdt} + {&TDEDT_Vozvrat_Vnesh_Kass}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .
    if available buf_stk-line then do:
      assign
        v-sum-cost  = v-sum-cost + buf_stk-line.sum-rubl
        v-qnty      = v-qnty     + buf_stk-line.fact-qnty
      .
    end.
    find last buf_stk-line no-lock   /* продаж - начало */
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh_Kass}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .
    if available buf_stk-line then  assign  v-sum-sale  = v-sum-sale + buf_stk-line.sum-rubl  .


    /* возвраты за сравнительный период */
    find last buf_stk-line no-lock   /* закуп - конец */
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = {&arh-csdt} + {&TDEDT_Vozvrat_Vnesh_Kass}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end1
      use-index category no-error .
    if available buf_stk-line then do:
      assign
        v-sum-cost1  = v-sum-cost1 - buf_stk-line.sum-rubl
        v-qnty1      = v-qnty1     - buf_stk-line.fact-qnty
      .
    end.
    find last buf_stk-line no-lock   /* продажа - конец */
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh_Kass}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end1
      use-index category no-error .
    if available buf_stk-line then assign  v-sum-sale1  = v-sum-sale1 - buf_stk-line.sum-rubl  .

    find last buf_stk-line no-lock    /* закуп - начало */
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = {&arh-csdt} + {&TDEDT_Vozvrat_Vnesh_Kass}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start1
      use-index category no-error .
    if available buf_stk-line then do:
      assign
        v-sum-cost1  = v-sum-cost1 + buf_stk-line.sum-rubl
        v-qnty1      = v-qnty1     + buf_stk-line.fact-qnty
      .
    end.
    find last buf_stk-line no-lock    /* продаж - начало */
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_goods.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh_Kass}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start1
      use-index category no-error .
    if available buf_stk-line then assign  v-sum-sale1  = v-sum-sale1 + buf_stk-line.sum-rubl  .

 end.


  /* ****************************************************************************************** */

  if  ( x-ShowNull = yes ) or (v-sum-sale <> 0 or v-sum-cost <> 0 or v-sum-sale1 <> 0 or v-sum-cost1 <> 0 or v-qnty <> 0 or v-qnty1 <> 0 or v-ostat <> 0) then do: /*  надо учитывать */
    if x-SumObj = yes then do:
      find first temp-DiscSales
        where temp-DiscSales.obj-type     = buf_gds-obj.obj-type
          and temp-DiscSales.obj-code     = buf_gds-obj.obj-code
          and temp-DiscSales.artic        = buf_goods.artic
          and temp-DiscSales.prod-type    = buf_goods.prod-type
          and temp-DiscSales.prod-code    = buf_goods.prod-code
      no-error .
    end.
    else do:
      find first temp-DiscSales
        where temp-DiscSales.artic        = buf_goods.artic
          and temp-DiscSales.prod-type    = buf_goods.prod-type
          and temp-DiscSales.prod-code    = buf_goods.prod-code
      no-error .
    end.

    assign
      v-all-sum  = v-all-sum + ( if x-SET_PAY_TYPE = 1 then v-sum-sale else v-sum-cost )
      v-all-qnty = v-all-qnty     + v-qnty
    .
    if available temp-DiscSales then do:
      assign
        temp-DiscSales.qnty      = temp-DiscSales.qnty      + v-qnty
        temp-DiscSales.ostat     = temp-DiscSales.ostat     + v-ostat
        temp-DiscSales.sum-cost  = temp-DiscSales.sum-cost  + v-sum-cost
        temp-DiscSales.sum-sale  = temp-DiscSales.sum-sale  + v-sum-sale
        temp-DiscSales.qnty1     = temp-DiscSales.qnty1     + v-qnty1
        temp-DiscSales.ostat1    = temp-DiscSales.ostat1    + v-ostat1
        temp-DiscSales.sum-cost1 = temp-DiscSales.sum-cost1 + v-sum-cost1
        temp-DiscSales.sum-sale1 = temp-DiscSales.sum-sale1 + v-sum-sale1
      .
    end.
    else do:
      create temp-DiscSales .
      { gbl/gdsbcode.i  buf_goods.gds-code  ?  temp-DiscSales.b-code  no-error }
/*      run grplib-get-full-name in this-procedure ( input buf_goods.grp-code,output temp-DiscSales.full-grp-name) .*/
      assign
        temp-DiscSales.obj-type  = buf_gds-obj.obj-type
        temp-DiscSales.obj-code  = buf_gds-obj.obj-code
        temp-DiscSales.artic     = buf_goods.artic
        temp-DiscSales.prod-type = buf_goods.prod-type
        temp-DiscSales.prod-code = buf_goods.prod-code
/*        temp-DiscSales.grp-name  = trim( buf_goods.grp-name )*/
        temp-DiscSales.full-grp-name = trim( buf_goods.grp-name )
        temp-DiscSales.grp-name  = entry ( num-entries( buf_goods.grp-name, {&slash-char} ) - 1, buf_goods.grp-name, {&slash-char} )
        temp-DiscSales.unit-base = buf_goods.unit-base
        temp-DiscSales.grp-code  = buf_goods.grp-code
        temp-DiscSales.qnty      = v-qnty
        temp-DiscSales.ostat     = v-ostat
        temp-DiscSales.sum-cost  = v-sum-cost
        temp-DiscSales.sum-sale  = v-sum-sale
        temp-DiscSales.qnty1     = v-qnty1
        temp-DiscSales.ostat1    = v-ostat1
        temp-DiscSales.sum-cost1 = v-sum-cost1
        temp-DiscSales.sum-sale1 = v-sum-sale1
      .
      if g#gds-engl then assign temp-DiscSales.gds-name = buf_goods.engl-name.
      else               assign temp-DiscSales.gds-name = buf_goods.gds-name.
    end.
  end.

/* $Workfile$   E n d */