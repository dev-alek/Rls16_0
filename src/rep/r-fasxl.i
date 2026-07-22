/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона фасов. листа в Excel

Автор: Демин Алексей Сергеевич
Дата создания: 07/23/07
Author: Alexey Demin
Creation date: 07/23/07

Required: { p a r a m l s . i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define r-fasxl-line-data-key "LD":U
&global-define r-fasxl-valutCode "valutCode":U
&global-define r-fasxl-columnList "columnList":U
&global-define r-fasxl-columnType "columnType":U
&global-define r-fasxl-columnAmount "columnAmount":U
&global-define r-fasxl-subtotalList "subtotalList":U
&global-define r-fasxl-subtotalType "subtotalType":U
&global-define r-fasxl-subtotalAmount "subtotalAmount":U

&global-define r-fasxl-h_docName       "h_docName":U
&global-define r-fasxl-h_cliFrom       "h_cliFrom":U
&global-define r-fasxl-h_Obj           "h_Obj":U

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
    field   num_ser          as character
    field   docdate             as character
    field   gds_name         as character
    field   seria            as character
    field   qnty             as decimal
    field   price            as decimal
    field   gds_name1        as character
    field   qnty1            as decimal
    field   price1           as decimal
    field   sum              as decimal
    field   last_date        as character
    index pi is primary unique xl-line-id
.

define variable v-r-fasxl-current-data-row     as integer      no-undo.
define variable v-r-fasxl-cell-file-name       as character    no-undo.
define variable v-r-fasxl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure r-fasxl-init :

    define buffer buf_temp_cell-data        for temp_cell-data.
do
for buf_temp_cell-data on error undo, return error :
    assign
        v-r-fasxl-current-data-row = 0
    .
    run gbl/_tmpfile.p ( input "xd", input ".txt", output v-r-fasxl-data-file-name ).
    output stream excel-line to value( v-r-fasxl-data-file-name ).
    run gbl/_tmpfile.p ( input "xc", input ".txt", output v-r-fasxl-cell-file-name ).
    output stream excel-cell to value( v-r-fasxl-cell-file-name ).
    if printrubl
    then do:
        run r-fasxl-write-cell-data in this-procedure (
              input {&r-fasxl-valutCode}
            , input "0":U
        ).
    end.
    else do:
        run r-fasxl-write-cell-data in this-procedure (
              input {&r-fasxl-valutCode}
            , input "1":U
        ).
    end.
    run r-fasxl-write-cell-data in this-procedure (
          input {&r-fasxl-columnList}
        , input "num_ser,docdate,gds_name,seria,qnty,price,gds_name1,qnty1,price1,sum,last_date":U
    ).
    run r-fasxl-write-cell-data in this-procedure (
          input {&r-fasxl-columnType}
        , input "S,S,S,S,D,D,S,D,D,D,S":U
    ).
    run r-fasxl-write-cell-data in this-procedure (
          input {&r-fasxl-columnAmount}
        , input "11":U
    ).
/*    run r-fasxl-write-cell-data in this-procedure (*/
/*          input {&r-fasxl-subtotalList}*/
/*        , input "qnty,sum":U*/
/*    ).*/
/*    run r-fasxl-write-cell-data in this-procedure (*/
/*          input {&r-fasxl-subtotalType}*/
/*        , input "S,S":U*/
/*    ).*/
/*    run r-fasxl-write-cell-data in this-procedure (*/
/*          input {&r-fasxl-subtotalAmount}*/
/*        , input "2":U*/
/*    ).*/
end.
end procedure. /* r-fasxl-init */

/*==========================================================================*/
procedure r-fasxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/fas_97.xlt":U.
        export "exe/t_97.bas":U.
        export v-r-fasxl-cell-file-name.
        export v-r-fasxl-data-file-name.
    output close.
end.
end procedure. /* r-fasxl-close */


/*==========================================================================*/
procedure r-fasxl-write-cell-data :
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
end procedure. /* r-fasxl-write-cell-data */


/*==========================================================================*/
procedure r-fasxl-write-line-data :
define input parameter p-num-ser          as character         no-undo.
define input parameter p-docdate             as character              no-undo.
define input parameter p-gds-name         as character              no-undo.
define input parameter p-seria            as character         no-undo.
define input parameter p-qnty             as decimal           no-undo.
define input parameter p-price            as decimal           no-undo.
define input parameter p-gds-name1        as character              no-undo.
define input parameter p-qnty1            as decimal           no-undo.
define input parameter p-price1           as decimal           no-undo.
define input parameter p-sum              as decimal           no-undo.
define input parameter p-last-date        as character              no-undo.

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
        v-r-fasxl-current-data-row = v-r-fasxl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key     = {&r-fasxl-line-data-key}
        buf_temp_line-data.xl-line-id   = v-r-fasxl-current-data-row
        buf_temp_line-data.num_ser      = p-num-ser
        buf_temp_line-data.docdate         = p-docdate
        buf_temp_line-data.gds_name     = p-gds-name
        buf_temp_line-data.seria        = p-seria
        buf_temp_line-data.qnty         = p-qnty
        buf_temp_line-data.price        = p-price
        buf_temp_line-data.gds_name1    = p-gds-name1
        buf_temp_line-data.qnty1        = p-qnty1
        buf_temp_line-data.price1       = p-price1
        buf_temp_line-data.sum          = p-sum
        buf_temp_line-data.last_date    = p-last-date
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        {&tabulation}   buf_temp_line-data.num_ser
        {&tabulation}   buf_temp_line-data.docdate
        {&tabulation}   buf_temp_line-data.gds_name
        {&tabulation}   buf_temp_line-data.seria
        {&tabulation}   buf_temp_line-data.qnty
        {&tabulation}   buf_temp_line-data.price
        {&tabulation}   buf_temp_line-data.gds_name1
        {&tabulation}   buf_temp_line-data.qnty1
        {&tabulation}   buf_temp_line-data.price1
        {&tabulation}   buf_temp_line-data.sum
        {&tabulation}   buf_temp_line-data.last_date
        {&new-line}
    .
end.
end procedure. /* r-fasxl-write-line-data */


/*==========================================================================*/
procedure r-fasxl-run-excel :
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
        v-template-file-name    = search( "exe/fas_97.xlt" )
        v-vb-file-name          = search( "exe/t_97.bas")
    .
    if v-template-file-name = ?  or v-template-file-name = "":U  then do:
        message  "Ошибка имени файла шаблона." view-as alert-box error.
    end.
    if v-vb-file-name = ?  or v-vb-file-name = "":U then do:
        message  "Ошибка имени файла кода обработки."   view-as alert-box error.
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
end procedure. /* r-fasxl-run-excel */

/* $Workfile$ e n d */