/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Акт приема нефтепродуктов по количесту - EXCEL

Автор: Морзов Александр Сергеевич
Дата создания: 08/07/14
Author: Alexandr Morozov
Creation date: 08/07/14

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define aktpq-xl-line-data-key        "LD":U

&global-define aktpq-xl-valutCode            "valutCode":U
&global-define aktpq-xl-columnList           "columnList":U
&global-define aktpq-xl-columnType           "columnType":U
&global-define aktpq-xl-columnAmount         "columnAmount":U

&global-define aktpq-xl-subtotalList         "subtotalList":U
&global-define aktpq-xl-subtotalType         "subtotalType":U
&global-define aktpq-xl-subcolumnAmount      "subcolumnAmount":U

&global-define aktpq-xl-firmname             "firmname":U
&global-define aktpq-xl-objname              "objname":U
&global-define aktpq-xl-object               "objcode":U
&global-define aktpq-xl-carnum               "carnum":U
&global-define aktpq-xl-chiefoper            "chiefoper":U
&global-define aktpq-xl-oper                 "oper":U
&global-define aktpq-xl-chiefoper1           "chiefoper1":U
&global-define aktpq-xl-oper1                "oper1":U
&global-define aktpq-xl-dr_name              "drivername":U
&global-define aktpq-xl-autoentname          "autoentname":U
&global-define aktpq-xl-autoentinfo          "autoentinfo":U
&global-define aktpq-xl-ddovday              "ddovday":U
&global-define aktpq-xl-ddovmonth            "ddovmonth":U
&global-define aktpq-xl-ddovyear             "ddovyear":U
&global-define aktpq-xl-ndov                 "ndov":U
&global-define aktpq-xl-listgdsname          "listgdsname":U
&global-define aktpq-xl-factday              "factday":U
&global-define aktpq-xl-factmonth            "factmonth":U
&global-define aktpq-xl-factyear             "factyear":U
&global-define aktpq-xl-mngr_name            "manager_name":U
&global-define aktpq-xl-doc-code             "docnum":U
&global-define aktpq-xl-ptbname              "ptbname":U
&global-define aktpq-xl-ptbinfo              "ptbinfo":U
&global-define aktpq-xl-contractorinfo       "contractorinfo":U
&global-define aktpq-xl-condition            "condition":U
&global-define aktpq-xl-sealscondition       "sealscondition":U
&global-define aktpq-xl-incomehour           "incomehour":U
&global-define aktpq-xl-incomemin            "incomemin":U

&global-define aktpq-xl-acceptbeginhour      "acceptbeginhour":U
&global-define aktpq-xl-acceptbeginmin       "acceptbeginmin":U

&global-define aktpq-xl-acceptendhour        "acceptendhour":U
&global-define aktpq-xl-acceptendmin         "acceptendmin":U

&global-define aktpq-xl-trnnum               "trnnum":U
&global-define aktpq-xl-trnday               "trnday":U
&global-define aktpq-xl-trnmonth             "trnmonth":U
&global-define aktpq-xl-trnyear              "trnyear":U
&global-define aktpq-xl-sectionnum           "sectionnum":U

&global-define aktpq-xl-invoicenum           "invoicenum":U
&global-define aktpq-xl-invoiceday           "invoiceday":U
&global-define aktpq-xl-invoicemonth         "invoicemonth":U
&global-define aktpq-xl-invoiceyear          "invoiceyear":U

&global-define aktpq-xl-sortpetrl            "sortpetrl":U
&global-define aktpq-xl-gdsname              "gdsname":U
&global-define aktpq-xl-vol                  "vol":U
&global-define aktpq-xl-temp                 "temp":U
&global-define aktpq-xl-temp1                "temp1":U
&global-define aktpq-xl-petrlvol             "petrlvol":U
&global-define aktpq-xl-dens                 "dens":U
&global-define aktpq-xl-weight               "weight":U
&global-define aktpq-xl-mark                 "mark":U

&global-define aktpq-xl-diametr              "diametr":U
&global-define aktpq-xl-la                   "la":U
&global-define aktpq-xl-lb                   "lb":U
&global-define aktpq-xl-tempexp              "tempexp":U
&global-define aktpq-xl-densexp              "densexp":U


&global-define aktpq-xl-mouth                "mouth":U
&global-define aktpq-xl-factvol              "factvol":U
&global-define aktpq-xl-denspomi             "denspomi":U
&global-define aktpq-xl-volpomi              "volpomi":U
&global-define aktpq-xl-factweight           "factweight":U





&global-define aktpq-xl-beforelevtotal       "beforelevtotal":U
&global-define aktpq-xl-beforemeasqnty       "beforemeasqnty":U
&global-define aktpq-xl-beforestatetemp      "beforestatetemp":U
&global-define aktpq-xl-beforestatedens      "beforestatedens":U
&global-define aktpq-xl-beforestateweight    "beforestateweight":U

&global-define aktpq-xl-afterlevtotal        "afterlevtotal":U
&global-define aktpq-xl-aftermeasqnty        "aftermeasqnty":U
&global-define aktpq-xl-afterstatetemp       "afterstatetemp":U
&global-define aktpq-xl-afterstatedens       "afterstatedens":U
&global-define aktpq-xl-afterstateweight     "afterstateweight":U

&global-define aktpq-xl-acc_qnty              "acc_qnty":U
&global-define aktpq-xl-acc_qnty_kg           "acc_qnty_kg":U

&global-define aktpq-xl-measur_error          "measur_error":U
&global-define aktpq-xl-admittance_error_mass "admittance_error_mass":U
&global-define aktpq-xl-diff_mass             "diff_mass":U
&global-define aktpq-xl-natural_loss          "natural_loss":U
&global-define aktpq-xl-surpluse              "surpluse":U
&global-define aktpq-xl-accept_accod_kg       "accept_accod_kg":U
&global-define aktpq-xl-accept_accod_l        "accept_accod_l":U
&global-define aktpq-xl-coor                  "coor":U




define stream excel-line .
define stream excel-cell .

define temp-table temp_cell-data no-undo
    field data-key   as character
    field data-value as character

    index pi is primary unique data-key
.


define variable v-aktpq-xl-cell-file-name  as character    no-undo .
define variable v-aktpq-xl-data-file-name  as character    no-undo .

/*==========================================================================*/
procedure aktpq-xl-init :

do
on error undo, return error
:
/*        run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-aktpq-xl-data-file-name
    ).
    output stream excel-line to value( v-aktpq-xl-data-file-name ).*/

    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-aktpq-xl-cell-file-name
    ).
    output stream excel-cell to value( v-aktpq-xl-cell-file-name ).

    run aktpq-xl-write-cell-data in this-procedure (
          input {&aktpq-xl-valutCode}
        , input "0":U
    ).

    run aktpq-xl-write-cell-data in this-procedure (
          input {&aktpq-xl-columnList}
        , input "":U
    ).
    run aktpq-xl-write-cell-data in this-procedure (
          input {&aktpq-xl-columnType}
        , input "":U
    ).
    run aktpq-xl-write-cell-data in this-procedure (
          input {&aktpq-xl-columnAmount}
        , input "0":U
    ).

end.
end procedure. /* aktpq-xl-init */


/*==========================================================================*/
procedure aktpq-xl-write-cell-data :
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
end procedure. /* aktpq-xl-write-cell-data */

/*==========================================================================*/
procedure aktpq-xl-run-excel :
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
        v-template-file-name    = search( "exe/akt-petrl-q.xlt" )
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
end procedure. /* aktpq-xl-run-excel */


/*==========================================================================*/
procedure aktpq-xl-close :


do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/akt-petrl-q.xlt":U.
        export "exe/t_97.bas":U.
        export v-aktpq-xl-cell-file-name.
        export v-aktpq-xl-data-file-name.
    output close.
end.
end procedure. /* aktpq-xl-close */