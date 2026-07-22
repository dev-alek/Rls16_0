block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chklsprn.p $
$Archive: str/chklsprn.p $

Печать списка чеков с содержанием из механизма списка чеков в формате Excel

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/09/07
Author: Bakhtadze Natalya
Creation date: 08/09/07

*/

define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER pReportOption as character no-undo.
define input parameter p-print-option as character no-undo .
/*на будущее!!!! short doc gds pay*/
/*
"" - простой список тип код им
"" -другие опции в будущем

*/
define output parameter p-frame-width as integer no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chklsprn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chklsprn.p $":U .
define variable vss-description as character no-undo init "Печать списка чеков с содержанием из механизма списка чеков в формате Excel".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i  }
{ cmp/library.i }

&SCOPED-DEFINE UNDERLINE-FRAME-gds ~
      ~{ rep/dincol.i un 1 FOR-doc-code-gds fill14 ~} ~
      ~{ rep/dincol.i un 2 for-chk-type-gds fill10~} ~
      ~{ rep/dincol.i un 3 for-obj-code-gds fill5~} ~
      ~{ rep/dincol.i un 4 for-chk-date-gds fill10~} ~
      ~{ rep/dincol.i un 5 for-chk-time-gds fill8~} ~
      ~{ rep/dincol.i un 6 for-line-num fill5~} ~
      ~{ rep/dincol.i un 7 for-b-code fill9~} ~
      ~{ rep/dincol.i un 8 for-artic fill16~} ~
      ~{ rep/dincol.i un 9 for-gds-name fill27~} ~
      ~{ rep/dincol.i un 10 for-prt-name fill10~} ~
      ~{ rep/dincol.i un 11 for-err-gds fill2~} ~
      ~{ rep/dincol.i un 12 for-src-code fill19~} ~
      ~{ rep/dincol.i un 13 for-pump fill3~} ~
      ~{ rep/dincol.i un 14 for-prod-name fill20~} ~
      ~{ rep/dincol.i un 15 for-doc-qnty fill11~} ~
      ~{ rep/dincol.i un 16 for-unit-cli fill3~} ~
      ~{ rep/dincol.i un 17 for-price-base fill10~} ~
      ~{ rep/dincol.i un 18 for-gds-discnt fill9~} ~
      ~{ rep/dincol.i un 19 for-discnt-pcnt fill6~} ~
      ~{ rep/dincol.i un 20 for-price-netto fill9~} ~
      ~{ rep/dincol.i un 21 for-write-off fill2~} ~



&SCOPED-DEFINE underline-gds ~{&PutExcel} ~
      ~{ rep/dincol.i unx 1 FOR-doc-code-gds fill14 ~} ~
      ~{ rep/dincol.i unx 2 for-chk-type-gds fill10~} ~
      ~{ rep/dincol.i unx 3 for-obj-code-gds fill5~} ~
      ~{ rep/dincol.i unx 4 for-chk-date-gds fill10~} ~
      ~{ rep/dincol.i unx 5 for-chk-time-gds fill8~} ~
      ~{ rep/dincol.i unx 6 for-line-num fill5~} ~
      ~{ rep/dincol.i unx 7 for-b-code fill9~} ~
      ~{ rep/dincol.i unx 8 for-artic fill16~} ~
      ~{ rep/dincol.i unx 9 for-gds-name fill27~} ~
      ~{ rep/dincol.i unx 10 for-prt-name fill10~} ~
      ~{ rep/dincol.i unx 11 for-err-gds fill2~} ~
      ~{ rep/dincol.i unx 12 for-src-code fill19~} ~
      ~{ rep/dincol.i unx 13 for-pump fill3~} ~
      ~{ rep/dincol.i unx 14 for-prod-name fill20~} ~
      ~{ rep/dincol.i unx 15 for-doc-qnty fill11~} ~
      ~{ rep/dincol.i unx 16 for-unit-cli fill3~} ~
      ~{ rep/dincol.i unx 17 for-price-base fill10~} ~
      ~{ rep/dincol.i unx 18 for-gds-discnt fill9~} ~
      ~{ rep/dincol.i unx 19 for-discnt-pcnt fill6~} ~
      ~{ rep/dincol.i unx 20 for-price-netto fill9~} ~
      ~{ rep/dincol.i unx 21 for-write-off fill2~} ~


&SCOPED-DEFINE DISPLAY-FRAME         DISPLAY stream  PrnLibStream with frame Doc. ~
                                     DOWN 1 stream PrnLibStream with frame Doc.

&SCOPED-DEFINE DOWN-FRAME            DOWN 1 stream PrnLibStream with frame Doc.

&SCOPED-DEFINE DOWN-EXCEL            ~{&PutExcel} skip.

DEFINE VARIABLE LINE as character no-undo.
DEFINE VARIABLE FOR-chk-type-gds as character no-undo .
DEFINE VARIABLE FOR-doc-code-gds like ub.chk-doc.doc-code NO-UNDO.
DEFINE VARIABLE FOR-OBJ-type-gds like ub.chk-doc.obj-type NO-UNDO.
DEFINE VARIABLE FOR-OBJ-code-gds like ub.chk-doc.obj-code NO-UNDO.
define variable for-chk-date-gds as character no-undo .
define variable for-chk-time-gds as character no-undo .

define variable for-chk-num like ub.chk-doc.chk-num no-undo .
define variable for-pay-desk like ub.chk-doc.pay-desk no-undo .
define variable for-cashier like ub.chk-doc.cashier no-undo .
define variable for-d-card like ub.chk-doc.d-card no-undo .
define variable for-out-code like ub.chk-doc.out-code no-undo .
define variable for-doc-num like ub.chk-doc.doc-num no-undo .
define variable for-netto as decimal no-undo .
define variable for-discnt as decimal no-undo .
define variable for-tot-doc as decimal no-undo .
define variable for-line-num as integer no-undo .
define variable for-b-code as integer no-undo .
define variable for-artic as character no-undo .
define variable for-gds-name as character no-undo .
define variable for-prt-name as character no-undo .
define variable for-err-gds as logical no-undo .
define variable for-src-code as character no-undo .
define variable for-pump as integer no-undo .
define variable for-prod-name as character no-undo .
define variable for-doc-qnty as decimal no-undo .
define variable for-unit-cli as character no-undo .
define variable for-price-base as decimal no-undo .
define variable for-gds-discnt as decimal no-undo .
define variable for-discnt-pcnt as decimal no-undo .
define variable for-price-netto as decimal no-undo .
define variable for-write-off as logical no-undo .

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
define variable g#report-num as integer no-undo .
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_clients for ub.clients.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_cash-pay for ub.cash-pay.
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ cmp/r-page1.i  new }
{ cmp/chk-list.i chk-list def " shared "}
{ rep/dincol.i def }
{ rep/opclexcl.i }
{ gbl/waitfram.i }
{ str/paycardv.i }
if not valid-handle(my-handle) then do:
  assign
  my-handle = parparentproc.
end.


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


ReportName = "Строки списка чеков ".
assign
use-column[1] = yes  /*chk-gds.doc-code x18*/
use-column[2] = yes /*v-receipt-name */
use-column[3] = yes /*obj-code*/
use-column[4] = yes /*chk-date*/
use-column[5] = yes /*chk-time*/
use-column[6] = yes /*line-num*/
use-column[7] = yes /*b-code*/
use-column[8] = yes /*goods.artic*/
use-column[9] = yes /*goods.gds-name*/
use-column[10] = yes /*gds-prt.f-name*/
use-column[11] = yes /*chk-gds.is-error*/
use-column[12] = yes /*chk-gds.src-code*/
use-column[13] = yes /*chk-gds.pump*/
use-column[14] = yes /*clientsobj-anme*/
use-column[15] = yes /*doc-qnty*/
use-column[16] = yes /*unit-cli*/
use-column[17] = yes /*price-basei*/
use-column[18] = yes /*discbnt*/
use-column[19] = yes /*% ск."*/
use-column[20] = yes /*цена нетто*/
use-column[21] = yes /*спис*/
.

FOR EACH sheetf where sheetf.sheet-num > 1:
  delete sheetf.
end.

FIND FIRST sheetf where
           sheetf.sheet-num = 1 No-ERROR.
assign
sheetf.Excel-Column-Lable =  ""
sheetf.sizes = "".



CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .
l-col-pos = 1.
Assign l-col-type="CHARACTER" l-col-len=14 l-col-format= "X(14)"     l-col-lable="Номер чека в БД".
  { rep/dincol.i cr  1    for-doc-code-gds  Doc                 }
  { rep/dincol.i crx 1 }
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "X(10)"     l-col-lable="Тип чека".
  { rep/dincol.i cr  2    for-chk-type-gds  Doc                 }
  { rep/dincol.i crx 2 }
Assign l-col-type="INTEGER" l-col-len=5 l-col-format= "99999"       l-col-lable="Код объекта".
  { rep/dincol.i cr  3    for-obj-code-gds       Doc                 }
  { rep/dincol.i crx 3 }
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "X(10)"       l-col-lable="Дата чека".
  { rep/dincol.i cr  4     for-chk-date-gds       Doc                 }
  { rep/dincol.i crx 4 }
Assign l-col-type="CHARACTER" l-col-len=8 l-col-format= "X(8)"       l-col-lable="Время чека".
  { rep/dincol.i cr  5    for-chk-time-gds       Doc                 }
  { rep/dincol.i crx 5 }
Assign l-col-type="integer" l-col-len=5 l-col-format= ">>>>9"       l-col-lable="№№".
  { rep/dincol.i cr  6    for-line-num       Doc                 }
  { rep/dincol.i crx 6 }
Assign l-col-type="integer" l-col-len=9 l-col-format= ">>>>>>>>9"       l-col-lable="Код товара/код платежа".
  { rep/dincol.i cr  7    for-b-code       Doc                 }
  { rep/dincol.i crx 7 }
Assign l-col-type="character" l-col-len=16 l-col-format= "X(16)"       l-col-lable="Артикул/№ карты ".
  { rep/dincol.i cr  8    for-artic       Doc                 }
  { rep/dincol.i crx 8 }
Assign l-col-type="character" l-col-len=27 l-col-format= "X(27)"       l-col-lable="Название товара/название платежа".
  { rep/dincol.i cr  9    for-gds-name       Doc                 }
  { rep/dincol.i crx 9 }
Assign l-col-type="character" l-col-len=10 l-col-format= "X(10)"       l-col-lable="Признак".
  { rep/dincol.i cr  10    for-prt-name       Doc                 }
  { rep/dincol.i crx 10 }
Assign l-col-type="logical" l-col-len=2 l-col-format= "+/"       l-col-lable="Ош".
  { rep/dincol.i cr  11    for-err-gds       Doc                 }
  { rep/dincol.i crx 11 }
Assign l-col-type="character" l-col-len=19 l-col-format= "X(19)"       l-col-lable="Код в спуле/№ ДК".
  { rep/dincol.i cr  12    for-src-code       Doc                 }
  { rep/dincol.i crx 12 }
Assign l-col-type="integer" l-col-len=3 l-col-format= ">>9"       l-col-lable="ТРК".
  { rep/dincol.i cr  13    for-pump       Doc                 }
  { rep/dincol.i crx 13 }
Assign l-col-type="character" l-col-len=20 l-col-format= "X(20)"       l-col-lable="Производитель".
  { rep/dincol.i cr  14    for-prod-name       Doc                 }
  { rep/dincol.i crx 14 }
Assign l-col-type="decimal" l-col-len=11 l-col-format= "->>,>>9.999"       l-col-lable="Кол-во".
  { rep/dincol.i cr  15    for-doc-qnty       Doc                 }
  { rep/dincol.i crx 15 }
Assign l-col-type="character" l-col-len=3 l-col-format= "X(3)"       l-col-lable="Ед.изм".
  { rep/dincol.i cr  16    for-unit-cli       Doc                 }
  { rep/dincol.i crx 16 }
Assign l-col-type="decimal" l-col-len=10 l-col-format= "->>,>>9.99"       l-col-lable="Цена/Сумма".
  { rep/dincol.i cr  17    for-price-base       Doc                 }
  { rep/dincol.i crx 17 }
Assign l-col-type="decimal" l-col-len=9 l-col-format= "->,>>9.99"       l-col-lable="Скидка".
  { rep/dincol.i cr  18    for-gds-discnt       Doc                 }
  { rep/dincol.i crx 18 }
Assign l-col-type="decimal" l-col-len=6 l-col-format= "->9.99"       l-col-lable="% Ск.".
  { rep/dincol.i cr  19    for-discnt-pcnt      Doc                 }
  { rep/dincol.i crx 19 }
Assign l-col-type="decimal" l-col-len=9 l-col-format= ">>,>>9.99"       l-col-lable="Цена нетто".
  { rep/dincol.i cr  20    for-price-netto       Doc                 }
  { rep/dincol.i crx 20 }
Assign l-col-type="logical" l-col-len=2 l-col-format= "+/"       l-col-lable="Сп".
  { rep/dincol.i cr  21    for-write-off       Doc                 }
  { rep/dincol.i crx 21 }





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
SKIP(1).


display STREAM PrnLibStream with frame top-Frame .

run rep/extitle.p ( input 1).
run waitfram-show in this-procedure ( input "Ждите...").

{ str/chklsprn.i chk-list }

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
for each chk-list-hist:
  {&PutExcel}
  (if chk-list-hist.line = 0
   then string(chk-list-hist.id, ">>>>>>>>9")
   else '':U)
  {&tabulation}
  (if chk-list-hist.item_ <> '':U
   then chk-list-hist.hist-mode
   else '':U)  {&tabulation}
   (if chk-list-hist.item_ <> '':U
   then string(chk-list-hist.num-add, "->>>>>>>>9")
   else '':U)  {&tabulation}
  (if chk-list-hist.item_ <> '':U
  then string(chk-list-hist.num-recs, ">>>>>>>>9")
  else '':U)  {&tabulation}
  chk-list-hist.des
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