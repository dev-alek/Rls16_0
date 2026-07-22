block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: finbankp.p $
$Archive: ref/finbankp.p $

Печать карточки банка

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/23/03
Author: Bakhtadze Natalya
Creation date: 10/23/03

*/

DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-host-code like ub.fin-bank.host-code no-undo.
define input parameter p-code-bank like ub.fin-bank.code-bank no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: finbankp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/finbankp.p $":U .
define variable vss-description as character no-undo init "Печать карточки банка".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-pril.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }



define variable date_string     as      char    no-undo.
define variable Line            as      char    no-undo.
define variable v-title         as character no-undo .
define variable v-status        as character no-undo .
define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_clients for ub.clients.

do
on error undo, return error
:


  find first buf_fin-bank no-lock where
            buf_fin-bank.host-code = p-host-code
        AND buf_fin-bank.code-bank = p-code-bank no-error.
  if not available buf_fin-bank then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найден банк" skip
    "p-host-code"  p-host-code skip
    "p-code-bnak" p-code-bank
    view-as alert-box error .
    undo, return error.
  end.

  find first buf_clients no-lock where
            buf_clients.obj-type = {&cmp}
        AND buf_clients.obj-code = buf_fin-bank.host-code .


  DEFINE FRAME TopFrame
  buf_fin-bank.host-code column-label "Код фирмы"
  buf_clients.obj-name   column-label "Фирма"
  buf_fin-bank.code-bank column-label "Код банка"
  buf_fin-bank.status_   column-label "Статус"
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
  SPACE(25) "Информация о банке"
  SKIP(1) .

  FORM HEADER
  Line format "X(195)" AT 1 SKIP
  "Продолжение - на следующей странице" AT 30 SKIP
  with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW  STREAM PrnLibStream FRAME BottomFrame .
  run waitfram-show in this-procedure ("Ждите...").


  FORM with frame TopFrame.
  display stream PrnLibStream
  buf_fin-bank.host-code
  buf_clients.obj-name
  buf_fin-bank.code-bank
  buf_fin-bank.status_
  with frame TopFrame.
  DOWN stream PrnLibStream 3
  with frame TopFrame.
  Put Stream PrnLibStream unformatted
  "БИК" {&space-char} buf_fin-bank.bik fill({&space-char}, 5)
  "{&abbr_inn_allshift}" {&space-char} buf_fin-bank.inn fill({&space-char}, 5)
  "{&abbr_kpp_allshift}" {&space-char} buf_fin-bank.kpp fill({&space-char}, 5)
  skip
  "Корр.счет"  {&space-char} buf_fin-bank.cor-acc skip
  "Наим. банка" {&space-char} buf_fin-bank.bank-name skip
  "Кратк. назв." {&space-char}  buf_fin-bank.short-name  skip
  "Лицензия" {&space-char} buf_fin-bank.licenz skip
  "Адрес юрид." {&space-char} entry(1, buf_fin-bank.addres, {&delim-par}) skip
  "Адрес почт." {&space-char} buf_fin-bank.addres1 skip
  "Телефон" {&space-char} buf_fin-bank.phone fill( {&space-char}, 5)
  "Факс" {&space-char} buf_fin-bank.fax skip
  "E-mail" {&space-char} buf_fin-bank.e-mail skip
  "ОКАТО" {&space-char} buf_fin-bank.okato  fill ( {&space-char}, 5)
  "{&abbr_okonh_allshift}" {&space-char} buf_fin-bank.okonx fill ( {&space-char}, 5)
  "ОКПО" {&space-char}  buf_fin-bank.okpo format "X(10)" skip
  "Примечания" {&space-char}   buf_fin-bank.PS
  skip.
  HIDE  STREAM PrnLibStream FRAME BottomFrame .
  output  STREAM PrnLibStream CLOSE.
  run waitfram-hide in this-procedure .
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 8
                                            ).

end.