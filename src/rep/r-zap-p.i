/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

расчеты остатков на начало, конец и расходов для ОТЧЕТ О СОСТОЯНИИ ЗАПАСА И ПРОДАЖАХ (r-zap-pr.i )

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


Assign
  f-end-cost  = 0
  f-beg-qnty  = 0
  f-sale-qnty = 0
  f-end-qnty  = 0
  f-end-sum   = 0
.

/* остатки на конец */
 find last /*first*/ buf_stk-line no-lock
   where buf_stk-line.obj-type  = obj-list.obj-type
     and buf_stk-line.obj-code  = obj-list.obj-code
     and buf_stk-line.artic     = temp-goods.artic
     and buf_stk-line.prod-type = temp-goods.prod-type
     and buf_stk-line.prod-code = temp-goods.prod-code
     and buf_stk-line.sum-type  = ( if ShowPrice = 1 then {&arh-crsa} else {&arh-cost} )
     and buf_stk-line.cat-id    = '##,##'
     and buf_stk-line.fact-order < v-fact-order-end
     use-index category no-error .

    if available buf_stk-line then
    do:
      if buf_stk-line.fact-qnty <> 0 then
      do:
        assign
          f-end-cost  = buf_stk-line.sum-{1} / buf_stk-line.fact-qnty
        .
      end.

      assign
        f-end-qnty  = buf_stk-line.fact-qnty
        f-end-sum   = buf_stk-line.sum-{1}
      .
    end.

/* расход и возврат за период */
 for each buf_ot-line no-lock
   where buf_ot-line.obj-type  = obj-list.obj-type
     and buf_ot-line.obj-code  = obj-list.obj-code
     and buf_ot-line.artic     = temp-goods.artic
     and buf_ot-line.prod-type = temp-goods.prod-type
     and buf_ot-line.prod-code = temp-goods.prod-code
     and buf_ot-line.fact-order >= v-fact-order-start
     and buf_ot-line.fact-order < v-fact-order-end
     and buf_ot-line.sum-type  = {&arh-cost}
     and buf_ot-line.cat-id    = '##,##'
     break by buf_ot-line.fact-order descending
   :

    case buf_ot-line.ext-doc-type :
      when {&TDEDT_Ras_Vnesh}       then do:
        assign
          f-sale-qnty = f-sale-qnty + buf_ot-line.fact-qnty
        .
      End.
      when {&TDEDT_Ras_Vnesh_Kass}       then do:
        assign
          f-sale-qnty = f-sale-qnty + buf_ot-line.fact-qnty
        .
      End.
      when {&TDEDT_Vozvrat_Vnesh}       then do:
        assign
          f-sale-qnty = f-sale-qnty + buf_ot-line.fact-qnty
        .
      End.
      when {&TDEDT_Vozvrat_Vnesh_Kass}       then do:
        assign
          f-sale-qnty = f-sale-qnty + buf_ot-line.fact-qnty
        .
      End.
    End case.

  end.

/* остатки на начало */
 find last buf_stk-line no-lock
   where buf_stk-line.obj-type  = obj-list.obj-type
     and buf_stk-line.obj-code  = obj-list.obj-code
     and buf_stk-line.artic     = temp-goods.artic
     and buf_stk-line.prod-type = temp-goods.prod-type
     and buf_stk-line.prod-code = temp-goods.prod-code
     and buf_stk-line.sum-type  = ( if ShowPrice = 1 then {&arh-crsa} else {&arh-cost} )
     and buf_stk-line.cat-id    = '##,##'
     and buf_stk-line.fact-order <= v-fact-order-start
     use-index category no-error .
    if available buf_stk-line then do:
      assign
        f-beg-qnty  = buf_stk-line.fact-qnty
      .
    end.

  if f-sale-qnty <> 0 then do:
    assign
      Oborot = yes
    .
  end.

  if f-beg-qnty <> 0 or f-end-qnty <> 0 then do:
    assign
      Ostat = yes
    .
  end.

/* заполнение данных по строке */
find first Temp-line share-lock
  where Temp-line.obj-type  = obj-list.obj-type
    and Temp-line.obj-code  = obj-list.obj-code  no-error .

if not available Temp-line Then  create Temp-line no-error .

assign
  Temp-line.obj-type    = obj-list.obj-type
  Temp-line.obj-code    = obj-list.obj-code
  Temp-line.l-end-cost  = f-end-cost
  Temp-line.l-beg-qnty  = f-beg-qnty
  Temp-line.l-sale-qnty = f-sale-qnty
  Temp-line.l-end-qnty  = f-end-qnty
  Temp-line.l-end-sum   = f-end-sum
.

/* подсчет итоговых сумм */
find first Temp-i  share-lock
  where Temp-i.obj-type  = obj-list.obj-type
    and Temp-i.obj-code  = obj-list.obj-code no-error .

if not available Temp-i then do:
  create Temp-i no-error .
  assign
    Temp-i.obj-code     = obj-list.obj-code
    Temp-i.obj-type     = obj-list.obj-type
    Temp-i.i-beg-qnty   = f-beg-qnty
    Temp-i.i-sale-qnty  = f-sale-qnty
    Temp-i.i-end-qnty   = f-end-qnty
    Temp-i.i-end-sum    = f-end-sum
  .
end.
else do:
  assign
    Temp-i.i-beg-qnty   = Temp-i.i-beg-qnty   + f-beg-qnty
    Temp-i.i-sale-qnty  = Temp-i.i-sale-qnty  + f-sale-qnty
    Temp-i.i-end-qnty   = Temp-i.i-end-qnty   + f-end-qnty
    Temp-i.i-end-sum    = Temp-i.i-end-sum    + f-end-sum
  .
end.

/* $Workfile$ e n d */