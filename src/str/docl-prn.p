block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: docl-prn.p $
$Archive: str/docl-prn.p $

Экспорт списка документов и/или в формате EXCEL

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/06/06
Author: Bakhtadze Natalya
Creation date: 01/06/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
DEFINE INPUT PARAMETER pReportOption as character no-undo.
/*
"" - простой список тип код им
"" -другие опции в будущем

*/
define output parameter p-frame-width as integer no-undo.

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: docl-prn.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/docl-prn.p $":U .
def var vss-description as character no-undo init "Экспорт списка документов и/или в формате EXCEL".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i  new }
{ cmp/doc-list.i doc-list def " shared "}
{ rep/dincol.i def }
define variable g#report-num as integer no-undo .
{ rep/opclexcl.i }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
if not valid-handle(my-handle) then do:
  assign
  my-handle = parparentproc.
end.


&SCOPED-DEFINE UNDERLINE-FRAME ~{ rep/dincol.i un 1 FOR-doc-code fill14 ~} ~
      ~{ rep/dincol.i un 2 for-doc-type fill10~} ~
      ~{ rep/dincol.i un 3 for-obj-type fill3~} ~
      ~{ rep/dincol.i un 4 for-obj-code fill5~} ~
      ~{ rep/dincol.i un 5 for-cli-type fill3~} ~
      ~{ rep/dincol.i un 6 for-cli-code fill9~} ~
      ~{ rep/dincol.i un 7 for-cli-name fill40~} ~
      DISPLAY stream  PrnLibStream with frame Doc. ~
      DOWN 1 stream PrnLibStream with frame Doc.

&SCOPED-DEFINE UNDERLINE-Excel ~{&PutExcel} ~
      ~{ rep/dincol.i unx 1 for-doc-code fill14 ~} ~
      ~{ rep/dincol.i unx 2 for-doc-type fill10~} ~
      ~{ rep/dincol.i unx 3 for-obj-type fill3~} ~
      ~{ rep/dincol.i unx 4 for-obj-code fill5~} ~
      ~{ rep/dincol.i unx 5 for-cli-type fill3~} ~
      ~{ rep/dincol.i unx 6 for-cli-code fill9~} ~
      ~{ rep/dincol.i unx 7 for-cli-name fill40~}


&SCOPED-DEFINE DISPLAY-FRAME         DISPLAY stream  PRnLibStream with frame Doc. ~
                                     DOWN 1 stream PrnLibStream with frame Doc.

&SCOPED-DEFINE DOWN-FRAME            DOWN 1 stream PrnLibStream with frame Doc.

&SCOPED-DEFINE DOWN-EXCEL            ~{&PutExcel} skip.

DEFINE VARIABLE LINE as character no-undo.
DEFINE VARIABLE FOR-doc-type as character no-undo .
DEFINE VARIABLE FOR-doc-code like ub.trn-doc.doc-code NO-UNDO.
DEFINE VARIABLE FOR-OBJ-type like ub.clients.obj-type NO-UNDO.
DEFINE VARIABLE FOR-OBJ-code like ub.clients.obj-code NO-UNDO.
DEFINE VARIABLE FOR-cli-type like ub.clients.obj-type NO-UNDO.
DEFINE VARIABLE FOR-cli-code like ub.clients.obj-code NO-UNDO.
DEFINE VARIABLE FOR-cli-name like ub.clients.obj-name NO-UNDO.
DEFINE VARIABLE fill3 as character no-undo.
DEFINE VARIABLE fill5 as character no-undo.
DEFINE VARIABLE fill9 as character no-undo.
DEFINE VARIABLE fill10 as character no-undo.
DEFINE VARIABLE fill14 as character no-undo.
DEFINE VARIABLE fill40 as character no-undo.
DEFINE VARIABLE accum-count as integer no-undo.
DEFINE VARIABLE ii as integer no-undo.
define variable v-host-name as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-client Dialog-Frame
FUNCTION get-client RETURNS CHARACTER
  ( input loc-doc-code as character,
    input loc-doc-type as character)  FORWARD.

DEFINE VARIABLE t-1 AS CHARACTER INITIAL "||||"
     VIEW-AS EDITOR
     SIZE 1 BY 4 NO-UNDO.


DEFINE FRAME top-frame
    t-1       AT ROW 1 COL 1 no-label
    HEADER
    cur-time-print() AT 5 format "x(35)"
    string( "Страница" ) AT 45 PAGE-NUMBER( PrnLibStream ) AT 55 FORMAT ">>9" SKIP
    with width {&DOS_CW_2} down stream-io use-text NO-BOX.

 DEFINE FRAME Doc
   with width {&DOS_CW_2} down stream-io use-text NO-BOX.

CASE pReportOption:
  when "excel":U then do:
    /*устанока параметра в Excel*/
    Make-excel = yes.
  end.
  when "":U then do:
    /*внешняя печать простого списка*/
  end.
  /*  todo
  when ??? then do:
  end.
  */
  /*вызов конфигуратора полей*/
end.


assign
use-column[1] = yes
use-column[2] = yes
use-column[3] = yes
use-column[4] = yes
use-column[5] = yes
use-column[6] = yes
use-column[7] = yes
fill3 = fill("-", 3)
fill5 = fill("-", 5)
fill9 = fill("-", 9)
fill10 = fill("-", 10)
fill14 = fill("-", 14)
fill40 = fill("-", 40)
.

FOR EACH sheetf where sheetf.sheet-num > 1:
  delete sheetf.
end.

FIND FIRST sheetf where
           sheetf.sheet-num = 1 No-ERROR.
{ gbl/hostname.i p-curr-obj-type p-curr-obj-code v-host-code v-host-name }
assign
ReportName = substitute("Список документов фирмы &1", v-host-name)
sheetf.Excel-Column-Lable =  ""
sheetf.sizes = "".

CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .

l-col-pos = 1.
Assign l-col-type="CHARACTER" l-col-len=14 l-col-format= "X(14)"     l-col-lable="Номер документа".
  { rep/dincol.i cr  1    for-doc-code  Doc                 }
  { rep/dincol.i crx 1 }
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "X(10)"     l-col-lable="Тип документа".
  { rep/dincol.i cr  2    for-doc-type  Doc                 }
  { rep/dincol.i crx 2 }
Assign l-col-type="CHARACTER" l-col-len=3 l-col-format= "X(3)"     l-col-lable="Тип".
  { rep/dincol.i cr  3    for-obj-type  Doc                 }
  { rep/dincol.i crx 3 }
Assign l-col-type="CHARACTER" l-col-len=5 l-col-format= "99999"       l-col-lable="Код объекта".
  { rep/dincol.i cr  4    for-obj-code       Doc                 }
  { rep/dincol.i crx 4 }
Assign l-col-type="CHARACTER" l-col-len=3 l-col-format= "X(3)"     l-col-lable="Тип".
  { rep/dincol.i cr  5    for-cli-type  Doc                 }
  { rep/dincol.i crx 5 }
Assign l-col-type="CHARACTER" l-col-len=9 l-col-format= "999999999"       l-col-lable="Код контр-та".
  { rep/dincol.i cr  6    for-cli-code       Doc                 }
  { rep/dincol.i crx 6 }
Assign l-col-type="DATE"   l-col-len=40  l-col-format= "X(40)"  l-col-lable="Название контрагента".
  { rep/dincol.i cr  7    for-cli-name    Doc        }
  { rep/dincol.i crx 7 }

Line = fill( "-" , 60 ) .

p-frame-width = l-col-pos - 1.

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

run get-report-num  in parParentProc(output g#report-num).

if Make-Excel then
RUN OpenForExcel in this-procedure .

FORM with FRAME Doc .
FORM HEADER
Line format "X(60)" AT 1 SKIP
string( "Продолжение - на следующей странице" ) FORMAT "X(40)" AT 10 SKIP
with FRAME NBottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW stream PrnLibStream FRAME NBottomFrame .
PUT stream PrnLibStream UNFORMATTED
SPACE(10)
Reportname {&new-line}
SKIP(1).


display stream PrnLibStream with frame top-Frame .

run rep/extitle.p (1).
run waitfram-show in this-procedure ("Ждите...").

{ str/docl-prn.i Doc-list }

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

for each doc-list-hist:
  {&PutExcel}
  (if doc-list-hist.line = 0
   then string(doc-list-hist.id, ">>>>>>>>9")
   else '':U)
  {&tabulation}
  (if doc-list-hist.item_ <> '':U
   then doc-list-hist.hist-mode
   else '':U)  {&tabulation}
   (if doc-list-hist.item_ <> '':U
   then string(doc-list-hist.num-add, "->>>>>>>>9")
   else '':U)  {&tabulation}
  (if doc-list-hist.item_ <> '':U
  then string(doc-list-hist.num-recs, ">>>>>>>>9")
  else '':U)  {&tabulation}
  doc-list-hist.des
  skip.
end.

HIDE stream PrnLibStream FRAME DOc .
HIDE stream PrnLibStream FRAME top-Frame .
HIDE stream PrnLibStream FRAME NBottomFrame .
output stream PrnLibStream CLOSE .

{&CloseExcel}
run waitfram-hide in this-procedure .

DELETE WIDGET-POOL "My-pool".

/*непосредственно открытие Excel*/
if Make-Excel then do:
   run rep/runexcel.p (
                   string( session:temp-directory +
                         {&DF_Name} +
                         string( g#report-num ) + ".txt":U )
                 ) .
end.

if Make-Excel then
RUN CLoseForExcel in this-procedure .


FUNCTION get-client RETURNS CHARACTER
  ( input loc-doc-code as character,
    input loc-doc-type as character) :
  if loc-doc-type = {&overvalue} then do:
    assign
    for-cli-type = ""
    for-cli-code = ?
    for-cli-name = "Переоценка"
    .
    find first ub.price-doc no-lock where
               ub.price-doc.doc-num = doc-list.doc-code No-ERROR.
    return for-cli-type.

  end.
  else do:

    FIND FIRST ub.trn-doc No-LOCK WHERE
               ub.trn-doc.doc-code = loc-doc-code No-ERROR.
    if not avail trn-doc then do:
        assign
        for-cli-type = "?"
        for-cli-code = ?
        for-cli-name = "Документ не найден"
        .

        return for-cli-type.

    end.
    assign
    for-cli-type = trn-doc.cli-type
    for-cli-code = trn-doc.cli-code
    .

    find first ub.clients no-lock where
               ub.clients.obj-type = ub.trn-doc.cli-type AND
               ub.clients.obj-code = ub.trn-doc.cli-code No-ERROR.
    if not avail ub.clients then do:
        assign
        for-cli-name = "Контрагент по документу не найден"
        .
        return for-cli-type.
    end.
    assign
    for-cli-name = ub.clients.obj-name
    .

    return for-cli-type.
  end.


  RETURN "".   /* Function return value. */

END FUNCTION.