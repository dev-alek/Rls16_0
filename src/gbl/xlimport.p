block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: xlimport.p $
$Archive: gbl/xlimport.p $

Процедура импорта из формата xls

Автор: Белоусов Илья Александрович
Дата создания: 02/05/07
Author: Ilia Belousov
Creation date: 02/05/07

Input:
    p-filename       as character  - Имя файла xls (данные)
    p-out-filename   as character  - Имя файла для вывода
    p-vb-filename    as character  - Имя файла bas (обработчик)

Output:


Пример использования:

    run gbl/xlimport.p (
          input "D:\Table2612.xls"
        , input "D:\111.txt"
        , input "imp/src08.bas"
    ).

*/
define input parameter p-filename       as character        no-undo.
define input parameter p-parameter      as character        no-undo.
define input parameter p-vb-filename    as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: xlimport.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/xlimport.p $":U .
define variable vss-description as character no-undo init "Процедура импорта из формата xls".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }


define variable v-xlimport-macro-line-counter    as integer      no-undo.

define variable v-ok            as logical      no-undo.
define variable v-vb-filename   as character    no-undo.
define variable v-filename      as character    no-undo.
define variable v-version       as character no-undo .
define variable v-version-dec   as decimal   no-undo .
define variable v-found-reg-entry as logical no-undo .
define variable v-trusted as character no-undo .

define variable chExcelApp                  as com-handle       no-undo.
define variable chWorkBook                  as com-handle       no-undo.
define variable chCodeModule                as com-handle       no-undo.
do
on error undo, return error
:
    assign
        v-filename      = search( p-filename    )
        v-vb-filename   = search( p-vb-filename )
    .
    if v-filename = ?
    then do:
        message
            "Не найден файл Excel"
            skip p-filename
        view-as alert-box error.
        undo, return error .
    end.
    if v-vb-filename = ?
    then do:
        message
            "Не найден файл обработки"
            skip p-vb-filename
        view-as alert-box error.
        undo, return error .
    end.
    create "Excel.Application" chExcelApp no-error .
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
    /* Ни в коем случае нельзя запускать EXCEL в невидимом режиме */
    /* он в этом случае работает в 4 раза медленнее. */
    /* Почему это происходит неизвестно. */
    /* Кроме того, при выводе отчета в строке состояния Excel будет выводиться */
    /* количество обработанных команд */

    assign
    chExcelApp :WindowState = {&xlMinimized}
    chExcelApp :Visible     = False
    chExcelApp :Interactive = False
    /*chExcelApp :WindowState = {&xlNormal}*/
    chExcelApp :Visible     = yes
    chExcelApp :Interactive = yes
    v-version = chExcelApp:version
    no-error
    .
    assign
    v-version-dec = decimal(v-version)
    no-error .
    if error-status:error then do:
      run  clearexcel in this-procedure .
      message "Не удалось определить версию Excel"
      view-as alert-box error .
      return error '':U.
    end.
    if v-version-dec > 9 then do:
      run gbl/getregvl.p (
                       input "HKEY_CURRENT_USER":U
                      ,input  "SOFTWARE":U
                      ,input ("Microsoft\Office\" + string(v-version-dec, ">9.9":U) + "\Excel\Security":U)
                      ,input  "AccessVBOM":U
                      ,output v-found-reg-entry
                      ,OUTPUT v-trusted) no-error .
      if error-status:error then do:
        message
        "Не удалось определить политику безопасности для данной версии Excel"
        view-as alert-box error .
        run  clearexcel in this-procedure .
        return error '':U.
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
        run  clearexcel in this-procedure .
        return error '':U.
      end.
    end.
    assign
    chWorkBook = chExcelApp :Workbooks :Add( v-filename )
    .
    assign
    chCodeModule = chWorkbook :VBProject :VBComponents :Item(1) :CodeModule
    .
    run load-basic in this-procedure (
          input v-filename
        , input v-vb-filename
    ).
    assign
        v-ok = chWorkbook:LoadBasic
    .
    assign
        v-ok = chWorkbook:StartApp
    .

    assign
        chExcelApp :DisplayAlerts = False
    .
    run clearexcel in this-procedure .

end.

procedure load-basic :
define input parameter p-filename       as character        no-undo.
define input parameter p-vb-filename    as character        no-undo.
define variable chCodeModule as com-handle no-undo .
define variable num-of-lines as integer no-undo .


    define variable v-command-string    as character    no-undo.

  do
  on error undo, return error return-value
  :
  assign
    chCodeModule = chWorkbook :VBProject :VBComponents :Item(1) :CodeModule
  .
  assign
  num-of-lines = chCodeModule :CountOfLines.
  chCodeModule:DeleteLines(1, num-of-lines).


    run append-macro-line ( input 'Sub LoadBasic').
/*    run append-macro-line ( input '  Application.ScreenUpdating = False').*/
/*    run append-macro-line ( input '  Application.Interactive = False').*/

    assign
        v-command-string = substitute( '  ThisWorkbook.VBProject.VBComponents.Import "&1"'
                                , p-vb-filename
                           )
    .
    run append-macro-line ( input v-command-string ).
    run append-macro-line ( input '  Application.Interactive = True').
    run append-macro-line ( input '  Application.ScreenUpdating = True').
    run append-macro-line ( input 'End Sub').
    run append-macro-line ( input 'Sub StartApp').
    run append-macro-line ( input 'Dim mModule As Object').
    run append-macro-line ( input 'Dim liCount As Long').
    run append-macro-line ( input '  Application.ScreenUpdating = False').
    run append-macro-line ( input '  Application.Interactive = False').
    assign
        v-command-string = substitute( '  call VBAProject.mainMacro ("&1")'
                                , p-parameter
                           )
    .
    run append-macro-line ( input v-command-string ).
    run append-macro-line ( input 'For Each mModule In ThisWorkbook.VBProject.VBComponents').
    run append-macro-line ( input 'If mModule.Type = 1 Then').
    run append-macro-line ( input '    ThisWorkbook.VBProject.VBComponents.Remove ThisWorkbook.VBProject.VBComponents(mModule.Name)').
    run append-macro-line ( input 'End If').
    run append-macro-line ( input 'Next mModule').
    run append-macro-line ( input '  Application.Interactive = True').
    run append-macro-line ( input '  Application.ScreenUpdating = True').
    run append-macro-line ( input 'For Each mModule In ThisWorkbook.VBProject.VBComponents').
    run append-macro-line ( input '    liCount = mModule.CodeModule.CountOfLines').
    run append-macro-line ( input '    mModule.CodeModule.DeleteLines 1, liCount').
    run append-macro-line ( input 'Next mModule').
    run append-macro-line ( input 'End Sub').
  end.

end procedure. /* load-basic */


procedure append-macro-line :
define input  parameter p-macro-str as character no-undo .

do
on error undo, return error return-value
:
    assign
        v-xlimport-macro-line-counter = v-xlimport-macro-line-counter + 1
    .
    assign
        v-ok = chCodeModule :InsertLines( v-xlimport-macro-line-counter, p-macro-str )
    .
end.

end procedure. /* append-macro-line */

procedure ClearExcel :
define variable v-ok as logical no-undo .
  do
  on error undo, return error
  :
    release object chCodeModule no-error .
    release object chWorkBook   no-error .
    assign
        v-ok = chExcelApp:Quit()
    no-error.
    release object chExcelApp   no-error .
    PROCESS EVENTS.
  end.

end procedure. /* ClearExcel */