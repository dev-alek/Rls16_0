block-level on error undo, throw.
define input parameter p-data-file-list-name    as character        no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: runxlt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/runxlt.p $":U .
define variable vss-description as character no-undo init "Печать в Excel по шаблону и списку файлов данных.".
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
    define stream in-stream.
    define variable v-template-file-name    as character    no-undo.
    define variable v-vb-file-name          as character    no-undo.
    define variable v-data-header-filename  as character    no-undo.
    define variable v-data-filename         as character    no-undo.
    define buffer buf_temp-param for temp-param .
do
for buf_temp-param
on error undo, return error
:
    assign
        p-data-file-list-name = search( p-data-file-list-name )
    .
    if p-data-file-list-name = ?
    or p-data-file-list-name = "":U
    then do:
        message
            "Не найден список файлов данных."
            skip (1)
            skip "Указан файл:" p-data-file-list-name
        view-as alert-box error.
    end.
    define variable v-counter               as integer      no-undo.
    define variable v-excel-files-count     as integer      no-undo.
    assign
        v-counter           = 0
        v-excel-files-count = 0
    .
    input stream in-stream from value( p-data-file-list-name ).
    repeat
    :
        import stream in-stream v-template-file-name   .
        import stream in-stream v-vb-file-name         .
        import stream in-stream v-data-header-filename .
        import stream in-stream v-data-filename        .
        assign
            v-excel-files-count = v-excel-files-count + 1
        .
    end.
    input stream in-stream close.
    input stream in-stream from value( p-data-file-list-name ).
    repeat
    :
        import stream in-stream v-template-file-name   .
        import stream in-stream v-vb-file-name         .
        import stream in-stream v-data-header-filename .
        import stream in-stream v-data-filename        .
        if search( v-template-file-name ) = ?
        then do:
            message
                skip "Не найден шаблон Excel для вывода данных."
                skip(1)
                skip "Указан файл шаблона:" v-template-file-name
            view-as alert-box error.
            undo, return error .
        end.
        if search( v-vb-file-name ) = ?
        then do:
            message
                skip "Не найден текст программы заполнения"
                skip "шаблона Excel."
                skip(1)
                skip "Файл шаблона:" v-template-file-name
                skip "Указан файл программы:" v-vb-file-name
            view-as alert-box error.
            undo, return error .
        end.
        if v-data-header-filename <> "":U
        and search( v-data-header-filename ) = ?
        then do:
            message
                skip "Не найден файл шапки."
                skip(1)
                skip "Файл шаблона:" v-template-file-name
                skip "Указан файл шапки:" v-data-header-filename
            view-as alert-box error.
            undo, return error .
        end.
        if v-data-filename <> "":U
        and search( v-data-filename )   = ?
        then do:
            message
                skip "Не найден файл строк данных."
                skip(1)
                skip "Файл шаблона:" v-template-file-name
                skip "Указан файл строк данных:" v-data-filename
            view-as alert-box error.
            undo, return error .
        end.
        for each buf_temp-param
        :
            if buf_temp-param.param-code <> "file":U
            or buf_temp-param.param-sub-code <> "file-out-list":U
            then do:
                delete buf_temp-param.
            end.
        end.
        create buf_temp-param.
        assign
            v-template-file-name = search( v-template-file-name )
        .
        if v-template-file-name = ?
        or v-template-file-name = "":U
        then do:
            message
                "Ошибка имени файла шаблона."
            view-as alert-box error.
        end.
        run paramls-write in this-procedure (
              input "template":U
            , input "template-file-name":U
            , input v-template-file-name
        ).
        run paramls-write in this-procedure (
              input "template":U
            , input "vb-file-name":U
            , input v-vb-file-name
        ).
        run paramls-write in this-procedure (
              input "data":U
            , input "data-header-filename":U
            , input v-data-header-filename
        ).
        run paramls-write in this-procedure (
              input "data":U
            , input "data-filename":U
            , input v-data-filename
        ).
        assign
            v-counter = v-counter + 1
        .
        if v-counter < v-excel-files-count
        then do:
            run paramls-write in this-procedure (
                  input "file":U
                , input "file-no-open":U
                , input "yes":U
            ).
        end.
        else do:
            run paramls-write in this-procedure (
                  input "file":U
                , input "file-no-open":U
                , input "no":U
            ).
        end.
        run gbl/macroxlt.p (
            input-output table buf_temp-param
        ) no-error.
        if error-status :error
        and return-value <> "quit"
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка создания файла Excel."
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end.
    input stream in-stream close.
    os-delete value(p-data-file-list-name).
end.
