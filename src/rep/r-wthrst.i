/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Белоусов Илья Александрович
Дата создания: 05/12/09
Author: Ilia Belousov
Creation date: 05/12/09

Required:

*/

DEFINE TEMP-TABLE tt-line NO-UNDO
      FIELD wth-code       as integer
      FIELD wth-name       as character
      FIELD wth-num        as character
      FIELD wth-par-code   as integer
      FIELD obj-type       as character
      FIELD obj-code       as integer
      FIELD obj-name       as character
      FIELD summ-4         as integer    format "->>>>>9"     /* 4 штук талонов */
      FIELD summ-5         as decimal    format "->>>>>9.999" /* 5 литры талонов */
      FIELD summ-6         as integer    format "->>>>>9"     /* 4 штук талонов */
      FIELD summ-7         as decimal    format "->>>>>9.999" /* 5 литры талонов */
      INDEX pi IS PRIMARY UNIQUE
            wth-code
            wth-par-code
            obj-type
            obj-code
.

define temp-table temp_hideCol no-undo
    field colName   as character

    index pi is primary unique
        colName
.

define variable sym1                as character init "|"   no-undo .
define variable sym2                as character init "|"   no-undo .
define variable sym3                as character init "|"   no-undo .
define variable sym4                as character init "|"   no-undo .
define variable sym5                as character init "|"   no-undo .
define variable sym6                as character init "|"   no-undo .
define variable sym7                as character init "|"   no-undo .
define variable sym8                as character init "|"   no-undo .
define variable sym9                as character init "|"   no-undo .

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


&global-define wthrst-data-label "DTA":U
&global-define wthrst-format-label "FMT":U

&global-define wthrst-sheetList  "Template":U

&global-define wthrst-sheet1_valutCode       "Template_valutCode":U
&global-define wthrst-sheet1_columnList      "Template_columnList":U
&global-define wthrst-sheet1_columnType      "Template_columnType":U
&global-define wthrst-sheet1_subtotalList    "Template_subtotalList":U
&global-define wthrst-sheet1_subtotalType    "Template_subtotalType":U

&global-define wthrst-sheet1-name            "Template":U
&global-define wthrst-sheet1-date1           "h_date1":U
&global-define wthrst-sheet1-firm            "h_firm":U
&global-define wthrst-sheet1-obj-list        "h_obj_list":U
&global-define wthrst-sheet1-wth-list        "h_wth_list":U

&global-define wthrst-sheet1_hideColList     "Template_hideColList":U
&global-define wthrst-sheet1_withoutFree     "summ4,summ5":U
&global-define wthrst-sheet1_withoutPut      "summ6,summ7":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.



define variable v-wthrst-sheet1-cur-data-row     as integer      no-undo.

define variable v-wthrst-cell-file-name       as character    no-undo.
define variable v-wthrst-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure wthrst-init :

do
on error undo, return error
:
    assign
        v-wthrst-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-wthrst-data-file-name
    ).
    output stream excel-line to value( v-wthrst-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-wthrst-cell-file-name
    ).
    output stream excel-cell to value( v-wthrst-cell-file-name ).
    run wthrst-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&wthrst-sheetList}
    ).
    if printrubl
    then do:
        run wthrst-write-cell-data in this-procedure (
              input {&wthrst-sheet1_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run wthrst-write-cell-data in this-procedure (
              input {&wthrst-sheet1_valutCode}
            , input "1":U
        ).
    end.


    run wthrst-write-cell-data in this-procedure (
          input {&wthrst-sheet1_columnList}
        , input "wth_name,wth_num,obj_num,obj_name,summ4,summ5,summ6,summ7":U
    ).
    run wthrst-write-cell-data in this-procedure (
          input {&wthrst-sheet1_columnType}
        , input "S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S":U
    ).
    run wthrst-write-cell-data in this-procedure (
          input {&wthrst-sheet1_subtotalList}
        , input "":U
    ).
    run wthrst-write-cell-data in this-procedure (
          input {&wthrst-sheet1_subtotalType}
        , input "":U
    ).

end.
end procedure. /* wthrst-init */


/*==========================================================================*/
procedure wthrst-sheet1-write-line-data :

define buffer buf_tt-line     for tt-line .

define variable v-summ-4-it  as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-5-it  as decimal format "->>>>>9.999" no-undo .
define variable v-summ-6-it  as decimal format "->>>>>9.99"  no-undo .
define variable v-summ-7-it  as decimal format "->>>>>9.999" no-undo .

define variable v-obj-num    as character    no-undo.

/*  define frame f-wthrst*/
/*    sym1                         no-label format "X(1)"              space(0)*/
/*    buf_tt-line.wth-name         no-label format "X(40)"             space(0)*/
/*    sym2                         no-label format "X(1)"              space(0)*/
/*    buf_tt-line.wth-num          no-label format "X(16)"             space(0)*/
/*    sym3                         no-label format "X(1)"              space(0)*/
/*    v-obj-num                    no-label format "X(10)"             space(0)*/
/*    sym4                         no-label format "X(1)"              space(0)*/
/*    buf_tt-line.obj-name         no-label format "x(40)"             space(0)*/
/*    sym5                         no-label format "X(1)"              space(0)*/
/*    buf_tt-line.summ-4           no-label format "->>>>>>>>>>9"      space(0)*/
/*    sym6                         no-label format "X(1)"              space(0)*/
/*    buf_tt-line.summ-5           no-label format "->>>>>>>>>>9.999"  space(0)*/
/*    sym7                         no-label format "X(1)"              space(0)*/
/*    buf_tt-line.summ-6           no-label format "->>>>>>>>>>9"      space(0)*/
/*    sym8                         no-label format "X(1)"              space(0)*/
/*    buf_tt-line.summ-7           no-label format "->>>>>>>>>>9.999"  space(0)*/
/*    sym9                         no-label format "X(1)"              space(0)*/
/*    skip*/
/*  header*/
/*    "+----------------------------------------+----------------+----------+----------------------------------------+------------+----------------+------------+----------------+" skip*/
/*    "|                                        |                |          |                                        |       Свободная зона        |       Зона погашения        |" skip*/
/*    "|             Наименование  МЦ           |     Номинал    |  Объект  |         Наименование  объекта          +------------+----------------+------------+----------------+" skip*/
/*    "|                                        |                |          |                                        |     шт.    |       лт.      |     шт.    |       лт.      |" skip*/
/*    "+----------------------------------------+----------------+----------+----------------------------------------+------------+----------------+------------+----------------+" skip*/
/*  with width 173 down stream-io no-labels no-box.*/

do
on error undo, return error
:
   run PutColumnTitul in this-procedure .

   FOR each buf_tt-line
       BREAK BY buf_tt-line.wth-code
             BY buf_tt-line.wth-par-code
      :
      if line-counter( Out-stream ) + 3 > page-size( Out-stream ) then do:
         put stream out-stream unformatted
            "+----------------------------------------+----------------+----------+----------------------------------------+"
            IF p-free-zone THEN "------------+----------------+" ELSE "":U
            IF p-put-zone  THEN "------------+----------------+" ELSE "":U
            skip
         .
         put stream out-stream  "Стр." PAGE-NUMBER( out-stream ) "Продолжение - на следующей странице" AT 30 SKIP .
         page stream Out-Stream .
         run PutColumnTitul in this-procedure .
      end.

      put stream excel-line unformatted
                            {&wthrst-sheet1-name}
            {&tabulation}   {&wthrst-data-label}
            {&tabulation}   buf_tt-line.wth-name
            {&tabulation}   buf_tt-line.wth-num
            {&tabulation}   SUBSTITUTE ("&1 &2", buf_tt-line.obj-code, buf_tt-line.obj-type)
            {&tabulation}   buf_tt-line.obj-name
            {&tabulation}   buf_tt-line.summ-4   format "->>>>>>>>>>9"
            {&tabulation}   buf_tt-line.summ-5   format "->>>>>>>>>>9.999"
            {&tabulation}   buf_tt-line.summ-6   format "->>>>>>>>>>9"
            {&tabulation}   buf_tt-line.summ-7   format "->>>>>>>>>>9.999"
            {&new-line}
      .
      put stream out-stream unformatted
         sym9
         buf_tt-line.wth-name    format "X(40)" sym1
         buf_tt-line.wth-num     format "X(16)" sym2
         SUBSTITUTE ("&1 &2", buf_tt-line.obj-code, buf_tt-line.obj-type) format "X(10)" sym3
         buf_tt-line.obj-name    format "X(40)" sym4
      .
      IF p-free-zone THEN
      put stream out-stream unformatted
         buf_tt-line.summ-4      format "->>>>>>>>>>9" sym5
         buf_tt-line.summ-5      format "->>>>>>>>>>9.999" sym6
      .
      IF p-put-zone THEN
      put stream out-stream unformatted
         buf_tt-line.summ-6      format "->>>>>>>>>>9"  sym7
         buf_tt-line.summ-7      format "->>>>>>>>>>9.999"  sym8
      .
      put stream out-stream unformatted
         skip
      .
      /*      down stream out-stream with frame f-wthrst.*/
      assign
         v-summ-4-it  = v-summ-4-it   +   buf_tt-line.summ-4
         v-summ-5-it  = v-summ-5-it   +   buf_tt-line.summ-5
         v-summ-6-it  = v-summ-6-it   +   buf_tt-line.summ-6
         v-summ-7-it  = v-summ-7-it   +   buf_tt-line.summ-7
      .
      IF LAST-OF (buf_tt-line.wth-par-code)
      THEN DO:
         /* Итого по номиналу */
         put stream excel-line unformatted
                              {&wthrst-sheet1-name}
               {&tabulation}   {&wthrst-data-label}
               {&tabulation}   buf_tt-line.wth-name
               {&tabulation}   buf_tt-line.wth-num
               {&tabulation}   " "
               {&tabulation}   " ИТОГО:"
               {&tabulation}   v-summ-4-it   format "->>>>>>>>>>>9"
               {&tabulation}   v-summ-5-it   format "->>>>>>>>>>>9.999"
               {&tabulation}   v-summ-6-it   format "->>>>>>>>>>>9"
               {&tabulation}   v-summ-7-it   format "->>>>>>>>>>>9.999"
               {&new-line}
         .
         put stream out-stream unformatted
               sym9
               buf_tt-line.wth-name format "X(40)"             sym1
               buf_tt-line.wth-num  format "X(16)"             sym2
               " "                  format "X(10)"             sym3
               " ИТОГО:     "       format "X(40)"             sym4
         .
         IF p-free-zone THEN
         put stream out-stream unformatted
               v-summ-4-it          format "->>>>>>>>>>9"      sym5
               v-summ-5-it          format "->>>>>>>>>>9.999"  sym6
         .
         IF p-put-zone THEN
         put stream out-stream unformatted
               v-summ-6-it          format "->>>>>>>>>>9"      sym7
               v-summ-7-it          format "->>>>>>>>>>9.999"  sym8
         .
         put stream out-stream unformatted
               skip
         .
         put stream out-stream unformatted
            "+----------------------------------------+----------------+----------+----------------------------------------+"
         .
         IF p-free-zone THEN
         put stream out-stream unformatted
         "------------+----------------+"
         .
         IF p-put-zone THEN
         put stream out-stream unformatted
         "------------+----------------+"
         .
         put stream out-stream unformatted
            skip
         .
         assign
            v-summ-4-it  = 0
            v-summ-5-it  = 0
            v-summ-6-it  = 0
            v-summ-7-it  = 0
         .
      END.
   END.

end.
end procedure. /* wthrst-sheet1-write-line-data */


/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure wthrst-write-cell-data :
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
end procedure. /* wthrst-write-cell-data */

/*==========================================================================*/
procedure wthrst-run-excel :
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
        v-template-file-name    = search( "exe/wthrst.xlt" )
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
end procedure. /* wthrst-run-excel */


/*==========================================================================*/
procedure wthrst-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/wthrst.xlt" .
        export "exe/t_form.bas" .
        export v-wthrst-cell-file-name.
        export v-wthrst-data-file-name.
    output close.
end.
end procedure. /* wthrst-close */


         PROCEDURE PutColumnTitul :
/* -----------------------------------------------------------
  Purpose:     Печать заголовка
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  put stream out-stream unformatted
    "+----------------------------------------+----------------+----------+----------------------------------------+"
    IF p-free-zone THEN "------------+----------------+" ELSE "":U
    IF p-put-zone  THEN "------------+----------------+" ELSE "":U
    skip
  .


  put stream out-stream unformatted
    "|                                        |                |          |                                        |"
    IF p-free-zone THEN "       Свободная зона        |" ELSE "":U
    IF p-put-zone  THEN "       Зона погашения        |" ELSE "":U
    skip
  .
  put stream out-stream unformatted
    "|             Наименование  МЦ           |     Номинал    |  Объект  |         Наименование  объекта          +"
    IF p-free-zone THEN "------------+----------------+" ELSE "":U
    IF p-put-zone  THEN "------------+----------------+" ELSE "":U
    skip
  .
  put stream out-stream unformatted
    "|                                        |                |          |                                        |"
    IF p-free-zone THEN "     шт.    |       лт.      |" ELSE "":U
    IF p-put-zone  THEN "     шт.    |       лт.      |" ELSE "":U
    skip
  .
  put stream out-stream unformatted
    "+----------------------------------------+----------------+----------+----------------------------------------+"
    IF p-free-zone THEN "------------+----------------+" ELSE "":U
    IF p-put-zone  THEN "------------+----------------+" ELSE "":U
    skip
  .

END PROCEDURE.

/* $Workfile$ e n d */