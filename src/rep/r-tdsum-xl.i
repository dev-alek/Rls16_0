/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Движение одноразовой посуды по кафе (Роснефть)
Excel логика

Автор: Харитонов Владимир Александрович
Дата создания: 21/03/13
Author: Kharitonov Vladimir
Creation date: 21/03/13

*/

&global-define tdsxl-data-label "DTA":U
&global-define tdsxl-format-label "FMT":U

&global-define tdsxl-sheetList  "Сводка":U
&global-define tdsxl-sheet1_valutCode       "Сводка_valutCode":U
&global-define tdsxl-sheet1_columnList      "Сводка_columnList":U
&global-define tdsxl-sheet1_columnType      "Сводка_columnType":U
&global-define tdsxl-sheet1_subtotalList    "Сводка_subtotalList":U
&global-define tdsxl-sheet1_subtotalType    "Сводка_subtotalType":U

&global-define tdsxl-org_name          "org_name":U
&global-define tdsxl-date_day          "date_day":U
&global-define tdsxl-date_month        "date_month":U
&global-define tdsxl-date_year         "date_year":U

&global-define tdsxl-Sheet1_shop_num            "Сводка_it_shop_num":U
&global-define tdsxl-Sheet1_gds-name            "Сводка_it_gds-name":U
&global-define tdsxl-Sheet1_impl-day            "Сводка_it_impl-day":U
&global-define tdsxl-Sheet1_impl-month          "Сводка_it_impl-month":U
&global-define tdsxl-Sheet1_price_impl-now      "Сводка_it_price_impl-now":U
&global-define tdsxl-Sheet1_price_impl-change   "Сводка_it_price_impl-change":U
&global-define tdsxl-Sheet1_f1                  "Сводка_it_f1":U
&global-define tdsxl-Sheet1_f2                  "Сводка_it_f2":U
&global-define tdsxl-Sheet1_f3                  "Сводка_it_f3":U
&global-define tdsxl-Sheet1_f4                  "Сводка_it_f4":U
&global-define tdsxl-Sheet1_f5                  "Сводка_it_f5":U
&global-define tdsxl-Sheet1_proc_day            "Сводка_it_proc_day":U
&global-define tdsxl-Sheet1_proc_month          "Сводка_it_proc_day":U

&global-define tdsxl-sheet1-name "Сводка":U

define stream excel-line.
define stream excel-cell.

define variable v-tdsxl-sheet1-cur-data-row     as integer      no-undo.
define variable v-tdsxl-sheet2-cur-data-row     as integer      no-undo.
define variable v-tdsxl-cell-file-name       as character    no-undo.
define variable v-tdsxl-data-file-name       as character    no-undo.

procedure tdsxl-init :

    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-tdsxl-data-file-name
    ).
    output stream excel-line to value( v-tdsxl-data-file-name ).
    
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-tdsxl-cell-file-name
    ).
    output stream excel-cell to value( v-tdsxl-cell-file-name ).
    
    run tdsxl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&tdsxl-sheetList}
    ).
    
    run tdsxl-write-cell-data in this-procedure (
          input {&tdsxl-sheet1_valutCode}
        , input "0":U
    ).
    
    run tdsxl-write-cell-data in this-procedure (
          input {&tdsxl-sheet1_columnList}
        , input "shop_num,gds_name,impl_day,impl_month,price_impl_now,price_impl_change,f1,f2,f3,f4,f5,proc_day,proc_month":U
    ).
    
    run tdsxl-write-cell-data in this-procedure (
          input {&tdsxl-sheet1_columnType}
        , input "I,S,D,D,D,D,D,D,D,D,D,D,D":U
    ).
    
    run tdsxl-write-cell-data in this-procedure (
          input {&tdsxl-sheet1_subtotalList}
        , input "":U
    ).
    
    run tdsxl-write-cell-data in this-procedure (
          input {&tdsxl-sheet1_subtotalType}
        , input "":U
    ).

end procedure. /* tdsxl-init */

procedure tdsxl-sheet1-write-line-data :
    define input parameter p-shop-num as character no-undo.
    define input parameter p-gds-name as character no-undo.
    define input parameter p-impl-day as decimal no-undo.
    define input parameter p-impl-month as decimal no-undo.
    define input parameter p-price-impl-now as decimal no-undo.
    define input parameter p-price-impl-change as decimal no-undo.
    define input parameter p-proc-day as character no-undo.
    define input parameter p-proc-month as character no-undo.
    
    put stream excel-line UNFORMATTED
        {&tdsxl-sheet1-name} 
        {&tabulation} {&tdsxl-data-label}
        {&tabulation} p-shop-num
        {&tabulation} p-gds-name
        {&tabulation} p-impl-day
        {&tabulation} p-impl-month
        {&tabulation} p-price-impl-now
        {&tabulation} p-price-impl-change
        {&tabulation} 0
        {&tabulation} 0
        {&tabulation} 0
        {&tabulation} 0
        {&tabulation} 0
        {&tabulation} p-proc-day
        {&tabulation} p-proc-month
        {&new-line}
    .
    
end procedure. /* tdsxl-write-line-data */

procedure tdsxl-write-cell-data :
    define input parameter p-key as character no-undo.
    define input parameter p-val as character no-undo.
    
    put stream excel-cell UNFORMATTED
        p-key {&tabulation} p-val {&new-line}
    .
    
end procedure. /* tdsxl-write-cell-data */

procedure tdsxl-close : 
    output to value( string( session:temp-directory + {&DF_Name} + string( g#report-num ) ) + ".txl" ) append.
    
    export "exe/tdsum.xlt":U.
    export "exe/t_form.bas":U.
    export v-tdsxl-cell-file-name.
    export v-tdsxl-data-file-name.
    
    output stream excel-line close.
    output stream excel-cell close.
    
end procedure. /* tdsxl-close */
