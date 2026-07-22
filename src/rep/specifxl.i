/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения Спецификация по партиям к документу в Excel

Автор: Самков Сергей Васильевич
Дата создания: 03/11/12
Author: Samkov Sergey
Creation date: 03/11/12

Required:  { gbl/paramls.i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define specifxl-line-data-key "LD":U
&global-define specifxl-regularExpressions "regularExpressions":U
&global-define specifxl-valutCode "valutCode":U
&global-define specifxl-columnList "columnList":U
&global-define specifxl-columnType "columnType":U
&global-define specifxl-columnAmount "columnAmount":U

&global-define specifxl-h_docName       "h_docName":U
&global-define specifxl-h_docCode       "h_docCode":U
&global-define specifxl-h_docDate       "h_docDate":U
&global-define specifxl-h_printdate     "h_printdate":U

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
    field iCounter    as integer
    field cTb-code    as character format "X({&BarCode_Length})"
    field artic       like ub.goods.artic
    field gds-name    like ub.goods.gds-name
    field qnty        as decimal
    field unit-base   like ub.goods.unit-base
    field last-date   like ub.parts.last-date
    field PS          like ub.parts.PS
    field price-rubl  like ub.parts.price-rubl
    field list-b-code as character

    index pi is primary unique xl-line-id
.

define variable v-specifxl-current-data-row     as integer      no-undo.
define variable v-specifxl-cell-file-name       as character    no-undo.
define variable v-specifxl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure specifxl-init :

    define buffer buf_temp_cell-data        for temp_cell-data.
do
for buf_temp_cell-data on error undo, return error :
    assign
        v-specifxl-current-data-row = 0
    .
    run gbl/_tmpfile.p
      (input  "xd"
      ,input  ".txt"
      ,output v-specifxl-data-file-name
      ).
    output stream excel-line to value( v-specifxl-data-file-name ).
    run gbl/_tmpfile.p
      (input "xc"
      ,input ".txt"
      ,output v-specifxl-cell-file-name
      ).
    output stream excel-cell to value( v-specifxl-cell-file-name ).

    run specifxl-write-cell-data in this-procedure
         (input {&specifxl-valutCode}
         ,input "0":U
      ).
    run specifxl-write-cell-data in this-procedure (
          input {&specifxl-regularExpressions}
        , input "1":U
      ).
    if print_zak then do:
      run specifxl-write-cell-data in this-procedure (
            input {&specifxl-columnList}
          , input "ID,code,artic,name,qnty,EI,ldate,PS,price,listbcode":U
      ).
      run specifxl-write-cell-data in this-procedure (
            input {&specifxl-columnType}
          , input "I,S,S,S,D,S,S,S,D,S":U
      ).
      run specifxl-write-cell-data in this-procedure (
            input {&specifxl-columnAmount}
          , input "10":U
      ).
    end.
    else do:
      run specifxl-write-cell-data in this-procedure (
            input {&specifxl-columnList}
          , input "ID,code,artic,name,qnty,EI,ldate,PS,listbcode":U
      ).
      run specifxl-write-cell-data in this-procedure (
            input {&specifxl-columnType}
          , input "I,S,S,S,D,S,S,S,S":U
      ).
      run specifxl-write-cell-data in this-procedure (
            input {&specifxl-columnAmount}
          , input "9":U
      ).
    end.
end.
end procedure. /* specifxl-init */

/*==========================================================================*/
procedure specifxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
      if print_zak then do:
        export "exe/specif.xlt":U.
      end.
      else do:
        export "exe/specif1.xlt":U.
      end.
        export "exe/t_97.bas":U.
        export v-specifxl-cell-file-name.
        export v-specifxl-data-file-name.
    output close.
end.
end procedure. /* specifxl-close */


/*==========================================================================*/
procedure specifxl-write-cell-data :
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
end procedure. /* specifxl-write-cell-data */


/*==========================================================================*/
procedure specifxl-write-line-data :
define input parameter p-Counter     as integer               no-undo.
define input parameter p-cTb-code    as character format "X({&BarCode_Length})" no-undo.
define input parameter p-artic       like goods.artic         no-undo.
define input parameter p-gds-name    like ub.goods.gds-name   no-undo.
define input parameter p-qnty        as decimal               no-undo.
define input parameter p-unit-base   like ub.goods.unit-base  no-undo.
define input parameter p-last-date   like ub.parts.last-date  no-undo.
define input parameter p-PS          like ub.parts.PS         no-undo.
define input parameter p-price-rubl  like ub.parts.price-rubl no-undo.
define input parameter p-list-b-code as character             no-undo.
define input parameter p-print_zak   as logical               no-undo.

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
    v-specifxl-current-data-row = v-specifxl-current-data-row + 1
  .
  assign
    buf_temp_line-data.data-key     = {&specifxl-line-data-key}
    buf_temp_line-data.xl-line-id   = v-specifxl-current-data-row
    buf_temp_line-data.iCounter     = p-Counter
    buf_temp_line-data.cTb-code     = p-cTb-code
    buf_temp_line-data.artic        = p-artic
    buf_temp_line-data.gds-name     = p-gds-name
    buf_temp_line-data.qnty         = p-qnty
    buf_temp_line-data.unit-base    = p-unit-base
    buf_temp_line-data.last-date    = p-last-date
    buf_temp_line-data.PS           = p-PS
    buf_temp_line-data.price-rubl   = p-price-rubl
    buf_temp_line-data.list-b-code  = p-list-b-code
  .
  put stream excel-line unformatted
                    buf_temp_line-data.data-key
    {&tabulation}   ( if buf_temp_line-data.iCounter = 0 then "":U else string( buf_temp_line-data.iCounter ) )
    {&tabulation}   buf_temp_line-data.cTb-code
    {&tabulation}   buf_temp_line-data.artic
    {&tabulation}   buf_temp_line-data.gds-name
    {&tabulation}   ( if buf_temp_line-data.qnty = 0 then "" else string( buf_temp_line-data.qnty ) )
    {&tabulation}   buf_temp_line-data.unit-base
    {&tabulation}   ( if buf_temp_line-data.iCounter = 0 then ( if buf_temp_line-data.last-date = ? then "":U else string( buf_temp_line-data.last-date, "99.99.9999" ) ) else "":U )
    {&tabulation}   buf_temp_line-data.PS
    {&tabulation}   ( if print_zak then ( if buf_temp_line-data.price-rubl = 0 then "" else string( buf_temp_line-data.price-rubl ) ) else buf_temp_line-data.list-b-code )
    ( if print_zak then {&tabulation} else "" )
    ( if print_zak then buf_temp_line-data.list-b-code else "" )
    {&new-line}
  .
end.
end procedure. /* specifxl-write-line-data */


/*==========================================================================*/
procedure specifxl-run-excel :
  define input parameter p-header-filename    as character        no-undo.
  define input parameter p-data-filename      as character        no-undo.

  define variable v-template-file-name    as character    no-undo.
  define variable v-vb-file-name          as character    no-undo.

  define buffer buf_temp-param for temp-param .

  do for buf_temp-param on error undo, return error :
    create buf_temp-param.
    assign
        v-template-file-name    = search( "exe/sp_97.xlt" )
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
end procedure. /* specifxl-run-excel */

/* $Workfile$ e n d */