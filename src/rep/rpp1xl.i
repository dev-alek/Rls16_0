/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры для печати расходного платёжного поручения в Excel.

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Required:

{ gbl/paramls.i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define rpp1xl-line-data-key "LD":U
&global-define rpp1xl-valutCode "valutCode":U
&global-define rpp1xl-columnList "columnList":U
&global-define rpp1xl-columnType "columnType":U
&global-define rpp1xl-columnAmount "columnAmount":U
&global-define rpp1xl-subtotalList "subtotalList":U
&global-define rpp1xl-subtotalType "subtotalType":U
&global-define rpp1xl-subtotalAmount "subtotalAmount":U
&global-define rpp1xl-subtotalPropisList "subtotalPropisList":U
&global-define rpp1xl-subtotalPropisAmount "subtotalPropisAmount":U

&global-define rpp1xl-h_payDate "h_payDate":U
&global-define rpp1xl-h_factDate "h_factDate":U
&global-define rpp1xl-h_docDate "h_docDate":U
&global-define rpp1xl-vidPlat "vidPlat":U
&global-define rpp1xl-prnDocCode "prnDocCode":U
&global-define rpp1xl-statPl "statPl":U
&global-define rpp1xl-sumDoc "sumDoc":U
&global-define rpp1xl-payerInn "payerInn":U
&global-define rpp1xl-payerKpp "payerKpp":U
&global-define rpp1xl-sumDocPropis "sumDocPropis":U
&global-define rpp1xl-sumDoc "sumDoc":U
&global-define rpp1xl-payerName "payerName":U
&global-define rpp1xl-payerRSchet "payerRSchet":U
&global-define rpp1xl-payerBankName "payerBankName":U
&global-define rpp1xl-payerBik "payerBik":U
&global-define rpp1xl-payerCSchet "payerCSchet":U
&global-define rpp1xl-receiverBankName "receiverBankName":U
&global-define rpp1xl-receiverBik "receiverBik":U
&global-define rpp1xl-receiverCSchet "receiverCSchet":U
&global-define rpp1xl-receiverRSchet "receiverRSchet":U
&global-define rpp1xl-receiverInn "receiverInn":U
&global-define rpp1xl-receiverKpp "receiverKpp":U
&global-define rpp1xl-receiverName "receiverName":U
&global-define rpp1xl-vidOpl "vidOpl":U
&global-define rpp1xl-srokPl "srokPl":U
&global-define rpp1xl-naznPlat "naznPlat":U
&global-define rpp1xl-ocherPl "ocherPl":U
&global-define rpp1xl-kodPoluchat "kodPoluchat":U
&global-define rpp1xl-rezPole "rezPole":U
&global-define rpp1xl-h_f104 "h_f104":U
&global-define rpp1xl-h_f105 "h_f105":U
&global-define rpp1xl-h_f106 "h_f106":U
&global-define rpp1xl-h_f107 "h_f107":U
&global-define rpp1xl-h_f108 "h_f108":U
&global-define rpp1xl-h_f109 "h_f109":U
&global-define rpp1xl-h_f110 "h_f110":U
&global-define rpp1xl-naznachPl "naznachPl":U
&global-define rpp1xl-payerSign1 "payerSign1":U
&global-define rpp1xl-payerSign2 "payerSign2":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.

define variable v-rpp1xl-current-data-row     as integer      no-undo.
define variable v-rpp1xl-cell-file-name       as character    no-undo.
/*define variable v-rpp1xl-data-file-name       as character    no-undo.*/

/*==========================================================================*/
procedure rpp1xl-init :

    define buffer buf_temp_cell-data        for temp_cell-data.
    define buffer buf_usr-flt               for ubflt.usr-flt.
do
for buf_temp_cell-data
  , buf_usr-flt
on error undo, return error
:
    assign
        v-rpp1xl-current-data-row = 0
    .
/*    run gbl/_tmpfile.p (*/
/*          input "xd"*/
/*        , input ".txt"*/
/*        , output v-rpp1xl-data-file-name*/
/*    ).*/
/*    output stream excel-line to value( v-rpp1xl-data-file-name ).*/
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-rpp1xl-cell-file-name
    ).
    output stream excel-cell to value( v-rpp1xl-cell-file-name ).
    if printrubl = yes
    then do:
        run rpp1xl-write-cell-data in this-procedure (
              input {&rpp1xl-valutCode}
            , input "0":U
        ).
    end.
    else do:
        run rpp1xl-write-cell-data in this-procedure (
              input {&rpp1xl-valutCode}
            , input "1":U
        ).
    end.
    run rpp1xl-write-cell-data in this-procedure (
          input {&rpp1xl-columnList}
        , input "":U
    ).
    run rpp1xl-write-cell-data in this-procedure (
          input {&rpp1xl-columnType}
        , input "":U
    ).
    run rpp1xl-write-cell-data in this-procedure (
          input {&rpp1xl-columnAmount}
        , input "0":U
    ).
    run rpp1xl-write-cell-data in this-procedure (
          input {&rpp1xl-subtotalList}
        , input "":U
    ).
    run rpp1xl-write-cell-data in this-procedure (
          input {&rpp1xl-subtotalType}
        , input "":U
    ).
    run rpp1xl-write-cell-data in this-procedure (
          input {&rpp1xl-subtotalAmount}
        , input "0":U
    ).
    run rpp1xl-write-cell-data in this-procedure (
        input {&rpp1xl-subtotalPropisList}
        , input "":U
    ).
    run rpp1xl-write-cell-data in this-procedure (
        input {&rpp1xl-subtotalPropisAmount}
        , input "0":U
    ).
end.
end procedure. /* rpp1xl-init */

/*==========================================================================*/
procedure rpp1xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/pp.xlt":U.
        export "exe/t_97.bas":U.
        export v-rpp1xl-cell-file-name.
        export "":U.
    output close.
end.
end procedure. /* rpp1xl-close */


/*==========================================================================*/
procedure rpp1xl-write-cell-data :
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
end procedure. /* rpp1xl-write-cell-data */
