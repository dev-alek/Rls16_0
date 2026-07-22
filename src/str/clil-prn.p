block-level on error undo, throw.
/*

$Revision: 9263cff4388a, 1753, rls $
$Author: SMMolotkov $
$Date: Thu Feb 07 16:50:10 2019 +0300 $
$Workfile: clil-prn.p $
$Archive: str/clil-prn.p $

Экспорт списка клиентов в формате EXCEL

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/24/05
Author: Bakhtadze Natalya
Creation date: 12/24/05

*/

define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER pReportOption as character no-undo.
/*
"" - простой список тип код им
"" -другие опции в будущем

*/
define output parameter p-frame-width as integer no-undo.

define variable vss-revision    as character no-undo init "$Revision: 9263cff4388a, 1753, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Feb 07 16:50:10 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: clil-prn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/clil-prn.p $":U .
define variable vss-description as character no-undo init "Экспорт списка клиентов в формате EXCEL".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i  }
{ gbl/prn-lib.i }
{ cmp/cli-list.i cli-list def shared }
{ rep/dincol.i def }
{ gbl/waitfram.i }
{ gbl/gbclcode.i }

define variable g#report-num as integer no-undo .
if not valid-handle(my-handle) then do:
  assign
  my-handle = parparentproc.
end.
run get-report-num in parparentproc ( output g#report-num).

{ rep/opclexcl.i }


&SCOPED-DEFINE UNDERLINE-FRAME ~{ rep/dincol.i un 1 FOR-OBJ-type fill3 ~} ~
      ~{ rep/dincol.i un 2 for-obj-CODE fill9~} ~
      ~{ rep/dincol.i un 3 for-obj-name fill40~} ~
      ~{ rep/dincol.i un 4 for-grp-name fill80~} ~
      ~{ rep/dincol.i un 5 for-db-num fill6~} ~
      ~{ rep/dincol.i un 6 for-stts fill9~} ~
      ~{ rep/dincol.i un 7 for-is-prod fill9~} ~
      ~{ rep/dincol.i un 8 for-sup-gds fill9~} ~
      ~{ rep/dincol.i un 9 for-sup-cons fill9~} ~
      ~{ rep/dincol.i un 10 for-buy-gds fill9~} ~
      ~{ rep/dincol.i un 11 for-buy-cons fill9~} ~
      ~{ rep/dincol.i un 12 for-buy-serv fill9~} ~
      ~{ rep/dincol.i un 13 for-cashier  fill5~} ~
      ~{ rep/dincol.i un 14 for-seller fill5~} ~
      ~{ rep/dincol.i un 15 for-dis-card fill16~} ~
      ~{ rep/dincol.i un 16 for-PS fill80~} ~
      DISPLAY stream  PRnLibStream with frame cli. ~
      DOWN 1 stream PRnLibStream with frame cli.

&SCOPED-DEFINE UNDERLINE-Excel ~{&PutExcel} ~
      ~{ rep/dincol.i unx 1 for-obj-type fill3~} ~
      ~{ rep/dincol.i unx 2 for-obj-code fill9~} ~
      ~{ rep/dincol.i unx 3 for-obj-name fill40~} ~
      ~{ rep/dincol.i unx 4 for-grp-name fill80~} ~
      ~{ rep/dincol.i unx 5 for-db-num fill6~} ~
      ~{ rep/dincol.i unx 6 for-stts fill9~} ~
      ~{ rep/dincol.i unx 7 for-is-prod fill9~} ~
      ~{ rep/dincol.i unx 8 for-sup-gds fill9~} ~
      ~{ rep/dincol.i unx 9 for-sup-cons fill9~} ~
      ~{ rep/dincol.i unx 10 for-buy-gds fill9~} ~
      ~{ rep/dincol.i unx 11 for-buy-cons fill9~} ~
      ~{ rep/dincol.i unx 12 for-buy-serv fill9~} ~
      ~{ rep/dincol.i unx 13 for-cashier  fill5~} ~
      ~{ rep/dincol.i unx 14 for-seller fill5~} ~
      ~{ rep/dincol.i unx 15 for-dis-card fill16~} ~
      ~{ rep/dincol.i unx 16 for-PS fill80~}



&SCOPED-DEFINE DISPLAY-FRAME         DISPLAY stream  PRnLibStream with frame cli. ~
                                     DOWN 1 stream PRnLibStream with frame cli.

&SCOPED-DEFINE DOWN-FRAME            DOWN 1 stream PRnLibStream with frame cli.

&SCOPED-DEFINE DOWN-EXCEL            ~{&PutExcel} skip.

DEFINE VARIABLE LINE as character no-undo.
DEFINE VARIABLE FOR-OBJ-type like ub.clients.obj-type NO-UNDO.
DEFINE VARIABLE FOR-OBJ-code like ub.clients.obj-code NO-UNDO.
DEFINE VARIABLE FOR-OBJ-name like ub.clients.obj-name NO-UNDO.
DEFINE VARIABLE FOR-grp-name like ub.clients.grp-name NO-UNDO.
DEFINE VARIABLE FOR-db-num   as character no-undo .
DEFINE VARIABLE FOR-stts as character NO-UNDO.
DEFINE VARIABLE FOR-is-prod like ub.clients.is-prod NO-UNDO.
DEFINE VARIABLE FOR-sup-gds like ub.clients.sup-gds NO-UNDO.
DEFINE VARIABLE FOR-sup-cons like ub.clients.sup-cons NO-UNDO.
DEFINE VARIABLE FOR-sup-serv like ub.clients.sup-serv NO-UNDO.
DEFINE VARIABLE FOR-buy-gds like ub.clients.buy-gds NO-UNDO.
DEFINE VARIABLE FOR-buy-cons like ub.clients.buy-cons NO-UNDO.
DEFINE VARIABLE FOR-buy-serv like ub.clients.buy-serv NO-UNDO.
DEFINE VARIABLE for-cashier like ub.staff.staff-code no-undo.
DEFINE VARIABLE for-seller like ub.staff.staff-code no-undo.
DEFINE VARIABLE for-dis-card like ub.dis-card.d-card no-undo.
DEFINE VARIABLE FOR-PS like ub.clients.PS NO-UNDO.
DEFINE VARIABLE fill3 as character no-undo.
DEFINE VARIABLE fill5 as character no-undo.
DEFINE VARIABLE fill6 as character no-undo.
DEFINE VARIABLE fill9 as character no-undo.
DEFINE VARIABLE fill16 as character no-undo.
DEFINE VARIABLE fill40 as character no-undo.
DEFINE VARIABLE fill80 as character no-undo.
DEFINE VARIABLE accum-count as integer no-undo.
DEFINE VARIABLE ii as integer no-undo.
DEFINE VARIABLE v-codes as character no-undo .
DEFINE VARIABLE v-labels as character no-undo .
DEFINE VARIABLE v-options as character no-undo .
define variable v-today as date no-undo .

DEFINE VARIABLE t-1 AS CHARACTER INITIAL "||||"
     VIEW-AS EDITOR
     SIZE 1 BY 4 NO-UNDO.


DEFINE FRAME top-frame
    t-1       AT ROW 1 COL 1 no-label
    HEADER
    cur-time-print() AT 5 format "X(35)"
    string( "Страница" ) AT 45 PAGE-NUMBER( PRnLibStream ) AT 55 FORMAT ">>9" SKIP
    with width {&DOS_CW_2} down stream-io use-text NO-BOX.

 DEFINE FRAME Cli
   with width {&DOS_CW_2} down stream-io use-text NO-BOX.

v-today = today .
CASE pReportOption:
  when "excel":U then do:
    /*устанока параметра в Excel*/
    Make-excel = yes.
  end.
  when "main":U then do:
    /*внешняя печать простого списка*/
    do ii = 4 to 17:
      use-column[ii] = no.
    end.
  end.
  when "extended":U then do:
    /*вызов конфигуратора полей*/
    assign
    Make-excel = yes
    v-codes =  "grp-name,db-num,stts,is-prod,sup-gds,sup-cons,buy-gds,buy-cons,buy-serv,cashier,seller,is-d-card,PS":U
    v-labels = "Группа клиентов" + {&comma-char} +
               "Номер БД" + {&comma-char} +
               "Статус" + {&comma-char} +
               "Производитель" + {&comma-char} +
               "Поставщик товаров" + {&comma-char} +
               "Консигнант" + {&comma-char} +
               "Покупатель товаров" + {&comma-char} +
               "Покупатель консигнационных товаров" + {&comma-char} +
               "Покупатель услуг" + {&comma-char} +
               "Код кассира" + {&comma-char} +
               "Код продавца" + {&comma-char} +
               "N дисконтной карты" + {&comma-char} +
               "Примечание"
    .
    run gbl/d-list.w (
                 input "b-sel,b-mark":U
                ,input "Выберите дополнительные поля для печати"
                ,input v-codes
                ,input v-labels
                ,input {&comma-char}
                ,input "":U
                ,output v-options).
    do ii = 1 to num-entries(v-codes):
      use-column[ii + 3] = lookup(entry(ii, v-codes), v-options) > 0.
    end.
  end.
end.


assign
use-column[1] = yes
use-column[2] = yes
use-column[3] = yes
fill3 = fill("-", 3)
fill5 = fill("-", 5)
fill6 = fill("-", 6)
fill9 = fill("-", 9)
fill16 = fill("-", 16)
fill40 = fill("-", 40)
fill80 = fill("-", 80)
.

FOR EACH sheetf where sheetf.sheet-num > 1:
  delete sheetf.
end.

FIND FIRST sheetf where
           sheetf.sheet-num = 1 No-ERROR.
assign
ReportName = "Список клиентов"
sheetf.Excel-Column-Lable =  ""
sheetf.sizes = "".

CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .

l-col-pos = 1.
Assign l-col-type="CHARACTER" l-col-len=3 l-col-format= "X(3)"     l-col-lable="Тип".
  { rep/dincol.i cr  1    for-obj-type  CLi                 }
  { rep/dincol.i crx 1 }
Assign l-col-type="CHARACTER" l-col-len=9 l-col-format= "999999999"       l-col-lable="Код".
  { rep/dincol.i cr  2    for-obj-code       CLi                 }
  { rep/dincol.i crx 2 }
Assign l-col-type="CHARACTER"   l-col-len=40  l-col-format= "X(40)"  l-col-lable="Название".
  { rep/dincol.i cr  3    for-obj-name    Cli        }
  { rep/dincol.i crx 3 }
Assign l-col-type="CHARACTER"   l-col-len=80  l-col-format= "X(80)"  l-col-lable="Группа клиентов".
  { rep/dincol.i cr  4    for-grp-name    Cli        }
  { rep/dincol.i crx 4 }
Assign l-col-type="CHARACTER"   l-col-len=6  l-col-format= "X(2)"  l-col-lable="Номер БД".
  { rep/dincol.i cr  5    for-db-num    Cli        }
  { rep/dincol.i crx 5 }
Assign l-col-type="CHARACTER"   l-col-len=9  l-col-format= "X(9)"  l-col-lable="Статус".
  { rep/dincol.i cr  6    for-stts    Cli        }
  { rep/dincol.i crx 6 }
Assign l-col-type="LOGICAL"   l-col-len=9  l-col-format= "+/"  l-col-lable="Произ-ль".
  { rep/dincol.i cr  7    for-is-prod   Cli        }
  { rep/dincol.i crx 7 }
Assign l-col-type="LOGICAL"   l-col-len=6  l-col-format= "+/"  l-col-lable="Пост-к товара".
  { rep/dincol.i cr  8    for-sup-gds    Cli        }
  { rep/dincol.i crx 8 }
Assign l-col-type="LOGICAL"   l-col-len=6  l-col-format= "+/"  l-col-lable="Конси-гнант".
  { rep/dincol.i cr  9    for-sup-cons    Cli        }
  { rep/dincol.i crx 9 }
Assign l-col-type="LOGICAL"   l-col-len=6  l-col-format= "+/"  l-col-lable="Покуп.товара".
  { rep/dincol.i cr  10    for-buy-gds    Cli        }
  { rep/dincol.i crx 10 }
Assign l-col-type="LOGICAL"   l-col-len=6  l-col-format= "+/"  l-col-lable="Покуп.консиг. товара".
  { rep/dincol.i cr  11    for-buy-cons    Cli        }
  { rep/dincol.i crx 11 }
Assign l-col-type="LOGICAL"   l-col-len=6  l-col-format= "+/"  l-col-lable="Покуп. услуг".
  { rep/dincol.i cr  12    for-buy-serv    Cli        }
  { rep/dincol.i crx 12 }
Assign l-col-type="INTEGER"   l-col-len=6  l-col-format= ">>>>>9"  l-col-lable="Код кассира".
  { rep/dincol.i cr  13    for-cashier    Cli        }
  { rep/dincol.i crx 13 }
Assign l-col-type="INTEGER"   l-col-len=6  l-col-format= ">>>>>9"  l-col-lable="Код прод-ца".
  { rep/dincol.i cr  14    for-seller     Cli        }
  { rep/dincol.i crx 14 }
Assign l-col-type="CHARACTER"   l-col-len=19  l-col-format= "X(19)"  l-col-lable="Номер дис.карты".
  { rep/dincol.i cr  15    for-dis-card     Cli        }
  { rep/dincol.i crx 15 }
Assign l-col-type="CHARACTER"   l-col-len=80  l-col-format= "X(80)"  l-col-lable="Примечание".
  { rep/dincol.i cr  16    for-PS     Cli        }
  { rep/dincol.i crx 16 }

Line = fill( "-" , 60 ) .

p-frame-width = l-col-pos - 1.

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

if p-frame-width > 232 then
Make-Excel = yes.
if Make-Excel then
RUN OpenForExcel in this-procedure .

FORM with FRAME Cli .
FORM HEADER
Line format "X(60)" AT 1 SKIP
string( "Продолжение - на следующей странице" ) FORMAT "X(40)" AT 10 SKIP
with FRAME NBottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW stream PRnLibStream FRAME NBottomFrame .
PUT stream PRnLibStream UNFORMATTED
SPACE(10)
Reportname {&new-line}
SKIP(1).


display STREAM PRnLibStream with frame top-Frame .

run rep/extitle.p ( input 1).
run waitfram-show in this-procedure ( input "Ждите...").
{ str/clil-prn.i cli-list }

{&pageExcel}

FInd first Sheetf where
           Sheetf.sheet-num = 2 No-ERROR.
if not avail sheetf then
create sheetf.
assign
Sheetf.Sheet-num = 2
sheetf.Excel-Column-Lable =  "№ п/п,Действие,Записей,итого,Множество"
sheetf.sizes = "9,9,9,12,155"
.
run rep/extitle.p ( input 2).
for each cli-list-hist:
  {&PutExcel}
  (if cli-list-hist.line = 0
   then string(cli-list-hist.id, ">>>>>>>>9")
   else '':U)
  {&tabulation}
  (if cli-list-hist.item_ <> '':U
   then cli-list-hist.hist-mode
   else '':U)  {&tabulation}
   (if cli-list-hist.item_ <> '':U
   then string(cli-list-hist.num-add, "->>>>>>>>9")
   else '':U)  {&tabulation}
  (if cli-list-hist.item_ <> '':U
  then string(cli-list-hist.num-recs, ">>>>>>>>9")
  else '':U)  {&tabulation}
  cli-list-hist.des
  skip.
end.


HIDE STREAM PRnLibStream FRAME Cli .
HIDE STREAM PRnLibStream FRAME top-Frame .
HIDE stream PRnLibStream FRAME NBottomFrame .
output stream PRnLibStream CLOSE .

{&CloseExcel}
run waitfram-hide in this-procedure .
DELETE WIDGET-POOL "My-pool".

/*непосредственно открытие Excel*/
if Make-Excel and pReportOption = "excel":U then do:
   run rep/runexcel.p (
                   input string( session:temp-directory +
                         {&DF_Name} +
                         string( g#report-num ) + ".txt":U )
                 ) .
   RUN CLoseForExcel in this-procedure .
end.