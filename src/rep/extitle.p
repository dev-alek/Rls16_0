block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: extitle.p $
$Archive: rep/extitle.p $

ВЫВОД В EXCEL шапки листа

Автор: Чернова Светлана Александровна
Дата создания: 09/09/05
Author: Svetlana Chernova
Creation date: 09/09/05

*/

DEFINE INPUT PARAMETER current-sheet as integer no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: extitle.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/extitle.p $":U .
define variable vss-description as character no-undo init "ВЫВОД В EXCEL".
{ cmp/vssrevis.i }


{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ rep/r-gl.i }
define variable C-c as int no-undo.
define variable C-str as char no-undo.
define variable str--1 as char Format "x(60)" no-undo.
define variable C-i as int no-undo.
define variable M        AS INTEGER no-undo.
define variable L        AS INTEGER no-undo.
define variable iColumn  AS INTEGER no-undo.
define variable cColumn  AS CHARACTER no-undo.
define variable cRange   AS CHARACTER no-undo.
define variable cRange2  AS CHARACTER no-undo.
define variable g#report-num as integer no-undo .

define variable AllCol   AS Int no-undo.
DEFINE VARIABLE v-bas-file as character no-undo .

IF Make-Excel THEN DO:
  IF NOT Make-Excel-com THEN DO:
    FIND FIRST sheetf NO-LOCK WHERE
                sheetf.sheet-num = current-sheet No-ERROR.
    if not avail sheetf then do:
      message vss-workfile vss-revision vss-description skip
        "Отсутствуют параметры форматирования для листов книги Excel"
      view-as alert-box error.
      return.
    end.

    C-str= ReportNAme + {&new-line} + str1
                       + {&new-line} + str2
                       + {&new-line} + str3
                       + {&new-line} + str4
                       + {&new-line} + ReportHeader .
    C-str = replace(c-str, ({&new-line} + {&new-line}), {&new-line}).

    PUT stream FORExcel UNFORMATTED   C-str skip.

    sheetf.Excel-Row-Heder =  NUM-ENTRIES(C-str ,{&new-line}) + 1.

    sheetf.Excel-Row-Title =  NUM-ENTRIES(sheetf.Excel-Column-Lable ,{&new-line}).
    Repeat C-c = 1 to sheetf.Excel-Row-Title :
      Repeat C-i = 1 to NUM-ENTRIES(Entry(c-c,sheetf.Excel-Column-Lable,{&new-line}), {&comma-char}) :
        str--1 = Entry( C-i ,Entry(c-c,sheetf.Excel-Column-Lable,{&new-line}), {&comma-char}).
        Put stream ForExcel UNFORMATTED
                    Trim(Str--1)  Format "x(60)"
                  {&tabulation}  .
      End.
      C-i = 0.
      Put stream ForExcel UNFORMATTED skip.
    End.
    /*перепишем в нужное место bas-file*/
    if Sheetf.Bas-FIle <> "":U then do:
      run get-report-num in my-handle (output G#report-num).
      assign
      v-bas-file = string( session:temp-directory) +
                   string( g#report-num)  + ".b8s":U + string(current-sheet)
      .
      define variable v-full-path        as character no-undo .
      define variable v-path             as character no-undo .
      define variable v-file-name        as character no-undo .
      define variable v-file-name-no-ext as character no-undo .
      define variable v-file-name-ext    as character no-undo .

      run gbl/filename.p
        (input  Sheetf.Bas-file
        ,output v-full-path
        ,output v-path
        ,output v-file-name
        ,output v-file-name-no-ext
        ,output v-file-name-ext
        ) no-error  .

      run gbl/fileattr.p
      (input v-bas-file
      ,input "readonly-clear"
      ) no-error .

      OS-delete value(v-bas-file).
      OS-COPY value(v-full-path) value(v-bas-file).
      if os-error <> 0 or search(v-bas-file) = ? then do:
        assign
        Sheetf.Bas-file = "":U
        .
      end.
      else do:
        assign
        Sheetf.Bas-file = v-bas-file
        .
      end.
    end.
  END. /*IF NOT Make-Excel-com*/
End.

IF Make-Excel THEN DO:
  IF Make-Excel-com THEN DO:
     C-str= ReportNAme + {&new-line} + str1
                       + {&new-line} + str2
                       + {&new-line} + str3
                       + {&new-line} + str4
                       + {&new-line} + ReportHeader .
    sheetf.Excel-Row-Heder =  NUM-ENTRIES(C-str ,{&new-line} ).
    sheetf.Excel-Row-Title =  NUM-ENTRIES(sheetf.Excel-Column-Lable ,{&new-line} ).

  { rep/putexcel.i  ReportNAme  1 }
  { rep/putexcel.i  str1        1 }
  { rep/putexcel.i  str2        1 }
  { rep/putexcel.i  str3        1 }
  { rep/putexcel.i  str4        1 }

     Repeat C-c = 1 to sheetf.Excel-Row-Title :
        Repeat C-i = 1 to NUM-ENTRIES(Entry(c-c,sheetf.Excel-Column-Lable,{&new-line}), {&comma-char}) :
            str--1 = Entry( C-i ,Entry(c-c,sheetf.Excel-Column-Lable,{&new-line}), {&comma-char}).
                    { rep/putexcel.i  Trim(Str--1)  C-i }
        End.
        C-i = 0.
     End.

  AllCol = NUM-ENTRIES(Sizes) - 1 no-error.
  iF  AllCol > 1 THEN DO :
  /*форматирование ширины*/
    repeat l = 1 TO  NUM-ENTRIES(Sizes) :
     Assign
          ch#WorkSheet:Columns (Col-name[L]):ColumnWidth  = Integer(Entry(L,Sizes))
          ch#WorkSheet:Columns (Col-name[L]):NumberFormat = "@":U no-error.
    End.
        sheetf.Excel-Row-Heder =  6.
       /* До шапки */
   REPEAT L = 1 TO  sheetf.Excel-Row-Heder - 1  :
       cRange = "A" + String(L) + {&colon-char} + Col-name[AllCol + 1] + string(L) no-error.
       ch#WorkSheet:Range (cRange):MergeCells = True no-error.
       if L > 1 Then DO:
          ch#WorkSheet:Range (cRange):Font:Bold = false no-error.
          ch#WorkSheet:Range (cRange):Font:Size = 10    no-error.
          ch#WorkSheet:Range (cRange):HorizontalAlignment = {&xlLeft}  no-error.
          ch#WorkSheet:Range (cRange):VerticalAlignment = {&xlTop}     no-error.
       End.
   End.

  /* ШАПКА */
    repeat M = sheetf.Excel-Row-Heder TO sheetf.Excel-Row-Heder + sheetf.Excel-Row-Title - 2 :
        /* Склеивание колонок */
        repeat l = 2 TO ALLCOL :
           IF  ch#workSheet:Range (Col-name[L] + STRING(M)):value = "" THEN DO:
               ch#workSheet:Range (Col-name[L] + STRING(M)):value = ? .
               ch#workSheet:Range (Col-name[L - 1] + STRING(M) + {&colon-char} + Col-name[L] + STRING(M)):MergeCells = True no-error.
           End.
        END.
    End.

     If Excel-Row-Title > 1 Then DO:
        repeat M = Excel-Row-Heder + 1 TO Excel-Row-Heder + Excel-Row-Title - 1 :
          repeat l = 1 TO ALLCOL :
          /* Склеивание колонок */
            IF  ch#workSheet:Range (Col-name[L] + STRING(M)):value = ""
                OR ch#workSheet:Range (Col-name[L] + STRING(M)):value = ? THEN DO :
            ch#workSheet:Range (Col-name[L] + STRING(M)):value =  ?  no-error.
            ch#workSheet:Range (Col-name[L] + STRING(M) + {&colon-char} + Col-name[L] + STRING(M - 1)):MergeCells = True no-error.
            End.
          End.
        End.
     End.
   ASSIGN
   cRange = "A" + STRING(Excel-Row-Heder) + {&colon-char} + Col-name[AllCol + 1] + STRING(Excel-Row-Heder + Excel-Row-Title - 1)
   ch#workSheet:Range (cRange):Font:Bold = TRUE
   ch#workSheet:Range (cRange):Interior:ColorIndex = 35
   ch#workSheet:Range (cRange):HorizontalAlignment = {&xlCenter}
   ch#workSheet:Range (cRange):VerticalAlignment   = {&xlTop}
   ch#workSheet:Range (cRange):WrapText = true
   ch#workSheet:Range (cRange):Orientation = 0 no-error.
/* Бордюр */
   Assign
   ch#workSheet:Range (cRange):Borders({&xlDiagonalDown}):LineStyle = {&xlNone}
   ch#workSheet:Range (cRange):Borders({&xlDiagonalUp}):LineStyle   = {&xlNone}

   ch#workSheet:Range (cRange):Borders({&xlEdgeLeft}):LineStyle  = {&xlContinuous}
   ch#workSheet:Range (cRange):Borders({&xlEdgeLeft}):Weight     = {&xlThin}
   ch#workSheet:Range (cRange):Borders({&xlEdgeLeft}):ColorIndex = {&xlAutomatic}

   ch#workSheet:Range (cRange):Borders({&xlEdgeTop}):LineStyle  = {&xlContinuous}
   ch#workSheet:Range (cRange):Borders({&xlEdgeTop}):Weight     = {&xlThin}
   ch#workSheet:Range (cRange):Borders({&xlEdgeTop}):ColorIndex = {&xlAutomatic}

   ch#workSheet:Range (cRange):Borders({&xlEdgeBottom}):LineStyle  = {&xlContinuous}
   ch#workSheet:Range (cRange):Borders({&xlEdgeBottom}):Weight     = {&xlThin}
   ch#workSheet:Range (cRange):Borders({&xlEdgeBottom}):ColorIndex = {&xlAutomatic}

   ch#workSheet:Range (cRange):Borders({&xlEdgeRight}):LineStyle  = {&xlContinuous}
   ch#workSheet:Range (cRange):Borders({&xlEdgeRight}):Weight     = {&xlThin}
   ch#workSheet:Range (cRange):Borders({&xlEdgeRight}):ColorIndex = {&xlAutomatic}

   ch#workSheet:Range (cRange):Borders({&xlInsideVertical}):LineStyle  = {&xlContinuous}
   ch#workSheet:Range (cRange):Borders({&xlInsideVertical}):Weight     = {&xlThin}
   ch#workSheet:Range (cRange):Borders({&xlInsideVertical}):ColorIndex = {&xlAutomatic} no-error.
   IF Excel-Row-Title > 1 THEN
   Assign
   ch#workSheet:Range (cRange):Borders({&xlInsideHorizontal}):LineStyle  = {&xlContinuous}
   ch#workSheet:Range (cRange):Borders({&xlInsideHorizontal}):Weight     = {&xlThin}
   ch#workSheet:Range (cRange):Borders({&xlInsideHorizontal}):ColorIndex = {&xlAutomatic}
   ch#workSheet:PageSetup:PrintTitleRows = cRange

   no-error
  .

    End.
   end.
  End.