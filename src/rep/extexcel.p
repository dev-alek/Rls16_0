block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: extexcel.p $
$Archive: rep/extexcel.p $

Вывод в Excel

Автор: Чернова Светлана Александровна
Дата создания: 03/06/06
Author: Svetlana Chernova
Creation date: 03/06/06


*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: extexcel.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/extexcel.p $":U .
define variable vss-description as character no-undo init "Вывод в Excel".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page0.i new }
{ gbl/waitfram.i }


define variable mm               as integer   no-undo .
define variable ll               as integer   no-undo .
define variable icolumn          as integer   no-undo .
define variable ccolumn          as character no-undo .
define variable crange           as character no-undo .
define variable crange2          as character no-undo .
define variable allcol           as integer   no-undo .
define variable colrule          as character no-undo .
define variable linerule         as character no-undo .
define variable ii               as integer   no-undo .
define variable kk               as integer   no-undo .
define variable lastsheet        as integer   no-undo .
define variable num-sheets       as integer   no-undo .
define variable real-num-sheets  as integer   no-undo .
define variable for-name         as character no-undo .
define variable cell-value       as character no-undo .
define variable ch#com-handle    as com-handle no-undo .
define variable ch#range         as com-handle no-undo .
define variable ch#columns       as com-handle no-undo .
define variable ch#sheets        as com-handle no-undo .
define variable ch#firstsheet    as com-handle no-undo .
define variable ch#zeroworkbook as com-handle no-undo .
define variable first-step       as logical   no-undo .
define variable current-address  as character no-undo .
define variable old-address      as character no-undo .
define variable current-row      as integer   no-undo .
define variable my-address       as character no-undo .
define variable my-address1      as character no-undo .
define variable found-next-sheet as logical   no-undo .
define variable tempfile-xls     as character no-undo .
define variable tempfile-frm     as character no-undo .
define variable tempfile-full    as character no-undo .
define variable my-excel         as logical   no-undo .
define variable is-open          as logical   no-undo .
define variable for-dir          as character no-undo .
define variable loc#log          as logical   no-undo .
define variable res              as character no-undo .
define variable p-param          as character no-undo .
define variable tempfile         as character no-undo .
define variable tempfile-n       as character no-undo .
define variable err-file         as character no-undo .
DEFINE VARIABLE v-ii             as integer no-undo .
DEFINE VARIABLE v-col-num        as integer no-undo .
DEFINE VARIABLE v-dec-separ      as character no-undo .
DEFINE VARIABLE v-th-separ       as character no-undo .
DEFINE VARIABLE v-module-lines   as integer   no-undo .
DEFINE VARIABLE v-ins-PostFormat as logical no-undo   .
DEFINE VARIABLE v-stroka         as character no-undo .
DEFINE VARIABLE v-call-bas       as logical no-undo .
DEFINE VARIABLE v-main-macro-lines as integer no-undo .
define variable v-excel-general-format as character no-undo .
define variable v-excel-short-date as character no-undo .
define variable v-excel-dec-separ as character no-undo .
define variable v-excel-th-separ as character no-undo .
define variable v-excel-date-separ as character no-undo .
define variable v-is-data-format as logical no-undo .
define variable v-col-format as character no-undo .
define variable v-zero-count as integer no-undo .
define variable v-workbook-name as character no-undo .
define variable v-worksheet-name as character no-undo .
define variable v-count as integer no-undo .
define variable v-version as character no-undo .
define variable v-version-dec as decimal no-undo .
define variable v-found-reg-entry as logical no-undo .
define variable v-trusted as character no-undo .
define variable v-bas-param-addition as character no-undo .
define variable v-silent-mode as logical   no-undo .

&scop xlNormal -4143
&scop xlgeneralformatname 26

define stream forformat .
define stream BasStream.
function fieldinfo-datef returns character (input p-format  as character) FORWARD.
function compare-data-format returns logical (input p-format  as character, input p-ex-fi as character, output p-is-data as logical) FORWARD.

define buffer buf_sheetf for sheetf .

do
on error undo, return error return-value
:
  assign
    p-param = session :parameter
  .
  if num-entries(p-param) <> 5 then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный вызов процедуры форматирования EXCEL в дополнительной сессии PROGRESS" skip
      "Неверное количество параметров" num-entries(p-param) skip
      "Параметры" p-param skip
      view-as alert-box error.
    run write-err in this-procedure (input yes) .
    quit .
  end.

  assign
    tempfile       = entry(1, p-param)
    err-file       = entry(2, p-param)
    make-excel     = lookup(entry(3, p-param), "yes,true":U) > 0
    make-excel-com = lookup(entry(4, p-param), "yes,true":U) > 0
    tempfile-frm   = entry(5, p-param)
  .

  /* проверка входных параметров */
  if make-excel <> true then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неверное значение параметра" "make-excel" skip
      "tempfile"        tempfile skip
      "err-file"        err-file skip
      "make-excel"      make-excel skip
      "make-excel-com"  make-excel-com skip
      "tempfile-frm"    tempfile-frm skip
      view-as alert-box error .
    run Write-err in this-procedure (input yes) .
    quit.
  end.

  if make-excel-com <> false then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неверное значение параметра" "make-excel-com" skip
      "tempfile"        tempfile skip
      "err-file"        err-file skip
      "make-excel"      make-excel skip
      "make-excel-com"  make-excel-com skip
      "tempfile-frm"    tempfile-frm skip
      view-as alert-box error .
    run Write-err in this-procedure (input yes) .
    quit.
  end.
  /* импорт параметров форматирования */
  run make-sheetf in this-procedure no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при чтении параметров форматирования из файла" skip
      "Файл параметров форматирования" tempfile-frm skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    run Write-err in this-procedure (input yes) .
    quit.
  end.

  input stream forformat close.

  if make-excel = true then do:
    if make-excel-com = false then do:

      define variable v-full-path        as character no-undo .
      define variable v-path             as character no-undo .
      define variable v-file-name        as character no-undo .
      define variable v-file-name-no-ext as character no-undo .
      define variable v-file-name-ext    as character no-undo .

      run gbl/filename.p
        (input  tempfile
        ,output v-full-path
        ,output v-path
        ,output v-file-name
        ,output v-file-name-no-ext
        ,output v-file-name-ext
        ) .

      assign
        tempfile-xls   = v-file-name-no-ext + '.':u + 'xls':u
        for-dir        = ""
      .
      find first buf_sheetf
        where buf_sheetf.sheet-num = 1
      no-error .
      if available buf_sheetf
      then do:
        if buf_sheetf.silent-save = yes
        then do:
          assign
            tempfile-xls  = buf_sheetf.file-name
            loc#log       = yes
            v-silent-mode = yes
          .
        end.
        else do:
          run gbl/d-file.p
            (input-output tempfile-xls            /* p-file-id           */
            ,input-output for-dir                 /* p-file-directory    */
            ,input  (" Все файлы EXCEL (*.xls) ") /* p-filter-names      */
            ,input  ("*.xls":U)                   /* p-filter-values     */
            ,input  {&comma-char}                 /* p-filter-delimiter  */
            ,input  (".xls":U)                    /* p-default-extension */
            ,input  no                            /* p-must-exist        */
            ,input  yes                           /* p-save-as           */
            ,input  yes                           /* p-use-filename      */
            ,input  "Введите имя файла"           /* p-title             */
            ,output loc#log                       /* p-choose            */
            ) .
        end.
      end.
      else do:
        run gbl/d-file.p
          (input-output tempfile-xls            /* p-file-id           */
          ,input-output for-dir                 /* p-file-directory    */
          ,input  (" Все файлы EXCEL (*.xls) ") /* p-filter-names      */
          ,input  ("*.xls":U)                   /* p-filter-values     */
          ,input  {&comma-char}                 /* p-filter-delimiter  */
          ,input  (".xls":U)                    /* p-default-extension */
          ,input  no                            /* p-must-exist        */
          ,input  yes                           /* p-save-as           */
          ,input  yes                           /* p-use-filename      */
          ,input  "Введите имя файла"           /* p-title             */
          ,output loc#log                       /* p-choose            */
          ) .
      end.
      if not loc#log then do:
        run write-err in this-procedure (input no) .
        quit.
      end.
      run waitfram-show in this-procedure ("Ждите! Идет форматирование файла...").
      { cmp/relescom.i ch#ExcelApplication }
      CREATE "Excel.Application" ch#ExcelApplication no-error.
      my-excel = yes.
      if error-status:error then DO:
        run clearexcel in this-procedure .
        run write-err in this-procedure (input yes) .
        run write-err in this-procedure (input yes) .
        quit.
      End.
      assign
      ch#ExcelApplication:Interactive = no
      ch#ExcelApplication:ScreenUpdating = no
      ch#ExcelApplication:Visible = no
      v-version = ch#ExcelApplication:version
      no-error
      .
      assign
      v-version-dec = decimal(v-version)
      no-error .
      if error-status:error then do:
        message
        "Не удалось определить версию Excel"
        view-as alert-box error .
        run clearexcel in this-procedure .
        run write-err in this-procedure (input yes) .
        run write-err in this-procedure (input yes) .
        quit.
      end.
      if v-version-dec > 9 then do:
        run gbl/getregvl.p
                        ( "HKEY_CURRENT_USER":U
                        , "SOFTWARE":U
                        , "Microsoft\Office\" + string(v-version-dec, ">9.9":U) + "\Excel\Security":U
                        , "AccessVBOM":U
                        , output v-found-reg-entry
                        , OUTPUT v-trusted) no-error .
        if error-status:error then do:
          message
          "Не удалось определить политику безопасности для данной версии Excel"
          view-as alert-box error .
          run clearexcel in this-procedure .
          run write-err in this-procedure (input yes) .
          run write-err in this-procedure (input yes) .
          quit.
        end.
        if not v-found-reg-entry
        or trim(v-trusted) = "0":U then do:
          message
          "На Вашей машине запрещен программный доступ к VisualBasicProject" skip
          "В связи с этим вывод в EXCEL невозможен" skip
          "возможное решение проблемы:" skip
          "открыть в EXCEL диалог <Сервис\Макрос\Безопасность> (<Tools\Macro\Security>)" skip
          "выбрать закладку <Надежные источники> (<Trusted Sources>)  и включить галочку" skip
          "<Доверять доступ Visual Basic Project> (<Trust access to Visual Basic Project>)" skip
          "Затем закрыть Excel"
          view-as alert-box ERROR.
          run clearexcel in this-procedure .
          run write-err in this-procedure (input yes) .
          run write-err in this-procedure (input yes) .
          quit.
        end.
      end.

      assign
      v-excel-general-format =  ch#ExcelApplication:International(26 /*xlGeneralFormatName*/ )
      v-excel-short-date =  ch#ExcelApplication:International(32 /*xlDateOrder*/ )
      v-excel-dec-separ = ch#ExcelApplication:International(3 /*xlDecimalSeparator*/ )
      v-excel-th-separ = ch#ExcelApplication:International(4 /*xlThousandsSeparator*/ )
      v-excel-date-separ = ch#ExcelApplication:International(17 /*xlDateSeparator*/ )
      /*
      0 = month-day-year
      1 = day-month-year
      2 = year-month-day
      */
      no-error
      .

      { cmp/relescom.i ch#Workbook }
      case SESSION:NUMERIC-FORMAT:
        when "American":U then do:
          assign
          v-dec-separ = ".":U
          v-th-separ = "":U
          .
        end.
        when "European":U then do:
          assign
          v-dec-separ = ",":U
          v-th-separ = "":U
          .
        end.
      END CASE.
      { cmp/relescom.i ch#Workbook }

      ch#Workbook  = ch#ExcelApplication:Workbooks:add.
      { cmp/relescom.i ch#zeroworkbook }
      assign
      v-zero-count = ch#ExcelApplication:Workbooks:Count()
      ch#zeroworkbook  = ch#ExcelApplication:Workbooks:Item(v-zero-count)
      .
      assign
      num-sheets = 0
      .
      _sheets:
      DO WHILE num-sheets < 257:
        assign
        num-sheets = num-sheets + 1
        .
        FIND FIRST  sheetf no-lock where
                    sheetf.sheet-num = num-sheets no-error.
        if num-sheets = 1 and not available sheetf then do:
          FIND FIRST  sheetf no-lock where
                      sheetf.sheet-num = 0 no-error.
        end.
        if not available sheetf then NEXT _sheets.
        if num-sheets > 1 then do:
          assign
          tempfile-n = right-trim(tempfile, "txt":U)
          tempfile-n = right-trim(tempfile-n, ".")
          tempfile-n = tempfile-n + ".":U + string(num-sheets)
          .
        end.
        else do:
          assign
          tempfile-n = tempfile
          .
        end.
        assign
        v-stroka = entry(1, sheetf.ColFOrmat, {&delim-par})
        .
        v-stroka = trim(v-stroka, ";":U) .
        do v-ii = 1 to num-entries(v-stroka, ";":U):
          assign
          v-col-num = integer(entry(1, entry(v-ii, v-stroka, ";":U), "=":U))
          Col-Format[v-col-num] = entry(2, entry(v-ii, v-stroka, ";":U), "=":U)
          .
        end.
        if search(tempfile-n) = ?
        or (avail sheetf and sheetf.Sizes = "":U)
        then NEXT _sheets.
        assign
        real-num-sheets = real-num-sheets + 1
        .
        { cmp/relescom.i ch#zeroworkbook }
        assign
        ch#zeroworkbook = ch#ExcelApplication:Workbooks:Item(v-zero-count)
        .
        ch#zeroworkbook:activate().
        run OpenFileFromtMacro in this-procedure ( input tempfile-n
                                                  ,input v-dec-separ) no-error .
        if error-status:error then do:
          run clearexcel in this-procedure .
          run write-err in this-procedure (input yes) .
          run write-err in this-procedure (input yes) .
          quit.
        end.

        { cmp/relescom.i ch#Workbook }
        assign
        ch#Workbook  = ch#ExcelApplication:Workbooks:Item(v-zero-count + 1)
        .
        { cmp/relescom.i ch#Sheets }
        ch#sheets = ch#ExcelApplication:Sheets.
        { cmp/relescom.i ch#WorkSheet }
        ch#WorkSheet = ch#SHeets:Item (1) no-error .
        for-name = ch#Sheets:Item(1):Name.
        ch#Sheets:Item(1):Name= string(num-sheets).

        /*попробуем поделить весь excel вывод на листы*/
        lastsheet = ch#Sheets:Count().
        /*пока очевидно lastsheet = 1*/
        run InsertMacroExcel .

        my-address = col-name[1] + string(1).
        { cmp/relescom.i ch#Range }
        assign
        ch#Range = ch#WorkSheet:Range (my-address)
        cell-value  = ch#Range:value.
        if not avail sheetf and NOT
        (cell-value = {&excel-page-char} OR
        cell-value = ? OR cell-value = "")
        then do:
          message vss-workfile vss-revision vss-description skip
                  "Отсутствуют параметры форматирования для листа " num-sheets "книги Excel" cell-value
          view-as alert-box ERROR.
          run ClearExcel in this-procedure .
          run Write-err in this-procedure (input yes) .
          quit.
        end.
        /*разберем формат колонок*/
        if num-entries(sheetf.COlFOrmat, {&delim-par}) > 1 then do:
          /*для этой книги еще на создали макрос пост-форматирования*/
          assign
          v-stroka = entry(2, sheetf.ColFOrmat, {&delim-par})
          .
          if not v-ins-PostFormat then do:
            run InsertPostFormatting in this-procedure (output v-module-lines) no-error .
            if not error-status:error then
            assign
            v-ins-PostFormat = yes
            .
          end.
          do v-ii = 1 to num-entries(v-stroka, ";":U):
            assign
            v-col-num = integer(entry(1, entry(v-ii, v-stroka, ";":U), "=":U))
            Col-Post-Format[v-col-num] = entry(2, entry(v-ii, v-stroka, ";":U), "=":U)
            .
          end.
        end.
        AllCol = NUM-ENTRIES(sheetf.Sizes) - 1 no-error.
        ch#WorkSheet:Cells:SpecialCells(11 /*xlCellTypeLastCell*/):Activate().
        iF  AllCol > 0 THEN DO:
          { cmp/relescom.i ch#Range }
          assign
          ch#range = ch#WorkSheet:Range ("A1")
          ch#Range:Font:Bold = TRUE .
          ch#Range:Font:Size = 14   .
          ch#Range:HorizontalAlignment = {&xlLeft} .
          ch#Range:VerticalAlignment   = {&xlTop}  .
          /*форматирование ширины*/
          do ll = 1 TO  NUM-ENTRIES(Sheetf.Sizes) :
            { cmp/relescom.i ch#COlumns }
            if Col-Format[ll] = ?
            OR Col-Format[ll] = "":U then do:
              assign
              v-col-format = v-excel-general-format
              .
            end.
            else do:
              if compare-data-format(COl-format[ll], input v-excel-short-date, output v-is-data-format)
              OR not v-is-data-format then do:
                assign
                v-col-format = Col-Format[ll]
                .
                if v-col-format begins "0.0" then do:
                  v-col-format = replace(v-col-format, ".", v-excel-dec-separ).
                end.
              end.
              else do:
                assign
                v-col-format = ?
                .
              end.
            end.
            Assign
            ch#COlumns = ch#WorkSheet:Columns (Col-name[LL])
            ch#Columns:ColumnWidth  = min(120, Integer(Entry(LL,Sheetf.Sizes)))
            .
            if v-col-format <> ? then
            assign
            ch#Columns:NumberFormat = v-col-format
            no-error.
            if Integer(Entry(LL,Sheetf.Sizes)) > 50 then do:
              assign
              ch#Columns:WrapText = true
              no-error.
            end.
            if Col-Post-Format[ll] <> ?
            AND Col-Post-Format[ll] <> "":U
            then do:
              if v-ins-PostFormat then do:
                assign
                ch#zeroworkbook  = ch#ExcelApplication:Workbooks:Item(v-zero-count)
                .
                v-count = ch#ExcelApplication:Workbooks:Count.
                v-worksheet-name = ch#WorkSheet:Name.
                v-workbook-name = ?.
                assign
                v-workbook-name = ch#ExcelApplication:Workbooks:Item(v-count):Name
                no-error
                .
                if v-workbook-name <> ? then do:
                  ch#zeroWorkbook:PostF(v-workbook-name, v-worksheet-name, Sheetf.Excel-Row-Heder, ll, {&delim-par}, COl-Post-Format[ll]) .
                end.
              end.
            end.
            assign
            col-format[ll] = ?
            col-Post-Format[ll] = ?
            .
          End.

          if Sheetf.Bas-Param-Add = yes
          then do:
            assign
              v-count              = ch#ExcelApplication:Workbooks:Count
              v-bas-param-addition = {&delim-par} + ch#ExcelApplication:Workbooks:Item(v-count):Name
            .
          end.
          else do:
            assign
              v-count              = ch#ExcelApplication:Workbooks:Count
              v-bas-param-addition = "":U
            .
          end.

          /* До шапки */
          do LL = 1 TO Sheetf.Excel-Row-Heder - 1 :
            cRange = "A" + String(LL) + {&colon-char} + Col-name[AllCol + 1] + string(LL) no-error.
            { cmp/relescom.i ch#Range }
            assign
            ch#Range = ch#WorkSheet:Range (cRange)
            ch#Range:Numberformat = ch#ExcelApplication:International({&xlGeneralFormatName})
            ch#range:MergeCells = True no-error.
            if LL > 1 Then DO:
              ch#Range:Font:Bold = false no-error.
              ch#Range:Font:Size = 10    no-error.
              ch#Range:HorizontalAlignment = {&xlLeft}  no-error.
              ch#Range:VerticalAlignment = {&xlTop}     no-error.
            End.
          End.
          if sheetf.MergeCellsH = "" AND sheetf.mergecellsV = "" then do:
            /*СТАРЫЙ МЕТОД*/

            /* ШАПКА */
            do MM = Sheetf.Excel-Row-Heder TO Sheetf.Excel-Row-Heder + Sheetf.Excel-Row-Title - 2 :
              /* Склеивание колонок */
              do ll = 2 TO ALLCOL :
                { cmp/relescom.i ch#Range }
                assign
                ch#range = ch#WorkSheet:Range (Col-name[LL] + STRING(MM)).
                IF  ch#range:value = "" THEN DO:
                  ch#Range :value = ? .
                  { cmp/relescom.i ch#Range }
                  assign
                  ch#range = ch#WorkSheet:Range (Col-name[LL - 1] + STRING(MM) + {&colon-char} + Col-name[LL] + STRING(MM))
                  ch#range:MergeCells = True no-error.
                End.
              END.
            End.
            If Sheetf.Excel-Row-Title > 1 Then DO:
              do MM = Sheetf.Excel-Row-Heder + 1 TO Sheetf.Excel-Row-Heder + Sheetf.Excel-Row-Title - 1 :
                do ll = 1 TO ALLCOL :
                  /* Склеивание колонок */
                  { cmp/relescom.i ch#Range }
                  assign
                  ch#range = ch#WorkSheet:Range (Col-name[LL] + STRING(MM)).
                  IF  ch#range:value = ""
                      OR ch#Range:value = ?  THEN DO :
                    ch#Range:value =  ?  no-error.
                    { cmp/relescom.i ch#Range }
                    assign
                    ch#range = ch#WorkSheet:Range (Col-name[LL] + STRING(MM) + {&colon-char} + Col-name[LL] + STRING(MM - 1))
                    ch#range:MergeCells = True no-error.
                  End.
                End.
              End.
            End.
          END.
          ELSE DO: /*метод с использованием MergeCells*/
            /*сливаем по горизронтали*/
            do MM = 1 TO Num-entries(Sheetf.MergeCellsH, {&slash-char}) :
              /*берем правило для одной строчки*/
              linerule = ENTRY(MM, sheetf.MergeCellsH, {&slash-char}).
              do LL = 1 to NUM-entries(linerule):
                /*находим какие колонки сливать*/
                colrule = ENTRY(ll, linerule).
                /*очищаем*/
                do ii = 1 to int(ENTRY(2, colrule, {&colon-char})) - int(ENTRY(1, colrule, {&colon-char})):
                  { cmp/relescom.i ch#Range }
                  assign
                  ch#range = ch#WorkSheet:Range (Col-name[int(entry(1, colrule, {&colon-char})) + ii] + STRING(MM + Sheetf.EXCEL-ROw-HEDER - 1) )
                  ch#range:value =  ?  no-error.
                end.
                /*сливаем*/
                  { cmp/relescom.i ch#Range }
                assign
                ch#range =
                ch#WorkSheet:Range
                (COL-name[int(ENTRY(1, colrule, {&colon-char}))] + STRING(MM + Sheetf.EXCEL-ROw-HEDER - 1) +
                {&colon-char} +
                col-name[int(ENTRY(2, colrule, {&colon-char}))] + STRING(MM + Sheetf.EXCEL-ROw-HEDER - 1)
                )
                ch#range:MergeCells = True no-error
                .
              end.
            end.
            /*сливаем по вертикали*/
            do ii = 1 to num-entries(Sheetf.MergeCellsV, {&slash-char}):
              assign
              colrule = entry(ii, Sheetf.MergecellsV, {&slash-char})
              LL = int(entry(1, colrule, "=":U)) /*номер колонки*/
              colrule = entry(2, colrule, "=":U) /*список типа 1:3 какие строчки в колонке L сливать*/
              .
              /*очищаем*/
              do MM = 1 to int(entry(2,colrule, {&colon-char})) - int(entry(1,colrule, {&colon-char})):
                { cmp/relescom.i ch#Range }
                assign
                ch#range = ch#WorkSheet:Range (Col-name[ll] + STRING(int(entry(1,colrule, {&colon-char})) + MM + Sheetf.EXCEL-ROw-HEDER - 1) )
                ch#range:value =  ?  no-error.
              END.
              /*сливаем*/
                  { cmp/relescom.i ch#Range }
              assign
              ch#range =
              ch#WorkSheet:Range
              (COL-name[LL] + STRING(Sheetf.EXCEL-ROw-HEDER + int(entry(2,colrule, {&colon-char})) - 1) +
              {&colon-char} +
              col-name[LL] + STRING(Sheetf.EXCEL-ROw-HEDER + int(entry(1,colrule, {&colon-char})) - 1)
              )
              ch#range:MergeCells = True no-error.

            END.
          END. /*новый метод слияния*/
          ASSIGN
          cRange = "A" + STRING(Sheetf.Excel-Row-Heder) + {&colon-char} + Col-name[AllCol + 1] + STRING(SHeetf.Excel-Row-Heder + SHeetf.Excel-Row-Title - 1).
          { cmp/relescom.i ch#Range }
          assign
          ch#range = ch#WorkSheet:Range (cRange)
          ch#range:Font:Bold = TRUE
          ch#Range:Interior:ColorIndex = 35
          ch#Range:HorizontalAlignment = {&xlCenter}
          ch#Range:VerticalAlignment   = {&xlTop}
          ch#Range:WrapText = true
          ch#Range:Orientation = 0
          no-error.
          /* Бордюр */
          Assign
          ch#range:Borders({&xlDiagonalDown}):LineStyle = {&xlNone}
          ch#range:Borders({&xlDiagonalUp}):LineStyle   = {&xlNone}
          ch#range:Borders({&xlEdgeLeft}):LineStyle  = {&xlContinuous}
          ch#range:Borders({&xlEdgeLeft}):Weight     = {&xlThin}
          ch#range:Borders({&xlEdgeLeft}):ColorIndex = {&xlAutomatic}
          ch#range:Borders({&xlEdgeTop}):LineStyle  = {&xlContinuous}
          ch#range:Borders({&xlEdgeTop}):Weight     = {&xlThin}
          ch#range:Borders({&xlEdgeTop}):ColorIndex = {&xlAutomatic}
          ch#range:Borders({&xlEdgeBottom}):LineStyle  = {&xlContinuous}
          ch#range:Borders({&xlEdgeBottom}):Weight     = {&xlThin}
          ch#range:Borders({&xlEdgeBottom}):ColorIndex = {&xlAutomatic}
          ch#range:Borders({&xlEdgeRight}):LineStyle  = {&xlContinuous}
          ch#range:Borders({&xlEdgeRight}):Weight     = {&xlThin}
          ch#range:Borders({&xlEdgeRight}):ColorIndex = {&xlAutomatic}
          ch#range:Borders({&xlInsideVertical}):LineStyle  = {&xlContinuous}
          ch#range:Borders({&xlInsideVertical}):Weight     = {&xlThin}
          ch#range:Borders({&xlInsideVertical}):ColorIndex = {&xlAutomatic} no-error.
          IF SHeetf.Excel-Row-Title > 1 THEN
          Assign
          ch#range:Borders({&xlInsideHorizontal}):LineStyle  = {&xlContinuous}
          ch#range:Borders({&xlInsideHorizontal}):Weight     = {&xlThin}
          ch#range:Borders({&xlInsideHorizontal}):ColorIndex = {&xlAutomatic}
          ch#WorkSheet:PageSetup:PrintTitleRows = cRange
          no-error

          .
        end.
        /*выделим строчки итогов*/
        my-address = col-name[1] + {&colon-char} + col-name[2].
        { cmp/relescom.i ch#COlumns }
        ch#Columns = ch#Sheets:Item (1):COLUMNS(my-address).
        ch#COLUMNS:Select().
        assign
        first-step =  yes
        current-address = ""
        old-address = ""
        MM = Sheetf.Excel-Row-Heder +  Sheetf.Excel-Row-Title
        MM = if MM = 0 then 1 else MM
        .
        do while true
        :
          if first-step then do:
            my-address1 = col-name[1] + string(MM).
            { cmp/relescom.i ch#Range }
            ch#range = ch#Sheets:Item(1):Range(my-address1).
            { cmp/relescom.i ch#COlumns }
            ch#columns = ch#Sheets:Item (1):COLUMNS(my-address).
            { cmp/relescom.i ch#com-handle }
            ch#com-handle =
            ch#columns:FIND(
            "ИТОГО", /*что ищем*/
            ch#range, /*после чего ищем*/
            - 4163, /*xlValues в формулах значениях ил еще где*/
            2, /*xlPart совпадение неполное*/
            2, /*xlByColumns по колонкам*/
            1 /*xlNext ищем вперед*/
            ).
          end.
          else do:
            my-address1 = replace(current-address, "$":U, "").
            { cmp/relescom.i ch#Range }
            ch#range = ch#Sheets:Item(1):range(my-address1).
            { cmp/relescom.i ch#COlumns }
            ch#columns = ch#Sheets:Item (1):COLUMNS(my-address).
            { cmp/relescom.i ch#com-handle }
            ch#com-handle = 0.
            ch#com-handle =
            ch#columns:FIND(
            "ИТОГО", /*что ищем*/
            ch#range, /*после чего ищем*/
            - 4163, /*xlValues в формулах значениях или еще где*/
            2, /*xlPart совпадение неполное*/
            2, /*xlByColumns по колонкам*/
            1 /*xlNext ищем вперед*/
            ).
          end.
          if not valid-handle(ch#com-handle) then leave.
          assign
          current-address = ch#com-handle:address(yes, yes, 1).
          if current-address = old-address then LEAVE.
          if first-step then
          assign
          first-step = no
          old-address = current-address.
          current-row = integer(ENtry(3, current-address, "$":U)).
          ch#Sheets:Item (1):ROWS(current-row):Font:Bold = true.
        END.

        if num-entries(Sheetf.colformat, {&delim-par}) >= 3 then do:
          ch#Sheets:Item(1):name = entry(3, Sheetf.colformat, {&delim-par}).
        end.
        /*запишем и толкнем в Excel пользовательские макросы*/
        if Sheetf.Bas-FIle <> "":U then do:
          run RunMainMacros in this-procedure (Sheetf.Bas-file, Sheetf.Bas-Params) no-error .
        end.
        assign
        my-address = col-name[1] + {&colon-char} + col-name[1]
        my-address1 = col-name[1] + string(1)
        .
        { cmp/relescom.i ch#Range }
        ch#range = ch#Sheets:Item(1):Range(my-address1).
        ch#range:select().
        /*начало перехода на следующий лист*/
        if real-num-sheets = 1 then do:
          { cmp/relescom.i ch#firstsheet }
          ch#firstsheet =  ch#Sheets:Item(1).
        end.
        else do:
          { cmp/relescom.i ch#firstsheet }
          assign
          ch#firstsheet = ch#ExcelApplication:Workbooks:Item(v-zero-count + 1):sheets:item(1)
          .
          ch#Sheets:Item(1):Move( ,ch#firstsheet) no-error.
        end.

        /*конец перехода на следующий лист*/

      END.  /*конец цикла по листам*/
      ch#firstsheet:activate() no-error.
      { cmp/relescom.i ch#zeroworkbook }
      assign
      ch#zeroworkbook  = ch#ExcelApplication:Workbooks:Item(v-zero-count).
      ch#zeroworkbook:Saved = yes.
      ch#zeroworkbook:close.
      { cmp/relescom.i ch#zeroworkbook }
      { cmp/relescom.i ch#firstsheet }
      num-sheets = ch#workbook:Sheets:Count().

      /*удалим ненужные листы*/
      /*
      if real-num-sheets > 1 then do:
        assign
        my-address = col-name[1] + string(1)
        ch#ExcelApplication:DisplayAlerts = False.
        ii = real-num-sheets.
        do while true
        :
          { cmp/relescom.i ch#Range }
          ch#range = ch#Sheets:Item (ii):range(my-address).

          if ch#range:value = "" OR
              ch#range:value = ?
          then do:
            ch#Sheets:Item (ii):delete.
          end.
          ii = ii - 1.
          if ii = 0 then leave.
        end.
        ch#ExcelApplication:DisplayAlerts = true.
        /*найдем первый по нумерации лист, но в excel он последний*/
        lastsheet = ch#Sheets:Count().
        ch#Sheets:Item (lastsheet):Activate().
      end.
      */
      /*сотрем макрос пост-форматирования*/
      if v-ins-PostFormat then do:
      { cmp/relescom.i ch#zeroworkbook }
        assign
        ch#zeroworkbook  = ch#ExcelApplication:Workbooks:Item(v-zero-count)
        .
        ch#zeroWorkbook :VBProject :VBComponents :Item(1) :CodeModule:DeleteLines(1, v-module-lines) no-error.
      end.
      ch#ExcelApplication:DisplayAlerts = False.
      res = ch#Workbook:SaveAs( tempfile-xls, {&xlNormal} , , , , , ) NO-ERROR.
      ch#ExcelApplication:DisplayAlerts = True.
      if error-status:error then do:
        run ClearExcel in this-procedure .
        run Write-err in this-procedure (input yes) .
        quit.
      end.
      tempfile-full = ch#Workbook:FullName.
      if tempfile = tempfile-full or res = ? then do:
        /*не удалось сохранить txt в xls*/
        message
          "Не удалось сохранить файл вывода " tempfile " в формате .XLS" skip
          "Возможно файл с именем " tempfile-xls " уже открыт ?" skip
          view-as alert-box error .
        /*      is-open = yes.*/
        ch#ExcelApplication:ActiveWorkbook:Saved = YES.
        ch#Workbook:Close.
        run ClearExcel in this-procedure .
        run Write-err in this-procedure (input yes) .
        quit.
      end.
      /*пока воздержимся*/

      /*сотрем текстовые файлы*/
      /*
      if num-sheets > 1 then do:
        for each sheetf where sheetf.sheet-num > 1:
          assign
          tempfile-n = right-trim(tempfile, "txt":U)
          tempfile-n = right-trim(tempfile-n, ".")
          tempfile-n = tempfile-n + ".":U + string(sheetf.sheet-num)
          .
          message tempfile-n view-as alert-box .
          OS-DELETE value(tempfile-n).
        end.
      end.
      */

    /*
      assign
      ch#ExcelApplication:Interactive    = true
      ch#ExcelApplication:ScreenUpdating = true
      ch#ExcelApplication:Visible        = true.
      PROCESS EVENTS.*/
      ch#ExcelApplication:Quit() no-error.
      run ClearExcel in this-procedure .
      PROCESS EVENTS.
      run waitfram-hide in this-procedure .
      run rep/killspac.p (input-output tempfile-full).
      if v-silent-mode = no
      then do:
        run gbl/open_url.p (tempfile-full) no-error .
      end.
    end.
  end. /* if make-excel */

  run write-err in this-procedure (input no) .
  quit.

  procedure ClearExcel :

    do
    on error undo, return error
    :
      run waitfram-hide in this-procedure .
      output Stream  ForExcel close.
      { cmp/relescom.i ch#COlumns }
      { cmp/relescom.i ch#Sheets }
      { cmp/relescom.i ch#Range }
      { cmp/relescom.i ch#com-handle }
      { cmp/relescom.i ch#WorkSheet }
      { cmp/relescom.i ch#Workbook }
      { cmp/relescom.i ch#firstsheet }
      { cmp/relescom.i ch#zeroworkbook }
      if not my-excel or is-open then do:
        assign
        ch#ExcelApplication:Interactive    = true
        ch#ExcelApplication:ScreenUpdating = true
        ch#ExcelApplication:Visible        = true.
      end.
      /*if my-excel and not is-open then
      ch#ExcelApplication:Quit() no-error.*/
      { cmp/relescom.i ch#ExcelApplication }
      PROCESS EVENTS.
    end.

  end procedure. /* ClearExcel */

  procedure write-err :
    do
    on error undo, return error
    :
      define input parameter p-is-err as logical no-undo .
      run gbl/bat-err.p
        (input err-file
        ,input (if p-is-err then 1 else 0)
        ).
    end.
  end.
end.



procedure make-sheetf :

  do
  on error undo, return error return-value
  :
    define buffer buf_sheetf for sheetf .

    for each buf_sheetf
    on error undo, return error
    :
      delete buf_sheetf .
    end.

    input stream forformat from value( tempfile-frm ) .

    repeat
    :
      create buf_sheetf .
      import stream forformat buf_sheetf .
    end.
  end.

end procedure. /* make-sheetf */

procedure InsertMacroExcel :
  do
  on error undo, return error
  :

  define variable chCodeModule as com-handle no-undo .
  define variable num-of-lines as integer no-undo .
  assign
    chCodeModule = ch#Workbook :VBProject :VBComponents :Item(1) :CodeModule
  .
  define variable v-ind     as integer no-undo .

  assign v-ind = 1 .
  assign
  num-of-lines = chCodeModule :CountOfLines.
  chCodeModule:DeleteLines(1, num-of-lines).
  chCodeModule :InsertLines(v-ind, 'Sub convdec(rowStart As long, colStart As Integer)                      ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '  dgChar = "0123456789-+' + v-delim + '"                                ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '  With ActiveSheet.Cells.SpecialCells(xlLastCell)  ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '    MaxRow = .Row                                  ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '    MaxCol = .Column                               ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '  End With                                         ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '  For Each curcell In Worksheets(1).Range(Worksheets(1).Cells(rowStart, colStart), Worksheets(1).Cells(MaxRow, MaxCol))  ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '      If Mid(curCell.Formula, 1, 1) = "=" Then                           ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '        If Mid(curCell.Formula, 2, 1) = """" And Mid(curCell.Formula, Len(curCell.Formula), 1) = """" Then       ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '          dg = Mid(curCell.Formula, 3, Len(curCell.Formula) - 3)         ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '          numPoint = 0                                                   ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '          numMinus = 0                                                   ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '          numPlus = 0                                                    ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '          For i = 1 To Len(dg)                                           ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '            flagExists = False                                           ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '            For j = 1 To Len(dgChar)                                     ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '              If Mid(dg, i, 1) = Mid(dgChar, j, 1) Then                  ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                If Mid(dg, i, 1) = "' + v-delim + '" Then                  ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                  If numPoint > 0 Then Exit For                          ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                  numPoint = 1                                           ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                End If                                                   ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                If Mid(dg, i, 1) = "-" Then                              ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                  If i > 1 Then Exit For                                 ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                  If numMinus > 0 Then Exit For                          ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                  numMinus = 1                                           ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                End If                                                   ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                If Mid(dg, i, 1) = "+" Then                              ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                  If i > 1 Then Exit For                                 ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                  If numPlus > 0 Then Exit For                           ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                  numPlus = 1                                            ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                End If                                                   ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                flagExists = True                                        ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '                Exit For                                                 ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '              End If                                                     ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '            Next                                                         ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '            If Not flagExists Then Exit For                              ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '          Next                                                           ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '          If flagExists Then curCell.Value = dg + 0                      ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '        End If                                                           ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '      End If                                                             ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, '  Next curCell                                                           ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, "'                                                                        " )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, 'End Sub                                                                  ' )  .

  ch#Workbook :convdec( 1, 2) .

  chCodeModule :DeleteLines(1, v-ind) .

  { cmp/relescom.i chCodeModule }

  end.

end procedure. /* InsertMacroExcel */


procedure OpenFileFromtMacro :
define input parameter p-filename as character no-undo .
define input parameter p-dec-separ as character no-undo .
  do
  on error undo, return error
  :

    DEFINE VARIABLE v-ii as integer no-undo .
    define variable chCodeModule as com-handle no-undo .
    define variable v-ind     as integer no-undo .
    DEFINE VARIABLE v-max-column-num as integer no-undo .
    define variable num-of-lines as integer no-undo .
      assign
      v-max-column-num = max(v-max-column-num, NUM-ENTRIES(sheetf.Sizes))
      .
    assign
    chCodeModule = ch#zeroWorkbook :VBProject :VBComponents :Item(1) :CodeModule
    no-error .
    if error-status:error then return error.
    assign v-ind = 1 .
    assign
    num-of-lines = chCodeModule :CountOfLines.
    chCodeModule:DeleteLines(1, num-of-lines).
    chCodeModule :InsertLines(v-ind, 'Sub MyOpen2(vfilename As String)                      ' )  .
    assign v-ind = v-ind + 1 .
    chCodeModule :InsertLines(v-ind, 'Workbooks.OpenText Filename:=vfilename, Origin:=xlWindows, ' +
                                    'StartRow:=1, DataType:=xlDelimited, TextQualifier:=xlDoubleQuote, ' +
                                    'ConsecutiveDelimiter:=False, Tab:=True, Semicolon:=False, Comma:=False, ' +
                                    'Space:=False, Other:=False, DecimalSeparator:=' + {&double-quote} + p-dec-separ +
                                      {&double-quote}  ).
    assign v-ind = v-ind + 1 .
    chCodeModule :InsertLines(v-ind, 'End Sub' )  .
    assign v-ind = v-ind + 1 .
    chCodeModule :InsertLines(v-ind, 'Sub MyOpen1(vfilename As String)                      ' )  .
    if v-max-column-num > 0 then do:
      assign v-ind = v-ind + 1 .
      chCodeModule :InsertLines(v-ind, 'Dim varray(1 To ' + string(v-max-column-num) + ') As Variant ').
      do v-ii = 1 to v-max-column-num:
        assign v-ind = v-ind + 1 .
        chCodeModule :InsertLines(v-ind, 'varray(':U +
                                          string(v-ii) +
                                          ') = Array(' +
                                          string(v-ii) +
                                          ', ' +
                                          fieldinfo-datef(Col-Format[v-ii]) +
                                          ')'
                                  ).
      end.
      assign v-ind = v-ind + 1 .
      chCodeModule :InsertLines(v-ind, 'Workbooks.OpenText Filename:=vfilename, Origin:=xlWindows, ' +
                                      'StartRow:=1, DataType:=xlDelimited, TextQualifier:=xlDoubleQuote, ' +
                                      'ConsecutiveDelimiter:=False, Tab:=True, Semicolon:=False, Comma:=False, ' +
                                      'Space:=False, Other:=False, FieldInfo:=varray, DecimalSeparator:=' + {&double-quote} + p-dec-separ +
                                       {&double-quote}  ).
    end.
    else do:
      assign v-ind = v-ind + 1 .
      chCodeModule :InsertLines(v-ind, 'Call MyOpen2(vfilename) ' )  .
    end.
    assign v-ind = v-ind + 1 .
    chCodeModule :InsertLines(v-ind, 'End Sub' )  .
    assign v-ind = v-ind + 1 .
    chCodeModule :InsertLines(v-ind, 'Sub MyOpen(vfilename As String)                      ' )  .
    assign v-ind = v-ind + 1 .
    chCodeModule :InsertLines(v-ind, 'If CInt(Mid(Application.Version, 1, InStr(Application.Version, ".") - 1)) < 9 Then').
    assign v-ind = v-ind + 1 .
    chCodeModule :InsertLines(v-ind, 'Call MyOpen2(vfilename) ' )  .
    assign v-ind = v-ind + 1 .
    chCodeModule :InsertLines(v-ind, 'Else: Call MyOpen1(vfilename) ').
    assign v-ind = v-ind + 1 .
    chCodeModule :InsertLines(v-ind, 'End If ').
    assign v-ind = v-ind + 1 .
    chCodeModule :InsertLines(v-ind, 'End  Sub ').
    ch#zeroWorkbook :MyOpen( p-filename) .

    /* надо стирать!!! другие листы придется открывать по-другому*/
    chCodeModule :DeleteLines(1, v-ind) .

    { cmp/relescom.i chCodeModule }

  end.

end procedure. /* OpenFileFromtMacro */


procedure InsertPostFormatting :
define output parameter p-lines as integer no-undo .
  do
  on error undo, return error
  :

  define variable chCodeModule as com-handle no-undo .
  define variable v-ind     as integer no-undo .
  define variable num-of-lines as integer no-undo .
  assign
  ch#zeroworkbook  = ch#ExcelApplication:Workbooks:Item(v-zero-count)
  chCodeModule = ch#ZeroWorkbook :VBProject :VBComponents :Item(1) :CodeModule
  no-error .
  if error-status:error then return error.
  assign v-ind = 1 .
  assign
  num-of-lines = chCodeModule :CountOfLines.
  chCodeModule:DeleteLines(1, num-of-lines).
  chCodeModule :InsertLines(v-ind, 'Sub PostF(vWorkbookName, vSheetname, vStartRow As Integer, vColumnNumber As Integer, vCutSymbol As String, vColumnFormat As String) ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, 'For ii = vStartRow To Workbooks(vWorkbookname).Sheets(vSheetname).Cells.SpecialCells(xlLastCell).Row ')  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, 'If Mid(Workbooks(vWorkbookname).Sheets(vSheetname).Cells(ii, vColumnNumber).Value, 1, 1) = vCutSymbol Then ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, 'Workbooks(vWorkbookname).Sheets(vSheetname).Cells(ii, vColumnNumber).NumberFormat = vColumnFormat ' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, 'Workbooks(vWorkbookname).Sheets(vSheetname).Cells(ii, vColumnNumber).Value = Mid(Workbooks(vWorkbookname).Sheets(vSheetname).Cells(ii, vColumnNumber).Value, 2)' )  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, 'End If ')  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, 'Next ii ')  .
  assign v-ind = v-ind + 1 .
  chCodeModule :InsertLines(v-ind, 'End Sub' )  .
  assign
  p-lines = v-ind
  .
  /*можно не стирать*/
  { cmp/relescom.i chCodeModule }

  end.

end procedure. /* OpenFileFromtMacro */


procedure RunMainMacros :
define input parameter p-bas-file as character no-undo .
define input parameter p-parameters as character no-undo .
define variable chCodeModule as com-handle no-undo .
define variable v-ind     as integer no-undo .
DEFINE VARIABLE v-str as character no-undo .

  do
  on error undo, return error
  :

  assign v-ind = 1 .
  assign
  p-bas-file = search(p-bas-file)
  .
  if p-bas-file = ? then do:
    return.
  end.
  input stream BasStream from value(p-bas-file) .
  assign
  chCodeModule = ch#Workbook :VBProject :VBComponents :Item(1) :CodeModule
  .
  assign v-ind = 1 .
  REPEAT:
    import stream BasStream unformatted
    v-str.
    chCodeModule :InsertLines(v-ind, v-str )  .
    assign v-ind = v-ind + 1 .
  END.
  input stream BasStream close.

  if Sheetf.Bas-Param-Add = yes
  then do:
    assign
      p-parameters = p-parameters + v-bas-param-addition
    .
  end.

  ch#Workbook:Main_Macros( p-parameters, {&delim-par} ).

  chCodeModule:DeleteLines(1, v-ind - 1) .
  if index(".b8s":U, p-bas-file)  > 0 then do:
  run gbl/fileattr.p
  (input p-bas-file
  ,input "readonly-clear"
  ) no-error .
  OS-delete value(p-bas-file).
  end.
    { cmp/relescom.i chCodeModule }
  end.

end procedure. /* InsertMacroExcel */

function fieldinfo-datef returns character(input p-format  as character):
define variable v-format as character no-undo init "1":U.
if p-format = "@" then do:
  return string(2).
end.

  assign
  v-format = replace(p-format, "/", "":U)
  v-format = replace(v-format, ".", "":U)
  v-format = replace(v-format, "dd", "d":U)
  v-format = replace(v-format, "mm", "m":U)
  v-format = replace(v-format, "yy", "y":U)
  v-format = replace(v-format, "yy", "y":U)
  .

  CASE v-format:
    when "MDY":U then return string(3).
    when "DMY":U then return string(4).
    when "YMD":U then return string(5).
    when "MYD":U then return string(6).
    when "DYM":U then return string(7).
    when "YDM":U then return string(8).
    otherwise return string(1).

  END CASE.
END FUNCTION.

function compare-data-format returns logical(input p-format as character
                                           ,  input p-excel-fi as character
                                           ,  output p-is-data as logical):
define variable v-ex-format-list as character no-undo init "MDY,DMY,YMD":U.
define variable v-ex-format as character no-undo .
define variable v-format as character no-undo.
define variable v-is-data-str as character no-undo .
assign
v-ex-format = entry(integer(p-excel-fi) + 1, v-ex-format-list)
.
assign
v-format = replace(p-format, "/", "":U)
v-format = replace(v-format, ".", "":U)
v-format = replace(v-format, "dd", "d":U)
v-format = replace(v-format, "mm", "m":U)
v-format = replace(v-format, "yy", "y":U)
v-format = replace(v-format, "yy", "y":U)
v-is-data-str = replace(v-format, "y", "":U)
v-is-data-str = replace(v-format, "m", "":U)
v-is-data-str = replace(v-format, "d", "":U)
p-is-data = (trim(v-is-data-str) = "":U)
.
return (v-format = v-ex-format).
END FUNCTION.