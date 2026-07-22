/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры для вывода формы расходного кассового ордера в Excel

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
&global-define rko2xl-line-data-key "LD":U
&global-define rko2xl-valutCode "valutCode":U
&global-define rko2xl-columnList "columnList":U
&global-define rko2xl-columnType "columnType":U
&global-define rko2xl-columnAmount "columnAmount":U
&global-define rko2xl-subtotalList "subtotalList":U
&global-define rko2xl-subtotalType "subtotalType":U
&global-define rko2xl-subtotalAmount "subtotalAmount":U
&global-define rko2xl-subtotalPropisList "subtotalPropisList":U
&global-define rko2xl-subtotalPropisAmount "subtotalPropisAmount":U

&global-define rko2xl-h_organization "h_organization":U
&global-define rko2xl-h_object "h_object":U
&global-define rko2xl-h_objectCode "h_objectCode":U
&global-define rko2xl-h_docCode "h_docCode":U
&global-define rko2xl-h_docDate "h_docDate":U
&global-define rko2xl-h_okpo "h_okpo":U
&global-define rko2xl-h_anUchetValue "h_anUchetValue":U
&global-define rko2xl-h_celNaznValue "h_celNaznValue":U
&global-define rko2xl-h_corAcc1Value "h_corAcc1Value":U
&global-define rko2xl-h_corAccValue "h_corAccValue":U
&global-define rko2xl-h_strPodrCode "h_strPodrCode":U
&global-define rko2xl-h_sumDoc "h_sumDoc":U

&global-define rko2xl-f_bossName "f_bossName":U
&global-define rko2xl-f_bossPos "f_bossPos":U
&global-define rko2xl-f_dateGet "f_dateGet":U
&global-define rko2xl-f_genAcc "f_genAcc":U
&global-define rko2xl-f_kassMan "f_kassMan":U
&global-define rko2xl-f_passport1 "f_passport1":U
&global-define rko2xl-f_passport2 "f_passport2":U
&global-define rko2xl-f_pril1 "f_pril1":U
&global-define rko2xl-f_pril2 "f_pril2":U
&global-define rko2xl-f_reason "f_reason":U
&global-define rko2xl-f_receiverName "f_receiverName":U
&global-define rko2xl-f_sumPropis1 "f_sumPropis1":U
&global-define rko2xl-f_sumPropis2 "f_sumPropis2":U


define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.

define variable v-rko2xl-current-data-row     as integer      no-undo.
define variable v-rko2xl-cell-file-name       as character    no-undo.
/*define variable v-rko2xl-data-file-name       as character    no-undo.*/

/*==========================================================================*/
procedure rko2xl-init :

    define buffer buf_temp_cell-data        for temp_cell-data.
    define buffer buf_usr-flt               for ubflt.usr-flt.
do
for buf_temp_cell-data
  , buf_usr-flt
on error undo, return error
:
    assign
        v-rko2xl-current-data-row = 0
    .
/*    run gbl/_tmpfile.p (*/
/*          input "xd"*/
/*        , input ".txt"*/
/*        , output v-rko2xl-data-file-name*/
/*    ).*/
/*    output stream excel-line to value( v-rko2xl-data-file-name ).*/
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-rko2xl-cell-file-name
    ).
    output stream excel-cell to value( v-rko2xl-cell-file-name ).
    if printrubl = yes
    then do:
        run rko2xl-write-cell-data in this-procedure (
              input {&rko2xl-valutCode}
            , input "0":U
        ).
    end.
    else do:
        run rko2xl-write-cell-data in this-procedure (
              input {&rko2xl-valutCode}
            , input "1":U
        ).
    end.
    run rko2xl-write-cell-data in this-procedure (
          input {&rko2xl-columnList}
        , input "":U
    ).
    run rko2xl-write-cell-data in this-procedure (
          input {&rko2xl-columnType}
        , input "":U
    ).
    run rko2xl-write-cell-data in this-procedure (
          input {&rko2xl-columnAmount}
        , input "0":U
    ).
    run rko2xl-write-cell-data in this-procedure (
          input {&rko2xl-subtotalList}
        , input "":U
    ).
    run rko2xl-write-cell-data in this-procedure (
          input {&rko2xl-subtotalType}
        , input "":U
    ).
    run rko2xl-write-cell-data in this-procedure (
          input {&rko2xl-subtotalAmount}
        , input "0":U
    ).
    run rko2xl-write-cell-data in this-procedure (
        input {&rko2xl-subtotalPropisList}
        , input "":U
    ).
    run rko2xl-write-cell-data in this-procedure (
        input {&rko2xl-subtotalPropisAmount}
        , input "0":U
    ).
end.
end procedure. /* rko2xl-init */

/*==========================================================================*/
procedure rko2xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/ko_out.xlt":U.
        export "exe/t_97.bas":U.
        export v-rko2xl-cell-file-name.
        export "":U.
    output close.
end.
end procedure. /* rko2xl-close */


/*==========================================================================*/
procedure rko2xl-write-cell-data :
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
end procedure. /* rko2xl-write-cell-data */

/* $Workfile$ e n d */