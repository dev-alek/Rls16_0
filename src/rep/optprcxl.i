/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона оптовый прайс-лист

Автор: Хныкин Павел Андреевич
Дата создания: 11/26/08
Author: Pavel Khnykin
Creation date: 11/26/08

Required: { p a r a m l s . i }

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define optprcxl-data-label "DTA":U
&global-define optprcxl-format-label "FMT":U

&global-define optprcxl-sheetList  "Template":U

&global-define optprcxl-sheet1_valutCode       "Template_valutCode":U
&global-define optprcxl-sheet1_columnList      "Template_columnList":U
&global-define optprcxl-sheet1_columnType      "Template_columnType":U
&global-define optprcxl-sheet1_subtotalList    "Template_subtotalList":U
&global-define optprcxl-sheet1_subtotalType    "Template_subtotalType":U

&global-define optprcxl-h_org "h_org":U
&global-define optprcxl-h_time "h_time":U
&global-define optprcxl-h_currency "h_currency":U
&global-define optprcxl-sheet1-name "Template":U



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
    field artic         as character
    field barcode       as character
    field gdsname       as character
    field prodname      as character
    field unitname      as character
    field price         as decimal
    field unitqnty      as character
    field unitprice     as character
    index pi is primary unique
        xl-line-id
.


define variable v-optprcxl-sheet1-cur-data-row     as integer      no-undo.
define variable v-optprcxl-cell-file-name       as character    no-undo.
define variable v-optprcxl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure optprcxl-init :

do
on error undo, return error
:
    assign
        v-optprcxl-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-optprcxl-data-file-name
    ).
    output stream excel-line to value( v-optprcxl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-optprcxl-cell-file-name
    ).
    output stream excel-cell to value( v-optprcxl-cell-file-name ).
    run optprcxl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&optprcxl-sheetList}
    ).
    if printrubl
    then do:
        run optprcxl-write-cell-data in this-procedure (
              input {&optprcxl-sheet1_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run optprcxl-write-cell-data in this-procedure (
              input {&optprcxl-sheet1_valutCode}
            , input "1":U
        ).
    end.
    run optprcxl-write-cell-data in this-procedure (
          input {&optprcxl-sheet1_columnList}
        , input "artic,barcode,gdsname,prodname,unitname,price,unitqnty,unitprice":U
    ).
    run optprcxl-write-cell-data in this-procedure (
          input {&optprcxl-sheet1_columnType}
        , input "S,S,S,S,S,D,S,S":U
    ).
    run optprcxl-write-cell-data in this-procedure (
          input {&optprcxl-sheet1_subtotalList}
        , input "":U
    ).
    run optprcxl-write-cell-data in this-procedure (
          input {&optprcxl-sheet1_subtotalType}
        , input "":U
    ).
end.
end procedure. /* optprcxl-init */

/*==========================================================================*/
procedure optprcxl-sheet1-write-line-data :
  define input  parameter p-artic         as character no-undo .
  define input  parameter p-barcode       as character no-undo .
  define input  parameter p-gdsname       as character no-undo .
  define input  parameter p-prodname      as character no-undo .
  define input  parameter p-unitname      as character no-undo .
  define input  parameter p-price         as decimal   no-undo .
  define input  parameter p-unitqnty      as character no-undo .
  define input  parameter p-unitprice     as character no-undo .

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
        v-optprcxl-sheet1-cur-data-row = v-optprcxl-sheet1-cur-data-row + 1
        buf_temp_sheet1_line-data.sheet-name = {&optprcxl-sheet1-name}
        buf_temp_sheet1_line-data.xl-line-id = v-optprcxl-sheet1-cur-data-row

        buf_temp_sheet1_line-data.artic     = p-artic
        buf_temp_sheet1_line-data.barcode   = p-barcode
        buf_temp_sheet1_line-data.gdsname   = p-gdsname
        buf_temp_sheet1_line-data.prodname  = p-prodname
        buf_temp_sheet1_line-data.unitname  = p-unitname
        buf_temp_sheet1_line-data.price     = p-price
        buf_temp_sheet1_line-data.unitqnty  = p-unitqnty
        buf_temp_sheet1_line-data.unitprice = p-unitprice
    .
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        {&tabulation}   {&optprcxl-data-label}
        {&tabulation}   buf_temp_sheet1_line-data.artic
        {&tabulation}   buf_temp_sheet1_line-data.barcode
        {&tabulation}   buf_temp_sheet1_line-data.gdsname
        {&tabulation}   buf_temp_sheet1_line-data.prodname
        {&tabulation}   buf_temp_sheet1_line-data.unitname
        {&tabulation}   buf_temp_sheet1_line-data.price
        {&tabulation}   buf_temp_sheet1_line-data.unitqnty
        {&tabulation}   buf_temp_sheet1_line-data.unitprice
        {&new-line}
    .
end.
end procedure. /* optprcxl-sheet1-write-line-data */

/*==========================================================================*/
procedure optprcxl-sheet1-write-line-format :
  define input parameter p-fmt-label  as character  no-undo.

  define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        {&optprcxl-sheet1-name}
        {&tabulation}   {&optprcxl-format-label}
        {&tabulation}   p-fmt-label
        {&new-line}
    .
end.
end procedure. /* optprcxl-sheet1-write-line-format */

/*==========================================================================*/
procedure optprcxl-write-cell-data :
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
end procedure. /* optprcxl-write-cell-data */

/*==========================================================================*/
procedure optprcxl-run-excel :
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
        v-Template-file-name    = search( "exe/optprice.xlt" )
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
end procedure. /* optprcxl-run-excel */


/*==========================================================================*/
procedure optprcxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/optprice.xlt":U.
        export "exe/t_form.bas":U.
        export v-optprcxl-cell-file-name.
        export v-optprcxl-data-file-name.
    output close.
end.
end procedure. /* optprcxl-close */

/* $Workfile$ e n d */