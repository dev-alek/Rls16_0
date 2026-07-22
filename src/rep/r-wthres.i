/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Белоусов Илья Александрович
Дата создания: 05/19/08
Author: Ilia Belousov
Creation date: 05/19/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
/*
DEFINE TEMP-TABLE tt-line NO-UNDO
      /* */
      FIELD wth-code       as integer
      FIELD wth-par-code   as integer
      FIELD obj-type       as character
      FIELD obj-code       as integer
      FIELD w-p-code       as integer

      FIELD qnty-free      as integer    /* штук талонов */
      FIELD qnty-put       as integer    /* штук погашенных талонов */

      INDEX pi IS PRIMARY UNIQUE
            wth-code
            wth-par-code
            obj-type
            obj-code
            w-p-code
.
*/

&global-define wthres-data-label "DTA":U
&global-define wthres-format-label "FMT":U

&global-define wthres-sheetList  "Template":U

&global-define wthres-sheet1_valutCode       "Template_valutCode":U
&global-define wthres-sheet1_columnList      "Template_columnList":U
&global-define wthres-sheet1_columnType      "Template_columnType":U
&global-define wthres-sheet1_subtotalList    "Template_subtotalList":U
&global-define wthres-sheet1_subtotalType    "Template_subtotalType":U

&global-define wthres-sheet1-name            "Template":U
&global-define wthres-sheet1-period          "period":U
&global-define wthres-sheet1-firm            "firm":U
&global-define wthres-sheet1-place           "place":U
&global-define wthres_title                  "FM_1":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.



define variable v-wthres-sheet1-cur-data-row     as integer      no-undo.

define variable v-wthres-cell-file-name       as character    no-undo.
define variable v-wthres-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure wthres-init :

do
on error undo, return error
:
    assign
        v-wthres-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-wthres-data-file-name
    ).
    output stream excel-line to value( v-wthres-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-wthres-cell-file-name
    ).
    output stream excel-cell to value( v-wthres-cell-file-name ).
    run wthres-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&wthres-sheetList}
    ).
    if printrubl
    then do:
        run wthres-write-cell-data in this-procedure (
              input {&wthres-sheet1_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run wthres-write-cell-data in this-procedure (
              input {&wthres-sheet1_valutCode}
            , input "1":U
        ).
    end.


    run wthres-write-cell-data in this-procedure (
          input {&wthres-sheet1_columnList}
        , input "wth_name,wth_par,qnty_free,qnty_out":U
    ).
    run wthres-write-cell-data in this-procedure (
          input {&wthres-sheet1_columnType}
        , input "S,S,S,S":U
    ).
    run wthres-write-cell-data in this-procedure (
          input {&wthres-sheet1_subtotalList}
        , input "":U
    ).
    run wthres-write-cell-data in this-procedure (
          input {&wthres-sheet1_subtotalType}
        , input "":U
    ).

end.
end procedure. /* wthres-init */


/*==========================================================================*/
procedure wthres-sheet1-write-line-data :
define input parameter p-wth-name      as character        no-undo.
define input parameter p-wth-par-name  as character        no-undo.
define input parameter p-wth-qnty-free as character        no-undo.
define input parameter p-wth-qnty-put  as character        no-undo.

do
on error undo, return error
:
      /* заголовок группы клиентов */
      put stream excel-line unformatted
                            {&wthres-sheet1-name}
            {&tabulation}   {&wthres-data-label}
            {&tabulation}   p-wth-name
            {&tabulation}   p-wth-par-name
            {&tabulation}   p-wth-qnty-free
            {&tabulation}   p-wth-qnty-put
            {&new-line}
      .

end.
end procedure. /* wthres-sheet1-write-line-data */

/*==========================================================================*/
procedure wthres-sheet1-write-line-style :
define input parameter p-style         as character        no-undo.

do
on error undo, return error
:
      put stream excel-line unformatted
                        {&wthres-sheet1-name}
         {&tabulation}  {&wthres-format-label}
         {&tabulation}  p-style
         {&new-line}
      .

end.
end procedure. /* wthres-sheet1-write-line-data */


/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure wthres-write-cell-data :
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
end procedure. /* wthres-write-cell-data */

/*==========================================================================*/
procedure wthres-run-excel :
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
        v-template-file-name    = search( "exe/wthres.xlt" )
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
end procedure. /* wthres-run-excel */


/*==========================================================================*/
procedure wthres-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/wthres.xlt" .
        export "exe/t_form.bas" .
        export v-wthres-cell-file-name.
        export v-wthres-data-file-name.
    output close.
end.
end procedure. /* wthres-close */


/* $Workfile$ e n d */