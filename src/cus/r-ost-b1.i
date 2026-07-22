/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

для прогр r-ost-bd.p

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/23/06
Author: Michael Kochetkov
Creation date: 03/23/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

  assign Counter1 = Counter1 + 1.
  { rep/repfrm.i disp Counter1 }

  find first temp-goods
    where temp-goods.gds-code = buf_gds-obj.gds-code
    no-error .
  if not available temp-goods then do:
    create temp-goods .
    assign
      temp-goods.gds-code      = buf_goods.gds-code
      temp-goods.artic         = buf_goods.artic
      temp-goods.prod-code     = buf_goods.prod-code
      temp-goods.prod-type     = buf_goods.prod-type
      temp-goods.grp-name      = buf_goods.grp-name
      temp-goods.full-grp-name = buf_goods.grp-name
      temp-goods.grp-name      = entry ( num-entries(right-trim(buf_goods.grp-name, {&delim-grp}), {&delim-grp} ), buf_goods.grp-name, {&delim-grp} )
    .
    if g#gds-engl then assign temp-goods.gds-name = buf_goods.engl-name.
    else               assign temp-goods.gds-name = buf_goods.gds-name.
  end.

/* $Workfile$ e n d */