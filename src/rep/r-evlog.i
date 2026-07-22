/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Журнал событий на кассе TcasH (процедуры работы с шаблоном)

Автор: Комаров Иван Сергеевич
Дата создания: 11/19/09
Author: Ivan Komarov
Creation date: 11/19/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


DEFINE TEMP-TABLE tt-line NO-UNDO LIKE ub.cd-event-log
      USE-INDEX PI  AS PRIMARY
      FIELD event-name AS CHARACTER
      index i-print
            obj-code
            cash-num
            event-date
            event-time
.


&global-define evlog-data-label "DTA":U
&global-define evlog-format-label "FMT":U

&global-define evlog-sheetList  "Лист1":U

&global-define evlog-sheet1_valutCode       "Лист1_valutCode":U
&global-define evlog-sheet1_columnList      "Лист1_columnList":U
&global-define evlog-sheet1_columnType      "Лист1_columnType":U
&global-define evlog-sheet1_subtotalList    "Лист1_subtotalList":U
&global-define evlog-sheet1_subtotalType    "Лист1_subtotalType":U

&global-define evlog-sheet1-name            "Лист1":U

&global-define evlog-event-list   "h_event_list":U
&global-define evlog-cd-list      "h_cd_list":U
&global-define evlog-user-id      "h_user_id":U
&global-define evlog-time-start   "h_time_start":U
&global-define evlog-time-end     "h_time_end":U
&global-define evlog-date-start   "date_start":U
&global-define evlog-date-end     "date_end":U
&global-define evlog-event-type   "h_event_type":U
&global-define evlog-supmode-id   "h_supmode_id":U
&global-define evlog-doc-num      "h_doc_num":U
&global-define evlog-b-codes      "h_b_codes":U
&global-define evlog-summ-min     "h_summ_min":U
&global-define evlog-summ-max     "h_summ_max":U
&global-define evlog-qnty-min     "h_qnty_min":U
&global-define evlog-qnty-max     "h_qnty_max":U
&global-define evlog-dc-num       "h_dc_num":U
&global-define evlog-bc-num       "h_bc_num":U
&global-define evlog-disc-type    "h_disc_type":U
&global-define evlog-disc-min     "h_disc_min":U
&global-define evlog-disc-max     "h_disc_max":U


define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.



define variable v-evlog-sheet1-cur-data-row     as integer      no-undo.

define variable v-evlog-cell-file-name       as character    no-undo.
define variable v-evlog-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure evlog-init :

do
on error undo, return error
:
    assign
        v-evlog-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-evlog-data-file-name
    ).
    output stream excel-line to value( v-evlog-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-evlog-cell-file-name
    ).
    output stream excel-cell to value( v-evlog-cell-file-name ).
    run evlog-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&evlog-sheetList}
    ).
    if printrubl
    then do:
        run evlog-write-cell-data in this-procedure (
              input {&evlog-sheet1_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run evlog-write-cell-data in this-procedure (
              input {&evlog-sheet1_valutCode}
            , input "1":U
        ).
    end.


    run evlog-write-cell-data in this-procedure (
          input {&evlog-sheet1_columnList}
        , input "trans_id,obj_code,pos_type,cash_num,db_num,shift_num,shift_date,shift_name,user_id,event_date,event_time,event_id,event_type,cd_mode,doc_code,chk_type,src_code,gds_code,doc_qnty,d_card,tot_sum,pay_card,discnt,description,action_item_id,price":U
    ).
    run evlog-write-cell-data in this-procedure (
          input {&evlog-sheet1_columnType}
        , input "S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S":U
    ).
    run evlog-write-cell-data in this-procedure (
          input {&evlog-sheet1_subtotalList}
        , input "":U
    ).
    run evlog-write-cell-data in this-procedure (
          input {&evlog-sheet1_subtotalType}
        , input "":U
    ).

end.
end procedure. /* evlog-init */


/*==========================================================================*/
procedure evlog-sheet1-write-line-data :

define buffer buf_tt-line     for tt-line .

define variable v-total-supp    as decimal  format "->>>>>9.99"     no-undo.
define variable v-number    as integer      no-undo.

do
on error undo, return error
:
   for each buf_tt-line
       USE-INDEX i-print
      :
            put stream excel-line unformatted
                                 {&evlog-sheet1-name}
                  {&tabulation}   {&evlog-data-label}
                  {&tabulation}   buf_tt-line.trans-id
                  {&tabulation}   buf_tt-line.obj-code
                  {&tabulation}   buf_tt-line.pos-type
                  {&tabulation}   buf_tt-line.cash-num
                  {&tabulation}   buf_tt-line.db-num
                  {&tabulation}   buf_tt-line.shift-num
                  {&tabulation}   buf_tt-line.shift-date
                  {&tabulation}   buf_tt-line.shift-name
                  {&tabulation}   buf_tt-line.user-id
                  {&tabulation}   string(buf_tt-line.event-date, "99/99/9999")
                  {&tabulation}   STRING(buf_tt-line.event-time, "HH:MM:SS")
                  {&tabulation}   buf_tt-line.event-name
                  {&tabulation}   buf_tt-line.event-type
                  {&tabulation}   buf_tt-line.cd-mode
                  {&tabulation}   buf_tt-line.doc-code
                  {&tabulation}   buf_tt-line.chk-type
                  {&tabulation}   buf_tt-line.src-code
                  {&tabulation}   buf_tt-line.gds-code
                  {&tabulation}   buf_tt-line.doc-qnty
                  {&tabulation}   buf_tt-line.d-card
                  {&tabulation}   buf_tt-line.tot-sum
                  {&tabulation}   buf_tt-line.pay-card
                  {&tabulation}   buf_tt-line.discnt
                  {&tabulation}   buf_tt-line.description
                  {&tabulation}   buf_tt-line.action-item-id
                  {&tabulation}   buf_tt-line.price
                  {&new-line}
            .
   end.
end.
end procedure. /* evlog-sheet1-write-line-data */


/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure evlog-write-cell-data :
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
end procedure. /* evlog-write-cell-data */

/*==========================================================================*/
procedure evlog-run-excel :
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
        v-template-file-name    = search( "exe/evlog.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas" )
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
end procedure. /* evlog-run-excel */


/*==========================================================================*/
procedure evlog-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/evlog.xlt" .
        export "exe/t_form.bas" .
        export v-evlog-cell-file-name.
        export v-evlog-data-file-name.
    output close.
end.
end procedure. /* evlog-close */

/* $Workfile$ e n d */