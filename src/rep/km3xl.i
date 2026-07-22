/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы KM-3 в Excel

Автор: Комаров Иван Сергеевич
Дата создания: 21/10/09
Author: Ivan Komarov
Creation date: 21/10/09

Автор1: Белоусов Илья Александрович

*/

&global-define km3xl-data-label "DTA":U
&global-define km3xl-format-label "FMT":U


&global-define km3xl-line-data-key        "LD":U
&global-define km3xl-valutCode            "valutCode":U
&global-define km3xl-columnList           "columnList":U
&global-define km3xl-columnType           "columnType":U
&global-define km3xl-columnAmount         "columnAmount":U

&global-define km3xl-subtotalList         "subtotalList":U
&global-define km3xl-subtotalType         "subtotalType":U
&global-define km3xl-subtotalAmount       "subtotalAmount":U
&global-define km3xl-subtotalPropisList   "subtotalPropisList":U
&global-define km3xl-subtotalPropisAmount "subtotalPropisAmount":U

&global-define km3xl-h_organization       "h_organization":U
&global-define km3xl-h_object             "h_object":U
&global-define km3xl-h_docCode            "h_docCode":U
&global-define km3xl-h_docDate            "h_docDate":U
&global-define km3xl-h_docTime            "h_docTime":U
&global-define km3xl-h_OKPO               "h_OKPO":U
&global-define km3xl-h_INN                "h_INN":U
&global-define km3xl-h_KKM_prod           "h_KKM_prod":U
&global-define km3xl-h_KKM_reg            "h_KKM_reg":U
&global-define km3xl-h_KKM_programm       "h_KKM_programm":U
&global-define km3xl-h_descname           "h_deskname":U

&global-define km3xl-f_boss               "f_boss":U
&global-define km3xl-f_post               "f_post":U
&global-define km3xl-f_cashier            "f_cashier":U
&global-define km3xl-f_cashier_op         "f_cashier_op":U

&global-define km3xl-it_Summ              "it_Summ":U
&global-define km3xl-it_kop               "it_kop":U
&global-define km3xl-it_s_Summ_return     "it_s_Summ_return":U
&global-define km3xl-it_s_Summ_1          "it_s_Summ_1":U
&global-define km3xl-it_s_Summ_2          "it_s_Summ_2":U
&global-define km3xl-it_dir               "it_dir":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.
define temp-table temp_line-data no-undo
    field sheet-name    as character
    field xl-line-id    as integer
    field d_LineNum      as integer
    field d_SectionName as character
    field d_ShiftNum    as character
    field d_ChkNum      as integer
    field d_Summ      as decimal
    field d_menager      as character
    index pi is primary unique
          xl-line-id
.

define variable v-km3xl-current-data-row     as integer      no-undo.
define variable v-km3xl-cell-file-name       as character    no-undo.
define variable v-km3xl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure km3xl-init :
define input parameter p-first-sheet as logical no-undo .
define input parameter p-sheet-name as character no-undo .
define input parameter p-sheet-list as character no-undo .
define input parameter p-sheet-list-copy-from as character no-undo .

    define buffer buf_temp_cell-data        for temp_cell-data.
    define buffer buf_usr-flt               for ubflt.usr-flt.
do
for buf_temp_cell-data
  , buf_usr-flt
on error undo, return error
:
    assign
        v-km3xl-current-data-row = 0
    .
    if p-first-sheet then do:
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-km3xl-data-file-name
    ).
    output stream excel-line to value( v-km3xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-km3xl-cell-file-name
    ).
    output stream excel-cell to value( v-km3xl-cell-file-name ).
      run km3xl-write-cell-data in this-procedure (
            input "sheetListcopyfrom":U
          , input p-sheet-list-copy-from
      ).

      run km3xl-write-cell-data in this-procedure (
            input "sheetList":U
          , input p-sheet-list
      ).
    end.
    if printrubl = yes
    then do:
        run km3xl-write-cell-data in this-procedure (
              input substitute("&1_&2"
                               , p-sheet-name
                               , {&km3xl-valutCode}
                               )
            , input "0":U
        ).
    end.
    else do:
        run km3xl-write-cell-data in this-procedure (
              input substitute("&1_&2"
                                , p-sheet-name
                                , {&km3xl-valutCode}
                                )
            , input "1":U
        ).
    end.

    run km3xl-write-cell-data in this-procedure (
          input substitute("&1_&2"
                           ,p-sheet-name
                           ,{&km3xl-columnList}
                           )
        , input "LineNum,sectionName,ShiftNum,ChkNum,Summ,menager":U
    ).
    run km3xl-write-cell-data in this-procedure (
          input substitute("&1_&2"
                            , p-sheet-name
                            ,{&km3xl-columnType}
                            )
        , input "I,S,S,I,D,S":U
    ).
    run km3xl-write-cell-data in this-procedure (
          input substitute("&1_&2"
                            , p-sheet-name
                            ,{&km3xl-columnAmount}
                            )
        , input "6":U
    ).
end.
end procedure. /* km3xl-init */

/*==========================================================================*/
procedure km3xl-close :

do
on error undo, return error
:

    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
        export "exe/km3_97.xlt":U.
        export "exe/t_form.bas":U.
        export v-km3xl-cell-file-name.
        export v-km3xl-data-file-name.
    output close.
end.
end procedure. /* km3xl-close */


/*==========================================================================*/
procedure km3xl-write-cell-data :
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
end procedure. /* km3xl-write-cell-data */


/*==========================================================================*/
procedure km3xl-write-line-data :
define input parameter p-sheet-name     as character no-undo .
define input parameter p-d_LineNum      as integer          no-undo.
define input parameter p-d_SectionName as character        no-undo.
define input parameter p-d_ShiftNum    as character          no-undo.
define input parameter p-d_ChkNum      as integer          no-undo.
define input parameter p-d_Summ      as decimal          no-undo.
define input parameter p-d_menager      as character        no-undo.


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
        buf_temp_line-data.sheet-name    = p-sheet-name
        buf_temp_line-data.xl-line-id    = p-d_LineNum
        buf_temp_line-data.d_LineNum     = p-d_LineNum
        buf_temp_line-data.d_SectionName = p-d_SectionName
        buf_temp_line-data.d_ShiftNum    = p-d_ShiftNum
        buf_temp_line-data.d_ChkNum      = p-d_ChkNum
        buf_temp_line-data.d_Summ        = p-d_Summ
        buf_temp_line-data.d_menager      = p-d_menager
    .
    put stream excel-line unformatted
                        buf_temp_line-data.sheet-name
        {&tabulation}   {&km3xl-data-label}
        {&tabulation}   buf_temp_line-data.d_LineNum
        {&tabulation}   buf_temp_line-data.d_SectionName
        {&tabulation}   buf_temp_line-data.d_ShiftNum
        {&tabulation}   buf_temp_line-data.d_ChkNum
        {&tabulation}   buf_temp_line-data.d_Summ
        {&tabulation}   buf_temp_line-data.d_menager
        {&new-line}
    .
end.
end procedure. /* km3xl-write-line-data */


/*==========================================================================*/
procedure km3xl-run-excel :
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
        v-template-file-name    = search( "exe/km3_97.xlt" )
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
end procedure. /* km3xl-run-excel */

/* $Workfile$ e n d */