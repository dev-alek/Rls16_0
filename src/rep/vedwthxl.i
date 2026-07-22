/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



ΐβςξπ: Αελξσρξβ Θλόÿ ΐλεκρΰνδπξβθχ
Δΰςΰ ρξηδΰνθÿ: 04/03/08
Author: Ilia Belousov
Creation date: 04/03/08

Required:

*/

DEFINE TEMP-TABLE tt-line NO-UNDO
      FIELD curr-name   as character
      FIELD curr-code   as integer
      FIELD okv-code    as integer
      field par-val     as integer
      field par-rate    as decimal
      field par-unit    as character
      FIELD par-code    as integer
      field summ        as integer
      FIELD wth-code    as integer

      INDEX pi IS PRIMARY UNIQUE
            curr-code
            wth-code
            par-code
.

DEFINE TEMP-TABLE tt-summ NO-UNDO
      FIELD curr-code   as integer
      FIELD okv-code   as integer
      field curr-summ   as decimal
      field curr-abbr   as character
      field part-abbr   as character
      INDEX pi IS PRIMARY UNIQUE
            curr-code
.

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


&global-define vedwthxl-data-label "DTA":U

&global-define vedwthxl-sheet1  "ύκη1":U
&global-define vedwthxl-sheet2  "ύκη2":U
&global-define vedwthxl-sheet3  "ύκη3":U

&global-define vedwthxl-sheetList  "ύκη1,ύκη2,ύκη3":U


&global-define vedwthxl-sheet1_valutCode       "ύκη1_valutCode":U
&global-define vedwthxl-sheet1_columnList      "ύκη1_columnList":U
&global-define vedwthxl-sheet1_columnType      "ύκη1_columnType":U
&global-define vedwthxl-sheet1_subtotalList    "ύκη1_subtotalList":U
&global-define vedwthxl-sheet1_subtotalType    "ύκη1_subtotalType":U

&global-define vedwthxl-sheet2_valutCode       "ύκη2_valutCode":U
&global-define vedwthxl-sheet2_columnList      "ύκη2_columnList":U
&global-define vedwthxl-sheet2_columnType      "ύκη2_columnType":U
&global-define vedwthxl-sheet2_subtotalList    "ύκη2_subtotalList":U
&global-define vedwthxl-sheet2_subtotalType    "ύκη2_subtotalType":U

&global-define vedwthxl-sheet3_valutCode       "ύκη3_valutCode":U
&global-define vedwthxl-sheet3_columnList      "ύκη3_columnList":U
&global-define vedwthxl-sheet3_columnType      "ύκη3_columnType":U
&global-define vedwthxl-sheet3_subtotalList    "ύκη3_subtotalList":U
&global-define vedwthxl-sheet3_subtotalType    "ύκη3_subtotalType":U

&global-define vedwthxl-sheet1-name            "ύκη1":U
&global-define vedwthxl-sheet1-date1           "ύκη1_date1":U
&global-define vedwthxl-sheet1-date2           "ύκη1_date2":U
&global-define vedwthxl-sheet1-from            "ύκη1_from":U
&global-define vedwthxl-sheet1-to              "ύκη1_to":U
&global-define vedwthxl-sheet1-bank-to         "ύκη1_bank_to":U
&global-define vedwthxl-sheet1-summ_1          "ύκη1_summ_1":U
&global-define vedwthxl-sheet1-summ_2          "ύκη1_summ_2":U
&global-define vedwthxl-sheet1-summ_3          "ύκη1_summ_3":U
&global-define vedwthxl-sheet1-summ_4          "ύκη1_summ_4":U
&global-define vedwthxl-sheet1-summ_5          "ύκη1_summ_5":U
&global-define vedwthxl-sheet1-summ_6          "ύκη1_summ_6":U
&global-define vedwthxl-sheet1-symb_5          "ύκη1_symb_5":U
&global-define vedwthxl-sheet1-symb_6          "ύκη1_symb_6":U
&global-define vedwthxl-sheet1-account_to      "ύκη1_account_to":U
&global-define vedwthxl-sheet1-account_dbt     "ύκη1_account_dbt":U
&global-define vedwthxl-sheet1-account_krd     "ύκη1_account_krd":U

&global-define vedwthxl-sheet2-name            "ύκη2":U
&global-define vedwthxl-sheet2-date1           "ύκη2_date1":U
&global-define vedwthxl-sheet2-date2           "ύκη2_date2":U
&global-define vedwthxl-sheet2-from            "ύκη2_from":U
&global-define vedwthxl-sheet2-to              "ύκη2_to":U
&global-define vedwthxl-sheet2-bank-to         "ύκη2_bank_to":U
&global-define vedwthxl-sheet2-summ_1          "ύκη2_summ_1":U
&global-define vedwthxl-sheet2-summ_2          "ύκη2_summ_2":U
&global-define vedwthxl-sheet2-summ_3          "ύκη2_summ_3":U
&global-define vedwthxl-sheet2-summ_4          "ύκη2_summ_4":U
&global-define vedwthxl-sheet2-summ_5          "ύκη2_summ_5":U
&global-define vedwthxl-sheet2-summ_6          "ύκη2_summ_6":U
&global-define vedwthxl-sheet2-symb_5          "ύκη2_symb_5":U
&global-define vedwthxl-sheet2-symb_6          "ύκη2_symb_6":U
&global-define vedwthxl-sheet2-account_to      "ύκη2_account_to":U
&global-define vedwthxl-sheet2-account_dbt     "ύκη2_account_dbt":U
&global-define vedwthxl-sheet2-account_krd     "ύκη2_account_krd":U

&global-define vedwthxl-sheet3-name            "ύκη3":U
&global-define vedwthxl-sheet3-date1           "ύκη3_date1":U
&global-define vedwthxl-sheet3-from            "ύκη3_from":U
&global-define vedwthxl-sheet3-to              "ύκη3_to":U
&global-define vedwthxl-sheet3-bank-to         "ύκη3_bank_to":U
&global-define vedwthxl-sheet3-summ_1          "ύκη3_summ_1":U
&global-define vedwthxl-sheet3-summ_2          "ύκη3_summ_2":U
&global-define vedwthxl-sheet3-summ_3          "ύκη3_summ_3":U
&global-define vedwthxl-sheet3-summ_4          "ύκη3_summ_4":U
&global-define vedwthxl-sheet3-summ_5          "ύκη3_summ_5":U
&global-define vedwthxl-sheet3-summ_6          "ύκη3_summ_6":U
&global-define vedwthxl-sheet3-symb_5          "ύκη3_symb_5":U
&global-define vedwthxl-sheet3-symb_6          "ύκη3_symb_6":U
&global-define vedwthxl-sheet3-account_to      "ύκη3_account_to":U
&global-define vedwthxl-sheet3-account_dbt     "ύκη3_account_dbt":U
&global-define vedwthxl-sheet3-account_krd     "ύκη3_account_krd":U

/*
&global-define vedwthxl-sheet2-dateString      "ύκη2_dateString":U
&global-define vedwthxl-sheet3-dateToString    "ύκη3_dateToString":U
*/

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.



define variable v-vedwthxl-sheet1-cur-data-row     as integer      no-undo.
define variable v-vedwthxl-sheet2-cur-data-row     as integer      no-undo.
define variable v-vedwthxl-sheet3-cur-data-row     as integer      no-undo.

define variable v-vedwthxl-cell-file-name       as character    no-undo.
define variable v-vedwthxl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure vedwthxl-init :

do
on error undo, return error
:
    assign
        v-vedwthxl-sheet1-cur-data-row = 0
        v-vedwthxl-sheet2-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-vedwthxl-data-file-name
    ).
    output stream excel-line to value( v-vedwthxl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-vedwthxl-cell-file-name
    ).
    output stream excel-cell to value( v-vedwthxl-cell-file-name ).
    run vedwthxl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&vedwthxl-sheetList}
    ).
    if printrubl
    then do:
        run vedwthxl-write-cell-data in this-procedure (
              input {&vedwthxl-sheet1_valutCode}
            , input "0":U
        ).
        run vedwthxl-write-cell-data in this-procedure (
              input {&vedwthxl-sheet2_valutCode}
            , input "0":U
        ).
        run vedwthxl-write-cell-data in this-procedure (
              input {&vedwthxl-sheet3_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run vedwthxl-write-cell-data in this-procedure (
              input {&vedwthxl-sheet1_valutCode}
            , input "1":U
        ).
        run vedwthxl-write-cell-data in this-procedure (
              input {&vedwthxl-sheet2_valutCode}
            , input "1":U
        ).
        run vedwthxl-write-cell-data in this-procedure (
              input {&vedwthxl-sheet3_valutCode}
            , input "1":U
        ).
    end.


    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet1_columnList}
        , input "curr_name,curr_code,fact_qnty,par_val,fact_sum":U
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet1_columnType}
        , input "S,S,S,S,S":U
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet1_subtotalList}
        , input "":U
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet1_subtotalType}
        , input "":U
    ).

    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet2_columnList}
        , input "curr_name,curr_code,fact_qnty,par_val,fact_sum":U
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet2_columnType}
        , input "S,S,S,S,S":U
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet2_subtotalList}
        , input "":U
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet2_subtotalType}
        , input "":U
    ).

    /*
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet3_columnList}
        , input "goodsName,wthPar,incIncmSt,incIncmLt,incRetnSt,incRetnLt,outSaleSt,outSaleLt,outSaleRb,outExchSt,outExchLt,outExchRb,payPaydDeskSt,payPaydDeskLt,payPaydDeskRb,payPaydSt,payPaydLt,payPaydRb,payExchSt,payExchLt,payExchRb,payRetnSt,payRetnLt,payRetnRb,clrRealSt,clrRealLt,clrRealRb,clrPOffSt,clrPOffLt,clrPOffRb,trsRealExpsSt,trsRealExpsLt,trsRealIncmSt,trsRealIncmLt,trsRealTrnsSt,trsRealTrnsLt,trsPOffExpsSt,trsPOffExpsLt,trsPOffExpsRb,trsPOffIncmSt,trsPOffIncmLt,trsPOffIncmRb,trsPOffTrnsSt,trsPOffTrnsLt,trsPOffTrnsRb":U
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet3_columnType}
        , input "S,S,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D":U
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet3_subtotalList}
        , input "":U
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet3_subtotalType}
        , input "":U
    ).
    */
end.
end procedure. /* vedwthxl-init */


/*==========================================================================*/
procedure vedwthxl-sheet1-write-line-data :

define buffer buf_tt-line     for tt-line .

do
on error undo, return error
:
    for each buf_tt-line
    :
        put stream excel-line unformatted
                            {&vedwthxl-sheet1}
            {&tabulation}   {&vedwthxl-data-label}
            {&tabulation}   buf_tt-line.curr-name
            {&tabulation}   buf_tt-line.okv-code
            {&tabulation}   (buf_tt-line.summ / buf_tt-line.par-rate)
            {&tabulation}   SUBSTITUTE ("&1 &2", buf_tt-line.par-val, buf_tt-line.par-unit)
            {&tabulation}   buf_tt-line.summ
            {&new-line}
        .
    end.
end.
end procedure. /* vedwthxl-sheet1-write-line-data */


/*==========================================================================*/
procedure vedwthxl-sheet3-write-line-data :

do
on error undo, return error
:

end.
end procedure. /* vedwthxl-sheet3-write-line-data */


/*==========================================================================*/
procedure vedwthxl-sheet2-write-line-data :

define buffer buf_tt-line     for tt-line .

do
on error undo, return error
:
    for each buf_tt-line
    :
        put stream excel-line unformatted
                            {&vedwthxl-sheet2}
            {&tabulation}   {&vedwthxl-data-label}
            {&tabulation}   buf_tt-line.curr-name
            {&tabulation}   buf_tt-line.okv-code
            {&tabulation}   (buf_tt-line.summ / buf_tt-line.par-rate)
            {&tabulation}   SUBSTITUTE ("&1 &2", buf_tt-line.par-val, buf_tt-line.par-unit)
            {&tabulation}   buf_tt-line.summ
            {&new-line}
        .
    end.
end.
end procedure. /* vedwthxl-sheet2-write-line-data */


/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure vedwthxl-write-cell-data :
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
end procedure. /* vedwthxl-write-cell-data */

/*==========================================================================*/
procedure vedwthxl-run-excel :
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
        v-template-file-name    = search( "exe/vedprepr.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas")
    .
/*    assign*/
/*        v-template-file-name = search( v-template-file-name )*/
/*    .*/
    if v-template-file-name = ?
    or v-template-file-name = "":U
    then do:
        message
            "Ξψθακΰ θμενθ τΰιλΰ ψΰαλξνΰ."
        view-as alert-box error.
    end.
    if v-vb-file-name = ?
    or v-vb-file-name = "":U
    then do:
        message
            "Ξψθακΰ θμενθ τΰιλΰ κξδΰ ξαπΰαξςκθ."
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
            skip "Ξψθακΰ ρξηδΰνθÿ τΰιλΰ Excel."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
end.
end procedure. /* vedwthxl-run-excel */


/*==========================================================================*/
procedure vedwthxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/vedprepr.xlt":U.
        export "exe/t_form.bas":U.
        export v-vedwthxl-cell-file-name.
        export v-vedwthxl-data-file-name.
    output close.
end.
end procedure. /* vedwthxl-close */


/* $Workfile$ e n d */