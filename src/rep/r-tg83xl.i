/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Акт о расхождениях при приемке товара. ТОРГ-8.3 (Кедр-М) - Excel

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

&global-define tg83xl-line-data-key        "LD":U

&global-define tg83xl-valutCode            "valutCode":U
&global-define tg83xl-columnList           "columnList":U
&global-define tg83xl-columnType           "columnType":U
&global-define tg83xl-columnAmount         "columnAmount":U

&global-define tg83xl-subtotalList         "subtotalList":U
&global-define tg83xl-subtotalType         "subtotalType":U
&global-define tg83xl-subcolumnAmount      "subcolumnAmount":U

&global-define tg83xl-organization         "h_organization":U
&global-define tg83xl-organization2        "h_organization2":U
&global-define tg83xl-object               "h_object":U
&global-define tg83xl-cliFrom              "h_cliFrom":U
&global-define tg83xl-docCode              "h_docCode":U
&global-define tg83xl-docDate              "h_docDate":U
&global-define tg83xl-cargoTo              "h_cargoTo":U
&global-define tg83xl-cargoToValue         "h_cargoToValue":U
&global-define tg83xl-supplier             "h_supplier":U
&global-define tg83xl-ndog                 "h_ndog":U
&global-define tg83xl-nnakl                "h_nnakl":U
&global-define tg83xl-dnakl                "h_dnakl":U
&global-define tg83xl-ddog                 "h_ddog":U
&global-define tg83xl-object               "h_object":U
&global-define tg83xl-wrkrname             "h_wrkrname":U
&global-define tg83xl-pass                 "h_pass":U
&global-define tg83xl-dover                "f_dover":U

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
    field count             as character
    field Name              as character
    field EI                as character
    field docqnty           as character
    field docprice          as character
    field docsum            as character
    field factqnty          as character
    field factprice         as character
    field factsum           as character
    field qntyi             as character
    field sumi              as character
    field qntyn             as character
    field sumn              as character

    index pi is primary unique
        xl-line-id
.

define variable v-tg83xl-cur-data-row    as integer      no-undo .
define variable v-tg83xl-cell-file-name  as character    no-undo .
define variable v-tg83xl-data-file-name  as character    no-undo .

/*==========================================================================*/
procedure tg83xl-init :

do
on error undo, return error
:
    assign
        v-tg83xl-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-tg83xl-data-file-name
    ).
    output stream excel-line to value( v-tg83xl-data-file-name ).

    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-tg83xl-cell-file-name
    ).
    output stream excel-cell to value( v-tg83xl-cell-file-name ).

    run tg83xl-write-cell-data in this-procedure (
          input {&tg83xl-valutCode}
        , input "0":U
    ).

    run tg83xl-write-cell-data in this-procedure (
          input {&tg83xl-columnList}
        , input "count,Name,EI,docqnty,docprice,docsum,factqnty,factprice,factsum,qntyi,sumi,qntyn,sumn"
    ).
    run tg83xl-write-cell-data in this-procedure (
          input {&tg83xl-columnType}
        , input "S,S,S,D,D,D,D,D,D,D,D,D,D":U
    ).
    run tg83xl-write-cell-data in this-procedure (
          input {&tg83xl-columnAmount}
        , input "13":U
    ).

end.
end procedure. /* tg83xl-init */


/*==========================================================================*/
procedure tg83xl-write-line-data :
define input parameter p-count             as character        no-undo .
define input parameter p-Name              as character        no-undo .
define input parameter p-EI                as character        no-undo .
define input parameter p-doc-qnty          as character        no-undo .
define input parameter p-doc-price         as character        no-undo .
define input parameter p-doc-sum           as character        no-undo .
define input parameter p-fact-qnty         as character        no-undo .
define input parameter p-fact-price        as character        no-undo .
define input parameter p-fact-sum          as character        no-undo .
define input parameter p-qnty-i            as character        no-undo .
define input parameter p-sum-i             as character        no-undo .
define input parameter p-qnty-n            as character        no-undo .
define input parameter p-sum-n             as character        no-undo .

    define buffer buf_temp_line-data        for temp_line-data .
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
        v-tg83xl-cur-data-row               = v-tg83xl-cur-data-row + 1
        buf_temp_line-data.data-key         = {&tg83xl-line-data-key}
        buf_temp_line-data.count             = p-count
        buf_temp_line-data.Name             = p-Name
        buf_temp_line-data.EI               = p-EI
        buf_temp_line-data.docqnty          = p-doc-qnty
        buf_temp_line-data.docprice         = p-doc-price
        buf_temp_line-data.docsum           = p-doc-sum
        buf_temp_line-data.factqnty         = p-fact-qnty
        buf_temp_line-data.factprice        = p-fact-price
        buf_temp_line-data.factsum          = p-fact-sum
        buf_temp_line-data.qntyi            = p-qnty-i
        buf_temp_line-data.sumi             = p-sum-i
        buf_temp_line-data.qntyn            = p-qnty-n
        buf_temp_line-data.sumn             = p-sum-n
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        {&tabulation}   buf_temp_line-data.count
        {&tabulation}   buf_temp_line-data.Name
        {&tabulation}   buf_temp_line-data.EI
        {&tabulation}   buf_temp_line-data.docqnty
        {&tabulation}   buf_temp_line-data.docprice
        {&tabulation}   buf_temp_line-data.docsum
        {&tabulation}   buf_temp_line-data.factqnty
        {&tabulation}   buf_temp_line-data.factprice
        {&tabulation}   buf_temp_line-data.factsum
        {&tabulation}   buf_temp_line-data.qntyi
        {&tabulation}   buf_temp_line-data.sumi
        {&tabulation}   buf_temp_line-data.qntyn
        {&tabulation}   buf_temp_line-data.sumn
        {&new-line}
    .
end.
end procedure. /* tg83xl-write-line-data */


/*==========================================================================*/
procedure tg83xl-write-cell-data :
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
end procedure. /* tg83xl-write-cell-data */

/*==========================================================================*/
procedure tg83xl-run-excel :
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
        v-template-file-name    = search( "exe/tg83.xlt" )
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
end procedure. /* tg83xl-run-excel */


/*==========================================================================*/
procedure tg83xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/tg83.xlt":U.
        export "exe/t_97.bas":U.
        export v-tg83xl-cell-file-name.
        export v-tg83xl-data-file-name.
    output close.
end.
end procedure. /* tg83xl-close */

/* $Workfile$ e n d */