block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fssttm1p.p $
$Archive: rep/fssttm1p.p $

Печать банковской выписки типа стандартная выписка

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/20/03
Author: Bakhtadze Natalya
Creation date: 11/20/03

*/

DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define parameter buffer buf_fin-statement for ub.fin-statement.
define input parameter p-append as logical no-undo .
define input parameter p-is-last as logical no-undo .
define input-output parameter p-format as integer no-undo .
/*1 - Landscape 0 -portrait*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fssttm1p.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/fssttm1p.p $":U .
define variable vss-description as character no-undo init "Печать банковской выписки типа стандартная выписка".

{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/getcntxt.i def }
define variable g#report-num  as integer no-undo .
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/paramls.i }
{ gbl/getcntxt.i get }
{ trg/factord.i }
{ rep/fssttxl1.i  }

define variable glog as logical no-undo .
define variable Line as character no-undo .
define variable date_string as character no-undo .
define variable num-lines as integer no-undo .
define variable v-fill as character no-undo init "_".
define variable v-dops as character no-undo .
define variable v-chernovik as character no-undo .
define variable v-vo as character no-undo .
define variable v-debet like ub.fin-doc.sum-doc no-undo .
define variable v-credit like ub.fin-doc.sum-doc no-undo .
define variable v-debet-ob like ub.fin-doc.sum-doc no-undo .
define variable v-credit-ob like ub.fin-doc.sum-doc no-undo .
define variable v-my-side as logical no-undo .
define variable v-debet-str as character no-undo .
define variable v-credit-str as character no-undo .
define variable v-c-schet like ub.fin-statement-line.rp-c-schet no-undo .
define variable v-from-fact-order like ub.fin-doc.fact-order no-undo .
define variable v-to-fact-order like ub.fin-doc.fact-order no-undo .
define variable v-last-doc-fact-date as date no-undo .
define variable v-last-doc-str as character no-undo .
define variable v-from-sum as decimal no-undo .
define variable v-to-sum-doc as decimal no-undo .

define buffer buf_currency for ub.currency.
define buffer buf_fin-statement-line for ub.fin-statement-line.
define buffer buf_fin-doc for ub.fin-doc.
define buffer last_fin-doc for ub.fin-doc.

DEFINE FRAME extract
v-vo COLUMN-LABEL "ВО" format "X(4)"
buf_fin-statement-line.prn-doc-code COLUMN-LABEL "Номер документа"
buf_fin-statement-line.rp-c-schet COLUMn-LABEL "Номер корр. счета"
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

  Line = fill("-", 134).
  date_string = replace(cur-time-string-sec(), {&slash-char}, ".":U) .
  find first buf_currency no-lock where
            buf_currency.curr-code = buf_fin-statement.curr-code no-error .
  if not available buf_currency then do:
    return error .
  end.

  run day-begin-fact-order (
      input  buf_fin-statement.start-date
     ,output v-from-fact-order) .

  /*найдем fact-order на конец дня от v-to-date */

  run factord-end-day (
      input  buf_fin-statement.end-date
    ,output v-to-fact-order) .

  /*получим дату последнeй операции меньшей v-from-date*/
  find last last_fin-doc no-lock where
            last_fin-doc.host-code = buf_Fin-statement.host-code
        AND last_fin-doc.status_ = {&fin-fact}
        AND last_fin-doc.fact-order < v-from-fact-order
        AND last_fin-doc.receiver-code-schet = buf_Fin-statement.code-schet no-error .
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
            last_fin-doc.host-code = buf_Fin-statement.host-code
        AND last_fin-doc.status_ = {&fin-fact}
        AND last_fin-doc.fact-order < v-from-fact-order
        AND last_fin-doc.payer-code-schet = buf_Fin-statement.code-schet no-error .
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
  assign
  v-from-sum = buf_fin-statement.end-sum-rubl
  .

  run get-report-num  in parParentProc(output g#report-num).
  output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
  output close.
  run fssttxl1-init in this-procedure.

 if p-format <> 1
 and p-format <> ?
 and p-append
 then do:
  assign
  p-format = ?
  .
  return.
 end.
  assign
  Line = fill("_":U, 198)
  .
  assign
  v-chernovik = if buf_fin-statement.status_ = {&fin-new}
                then "Ч Е Р Н О В И К"
                else (fill( {&space-char}, 15))
  .


  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input {&CS_PS}
                                              ,input yes /*p-is-stream*/
                                              ,input p-append /*p-append*/
                                              ).


  FORM with FRAME extract  .
  FORM HEADER
  Line format "X(134)" SKIP
  "Продолжение - на следующей странице" AT 30 SKIP
  with FRAME BottomFrame width {&A4_CW0} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW  STREAM PrnLibStream FRAME BottomFrame .

  run fssttxl1-write-cell-data in this-procedure ( input {&fssttxl1-h_datetime}       , input date_string  ).
  run fssttxl1-write-cell-data in this-procedure ( input {&fssttxl1-h_bankname}       , input buf_fin-statement.bank-name  ).
  run fssttxl1-write-cell-data in this-procedure ( input {&fssttxl1-h_bik}       , input buf_fin-statement.bik  ).
  run fssttxl1-write-cell-data in this-procedure ( input {&fssttxl1-h_corrschet}       , input buf_fin-statement.c-schet  ).
  run fssttxl1-write-cell-data in this-procedure ( input {&fssttxl1-h_cliname}       , input buf_fin-statement.cli-name  ).
  run fssttxl1-write-cell-data in this-procedure ( input {&fssttxl1-h_currcodename}
                                                  ,input substitute("&1/&2 &3"
                                                                    ,buf_currency.curr-abbr
                                                                    ,buf_currency.okv-code
                                                                    ,buf_currency.curr-name )).
  run fssttxl1-write-cell-data in this-procedure ( input {&fssttxl1-h_rschet}       , input buf_fin-statement.r-schet ).
  run fssttxl1-write-cell-data in this-procedure ( input {&fssttxl1-h_lastfindoc}       , input v-last-doc-str ).
  run fssttxl1-write-cell-data in this-procedure ( input {&fssttxl1-h_startsumdoc}
                                                   ,input substitute("Входящий остаток на начало дня &1: &2"
                                                                     ,string(buf_fin-statement.start-date, "99/99/9999")
                                                                     ,string( v-from-sum, "->>>,>>>,>>>,>>9.99"))).

  PUT  STREAM PrnLibStream unformatted
  line skip(1)
  SPACE(25) "ВЫПИСКА ИЗ ЛИЦЕВОГО СЧЕТА КЛИЕНТА"  space(25) date_string skip(1)
  buf_fin-statement.bank-name space(10) "БИК" {&space-char} buf_fin-statement.bik space(10) "корр. счет" {&space-char} buf_fin-statement.c-schet skip(1)
  "Наименование клиента: " buf_fin-statement.cli-name skip(1)
  "Валюта счета: "
  substitute("&1/&2 &3"
                  ,buf_currency.curr-abbr
                  ,buf_currency.okv-code
                  ,buf_currency.curr-name )
   skip(1)
  "Номер счeта: " buf_fin-statement.r-schet
  skip(1)
  line skip(1)
  "Дата последней операции: " v-last-doc-str skip(1)
   substitute("Входящий остаток на начало дня &1: &2"
            ,string(buf_fin-statement.start-date, "99/99/9999")
            , string(v-from-sum, "->>>,>>>,>>>,>>9.99")) skip(1)
  .

  /*печать документов закрытых на факт по этому счету*/
  for each buf_fin-statement-line no-lock where
          buf_fin-statement-line.host-code = buf_fin-statement.host-code
      AND buf_fin-statement-line.sttm-code = buf_fin-statement.sttm-code:
    CASE buf_fin-statement-line.fin-ext-doc-type:
      when {&FDEDT_Expense_Cashless} then do:
        if buf_fin-statement-line.fin-doc-code > 0 then do:
          find first buf_fin-doc no-lock where
                    buf_fin-doc.host-code = buf_fin-statement-line.host-code
                and buf_fin-doc.fin-doc-code = buf_fin-statement-line.fin-doc-code no-error.
        end.
        assign
        v-vo = string(buf_fin-statement-line.line-num)
        v-c-schet = (if available buf_fin-doc
                     then buf_fin-doc.receiver-c-schet
                     else buf_Fin-statement-line.rp-c-schet)
        v-debet = (if v-my-side
                   then (if available buf_fin-doc
                        then buf_fin-doc.sum-doc
                        else buf_fin-statement-line.sum-doc)
                   else 0)
        v-credit = (if v-my-side
                    then 0
                    else (if available buf_fin-doc
                          then buf_fin-doc.sum-doc
                          else buf_fin-statement-line.sum-doc)
                          )
        v-debet-str   = (if v-my-side
                         then (if available buf_fin-doc
                               then string(buf_fin-doc.sum-doc)
                               else string(buf_fin-statement-line.sum-doc)
                               )
                         else "":U)
        v-credit-str   = (if v-my-side
                          then "":U
                          else (if available buf_fin-doc
                                then string(buf_fin-doc.sum-doc)
                                else string(buf_fin-statement-line.sum-doc)
                               )
                                )
        v-debet-ob = v-debet-ob + v-debet
        v-credit-ob = v-credit-ob + v-credit
        .
      end.
      when {&FDEDT_Income_Cashless}
      then do:
        if buf_fin-statement-line.fin-doc-code > 0 then do:
          find first buf_fin-doc no-lock where
                    buf_fin-doc.host-code = buf_fin-statement-line.host-code
                and buf_fin-doc.fin-doc-code = buf_fin-statement-line.fin-doc-code no-error.
        end.
        assign
        v-vo = string(buf_fin-statement-line.line-num)
        v-c-schet = (if available buf_fin-doc
                     then buf_fin-doc.payer-c-schet
                     else buf_Fin-statement-line.rp-c-schet)
        v-credit = (if v-my-side
                    then (if available buf_fin-doc
                          then buf_fin-doc.sum-doc
                          else buf_fin-statement-line.sum-doc)
                    else 0)
        v-debet = (if v-my-side
                   then 0
                   else (if available buf_fin-doc
                         then buf_fin-doc.sum-doc
                         else buf_fin-statement-line.sum-doc)
                         )
        v-credit-str   = (if v-my-side
                          then (if available buf_fin-doc
                                then string(buf_fin-doc.sum-doc)
                                else string(buf_fin-statement-line.sum-doc)
                                )
                          else "":U)
        v-debet-str = (if v-my-side
                       then "":U
                       else (if available buf_fin-doc
                             then string(buf_fin-doc.sum-doc)
                             else string(buf_fin-statement-line.sum-doc))
                             )
        v-credit-ob = v-credit-ob + v-credit
        v-debet-ob = v-debet-ob + v-debet
        .
      end.
    END CASE.
    run fssttxl1-write-line-data in this-procedure (
                                                    input v-vo /* p-linenum */
                                                    ,input buf_fin-statement-line.prn-doc-code
                                                    ,input v-c-schet
                                                    ,input string(v-debet, ">>>,>>>,>>>,>>9.99")
                                                    ,input string(v-credit, ">>>,>>>,>>>,>>9.99")
                                                   ).

    Display STREAM PrnLibStream
    v-vo
    buf_fin-statement-line.prn-doc-code
    v-c-schet @ buf_fin-statement-line.rp-c-schet
    v-debet
    v-credit
    with FRAME extract .
    DOWN STREAM PrnLibStream
    with frame extract .
  end. /*for each buf_fin-doc*/
  assign
  v-to-sum-doc = v-from-sum - v-debet-ob + v-credit-ob
  .
  run fssttxl1-write-cell-data in this-procedure ( input {&fssttxl1-it_debetsum}
                                                 , input string(v-debet-ob, ">>>,>>>,>>>,>>9.99")) .
  run fssttxl1-write-cell-data in this-procedure ( input {&fssttxl1-it_creditsum}
                                                 , input string(v-credit-ob, ">>>,>>>,>>>,>>9.99")).
  run fssttxl1-write-cell-data in this-procedure ( input {&fssttxl1-f_endsumdoc}
                                                   ,input substitute("Исходящий остаток на конец дня &1: &2"
                                                                     ,string(buf_fin-statement.end-date, "99/99/9999")
                                                                     , string(v-to-sum-doc, "->>>,>>>,>>>,>>9.99"))).


  DOWN STREAM PrnLibStream 1
  with frame extract.
  display stream PrnLibstream
  "ИТОГО" @ buf_fin-statement-line.prn-doc-code
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
  substitute("Исходящий остаток на конец дня &1: &2"
              ,string(buf_fin-statement.end-date, "99/99/9999")
              , string(v-to-sum-doc, "->>>,>>>,>>>,>>9.99"))
  skip(1)
  line skip.

  /*run pko1xl-write-cell-data in this-procedure ( input {&pko1xl-h_organization}       , input buf_fin-doc.receiver-name                               ).*/

  HIDE  STREAM PrnLibStream FRAME BottomFrame .
  HIDE  STREAM PrnLibStream FRAME extract.
  if p-append and not p-is-last then Page stream PrnLibStream .

  output  STREAM PrnLibStream CLOSE.

  assign
  p-format = 0
  .
  run fssttxl1-close in this-procedure .

  if not p-append
  then do:

      os-delete
          value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
      .
      os-rename
          value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
          value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
      .
      run prn-lib-prn-file in this-procedure (
            input parParentProc
          , input 0
      ).

      os-delete
          value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
      .
      os-delete
          value( v-fssttxl1-cell-file-name )
      .
  end.

end.