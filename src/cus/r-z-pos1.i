/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сравнительный отчет по ценам товара на объектах

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$".

  assign Counter1 = Counter1 + 1.
  { rep/repfrm.i disp Counter1 }

  find first temp-goods where temp-goods.gds-code = buf_gds-obj.gds-code no-error .
  if not available temp-goods then do:
    create temp-goods .

    find first buf_goods no-lock  where buf_goods.gds-code = buf_gds-obj.gds-code .

    { gbl/gdsbcode.i  buf_gds-obj.gds-code  ?  ii  no-error }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении бар-кода товара" skip
        "Код товара" buf_goods.artic skip
      view-as alert-box error .
      undo, return error .
    end.

    assign
      temp-goods.gds-code  = buf_goods.gds-code
      temp-goods.artic     = buf_goods.artic
      temp-goods.prod-code = buf_goods.prod-code
      temp-goods.prod-type = buf_goods.prod-type
      temp-goods.grp-name  = buf_goods.grp-name
      temp-goods.b-code    = string(ii,"9999999999999")
/*      temp-goods.grp-name      = entry ( num-entries( buf_goods.grp-name, {&slash-char} ), buf_goods.grp-name, {&slash-char} )*/
    .
    if g#gds-engl then assign temp-goods.gds-name = buf_goods.engl-name.
    else               assign temp-goods.gds-name = buf_goods.gds-name.
  end.

/* $Workfile$ e n d */