block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fextract.p $
$Archive: rep/fextract.p $

Выписка из лицевого счета клиента

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/25/04
Author: Bakhtadze Natalya
Creation date: 02/25/04

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-host-code like ub.fin-schet.host-code no-undo .
define input parameter p-code-schet like ub.fin-schet.code-schet no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fextract.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/fextract.p $":U .
define variable vss-description as character no-undo init "Выписка из лицевого счета клиента".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ trg/factord.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define variable v-is-ok as logical no-undo .
define variable v-from-date as date no-undo .
define variable v-to-date as date no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-debet like ub.fin-doc.sum-doc no-undo .
define variable v-credit like ub.fin-doc.sum-doc no-undo .
define variable v-debet-ob like ub.fin-doc.sum-doc no-undo .
define variable v-credit-ob like ub.fin-doc.sum-doc no-undo .
define variable v-my-side as logical no-undo .

define variable line as character no-undo .
define variable date_string as character no-undo .
define variable v-from-sum as decimal no-undo .
define variable v-from-sum-i as decimal no-undo .
define variable v-from-sum-e as decimal no-undo .
define variable v-to-sum-arh as decimal no-undo .
define variable v-to-sum-doc as decimal no-undo .
define variable v-last-doc-str as character no-undo .
define variable v-last-doc-fact-date as date no-undo .
define variable v-from-fact-order like ub.fin-doc.fact-order no-undo .
define variable v-from-fact-order-i like ub.fin-doc.fact-order no-undo .
define variable v-from-fact-order-e like ub.fin-doc.fact-order no-undo .
define variable v-to-fact-order like ub.fin-doc.fact-order no-undo .
define variable v-vo as character no-undo .
define variable v-debet-str as character no-undo .
define variable v-credit-str as character no-undo .
define variable v-c-schet like ub.fin-doc.receiver-c-schet no-undo .
define variable glog as logical no-undo .

define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_currency for ub.currency.
define buffer buf_fin-doc for ub.fin-doc.
define buffer last_fin-doc for ub.fin-doc.
define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_clients for ub.clients.
define buffer buf_arh-fin-doc-schet for ub.arh-fin-doc-schet.
define buffer buf_sysconf for ub.sysconf.


DEFINE FRAME extract
v-vo COLUMN-LABEL "ВО" format "X(4)"
buf_fin-doc.prn-doc-code COLUMN-LABEL "Номер документа"
buf_fin-doc.receiver-c-schet COLUMn-LABEL "Номер корр. счета"
v-debet COLUMN-LABEL "Дебет!(-)"
v-credit COLUMN-LABEL "Кредит!(+)"
HEADER  string( "Страница " ) format "X(9)" AT 105 PAGE-NUMBER(PrnLibStream) AT 115 FORMAT ">>9" SKIP
Line format "X(134)"
with width {&A4_CW0} down  stream-io use-text  .

do
on error undo, return error return-value
:
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_reports_print':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  true
  glog
  }

  if not glog then return.
  run cur-time in this-procedure(output v-today, output v-time).
  assign
  v-from-date = v-today - 1
  v-to-date = v-today - 1
  .
  run gbl/get-per.w (
                    OUTPUT v-is-ok
                    ,input-output v-from-date
                    ,input-output v-to-date
                    ).

  if not v-is-ok then return.

  Line = fill("-", 134).
  date_string = replace(cur-time-string-sec(), {&slash-char}, ".":U) .
  find first buf_fin-schet no-lock where
            buf_fin-schet.host-code = p-host-code
        AND buf_fin-schet.code-schet = p-code-schet no-error .
  if not available buf_fin-schet then do:
    return error .
  end.
  find first buf_fin-bank no-lock where
          buf_fin-bank.host-code = buf_fin-schet.host-code
    AND  buf_fin-bank.code-bank = buf_fin-schet.code-bank no-error .
  if not available buf_fin-bank then do:
    return error .
  end.
  find first buf_clients no-lock where
            buf_clients.obj-type = buf_fin-schet.cli-type
        AND buf_clients.obj-code = buf_fin-schet.cli-code no-error .
  if not available buf_clients then do:
    return error .
  end.
  if buf_clients.obj-type = {&cmp}
  and buf_Clients.obj-code = p-host-code
  then do:
    assign
    v-my-side = yes
    .
  end.
  find first buf_currency no-lock where
            buf_currency.curr-code = buf_fin-schet.curr-code no-error .
  if not available buf_currency then do:
    return error .
  end.

  /*найдем fact-order на начало дня от v-from-date */

  run day-begin-fact-order (
      input  v-from-date
    ,output v-from-fact-order) .

  /*найдем fact-order на конец дня от v-to-date */

  run factord-end-day (
      input  v-to-date
    ,output v-to-fact-order) .

  /*получим дату последнeй операции меньшей v-from-date*/

  find last last_fin-doc no-lock where
            last_fin-doc.host-code = p-host-code
        AND last_fin-doc.status_ = {&fin-fact}
        AND last_fin-doc.fact-order < v-from-fact-order
        AND last_fin-doc.receiver-code-schet = p-code-schet no-error .
  if available last_fin-doc then do:
    assign
    v-last-doc-fact-date = last_fin-doc.fact-date

    .
  end.
  else do:
    assign
    v-last-doc-fact-date = 01/01/1990
    .
  end.

  find last last_fin-doc no-lock where
            last_fin-doc.host-code = p-host-code
        AND last_fin-doc.status_ = {&fin-fact}
        AND last_fin-doc.fact-order < v-from-fact-order
        AND last_fin-doc.payer-code-schet = p-code-schet no-error .
  if available last_fin-doc then do:
    assign
    v-last-doc-fact-date = max(last_fin-doc.fact-date, v-last-doc-fact-date)
    .
  end.
  else do:
    assign
    v-last-doc-fact-date = v-last-doc-fact-date
    .
  end.

  assign
  v-last-doc-str = if v-last-doc-fact-date = 01/01/1990
                  then "":U
                  else string(v-last-doc-fact-date, "99.99.9999":U)
  .

  /*получим остаток на начало дня*/
  find last  buf_arh-fin-doc-schet no-lock where
            buf_arh-fin-doc-schet.host-code = p-host-code
        AND buf_arh-fin-doc-schet.code-schet = p-code-schet
        AND buf_arh-fin-doc-schet.calc-curr-code = buf_fin-schet.curr-code
        AND buf_arh-fin-doc-schet.sum-type  = "":U
        AND buf_arh-fin-doc-schet.fin-ext-doc-type = {&FDEDT_Income_Cashless}
        AND buf_arh-fin-doc-schet.fact-order < v-from-fact-order no-error .
  if available buf_arh-fin-doc-schet then do:
    assign
    v-from-sum-i = (if v-my-side then buf_arh-fin-doc-schet.income else buf_arh-fin-doc-schet.expense)
    v-from-fact-order-i = buf_arh-fin-doc-schet.fact-order
    .
  end.

  find last  buf_arh-fin-doc-schet no-lock where
            buf_arh-fin-doc-schet.host-code = p-host-code
        AND buf_arh-fin-doc-schet.code-schet = p-code-schet
        AND buf_arh-fin-doc-schet.calc-curr-code = buf_fin-schet.curr-code
        AND buf_arh-fin-doc-schet.sum-type  = "":U
        AND buf_arh-fin-doc-schet.fin-ext-doc-type = {&FDEDT_Expense_Cashless}
        AND buf_arh-fin-doc-schet.fact-order < v-from-fact-order no-error .
  if available buf_arh-fin-doc-schet then do:
    assign
    v-from-sum-e = (if v-my-side then buf_arh-fin-doc-schet.expense else buf_arh-fin-doc-schet.income)
    v-from-fact-order-e = buf_arh-fin-doc-schet.fact-order
    .
  end.

  assign
  v-from-sum = if v-my-side
               then (v-from-sum-i - v-from-sum-e)
               else (v-from-sum-e - v-from-sum-i)
  .
  /*получим остаток на конец дня*/
  /*а нужно ли?
  ведь архив рассчитвается по закрытию документа а мы пройдем по все документам*/



  run waitfram-show in this-procedure ("Ждите...").

  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input {&CS_PS}
                                              ,input yes /*p-is-stream*/
                                              ,input no /*p-append*/
                                              ).
  FORM with FRAME extract  .
  FORM HEADER
  Line format "X(134)" SKIP
  "Продолжение - на следующей странице" AT 30 SKIP
  with FRAME BottomFrame width {&A4_CW0} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW  STREAM PrnLibStream FRAME BottomFrame .




  PUT  STREAM PrnLibStream unformatted
  line skip(1)
  SPACE(25) "ВЫПИСКА ИЗ ЛИЦЕВОГО СЧЕТА КЛИЕНТА"  space(25) date_string skip(1)
  buf_fin-bank.short-name space(10) "БИК" {&space-char} buf_fin-bank.bik space(10) "корр. счет" {&space-char} buf_fin-bank.cor-acc skip(1)
  "Наименование клиента: " buf_clients.obj-name skip(1)
  "Валюта счета: " buf_currency.curr-abbr {&slash-char} buf_currency.okv-code {&space-char} buf_currency.curr-name skip(1)
  "Номер счeта: " buf_fin-schet.r-schet
  skip(1)
  line skip(1)
  "Дата последней операции: " v-last-doc-str skip(1)
  "Входящий остаток на начало дня: "  v-from-sum skip(1)
  .

  /*печать документов закрытых на факт по этому счету*/
  for each buf_arh-fin-doc-schet  no-lock where
          buf_arh-fin-doc-schet.host-code = p-host-code
      AND buf_arh-fin-doc-schet.code-schet = p-code-schet
      AND buf_arh-fin-doc-schet.fact-order >= v-from-fact-order
      AND buf_arh-fin-doc-schet.fact-order <= v-to-fact-order
      AND buf_arh-fin-doc-schet.calc-curr-code = buf_fin-schet.curr-code
      AND buf_arh-fin-doc-schet.sum-type = "":U,
     first buf_fin-doc no-lock where
              buf_fin-doc.fin-doc-code = buf_arh-fin-doc-schet.fin-doc-code
          AND buf_fin-doc.host-code = buf_arh-fin-doc-schet.host-code:
    CASE buf_fin-doc.fin-ext-doc-type:
      when {&FDEDT_Expense_Cashless} then do:
        assign
        v-vo = "01":U
        v-c-schet = buf_Fin-doc.receiver-c-schet
        v-debet = (if v-my-side then buf_fin-doc.sum-doc else 0)
        v-credit = (if v-my-side then 0 else buf_fin-doc.sum-doc)
        v-debet-str   = (if v-my-side then string(buf_fin-doc.sum-doc) else "":U)
        v-credit-str   = (if v-my-side then "":U else string(buf_fin-doc.sum-doc))
        v-debet-ob = v-debet-ob + v-debet
        v-credit-ob = v-credit-ob + v-credit
        .
      end.
      when {&FDEDT_Income_Cashless}
      then do:
        assign
        v-vo = "01":U
        v-c-schet = buf_Fin-doc.payer-c-schet
        v-credit = (if v-my-side then buf_fin-doc.sum-doc else 0)
        v-debet = (if v-my-side then 0 else buf_fin-doc.sum-doc)
        v-credit-str   = (if v-my-side then string(buf_fin-doc.sum-doc) else "":U)
        v-debet-str = (if v-my-side then "":U else string(buf_fin-doc.sum-doc))
        v-credit-ob = v-credit-ob + v-credit
        v-debet-ob = v-debet-ob + v-debet
        .
      end.
    END CASE.
    Display STREAM PrnLibStream
    v-vo
    buf_fin-doc.prn-doc-code
    v-c-schet @ buf_fin-doc.receiver-c-schet
    v-debet
    v-credit
    with FRAME extract .
    DOWN STREAM PrnLibStream
    with frame extract .
  end. /*for each buf_fin-doc*/
  assign
  v-to-sum-doc = v-from-sum - v-debet-ob + v-credit-ob
  .

  DOWN STREAM PrnLibStream 1
  with frame extract.
  display stream PrnLibstream
  "ИТОГО" @ buf_fin-doc.prn-doc-code
  "Обороты по дебету" @ v-debet
  "Обороты по кредиту" @ v-credit
  with FRAME extract .
  DOWN STREAM PrnLibStream 2
  with frame extract.
  display stream PrnLibstream
  "Сумма в валюте счета:" @ v-vo
  v-debet-ob @ v-debet
  v-credit-ob @ v-credit
  with FRAME extract .
  DOWN STREAM PrnLibStream 2
  with frame extract.
  Put stream Prnlibstream unformatted
  substitute("Исходящий остаток на конец дня &1: &2", string(v-to-date, "99.99.9999":U) , v-to-sum-doc) skip(1)
  line skip.

  HIDE  STREAM PrnLibStream FRAME BottomFrame .
  HIDE  STREAM PrnLibStream FRAME extract.

  output  STREAM PrnLibStream CLOSE.

  run waitfram-hide in this-procedure .
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 0
                                            ).

end. /*doe*/