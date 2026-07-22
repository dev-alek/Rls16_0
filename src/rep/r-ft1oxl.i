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

&global-define r-f_t1xl-data-label "DTA":U
&global-define r-f_t1xl-format-label "FMT":U

&global-define r-f_t1xl-sheetList  "T_1,Оборот.сторона":U
&global-define r-f_t1xl-sheet1_valutCode       "T_1_valutCode":U
&global-define r-f_t1xl-sheet1_columnList      "T_1_columnList":U
&global-define r-f_t1xl-sheet1_columnType      "T_1_columnType":U
&global-define r-f_t1xl-sheet1_subtotalList    "T_1_subtotalList":U
&global-define r-f_t1xl-sheet1_subtotalType    "T_1_subtotalType":U

&global-define r-f_t1xl-sheet2_valutCode       "Оборот.сторона_valutCode":U
&global-define r-f_t1xl-sheet2_columnList      "Оборот.сторона_columnList":U
&global-define r-f_t1xl-sheet2_columnType      "Оборот.сторона_columnType":U
&global-define r-f_t1xl-sheet2_subtotalList    "Оборот.сторона_subtotalList":U
&global-define r-f_t1xl-sheet2_subtotalType    "Оборот.сторона_subtotalType":U



&global-define r-f_t1xl-h_cargoTo "h_cargoTo":U
&global-define r-f_t1xl-h_cargoToValue "h_cargoToValue":U
&global-define r-f_t1xl-h_cliFrom "h_cliFrom":U
&global-define r-f_t1xl-h_docCode "h_docCode":U
&global-define r-f_t1xl-h_saler "h_saler":U

&global-define r-f_t1xl-h_docDate "h_docDate":U
&global-define r-f_t1xl-h_tbl_docCode "h_tbl_docCode":U
&global-define r-f_t1xl-h_tbl_docDate "h_tbl_docDate":U
&global-define r-f_t1xl-h_OKPO_0 "h_OKPO_0":U
&global-define r-f_t1xl-h_OKPO "h_OKPO":U
&global-define r-f_t1xl-h_OKPO2 "h_OKPO2":U
&global-define r-f_t1xl-h_OKPO3 "h_OKPO3":U
&global-define r-f_t1xl-h_operationType "h_operationType":U
&global-define r-f_t1xl-h_orgFrom "h_orgFrom":U
&global-define r-f_t1xl-h_reason "h_reason":U
&global-define r-f_t1xl-h_reason_date "h_reason_date":U
&global-define r-f_t1xl-h_reason_num "h_reason_num":U
&global-define r-f_t1xl-h_supplier "h_supplier":U

&global-define r-f_t1xl-margin "margin":U

&global-define r-f_t1xl-sheet1-name   "T_1":U
&global-define r-f_t1xl-f_buhName "f_buhName":U
&global-define r-f_t1xl-f_lineAmount "f_lineAmount":U
&global-define r-f_t1xl-f_massBrutto "f_massBrutto":U
&global-define r-f_t1xl-f_massNetto "f_massNetto":U
&global-define r-f_t1xl-f_massNettoSTR "f_massNettoSTR":U
&global-define r-f_t1xl-f_massBruttoSTR "f_massBruttoSTR":U
&global-define r-f_t1xl-f_pageAmount "f_pageAmount":U
&global-define r-f_t1xl-f_permitterName "f_permitterName":U
&global-define r-f_t1xl-f_permitterStatus "f_permitterStatus":U
&global-define r-f_t1xl-f_sumLiteral1 "f_sumLiteral1":U
&global-define r-f_t1xl-f_sumLiteral2 "f_sumLiteral2":U
&global-define r-f_t1xl-f_exptrans "f_exptrans":U
&global-define r-f_t1xl-f_qntyname "f_qntyname":U
&global-define r-f_t1xl-f_placeAmount "f_placeAmount":U
&global-define r-f_t1xl-it_qnty "it_qnty":U
&global-define r-f_t1xl-it_SumNoVAT "it_SumNoVAT":U
&global-define r-f_t1xl-it_VATsum "it_VATsum":U
&global-define r-f_t1xl-it_sum "it_sum":U
&global-define r-f_t1xl-f_sumLiteral1-length 500
&global-define r-f_t1xl-h_from_to_uderline "h_from_to_uderline"
&global-define r-f_t1xl-f_post "f_post"
&global-define r-f_t1xl-f_wkr_name "f_wkr_name"
&global-define r-f_t1xl-f_exptrans "f_exptrans"
&global-define r-f_t1xl-N_warrant_char "N_warrant_char"
&global-define r-f_t1xl-Day_warrant "Day_warrant"
&global-define r-f_t1xl-Date_warrant "Date_warrant"
&global-define r-f_t1xl-accept_position "accept_position"
&global-define r-f_t1xl-accept_fname "accept_fname"
&global-define r-f_t1xl-N_ndovwho "N_ndovwho"
&global-define r-f_t1xl-loadtplace "loadtplace"
&global-define r-f_t1xl-loadtname "loadtname"
&global-define r-f_t1xl-h_osn_doc_code "h_osn_doc_code"
&global-define r-f_t1xl-h_osn_doc_date "h_osn_doc_date"

&global-define r-f_t1xl-sheet2-name "Оборот.сторона":U
&global-define r-f_t1xl-h_driver "f_driver":U
&global-define r-f_t1xl-h_carrytype "f_carrytype":U
&global-define r-f_t1xl-h_automark "f_automark":U
&global-define r-f_t1xl-h_autonum "f_autonum":U
&global-define r-f_t1xl-h_cargoname "h_cargoname":U
&global-define r-f_t1xl-h_cargopack "h_cargopack":U
&global-define r-f_t1xl-h_placeAmount "h_placeAmount":U
&global-define r-f_t1xl-h_addrFrom "h_addrFrom":U
&global-define r-f_t1xl-h_addrTo "h_addrTo":U
&global-define r-f_t1xl-h_saler1 "h_saler1":U
&global-define r-f_t1xl-h_massBrutto "h_massBrutto":U
&global-define r-f_t1xl-h_massBrutto1 "h_massBrutto1":U
&global-define r-f_t1xl-h_massBruttoSTR "h_massBruttoSTR":U
&global-define r-f_t1xl-h_post "f_post1"
&global-define r-f_t1xl-h_wkr_name "f_wkr_name1"



define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.
define temp-table temp_sheet1_line-data no-undo
    field sheet-name    as character
    field xl-line-id   as integer
    field ID           as integer
    field Name         as character
    field art          as character
    field EI           as character
    field pack         as character
    field PlaceAmount  as character
    field Mass         as character
    field qnty         as character
    field price        as character
    field sum          as character

    index pi is primary unique xl-line-id
.

define variable v-r-f_t1xl-sheet1-cur-data-row  as integer      no-undo.
define variable v-r-f_t1xl-sheet2-cur-data-row  as integer      no-undo.
define variable v-r-f_t1xl-cell-file-name       as character    no-undo.
define variable v-r-f_t1xl-data-file-name       as character    no-undo.


/*==========================================================================*/
procedure r-f_t1xl-init :

do
on error undo, return error
:
    assign
        v-r-f_t1xl-sheet1-cur-data-row = 0
        v-r-f_t1xl-sheet2-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-r-f_t1xl-data-file-name
    ).
    output stream excel-line to value( v-r-f_t1xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-r-f_t1xl-cell-file-name
    ).
    output stream excel-cell to value( v-r-f_t1xl-cell-file-name ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&r-f_t1xl-sheetList}
    ).
    if printrubl
    then do:
        run r-f_t1xl-write-cell-data in this-procedure (
              input {&r-f_t1xl-sheet1_valutCode}
            , input "0":U
        ).
        run r-f_t1xl-write-cell-data in this-procedure (
              input {&r-f_t1xl-sheet2_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run r-f_t1xl-write-cell-data in this-procedure (
              input {&r-f_t1xl-sheet1_valutCode}
            , input "1":U
        ).
        run r-f_t1xl-write-cell-data in this-procedure (
              input {&r-f_t1xl-sheet2_valutCode}
            , input "1":U
        ).
    end.
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-sheet1_columnList}
        , input "ID,Name,art,EI,pack,PlaceAmount,Mass,qnty,price,sum":U
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-sheet1_columnType}
        , input "I,S,S,S,S,D,D,D,C,C":U
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-sheet2_columnList}
        , input "":U
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-sheet2_columnType}
        , input "":U
    ).

    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-sheet2_subtotalList}
        , input "":U
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-sheet2_subtotalType}
        , input "":U
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-sheet1_subtotalList}
        , input "":U
    ).
    run r-f_t1xl-write-cell-data in this-procedure (
          input {&r-f_t1xl-sheet1_subtotalType}
        , input "":U
    ).
end.
end procedure. /* r-f_t1xl-init */

/*==========================================================================*/
procedure r-f_t1xl-sheet1-write-line-data :



define input parameter p-ID             as integer          no-undo.
define input parameter p-Name           as character        no-undo.
define input parameter p-art            as character        no-undo.
define input parameter p-EI             as character        no-undo.
define input parameter p-pack           as character        no-undo.
define input parameter p-PlaceAmount    as character        no-undo.
define input parameter p-Mass           as character        no-undo.
define input parameter p-qnty           as character        no-undo.
define input parameter p-price          as character        no-undo.
define input parameter p-sum            as character        no-undo.

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
        v-r-f_t1xl-sheet1-cur-data-row         = v-r-f_t1xl-sheet1-cur-data-row + 1
        buf_temp_sheet1_line-data.sheet-name    = {&r-f_t1xl-sheet1-name}
        buf_temp_sheet1_line-data.xl-line-id    = v-r-f_t1xl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.id           = p-id
        buf_temp_sheet1_line-data.Name         = p-Name
        buf_temp_sheet1_line-data.art          = p-art
        buf_temp_sheet1_line-data.EI           = p-EI
        buf_temp_sheet1_line-data.pack         = p-pack
        buf_temp_sheet1_line-data.PlaceAmount  = p-PlaceAmount
        buf_temp_sheet1_line-data.Mass         = p-Mass
        buf_temp_sheet1_line-data.qnty         = p-qnty
        buf_temp_sheet1_line-data.price        = p-price
        buf_temp_sheet1_line-data.sum          = p-sum
    .
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        {&tabulation}   {&r-f_t1xl-data-label}
        {&tabulation}   ( if buf_temp_sheet1_line-data.id = 0 then "":U else string( buf_temp_sheet1_line-data.id ) )
        {&tabulation}   buf_temp_sheet1_line-data.Name
        {&tabulation}   buf_temp_sheet1_line-data.art
        {&tabulation}   buf_temp_sheet1_line-data.EI
        {&tabulation}   buf_temp_sheet1_line-data.pack
        {&tabulation}   buf_temp_sheet1_line-data.PlaceAmount
        {&tabulation}   buf_temp_sheet1_line-data.Mass
        {&tabulation}   buf_temp_sheet1_line-data.qnty
        {&tabulation}   buf_temp_sheet1_line-data.price
        {&tabulation}   buf_temp_sheet1_line-data.sum
        {&new-line}
    .
end.
end procedure. /* r-f_t1xl-sheet1-write-line-data */


/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure r-f_t1xl-write-cell-data :
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
end procedure. /* r-f_t1xl-write-cell-data */

/*==========================================================================*/
procedure r-f_t1xl-run-excel :
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
        v-template-file-name    = search( "exe/T_1.xlt" )
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
end procedure. /* r-f_t1xl-run-excel */


/*==========================================================================*/
procedure r-f_t1xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/T_1.xlt":U.
        export "exe/t_form.bas":U.
        export v-r-f_t1xl-cell-file-name.
        export v-r-f_t1xl-data-file-name.
    output close.
end.
end procedure. /* r-f_t1xl-close */
/* $Workfile$ e n d */