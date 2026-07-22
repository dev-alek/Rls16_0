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

&global-define r-inpxl-line-data-key "LD":U
&global-define r-inpxl-regularExpressions "regularExpressions":U
&global-define r-inpxl-valutCode "valutCode":U
&global-define r-inpxl-columnList "columnList":U
&global-define r-inpxl-columnType "columnType":U
&global-define r-inpxl-columnAmount "columnAmount":U
&global-define r-inpxl-subtotalList "subtotalList":U
&global-define r-inpxl-subtotalType "subtotalType":U
&global-define r-inpxl-subtotalAmount "subtotalAmount":U

&global-define r-inpxl-h_docName       "h_docName":U
&global-define r-inpxl-h_docCode       "h_docCode":U
&global-define r-inpxl-h_docDate       "h_docDate":U
&global-define r-inpxl-h_cliFrom       "h_cliFrom":U
&global-define r-inpxl-h_cliTo         "h_cliTo":U
&global-define r-inpxl-h_CostPrice     "h_CostPrice":U
&global-define r-inpxl-h_PayType       "h_PayType":U
&global-define r-inpxl-h_PS            "h_PS":U
&global-define r-inpxl-h_Osnov         "h_Osnov":U
&global-define r-inpxl-h_Rate          "h_Rate":U
&global-define r-inpxl-h_Invoice       "h_Invoice":U
&global-define r-inpxl-h_Custom        "h_Custom":U
&global-define r-inpxl-h_CustomTax     "h_CustomTax":U
&global-define r-inpxl-h_Zakaz         "h_Zakaz":U

&global-define r-inpxl-it_qnty         "it_qnty":U
&global-define r-inpxl-it_sum          "it_sum":U
&global-define r-inpxl-f_lineAmount    "f_lineAmount":U
&global-define r-inpxl-f_placeAmount   "f_placeAmount":U
&global-define r-inpxl-f_sumAmount     "f_sumAmount":U
&global-define r-inpxl-f_Skidka        "f_Skidka":U
&global-define r-inpxl-f_SumAll        "f_SumAll":U
&global-define r-inpxl-f_SumAllLiteral "f_SumAllLiteral":U
&global-define r-inpxl-f_Nalog         "f_Nalog":U
&global-define r-inpxl-f_OperName      "f_OperName":U
&global-define r-inpxl-f_KladName      "f_KladName":U
&global-define r-inpxl-f_MngrName      "f_MngrName":U
&global-define r-inpxl-f_Date          "f_Date":U

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
    field ID           as integer
    field gdscode      as character
    field artic        as character
    field Name         as character
    field EI           as character
    field price        as character
    field qnty         as character
    field sum          as character
    field nazen        as character

    index pi is primary unique xl-line-id
.

define variable v-r-inpxl-current-data-row     as integer      no-undo.
define variable v-r-inpxl-cell-file-name       as character    no-undo.
define variable v-r-inpxl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure r-inpxl-init :

    define buffer buf_temp_cell-data        for temp_cell-data.
do
for buf_temp_cell-data on error undo, return error :
    assign
        v-r-inpxl-current-data-row = 0
    .
    run gbl/_tmpfile.p
      (input "xd"
      ,input ".txt"
      ,output v-r-inpxl-data-file-name
      ).
    output stream excel-line to value( v-r-inpxl-data-file-name ).
    run gbl/_tmpfile.p
      (input "xc"
      ,input ".txt"
      ,output v-r-inpxl-cell-file-name
      ).
    output stream excel-cell to value( v-r-inpxl-cell-file-name ).

    if printrubl
    then do:
        run r-inpxl-write-cell-data in this-procedure (
              input {&r-inpxl-valutCode}
            , input "0":U
        ).
    end.
    else do:
        run r-inpxl-write-cell-data in this-procedure (
              input {&r-inpxl-valutCode}
            , input "1":U
        ).
    end.
    run r-inpxl-write-cell-data in this-procedure (
          input {&r-inpxl-regularExpressions}
        , input "1":U
    ).
    run r-inpxl-write-cell-data in this-procedure (
          input {&r-inpxl-columnList}
        , input "ID,gdscode,artic,Name,EI,price,qnty,sum,nazen":U
    ).
    run r-inpxl-write-cell-data in this-procedure (
          input {&r-inpxl-columnType}
        , input "I,I,S,S,S,D,D,D,D":U
    ).
    run r-inpxl-write-cell-data in this-procedure (
          input {&r-inpxl-columnAmount}
        , input "9":U
    ).
    run r-inpxl-write-cell-data in this-procedure (
          input {&r-inpxl-subtotalList}
        , input "qnty,sum":U
    ).
    run r-inpxl-write-cell-data in this-procedure (
          input {&r-inpxl-subtotalType}
        , input "S,S":U
    ).
    run r-inpxl-write-cell-data in this-procedure (
          input {&r-inpxl-subtotalAmount}
        , input "2":U
    ).
end.
end procedure. /* r-inpxl-init */

/*==========================================================================*/
procedure r-inpxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/ni_97.xlt":U.
        export "exe/t_97.bas":U.
        export v-r-inpxl-cell-file-name.
        export v-r-inpxl-data-file-name.
    output close.
end.
end procedure. /* r-inpxl-close */


/*==========================================================================*/
procedure r-inpxl-write-cell-data :
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
end procedure. /* r-inpxl-write-cell-data */


/*==========================================================================*/
procedure r-inpxl-write-line-data :
define input parameter p-ID             as integer          no-undo.
define input parameter p-gdscode        as character        no-undo.
define input parameter p-artic          as character        no-undo.
define input parameter p-Name           as character        no-undo.
define input parameter p-EI             as character        no-undo.
define input parameter p-price          as character        no-undo.
define input parameter p-qnty           as character        no-undo.
define input parameter p-sum            as character        no-undo.
define input parameter p-nazen          as character        no-undo.

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
        v-r-inpxl-current-data-row = v-r-inpxl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key     = {&r-inpxl-line-data-key}
        buf_temp_line-data.xl-line-id   = v-r-inpxl-current-data-row
        buf_temp_line-data.id           = p-id
        buf_temp_line-data.gdscode      = p-gdscode
        buf_temp_line-data.artic        = p-artic
        buf_temp_line-data.Name         = p-Name
        buf_temp_line-data.EI           = p-EI
        buf_temp_line-data.price        = p-price
        buf_temp_line-data.qnty         = p-qnty
        buf_temp_line-data.sum          = p-sum
        buf_temp_line-data.nazen        = p-nazen
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        {&tabulation}   ( if buf_temp_line-data.id = 0 then "":U else string( buf_temp_line-data.id ) )
        {&tabulation}   buf_temp_line-data.gdscode
        {&tabulation}   buf_temp_line-data.artic
        {&tabulation}   buf_temp_line-data.Name
        {&tabulation}   buf_temp_line-data.EI
        {&tabulation}   buf_temp_line-data.price
        {&tabulation}   buf_temp_line-data.qnty
        {&tabulation}   buf_temp_line-data.sum
        {&tabulation}   buf_temp_line-data.nazen
        {&new-line}
    .
end.
end procedure. /* r-inpxl-write-line-data */


/*==========================================================================*/
procedure r-inpxl-run-excel :
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
        v-template-file-name    = search( "exe/ni_97.xlt" )
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
end procedure. /* r-inpxl-run-excel */

/* $Workfile$ e n d */