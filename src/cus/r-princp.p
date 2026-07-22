block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-princp.p $
$Archive: cus/r-princp.p $

Печать отчета по сумме кассовых услуг, оказанных принципиалу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/18/05
Author: Bakhtadze Natalya
Creation date: 10/18/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define input parameter T-slt-sum   as logical no-undo .
define input parameter f-slt-pc    as decimal no-undo . .
define input parameter p-report-header as character no-undo .
/*какой длины в итоге получился фрейм*/
define output parameter p-frame-width as integer no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-princp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-princp.p $":U .
define variable vss-description as character no-undo init "Печать отчета по сумме кассовых услуг, оказанных принципиалу".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i }
{ gbl/prn-lib.i }
{ cmp/library.i }
{ gbl/waitfram.i }
{ gbl/cur-time.i }

DEFINE VARIABLE v-main-code like ub.bar-code.b-code no-undo .
DEFINE VARIABLE line as character no-undo .
DEFINE VARIABLE date_string as character no-undo .
DEFINE VARIABLE for-time as character no-undo .
DEFINE VARIABLE accum-count as integer no-undo .
DEFINE VARIABLE accum-netto as decimal no-undo .
DEFINE VARIABLE v-slt-sum as decimal no-undo .
DEFINE VARIABLE v-agent-profit as decimal no-undo .
DEFINE VARIABLE v-principial-profit as decimal no-undo .
define variable v-header-base-curr as character no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define buffer buf_goods for ub.goods.
define buffer buf_chk-gds  for ub.chk-gds.
define buffer buf_chk-doc  for ub.chk-doc.
define buffer buf_currency for ub.currency.
define buffer buf_clients for ub.clients.


&scop f-sum "->>>,>>>,>>9.99"
find first buf_goods no-lock where
           buf_goods.gds-code = p-gds-code.
{ gbl/gdsbcode.i p-gds-code ? v-main-code no-error }
if error-status:error then do:
  return .
end.

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
buf_chk-doc.doc-code      column-label "Номер_чека"  format "X(23)"
buf_chk-doc.chk-num       column-label "N_по кассе" format ">>>>>>9"
buf_chk-doc.pay-desk      column-label "Касса"
buf_chk-doc.chk-date      column-label "Дата" format "99/99/9999"
for-time                  column-label "Время"   format "X(5)"
buf_chk-doc.netto         column-label "Сумма_оплат"
HEADER  date_string AT 1 format "X(35)"
v-header-base-curr        format "X(20)"
string( "Страница " ) format "X(9)" AT 59 PAGE-NUMBER(PrnLibStream) AT 69 FORMAT ">>9" SKIP
Line format "X(73)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 73).
date_string = cur-time-print() .
assign
Sheetf.Excel-Column-Lable =
"Номер чека"  + {&comma-char} +
"N по кассе" + {&comma-char} +
"Касса" + {&comma-char} +
"Дата" + {&comma-char} +
"Время" + {&comma-char} +
"Сумма оплат"
sheetf.sizes =
"23" + {&comma-char} +
"7"  +  {&comma-char} +
"5" + {&comma-char} +
"10" + {&comma-char} +
"5" + {&comma-char} +
"13"
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
Line format "X(73)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME Chk-List  .
run waitfram-show in this-procedure ("Ждите...").

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
    display stream PrnLibStream
    buf_chk-doc.doc-code
    buf_chk-doc.pay-desk
    buf_chk-doc.chk-num
    buf_chk-doc.chk-date
    string(buf_chk-doc.chk-time, "HH:MM") @ for-time
    buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt) @ buf_chk-doc.netto
    with frame chk-list.
    DOWN STREAM PrnLibStream 1
    with FRAME CHk-List  .

    {&PutExcel}
    buf_chk-doc.doc-code                                                   {&tabulation}
    buf_chk-doc.pay-desk                                                   {&tabulation}
    buf_chk-doc.chk-num                                                    {&tabulation}
    buf_chk-doc.chk-date                                                   {&tabulation}
    string(buf_chk-doc.chk-time, "HH:MM")                                  {&tabulation}
    buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt)
    skip.

    assign
    accum-count      = accum-count + 1
    accum-netto      = accum-netto + buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt)
    .
  end.
end.
underline stream PrnLibStream
buf_chk-doc.doc-code
buf_chk-doc.pay-desk
buf_chk-doc.chk-num
buf_chk-doc.chk-date
for-time
buf_chk-doc.netto
with frame chk-list.
DOWN STREAM PrnLibStream 1
with FRAME CHk-List  .
assign
v-slt-sum = (if T-slt-sum
             then accum-netto / (100 + f-slt-pc ) * f-slt-pc
             else 0)
v-agent-profit = accum-netto * 0.01
v-principial-profit = accum-netto - v-slt-sum - v-agent-profit
.
display stream PrnLibStream
"Итого" + {&space-char} + string(accum-count) + {&space-char} + "чеков" @ buf_chk-doc.doc-code
"на" @ buf_chk-doc.chk-num
"сумму" @ buf_chk-doc.pay-desk
accum-netto @ buf_chk-doc.netto
with frame chk-list.
DOWN STREAM PrnLibStream 1
with FRAME CHk-List  .

{&PutExcel}
("Итого" + {&space-char} + string(accum-count) + {&space-char} + "чеков")  {&tabulation}
"на"                                                                       {&tabulation}
"сумму"                                                                    {&tabulation}
                                                                           {&tabulation}
                                                                           {&tabulation}
accum-netto
skip.

put stream PrnLibStream unformatted
skip(2)
string("ИТОГО продано на сумму", "x(45)")
string(accum-netto, {&f-sum}) skip(0)
(if T-SLt-sum
then (
      string(("в том числе НсП" + {&space-char} +
              string(f-slt-pc, ">9.99%") + {&space-char}), "X(45)") +
      string(v-slt-sum, {&f-sum}) + {&new-line}
      )
else "":U)
string("Сумма агентского вознаграждения составляет", "X(45)")
string(v-agent-profit , {&f-sum}) skip(0)
string("Подлежит перечислению принципиалу", "X(45)")
string(v-principial-profit , {&f-sum}) skip(2)
string("От имени Агента", "X(20)") {&space-char} string(buf_clients.obj-name, "X(25)") {&space-char}
"отчет сдал" {&space-char} fill("_", 15)
skip(0)
fill({&space-char}, 58)
"(подпись)"
skip(0)
fill({&space-char}, 49) "М.П."
skip(2)
string("От имени Принципиала", "X(20)") {&space-char} string(buf_goods.gds-name, "X(25)") {&space-char}
"отчет принял" {&space-char} fill("_", 13)
skip(0)
fill({&space-char}, 58)
"(подпись)"
skip
fill({&space-char}, 49) "М.П."
skip.

{&PutExcel}
skip(2)
"ИТОГО продано на сумму"                         {&tabulation}
                                                 {&tabulation}
                                                 {&tabulation}
                                                 {&tabulation}
                                                 {&tabulation}
string(accum-netto, {&f-sum}) skip(0)
(if T-SLt-sum
then (
      "в том числе НсП" + {&tabulation} +
                          {&tabulation} +
      string(f-slt-pc, ">9.99%")  + {&tabulation} +
                                    {&tabulation} +
                                    {&tabulation} +
      string(v-slt-sum, {&f-sum}) + {&new-line}
      )
else "":U)
"Сумма агентского вознаграждения составляет"       {&tabulation}
                                                   {&tabulation}
                                                   {&tabulation}
                                                   {&tabulation}
                                                   {&tabulation}
string(v-agent-profit , {&f-sum}) skip(0)
"Подлежит перечислению принципиалу"                 {&tabulation}
                                                    {&tabulation}
                                                    {&tabulation}
                                                    {&tabulation}
                                                    {&tabulation}
string(v-principial-profit , {&f-sum}) skip(2)
"От имени Агента"                                   {&tabulation}
string(buf_clients.obj-name, "X(25)")
SKIP
                                                    {&tabulation}
                                                    {&tabulation}
                                                    {&tabulation}
"отчет сдал"                                        {&tabulation}
fill("_", 15)
skip(0)
                                                   {&tabulation}
                                                   {&tabulation}
                                                   {&tabulation}
                                                   {&tabulation}
                                                   {&tabulation}
"(подпись)"
skip(0)
                                                   {&tabulation}
                                                   {&tabulation}
                                                   {&tabulation}
                                                   {&tabulation}
                                                   {&tabulation}
 "М.П."
skip(2)
"От имени Принципиала"                             {&tabulation}
 buf_goods.gds-name
 SKIP
                                                   {&tabulation}
                                                   {&tabulation}
                                                   {&tabulation}
"отчет принял"                                     {&tabulation}
 fill("_", 13)
skip(0)
                                                   {&tabulation}
                                                   {&tabulation}
                                                   {&tabulation}
                                                   {&tabulation}
                                                   {&tabulation}
"(подпись)"
skip
                                                   {&tabulation}
                                                   {&tabulation}
                                                   {&tabulation}
                                                   {&tabulation}
                                                   {&tabulation}
"М.П."
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
