/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы Декларация об объемах розничной продажи алкогольной продукции (Калуга) в Excel

Автор: Хныкин Павел Андреевич
Дата создания: 07/19/07
Author: Pavel Khnykin
Creation date: 07/19/07

Required:

{ gbl/paramls.i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define hazkrtxl-data-label "DTA":U
&global-define hazkrtxl-format-label "FMT":U

&global-define hazkrtxl-row-delim chr(6)
&global-define hazkrtxl-sheetList  "Сводка":U

&global-define hazkrtxl-h_hostName "h_hostName":U
&global-define hazkrtxl-h_dateDayStart "h_dateDayStart":U
&global-define hazkrtxl-h_dateMonthStart "h_dateMonthStart":U
&global-define hazkrtxl-h_dateYearStart "h_dateYearStart":U
&global-define hazkrtxl-h_dateTimeStart "h_dateTimeStart":U
&global-define hazkrtxl-h_dateDayEnd "h_dateDayEnd":U
&global-define hazkrtxl-h_dateMonthEnd "h_dateMonthEnd":U
&global-define hazkrtxl-h_dateYearEnd "h_dateYearEnd":U
&global-define hazkrtxl-h_dateTimeEnd "h_dateTimeEnd":U

&global-define hazkrtxl-sheet1-name "Сводка":U

&global-define hazkrtxl-valutCode "Сводка_valutCode":U
&global-define hazkrtxl-regularExpressions "Сводка_regularExpressions":U
&global-define hazkrtxl-columnList "Сводка_columnList":U
&global-define hazkrtxl-columnType "Сводка_columnType":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.
define temp-table temp_sheet1_line-data no-undo
    field sheet-name    as character
    field xl-line-id    as integer
    field objName      as character
    field fuelName     as character
    field daySale      as character
    field salePrice    as character
    field notFuelSale as character

    index pi is primary unique
        xl-line-id
.

define variable v-hazkrtxl-sheet1-cur-data-row  as integer      no-undo.
define variable v-hazkrtxl-cell-file-name       as character    no-undo.
define variable v-hazkrtxl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure hazkrtxl-init :

do
on error undo, return error
:
    assign
        v-hazkrtxl-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-hazkrtxl-data-file-name
    ).
    output stream excel-line to value( v-hazkrtxl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-hazkrtxl-cell-file-name
    ).
    output stream excel-cell to value( v-hazkrtxl-cell-file-name ).
    run hazkrtxl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&hazkrtxl-sheetList}
    ).
    run hazkrtxl-write-cell-data in this-procedure (
          input {&hazkrtxl-regularExpressions}
        , input "1":U
    ).
    if printrubl
    then do:
        run hazkrtxl-write-cell-data in this-procedure (
              input {&hazkrtxl-valutCode}
            , input "0":U
        ).
    end.
    else do:
        run hazkrtxl-write-cell-data in this-procedure (
              input {&hazkrtxl-valutCode}
            , input "1":U
        ).
    end.
    run hazkrtxl-write-cell-data in this-procedure (
          input {&hazkrtxl-columnList}
        , input "objName,fuelName,daySale,salePrice,notFuelSale":U
    ).
    run hazkrtxl-write-cell-data in this-procedure (
          input {&hazkrtxl-columnType}
        , input "S,S,S,S,D":U
    ).
end.
end procedure. /* hazkrtxl-init */

/*==========================================================================*/
procedure hazkrtxl-write-line-data :
define input parameter p-obj-name       as character        no-undo.
define input parameter p-fuel-name      as character        no-undo.
define input parameter p-day-sale       as character        no-undo.
define input parameter p-sale-price     as character        no-undo.
define input parameter p-not-fuel-sale  as character        no-undo.

    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    for each buf_temp_sheet1_line-data
    :
        delete buf_temp_sheet1_line-data.
    end.
    create buf_temp_sheet1_line-data.
    assign
        v-hazkrtxl-sheet1-cur-data-row = v-hazkrtxl-sheet1-cur-data-row + 1
    .
    assign
        buf_temp_sheet1_line-data.sheet-name  = {&hazkrtxl-sheet1-name}
        buf_temp_sheet1_line-data.xl-line-id  = v-hazkrtxl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.objName     = p-obj-name
        buf_temp_sheet1_line-data.fuelName    = p-fuel-name
        buf_temp_sheet1_line-data.daySale     = p-day-sale
        buf_temp_sheet1_line-data.salePrice   = p-sale-price
        buf_temp_sheet1_line-data.notFuelSale = p-not-fuel-sale
    .
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        {&tabulation}   {&hazkrtxl-data-label}
        {&tabulation}   buf_temp_sheet1_line-data.objName
        {&tabulation}   buf_temp_sheet1_line-data.fuelName
        {&tabulation}   buf_temp_sheet1_line-data.daySale
        {&tabulation}   buf_temp_sheet1_line-data.salePrice
        {&tabulation}   buf_temp_sheet1_line-data.notFuelSale
        {&new-line}
    .
end.
end procedure. /* hazkrtxl-write-line-data */

/*==========================================================================*/
procedure hazkrtxl-write-cell-data :
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
end procedure. /* hazkrtxl-write-cell-data */

/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure hazkrtxl-run-excel :
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
        v-template-file-name    = search( "exe/hazkrt1.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas" )
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
end procedure. /* hazkrtxl-run-excel */


/*==========================================================================*/
procedure hazkrtxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/hazkrt1.xlt":U.
        export "exe/t_form.bas":U.
        export v-hazkrtxl-cell-file-name.
        export v-hazkrtxl-data-file-name.
    output close.
end.
end procedure. /* hazkrtxl-close */

/* $Workfile$ e n d */