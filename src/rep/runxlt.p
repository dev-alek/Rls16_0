block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: runxlt.p $
$Archive: rep/runxlt.p $

Печать в Excel по шаблону и списку файлов данных.

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Input:

Output:

*/
define input parameter p-data-file-list-name    as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: runxlt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/runxlt.p $":U .
define variable vss-description as character no-undo init "Печать в Excel по шаблону и списку файлов данных.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/paramls.i  }

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
            if buf_temp-param.param-code <> {&paramls-file}
            or buf_temp-param.param-sub-code <> {&paramls-file-out-list}
            then do:        /* Остаётся список файлов Excel, которые надо открыть */
                delete buf_temp-param.
            end.
        end.
        create buf_temp-param.
    /*    assign*/
    /*        v-template-file-name    = "d:\ww\2\t12_97.xlt"*/
    /*        v-vb-file-name          = "d:\ww\2\t_97.bas"*/
    /*        v-data-header-filename  = "d:\tmp\p55029xc.txt"*/
    /*        v-data-filename         = "d:\tmp\p54989xd.txt"*/
    /*    .*/
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
              input {&paramls-template}
            , input {&paramls-template-file-name}
            , input v-template-file-name
        ).
        run paramls-write in this-procedure (
              input {&paramls-template}
            , input {&paramls-vb-file-name}
            , input v-vb-file-name
        ).
        run paramls-write in this-procedure (
              input {&paramls-data}
            , input {&paramls-data-header-filename}
            , input v-data-header-filename
        ).
        run paramls-write in this-procedure (
              input {&paramls-data}
            , input {&paramls-data-filename}
            , input v-data-filename
        ).
    /*    run paramls-write in this-procedure (*/
    /*          input {&paramls-saveas}*/
    /*        , input {&paramls-excel-file-name}*/
    /*        , input v-excel-file-name*/
    /*    ).*/
    /*    run paramls-write in this-procedure (*/
    /*          input "charcol"*/
    /*        , input ""*/
    /*        , input "2"*/
    /*    ).*/
        assign
            v-counter = v-counter + 1
        .
        if v-counter < v-excel-files-count
        then do:
            run paramls-write in this-procedure (
                  input {&paramls-file}
                , input {&paramls-file-no-open}
                , input "yes":U
            ).
        end.
        else do:
            run paramls-write in this-procedure (
                  input {&paramls-file}
                , input {&paramls-file-no-open}
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