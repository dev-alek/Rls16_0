using ibs.th.gbl.sys.objsrv.
using ibs.th.bge.is_motp.*.
using ibs.th.str.utd.edoctype .
using ibs.th.str.marking.sts.*.
define input parameter  parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo .
define input parameter p-type as integer no-undo .
define input parameter i-Pack as  character  no-undo .
define input-output parameter p-connect as com-handle no-undo .
define output parameter p-rid-list as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список УПД".
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
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
define variable v-obj-active            as logical     no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  'active=request'
  ,output v-obj-active
  )  .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define variable mDebug as logical no-undo.
mDebug = session:debug-alert.
def var vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable mDiadocApi as component-handle no-undo.
define variable mDiadocConnection as component-handle no-undo.
define variable m-sys-key as character no-undo.
define variable marpar-type as character no-undo.
define variable mPublishHand as handle  no-undo.
define variable mFlaftest as logical no-undo.
   create "Diadoc.DiadocClient":U mDiadocApi no-error.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable mySeqUtd as int64 no-undo init ?.
if mDiadocApi eq ?
then do:
   if  log-manager:logfile-name ne ?
   then
      log-manager:write-message("Нет библиотеки Diadoc или не удалось создать объект Diadoc.DiadocClient", "EDOError").
end.
else do:
   if  log-manager:logfile-name ne ?
   then
      log-manager:write-message(substitute ("Версия библиотеки Diadoc &1" , mDiadocApi:GetFullVersion()) , "EDOError").
end.
def var vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info12 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info12, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info12, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info12, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info12, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info12 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info12, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info12 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info12, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info12, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info12, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info12, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info12, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info12, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info12 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info12 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info12, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info12, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info12, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info12 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info12 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info12, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info12, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
def var vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function getattrUtdex returns char
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-attr  then iExValue    else  utd-attr.attr-value.
end.
function getattrUtd returns char
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character ):
  return getattrUtdex(idb-num,idoc-id,iattrcode,?).
end.
function setattrUtd returns logical
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-attr
   then do:
      create utd-attr.
      assign
         utd-attr.db-num    = idb-num
         utd-attr.doc-id    = idoc-id
         utd-attr.attr-code = iattrcode
         utd-attr.attr-value = iattrval
      .
   end.
   else do:
      if utd-attr.attr-value ne iattrval
      then do:
         find current utd-attr exclusive-lock no-error.
         if available utd-attr
         then
            utd-attr.attr-value = iattrval.
      end.
   end.
   release utd-attr.
end.
function GetAttrUtdlinesEx returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-lines-attr  then iExValue    else  utd-lines-attr.attr-value.
end.
function GetAttrUtdlines returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character ):
   return GetAttrUtdlinesex (idb-num,idoc-id,ilinenum,iattrcode,?).
end.
function setattrUtdlines returns logical
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-lines-attr.
         assign
            utd-lines-attr.db-num    = idb-num
            utd-lines-attr.doc-id    = idoc-id
            utd-lines-attr.lineNum   = ilineNum
            utd-lines-attr.attr-code = iattrcode
            utd-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-lines-attr.attr-value ne iattrval
      then do:
         find current utd-lines-attr exclusive-lock no-error.
         if available utd-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-lines-attr.
            end.
            else do:
               utd-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-lines-attr.
end.
function GetAttrUtdMarkingLinesEx returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-marking-lines-attr  then iExValue    else  utd-marking-lines-attr.attr-value.
end.
function GetAttrUtdMarkingLines returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character ):
   return GetAttrUtdMarkingLinesEx (idb-num,idoc-id,ilinenum,imark,iattrcode,?).
end.
function setattrUtdMarkingLines returns logical
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-marking-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-marking-lines-attr.
         assign
            utd-marking-lines-attr.db-num     = idb-num
            utd-marking-lines-attr.doc-id     = idoc-id
            utd-marking-lines-attr.lineNum    = ilineNum
            utd-marking-lines-attr.mark       = imark
            utd-marking-lines-attr.attr-code  = iattrcode
            utd-marking-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-marking-lines-attr.attr-value ne iattrval
      then do:
         find current utd-marking-lines-attr exclusive-lock no-error.
         if available utd-marking-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-marking-lines-attr.
            end.
            else do:
               utd-marking-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-marking-lines-attr.
end.
def var vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
def var vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info17 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
define variable mMRCCode  as logical    no-undo.
define variable mTypeMark as character  no-undo.
function IS-NeedMark returns logical
( input ib-code as integer  ,
  input ib-str as character ):
   define buffer buf_prod-bc-attr for ub.prod-bc-attr.
   find first buf_prod-bc-attr where buf_prod-bc-attr.b-code eq ib-code
                                 and buf_prod-bc-attr.b-str  eq ib-str
                                 and buf_prod-bc-attr.attr-code eq 'mark':U
     no-lock no-error.
   return if available buf_prod-bc-attr then logical(buf_prod-bc-attr.attr-value) else no .
end.
function repTegforDm return char
(iDM as char ):
    define variable vTeglist as character no-undo init "01,02,11,13,17,21,8005,37".
    define variable vteg as character no-undo.
    define variable oDM as character no-undo.
    define variable vi as integer no-undo.
    oDM = iDm.
    do vi = 1 to num-entries(vTeglist):
       vTeg = entry(vi,vTeglist).
       oDM = replace(oDM,"(" + vTeg + ")",vTeg).
    end.
    return oDM.
end.
function repSpecSimbforDm return char
(iDM as char ):
    define variable oDM as character no-undo.
  run
    xmlchar-decode(iDM, output oDM).
  return repTegforDm (oDM).
end.
function CheckGtin return logical
(iGtin as char):
   define variable bar_code as character no-undo.
   define variable vGtin as logical no-undo init "yes".
   if length(iGtin) eq 14
   then do:
      bar_code = substr (iGtin, 1, length (iGtin) - 1).
      run str/chk-sum.p
       (input-output bar_code ) no-error .
      if iGtin ne  bar_code
      then
         vGtin = no.
   end.
   else
      vGtin = no.
   return vgtin.
end.
function repSpecSimbforXlm return char
(iDM as char ):
    iDM = replace(iDM,chr(29),"").
    return iDM.
end.
function getGtinByDM return char
(IDM as char):
   define variable VTXT as char no-undo.
   define variable vGtin as char no-undo.
   vTXt = IdM.
   vGtin = IDM.
   if    length(vtxt) > 14
   then do:
      if   vtxt begins "(01)"
             or vtxt begins "(02)"
      then
         vGtin = substring(vtxt,5,14).
      else if   (vtxt begins "01"
             or vtxt begins "02" )
             and (   (    substring(iDm,17,2) eq "21"
                      and length(vtxt) >= 21)
                  or substring(iDm,17,2) eq "37"
                  or substring(iDm,17,4) eq "(37)" )
      then do:
         vGtin = substring(vtxt,3,14).
         if not checkGtin(vGtin)
         then
            vGtin = substring(vtxt,1,14).
      end.
      else if     length(vtxt) eq 14 + 7 + 4 + 4
          or length(vtxt) eq 14 + 7 + 4
          or length(vtxt) eq 14 + 7
      then
         vGtin = substring(vtxt,1,14).
   end.
   if not checkGtin(vGtin)
   then
      vGtin = "".
   return vgtin.
end.
function getGdsCodeByGtin return int
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin  and prod-bc.bc-on no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.gds-code else ?.
end.
function getQntyCodeByGtin return decimal
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.cli-base-rate else ?.
end.
function getGdsCodeByDM return int
(iDm as char):
   define variable vGtin as char no-undo.
   define buffer prod-bc for ub.prod-bc.
   vGtin  = getGtinByDM (IDM ).
   return getGdsCodeByGtin (vGtin).
end.
function ChekTypeMarkByGds return logical
(iGds-code as integer ):
   define buffer goods-attr for ub.goods-attr.
   find first goods-attr where goods-attr.gds-code   = iGds-code
                           and goods-attr.attr-code  = 'mark-type':U
   no-lock no-error.
   if available goods-attr
   then do:
      mTypeMark = goods-attr.attr-value.
      return goods-attr.attr-value = objsrv:Env:Marking:Types:tabak:NameProp
        .
   end.
   else
      return no.
end.
function ChekTypeMarkByDm return logical
(iDM as char ):
   return ChekTypeMarkByGds(getGdsCodeByDM(idm)).
end.
function ChekTypeMarkByGtin return logical
(iGtin as char ):
   return ChekTypeMarkByGds(getGdsCodeByGtin(iGtin)).
end.
function GetNextElement return character
  (input iAllTeg        as logical
  ,output oteg          as character
  ,output otegval       as character
  ,input-output pstr    as character
   ):
     define variable vlistElem   as character no-undo init "00,01,02,21,17,11,13,(01),(02),(21),(17),(11),(13)".
     define variable vlistleng   as character no-undo init "27,14,14,13,06,06,06,0014,0014,0013,0006,0006,0006".
     define variable vlistElemDop   as character no-undo init ",37,(37),(8005),8005,93,(93)".
     define variable vlistlengDop   as character no-undo init ",08,0008,000006,0006,04,0004".
     define variable vTeg as character no-undo.
     define variable vLength as integer no-undo.
     define variable vi as integer no-undo.
     define variable vj as integer no-undo.
     define buffer code for ub.code.
     find first code where Code.parent eq "MarkType"
                       and Code.CodeValue   eq mTypeMark
                       no-lock no-error.
     if     available code
        and Code.misc1 ne ""
        and Code.misc1 ne ?
     then do:
        integer (Code.misc1) no-error.
        if not error-status:error
        then
          entry (4,vlistleng) = Code.misc1.
     end.
     if iAllTeg
     then
        assign
           vlistElem     = vlistElem    + vlistElemDop
           vlistleng     = vlistleng    + vlistlengDop
        .
     else if mMRCCode
     then
        assign
           vlistElem     = vlistElem    + ",(8005),8005"
           vlistleng     = vlistleng    + ",000006,0006"
        .
    block-elem:
    do vi = 1 to num-entries(vlistElem):
       vTeg = entry(vi,vlistElem).
       if pstr begins vTeg
       then do:
          if    vTeg eq "21"
          then
             vLength = index(pstr,chr(29)) - 2 no-error.
          if vLength  <= 0
          then
             vLength = int(entry(vi,vlistleng)).
          otegval = substring (pstr,length(vteg) + 1, vLength).
          oteg = replace(replace(vteg,")",""),"(","").
          vTeg = vteg + otegval.
          otegval = replace(otegval,chr(29),"").
          oteg = replace(replace(oteg,")",""),"(","").
          pstr = substring (pstr,length(vTeg)+ 1).
          vTeg = replace(vTeg,chr(29),"").
          leave block-elem.
       end.
       else
          vTeg = "".
    end.
    return vteg.
end.
function GetCodeIdent return character
(iDm as char):
   define variable Velement   as character no-undo init "first".
   define variable oCodeIdent as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define variable vGtin as character no-undo.
   define buffer marking for ub.marking.
   for first marking no-lock where
             marking.mark eq iDm
         and marking.unit-ext = "LEVEL2"
   :
     return iDm.
   end.
   vGtin  = getGtinByDM (iDm ).
   ChekTypeMarkByDm(idm).
   if iDm begins 'tech_':U
   then
      oCodeIdent = iDm.
   else if length(iDm) < 21
   then do:
      find first marking where marking.mark eq idm
      no-lock no-error.
      oCodeIdent = if available marking then marking.mark else  ?.
   end.
   else if     length(iDm) eq 29
      and not iDm begins "01"
      and not iDm begins "02"
   then
      oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21 ).
   else  if     length(iDm) >= 24
            and (  iDm begins "01"
                or iDm begins "02")
            and  substring(iDm,17,2) ne "21"
   then do:
      if checkGtin(substring(iDm,1,14)) and ( (length(idm) eq 25 and substring(iDm,22,1) eq "A")
                                                or (length(idm) eq 29 and substring(iDm,22,1) eq "A"))
      then
         oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21).
      else
         oCodeIdent = iDM.
   end.
   else  if     (   length(iDm) eq 25
                 or length(iDm) eq 21)
            and (not iDm begins "01"
            and  not iDm begins "02")
   then
      oCodeIdent = substring(iDm,1,21).
   else if vGtin = substring(iDm,1,14) and checkGtin(substring(iDm,1,14)) and ( length(idm) eq 21 or (length(idm) eq 25 and substring(iDm,22,1) eq "A"))
   then
      oCodeIdent = substring(iDm,1,21).
   else do while Velement ne "" and idm ne "":
      Velement = GetNextElement(no,output vteg, output vtegval, input-output idm).
      oCodeIdent = oCodeIdent + Velement.
   end.
   return oCodeIdent.
end.
function GetTegCod return character
(icodeIdent as char, iTeg as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo init ?.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if     ((length(icodeIdent) eq 21
      and not icodeIdent begins "01"
      and not icodeIdent begins "02")
      or
          ( length(icodeIdent) eq 25
            and not icodeIdent begins "01"
            and not icodeIdent begins "02"))
   then do:
      if iTeg eq "01" or iTeg eq "02"
      then
         oTeg = substring(icodeIdent,1,21).
      else  if  iTeg eq "21"
      then
         oTeg = substring(icodeIdent,15,7).
   end.
   else do:
      ChekTypeMarkByDm(icodeIdent).
      block-teg:
         do while Velement ne "" and icodeIdent ne "":
         Velement = GetNextElement(yes,output vteg, output vtegval, input-output icodeIdent).
         if    Velement begins iTeg
            or Velement begins "(" + iTeg + ")"
         then do:
            oTeg = vtegval.
            leave block-teg.
         end.
      end.
   end.
   return oTeg.
end.
function isOAD return logical
(icodeIdent as character):
   return length(icodeIdent) > 18 and GetTegCod(icodeIdent,"37") ne ? and GetTegCod(icodeIdent,"02") ne ?.
end.
function isMark return logical
(icodeIdent as character):
   define buffer buf_marking for ub.marking.
   return can-find(first buf_marking where buf_marking.mark begins icodeIdent) or
          (length(icodeIdent) > 20 and not isOAD(icodeIdent)).
end.
function addBracketForCode return character
(icodeIdent as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define buffer marking for ub.marking.
   find first marking no-lock where
              marking.mark begins icodeIdent no-error.
   if    not ChekTypeMarkByDm(icodeIdent)
      or length(icodeIdent) le 24
      or (avail marking and marking.unit-ext = "LEVEL2")
   then
      oTeg = icodeIdent.
   else do:
      if (  icodeIdent begins "01"
         or icodeIdent begins "02"
         ) and CheckGtin(substring (icodeIdent,3,14))
         and substring (icodeIdent,17,2) eq "21"
      then do:
         mMRCCode = yes.
         ChekTypeMarkByDm(icodeIdent).
         block-teg:
         do while Velement ne "" and icodeIdent ne "":
            Velement = GetNextElement(no,output vteg, output vtegval, input-output icodeIdent).
            if vteg ne ""
            then
               oTeg = oTeg + "(" + vteg + ")" + vtegval .
         end.
         mMRCCode = no.
      end.
      else do:
         oTeg = icodeIdent.
      end.
   end.
   return oTeg.
end.
function getlevelByCodId return int
(iCode as char):
   define variable vLength as int no-undo.
   define variable vLevel  as int no-undo.
   if not ChekTypeMarkByDM (icode) then return ?.
   vLength = length(iCode).
   if    vLength eq 18
      or vLength eq 20
   then
      Vlevel = 4.
   else if vLength eq 21
   then
      Vlevel = 1.
   else if vLength eq 25
   then do:
      if  iCode begins "01"
      then
         Vlevel = 3.
      else
         Vlevel = 1.
   end.
   else if     vLength >= 26
           and vLength <= 46
   then do:
      if    substring(iCode,17,2) eq "11"
         or substring(iCode,17,2) eq "13"
         or (    substring(iCode,17,2) eq "21"
             and vLength >= 33
             and substring(iCode,26,4) ne "8005")
      then
         Vlevel = 4.
      else if    vLength eq 31
              or vLength eq 38
              or vLength eq 39
              or vLength eq 45
      then
         Vlevel = 1.
      else if    vLength eq 35
              or vLength eq 43
      then
         Vlevel = 3.
      else
         Vlevel = ?.
   end.
   else
      Vlevel = ?.
   return Vlevel.
end.
function getLevelMotpBycodid return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 6
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByLevelMotp return character
(iUnit as char):
   define variable vLevel as integer no-undo.
   define variable vListMOTP    as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   define variable vListutd as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = lookup(iUnit,vListMOTP).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vListutd).
end.
function getLevelMotpByDM return character
(iDm as char):
   return getLevelMotpByCodId(GetCodeIdent(iDm)).
end.
function getLevelUTDByCodId return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByDM return character
(iDm as char):
   return getLevelUTDByCodId(GetCodeIdent(iDm)).
end.
define variable mNotMarkQnty as logical no-undo.
function getQntyUTDByCodId return decimal
(iDM as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "1,5,10,500".
   define variable vGtin as character no-undo.
   define variable vqnty as decimal no-undo init ?.
   vqnty = dec(GetTegCod(iDM,"37")) no-error.
   if vqnty eq ?
   then do:
      if not mNotMarkQnty
      then do:
         define buffer marking for ub.marking.
         define variable vCodident as character no-undo.
         vCodident = GetCodeIdent(idm).
         find first marking where marking.mark begins vCodident no-lock no-error.
         if     available marking
            and marking.box-qnty ne ?
         then
            return marking.box-qnty.
      end.
      vGtin = getGtinByDm(iDM).
      if ChekTypeMarkByGtin (vGtin)
      then do:
         vLevel = getlevelByCodId(iDM).
         if     vLevel >= 1
            and vLevel <= 4
         then
            vqnty = int(entry(vlevel,vList)).
      end.
      else
         vqnty = getQntyCodeByGtin(vgtin).
   end.
   return vqnty.
end.
function getQntyUTDByDM return decimal
(iDm as char):
   define variable vDM as character no-undo.
   if     length (iDm) ne 25
      and length (iDm) ne 29
      and substring (iDm,length (iDm) - 6 + 1, 2 ) eq "93"
   then
      vDM = substring (iDm,1,length (iDm) - 6 ).
   else
      vDM = substring (iDm,1,length (iDm) - 4 ).
   return getQntyUTDByCodId(vDM).
end.
function getMRC4 return decimal
(iMRC as char):
   define variable oMrc     as decimal no-undo init ?.
   define variable vAlphabet as character no-undo init "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!~"%&'*+-./_,:;=<>?".
   define variable vi       as integer no-undo.
   define variable vfound   as integer no-undo.
   define variable vposStart   as integer no-undo.
   do:
   OMRc = 0.
   do vi = 1 to 4:
      define variable vsimb as character no-undo.
      vsimb = substring(iMRC,vi,1).
      vposStart = if keycode("Z") < keycode(vsimb) then 27 else 1.
      vfound = index(vAlphabet,vsimb,vposStart) - 1.
      if vfound > 0
      then
         OMRc = OMRc + exp (80,(4 - vi) ) * vfound  .
      end.
      OMRc = OMRc / 100.
   end.
   return OMRc.
end.
function getMRCByDM return decimal
(iDm as char):
   define variable vMRC     as character no-undo.
   define variable oMrc     as decimal no-undo init ?.
   define variable Velement as character no-undo init "empty".
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if    length(idm) eq 14 + 7 + 4 + 4
      or length(idm) eq 14 + 7 + 4
   then do:
      vMRC = substring(idm,22,4).
      omrc = getMRC4(vMRC).
   end.
   else do:
       ChekTypeMarkByDm(iDm).
       block-mrc:
       do while Velement ne "" and idm ne "":
          Velement = GetNextElement(yes,output vteg, output vtegval, input-output idm).
          if Velement begins "8005"
          then do:
             vMRC = substring(Velement,5,6).
             leave block-mrc.
          end.
          else if Velement begins "(8005)"
          then do:
             vMRC = substring(Velement,7,6).
             leave block-mrc.
          end.
       end.
       if vMRC ne ""
       then
          OMRc = dec(vmrc) / 100 no-error.
   end.
   return OMRc.
end.
function MoveDate return Date
(idate as date,
 iMonth as int64):
   define variable vMonth   as int64 no-undo.
   define variable vYear    as int64 no-undo.
   define variable vDateNew as date  no-undo.
    define variable vDay     as int64 no-undo.
    vMonth = month(iDate) + iMonth.
    vYear =  year(iDate).
    if vMonth <= 0
    then assign
       vMonth = vMonth + 12
        vYear  = vYear - 1
    .
    else if vMonth > 12
    then assign
       vMonth = vMonth - 12
        vYear  = vYear + 1
    .
    vDateNew = date(vMonth,day(iDate),vYear) no-error.
    do while error-status:error eq yes:
       VDay = vDay + 1.
       vDateNew = date(vMonth,day(iDate) - vDay,vYear) no-error.
    end.
    if VDay > 0
    then
       vDateNew + 1.
    return vDateNew.
end.
procedure checkEMRC:
define input  parameter iDm as character no-undo.
define output parameter vok as logical   no-undo init yes.
   define variable v-value-emrc as character no-undo.
   define variable v-type-emrc  as character no-undo.
   define variable vDateIso     as character no-undo.
   define variable vMRC         as decimal no-undo.
   define variable vqnty        as decimal no-undo.
   define variable vPrice       as decimal no-undo.
   define variable vparent      as character no-undo.
   define variable vgds-code    as integer no-undo.
   define buffer code for ub.code.
   vMRC = getMRCByDM(iDm).
   if vMRC > 0
   then do:
      vgds-code = getGdsCodeByDM(iDm).
      vqnty     = getQntyUTDByDM(iDm).
            if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
         (
          input   vgds-code
         ,input   'emrc-type':U
         ,output   v-value-emrc
         ,output   v-type-emrc
       ) no-error.
       if     v-value-emrc ne ""
          and v-value-emrc ne ?
       then do:
          vDateIso = iso-date(today).
          vPrice = vMRC / vqnty.
          vparent ="emc" + chr(4) + v-value-emrc.
          find last code where Code.parent      eq vparent
                           and Code.code        le vDateIso
                           and code.status_  eq 0
          no-lock no-error.
          if not available code or ( vPrice  >= dec(Code.CodeValue))
          then
             vOk = true .
          else do:
              define variable vText      as character no-undo.
              define variable vDate      as date no-undo.
              define variable vDateLast  as character no-undo.
              define variable vDateFirst as character no-undo.
              define variable vDate3     as date no-undo.
              vdate = date(code.misc1).
              vDateLast = code.misc1.
              vDate3 = MoveDate(today, - 3 ).
              vText =  substitute ("ТОВАР ИМЕЕТ ОГРАНИЧЕННЫЙ СРОК РЕАЛИЗАЦИИ. Если товар произведен после &2, то его приемка и продажа запрещена.",
                                   string(vDate3  , "99/99/9999"),
                                   string(vDate   , "99/99/9999")
                                   ).
              vdateIso = iso-date(vdate3).
              find last code  where Code.parent      eq vparent
                                and Code.code        le vDateIso
                                and code.status_  eq 0 no-lock no-error.
              if available code
              then
                 vDateIso = code.code.
              vDateFirst = vDateIso.
              vDateLast = iso-date(vdate).
              define variable vGood as logical no-undo.
              define variable vDateSale as date no-undo.
              define buffer bcode for code.
              for last code where Code.parent   eq vparent
                              and code.status_  eq 0
                              and code.code     < vDateLast
                              and code.code     >= vDateFirst
              no-lock:
                 find first bcode where bCode.parent   eq vparent
                                    and bcode.status_  eq 0
                                    and bcode.code     > code.code no-lock no-error.
                 if available bcode
                 then do:
                    if vPrice < dec(Code.CodeValue)
                    then
                       vText = vtext + substitute ("&1Если товар произведен с &2 до &3, ТО ЕГО ПРИЕМКА И ПРОДАЖА ЗАПРЕЩЕНА",
                                                  chr(10),
                                                  string(    date( code.misc1)       ,"99/99/9999"),
                                                  string(    date(bcode.misc1)       ,"99/99/9999")
                                                  ).
                    else do:
                       vGood = yes.
                       vDateSale = MoveDate(date(bcode.misc1), 3) - 1.
                       vText = vtext + substitute ("&1Если товар произведен до &3, то продажа разрешена до &4.~Осталось &5 дней.",
                                                  chr(10),
                                                  string(    date( code.misc1)         ,"99/99/9999"),
                                                  string(    date(bcode.misc1)         ,"99/99/9999"),
                                                  string(         vDateSale            ,"99/99/9999"),
                                                  string(vDateSale - today)
                                                  ).
                    end.
                 end.
              end.
              if vgood
              then do:
                 define variable choice as integer no-undo .
                 run gbl/d-askw.w (input "Уточнение"
                        ,input  vText
                        ,input "|"
                        ,input "Принять|Вернуть"
                        ,input "Принять данный товар|Вернуть товар постащику"
                        ,input 1
                        ,input 2
                        ,output choice) no-error.
                 vok = choice eq 1.
              end.
              else
                 vok =false.
          end.
       end.
   end.
end.
function addGs2Mark return character
(iMark as char):
   define variable vDM   as character no-undo.
   define variable vIdx  as integer   no-undo.
   if index(iMark,chr(29),1) > 0
   then return iMark.
   if substring(iMark,26,4) = "8005" then
   do:
     vIdx = index(iMark,"93",26 + 4 + 5).
     if vIdx > 1 then do:
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,25),
                        substring(iMark,26,vIdx - 25 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       vIdx = index(vDm,"240",vIdx + 4).
       if vIdx > 0 then
       do:
         vDM = substitute("&1&3&2",
                          substring(vDm,1,vIdx - 1),
                          substring(vDm,vIdx),
                          chr(29)) no-error.
       end.
     end.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,25),
                        substring(iMark,26),
                        chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "91" then
   do:
     vIdx = index(iMark,"92",32).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,31),
                        substring(iMark,32,vIdx - 31 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,31),
                        substring(iMark,32),
                        chr(29)) no-error.
   end.
   else if substring(iMark,39,2) = "91" then
   do:
     vIdx = index(iMark,"92",38).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,38),
                        substring(iMark,39,vIdx - 38 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,38),
                        substring(iMark,39),
                        chr(29)) no-error.
   end.
   else if substring(iMark,25,2) = "93" then
   do:
     vIdx = index(iMark,"92",25).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vIdx = index(iMark,"3103",25).
       if vIdx > 0 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       else
         vDM = substitute("&1&3&2",
                          substring(iMark,1,24),
                          substring(iMark,25),
                          chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "93" then
   do:
     vDM = substitute("&1&3&2",
           substring(iMark,1,31),
           substring(iMark,32),
           chr(29)) no-error.
   end.
   return if vDM <> "" then vDm else iMark.
end.
def var vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function AddUtdErrForTab returns logical
(idb-num         as integer ,
 idoc-id         as integer ,
 iTab            as character,
 iObj            as handle ,
 iCheckType      as character,
 iCodeErr        as character,
 iCheckObj       as character ):
   define buffer utd-err for utd-err.
   define buffer utd for utd.
   find first utd where utd.db-num     eq idb-num
                    and utd.doc-id     eq idoc-id
                    and utd.Direction  eq 'Outbound'
   no-lock no-error.
   if available utd
   then
      return no.
   define variable vRecKey as character no-undo.
         run gen-key-rec (input iTab,
                          input  iObj,
                          output vRecKey).
   find first utd-err where utd-err.db-num     eq idb-num
                        and utd-err.doc-id     eq idoc-id
                        and utd-err.CheckType  eq iCheckType
                        and utd-err.CodeErr    eq iCodeErr
                        and utd-err.CheckObj   eq iCheckObj
   exclusive-lock no-error.
   if not available utd-err
   then do:
      create utd-err.
      assign
         utd-err.db-num         = idb-num
         utd-err.doc-id         = idoc-id
         utd-err.CheckType      = iCheckType
         utd-err.CodeErr        = iCodeErr
         utd-err.CheckObj       = if iCheckObj eq ? then "?" else iCheckObj
         utd-err.reckey         = vRecKey
         utd-err.qnty           = 1
      .
   end.
   else
      utd-err.qnty = utd-err.qnty + 1.
   return utd-err.qnty eq 1.
end.
function AddUtdErr returns logical
(idb-num         as integer ,
 idoc-id         as integer ,
 iObj            as handle ,
 iCheckType      as character,
 iCodeErr        as character,
 iCheckObj       as character ):
   AddUtdErrForTab
      (idb-num,
       idoc-id,
       iObj:table,
       iObj,
       iCheckType,
       iCodeErr,
       iCheckObj).
end.
function ClearUtdErrTypeCode returns logical
(idb-num         as integer,
 idoc-id         as integer ,
 iCheckType      as character,
 iCodeErr        as character
 ):
   define buffer utd-err for utd-err.
   if    iCheckType eq "*"
      or iCheckType eq ?
   then do:
      if     iCodeErr ne ?
         and iCodeErr ne "*"
      then
         message "Задан код ошибки " iCodeErr " для удаления, но не задан тип"
         view-as alert-box.
      else
      for each utd-err where utd-err.db-num  eq idb-num
                         and utd-err.doc-id  eq idoc-id
      exclusive-lock:
         delete utd-err.
      end.
   end.
   else do:
      if    iCodeErr eq ?
         or iCodeErr eq "*"
      then do:
         for each utd-err where utd-err.db-num     eq idb-num
                            and utd-err.doc-id     eq idoc-id
                            and utd-err.CheckType  eq iCheckType
         exclusive-lock:
            delete utd-err.
         end.
      end.
      else do:
         for each utd-err where utd-err.db-num     eq idb-num
                            and utd-err.doc-id     eq idoc-id
                            and utd-err.CheckType  eq iCheckType
                            and ub.utd-err.CodeErr eq iCodeErr
         exclusive-lock:
            delete utd-err.
         end.
      end.
   end.
end.
function ClearUtdErr returns logical
(idb-num         as integer,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   ClearUtdErrTypeCode(idb-num,idoc-id,iCheckType,?).
end.
function GetMesError returns character
(itxt as character,
 iobj as character ):
 define variable vi as integer no-undo.
 do vi = num-entries(iobj ,chr(4) ) to 1 by -1 :
    itxt = replace(itxt,"&" + string(vi),entry(vi,iobj,chr(4))).
 end.
 return itxt.
end.
function GetTextErrorType returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character,
 iType      as character  ):
   define buffer code    for code.
   define variable vError as character no-undo.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if available code
   then do:
      define variable vType as integer no-undo.
      if code.misc3 eq "error"
      then
         vType = 0.
      else if code.misc3 eq "warning"
      then
         vType = 1.
      else if code.misc3 eq "Hiden"
      then
         vType = 2.
      else
         vtype = int(code.misc3) no-error.
      case itype:
         when "error"
         then do:
            if vtype eq 0
            then
               vError = GetMesError(Code.CodeValue,iChechObj).
         end.
         when "warning"
         then do:
            if vtype <= 1
            then
               vError = GetMesError(Code.CodeValue,iChechObj).
         end.
         otherwise do:
            vError = GetMesError(Code.CodeValue,iChechObj).
         end.
      end.
   end.
   else
      vError =  iCodeErr + ":" + replace (iChechObj,chr(4),"|").
   return vError.
end.
function GetTypeError returns integer
(iCheckType as character,
 iCodeErr   as character):
   define buffer code    for code.
   define variable vType as integer no-undo.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if     not available code
      and code.misc3 eq "error"
   then
      vType = 0.
   else if code.misc3 eq "warning"
   then
      vType = 1.
   else if code.misc3 eq "Hiden"
   then
      vType = 2.
   else
      vtype = int(code.misc3) no-error.
   return vtype.
end.
function GetTextError returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character ):
   return GetTextErrortype(iCheckType,iCodeErr,iChechObj,"warning").
end.
function GetErrForUtdStr returns character
(idb-num     as integer ,
 idoc-id     as integer ,
 iCheckType  as character
 ):
   define buffer utd-err for utd-err.
   define buffer code    for code.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable vErrorOne as longchar  no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ""
         and vErrorOne ne ?
      then
         vError = vError + ", " + vErrorOne.
      vHQry:get-next().
   end.
   oError = substring(vError,3,4002).
   return oError.
end.
function GetErrJsonForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   define variable vi as integer no-undo.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      define variable vErrorOne as character no-undo.
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vi = vi + 1.
         vError = vError + ',"Ошибка_' + string(vi) +  '":~{"КодОш":"'    + utd-err.CheckType + "_" + utd-err.CodeErr
                         + '","ОбъектОш":"' + replace(utd-err.CheckObj,chr(4),"|")
                         + '","ТекстОш":"' + vErrorOne + '"}'.
      end.
      vHQry:get-next().
   end.
   for first utd where utd.db-num eq idb-num
                   and utd.doc-id eq idoc-id
                   and utd.sts    eq ObjSrv:Env:Utd:Sts:th:DeliveryCodeMismatch:KeyIntDB
   no-lock,
      each utd-marking-lines where utd-marking-lines.db-num eq idb-num
                               and utd-marking-lines.doc-id eq idoc-id
                               and utd-marking-lines.doc-level eq 1
   no-lock,
      first marking where marking.mark eq utd-marking-lines.mark
                      and marking.sts  eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
   no-lock:
      vErrorOne = GetTextErrortype("CheckShip","NotMark",marking.mark,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vError = vError + ',"Ошибка_' + string(vi) +  '":~{"КодОш":"'    + "CheckShip" + "_" + "NotMark"
                         + '","ОбъектОш":"' + marking.mark
                         + '","ТекстОш":"' + vErrorOne + '"}'.
      end.
   end.
   if vError ne ""
   then
      oError = '"Ошибки":~{' + substring(vError,2,31002) + "}".
   return oError.
end.
function GetErrJsonForUtdReturn returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable oError as character no-undo.
   define variable vi as integer no-undo.
   create query vHQry.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      define variable vErrorOne as character no-undo.
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vi = vi + 1.
         vError = vError + ',"Возврат_' + string(vi) +  '":~{"КодВозр":"'    + utd-err.CheckType + "_" + utd-err.CodeErr
                         + '","ОбъектВозр":"' + replace(utd-err.CheckObj,chr(4),"|")
                         + '","ТекстВозр":"' + GetTextError(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj) + '"}'.
      end.
      vHQry:get-next().
   end.
   if vError ne ""
   then
      oError = '"Возвраты":~{' + substring(vError,2,31002) + "}".
   return oError.
end.
function GetCodeTextError returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character,
 output oCode as character,
 output ovalue as character ):
   define buffer code    for code.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if     available code
   then do:
      define variable vi as integer no-undo init ?.
      vi = int(Code.misc3) no-error.
      if    code.misc3 ne "error"
         and vi ne 0
      then
         oCode = ?.
      else if     Code.misc1 ne ?
              and Code.misc1 ne ""
      then
         assign
            oCode  = GetMesError(Code.misc1,iChechObj)
            ovalue = GetMesError(Code.misc2,iChechObj)
         .
   end.
   return if oCode eq ""
          then ""
          else (oCode + "_" + ovalue).
end.
define temp-table TT-err no-undo
  field code_ as character
  field text_ as character
index code_ code_.
function GetErrTxtForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   define variable vi as integer no-undo.
   for each tt-err :
      delete tt-err.
   end.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   define variable vcode as character no-undo.
   define variable vvalue as character no-undo.
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      vi = vi + 1.
      GetCodeTextError (utd-err.CheckType, utd-err.CodeErr, utd-err.CheckObj, output vcode, output vvalue).
      if vcode ne ?
      then do:
         find first tt-err where tt-err.code eq vcode
         no-error.
         if not available tt-err
         then do:
            create tt-err.
            assign
               tt-err.code_ = vcode
               tt-err.text_ = vvalue
            .
         end.
         else
            tt-err.text_ = tt-err.text_ + "||" + vvalue.
      end.
      vHQry:get-next().
   end.
  find first utd where utd.db-num eq idb-num
                      and utd.doc-id eq idoc-id
      no-lock.
   define buffer cancel_utd-lines for utd-lines.
   for each cancel_utd-lines where cancel_utd-lines.db-num eq idb-num
                               and cancel_utd-lines.doc-id eq idoc-id
   no-lock:
      if logical(getattrutdlinesex  (idb-num,idoc-id,cancel_utd-lines.LineNum,"MarkUtdLine"        ,"no"))
      then do:
         for   each utd-marking-lines where utd-marking-lines.db-num eq idb-num
                                     and utd-marking-lines.doc-id eq idoc-id
                                     and utd-marking-lines.LineNum eq cancel_utd-lines.LineNum
         no-lock,
            first marking where marking.mark eq utd-marking-lines.mark
                            and marking.sts  eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
         no-lock:
            GetCodeTextError ("CheckShip", "MARKDECLINED", utd-marking-lines.mark + chr(4) + string(utd-marking-lines.LineNum), output vcode, output vvalue).
            find first tt-err where tt-err.code eq vcode
            no-error.
            if not available tt-err
            then do:
               create tt-err.
               assign
                  tt-err.code_ = vcode
                  tt-err.text_ = vvalue
               .
            end.
            else
               tt-err.text_ = tt-err.text_ + "||" + vvalue.
         end.
      end.
      else do:
         define variable vqnty as decimal no-undo.
         vqnty = decimal(GetAttrUtdlines(cancel_utd-lines.db-num,cancel_utd-lines.doc-id,cancel_utd-lines.linenum,"QuantityBarCode")).
         if vqnty eq ? then vqnty = 0.
         if vqnty ne cancel_utd-lines.Quantity
         then do:
            GetCodeTextError ("CheckShip", "NotAcceptQuantity", string(cancel_utd-lines.LineNum) + chr(4) + string(cancel_utd-lines.Quantity - vqnty), output vcode, output vvalue).
            find first tt-err where tt-err.code eq vcode
            no-error.
            if not available tt-err
            then do:
               create tt-err.
               assign
                  tt-err.code_ = vcode
                  tt-err.text_ = vvalue
               .
            end.
            else
               tt-err.text_ = tt-err.text_ + "||" + vvalue.
         end.
      end.
   end.
   for each tt-err:
      oError = oError + substitute("&1|&2|",tt-err.code_ , tt-err.text_ ) + chr(13) + chr(10) .
   end.
   return oError.
end.
define variable mFormatErr as character no-undo init "text".
function GetErrForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iType           as character
 ):
   if mFormatErr eq "text"
   then
      return GetErrTxtForUtd(idb-num,idoc-id,iType).
   else do:
      if itype eq "return"
      then return GetErrJsonForUtdReturn (idb-num,idoc-id,iType).
      else return GetErrJsonForUtd(idb-num,idoc-id,iType).
   end.
end.
function GetErrComText returns longchar
(icomment as character,
 itext    as longchar ):
    define variable vText as longchar no-undo.
   if mFormatErr eq "text"
   then do:
      if icomment ne ""
      then
         icomment = substitute("comment:|&1|",icomment).
      vText = icomment + itext.
   end.
   else do:
      icomment = if icomment begins  '"'
                 then icomment
                 else  if icomment eq "" then "" else ( '"Коментрии":~{"Коментарий":"' + icomment  + '"}') .
      vText = icomment + "," + itext.
      vText = "~{" + trim(vText,",") + "~}".
   end.
   return vText.
end.
function CheckTypeForMarkLineType returns logical
(iObj            as handle,
 iCheckType      as character,
 iCodeErr        as character ,
 iTypeErr        as character ):
   define variable vRecKey-markLine as character no-undo.
   define variable vGoodMark        as logical no-undo.
   define variable vdb-num          as integer no-undo.
   define variable vdoc-id          as integer no-undo.
   define variable vlinenum         as integer no-undo.
   define variable vErrorOne as character no-undo.
   define buffer buf_utd-err for utd-err.
   run gen-key-rec (input "utd-marking-lines",
                    input  iObj,
                    output vRecKey-markLine).
   vGoodMark = yes.
   vdb-num = iObj::db-num.
   vdoc-id = iObj::doc-id.
   vlinenum = iObj::linenum.
   block-mark-err:
   for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                            and buf_utd-err.db-num = vdb-num
                            and buf_utd-err.reckey = vRecKey-markLine
                            and if iCheckType  eq "*" or iCheckType eq ? then yes else buf_utd-err.CheckType = iCheckType
                            and if iCodeErr    eq "*" or iCodeErr   eq ? then yes else buf_utd-err.CodeErr   = iCodeErr
   no-lock:
      vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,iTypeErr).
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vGoodMark = no.
         leave block-mark-err.
      end.
   end.
   return not vGoodMark.
end.
function CheckErrForMarkLineType returns logical
(iObj            as handle,
 iType           as character  ):
   return CheckTypeForMarkLineType (iObj,iType,"*","error").
end.
function CheckErrForMarkLine returns logical
(iObj            as handle):
   return CheckErrForMarkLineType(iObj,"*").
end.
function CheckErrForLineTypeCode returns logical
(iObj                 as handle,
 iCheckType           as character,
 iCodeErr             as character,
 iTypeErr             as character,
 iOneErr              as logical):
   define variable vRecKey-line     as character no-undo.
   define buffer buf_utd-err for utd-err.
   define variable vUtdlineError as logical no-undo.
   define variable vErrorOne as character no-undo.
         run gen-key-rec (input "utd-lines",
                          input  iObj,
                          output vRecKey-line).
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vlinenum as integer no-undo.
      vdb-num = iObj::db-num.
      vdoc-id = iObj::doc-id.
      vlinenum = iObj::linenum.
      block-err:
      for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                               and buf_utd-err.db-num = vdb-num
                               and buf_utd-err.reckey = vRecKey-line
                               and if iCheckType eq "*" or iCheckType eq ? then yes else buf_utd-err.CheckType = iCheckType
                               and if iCodeErr   eq "*" or iCodeErr   eq ? then yes else buf_utd-err.CodeErr   = iCodeErr
      no-lock:
         vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,iTypeErr).
         if     vErrorOne ne ?
            and vErrorOne ne ""
         then do:
            vUtdlineError = yes.
            leave block-err.
         end.
      end.
      if  not vUtdlineError
      then do:
         define variable vGoodMark as logical no-undo.
         vGoodMark = yes.
         block-line-err:
         for each utd-marking-lines where utd-marking-lines.db-num  eq vdb-num
                                      and utd-marking-lines.doc-id  eq vdoc-id
                                      and utd-marking-lines.LineNum eq vLineNum
         no-lock:
            vGoodMark = not CheckTypeForMarkLineType(buffer utd-marking-lines:handle,iCheckType,iCodeErr,iTypeErr).
            if     vGoodMark
               and iOneErr eq no
            then
               leave block-line-err.
            if     iOneErr = yes
               and not vGoodMark
            then
               leave block-line-err.
         end.
         vUtdlineError = not vGoodMark.
      end.
   return vUtdlineError.
end.
function getErrForLineType returns character
(iObj            as handle,
 iType           as character  ):
   define variable vRecKey-line     as character no-undo.
   define buffer buf_utd-err for utd-err.
   define variable vUtdlineError as logical no-undo.
   define variable vErrorOne as character no-undo.
   define variable oError as character no-undo.
         run gen-key-rec (input "utd-lines",
                          input  iObj,
                          output vRecKey-line).
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vlinenum as integer no-undo.
      vdb-num = iObj::db-num.
      vdoc-id = iObj::doc-id.
      vlinenum = iObj::linenum.
      block-err:
      for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                               and buf_utd-err.db-num = vdb-num
                               and buf_utd-err.reckey = vRecKey-line
                               and if iType eq "*" or iType eq ? then yes else buf_utd-err.CheckType = iType
      no-lock:
         vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,"error").
         if     vErrorOne ne ?
            and vErrorOne ne ""
         then do:
            oError = oError + vErrorOne + " ".
         end.
      end.
   return oError.
end.
function CheckErrForLineType returns logical
(iObj            as handle,
 iType           as character  ):
    return CheckErrForLineTypeCode (iObj,itype,"*","error",no).
end.
function CheckErrForLine returns logical
(iObj            as handle):
   return CheckErrForLineType(iobj,"*").
end.
function CheckErrForUtd returns logical
(idb-num         as integer ,
 idoc-id         as integer ):
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock :
      if not CheckErrForLine (buffer ub.utd-lines:handle)
      then
         return no.
   end.
   return yes.
end.
function CheckMarkUtd-28rel return logical
 (input idb-num as integer,
 input idoc-id as integer):
 define buffer utd                   for utd.
 define buffer utd-lines             for utd-lines.
 define buffer utd-marking-lines     for utd-marking-lines.
 define variable v-par-type as character no-undo.
 define variable vgdsNoMark as logical no-undo.
 define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-val  as character no-undo.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if     utd.obj-code ne ?
         and utd.obj-type ne ?
      then do:
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(utd.obj-type, utd.obj-code).
         Block-utd-lines:
         for each utd-lines where utd-lines.db-num eq idb-num
                              and utd-lines.doc-id eq idoc-id
         no-lock:
            if     utd-lines.gds-code ne ?
               and utd-lines.gds-code ne 0
            then do:
                               if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                    ( utd-lines.gds-code,
                      'mark-type':U,
                       output v-par-val,
                       output v-par-type
                    ).
               if     EDOParSec:IsEdo
                  and EDOParSec:GetIsEDOForType(v-par-val)
               then do:
                  find first utd-marking-lines where utd-marking-lines.db-num  eq utd-lines.db-num
                                                 and utd-marking-lines.doc-id  eq utd-lines.doc-id
                                                 and utd-marking-lines.LineNum eq utd-lines.LineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock no-error.
                  if     avail utd-marking-lines
                     and not CheckErrForLine(buffer utd-lines:handle)
                  then
                     leave Block-utd-lines.
               end.
               else
                  vgdsNoMark = yes.
            end.
         end.
         setattrutd (utd.db-num,utd.doc-id,"MarkUtd",if vgdsNoMark then string(available utd-lines) else "yes").
         if vgdsNoMark then return available utd-lines . else return yes .
      end.
   end.
   return yes.
end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-utd-mark no-undo like utd-marking-lines
  field side as character.
def var vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function CheckMarkUtd return logical
 (input idb-num  as integer,
  input idoc-id  as integer):
  define buffer utd-lines             for ub.utd-lines.
  block-line:
  for each utd-lines where utd-lines.db-num eq idb-num
                       and utd-lines.doc-id eq idoc-id
  no-lock:
     if logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","yes"))
     then
        leave block-line.
  end.
  setattrutd (idb-num, idoc-id,"MarkUtd",string(available utd-lines)).
  return available utd-lines.
end.
function CheckNotMarkUtd return logical
 (input idb-num  as integer,
  input idoc-id  as integer):
  define buffer utd-lines             for ub.utd-lines.
  for each utd-lines where utd-lines.db-num eq idb-num
                       and utd-lines.doc-id eq idoc-id
  no-lock:
     if not logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","no"))
     then
        return yes.
  end.
  return no.
end.
function CheckMarkUtdLine return logical
 (input idb-num  as integer,
  input idoc-id  as integer,
  input iLineNum as integer):
 define buffer utd                   for utd.
 define buffer utd-lines             for utd-lines.
 define buffer utd-marking-lines     for utd-marking-lines.
 define variable v-par-type as character no-undo.
 define variable vMarking        as logical no-undo.
 define variable vArtic          as logical no-undo.
 define variable vTransitional   as logical no-undo.
 define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-val  as character no-undo.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if     utd.obj-code ne ?
         and utd.obj-type ne ?
      then do:
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(utd.obj-type, utd.obj-code).
         Block-utd-lines:
         for each utd-lines where utd-lines.db-num   eq idb-num
                              and utd-lines.doc-id   eq idoc-id
                              and utd-lines.LineNum  eq iLineNum
         no-lock:
            if     utd-lines.gds-code ne ?
               and utd-lines.gds-code ne 0
            then do:
                               if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                    ( utd-lines.gds-code,
                      'mark-type':U,
                       output v-par-val,
                       output v-par-type
                    ).
               vMarking = EDOParSec:GetIsEDOForType(v-par-val).
               vArtic = not vMarking and EDOParSec:GetIsArticForType(v-par-val).
               if vMarking
               then do:
                  block-marking:
                  for each   utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock:
                     if isOAD(utd-marking-lines.mark)
                     then do:
                        assign
                           vArtic   = yes
                           vMarking = no
                        .
                        leave block-marking.
                     end.
                  end.
               end.
               if vArtic
               then do:
                  block-artic:
                  for each   utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock:
                     if isMark(utd-marking-lines.mark)
                     then do:
                        assign
                           vArtic   = no
                           vMarking = yes
                        .
                        leave block-artic.
                     end.
                  end.
               end.
               vTransitional = (vMarking or vArtic) and EDOParSec:GetIsTransitionalForType(v-par-val).
               if vTransitional
               then do:
                  find first utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock no-error.
                  if not available utd-marking-lines
                  then assign
                     vMarking = no
                     vArtic   = no
                  .
               end.
            end.
            else
               assign
                  vMarking      = yes
                  vArtic        = no
                  vTransitional = no
               .
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"MarkUtdLine"         ,if vMarking      then "yes" else "").
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"ArticUtdLine"        ,if vArtic        then "yes" else "").
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"TransitionalUtdLine" ,if vTransitional then "yes" else "").
         end.
      end.
   end.
   return vMarking or vArtic.
end.
function getMarkUtdLine return logical
 (input  idb-num  as integer,
  input  idoc-id  as integer,
  input  iLineNum as integer,
  output oMarking        as logical,
  output oArtic          as logical,
  output oTransitional   as logical):
  oMarking = logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"MarkUtdLine"        ,"no")).
  oArtic        = not oMarking
         and logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"ArticUtdLine"       ,"no")).
  oTransitional = (oMarking or oArtic)
         and logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"TransitionalUtdLine","no")).
end.
function CheckMarking return logical
 (input idb-num as integer,
 input idoc-id as integer,
 input iTypeErr as character ):
  define variable vMarkutd as logical no-undo.
  define variable vCrErr   as logical no-undo.
  define buffer utd-lines         for utd-lines.
  define buffer utd-marking-lines for utd-marking-lines.
  define buffer marking           for marking.
  ClearUtdErrTypeCode(idb-num,idoc-id,iTypeErr,"NotMark").
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      if logical (getAttrUtdLinesEx(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","no"))
      then do:
         for each utd-marking-lines
                  where utd-marking-lines.db-num  = utd-lines.db-num
                    and utd-marking-lines.doc-id  = utd-lines.doc-id
                    and utd-marking-lines.LineNum = utd-lines.LineNum
         no-lock:
            if isMark(utd-marking-lines.mark)
            then do:
               find first marking where marking.mark eq utd-marking-lines.mark
               no-lock no-error.
               if not available marking
               then do:
                  AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iTypeErr,"NotMark",string(utd-lines.LineNum)).
                  vCrErr = yes.
                  next block-line.
               end.
            end.
         end.
      end.
   end.
   return vCrErr.
end.
function CheckMarkForType return logical
 (input idb-num   as integer,
  input idoc-id   as integer):
   define variable vMarking        as logical no-undo.
   define variable vArtic          as logical no-undo.
   define variable vTransitional   as logical no-undo.
   define buffer utd-lines         for utd-lines.
   define buffer utd-marking-lines for utd-marking-lines.
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      getMarkUtdLine  (input  utd-lines.db-num , input  utd-lines.doc-id, input  utd-lines.LineNum,
                       output vMarking         , output vArtic          , output vTransitional).
      for each utd-marking-lines
                  where utd-marking-lines.db-num  = utd-lines.db-num
                    and utd-marking-lines.doc-id  = utd-lines.doc-id
                    and utd-marking-lines.LineNum = utd-lines.LineNum
      no-lock:
         if length(utd-marking-lines.mark) < 14
         then do:
            if (vMarking or vArtic) and not vTransitional
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"loadUtd","NotMark",utd-marking-lines.mark).
         end.
         else if not isMark(utd-marking-lines.mark)
         then do:
            if vMarking
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"loadUtd","NotMark",utd-marking-lines.mark).
         end.
         else do:
         end.
      end.
   end.
end.
function WeighedProd return logical
   ( input p-gds-code as integer) :
   define variable v-par-val  as character no-undo.
   define variable v-par-type as character no-undo.
           if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
            ( p-gds-code,
              'weighed-gds':U,
               output v-par-val,
               output v-par-type
            ).
   return logical(v-par-val).
end.
function WghProdVariable return logical
    (input p-obj-type as char,
     input p-obj-code as integer,
     input p-gds-code as integer) :
   define variable v-wgh-val  as character no-undo.
   define variable v-par-val  as character no-undo.
   define variable v-par-type as character no-undo.
   define variable vMarking        as logical no-undo.
   define variable vArtic          as logical no-undo.
   define variable vTransitional   as logical no-undo.
   define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
      if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
        ( p-gds-code,
          'weighed-gds':U,
           output v-wgh-val,
           output v-par-type
        ).
    if logical(v-wgh-val) = yes then do:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
            ( p-gds-code,
              'mark-type':U,
               output v-par-val,
               output v-par-type
            ).
        if v-par-val <> "" then do:
            EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(p-obj-type, p-obj-code).
            assign
               vMarking = EDOParSec:GetIsEDOForType(v-par-val)
               vArtic = not vMarking and EDOParSec:GetIsArticForType(v-par-val)
               .
        end.
   end.
   if v-wgh-val > "" and (vMarking or vArtic)
   then return yes.
   else return no.
end.
function MarkWeight return decimal
   ( input p-mark as character) :
   define buffer  buf_marking-attr for  ub.marking-attr.
   define variable vMarkWeight as decimal no-undo.
   vMarkWeight = 0.
   if p-mark <> "" and p-mark <> ?
   then do:
       find first buf_marking-attr where buf_marking-attr.mark      eq p-mark
                                     and buf_marking-attr.attr-code eq "weight"
          no-lock no-error.
       if not available buf_marking-attr
       then do :
         find first buf_marking-attr where buf_marking-attr.mark  begins p-mark
                                       and buf_marking-attr.attr-code eq "weight"
            no-lock no-error.
       end .
       if avail buf_marking-attr
       then vMarkWeight = dec(buf_marking-attr.attr-value).
   end.
   return vMarkWeight.
end.
function CheckQnty returns logical
(  input idb-num  as integer,
   input idoc-id  as integer,
   input iErrType as character
):
   if iErrType ne "loadUTD"
   then do:
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","MarkNotFormatqnty").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","QntyMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","Qnty").
   end.
   if iErrType ne "CheckQnty"
   then do:
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckQnty","MarkNotFormatqnty").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckQnty","QntyMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckQnty","Qnty").
   end.
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"QntyMark").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"MarkNotFormatqnty").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"Qnty").
   define buffer marking               for marking.
   define buffer utd-lines             for utd-lines.
   define buffer utd-marking-lines     for utd-marking-lines.
   define buffer Buf_utd-marking-lines for utd-marking-lines.
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      define variable Vflagmark as logical no-undo.
      find first buf_utd-marking-lines
                    where buf_utd-marking-lines.db-num   = utd-lines.db-num
                      and buf_utd-marking-lines.doc-id   = utd-lines.doc-id
                      and buf_utd-marking-lines.LineNum  = utd-lines.LineNum
                      and length(buf_utd-marking-lines.mark) > 13
      no-lock no-error.
      if not available buf_utd-marking-lines
      then
         next block-line.
      define variable vqntyMark as integer no-undo.
      define variable vqntyOAD  as integer no-undo.
      vqntyMark = 0.
      vqntyOAD  = 0.
      block-mark:
      for each utd-marking-lines
           where utd-marking-lines.db-num  = utd-lines.db-num
             and utd-marking-lines.doc-id  = utd-lines.doc-id
             and utd-marking-lines.LineNum = utd-lines.LineNum
             and length(utd-marking-lines.mark) > 13
             and utd-marking-lines.doc-level  = 1
      no-lock:
         if isMark(utd-marking-lines.mark)
         then do:
            find first marking where marking.mark eq utd-marking-lines.mark
            no-lock no-error.
            if available marking
            then do:
               if marking.box-qnty ne ?
               then
                  vqntyMark = vqntyMark + marking.box-qnty.
            end.
         end.
         else do:
            find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq utd-marking-lines.db-num
                                                and utd-marking-lines-attr.doc-id    eq utd-marking-lines.doc-id
                                                and utd-marking-lines-attr.LineNum   eq utd-marking-lines.LineNum
                                                and utd-marking-lines-attr.mark      eq utd-marking-lines.mark
                                                and utd-marking-lines-attr.attr-code eq "box-qnty"
            no-lock no-error.
            if available utd-marking-lines-attr
            then
               vqntyOAD = vqntyOAD + dec(utd-marking-lines-attr.attr-value).
         end.
      end.
      if     utd-lines.gds-code   gt 0
         and utd-lines.gds-code   ne ?
         and vqntyMark            ne 0
      then do:
         if utd-lines.Quantity  < vqntyMark
         then
            AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"Qnty",string(utd-lines.LineNum ) + chr(4) + string(utd-lines.Quantity ) + chr(4) + string(vqntyMark)).
         else if utd-lines.Quantity  <> vqntyMark
         then
            AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"QntyMark",string(utd-lines.LineNum ) + chr(4) + string(utd-lines.Quantity ) + chr(4) + string(vqntyMark)).
      end.
      else if     utd-lines.gds-code   gt 0
         and utd-lines.gds-code   ne ?
         and vqntyOAD ne 0
         and utd-lines.Quantity  ne vqntyOAD
      then
         AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"Qnty",string(utd-lines.LineNum ) + chr(4) + string(utd-lines.Quantity ) + chr(4) + string(vqntyOAD)).
   end.
end.
function CheckGds returns logical
(  input idb-num   as integer,
   input idoc-id   as integer,
   input iobj-type as character,
   input iobj-code as integer,
   input iErrType as character
):
   if iErrType ne "loadUTD"
   then do:
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","InLineNotMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NoGtinForMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NoBarcodForGtin").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","MarkNotFormatqnty").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","MarkingForTypeEDO").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NotMarkForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","MultGtinForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NoBarCodeForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NotFindGdsForBarCode").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NotEqGgsForLineAndMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","GtinQntyNotOne").
   end.
   if iErrType ne "CheckGds"
   then do:
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","InLineNotMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NoGtinForMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NoBarcodForGtin").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","MarkNotFormatqnty").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","MarkingForTypeEDO").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NotMarkForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","MultGtinForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NoBarCodeForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NotFindGdsForBarCode").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NotEqGgsForLineAndMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","GtinQntyNotOne").
   end.
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"InLineNotMark").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NoGtinForMark").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NoBarcodForGtin").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"MarkNotFormatqnty").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"MarkingForTypeEDO").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NotMarkForLine").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"MultGtinForLine").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NoBarCodeForLine").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NotFindGdsForBarCode").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NotEqGgsForLineAndMark").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"GtinQntyNotOne").
   define variable v-par-type as character no-undo.
   define variable v-par-val  as character no-undo.
   define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define buffer marking               for marking.
   define buffer utd-lines             for utd-lines.
   define buffer buf_utd-lines         for utd-lines.
   define buffer utd-marking-lines     for utd-marking-lines.
   define buffer Buf_utd-marking-lines for utd-marking-lines.
   define variable vGdsCode as integer no-undo.
   EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(iobj-type, iobj-code).
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      vGdsCode = ?.
      define variable Vflagmark as logical no-undo.
      define variable VflagOAD  as logical no-undo.
      assign
         Vflagmark = no
         VflagOAD = no
      .
      block-mark:
      for each utd-marking-lines
               where utd-marking-lines.db-num  = utd-lines.db-num
                 and utd-marking-lines.doc-id  = utd-lines.doc-id
                 and utd-marking-lines.LineNum = utd-lines.LineNum
      no-lock:
         if    isMark(utd-marking-lines.mark)
            or isOAD (utd-marking-lines.mark)
         then do:
            define variable vnewGdsCode as integer no-undo.
            vnewGdsCode = getGdsCodeByDM(utd-marking-lines.mark).
            if isMark(utd-marking-lines.mark)
            then do:
               Vflagmark = yes.
               find first marking where marking.mark eq utd-marking-lines.mark
               no-lock no-error.
               if not available marking
               then do:
                  AddUtdErr(utd-marking-lines.db-num,utd-marking-lines.doc-id,buffer utd-marking-lines:handle,iErrType,"InLineNotMark",utd-marking-lines.mark).
                  next block-mark.
               end.
               if vnewGdsCode eq ?
               then
                  vnewGdsCode = GetGdsCodeByGtin(marking.gds-ext-id).
               if    marking.gds-code eq 0
                  or marking.gds-code eq ?
                  or marking.sts eq 0
                  or marking.sts eq ?
                  or marking.box-qnty eq ?
                  or (marking.gds-code ne vnewGdsCode
                      and vnewGdsCode ne ?
                      and vnewGdsCode ne 0)
               then do:
                  find first marking where marking.mark eq utd-marking-lines.mark
                  exclusive-lock no-error.
                  if marking.box-qnty = ? then marking.box-qnty = getQntyUTDByDM(marking.mark).
                  if marking.gds-ext-id = "" then marking.gds-ext-id = getGtinByDM(marking.mark).
                  if marking.gds-code = ? or marking.gds-code ne vnewGdsCode then marking.gds-code = vnewGdsCode.
                  if    marking.gds-ext-id eq ""
                     or marking.gds-ext-id eq ?
                  then do:
                     AddUtdErr(utd-marking-lines.db-num,utd-marking-lines.doc-id,buffer utd-marking-lines:handle,iErrType,"NoGtinForMark",string(utd-lines.LineNum ) + chr(4) + marking.mark).
                  end.
                  else if    marking.gds-code eq 0
                          or marking.gds-code eq ?
                  then
                     AddUtdErr(utd-marking-lines.db-num,utd-marking-lines.doc-id,buffer utd-marking-lines:handle,iErrType,"NoBarcodForGtin",string(utd-lines.LineNum ) + chr(4) + marking.gds-ext-id).
                  else if     marking.sts eq 0
                          or  marking.sts eq ?
                  then
                     marking.sts = objSrv:Env:marking:Sts:Mark:PendingVerification:KeyIntDB.
               end.
               if utd-marking-lines.doc-level eq 1
               then do:
                  if marking.box-qnty eq ?
                  then
                     AddUtdErr(utd-marking-lines.db-num,utd-marking-lines.doc-id,buffer utd-marking-lines:handle,iErrType,"MarkNotFormatqnty",string(utd-lines.LineNum ) + chr(4) + utd-marking-lines.mark).
               end.
            end.
            else do:
               VflagOAD = yes.
               define variable vQnty as decimal no-undo.
               vQnty = getQntyUTDByCodId(utd-marking-lines.mark) .
               setAttrUtdMarkingLines (utd-marking-lines.db-num,
                                       utd-marking-lines.doc-id,
                                       utd-marking-lines.LineNum,
                                       utd-marking-lines.mark,
                                       "box-qnty",
                                        string(vQnty)).
               define variable vgtin as character no-undo.
               vgtin = getGtinByDM(utd-marking-lines.mark).
               if getQntyCodeByGtin(vgtin) ne 1
               then
                  AddUtdErr(utd-marking-lines.db-num,utd-marking-lines.doc-id,buffer utd-marking-lines:handle,iErrType,"GtinQntyNotOne",string(utd-lines.LineNum ) + chr(4) + vgtin).
            end.
            if utd-marking-lines.gds-code ne vnewGdsCode
            and vnewGdsCode ne ?
            and vnewGdsCode ne 0
            then do:
               find first buf_utd-marking-lines
                        where buf_utd-marking-lines.db-num   = utd-marking-lines.db-num
                          and buf_utd-marking-lines.doc-id   = utd-marking-lines.doc-id
                          and buf_utd-marking-lines.LineNum  = utd-marking-lines.LineNum
                          and buf_utd-marking-lines.mark     = utd-marking-lines.mark
               exclusive-lock no-error.
               if available buf_utd-marking-lines
               then do:
                  buf_utd-marking-lines.gds-code = vnewGdsCode.
               end.
            end.
         end.
         else  do:
            define variable vgdsbar as integer no-undo.
            vgdsbar = GetGdsCodeByGtin(utd-marking-lines.mark).
            if    utd-marking-lines.gds-code ne vgdsbar
            then do:
               find first buf_utd-marking-lines
                          where buf_utd-marking-lines.db-num   = utd-marking-lines.db-num
                            and buf_utd-marking-lines.doc-id   = utd-marking-lines.doc-id
                            and buf_utd-marking-lines.LineNum  = utd-marking-lines.LineNum
                            and buf_utd-marking-lines.mark     = utd-marking-lines.mark
               exclusive-lock no-error.
               if available buf_utd-marking-lines
               then do:
                  buf_utd-marking-lines.gds-code = vgdsbar.
               end.
            end.
            if vgdsbar ne ?
            then do:
                              if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                         ( vgdsbar,
                           'mark-type':U,
                           output v-par-val,
                           output v-par-type
                          ).
               if      (EDOParSec:GetIsEDOForType(v-par-val)
                    or  EDOParSec:GetIsArticForType(v-par-val))
                and not EDOParSec:GetIsTransitionalForType(v-par-val)
                and     EDOParSec:IsEdo
               then do:
                  AddUtdErr(utd-marking-lines.db-num,
                            utd-marking-lines.doc-id,
                            buffer utd-marking-lines:handle,
                            iErrType,
                            "MarkingForTypeEDO",
                            string(utd-lines.LineNum ) + chr(4) + utd-marking-lines.mark).
               end.
            end.
         end.
         if vGdsCode eq ?
         then
            vGdsCode = utd-marking-lines.gds-code.
         if vGdsCode ne utd-marking-lines.gds-code
         and utd-marking-lines.gds-code > 0
         then do:
            vGdsCode = -1.
         end.
      end.
      if  vGdsCode = -1
      then do:
         vGdsCode = ?.
         AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"MultGtinForLine",string(utd-lines.LineNum )).
         next block-line.
      end.
      if vGdsCode ne ?
      then do:
                  if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                   ( vGdsCode,
                     'mark-type':U,
                     output v-par-val,
                     output v-par-type
                    ).
         if   not EDOParSec:GetIsTransitionalForType(v-par-val)
             and(
              (    EDOParSec:GetIsEDOForType(v-par-val)
                  and not Vflagmark)
              or  (EDOParSec:GetIsArticForType(v-par-val)
                  and not VflagOAD
                  and not Vflagmark))
         then do:
            AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"NotMarkForLine",string(utd-lines.LineNum)).
         end.
      end.
      if utd-lines.gds-code ne vGdsCode
      then do:
         find first  buf_utd-lines where buf_utd-lines.db-num  eq utd-lines.db-num
                                     and buf_utd-lines.doc-id  eq utd-lines.doc-id
                                     and buf_utd-lines.LineNum eq utd-lines.LineNum
         exclusive-lock no-error.
         if available buf_utd-lines
         then
            buf_utd-lines.gds-code = vGdsCode.
         release buf_utd-lines.
      end.
      define variable VBarCode as character no-undo.
      VBarCode = getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"BarCode").
      if VBarCode ne ?
      then do:
         if num-entries(VBarCode," ") > 0
         then
            VBarCode = entry(num-entries(VBarCode," "),VBarCode," ").
         vgdsbar = GetGdsCodeByGtin(VBarCode).
         if vgdsbar eq ? or vgdsbar eq 0
         then do:
            AddUtdErr(utd-lines.db-num,
                      utd-lines.doc-id,
                      buffer utd-lines:handle,
                      iErrType,
                      "NotFindGdsForBarCode",
                      string(utd-lines.LineNum ) + chr(4) + VBarCode).
         end.
         else do:
            if    utd-lines.gds-code eq ?
               or utd-lines.gds-code eq 0
            then do:
               find first  buf_utd-lines where buf_utd-lines.db-num  eq utd-lines.db-num
                                           and buf_utd-lines.doc-id  eq utd-lines.doc-id
                                           and buf_utd-lines.LineNum eq utd-lines.LineNum
               exclusive-lock no-error.
               if available buf_utd-lines
               then
                  buf_utd-lines.gds-code = vgdsbar.
               release buf_utd-lines.
            end.
            else if utd-lines.gds-code ne vgdsbar
            then do:
               AddUtdErr(utd-lines.db-num,
                      utd-lines.doc-id,
                      buffer utd-lines:handle,
                      iErrType,
                      "NotEqGgsForLineAndMark",
                      string(utd-lines.LineNum ) + chr(4) + String(vgdsbar) + chr(4) + String(utd-lines.gds-code)).
            end.
         end.
      end.
      if vGdsCode eq ? and utd-lines.gds-code eq ?
      then
         AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"NoBarCodeForLine",string(utd-lines.LineNum )).
   end.
end.
function GetUtdLineForOrig return logical
(input idb-num as integer,
 input idoc-id as integer,
 input ilineNum as integer,
 input idb-numOrig as integer,
 input idoc-idOrig as integer,
 buffer edoc-lines for utd-lines):
   define buffer edoc-marking-lines for ub.utd-marking-lines.
   block-mark:
   for each utd-marking-lines where utd-marking-lines.db-num  eq idb-num
                                and utd-marking-lines.doc-id  eq idoc-id
                                and utd-marking-lines.LineNum eq iLineNum
                                and utd-marking-lines.site eq "-"
   no-lock:
      find first edoc-marking-lines where edoc-marking-lines.db-num eq idb-numOrig
                                      and edoc-marking-lines.doc-id eq idoc-idOrig
                                      and edoc-marking-lines.mark   eq utd-marking-lines.mark
                  no-lock no-error.
      if available edoc-marking-lines
      then do:
         find first edoc-lines where edoc-lines.db-num      = edoc-marking-lines.db-num
                                 and edoc-lines.doc-id            = edoc-marking-lines.doc-id
                                 and edoc-lines.LineNum           = edoc-marking-lines.LineNum
         no-lock no-error.
            leave block-mark.
       end.
   end.
    if not available edoc-lines
    then do:
       find  first  utd-lines where utd-lines.db-num      = idb-num
                                and utd-lines.doc-id      = idoc-id
                                and utd-lines.LineNum     = ilinenum
          no-lock no-error.
       find  edoc-lines where edoc-lines.db-num      = idb-numOrig
                               and edoc-lines.doc-id      = idoc-idOrig
                               and edoc-lines.ProductCode = utd-lines.ProductCode
       no-lock no-error.
    end.
    if not available edoc-lines
    then
       find  edoc-lines where edoc-lines.db-num      = idb-numOrig
                               and edoc-lines.doc-id      = idoc-idOrig
                               and edoc-lines.gds-code    = utd-lines.gds-code
       no-lock no-error.
end.
function GetLastUTDinPack returns logical
(input idb-num as integer,
 input idoc-id as integer,
 output odb-num as integer,
 output odoc-id as integer ) forward.
function getObgFns return logical
(input iDocumentNumber   as character ,
 input iFnsParticipantId as character ,
 input ikpp              as character ,
 output ohost-code       as integer,
 output oobj-type        as character ,
 output oobj-code        as integer ,
 output otext            as character  ):
    define buffer ext-classif   for ext-classif.
    define buffer clients       for clients.
    define buffer buf_clients   for clients.
    define buffer clients-attr  for clients-attr.
    find first ext-classif where ext-classif.classif-name  eq 'id_diadok_client':U
                             and ext-classif.charkey_three eq iFnsParticipantId
    no-lock no-error.
    if available ext-classif
    then do:
       if ext-classif.CharKey_One eq 'маг':U
       then do:
          assign
             oobj-type = ext-classif.CharKey_One
             oobj-code = ext-classif.Key#_One
          .
          find first clients
               where clients.obj-type   = ext-classif.CharKey_One
                 and clients.obj-code   = ext-classif.Key#_One
          no-lock no-error .
          if available clients
          then
             ohost-code =  clients.host-code.
       end.
       else do:
          find first clients
               where clients.obj-type   = ext-classif.CharKey_One
                 and clients.obj-code   = ext-classif.Key#_One
                 and can-find(first ub.sysconf where ub.sysconf.host-code = clients.obj-code)
          no-lock no-error .
          if not available clients
          then do:
             otext = substitute("По &1 получатель  &2 не наша фирма." ,iDocumentNumber, iFnsParticipantId) .
             return no.
          end.
          ohost-code = ext-classif.Key#_One.
          block-cl:
          for each clients-attr
             where clients-attr.attr-code  = 'kpp':U
               and clients-attr.obj-type   = 'маг':U
               and clients-attr.attr-value = ikpp
               and can-find(buf_clients where buf_clients.obj-type   = clients-attr.obj-type
                                          and buf_clients.obj-code   = clients-attr.obj-code
                                          and buf_clients.host-code  = ohost-code)
          no-lock :
             leave block-cl.
          end.
          if     available clients
             and clients.obj-type eq 'маг':U
          then do:
             assign
                oobj-type = clients.obj-type
                oobj-code = clients.obj-code
             .
          end.
          else if available clients-attr
          then do:
             assign
                oobj-type = clients-attr.obj-type
                oobj-code = clients-attr.obj-code
             .
          end.
          else do:
             otext = substitute("По &1 не найден объект по КПП &2." ,iDocumentNumber, ikpp ).
             return yes.
          end.
       end.
    end.
    else do:
       otext = substitute("По &1 не найден получатель  &2." ,iDocumentNumber, iFnsParticipantId) .
       return no.
    end.
    return ?.
end.
function CheckUcdForReturn return logical
(input idb-numUcd as integer,
 input idoc-idUcd as integer,
 input idb-numRet as integer,
 input idoc-idRet as integer  ):
    for each utd-marking-lines where utd-marking-lines.db-num eq idb-numUcd
                                 and utd-marking-lines.doc-id eq idoc-idUcd
                                 and utd-marking-lines.doc-level eq 1
    no-lock:
       create tt-utd-mark.
       buffer-copy utd-marking-lines to tt-utd-mark
       assign
          tt-utd-mark.side = "+"
       .
    end.
    for each utd-marking-lines where utd-marking-lines.db-num eq idb-numRet
                                 and utd-marking-lines.doc-id eq idoc-idRet
                                 and utd-marking-lines.doc-level eq 1
    no-lock:
       find first tt-utd-mark where tt-utd-mark.mark eq utd-marking-lines.mark
       no-lock no-error.
       if available tt-utd-mark
       then
          tt-utd-mark.side = "".
       else do:
          create tt-utd-mark.
          buffer-copy utd-marking-lines to tt-utd-mark
          assign
             tt-utd-mark.side = "-"
          .
       end.
    end.
    for each tt-utd-mark where  tt-utd-mark.side ne ""
    no-lock:
       AddUtdErrForTab(utd.db-num, utd.doc-id, "utd-marking-lines", buffer tt-utd-mark:handle, "UCDСompar", "NotMark" + tt-utd-mark.side, tt-utd-mark.mark).
    end.
    for each tt-utd-mark:
       delete tt-utd-mark.
    end.
end.
function GetLastUTDinPackAft returns logical
(input idb-num as integer,
 input idoc-id as integer,
 output odb-num as integer,
 output odoc-id as integer ) forward.
function SaturateAndCheckUTD return character
(input idb-num as integer,
 input idoc-id as integer  ):
   define buffer clients-attr          for clients-attr.
   define buffer clients               for clients.
   define buffer Utd                   for Utd.
   define buffer utd_ret               for ub.utd.
   define buffer utd-lines             for utd-lines.
   define buffer buf_utd-lines         for utd-lines.
   define buffer buf_utddoc-lines      for utd-lines.
   define buffer marking               for marking.
   define buffer marking-lines         for marking-lines.
   define buffer utd-marking-lines     for utd-marking-lines.
   define buffer Buf_utd-marking-lines for utd-marking-lines.
   define buffer contract              for contract.
   define buffer old_utd               for Utd.
   define variable vError as character no-undo.
   define variable vGdsCode as integer no-undo.
   define variable vcli-type as character no-undo.
   define variable vcli-code as integer no-undo.
   define variable vhost-code as integer no-undo init ?.
   define variable vcontract-code as integer no-undo.
   define variable vobj-type as character no-undo init ?.
   define variable vobj-code as integer no-undo init ?.
   define variable volddb-num as integer no-undo.
   define variable volddoc-id as integer no-undo.
   define variable vMark as logical no-undo.
   define variable VUcd as logical no-undo.
   define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-type as character no-undo.
   define variable v-par-val  as character no-undo.
   define variable VFileMark as logical no-undo.
   define variable vunit     as int no-undo.
   define variable vunitCode as character no-undo.
   define variable vMarkingUtd as logical no-undo.
   find first Utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available Utd
   then do:
      VUcd = utd.EDocType eq objSrv:Env:Utd:EDocType:UCD:KeyIntDB.
      VFileMark = getattrutd (utd.db-num,utd.doc-id,"FileName") begins "ON_NSCHFDOPPRMARK_".
      ClearUtdErr(utd.db-num,utd.doc-id,"loadUtd").
      assign
            vobj-type  = utd.obj-type
            vobj-code  = utd.obj-code
            vhost-code = utd.host-code
      .
      do:
         define variable vtext       as character no-undo.
         define variable vhost-code1 as integer   no-undo.
         define variable vobj-type1  as character no-undo.
         define variable vobj-code1  as integer   no-undo.
          getObgFns
                    (input utd.DocumentNumber ,
                     input utd.obj-FnsParticipantId ,
                     input utd.obj-kpp,
                     output vhost-code1,
                     output vobj-type1,
                     output vobj-code1,
                     output vtext ).
         assign
            vobj-type  = vobj-type1   when vobj-type  eq ? or vobj-type  eq ""
            vobj-code  = vobj-code1   when vobj-code  eq ? or vobj-code  eq 0
            vhost-code = vhost-code1  when vhost-code eq ? or vhost-code eq 0
         .
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(vobj-type, vobj-code).
         CheckGds (utd.db-num,utd.doc-id,vobj-type,vobj-code,"loadUTD").
         block-line:
         for each utd-lines where utd-lines.db-num eq utd.db-num
                              and utd-lines.doc-id eq utd.doc-id
         no-lock:
            vGdsCode =?.
            define variable vNotMarkForLine as logical no-undo.
            vNotMarkForLine = no.
            if not VUcd
            then do:
               find first utd-marking-lines
                    where utd-marking-lines.db-num  = utd-lines.db-num
                      and utd-marking-lines.doc-id  = utd-lines.doc-id
                      and utd-marking-lines.LineNum = utd-lines.LineNum
               no-lock no-error.
               if not available utd-marking-lines
               then do:
                  AddUtdErr(utd.db-num,utd.doc-id,buffer utd-lines:handle,"loadUtd","NotMarkForLine",string(utd-lines.LineNum)).
                  vNotMarkForLine = yes.
               end.
            end.
            block-mark:
            for each utd-marking-lines
               where utd-marking-lines.db-num  = utd-lines.db-num
                 and utd-marking-lines.doc-id  = utd-lines.doc-id
                 and utd-marking-lines.LineNum = utd-lines.LineNum
            no-lock:
               vMark = yes.
               if     isMark(utd-marking-lines.mark)
                  and utd-marking-lines.gds-code  ne 0
                  and utd-marking-lines.gds-code ne ?
               then do:
                                    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                        ( utd-marking-lines.gds-code,
                         'mark-type':U,
                         output v-par-val,
                         output v-par-type
                         ).
                   if     not VFileMark
                      and not VUcd
                      and EDOParSec:GetIsEDOForType(v-par-val) and EDOParSec:IsEdo
                   then do:
                       AddUtdErr(utd.db-num,
                                  utd.doc-id,
                                  buffer utd-marking-lines:handle,
                                  "loadUtd",
                                  "NotON_NSCHFDOPPRMARK",
                                  string(utd-lines.LineNum ) + chr(4) + utd-marking-lines.mark).
                  end.
               end.
            end.
            if utd-lines.gds-code eq 0 or utd-lines.gds-code eq ?
            then do :
               if     VUcd
               then do:
                  GetLastUTDinPack (utd.db-num,utd.doc-id,volddb-num,volddoc-id).
                  GetUtdLineForOrig(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,volddb-num,volddoc-id, buffer buf_utddoc-lines).
                  if available buf_utddoc-lines
                  then do:
                     vGdsCode = buf_utddoc-lines.gds-code.
                     vunitCode = buf_utddoc-lines.UnitCode.
                     if     getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old") ne ?
                        and buf_utddoc-lines.UnitCode ne getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old")
                     then
                        AddUtdErr(utd.db-num,utd.doc-id,buffer utd-lines:handle,
                            "loadUtd",
                            "UcdUnitChangForUtd",
                            string(utd-lines.LineNum )                  + chr(4) +
                            buf_utddoc-lines.UnitCode                   + chr(4) +
                            getattrutdlinesex(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old","?")).
                  end.
                  if     utd-lines.UnitCode ne ?
                     and utd-lines.UnitCode ne ""
                     and utd-lines.UnitCode ne getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old")
                  then
                     AddUtdErr(utd.db-num,utd.doc-id,buffer utd-lines:handle,
                            "loadUtd",
                            "UcdUnitChang",
                            string(utd-lines.LineNum )                  + chr(4) +
                            utd-lines.UnitCode                          + chr(4) +
                            getattrutdlinesex(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old","?")).
               end.
            end.
            else
               vGdsCode = utd-lines.gds-code.
            define variable vValText as character no-undo.
            define variable vValDec  as decimal no-undo.
            VValText = GetAttrUtdlines (utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity").
            if VValText = ?
            then do:
               vValDec = utd-lines.Quantity.
               setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity",string(utd-lines.Quantity)).
            end.
            else
               vValDec = dec(VValText).
            release bar-code .
            if     vGdsCode > 0 and vGdsCode ne ?
            then do:
               assign
                  vunitCode = utd-lines.UnitCode when utd-lines.UnitCode ne ? and utd-lines.UnitCode ne ""
                  vunit = ?
                  vunit = integer (getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unit"))
               no-error.
               if vunit ne 0 and vunit ne ?
               then do:
                  find units where units.OKEI eq vunit no-lock no-error.
                  if available units
                  then
                     vunitCode = units.unit-name.
               end.
               find first bar-code where bar-code.gds-code eq vGdsCode
                                     and bar-code.unit-cli eq vUnitCode
               no-lock no-error.
               if not available bar-code
               then
                  AddUtdErr(utd.db-num,utd.doc-id,buffer utd-lines:handle,
                            "loadUtd",
                            "Unit",
                            string(utd-lines.LineNum )                  + chr(4) +
                            string(vGdsCode)                            + chr(4) +
                            (if vunit ne ? then string(vunit ) else "") + chr(4) +
                            vunitCode).
            end.
            if utd-lines.Quantity ne vValDec * (if avail bar-code then bar-code.cli-base-rate else 1)
            then do:
               find first  buf_utd-lines where buf_utd-lines.db-num  eq utd-lines.db-num
                                           and buf_utd-lines.doc-id  eq utd-lines.doc-id
                                           and buf_utd-lines.LineNum eq utd-lines.LineNum
               exclusive-lock no-error.
               if available buf_utd-lines
               then do:
                  buf_utd-lines.Quantity = vValDec * (if avail bar-code then bar-code.cli-base-rate else 1).
                  release buf_utd-lines.
               end.
            end.
            vValDec  = decimal(getAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity_old")) no-error.
            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity_old_new",string(vValDec * (if avail bar-code then bar-code.cli-base-rate else 1))).
            if     not VUcd
               and CheckMarkUtdLine(utd.db-num,utd.doc-id,utd-lines.LineNum)
            then
               vMarkingUtd = yes .
         end.
         if not VUcd
         then
            CheckQnty(utd.db-num, utd.doc-id, "loadUtd").
         find first ext-classif where ext-classif.classif-name  eq 'id_diadok_client':U
                                  and ext-classif.charkey_three eq utd.cli-FnsParticipantId
         no-lock no-error.
         if available ext-classif
         then
            assign
               vcli-type = ext-classif.CharKey_One
               vcli-code = ext-classif.Key#_One
            .
         else do:
            assign
              vcli-type = ?
              vcli-code = ?
            .
            AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoSuppForId",utd.cli-FnsParticipantId ).
         end.
         find first contract  where contract.host-code eq vhost-code
                                and contract.cli-type  eq vcli-type
                                and contract.cli-code  eq vcli-code
                                and contract.contract-prn-code eq Utd.BaseDocumentNumber
         no-lock no-error.
         define variable VContractEdo as logical no-undo init yes.
         if available contract
         then do:
            assign
               VContractEdo = contract.whole-send-news > 0
               vcontract-code = contract.contract-code
            .
            if not VContractEdo
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoEdoDoc", Utd.BaseDocumentNumber).
         end.
         else do:
            vcontract-code = ?.
         end.
      end.
      if not GetLastUTDinPackAft (utd.db-num, utd.doc-id, volddb-num, volddoc-id)
      then do:
         AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoLastDoc",string(utd.PackageId) + chr(4) + string(volddb-num) + chr(4) + string(volddoc-id)).
      end.
      define variable vdoc-code as character no-undo init ?.
      if utd.EDocType              eq objSrv:Env:Utd:EDocType:Ucd:KeyIntDB
      then do:
         find first utd_ret where utd_ret.parentDocumentExt     eq utd.parentDocumentExt
                              and utd_ret.parentOrganizationExt eq utd.parentOrganizationExt
                              and utd_ret.Timestamp             le utd.Timestamp
                              and utd_ret.EDocType              eq objSrv:Env:Utd:EDocType:returns:KeyIntDB
         no-lock no-error.
         if available utd_ret
         then do:
            vdoc-code = utd_ret.doc-code.
            CheckUcdForReturn(utd.db-num,utd.doc-id,utd_ret.db-num,utd_ret.doc-id).
         end.
      end.
   end.
   find current utd exclusive-lock no-error.
   if available utd
   then do:
      assign
         utd.cli-type      = vcli-type      when vcli-type      ne ?
         utd.cli-code      = vcli-code      when vcli-type      ne ?
         utd.host-code     = vhost-code     when vhost-code     ne ? and vhost-code     ne 0
         utd.contract-code = vcontract-code when vcontract-code ne ?
         utd.obj-type      = vobj-type      when vobj-type      ne ? and vobj-type      ne ""
         utd.obj-code      = vobj-code      when vobj-code      ne ? and vobj-code      ne 0
         utd.doc-code      = vdoc-code      when vdoc-code      ne ?
      .
      if   ( utd.contract-code eq ?
         or utd.contract-code eq 0)
         and not vucd
      then
         AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoContForFirmId",(if utd.host-code eq ? then "?" else string (utd.host-code)) + chr(4) +  utd.BaseDocumentNumber).
      if utd.host-code eq ?
         or utd.host-code eq 0
      then
         AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoFirmForId",if utd.obj-FnsParticipantId eq ? then "?" else utd.obj-FnsParticipantId ).
      if utd.obj-code eq ?
         or utd.obj-code eq 0
      then
         AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoShopForKpp",utd.obj-kpp).
   end.
   vError = GetErrForUtdstr(utd.db-num,utd.doc-id,"loadUtd").
   if vError eq ""
   then do:
      if utd.sts eq 0 or utd.sts eq ?
      then
         utd.sts = if VUcd
                   then ObjSrv:Env:Utd:Sts:th:ConfirmedUcd:KeyIntDB
                   else ObjSrv:Env:Utd:Sts:th:ReceivedFromSupplier:KeyIntDB.
      if utd.sts = ObjSrv:Env:Utd:Sts:th:LoadError:KeyIntDB
      then do:
         utd.sts = ObjSrv:Env:Utd:Sts:th:ReceivedFromSupplier:KeyIntDB.
      end.
      if     not VUcd
         and utd.sts = ObjSrv:Env:Utd:Sts:th:ReceivedFromSupplier:KeyIntDB
      then do:
         if not vMarkingUtd
         then
            utd.sts = objSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB.
      end.
   end.
   else do:
      if utd.sts ne ObjSrv:Env:Utd:Sts:th:CorrectionRequested:KeyIntDB
      then
         utd.sts = ObjSrv:Env:Utd:Sts:th:LoadError:KeyIntDB.
   end.
   if     utd.sts-edi  >= ObjSrv:Env:Utd:Sts:edi:StatChangLoanOnlyBeg
      and utd.sts-edi  <= ObjSrv:Env:Utd:Sts:edi:StatChangLoanOnlyEnd
   then
      utd.sts-edi = ?.
   else if     (not vMark and  not vucd) or not VContractEdo
           and utd.sts-edi < ObjSrv:Env:Utd:Sts:edi:StatChangLoanOnlyBeg
   then
      utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:AutoRejected:KeyIntDB.
   release utd no-error.
   if error-status:error
   then
      return error return-value.
   return vError.
end.
function ReCheckload returns logical
(idb-num as integer,
 idoc-id as integer,
 iload   as logical ):
   subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
   define buffer buf_c-utd for ub.c-utd .
   define buffer buf_utd   for ub.utd .
   find first buf_utd where buf_utd.db-num eq idb-num
                        and buf_utd.doc-id eq idoc-id
   exclusive-lock no-error.
   if available buf_utd
   then do:
      if    iload
         or buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:loaderror:KeyIntDB
      then do:
         SaturateAndCheckUTD(buf_utd.db-num, buf_utd.doc-id) no-error .
         if  error-status:error then
         do:
            message return-value view-as alert-box.
         end.
      end.
      if    buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:InconsistencyWithSupplyContract:KeyIntDB
         or buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:LinesInError:KeyIntDB
         or buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:DeliveryCodeMismatch:KeyIntDB
         or buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:LackOfMarkingCodesInCirculation:KeyIntDB
      then do:
         find last buf_c-utd no-lock where buf_c-utd.db-num eq buf_utd.db-num and
                                           buf_c-utd.doc-id eq buf_utd.doc-id and
                                           buf_c-utd.sts    eq buf_utd.sts and
                                           buf_c-utd.sts    eq ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB
         no-error .
         if available (buf_c-utd)
         then do:
            buf_utd.sts = buf_c-utd.sts .
            buf_utd.sts-edi = buf_c-utd.sts-edi .
         end.
         else do:
            if    buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:InconsistencyWithSupplyContract:KeyIntDB
               or buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:LinesInError:KeyIntDB
            then
               buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB .
            else
               buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB .
            buf_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:Verification:KeyIntDB .
         end.
      end.
      if buf_utd.sts = objSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB
      then do:
         run utl/utd-checkSpec.p (input buf_utd.db-num,
                                  input buf_utd.doc-id) .
      end.
   end.
   release buf_utd.
   unsubscribe "getNextseq".
end.
function ReCheck returns logical
(idb-num as integer,
 idoc-id as integer ):
   ReCheckload(idb-num,idoc-id,no).
end.
function GetLastUTDForPac returns logical
(iPackegeId as character ,
 iTimestamp as datetime,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   find last buf_utd where Buf_utd.PackageId eq iPackegeId
                             and Buf_utd.EDocType  eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                             and Buf_utd.Timestamp gt iTimestamp
   no-lock no-error.
   if available  buf_utd
   then
      assign
         odb-num = buf_utd.db-num
         odoc-id = buf_utd.doc-id
      no-error.
   else
      assign
         odb-num = ?
         odoc-id = ?
      no-error.
end.
function GetprevUTDForPac returns logical
(iPackegeId as character ,
 iTimestamp as datetime,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   find last buf_utd where Buf_utd.PackageId eq iPackegeId
                             and Buf_utd.EDocType  eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                             and Buf_utd.Timestamp < iTimestamp
   no-lock no-error.
   if available  buf_utd
   then
      assign
         odb-num = buf_utd.db-num
         odoc-id = buf_utd.doc-id
      no-error.
   else
      assign
         odb-num = ?
         odoc-id = ?
      no-error.
end.
function GetLastUTDinPackAft returns logical
(input idb-num as integer,
 input idoc-id as integer,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   define buffer     utd for utd.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if utd.PackageId eq ""
      then do:
         assign
            odb-num = utd.db-num
            odoc-id = utd.doc-id
         .
         return yes.
      end.
      else do:
         GetLastUTDForPac(utd.PackageId,utd.Timestamp,output odb-num,output odoc-id ).
         if    odb-num eq ?
            or odoc-id eq ?
         then do:
            assign
               odb-num = utd.db-num
               odoc-id = utd.doc-id
            .
            return yes.
         end.
         else
            return odoc-id = utd.doc-id.
      end.
   end.
   return ?.
end.
function GetLastUTDinPackbef returns logical
(input idb-num as integer,
 input idoc-id as integer,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   define buffer     utd for utd.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if utd.PackageId eq ""
      then do:
         assign
            odb-num = utd.db-num
            odoc-id = utd.doc-id
         .
         return yes.
      end.
      else do:
         GetprevUTDForPac(utd.PackageId,utd.Timestamp,output odb-num,output odoc-id ).
         if    odb-num eq ?
            or odoc-id eq ?
         then do:
            assign
               odb-num = utd.db-num
               odoc-id = utd.doc-id
            .
            return yes.
         end.
         else
            return odoc-id = utd.doc-id.
      end.
   end.
   return ?.
end.
function GetLastUTDinPack returns logical
(input idb-num as integer,
 input idoc-id as integer,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   define buffer     utd for utd.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if utd.PackageId eq ""
      then do:
         assign
            odb-num = utd.db-num
            odoc-id = utd.doc-id
         .
         return yes.
      end.
      else do:
         GetLastUTDForPac(utd.PackageId,datetime("01/01/1900"),output odb-num,output odoc-id ).
         if    odb-num eq ?
            or odoc-id eq ?
         then do:
            assign
               odb-num = utd.db-num
               odoc-id = utd.doc-id
            .
            return yes.
         end.
         else
            return odoc-id = utd.doc-id.
      end.
   end.
   return ?.
end.
function delMark returns logical
( buffer utd-marking-lines for utd-marking-lines ):
   define buffer buf_utd-marking-line for utd-marking-lines.
   for each marking where marking.mark-parent eq utd-marking-lines.mark no-lock:
      find first buf_utd-marking-line where buf_utd-marking-line.db-num    eq utd-marking-lines.db-num
                                        and buf_utd-marking-line.doc-id    eq utd-marking-lines.doc-id
                                        and buf_utd-marking-line.mark      eq marking.mark
      no-lock no-error.
      if available  buf_utd-marking-line
      then do:
         delMark(buffer buf_utd-marking-line).
         delete buf_utd-marking-line.
      end.
   end.
end.
function addMark returns logical
( buffer utd-marking-lines for utd-marking-lines ):
   define buffer buf_utd-marking-line for utd-marking-lines.
   define buffer par_utd-marking-line for utd-marking-lines.
   define buffer buf_utd for ub.utd .
   for each marking where marking.mark-parent eq utd-marking-lines.mark no-lock:
      find first buf_utd-marking-line where buf_utd-marking-line.db-num    eq utd-marking-lines.db-num
                                        and buf_utd-marking-line.doc-id    eq utd-marking-lines.doc-id
                                        and buf_utd-marking-line.mark      eq marking.mark
      no-lock no-error.
      if available  buf_utd-marking-line
      then do:
         if buf_utd-marking-line.doc-level ne utd-marking-lines.doc-level + 1
         then do:
            find current  buf_utd-marking-line exclusive-lock no-error.
            if available buf_utd-marking-line
            then
               buf_utd-marking-line.doc-level = utd-marking-lines.doc-level + 1.
         end.
      end.
      else do:
         find first buf_utd no-lock where buf_utd.db-num    eq utd-marking-lines.db-num
                                      and buf_utd.doc-id    eq utd-marking-lines.doc-id
                                      no-error .
         create buf_utd-marking-line.
         buffer-copy utd-marking-lines except doc-level mark sts gds-code to buf_utd-marking-line
         assign
            buf_utd-marking-line.doc-level = utd-marking-lines.doc-level + 1
            buf_utd-marking-line.mark      = marking.mark
            buf_utd-marking-line.gds-code  = marking.Gds-code
            buf_utd-marking-line.sts      = if (available buf_utd and buf_utd.EDocType = objSrv:Env:Utd:EDocType:Mark_Collect:KeyIntDB)
                                            then marking.sts
                                            else
                                            if can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(marking.sts)) or
                                               can-do(objSrv:Env:Marking:Sts:Mark:Doc_Status,string(marking.sts)) or
                                               marking.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB or
                                               marking.sts = objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB
                                             then objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
                                             else marking.sts
         .
         if  buf_utd-marking-line.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB then
         do:
           for first par_utd-marking-line no-lock where
                     par_utd-marking-line.db-num  = buf_utd-marking-line.db-num
                 and par_utd-marking-line.doc-id  = buf_utd-marking-line.doc-id
                 and par_utd-marking-line.LineNum = buf_utd-marking-line.LineNum
                 and par_utd-marking-line.mark    = marking.mark-parent
                 and par_utd-marking-line.sts     = objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
           :
             buf_utd-marking-line.sts = objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB.
           end.
         end.
      end.
      addMark(buffer buf_utd-marking-line).
   end.
end.
function UnLockUTDMarkbuf returns logical
(buffer old_utd for utd,
 iAll as logical ):
   define variable voldkey    as character no-undo.
      run gen-key-rec (input "utd",
                       input  buffer old_utd:handle,
                       output voldkey).
   for each marking where marking.loc-key eq voldkey
   exclusive-lock:
      if    iAll
         or (    marking.sts eq  ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
             and marking.sts eq  ObjSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB )
      then do:
         marking.loc-key = "".
         marking.sts =  ObjSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB.
      end.
   end.
end.
function UnLockUTDMark returns logical
(idb-num as integer ,idoc-id as integer ,iall as logical):
   define buffer old_utd for utd.
   find first old_utd where old_utd.db-num eq idb-num
                        and old_utd.db-num eq idoc-id
   no-lock no-error.
   if available old_utd
   then do:
      UnLockUTDMarkbuf(buffer old_utd,iall).
   end.
end.
function changSts returns logical
(idb-num as integer ,
 idoc-id as integer ,
 old_sts_edo as character ,
 new_sts_edo as character  ):
   if     old_sts_edo ne new_sts_edo
      and ( new_sts_edo eq "RevocationAccepted"
           or  new_sts_edo eq "RecipientSignatureRequestRejected"
           )
   then
      UnLockUTDMark(idb-num,idoc-id,yes).
   if     old_sts_edo ne new_sts_edo
      and ( new_sts_edo eq "WithRecipientSignature"
        or  new_sts_edo eq "WithRecipientPartiallySignature"
           )
   then
      UnLockUTDMark(idb-num,idoc-id,no).
end.
function SetLockUTDMark returns logical
(idb-num as integer ,idoc-id as integer ):
   define buffer new_utd for utd.
   define buffer old_utd for utd.
   define variable volddb-num as integer no-undo.
   define variable volddoc-id as integer no-undo.
   define variable voldkey    as character no-undo.
   define variable vnewkey    as character no-undo.
   find first new_utd where new_utd.db-num eq idb-num
                        and new_utd.doc-id eq idoc-id
   no-lock no-error.
   if not GetLastUTDinPack (new_utd.db-num,new_utd.doc-id,volddb-num,volddoc-id)
   then do trans:
      find first old_utd where old_utd.db-num eq volddb-num
                           and old_utd.doc-id eq volddoc-id
      no-lock no-error.
         run gen-key-rec (input "utd",
                          input  buffer new_utd:handle,
                          output vnewkey).
         run gen-key-rec (input "utd",
                          input  buffer old_utd:handle,
                          output voldkey).
      for each utd-marking-lines where utd-marking-lines.db-num eq new_utd.db-num
                                   and utd-marking-lines.doc-id eq new_utd.doc-id
      no-lock:
         find first marking where marking.mark eq utd-marking-lines.mark no-lock no-error.
         if available  marking
         then do:
            if    marking.loc-key eq ""
               or marking.loc-key eq ?
               or marking.loc-key eq voldkey
            then do:
               find current marking exclusive-lock no-error.
               if available marking
               then do:
                  marking.loc-key = vnewkey.
                  release marking.
               end.
            end.
            else if marking.loc-key ne vnewkey
            then do:
               addutderr(new_utd.db-num,new_utd.doc-id,buffer new_utd:handle,"LoadUtd","MarkLock",marking.mark + chr(4) + marking.loc-key).
            end.
         end.
      end.
      UnLockUTDMark(old_utd.db-num,old_utd.doc-id,yes).
   end.
end.
function CheckedocMark return logical
(input idb-numorig as integer,
 input idoc-idorig as integer,
 input idb-numedoc as integer,
 input idoc-idedoc as integer  ):
    define variable VChekOk    as logical   no-undo init yes.
    define variable vMarkUtd   as logical   no-undo.
    define variable v-par-type as character no-undo.
    define variable v-par-val  as character no-undo.
    define buffer buf_utd-attr      for utd-attr.
    define buffer buf_utd           for utd.
    define buffer utd-marking-lines for utd-marking-lines.
    define buffer utd-lines         for utd-lines.
    define buffer marking           for marking.
    define buffer edoc-lines        for utd-lines.
       for each utd-marking-lines where utd-marking-lines.db-num    eq idb-numorig
                                    and utd-marking-lines.doc-id    eq idoc-idorig
                                    and utd-marking-lines.doc-level eq 1
                                    and utd-marking-lines.sts       eq objSrv:Env:marking:Sts:Mark:Checked_:KeyIntDB
       no-lock:
          if    isMark (utd-marking-lines.mark)
          then do:
             create tt-utd-mark.
             buffer-copy utd-marking-lines to tt-utd-mark
             assign
                tt-utd-mark.side = "+"
             .
          end.
       end.
       for each utd-marking-lines where utd-marking-lines.db-num eq idb-numedoc
                                    and utd-marking-lines.doc-id eq idoc-idedoc
                                    and utd-marking-lines.doc-level eq 1
       no-lock:
          if    isMark (utd-marking-lines.mark)
          then do:
             find first tt-utd-mark where tt-utd-mark.mark eq utd-marking-lines.mark
             no-lock no-error.
             if available tt-utd-mark
             then
                tt-utd-mark.side = "".
             else do:
                create tt-utd-mark.
                buffer-copy utd-marking-lines to tt-utd-mark
                assign
                   tt-utd-mark.side = "-"
                .
             end.
          end.
       end.
       for each tt-utd-mark where  tt-utd-mark.side ne ""
       no-lock:
          AddUtdErrForTab(idb-numedoc, idoc-idedoc, "utd-marking-lines", buffer tt-utd-mark:handle, "edoc", "MarkOrig" + tt-utd-mark.side, tt-utd-mark.mark).
          VChekOk = no.
       end.
       for each utd-lines where utd-lines.db-num    eq idb-numorig
                            and utd-lines.doc-id    eq idoc-idorig
       no-lock:
          find first edoc-lines where edoc-lines.db-num eq idb-numedoc
                                  and edoc-lines.doc-id eq idoc-idedoc
                                  and edoc-lines.LineNum eq utd-lines.LineNum
          no-lock no-error.
          define variable VUtdlinequentity as decimal no-undo.
          VUtdlinequentity = dec (getattrutdlinesex(utd-lines.db-num ,utd-lines.doc-id,utd-lines.LineNum,"QuantityBarCode","0")).
          if     VUtdlinequentity eq ?
             or (if available edoc-lines then edoc-lines.Quantity else 0) ne VUtdlinequentity
          then
             AddUtdErr(idb-numedoc, idoc-idedoc,buffer edoc-lines:handle,"edoc","lineQnty",string(edoc-lines.LineNum ) + chr(4) + string(VUtdlinequentity) + chr(4) + string(edoc-lines.Quantity ) ).
       end.
    for each tt-utd-mark:
       delete tt-utd-mark.
    end.
end.
function CheckEdoc returns character
(idb-numOrig as integer ,
 idoc-idOrig as integer,
 idb-num as integer ,
 idoc-id as integer ):
   define buffer utd  for ub.utd.
   define buffer utd-lines  for ub.utd-lines.
   define buffer utd-marking-lines  for ub.utd-marking-lines.
   define buffer edoc-lines for ub.utd-lines.
   define variable vSts as integer no-undo.
   define variable vMarkutd as logical no-undo.
   vSts = objSrv:Env:utd:Sts:th:ReceivedFromSupplier:KeyIntDB.
   Block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   exclusive-lock:
      define variable ismarkin as logical no-undo.
      define variable isOAD as logical no-undo.
      define variable isper as logical no-undo.
      getMarkUtdLine(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,
           output ismarkin, output isOAD, output isper).
      if    utd-lines.Price                eq 0
         or utd-lines.Total                eq 0
         or utd-lines.TotalWithVatExcluded eq 0
         or utd-lines.Quantity             eq 0
      then do:
         for each utd-marking-lines where utd-marking-lines.db-num  eq utd-lines.db-num
                                      and utd-marking-lines.doc-id  eq utd-lines.doc-id
                                      and utd-marking-lines.linenum eq utd-lines.LineNum
         no-lock:
            if    isMark(utd-marking-lines.mark)
               or isOad(utd-marking-lines.mark)
            then do:
               AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,"Edoc","Amount" , string(utd-lines.LineNum )).
               next Block-line.
            end.
         end.
         delete utd-lines.
      end.
      else if   ( utd-lines.Total                ne 0
              or utd-lines.Quantity             ne 0)
              and ismarkin or isOAD
      then do:
         Block-mark:
         for each utd-marking-lines where utd-marking-lines.db-num  eq utd-lines.db-num
                                      and utd-marking-lines.doc-id  eq utd-lines.doc-id
                                      and utd-marking-lines.linenum eq utd-lines.LineNum
         no-lock:
            if  (isOAD and
                  isMark(utd-marking-lines.mark)
               or isOad(utd-marking-lines.mark) )
               or (ismarkin and
                  isMark(utd-marking-lines.mark))
            then do:
               leave Block-mark.
            end.
         end.
         if not available utd-marking-lines
         then
            AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,"Edoc","Mark" ,string(utd-lines.LineNum)).
      end.
   end.
   for each utd-lines where utd-lines.db-num eq idb-numOrig
                        and utd-lines.doc-id eq idoc-idOrig
   no-lock:
      find first edoc-lines where edoc-lines.db-num eq idb-num
                              and edoc-lines.doc-id eq idoc-id
                              and edoc-lines.LineNum eq utd-lines.LineNum
      no-lock no-error.
      if     available edoc-lines
      then do:
         if edoc-lines.Quantity ne 0
         then do:
            if edoc-lines.Price ne utd-lines.Price
            then
               AddUtdErr(edoc-lines.db-num,edoc-lines.doc-id,buffer edoc-lines:handle,"Edoc","Price" ,string(edoc-lines.LineNum)).
         end.
      end.
      vSts = objSrv:Env:utd:Sts:th:SignatureRequired:KeyIntDB.
      CheckedocMark(idb-numOrig , idoc-idOrig , idb-num , idoc-id).
   end.
   define variable vError as character no-undo.
   vError = GetErrForUtdstr(idb-num , idoc-id ,"edoc").
   if vError ne ""
   then
      vSts = objSrv:Env:utd:Sts:th:edocError:KeyIntDB.
   else
      vSts = objSrv:Env:utd:Sts:th:SignatureRequired:KeyIntDB.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   exclusive-lock no-error.
   if available utd
   then do:
      utd.sts = vsts.
   end.
end.
function CrEdoc returns character
(iPack as character ,
 iTimestamp as datetime):
   define variable vdb-num as integer no-undo.
   define variable vdoc-id as integer no-undo.
   define buffer utd  for ub.utd.
   define buffer edoc for ub.utd.
   define buffer utd_ret   for ub.utd.
   define buffer utd-attr  for ub.utd-attr.
   define buffer edoc-attr for ub.utd-attr.
   define buffer utd-lines  for ub.utd-lines.
   define buffer edoc-lines for ub.utd-lines.
   define buffer utd-lines-attr  for ub.utd-lines-attr.
   define buffer edoc-lines-attr for ub.utd-lines-attr.
   define buffer utd-marking-lines  for ub.utd-marking-lines.
   define buffer edoc-marking-lines for ub.utd-marking-lines.
   define buffer utd-marking-lines-attr for ub.utd-marking-lines-attr.
   define buffer edoc-marking-lines-attr for ub.utd-marking-lines-attr.
   define variable vTimestamp  as datetime no-undo.
   find last utd where utd.PackageId eq iPack
                   and utd.EDocType  eq objSrv:Env:Utd:EDocType:edoc:KeyIntDB
                   and utd.Timestamp ge iTimestamp
   no-lock no-error.
   if available utd
   then
      return "Есть документ позже".
   find last utd where utd.PackageId eq iPack
                   and utd.EDocType  eq objSrv:Env:Utd:EDocType:ucd:KeyIntDB
                   and utd.Timestamp le iTimestamp
   no-lock no-error.
   if not available utd
   then
      return "Не найден УКД".
   define variable vdb-numOrig as integer no-undo.
   define variable vdoc-idOrig as integer no-undo.
   find last utd where utd.PackageId eq iPack
                   and utd.EDocType  eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                   and utd.Timestamp le iTimestamp
   no-lock no-error.
   if available utd
   then do:
      subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
      MySeqUtd = ?.
      vTimestamp = utd.Timestamp.
      create edoc.
      vdb-num = utd.db-num.
      vdoc-id = utd.doc-id.
      buffer-copy utd except doc-id db-num DocumentExt OrganizationExt comment to edoc
      assign
         edoc.EDocType = objSrv:Env:Utd:EDocType:edoc:KeyIntDB
         edoc.Timestamp = iTimestamp + 1
         edoc.AmendmentRequested = no
         edoc.sts-edi  = objSrv:Env:Utd:sts:edi:WaitingForRecipientSignature:KeyIntDB
      .
      validate edoc.
      for each utd-attr where utd-attr.db-num eq vdb-num
                          and utd-attr.doc-id eq vdoc-id
                          and utd-attr.attr-code ne "ststhbeforeCorrection"
                          and utd-attr.attr-code ne "sendcode"
      no-lock:
         create edoc-attr.
         buffer-copy utd-attr except doc-id db-num to edoc-attr
         assign
            edoc-attr.db-num = edoc.db-num
            edoc-attr.doc-id = edoc.doc-id
         .
      end.
      for each utd-lines where utd-lines.db-num eq vdb-num
                           and utd-lines.doc-id eq vdoc-id
      no-lock:
         create edoc-lines.
         buffer-copy utd-lines except doc-id db-num to edoc-lines
         assign
            edoc-lines.db-num = edoc.db-num
            edoc-lines.doc-id = edoc.doc-id
         .
         release edoc-lines.
      end.
      for each utd-lines-attr where utd-lines-attr.db-num eq vdb-num
                                and utd-lines-attr.doc-id eq vdoc-id
      no-lock:
         create edoc-lines-attr.
         buffer-copy utd-lines-attr except doc-id db-num to edoc-lines-attr
         assign
            edoc-lines-attr.db-num = edoc.db-num
            edoc-lines-attr.doc-id = edoc.doc-id
         .
      end.
      for each utd-marking-lines where utd-marking-lines.db-num eq vdb-num
                                   and utd-marking-lines.doc-id eq vdoc-id
                                   and utd-marking-lines.doc-level eq 1
      no-lock:
         create edoc-marking-lines.
         buffer-copy utd-marking-lines except doc-id db-num to edoc-marking-lines
         assign
            edoc-marking-lines.db-num = edoc.db-num
            edoc-marking-lines.doc-id = edoc.doc-id
         .
      end.
      for each utd-marking-lines-attr where utd-marking-lines-attr.db-num eq vdb-num
                                        and utd-marking-lines-attr.doc-id eq vdoc-id
      no-lock:
         if utd-marking-lines-attr.attr-code eq "box-qnty"
         then do:
             find first edoc-marking-lines-attr  where edoc-marking-lines-attr.db-num    eq utd-marking-lines-attr.db-num
                                                   and edoc-marking-lines-attr.doc-id    eq utd-marking-lines-attr.doc-id
                                                   and edoc-marking-lines-attr.LineNum   eq utd-marking-lines-attr.LineNum
                                                   and edoc-marking-lines-attr.mark      eq utd-marking-lines-attr.mark
                                                   and edoc-marking-lines-attr.attr-code eq utd-marking-lines-attr.attr-code
             no-lock no-error.
         end.
         if not avail edoc-marking-lines-attr
         then do:
             create edoc-marking-lines-attr.
             buffer-copy utd-marking-lines-attr except doc-id db-num to edoc-marking-lines-attr
             assign
                edoc-marking-lines-attr.db-num = vdb-num
                edoc-marking-lines-attr.doc-id = vdoc-id
             .
         end.
         release edoc-marking-lines-attr.
      end.
      for each utd where utd.PackageId eq iPack
                     and utd.EDocType  eq objSrv:Env:Utd:EDocType:Ucd:KeyIntDB
                     and utd.Timestamp gt vTimestamp
                     and utd.Timestamp le iTimestamp
                     and (    utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:WaitingForRecipientSignature:KeyIntDB
                          or  utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:sendRecipient:KeyIntDB
                          or  utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:WithRecipientSignature:KeyIntDB
                          or  utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:WithRecipientPartiallySignature:KeyIntDB
                          or  utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:HaveToCreateReceipt:KeyIntDB
                          or  utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:Verification:KeyIntDB)
      no-lock by utd.PackageId by utd.EDocType by utd.Timestamp:
         edoc.Total = edoc.Total + utd.total.
         edoc.Vat = edoc.Vat + utd.Vat.
         edoc.DocumentDate = utd.DocumentDate.
         edoc.Timestamp = utd.Timestamp + 1.
         for each utd-lines where utd-lines.db-num     = utd.db-num
                              and utd-lines.doc-id     = utd.doc-id
         no-lock:
            block-mark:
            for each utd-marking-lines where utd-marking-lines.db-num eq utd-lines.db-num
                                         and utd-marking-lines.doc-id eq utd-lines.doc-id
                                         and utd-marking-lines.LineNum eq utd-lines.LineNum
                                         and utd-marking-lines.site eq "-"
                                         no-lock:
               if isOAD(utd-marking-lines.mark)
               then do:
                  define variable VOAD as character no-undo.
                  VOAD = "02" + getGtinByDM(utd-marking-lines.mark) + "37".
                  find first edoc-marking-lines where edoc-marking-lines.db-num eq edoc.db-num
                                               and edoc-marking-lines.doc-id eq edoc.doc-id
                                               and edoc-marking-lines.mark   begins VOAD
                  no-lock no-error.
               end.
               else
                  find first edoc-marking-lines where edoc-marking-lines.db-num eq edoc.db-num
                                                  and edoc-marking-lines.doc-id eq edoc.doc-id
                                                  and edoc-marking-lines.mark   eq utd-marking-lines.mark
                     no-lock no-error.
               if available edoc-marking-lines
               then do:
                  find first edoc-lines where edoc-lines.db-num      = edoc-marking-lines.db-num
                                    and edoc-lines.doc-id            = edoc-marking-lines.doc-id
                                    and edoc-lines.LineNum           = edoc-marking-lines.LineNum
                  exclusive-lock no-error.
                  leave block-mark.
               end.
            end.
            if not available edoc-lines
            then
               find first edoc-lines where edoc-lines.db-num      = edoc.db-num
                                       and edoc-lines.doc-id      = edoc.doc-id
                                       and edoc-lines.ProductCode = utd-lines.ProductCode
               exclusive-lock no-error.
            if not available edoc-lines
            then do:
               find last edoc-lines where edoc-lines.db-num      = edoc.db-num
                                      and edoc-lines.doc-id      = edoc.doc-id
               no-lock no-error.
               define variable vline as integer no-undo.
               vline = if available edoc-lines then edoc-lines.linenum + 1 else 1.
               create edoc-lines.
               buffer-copy utd-lines except doc-id db-num linenum to edoc-lines
               assign
                  edoc-lines.db-num = edoc.db-num
                  edoc-lines.doc-id = edoc.doc-id
                  edoc-lines.linenum = vline
               .
            end.
            else
               assign
                  edoc-lines.Vat       = dec(getattrUtdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"Vat_old") )       + utd-lines.Vat
                  edoc-lines.Total     = dec(getattrUtdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"Total_old") )     + utd-lines.Total
                  edoc-lines.Quantity  = dec(getattrUtdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"Quantity_old_new") )  + utd-lines.Quantity.
                  edoc-lines.TotalWithVatExcluded = edoc-lines.Total - edoc-lines.Vat.
               .
            define variable Vqnty as decimal no-undo.
            Vqnty = dec(getattrUtdlines(edoc-lines.db-num,edoc-lines.doc-id,edoc-lines.LineNum,"Quantity") )
                  + dec(getattrUtdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"Quantity") ).
            setattrUtdlines(edoc-lines.db-num,edoc-lines.doc-id,edoc-lines.LineNum,"Quantity",string(vqnty)).
            if     getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old") ne ?
               and edoc-lines.UnitCode ne getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old")
            then
               AddUtdErr(edoc.db-num,edoc.doc-id,buffer edoc-lines:handle,
                   "loadUtd",
                   "UcdUnitChangForUtd",
                   string(edoc-lines.LineNum )                  + chr(4) +
                   edoc-lines.UnitCode                   + chr(4) +
                   getattrutdlinesex(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old","?")).
            if     utd-lines.UnitCode ne ?
               and utd-lines.UnitCode ne ""
               and utd-lines.UnitCode ne getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old")
            then
               AddUtdErr(edoc.db-num,edoc.doc-id,buffer edoc-lines:handle,
                      "loadUtd",
                      "UcdUnitChang",
                      string(edoc-lines.LineNum )                  + chr(4) +
                      utd-lines.UnitCode                          + chr(4) +
                      getattrutdlinesex(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old","?")).
            for each utd-marking-lines where utd-marking-lines.db-num eq utd-lines.db-num
                                         and utd-marking-lines.doc-id eq utd-lines.doc-id
                                         and utd-marking-lines.LineNum eq utd-lines.LineNum
            no-lock by utd-marking-lines.site by utd-marking-lines.doc-level desc:
               if utd-marking-lines.site eq "-"
               then do:
                  if isOAD(utd-marking-lines.mark)
                  then do:
                     VOAD = "02" + getGtinByDM(utd-marking-lines.mark) + "37".
                     find first edoc-marking-lines where edoc-marking-lines.db-num eq edoc-lines.db-num
                                                     and edoc-marking-lines.doc-id eq edoc-lines.doc-id
                                                     and edoc-marking-lines.mark   eq utd-marking-lines.mark
                     exclusive-lock no-error.
                     if not available edoc-marking-lines
                     then
                        find first edoc-marking-lines where edoc-marking-lines.db-num eq edoc.db-num
                                                     and edoc-marking-lines.doc-id eq edoc.doc-id
                                                     and edoc-marking-lines.mark   begins VOAD
                        exclusive-lock no-error.
                     if not available edoc-marking-lines
                     then
                        AddUtdErr(edoc.db-num,edoc.doc-id,buffer edoc-lines:handle,"edoc","Mark" + utd-marking-lines.site,utd-marking-lines.mark).
                     else do:
                        define variable v37tegdoc as character no-undo.
                        define variable v37tegedoc as character no-undo.
                        v37tegdoc  = GetTegCod( utd-marking-lines.mark,"37").
                        v37tegedoc = GetTegCod(edoc-marking-lines.mark,"37").
                        vqnty = int(v37tegedoc) - int(v37tegdoc) no-error.
                        if error-status:error
                        then
                           message "беда с маркой" skip edoc-marking-lines.mark skip utd-marking-lines.mark
                           view-as alert-box.
                        else if vqnty = 0
                        then
                           delete edoc-marking-lines.
                        else do:
                           edoc-marking-lines.mark  = VOAD + string(vqnty).
                           setAttrUtdMarkingLines (edoc-marking-lines.db-num,
                                          edoc-marking-lines.doc-id,
                                          edoc-marking-lines.LineNum,
                                          edoc-marking-lines.mark,
                                          "box-qnty",
                                           string(vQnty)).
                        end.
                     end.
                  end.
                  else do:
                     find first edoc-marking-lines where edoc-marking-lines.db-num eq edoc-lines.db-num
                                                     and edoc-marking-lines.doc-id eq edoc-lines.doc-id
                                                     and edoc-marking-lines.mark   eq utd-marking-lines.mark
                     exclusive-lock no-error.
                     if available edoc-marking-lines
                     then
                        delete edoc-marking-lines.
                     else
                        AddUtdErr(edoc.db-num,edoc.doc-id,buffer edoc-lines:handle,"edoc","Mark" + utd-marking-lines.site,utd-marking-lines.mark).
                  end.
               end.
               else if utd-marking-lines.site eq "+"
               then do:
                  if isOAD(utd-marking-lines.mark)
                  then do:
                     VOAD = "02" + getGtinByDM(utd-marking-lines.mark) + "37".
                     find first edoc-marking-lines where edoc-marking-lines.db-num eq edoc.db-num
                                                  and edoc-marking-lines.doc-id eq edoc.doc-id
                                                  and edoc-marking-lines.mark   begins VOAD
                     exclusive-lock no-error.
                     if available edoc-marking-lines
                     then do:
                        v37tegdoc  = GetTegCod( utd-marking-lines.mark,"37").
                        v37tegedoc = GetTegCod(edoc-marking-lines.mark,"37").
                        vqnty = int(v37tegedoc) + int(v37tegdoc) no-error.
                        if error-status:error
                        then
                           message "беда с маркой" skip edoc-marking-lines.mark skip utd-marking-lines.mark
                           view-as alert-box.
                        else if vqnty = 0
                        then
                           delete edoc-marking-lines.
                        else do:
                           edoc-marking-lines.mark  = VOAD + string(vqnty).
                           setAttrUtdMarkingLines (edoc-marking-lines.db-num,
                                          edoc-marking-lines.doc-id,
                                          edoc-marking-lines.LineNum,
                                          edoc-marking-lines.mark,
                                          "box-qnty",
                                           string(vQnty)).
                        end.
                     end.
                     else do:
                        create edoc-marking-lines.
                        buffer-copy utd-marking-lines except doc-id db-num to edoc-marking-lines
                        assign
                           edoc-marking-lines.db-num = edoc.db-num
                           edoc-marking-lines.doc-id = edoc.doc-id
                        .
                        setAttrUtdMarkingLines (edoc-marking-lines.db-num,
                                          edoc-marking-lines.doc-id,
                                          edoc-marking-lines.LineNum,
                                          edoc-marking-lines.mark,
                                          "box-qnty",
                                           string(int(GetTegCod(edoc-marking-lines.mark,"37")))) no-error.
                     end.
                  end.
                  else do:
                  find first edoc-marking-lines where edoc-marking-lines.db-num eq edoc-lines.db-num
                                                  and edoc-marking-lines.doc-id eq edoc-lines.doc-id
                                                  and edoc-marking-lines.mark   eq utd-marking-lines.mark
                  no-lock no-error.
                  if not available edoc-marking-lines
                  then do:
                     create edoc-marking-lines.
                     buffer-copy utd-marking-lines except doc-id db-num linenum to edoc-marking-lines
                     assign
                        edoc-marking-lines.db-num  = edoc-lines.db-num
                        edoc-marking-lines.doc-id  = edoc-lines.doc-id
                        edoc-marking-lines.linenum = edoc-lines.linenum
                     .
                  end.
                  else
                     AddUtdErr(edoc.db-num,edoc.doc-id,buffer edoc-lines:handle,"Edoc","Mark" + utd-marking-lines.site,utd-marking-lines.mark).
               end.
            end.
            release edoc-lines.
         end.
         release edoc-lines.
      end.
      find first utd_ret where utd_ret.parentDocumentExt     eq utd.parentDocumentExt
                              and utd_ret.parentOrganizationExt eq utd.parentOrganizationExt
                              and utd_ret.Timestamp             le utd.Timestamp
                              and utd_ret.EDocType              eq objSrv:Env:Utd:EDocType:returns:KeyIntDB
         no-lock no-error.
      if not avail utd_ret
      then
         CheckEdoc (vdb-num,vdoc-id,edoc.db-num,edoc.doc-id) .
   end.
   for each utd where utd.PackageId eq iPack
                     and utd.EDocType  eq objSrv:Env:Utd:EDocType:edoc:KeyIntDB
                     and utd.Timestamp < iTimestamp
      exclusive-lock:
         utd.sts-edi = objSrv:Env:Utd:sts:edi:Changed:KeyIntDB.
         utd.sts     = objSrv:Env:Utd:sts:th:Rejection:KeyIntDB.
      end.
      unsubscribe "getNextseq".
   end.
end.
define variable Mext-sys as integer no-undo init ?.
define variable mdb-num-local as integer no-undo.
run gbl/getdbnum.p (output mdb-num-local).
function  getExtSys returns integer
():
   define buffer ext-system      for ext-system.
   define buffer ext-system-attr for ext-system-attr.
   Mext-sys = ?.
   block-sys-obj:
   for each ext-system where ext-system.esys-type eq 12
                         and ext-system.db-num    eq mdb-num-local
   no-lock:
       find first ext-system-attr where ext-system-attr.db-num  eq ext-system.db-num
                                    and ext-system-attr.esys-id eq ext-system.esys-id
                                    and ext-system-attr.esya-attr-code eq 'obj':U
       no-lock no-error.
       if     available ext-system-attr
          and           ext-system-attr.esya-attr-value eq v-cntxt-obj-type + string(v-cntxt-obj-code)
       then do:
          Mext-sys = ext-system-attr.esys-id.
          leave block-sys-obj.
       end.
   end.
   if Mext-sys eq ?
   then do:
      block-sys-host:
      for each ext-system where ext-system.esys-type eq 12
                            and ext-system.db-num    eq mdb-num-local
      no-lock:
          find first ext-system-attr where ext-system-attr.db-num  eq ext-system.db-num
                                       and ext-system-attr.esys-id eq ext-system.esys-id
                                       and ext-system-attr.esya-attr-code eq 'host-code':U
          no-lock no-error.
          if     available ext-system-attr
             and           ext-system-attr.esya-attr-value eq string(v-cntxt-host-code-obj)
          then do:
             Mext-sys = ext-system-attr.esys-id.
             leave block-sys-host.
          end.
      end.
   end.
   return Mext-sys.
end.
function  getExtAttr returns character
(input icode as character ):
   define variable oValue as character no-undo.
   define variable vtype as character no-undo.
   define buffer ext-system for ext-system.
   get-key-value section "ProxyServ" key icode value oValue.
   if oValue eq ?
   then do:
      if Mext-sys eq ?
      then
         getExtSys ().
      find first ext-system no-lock where ext-system.db-num  eq mdb-num-local
                                      and ext-system.esys-id eq Mext-sys no-error.
      if available ext-system
      then do:
             if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-value in g#attr-lib
         (ext-system.esys-id,
          mdb-num-local,
          icode,
          output oValue,
          output vtype) no-error.
       end.
   end.
   return if oValue eq ? then "" else oValue .
end.
function  SetExtAttr returns character
(input icode   as character,
 input iValue  as character):
   define variable vtype as character no-undo.
   define buffer ext-system for ext-system.
   if Mext-sys eq ?
   then
      getExtSys ().
   find first ext-system no-lock where ext-system.db-num  eq mdb-num-local
                                   and ext-system.esys-id eq Mext-sys no-error.
   if available ext-system
   then do:
       if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-write in g#attr-lib
      (ext-system.esys-id,
       mdb-num-local,
       icode,
       iValue) no-error.
    end.
end.
define stream File-stream.
function PutMes returns character
(idext as character ):
   if valid-handle(mPublishHand)
   then
      publish "WriteLogAsunc" from mPublishHand (idext,yes).
   else do:
      if idext begins "error"
      then do:
         message substring (idext,6)
            view-as alert-box.
         if mDiadocApi ne ?
         then
            idext = substitute ("&1 (&2)",idext , mDiadocApi:GetFullVersion())no-error.
      end.
      output stream File-stream to "diadoc_user.log" append.
      put stream File-stream unformatted now " " idext skip.
      output stream File-stream close.
   end.
end.
function PutErr returns character
(idext as character ):
   define variable vi as integer no-undo.
   define variable vnumerr as integer no-undo.
   define variable vtext as character extent 25 no-undo .
   if error-status:num-messages > 0 then do:
      vnumerr = error-status:num-messages.
      vnumerr = min(vnumerr,extent(vtext)).
      do vi = 1 to vnumerr:
         vtext[vi] = error-status:get-message(vi).
      end.
      idext = idext + chr(10) + "Ошибка: [":U.
      do vi = 1 to vnumerr:
         idext = idext + chr(10) + vtext[vi] no-error.
      end.
      idext = idext +  chr(10) +  " ]" no-error.
      if not  idext begins "Error"
      then
         idext = "Error " + idext.
      PutMes(idext).
   end.
end.
function PutStat returns character
(itext as character,
 iflag as logical):
   if valid-handle(mPublishHand)
   then
      publish "PutStatAsunc" from mPublishHand (itext,iflag).
   PutMes(itext).
end.
function chekStop returns logical
( ):
   define variable oStop as logical no-undo.
   if valid-handle(mPublishHand)
   then
      publish "StopProc" from mPublishHand (output oStop).
   return oStop.
end.
function  putloggetdesc returns logical
(is1 as character ,is2 as character ,
is3 as character ):
end.
function  getdesc returns logical
(input iObj as component-handle):
   if iObj eq ? then return false.
   if mdebug
   then do:
   output stream File-stream to "diadoc_load.txt" append.
   define variable vReflector as component-handle no-undo.
   define variable vDescobj  as component-handle no-undo.
   define variable vPropertyNames  as component-handle no-undo.
   define variable vMethodsNames as component-handle no-undo.
   define variable vMethodDesc as component-handle no-undo.
   define variable vMethodsName as character  no-undo.
   define variable vPropertyValue as char no-undo.
   create "Diadoc.Reflector" vReflector.
   vDescobj = vReflector:Describe(iObj).
  put   stream File-stream  unformatted skip (1)
   "------------------------------------------" skip
   vDescobj:GetInterfaceName() skip.
   define variable vPropertyName as character no-undo.
   define variable vPropertyType as character no-undo.
   .
   putloggetdesc(vDescobj:GetInterfaceName(),"","").
   putloggetdesc("property","","").
   define variable vi as integer no-undo.
   define variable vii as integer no-undo.
  put stream File-stream  unformatted skip "property" skip.
  vPropertyNames = vDescobj:GetPropertiesNames().
   vi= vPropertyNames:count.
   do vi= 1 to vPropertyNames:count :
      vPropertyName = "".
      vPropertyType = "".
      vPropertyValue = "".
      vPropertyName  = vPropertyNames:GetItem(vi - 1) no-error.
      vPropertyType  = vDescobj:GetPropertyType(vPropertyName) no-error .
      vPropertyValue = substring((vDescobj:GetProperty(vPropertyName)),1,4000) no-error.
      putloggetdesc(vPropertyName,vPropertyType,vPropertyValue).
     put stream File-stream  unformatted vPropertyName " " vPropertyType  " " vPropertyValue skip.
   end.
   release object vPropertyNames.
   put stream File-stream  unformatted skip "method" skip.
   vMethodsNames = vDescobj:GetMethodsNames().
   vi = vMethodsNames:count.
   do vi = 1 to vMethodsNames:count :
      vMethodsName = "".
      vMethodsName = vMethodsNames:GetItem(vi - 1)no-error.
      vMethodDesc  = vDescobj:GetMethodDesc(vMethodsName)no-error.
      putloggetdesc("method",vMethodsName, vMethodDesc:RetVal).
      put stream File-stream  unformatted vMethodsName  " retval " vMethodDesc:RetVal skip.
      do vii  = 1 to vMethodDesc:args:count:
         define variable varg as character no-undo.
         varg = "".
         varg = vMethodDesc:args:GetItem(vii - 1) no-error.
         put stream File-stream  unformatted " args " varg  skip .
         putloggetdesc(" args ",varg, "").
      end.
      release object vMethodDesc.
   end.
   release object vMethodsNames.
   put stream File-stream  unformatted "end---------------------------------------" skip.
   output stream File-stream close.
   release object vDescobj.
   release object vReflector.
   end.
   return true.
end.
function getxsddocum returns logical
(iOrganization as component-handle):
   if iOrganization eq ? then return false.
   define variable vDocumentTypes as component-handle no-undo.
   define variable vDocumentType as component-handle no-undo.
   define variable vFunctions as component-handle no-undo.
   define variable vFunction as component-handle no-undo.
   define variable vVersions as component-handle no-undo.
   define variable vVersion as component-handle no-undo.
   define variable vTitles as component-handle no-undo.
   define variable vTitle as component-handle no-undo.
   define variable vi as integer no-undo.
   define variable vii as integer no-undo.
   define variable viii as integer no-undo.
   define variable viiii as integer no-undo.
   if mdebug
   then do:
   output stream File-stream to "diadoc_doc.txt" append.
   vDocumentTypes = iOrganization:GetDocumentTypes().
   do vi =1 to vDocumentTypes:count:
      vDocumentType = vDocumentTypes:GetItem(vi - 1).
      put stream File-stream  unformatted "DocumentType -> NAme " vDocumentType:name skip.
      put stream File-stream  unformatted "DocumentType -> Title " vDocumentType:Title skip.
      vFunctions = vDocumentType:Functions.
      do vii =1 to vFunctions:count:
         vFunction = vFunctions:GetItem(vii - 1 ).
         put stream File-stream  unformatted "DocumentType -> Function -> NAme " vFunction:name skip.
         vVersions = vFunction:Versions.
         do viii =1 to vVersions:count:
            vVersion = vVersions:GetItem(viii - 1 ).
            put stream File-stream  unformatted "DocumentType -> Function -> Version -> version " vVersion:version skip.
            put stream File-stream  unformatted "DocumentType -> Function -> Version -> IsActual " vVersion:IsActual skip.
            vTitles  = vVersion:Titles.
            do viiii =1 to vTitles:count:
               vTitle = vTitles:GetItem(viiii - 1 ).
               put stream File-stream  unformatted "DocumentType -> Function -> Version -> Title -> IsFormal " vTitle:IsFormal skip.
               put stream File-stream  unformatted "DocumentType -> Function -> Version -> Title -> XsdUrl " vTitle:XsdUrl skip.
               put stream File-stream  unformatted "DocumentType -> Function -> Version -> Title -> HaveUserDataXSD " vTitle:HaveUserDataXSD skip.
               put stream File-stream  unformatted "DocumentType -> Function -> Version -> Title -> type " vTitle:type skip.
               release object vTitle.
            end.
           release object vTitles.
            release object vVersion.
         end.
         release object vVersions.
         release object vFunction.
      end.
      release object vFunctions.
      release object vDocumentType.
   end.
   release object vDocumentTypes.
   put stream File-stream  unformatted "--------------------------------------------------- " skip.
  output stream File-stream close.
  end.
   return true.
end.
function GetDocTitleType returns character
(iOrganizationGuid as character ,
itype as character ,
ifunction as character,
iversion as character
):
   if iOrganizationGuid eq ? then return "".
   define variable vOrganization  as component-handle no-undo.
   define variable vDocumentTypes as component-handle no-undo.
   define variable vDocumentType  as component-handle no-undo.
   define variable vFunctions     as component-handle no-undo.
   define variable vFunction      as component-handle no-undo.
   define variable vVersions      as component-handle no-undo.
   define variable vVersion       as component-handle no-undo.
   define variable vTitles        as component-handle no-undo.
   define variable vTitle         as component-handle no-undo.
   define variable vi             as integer no-undo.
   define variable vii            as integer no-undo.
   define variable viii           as integer no-undo.
   define variable viiii          as integer no-undo.
   define variable oTitleType as character no-undo.
   vOrganization = mDiadocConnection:GetOrganizationById(iOrganizationGuid) no-error.
   if vOrganization eq ? then return "".
   vDocumentTypes = vOrganization:GetDocumentTypes().
   do vi =1 to vDocumentTypes:count:
      vDocumentType = vDocumentTypes:GetItem(vi - 1).
      if vDocumentType:name eq iType
      then do:
         vFunctions = vDocumentType:Functions.
         do vii =1 to vFunctions:count:
            vFunction = vFunctions:GetItem(vii - 1 ).
            if vFunction:name eq ifunction
            then do:
               vVersions = vFunction:Versions.
               do viii =1 to vVersions:count:
                  vVersion = vVersions:GetItem(viii - 1 ).
                  if vVersion:version eq iversion
                  then do:
                     vTitles  = vVersion:Titles.
                     do viiii =1 to vTitles:count:
                        vTitle = vTitles:GetItem(viiii - 1 ).
                        oTitleType = oTitleType + "," + vTitle:type.
                        release object vTitle.
                     end.
                     release object vTitles.
                  end.
                  release object vVersion.
               end.
               release object vVersions.
            end.
            release object vFunction.
         end.
         release object vFunctions.
      end.
      release object vDocumentType.
   end.
   release object vDocumentTypes.
   release object vOrganization.
   return left-trim(oTitleType,",").
end.
define temp-table tt-type no-undo
          field id as char
          field name as character
          index pi id .
define temp-table tt-Class no-undo like tt-type.
function crcode returns character
():
   define variable vtypelist as character no-undo.
   define variable vtypename as character no-undo.
   define variable vi as integer no-undo.
   vtypelist =
              "UniversalTransferDocument|"
             + "UniversalTransferDocumentRevision|"
             + "UniversalCorrectionDocument|"
             + "UniversalCorrectionDocumentRevision"
             .
   vtypename =
              "УПД|"
             + "Исправление УПД|"
             + "УКД|"
             + "Исправление УКД"
             .
   do vi = 1 to num-entries(vtypelist,"|"):
      create tt-type.
      assign
         tt-type.id   =  entry(vi,vtypelist,"|")
         tt-type.name =  entry(vi,vtypename,"|")
      .
   end.
   vtypelist = "Inbound|"
             + "Outbound|"
             + "Proxy".
   vtypename = "входящий документ|"
             + "исходящий документ|"
             + "документ, переданный через промежуточного получателя|".
   do vi = 1 to num-entries(vtypelist,"|"):
      create tt-Class.
      assign
         tt-Class.id   =  entry(vi,vtypelist,"|")
         tt-Class.name =  entry(vi,vtypename,"|")
      .
   end.
end.
crcode().
function getOrganizationInfo returns character
(input iContAgent as component-handle,
                                                output oinn as character,
                                                output oKpp as character,
                                                output oFnsParticipantId as character,
                                                output oOrgName as character,
                                                output oAdditionalInfo as character,
                                                output OarddrRus as character
                                                 ):
   define variable vi as integer no-undo.
   define variable vContAgentOrganizationDetails   as component-handle no-undo.
   define variable vAddrRus                        as component-handle no-undo.
   if iContAgent ne ?
   then do:
      getdesc(iContAgent).
      vContAgentOrganizationDetails = iContAgent:OrganizationDetails.
      oinn = vContAgentOrganizationDetails:Inn.
      oKpp = vContAgentOrganizationDetails:Kpp.
      oFnsParticipantId = vContAgentOrganizationDetails:FnsParticipantId.
      oAdditionalInfo = vContAgentOrganizationDetails:OrganizationAdditionalInfo.
      getdesc(vContAgentOrganizationDetails).
      oOrgName = vContAgentOrganizationDetails:OrgName.
      getdesc(vContAgentOrganizationDetails:Address).
      vAddrRus = vContAgentOrganizationDetails:Address:RussianAddress.
      getdesc(vAddrRus ).
      if vAddrRus ne ?
      then do:
         if vAddrRus:ZipCode ne ""
         then
            OarddrRus = OarddrRus + " " + vAddrRus:ZipCode.
         if vAddrRus:Region ne ""
         then
            OarddrRus = OarddrRus + " Регион: " + vAddrRus:Region.
         if vAddrRus:Territory ne ""
         then
            OarddrRus = OarddrRus + " Область: " + vAddrRus:Territory.
         if vAddrRus:City ne ""
         then
            OarddrRus = OarddrRus + " Город: " + vAddrRus:City.
         if vAddrRus:Locality ne ""
         then
            OarddrRus = OarddrRus + " Район: " + vAddrRus:Locality.
         if vAddrRus:Street ne ""
         then
            OarddrRus = OarddrRus + " Улица: " + vAddrRus:Street.
         if vAddrRus:Block ne ""
         then
            OarddrRus = OarddrRus + " Стр: " + vAddrRus:Block.
         if vAddrRus:Building ne ""
         then
            OarddrRus = OarddrRus + " Дом: " + vAddrRus:Building.
         if vAddrRus:Apartment ne ""
         then
            OarddrRus = OarddrRus + " Квартира: " + vAddrRus:Apartment.
      end.
      release object vAddrRus.
      release object vContAgentOrganizationDetails.
   end.
end.
function ConectByCertif return component-handle
(iThumbprint as character ):
  if mDiadocApi eq ? then return ?.
  if iThumbprint eq ""
  then do:
     release object mDiadocConnection no-error.
     return ?.
  end.
   mDiadocApi:ApiClientId =  getextAttr('diadoc-key':U).
   mDiadocApi:ServerUrl   =  getextAttr('server-addr':U).
   define variable vSSl as character no-undo.
   vSSl =  getextAttr('diadoc-ssl':U).
   if vSSl ne ""
      and logical(vSSl)
   then
      mDiadocApi:VerifySslCertificate = no.
   if mDiadocApi:ApiClientId eq ""
      or  mDiadocApi:ServerUrl eq ""
   then do:
     message "Не задан адрес сервера или ключ разработчика для внешей системы Диадок"
     view-as alert-box.
     release object mDiadocConnection no-error.
     return ?.
  end.
  define variable VProxy as character no-undo.
   vProxy =  getextAttr('proxy-addr':U).
   if     vProxy ne ""
      and vProxy ne ?
   then do:
      mDiadocApi:ProxyMode =  "UseProxy".
      mDiadocApi:ProxySettings:Url = vProxy.
      mDiadocApi:ProxySettings:Login    = getextAttr('proxy-login':U).
      mDiadocApi:ProxySettings:Password = getextAttr('proxy-pswd':U).
   end.
   define variable vtest as component-handle no-undo.
   vtest = mDiadocApi:TestConnection2().
   if not vtest:ConnectionSuccess
   then do:
      PutMes(vtest:ErrorText).
   end.
   else
      mDiadocConnection = mDiadocApi:CreateConnectionByCertificate(iThumbprint,"") no-error.
   if mDiadocConnection eq ?
   then
      PutErr("DiadocApi:CreateConnectionByCertificate:").
   release object vtest.
   return mDiadocConnection.
end.
function ConectByLogin return component-handle
():
   define variable vSSl as character no-undo.
   if mDiadocApi eq ? then return ?.
   mDiadocApi:ApiClientId = getextAttr('diadoc-key':U).
   mDiadocApi:ServerUrl   = getextAttr('server-addr':U).
   if mDiadocApi:ApiClientId eq ""
      or  mDiadocApi:ServerUrl eq ""
   then do:
     PutMes( "Error Не задан адрес сервера или ключ разработчика для внешей системы Диадок").
     release object mDiadocConnection no-error.
     return ?.
  end.
  vSSl =  getextAttr('diadoc-ssl':U).
  if vSSl ne ""
     and logical(vSSl)
  then
      mDiadocApi:VerifySslCertificate = no.
  define variable VProxy as character no-undo.
   vProxy =  getextAttr('proxy-addr':U).
   if     vProxy ne ""
      and vProxy ne ?
   then do:
      mDiadocApi:ProxyMode =  "UseProxy".
      mDiadocApi:ProxySettings:Url = vProxy.
      mDiadocApi:ProxySettings:Login    = getextAttr('proxy-login':U).
      mDiadocApi:ProxySettings:Password = getextAttr('proxy-pswd':U).
   end.
   mDiadocConnection = mDiadocAPI:CreateConnectionByLogin(getextAttr('diadoc-user':U),getextAttr('diadoc-pwd':U)) no-error.
   define variable vi as integer no-undo.
   if mDiadocConnection eq ?
   then
      PutErr("DiadocAPI:CreateConnectionByLogin").
   return mDiadocConnection.
end.
function GetDocumforid returns character
(input  iorg as character ,
 input  idoc-id as character ,
 output oDocument      as component-handle
  ):
   define variable vOrganization  as component-handle no-undo.
   define variable vDocument      as component-handle no-undo.
   define buffer utd           for ub.utd.
   if
          iorg  ne ?
      and iorg  ne ""
      and idoc-id ne ?
      and idoc-id ne ""
   then do:
      vOrganization = mDiadocConnection:GetOrganizationById(iorg) no-error.
      if vOrganization ne ?
      then do:
         oDocument = vOrganization:GetDocumentById(idoc-id,false) no-error.
         if oDocument eq ?
         then
            PutErr(substitute("Error Нет доступа к документу &2 по организации &1. ", iorg,idoc-id)).
      end.
      else do:
         PutErr(substitute("Error Нет доступа к организации &1 по документу &2. ", iorg,idoc-id)).
         return "Нет доступа к организации " + iorg.
      end.
   end.
   else
      return "Нет доступа к организации не ЭДО".
   release object vOrganization no-error.
   return "".
end.
function GetDocum returns character
(input  idb-num as integer,
 input  idoc-id as integer,
 output oDocument      as component-handle
  ):
   define variable vOrganization  as component-handle no-undo.
   define variable vDocument      as component-handle no-undo.
   define buffer utd           for ub.utd.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if     available utd
      and utd.OrganizationExt ne ?
      and utd.OrganizationExt ne ""
      and utd.DocumentExt ne ?
      and utd.DocumentExt ne ""
   then do:
      vOrganization = mDiadocConnection:GetOrganizationById(utd.OrganizationExt) no-error.
      if vOrganization ne ?
      then do:
         oDocument = vOrganization:GetDocumentById(utd.DocumentExt,false) no-error.
         if oDocument eq ?
         then
            PutErr(substitute("Error Нет доступа к документу &2 по организации &1. ", utd.OrganizationExt,utd.DocumentExt)).
         release object vOrganization no-error.
      end.
      else do:
         PutErr(substitute("Error Нет доступа к организации &1 по документу &2. ", utd.OrganizationExt,utd.DocumentNumber)).
         return "Нет доступа к организации " + utd.OrganizationExt.
      end.
   end.
   else
      return "Нет доступа к организации не ЭДО".
   return "".
end.
function GetFirstUTDinPack returns logical
(input idb-num as integer,
 input idoc-id as integer,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   define buffer     utd for utd.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if utd.PackageId eq ""
      then do:
         assign
            odb-num = utd.db-num
            odoc-id = utd.doc-id
         .
         return yes.
      end.
      else do:
         find first buf_utd where Buf_utd.PackageId eq utd.PackageId
                              and Buf_utd.EDocType  eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
         no-lock.
         assign
            odb-num = buf_utd.db-num
            odoc-id = buf_utd.doc-id
         .
         return if available buf_utd then (recid(utd) eq recid(buf_utd)) else no.
      end.
   end.
   return ?.
end.
function AddOADLine returns integer
(iDb-num  as integer ,
 iDoc-id  as integer ,
 ilinenum as integer ,
 iGtin    as char,
 iQnty    as int,
 isite    as character ):
    define buffer utd-marking-lines      for ub.utd-marking-lines.
    define variable vnewMark as character no-undo.
    define variable vQnty    as integer   no-undo.
    vnewMark = "02" + iGtin + "37" + string(iQnty).
    find first utd-marking-lines where utd-marking-lines.mark       = vnewMark
                                   and utd-marking-lines.db-num     = idb-num
                                   and utd-marking-lines.doc-id     = idoc-id
                                   and utd-marking-lines.Linenum    = iLinenum
    exclusive-lock no-error.
    if available utd-marking-lines
    then do:
       delete utd-marking-lines.
       vQnty = AddOADLine(idb-num, idoc-id, iLinenum, iGtin, iQnty * 2 ,isite ).
    end.
    else do:
       create utd-marking-lines.
       assign
          utd-marking-lines.mark      = vnewMark
          utd-marking-lines.db-num    = idb-num
          utd-marking-lines.doc-id    = idoc-id
          utd-marking-lines.Linenum   = iLinenum
          utd-marking-lines.site      = isite
          utd-marking-lines.doc-level = 1
          utd-marking-lines.gds-code  = ?
       .
       vQnty = iQnty.
    end.
    return vQnty.
 end.
function addMarkforUtd returns recid
(iDb-num  as integer ,
 iDoc-id  as integer ,
 ilinenum as integer ,
 iMark as character  ,
 isite   as character,
 iUtdType as character    ):
    define buffer     marking            for ub.marking.
    define buffer     marking-attr       for ub.marking-attr.
    define buffer utd-marking-lines      for ub.utd-marking-lines.
    define buffer utd-marking-lines-attr for ub.utd-marking-lines-attr.
    define variable vMRC  as decimal no-undo.
    define variable vQnty as decimal no-undo.
   define variable vRec as recid no-undo.
   if     imark ne "-"
      and imark ne ""
      and imark ne ?
   then do:
      imark = repTegforDm(imark).
      vQnty = getQntyUTDByCodId(imark) .
      find first utd-marking-lines where utd-marking-lines.mark       = imark
                                     and utd-marking-lines.db-num     = idb-num
                                     and utd-marking-lines.doc-id     = idoc-id
                                     and utd-marking-lines.Linenum    = iLinenum
      exclusive-lock no-error.
      if not available utd-marking-lines
      then do:
         create utd-marking-lines.
         assign
            utd-marking-lines.mark      = imark
            utd-marking-lines.db-num    = idb-num
            utd-marking-lines.doc-id    = idoc-id
            utd-marking-lines.Linenum   = iLinenum
            utd-marking-lines.site      = isite
            utd-marking-lines.doc-level = 1
            utd-marking-lines.gds-code  = ?
         .
         create utd-marking-lines-attr.
         assign
            utd-marking-lines-attr.mark      = imark
            utd-marking-lines-attr.db-num    = idb-num
            utd-marking-lines-attr.doc-id    = idoc-id
            utd-marking-lines-attr.Linenum   = iLinenum
            utd-marking-lines-attr.attr-code = "box-qnty"
            utd-marking-lines-attr.attr-value = string(vQnty)
         .
         vRec = recid(utd-marking-lines).
         release utd-marking-lines-attr.
         release utd-marking-lines.
      end.
      else do:
         if    (    isite eq "-"
            and utd-marking-lines.site eq "+")
         or (    isite eq "+"
            and utd-marking-lines.site eq "-")
         then
            delete utd-marking-lines.
         else if isOAD (imark)
         then do:
            vQnty = AddOADLine(idb-num, idoc-id, iLinenum, GetTegCod(imark,"02"), int(vQnty) ,isite ).
            create utd-marking-lines-attr.
            assign
               utd-marking-lines-attr.mark      = imark
               utd-marking-lines-attr.db-num    = idb-num
               utd-marking-lines-attr.doc-id    = idoc-id
               utd-marking-lines-attr.Linenum   = iLinenum
               utd-marking-lines-attr.attr-code = "box-qnty"
               utd-marking-lines-attr.attr-value = string(vQnty)
            .
         end.
         vRec = recid(utd-marking-lines).
         release utd-marking-lines.
      end.
      if isMark (imark)
      then do:
         find first marking where marking.mark eq iMark exclusive-lock no-error.
         if not available marking
         then do:
            create marking.
            marking.mark = iMark.
            marking.gds-code = ?.
            marking.unit     = getLevelUTDByCodId(marking.mark) .
         end.
         assign
           marking.unit-ext   = if marking.unit-ext = "" or marking.unit-ext = ? then
                                   getLevelMotpByCodId(marking.mark)
                                else marking.unit-ext
           marking.box-qnty   = vQnty
           marking.unit       = if marking.unit-ext = "LEVEL2" then "КИТУ" else getLevelUTDByCodId(marking.mark)
         .
         if        (     iUtdType eq "UniversalTransferDocument"
                  and marking.sts = objSrv:Env:marking:Sts:Mark:NotAvailable:KeyIntDB)
         then
            marking.sts = ?.
      end.
   end.
   return vRec.
end.
function isSaleMarkInUpak returns logical
(iMark    as char ):
   define buffer buf_marking       for ub.marking.
   for each buf_marking no-lock where
            buf_marking.mark-parent = iMark
   :
     if can-do(objSrv:Env:marking:Sts:Mark:Sale_Return_Wait,string(buf_marking.sts)) or
        can-do(objSrv:Env:marking:Sts:Mark:Doc_Status,string(buf_marking.sts)) then
       return true.
     if isSaleMarkInUpak(buf_marking.mark) then
       return true.
   end.
   return false.
 end.
function setStatusUpak returns logical
(iDbNum   as integer ,
 iDocId   as integer ,
 iLineNum as integer ,
 iMark    as char ,
 iSts     as integer):
   define buffer buf_utd-marking-lines for ub.utd-marking-lines.
   define buffer buf_marking           for ub.marking.
   for each buf_marking exclusive-lock where
            buf_marking.mark-parent = iMark,
      first buf_utd-marking-lines exclusive-lock where
            buf_utd-marking-lines.doc-id  = iDocId
        and buf_utd-marking-lines.db-num  = iDbNum
        and buf_utd-marking-lines.lineNum = iLineNum
        and buf_utd-marking-lines.mark = buf_marking.mark
   :
     setStatusUpak(iDbNum, iDocId, iLineNum, buf_marking.mark, iSts).
   end.
   for first buf_utd-marking-lines exclusive-lock where
             buf_utd-marking-lines.doc-id  = iDocId
         and buf_utd-marking-lines.db-num  = iDbNum
         and buf_utd-marking-lines.lineNum = iLineNum
         and buf_utd-marking-lines.mark = iMark,
       first buf_marking exclusive-lock where
             buf_marking.mark = buf_utd-marking-lines.mark
   :
     if  buf_marking.sts <> objSrv:Env:marking:Sts:Mark:MarkError:KeyIntDB
     then do:
       assign
         buf_utd-marking-lines.sts = iSts
         buf_marking.sts           = iSts
       .
     end.
   end.
   return true.
end.
define temp-table tt-recid no-undo
          field orgid as char
          field docid as char
          field parent as char
          field stamp as datetime
          index pi orgid docid
          index parent parent  stamp.
function ProcessSystemMessStart return component-handle
(IStartStop as logical):
   if mDiadocConnection eq ? then
   define variable vOrganizationList as component-handle no-undo.
   define variable vOrganization as component-handle no-undo.
   define variable vReceiptGenerationProcess as component-handle no-undo.
   define variable vi as integer no-undo.
   if mDiadocConnection ne ?
   then do:
      vOrganizationList = mDiadocConnection:GetOrganizationList().
       do vi = 1 to vOrganizationList:count:
          vOrganization = vOrganizationList:GetItem(vi - 1 ).
          vReceiptGenerationProcess = vOrganization:GetReceiptGenerationProcess().
          release object vOrganization.
          if IStartStop
          then
             vReceiptGenerationProcess:Start().
          else
             vReceiptGenerationProcess:Stop().
          release object vReceiptGenerationProcess.
       end.
       release object vOrganizationList.
   end.
end.
procedure  changeIdToGuid :
define input  parameter iOrganization as component-handle no-undo.
   define variable vOrgId   as character no-undo.
   define variable vOrgGuid as character no-undo.
   define buffer utd for utd.
   assign
      vOrgId   = iOrganization:id.
      vOrgGuid = iOrganization:guid
   no-error.
   if     error-status:num-messages eq 0
      and vOrgId   ne ""
      and vOrgGuid ne ""
   then do:
      define variable vfirst as logical no-undo init yes.
      repeat preselect each utd where utd.OrganizationExt = vOrgId exclusive-lock:
         find next utd.
         if vfirst
         then do:
            PutMes("Конвертация документов").
            vfirst = no.
         end.
         utd.OrganizationExt = vOrgGuid.
         validate utd.
         PutMes(substitute ("У документа &1 изменен индификатор организации с &2 на &3",ub.utd.DocumentNumber,vOrgId,utd.OrganizationExt)).
      end.
      if not vfirst
      then
         PutMes("Конвертация документов завершина.").
   end.
end.
procedure getNewUpd :
   define variable VLastDate as date no-undo init ?.
   define variable vDocument     as component-handle no-undo.
   define variable vYear         as integer no-undo.
   define variable vMonth        as integer no-undo.
   define variable vDay          as integer no-undo.
   define variable vBegLoadDate  as date    no-undo.
   define variable vLastLoadDate as date    no-undo.
   define buffer utd for utd.
   VLastDate = date( getextAttr('diadoc-lastload':U)) no-error.
   find first sys-ctrl no-lock.
   if VLastDate eq ?
   then
      VLastDate = sys-ctrl.cut-date + 3.
   else if sys-ctrl.cut-date ne ?
   then
      VLastDate = max(VLastDate,sys-ctrl.cut-date + 3) .
   vLastLoadDate = VLastDate.
   for each tt-recid:
      delete tt-recid.
   end.
   if chekStop() then return "Остановка пользователем".
    run  UpdateUTDInform(if VLastDate eq ? then today - 365 else VLastDate - 3,today + 1,output VLastDate).
   if chekStop() then return "Остановка пользователем".
   if VLastDate ne ?
   then do:
      setextAttr('diadoc-lastload':U,string(VLastDate)).
      vYear = year(vLastLoadDate).
      vMonth = month(vLastLoadDate) - 2.
      vDay   = day(vLastLoadDate).
      if vMonth <= 0 then
         assign
            vMonth = vMonth + 12
            vYear  = vYear - 1
            .
      repeat:
         vBegLoadDate = date(vMonth, vDay, vYear) no-error.
         if error-status:error then
            vDay = vDay - 1.
         else
            leave.
      end.
      vBegLoadDate = vBegLoadDate + 1.
   end.
   block-rec:
   for each tt-recid break by tt-recid.parent descending by tt-recid.stamp descending :
      if  tt-recid.parent eq ""
      then next  block-rec.
      if first-of (tt-recid.parent)
      then do:
         for each utd where utd.PackageId eq tt-recid.parent
         no-lock break by utd.PackageId descending by utd.Timestamp descending :
            if chekStop() then return "Остановка пользователем".
            if utd.EDocType = objSrv:Env:Utd:EDocType:UCD:KeyIntDB
            then do:
               subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
               MySeqUtd = ?.
               CrEdoc(utd.PackageId,utd.Timestamp).
               unsubscribe "getNextseq".
               next block-rec.
            end.
         end.
      end.
   end.
   PutMes("Обновление информации по ранее загруженным документам за период c " + (if vBegLoadDate <> ? then
                                                                                     string(vBegLoadDate)
                                                                                  else "?")
                                                                                  + " по " +
                                                                                  (if vLastLoadDate <> ? then
                                                                                      string(vLastLoadDate)
                                                                                   else
                                                                                      "?")
                                                                                   ).
   define variable vobj as character no-undo.
   vobj = getExtAttr('host-code':U).
   if vobj ne "0"
   then
       for each utd where utd.sts-edi < ObjSrv:Env:Utd:Sts:edi:StatFinesh
                      and utd.host-code eq int(vobj)
                      and (   utd.EDocType eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                           or utd.EDocType eq objSrv:Env:Utd:EDocType:UCD:KeyIntDB
                           )
       no-lock break by utd.OrganizationExt:
          if chekStop() then return "Остановка пользователем".
          if vBegLoadDate <> ? and utd.DocumentDate < vBegLoadDate then next.
          find first tt-recid where tt-recid.orgid = utd.OrganizationExt
                                and tt-recid.docid = utd.DocumentExt
                 no-error.
          if     not available tt-recid
             and getdocum (utd.db-num, utd.doc-id, output vDocument) eq ""
          then do:
              run  UpdateUTDInformOne(vDocument).
             release object vDocument no-error.
          end.
       end.
   vobj = getExtAttr('obj':U).
   if vobj ne ""
   then
       for each utd where utd.sts-edi < ObjSrv:Env:Utd:Sts:edi:StatFinesh
                      and utd.obj-type + string(utd.obj-code) eq vobj
       no-lock break by utd.OrganizationExt:
          if chekStop() then return "Остановка пользователем".
          if vBegLoadDate <> ? and utd.DocumentDate < vBegLoadDate then next.
          find first tt-recid where tt-recid.orgid = utd.OrganizationExt
                                and tt-recid.docid = utd.DocumentExt
                 no-error.
          if     not available tt-recid
             and getdocum (utd.db-num, utd.doc-id, output vDocument) eq ""
          then do:
              run  UpdateUTDInformOne(vDocument).
             release object vDocument no-error.
          end.
       end.
end.
procedure  SendAuto:
 define variable vOrganization as component-handle no-undo.
 define variable vOrganizationList as component-handle no-undo.
 define variable vi as integer no-undo.
   if mDiadocConnection eq ?
   then do:
      message "По данному сертификату не удалось подключиться к Диадок"
      view-as alert-box.
   end.
   else do:
      for each tt-recid:
         delete tt-recid.
      end.
      vOrganizationList = mDiadocConnection:GetOrganizationList() no-error.
      if vOrganizationList eq ? then return error ?.
      vi = vOrganizationList:Count()no-error.
      if vi eq ?
      then
         return error ?.
      do vi = 1 to vOrganizationList:Count() :
         vOrganization = vOrganizationList:GetItem(vi - 1 ).
         define variable vorgid as character no-undo.
         vorgid = vOrganization:guid.
         for each utd where utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:HaveToCreateReceipt:KeyIntDB
                        and utd.host-code eq v-cntxt-host-code-obj
                        and utd.OrganizationExt eq vorgid
         no-lock:
             run  SendReceiptsAsync(utd.db-num,utd.doc-id).
         end.
         for each utd where utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:HaveToCreateReceipt:KeyIntDB
                        and utd.host-code eq v-cntxt-host-code-obj
                        and utd.OrganizationExt eq vorgid
         no-lock:
             run  updOneUTD(utd.db-num,utd.doc-id).
         end.
      end.
   end.
end.
procedure SendAccept:
   define input  parameter iTypeAccept     as character no-undo.
   define input  parameter iReplyTask      as component-handle no-undo.
   define input  parameter iOrganizationGuid as character no-undo.
   define input  parameter iWorkflowId     as integer no-undo.
   define input  parameter iTitleTypes    as character  no-undo.
   define output parameter oOperationCode as character no-undo.
   define variable vContentItems as component-handle no-undo.
   define variable vContentItem  as component-handle no-undo.
   define variable vSigner       as component-handle no-undo.
   define variable vBuyerTitle   as component-handle no-undo.
   define variable vEmployee     as component-handle no-undo.
   define variable vContentOperCode as component-handle no-undo.
   define variable vOrganization   as component-handle no-undo.
   define variable vUserperm   as component-handle no-undo.
   define variable vi as integer no-undo.
  define variable vdate as date no-undo.
  define variable vDocumentCreator as character no-undo.
  define variable vDocumentCreatorBase as character no-undo.
  define variable vOperationCode as character no-undo.
  define variable vOperationContenttext as character no-undo.
  define variable vOperationContent as character no-undo.
  define variable vThumbprint as character no-undo.
  define variable vJobTitle   as character no-undo.
  vThumbprint = mDiadocConnection:Certificate:Thumbprint.
  vOrganization = mDiadocConnection:GetOrganizationById(iOrganizationGuid) no-error.
  if vOrganization eq ?
  then do:
     run str\utdacp.w (output vdate, output  vDocumentCreator, output vDocumentCreatorBase, output vOperationCode, output vOperationContent) no-error.
     if vdate eq ?
     then
        return error "".
  end.
  else do:
     define variable vTitleType as character no-undo.
     define variable vSignSet   as component-handle no-undo.
     define variable vSeller as logical no-undo.
     vUserperm = vOrganization:GetUserPermissions().
     vJobTitle = vUserperm:JobTitle.
     release object vUserperm.
     blk-tit:
     do vi = 1 to num-entries(iTitleTypes):
        vTitleType = entry(vi,iTitleTypes).
        vSeller = index(vTitleType,"Seller") > 0.
        if vSeller
        then
           next blk-tit.
        vSignSet = vOrganization:GetExtendedSignerDetails2(vThumbprint, vTitleType) no-error.
        if error-status:num-messages > 0
        then do:
           define variable vTasksetSign   as component-handle no-undo.
           define variable vTasksetSignDetal   as component-handle no-undo.
           vTasksetSign = vOrganization:CreateSetExtendedSignerDetailsTask(VThumbprint).
           getdesc(vTasksetSign).
           vTasksetSign:DocumentTitleType = vTitleType.
           getdesc(vTasksetSign).
           vTasksetSignDetal = vTasksetSign:ExtendedSignerDetailsToPost.
           getdesc(vTasksetSignDetal).
           vTasksetSignDetal:JobTitle  = vJobTitle    .
           vTasksetSignDetal:SignerType = "LegalEntity" .
           vTasksetSignDetal:SignerInfo = "".
           vTasksetSignDetal:Powers = if VSeller then "InvoiceSigner"  else "PersonDocumentedOperation".
           vTasksetSignDetal:Status = if VSeller then "SellerEmployee" else "BuyerEmployee".
           vTasksetSignDetal:PowersBase = "Должностные обязанности".
           getdesc(vTasksetSignDetal).
           release object vTasksetSignDetal.
           vTasksetSign:send() no-error.
           if error-status:num-messages > 0 then do:
              PutErr(substitute("Error Ошибка при установке подписанта по документу &1 ", vTitleType )).
           end.
           release object vTasksetSign.
        end.
        else do:
           getdesc(vSignSet).
           release object vSignSet.
        end.
     end.
     vOperationContent = if iTypeAccept eq "AcceptDocumentWithDisc"
                         then "2"
                         else if iTypeAccept eq "AcceptDocumentNotAccepted"
                         then "3"
                         else "1".
     vdate = today.
     vDocumentCreator = substitute("&1, ИНН~/КПП &2~/&3", vOrganization:name , vOrganization:inn , vOrganization:kpp).
     release object vOrganization.
  end.
  if    vJobTitle eq ?
     or vJobTitle eq ""
  then
     vJobTitle = mDiadocConnection:Certificate:JobTitle.
   if (   iWorkflowId = 3
      or iWorkflowId = 5
      or iWorkflowId = 8
      or iWorkflowId = 11
      or iWorkflowId = 12
      or iWorkflowId = 13
      or iWorkflowId = 16)
      and iReplyTask ne ?
   then do:
      getdesc(iReplyTask).
      vContentItems = iReplyTask:ContentItems.
      getdesc(vContentItems).
      do vi = 1 to vContentItems:count:
         getdesc(vContentItems:GetItem(vi - 1 )).
         getdesc(vContentItems:GetItem(vi - 1 ):document).
         vContentItem = vContentItems:GetItem(vi - 1 ):Content.
         getdesc(vContentItem).
         vBuyerTitle = vContentItem:UniversalTransferDocumentBuyerTitle no-error.
         getdesc(vBuyerTitle).
           if vBuyerTitle eq ?
         then do:
            vBuyerTitle = vContentItem:UniversalCorrectionDocumentBuyerTitle.
            getdesc(vBuyerTitle).
            vOperationContenttext = "C изменением стоимости согласен".
         end.
         else do:
            oOperationCode = vOperationContent.
   vOperationContenttext = if vOperationContent eq "1"
                       then "Принято без разногласий"
                       else if vOperationContent eq "2"
                       then "Принято с разногласиями"
                       else if vOperationContent eq "3"
                       then "Товары не приняты"
                       else vOperationContent.
            getdesc(vBuyerTitle).
            vEmployee = vBuyerTitle:Employee.
            getdesc(vEmployee).
            define variable vUser   as component-handle no-undo.
            vUser = mDiadocConnection:GetMyUser().
            getdesc(vUser).
            vEmployee:position        = vJobTitle    .
            vEmployee:FirstName       = vUser:FirstName  .
            vEmployee:LastName        = vUser:LastName   .
            vEmployee:MiddleName      = vUser:MiddleName .
            vEmployee:EmployeeBase     = "Должностные обязанности".
            release object vUser.
            getdesc(vEmployee).
            getdesc(mDiadocConnection:Certificate).
            getdesc(vContentItem:UniversalTransferDocumentBuyerTitle).
            getdesc(vBuyerTitle:ContentOperCode).
            vContentOperCode = vBuyerTitle:ContentOperCode.
            vContentOperCode:TotalCode = vOperationContent.
            vBuyerTitle:OperationCode   = oOperationCode.
            release object vContentOperCode.
            release object vEmployee.
         end.
         vBuyerTitle:DocumentCreator = vDocumentCreator .
         vBuyerTitle:DocumentCreatorBase     = vDocumentCreatorBase.
         vBuyerTitle:OperationContent =  vOperationContenttext.
         vBuyerTitle:AcceptanceDate   = vdate.
         getdesc(vBuyerTitle).
         getdesc(vBuyerTitle:Signers).
         vSigner = vBuyerTitle:Signers:additems().
         getdesc(vSigner).
         getdesc(vSigner:SignerReference).
         getdesc(vSigner:SignerDetails).
         vSigner:SignerReference:CertificateThumbprint = mDiadocConnection:Certificate:Thumbprint.
         vSigner:SignerReference:boxid = iOrganizationGuid.
         getdesc(vSigner:SignerReference).
         release object vBuyerTitle no-error.
         release object vContentItem.
      end.
      release object vContentItems.
   end.
end.
function SendAnswer returns character
(iReplyTask as component-handle,iorg as char,iTypeAnswer as character,imes as longchar ):
   define variable vContent       as component-handle no-undo.
   define variable vContentItems  as component-handle no-undo.
   define variable vSigner        as component-handle no-undo.
   define variable vSignTask      as component-handle no-undo.
   define variable vOrganization  as component-handle no-undo.
   define variable vUserperm      as component-handle no-undo.
   define variable vUser          as component-handle no-undo.
   define variable vi as integer no-undo.
   if     itypeAnswer ne "AcceptRevocation"
      and iReplyTask  ne ?
   then do:
      getdesc(iReplyTask).
      vContentItems = iReplyTask:ContentItems.
      getdesc(vContentItems).
      do vi = 1 to vContentItems:count:
         getdesc(vContentItems:GetItem(vi - 1 )).
         getdesc(vContentItems:GetItem(vi - 1 ):document).
         vContent = vContentItems:GetItem(vi - 1 ):Content.
         vContent:comment =  imes.
        getdesc(vContent).
         vSigner = vContent:Signer.
         getdesc(vSigner).
         vOrganization = mDiadocConnection:GetOrganizationById(iOrg) no-error.
         vUserperm = vOrganization:GetUserPermissions().
         define variable vJobTitle as character no-undo.
         vJobTitle = vUserperm:JobTitle.
         if    vJobTitle eq ?
            or vJobTitle eq ""
         then
            vJobTitle = mDiadocConnection:Certificate:JobTitle.
         release object vUserperm.
         release object vOrganization.
         vUser = mDiadocConnection:GetMyUser().
         getdesc(vUser).
         vSigner:Surname    = vUser:FirstName.
         vSigner:FirstName  = vUser:LastName.
         vSigner:Patronymic = vUser:MiddleName.
         vSigner:JobTitle   = vJobTitle.
         vSigner:Inn        = mDiadocConnection:Certificate:inn.
         getdesc(vSigner).
         release object vUser.
         release object vSigner.
         release object vContent.
      end.
      release object vContentItems.
   end.
end.
procedure send:
   define input  parameter iDocument as component-handle no-undo.
   define input  parameter iTypeAnswer as character no-undo.
   define input  parameter icomment as character no-undo.
   define output parameter oOperationCode as character no-undo.
   define variable vReplyTask    as component-handle no-undo.
   define variable vTypeAnswer as character no-undo.
   define variable vTypeAnswer_orig as character no-undo.
   define variable Vmes as longchar  no-undo.
   define variable vOrganizationGuid as character no-undo.
   define variable vDocumentid as character no-undo.
   define variable vi as integer no-undo.
   if iDocument ne ?
   then do:
      case iTypeAnswer:
         when "Подписания"                 then vTypeAnswer =  "AcceptDocument".
         when "отказ подписи"              then vTypeAnswer =  "RejectDocument".
         when "запрос коректировки"        then vTypeAnswer =  "CorrectionRequest".
         when "Запрос анулирование"        then vTypeAnswer =  "RevocationRequest".
         when "Подтверждение анулирования" then vTypeAnswer =  "AcceptRevocation".
         when "отказ анулирования"         then vTypeAnswer =  "RejectRevocation".
         when "подписать с расхождениями"  then vTypeAnswer =  "AcceptDocumentWithDisc".
         when "подписать товар не принят"  then vTypeAnswer =  "AcceptDocumentNotAccepted".
         otherwise vTypeAnswer = iTypeAnswer .
      end case.
      vTypeAnswer_orig = vTypeAnswer.
      if    vTypeAnswer =  "AcceptDocumentWithDisc"
         or vTypeAnswer =  "AcceptDocumentNotAccepted"
      then
         vTypeAnswer =  "AcceptDocument".
      if mDiadocConnection:AuthenticateType ne "Certificate" then return error "не сертификат".
      vReplyTask = iDocument:CreateReplySendTask2(vTypeAnswer).
      vOrganizationGuid = iDocument:OrganizationGuid.
      vDocumentid     = iDocument:DocumentId.
      getdesc(iDocument).
      if vTypeAnswer =  "AcceptDocument"
      then do:
         define variable vtitletype as character no-undo.
         vTitleType = GetDocTitleType(vOrganizationGuid,iDocument:TypeNamedId,iDocument:DocumentFunction,iDocument:Version).
         run sendAccept in this-procedure (vTypeAnswer_orig,
                                           vReplyTask,
                                           iDocument:OrganizationGuid,
                                           iDocument:WorkflowId,
                                           vtitletype,
                                           output oOperationCode ) no-error.
         if error-status:error
         then
            return error "".
      end.
      else do:
         find first utd where utd.DocumentExt     = vDocumentid
                          and utd.OrganizationExt = vOrganizationGuid
         no-lock no-error.
         if available utd
         then do:
            if   vTypeAnswer ne  "CorrectionRequest"
                and vTypeAnswer ne  "RejectDocument"
            then
               icomment = "".
            if vTypeAnswer eq  "RejectDocument"
            then do:
               if icomment eq ? or icomment eq "" then icomment = utd.comment.
               Vmes = (if icomment ne ? and icomment ne "" then icomment + "," else "" ) + GetErrForUtdStr(utd.db-num,utd.doc-id,?).
            end.
            else do:
                Vmes = GetErrForUtd(utd.db-num,utd.doc-id,?) .
                Vmes = GetErrComText(icomment,Vmes).
            end.
            if mFlaftest
            then do:
               output stream File-stream to "SendAnswer.txt" .
               put stream File-stream unformatted string(Vmes).
               output stream File-stream close.
               message "сформирован файл " search("SendAnswer.txt")
               view-as alert-box.
               return error "ничего не отправляем".
            end.
            else
               SendAnswer(vReplyTask,iDocument:OrganizationGuid, iTypeAnswer,Vmes) no-error.
            if error-status:error
            then
               return error "".
            end.
         end.
      if not mFlaftest
      then do:
         getdesc(vReplyTask).
          vReplyTask:Send() no-error.
         if error-status:num-messages > 0 then do:
            Puterr(substitute("Error Ошибка при выполнение действия по документу &1. ", vDocumentid )).
            release object vReplyTask.
            return error "Ошибка при выполнение дейстия с документом".
         end.
      end.
   end.
end.
procedure SendReceiptsAsync :
define input  parameter idb-num as integer no-undo.
define input  parameter idoc-id as integer no-undo.
   define variable vDocument as component-handle no-undo.
   define buffer utd for utd.
   if getdocum (idb-num, idoc-id, output vDocument ) eq ""
   then do:
      PutMes(substitute("Обработка подписи ИОП по документу ДБ &1 ID &2",idb-num,idoc-id)).
      define variable vAsyncResult   as component-handle no-undo.
      vAsyncResult = vDocument:SendReceiptsAsync().
      release object vDocument.
      PutMes(substitute("Запущена асинхронная обработка ИОП по документу ДБ &1 ID &2",idb-num,idoc-id)).
      find first utd where utd.db-num eq idb-num
                       and utd.doc-id eq idoc-id
      exclusive-lock no-error.
      if available utd
      then do:
         if getdocum (idb-num, idoc-id, output vDocument) eq ""
         then do:
             run  UpdateUTDInformOne(vDocument).
            release object vDocument.
         end.
         utd.flagRI = yes.
    end.
      PutMes(vAsyncResult:Result).
      release object vAsyncResult.
      if getdocum (idb-num, idoc-id, output vDocument) eq ""
      then do:
          run  UpdateUTDInformOne(vDocument).
         release object vDocument.
      end.
   end.
end.
procedure SendAnsver:
   define input  parameter idb-num as integer no-undo.
   define input  parameter idoc-id as integer no-undo.
   define input  parameter iTypeAnswer as character no-undo.
   define input  parameter iComment as character no-undo.
   define variable vSendcode as character no-undo.
   define variable vDocument as component-handle no-undo.
   define buffer utd for utd.
   if getdocum (idb-num, idoc-id, output vDocument ) eq ""
   then do:
      PutMes(substitute("Обработка запроса &3 по документу ДБ &1 ID &2",idb-num,idoc-id,iTypeAnswer)).
       run   SendReceiptsAsync(idb-num,idoc-id).
         find first utd where utd.db-num eq idb-num
                                and utd.doc-id eq idoc-id
               no-lock.
      if      (not utd.AmendmentRequested
          and  iTypeAnswer eq "CorrectionRequest")
          or iTypeAnswer ne "CorrectionRequest"
      then do:
          run   send in this-procedure (vDocument,iTypeAnswer,iComment,output vSendcode) no-error.
         if error-status:error
         then do:
            release object vDocument.
            return error return-value.
         end.
         PutMes(substitute("Обработка запроса &3 по документу ДБ &1 ID &2 Завершина",idb-num,idoc-id,iTypeAnswer)).
      end.
      else
         PutMes(substitute("Обработка запроса &3 по документу ДБ &1 ID &2 пропущена",idb-num,idoc-id,iTypeAnswer)).
      release object vDocument.
      if     vSendcode ne ?
         and vSendcode ne ""
      then
         setattrutd (idb-num,idoc-id,"sendcode",vSendcode).
      if not mFlaftest
      then do:
         if getdocum (idb-num, idoc-id, output vDocument) eq ""
         then do:
             run   UpdateUTDInformOne(vDocument).
            release object vDocument.
         end.
         if    iTypeAnswer eq "CorrectionRequest"
            or iTypeAnswer eq "AcceptRevocation"
            or iTypeAnswer eq "RejectRevocation"
            or iTypeAnswer eq "RejectDocument"
            or iTypeAnswer eq "AcceptDocument"
            or iTypeAnswer eq "AcceptDocumentWithDisc"
            or iTypeAnswer eq "AcceptDocumentNotAccepted"
         then do:
            if getdocum (idb-num, idoc-id, output vDocument) eq ""
            then do:
                run  UpdateUTDInformOne(vDocument).
               release object vDocument.
            end.
            if   not mFlaftest
            then do trans:
               find first utd where utd.db-num eq idb-num
                                and utd.doc-id eq idoc-id
                                and utd.sts-edi < ObjSrv:Env:Utd:Sts:edi:StatFinesh
               exclusive-lock no-error.
               if available utd
               then do :
                  case iTypeAnswer:
                     when   "AcceptDocument"               then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRecipient:KeyIntDB.
                     when   "RejectDocument"               then utd.sts-edi = if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:AutoRejected:KeyIntDB
                                                                              then ObjSrv:Env:Utd:Sts:edi:sendAutoRejected:KeyIntDB
                                                                              else ObjSrv:Env:Utd:Sts:edi:sendRejected:KeyIntDB.
                     when   "CorrectionRequest"            then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendAdjustment:KeyIntDB.
                     when   "AcceptRevocation"             then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRevocation:KeyIntDB.
                     when   "RejectRevocation"             then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRevocation:KeyIntDB.
                     when   "AcceptDocumentWithDisc"       then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRecipient:KeyIntDB.
                     when   "AcceptDocumentNotAccepted"    then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRecipient:KeyIntDB.
                  end case.
                  if iTypeAnswer eq "CorrectionRequest"
                  then do:
                     utd.sts = ObjSrv:Env:Utd:Sts:th:CorrectionRequested:KeyIntDB.
                     if     utd.sts-edi < ObjSrv:Env:Utd:Sts:edi:StatFinesh
                     then do:
                         run   SendAnsver(idb-num,idoc-id,"AcceptDocumentWithDisc",iComment).
                     end.
                  end.
               end.
            end.
         end.
      end.
   end.
end.
procedure  SendResponse :
   define input  parameter idb-num as integer no-undo.
   define input  parameter idoc-id as integer no-undo.
   define input  parameter iAccept as logical no-undo.
   define input  parameter itestMod as logical no-undo.
    define buffer utd for utd.
    define buffer buf_utd for utd.
    itestMod = not itestMod.
    define variable vreturn as logical no-undo.
    find first utd where utd.db-num eq idb-num
                     and utd.doc-id eq idoc-id
    no-lock no-error.
    if available utd
    then do:
       if utd.EDocType              = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB
       then do:
          if     iAccept
             and utd.sts-edi     ne objSrv:Env:Utd:sts:edi:WithRecipientSignature:KeyIntDB
             and utd.sts-edi     ne objSrv:Env:Utd:sts:edi:WithRecipientPartiallySignature:KeyIntDB
          then do:
             vreturn = yes.
             if itestMod
             then do:
                for each buf_utd where buf_utd.PackageId eq utd.PackageId
                                   and buf_utd.EDocType  eq objSrv:Env:Utd:EDocType:ucd:KeyIntDB
                                   and buf_utd.Timestamp <= utd.Timestamp
                                   and (     buf_utd.sts-edi   eq objSrv:Env:Utd:sts:edi:WaitingForRecipientSignature:KeyIntDB
                                         or  buf_utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:HaveToCreateReceipt:KeyIntDB
                                         or  buf_utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:Verification:KeyIntDB)
                no-lock :
                    run  SendAnsver in this-procedure (buf_utd.db-num,buf_utd.doc-id,"AcceptDocument","")no-error.
                   if error-status:error then return error return-value.
                end.
             end.
          end.
       end.
       else if utd.EDocType              = objSrv:Env:Utd:EDocType:returns:KeyIntDB
       then do:
          if iAccept
          then do:
             vreturn = yes.
             if itestMod
             then do:
                define variable vsend as logical no-undo.
                vsend = logical(getattrutdex (idb-num,idoc-id,"returnSend","no")).
                if vsend
                then
                   return error "Документ был отправлен рание. Повторная отправка возможна через сервис.".
                find first buf_utd where buf_utd.OrganizationExt eq utd.parentOrganizationExt
                                     and buf_utd.DocumentExt     eq utd.parentDocumentExt
                no-lock no-error.
                if available buf_utd
                then do:
                   if getattrutd (idb-num,idoc-id,"TypeUTD") ne "счфДОП"
                   then do:
                       run  SendAnsver in this-procedure (buf_utd.db-num,buf_utd.doc-id,"CorrectionRequest",GetErrForUtd(utd.db-num,utd.doc-id,"return"))no-error.
                      if error-status:error then return error return-value.
                   end.
                end.
                run bge/sendutd.p(
                     parparentproc,
                     mDiadocConnection:Certificate:Thumbprint,
                     idb-num,
                     idoc-id) no-error.
                if error-status:error then return error return-value.
                do trans :
                   find first utd where utd.db-num eq idb-num
                                    and utd.doc-id eq idoc-id
                   exclusive-lock no-error.
                   utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:WithRecipientSignature:KeyIntDB.
                   setattrutd (idb-num,idoc-id,"returnSend","yes").
                end.
             end.
          end.
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:HaveToCreateReceipt:KeyIntDB
       then do:
          if iAccept
          then do:
             vreturn = yes.
             if itestMod
             then
                 run  SendReceiptsAsync(idb-num,idoc-id).
          end.
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:Verification:KeyIntDB
       then do:
          if not iAccept
          then do:
             vreturn = yes.
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"RejectDocument","") no-error.
                if error-status:error then return error return-value.
             end.
          end.
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:RequestsMyRevocation:KeyIntDB
       then do:
          vreturn = yes.
          if iAccept
          then do:
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"AcceptRevocation","") no-error.
                if error-status:error then return error return-value.
             end.
          end.
          else do:
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"RejectRevocation","")no-error.
                if error-status:error then return error return-value.
             end.
          end.
       end.
       else if   utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:Changed:KeyIntDB
              or utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:WaitingForRecipientSignature:KeyIntDB
       then do:
          vreturn = yes.
          if iAccept
          then do:
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"AcceptDocument","")no-error.
                if error-status:error then return error return-value.
             end.
          end.
          else do:
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"RejectDocument","") no-error.
                if error-status:error then return error return-value.
             end.
          end.
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:AutoRejected:KeyIntDB
       then do:
          if iAccept
          then do:
             vreturn = yes.
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"RejectDocument","") no-error.
                if error-status:error then return error return-value.
             end.
          end.
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:SignatureAdjustment:KeyIntDB
       then do:
          if iAccept
          then do:
             vreturn = yes.
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"CorrectionRequest","")no-error.
                if error-status:error then return error return-value.
             end.
          end.
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:SignatureNotAccepted:KeyIntDB
       then do:
          if iAccept
          then do:
             vreturn = yes.
             if itestMod
             then do:
                 run  SendAnsver in this-procedure (idb-num,idoc-id,"AcceptDocumentNotAccepted","")no-error.
                if error-status:error then return error return-value.
             end.
          end.
       end.
       if itestmod and not vreturn
       then do:
          PutMes (substitute('Error Документ с № "&5" в.н. "&2" по БД "&1" в статусе "&3" выполнить операцию "&4" не возможно.',
                             utd.db-num,
                             utd.doc-id,
                             ObjSrv:Env:Utd:Sts:EDI:GetLabel(utd.sts-edi),
                             if iAccept then "Подписать" else "Отказать",
                             utd.DocumentNumber)
                             ).
       end.
    end.
    return string(vreturn).
end.
define temp-table tt-pack no-undo
          field orgid as char
          field docid as char
          field packid as char
          field stamp as datetime
          index pi packid   stamp   orgid  docid
          .
function CheckLoad returns logical
(iDocument as component-handle,
 output ohost-code as integer ,
 output oObj-type  as character  ,
 output oObj-code  as integer ):
   define variable vFlag as logical no-undo.
   define variable vDocumentChild as component-handle no-undo.
   define variable vContent as component-handle no-undo.
   define variable vConsignees as component-handle no-undo.
   define variable vfilename as character no-undo.
   oObj-type  = ?.
   oObj-code  = ?.
   ohost-code = ?.
   define buffer ext-classif   for ext-classif.
   define buffer clients       for clients.
   define buffer buf_clients   for clients.
   define buffer clients-attr  for clients-attr.
   if   iDocument:type eq "UniversalTransferDocument"
     or iDocument:type eq "UniversalTransferDocumentRevision"
   then main-block :
   do on error undo main-block, return error:
      getdesc(iDocument).
      vfilename = iDocument:filename.
      if iDocument:Direction eq "Inbound"
      then do:
         define variable vOrganizationGuid as character no-undo.
         define variable vDocumentid as character no-undo.
         vOrganizationGuid = iDocument:OrganizationGuid.
         vDocumentid     = iDocument:DocumentId.
         find first utd where utd.DocumentExt     = vDocumentid
                          and utd.OrganizationExt = vOrganizationGuid
         no-lock no-error .
         if available utd
         then do:
            assign
               Oobj-type = utd.obj-type
               Oobj-code = utd.obj-code
               ohost-code = utd.host-code.
            .
         end.
         vDocumentChild = iDocument:GetDynamicContent("Seller") no-error.
         getdesc(vDocumentChild).
         if    (Oobj-code  ne 0 and Oobj-code  ne ?
            and ohost-code ne 0 and ohost-code ne ?)
         then vFlag = no.
         if    (Oobj-code  ne 0 and Oobj-code  ne ?
            and (ohost-code eq 0 and ohost-code eq ?))
         then do:
             find first clients  where clients.obj-type   = Oobj-type
                                   and clients.obj-code   = Oobj-code
             no-lock no-error .
             if available clients
             then
                ohost-code =  clients.host-code.
             vFlag = no.
         end.
         else if vDocumentChild ne ?
         then do:
            if iDocument:version  eq "utd820_05_01_01"
            then do:
               vContent = vDocumentChild:UniversalTransferDocument no-error.
            end.
            else
               vContent = vDocumentChild:UniversalTransferDocumentWithHyphens no-error.
            release object vDocumentChild.
            if vContent ne ?
            then do:
               getdesc(vContent).
               define variable vFnsParticipantId as character no-undo.
               define variable vinn as character no-undo.
               define variable vkpp as character no-undo.
               define variable vorgname as character no-undo.
               define variable vAddrOrg as character no-undo.
               define variable vAdditionalInfo as character no-undo.
               if iDocument:version  eq "utd820_05_01_01"
               then do:
                  getdesc(vContent:Sellers).
                  getdesc(vContent:Sellers:Seller).
                  getdesc(vContent:Sellers:Seller:GetItem(0)).
                  getdesc(vContent:Sellers:Seller:GetItem(0):OrganizationDetails).
                  getOrganizationInfo(vContent:Sellers:Seller:GetItem(0),output vinn,output vkpp,vFnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
               end.
               else do:
                  vFnsParticipantId =  vContent:SenderFnsParticipantId.
               end.
               find first ext-classif where ext-classif.classif-name  eq 'id_diadok_client':U
                                        and ext-classif.charkey_three eq vFnsParticipantId
               no-lock no-error.
               if available ext-classif
               then do:
                  find first clients
                    where clients.obj-type   = ext-classif.CharKey_One
                      and clients.obj-code   = ext-classif.Key#_One
                      and not can-find(first ub.sysconf where ub.sysconf.host-code = clients.obj-code)
                  no-lock no-error .
                  if not available clients
                  then do:
                     PutMes(substitute("По &1 отправитель &2 наша фирма." ,iDocument:DocumentNumber, vFnsParticipantId) ).
                     return no.
                  end.
               end.
               else do:
                  PutMes(substitute("По &1 не найден отправитель  &2." ,iDocument:DocumentNumber, vFnsParticipantId) ).
                  return no.
               end.
               if iDocument:version  eq "utd820_05_01_01"
               then do:
                  getdesc(vContent:Buyers).
                  getdesc(vContent:Buyers:Buyer).
                  getdesc(vContent:Buyers:Buyer:GetItem(0)).
                  getOrganizationInfo(vContent:Buyers:Buyer:GetItem(0),output vinn,output vkpp,vFnsParticipantId, output vorgname, output vAdditionalInfo,output vAddrOrg).
               end.
               else do:
                  vConsignees = vContent:Consignees.
                  getdesc(vConsignees).
                  getdesc(vConsignees:Consignee).
                  if vConsignees:Consignee:count > 0
                  then do:
                     getdesc(vConsignees:Consignee:GetItem(0)).
                     getOrganizationInfo(vConsignees:Consignee:GetItem(0),output vinn,output vkpp,vFnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
                  end.
                  release object vConsignees.
                  vFnsParticipantId = vContent:RecipientFnsParticipantId.
               end.
               release object vContent.
               define variable otext as character no-undo.
               vFlag = getObgFns
                          (input iDocument:DocumentNumber ,
                           input vFnsParticipantId ,
                           input vkpp,
                           output ohost-code,
                           output oobj-type,
                           output oobj-code,
                           output otext ).
               if otext ne "" and otext ne ?
               then
                  PutMes( otext).
               if vFlag  eq no
               then
                  return vFlag .
            end.
            else do:
               PutMes("Error Ошибка получения данных из Диадок UniversalTransferDocument" + if iDocument:version  eq "utd820_05_01_01" then "" else "WithHyphens").
               return no.
            end.
         end.
         else do:
            PutErr(substitute ("Error Ошибка получения данных из Диадок Seller по документу с типом &1",iDocument:type)).
            return no.
         end.
      end.
      else
         return yes.
      if ohost-code eq ? or ohost-code eq 0
      then do:
         PutMes(substitute("По &1 не удалось определить фирму по получателю  &2." ,iDocument:DocumentNumber, vFnsParticipantId) ).
         return no.
      end.
   end.
   else do:
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vpack as character no-undo init ?.
      define variable vcli-type as character no-undo.
      define variable vcli-code as integer no-undo.
      define variable vfns as character no-undo.
      define variable vchar as character no-undo.
      vDocumentChild = iDocument:GetDynamicContent("Seller")no-error.
      if vDocumentChild eq ?
      then do:
         PutErr(substitute ("Error Ошибка получения данных из Диадок Seller по документу с типом &1",iDocument:type)).
         return no.
      end.
      vContent = vDocumentChild:UniversalCorrectionDocument no-error.
      if vContent ne ?
      then do:
         getOrganizationInfo(vContent:Seller,output vchar,output vchar,vFns, output vchar,  output vchar, output vchar).
         find first ext-classif where ext-classif.classif-name  eq 'id_diadok_client':U
                                  and ext-classif.charkey_three eq vFns
         no-lock no-error.
         if available ext-classif
         then do:
            assign
               vcli-type = ext-classif.CharKey_One
               vcli-code = ext-classif.Key#_One
            .
            vPack = substitute("&1|&2|&3|&4",vcli-type,vcli-code,iDocument:OriginalInvoiceNumber,date(iDocument:OriginalInvoiceDate)).
            GetprevUTDForPac(vpack,iDocument:Timestamp,output vdb-num,output vdoc-id ).
            release object vContent.
         end.
         else do:
                  PutMes(substitute("По &1 не найден отправитель  &2." ,iDocument:DocumentNumber, vFnsParticipantId) ).
                  return no.
               end.
      end.
      else do:
         PutErr("Error Ошибка получения данных из Диадок Seller").
         return no.
      end.
      release object vDocumentChild.
      define buffer     utd for utd.
      find first utd where utd.db-num eq vdb-num
                       and utd.doc-id eq vdoc-id
      no-lock no-error.
      if available utd
      then do:
         assign
            oobj-type  = utd.obj-type
            oobj-code  = utd.obj-code
            ohost-code = utd.host-code
            vfilename  = getattrutd (utd.db-num,utd.doc-id,"FileName")
         .
      end.
      else do:
         PutMes(substitute("Не найден оригенальный документ по пакету &1.",vpack)).
         return no.
      end.
   end.
   if  yes
   then do:
      define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
      EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(oobj-type, oobj-code).
      if     not EDOParSec:IsEdo
         and vfilename begins "ON_NSCHFDOPPRMARK_"
      then do:
         PutMes(substitute("На объекте &1&2 не установлен параметр работы с ЭДО для маркированного товара.",oobj-type,oobj-code)).
         vFlag = no.
      end.
      else if     not EDOParSec:IsEdoNotmark
              and not vfilename begins "ON_NSCHFDOPPRMARK_"
      then do:
         PutMes(substitute("На объекте &1&2 не установлен параметр работы с ЭДО для не маркированного товара.",oobj-type,oobj-code)).
         vFlag = no.
      end.
      else
         vFlag = yes.
   end.
   return vFlag.
end.
procedure  UpdateUTDInformOne :
   define input  parameter iDocument as component-handle no-undo.
   define variable vOrganizationGuid as character no-undo.
   define variable vDocumentId as character no-undo.
   define variable vi as integer no-undo.
   define variable vii as integer no-undo.
   define variable viii as integer no-undo.
   define variable vtext as longchar no-undo.
   define buffer utd           for ub.utd.
   define buffer old_utd           for ub.utd.
   define buffer utd-lines      for ub.utd-lines.
   define buffer marking       for ub.marking.
   define buffer marking-lines for ub.marking-lines.
   define buffer utd-marking-lines for ub.utd-marking-lines.
   define buffer buf_utd-marking-lines for ub.utd-marking-lines.
   define variable vDocumentChild               as component-handle no-undo.
   define variable vContent                     as component-handle no-undo.
   define variable vValues                      as component-handle no-undo.
   define variable vSellers                     as component-handle no-undo.
   define variable vConsignees                  as component-handle no-undo.
   define variable vInvoiceTable                as component-handle no-undo.
   define variable vItems                       as component-handle no-undo.
   define variable vExtendedInvoiceItem         as component-handle no-undo.
   define variable vItemIdentificationNumber    as component-handle no-undo.
   define variable vTransferBaseCol             as component-handle no-undo.
   define variable vTransferBase                as component-handle no-undo.
   define variable vorgname as character no-undo.
   define variable vAddrOrg as character no-undo.
   define variable vAdditionalInfo as character no-undo.
   define variable volddb-num as integer no-undo.
   define variable volddoc-id as integer no-undo.
   define variable vunits  as component-handle no-undo.
   define variable vunit   as component-handle no-undo.
   define variable VValue  as character        no-undo.
   define variable vsite   as character        no-undo.
   define variable vNewUtd as logical          no-undo.
   if iDocument eq ?
   then
     return.
   vOrganizationGuid = iDocument:OrganizationGuid.
   vDocumentid     = iDocument:DocumentId.
   find first utd where utd.DocumentExt     = vDocumentid
                    and utd.OrganizationExt = vOrganizationGuid
   no-lock no-error .
   find first tt-recid where tt-recid.orgid eq vOrganizationGuid
                         and tt-recid.docid eq vDocumentid
   no-lock no-error.
   if not available tt-recid
   then do trans:
      if iDocument  ne ?
         and (
                  iDocument:type eq "UniversalTransferDocument"
               or iDocument:type eq "UniversalTransferDocumentRevision"
               or iDocument:type eq "UniversalCorrectionDocument"
              )
      then do:
         PutMes(substitute("Загрузка документа  &1 от &2." ,iDocument:DocumentNumber,iDocument:DocumentDate) ).
         define variable vhost-code as integer   no-undo.
         define variable vobj-type  as character no-undo.
         define variable vobj-code  as integer   no-undo.
         if not CheckLoad(iDocument,output vhost-code,output vobj-type,output  vobj-code )
         then do:
            PutMes(substitute("Документ &1 от &2 пропущен." ,iDocument:DocumentNumber,iDocument:DocumentDate) ).
            create tt-recid.
            assign
               tt-recid.orgid = vOrganizationGuid
               tt-recid.docid = vDocumentid
            .
            return.
         end.
         find first utd where utd.DocumentExt     = vDocumentid
                          and utd.OrganizationExt = vOrganizationGuid
         no-lock no-error  .
         if available utd
         then do:
            if     utd.sts-edi > ObjSrv:Env:Utd:Sts:edi:StatFinesh
               and iDocument:RevocationStatus ne "RequestsMyRevocation"
            then do:
               create tt-recid.
               assign
                  tt-recid.orgid = vOrganizationGuid.
                  tt-recid.docid = vDocumentid
               .
               PutMes(substitute("Документ &1 от &2 в конечном статусе. Документ пропущен." ,iDocument:DocumentNumber,iDocument:DocumentDate) ).
            end.
            find current utd exclusive-lock no-error  no-wait  .
            if  not available  utd
            then do:
               PutMes(substitute("Документ &1 от &2 заблокирован и будет пропущен." ,iDocument:DocumentNumber,iDocument:DocumentDate )).
               return.
            end.
         end.
         subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
         MySeqUtd = ?.
         if     not available  utd
         then do:
            create utd.
            assign
               utd.DocumentExt      = vDocumentid
               utd.OrganizationExt  = vOrganizationGuid
               vNewUtd              = yes
            .
            validate utd.
         end.
         assign
            utd.host-code = vhost-code when vhost-code ne ? and vhost-code ne 0
            utd.obj-code  = vobj-code  when vobj-code  ne ? and vobj-code  ne 0
            utd.obj-type  = vobj-type  when vobj-type  ne ? and vobj-type  ne ""
         .
         setattrutd (utd.db-num,utd.doc-id,"FileName",iDocument:FileName).
         utd.RevocationStatus = iDocument:RevocationStatus.
         utd.RecipientResponseStatus          = iDocument:RecipientResponseStatus.
         utd.TypeId           = iDocument:type.
         utd.CounteragentId   = iDocument:Counteragent:guid.
         utd.CustomDocumentId = iDocument:CustomDocumentId.
         utd.sts-edi = ?.
         utd.DocumentNumber = iDocument:DocumentNumber.
         utd.DocumentDate   = date(iDocument:DocumentDate).
         utd.Timestamp      = datetime(iDocument:Timestamp) .
         utd.ReceiptStatus  = iDocument:RecipientReceiptMetadata:ReceiptStatus.
         utd.Direction      = iDocument:Direction.
         utd.ModifyDate = today.
         utd.flagRI     =    utd.ReceiptStatus eq "GeneralReceiptStatusNotAcceptable" or utd.ReceiptStatus eq "Finished".
         utd.EDocType = if   iDocument:type eq "UniversalTransferDocument"
                          or iDocument:type eq "UniversalTransferDocumentRevision"
                        then objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                        else objSrv:Env:Utd:EDocType:UCD:KeyIntDB.
         getdesc(iDocument).
         getdesc(iDocument:Counteragent).
         getdesc(iDocument:RecipientReceiptMetadata).
         getdesc(iDocument:ConfirmationMetadata).
         utd.AmendmentRequested = logical(iDocument:AmendmentRequested).
         if iDocument:type ne "UniversalTransferDocumentRevision"
         then do:
                utd.Revised = logical(iDocument:Revised).
                utd.Corrected = logical(iDocument:Corrected).
         end.
         vDocumentChild = iDocument:GetDynamicContent("Seller").
         getdesc(vDocumentChild).
         if   iDocument:type eq "UniversalTransferDocument"
           or iDocument:type eq "UniversalTransferDocumentRevision"
         then do:
            utd.Total = iDocument:total.
            utd.Vat = iDocument:Vat.
         end.
         else do:
            utd.Total = decimal (iDocument:TotalInc) - decimal (iDocument:TotalDec).
            utd.Vat = decimal (iDocument:VatInc) - decimal (iDocument:VatDec).
         end.
         find first utd-lines where utd-lines.db-num     = utd.db-num
                                and utd-lines.doc-id     = utd.doc-id
                                no-lock no-error.
         if     (   vNewUtd
                 or utd.Direction ne "Inbound"
                 or not available utd-lines)
            and vDocumentChild ne ?
         then do:
            if utd.EDocType eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
            then do:
               if iDocument:version  eq "utd820_05_01_01"
               then do:
                  vContent = vDocumentChild:UniversalTransferDocument no-error.
               end.
               else
                  vContent = vDocumentChild:UniversalTransferDocumentWithHyphens no-error.
               if vContent ne ?
               then do:
                  getdesc(vContent).
                  define variable vInfoCount as integer no-undo.
                  define variable vInfos as component-handle no-undo.
                  define variable vInfo as component-handle no-undo.
                  vInfos = vContent:AdditionalInfoId:AdditionalInfo.
                  do vInfoCount = 1 to vInfos:count:
                     vInfo = vInfos:getitem(vInfoCount - 1).
                     getdesc(vInfo).
                     setattrutd (utd.db-num,utd.doc-id,vInfo:id,vInfo:value).
                  end.
                  getdesc(vContent:TransferInfo).
                  getdesc(vContent:TransferInfo:TransferBases).
                  vTransferBasecol = vContent:TransferInfo:TransferBases:TransferBase.
                  getdesc(vTransferBasecol).
                  do vi = 1 to min(vTransferBasecol:count,1):
                     vTransferBase = vTransferBasecol:getitem(vi - 1).
                     getdesc(vTransferBase).
                     utd.BaseDocumentNumber = vTransferBase:BaseDocumentNumber.
                     utd.BaseDocumentName   = vTransferBase:BaseDocumentName.
                     utd.BaseDocumentDate   = date(vTransferBase:BaseDocumentDate).
                     release object vTransferBase.
                  end.
                  release object vTransferBasecol.
                  vSellers = vContent:Sellers.
                  getdesc(vSellers).
                  getdesc(vSellers:Seller:GetItem(0)).
                  if vSellers:Seller:count > 0
                  then
                     getOrganizationInfo(vSellers:Seller:GetItem(0),output utd.cli-inn,output utd.cli-kpp,utd.cli-FnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
                  release object vSellers.
                  if iDocument:version  ne "utd820_05_01_01"
                  then
                     utd.cli-FnsParticipantId = vContent:SenderFnsParticipantId.
                  utd.cli-info = vorgname + " " + vAddrOrg.
                  if iDocument:version  eq "utd820_05_01_01"
                  then do:
                     getOrganizationInfo(vContent:Buyers:Buyer:GetItem(0),output utd.obj-inn,output utd.obj-kpp,utd.obj-FnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
                  end.
                  else do:
                     vConsignees = vContent:Consignees.
                     getdesc(vConsignees).
                     if vConsignees:Consignee:count > 0
                     then do:
                        getOrganizationInfo(vConsignees:Consignee:GetItem(0),output utd.obj-inn,output utd.obj-kpp,utd.obj-FnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
                        setattrutd (utd.db-num,utd.doc-id,"Consignee_ИнфДляУчаст",vAdditionalInfo).
                     end.
                     utd.obj-FnsParticipantId = vContent:RecipientFnsParticipantId.
                     release object vConsignees.
                  end.
                  utd.obj-info = vorgname + " " + vAddrOrg + " ИНН: " + utd.obj-inn + " КПП: " + utd.obj-kpp.
                  vInvoiceTable = vContent:Table.
                  getdesc(vInvoiceTable).
                  vItems = vInvoiceTable:Item.
                  release object vInvoiceTable.
                  do vi = 1 to vItems:Count:
                     vExtendedInvoiceItem= vItems:GetItem(vi - 1).
                     getdesc(vExtendedInvoiceItem).
                     find first utd-lines where utd-lines.db-num     = utd.db-num
                                            and utd-lines.doc-id     = utd.doc-id
                                            and utd-lines.LineNum    = vi
                     exclusive-lock no-error.
                     if not available  utd-lines
                     then do:
                        create utd-lines.
                        assign
                           utd-lines.db-num   = utd.db-num
                           utd-lines.doc-id   = utd.doc-id
                           utd-lines.Linenum  = vi
                           utd-lines.gds-code = ?
                        .
                     end.
                     utd-lines.ProductCode = vExtendedInvoiceItem:Product.
                     utd-lines.UnitCode    = vExtendedInvoiceItem:UnitnAME.
                     setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity",string(vExtendedInvoiceItem:Quantity)).
                     setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Unit",string(vExtendedInvoiceItem:unit)).
                     utd-lines.Price       = vExtendedInvoiceItem:Price.
                     utd-lines.TotalWithVatExcluded   = vExtendedInvoiceItem:SubtotalWithVatExcluded.
                     utd-lines.TaxRate   =   if  vExtendedInvoiceItem:TaxRate eq "без ндс" then -1 else decimal(trim(entry(1,vExtendedInvoiceItem:TaxRate,"/"),"%")).
                     utd-lines.Vat       = vExtendedInvoiceItem:Vat.
                     utd-lines.Total     = vExtendedInvoiceItem:Subtotal.
                     utd-lines.Article   = vExtendedInvoiceItem:ItemVendorCode.
                     getdesc(vExtendedInvoiceItem:CustomsDeclarations).
                     getdesc(vExtendedInvoiceItem:CustomsDeclarations:CustomsDeclaration).
                     if vExtendedInvoiceItem:CustomsDeclarations:CustomsDeclaration:COUNT >= 1
                     then
                        getdesc(vExtendedInvoiceItem:CustomsDeclarations:CustomsDeclaration:GETITEM(0)).
                     getdesc(vExtendedInvoiceItem:AdditionalInfos).
                     getdesc(vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo).
                     if vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo:COUNT >= 1
                     then
                        getdesc(vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo:GETITEM(0)).
                     getdesc(vExtendedInvoiceItem:ItemTracingInfos).
                     getdesc(vExtendedInvoiceItem:ItemTracingInfos:ItemTracingInfo ).
                     if vExtendedInvoiceItem:ItemTracingInfos:ItemTracingInfo:COUNT >= 1
                     then
                        getdesc(vExtendedInvoiceItem:ItemTracingInfos:ItemTracingInfo:GETITEM(0) ).
                     getdesc(vExtendedInvoiceItem:ItemIdentificationNumbers).
                     getdesc(vExtendedInvoiceItem:ItemIdentificationNumbers:ItemIdentificationNumber).
                     do vii = 1 to vExtendedInvoiceItem:ItemIdentificationNumbers:ItemIdentificationNumber:COUNT:
                        vItemIdentificationNumber = vExtendedInvoiceItem:ItemIdentificationNumbers:ItemIdentificationNumber:GETITEM(vii - 1).
                        getdesc(vItemIdentificationNumber).
                        getdesc(vItemIdentificationNumber:Unit).
                        if vItemIdentificationNumber:TransPackageId ne ? and vItemIdentificationNumber:TransPackageId ne ""
                        then do:
                           VValue = repTegforDm(vItemIdentificationNumber:TransPackageId).
                           addMarkforUtd (utd-lines.db-num ,
                                          utd-lines.doc-id,
                                          utd-lines.Linenum,
                                          VValue,
                                          "",
                                          iDocument:type).
                        end.
                        vunit = vItemIdentificationNumber:Unit.
                        do viii = 1 to vunit:count:
                           vValue = vunit:GETITEM(viii - 1).
                           VValue = repTegforDm(VValue).
                           addMarkforUtd (utd-lines.db-num ,
                                          utd-lines.doc-id,
                                          utd-lines.Linenum,
                                          VValue,
                                          "",
                                          iDocument:type).
                        end.
                        release object  vunit.
                        getdesc(vItemIdentificationNumber:PackageId).
                        vunit = vItemIdentificationNumber:PackageId.
                        do viii = 1 to vunit:count:
                           VValue = vunit:GETITEM(viii - 1).
                           VValue = repTegforDm(VValue).
                           addMarkforUtd (utd-lines.db-num ,
                                          utd-lines.doc-id,
                                          utd-lines.Linenum,
                                          VValue,
                                          "",
                                          iDocument:type).
                        end.
                        release object  vunit.
                        release object vItemIdentificationNumber.
                     end.
                     vunits = vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo.
                     do vii = 1 to vunits:count:
                        vunit = vunits:GETITEM(vii - 1).
                        getdesc(vunit).
                        if     vunit:Id eq "штрихкод"
                            or vunit:Id eq "ean"
                        then do:
                           setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,vunit:Id,vunit:value).
                           setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"BarCode",vunit:value).
                           find first utd-marking-lines where       utd-marking-lines.db-num     = utd-lines.db-num
                                                          and utd-marking-lines.doc-id     = utd-lines.doc-id
                                                          and utd-marking-lines.Linenum    = utd-lines.Linenum
                           no-lock no-error.
                           if not available utd-marking-lines
                           then do:
                              vtext = vunit:Value.
                              do viii = 1 to num-entries(vtext," "):
                                 VValue = entry(viii,vtext," ").
                                 addMarkforUtd (utd-lines.db-num ,
                                          utd-lines.doc-id,
                                          utd-lines.Linenum,
                                          VValue,
                                          "",
                                          iDocument:type).
                              end.
                           end.
                        end.
                        if vunit:Id eq "Документ о соответствии" then do:
                          define variable v-sert-value as character no-undo .
                          find first utd-lines-attr exclusive-lock where utd-lines-attr.doc-id = utd-lines.doc-id and
                          utd-lines-attr.db-num = utd-lines.db-num and
                          utd-lines-attr.LineNum = utd-lines.LineNum and
                          utd-lines-attr.attr-code = "doc_sertif" no-error .
                          if available (utd-lines-attr) then utd-lines-attr.attr-value = utd-lines-attr.attr-value + "; " + vunit:value .
                          else setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"doc_sertif",vunit:value).
                        end.
                        release object  vunit.
                     end.
                     release object  vunits.
                     release utd-lines.
                     release object vExtendedInvoiceItem.
                  end.
                  release object vItems.
               end.
               else do:
                  PutMes("Ошибка получения данных из Диадок UniversalTransferDocumentWithHyphens").
                  release object vDocumentChild.
                  return error "Ошибка получения данных из Диадок UniversalTransferDocumentWithHyphens".
               end.
            end.
            else do:
               vContent = vDocumentChild:UniversalCorrectionDocument.
               if vContent ne ?
               then do:
                  getdesc(vContent).
                  getdesc(vContent:Seller).
                  getdesc(vContent:EventContent).
                  getdesc(vContent:EventContent:CorrectionBase).
                  getOrganizationInfo(vContent:Seller,output utd.cli-inn,output utd.cli-kpp,utd.cli-FnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
                  utd.cli-info = vorgname + " " + vAddrOrg.
                  do:
                      vInvoiceTable = vContent:Table.
                      getdesc(vInvoiceTable).
                      getdesc(vInvoiceTable:TotalsInc).
                      getdesc(vInvoiceTable:TotalsDec).
                      getdesc(vInvoiceTable:Items).
                      getdesc(vInvoiceTable:Items:item).
                      vItems = vInvoiceTable:Items:item.
                      release object vInvoiceTable.
                      do vi = 1 to vItems:Count:
                         vExtendedInvoiceItem = vItems:GetItem(vi - 1).
                         getdesc(vExtendedInvoiceItem).
                         getdesc(vExtendedInvoiceItem:AdditionalInfos ).
                         getdesc(vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo ).
                         find first utd-lines where utd-lines.db-num     = utd.db-num
                                                and utd-lines.doc-id     = utd.doc-id
                                                and utd-lines.LineNum    = vi
                         exclusive-lock no-error.
                         if not available  utd-lines
                         then do:
                            create utd-lines.
                            assign
                               utd-lines.db-num   = utd.db-num
                               utd-lines.doc-id   = utd.doc-id
                               utd-lines.Linenum  = vi
                               utd-lines.gds-code = ?
                            .
                         end.
                         utd-lines.ProductCode = vExtendedInvoiceItem:Product.
                         vValues = vExtendedInvoiceItem:CorrectedValues no-error.
                         if vValues ne ?
                         then do:
                            getdesc(vExtendedInvoiceItem:OriginalValues ).
                            getdesc(vExtendedInvoiceItem:CorrectedValues ).
                            getdesc(vExtendedInvoiceItem:AmountsInc ).
                            getdesc(vExtendedInvoiceItem:AmountsDec ).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Unit",string(vValues:unit)).
                            define variable vQuantity as decimal no-undo.
                            vQuantity    = vValues:Quantity.
                            utd-lines.Price       = vValues:Price.
                            utd-lines.TotalWithVatExcluded   = vValues:SubtotalWithVatExcluded.
                            utd-lines.TaxRate   =   if  vValues:TaxRate eq "без ндс" then -1 else decimal(trim(entry(1,vValues:TaxRate,"/"),"%")).
                            utd-lines.Vat       = vValues:Vat.
                            utd-lines.Total     = vValues:Subtotal.
                            release object vValues.
                            vValues = vExtendedInvoiceItem:OriginalValues.
                            vQuantity    = vQuantity - vValues:Quantity.
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity",string(vQuantity)).
                            utd-lines.Price       = utd-lines.Price - vValues:Price.
                            utd-lines.Vat       = utd-lines.Vat - vValues:Vat.
                            utd-lines.Total     = utd-lines.Total  - vValues:Subtotal.
                            utd-lines.TotalWithVatExcluded   = utd-lines.TotalWithVatExcluded - vValues:SubtotalWithVatExcluded.
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity_old",string( vValues:Quantity)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Price_old"   ,string( vValues:Price)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"TotalWithVatExcluded", string( vValues:SubtotalWithVatExcluded)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"TaxRate_old", string(  if  vValues:TaxRate eq "без ндс" then -1 else decimal(trim(entry(1,vValues:TaxRate,"/"),"%")))).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Vat_old"    , string( vValues:Vat)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Total_old",       string( vValues:Subtotal)).
                            release object vValues.
                            vunits = vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo.
                            do vii = 1 to vunits:count:
                               vunit = vunits:GETITEM(vii - 1).
                               getdesc(vunit).
                               if     vunit:Id eq "cis"
                                  or vunit:Id eq "cis_до"
                                  or vunit:Id eq "sscc"
                                  or vunit:Id eq "sscc_до"
                               then do:
                                  vtext = vunit:Value.
                                  if vtext ne "-"
                                  then do viii = 1 to num-entries(vtext," "):
                                     VValue = entry(viii,vtext," ").
                                     vsite = if     vunit:Id eq "cis" or vunit:Id eq "sscc" then "+" else "-".
                                     addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, vsite,iDocument:type).
                                  end.
                               end.
                               release object vunit.
                            end.
                            do vii = 1 to vunits:count:
                               vunit = vunits:GETITEM(vii - 1).
                               getdesc(vunit).
                               if     vunit:Id eq "штрихкод"
                                   or vunit:Id eq "ean"
                               then do:
                                  setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,vunit:Id,vunit:value).
                                  setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"BarCode",vunit:value).
                                  find first utd-marking-lines where       utd-marking-lines.db-num     = utd-lines.db-num
                                                                 and utd-marking-lines.doc-id     = utd-lines.doc-id
                                                                 and utd-marking-lines.Linenum    = utd-lines.Linenum
                                  no-lock no-error.
                                  if not available utd-marking-lines
                                  then do:
                                    vtext = vunit:Value.
                                    do viii = 1 to num-entries(vtext," "):
                                       VValue = entry(viii,vtext," ").
                                       addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, "",iDocument:type).
                                    end.
                                 end.
                              end.
                              release object  vunit.
                           end.
                            release object vunits.
                            release utd-lines.
                            release utd-marking-lines.
                         end.
                         else do:
                            getdesc(vExtendedInvoiceItem:OriginalItemIdentificationNumbers ).
                            getdesc(vExtendedInvoiceItem:OriginalItemIdentificationNumbers:ItemIdentificationNumber).
                            vunits = vExtendedInvoiceItem:OriginalItemIdentificationNumbers:ItemIdentificationNumber.
                            getdesc(vunits).
                            vsite =  "-".
                            do vii = 1 to vunits:count:
                               getdesc(vunits:GETITEM(vii - 1)).
                               vunit = vunits:GETITEM(vii - 1):unit.
                               getdesc(vunit).
                               do viii = 1 to vunit:count:
                                  vvalue = vunit:GETITEM(viii - 1).
                                  addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, vsite,iDocument:type).
                               end.
                               release object vunit.
                               vunit = vunits:GETITEM(vii - 1):PackageId.
                               getdesc(vunit).
                               do viii = 1 to vunit:count:
                                  vvalue = vunit:GETITEM(viii - 1).
                                  addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, vsite,iDocument:type).
                               end.
                               release object vunit.
                            end.
                            release object vunits.
                            getdesc(vExtendedInvoiceItem:CorrectedItemIdentificationNumbers).
                            vunits = vExtendedInvoiceItem:CorrectedItemIdentificationNumbers:ItemIdentificationNumber.
                            getdesc(vunits).
                            vsite =  "+".
                            do vii = 1 to vunits:count:
                               getdesc(vunits:GETITEM(vii - 1)).
                               vunit = vunits:GETITEM(vii - 1):unit.
                               getdesc(vunit).
                               do viii = 1 to vunit:count:
                                  vvalue = vunit:GETITEM(viii - 1).
                                  addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, vsite,iDocument:type).
                               end.
                               release object vunit.
                               vunit = vunits:GETITEM(vii - 1):PackageId.
                               getdesc(vunit).
                               do viii = 1 to vunit:count:
                                  vvalue = vunit:GETITEM(viii - 1).
                                  addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, vsite,iDocument:type).
                               end.
                               release object vunit.
                            end.
                            release object vunits.
                            getdesc(vExtendedInvoiceItem:TaxRate ).
                            getdesc(vExtendedInvoiceItem:UnitName ).
                            getdesc(vExtendedInvoiceItem:Unit ).
                            getdesc(vExtendedInvoiceItem:Quantity ).
                            getdesc(vExtendedInvoiceItem:Price ).
                            getdesc(vExtendedInvoiceItem:Excise ).
                            getdesc(vExtendedInvoiceItem:SubtotalWithVatExcluded ).
                            getdesc(vExtendedInvoiceItem:Vat ).
                            getdesc(vExtendedInvoiceItem:WithoutVat).
                            getdesc(vExtendedInvoiceItem:Subtotal ).
                            getdesc(vExtendedInvoiceItem:ItemTracingInfos ).
                            getdesc(vExtendedInvoiceItem:ItemTracingInfos:ItemTracingInfo ).
                            vValues = vExtendedInvoiceItem:CorrectedItemIdentificationNumbers.
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Unit",string(vExtendedInvoiceItem:Unit:CorrectedValue)).
                            utd-lines.Price       = vExtendedInvoiceItem:Price:CorrectedValue.
                            utd-lines.TotalWithVatExcluded   = vExtendedInvoiceItem:SubtotalWithVatExcluded:CorrectedValue.
                            utd-lines.UnitCode    = vExtendedInvoiceItem:UnitName:CorrectedValue.
                            utd-lines.TaxRate   =   if  vExtendedInvoiceItem:TaxRate:CorrectedValue eq "без ндс" then -1 else decimal(trim(entry(1,vExtendedInvoiceItem:TaxRate:CorrectedValue,"/"),"%")).
                            utd-lines.Vat       = vExtendedInvoiceItem:Vat:CorrectedValue.
                            utd-lines.Total     = vExtendedInvoiceItem:Subtotal:CorrectedValue.
                            vQuantity    = dec(vExtendedInvoiceItem:Quantity:CorrectedValue) - dec(vExtendedInvoiceItem:Quantity:OriginalValue).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity",string(vQuantity)).
                            utd-lines.Price       = utd-lines.Price - vExtendedInvoiceItem:Price:OriginalValue.
                            utd-lines.Vat       = utd-lines.Vat - vExtendedInvoiceItem:Vat:OriginalValue.
                            utd-lines.Total     = utd-lines.Total  - vExtendedInvoiceItem:Subtotal:OriginalValue.
                            utd-lines.TotalWithVatExcluded   = utd-lines.TotalWithVatExcluded - vExtendedInvoiceItem:SubtotalWithVatExcluded:OriginalValue.
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity_old",string( vExtendedInvoiceItem:Quantity:OriginalValue)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Price_old"   ,string( vExtendedInvoiceItem:Price:OriginalValue)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"TotalWithVatExcluded", string( vExtendedInvoiceItem:SubtotalWithVatExcluded:OriginalValue)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"TaxRate_old", string(  if  vExtendedInvoiceItem:TaxRate:OriginalValue eq "без ндс" then -1 else decimal(trim(entry(1,vExtendedInvoiceItem:TaxRate:OriginalValue,"/"),"%")))).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Vat_old"    , string( vExtendedInvoiceItem:Vat:OriginalValue)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Total_old",       string( vExtendedInvoiceItem:Subtotal:OriginalValue)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"UnitCode_old", vExtendedInvoiceItem:UnitName:OriginalValue).
                         end.
                         vunits = vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo.
                         getdesc(vunits).
                         do vii = 1 to vunits:count:
                            vunit = vunits:GETITEM(vii - 1).
                            getdesc(vunit).
                            if     vunit:Id eq "штрихкод"
                                or vunit:Id eq "ean"
                            then do:
                               setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,vunit:Id,vunit:value).
                               setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"BarCode",vunit:value).
                               find first utd-marking-lines where       utd-marking-lines.db-num     = utd-lines.db-num
                                                              and utd-marking-lines.doc-id     = utd-lines.doc-id
                                                              and utd-marking-lines.Linenum    = utd-lines.Linenum
                               no-lock no-error.
                               if not available utd-marking-lines
                               then do:
                                 vtext = vunit:Value.
                                 do viii = 1 to num-entries(vtext," "):
                                    VValue = entry(viii,vtext," ").
                                    addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, "",iDocument:type).
                                 end.
                              end.
                           end.
                           release object  vunit.
                        end.
                        release object  vunits.
                         release object vExtendedInvoiceItem.
                      end.
                      release object vItems.
                  end.
                  release object vContent.
               end.
               else do:
                  create tt-recid.
                  assign
                     tt-recid.orgid = vOrganizationGuid
                     tt-recid.docid = vDocumentid
                  .
                  PutMes("Error Ошибка получения данных из Диадок UniversalCorrectionDocument").
                  release object vDocumentChild.
                  return error "Ошибка получения данных из Диадок UniversalCorrectionDocument".
               end.
            end.
         end.
         release object vDocumentChild.
         define variable vsetPAck as logical no-undo.
         define variable vcli-type as character no-undo.
         define variable vcli-code as integer no-undo.
         find first ext-classif where ext-classif.classif-name  eq 'id_diadok_client':U
                                  and ext-classif.charkey_three eq utd.cli-FnsParticipantId
         no-lock no-error.
         if available ext-classif
         then do:
            assign
               vcli-type = ext-classif.CharKey_One
               vcli-code = ext-classif.Key#_One
            .
            define variable vPack as character no-undo.
            if   iDocument:type eq "UniversalTransferDocument"
            then
               vPack = substitute("&1|&2|&3|&4",vcli-type,vcli-code,utd.DocumentNumber,utd.DocumentDate).
            else if iDocument:type eq "UniversalTransferDocumentRevision"
            then
               vPack = substitute("&1|&2|&3|&4",vcli-type,vcli-code,iDocument:OriginalDocumentNumber,date(iDocument:OriginalDocumentDate)).
            else
               vPack = substitute("&1|&2|&3|&4",vcli-type,vcli-code,iDocument:OriginalInvoiceNumber,date(iDocument:OriginalInvoiceDate)).
            if vPack ne utd.PackageId
            then
               assign
                  vsetPAck      = yes
                  utd.PackageId = vPack
               .
         end.
         if vNewUtd or vsetPAck then do:
            if utd.EDocType eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
            then do:
               if vNewUtd  then do:
                  GetLastUTDinPackbef(utd.db-num,utd.doc-id,volddb-num,volddoc-id).
                  find first old_utd where old_utd.db-num eq volddb-num
                                       and old_utd.doc-id eq volddoc-id
                     no-lock no-error.
                  for each utd-marking-lines where utd-marking-lines.db-num eq utd.db-num
                                               and utd-marking-lines.doc-id eq utd.doc-id
                  exclusive-lock:
                     if available old_utd
                        and utd.db-num ne volddb-num
                        and utd.doc-id ne volddoc-id
                     then
                        find first buf_utd-marking-lines where buf_utd-marking-lines.mark       = utd-marking-lines.mark
                                                           and buf_utd-marking-lines.db-num     = old_utd.db-num
                                                           and buf_utd-marking-lines.doc-id     = old_utd.doc-id
                        no-lock no-error.
                     utd-marking-lines.sts = if available buf_utd-marking-lines then buf_utd-marking-lines.sts else  objSrv:Env:marking:Sts:Mark:PendingVerification:KeyIntDB.
                  end.
                  validate utd.
                  ReCheckload( utd.db-num, utd.doc-id,yes).
                  subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
               end.
            end.
            else do:
               GetLastUTDinPack (utd.db-num,utd.doc-id,volddb-num,volddoc-id).
               find first old_utd where old_utd.db-num eq volddb-num
                                    and old_utd.doc-id eq volddoc-id
               no-lock no-error.
               if not available old_utd
                  or (   utd.db-num eq volddb-num
                     and utd.doc-id eq volddoc-id)
               then
                  AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoAvailDoc",string(utd.PackageId) + chr(4) + string(utd.db-num) + chr(4) + string(utd.doc-id)).
               else do:
                   assign
                       utd.obj-inn               = old_utd.obj-inn
                       utd.obj-kpp               = old_utd.obj-kpp
                       utd.obj-FnsParticipantId  = old_utd.obj-FnsParticipantId
                       utd.obj-info              = old_utd.obj-info
                       utd.parentDocumentExt     = old_utd.DocumentExt
                       utd.parentOrganizationExt = old_utd.OrganizationExt
                       utd.contract-code         = old_utd.contract-code
                   .
               end.
               validate utd.
               SaturateAndCheckUTD( utd.db-num, utd.doc-id).
            end.
         end.
         GetLastUTDinPack (utd.db-num,utd.doc-id,volddb-num,volddoc-id).
         find first old_utd where old_utd.db-num eq volddb-num
                              and old_utd.doc-id eq volddoc-id
         no-lock no-error.
         if available old_utd
         then
            assign
               utd.parentDocumentExt     = old_utd.DocumentExt
               utd.parentOrganizationExt = old_utd.OrganizationExt
            .
         create tt-recid.
         assign
            tt-recid.orgid = vOrganizationGuid
            tt-recid.docid = vDocumentid
         .
         if utd.EDocType = objSrv:Env:Utd:EDocType:UCD:KeyIntDB
         then do:
            tt-recid.parent = utd.PackageId.
            tt-recid.stamp  = utd.Timestamp.
         end.
         release utd no-error.
         if error-status:error
         then
            PutMes(substitute("Документ &1 от &2 не загружен. &3" ,iDocument:DocumentNumber,iDocument:DocumentDate,return-value) ).
         else
            PutMes(substitute("Документ &1 от &2 загружен." ,iDocument:DocumentNumber,iDocument:DocumentDate) ).
         unsubscribe "getNextseq".
      end.
   end.
end.
function packetupdd returns date
(iOrganization as component-handle, iDocument as component-handle):
   define variable VPack as character no-undo.
   define variable vorgid as character no-undo.
   define variable vdocid as character no-undo.
   define variable vstamp as datetime no-undo.
   define variable VPack2 as character no-undo.
   define variable vorgid2 as character no-undo.
   define variable vdocid2 as character no-undo.
   define variable vstamp2 as datetime no-undo.
   define variable VPackage as component-handle no-undo.
   define variable vi as integer no-undo.
   define variable vDocument as component-handle no-undo.
   define variable vDocuments as component-handle no-undo.
      VPack = iDocument:PackageId.
      vorgid = iDocument:OrganizationGuid.
      vdocid = iDocument:DocumentId.
      vstamp = iDocument:Timestamp.
      find first tt-pack where tt-pack.packid eq VPack
                           and tt-pack.stamp  eq vstamp
                           and tt-pack.orgid  eq vorgid
                           and tt-pack.docid  eq vdocid
      no-lock no-error.
      if not available tt-pack
      then do:
         create tt-pack.
         assign
            tt-pack.packid = VPack
            tt-pack.stamp  = vstamp
            tt-pack.orgid  = vorgid
            tt-pack.docid  = vdocid
         .
      end.
      getdesc(iDocument ).
      getdesc(iDocument:InitialDocumentIds ).
      vDocuments = iDocument:InitialDocumentIds.
      do vi= 1 to vDocuments:Count:
         vDocument = iOrganization:GetDocumentById(vDocuments:GetItem(vi - 1),false).
         getdesc(vDocument ).
         vorgid2 = vDocument:OrganizationGuid.
         vdocid2 = vDocument:DocumentId.
         vstamp2 = vDocument:Timestamp.
         find first tt-pack where tt-pack.packid eq VPack
                              and tt-pack.stamp  eq vstamp2
                              and tt-pack.orgid  eq vorgid2
                              and tt-pack.docid  eq vdocid2
         no-lock no-error.
         if not available tt-pack
         then do:
            create tt-pack.
            assign
               tt-pack.packid = VPack
               tt-pack.stamp  = vstamp2
               tt-pack.orgid  = vorgid2
               tt-pack.docid  = vdocid2
            .
         end.
         release object vDocument.
      end.
      release object vDocuments.
end.
procedure UpdateUTDInform:
   define input  parameter ibeg-date as date no-undo.
   define input  parameter iend-date as date no-undo.
   define output parameter odatelast as date no-undo.
   define variable vOrganizationList as component-handle no-undo.
   define variable vOrganization as component-handle no-undo.
   define variable vDocumentsTask as component-handle no-undo.
   define variable vDocumentList  as component-handle no-undo.
   define variable vDocumentchildList  as component-handle no-undo.
   define variable vDocument       as component-handle no-undo.
   define buffer ext-classif_obj for ext-classif.
   define buffer ext-classif_Cli  for ext-classif.
   define variable vi  as integer no-undo.
   define variable vii as integer no-undo.
   odatelast = ibeg-date.
   vOrganizationList = mDiadocConnection:GetOrganizationList() no-error.
   if vOrganizationList eq ? then return error ?.
   vi = vOrganizationList:Count()no-error.
   if vi eq ?
   then
      return error ?.
   for each tt-recid:
      delete tt-recid.
   end.
   for each tt-pack:
      delete tt-pack.
   end.
   do vi = 1 to vOrganizationList:Count() :
      vOrganization = vOrganizationList:GetItem(vi - 1 ).
      getdesc(vOrganization).
      run changeIdtoGuid(vOrganization).
      vDocumentsTask = vOrganization:GetDocumentsTask().
                  vDocumentsTask:FromSendDate = ibeg-date  .
                  vDocumentsTask:ToSendDate   = iend-date.
                  for each tt-type, each tt-Class:
                      vDocumentsTask:Category     = tt-type.id + "." + tt-Class.id.
                     PutMes(substitute("Формируем список зависимых документов за период с &2 по &3  &1Категория: &4 &5",
                                       chr(10),
                                       ibeg-date ,
                                       iend-date,
                                       if tt-type .id eq "Any" then "" else tt-type.name,
                                       tt-Class.name)).
                      vDocumentList = vDocumentsTask:GetDocuments() no-error.
                      if vDocumentList ne ?
                      then do:
                        do vii= 1 to vDocumentList:Count:
                           if chekStop() then return ?.
                           vDocument = vDocumentList:GetItem(vii - 1).
                           odatelast = max(odatelast,vDocument:DocumentDate) no-error.
                           odatelast = min(odatelast,today).
                           packetupdd(vOrganization, vDocument).
                           release object vDocument.
                         end.
                         release object vDocumentList.
                      end.
                   end.
                   define variable VAlldoc    as integer no-undo.
                   define variable vprocessed as integer no-undo.
                   for each tt-pack :
                      VAlldoc = VAlldoc + 1.
                   end.
                   for each tt-pack :
                       if chekStop() then return ?.
                      if GetDocumforid (tt-pack.orgid, tt-pack.docid, output vDocument) eq ""
                      then do:
                          run  UpdateUTDInformOne(vDocument).
                         release object vDocument.
                     end.
                     vprocessed = vprocessed + 1.
                     PutStat (substitute ("Обработано документов &1 из &2",vprocessed,vAllDoc),yes).
                  end.
      release object vOrganization.
      release object vDocumentsTask.
   end.
   release object vOrganizationList.
end.
procedure updOneUTD:
   define input  parameter idb-num as integer no-undo.
   define input  parameter idoc-id as integer no-undo.
   define variable vDocument as component-handle no-undo.
   define buffer utd for utd.
   for each tt-recid:
      delete tt-recid.
   end.
   if getdocum (idb-num, idoc-id, output vDocument) eq ""
   then do:
       run  UpdateUTDInformOne(vDocument).
      release object vDocument.
   end.
end.
function CRnewDocum return character
(
iOrgGuid as character,
iContGuid as character,
iTypeUTD as character,
 iFile as character
 ):
define variable vOrganization as component-handle no-undo.
define variable vSendTask as component-handle no-undo.
    vOrganization = mDiadocConnection:GetOrganizationById(iOrgGuid ) no-error.
    if vOrganization ne ?
    then do:
       vSendTask = vOrganization:CreatePackageSendTask2().
       getdesc(vSendTask).
       vSendTask:CounteragentId = iContGuid  .
       vSendTask:AddDocumentFromFile("UniversalTransferDocument", iTypeUTD, "utd820_05_01_01", iFile).
       vSendTask:Send()no-error.
       if error-status:num-messages > 0 then do:
          PutErr("ERROR Ошибка отправки документа").
          return error "ERROR Ошибка отправки документа".
       end.
       else do:
          PutMes("Документ отправлен успешно.").
          message "Документ отправлен успешно."
          view-as alert-box.
       end.
       release object vSendTask.
      release object vOrganization .
   end.
end.
procedure MySeqForUtd:
   define input  parameter iTable       as character no-undo.
   define input  parameter iseqnamehist as character no-undo.
   define input  parameter idb-name     as character no-undo.
   define output parameter Oseq         as int64 no-undo.
   if iTable begins "utd"
   then do:
      if myseqUtd eq ?
      then
         myseqUtd = dynamic-next-value(iseqnamehist,idb-name).
      Oseq = myseqUtd.
   end.
   else
      Oseq = ?.
   return.
end.
define temp-table tt-utd like ub.utd
  field stts        as character
  field stts-edi    as character
  field cli-name    as character
  field EDoTypeName as character
  field ModifyTime_ as character
  field orig-code   as character
  field GrayZone    as logical
  field obj-name    as character
  field is-initial  as character
  field scan-qnty   as decimal
  field free-qnty   as decimal
  .
define temp-table tt-sert-utd
  field doc-id like ub.utd.doc-id
  field db-num like ub.utd.db-num
  field DocumentDate like ub.utd.DocumentDate
  field DocumentNumber like ub.utd.DocumentNumber
  field cli-code as integer
  field cli-type as character
  index pi  db-num doc-id
  .
define temp-table tt-utd-lines-filtr no-undo
    field db-num  as integer
    field doc-id  as integer
    field linenum as integer
    field bar-code as character
    index pi  db-num doc-id LineNum
    index bar-code bar-code db-num doc-id LineNum
.
define temp-table tt-utd-lines like ub.utd-lines
  field qnty-scan as decimal
  field qnty-mark as integer
  field stts      as character
  field gds-name  as character
  field TaxRate_  as character
  field fact-qnty as decimal
  field free-qnty as decimal
  field sts_err   as logical
  field DelivCodeMis   as logical
  field UnitCli   as character
  field UnitCliQnty as decimal
  field isMarking   as logical
  field isArtic     as logical
  field isWeight    as logical
  field isVarWeight as logical
  field isSelect    as logical
  field markType    as character
  field PieceTTH    as character
  field PieceFact   as character
  index pi  db-num doc-id LineNum
  index gds-code gds-code
  index sts stts sts
  .
define temp-table tt-marking-lines no-undo like ub.marking-lines
  field mark-parent like ub.marking.mark-parent
  field stts        as character
  field sts-utd     as integer
  field stts-utd    as character
  field unit        as character
  field unit-ext    as character
  field site        as character
  field box-qnty    as decimal
  field gds-name    as character
  field db-num      as integer
  field doc-id      as integer
  field LineNum     as integer
  field GrayZone    as logical
  field isMark      as logical
  field isWeight    as logical
  field marking-string as character
  field old-sts     as integer
  field weight      as character
  index pi  doc-level   sts
  index pi2 mark-parent sts
  index pi3 unit-ext
  index pi4 mark obj-type obj-code gds-code in-code out-code part-code prt-code
  index part gds-code obj-type obj-code in-code out-code part-code prt-code
  index gds-code gds-code
  index obj obj-code obj-type
  .
define temp-table tt-mark-line like ub.marking-lines
  field date_    as date
  field doc-type as character
  field type     as integer
  field doc-id   as integer
  field db-num   as integer
  field EdocType as integer
  index pi mark out-code doc-type .
define temp-table tt-marking like ub.marking
  .
define temp-table tt-utd-marking-lines like ub.utd-marking-lines
  .
define temp-table tt-inv-marking no-undo
  field gds-code      as integer
  field gds-name      as character
  field qnty          as decimal
  field qnty-scan     as decimal
  field qnty-confirm  as integer
  field qnty-scan-not as integer
  field qnty-not      as integer
  index pi gds-code
  .
define temp-table tt-tech-mark no-undo
  field gds-code      as integer
  field gds-name      as character
  field qnty-fact     as integer
  field qnty-doc      as integer
  field doc-code      as character
  field line-num      as integer
  index pi as UNIQUE doc-code line-num gds-code
  .
define temp-table tt-utd-err like ub.utd-err
  field descr as character
  field gds-code as integer
  field LineNum  as integer
  field type     as integer
  .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ext-system-attr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-value :
  define input  parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-value     like ub.ext-system-attr.esya-attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-value in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-write :
  define input parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define input parameter p-value     like ub.ext-system-attr.esya-attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-write in g#attr-lib
      (input p-esys-id
      ,input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-exist :
  define input  parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-exist in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-delete :
  define input  parameter p-esys-id  like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num   like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code     like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-delete in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-uf-List_        like ubflt.usr-flt.List_        no-undo .
define variable v-uf-Naim         like ubflt.usr-flt.Naim         no-undo .
define variable v-uf-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
define variable v-uf-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
define variable v-uf-type-price   like ubflt.usr-flt.type-price   no-undo .
define variable v-uf-type-val     like ubflt.usr-flt.type-val     no-undo .
define temp-table usr-flt_custom-labels no-undo like ub.custom-labels.
procedure uf-name :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define output parameter p-use-List_     as logical   no-undo .
  define output parameter p-type-List_     as character no-undo .
  define output parameter p-format-List_   as character no-undo .
  define output parameter p-use-Naim      as logical   no-undo .
  define output parameter p-type-Naim      as character no-undo .
  define output parameter p-format-Naim    as character no-undo .
  define output parameter p-use-print-graft as logical   no-undo .
  define output parameter p-use-sort-gr   as logical   no-undo .
  define output parameter p-use-type-price as logical   no-undo .
  define output parameter p-use-type-val  as logical   no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-tooltip        as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'cli-all-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'oldscode':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника неиспользуемых весовых кодов"     p-tooltip = "Настройки справочника неиспользуемых весовых кодов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-ref-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(8)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = yes      p-label = "Параметры вызова справочника товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fbr-gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп блюд"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп блюд"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findoci-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findocs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника платежей"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-obi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'seqeallo':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Порядок колонок в АВТО-ЗАКАЗЕ"     p-tooltip = "Порядок колонок в РАСЧЕТЕ потребности заказа и его импорте"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'skm-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова выгрузки файла данных по продажам по СКМ"     p-tooltip = "Параметры по умолчанию, используемые для вызова выгрузки файла данных по продажам по СКМ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'imp-goods':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Импорт в карточке товара"     p-tooltip = "Заполнение по умолчанию параметров импорта товаров из карточки товара"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'discards-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник ДК"     p-tooltip = "Справочник дисконтных карт"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'finsttms-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника банковских выписок"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника банковских выписок"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список фин.обязательств"     p-tooltip = "Список фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'mpl-gds-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список цен по товару"     p-tooltip = "Список цен по товару"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'tpl-mode-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список мод"     p-tooltip = "Список мод"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-sost-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Состояние заказа"     p-tooltip = "Просмотр несоответствий поставок и накладных по заказам ОП ФП и ПО"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'planplat-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Планирование платежей"     p-tooltip = "Планирование платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа"     p-tooltip = "Форма ввода заказа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОП"     p-tooltip = "Форма ввода заказа ОП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pФП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ФП"     p-tooltip = "Форма ввода заказа ФП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОФ':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОФ"     p-tooltip = "Форма ввода заказа ОФ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'list-abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список заголовков ABC-анализа"     p-tooltip = "Список заголовков ABC-анализа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "ABC-анализ"     p-tooltip = "ABC-анализ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-rc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Заказ О-РЦ"     p-tooltip = "Заказ О-РЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cfin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список удаленных фин.обязательств"     p-tooltip = "Список удаленных фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'color-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = yes      p-use-type-price = no      p-use-type-val = no      p-label = "Раскрасить экран"     p-tooltip = "Изменение цветовой палитры брауза"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bon1-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-tooltip = "Параметры вызова отчета НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-shift':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Сменный отчет"     p-tooltip = "Сменный отчет"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsreffi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник товаров - доп поля"     p-tooltip = "Справочник товаров - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsfrmfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Карточка товара - доп поля"     p-tooltip = "Карточка товара - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-g':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrst':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = YES      p-use-type-val =       p-label = "Остатки МЦ"     p-tooltip = "Остатки МЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthcom':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = no      p-use-type-val =       p-label = "Сводный отчет о реализованных талонах"     p-tooltip = "Сводный отчет о реализованных талонах"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'bge-active-vbrr':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper-new':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов(расширенный)"     p-tooltip = "Параметры для выгрузки документов(расширенный)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/i-egais.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Интерфейс импорта классификатора ЕГАИС"     p-tooltip = "Интерфейс импорта классификатора ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'alc-rees':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр документов ЕГАИС"     p-tooltip = "Реестр документов ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-optprc.w':U then do:     assign     p-use-List_ = no      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оптовый прайс-лист"     p-tooltip = "Оптовый прайс-лист"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/iecliart.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Процедуры импорта экспорта артикулов поставщиков"     p-tooltip = "Процедуры импорта экспорта артикулов поставщиков"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthps-zone':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthparts-obj':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '&bef-wthsref-stts}':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrd':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthob':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-type':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-stts':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = yes      p-use-type-price = yes      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-sup':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-wth':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-ptlbal':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ctrasm':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Контроль ассортиментной матрицы"     p-tooltip = "Контроль ассортиментной матрицы"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-eslg-e':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'prphoto':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(2256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(2256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Прайс-лист с фото товаров"     p-tooltip = "Прайс-лист с фото товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkgdsfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Товарная строка чека - доп поля"     p-tooltip = "Товарная строка чека - доп поля "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkdocfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Чек - доп поля"     p-tooltip = "Чек - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'barcodfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Бар-код - доп поля"     p-tooltip = "Бар-код - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'UPD':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника Электронного документоборота"     p-tooltip = "Настройки справочника Электронного документоборота"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'LK_RECEIPT':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-tooltip = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
      otherwise do:
        undo, return error "неизвестная настройка пользователя usr-flt" + " " + p-code .
      end.
    end CASE.
  end.
end procedure.
procedure uf-get :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define output parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define output parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define output parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define output parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define output parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define output parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr     as logical   no-undo .
    define variable v-use-type-price  as logical   no-undo .
    define variable v-use-type-val    as logical   no-undo .
    define variable v-label          as character no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
       (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt no-lock where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if avail buf_usr-flt then do:
      assign
      p-List_        = (if v-use-List_       then buf_usr-flt.List_       else ?)
      p-Naim         = (if v-use-Naim        then buf_usr-flt.Naim        else ?)
      p-print-graft  = (if v-use-print-graft then buf_usr-flt.print-graft else ?)
      p-sort-gr      = (if v-use-sort-gr     then buf_usr-flt.sort-gr     else ?)
      p-type-price   = (if v-use-type-price  then buf_usr-flt.type-price  else ?)
      p-type-val     = (if v-use-List_       then buf_usr-flt.type-val    else ?)
      .
    end.
    else do:
      assign
      p-List_        = (if v-use-List_       then "":U                    else ?)
      p-Naim         = (if v-use-Naim        then "":U                    else ?)
      p-print-graft  = (if v-use-print-graft then no                      else ?)
      p-sort-gr      = (if v-use-sort-gr     then no                      else ?)
      p-type-price   = (if v-use-type-price  then no                      else ?)
      p-type-val     = (if v-use-List_       then no                      else ?)
      .
    end.
  end.
end procedure.
procedure uf-set :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define input  parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define input  parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define input  parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define input  parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define input  parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define input  parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr   as logical   no-undo .
    define variable v-use-type-price as logical   no-undo .
    define variable v-use-type-val  as logical   no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
      (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if not avail buf_usr-flt then do:
        create buf_usr-flt .
        assign
        buf_usr-flt.call-point = p-code
        buf_usr-flt.user-name  = p-user-name
        .
    end.
    if avail buf_usr-flt then do:
     assign
     buf_usr-flt.List_       =  (if v-use-List_       then  p-List_        else ?)
     buf_usr-flt.Naim        =  (if v-use-Naim        then  p-Naim         else ?)
     buf_usr-flt.print-graft =  (if v-use-print-graft then  p-print-graft  else ?)
     buf_usr-flt.sort-gr     =  (if v-use-sort-gr     then  p-sort-gr      else ?)
     buf_usr-flt.type-price  =  (if v-use-type-price  then  p-type-price   else ?)
     buf_usr-flt.type-val    =  (if v-use-List_       then  p-type-val     else ?)
    .
    release buf_usr-flt.
    end.
    else undo, return error ("Ошибка при записи usr-flt" + substitute(" call-point=&1, user-name=&2", p-code, p-user-name)).
  end.
end procedure.
define variable log-res-Token           as log         no-undo.
define variable log-res-recheck         as logical     no-undo .
define variable varlog                  as logical     no-undo .
define variable rr                      as recid       no-undo.
define variable v_type                  as char        no-undo.
define variable v-is-deploy             as logical     no-undo .
define variable v-rid-list              as character   no-undo .
define variable v-db-list               as character   no-undo .
define variable v-sertif                as character   no-undo .
define variable v-sertif_num            as character   no-undo .
define variable Vflaginout as logical no-undo.
define variable vToken                  as character   no-undo .
define variable row_utd                 as rowid       no-undo .
define variable recid_utd               as integer     no-undo .
define variable ii                      as integer     no-undo .
define variable v-time                  as integer     no-undo .
define variable time_old_start          as datetime-tz no-undo.
define variable v-Token-error           as logical     no-undo initial false.
define variable time_motp               as datetime-tz no-undo.
define variable vtime                   as int64       no-undo.
define variable mflagExit               as logical     no-undo.
define variable v-flag                  as logical     no-undo .
define variable v-void-logical          as logical     no-undo .
define variable v-current-sort-string   as character   no-undo .
define variable v-current-sertif-string as character   no-undo .
define variable mode-erprn              as logical     no-undo .
define variable conf-par                as character   no-undo .
define variable par-type                as character   no-undo .
define VARIABLE v-mes-Token             as LOGICAL     no-undo .
define buffer buf_utd     for ub.utd .
define buffer buf_clients for ub.clients .
define temp-table tt-obj-list no-undo
    field obj-code as integer
    field obj-type as character
    .
define temp-table tt-sertif no-undo
    field Name_                          as character
    field BeginDate                      as datetime
    field EndDate                        as datetime
    field Thumbprint                     as character
    field IssuerName                     as character
    field OrganizationName               as character
    field SerialNumber                   as character
    field IsQualifiedElectronicSignature as character
    field INN                            as character
    field KPP                            as character
    field JobTitle                       as character
    field CanEncrypt                     as character
    .
define variable StatusTH  as class ibs.th.str.utd.sts.th   no-undo .
define variable StatusEDI as class ibs.th.str.utd.sts.edi  no-undo .
define variable EdocType  as class ibs.th.str.utd.edoctype no-undo .
def    var      Marking   as class mark                    no-undo .
DEFINE BUFFER X_utd FOR tt-utd.
FUNCTION CliName RETURNS CHARACTER
    (input p-cli-code as integer, input p-cli-type as character)  FORWARD.
FUNCTION EdoTypeName RETURNS CHARACTER
    ( input p-stsTH as integer )  FORWARD.
FUNCTION StatusEDIName RETURNS CHARACTER
    ( input p-stsEDI as integer )  FORWARD.
FUNCTION StatusTHName RETURNS CHARACTER
    ( input p-stsTH as integer )  FORWARD.
FUNCTION checkmark RETURNS logical
    ( input idb-num as integer,
      input idoc-id as integer )  FORWARD.
DEFINE MENU POPUP-MENU-b-print
    MENU-ITEM m_akt          LABEL "Акт приема-передачи".
DEFINE MENU POPUP-MENU-b-servis
    MENU-ITEM m___Token      LABEL "Отключить запрос Token"
    MENU-ITEM m_nakl         LABEL "Формирование накладной"
    MENU-ITEM m_recheck      LABEL "Повторно проверить"
    MENU-ITEM m_recEDI       LABEL "Получение данных ЭДО"
    MENU-ITEM m_checknakl    LABEL "Связать с ПН"
    MENU-ITEM m_return       LABEL "Реквизиты возврата".
    MENU-ITEM m_return_send  LABEL "Отправит возврат повторно".
    menu-item m_dekl_sertif  label "Сертификаты/декларации".
DEFINE BUTTON b-add
    LABEL "&Добавить":L
    SIZE 10 BY 1.
DEFINE BUTTON b-choose-sertif
    LABEL "Выбор"
    SIZE 10 BY 1.
DEFINE BUTTON b-del
    LABEL "&Удалить":L
    SIZE 10 BY 1.
DEFINE BUTTON b-pack
    LABEL "Пакет":L
    SIZE 10 BY 1.
DEFINE BUTTON b-inout
    LABEL "Исходящие":L
    SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-GO
    LABEL "&Выход ":L
    SIZE 10 BY 1.
DEFINE BUTTON b-hist
    IMAGE-UP FILE "cmp/b-hist.bmp":U
    IMAGE-DOWN FILE "cmp/b-hist.bmp":U
    IMAGE-INSENSITIVE FILE "cmp/b-hist.bmp":U NO-CONVERT-3D-COLORS
    LABEL "Ис&тория"
    SIZE 3 BY 1.
DEFINE BUTTON b-mark
    LABEL "&*"
    SIZE 3 BY 1.
DEFINE BUTTON b-print
    IMAGE-UP FILE "cmp/b-print.bmp":U
    IMAGE-DOWN FILE "cmp/b-print.bmp":U
    IMAGE-INSENSITIVE FILE "cmp/b-print.bmp":U NO-CONVERT-3D-COLORS
    LABEL "Печать"
    SIZE 3 BY 1.
DEFINE BUTTON B-refresh
    LABEL "Обновить"
    SIZE 10 BY 1.
DEFINE BUTTON b-sel AUTO-GO
    LABEL "&Выбор":L
    SIZE 10 BY 1.
DEFINE BUTTON b-servis
    LABEL "Сервис"
    SIZE 10 BY 1.
DEFINE BUTTON b-update
    LABEL "&Изменить":L
    SIZE 10 BY 1.
DEFINE BUTTON b-utd
    LABEL "&Просмотр":L
    SIZE 10 BY 1.
DEFINE BUTTON B-write-cancel
    LABEL "Отказать в подписи"
    SIZE 27 BY 1.13.
DEFINE BUTTON B-write-sertif
    LABEL "Подписать"
    SIZE 27 BY 1.13.
DEFINE BUTTON B-write-Token
    LABEL "Получить Token"
    SIZE 27 BY 1.13.
DEFINE BUTTON B-LK_RECEIPT
    LABEL "Док-ты Вывода из оборота (ОСУ)"
    SIZE 31 BY 1.13.
DEFINE BUTTON bt-not-sel-all
    LABEL "+"
    SIZE 3 BY 1 TOOLTIP "Выбрать все".
DEFINE BUTTON bt-not-sel-desel-all
    LABEL "-"
    SIZE 3 BY 1 TOOLTIP "Отменить выбор".
DEFINE VARIABLE f-mark AS CHARACTER FORMAT "X(256)":U
    LABEL "Марка"
    VIEW-AS FILL-IN
    SIZE 38 BY 1 NO-UNDO.
DEFINE BUTTON b_cl_mark
    LABEL "Сбросить"
    SIZE 10 BY 1.13.
DEFINE BUTTON bt-sel-obj
    IMAGE-UP FILE "btn-down-arrow":U
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "..."
    SIZE 3.5 BY 1.04.
DEFINE BUTTON b_anul
    LABEL "Аннуляция"
    SIZE 27 BY 1.13.
DEFINE BUTTON b_oneUtd
    LABEL "Получить данные из Диадок"
    SIZE 27 BY 1.13.
DEFINE VARIABLE c-status         AS CHARACTER FORMAT "X(256)":U INITIAL "0"
    LABEL "Статус ТН"
    VIEW-AS COMBO-BOX INNER-LINES 5
    LIST-ITEM-PAIRS "Все","0",
    "Получен от поставщика","2",
    "Требует корректировки","3",
    "Ожидает поставки","4",
    "Требует подписания","5"
    DROP-DOWN-LIST
    SIZE 55.5 BY 1 NO-UNDO.
DEFINE VARIABLE c-status-edi     AS INTEGER   FORMAT "-999":U INITIAL 0
    LABEL "Статус EDI"
    VIEW-AS COMBO-BOX INNER-LINES 5
    LIST-ITEM-PAIRS "Все",1,
    "Получен от поставщика",2,
    "Требует корректировки",3,
    "Ожидает поставки",4,
    "Требует подписания",5
    DROP-DOWN-LIST
    SIZE 55.5 BY 1 NO-UNDO.
DEFINE VARIABLE c-type           AS INTEGER   FORMAT "-999":U INITIAL 0
    LABEL "Тип"
    VIEW-AS COMBO-BOX INNER-LINES 5
    LIST-ITEM-PAIRS "Все",0,
    "Получен от поставщика",2,
    "Требует корректировки",3,
    "Ожидает поставки",4,
    "Требует подписания",5
    DROP-DOWN-LIST
    SIZE 55.5 BY 1 NO-UNDO.
DEFINE VARIABLE F-date-from      AS DATE      FORMAT "99/99/9999":U
    VIEW-AS FILL-IN
    SIZE 10.88 BY 1 NO-UNDO.
DEFINE VARIABLE F-date-to        AS DATE      FORMAT "99/99/9999":U
    LABEL "За период с"
    VIEW-AS FILL-IN
    SIZE 10.88 BY 1 NO-UNDO.
DEFINE VARIABLE f-DocumentNumber AS CHARACTER FORMAT "X(256)":U
    LABEL "Номер документа"
    VIEW-AS FILL-IN
    SIZE 28 BY 1 NO-UNDO.
DEFINE VARIABLE F-sertif         AS CHARACTER FORMAT "X(256)":U
    LABEL "Сертификат"
    VIEW-AS FILL-IN
    SIZE 41.13 BY 1
    BGCOLOR 15 NO-UNDO.
DEFINE VARIABLE F-timeToken      AS Character FORMAT "X(256)":U INITIAL ?
    VIEW-AS FILL-IN
    SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE mark-num         AS INTEGER   FORMAT "->>>9":U INITIAL 0
    VIEW-AS TEXT
    SIZE 4 BY 1
    FGCOLOR 7 NO-UNDO.
DEFINE VARIABLE obj-list         AS CHARACTER FORMAT "X(256)":U
    VIEW-AS FILL-IN
    SIZE 18.38 BY 1 NO-UNDO.
DEFINE VARIABLE R-obj            AS INTEGER
    VIEW-AS RADIO-SET HORIZONTAL
    RADIO-BUTTONS
    "Все", 1,
    "Выборочно", 2
    SIZE 18.5 BY 1 NO-UNDO.
DEFINE VARIABLE RADIO-SET-1      AS INTEGER
    VIEW-AS RADIO-SET HORIZONTAL
    RADIO-BUTTONS
    "Все", 0,
    "В работе", 2,
    "Требуется корректировка", 1
    SIZE 52.5 BY 1.25 NO-UNDO.
DEFINE VARIABLE RADIO-SET-2      AS INTEGER
    VIEW-AS RADIO-SET HORIZONTAL
    RADIO-BUTTONS
    "Все", 0,
    "Требуется подпись", 1,
    "Подписано", 2
    SIZE 47 BY 1.25 NO-UNDO.
define variable mdoc-id as character no-undo.
DEFINE QUERY br-utd FOR
    X_utd SCROLLING.
DEFINE BROWSE br-utd
    QUERY br-utd NO-LOCK DISPLAY
    mark-string( input recid(X_utd), input v-rid-list) column-label "*" format "X(1)":U
    X_utd.DocumentNumber COLUMN-LABEL "Номер!документа" FORMAT "x(60)":U width 15
    X_utd.EDoTypeName COLUMN-LABEL "Тип" FORMAT "X(30)":U width 9
    X_utd.DocumentDate COLUMN-LABEL "Дата док-та" FORMAT "99/99/9999":U
    X_utd.obj-name COLUMN-LABEL "Объект" FORMAT "X(30)":U width 6
    X_utd.cli-code COLUMN-LABEL "Код! пост-ка" FORMAT ">>>>9999999":U
    X_utd.cli-name COLUMN-LABEL "Название!поставщика" FORMAT "X(30)":U width 19
    X_utd.total COLUMN-LABEL "Сумма" FORMAT "->>>>>>>>>>99.99":U width 13
    X_utd.vat COLUMN-LABEL "Сумма! НДС" FORMAT "->>>>>>>>>>99.99":U width 9
    X_utd.stts COLUMN-LABEL "Статус ТН" FORMAT "X(40)":U width 14
    X_utd.stts-edi COLUMN-LABEL "Статус EDI" FORMAT "X(40)":U width 14
    (if X_utd.AmendmentRequested then "+":U else "") format "X(1)":U LABEL "И"
    X_utd.ModifyTime_ column-label "Время!послед.!измен." format "X(7)":U
    X_utd.doc-code COLUMN-LABEL "Номер!документа ТН" FORMAT "x(15)":U
    X_utd.orig-code COLUMN-LABEL "Номер!ориг.документа" FORMAT "x(15)":U WIDTH 50
    X_utd.LoadDate COLUMN-LABEL "Дата загр" FORMAT "99/99/9999":U
    X_utd.DocumentExt COLUMN-LABEL "ID документа" FORMAT "x(80)":U WIDTH 50
    substitute ("&1_&2",X_utd.db-num, X_utd.doc-id) @ mdoc-id COLUMN-LABEL "Внутр.!номер" FORMAT "x(12)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 131 BY 17.63 FIT-LAST-COLUMN.
DEFINE FRAME d-utd
    b-exit AT ROW 1 COL 1.5
    b-update AT ROW 1 COL 11.5 WIDGET-ID 222
    b-sel AT ROW 1 COL 11.5 WIDGET-ID 222
    b-utd AT ROW 1 COL 21.5 WIDGET-ID 230
    b-add AT ROW 1 COL 31.5 WIDGET-ID 266
    b-del AT ROW 1 COL 41.5 WIDGET-ID 280
    b-pack AT ROW 1 COL 51.5 WIDGET-ID 284
    b-inout AT ROW 1 COL 71.5 WIDGET-ID 484
    B-refresh AT ROW 1 COL 106 WIDGET-ID 286
    b-servis AT ROW 1 COL 116 WIDGET-ID 288
    b-print AT ROW 1 COL 126.13 WIDGET-ID 62
    b-hist AT ROW 1 COL 129 WIDGET-ID 64
    F-date-to AT ROW 2.29 COL 13.5 COLON-ALIGNED WIDGET-ID 238
    F-date-from AT ROW 2.29 COL 28 COLON-ALIGNED NO-LABEL WIDGET-ID 36
    F-sertif AT ROW 2.29 COL 78.5 COLON-ALIGNED WIDGET-ID 232 NO-TAB-STOP
    b-choose-sertif AT ROW 2.29 COL 121.88 WIDGET-ID 234
    obj-list AT ROW 3.5 COL 47.38 RIGHT-ALIGNED NO-LABEL WIDGET-ID 30
    bt-sel-obj AT ROW 3.5 COL 48.38 WIDGET-ID 28
    f-DocumentNumber AT ROW 3.5 COL 120.5 RIGHT-ALIGNED WIDGET-ID 276
    R-obj AT ROW 3.54 COL 11.5 NO-LABEL WIDGET-ID 290
    RADIO-SET-1 AT ROW 4.75 COL 2.5 NO-LABEL WIDGET-ID 250
    c-status AT ROW 5.08 COL 74.5 COLON-ALIGNED WIDGET-ID 228
    RADIO-SET-2 AT ROW 5.88 COL 2.5 NO-LABEL WIDGET-ID 282
    c-status-edi AT ROW 6.13 COL 74.5 COLON-ALIGNED WIDGET-ID 248
    c-type AT ROW 7.17 COL 74.5 COLON-ALIGNED WIDGET-ID 278
    bt-not-sel-all AT ROW 7.21 COL 5.5 WIDGET-ID 10 NO-TAB-STOP
    bt-not-sel-desel-all AT ROW 7.21 COL 8.5 WIDGET-ID 12 NO-TAB-STOP
    b-mark AT ROW 7.21 COL 11.5 WIDGET-ID 4 NO-TAB-STOP
    f-mark AT ROW 7.21 COL 15.5 WIDGET-ID 98
    b_cl_mark AT ROW 7.14 COL 60.5
    br-utd AT ROW 8.21 COL 1.5
    B-write-sertif AT ROW 26.38 COL 4 WIDGET-ID 236
    B-write-cancel AT ROW 26.38 COL 36.25 WIDGET-ID 70
    b_anul AT ROW 26.38 COL 68.75 WIDGET-ID 246
    b_oneUtd AT ROW 26.38 COL 101.63 WIDGET-ID 254
    B-write-Token AT ROW 27.67 COL 4 WIDGET-ID 240
    B-LK_RECEIPT AT ROW 27.67 COL 63 WIDGET-ID 440
    F-timeToken AT ROW 27.67 COL 128 RIGHT-ALIGNED NO-LABEL WIDGET-ID 294
    mark-num AT ROW 7.21 COL 1.5 NO-LABEL WIDGET-ID 8
    "Время Token:" VIEW-AS TEXT
    SIZE 12.5 BY .75 AT ROW 27.75 COL 96.5 WIDGET-ID 298
    "по" VIEW-AS TEXT
    SIZE 2.5 BY .67 AT ROW 2.46 COL 27 WIDGET-ID 38
    "Объекты:" VIEW-AS TEXT
    SIZE 8 BY .67 AT ROW 3.71 COL 2.63 WIDGET-ID 296
    SPACE(121.87) SKIP(24.65)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
    TITLE "Список УПД":L.
ASSIGN
    FRAME d-utd:SCROLLABLE = FALSE.
ASSIGN
    b-print:POPUP-MENU IN FRAME d-utd = MENU POPUP-MENU-b-print:HANDLE.
ASSIGN
    b-print:MENU-MOUSE = 1.
ASSIGN
    b-servis:POPUP-MENU IN FRAME d-utd = MENU POPUP-MENU-b-servis:HANDLE.
ASSIGN
    b-servis:MENU-MOUSE = 1.
ASSIGN
    br-utd:COLUMN-RESIZABLE IN FRAME d-utd = TRUE.
ON GO OF FRAME d-utd
    DO:
    END.
ON choose OF b-add IN FRAME d-utd
    DO:
        define variable Log-Res as logical no-undo.
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_edi-doc_add':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output log-res
    )  .
end.
        if log-res then
        do:
            subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
            MySeqUtd = ?.
            run str/upd_browse.w (input parparentproc,
                input ?,
                input ?,
                input 2,
                input 'ДОБАВЛЕНИЕ':U,
                input mDiadocConnection
                ) no-error.
            run init-sort .
            unsubscribe "getNextseq".
            OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
        end.
    END.
ON CHOOSE OF b-choose-sertif IN FRAME d-utd
    DO:
        run str/sertif.w (input parparentproc,
            output v-sertif_num
            ) no-error .
        if v-sertif_num <> "" then
        do:
            run proc-sertif (yes).
        end.
        run enable_BUTTON .
        F-sertif = v-sertif_num .
        if f-sertif <> "" then
        do:
            enable       B-write-Token with frame d-utd .
        end.
        else
        do:
            disable       B-write-Token with frame d-utd .
        end.
        display
            F-sertif
            with frame d-utd .
    END.
ON ROW-DISPLAY OF br-utd IN FRAME d-utd
    DO:
        if AVAILABLE (X_utd) then
        do:
            if X_utd.GrayZone then
            do:
                X_utd.DocumentNumber:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.EDoTypeName:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.DocumentDate:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.cli-code:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.cli-name:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.total:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.vat:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.stts:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.stts-edi:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.ModifyTime_:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.doc-code:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.orig-code:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.LoadDate:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.DocumentExt:bGCOLOR in browse br-utd = GRAY_COLOR.
                mdoc-id:bGCOLOR in browse br-utd = GRAY_COLOR.
                X_utd.obj-name:bGCOLOR in browse br-utd = GRAY_COLOR.
            end.
            if X_utd.edoctype = objSrv:Env:Utd:EDocType:UTD:KeyIntDB then
            do:
                case X_utd.sts:
                    when ObjSrv:Env:Utd:Sts:TH:LoadError:KeyIntDB or
                    when ObjSrv:Env:Utd:Sts:TH:LackOfMarkingCodesInCirculation:KeyIntDB or
                    when ObjSrv:Env:Utd:Sts:TH:InconsistencyWithSupplyContract:KeyIntDB or
                    when ObjSrv:Env:Utd:Sts:TH:LinesInError:KeyIntDB or
                    when ObjSrv:Env:Utd:Sts:TH:edocError:KeyIntDB then
                        do:
                            X_utd.DocumentNumber:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.EDoTypeName:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.DocumentDate:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.cli-code:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.cli-name:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.total:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.vat:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.stts:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.stts-edi:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.ModifyTime_:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.doc-code:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.orig-code:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.LoadDate:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.DocumentExt:fGCOLOR in browse br-utd = RED_COLOR.
                            mdoc-id:fGCOLOR in browse br-utd = RED_COLOR.
                            X_utd.obj-name:fGCOLOR in browse br-utd = RED_COLOR.
                        end.
                    when ObjSrv:Env:Utd:Sts:TH:SignatureRequired:KeyIntDB or
                    when ObjSrv:Env:Utd:Sts:TH:AwaitingConfirmation:KeyIntDB
                    then
                        do:
                            X_utd.DocumentNumber:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.EDoTypeName:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.DocumentDate:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.cli-code:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.cli-name:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.total:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.vat:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.stts:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.stts-edi:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.ModifyTime_:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.doc-code:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.orig-code:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.LoadDate:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.DocumentExt:fGCOLOR in browse br-utd = CYAN_COLOR.
                            mdoc-id:fGCOLOR in browse br-utd = CYAN_COLOR.
                            X_utd.obj-name:fGCOLOR in browse br-utd = CYAN_COLOR.
                        end.
                    when ObjSrv:Env:Utd:Sts:TH:DeliveryCodeMismatch:KeyIntDB
                    then
                        do:
                            X_utd.DocumentNumber:fGCOLOR in browse br-utd = 13.
                            X_utd.EDoTypeName:fGCOLOR in browse br-utd = 13.
                            X_utd.DocumentDate:fGCOLOR in browse br-utd = 13.
                            X_utd.cli-code:fGCOLOR in browse br-utd = 13.
                            X_utd.cli-name:fGCOLOR in browse br-utd = 13.
                            X_utd.total:fGCOLOR in browse br-utd = 13.
                            X_utd.vat:fGCOLOR in browse br-utd = 13.
                            X_utd.stts:fGCOLOR in browse br-utd = 13.
                            X_utd.stts-edi:fGCOLOR in browse br-utd = 13.
                            X_utd.ModifyTime_:fGCOLOR in browse br-utd = 13.
                            X_utd.doc-code:fGCOLOR in browse br-utd = 13.
                            X_utd.orig-code:fGCOLOR in browse br-utd = 13.
                            X_utd.LoadDate:fGCOLOR in browse br-utd = 13.
                            X_utd.DocumentExt:fGCOLOR in browse br-utd = 13.
                            mdoc-id:fGCOLOR in browse br-utd = 13.
                            X_utd.obj-name:fGCOLOR in browse br-utd = 13.
                        end.
                end.
            end.
        end.
    end.
ON choose OF b-del IN FRAME d-utd
    DO:
        define buffer bf_utd               for ub.utd .
        define buffer bf_utd-lines         for ub.utd-lines .
        define buffer bf_utd-marking-lines for ub.utd-marking-lines .
        define buffer bf_marking           for ub.marking .
        define variable Log-Res as logical no-undo.
        define variable undelete as logical no-undo .
        define variable vCount   as integer no-undo .
        if AVAILABLE (X_utd) then
        do:
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_edi-doc_delete':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output log-res
    )  .
end.
            if log-res then
            do:
              if v-rid-list <> "" then
              do:
                message "Удалить"  num-entries(v-rid-list) "документа?"
                        view-as alert-box question buttons yes-no update undelete.
                if not undelete then return no-apply.
              end.
              else v-rid-list = string(recid(X_utd)).
              do vCount = 1 to num-entries(v-rid-list):
                find first X_utd no-lock where recid(X_utd) = int(entry(vCount, v-rid-list)) no-error .
                if X_utd.EDocType = objSrv:Env:Utd:EDocType:AKT:KeyIntDB or X_utd.EDocType = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB
                    then
                do:
                    if X_utd.sts = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB then
                    do:
                        if not undelete then
                        message "Удалить документ " + X_utd.DocumentNumber + "?"
                            view-as alert-box question buttons yes-no update undelete.
                        if undelete then
                        do:
                            find first bf_utd exclusive-lock where bf_utd.db-num = X_utd.db-num and bf_utd.doc-id = int(entry(vCount, v-rid-list)) no-error .
                            delete bf_utd .
                        end.
                    end.
                    else
                    do:
                        message "Документ " + string (X_utd.DocumentNumber) + " не может быть удален"
                            view-as alert-box.
                    end.
                end.
                else
                do:
                    if X_utd.db-num = v-cntxt-db-num and
                        X_utd.sts <> ObjSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB and
                        X_utd.sts <> ObjSrv:Env:Utd:Sts:TH:Rejection:KeyIntDB then
                    do:
                        if not undelete then
                        message "Удалить документ " + X_utd.DocumentNumber + "?"
                            view-as alert-box question buttons yes-no update undelete.
                        if undelete then
                        do:
                            find first bf_utd exclusive-lock where bf_utd.db-num = X_utd.db-num and bf_utd.doc-id = X_utd.doc-id no-error .
                            delete bf_utd .
                        end.
                    end.
                    else
                    do:
                        message "Документ " + string (X_utd.DocumentNumber) + " не может быть удален"
                            view-as alert-box.
                    end.
                end.
              end.
              v-rid-list = "".
              run init-sort .
              OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
            end.
        end.
        else
        do:
            message "Нет документа для удаления"
                view-as alert-box.
        end.
    END.
ON CHOOSE OF b-exit IN FRAME d-utd
    DO:
        if v-current-sort-string <> "" then
        do:
            c-status = string(entry(1,v-current-sort-string,chr(3))) .
            c-status-edi = integer(entry(2,v-current-sort-string,chr(3))) .
            c-type = integer(entry(3,v-current-sort-string,chr(3))) .
            RADIO-SET-1 = integer(entry(4,v-current-sort-string,chr(3))) .
            RADIO-SET-2 = integer(entry(4,v-current-sort-string,chr(3))) .
        end.
        v-current-sort-string =c-status + chr(3) + string(c-status-edi) + chr(3) + string(c-type) +
            chr(3) + string(RADIO-SET-1) + chr(3) + string (RADIO-SET-2).
        v-current-sertif-string = v-sertif_num.
        run uf-set(
            input 'UPD':U
            , input v-cntxt-userid
            , input v-current-sertif-string
            , input v-current-sort-string
            , input no
            , input no
            , input no
            , input no
            ) no-error.
        assign
            mflagExit = yes
            .
    END.
ON choose OF B-LK_RECEIPT IN FRAME d-utd
DO:
  define variable v-lk_receipt-list as character no-undo .
  run str/LK_RECEIPT-docs.w ( parparentproc, "", output v-lk_receipt-list) .
end.
ON choose OF b-hist IN FRAME d-utd
    DO:
        define variable v-rid-list as character no-undo.
        if available (X_utd) then
        do:
            row_utd = rowid (X_utd) .
            run ref/cutdhist.w (
                X_utd.db-num,
                X_utd.doc-id,
                parparentproc,
                0,
                "",
                0,
                "",
                "one",
                ?,
                "",
                "" ,
                v-cntxt-db-num,
                ?,
                input-output v-rid-list ) .
            br-utd:refresh ().
            reposition br-utd to rowid row_utd.
        end.
    END.
ON CHOOSE OF b-mark IN FRAME d-utd
    DO:
        define variable loc#log as logical no-undo .
        if available X_utd then
        do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid26 as character no-undo .
define variable v-num-entry26 as integer   no-undo .
assign
  v-str-recid26 = trim( string( recid( X_utd ) , "->>>>>>>>>>>9":U ) )
  v-num-entry26 = lookup( v-str-recid26 , v-rid-list )
.
if v-num-entry26 > 0 then do:
  assign
    entry( v-num-entry26, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid26
  .
end.
            row_utd = rowid(X_utd).
            loc#log = br-utd:refresh() .
            reposition br-utd to rowid row_utd.
            if last-event:function <> "MOUSE-SELECT-DBLCLICK" then
            do:
                loc#log = br-utd:select-next-row ().
                apply "VALUE-CHANGED" to br-utd in frame d-utd.
            end.
            if num-entries( v-rid-list ) = 0 then
            do:
                hide mark-num in frame d-utd.
            end.
            else
            do:
                display
                    num-entries( v-rid-list ) @ mark-num
                    with frame d-utd.
            end.
        end.
        apply "entry" to br-utd in frame d-utd.
    END.
ON CHOOSE OF B-refresh IN FRAME d-utd
    DO:
        f-date-from = date(f-date-from:screen-value) .
        f-date-to   = date(f-date-to:screen-value) .
        run init-sort .
        OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
        run enable_BUTTON.
    END.
ON CHOOSE OF b-sel IN FRAME d-utd
    DO:
        define buffer buf_utd for ub.utd .
        if v-rid-list = "" then
        do:
            if available (X_utd) then
            do:
                find first buf_utd no-lock where buf_utd.doc-id = X_utd.doc-id and buf_utd.db-num = X_utd.db-num no-error .
                v-rid-list = string(recid(buf_utd)) .
            end.
        end.
        p-rid-list = v-rid-list .
    END.
ON CHOOSE OF b-update IN FRAME d-utd
    DO:
        define var      doc-id   like ub.utd.doc-id no-undo .
        define var      db-num   like ub.utd.db-num no-undo .
        define var      EDocType like ub.utd.EDocType no-undo .
        define variable Log-Res  as logical no-undo.
        if available (x_utd) then
        do:
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_edi-doc_update':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output log-res
    )  .
end.
            if log-res then
            do:
                row_utd = rowid(X_utd) .
                assign
                    doc-id   = x_utd.doc-id
                    db-num   = x_utd.db-num
                    EDocType = x_utd.EDocType
                    .
                subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
                MySeqUtd = ?.
                if v-obj-active or X_utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB or X_utd.EDocType = objSrv:Env:Utd:EDocType:UCD:KeyIntDB
                  or X_utd.EDocType = objSrv:Env:utd:EDocType:edoc:KeyIntDB
                then
                do:
                    run str/upd_browse.w (input parparentproc,
                        input x_utd.doc-id,
                        input x_utd.db-num,
                        input x_utd.EDocType,
                        input 'ИЗМЕНЕНИЕ':U,
                        input mDiadocConnection
                        )  .
                end.
                else
                do:
                    run str/upd_browse.w (input parparentproc,
                        input x_utd.doc-id,
                        input x_utd.db-num,
                        input x_utd.EDocType,
                        input 'ПРОСМОТР':U,
                        input mDiadocConnection
                        )  .
                end.
                unsubscribe "getNextseq".
            end.
            else
            do:
                message "Не выбран УПД"
                    view-as alert-box.
                return no-apply .
            end.
            run init-id (doc-id, db-num).
            br-utd:refresh ().
            reposition br-utd to rowid row_utd.
        end.
    END.
ON choose OF b-utd IN FRAME d-utd
    DO:
        define variable Log-Res as logical no-undo.
        if available (x_utd) then
        do:
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_edi-doc_lookup':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output log-res
    )  .
end.
            if log-res then
            do:
                row_utd = rowid (X_utd) .
                subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
                MySeqUtd = ?.
                run str/upd_browse.w (input parparentproc,
                    input x_utd.doc-id,
                    input x_utd.db-num,
                    input x_utd.EDocType,
                    input 'ПРОСМОТР':U,
                    input mDiadocConnection
                    ) no-error .
                unsubscribe "getNextseq".
            end.
            else
            do:
                message "Не выбран УПД"
                    view-as alert-box.
                return no-apply .
            end.
            reposition br-utd to rowid row_utd no-error .
        end.
    END.
ON CHOOSE OF B-write-cancel IN FRAME d-utd
    DO:
        define variable Log-Res as logical no-undo.
define variable vss-include-info29 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_edi-doc_close':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output log-res
    )  .
end.
        if log-res then
        do:
            if v-rid-list <> "" then
            do:
                do ii = 1 to num-entries (v-rid-list):
                    recid_utd = integer(entry(ii,v-rid-list)) .
                    find first x_utd where recid (x_utd) = recid_utd .
                    run SendResponse( X_utd.db-num, X_utd.doc-id, no, no) no-error.
                    if  error-status:error then
                    do:
                        return return-value .
                    end.
                end.
                run init-sort in this-procedure .
                OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
            end.
            else
            do:
                if available (X_utd) then
                do:
                    row_utd = rowid (X_utd) .
                    find first x_utd where rowid (x_utd) = row_utd .
                    run SendResponse( X_utd.db-num, X_utd.doc-id, no, no) no-error.
                    if  error-status:error then
                    do:
                        message return-value
                        view-as alert-box.
                        return return-value .
                    end.
                    run init-id (X_utd.doc-id, X_utd.db-num).
                    br-utd:refresh () no-error.
                    reposition br-utd to rowid row_utd no-error .
                end.
            end.
        end.
        v-rid-list = "" .
    END.
ON CHOOSE OF B-write-sertif IN FRAME d-utd
    DO:
        define variable Log-Res as logical no-undo.
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_edi-doc_close':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output log-res
    )  .
end.
        if log-res then
        do:
            if v-rid-list <> "" then
            do:
                do ii = 1 to num-entries (v-rid-list):
                    recid_utd = integer(entry(ii,v-rid-list)) .
                    find first x_utd where recid (x_utd) = recid_utd .
                    if checkMark(x_utd.db-num,x_utd.doc-id)
                    then do:
                       run SendResponse( X_utd.db-num, X_utd.doc-id, yes, no) no-error.
                       if  error-status:error then
                       do:
                           return return-value .
                       end.
                    end.
                end.
                run init-sort in this-procedure .
                OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
            end.
            else
            do:
                if available (X_utd) then
                do:
                    row_utd = rowid (X_utd) .
                    find first x_utd where rowid (x_utd) = row_utd .
                    if checkMark(x_utd.db-num,x_utd.doc-id)
                    then do:
                       run SendResponse( X_utd.db-num, X_utd.doc-id, yes, no) no-error.
                       if  error-status:error then
                       do:
                          message return-value
                        view-as alert-box.
                           return return-value .
                       end.
                       run init-id (X_utd.doc-id, X_utd.db-num).
                       br-utd:refresh () no-error.
                       reposition br-utd to rowid row_utd no-error .
                    end.
                end.
            end.
        end.
        v-rid-list = "" .
    END.
ON choose OF B-write-Token IN FRAME d-utd
    DO:
        define buffer buf_ext-system      for ub.ext-system .
        define buffer buf_ext-system-attr for ub.ext-system-attr .
        if v-sertif_num = "" then
        do:
            message "Сертификат не выбран"
                view-as alert-box.
            return .
        end.
        v-mes-Token = yes .
        run proc-Token .
        run enable_BUTTON .
    END.
ON entry OF br-utd IN FRAME d-utd
    DO:
        run enable_BUTTON .
    END.
ON mouse-select-dblclick OF br-utd IN FRAME d-utd
    DO:
        if AVAILABLE (X_utd) then
        do:
            if v-obj-active or X_utd.EDocType = EdocType:UTD:KeyIntDB or X_utd.EDocType = EdocType:UCD:KeyIntDB then
            do:
                apply "Choose" to b-update in frame d-utd.
            end.
            else
            do:
                apply "Choose" to b-utd in frame d-utd.
            end.
        end.
    END.
ON CHOOSE OF bt-not-sel-all IN FRAME d-utd
    DO:
        define variable loc#log as logical no-undo .
        if available X_utd then
        do:
            v-rid-list = "" .
            for each X_utd no-lock:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid32 as character no-undo .
define variable v-num-entry32 as integer   no-undo .
assign
  v-str-recid32 = trim( string( recid( X_utd ) , "->>>>>>>>>>>9":U ) )
  v-num-entry32 = lookup( v-str-recid32 , v-rid-list )
.
if v-num-entry32 > 0 then do:
  assign
    entry( v-num-entry32, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid32
  .
end.
                loc#log = br-utd:refresh() .
            end.
        end.
        if num-entries( v-rid-list ) <> 0 then
        do:
            display
                num-entries( v-rid-list ) @ mark-num
                with frame d-utd.
        end.
    END.
ON CHOOSE OF bt-not-sel-desel-all IN FRAME d-utd
    DO:
        define variable loc#log as logical no-undo .
        v-rid-list = "" .
        loc#log = br-utd:refresh() .
        hide mark-num in frame d-utd.
    END.
ON CHOOSE OF bt-sel-obj IN FRAME d-utd
    DO:
        define variable v-obj-list         as character no-undo.
        define variable v-exclude-obj-list as character no-undo.
        define variable v-object-available as logical   no-undo.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_clear in this-procedure  .
define variable vss-include-info34 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-object-available
  ) no-error .
        if error-status :error then
        do:
            message vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры gbl/usobjava.i" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error.
            undo, return no-apply.
        end.
        if v-object-available = true then
        do:
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_append in this-procedure
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  )  .
        end.
        define variable v-user-select as logical no-undo.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
        if v-user-select <> true then
        do:
            message "Объект не выбран" view-as alert-box information.
        end.
        else
        do:
            v-obj-list = "" .
            empty temp-table tt-obj-list .
            for each userobjs_temp-user-obj:
                create tt-obj-list .
                assign
                    tt-obj-list.obj-code = userobjs_temp-user-obj.obj-code
                    tt-obj-list.obj-type = userobjs_temp-user-obj.obj-type
                    .
                v-obj-list = v-obj-list + (if v-obj-list <> "" then ", " else "")
                    + userobjs_temp-user-obj.obj-type + " " + string( userobjs_temp-user-obj.obj-code).
            end.
        end.
        obj-list:screen-value = v-obj-list.
        run init-sort in this-procedure .
        OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
    END.
ON CHOOSE OF b-inout IN FRAME d-utd
DO:
   Vflaginout = not Vflaginout.
   b-inout:label = if Vflaginout then "Входящие" else "Исходящие" .
   run init-sort .
   OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
END.
ON CHOOSE OF menu-item m_return_send
DO:
   define variable vsend as logical no-undo.
   vsend = not logical(getattrutdex (X_utd.db-num,X_utd.doc-id,"returnSend","no")).
   if not vsend
   then
      message "Документ был отправлен ранее, отправить повторно?"
      view-as alert-box question buttons yes-no update vsend.
   if vsend
   then
      run bge/sendutd.p(parparentproc,
                        v-sertif,
                        X_utd.db-num,
                        X_utd.doc-id) no-error.
      if error-status:error
      then do:
         message return-value
         view-as alert-box.
      end.
END.
ON CHOOSE OF menu-item m_dekl_sertif
DO:
  if v-rid-list <> "" then
  do:
    do ii = 1 to num-entries (v-rid-list):
      recid_utd = integer(entry(ii,v-rid-list)) .
      find first x_utd where recid (x_utd) = recid_utd .
      create tt-sert-utd .
      assign
        tt-sert-utd.doc-id = x_utd.doc-id
        tt-sert-utd.db-num = x_utd.db-num
        tt-sert-utd.documentDate = x_utd.documentDate
        tt-sert-utd.documentNumber = x_utd.documentNumber
        tt-sert-utd.cli-code = x_utd.cli-code
        tt-sert-utd.cli-type = x_utd.cli-type
        .
    end.
  end.
  else
  do:
    if available (X_utd) then
    do:
      row_utd = rowid (X_utd) .
      find first x_utd where rowid (x_utd) = row_utd .
      create tt-sert-utd .
      assign
        tt-sert-utd.doc-id = x_utd.doc-id
        tt-sert-utd.db-num = x_utd.db-num
        tt-sert-utd.documentDate = x_utd.documentDate
        tt-sert-utd.documentNumber = x_utd.documentNumber
        tt-sert-utd.cli-code = x_utd.cli-code
        tt-sert-utd.cli-type = x_utd.cli-type
        .
    end.
  end.
  run rep/dekl_sertif.p (parparentproc, table tt-sert-utd) no-error .
  empty temp-table tt-sert-utd .
  v-rid-list = "" .
  apply "Choose" to b-refresh in frame d-utd.
END.
ON CHOOSE OF b-pack IN FRAME d-utd
    DO:
        define variable v-rid-list as character no-undo.
        if available X_utd
            then
        do:
            v-current-sertif-string = v-sertif_num.
            run uf-set(
                input 'UPD':U
                , input v-cntxt-userid
                , input v-current-sertif-string
                , input v-current-sort-string
                , input no
                , input no
                , input no
                , input no
                ) no-error.
            run str\upd.w (parparentproc, p-mode, p-type, X_utd.PackageId,input-output mDiadocConnection, output v-rid-list).
            run uf-get (
                input 'UPD':U
                , input  v-cntxt-userid
                , output v-current-sertif-string
                , output v-current-sort-string
                , output v-void-logical
                , output v-void-logical
                , output v-void-logical
                , output v-void-logical
                ) no-error.
            if v-current-sertif-string <> "" then
            do:
                F-sertif = v-current-sertif-string .
                v-sertif_num = v-current-sertif-string .
                display F-sertif with frame d-utd .
            end.
            run enable_BUTTON.
        end.
        v-rid-list = "" .
    end.
ON CHOOSE OF b_anul IN FRAME d-utd
    DO:
        define variable load-sts as logical no-undo .
        if v-rid-list <> "" then
        do:
            do ii = 1 to num-entries (v-rid-list):
                recid_utd = integer(entry(ii,v-rid-list)) .
                find first x_utd where recid (x_utd) = recid_utd .
                if X_utd.sts = ObjSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB or X_utd.sts = ObjSrv:Env:Utd:Sts:TH:AwaitingConfirmation:KeyIntDB then
                do:
                    message "Документ с номером: " + X_utd.DocumentNumber + " " + string(X_utd.DocumentDate) + " подписан и обработан в системе." skip
                        "Убедитесь, что товар не оприходован в системе." skip
                        "Вы уверены, что хотите подписать аннуляцию?" skip
                        view-as alert-box question buttons yes-no update load-sts.
                    if load-sts <> true then
                    do:
                        return .
                    end.
                end.
                run Sendansver( X_utd.db-num, X_utd.doc-id, "RevocationRequest","") no-error.
                if  error-status:error then
                do:
                    return return-value .
                end.
            end.
            run init-sort in this-procedure .
            OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
        end.
        else
        do:
            if available (X_utd) then
            do:
                row_utd = rowid (X_utd) .
                find first x_utd where rowid (x_utd) = row_utd .
                if X_utd.sts = ObjSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB or X_utd.sts = ObjSrv:Env:Utd:Sts:TH:AwaitingConfirmation:KeyIntDB then
                do:
                    message "Документ с номером: " + X_utd.DocumentNumber + "подписан и обработан в системе." skip
                        "Убедитесь, что товар не оприходован в системе." skip
                        "Вы уверены, что хотите подписать аннуляцию?" skip
                        view-as alert-box question buttons yes-no update load-sts.
                    if load-sts <> true then
                    do:
                        return .
                    end.
                end.
                run Sendansver( X_utd.db-num, X_utd.doc-id, "RevocationRequest","") no-error.
                if  error-status:error then
                do:
                    message return-value
                    view-as alert-box.
                    return return-value .
                end.
                run init-id (X_utd.doc-id, X_utd.db-num).
                br-utd:refresh () no-error.
                reposition br-utd to rowid row_utd no-error .
            end.
        end.
        v-rid-list = "" .
    END.
ON CHOOSE OF menu-item m_return
DO:
   define variable row_utd as rowid no-undo.
   if available (X_utd)
   then do with FRAME d-utd:
      define variable mMode as character  no-undo.
      mMode = if     X_utd.edoctype = EdocType:Returns:KeyIntDB
                 and X_utd.sts      = ObjSrv:Env:Utd:Sts:th:RequireFilling:KeyIntDB
              then 'ИЗМЕНЕНИЕ':U
              else 'ПРОСМОТР':U.
      run str/upd_org.w (parparentproc, mDiadocConnection, X_utd.db-num, X_utd.doc-id,'ИЗМЕНЕНИЕ':U) .
      row_utd = rowid(x_utd).
      run init-id (X_utd.doc-id, X_utd.db-num).
      br-utd:refresh () no-error.
      reposition br-utd to rowid row_utd no-error .
    end.
END.
ON CHOOSE OF menu-item m_akt
    DO:
        if available (X_utd) then
        do:
            if X_utd.edoctype = EdocType:UTD:KeyIntDB or
                X_utd.edoctype = EdocType:AKT:KeyIntDB then
            do:
                run rep/akt-utd.p (parparentproc, X_utd.db-num, X_utd.doc-id) no-error .
            end.
            else
            do:
                message "Акт приема-передачи не печатается для данного типа документа"
                    view-as alert-box.
            end.
        end.
    END.
ON CHOOSE OF menu-item m_nakl
    DO:
        define variable v-check-db-num  as integer    no-undo .
        define variable v-check-user-id as character  no-undo .
define variable vss-include-info37 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run getcurus in g#library2
  (output v-check-db-num
  ,output v-check-user-id
  ) no-error .
        if v-rid-list <> "" then
        do:
            do ii = 1 to num-entries (v-rid-list):
                for first buf_utd no-lock where recid(buf_utd) = integer(entry(ii,v-rid-list)):
                    run ibs\th\str\utd\adaputd.p
                        (buf_utd.db-num,
                        buf_utd.doc-id,
                        v-check-user-id
                        ) no-error .
                    def var v-msg as char no-undo.
                    if not error-status:error
                    then do:
                       if return-value matches "*ошибка*"
                       then v-msg = substitute ('Документ № &1 от &2. Сформирована ПН: &3. &4', buf_utd.DocumentNumber, string (buf_utd.DocumentDate) , buf_utd.doc-code, return-value).
                       else v-msg = substitute ('Документ № &1 от &2. Сформирована ПН: &3. &5 &4', buf_utd.DocumentNumber, string (buf_utd.DocumentDate) , buf_utd.doc-code, return-value, "Товары данной поставки можно продавать на кассе.").
                    end.
                    else v-msg = substitute ('Документ: &1 от &2. Ошибка при формировании ПН. &3. &4', buf_utd.DocumentNumber, string (buf_utd.DocumentDate), trim(return-value, ".")).
                    message v-msg view-as alert-box.
               end.
            end.
            message "Накладные сформированы"
                view-as alert-box.
            run init-sort in this-procedure .
            OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
        end.
        else
        do:
            if available (X_utd) then
            do:
                v-rid-list = string(recid(X_utd)) .
                find first buf_utd no-lock where buf_utd.doc-id = X_utd.doc-id and buf_utd.db-num = X_utd.db-num no-error .
                run ibs\th\str\utd\adaputd.p
                    (X_utd.db-num,
                    X_utd.doc-id,
                    v-check-user-id
                    )  no-error.
                    if not error-status:error
                    then do:
                       if return-value matches "*ошибка*"
                       then v-msg = substitute ('Документ № &1 от &2. Сформирована ПН: &3. &4', buf_utd.DocumentNumber, string (buf_utd.DocumentDate) , buf_utd.doc-code, return-value).
                       else v-msg = substitute ('Документ № &1 от &2. Сформирована ПН: &3. &5 &4', buf_utd.DocumentNumber, string (buf_utd.DocumentDate) , buf_utd.doc-code, return-value, "Товары данной поставки можно продавать на кассе.").
                    end.
                    else v-msg = substitute ('Документ: &1 от &2. Ошибка при формировании ПН. &3. &4', buf_utd.DocumentNumber, string (buf_utd.DocumentDate), trim(return-value, ".")).
                    message v-msg view-as alert-box.
                run init-id (X_utd.doc-id, X_utd.db-num).
           end.
        end.
        v-rid-list = "" .
    END.
ON CHOOSE OF menu-item m_recEDI
    DO:
        define variable Log-Res as logical no-undo.
define variable vss-include-info38 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_edi-doc_request':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output log-res
    )  .
end.
        if log-res then
        do:
            run getNewupd no-error.
            if error-status:error then
            do:
                return return-value .
            end.
            run init-sort .
            OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
        end.
        v-rid-list = "" .
    END.
ON CHOOSE OF b_oneUtd IN FRAME d-utd
    DO:
        if available (X_utd) then
        do:
            recid_utd = recid (X_utd) .
            find first x_utd where recid (x_utd) = recid_utd .
            run updOneUTD(X_utd.db-num, X_utd.doc-id ) no-error  .
            if  error-status:error then
            do:
                return return-value .
            end.
            run init-id (X_utd.doc-id, X_utd.db-num).
        end.
        OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
    END.
ON value-changed OF br-utd IN FRAME d-utd
    DO:
        run enable_BUTTON .
        b-pack:visible = (i-pack eq ? or i-pack eq "")
            and available X_utd and   X_utd.PackageId ne "" and X_utd.PackageId ne ? .
    END.
ON CHOOSE OF MENU-ITEM m_recheck
    DO:
        define variable Log-Res as logical no-undo.
define variable vss-include-info39 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_edi-doc_recheck':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output log-res
    )  .
end.
        if log-res then
        do:
            define buffer buf_c-utd for ub.c-utd .
            if v-rid-list <> "" then
            do:
                do ii = 1 to num-entries (v-rid-list):
                    find first x_utd where recid (x_utd) = integer(entry(ii,v-rid-list)) .
                    subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
                    MySeqUtd = ?.
                    Recheck(X_utd.db-num, X_utd.doc-id).
                    unsubscribe "getNextseq".
                end.
                run init-sort in this-procedure .
            end.
            else
            do:
                if available (X_utd) then
                do:
                    recid_utd = recid (X_utd) .
                    subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
                    MySeqUtd = ?.
                    Recheck(X_utd.db-num, X_utd.doc-id).
                    unsubscribe "getNextseq".
                    run init-id (X_utd.doc-id, X_utd.db-num).
                end.
            end.
            OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
            v-rid-list = "" .
        end.
    END.
ON CHOOSE OF MENU-ITEM m_checknakl
    DO:
    define buffer buf_trn-doc for ub.trn-doc .
    define buffer X_clients for ub.clients .
    define buffer Nakl_utd  for ub.utd .
    define variable loc-ref-list as character no-undo .
        if available (X_utd) then
        do:
           if ((X_utd.sts = ObjSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB and X_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:WithRecipientSignature:KeyIntDB)
           or (X_utd.sts = ObjSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB and X_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:WithRecipientPartiallySignature:KeyIntDB))
              and X_utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB then
           do:
              find first buf_trn-doc no-lock where buf_trn-doc.doc-code = X_utd.doc-code no-error .
              if available (buf_trn-doc) then
              do:
                 if buf_trn-doc.status_ = 'факт':U then
                 do:
                    message "Накладная " + string(buf_trn-doc.doc-code)+ " по документу " + X_utd.DocumentNumber + " уже создана."
                       view-as alert-box.
                    return no-apply .
                 end.
                 if buf_trn-doc.status_ <> 'факт':U then
                 do:
                    message "Накладная " + string(buf_trn-doc.doc-code)+ " по документу " + X_utd.DocumentNumber + " уже создана." skip
                       "Закройте накладную на факт"
                       view-as alert-box.
                    return no-apply .
                 end.
              end.
           end.
           else
           do:
              message "Для документа нельзя привязать накладную."
                 view-as alert-box.
              return no-apply .
           end.
            find first X_clients no-lock where X_clients.obj-code = X_utd.cli-code and
                                               X_clients.obj-type = X_utd.cli-type no-error .
           if available (X_clients) then do:
            run str/all-docs.w
                (input parparentproc
                ,input X_utd.host-code
                ,input X_utd.obj-type
                ,input X_utd.obj-code
                ,input 'Контрагент':U
                ,input 'факт':U
                ,input 'ie':U
                ,input ?
                ,input ?
                ,input "b-sel,b-mark":U
                ,input ?
                ,input ?
                ,input recid(X_clients)
                ,output loc-ref-list ).
            if loc-ref-list = "" then
            do:
                message
                    "Документы не выбраны"
                    view-as alert-box error.
                return no-apply.
            END.
            else do:
                find first buf_trn-doc no-lock where recid(buf_trn-doc) = integer(entry(1,loc-ref-list)) and buf_trn-doc.status_ = 'факт':U no-error .
                if not available (buf_trn-doc) then
                do:
                    message
                        "Документ не закрыт до статуса - факт"
                        view-as alert-box error.
                    return no-apply.
                end.
                find first buf_trn-doc no-lock where recid(buf_trn-doc) = integer(entry(1,loc-ref-list)) and buf_trn-doc.status_ = 'факт':U
                and buf_trn-doc.fact-date >= X_utd.DocumentDate no-error .
                if not available (buf_trn-doc) then
                do:
                    message
                        "Накладная создана раньше документа"
                        view-as alert-box error.
                    return no-apply.
                end.
                else do:
                find first Nakl_utd no-lock where Nakl_utd.doc-code = buf_trn-doc.doc-code no-error .
                if available (Nakl_utd) then do:
                    message
                        "Накладная " + string(buf_trn-doc.doc-code) + " привязана к другому документу УПД " + string(Nakl_utd.DocumentNumber)
                        view-as alert-box error.
                    return no-apply.
                end.
                end.
            end .
            find first buf_trn-doc no-lock where recid(buf_trn-doc) = integer(entry(1,loc-ref-list)) no-error .
            if available (buf_trn-doc) then do:
                find first Nakl_utd exclusive-lock where Nakl_utd.doc-id = X_utd.doc-id
                                                     and Nakl_utd.db-num = X_utd.db-num no-error .
                Nakl_utd.doc-code = buf_trn-doc.doc-code .
                run init-sort .
                OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
            end.
            end.
            else message "Не найден поставщик " + X_utd.cli-type + " " + string(X_utd.cli-code) + "."
                 view-as alert-box.
        end.
        else do:
            message "Не найден документ."
                 view-as alert-box.
        end.
    END.
ON VALUE-CHANGED OF c-status IN FRAME d-utd
    DO:
        assign c-status .
        run init-sort .
        OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
    END.
ON VALUE-CHANGED OF c-status-edi IN FRAME d-utd
    DO:
        assign c-status-edi .
        run init-sort .
        OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
    END.
ON VALUE-CHANGED OF c-type IN FRAME d-utd
    DO:
        assign c-type .
        run init-sort .
        OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
    END.
ON RETURN OF F-date-from IN FRAME d-utd
    DO:
        apply "TAB":U to self .
        return no-apply .
    END.
ON TAB OF F-date-from IN FRAME d-utd
    DO:
        if string(F-date-from) <> F-date-from:screen-value then
        do:
            assign F-date-from .
        end.
        if F-date-from < F-date-to then
        do:
            message "Дата начала не может быть больше конечной даты"
                view-as alert-box.
            return no-apply .
        end.
        run init-sort .
        OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
        run enable_BUTTON.
    END.
ON return,tab OF f-mark IN FRAME d-utd
DO:
   if f-mark eq f-mark:screen-value
   then
      return no-apply.
   assign
      f-mark
   .
   f-mark:sensitive    = f-mark eq "".
   b_cl_mark:visible   = f-mark ne "".
   b_cl_mark:sensitive = b_cl_mark:visible.
   apply "entry" to b_cl_mark IN FRAME d-utd .
   run init-sort .
   OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
   run enable_BUTTON.
END.
ON CHOOSE OF b_cl_mark  IN FRAME d-utd
DO:
   f-mark:screen-value = "".
   assign
      f-mark
   .
   f-mark:sensitive    = f-mark eq "".
   b_cl_mark:visible   = f-mark ne "".
   b_cl_mark:sensitive = b_cl_mark:visible.
   apply "entry" to f-mark IN FRAME d-utd .
   run init-sort .
   OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
   run enable_BUTTON.
END.
ON RETURN OF F-date-to IN FRAME d-utd
    DO:
        apply "TAB":U to self .
        return no-apply .
    END.
ON TAB OF F-date-to IN FRAME d-utd
    DO:
        if string(F-date-from) <> F-date-from:screen-value then
        do:
            assign F-date-to .
        end.
        if F-date-from < F-date-to then
        do:
            message "Дата начала не может быть больше конечной даты"
                view-as alert-box.
            return no-apply .
        end.
        run init-sort .
        OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
        run enable_BUTTON.
    END.
ON value-changed OF f-DocumentNumber IN FRAME d-utd
    DO:
        assign f-DocumentNumber .
        run init-sort .
        OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
    END.
ON CHOOSE OF MENU-ITEM m___Token
    DO:
        define variable v-ok as logical no-undo .
        if F-sertif <> "" then v-ok = yes .
        else v-ok = no .
        run str/dialog-Token.w (input v-ok, input-output v-flag) no-error .
        if not v-flag then
        do:
            run enable_BUTTON .
        end.
    END.
ON value-changed OF RADIO-SET-1 IN FRAME d-utd
    DO:
        assign RADIO-SET-1 .
        run init-sort .
        OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
    END.
ON value-changed OF R-obj IN FRAME d-utd
    DO:
        assign R-obj .
        if R-obj = 1 then
        do:
            hide
                bt-sel-obj
                obj-list
                in frame d-utd .
            empty temp-table tt-obj-list .
        end.
        else
        do:
            enable
                bt-sel-obj
                with frame d-utd .
            display
                obj-list
                with frame d-utd .
            apply "choose" to bt-sel-obj in frame d-utd.
        end.
        run init-sort .
        OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
    END.
ON value-changed OF RADIO-SET-2 IN FRAME d-utd
    DO:
        assign RADIO-SET-2 .
        run init-sort .
        OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
    END.
ON value-changed OF F-timeToken IN FRAME d-utd
    DO:
        if v-Token-error then
        do:
            if v-sertif_num <> "" or v-cntxt-db-num = 0 then
            do:
                F-timeToken:fgcolor = 12 .
                F-timeToken = "не получено" .
            end.
            else F-timeToken = "" .
        end.
        else
        do:
            if time_motp <> ? then
            do:
                F-timeToken:fgcolor = 0 .
                F-timeToken = string(time_motp,"99/99/9999 HH:MM:SS") .
            end.
            else F-timeToken = "" .
        end.
    END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-utd:PARENT eq ?
    THEN FRAME d-utd:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME d-utd
    APPLY "END-ERROR":U TO SELF.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-utd :SET-REPOSITIONED-ROW(9, "CONDITIONAL") .
end.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of f-date-from in frame d-utd
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of f-date-from in frame d-utd
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of f-date-from in frame d-utd
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of f-date-from in frame d-utd
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of f-date-from in frame d-utd
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of f-date-from in frame d-utd
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date42
    MENU-ITEM m-ed-date42-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date42-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date42-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date42-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if f-date-from :POPUP-MENU in frame d-utd = ?
  then do:
    ASSIGN
      f-date-from :POPUP-MENU in frame d-utd = MENU m-ed-date42 :HANDLE
      f-date-from :MENU-MOUSE in frame d-utd = 3
    .
  end.
  define variable v-label-handle42 as handle no-undo .
  assign
    v-label-handle42 = f-date-from :side-label-handle in frame d-utd
  .
  if valid-handle (v-label-handle42)
  then do:
    if v-label-handle42 :tooltip = ""
    or v-label-handle42 :tooltip = ?
    then do:
      assign
        v-label-handle42 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date42-1 in menu m-ed-date42 DO:
    apply "ctrl-b":U to f-date-from in frame d-utd .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date42-2 in menu m-ed-date42 DO:
    apply "ctrl-d":U to f-date-from in frame d-utd .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date42-3 in menu m-ed-date42 DO:
    apply "ctrl-e":U to f-date-from in frame d-utd .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date42-4 in menu m-ed-date42 DO:
    apply "ctrl-f":U to f-date-from in frame d-utd .
  END.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of f-date-to in frame d-utd
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of f-date-to in frame d-utd
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of f-date-to in frame d-utd
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of f-date-to in frame d-utd
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of f-date-to in frame d-utd
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of f-date-to in frame d-utd
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date44
    MENU-ITEM m-ed-date44-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date44-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date44-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date44-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if f-date-to :POPUP-MENU in frame d-utd = ?
  then do:
    ASSIGN
      f-date-to :POPUP-MENU in frame d-utd = MENU m-ed-date44 :HANDLE
      f-date-to :MENU-MOUSE in frame d-utd = 3
    .
  end.
  define variable v-label-handle44 as handle no-undo .
  assign
    v-label-handle44 = f-date-to :side-label-handle in frame d-utd
  .
  if valid-handle (v-label-handle44)
  then do:
    if v-label-handle44 :tooltip = ""
    or v-label-handle44 :tooltip = ?
    then do:
      assign
        v-label-handle44 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date44-1 in menu m-ed-date44 DO:
    apply "ctrl-b":U to f-date-to in frame d-utd .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date44-2 in menu m-ed-date44 DO:
    apply "ctrl-d":U to f-date-to in frame d-utd .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date44-3 in menu m-ed-date44 DO:
    apply "ctrl-e":U to f-date-to in frame d-utd .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date44-4 in menu m-ed-date44 DO:
    apply "ctrl-f":U to f-date-to in frame d-utd .
  END.
define variable vss-include-info45 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_edi-doc_gettok':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output log-res-Token
    )  .
end.
define variable vss-include-info46 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_edi-doc_recheck':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output log-res-recheck
    )  .
end.
define variable vss-include-info47 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_fact':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output varlog
    )  .
end.
    run uf-get (
        input 'UPD':U
        , input  v-cntxt-userid
        , output v-current-sertif-string
        , output v-current-sort-string
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        ) no-error.
    if v-current-sertif-string <> "" then
    do:
        F-sertif = v-current-sertif-string .
    end.
    Marking = ObjSrv:Env:Marking:Sts:Mark.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-erpRN'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  NO
  ,output conf-par
  ,output par-type
  ) no-error .
  if not error-status:error and conf-par = "yes":U then mode-erprn = yes.
  else mode-erprn = no.
    StatusTH = ObjSrv:Env:Utd:Sts:TH.
    StatusEDI = ObjSrv:Env:Utd:Sts:EDI.
    EdocType = ObjSrv:Env:Utd:EDocType.
    F-date-to = today - 7.
    F-date-from = today .
    if v-current-sertif-string <> "" then
    do:
        F-sertif = v-current-sertif-string .
    end.
    run init-temp in this-procedure .
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame d-utd :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-utd :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame d-utd :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-utd :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame d-utd :height = v-frame-height
          .
          if frame d-utd :scrollable = true
          then do:
            assign
              frame d-utd :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-utd :scrollable = true
          then do:
            assign
              frame d-utd :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-utd :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame d-utd :height
      v-frame-virtual-height = frame d-utd :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame d-utd :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame d-utd
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-utd :scrollable = true
      then do:
        assign
          frame d-utd :virtual-height = frame d-utd :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-utd :height = frame d-utd :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-utd :height = frame d-utd :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-utd :scrollable = true
      then do:
        assign
          frame d-utd :virtual-height = frame d-utd :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame d-utd :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame d-utd :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame d-utd :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-utd :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame d-utd :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-utd :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame d-utd :width = v-frame-width
          .
          if frame d-utd :scrollable = true
          then do:
            assign
              frame d-utd :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-utd :scrollable = true
          then do:
            assign
              frame d-utd :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-utd :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame d-utd :width
      v-frame-virtual-width = frame d-utd :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame d-utd :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame d-utd
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-utd :scrollable = true
      then do:
        assign
          frame d-utd :virtual-width = frame d-utd :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-utd :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame d-utd :width = frame d-utd :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-utd :scrollable = true
      then do:
        assign
          frame d-utd :virtual-width = frame d-utd :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame d-utd :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame d-utd :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-utd
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-utd :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-utd :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-utd :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-utd :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame d-utd
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame d-utd :height
      v-col-delta = v-new-col - frame d-utd :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame d-utd :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-utd :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-utd :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-utd :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame d-utd :width
      v-diasize-current-frame-height = frame d-utd :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame d-utd
    :
      assign
        v-diasize-orig-frame-height = frame d-utd :height
        v-diasize-orig-frame-width  = frame d-utd :width
        v-diasize-browse-handle     = browse br-utd :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-utd :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
    run enable_UI in this-procedure .
    apply "value-changed" to br-utd IN FRAME d-utd.
    if time_motp <> ? then
    do:
        if v-sertif <> "" and mode-erprn = false then
        do:
            vtime = max(1,time_motp + 10500000 - now).
            block-wait:
            do while not mflagExit:
                WAIT-FOR CHOOSE OF FRAME d-utd  focus f-mark pause vtime .
                vtime = max(0,time_motp + 10500000 - now).
                if vtime = 0 and not v-flag then
                    run proc-Token no-error .
                vtime = max(60000,time_motp + 10500000 - now).
            end.
        end.
        else
        do:
            WAIT-FOR GO OF FRAME d-utd focus f-mark .
        end.
    end.
    else
    do:
        WAIT-FOR GO OF FRAME d-utd focus f-mark .
    end.
END.
run disable_UI in this-procedure .
PROCEDURE disable_UI :
    HIDE FRAME d-utd.
END PROCEDURE.
PROCEDURE enable_BUTTON :
    F-timeToken = string(time_motp) .
    apply "value-changed" to F-timeToken in frame d-utd.
    display
        F-timeToken
        with frame d-utd .
    if available (X_utd) and mDiadocConnection <> ?
        then
    do:
        enable
            b_anul
            B-write-cancel
            B-write-sertif
            with frame d-utd .
        menu-item m_return_send:sensitive in menu POPUP-MENU-b-servis = varlog and X_utd.EDocType eq ObjSrv:Env:Utd:EDocType:returns:KeyIntDB .
    end.
    else
    do:
       menu-item m_return_send:sensitive in menu POPUP-MENU-b-servis = no.
        if AVAILABLE (X_utd) and (X_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:AutoRejected:KeyIntDB or X_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:SignatureNotAccepted:KeyIntDB) then
        do:
            enable
                B-write-sertif
                with frame d-utd .
        end.
        else
        do:
            DISABLE
                B-write-sertif
                with frame d-utd .
        end.
        disable
            b_anul
            B-write-cancel
            with frame d-utd .
    end.
    if mDiadocConnection <> ?
        then enable  b_oneUtd with frame d-utd .
    else disable b_oneUtd with frame d-utd .
END PROCEDURE.
function checkMark returns logical
   (idb-num as integer,
    idoc-id as integer ):
   define buffer cancel_utd-lines for ub.utd-marking-lines .
   define buffer cancel_marking           for ub.marking .
   define buffer X_utd                    for X_utd .
   define variable v-write-cancel as logical no-undo .
   v-write-cancel = false .
   define variable vpen as integer no-undo.
   define variable vdel as integer no-undo.
   v-write-cancel = true.
   define variable vqnty as decimal no-undo.
   block-line:
   for each cancel_utd-lines where cancel_utd-lines.doc-id = idoc-id and cancel_utd-lines.db-num = idb-num no-lock:
      vqnty = decimal(GetAttrUtdlinesex(cancel_utd-lines.db-num,cancel_utd-lines.doc-id,cancel_utd-lines.linenum,"QuantityBarCode","0")).
      if vqnty ne 0
      then do:
         v-write-cancel = false .
         leave block-line.
      end.
   end.
   if     v-write-cancel
   then do:
      find first utd where utd.db-num eq idb-num
                       and utd.doc-id eq idoc-id
      no-lock no-error.
      if available  utd
         and utd.sts-edi <> ObjSrv:Env:Utd:Sts:EDI:AutoRejected:KeyIntDB
         and utd.sts-edi <> ObjSrv:Env:Utd:Sts:EDI:SignatureNotAccepted:KeyIntDB
      then
         return no.
      else
         return yes.
   end.
   else
      return yes.
END function.
PROCEDURE enable_UI :
    if p-mode = "" then
    do:
        ENABLE
            b-inout
            br-utd
            b-pack
            b-exit
            b-update
            R-obj
            b-utd
            b-hist
            b-print
            b-del
            b-refresh
            c-status
            c-status-edi
            RADIO-SET-1
            c-type
            F-date-from
            F-date-to
            b-mark
            bt-not-sel-all
            b-servis
            f-DocumentNumber
            f-mark
            radio-set-2
            bt-not-sel-desel-all
            B-LK_RECEIPT
            WITH FRAME d-utd.
        display
            b-inout
            B-write-Token
            b_anul
            B-write-cancel
            b_oneUtd
            B-write-sertif
            F-sertif
            mark-num
            F-date-from
            F-date-to
            f-mark
            with frame d-utd .
        enable
            b-choose-sertif
            with frame d-utd .
        hide b-sel b_cl_mark in frame d-utd .
        if v-obj-active then enable b-add with frame d-utd .
        if v-cntxt-db-num <> 0
        then
          hide B-LK_RECEIPT in frame d-utd .
    end.
    if p-mode = 'ВЫБОР':U then
    do:
        ENABLE
            b-inout
            b-mark
            bt-not-sel-all
            b-sel
            br-utd
            b-exit
            b-utd
            bt-not-sel-desel-all
            R-obj
            radio-set-2
            c-status
            c-status-edi
            RADIO-SET-1
            c-type
            F-date-from
            F-date-to
            f-DocumentNumber
            f-mark
            WITH FRAME d-utd.
        display     F-date-from
            b-inout
            F-date-to
            with frame d-utd .
        disable
            b-hist
            b-print
            b-del
            b-refresh
            b-servis
            B-write-Token
            b_anul
            B-write-cancel
            b_oneUtd
            B-write-sertif
            F-sertif
            mark-num
            b-choose-sertif
            f-mark
            with frame d-utd .
        hide b-update b_cl_mark in frame d-utd .
    end.
    if log-res-Token then
    do:
        menu-item m___Token:sensitive in menu POPUP-MENU-b-servis = yes.
    end.
    else
    do:
        menu-item m___Token:sensitive in menu POPUP-MENU-b-servis = no.
    end.
    if log-res-recheck then
    do:
        menu-item m_recheck:sensitive in menu POPUP-MENU-b-servis = yes .
    end.
    else
    do:
        menu-item m_recheck:sensitive in menu POPUP-MENU-b-servis = no .
    end.
    if varlog then
    do:
        menu-item m_nakl:sensitive in menu POPUP-MENU-b-servis = yes .
    end.
    else
    do:
        menu-item m_nakl:sensitive in menu POPUP-MENU-b-servis = no .
    end.
    if v-current-sertif-string <> "" then
    do:
        v-sertif_num =  v-current-sertif-string .
        run proc-sertif (no).
        F-sertif = v-sertif_num .
        if f-sertif <> "" then
        do:
            enable       B-write-Token with frame d-utd .
        end.
        else
        do:
            disable       B-write-Token with frame d-utd .
        end.
        display
            F-sertif
            with frame d-utd .
        run enable_BUTTON .
    end.
  if mode-erprn then
  do:
     DISABLE
        B-write-sertif
        b-choose-sertif
      with frame d-utd .
    browse br-utd:GET-BROWSE-COLUMN(11):VISIBLE = no no-error.
  end.
END PROCEDURE.
PROCEDURE init-id :
    define input parameter p-doc-id as integer no-undo .
    define input parameter p-db-num as integer no-undo .
    define buffer buf_utd-marking-lines for ub.utd-marking-lines .
    define buffer buf_marking           for ub.marking .
    find first X_utd exclusive-lock where X_utd.doc-id = p-doc-id and X_utd.db-num = p-db-num no-error .
    if available (X_utd) then
    do:
        X_utd.GrayZone = no .
        FOR EACH buf_utd NO-LOCK where buf_utd.doc-id = p-doc-id and buf_utd.db-num = p-db-num:
            X_utd.sts = buf_utd.sts .
            X_utd.sts-edi = buf_utd.sts-edi .
            X_utd.stts = StatusTHName(buf_utd.sts).
            X_utd.stts-edi = StatusEDIName(buf_utd.sts-edi).
            X_utd.doc-code = buf_utd.doc-code.
            if v-cntxt-db-num <> 0 then
            do:
                for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd.db-num
                    and buf_utd-marking-lines.doc-id = buf_utd.doc-id,
                    first buf_marking no-lock where buf_marking.mark = buf_utd-marking-lines.mark
                    and buf_marking.sts = Marking:GrayZone:KeyIntDB:
                    X_utd.GrayZone = yes .
                    leave .
                end.
            end.
        end.
    end.
END PROCEDURE.
PROCEDURE init-sort :
    define variable p-ok    as logical no-undo .
    define variable v-days  as integer no-undo .
    define variable v-days1 as integer no-undo .
    define variable v-days2 as integer no-undo .
    define buffer buf_utd-marking-lines for ub.utd-marking-lines .
    define buffer buf_marking           for ub.marking .
    if AVAILABLE (X_utd) then empty temp-table X_utd .
    define variable mQuery as handle    no-undo.
    define variable vqry   as character no-undo.
    create query mQuery.
    mQuery:set-buffers(buffer buf_utd:HANDLE).
    define variable vinout as character no-undo.
    if       i-Pack ne ""
        and i-pack ne ?
    then do:
       if not Vflaginout
       then
          vinout = " (buf_utd.Direction eq 'inbound' or buf_utd.Direction eq '') ".
       else
          vinout = " buf_utd.Direction ne 'inbound'".
        vqry = substitute("FOR EACH buf_utd where buf_utd.PackageId eq '&1' and &2 no-lock" ,  i-pack,vinout).
    end.
    else do:
       if not Vflaginout
       then
          vinout = substitute (" buf_utd.host-code = &1 and (buf_utd.Direction eq 'inbound'  or buf_utd.Direction eq '') ",  v-cntxt-host-code-obj).
       else
          vinout = " buf_utd.Direction ne 'inbound' and buf_utd.Direction ne '' " .
        vqry = substitute("FOR EACH buf_utd where &1 and buf_utd.DocumentDate >= &2 and buf_utd.DocumentDate <= &3 no-lock" , vinout,f-date-to,f-date-from).
    end.
    define variable vGdsCode  as integer   no-undo.
    define variable vGtin     as character no-undo.
    define variable vMark     as character no-undo.
    define variable vMarkGtin as character no-undo.
    define variable vInt      as logical   no-undo.
    define variable vi        as integer   no-undo.
    define buffer goods             for goods.
    define buffer bar-code          for bar-code.
    define buffer prod-bc           for prod-bc.
    define buffer utd-lines         for utd-lines.
    define buffer utd-marking-lines for utd-marking-lines.
    assign
       vGdsCode = 0
       vGtin    = ""
       vMark    = ""
    .
    if f-mark ne ""
    then do:
       int(f-mark) no-error.
       vInt = not error-status:error.
       if vInt
       then
          find first goods where goods.gds-code eq int(f-mark) no-lock no-error.
       if available goods
       then do:
          vGdsCode  = goods.gds-code.
       end.
       else do:
          if vInt
          then
             find first bar-code where bar-code.b-code eq int(f-mark) no-lock no-error.
          if available bar-code
          then do:
             vGdsCode  = bar-code.gds-code.
          end.
          else do:
             block-fill:
             do vi = 0 to 10:
                find first prod-bc where prod-bc.b-str eq fill("0",vi) + f-mark no-lock no-error.
                if available prod-bc
                then
                   leave block-fill.
             end.
             if available prod-bc
             then do:
                if prod-bc.bc-on-type = 'GTIN':U
                then
                   vGtin = prod-bc.b-str.
                else do:
                    find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
                    if available bar-code
                    then
                       vGdsCode  = bar-code.gds-code.
                end.
             end.
             else do:
                vMark     = getcodeident(f-mark).
                vMarkGtin = getGtinByDM (f-mark).
             end.
          end.
       end.
    end.
    mQuery:query-prepare(vqry).
    mQuery:query-open ().
    mQuery:get-first ().
    do while not mQuery:query-off-end:
        if       i-Pack ne ""
            and i-pack ne ?
            and buf_utd.DocumentDate < f-date-to
            then
        do:
            f-date-to = buf_utd.DocumentDate.
            display f-date-to.
        end.
        if buf_utd.EDocType = EdocType:LK_RECEIPT:KeyIntDB
        or buf_utd.EDocType = EdocType:Mark_Collect:KeyIntDB
        then do :
          mQuery:get-next ().
          next .
        end .
        if vGdsCode  ne 0
        then do:
           find first utd-lines where utd-lines.db-num   eq buf_utd.db-num
                                  and utd-lines.doc-id   eq buf_utd.doc-id
                                  and utd-lines.gds-code eq vGdsCode
           no-lock no-error.
           if not available utd-lines
           then do :
              mQuery:get-next ().
              next .
           end .
        end.
        if vGtin ne ""
        then do:
           find first utd-marking-lines where utd-marking-lines.db-num   eq buf_utd.db-num
                                          and utd-marking-lines.doc-id   eq buf_utd.doc-id
                                          and utd-marking-lines.mark     begins "01" + vGtin + "21"
           no-lock no-error.
           if not available utd-marking-lines
           then
              find first utd-marking-lines where utd-marking-lines.db-num   eq buf_utd.db-num
                                             and utd-marking-lines.doc-id   eq buf_utd.doc-id
                                             and utd-marking-lines.mark     begins "02" + vGtin + "37"
              no-lock no-error.
           if not available utd-marking-lines
           then do :
              mQuery:get-next ().
              next .
           end .
        end.
        if vMark ne ""
        then do:
           find first utd-marking-lines where utd-marking-lines.db-num   eq buf_utd.db-num
                                          and utd-marking-lines.doc-id   eq buf_utd.doc-id
                                          and utd-marking-lines.mark     begins vMark
           no-lock no-error.
           if not available utd-marking-lines
           then
              find first utd-marking-lines where utd-marking-lines.db-num   eq buf_utd.db-num
                                             and utd-marking-lines.doc-id   eq buf_utd.doc-id
                                             and utd-marking-lines.mark     begins "02" + vMarkGtin + "37"
              no-lock no-error.
           if not available utd-marking-lines
           then do :
              mQuery:get-next ().
              next .
           end .
        end.
        create X_utd .
        buffer-copy buf_utd to X_utd .
        X_utd.stts = StatusTHName(X_utd.sts).
        X_utd.stts-edi = StatusEDIName(X_utd.sts-edi).
        X_utd.cli-name = CliName(X_utd.cli-code, X_utd.cli-type).
        X_utd.EdoTypeName = EdoTypeName(X_utd.EDocType).
        X_utd.GrayZone = no .
        X_utd.obj-name = buf_utd.obj-type + " " + string(buf_utd.obj-code) .
        for first ub.utd no-lock where ub.utd.DocumentExt = buf_utd.parentDocumentExt and ub.utd.OrganizationExt = buf_utd.parentOrganizationExt:
            if ub.utd.DocumentNumber <> buf_utd.documentNumber then
                X_utd.orig-code = ub.utd.DocumentNumber .
        end.
        if X_utd.sts <> ObjSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB and
        X_utd.sts <> ObjSrv:Env:Utd:Sts:TH:Canceled:KeyIntDB and
        X_utd.sts <> ObjSrv:Env:Utd:Sts:TH:Rejection:KeyIntDB then
        do:
            if X_utd.ModifyDate <> ? and X_utd.ModifyTime <> ? and X_utd.ModifyTime <> 0 then
            do:
                if today = X_utd.ModifyDate then
                do:
                    X_utd.ModifyTime_ = string((time - X_utd.ModifyTime), "HH:MM") .
                end.
                else
                do:
                    if time < X_utd.ModifyTime then X_utd.ModifyTime_ = string((time - X_utd.ModifyTime), "HH:MM") .
                    else X_utd.ModifyTime_ = "> суток" .
                end.
            end.
        end.
        if v-cntxt-db-num <> 0 then
        do:
            for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = X_utd.db-num
                and buf_utd-marking-lines.doc-id = X_utd.doc-id,
                first buf_marking no-lock where buf_marking.mark = buf_utd-marking-lines.mark
                and buf_marking.sts = Marking:GrayZone:KeyIntDB:
                X_utd.GrayZone = yes .
                leave .
            end.
        end.
        mQuery:get-next ().
    end.
    delete object mQuery.
    find first tt-obj-list no-error .
    if available (tt-obj-list) then
    do:
        for each X_utd:
            p-ok = false .
            for each tt-obj-list:
                if X_utd.obj-code = tt-obj-list.obj-code and X_utd.obj-type = tt-obj-list.obj-type then p-ok = true.
            end.
            if p-ok <> true then delete X_utd .
        end.
    end.
    if c-status <> "-1" then
    do:
        for each X_utd where X_utd.sts <> integer(c-status):
            delete X_utd .
        end.
    end.
    if c-status-edi <> 0 then
    do:
        for each X_utd where X_utd.sts-edi <> c-status-edi:
            delete X_utd .
        end.
    end.
    case RADIO-SET-1:
        when 1 then
            do:
                for each X_utd :
                    if StatusTH:CheckStsErr(X_utd.sts)
                        then next.
                    delete X_utd .
                end.
            end.
        when 2 then
            do:
                for each X_utd where X_utd.sts = ObjSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB or
                    X_utd.sts = ObjSrv:Env:Utd:Sts:TH:Canceled:KeyIntDB or
                    X_utd.sts = ObjSrv:Env:Utd:Sts:TH:ConfirmedUcd:KeyIntDB or
                    X_utd.sts = ObjSrv:Env:Utd:Sts:TH:Rejection:KeyIntDB:
                    delete X_utd .
                end.
            end.
    end case.
    case RADIO-SET-2:
        when 1 then
            do:
                for each X_utd where X_utd.sts-edi > 100 :
                    delete X_utd .
                end.
            end.
        when 2 then
            do:
                for each X_utd where X_utd.sts-edi < 100 :
                    delete X_utd .
                end.
            end.
    end case.
    if c-type <> 0 then
    do:
        for each X_utd where X_utd.EDocType <> c-type:
            delete X_utd .
        end.
    end.
    if f-DocumentNumber <> "" then
    do:
        for each X_utd :
            if X_utd.DocumentNumber begins f-DocumentNumber
                then next.
            delete X_utd .
        end.
    end.
    apply "value-changed" to br-utd IN FRAME d-utd.
END PROCEDURE.
PROCEDURE init-temp :
    define variable ii         as integer   no-undo .
    define variable Status_    as character no-undo .
    define variable Status_EDI as character no-undo .
    define variable Edoc_type  as character no-undo .
    Status_ = "Все" + chr(44) + '-1':U .
    do ii = 1 to StatusTH:mapType:GetItemByLab(ii):
        if StatusTH:CurrProp:KeyIntDB >= 50
        and StatusTH:CurrProp:KeyIntDB < 60
        then next .
        Status_ = Status_ + chr(44) + StatusTH:CurrProp:Label_ + chr(44) + string(StatusTH:CurrProp:KeyIntDB) .
    end.
    Status_EDI = "Все" + chr(44) + '0':U .
    do ii = 1 to StatusEDI:mapType:GetItemByLab(ii):
        Status_EDI = Status_EDI + chr(44) + replace(StatusEDI:CurrProp:Label_,",","") + chr(44) + string(StatusEDI:CurrProp:KeyIntDB) .
    end.
    Edoc_Type = "Все" + chr(44) + '0':U .
    do ii = 1 to EdocType:mapType:GetItemByLab(ii):
      if EdocType:CurrProp = EdocType:LK_RECEIPT
      or EdocType:CurrProp = EdocType:Mark_Collect
      then next .
        Edoc_type = Edoc_type + chr(44) + EdocType:CurrProp:Label_ + chr(44) + string(EdocType:CurrProp:KeyIntDB) .
    end.
    ASSIGN
        c-status-edi:LIST-ITEM-PAIRS  in frame d-utd = Status_EDI .
    ASSIGN
        c-status:LIST-ITEM-PAIRS  in frame d-utd = Status_ .
    ASSIGN
        c-type:LIST-ITEM-PAIRS  in frame d-utd = Edoc_type .
    c-status = "-1" .
    c-status-edi = 0 .
    RADIO-SET-1 = 2 .
    radio-set-1:screen-value = "2" .
    if p-mode = 'ВЫБОР':U and p-type <> 0 then
    do:
        c-type = integer(p-type) .
        c-type:screen-value = string(c-type) .
    end.
    if not mode-erprn then
    do:
    run proc-Token .
    end.
    run init-sort .
    OPEN QUERY br-utd FOR EACH X_utd NO-LOCK by X_utd.DocumentDate desc by X_utd.Timestamp desc INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE proc-sertif :
    define input  parameter iChange as logical no-undo.
    define variable vCertificates    as component-handle no-undo.
    define variable vCertificate     as component-handle no-undo.
    define variable mDiadocApi       as component-handle no-undo.
    define variable mReflector       as component-handle no-undo.
    define variable vCertificateName as component-handle no-undo .
    define variable vi               as integer          no-undo.
    if mDiadocApi eq ?
        then
        create "Diadoc.DiadocClient":U mDiadocApi no-error.
    if mDiadocApi eq ?
        then
        return.
    if    (    p-connect eq ?
        and (i-pack eq ? or i-pack eq "")
        )
        or iChange
        then
    do:
        vCertificates = mDiadocApi:GetPersonalCertificates(true).
        cerfcnt:
        do vi = 1 to  vCertificates:count:
            vCertificate = vCertificates:GetItem(vi - 1).
            if vCertificate:SerialNumber = v-sertif_num then
            do:
                v-sertif = vCertificate:Thumbprint .
                leave cerfcnt.
            end.
        end.
        conectbyCertif(v-sertif) .
        p-connect = mDiadocConnection.
        if mDiadocConnection ne ?
        then
           run SendAuto.
    end.
    else
    do:
        mDiadocConnection = p-connect.
        if mDiadocConnection ne ? then run SendAuto.
    end.
END PROCEDURE.
PROCEDURE proc-Token :
    define buffer buf_ext-system      for ub.ext-system .
    define buffer buf_ext-system-attr for ub.ext-system-attr .
    define variable oMotp as class ibs.th.bge.is_motp.is_motp no-undo .
    for each buf_ext-system-attr no-lock where buf_ext-system-attr.esya-attr-code   = 'obj':U
        and buf_ext-system-attr.esya-attr-value  = v-cntxt-obj-type + string(v-cntxt-obj-code)
        :
        find first buf_ext-system no-lock where buf_ext-system.esys-type = integer('11':U)
            and buf_ext-system.esys-id   = buf_ext-system-attr.esys-id
            no-error .
        R-obj = 2 .
        empty temp-table tt-obj-list .
        create tt-obj-list .
        assign
            tt-obj-list.obj-code = v-cntxt-obj-code
            tt-obj-list.obj-type = v-cntxt-obj-type
            .
        obj-list = v-cntxt-obj-type + " " + string(v-cntxt-obj-code) .
        display obj-list r-obj with frame d-utd .
        disable bt-sel-obj with frame d-utd .
        if available buf_ext-system then leave .
    end .
    if not available buf_ext-system
        then
        for each buf_ext-system-attr no-lock where buf_ext-system-attr.esya-attr-code   = 'host-code':U
            and buf_ext-system-attr.esya-attr-value  = string(v-cntxt-host-code-obj)
            :
            find first buf_ext-system no-lock where buf_ext-system.esys-type = integer('11':U)
                and buf_ext-system.esys-id   = buf_ext-system-attr.esys-id
                no-error .
            if available buf_ext-system then leave .
        end .
    if not available buf_ext-system
        then
    do :
        if v-mes-Token then
        do:
            message "Нет внешней системы с типом ИС МОТП" view-as alert-box .
            return .
        end.
        else return .
    end.
    v-mes-Token = no .
    oMotp = new is_motp(buf_ext-system.db-num, buf_ext-system.esys-id) .
    time_motp = oMotp:currTokenDT .
    if v-sertif <> ? and v-sertif <> "" then
    do:
        vToken = oMotp:authorize(input v-sertif, input "ThumbPrint") no-error .
        if error-status:error
            then
        do:
            time_motp = oMotp:currTokenDT .
            vtime = max(0,time_motp + 10500000 - now).
            if vtime = 0 then v-Token-error = true .
            else v-Token-error = false .
            message oMotp:MSG view-as alert-box .
        end.
        else
        do:
            time_motp = oMotp:currTokenDT .
            v-Token-error = false.
        end.
    end.
    else
    do:
        time_motp = oMotp:currTokenDT .
        vtime = max(0,time_motp + 10500000 - now).
        if vtime = 0 then v-Token-error = true .
        else v-Token-error = false .
    end.
    apply "value-changed" to F-timeToken IN FRAME d-utd.
    delete object oMotp.
END PROCEDURE.
FUNCTION CliName RETURNS CHARACTER
    (input p-cli-code as integer, input p-cli-type as character) :
    define variable v-cli-name as character no-undo .
    find first buf_clients no-lock where buf_clients.obj-code = p-cli-code
        and buf_clients.obj-type = p-cli-type no-error .
    if available (buf_clients) then v-cli-name = buf_clients.obj-name .
    RETURN v-cli-name.
END FUNCTION.
FUNCTION EdoTypeName RETURNS CHARACTER
    ( input p-stsTH as integer ) :
    RETURN EdocType:GetLabel(p-stsTH) .
END FUNCTION.
FUNCTION StatusEDIName RETURNS CHARACTER
    ( input p-stsEDI as integer ) :
    define variable v-status-name as character no-undo .
    define buffer buf_utd-attr for ub.utd-attr .
    if p-stsEDI = ObjSrv:Env:Utd:Sts:EDI:WithRecipientSignature:KeyIntDB then
    do:
        find first buf_utd-attr no-lock where buf_utd-attr.doc-id = buf_utd.doc-id and
            buf_utd-attr.db-num = buf_utd.db-num and
            buf_utd-attr.attr-code = "sendcode"  no-error .
        if available (buf_utd-attr) then
        do:
            case buf_utd-attr.attr-value:
                when "2" then
                    do:
                        v-status-name = "(С расхождением)" .
                    end.
                when "3" then
                    do:
                        v-status-name = "(Не принято)" .
                    end.
                otherwise
                do:
                    v-status-name = "" .
                end.
            end case .
        end.
        RETURN StatusEdi:GetLabel(p-stsEDI) + " " + v-status-name.
    end.
    else
    do:
        RETURN StatusEdi:GetLabel(p-stsEDI).
    end.
END FUNCTION.
FUNCTION StatusTHName RETURNS CHARACTER
    ( input p-stsTH as integer ) :
    RETURN StatusTH:GetLabel(p-stsTH) .
END FUNCTION.
