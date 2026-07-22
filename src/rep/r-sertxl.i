/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона короткой формы прих. наклад. в Excel

Автор: Демин Алексей Сергеевич
Дата создания: 08/30/06
Author: Alexey Demin
Creation date: 08/30/06

Required:  { gbl/paramls.i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define r-sertxl-line-data-key "LD":U
&global-define r-sertxl-regularExpressions "regularExpressions":U
&global-define r-sertxl-valutCode "valutCode":U
&global-define r-sertxl-columnList "columnList":U
&global-define r-sertxl-columnType "columnType":U
&global-define r-sertxl-columnAmount "columnAmount":U
&global-define r-sertxl-subtotalList "subtotalList":U
&global-define r-sertxl-subtotalType "subtotalType":U
&global-define r-sertxl-subtotalAmount "subtotalAmount":U

&global-define r-sertxl-h_docNum       "h_DocNum":U
&global-define r-sertxl-f_OrgName      "f_OrgName":U
&global-define r-sertxl-f_contact      "f_contact":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.
define temp-table temp_line-data no-undo
    field data-key   as character
    field xl-line-id as integer
    field num        as integer
    field artic      as character
    field name       as character
    field numblank   as character
    field numsertif  as character
    field date1      as character
    field date2      as character
    field orgsertif  as character
    field srok       as character
    field datestart  as character
    field techusl    as character

    index pi is primary unique xl-line-id
    .

define variable v-r-sertxl-current-data-row     as integer      no-undo.
define variable v-r-sertxl-cell-file-name       as character    no-undo.
define variable v-r-sertxl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure r-sertxl-init :

    define buffer buf_temp_cell-data        for temp_cell-data.
do
for buf_temp_cell-data on error undo, return error :
    assign
        v-r-sertxl-current-data-row = 0
    .
    run gbl/_tmpfile.p
      (input "xd"
      ,input ".txt"
      ,output v-r-sertxl-data-file-name
      ).
    output stream excel-line to value( v-r-sertxl-data-file-name ).
    run gbl/_tmpfile.p
      (input "xc"
      ,input ".txt"
      ,output v-r-sertxl-cell-file-name
      ).
    output stream excel-cell to value( v-r-sertxl-cell-file-name ).

    run r-sertxl-write-cell-data in this-procedure (
              input {&r-sertxl-valutCode}
            , input "0":U
    ).
    run r-sertxl-write-cell-data in this-procedure (
          input {&r-sertxl-regularExpressions}
        , input "1":U
    ).
    run r-sertxl-write-cell-data in this-procedure (
          input {&r-sertxl-columnList}
        , input "num,artic,name,numblank,numsertif,date1,date2,orgsertif,srok,datestart,techusl":U
    ).
    run r-sertxl-write-cell-data in this-procedure (
          input {&r-sertxl-columnType}
        , input "I,S,S,S,S,S,S,S,S,S,S":U
    ).
    run r-sertxl-write-cell-data in this-procedure (
          input {&r-sertxl-columnAmount}
        , input "11":U
    ).
/*    run r-sertxl-write-cell-data in this-procedure (*/
/*          input {&r-sertxl-subtotalList}*/
/*        , input "":U*/
/*    ).*/
/*    run r-sertxl-write-cell-data in this-procedure (*/
/*          input {&r-sertxl-subtotalType}*/
/*        , input "":U*/
/*    ).*/
/*    run r-sertxl-write-cell-data in this-procedure (*/
/*          input {&r-sertxl-subtotalAmount}*/
/*        , input "":U*/
/*    ).*/
end.
end procedure. /* r-sertxl-init */

/*==========================================================================*/
procedure r-sertxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/sertif.xlt":U.
        export "exe/t_97.bas":U.
        export v-r-sertxl-cell-file-name.
        export v-r-sertxl-data-file-name.
    output close.
end.
end procedure. /* r-sertxl-close */


/*==========================================================================*/
procedure r-sertxl-write-cell-data :
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
end procedure. /* r-sertxl-write-cell-data */


/*==========================================================================*/
procedure r-sertxl-write-line-data :
define input parameter p-num              as integer          no-undo.
define input parameter p-artic            as character        no-undo.
define input parameter p-name             as character        no-undo.
define input parameter p-numblank         as character        no-undo.
define input parameter p-numsertif        as character        no-undo.
define input parameter p-date1            as character        no-undo.
define input parameter p-date2            as character        no-undo.
define input parameter p-orgsertif        as character        no-undo.
define input parameter p-srok             as character        no-undo.
define input parameter p-date-start       as character        no-undo.
define input parameter p-tech-usl         as character        no-undo.

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
        v-r-sertxl-current-data-row = v-r-sertxl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key   = {&r-sertxl-line-data-key}
        buf_temp_line-data.xl-line-id = v-r-sertxl-current-data-row
        buf_temp_line-data.num        = p-num
        buf_temp_line-data.artic      = p-artic
        buf_temp_line-data.name       = p-name
        buf_temp_line-data.numblank   = p-numblank
        buf_temp_line-data.numsertif  = p-numsertif
        buf_temp_line-data.date1      = p-date1
        buf_temp_line-data.date2      = p-date2
        buf_temp_line-data.orgsertif  = p-orgsertif
        buf_temp_line-data.srok       = p-srok
        buf_temp_line-data.datestart  = p-date-start
        buf_temp_line-data.techusl    = p-tech-usl     
        .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        {&tabulation}   buf_temp_line-data.num
        {&tabulation}   buf_temp_line-data.artic
        {&tabulation}   buf_temp_line-data.name
        {&tabulation}   buf_temp_line-data.numblank
        {&tabulation}   buf_temp_line-data.numsertif
        {&tabulation}   buf_temp_line-data.date1
        {&tabulation}   buf_temp_line-data.date2
        {&tabulation}   buf_temp_line-data.orgsertif
        {&tabulation}   buf_temp_line-data.srok
        {&tabulation}   buf_temp_line-data.datestart
        {&tabulation}   buf_temp_line-data.techusl
        {&new-line}
    .
end.
end procedure. /* r-sertxl-write-line-data */


/*==========================================================================*/
procedure r-sertxl-run-excel :
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
        v-template-file-name    = search( "exe/sertif.xlt" )
        v-vb-file-name          = search( "exe/t_97.bas")
    .
    if v-template-file-name = ?  or v-template-file-name = "":U  then do:
        message  "Ошибка имени файла шаблона." view-as alert-box error.
    end.
    if v-vb-file-name = ?  or v-vb-file-name = "":U then do:
        message  "Ошибка имени файла кода обработки."   view-as alert-box error.
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
end procedure. /* r-sertxl-run-excel */

/* $Workfile$ e n d */