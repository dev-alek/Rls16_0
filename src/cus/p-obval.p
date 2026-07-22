block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: p-obval.p $
$Archive: cus/p-obval.p $

Печать оборота в валюте поставщика

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/20/06
Author: Bakhtadze Natalya
Creation date: 01/20/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter pcurr-code like ub.trn-doc.exch-code no-undo.
/* валюта поставки если ? значит все */
define input parameter pnum-obj    as integer no-undo.
/* количество объектов в выборке */
define input parameter pall-obj    as logical no-undo.
/* все ли объекты выбраны */
define input parameter pReport-Header    as Character no-undo.
/*какой длины в итоге получился фрейм*/
define output parameter p-frame-width as integer no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: p-obval.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/p-obval.p $":U .
define variable vss-description as character no-undo init "Печать оборота в валюте поставщика".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/r-pril.i new }
{ cmp/r-page1.i  }
{ gbl/prn-lib.i }
{ cus/r-obval.i "def" "SHARED"}
{ rep/dincol.i def }
{ cmp/breakstr.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ cmp/cli-list.i cli-list def shared }
{ rep/lhstprex.i cli-list-hist }


/* печать возможна в вариантах фрейма */
/* все валюты один объект vOption */
/* все валюты несколько объектов но не все */
/* все валюты все объекты */
/* одна валюта один объект */
/* одна валюта несколько объектов но не все */
/* одна валюта  все объекты */
/* ПОЛНЫЙ порядок полей фрейма */
/*1 - Валюта поставки*/
/*2 - Текущий объект*/
/*3 - Номер ПН*/
/*4 - Дата ПН*/
/*5 - объект первоначального прихода*/
/*6 - Условия поставки*/
/*7 - Номер партии (part-code)*/
/*8 - Артикул производитель ?*/
/*9 - Название товара*/
/*10 - Единица измерени*/
/*11 - Цена поставки*/
/*12 - Сколько изначально поставили (на объект первоначального прихода)*/
/*13 - Сколько на текущий за выбранный интервал времени (- возврат поставщику + внутренний приход)*/
/*14 - Сумма in*/
/*15 - Кол-во расхода*/
/*16 - Сумма out*/
/*17 - Остаток*/

&SCOPED-DEFINE UNDERLINE-FRAME ~{ rep/dincol.i un 1 FOR-CURR-OBJ fill8 ~} ~
      ~{ rep/dincol.i un 2 for-IN-CODE fill14~} ~
      ~{ rep/dincol.i un 3 for-IN-DATE fill10~} ~
      ~{ rep/dincol.i un 4 for-ini-obj fill8~} ~
      ~{ rep/dincol.i un 5 for-terms fill20~} ~
      ~{ rep/dincol.i un 6 for-part-code fill14~} ~
      ~{ rep/dincol.i un 7 for-artic fill16~} ~
      ~{ rep/dincol.i un 8 for-gds-name fill22~} ~
      ~{ rep/dincol.i un 9 for-unit fill3~} ~
      ~{ rep/dincol.i un 10 for-price-cli-in-brutto fill18~} ~
      ~{ rep/dincol.i un 11 for-VAT-pc fill5~} ~
      ~{ rep/dincol.i un 12 for-SLT-pc fill5~} ~
      ~{ rep/dincol.i un 13 for-price-cli-in fill18~} ~
      ~{ rep/dincol.i un 14 for-qnty-all fill15~} ~
      ~{ rep/dincol.i un 15 for-qnty-in fill15~} ~
      ~{ rep/dincol.i un 16 for-price-cli-in-sum fill18~} ~
      ~{ rep/dincol.i un 17 for-qnty-out fill15~} ~
      ~{ rep/dincol.i un 18 for-price-cli-out-sum fill18~} ~
      ~{ rep/dincol.i un 19 for-qnty-rest fill15~} ~
      DISPLAY stream  PrnLibStream with frame Obval. ~
      DOWN 1 stream PrnLibStream with frame Obval.


&SCOPED-DEFINE UNDERLINE-Excel ~{&PutExcel} ~
      ~{ rep/dincol.i unx 1 for-curr-obj fill8 ~} ~
      ~{ rep/dincol.i unx 2 for-in-code fill14~} ~
      ~{ rep/dincol.i unx 3 for-in-date fill10~} ~
      ~{ rep/dincol.i unx 4 for-ini-obj fill8~} ~
      ~{ rep/dincol.i unx 5 for-terms fill20~} ~
      ~{ rep/dincol.i unx 6 for-part-code fill14~} ~
      ~{ rep/dincol.i unx 7 for-artic fill16~} ~
      ~{ rep/dincol.i unx 8 for-gds-name fill22~} ~
      ~{ rep/dincol.i unx 9 for-unit fill3~} ~
      ~{ rep/dincol.i unx 10 for-price-cli-in-brutto fill18~} ~
      ~{ rep/dincol.i unx 11 for-VAT-pc fill5~} ~
      ~{ rep/dincol.i unx 12 for-SLT-pc fill5~} ~
      ~{ rep/dincol.i unx 13 for-price-cli-in fill18~} ~
      ~{ rep/dincol.i unx 14 for-qnty-all fill15~} ~
      ~{ rep/dincol.i unx 15 for-qnty-in fill15~} ~
      ~{ rep/dincol.i unx 16 for-price-cli-in-sum fill18~} ~
      ~{ rep/dincol.i unx 17 for-qnty-out fill15~} ~
      ~{ rep/dincol.i unx 18 for-price-cli-out-sum fill18~} ~
      ~{ rep/dincol.i unx 19 for-qnty-rest fill15~} ~
      skip.




&SCOPED-DEFINE DISPLAY-FRAME         DISPLAY stream  PrnLibStream with frame Obval. ~
                                     DOWN 1 stream PrnLibStream with frame Obval.

&SCOPED-DEFINE DOWN-FRAME            DOWN 1 stream PrnLibStream with frame Obval.
&SCOPED-DEFINE DOWN-EXCEL            ~{&PutExcel} skip.

DEFINE VARIABLE LINE as character no-undo.
DEFINE VARIABLE FOR-curr-OBJ AS CHARACTER FORMAT "x(9)" NO-UNDO.
DEFINE VARIABLE for-in-code like temp-goods.in-code no-undo.
DEFINE VARIABLE for-in-date like temp-goods.in-date no-undo.
DEFINE VARIABLE FOR-INI-OBJ AS CHARACTER FORMAT "x(9)" NO-UNDO.
DEFINE VARIABLE FOR-terms AS CHARACTER FORMAT "x(20)" NO-UNDO.
DEFINE VARIABLE for-part-code like temp-goods.part-code no-undo.
DEFINE VARIABLE for-artic like temp-goods.artic no-undo.
DEFINE VARIABLE for-gds-name like temp-goods.gds-name no-undo.
DEFINE VARIABLE for-unit like temp-goods.unit no-undo.
DEFINE VARIABLE for-price-cli-in-brutto like temp-goods.price-cli-in no-undo.
DEFINE VARIABLE for-vat-pc like ub.parts.vat-pc no-undo.
DEFINE VARIABLE for-slt-pc like ub.parts.slt-pc no-undo.
DEFINE VARIABLE for-price-cli-in like temp-goods.price-cli-in no-undo.
DEFINE VARIABLE for-qnty-all like temp-goods.qnty-all no-undo.
DEFINE VARIABLE for-qnty-in like temp-goods.qnty-in no-undo.
DEFINE VARIABLE for-price-cli-in-sum like temp-goods.price-cli-in-sum no-undo.
DEFINE VARIABLE for-qnty-out like temp-goods.qnty-out no-undo.
DEFINE VARIABLE for-price-cli-out-sum like temp-goods.price-cli-out-sum no-undo.
DEFINE VARIABLE for-qnty-rest like temp-goods.qnty-rest no-undo.
DEFINE VARIABLE fill3 as character no-undo.
DEFINE VARIABLE fill5 as character no-undo.
DEFINE VARIABLE fill8 as character no-undo.
DEFINE VARIABLE fill9 as character no-undo.
DEFINE VARIABLE fill10 as character no-undo.
DEFINE VARIABLE fill14 as character no-undo.
DEFINE VARIABLE fill15 as character no-undo.
DEFINE VARIABLE fill16 as character no-undo.
DEFINE VARIABLE fill18 as character no-undo.
DEFINE VARIABLE fill19 as character no-undo.
DEFINE VARIABLE fill20 as character no-undo.
DEFINE VARIABLE fill22 as character no-undo.
DEFINE VARIABLE fill25 as character no-undo.
DEFINE VARIABLE accum-qnty-all-by-exch-code as decimal no-undo.
DEFINE VARIABLE accum-in-qnty-by-exch-code as decimal no-undo.
DEFINE VARIABLE accum-out-qnty-by-exch-code as decimal no-undo .
DEFINE VARIABLE accum-qnty-all-by-supp-code as decimal no-undo.
DEFINE VARIABLE accum-in-qnty-by-supp-code as decimal no-undo.
DEFINE VARIABLE accum-out-qnty-by-supp-code as decimal no-undo .
DEFINE VARIABLE accum-in-by-exch-code as decimal no-undo.
DEFINE VARIABLE accum-out-by-exch-code as decimal no-undo .
DEFINE VARIABLE accum-in-by-supp-code as decimal no-undo.
DEFINE VARIABLE accum-out-by-supp-code as decimal no-undo .
DEFINE VARIABLE suppnamebuf1 as character no-undo.
DEFINE VARIABLE suppnamebuf2 as character no-undo.
DEFINE VARIABLE first-good as logical no-undo init yes.
DEFINE VARIABLE first-supp as logical no-undo init yes.
DEFINE VARIABLE v-artic-cols as character no-undo .
DEFINE VARIABLE jj as integer no-undo .


DEFINE STREAM PrnLibStream.

DEFINE VARIABLE t-1 AS CHARACTER INITIAL "||||"
     VIEW-AS EDITOR
     SIZE 1 BY 4 NO-UNDO.


DEFINE FRAME top-frame
    t-1       AT ROW 1 COL 1 no-label
    HEADER
    string( cur-time-print() ) AT 5 format "x(35)"
    string( "Страница" ) AT 45 PAGE-NUMBER( PrnLibStream ) AT 55 FORMAT ">>9" SKIP
    with width {&DOS_CW_2} down stream-io use-text NO-BOX.

 DEFINE FRAME obval
   with width {&DOS_CW_2} down stream-io use-text NO-BOX.

run waitfram-show in this-procedure ("Ждите...").
assign
use-column[1] = (if pnum-obj > 1 then yes else no)
use-column[2] = yes
use-column[3] = yes
use-column[4] = yes
/*use-column[5] = use-column[5] условия поставки*/
/*use-column[6] = use-column[6] part-code */
use-column[7] = yes
use-column[8] = yes
use-column[9] = yes
/*
use-column[10] = use-column[10] цена брутто
use-column[11] = use-column[11] VAT-pc
use-column[12] = use-column[12] slt-pc
use-column[13] = use-column[13] цена нетто
use-column[14] = use-column[14] первоначально пришло
*/
use-column[15] = yes
use-column[16] = yes
use-column[17] = yes
use-column[18] = yes
use-column[19] = /*(if pall-obj then yes else no)*/ no
fill3 = fill("-", 3)
fill5 = fill("-", 5)
fill8 = fill("-", 8)
fill9 = fill("-", 9)
fill10 = fill("-", 10)
fill14 = fill("-", 14)
fill15 = fill("-", 15)
fill16 = fill("-", 16)
fill18 = fill("-", 18)
fill19 = fill("-", 19)
fill20 = fill("-", 20)
fill22 = fill("-", 22)
fill25 = fill("-", 25)
.

assign
sheetf.Excel-Column-Lable =  ""
sheetf.sizes = ""
sheetf.colformat = "":U.
.

CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .

l-col-pos = 1.
Assign l-col-type="CHARACTER" l-col-len=8 l-col-format= "X(8)"     l-col-lable="Объект".
  { rep/dincol.i cr  1    for-curr-obj  Obval                 }
  { rep/dincol.i crx 1 }
Assign l-col-type="CHARACTER" l-col-len=14 l-col-format= "X(14)"       l-col-lable="ПН".
  { rep/dincol.i cr  2    for-in-code       Obval                 }
  { rep/dincol.i crx 2 }
Assign l-col-type="DATE"   l-col-len=10  l-col-format= "99/99/9999"  l-col-lable="Дата ПН".
  { rep/dincol.i cr  3    for-in-date    Obval        }
  { rep/dincol.i crx 3 }
Assign l-col-type="CHARACTER"   l-col-len=8  l-col-format= "X(8)"  l-col-lable="Объект прихода".
  { rep/dincol.i cr  4    for-ini-obj    Obval        }
  { rep/dincol.i crx 4 }
Assign l-col-type="CHARACTER"   l-col-len=20  l-col-format= "X(20)"  l-col-lable="Условия   поставки".
  { rep/dincol.i cr  5    for-terms     Obval       }
  { rep/dincol.i crx 5 }
Assign l-col-type="CHARACTER"   l-col-len=14  l-col-format= "X(14)"  l-col-lable="Партия".
  { rep/dincol.i cr  6    for-part-code     Obval      }
  { rep/dincol.i crx 6 }
Assign l-col-type="CHARACTER"   l-col-len=16  l-col-format= "X(16)"  l-col-lable="Артикул".
  { rep/dincol.i cr  7    for-artic     Obval     }
  { rep/dincol.i crx 7 }
assign
v-artic-cols = v-artic-cols + (if v-artic-cols = "":U then "":U else {&comma-char}) + string(v-r-col-num).
Assign l-col-type="CHARACTER"   l-col-len=22  l-col-format= "X(22)"  l-col-lable="Название товара".
  { rep/dincol.i cr  8    for-gds-name     Obval      }
  { rep/dincol.i crx 8 }
Assign l-col-type="CHARACTER"   l-col-len=3  l-col-format= "X(3)"  l-col-lable="Ед.изм".
  { rep/dincol.i cr  9   for-unit     Obval      }
  { rep/dincol.i crx 9 }
Assign l-col-type="DECIMAL"   l-col-len=18  l-col-format= "->>,>>>,>>>,>>9.99"  l-col-lable="Цена по ТТН".
  { rep/dincol.i cr  10   for-price-cli-in-brutto     Obval       }
  { rep/dincol.i crx 10 }
Assign l-col-type="DECIMAL"   l-col-len=5  l-col-format= ">9.9"  l-col-lable="НДС %".
  { rep/dincol.i cr  11   for-VAT-pc     Obval       }
  { rep/dincol.i crx 11 }
Assign l-col-type="DECIMAL"   l-col-len=5  l-col-format= ">9.9"  l-col-lable="НП %".
  { rep/dincol.i cr  12   for-SLT-pc     Obval       }
  { rep/dincol.i crx 12 }
Assign l-col-type="DECIMAL"   l-col-len=18  l-col-format= "->>,>>>,>>>,>>9.99"  l-col-lable="Цена поставки с налогами".
  { rep/dincol.i cr  13   for-price-cli-in     Obval       }
  { rep/dincol.i crx 13 }
Assign l-col-type="DECIMAL"   l-col-len=15  l-col-format= "->>,>>>,>>9.999"  l-col-lable="Внешний  приход".
  { rep/dincol.i cr  14   for-qnty-all     Obval       }
  { rep/dincol.i crx 14 }
Assign l-col-type="INTEGER"   l-col-len=15  l-col-format= "->>,>>>,>>9.999"  l-col-lable="Приход за  период".
  { rep/dincol.i cr  15   for-qnty-in    Obval       }
  { rep/dincol.i crx 15 }
Assign l-col-type="INTEGER"   l-col-len=18  l-col-format= "->>,>>>,>>>,>>9.99"  l-col-lable="Сумма прихода".
  { rep/dincol.i cr  16   for-price-cli-in-sum    Obval       }
  { rep/dincol.i crx 16 }
Assign l-col-type="INTEGER"   l-col-len=15  l-col-format= "->>,>>>,>>9.999"  l-col-lable="Расход  за  период".
  { rep/dincol.i cr  17   for-qnty-out    Obval       }
  { rep/dincol.i crx 17 }
Assign l-col-type="INTEGER"   l-col-len=18  l-col-format= "->>,>>>,>>>,>>9.99"  l-col-lable="Сумма расхода".
  { rep/dincol.i cr  18   for-price-cli-out-sum    Obval       }
  { rep/dincol.i crx 18 }
Assign l-col-type="INTEGER"   l-col-len=15  l-col-format= "->>,>>>,>>9.999"  l-col-lable="Остаток".
  { rep/dincol.i cr  19   for-qnty-rest    Obval       }
  { rep/dincol.i crx 19 }
if frame obval:width < l-col-pos - 1 then frame obval:width = l-col-pos - 1.

Line = fill( "-" , 60 ) .

p-frame-width = l-col-pos - 1.
assign
sheetf.colformat = sheetf.colformat + {&delim-par}
.
if v-artic-cols <> "":U then do:
  do jj = 1 to num-entries(v-artic-cols):
    assign
    sheetf.colformat =  sheetf.colformat +
                        entry(jj, v-artic-cols)  + "=":U + "@":U + ";":U
    .
  end.
end.
assign
sheetf.colformat = trim(sheetf.colformat, ";":U)
.

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


FORM with FRAME Obval .
FORM HEADER
Line format "X(60)" AT 1 SKIP
string( "Продолжение - на следующей странице" ) FORMAT "X(40)" AT 10 SKIP
with FRAME NBottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW stream PrnLibStream FRAME NBottomFrame .
PUT stream PrnLibStream UNFORMATTED
SPACE(10)
(Reportname + {&new-line} +
 str1 + {&new-line} +
 str4 + {&new-line} )
pReport-Header
SKIP(1).
display STREAM PrnLibStream with frame top-Frame .
run rep/extitle.p (1).
FOR EACH temp-goods No-LOCK
    BREAK
    BY temp-goods.supp-type
    BY temp-goods.supp-code
    BY temp-goods.exch-code
    :

  IF FIRST-OF(temp-goods.supp-code) then do:
    if pcurr-code <> ? then
    assign
    accum-qnty-all-by-exch-code = 0
    accum-qnty-all-by-supp-code = 0
    accum-in-by-supp-code = 0
    accum-out-by-supp-code = 0
    accum-in-qnty-by-supp-code = 0
    accum-out-qnty-by-supp-code = 0
    .
    first-good = yes.
    FIND FIRST ub.clients No-LOCK WHERE
               ub.clients.obj-type = temp-goods.supp-type AND
               ub.clients.obj-code = temp-goods.supp-code NO-ERROR.
    if avail ub.clients then do:
      assign
      suppnamebuf1 = substr(ub.clients.obj-name, 1,25)
      .
    end.
    else do:
      assign
      suppnamebuf1 = temp-goods.supp-type + string(temp-goods.supp-code)
      .
    end.
    if not first-supp then do:
      { rep/dincol.i dil PrnLibStream top-frame}
      {&down-frame}
      { rep/dincol.i dil PrnLibStream top-frame}
      {&down-excel}
    end.
    first-supp = no.
    { rep/dincol.i di 2 for-in-code
                   "'Поставщик: '" }

    { rep/dincol.i di 8 for-gds-name
                   suppnamebuf1 }
    { rep/dincol.i dil PrnLibStream top-frame}
    {&DISPLAY-FRAME}
    { rep/dincol.i dil PrnLibStream top-frame}
    {&UNDERLINE-FRAME}

    {&PutExcel}
    { rep/dincol.i dit 1 }
    { rep/dincol.i dix 2 for-in-code
                   "'Поставщик: '" }
    { rep/dincol.i dit 3 }
    { rep/dincol.i dit 4 }
    { rep/dincol.i dit 5 }
    { rep/dincol.i dit 6 }
    { rep/dincol.i dit 7 }
    { rep/dincol.i dix 8 for-gds-name
                    suppnamebuf1 }
    { rep/dincol.i dit 9 }
    { rep/dincol.i dit 10 }
    { rep/dincol.i dit 11 }
    { rep/dincol.i dit 12 }
    { rep/dincol.i dit 13 }
    { rep/dincol.i dit 14 }
    { rep/dincol.i dit 15 }
    { rep/dincol.i dit 16 }
    { rep/dincol.i dit 17 }
    { rep/dincol.i dit 18 }
    { rep/dincol.i dit 19 }
    skip.

    {&UNDERLINE-EXCEL}
  END.
  IF FIRST-OF(temp-goods.exch-code) then do:
    assign
    accum-qnty-all-by-exch-code = 0
    accum-in-by-exch-code = 0
    accum-out-by-exch-code = 0
    accum-in-qnty-by-exch-code = 0
    accum-out-qnty-by-exch-code = 0
    .
    first-good = yes.
    if pcurr-code = ? then do:
      { rep/dincol.i di 2 for-in-code
                     "('Валюта: ' + temp-goods.curr-name)" }
      { rep/dincol.i dil PrnLibStream top-frame}
      {&DISPLAY-FRAME}
      { rep/dincol.i dil PrnLibStream top-frame}
      {&UNDERLINE-FRAME}

      {&PutExcel}
      { rep/dincol.i dit 1 }
      { rep/dincol.i dix 2 for-in-code
                     "('Валюта: ' + temp-goods.curr-name)" }
      { rep/dincol.i dit 3 }
      { rep/dincol.i dit 4 }
      { rep/dincol.i dit 5 }
      { rep/dincol.i dit 6 }
      { rep/dincol.i dit 7 }
      { rep/dincol.i dit 8 }
      { rep/dincol.i dit 9 }
      { rep/dincol.i dit 10 }
      { rep/dincol.i dit 11 }
      { rep/dincol.i dit 12 }
      { rep/dincol.i dit 13 }
      { rep/dincol.i dit 14 }
      { rep/dincol.i dit 15 }
      { rep/dincol.i dit 16 }
      { rep/dincol.i dit 17 }
      { rep/dincol.i dit 18 }
      { rep/dincol.i dit 19 }
      skip.
      {&UNDERLINE-EXCEL}
    end.
  end.

  assign
  accum-qnty-all-by-exch-code = accum-qnty-all-by-exch-code + if (pnum-obj > 1) = (temp-goods.obj-code = 0) then temp-goods.qnty-all else 0
  accum-in-qnty-by-exch-code = accum-in-qnty-by-exch-code + (if temp-goods.obj-code <> 0 then temp-goods.qnty-in else 0)
  accum-out-qnty-by-exch-code = accum-out-qnty-by-exch-code + (if temp-goods.obj-code <> 0 then temp-goods.qnty-out else 0)
  accum-in-by-exch-code = accum-in-by-exch-code + (if temp-goods.obj-code <> 0 then temp-goods.price-cli-in-sum else 0)
  accum-out-by-exch-code = accum-out-by-exch-code + (if temp-goods.obj-code <> 0 then temp-goods.price-cli-out-sum else 0)
  .
  if pcurr-code <> ? then
  assign
  accum-qnty-all-by-supp-code = accum-qnty-all-by-supp-code + if (pnum-obj > 1) = (temp-goods.obj-code = 0) then temp-goods.qnty-all else 0
  accum-in-qnty-by-supp-code = accum-in-qnty-by-supp-code + (if temp-goods.obj-code <> 0 then temp-goods.qnty-in else 0)
  accum-out-qnty-by-supp-code = accum-out-qnty-by-supp-code + (if temp-goods.obj-code <> 0 then temp-goods.qnty-out else 0)
  accum-in-by-supp-code = accum-in-by-supp-code + (if temp-goods.obj-code <> 0 then temp-goods.price-cli-in-sum else 0)
  accum-out-by-supp-code = accum-out-by-supp-code + (if temp-goods.obj-code <> 0 then temp-goods.price-cli-out-sum else 0)
  .
  /*вывод в обычный фрейм*/
  if pnum-obj > 1 and temp-goods.obj-code = 0 then do:
    if not first-good then do:
    { rep/dincol.i dil PrnLibStream top-frame}
    {&DOWN-FRAME}
    { rep/dincol.i dil PrnLibStream top-frame}
    end.
  END.
  { rep/dincol.i di 1 for-curr-obj
                 "(if temp-goods.obj-code > 0 then (temp-goods.obj-type + string(temp-goods.obj-code)) else '')" }
    if pnum-obj > 1 and temp-goods.obj-code > 0 then do:
    { rep/dincol.i di 2 for-in-code
                   "'------>'" }
    first-good = no.
  end.
  else do:
    { rep/dincol.i di 2 for-in-code
                  temp-goods.in-code }
    { rep/dincol.i di 3 for-in-date
                   temp-goods.in-date }
    { rep/dincol.i di 4 for-ini-obj
                   "(temp-goods.obj-in-type + string(temp-goods.obj-in-code))" }
    { rep/dincol.i di 5 for-terms
                   "('НДС ' + temp-goods.vat-type + {&space-char} + 'НП ' + temp-goods.slt-type)"}
    { rep/dincol.i di 6 for-part-code
                   temp-goods.part-code }
    { rep/dincol.i di 7 for-artic
                   temp-goods.artic }
    { rep/dincol.i di 8 for-gds-name
                   temp-goods.gds-name }
    { rep/dincol.i di 9 for-unit
                   temp-goods.unit }
    { rep/dincol.i di 10 for-price-cli-in-brutto
                    temp-goods.price-cli-in-brutto }
    { rep/dincol.i di 11 for-VAT-pc
                    temp-goods.vat-pc }
    { rep/dincol.i di 12 for-SLT-pc
                    temp-goods.SLT-pc }
    { rep/dincol.i di 13 for-price-cli-in
                    temp-goods.price-cli-in }
    { rep/dincol.i di 14 for-qnty-all
                    temp-goods.qnty-all }
  end.
  { rep/dincol.i di 15 for-qnty-in
                 temp-goods.qnty-in }
  { rep/dincol.i di 16 for-price-cli-in-sum
                 temp-goods.price-cli-in-sum }
  { rep/dincol.i di 17 for-qnty-out
                 "(- temp-goods.qnty-out)" }
  { rep/dincol.i di 18 for-price-cli-out-sum
                 "(- temp-goods.price-cli-out-sum)" }
  { rep/dincol.i dil PrnLibStream top-frame}
  {&DISPLAY-FRAME}

  /*вывод в EXCEL*/
  if pnum-obj > 1 and temp-goods.obj-code = 0 then do:
    if not first-good then
    {&DOWN-EXCEL}
  END.

  {&PutExcel}
  { rep/dincol.i dix 1 for-curr-obj
                 "(if temp-goods.obj-code > 0 then (temp-goods.obj-type + string(temp-goods.obj-code)) else '')" }
  .
  if pnum-obj > 1 and temp-goods.obj-code > 0 then do:
    {&PutExcel}
    { rep/dincol.i dix 2 for-in-code
                   "'------>'" }
    { rep/dincol.i dit 3 }
    { rep/dincol.i dit 4 }
    { rep/dincol.i dit 5 }
    { rep/dincol.i dit 6 }
    { rep/dincol.i dit 7 }
    { rep/dincol.i dit 8 }
    { rep/dincol.i dit 9 }
    { rep/dincol.i dit 10 }
    { rep/dincol.i dit 11 }
    { rep/dincol.i dit 12 }
    { rep/dincol.i dit 13 }
    { rep/dincol.i dit 14 }
    .
    first-good = no.
  end.
  else do:

    {&PutExcel}
    { rep/dincol.i dix 2 for-in-code
                  temp-goods.in-code }
    { rep/dincol.i dix 3 for-in-date
                   temp-goods.in-date }
    { rep/dincol.i dix 4 for-ini-obj
                   "(temp-goods.obj-in-type + string(temp-goods.obj-in-code))" }
    { rep/dincol.i dix 5 for-terms
                   "('НДС ' + temp-goods.vat-type + {&space-char} + 'НП ' + temp-goods.slt-type)"}
    { rep/dincol.i dix 6 for-part-code
                   temp-goods.part-code }
    { rep/dincol.i dix 7 for-artic
                   "(~{&delim-par~} + temp-goods.artic)" }
    { rep/dincol.i dix 8 for-gds-name
                   temp-goods.gds-name }
    { rep/dincol.i dix 9 for-unit
                   temp-goods.unit }
    { rep/dincol.i dix 10 for-price-cli-in-brutto
                    temp-goods.price-cli-in-brutto }
    { rep/dincol.i dix 11 for-VAT-pc
                    temp-goods.vat-pc }
    { rep/dincol.i dix 12 for-SLT-pc
                    temp-goods.SLT-pc }
    { rep/dincol.i dix 13 for-price-cli-in
                    temp-goods.price-cli-in }
    { rep/dincol.i dix 14 for-qnty-all
                    temp-goods.qnty-all }
    .
  end.
  {&PutExcel}
  { rep/dincol.i dix 15 for-qnty-in
                 temp-goods.qnty-in }
  { rep/dincol.i dix 16 for-price-cli-in-sum
                 temp-goods.price-cli-in-sum }
  { rep/dincol.i dix 17 for-qnty-out
                 "(- temp-goods.qnty-out)" }
  { rep/dincol.i dix 18 for-price-cli-out-sum
                 "(- temp-goods.price-cli-out-sum)" }
  SKIP.

  IF pcurr-code = ? and LAST-OF(temp-goods.exch-code) then do:
    {&UNDERLINE-FRAME}
    { rep/dincol.i dil PrnLibStream top-frame}
    { rep/dincol.i di 2 for-in-code
                   "('Итого в ' + temp-goods.curr-name)"  }
    { rep/dincol.i di 14 for-qnty-all
                    accum-qnty-all-by-exch-code }
    { rep/dincol.i di 15 for-qnty-in
                    accum-in-qnty-by-exch-code }
    { rep/dincol.i di 16 for-price-cli-in-sum
                    accum-in-by-exch-code }
    { rep/dincol.i di 17 for-qnty-out
                    "(- accum-out-qnty-by-exch-code)" }
    { rep/dincol.i di 18 for-price-cli-out-sum
                    "(- accum-out-by-exch-code)" }
    { rep/dincol.i dil PrnLibStream top-frame}
    {&DISPLAY-FRAME}
    { rep/dincol.i dil PrnLibStream top-frame}
    {&UNDERLINE-FRAME}


    {&UNDERLINE-EXCEL}
    {&PutExcel}
    { rep/dincol.i dit 1 }
    { rep/dincol.i dix 2 for-in-code
                   "('Итого в ' + temp-goods.curr-name)"  }
    { rep/dincol.i dit 3 }
    { rep/dincol.i dit 4 }
    { rep/dincol.i dit 5 }
    { rep/dincol.i dit 6 }
    { rep/dincol.i dit 7 }
    { rep/dincol.i dit 8 }
    { rep/dincol.i dit 9 }
    { rep/dincol.i dit 10 }
    { rep/dincol.i dit 11 }
    { rep/dincol.i dit 12 }
    { rep/dincol.i dit 13 }
    { rep/dincol.i dix 14 for-qnty-all
                     accum-qnty-all-by-exch-code }
    { rep/dincol.i dix 15 for-qnty-in
                     accum-in-qnty-by-exch-code }
    { rep/dincol.i dix 16 for-price-cli-in-sum
                    accum-in-by-exch-code }
    { rep/dincol.i dix 17 for-qnty-out
                    "(- accum-out-qnty-by-exch-code)" }
    { rep/dincol.i dix 18 for-price-cli-out-sum
                    "(- accum-out-by-exch-code)" }
    { rep/dincol.i dit 19 }
    SKIP.
    {&UNDERLINE-EXCEL}


  end.
  IF pcurr-code <> ? and LAST-OF(temp-goods.supp-code) then do:
    {&UNDERLINE-FRAME}
    { rep/dincol.i dil PrnLibStream top-frame}
    { rep/dincol.i di 5 for-terms
                   "'Итого по поставщику:'"  }
    { rep/dincol.i di 14 for-qnty-all
                    accum-qnty-all-by-supp-code }
    { rep/dincol.i di 15 for-qnty-in
                    accum-in-qnty-by-supp-code }
    { rep/dincol.i di 16 for-price-cli-in-sum
                    accum-in-by-supp-code }
    { rep/dincol.i di 17 for-qnty-out
                    "(- accum-out-qnty-by-supp-code)" }
    { rep/dincol.i di 18 for-price-cli-out-sum
                    "(- accum-out-by-supp-code)" }
    { rep/dincol.i dil PrnLibStream top-frame}
    {&DISPLAY-FRAME}
    { rep/dincol.i dil PrnLibStream top-frame}
    {&UNDERLINE-FRAME}

    {&UNDERLINE-EXCEL}
    {&PutExcel}
    { rep/dincol.i dit 1 }
    { rep/dincol.i dit 2 }
    { rep/dincol.i dit 3 }
    { rep/dincol.i dit 4 }
    { rep/dincol.i dix 5 for-terms
                   "'Итого по поставщику:'"  }
    { rep/dincol.i dit 6 }
    { rep/dincol.i dit 7 }
    { rep/dincol.i dit 8 }
    { rep/dincol.i dit 9 }
    { rep/dincol.i dit 10 }
    { rep/dincol.i dit 11 }
    { rep/dincol.i dit 12 }
    { rep/dincol.i dit 13 }
    { rep/dincol.i dix 14 for-qnty-all
                     accum-qnty-all-by-supp-code }
    { rep/dincol.i dix 15 for-qnty-in
                     accum-in-qnty-by-supp-code }
    { rep/dincol.i dix 16 for-price-cli-in-sum
                    accum-in-by-supp-code }
    { rep/dincol.i dix 17 for-qnty-out
                     "(- accum-out-qnty-by-supp-code)" }
    { rep/dincol.i dix 18 for-price-cli-out-sum
                    "(- accum-out-by-supp-code)" }
    { rep/dincol.i dit 19 }
    skip.
    {&UNDERLINE-EXCEL}
  end.
END.
HIDE STREAM PrnLibStream FRAME Obval .
HIDE STREAM PrnLibStream FRAME top-Frame .
HIDE stream PrnLibStream FRAME NBottomFrame .
Delete widget-pool "My-pool".
if Print-List-hist
and can-find(first cli-list) then do:
  run lhistprex-print-cli-list-hist-excel  in this-procedure (input yes, input yes, 2).
end.
output stream PrnLibStream CLOSE .
{&CloseExcel}
run waitfram-hide in this-procedure .