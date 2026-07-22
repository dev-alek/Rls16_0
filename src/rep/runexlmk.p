block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: runexlmk.p $
$Archive: rep/runexlmk.p $

Запуск дополнительной сессии для вывода в Excel

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/

define input parameter tempfile as char no-undo.
define input parameter p-list-name as char no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: runexlmk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/runexlmk.p $":U .
define variable vss-description as character no-undo init "Вывод в Excel с запуском дополнительной сессии".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
/*{ cmp/r-page1.i  }*/
{ gbl/waitfram.i }


define variable tempfile-frm as character no-undo .
define variable tempfile-t-t as character no-undo .
define variable res          as integer   no-undo .
define variable v-cmdln      as character no-undo .
define variable v-exefile    as character no-undo .
define variable v-inifile    as character no-undo .
define variable err-file     as character no-undo .

define stream forformat .

do
on error undo, return error return-value
:
  define variable v-full-path        as character no-undo .
  define variable v-path             as character no-undo .
  define variable v-file-name        as character no-undo .
  define variable v-file-name-no-ext as character no-undo .
  define variable v-file-name-ext    as character no-undo .

  run gbl/filename.p (input  tempfile, output v-full-path, output v-path, output v-file-name, output v-file-name-no-ext, output v-file-name-ext) .

  assign
    tempfile-frm = v-path + '/':u + v-file-name-no-ext + '.':U + 'frm':U
    tempfile-t-t = v-path + '\':u + v-file-name-no-ext + '.':U + 't-t':U
  .
  run mcr-rep-mk (input tempfile-t-t, input v-path + '\':u + v-file-name-no-ext, input p-list-name) .

  os-delete  value( tempfile-t-t ) .
  os-delete  value( tempfile  ) .

  define variable err-status as integer   no-undo .
  err-status = OS-ERROR.
  IF err-status <> 0 THEN  return "disable-button":U.
                     else  return.
end.


{ gbl/paramls.i  }


define stream  inStream  .

procedure mcr-rep-mk :
  define input parameter  v-file-name as character no-undo .
  define input parameter  v-file-name1 as character no-undo .
  define input parameter  v-list-name as character no-undo .
  do
  on error undo, return error return-value
  :
  define variable v-count  as integer no-undo .
  define variable v-param-code     as character no-undo .
  define variable v-param-sub-code as character no-undo .
  define variable v-param-value    as character no-undo .

  input stream instream from value (v-file-name) .
  repeat  :
    assign
      v-count = v-count + 1
      v-param-code     = ''
      v-param-sub-code = ''
      v-param-value    = ''
    .
    import stream instream  v-param-code  v-param-sub-code  v-param-value .
    create temp-param .
    assign
      temp-param.param-code     = v-param-code
      temp-param.param-sub-code = v-param-sub-code
      temp-param.param-value    = v-param-value
    .
  end.
  input stream instream close .

  define variable v-ok as logical   no-undo .
  run macroexl-mk (input v-file-name1, input v-list-name, input-output table temp-param  ) .

  /* удаляем файлы отчета */
  os-delete value (v-file-name) .

  define buffer buf_temp-param for temp-param .
  for each buf_temp-param  where buf_temp-param.param-code = "file" on error undo, return error :
    os-delete value(buf_temp-param.param-value) .
  end.

  end.
end procedure. /* mcr-rep-mk */



&scop xlMinimized  -4140
&scop xlNormal     -4143

define buffer buf_temp-param for temp-param .

define variable chExcelApp   as com-handle no-undo .
define variable chWorkBook   as com-handle no-undo .
define variable chCodeModule as com-handle no-undo .

define variable v-ind              as integer   no-undo .
define variable v-excel-macro-file as character no-undo .
define variable v-ok               as logical   no-undo .


procedure macroexl-mk :
  define input parameter v-file-name as character no-undo .
  define input parameter v-list-name as character no-undo .
  define input-output parameter table for temp-param .
  do
  on error undo, return error return-value
  :
  define variable v-excel-file-name as character no-undo .
  define variable v-read-password   as character no-undo .
  define variable v-write-password  as character no-undo .
  define variable v-excel-dir-name  as character no-undo .

  /* определяем имя файла и параметры сохранения */
  assign
    v-excel-file-name = v-file-name + ".xls"
  .

  if search(v-excel-file-name) <> ? then do:
    os-delete value(v-excel-file-name) .
  end.

  define variable v-column-list as character no-undo .

  run paramls-read in this-procedure  (input  "charcol" ,input  "" ,input  "" ,output v-column-list ) .

  create "Excel.Application" chExcelApp no-error .
  if error-status :error then do:
    message
      "Ошибка при запуске Excel" skip
      error-status :get-message(1) skip
      view-as alert-box error .
    undo, return error .
  end.

  define variable v-excel-visible-char as character no-undo .
  run paramls-read  (input "option",input "visible",input "true",output v-excel-visible-char ) .
  assign
    chExcelApp :Visible = lookup(v-excel-visible-char, "true,yes") > 0
  .
  assign
    chExcelApp :WindowState = {&xlNormal}
    chExcelApp :Visible     = True
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

  run export-macro in this-procedure .

  for each buf_temp-param
    where buf_temp-param.param-code = "file"
  by buf_temp-param.param-sub-code descending
  on error undo, return error
  :

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
    assign  v-ok = chWorkbook :DDEExec(v-excel-macro-file,v-list-name , v-column-list) .
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

  if  v-read-password <> ""  and v-write-password <> "" then do:
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

/*    run gbl/open_url.p (v-excel-file-name) .*/
  end.


  end.
end procedure. /* macroexl-mk */


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