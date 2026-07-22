/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для импорта карточек товаров

Автор: Белоусов Илья Александрович
Дата создания: 03/23/06
Author: Ilia Belousov
Creation date: 03/23/06

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

define temp-table temp_goods no-undo
    field rec-no            as integer
    field gds-code          as integer
    field artic             as character
    field prod-code         as integer
    field grp-code          as integer
    field unit-base         as character
    field unit-base-type    as character
    field gds-type          as character
    field gds-name          as character
    field engl-name         as character
    field VAT-pc            as decimal
    field SLT-pc            as decimal
    field deadline          as integer

    index pi is primary unique rec-no
    index gc gds-code
.
define temp-table temp_tax no-undo
    field tax-code      as integer
    field rate-code     as integer
    field rate-value    as decimal

    index pi is unique primary tax-code rate-code rate-value
    index rv rate-value
.
define temp-table temp_gds-grp no-undo
    field rec-no        as integer
    field node-code     as integer
    field upper-code    as integer
    field node-name     as character

    index pi is primary unique rec-no
    index nc node-code
    index uc upper-code
.

define temp-table temp_clients no-undo
    field rec-no    as integer
    field obj-code  as integer
    field obj-name  as character
    field address   as character
    field phone     as character
    field fax       as character
    field director  as character
    field email     as character
    field okonh     as character
    field okpo      as character
    field inn       as character
    field kpp       as character
    field ps        as character

    index pi is primary unique rec-no
.

define temp-table temp_bar-codes no-undo
    field rec-no    as integer
    field gds-code  as integer
    field b-str     as character

    index pi is primary unique rec-no
    index gc gds-code b-str
.

&global-define all-klients-group 'Внешние':U
&global-define oil-unit-base 'лт':U
&global-define oil-unit-cli 'кгт':U

&global-define impgds-goods-filename "good.txt"
&global-define impgds-gds-grp-filename "group.txt"
&global-define impgds-clients-filename "client.txt"
&global-define impgds-barcode-filename "bcode.txt"
&global-define impgds-log-filename "impgds.log"
&global-define impgds-err-filename "impgds.err"
&global-define impgds-tab-position 4
&global-define impgds-max-firm-code 9999990
&scoped-define impgds-log-line-size 80

define variable v-impgds-last-rec-no        as integer      no-undo.
define variable v-impgds-repeated-records   as integer      no-undo.
define variable v-impgds-existed-records    as integer      no-undo.
define variable v-impgds-error-records      as integer      no-undo.

define stream impgds-in.
define stream impgds-err.
define stream impgds-log.

/*==========================================================================*/
procedure impgds-write-log :
define input parameter p-tab-position   as integer          no-undo.
define input parameter p-log-text       as character        no-undo.
do
on error undo, return error
:
    put stream impgds-log unformatted
        skip
    .
    if p-tab-position <> 0
    then do:
        put stream impgds-log unformatted
            cur-time-string-sec()
        .
        put stream impgds-log unformatted
            space( p-tab-position * {&impgds-tab-position} )
        .
    end.
    put stream impgds-log unformatted
        p-log-text
    .
end.
end procedure. /* impgds-write-log */


/*==========================================================================*/
procedure impgds-write-error :
define input parameter p-tab-position   as integer          no-undo.
define input parameter p-err-text       as character        no-undo.
do
on error undo, return error
:
    output stream impgds-err to {&impgds-err-filename} append .

    put stream impgds-err unformatted
        {&new-line}
    .
    if p-tab-position <> 0
    then do:
        put stream impgds-err unformatted
            cur-time-string-sec()
        .
        put stream impgds-err unformatted
            space( p-tab-position * {&impgds-tab-position} )
        .
    end.
    put stream impgds-err unformatted
        p-err-text
    .
    output stream impgds-err close.
end.
end procedure. /* impgds-write-error */


/*==========================================================================*/
procedure impgds-write-edt :
define input parameter p-edt-handle     as handle           no-undo.
define input parameter p-log-level      as integer          no-undo.
define input parameter p-output-string  as character        no-undo.
do
on error undo, return error
:
    if valid-handle ( p-edt-handle )
    then do:
        p-edt-handle :move-to-eof().
        p-edt-handle :insert-string(
            if( p-log-level = 0
                or p-output-string = "&DLine"
                or p-output-string = "&Line" )
            then ""
            else cur-time-string-sec() + " " ).
        p-edt-handle :insert-string(
            if p-output-string = "&Line"
            then fill( "-", {&impgds-log-line-size} )
            else if p-output-string = "&DLine"
                 then fill( "=", {&impgds-log-line-size} )
                 else fill( " ", p-log-level ) + p-output-string ).
        p-edt-handle :insert-string( {&new-line} ).
    end.
    process events.
end.
end procedure. /* impgds-write-edt */


/*==========================================================================*/
procedure impgds-write-cnt :
define input parameter p-cnt-handle     as handle           no-undo.
define input parameter p-output-string  as character        no-undo.

do
on error undo, return error
:
    if valid-handle( p-cnt-handle )
    then do:
        assign p-cnt-handle :screen-value = p-output-string.
    end.
    process events.
end.
end procedure. /* impgds-write-cnt */


/*==========================================================================*/
procedure impgds-assign-integer :
define input parameter p-log-handle         as handle           no-undo.
define input parameter p-file-line-num      as integer          no-undo.
define input parameter p-field-name         as character        no-undo.
define input parameter p-input-string       as character        no-undo.
define output parameter p-output-integer    as integer          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        run impgds-write-error in this-procedure (
              input 1
            , input substitute( "Ошибка преобразования поля в десятичный тип. Строка &1. Поле &2. Значение '&3'"
                                , p-file-line-num
                                , p-field-name
                                , p-input-string
                              )
        ).
        run impgds-write-log in this-procedure (
              input 1
            , input substitute( "Ошибка преобразования поля в десятичный тип. Строка &1. Поле &2. Значение '&3'"
                                , p-file-line-num
                                , p-field-name
                                , p-input-string
                              )
        ).
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 0
            , input substitute( "Ошибка преобразования поля в десятичный тип. Строка &1. Поле &2. Значение '&3'"
                                , p-file-line-num
                                , p-field-name
                                , p-input-string
                              )
        ).
        undo, return error.
    end.
end.
end procedure. /* impgds-assign-integer */

/*==========================================================================*/
procedure impgds-assign-decimal :
define input parameter p-log-handle         as handle           no-undo.
define input parameter p-file-line-num      as integer          no-undo.
define input parameter p-field-name         as character        no-undo.
define input parameter p-input-string       as character        no-undo.
define output parameter p-output-decimal    as decimal          no-undo.
do
on error undo, return error
:
    assign
        p-output-decimal = decimal( p-input-string )
    no-error.
    if error-status :error
    then do:
        run impgds-write-error in this-procedure (
              input 1
            , input substitute( "Ошибка преобразования поля в десятичный тип. Строка &1. Поле &2. Значение '&3'"
                                , p-file-line-num
                                , p-field-name
                                , p-input-string
                              )
        ).
        run impgds-write-log in this-procedure (
              input 1
            , input substitute( "Ошибка преобразования поля в десятичный тип. Строка &1. Поле &2. Значение '&3'"
                                , p-file-line-num
                                , p-field-name
                                , p-input-string
                              )
        ).
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 0
            , input substitute( "Ошибка преобразования поля в десятичный тип. Строка &1. Поле &2. Значение '&3'"
                                , p-file-line-num
                                , p-field-name
                                , p-input-string
                              )
        ).
        undo, return error.
    end.
end.
end procedure. /* impgds-assign-decimal */

/* $Workfile$   E n d */
