/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы Декларация об объемах розничной продажи алкогольной продукции (Псков) в Excel

Автор: Хныкин Павел Андреевич
Дата создания: 09/20/07
Author: Pavel Khnykin
Creation date: 09/20/07

Required: { p a r a m l s . i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define kfrebaxl-data-label "DTA":U
&global-define kfrebaxl-format-label "FMT":U

&global-define kfrebaxl-sheetList  "Лист1":U

&global-define kfrebaxl-sheet1_valutCode       "Лист1_valutCode":U
&global-define kfrebaxl-sheet1_columnList      "Лист1_columnList":U
&global-define kfrebaxl-sheet1_columnType      "Лист1_columnType":U
&global-define kfrebaxl-sheet1_subtotalList    "Лист1_subtotalList":U
&global-define kfrebaxl-sheet1_subtotalType    "Лист1_subtotalType":U

&global-define kfrebaxl-h_date "h_date":U
&global-define kfrebaxl-h_obj  "h_obj":U

&global-define kfrebaxl-sheet1-name "Лист1":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.

define temp-table temp_sheet1_line-data no-undo
    field sheet-name                  as character
    field xl-line-id                  as integer
    field pump-code                   like ub.rvs-line-pump.pump-code
    field gds-name                    as character
    field prev-state-measure-qnty     as decimal
    field fact-qnty                   as decimal
    field end-state-el-cnt            as decimal
    field begin-state-el-cnt          as decimal
    field sale-state-el-cnt           as decimal
    field end-state-mh-cnt            as decimal
    field begin-state-mh-cnt          as decimal
    field sale-state-mh-cnt           as decimal
    field state-divergence            as decimal
    field sale-state                  as decimal
    field sale-techfuel               as decimal
    field sale-total                  as decimal
    field place-loc1                  like ub.place.loc1
    field fact-ost-measure-qnty       as decimal
    field fact-ost-state-measure-qnty as decimal
    field end-system-qnty             as decimal
    field fact-divergence             as decimal
index pi is primary unique
        xl-line-id
.


define variable v-kfrebaxl-sheet1-cur-data-row  as integer      no-undo.
define variable v-kfrebaxl-cell-file-name       as character    no-undo.
define variable v-kfrebaxl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure kfrebaxl-init :

do
on error undo, return error
:
    assign
        v-kfrebaxl-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-kfrebaxl-data-file-name
    ).
    output stream excel-line to value( v-kfrebaxl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-kfrebaxl-cell-file-name
    ).
    output stream excel-cell to value( v-kfrebaxl-cell-file-name ).
    run kfrebaxl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&kfrebaxl-sheetList}
    ).
    if printrubl
    then do:
        run kfrebaxl-write-cell-data in this-procedure (
              input {&kfrebaxl-sheet1_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run kfrebaxl-write-cell-data in this-procedure (
              input {&kfrebaxl-sheet1_valutCode}
            , input "1":U
        ).
    end.
    run kfrebaxl-write-cell-data in this-procedure (
          input {&kfrebaxl-sheet1_columnList}
        , input "gds_name,prev_state_measure_qnty,fact_qnty,pump_code,end_state_el_cnt,begin_state_el_cnt,sale_state_el_cnt,end_state_mh_cnt,begin_state_mh_cnt,sale_state_mh_cnt,state_divergence,sale_state,sale_techfuel,sale_total,place_loc1,fact_ost_measure_qnty,fact_ost_state_measure_qnty,end_system_qnty,fact_divergence":U
    ).
    run kfrebaxl-write-cell-data in this-procedure (
          input {&kfrebaxl-sheet1_columnType}
        , input "S,D,D,I,D,D,D,D,D,D,D,D,D,D,S,D,D,D,D":U
    ). /*  "S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S":U */
    run kfrebaxl-write-cell-data in this-procedure (
          input {&kfrebaxl-sheet1_subtotalList}
        , input "":U
    ).
    run kfrebaxl-write-cell-data in this-procedure (
          input {&kfrebaxl-sheet1_subtotalType}
        , input "":U
    ).
end.
end procedure. /* kfrebaxl-init */

/*==========================================================================*/
procedure kfrebaxl-sheet1-write-line-data :
  define input  parameter p-pump-code                   like ub.rvs-line-pump.pump-code no-undo .
  define input  parameter p-gds-name                    as character                    no-undo .
  define input  parameter p-prev-state-measure-qnty     as decimal                      no-undo .
  define input  parameter p-fact-qnty                   as decimal                      no-undo .
  define input  parameter p-end-state-el-cnt            as decimal                      no-undo .
  define input  parameter p-begin-state-el-cnt          as decimal                      no-undo .
  define input  parameter p-sale-state-el-cnt           as decimal                      no-undo .
  define input  parameter p-end-state-mh-cnt            as decimal                      no-undo .
  define input  parameter p-begin-state-mh-cnt          as decimal                      no-undo .
  define input  parameter p-sale-state-mh-cnt           as decimal                      no-undo .
  define input  parameter p-state-divergence            as decimal                      no-undo .
  define input  parameter p-sale-state                  as decimal                      no-undo .
  define input  parameter p-sale-techfuel               as decimal                      no-undo .
  define input  parameter p-sale-total                  as decimal                      no-undo .
  define input  parameter p-place-loc1                  like ub.place.loc1              no-undo .
  define input  parameter p-fact-ost-measure-qnty       as decimal                      no-undo .
  define input  parameter p-fact-ost-state-measure-qnty as decimal                      no-undo .
  define input  parameter p-end-system-qnty             as decimal                      no-undo .
  define input  parameter p-fact-divergence             as decimal                      no-undo .

define buffer buf_temp_sheet1_line-data  for temp_sheet1_line-data.

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
        v-kfrebaxl-sheet1-cur-data-row                        = v-kfrebaxl-sheet1-cur-data-row + 1
        buf_temp_sheet1_line-data.sheet-name                  = {&kfrebaxl-sheet1-name}
        buf_temp_sheet1_line-data.xl-line-id                  = v-kfrebaxl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.pump-code                   = p-pump-code
        buf_temp_sheet1_line-data.gds-name                    = p-gds-name
        buf_temp_sheet1_line-data.prev-state-measure-qnty     = p-prev-state-measure-qnty
        buf_temp_sheet1_line-data.fact-qnty                   = p-fact-qnty
        buf_temp_sheet1_line-data.end-state-el-cnt            = p-end-state-el-cnt
        buf_temp_sheet1_line-data.begin-state-el-cnt          = p-begin-state-el-cnt
        buf_temp_sheet1_line-data.sale-state-el-cnt           = p-sale-state-el-cnt
        buf_temp_sheet1_line-data.end-state-mh-cnt            = p-end-state-mh-cnt
        buf_temp_sheet1_line-data.begin-state-mh-cnt          = p-begin-state-mh-cnt
        buf_temp_sheet1_line-data.sale-state-mh-cnt           = p-sale-state-mh-cnt
        buf_temp_sheet1_line-data.state-divergence            = p-state-divergence
        buf_temp_sheet1_line-data.sale-state                  = p-sale-state
        buf_temp_sheet1_line-data.sale-techfuel               = p-sale-techfuel
        buf_temp_sheet1_line-data.sale-total                  = p-sale-total
        buf_temp_sheet1_line-data.place-loc1                  = p-place-loc1
        buf_temp_sheet1_line-data.fact-ost-measure-qnty       = p-fact-ost-measure-qnty
        buf_temp_sheet1_line-data.fact-ost-state-measure-qnty = p-fact-ost-state-measure-qnty
        buf_temp_sheet1_line-data.end-system-qnty             = p-end-system-qnty
        buf_temp_sheet1_line-data.fact-divergence             = p-fact-divergence
    .

    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        {&tabulation}   {&kfrebaxl-data-label}
        {&tabulation}   buf_temp_sheet1_line-data.gds-name
        {&tabulation}   /*trim(replace(replace(string(*/ buf_temp_sheet1_line-data.prev-state-measure-qnty /*) , ',' , '') , '.' , ',' ))*/
        {&tabulation}   /*trim(replace(replace(string(*/ buf_temp_sheet1_line-data.fact-qnty /*) , ',' , '') , '.' , ',' ))*/
        {&tabulation}   buf_temp_sheet1_line-data.pump-code
        {&tabulation}   /*trim(replace(replace(string(*/  buf_temp_sheet1_line-data.end-state-el-cnt /*) , ',' , '') , '.' , ',' ))*/
        {&tabulation}   /*trim(replace(replace(string(*/  buf_temp_sheet1_line-data.begin-state-el-cnt /*) , ',' , '') , '.' , ',' ))*/
        {&tabulation}   /*trim(replace(replace(string(*/  buf_temp_sheet1_line-data.sale-state-el-cnt /*) , ',' , '') , '.' , ',' ))*/
        {&tabulation}   /*trim(replace(replace(string(*/  buf_temp_sheet1_line-data.end-state-mh-cnt /*) , ',' , '') , '.' , ',' ))*/
        {&tabulation}   /*trim(replace(replace(string(*/  buf_temp_sheet1_line-data.begin-state-mh-cnt /*) , ',' , '') , '.' , ',' ))*/
        {&tabulation}   /*trim(replace(replace(string(*/  buf_temp_sheet1_line-data.sale-state-mh-cnt /*) , ',' , '') , '.' , ',' ))*/
        {&tabulation}   /*trim(replace(replace(string(*/  buf_temp_sheet1_line-data.state-divergence /*) , ',' , '') , '.' , ',' ))*/
        {&tabulation}   /*trim(replace(replace(string(*/  buf_temp_sheet1_line-data.sale-state /*) , ',' , '') , '.' , ',' ))*/
        {&tabulation}   /*trim(replace(replace(string(*/  buf_temp_sheet1_line-data.sale-techfuel /*) , ',' , '') , '.' , ',' ))*/
        {&tabulation}   /*trim(replace(replace(string(*/  buf_temp_sheet1_line-data.sale-total /*) , ',' , '') , '.' , ',' ))*/
        {&tabulation}   buf_temp_sheet1_line-data.place-loc1
        {&tabulation}   /*trim(replace(replace(string(*/  buf_temp_sheet1_line-data.fact-ost-measure-qnty /*) , ',' , '') , '.' , ',' ))*/
        {&tabulation}   /*trim(replace(replace(string(*/  buf_temp_sheet1_line-data.fact-ost-state-measure-qnty /*) , ',' , '') , '.' , ',' ))*/
        {&tabulation}   /*trim(replace(replace(string(*/  buf_temp_sheet1_line-data.end-system-qnty /*) , ',' , '') , '.' , ',' ))*/
        {&tabulation}   /*trim(replace(replace(string(*/  buf_temp_sheet1_line-data.fact-divergence /*) , ',' , '') , '.' , ',' ))*/
        {&new-line}
    .
end.
end procedure. /* kfrebaxl-sheet1-write-line-data */

/*==========================================================================*/
procedure kfrebaxl-sheet1-write-line-format :
define input parameter p-fmt-label       as character  no-undo.


    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        {&kfrebaxl-sheet1-name}
        {&tabulation}   {&kfrebaxl-format-label}
        {&tabulation}   p-fmt-label
        {&new-line}
    .
end.
end procedure. /* kfrebaxl-sheet1-write-line-format */


/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure kfrebaxl-write-cell-data :
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
end procedure. /* kfrebaxl-write-cell-data */

/*==========================================================================*/
procedure kfrebaxl-run-excel :
define input parameter p-header-filename    as character        no-undo.
define input parameter p-data-filename      as character        no-undo.

    define variable v-Template-file-name    as character    no-undo.
    define variable v-vb-file-name          as character    no-undo.

    define buffer buf_temp-param for temp-param .
do
for buf_temp-param
on error undo, return error
:
    create buf_temp-param.
    assign
        v-Template-file-name    = search( "exe/kfsale.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas")
    .
    if v-Template-file-name = ?
    or v-Template-file-name = "":U
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
          input {&paramls-Template}
        , input {&paramls-Template-file-name}
        , input v-Template-file-name
    ).
    run paramls-write in this-procedure (
          input {&paramls-Template}
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
end procedure. /* kfrebaxl-run-excel */


/*==========================================================================*/
procedure kfrebaxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/kfreba.xlt":U.
        export "exe/t_form.bas":U.
        export v-kfrebaxl-cell-file-name.
        export v-kfrebaxl-data-file-name.
    output close.
end.
end procedure. /* kfrebaxl-close */

/* $Workfile$ e n d */