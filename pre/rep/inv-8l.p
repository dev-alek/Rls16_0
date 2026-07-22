block-level on error undo, throw.
define input parameter parParentProc      AS WIDGET-HANDLE NO-UNDO.
define input parameter rec_id   as recid.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: inv-8l.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/inv-8l.p $":U .
define variable vss-description as character no-undo initial "Акт инвентаризации по форме ИНВ-8".
define variable g#report-num as integer   no-undo .
define variable g#quest-print as logical   no-undo .
define variable g#log as logical   no-undo .
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function breakstr returns character ( input        for-name    as character,
                                      input        line-length as integer,
                                      input-output line1       as character,
                                      input-output line2       as character ) :
  define variable ii as integer no-undo.
  if length( for-name ) > line-length then do:
    assign ii    = 1
           line1 = "":u
           line2 = "":u.
    if length( entry( ii, for-name , " ":u ) ) > line-length then do:
      assign line1 =       substring( for-name, 1, line-length     )
             line2 = trim( substring( for-name,    line-length + 1 ) ).
    end.                                                     else do:
      do while length( line1 + entry( ii, for-name, " ":u ) ) < ( line-length + 1 ) :
        assign line1 = line1 + entry( ii, for-name, " ":u ) + " ":u
               ii    = ii    + 1.
        if length( entry( ii, for-name, " ":u ) ) > line-length then do:
          assign line1 = line1 + substring( for-name, length( line1 ), line-length - length( line1 ) + 1 ).
        end.
      end.
      assign line2 = trim( substring( for-name, length( line1 ) ) ).
    end.
  end.                                else do:
    assign line1 = for-name
           line2 = "":u.
  end.
  return ( line1 ).
end function.
    def var t-addres        like ub.firm.addres1   no-undo.
    def var t-phone         like ub.firm.phone     no-undo.
    def var t-inn           like ub.firm.inn       no-undo.
    def var t-okpo          like ub.firm.okpo      no-undo.
    def var t-temp-address  like ub.firm.addres1   no-undo.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-param no-undo   field param-code     as character   field param-sub-code as character   field param-value    as character   index xpk is primary unique param-code param-sub-code   .
procedure paramls-clear :
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    for each buf_temp-param
    on error undo, return error
    :
      delete buf_temp-param .
    end.
  end.
end procedure.
procedure paramls-write :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
      .
    end.
    assign
      buf_temp-param.param-value = p-value
    .
  end.
end procedure.
procedure paramls-read :
  define input  parameter p-code          as character no-undo .
  define input  parameter p-sub-code      as character no-undo .
  define input  parameter p-default-value as character no-undo .
  define output parameter p-value         as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if available buf_temp-param then do:
      assign
        p-value = buf_temp-param.param-value
      .
    end.
    else do:
      assign
        p-value = p-default-value
      .
    end.
  end.
end procedure.
procedure paramls-append :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
         where buf_temp-param.param-code     = p-code
           and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
        buf_temp-param.param-value    = p-value
      .
    end.
    else do:
        assign
            buf_temp-param.param-value = buf_temp-param.param-value + ",":U + p-value
        .
    end.
  end.
end procedure.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
  function valid-density returns logical ( input p-density as decimal, input p-unit-base-cli-eq as logical ) :
    define variable v-answ as logical no-undo .
    if ( p-unit-base-cli-eq = true
         and p-density = 1.0
       )
      or ( p-unit-base-cli-eq = false
           and p-density <> ?
           and p-density > 0.0
           and p-density < 1.0
         )
    then do:
      assign
        v-answ = true
      .
    end.
    else do:
      assign
        v-answ = false
      .
    end.
    return v-answ.
  end function.
define variable vss-include-info5 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
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
              input "valutCode":U
            , input "0":U
        ).
    end.
    else do:
        run inv8xl-write-cell-data in this-procedure (
              input "valutCode":U
            , input "1":U
        ).
    end.
    run inv8xl-write-cell-data in this-procedure (
          input "columnList":U
        , input "num,name,artic,barcod,EI,qntyFact,WeightItemFact,WeightFact,qntyBuh,WeightItemBuh,WeightBuh":U
    ).
    run inv8xl-write-cell-data in this-procedure (
          input "columnType":U
        , input "I,S,S,S,S,D,I,D,D,I,D":U
    ).
    run inv8xl-write-cell-data in this-procedure (
          input "columnAmount":U
        , input "10":U
    ).
    run inv8xl-write-cell-data in this-procedure (
          input "subtotalList":U
        , input "num,qntyFact,WeightFact,qntyBuh,WeightBuh":U
    ).
    run inv8xl-write-cell-data in this-procedure (
          input "subtotalType":U
        , input "S,S,S,S,S":U
    ).
    run inv8xl-write-cell-data in this-procedure (
          input "subtotalAmount":U
        , input "5":U
    ).
    run inv8xl-write-cell-data in this-procedure (
        input "subtotalPropisList":U
        , input "num,qntyFact,WeightFact":U
    ).
    run inv8xl-write-cell-data in this-procedure (
        input "subtotalPropisAmount":U
        , input "3":U
    ).
end.
end procedure.
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
end procedure.
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
        chr(9)   buf_temp_cell-data.data-value
        chr(10)
    .
end.
end procedure.
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
        buf_temp_line-data.data-key     = "LD":U
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
        chr(9)   ( if buf_temp_line-data.num = 0 then "":U else string( buf_temp_line-data.num ) )
        chr(9)   buf_temp_line-data.name
        chr(9)   buf_temp_line-data.artic
        chr(9)   buf_temp_line-data.b-code
        chr(9)   buf_temp_line-data.EI
        chr(9)   buf_temp_line-data.qntyFact
        chr(9)   buf_temp_line-data.WeightItemFact
        chr(9)   buf_temp_line-data.WeightFact
        chr(9)   buf_temp_line-data.qntyBuh
        chr(9)   buf_temp_line-data.WeightItemBuh
        chr(9)   buf_temp_line-data.WeightBuh
        chr(10)
    .
end.
end procedure.
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
          input "template":U
        , input "template-file-name":U
        , input v-template-file-name
    ).
    run paramls-write in this-procedure (
          input "template":U
        , input "vb-file-name":U
        , input v-vb-file-name
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-header-filename":U
        , input p-header-filename
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-filename":U
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
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
DEFINE temp-table temp-str no-undo
  field   gds-name         as character
  field   artic            as character
  field   prod-type        as character
  field   prod-code        as integer
  field   b-code           as character
  field   EI               as character
  field   WeightItemLigat  as decimal
  field   WeightItemClear  as decimal
  field   qntyBuh          as decimal
  field   qntyFact         as decimal
  INDEX pi  IS PRIMARY UNIQUE
               artic
               prod-type
               prod-code
.
define stream Out-Stream.
define buffer buf_clients      for clients .
define buffer This_Object      for clients .
define buffer buf_doc-line     for doc-line .
define buffer buf_goods        for goods .
define buffer buf_doc-line-sum for doc-line-sum .
define buffer buf_gds-dtl      for gds-dtl .
define buffer buf_gds-prt      for gds-prt .
define buffer bf_doc-attr      for doc-attr .
define buffer buf_prod-bc      for prod-bc .
define variable sum1-qntyFact   as decimal initial 0     no-undo .
define variable sum1-qntyBuh    as decimal initial 0     no-undo .
define variable sum1-weightFact-l as decimal initial 0     no-undo .
define variable sum1-weightBuh-l  as decimal initial 0     no-undo .
define variable sum1-weightFact-c as decimal initial 0     no-undo .
define variable sum1-weightBuh-c  as decimal initial 0     no-undo .
define variable weightitem      as decimal initial 0     no-undo .
define variable PgQnty          as decimal               no-undo .
define variable PgWeight-l        as decimal               no-undo .
define variable PgWeight-c        as decimal               no-undo .
define variable PgQntyBuh       as decimal               no-undo .
define variable PgWeightBuh-l     as decimal               no-undo .
define variable PgWeightBuh-c     as decimal               no-undo .
define variable PgNPP           as integer               no-undo .
define variable v-b-code        as integer               no-undo .
define variable num-ln          as integer               no-undo .
 define variable i as integer no-undo.
 define variable j as integer no-undo.
define variable Counter1        as integer initial 0     no-undo .
define variable Lines_Counter   as integer initial 0     no-undo .
define variable Tmp_Counter     as integer initial 0     no-undo .
define variable Line            as character             no-undo .
define variable LineBuf         as character             no-undo .
define variable UndLine         as character             no-undo .
define variable PropisQnty      as character             no-undo .
define variable PropisSumall-l  as character             no-undo .
define variable PropisSumall-c  as character             no-undo .
define variable Propiscount     as character             no-undo .
define variable sym1            as character initial ":" no-undo .
define variable sym2            as character initial ":" no-undo .
define variable sym3            as character initial ":" no-undo .
define variable sym4            as character initial ":" no-undo .
define variable sym5            as character initial ":" no-undo .
define variable sym6            as character initial ":" no-undo .
define variable sym7            as character initial ":" no-undo .
define variable sym8            as character initial ":" no-undo .
define variable sym9            as character initial ":" no-undo .
define variable sym10           as character initial ":" no-undo .
define variable sym11           as character initial ":" no-undo .
define variable sym12           as character initial ":" no-undo .
define variable v-prn0          as character             no-undo .
define variable v-par-type      as character             no-undo .
define variable tdoc-date       like trn-doc.doc-date    no-undo .
define variable tdoc-code       like trn-doc.doc-code    no-undo .
DEFINE FRAME invent-gold
      sym1                 column-label ":!:!:!:!:"                           format "X(1)"  space(0)
      num-ln               column-label "N!по!поряк!ку!":C5                   format ">>>>9" space(0)
      sym3                 column-label ":!:!:!:!:"                           format "X(1)" space(0)
      temp-str.gds-name    column-label " Драгоченные металлы и изделия из них !----------------------------------------! ! Наименование ! ":C40           format "X(40)" space(0)
      sym2                 column-label " !-!:!:!:"                           format "X(1)" space(0)
      temp-str.artic       column-label " !-----------------! ! код ! ":C17                     format "X(17)" space(0)
      Sym4                 column-label " !-!:!:!:"                           format "X(1)" space(0)
      temp-str.b-code      column-label " !-------------! ! бар-код ! ":C13                  format "X(13)" space(0)
      sym5                 column-label ":!:!:!:!:"                           format "X(1)" space(0)
      temp-str.EI          column-label "Проба!или!процент!драг.!металла":C8  format "x(8)" space(0)
      sym6                 column-label ":!:!:!:!:"                           format "X(1)" space(0)
      temp-str.qntyFact    column-label "Фактическое !--------------! !Количество! ":C14 format "->>>>>>>9.<<<" space(0)
      sym7                 column-label " !-!:!:!:"                           format "X(1)" space(0)
      sum1-weightfact-l    column-label " наличие!---------------! Масса !---------------!Лигатурная":C15   format "->>>,>>>,>>9.99" space(0)
      sym8                 column-label " !-! !-!:"                           format "X(1)" space(0)
      sum1-weightfact-c    column-label "!---------------! !---------------! чистая ":C15   format "->>>,>>>,>>9.99" space(0)
      sym9                 column-label ":!:!:!:!:"                           format "X(1)" space(0)
      temp-str.qntyBuh     column-label " Числится !--------------! ! Количество ! ":C14 format "->>>>>>>9.<<<" space(0)
      sym10                column-label " !-!:!:!:"                           format "X(1)" space(0)
      sum1-weightbuh-l     column-label " по данным !---------------! Масса !---------------!лигатурная":C15   format "->>>,>>>,>>9.99" space(0)
      sym11                column-label " !-! !-!:"                           format "X(1)" space(0)
      sum1-weightbuh-c     column-label " учета !---------------! !---------------! чистая ":C15   format "->>>,>>>,>>9.99" space(0)
      sym12                column-label ":!:!:!:!:"                           format "X(1)" space(0)
     HEADER
      Line format "X(183)" AT 1
      with width 232 down stream-io use-text NO-BOX.
FUNCTION f-wp-qnty returns character ( INPUT p-dec as decimal ) :
  define variable pr as character no-undo .
  run rep/wp-qnty.p ( input p-dec, output Pr ).
  if Pr = '' then do:
     Pr = 'Ноль'.
  end.
  RETURN ( Pr ) .
END FUNCTION.
do on error undo, return error
   :
   run get-report-num  in parParentProc ( output g#report-num ).
   run get-quest-print in parParentProc ( output g#quest-print ).
   FIND trn-doc WHERE recid(trn-doc) = rec_id NO-LOCK .
   assign
     tdoc-date = (if trn-doc.status_ <> 'факт':U then trn-doc.doc-date else trn-doc.fact-date)
     tdoc-code = trn-doc.doc-code
   .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'prt-glob':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'invprn0'  then v-prn0      = string( thbjattr_thbj-attr.property-value-logical) .
  end.
   if session:set-wait-state("compiler") then.
output STREAM Out-Stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
   run inv8xl-init in this-procedure .
   assign
     UndLine = fill("_", 230)
     Line    = fill("-", 230)
     LineBuf = fill("_", 240)
   .
   FIND This_Object  WHERE This_Object.obj-type = trn-doc.obj-type AND This_Object.obj-code = trn-doc.obj-code  NO-LOCK.
   FIND clients      WHERE clients.obj-type     = 'орг':U           AND clients.obj-code     = trn-doc.host-code NO-LOCK.
   run PrintTitul in this-procedure .
   FORM with frame invent-gold .
define variable v-account as integer init 0 no-undo .
define variable v-account-lavel as character no-undo .
define variable v-button-stop as logical no-undo .
define variable v-kol-spice as integer no-undo .
define variable v-kol-spice2 as integer no-undo .
define variable v-kol-spice3 as integer no-undo .
DEFINE VARIABLE StopProcessing AS LOGICAL NO-UNDO.
DEFINE BUTTON StopBtn AUTO-END-KEY
     LABEL "Стоп"
     SIZE 10 BY 1.
DEFINE VARIABLE RecordsDone AS INTEGER FORMAT ">,>>>,>>>,>>9":U INITIAL 0
     LABEL "Обработано записей"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE RecordsString AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString2 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString3 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.13 BY 4.46.
DEFINE FRAME InfoFrame
     StopBtn AT ROW 4.25 COL 21.75
     RecordsString AT ROW 1.21 COL 2 NO-LABEL
     RecordsString2 AT ROW 1.96 COL 2 NO-LABEL
     RecordsString3 AT ROW 2.58 COL 2 NO-LABEL
     RecordsDone AT ROW 3.42 COL 24.88 COLON-ALIGNED
     RECT-1 AT ROW 1 COL 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Процесс"
         DEFAULT-BUTTON StopBtn CANCEL-BUTTON StopBtn.
define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.
  mFramHandle = frame InfoFrame:handle.
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameRepError").
  end.
  mFrameView = not session:batch-mode and mFramHandle:visible.
  if mFrameView
  then do:
    ASSIGN
       FRAME InfoFrame:HIDDEN                           = TRUE
       StopBtn:sensitive IN FRAME InfoFrame             = TRUE.
  end.
ON CHOOSE OF StopBtn IN FRAME InfoFrame
DO:
  IF not StopProcessing THEN
    Message "Вы действительно хотите прервать" SKIP
            "процесс проверки?" view-as alert-box QUESTION BUTTONS yes-no
              UPDATE StopProcessing.
  IF StopProcessing THEN do:
     if mFrameView
     then do:
        HIDE FRAME InfoFrame.
     end.
  End.
END.
assign v-account = ( if integer( 25 ) = 0 then 100 else integer( 25 ) ).
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("ON mFrameView=" + string(mFrameView), "frameRepError").
  end.
  if not session:batch-mode then
  do:
    VIEW FRAME InfoFrame.
    mFrameView = true.
  end.
   v-button-stop = false .
      if mFrameView
      then do:
      if v-button-stop then view STOPBTN in frame InfoFrame.
                       else Hide STOPBTN in frame InfoFrame.
      end.
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
   counter1 = 0
.
for each buf_doc-line where buf_doc-line.doc-code = trn-doc.doc-code
                      no-lock
                      :
  find first buf_goods where buf_goods.prod-type = buf_doc-line.prod-type
                         and buf_goods.prod-code = buf_doc-line.prod-code
                         and buf_goods.artic     = buf_doc-line.artic
                       no-lock
                       no-error
                       .
  find first buf_doc-line-sum no-lock where
             buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
             buf_doc-line-sum.gds-code = buf_goods.gds-code    and
             buf_doc-line-sum.sum-type = 'bd':U     no-error.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-b-code
  ) no-error .
  if error-status :error then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Ошибка при определении бар-кода товара"     skip
            "Артикул товара:" buf_goods.artic            skip
            "Производитель:"  buf_goods.prod-type buf_goods.prod-code skip
            error-status :get-message( 1 ) skip
            error-status :get-message( 2 ) skip
            return-value                   skip( 1 )
    view-as alert-box error.
  end.
  find first buf_prod-bc where buf_prod-bc.b-code = v-b-code
                     no-lock
                     no-error
                     .
  assign
     Counter1 = Counter1 + 1
  .
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
  if v-prn0 = "no" then do:
    if  buf_doc-line-sum.fact-qnty = 0
    and buf_doc-line.fact-qnty     = 0
    then do:
         NEXT.
    end.
  end.
  create temp-str.
  assign temp-str.b-code          = if not available buf_prod-bc then string( v-b-code )
                                                                 else buf_prod-bc.b-str
         temp-str.artic           = buf_goods.artic
         temp-str.prod-type       = buf_goods.prod-type
         temp-str.prod-code       = buf_goods.prod-code
         temp-str.gds-name        = trim( buf_goods.gds-name )
         temp-str.EI              = buf_goods.sort
         temp-str.qntyBuh         = buf_doc-line-sum.fact-qnty
         temp-str.qntyFact        = temp-str.qntyBuh  + buf_doc-line.fact-qnty
         temp-str.WeightItemLigat = buf_goods.wt-base
  .
  assign
     temp-str.WeightItemClear = decimal(buf_goods.Destin)
  no-error.
  if error-status :error then do:
     assign
        temp-str.WeightItemClear = 0.0
     .
  end.
end.
   for each temp-str no-lock
                     :
       run print-line in this-procedure .
   end.
   display stream Out-Stream
         Line format "X(183)" AT 1 skip
         String("Итого"
                + sym6
                + String(PgQnty ,     "->>>>>>>>9.999"    )
                + sym7
                + String(PgWeight-l ,   "->>>>>>>>>9.999"    )
                + sym8
                + String(PgWeight-c ,   "->>>>>>>>>9.999"    )
                + sym9
                + String(PgQntyBuh,   "->>>>>>>>9.999"     )
                + sym10
                + String(PgWeightBuh-l, "->>>>>>>>>9.999" )
                + sym11
                + String(PgWeightBuh-c, "->>>>>>>>>9.999" )
                + sym12)  at 84 Format "x(100)"
                skip
         String("Всего по акту"
                + sym6
                + String(sum1-qntyFact ,     "->>>>>>>>9.999"    )
                + sym7
                + String(sum1-weightFact-l ,   "->>>>>>>>>9.999"    )
                + sym8
                + String(sum1-weightFact-c ,   "->>>>>>>>>9.999"    )
                + sym9
                + String(sum1-qntyBuh ,   "->>>>>>>>9.999"     )
                + sym10
                + String(sum1-weightBuh-l , "->>>>>>>>>9.999" )
                + sym11
                + String(sum1-weightBuh-c , "->>>>>>>>>9.999" )
                + sym12)  at 76 Format "x(108)"
                skip
         UndLine format "X(183)" AT 1 skip
         "Итого по странице : " skip
         "а) количество порядковых номеров "           AT 18 "(" STRING(PgNPP)    ")" f-wp-qnty (decimal(PgNPP)) FORMAT "x(90)"   SKIP
         "б) общее количество единиц фактически "      AT 18 "(" STRING(PgQnty)   ")" f-wp-qnty (decimal(PgQnty)) FORMAT "x(90)"   SKIP
         "в) масса драгоценных металлов фактически: "  AT 18                               SKIP
         "лигатурная "                                 AT 25 "(" STRING(PgWeight-l) ")" f-wp-qnty (decimal(PgWeight-l)) FORMAT "x(90)"  SKIP
         "чистая "                                     AT 25 "(" STRING(PgWeight-c) ")" f-wp-qnty (decimal(PgWeight-c)) FORMAT "x(90)"  SKIP
   with FRAME PageFrame2 width 232 NO-LABELS NO-BOX .
   DOWN stream Out-Stream 1 with FRAME PageFrame.
   page stream out-stream.
   run on-same-page in this-procedure (input 14) .
   run PrintPodval in this-procedure .
   output stream Out-Stream CLOSE .
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
   run inv8xl-close in this-procedure .
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 8 >= 8 then 2 else 0), 0, 0,
                                      OUTPUT g#log ).
end.
else do:
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + " " +
      string( session:temp-directory) +  "$" + string( g#report-num )
              ) .
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl" + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txl" + " " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl"
              ) .
end.
end.
procedure print-line :
  do on error undo, return error return-value :
define variable vss-include-info10 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
DO:
  assign Lines_Counter = Lines_Counter + 1  .
  if line-counter( out-stream ) + 9 > page-size( out-stream ) then do:
     display stream Out-Stream
        Line format "X(183)" AT 1
        String("Итого"
               + sym6
               + String(PgQnty ,     "->>>>>>>>9.999"    )
               + sym7
               + String(PgWeight-l ,   "->>>>>>>>>9.999"    )
               + sym8
               + String(PgWeight-c ,   "->>>>>>>>>9.999"    )
               + sym9
               + String(PgQntyBuh,   "->>>>>>>>9.999"     )
               + sym10
               + String(PgWeightBuh-l, "->>>>>>>>>9.999" )
               + sym11
               + String(PgWeightBuh-c, "->>>>>>>>>9.999" )
               + sym12)  at 84 Format "x(100)"
               skip
        "Итого по странице : " skip
        "а) количество порядковых номеров "           AT 18 "(" STRING(PgNPP)    ")" f-wp-qnty (decimal(PgNPP)) FORMAT "x(90)"   SKIP
        "б) общее количество единиц фактически "      AT 18 "(" STRING(PgQnty)   ")" f-wp-qnty (decimal(PgQnty)) FORMAT "x(90)"   SKIP
        "в) масса драгоценных металлов фактически: "  AT 18                               SKIP
        "лигатурная "                                 AT 25 "(" STRING(PgWeight-l) ")" f-wp-qnty (decimal(PgWeight-l)) FORMAT "x(90)"  SKIP
        "чистая "                                     AT 25 "(" STRING(PgWeight-c) ")" f-wp-qnty (decimal(PgWeight-c)) FORMAT "x(90)"  SKIP
     with FRAME PageFrame width 232 NO-LABELS NO-BOX .
     DOWN stream Out-Stream 1 with FRAME PageFrame.
     page stream out-stream.
  end.
  if line-counter( Out-Stream ) < Tmp_Counter then DO:
     assign
        PgNPP         = 0
        PgQnty        = 0
        PgWeight-l    = 0
        PgWeight-c    = 0
        PgQntyBuh     = 0
        PgWeightBuh-l = 0
        PgWeightBuh-c = 0
     .
  END.
  assign
    Tmp_Counter     = line-counter( Out-Stream )
    PgNPP           = PgNPP           + 1
    PgQnty          = PgQnty          + temp-str.qntyFact
    PgQntyBuh       = PgQntyBuh       + temp-str.qntyBuh
    PgWeight-l      = PgWeight-l      + temp-str.weightItemLigat * temp-str.qntyFact
    PgWeightBuh-l   = PgWeightBuh-l   + temp-str.weightItemLigat * temp-str.qntyBuh
    PgWeight-c      = PgWeight-c      + temp-str.weightItemClear * temp-str.qntyFact
    PgWeightBuh-c   = PgWeightBuh-c   + temp-str.weightItemClear * temp-str.qntyBuh
    num-ln          = num-ln          + 1
    sum1-qntyFact   = sum1-qntyFact   + temp-str.qntyFact
    sum1-qntyBuh    = sum1-qntyBuh    + temp-str.qntyBuh
    sum1-weightFact-l = sum1-weightFact-l + temp-str.weightItemLigat * temp-str.qntyFact
    sum1-weightBuh-l  = sum1-weightBuh-l  + temp-str.weightItemLigat * temp-str.qntyBuh
    sum1-weightFact-c = sum1-weightFact-c + temp-str.weightItemClear * temp-str.qntyFact
    sum1-weightBuh-c  = sum1-weightBuh-c  + temp-str.weightItemClear * temp-str.qntyBuh
  .
  if line-counter( Out-Stream ) + j > page-size( Out-Stream )
  then  PAGE STREAM Out-Stream.
  display stream Out-Stream
    sym1     num-ln
    sym2     temp-str.artic
    sym3     temp-str.gds-name
    sym4     temp-str.b-code
    sym5     temp-str.EI
    sym6     temp-str.qntyFact
    sym7     temp-str.weightItemLigat * temp-str.qntyFact @ sum1-weightFact-l
    sym8     temp-str.weightItemClear * temp-str.qntyFact @ sum1-weightFact-c
    sym9     temp-str.qntyBuh
    sym10     temp-str.weightItemLigat * temp-str.qntyBuh  @ sum1-weightBuh-l
    sym11     temp-str.weightItemClear * temp-str.qntyBuh  @ sum1-weightBuh-c
    sym12
  with FRAME invent-gold.
  DOWN stream Out-Stream 1 with FRAME invent-gold
  .
  run inv8xl-write-line-data in this-procedure (
      input num-ln
      , input temp-str.gds-name
      , input temp-str.artic
      , input temp-str.b-code
      , input temp-str.EI
      , input temp-str.QntyFact
      , input temp-str.WeightItemLigat * Qntyfact
      , input temp-str.WeightItemClear * Qntyfact
      , input temp-str.QntyBuh
      , input temp-str.WeightItemLigat * QntyBuh
      , input temp-str.WeightItemClear * QntyBuh
  ).
end.
  end.
end procedure.
procedure PrintTitul :
define variable v-organization  as character    no-undo.
define variable v-object        as character    no-undo.
do on error undo, return error return-value  :
    case clients.obj-type:
       when 'орг':U
       then do:
            FIND ub.firm WHERE ub.firm.firm-code = clients.obj-code NO-LOCK .
            if available ub.firm
            then do:
                assign
                    t-addres = ( if ub.firm.ind = 0 or ub.firm.ind = ? then "" else string( ub.firm.ind ) )
                    t-addres = t-addres
                        + ( if ub.firm.city = ? or trim(ub.firm.city) = ""
                            then ""
                            else ( (if t-addres = "" then "" else ", ") + trim( ub.firm.city ) )
                          )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 1, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                        + ( if  ub.firm.addres2 = ? or trim(ub.firm.addres2) = "" then "" else ( ", " + trim( ub.firm.addres2 ) ) )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 51, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 101, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                    t-phone = ub.firm.phone
                    t-inn   = ub.firm.inn
                    t-okpo  = ub.firm.okpo
                .
            end.
       end.
       when 'маг':U
       then do:
            FIND ub.shop WHERE ub.shop.obj-code = clients.obj-code NO-LOCK .
            if available ub.shop
            then do:
                assign
                    t-addres = ( if trim( shop.addres1 ) <> "" then ( trim( shop.addres1 ) ) else "" )
                            + ( if trim( shop.addres2 ) <> "" then ( ", " + trim( shop.addres2 ) ) else "" )
                    t-phone = shop.phone
                    t-inn = ""
                    t-okpo = ""
                .
            end.
       end.
       when 'скл':U
       then do:
            FIND ub.store WHERE ub.store.obj-code = clients.obj-code NO-LOCK .
            if available ub.store
            then do:
                assign
                    t-addres = ( if trim( ub.store.addres1 ) <> "" then ( trim( ub.store.addres1 ) ) else "" )
                            + ( if trim( ub.store.addres2 ) <> "" then ( ", " + trim( ub.store.addres2 ) ) else "" )
                    t-phone = ub.store.phone
                    t-inn = ""
                    t-okpo = ""
                .
            end.
       end.
       when 'чел':U
       then do:
            find ub.person where ub.person.psn-code = clients.obj-code no-lock .
            if available ub.person
            then do:
                assign
                    t-addres = ( if ub.person.ind <> 0 and ub.person.ind <> ? then string( ub.person.ind ) else "" )
                                + ( if  ub.person.city <> ? and trim(ub.person.city) <> "" then ( ", " + trim( ub.person.city ) ) else "" )
                                + ( if  ub.person.address <> ? and trim(ub.person.address) <> "" then ( ", " + trim( ub.person.address ) ) else "" )
                    t-phone = ub.person.phone1
                    t-inn = ub.person.inn
                    t-okpo = ub.person.okpo
                .
            end.
       end.
    end case.
   assign
       v-organization = string( "ИНН " + t-inn + " " + CAPS( clients.obj-name ) + " (" + string(clients.obj-code) + ")"
                             + t-addres + t-phone)
       v-object       = string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" )
   .
   run inv8xl-write-cell-data in this-procedure (
       input "h_organization":U
       , input v-organization
   ).
   run inv8xl-write-cell-data in this-procedure (
       input "h_object":U
       , input v-object
   ).
   run inv8xl-write-cell-data in this-procedure (
       input "h_docCode":U
       , input tdoc-code
   ).
   run inv8xl-write-cell-data in this-procedure (
       input "h_docDate":U
       , input string( tdoc-date, "99/99/9999")
   ).
   PUT STREAM Out-Stream
       "Унифицированная форма N ИНВ-8"             AT 138 skip
       "Утверждена постановлением Госкомстата РФ"  AT 138 skip
       "от 18 августа 1998 г. N 88"                AT 138 skip
       "+----------------+"                        AT 166 skip
       "|      Код       |"                        AT 166 skip
       "+----------------+"                        AT 166 skip
       "Форма по ОКУД|     0317008    |"           AT 153 skip
       space(5) v-organization format "X(140)" "+----------------+" AT 166 skip
       space(5) Line           format "X(140)" "по ОКПО" format "X(7)" AT 156 "|" AT 166 t-okpo format "X(16)" "|" AT 183 skip
       space(35) "организация" format "X(120)" "+----------------+" AT 166 skip
       space(5) v-object format "X(120)" "| " AT 166  "|" AT 183 skip
       space(5) Line format  "X(120)"  "+----------------+" AT 166 skip
       space(35) "структурное подразделение" format "x(85)" "Вид деятельности" AT 150 "| " AT 166 "|" AT 183 skip
       "+--------+----------------+"                         AT 157 skip
       "Основание для     приказ, постановление, распоряжение    |  номер |                |" AT 100 skip
       "проведения        -----------------------------------    +--------+----------------+" AT 100 skip
       "инвентаризации:           ненужное зачеркнуть            |  дата  |                |" AT 100 skip
       "+--------+----------------+"         AT 157 skip
       "Вид операции| инвентаризация |"      AT 154 skip
       "+----------------+"                  AT 166 skip
                         "+----------------+----------------+" AT 132 skip
       space(54) " АКТ " "| Номер документа|Дата составления|" AT 132 skip
       space(34) "инвентаризации драгоценных металлов и изделий из них"  "+----------------+----------------+" AT 132 skip
       "|" AT 132 STRING(tdoc-code,"X(14)")  AT 134 "|   " AT 149 STRING(tdoc-date, "99/99/9999") AT 153 "   |" AT 163 skip
       space(54) "РАСПИСКА" format "X(8)" "+----------------+----------------+" AT 132 skip
       space(15) "К началу проведения инвентаризации все расходные и  приходные  документы на драгоценные металлы и изделия из них сданы в бухгалтерию, и все " SKIP
       space(10) "драгоценные металлы и изделия из них, поступившие на мою (нашу)  ответственность, оприходованы, а выбывшие списаны в расход." SKIP(1)
       space(15) "Материально ответственное (ые) лицо (а): " format "X(41)" skip(1)
       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
       "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
       "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
       "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
       space(15) "Акт составлен  комиссией  о  том,   что   проведена   инвентаризаци драгоценных металлов и изделий из них по состоянию на <<       >> _________________        г." SKIP(1)
       space(15) "При инвентаризации установлено следующее:" SKIP
   .
   PAGE stream Out-Stream.
   PUT STREAM Out-Stream
   "+------------+--------------+-------------+"  AT 141 skip
   ":            :      Единица измерения     :"  AT 141 skip
   "+            +--------------+-------------+"  AT 141 skip
   ":            : наименование : код по ОКЕИ :"  AT 141 skip
   "+------------+--------------+-------------+"  AT 141 skip
   ": количество :              :             :"  AT 141 skip
   "+------------+--------------+-------------+"  AT 141 skip
   ":   масса    :    грамм     :     163     :"  AT 141 skip
   "+------------+--------------+-------------+"  AT 141 skip
   .
end.
end procedure.
procedure PrintPodval :
do on error undo, return error return-value  :
   run rep/wp-qnty.p ( num-ln , output PropisCount).
   if PropisCount = '' Then PropisCount = 'Ноль'.
   PAGE stream Out-Stream.
   HIDE stream Out-Stream FRAME BottomFrame .
   HIDE stream Out-Stream FRAME BottomFrame2 .
   run rep/wp-qnty.p ( sum1-qntyFact , output PropisQnty).
   if PropisQnty = ''
   Then PropisQnty = 'Ноль'.
   run rep/wp-qnty.p ( sum1-weightFact-l, output PropisSumall-l).
   if PropisQnty = ''
   Then PropisQnty = 'Ноль'.
   run rep/wp-qnty.p ( sum1-weightFact-c, output PropisSumall-c).
   if PropisQnty = ''
   Then PropisQnty = 'Ноль'.
   run inv8xl-write-cell-data in this-procedure (
         input "it_s_Num":U
       , input PropisCount
   ).
   run inv8xl-write-cell-data in this-procedure (
         input "it_s_qntyFact":U
       , input PropisQnty
   ).
   run inv8xl-write-cell-data in this-procedure (
         input "it_s_WeightFact":U
       , input PropisSumall-l
   ).
   run inv8xl-write-cell-data in this-procedure (
         input "it_qntyFact":U
       , input string( sum1-qntyFact )
   ).
   run inv8xl-write-cell-data in this-procedure (
         input "it_WeightFact":U
       , input string( sum1-weightFact-l )
   ).
   run inv8xl-write-cell-data in this-procedure (
         input "it_qntyBuh":U
       , input string( sum1-qntyBuh )
   ).
   run inv8xl-write-cell-data in this-procedure (
         input "it_WeightBuh":U
       , input string( sum1-weightBuh-l )
   ).
   PAGE STREAM Out-Stream.
   PUT STREAM Out-Stream
       "Итого по акту:" Skip
         "а) количество порядковых номеров: " + string( num-ln ) + " (" + PropisCount + ")"  format "x(179)"                         at 18 SKIP
         "б) общее количество единиц фактически: " + string( sum1-qntyFact ) + " (" + PropisQnty + ")"  format "x(179)"  at 18 SKIP
         "в) масса драгоценных металлов фактически: "  AT 18                               SKIP
         "лигатурная "                                 AT 25 "(" STRING(sum1-weightFact-l) ")" f-wp-qnty (decimal(sum1-weightFact-l)) FORMAT "x(90)"  SKIP
         "чистая "                                     AT 25 "(" STRING(sum1-weightFact-c) ")" f-wp-qnty (decimal(sum1-weightFact-c)) FORMAT "x(90)"  SKIP
       space(15) "Все подсчеты итогов по строкам, страницам и в целом по акту инвентаризации проверены." SKIP
       space(15) "Председатель комиссии: " SKIP(1)
       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
       "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
       space(15) "Члены комиссии: " format "X(25)" SKIP
       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
       "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
       "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
       "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
       space(15) "Все  ценности,  поименованные  в настоящем инвентаризационном акте с N ________ по N ___________,  комиссией проверены в натуре в моем (нашем)" SKIP
       space(10) "присутствии и внесены в акт, в связи с чем претензий к инвентаризационной комиссии не имею (не имеем). Ценности, перечисленные в акте, находя-" SKIP
       space(10) "тся на моем (нашем) ответственном хранении." SKIP
       space(15) "Материально ответственное (ые) лицо (а): "  SKIP(1)
       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
       "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
       "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
       "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
       space(15) "<<       >> _________________        г. "   SKIP
       space(15) "Указанные в настоящем акте данные и расчеты проверил" SKIP(1)
       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
       "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
       space(15) "<<       >> _________________        г. "
   .
end.
end procedure.
PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( Out-Stream ) then return .
  if line-counter( Out-Stream ) + p-line-number > page-size( Out-Stream ) then  page stream Out-Stream .
end procedure.
