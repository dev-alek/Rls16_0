/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы Требования-накладной (форма М-11) в Excel

Автор: Морозов Александр Сергеевич
Дата создания: 24/03/11
Author: Alexandr Morozov
Creation date: 24/03/11

Required: { p a r a m l s . i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define r-f_m11xl-data-label   "DTA":U
&global-define r-f_m11xl-format-label "FMT":U

&global-define r-f_m11xl-sheetList  "M11":U
&global-define r-f_m11xl-sheet1_valutCode       "M11_valutCode":U
&global-define r-f_m11xl-sheet1_columnList      "M11_columnList":U
&global-define r-f_m11xl-sheet1_columnType      "M11_columnType":U
&global-define r-f_m11xl-sheet1_subtotalList    "M11_subtotalList":U
&global-define r-f_m11xl-sheet1_subtotalType    "M11_subtotalType":U

&global-define r-f_m11xl-doccode       "h_doccode":U
&global-define r-f_m11xl-orgname       "h_orgname":U
&global-define r-f_m11xl-OKPO          "h_OKPO":U
&global-define r-f_m11xl-docdate       "h_docdate":U
&global-define r-f_m11xl-doctype       "h_doctype":U
&global-define r-f_m11xl-objname1      "h_objname1":U
&global-define r-f_m11xl-objname2      "h_objname2":U
&global-define r-f_m11xl-storeman      "h_storeman":U

&global-define r-f_m11xl-it_noVATrubl      "M11_it_noVATrubl":U
&global-define r-f_m11xl-it_quantity1      "M11_it_quantity1":U
&global-define r-f_m11xl-it_quantity2      "M11_it_quantity2":U

&global-define r-f_m11xl-sheet1-name   "M11":U
&global-define r-f_m11xl-wordord       "f_wordord":U
&global-define r-f_m11xl-wordsum       "f_wordsum":U
&global-define r-f_m11xl-wordVAT       "f_wordVAT":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.

define temp-table temp_sheet1_line-data no-undo
    field sheet-name    as character
    field xl-line-id    as integer
    field account       as character
    field analytics     as character
    field wealthname    as character
    field article       as character
    field unitcode      as character
    field unitname      as character
    field quantity1     as character
    field quantity2     as character
    field costrubl      as character
    field noVATrubl     as character
    field order         as character

    index pi is primary unique
        xl-line-id
.

define variable v-r-f_m11xl-sheet1-cur-data-row  as integer      no-undo.
define variable v-r-f_m11xl-cell-file-name       as character    no-undo.
define variable v-r-f_m11xl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure r-f_m11xl-init :

do
on error undo, return error
:
    assign
        v-r-f_m11xl-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-r-f_m11xl-data-file-name
    ).
    output stream excel-line to value( v-r-f_m11xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-r-f_m11xl-cell-file-name
    ).
    output stream excel-cell to value( v-r-f_m11xl-cell-file-name ).
    run r-f_m11xl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&r-f_m11xl-sheetList}
    ).
    if printrubl
    then do:
        run r-f_m11xl-write-cell-data in this-procedure (
              input {&r-f_m11xl-sheet1_valutCode}
            , input "0":U
        ).

    end.
    else do:
        run r-f_m11xl-write-cell-data in this-procedure (
              input {&r-f_m11xl-sheet1_valutCode}
            , input "1":U
        ).

    end.


    run r-f_m11xl-write-cell-data in this-procedure (
          input {&r-f_m11xl-sheet1_columnList}
        , input "account,analytics,wealthname,article,unitcode,unitname,quantity1,quantity2,costrubl,noVATrubl,order":U
    ).
    run r-f_m11xl-write-cell-data in this-procedure (
          input {&r-f_m11xl-sheet1_columnType}
        , input "S,S,S,S,S,S,D,D,C,C,I":U
    ).
/*    run r-f_m11xl-write-cell-data in this-procedure (
          input {&r-f_m11xl-sheet1_subtotalList}
        , input "quantity1,quantity2,noVATrubl":U
    ).
    run r-f_m11xl-write-cell-data in this-procedure (
          input {&r-f_m11xl-sheet1_subtotalType}
        , input "D,D,C":U
    ).*/
end.
end procedure. /* r-f_m11xl-init */

/*==========================================================================*/
procedure r-f_m11xl-sheet1-write-line-data :
define input parameter p-account          as character        no-undo.
define input parameter p-analytics        as character        no-undo.
define input parameter p-wealthname      as character        no-undo.
define input parameter p-article          as character        no-undo.
define input parameter p-unitcode        as character        no-undo.
define input parameter p-unitname        as character        no-undo.
define input parameter p-quantity1        as character        no-undo.
define input parameter p-quantity2        as character        no-undo.
define input parameter p-costrubl        as character        no-undo.
define input parameter p-noVATrubl      as character        no-undo.
define input parameter p-order            as character        no-undo.

    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    for each buf_temp_sheet1_line-data
    :
        delete buf_temp_sheet1_line-data.
    end.
    create buf_temp_sheet1_line-data.
    assign
        v-r-f_m11xl-sheet1-cur-data-row         = v-r-f_m11xl-sheet1-cur-data-row + 1
        buf_temp_sheet1_line-data.sheet-name    = {&r-f_m11xl-sheet1-name}
        buf_temp_sheet1_line-data.xl-line-id    = v-r-f_m11xl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.account       = p-account
        buf_temp_sheet1_line-data.analytics     = p-analytics
        buf_temp_sheet1_line-data.wealthname   = p-wealthname
        buf_temp_sheet1_line-data.article       = p-article
        buf_temp_sheet1_line-data.unitcode     = p-unitcode
        buf_temp_sheet1_line-data.unitname     = p-unitname
        buf_temp_sheet1_line-data.quantity1     = p-quantity1
        buf_temp_sheet1_line-data.quantity2     = p-quantity2
        buf_temp_sheet1_line-data.costrubl     = p-costrubl
        buf_temp_sheet1_line-data.noVATrubl   = p-noVATrubl
        buf_temp_sheet1_line-data.order         = p-order
    .
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        {&tabulation}   {&r-f_m11xl-data-label}
        {&tabulation}   buf_temp_sheet1_line-data.account
        {&tabulation}   buf_temp_sheet1_line-data.analytics
        {&tabulation}   buf_temp_sheet1_line-data.wealthname
        {&tabulation}   buf_temp_sheet1_line-data.article
        {&tabulation}   buf_temp_sheet1_line-data.unitcode
        {&tabulation}   buf_temp_sheet1_line-data.unitname
        {&tabulation}   buf_temp_sheet1_line-data.quantity1
        {&tabulation}   buf_temp_sheet1_line-data.quantity2
        {&tabulation}   buf_temp_sheet1_line-data.costrubl
        {&tabulation}   buf_temp_sheet1_line-data.noVATrubl
        {&tabulation}   buf_temp_sheet1_line-data.order
        {&new-line}
    .
    .
end.
end procedure. /* r-f_m11xl-write-line-data */


/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure r-f_m11xl-write-cell-data :
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
end procedure. /* r-f_m11xl-write-cell-data */

/*==========================================================================*/
procedure r-f_m11xl-run-excel :
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
        v-template-file-name    = search( "exe/f_m11.xlt" )
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
end procedure. /* r-f_m11xl-run-excel */


/*==========================================================================*/
procedure r-f_m11xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
/*        put unformatted*/
/*            substitute("&2&1&3&1&4&1&1",*/
/*                  {&new-line}*/
/*                , "d:\ww\2\t12_97.xlt":U*/
/*                , v-r-f_m11xl-cell-file-name*/
/*                , v-r-f_m11xl-data-file-name*/
/*            )*/
/*        .*/
        export "exe/f_m11.xlt":U.
        export "exe/t_form.bas":U.
        export v-r-f_m11xl-cell-file-name.
        export v-r-f_m11xl-data-file-name.
    output close.
end.
end procedure. /* r-f_m11xl-close */

/* $Workfile$ e n d */