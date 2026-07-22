/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры для работы с файлами формата DBF

Автор: Белоусов Илья Александрович
Дата создания: 10/14/05
Author: Ilia Belousov
Creation date: 10/14/05

Required:

Пример:

        input stream in-stream from value( v-full-name ).
        run dbflib-init in this-procedure.
        repeat:
            import stream in-stream
                v-field-name
                v-field-value
            .
            if v-field-value = ?
            then do:
                assign
                    v-field-value = "":U
                    v-field-length = 0
                .
            end.
            else do:
                assign
                    v-field-length = length( v-field-value )
                .
            end.
            run dbflib-add-field in this-procedure (
                  input v-field-name
                , input 255
                , input "character":U
                , input 0
            ).
            run dbflib-add-data in this-procedure (
                  input 1
                , input v-field-name
                , input v-field-value
            ).
            run dbflib-write-dbf in this-procedure (
                  input substitute( "&1/&2.dbf":U, p-dir-name, buf_temp-filelist.file-name-no-ext )
                , input 1
            ).
        end.
        input stream in-stream close.

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


define temp-table temp_dbflib_field no-undo
    field field-name        as character    format "x(32)"
    field data-type         as character
    field field-decimals    as integer
    field dbfield-name      as character    format "x(11)"
    field field-handle      as handle
    field field-length      as integer      format ">>>9"

    index field-name        is primary unique
        field-name
.
define temp-table temp_dbflib_data no-undo
    field record-number as integer
    field field-name    as character
    field data-value    as character

    index pi is primary unique
        record-number
        field-name
.
define variable v-dbflib-reclength      as integer      no-undo.
define variable v-field-amount          as integer      no-undo.
define stream dbf-stream.

/*==========================================================================*/
procedure dbflib-write-dbf :
define input parameter p-filename       as character        no-undo.
define input parameter p-record-amount  as integer          no-undo.

    define variable v-date          as date         no-undo.
    define variable v-string-value  as character    no-undo.
    define variable raw-value       as raw          no-undo.
    define variable v-record-count  as integer      no-undo.

    define buffer buf_temp_dbflib_field    for temp_dbflib_field.
    define buffer buf_temp_dbflib_data     for temp_dbflib_data.
do
for buf_temp_dbflib_field
  , buf_temp_dbflib_data
on error undo, return error
:
    output stream dbf-stream to value( p-filename ) binary no-convert.
    put stream dbf-stream
        control "~003":U
    .
    /* bytes 1-3: Date of last update */
    run dbflib-makebinary (
          input year( today ) - 2000
        , input 1
        , output raw-value
    ).
    put stream dbf-stream control raw-value.

    run dbflib-makebinary (
        month( today )
        , input 1
        , output raw-value
    ).
    put stream dbf-stream control raw-value.

    run dbflib-makebinary (
          input day( today )
        , input 1
        , output raw-value
    ).
    put stream dbf-stream control raw-value.

    /* Number of records (bytes 4-7) as a 4-byte binary number: */
    run dbflib-makebinary (
          input p-record-amount
        , input 4
        , output raw-value
    ).
    put stream dbf-stream control raw-value.

    /* no of bytes in the header (bytes 8-9) */
    run dbflib-makebinary (
          input ( 32 + 32 * v-field-amount + 1 )
        , input 2
        , output raw-value
    ).
    put stream dbf-stream control raw-value.

    /* bytes 10-11: record length */
    run dbflib-makebinary (
          input v-dbflib-reclength + 1
        , input 2
        , output raw-value
    ).
    put stream dbf-stream control raw-value.

    /* bytes 12-31: null */
    put stream dbf-stream control null( 20 ).

    /* now the field descriptions */
    for each buf_temp_dbflib_field
    :
        put stream dbf-stream control
            buf_temp_dbflib_field.dbfield-name
            null( 11 - length( buf_temp_dbflib_field.dbfield-name ) )
        .  /* 11 bytes null filled */
        case buf_temp_dbflib_field.data-type:
            when "character":U
            then do:
                put stream dbf-stream "C".
            end.
            when "integer":U
            or when "decimal"
            then do:
                put stream dbf-stream "N".
            end.
            when "logical":U
            then do:
                put stream dbf-stream "L".
            end.
            when "date":U
            then do:
                put stream dbf-stream "D".
            end.
            otherwise do:
                undo, return error substitute("Unknown field type for &1: &2",
                                                buf_temp_dbflib_field.field-handle:name,
                                                buf_temp_dbflib_field.data-type).
            end.
        end case.

        put stream dbf-stream control
            null( 4 )                      /* reserved */
            chr( buf_temp_dbflib_field.field-length )    /* field length in binary */
        .
        if buf_temp_dbflib_field.field-decimals = 0
        then do:
            put stream dbf-stream control null.
        end.
        else do:
            put stream dbf-stream control
                chr( buf_temp_dbflib_field.field-decimals ) /* decimal count in binary */
            .
        end.
        put stream dbf-stream control
            null(2)                      /* reserved */
            chr(1)                       /* work area id */
            null(11)                     /* reserved etc. */
       .
    end. /* of field specifications */
    put stream dbf-stream control
        chr(13)           /* field terminator */
    .
    do v-record-count = 1 to p-record-amount
    on error undo, return error
    :
        for each buf_temp_dbflib_data
           where buf_temp_dbflib_data.record-number = v-record-count
        :
            put stream dbf-stream
                " "
            . /* delete flag */
            find first buf_temp_dbflib_field
            where buf_temp_dbflib_field.field-name = buf_temp_dbflib_data.field-name
            no-error.
            if available buf_temp_dbflib_field
            then do:
                case buf_temp_dbflib_field.data-type
                :
                    when "logical":U
                    then do:
                        put stream dbf-stream unformatted
                            ( if buf_temp_dbflib_data.data-value = "yes":U
                            then "T":U
                            else "F":U )
                        .
                    end.
                    when "date":U
                    then do:
                        assign
                            v-date = date( buf_temp_dbflib_data.data-value )
                        .
                        put stream dbf-stream unformatted
                            year( v-date )
                            month( v-date ) format "99"
                            day( v-date ) format "99"
                        .
                    end.
                    when "decimal":U
                    or when "integer":U
                    then do:        /* remove thousands seperators, replace decimal separators with dot */
                        if session:numeric-format = "EUROPEAN":U
                        then do:
                            assign
                                v-string-value = replace( string( buf_temp_dbflib_data.data-value ), ".":U, "":U )
                                v-string-value = replace( v-string-value, ",":U, ".":U )
                            .
                        end.
                        else do:
                            assign
                                v-string-value = replace( string( buf_temp_dbflib_data.data-value ),",","")
                            .
                        end.
                        put stream dbf-stream unformatted
                            v-string-value
                            fill( " ":U, buf_temp_dbflib_field.field-length - length( v-string-value ) )
                        .
                    end.
                    otherwise do:
                        put stream dbf-stream unformatted
                            string( buf_temp_dbflib_data.data-value )
                            fill( " ", buf_temp_dbflib_field.field-length - length( string( buf_temp_dbflib_data.data-value ) ) )
                        .
                    end.
                end case.       /* case buf_temp_dbflib_field.data-type */
            end.        /* if available buf_temp_dbflib_field */
        end.        /* for each buf_temp_dbflib_data */
    end.        /* do */
    output stream dbf-stream close.
end.
end procedure. /* dbflib-write-dbf */

/* This routine converts a Progress integer to a binary
    representation. No "C" needed!

    Input parameters:

    - number to be converted
    - no of desired bytes

    Output parameter

    - binary representation of number as a raw variable
    with the correct length

*/
PROCEDURE dbflib-makebinary:
define input parameter anumm#     as integer      no-undo. /* number */
define input parameter abyte#     as integer      no-undo. /* no of desired bytes */
define output parameter raw-value as raw          no-undo. /* result of conversion */

    define variable acoun#    as integer      no-undo.
do
on error undo, return error
:
    assign
        length( raw-value ) = abyte#
    .
    if anumm# <0
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip ": This routine works for positive integers only."
            skip "Received value of" anumm# "is invalid."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error
        title "Conversion to binary".
        undo, return error .
    end.
    if anumm# > 0
    and anumm# modulo anumm# / EXP( anumm#, abyte#) > 256
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip ": received number" anumm#
            skip "does not fit in" abyte# "bytes."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error
        title "Conversion to binary".
        undo, return error .
    end.
    do acoun# = abyte# to 1 by -1
    on error undo, return error
    :
        put-byte( raw-value, acoun# ) = int( truncate( anumm# / EXP( 256, acoun# - 1 ), 0 ) ).
        if anumm# ne 0
        then do:
            assign
                anumm# = anumm# modulo EXP( 256, acoun# - 1 )
            .
        end.
    end.
end.
END PROCEDURE. /* dbflib-makebinary */

/*==========================================================================*/
procedure dbflib-init :

    define buffer buf_temp_dbflib_field    for temp_dbflib_field.
    define buffer buf_temp_dbflib_data     for temp_dbflib_data.
do
for buf_temp_dbflib_field
  , buf_temp_dbflib_data
:
    empty temp-table buf_temp_dbflib_field.
    empty temp-table buf_temp_dbflib_data.
    assign
        v-dbflib-reclength = 0
        v-field-amount     = 0
    .
end.
end procedure. /* dbflib-init */
/*==========================================================================
Input:
    p-field-name     as character -
    p-field-length   as integer   -
    p-data-type      as character - "character":U, "integer":U, "logical":U, "date":U
    p-field-decimals as integer   -

*/
procedure dbflib-add-field :
define input parameter p-field-name     as character        no-undo.
define input parameter p-field-length   as integer          no-undo.
define input parameter p-data-type      as character        no-undo.
define input parameter p-field-decimals as integer          no-undo.

    define buffer buf_temp_dbflib_field    for temp_dbflib_field.
do
for buf_temp_dbflib_field
on error undo, return error
:
    find first buf_temp_dbflib_field
         where buf_temp_dbflib_field.field-name       = p-field-name
    no-error.
    if not available buf_temp_dbflib_field
    then do:
        create buf_temp_dbflib_field.
        assign
            buf_temp_dbflib_field.field-name       = p-field-name
            buf_temp_dbflib_field.field-length     = p-field-length
            buf_temp_dbflib_field.data-type        = p-data-type
            buf_temp_dbflib_field.field-decimals   = p-field-decimals
            buf_temp_dbflib_field.dbfield-name     = caps( replace( substring( p-field-name, 1, 11 ), "-":U, "_":U ) )
            v-dbflib-reclength                     = v-dbflib-reclength + buf_temp_dbflib_field.field-length
            v-field-amount                         = v-field-amount + 1
        .
    end.
end.
end procedure. /* dbflib-add-field */


/*==========================================================================*/
procedure dbflib-add-data :
define input parameter p-record-number  as integer          no-undo.
define input parameter p-field-name     as character        no-undo.
define input parameter p-data-value     as character        no-undo.

    define buffer buf_temp_dbflib_data      for temp_dbflib_data.
do
for buf_temp_dbflib_data
on error undo, return error
:
    find first buf_temp_dbflib_data
         where buf_temp_dbflib_data.record-number  = p-record-number
           and buf_temp_dbflib_data.field-name     = p-field-name
    no-error.
    if not available buf_temp_dbflib_data
    then do:
        create buf_temp_dbflib_data.
        assign
            buf_temp_dbflib_data.record-number  = p-record-number
            buf_temp_dbflib_data.field-name     = p-field-name
            buf_temp_dbflib_data.data-value     = p-data-value
        .
    end.
end.
end procedure. /* dbflib-add-data */

/* $Workfile$ e n d */