/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчёт Оборотная ведомость по матценностям - Excel

Автор: Демин Алексей Сергеевич
Дата создания: 09/06/07
Author: Alexey Demin
Creation date: 09/06/07

Required:
    { g b l / p a r a m l s . i    }
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define torg1xl-data-label "DTA":U
&global-define torg1xl-format-label "FMT":U

&global-define torg1xl-FMT_Object "Объект":U

&global-define torg1xl-sheetList  "стр1,стр2,стр3":U

&global-define torg1xl-sheet1_valutCode       "стр1_valutCode":U
&global-define torg1xl-sheet1_columnList      "стр1_columnList":U
&global-define torg1xl-sheet1_columnType      "стр1_columnType":U
&global-define torg1xl-sheet1_subtotalList    "стр1_subtotalList":U
&global-define torg1xl-sheet1_subtotalType    "стр1_subtotalType":U

&global-define torg1xl-sheet2_valutCode       "стр2_valutCode":U
&global-define torg1xl-sheet2_columnList      "стр2_columnList":U
&global-define torg1xl-sheet2_columnType      "стр2_columnType":U
&global-define torg1xl-sheet2_subtotalList    "стр2_subtotalList":U
&global-define torg1xl-sheet2_subtotalType    "стр2_subtotalType":U

&global-define torg1xl-sheet3_valutCode       "стр3_valutCode":U
&global-define torg1xl-sheet3_columnList      "стр3_columnList":U
&global-define torg1xl-sheet3_columnType      "стр3_columnType":U
&global-define torg1xl-sheet3_subtotalList    "стр3_subtotalList":U
&global-define torg1xl-sheet3_subtotalType    "стр3_subtotalType":U

&global-define torg1xl-sheet1-name            "стр1":U
&global-define torg1xl-sheet1-organization    "organization":U
&global-define torg1xl-sheet1-okpo            "okpo":U
&global-define torg1xl-sheet1-cliFrom         "cliFrom":U
&global-define torg1xl-sheet1-docCode         "docCode":U
&global-define torg1xl-sheet1-docDate         "docDate":U
&global-define torg1xl-sheet1-operationType   "operationType":U
&global-define torg1xl-sheet1-cargoTo         "cargoTo":U
&global-define torg1xl-sheet1-cargoToValue    "cargoToValue":U
&global-define torg1xl-sheet1-supplier        "supplier":U

&global-define torg1xl-sheet2-name "стр2":U

&global-define torg1xl-sheet2-it-PlaceAmountSupp         "стр2_it_PlaceAmountSupp":U
&global-define torg1xl-sheet2-it-SumSupp                 "стр2_it_SumSupp":U
&global-define torg1xl-sheet2-it-PlaceAmountFact         "стр2_it_PlaceAmountFact":U
&global-define torg1xl-sheet2-it-SumFact                 "стр2_it_SumFact":U
&global-define torg1xl-sheet2-it-sum                     "стр2_it_sum":U
&global-define torg1xl-sheet2-it-VATsum                  "стр2_it_VATsum":U
&global-define torg1xl-sheet2-it-PlaceAmountDelt         "стр2_it_PlaceAmountDelt":U
&global-define torg1xl-sheet2-it-SumDelt                 "стр2_it_SumDelt":U

&global-define torg1xl-sheet3-name          "стр3":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.

define temp-table temp_sheet2_line-data no-undo
    field sheet-name        as character
    field xl-line-id        as integer
    field counter           as integer
    field Name              as character
    field gdscode           as character
    field EI                as character
    field OKEI              as character
    field price             as character
    field AmountInPlSupp    as character
    field PlaceAmountSupp   as character
    field MassSupp          as character
    field SumSupp           as character
    field AmountInPlFact    as character
    field PlaceAmountFact   as character
    field MassFact          as character
    field SumFact           as character
    field sum               as character
    field VATpc             as character
    field VATsum            as character
    field AmountInPlDelt    as character
    field PlaceAmountDelt   as character
    field MassDelt          as character
    field SumDelt           as character
    field Sertif            as character

    index pi is primary unique
        xl-line-id
.

define variable v-torg1xl-sheet2-cur-data-row   as integer      no-undo.
define variable v-torg1xl-cell-file-name            as character    no-undo.
define variable v-torg1xl-data-file-name            as character    no-undo.

/*==========================================================================*/
procedure torg1xl-init :

do
on error undo, return error
:
    assign
        v-torg1xl-sheet2-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-torg1xl-data-file-name
    ).
    output stream excel-line to value( v-torg1xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-torg1xl-cell-file-name
    ).
    output stream excel-cell to value( v-torg1xl-cell-file-name ).
    run torg1xl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&torg1xl-sheetList}
    ).
    if printrubl
    then do:
        run torg1xl-write-cell-data in this-procedure (
              input {&torg1xl-sheet1_valutCode}
            , input "0":U
        ).
        run torg1xl-write-cell-data in this-procedure (
              input {&torg1xl-sheet2_valutCode}
            , input "0":U
        ).
        run torg1xl-write-cell-data in this-procedure (
              input {&torg1xl-sheet3_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run torg1xl-write-cell-data in this-procedure (
              input {&torg1xl-sheet1_valutCode}
            , input "1":U
        ).
        run torg1xl-write-cell-data in this-procedure (
              input {&torg1xl-sheet2_valutCode}
            , input "1":U
        ).
        run torg1xl-write-cell-data in this-procedure (
              input {&torg1xl-sheet3_valutCode}
            , input "1":U
        ).
    end.
/*    run torg1xl-write-cell-data in this-procedure (*/
/*          input {&torg1xl-sheet1_columnList}*/
/*        , input "seaname,seacode,ostbegtot,ostbeglocal,ostbegregion,ostbegimp,pritot,prilocal,priregion,priimp,saletot,salelocal,saleregion,saleimp,rettot,retlocal,retregion,retimp,othtot,othlocal,othregion,othimp,ostendtot,ostendlocal,ostendregion,ostendimp":U*/
/*    ).*/
    run torg1xl-write-cell-data in this-procedure (
          input {&torg1xl-sheet2_columnList}
        , input "counter,Name,gdscode,EI,OKEI,price,AmountInPlSupp,PlaceAmountSupp,MassSupp,SumSupp,AmountInPlFact,PlaceAmountFact,MassFact,SumFact,sum,VATpc,VATsum,AmountInPlDelt,PlaceAmountDelt,MassDelt,SumDelt,Sertif":U
    ).
    run torg1xl-write-cell-data in this-procedure (
          input {&torg1xl-sheet2_columnType}
        , input "I,S,S,S,S,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,S":U
    ).
    run torg1xl-write-cell-data in this-procedure (
          input {&torg1xl-sheet2_subtotalList}
        , input "PlaceAmountSupp,SumSupp,PlaceAmountFact,SumFact,sum,VATsum,PlaceAmountDelt,SumDelt":U
    ).
    run torg1xl-write-cell-data in this-procedure (
          input {&torg1xl-sheet2_subtotalType}
        , input "D,D,D,D,D,D,D,D":U
    ).
end.
end procedure. /* torg1xl-init */


/*==========================================================================*/
procedure torg1xl-sheet2-write-line-data :
define input parameter p-Name              as character        no-undo.
define input parameter p-gdscode           as character        no-undo.
define input parameter p-EI                as character        no-undo.
define input parameter p-OKEI              as character        no-undo.
define input parameter p-price             as character        no-undo.
define input parameter p-AmountInPlSupp    as character        no-undo.
define input parameter p-PlaceAmountSupp   as character        no-undo.
define input parameter p-MassSupp          as character        no-undo.
define input parameter p-SumSupp           as character        no-undo.
define input parameter p-AmountInPlFact    as character        no-undo.
define input parameter p-PlaceAmountFact   as character        no-undo.
define input parameter p-MassFact          as character        no-undo.
define input parameter p-SumFact           as character        no-undo.
define input parameter p-sum               as character        no-undo.
define input parameter p-VATpc             as character        no-undo.
define input parameter p-VATsum            as character        no-undo.
define input parameter p-AmountInPlDelt    as character        no-undo.
define input parameter p-PlaceAmountDelt   as character        no-undo.
define input parameter p-MassDelt          as character        no-undo.
define input parameter p-SumDelt           as character        no-undo.
define input parameter p-Sertif            as character        no-undo.

    define buffer buf_temp_sheet2_line-data        for temp_sheet2_line-data.
do
for buf_temp_sheet2_line-data
on error undo, return error
:
    for each buf_temp_sheet2_line-data
    :
        delete buf_temp_sheet2_line-data.
    end.
    create buf_temp_sheet2_line-data.
    assign
        v-torg1xl-sheet2-cur-data-row           = v-torg1xl-sheet2-cur-data-row + 1
        buf_temp_sheet2_line-data.sheet-name        = {&torg1xl-sheet2-name}
        buf_temp_sheet2_line-data.counter           = v-torg1xl-sheet2-cur-data-row
        buf_temp_sheet2_line-data.Name              = p-Name
        buf_temp_sheet2_line-data.gdscode           = p-gdscode
        buf_temp_sheet2_line-data.EI                = p-EI
        buf_temp_sheet2_line-data.OKEI              = p-OKEI
        buf_temp_sheet2_line-data.price             = p-price
        buf_temp_sheet2_line-data.AmountInPlSupp    = p-AmountInPlSupp
        buf_temp_sheet2_line-data.PlaceAmountSupp   = p-PlaceAmountSupp
        buf_temp_sheet2_line-data.MassSupp          = p-MassSupp
        buf_temp_sheet2_line-data.SumSupp           = p-SumSupp
        buf_temp_sheet2_line-data.AmountInPlFact    = p-AmountInPlFact
        buf_temp_sheet2_line-data.PlaceAmountFact   = p-PlaceAmountFact
        buf_temp_sheet2_line-data.MassFact          = p-MassFact
        buf_temp_sheet2_line-data.SumFact           = p-SumFact
        buf_temp_sheet2_line-data.sum               = p-sum
        buf_temp_sheet2_line-data.VATpc             = p-VATpc
        buf_temp_sheet2_line-data.VATsum            = p-VATsum
        buf_temp_sheet2_line-data.AmountInPlDelt    = p-AmountInPlDelt
        buf_temp_sheet2_line-data.PlaceAmountDelt   = p-PlaceAmountDelt
        buf_temp_sheet2_line-data.MassDelt          = p-MassDelt
        buf_temp_sheet2_line-data.SumDelt           = p-SumDelt
        buf_temp_sheet2_line-data.Sertif            = p-Sertif
    .
    put stream excel-line unformatted
                        buf_temp_sheet2_line-data.sheet-name
        {&tabulation}   {&torg1xl-data-label}
        {&tabulation}   buf_temp_sheet2_line-data.counter
        {&tabulation}   buf_temp_sheet2_line-data.Name
        {&tabulation}   buf_temp_sheet2_line-data.gdscode
        {&tabulation}   buf_temp_sheet2_line-data.EI
        {&tabulation}   buf_temp_sheet2_line-data.OKEI
        {&tabulation}   buf_temp_sheet2_line-data.price
        {&tabulation}   buf_temp_sheet2_line-data.AmountInPlSupp
        {&tabulation}   buf_temp_sheet2_line-data.PlaceAmountSupp
        {&tabulation}   buf_temp_sheet2_line-data.MassSupp
        {&tabulation}   buf_temp_sheet2_line-data.SumSupp
        {&tabulation}   buf_temp_sheet2_line-data.AmountInPlFact
        {&tabulation}   buf_temp_sheet2_line-data.PlaceAmountFact
        {&tabulation}   buf_temp_sheet2_line-data.MassFact
        {&tabulation}   buf_temp_sheet2_line-data.SumFact
        {&tabulation}   buf_temp_sheet2_line-data.sum
        {&tabulation}   buf_temp_sheet2_line-data.VATpc
        {&tabulation}   buf_temp_sheet2_line-data.VATsum
        {&tabulation}   buf_temp_sheet2_line-data.AmountInPlDelt
        {&tabulation}   buf_temp_sheet2_line-data.PlaceAmountDelt
        {&tabulation}   buf_temp_sheet2_line-data.MassDelt
        {&tabulation}   buf_temp_sheet2_line-data.SumDelt
        {&tabulation}   buf_temp_sheet2_line-data.Sertif
        {&new-line}
    .
end.
end procedure. /* torg1xl-sheet2-write-line-data */


/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure torg1xl-write-cell-data :
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
end procedure. /* torg1xl-write-cell-data */

/*==========================================================================*/
procedure torg1xl-run-excel :
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
        v-template-file-name    = search( "exe/torg1.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas")
    .
/*    assign*/
/*        v-template-file-name = search( v-template-file-name )*/
/*    .*/
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
end procedure. /* torg1xl-run-excel */


/*==========================================================================*/
procedure torg1xl-close :
  define variable v-template-filename as character no-undo .

do
on error undo, return error
:
    if printrubl
    then do:
      assign
        v-template-filename = "exe/torg1.xlt":U
      .
    end.
    else do:
      assign
        v-template-filename = "exe/torg1_val.xlt":U
      .
    end.

    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export v-template-filename.
        export "exe/t_form.bas":U.
        export v-torg1xl-cell-file-name.
        export v-torg1xl-data-file-name.
    output close.
end.
end procedure. /* torg1xl-close */

/*==========================================================================*/
procedure torg1xl-sheet2-write-line-format :
define input parameter p-fmt-label       as character  no-undo.


    define buffer buf_temp_sheet2_line-data        for temp_sheet2_line-data.
do
for buf_temp_sheet2_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        {&torg1xl-sheet2-name}
        {&tabulation}   {&torg1xl-format-label}
        {&tabulation}   p-fmt-label
        {&new-line}
    .
end.
end procedure. /* torg1xl-sheet2-write-line-format */


/* $Workfile$ e n d */