/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы Требования-накладной (форма М-11) в Excel

Автор: Морозов Александр Сергеевич
Дата создания: 20/05/11
Author: Alexandr Morozov
Creation date: 20/05/11

Required: { p a r a m l s . i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define torg16xl-data-label "DTA":U
&global-define torg16xl-format-label "FMT":U

&global-define torg16xl-sheetList  "ТОРГ_16_1,ТОРГ_16_2":U

&global-define torg16xl-sheet1_valutCode       "ТОРГ_16_1_valutCode":U
&global-define torg16xl-sheet1_columnList      "ТОРГ_16_1_columnList":U
&global-define torg16xl-sheet1_columnType      "ТОРГ_16_1_columnType":U
&global-define torg16xl-sheet1_subtotalList    "ТОРГ_16_1_subtotalList":U
&global-define torg16xl-sheet1_subtotalType    "ТОРГ_16_1_subtotalType":U

&global-define torg16xl-sheet2_valutCode       "ТОРГ_16_2_valutCode":U
&global-define torg16xl-sheet2_columnList      "ТОРГ_16_2_columnList":U
&global-define torg16xl-sheet2_columnType      "ТОРГ_16_2_columnType":U
&global-define torg16xl-sheet2_subtotalList    "ТОРГ_16_2_subtotalList":U
&global-define torg16xl-sheet2_subtotalType    "ТОРГ_16_2_subtotalType":U


&global-define torg16xl-sheet1-name "ТОРГ_16_1":U

&global-define torg16xl-h_orgname     "h_orgname":U
&global-define torg16xl-h_obj         "h_obj":U
&global-define torg16xl-h_reason      "h_reason":U
&global-define torg16xl-h_TDocCode    "h_TDocCode":U
&global-define torg16xl-h_DocDate     "h_DocDate":U
&global-define torg16xl-h_t-okpo      "h_tokpo":U
&global-define torg16xl-hp_VAT1       "hp_VAT1":U
&global-define torg16xl-hp_DocInfo    "hp_DocInfo":U

&global-define torg16xl-sheet1-it-fact-qnty       "ТОРГ_16_1_it_FactQnty":U
&global-define torg16xl-sheet1-it-parts-cost      "ТОРГ_16_1_it_PartsCost":U
&global-define torg16xl-sheet1-it-parts-vat       "ТОРГ_16_1_it_PartsVat":U


&global-define torg16xl-sheet2-name "ТОРГ_16_2":U

&global-define torg16xl-hp_VAT2       "hp_VAT2":U
&global-define torg16xl-hp_VAT3       "hp_VAT3":U
&global-define torg16xl-hp_DocInfo2   "hp_DocInfo2":U
&global-define torg16xl-hp_DocInfo3   "hp_DocInfo3":U
/*&global-define torg16xl-hp_valut1     "hp_valut1":U*/
/*&global-define torg16xl-hp_valut2     "hp_valut2":U*/
&global-define torg16xl-sheet2-it-Tqnty             "ТОРГ_16_2_it_Tqnty":U
&global-define torg16xl-sheet2-it-parts-Stoimt      "ТОРГ_16_2_it_Stoim":U
&global-define torg16xl-sheet2-it-parts-StoimVat    "ТОРГ_16_2_it_StoimVat":U
&global-define torg16xl-f_sumstr        "f_sumstr":U

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
    field date-in       as character
    field fact-date     as character
    field in-code       as character
    field trn-fact-date as character
    field reason        as character

    index pi is primary unique
        xl-line-id
.
define temp-table temp_sheet2_line-data no-undo
    field sheet-name    as character
    field xl-line-id    as integer
    field gds-name      as character
    field tb-code       as character
    field unit-base     as character
    field okei          as character
    field tqnty         as character
    field mass-b        as character
    field mass-n        as character
    field price         as character
    field stoim         as character
    field gds-ps        as character

    index pi is primary unique
        xl-line-id
.

define variable v-torg16xl-sheet1-cur-data-row     as integer      no-undo.
define variable v-torg16xl-sheet2-cur-data-row     as integer      no-undo.
define variable v-torg16xl-cell-file-name       as character    no-undo.
define variable v-torg16xl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure torg16xl-init :

do
on error undo, return error
:
    assign
        v-torg16xl-sheet1-cur-data-row = 0
        v-torg16xl-sheet2-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-torg16xl-data-file-name
    ).
    output stream excel-line to value( v-torg16xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-torg16xl-cell-file-name
    ).
    output stream excel-cell to value( v-torg16xl-cell-file-name ).
    run torg16xl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&torg16xl-sheetList}
    ).

    if printrubl
    then do:
        run torg16xl-write-cell-data in this-procedure (
              input {&torg16xl-sheet1_valutCode}
            , input "0":U
        ).
        run torg16xl-write-cell-data in this-procedure (
              input {&torg16xl-sheet2_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run torg16xl-write-cell-data in this-procedure (
              input {&torg16xl-sheet1_valutCode}
            , input "1":U
        ).
        run torg16xl-write-cell-data in this-procedure (
              input {&torg16xl-sheet2_valutCode}
            , input "1":U
        ).
/*        run torg16xl-write-cell-data in this-procedure (*/
/*              input {&torg16xl-hp_valut1}*/
/*            , input "баз. вал.":U*/
/*        ).*/
/*        run torg16xl-write-cell-data in this-procedure (*/
/*              input {&torg16xl-hp_valut2}*/
/*            , input "баз. вал.":U*/
/*        ).*/
    end.
    run torg16xl-write-cell-data in this-procedure (
          input {&torg16xl-sheet1_columnList}
        , input "DateIn,FactDate,InCode,TrnFactDate,Reason":U
    ).
    run torg16xl-write-cell-data in this-procedure (
          input {&torg16xl-sheet1_columnType}
        , input "I,S,S,S,S":U
    ).
    run torg16xl-write-cell-data in this-procedure (
          input {&torg16xl-sheet1_subtotalList}
        , input "":U
    ).
    run torg16xl-write-cell-data in this-procedure (
          input {&torg16xl-sheet1_subtotalType}
        , input "":U
    ).
    run torg16xl-write-cell-data in this-procedure (
          input {&torg16xl-sheet2_columnList}
        , input "GdsName,TbCode,UnitBase,Okei,Tqnty,MassB,MassN,Price,Stoim,GdsPs":U
    ).
    run torg16xl-write-cell-data in this-procedure (
          input {&torg16xl-sheet2_columnType}
        , input "S,S,S,S,D,D,D,D,D,S":U
    ).
    run torg16xl-write-cell-data in this-procedure (
          input {&torg16xl-sheet2_subtotalList}
        , input "Tqnty,Stoim":U
    ).
    run torg16xl-write-cell-data in this-procedure (
          input {&torg16xl-sheet2_subtotalType}
        , input "S,S":U
    ).
end.
end procedure. /* torg16xl-init */

/*==========================================================================*/
procedure torg16xl-sheet1-write-line-data :
define input parameter p-date-in        as character        no-undo.
define input parameter p-fact-date      as character        no-undo.
define input parameter p-in-code        as character        no-undo.
define input parameter p-trn-fact-date  as character        no-undo.
define input parameter p-reason         as character        no-undo.

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
        v-torg16xl-sheet1-cur-data-row = v-torg16xl-sheet1-cur-data-row + 1
        buf_temp_sheet1_line-data.sheet-name    = {&torg16xl-sheet1-name}
        buf_temp_sheet1_line-data.xl-line-id    = v-torg16xl-sheet1-cur-data-row

        buf_temp_sheet1_line-data.date-in       = p-date-in
        buf_temp_sheet1_line-data.fact-date     = p-fact-date
        buf_temp_sheet1_line-data.in-code       = p-in-code
        buf_temp_sheet1_line-data.trn-fact-date = p-trn-fact-date
        buf_temp_sheet1_line-data.reason        = p-reason
    .
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        {&tabulation}   {&torg16xl-data-label}
        {&tabulation}   buf_temp_sheet1_line-data.date-in
        {&tabulation}   buf_temp_sheet1_line-data.fact-date
        {&tabulation}   buf_temp_sheet1_line-data.in-code
        {&tabulation}   buf_temp_sheet1_line-data.trn-fact-date
        {&tabulation}   buf_temp_sheet1_line-data.reason
        {&new-line}
    .
end.
end procedure. /* torg16xl-write-line-data */

/*==========================================================================*/
procedure torg16xl-sheet2-write-line-data :
define input parameter p-gds-name     as character        no-undo.
define input parameter p-tb-code      as character        no-undo.
define input parameter p-unit-base    as character        no-undo.
define input parameter p-okei         as character        no-undo.
define input parameter p-tqnty        as character        no-undo.
define input parameter p-mass-b       as character        no-undo.
define input parameter p-mass-n       as character        no-undo.
define input parameter p-price        as character        no-undo.
define input parameter p-stoim        as character        no-undo.
define input parameter p-gds-ps       as character        no-undo.


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
        v-torg16xl-sheet2-cur-data-row = v-torg16xl-sheet2-cur-data-row + 1
    .
    assign
        buf_temp_sheet2_line-data.sheet-name      = {&torg16xl-sheet2-name}
        buf_temp_sheet2_line-data.xl-line-id      = v-torg16xl-sheet2-cur-data-row
        buf_temp_sheet2_line-data.gds-name        = p-gds-name
        buf_temp_sheet2_line-data.tb-code         = p-tb-code
        buf_temp_sheet2_line-data.unit-base       = p-unit-base
        buf_temp_sheet2_line-data.okei            = p-okei
        buf_temp_sheet2_line-data.tqnty           = p-tqnty
        buf_temp_sheet2_line-data.mass-b          = p-mass-b
        buf_temp_sheet2_line-data.mass-n          = p-mass-n
        buf_temp_sheet2_line-data.price           = p-price
        buf_temp_sheet2_line-data.stoim           = p-stoim
        buf_temp_sheet2_line-data.gds-ps          = p-gds-ps
    .
    put stream excel-line unformatted
                        buf_temp_sheet2_line-data.sheet-name
        {&tabulation}   {&torg16xl-data-label}
        {&tabulation}   buf_temp_sheet2_line-data.gds-name
        {&tabulation}   buf_temp_sheet2_line-data.tb-code
        {&tabulation}   buf_temp_sheet2_line-data.unit-base
        {&tabulation}   buf_temp_sheet2_line-data.okei
        {&tabulation}   buf_temp_sheet2_line-data.tqnty
        {&tabulation}   buf_temp_sheet2_line-data.mass-b
        {&tabulation}   buf_temp_sheet2_line-data.mass-n
        {&tabulation}   buf_temp_sheet2_line-data.price
        {&tabulation}   buf_temp_sheet2_line-data.stoim
        {&tabulation}   buf_temp_sheet2_line-data.gds-ps
        {&new-line}
    .
end.
end procedure. /* torg16xl-write-line-data */

/*==========================================================================*/
procedure torg16xl-write-cell-data :
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
end procedure. /* torg16xl-write-cell-data */

/*==========================================================================*/
procedure torg16xl-run-excel :
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
        v-template-file-name    = search( "exe/torg16.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas")
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
end procedure. /* torg16xl-run-excel */


/*==========================================================================*/
procedure torg16xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/torg16.xlt":U.
        export "exe/t_form.bas":U.
        export v-torg16xl-cell-file-name.
        export v-torg16xl-data-file-name.
    output close.
end.
end procedure. /* torg16xl-close */

/* $Workfile$ e n d */