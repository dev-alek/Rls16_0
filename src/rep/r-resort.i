/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы пересортицы в Excel

Автор: Булгаков Андрей Николаевич
Дата создания: 05/23/06
Author: Andrew Bulgakoff
Creation date: 05/23/06

*/

&scoped-define vssseq {&sequence}

define variable vss-include-info{&vssseq} as character no-undo format "x(65)":U
  initial "@(#)$Workfile$ $Revision$":U .

&global-define r-resort_template      "peresort.xlt":U

&global-define r-resort-line-data-key "LD":U
&global-define r-resort-valutCode     "valutCode":U
&global-define r-resort-columnList    "columnList":U
&global-define r-resort-columnType    "columnType":U
&global-define r-resort-columnAmount  "columnAmount":U

&global-define r-resort-h_OwnFirm     "h_OwnFirm":U
&global-define r-resort-h_ObjName     "h_ObjName":U
&global-define r-resort-h_DocType     "h_DocType":U
&global-define r-resort-h_DocCode     "h_DocCode":U
&global-define r-resort-h_DocDate     "h_DocDate":U
&global-define r-resort-h_DocFact     "h_DocFact":U
&global-define r-resort-h_PostScr     "h_PostScr":U
&global-define r-resort-h_SaleTot     "h_SaleTot":U
&global-define r-resort-h_CostTot     "h_CostTot":U
&global-define r-resort-h_WordTot     "h_WordTot":U

define stream excel-line .
define stream excel-cell .

define temp-table temp_cell-data no-undo
  field data-key   as character
  field data-value as character

  index pi         is primary   unique data-key
.

define temp-table temp_line-data no-undo
  field data-key   as character
  field xl-line-id as integer
  field Num        as integer   /* 1 */
  field Artic      as character /* 2 */
  field Name       as character /* 3 */
  field EdIzm      as character /* 4 */
  field Qnty       as character /* 5 */
  field Price      as character /* 6 */
  field Sum        as character /* 7 */
  field PerCent    as character /* 8 */
  field Cost       as character /* 9 */

  index pi         is primary   unique xl-line-id
.

define variable v-r-resort-current-data-row as integer   no-undo .
define variable v-r-resort-cell-file-name   as character no-undo .
define variable v-r-resort-data-file-name   as character no-undo .

procedure r-resort-init :
  define buffer buf_temp_cell-data for temp_cell-data .
  define buffer buf_usr-flt        for ubflt.usr-flt .

  do
  for buf_temp_cell-data
    , buf_usr-flt
  on error undo, return error
  :
    assign
      v-r-resort-current-data-row = 0
    .
    run gbl/_tmpfile.p
      ( input "xd"
      , input ".txt"
      , output v-r-resort-data-file-name
      ) .
    output stream excel-line to value( v-r-resort-data-file-name ) .
    run gbl/_tmpfile.p
      ( input "xc"
      , input ".txt"
      , output v-r-resort-cell-file-name
      ) .
    output stream excel-cell to value( v-r-resort-cell-file-name ) .
    run r-resort-write-cell-data in this-procedure
      ( input {&r-resort-valutCode}
      , input "0":U
      ) .
    run r-resort-write-cell-data in this-procedure
      ( input {&r-resort-columnList}
      , input "Num,Artic,Name,EdIzm,Qnty,Price,Sum,PerCent,Cost"
      ) .
    run r-resort-write-cell-data in this-procedure
      ( input {&r-resort-columnType}
      , input "I,S,S,S,D,D,D,D,D":U
      ) .
    run r-resort-write-cell-data in this-procedure
      ( input {&r-resort-columnAmount}
      , input "9":U
      ) .
  end. /* on error */
end procedure. /* r-resort-init */

procedure r-resort-close :
  do
  on error undo, return error
  :
    output stream excel-line close .
    output stream excel-cell close .
    output to value( string( session :temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append .
    export string ("exe/" + {&r-resort_template}) .
    export "exe/t_97.bas":U .
    export v-r-resort-cell-file-name .
    export v-r-resort-data-file-name .
    output close .
  end. /* on error */
end procedure. /* r-resort-close */

procedure r-resort-write-cell-data :
  define input parameter p-data-key   as character no-undo .
  define input parameter p-data-value as character no-undo .

  define buffer buf_temp_cell-data for temp_cell-data .

  do
  for buf_temp_cell-data
  on error undo, return error
  :
    find first buf_temp_cell-data where
               buf_temp_cell-data.data-key = p-data-key no-error.
    if not available buf_temp_cell-data
    then do:
      create buf_temp_cell-data .
      assign
        buf_temp_cell-data.data-key = p-data-key
      .
    end.
    assign
      buf_temp_cell-data.data-value = p-data-value
    .
    put stream excel-cell unformatted
      buf_temp_cell-data.data-key   {&tabulation}
      buf_temp_cell-data.data-value {&new-line}
    .
  end. /* on error */
end procedure. /* r-resort-write-cell-data */

procedure r-resort-write-line-data :
  define input parameter p-Num     as integer   no-undo .
  define input parameter p-Artic   as character no-undo .
  define input parameter p-Name    as character no-undo .
  define input parameter p-EdIzm   as character no-undo .
  define input parameter p-Qnty    as character no-undo .
  define input parameter p-Price   as character no-undo .
  define input parameter p-Sum     as character no-undo .
  define input parameter p-PerCent as character no-undo .
  define input parameter p-Cost    as character no-undo .

  define buffer buf_temp_line-data for temp_line-data .

  do
  for buf_temp_line-data
  on error undo, return error
  :
    for each buf_temp_line-data
    :
      delete buf_temp_line-data .
    end.
    create buf_temp_line-data .
    assign
      v-r-resort-current-data-row = v-r-resort-current-data-row + 1
    .
    assign
      buf_temp_line-data.data-key   = {&r-resort-line-data-key}
      buf_temp_line-data.xl-line-id = v-r-resort-current-data-row
      buf_temp_line-data.Num        = p-Num
      buf_temp_line-data.Artic      = p-Artic
      buf_temp_line-data.Name       = p-Name
      buf_temp_line-data.EdIzm      = p-EdIzm
      buf_temp_line-data.Qnty       = p-Qnty
      buf_temp_line-data.Price      = p-Price
      buf_temp_line-data.Sum        = p-Sum
      buf_temp_line-data.PerCent    = p-PerCent
      buf_temp_line-data.Cost       = p-Cost
    .
    put stream excel-line unformatted
      buf_temp_line-data.data-key {&tabulation}
    .
    if buf_temp_line-data.Num = ?
    then do:
      put stream excel-line unformatted
        {&tabulation}
      .
    end.
    else do:
      put stream excel-line unformatted
        buf_temp_line-data.Num    {&tabulation}
      .
    end.
    put stream excel-line unformatted
      buf_temp_line-data.Artic    {&tabulation}
      buf_temp_line-data.Name     {&tabulation}
      buf_temp_line-data.EdIzm    {&tabulation}
      buf_temp_line-data.Qnty     {&tabulation}
      buf_temp_line-data.Price    {&tabulation}
      buf_temp_line-data.Sum      {&tabulation}
    .
    if buf_temp_line-data.PerCent = ?
    then do:
      put stream excel-line unformatted
        {&tabulation}
      .
    end.
    else do:
      put stream excel-line unformatted
        buf_temp_line-data.PerCent {&tabulation}
      .
    end.
    .
    put stream excel-line unformatted
      buf_temp_line-data.Cost     {&new-line}
    .
  end. /* on error */
end procedure. /* r-resort-write-line-data */

procedure r-resort-run-excel :
  define input parameter p-header-filename as character no-undo .
  define input parameter p-data-filename   as character no-undo .

  define variable v-template-file-name as character no-undo .
  define variable v-vb-file-name       as character no-undo .

  define buffer buf_temp-param for temp-param .

  do
  for buf_temp-param
  on error undo, return error
  :
    create buf_temp-param.
    assign
      v-template-file-name = search( string ("exe/" + {&r-resort_template}) )
      v-vb-file-name       = search( "exe/t_97.bas" )
    .
    if v-template-file-name = ? or
       v-template-file-name = "":U
    then do:
      message
        "Ошибка имени файла шаблона."
      view-as alert-box error .
    end.
    if v-vb-file-name = ? or
       v-vb-file-name = "":U
    then do:
      message
        "Ошибка имени файла кода обработки."
      view-as alert-box error .
    end.
    run paramls-write in this-procedure
      ( input {&paramls-template}
      , input {&paramls-template-file-name}
      , input v-template-file-name
      ) .
    run paramls-write in this-procedure
      ( input {&paramls-template}
      , input {&paramls-vb-file-name}
      , input v-vb-file-name
      ) .
    run paramls-write in this-procedure
      ( input {&paramls-data}
      , input {&paramls-data-header-filename}
      , input p-header-filename
      ) .
    run paramls-write in this-procedure
      ( input {&paramls-data}
      , input {&paramls-data-filename}
      , input p-data-filename
      ) .
    run gbl/macroxlt.p
      ( input-output table buf_temp-param
      ) no-error .
    if error-status :error
    then do:
      message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
              "Ошибка создания файла Excel."  skip( 0 )
              return-value                    skip( 0 )
              trim( error-status :get-message( 1 ) )
              trim( error-status :get-message( 2 ) )
              trim( error-status :get-message( 3 ) )
      view-as alert-box error .
      undo, return error .
    end.
  end. /* on error */
end procedure. /* r-resort-run-excel */

/* $Workfile$   E n d */