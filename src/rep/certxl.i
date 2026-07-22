/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы Качественное удостоверение r-cert.p в Excel

Автор: Демин Алексей Сергеевич
Дата создания: 10/16/08
Author: Alexey Demin
Creation date: 10/16/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define certxl-data-label "DTA":U
&global-define certxl-format-label "FMT":U

&global-define certxl-template  "Template":U

&global-define certxl-template_valutCode       "Template_valutCode":U
&global-define certxl-template_columnList      "Template_columnList":U
&global-define certxl-template_columnType      "Template_columnType":U
&global-define certxl-template_subtotalList    "Template_subtotalList":U
&global-define certxl-template_subtotalType    "Template_subtotalType":U

&global-define certxl-Template_df_Name      "Template_df_Name":U
&global-define certxl-Template_df_manuf     "Template_df_manuf":U
&global-define certxl-Template_df_qnty      "Template_df_qnty":U
&global-define certxl-Template_df_vplace    "Template_df_vplace":U
&global-define certxl-Template_df_deadline  "Template_df_deadline":U
&global-define certxl-Template_df_struct    "Template_df_struct":U
&global-define certxl-Template_df_protokol  "Template_df_protokol":U

&global-define certxl-df_Name      "df_Name":U
&global-define certxl-df_manuf      "df_manuf":U
&global-define certxl-df_qnty      "df_qnty":U
&global-define certxl-df_vplace    "df_vplace":U
&global-define certxl-df_deadline  "df_deadline":U
&global-define certxl-df_struct    "df_struct":U
&global-define certxl-df_protokol   "df_protokol":U
&global-define certxl-h_org        "h_org":U
&global-define certxl-h_adres      "h_adres":U
&global-define certxl-h_num        "h_num":U

&global-define certxl-h_adresu       "h_adresu":U
&global-define certxl-h_adresp       "h_adresp":U
&global-define certxl-h_phone        "h_phone":U

&global-define certxl-Template-name "Template":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.

define temp-table temp_Template_line-data no-undo
    field template-name    as character
    field xl-line-id       as integer
    field df_struct        as character
    field df_Name          as character
    field df_manuf         as character
    field df_qnty          as decimal
    field df_vplace        as character
    field df_deadline      as character
    field df_protokol      as character
    index pi is primary unique
        xl-line-id
.

define variable v-certxl-Template-cur-data-row     as integer      no-undo.
define variable v-certxl-cell-file-name       as character    no-undo.
define variable v-certxl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure certxl-init :

do
on error undo, return error
:
    assign
        v-certxl-Template-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-certxl-data-file-name
    ).
    output stream excel-line to value( v-certxl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-certxl-cell-file-name
    ).
    output stream excel-cell to value( v-certxl-cell-file-name ).
    run certxl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&certxl-Template}
    ).
    if printrubl
    then do:
        run certxl-write-cell-data in this-procedure (
              input {&certxl-template_valutCode}
            , input "0":U
        ).
    end.
    else do:
       run certxl-write-cell-data in this-procedure (
              input {&certxl-Template_valutCode}
            , input "1":U
       ).
    end.
    run certxl-write-cell-data in this-procedure (
          input {&certxl-Template_columnList}
        , input "df_struct,df_Name,df_manuf,df_qnty,df_vplace,df_deadline,df_protokol":U
    ).
    run certxl-write-cell-data in this-procedure (
          input {&certxl-Template_columnType}
        , input "S,S,S,D,S,S,S":U
    ).
    run certxl-write-cell-data in this-procedure (
          input {&certxl-Template_subtotalList}
        , input "":U
    ).
    run certxl-write-cell-data in this-procedure (
          input {&certxl-Template_subtotalType}
        , input "":U
    ).
end.
end procedure. /* certxl-init */

/*==========================================================================*/
procedure certxl-Template-write-line-data :
define input parameter p-df_struct    as character      no-undo.
define input parameter p-df_Name      as character      no-undo.
define input parameter p-df_manuf     as character      no-undo.
define input parameter p-df_qnty      as decimal        no-undo.
define input parameter p-df_vplace    as character      no-undo.
define input parameter p-df_deadline  as character      no-undo.
define input parameter p-df_protokol  as character      no-undo.

    define buffer buf_temp_Template_line-data        for temp_Template_line-data.
do
for buf_temp_Template_line-data
on error undo, return error
:
    for each buf_temp_Template_line-data
    :
        delete buf_temp_Template_line-data.
    end.
    create buf_temp_Template_line-data.
    assign
        v-certxl-Template-cur-data-row            = v-certxl-Template-cur-data-row + 1
        buf_temp_Template_line-data.template-name = {&certxl-Template-name}
        buf_temp_Template_line-data.xl-line-id    = v-certxl-Template-cur-data-row
        buf_temp_Template_line-data.df_struct     = p-df_struct
        buf_temp_Template_line-data.df_Name       = p-df_Name
        buf_temp_Template_line-data.df_manuf      = p-df_manuf
        buf_temp_Template_line-data.df_qnty       = p-df_qnty
        buf_temp_Template_line-data.df_vplace     = p-df_vplace
        buf_temp_Template_line-data.df_deadline   = p-df_deadline
        buf_temp_Template_line-data.df_protokol   = p-df_protokol
    .
    put stream excel-line unformatted
                        buf_temp_Template_line-data.Template-name
        {&tabulation}   {&certxl-data-label}
        {&tabulation}   buf_temp_Template_line-data.df_struct
        {&tabulation}   buf_temp_Template_line-data.df_Name
        {&tabulation}   buf_temp_Template_line-data.df_manuf
        {&tabulation}   buf_temp_Template_line-data.df_qnty
        {&tabulation}   buf_temp_Template_line-data.df_vplace
        {&tabulation}   buf_temp_Template_line-data.df_deadline
        {&tabulation}   buf_temp_Template_line-data.df_protokol
        {&new-line}
    .

end.
end procedure. /* certxl-write-line-data */

/*==========================================================================*/
/*==========================================================================*/
procedure certxl-write-cell-data :
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
end procedure. /* certxl-write-cell-data */

/*==========================================================================*/
procedure certxl-run-excel :
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
        v-template-file-name    = search( "exe/celt.xlt" )
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
end procedure. /* certxl-run-excel */


/*==========================================================================*/
procedure certxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/celt.xlt":U.
        export "exe/t_form.bas":U.
        export v-certxl-cell-file-name.
        export v-certxl-data-file-name.
    output close.
end.
end procedure. /* certxl-close */


/* $Workfile$ e n d */