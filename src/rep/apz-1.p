block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: apz-1.p $
$Archive: rep/apz-1.p $

Печать платежа  типа приход-расход АПЗ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/20/03
Author: Bakhtadze Natalya
Creation date: 11/20/03

*/

DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define parameter buffer buf_fin-doc for ub.fin-doc.
define input parameter p-append as logical no-undo .
define input parameter p-is-last as logical no-undo .
define input parameter p-from-forms as logical no-undo .
define input-output parameter p-format as integer no-undo .
/*1 - Landscape 0 -portrait*/

&SCOP f-l MonthNameRusGen

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: apz-1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/apz-1.p $":U .
define variable vss-description as character no-undo init "Печать платежа  типа приход-расход АПЗ".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ rep/frmlib.i }
{ gbl/waitfram.i }

define variable g#quest-print   as logical      no-undo.
define variable g#report-num  as integer no-undo .
define variable Line as character no-undo .
define variable num-lines as integer no-undo .
define variable v-fill as character no-undo init "_".
define variable v-sum-doc-v1 as character no-undo .
define variable v-sum-doc-v2 as character no-undo .
define variable v-sum-doc-n1 as character no-undo .
define variable v-sum-doc-n2 as character no-undo .
define variable v-sum-kop-p  as character no-undo .
define variable v-dops as character no-undo .
define variable v-head-position as character no-undo .
define variable v-payer-sign1 as character no-undo .
define variable v-receiver-sign1 as character no-undo .
define variable v-rub as character no-undo .
define variable v-kop as character no-undo .
define variable v-title-rub as character no-undo .
define variable v-line3 as integer no-undo .
define variable v-line2 as integer no-undo .
define variable v-okv-code as character no-undo .
define variable v-chernovik as character no-undo .
define variable v-naznach-plat-1 as character no-undo .
define variable v-naznach-plat-2  as character no-undo .
define variable acc as decimal no-undo .
define variable v-exist as logical no-undo .
define variable date_string     as      char    no-undo.
define variable g#log as logical no-undo .

define buffer buf_currency for ub.currency.
define buffer buf_contract for ub.contract.
define buffer buf_fin-connect for ub.fin-connect.
define buffer buf_fin-ob for ub.fin-ob .
define buffer buf_fin-gds-part for ub.fin-gds-part.

define temp-table temp-trn-doc no-undo
field fin-ob-code like ub.fin-gds-part.fin-ob-code
field in-code like ub.fin-gds-part.in-code
field prn-doc-code like ub.fin-ob.prn-doc-code
field sum-doc like ub.fin-ob.sum-doc
field PS like ub.fin-connect.PS
index pi is unique primary
fin-ob-code
in-code
.
define buffer buf_temp-trn-doc for temp-trn-doc.


DEFINE FRAME doc-list
buf_temp-trn-doc.in-code COLUMN-LABEL "Документ основания"
buf_temp-trn-doc.prn-doc-code "Номер ФО"
buf_temp-trn-doc.sum-doc "Сумма погашения"
buf_temp-trn-doc.PS "Примечания!(причины, условия погашения и т.д.)"
HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(198)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .


do
on error undo, return error
:

 run waitfram-show in this-procedure ("Ждите...").
  run get-report-num  in parParentProc(output g#report-num).
  run get-quest-print in parParentProc(output g#quest-print).

 if p-format <> 0
 and p-format <> ?
 and p-append
 then do:
    assign
    p-format = ?
    .
   return.
 end.
  assign
  Line = fill("_":U, 136)
  .
  assign
  v-chernovik = if buf_fin-doc.status_ = {&fin-new}
                then "Ч Е Р Н О В И К"
                else (fill( {&space-char}, 15))
  .
  if buf_fin-doc.curr-code = 0 then do:
    assign
    v-rub = " {&abbr_rub}.":U
    v-kop = " {&abbr_kop}.":U
    .
  end.
  else do:
    find first buf_currency no-lock where
               buf_currency.curr-code = buf_fin-doc.curr-code .
    assign
    v-rub = {&space-char} + buf_currency.curr-abbr + ".":U
    v-kop = {&space-char} + buf_currency.part-abbr + ".":U
    v-title-rub = "       инвалюты       ":U
    v-okv-code = (if buf_currency.okv-code = 0
                  then "Код ОКВ?"
                  else string(buf_Currency.okv-code))
    .
  end.

  assign
  v-naznach-plat-1 = Break-n-line(buf_fin-doc.naznach-plat, "102,136":U, output num-lines)
  v-naznach-plat-2 = (if num-lines >=2
                      then entry(2, v-naznach-plat-1, {&delim-par})
                      else "":U
                      )
  v-naznach-plat-1 = entry(1, v-naznach-plat-1, {&delim-par})
  .

  if buf_fin-doc.curr-code = 0 then do:
    assign
    v-dops = Sum-in-Words-Without-Dec(buf_fin-doc.sum-doc)
    .
    assign
    v-sum-kop-p = string((buf_fin-doc.sum-doc - truncate(buf_fin-doc.sum-doc, 0)) * 100, "99":U)
    v-dops = v-dops + {&space-char} + v-rub +  {&space-char}  + v-sum-kop-p + v-kop
    .
    v-line2 = 98.
  end.
  else do:
    assign
    v-dops = Sum-in-Words-Invalut(buf_fin-doc.sum-doc, buf_fin-doc.curr-code)
    v-line2 = 98
    .
  end.

  assign
  v-sum-doc-v1 = Break-n-line(v-dops, ("76,136":U + string(v-line2)), output num-lines)
  v-sum-doc-v2 = If num-lines >= 2
                 then entry(2, v-sum-doc-v1, {&delim-par})
                 else "":U
  v-sum-doc-v2 =  v-sum-doc-v2 +  fill( {&space-char} , v-line2 - length(v-sum-doc-v2))
  v-sum-doc-v1 =  entry(1, v-sum-doc-v1, {&delim-par})
  v-sum-doc-v1 = v-sum-doc-v1 +  fill( {&space-char} , 76 - length(v-sum-doc-v1))
  v-sum-doc-v1 = caps(substring(v-sum-doc-v1, 1, 1)) + substring(v-sum-doc-v1, 2)
  .
  assign
  v-sum-doc-n1 = Break-n-line(v-dops, ("98,136":U + string(v-line2)), output num-lines)
  v-sum-doc-n2 = If num-lines >= 2
                 then entry(2, v-sum-doc-n1, {&delim-par})
                 else "":U
  v-sum-doc-n2 = v-sum-doc-n2 +  fill( {&space-char} , v-line2 - length(v-sum-doc-n2))
  v-sum-doc-n1 = entry(1, v-sum-doc-n1, {&delim-par})
  v-sum-doc-n1 = v-sum-doc-n1 +  fill( {&space-char} , 98 - length(v-sum-doc-n1))
  v-sum-doc-n1 = caps(substring(v-sum-doc-n1, 1, 1)) + substring(v-sum-doc-n1, 2)
  .


  assign
  v-head-position = string(if num-entries(buf_fin-doc.payer-sign1, {&delim-par})  > 1
                            then entry(1, buf_fin-doc.payer-sign1, {&delim-par})
                            else "Директор", "X(25)")
  v-payer-sign1         = string(if num-entries(buf_fin-doc.payer-sign1, {&delim-par})  > 1
                            then entry(2, buf_fin-doc.payer-sign1, {&delim-par})
                            else entry(1, buf_fin-doc.payer-sign1, {&delim-par})
                            , "X(25)")
  v-receiver-sign1         = string(if num-entries(buf_fin-doc.payer-sign1, {&delim-par})  > 1
                            then entry(2, buf_fin-doc.payer-sign1, {&delim-par})
                            else entry(1, buf_fin-doc.payer-sign1, {&delim-par}), "X(25)")

  .

  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input {&CS_PS}
                                              ,input yes /*p-is-stream*/
                                              ,input p-append /*p-append*/
                                              ).

  PUT  STREAM PrnLibStream unformatted
  skip(1)
  v-chernovik
  skip(2)
  fill({&space-char}, 20) "Акт погашения задолженности № "  buf_fin-doc.prn-doc-code
  "     от " string(day(buf_fin-doc.doc-date))
  {&space-char} MonthNameRusGen(Month(buf_fin-doc.doc-date))
  {&space-char} string(Year(buf_fin-doc.doc-date)) {&space-char} "г."
  skip(1).
  if buf_fin-doc.contract-code <> 0 then do:
    find first buf_contract no-lock where
              buf_Contract.host-code = buf_fin-doc.host-code
          AND buf_Contract.contract-code = buf_fin-doc.contract-code.
    Put Stream PrnLibStream unformatted
    fill({&space-char}, 20) "по договору № " buf_contract.contract-prn-code
    "     от " string(day(buf_contract.contract-date))
    {&space-char} MonthNameRusGen(Month(buf_contract.contract-date))
    {&space-char} string(Year(buf_contract.contract-date)) {&space-char} "г."
    skip(2).
  end.

  PUT  STREAM PrnLibStream unformatted
  fill({&space-char}, 10) "ФИРМA:          " (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_Income_Payoff}
                                              then buf_fin-doc.receiver-name
                                              else buf_fin-doc.payer-name)
  skip(2)
  fill({&space-char}, 10) "КОНТРАГЕНТ:     " (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_Income_Payoff}
                                              then buf_fin-doc.payer-name
                                              else buf_fin-doc.receiver-name)
  skip(3).


  PUT  STREAM PrnLibStream unformatted
  fill({&space-char}, 20) "Представители " skip(0)
  fill({&space-char}, 20) "ФИРМЫ - "
  (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_Income_Payoff}
    then buf_fin-doc.receiver-name
    else buf_fin-doc.payer-name)
    " и " skip(0)
  fill({&space-char}, 20) "КОНТРАГЕНТА - "
  (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_Income_Payoff}
    then buf_fin-doc.payer-name
    else buf_fin-doc.receiver-name)
    skip(1)
    "на основании произведенных сверок по суммам поставок и суммам платежей "
    (if buf_fin-doc.contract-code <> 0
    then "согласно данного Договора "
    else "":U) skip(1)
    substitute("подтвердили расхождения в выполнении &1 финансовых обязательств на сумму "
              , (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_Income_Payoff}
                 then "Контрагентом"
                 else "Фирмой"
                 )
              ) v-sum-doc-v1 skip(0)
    (if v-sum-doc-v2 <> "":U then v-sum-doc-v2 else "":U)
    skip(1).
  PUT  STREAM PrnLibStream unformatted
  "По соглашению сторон выявленная сумма " v-sum-doc-n1 skip(0)
  (if v-sum-doc-n2 <> "":U then v-sum-doc-n2 else "":U)
  "считается погашенной на основании " v-naznach-plat-1 skip(0)
  (if v-naznach-plat-2 <> "":U
  then (v-naznach-plat-2 + {&new-line})
  else "":U)
  skip(2).

  PUT  STREAM PrnLibStream unformatted
  fill({&space-char}, 20) "Данный Акт составлен в двух экземплярах, каждый из которых имеет одинаковую юридическую силу."
  skip(5).

  PUT  STREAM PrnLibStream unformatted
  fill({&space-char}, 20) "ФИРМА" fill({&space-char}, 70) "КОНТРАГЕНТ" skip(2)
  v-head-position
  v-payer-sign1 AT 40
  v-receiver-sign1 AT 80 skip(2)
  fill("-", 25) fill({&space-char}, 2) /*должность1*/
  fill("-", 10) fill({&space-char}, 2) /*подпись1*/
  fill("-", 25) fill({&space-char}, 2) /*расшифровка подпись1*/
  fill({&space-char}, 5)
  fill("-", 25) fill({&space-char}, 2) /*должность2*/
  fill("-", 10) fill({&space-char}, 2) /*подпись2*/
  fill("-", 25) fill({&space-char}, 2) /*расшифровка подпись2*/
  skip(0)
  fill({&space-char}, 8) "должность" fill({&space-char}, 8)  fill({&space-char}, 2) /*должность1*/
  fill({&space-char}, 1) "подпись"   fill({&space-char}, 2)  fill({&space-char}, 2) /*подпись1*/
  fill({&space-char}, 4) "расшифровка подписи" fill({&space-char}, 4)  fill({&space-char}, 2)
  fill({&space-char}, 3)
  fill({&space-char}, 8) "должность" fill({&space-char}, 8)  fill({&space-char}, 2) /*должность2*/
  fill({&space-char}, 1) "подпись"   fill({&space-char}, 2)  fill({&space-char}, 2) /*подпись2*/
  fill({&space-char}, 4) "расшифровка подписи" fill({&space-char}, 4)  fill({&space-char}, 2)
  skip(2)
  fill({&space-char}, 10) "МП"
  fill({&space-char}, 70) "МП"
  skip
  .
  for each buf_temp-trn-doc:
    delete buf_temp-trn-doc.
  end.
  assign
  v-exist = no
  .
  /*второй лист временно не печатается совесм - потому что непонятно как*/
  /*
  for each buf_fin-connect no-lock where
          buf_fin-connect.host-code = buf_fin-doc.host-code
      AND buf_fin-connect.fin-doc-code = buf_fin-doc.fin-doc-code
      AND buf_fin-connect.status_ = {&fact},
      each buf_fin-ob no-lock where
          buf_Fin-ob.host-code = buf_fin-doc.host-code
      AND buf_Fin-ob.doc-code = buf_fin-connect.fin-ob-code,
      each buf_fin-gds-part no-lock where
          buf_fin-gds-part.host-code = buf_fin-doc.host-code
      AND buf_fin-gds-part.fin-ob-code = buf_fin-ob.doc-code:
     assign
     v-exist = yes.
     find first buf_temp-trn-doc no-lock where
              buf_temp-trn-doc.in-code = buf_fin-gds-part.in-code
          AND buf_temp-trn-doc.fin-ob-code = buf_fin-gds-part.fin-ob-code
              no-error .
    if not available buf_temp-trn-doc then do:
      create buf_temp-trn-doc.
      assign
      buf_temp-trn-doc.in-code = buf_fin-gds-part.in-code
      buf_temp-trn-doc.fin-ob-code = buf_fin-gds-part.fin-ob-code
      buf_temp-trn-doc.prn-doc-code = buf_fin-ob.prn-doc-code
      buf_temp-trn-doc.pS = buf_fin-connect.PS
      .
    end.
    assign
    buf_temp-trn-doc.sum-doc = buf_temp-trn-doc.sum-doc + buf_fin-gds-part.sum-doc
    .
  end.
  */
  if v-exist then do:
    /*печатаем второй лист*/
    Page stream PrnLibStream .
    PUT  STREAM PrnLibStream
    SPACE(25)
    "Спецификация к акту  погашения задолженности №" buf_fin-doc.prn-doc-code " от "
    "     от " string(day(buf_fin-doc.doc-date))
    {&space-char} MonthNameRusGen(Month(buf_fin-doc.doc-date))
    {&space-char} string(Year(buf_fin-doc.doc-date)) {&space-char} "г."
    skip(1).
    if buf_fin-doc.contract-code <> 0 then do:
      Put Stream PrnLibStream unformatted
      fill({&space-char}, 20) "по договору № " buf_contract.contract-prn-code
      "     от " string(day(buf_contract.contract-date))
      {&space-char} MonthNameRusGen(Month(buf_contract.contract-date))
      {&space-char} string(Year(buf_contract.contract-date)) {&space-char} "г."
      skip(2).
    end.
    PUT  STREAM PrnLibStream unformatted
    fill({&space-char}, 10) "ФИРМA:          " (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_Income_Payoff}
                                                then buf_fin-doc.receiver-name
                                                else buf_fin-doc.payer-name)
    skip(2)
    fill({&space-char}, 10) "КОНТРАГЕНТ:     " (if buf_fin-doc.fin-ext-doc-type = {&FDEDT_Income_Payoff}
                                                then buf_fin-doc.payer-name
                                                else buf_fin-doc.receiver-name)
    skip(3).
    FORM HEADER
    Line format "X(195)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 30 SKIP
    with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW  STREAM PrnLibStream FRAME BottomFrame .

    FORM with FRAME doc-list  .

    for each buf_temp-trn-doc :
      Display STREAM PrnLibStream
      buf_temp-trn-doc.in-code
      buf_temp-trn-doc.prn-doc-code
      buf_temp-trn-doc.sum-doc
      buf_temp-trn-doc.PS
      with FRAME doc-list .
      DOWN STREAM PrnLibStream 1
      with FRAME fin-doc-list  .
    end.
    assign
    acc = acc + buf_temp-trn-doc.sum-doc
    .
    UNDERLINE  STREAM PrnLibStream
    buf_temp-trn-doc.in-code
    buf_temp-trn-doc.prn-doc-code
    buf_temp-trn-doc.sum-doc
    buf_temp-trn-doc.PS
    with FRAME doc-list .
    PUT STREAM PrnLibStream UNFORMATTED
    "ИТОГО СУММА ПРОПИСЬЮ " v-dops skip(1) .
    HIDE  STREAM PrnLibStream FRAME BottomFrame .
    HIDE  STREAM PrnLibStream FRAME doc-List.
  end.

  run waitfram-hide in this-procedure .

  if p-append and not p-is-last then Page stream PrnLibStream .
  output  STREAM PrnLibStream CLOSE.
  assign
  p-format = 0
  .
  if p-from-forms then do:
    { rep/q-print.i 0 }
  end.
  else do:
  if not p-append then
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 0
                                            ).
  end.
end.