/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Белоусов Илья Александрович
Дата создания: 05/27/08
Author: Ilia Belousov
Creation date: 05/27/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

DEFINE TEMP-TABLE tt-line NO-UNDO
   field grp-code           like ub.goods.grp-code
   field prod-type          as character
   field prod-code          as integer
   field supp-type          as character
   field supp-code          as integer

   field obj-type           as character
   field obj-code           as integer

   field grp-name           as character  /* 02 */
   field supp-name          as character  /* 03 */
   field prod-name          as character  /* 04 */

   field prod-summ-sale     as decimal

   field prod-summ-cost     as decimal   /* 05 */

index pu as primary unique
      grp-code
      supp-type
      supp-code
      /*
      prod-type
      prod-code
index i-print
      grp-code
      supp-name
      prod-name
      */
.
DEFINE TEMP-TABLE tt-total NO-UNDO
   field grp-code           like ub.goods.grp-code

   field grp-summ-sale      as decimal

   field grp-summ-cost      as decimal    /* 08 */

index pu as primary unique
      grp-code
.


&global-define salest-data-label "DTA":U
&global-define salest-format-label "FMT":U

&global-define salest-sheetList  "Template":U

&global-define salest-sheet1_valutCode       "Template_valutCode":U
&global-define salest-sheet1_columnList      "Template_columnList":U
&global-define salest-sheet1_columnType      "Template_columnType":U
&global-define salest-sheet1_subtotalList    "Template_subtotalList":U
&global-define salest-sheet1_subtotalType    "Template_subtotalType":U

&global-define salest-sheet1-name            "Template":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.



define variable v-salest-sheet1-cur-data-row     as integer      no-undo.

define variable v-salest-cell-file-name       as character    no-undo.
define variable v-salest-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure salest-init :

do
on error undo, return error
:
    assign
        v-salest-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-salest-data-file-name
    ).
    output stream excel-line to value( v-salest-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-salest-cell-file-name
    ).
    output stream excel-cell to value( v-salest-cell-file-name ).
    run salest-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&salest-sheetList}
    ).
    if printrubl
    then do:
        run salest-write-cell-data in this-procedure (
              input {&salest-sheet1_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run salest-write-cell-data in this-procedure (
              input {&salest-sheet1_valutCode}
            , input "1":U
        ).
    end.


    run salest-write-cell-data in this-procedure (
          input {&salest-sheet1_columnList}
        , input "number,grp_name,supp_name,summ_cost,supp_perc,grp_summ_cost,grp_perc,grp_marg":U
    ).
    run salest-write-cell-data in this-procedure (
          input {&salest-sheet1_columnType}
        , input "S,S,S,S,S,S,S":U
    ).
    run salest-write-cell-data in this-procedure (
          input {&salest-sheet1_subtotalList}
        , input "":U
    ).
    run salest-write-cell-data in this-procedure (
          input {&salest-sheet1_subtotalType}
        , input "":U
    ).

end.
end procedure. /* salest-init */


/*==========================================================================*/
procedure salest-sheet1-write-line-data :

define buffer buf_tt-line     for tt-line .

define variable v-total-supp    as decimal  format "->>>>>9.99"     no-undo.
define variable v-number    as integer      no-undo.
define variable v-grp-name    as character    no-undo.

do
on error undo, return error
:
   for each buf_tt-line
       break by buf_tt-line.grp-code
             by supp-type
             by supp-code
      :
         IF FIRST-OF(buf_tt-line.grp-code)
         THEN DO:
            FIND FIRST tt-total
                 where tt-total.grp-code = buf_tt-line.grp-code
                 .
            assign
               v-number = v-number + 1
            v-grp-name = buf_tt-line.grp-name
            .
         END.
      IF buf_tt-line.prod-summ-sale <> 0
      THEN DO:
            put stream excel-line unformatted
                                 {&salest-sheet1-name}
                  {&tabulation}   {&salest-data-label}
                  {&tabulation}   " "
               {&tabulation}   v-grp-name
                  {&tabulation}   buf_tt-line.supp-name
               {&tabulation}   STRING(buf_tt-line.prod-summ-sale, "->>>,>>>,>>9")
               {&tabulation}   IF (buf_tt-line.prod-summ-sale / tt-total.grp-summ-sale * 100) <> ? THEN buf_tt-line.prod-summ-sale / tt-total.grp-summ-sale * 100 ELSE 0
               {&tabulation}   " "
               {&tabulation}   " "
               {&tabulation}   " "
               {&new-line}
         .
         assign
            v-grp-name = " "
            .
      END.

      ASSIGN
         v-total-supp = v-total-supp + buf_tt-line.prod-summ-sale
      .

      /* Итого по ппоставщику
      IF LAST-OF(buf_tt-line.supp-code)
      THEN DO:
         put stream excel-line unformatted
                              {&salest-sheet1-name}
               {&tabulation}   {&salest-data-label}
               {&tabulation}   " "
               {&tabulation}   " "
               {&tabulation}   "Итого:"
               {&tabulation}   STRING(v-total-supp, "->>>,>>>,>>9")
               {&tabulation}   v-total-supp / tt-total.grp-summ-sale * 100
               {&tabulation}   " "
               {&tabulation}   " "
               {&tabulation}   " "
               {&new-line}
         .
      END.
      */

      /* итого по группе */
      IF LAST-OF(buf_tt-line.grp-code)
      THEN DO:
         IF v-grp-name <> " "
         THEN DO:
         put stream excel-line unformatted
                              {&salest-sheet1-name}
               {&tabulation}   {&salest-data-label}
               {&tabulation}   " "
                  {&tabulation}   v-grp-name
                  {&tabulation}   " "
                  {&tabulation}   STRING(buf_tt-line.prod-summ-sale, "->>>,>>>,>>9")
                  {&tabulation}   IF (v-total-supp / tt-total.grp-summ-sale * 100) <> ? THEN v-total-supp / tt-total.grp-summ-sale * 100 ELSE 0
               {&tabulation}   " "
               {&tabulation}   " "
               {&tabulation}   " "
                  {&new-line}
            .
            assign
               v-grp-name = " "
            .
         END.
         put stream excel-line unformatted
                              {&salest-sheet1-name}
               {&tabulation}   {&salest-data-label}
               {&tabulation}   " "
               {&tabulation}   "Итого:"
               {&tabulation}   " "
               {&tabulation}   " "
               {&tabulation}   " "
               {&tabulation}   STRING(tt-total.grp-summ-sale, "->>>,>>>,>>9")
               {&tabulation}   IF (tt-total.grp-summ-sale / v-total-sale * 100) <> ? THEN tt-total.grp-summ-sale / v-total-sale * 100 ELSE 0
               {&tabulation}   IF ((tt-total.grp-summ-sale - tt-total.grp-summ-cost) / tt-total.grp-summ-sale * 100) <> ? THEN (tt-total.grp-summ-sale - tt-total.grp-summ-cost) / tt-total.grp-summ-sale * 100 ELSE 0
               {&new-line}
         .
         put stream excel-line unformatted
                           {&salest-sheet1-name}
            {&tabulation}  {&salest-format-label}
            {&tabulation}   "h3"
            {&new-line}
         .
      END.
   end.
end.
end procedure. /* salest-sheet1-write-line-data */


/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure salest-write-cell-data :
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
end procedure. /* salest-write-cell-data */

/*==========================================================================*/
procedure salest-run-excel :
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
        v-template-file-name    = search( "exe/salest.xlt" )
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
end procedure. /* salest-run-excel */


/*==========================================================================*/
procedure salest-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/salest.xlt" .
        export "exe/t_form.bas" .
        export v-salest-cell-file-name.
        export v-salest-data-file-name.
    output close.
end.
end procedure. /* salest-close */


/* $Workfile$ e n d */