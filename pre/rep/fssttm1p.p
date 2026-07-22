block-level on error undo, throw.
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define parameter buffer buf_fin-statement for ub.fin-statement.
define input parameter p-append as logical no-undo .
define input parameter p-is-last as logical no-undo .
define input-output parameter p-format as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fssttm1p.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/fssttm1p.p $":U .
define variable vss-description as character no-undo init "Печать банковской выписки типа стандартная выписка".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable g#report-num  as integer no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
define variable vss-include-info10 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
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
    field linenum     as integer
    field prndoccode as character
    field rpcschet   as character
    field debetsum    as character
    field creditsum   as character
    index pi is primary unique xl-line-id
.
define variable v-fssttxl1-current-data-row     as integer      no-undo.
define variable v-fssttxl1-cell-file-name       as character    no-undo.
define variable v-fssttxl1-data-file-name       as character    no-undo.
procedure fssttxl1-init :
    define buffer buf_temp_cell-data        for temp_cell-data.
do
for buf_temp_cell-data
on error undo, return error
:
    assign
        v-fssttxl1-current-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-fssttxl1-data-file-name
    ).
    output stream excel-line to value( v-fssttxl1-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-fssttxl1-cell-file-name
    ).
    output stream excel-cell to value( v-fssttxl1-cell-file-name ).
    if printrubl
    then do:
        run fssttxl1-write-cell-data in this-procedure (
              input "valutCode":U
            , input "0":U
        ).
    end.
    else do:
        run fssttxl1-write-cell-data in this-procedure (
              input "valutCode":U
            , input "1":U
        ).
    end.
    run fssttxl1-write-cell-data in this-procedure (
          input "columnList":U
        , input "linenum,prndoccode,rpcschet,debetsum,creditsum":U
    ).
    run fssttxl1-write-cell-data in this-procedure (
          input "columnType":U
        , input "I,S,S,D,D":U
    ).
    run fssttxl1-write-cell-data in this-procedure (
          input "columnAmount":U
        , input "5":U
    ).
    run fssttxl1-write-cell-data in this-procedure (
          input "subtotalList":U
        , input "":U
    ).
    run fssttxl1-write-cell-data in this-procedure (
          input "subtotalType":U
        , input "":U
    ).
    run fssttxl1-write-cell-data in this-procedure (
          input "subtotalAmount":U
        , input "0":U
    ).
end.
end procedure.
procedure fssttxl1-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/fssttm1.xlt":U.
        export "exe/t_97.bas":U.
        export v-fssttxl1-cell-file-name.
        export v-fssttxl1-data-file-name.
    output close.
end.
end procedure.
procedure fssttxl1-write-cell-data :
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
procedure fssttxl1-write-line-data :
define input parameter p-linenum       as integer          no-undo.
define input parameter p-prndoccode   as character        no-undo.
define input parameter p-rpcschet     as character        no-undo.
define input parameter p-debetsum      as character        no-undo.
define input parameter p-creditsum     as character        no-undo.
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
        v-fssttxl1-current-data-row = v-fssttxl1-current-data-row + 1
    .
    assign
    buf_temp_line-data.data-key     = "LD":U
    buf_temp_line-data.xl-line-id   = v-fssttxl1-current-data-row
    buf_temp_line-data.linenum      = p-linenum
    buf_temp_line-data.prndoccode   = p-prndoccode
    buf_temp_line-data.rpcschet      = p-rpcschet
    buf_temp_line-data.debetsum     = p-debetsum
    buf_temp_line-data.creditsum    = p-creditsum
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        chr(9)   buf_temp_line-data.linenum
        chr(9)   buf_temp_line-data.prndoccode
        chr(9)   buf_temp_line-data.rpcschet
        chr(9)   buf_temp_line-data.debetsum
        chr(9)   buf_temp_line-data.creditsum
        chr(10)
    .
end.
end procedure.
procedure fssttxl1-run-excel :
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
        v-template-file-name    = search( "exe/t12_97.xlt" )
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
define variable glog as logical no-undo .
define variable Line as character no-undo .
define variable date_string as character no-undo .
define variable num-lines as integer no-undo .
define variable v-fill as character no-undo init "_".
define variable v-dops as character no-undo .
define variable v-chernovik as character no-undo .
define variable v-vo as character no-undo .
define variable v-debet like ub.fin-doc.sum-doc no-undo .
define variable v-credit like ub.fin-doc.sum-doc no-undo .
define variable v-debet-ob like ub.fin-doc.sum-doc no-undo .
define variable v-credit-ob like ub.fin-doc.sum-doc no-undo .
define variable v-my-side as logical no-undo .
define variable v-debet-str as character no-undo .
define variable v-credit-str as character no-undo .
define variable v-c-schet like ub.fin-statement-line.rp-c-schet no-undo .
define variable v-from-fact-order like ub.fin-doc.fact-order no-undo .
define variable v-to-fact-order like ub.fin-doc.fact-order no-undo .
define variable v-last-doc-fact-date as date no-undo .
define variable v-last-doc-str as character no-undo .
define variable v-from-sum as decimal no-undo .
define variable v-to-sum-doc as decimal no-undo .
define buffer buf_currency for ub.currency.
define buffer buf_fin-statement-line for ub.fin-statement-line.
define buffer buf_fin-doc for ub.fin-doc.
define buffer last_fin-doc for ub.fin-doc.
DEFINE FRAME extract
v-vo COLUMN-LABEL "ВО" format "X(4)"
buf_fin-statement-line.prn-doc-code COLUMN-LABEL "Номер документа"
buf_fin-statement-line.rp-c-schet COLUMn-LABEL "Номер корр. счета"
v-debet COLUMN-LABEL "Дебет!(-)"
v-credit COLUMN-LABEL "Кредит!(+)"
HEADER  string( "Страница " ) format "X(9)" AT 105 PAGE-NUMBER(PrnLibStream) AT 115 FORMAT ">>9" SKIP
Line format "X(134)"
with width 136 down  stream-io use-text  .
do
on error undo, return error return-value
:
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reports_print':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  if not glog then return.
  Line = fill("-", 134).
  date_string = replace(cur-time-string-sec(), chr(47), ".":U) .
  find first buf_currency no-lock where
            buf_currency.curr-code = buf_fin-statement.curr-code no-error .
  if not available buf_currency then do:
    return error .
  end.
  run day-begin-fact-order (
      input  buf_fin-statement.start-date
     ,output v-from-fact-order) .
  run factord-end-day (
      input  buf_fin-statement.end-date
    ,output v-to-fact-order) .
  find last last_fin-doc no-lock where
            last_fin-doc.host-code = buf_Fin-statement.host-code
        AND last_fin-doc.status_ = 'факт':U
        AND last_fin-doc.fact-order < v-from-fact-order
        AND last_fin-doc.receiver-code-schet = buf_Fin-statement.code-schet no-error .
  if available last_fin-doc then do:
    assign
    v-last-doc-fact-date = last_fin-doc.fact-date
    .
  end.
  else do:
    assign
    v-last-doc-fact-date = 01/01/1990
    .
  end.
  find last last_fin-doc no-lock where
            last_fin-doc.host-code = buf_Fin-statement.host-code
        AND last_fin-doc.status_ = 'факт':U
        AND last_fin-doc.fact-order < v-from-fact-order
        AND last_fin-doc.payer-code-schet = buf_Fin-statement.code-schet no-error .
  if available last_fin-doc then do:
    assign
    v-last-doc-fact-date = max(last_fin-doc.fact-date, v-last-doc-fact-date)
    .
  end.
  else do:
    assign
    v-last-doc-fact-date = v-last-doc-fact-date
    .
  end.
  assign
  v-last-doc-str = if v-last-doc-fact-date = 01/01/1990
                  then "":U
                  else string(v-last-doc-fact-date, "99.99.9999":U)
  .
  assign
  v-from-sum = buf_fin-statement.end-sum-rubl
  .
  run get-report-num  in parParentProc(output g#report-num).
  output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
  output close.
  run fssttxl1-init in this-procedure.
 if p-format <> 1
 and p-format <> ?
 and p-append
 then do:
  assign
  p-format = ?
  .
  return.
 end.
  assign
  Line = fill("_":U, 198)
  .
  assign
  v-chernovik = if buf_fin-statement.status_ = 'новый':U
                then "Ч Е Р Н О В И К"
                else (fill( chr(32), 15))
  .
  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input 62
                                              ,input yes
                                              ,input p-append
                                              ).
  FORM with FRAME extract  .
  FORM HEADER
  Line format "X(134)" SKIP
  "Продолжение - на следующей странице" AT 30 SKIP
  with FRAME BottomFrame width 136 PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW  STREAM PrnLibStream FRAME BottomFrame .
  run fssttxl1-write-cell-data in this-procedure ( input "h_datetime":U       , input date_string  ).
  run fssttxl1-write-cell-data in this-procedure ( input "h_bankname":U       , input buf_fin-statement.bank-name  ).
  run fssttxl1-write-cell-data in this-procedure ( input "h_bik":U       , input buf_fin-statement.bik  ).
  run fssttxl1-write-cell-data in this-procedure ( input "h_corrschet":U       , input buf_fin-statement.c-schet  ).
  run fssttxl1-write-cell-data in this-procedure ( input "h_cliname":U       , input buf_fin-statement.cli-name  ).
  run fssttxl1-write-cell-data in this-procedure ( input "h_currcodename":U
                                                  ,input substitute("&1/&2 &3"
                                                                    ,buf_currency.curr-abbr
                                                                    ,buf_currency.okv-code
                                                                    ,buf_currency.curr-name )).
  run fssttxl1-write-cell-data in this-procedure ( input "h_rschet":U       , input buf_fin-statement.r-schet ).
  run fssttxl1-write-cell-data in this-procedure ( input "h_lastfindoc":U       , input v-last-doc-str ).
  run fssttxl1-write-cell-data in this-procedure ( input "h_startsumdoc":U
                                                   ,input substitute("Входящий остаток на начало дня &1: &2"
                                                                     ,string(buf_fin-statement.start-date, "99/99/9999")
                                                                     ,string( v-from-sum, "->>>,>>>,>>>,>>9.99"))).
  PUT  STREAM PrnLibStream unformatted
  line skip(1)
  SPACE(25) "ВЫПИСКА ИЗ ЛИЦЕВОГО СЧЕТА КЛИЕНТА"  space(25) date_string skip(1)
  buf_fin-statement.bank-name space(10) "БИК" chr(32) buf_fin-statement.bik space(10) "корр. счет" chr(32) buf_fin-statement.c-schet skip(1)
  "Наименование клиента: " buf_fin-statement.cli-name skip(1)
  "Валюта счета: "
  substitute("&1/&2 &3"
                  ,buf_currency.curr-abbr
                  ,buf_currency.okv-code
                  ,buf_currency.curr-name )
   skip(1)
  "Номер счeта: " buf_fin-statement.r-schet
  skip(1)
  line skip(1)
  "Дата последней операции: " v-last-doc-str skip(1)
   substitute("Входящий остаток на начало дня &1: &2"
            ,string(buf_fin-statement.start-date, "99/99/9999")
            , string(v-from-sum, "->>>,>>>,>>>,>>9.99")) skip(1)
  .
  for each buf_fin-statement-line no-lock where
          buf_fin-statement-line.host-code = buf_fin-statement.host-code
      AND buf_fin-statement-line.sttm-code = buf_fin-statement.sttm-code:
    CASE buf_fin-statement-line.fin-ext-doc-type:
      when 'рпп':U then do:
        if buf_fin-statement-line.fin-doc-code > 0 then do:
          find first buf_fin-doc no-lock where
                    buf_fin-doc.host-code = buf_fin-statement-line.host-code
                and buf_fin-doc.fin-doc-code = buf_fin-statement-line.fin-doc-code no-error.
        end.
        assign
        v-vo = string(buf_fin-statement-line.line-num)
        v-c-schet = (if available buf_fin-doc
                     then buf_fin-doc.receiver-c-schet
                     else buf_Fin-statement-line.rp-c-schet)
        v-debet = (if v-my-side
                   then (if available buf_fin-doc
                        then buf_fin-doc.sum-doc
                        else buf_fin-statement-line.sum-doc)
                   else 0)
        v-credit = (if v-my-side
                    then 0
                    else (if available buf_fin-doc
                          then buf_fin-doc.sum-doc
                          else buf_fin-statement-line.sum-doc)
                          )
        v-debet-str   = (if v-my-side
                         then (if available buf_fin-doc
                               then string(buf_fin-doc.sum-doc)
                               else string(buf_fin-statement-line.sum-doc)
                               )
                         else "":U)
        v-credit-str   = (if v-my-side
                          then "":U
                          else (if available buf_fin-doc
                                then string(buf_fin-doc.sum-doc)
                                else string(buf_fin-statement-line.sum-doc)
                               )
                                )
        v-debet-ob = v-debet-ob + v-debet
        v-credit-ob = v-credit-ob + v-credit
        .
      end.
      when 'ппп':U
      then do:
        if buf_fin-statement-line.fin-doc-code > 0 then do:
          find first buf_fin-doc no-lock where
                    buf_fin-doc.host-code = buf_fin-statement-line.host-code
                and buf_fin-doc.fin-doc-code = buf_fin-statement-line.fin-doc-code no-error.
        end.
        assign
        v-vo = string(buf_fin-statement-line.line-num)
        v-c-schet = (if available buf_fin-doc
                     then buf_fin-doc.payer-c-schet
                     else buf_Fin-statement-line.rp-c-schet)
        v-credit = (if v-my-side
                    then (if available buf_fin-doc
                          then buf_fin-doc.sum-doc
                          else buf_fin-statement-line.sum-doc)
                    else 0)
        v-debet = (if v-my-side
                   then 0
                   else (if available buf_fin-doc
                         then buf_fin-doc.sum-doc
                         else buf_fin-statement-line.sum-doc)
                         )
        v-credit-str   = (if v-my-side
                          then (if available buf_fin-doc
                                then string(buf_fin-doc.sum-doc)
                                else string(buf_fin-statement-line.sum-doc)
                                )
                          else "":U)
        v-debet-str = (if v-my-side
                       then "":U
                       else (if available buf_fin-doc
                             then string(buf_fin-doc.sum-doc)
                             else string(buf_fin-statement-line.sum-doc))
                             )
        v-credit-ob = v-credit-ob + v-credit
        v-debet-ob = v-debet-ob + v-debet
        .
      end.
    END CASE.
    run fssttxl1-write-line-data in this-procedure (
                                                    input v-vo
                                                    ,input buf_fin-statement-line.prn-doc-code
                                                    ,input v-c-schet
                                                    ,input string(v-debet, ">>>,>>>,>>>,>>9.99")
                                                    ,input string(v-credit, ">>>,>>>,>>>,>>9.99")
                                                   ).
    Display STREAM PrnLibStream
    v-vo
    buf_fin-statement-line.prn-doc-code
    v-c-schet @ buf_fin-statement-line.rp-c-schet
    v-debet
    v-credit
    with FRAME extract .
    DOWN STREAM PrnLibStream
    with frame extract .
  end.
  assign
  v-to-sum-doc = v-from-sum - v-debet-ob + v-credit-ob
  .
  run fssttxl1-write-cell-data in this-procedure ( input "it_debetsum":U
                                                 , input string(v-debet-ob, ">>>,>>>,>>>,>>9.99")) .
  run fssttxl1-write-cell-data in this-procedure ( input "it_creditsum":U
                                                 , input string(v-credit-ob, ">>>,>>>,>>>,>>9.99")).
  run fssttxl1-write-cell-data in this-procedure ( input "f_endsumdoc":U
                                                   ,input substitute("Исходящий остаток на конец дня &1: &2"
                                                                     ,string(buf_fin-statement.end-date, "99/99/9999")
                                                                     , string(v-to-sum-doc, "->>>,>>>,>>>,>>9.99"))).
  DOWN STREAM PrnLibStream 1
  with frame extract.
  display stream PrnLibstream
  "ИТОГО" @ buf_fin-statement-line.prn-doc-code
  "Обороты по дебету" @ v-debet
  "Обороты по кредиту" @ v-credit
  with FRAME extract .
  DOWN STREAM PrnLibStream 2
  with frame extract.
  display stream PrnLibstream
  "Сумма в валюте счета:" @ v-vo
  v-debet-ob @ v-debet
  v-credit-ob @ v-credit
  with FRAME extract .
  DOWN STREAM PrnLibStream 2
  with frame extract.
  Put stream Prnlibstream unformatted
  substitute("Исходящий остаток на конец дня &1: &2"
              ,string(buf_fin-statement.end-date, "99/99/9999")
              , string(v-to-sum-doc, "->>>,>>>,>>>,>>9.99"))
  skip(1)
  line skip.
  HIDE  STREAM PrnLibStream FRAME BottomFrame .
  HIDE  STREAM PrnLibStream FRAME extract.
  if p-append and not p-is-last then Page stream PrnLibStream .
  output  STREAM PrnLibStream CLOSE.
  assign
  p-format = 0
  .
  run fssttxl1-close in this-procedure .
  if not p-append
  then do:
      os-delete
          value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
      .
      os-rename
          value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
          value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
      .
      run prn-lib-prn-file in this-procedure (
            input parParentProc
          , input 0
      ).
      os-delete
          value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
      .
      os-delete
          value( v-fssttxl1-cell-file-name )
      .
  end.
end.
