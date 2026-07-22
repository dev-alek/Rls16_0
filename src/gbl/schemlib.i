/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы со схемой БД

Автор: Белоусов Илья Александрович
Дата создания: 05/08/08
Author: Ilia Belousov
Creation date: 05/08/08

Input:

Output:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

/*==========================================================================
    Возвращает список полей первичного ключа таблицы БД.
*/
procedure schemlib-get-index-fields :
define input parameter p-table-name     as character        no-undo.
define output parameter p-field-list    as character        no-undo.

    define variable v-table-handle          as handle       no-undo.
    define variable v-field-handle          as handle       no-undo.
    define variable v-index-info            as character    no-undo.
    define variable v-counter               as integer      no-undo.
    define variable v-index-fields-amount   as integer      no-undo.
do
on error undo, return error
:
    if p-table-name = ?
    or p-table-name = "":U
    then do:
        return error substitute( "&1 (get-index-fields). Ошибка задания входных параметров. Задано пустое имя таблицы.", vss-workfile ).
    end.
    create buffer v-table-handle for table p-table-name no-error.
    if error-status :error
    then do:
        return error substitute( "&1 (get-index-fields). Ошибка задания входных параметров. Неверно задано имя таблицы '&2'.", vss-workfile, p-table-name ).
    end.
    assign
        v-counter       = 1
        v-index-info    = v-table-handle :index-information( v-counter )
    .
    do while v-index-info <> ?
    and entry( 3, v-index-info ) <> "1":U
    on error undo, return error
    :
        assign
            v-counter       = v-counter + 1
            v-index-info    = v-table-handle :index-information( v-counter )
        .
    end.
    if v-index-info = ?
    or LC( entry( 1, v-index-info ) ) = "default":U
    or entry( 3, v-index-info ) <> "1":U
    then do:
        return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, p-table-name ).
    end.
    else do:
        assign
            v-index-fields-amount = num-entries( v-index-info ) - 4
            p-field-list          = "":U
        .
        if v-index-fields-amount < 2
        then do:
            return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-index-info, p-table-name ).
        end.
        do v-counter = 1 to v-index-fields-amount by 2
        on error undo, return error
        :
            assign
                v-field-handle  = v-table-handle :buffer-field( entry( 4 + v-counter, v-index-info ) ).
            .
            assign
                p-field-list    = substitute( "&1&2&3":U
                                    , p-field-list
                                    , ( if p-field-list = "":U then "":U else ",":U )
                                    , v-field-handle :name
                                    )
            .
        end.
    end.
end.
end procedure. /* schemlib-get-index-fields */

/*==========================================================================
    Возвращает буфер таблицы p-table-name, найденный по первому нахождению
    полей p-field-list со значениями p-value-list.

    Применять в основном при поиске по уникальному ключу.
*/
procedure schemlib-set-buffer :
define input parameter p-table-name     as character        no-undo.
define input parameter p-field-list     as character        no-undo.
define input parameter p-value-list     as character        no-undo.
define output parameter p-buffer-handle as handle           no-undo.

    define variable v-query-handle      as handle       no-undo.
    define variable v-query-string      as character    no-undo.
    define variable v-field-handle      as handle       no-undo.
    define variable v-field-name        as character    no-undo.
    define variable v-field-value       as character    no-undo.
    define variable v-field-counter     as integer      no-undo.
    define variable v-counter           as integer      no-undo.
    define variable v-field-type        as character    no-undo.
do
on error undo, return error
:
    assign
        v-field-counter = num-entries( p-field-list )
    .
    if v-field-counter <> num-entries( p-value-list )
    then do:
        undo, return error substitute( "schemlib-set-buffer. Указан список значений '&1', не соответствующий списку полей '&2'."
                    , p-value-list
                    , p-field-list ).
    end.
    create buffer p-buffer-handle for table p-table-name.
    create query v-query-handle.
    v-query-handle :set-buffers( p-buffer-handle ).
    assign
        v-query-string  = substitute( "for each &1 no-lock":U, p-table-name )
    .
    do v-counter = 1 to v-field-counter
    on error undo, return error
    :
        assign
            v-field-name  = entry( v-counter, p-field-list )
            v-field-value = entry( v-counter, p-value-list )
        .
        assign
            v-field-handle = p-buffer-handle :buffer-field( v-field-name )
        .
        if not valid-handle( v-field-handle )
        then do:
            undo, return error substitute( "schemlib-set-buffer. Не найдено поле '&1' в таблице '&2'."
                    , v-field-name
                    , p-table-name ).
        end.
        assign
            v-field-type = v-field-handle :data-type
        .
        assign
            v-query-string  = substitute( "&1&2&3.&4=&5&6&5":U
                , v-query-string
                , ( if v-counter = 1 then " where ":U else " and ":U )
                , p-table-name
                , v-field-name
                , ( if v-field-type = "character":U then '"':U else "":U )
                , v-field-value
                )
        .
    end.        /* do */
    v-query-handle :query-prepare( v-query-string ).
    v-query-handle :query-open.
    v-query-handle :get-first( no-lock ).
    delete object v-query-handle.
end.
end procedure. /* schemlib-set-buffer */
/* $Workfile$ e n d */