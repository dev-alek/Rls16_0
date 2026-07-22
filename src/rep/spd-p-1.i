/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по скорости продаж

Автор: Демин Алексей Сергеевич
Дата создания: 03/23/06
Author: Alexey Demin
Creation date: 03/23/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$".

  assign Counter1 = Counter1 + 1.
  { rep/repfrm.i disp Counter1 }

  find first temp-goods
    where temp-goods.gds-code = buf_gds-obj.gds-code
    no-error .
  if not available temp-goods then do:
    create temp-goods .
    assign
      temp-goods.gds-code   = buf_goods.gds-code
      temp-goods.artic      = buf_goods.artic
      temp-goods.prod-code  = buf_goods.prod-code
      temp-goods.prod-type  = buf_goods.prod-type
      temp-goods.grp-name   = buf_goods.grp-name
      temp-goods.sum-reserv = buf_gds-obj.fact-qnty - buf_gds-obj.free-qnty
    .
    if g#gds-engl then assign temp-goods.gds-name = buf_goods.engl-name.
    else               assign temp-goods.gds-name = buf_goods.gds-name.
  end.
  else assign temp-goods.sum-reserv = temp-goods.sum-reserv + buf_gds-obj.fact-qnty - buf_gds-obj.free-qnty .

  /* *********************************************************** */
  find first Temp-obj1
    where Temp-obj1.gds-code = temp-goods.gds-code
      and Temp-obj1.obj-type = obj-list.obj-type
      and Temp-obj1.obj-code = obj-list.obj-code
    no-error .
  if not available Temp-obj1 then do:
    create Temp-obj1 .
    assign
      Temp-obj1.gds-code = temp-goods.gds-code
      Temp-obj1.obj-code = obj-list.obj-code
      Temp-obj1.obj-type = obj-list.obj-type
    .
  end.
  assign Temp-obj1.reserv = Temp-obj1.reserv + buf_gds-obj.fact-qnty - buf_gds-obj.free-qnty .
  /* *********************************************************** */


/* $Workfile$ e n d */