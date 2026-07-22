block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chkl-prn.p $
$Archive: str/chkl-prn.p $

Печать списка чеков из механизма списка чеков в формате Excel

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/02/04
Author: Bakhtadze Natalya
Creation date: 03/02/04

*/

define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER pReportOption as character no-undo.
define input parameter p-print-option as character no-undo .
/*на будущее!!!! short doc gds pay*/
define input parameter p-notes as character no-undo .
/*
"" - простой список тип код им
"" -другие опции в будущем

*/
define output parameter p-frame-width as integer no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chkl-prn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chkl-prn.p $":U .
define variable vss-description as character no-undo init "Печать списка чеков из механизма списка чеков в формате Excel".
{ cmp/vssrevis.i }

{ cmp/trg-def.i  }

&SCOPED-DEFINE UNDERLINE-FRAME ~{ rep/dincol.i un 1 FOR-doc-code fill14 ~} ~
      ~{ rep/dincol.i un 2 for-chk-type fill10~} ~
      ~{ rep/dincol.i un 3 for-obj-type fill3~} ~
      ~{ rep/dincol.i un 4 for-obj-code fill5~} ~
      ~{ rep/dincol.i un 5 for-chk-date fill10~} ~
      ~{ rep/dincol.i un 6 for-chk-time fill8~} ~
      ~{ rep/dincol.i un 7 for-chk-num  fill7~} ~
      ~{ rep/dincol.i un 8 for-pay-desk  fill4~} ~
      ~{ rep/dincol.i un 9 for-cashier  fill4~} ~
      ~{ rep/dincol.i un 10 for-out-code  fill14~} ~
      ~{ rep/dincol.i un 11 for-d-card   fill16~} ~
      ~{ rep/dincol.i un 12 for-doc-num  fill10~} ~
      ~{ rep/dincol.i un 13 for-netto   fill13~} ~
      ~{ rep/dincol.i un 14 for-discnt   fill13~} ~
      ~{ rep/dincol.i un 15 for-tot-doc   fill13~} ~
      DISPLAY stream  PrnLibStream with frame Doc. ~
      DOWN 1 stream PrnLibStream with frame Doc.

&SCOPED-DEFINE UNDERLINE-Excel ~{&PutExcel} ~
      ~{ rep/dincol.i unx 1 for-doc-code fill14 ~} ~
      ~{ rep/dincol.i unx 2 for-chk-type fill10~} ~
      ~{ rep/dincol.i unx 3 for-obj-type fill3~} ~
      ~{ rep/dincol.i unx 4 for-obj-code fill5~} ~
      ~{ rep/dincol.i unx 5 for-chk-date fill10~} ~
      ~{ rep/dincol.i unx 6 for-chk-time fill8~} ~
      ~{ rep/dincol.i unx 7 for-chk-num  fill7~} ~
      ~{ rep/dincol.i unx 8 for-pay-desk  fill4~} ~
      ~{ rep/dincol.i unx 9 for-cashier  fill4~} ~
      ~{ rep/dincol.i unx 10 for-out-code  fill14~} ~
      ~{ rep/dincol.i unx 11 for-d-card   fill16~} ~
      ~{ rep/dincol.i unx 12 for-d-card   fill10~} ~
      ~{ rep/dincol.i unx 13 for-netto   fill13~} ~
      ~{ rep/dincol.i unx 14 for-discnt   fill13~} ~
      ~{ rep/dincol.i unx 15 for-tot-doc   fill13~} ~



&SCOPED-DEFINE DISPLAY-FRAME         DISPLAY stream  PrnLibStream with frame Doc. ~
                                     DOWN 1 stream PrnLibStream with frame Doc.

&SCOPED-DEFINE DOWN-FRAME            DOWN 1 stream PrnLibStream with frame Doc.

&SCOPED-DEFINE DOWN-EXCEL            ~{&PutExcel} skip.

DEFINE VARIABLE LINE as character no-undo.
DEFINE VARIABLE FOR-chk-type as character no-undo .
DEFINE VARIABLE FOR-doc-code like ub.chk-doc.doc-code NO-UNDO.
DEFINE VARIABLE FOR-OBJ-type like ub.chk-doc.obj-type NO-UNDO.
DEFINE VARIABLE FOR-OBJ-code like ub.chk-doc.obj-code NO-UNDO.
define variable for-chk-date as character no-undo .
define variable for-chk-time as character no-undo .
define variable for-chk-num like ub.chk-doc.chk-num no-undo .
define variable for-pay-desk like ub.chk-doc.pay-desk no-undo .
define variable for-cashier like ub.chk-doc.cashier no-undo .
define variable for-d-card like ub.chk-doc.d-card no-undo .
define variable for-doc-num like ub.chk-doc.doc-num  no-undo .
define variable for-out-code like ub.chk-doc.out-code no-undo .
define variable for-netto as decimal no-undo .
define variable for-discnt as decimal no-undo .
define variable for-tot-doc as decimal no-undo .
DEFINE VARIABLE fill2 as character no-undo.
DEFINE VARIABLE fill3 as character no-undo.
DEFINE VARIABLE fill4 as character no-undo.
DEFINE VARIABLE fill5 as character no-undo.
DEFINE VARIABLE fill6 as character no-undo.
DEFINE VARIABLE fill7 as character no-undo.
DEFINE VARIABLE fill8 as character no-undo.
DEFINE VARIABLE fill9 as character no-undo.
DEFINE VARIABLE fill10 as character no-undo.
DEFINE VARIABLE fill11 as character no-undo.
DEFINE VARIABLE fill13 as character no-undo.
DEFINE VARIABLE fill14 as character no-undo.
DEFINE VARIABLE fill16 as character no-undo.
DEFINE VARIABLE fill19 as character no-undo.
DEFINE VARIABLE fill20 as character no-undo.
DEFINE VARIABLE fill27 as character no-undo.
DEFINE VARIABLE fill40 as character no-undo.
DEFINE VARIABLE accum-count as integer no-undo.
DEFINE VARIABLE ii as integer no-undo.
DEFINE VARIABLE dopstr as character no-undo .
DEFINE VARIABLE dopstr1 as character no-undo .
define variable g#report-num as integer no-undo .
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ cmp/r-page1.i  new }
{ cmp/chk-list.i chk-list def " shared "}
{ rep/dincol.i def }
{ rep/opclexcl.i }
{ gbl/waitfram.i }


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-chk-type Dialog-Frame
FUNCTION get-chk-type RETURNS CHARACTER
  ( input loc-doc-code as character,
    input loc-doc-type as integer,
    input loc-is-wth as logical)  FORWARD.

DEFINE STREAM PrnLibStream.

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
use-column[8] = yes
use-column[9] = yes
use-column[10] = yes
use-column[11] = yes
use-column[12] = yes
use-column[13] = yes
use-column[14] = yes
use-column[15] = yes
fill2 = fill("-", 2)
fill3 = fill("-", 3)
fill4 = fill("-", 4)
fill5 = fill("-", 5)
fill6 = fill("-", 6)
fill7 = fill("-", 7)
fill8 = fill("-", 8)
fill9 = fill("-", 9)
fill10 = fill("-", 10)
fill11 = fill("-", 11)
fill13 = fill("-", 13)
fill14 = fill("-", 14)
fill16 = fill("-", 16)
fill19 = fill("-", 19)
fill20 = fill("-", 20)
fill40 = fill("-", 40)
.

FOR EACH sheetf where sheetf.sheet-num > 1:
  delete sheetf.
end.

FIND FIRST sheetf where
           sheetf.sheet-num = 1 No-ERROR.
assign
ReportName = "Список чеков "
sheetf.Excel-Column-Lable =  ""
sheetf.sizes = "".

CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .

l-col-pos = 1.
Assign l-col-type="CHARACTER" l-col-len=14 l-col-format= "X(14)"     l-col-lable="Номер чека в БД".
  { rep/dincol.i cr  1    for-doc-code  Doc                 }
  { rep/dincol.i crx 1 }
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "X(10)"     l-col-lable="Тип чека".
  { rep/dincol.i cr  2    for-chk-type  Doc                 }
  { rep/dincol.i crx 2 }
Assign l-col-type="CHARACTER" l-col-len=3 l-col-format= "X(3)"     l-col-lable="Тип".
  { rep/dincol.i cr  3    for-obj-type  Doc                 }
  { rep/dincol.i crx 3 }
Assign l-col-type="INTEGER" l-col-len=5 l-col-format= "99999"       l-col-lable="Код объекта".
  { rep/dincol.i cr  4    for-obj-code       Doc                 }
  { rep/dincol.i crx 4 }
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "X(10)"       l-col-lable="Дата чека".
  { rep/dincol.i cr  5    for-chk-date       Doc                 }
  { rep/dincol.i crx 5 }
Assign l-col-type="CHARACTER" l-col-len=8 l-col-format= "X(8)"       l-col-lable="Время чека".
  { rep/dincol.i cr  6    for-chk-time       Doc                 }
  { rep/dincol.i crx 6 }
Assign l-col-type="CHARACTER" l-col-len=8 l-col-format= ">>>>>>9"       l-col-lable="№ чека на кассе".
  { rep/dincol.i cr  7    for-chk-num       Doc                 }
  { rep/dincol.i crx 7 }
Assign l-col-type="INTEGER" l-col-len=4 l-col-format= ">>>9"       l-col-lable="Касса".
  { rep/dincol.i cr  8    for-pay-desk       Doc                 }
  { rep/dincol.i crx 8 }
Assign l-col-type="INTEGER" l-col-len=4 l-col-format= ">>>9"       l-col-lable="Кассир".
  { rep/dincol.i cr  9    for-cashier       Doc                 }
  { rep/dincol.i crx 9 }
Assign l-col-type="CHARACTER" l-col-len=14 l-col-format= "X(14)"       l-col-lable="Номер РН".
  { rep/dincol.i cr  10    for-out-code       Doc                 }
  { rep/dincol.i crx 10 }
Assign l-col-type="CHARACTER" l-col-len=16 l-col-format= "X(16)"       l-col-lable="Дкарта".
  { rep/dincol.i cr  11    for-d-card       Doc                 }
  { rep/dincol.i crx 11 }
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "X(10)"       l-col-lable="№ док-та".
  { rep/dincol.i cr  12    for-doc-num       Doc                 }
  { rep/dincol.i crx 12 }
Assign l-col-type="decimal" l-col-len=13 l-col-format= "->,>>>,>>9.99"       l-col-lable="Нетто".
  { rep/dincol.i cr  13    for-netto       Doc                 }
  { rep/dincol.i crx 13 }
Assign l-col-type="decimal" l-col-len=13 l-col-format= "->,>>>,>>9.99"       l-col-lable="Скидка".
  { rep/dincol.i cr  14    for-discnt       Doc                 }
  { rep/dincol.i crx 14 }
Assign l-col-type="decimal" l-col-len=13 l-col-format= "->,>>>,>>9.99"       l-col-lable="Брутто".
  { rep/dincol.i cr  15    for-tot-doc       Doc                 }
  { rep/dincol.i crx 15 }


Line = fill( "-" , 60 ) .

p-frame-width = l-col-pos - 1.

run get-report-num  in parParentProc ( output g#report-num).

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

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
p-notes
SKIP(1).


display STREAM PrnLibStream with frame top-Frame .

run rep/extitle.p (1).
run waitfram-show in this-procedure ("Ждите...").

{ str/chkl-prn.i chk-list }

{&pageExcel}

FInd first Sheetf where
           Sheetf.sheet-num = 2 No-ERROR.
if not avail sheetf then
create sheetf.
assign
Sheetf.Sheet-num = 2
sheetf.Excel-Column-Lable =  "№ п/п,Действие,Множество"
sheetf.sizes = "3,10,40"
.
run rep/extitle.p (2).

do ii = 1 to num-entries (p-Notes, {&new-line}):
  assign
  dopstr = substring (entry (ii, p-notes, {&new-line}), 1, 1)
  dopstr1 = substring (entry (ii, p-notes, {&new-line}), 3)
  .

  {&PutExcel}
  { rep/dincol.i dix 1 for-doc-code string(ii) }
  { rep/dincol.i dix 2 for-chk-type dopstr }
  { rep/dincol.i dixf 3 for-chk-date dopstr1 }
  skip.
end.

HIDE STREAM PrnLibStream FRAME DOc .
HIDE STREAM PrnLibStream FRAME top-Frame .
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

FUNCTION get-chk-type RETURNS CHARACTER
  ( LOC-DOC-CODE AS CHARACTER, loc-chk-type as integer, loc-is-wth as logical ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define variable v-str as character no-undo.
CASE loc-is-wth:
    when yes then do:
&scop wth-receipt-code string(loc-chk-type)
    assign
    v-str = {&wth-receipt-name}
    no-error
    .
  end.
  when no then do:
&scop receipt-code string(loc-chk-type)
      if loc-chk-type = ?
      or loc-chk-type = 0
      then do:
        find first buf_chk-doc no-lock where
                  buf_chk-doc.doc-code = loc-doc-code no-error .
        if available buf_chk-doc then do:
          assign
          loc-chk-type = integer(if buf_chk-doc.netto >= 0
                  then {&rcpt-sale}
                  else {&rcpt-return})
          .
        end.
        if loc-chk-type = integer({&rcpt-return}) then do:
          for each buf_chk-gds no-lock where
                  buf_Chk-gds.doc-code = buf_chk-doc.doc-code:
            if not (buf_Chk-gds.write-off-code < 0 and
                    (buf_Chk-gds.write-off-code = integer({&wro-cancell-all})
                    or
                    buf_Chk-gds.write-off-code = integer({&wro-v-modificator-ca})
                    )
                    )
            then do:
              leave.
            end.
          end.
        end.
        if not available buf_chk-gds then
        loc-chk-type = integer({&rcpt-return-write-off}).
      end.
      assign
      v-str = {&receipt-name}
      no-error
      .
  end.
END CASE.
RETURN v-str.   /* Function return value. */
END FUNCTION.