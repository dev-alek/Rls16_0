/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы Декларация об объемах розничной продажи алкогольной продукции (Калуга) в Excel

Автор: Хныкин Павел Андреевич
Дата создания: 12/28/07
Author: Pavel Khnykin
Creation date: 12/28/07

Required:

{ gbl/paramls.i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define wthobrxl-data-label "DTA":U
&global-define wthobrxl-format-label "FMT":U

&global-define wthobrxl-row-delim chr(6)
&global-define wthobrxl-sheetList  "Лист1":U

&global-define wthobrxl-h_daterange "h_daterange":U
&global-define wthobrxl-h_clients "h_clients":U
&global-define wthobrxl-h_wth "h_wth":U

&global-define wthobrxl-sheet1-name "Лист1":U

&global-define wthobrxl-valutCode "Лист1_valutCode":U
&global-define wthobrxl-regularExpressions "Лист1_regularExpressions":U
&global-define wthobrxl-columnList "Лист1_columnList":U
&global-define wthobrxl-columnType "Лист1_columnType":U
&global-define wthobrxl-sheet1_subtotalList    "Лист1_subtotalList":U
&global-define wthobrxl-sheet1_subtotalType    "Лист1_subtotalType":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.
define temp-table temp_sheet1_line-data no-undo
    field sheet-name          as character
    field xl-line-id          as integer
    field cli-name            as character
    field talon-name          as character
    field talon-nominal       as character
    field talon-series        as character
    field give-sum-units      as character
    field give-sum-money      as character
    field chg-give-sum-units  as character
    field chg-give-sum-money  as character
    field sell-sum-units      as character
    field sell-sum-money      as character
    field ret-sum-units       as character
    field ret-sum-money       as character
    field chg-ret-sum-units   as character
    field chg-ret-sum-money   as character
    field spi-sum-units       as character
    field spi-sum-money       as character
    field restFrom-units      as character
    field restFrom-money      as character
    field restEnd-units       as character
    field restEnd-money       as character


    index pi is primary unique
        xl-line-id
.

define variable v-wthobrxl-sheet1-cur-data-row  as integer      no-undo.
define variable v-wthobrxl-cell-file-name       as character    no-undo.
define variable v-wthobrxl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure wthobrxl-init :

do
on error undo, return error
:
    assign
        v-wthobrxl-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-wthobrxl-data-file-name
    ).
    output stream excel-line to value( v-wthobrxl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-wthobrxl-cell-file-name
    ).
    output stream excel-cell to value( v-wthobrxl-cell-file-name ).
    run wthobrxl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&wthobrxl-sheetList}
    ).
    run wthobrxl-write-cell-data in this-procedure (
          input {&wthobrxl-regularExpressions}
        , input "1":U
    ).
    if printrubl
    then do:
        run wthobrxl-write-cell-data in this-procedure (
              input {&wthobrxl-valutCode}
            , input "0":U
        ).
    end.
    else do:
        run wthobrxl-write-cell-data in this-procedure (
              input {&wthobrxl-valutCode}
            , input "1":U
        ).
    end.
    run wthobrxl-write-cell-data in this-procedure (
          input {&wthobrxl-columnList}
        , input "cliname,talonname,talonnominal,talonser,givesumunits,givesummoney,chggivesumunits,chggivesummoney,sellsumunits,sellsummoney,retsumunits,retsummoney,chgretsumunits,chgretsummoney,spisumunits,spisummoney,restfromunits,restfrommoney,restendunits,restendmoney":U
    ).
    run wthobrxl-write-cell-data in this-procedure (
          input {&wthobrxl-columnType}
        , input "S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S":U
    ).
    run wthobrxl-write-cell-data in this-procedure (
          input {&wthobrxl-sheet1_subtotalList}
        , input "":U
    ).
    run wthobrxl-write-cell-data in this-procedure (
          input {&wthobrxl-sheet1_subtotalType}
        , input "":U
    ).

end.
end procedure. /* wthobrxl-init */

/*==========================================================================*/
procedure wthobrxl-write-line-data :
define input parameter p-cli-name            as character no-undo .
define input parameter p-talon-name          as character no-undo .
define input parameter p-talon-nominal       as character no-undo .
define input parameter p-talon-series        as character no-undo .
define input parameter p-give-sum-units      as character no-undo .
define input parameter p-give-sum-money      as character no-undo .
define input parameter p-chg-give-sum-units  as character no-undo .
define input parameter p-chg-give-sum-money  as character no-undo .
define input parameter p-sell-sum-units      as character no-undo .
define input parameter p-sell-sum-money      as character no-undo .
define input parameter p-ret-sum-units       as character no-undo .
define input parameter p-ret-sum-money       as character no-undo .
define input parameter p-chg-ret-sum-units   as character no-undo .
define input parameter p-chg-ret-sum-money   as character no-undo .
define input parameter p-spi-sum-units       as character no-undo .
define input parameter p-spi-sum-money       as character no-undo .
define input parameter p-RestFrom-units      as character no-undo .
define input parameter p-restFrom-money      as character no-undo .
define input parameter p-restEnd-units       as character no-undo .
define input parameter p-restEnd-money       as character no-undo .

define buffer buf_temp_sheet1_line-data      for temp_sheet1_line-data.

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
        v-wthobrxl-sheet1-cur-data-row = v-wthobrxl-sheet1-cur-data-row + 1
    .
    assign
        buf_temp_sheet1_line-data.sheet-name          = {&wthobrxl-sheet1-name}
        buf_temp_sheet1_line-data.xl-line-id          = v-wthobrxl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.cli-name            = p-cli-name
        buf_temp_sheet1_line-data.talon-name          = p-talon-name
        buf_temp_sheet1_line-data.talon-nominal       = p-talon-nominal
        buf_temp_sheet1_line-data.talon-series        = p-talon-series
        buf_temp_sheet1_line-data.give-sum-units      = p-give-sum-units
        buf_temp_sheet1_line-data.give-sum-money      = p-give-sum-money
        buf_temp_sheet1_line-data.chg-give-sum-units  = p-chg-give-sum-units
        buf_temp_sheet1_line-data.chg-give-sum-money  = p-chg-give-sum-money
        buf_temp_sheet1_line-data.sell-sum-units      = p-sell-sum-units
        buf_temp_sheet1_line-data.sell-sum-money      = p-sell-sum-money
        buf_temp_sheet1_line-data.ret-sum-units       = p-ret-sum-units
        buf_temp_sheet1_line-data.ret-sum-money       = p-ret-sum-money
        buf_temp_sheet1_line-data.chg-ret-sum-units   = p-chg-ret-sum-units
        buf_temp_sheet1_line-data.chg-ret-sum-money   = p-chg-ret-sum-money
        buf_temp_sheet1_line-data.spi-sum-units       = p-spi-sum-units
        buf_temp_sheet1_line-data.spi-sum-money       = p-spi-sum-money
        buf_temp_sheet1_line-data.RestFrom-units      = p-RestFrom-units
        buf_temp_sheet1_line-data.restFrom-money      = p-restFrom-money
        buf_temp_sheet1_line-data.restEnd-units       = p-restEnd-units
        buf_temp_sheet1_line-data.restEnd-money       = p-restEnd-money

    .
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        {&tabulation}   {&wthobrxl-data-label}
        {&tabulation}   buf_temp_sheet1_line-data.cli-name
        {&tabulation}   buf_temp_sheet1_line-data.talon-name
        {&tabulation}   buf_temp_sheet1_line-data.talon-nominal
        {&tabulation}   buf_temp_sheet1_line-data.talon-series
        {&tabulation}   buf_temp_sheet1_line-data.give-sum-units
        {&tabulation}   buf_temp_sheet1_line-data.give-sum-money
        {&tabulation}   buf_temp_sheet1_line-data.chg-give-sum-units
        {&tabulation}   buf_temp_sheet1_line-data.chg-give-sum-money
        {&tabulation}   buf_temp_sheet1_line-data.sell-sum-units
        {&tabulation}   buf_temp_sheet1_line-data.sell-sum-money
        {&tabulation}   buf_temp_sheet1_line-data.ret-sum-units
        {&tabulation}   buf_temp_sheet1_line-data.ret-sum-money
        {&tabulation}   buf_temp_sheet1_line-data.chg-ret-sum-units
        {&tabulation}   buf_temp_sheet1_line-data.chg-ret-sum-money
        {&tabulation}   buf_temp_sheet1_line-data.spi-sum-units
        {&tabulation}   buf_temp_sheet1_line-data.spi-sum-money
        {&tabulation}   buf_temp_sheet1_line-data.RestFrom-units
        {&tabulation}   buf_temp_sheet1_line-data.restFrom-money
        {&tabulation}   buf_temp_sheet1_line-data.restEnd-units
        {&tabulation}   buf_temp_sheet1_line-data.restEnd-money

        {&new-line}
    .
end.
end procedure. /* wthobrxl-write-line-data */

/*==========================================================================*/
procedure wthobrxl-write-cell-data :
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
end procedure. /* wthobrxl-write-cell-data */

/*==========================================================================*/
procedure wthobrxl-sheet1-write-line-format :
define input parameter p-fmt-label       as character  no-undo.


    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        {&wthobrxl-sheet1-name}
        {&tabulation}   {&wthobrxl-format-label}
        {&tabulation}   p-fmt-label
        {&new-line}
    .
end.
end procedure. /* wthobrxl-sheet1-write-line-format */

/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure wthobrxl-run-excel :
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
        v-template-file-name    = search( "exe/wth-obr.xlt" )
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
end procedure. /* wthobrxl-run-excel */


/*==========================================================================*/
procedure wthobrxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/wth-obr.xlt":U.
        export "exe/t_form.bas":U.
        export v-wthobrxl-cell-file-name.
        export v-wthobrxl-data-file-name.
    output close.
end.
end procedure. /* wthobrxl-close */

/* $Workfile$ e n d */