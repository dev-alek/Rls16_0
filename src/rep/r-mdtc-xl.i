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

&global-define mdtcxl-data-label "DTA":U
&global-define mdtcxl-format-label "FMT":U

&global-define mdtcxl-sheetList  "Sheet1":U
&global-define mdtcxl-sheet1_valutCode       "Sheet1_valutCode":U
&global-define mdtcxl-sheet1_columnList      "Sheet1_columnList":U
&global-define mdtcxl-sheet1_columnType      "Sheet1_columnType":U
&global-define mdtcxl-sheet1_subtotalList    "Sheet1_subtotalList":U
&global-define mdtcxl-sheet1_subtotalType    "Sheet1_subtotalType":U

&global-define mdtcxl-obj_num_1          "obj_num_1":U
&global-define mdtcxl-obj_num_2          "obj_num_2":U
&global-define mdtcxl-obj_num_3          "obj_num_3":U
&global-define mdtcxl-date_interval      "date_interval":U
&global-define mdtcxl-start_date_header  "start_date_header":U
&global-define mdtcxl-end_date_header    "end_date_header":U
&global-define mdtcxl-sum_start_qnty     "sum_start_qnty":U
&global-define mdtcxl-sum_end_qnty       "sum_end_qnty":U
&global-define mdtcxl-sum_all_rcv_qnty   "sum_all_rcv_qnty":U
&global-define mdtcxl-sum_all_spent_qnty "sum_all_spent_qnty":U

&global-define mdtcxl-Sheet1_it_start_qnty      "Sheet1_it_start_qnty":U
&global-define mdtcxl-Sheet1_it_all_rcv_qnty    "Sheet1_it_all_rcv_qnty":U
&global-define mdtcxl-Sheet1_it_all_spent_qnty  "Sheet1_it_all_spent_qnty":U
&global-define mdtcxl-Sheet1_it_end_qnty        "Sheet1_it_end_qnty":U

&global-define mdtcxl-sheet1-name "Sheet1":U

define stream excel-line.
define stream excel-cell.

define variable v-mdtcxl-sheet1-cur-data-row     as integer      no-undo.
define variable v-mdtcxl-sheet2-cur-data-row     as integer      no-undo.
define variable v-mdtcxl-cell-file-name       as character    no-undo.
define variable v-mdtcxl-data-file-name       as character    no-undo.

procedure mdtcxl-init :

    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-mdtcxl-data-file-name
    ).
    output stream excel-line to value( v-mdtcxl-data-file-name ).
    
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-mdtcxl-cell-file-name
    ).
    output stream excel-cell to value( v-mdtcxl-cell-file-name ).
    
    run mdtcxl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&mdtcxl-sheetList}
    ).
    
    run mdtcxl-write-cell-data in this-procedure (
          input {&mdtcxl-sheet1_valutCode}
        , input "0":U
    ).
    
    run mdtcxl-write-cell-data in this-procedure (
          input {&mdtcxl-sheet1_columnList}
        , input "gds_name,start_qnty,all_rcv_qnty,all_spent_qnty,end_qnty":U
    ).
    
    run mdtcxl-write-cell-data in this-procedure (
          input {&mdtcxl-sheet1_columnType}
        , input "S,D,D,D,D":U
    ).
    
    run mdtcxl-write-cell-data in this-procedure (
          input {&mdtcxl-sheet1_subtotalList}
        , input "":U
    ).
    
    run mdtcxl-write-cell-data in this-procedure (
          input {&mdtcxl-sheet1_subtotalType}
        , input "":U
    ).

end procedure. /* mdtcxl-init */

procedure mdtcxl-sheet1-write-line-data :
    define input parameter p-gds-name       as character    no-undo.
    define input parameter p-unit-base      as character    no-undo.
    define input parameter p-start-qnty     as decimal      no-undo.
    define input parameter p-all-rcv-qnty   as decimal      no-undo.
    define input parameter p-all-spent-qnty as decimal      no-undo.
    define input parameter p-end-qnty       as decimal      no-undo.
    
    put stream excel-line UNFORMATTED
        {&mdtcxl-sheet1-name} 
        {&tabulation} {&mdtcxl-data-label}
        {&tabulation} subst("&1, &2", p-gds-name, p-unit-base)
        {&tabulation} p-start-qnty
        {&tabulation} p-all-rcv-qnty
        {&tabulation} p-all-spent-qnty
        {&tabulation} p-end-qnty
        {&new-line}
    .
    
end procedure. /* mdtcxl-write-line-data */

procedure mdtcxl-write-cell-data :
    define input parameter p-key as character no-undo.
    define input parameter p-val as character no-undo.
    
    put stream excel-cell UNFORMATTED
        p-key {&tabulation} p-val {&new-line}
    .
    
end procedure. /* mdtcxl-write-cell-data */

procedure mdtcxl-close : 
    output to value( string( session:temp-directory + {&DF_Name} + string( g#report-num ) ) + ".txl" ) append.
    
    export "exe/mdtc.xlt":U.
    export "exe/t_form.bas":U.
    export v-mdtcxl-cell-file-name.
    export v-mdtcxl-data-file-name.
    
    output stream excel-line close.
    output stream excel-cell close.
    
end procedure. /* mdtcxl-close */
