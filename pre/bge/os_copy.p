block-level on error undo, throw.
define input parameter  v-operation as character format "X(1)"  no-undo.
define input parameter  v-file-in   as character                no-undo.
define input parameter  v-file-out  as character                no-undo.
define output parameter v-error-num as integer                  no-undo.
define variable vss-revision    as character no-undo init "$Revision: c89b59c2f62e, 135, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Mon Feb 16 20:48:25 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: os_copy.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/os_copy.p $":U .
define variable vss-description as character no-undo init "Копирование, перенос, удаление, печать файлов ОС".
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
    define variable v-error-name as char extent 19 init [
        "Чужой файл",
        "Нет такого файла/директории",
        "Работа процедуры прервана",
        "Ошибка ввода-вывода",
        "Неправильный номер файла",
        "Слишком много процессов",
        "Не хватает памяти",
        "Нарушение прав доступа",
        "Неправильный адрес",
        "Файл не удален",
        "Нет такого устройства",
        "Вместо директории указан файл",
        "Вместо файла указана директория",
        "Переполнение таблицы файлов",
        "Слишком много открытых файлов",
        "Слишком большой файл",
        "Не хватает места на диске",
        "Директория не пуста",
        "НЕИЗВЕСТНАЯ ОШИБКА"
    ] no-undo.
    define variable v-operation-num  as integer     no-undo.
    define variable v-operation-list as character   no-undo.
    define variable v-operation-name as character extent 4 init [
          "Копирование из "
        , "Перенос из "
        , "Удаление "
        , "Печать "
    ] no-undo.
do
on error undo, return error
:
    assign
        v-operation-list    = "CMDP"
        v-operation-num     = index( v-operation-list, v-operation )
    .
    if v-operation-num = 0
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Неправильный тип операции."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    assign
        v-operation-name[ v-operation-num ] = v-operation-name[ v-operation-num ]
                                                + v-file-in
                                                + ( if v-operation-num > 2
                                                    then ""
                                                    else " в " + v-file-out )
    .
    case v-operation-num:
        when 1
        then do:
            os-copy value(v-file-in) value(v-file-out).
        end.
        when 2
        then do:
            os-rename value(v-file-in) value(v-file-out).
            if os-error = 999
            then do:
                os-copy value(v-file-in) value(v-file-out).
                if os-error = 0 then OS-DELETE value(v-file-in) RECURSIVE.
            end.
        end.
        when 3
        then do:
            os-delete value( v-file-in ) recursive.
        end.
        when 4
        then do:
            os-command silent copy value(v-file-in) value(v-file-out).
        end.
    end case.
    assign
        v-error-num = ( if v-operation-num = 3 and os-error = 2 then 0 else os-error ).
    .
    if v-error-num > 0
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip v-operation-name[ v-operation-num ]
                    + " - ошибка "
                    + trim( string( v-error-num, ">>9" ) )
                    + ": "
                    + v-error-name[ min( v-error-num, 19 ) ]
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
end.
