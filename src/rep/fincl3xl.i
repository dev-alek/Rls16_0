/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы Декларация об объемах розничной продажи алкогольной продукции (Калуга) в Excel

Автор: Демин Алексей Сергеевич
Дата создания: 12/21/06
Author: Alexey Demin
Creation date: 12/21/06

Required: { p a r a m l s . i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define fincl3xl-data-label "DTA":U
&global-define fincl3xl-format-label "FMT":U

&global-define fincl3xl-sheetList  "Template":U

&global-define fincl3xl-sheet1_valutCode       "Template_valutCode":U
&global-define fincl3xl-sheet1_columnList      "Template_columnList":U
&global-define fincl3xl-sheet1_columnType      "Template_columnType":U
&global-define fincl3xl-sheet1_subtotalList    "Template_subtotalList":U
&global-define fincl3xl-sheet1_subtotalType    "Template_subtotalType":U

&global-define fincl3xl-h_header "h_header":U

&global-define fincl3xl-sheet1-name "Template":U



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
    field opName       as character
    field opDate       as character
    field docCode      as character
    field debetSum     as character
    field creditSum    as character

    index pi is primary unique
        xl-line-id
.


define variable v-fincl3xl-sheet1-cur-data-row     as integer      no-undo.
define variable v-fincl3xl-cell-file-name       as character    no-undo.
define variable v-fincl3xl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure fincl3xl-init :

do
on error undo, return error
:
    assign
        v-fincl3xl-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-fincl3xl-data-file-name
    ).
    output stream excel-line to value( v-fincl3xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-fincl3xl-cell-file-name
    ).
    output stream excel-cell to value( v-fincl3xl-cell-file-name ).
    run fincl3xl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&fincl3xl-sheetList}
    ).
    if printrubl
    then do:
        run fincl3xl-write-cell-data in this-procedure (
              input {&fincl3xl-sheet1_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run fincl3xl-write-cell-data in this-procedure (
              input {&fincl3xl-sheet1_valutCode}
            , input "1":U
        ).
    end.
    run fincl3xl-write-cell-data in this-procedure (
          input {&fincl3xl-sheet1_columnList}
        , input "opName,opDate,docCode,debetSum,creditSum":U
    ).
    run fincl3xl-write-cell-data in this-procedure (
          input {&fincl3xl-sheet1_columnType}
        , input "S,S,S,S,S":U
    ).
    run fincl3xl-write-cell-data in this-procedure (
          input {&fincl3xl-sheet1_subtotalList}
        , input "":U
    ).
    run fincl3xl-write-cell-data in this-procedure (
          input {&fincl3xl-sheet1_subtotalType}
        , input "":U
    ).
end.
end procedure. /* fincl3xl-init */

/*==========================================================================*/
procedure fincl3xl-sheet1-write-line-data :
define input parameter p-opName       as character  no-undo.
define input parameter p-opDate       as character  no-undo.
define input parameter p-docCode      as character  no-undo.
define input parameter p-debetSum     as character  no-undo.
define input parameter p-creditSum    as character  no-undo.


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
        v-fincl3xl-sheet1-cur-data-row = v-fincl3xl-sheet1-cur-data-row + 1
        buf_temp_sheet1_line-data.sheet-name = {&fincl3xl-sheet1-name}
        buf_temp_sheet1_line-data.xl-line-id = v-fincl3xl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.opName     = p-opName
        buf_temp_sheet1_line-data.opDate     = p-opDate
        buf_temp_sheet1_line-data.docCode    = p-docCode
        buf_temp_sheet1_line-data.debetSum   = p-debetSum
        buf_temp_sheet1_line-data.creditSum  = p-creditSum
    .
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        {&tabulation}   {&fincl3xl-data-label}
        {&tabulation}   buf_temp_sheet1_line-data.opName
        {&tabulation}   buf_temp_sheet1_line-data.opDate
        {&tabulation}   buf_temp_sheet1_line-data.docCode
        {&tabulation}   buf_temp_sheet1_line-data.debetSum
        {&tabulation}   buf_temp_sheet1_line-data.creditSum
        {&new-line}
    .
    .
end.
end procedure. /* fincl3xl-sheet1-write-line-data */

/*==========================================================================*/
procedure fincl3xl-sheet1-write-line-format :
define input parameter p-fmt-label       as character  no-undo.


    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        {&fincl3xl-sheet1-name}
        {&tabulation}   {&fincl3xl-format-label}
        {&tabulation}   p-fmt-label
        {&new-line}
    .
end.
end procedure. /* fincl3xl-sheet1-write-line-format */


/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure fincl3xl-write-cell-data :
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
end procedure. /* fincl3xl-write-cell-data */

/*==========================================================================*/
procedure fincl3xl-run-excel :
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
        v-Template-file-name    = search( "exe/fincl3.xlt" )
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
end procedure. /* fincl3xl-run-excel */


/*==========================================================================*/
procedure fincl3xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/fincl3.xlt":U.
        export "exe/t_form.bas":U.
        export v-fincl3xl-cell-file-name.
        export v-fincl3xl-data-file-name.
    output close.
end.
end procedure. /* fincl3xl-close */

/* $Workfile$ e n d */