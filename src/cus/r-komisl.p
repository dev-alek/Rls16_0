block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-komisl.p $
$Archive: cus/r-komisl.p $

Печать отчета РЕАЛИЗАЦИЯ КОМИССИОННОГО ТОВАРА по списку поставщиков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/28/05
Author: Bakhtadze Natalya
Creation date: 12/28/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-host-name as character no-undo .
define input parameter RS-by       as integer no-undo .
define input parameter p-report-header as character no-undo .
/*какой длины в итоге получился фрейм*/
define output parameter p-frame-width as integer no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-komisl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-komisl.p $":U .
define variable vss-description as character no-undo init "Печать отчета РЕАЛИЗАЦИЯ КОМИССИОННОГО ТОВАРА по списку поставщиков".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i }
{ gbl/prn-lib.i }
{ cmp/library.i }
{ str/in-vatp.i  def }
{ str/out-vatp.i def }
{ cmp/cli-list.i cli-list def shared }
{ cus/r-komis.i list }
{ gbl/waitfram.i }
{ gbl/cur-time.i }
{ rep/lhstprex.i cli-list-hist }

&SCOPED-DEFINE f-sums "->>,>>>,>>>,>>9.99"

&SCOPED-DEFINE default-vat  18.00

DEFINE VARIABLE Line as character no-undo .
DEFINE VARIABLE date_string as character no-undo .
DEFINE VARIABLE v-nn as integer no-undo .
DEFINE VARIABLE v-supp-name like ub.clients.obj-name no-undo .
DEFINE VARIABLE v-sum-without-slt-sale like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-sum-with-tax-cost    like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-sum-benefit-with-VAT like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-sum-benefit-without-VAT like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE a-sum-without-slt-sale like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE a-sum-with-tax-cost    like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE a-sum-benefit-with-VAT like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE a-sum-benefit-without-VAT like ub.doc-line.price-rubl no-undo .
define buffer buf_clients for ub.clients.

DEFINE FRAME Fkomis
v-nn                      column-label "№" format ">>9"
v-supp-name               column-label "Наименование поставщика" format "X(35)"
v-sum-without-slt-sale    column-label "Получено!комиссионером" format {&f-sums}
v-sum-with-tax-cost       column-label "Подлежит!перечислению!комитенту" format {&f-sums}
v-sum-benefit-with-VAT    column-label "Комиссионное!вознаграждение!с НДС" format {&f-sums}
v-sum-benefit-without-VAT column-label "Комиссионное!вознаграждение!без НДС" format {&f-sums}
HEADER  date_string AT 1 format "X(35)"
string( "Страница " ) format "X(9)" AT 59 PAGE-NUMBER(PrnLibStream) AT 69 FORMAT ">>9" SKIP
Line format "X(115)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

if not can-find( first cli-list no-lock) then do:
  message "Не выбрано ни одного поставщика"
  view-as alert-box ERROR.
  return.
end.
if RS-BY < 1 AND RS-by > 4 then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметра RS-by = "RS-by
  view-as alert-box error .
  return error .
end.

run FillTable in this-procedure no-error  .

if error-status:error then do:
  run waitfram-hide in this-procedure .
  return error .
end.

if not avail sj-goods then do:
  run waitfram-hide in this-procedure .
  message
  "Нет данных для отчета"
  view-as alert-box .
  return.
end.



Line = fill("-", 115).
date_string = cur-time-print() .
assign
str3 = str3 + {&new-line} + "НДС принимается равным" + {&space-char} + string({&default-vat}, ">9.99%")
sheetf.Excel-Column-Lable =
"№"  + {&comma-char} +
"Наименование поставщика" + {&comma-char} +
"Получено комиссионером" + {&comma-char} +
"Подлежит перечислению комитенту" + {&comma-char} +
"Комиссионное вознаграждение с НДС" + {&comma-char} +
"Комиссионное вознаграждение без НДС"
sheetf.sizes =
"3" + {&comma-char} +
"35"  + {&comma-char} +
"18"  + {&comma-char} +
"18"  + {&comma-char} +
"18"  + {&comma-char} +
"18"
.

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

run rep/extitle.p (1).
FORM with FRAME FKomis .

PUT stream PrnLibStream UNFORMATTED
p-Report-header skip(0)
"НДС принимается равным" {&space-char} string({&default-vat}, ">9.99%") skip(0)
.
FORM HEADER
Line format "X(115)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME Fkomis  .
run waitfram-show in this-procedure ("Ждите...").
for each sj-goods no-lock
by sj-goods.supp-type
by sj-goods.supp-code:
  assign
  v-nn = v-nn + 1
  v-sum-benefit-with-VAT = sj-goods.sum-with-tax-sale_ - sj-goods.sum-slt-sale_ - sj-goods.sum-with-tax-cost
  v-sum-benefit-without-VAT = v-sum-benefit-with-VAT / (1 + {&default-vat} / 100 )
  a-sum-without-slt-sale    = a-sum-without-slt-sale    + sj-goods.sum-with-tax-sale_ - sj-goods.sum-slt-sale_
  a-sum-with-tax-cost       = a-sum-with-tax-cost       + sj-goods.sum-with-tax-cost
  a-sum-benefit-with-VAT    = a-sum-benefit-with-VAT    + v-sum-benefit-with-VAT
  a-sum-benefit-without-VAT = a-sum-benefit-without-VAT + v-sum-benefit-without-VAT
  .
  find first buf_clients no-lock where
            buf_clients.obj-type = sj-goods.supp-type
       AND  buf_clients.obj-code = sj-goods.supp-code no-error .
  if avail buf_clients then do:
    assign
    v-supp-name = buf_clients.obj-name
    .
  end.
  else do:
    assign
    v-supp-name = sj-goods.supp-type + string(sj-goods.supp-code)
    .
  end.
  DISPLAY stream PrnLibStream
  v-nn
  v-supp-name
  (sj-goods.sum-with-tax-sale_ - sj-goods.sum-slt-sale_) @  v-sum-without-slt-sale
  sj-goods.sum-with-tax-cost @ v-sum-with-tax-cost
  v-sum-benefit-with-VAT
  v-sum-benefit-without-VAT
  with frame Fkomis.
  DOWN 1 stream PrnLibStream with frame Fkomis.

  {&PutExcel}
  v-nn                                                   {&tabulation}
  v-supp-name                                            {&tabulation}
  (sj-goods.sum-with-tax-sale_ - sj-goods.sum-slt-sale_) {&tabulation}
  sj-goods.sum-with-tax-cost                             {&tabulation}
  v-sum-benefit-with-VAT                                 {&tabulation}
  v-sum-benefit-without-VAT
  skip.
END.
underline stream PrnLibStream
v-nn
v-supp-name
v-sum-without-slt-sale
v-sum-with-tax-cost
v-sum-benefit-with-VAT
v-sum-benefit-without-VAT
with frame Fkomis.
DOWN 1 stream PrnLibStream with frame Fkomis.
display stream PrnLibStream
"ИТОГО" @ v-supp-name
a-sum-without-slt-sale    @ v-sum-without-slt-sale
a-sum-with-tax-cost       @ v-sum-with-tax-cost
a-sum-benefit-with-VAT    @ v-sum-benefit-with-VAT
a-sum-benefit-without-VAT @ v-sum-benefit-without-VAT
with frame Fkomis.
DOWN 1 stream PrnLibStream with frame Fkomis.

{&PutExcel}
                          {&tabulation}
"ИТОГО"                   {&tabulation}
a-sum-without-slt-sale    {&tabulation}
a-sum-with-tax-cost       {&tabulation}
a-sum-benefit-with-VAT    {&tabulation}
a-sum-benefit-without-VAT
skip.

HIDE STREAM PrnLibStream FRAME FKomis .
HIDE STREAM PrnLibStream FRAME top-Frame .
HIDE stream PrnLibStream FRAME BottomFrame .
if Print-List-hist
and can-find(first cli-list) then do:
  run lhistprex-print-cli-list-hist-excel  in this-procedure (input yes, input yes, 2).
end.
output stream PrnLibStream CLOSE .
{&CloseExcel}
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).