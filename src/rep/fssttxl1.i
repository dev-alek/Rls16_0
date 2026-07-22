/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы fsssttm1 в Excel

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/21/06
Author: Bakhtadze Natalya
Creation date: 11/21/06

Required:

{ gbl/paramls.i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define fssttxl1-line-data-key "LD":U
&global-define fssttxl1-valutCode "valutCode":U
&global-define fssttxl1-columnList "columnList":U
&global-define fssttxl1-columnType "columnType":U
&global-define fssttxl1-columnAmount "columnAmount":U
&global-define fssttxl1-subtotalList "subtotalList":U
&global-define fssttxl1-subtotalType "subtotalType":U
&global-define fssttxl1-subtotalAmount "subtotalAmount":U

&global-define fssttxl1-h_datetime "h_datetime":U
&global-define fssttxl1-h_bankname "h_bankname":U
&global-define fssttxl1-h_bik "h_bik":U
&global-define fssttxl1-h_corrschet "h_corrschet":U
&global-define fssttxl1-h_rschet "h_rschet":U
&global-define fssttxl1-h_cliname "h_cliname":U
&global-define fssttxl1-h_currcodename "h_currcodename":U
&global-define fssttxl1-h_rschet "h_rschet":U
&global-define fssttxl1-h_lastfindoc "h_lastfindoc":U
&global-define fssttxl1-h_startsumdoc "h_startsumdoc":U
&global-define fssttxl1-f_endsumdoc "f_endsumdoc":U
&global-define fssttxl1-it_debetsum "it_debetsum":U
&global-define fssttxl1-it_creditsum "it_creditsum":U
&global-define fssttxl1-f_sumLiteral1-length 40

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.
define temp-table temp_line-data no-undo
    field data-key     as character
    field xl-line-id   as integer
    field linenum     as integer
    field prndoccode as character
    field rpcschet   as character
    field debetsum    as character
    field creditsum   as character

    index pi is primary unique xl-line-id
.

define variable v-fssttxl1-current-data-row     as integer      no-undo.
define variable v-fssttxl1-cell-file-name       as character    no-undo.
define variable v-fssttxl1-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure fssttxl1-init :

    define buffer buf_temp_cell-data        for temp_cell-data.
do
for buf_temp_cell-data
on error undo, return error
:
    assign
        v-fssttxl1-current-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-fssttxl1-data-file-name
    ).
    output stream excel-line to value( v-fssttxl1-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-fssttxl1-cell-file-name
    ).
    output stream excel-cell to value( v-fssttxl1-cell-file-name ).

    if printrubl
    then do:
        run fssttxl1-write-cell-data in this-procedure (
              input {&fssttxl1-valutCode}
            , input "0":U
        ).
    end.
    else do:
        run fssttxl1-write-cell-data in this-procedure (
              input {&fssttxl1-valutCode}
            , input "1":U
        ).
    end.
    run fssttxl1-write-cell-data in this-procedure (
          input {&fssttxl1-columnList}
        , input "linenum,prndoccode,rpcschet,debetsum,creditsum":U
    ).
    run fssttxl1-write-cell-data in this-procedure (
          input {&fssttxl1-columnType}
        , input "I,S,S,D,D":U
    ).
    run fssttxl1-write-cell-data in this-procedure (
          input {&fssttxl1-columnAmount}
        , input "5":U
    ).
    run fssttxl1-write-cell-data in this-procedure (
          input {&fssttxl1-subtotalList}
        , input "":U
    ).
    run fssttxl1-write-cell-data in this-procedure (
          input {&fssttxl1-subtotalType}
        , input "":U
    ).
    run fssttxl1-write-cell-data in this-procedure (
          input {&fssttxl1-subtotalAmount}
        , input "0":U
    ).
end.
end procedure. /* fssttxl1-init */

/*==========================================================================*/
procedure fssttxl1-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
/*        put unformatted*/
/*            substitute("&2&1&3&1&4&1&1",*/
/*                  {&new-line}*/
/*                , "d:\ww\2\t12_97.xlt":U*/
/*                , v-fssttxl1-cell-file-name*/
/*                , v-fssttxl1-data-file-name*/
/*            )*/
/*        .*/
        export "exe/fssttm1.xlt":U.
        export "exe/t_97.bas":U.
        export v-fssttxl1-cell-file-name.
        export v-fssttxl1-data-file-name.
    output close.
end.
end procedure. /* fssttxl1-close */


/*==========================================================================*/
procedure fssttxl1-write-cell-data :
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
end procedure. /* fssttxl1-write-cell-data */


/*==========================================================================*/
procedure fssttxl1-write-line-data :
define input parameter p-linenum       as integer          no-undo.
define input parameter p-prndoccode   as character        no-undo.
define input parameter p-rpcschet     as character        no-undo.
define input parameter p-debetsum      as character        no-undo.
define input parameter p-creditsum     as character        no-undo.

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
        v-fssttxl1-current-data-row = v-fssttxl1-current-data-row + 1
    .
    assign
    buf_temp_line-data.data-key     = {&fssttxl1-line-data-key}
    buf_temp_line-data.xl-line-id   = v-fssttxl1-current-data-row
    buf_temp_line-data.linenum      = p-linenum
    buf_temp_line-data.prndoccode   = p-prndoccode
    buf_temp_line-data.rpcschet      = p-rpcschet
    buf_temp_line-data.debetsum     = p-debetsum
    buf_temp_line-data.creditsum    = p-creditsum
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        {&tabulation}   buf_temp_line-data.linenum
        {&tabulation}   buf_temp_line-data.prndoccode
        {&tabulation}   buf_temp_line-data.rpcschet
        {&tabulation}   buf_temp_line-data.debetsum
        {&tabulation}   buf_temp_line-data.creditsum
        {&new-line}
    .
end.
end procedure. /* fssttxl1-write-line-data */


/*==========================================================================*/
procedure fssttxl1-run-excel :
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
        v-template-file-name    = search( "exe/t12_97.xlt" )
        v-vb-file-name          = search( "exe/t_97.bas")
    .
/*    assign*/
/*        v-template-file-name = search( v-template-file-name )*/
/*    .*/
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
/*    run paramls-write in this-procedure (*/
/*          input {&paramls-saveas}*/
/*        , input {&paramls-excel-file-name}*/
/*        , input v-excel-file-name*/
/*    ).*/
/*    run paramls-write in this-procedure (*/
/*          input "charcol"*/
/*        , input ""*/
/*        , input "2"*/
/*    ).*/
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
end procedure. /* fssttxl1-run-excel */

/* $Workfile$ e n d */