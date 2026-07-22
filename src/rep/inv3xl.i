/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: inv3xl.i $
$Archive: rep/inv3xl.i $

Обработка данных для заполнения шаблона формы инв-3 в Excel

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Required:

{ gbl/paramls.i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile: inv3xl.i $ $Revision: aea5316774be, 0, rls $".

&global-define inv3xl-line-data-key "LD":U
&global-define inv3xl-valutCode "valutCode":U
&global-define inv3xl-columnList "columnList":U
&global-define inv3xl-columnType "columnType":U
&global-define inv3xl-columnAmount "columnAmount":U
&global-define inv3xl-subtotalList "subtotalList":U
&global-define inv3xl-subtotalType "subtotalType":U
&global-define inv3xl-subtotalAmount "subtotalAmount":U
&global-define inv3xl-subtotalPropisList "subtotalPropisList":U
&global-define inv3xl-subtotalPropisAmount "subtotalPropisAmount":U

&global-define inv3xl-h_organization "h_organization":U
&global-define km7xl-h_OKPO          "h_OKPO":U
&global-define inv3xl-h_object "h_object":U
&global-define inv3xl-h_docCode "h_docCode":U
&global-define inv3xl-h_docDate "h_docDate":U
&global-define inv3xl-h_tbl_prikaz_num "h_tbl_prikaz_num":U 
&global-define inv3xl-h_tbl_prikaz_date "h_tbl_prikaz_date":U
&global-define inv3xl-h_tbl_startDate "h_tbl_startDate":U
&global-define inv3xl-h_tbl_endDate "h_tbl_endDate":U
&global-define inv3xl-h_BuhSum "h_BuhSum":U

&global-define inv3xl-f_itNumStr      "f_itNumStr":U
&global-define inv3xl-f_itQntyFactStr "f_itQntyFactStr":U
&global-define inv3xl-f_itSumFactStr "f_itSumFactStr":U
&global-define inv3xl-it_sumFact "it_sumFact":U
&global-define inv3xl-it_qntyFact "it_qntyFact":U
&global-define inv3xl-it_qntyBuh "it_qntyBuh":U
&global-define inv3xl-it_sumBuh "it_sumBuh":U
&global-define inv3xl-itp_s_num "itp_s_num":U
&global-define inv3xl-itp_s_qntyFact "itp_s_qntyFact":U


&global-define inv3xl-itp_s_pos_agent "itp_s_pos_agent":U
&global-define inv3xl-itp_s_fio_agent "itp_s_fio_agent":U
&global-define inv3xl-itp_s_pos_player1 "itp_s_pos_player1":U
&global-define inv3xl-itp_s_fio_player1 "itp_s_fio_player1":U
&global-define inv3xl-itp_s_pos_player2 "itp_s_pos_player2":U
&global-define inv3xl-itp_s_fio_player2 "itp_s_fio_player2":U
&global-define inv3xl-itp_s_pos_player3 "itp_s_pos_player3":U
&global-define inv3xl-itp_s_fio_player3 "itp_s_fio_player3":U
&global-define inv3xl-itp_s_pos_agent "itp_s_pos_agent":U
&global-define inv3xl-itp_s_fio_agent "itp_s_fio_agent":U
&global-define inv3xl-itp_s_pos_player1 "itp_s_pos_player1":U
&global-define inv3xl-itp_s_fio_player1 "itp_s_fio_player1":U
&global-define inv3xl-itp_s_pos_player2 "itp_s_pos_player2":U
&global-define inv3xl-itp_s_fio_player2 "itp_s_fio_player2":U
&global-define inv3xl-itp_s_pos_player3 "itp_s_pos_player3":U
&global-define inv3xl-itp_s_fio_player3 "itp_s_fio_player3":U

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
    field num          as integer
    field name         as character
    field gdscode      as character
    field EI           as character
    field OKEI         as character
    field price        as character
    field qntyFact     as character
    field sumFact      as character
    field qntyBuh      as character
    field sumBuh       as character

    index pi is primary unique xl-line-id
.

define variable v-inv3xl-current-data-row     as integer      no-undo.
define variable v-inv3xl-cell-file-name       as character    no-undo.
define variable v-inv3xl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure inv3xl-init :

    define buffer buf_temp_cell-data        for temp_cell-data.
    define buffer buf_usr-flt               for ubflt.usr-flt.
do
for buf_temp_cell-data
  , buf_usr-flt
on error undo, return error
:
    assign
        v-inv3xl-current-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-inv3xl-data-file-name
    ).
    output stream excel-line to value( v-inv3xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-inv3xl-cell-file-name
    ).
    output stream excel-cell to value( v-inv3xl-cell-file-name ).
    if v-curr-code = 0 then do :
       run inv3xl-write-cell-data in this-procedure (
             input {&inv3xl-valutCode}
           , input 0
       ).
    end.
    else do :
       run inv3xl-write-cell-data in this-procedure (
             input {&inv3xl-valutCode}
           , input 1
       ).
    end.

    run inv3xl-write-cell-data in this-procedure (
          input {&inv3xl-columnList}
        , input "num,name,gdscode,EI,OKEI,price,qntyFact,sumFact,qntyBuh,sumBuh":U
    ).
    run inv3xl-write-cell-data in this-procedure (
          input {&inv3xl-columnType}
        , input "I,S,I,S,S,C,D,C,D,C":U
    ).
    run inv3xl-write-cell-data in this-procedure (
          input {&inv3xl-columnAmount}
        , input "10":U
    ).
    run inv3xl-write-cell-data in this-procedure (
          input {&inv3xl-subtotalList}
        , input "num,qntyFact,qntyBuh":U
    ).
    run inv3xl-write-cell-data in this-procedure (
          input {&inv3xl-subtotalType}
        , input "C,S,S,S,S":U
    ).
    run inv3xl-write-cell-data in this-procedure (
          input {&inv3xl-subtotalAmount}
        , input "5":U
    ).
    run inv3xl-write-cell-data in this-procedure (
        input {&inv3xl-subtotalPropisList}
        , input "num,qntyFact":U
    ).
    run inv3xl-write-cell-data in this-procedure (
        input {&inv3xl-subtotalPropisAmount}
        , input "3":U
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
/*                                , v-inv3xl-cell-file-name*/
/*                                , v-inv3xl-data-file-name*/
/*                              )*/
/*    .*/
end.
end procedure. /* inv3xl-init */

/*==========================================================================*/
procedure inv3xl-close :
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
/*                , v-inv3xl-cell-file-name*/
/*                , v-inv3xl-data-file-name*/
/*            )*/
/*        .*/
        export "exe/i3_97.xlt":U.
        export "exe/t_97.bas":U.
        export v-inv3xl-cell-file-name.
        export v-inv3xl-data-file-name.
    output close.
end.
end procedure. /* inv3xl-close */


/*==========================================================================*/
procedure inv3xl-write-cell-data :
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
end procedure. /* inv3xl-write-cell-data */


/*==========================================================================*/
procedure inv3xl-write-line-data :
define input parameter p-num        as integer          no-undo.
define input parameter p-name       as character        no-undo.
define input parameter p-gdscode    as character        no-undo.
define input parameter p-EI         as character        no-undo.
define input parameter p-OKEI       as character        no-undo.
define input parameter p-price      as character        no-undo.
define input parameter p-qntyFact   as character        no-undo.
define input parameter p-sumFact    as character        no-undo.
define input parameter p-qntyBuh    as character        no-undo.
define input parameter p-sumBuh     as character        no-undo.

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
        v-inv3xl-current-data-row = v-inv3xl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key     = {&inv3xl-line-data-key}
        buf_temp_line-data.xl-line-id   = v-inv3xl-current-data-row
        buf_temp_line-data.num       = p-num
        buf_temp_line-data.name      = p-name
        buf_temp_line-data.gdscode   = p-gdscode
        buf_temp_line-data.EI        = p-EI
        buf_temp_line-data.OKEI      = p-OKEI
        buf_temp_line-data.price     = p-price
        buf_temp_line-data.qntyFact  = p-qntyFact
        buf_temp_line-data.sumFact   = p-sumFact
        buf_temp_line-data.qntyBuh   = p-qntyBuh
        buf_temp_line-data.sumBuh    = p-sumBuh
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        {&tabulation}   ( if buf_temp_line-data.num = 0 then "":U else string( buf_temp_line-data.num ) )
        {&tabulation}   buf_temp_line-data.name
        {&tabulation}   buf_temp_line-data.gdscode
        {&tabulation}   buf_temp_line-data.EI
        {&tabulation}   buf_temp_line-data.OKEI
        {&tabulation}   buf_temp_line-data.price
        {&tabulation}   buf_temp_line-data.qntyFact
        {&tabulation}   buf_temp_line-data.sumFact
        {&tabulation}   buf_temp_line-data.qntyBuh
        {&tabulation}   buf_temp_line-data.sumBuh
        {&new-line}
    .
end.
end procedure. /* inv3xl-write-line-data */


/*==========================================================================*/
procedure inv3xl-run-excel :
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
        v-template-file-name    = search( "exe/i3_97.xlt" )
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
end procedure. /* inv3xl-run-excel */

/* $Workfile: inv3xl.i $ e n d */