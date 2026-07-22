/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы инв-8 в Excel

Автор: Белоусов Илья Александрович
Дата создания:
Author: Ilia Belousov
Creation date:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define inv8xl-line-data-key        "LD":U
&global-define inv8xl-valutCode            "valutCode":U
&global-define inv8xl-columnList           "columnList":U
&global-define inv8xl-columnType           "columnType":U
&global-define inv8xl-columnAmount         "columnAmount":U

&global-define inv8xl-subtotalList         "subtotalList":U
&global-define inv8xl-subtotalType         "subtotalType":U
&global-define inv8xl-subtotalAmount       "subtotalAmount":U
&global-define inv8xl-subtotalPropisList   "subtotalPropisList":U
&global-define inv8xl-subtotalPropisAmount "subtotalPropisAmount":U

&global-define inv8xl-h_organization       "h_organization":U
&global-define inv8xl-h_object             "h_object":U
&global-define inv8xl-h_docCode            "h_docCode":U
&global-define inv8xl-h_docDate            "h_docDate":U

&global-define inv8xl-f_s_num              "f_s_Num":U
&global-define inv8xl-f_s_WeightFact       "f_s_WeightFact":U
&global-define inv8xl-f_s_qntyFact         "f_s_qntyFact":U
&global-define inv8xl-f_WeightFact         "f_WeightFact":U
&global-define inv8xl-f_qntyFact           "f_qntyFact":U
&global-define inv8xl-f_WeightBuh          "f_WeightBuh":U
&global-define inv8xl-f_qntyBuh            "f_qntyBuh":U

&global-define inv8xl-it_qntyFact          "it_qntyFact":U
&global-define inv8xl-it_WeightFact        "it_WeightFact":U
&global-define inv8xl-it_qntyBuh           "it_qntyBuh":U
&global-define inv8xl-it_WeightBuh         "it_WeightBuh":U

&global-define inv8xl-it_s_qntyFact        "it_s_qntyFact":U
&global-define inv8xl-it_s_WeightFact      "it_s_WeightFact":U
&global-define inv8xl-it_s_num             "it_s_Num":U



define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.
define temp-table temp_line-data no-undo
    field data-key       as character
    field xl-line-id     as integer
    field num            as integer
    field name           as character
    field artic          as character
    field b-code         as character
    field EI             as character
    field qntyFact       as character
    field qntyBuh        as character
    field WeightFact     as character
    field WeightItemFact as character
    field WeightItemBuh  as character
    field WeightBuh      as character
    index pi is primary unique
          xl-line-id
.

define variable v-inv8xl-current-data-row     as integer      no-undo.
define variable v-inv8xl-cell-file-name       as character    no-undo.
define variable v-inv8xl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure inv8xl-init :

    define buffer buf_temp_cell-data        for temp_cell-data.
    define buffer buf_usr-flt               for ubflt.usr-flt.
do
for buf_temp_cell-data
  , buf_usr-flt
on error undo, return error
:
    assign
        v-inv8xl-current-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-inv8xl-data-file-name
    ).
    output stream excel-line to value( v-inv8xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-inv8xl-cell-file-name
    ).
    output stream excel-cell to value( v-inv8xl-cell-file-name ).
    if printrubl = yes
    then do:
        run inv8xl-write-cell-data in this-procedure (
              input {&inv8xl-valutCode}
            , input "0":U
        ).
    end.
    else do:
        run inv8xl-write-cell-data in this-procedure (
              input {&inv8xl-valutCode}
            , input "1":U
        ).
    end.
    run inv8xl-write-cell-data in this-procedure (
          input {&inv8xl-columnList}
        , input "num,name,artic,barcod,EI,qntyFact,WeightItemFact,WeightFact,qntyBuh,WeightItemBuh,WeightBuh":U
    ).
    run inv8xl-write-cell-data in this-procedure (
          input {&inv8xl-columnType}
        , input "I,S,S,S,S,D,I,D,D,I,D":U
    ).
    run inv8xl-write-cell-data in this-procedure (
          input {&inv8xl-columnAmount}
        , input "10":U
    ).
    run inv8xl-write-cell-data in this-procedure (
          input {&inv8xl-subtotalList}
        , input "num,qntyFact,WeightFact,qntyBuh,WeightBuh":U
    ).
    run inv8xl-write-cell-data in this-procedure (
          input {&inv8xl-subtotalType}
        , input "S,S,S,S,S":U
    ).
    run inv8xl-write-cell-data in this-procedure (
          input {&inv8xl-subtotalAmount}
        , input "5":U
    ).
    run inv8xl-write-cell-data in this-procedure (
        input {&inv8xl-subtotalPropisList}
        , input "num,qntyFact,WeightFact":U
    ).
    run inv8xl-write-cell-data in this-procedure (
        input {&inv8xl-subtotalPropisAmount}
        , input "3":U
    ).
end.
end procedure. /* inv8xl-init */

/*==========================================================================*/
procedure inv8xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/inv8_97.xlt":U.
        export "exe/t_97.bas":U.
        export v-inv8xl-cell-file-name.
        export v-inv8xl-data-file-name.
    output close.
end.
end procedure. /* inv8xl-close */


/*==========================================================================*/
procedure inv8xl-write-cell-data :
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
end procedure. /* inv8xl-write-cell-data */


/*==========================================================================*/
procedure inv8xl-write-line-data :
define input parameter p-num            as integer          no-undo.
define input parameter p-name           as character        no-undo.
define input parameter p-artic          as character        no-undo.
define input parameter p-b-code         as character        no-undo.
define input parameter p-EI             as character        no-undo.
define input parameter p-qntyFact       as character        no-undo.
define input parameter p-WeightItemFact as character        no-undo.
define input parameter p-WeightFact     as character        no-undo.
define input parameter p-qntyBuh        as character        no-undo.
define input parameter p-WeightItemBuh  as character        no-undo.
define input parameter p-WeightBuh      as character        no-undo.

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
        v-inv8xl-current-data-row = v-inv8xl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key     = {&inv8xl-line-data-key}
        buf_temp_line-data.xl-line-id   = v-inv8xl-current-data-row
        buf_temp_line-data.num       = p-num
        buf_temp_line-data.name      = p-name
        buf_temp_line-data.artic     = p-artic
        buf_temp_line-data.b-code    = p-b-code
        buf_temp_line-data.EI        = p-EI
        buf_temp_line-data.qntyFact  = p-qntyFact
        buf_temp_line-data.WeightItemFact   = p-WeightFact
        buf_temp_line-data.WeightFact   = p-WeightFact
        buf_temp_line-data.qntyBuh   = p-qntyBuh
        buf_temp_line-data.WeightItemBuh    = p-WeightBuh
        buf_temp_line-data.WeightBuh    = p-WeightBuh
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        {&tabulation}   ( if buf_temp_line-data.num = 0 then "":U else string( buf_temp_line-data.num ) )
        {&tabulation}   buf_temp_line-data.name
        {&tabulation}   buf_temp_line-data.artic
        {&tabulation}   buf_temp_line-data.b-code
        {&tabulation}   buf_temp_line-data.EI
        {&tabulation}   buf_temp_line-data.qntyFact
        {&tabulation}   buf_temp_line-data.WeightItemFact
        {&tabulation}   buf_temp_line-data.WeightFact
        {&tabulation}   buf_temp_line-data.qntyBuh
        {&tabulation}   buf_temp_line-data.WeightItemBuh
        {&tabulation}   buf_temp_line-data.WeightBuh
        {&new-line}
    .
end.
end procedure. /* inv8xl-write-line-data */


/*==========================================================================*/
procedure inv8xl-run-excel :
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
        v-template-file-name    = search( "exe/inv8_97.xlt" )
        v-vb-file-name          = search( "exe/t_97.bas")
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
end procedure. /* inv8xl-run-excel */

/* $Workfile$ e n d */