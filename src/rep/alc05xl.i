/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы Декларация об объемах розничной продажи алкогольной продукции (Марий-Эл) в Excel

Автор: Хныкин Павел Андреевич
Дата создания: 03/19/08
Author: Pavel Khnykin
Creation date: 03/19/08

Required: { p a r a m l s . i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define alc05xl-data-label "DTA":U
&global-define alc05xl-format-label "FMT":U

&global-define alc05xl-sheetList  "Декларация":U

&global-define alc05xl-sheet1_valutCode       "Декларация_valutCode":U
&global-define alc05xl-sheet1_columnList      "Декларация_columnList":U
&global-define alc05xl-sheet1_columnType      "Декларация_columnType":U
&global-define alc05xl-sheet1_subtotalList    "Декларация_subtotalList":U
&global-define alc05xl-sheet1_subtotalType    "Декларация_subtotalType":U

&global-define alc05xl-h_month "month":U
&global-define alc05xl-h_object "object":U
&global-define alc05xl-h_license "license":U

&global-define alc05xl-sheet1-name "Декларация":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.

define temp-table temp_sheet1_line-data no-undo
    field sheet-name    as character
    field xl-line-id    as integer
    field npp           as character
    field alctypename   as character
    field ostbegin      as character
    field pritot        as character
    field priprod       as character
    field priopt        as character
    field priret        as character
    field rastot        as character
    field rassel        as character
    field rasret        as character
    field rasspi        as character
    field rasoth        as character
    field ostend        as character
index pi is primary unique
        xl-line-id
.


define variable v-alc05xl-sheet1-cur-data-row  as integer      no-undo.
define variable v-alc05xl-cell-file-name       as character    no-undo.
define variable v-alc05xl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure alc05xl-init :

do
on error undo, return error
:
    assign
        v-alc05xl-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-alc05xl-data-file-name
    ).
    output stream excel-line to value( v-alc05xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-alc05xl-cell-file-name
    ).
    output stream excel-cell to value( v-alc05xl-cell-file-name ).
    run alc05xl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&alc05xl-sheetList}
    ).
    if printrubl
    then do:
        run alc05xl-write-cell-data in this-procedure (
              input {&alc05xl-sheet1_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run alc05xl-write-cell-data in this-procedure (
              input {&alc05xl-sheet1_valutCode}
            , input "1":U
        ).
    end.
    run alc05xl-write-cell-data in this-procedure (
          input {&alc05xl-sheet1_columnList}
        , input "npp,alctypename,ostbegin,pritot,priprod,priopt,priret,rastot,rassel,rasret,rasspi,rasoth,ostend":U
    ).
    run alc05xl-write-cell-data in this-procedure (
          input {&alc05xl-sheet1_columnType}
        , input "S,S,S,S,S,S,S,S,S,S,S,S,S":U
    ).
    run alc05xl-write-cell-data in this-procedure (
          input {&alc05xl-sheet1_subtotalList}
        , input "":U
    ).
    run alc05xl-write-cell-data in this-procedure (
          input {&alc05xl-sheet1_subtotalType}
        , input "":U
    ).
end.
end procedure. /* alc05xl-init */

/*==========================================================================*/
procedure alc05xl-sheet1-write-line-data :
  define input parameter p-npp          as character no-undo .
  define input parameter p-alctypename  as character no-undo .
  define input parameter p-ostbegin     as character no-undo .
  define input parameter p-pritot       as character no-undo .
  define input parameter p-priprod      as character no-undo .
  define input parameter p-priopt       as character no-undo .
  define input parameter p-priret       as character no-undo .
  define input parameter p-rastot       as character no-undo .
  define input parameter p-rassel       as character no-undo .
  define input parameter p-rasret       as character no-undo .
  define input parameter p-rasspi       as character no-undo .
  define input parameter p-rasoth       as character no-undo .
  define input parameter p-ostend       as character no-undo .

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
        v-alc05xl-sheet1-cur-data-row         = v-alc05xl-sheet1-cur-data-row + 1
        buf_temp_sheet1_line-data.sheet-name  = {&alc05xl-sheet1-name}
        buf_temp_sheet1_line-data.xl-line-id  = v-alc05xl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.npp         = p-npp
        buf_temp_sheet1_line-data.alctypename = p-alctypename
        buf_temp_sheet1_line-data.ostbegin    = p-ostbegin
        buf_temp_sheet1_line-data.pritot      = p-pritot
        buf_temp_sheet1_line-data.priprod     = p-priprod
        buf_temp_sheet1_line-data.priopt      = p-priopt
        buf_temp_sheet1_line-data.priret      = p-priret
        buf_temp_sheet1_line-data.rastot      = p-rastot
        buf_temp_sheet1_line-data.rassel      = p-rassel
        buf_temp_sheet1_line-data.rasret      = p-rasret
        buf_temp_sheet1_line-data.rasspi      = p-rasspi
        buf_temp_sheet1_line-data.rasoth      = p-rasoth
        buf_temp_sheet1_line-data.ostend      = p-ostend
    .

    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        {&tabulation}   {&alc05xl-data-label}
        {&tabulation}   buf_temp_sheet1_line-data.npp
        {&tabulation}   buf_temp_sheet1_line-data.alctypename
        {&tabulation}   buf_temp_sheet1_line-data.ostbegin
        {&tabulation}   buf_temp_sheet1_line-data.pritot
        {&tabulation}   buf_temp_sheet1_line-data.priprod
        {&tabulation}   buf_temp_sheet1_line-data.priopt
        {&tabulation}   buf_temp_sheet1_line-data.priret
        {&tabulation}   buf_temp_sheet1_line-data.rastot
        {&tabulation}   buf_temp_sheet1_line-data.rassel
        {&tabulation}   buf_temp_sheet1_line-data.rasret
        {&tabulation}   buf_temp_sheet1_line-data.rasspi
        {&tabulation}   buf_temp_sheet1_line-data.rasoth
        {&tabulation}   buf_temp_sheet1_line-data.ostend
        {&new-line}
    .
    .
end.
end procedure. /* alc05xl-sheet1-write-line-data */

/*==========================================================================*/
procedure alc05xl-sheet1-write-line-format :
define input parameter p-fmt-label       as character  no-undo.


    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        {&alc05xl-sheet1-name}
        {&tabulation}   {&alc05xl-format-label}
        {&tabulation}   p-fmt-label
        {&new-line}
    .
end.
end procedure. /* alc05xl-sheet1-write-line-format */


/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure alc05xl-write-cell-data :
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
end procedure. /* alc05xl-write-cell-data */

/*==========================================================================*/
procedure alc05xl-run-excel :
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
        v-Template-file-name    = search( "exe/alcdcl05.xlt" )
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
end procedure. /* alc05xl-run-excel */


/*==========================================================================*/
procedure alc05xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/alcdcl05.xlt":U.
        export "exe/t_form.bas":U.
        export v-alc05xl-cell-file-name.
        export v-alc05xl-data-file-name.
    output close.
end.
end procedure. /* alc05xl-close */

/* $Workfile$ e n d */