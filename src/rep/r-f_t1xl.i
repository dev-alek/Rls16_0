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

&global-define r-f_t1xl-sheetList  "Приложение_4":U
&global-define r-f_t1xl-sheet1_valutCode       "Приложение_4_valutCode":U
&global-define r-f_t1xl-sheet1_columnList      "Приложение_4_columnList":U
&global-define r-f_t1xl-sheet1_columnType      "Приложение_4_columnType":U
&global-define r-f_t1xl-sheet1_subtotalList    "Приложение_4_subtotalList":U
&global-define r-f_t1xl-sheet1_subtotalType    "Приложение_4_subtotalType":U

&global-define r-f_t1xl-sheet1-name   "T_1":U
&global-define r-f_t1xl-h_cargoToValue "h_cargoToValue":U
&global-define r-f_t1xl-h_cargoToValue1 "h_cargoToValue1":U
&global-define r-f_t1xl-h_cargoToValue-length 150
&global-define r-f_t1xl-h_docCode "h_docCode":U
&global-define r-f_t1xl-f_orgNameFrom "f_orgNameFrom":U
&global-define r-f_t1xl-h_addressFrom "h_addressFrom":U
&global-define r-f_t1xl-h_addressTo "h_addressTo":U
&global-define r-f_t1xl-h_orgFrom "h_orgFrom":U
&global-define r-f_t1xl-h_orgFrom1 "h_orgFrom1":U
&global-define r-f_t1xl-h_orgFrom-length 150
&global-define r-f_t1x1-h_manFromPos "h_manFromPos":U
&global-define r-f_t1xl-h_manFrom "h_manFrom":U
&global-define r-f_t1xl-h_manFrom1 "h_manFrom1":U
&global-define r-f_t1xl-h_manTo "h_manTo":U
&global-define r-f_t1xl-h_phoneFrom "h_phoneFrom":U
&global-define r-f_t1xl-h_phoneTo "h_phoneTo":U
&global-define r-f_t1xl-h_Date "h_Date":U
&global-define r-f_t1xl-h_cargoname "h_cargoname":U
&global-define r-f_t1xl-h_cargopack "h_cargopack":U
&global-define r-f_t1xl-h_cargopack1 "h_cargopack1":U
&global-define r-f_t1xl-h_cargoInfo "h_cargoInfo":U
&global-define r-f_t1xl-h_EI "h_EI":U
&global-define r-f_t1xl-h_EI1 "h_EI1":U
&global-define r-f_t1xl-h_placeAmount "h_placeAmount":U
&global-define r-f_t1xl-h_placeAmount1 "h_placeAmount1":U
&global-define r-f_t1xl-h_placeAmount2 "h_placeAmount2":U
&global-define r-f_t1xl-h_addrFrom "h_addrFrom":U
&global-define r-f_t1xl-h_addrTo "h_addrTo":U
&global-define r-f_t1xl-h_massBruttoNetto "h_massBruttoNetto":U
&global-define r-f_t1xl-h_sumStr "h_sumStr":U
&global-define r-f_t1xl-h_lableSum "h_lableSum":U
&global-define r-f_t1xl-h_massNetto "h_massNetto":U
&global-define r-f_t1xl-h_massNetto1 "h_massNetto1":U
&global-define r-f_t1xl-it_sum "it_sum":U
&global-define r-f_t1xl-it_sum1 "it_sum1":U

&global-define r-f_t1xl-h_driver "h_driver":U
&global-define r-f_t1xl-f_driver "f_driver":U
&global-define r-f_t1xl-f_automark "f_automark":U
&global-define r-f_t1xl-h_autonum "f_autonum":U
&global-define r-f_t1xl-f_orgNameFrom "f_orgNameFrom":U
&global-define r-f_t1xl-f_manFromDate "f_manFromDate":U



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
define variable v-r-f_t1xl-cell-file-name       as character    no-undo.
define variable v-r-f_t1xl-data-file-name       as character    no-undo.


/*==========================================================================*/
procedure r-f_t1xl-init :

do
on error undo, return error
:
    assign
        v-r-f_t1xl-sheet1-cur-data-row = 0
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
    end.
    else do:
        run r-f_t1xl-write-cell-data in this-procedure (
              input {&r-f_t1xl-sheet1_valutCode}
            , input "1":U
        ).
    end.
/*    run r-f_t1xl-write-cell-data in this-procedure (*/
/*          input {&r-f_t1xl-sheet1_columnList}*/
/*        , input "ID,Name,art,EI,pack,PlaceAmount,Mass,qnty,price,sum":U*/
/*    ).*/
/*    run r-f_t1xl-write-cell-data in this-procedure (*/
/*          input {&r-f_t1xl-sheet1_columnType}*/
/*        , input "I,S,S,S,S,D,D,D,C,C":U*/
/*    ).*/
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
    if lookup( "TOPAUKC":U, p-mode ) <> 0
    then do:
      assign
        v-template-file-name    = search( "exe/ttnbb.xlt" )
      .
    end.
    else do:
      assign
        v-template-file-name    = search( "exe/ttn.xlt" )
      .
    end.
    assign
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
        if lookup( "TOPAUKC":U, p-mode ) <> 0
        then do:
          export "exe/ttnbb.xlt":U.
        end.
        else do:
          export "exe/ttn.xlt":U.
        end.
        export "exe/t_form.bas":U.
        export v-r-f_t1xl-cell-file-name.
        export v-r-f_t1xl-data-file-name.
    output close.
end.
end procedure. /* r-f_t1xl-close */
/* $Workfile$ e n d */