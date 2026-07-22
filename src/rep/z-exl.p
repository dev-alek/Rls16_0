block-level on error undo, throw.
/*

$Revision: e47eaee10c88, 211, rls $
$Author: SShalanin $
$Date: Tue Jun 30 11:11:56 2015 +0400 $
$Workfile: z-exl.p $
$Archive: rep/z-exl.p $

Программа запуска excel 

Автор: Шаланин Сергей Владимирович
Дата создания: 06/02/15
Author: Shalanin Sergey
Creation date: 06/02/15

*/

{ gbl/paramls.i }
define input-output parameter table for temp-param .

define variable vss-revision    as character no-undo init "$Revision: e47eaee10c88, 211, rls $":U .
define variable vss-author      as character no-undo init "$Author: SShalanin $":U .
define variable vss-date        as character no-undo init "$Date: Tue Jun 30 11:11:56 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: z-exl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/z-exl.p $":U .
define variable vss-description as character no-undo init "Программа запуска excel ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

&scop xlMinimized  -4140
&scop xlNormal     -4143
define output parameter p-excel as char no-undo.
define buffer buf_temp-param for temp-param .

define variable chExcelApp   as com-handle no-undo .
define variable chWorkBook   as com-handle no-undo .
define variable chCodeModule as com-handle no-undo .

define variable v-ind              as integer   no-undo .
define variable v-excel-macro-file as character no-undo .
define variable v-ok               as logical   no-undo .

do
on error undo, return error
:

  define variable v-excel-file-name as character no-undo .
  define variable v-read-password   as character no-undo .
  define variable v-write-password  as character no-undo .
  define variable v-excel-dir-name  as character no-undo .

  /* определяем имя файла и параметры сохранения */
  run paramls-read in this-procedure
    (input  "saveas"
    ,input  "excel-file-name"
    ,input  ""
    ,output v-excel-file-name
    ) .

  define variable v-rowsgroup-enable-str as character no-undo .
  define variable v-rowsgroup-enable     as logical   no-undo .

  run paramls-read in this-procedure
    (input  "rowsgroup-enable"
    ,input  ""
    ,input  "false"
    ,output v-rowsgroup-enable-str
    ) .
  if lookup(v-rowsgroup-enable-str, 'yes,true':u) > 0
  then do:
    assign
      v-rowsgroup-enable = true
    .
  end.
  else do:
    assign
      v-rowsgroup-enable = false
    .
  end.


  if v-excel-file-name = ""
  or v-excel-file-name = ?
  then do:
    run gbl/_tmpfile.p
      (input  ""
      ,input  ".xls"
      ,output v-excel-file-name
      ) .

/*    run gbl/d-file.p                                                 */
/*      (input-output v-excel-file-name       /* p-file-id           */*/
/*      ,input-output v-excel-dir-name        /* p-file-directory    */*/
/*      ,input  (" Все файлы EXCEL (*.xls) ") /* p-filter-names      */*/
/*      ,input  ("*.xls":U)                   /* p-filter-values     */*/
/*      ,input  {&comma-char}                 /* p-filter-delimiter  */*/
/*      ,input  (".xls":U)                    /* p-default-extension */*/
/*      ,input  no                            /* p-must-exist        */*/
/*      ,input  yes                           /* p-save-as           */*/
/*      ,input  yes                           /* p-use-filename      */*/
/*      ,input  "Введите имя файла"           /* p-title             */*/
/*      ,output v-ok                          /* p-choose            */*/
/*      ) .                                                            */
/*    if v-ok <> true then do:                                         */
/*      undo, return error .                                           */
/*    end.                                                             */
p-excel = v-excel-file-name.
    if search(v-excel-file-name) <> ? then do:
      os-delete value(v-excel-file-name) .
    end.
  end.

  run paramls-read in this-procedure
    (input  "saveas"
    ,input  "read-password"
    ,input  ""
    ,output v-read-password
    ) .

  run paramls-read in this-procedure
    (input  "saveas"
    ,input  "write-password"
    ,input  ""
    ,output v-write-password
    ) .

  define variable v-column-list as character no-undo .

  run paramls-read in this-procedure
    (input  "charcol"
    ,input  ""
    ,input  ""
    ,output v-column-list
    ) .

  create "Excel.Application" chExcelApp no-error .
  if error-status :error then do:
    message
      "Ошибка при запуске Excel" skip
      error-status :get-message(1) skip
      view-as alert-box error .
    undo, return error .
  end.


    chExcelApp :Visible = false
  .
  assign
    chExcelApp :WindowState = {&xlNormal}
    chExcelApp :Visible     = false
    chExcelApp :Interactive = False
  .
  /* Ни в коем случае нельзя запускать EXCEL в невидимом режиме */
  /* он в этом случае работает в 4 раза медленнее. */
  /* Почему это происходит неизвестно. */
  /* Кроме того, при выводе отчета в строке состояния Excel будет выводиться */
  /* количество обработанных команд */
/*  assign*/
/*    chExcelApp :WindowState = {&xlMinimized}*/
/*    chExcelApp :Visible     = False*/
/*    chExcelApp :Interactive = False*/
/*  .*/

  assign
    chWorkBook = chExcelApp :Workbooks :Add()
  .

  assign
    chCodeModule = chWorkbook :VBProject :VBComponents :Item(1) :CodeModule
  .
  define variable num-of-lines as integer no-undo .
  assign
  num-of-lines = chCodeModule :CountOfLines.
  chCodeModule:DeleteLines(1, num-of-lines).

  run export-macro in this-procedure
    (input v-rowsgroup-enable
    ) .

  for each buf_temp-param
    where buf_temp-param.param-code = "file"
  by buf_temp-param.param-sub-code descending
  on error undo, return error
  : /*message "Этот отчёт задействует файл macroexl.p!!!" skip "buf_temp-param.param-sub-code = " buf_temp-param.param-sub-code view-as alert-box.*/
    /* ТН-3349 12.12.2014г Арн (ошибка выявлена Заказчиком - ББ) */
    /* текст из buf_temp-param.param-sub-code - выводится в Лист Excel, проверяем, содержит ли текст запрещённые Microsoft в имени Листа пяти символов: "/"; "\"; ":"; "?"; "*". */
    buf_temp-param.param-sub-code = replace(buf_temp-param.param-sub-code, "/", "|" ).
    buf_temp-param.param-sub-code = replace(buf_temp-param.param-sub-code, "\", "_" ).
    buf_temp-param.param-sub-code = replace(buf_temp-param.param-sub-code, ":", ";" ).
    buf_temp-param.param-sub-code = replace(buf_temp-param.param-sub-code, "?", "#" ).
    buf_temp-param.param-sub-code = replace(buf_temp-param.param-sub-code, "*", "@" ).
    /* текст из buf_temp-param.param-sub-code - не должен превышать 31 символ, согласно спецификации Microsoft. */
    if length(buf_temp-param.param-sub-code) > 31 then
        do:
            buf_temp-param.param-sub-code = substring (buf_temp-param.param-sub-code, 1, 28) + "...".
        end.
    /* преобразуем относительный путь к файлу в полный */
    assign
      file-info :file-name = buf_temp-param.param-value
    .
    assign
      v-excel-macro-file = file-info :full-pathname
    .

    if v-excel-macro-file = ?
    or v-excel-macro-file = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден файл" buf_temp-param.param-value skip
        "param-code" buf_temp-param.param-code skip
        "param-sub-code" buf_temp-param.param-sub-code skip
        view-as alert-box error .
      undo, next .
    end.

    /* производим импорт файла в Excel */
    assign
      v-ok = chWorkbook :DDEExec(v-excel-macro-file, buf_temp-param.param-sub-code, v-column-list)
    .

    define variable v-rowsgroup-sub-code as character no-undo .
    assign
      v-rowsgroup-sub-code = buf_temp-param.param-sub-code + ',':u
    .

    if v-rowsgroup-enable = true
    then do:
      define buffer buf_rowsgroup_temp-param for temp-param .
      for each buf_rowsgroup_temp-param
        where buf_rowsgroup_temp-param.param-code = 'rowsgroup':u
          and buf_rowsgroup_temp-param.param-sub-code begins v-rowsgroup-sub-code
      on error undo, return error return-value
      :
        assign
          v-ok = chWorkBook :rowsgroup(buf_rowsgroup_temp-param.param-value) no-error
        .
      end.
    end.
  end.

  for each buf_temp-param
    where buf_temp-param.param-code = "command"
  by buf_temp-param.param-sub-code
  on error undo, leave
  :
    assign
      v-ok = chWorkbook :DDEExecCommand(buf_temp-param.param-value)
    .
  end.

  run clear-macro in this-procedure .

  assign
    chExcelApp :DisplayAlerts = False
  .

  define variable v-default-excel-file-name as character no-undo .
  assign
    v-default-excel-file-name = chWorkBook :FullName
  .

  /*
    xpression.SaveAs
      (Filename
      ,FileFormat
      ,Password
      ,WriteResPassword
      ,ReadOnlyRecommended
      ,CreateBackup
      ,AddToMru
      ,TextCodePage
      ,TextVisualLayout
      )

  */

  if  v-read-password <> ""
  and v-write-password <> "" then do:
    assign
      v-ok = chWorkBook :SaveAs(v-excel-file-name, {&xlNormal}  ,v-read-password ,v-write-password , , , ) no-error
    .
  end.
  else do:
    if v-write-password <> "" then do:
      assign
        v-ok = chWorkBook :SaveAs(v-excel-file-name, {&xlNormal} , ,v-write-password , , , ) no-error
      .
    end.
    else do:
      assign
        v-ok = chWorkBook :SaveAs(v-excel-file-name, {&xlNormal} , , , , , ) no-error
      .
    end.
  end.

  assign
    chExcelApp :DisplayAlerts = True
  .
  assign
    v-excel-file-name = chWorkBook :FullName
  .
  if v-excel-file-name = v-default-excel-file-name
  or v-excel-file-name = ? then do:
    release object chCodeModule no-error .
    release object chWorkBook   no-error .
    release object chExcelApp   no-error .

    message
      "Ошибка при сохранении файла" skip
      "Сохраните Excel файл вручную" skip
      view-as alert-box information .
  end.
  else do:
    assign
      chWorkBook :Saved = true
    .
    assign
      v-ok = chWorkBook :Close
    .

    release object chCodeModule no-error .
    release object chWorkBook   no-error .
    assign
      v-ok = chExcelApp:Quit() no-error
    .
    release object chExcelApp   no-error .

  
  end.

end.


procedure append-macro-line :

  define input  parameter p-macro-str as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-ind = v-ind + 1
    .
    assign
      v-ok = chCodeModule :InsertLines(v-ind, p-macro-str )
    .
  end.

end procedure. /* append-macro-line */

procedure export-test-macro :

  assign
    v-ind = 0
  .

  do
  on error undo, return error return-value
  :
    run append-macro-line (input 'Sub HelloWorld()').
    run append-macro-line (input '  MsgBox "HelloWorld"').
    run append-macro-line (input 'End Sub').
  end.

end procedure. /* export-test-macro */

procedure export-macro :

  define input  parameter p-export-rowsgroup-macro as logical   no-undo .

  assign
    v-ind = 0
  .

  do
  on error undo, return error return-value
  :
    run append-macro-line (input 'Sub DDEExec(FileName$, SheetName$, numColList$)').
    run append-macro-line (input '  Application.ScreenUpdating = False').
    run append-macro-line (input '  Application.Interactive = False').
    /* создаем новую страницу в книге */
    run append-macro-line (input '  Set NewSheet = Sheets.Add(Type:=xlWorksheet)').
/*    run append-macro-line (input '  NewSheet.Select()').*/
    run append-macro-line (input '  NewSheet.Name = SheetName$').
    run append-macro-line (input '  dim ind as long').
    run append-macro-line (input '  dim vshowmess as boolean').
    run append-macro-line (input '  vshowmess = true').
    /* форматируем колонки, как символьные */
/*    run append-macro-line (input '  Columns(CInt(numColList$)).NumberFormat = "@"').*/
    run append-macro-line (input '  callList(numColList$)').
    /* открываем файл с командами */
    run append-macro-line (input '  Open FileName$ For Input As #1').
    run append-macro-line (input '  ind = 0').
    /* в цикле считываем команды из файла */
    run append-macro-line (input '  Do Until EOF(1)').
    run append-macro-line (input '    Line Input #1, vCommand').
    run append-macro-line (input '    ind = ind + 1').
    /* после каждой тысячной команды - показываем информацию о считывании команд */
    run append-macro-line (input '    if ind mod 3000 = 0 then').
    run append-macro-line (input '      Application.StatusBar = "Импорт из " & FileName$ & " Строк " & CStr(ind)').
    run append-macro-line (input '      Application.ScreenUpdating = True').
    run append-macro-line (input '      Application.ScreenUpdating = False').
    run append-macro-line (input '    end if').
    /* выполняем команду */

    /* обрабатываем возможные ошибки */
    run append-macro-line (input '    On Error Resume Next').
    run append-macro-line (input '    ExecuteExcel4Macro (vCommand)').
    run append-macro-line (input '    If (Err.Number <> 0) and (vshowmess = true) Then').
    run append-macro-line (input '      Dim vCancelMacro As Integer').
    run append-macro-line (input '      vCancelMacro = MsgBox("Ошибка " & Err.Number & Chr(13) & "Команда " & vCommand & Chr(13) & "Файл " & FileName$ & Chr(13) & "Строка файла " & ind & Chr(13) & "Yes - Продолжить выполнение программы" & Chr(13) & "No - Продолжить выполнение программы и не выводить сообщения об ошибках" & Chr(13) & "Cancel - Прервать выполнение программы" & Chr(13), vbYesNoCancel)').
    run append-macro-line (input '      Select Case vCancelMacro').
    run append-macro-line (input '        Case vbYes').
    run append-macro-line (input '        Case vbNo').
    run append-macro-line (input '          vshowmess = false').
    run append-macro-line (input '        Case vbCancel').
    run append-macro-line (input '          Close #1').
    run append-macro-line (input '          Exit Sub').
    run append-macro-line (input '      End Select').
    run append-macro-line (input '    End If').
    run append-macro-line (input '    On Error GoTo 0').
    /* возвращаемся к началу цикла - продолжаем считывать строки файла */
    run append-macro-line (input '  Loop').
    /* закрываем файл с командами */
    run append-macro-line (input '  Close #1').
    run append-macro-line (input '  Application.StatusBar = "Импорт из " & FileName$ & " завершен"').
    run append-macro-line (input '  Application.ScreenUpdating = True').
    run append-macro-line (input '  Application.Interactive = True').
    run append-macro-line (input 'End Sub').
    run append-macro-line (input 'Sub DDEExecCommand(vCommand$)').
    run append-macro-line (input '   ExecuteExcel4Macro (vCommand$)').
    run append-macro-line (input 'End Sub').
    run append-macro-line (input 'Sub FormatColumnNumber(numCol As Integer)').
    run append-macro-line (input '  Columns(numCol).NumberFormat = "@"').
    run append-macro-line (input 'End Sub').
    run append-macro-line (input 'Sub callList(sList As String)').
    run append-macro-line (input '  Dim iPos0 As Integer, iPos As Integer').
    run append-macro-line (input '  Dim sDelimiter As String').
    run append-macro-line (input '  sDelimiter = ","').
    run append-macro-line (input '  If sList = "" Then').
    run append-macro-line (input '      Exit Sub').
    run append-macro-line (input '  End If').
    run append-macro-line (input '  iPos0 = 0').
    run append-macro-line (input '  iPos = InStr(1, sList, sDelimiter, vbBinaryCompare)').
    run append-macro-line (input '  If iPos = 0 Then').
    run append-macro-line (input '      FormatColumnNumber(Cint(sList))').
    run append-macro-line (input '      Exit Sub').
    run append-macro-line (input '  End If').
    run append-macro-line (input '  While True').
    run append-macro-line (input '      FormatColumnNumber(Cint(Mid(sList, iPos0 + 1, IIf(iPos = 0, Len(sList), iPos - iPos0 - 1))))').
    run append-macro-line (input '      If iPos = 0 Then').
    run append-macro-line (input '          Exit Sub').
    run append-macro-line (input '      End If').
    run append-macro-line (input '      iPos0 = iPos').
    run append-macro-line (input '      iPos = InStr(iPos + 1, sList, sDelimiter)').
    run append-macro-line (input '  Wend').
    run append-macro-line (input 'End Sub').

    if p-export-rowsgroup-macro = true
    then do:
      run append-macro-line (input 'Sub rowsgroup(srange As String)').
      run append-macro-line (input '  Rows(srange).Group').
      run append-macro-line (input 'End Sub').
    end.
  end.

end procedure. /* export-macro */


procedure clear-macro :

  /* удалить все макросы в составе файла */

  define variable v-num-lines as integer   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-num-lines = chCodeModule :CountOfLines
    .
    chCodeModule :DeleteLines(1, v-num-lines) .
  end.

end procedure. /* clear-macro */