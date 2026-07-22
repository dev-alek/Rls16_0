/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Акт о приемке товаров. 1393НТФ №ТОРГ-8.4 (Кедр-М) - Excel

Автор: Комаров Иван Сергеевич
Дата создания: 02/26/10
Author: Ivan Komarov
Creation date: 02/26/10

Автор1: Демин Алексей Сергеевич
Дата создания: 09/06/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define tg84xl-line-data-key        "LD":U

&global-define tg84xl-valutCode            "valutCode":U
&global-define tg84xl-columnList           "columnList":U
&global-define tg84xl-columnType           "columnType":U
&global-define tg84xl-columnAmount         "columnAmount":U

&global-define tg84xl-subtotalList         "subtotalList":U
&global-define tg84xl-subtotalType         "subtotalType":U
&global-define tg84xl-subcolumnAmount      "subcolumnAmount":U

&global-define tg84xl-organization         "h_organization":U
&global-define tg84xl-object               "h_object":U
&global-define tg84xl-cliFrom              "h_cliFrom":U
&global-define tg84xl-docCode              "h_docCode":U
&global-define tg84xl-docDate              "h_docDate":U
&global-define tg84xl-cargoTo              "h_cargoTo":U
&global-define tg84xl-cargoToValue         "h_cargoToValue":U
&global-define tg84xl-supplier             "h_supplier":U
&global-define tg84xl-ndog                 "h_ndog":U
&global-define tg84xl-nakl                 "h_nakl":U
&global-define tg84xl-datadog              "h_data_dog":U
&global-define tg84xl-monthdog             "h_month_dog":U
&global-define tg84xl-yeardog              "h_year_dog":U
&global-define tg84xl-object               "h_object":U
&global-define tg84xl-object2              "h_object2":U

&global-define tg84xl-it-PlaceAmountSupp   "it_PlaceAmountSupp":U
&global-define tg84xl-it-SumSupp           "it_SumSupp":U
&global-define tg84xl-it-PlaceAmountFact   "it_PlaceAmountFact":U
&global-define tg84xl-it-SumFact           "it_SumFact":U
&global-define tg84xl-it-sum               "it_sum":U
&global-define tg84xl-it-VATsum            "it_VATsum":U
&global-define tg84xl-it-PlaceAmountDelt   "it_PlaceAmountDelt":U
&global-define tg84xl-it-SumDelt           "it_SumDelt":U

define stream excel-line .
define stream excel-cell .

define temp-table temp_cell-data no-undo
    field data-key   as character
    field data-value as character

    index pi is primary unique data-key
.

define temp-table temp_line-data no-undo
    field data-key          as character
    field xl-line-id        as integer
    field Name              as character
    field EI                as character
    field price             as character
    field PlaceAmountSupp   as character
    field SumSupp           as character
    field PlaceAmountFact   as character
    field SumFact           as character
    field sum               as character
    field VATpc             as character
    field VATsum            as character
    field PlaceAmountDelt   as character
    field SumDelt           as character

    index pi is primary unique
        xl-line-id
.

define variable v-tg84xl-cur-data-row    as integer      no-undo .
define variable v-tg84xl-cell-file-name  as character    no-undo .
define variable v-tg84xl-data-file-name  as character    no-undo .

/*==========================================================================*/
procedure tg84xl-init :

do
on error undo, return error
:
    assign
        v-tg84xl-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-tg84xl-data-file-name
    ).
    output stream excel-line to value( v-tg84xl-data-file-name ).

    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-tg84xl-cell-file-name
    ).
    output stream excel-cell to value( v-tg84xl-cell-file-name ).

    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-valutCode}
        , input "0":U
    ).

    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-columnList}
        , input "Name,EI,price,PlaceAmountSupp,SumSupp,PlaceAmountFact,SumFact,sum,VATpc,VATsum,PlaceAmountDelt,SumDelt":U
    ).
    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-columnType}
        , input "S,S,D,D,D,D,D,D,D,D,D,D":U
    ).
    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-columnAmount}
        , input "12":U
    ).

end.
end procedure. /* tg84xl-init */


/*==========================================================================*/
procedure tg84xl-write-line-data :
define input parameter p-Name              as character        no-undo.
define input parameter p-EI                as character        no-undo.
define input parameter p-price             as character        no-undo.
define input parameter p-PlaceAmountSupp   as character        no-undo.
define input parameter p-SumSupp           as character        no-undo.
define input parameter p-PlaceAmountFact   as character        no-undo.
define input parameter p-SumFact           as character        no-undo.
define input parameter p-sum               as character        no-undo.
define input parameter p-VATpc             as character        no-undo.
define input parameter p-VATsum            as character        no-undo.
define input parameter p-PlaceAmountDelt   as character        no-undo.
define input parameter p-SumDelt           as character        no-undo.

    define buffer buf_temp_line-data        for temp_line-data.
do
for buf_temp_line-data
on error undo, return error
:
    for each buf_temp_line-data
    :
        delete buf_temp_line-data.
    end.
    create buf_temp_line-data.
    assign
        v-tg84xl-cur-data-row                = v-tg84xl-cur-data-row + 1
        buf_temp_line-data.data-key          = {&tg84xl-line-data-key}
        buf_temp_line-data.Name              = p-Name
        buf_temp_line-data.EI                = p-EI
        buf_temp_line-data.price             = p-price
        buf_temp_line-data.PlaceAmountSupp   = p-PlaceAmountSupp
        buf_temp_line-data.SumSupp           = p-SumSupp
        buf_temp_line-data.PlaceAmountFact   = p-PlaceAmountFact
        buf_temp_line-data.SumFact           = p-SumFact
        buf_temp_line-data.sum               = p-sum
        buf_temp_line-data.VATpc             = p-VATpc
        buf_temp_line-data.VATsum            = p-VATsum
        buf_temp_line-data.PlaceAmountDelt   = p-PlaceAmountDelt
        buf_temp_line-data.SumDelt           = p-SumDelt
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        {&tabulation}   buf_temp_line-data.Name
        {&tabulation}   buf_temp_line-data.EI
        {&tabulation}   buf_temp_line-data.price
        {&tabulation}   buf_temp_line-data.PlaceAmountSupp
        {&tabulation}   buf_temp_line-data.SumSupp
        {&tabulation}   buf_temp_line-data.PlaceAmountFact
        {&tabulation}   buf_temp_line-data.SumFact
        {&tabulation}   buf_temp_line-data.sum
        {&tabulation}   buf_temp_line-data.VATpc
        {&tabulation}   buf_temp_line-data.VATsum
        {&tabulation}   buf_temp_line-data.PlaceAmountDelt
        {&tabulation}   buf_temp_line-data.SumDelt
        {&new-line}
    .
end.
end procedure. /* tg84xl-write-line-data */


/*==========================================================================*/
procedure tg84xl-write-cell-data :
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
end procedure. /* tg84xl-write-cell-data */

/*==========================================================================*/
procedure tg84xl-run-excel :
define input parameter p-header-filename    as character    no-undo .
define input parameter p-data-filename      as character    no-undo .

define variable v-template-file-name        as character    no-undo .
define variable v-vb-file-name              as character    no-undo .

    define buffer buf_temp-param for temp-param .
do
for buf_temp-param
on error undo, return error
:
    create buf_temp-param.
    assign
        v-template-file-name    = search( "exe/tg84.xlt" )
        v-vb-file-name          = search( "exe/t_97.bas")
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
end procedure. /* tg84xl-run-excel */


/*==========================================================================*/
procedure tg84xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/tg84.xlt":U.
        export "exe/t_97.bas":U.
        export v-tg84xl-cell-file-name.
        export v-tg84xl-data-file-name.
    output close.
end.
end procedure. /* tg84xl-close */

/*==========================================================================*/
procedure tg84xl-write-line-format :
define input parameter p-fmt-label  as character  no-undo.

define buffer buf_temp_line-data    for temp_line-data.

do
for buf_temp_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        {&tg84xl-name}
        {&tabulation}   {&tg84xl-format-label}
        {&tabulation}   p-fmt-label
        {&new-line}
    .
end.
end procedure. /* tg84xl-write-line-format */


/* $Workfile$ e n d */