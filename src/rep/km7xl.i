/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы KM-7 в Excel

Автор: Белоусов Илья Александрович
Дата создания:
Author: Ilia Belousov
Creation date:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define km7xl-line-data-key        "LD":U
&global-define km7xl-valutCode            "valutCode":U
&global-define km7xl-columnList           "columnList":U
&global-define km7xl-columnType           "columnType":U
&global-define km7xl-columnAmount         "columnAmount":U

&global-define km7xl-subtotalList         "subtotalList":U
&global-define km7xl-subtotalType         "subtotalType":U
&global-define km7xl-subtotalAmount       "subtotalAmount":U
&global-define km7xl-subtotalPropisList   "subtotalPropisList":U
&global-define km7xl-subtotalPropisAmount "subtotalPropisAmount":U

&global-define km7xl-h_organization       "h_organization":U
&global-define km7xl-h_object             "h_object":U
&global-define km7xl-h_docCode            "h_docCode":U
&global-define km7xl-h_docDate            "h_docDate":U
&global-define km7xl-h_docTime            "h_docTime":U
&global-define km7xl-h_OKPO               "h_OKPO":U
&global-define km7xl-h_INN                "h_INN":U
&global-define km7xl-h_pril_kass1         "h_pril_kass1":U
&global-define km7xl-h_pril_kass2         "h_pril_kass2":U

&global-define km7xl-f_boss               "f_boss":U
&global-define km7xl-f_post               "f_post":U
&global-define km7xl-f_cashier            "f_cashier":U

&global-define km7xl-it_Summ              "it_Summ":U
&global-define km7xl-it_kop               "it_kop":U
&global-define km7xl-it_sSummreturn       "it_sSummreturn":U
&global-define km7xl-it_s_Summ_1          "it_s_Summ_1":U
&global-define km7xl-it_s_Summ_2          "it_s_Summ_2":U


define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.
define temp-table temp_line-data no-undo
    field data-key    as character
    field xl-line-id  as integer
    field d_desk      as integer
    field d_kkm_prod  as character
    field d_kkm_reg   as character
    field d_z         as character
    field d_empty1    as character
    field d_sum_begin as decimal
    field d_sum_end   as decimal
    field d_summ      as decimal
    field d_empty2    as character
    field d_empty3    as character
    field d_empty4    as character
    field d_empty5    as character
    field d_empty6    as character
    field d_empty7    as character
    index pi is primary unique
          xl-line-id
.

define variable v-km7xl-current-data-row     as integer      no-undo.
define variable v-km7xl-cell-file-name       as character    no-undo.
define variable v-km7xl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure km7xl-init :

    define buffer buf_temp_cell-data        for temp_cell-data.
    define buffer buf_usr-flt               for ubflt.usr-flt.
do
for buf_temp_cell-data
  , buf_usr-flt
on error undo, return error
:
    assign
        v-km7xl-current-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-km7xl-data-file-name
    ).
    output stream excel-line to value( v-km7xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-km7xl-cell-file-name
    ).
    output stream excel-cell to value( v-km7xl-cell-file-name ).
    if printrubl = yes
    then do:
        run km7xl-write-cell-data in this-procedure (
              input {&km7xl-valutCode}
            , input "0":U
        ).
    end.
    else do:
        run km7xl-write-cell-data in this-procedure (
              input {&km7xl-valutCode}
            , input "1":U
        ).
    end.

    run km7xl-write-cell-data in this-procedure (
          input {&km7xl-columnList}
        , input "desk,kkmprod,kkmreg,z":U
    ).
    run km7xl-write-cell-data in this-procedure (
            input {&km7xl-columnType}
          , input "I,S,S,I":U
    ).
    run km7xl-write-cell-data in this-procedure (
          input {&km7xl-columnAmount}
        , input "4":U
    ).
    /*
    run km7xl-write-cell-data in this-procedure (
          input {&km7xl-subtotalList}
        , input "":U
    ).
    run km7xl-write-cell-data in this-procedure (
          input {&km7xl-subtotalType}
        , input "":U
    ).

    run km7xl-write-cell-data in this-procedure (
          input {&km7xl-subtotalAmount}
        , input "0":U
    ).
    run km7xl-write-cell-data in this-procedure (
        input {&km7xl-subtotalPropisList}
        , input "":U
    ).
    run km7xl-write-cell-data in this-procedure (
        input {&km7xl-subtotalPropisAmount}
        , input "0":U
    ).
    */
end.
end procedure. /* km7xl-init */

/*==========================================================================*/
procedure km7xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
        export "exe/km7_97.xlt":U.
        export "exe/t_97.bas":U.
        export v-km7xl-cell-file-name.
        export v-km7xl-data-file-name.
    output close.
end.
end procedure. /* km7xl-close */


/*==========================================================================*/
procedure km7xl-write-cell-data :
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
end procedure. /* km7xl-write-cell-data */


/*==========================================================================*/
procedure km7xl-write-line-data :

define input parameter p-d_desk      as integer          no-undo.
define input parameter p-d_kkm_prod  as character        no-undo.
define input parameter p-d_kkm_reg   as character        no-undo.
define input parameter p-d_z         as character        no-undo.

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
        v-km7xl-current-data-row = v-km7xl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key    = {&km7xl-line-data-key}
        buf_temp_line-data.xl-line-id  = v-km7xl-current-data-row
        buf_temp_line-data.d_desk      = p-d_desk
        buf_temp_line-data.d_kkm_prod  = p-d_kkm_prod
        buf_temp_line-data.d_kkm_reg   = p-d_kkm_reg
        buf_temp_line-data.d_z         = p-d_z
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key

        {&tabulation}   buf_temp_line-data.d_desk
        {&tabulation}   buf_temp_line-data.d_kkm_prod
        {&tabulation}   buf_temp_line-data.d_kkm_reg
        {&tabulation}   buf_temp_line-data.d_z
        {&new-line}
    .
end.
end procedure. /* km7xl-write-line-data */


/*==========================================================================*/
procedure km7xl-run-excel :
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
        v-template-file-name    = search( "exe/km7_97.xlt" )
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
end procedure. /* km7xl-run-excel */

/* $Workfile$ e n d */