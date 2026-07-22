/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Белоусов Илья Александрович
Дата создания: 09/18/07
Author: Ilia Belousov
Creation date: 09/18/07

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define r-plc-xl-sheetList        "Контроль,Сверки":U
&global-define r-plc-xl-line-data-key    "LD":U

&global-define r-plc-xl-sheet1_valutCode       "Контроль_valutCode":U
&global-define r-plc-xl-sheet1_columnList      "Контроль_columnList":U
&global-define r-plc-xl-sheet1_columnType      "Контроль_columnType":U
&global-define r-plc-xl-sheet1_subtotalList    "Контроль_subtotalList":U
&global-define r-plc-xl-sheet1_subtotalType    "Контроль_subtotalType":U

&global-define r-plc-xl-sheet2_valutCode       "Сверки_valutCode":U
&global-define r-plc-xl-sheet2_columnList      "Сверки_columnList":U
&global-define r-plc-xl-sheet2_columnType      "Сверки_columnType":U
&global-define r-plc-xl-sheet2_subtotalList    "Сверки_subtotalList":U
&global-define r-plc-xl-sheet2_subtotalType    "Сверки_subtotalType":U

&global-define r-plc-xl-objname       "objname":U
&global-define r-plc-xl-rep_num       "rep_num":U
&global-define r-plc-xl-staff         "staff":U
&global-define r-plc-xl-staff_prev    "staff_prev":U
&global-define r-plc-xl-date_begin    "date_begin":U
&global-define r-plc-xl-date_end      "date_end":U
&global-define r-plc-xl-f_date        "f_date":U
&global-define r-plc-xl-f_time        "f_time":U

&global-define r-plc-xl-sheet1-name "Контроль":U
&global-define r-plc-xl-sheet2-name "Сверки":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define temp-table temp_sheet1_line-data no-undo
    field sheet-name          as character
    field xl-line-id          as integer
    field loc1                as character
    field state-measure-qnty  as character
    field state-level-total   as character
    field state-temperature   as character
    field state-dencity       as character
    field average-dencity     as character

    index pi is primary unique
        xl-line-id
.
define temp-table temp_sheet2_line-data no-undo
    field sheet-name           as character
    field xl-line-id           as integer
    field counter              as character
    field fact-date            as character
    field fact-time            as character
    field loc1                 as character
    field gds-name             as character
    field rvs-type-outside     as character
    field state-measure-qnty   as character
    field state-level-total    as character
    field state-temperature    as character
    field state-dencity        as character
    field attr_                as character

    index pi is primary unique
        xl-line-id
.

define variable v-r-plc-xl-sheet1-cur-data-row  as integer      no-undo.
define variable v-r-plc-xl-sheet2-cur-data-row  as integer      no-undo.
define variable v-r-plc-xl-cell-file-name       as character    no-undo.
define variable v-r-plc-xl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure r-plc-xl-init :

do
on error undo, return error
:
    assign
        v-r-plc-xl-sheet1-cur-data-row = 0
        v-r-plc-xl-sheet2-cur-data-row = 0
    .
    run gbl/_tmpfile.p
        ( input "xd"
        , input ".txt"
        , output v-r-plc-xl-data-file-name
    ).
    output stream excel-line to value( v-r-plc-xl-data-file-name ).
    run gbl/_tmpfile.p
        ( input "xc"
        , input ".txt"
        , output v-r-plc-xl-cell-file-name
    ).
    output stream excel-cell to value( v-r-plc-xl-cell-file-name ).
    run r-plc-xl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&r-plc-xl-sheetList}
    ).
    run r-plc-xl-write-cell-data in this-procedure (
          input {&r-plc-xl-sheet1_valutCode}
        , input "0":U
    ).
    run r-plc-xl-write-cell-data in this-procedure (
          input {&r-plc-xl-sheet1_columnList}
        , input "loc1,state_measure_qnty,state_level_total,state_temperature,state_dencity,average_dencity":U
    ).
    run r-plc-xl-write-cell-data in this-procedure (
          input {&r-plc-xl-sheet1_columnType}
        , input "S,S,S,S,S,S":U
    ).
    run r-plc-xl-write-cell-data in this-procedure (
          input {&r-plc-xl-sheet1_subtotalList}
        , input "":U
    ).
    run r-plc-xl-write-cell-data in this-procedure (
          input {&r-plc-xl-sheet1_subtotalType}
        , input "":U
    ).
    run r-plc-xl-write-cell-data in this-procedure (
          input {&r-plc-xl-sheet2_valutCode}
        , input "0":U
    ).
    run r-plc-xl-write-cell-data in this-procedure (
          input {&r-plc-xl-sheet2_columnList}
        , input "counter,fact_date,fact_time,loc1,gds_name,rvs_type_outside,state_measure_qnty,state_level_total,state_temperature,state_dencity,attr_":U
    ).
    run r-plc-xl-write-cell-data in this-procedure (
          input {&r-plc-xl-sheet2_columnType}
        , input "S,S,S,S,S,S,S,S,S,S,S,S":U
    ).
    run r-plc-xl-write-cell-data in this-procedure (
          input {&r-plc-xl-sheet2_subtotalList}
        , input "":U
    ).
    run r-plc-xl-write-cell-data in this-procedure (
          input {&r-plc-xl-sheet2_subtotalType}
        , input "":U
    ).
end.
end procedure. /* r-plc-xl-init */

/*==========================================================================*/
procedure r-plc-xl-sheet1-write-line-data :
define input parameter p-loc1                 as character        no-undo.
define input parameter p-state-measure-qnty   as character        no-undo.
define input parameter p-state-level-total    as character        no-undo.
define input parameter p-state-temperature    as character        no-undo.
define input parameter p-state-dencity        as character        no-undo.
define input parameter p-average-dencity      as character        no-undo.

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
        v-r-plc-xl-sheet1-cur-data-row = v-r-plc-xl-sheet1-cur-data-row + 1
    .
    assign
        buf_temp_sheet1_line-data.sheet-name          = {&r-plc-xl-sheet1-name}
        buf_temp_sheet1_line-data.xl-line-id          = v-r-plc-xl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.loc1                = p-loc1
        buf_temp_sheet1_line-data.state-measure-qnty  = p-state-measure-qnty
        buf_temp_sheet1_line-data.state-level-total   = p-state-level-total
        buf_temp_sheet1_line-data.state-temperature   = p-state-temperature
        buf_temp_sheet1_line-data.state-dencity       = p-state-dencity
        buf_temp_sheet1_line-data.average-dencity     = p-average-dencity
    .
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        {&tabulation}   {&r-plc-xl-line-data-key}
        {&tabulation}   buf_temp_sheet1_line-data.loc1
        {&tabulation}   buf_temp_sheet1_line-data.state-measure-qnty
        {&tabulation}   buf_temp_sheet1_line-data.state-level-total
        {&tabulation}   buf_temp_sheet1_line-data.state-temperature
        {&tabulation}   buf_temp_sheet1_line-data.state-dencity
        {&tabulation}   buf_temp_sheet1_line-data.average-dencity
        {&new-line}
    .
end.
end procedure. /* r-plc-xl-write-line-data */

/*==========================================================================*/
procedure r-plc-xl-sheet2-write-line-data :
define input parameter p-counter               as character        no-undo.
define input parameter p-fact-date             as character        no-undo.
define input parameter p-fact-time             as character        no-undo.
define input parameter p-loc1                  as character        no-undo.
define input parameter p-gds-name              as character        no-undo.
define input parameter p-rvs-type-outside      as character        no-undo.
define input parameter p-state-measure-qnty    as character        no-undo.
define input parameter p-state-level-total     as character        no-undo.
define input parameter p-state-temperature     as character        no-undo.
define input parameter p-state-dencity         as character        no-undo.
define input parameter p-attr_                 as character        no-undo.

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
        v-r-plc-xl-sheet2-cur-data-row = v-r-plc-xl-sheet2-cur-data-row + 1
    .
    assign
        buf_temp_sheet2_line-data.sheet-name          = {&r-plc-xl-sheet2-name}
        buf_temp_sheet2_line-data.xl-line-id          = v-r-plc-xl-sheet2-cur-data-row
        buf_temp_sheet2_line-data.counter             = p-counter
        buf_temp_sheet2_line-data.fact-date           = p-fact-date
        buf_temp_sheet2_line-data.fact-time           = p-fact-time
        buf_temp_sheet2_line-data.loc1                = p-loc1
        buf_temp_sheet2_line-data.gds-name            = p-gds-name
        buf_temp_sheet2_line-data.rvs-type-outside    = p-rvs-type-outside
        buf_temp_sheet2_line-data.state-measure-qnty  = p-state-measure-qnty
        buf_temp_sheet2_line-data.state-level-total   = p-state-level-total
        buf_temp_sheet2_line-data.state-temperature   = p-state-temperature
        buf_temp_sheet2_line-data.state-dencity       = p-state-dencity
        buf_temp_sheet2_line-data.attr_               = p-attr_
    .
    put stream excel-line unformatted
                        buf_temp_sheet2_line-data.sheet-name
        {&tabulation}   {&r-plc-xl-line-data-key}
        {&tabulation}   buf_temp_sheet2_line-data.counter
        {&tabulation}   buf_temp_sheet2_line-data.fact-date
        {&tabulation}   buf_temp_sheet2_line-data.fact-time
        {&tabulation}   buf_temp_sheet2_line-data.loc1
        {&tabulation}   buf_temp_sheet2_line-data.gds-name
        {&tabulation}   buf_temp_sheet2_line-data.rvs-type-outside
        {&tabulation}   buf_temp_sheet2_line-data.state-measure-qnty
        {&tabulation}   buf_temp_sheet2_line-data.state-level-total
        {&tabulation}   buf_temp_sheet2_line-data.state-temperature
        {&tabulation}   buf_temp_sheet2_line-data.state-dencity
        {&tabulation}   buf_temp_sheet2_line-data.attr_
        {&new-line}
    .
end.
end procedure. /* r-plc-xl-write-line-data */



/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure r-plc-xl-write-cell-data :
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
end procedure. /* r-plc-xl-write-cell-data */

/*==========================================================================*/
procedure r-plc-xl-run-excel :
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
        v-template-file-name    = search( "exe/plcsht.xlt" )
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
end procedure. /* r-plc-xl-run-excel */


/*==========================================================================*/
procedure r-plc-xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/plcsht.xlt":U.
        export "exe/t_form.bas":U.
        export v-r-plc-xl-cell-file-name.
        export v-r-plc-xl-data-file-name.
    output close.
end.
end procedure. /* r-plc-xl-close */

/* $Workfile$ e n d */