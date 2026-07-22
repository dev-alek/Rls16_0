block-level on error undo, throw.
/*

$Revision: c89b59c2f62e, 135, rls $
$Author: EShklyar $
$Date: Mon Feb 16 20:48:25 2015 +0400 $
$Workfile: os_copy.p $
$Archive: bge/os_copy.p $

Копирование, перенос, удаление, печать файлов ОС

Автор: Хныкин Павел Андреевич
Дата создания: 03/31/06
Author: Pavel Khnykin
Creation date: 03/31/06

Input:

Output:

*/
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
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

    define variable v-error-name as char extent 19 init [
        "Чужой файл",                      /* Not owner                         */
        "Нет такого файла/директории",     /* No such file or directory         */
        "Работа процедуры прервана",       /* Interrupted system call           */
        "Ошибка ввода-вывода",             /* I/O error                         */
        "Неправильный номер файла",        /* Bad file number                   */
        "Слишком много процессов",         /* No more processes                 */
        "Не хватает памяти",               /* Not enough core memory            */
        "Нарушение прав доступа",          /* Permission denied                 */
        "Неправильный адрес",              /* Bad address                       */
        "Файл не удален",                  /* File exists                       */
        "Нет такого устройства",           /* No such device                    */
        "Вместо директории указан файл",   /* Not a directory                   */
        "Вместо файла указана директория", /* Is a directory                    */
        "Переполнение таблицы файлов",     /* File table overflow               */
        "Слишком много открытых файлов",   /* Too many open files               */
        "Слишком большой файл",            /* File too large                    */
        "Не хватает места на диске",       /* No space left on device           */
        "Директория не пуста",             /* Directory not empty               */
        "НЕИЗВЕСТНАЯ ОШИБКА"               /* Unmapped error (PROGRESS default) */
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
    /* Отсутствие удаляемого файла не должно давать ошибку */
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