/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Акт переоценки ТАП-1-ДО (процедуры работы с шаблоном)

Автор: Белоусов Илья Александрович
Дата создания: 01/15/09
Author: Ilia Belousov
Creation date: 01/15/09

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


&global-define tap1-data-label "DTA":U
&global-define tap1-format-label "FMT":U

&global-define tap1-sheetList  "Лист1":U

&global-define tap1-sheet1_valutCode       "Лист1_valutCode":U
&global-define tap1-sheet1_columnList      "Лист1_columnList":U
&global-define tap1-sheet1_columnType      "Лист1_columnType":U
&global-define tap1-sheet1_subtotalList    "Лист1_subtotalList":U
&global-define tap1-sheet1_subtotalType    "Лист1_subtotalType":U

&global-define tap1-sheet1-name            "Лист1":U

&global-define tap1-firm              "firm":U
&global-define tap1-object            "object":U
&global-define tap1-number_begin      "number_begin":U
&global-define tap1-number_end        "number_end":U
&global-define tap1-qnty_prop         "qnty_prop":U
&global-define tap1-doc_num           "doc_num":U
&global-define tap1-doc_date          "doc_date":U
&global-define tap1-summ_prop         "summ_prop":U
&global-define tap1-summ_after_prop   "summ_after_prop":U
&global-define tap1-it_qnty           "it_qnty":U
&global-define tap1-it_summ_before    "it_summ_before":U
&global-define tap1-it_summ_after     "it_summ_after":U
&global-define tap1-it_delta          "it_delta":U
&global-define tap1-h_post_header     "h_post_header":U
&global-define tap1-h_post_footer_1   "h_post_footer_1":U
&global-define tap1-h_post_footer_2   "h_post_footer_2":U
&global-define tap1-h_post_footer_3   "h_post_footer_3":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.



define variable v-tap1-sheet1-cur-data-row     as integer      no-undo.

define variable v-tap1-cell-file-name       as character    no-undo.
define variable v-tap1-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure tap1-init :

do
on error undo, return error
:
    assign
        v-tap1-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-tap1-data-file-name
    ).
    output stream excel-line to value( v-tap1-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-tap1-cell-file-name
    ).
    output stream excel-cell to value( v-tap1-cell-file-name ).
    run tap1-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&tap1-sheetList}
    ).
    if printrubl
    then do:
        run tap1-write-cell-data in this-procedure (
              input {&tap1-sheet1_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run tap1-write-cell-data in this-procedure (
              input {&tap1-sheet1_valutCode}
            , input "1":U
        ).
    end.


    run tap1-write-cell-data in this-procedure (
          input {&tap1-sheet1_columnList}
        , input "number,artic,name,chrt,meas,qnty,price_before,summ_before,price_after,summ_after,delta":U
    ).
    run tap1-write-cell-data in this-procedure (
          input {&tap1-sheet1_columnType}
        , input "S,S,S,S,S,S,S,S,S,S,S":U
    ).
    run tap1-write-cell-data in this-procedure (
          input {&tap1-sheet1_subtotalList}
        , input "":U
    ).
    run tap1-write-cell-data in this-procedure (
          input {&tap1-sheet1_subtotalType}
        , input "":U
    ).

end.
end procedure. /* tap1-init */


/*==========================================================================*/
procedure tap1-sheet1-write-line-data :
define input parameter p-number       as character        no-undo.
define input parameter p-artic        as character        no-undo.
define input parameter p-name         as character        no-undo.
define input parameter p-chrt         as character        no-undo.
define input parameter p-meas         as character        no-undo.
define input parameter p-qnty         as character        no-undo.
define input parameter p-price_before as character        no-undo.
define input parameter p-summ_before  as character        no-undo.
define input parameter p-price_after  as character        no-undo.
define input parameter p-summ_after   as character        no-undo.
define input parameter p-delta        as character        no-undo.

do
on error undo, return error
:
   put stream excel-line unformatted
                        {&tap1-sheet1-name}
         {&tabulation}  {&tap1-data-label}
         {&tabulation}  p-number
         {&tabulation}  p-artic
         {&tabulation}  p-name
         {&tabulation}  p-chrt
         {&tabulation}  p-meas
         {&tabulation}  p-qnty
         {&tabulation}  p-price_before
         {&tabulation}  p-summ_before
         {&tabulation}  p-price_after
         {&tabulation}  p-summ_after
         {&tabulation}  p-delta
         {&new-line}
   .
end.
end procedure. /* tap1-sheet1-write-line-data */


/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure tap1-write-cell-data :
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
end procedure. /* tap1-write-cell-data */

/*==========================================================================*/
procedure tap1-run-excel :
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
        v-template-file-name    = search( "exe/wth-tap1.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas" )
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
end procedure. /* tap1-run-excel */


/*==========================================================================*/
procedure tap1-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/wth-tap1.xlt" .
        export "exe/t_form.bas" .
        export v-tap1-cell-file-name.
        export v-tap1-data-file-name.
    output close.
end.
end procedure. /* tap1-close */

/* $Workfile$ e n d */