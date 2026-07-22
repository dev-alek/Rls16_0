block-level on error undo, throw.
define temp-table tt-shift no-undo
  field shift-date like ub.shift-obj.shift-date
  field shift-num  like ub.shift-obj.shift-num
  field shift-name like ub.shift-obj.shift-name
.
define temp-table tt-pl-gds no-undo
  field pl-code like ub.place.pl-code
  field loc1 like ub.place.loc1
  field gds-code like ub.goods.gds-code
  field gds-name like ub.goods.gds-name
.
define input parameter parparentproc    as widget-handle  no-undo .
define input parameter table for tt-shift .
define input parameter table for tt-pl-gds .
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-shift-periods.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-shift-periods.p $":U .
define variable vss-description as character no-undo init "Отчет Контроль плотности НП".
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
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define temp-table tt-shift-pl-gds no-undo
  field num as integer
  field shift-date like ub.shift-period.shift-date
  field shift-num like ub.shift-period.shift-num
  field shift-name like ub.shift-obj.shift-name
  field pl-code like ub.shift-period.pl-code
  field loc1 like ub.place.loc1
  field gds-code like ub.shift-period.gds-code
  field gds-name like ub.goods.gds-name
  field num-periods as integer
.
define temp-table tt-result no-undo
  field shift-date like ub.shift-period.shift-date
  field shift-num like ub.shift-period.shift-num
  field pl-code like ub.shift-period.pl-code
  field gds-code like ub.shift-period.gds-code
  field period-num like ub.shift-period.period-num
  field period-name like ub.shift-period.period-name
  field sales-density15 like ub.shift-period.sales-density15
  field control-density like ub.shift-period.control-density
  field delta-density like ub.shift-period.delta-density
.
function fDec2Str returns character
  (input idec as decimal,
   input iformat as char)
:
  define variable vdecstr as character no-undo.
  if idec = ? then
     vdecstr = "".
  else
     vdecstr = trim(string(idec, iformat)).
  return vdecstr.
end function .
define stream sOutStr-html.
define buffer buf_shift-period for ub.shift-period .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
run fillTT .
run PrintRep .
procedure fillTT :
  define variable v-num as integer no-undo init 0 .
  for each tt-shift no-lock by tt-shift.shift-date by tt-shift.shift-num :
    for each buf_shift-period no-lock where buf_shift-period.shift-date = tt-shift.shift-date
                                        and buf_shift-period.shift-num = tt-shift.shift-num
    :
      find first tt-pl-gds no-lock where tt-pl-gds.pl-code = buf_shift-period.pl-code
                                     and tt-pl-gds.gds-code = buf_shift-period.gds-code
                                     no-error .
      if not available tt-pl-gds
      then next .
      find first tt-shift-pl-gds where tt-shift-pl-gds.shift-date = buf_shift-period.shift-date
                                   and tt-shift-pl-gds.shift-num  = buf_shift-period.shift-num
                                   and tt-shift-pl-gds.pl-code    = buf_shift-period.pl-code
                                   and tt-shift-pl-gds.gds-code   = buf_shift-period.gds-code
                                   no-error .
      if not available tt-shift-pl-gds
      then do :
        create tt-shift-pl-gds .
        assign
          v-num = v-num + 1
          tt-shift-pl-gds.num        = v-num
          tt-shift-pl-gds.shift-date = buf_shift-period.shift-date
          tt-shift-pl-gds.shift-num  = buf_shift-period.shift-num
          tt-shift-pl-gds.shift-name = tt-shift.shift-name
          tt-shift-pl-gds.pl-code    = buf_shift-period.pl-code
          tt-shift-pl-gds.loc1       = tt-pl-gds.loc1
          tt-shift-pl-gds.gds-code   = buf_shift-period.gds-code
          tt-shift-pl-gds.gds-name   = tt-pl-gds.gds-name
          tt-shift-pl-gds.num-periods = 0
        .
      end .
      assign tt-shift-pl-gds.num-periods = tt-shift-pl-gds.num-periods + 1 .
      create tt-result .
      assign
        tt-result.shift-date      = tt-shift-pl-gds.shift-date
        tt-result.shift-num       = tt-shift-pl-gds.shift-num
        tt-result.pl-code         = tt-shift-pl-gds.pl-code
        tt-result.gds-code        = tt-shift-pl-gds.gds-code
        tt-result.period-num      = buf_shift-period.period-num
        tt-result.period-name     = buf_shift-period.period-name
        tt-result.sales-density15 = buf_shift-period.sales-density15
        tt-result.control-density = buf_shift-period.control-density
        tt-result.delta-density   = buf_shift-period.delta-density
      .
    end .
  end .
end procedure .
procedure PrintRep :
  define variable vReportId     as character no-undo.
  define variable vFileNameRep  as character no-undo.
  define variable vStr          as character no-undo.
  define variable vI            as integer   no-undo.
  define variable v-period      as character no-undo .
  define variable v-firm-name   as character no-undo .
  define variable v-obj-name    as character no-undo .
  define variable v-print-date  as character no-undo .
  define variable v-today as date    no-undo .
  define variable v-time  as integer no-undo .
  define buffer buf_clients for ub.clients .
  do on error undo, return error return-value:
    run get-report-num(output vReportId).
    vFileNameRep = session:temp-directory + string(vReportId) + ".html".
    v-period = "Смены: " .
    for each tt-shift by tt-shift.shift-date by tt-shift.shift-num :
      v-period = v-period + string(tt-shift.shift-num) + " (" + tt-shift.shift-name + ") от " + string(tt-shift.shift-date, "99.99.9999") + ", " .
    end .
    v-period = trim(v-period, ", ") .
    find first buf_clients no-lock where buf_clients.obj-type = 'орг':U
                                     and buf_clients.obj-code = v-cntxt-host-code-obj
                                     no-error .
    if available buf_clients
    then do :
      v-firm-name = buf_clients.obj-name .
    end .
    find first buf_clients no-lock where buf_clients.obj-type = v-cntxt-obj-type
                                     and buf_clients.obj-code = v-cntxt-obj-code
                                     no-error .
    if available buf_clients
    then do :
      v-obj-name = "Выбор объекта: " + buf_clients.obj-name .
    end .
    run cur-time in this-procedure (
      output v-today
      , output v-time
      ).
    v-print-date = "Дата печати: " + string (v-today,"99.99.9999") + ", время: " + string(truncate (v-time / 3600, 0)) + ":" + string((v-time modulo 3600) / 60,"99")  + ":" + string((v-time modulo 3600) / 360,"99").
    output stream sOutStr-html to value(vFileNameRep) convert target 'UTF-8'.
    put stream sOutStr-html unformatted
"<!DOCTYPE HTML>" skip
' <html>' skip
'  <head>' skip
'   <meta charset="utf-8">' skip
'    <style type="text/css">' skip
'      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
'      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
'      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black;' + chr(125) skip
'   </style>' skip
'  </head>' skip
    .
    put stream sOutStr-html unformatted
      '<body>' skip
      '<TABLE name="1" outline_below="true" fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">' skip
      '<thead>' skip
      '<TR class="set_columns">' skip
        '<TD style="width:  70px;"></TD>' skip
        '<TD style="width:  70px;"></TD>' skip
        '<TD style="width:  70px;"></TD>' skip
        '<TD style="width:  90px;"></TD>' skip
        '<TD style="width:  80px;"></TD>' skip
        '<TD style="width: 180px;"></TD>' skip
        '<TD style="width: 140px;"></TD>' skip
        '<TD style="width: 140px;"></TD>' skip
        '<TD style="width: 140px;"></TD>' skip
      '</TR>' skip
    .
    put stream sOutStr-html unformatted
      '<TR>' skip
        '<TD colspan="9" style="font-weight: bold;">' + 'Отчёт Контроль плотности НП' + '</TD>'skip
      '</TR>' skip
      '<TR>' skip
        '<TD colspan="9" style="font-weight: bold;">' + v-period + '</TD>'skip
      '</TR>' skip
      '<TR>' skip
        '<TD colspan="9" style="font-weight: bold;">' + v-firm-name + '</TD>'skip
      '</TR>' skip
      '<TR>' skip
        '<TD colspan="9" style="font-weight: bold;">' + v-obj-name + '</TD>'skip
      '</TR>' skip
      '<TR>' skip
        '<TD colspan="9" style="font-weight: bold;">' + v-print-date + '</TD>'skip
      '</TR>' skip
      '<TR>' skip
        '<TD colspan="9">&nbsp;</TD>' skip
      '</TR>' skip
    .
    put stream sOutStr-html unformatted
      '<TR>' skip
        '<TD colspan="9" style="font-weight: bold;">' + 'Примечания к отчёту:' + '</TD>'skip
      '</TR>' skip
      '<TR>' skip
        '<TD colspan="9">' + 'В отчет выводятся отклонения плотности НП за период по каждому резервуару НП.' + '</TD>' skip
      '</TR>'skip
      '<TR>' skip
        '<TD colspan="9">' + 'Отклонение рассчитывается при сравнении значения P_реализ15 с P_контр.' + '</TD>' skip
      '</TR>'skip
      '<TR>' skip
        '<TD colspan="9">' + 'Расхождение значения по плотности НП не должно превышать 1,7 кг/м3 между значением P_реализ15 по сравнению с P_контр.' + '</TD>' skip
      '</TR>'skip
      '<TR>' skip
        '<TD colspan="9">' + 'Расхождение значения по плотности НП 1,7 кг/м3 для отчета конвертировано в 0,0017 г/см3.' + '</TD>' skip
      '</TR>'skip
      '<TR>' skip
        '<TD colspan="9">' + 'Чеки, сформированные во время прихода НП, не учитываются ни в одном из периодов.' + '</TD>' skip
      '</TR>'skip
      '<TR>' skip
        '<TD colspan="9">' + 'Для сообщающихся резервуаров НП в отчет выводится только «Главный» резервуар.' + '</TD>' skip
      '</TR>'skip
      '<TR>' skip
        '<TD colspan="9">' + 'При учете чеков реализации НП задним числом (включение в закрытую смену), данные этих чеков не оказывают влияние на расчет значений НП по периодам и формирование отчета.' + '</TD>' skip
      '</TR>'skip
      '<TR>' skip
        '<TD colspan="9">&nbsp;</TD>' skip
      '</TR>'skip
      '<TR>' skip
        '<TD colspan="9">' + 'P_реализ15 - плотность реализации НП, приведенная к 15 С, за период в представленной смене.' + '</TD>' skip
      '</TR>'skip
      '<TR>' skip
        '<TD colspan="9">' + 'P_контр - контрольная плотность НП в резервуаре за период в представленной смене.' + '</TD>' skip
      '</TR>'skip
      '<TR>' skip
        '<TD colspan="9">&nbsp;</TD>' skip
      '</TR>'skip
      '</thead>' skip
    .
    put stream sOutStr-html unformatted
      '<tbody>' skip
      '<TR>' skip
      '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">№ п/п</TH>' skip
      '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Дата смены</TH>' skip
      '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Порядок и номер смены</TH>' skip
      '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">№ Резервуара</TH>' skip
      '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Наименование топлива</TH>' skip
      '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Период в смене</TH>' skip
      '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Плотность реализации НП за период, г/см3 (приведенная к 15 С)</TH>' skip
      '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Контрольная плотность НП за период, г/см3 (приведенная к 15 С)</TH>' skip
      '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Отклонение по плотности НП за период, г/см3 (1.9 = 1.7 – 1.8)</TH>' skip
      '</TR>' skip
      '<TR >'skip
      '</TR>'skip
      '<TR >'skip
      '</TR>'skip
      '<TR >'skip
      '</TR>'skip
      '<TR >'skip
      '</TR>'skip
      '<TR >'skip
      '<TH style="text-align: center; font-weight:bold; ">1.1</TH>'   skip
      '<TH style="text-align: center; font-weight:bold; ">1.2</TH>'   skip
      '<TH style="text-align: center; font-weight:bold; ">1.3</TH>'   skip
      '<TH style="text-align: center; font-weight:bold; ">1.4</TH>'   skip
      '<TH style="text-align: center; font-weight:bold; ">1.5</TH>'   skip
      '<TH style="text-align: center; font-weight:bold; ">1.6</TH>'   skip
      '<TH style="text-align: center; font-weight:bold; ">1.7</TH>'   skip
      '<TH style="text-align: center; font-weight:bold; ">1.8</TH>'   skip
      '<TH style="text-align: center; font-weight:bold; ">1.9</TH>'   skip
      '</TR>'skip
    .
    for each tt-shift-pl-gds by tt-shift-pl-gds.num :
      put stream sOutStr-html unformatted
        '<TR>' skip
        '<TD text_wrap="true" rowspan="' + string(tt-shift-pl-gds.num-periods) + '" style="text-align: center;">' + string(tt-shift-pl-gds.num) + '</TD>' skip
        '<TD text_wrap="true" rowspan="' + string(tt-shift-pl-gds.num-periods) + '" style="text-align: center;">' + string(tt-shift-pl-gds.shift-date, "99.99.9999") + '</TD>' skip
        '<TD text_wrap="true" rowspan="' + string(tt-shift-pl-gds.num-periods) + '" style="text-align: center;">' + string(tt-shift-pl-gds.shift-num) + " (" + tt-shift-pl-gds.shift-name + ")" + '</TD>' skip
        '<TD text_wrap="true" rowspan="' + string(tt-shift-pl-gds.num-periods) + '" style="text-align: center;">' + string(tt-shift-pl-gds.loc1) + '</TD>' skip
        '<TD text_wrap="true" rowspan="' + string(tt-shift-pl-gds.num-periods) + '" style="text-align: center;">' + string(tt-shift-pl-gds.gds-name) + '</TD>' skip
      .
      for each tt-result where tt-result.shift-date = tt-shift-pl-gds.shift-date
                           and tt-result.shift-num  = tt-shift-pl-gds.shift-num
                           and tt-result.pl-code    = tt-shift-pl-gds.pl-code
                           and tt-result.gds-code   = tt-shift-pl-gds.gds-code
                           break by tt-result.pl-code by tt-result.gds-code
                           by tt-result.period-num
      :
        if not (first-of(tt-result.pl-code) and first-of(tt-result.gds-code))
        then do :
          put stream sOutStr-html unformatted
            '<TR>' skip
          .
        end .
        put stream sOutStr-html unformatted
          '<TD text_wrap="true" style="text-align: center;">' + string(tt-result.period-name) + '</TD>' skip
          '<TD num="#,####0.0000" val="' + fDec2Str(tt-result.sales-density15, "-9.9999") + '" text_wrap="true" style="text-align: center;">' + fDec2Str(tt-result.sales-density15, "-9.9999") + '</TD>' skip
          '<TD num="#,####0.0000" val="' + fDec2Str(tt-result.control-density, "-9.9999") + '" text_wrap="true" style="text-align: center;">' + fDec2Str(tt-result.control-density, "-9.9999") + '</TD>' skip
          '<TD num="#,####0.0000" val="' + fDec2Str(tt-result.delta-density, "-9.9999") + '" text_wrap="true" style="text-align: center; color: ' + (if abs(tt-result.delta-density) > 0.0017 then "red" else "black") + ';">' + fDec2Str(tt-result.delta-density, "-9.9999") + '</TD>' skip
          '</TR>' skip.
        .
      end .
    end .
    put stream sOutStr-html unformatted
      '</tbody>' skip
      '</table>' skip
      '</body>' skip
      '</html>' skip
    .
    output stream sOutStr-html close.
    run prn-lib-reportviewer-report-name in this-procedure (
    input THIS-PROCEDURE
    ,input vFileNameRep
    ).
  end .
end procedure .
procedure get-report-num :
  define output parameter p-report-num as integer no-undo .
  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.
end procedure .
