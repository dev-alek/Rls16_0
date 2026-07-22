/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сравнение буферов

Автор: Белоусов Илья Александрович
Дата создания: 04/14/06
Author: Ilia Belousov
Creation date: 04/14/06

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

    define temp-table temp_bufcomp_field-param no-undo
        field fpm-key               as integer
        field table-name          as character
        field field-name           as character
        field field-new-label     as character

        index pi is primary unique
            fpm-key
        index fld
            table-name
            field-name
    .
    define temp-table temp_bufcomp_field-diff no-undo
        field fdd-key       as integer
        field fpm-key-old   as integer
        field fpm-key-new   as integer
        field value-old     as character
        field label-old     as character
        field value-new     as character
        field label-new     as character
        field diff          as character

        index pi is primary unique
            fdd-key
    .
    define variable v-bufcomp-fpm-key       as integer    no-undo.
    define variable v-bufcomp-fdd-key       as integer    no-undo.



PROCEDURE bufcomp-init-field-param :
    define buffer buf_temp_bufcomp_field-param      for temp_bufcomp_field-param.
do
for buf_temp_bufcomp_field-param
on error undo, return error
:
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "recipe-code     ":U )   , input trim( "Рецепт           ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "artic           ":U )   , input trim( "Артикул          ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "prod-type       ":U )   , input trim( "Тип производителя":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "prod-code       ":U )   , input trim( "Код производителя":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "brutto-qnty     ":U )   , input trim( "Брутто           ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "gds-code        ":U )   , input trim( "Код товара       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "host-code       ":U )   , input trim( "Код фирмы        ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "is-default      ":U )   , input trim( "Основной         ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "obj-code        ":U )   , input trim( "Код объекта      ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "obj-type        ":U )   , input trim( "Тип объекта      ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "portion-qnty    ":U )   , input trim( "Кол.порций       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "portion-weight  ":U )   , input trim( "Вес порции       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "qnty            ":U )   , input trim( "Количество       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "recipe-code     ":U )   , input trim( "Номер рецепта    ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "recipe-design   ":U )   , input trim( "Оформление       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "recipe-name     ":U )   , input trim( "Назв.рецепта     ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "recipe-order    ":U )   , input trim( "Порядок          ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "recipe-quality  ":U )   , input trim( "Показ.качества   ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "recipe-ref-num  ":U )   , input trim( "Номер по спр.рец.":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "recipe-technique":U )   , input trim( "Технология       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "recipe-template ":U )   , input trim( "Ссылка на спр.рец":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "recipe-type     ":U )   , input trim( "Тип рецепта      ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "recipe":U    , input trim( "sale-factor     ":U )   , input trim( "Кратность        ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "recipe-code     ":U )   , input trim( "Рецепт           ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "artic           ":U )   , input trim( "Артикул          ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "prod-type       ":U )   , input trim( "Тип производителя":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "prod-code       ":U )   , input trim( "Код производителя":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "brutto-qnty     ":U )   , input trim( "Брутто           ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "gds-code        ":U )   , input trim( "Код товара       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "host-code       ":U )   , input trim( "Код фирмы        ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "is-default      ":U )   , input trim( "Основной         ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "obj-code        ":U )   , input trim( "Код объекта      ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "obj-type        ":U )   , input trim( "Тип объекта      ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "portion-qnty    ":U )   , input trim( "Кол.порций       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "portion-weight  ":U )   , input trim( "Вес порции       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "qnty            ":U )   , input trim( "Количество       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "recipe-code     ":U )   , input trim( "Номер рецепта    ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "recipe-design   ":U )   , input trim( "Оформление       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "recipe-name     ":U )   , input trim( "Назв.рецепта     ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "recipe-order    ":U )   , input trim( "Порядок          ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "recipe-quality  ":U )   , input trim( "Показ.качества   ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "recipe-ref-num  ":U )   , input trim( "Номер по спр.рец.":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "recipe-technique":U )   , input trim( "Технология       ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "recipe-template ":U )   , input trim( "Ссылка на спр.рец":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "recipe-type     ":U )   , input trim( "Тип рецепта      ":U )   ).
    run bufcomp-set-field-param in this-procedure  ( input "c-recipe":U  , input trim( "sale-factor     ":U )   , input trim( "Кратность        ":U )   ).
end.
END PROCEDURE. /* bufcomp-init-field-param */


PROCEDURE bufcomp-set-field-param :
define input parameter p-table-name     as character  no-undo.
define input parameter p-field-name     as character  no-undo.
define input parameter p-field-label    as character  no-undo.

    define buffer buf_temp_bufcomp_field-param      for temp_bufcomp_field-param.
do
for buf_temp_bufcomp_field-param
on error undo, return error
:
    assign
        v-bufcomp-fpm-key = v-bufcomp-fpm-key + 1
    .
    create buf_temp_bufcomp_field-param.
    assign
        buf_temp_bufcomp_field-param.fpm-key           = v-bufcomp-fpm-key
        buf_temp_bufcomp_field-param.table-name        = p-table-name
        buf_temp_bufcomp_field-param.field-name        = p-field-name
        buf_temp_bufcomp_field-param.field-new-label   = p-field-label
    .
end.
END PROCEDURE. /* bufcomp-set-field-param */



PROCEDURE bufcomp-buffer-compare :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-old-buffer-handle  as handle           no-undo.
define input parameter p-new-buffer-handle  as handle           no-undo.
define input parameter p-except-field-list  as character        no-undo.

    define variable v-field-counter    as integer      no-undo.
    define variable v-old-field-handle as handle       no-undo.
    define variable v-new-field-handle as handle       no-undo.

    define buffer buf_old_temp_bufcomp_field-param      for temp_bufcomp_field-param.
    define buffer buf_new_temp_bufcomp_field-param      for temp_bufcomp_field-param.
    define buffer buf_temp_bufcomp_field-diff           for temp_bufcomp_field-diff.
do
for buf_old_temp_bufcomp_field-param
  , buf_new_temp_bufcomp_field-param
  , buf_temp_bufcomp_field-diff
on error undo, return error
:
    process-fields:
    do v-field-counter = 1 TO p-new-buffer-handle :num-fields
    :
        assign
            v-new-field-handle = p-new-buffer-handle :buffer-field( v-field-counter )
            v-old-field-handle = p-old-buffer-handle :buffer-field( v-new-field-handle :name )
        no-error.
        if not valid-handle( v-old-field-handle )
        or not valid-handle( v-new-field-handle )
        then do:
            next process-fields.
        end.
        if lookup( v-new-field-handle :name, p-except-field-list ) <> 0
        then do:
            next process-fields.
        end.
        else do:
            find first buf_old_temp_bufcomp_field-param
                 where buf_old_temp_bufcomp_field-param.table-name  = p-old-buffer-handle :name
                   and buf_old_temp_bufcomp_field-param.field-name  = v-old-field-handle :name
            no-error.
            find first buf_new_temp_bufcomp_field-param
                 where buf_new_temp_bufcomp_field-param.table-name  = p-new-buffer-handle :name
                   and buf_new_temp_bufcomp_field-param.field-name  = v-new-field-handle :name
            no-error.
            if v-new-field-handle :buffer-value <> v-old-field-handle :buffer-value
            then do:
                assign
                    v-bufcomp-fdd-key = v-bufcomp-fdd-key + 1
                .
                create buf_temp_bufcomp_field-diff.
                assign
                    buf_temp_bufcomp_field-diff.fdd-key     = v-bufcomp-fdd-key
                    buf_temp_bufcomp_field-diff.fpm-key-old = ( if available buf_old_temp_bufcomp_field-param then buf_old_temp_bufcomp_field-param.fpm-key else 0 )
                    buf_temp_bufcomp_field-diff.fpm-key-new = ( if available buf_new_temp_bufcomp_field-param then buf_new_temp_bufcomp_field-param.fpm-key else 0 )
                    buf_temp_bufcomp_field-diff.value-old   = string( v-old-field-handle :buffer-value )
                    buf_temp_bufcomp_field-diff.value-new   = string( v-new-field-handle :buffer-value )
                    buf_temp_bufcomp_field-diff.label-old = ( if available buf_old_temp_bufcomp_field-param then buf_old_temp_bufcomp_field-param.field-new-label else v-old-field-handle :label )
                    buf_temp_bufcomp_field-diff.label-new = ( if available buf_new_temp_bufcomp_field-param then buf_new_temp_bufcomp_field-param.field-new-label else v-new-field-handle :label )
                .
                case v-new-field-handle :data-type
                :
                    when "integer":U
                    then do:
                        assign
                            buf_temp_bufcomp_field-diff.diff = string( integer( buf_temp_bufcomp_field-diff.value-new ) - integer( buf_temp_bufcomp_field-diff.value-old ) )
                        .
                    end.        /* when "integer":U */
                    when "decimal":U
                    then do:
                        assign
                            buf_temp_bufcomp_field-diff.diff = string( decimal( buf_temp_bufcomp_field-diff.value-new ) - decimal( buf_temp_bufcomp_field-diff.value-old ) )
                        .
                    end.        /* when "decimal":U */
                    when "character":U
                    then do:
                        assign
                            buf_temp_bufcomp_field-diff.diff = string( v-old-field-handle :buffer-value ) + " | ":U + string( v-new-field-handle :buffer-value )
                        .
                    end.        /* when "character":U */
                    when "logical":U
                    then do:
                        assign
                            buf_temp_bufcomp_field-diff.diff = string( v-old-field-handle :buffer-value ) + " | ":U + string( v-new-field-handle :buffer-value )
                        .
                    end.        /* when "logical":U */
                end case.       /* case v-new-field-handle :data-type */
            end.
/*            put unformatted*/
/*                substitute( "&2, &3, &4  =  &5&1", chr(10), v-new-field-handle :name, v-old-field-handle :name, v-new-field-handle :data-type, v-new-field-handle :format, v-new-field-handle :buffer-value  )*/
/*            .*/
        end.
    end.
end.
END PROCEDURE. /* bufcomp-buffer-compare */


/* $Workfile$ e n d */