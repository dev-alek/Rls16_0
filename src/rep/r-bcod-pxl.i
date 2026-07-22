/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы Требования-накладной (форма М-11) в Excel

Автор: Морозов Александр Сергеевич
Дата создания: 24/03/11
Author: Alexandr Morozov
Creation date: 24/03/11

Required: { p a r a m l s . i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define r-bcod-pxl-excel-out-type-normal      1
&global-define r-bcod-pxl-excel-out-type-scale-head  2
&global-define r-bcod-pxl-excel-out-type-scale-line  3
&global-define r-bcod-pxl-excel-out-type-group       4
&global-define r-bcod-pxl-excel-out-type-bcode       5

&global-define r-bcod-pxl-data-label "DTA":U
&global-define r-bcod-pxl-format-label "FMT":U

&global-define r-bcod-pxl-sheetList  "бар_коды":U
&global-define r-bcod-pxl-sheet1_valutCode       "бар_коды_valutCode":U
&global-define r-bcod-pxl-sheet1_columnList      "бар_коды_columnList":U
&global-define r-bcod-pxl-sheet1_columnType      "бар_коды_columnType":U
&global-define r-bcod-pxl-sheet1_subtotalList    "бар_коды_subtotalList":U
&global-define r-bcod-pxl-sheet1_subtotalType    "бар_коды_subtotalType":U

&global-define r-bcod-pxl-sheet1-name   "бар_коды":U
&global-define r-bcod-pxl-h_sender      "h_sender":U
&global-define r-bcod-pxl-h_buyer       "h_buyer":U                                                                   
&global-define r-bcod-pxl-h_note       "h_note":U
&global-define r-bcod-pxl-h_cost       "h_cost":U
&global-define r-bcod-pxl-h_count       "h_count":U
&global-define r-bcod-pxl-h_head_info  "h_head_info":U
&global-define r-bcod-pxl-h_date_print "h_date_print":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.

define variable v-r-bcod-pxl-current-data-row     as integer      no-undo.
define variable v-r-bcod-pxl-sheet1-cur-data-row  as integer      no-undo.
define variable v-r-bcod-pxl-cell-file-name       as character    no-undo.
define variable v-r-bcod-pxl-data-file-name       as character    no-undo.


/*==========================================================================*/
procedure r-bcod-pxl-init :

do
on error undo, return error
:
    assign
        v-r-bcod-pxl-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-r-bcod-pxl-data-file-name
    ).
    output stream excel-line to value( v-r-bcod-pxl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-r-bcod-pxl-cell-file-name
    ).
    output stream excel-cell to value( v-r-bcod-pxl-cell-file-name ).
    run r-bcod-pxl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&r-bcod-pxl-sheetList}
    ).
    if printrubl
    then do:
        run r-bcod-pxl-write-cell-data in this-procedure (
              input {&r-bcod-pxl-sheet1_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run r-bcod-pxl-write-cell-data in this-procedure (
              input {&r-bcod-pxl-sheet1_valutCode}
            , input "1":U
        ).
    end.
    run r-bcod-pxl-write-cell-data in this-procedure (
          input {&r-bcod-pxl-sheet1_columnList}
        , input "num,code,artic,prod_name,unit,price,count,cost,bcodes":U
    ).
    run r-bcod-pxl-write-cell-data in this-procedure (
          input {&r-bcod-pxl-sheet1_columnType}
        , input "I,I,S,S,S,S,S,D,S":U
    ).
    run r-bcod-pxl-write-cell-data in this-procedure (
          input {&r-bcod-pxl-sheet1_subtotalList}
        , input "":U
    ).
    run r-bcod-pxl-write-cell-data in this-procedure (
          input {&r-bcod-pxl-sheet1_subtotalType}
        , input "":U
    ).
end.
end procedure. /* r-bcod-pxl-init */


/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure r-bcod-pxl-write-cell-data :
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
end procedure. /* r-bcod-pxl-write-cell-data */

/*==========================================================================*/

procedure r-bcod-pxl-write-line-data:
    /* тип вывода */
    def input param p-type as int no-undo.
    
    def input param p-num as int no-undo.
    def input param p-code as int no-undo.
    def input param p-artic as char no-undo.
    def input param p-prod-name as char no-undo.
    def input param p-unit as char no-undo.
    def input param p-price as dec no-undo.
    def input param p-count as char no-undo.
    def input param p-cost as dec no-undo.
    def input param p-bcode as char no-undo.
    
    def var i as int no-undo.
    def var num as int no-undo.
    
    v-r-bcod-pxl-current-data-row = v-r-bcod-pxl-current-data-row + 1.
    
    /* обычный вывод строки */
    if p-type = {&r-bcod-pxl-excel-out-type-normal} then do:
        put stream excel-line unformatted
                          {&r-bcod-pxl-sheet1-name}
            {&tabulation} {&r-bcod-pxl-data-label}
            {&tabulation} p-num
            {&tabulation} p-code
            {&tabulation} p-artic
            {&tabulation} p-prod-name
            {&tabulation} p-unit
            {&tabulation} p-price
            {&tabulation} p-count
            {&tabulation} p-cost
            {&tabulation} p-bcode
            {&new-line}
        .
    end.
    /* вывод заголовка шкалы */
    else if p-type = {&r-bcod-pxl-excel-out-type-scale-head} then do:
        put stream excel-line unformatted
                          {&r-bcod-pxl-sheet1-name}
            {&tabulation} {&r-bcod-pxl-data-label}
            {&tabulation} ""
            {&tabulation} p-code
            {&tabulation} p-artic
            {&tabulation} p-prod-name
            {&tabulation} p-unit
            {&tabulation} ""
            {&tabulation} ""
            {&tabulation} ""
            {&tabulation} ""
            {&new-line}
        .
    end.
    /* вывод линии шкалы */
    else if p-type = {&r-bcod-pxl-excel-out-type-scale-line} then do:
        put stream excel-line unformatted
                          {&r-bcod-pxl-sheet1-name}
            {&tabulation} {&r-bcod-pxl-data-label}
            {&tabulation} p-num
            {&tabulation} p-code
            {&tabulation} ""
            {&tabulation} p-prod-name
            {&tabulation} ""
            {&tabulation} p-price
            {&tabulation} p-count
            {&tabulation} p-cost
            {&tabulation} p-bcode
            {&new-line}
        .
    end.
    /* вывод названия группы */
    else if p-type = {&r-bcod-pxl-excel-out-type-group} then do:
        put stream excel-line unformatted
                          {&r-bcod-pxl-sheet1-name}
            {&tabulation} {&r-bcod-pxl-data-label}
            {&tabulation} "-1" /* позже через vba-скрипт эта строчка будет смержена и записано название группы */
            {&tabulation} ""
            {&tabulation} ""
            {&tabulation} p-prod-name
            {&tabulation} ""
            {&tabulation} ""
            {&tabulation} ""
            {&tabulation} ""
            {&tabulation} ""
            {&new-line}
        .
    end.
    /* вывод бар-кодов */
    else if p-type = {&r-bcod-pxl-excel-out-type-bcode} then do:
        put stream excel-line unformatted
                          {&r-bcod-pxl-sheet1-name}
            {&tabulation} {&r-bcod-pxl-data-label}
            {&tabulation} ""
            {&tabulation} ""
            {&tabulation} ""
            {&tabulation} ""
            {&tabulation} ""
            {&tabulation} ""
            {&tabulation} ""
            {&tabulation} ""
            {&tabulation} p-bcode
            {&new-line}
        .
    end.
end.

/*==========================================================================*/
procedure r-bcod-pxl-run-excel :
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
        v-template-file-name    = search( "exe/r-bcod-p.xlt" )
        v-vb-file-name          = search( "exe/r-bcod-p.bas")
    .
    
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
end procedure. /* r-bcod-pxl-run-excel */


/*==========================================================================*/
procedure r-bcod-pxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/r-bcod-p.xlt":U.
        export "exe/r-bcod-p.bas":U.
        export v-r-bcod-pxl-cell-file-name.
        export v-r-bcod-pxl-data-file-name.
    output close.
end.
end procedure. /* r-bcod-pxl-close */
/* $Workfile$ e n d */