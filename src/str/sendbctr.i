/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Поиск цены в данной переоценке по данному бар-коду

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&SCOPED-DEFINE find-price  find first buf_price-list no-lock where ~
                            buf_price-list.doc-num    = ub.price-list.doc-num AND ~
                            buf_price-list.b-code     = buf_bar-code.B-CODE AND ~
                            buf_price-list.price-type = ""  no-error. ~
                            if avail buf_price-list then do: ~
                              assign ~
                              FOR-PRICE = buf_price-list.PRICE-SALE ~
                              plist-unit-cli = buf_bar-code.unit-cli. ~
                              LEAVE. ~
                            end.

def var plist-unit-cli  like ub.bar-code.unit-cli.
do while true:
  find first buf_price-list no-lock where
             buf_price-list.doc-num    = ub.price-list.doc-num AND
             buf_price-list.b-code     = LOC-BAR-CODE.B-CODE AND
             buf_price-list.price-type = "" no-error.
  if available buf_price-list then do:
    assign
    FOR-PRICE = buf_price-list.PRICE-SALE
    plist-unit-cli = loc-bar-code.unit-cli
    .
    LEAVE.
  end.
  if LOC-bar-code.unit-cli <> LOC-GOODS.UNIT-BASE then do:
    /*ищем на основной едизм*/
    find first buf_BAR-CODE no-lock WHERE
              buf_BAR-CODE.GDS-CODE    = loc-bar-code.gds-code AND
              buf_BAR-CODE.node-code   = LOC-BAR-CODE.node-code AND
              buf_bar-code.part-code   = loc-bar-code.part-code AND
              buf_bar-code.in-code = loc-bar-code.in-code AND
              buf_bar-code.unit-cli = loc-goods.unit-base No-ERROR.
    IF AVAIL buf_bar-code then do:
      {&find-price}
    end.
  END. /* LOC-bar-code.unit-cli <> LOC-GOODS.UNIT-BAS */
  /*если мы здесь значит основной едизм или не нашли - ищем дальше - непартионный*/
  IF loc-bar-code.in-code <> "" then do:
    find first buf_BAR-CODE no-lock where
                buf_BAR-CODE.GDS-CODE    = loc-bar-code.gds-code AND
                buf_BAR-CODE.node-code   = LOC-BAR-CODE.node-code AND
                buf_bar-code.part-code   = "" AND
                buf_bar-code.in-code = "" AND
                buf_bar-code.unit-cli = loc-goods.unit-base No-ERROR.
      IF AVAIL buf_bar-code then do:
        {&find-price}
      END.
  END.
  /*если мы здесь значит непартионный и основной едизм или не нашли значит берем главный*/
  if NOT avail buf_price-list then LEAVE.
END. /*while*/

error-status:error = no.
/* $Workfile$ e n d */