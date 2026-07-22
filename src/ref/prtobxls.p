block-level on error undo, throw.
/*

$Revision: bbf1530230d5, 2753, rls $
$Author: EShklyar $
$Date: Сб фев 20 15:59:21 2021 +0300 $
$Workfile: prtobxls.p $
$Archive: ref/prtobxls.p $

Печать информации по признакам в формате EXCEL

Автор: Чернова Светлана Александровна
Дата создания: 02/21/07
Author: Svetlana Chernova
Creation date: 02/21/07

CREATE: Перваков Михаил Сергеевич
Дата создания: 09/08/03


*/


define input  parameter p-prt-ref-handle as handle    no-undo .
define input  parameter p-title          as character no-undo .
define input  parameter p-sort-label     as character no-undo .
define input  parameter p-sort-value     as character no-undo .
define input  parameter p-filter-label   as character no-undo .
define input  parameter p-filter-value   as character no-undo .

define variable vss-revision    as character no-undo initial "$Revision: bbf1530230d5, 2753, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Сб фев 20 15:59:21 2021 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: prtobxls.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: ref/prtobxls.p $":U .
define variable vss-description as character no-undo initial "Печать информации по признакам в формате EXCEL".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }


DEFINE VARIABLE chExcelApplication      AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorkbook              AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorksheet             AS COM-HANDLE no-undo .

def var cColumn       as character no-undo .
def var cRange        as character no-undo .
/*def var v-report-name as character no-undo .*/


if not valid-handle(p-prt-ref-handle)
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка задания входных параметров" skip
    "Неизвестная ссылка на программу" p-prt-ref-handle skip
    view-as alert-box error .
  undo, return error return-value .
end.


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

/*chWorkBook:SaveAs( "c:\workp\test.xls", , , , , , ) .*/

assign
  /* get the active Worksheet */
  chWorkSheet = chExcelApplication:Sheets:Item (1)
  /* чтоб нельзя было уронить EXCEL при заполнении и не мигало и не тратило время на перерисовку */
  chExcelApplication:Interactive = false
  chExcelApplication:ScreenUpdating = false
  /* название на WorkSheet */

  chWorkSheet:Name = "Признаки"
  chWorkSheet:PageSetup:PrintGridlines = TRUE
  chWorkSheet:Range ("A1"):Value           = p-title
  chWorkSheet:Range ("A1:A1"):Font:Bold = TRUE

  chWorkSheet:Range ("A2"):Value           = p-sort-label
  chWorkSheet:Range ("C2"):Value           = p-sort-value
  chWorkSheet:Range ("A3"):Value           = p-filter-label
  chWorkSheet:Range ("C3"):Value           = p-filter-value
  /* set the column names for the Worksheet */
  chWorkSheet:Range ("A4"):Value           = "№ п/п"
  chWorkSheet:Columns ("A":U):ColumnWidth  = 7
  chWorkSheet:Columns ("A":U):NumberFormat = fill ("#", 5) + "0"
  chWorkSheet:Range ("B4"):Value           = "Осн.код"
  chWorkSheet:Columns ("B":U):ColumnWidth  = 10
  chWorkSheet:Columns ("B":U):NumberFormat = fill("0", 9)
  chWorkSheet:Range ("C4"):Value           = "Признак"
  chWorkSheet:Columns ("C":U):ColumnWidth  = 30
  chWorkSheet:Columns ("C":U):NumberFormat = "@"
  chWorkSheet:Range ("D4"):Value           = "Свободно"
  chWorkSheet:Columns ("D":U):ColumnWidth  = 10
  chWorkSheet:Range ("E4"):Value           = "Факт"
  chWorkSheet:Columns ("E":U):ColumnWidth  = 10
  chWorkSheet:Range ("F4"):Value           = "Цена"
  chWorkSheet:Columns ("F":U):ColumnWidth  = 12

  chWorkSheet:Range ("A4:F4"):Font:Bold = TRUE
  chWorkSheet:Range ("A4:F4"):Interior:ColorIndex = 35
  .

run waitfram-show in this-procedure
  (input "Экспорт в EXCEL. Ждите ..."
  ).

def var v-rid as recid no-undo .


define variable v-ind as integer   no-undo .


run prt-ref_get-first in p-prt-ref-handle .

do while true
:
  define variable v-available as logical   no-undo .
  define variable v-b-code    as integer   no-undo .
  define variable v-prt-name  as character no-undo .
  define variable v-free-qnty as decimal   no-undo .
  define variable v-fact-qnty as decimal   no-undo .
  define variable v-price     as decimal   no-undo .

  run prt-ref_get-current in p-prt-ref-handle
    (output  v-available
    ,output  v-b-code
    ,output  v-prt-name
    ,output  v-free-qnty
    ,output  v-fact-qnty
    ,output  v-price
    ) .
  if v-available <> true
  then do:
    leave .
  end.

  assign
    v-ind = v-ind + 1
  .
  run waitfram-show in this-procedure
    (input substitute("Экспортировано в EXCEL строк: &1", v-ind)
    ).

  assign
    cColumn = STRING (v-ind + 4)
    cRange = "A":U + cColumn
    chWorkSheet:Range (cRange):Value = v-ind
    cRange = "B":U + cColumn
    chWorkSheet:Range (cRange):Value = v-b-code
    cRange = "C":U + cColumn
    chWorkSheet:Range (cRange):Value = v-prt-name
    cRange = "D":U + cColumn
    chWorkSheet:Range (cRange):Value = v-free-qnty
    cRange = "E":U + cColumn
    chWorkSheet:Range (cRange):Value = v-fact-qnty
    cRange = "F":U + cColumn
    chWorkSheet:Range (cRange):Value = v-price
  .


  run prt-ref_get-next in p-prt-ref-handle .

END.

run waitfram-hide in this-procedure .


/* make Excel visible and enable input in it */
assign
  chExcelApplication:Interactive = true
  chExcelApplication:ScreenUpdating = true
  chExcelApplication:Visible = true
.


/* release com-handles */
RELEASE OBJECT chWorksheet NO-ERROR.
RELEASE OBJECT chWorkbook NO-ERROR.
chExcelApplication :QUIT().
RELEASE OBJECT  chExcelApplication  NO-ERROR.
