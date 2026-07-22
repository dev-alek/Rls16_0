/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы акт приема нефтепродуктов по количеству

Автор: Хныкин Павел Андреевич
Дата создания: 07/31/07
Author: Pavel Khnykin
Creation date: 07/31/07

Required:

{ gbl/paramls.i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define sibactxl-line-data-key "LD":U
&global-define sibactxl-valutCode "valutCode":U
&global-define sibactxl-columnList "columnList":U
&global-define sibactxl-columnType "columnType":U
&global-define sibactxl-columnAmount "columnAmount":U
&global-define sibactxl-subtotalList "subtotalList":U
&global-define sibactxl-subtotalType "subtotalType":U
&global-define sibactxl-subtotalAmount "subtotalAmount":U

&global-define sibactxl-h_timePour "h_timePour":U
&global-define sibactxl-h_timeIncome "h_timeIncome":U
&global-define sibactxl-h_cargoFrom "h_cargoFrom":U
&global-define sibactxl-h_cargoTo "h_cargoTo":U
&global-define sibactxl-h_autoent "h_autoent":U
&global-define sibactxl-h_address "h_address":U
&global-define sibactxl-h_dirAzk "h_dirAzk":U
&global-define sibactxl-h_docDate "h_docDate":U

&global-define sibactxl-f_stOp "f_stOp":U
&global-define sibactxl-f_op "f_op":U
&global-define sibactxl-f_3Ex "f_3Ex":U


define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.
define temp-table temp_line-data no-undo
    field data-key     as character
    field xl-line-id   as integer
    field col-1        as character
    field col-2        as character
    field col-3        as character
    field col-4        as character
    field col-5        as character
    field col-6        as character
    field col-7        as character
    field col-8        as character
    field col-9        as character
    field col-10       as character
    field col-11       as character
    field col-12       as character
    field col-13       as character
    field col-14       as character
    field col-15       as character
    field col-16       as character
    field col-17       as character

    index pi is primary unique xl-line-id
.

define variable v-sibactxl-current-data-row     as integer      no-undo.
define variable v-sibactxl-cell-file-name       as character    no-undo.
define variable v-sibactxl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure sibactxl-init :

    define buffer buf_temp_cell-data        for temp_cell-data.
    define buffer buf_usr-flt               for ubflt.usr-flt.
do
for buf_temp_cell-data
  , buf_usr-flt
on error undo, return error
:
    assign
        v-sibactxl-current-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-sibactxl-data-file-name
    ).
    output stream excel-line to value( v-sibactxl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-sibactxl-cell-file-name
    ).
    output stream excel-cell to value( v-sibactxl-cell-file-name ).

    if printrubl
    then do:
        run sibactxl-write-cell-data in this-procedure (
              input {&sibactxl-valutCode}
            , input "0":U
        ).
    end.
    else do:
        run sibactxl-write-cell-data in this-procedure (
              input {&sibactxl-valutCode}
            , input "1":U
        ).
    end.
    run sibactxl-write-cell-data in this-procedure (
          input {&sibactxl-columnList}
        , input "col1,col2,col3,col4,col5,col6,col7,col8,col9,col10,col11,col12,col13,col14,col15,col16,col17":U
    ).
    run sibactxl-write-cell-data in this-procedure (
          input {&sibactxl-columnType}
        , input "S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S":U
    ).
    run sibactxl-write-cell-data in this-procedure (
          input {&sibactxl-columnAmount}
        , input "17":U
    ).
end.
end procedure. /* sibactxl-init */

/*==========================================================================*/
procedure sibactxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/sibactp1.xlt":U.
        export "exe/t_97.bas":U.
        export v-sibactxl-cell-file-name.
        export v-sibactxl-data-file-name.
    output close.
end.
end procedure. /* sibactxl-close */

/*==========================================================================*/
procedure sibactxl-write-cell-data :
define input parameter p-data-key   as character        no-undo.
define input parameter p-data-value as character        no-undo.

    define buffer buf_temp_cell-data     for temp_cell-data.
do
for buf_temp_cell-data
on error undo, return error
:
    find first buf_temp_cell-data
         where buf_temp_cell-data.data-key = p-data-key
    no-error.
    if not available buf_temp_cell-data
    then do:
        create buf_temp_cell-data.
        assign
            buf_temp_cell-data.data-key = p-data-key
        .
    end.
    assign
        buf_temp_cell-data.data-value = p-data-value
    .
    put stream excel-cell unformatted
                        buf_temp_cell-data.data-key
        {&tabulation}   buf_temp_cell-data.data-value
        {&new-line}
    .
end.
end procedure. /* sibactxl-write-cell-data */


/*==========================================================================*/
procedure sibactxl-write-line-data :
  define input parameter p-col-1  as character no-undo .
  define input parameter p-col-2  as character no-undo .
  define input parameter p-col-3  as character no-undo .
  define input parameter p-col-4  as character no-undo .
  define input parameter p-col-5  as character no-undo .
  define input parameter p-col-6  as character no-undo .
  define input parameter p-col-7  as character no-undo .
  define input parameter p-col-8  as character no-undo .
  define input parameter p-col-9  as character no-undo .
  define input parameter p-col-10 as character no-undo .
  define input parameter p-col-11 as character no-undo .
  define input parameter p-col-12 as character no-undo .
  define input parameter p-col-13 as character no-undo .
  define input parameter p-col-14 as character no-undo .
  define input parameter p-col-15 as character no-undo .
  define input parameter p-col-16 as character no-undo .
  define input parameter p-col-17 as character no-undo .
    define buffer buf_temp_line-data        for temp_line-data.
do
for buf_temp_line-data
on error undo, return error
:

    for each buf_temp_line-data
    :
        delete buf_temp_line-data.
    end.
    create buf_temp_line-data.
    assign
        v-sibactxl-current-data-row = v-sibactxl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key     = {&sibactxl-line-data-key}
        buf_temp_line-data.xl-line-id   = v-sibactxl-current-data-row
        buf_temp_line-data.col-1        = p-col-1
        buf_temp_line-data.col-2        = p-col-2
        buf_temp_line-data.col-3        = p-col-3
        buf_temp_line-data.col-4        = p-col-4
        buf_temp_line-data.col-5        = p-col-5
        buf_temp_line-data.col-6        = p-col-6
        buf_temp_line-data.col-7        = p-col-7
        buf_temp_line-data.col-8        = p-col-8
        buf_temp_line-data.col-9        = p-col-9
        buf_temp_line-data.col-10       = p-col-10
        buf_temp_line-data.col-11       = p-col-11
        buf_temp_line-data.col-12       = p-col-12
        buf_temp_line-data.col-13       = p-col-13
        buf_temp_line-data.col-14       = p-col-14
        buf_temp_line-data.col-15       = p-col-15
        buf_temp_line-data.col-16       = p-col-16
        buf_temp_line-data.col-17       = p-col-17
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        {&tabulation}   buf_temp_line-data.col-1
        {&tabulation}   buf_temp_line-data.col-2
        {&tabulation}   buf_temp_line-data.col-3
        {&tabulation}   buf_temp_line-data.col-4
        {&tabulation}   buf_temp_line-data.col-5
        {&tabulation}   buf_temp_line-data.col-6
        {&tabulation}   buf_temp_line-data.col-7
        {&tabulation}   buf_temp_line-data.col-8
        {&tabulation}   buf_temp_line-data.col-9
        {&tabulation}   buf_temp_line-data.col-10
        {&tabulation}   buf_temp_line-data.col-11
        {&tabulation}   buf_temp_line-data.col-12
        {&tabulation}   buf_temp_line-data.col-13
        {&tabulation}   buf_temp_line-data.col-14
        {&tabulation}   buf_temp_line-data.col-15
        {&tabulation}   buf_temp_line-data.col-16
        {&tabulation}   buf_temp_line-data.col-17
        {&new-line}
    .
end.
end procedure. /* sibactxl-write-line-data */


/*==========================================================================*/
procedure sibactxl-run-excel :
define input parameter p-header-filename    as character        no-undo.
define input parameter p-data-filename      as character        no-undo.

    define variable v-template-file-name    as character    no-undo.
    define variable v-vb-file-name          as character    no-undo.

    define buffer buf_temp-param for temp-param .
do
for buf_temp-param
on error undo, return error
:
    create buf_temp-param.
    assign
        v-template-file-name    = search( "exe/sibactp1.xlt" )
        v-vb-file-name          = search( "exe/t_97.bas")
    .
/*    assign*/
/*        v-template-file-name = search( v-template-file-name )*/
/*    .*/
    if v-template-file-name = ?
    or v-template-file-name = "":U
    then do:
        message
            "Ошибка имени файла шаблона."
        view-as alert-box error.
    end.
    if v-vb-file-name = ?
    or v-vb-file-name = "":U
    then do:
        message
            "Ошибка имени файла кода обработки."
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
        , input p-header-filename
    ).
    run paramls-write in this-procedure (
          input {&paramls-data}
        , input {&paramls-data-filename}
        , input p-data-filename
    ).
    run gbl/macroxlt.p (
        input-output table buf_temp-param
    ) no-error.
    if error-status :error
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
end procedure. /* sibactxl-run-excel */

/* $Workfile$ e n d */