/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы Декларация об объемах розничной продажи алкогольной продукции (Псков) в Excel

Автор: Хныкин Павел Андреевич
Дата создания: 09/20/07
Author: Pavel Khnykin
Creation date: 09/20/07

Required: { p a r a m l s . i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define alc04xl-data-label "DTA":U
&global-define alc04xl-format-label "FMT":U

&global-define alc04xl-sheetList  "Декларация":U

&global-define alc04xl-sheet1_valutCode       "Декларация_valutCode":U
&global-define alc04xl-sheet1_columnList      "Декларация_columnList":U
&global-define alc04xl-sheet1_columnType      "Декларация_columnType":U
&global-define alc04xl-sheet1_subtotalList    "Декларация_subtotalList":U
&global-define alc04xl-sheet1_subtotalType    "Декларация_subtotalType":U

&global-define alc04xl-h_firmname "firmname":U
&global-define alc04xl-h_inn  "inn":U
&global-define alc04xl-h_kpp  "kpp":U

&global-define alc04xl-sheet1-name "Декларация":U

&global-define alc04xl-sheet1-it-ostbegin "Декларация_it_ostbegin":U
&global-define alc04xl-sheet1-it-purchase "Декларация_it_purchase":U
&global-define alc04xl-sheet1-it-sell     "Декларация_it_sell":U
&global-define alc04xl-sheet1-it-ret      "Декларация_it_ret":U
&global-define alc04xl-sheet1-it-other    "Декларация_it_other":U
&global-define alc04xl-sheet1-it-rastotal "Декларация_it_rastotal":U
&global-define alc04xl-sheet1-it-ostend   "Декларация_it_ostend":U

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
    field alc-type-num  as character
    field alc-type-name as character
    field alc-type-code as character
    field ost-begin     as character
    field purchase      as character
    field sell          as character
    field ret           as character
    field other         as character
    field ras-total     as character
    field ost-end       as character
index pi is primary unique
        xl-line-id
.


define variable v-alc04xl-sheet1-cur-data-row  as integer      no-undo.
define variable v-alc04xl-cell-file-name       as character    no-undo.
define variable v-alc04xl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure alc04xl-init :

do
on error undo, return error
:
    assign
        v-alc04xl-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-alc04xl-data-file-name
    ).
    output stream excel-line to value( v-alc04xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-alc04xl-cell-file-name
    ).
    output stream excel-cell to value( v-alc04xl-cell-file-name ).
    run alc04xl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&alc04xl-sheetList}
    ).
    if printrubl
    then do:
        run alc04xl-write-cell-data in this-procedure (
              input {&alc04xl-sheet1_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run alc04xl-write-cell-data in this-procedure (
              input {&alc04xl-sheet1_valutCode}
            , input "1":U
        ).
    end.
    run alc04xl-write-cell-data in this-procedure (
          input {&alc04xl-sheet1_columnList}
        , input "alctypenum,alctypename,alctypecode,ostbegin,purchase,sell,ret,other,rastotal,ostend":U
    ).
    run alc04xl-write-cell-data in this-procedure (
          input {&alc04xl-sheet1_columnType}
        , input "S,S,S,S,S,S,S,S,S,S":U
    ).
    run alc04xl-write-cell-data in this-procedure (
          input {&alc04xl-sheet1_subtotalList}
        , input "":U
    ).
    run alc04xl-write-cell-data in this-procedure (
          input {&alc04xl-sheet1_subtotalType}
        , input "":U
    ).
end.
end procedure. /* alc04xl-init */

/*==========================================================================*/
procedure alc04xl-sheet1-write-line-data :
define input parameter p-alc-type-num  as character no-undo .
define input parameter p-alc-type-name as character no-undo .
define input parameter p-alc-type-code as character no-undo .
define input parameter p-ost-begin     as character no-undo .
define input parameter p-purchase      as character no-undo .
define input parameter p-sell          as character no-undo .
define input parameter p-ret           as character no-undo .
define input parameter p-other         as character no-undo .
define input parameter p-ras-total     as character no-undo .
define input parameter p-ost-end       as character no-undo .


define buffer buf_temp_sheet1_line-data  for temp_sheet1_line-data.

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
        v-alc04xl-sheet1-cur-data-row           = v-alc04xl-sheet1-cur-data-row + 1
        buf_temp_sheet1_line-data.sheet-name    = {&alc04xl-sheet1-name}
        buf_temp_sheet1_line-data.xl-line-id    = v-alc04xl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.alc-type-num  = p-alc-type-num
        buf_temp_sheet1_line-data.alc-type-name = p-alc-type-name
        buf_temp_sheet1_line-data.alc-type-code = p-alc-type-code
        buf_temp_sheet1_line-data.ost-begin     = p-ost-begin
        buf_temp_sheet1_line-data.purchase      = p-purchase
        buf_temp_sheet1_line-data.sell          = p-sell
        buf_temp_sheet1_line-data.ret           = p-ret
        buf_temp_sheet1_line-data.other         = p-other
        buf_temp_sheet1_line-data.ras-total     = p-ras-total
        buf_temp_sheet1_line-data.ost-end       = p-ost-end
    .

    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        {&tabulation}   {&alc04xl-data-label}
        {&tabulation}   buf_temp_sheet1_line-data.alc-type-num
        {&tabulation}   buf_temp_sheet1_line-data.alc-type-name
        {&tabulation}   buf_temp_sheet1_line-data.alc-type-code
        {&tabulation}   buf_temp_sheet1_line-data.ost-begin
        {&tabulation}   buf_temp_sheet1_line-data.purchase
        {&tabulation}   buf_temp_sheet1_line-data.sell
        {&tabulation}   buf_temp_sheet1_line-data.ret
        {&tabulation}   buf_temp_sheet1_line-data.other
        {&tabulation}   buf_temp_sheet1_line-data.ras-total
        {&tabulation}   buf_temp_sheet1_line-data.ost-end
        {&new-line}
    .
    .
end.
end procedure. /* alc04xl-sheet1-write-line-data */

/*==========================================================================*/
procedure alc04xl-sheet1-write-line-format :
define input parameter p-fmt-label       as character  no-undo.


    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        {&alc04xl-sheet1-name}
        {&tabulation}   {&alc04xl-format-label}
        {&tabulation}   p-fmt-label
        {&new-line}
    .
end.
end procedure. /* alc04xl-sheet1-write-line-format */


/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure alc04xl-write-cell-data :
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
end procedure. /* alc04xl-write-cell-data */

/*==========================================================================*/
procedure alc04xl-run-excel :
define input parameter p-header-filename    as character        no-undo.
define input parameter p-data-filename      as character        no-undo.

    define variable v-Template-file-name    as character    no-undo.
    define variable v-vb-file-name          as character    no-undo.

    define buffer buf_temp-param for temp-param .
do
for buf_temp-param
on error undo, return error
:
    create buf_temp-param.
    assign
        v-Template-file-name    = search( "exe/alcdcl04.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas")
    .
    if v-Template-file-name = ?
    or v-Template-file-name = "":U
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
          input {&paramls-Template}
        , input {&paramls-Template-file-name}
        , input v-Template-file-name
    ).
    run paramls-write in this-procedure (
          input {&paramls-Template}
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
end procedure. /* alc04xl-run-excel */


/*==========================================================================*/
procedure alc04xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/alcdcl04.xlt":U.
        export "exe/t_form.bas":U.
        export v-alc04xl-cell-file-name.
        export v-alc04xl-data-file-name.
    output close.
end.
end procedure. /* alc04xl-close */

/* $Workfile$ e n d */