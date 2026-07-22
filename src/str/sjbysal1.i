/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

список продаж - печать списка

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/13/06
Author: Bakhtadze Natalya
Creation date: 01/13/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE PrintListProc.
define input parameter p-curr-r-b as character no-undo .
define input parameter p-base-type as character no-undo .
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable accum-count as integer.
define variable accum-tot-doc as decimal.
define variable accum-discnt as decima.
define variable accum-sub-discnt as decimal.
define variable accum-netto as decimal.
define variable accum-qnty as decimal.
define variable accum-num-chk as integer.
define variable for-pcnt as decimal.
DEFINE VARIABLE jj as integer no-undo .
define variable v-header-base-curr as character no-undo .
define variable v-flag as logical no-undo .
define variable v-shift-name-num as character no-undo.
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-base-type like ub.currency.curr-abbr no-undo .
define buffer buf_trn-doc for ub.trn-doc.


if p-curr-r-b = {&r-b-base} and p-base-type <> '':U then do:
  assign
  v-header-base-curr = string( "( Б.Вал. - " + caps( p-base-type ) + " )" )
  .
end.



DEFINE FRAME Chk-List
ink-doc.office       column-label "У" format "+/-"
ink-doc.inkas-code FORMAT "X(12)"
ink-doc.doc-date FORMAT "99/99/9999"
ink-doc.fact-date COLUMN-LABEL "Факт.дата" FORMAT "99/99/9999"
ink-doc.netto COLUMN-LABEL "Нетто" FORMAT "->>>,>>>,>>>,>>9.99"
ink-doc.tot-doc COLUMN-LABEL "Сумма_товар."
ink-doc.discnt FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "Скидка_общ"
for-pcnt COLUMN-LABEL "%" FORMAT "->>>9.9"
ink-doc.sub-discnt FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "Списания"
ink-doc.qnty COLUMN-LABEL "Кол_товара"
ink-doc.num-chk FORMAT ">>>,>>9" COLUMN-LABEL "Кол._чеков"
ink-doc.shift-date COLUMn-LABEL "Дата_смены"
v-shift-name-num COLUmn-LABEL "№ см." FORMAT "X(6)"
ink-doc.obj-code FORMAT "99999" COLUMn-LABEL "Маг-н"
ink-doc.status_ FORMAT "X(8)":U
v-flag COLUMN-LABEL "ОК" FORMAT "+/":U
HEADER  date_string AT 5 format "X(35)"
v-header-base-curr        format "X(20)" AT 42
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(177)" AT 1
    with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 177).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .

FORM HEADER
        Line format "X(177)" AT 1 SKIP
        "Продолжение - на следующей странице" AT 30 SKIP
        with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME Chk-List  .
run waitfram-show in this-procedure ("Ждите...").
GET next br-docs.
jj = 0 .
DO WHILE available ink-doc :
  find first buf_trn-doc no-lock where
              buf_trn-doc.doc-code = ink-doc.inkas-code no-error.
  Display STREAM PrnLibStream
  ink-doc.office
  ink-doc.inkas-code
  ink-doc.doc-date
  ink-doc.fact-date
  ink-doc.netto
  ink-doc.tot-doc
  ink-doc.discnt
  (ink-doc.discnt / ink-doc.tot-doc * 100) @ for-pcnt
  ink-doc.sub-discnt
  ink-doc.qnty
  ink-doc.num-chk
  ink-doc.shift-date
  shift-name-no-err(buffer ink-doc) @ v-shift-name-num
  ink-doc.obj-code
  ink-doc.status_
  (if available buf_trn-doc then buf_trn-doc.flag else ?) @ v-flag
  with FRAME Chk-List .
  DOWN STREAM PrnLibStream 1 with FRAME CHk-List  .
  assign
  accum-count = accum-count + 1
  accum-tot-doc = accum-tot-doc + ink-doc.tot-doc
  accum-discnt = accum-discnt + ink-doc.discnt
  accum-sub-discnt = accum-sub-discnt + ink-doc.sub-discnt
  accum-netto = accum-netto + ink-doc.netto
  accum-qnty = accum-qnty + ink-doc.qnty
  accum-num-chk = accum-num-chk + ink-doc.num-chk.
  GET next br-docs.
END.
UNDERLINE  STREAM PrnLibStream
ink-doc.office
ink-doc.inkas-code
ink-doc.doc-date
ink-doc.fact-date
ink-doc.netto
ink-doc.tot-doc
ink-doc.discnt
for-pcnt
ink-doc.sub-discnt
ink-doc.qnty
ink-doc.num-chk
ink-doc.shift-date
v-shift-name-num
ink-doc.obj-code
ink-doc.status_
v-flag
with FRAME Chk-List .
DISPLAY STREAM PrnLibStream
"ИТОГО " @ ink-doc.inkas-code
string(accum-count) @ ink-doc.doc-date
"отчетов" @ ink-doc.fact-date
accum-netto @ ink-doc.netto
accum-tot-doc @ ink-doc.tot-doc
accum-discnt @ ink-doc.discnt
(accum-discnt / accum-tot-doc * 100) @ for-pcnt
accum-sub-discnt @ ink-doc.sub-discnt
accum-qnty @ ink-doc.qnty
accum-num-chk @ ink-doc.num-chk
with frame Chk-List.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME Chk-List.
output  STREAM PrnLibStream CLOSE.
/*
  assign
g#rep-tblname = ""
g#rep-tblrid = -117
g#rep-updflds = string( "Список отчетов о продаже|" ) .
*/
run waitfram-hide in this-procedure .

run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).


END PROCEDURE.

/* $Workfile$ e n d */