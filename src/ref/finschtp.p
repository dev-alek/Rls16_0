block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: finschtp.p $
$Archive: ref/finschtp.p $

Печать карточки банковского счета

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/24/03
Author: Bakhtadze Natalya
Creation date: 10/24/03

*/

DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-host-code like ub.fin-schet.host-code no-undo.
define input parameter p-code-schet like ub.fin-schet.code-schet no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: finschtp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/finschtp.p $":U .
define variable vss-description as character no-undo init "Печать карточки банковского счета".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/r-pril.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }



define variable date_string     as      char    no-undo.
define variable Line            as      char    no-undo.
define variable v-title         as character no-undo .
define variable v-status        as character no-undo .
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_clients for ub.clients.
define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_currency for ub.currency.
define buffer buf_schet-clients for ub.clients.

do
on error undo, return error
:


  find first buf_fin-schet no-lock where
            buf_fin-schet.host-code = p-host-code
        AND buf_fin-schet.code-schet = p-code-schet no-error.
  if not available buf_fin-schet then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найден банковский счет" skip
    "p-host-code"  p-host-code skip
    "p-code-schet" p-code-schet
    view-as alert-box error .
    undo, return error.
  end.

  find first buf_clients no-lock where
            buf_clients.obj-type = {&cmp}
        AND buf_clients.obj-code = buf_fin-schet.host-code .

  find first buf_schet-clients no-lock where
            buf_schet-clients.obj-type = buf_fin-schet.cli-type
        AND buf_schet-clients.obj-code = buf_fin-schet.cli-code .

  find first buf_currency no-lock where
            buf_currency.curr-code= buf_fin-schet.curr-code.

  find first buf_fin-bank no-lock where
            buf_fin-bank.host-code = buf_fin-schet.host-code
        AND buf_fin-bank.code-bank = buf_fin-schet.code-bank .




  DEFINE FRAME TopFrame
  buf_fin-schet.host-code column-label "Код фирмы"
  buf_clients.obj-name   column-label "Фирма"
  buf_fin-schet.code-schet column-label "Код счета"
  buf_fin-schet.status_   column-label "Статус"
  HEADER
  date_string AT 5 format "X(35)"
  string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
  Line format "X(195)" AT 1
  with FRAME TopFrame width {&DOS_CW_2} down stream-io use-text    .

  Line = fill("-", 195).
  date_string = cur-time-print() .

  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input {&LS_PS_A4}
                                              ,input yes /*p-is-stream*/
                                              ,input no /*p-append*/
                                              ).

  PUT  STREAM PrnLibStream UNFORMATTED
  SPACE(25) "Информация о банковском счете"
  SKIP(1) .

  FORM HEADER
  Line format "X(195)" AT 1 SKIP
  "Продолжение - на следующей странице" AT 30 SKIP
  with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW  STREAM PrnLibStream FRAME BottomFrame .
  run waitfram-show in this-procedure ("Ждите...").


  FORM with frame TopFrame.
  display stream PrnLibStream
  buf_fin-schet.host-code
  buf_clients.obj-name
  buf_fin-schet.code-schet
  buf_fin-schet.status_
  with frame TopFrame.
  DOWN stream PrnLibStream 3
  with frame TopFrame.
  Put Stream PrnLibStream unformatted
  "Держатель счета" {&space-char} buf_fin-schet.cli-type buf_fin-schet.cli-code {&space-char}
   buf_schet-clients.obj-name skip
  "Код банка" {&space-char} buf_fin-schet.code-bank fill({&space-char}, 5)
  buf_fin-bank.bank-name skip
  "БИК" {&space-char} buf_fin-bank.bik  skip
  "Валюта счета" {&space-char} buf_fin-schet.curr-code {&space-char} buf_currency.curr-abbr skip
  "Расч. счет" {&space-char} buf_fin-schet.r-schet fill({&space-char}, 5)
  "Корр. счет" {&space-char} buf_fin-schet.c-schet
  "Примечания" {&space-char}   buf_fin-schet.PS
  skip.
  HIDE  STREAM PrnLibStream FRAME BottomFrame .
  output  STREAM PrnLibStream CLOSE.
  run waitfram-hide in this-procedure .
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 8
                                            ).

end.