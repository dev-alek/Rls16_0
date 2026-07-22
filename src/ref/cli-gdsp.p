block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cli-gdsp.p $
$Archive: ref/cli-gdsp.p $

Печать справочника товаров контрагентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

define input parameter parparentproc as widget-handle no-undo .

define input parameter parlist-mode1 as character no-undo .
define input parameter parlist-mode2 as character no-undo .
define input parameter for-title as character no-undo .
define input parameter p-without-zero as logical no-undo .

define output parameter accum-in-qnty as decimal no-undo .
define output parameter accum-out-qnty as decimal no-undo .
define output parameter accum-ret-qnty  as decimal no-undo .
define output parameter accum-in-base  as decimal no-undo .
define output parameter accum-in-rubl  as decimal no-undo .
define output parameter accum-out-sum  as decimal no-undo .
define output parameter accum-ret-sum  as decimal no-undo .
define output parameter accum-out-discnt  as decimal no-undo .
define output parameter accum-ret-discnt  as decimal no-undo .
define output parameter accum-supp-qnty  as decimal no-undo .
define output parameter accum-supp-base  as decimal no-undo .
define output parameter accum-supp-rubl  as decimal no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cli-gdsp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cli-gdsp.p $":U .
define variable vss-description as character no-undo init "Печать справочника товаров контрагентов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ cmp/breakstr.i }
{ cmp/r-page1.i new }
{ gbl/prn-lib.i }
define variable g#report-num as integer no-undo .
{ rep/opclexcl.i }
{ rep/dincol.i def }
{ gbl/waitfram.i }



DEFINE SHARED BUFFER sb-cli-gds FOR ub.cli-gds.
DEFINE shared QUERY br-docs FOR sb-cli-gds SCROLLING.
define variable Line                as      char    no-undo.
DEFINE VARIABLE for-artic like ub.goods.artic no-undo .
DEFINE VARIABLE for-cli-artic like ub.goods.artic no-undo .
DEFINE VAR for-cli-name like ub.clients.obj-name no-undo.
define variable for-prod-name like ub.clients.obj-name no-undo .
define variable producer as char.
DEFINE VAR for-gds-name like ub.goods.gds-name no-undo.
DEFINE VAR for-unit-base like ub.goods.unit-base no-undo.
DEFINE VAR for-unit-cli like ub.goods.unit-cli no-undo.
define variable accum-count as integer.
define variable namebuf1     as      char    no-undo.
define variable namebuf2     as      char    no-undo.
define variable prodbuf1     as      char    no-undo.
define variable prodbuf2     as      char    no-undo.
define variable cliname1     as      char    no-undo.
define variable cliname2     as      char    no-undo.
DEFINE VARIABLE fill3 as character no-undo .
DEFINE VARIABLE fill9 as character no-undo .
DEFINE VARIABLE fill15 as character no-undo .
DEFINE VARIABLE fill16 as character no-undo .
DEFINE VARIABLE fill20 as character no-undo .
define variable p-frame-width as integer no-undo.
define variable i as integer no-undo.

&scop din-label-height 4

&SCOPED-DEFINE DISPLAY-FRAME         DISPLAY stream  PrnLibStream with frame CLi-Gds-List. ~
                                     DOWN 1 stream PrnLibStream with frame CLi-Gds-List.


/* ПОЛНЫЙ порядок полей фрейма */
/*1 - Артикул основной/!контрагента*/
/*3 - Ед.изм!осн./!контр-та*/
/*5 - Назв.товара*/
/*6 - Пр-ль*/
/*7 - назв производителя*/
/*8 - Контрагент*/
/*9 - Кол-во/приход*/
/*10 - Кол-во/расход*/
/*11 - Кол-во/возврат*/
/*12 - Учетн.цены!баз.вал./!приход*/
/*13 - Учетн.цены!{&abbr_rub}./!приход*/
/*14 - Продаж.цены!вал.продаж/!расход*/
/*15 - Продаж.цены!вал.продаж/!возврат*/
/*16 - Скидки!вал.продаж/!расход*/
/*17 - Скидки!вал.продаж/!возврат*/
/*18 - Кол-во/остатки*/
/*19 - Учетн.цены!баз.вал./!остатки*/
/*20- Учетн.цены!{&abbr_rub}./!остатки*/


/*ОСНОВНАЯ ФОРМА*/
DEFINE VARIABLE t-1 AS CHARACTER INITIAL "||||"
     VIEW-AS EDITOR
     SIZE 1 BY 5 NO-UNDO.

DEFINE FRAME top-frame
    t-1       AT ROW 1 COL 1 no-label
    HEADER
    cur-time-print() AT 5 format "x(35)"
    string( "Страница" ) AT 45 PAGE-NUMBER( PrnLibStream ) AT 55 FORMAT ">>9" SKIP
/*    Line format "X(177)" AT 1*/
    with width {&DOS_CW_2} down stream-io use-text NO-BOX.

 DEFINE FRAME CLi-Gds-List
   with width {&DOS_CW_2} down stream-io use-text NO-BOX.

assign
use-column[1] = if parlist-mode1 <> {&goods-cmp} then yes else no
use-column[2] = if parlist-mode1 <> {&goods-cmp} then yes else no
use-column[3] = if parlist-mode1 <> {&goods-cmp} then yes else no
use-column[4] = if parlist-mode1 <> {&goods-cmp} then yes else no
use-column[5] = if parlist-mode1 <> {&goods-cmp} then yes else no

use-column[6] = if parlist-mode1 = {&client-cmp} then yes else no
use-column[7] = if parlist-mode1 = {&client-cmp} then yes else no

use-column[8] = if parlist-mode1 <> {&client-cmp} then yes else no

use-column[9] = if parlist-mode2 = {&balance-cmp} then yes else no
use-column[10] = if parlist-mode2 = {&balance-cmp} then yes else no
use-column[11] = if parlist-mode2 = {&balance-cmp} then yes else no
use-column[12] = if parlist-mode2 = {&balance-cmp} then yes else no
use-column[13] = if parlist-mode2 = {&balance-cmp} then yes else no
use-column[14] = if parlist-mode2 = {&balance-cmp} then yes else no
use-column[15] = if parlist-mode2 = {&balance-cmp} then yes else no
use-column[16] = if parlist-mode2 = {&balance-cmp} then yes else no
use-column[17] = if parlist-mode2 = {&balance-cmp} then yes else no

use-column[18] = if parlist-mode2 = {&stock-cmp} then yes else no
use-column[19] = if parlist-mode2 = {&stock-cmp} then yes else no
use-column[20] = if parlist-mode2 = {&stock-cmp} then yes else no
.
run get-report-num  in parparentproc (output g#report-num).
assign
fill3 = fill("-", 3)
fill9 = fill("-", 9)
fill15 = fill("-", 15)
fill16 = fill("-", 16)
fill20 = fill("-", 20)
.

assign
sheetf.Excel-Column-Lable =  ""
sheetf.sizes = ""
Make-Excel = yes
.

CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .

l-col-pos = 1.
Assign l-col-type="CHARACTER" l-col-len=16 l-col-format= "X(16)"     l-col-lable="Артикул основн./ контрагента".
  { rep/dincol.i cr  1    for-artic      CLi-Gds-List                 }
  l-col-lable="Артикул основной".
  { rep/dincol.i crx 1  }

/*эта колонка должна печататься только в EXCEL!*/
Assign l-col-type="CHARACTER" l-col-len=16 l-col-format= "X(16)"     l-col-lable="Артикул основн./ контр.".
  { rep/dincol.i cr  2    for-cli-artic      CLi-Gds-List                 }
  assign
  l-col-lable="Артикул контрагента"
  .
  if use-column[2] then
  assign
  l-col-pos =  l-col-pos - l-col-len - 1.
  { rep/dincol.i crx 2  }


Assign l-col-type="CHARACTER" l-col-len=7  l-col-format= "X(3)"      l-col-lable="Ед.изм./контр .".
  { rep/dincol.i cr  3    for-unit-base  CLi-Gds-List                 }
  assign
  l-col-lable = "Ед.изм"
  .
  { rep/dincol.i crx 3  }

/*эта колонка должна печататься только в EXCEL!*/
Assign l-col-type="CHARACTER" l-col-len=7  l-col-format= "X(3)"      l-col-lable="Ед.изм./контр .".
  { rep/dincol.i cr  4    for-unit-cli  CLi-Gds-List                 }
  if use-column[4] then
  assign
  l-col-pos =  l-col-pos - l-col-len - 1
  .
  assign
  l-col-lable = "Ед.изм /контр."
  .
  { rep/dincol.i crx 4  }



Assign l-col-type="CHARACTER" l-col-len=20 l-col-format= "X(20)"      l-col-lable="        Название товара".
  { rep/dincol.i cr  5    for-gds-name  CLi-Gds-List                 }
  assign
  l-col-len=40 l-col-format= "X(40)"
  .
  { rep/dincol.i crx 5  }

Assign l-col-type="CHARACTER" l-col-len=9  l-col-format= "X(9)"      l-col-lable="Пр-ль".
  { rep/dincol.i cr  6    producer  CLi-Gds-List                 }
  { rep/dincol.i crx 6  }
Assign l-col-type="CHARACTER" l-col-len=20  l-col-format= "X(20)"      l-col-lable="Название пр-ля".
  { rep/dincol.i cr  7    for-prod-name  CLi-Gds-List                 }
  assign
  l-col-len=40  l-col-format= "X(40)"
  .
  { rep/dincol.i crx 7  }
Assign l-col-type="CHARACTER" l-col-len=20  l-col-format= "X(20)"      l-col-lable="Контрагент".

  { rep/dincol.i cr  8    for-cli-name  CLi-Gds-List                 }
  { rep/dincol.i crx 8  }
Assign l-col-type="DECIMAL" l-col-len=15    l-col-format= "->>,>>>,>>9.<<<"      l-col-lable="Кол-во/приход".
  { rep/dincol.i cr  9    for-in-qnty  CLi-Gds-List                 }
  { rep/dincol.i crx 9 }
Assign l-col-type="DECIMAL" l-col-len=15    l-col-format= "->>,>>>,>>9.<<<"      l-col-lable="Кол-во/расход".
  { rep/dincol.i cr  10    for-out-qnty  CLi-Gds-List                 }
  { rep/dincol.i crx 10 }
Assign l-col-type="DECIMAL" l-col-len=15    l-col-format= "->>,>>>,>>9.<<<"      l-col-lable="Кол-во/возврат".
  { rep/dincol.i cr  11    for-ret-qnty  CLi-Gds-List                 }
  { rep/dincol.i crx 11 }
Assign l-col-type="DECIMAL" l-col-len=15    l-col-format= "->>>,>>>,>>9.99"      l-col-lable="Учетн.цены баз.вал./приход".
  { rep/dincol.i cr  12    for-in-base  CLi-Gds-List                 }
  { rep/dincol.i crx 12 }
Assign l-col-type="DECIMAL" l-col-len=15    l-col-format= "->>>,>>>,>>9.99"      l-col-lable="Учетн.цены {&abbr_rub}./приход".
  { rep/dincol.i cr  13    for-in-rubl  CLi-Gds-List                 }
  { rep/dincol.i crx 13 }
Assign l-col-type="DECIMAL" l-col-len=15    l-col-format= "->>>,>>>,>>9.99"      l-col-lable="Продаж.цены вал.продаж/ расход".
  { rep/dincol.i cr  14    for-out-sum  CLi-Gds-List                 }
  { rep/dincol.i crx 14 }
Assign l-col-type="DECIMAL" l-col-len=15    l-col-format= "->>>,>>>,>>9.99"      l-col-lable="Продаж.цены вал.продаж/ возврат".
  { rep/dincol.i cr  15    for-ret-sum  CLi-Gds-List                 }
  { rep/dincol.i crx 15 }
Assign l-col-type="DECIMAL" l-col-len=15    l-col-format= "->>>,>>>,>>9.99"      l-col-lable="Скидки вал.продаж/ расход".
  { rep/dincol.i cr  16    for-out-discnt  CLi-Gds-List                 }
  { rep/dincol.i crx 16 }
Assign l-col-type="DECIMAL" l-col-len=15    l-col-format= "->>>,>>>,>>9.99"      l-col-lable="Скидки вал.продаж/ возврат".
  { rep/dincol.i cr  17    for-ret-discnt  CLi-Gds-List                 }
  { rep/dincol.i crx 17 }
Assign l-col-type="DECIMAL" l-col-len=15    l-col-format= "->>>,>>>,>>9.99"      l-col-lable="Кол-во/остатки".
  { rep/dincol.i cr  18    for-supp-qnty  CLi-Gds-List                 }
  { rep/dincol.i crx 18 }
Assign l-col-type="DECIMAL" l-col-len=15    l-col-format= "->>>,>>>,>>9.99"      l-col-lable="Учетн.цены баз.вал./ остатки".
  { rep/dincol.i cr  19    for-supp-base  CLi-Gds-List                 }
  { rep/dincol.i crx 19 }
Assign l-col-type="DECIMAL" l-col-len=15    l-col-format= "->>>,>>>,>>9.99"      l-col-lable="Учетн.цены {&abbr_rub}./ остатки".
  { rep/dincol.i cr  20    for-supp-rubl  CLi-Gds-List                 }
  { rep/dincol.i crx 20 }

Line = fill("-", 177).

p-frame-width = l-col-pos - 1.

if num-entries (sheetf.colformat, {&delim-par}) > 1 then  do:
  assign
  entry(2, sheetf.colformat, {&delim-par}) =  entry(2, sheetf.colformat, {&delim-par}) +
                                             (if entry(2, sheetf.colformat, {&delim-par}) = "":U then "":U else ";") +
                                             "1=@;2=@":U
  .
end.
else  do:
  assign
  sheetf.colformat = sheetf.colformat + {&delim-par} + "1=@;2=@":U
  .
end.

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


RUN OpenForExcel in this-procedure .

run waitfram-show in this-procedure ("ЖДИТЕ...").

FORM with FRAME CLi-Gds-List .

FORM HEADER
Line format "X(177)" AT 1 SKIP
"Продолжение на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .

VIEW  STREAM PrnLibStream FRAME BottomFrame .

PUT  STREAM PrnLibStream UNFORMATTED
SPACE(25) ( for-title )
format "x(90)" SKIP(1) .
display STREAM PrnLibStream with frame top-Frame .
assign
reportname = for-title
.
run rep/extitle.p (1).

GET next br-docs.
_sb:
DO WHILE available sb-cli-gds :
  if not p-without-zero
  or sb-cli-gds.supp-qnty <> 0 then do:
  assign
  accum-count = accum-count + 1
  .
  if parlist-mode2 = {&balance-cmp} then do:
    assign
    accum-in-qnty = accum-in-qnty + sb-cli-gds.in-qnty
    accum-out-qnty = accum-out-qnty + sb-cli-gds.out-qnty
    accum-ret-qnty = accum-ret-qnty + sb-cli-gds.ret-qnty
    accum-in-base = accum-in-base + sb-cli-gds.in-base
    accum-in-rubl = accum-in-rubl + sb-cli-gds.in-rubl
    accum-out-sum = accum-out-sum + sb-cli-gds.out-sum
    accum-ret-sum = accum-ret-sum + sb-cli-gds.ret-sum
    accum-out-discnt = accum-out-discnt + sb-cli-gds.out-discnt
    accum-ret-discnt = accum-ret-discnt + sb-cli-gds.ret-discnt
    .
  end.
  if parlist-mode2 = {&stock-cmp} then do:
    assign
    accum-supp-qnty = accum-supp-qnty + sb-cli-gds.supp-qnty
    accum-supp-base = accum-supp-base + sb-cli-gds.supp-base
    accum-supp-rubl = accum-supp-rubl + sb-cli-gds.supp-rubl
    .
  end.
  if not parlist-mode1 = {&goods-cmp} then do:
    FIND FIRST ub.goods No-LOCK WHERE
              ub.goods.prod-type = sb-cli-gds.prod-type AND
              ub.goods.prod-code = sb-cli-gds.prod-code AND
              ub.goods.artic = sb-cli-gds.artic
    NO-ERROR.
    IF AVAIL ub.goods then
    assign
    for-gds-name = ub.goods.gds-name
    for-unit-base = ub.goods.unit-base.
    else
    assign
    for-gds-name = ""
    for-unit-base = "".
    namebuf1 = breakstr(for-gds-name, 18, input-output namebuf1, input-output namebuf2).
  end.
  if parlist-mode1 = {&client-cmp} then do:
    FIND FIRST ub.clients NO-LOCK WHERE
               ub.clients.obj-type = sb-cli-gds.prod-type AND
              ub.clients.obj-code = sb-cli-gds.prod-code
    No-ERROR.
    if avail ub.clients then do:
      assign
      for-prod-name = ub.clients.obj-name
      prodbuf1 = breakstr(ub.clients.obj-name, 15, input-output prodbuf1, input-output prodbuf2).
    end.
    else do:
      assign
      for-prod-name = "":U
      prodbuf1 = ""
      prodbuf2 = "".
    end.
  end.
  if not parlist-mode1 = {&client-cmp} then do:
    FIND FIRST ub.clients NO-LOCK WHERE
               ub.clients.obj-type = sb-cli-gds.cli-type AND
              ub.clients.obj-code = sb-cli-gds.cli-code
    No-ERROR.
    if avail ub.clients then do:
      assign
      for-cli-name = ub.clients.obj-name
      cliname1 = breakstr(ub.clients.obj-name, 15, input-output cliname1, input-output cliname2).
    end.
    else do:
      assign
      for-cli-name = "":U
      cliname1 = ""
      cliname2 = "".
    end.
  end.
  producer = ub.clients.obj-type + ' ' + string(ub.clients.obj-code).
  { rep/dincol.i di 1 for-artic
                  sb-cli-gds.artic }
  { rep/dincol.i di 3 for-unit-base
                 for-unit-base }
  { rep/dincol.i di 5 for-gds-name
                  namebuf1 }
  { rep/dincol.i di 6 producer
                 producer }
  { rep/dincol.i di 7 for-prod-name
                  prodbuf1      }
  { rep/dincol.i di 8 for-cli-name
                  cliname1    }
  { rep/dincol.i di 9 for-in-qnty
                  sb-cli-gds.in-qnty  }
  { rep/dincol.i di 10 for-out-qnty
                  sb-cli-gds.out-qnty  }
  { rep/dincol.i di 11 for-ret-qnty
                  sb-cli-gds.ret-qnty  }
  { rep/dincol.i di 12 for-in-base
                  sb-cli-gds.in-base  }
  { rep/dincol.i di 13 for-in-rubl
                  sb-cli-gds.in-rubl  }
  { rep/dincol.i di 14 for-out-sum
                  sb-cli-gds.out-sum  }
  { rep/dincol.i di 15 for-ret-sum
                  sb-cli-gds.ret-sum  }
  { rep/dincol.i di 16 for-out-discnt
                  sb-cli-gds.out-discnt  }
  { rep/dincol.i di 17 for-ret-discnt
                  sb-cli-gds.ret-discnt  }
  { rep/dincol.i di 18 for-supp-qnty
                  sb-cli-gds.supp-qnty  }
  { rep/dincol.i di 19 for-supp-base
                  sb-cli-gds.supp-base  }
  { rep/dincol.i di 20 for-supp-rubl
                  sb-cli-gds.supp-rubl  }

  {&DISPLAY-FRAME}

/*вторая строчка*/

  { rep/dincol.i di 1 for-artic
                  sb-cli-gds.cli-art }
  { rep/dincol.i di 3 for-unit-base
                  sb-cli-gds.unit-cli }
  { rep/dincol.i di 5 for-gds-name
                  namebuf2 }
  { rep/dincol.i di 7 for-prod-name
                  prodbuf2     }
  { rep/dincol.i di 8 for-cli-name
                  cliname2    }

  {&DISPLAY-FRAME}

    {&PutExcel}
    { rep/dincol.i dix 1 for-artic
                    "{&delim-par} + sb-cli-gds.artic" }

    { rep/dincol.i dix 2 for-cli-artic
                    "{&delim-par} + sb-cli-gds.cli-art" }
    { rep/dincol.i dix 3 for-unit-base
                  for-unit-base }
    { rep/dincol.i dix 4 for-unit-cli
                  sb-cli-gds.unit-cli }
    { rep/dincol.i dix 5 for-gds-name
                    for-gds-name }
    { rep/dincol.i dix 6 producer
                  producer }
    { rep/dincol.i dix 7 for-prod-name
                    for-prod-name      }

    { rep/dincol.i dix 8 for-cli-name
                    for-cli-name    }
    { rep/dincol.i dix 9 for-in-qnty
                    sb-cli-gds.in-qnty  }
    { rep/dincol.i dix 10 for-out-qnty
                    sb-cli-gds.out-qnty  }
    { rep/dincol.i dix 11 for-ret-qnty
                    sb-cli-gds.ret-qnty  }
    { rep/dincol.i dix 12 for-in-base
                    sb-cli-gds.in-base  }
    { rep/dincol.i dix 13 for-in-rubl
                    sb-cli-gds.in-rubl  }
    { rep/dincol.i dix 14 for-out-sum
                    sb-cli-gds.out-sum  }
    { rep/dincol.i dix 15 for-ret-sum
                    sb-cli-gds.ret-sum  }
    { rep/dincol.i dix 16 for-out-discnt
                    sb-cli-gds.out-discnt  }
    .

    /*разрыв1 иначе не компилит превышение -tok*/

    {&PutExcel}
    { rep/dincol.i dix 17 for-ret-discnt
                    sb-cli-gds.ret-discnt  }
    { rep/dincol.i dix 18 for-supp-qnty
                    sb-cli-gds.supp-qnty  }
    { rep/dincol.i dix 19 for-supp-base
                    sb-cli-gds.supp-base  }
    { rep/dincol.i dix 20 for-supp-rubl
                    sb-cli-gds.supp-rubl  }
    skip.
   end.
  GET next br-docs.
END.


run UNDERLINE-FRAME in this-procedure .
run underline-excel in this-procedure .

/*Покажем ИТОГИ*/
assign
for-gds-name = 'записей' + {&space-char} + string(accum-count)
for-artic = 'ИТОГО -'
.

{ rep/dincol.i di 1 for-artic
               for-artic }
{ rep/dincol.i di 3 for-gds-name
               for-gds-name   }
{ rep/dincol.i di 4 for-unit-base
                '_' }
{ rep/dincol.i di 6 producer
                '_' }
{ rep/dincol.i di 7 for-prod-name
                '_'    }
{ rep/dincol.i di 8 for-cli-name
                '_'    }
{ rep/dincol.i di 9 for-in-qnty
                accum-in-qnty  }
{ rep/dincol.i di 10 for-out-qnty
                accum-out-qnty  }
{ rep/dincol.i di 11 for-ret-qnty
                accum-ret-qnty  }
{ rep/dincol.i di 12 for-in-base
                accum-in-base  }
{ rep/dincol.i di 13 for-in-rubl
                accum-in-rubl  }
{ rep/dincol.i di 14 for-out-sum
                accum-out-sum  }
{ rep/dincol.i di 15 for-ret-sum
                accum-ret-sum  }
{ rep/dincol.i di 16 for-out-discnt
                accum-out-discnt  }
{ rep/dincol.i di 17 for-ret-discnt
                accum-ret-discnt  }
{ rep/dincol.i di 18 for-supp-qnty
                accum-supp-qnty  }
{ rep/dincol.i di 19 for-supp-base
                accum-supp-base  }
{ rep/dincol.i di 20 for-supp-rubl
                accum-supp-rubl  }

{&DISPLAY-FRAME}


{&PutExcel}
{ rep/dincol.i dix 1 for-artic
               for-artic }
{ rep/dincol.i dix 2 for-cli-artic
               for-cli-artic }
{ rep/dincol.i dix 3 for-unit-base
                '_' }
{ rep/dincol.i dix 4 for-unit-cli
                '_' }
{ rep/dincol.i dix 5 for-gds-name
               for-gds-name   }
{ rep/dincol.i dix 6 producer
                '_' }
{ rep/dincol.i dix 7 for-prod-name
                '_'    }
{ rep/dincol.i dix 8 for-cli-name
                '_'    }
.
/*разрыв2   иначе не компилит превышение -tok*/
{&PutExcel}
{ rep/dincol.i dix 9 for-in-qnty
                accum-in-qnty  }
{ rep/dincol.i dix 10 for-out-qnty
                accum-out-qnty  }
{ rep/dincol.i dix 11 for-ret-qnty
                accum-ret-qnty  }
{ rep/dincol.i dix 12 for-in-base
                accum-in-base  }
{ rep/dincol.i dix 13 for-in-rubl
                accum-in-rubl  }
{ rep/dincol.i dix 14 for-out-sum
                accum-out-sum  }
{ rep/dincol.i dix 15 for-ret-sum
                accum-ret-sum  }
{ rep/dincol.i dix 16 for-out-discnt
                accum-out-discnt  }
{ rep/dincol.i dix 17 for-ret-discnt
                accum-ret-discnt  }
{ rep/dincol.i dix 18 for-supp-qnty
                accum-supp-qnty  }
{ rep/dincol.i dix 19 for-supp-base
                accum-supp-base  }
{ rep/dincol.i dix 20 for-supp-rubl
                accum-supp-rubl  }
skip.





HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME Cli-Gds-List.
output  STREAM PrnLibStream CLOSE.
{&CloseExcel}
run waitfram-hide in this-procedure .
if p-frame-width <= {&A4_CW0} then do:
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 0
                                            ).
end.
else do:
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 8
                                            ).
end.

procedure underline-frame :

  do
  on error undo, return error
  :
    { rep/dincol.i un 1 for-artic fill16 }
    { rep/dincol.i un 3 for-gds-name fill20 }
    { rep/dincol.i un 4 for-unit-base fill3 }
    { rep/dincol.i un 6 producer fill9 }
    { rep/dincol.i un 7 for-prod-name fill20 }
    { rep/dincol.i un 8 for-cli-name fill20 }
    { rep/dincol.i un 9 for-in-qnty fill15 }
    { rep/dincol.i un 10 for-out-qnty fill15 }
    { rep/dincol.i un 11 for-ret-qnty fill15 }
    { rep/dincol.i un 12 for-in-base fill15 }
    { rep/dincol.i un 13 for-in-rubl fill15 }
    { rep/dincol.i un 14 for-out-sum fill15 }
    { rep/dincol.i un 15 for-ret-sum fill15 }
    { rep/dincol.i un 16 for-out-discnt fill15 }
    { rep/dincol.i un 17 for-ret-discnt fill15 }
    { rep/dincol.i un 18 for-supp-qnty fill15 }
    { rep/dincol.i un 19 for-supp-base fill15 }
    { rep/dincol.i un 20 for-supp-rubl fill15 }
      DISPLAY stream  PrnLibStream with frame CLi-GDS-LIST.
      DOWN 1 stream PrnLibStream with frame CLI-GDS-LIST.


  end.

end procedure. /* underline-frame */


procedure underline-excel :

  do
  on error undo, return error
  :
    {&PutExcel}
    { rep/dincol.i unx 1 for-artic fill16 }
    { rep/dincol.i unx 2 for-cli-artic fill16 }
    { rep/dincol.i unx 3 for-gds-name fill20 }
    { rep/dincol.i unx 4 for-unit-base fill3 }
    { rep/dincol.i unx 5 for-unit-cli fill3 }
    { rep/dincol.i unx 6 producer fill9 }
    { rep/dincol.i unx 7 for-prod-name fill20 }
    { rep/dincol.i unx 8 for-cli-name fill20 }
    { rep/dincol.i unx 9 for-in-qnty fill15 }
    { rep/dincol.i unx 10 for-out-qnty fill15 }
    { rep/dincol.i unx 11 for-ret-qnty fill15 }
    { rep/dincol.i unx 12 for-in-base fill15 }
    { rep/dincol.i unx 13 for-in-rubl fill15 }
    { rep/dincol.i unx 14 for-out-sum fill15 }
    { rep/dincol.i unx 15 for-ret-sum fill15 }
    { rep/dincol.i unx 16 for-out-discnt fill15 }
    { rep/dincol.i unx 17 for-ret-discnt fill15 }
    { rep/dincol.i unx 18 for-supp-qnty fill15 }
    { rep/dincol.i unx 19 for-supp-base fill15 }
    { rep/dincol.i unx 20 for-supp-rubl fill15 }
    skip.

  end.

end procedure. /* underline-excel */