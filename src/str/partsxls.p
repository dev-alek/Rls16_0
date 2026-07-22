block-level on error undo, throw.
/*

$Revision: bbf1530230d5, 2753, rls $
$Author: EShklyar $
$Date: Сб фев 20 15:59:21 2021 +0300 $
$Workfile: partsxls.p $
$Archive: str/partsxls.p $

Печать партий в Excel

Автор: Чернова Светлана Александровна
Дата создания: 02/21/07
Author: Svetlana Chernova
Creation date: 02/21/07

create: Перваков Михаил Сергеевич
Дата создания: 05/22/03

*/

define input  parameter p-handle-callback as handle    no-undo .

define variable vss-revision    as character no-undo initial "$Revision: bbf1530230d5, 2753, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Сб фев 20 15:59:21 2021 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: partsxls.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/partsxls.p $":U .
define variable vss-description as character no-undo initial "Печать партий в формате EXCEL".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/waitfram.i }


DEFINE SHARED BUFFER parts FOR ub.parts .
DEFINE SHARED QUERY br-parts FOR
      parts SCROLLING.

DEFINE VARIABLE chExcelApplication      AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorkbook              AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorksheet             AS COM-HANDLE no-undo .

def var v-ind   as integer   no-undo .
def var cRow as character no-undo .
def var cRange  as character no-undo .
/*def var v-report-name as character no-undo .*/


/* create a new Excel Application object */
CREATE "Excel.Application" chExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
assign
  /* launch Excel so it is visible to the user */
  chExcelApplication:Visible = false
  /* create a new Workbook */
  chWorkbook = chExcelApplication:Workbooks:Add ()
.



assign
  /* get the active Worksheet */
  chWorkSheet = chExcelApplication:Sheets:Item (1)
  /* чтоб нельзя было уронить EXCEL при заполнении и не мигало и не тратило время на перерисовку */
  chExcelApplication:Interactive = false
  chExcelApplication:ScreenUpdating = false
  /* название на WorkSheet */
  chWorkSheet:Name = "Партии"
  /* set the column names for the Worksheet */
  chWorkSheet:Range ("A1"):Value           = "№ п/п"
  chWorkSheet:Columns ("A":U):ColumnWidth  = 7
  chWorkSheet:Columns ("A":U):NumberFormat = fill ("#", 5) + "0"
  chWorkSheet:Range ("B1"):Value           = "Тип объекта"
  chWorkSheet:Columns ("B":U):ColumnWidth  = 5
  chWorkSheet:Columns ("B":U):NumberFormat = "@"
  chWorkSheet:Range ("C1"):Value           = "Код объекта"
  chWorkSheet:Columns ("C":U):ColumnWidth  = 10
  chWorkSheet:Columns ("C":U):NumberFormat = fill ("0", 9)
  chWorkSheet:Range ("D1"):Value           = "Артикул"
  chWorkSheet:Columns ("D":U):ColumnWidth  = 20
  chWorkSheet:Columns ("D":U):NumberFormat = "@"
  chWorkSheet:Range ("E1"):Value           = "Тип производителя"
  chWorkSheet:Columns ("E":U):ColumnWidth  = 5
  chWorkSheet:Columns ("E":U):NumberFormat = "@"
  chWorkSheet:Range ("F1"):Value           = "Код производителя"
  chWorkSheet:Columns ("F":U):ColumnWidth  = 10
  chWorkSheet:Columns ("F":U):NumberFormat = fill ("0", 9)
  chWorkSheet:Range ("G1"):Value           = "Номер ПН"
  chWorkSheet:Columns ("G":U):ColumnWidth  = 10
  chWorkSheet:Columns ("G":U):NumberFormat = "@"
  chWorkSheet:Range ("H1"):Value           = "Документ"
  chWorkSheet:Columns ("H":U):ColumnWidth  = 10
  chWorkSheet:Columns ("H":U):NumberFormat = "@"
  chWorkSheet:Range ("I1"):Value           = "Код партии"
  chWorkSheet:Columns ("I":U):ColumnWidth  = 5
  chWorkSheet:Columns ("I":U):NumberFormat = "@"
  chWorkSheet:Range ("J1"):Value           = "По док."
  chWorkSheet:Columns ("J":U):ColumnWidth  = 10
  chWorkSheet:Range ("K1"):Value           = "Факт"
  chWorkSheet:Columns ("K":U):ColumnWidth  = 10
  chWorkSheet:Range ("L1"):Value           = "Цена (Б.В.)"
  chWorkSheet:Columns ("L":U):ColumnWidth  = 12
  chWorkSheet:Range ("M1"):Value           = "Цена ({&abbr_rub}.)"
  chWorkSheet:Columns ("M":U):ColumnWidth  = 12
  chWorkSheet:Range ("N1"):Value           = "Поставка"
  chWorkSheet:Columns ("N":U):ColumnWidth  = 5
  chWorkSheet:Columns ("N":U):NumberFormat = "@"
  chWorkSheet:Range ("O1"):Value           = "Тип поставщика"
  chWorkSheet:Columns ("O":U):ColumnWidth  = 5
  chWorkSheet:Columns ("O":U):NumberFormat = "@"
  chWorkSheet:Range ("P1"):Value           = "Код поставщика"
  chWorkSheet:Columns ("P":U):ColumnWidth  = 10
  chWorkSheet:Columns ("P":U):NumberFormat = fill ("0", 9)
  chWorkSheet:Range ("Q1"):Value           = "ГТД"
  chWorkSheet:Columns ("Q":U):ColumnWidth  = 10
  chWorkSheet:Columns ("Q":U):NumberFormat = "@"
  chWorkSheet:Range ("R1"):Value           = "Тип приобретения"
  chWorkSheet:Columns ("R":U):ColumnWidth  = 20
  chWorkSheet:Columns ("R":U):NumberFormat = "@"
  chWorkSheet:Range ("S1"):Value           = "Договор"
  chWorkSheet:Columns ("S":U):ColumnWidth  = 20
  chWorkSheet:Columns ("S":U):NumberFormat = "@"
  chWorkSheet:Range ("T1"):Value           = "Годен до"
  chWorkSheet:Columns ("T":U):ColumnWidth  = 20
  chWorkSheet:Columns ("T":U):NumberFormat = "@"
  chWorkSheet:Range ("U1"):Value           = "Складское место"
  chWorkSheet:Columns ("U":U):ColumnWidth  = 20
  chWorkSheet:Columns ("U":U):NumberFormat = "@"
  chWorkSheet:Range ("V1"):Value           = "НДС"
  chWorkSheet:Columns ("V":U):ColumnWidth  = 10
  chWorkSheet:Columns ("V":U):NumberFormat = "@"


  chWorkSheet:Range ("A1:V1"):Font:Bold = TRUE
  chWorkSheet:Range ("A1:V1"):Interior:ColorIndex = 35
  .

run waitfram-show
  (input "Экспорт в EXCEL. Ждите ..."
  ).

def var v-rid as recid no-undo .

assign
  v-rid = recid(parts)
  v-ind = 0
.

reposition br-parts to row 1.

do while available parts
:
  assign
    v-ind = v-ind + 1
  .

  if (v-ind modulo 10) = 0 then do:
    run waitfram-show
      (input "Экспортировано в EXCEL строк : " + string (v-ind)
      ).
  end.

  assign
    cRow = string (v-ind + 1)
    cRange = "A":U + cRow
    chWorkSheet:Range (cRange):Value = v-ind
    cRange = "B":U + cRow
    chWorkSheet:Range (cRange):Value = parts.obj-type
    cRange = "C":U + cRow
    chWorkSheet:Range (cRange):Value = parts.obj-code
    cRange = "D":U + cRow
    chWorkSheet:Range (cRange):Value = parts.artic
    cRange = "E":U + cRow
    chWorkSheet:Range (cRange):Value = parts.prod-type
    cRange = "F":U + cRow
    chWorkSheet:Range (cRange):Value = parts.prod-code
    cRange = "G":U + cRow
    chWorkSheet:Range (cRange):Value = parts.in-code
    cRange = "H":U + cRow
    chWorkSheet:Range (cRange):Value = parts.out-code
    cRange = "I":U + cRow
    chWorkSheet:Range (cRange):Value = parts.part-code
    cRange = "J":U + cRow
    chWorkSheet:Range (cRange):Value = parts.qnty
    cRange = "K":U + cRow
    chWorkSheet:Range (cRange):Value = parts.fact-qnty
    cRange = "L":U + cRow
    chWorkSheet:Range (cRange):Value = parts.price-base
    cRange = "M":U + cRow
    chWorkSheet:Range (cRange):Value = parts.price-rubl
    cRange = "N":U + cRow
    chWorkSheet:Range (cRange):Value = string(parts.is-supp, "да/нет")
    cRange = "O":U + cRow
    chWorkSheet:Range (cRange):Value = parts.supp-type
    cRange = "P":U + cRow
    chWorkSheet:Range (cRange):Value = parts.supp-code
    cRange = "Q":U + cRow
    chWorkSheet:Range (cRange):Value = parts.cst-code
    cRange = "U":U + cRow
    chWorkSheet:Range (cRange):Value = parts.pl-code
    cRange = "V":U + cRow
    chWorkSheet:Range (cRange):Value = parts.vat-pc


  .


  define variable v-purch-str as character no-undo .

  if valid-handle(p-handle-callback)
  and p-handle-callback :get-signature("purch-code-to-str") <> ""
  then do:
    run purch-code-to-str in p-handle-callback
      (input  parts.purch-code
      ,output v-purch-str
      ) .
    assign
      cRange = "R":U + cRow
      chWorkSheet:Range (cRange):Value = v-purch-str
    .
  end.

  if valid-handle(p-handle-callback)
  and p-handle-callback :get-signature("contract-code-to-str") <> ""
  then do:
    define variable v-contract-prn-code-str as character no-undo .
    run contract-code-to-str in p-handle-callback
       (input  parts.contract-code
       ,input  parts.obj-type
       ,input  parts.obj-code
       ,output v-contract-prn-code-str
      ) .

    assign
      cRange = "S":U + cRow
      chWorkSheet:Range (cRange):Value = v-contract-prn-code-str
    .
  end.

  if parts.last-date <> ?
  then do:
    assign
      cRange = "T":U + cRow
      chWorkSheet:Range (cRange):Value = string(parts.last-date, '99/99/9999':U)
    .
  end.

  get next br-parts .
end.

run waitfram-hide in this-procedure .

/* make Excel visible and enable input in it */
assign
  chExcelApplication:Interactive = true
  chExcelApplication:ScreenUpdating = true
  chExcelApplication:Visible = true
.


/*assign*/
/*  v-report-name  = chWorkbook:FullName*/
/*.*/
/*chWorkBook:Close.*/
/*chExcelApplication:Workbooks:Open(v-report-name).*/
/*assign*/
/*  chExcelApplication:ActiveWorkbook:Saved = YES*/
/*.*/

/* release com-handles */
RELEASE OBJECT chWorksheet NO-ERROR.
RELEASE OBJECT chWorkbook NO-ERROR.
chExcelApplication :QUIT().
RELEASE OBJECT  chExcelApplication  NO-ERROR.

if v-rid <> ? then do:
  reposition br-parts to recid v-rid .
end.