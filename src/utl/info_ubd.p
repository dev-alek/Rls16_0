block-level on error undo, throw.
/*

$Revision: d7ce49db94ae, 3179, rls $
$Author: VSpiridonov $
$Date: 2022/12/27 12:54:24 $
$Workfile: info_ubd.p $
$Archive: utl/info_ubd.p $

Информация о БД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 06/28/07
Author: Dmitry Ukhanov
Creation date: 06/28/07

Автор1: Румянцев Юрий Александрович
Дата создания: 04/12/04

*/

DEF VAR num AS INT NO-UNDO.
DEF VAR v-ind-1 AS INT NO-UNDO.

define variable v-ind as integer   no-undo .

{ gbl/waitfram.i }

DEFINE VARIABLE chExcelApplication      AS COM-HANDLE.
DEFINE VARIABLE chWorkbook              AS COM-HANDLE.
DEFINE VARIABLE chWorksheet             AS COM-HANDLE.

def var cColumn       as character no-undo .
def var cRange        as character no-undo .

/* define buffer buf_db-info for db-info . */

define TEMP-TABLE tt-db-info  no-undo
	field db-num                    as int 
	field area-id                   as int    
	field area-name                 as char    
	field date-info                 as date    
index pi IS PRIMARY db-num area-id area-name date-info.

.

CREATE "Excel.Application" chExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
assign
  chExcelApplication:Visible = false
  chWorkbook = chExcelApplication:Workbooks:Add ()
.

/*   Заполнение шапки колонок    */
assign
  /* get the active Worksheet */
  chWorkSheet = chExcelApplication:Sheets:Item (1)
  /* чтоб нельзя было уронить EXCEL при заполнении и не мигало и не тратило время на перерисовку */
  chExcelApplication:Interactive = false
  chExcelApplication:ScreenUpdating = false
  /* название на WorkSheet */
  chWorkSheet:Name = "Партии"
  /* set the column names for the Worksheet */
  chWorkSheet:Range ("A1"):Value           = "№ БД"
  chWorkSheet:Columns ("A":U):ColumnWidth  = 5
  chWorkSheet:Columns ("A":U):NumberFormat = fill ("#", 5) + "0"
  chWorkSheet:Range ("B1"):Value           = "№ области"
  chWorkSheet:Columns ("B":U):ColumnWidth  = 5
  chWorkSheet:Columns ("B":U):NumberFormat = "@"
  chWorkSheet:Range ("C1"):Value           = "Имя области"
  chWorkSheet:Columns ("C":U):ColumnWidth  = 15
  chWorkSheet:Columns ("C":U):NumberFormat = fill ("0", 9)
  chWorkSheet:Range ("D1"):Value           = "Имя тома"
  chWorkSheet:Columns ("D":U):ColumnWidth  = 28
  chWorkSheet:Columns ("D":U):NumberFormat = fill ("0", 7)
  chWorkSheet:Range ("E1"):Value           = "Посл. том заполнен на %"
  chWorkSheet:Columns ("E":U):ColumnWidth  = 20
  chWorkSheet:Columns ("E":U):NumberFormat = "@"
  chWorkSheet:Range ("F1"):Value           = "На дату"
  chWorkSheet:Columns ("F":U):ColumnWidth  = 10
  chWorkSheet:Columns ("F":U):NumberFormat = "@"
  chWorkSheet:Range ("A1:F1"):Font:Bold = TRUE
  chWorkSheet:Range ("A1:F1"):Interior:ColorIndex = 35
  chWorkSheet:Range ("G1"):Value           = "Время "
  chWorkSheet:Columns ("G":U):ColumnWidth  = 10
  chWorkSheet:Columns ("G":U):NumberFormat = "@"
  chWorkSheet:Range ("A1:G1"):Font:Bold = TRUE
  chWorkSheet:Range ("A1:G1"):Interior:ColorIndex = 35




  .

run waitfram-show
  (input "Экспорт в EXCEL. Ждите ..."
  ).

v-ind = 1.
FOR EACH db WHERE db.db-num > 0 NO-LOCK:
    num = ?.
    srch_first:
    DO v-ind-1 = 1 TO 365:
      FIND FIRST  db-info  WHERE
               db-info.db-num = db.db-num
          AND db-info.date-info =  TODAY - v-ind-1
          AND  db-info.volume-hiwater <> 0
      NO-LOCK NO-ERROR.
      IF AVAIL db-info THEN DO:
          num = v-ind-1.
          LEAVE srch_first.
      END.
    END.
    IF num <> ?  THEN DO:
      FOR EACH    db-info   WHERE
             db-info.db-num = db.db-num
        AND  db-info.date-info =  TODAY - v-ind-1
        AND  db-info.volume-hiwater <> 0
      NO-LOCK:

/* message '   ' db-info.db-num db-info.area-id db-info.area-name db-info.volume-name db-info.volume-percent-hiwater  ub.db-info.date-info view-as alert-box. */

        find first tt-db-info  WHERE
             tt-db-info.db-num    = db-info.db-num
        AND  tt-db-info.area-id   = db-info.area-id 
        AND  tt-db-info.area-name = db-info.area-name 
        AND  tt-db-info.date-info = db-info.date-info no-error.
        if not available (tt-db-info) then     do:
         create tt-db-info .
         assign
             tt-db-info.db-num    = db-info.db-num
             tt-db-info.area-id   = db-info.area-id 
             tt-db-info.area-name = db-info.area-name 
             tt-db-info.date-info = db-info.date-info .
         .
         end.

/*
         assign
            ccolumn = string (v-ind + 1)
            cRange = "A":U + cColumn
            chWorkSheet:Range (cRange):Value = db-info.db-num
            cRange = "B":U + cColumn
            chWorkSheet:Range (cRange):Value = db-info.area-id
            cRange = "C":U + cColumn
            chWorkSheet:Range (cRange):Value = db-info.area-name
            cRange = "D":U + cColumn
            chWorkSheet:Range (cRange):Value = db-info.volume-name
            cRange = "E":U + cColumn
            chWorkSheet:Range (cRange):Value = db-info.volume-percent-hiwater
            cRange = "F":U + cColumn
            chWorkSheet:Range (cRange):Value = ub.db-info.date-info 
            cRange = "G":U + cColumn
            chWorkSheet:Range (cRange):Value =  string(ub.db-info.time-info, "HH:MM:SS")
            v-ind = v-ind + 1

            .
         IF db-info.volume-percent-hiwater > 50 AND db-info.volume-percent-hiwater < 80 THEN DO:
             ASSIGN
                cRange = "E":U + cColumn
                chWorkSheet:Range (cRange):Interior:ColorIndex = 6
                /* 3 - красный */
                /* 6 - желтый */
             .
         END.
         ELSE IF db-info.volume-percent-hiwater > 80 THEN DO:
             ASSIGN
                cRange = "E":U + cColumn
                chWorkSheet:Range (cRange):Interior:ColorIndex = 3
             .
         END.      */

      END. /*  FOR EACH    db-info   WHERE */
    END.  /* IF num <> ?  THEN DO:  */
    /* v-ind = v-ind + 1. */
END.   /*  db    */


FOR EACH tt-db-info  NO-LOCK:
find last    ub.db-info  WHERE 
             tt-db-info.db-num    = db-info.db-num
        AND  tt-db-info.area-id   = db-info.area-id 
        AND  tt-db-info.area-name = db-info.area-name 
        AND  tt-db-info.date-info = db-info.date-info no-error.

         assign
            ccolumn = string (v-ind + 1)
            cRange = "A":U + cColumn
            chWorkSheet:Range (cRange):Value = db-info.db-num
            cRange = "B":U + cColumn
            chWorkSheet:Range (cRange):Value = db-info.area-id
            cRange = "C":U + cColumn
            chWorkSheet:Range (cRange):Value = db-info.area-name
            cRange = "D":U + cColumn
            chWorkSheet:Range (cRange):Value = db-info.volume-name
            cRange = "E":U + cColumn
            chWorkSheet:Range (cRange):Value = db-info.volume-percent-hiwater
            cRange = "F":U + cColumn
            chWorkSheet:Range (cRange):Value = ub.db-info.date-info 
            cRange = "G":U + cColumn
            chWorkSheet:Range (cRange):Value =  string(ub.db-info.time-info, "HH:MM:SS")
            v-ind = v-ind + 1

            .
         IF db-info.volume-percent-hiwater > 50 AND db-info.volume-percent-hiwater < 80 THEN DO:
             ASSIGN
                cRange = "E":U + cColumn
                chWorkSheet:Range (cRange):Interior:ColorIndex = 6
                /* 3 - красный */
                /* 6 - желтый */
             .
         END.
         ELSE IF db-info.volume-percent-hiwater > 80 THEN DO:
             ASSIGN
                cRange = "E":U + cColumn
                chWorkSheet:Range (cRange):Interior:ColorIndex = 3
             .
         END.     

end.


empty temp-table tt-db-info .
run waitfram-hide in this-procedure .

assign
  chExcelApplication:Interactive = true
  chExcelApplication:ScreenUpdating = true
  chExcelApplication:Visible = true
.

RELEASE OBJECT chWorksheet.
RELEASE OBJECT chExcelApplication.
RELEASE OBJECT chWorkbook.