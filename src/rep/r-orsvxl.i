/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы сличительной ведомости в Excel

Автор: Булгаков Андрей Николаевич
Дата создания: 05/23/06
Author: Andrew Bulgakoff
Creation date: 05/23/06

*/

&scoped-define vssseq {&sequence}

define variable vss-include-info{&vssseq} as character no-undo format "x(65)":U
  initial "@(#)$Workfile$ $Revision$":U .

&global-define r-orsvxl-line-data-key "LD":U
&global-define r-orsvxl-valutCode     "valutCode":U
&global-define r-orsvxl-columnList    "columnList":U
&global-define r-orsvxl-columnType    "columnType":U
&global-define r-orsvxl-columnAmount  "columnAmount":U

&global-define r-orsvxl-h_OwnFirm     "h_OwnFirm":U
&global-define r-orsvxl-h_ObjCode     "h_ObjCode":U
&global-define r-orsvxl-h_FactDate    "h_FactDate":U

&global-define r-orsvxl-it_ExtraQnty  "it_ExtraQnty":U
&global-define r-orsvxl-it_ExtraSum   "it_ExtraSum":U
&global-define r-orsvxl-it_MissQnty   "it_MissQnty":U
&global-define r-orsvxl-it_MissSum    "it_MissSum":U
&global-define r-orsvxl-it_LossQnty   "it_LossQnty":U
&global-define r-orsvxl-it_LossSum    "it_LossSum":U
&global-define r-orsvxl-it_NormQnty   "it_NormQnty":U
&global-define r-orsvxl-it_NormSum    "it_NormSum":U
&global-define r-orsvxl-it_XcalcQnty  "it_XcalcQnty":U
&global-define r-orsvxl-it_XcalcSum   "it_XcalcSum":U
&global-define r-orsvxl-it_LcalcQnty  "it_LcalcQnty":U
&global-define r-orsvxl-it_LcalcSum   "it_LcalcSum":U

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
  field Num        as integer   /*  1 */
  field Name       as character /*  2 */
  field artic      as character /*  3 */
  field locate     as character /*  4 */
  field EdIzm      as character /*  5 */
  field Price      as character /*  6 */
  field ExtraQnty  as character /*  7 */
  field ExtraSum   as character /*  8 */
  field MissQnty   as character /*  9 */
  field MissSum    as character /* 10 */
  field LossQnty   as character /* 21 */
  field LossSum    as character /* 22 */
  field NormQnty   as character /* 23 */
  field NormSum    as character /* 24 */
  field XcalcQnty  as character /* 25 */
  field XcalcSum   as character /* 26 */
  field LcalcQnty  as character /* 28 */
  field LcalcSum   as character /* 29 */

  index pi         is primary   unique xl-line-id
.

define variable v-r-orsvxl-current-data-row as integer   no-undo .
define variable v-r-orsvxl-cell-file-name   as character no-undo .
define variable v-r-orsvxl-data-file-name   as character no-undo .

procedure r-orsvxl-init :
  define buffer buf_temp_cell-data for temp_cell-data .
  define buffer buf_usr-flt        for ubflt.usr-flt .

  do
  for buf_temp_cell-data
    , buf_usr-flt
  on error undo, return error
  :
    assign
      v-r-orsvxl-current-data-row = 0
    .
    run gbl/_tmpfile.p
      ( input "xd"
      , input ".txt"
      , output v-r-orsvxl-data-file-name
      ) .
    output stream excel-line to value( v-r-orsvxl-data-file-name ) .
    run gbl/_tmpfile.p
      ( input "xc"
      , input ".txt"
      , output v-r-orsvxl-cell-file-name
      ) .
    output stream excel-cell to value( v-r-orsvxl-cell-file-name ) .
    run r-orsvxl-write-cell-data in this-procedure
      ( input {&r-orsvxl-valutCode}
      , input "0":U
      ) .
    run r-orsvxl-write-cell-data in this-procedure
      ( input {&r-orsvxl-columnList}
      , input "Num,Name,artic,locate,EdIzm,Price,ExtraQnty,ExtraSum,MissQnty,MissSum,":U
      +       "LossQnty,LossSum,NormQnty,NormSum,XcalcQnty,XcalcSum,LcalcQnty,LcalcSum":U
      ) .
    run r-orsvxl-write-cell-data in this-procedure
      ( input {&r-orsvxl-columnType}
      , input "I,S,S,I,S,C,D,C,D,C,D,C,D,C,D,C,D,C":U
      ) .
    run r-orsvxl-write-cell-data in this-procedure
      ( input {&r-orsvxl-columnAmount}
      , input "18":U
      ) .
  end. /* on error */
end procedure. /* r-orsvxl-init */

procedure r-orsvxl-close :
  do
  on error undo, return error
  :
    output stream excel-line close .
    output stream excel-cell close .
    output to value( string( session :temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append .
    export "exe/t33np_97.xlt":U .
    export "exe/t_97.bas":U .
    export v-r-orsvxl-cell-file-name .
    export v-r-orsvxl-data-file-name .
    output close .
  end. /* on error */
end procedure. /* r-orsvxl-close */

procedure r-orsvxl-write-cell-data :
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
end procedure. /* r-orsvxl-write-cell-data */

procedure r-orsvxl-write-line-data :
  define input parameter p-Num       as integer   no-undo .
  define input parameter p-Name      as character no-undo .
  define input parameter p-artic     as character no-undo .
  define input parameter p-locate    as character no-undo .
  define input parameter p-EdIzm     as character no-undo .
  define input parameter p-Price     as character no-undo .
  define input parameter p-ExtraQnty as character no-undo .
  define input parameter p-ExtraSum  as character no-undo .
  define input parameter p-MissQnty  as character no-undo .
  define input parameter p-MissSum   as character no-undo .
  define input parameter p-LossQnty  as character no-undo .
  define input parameter p-LossSum   as character no-undo .
  define input parameter p-NormQnty  as character no-undo .
  define input parameter p-NormSum   as character no-undo .
  define input parameter p-XcalcQnty as character no-undo .
  define input parameter p-XcalcSum  as character no-undo .
  define input parameter p-LcalcQnty as character no-undo .
  define input parameter p-LcalcSum  as character no-undo .

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
      v-r-orsvxl-current-data-row = v-r-orsvxl-current-data-row + 1
    .
    assign
      buf_temp_line-data.data-key   = {&r-orsvxl-line-data-key}
      buf_temp_line-data.xl-line-id = v-r-orsvxl-current-data-row
      buf_temp_line-data.Num        = p-Num
      buf_temp_line-data.Name       = p-Name
      buf_temp_line-data.artic      = p-artic
      buf_temp_line-data.locate     = p-locate
      buf_temp_line-data.EdIzm      = p-EdIzm
      buf_temp_line-data.Price      = p-Price
      buf_temp_line-data.ExtraQnty  = p-ExtraQnty
      buf_temp_line-data.ExtraSum   = p-ExtraSum
      buf_temp_line-data.MissQnty   = p-MissQnty
      buf_temp_line-data.MissSum    = p-MissSum
      buf_temp_line-data.LossQnty   = p-LossQnty
      buf_temp_line-data.LossSum    = p-LossSum
      buf_temp_line-data.NormQnty   = p-NormQnty
      buf_temp_line-data.NormSum    = p-NormSum
      buf_temp_line-data.XcalcQnty  = p-XcalcQnty
      buf_temp_line-data.XcalcSum   = p-XcalcSum
      buf_temp_line-data.LcalcQnty  = p-LcalcQnty
      buf_temp_line-data.LcalcSum   = p-LcalcSum
    .
    put stream excel-line unformatted
      buf_temp_line-data.data-key  {&tabulation}
      buf_temp_line-data.Num       {&tabulation}
      buf_temp_line-data.Name      {&tabulation}
      buf_temp_line-data.artic     {&tabulation}
      buf_temp_line-data.locate    {&tabulation}
      buf_temp_line-data.EdIzm     {&tabulation}
      buf_temp_line-data.Price     {&tabulation}
      buf_temp_line-data.ExtraQnty {&tabulation}
      buf_temp_line-data.ExtraSum  {&tabulation}
      buf_temp_line-data.MissQnty  {&tabulation}
      buf_temp_line-data.MissSum   {&tabulation}
      buf_temp_line-data.LossQnty  {&tabulation}
      buf_temp_line-data.LossSum   {&tabulation}
      buf_temp_line-data.NormQnty  {&tabulation}
      buf_temp_line-data.NormSum   {&tabulation}
      buf_temp_line-data.XcalcQnty {&tabulation}
      buf_temp_line-data.XcalcSum  {&tabulation}
      buf_temp_line-data.LcalcQnty {&tabulation}
      buf_temp_line-data.LcalcSum  {&new-line}
    .
  end. /* on error */
end procedure. /* r-orsvxl-write-line-data */

procedure r-orsvxl-run-excel :
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
      v-template-file-name = search( "exe/t33np_97.xlt" )
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
end procedure. /* r-orsvxl-run-excel */

/* $Workfile$   E n d */