/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы KM-6 в Excel

Автор: Комаров Иван Сергеевич
Дата создания: 06/01/10
Author: Ivan Komarov
Creation date: 06/01/10

Автор1: Белоусов Илья Александрович
Дата создания1: 18.08.08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


&global-define km6xl-data-label           "DTA":U
&global-define km6xl-format-label         "FMT":U

&global-define km6xl-line-data-key        "LD":U
&global-define km6xl-valutCode            "valutCode":U
&global-define km6xl-columnList           "columnList":U
&global-define km6xl-columnType           "columnType":U
&global-define km6xl-columnAmount         "columnAmount":U

&global-define km6xl-subtotalList         "subtotalList":U
&global-define km6xl-subtotalType         "subtotalType":U
&global-define km6xl-subtotalAmount       "subtotalAmount":U
&global-define km6xl-subtotalPropisList   "subtotalPropisList":U
&global-define km6xl-subtotalPropisAmount "subtotalPropisAmount":U

&global-define km6xl-h_organization       "h_organization":U
&global-define km6xl-h_organization2      "h_organization2":U
&global-define km6xl-h_object             "h_object":U
&global-define km6xl-h_docCode            "h_docCode":U
&global-define km6xl-h_docDate            "h_DocDate":U
&global-define km6xl-h_DocTime1           "h_DocTime1":U
&global-define km6xl-h_DocTime2           "h_DocTime2":U
&global-define km6xl-h_docTime            "h_DocTime":U
&global-define km6xl-h_OKPO               "h_OKPO":U
&global-define km6xl-h_INN                "h_INN":U
&global-define km6xl-h_KKM_prod           "h_KKM_prod":U
&global-define km6xl-h_KKM_prog           "h_KKM_prog":U
&global-define km6xl-h_KKM_reg            "h_KKM_reg":U
&global-define km6xl-h_descname           "h_deskname":U
&global-define km6xl-h_shift              "h_shift":U

&global-define km6xl-f_boss               "f_boss":U
&global-define km6xl-f_post               "f_post":U
&global-define km6xl-f_cashier            "f_cashier":U
&global-define km6xl-f_senior_cashier     "f_senior_cashier":U
&global-define km6xl-f-pko-num            "f_pko_num":U
&global-define km6xl-f-day-date           "f_day_date":U
&global-define km6xl-f-month-date         "f_month_date":U
&global-define km6xl-f-year-date          "f_year_date":U

&global-define km6xl-it_Summ              "it_Summ":U
&global-define km6xl-it_kop               "it_kop":U
&global-define km6xl-it_Summ_return       "it_Summ_return":U
&global-define km6xl-it_s_Summ_1          "it_s_Summ_1":U
&global-define km6xl-it_s_Summ_2          "it_s_Summ_2":U


define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.
define temp-table temp_line-data no-undo
      field sheet-name       as character
      field data-key         as character
      field xl-line-id       as integer
      FIELD d_znumber        as INTEGER
      FIELD d_empty2         as character
      FIELD d_empty3         as character
      FIELD d_empty4         as character
      FIELD d_empty5         as character
      FIELD d_empty6         as character
      FIELD d_summ-sale-7    as character
      FIELD d_zerocounter    as INTEGER
      FIELD d_summbegin      as DECIMAL
      FIELD d_summend        as DECIMAL
      FIELD d_summdelta      as DECIMAL
      FIELD d_summreturn     as DECIMAL
      FIELD d_person         as character
      FIELD d_empty10        as character
/*    index pi is primary unique*/
/*          xl-line-id*/
.

define variable v-km6xl-cell-file-name       as character    no-undo.
define variable v-km6xl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure km6xl-init :

define input parameter p-first-sheet          as logical no-undo .
define input parameter p-sheet-name           as character no-undo .
define input parameter p-sheet-list           as character no-undo .
define input parameter p-sheet-list-copy-from as character no-undo .

define buffer buf_temp_cell-data        for temp_cell-data.
define buffer buf_usr-flt               for ubflt.usr-flt.
do
for buf_temp_cell-data
  , buf_usr-flt
on error undo, return error
:

    if p-first-sheet then do:
      run gbl/_tmpfile.p (
            input "xd"
          , input ".txt"
          , output v-km6xl-data-file-name
      ).
      output stream excel-line to value( v-km6xl-data-file-name ).
      run gbl/_tmpfile.p (
            input "xc"
          , input ".txt"
          , output v-km6xl-cell-file-name
      ).
      output stream excel-cell to value( v-km6xl-cell-file-name ).
      run km6xl-write-cell-data in this-procedure (
            input "sheetListcopyfrom":U
          , input p-sheet-list-copy-from
      ).

      run km6xl-write-cell-data in this-procedure (
            input "sheetList":U
          , input p-sheet-list
      ).
    end.

/*    run gbl/_tmpfile.p (*/
/*          input "xd"*/
/*        , input ".txt"*/
/*        , output v-km6xl-data-file-name*/
/*    ).*/
/*    output stream excel-line to value( v-km6xl-data-file-name ).*/
/*    run gbl/_tmpfile.p (*/
/*          input "xc"*/
/*        , input ".txt"*/
/*        , output v-km6xl-cell-file-name*/
/*    ).*/
/*    output stream excel-cell to value( v-km6xl-cell-file-name ).*/

    if printrubl = yes
    then do:
        run km6xl-write-cell-data in this-procedure (
              input substitute("&1_&2"
                               , p-sheet-name
                               , {&km6xl-valutCode}
                               )
            , input "0":U
        ).
    end.
    else do:
        run km6xl-write-cell-data in this-procedure (
              input substitute("&1_&2"
                               , p-sheet-name
                               , {&km6xl-valutCode}
                               )
            , input "1":U
        ).
    end.
    run km6xl-write-cell-data in this-procedure (
          input substitute("&1_&2"
                          , p-sheet-name
                          , {&km6xl-columnList}
                           )
        , input "znumber,empty2,empty3,zerocounter,summbegin,summend,summdelta,summreturn,person,empty10":U
    ).
    run km6xl-write-cell-data in this-procedure (
          input substitute("&1_&2"
                          , p-sheet-name
                          , {&km6xl-columnType}
                          )
        , input "I,S,S,I,D,D,D,D,S,S":U
    ).
    run km6xl-write-cell-data in this-procedure (
          input substitute("&1_&2"
                          , p-sheet-name
                          , {&km6xl-columnAmount}
                          )
        , input "10":U
    ).  /*
    run km6xl-write-cell-data in this-procedure (
          input {&km6xl-subtotalList}
        , input "":U
    ).
    run km6xl-write-cell-data in this-procedure (
          input {&km6xl-subtotalType}
        , input "":U
    ).
    run km6xl-write-cell-data in this-procedure (
          input {&km6xl-subtotalAmount}
        , input "0":U
    ).
    run km6xl-write-cell-data in this-procedure (
        input {&km6xl-subtotalPropisList}
        , input "":U
    ).
    run km6xl-write-cell-data in this-procedure (
        input {&km6xl-subtotalPropisAmount}
        , input "":U
    ).  */
end.
end procedure. /* km6xl-init */

/*==========================================================================*/
procedure km6xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
        export "exe/km6_97.xlt":U.
        export "exe/t_form.bas":U.
        export v-km6xl-cell-file-name.
        export v-km6xl-data-file-name.
    output close.
end.
end procedure. /* km6xl-close */


/*==========================================================================*/
procedure km6xl-write-cell-data :
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
end procedure. /* km6xl-write-cell-data */


/*==========================================================================*/
procedure km6xl-write-line-data :
define input parameter p-sheet-name        as character   no-undo.
define input parameter p-d_z-number        as INTEGER     no-undo.
define input parameter p-d_summ-sale       as decimal     no-undo.
define input parameter p-d_summ-return     as DECIMAL     no-undo.
define input parameter p-d_person          as character   no-undo.

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
        buf_temp_line-data.sheet-name     = p-sheet-name
        buf_temp_line-data.data-key       = {&km6xl-data-label}
        buf_temp_line-data.d_znumber      = p-d_z-number
        buf_temp_line-data.d_empty2       = ""
        buf_temp_line-data.d_empty3       = ""
        buf_temp_line-data.d_empty4       = ""
        buf_temp_line-data.d_empty5       = ""
        buf_temp_line-data.d_empty6       = ""
        buf_temp_line-data.d_summ-sale-7  = string(p-d_summ-sale)
        buf_temp_line-data.d_summreturn   = p-d_summ-return
        buf_temp_line-data.d_person       = p-d_person
        buf_temp_line-data.d_empty10      = ""
    .
    put stream excel-line unformatted
                        buf_temp_line-data.sheet-name
        {&tabulation}   buf_temp_line-data.data-key
        {&tabulation}   buf_temp_line-data.d_znumber
        {&tabulation}   buf_temp_line-data.d_empty2
        {&tabulation}   buf_temp_line-data.d_empty3
        {&tabulation}   buf_temp_line-data.d_empty4
        {&tabulation}   buf_temp_line-data.d_empty5
        {&tabulation}   buf_temp_line-data.d_empty6
        {&tabulation}   buf_temp_line-data.d_summ-sale-7
        {&tabulation}   buf_temp_line-data.d_summreturn
        {&tabulation}   buf_temp_line-data.d_person
        {&tabulation}   buf_temp_line-data.d_empty10
        {&new-line}
    .
end.
end procedure. /* km6xl-write-line-data */


/*==========================================================================*/
procedure km6xl-run-excel :
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
        v-template-file-name    = search( "exe/km6_97.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas")
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
end procedure. /* km6xl-run-excel */

/* $Workfile$ e n d */