/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы книга покупок r-book в Excel

Автор: Кочетков Михаил Юрьевич
Дата создания: 12/05/05
Author: Michael Kochetkov
Creation date: 12/05/05

Required:
{ gbl/paramls.i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define bookxl-line-data-key "LD":U
&global-define bookxl-valutCode "valutCode":U
&global-define bookxl-columnList "columnList":U
&global-define bookxl-columnType "columnType":U
&global-define bookxl-columnAmount "columnAmount":U
/*&global-define bookxl-subtotalList "subtotalList":U*/
/*&global-define bookxl-subtotalType "subtotalType":U*/
/*&global-define bookxl-subtotalAmount "subtotalAmount":U*/
/*&global-define bookxl-subtotalPropisList "subtotalPropisList":U*/
/*&global-define bookxl-subtotalPropisAmount "subtotalPropisAmount":U*/

&global-define bookxl-h_organization "h_organization":U
&global-define bookxl-h_inn "h_inn":U
&global-define bookxl-h_startDate "h_startDate":U
&global-define bookxl-h_endDate "h_endDate":U

&global-define bookxl-f_BuhName      "f_BuhName":U

&global-define bookxl-it_sum       "it_sum":U
&global-define bookxl-it_sumVAT20  "it_sumVAT20":U
&global-define bookxl-it_VAT20     "it_VAT20":U
&global-define bookxl-it_sumVAT10  "it_sumVAT10":U
&global-define bookxl-it_VAT10     "it_VAT10":U
&global-define bookxl-it_sumVAT0   "it_sumVAT0":U
&global-define bookxl-it_sumVATno  "it_sumVATno":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key

.
define temp-table temp_line-data no-undo
    field data-key     as character
    field xl-line-id   as integer
    field num          as integer
    field docDateCode  as character
    field payDate      as character
    field inDate       as character
    field cliName      as character
    field cliInn       as character
    field cliKPP       as character
    field countryGds   as character
    field sumRubl      as decimal
    field sumVAT20     as decimal
    field VAT20        as decimal
    field sumVAT10     as decimal
    field VAT10        as decimal
    field sumVAT0      as decimal
    field sumVATno     as decimal

    index pi is primary unique xl-line-id
.

define variable v-bookxl-current-data-row     as integer      no-undo.
define variable v-bookxl-cell-file-name       as character    no-undo.
define variable v-bookxl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure bookxl-init :

    define buffer buf_temp_cell-data        for temp_cell-data.
    define buffer buf_usr-flt               for ubflt.usr-flt.
do
for buf_temp_cell-data
  , buf_usr-flt
on error undo, return error
:
    assign
        v-bookxl-current-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-bookxl-data-file-name
    ).
    output stream excel-line to value( v-bookxl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-bookxl-cell-file-name
    ).
    output stream excel-cell to value( v-bookxl-cell-file-name ).
/*    if printrubl = yes*/
/*    then do:*/
        run bookxl-write-cell-data in this-procedure (
              input {&bookxl-valutCode}
            , input "0":U
        ).
/*    end.*/
/*    else do:*/
/*        run bookxl-write-cell-data in this-procedure (*/
/*              input {&bookxl-valutCode}*/
/*            , input "1":U*/
/*        ).*/
/*    end.*/
    run bookxl-write-cell-data in this-procedure (
          input {&bookxl-columnList}
        , input "num,docDateCode,payDate,inDate,cliName,cliInn,cliKPP,countryGds,sumRubl,sumVAT20,VAT20,sumVAT10,VAT10,sumVAT0,sumVATno":U
    ).
    run bookxl-write-cell-data in this-procedure (
          input {&bookxl-columnType}
        , input "I,S,S,S,S,S,S,S,D,D,D,D,D,D,D":U
    ).
    run bookxl-write-cell-data in this-procedure (
          input {&bookxl-columnAmount}
        , input "15":U
    ).
end.
end procedure. /* bookxl-init */

/*==========================================================================*/
procedure bookxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/book.xlt":U.
        export "exe/t_97.bas":U.
        export v-bookxl-cell-file-name.
        export v-bookxl-data-file-name.
    output close.
end.
end procedure. /* bookxl-close */


/*==========================================================================*/
procedure bookxl-write-cell-data :
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
end procedure. /* bookxl-write-cell-data */


/*==========================================================================*/
procedure bookxl-write-line-data :
define input parameter p-num            as integer          no-undo.
define input parameter p-docDateCode    as character        no-undo.
define input parameter p-payDate        as character        no-undo.
define input parameter p-inDate         as character        no-undo.
define input parameter p-cliName        as character        no-undo.
define input parameter p-cliInn         as character        no-undo.
define input parameter p-cliKpp         as character        no-undo.
define input parameter p-countryGds     as character        no-undo.
define input parameter p-sumRubl        as decimal          no-undo .
define input parameter p-sumVAT20       as decimal          no-undo.
define input parameter p-VAT20          as decimal          no-undo.
define input parameter p-sumVAT10       as decimal          no-undo.
define input parameter p-VAT10          as decimal          no-undo.
define input parameter p-sumVAT0        as decimal          no-undo.
define input parameter p-sumVATno       as decimal          no-undo.

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
        v-bookxl-current-data-row = v-bookxl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key      = {&bookxl-line-data-key}
        buf_temp_line-data.xl-line-id    = v-bookxl-current-data-row
        buf_temp_line-data.num           = p-num
        buf_temp_line-data.docDateCode   = p-docDateCode
        buf_temp_line-data.payDate       = p-payDate
        buf_temp_line-data.inDate        = p-inDate
        buf_temp_line-data.cliName       = p-cliName
        buf_temp_line-data.cliInn        = p-cliInn
        buf_temp_line-data.cliKPP        = p-cliKPP
        buf_temp_line-data.countryGds    = p-countryGds
        buf_temp_line-data.sumRubl       = p-sumRubl
        buf_temp_line-data.sumVAT20      = p-sumVAT20
        buf_temp_line-data.VAT20         = p-VAT20
        buf_temp_line-data.sumVAT10      = p-sumVAT10
        buf_temp_line-data.VAT10         = p-VAT10
        buf_temp_line-data.sumVAT0       = p-sumVAT0
        buf_temp_line-data.sumVATno      = p-sumVATno
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        {&tabulation}   ( if buf_temp_line-data.num = 0 then "":U else string( buf_temp_line-data.num ) )
        {&tabulation}   buf_temp_line-data.docDateCode
        {&tabulation}   buf_temp_line-data.payDate
        {&tabulation}   buf_temp_line-data.inDate
        {&tabulation}   buf_temp_line-data.cliName
        {&tabulation}   buf_temp_line-data.cliInn
        {&tabulation}   buf_temp_line-data.cliKPP
        {&tabulation}   buf_temp_line-data.countryGds
        {&tabulation}   buf_temp_line-data.sumRubl
        {&tabulation}   buf_temp_line-data.sumVAT20
        {&tabulation}   buf_temp_line-data.VAT20
        {&tabulation}   buf_temp_line-data.sumVAT10
        {&tabulation}   buf_temp_line-data.VAT10
        {&tabulation}   buf_temp_line-data.sumVAT0
        {&tabulation}   buf_temp_line-data.sumVATno
        {&new-line}
    .
end.
end procedure. /* bookxl-write-line-data */


/*==========================================================================*/
procedure bookxl-run-excel :
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
        v-template-file-name    = search( "exe/book.xlt" )
        v-vb-file-name          = search( "exe/t_97.bas")
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
/*    run paramls-write in this-procedure (*/
/*          input {&paramls-saveas}*/
/*        , input {&paramls-excel-file-name}*/
/*        , input v-excel-file-name*/
/*    ).*/
/*    run paramls-write in this-procedure (*/
/*          input "charcol"*/
/*        , input ""*/
/*        , input "2"*/
/*    ).*/
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
end procedure. /* bookxl-run-excel */

/* $Workfile$ e n d */