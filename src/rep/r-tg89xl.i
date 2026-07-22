/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по движению товаров на АЗС, вывод в Эксель

Автор: Комаров Иван Сергеевич
Дата создания: 02/11/10
Author: Ivan Komarov
Creation date: 02/11/10

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


&global-define tg89xl-line-data-key        "LD":U
&global-define tg89xl-valutCode            "valutCode":U
&global-define tg89xl-columnList           "columnList":U
&global-define tg89xl-columnType           "columnType":U
&global-define tg89xl-columnAmount         "columnAmount":U

&global-define tg89xl-subtotalList         "subtotalList":U
&global-define tg89xl-subtotalType         "subtotalType":U
&global-define tg89xl-subtotalAmount       "subtotalAmount":U
&global-define tg89xl-subtotalPropisList   "subtotalPropisList":U
&global-define tg89xl-subtotalPropisAmount "subtotalPropisAmount":U

&global-define tg89xl-h_organization       "h_organization":U
&global-define tg89xl-h_object             "h_object":U
&global-define tg89xl-h_date               "h_date":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define temp-table temp_line-data no-undo
    field data-key        as character
    field xl-line-id      as integer
    field d_count         as character
    field d_grpname       as character
    field d_ostbegin      as decimal
    field d_pripost       as decimal
    field d_priperem      as decimal
    field d_priprvo       as decimal
    field d_privozv       as decimal
    field d_prielse       as decimal
    field d_rasprod       as decimal
    field d_rasvozv       as decimal
    field d_rasperem      as decimal
    field d_rasvnesh      as decimal
    field d_rasprvo       as decimal
    field d_rasspis       as decimal
    field d_raselse       as decimal
    field d_peresort      as decimal
    field d_izlish        as decimal
    field d_nedost        as decimal
    field d_ostend        as decimal
    index pi is primary unique
          xl-line-id
.

define variable v-xl-current-data-row     as integer      no-undo.
define variable v-xl-cell-file-name       as character    no-undo.
define variable v-xl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure xl-init :

    define buffer buf_temp_cell-data        for temp_cell-data.
    define buffer buf_usr-flt               for ubflt.usr-flt.
do
for buf_temp_cell-data
  , buf_usr-flt
on error undo, return error
:
    assign
        v-xl-current-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-xl-data-file-name
    ).
    output stream excel-line to value( v-xl-data-file-name ).

    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-xl-cell-file-name
    ).
    output stream excel-cell to value( v-xl-cell-file-name ).

    run xl-write-cell-data in this-procedure (
          input {&tg89xl-valutCode}
        , input "0":U
    ).

    run xl-write-cell-data in this-procedure (
          input {&tg89xl-columnList}
        , input "count,grpname,ostbegin,pripost,priperem,priprvo,privozv,prielse,rasprod,rasvozv,rasperem,rasvnesh,rasprvo,rasspis,raselse,peresort,izlish,nedost,ostend":U
    ).

    run xl-write-cell-data in this-procedure (
          input {&tg89xl-columnType}
        , input "S,S,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D":U
    ).
    run xl-write-cell-data in this-procedure (
          input {&tg89xl-columnAmount}
        , input "19":U
    ).

/*    run xl-write-cell-data in this-procedure (*/
/*          input {&tg89xl-subtotalList}*/
/*        , input "ostbegin,pripost,priperem,priprvo,privozv,prielse,rasprod,rasvozv,rasperem,rasprvo,rasspis,raselse,peresort,izlish,nedost,ostend":U*/
/*    ).*/
/*    run xl-write-cell-data in this-procedure (*/
/*          input {&tg89xl-subtotalType}*/
/*        , input "D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D":U*/
/*    ).*/
/*    run xl-write-cell-data in this-procedure (*/
/*          input {&tg89xl-subtotalAmount}*/
/*        , input "16":U*/
/*    ).*/


end.
end procedure. /* xl-init */

/*==========================================================================*/
procedure xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/tg89.xlt":U.
        export "exe/t_97.bas":U.
        export v-xl-cell-file-name.
        export v-xl-data-file-name.
    output close.
end.
end procedure. /* xl-close */


/*==========================================================================*/
procedure xl-write-cell-data :
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
    then do :
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
end procedure. /* xl-write-cell-data */


/*==========================================================================*/
procedure xl-write-line-data :

define input parameter p-d_count        as character   no-undo .
define input parameter p-d_grpname      as character no-undo .
define input parameter p-d_ostbegin     as decimal   no-undo .
define input parameter p-d_pripost      as decimal   no-undo .
define input parameter p-d_priperem     as decimal   no-undo .
define input parameter p-d_priprvo      as decimal   no-undo .
define input parameter p-d_privozv      as decimal   no-undo .
define input parameter p-d_prielse      as decimal   no-undo .
define input parameter p-d_rasprod      as decimal   no-undo .
define input parameter p-d_rasvozv      as decimal   no-undo .
define input parameter p-d_rasperem     as decimal   no-undo .
define input parameter p-d_rasvnesh     as decimal   no-undo .
define input parameter p-d_rasprvo      as decimal   no-undo .
define input parameter p-d_rasspis      as decimal   no-undo .
define input parameter p-d_raselse      as decimal   no-undo .
define input parameter p-d_peresort     as decimal   no-undo .
define input parameter p-d_izlish       as decimal   no-undo .
define input parameter p-d_nedost       as decimal   no-undo .
define input parameter p-d_ostend       as decimal   no-undo .

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
        buf_temp_line-data.data-key        =  {&tg89xl-line-data-key}
        buf_temp_line-data.xl-line-id      =  buf_temp_line-data.xl-line-id + 1
        buf_temp_line-data.d_count         =  p-d_count
        buf_temp_line-data.d_grpname       =  p-d_grpname
        buf_temp_line-data.d_ostbegin      =  p-d_ostbegin
        buf_temp_line-data.d_pripost       =  p-d_pripost
        buf_temp_line-data.d_priperem      =  p-d_priperem
        buf_temp_line-data.d_priprvo       =  p-d_priprvo
        buf_temp_line-data.d_privozv       =  p-d_privozv
        buf_temp_line-data.d_prielse       =  p-d_prielse
        buf_temp_line-data.d_rasprod       =  p-d_rasprod
        buf_temp_line-data.d_rasvozv       =  p-d_rasvozv
        buf_temp_line-data.d_rasperem      =  p-d_rasperem
        buf_temp_line-data.d_rasvnesh      =  p-d_rasvnesh
        buf_temp_line-data.d_rasprvo       =  p-d_rasprvo
        buf_temp_line-data.d_rasspis       =  p-d_rasspis
        buf_temp_line-data.d_raselse       =  p-d_raselse
        buf_temp_line-data.d_peresort      =  p-d_peresort
        buf_temp_line-data.d_izlish        =  p-d_izlish
        buf_temp_line-data.d_nedost        =  p-d_nedost
        buf_temp_line-data.d_ostend        =  p-d_ostend
    .
    put stream excel-line unformatted
                      buf_temp_line-data.data-key
        {&tabulation} buf_temp_line-data.d_count
        {&tabulation} buf_temp_line-data.d_grpname
        {&tabulation} buf_temp_line-data.d_ostbegin
        {&tabulation} buf_temp_line-data.d_pripost
        {&tabulation} buf_temp_line-data.d_priperem
        {&tabulation} buf_temp_line-data.d_priprvo
        {&tabulation} buf_temp_line-data.d_privozv
        {&tabulation} buf_temp_line-data.d_prielse
        {&tabulation} buf_temp_line-data.d_rasprod
        {&tabulation} buf_temp_line-data.d_rasvozv
        {&tabulation} buf_temp_line-data.d_rasperem
        {&tabulation} buf_temp_line-data.d_rasvnesh
        {&tabulation} buf_temp_line-data.d_rasprvo
        {&tabulation} buf_temp_line-data.d_rasspis
        {&tabulation} buf_temp_line-data.d_raselse
        {&tabulation} buf_temp_line-data.d_peresort
        {&tabulation} buf_temp_line-data.d_izlish
        {&tabulation} buf_temp_line-data.d_nedost
        {&tabulation} buf_temp_line-data.d_ostend
        {&new-line}
    .
end.
end procedure. /* xl-write-line-data */


/*==========================================================================*/
procedure xl-run-excel :
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
        v-template-file-name    = search( "exe/tg89.xlt" )
        v-vb-file-name          = search( "exe/t_97.bas")
    .
    if v-template-file-name = ?
    or v-template-file-name = "":U
    then do :
        message
            "Ошибка имени файла шаблона."
        view-as alert-box error.
    end.
    if v-vb-file-name = ?
    or v-vb-file-name = "":U
    then do :
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
    then do :
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
end procedure. /* xl-run-excel */

/* $Workfile$ e n d */