block-level on error undo, throw.
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-param no-undo   field param-code     as character   field param-sub-code as character   field param-value    as character   index xpk is primary unique param-code param-sub-code   .
procedure paramls-clear :
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    for each buf_temp-param
    on error undo, return error
    :
      delete buf_temp-param .
    end.
  end.
end procedure.
procedure paramls-write :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
      .
    end.
    assign
      buf_temp-param.param-value = p-value
    .
  end.
end procedure.
procedure paramls-read :
  define input  parameter p-code          as character no-undo .
  define input  parameter p-sub-code      as character no-undo .
  define input  parameter p-default-value as character no-undo .
  define output parameter p-value         as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if available buf_temp-param then do:
      assign
        p-value = buf_temp-param.param-value
      .
    end.
    else do:
      assign
        p-value = p-default-value
      .
    end.
  end.
end procedure.
procedure paramls-append :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
         where buf_temp-param.param-code     = p-code
           and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
        buf_temp-param.param-value    = p-value
      .
    end.
    else do:
        assign
            buf_temp-param.param-value = buf_temp-param.param-value + ",":U + p-value
        .
    end.
  end.
end procedure.
define input-output parameter table for temp-param .
define variable vss-revision    as character no-undo init "$Revision: bbf1530230d5, 2753, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Сб фев 20 15:59:21 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: macroxlt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/macroxlt.p $":U .
define variable vss-description as character no-undo init "Программа формирования файла Excel из шаблона.".
define variable mTextError      as character no-undo.
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer buf_temp-param for temp-param .
    define variable v-macroxlt-counter          as integer          no-undo .
    define variable chExcelApp                  as com-handle       no-undo .
    define variable chWorkBook                  as com-handle       no-undo .
    define variable chCodeModule                as com-handle       no-undo .
    define variable v-counter                   as integer          no-undo .
    define variable v-excel-file-name           as character        no-undo .
    define variable v-read-password             as character        no-undo .
    define variable v-write-password            as character        no-undo .
    define variable v-excel-dir-name            as character        no-undo .
    define variable v-ind                       as integer          no-undo .
    define variable v-excel-macro-file          as character        no-undo .
    define variable v-ok                        as logical          no-undo .
    define variable v-column-list               as character        no-undo .
    define variable v-excel-visible-char        as character        no-undo .
    define variable v-template-file-name        as character        no-undo .
    define variable v-vb-file-name              as character        no-undo .
    define variable v-default-excel-file-name   as character        no-undo .
    define variable v-data-header-filename      as character        no-undo .
    define variable v-data-filename             as character        no-undo .
    define variable v-temp-string               as character        no-undo .
    define variable v-version                   as character        no-undo .
    define variable v-version-dec               as decimal          no-undo .
    define variable v-found-reg-entry           as logical          no-undo .
    define variable v-trusted                   as character        no-undo .
do
on error undo, return error
:
    run paramls-read in this-procedure (
          input "saveas":U
        , input "excel-file-name":U
        , input "":U
        , output v-excel-file-name
    ).
    run paramls-read in this-procedure (
          input "saveas":U
        , input "read-password":U
        , input  "":U
        , output v-read-password
    ).
    run paramls-read in this-procedure (
          input  "saveas":U
        , input  "write-password":U
        , input  "":U
        , output v-write-password
    ).
    run paramls-read in this-procedure (
          input "option":U
        , input "visible":U
        , input "true":U
        , output v-excel-visible-char
    ).
    run paramls-read (
          input "template":U
        , input "template-file-name":U
        , input "":U
        , output v-template-file-name
    ) .
    run paramls-read (
          input "template":U
        , input "vb-file-name":U
        , input "":U
        , output v-vb-file-name
    ) .
    run paramls-read (
          input "data":U
        , input "data-header-filename":U
        , input "":U
        , output v-data-header-filename
    ) .
    run paramls-read (
          input "data":U
        , input "data-filename":U
        , input "":U
        , output v-data-filename
    ) .
    define variable v-file-no-open-string   as character    no-undo.
    define variable v-file-no-open          as logical      no-undo.
    run paramls-read (
          input "file":U
        , input "file-no-open":U
        , input "yes":U
        , output v-file-no-open-string
    ) .
    assign
        v-file-no-open = ( v-file-no-open-string = "yes":U )
    .
    create "Excel.Application" chExcelApp no-error .
    if error-status :error then do:
        mTextError = substitute("&1~n&2"
            ,"Ошибка при запуске Excel"
            ,error-status :get-message(1)
          ).
        if not session:batch-mode then
          message
            mTextError
            view-as alert-box error.
        undo, return error mTextError.
    end.
    assign
        chExcelApp :WindowState = -4140
        chExcelApp :Visible     = False
        chExcelApp :Interactive = False
    .
      assign
        v-version = chExcelApp :version
      no-error.
      assign
        v-version-dec = decimal(v-version)
      no-error .
      if error-status:error then do:
        mTextError = "Не удалось определить версию Excel".
        if not session:batch-mode then
            message
            mTextError
            view-as alert-box error .
        release object chCodeModule no-error .
        release object chWorkBook   no-error .
        release object chExcelApp   no-error .
        undo, return error mTextError.
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
          mTextError = "Не удалось определить политику безопасности для данной версии Excel".
          if not session:batch-mode then
              message
              mTextError
              view-as alert-box error .
          release object chCodeModule no-error .
          release object chWorkBook   no-error .
          release object chExcelApp   no-error .
          undo, return error mTextError.
        end.
        if not v-found-reg-entry
        or trim(v-trusted) = "0":U then do:
            mTextError = substitute("&1~n&2~n&3~n&4~n&5~n&6~n&7"
              ,"На Вашей машине запрещен программный доступ к VisualBasicProject"
              ,"В связи с этим вывод в EXCEL невозможен"
              ,"возможное решение проблемы:"
              ,"открыть в EXCEL диалог <Сервис\Макрос\Безопасность> (<Tools\Macro\Security>)"
              ,"выбрать закладку <Надежные источники> (<Trusted Sources>)  и включить галочку"
              ,"<Доверять доступ Visual Basic Project> (<Trust access to Visual Basic Project>)"
              ,"Затем закрыть Excel").
          if not session:batch-mode then
              message
              mTextError
              view-as alert-box ERROR.
          release object chCodeModule no-error .
          release object chWorkBook   no-error .
          release object chExcelApp   no-error .
          undo, return error mTextError.
        end.
      end.
    assign
        v-temp-string        = v-template-file-name
        v-template-file-name = search( v-template-file-name )
    .
    if v-vb-file-name = ?
    then do:
        mTextError = substitute("&1~n~n&2&3"
          ,"Не найден шаблон Excel."
          ,"Необходим шаблон:"
          ,v-temp-string
        ).
        if not session:batch-mode then
            message
                vss-workfile vss-revision vss-description skip
            view-as alert-box error.
        undo, return error mTextError.
    end.
    assign
        chWorkBook = chExcelApp :Workbooks :Add( v-template-file-name )
    .
    assign
        chCodeModule = chWorkbook :VBProject :VBComponents :Item(1) :CodeModule
    .
    define variable v-book-name    as character    no-undo.
    assign
        v-book-name = chWorkBook :CodeName
    .
    assign
        v-temp-string  = v-vb-file-name
        v-vb-file-name = search( v-vb-file-name )
    .
    if v-vb-file-name = ?
    then do:
        mTextError = substitute("&1~n~n&2&3~n&4&5"
          ,"Не найдена программа обработки шаблона Excel."
          ,"Шаблон:"
          ,v-template-file-name
          ,"Необходима программа:",
          v-temp-string
        ).
        if not session:batch-mode then
            message
                vss-workfile vss-revision vss-description skip
                mTextError
            view-as alert-box error.
        undo, return error mTextError.
    end.
    run load-basic in this-procedure (
          input v-vb-file-name
        , input v-book-name
        , input v-template-file-name
        , input v-data-header-filename
        , input v-data-filename
    ).
    assign
        v-ok = chWorkbook :LoadBasic
    .
    assign
        v-ok = chWorkbook :StartApp
    .
    for each buf_temp-param
       where buf_temp-param.param-code = "command":U
    by buf_temp-param.param-sub-code
    on error undo, leave
    :
        assign
            v-ok = chWorkbook :DDEExecCommand( buf_temp-param.param-value )
        .
    end.
    assign
        chExcelApp:DisplayAlerts = False
    no-error .
    assign
        v-default-excel-file-name = chWorkBook:FullName
    no-error .
    if v-excel-file-name = "":U
    or v-excel-file-name = ?
    then do:
        run gbl/_tmpfile.p (
              input  ""
            , input  ".xls"
            , output v-excel-file-name
        ).
        run gbl/d-file.p (
              input-output v-excel-file-name
            , input-output v-excel-dir-name
            , input  (" Все файлы EXCEL (*.xls) ")
            , input  ("*.xls":U)
            , input  chr(44)
            , input  (".xls":U)
            , input  no
            , input  yes
            , input  yes
            , input  "Введите имя файла"
            , output v-ok
        ) .
        if v-ok <> true
        then do:
            assign
                chWorkBook :Saved = true
            .
            assign
                v-ok = chWorkBook :close no-error
            .
            release object chCodeModule no-error .
            release object chWorkBook   no-error .
            assign
                v-ok = chExcelApp:Quit()
            no-error.
            release object chExcelApp   no-error .
            undo, return error "quit":U .
        end.
        if search( v-excel-file-name ) <> ?
        then do:
            os-delete value( v-excel-file-name ).
        end.
    end.
    if v-read-password <> "":U
    and v-write-password <> "":U
    then do:
        assign
            v-ok = chWorkBook :SaveAs( v-excel-file-name, -4143, v-read-password, v-write-password , , , ) no-error
        .
    end.
    else do:
        if v-write-password <> "":U
        then do:
            assign
                v-ok = chWorkBook :SaveAs( v-excel-file-name, -4143, , v-write-password , , , ) no-error
            .
        end.
        else do:
            assign
                v-ok = chWorkBook :SaveAs( v-excel-file-name, -4143 , , , , , ) no-error
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
    or v-excel-file-name = ?
    then do:
        release object chCodeModule no-error .
        release object chWorkBook   no-error .
        release object chExcelApp   no-error .
        if not session:batch-mode then
            message
                "Ошибка при сохранении файла"
                skip "Сохраните Excel файл вручную"
            view-as alert-box information .
    end.
    else do:
        assign
            chWorkBook :Saved = true
        .
        assign
            v-ok = chWorkBook :close no-error
        .
        release object chCodeModule no-error .
        release object chWorkBook   no-error .
        assign
            v-ok = chExcelApp:Quit()
        no-error.
        release object chExcelApp   no-error .
        run paramls-append in this-procedure (
              input "file":U
            , input "file-out-list":U
            , input v-excel-file-name
        ).
        if v-file-no-open = no
        then do:
            define variable v-excel-file-list    as character    no-undo.
            define variable v-excel-file-count   as integer      no-undo.
            run paramls-read in this-procedure (
                  input "file":U
                , input "file-out-list":U
                , input "":U
                , output v-excel-file-list
            ).
            assign
                v-excel-file-count = num-entries( v-excel-file-list )
            .
            do v-counter = 1 to v-excel-file-count
            :
                assign
                    v-excel-file-name = entry( v-counter, v-excel-file-list )
                .
                run rep/killspac.p (
                    input-output v-excel-file-name
                ).
                run gbl/open_url.p (
                    input v-excel-file-name
                ).
            end.
        end.
    end.
end.
procedure append-macro-line :
define input  parameter p-macro-str as character no-undo .
do
on error undo, return error return-value
:
    assign
        v-macroxlt-counter = v-macroxlt-counter + 1
    .
    assign
        v-ok = chCodeModule :InsertLines( v-macroxlt-counter, p-macro-str )
    .
end.
end procedure.
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
end procedure.
procedure load-basic :
define input parameter p-vb-file-name           as character        no-undo.
define input parameter p-book-name              as character        no-undo.
define input parameter p-template-file-name     as character        no-undo.
define input parameter p-data-header-filename   as character        no-undo.
define input parameter p-data-filename          as character        no-undo.
    define variable v-command-string    as character    no-undo.
  assign
    v-ind = 0
  .
  do
  on error undo, return error return-value
  :
    run append-macro-line ( input 'Sub LoadBasic').
    assign
        v-command-string = substitute( '  VBAProject.&1.VBProject.VBComponents.Import "&2"'
                                , p-book-name
                                , p-vb-file-name
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
        v-command-string = substitute( '  call VBAProject.startFormFromTemplate ("&1", "&2")'
                                , p-data-header-filename
                                , p-data-filename
                           )
    .
    run append-macro-line ( input v-command-string ).
    run append-macro-line ( input substitute( 'For Each mModule In VBAProject.&1.VBProject.VBComponents', p-book-name ) ).
    run append-macro-line ( input 'If mModule.Type = 1 Then').
    run append-macro-line ( input substitute( '    VBAProject.&1.VBProject.VBComponents.Remove VBAProject.&1.VBProject.VBComponents(mModule.Name)', p-book-name ) ).
    run append-macro-line ( input 'End If').
    run append-macro-line ( input 'Next mModule').
    run append-macro-line ( input '  Application.Interactive = True').
    run append-macro-line ( input '  Application.ScreenUpdating = True').
    run append-macro-line ( input substitute( 'For Each mModule In VBAProject.&1.VBProject.VBComponents', p-book-name ) ).
    run append-macro-line ( input '    liCount = mModule.CodeModule.CountOfLines').
    run append-macro-line ( input '    mModule.CodeModule.DeleteLines 1, liCount').
    run append-macro-line ( input 'Next mModule').
    run append-macro-line ( input 'End Sub').
  end.
end procedure.
procedure clear-macro :
  define variable v-num-lines as integer   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-num-lines = chCodeModule :CountOfLines
    .
    chCodeModule :DeleteLines(1, v-num-lines) .
  end.
end procedure.
