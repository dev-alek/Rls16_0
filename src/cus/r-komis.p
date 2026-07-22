block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-komis.p $
$Archive: cus/r-komis.p $

Печать отчета РЕАЛИЗАЦИЯ КОМИССИОННОГО ТОВАРА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/21/06
Author: Bakhtadze Natalya
Creation date: 03/21/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-host-name   as character no-undo .
define input parameter p-supp-type like ub.clients.obj-type no-undo .
define input parameter p-supp-code like ub.clients.obj-code no-undo .
define input parameter p-supp-name like ub.clients.obj-name no-undo .
define input parameter RS-by       as integer no-undo .
define input parameter T-parts     as logical no-undo .
define input parameter p-report-header as character no-undo .
/*какой длины в итоге получился фрейм*/
define output parameter p-frame-width as integer no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-komis.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-komis.p $":U .
define variable vss-description as character no-undo init "Печать отчета РЕАЛИЗАЦИЯ КОМИССИОННОГО ТОВАРА".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i }
{ gbl/prn-lib.i }
{ cmp/library.i }
{ str/in-vatp.i  def }
{ str/out-vatp.i def }
{ gbl/waitfram.i }
define buffer cli_supp for ub.clients.
{ cus/r-komis.i }
{ rep/dincol.i def }

define variable g#report-num as integer no-undo .
/*1 - nn*/
/*2 - артикул*/
/*3 - наименование */
/*4 - тип производителя*/
/*5 - код производителя*/
/*6 - едизм*/
/*7 - количество*/
/*8 -  Учетная цена без НДС*/
/*9 -  Сумма уч. цен без НДС */
/*10 - НДС поставщика  */
/*11 - Сумма уч. Цен */
/*12 - Цена ед. изм без налога */
/*13 - Сумма товаров без налога  */
/*14 - НДС */
/*15 - Сумма товаров без НсП */
/*16 - НсП */
/*17 - Сумма */


&SCOPED-DEFINE DISPLAY-FRAME         DISPLAY stream  PrnLibStream with frame FKomis. ~
                                     DOWN 1 stream PrnLibStream with frame FKomis.

&SCOPED-DEFINE DOWN-FRAME            DOWN 1 stream PrnLibStream with frame Fkomis.
&SCOPED-DEFINE DOWN-EXCEL            ~{&PutExcel} skip.

&SCOPED-DEFINE f-sums "->>,>>>,>>>,>>9.99"
&SCOPED-DEFINE f-sums-xls '0.00'

DEFINE VARIABLE fill5 as character no-undo.
DEFINE VARIABLE fill6 as character no-undo.
DEFINE VARIABLE fill9 as character no-undo.
DEFINE VARIABLE fill13 as character no-undo.
DEFINE VARIABLE fill15 as character no-undo.
DEFINE VARIABLE fill16 as character no-undo.
DEFINE VARIABLE fill18 as character no-undo.
DEFINE VARIABLE fill19 as character no-undo.
DEFINE VARIABLE fill30 as character no-undo.
DEFINE VARIABLE date_string     as      char    no-undo.
DEFINE VARIABLE Line  as character no-undo .
DEFINE VARIABLE v-nn                      as integer                  no-undo .
DEFINE VARIABLE v-artic                   like ub.doc-line.artic      no-undo .
DEFINE VARIABLE v-gds-name                like ub.goods.gds-name      no-undo .
DEFINE VARIABLE v-prod                    as character no-undo .
DEFINE VARIABLE v-unit-base               like ub.goods.unit-base     no-undo .
DEFINE VARIABLE v-qnty                    like ub.doc-line.doc-qnty   no-undo .
DEFINE VARIABLE v-price-without-tax-cost  like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-sum-without-tax-cost    like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-sum-vat-cost            like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-sum-with-tax-cost       like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-price-without-tax-sale  like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-sum-without-tax-sale    like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-sum-vat-sale            like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-sum-without-slt-sale    like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-sum-slt-sale            like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-sum-with-slt-sale       like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE accum-qnty                    like ub.doc-line.doc-qnty   no-undo .
DEFINE VARIABLE accum-sum-without-tax-cost    like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE accum-sum-vat-cost            like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE accum-sum-with-tax-cost       like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE accum-sum-without-tax-sale    like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE accum-sum-vat-sale            like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE accum-sum-without-slt-sale    like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE accum-sum-slt-sale            like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE accum-sum-with-tax-sale       like ub.doc-line.price-rubl no-undo .
DEFINE VARIABLE v-choice                      as integer no-undo .
DEFINE VARIABLE v-gen-print                   as logical no-undo init yes.

DEFINE VARIABLE t-1 AS CHARACTER INITIAL "||||"
     VIEW-AS EDITOR
     SIZE 1 BY 4 NO-UNDO.


DEFINE FRAME top-frame
t-1       AT ROW 1 COL 1 no-label
HEADER
string( "Дата печати :" ) AT 5 format "x(15)" TODAY format "99.99.9999"
string( " , " ) format "X(3)" string(TIME, "HH:MM")
string( "Страница" ) AT 45 PAGE-NUMBER( PrnLibStream ) AT 55 FORMAT ">>9" SKIP
with width {&DOS_CW_2} down stream-io use-text NO-BOX.

DEFINE FRAME FKomis
with width {&DOS_CW_2} down stream-io use-text NO-BOX.


find first cli_supp no-lock where
          cli_supp.obj-type = p-supp-type
      AND cli_supp.obj-code = p-supp-code no-error .
if not available cli_supp then do:
  message
  vss-workfile vss-revision vss-description skip
  "Не найден поставщик" p-supp-type p-supp-code
  view-as alert-box error .
  return error .
end.
if RS-BY < 1 AND RS-by > 4 then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметра RS-by = "RS-by
  view-as alert-box error .
  return error .
end.



run waitfram-show in this-procedure ("Ждите...").

assign
fill5 = fill("-", 5)
fill6 = fill("-", 6)
fill9 = fill("-", 9)
fill13 = fill("-", 13)
fill15 = fill("-", 15)
fill16 = fill("-", 16)
fill18 = fill("-", 18)
fill30 = fill("-", 30)
.



assign
sheetf.Excel-Column-Lable =  ""
sheetf.sizes = ""
.
CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .

l-col-pos = 1.
Assign l-col-type="INTEGER" l-col-len=5 l-col-format= ">>>9"  l-col-lable = {&space-char} + "NN" + {&space-char} + {&space-char}.
  { rep/dincol.i cr  1    v-nn FKomis  }
  { rep/dincol.i crx 1 }
Assign l-col-type="CHARACTER" l-col-len=16 l-col-format= "X(16)"  l-col-lable = "Артикул".
  { rep/dincol.i cr  2    v-artic FKomis  }
  { rep/dincol.i crx 2 }
Assign l-col-type="CHARACTER" l-col-len=30 l-col-format= "X(30)"  l-col-lable = "Название товара".
  { rep/dincol.i cr  3    v-gds-name FKomis  }
  { rep/dincol.i crx 3 }
Assign l-col-type="CHARACTER" l-col-len=13 l-col-format= "X(13)"  l-col-lable = "Производитель".
  { rep/dincol.i cr  4    v-prod FKomis  }
  { rep/dincol.i crx 4 }
Assign l-col-type="CHARACTER" l-col-len=6 l-col-format= "X(6)"  l-col-lable = "Ед.Изм".
  { rep/dincol.i cr  5    v-unit-base FKomis  }
  { rep/dincol.i crx 5 }
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>,>>>,>>9.999"  l-col-lable = "Количество".
  { rep/dincol.i cr  6    v-qnty FKomis  }
  { rep/dincol.i crx 6 }
Assign l-col-type="DECIMAL" l-col-len=18 l-col-format= {&f-sums}  l-col-lable = "Учетная цена без НДС".
  { rep/dincol.i cr  7   v-price-without-tax-cost FKomis  }
  { rep/dincol.i crx 7 }
Assign l-col-type="DECIMAL" l-col-len=18 l-col-format= {&f-sums}  l-col-lable = "Сумма уч. цен без НДС".
  { rep/dincol.i cr  8   v-sum-without-tax-cost FKomis  }
  { rep/dincol.i crx 8 }
Assign l-col-type="DECIMAL" l-col-len=18 l-col-format= {&f-sums}  l-col-lable = "НДС поставщика".
  { rep/dincol.i cr  9   v-sum-vat-cost FKomis  }
  { rep/dincol.i crx 9 }
Assign l-col-type="DECIMAL" l-col-len=18 l-col-format= {&f-sums}  l-col-lable = "Сумма уч. цен".
  { rep/dincol.i cr  10   v-sum-with-tax-cost FKomis  }
  { rep/dincol.i crx 10 }
Assign l-col-type="DECIMAL" l-col-len=18 l-col-format= {&f-sums}  l-col-lable = "Цена ед. изм без налога".
  { rep/dincol.i cr  11   v-price-without-tax-sale FKomis  }
  { rep/dincol.i crx 11 }
Assign l-col-type="DECIMAL" l-col-len=18 l-col-format= {&f-sums}  l-col-lable = "Сумма товаров без налога".
  { rep/dincol.i cr  12   v-sum-without-tax-sale FKomis  }
  { rep/dincol.i crx 12 }
Assign l-col-type="DECIMAL" l-col-len=18 l-col-format= {&f-sums}  l-col-lable = "НДС".
  { rep/dincol.i cr  13   v-sum-vat-sale FKomis  }
  { rep/dincol.i crx 13 }
Assign l-col-type="DECIMAL" l-col-len=18 l-col-format= {&f-sums}  l-col-lable = "Сумма товаров без НсП".
  { rep/dincol.i cr  14   v-sum-without-slt-sale FKomis  }
  { rep/dincol.i crx 14 }
Assign l-col-type="DECIMAL" l-col-len=18 l-col-format= {&f-sums}  l-col-lable = "НсП".
  { rep/dincol.i cr  15   v-sum-slt-sale FKomis  }
  { rep/dincol.i crx 15 }
Assign l-col-type="DECIMAL" l-col-len=18 l-col-format= {&f-sums}  l-col-lable = "Сумма".
  { rep/dincol.i cr  16   v-sum-with-tax-sale FKomis  }
  { rep/dincol.i crx 16 }


if frame FKomis:width < l-col-pos - 1 then frame FKomis:width = l-col-pos - 1.
assign
Line = fill( "-" , 60 )
p-frame-width = l-col-pos - 1
.
if p-frame-width > 198 then do:
  run waitfram-hide in this-procedure .
  run gbl/d-askw.w (input "Формат вывода",
                input ("Общая ширина интересующих Вас колонок больше:" + string(198) + {&new-line} +
                       "отчет не уместится на бумаге формата А4 (ориентация альбомная)"
                      ),
                input "|",
                input ("Выводить только в Excel|" +
                       "Формат А3 (ориентация альбомная)|" +
                       "Уменьшить количество интервалов"),
                input "||",
                input 1,
                input 3,
                output v-choice).
   if v-choice = 3 then do:
     DELETE WIDGET-POOL "My-pool".
     run waitfram-hide in this-procedure .
     return.
   end.
   if v-choice = 1 then v-Gen-Print = no.
end.

run FillTable in this-procedure no-error  .

if error-status:error then do:
  DELETE WIDGET-POOL "My-pool".
  run waitfram-hide in this-procedure .
  return error .
end.

if not avail sj-goods then do:
  DELETE WIDGET-POOL "My-pool".
  run waitfram-hide in this-procedure .
  message
  "Нет данных для отчета"
  view-as alert-box .
  return.
end.

if v-gen-print then do:
  { cmp/open-out.i stream PrnLibStream " "  {&LS_PS_A4} }

  FORM with FRAME FKomis .

  FORM HEADER
  Line format "X(60)" AT 1 SKIP
  string( "Продолжение - на следующей странице" ) FORMAT "X(40)" AT 10 SKIP
  with FRAME NBottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream PrnLibStream FRAME NBottomFrame .
  PUT stream PrnLibStream UNFORMATTED
  SPACE(10)
  p-Report-header
  SKIP(1).
  display STREAM PrnLibStream with frame top-Frame .
end.
run rep/extitle.p (1).

assign
accum-qnty                   = 0
accum-sum-without-tax-cost   = 0
accum-sum-vat-cost           = 0
accum-sum-with-tax-cost      = 0
accum-sum-without-tax-sale   = 0
accum-sum-vat-sale           = 0
accum-sum-without-slt-sale   = 0
accum-sum-slt-sale           = 0
accum-sum-with-tax-sale      = 0
.

FOR EACH sj-goods no-lock
By sj-goods.artic
By sj-goods.prod-type
By sj-goods.prod-code:

  assign
  v-nn = v-nn + 1
  v-prod = sj-goods.prod-type + {&space-char} + string(sj-goods.prod-code)
  v-sum-without-slt-sale = sj-goods.sum-with-tax-sale_ - sj-goods.sum-slt-sale_
  accum-qnty                   = accum-qnty                   + sj-goods.qnty
  accum-sum-without-tax-cost   = accum-sum-without-tax-cost   + sj-goods.sum-without-tax-cost_
  accum-sum-vat-cost           = accum-sum-vat-cost           + sj-goods.sum-vat-cost_
  accum-sum-with-tax-cost      = accum-sum-with-tax-cost      + sj-goods.sum-with-tax-cost_
  accum-sum-without-tax-sale   = accum-sum-without-tax-sale   + sj-goods.sum-without-tax-sale_
  accum-sum-vat-sale           = accum-sum-vat-sale           + sj-goods.sum-vat-sale_
  accum-sum-without-slt-sale   = accum-sum-without-slt-sale   + v-sum-without-slt-sale
  accum-sum-slt-sale           = accum-sum-slt-sale           + sj-goods.sum-slt-sale_
  accum-sum-with-tax-sale      = accum-sum-with-tax-sale      + sj-goods.sum-with-tax-sale_
  .
  if v-gen-print then do:
    { rep/dincol.i di 1 v-nn    v-nn }
    { rep/dincol.i di 2 v-artic sj-goods.artic }
    { rep/dincol.i di 3 v-gds-name  sj-goods.gds-name }
    { rep/dincol.i di 4 v-prod     v-prod }
    { rep/dincol.i di 5 v-unit-base sj-goods.unit }
    { rep/dincol.i di 6 v-qnty      sj-goods.qnty }
    { rep/dincol.i di 7 v-price-without-tax-cost  sj-goods.price-without-tax-cost_ }
    { rep/dincol.i di 8 v-sum-without-tax-cost sj-goods.sum-without-tax-cost_ }
    { rep/dincol.i di 9 v-sum-vat-cost sj-goods.sum-vat-cost_ }
    { rep/dincol.i di 10 v-sum-with-tax-cost sj-goods.sum-with-tax-cost_ }
    { rep/dincol.i di 11 v-price-without-tax-sale sj-goods.price-without-tax-sale_ }
    { rep/dincol.i di 12 v-sum-without-tax-sale sj-goods.sum-without-tax-sale_ }
    { rep/dincol.i di 13 v-sum-vat-sale sj-goods.sum-vat-sale_ }
    { rep/dincol.i di 14 v-sum-without-slt-sale v-sum-without-slt-sale }
    { rep/dincol.i di 15 v-sum-slt-sale sj-goods.sum-slt-sale_ }
    { rep/dincol.i di 16 v-sum-with-tax-sale sj-goods.sum-with-tax-sale_ }
    {&DISPLAY-FRAME}
   end.

    {&PutExcel}
    { rep/dincol.i dix 1 v-nn v-nn }
    { rep/dincol.i dix 2 v-artic sj-goods.artic }
    { rep/dincol.i dix 3 v-gds-name  sj-goods.gds-name }
    { rep/dincol.i dix 4 v-prod     v-prod }
    { rep/dincol.i dix 5 v-unit-base sj-goods.unit }
    { rep/dincol.i dix 6 v-qnty      sj-goods.qnty }
    { rep/dincol.i dix 7 v-price-without-tax-cost  sj-goods.price-without-tax-cost_ }
    { rep/dincol.i dix 8 v-sum-without-tax-cost sj-goods.sum-without-tax-cost_ }
    { rep/dincol.i dix 9 v-sum-vat-cost sj-goods.sum-vat-cost_ }
    { rep/dincol.i dix 10 v-sum-with-tax-cost sj-goods.sum-with-tax-cost_ }
    { rep/dincol.i dix 11 v-price-without-tax-sale sj-goods.price-without-tax-sale_ }
    { rep/dincol.i dix 12 v-sum-without-tax-sale sj-goods.sum-without-tax-sale_ }
    { rep/dincol.i dix 13 v-sum-vat-sale sj-goods.sum-vat-sale_ }
    { rep/dincol.i dix 14 v-sum-without-slt-sale v-sum-without-slt-sale }
    { rep/dincol.i dix 15 v-sum-slt-sale sj-goods.sum-slt-sale_ }
    { rep/dincol.i dix 16 v-sum-with-tax-sale sj-goods.sum-with-tax-sale_ }
    skip.

END. /*for each sj-goods*/

if v-gen-print then do:
  run UNDERLINE-FRAME in this-procedure .

  { rep/dincol.i di 1 v-nn    v-nn }
  { rep/dincol.i di 6 v-qnty      accum-qnty }
  { rep/dincol.i di 8 v-sum-without-tax-cost accum-sum-without-tax-cost }
  { rep/dincol.i di 9 v-sum-vat-cost accum-sum-vat-cost }
  { rep/dincol.i di 10 v-sum-with-tax-cost accum-sum-with-tax-cost }
  { rep/dincol.i di 12 v-sum-without-tax-sale accum-sum-without-tax-sale }
  { rep/dincol.i di 13 v-sum-vat-sale accum-sum-vat-sale }
  { rep/dincol.i di 14 v-sum-without-slt-sale accum-sum-without-slt-sale }
  { rep/dincol.i di 15 v-sum-slt-sale accum-sum-slt-sale }
  { rep/dincol.i di 16 v-sum-with-tax-sale accum-sum-with-tax-sale }
  {&DISPLAY-FRAME}

  Put stream PrnLibStream UNFORMATTED
  skip(2)
  fill({&space-char}, 15)
  "ИТОГО продано с учетом НДС" {&space-char}
  fill({&space-char}, 15)
  string(accum-sum-without-slt-sale, {&f-sums})  AT 100
  skip
  fill({&space-char}, 15)
  "За проданный товар Комиссионеру причитается вознаграждение в сумме" {&space-char}
  fill({&space-char}, 15)
  string(accum-sum-without-slt-sale - accum-sum-with-tax-cost, {&f-sums}) AT 100
  skip
   fill({&space-char}, 15)
  "Подлежит перечислению Комитенту сумма" {&space-char}
   fill({&space-char}, 15)
   string(accum-sum-with-tax-cost, {&f-sums}) AT 100
   skip(2)
   fill({&space-char}, 15)
   "От Комиссионера" {&space-char} p-host-name {&space-char}
   "отчет сдал" {&space-char} fill("_", 15)
   skip
   fill({&space-char}, 54)
   "(подпись)"
   skip
   fill({&space-char}, 45) "М.П."
   skip(2)
   fill({&space-char}, 15)
   "От Комитента" {&space-char} p-supp-name {&space-char}
   "отчет принял" {&space-char} fill("_", 15)
   skip
   fill({&space-char}, 54)
   "(подпись)"
   skip
   fill({&space-char}, 45) "М.П."
   skip.

end.

run UNDERLINE-EXCEL in this-procedure .

{&PutExcel}
{ rep/dincol.i dix 1 v-nn    v-nn }
{ rep/dincol.i dit 2 v-artic }
{ rep/dincol.i dit 3 v-gds-name }
{ rep/dincol.i dit 4 v-prod   }
{ rep/dincol.i dit 5 v-unit-base  }
{ rep/dincol.i dix 6 v-qnty      accum-qnty }
{ rep/dincol.i dit 7 v-price-without-tax-cost  }
{ rep/dincol.i dix 8 v-sum-without-tax-cost accum-sum-without-tax-cost }
{ rep/dincol.i dix 9 v-sum-vat-cost accum-sum-vat-cost }
{ rep/dincol.i dix 10 v-sum-with-tax-cost accum-sum-with-tax-cost }
{ rep/dincol.i dit 11 v-price-without-tax-sale  }
{ rep/dincol.i dix 12 v-sum-without-tax-sale accum-sum-without-tax-sale }
{ rep/dincol.i dix 13 v-sum-vat-sale accum-sum-vat-sale }
{ rep/dincol.i dix 14 v-sum-without-slt-sale accum-sum-without-slt-sale }
{ rep/dincol.i dix 15 v-sum-slt-sale accum-sum-slt-sale }
{ rep/dincol.i dix 16 v-sum-with-tax-sale accum-sum-with-tax-sale }
SKIP(2).

{&PutExcel}
{&tabulation}
{&tabulation}
"ИТОГО продано с учетом НДС" {&tabulation}
string(accum-sum-without-slt-sale, {&f-sums})
skip
{&tabulation}
{&tabulation}
"За проданный товар Комиссионеру причитается вознаграждение в сумме"   {&tabulation}
string(accum-sum-without-slt-sale - accum-sum-with-tax-cost, {&f-sums})
skip
{&tabulation}
{&tabulation}
"Подлежит перечислению Комитенту сумма" {&tabulation}
string(accum-sum-with-tax-cost, {&f-sums})
skip(2)
{&tabulation}
{&tabulation}
"От Комиссионера" {&tabulation}
{&tabulation}
{&tabulation}
p-host-name {&tabulation}
"отчет сдал"
skip
{&tabulation}
{&tabulation}
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
{&tabulation}
"М.П."
skip(2)
{&tabulation}
{&tabulation}
"От Комитента" {&tabulation}
{&tabulation}
{&tabulation}
p-supp-name {&tabulation}
"отчет принял"
skip
{&tabulation}
{&tabulation}
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
{&tabulation}
"М.П."
skip.

if v-gen-print then do:
  HIDE STREAM PrnLibStream FRAME FKomis .
  HIDE STREAM PrnLibStream FRAME top-Frame .
  HIDE stream PrnLibStream FRAME NBottomFrame .
  output stream PrnLibStream CLOSE .
end.

{&CloseExcel}
run waitfram-hide in this-procedure .
DELETE WIDGET-POOL "My-pool".
if p-frame-width  <= 198 then do:
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 8
                                            ).
end.
else do:
  run get-report-num  in parparentproc (output g#report-num).
  run rep/runexcel.p (string( session:temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt").
end.

procedure underline-frame :

  do
  on error undo, return error
  :
       { rep/dincol.i un 1 v-nn fill5 }
      { rep/dincol.i un 2 v-artic fill16}
      { rep/dincol.i un 3 v-gds-name fill30}
      { rep/dincol.i un 4 v-prod     fill13}
      { rep/dincol.i un 5 v-unit-base fill6}
      { rep/dincol.i un 6 v-qnty      fill15}
      { rep/dincol.i un 7 v-price-without-tax-cost  fill18}
      { rep/dincol.i un 8 v-sum-without-tax-cost fill18}
      { rep/dincol.i un 9 v-sum-vat-cost fill18}
      { rep/dincol.i un 10 v-sum-with-tax-cost fill18}
      { rep/dincol.i un 11 v-price-without-tax-sale fill18}
      { rep/dincol.i un 12 v-sum-without-tax-sale fill18}
      { rep/dincol.i un 13 v-sum-vat-sale fill18}
      { rep/dincol.i un 14 v-sum-without-slt-sale fill18}
      { rep/dincol.i un 15 v-sum-slt-sale fill18}
      { rep/dincol.i un 16 v-sum-with-tax-sale fill18}
      DISPLAY stream  PrnLibStream with frame FKomis.
      DOWN 1 stream PrnLibStream with frame Fkomis.


  end.

end procedure. /* underline-frame */

procedure underline-excel :

  do
  on error undo, return error
  :
      {&PutExcel}
      { rep/dincol.i unx 1 v-nn fill5}
      { rep/dincol.i unx 2 v-artic fill16}
      { rep/dincol.i unx 3 v-gds-name fill30}
      { rep/dincol.i unx 4 v-prod-type fill13}
      { rep/dincol.i unx 5 v-unit-base fill6}
      { rep/dincol.i unx 6 v-qnty      fill15}
      { rep/dincol.i unx 7 v-price-without-tax-cost  fill18}
      { rep/dincol.i unx 8 v-sum-without-tax-cost fill18}
      { rep/dincol.i unx 9 v-sum-vat-cost fill18}
      { rep/dincol.i unx 10 v-sum-with-tax-cost fill18}
      { rep/dincol.i unx 11 v-price-without-tax-sale fill18}
      { rep/dincol.i unx 12 v-sum-without-tax-sale fill18}
      { rep/dincol.i unx 13 v-sum-vat-sale fill18}
      { rep/dincol.i unx 14 v-sum-without-slt-sale fill18}
      { rep/dincol.i unx 15 v-sum-slt-sale fill18}
      { rep/dincol.i unx 16 v-sum-with-tax-sale fill18}
      skip.

  end.

end procedure. /* underline-excel */
