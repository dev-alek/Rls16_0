/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по закончившимся наименованиям - обработка

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/

assign Counter1 = Counter1 + 1.
{ rep/repfrm.i disp Counter1 }

find first temp-DiscSales
where temp-DiscSales.artic        = buf_goods.artic
  and temp-DiscSales.prod-type    = buf_goods.prod-type
  and temp-DiscSales.prod-code    = buf_goods.prod-code
no-error .
if not available temp-DiscSales then do:
create temp-DiscSales .
assign
  temp-DiscSales.artic     = buf_goods.artic
  temp-DiscSales.prod-type = buf_goods.prod-type
  temp-DiscSales.prod-code = buf_goods.prod-code
  temp-DiscSales.grp-name  = trim( buf_goods.grp-name )
  temp-DiscSales.unit-base = buf_goods.unit-base
  temp-DiscSales.grp-code  = buf_goods.grp-code
  temp-DiscSales.sum-sale  = 0
  temp-DiscSales.fact-qnty = 0
.
if g#gds-engl then assign temp-DiscSales.gds-name = buf_goods.engl-name.
else               assign temp-DiscSales.gds-name = buf_goods.gds-name.
end.

/* продажи за рабочий период */
do ii = 1 to 4 :
case ii :
  when 1 then assign str-find = {&arh-sadt} + {&TDEDT_Ras_Vnesh} .                 /* продажа */
  when 2 then assign str-find = {&arh-sadt} + {&TDEDT_Ras_Vnesh_Kass} .
  when 3 then assign str-find = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh} .
  when 4 then assign str-find = {&arh-sadt} + {&TDEDT_Vozvrat_Vnesh_Kass} .
  end.

find last buf_stk-line no-lock
  where buf_stk-line.obj-type  = buf_gds-obj.obj-type
    and buf_stk-line.obj-code  = buf_gds-obj.obj-code
    and buf_stk-line.artic     = buf_goods.artic
    and buf_stk-line.prod-type = buf_gds-obj.prod-type
    and buf_stk-line.prod-code = buf_gds-obj.prod-code
    and buf_stk-line.sum-type  = str-find
    and buf_stk-line.cat-id    = '##,##'
    and buf_stk-line.fact-order  <= v-fact-order-start
use-index category no-error .

if available buf_stk-line then do:

  case ii :
    when 1 or when 2 then assign
    temp-DiscSales.sum-sale = temp-DiscSales.sum-sale + buf_stk-line.sum-rubl
    temp-DiscSales.fact-qnty = temp-DiscSales.fact-qnty + buf_stk-line.fact-qnty.
    when 3 or when 4 then assign
    temp-DiscSales.sum-sale = temp-DiscSales.sum-sale + buf_stk-line.sum-rubl
    temp-DiscSales.fact-qnty = temp-DiscSales.fact-qnty + buf_stk-line.fact-qnty.
    end.
end.

find last buf_stk-line no-lock
  where buf_stk-line.obj-type  = buf_gds-obj.obj-type
    and buf_stk-line.obj-code  = buf_gds-obj.obj-code
    and buf_stk-line.artic     = buf_goods.artic
    and buf_stk-line.prod-type = buf_gds-obj.prod-type
    and buf_stk-line.prod-code = buf_gds-obj.prod-code
    and buf_stk-line.sum-type  = str-find
    and buf_stk-line.cat-id    = '##,##'
    and buf_stk-line.fact-order  < v-fact-order-end
use-index category no-error .

if available buf_stk-line then do:

    case ii :
    when 1 or when 2 then assign
    temp-DiscSales.sum-sale = temp-DiscSales.sum-sale - buf_stk-line.sum-rubl
    temp-DiscSales.fact-qnty = temp-DiscSales.fact-qnty - buf_stk-line.fact-qnty.
    when 3 or when 4 then assign
    temp-DiscSales.sum-sale = temp-DiscSales.sum-sale - buf_stk-line.sum-rubl
    temp-DiscSales.fact-qnty = temp-DiscSales.fact-qnty - buf_stk-line.fact-qnty.
    end.
end.
end.


/* $Workfile$ e n d */