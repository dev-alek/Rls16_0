/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Белоусов Илья Александрович
Дата создания: 05/07/08
Author: Ilia Belousov
Creation date: 05/07/08

Required:

*/
DEFINE TEMP-TABLE tt-grp NO-UNDO
      FIELD grp-name    as character
      FIELD grp-code    as integer

      INDEX pi IS PRIMARY UNIQUE
            grp-code
.

DEFINE TEMP-TABLE tt-wth-par NO-UNDO
      FIELD number         as integer    /* 1 № */
      FIELD wth-name       as character  /* 2 топливо */
      FIELD wth-par-name   as character  /* 3 номинал */
      FIELD wth-par-code   as integer
      FIELD wth-code       as integer
      FIELD par-rate       as decimal

      INDEX pi IS PRIMARY UNIQUE
            wth-code
            wth-par-code
      INDEX i-print
            number
.

DEFINE TEMP-TABLE tt-line NO-UNDO
      /* */
      FIELD grp-code       as integer
      FIELD wth-code       as integer
      FIELD wth-par-code   as integer

      /* */
      FIELD summ-4      as integer    format "->>>>>9"     /* 4 штук талонов */
      FIELD summ-5      as decimal    format "->>>>>9.999" /* 5 литры талонов */
      FIELD summ-6      as decimal    format "->>>>>9.99"  /* 6 сумма талонов */
      FIELD summ-7      as decimal    format "->>>>>9.999" /* 7 возврат литры талонов */
      FIELD summ-8      as decimal    format "->>>>>9.99"  /* 8 возврат сумма талонов */
      FIELD summ-9      as decimal    format "->>>>>9.999" /* 9  продано */
      FIELD summ-10     as decimal    format "->>>>>9.99"  /* 10 продано */
      FIELD summ-11     as decimal    format "->>>>>9.999" /* 11 продано */
      FIELD summ-12     as decimal    format "->>>>>9.99"  /* 12 продано */
      /* FIELD summ-13     as decimal format "->>>>>9.999"    13 5 - 9  считается при печати */
      /* FIELD summ-14     as decimal format "->>>>>9.99"     14 6 - 10 считается при печати */
      FIELD summ-15     as decimal    format "->>>>>9.999" /* 15 */
      FIELD summ-16     as decimal    format "->>>>>9.99"  /* 16 */

      INDEX pi IS PRIMARY UNIQUE
            grp-code
            wth-par-code
            wth-code
.


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


&global-define wthcom-data-label "DTA":U
&global-define wthcom-format-label "FMT":U

&global-define wthcom-sheetList  "Template":U

&global-define wthcom-sheet1_valutCode       "Template_valutCode":U
&global-define wthcom-sheet1_columnList      "Template_columnList":U
&global-define wthcom-sheet1_columnType      "Template_columnType":U
&global-define wthcom-sheet1_subtotalList    "Template_subtotalList":U
&global-define wthcom-sheet1_subtotalType    "Template_subtotalType":U

&global-define wthcom-sheet1-name            "Template":U
&global-define wthcom-sheet1-date1           "h_date1":U
&global-define wthcom-sheet1-dir             "h_dir":U
&global-define wthcom-sheet1-glbuh           "h_glbuh":U
&global-define wthcom-sheet1-oper            "h_oper":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.



define variable v-wthcom-sheet1-cur-data-row     as integer      no-undo.

define variable v-wthcom-cell-file-name       as character    no-undo.
define variable v-wthcom-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure wthcom-init :

do
on error undo, return error
:
    assign
        v-wthcom-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-wthcom-data-file-name
    ).
    output stream excel-line to value( v-wthcom-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-wthcom-cell-file-name
    ).
    output stream excel-cell to value( v-wthcom-cell-file-name ).
    run wthcom-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&wthcom-sheetList}
    ).
    if printrubl
    then do:
        run wthcom-write-cell-data in this-procedure (
              input {&wthcom-sheet1_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run wthcom-write-cell-data in this-procedure (
              input {&wthcom-sheet1_valutCode}
            , input "1":U
        ).
    end.


    run wthcom-write-cell-data in this-procedure (
          input {&wthcom-sheet1_columnList}
        , input "number,wth_name,wth_par_name,summ_4,summ_5,summ_6,summ_7,summ_8,summ_9,summ_10,summ_11,summ_12,summ_13,summ_14,summ_15,summ_16":U
    ).
    run wthcom-write-cell-data in this-procedure (
          input {&wthcom-sheet1_columnType}
        , input "S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S":U
    ).
    run wthcom-write-cell-data in this-procedure (
          input {&wthcom-sheet1_subtotalList}
        , input "":U
    ).
    run wthcom-write-cell-data in this-procedure (
          input {&wthcom-sheet1_subtotalType}
        , input "":U
    ).

end.
end procedure. /* wthcom-init */


/*==========================================================================*/
procedure wthcom-sheet1-write-line-data :

define buffer buf_tt-line     for tt-line .
define buffer buf_tt-grp      for tt-grp .
define buffer buf_tt-wth-par  for tt-wth-par .

define variable v-summ-4-it  as decimal format "->>>>>9"     no-undo .
define variable v-summ-5-it  as decimal format "->>>>>9.999" no-undo .
define variable v-summ-6-it  as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-7-it  as decimal format "->>>>>9.999" no-undo .
define variable v-summ-8-it  as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-9-it  as decimal format "->>>>>9.999" no-undo .
define variable v-summ-10-it as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-11-it as decimal format "->>>>>9.999" no-undo .
define variable v-summ-12-it as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-13-it as decimal format "->>>>>9.999" no-undo .
define variable v-summ-14-it as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-15-it as decimal format "->>>>>9.999" no-undo .
define variable v-summ-16-it as decimal format "->>>>>9.99"  no-undo .

define variable v-summ-4-vs  as decimal format "->>>>>9"     no-undo .
define variable v-summ-5-vs  as decimal format "->>>>>9.999" no-undo .
define variable v-summ-6-vs  as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-7-vs  as decimal format "->>>>>9.999" no-undo .
define variable v-summ-8-vs  as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-9-vs  as decimal format "->>>>>9.999" no-undo .
define variable v-summ-10-vs as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-11-vs as decimal format "->>>>>9.999" no-undo .
define variable v-summ-12-vs as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-13-vs as decimal format "->>>>>9.999" no-undo .
define variable v-summ-14-vs as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-15-vs as decimal format "->>>>>9.999" no-undo .
define variable v-summ-16-vs as decimal format "->>>>>9.99"  no-undo .

do
on error undo, return error
:
   for each buf_tt-grp
      :
      /* заголовок группы клиентов */
      put stream excel-line unformatted
                            {&wthcom-sheet1-name}
            {&tabulation}   {&wthcom-data-label}
            {&tabulation}   buf_tt-grp.grp-name
            {&tabulation}   " "
            {&tabulation}   " "
            {&tabulation}   " "
            {&tabulation}   " "
            {&tabulation}   " "
            {&tabulation}   " "
            {&tabulation}   " "
            {&tabulation}   " "
            {&tabulation}   " "
            {&tabulation}   " "
            {&tabulation}   " "
            {&tabulation}   " "
            {&tabulation}   " "
            {&tabulation}   " "
            {&tabulation}   " "
            {&new-line}
      .

      put stream excel-line unformatted
                        {&wthcom-sheet1-name}
         {&tabulation}  {&wthcom-format-label}
         {&tabulation}   "Заголовок1"
         {&new-line}
      .


      assign
         v-summ-4-it  = 0
         v-summ-5-it  = 0
         v-summ-6-it  = 0
         v-summ-7-it  = 0
         v-summ-8-it  = 0
         v-summ-9-it  = 0
         v-summ-10-it = 0
         v-summ-11-it = 0
         v-summ-12-it = 0
         v-summ-13-it = 0
         v-summ-14-it = 0
         v-summ-15-it = 0
         v-summ-16-it = 0
      .
      FOR EACH buf_tt-wth-par
          by number
         :
         FOR each buf_tt-line
            where buf_tt-line.grp-code       = buf_tt-grp.grp-code
              and buf_tt-line.wth-code       = buf_tt-wth-par.wth-code
              and buf_tt-line.wth-par-code   = buf_tt-wth-par.wth-par-code
            :
            put stream excel-line unformatted
                                  {&wthcom-sheet1-name}
                  {&tabulation}   {&wthcom-data-label}
                  {&tabulation}    buf_tt-wth-par.number
                  {&tabulation}    buf_tt-wth-par.wth-name
                  {&tabulation}    buf_tt-wth-par.wth-par-name
                  {&tabulation}       buf_tt-line.summ-4                                 format "->>>>>>>>>>9"
                  {&tabulation}       buf_tt-line.summ-5                                 format "->>>>>>>>>>9.999"
                  {&tabulation}       buf_tt-line.summ-6                                 format "->>>>>>>>>>9.99"
                  {&tabulation}       buf_tt-line.summ-7                                 format "->>>>>>>>>>9.999"
                  {&tabulation}       buf_tt-line.summ-8                                 format "->>>>>>>>>>9.99"
                  {&tabulation}       buf_tt-line.summ-9                                 format "->>>>>>>>>>9.999"
                  {&tabulation}       buf_tt-line.summ-10                                format "->>>>>>>>>>9.99"
                  {&tabulation}       buf_tt-line.summ-11                                format "->>>>>>>>>>9.999"
                  {&tabulation}       buf_tt-line.summ-12                                format "->>>>>>>>>>9.99"
                  {&tabulation}     ( buf_tt-line.summ-5        - buf_tt-line.summ-9  )  format "->>>>>>>>>>9.999"
                  {&tabulation}     ( buf_tt-line.summ-6        - buf_tt-line.summ-10 )  format "->>>>>>>>>>9.99"
                  {&tabulation}       buf_tt-line.summ-15                                format "->>>>>>>>>>9.999"
                  {&tabulation}       buf_tt-line.summ-16                                format "->>>>>>>>>>9.99"
                  {&new-line}
            .
            assign
               v-summ-4-it  = v-summ-4-it   +   buf_tt-line.summ-4
               v-summ-5-it  = v-summ-5-it   +   buf_tt-line.summ-5
               v-summ-6-it  = v-summ-6-it   +   buf_tt-line.summ-6
               v-summ-7-it  = v-summ-7-it   +   buf_tt-line.summ-7
               v-summ-8-it  = v-summ-8-it   +   buf_tt-line.summ-8
               v-summ-9-it  = v-summ-9-it   +   buf_tt-line.summ-9
               v-summ-10-it = v-summ-10-it  +   buf_tt-line.summ-10
               v-summ-11-it = v-summ-11-it  +   buf_tt-line.summ-11
               v-summ-12-it = v-summ-12-it  +   buf_tt-line.summ-12
               v-summ-13-it = v-summ-13-it  + ( buf_tt-line.summ-5        - buf_tt-line.summ-9  )
               v-summ-14-it = v-summ-14-it  + ( buf_tt-line.summ-6        - buf_tt-line.summ-10 )
               v-summ-15-it = v-summ-15-it  +   buf_tt-line.summ-15
               v-summ-16-it = v-summ-16-it  +   buf_tt-line.summ-16

               v-summ-4-vs  = v-summ-4-vs   +   buf_tt-line.summ-4
               v-summ-5-vs  = v-summ-5-vs   +   buf_tt-line.summ-5
               v-summ-6-vs  = v-summ-6-vs   +   buf_tt-line.summ-6
               v-summ-7-vs  = v-summ-7-vs   +   buf_tt-line.summ-7
               v-summ-8-vs  = v-summ-8-vs   +   buf_tt-line.summ-8
               v-summ-9-vs  = v-summ-9-vs   +   buf_tt-line.summ-9
               v-summ-10-vs = v-summ-10-vs  +   buf_tt-line.summ-10
               v-summ-11-vs = v-summ-11-vs  +   buf_tt-line.summ-11
               v-summ-12-vs = v-summ-12-vs  +   buf_tt-line.summ-12
               v-summ-13-vs = v-summ-13-vs  + ( buf_tt-line.summ-5        - buf_tt-line.summ-9  )
               v-summ-14-vs = v-summ-14-vs  + ( buf_tt-line.summ-6        - buf_tt-line.summ-10 )
               v-summ-15-vs = v-summ-15-vs  +   buf_tt-line.summ-15
               v-summ-16-vs = v-summ-16-vs  +   buf_tt-line.summ-16
           .
         END.
      end.
      /* Итого по группе */
      put stream excel-line unformatted
                            {&wthcom-sheet1-name}
            {&tabulation}   {&wthcom-data-label}
            {&tabulation}   ""
            {&tabulation}   "  ИТОГО:"
            {&tabulation}   " "
            {&tabulation}   v-summ-4-it   format "->>>>>>>>>>>9"
            {&tabulation}   v-summ-5-it   format "->>>>>>>>>>>9.999"
            {&tabulation}   v-summ-6-it   format "->>>>>>>>>>>9.99"
            {&tabulation}   v-summ-7-it   format "->>>>>>>>>>>9.999"
            {&tabulation}   v-summ-8-it   format "->>>>>>>>>>>9.99"
            {&tabulation}   v-summ-9-it   format "->>>>>>>>>>>9.999"
            {&tabulation}   v-summ-10-it  format "->>>>>>>>>>>9.99"
            {&tabulation}   v-summ-11-it  format "->>>>>>>>>>>9.999"
            {&tabulation}   v-summ-12-it  format "->>>>>>>>>>>9.99"
            {&tabulation}   v-summ-13-it  format "->>>>>>>>>>>9.999"
            {&tabulation}   v-summ-14-it  format "->>>>>>>>>>>9.99"
            {&tabulation}   v-summ-15-it  format "->>>>>>>>>>>9.999"
            {&tabulation}   v-summ-16-it  format "->>>>>>>>>>>9.99"
            {&new-line}
      .
   end.
   /* Всего */
   put stream excel-line unformatted
                           {&wthcom-sheet1-name}
         {&tabulation}   {&wthcom-data-label}
         {&tabulation}   ""
         {&tabulation}   "  ВСЕГО:"
         {&tabulation}   " "
         {&tabulation}   v-summ-4-vs    format "->>>>>>>>>>>>>9"
         {&tabulation}   v-summ-5-vs    format "->>>>>>>>>>>>>9.999"
         {&tabulation}   v-summ-6-vs    format "->>>>>>>>>>>>>9.99"
         {&tabulation}   v-summ-7-vs    format "->>>>>>>>>>>>>9.999"
         {&tabulation}   v-summ-8-vs    format "->>>>>>>>>>>>>9.99"
         {&tabulation}   v-summ-9-vs    format "->>>>>>>>>>>>>9.999"
         {&tabulation}   v-summ-10-vs   format "->>>>>>>>>>>>>9.99"
         {&tabulation}   v-summ-11-vs   format "->>>>>>>>>>>>>9.999"
         {&tabulation}   v-summ-12-vs   format "->>>>>>>>>>>>>9.99"
         {&tabulation}   v-summ-13-vs   format "->>>>>>>>>>>>>9.999"
         {&tabulation}   v-summ-14-vs   format "->>>>>>>>>>>>>9.99"
         {&tabulation}   v-summ-15-vs   format "->>>>>>>>>>>>>9.999"
         {&tabulation}   v-summ-16-vs   format "->>>>>>>>>>>>>9.99"
         {&new-line}
   .
end.
end procedure. /* wthcom-sheet1-write-line-data */


/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure wthcom-write-cell-data :
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
end procedure. /* wthcom-write-cell-data */

/*==========================================================================*/
procedure wthcom-run-excel :
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
        v-template-file-name    = search( "exe/wth_com.xlt" )
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
end procedure. /* wthcom-run-excel */


/*==========================================================================*/
procedure wthcom-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/wth_com.xlt" .
        export "exe/t_form.bas" .
        export v-wthcom-cell-file-name.
        export v-wthcom-data-file-name.
    output close.
end.
end procedure. /* wthcom-close */


/* $Workfile$ e n d */