using ibs.th.gbl.sys.objsrv.
using ibs.th.str.marking.sts.*.
using ibs.th.str.marking.handlers.*.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка кодов маркировки".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info10 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info10, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info10, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info10, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info10, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info10 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info10, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info10 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info10, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info10, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info10, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info10, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info10, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info10, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info10 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info10 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info10, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info10, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info10, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info10 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info10 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info10, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info10, v-inform, v-tbl-name ).
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
def var vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info12 as character format "X(65)" no-undo
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
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
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
def var vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define input parameter parparentproc as widget-handle no-undo .
define input-output  PARAMETER TABLE FOR tt-marking-lines.
define input parameter p-mode as character no-undo .
define input parameter p-doc as character  no-undo .
define input parameter p-type as integer   no-undo .
define input parameter p-parent_mark as character   no-undo .
define variable EDOParSec  as class ibs.th.gbl.env.prmtrs.edo   no-undo.
define variable log-res     as log       no-undo.
define variable rr          as recid     no-undo.
define variable v_type      as char      no-undo.
define variable v-is-deploy as logical   no-undo .
define variable v-rid-list  as character no-undo .
define variable v-rid-list2 as character no-undo .
define variable v-db-list   as character no-undo .
define variable recid_mark  as integer   no-undo .
define variable title_name  as character no-undo .
define variable iLang       as integer   no-undo.
define variable p-value-logical as logical no-undo.
define variable p-value-character  as character no-undo.
define variable p-value-date       as date no-undo.
define variable p-value-decimal    as decimal no-undo.
define variable p-value-integer    as integer no-undo.
define variable p-param-type       as character no-undo.
define variable v-tth as handle no-undo .
define variable Tree        as class     tree no-undo .
define variable ungroup     as logical   no-undo .
define variable jj          as integer   no-undo .
define variable v-qnty-mark as integer   no-undo .
define variable mark-parent as character no-undo .
define variable v-edoc-type as logical   no-undo .
define variable mIsRasVneshReturn as logical no-undo init false.
define temp-table tt-gray-marking-lines like tt-marking-lines .
define buffer buf_marking           for ub.marking .
define buffer buf_utd-marking-lines for ub.utd-marking-lines .
define buffer bf_utd-marking-lines  for ub.utd-marking-lines .
define buffer buf_utd-lines         for ub.utd-lines .
define buffer buf_parts             for ub.parts .
define buffer buf_goods             for ub.goods .
define buffer buf_utd-err           for ub.utd-err .
DEFINE BUFFER X_marking             FOR tt-marking-lines.
DEFINE BUFFER X_marking-line        FOR tt-marking-lines.
define variable typem as character no-undo.
define variable v-scan-str  as character no-undo.
define variable v-manual    as logical   no-undo .
DEFINE VARIABLE v-timedelay as integer   no-undo .
define variable vMarkBrow2 as character no-undo.
define variable vLevel     as integer   no-undo init 1.
define variable varvalue as character no-undo.
define variable vartype  as character no-undo.
FUNCTION GdsName RETURNS CHARACTER
    ( input p-gds-code as integer )  FORWARD.
FUNCTION getStatusName RETURNS CHARACTER
    ( input p-mark     as character,
      input p-sts-glob as integer,
      input p-sts-loc  as integer )  FORWARD.
def var Marking as class mark no-undo .
DEFINE BUTTON b-change
     LABEL "&Поменять":L
     SIZE 10 BY 1.
DEFINE BUTTON b-look
     LABEL "Просмотр":L
     SIZE 10 BY 1.
DEFINE BUTTON b-change-2
     LABEL "Поменять":L
     SIZE 10 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удалить":L
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
DEFINE BUTTON b-mark-2
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON bt-not-sel-all
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Выбрать все".
DEFINE BUTTON bt-not-sel-all-2
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Выбрать все".
DEFINE BUTTON bt-not-sel-desel-all
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Отменить выбор".
DEFINE BUTTON bt-not-sel-desel-all-2
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Отменить выбор".
DEFINE BUTTON b_block
     LABEL "Проверка"
     SIZE 10 BY 1.
DEFINE BUTTON b_error
     LABEL "Ошибки"
     SIZE 10 BY 1.
DEFINE VARIABLE c-status AS INTEGER FORMAT "-999":U INITIAL 0
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Все",1,
                     "Получен от поставщика",2,
                     "Требует корректировки",3,
                     "Ожидает поставки",4,
                     "Требует подписания",5
     DROP-DOWN-LIST
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE c-status-2 AS INTEGER FORMAT "-999":U INITIAL 0
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Все",1,
                     "Получен от поставщика",2,
                     "Требует корректировки",3,
                     "Ожидает поставки",4,
                     "Требует подписания",5
     DROP-DOWN-LIST
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE f-qnty-bar-code AS INTEGER FORMAT "->>>,>>>,>>9":U INITIAL 0
     LABEL "Кол-во штрих-кодов"
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-qnty-unit AS INTEGER FORMAT "->>>,>>>,>>9":U INITIAL 0
     LABEL "Кол-во марок"
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE F-text AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 100 BY 1.25
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE qnty-mark AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "из"
     VIEW-AS FILL-IN
     SIZE 5.5 BY 1 NO-UNDO.
DEFINE VARIABLE qnty-mark-2 AS INTEGER FORMAT "->,>>>>>9":U INITIAL 0
     LABEL "Просканировано марок"
     VIEW-AS FILL-IN
     SIZE 5.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-mark AS CHARACTER FORMAT "X(255)"
     LABEL "Марка/Штрих-код"
     VIEW-AS FILL-IN
     SIZE 74 BY 1.
DEFINE VARIABLE Status_ AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 0,
"Ожидает проверку", 1,
"Проверен", 7
     SIZE 41 BY 1 NO-UNDO.
FUNCTION StatusTHName RETURNS CHARACTER
  (input p-stsTH as integer)  .
  Return Marking:GetLabel(p-stsTH) .
END FUNCTION .
DEFINE QUERY br-bar-code FOR
  X_marking SCROLLING.
DEFINE QUERY br-mark FOR
  X_marking SCROLLING.
DEFINE QUERY br-mark-item FOR
  X_marking-line SCROLLING.
DEFINE BROWSE br-mark
  QUERY br-mark NO-LOCK DISPLAY
  X_marking.marking-string column-label "*" format "X(1)":U
  X_marking.gds-code COLUMN-LABEL "Код товара" FORMAT "999999999":U
  X_marking.gds-name COLUMN-LABEL "Наименование" FORMAT "x(210)":U width 15
  (if length(X_marking.mark) < 16 then "ШК"
  else if ismark(X_marking.mark) then "КМ"
  else "АОД") @ typem COLUMN-LABEL "Тип!кода" FORMAT "x(3)":U
  X_marking.mark COLUMN-LABEL "Марка/Штрих-код" FORMAT "x(56)":U width 33
  X_marking.box-qnty column-label "Кол-во" format "->>>>>>9.99":U
  if ismark(X_marking.mark) and WeighedProd(X_marking.gds-code) then string(MarkWeight(X_marking.mark),">>>>>9.999") else "" @ X_marking.weight COLUMN-LABEL "Вес" FORMAT "x(10)":U width 10
  if not ismark(X_marking.mark) then "" else getStatusName(X_marking.mark,X_marking.sts,X_marking.sts-utd) @ X_marking.stts COLUMN-LABEL "Текущий статус" FORMAT "X(50)":U width 20
  X_marking.site COLUMN-LABEL "" FORMAT "X(1)":U
  if X_marking.unit eq ? or X_marking.unit eq "" then getLevelUTDByLevelMotp( X_marking.unit-ext) else X_marking.unit @ X_marking.unit COLUMN-LABEL "Ед.изм." FORMAT "x(8)":U
Enable
X_marking.mark
    WITH NO-ROW-MARKERS SEPARATORS SIZE 123.5 BY 11 FIT-LAST-COLUMN.
DEFINE BROWSE br-mark-item
  QUERY br-mark-item NO-LOCK DISPLAY
  X_marking-line.marking-string column-label "*" format "X(1)":U
  X_marking-line.gds-code COLUMN-LABEL "Код товара" FORMAT "999999999":U
  X_marking-line.gds-name COLUMN-LABEL "Наименование" FORMAT "x(210)":U width 15
  if length(X_marking.mark) < 16 then "ШК"
  else if ismark(X_marking.mark) then "КМ"
  else "АОД" @ typem COLUMN-LABEL "Тип!кода" FORMAT "x(3)":U
  X_marking-line.mark COLUMN-LABEL "Марка" FORMAT "x(56)":U width 33
  X_marking-line.box-qnty column-label "Кол-во" format "->>>>>>9.99":U
  if ismark(X_marking-line.mark) and WeighedProd(X_marking-line.gds-code) then string(MarkWeight(X_marking-line.mark),">>>>>9.999") else "" @ X_marking-line.weight COLUMN-LABEL "Вес" FORMAT "x(10)":U width 10
  getStatusName(X_marking.mark,X_marking-line.sts,X_marking-line.sts-utd) @ X_marking-line.stts COLUMN-LABEL "Текущий статус" FORMAT "X(50)":U width 20
  X_marking-line.unit COLUMN-LABEL "Ед.изм." FORMAT "x(8)":U
Enable
X_marking-line.mark
    WITH NO-ROW-MARKERS SEPARATORS SIZE 123.5 BY 11.25 FIT-LAST-COLUMN.
DEFINE FRAME d-mark
     b-exit AT ROW 1 COL 1
     b_block AT ROW 1 COL 101.63 WIDGET-ID 290
     b_error AT ROW 1 COL 111.5 WIDGET-ID 282
     v-mark AT ROW 1.08 COL 38 COLON-ALIGNED WIDGET-ID 34
     b-hist AT ROW 1.08 COL 121.88 WIDGET-ID 64
     F-text AT ROW 2.33 COL 23 NO-LABEL WIDGET-ID 224
     bt-not-sel-all AT ROW 3.75 COL 1.63 WIDGET-ID 10 NO-TAB-STOP
     bt-not-sel-desel-all AT ROW 3.75 COL 4.63 WIDGET-ID 12 NO-TAB-STOP
     b-mark AT ROW 3.75 COL 7.63 WIDGET-ID 4
     b-del AT ROW 3.75 COL 10.88 WIDGET-ID 66
     c-status AT ROW 3.75 COL 22 COLON-ALIGNED NO-LABEL WIDGET-ID 72
     b-change AT ROW 3.75 COL 53.5 WIDGET-ID 68
     b-look AT ROW 3.75 COL 63.5 WIDGET-ID 68
     Status_ AT ROW 3.75 COL 84 NO-LABEL WIDGET-ID 24
     br-mark AT ROW 4.75 COL 1.5 WIDGET-ID 200
     bt-not-sel-all-2 AT ROW 16 COL 1.5 WIDGET-ID 80 NO-TAB-STOP
     bt-not-sel-desel-all-2 AT ROW 16 COL 4.5 WIDGET-ID 82 NO-TAB-STOP
     b-mark-2 AT ROW 16 COL 7.5 WIDGET-ID 78
     c-status-2 AT ROW 16 COL 21.88 COLON-ALIGNED NO-LABEL WIDGET-ID 84
     b-change-2 AT ROW 16 COL 53.38 WIDGET-ID 74
     f-qnty-unit AT ROW 16 COL 123.75 RIGHT-ALIGNED WIDGET-ID 284
     qnty-mark-2 AT ROW 16 COL 107.25 COLON-ALIGNED WIDGET-ID 288
     f-qnty-bar-code AT ROW 16 COL 123.75 RIGHT-ALIGNED WIDGET-ID 294
     qnty-mark AT ROW 16 COL 117.38 COLON-ALIGNED WIDGET-ID 286
     br-mark-item AT ROW 17 COL 1.5 WIDGET-ID 300
     SPACE(0.99) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
    TITLE "Проверка кодов маркировки":L.
ASSIGN
       br-mark:HIDDEN  IN FRAME d-mark                = TRUE
       br-mark:COLUMN-RESIZABLE IN FRAME d-mark       = TRUE.
ASSIGN
       br-mark-item:HIDDEN  IN FRAME d-mark                = TRUE
       br-mark-item:COLUMN-RESIZABLE IN FRAME d-mark       = TRUE.
assign
      v-mark:hidden in frame d-mark = true .
      b-change-2:hidden in frame d-mark = true .
      b-mark-2:hidden in frame d-mark = true .
      b_block:hidden in frame d-mark = true .
      bt-not-sel-all-2:hidden in frame d-mark = true .
      bt-not-sel-desel-all-2:hidden in frame d-mark = true .
      c-status-2:hidden in frame d-mark = true .
      b_error:hidden in frame d-mark = true .
ON CTRL-S OF FRAME d-mark
anywhere DO:
  define buffer b_utd-marking-lines for ub.utd-marking-lines.
  define buffer b_marking for ub.marking.
  if focus:parent:type = "browse" and
     focus:name = "mark" and
     focus:screen-value <> "" then
  do:
    message
      "Марка     :" focus:screen-value skip
      "Глобальный:" if focus:parent:name = "br-mark" then X_marking.stts else X_marking-line.stts skip
      "Локальный :" if focus:parent:name = "br-mark" then X_marking.stts-utd else X_marking-line.stts-utd
    view-as alert-box title "Статус марки".
  end.
END.
ON CHOOSE OF b-change IN FRAME d-mark
    DO:
        define variable ii         as integer no-undo .
        define variable recid_mark as integer no-undo .
        find first tt-marking-lines where tt-marking-lines.marking-string = "*" no-error .
        if available (tt-marking-lines) then
        do:
            for each X_marking where X_marking.marking-string = "*":
                find first buf_marking exclusive-lock where buf_marking.mark = X_marking.mark no-error .
                if available (buf_marking)
                    then
                do:
                    buf_marking.sts = c-status .
                    validate buf_marking.
                    X_marking.sts = buf_marking.sts .
                    X_marking.stts =  StatusTHName(X_marking.sts).
                end.
                find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking.mark
                                                                  and buf_utd-marking-lines.db-num = X_marking.db-num
                                                                  and buf_utd-marking-lines.doc-id = X_marking.doc-id no-error .
                if available (buf_utd-marking-lines)
                    then
                do:
                    buf_utd-marking-lines.sts = c-status .
                    validate buf_utd-marking-lines.
                    X_marking.sts-utd = buf_utd-marking-lines.sts .
                    X_marking.stts-utd =  StatusTHName(X_marking.sts-utd).
                end.
                X_marking.marking-string = "" .
            end.
        end.
        else
        do:
            recid_mark = recid(X_marking) .
            find first X_marking where recid (X_marking) = recid_mark no-error.
            if available (X_marking) then
            do:
                find first buf_marking exclusive-lock where buf_marking.mark = X_marking.mark no-error .
                if available (buf_marking)
                    then
                do:
                    buf_marking.sts = c-status .
                    validate buf_marking.
                    X_marking.sts = buf_marking.sts .
                    X_marking.stts =  StatusTHName(X_marking.sts).
                end.
                find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking.mark and buf_utd-marking-lines.db-num = X_marking.db-num and
                    buf_utd-marking-lines.doc-id = X_marking.doc-id no-error .
                if available (buf_utd-marking-lines)
                    then
                do:
                    buf_utd-marking-lines.sts = c-status .
                    validate buf_utd-marking-lines.
                    X_marking.sts-utd = buf_utd-marking-lines.sts .
                    X_marking.stts-utd =  StatusTHName(X_marking.sts-utd).
                end.
            end.
        end.
        if p-parent_mark eq "" then OPEN QUERY br-mark FOR EACH X_marking NO-LOCK where x_marking.doc-level = 1 and if Status_ <> 0 then if Status_ = 7 then x_marking.sts-utd = Status_ else x_marking.sts-utd = 3 or X_marking.sts-utd = Status_ else x_marking.sts-utd <> 99 INDEXED-REPOSITION. else OPEN QUERY br-mark FOR EACH X_marking NO-LOCK where x_marking.mark-parent = p-parent_mark and if Status_ <> 0 then if Status_ = 7 then x_marking.sts-utd = Status_ else x_marking.sts-utd = 3 or X_marking.sts-utd = Status_ else x_marking.sts-utd <> 99 INDEXED-REPOSITION.    OPEN QUERY br-mark-item for each X_marking-line no-lock where X_marking-line.mark-parent = vMarkBrow2   and if Status_ <> 0 then if Status_ = 7 then x_marking-line.sts-utd = Status_ else x_marking-line.sts-utd = 3 or X_marking-line.sts-utd = Status_ else x_marking-line.sts <> 99 INDEXED-REPOSITION.
        apply "entry" to br-mark in frame d-mark.
    END.
ON CHOOSE OF b-change-2 IN FRAME d-mark
    DO:
        define variable ii         as integer no-undo .
        define variable recid_mark as integer no-undo .
        find first tt-marking-lines where tt-marking-lines.marking-string = "*" and tt-marking-lines.doc-level > 1 no-error .
        if available (tt-marking-lines) then
        do:
            for each X_marking-line where X_marking-line.marking-string = "*" and tt-marking-lines.doc-level > 1:
                X_marking-line.sts-utd = c-status-2 .
                X_marking-line.stts-utd =  StatusTHName(X_marking-line.sts-utd).
                X_marking-line.sts = c-status-2 .
                X_marking-line.stts =  StatusTHName(X_marking-line.sts).
                find first buf_marking exclusive-lock where buf_marking.mark = X_marking-line.mark no-error .
                if available (buf_marking) then buf_marking.sts = X_marking-line.sts .
                find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking-line.mark and buf_utd-marking-lines.db-num = X_marking-line.db-num and
                    buf_utd-marking-lines.doc-id = X_marking-line.doc-id no-error .
                if available (buf_utd-marking-lines) then buf_utd-marking-lines.sts = X_marking-line.sts-utd .
                X_marking-line.marking-string = "" .
            end.
        end.
        else
        do:
            recid_mark = recid(X_marking-line) .
            find first X_marking-line where recid (X_marking-line) = recid_mark no-error.
            if available (X_marking-line) then
            do:
                X_marking-line.sts-utd = c-status-2 .
                X_marking-line.stts-utd =  StatusTHName(X_marking-line.sts-utd).
                X_marking-line.sts = c-status-2 .
                X_marking-line.stts =  StatusTHName(X_marking-line.sts).
                find first buf_marking exclusive-lock where buf_marking.mark = X_marking-line.mark no-error .
                if available (buf_marking) then buf_marking.sts = X_marking-line.sts .
                find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking-line.mark and buf_utd-marking-lines.db-num = X_marking-line.db-num and
                    buf_utd-marking-lines.doc-id = X_marking-line.doc-id no-error .
                if available (buf_utd-marking-lines) then buf_utd-marking-lines.sts = X_marking-line.sts-utd .
            end.
        end.
        if p-parent_mark eq "" then OPEN QUERY br-mark FOR EACH X_marking NO-LOCK where x_marking.doc-level = 1 and if Status_ <> 0 then if Status_ = 7 then x_marking.sts-utd = Status_ else x_marking.sts-utd = 3 or X_marking.sts-utd = Status_ else x_marking.sts-utd <> 99 INDEXED-REPOSITION. else OPEN QUERY br-mark FOR EACH X_marking NO-LOCK where x_marking.mark-parent = p-parent_mark and if Status_ <> 0 then if Status_ = 7 then x_marking.sts-utd = Status_ else x_marking.sts-utd = 3 or X_marking.sts-utd = Status_ else x_marking.sts-utd <> 99 INDEXED-REPOSITION.    OPEN QUERY br-mark-item for each X_marking-line no-lock where X_marking-line.mark-parent = vMarkBrow2   and if Status_ <> 0 then if Status_ = 7 then x_marking-line.sts-utd = Status_ else x_marking-line.sts-utd = 3 or X_marking-line.sts-utd = Status_ else x_marking-line.sts <> 99 INDEXED-REPOSITION.
        apply "entry" to br-mark in frame d-mark.
    END.
ON CHOOSE OF b-del IN FRAME d-mark
    DO:
        define variable ii         as integer no-undo .
        define variable recid_mark as integer no-undo .
        if v-rid-list <> "" then
        do:
            do ii = 1 to num-entries (v-rid-list):
                recid_mark = integer(entry(ii,v-rid-list)) .
                for first X_marking where recid (X_marking) = recid_mark:
                    for first buf_marking exclusive-lock where buf_marking.mark = X_marking.mark:
                        for first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking.mark:
                            for first buf_utd-lines exclusive-lock where buf_utd-lines.LineNum = buf_utd-marking-lines.LineNum and buf_utd-lines.db-num = buf_utd-marking-lines.db-num
                                and buf_utd-lines.doc-id = buf_utd-marking-lines.doc-id:
                                buf_utd-lines.Quantity = buf_utd-lines.Quantity - buf_marking.box-qnty .
                                delete X_marking.
                                delete buf_utd-marking-lines .
                                v-qnty-mark = v-qnty-mark - buf_marking.box-qnty .
                                if buf_utd-lines.Quantity = 0 then
                                do:
                                    delete buf_utd-lines .
                                end.
                            end.
                        end.
                    end.
                end.
            end.
        end.
        else
        do:
            recid_mark = recid(X_marking) .
            for first X_marking where recid (X_marking) = recid_mark:
                for first buf_marking exclusive-lock where buf_marking.mark = X_marking.mark:
                    for first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking.mark:
                        for first buf_utd-lines exclusive-lock where buf_utd-lines.LineNum = buf_utd-marking-lines.LineNum and buf_utd-lines.db-num = buf_utd-marking-lines.db-num
                            and buf_utd-lines.doc-id = buf_utd-marking-lines.doc-id:
                            buf_utd-lines.Quantity = buf_utd-lines.Quantity - buf_marking.box-qnty .
                            delete X_marking.
                            delete buf_utd-marking-lines .
                            v-qnty-mark = v-qnty-mark - buf_marking.box-qnty .
                            if buf_utd-lines.Quantity = 0 then
                            do:
                                delete buf_utd-lines .
                            end.
                        end.
                    end.
                end.
            end.
        end.
        if p-parent_mark eq "" then OPEN QUERY br-mark FOR EACH X_marking NO-LOCK where x_marking.doc-level = 1 and if Status_ <> 0 then if Status_ = 7 then x_marking.sts-utd = Status_ else x_marking.sts-utd = 3 or X_marking.sts-utd = Status_ else x_marking.sts-utd <> 99 INDEXED-REPOSITION. else OPEN QUERY br-mark FOR EACH X_marking NO-LOCK where x_marking.mark-parent = p-parent_mark and if Status_ <> 0 then if Status_ = 7 then x_marking.sts-utd = Status_ else x_marking.sts-utd = 3 or X_marking.sts-utd = Status_ else x_marking.sts-utd <> 99 INDEXED-REPOSITION.    OPEN QUERY br-mark-item for each X_marking-line no-lock where X_marking-line.mark-parent = vMarkBrow2   and if Status_ <> 0 then if Status_ = 7 then x_marking-line.sts-utd = Status_ else x_marking-line.sts-utd = 3 or X_marking-line.sts-utd = Status_ else x_marking-line.sts <> 99 INDEXED-REPOSITION.
        apply "entry" to br-mark in frame d-mark.
        f-qnty-unit = v-qnty-mark .
        f-qnty-bar-code = v-qnty-mark .
        display f-qnty-unit with frame d-mark .
        display f-qnty-bar-code with frame d-mark .
    END.
ON choose OF b-exit IN FRAME d-mark
DO:
    define buffer buf_marking for ub.marking .
    define variable quest-ok as logical no-undo .
    define variable quest-scan as logical no-undo .
    define buffer buf_utd for ub.utd .
    if  p-type = 6 then
    do:
      find first buf_utd no-lock where buf_utd.db-num = X_marking.db-num and buf_utd.doc-id = X_marking.doc-id no-error .
      if X_marking.box-qnty = qnty-mark-2 then
      do:
        find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking.mark and buf_utd-marking-lines.db-num = X_marking.db-num and
          buf_utd-marking-lines.doc-id = X_marking.doc-id no-error .
        if available (buf_utd-marking-lines) then
        do:
          buf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB .
          buf_utd-marking-lines.doc-level = 1 .
          X_marking.sts-utd = Marking:Checked_:KeyIntDB .
          X_marking.stts-utd = StatusTHName(X_marking.sts-utd) .
        end.
        for first buf_marking exclusive-lock where buf_marking.mark = buf_utd-marking-lines.mark :
          buf_marking.sts = Marking:Ungrouped:KeyIntDB .
          X_marking.sts = Marking:Ungrouped:KeyIntDB .
          X_marking.stts = StatusTHName(X_marking.sts) .
        end.
        run save-mark .
      end .
      else
      do:
        message "Марки просканированы не полностью." skip
          "Должны быть просканированы все марки." skip
          "Продолжить сканирование?" skip
          "Да – возврат к сканированию" skip
          "Нет – сброс введенной информации"
          view-as alert-box question buttons yes-no update quest-ok.
        if not quest-ok then
        do:
            for each X_marking-line exclusive-lock where X_marking-line.doc-level > 1:
              find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking-line.mark and buf_utd-marking-lines.db-num = X_marking-line.db-num and
              buf_utd-marking-lines.doc-id = X_marking-line.doc-id no-error .
              if available (buf_utd-marking-lines) then do:
                 if available (buf_utd) and buf_utd.EdocType = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB
                    then
                 do:
                    buf_utd-marking-lines.sts = Marking:DeliveryControl:KeyIntDB .
                    X_marking-line.sts-utd = Marking:DeliveryControl:KeyIntDB .
                    X_marking-line.stts-utd = StatusTHName(X_marking-line.sts-utd) .
                 end .
                 else
                 do:
                    buf_utd-marking-lines.sts = Marking:PendingVerification:KeyIntDB .
                    X_marking-line.sts-utd = Marking:PendingVerification:KeyIntDB .
                    X_marking-line.stts-utd = StatusTHName(X_marking-line.sts-utd) .
                 end.
              end.
              if X_marking-line.GrayZone = yes then
              do:
                delete X_marking-line .
              end.
            end.
        end.
        else
        do:
          return no-apply .
        end.
      end.
    end.
   else if p-type = 7 then
    do:
      define variable vQnty as integer no-undo.
      find first buf_utd no-lock where buf_utd.db-num = X_marking.db-num and buf_utd.doc-id = X_marking.doc-id no-error .
      for each tt-gray-marking-lines where tt-gray-marking-lines.mark-parent eq X_marking.mark
                                       and   tt-gray-marking-lines.sts-utd = Marking:Checked_:KeyIntDB
                                          or tt-gray-marking-lines.sts-utd = Marking:MarkError:KeyIntDB
      no-lock:
         vQnty = vqnty + tt-gray-marking-lines.box-qnty.
      end.
      if X_marking.box-qnty ne vQnty then
      do:
         message "Марки просканированы не полностью." skip
          "Не просканированные марки будут не приняты" skip
          "Продолжить сканирование?" skip
          "Да – возврат к сканированию" skip
          "Нет"
          view-as alert-box question buttons yes-no update quest-ok.
        if not quest-ok then
        do:
           run save-mark .
        end.
      end .
      else
      do:
         return no-apply .
      end.
    end.
  END.
ON choose OF b-hist IN FRAME d-mark
    DO:
        if available (X_marking) then
        do:
            run str/mark_hist.w(input parparentproc,
                input X_marking.mark,
                input p-mode).
        end.
        else
        do:
            if available (X_marking-line) then
            do:
                run str/mark_hist.w(input parparentproc,
                    input X_marking-line.mark,
                    input p-mode).
            end.
            else
            do:
                message "Не выбрана марка"
                    view-as alert-box.
            end.
        end.
    END.
ON CHOOSE OF b-mark IN FRAME d-mark
    DO:
        define variable loc#log     as logical no-undo .
        define variable row-marking as rowid   no-undo .
        if available X_marking
           and X_marking.isMark
        then
        do:
            if X_marking.marking-string = "*" then X_marking.marking-string = "" .
            else X_marking.marking-string = "*" .
            row-marking = rowid(X_marking).
            loc#log = br-mark:refresh() .
            reposition br-mark to rowid row-marking.
            loc#log = br-mark:refresh() .
            if last-event:function <> "MOUSE-SELECT-DBLCLICK" then
            do:
                loc#log = br-mark:select-next-row () .
                apply "VALUE-CHANGED" to br-mark in frame d-mark .
            end.
            apply "entry" to br-mark in frame d-mark.
         end.
    END.
ON CHOOSE OF b-mark-2 IN FRAME d-mark
    DO:
        define variable loc#log     as logical no-undo .
        define variable row-marking as rowid   no-undo .
        apply "entry" to br-mark in frame d-mark.
        if     available X_marking-line
           and X_marking.isMark
        then
        do:
            if X_marking-line.marking-string = "*" then X_marking-line.marking-string = "" .
            else X_marking-line.marking-string = "*" .
            row-marking = rowid(X_marking-line).
            loc#log = br-mark-item:refresh() .
            reposition br-mark-item to rowid row-marking.
            if last-event:function <> "MOUSE-SELECT-DBLCLICK" then
            do:
                loc#log = br-mark-item:select-next-row () .
                apply "VALUE-CHANGED" to br-mark-item in frame d-mark.
            end.
        end.
        apply "entry" to br-mark-item in frame d-mark.
    END.
ON value-changed OF br-mark-item IN FRAME d-mark
    DO:
        br-mark-item:refresh () no-error .
    END.
ON ROW-DISPLAY OF br-mark IN FRAME d-mark
    DO:
        if p-type = 1 or p-type = 6 or p-type = 7 then
        do:
            case X_marking.sts-utd:
                when Marking:Checked_:KeyIntDB then
                    do:
                        X_marking.gds-code:fGCOLOR in browse br-mark = CYAN_COLOR.
                        X_marking.gds-name:fGCOLOR in browse br-mark = CYAN_COLOR.
                        X_marking.mark:fGCOLOR in browse br-mark = CYAN_COLOR.
                        X_marking.box-qnty:fGCOLOR in browse br-mark = CYAN_COLOR.
                        X_marking.weight:fGCOLOR in browse br-mark = CYAN_COLOR.
                        X_marking.unit:fGCOLOR in browse br-mark = CYAN_COLOR.
                        X_marking.stts:fGCOLOR in browse br-mark = CYAN_COLOR.
                        typem:fGCOLOR in browse br-mark = CYAN_COLOR.
                    end.
                when Marking:MarkError:KeyIntDB then
                    do:
                        X_marking.gds-code:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.gds-name:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.mark:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.box-qnty:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.weight:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.unit:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.stts:fGCOLOR in browse br-mark = red_COLOR.
                        typem:fGCOLOR in browse br-mark = red_COLOR.
                    end.
            end case.
            if X_marking.sts = Marking:MarkError:KeyIntDB then
            do:
                X_marking.gds-code:fGCOLOR in browse br-mark = red_COLOR.
                X_marking.gds-name:fGCOLOR in browse br-mark = red_COLOR.
                X_marking.mark:fGCOLOR in browse br-mark = red_COLOR.
                X_marking.box-qnty:fGCOLOR in browse br-mark = red_COLOR.
                X_marking.weight:fGCOLOR in browse br-mark = red_COLOR.
                X_marking.unit:fGCOLOR in browse br-mark = red_COLOR.
                X_marking.stts:fGCOLOR in browse br-mark = red_COLOR.
                typem:fGCOLOR in browse br-mark = red_COLOR.
            end.
        end.
        else
        do:
            case X_marking.sts:
                when Marking:MarkError:KeyIntDB then
                    do:
                        X_marking.gds-code:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.gds-name:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.mark:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.box-qnty:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.weight:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.unit:fGCOLOR in browse br-mark = red_COLOR.
                        X_marking.stts:fGCOLOR in browse br-mark = red_COLOR.
                        typem:fGCOLOR in browse br-mark = red_COLOR.
                    end.
            end case.
        end.
    END .
ON value-changed OF br-mark IN FRAME d-mark
DO:
        br-mark:refresh() no-error .
        if p-type = 1 then
        do:
            if X_marking.sts = Marking:GrayZone:KeyIntDB then
            do:
                enable
                    b_block
                    with frame d-mark .
            end.
            else
            do:
                disable b_block with frame d-mark .
            end.
        end.
        vMarkBrow2 = if not available X_marking then ? else X_marking.mark.
        OPEN QUERY br-mark-item for each X_marking-line no-lock where X_marking-line.mark-parent = vMarkBrow2   and if Status_ <> 0 then if Status_ = 7 then x_marking-line.sts-utd = Status_ else x_marking-line.sts-utd = 3 or X_marking-line.sts-utd = Status_ else x_marking-line.sts <> 99 INDEXED-REPOSITION. .
    END.
ON ROW-DISPLAY OF br-mark-item IN FRAME d-mark
    DO:
        if p-type = 1 or p-type = 6 or p-type = 7  then
        do:
            case X_marking-line.sts-utd:
                when Marking:Checked_:KeyIntDB then
                    do:
                        X_marking-line.gds-code:fGCOLOR in browse br-mark-item = CYAN_COLOR.
                        X_marking-line.gds-name:fGCOLOR in browse br-mark-item = CYAN_COLOR.
                        X_marking-line.mark:fGCOLOR in browse br-mark-item = CYAN_COLOR.
                        X_marking-line.box-qnty:fGCOLOR in browse br-mark-item = CYAN_COLOR.
                        X_marking-line.weight:fGCOLOR in browse br-mark-item = CYAN_COLOR.
                        X_marking-line.unit:fGCOLOR in browse br-mark-item = CYAN_COLOR.
                        X_marking-line.stts:fGCOLOR in browse br-mark-item = CYAN_COLOR.
                        typem:fGCOLOR in browse br-mark-item = CYAN_COLOR.
                    end.
                when Marking:MarkError:KeyIntDB then
                    do:
                        X_marking-line.gds-code:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.gds-name:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.mark:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.box-qnty:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.weight:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.unit:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.stts:fGCOLOR in browse br-mark-item = red_COLOR.
                        typem:fGCOLOR in browse br-mark-item = red_COLOR.
                    end.
            end case.
            if X_marking-line.sts = Marking:MarkError:KeyIntDB then
            do:
                X_marking-line.gds-code:fGCOLOR in browse br-mark-item = red_COLOR.
                X_marking-line.gds-name:fGCOLOR in browse br-mark-item = red_COLOR.
                X_marking-line.mark:fGCOLOR in browse br-mark-item = red_COLOR.
                X_marking-line.box-qnty:fGCOLOR in browse br-mark-item = red_COLOR.
                X_marking-line.weight:fGCOLOR in browse br-mark-item = red_COLOR.
                X_marking-line.unit:fGCOLOR in browse br-mark-item = red_COLOR.
                X_marking-line.stts:fGCOLOR in browse br-mark-item = red_COLOR.
                typem:fGCOLOR in browse br-mark-item = red_COLOR.
            end.
        end.
        else
        do:
            case X_marking-line.sts:
                when Marking:MarkError:KeyIntDB then
                    do:
                        X_marking-line.gds-code:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.gds-name:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.mark:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.box-qnty:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.weight:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.unit:fGCOLOR in browse br-mark-item = red_COLOR.
                        X_marking-line.stts:fGCOLOR in browse br-mark-item = red_COLOR.
                        typem:fGCOLOR in browse br-mark-item = red_COLOR.
                    end.
            end case.
        end.
    END .
ON CHOOSE OF bt-not-sel-all IN FRAME d-mark
    DO:
        define variable loc#log as logical no-undo .
        if available X_marking
           and X_marking.isMark
        then
        do:
            v-rid-list = "" .
            for each X_marking where X_marking.doc-level = vLevel:
                X_marking.marking-string = "*" .
                loc#log = br-mark:refresh() no-error.
            end.
        end.
        apply "entry" to br-mark in frame d-mark.
    END.
ON CHOOSE OF bt-not-sel-all-2 IN FRAME d-mark
    DO:
        define variable loc#log as logical no-undo .
        if available (X_marking) then
        do:
            v-rid-list2 = "" .
            for each X_marking-line where X_marking.mark begins X_marking-line.mark-parent and X_marking-line.doc-level > 1:
                X_marking-line.marking-string = "*" .
                loc#log = br-mark-item:refresh() no-error.
            end.
        end.
        apply "entry" to br-mark-item in frame d-mark.
    END.
ON CHOOSE OF bt-not-sel-desel-all IN FRAME d-mark
    DO:
        define variable loc#log as logical no-undo .
        v-rid-list = "" .
        For each X_marking where X_marking.marking-string = "*":
            X_marking.marking-string = "" .
        end.
        loc#log = br-mark:refresh() no-error.
    END.
ON CHOOSE OF bt-not-sel-desel-all-2 IN FRAME d-mark
    DO:
        define variable loc#log as logical no-undo .
        v-rid-list2 = "" .
        For each X_marking-line where X_marking-line.marking-string = "*":
            X_marking-line.marking-string = "" .
        end.
        loc#log = br-mark-item:refresh() .
    END.
ON CHOOSE OF b_block IN FRAME d-mark
    DO:
        define buffer gray_marking                for ub.marking .
        define buffer gray_unit-marking           for ub.marking .
        define buffer gray_utd-marking-lines      for ub.utd-marking-lines .
        define buffer gray_unit_utd-marking-lines for ub.utd-marking-lines .
        for first gray_utd-marking-lines no-lock where gray_utd-marking-lines.db-num = X_marking.db-num and
            gray_utd-marking-lines.doc-id = X_marking.doc-id and
            gray_utd-marking-lines.LineNum = X_marking.LineNum and
            gray_utd-marking-lines.mark = X_marking.mark:
            for first gray_marking no-lock where gray_marking.mark = X_marking.mark :
                create tt-gray-marking-lines .
                assign
                    tt-gray-marking-lines.gds-name    = GdsName(gray_utd-marking-lines.gds-code)
                    tt-gray-marking-lines.stts-utd    = StatusTHName(gray_utd-marking-lines.sts)
                    tt-gray-marking-lines.stts        = StatusTHName(gray_marking.sts)
                    tt-gray-marking-lines.mark        = gray_marking.mark
                    tt-gray-marking-lines.mark-parent = gray_marking.mark-parent
                    tt-gray-marking-lines.gds-code    = gray_utd-marking-lines.gds-code
                    tt-gray-marking-lines.sts         = gray_marking.sts
                    tt-gray-marking-lines.sts-utd     = gray_utd-marking-lines.sts
                    tt-gray-marking-lines.unit        = gray_marking.unit
                    tt-gray-marking-lines.box-qnty    = gray_marking.box-qnty
                    tt-gray-marking-lines.LineNum     = gray_utd-marking-lines.LineNum
                    tt-gray-marking-lines.db-num      = gray_utd-marking-lines.db-num
                    tt-gray-marking-lines.doc-id      = gray_utd-marking-lines.doc-id
                    tt-gray-marking-lines.doc-level   = gray_utd-marking-lines.doc-level
                    .
            end.
            for each gray_unit-marking no-lock where gray_unit-marking.mark-parent = gray_utd-marking-lines.mark:
                for first gray_unit_utd-marking-lines no-lock where gray_unit_utd-marking-lines.db-num = X_marking.db-num and gray_unit_utd-marking-lines.doc-id = X_marking.doc-id
                    and gray_unit_utd-marking-lines.LineNum = X_marking.LineNum and gray_unit_utd-marking-lines.mark = gray_unit-marking.mark:
                    create tt-gray-marking-lines .
                    assign
                        tt-gray-marking-lines.gds-name    = GdsName(gray_unit_utd-marking-lines.gds-code)
                        tt-gray-marking-lines.stts-utd    = StatusTHName(gray_unit_utd-marking-lines.sts)
                        tt-gray-marking-lines.stts        = StatusTHName(gray_unit-marking.sts)
                        tt-gray-marking-lines.mark        = gray_unit-marking.mark
                        tt-gray-marking-lines.mark-parent = gray_unit-marking.mark-parent
                        tt-gray-marking-lines.gds-code    = gray_unit_utd-marking-lines.gds-code
                        tt-gray-marking-lines.sts         = gray_unit-marking.sts
                        tt-gray-marking-lines.sts-utd     = gray_unit_utd-marking-lines.sts
                        tt-gray-marking-lines.unit        = gray_unit-marking.unit
                        tt-gray-marking-lines.unit-ext    = gray_unit-marking.unit-ext
                        tt-gray-marking-lines.box-qnty    = gray_unit-marking.box-qnty
                        tt-gray-marking-lines.LineNum     = gray_unit_utd-marking-lines.LineNum
                        tt-gray-marking-lines.db-num      = gray_unit_utd-marking-lines.db-num
                        tt-gray-marking-lines.doc-id      = gray_unit_utd-marking-lines.doc-id
                        tt-gray-marking-lines.doc-level   = gray_unit_utd-marking-lines.doc-level
                        .
                end.
            end.
        end.
        run str/mark_browse.w (input parparentproc,
            input-output table tt-gray-marking-lines by-reference,
            input p-mode,
            input "Марки по товару " + string(X_marking.gds-code) + " " + GdsName(X_marking.gds-code) + " со статусом: " + StatusTHName(Marking:GrayZone:KeyIntDB),
            input 6,
            input ""
            ) no-error .
        for each tt-gray-marking-lines no-lock:
            find first tt-marking-lines exclusive-lock where tt-marking-lines.mark = tt-gray-marking-lines.mark no-error .
            if not available (tt-marking-lines) then
            do:
                create tt-marking-lines .
                buffer-copy tt-gray-marking-lines to tt-marking-lines .
                v-qnty-mark = v-qnty-mark + 1 .
                f-qnty-unit = v-qnty-mark .
            end.
            else
            do:
                assign
                    tt-marking-lines.sts      = tt-gray-marking-lines.sts
                    tt-marking-lines.stts     = tt-gray-marking-lines.stts
                    tt-marking-lines.sts-utd  = tt-gray-marking-lines.sts-utd
                    tt-marking-lines.stts-utd = tt-gray-marking-lines.stts-utd
                    .
            end.
        end.
        recid_mark = recid (X_marking) .
        empty temp-table tt-gray-marking-lines .
        browse br-mark :refresh().
        reposition br-mark to recid recid_mark no-error .
        browse br-mark-item:refresh () no-error .
        if p-parent_mark eq "" then OPEN QUERY br-mark FOR EACH X_marking NO-LOCK where x_marking.doc-level = 1 and if Status_ <> 0 then if Status_ = 7 then x_marking.sts-utd = Status_ else x_marking.sts-utd = 3 or X_marking.sts-utd = Status_ else x_marking.sts-utd <> 99 INDEXED-REPOSITION. else OPEN QUERY br-mark FOR EACH X_marking NO-LOCK where x_marking.mark-parent = p-parent_mark and if Status_ <> 0 then if Status_ = 7 then x_marking.sts-utd = Status_ else x_marking.sts-utd = 3 or X_marking.sts-utd = Status_ else x_marking.sts-utd <> 99 INDEXED-REPOSITION.    OPEN QUERY br-mark-item for each X_marking-line no-lock where X_marking-line.mark-parent = vMarkBrow2   and if Status_ <> 0 then if Status_ = 7 then x_marking-line.sts-utd = Status_ else x_marking-line.sts-utd = 3 or X_marking-line.sts-utd = Status_ else x_marking-line.sts <> 99 INDEXED-REPOSITION.
        apply "value-changed" to br-mark in frame d-mark.
    END.
ON CHOOSE OF b_error IN FRAME d-mark
    DO:
        define variable v-ok as logical no-undo .
        run ref/dialog-error.w (input X_marking.db-num, input X_marking.doc-id, input "utd-marking-lines") .
        if  error-status:error then
        do:
            return return-value .
        end.
        run enable_UI in this-procedure .
    END.
ON CHOOSE OF b-look IN FRAME d-mark
    DO:
        define variable v-ok as logical no-undo .
        define buffer buf-mark for tt-marking-lines.
        find first buf-mark where buf-mark.mark-parent eq X_marking.mark no-lock no-error.
        if available buf-mark
        then do:
           run str/mark_browse.w (input parparentproc,
               input-output table tt-marking-lines by-reference,
               input p-mode,
               input substitute ("&1 по марке &2 уровень &3",p-doc, X_marking.mark ,X_marking.doc-level + 1) ,
               input p-type,
               input X_marking.mark
               ) no-error .
           if  error-status:error then
           do:
               return return-value .
           end.
           run enable_UI in this-procedure .
       end.
    END.
ON VALUE-CHANGED OF c-status IN FRAME d-mark
    DO:
        assign c-status .
    END.
ON VALUE-CHANGED OF c-status-2 IN FRAME d-mark
    DO:
        assign c-status-2 .
    END.
ON VALUE-CHANGED OF Status_ IN FRAME d-mark
    DO:
        assign status_ .
        run init-temp in this-procedure .
    END.
ON any-printable OF v-mark IN FRAME d-mark
do:
        run proc-any-key.
    end.
ON ENTRY OF v-mark IN FRAME d-mark
DO:
        run LoadKeyboardLayoutA (input v-scan-str, input 0, output iLang).
        run adm/shattri.p (
               input "get":U
               ,input  v-cntxt-obj-type
               ,input  v-cntxt-obj-code
               ,input  'marking':U
               ,input  'rus-key':U
               ,output p-value-character
               ,output p-value-date
               ,output p-value-decimal
               ,output p-value-integer
               ,output p-value-logical
               ,output p-param-type
               ,input-output table-handle v-tth
               ) no-error .
        IF p-value-logical = yes THEN  iLang = 68748313.
        run ActivateKeyboardLayout (input iLang, input 0).
    END.
ON return OF v-mark IN FRAME d-mark
DO:
   if v-mark:screen-value in frame d-mark = ""
        then
    do:
        v-mark:screen-value in frame d-mark = v-scan-str.
    end.
    v-scan-str = "".
    assign
        v-mark = v-mark:screen-value .
   if isMark(v-mark)
   then
   do:
     run scan-mark .
     br-mark:refresh() in frame d-mark.
     OPEN QUERY br-mark-item for each X_marking-line no-lock where X_marking-line.mark-parent = vMarkBrow2   and if Status_ <> 0 then if Status_ = 7 then x_marking-line.sts-utd = Status_ else x_marking-line.sts-utd = 3 or X_marking-line.sts-utd = Status_ else x_marking-line.sts <> 99 INDEXED-REPOSITION.
     if NUM-RESULTS("br-mark-item") > 0 then
       br-mark-item:refresh() in frame d-mark.
   end.
   else
      run scan-bar-code .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-mark:PARENT eq ?
    THEN FRAME d-mark:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME d-mark
    APPLY "END-ERROR":U TO SELF.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code).
    Marking = ObjSrv:Env:Marking:Sts:Mark .
    tree = ObjSrv:Lib:MarkingTree .
    run LoadKeyboardLayoutA (input v-scan-str, input 0, output iLang).
      run adm/shattri.p (
               input "get":U
               ,input  v-cntxt-obj-type
               ,input  v-cntxt-obj-code
               ,input  'marking':U
               ,input  'rus-key':U
               ,output p-value-character
               ,output p-value-date
               ,output p-value-decimal
               ,output p-value-integer
               ,output p-value-logical
               ,output p-param-type
               ,input-output table-handle v-tth
               ) no-error .
      IF p-value-logical = yes THEN  iLang = 68748313.
    run ActivateKeyboardLayout (input iLang, input 0).
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_mark_stchange':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output log-res
    )  .
end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-mark :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-mark-item :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
   find first utd no-lock where utd.doc-id = tt-marking-lines.doc-id and utd.db-num = tt-marking-lines.db-num no-error .
   if available (utd) then do:
      if utd.EDocType = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB then v-edoc-type = yes .
   end.
   if num-entries(p-doc,chr(4)) > 1 then
   do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input trim(entry(2,entry(1,p-doc,chr(4)),':')) ,
                        input 'is-return':U ,
                       output varvalue ,
                       output vartype ) no-error .
     mIsRasVneshReturn = (varvalue = "yes").
   end.
    run init-temp in this-procedure .
    run enable_UI in this-procedure .
    apply "entry" to v-mark in FRAME d-mark.
    if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsManual
        then v-manual = yes .
    else
    do:
        v-manual = no .
        v-mark:READ-ONLY IN FRAME d-mark        = TRUE .
    end.
    X_marking-line.mark:COLUMN-READ-ONLY IN BROWSE br-mark-item = YES.
    X_marking.mark     :COLUMN-READ-ONLY IN BROWSE br-mark      = YES.
    apply "value-changed" to br-mark in FRAME d-mark.
    WAIT-FOR GO OF FRAME d-mark focus br-mark-item.
END.
run disable_UI in this-procedure .
PROCEDURE disable_UI :
    HIDE FRAME d-mark.
END PROCEDURE.
PROCEDURE enable_UI :
    frame d-mark:title = entry(1,p-doc,chr(4)) + " " + p-mode.
    ENABLE
        b-exit
        b-hist
        b-look
        with frame d-mark .
    enable
    br-mark
    br-mark-item
    with frame d-mark .
    display f-text with frame d-mark .
    if p-mode <> 'ПРОСМОТР':U then
    do:
        if p-type = 5 then
        do:
            ENABLE
                b-del
                b-mark
                bt-not-sel-all
                bt-not-sel-desel-all
                with frame d-mark .
        end.
        ENABLE
            v-mark
            with frame d-mark .
        if log-res then
        do:
            enable
                c-status
                b-change
                b-mark
                bt-not-sel-all
                bt-not-sel-desel-all
                 WITH FRAME d-mark.
        end.
    end.
    else
    do:
        display
            b-del
            b-mark
            b-mark-2
            bt-not-sel-all
            bt-not-sel-all-2
            bt-not-sel-desel-all
            bt-not-sel-desel-all-2
            c-status
            c-status-2
            b-change
            b-change-2
            c-status-2
            WITH FRAME d-mark.
    end.
    if p-type = 1 then
    do:
        if p-mode <> 'ПРОСМОТР':U then
        do:
        ENABLE
            Status_
            v-mark
            with frame d-mark .
        end.
    end.
    else
    do:
        hide b_block in frame d-mark .
    end.
    if p-type = 0 then
    do:
        hide
            Status_
            v-mark
            in frame d-mark .
    end.
    if p-type <> 2 then
    do:
        find first buf_utd-err no-lock where buf_utd-err.db-num = tt-marking-lines.db-num and buf_utd-err.doc-id = tt-marking-lines.doc-id and buf_utd-err.reckey begins "utd-marking-lines" no-error .
        if available (buf_utd-err) then
            enable b_error with frame d-mark .
    end.
    if p-type = 6 then
    do:
        display qnty-mark with frame d-mark .
        display qnty-mark-2 with frame d-mark .
        hide f-qnty-unit in frame d-mark .
        hide f-qnty-bar-code  in frame d-mark .
    end.
    else
    do:
        display f-qnty-unit with frame d-mark .
        display f-qnty-bar-code with frame d-mark .
        hide qnty-mark   in frame d-mark .
        hide qnty-mark-2 in frame d-mark .
    end.
END PROCEDURE.
PROCEDURE save-mark :
    define variable v-GTIN as character no-undo .
    for each X_marking-line no-lock where X_marking-line.GrayZone = yes:
        create buf_utd-marking-lines .
        assign
            buf_utd-marking-lines.db-num    = X_marking-line.db-num
            buf_utd-marking-lines.doc-id    = X_marking-line.doc-id
            buf_utd-marking-lines.doc-level = X_marking-line.doc-level
            buf_utd-marking-lines.gds-code  = X_marking-line.gds-code
            buf_utd-marking-lines.LineNum   = X_marking-line.LineNum
            buf_utd-marking-lines.mark      = X_marking-line.mark
            buf_utd-marking-lines.sts       = X_marking-line.sts-utd
            .
        find first ub.marking exclusive-lock where ub.marking.mark = X_marking-line.mark no-error .
        if not available (ub.marking) then
        do:
            create ub.marking .
            assign
                ub.marking.mark = X_marking-line.mark
                ub.marking.box-qnty    = ?
            .
        end.
        v-GTIN = getGtinByDM(X_marking-line.mark) .
        assign
            ub.marking.gds-code    = X_marking-line.gds-code
            ub.marking.sts         = X_marking-line.sts
            ub.marking.gds-ext-id  = v-GTIN
            ub.marking.obj-code    = X_marking-line.obj-code
            ub.marking.obj-type    = X_marking-line.obj-type
            ub.marking.mark-parent = mark-parent
        .
        if v-edoc-type then ub.marking.sts = Marking:Checked_:KeyIntDB .
        ub.marking.unit-ext  = getLevelMotpByDM(X_marking-line.mark) .
        ub.marking.box-qnty  = getQntyCodeByGtin(getGtinByDM(X_marking-line.mark)).
    end.
END PROCEDURE.
PROCEDURE init-temp :
    define variable ii       as integer   no-undo .
    define variable Status_1 as character no-undo .
    Status_1 = "" + chr(44) + '0':U .
   define variable MarkType as ibs.th.gbl.map.mapstring no-undo.
   define variable objType  as ibs.th.gbl.propmap no-undo.
   define variable Types as ibs.th.str.marking.sts.mark no-undo.
   Types = ObjSrv:Env:Marking:Sts:Mark.
   MarkType = Types:mapType.
    do ii = 1 to MarkType:GetItemByLab(ii):
        objType = Types:CurrProp.
        Status_1 = Status_1 + chr(44) + objType:Label_ + chr(44) + string(objType:KeyIntDB) .
    end.
    ASSIGN
        c-status:LIST-ITEM-PAIRS  in frame d-mark = Status_1 .
    ASSIGN
        c-status-2:LIST-ITEM-PAIRS  in frame d-mark = Status_1 .
    if p-parent_mark <> "" then
    do:
      for first tt-marking-lines no-lock where tt-marking-lines.mark-parent = p-parent_mark:
        vLevel = tt-marking-lines.doc-level.
      end.
    end.
    for each tt-marking-lines no-lock where tt-marking-lines.unit-ext = "UNIT":
           v-qnty-mark = v-qnty-mark + 1 .
           if tt-marking-lines.sts-utd = Marking:Checked_:KeyIntDB then
             qnty-mark-2 = qnty-mark-2 + 1.
    end.
    f-qnty-unit = v-qnty-mark .
    f-qnty-bar-code = v-qnty-mark .
    if p-type = 6 then
    do:
        find first tt-marking-lines no-lock where tt-marking-lines.doc-level = 1 no-error .
        if available (tt-marking-lines) then
        do:
            qnty-mark = tt-marking-lines.box-qnty .
            mark-parent = tt-marking-lines.mark .
        end.
        f-text = "Упаковка с неполным составом марок/штрих-кодом, необходимо просканировать все марки упаковки" .
    end.
    if p-parent_mark eq "" then OPEN QUERY br-mark FOR EACH X_marking NO-LOCK where x_marking.doc-level = 1 and if Status_ <> 0 then if Status_ = 7 then x_marking.sts-utd = Status_ else x_marking.sts-utd = 3 or X_marking.sts-utd = Status_ else x_marking.sts-utd <> 99 INDEXED-REPOSITION. else OPEN QUERY br-mark FOR EACH X_marking NO-LOCK where x_marking.mark-parent = p-parent_mark and if Status_ <> 0 then if Status_ = 7 then x_marking.sts-utd = Status_ else x_marking.sts-utd = 3 or X_marking.sts-utd = Status_ else x_marking.sts-utd <> 99 INDEXED-REPOSITION.    OPEN QUERY br-mark-item for each X_marking-line no-lock where X_marking-line.mark-parent = vMarkBrow2   and if Status_ <> 0 then if Status_ = 7 then x_marking-line.sts-utd = Status_ else x_marking-line.sts-utd = 3 or X_marking-line.sts-utd = Status_ else x_marking-line.sts <> 99 INDEXED-REPOSITION.
END PROCEDURE.
FUNCTION GdsName RETURNS CHARACTER
    ( input p-gds-code as integer ) :
    define buffer buf_goods for ub.goods .
    define variable v-gds-name as character no-undo .
    find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
    if available (buf_goods) then v-gds-name = buf_goods.gds-name .
    RETURN v-gds-name.
END FUNCTION.
FUNCTION getStatusName RETURNS CHARACTER
    ( input p-mark as character,
      input p-sts-glob as integer,
      input p-sts-loc  as integer ):
    define variable vExtDocType as character no-undo.
    define buffer c-marking for ub.c-marking.
    vExtDocType = if num-entries(p-doc,chr(4)) > 1 then entry(2,p-doc,chr(4)) else ?.
    if p-sts-loc = marking:Reserved:KeyIntDB and
       (vExtDocType = 'we':U or vExtDocType = 'ev':U or mIsRasVneshReturn) then
    do:
      find last c-marking no-lock where
                c-marking.mark = p-mark
           use-index pi-2 no-error.
      if not avail c-marking or
         c-marking.sts = marking:Checked_:KeyIntDB or
         c-marking.sts = marking:FreeZone:KeyIntDB then
        return StatusTHName(p-sts-glob).
      else
        return substitute("&1_&2",StatusTHName(p-sts-loc),StatusTHName(c-marking.sts)).
    end.
    else
      return if p-sts-loc = marking:Checked_:KeyIntDB    and
                p-sts-glob <> marking:Ungrouped:KeyIntDB and
                p-sts-glob <> marking:MarkError:KeyIntDB
             then StatusTHName(p-sts-loc)
             else StatusTHName(p-sts-glob).
END FUNCTION.
ON ENTRY OF v-mark IN FRAME d-mark
    DO:
        run LoadKeyboardLayoutA (input v-scan-str, input 0, output iLang).
        run adm/shattri.p (
               input "get":U
               ,input  v-cntxt-obj-type
               ,input  v-cntxt-obj-code
               ,input  'marking':U
               ,input  'rus-key':U
               ,output p-value-character
               ,output p-value-date
               ,output p-value-decimal
               ,output p-value-integer
               ,output p-value-logical
               ,output p-param-type
               ,input-output table-handle v-tth
               ) no-error .
        IF p-value-logical = yes THEN  iLang = 68748313.
        run ActivateKeyboardLayout (input iLang, input 0).
    END.
procedure LoadKeyboardLayoutA external "user32" :
    define input  parameter P1 as char.
    define input  parameter P2 as LONG.
    define return parameter pret as LONG.
end procedure.
procedure ActivateKeyboardLayout external "user32" :
    define input parameter P1 as LONG.
    define input parameter P2 as LONG.
END PROCEDURE.
PROCEDURE scan-mark :
    define variable v_list      as character no-undo .
    define variable ii          as integer   no-undo .
    define variable v-marking   as character no-undo .
    define variable recid_mark1 as integer   no-undo .
    define variable v-GTIN      as character no-undo .
    define variable v-gds-code  as integer   no-undo .
    define VARIABLE vRecKeyLine as character no-undo .
    define VARIABLE vMsg        as character no-undo .
    define variable vFlag       as log       no-undo.
    define buffer gray_marking                for ub.marking .
    define buffer gray_unit-marking           for ub.marking .
    define buffer gray_utd-marking-lines      for ub.utd-marking-lines .
    define buffer gray_unit_utd-marking-lines for ub.utd-marking-lines .
    define buffer buf_utd-lines               for ub.utd-lines .
    define buffer buf_utd-marking-lines       for ub.utd-marking-lines .
    define buffer X_utd-lines                 for tt-utd-lines .
    define buffer buf_utd-err                 for ub.utd-err .
    define buffer un_utd-marking-lines        for ub.utd-marking-lines .
    if v-mark:screen-value in frame d-mark = ""
        then
    do:
        v-mark:screen-value in frame d-mark = v-scan-str.
    end.
    v-scan-str = "".
    assign
        v-mark = v-mark:screen-value in frame d-mark.
    v-marking = GetCodeIdent(v-mark) .
    f-text = "" .
    f-text:screen-value = "" .
    ASSIGN
        v_list = 'Ё,Й,Ц,У,К,Е,Н,Г,Ш,Щ,З,Х,Ъ,Ф,Ы,В,А,П,Р,О,Л,Д,Ж,Э,Я,Ч,С,М,И,Т,Ь,Б,Ю':U .
    do ii = 1 to length (v-mark):
        if LOOKUP( SUBSTRING( v-mark, ii, 1 ), v_list )  > 1 then
        do:
            message "Не корректно считана акцизная марка, перед считыванием переключите клавиатуру на английскую раскладку."
                view-as alert-box.
            v-mark:screen-value = "" .
            v-mark = "" .
            return .
        end.
    end.
    v-marking = GetCodeIdent(v-mark) .
    if v-marking = "" or v-marking = ? then
    do:
        F-text = "            Просканирован штрих код, необходимо просканировать марку" .
        display F-text with frame d-mark.
        v-mark:screen-value = "" .
        v-mark = "" .
        return no-apply.
    end.
    if p-mode <> 'ПРОСМОТР':U then
    do:
        if p-type = 6 then
        do:
            find first X_marking-line exclusive-lock where X_marking-line.mark begins v-marking no-error .
            if available (X_marking-line) then
            do:
                recid_mark = recid (X_marking-line) .
                if X_marking-line.sts-utd = Marking:Checked_:KeyIntDB then
                do:
                    if qnty-mark = qnty-mark-2 then
                    do:
                        F-text = "               Упаковка просканирована полностью".
                        display F-text with frame d-mark.
                        v-mark:screen-value = "" .
                        v-mark = "" .
                        return no-apply.
                    end.
                    else
                    do:
                        F-text = "            Марка уже проверена, просканируйте следующую".
                        display F-text with frame d-mark.
                        v-mark:screen-value = "" .
                        v-mark = "" .
                        return no-apply.
                    end.
                end.
                if X_marking-line.sts = Marking:GrayZone:KeyIntDB and X_marking-line.doc-level = 1 then
                do:
                    F-text = "      Это марка упаковки, просканируйте марку индивидуальной упаковки".
                    display F-text with frame d-mark.
                    v-mark:screen-value = "" .
                    v-mark = "" .
                    return no-apply.
                end.
                find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking-line.mark and buf_utd-marking-lines.db-num = X_marking-line.db-num and
                    buf_utd-marking-lines.doc-id = X_marking-line.doc-id no-error .
                if available (buf_utd-marking-lines) then buf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB .
                assign
                    X_marking-line.sts-utd = Marking:Checked_:KeyIntDB .
                X_marking-line.stts-utd = StatusTHName(Marking:Checked_:KeyIntDB)
                    .
                qnty-mark-2 = qnty-mark-2 + 1 .
                display qnty-mark-2 with frame d-mark .
                br-mark-item :refresh().
                reposition br-mark-item to recid recid_mark no-error .
                v-mark:screen-value = "" .
                v-mark = "" .
            end.
            else
            do:
                find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark begins v-marking and buf_utd-marking-lines.db-num = X_marking-line.db-num and
                    buf_utd-marking-lines.doc-id = X_marking-line.doc-id no-error .
                if qnty-mark = qnty-mark-2 then
                do:
                    F-text = "               Упаковка просканирована полностью".
                    display F-text with frame d-mark.
                    v-mark:screen-value = "" .
                    v-mark = "" .
                    return no-apply.
                end.
                if v-qnty-mark = qnty-mark then
                do:
                    F-text = "        Все неизвестные марки добавлены, просканируйте непроверенные марки".
                    display F-text with frame d-mark.
                    v-mark:screen-value = "" .
                    v-mark = "" .
                    return no-apply.
                end.
                if available (buf_utd-marking-lines) then
                do:
                    f-text = "                    Марка в документе уже есть".
                    display F-text with frame d-mark.
                    v-mark:screen-value = "" .
                    v-mark = "" .
                    leave .
                end.
                v-GTIN = getGtinByDM(v-marking) .
                v-gds-code = getGdsCodeByGtin(v-GTIN) .
                if v-gds-code <> X_marking.gds-code then
                do:
                    f-text = "                Марка не может относится к проверяемой упаковке ".
                    display F-text with frame d-mark.
                    v-mark:screen-value = "" .
                    v-mark = "" .
                    leave .
                end.
                find first ub.marking exclusive-lock where ub.marking.mark begins v-marking no-error .
                if available (ub.marking) then
                do:
                    f-text = "              Марка оприходована, просканируйте следующую".
                    display F-text with frame d-mark.
                    v-mark:screen-value = "" .
                    v-mark = "" .
                    leave .
                end.
                if qnty-mark-2 = X_marking.box-qnty then
                do:
                    f-text = "                  Все неизвестные марки по упаковке добавлены" .
                    display F-text with frame d-mark.
                    v-mark:screen-value = "" .
                    v-mark = "" .
                    return no-apply.
                end.
                create X_marking-line .
                assign
                    X_marking-line.db-num      = X_marking.db-num
                    X_marking-line.doc-id      = X_marking.doc-id
                    X_marking-line.doc-level   = X_marking.doc-level + 1
                    X_marking-line.gds-code    = X_marking.gds-code
                    X_marking-line.LineNum     = X_marking.LineNum
                    X_marking-line.mark        = v-marking
                    X_marking-line.sts         = Marking:DeliveryControl:KeyIntDB
                    X_marking-line.mark-parent = X_marking.mark
                    X_marking-line.GrayZone    = yes
                    .
                X_marking-line.gds-name    = GdsName(X_marking-line.gds-code)
                    .
                X_marking-line.box-qnty = getQntyCodeByGtin(getGtinByDM(v-marking)) .
                X_marking.unit-ext  = getLevelMotpByDM(v-marking) .
                assign
                X_marking-line.sts-utd = Marking:Checked_:KeyIntDB .
                X_marking-line.stts-utd = StatusTHName(Marking:Checked_:KeyIntDB) .
                X_marking-line.stts = StatusTHName(X_marking-line.sts)
                    .
                if v-edoc-type then X_marking-line.stts = StatusTHName(Marking:Checked_:KeyIntDB) .
                qnty-mark-2 = qnty-mark-2 + 1 .
                v-qnty-mark = v-qnty-mark + 1 .
                display qnty-mark-2 with frame d-mark .
                recid_mark = recid(X_marking-line) .
                br-mark-item:refresh () no-error .
                reposition br-mark-item to recid recid_mark no-error .
                v-mark:screen-value = "" .
                v-mark = "" .
            end.
        end.
        else if p-type = 2 then
        do:
            run checkPriPerem in this-procedure (v-marking, output F-text).
            if F-text <> "" then
            do:
               display F-text with frame d-mark.
               v-mark:screen-value = "" .
               v-mark = "" .
               return no-apply.
            end.
            br-mark:refresh().
            reposition br-mark to recid recid_mark no-error .
            br-mark-item:refresh () no-error .
        end.
        else
        do:
            find first X_marking exclusive-lock where X_marking.mark begins v-marking no-error .
            if v-mark <> v-marking and
               avail(X_marking) and
               X_marking.unit-ext = "LEVEL2" then
            do:
              v-marking = v-mark.
              find first X_marking exclusive-lock where X_marking.mark begins v-marking no-error .
            end.
            if available (X_marking) then
            do:
                run checkEMRC(v-mark, output vFlag).
                if not vFlag
                then do:
                   F-text = "МРЦ на упаковке меньше ЕМЦ. Приемка товара запрещена." .
                   display F-text with frame d-mark.
                   v-mark:screen-value = "" .
                   v-mark = "" .
                   return no-apply.
                end.
                for first buf_utd-marking-lines no-lock where buf_utd-marking-lines.doc-id = X_marking.doc-id
                    and buf_utd-marking-lines.db-num = X_marking.db-num
                    and buf_utd-marking-lines.mark = X_marking.mark,
                    first buf_utd-lines no-lock where buf_utd-lines.db-num = buf_utd-marking-lines.db-num
                    and buf_utd-lines.doc-id = buf_utd-marking-lines.doc-id
                    and buf_utd-lines.LineNum = buf_utd-marking-lines.LineNum:
                    run gen-key-rec ("utd-lines",
                        input  buffer buf_utd-lines:handle,
                        output vRecKeyLine).
                    find first buf_utd-err no-lock where buf_utd-err.doc-id = buf_utd-lines.doc-id and buf_utd-err.db-num = buf_utd-lines.db-num and buf_utd-err.reckey = vRecKeyLine no-error .
                    if available (buf_utd-err) then
                    do:
                        F-text = "Товар не подлежит приемке, т.к. не прошел проверку на корректность" .
                        display F-text with frame d-mark.
                        v-mark:screen-value = "" .
                        v-mark = "" .
                        return no-apply.
                    end.
                end.
                recid_mark = recid (X_marking) .
                if X_marking.isWeight then
                do:
                    f-text = "Просканированная марка по товару с переменным весом. Просканируйте марку в основном окне УПД." .
                    display F-text with frame d-mark.
                    v-mark:screen-value = "" .
                    v-mark = "" .
                    return no-apply.
                end.
                else if X_marking.sts-utd = Marking:Checked_:KeyIntDB then
                do:
                    f-text = "          Марка уже проверена, просканируйте следующую" .
                    display F-text with frame d-mark.
                    v-mark:screen-value = "" .
                    v-mark = "" .
                    return no-apply.
                end.
                else if X_marking.sts-utd = Marking:Ungrouped:KeyIntDB then
                do:
                    f-text = substitute(
                      "&1 упаковка разгруппирована, просканируйте марку &2 упаковки.",
                      if X_marking.unit-ext = "LEVEL1" then "Групповая" else "Транспортная",
                      if X_marking.unit-ext = "LEVEL1" then "потребительской" else "групповой"
                    ).
                    display F-text with frame d-mark.
                    v-mark:screen-value = "" .
                    v-mark = "" .
                    return no-apply.
                end.
                else
                do:
                    if X_marking.sts = Marking:MarkError:KeyIntDB  then
                    do:
                        F-text = "Товар не подлежит приемке, т.к. не прошел проверку на корректность" .
                        display F-text with frame d-mark.
                        v-mark:screen-value = "" .
                        v-mark = "" .
                        return no-apply.
                    end.
                    find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking.mark and buf_utd-marking-lines.db-num = X_marking.db-num and
                        buf_utd-marking-lines.doc-id = X_marking.doc-id no-error .
                    if available (buf_utd-marking-lines) then
                    do:
                        if can-find (buf_marking where buf_marking.mark = buf_utd-marking-lines.mark and buf_marking.sts = Marking:GrayZone:KeyIntDB)
                            then
                        do:
                            v-mark:screen-value = "" .
                            v-mark = "" .
                            for first gray_utd-marking-lines no-lock where gray_utd-marking-lines.db-num = X_marking.db-num and
                                gray_utd-marking-lines.doc-id = X_marking.doc-id and
                                gray_utd-marking-lines.LineNum = X_marking.LineNum and
                                gray_utd-marking-lines.mark = buf_utd-marking-lines.mark:
                                for first gray_marking no-lock where gray_marking.mark = buf_utd-marking-lines.mark :
                                    create tt-gray-marking-lines .
                                    assign
                                        tt-gray-marking-lines.gds-name    = GdsName(gray_utd-marking-lines.gds-code)
                                        tt-gray-marking-lines.stts-utd    = StatusTHName(gray_utd-marking-lines.sts)
                                        tt-gray-marking-lines.stts        = StatusTHName(gray_marking.sts)
                                        tt-gray-marking-lines.mark        = gray_marking.mark
                                        tt-gray-marking-lines.mark-parent = gray_marking.mark-parent
                                        tt-gray-marking-lines.gds-code    = gray_utd-marking-lines.gds-code
                                        tt-gray-marking-lines.sts         = gray_marking.sts
                                        tt-gray-marking-lines.sts-utd     = gray_utd-marking-lines.sts
                                        tt-gray-marking-lines.unit        = gray_marking.unit
                                        tt-gray-marking-lines.box-qnty    = gray_marking.box-qnty
                                        tt-gray-marking-lines.LineNum     = gray_utd-marking-lines.LineNum
                                        tt-gray-marking-lines.db-num      = gray_utd-marking-lines.db-num
                                        tt-gray-marking-lines.doc-id      = gray_utd-marking-lines.doc-id
                                        tt-gray-marking-lines.doc-level   = gray_utd-marking-lines.doc-level
                                        .
                                end.
                                for each gray_unit-marking no-lock where gray_unit-marking.mark-parent = gray_utd-marking-lines.mark:
                                    for first gray_unit_utd-marking-lines no-lock where gray_unit_utd-marking-lines.db-num = X_marking.db-num and gray_unit_utd-marking-lines.doc-id = X_marking.doc-id
                                        and gray_unit_utd-marking-lines.LineNum = X_marking.LineNum and gray_unit_utd-marking-lines.mark = gray_unit-marking.mark:
                                        create tt-gray-marking-lines .
                                        assign
                                            tt-gray-marking-lines.gds-name    = GdsName(gray_unit_utd-marking-lines.gds-code)
                                            tt-gray-marking-lines.stts-utd    = StatusTHName(gray_unit_utd-marking-lines.sts)
                                            tt-gray-marking-lines.stts        = StatusTHName(gray_unit-marking.sts)
                                            tt-gray-marking-lines.mark        = gray_unit-marking.mark
                                            tt-gray-marking-lines.mark-parent = gray_unit-marking.mark-parent
                                            tt-gray-marking-lines.gds-code    = gray_unit_utd-marking-lines.gds-code
                                            tt-gray-marking-lines.sts         = gray_unit-marking.sts
                                            tt-gray-marking-lines.sts-utd     = gray_unit_utd-marking-lines.sts
                                            tt-gray-marking-lines.unit        = gray_unit-marking.unit
                                            tt-gray-marking-lines.unit-ext    = gray_unit-marking.unit-ext
                                            tt-gray-marking-lines.box-qnty    = gray_unit-marking.box-qnty
                                            tt-gray-marking-lines.LineNum     = gray_unit_utd-marking-lines.LineNum
                                            tt-gray-marking-lines.db-num      = gray_unit_utd-marking-lines.db-num
                                            tt-gray-marking-lines.doc-id      = gray_unit_utd-marking-lines.doc-id
                                            tt-gray-marking-lines.doc-level   = gray_unit_utd-marking-lines.doc-level
                                            .
                                    end.
                                end.
                            end.
                            run str/mark_browse.w (input parparentproc,
                                input-output table tt-gray-marking-lines by-reference,
                                input p-mode,
                                input "Марки по товару " + string(X_marking.gds-code) + " " + GdsName(X_marking.gds-code) + " со статусом: " + StatusTHName(Marking:GrayZone:KeyIntDB),
                                input 6,
                                input ""
                                ) no-error .
                            for each tt-gray-marking-lines no-lock:
                                find first tt-marking-lines exclusive-lock where tt-marking-lines.mark = tt-gray-marking-lines.mark no-error .
                                if not available (tt-marking-lines) then
                                do:
                                    create tt-marking-lines .
                                    buffer-copy tt-gray-marking-lines to tt-marking-lines .
                                    v-qnty-mark = v-qnty-mark + 1 .
                                    f-qnty-unit = v-qnty-mark .
                                end.
                                else
                                do:
                                    assign
                                        tt-marking-lines.sts      = tt-gray-marking-lines.sts
                                        tt-marking-lines.stts     = tt-gray-marking-lines.stts
                                        tt-marking-lines.sts-utd  = tt-gray-marking-lines.sts-utd
                                        tt-marking-lines.stts-utd = tt-gray-marking-lines.stts-utd
                                        .
                                end.
                            end.
                            empty temp-table tt-gray-marking-lines .
                            br-mark :refresh().
                            reposition br-mark to recid recid_mark no-error .
                            br-mark-item:refresh () no-error .
                            display f-qnty-unit with frame d-mark .
                        end.
                        else
                        do:
                            if buf_utd-marking-lines.doc-level > 1 then
                            do:
                                find first buf_marking no-lock where buf_marking.mark = buf_utd-marking-lines.mark no-error .
                                if available (buf_marking) then
                                do:
                                    find first ub.marking exclusive-lock where ub.marking.mark = buf_marking.mark-parent and ub.marking.sts <> Marking:GrayZone:KeyIntDB and ub.marking.sts <> Marking:Ungrouped:KeyIntDB no-error .
                                    if available (ub.marking) then
                                    do:
                                        message "Разгруппировать упаковки?"
                                            view-as alert-box question buttons yes-no update ungroup.
                                        if ungroup then
                                        do:
                                            if tree:UnGroupUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then
                                            do:
                                                message "Упаковка с маркой " + buf_utd-marking-lines.mark + " разгруппирована."
                                                    view-as alert-box.
                                            end.
                                            run ungroupTT in this-procedure (ub.marking.mark).
                                            find first X_marking-line where X_marking-line.mark = buf_marking.mark no-error .
                                            if available (X_marking-line) then
                                            do:
                                                X_marking-line.stts-utd = StatusTHName(Marking:Checked_:KeyIntDB) .
                                                X_marking-line.sts-utd = Marking:Checked_:KeyIntDB .
                                                buf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB .
                                            end.
                                            br-mark :refresh().
                                            OPEN QUERY br-mark-item for each X_marking-line no-lock where X_marking-line.mark-parent = vMarkBrow2   and if Status_ <> 0 then if Status_ = 7 then x_marking-line.sts-utd = Status_ else x_marking-line.sts-utd = 3 or X_marking-line.sts-utd = Status_ else x_marking-line.sts <> 99 INDEXED-REPOSITION.
                                            br-mark-item:refresh () no-error .
                                        end.
                                        else
                                        do:
                                            F-text = "                            Просканируйте марку" .
                                            display F-text with frame d-mark .
                                            v-mark:screen-value = "" .
                                            v-mark = "" .
                                            return no-apply.
                                        end.
                                    end.
                                    else
                                    do:
                                        if can-find (first ub.marking where ub.marking.mark = buf_marking.mark-parent and ub.marking.sts = Marking:GrayZone:KeyIntDB) then
                                        do:
                                            message " Марка входит в состав упаковки c серой зоной, разгруппировать упаковки?"
                                                view-as alert-box question buttons yes-no update ungroup.
                                            if ungroup then
                                            do:
                                                if tree:UnGroupUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then
                                                do:
                                                    message "Упаковка с маркой " + buf_utd-marking-lines.mark + " разгруппирована."
                                                        view-as alert-box.
                                                end.
                                            end.
                                            else
                                            do:
                                                F-text = "                            Просканируйте марку" .
                                                display F-text with frame d-mark .
                                                v-mark:screen-value = "" .
                                                v-mark = "" .
                                                return no-apply.
                                            end.
                                        end.
                                        else
                                        do:
                                            for first X_marking-line exclusive-lock where X_marking-line.mark begins v-marking:
                                                X_marking-line.sts-utd = Marking:Checked_:KeyIntDB .
                                                X_marking-line.stts-utd = StatusTHName(Marking:Checked_:KeyIntDB) .
                                            end.
                                            find first bf_utd-marking-lines exclusive-lock where bf_utd-marking-lines.mark = buf_utd-marking-lines.mark and bf_utd-marking-lines.db-num = buf_utd-marking-lines.db-num and
                                                bf_utd-marking-lines.doc-id = buf_utd-marking-lines.doc-id no-error .
                                            if available (bf_utd-marking-lines) then
                                            do:
                                                bf_utd-marking-lines.sts   = X_marking-line.sts-utd .
                                                run setCheckedStatusForParentMarks(X_marking-line.mark-parent, buf_utd-marking-lines.db-num, buf_utd-marking-lines.doc-id).
                                            end.
                                            OPEN QUERY br-mark-item for each X_marking-line no-lock where X_marking-line.mark-parent = vMarkBrow2   and if Status_ <> 0 then if Status_ = 7 then x_marking-line.sts-utd = Status_ else x_marking-line.sts-utd = 3 or X_marking-line.sts-utd = Status_ else x_marking-line.sts <> 99 INDEXED-REPOSITION.
                                            F-text = "                            Просканируйте марку" .
                                            display F-text with frame d-mark .
                                        end.
                                    end.
                                end.
                            end.
                            if tree:LevelDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then
                            do:
                                tree:StatusDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num, Marking:Checked_:KeyIntDB) .
                                for each X_marking-line exclusive-lock,
                                    first bf_utd-marking-lines no-lock where
                                          bf_utd-marking-lines.db-num = buf_utd-marking-lines.db-num
                                      and bf_utd-marking-lines.doc-id = buf_utd-marking-lines.doc-id
                                      and bf_utd-marking-lines.mark   = X_marking-line.mark
                                :
                                    X_marking-line.sts-utd = bf_utd-marking-lines.sts .
                                    X_marking-line.stts-utd = StatusTHName(X_marking-line.sts-utd) .
                                end.
                            end.
                            else do:
                              assign
                                buf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB
                              .
                            end.
                            for each X_marking-line exclusive-lock,
                                first bf_utd-marking-lines no-lock where
                                      bf_utd-marking-lines.db-num = buf_utd-marking-lines.db-num
                                  and bf_utd-marking-lines.doc-id = buf_utd-marking-lines.doc-id
                                  and bf_utd-marking-lines.mark   = X_marking-line.mark
                            :
                              X_marking-line.sts-utd = bf_utd-marking-lines.sts .
                              X_marking-line.stts-utd = StatusTHName(X_marking-line.sts-utd) .
                            end.
                            if tree:checkedAllMarksOfUpakUTD(X_marking.mark, buf_utd-marking-lines.db-num, buf_utd-marking-lines.doc-id)
                            then do:
                              assign
                                X_marking.sts-utd = Marking:Checked_:KeyIntDB .
                                X_marking.stts-utd = StatusTHName(Marking:Checked_:KeyIntDB)
                              .
                            end.
                            for first bf_utd-marking-lines exclusive-lock where bf_utd-marking-lines.mark = buf_utd-marking-lines.mark and
                                bf_utd-marking-lines.db-num = buf_utd-marking-lines.db-num and
                                bf_utd-marking-lines.doc-id = buf_utd-marking-lines.doc-id:
                                if bf_utd-marking-lines.doc-level = 1 then bf_utd-marking-lines.sts   = X_marking.sts-utd .
                            end.
                        end.
                        v-mark:screen-value = "" .
                        v-mark = "" .
                    end.
                end.
                br-mark :refresh().
                reposition br-mark to recid recid_mark no-error .
                br-mark-item:refresh () no-error .
            end.
            else
            do:
                find first X_marking-line exclusive-lock where X_marking-line.mark begins v-marking no-error .
                if available (X_marking-line) then
                do:
                    recid_mark = recid (X_marking-line) .
                    if X_marking-line.sts-utd = Marking:Checked_:KeyIntDB then
                    do:
                        F-text = "            Марка уже проверена, просканируйте следующую" .
                        display F-text with frame d-mark.
                        v-mark:screen-value = "" .
                        v-mark = "" .
                        return no-apply.
                    end.
                    else
                    do:
                        assign
                            X_marking-line.sts-utd  = Marking:Checked_:KeyIntDB
                            X_marking-line.stts-utd = StatusTHName(Marking:Checked_:KeyIntDB)
                            .
                        find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = X_marking-line.mark and buf_utd-marking-lines.db-num = X_marking-line.db-num and
                            buf_utd-marking-lines.doc-id = X_marking-line.doc-id no-error .
                        if available (buf_utd-marking-lines) then
                        do:
                            if buf_utd-marking-lines.doc-level > 1 then
                            do:
                                if tree:LevelUpUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then
                                do:
                                    message "Разгруппировать упаковки?"
                                        view-as alert-box question buttons yes-no update ungroup.
                                    if ungroup then
                                    do:
                                        if tree:UnGroupUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then
                                        do:
                                            message "Упаковка с маркой " + buf_utd-marking-lines.mark + " разгруппирована."
                                                view-as alert-box.
                                        end.
                                    end.
                                end.
                            end.
                            if tree:LevelDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then
                            do:
                                tree:StatusDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num, Marking:Checked_:KeyIntDB) .
                            end.
                            for first bf_utd-marking-lines exclusive-lock where bf_utd-marking-lines.mark = buf_utd-marking-lines.mark and bf_utd-marking-lines.db-num = buf_utd-marking-lines.db-num and
                                bf_utd-marking-lines.doc-id = buf_utd-marking-lines.doc-id:
                                bf_utd-marking-lines.sts   = X_marking-line.sts-utd .
                            end.
                        end.
                        v-mark:screen-value = "" .
                        v-mark = "" .
                    end.
                    br-mark-item :refresh().
                    reposition br-mark-item to recid recid_mark no-error .
                    v-mark:screen-value = "" .
                    v-mark = "" .
                end.
                else
                do:
                    f-text = "              Марка не найдена в документе" .
                    display F-text with frame d-mark.
                    v-mark = "" .
                    v-mark:screen-value = "" .
                    return no-apply .
                end.
            end.
        end.
    end.
    else
    do:
        find first X_marking no-lock where X_marking.mark begins v-marking and X_marking.doc-level = 1 no-error .
        if available (X_marking) then
        do:
            recid_mark = recid (X_marking) .
            reposition br-mark to recid recid_mark no-error .
        end.
        else
        do:
            find first X_marking-line exclusive-lock where X_marking-line.mark begins v-marking no-error .
            if available (X_marking-line) then
            do:
                recid_mark1 = recid (X_marking-line) .
                reposition br-mark-item to recid recid_mark1 no-error .
                if error-status:error then
                do:
                    f-text = "            Марка не отображена в браузере" .
                    display F-text with frame d-mark.
                end.
            end.
            else
            do:
                f-text = "              Марка не найдена в документе" .
                display F-text with frame d-mark.
            end.
        end.
    end.
    v-mark:screen-value = "" .
    v-mark = "" .
end.
PROCEDURE scan-bar-code :
    define variable v_list      as character no-undo .
    define variable ii          as integer   no-undo .
    define variable v-marking   as character no-undo .
    define variable recid_mark1 as integer   no-undo .
    define variable v-GTIN      as character no-undo .
    define variable v-gds-code  as integer   no-undo .
    define VARIABLE vRecKeyLine as character no-undo .
    define buffer gray_marking                for ub.marking .
    define buffer gray_unit-marking           for ub.marking .
    define buffer gray_utd-marking-lines      for ub.utd-marking-lines .
    define buffer gray_unit_utd-marking-lines for ub.utd-marking-lines .
    define buffer buf_utd-lines               for ub.utd-lines .
    define buffer buf_utd-marking-lines       for ub.utd-marking-lines .
    define buffer X_utd-lines                 for tt-utd-lines .
    define buffer buf_utd-err                 for ub.utd-err .
    define buffer un_utd-marking-lines        for ub.utd-marking-lines .
    f-text = "" .
    f-text:screen-value in frame d-mark = "" .
    ASSIGN
        v_list = 'Ё,Й,Ц,У,К,Е,Н,Г,Ш,Щ,З,Х,Ъ,Ф,Ы,В,А,П,Р,О,Л,Д,Ж,Э,Я,Ч,С,М,И,Т,Ь,Б,Ю':U .
    do ii = 1 to length (v-mark):
        if LOOKUP( SUBSTRING( v-mark, ii, 1 ), v_list )  > 1 then
        do:
            message "Не корректно считан штрих-код, перед считыванием переключите клавиатуру на английскую раскладку."
                view-as alert-box.
            v-mark:screen-value = "" .
            v-mark = "" .
            return .
        end.
    end.
       mMRCCode  = yes.
   v-marking = GetCodeIdent(v-mark) .
   mMRCCode = no.
   if v-marking <> "" and v-marking <> ? then
   do:
      v-mark = v-marking .
   end.
        find first X_marking no-lock where X_marking.mark begins v-mark and X_marking.doc-level = 1 no-error .
        if available (X_marking) then
        do:
            recid_mark = recid (X_marking) .
            reposition br-bar-code to recid recid_mark no-error .
        end.
        v-mark:screen-value = "" .
        v-mark = "" .
end.
PROCEDURE proc-any-key :
    if not v-manual
        then
        if v-scan-str = ""
            then etime(yes).
        else
            if etime > 700
                then v-scan-str = "".
    v-scan-str = v-scan-str + last-event:label.
end.
PROCEDURE checkPriPerem :
    define input  parameter iMark as character no-undo.
    define output parameter oMsg  as character no-undo.
    define buffer buf_trn-doc          for ub.trn-doc.
    define buffer buf_marking          for ub.marking.
    define buffer parent_marking       for ub.marking.
    define buffer buf_marking-lines    for ub.marking-lines.
    define buffer buf_tt-marking       for tt-marking-lines.
    find first X_marking exclusive-lock where X_marking.mark begins iMark no-error .
    if available (X_marking) then
    do:
        if X_marking.sts-utd = Marking:Checked_:KeyIntDB then
        do:
            if x_marking.unit-ext <> "UNIT" then
            do:
                oMsg = "               Упаковка уже проверена полностью".
                return.
            end.
            else
            do:
                oMsg = "            Марка уже проверена, просканируйте следующую".
                display F-text with frame d-mark.
                return.
            end.
        end.
        find first buf_marking exclusive-lock where
                   buf_marking.mark begins iMark
             no-error.
        if buf_marking.sts = Marking:Checked_:KeyIntDB or
           buf_marking.sts = Marking:SaleLock:KeyIntDB or
           buf_marking.sts = Marking:ReturnLock:KeyIntDB then
        do:
            oMsg = "Марка проверена ранее".
            return.
        end.
        if buf_marking.sts = Marking:FreeZone:KeyIntDB then
        do:
          for each buf_marking-lines no-lock where
                   buf_marking-lines.mark      = X_marking.mark
               and buf_marking-lines.obj-type  = X_marking.obj-type
               and buf_marking-lines.obj-code  = X_marking.obj-code
               and buf_marking-lines.gds-code  = X_marking.gds-code
               and buf_marking-lines.out-code  <> X_marking.out-code,
              first buf_trn-doc no-lock where
                    buf_trn-doc.doc-code = buf_marking-lines.out-code
                and buf_trn-doc.ext-doc-type = 'iv':U:
            oMsg = "Марка уже принята ранее по другому документу внутреннего прихода".
            return.
          end.
        end.
        find first buf_marking-lines exclusive-lock where
                   buf_marking-lines.mark      = X_marking.mark
               and buf_marking-lines.obj-type  = X_marking.obj-type
               and buf_marking-lines.obj-code  = X_marking.obj-code
               and buf_marking-lines.gds-code  = X_marking.gds-code
               and buf_marking-lines.out-code  = X_marking.out-code no-error .
        if buf_marking-lines.doc-level > 1 and
           avail buf_marking
        then do:
          for first parent_marking no-lock where
                    parent_marking.mark = buf_marking.mark-parent
                and parent_marking.sts <> Marking:GrayZone:KeyIntDB
                and parent_marking.sts <> Marking:Ungrouped:KeyIntDB
          :
            oMsg = "Марка входит в состав упаковки, просканируйте марку упаковки.".
            return.
          end.
        end.
        assign
          buf_marking.sts       = Marking:Checked_:KeyIntDB
          x_marking.sts         = buf_marking.sts
          x_marking.sts-utd     = buf_marking.sts
          buf_marking-lines.sts = buf_marking.sts
          X_marking.stts-utd    = marking:GetLabel(buf_marking.sts)
          X_marking.stts        = marking:GetLabel(buf_marking.sts)
        .
        run setStatusForChildMarks in this-procedure (buf_marking.mark, buf_marking.sts).
    end.
END.
PROCEDURE ungroupTT:
    define input parameter iMark as character no-undo.
    define buffer buf_tt-marking-lines for tt-marking-lines.
    for first buf_tt-marking-lines exclusive-lock where
              buf_tt-marking-lines.mark = iMark
    :
      buf_tt-marking-lines.stts = StatusTHName(Marking:Ungrouped:KeyIntDB) .
      buf_tt-marking-lines.stts-utd = StatusTHName(Marking:Ungrouped:KeyIntDB) .
      buf_tt-marking-lines.sts = Marking:Ungrouped:KeyIntDB .
      buf_tt-marking-lines.sts-utd = Marking:Ungrouped:KeyIntDB .
      run ungroupTT in this-procedure (buf_tt-marking-lines.mark-parent).
    end.
end.
PROCEDURE setCheckedStatusForParentMarks:
  define input parameter iMark  as character no-undo.
  define input parameter iDbNum as integer no-undo.
  define input parameter iDocId as integer no-undo.
  define buffer parent_utd-marking-lines for ub.utd-marking-lines.
  if iMark = "" then return.
  find first parent_utd-marking-lines exclusive-lock where
             parent_utd-marking-lines.db-num = iDbNum
         and parent_utd-marking-lines.doc-id = iDocId
         and parent_utd-marking-lines.mark = iMark no-error .
  if available (parent_utd-marking-lines) then
  do:
    find first tt-marking-lines where
               parent_utd-marking-lines.mark begins tt-marking-lines.mark-parent
           and tt-marking-lines.mark-parent <> ""
           and tt-marking-lines.sts-utd = Marking:PendingVerification:KeyIntDB no-error .
    if not available (tt-marking-lines) then
    do:
        if tree:checkedAllMarksOfUpakUTD(parent_utd-marking-lines.mark, iDbNum, iDocId)
        then do:
          parent_utd-marking-lines.sts = Marking:Checked_:KeyIntDB .
          find first X_marking where X_marking.mark = parent_utd-marking-lines.mark no-error .
          if available (X_marking) then
          do:
            X_marking.sts-utd = Marking:Checked_:KeyIntDB .
            X_marking.stts-utd = StatusTHName(Marking:Checked_:KeyIntDB) .
          end.
          run setCheckedStatusForParentMarks(X_marking.mark-parent, iDbNum, iDocId).
        end.
    end.
    else
    do:
        find first X_marking where X_marking.mark = parent_utd-marking-lines.mark no-error .
        if available (X_marking) then recid_mark = recid(X_marking) .
    end.
  end.
end.
PROCEDURE setStatusForChildMarks:
  define input parameter iMark  like ub.marking.mark no-undo.
  define input parameter iSts   like ub.marking.sts  no-undo.
  define buffer buf_marking-child    for ub.marking.
  define buffer buf_marking-lines    for ub.marking-lines.
  for each buf_marking-child where
           buf_marking-child.mark-parent = iMark
    exclusive-lock:
    find first buf_marking-lines exclusive-lock where
               buf_marking-lines.mark      = buf_marking-child.mark
           and buf_marking-lines.obj-type  = X_marking.obj-type
           and buf_marking-lines.obj-code  = X_marking.obj-code
           and buf_marking-lines.gds-code  = X_marking.gds-code
           and buf_marking-lines.out-code  = X_marking.out-code no-error .
    find first X_marking-line exclusive-lock where X_marking-line.mark begins buf_marking-child.mark no-error .
    assign
      X_marking-line.sts      = iSts
      X_marking-line.sts-utd  = iSts
      X_marking-line.stts-utd = marking:GetLabel(iSts)
      X_marking-line.stts     = marking:GetLabel(iSts)
      buf_marking-lines.sts   = iSts
      buf_marking-child.sts   = iSts
    .
    run setStatusForChildMarks in this-procedure (buf_marking-child.mark, iSts).
  end.
end.
