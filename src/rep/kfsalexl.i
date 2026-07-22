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

&global-define kfsalexl-data-label "DTA":U
&global-define kfsalexl-format-label "FMT":U

&global-define kfsalexl-sheetList  "Лист1":U

&global-define kfsalexl-sheet1_valutCode       "Лист1_valutCode":U
&global-define kfsalexl-sheet1_columnList      "Лист1_columnList":U
&global-define kfsalexl-sheet1_columnType      "Лист1_columnType":U
&global-define kfsalexl-sheet1_subtotalList    "Лист1_subtotalList":U
&global-define kfsalexl-sheet1_subtotalType    "Лист1_subtotalType":U

&global-define kfsalexl-h_date "h_date":U
&global-define kfsalexl-h_obj  "h_obj":U

&global-define kfsalexl-sheet1-name "Лист1":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.

define temp-table temp_sheet1_line-data no-undo
    field sheet-name         as character
    field xl-line-id         as integer
    field gds-name           as character
    field pump-code          as integer
    field end-state-el-cnt   as decimal
    field begin-state-el-cnt as decimal
    field sale-state-el-cnt  as decimal
    field end-state-mh-cnt   as decimal
    field begin-state-mh-cnt as decimal
    field sale-state-mh-cnt  as decimal
    field state-divergence   as decimal
    field sale-state         as decimal
    field sale-techfuel      as decimal
    field sale-total         as decimal
index pi is primary unique
        xl-line-id
.


define variable v-kfsalexl-sheet1-cur-data-row  as integer      no-undo.
define variable v-kfsalexl-cell-file-name       as character    no-undo.
define variable v-kfsalexl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure kfsalexl-init :

do
on error undo, return error
:
    assign
        v-kfsalexl-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-kfsalexl-data-file-name
    ).
    output stream excel-line to value( v-kfsalexl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-kfsalexl-cell-file-name
    ).
    output stream excel-cell to value( v-kfsalexl-cell-file-name ).
    run kfsalexl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&kfsalexl-sheetList}
    ).
    if printrubl
    then do:
        run kfsalexl-write-cell-data in this-procedure (
              input {&kfsalexl-sheet1_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run kfsalexl-write-cell-data in this-procedure (
              input {&kfsalexl-sheet1_valutCode}
            , input "1":U
        ).
    end.
    run kfsalexl-write-cell-data in this-procedure (
          input {&kfsalexl-sheet1_columnList}
        , input "gds_name,pump_code,end_state_el_cnt,begin_state_el_cnt,sale_state_el_cnt,end_state_mh_cnt,begin_state_mh_cnt,sale_state_mh_cnt,state_divergence,sale_state,sale_techfuel,sale_total":U
    ).
    run kfsalexl-write-cell-data in this-procedure (
          input {&kfsalexl-sheet1_columnType}
        , input "S,I,D,D,D,D,D,D,D,D,D,D":U
    ).
    run kfsalexl-write-cell-data in this-procedure (
          input {&kfsalexl-sheet1_subtotalList}
        , input "":U
    ).
    run kfsalexl-write-cell-data in this-procedure (
          input {&kfsalexl-sheet1_subtotalType}
        , input "":U
    ).
end.
end procedure. /* kfsalexl-init */

/*==========================================================================*/
procedure kfsalexl-sheet1-write-line-data :
  define input  parameter p-gds-name           as character no-undo .
  define input  parameter p-pump-code          as integer   no-undo .
  define input  parameter p-end-state-el-cnt   as decimal   no-undo .
  define input  parameter p-begin-state-el-cnt as decimal   no-undo .
  define input  parameter p-sale-state-el-cnt  as decimal   no-undo .
  define input  parameter p-end-state-mh-cnt   as decimal   no-undo .
  define input  parameter p-begin-state-mh-cnt as decimal   no-undo .
  define input  parameter p-sale-state-mh-cnt  as decimal   no-undo .
  define input  parameter p-state-divergence   as decimal   no-undo .
  define input  parameter p-sale-state         as decimal   no-undo .
  define input  parameter p-sale-techfuel      as decimal   no-undo .
  define input  parameter p-sale-total         as decimal   no-undo .

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
        v-kfsalexl-sheet1-cur-data-row                = v-kfsalexl-sheet1-cur-data-row + 1
        buf_temp_sheet1_line-data.sheet-name          = {&kfsalexl-sheet1-name}
        buf_temp_sheet1_line-data.xl-line-id          = v-kfsalexl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.gds-name            = p-gds-name
        buf_temp_sheet1_line-data.pump-code           = p-pump-code
        buf_temp_sheet1_line-data.end-state-el-cnt    = p-end-state-el-cnt
        buf_temp_sheet1_line-data.begin-state-el-cnt  = p-begin-state-el-cnt
        buf_temp_sheet1_line-data.sale-state-el-cnt   = p-sale-state-el-cnt
        buf_temp_sheet1_line-data.end-state-mh-cnt    = p-end-state-mh-cnt
        buf_temp_sheet1_line-data.begin-state-mh-cnt  = p-begin-state-mh-cnt
        buf_temp_sheet1_line-data.sale-state-mh-cnt   = p-sale-state-mh-cnt
        buf_temp_sheet1_line-data.state-divergence    = p-state-divergence
        buf_temp_sheet1_line-data.sale-state          = p-sale-state
        buf_temp_sheet1_line-data.sale-techfuel       = p-sale-techfuel
        buf_temp_sheet1_line-data.sale-total          = p-sale-total
    .

    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        {&tabulation}   {&kfsalexl-data-label}
        {&tabulation}   buf_temp_sheet1_line-data.gds-name
        {&tabulation}   buf_temp_sheet1_line-data.pump-code
        {&tabulation}   buf_temp_sheet1_line-data.end-state-el-cnt
        {&tabulation}   buf_temp_sheet1_line-data.begin-state-el-cnt
        {&tabulation}   buf_temp_sheet1_line-data.sale-state-el-cnt
        {&tabulation}   buf_temp_sheet1_line-data.end-state-mh-cnt
        {&tabulation}   buf_temp_sheet1_line-data.begin-state-mh-cnt
        {&tabulation}   buf_temp_sheet1_line-data.sale-state-mh-cnt
        {&tabulation}   buf_temp_sheet1_line-data.state-divergence
        {&tabulation}   buf_temp_sheet1_line-data.sale-state
        {&tabulation}   buf_temp_sheet1_line-data.sale-techfuel
        {&tabulation}   buf_temp_sheet1_line-data.sale-total
        {&new-line}
    .
end.
end procedure. /* kfsalexl-sheet1-write-line-data */

/*==========================================================================*/
procedure kfsalexl-sheet1-write-line-format :
define input parameter p-fmt-label       as character  no-undo.


    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        {&kfsalexl-sheet1-name}
        {&tabulation}   {&kfsalexl-format-label}
        {&tabulation}   p-fmt-label
        {&new-line}
    .
end.
end procedure. /* kfsalexl-sheet1-write-line-format */


/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure kfsalexl-write-cell-data :
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
end procedure. /* kfsalexl-write-cell-data */

/*==========================================================================*/
procedure kfsalexl-run-excel :
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
        v-Template-file-name    = search( "exe/kfsale.xlt" )
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
end procedure. /* kfsalexl-run-excel */


/*==========================================================================*/
procedure kfsalexl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/kfsale.xlt":U.
        export "exe/t_form.bas":U.
        export v-kfsalexl-cell-file-name.
        export v-kfsalexl-data-file-name.
    output close.
end.
end procedure. /* kfsalexl-close */

/* $Workfile$ e n d */