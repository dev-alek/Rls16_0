/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сводный отчет по движению СТ. НТФ-8.10 (Кедр-М) - вывод в Эксель

Автор: Комаров Иван Сергеевич
Дата создания: 02/11/10
Author: Ivan Komarov
Creation date: 02/11/10

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define tg810xl-line-data-key        "DTA":U
&global-define tg810xl-format-label         "FMT":U

&global-define tg810xl-valutCode            "Template_valutCode":U
&global-define tg810xl-columnList           "Template_columnList":U
&global-define tg810xl-columnType           "Template_columnType":U
&global-define tg810xl-columnAmount         "Template_columnAmount":U

&global-define tg810xl-subtotalList         "Template_subtotalList":U
&global-define tg810xl-subtotalType         "Template_subtotalType":U
&global-define tg810xl-subtotalAmount       "Template_subtotalAmount":U
&global-define tg810xl-subtotalPropisList   "Template_subtotalPropisList":U
&global-define tg810xl-subtotalPropisAmount "Template_subtotalPropisAmount":U

&global-define tg810xl-h_organization       "Template_h_organization":U
&global-define tg810xl-h_object             "Template_h_object":U
&global-define tg810xl-h_date               "Template_h_date":U

&global-define tg810xl-sheet1-name          "Template":U
&global-define tg810xl-sheetList            "Template":U
&global-define tg810xl-h_header             "h_header":U


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
    field sheet-name      as character
    field d_grpname       as character
    field d_ostbegin      as decimal
    field d_income        as decimal
    field d_intincome     as decimal
    field d_expense       as decimal
    field d_intexpense    as decimal
    field d_izlish        as decimal
    field d_nedost        as decimal
    field d_ostend        as decimal
    index pi is primary unique
          xl-line-id
.

define variable v-tg810xl-cur-data-row         as integer      no-undo.
define variable v-tg810xl-cell-file-name       as character    no-undo.
define variable v-tg810xl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure tg810xl-init :

    define buffer buf_temp_cell-data        for temp_cell-data.
    define buffer buf_usr-flt               for ubflt.usr-flt.
do
for buf_temp_cell-data
  , buf_usr-flt
on error undo, return error
:
    assign
        v-tg810xl-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-tg810xl-data-file-name
    ).
    output stream excel-line to value( v-tg810xl-data-file-name ).

    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-tg810xl-cell-file-name
    ).
    output stream excel-cell to value( v-tg810xl-cell-file-name ).

    run tg810xl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&tg810xl-sheetList}
    ).

    run tg810xl-write-cell-data in this-procedure (
          input {&tg810xl-valutCode}
        , input "0":U
    ).

    run tg810xl-write-cell-data in this-procedure (
          input {&tg810xl-columnList}
        , input "count,grpname,ostbegin,income,intincome,expense,intexpense,izlish,nedost,ostend":U
    ).

    run tg810xl-write-cell-data in this-procedure (
          input {&tg810xl-columnType}
        , input "I,S,D,D,D,D,D,D,D,D":U
    ).
    run tg810xl-write-cell-data in this-procedure (
          input {&tg810xl-columnAmount}
        , input "10":U
    ).

end.
end procedure. /* tg810xl-init */

/*==========================================================================*/
procedure tg810xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    OUTPUT TO value( STRING( SESSION:temp-directory + "$" + STRING( g#report-num ) ) + ".txl" ) /*!!! APPEND*/ .
        export "exe/tg810.xlt":U.
        export "exe/t_form.bas":U.
        export v-tg810xl-cell-file-name.
        export v-tg810xl-data-file-name.
    output close.
end.
end procedure. /* tg810xl-close */


/*==========================================================================*/
procedure tg810xl-write-cell-data :
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
end procedure. /* tg810xl-write-cell-data */


/*==========================================================================*/
procedure tg810xl-write-line-data :

define input parameter p-d_count        as character no-undo .
define input parameter p-d_grpname      as character no-undo .
define input parameter p-d_ostbegin     as decimal   no-undo .
define input parameter p-d_income       as decimal   no-undo .
define input parameter p-d_intincome    as decimal   no-undo .
define input parameter p-d_expense      as decimal   no-undo .
define input parameter p-d_intexpense   as decimal   no-undo .
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
        v-tg810xl-cur-data-row             =  v-tg810xl-cur-data-row + 1
        buf_temp_line-data.xl-line-id      =  v-tg810xl-cur-data-row
        buf_temp_line-data.sheet-name      =  {&tg810xl-sheet1-name}
        buf_temp_line-data.data-key        =  {&tg810xl-line-data-key}
        buf_temp_line-data.d_count         =  p-d_count
        buf_temp_line-data.d_grpname       =  p-d_grpname
        buf_temp_line-data.d_ostbegin      =  p-d_ostbegin
        buf_temp_line-data.d_income        =  p-d_income
        buf_temp_line-data.d_intincome     =  p-d_intincome
        buf_temp_line-data.d_expense       =  p-d_expense
        buf_temp_line-data.d_intexpense    =  p-d_intexpense
        buf_temp_line-data.d_izlish        =  p-d_izlish
        buf_temp_line-data.d_nedost        =  p-d_nedost
        buf_temp_line-data.d_ostend        =  p-d_ostend
        .

    put stream excel-line unformatted
                      buf_temp_line-data.sheet-name
        {&tabulation} buf_temp_line-data.data-key
        {&tabulation} buf_temp_line-data.d_count
        {&tabulation} buf_temp_line-data.d_grpname
        {&tabulation} buf_temp_line-data.d_ostbegin
        {&tabulation} buf_temp_line-data.d_income
        {&tabulation} buf_temp_line-data.d_intincome
        {&tabulation} buf_temp_line-data.d_expense
        {&tabulation} buf_temp_line-data.d_intexpense
        {&tabulation} buf_temp_line-data.d_izlish
        {&tabulation} buf_temp_line-data.d_nedost
        {&tabulation} buf_temp_line-data.d_ostend
        {&new-line}
    .
end.
end procedure. /* tg810xl-write-line-data */

/*==========================================================================*/
procedure tg810xl-write-line-format :
define input parameter p-fmt-label       as character  no-undo.


    define buffer buf_temp_line-data        for temp_line-data.
do
for buf_temp_line-data
on error undo, return error
:
    put stream excel-line unformatted
                       {&tg810xl-sheet1-name}
        {&tabulation}  {&tg810xl-format-label}
        {&tabulation}   p-fmt-label
        {&new-line}
    .
end.
end procedure. /* tg810xl-write-line-format */

/*==========================================================================*/
procedure tg810xl-run-excel :
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
        v-template-file-name    = search( "exe/tg810.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas")
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
end procedure. /* tg810xl-run-excel */

/* $Workfile$ e n d */