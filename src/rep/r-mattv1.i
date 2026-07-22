/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

кусок r-mattov.p

Автор: Демин Алексей Сергеевич
Дата создания: 09/11/07
Author: Alexey Demin
Creation date: 09/11/07

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


  assign Counter1 = Counter1 + 1.
  { rep/repfrm.i disp Counter1 }
  find first buf_gds-obj-prop no-lock
    where buf_gds-obj-prop.obj-type = p-cli-type1
      and buf_gds-obj-prop.obj-code = p-cli-code1
      and buf_gds-obj-prop.gds-code = buf_goods.gds-code
  no-error .
  if available buf_gds-obj-prop then assign   v-min-qnty = buf_gds-obj-prop.gdop-min-stock  .
  else  assign v-min-qnty = 0 .

  if v-min-qnty = 0 or v-min-qnty = ? then next .

  create temp-gds .
  assign
    temp-gds.prod-type = buf_goods.prod-type
    temp-gds.prod-code = buf_goods.prod-code
    temp-gds.artic     = buf_goods.artic
    temp-gds.unit-base = buf_goods.unit-base
    temp-gds.gds-code  = buf_goods.gds-code
    temp-gds.gds-name  = buf_goods.gds-name
    temp-gds.grp-code  = buf_goods.grp-code
    temp-gds.grp-name  = trim( buf_goods.grp-name )
    temp-gds.min-qnty  = v-min-qnty
  .

/* $Workfile$ e n d */