/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы torg-13 в Excel

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Required:

{ gbl/paramls.i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define torg13xl-line-data-key "LD":U
&global-define torg13xl-valutCode "valutCode":U
&global-define torg13xl-columnList "columnList":U
&global-define torg13xl-columnType "columnType":U
&global-define torg13xl-columnAmount "columnAmount":U
&global-define torg13xl-subtotalList "subtotalList":U
&global-define torg13xl-subtotalType "subtotalType":U
&global-define torg13xl-subtotalAmount "subtotalAmount":U

&global-define torg13xl-h_OKPO "h_OKPO":U
&global-define torg13xl-h_operationType "h_operationType":U
&global-define torg13xl-h_organization "h_organization":U
&global-define torg13xl-h_docCode "h_docCode":U
&global-define torg13xl-h_docDate "h_docDate":U
&global-define torg13xl-h_objFrom "h_objFrom":U
&global-define torg13xl-h_objTo "h_objTo":U

&global-define torg13xl-it_qnty "it_qnty":U
&global-define torg13xl-it_sum "it_sum":U
&global-define torg13xl-f_itSumStr "f_itSumStr":U

&global-define torg13xl-f_pass_fname "f_pass_fname":U
&global-define torg13xl-f_pass_position "f_pass_position":U
&global-define torg13xl-f_accept_position "f_accept_position":U
&global-define torg13xl-f_accept_fname "f_accept_fname":U


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
    field Name         as character
    field gdscode      as character
    field EI           as character
    field OKEI         as character
    field AmountInPl   as character
    field PlaceAmount  as character
    field qnty         as character
    field price        as character
    field sum          as character

    index pi is primary unique xl-line-id
.

define variable v-torg13xl-current-data-row     as integer      no-undo.
define variable v-torg13xl-cell-file-name       as character    no-undo.
define variable v-torg13xl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure torg13xl-init :

    define buffer buf_temp_cell-data        for temp_cell-data.
    define buffer buf_usr-flt               for ubflt.usr-flt.
do
for buf_temp_cell-data
  , buf_usr-flt
on error undo, return error
:
    assign
        v-torg13xl-current-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-torg13xl-data-file-name
    ).
    output stream excel-line to value( v-torg13xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-torg13xl-cell-file-name
    ).
    output stream excel-cell to value( v-torg13xl-cell-file-name ).
    if printrubl
    then do:
        run torg13xl-write-cell-data in this-procedure (
              input {&torg13xl-valutCode}
            , input "0":U
        ).
    end.
    else do:
        run torg13xl-write-cell-data in this-procedure (
              input {&torg13xl-valutCode}
            , input "1":U
        ).
    end.
    run torg13xl-write-cell-data in this-procedure (
          input {&torg13xl-columnList}
        , input "Name,gdscode,EI,OKEI,AmountInPl,PlaceAmount,qnty,price,sum":U
    ).
    run torg13xl-write-cell-data in this-procedure (
          input {&torg13xl-columnType}
        , input "S,I,S,S,D,D,D,C,C":U
    ).
    run torg13xl-write-cell-data in this-procedure (
          input {&torg13xl-columnAmount}
        , input "9":U
    ).
    run torg13xl-write-cell-data in this-procedure (
          input {&torg13xl-subtotalList}
        , input "AmountInPl,PlaceAmount,qnty,sum":U
    ).
    run torg13xl-write-cell-data in this-procedure (
          input {&torg13xl-subtotalType}
        , input "S,S,S,S":U
    ).
    run torg13xl-write-cell-data in this-procedure (
          input {&torg13xl-subtotalAmount}
        , input "4":U
    ).
/*    find first buf_usr-flt exclusive-lock*/
/*         where buf_usr-flt.user-name    = g#userid*/
/*           and buf_usr-flt.call-point   = "macroxlt":U*/
/*    no-error.*/
/*    if not available buf_usr-flt*/
/*    then do:*/
/*        create buf_usr-flt.*/
/*        assign*/
/*            buf_usr-flt.user-name    = g#userid*/
/*            buf_usr-flt.call-point   = "macroxlt":U*/
/*        .*/
/*    end.*/
/*    assign*/
/*        buf_usr-flt.Naim    = "torg12"*/
/*        buf_usr-flt.List_   = substitute( "&1,&2"*/
/*                                , v-torg13xl-cell-file-name*/
/*                                , v-torg13xl-data-file-name*/
/*                              )*/
/*    .*/
end.
end procedure. /* torg13xl-init */

/*==========================================================================*/
procedure torg13xl-close :
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
/*                , v-torg13xl-cell-file-name*/
/*                , v-torg13xl-data-file-name*/
/*            )*/
/*        .*/
        export "exe/t13_97.xlt":U.
        export "exe/t_97.bas":U.
        export v-torg13xl-cell-file-name.
        export v-torg13xl-data-file-name.
    output close.
end.
end procedure. /* torg13xl-close */


/*==========================================================================*/
procedure torg13xl-write-cell-data :
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
end procedure. /* torg13xl-write-cell-data */


/*==========================================================================*/
procedure torg13xl-write-line-data :
define input parameter p-Name           as character        no-undo.
define input parameter p-gdscode        as character        no-undo.
define input parameter p-EI             as character        no-undo.
define input parameter p-OKEI           as character        no-undo.
define input parameter p-AmountInPl     as character        no-undo.
define input parameter p-PlaceAmount    as character        no-undo.
define input parameter p-qnty           as character        no-undo.
define input parameter p-price          as character        no-undo.
define input parameter p-sum            as character        no-undo.

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
        v-torg13xl-current-data-row = v-torg13xl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key     = {&torg13xl-line-data-key}
        buf_temp_line-data.xl-line-id   = v-torg13xl-current-data-row
        buf_temp_line-data.Name         = p-Name
        buf_temp_line-data.gdscode      = p-gdscode
        buf_temp_line-data.EI           = p-EI
        buf_temp_line-data.OKEI         = p-OKEI
        buf_temp_line-data.AmountInPl   = p-AmountInPl
        buf_temp_line-data.PlaceAmount  = p-PlaceAmount
        buf_temp_line-data.qnty         = p-qnty
        buf_temp_line-data.price        = p-price
        buf_temp_line-data.sum          = p-sum
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        {&tabulation}   buf_temp_line-data.Name
        {&tabulation}   buf_temp_line-data.gdscode
        {&tabulation}   buf_temp_line-data.EI
        {&tabulation}   buf_temp_line-data.OKEI
        {&tabulation}   buf_temp_line-data.AmountInPl
        {&tabulation}   buf_temp_line-data.PlaceAmount
        {&tabulation}   buf_temp_line-data.qnty
        {&tabulation}   buf_temp_line-data.price
        {&tabulation}   buf_temp_line-data.sum
        {&new-line}
    .
end.
end procedure. /* torg13xl-write-line-data */


/*==========================================================================*/
procedure torg13xl-run-excel :
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
        v-template-file-name    = search( "exe/t13_97.xlt" )
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
end procedure. /* torg13xl-run-excel */

/* $Workfile$ e n d */