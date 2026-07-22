/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы torg-12 в Excel

Автор: Кочетков Михаил Юрьевич
Дата создания: 08/30/06
Author: Michael Kochetkov
Creation date: 08/30/06

Required:  { gbl/paramls.i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define outretxl-line-data-key "LD":U
&global-define outretxl-regularExpressions "regularExpressions":U
&global-define outretxl-valutCode "valutCode":U
&global-define outretxl-columnList "columnList":U
&global-define outretxl-columnType "columnType":U
&global-define outretxl-columnAmount "columnAmount":U
&global-define outretxl-subtotalList "subtotalList":U
&global-define outretxl-subtotalType "subtotalType":U
&global-define outretxl-subtotalAmount "subtotalAmount":U

&global-define outretxl-h_docName       "h_docName":U
&global-define outretxl-h_docCode       "h_docCode":U
&global-define outretxl-h_docDate       "h_docDate":U
&global-define outretxl-h_cliFrom       "h_cliFrom":U
&global-define outretxl-h_cliTo         "h_cliTo":U
&global-define outretxl-h_CostPrice     "h_CostPrice":U
&global-define outretxl-h_PayType       "h_PayType":U
&global-define outretxl-h_PS            "h_PS":U
&global-define outretxl-h_reason        "h_reason":U

&global-define outretxl-it_qnty         "it_qnty":U
&global-define outretxl-it_sum          "it_sum":U
&global-define outretxl-f_lineAmount    "f_lineAmount":U
&global-define outretxl-f_placeAmount   "f_placeAmount":U
&global-define outretxl-f_sumAmount     "f_sumAmount":U
&global-define outretxl-f_Skidka        "f_Skidka":U
&global-define outretxl-f_SumAll        "f_SumAll":U
&global-define outretxl-f_SumAllLiteral "f_SumAllLiteral":U
&global-define outretxl-f_Nalog         "f_Nalog":U
&global-define outretxl-f_OperName      "f_OperName":U
&global-define outretxl-f_KladName      "f_KladName":U
&global-define outretxl-f_MngrName      "f_MngrName":U
&global-define outretxl-f_Date          "f_Date":U

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
    field part-code    as character
    field price        as character
    field qnty         as character
    field sum          as character

    index pi is primary unique xl-line-id
.

define variable v-outretxl-current-data-row     as integer      no-undo.
define variable v-outretxl-cell-file-name       as character    no-undo.
define variable v-outretxl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure outretxl-init :

    define buffer buf_temp_cell-data        for temp_cell-data.
do
for buf_temp_cell-data on error undo, return error :
    assign
        v-outretxl-current-data-row = 0
    .
    run gbl/_tmpfile.p
      (input  "xd"
      ,input  ".txt"
      ,output v-outretxl-data-file-name
      ).
    output stream excel-line to value( v-outretxl-data-file-name ).
    run gbl/_tmpfile.p
      (input "xc"
      ,input ".txt"
      ,output v-outretxl-cell-file-name
      ).
    output stream excel-cell to value( v-outretxl-cell-file-name ).

    if printrubl
    then do:
        run outretxl-write-cell-data in this-procedure
          (input {&outretxl-valutCode}
          ,input "0":U
          ).
    end.
    else do:
        run outretxl-write-cell-data in this-procedure (
              input {&outretxl-valutCode}
            , input "1":U
        ).
    end.
    run outretxl-write-cell-data in this-procedure (
          input {&outretxl-regularExpressions}
        , input "1":U
    ).
    run outretxl-write-cell-data in this-procedure (
          input {&outretxl-columnList}
        , input "ID,artic,gdscode,EI,Name,price,qnty,sum":U
    ).
    run outretxl-write-cell-data in this-procedure (
          input {&outretxl-columnType}
        , input "I,I,S,S,S,D,D,D":U
    ).
    run outretxl-write-cell-data in this-procedure (
          input {&outretxl-columnAmount}
        , input "8":U
    ).
    run outretxl-write-cell-data in this-procedure (
          input {&outretxl-subtotalList}
        , input "qnty,sum":U
    ).
    run outretxl-write-cell-data in this-procedure (
          input {&outretxl-subtotalType}
        , input "D,D":U
    ).
    run outretxl-write-cell-data in this-procedure (
          input {&outretxl-subtotalAmount}
        , input "2":U
    ).
end.
end procedure. /* outretxl-init */

/*==========================================================================*/
procedure outretxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/ap_97.xlt":U.
        export "exe/t_97.bas":U.
        export v-outretxl-cell-file-name.
        export v-outretxl-data-file-name.
    output close.
end.
end procedure. /* outretxl-close */


/*==========================================================================*/
procedure outretxl-write-cell-data :
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
end procedure. /* outretxl-write-cell-data */


/*==========================================================================*/
procedure outretxl-write-line-data :
define input parameter p-ID             as integer          no-undo.
define input parameter p-gdscode        as character        no-undo.
define input parameter p-artic          as character        no-undo.
define input parameter p-Name           as character        no-undo.
define input parameter p-part-code      as character        no-undo.
define input parameter p-price          as character        no-undo.
define input parameter p-qnty           as character        no-undo.
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
        v-outretxl-current-data-row = v-outretxl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key     = {&outretxl-line-data-key}
        buf_temp_line-data.xl-line-id   = v-outretxl-current-data-row
        buf_temp_line-data.id           = p-id
        buf_temp_line-data.gdscode      = p-gdscode
        buf_temp_line-data.artic        = p-artic
        buf_temp_line-data.Name         = p-Name
        buf_temp_line-data.part-code           = p-part-code
        buf_temp_line-data.price        = p-price
        buf_temp_line-data.qnty         = p-qnty
        buf_temp_line-data.sum          = p-sum
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        {&tabulation}   ( if buf_temp_line-data.id = 0 then "":U else string( buf_temp_line-data.id ) )
        {&tabulation}   buf_temp_line-data.artic
        {&tabulation}   buf_temp_line-data.gdscode
        {&tabulation}   buf_temp_line-data.part-code
        {&tabulation}   buf_temp_line-data.Name
        {&tabulation}   buf_temp_line-data.price
        {&tabulation}   buf_temp_line-data.qnty
        {&tabulation}   buf_temp_line-data.sum
        {&new-line}
    .
end.
end procedure. /* outretxl-write-line-data */


/*==========================================================================*/
procedure outretxl-run-excel :
  define input parameter p-header-filename    as character        no-undo.
  define input parameter p-data-filename      as character        no-undo.

  define variable v-template-file-name    as character    no-undo.
  define variable v-vb-file-name          as character    no-undo.

  define buffer buf_temp-param for temp-param .

  do for buf_temp-param on error undo, return error :
    create buf_temp-param.
    assign
        v-template-file-name    = search( "exe/no_97.xlt" )
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
        message vss-workfile vss-revision vss-description skip(1)
            skip "Ошибка создания файла Excel."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
  end.
end procedure. /* outretxl-run-excel */

/* $Workfile$ e n d */