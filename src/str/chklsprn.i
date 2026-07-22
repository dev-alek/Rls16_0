/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт списка чеков с содержанием в формате EXCEL и обычном формате

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/09/07
Author: Bakhtadze Natalya
Creation date: 08/09/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FOR EACH {1} No-LOCK,
    each buf_chk-gds no-lock where
        buf_chk-gds.doc-code = {1}.doc-code
BREAK
BY {1}.doc-code
BY buf_chk-gds.line-num
:

  for-chk-type-gds = get-chk-type({1}.doc-code, {1}.chk-type, {1}.is-wth).
  if first-of({1}.doc-code) then do:
    { rep/dincol.i di 1 for-doc-code-gds
                  {1}.doc-code }

    { rep/dincol.i di 2 for-chk-type-gds
                  "get-chk-type({1}.doc-code, {1}.chk-type, {1}.is-wth )" }

    { rep/dincol.i di 3 for-obj-code-gds
                  {1}.obj-code }

    { rep/dincol.i di 4 for-chk-date-gds
                  "string({1}.chk-date, '99/99/9999')" }

    { rep/dincol.i di 5 for-chk-time-gds
                  "string({1}.chk-time, 'hh:mm:ss')" }

    { rep/dincol.i di 12 for-src-code  {1}.d-card }

    {&putexcel}
    { rep/dincol.i dix 1 for-doc-code-gds {1}.doc-code }
    { rep/dincol.i dix 2 for-chk-type-gds  "get-chk-type({1}.doc-code, {1}.chk-type, {1}.is-wth )" }
    { rep/dincol.i dix 3 for-obj-code-gds {1}.obj-code }
    { rep/dincol.i dix 4 for-chk-date-gds  "string({1}.chk-date, '99/99/9999')" }
    { rep/dincol.i dix 5 for-chk-time-gds  "string({1}.chk-time, 'hh:mm:ss')" }
    { rep/dincol.i dix 12 for-src-code  {1}.d-card }
    skip.
  end.
  for each buf_chk-pay no-lock where
          buf_chk-pay.doc-code = {1}.doc-code:
     find first buf_cash-pay no-lock
             where buf_cash-pay.cdpay-code = buf_chk-pay.pay-code
               and buf_cash-pay.curr-code = buf_chk-pay.curr-code no-error.

    { rep/dincol.i di 6 for-line-num
                  buf_chk-pay.line-num }

    { rep/dincol.i di 7 for-b-code
                  buf_chk-pay.pay-code }

    { rep/dincol.i di 8 for-artic
                  f-paycardv(buf_chk-pay.pay-card,buf_chk-pay.pay-code,buf_chk-pay.curr-code) }

    { rep/dincol.i di 9 for-gds-name
                  "(if available buf_cash-pay then buf_cash-pay.obj-name else '':U)" }


    { rep/dincol.i di 17 for-price-base  buf_chk-pay.tot-sum }

    {&DISPLAY-FRAME}

    {&putexcel}
    { rep/dincol.i dix 6 for-line-num  buf_chk-pay.line-num }

    { rep/dincol.i dix 7 for-b-code    buf_chk-pay.pay-code }

    { rep/dincol.i dix 8 for-artic     "(if available buf_cash-pay then buf_cash-pay.obj-name else '':U)" }

    { rep/dincol.i dix 9 for-gds-name   f-paycardv(buf_chk-pay.pay-card,buf_chk-pay.pay-code,buf_chk-pay.curr-code) }

    { rep/dincol.i dix 17 for-price-base  buf_chk-pay.tot-sum }
    skip.
  end.



  FIND FIRST buf_bar-code No-LOCK WHERE
              buf_bar-code.b-code = buf_chk-gds.b-code NO-ERROR.
  IF AVAIL buf_bar-code then do:
    FIND FIRST buf_goods NO-LOCK WHERE
                buf_goods.gds-code = buf_bar-code.gds-code NO-ERROR.

    FIND FIRST  buf_clients NO-LOCK WHERE
                buf_clients.obj-type = buf_goods.prod-type AND
                buf_clients.obj-code = buf_goods.prod-code NO-ERROR.
    FIND FIRST buf_gds-prt No-LOCK where
                buf_gds-prt.upper-code = buf_goods.prt-root NO-ERROR.
  end.
  else do:
    release buf_goods.
    release buf_clients.
    release buf_gds-prt.
  end.
  assign
  accum-count = accum-count + 1
  .


  { rep/dincol.i di 6 for-line-num
                 buf_chk-gds.line-num }

  { rep/dincol.i di 7 for-b-code
                 buf_chk-gds.b-code }

  { rep/dincol.i di 8 for-artic
                 "(if available buf_goods then buf_goods.artic else '':U)" }


  { rep/dincol.i di 9 for-gds-name
                 "(if available buf_goods then buf_goods.gds-name else 'НЕИЗВЕСТНЫЙ ТОВАР':U)" }

  { rep/dincol.i di 10 for-prt-name
                 "(if available buf_gds-prt then buf_gds-prt.f-name else '':U)" }

  { rep/dincol.i di 11 for-err-gds
                 buf_chk-gds.is-error }

  { rep/dincol.i di 12 for-src-code
                 buf_chk-gds.src-code }

  { rep/dincol.i di 13 for-pump  buf_chk-gds.pump }

  { rep/dincol.i di 14 for-prod-name
                 "(if available buf_Clients then buf_clients.obj-name else '':U)" }

  { rep/dincol.i di 15 for-doc-qnty buf_chk-gds.doc-qnty }

  { rep/dincol.i di 16 for-unit-cli  "(if available buf_bar-code then buf_bar-code.unit-cli else '':U)" }

  { rep/dincol.i di 17 for-price-base  buf_chk-gds.price-base }

  { rep/dincol.i di 18 for-gds-discnt buf_chk-gds.discnt }

  { rep/dincol.i di 19 for-discnt-pcnt  "(buf_chk-gds.discnt / (buf_chk-gds.price-base * 100))" }

  { rep/dincol.i di 20 for-price-netto  "(buf_chk-gds.price-base - buf_chk-gds.discnt)" }

  { rep/dincol.i di 21 for-write-off
                 "(if buf_chk-gds.write-off-code <> ? ~
                  and buf_chk-gds.write-off-code <> 0 ~
                  then yes ~
                  else no) " }


  {&DISPLAY-FRAME}

  {&PutExcel}
  { rep/dincol.i dix 6 for-line-num     buf_chk-gds.line-num }
  { rep/dincol.i dix  7 for-b-code     buf_chk-gds.b-code }
  { rep/dincol.i dix  8 for-artic    "(if available buf_goods then buf_goods.artic else '':U)" }
  { rep/dincol.i dix  9 for-gds-name  "(if available buf_goods then buf_goods.gds-name else 'НЕИЗВЕСТНЫЙ ТОВАР':U)" }
  { rep/dincol.i dix  10 for-prt-name  "(if available buf_gds-prt then buf_gds-prt.f-name else '':U)" }
  { rep/dincol.i dix  11 for-err-gds   buf_chk-gds.is-error }
  { rep/dincol.i dix  12 for-src-code  buf_chk-gds.src-code }
  { rep/dincol.i dix  13 for-pump      buf_chk-gds.pump  }
  { rep/dincol.i dix  14 for-prod-name  "(if available buf_Clients then buf_clients.obj-name else '':U)" }
  { rep/dincol.i dix  15 for-doc-qnty buf_chk-gds.doc-qnty }
  { rep/dincol.i dix  16 for-unit-cli  "(if available buf_bar-code then buf_bar-code.unit-cli else '':U)" }
  { rep/dincol.i dix  17 for-price-base  buf_chk-gds.price-base }
  { rep/dincol.i dix  18 for-gds-discnt  buf_chk-gds.discnt }
  .

  {&PutExcel}
  { rep/dincol.i dix  19 for-discnt-pcnt  "(buf_chk-gds.discnt / (buf_chk-gds.price-base * 100))" }
  { rep/dincol.i dix  20 for-price-netto  "(buf_chk-gds.price-base - buf_chk-gds.discnt)" }
  { rep/dincol.i dix  21 for-write-off   "(if buf_chk-gds.write-off-code <> ? ~
                                      and buf_chk-gds.write-off-code <> 0 ~
                                      then yes ~
                                      else no) "
                                      }
  skip.


  IF LAST({1}.doc-code) then do:

    {&UNDERLINE-FRAME}

    { rep/dincol.i di  1 for-doc-code-gds
                   string(accum-count) }

    { rep/dincol.i di 2 for-chk-type-gds
                   " 'строк' " }

    {&DISPLAY-FRAME}

  end.

END. /*for each {1} */

/* $Workfile$ e n d */