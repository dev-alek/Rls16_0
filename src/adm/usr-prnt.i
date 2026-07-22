/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать прав пользователя (работа с шаблоном)

Автор: Белоусов Илья Александрович
Дата создания: 08/01/08
Author: Ilia Belousov
Creation date: 08/01/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define usr-prnt-data-label "DTA":U
&global-define usr-prnt-format-label "FMT":U

&global-define usr-prnt-sheetList  "Фирмы,Объекты,Меню,Права":U

&global-define usr-prnt-sheet1_valutCode       "Фирмы_valutCode":U
&global-define usr-prnt-sheet1_columnList      "Фирмы_columnList":U
&global-define usr-prnt-sheet1_columnType      "Фирмы_columnType":U
&global-define usr-prnt-sheet1_subtotalList    "Фирмы_subtotalList":U
&global-define usr-prnt-sheet1_subtotalType    "Фирмы_subtotalType":U

&global-define usr-prnt-sheet2_valutCode       "Объекты_valutCode":U
&global-define usr-prnt-sheet2_columnList      "Объекты_columnList":U
&global-define usr-prnt-sheet2_columnType      "Объекты_columnType":U
&global-define usr-prnt-sheet2_subtotalList    "Объекты_subtotalList":U
&global-define usr-prnt-sheet2_subtotalType    "Объекты_subtotalType":U

&global-define usr-prnt-sheet3_valutCode       "Меню_valutCode":U
&global-define usr-prnt-sheet3_columnList      "Меню_columnList":U
&global-define usr-prnt-sheet3_columnType      "Меню_columnType":U
&global-define usr-prnt-sheet3_subtotalList    "Меню_subtotalList":U
&global-define usr-prnt-sheet3_subtotalType    "Меню_subtotalType":U

&global-define usr-prnt-sheet4_valutCode       "Права_valutCode":U
&global-define usr-prnt-sheet4_columnList      "Права_columnList":U
&global-define usr-prnt-sheet4_columnType      "Права_columnType":U
&global-define usr-prnt-sheet4_subtotalList    "Права_subtotalList":U
&global-define usr-prnt-sheet4_subtotalType    "Права_subtotalType":U

&global-define usr-prnt-sheet1-name            "Фирмы":U
&global-define usr-prnt-sheet1-user            "user_id_1":U
&global-define usr-prnt-sheet1-user-login      "user_login_1":U
&global-define usr-prnt-sheet1-user-name       "user_name_1":U
&global-define usr-prnt-sheet1-user-nik        "user_nik_1":U
&global-define usr-prnt-sheet1-db              "user_db_1":U

&global-define usr-prnt-sheet2-name            "Объекты":U
&global-define usr-prnt-sheet2-user            "user_id_2":U
&global-define usr-prnt-sheet2-user-login      "user_login_2":U
&global-define usr-prnt-sheet2-user-name       "user_name_2":U
&global-define usr-prnt-sheet2-user-nik        "user_nik_2":U
&global-define usr-prnt-sheet2-db              "user_db_2":U

&global-define usr-prnt-sheet3-name            "Меню":U
&global-define usr-prnt-sheet3-user            "user_id_3":U
&global-define usr-prnt-sheet3-user-login      "user_login_3":U
&global-define usr-prnt-sheet3-user-name       "user_name_3":U
&global-define usr-prnt-sheet3-user-nik        "user_nik_3":U
&global-define usr-prnt-sheet3-db              "user_db_3":U

&global-define usr-prnt-sheet4-name            "Права":U
&global-define usr-prnt-sheet4-user            "user_id_4":U
&global-define usr-prnt-sheet4-user-login      "user_login_4":U
&global-define usr-prnt-sheet4-user-name       "user_name_4":U
&global-define usr-prnt-sheet4-user-nik        "user_nik_4":U
&global-define usr-prnt-sheet4-db              "user_db_4":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.



define variable v-usr-prnt-sheet1-cur-data-row     as integer      no-undo.

define variable v-usr-prnt-cell-file-name       as character    no-undo.
define variable v-usr-prnt-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure usr-prnt-init :

do
on error undo, return error
:
    assign
        v-usr-prnt-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-usr-prnt-data-file-name
    ).
    output stream excel-line to value( v-usr-prnt-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-usr-prnt-cell-file-name
    ).
    output stream excel-cell to value( v-usr-prnt-cell-file-name ).
    run usr-prnt-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&usr-prnt-sheetList}
    ).
   run usr-prnt-write-cell-data in this-procedure (
         input {&usr-prnt-sheet1_valutCode}
      , input "0":U
   ).
   run usr-prnt-write-cell-data in this-procedure (
         input {&usr-prnt-sheet2_valutCode}
      , input "0":U
   ).
   run usr-prnt-write-cell-data in this-procedure (
         input {&usr-prnt-sheet3_valutCode}
      , input "0":U
   ).
   run usr-prnt-write-cell-data in this-procedure (
         input {&usr-prnt-sheet4_valutCode}
      , input "0":U
   ).


    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet1_columnList}
        , input "firm_code,firm_name":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet1_columnType}
        , input "S,S":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet1_subtotalList}
        , input "":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet1_subtotalType}
        , input "":U
    ).


    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet2_columnList}
        , input "obj_code,obj_type,obj_name":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet2_columnType}
        , input "S,S,S":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet2_subtotalList}
        , input "":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet2_subtotalType}
        , input "":U
    ).


    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet3_columnList}
        , input "menu_obj,menu_name":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet3_columnType}
        , input "S,S":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet3_subtotalList}
        , input "":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet3_subtotalType}
        , input "":U
    ).


    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet4_columnList}
        , input "actn_obj,actn_grp,actn_id,actn_name,actn_ps":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet4_columnType}
        , input "S,S,S,S,S":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet4_subtotalList}
        , input "":U
    ).
    run usr-prnt-write-cell-data in this-procedure (
          input {&usr-prnt-sheet4_subtotalType}
        , input "":U
    ).

end.
end procedure. /* usr-prnt-init */


/*==========================================================================*/
procedure usr-prnt-sheet1-write-line-data :
define input parameter p-firm-code as character        no-undo.
define input parameter p-firm-name  as character        no-undo.

do
on error undo, return error
:
      put stream excel-line unformatted
                            {&usr-prnt-sheet1-name}
            {&tabulation}   {&usr-prnt-data-label}
            {&tabulation}   p-firm-code
            {&tabulation}   p-firm-name
            {&new-line}
      .

end.
end procedure. /* usr-prnt-sheet1-write-line-data */


/*==========================================================================*/
procedure usr-prnt-sheet2-write-line-data :
define input parameter p-obj-type as character        no-undo.
define input parameter p-obj-code as character        no-undo.
define input parameter p-obj-name as character        no-undo.

do
on error undo, return error
:
      put stream excel-line unformatted
                            {&usr-prnt-sheet2-name}
            {&tabulation}   {&usr-prnt-data-label}
            {&tabulation}   p-obj-type
            {&tabulation}   p-obj-code
            {&tabulation}   p-obj-name
            {&new-line}
      .

end.
end procedure. /* usr-prnt-sheet1-write-line-data */


/*==========================================================================*/
procedure usr-prnt-sheet3-write-line-data :
define input parameter p-menu_obj  as character        no-undo.
define input parameter p-menu_name as character        no-undo.

do
on error undo, return error
:
      put stream excel-line unformatted
                            {&usr-prnt-sheet3-name}
            {&tabulation}   {&usr-prnt-data-label}
            {&tabulation}   p-menu_obj
            {&tabulation}   p-menu_name
            {&new-line}
      .

end.
end procedure. /* usr-prnt-sheet1-write-line-data */


/*==========================================================================*/
procedure usr-prnt-sheet4-write-line-data :
define input parameter p-actn-obj   as character        no-undo.
define input parameter p-actn-grp   as character        no-undo.
define input parameter p-actn-id    as character        no-undo.
define input parameter p-actn-name  as character        no-undo.
define input parameter p-actn-ps    as character        no-undo.

do
on error undo, return error
:
      /* заголовок группы клиентов */
      put stream excel-line unformatted
                            {&usr-prnt-sheet4-name}
            {&tabulation}   {&usr-prnt-data-label}
            {&tabulation}   p-actn-obj
            {&tabulation}   p-actn-grp
            {&tabulation}   p-actn-id
            {&tabulation}   p-actn-name
            {&tabulation}   p-actn-ps
            {&new-line}
      .

end.
end procedure. /* usr-prnt-sheet1-write-line-data */


/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure usr-prnt-write-cell-data :
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
end procedure. /* usr-prnt-write-cell-data */

/*==========================================================================*/
procedure usr-prnt-run-excel :
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
        v-template-file-name    = search( "exe/user.xlt" )
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
end procedure. /* usr-prnt-run-excel */


/*==========================================================================*/
procedure usr-prnt-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/user.xlt" .
        export "exe/t_form.bas" .
        export v-usr-prnt-cell-file-name.
        export v-usr-prnt-data-file-name.
    output close.
end.
end procedure. /* usr-prnt-close */

/* $Workfile$ e n d */