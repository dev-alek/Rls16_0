/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы инв-8 в Excel

Автор: Белоусов Илья Александрович
Дата создания: 07/27/07
Author: Ilia Belousov
Creation date: 07/27/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define inv26xl-line-data-key        "LD":U
&global-define inv26xl-valutCode            "valutCode":U
&global-define inv26xl-columnList           "columnList":U
&global-define inv26xl-columnType           "columnType":U
&global-define inv26xl-columnAmount         "columnAmount":U

&global-define inv26xl-subtotalList         "subtotalList":U
&global-define inv26xl-subtotalType         "subtotalType":U
&global-define inv26xl-subtotalAmount       "subtotalAmount":U
&global-define inv26xl-subtotalPropisList   "subtotalPropisList":U
&global-define inv26xl-subtotalPropisAmount "subtotalPropisAmount":U

&global-define inv26xl-h_organization       "h_organization":U
&global-define inv26xl-h_object             "h_object":U
&global-define inv26xl-h_docCode            "h_docCode":U
&global-define inv26xl-h_docDate            "h_docDate":U
&global-define inv26xl-h_OKPO               "h_OKPO":U

&global-define inv26xl-f_docextra-rubl      "f_docextra_rubl":U
&global-define inv26xl-f_docmiss-rubl       "f_docmiss_rubl":U
&global-define inv26xl-f_docwaste-rubl      "f_docwaste_rubl":U

&global-define inv26xl-it_docextra-rubl     "it_docextra_rubl":U
&global-define inv26xl-it_docmiss-rubl      "it_docmiss_rubl":U
&global-define inv26xl-it_docwaste-rubl     "it_docwaste_rubl":U



define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.
define temp-table temp_line-data no-undo
    field data-key      as character
    field xl-line-id    as integer
    field vat      as character
    field docextra-rubl as character
    field docmiss-rubl  as character
    field docwaste-rubl as character
    index pi is primary unique
          xl-line-id
.

define variable v-inv26xl-current-data-row     as integer      no-undo.
define variable v-inv26xl-cell-file-name       as character    no-undo.
define variable v-inv26xl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure inv26xl-init :

define buffer buf_temp_cell-data        for temp_cell-data.

do
for buf_temp_cell-data
on error undo, return error
:
    assign
        v-inv26xl-current-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-inv26xl-data-file-name
    ).
    output stream excel-line to value( v-inv26xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-inv26xl-cell-file-name
    ).
    output stream excel-cell to value( v-inv26xl-cell-file-name ).

    if printrubl = yes
    then do:
        run inv26xl-write-cell-data in this-procedure (
              input {&inv26xl-valutCode}
            , input "0":U
        ).
    end.
    else do:
        run inv26xl-write-cell-data in this-procedure (
              input {&inv26xl-valutCode}
            , input "1":U
        ).
    end.

    run inv26xl-write-cell-data in this-procedure (
          input {&inv26xl-columnList}
        , input "num,vat,docextra_rubl,docmiss_rubl,docwaste_rubl":U
    ).
    run inv26xl-write-cell-data in this-procedure (
          input {&inv26xl-columnType}
        , input "S,S,S,S,S":U
    ).
    run inv26xl-write-cell-data in this-procedure (
          input {&inv26xl-columnAmount}
        , input "5":U
    ).
    /*
    run inv26xl-write-cell-data in this-procedure (
          input {&inv26xl-subtotalList}
        , input "docextra-rubl,docmiss-rubl,docwaste-rubl":U
    ).
    run inv26xl-write-cell-data in this-procedure (
          input {&inv26xl-subtotalType}
        , input "S,S,S":U
    ).
    run inv26xl-write-cell-data in this-procedure (
          input {&inv26xl-subtotalAmount}
        , input "3":U
    ).
    */
end.
end procedure. /* inv26xl-init */

/*==========================================================================*/
procedure inv26xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/inv26_97.xlt":U.
        export "exe/t_97.bas":U.
        export v-inv26xl-cell-file-name.
        export v-inv26xl-data-file-name.
    output close.
end.
end procedure. /* inv26xl-close */


/*==========================================================================*/
procedure inv26xl-write-cell-data :
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
end procedure. /* inv26xl-write-cell-data */


/*==========================================================================*/
procedure inv26xl-write-line-data :
define input parameter p-vat                    as character        no-undo.
define input parameter p-docextra-rubl          as character        no-undo.
define input parameter p-docmiss-rubl           as character        no-undo.
define input parameter p-docwaste-rubl          as character        no-undo.

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
        v-inv26xl-current-data-row = v-inv26xl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key       = {&inv26xl-line-data-key}
        buf_temp_line-data.xl-line-id     = v-inv26xl-current-data-row
        buf_temp_line-data.vat            = p-vat
        buf_temp_line-data.docextra-rubl  = p-docextra-rubl
        buf_temp_line-data.docmiss-rubl   = p-docmiss-rubl
        buf_temp_line-data.docwaste-rubl  = p-docwaste-rubl
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        {&tabulation}   buf_temp_line-data.xl-line-id
        {&tabulation}   buf_temp_line-data.vat
        {&tabulation}   buf_temp_line-data.docextra-rubl
        {&tabulation}   buf_temp_line-data.docmiss-rubl
        {&tabulation}   buf_temp_line-data.docwaste-rubl
        {&new-line}
    .
end.
end procedure. /* inv26xl-write-line-data */


/*==========================================================================*/
procedure inv26xl-run-excel :
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
        v-template-file-name    = search( "exe/inv26_97.xlt" )
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
end procedure. /* inv26xl-run-excel */



/* $Workfile$ e n d */