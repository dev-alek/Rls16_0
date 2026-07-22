/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы инвентаризационной описи в Excel

Автор: Булгаков Андрей Николаевич
Дата создания: 05/23/06
Author: Andrew Bulgakoff
Creation date: 05/23/06

*/

&scoped-define vssseq {&sequence}

define variable vss-include-info{&vssseq} as character no-undo format "x(65)":U
  initial "@(#)$Workfile$ $Revision$":U .

&global-define r-orioxl-line-data-key "LD":U
&global-define r-orioxl-valutCode     "valutCode":U
&global-define r-orioxl-columnList    "columnList":U
&global-define r-orioxl-columnType    "columnType":U
&global-define r-orioxl-columnAmount  "columnAmount":U

&global-define r-orioxl-h_OwnFirm     "h_OwnFirm":U
&global-define r-orioxl-h_ObjCode     "h_ObjCode":U
&global-define r-orioxl-h_DocStamp    "h_DocStamp":U

define stream excel-line .
define stream excel-cell .

define temp-table temp_cell-data no-undo
  field data-key   as character
  field data-value as character

  index pi         is primary   unique data-key
.

define temp-table temp_line-data no-undo
  field data-key      as character
  field xl-line-id    as integer
  field Num           as integer   /*  1 */
  field Name          as character /*  2 */
  field Locate        as character /*  3 */
  field Artic         as character /*  4 */
  field LevelTotal    as character /*  5 */
  field LevelWater    as character /*  6 */
  field BruttoQnty    as character /*  7 */
  field WaterQnty     as character /*  8 */
  field PetrolQnty    as character /*  9 */
  field Density       as character /* 10 */
  field Temperature   as character /* 11 */
  field BruttoCliQnty as character /* 12 */
  field WaterCliQnty  as character /* 15 */
  field PetrolCliQnty as character /* 17 */
  field AddCliQnty    as character /* 18 */
  field OverCliQnty   as character /* 21 */
  field Price         as character /* 22 */
  field OverSum       as character /* 23 */
  field BookQnty      as character /* 24 */
  field BookSum       as character /* 25 */
  field ExtraQnty     as character /* 26 */
  field ExtraSum      as character /* 27 */
  field MissQnty      as character /* 28 */
  field MissSum       as character /* 29 */

  index pi            is primary   unique xl-line-id
.

define variable v-r-orioxl-current-data-row as integer   no-undo .
define variable v-r-orioxl-cell-file-name   as character no-undo .
define variable v-r-orioxl-data-file-name   as character no-undo .

procedure r-orioxl-init :
  define buffer buf_temp_cell-data for temp_cell-data .
  define buffer buf_usr-flt        for ubflt.usr-flt .

  do
  for buf_temp_cell-data
    , buf_usr-flt
  on error undo, return error
  :
    assign
      v-r-orioxl-current-data-row = 0
    .
    run gbl/_tmpfile.p
      ( input "xd"
      , input ".txt"
      , output v-r-orioxl-data-file-name
      ) .
    output stream excel-line to value( v-r-orioxl-data-file-name ) .
    run gbl/_tmpfile.p
      ( input "xc"
      , input ".txt"
      , output v-r-orioxl-cell-file-name
      ) .
    output stream excel-cell to value( v-r-orioxl-cell-file-name ) .
    run r-orioxl-write-cell-data in this-procedure
      ( input {&r-orioxl-valutCode}
      , input "0":U
      ) .
    run r-orioxl-write-cell-data in this-procedure
      ( input {&r-orioxl-columnList}
      , input "Num,Name,Locate,Artic,LevelTotal,LevelWater,BruttoQnty,WaterQnty,PetrolQnty,Density,Temperature,"
      +       "BruttoCliQnty,WaterCliQnty,PetrolCliQnty,AddCliQnty,OverCliQnty,Price,OverSum,BookQnty,BookSum,ExtraQnty,"
      +       "ExtraSum,MissQnty,MissSum":U
      ) .
    run r-orioxl-write-cell-data in this-procedure
      ( input {&r-orioxl-columnType}
      , input "I,S,I,S,D,D,D,D,D,D,D,D,D,D,D,D,C,C,D,C,D,C,D,C":U
      ) .
    run r-orioxl-write-cell-data in this-procedure
      ( input {&r-orioxl-columnAmount}
      , input "24":U
      ) .
  end. /* on error */
end procedure. /* r-orioxl-init */

procedure r-orioxl-close :
  do
  on error undo, return error
  :
    output stream excel-line close .
    output stream excel-cell close .
    output to value( string( session :temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append .
    export "exe/t32np_97.xlt":U .
    export "exe/t_97.bas":U .
    export v-r-orioxl-cell-file-name .
    export v-r-orioxl-data-file-name .
    output close .
  end. /* on error */
end procedure. /* r-orioxl-close */

procedure r-orioxl-write-cell-data :
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
end procedure. /* r-orioxl-write-cell-data */

procedure r-orioxl-write-line-data :
  define input parameter p-Num           as integer   no-undo .
  define input parameter p-Name          as character no-undo .
  define input parameter p-Locate        as character no-undo .
  define input parameter p-Artic         as character no-undo .
  define input parameter p-LevelTotal    as character no-undo .
  define input parameter p-LevelWater    as character no-undo .
  define input parameter p-BruttoQnty    as character no-undo .
  define input parameter p-WaterQnty     as character no-undo .
  define input parameter p-PetrolQnty    as character no-undo .
  define input parameter p-Density       as character no-undo .
  define input parameter p-Temperature   as character no-undo .
  define input parameter p-BruttoCliQnty as character no-undo .
  define input parameter p-WaterCliQnty  as character no-undo .
  define input parameter p-PetrolCliQnty as character no-undo .
  define input parameter p-AddCliQnty    as character no-undo .
  define input parameter p-OverCliQnty   as character no-undo .
  define input parameter p-Price         as character no-undo .
  define input parameter p-OverSum       as character no-undo .
  define input parameter p-BookQnty      as character no-undo .
  define input parameter p-BookSum       as character no-undo .
  define input parameter p-ExtraQnty     as character no-undo .
  define input parameter p-ExtraSum      as character no-undo .
  define input parameter p-MissQnty      as character no-undo .
  define input parameter p-MissSum       as character no-undo .

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
      v-r-orioxl-current-data-row = v-r-orioxl-current-data-row + 1
    .
    assign
      buf_temp_line-data.data-key      = {&r-orioxl-line-data-key}
      buf_temp_line-data.xl-line-id    = v-r-orioxl-current-data-row
      buf_temp_line-data.Num           = p-Num
      buf_temp_line-data.Name          = p-Name
      buf_temp_line-data.Locate        = p-Locate
      buf_temp_line-data.Artic         = p-Artic
      buf_temp_line-data.LevelTotal    = p-LevelTotal
      buf_temp_line-data.LevelWater    = p-LevelWater
      buf_temp_line-data.BruttoQnty    = p-BruttoQnty
      buf_temp_line-data.WaterQnty     = p-WaterQnty
      buf_temp_line-data.PetrolQnty    = p-PetrolQnty
      buf_temp_line-data.Density       = p-Density
      buf_temp_line-data.Temperature   = p-Temperature
      buf_temp_line-data.BruttoCliQnty = p-BruttoCliQnty
      buf_temp_line-data.WaterCliQnty  = p-WaterCliQnty
      buf_temp_line-data.PetrolCliQnty = p-PetrolCliQnty
      buf_temp_line-data.AddCliQnty    = p-AddCliQnty
      buf_temp_line-data.OverCliQnty   = p-OverCliQnty
      buf_temp_line-data.Price         = p-Price
      buf_temp_line-data.OverSum       = p-OverSum
      buf_temp_line-data.BookQnty      = p-BookQnty
      buf_temp_line-data.BookSum       = p-BookSum
      buf_temp_line-data.ExtraQnty     = p-ExtraQnty
      buf_temp_line-data.ExtraSum      = p-ExtraSum
      buf_temp_line-data.MissQnty      = p-MissQnty
      buf_temp_line-data.MissSum       = p-MissSum
    .
    put stream excel-line unformatted
      buf_temp_line-data.data-key      {&tabulation}
      buf_temp_line-data.Num           {&tabulation}
      buf_temp_line-data.Name          {&tabulation}
      buf_temp_line-data.Locate        {&tabulation}
      buf_temp_line-data.Artic         {&tabulation}
      buf_temp_line-data.LevelTotal    {&tabulation}
      buf_temp_line-data.LevelWater    {&tabulation}
      buf_temp_line-data.BruttoQnty    {&tabulation}
      buf_temp_line-data.WaterQnty     {&tabulation}
      buf_temp_line-data.PetrolQnty    {&tabulation}
      buf_temp_line-data.Density       {&tabulation}
      buf_temp_line-data.Temperature   {&tabulation}
      buf_temp_line-data.BruttoCliQnty {&tabulation}
      buf_temp_line-data.WaterCliQnty  {&tabulation}
      buf_temp_line-data.PetrolCliQnty {&tabulation}
      buf_temp_line-data.AddCliQnty    {&tabulation}
      buf_temp_line-data.OverCliQnty   {&tabulation}
      buf_temp_line-data.Price         {&tabulation}
      buf_temp_line-data.OverSum       {&tabulation}
      buf_temp_line-data.BookQnty      {&tabulation}
      buf_temp_line-data.BookSum       {&tabulation}
      buf_temp_line-data.ExtraQnty     {&tabulation}
      buf_temp_line-data.ExtraSum      {&tabulation}
      buf_temp_line-data.MissQnty      {&tabulation}
      buf_temp_line-data.MissSum       {&new-line}
    .
  end. /* on error */
end procedure. /* r-orioxl-write-line-data */

procedure r-orioxl-run-excel :
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
      v-template-file-name = search( "exe/t32np_97.xlt" )
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
end procedure. /* r-orioxl-run-excel */

/* $Workfile$   E n d */