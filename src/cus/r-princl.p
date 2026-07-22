block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-princl.p $
$Archive: cus/r-princl.p $

Печать отчета по сумме кассовых услуг, оказанных списку принципиалов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/18/05
Author: Bakhtadze Natalya
Creation date: 10/18/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter T-slt-sum   as logical no-undo .
define input parameter f-slt-pc    as decimal no-undo . .
define input parameter p-report-header as character no-undo .
/*какой длины в итоге получился фрейм*/
define output parameter p-frame-width as integer no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-princl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-princl.p $":U .
define variable vss-description as character no-undo init "Печать отчета по сумме кассовых услуг, оказанных списку принципиалов".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i }
{ gbl/prn-lib.i }
{ cmp/library.i }
{ gbl/waitfram.i }
{ gbl/cur-time.i }

define temp-table temp-goods no-undo
field gds-code like ub.goods.gds-code
field gds-name like ub.goods.gds-name
field netto like ub.inkas.netto
.

DEFINE VARIABLE v-main-code like ub.bar-code.b-code no-undo .
DEFINE VARIABLE v-nn as integer no-undo .
DEFINE VARIABLE line as character no-undo .
DEFINE VARIABLE date_string as character no-undo .
DEFINE VARIABLE for-time as character no-undo .
DEFINE VARIABLE accum-count as integer no-undo .
DEFINE VARIABLE accum-netto as decimal no-undo .
DEFINE VARIABLE accum-slt-sum as decimal no-undo .
DEFINE VARIABLE accum-agent-profit as decimal no-undo .
DEFINE VARIABLE accum-principial-profit as decimal no-undo .
DEFINE VARIABLE v-slt-sum like ub.inkas.netto no-undo .
DEFINE VARIABLE v-without-slt-sum like ub.inkas.netto no-undo .
DEFINE VARIABLE v-agent-profit as decimal no-undo .
DEFINE VARIABLE v-principial-profit as decimal no-undo .
define variable v-header-base-curr as character no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define buffer buf_chk-gds  for ub.chk-gds.
define buffer buf_chk-doc  for ub.chk-doc.
define buffer buf_sysconf  for ub.sysconf.
define buffer buf_currency for ub.currency.
define buffer buf_clients for ub.clients.

&scop f-sum "->>>,>>>,>>9.99"

define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}
if v-curr-r-b = {&r-b-base} then do:
  { gbl/basecode.i p-curr-host-code v-base-code }
  find first buf_currency no-lock where
          buf_currency.curr-code = v-base-code.
  assign
  v-header-base-curr = string( "( Б.Вал. - " + caps( buf_currency.curr-abbr) + " )" )
  .
end.
find first buf_clients where
            buf_clients.obj-type = {&cmp}
        AND buf_clients.obj-code = p-curr-host-code.


DEFINE FRAME Chk-List
v-nn                      column-label "№"           format ">>9"
temp-goods.gds-name       column-label "Наименование фирмы (принципиала)" format "X(35)"
temp-goods.netto          column-label "Сумма продаж"
v-slt-sum                 column-label "В том числе сумма НсП"
v-without-slt-sum         column-label "Сумма продаж без НсП"
v-agent-profit            column-label "Сумма агентского!вознаграждения"
v-principial-profit       column-label "Сумма подлежащая!перечисл. принцип-лу" format {&f-sum}
HEADER  date_string AT 1 format "X(35)"
v-header-base-curr       format "X(20)"
string( "Страница " ) format "X(9)" AT 59 PAGE-NUMBER(PrnLibStream) AT 69 FORMAT ">>9" SKIP
Line format "X(136)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .


run fill-table in this-procedure .
if not can-find(first temp-goods ) then do:
  return "no-data":U.
end.

Line = fill("-", 136).
date_string = cur-time-print() .
find first buf_sysconf no-lock where
           buf_sysconf.host-code = p-curr-host-code.
assign
Sheetf.Excel-Column-Lable =
"№" + {&comma-char} +
"Наименование фирмы (принципиала)" + {&comma-char} +
"Сумма продаж" + {&comma-char} +
"В том числе сумма НсП" + {&comma-char} +
"Сумма продаж без НсП" + {&comma-char} +
"Сумма агентского вознаграждения" + {&comma-char} +
"Сумма подлежащая перечислению принципиалу"
sheetf.sizes =
"3" + {&comma-char} +
"35" + {&comma-char} +
"18" + {&comma-char} +
"18" + {&comma-char} +
"18" + {&comma-char} +
"18" + {&comma-char} +
"18"
.

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

run rep/extitle.p (1).
FORM with FRAME CHk-list .

PUT stream PrnLibStream UNFORMATTED
SPACE(10)
p-Report-header
SKIP(1).
FORM HEADER
Line format "X(136)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME Chk-List  .
run waitfram-show in this-procedure ("Ждите...").

for each temp-goods no-lock :
  assign
  v-nn = v-nn + 1
  v-slt-sum = (if T-slt-sum
              then temp-goods.netto / (100 + f-slt-pc ) * f-slt-pc
              else 0)
  v-without-slt-sum = temp-goods.netto - v-slt-sum
  v-agent-profit = temp-goods.netto * 0.01
  v-principial-profit = temp-goods.netto - v-slt-sum - v-agent-profit
  accum-netto = accum-netto + temp-goods.netto
  accum-count      = accum-count + 1
  accum-slt-sum = accum-slt-sum + v-slt-sum
  accum-agent-profit = accum-agent-profit + v-agent-profit
  accum-principial-profit = accum-principial-profit + v-principial-profit
  .
  display stream PrnLibStream
  v-nn
  temp-goods.gds-name
  temp-goods.netto
  v-slt-sum
  v-without-slt-sum
  v-agent-profit
  v-principial-profit
  with frame chk-list.
  DOWN STREAM PrnLibStream 1
  with FRAME CHk-List  .

  {&PutExcel}
  v-nn                     {&tabulation}
  temp-goods.gds-name      {&tabulation}
  temp-goods.netto         {&tabulation}
  v-slt-sum                {&tabulation}
  v-without-slt-sum        {&tabulation}
  v-agent-profit           {&tabulation}
  v-principial-profit
  skip.
end.
underline stream PrnLibStream
v-nn
temp-goods.gds-name
temp-goods.netto
v-slt-sum
v-without-slt-sum
v-agent-profit
v-principial-profit
with frame chk-list.
DOWN STREAM PrnLibStream 1
with FRAME CHk-List  .
assign
v-slt-sum = accum-slt-sum
v-agent-profit = accum-agent-profit
v-principial-profit = accum-principial-profit
v-without-slt-sum = accum-netto - v-slt-sum
.
display stream PrnLibStream
"Итого" + {&space-char} + string(accum-count) + {&space-char} + "фирм" @ temp-goods.gds-name
accum-netto @ temp-goods.netto
v-slt-sum
v-without-slt-sum
v-agent-profit
v-principial-profit
with frame chk-list.
DOWN STREAM PrnLibStream 1
with FRAME CHk-List  .

{&PutExcel}
{&tabulation}
("Итого" + {&space-char} + string(accum-count) + {&space-char} + "фирм")  {&tabulation}
accum-netto                                                               {&tabulation}
v-slt-sum                                                                 {&tabulation}
v-without-slt-sum                                                         {&tabulation}
v-agent-profit                                                            {&tabulation}
v-principial-profit
skip.

put stream PrnLibStream unformatted
skip(2)
"Главный бухгалтер фирмы" {&space-char}
buf_clients.obj-name fill({&space-char}, 5)
buf_sysconf.snr-accnt {&space-char} fill("_", 15)
skip(0)
fill({&space-char}, 30 + length(buf_clients.obj-name) + length(buf_sysconf.snr-accnt))
"(подпись)"
skip(0)
fill({&space-char}, 30 + length(buf_clients.obj-name) + length(buf_sysconf.snr-accnt)) "М.П."
skip.

{&PutExcel}
skip(2)
                                                    {&tabulation}
("Главный бухгалтер фирмы" + {&space-char} +
 buf_clients.obj-name + {&space-char})                       {&tabulation}
                                                    {&tabulation}
                                                    {&tabulation}
buf_sysconf.snr-accnt                               {&tabulation}
                                                    {&tabulation}
SKIP(0)
                                                   {&tabulation}
                                                   {&tabulation}
                                                   {&tabulation}
                                                   {&tabulation}
                                                   {&tabulation}
"(подпись)"                                        {&tabulation}
skip(0)
                                                   {&tabulation}
                                                   {&tabulation}
                                                   {&tabulation}
                                                   {&tabulation}
                                                   {&tabulation}
 "М.П."                                            {&tabulation}
skip.

HIDE STREAM PrnLibStream FRAME Chk-list .
HIDE STREAM PrnLibStream FRAME top-Frame .
HIDE stream PrnLibStream FRAME BottomFrame .
output stream PrnLibStream CLOSE .
{&CloseExcel}
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).



procedure fill-table :

  do
  on error undo, return error
  :
    for each temp-goods :
      delete temp-goods.
    end.
    for each gds-list  no-lock :
      { gbl/gdsbcode.i gds-list.gds-code ? v-main-code no-error }
      if error-status:error then do:
        undo, return error.
      end.
      for each obj-list no-lock:
        _chk-gds:
        for each buf_chk-gds no-lock where
                buf_chk-gds.b-code = v-main-code,
          FIRST buf_chk-doc No-LOCK WHERE
                buf_chk-doc.doc-code = buf_chk-gds.doc-code
            AND buf_chk-doc.obj-type = obj-list.obj-type
            AND buf_chk-doc.obj-code = obj-list.obj-code
            AND buf_chk-doc.chk-date >= X-date-start
            AND buf_chk-doc.chk-date <= X-date-end:
          if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-gds.
          find first temp-goods no-lock where
                    temp-goods.gds-code = gds-list.gds-code no-error .
          if not avail temp-goods then do:
            create temp-goods.
            assign
            temp-goods.gds-code = gds-list.gds-code
            temp-goods.gds-name = gds-list.gds-name
            .
          end.
          assign
          temp-goods.netto = temp-goods.netto + buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt)
          .
        end. /*for each buf_chk-gds*/
      end. /*for each obj-list*/
    end. /*for eahc gds-list*/
  end. /*doe*/

end procedure. /* fill-table */