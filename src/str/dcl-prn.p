block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dcl-prn.p $
$Archive: str/dcl-prn.p $

Экспорт списка дисконтных карт в формате EXCEL

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter parhost-code like ub.sysconf.host-code no-undo .
define input parameter parobj-type like ub.clients.obj-type no-undo .
define input parameter parobj-code like ub.clients.obj-code no-undo .
DEFINE INPUT PARAMETER pReportOption as character no-undo.

/*
"" - простой список тип код им
"" -другие опции в будущем

*/
define output parameter p-frame-width as integer no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dcl-prn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/dcl-prn.p $":U .
define variable vss-description as character no-undo init "Экспорт списка дисконтных карт в формате EXCEL".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i  }
{ gbl/prn-lib.i }
{ cmp/dc-list.i dc-list def shared }
{ rep/dincol.i def }
define variable g#report-num as integer no-undo .
{ rep/opclexcl.i }
{ gbl/waitfram.i }


&SCOPED-DEFINE UNDERLINE-FRAME ~{ rep/dincol.i un 1 FOR-d-card fill16 ~} ~
      ~{ rep/dincol.i un 2 for-cli-type fill3~} ~
      ~{ rep/dincol.i un 3 for-cli-code fill9~} ~
      ~{ rep/dincol.i un 4 for-cli-name  fill45~} ~
      ~{ rep/dincol.i un 5 for-issue-CODE fill5~} ~
      ~{ rep/dincol.i un 6 for-issue-date fill10~} ~
      ~{ rep/dincol.i un 7 for-d-pcnt fill12~} ~
      ~{ rep/dincol.i un 8 for-status_ fill4~} ~
      ~{ rep/dincol.i un 9 for-emitent-host-code fill9~} ~
      ~{ rep/dincol.i un 10 for-sourced-card fill16~} ~
      ~{ rep/dincol.i un 11 for-obj-d-pcnt fill8~} ~
      ~{ rep/dincol.i un 12 for-valid-date fill10~} ~
      ~{ rep/dincol.i un 13 for-type fill8~} ~
      ~{ rep/dincol.i un 14 for-credit-card fill19~} ~
      ~{ rep/dincol.i un 15 for-lim-kr fill18~} ~
      ~{ rep/dincol.i un 16 for-cash-d-pcnt fill12~} ~
      DISPLAY stream  PrnLibStream with frame dc. ~
      DOWN 1 stream PrnLibStream with frame dc.

&SCOPED-DEFINE UNDERLINE-Excel ~{&PutExcel} ~
      ~{ rep/dincol.i unx 1 for-d-card fill16~} ~
      ~{ rep/dincol.i unx 2 for-cli-type fill3~} ~
      ~{ rep/dincol.i unx 3 for-cli-code fill9~} ~
      ~{ rep/dincol.i unx 4 for-cli-name  fill45~} ~
      ~{ rep/dincol.i unx 5 for-issue-CODE fill5~} ~
      ~{ rep/dincol.i unx 6 for-issue-date fill10~} ~
      ~{ rep/dincol.i unx 7 for-d-pcnt fill12~} ~
      ~{ rep/dincol.i unx 8 for-status_ fill4~} ~
      ~{ rep/dincol.i unx 9 for-emitent-host-code fill9~} ~
      ~{ rep/dincol.i unx 10 for-sourced-card fill16~} ~
      ~{ rep/dincol.i unx 11 for-obj-d-pcnt fill8~} ~
      ~{ rep/dincol.i unx 12 for-valid-date fill10~} ~
      ~{ rep/dincol.i unx 13 for-type fill8~} ~
      ~{ rep/dincol.i unx 14 for-credit-card fill19~} ~
      ~{ rep/dincol.i unx 15 for-lim-kr fill18~} ~
      ~{ rep/dincol.i unx 16 for-cash-d-pcnt fill12~} ~



&SCOPED-DEFINE DISPLAY-FRAME         DISPLAY stream  PrnLibStream with frame dc. ~
                                     DOWN 1 stream PrnLibStream with frame dc.

&SCOPED-DEFINE DOWN-FRAME            DOWN 1 stream PrnLibStream with frame dc.

&SCOPED-DEFINE DOWN-EXCEL            ~{&PutExcel} skip.

DEFINE VARIABLE LINE as character no-undo.
DEFINE VARIABLE for-d-card like ub.dis-card.d-card no-undo .
DEFINE VARIABLE for-issue-code like ub.dis-card.issue-code no-undo .
DEFINE VARIABLE for-issue-date like ub.dis-card.issue-date no-undo .
DEFINE VARIABLE for-d-pcnt like ub.dis-card.d-pcnt no-undo .
DEFINE VARIABLE for-cash-d-pcnt like ub.dis-card.cash-d-pcnt no-undo .
DEFINE VARIABLE for-status_ like ub.dis-card.status_ no-undo .
DEFINE VARIABLE for-emitent-host-code like ub.dis-card.emitent-host-code no-undo .
DEFINE VARIABLE for-sourced-card like ub.dis-card.sourced-card no-undo .
DEFINE VARIABLE for-obj-d-pcnt as character no-undo .
DEFINE VARIABLE for-obj-d-pcntd as decimal no-undo .
DEFINE VARIABLE for-valid-date like ub.dis-card.valid-date no-undo .
DEFINE VARIABLE for-type like ub.dis-card.type no-undo .
DEFINE VARIABLE for-credit-card like ub.dis-card.credit-card no-undo .
DEFINE VARIABLE for-lim-kr like ub.dis-card.lim-kr no-undo .
DEFINE VARIABLE for-cli-name like ub.clients.obj-name no-undo .
DEFINE VARIABLE for-cli-type like ub.dis-card.cli-type no-undo .
DEFINE VARIABLE for-cli-code like ub.dis-card.cli-code no-undo .
DEFINE VARIABLE fill3 as character no-undo.
DEFINE VARIABLE fill4 as character no-undo.
DEFINE VARIABLE fill5 as character no-undo.
DEFINE VARIABLE fill7 as character no-undo.
DEFINE VARIABLE fill8 as character no-undo.
DEFINE VARIABLE fill9 as character no-undo.
DEFINE VARIABLE fill10 as character no-undo.
DEFINE VARIABLE fill12 as character no-undo.
DEFINE VARIABLE fill14 as character no-undo.
DEFINE VARIABLE fill16 as character no-undo.
DEFINE VARIABLE fill18 as character no-undo.
DEFINE VARIABLE fill19 as character no-undo.
DEFINE VARIABLE fill45 as character no-undo.
DEFINE VARIABLE accum-count as integer no-undo.
DEFINE VARIABLE ii as integer no-undo.
DEFINE VARIABLE v-codes as character no-undo .
DEFINE VARIABLE v-labels as character no-undo .
DEFINE VARIABLE v-options as character no-undo .

DEFINE VARIABLE t-1 AS CHARACTER INITIAL "||||"
     VIEW-AS EDITOR
     SIZE 1 BY 4 NO-UNDO.


DEFINE FRAME top-frame
    t-1       AT ROW 1 COL 1 no-label
    HEADER
    cur-time-print() AT 5 format "X(35)"
    string( "Страница" ) AT 45 PAGE-NUMBER( PrnLibStream ) AT 55 FORMAT ">>9" SKIP
    with width {&DOS_CW_2} down stream-io use-text NO-BOX.

 DEFINE FRAME DC
   with width {&DOS_CW_2} down stream-io use-text NO-BOX.


CASE pReportOption:
  when "excel":U then do:
    /*устанока параметра в Excel*/
    Make-excel = yes.
  end.
  when "main":U then do:
    /*внешняя печать простого списка*/
    do ii = 5 to 15:
      use-column[ii] = no.
    end.
  end.
  when "extended":U then do:
    /*вызов конфигуратора полей*/
    assign
    Make-excel = yes
    v-codes =  "issue-code,issue-date,d-pcnt,status_,emitent-host-code,sourced-card,obj-d-pcnt,valid-date,type,credit-card,lim-kr,cash-d-pcnt":U
    v-labels =  "Магазин выдачи" + {&comma-char} +
               "Дата выдачи" + {&comma-char} +
               "Скидка" + {&comma-char} +
               "Статус" + {&comma-char} +
               "Эмитент" + {&comma-char} +
               "К карте" + {&comma-char} +
               "Скидка на объекте" + {&space-char} + parobj-type + string(parobj-code) + {&comma-char} +
               "Действует по" + {&comma-char} +
               "Тип" + {&comma-char} +
               "Кредитная" + {&comma-char} +
               "Лимит кредита" + {&comma-char} +
               "Скидка на итог"

    .
    run gbl/d-list.w ("b-sel,b-mark":U,
                "Выберите дополнительные поля для печати",
                v-codes,
                v-labels,
                {&comma-char},
                "":U,
                output v-options).
    do ii = 1 to num-entries(v-codes):
      use-column[ii + 4] = lookup(entry(ii, v-codes), v-options) > 0.
    end.
  end.
end.


assign
use-column[1] = yes
use-column[2] = yes
use-column[3] = yes
use-column[4] = yes
fill3 = fill("-", 3)
fill4 = fill("-", 4)
fill5 = fill("-", 5)
fill7 = fill("-", 7)
fill8 = fill("-", 8)
fill9 = fill("-", 9)
fill10 = fill("-", 10)
fill12 = fill("-", 12)
fill14 = fill("-", 14)
fill16 = fill("-", 16)
fill18 = fill("-", 18)
fill19 = fill("-", 19)
fill45 = fill("-", 45)
.

FOR EACH sheetf where sheetf.sheet-num > 1:
  delete sheetf.
end.
if not valid-handle(my-handle) then do:
  assign
  my-handle = parparentproc.
end.
run get-report-num in parparentproc (output g#report-num).
FIND FIRST sheetf where
           sheetf.sheet-num = 1 No-ERROR.
assign
ReportName = "Список дисконтных карт"
sheetf.Excel-Column-Lable =  ""
sheetf.sizes = "".

CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .

l-col-pos = 1.
Assign l-col-type="CHARACTER" l-col-len=16 l-col-format= "X(16)"     l-col-lable="N карты".
  { rep/dincol.i cr  1    for-d-card  dc                 }
  { rep/dincol.i crx 1 }
Assign l-col-type="CHARACTER" l-col-len=6 l-col-format= "X(3)"       l-col-lable="Клиент".
  { rep/dincol.i cr  2    for-cli-type       dc                 }
  { rep/dincol.i crx 2 }
Assign l-col-type="INTEGER" l-col-len=9 l-col-format= ">>>>>>>>9"       l-col-lable="Код клиента".
  { rep/dincol.i cr  3    for-cli-code       dc                 }
  { rep/dincol.i crx 3 }
Assign l-col-type="CHARACTER"   l-col-len=45  l-col-format= "X(45)"  l-col-lable="Название(ФИО) клиента".
  { rep/dincol.i cr  4    for-cli-name     dc        }
  { rep/dincol.i crx 4 }
Assign l-col-type="integer"   l-col-len=5  l-col-format= "99999"  l-col-lable="Выдал магаз".
  { rep/dincol.i cr  5    for-issue-code    dc        }
  { rep/dincol.i crx 5 }
Assign l-col-type="DATE"   l-col-len=10  l-col-format= "99/99/9999"  l-col-lable="Дата выдачи".
  { rep/dincol.i cr  6    for-issue-date    dc        }
  { rep/dincol.i crx 6 }
Assign l-col-type="DECIMAL"   l-col-len=7  l-col-format= "->9.99%"  l-col-lable="% Скидки".
  { rep/dincol.i cr  7    for-d-pcnt    dc        }
  { rep/dincol.i crx 7 }
Assign l-col-type="CHARACTER"   l-col-len=4  l-col-format= "X(4)"  l-col-lable="Статус".
  { rep/dincol.i cr  8    for-status_    dc        }
  { rep/dincol.i crx 8 }
Assign l-col-type="INTEGER"   l-col-len=9  l-col-format= ">>>>>>>>9"  l-col-lable="Эмитент".
  { rep/dincol.i cr  9    for-emitent-host-code  dc        }
  { rep/dincol.i crx 9 }
Assign l-col-type="CHARACTER"   l-col-len=16  l-col-format= "X(16)"  l-col-lable="К карте".
  { rep/dincol.i cr  10    for-sourced-card    dc        }
  { rep/dincol.i crx 10 }
Assign l-col-type="CHARACTER"   l-col-len=8  l-col-format= "X(8)"  l-col-lable="Скидка" + {&space-char} + parobj-type + string(parobj-code).
  { rep/dincol.i cr  11    for-obj-d-pcnt   dc        }
  { rep/dincol.i crx 11 }
Assign l-col-type="DATE"   l-col-len=10  l-col-format= "99/99/9999"  l-col-lable="Действует по".
  { rep/dincol.i cr  12    for-valid-date    dc        }
  { rep/dincol.i crx 12 }
Assign l-col-type="CHARACTER"   l-col-len=8  l-col-format= "X(8)"  l-col-lable="Тип".
  { rep/dincol.i cr  13    for-type   dc        }
  { rep/dincol.i crx 13 }
Assign l-col-type="LOGICAL"   l-col-len=9  l-col-format= "+/"  l-col-lable="Кред-ная".
  { rep/dincol.i cr  14    for-credit-card    dc        }
  { rep/dincol.i crx 14 }
Assign l-col-type="DECIMAL"   l-col-len=18  l-col-format= ">>>,>>>,>>>,>>9.99"  l-col-lable="Лимит кредита".
  { rep/dincol.i cr  15    for-lim-kr    dc        }
  { rep/dincol.i crx 15 }
Assign l-col-type="DECIMAL"   l-col-len=7  l-col-format= "->9.99%"  l-col-lable="% Ск.итог".
  { rep/dincol.i cr  16    for-cash-d-pcnt    dc        }
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

FORM with FRAME dc .
FORM HEADER
Line format "X(60)" AT 1 SKIP
string( "Продолжение - на следующей странице" ) FORMAT "X(40)" AT 10 SKIP
with FRAME NBottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW stream PrnLibStream FRAME NBottomFrame .
PUT stream PrnLibStream UNFORMATTED
SPACE(10)
Reportname {&new-line}
SKIP(1).


display STREAM PrnLibStream with frame top-Frame .

run rep/extitle.p (1).
run waitfram-show in this-procedure ("Ждите...").

{ str/dcl-prn.i dc-list }

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
run rep/extitle.p (2).

for each dc-list-hist:
  {&PutExcel}
  (if dc-list-hist.line = 0
   then string(dc-list-hist.id, ">>>>>>>>9")
   else '':U)
  {&tabulation}
  (if dc-list-hist.item_ <> '':U
   then dc-list-hist.hist-mode
   else '':U)  {&tabulation}
   (if dc-list-hist.item_ <> '':U
   then string(dc-list-hist.num-add, "->>>>>>>>9")
   else '':U)  {&tabulation}
  (if dc-list-hist.item_ <> '':U
  then string(dc-list-hist.num-recs, ">>>>>>>>9")
  else '':U)  {&tabulation}
  dc-list-hist.des
  skip.
end.


HIDE STREAM PrnLibStream FRAME dc .
HIDE STREAM PrnLibStream FRAME top-Frame .
HIDE stream PrnLibStream FRAME NBottomFrame .
output stream PrnLibStream CLOSE .

{&CloseExcel}
DELETE WIDGET-POOL "My-pool".
run waitfram-hide in this-procedure .
/*непосредственно открытие Excel*/
if Make-Excel and pReportOption = "excel":U then do:
   run rep/runexcel.p (
                   string( session:temp-directory +
                         {&DF_Name} +
                         string( g#report-num ) + ".txt":U )
                 ) .
   RUN CLoseForExcel in this-procedure .
end.