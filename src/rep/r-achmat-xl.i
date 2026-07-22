/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет Акт на списание материалов ( для инвентаризации, факт )
Excel логика

Автор: Харитонов Владимир Александрович
Дата создания: 21/03/13
Author: Kharitonov Vladimir
Creation date: 21/03/13

*/

&global-define acmxl-data-label "DTA":U
&global-define acmxl-format-label "FMT":U

&global-define acmxl-sheetList  "Лист1":U
&global-define acmxl-sheet1_valutCode       "Лист1_valutCode":U
&global-define acmxl-sheet1_columnList      "Лист1_columnList":U
&global-define acmxl-sheet1_columnType      "Лист1_columnType":U
&global-define acmxl-sheet1_subtotalList    "Лист1_subtotalList":U
&global-define acmxl-sheet1_subtotalType    "Лист1_subtotalType":U

&global-define acmxl-firm_name      "h_firm_name":U
&global-define acmxl-obj_name       "h_obj_name":U
&global-define acmxl-obj_name_2     "h_obj_name_2":U
&global-define acmxl-doc_code       "h_doc_code":U
&global-define acmxl-doc_date       "h_doc_date":U
&global-define acmxl-sum_all        "h_sum_all":U
&global-define acmxl-sum_str        "h_sum_str":U
&global-define acmxl-qnty_all       "h_qnty_all":U
/*&global-define acmxl-qnty_str       "h_qnty_str":U*/
&global-define acmxl-mgr_name       "h_mgr_name":U
&global-define acmxl-performer_name "h_performer_name":U
&global-define acmxl-stock_name     "h_stock_name":U

&global-define acmxl-sheet1-name "Лист1":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.

define variable v-acmxl-sheet1-cur-data-row     as integer      no-undo.
define variable v-acmxl-sheet2-cur-data-row     as integer      no-undo.
define variable v-acmxl-cell-file-name       as character    no-undo.
define variable v-acmxl-data-file-name       as character    no-undo.

procedure acmxl-init :

    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-acmxl-data-file-name
    ).
    output stream excel-line to value( v-acmxl-data-file-name ).
    
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-acmxl-cell-file-name
    ).
    output stream excel-cell to value( v-acmxl-cell-file-name ).
    
    run acmxl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&acmxl-sheetList}
    ).
    
    run acmxl-write-cell-data in this-procedure (
          input {&acmxl-sheet1_valutCode}
        , input "0":U
    ).
    
    run acmxl-write-cell-data in this-procedure (
          input {&acmxl-sheet1_columnList}
/*        , input "pos,name,num,delivery_date,unit,norm,fact_qnty,price,sum,description":U*/
        , input "pos,name,num,delivery_date,unit,fact_qnty,price,sum,description":U
    ).
    
    run acmxl-write-cell-data in this-procedure (
          input {&acmxl-sheet1_columnType}
/*        , input "I,S,S,S,S,S,D,D,D,S":U*/
        , input "I,S,S,S,S,D,D,D,S":U
    ).
    
    run acmxl-write-cell-data in this-procedure (
          input {&acmxl-sheet1_subtotalList}
        , input "":U
    ).
    
    run acmxl-write-cell-data in this-procedure (
          input {&acmxl-sheet1_subtotalType}
        , input "":U
    ).

end procedure. /* acmxl-init */

procedure acmxl-sheet1-write-line-data :
    define input parameter p-pos        as integer   no-undo.
    define input parameter p-name       as character no-undo.
    define input parameter p-num        as character no-undo.
    define input parameter p-dv-date    as date      no-undo.
    define input parameter p-unit       as character no-undo.
/*    define input parameter p-norm       as character no-undo.*/
    define input parameter p-fact-qnty  as decimal   no-undo.
    define input parameter p-price      as decimal   no-undo.
    define input parameter p-sum        as decimal   no-undo.
    define input parameter p-desciption as character no-undo.
    
    put stream excel-line UNFORMATTED
        {&acmxl-sheet1-name} 
        {&tabulation} {&acmxl-data-label}
        {&tabulation} p-pos
        {&tabulation} p-name
        {&tabulation} p-num
        {&tabulation} p-dv-date
        {&tabulation} p-unit
/*        {&tabulation} p-norm*/
        {&tabulation} p-fact-qnty
        {&tabulation} p-price
        {&tabulation} p-sum
        {&tabulation} p-desciption
        {&new-line}
    .
    
end procedure. /* acmxl-write-line-data */

procedure acmxl-write-cell-data :
    define input parameter p-key as character no-undo.
    define input parameter p-val as character no-undo.

    find first temp_cell-data
        where temp_cell-data.data-key = p-key
        no-lock no-error.
    
    if avail temp_cell-data then
        temp_cell-data.data-value = p-val.
    else do:
        create temp_cell-data.
        assign
            temp_cell-data.data-key = p-key
            temp_cell-data.data-value = p-val
        .
    end.
    
    put stream excel-cell UNFORMATTED
        p-key {&tabulation} p-val {&new-line}
    .
    
end procedure. /* acmxl-write-cell-data */

procedure acmxl-close : 

    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.

    export "exe/achmat.xlt":U.
    export "exe/t_form.bas":U.
    export v-acmxl-cell-file-name.
    export v-acmxl-data-file-name.
    
    output close.
    
end procedure. /* acmxl-close */
