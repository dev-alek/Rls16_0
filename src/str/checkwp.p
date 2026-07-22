block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: checkwp.p $
$Archive: str/checkwp.p $

Печать одного чека МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

*/

define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER pardoc-code like chk-doc.doc-code no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: checkwp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/checkwp.p $":U .
define variable vss-description as character no-undo init "Печать одного чека МЦ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ str/shftnmef.i chk-doc shift-name }

define variable sym1   as char format "X(1)" init ":".
define variable sym10 as char format "X(1)" init ":".
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.


DEFINE FRAME Pay-Frame
chk-pay.curr-code column-label "Код. вал"
currency.curr-name column-label "Валюта" FORMAT "X(15)"
chk-pay.pay-code Column-label "Код платежа"
cash-pay.obj-name COLUMn-LABEL "Платеж"
cash-pay.wth-code COLUMN-LABEL "Код МЦ"
wealth.wth-name COLUMn-LABEL "МЦ" format "X(20)"
chk-pay.tot-sum COLUMN-LABEL "Сумма в вал. платежа"
chk-pay.cash-rate COLUMN-LABEL "Курс валюты"
with width {&DOS_CW_2} down stream-io use-text    .


run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).




VIEW  STREAM PrnLibStream FRAME BottomFrame .


FIND FIRST chk-doc NO-LOCK WHERE chk-doc.doc-code = pardoc-code NO-ERROR.
IF NOT avail chk-doc then return.


Line = fill("-", 141).
date_string = cur-time-print() .


PUT STREAM PrnLibStream UNFORMATTED
line skip(0)
date_string skip(0)
"Чек N "
chk-doc.doc-code SPace(1)
"Магазин N " string(chk-doc.obj-code, ">>>>9") space(1)
"Дата: " string(chk-doc.chk-date, "99/99/9999") space(1)
"Время: " string(chk-doc.chk-time, "HH:MM") space(1)
"Дата смены: " string(chk-doc.shift-date, "99/99/9999") space(1)
"Номер смены: " shift-name-no-err(buffer chk-doc) format "X(6)" space(1)
 skip(0)
"Касса N" string(chk-doc.pay-desk, ">>>>9") space(1)
"Номер по кассе " string(chk-doc.chk-num, "9999999") space(1)
"Кассир: " string(chk-doc.cashier, ">>>>9") space(1)
skip(0)
.
FORM with FRAME PAY-Frame  .


PUT STREAM PrnLibStream
SKIP(1)
"ОПЛАТЫ ПО ЧЕКУ:" skip(0)
.

FOR EACH chk-pay No-LOCK WHERE
         chk-pay.doc-code = chk-doc.doc-code :
    FIND FIRST currency No-LOCK WHERE
               currency.curr-code = chk-pay.curr-code NO-ERROR.
    FIND FIRST cash-pay No-LOCK WHERE
              cash-pay.cdpay-code = chk-pay.pay-code AND
              cash-pay.curr-code = chk-pay.curr-code No-ERROR.
    if available cash-pay then do:
      if cash-pay.wth-code > 0 then do:
        FIND FIRST wealth No-LOCK WHERE
                   wealth.wth-code = cash-pay.wth-code No-ERROR.
      end.
      else release wealth.
    end.
    else release wealth.
    DISPLAY STREAM PrnLibStream
    chk-pay.curr-code
    if avail currency then currency.curr-name else "НЕОПОЗНАННАЯ ВАЛЮТА" @ currency.curr-name
    chk-pay.pay-code
    if avail cash-pay then cash-pay.obj-name else "НЕОПОЗНАННАЯ ОПЛАТА" @ cash-pay.obj-name
    if avail cash-pay then cash-pay.wth-code else ? @ cash-pay.wth-code
    if avail wealth then wealth.wth-name else "НЕОПОЗНАННАЯ МЦ" @ wealth.wth-name
    chk-pay.tot-sum
    chk-pay.cash-rate

    WITH FRAME Pay-Frame.
    DOWN STREAM PrnLibStream
    WITH FRAME Pay-Frame.
END.
UNDERLINE STREAM PrnLibStream
chk-pay.curr-code
currency.curr-name
chk-pay.pay-code
cash-pay.obj-name
cash-pay.wth-code
wealth.wth-name
chk-pay.tot-sum
chk-pay.cash-rate
WITH FRAME Pay-Frame.
DOWN STREAM PrnLibStream
WITH FRAME Pay-Frame.

HIDE  STREAM PrnLibStream FRAME Pay-Frame.
HIDE  STREAM PrnLibStream FRAME Bottom-Frame.

output  STREAM PrnLibStream CLOSE.

run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).