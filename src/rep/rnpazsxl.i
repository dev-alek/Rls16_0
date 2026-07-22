/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы Данные о реализации НП на АЗС за период (ТамбовНП) в Excel

Автор: Самков Сергей Васильевич
Дата создания: 06/01/12
Author: Samkov Sergey
Creation date: 06/01/12

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define rnpazsxl-line-data-key "LD":U

&global-define rnpazsxl-sheet1_valutCode       "valutCode":U
&global-define rnpazsxl-sheet1_columnList      "columnList":U
&global-define rnpazsxl-sheet1_columnType      "columnType":U
&global-define rnpazsxl-sheet1_subtotalList    "subtotalList":U
&global-define rnpazsxl-sheet1_subtotalType    "subtotalType":U
&global-define rnpazsxl-columnAmount "columnAmount":U
&global-define rnpazsxl-regularExpressions "regularExpressions":U

&global-define rnpazsxl-h_date      "h_date":U
&global-define rnpazsxl-h_obj       "h_obj":U
&global-define rnpazsxl-h_num       "h_num":U
&global-define rnpazsxl-h_docname   "h_docName"
&global-define rnpazsxl-h_printdate "h_printdate":U

&global-define rnpazsxl-f_sign      "f_sign":U

&global-define sum-fmt ">>>>>>>>>>>>>>>9.<<":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.
define temp-table temp_sheet1_line-data no-undo
    field xl-line-id as integer
    field data-key   as character
    field firm       as character
    field region     as character
    field azs_name   as character
    field gds_type   as character
    field gds_code   as character
    field data_sell  as date
    field nqty       as decimal
    field price      as decimal
    field sum_sell   as decimal
    field price_type as character
    index pi is primary unique
        xl-line-id
    index p_print
      data_sell
      azs_name
      gds_type
      price_type
.

define variable v-rnpazsxl-sheet1-cur-data-row     as integer      no-undo.
define variable v-rnpazsxl-cell-file-name       as character    no-undo.
define variable v-rnpazsxl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure rnpazsxl-init :

do
on error undo, return error
:
    assign
      v-rnpazsxl-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-rnpazsxl-data-file-name
    ).
    output stream excel-line to value( v-rnpazsxl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-rnpazsxl-cell-file-name
    ).
    output stream excel-cell to value( v-rnpazsxl-cell-file-name ).
    if printrubl
    then do:
        run rnpazsxl-write-cell-data in this-procedure (
              input {&rnpazsxl-sheet1_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run rnpazsxl-write-cell-data in this-procedure (
              input {&rnpazsxl-sheet1_valutCode}
            , input "1":U
        ).
    end.
    run rnpazsxl-write-cell-data in this-procedure (
          input {&rnpazsxl-sheet1_columnList}
        , input "firm,region,azs_name,gds_type,gds_code,data_sell,nqty,price,sum_sell,price_type":U
    ).
    run rnpazsxl-write-cell-data in this-procedure (
          input {&rnpazsxl-sheet1_columnType}
        , input "S,S,S,S,S,S,D,D,D,S":U
    ).
    run rnpazsxl-write-cell-data in this-procedure (
          input {&rnpazsxl-columnAmount}
        , input "10":U
    ).
    run rnpazsxl-write-cell-data in this-procedure (
          input {&rnpazsxl-regularExpressions}
        , input "1":U
      ).
    run rnpazsxl-write-cell-data in this-procedure (
          input {&rnpazsxl-sheet1_subtotalList}
        , input "":U
    ).
    run rnpazsxl-write-cell-data in this-procedure (
          input {&rnpazsxl-sheet1_subtotalType}
        , input "":U
    ).

end.
end procedure. /* rnpazsxl-init */

/*==========================================================================*/
procedure rnpazsxl-sheet1-write-line-data :
define input parameter p-firm       as character no-undo.
define input parameter p-region     as character no-undo.
define input parameter p-azs_name   as character no-undo.
define input parameter p-gds_type   as character no-undo.
define input parameter p-data_sell  as date      no-undo.
define input parameter p-nqty       as decimal   no-undo.
define input parameter p-price      as decimal   no-undo.
define input parameter p-sum_sell   as decimal   no-undo.
define input parameter p-price_type as character no-undo.

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
        v-rnpazsxl-sheet1-cur-data-row       = v-rnpazsxl-sheet1-cur-data-row + 1
        buf_temp_sheet1_line-data.xl-line-id = v-rnpazsxl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.data-key   = {&rnpazsxl-line-data-key}
        buf_temp_sheet1_line-data.firm       = p-firm
        buf_temp_sheet1_line-data.region     = p-region
        buf_temp_sheet1_line-data.azs_name   = p-azs_name
        buf_temp_sheet1_line-data.gds_type   = p-gds_type
        buf_temp_sheet1_line-data.data_sell  = p-data_sell
        buf_temp_sheet1_line-data.nqty       = p-nqty
        buf_temp_sheet1_line-data.price      = p-price
        buf_temp_sheet1_line-data.sum_sell   = p-sum_sell
        buf_temp_sheet1_line-data.price_type = p-price_type
    .
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.data-key
        {&tabulation}   buf_temp_sheet1_line-data.firm
        {&tabulation}   buf_temp_sheet1_line-data.region
        {&tabulation}   buf_temp_sheet1_line-data.azs_name
        {&tabulation}   buf_temp_sheet1_line-data.gds_type
        {&tabulation}   buf_temp_sheet1_line-data.gds_code
        {&tabulation}   string( buf_temp_sheet1_line-data.data_sell, "99.99.9999" )
        {&tabulation}   string( buf_temp_sheet1_line-data.nqty )
        {&tabulation}   string( buf_temp_sheet1_line-data.price )
        {&tabulation}   string( buf_temp_sheet1_line-data.sum_sell )
        {&tabulation}   buf_temp_sheet1_line-data.price_type
        {&new-line}
    .
end.
end procedure. /* rnpazsxl-write-line-data */
/*==========================================================================*/

procedure rnpazsxl-write-cell-data :
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
end procedure. /* rnpazsxl-write-cell-data */

/*==========================================================================*/
/*procedure rnpazsxl-run-excel :*/
/*define input parameter p-header-filename    as character        no-undo.*/
/*define input parameter p-data-filename      as character        no-undo.*/

/*    define variable v-template-file-name    as character    no-undo.*/
/*    define variable v-vb-file-name          as character    no-undo.*/

/*    define buffer buf_temp-param for temp-param .*/
/*do*/
/*for buf_temp-param*/
/*on error undo, return error*/
/*:*/
/*    create buf_temp-param.*/
/*    assign*/
/*        v-template-file-name    = search( "exe/rnpazs.xlt" )*/
/*        v-vb-file-name          = search( "exe/t_form.bas")*/
/*    .*/
/*    message "v-template-file-name = " v-template-file-name skip*/
/*    view-as alert-box.*/

/*    if v-template-file-name = ?*/
/*    or v-template-file-name = "":U*/
/*    then do:*/
/*        message*/
/*            "Ошибка имени файла шаблона."*/
/*        view-as alert-box error.*/
/*    end.*/
/*    if v-vb-file-name = ?*/
/*    or v-vb-file-name = "":U*/
/*    then do:*/
/*        message*/
/*            "Ошибка имени файла кода обработки."*/
/*        view-as alert-box error.*/
/*    end.*/
/*    run paramls-write in this-procedure (*/
/*          input {&paramls-template}*/
/*        , input {&paramls-template-file-name}*/
/*        , input v-template-file-name*/
/*    ).*/
/*    run paramls-write in this-procedure (*/
/*          input {&paramls-template}*/
/*        , input {&paramls-vb-file-name}*/
/*        , input v-vb-file-name*/
/*    ).*/
/*    run paramls-write in this-procedure (*/
/*          input {&paramls-data}*/
/*        , input {&paramls-data-header-filename}*/
/*        , input p-header-filename*/
/*    ).*/
/*    run paramls-write in this-procedure (*/
/*          input {&paramls-data}*/
/*        , input {&paramls-data-filename}*/
/*        , input p-data-filename*/
/*    ).*/
/*    run gbl/macroxlt.p (*/
/*        input-output table buf_temp-param*/
/*    ) no-error.*/
/*    if error-status :error*/
/*    then do:*/
/*        message*/
/*                 vss-workfile vss-revision vss-description*/
/*            skip(1)*/
/*            skip "Ошибка создания файла Excel."*/
/*            skip return-value*/
/*            skip trim(error-status :get-message(1))*/
/*                 trim(error-status :get-message(2))*/
/*                 trim(error-status :get-message(3))*/
/*        view-as alert-box error.*/
/*        undo, return error .*/
/*    end.*/
/*end.*/
/*end procedure. /* rnpazsxl-run-excel */*/


/*==========================================================================*/
procedure rnpazsxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/rnpazs.xlt":U.
        export "exe/t_97.bas":U.
        export v-rnpazsxl-cell-file-name.
        export v-rnpazsxl-data-file-name.
    output close.
end.
end procedure. /* rnpazsxl-close */

/* $Workfile$ e n d */