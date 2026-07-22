/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры для вывода формы приходного кассового ордера в Excel

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

&global-define pko1xl-line-data-key "LD":U
&global-define pko1xl-valutCode "valutCode":U
&global-define pko1xl-columnList "columnList":U
&global-define pko1xl-columnType "columnType":U
&global-define pko1xl-columnAmount "columnAmount":U
&global-define pko1xl-subtotalList "subtotalList":U
&global-define pko1xl-subtotalType "subtotalType":U
&global-define pko1xl-subtotalAmount "subtotalAmount":U
&global-define pko1xl-subtotalPropisList "subtotalPropisList":U
&global-define pko1xl-subtotalPropisAmount "subtotalPropisAmount":U

&global-define pko1xl-h_organization "h_organization":U
&global-define pko1xl-h_kvitOrganization "h_kvitOrganization":U
&global-define pko1xl-h_okpo "h_okpo":U
&global-define pko1xl-h_kvitDocCode "h_kvitDocCode":U
&global-define pko1xl-h_kvitDocDateDay "h_kvitDocDateDay":U
&global-define pko1xl-h_kvitDocDateMonth "h_kvitDocDateMonth":U
&global-define pko1xl-h_kvitDocDateYear "h_kvitDocDateYear":U
&global-define pko1xl-h_strPodr "h_strPodr":U
&global-define pko1xl-h_kvitPayerName1 "h_kvitPayerName1":U
&global-define pko1xl-h_kvitPayerName2 "h_kvitPayerName2":U
&global-define pko1xl-h_kvitNaznachPlat1 "h_kvitNaznachPlat1":U
&global-define pko1xl-h_kvitNaznachPlat2 "h_kvitNaznachPlat2":U
&global-define pko1xl-h_kvitNaznachPlat3 "h_kvitNaznachPlat3":U
&global-define pko1xl-h_kvitNaznachPlat4 "h_kvitNaznachPlat4":U
&global-define pko1xl-h_docCode "h_docCode":U
&global-define pko1xl-h_docDate "h_docDate":U
&global-define pko1xl-h_kvitSumRubKop "h_kvitSumRubKop":U
&global-define pko1xl-h_kvitSumRubProp1 "h_kvitSumRubProp1":U
&global-define pko1xl-h_kvitSumRubProp2 "h_kvitSumRubProp2":U
&global-define pko1xl-h_kvitSumRubProp3 "h_kvitSumRubProp3":U
&global-define pko1xl-h_kvitSumKopProp "h_kvitSumKopProp":U
&global-define pko1xl-h_corAcc1Value "h_corAcc1Value":U
&global-define pko1xl-h_strPodrCode "h_strPodrCode":U
&global-define pko1xl-h_corAccValue "h_corAccValue":U
&global-define pko1xl-h_anUchetValue "h_anUchetValue":U
&global-define pko1xl-h_sumDoc "h_sumDoc":U
&global-define pko1xl-h_celNaznValue "h_celNaznValue":U
&global-define pko1xl-h_payerName "h_payerName":U
&global-define pko1xl-h_kvitIncluding "h_kvitIncluding":U
&global-define pko1xl-h_naznachPlat1 "h_naznachPlat1":U
&global-define pko1xl-h_naznachPlat2 "h_naznachPlat2":U
&global-define pko1xl-h_kvitDateString "h_kvitDateString":U
&global-define pko1xl-h_sumRubProp1 "h_sumRubProp1":U
&global-define pko1xl-h_sumRubProp2 "h_sumRubProp2":U
&global-define pko1xl-h_sumKopProp "h_sumKopProp":U
&global-define pko1xl-h_including "h_including":U
&global-define pko1xl-h_enclosure "h_enclosure":U
&global-define pko1xl-h_receiverBuh "h_receiverBuh":U
&global-define pko1xl-h_kvitReceiverBuh "h_kvitReceiverBuh":U
&global-define pko1xl-h_receiverKass "h_receiverKass":U
&global-define pko1xl-h_kvitReceiverKass "h_kvitReceiverKass":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.

define variable v-pko1xl-current-data-row     as integer      no-undo.
define variable v-pko1xl-cell-file-name       as character    no-undo.
/*define variable v-pko1xl-data-file-name       as character    no-undo.*/

/*==========================================================================*/
procedure pko1xl-init :

    define buffer buf_temp_cell-data        for temp_cell-data.
    define buffer buf_usr-flt               for ubflt.usr-flt.
do
for buf_temp_cell-data
  , buf_usr-flt
on error undo, return error
:
    assign
        v-pko1xl-current-data-row = 0
    .
/*    run gbl/_tmpfile.p (*/
/*          input "xd"*/
/*        , input ".txt"*/
/*        , output v-pko1xl-data-file-name*/
/*    ).*/
/*    output stream excel-line to value( v-pko1xl-data-file-name ).*/
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-pko1xl-cell-file-name
    ).
    output stream excel-cell to value( v-pko1xl-cell-file-name ).
    if printrubl = yes
    then do:
        run pko1xl-write-cell-data in this-procedure (
              input {&pko1xl-valutCode}
            , input "0":U
        ).
    end.
    else do:
        run pko1xl-write-cell-data in this-procedure (
              input {&pko1xl-valutCode}
            , input "1":U
        ).
    end.
    run pko1xl-write-cell-data in this-procedure (
          input {&pko1xl-columnList}
        , input "":U
    ).
    run pko1xl-write-cell-data in this-procedure (
          input {&pko1xl-columnType}
        , input "":U
    ).
    run pko1xl-write-cell-data in this-procedure (
          input {&pko1xl-columnAmount}
        , input "0":U
    ).
    run pko1xl-write-cell-data in this-procedure (
          input {&pko1xl-subtotalList}
        , input "":U
    ).
    run pko1xl-write-cell-data in this-procedure (
          input {&pko1xl-subtotalType}
        , input "":U
    ).
    run pko1xl-write-cell-data in this-procedure (
          input {&pko1xl-subtotalAmount}
        , input "0":U
    ).
    run pko1xl-write-cell-data in this-procedure (
        input {&pko1xl-subtotalPropisList}
        , input "":U
    ).
    run pko1xl-write-cell-data in this-procedure (
        input {&pko1xl-subtotalPropisAmount}
        , input "0":U
    ).
end.
end procedure. /* pko1xl-init */

/*==========================================================================*/
procedure pko1xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/ko_in.xlt":U.
        export "exe/t_97.bas":U.
        export v-pko1xl-cell-file-name.
        export "":U.
    output close.
end.
end procedure. /* pko1xl-close */


/*==========================================================================*/
procedure pko1xl-write-cell-data :
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
end procedure. /* pko1xl-write-cell-data */


/* $Workfile$ e n d */