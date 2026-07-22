/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы Расшифровка реализации к сменному отчету в Excel

Автор: Кочетков Михаил Юрьевич
Дата создания: 12/21/06
Author: Michael Kochetkov
Creation date: 12/21/06

Required: { p a r a m l s . i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define shift3xl-data-label "DTA":U
&global-define shift3xl-format-label "FMT":U

&global-define shift3xl-sheetList  "Реализация":U

&global-define shift3xl-sheet1_valutCode       "Реализация_valutCode":U
&global-define shift3xl-sheet1_columnList      "Реализация_columnList":U
&global-define shift3xl-sheet1_columnType      "Реализация_columnType":U
&global-define shift3xl-sheet1_subtotalList    "Реализация_subtotalList":U
&global-define shift3xl-sheet1_subtotalType    "Реализация_subtotalType":U


&global-define shift3xl-h_Obj      "h_Obj":U
&global-define shift3xl-h_Date     "h_Date":U
&global-define shift3xl-f_teh1     "f_teh1":U
&global-define shift3xl-f_teh2     "f_teh2":U
&global-define shift3xl-f_teh3     "f_teh3":U
&global-define shift3xl-f_teh4     "f_teh4":U
&global-define shift3xl-f_teh5     "f_teh5":U
&global-define shift3xl-f_teh6     "f_teh6":U
&global-define shift3xl-f_teh7     "f_teh7":U
&global-define shift3xl-f_fteh1    "f_fteh1":U
&global-define shift3xl-f_fteh2    "f_fteh2":U
&global-define shift3xl-f_fteh3    "f_fteh3":U
&global-define shift3xl-f_fteh4    "f_fteh4":U
&global-define shift3xl-f_fteh5    "f_fteh5":U
&global-define shift3xl-f_fteh6    "f_fteh6":U
&global-define shift3xl-f_fteh7    "f_fteh7":U
&global-define shift3xl-f_count1   "f_count1":U
&global-define shift3xl-f_count2   "f_count2":U
&global-define shift3xl-f_count3   "f_count3":U
&global-define shift3xl-f_count4   "f_count4":U
&global-define shift3xl-f_count5   "f_count5":U
&global-define shift3xl-f_count6   "f_count6":U
&global-define shift3xl-f_count7   "f_count7":U
&global-define shift3xl-f_itog1    "f_itog1":U
&global-define shift3xl-f_itog2    "f_itog2":U
&global-define shift3xl-f_itog3    "f_itog3":U
&global-define shift3xl-f_itog4    "f_itog4":U
&global-define shift3xl-f_itog5    "f_itog5":U
&global-define shift3xl-f_itog6    "f_itog6":U
&global-define shift3xl-f_itog7    "f_itog7":U
&global-define shift3xl-f_delta1   "f_delta1":U
&global-define shift3xl-f_delta2   "f_delta2":U
&global-define shift3xl-f_delta3   "f_delta3":U
&global-define shift3xl-f_delta4   "f_delta4":U
&global-define shift3xl-f_delta5   "f_delta5":U
&global-define shift3xl-f_delta6   "f_delta6":U
&global-define shift3xl-f_delta7   "f_delta7":U

&global-define shift3xl-sheet1-name "Реализация":U

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
    field name   as character
    field DT_l   as character
    field DT_s   as character
    field AI80_l as character
    field AI80_s as character
    field AI92_l as character
    field AI92_s as character
    field AI95_l as character
    field AI95_s as character
    field AI98_l as character
    field AI98_s as character
    field SUG_l  as character
    field SUG_s  as character
    field all_l  as character
    field all_s  as character

    index pi is primary unique
        xl-line-id
.

define variable v-shift3xl-sheet1-cur-data-row     as integer      no-undo.
define variable v-shift3xl-cell-file-name       as character    no-undo.
define variable v-shift3xl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure shift3xl-init :

do
on error undo, return error
:
    assign
        v-shift3xl-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-shift3xl-data-file-name
    ).
    output stream excel-line to value( v-shift3xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-shift3xl-cell-file-name
    ).
    output stream excel-cell to value( v-shift3xl-cell-file-name ).
    run shift3xl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&shift3xl-sheetList}
    ).
    run shift3xl-write-cell-data in this-procedure (
          input {&shift3xl-sheet1_valutCode}
        , input "0":U
    ).
    run shift3xl-write-cell-data in this-procedure (
          input {&shift3xl-sheet1_columnList}
        , input "name,DT_l,DT_s,AI80_l,AI80_s,AI92_l,AI92_s,AI95_l,AI95_s,AI98_l,AI98_s,SUG_l,SUG_s,all_l,all_s"
    ).
    run shift3xl-write-cell-data in this-procedure (
          input {&shift3xl-sheet1_columnType}
        , input "S,S,S,S,S,S,S,S,S,S,S,S,S,S,S":U
    ).
    run shift3xl-write-cell-data in this-procedure (
          input {&shift3xl-sheet1_subtotalList}
        , input "":U
    ).
    run shift3xl-write-cell-data in this-procedure (
          input {&shift3xl-sheet1_subtotalType}
        , input "":U
    ).
end.
end procedure. /* shift3xl-init */

/*==========================================================================*/
procedure shift3xl-sheet1-write-line-data :
define input parameter p-name     as character        no-undo.
define input parameter p-DT_l     as character        no-undo.
define input parameter p-DT_s     as character        no-undo.
define input parameter p-AI80_l   as character        no-undo.
define input parameter p-AI80_s   as character        no-undo.
define input parameter p-AI92_l   as character        no-undo.
define input parameter p-AI92_s   as character        no-undo.
define input parameter p-AI95_l   as character        no-undo.
define input parameter p-AI95_s   as character        no-undo.
define input parameter p-AI98_l   as character        no-undo.
define input parameter p-AI98_s   as character        no-undo.
define input parameter p-SUG_l    as character        no-undo.
define input parameter p-SUG_s    as character        no-undo.
define input parameter p-all_l    as character        no-undo.
define input parameter p-all_s    as character        no-undo.

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
        v-shift3xl-sheet1-cur-data-row = v-shift3xl-sheet1-cur-data-row + 1
        buf_temp_sheet1_line-data.sheet-name    = {&shift3xl-sheet1-name}
        buf_temp_sheet1_line-data.xl-line-id    = v-shift3xl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.name    = p-name
        buf_temp_sheet1_line-data.DT_l    = p-DT_l
        buf_temp_sheet1_line-data.DT_s    = p-DT_s
        buf_temp_sheet1_line-data.AI80_l  = p-AI80_l
        buf_temp_sheet1_line-data.AI80_s  = p-AI80_s
        buf_temp_sheet1_line-data.AI92_l  = p-AI92_l
        buf_temp_sheet1_line-data.AI92_s  = p-AI92_s
        buf_temp_sheet1_line-data.AI95_l  = p-AI95_l
        buf_temp_sheet1_line-data.AI95_s  = p-AI95_s
        buf_temp_sheet1_line-data.AI98_l  = p-AI98_l
        buf_temp_sheet1_line-data.AI98_s  = p-AI98_s
        buf_temp_sheet1_line-data.SUG_l   = p-SUG_l
        buf_temp_sheet1_line-data.SUG_s   = p-SUG_s
        buf_temp_sheet1_line-data.all_l   = p-all_l
        buf_temp_sheet1_line-data.all_s   = p-all_s
    .
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        {&tabulation}   {&shift3xl-data-label}
        {&tabulation}   buf_temp_sheet1_line-data.name
        {&tabulation}   buf_temp_sheet1_line-data.DT_l
        {&tabulation}   buf_temp_sheet1_line-data.DT_s
        {&tabulation}   buf_temp_sheet1_line-data.AI80_l
        {&tabulation}   buf_temp_sheet1_line-data.AI80_s
        {&tabulation}   buf_temp_sheet1_line-data.AI92_l
        {&tabulation}   buf_temp_sheet1_line-data.AI92_s
        {&tabulation}   buf_temp_sheet1_line-data.AI95_l
        {&tabulation}   buf_temp_sheet1_line-data.AI95_s
        {&tabulation}   buf_temp_sheet1_line-data.AI98_l
        {&tabulation}   buf_temp_sheet1_line-data.AI98_s
        {&tabulation}   buf_temp_sheet1_line-data.SUG_l
        {&tabulation}   buf_temp_sheet1_line-data.SUG_s
        {&tabulation}   buf_temp_sheet1_line-data.all_l
        {&tabulation}   buf_temp_sheet1_line-data.all_s
        {&new-line}
    .
end.
end procedure. /* shift3xl-write-line-data */


/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure shift3xl-write-cell-data :
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
end procedure. /* shift3xl-write-cell-data */

/*==========================================================================*/
procedure shift3xl-run-excel :
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
        v-template-file-name    = search( "exe/shift3.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas")
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
end procedure. /* shift3xl-run-excel */


/*==========================================================================*/
procedure shift3xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
    export "exe/shift3.xlt":U.
    export "exe/t_form.bas":U.
    export v-shift3xl-cell-file-name.
    export v-shift3xl-data-file-name.
    output close.
end.
end procedure. /* shift3xl-close */

/* $Workfile$ e n d */