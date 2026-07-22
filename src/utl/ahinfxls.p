block-level on error undo, throw.
/*

$Revision: bbf1530230d5, 2753, rls $
$Author: EShklyar $
$Date: Сб фев 20 15:59:21 2021 +0300 $
$Workfile: ahinfxls.p $
$Archive: utl/ahinfxls.p $

Печать информации по складским архивам по товарам, по поставщикам, по типам приобретени

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 10/20/03

*/

define input  parameter p-ah-infov-handle as handle    no-undo .

define variable vss-revision    as character no-undo initial "$Revision: bbf1530230d5, 2753, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Сб фев 20 15:59:21 2021 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: ahinfxls.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/ahinfxls.p $":U .
define variable vss-description as character no-undo initial "Печать информации по складским архивам по товарам, по поставщикам, по типам приобретени".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }

DEFINE VARIABLE chExcelApplication      AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorkbook              AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorksheet             AS COM-HANDLE no-undo .

define variable cColumn       as character no-undo .
define variable cRange        as character no-undo .
/*define variable v-report-name as character no-undo .*/


if not valid-handle(p-ah-infov-handle)
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка задания входных параметров" skip
    "Неизвестная ссылка на программу" p-ah-infov-handle skip
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
  chWorkSheet:PageSetup:PrintGridlines     = TRUE
  chWorkSheet:Range ("A1"):Value           = "Архивы на объектах"
  chWorkSheet:Range ("A1:A1"):Font:Bold    = TRUE

  /* задать заголовки и форматы колонок */
  chWorkSheet:Range ("A2"):Value           = "Номер БД"
  chWorkSheet:Columns ("A":U):ColumnWidth  = 7
  chWorkSheet:Columns ("A":U):NumberFormat = fill ("#", 5) + "0"
  chWorkSheet:Range ("B2"):Value           = "Объект"
  chWorkSheet:Columns ("B":U):ColumnWidth  = 7
  chWorkSheet:Columns ("B":U):NumberFormat = "@"
  chWorkSheet:Range ("C2"):Value           = "Тип"
  chWorkSheet:Columns ("C":U):ColumnWidth  = 10
  chWorkSheet:Columns ("C":U):NumberFormat = "@"
  chWorkSheet:Range ("D2"):Value           = "Не рассчитан оборот"
  chWorkSheet:Columns ("D":U):ColumnWidth  = 5
  chWorkSheet:Columns ("D":U):NumberFormat = "@"
  chWorkSheet:Range ("E2"):Value           = "Не рассчитан нач.остаток"
  chWorkSheet:Columns ("E":U):ColumnWidth  = 5
  chWorkSheet:Columns ("E":U):NumberFormat = "@"
  chWorkSheet:Range ("F2"):Value           = "Расчет архива выключен"
  chWorkSheet:Columns ("F":U):ColumnWidth  = 5
  chWorkSheet:Columns ("F":U):NumberFormat = "@"
  chWorkSheet:Range ("G2"):Value           = "Сбой удал./восст."
  chWorkSheet:Columns ("G":U):ColumnWidth  = 5
  chWorkSheet:Columns ("G":U):NumberFormat = "@"
  chWorkSheet:Range ("H2"):Value           = "Задания на расчет"
  chWorkSheet:Columns ("H":U):ColumnWidth  = 5
  chWorkSheet:Columns ("H":U):NumberFormat = "@"
  chWorkSheet:Range ("I2"):Value           = "Подробный"
  chWorkSheet:Columns ("I":U):ColumnWidth  = 10
  chWorkSheet:Columns ("I":U):NumberFormat = "@"
  chWorkSheet:Range ("J2"):Value           = "Сжатый"
  chWorkSheet:Columns ("J":U):ColumnWidth  = 10
  chWorkSheet:Columns ("J":U):NumberFormat = "@"
  chWorkSheet:Range ("K2"):Value           = "Перерасчет"
  chWorkSheet:Columns ("K":U):ColumnWidth  = 10
  chWorkSheet:Columns ("K":U):NumberFormat = "@"


  chWorkSheet:Range ("A2:K2"):Font:Bold = TRUE
  chWorkSheet:Range ("A2:K2"):Interior:ColorIndex = 35
  .

run waitfram-show in this-procedure
  (input "Экспорт в EXCEL. Ждите ..."
  ).

define variable v-rid as recid no-undo .


define variable v-ind as integer   no-undo .


run ah-infov_get-first in p-ah-infov-handle .

do while true
:
  define variable v-available                as logical   no-undo .
  define variable v-db-num                   as integer   no-undo .
  define variable v-obj-type                 as character no-undo .
  define variable v-obj-code                 as integer   no-undo .
  define variable v-archive-type             as character no-undo .
  define variable v-deleted                  as logical   no-undo .
  define variable v-archive-calc             as logical   no-undo .
  define variable v-archive-del              as logical   no-undo .
  define variable v-archive-disable          as logical   no-undo .
  define variable v-archive-rest             as logical   no-undo .
  define variable v-archive-bpexist          as logical   no-undo .
  define variable v-archive-detail-date      as date      no-undo .
  define variable v-archive-start-date       as date      no-undo .
  define variable v-archive-date-recalc      as date      no-undo .
  define variable v-archive-lock-prc         as logical   no-undo .
  define variable v-archive-execuser         as character no-undo .
  define variable v-archive-execsysdate      as date      no-undo .
  define variable v-archive-execsystime      as character no-undo .
  define variable v-archive-rest-lock-prc    as logical   no-undo .
  define variable v-archive-rest-execuser    as character no-undo .
  define variable v-archive-rest-execsysdate as date      no-undo .
  define variable v-archive-rest-execsystime as character no-undo .

  define variable v-archive-type-name     as character no-undo .

  run ah-infov_get-current in p-ah-infov-handle
    (output v-available                /* p-available                */
    ,output v-db-num                   /* p-db-num                   */
    ,output v-obj-type                 /* p-obj-type                 */
    ,output v-obj-code                 /* p-obj-code                 */
    ,output v-archive-type             /* p-archive-type             */
    ,output v-deleted                  /* p-obj-deleted              */
    ,output v-archive-calc             /* p-archive-calc             */
    ,output v-archive-del              /* p-archive-del              */
    ,output v-archive-disable          /* p-archive-disable          */
    ,output v-archive-rest             /* p-archive-rest             */
    ,output v-archive-bpexist          /* p-archive-bpexist          */
    ,output v-archive-detail-date      /* p-archive-detail-date      */
    ,output v-archive-start-date       /* p-archive-start-date       */
    ,output v-archive-date-recalc      /* p-archive-recalc-date      */
    ,output v-archive-lock-prc         /* p-archive-lock-prc         */
    ,output v-archive-execuser         /* p-archive-execuser         */
    ,output v-archive-execsysdate      /* p-archive-execsysdate      */
    ,output v-archive-execsystime      /* p-archive-execsystime      */
    ,output v-archive-rest-lock-prc    /* p-archive-rest-lock-prc    */
    ,output v-archive-rest-execuser    /* p-archive-rest-execuser    */
    ,output v-archive-rest-execsysdate /* p-archive-rest-execsysdate */
    ,output v-archive-rest-execsystime /* p-archive-rest-execsystime */
    ) .
  if v-available <> true
  then do:
    leave .
  end.

  run ah-infov_archive-type-name-proc in p-ah-infov-handle
    (input  v-archive-type
    ,output v-archive-type-name
    ) .

  assign
    v-ind = v-ind + 1
  .
  run waitfram-show in this-procedure
    (input substitute("Экспортировано в EXCEL строк: &1", v-ind)
    ).

  assign
    cColumn = STRING (v-ind + 2)
    cRange = "A":U + cColumn
    chWorkSheet:Range (cRange):Value = v-db-num
    cRange = "B":U + cColumn
    chWorkSheet:Range (cRange):Value = substitute("&1 &2", v-obj-type, v-obj-code)
    cRange = "C":U + cColumn
    chWorkSheet:Range (cRange):Value = v-archive-type-name
    cRange = "D":U + cColumn
    chWorkSheet:Range (cRange):Value = string(v-archive-calc, '+/-':u)
    cRange = "E":U + cColumn
    chWorkSheet:Range (cRange):Value = string(v-archive-del, '+/-':u)
    cRange = "F":U + cColumn
    chWorkSheet:Range (cRange):Value = string(v-archive-disable, '+/-':u)
    cRange = "G":U + cColumn
    chWorkSheet:Range (cRange):Value = string(v-archive-rest, '+/-':u)
    cRange = "H":U + cColumn
    chWorkSheet:Range (cRange):Value = string(v-archive-bpexist, '+/-':u)
    cRange = "I":U + cColumn
    chWorkSheet:Range (cRange):Value = string(v-archive-detail-date, '99/99/9999':u)
    cRange = "J":U + cColumn
    chWorkSheet:Range (cRange):Value = string(v-archive-start-date, '99/99/9999':u)
    cRange = "K":U + cColumn
    chWorkSheet:Range (cRange):Value = string(v-archive-date-recalc, '99/99/9999':u)
  .

  run ah-infov_get-next in p-ah-infov-handle .

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