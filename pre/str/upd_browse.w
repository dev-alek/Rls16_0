using ibs.th.gbl.sys.objsrv.
using ibs.th.str.marking.sts.*.
using ibs.th.str.marking.handlers.*.
using ibs.th.str.utd.sts.*.
using ibs.th.bge.is_motp.*.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-doc-id as integer no-undo .
define input parameter p-db-num as integer   no-undo .
define input parameter p-type   as integer  no-undo .
define input parameter p-mode as character no-undo .
define input parameter p-connect as com-handle no-undo .
define variable p-host-code     as integer   no-undo .
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
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info9 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info9, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info9, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info9, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info9, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info9 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info9, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info9 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info9, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info9, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info9, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info9, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info9, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info9, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info9 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info9 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info9, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info9, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info9, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info9 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info9 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info9, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info9, v-inform, v-tbl-name ).
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
define variable mDebug as logical no-undo.
mDebug = session:debug-alert.
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
def var vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info16 as character format "X(65)" no-undo
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
def var vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-utd-mark no-undo like utd-marking-lines
  field side as character.
def var vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable log-res-statch as log       no-undo.
define variable rr             as recid     no-undo.
define variable v_type         as char      no-undo.
define variable v-is-deploy    as logical   no-undo .
define variable v-rid-list     as character no-undo .
define variable v-db-list      as character no-undo .
define variable v-comment      as character no-undo .
define variable gds-rec        as integer   no-undo .
define variable recid_utd      as integer   no-undo .
define variable v-GTIN         as character no-undo .
define variable m-gds-code     as character no-undo label "Товар" view-as fill-in.
define variable type_mark      as integer   no-undo .
define variable iLang          as integer   no-undo .
define variable p-value-logical as logical no-undo.
define variable p-value-character  as character no-undo.
define variable p-value-date       as date no-undo.
define variable p-value-decimal    as decimal no-undo.
define variable p-value-integer    as integer no-undo.
define variable p-param-type       as character no-undo.
define variable v-tth as handle no-undo .
define variable log-edi-doc_update as logical no-undo .
define variable Tree           as class     tree no-undo .
define variable ungroup        as logical   no-undo .
define variable line-num-error as integer   no-undo .
define variable v-pred-status  as integer   no-undo .
define variable v-obj-active   as logical   no-undo .
define variable mRecKey-line   as character no-undo.
define buffer buf_clients           for ub.clients .
define buffer X_utd-lines           for tt-utd-lines .
define buffer buf_utd               for ub.utd .
define buffer buf_utd-attr          for ub.utd-attr .
define buffer buf_utd-lines         for ub.utd-lines .
define buffer bf_utd-lines          for ub.utd-lines .
define buffer buf_contract          for ub.contract .
define buffer buf_utd-marking-lines for ub.utd-marking-lines .
define buffer bf_utd-marking-lines  for ub.utd-marking-lines .
define buffer buf_goods             for ub.goods .
define buffer buf_marking           for ub.marking .
define buffer buf_utd-err           for ub.utd-err .
define variable v-scan-str  as character no-undo .
define variable v-manual    as logical   no-undo .
define variable v-barcode   as logical   no-undo .
DEFINE VARIABLE v-timedelay as integer   no-undo .
define variable mflagscan   as logical   no-undo.
define variable mMarkUtdLine as logical   no-undo.
define variable mOrderItem  as character   no-undo.
FUNCTION CliName RETURNS CHARACTER
   (input p-cli-code as integer, input p-cli-type as character)  FORWARD.
FUNCTION ContName RETURNS CHARACTER
   ( input p-contract-code as integer, input p-host-code as integer )  FORWARD.
FUNCTION GdsName RETURNS CHARACTER
   ( input p-gds-code as integer)  FORWARD.
FUNCTION GdsUnit RETURNS CHARACTER
   ( input p-gds-code as integer)  FORWARD.
FUNCTION StatusName RETURNS CHARACTER
   ( input p-doc-id as integer,
   input p-db-num as integer)  FORWARD.
FUNCTION ChkAnotherUtd RETURNS LOGICAL
   ( input p-doc-id as integer,
     input p-db-num as integer,
     input p-mark as character)  FORWARD.
DEFINE MENU m_error
   MENU-ITEM m_error-utd    LABEL "Ошибки по документу"
   MENU-ITEM m_error-lines  LABEL "Ошибки по строке".
DEFINE MENU m_marks
   MENU-ITEM m_marks-utd    LABEL "Марки по документу"
   MENU-ITEM m_marks-lines  LABEL "Марки по строке".
DEFINE MENU POPUP-MENU-b-servis
   MENU-ITEM m_choose-status LABEL "Сменить статус документа"
   MENU-ITEM m_check-akt    LABEL "Проверить по Акту приема-передачи"
   MENU-ITEM m_reset_row_data LABEL "Сбросить данные по строке"
   .
DEFINE BUTTON b-cancel AUTO-END-KEY
   LABEL "&Отмена":L
   SIZE 15 BY 1.
DEFINE BUTTON b-exit AUTO-GO
   LABEL "&Выход ":L
   SIZE 15 BY 1.
DEFINE BUTTON b-save AUTO-GO
   LABEL "&Ввод ":L
   SIZE 15 BY 1.
DEFINE BUTTON b-order
   LABEL "Заказ"
   SIZE 20 BY 1.
DEFINE BUTTON b-servis
   LABEL "Сервис"
   SIZE 15 BY 1.
DEFINE BUTTON b_anul
   LABEL "Аннулировать"
   SIZE 36 BY 1.25.
DEFINE BUTTON b_back-check
   LABEL "Продолжить проверку"
   SIZE 36 BY 1.25.
DEFINE BUTTON b_correct
   LABEL "Запрос на изменение"
   SIZE 36 BY 1.25.
DEFINE BUTTON b_deliv-cancel
   LABEL "Отказать в поставке"
   SIZE 36 BY 1.25.
DEFINE BUTTON b_error
   LABEL "Ошибки/проблемы"
   SIZE 16 BY 1.
DEFINE BUTTON b_finish
   LABEL "Ввод в оборот"
   SIZE 36 BY 1.25.
DEFINE BUTTON B_mark
   LABEL "Марки/Штрих-коды"
   SIZE 17 BY 1.
DEFINE BUTTON b_prov-finish
   LABEL "Проверка завершена"
   SIZE 36 BY 1.25.
DEFINE BUTTON b_recheck
   LABEL "Повторно проверить"
   SIZE 36 BY 1.25.
DEFINE BUTTON b_write-cancel
   LABEL "Отказать в подписи"
   SIZE 36 BY 1.25.
DEFINE BUTTON b_cleaggds
   LABEL "Сброс фильтра"
   SIZE 15 BY 1.
DEFINE BUTTON r-agnt
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "r-acc"
   SIZE 3 BY 1.
DEFINE BUTTON r-boss
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "r-acc"
   SIZE 3 BY 1.
DEFINE BUTTON r-contr-TH
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL ""
   SIZE 3 BY 1.
DEFINE BUTTON r-obj-TH
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL ""
   SIZE 3 BY 1.
DEFINE BUTTON r-supp-TH
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL ""
   SIZE 3 BY 1.
DEFINE BUTTON r-wrkr
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "r-acc"
   SIZE 3 BY 1.
DEFINE VARIABLE c-status        AS INTEGER   FORMAT "-999":U INITIAL 0
   VIEW-AS COMBO-BOX INNER-LINES 5
   LIST-ITEM-PAIRS "Все",0,
   "Получен от поставщика",2,
   "Требует корректировки",3,
   "Ожидает поставки",4,
   "Требует подписания",5
   DROP-DOWN-LIST
   SIZE 55.5 BY 1 NO-UNDO.
DEFINE VARIABLE c-status-edi    AS INTEGER   FORMAT "-999":U INITIAL 352
   VIEW-AS COMBO-BOX INNER-LINES 5
   LIST-ITEM-PAIRS "Все",0,
   "Получен от поставщика",2,
   "Требует корректировки",3,
   "Ожидает поставки",4,
   "Требует подписания",5
   DROP-DOWN-LIST
   SIZE 58.5 BY 1 NO-UNDO.
DEFINE VARIABLE c-type          AS INTEGER   FORMAT "-999":U INITIAL 0
   LABEL "Тип"
   VIEW-AS COMBO-BOX INNER-LINES 5
   LIST-ITEM-PAIRS "Все",0,
   "Получен от поставщика",2,
   "Требует корректировки",3,
   "Ожидает поставки",4,
   "Требует подписания",5
   DROP-DOWN-LIST
   SIZE 42 BY 1 NO-UNDO.
DEFINE VARIABLE f-comment       AS CHARACTER
   VIEW-AS EDITOR SCROLLBAR-VERTICAL
   SIZE 100 BY 1.46 NO-UNDO.
DEFINE VARIABLE f-info          AS CHARACTER
   VIEW-AS EDITOR SCROLLBAR-VERTICAL
   SIZE 100 BY 1.96 NO-UNDO.
DEFINE VARIABLE f-obj-name-2    AS CHARACTER
   VIEW-AS EDITOR SCROLLBAR-VERTICAL
   SIZE 70.5 BY 2.17 NO-UNDO.
DEFINE VARIABLE a-n-c-name      AS CHARACTER FORMAT "X(256)":U
   VIEW-AS FILL-IN
   SIZE 45 BY 1
   FGCOLOR 12 NO-UNDO.
DEFINE VARIABLE agnt-name       AS CHARACTER FORMAT "x(256)":U
   VIEW-AS TEXT
   SIZE 11 BY 1
   BGCOLOR 15 NO-UNDO.
DEFINE VARIABLE boss-name       AS CHARACTER FORMAT "x(256)":U
   VIEW-AS TEXT
   SIZE 11 BY 1
   BGCOLOR 15 NO-UNDO.
DEFINE VARIABLE f-agnt          AS INTEGER   FORMAT ">>>>>>>>>>>9":U INITIAL 0
   VIEW-AS FILL-IN
   SIZE 11.25 BY 1
   BGCOLOR 15 NO-UNDO.
DEFINE VARIABLE f-agnt-name     AS CHARACTER FORMAT "X(256)":U INITIAL "Исп:"
   VIEW-AS FILL-IN
   SIZE 4.88 BY 1 NO-UNDO.
DEFINE VARIABLE f-boss          AS INTEGER   FORMAT ">>>>>>>>>>>9":U INITIAL 0
   VIEW-AS FILL-IN
   SIZE 11.25 BY 1
   BGCOLOR 15 NO-UNDO.
DEFINE VARIABLE f-boss-name     AS CHARACTER FORMAT "X(256)":U INITIAL "М-р:"
   VIEW-AS FILL-IN
   SIZE 4.88 BY 1 NO-UNDO.
DEFINE VARIABLE f-comment-name  AS CHARACTER FORMAT "X(256)":U INITIAL "Комментарий:"
   VIEW-AS FILL-IN
   SIZE 12.88 BY 1 NO-UNDO.
DEFINE VARIABLE f-contr-name    AS CHARACTER FORMAT "X(150)"
   VIEW-AS FILL-IN
   SIZE 35.25 BY 1.
DEFINE VARIABLE f-contr-name-TH AS CHARACTER FORMAT "X(100)"
   VIEW-AS FILL-IN
   SIZE 48.5 BY 1.
DEFINE VARIABLE f-contr-TH      AS INTEGER   FORMAT ">>>>>>>>>>>>>>>>>>>>>>9" INITIAL 0
   VIEW-AS FILL-IN
   SIZE 19.5 BY 1.
DEFINE VARIABLE f-date          AS DATE      FORMAT "99/99/9999":U
   VIEW-AS FILL-IN
   SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-2        AS DATE      FORMAT "99/99/9999":U
   VIEW-AS FILL-IN
   SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-name     AS CHARACTER FORMAT "X(256)":U INITIAL "Дата:"
   VIEW-AS FILL-IN
   SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-name-2   AS CHARACTER FORMAT "X(256)":U INITIAL "Дата:"
   VIEW-AS FILL-IN
   SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE f-gruz          AS CHARACTER FORMAT "X(256)":U INITIAL "Грузополучатель:"
   VIEW-AS FILL-IN
   SIZE 17.38 BY .92 NO-UNDO.
DEFINE VARIABLE f-info-name     AS CHARACTER FORMAT "X(256)":U INITIAL "Доп.инфо:"
   VIEW-AS FILL-IN
   SIZE 9.88 BY 1 NO-UNDO.
DEFINE VARIABLE f-mark          AS CHARACTER FORMAT "X(256)":U INITIAL "Марка:"
   VIEW-AS FILL-IN
   SIZE 6.75 BY 1 NO-UNDO.
DEFINE VARIABLE f-num           AS CHARACTER FORMAT "X(256)":U
   VIEW-AS FILL-IN
   SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-num-2         AS CHARACTER FORMAT "X(256)":U
   LABEL "№"
   VIEW-AS FILL-IN
   SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-num-name      AS CHARACTER FORMAT "X(256)":U INITIAL "№ документа:"
   VIEW-AS FILL-IN
   SIZE 12.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-num-name-2    AS CHARACTER FORMAT "X(256)":U INITIAL "№:"
   VIEW-AS FILL-IN
   SIZE 3.25 BY 1 NO-UNDO.
DEFINE VARIABLE f-obj-code-TH   AS INTEGER   FORMAT ">>>>>>>>>>9" INITIAL 0
   VIEW-AS FILL-IN
   SIZE 14.75 BY 1.
DEFINE VARIABLE f-obj-name      AS CHARACTER FORMAT "X(256)":U INITIAL "Объект:"
   VIEW-AS FILL-IN
   SIZE 14 BY .75 NO-UNDO.
DEFINE VARIABLE f-obj-name-TH   AS CHARACTER FORMAT "X(100)"
   VIEW-AS FILL-IN
   SIZE 48.5 BY 1.
DEFINE VARIABLE f-obj-type-TH   AS CHARACTER FORMAT "X(3)"
   VIEW-AS FILL-IN
   SIZE 4.13 BY 1.
DEFINE VARIABLE f-status-EDI    AS CHARACTER FORMAT "X(256)":U INITIAL "Статус EDI:"
   VIEW-AS FILL-IN
   SIZE 11.75 BY 1 NO-UNDO.
DEFINE VARIABLE f-status-TH     AS CHARACTER FORMAT "X(256)":U INITIAL "Статус ТН:"
   VIEW-AS FILL-IN
   SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE f-supp-code-TH  AS INTEGER   FORMAT ">>>>>>>>>>9" INITIAL 0
   VIEW-AS FILL-IN
   SIZE 14.75 BY 1.
DEFINE VARIABLE f-supp-name-TH  AS CHARACTER FORMAT "X(100)"
   VIEW-AS FILL-IN
   SIZE 48.5 BY 1.
DEFINE VARIABLE f-supp-type-TH  AS CHARACTER FORMAT "X(3)"
   VIEW-AS FILL-IN
   SIZE 4.13 BY 1.
DEFINE VARIABLE F-text          AS CHARACTER FORMAT "X(256)":U
   VIEW-AS FILL-IN
   SIZE 148 BY 1.25
   FGCOLOR 12 NO-UNDO.
DEFINE VARIABLE f-total         AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99":U INITIAL 0
   LABEL "Общая сумма"
   VIEW-AS FILL-IN
   SIZE 16.75 BY 1 NO-UNDO.
DEFINE VARIABLE f-vat           AS DECIMAL   FORMAT "->>,>>9.99":U INITIAL 0
   LABEL "Сумма НДС"
   VIEW-AS FILL-IN
   SIZE 16.75 BY 1 NO-UNDO.
DEFINE VARIABLE f-wrkr          AS INTEGER   FORMAT ">>>>>>>>>>>9":U INITIAL 0
   VIEW-AS FILL-IN
   SIZE 11.25 BY 1
   BGCOLOR 15 NO-UNDO.
DEFINE VARIABLE f-wrkr-name     AS CHARACTER FORMAT "X(256)":U INITIAL "Кл-к:"
   VIEW-AS FILL-IN
   SIZE 5.88 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-1       AS CHARACTER FORMAT "X(256)":U INITIAL "Поставщик:"
   VIEW-AS FILL-IN
   SIZE 14 BY .75 NO-UNDO.
DEFINE VARIABLE FILL-IN-2       AS CHARACTER FORMAT "X(256)":U INITIAL "Договор:"
   VIEW-AS FILL-IN
   SIZE 14 BY .75 NO-UNDO.
DEFINE VARIABLE FILL-IN-3       AS CHARACTER FORMAT "X(256)":U INITIAL "Договор:"
   VIEW-AS FILL-IN
   SIZE 14 BY .75 NO-UNDO.
DEFINE VARIABLE v-mark          AS CHARACTER FORMAT "X(255)"
   VIEW-AS FILL-IN
   SIZE 100 BY 1.
DEFINE VARIABLE wrkr-name       AS CHARACTER FORMAT "x(256)":U
   VIEW-AS TEXT
   SIZE 11 BY 1
   BGCOLOR 15 NO-UNDO.
DEFINE VARIABLE a-n-c           AS CHARACTER
   VIEW-AS RADIO-SET HORIZONTAL
   RADIO-BUTTONS
   "Код", "code",
   "Нач.назв", "name",
   "Нач.слова", "context"
   SIZE 37.63 BY 1 NO-UNDO.
DEFINE VARIABLE R-error         AS INTEGER
   VIEW-AS RADIO-SET HORIZONTAL
   RADIO-BUTTONS
   "Все", 1,
   "Не проверено", 2
   SIZE 25.38 BY 1 NO-UNDO.
DEFINE VARIABLE R-error-2       AS INTEGER
   VIEW-AS RADIO-SET HORIZONTAL
   RADIO-BUTTONS
   "Все", 1,
   "Ошибки", 2
   SIZE 25.38 BY 1 NO-UNDO.
DEFINE RECTANGLE R-TH
   EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
   SIZE 73.5 BY 6.75 TOOLTIP "Данные ТН".
DEFINE RECTANGLE RECT-1
   EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
   SIZE 147.5 BY 3.25.
define variable mgdsUnit as character no-undo.
define variable much as character no-undo.
DEFINE QUERY br-utd FOR
   X_utd-lines, tt-utd-lines-filtr SCROLLING.
DEFINE QUERY br-utd-nomark FOR
   X_utd-lines SCROLLING.
def var Marking as class mark no-undo .
FUNCTION StatusTHName RETURNS CHARACTER
   (input p-stsTH as integer)  .
   Return Marking:GetLabel(p-stsTH) .
END FUNCTION .
FUNCTION EdoTypeName RETURNS CHARACTER
   (input p-stsTH as integer)  .
   Return ObjSrv:Env:Utd:EDocType:GetLabel(p-stsTH) .
END FUNCTION .
DEFINE BROWSE br-utd
   QUERY br-utd NO-LOCK DISPLAY
   X_utd-lines.LineNum COLUMN-LABEL "№ п/п" FORMAT ">>>9":U
   X_utd-lines.gds-code COLUMN-LABEL "Код товара" FORMAT ">>>>999999":U
   X_utd-lines.ProductCode COLUMN-LABEL "Наименование!УПД" FORMAT "x(40)":U width 25
   X_utd-lines.gds-name COLUMN-LABEL "Наименование ТН" FORMAT "x(112)":U width 25
   X_utd-lines.Quantity COLUMN-LABEL "Кол-во в ед.!изм TH по!УПД" FORMAT "->>,>>9.999":U
   X_utd-lines.qnty-scan COLUMN-LABEL "Факт!кол-во" FORMAT "->>>>>>>>>9.999":U
   gdsunit (X_utd-lines.gds-code) @ mgdsunit COLUMN-LABEL "Ед.изм!TH" FORMAT "x(6)":U
   if X_utd-lines.IsMarking and X_utd-lines.isWeight
   then "вп"
   else if X_utd-lines.IsArtic and X_utd-lines.isWeight
   then "во"
   else if X_utd-lines.IsMarking
   then "п"
   else if X_utd-lines.IsArtic
   then "о"
   else "-" @
    much COLUMN-LABEL "У" FORMAT "X(2)":U
   X_utd-lines.stts COLUMN-LABEL "Статус" FORMAT "x(20)":U WIDTH 18.13
   X_utd-lines.Price COLUMN-LABEL "Цена!(без НДC)" FORMAT "->>>>>>>>>>99.99":U width 10
   X_utd-lines.Total COLUMN-LABEL "Сумма!(с НДС)" FORMAT "->>>>>>>>>>>>>>99.99":U width 10
   X_utd-lines.TaxRate_ COLUMN-LABEL "Ставка!НДС" FORMAT "X(7)":U
   X_utd-lines.UnitCliQnty COLUMN-LABEL "Кол-во в!ед.изм постав-ка" FORMAT "->>>>>9":U
X_utd-lines.UnitCode COLUMN-LABEL "Ед.изм!постав-ка" FORMAT "x(5)":U
   X_utd-lines.PieceTTH COLUMN-LABEL "Штуки ТТН" FORMAT "x(10)":U
   X_utd-lines.PieceFact COLUMN-LABEL "Штуки факт" FORMAT "x(10)":U
ENABLE
      X_utd-lines.qnty-scan
    WITH NO-ROW-MARKERS SEPARATORS SIZE 147.5 BY 10.88 FIT-LAST-COLUMN.
DEFINE FRAME d-utd
   b-cancel AT ROW 1 COL 2
   b-exit AT ROW 1 COL 2
   b-save AT ROW 1 COL 17
   b-order AT ROW 1 COL 79.88 WIDGET-ID 288
   b-servis AT ROW 1 COL 99.88 WIDGET-ID 288
   b_error AT ROW 1 COL 114.88 WIDGET-ID 282
   B_mark AT ROW 1 COL 146.88 RIGHT-ALIGNED WIDGET-ID 80
   c-type AT ROW 2.25 COL 5.13 COLON-ALIGNED WIDGET-ID 240
   f-num-name AT ROW 2.25 COL 53.75 NO-LABEL WIDGET-ID 328
   f-num AT ROW 2.25 COL 64.5 COLON-ALIGNED NO-LABEL WIDGET-ID 284
   f-date-name AT ROW 2.25 COL 81.13 NO-LABEL WIDGET-ID 330
   f-date AT ROW 2.25 COL 85.25 COLON-ALIGNED NO-LABEL WIDGET-ID 286
   f-num-name-2 AT ROW 2.25 COL 110.5 NO-LABEL WIDGET-ID 334
   f-num-2 AT ROW 2.25 COL 112 COLON-ALIGNED NO-LABEL WIDGET-ID 314
   f-date-name-2 AT ROW 2.25 COL 128.63 NO-LABEL WIDGET-ID 332
   f-date-2 AT ROW 2.25 COL 132.75 COLON-ALIGNED NO-LABEL WIDGET-ID 312
   f-obj-name AT ROW 4.38 COL 2.5 NO-LABEL WIDGET-ID 326
   f-obj-type-TH AT ROW 5.21 COL 5.88 RIGHT-ALIGNED NO-LABEL WIDGET-ID 102
   f-obj-code-TH AT ROW 5.21 COL 21.25 RIGHT-ALIGNED NO-LABEL WIDGET-ID 98
   r-obj-TH AT ROW 5.21 COL 22.5 WIDGET-ID 104
   f-obj-name-TH AT ROW 5.21 COL 73.25 RIGHT-ALIGNED NO-LABEL WIDGET-ID 100
   f-gruz AT ROW 5.25 COL 77.13 NO-LABEL WIDGET-ID 310
   f-obj-name-2 AT ROW 6.17 COL 77.25 NO-LABEL WIDGET-ID 270
   FILL-IN-1 AT ROW 6.5 COL 2.5 NO-LABEL WIDGET-ID 242
   f-supp-type-TH AT ROW 7.29 COL 5.88 RIGHT-ALIGNED NO-LABEL WIDGET-ID 96
   f-supp-code-TH AT ROW 7.29 COL 21.25 RIGHT-ALIGNED NO-LABEL WIDGET-ID 86
   r-supp-TH AT ROW 7.29 COL 22.5 WIDGET-ID 92
   f-supp-name-TH AT ROW 7.29 COL 73.25 RIGHT-ALIGNED NO-LABEL WIDGET-ID 88
   f-total AT ROW 8.42 COL 129 COLON-ALIGNED WIDGET-ID 320
   FILL-IN-2 AT ROW 8.5 COL 2.5 NO-LABEL WIDGET-ID 244
   FILL-IN-3 AT ROW 8.5 COL 77.13 NO-LABEL WIDGET-ID 248
   f-contr-TH AT ROW 9.29 COL 21.25 RIGHT-ALIGNED NO-LABEL WIDGET-ID 106
   r-contr-TH AT ROW 9.29 COL 22.5 WIDGET-ID 110
   f-contr-name-TH AT ROW 9.29 COL 73.25 RIGHT-ALIGNED NO-LABEL WIDGET-ID 212
   f-contr-name AT ROW 9.29 COL 77.25 NO-LABEL WIDGET-ID 214
   f-vat AT ROW 9.5 COL 129 COLON-ALIGNED WIDGET-ID 322
   f-status-TH AT ROW 11.17 COL 5.88 NO-LABEL WIDGET-ID 336
   c-status AT ROW 11.17 COL 15 COLON-ALIGNED NO-LABEL WIDGET-ID 238
   f-status-EDI AT ROW 11.17 COL 77.63 NO-LABEL WIDGET-ID 338
   c-status-edi AT ROW 11.17 COL 87.5 COLON-ALIGNED NO-LABEL WIDGET-ID 234
   f-comment AT ROW 12.25 COL 17 NO-LABEL WIDGET-ID 266
   f-wrkr-name AT ROW 12.25 COL 117.25 NO-LABEL WIDGET-ID 346
   f-wrkr AT ROW 12.25 COL 121.25 COLON-ALIGNED NO-LABEL WIDGET-ID 304
   r-wrkr AT ROW 12.25 COL 145.5 WIDGET-ID 302
   f-comment-name AT ROW 12.42 COL 4 NO-LABEL WIDGET-ID 340
   f-agnt-name AT ROW 13.46 COL 118.25 NO-LABEL WIDGET-ID 348
   f-agnt AT ROW 13.46 COL 121.25 COLON-ALIGNED NO-LABEL WIDGET-ID 290
   r-agnt AT ROW 13.46 COL 145.5 WIDGET-ID 298
   f-info AT ROW 13.71 COL 17 NO-LABEL WIDGET-ID 268
   f-info-name AT ROW 14.04 COL 7 NO-LABEL WIDGET-ID 342
   f-boss-name AT ROW 14.67 COL 118.25 NO-LABEL WIDGET-ID 350
   f-boss AT ROW 14.67 COL 121.25 COLON-ALIGNED NO-LABEL WIDGET-ID 294
   r-boss AT ROW 14.67 COL 145.5 WIDGET-ID 300
   WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
   SIDE-LABELS THREE-D  SCROLLABLE .
DEFINE FRAME d-utd
   f-mark AT ROW 15.67 COL 10 NO-LABEL WIDGET-ID 344
   v-mark AT ROW 15.67 COL 15 COLON-ALIGNED NO-LABEL WIDGET-ID 34
   a-n-c AT ROW 16.71 COL 2.38 NO-LABEL WIDGET-ID 272
   a-n-c-name AT ROW 16.75 COL 39.5 COLON-ALIGNED NO-LABEL WIDGET-ID 278
   R-error AT ROW 16.79 COL 124.63 NO-LABEL WIDGET-ID 316
   R-error-2 AT ROW 16.79 COL 124.63 NO-LABEL WIDGET-ID 316
   br-utd AT ROW 17.83 COL 2.5 WIDGET-ID 100
   F-text AT ROW 28.75 COL 2.5 NO-LABEL WIDGET-ID 224
   b_prov-finish AT ROW 30.5 COL 2.75 WIDGET-ID 70
   b_recheck AT ROW 30.5 COL 39.5 WIDGET-ID 228
   b_correct AT ROW 30.5 COL 76.13 WIDGET-ID 230
   b_anul AT ROW 30.5 COL 112.75 WIDGET-ID 324
   b_back-check AT ROW 31.88 COL 2.75 WIDGET-ID 236
   b_finish AT ROW 31.88 COL 39.5 WIDGET-ID 252
   b_write-cancel AT ROW 31.88 COL 76.13 WIDGET-ID 232
   b_deliv-cancel AT ROW 31.88 COL 112.75 WIDGET-ID 230
   wrkr-name AT ROW 12.25 COL 132.88 COLON-ALIGNED NO-LABEL WIDGET-ID 306
   agnt-name AT ROW 13.46 COL 132.88 COLON-ALIGNED NO-LABEL WIDGET-ID 292
   boss-name AT ROW 14.67 COL 132.88 COLON-ALIGNED NO-LABEL WIDGET-ID 296
   "Доп.инфо:" VIEW-AS TEXT
   SIZE 9.5 BY .67 AT ROW 14.17 COL 7 WIDGET-ID 264
   m-gds-code  AT ROW 16.7 COL 87
   b_cleaggds AT ROW 16.7 COL 105
   "Объект:" VIEW-AS TEXT
   SIZE 8 BY .67 AT ROW 4.42 COL 3 WIDGET-ID 182
   "Данные ТН:" VIEW-AS TEXT
   SIZE 11 BY .67 AT ROW 3.75 COL 32.63 WIDGET-ID 180
   RECT-1 AT ROW 30.25 COL 2 WIDGET-ID 64
   R-TH AT ROW 4 COL 2 WIDGET-ID 112
   SPACE(74.51) SKIP(23.07)
   WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
   SIDE-LABELS THREE-D  SCROLLABLE
   TITLE "Проверка кодов маркировки":L.
ASSIGN
   FRAME d-utd:SCROLLABLE = FALSE
   br-utd:num-locked-columns in frame d-utd = 3
   .
ASSIGN
   b-servis:POPUP-MENU IN FRAME d-utd = MENU POPUP-MENU-b-servis:HANDLE.
ASSIGN
   b-servis:MENU-MOUSE = 1.
ASSIGN
   br-utd:COLUMN-RESIZABLE IN FRAME d-utd = TRUE.
ASSIGN
   b_error:POPUP-MENU IN FRAME d-utd = MENU m_error:HANDLE.
ASSIGN
   b_error:MENU-MOUSE = 1.
ASSIGN
   B_mark:POPUP-MENU IN FRAME d-utd = MENU m_marks:HANDLE.
ASSIGN
   b_mark:MENU-MOUSE = 1.
ASSIGN
   f-comment:READ-ONLY IN FRAME d-utd = TRUE.
ASSIGN
   f-info:READ-ONLY IN FRAME d-utd = TRUE.
ASSIGN
   f-mark:HIDDEN IN FRAME d-utd = TRUE.
ASSIGN
   f-obj-name-2:READ-ONLY IN FRAME d-utd = TRUE.
ASSIGN
   v-mark:HIDDEN IN FRAME d-utd = TRUE.
ON VALUE-CHANGED OF a-n-c IN FRAME d-utd
   DO:
      assign a-n-c .
      apply "TAB":U to self .
      return no-apply .
   END.
ON leave, return OF a-n-c-name IN FRAME d-utd
   DO:
      assign a-n-c-name .
      assign a-n-c .
      case a-n-c:
         when "code" then
            do:
               find first X_utd-lines where X_utd-lines.gds-code = integer(a-n-c-name) no-error .
               if available (X_utd-lines) then
               do:
                  recid_utd = recid (X_utd-lines) .
                  br-utd :refresh() no-error.
                  reposition br-utd to recid recid_utd no-error .
               end.
            end.
         when "name" then
            do:
               find first X_utd-lines where (X_utd-lines.ProductCode begins a-n-c-name or X_utd-lines.gds-name begins a-n-c-name) no-error .
               if available (X_utd-lines) then
               do:
                  recid_utd = recid (X_utd-lines) .
                  br-utd :refresh() no-error.
                  reposition br-utd to recid recid_utd no-error .
               end.
            end.
         when "context" then
            do:
               find first X_utd-lines where (X_utd-lines.ProductCode MATCHES "*" + a-n-c-name + "*" or X_utd-lines.gds-name MATCHES "*" + a-n-c-name + "*") no-error .
               if available (X_utd-lines) then
               do:
                  recid_utd = recid (X_utd-lines) .
                  br-utd :refresh() no-error.
                  reposition br-utd to recid recid_utd no-error .
               end.
            end.
      end case.
      apply "TAB":U to self .
      return no-apply .
   END.
ON CHOOSE OF b-order IN FRAME d-utd
DO:
    define buffer buf_order-doc for ub.order-doc.
    find first buf_order-doc where
               buf_order-doc.order-item = mOrderItem
         no-lock no-error.
    if available (buf_order-doc) then
    do:
       run str/order-doc.w (input parparentproc,
                            input buf_order-doc.doc-code,
                            input 'ПРОСМОТР':U
                           )  .
    end.
    else
    do:
        message "Заказ не найден."
            view-as alert-box.
        return no-apply .
    end.
END.
ON choose OF b-cancel IN FRAME d-utd
   DO:
      if p-mode = 'ДОБАВЛЕНИЕ':U and available (buf_utd) then
      do:
         delete buf_utd .
      end.
   END.
ON choose OF b-exit IN FRAME d-utd
   DO:
   END.
ON choose OF b-save IN FRAME d-utd
   DO:
      define variable v-ok as logical no-undo .
      if p-mode <> 'ПРОСМОТР':U and type_mark = 1 then
      do:
         run save_mol.
      end .
      if p-mode <> 'ПРОСМОТР':U then
      do:
         if f-obj-type-th = "" then
         do:
            message "Не выбран объект"
               view-as alert-box.
            return no-apply .
         end.
         if c-type = 0 then
         do:
            message "Не выбран тип документа"
               view-as alert-box.
            return no-apply .
         end.
         if available (buf_utd) then
         do:
            assign
               buf_utd.obj-code = f-obj-code-TH
               buf_utd.obj-type = f-obj-type-TH
               .
         end.
         if f-contr-TH <> 0 and f-contr-TH <> ? then
         do:
            assign
               buf_utd.contract-code = f-contr-TH
               .
         end.
         else
         do:
            if c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
            then
            do:
               message "Не заполнен номер договора"
                  view-as alert-box.
               return no-apply .
            end.
         end.
         if f-obj-code-TH <> 0 and f-obj-code-TH <> ? then
         do:
            assign
               buf_utd.obj-code = f-obj-code-TH
               buf_utd.obj-type = f-obj-type-TH
               .
         end.
         else
         do:
            if c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
            then
            do:
               message "Не заполнен объект"
                  view-as alert-box.
               return no-apply .
            end.
         end.
         if f-supp-code-TH <> 0 and f-supp-code-TH <> ? then
         do:
            assign
               buf_utd.cli-code = f-supp-code-TH
               buf_utd.cli-type = f-supp-type-TH
               .
         end.
         else
         do:
            if c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
            then
            do:
               message "Не заполнен поставщик"
                  view-as alert-box.
               return no-apply .
            end .
         end.
         if c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
         then
         do:
            if f-num = "" then
            do:
               message "Заполните номер документа"
                  view-as alert-box.
               return no-apply .
            end.
            assign
               buf_utd.DocumentNumber = f-num
               buf_utd.DocumentDate   = f-date
               buf_utd.sts-edi        = ObjSrv:Env:Utd:Sts:EDI:RecipientResponseStatusNotAccep:KeyIntDB
               .
            for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.doc-id = buf_utd.doc-id
               and buf_utd-marking-lines.db-num = buf_utd.db-num,
               first buf_marking EXCLUSIVE-LOCK where buf_marking.mark begins buf_utd-marking-lines.mark:
               buf_marking.sts = Marking:PendingVerification:KeyIntDB .
            end.
         end.
         if c-type = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB and p-mode = 'ДОБАВЛЕНИЕ':U then
         do:
            if buf_utd.DocumentNumber = "" then buf_utd.DocumentNumber = string(buf_utd.doc-id) .
            assign
               buf_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:RecipientResponseStatusNotAccep:KeyIntDB
               .
         end.
      end.
   END.
ON ROW-DISPLAY OF br-utd IN FRAME d-utd
   DO:
      define variable vColor as integer no-undo.
      if     buf_utd.Direction   ne 'inbound'
          or buf_utd.EDocType    eq objSrv:Env:Utd:EDocType:returns:KeyIntDB
      then
         .
      else if X_utd-lines.stts eq "Проверен" then
      do:
         if type_mark = 1 then
         do:
            vColor = CYAN_COLOR.
         end.
      end.
      else if X_utd-lines.stts begins  "Ошибка" then
      do:
         vColor = red_COLOR.
      end.
      if X_utd-lines.DelivCodeMis then
      do:
         vColor = LIGHT_RED_COLOR.
      end.
      X_utd-lines.LineNum     :fGCOLOR in browse br-utd = vColor.
      X_utd-lines.gds-code    :fGCOLOR in browse br-utd = vColor.
      X_utd-lines.ProductCode :fGCOLOR in browse br-utd = vColor.
      X_utd-lines.Gds-Name    :fGCOLOR in browse br-utd = vColor.
      X_utd-lines.UnitCode    :fGCOLOR in browse br-utd = vColor.
      X_utd-lines.UnitCliQnty :fGCOLOR in browse br-utd = vColor.
      X_utd-lines.Quantity    :fGCOLOR in browse br-utd = vColor.
      X_utd-lines.price       :fGCOLOR in browse br-utd = vColor.
      X_utd-lines.total       :fGCOLOR in browse br-utd = vColor.
      X_utd-lines.TaxRate_    :fgCOLOR in browse br-utd = vColor.
      X_utd-lines.qnty-scan   :fGCOLOR in browse br-utd = vColor.
      much                    :fGCOLOR in browse br-utd = vColor.
      mgdsunit                :fGCOLOR in browse br-utd = vColor.
      X_utd-lines.stts        :fGCOLOR in browse br-utd = vColor.
   END .
ON VALUE-CHANGED OF br-utd IN FRAME d-utd
   DO:
      f-info = "" .
      define variable vRecKey          as character no-undo.
      define variable vRecKey-line     as character no-undo.
      define variable vRecKey-markLine as character no-undo.
      if available (X_utd-lines) and available (buf_utd) then
      do:
         br-utd :refresh() no-error .
         run gen-key-rec ("utd",
            input  buffer buf_utd:handle,
            output vRecKey).
         run gen-key-rec ("utd-lines",
            input  buffer X_utd-lines:handle,
            output vRecKey-line).
         mRecKey-line = vRecKey-line.
         vRecKey-markLine = replace(vRecKey-line,"utd-lines","utd-marking-lines") + chr(3).
         menu-item m_error-lines:sensitive in menu m_error = yes.
         for each buf_utd-err no-lock where buf_utd-err.doc-id = X_utd-lines.doc-id
            and buf_utd-err.db-num = X_utd-lines.db-num
            and (buf_utd-err.reckey = vRecKey-line
            or buf_utd-err.reckey begins vRecKey-markLine or buf_utd-err.reckey = vRecKey):
            if f-info = "" then f-info = GetTextError(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj) + chr(10) no-error.
            else
            do:
               if length (f-info) >= 2000 then leave .
               f-info = f-info + GetTextError(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj) + chr(10) no-error.
            end.
         end.
         line-num-error = X_utd-lines.LineNum .
         if    ((    (not v-BarCode or X_utd-lines.isSelect)
                 and not X_utd-lines.isArtic)
            or can-find (first tt-utd-lines-filtr where tt-utd-lines-filtr.db-num   eq X_utd-lines.db-num
                                                    and tt-utd-lines-filtr.doc-id   eq X_utd-lines.doc-id
                                                    and tt-utd-lines-filtr.linenum  eq X_utd-lines.LineNum
                                                    and tt-utd-lines-filtr.bar-code eq m-gds-code))
            and f-info eq ""
            and p-mode <> 'ПРОСМОТР':U
            and mflagscan
            and not X_utd-lines.isMarking
            and not X_utd-lines.isVarWeight
         then
         do:
            X_utd-lines.qnty-scan:COLUMN-READ-ONLY IN BROWSE br-utd = FALSE.
         end.
         else
         do:
            X_utd-lines.qnty-scan:COLUMN-READ-ONLY IN BROWSE br-utd = TRUE.
         end.
      end.
      display f-info with frame d-utd .
   END.
ON row-leave OF br-utd IN FRAME d-utd
   DO:
      define variable kk as decimal no-undo .
      if available (X_utd-lines) then
      do:
         if X_utd-lines.isMarking then do:
         end.
         else do:
            kk = X_utd-lines.qnty-scan .
            assign
               browse br-utd X_utd-lines.qnty-scan
               .
            if X_utd-lines.stts begins "Ошибка" and kk <> X_utd-lines.qnty-scan then
            do:
               message "Приемка товара не возможна"
                  view-as alert-box.
               X_utd-lines.qnty-scan = kk.
               assign
                  browse br-utd X_utd-lines.qnty-scan
                  .
               if X_utd-lines.Quantity = X_utd-lines.qnty-scan then X_utd-lines.stts = "Проверен" .
               else X_utd-lines.stts = "Ожидает проверку" .
               recid_utd = recid (X_utd-lines) .
               run mark-temp (?).
               if m-gds-code ne ? and m-gds-code ne "" then do:    if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else    if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else                          OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. end. else do: if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else  if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else                        OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      end.
               br-utd :refresh() no-error.
               reposition br-utd to recid recid_utd no-error .
               apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
               return .
               .
            end.
            else if X_utd-lines.stts begins "Ошибка" then
               do:
                  return .
               end.
            if (not X_utd-lines.isWeight) and ROUND(X_utd-lines.qnty-scan,0) <> X_utd-lines.qnty-scan
            then do:
                message "Данный товар не может иметь дробное количество"
                view-as alert-box.
                return no-apply.
            end.
            if kk > X_utd-lines.qnty-scan and kk = X_utd-lines.Quantity then
            do:
               message
           "Вы точно хотите уменьшить количество по строке?"
           view-as alert-box question buttons yes-no update choice as logical  .
             if choice = false
             then do:
                X_utd-lines.qnty-scan = kk.
               assign
                  browse br-utd X_utd-lines.qnty-scan
                  .
               if X_utd-lines.Quantity = X_utd-lines.qnty-scan then X_utd-lines.stts = "Проверен" .
               else X_utd-lines.stts = "Ожидает проверку" .
                  recid_utd = recid (X_utd-lines) .
                  run mark-temp (?).
                  if m-gds-code ne ? and m-gds-code ne "" then do:    if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else    if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else                          OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. end. else do: if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else  if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else                        OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      end.
                  br-utd :refresh() no-error.
                  reposition br-utd to recid recid_utd no-error .
                  apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
                  return .
               end.
            end.
            if kk < X_utd-lines.qnty-scan and kk = X_utd-lines.Quantity then
            do:
               message "По строке введено максимальное значение. Изменить его в большую сторону невозможно."
                  view-as alert-box.
               X_utd-lines.qnty-scan = kk.
               if X_utd-lines.Quantity = X_utd-lines.qnty-scan then X_utd-lines.stts = "Проверен" .
               else X_utd-lines.stts = "Ожидает проверку" .
               recid_utd = recid (X_utd-lines) .
               run mark-temp (?).
               if m-gds-code ne ? and m-gds-code ne "" then do:    if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else    if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else                          OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. end. else do: if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else  if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else                        OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      end.
               br-utd :refresh() no-error.
               reposition br-utd to recid recid_utd no-error .
               apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
               return .
            end.
            if X_utd-lines.sts = Marking:Checked_:KeyIntDB then
            do:
               message "Товар проверен"
                  view-as alert-box.
               X_utd-lines.qnty-scan = kk.
               assign
                  browse br-utd X_utd-lines.qnty-scan
                  .
               if X_utd-lines.Quantity = X_utd-lines.qnty-scan then X_utd-lines.stts = "Проверен" .
               else X_utd-lines.stts = "Ожидает проверку" .
               recid_utd = recid (X_utd-lines) .
               run mark-temp (?).
               if m-gds-code ne ? and m-gds-code ne "" then do:    if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else    if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else                          OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. end. else do: if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else  if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else                        OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      end.
               br-utd :refresh() no-error.
               reposition br-utd-nomark to recid recid_utd no-error .
               apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
               return .
            end.
            if X_utd-lines.qnty-scan > X_utd-lines.Quantity then
            do:
               message "Введённое количество не может быть больше количества по строке. Количество уменьшено."
                  view-as alert-box.
               X_utd-lines.qnty-scan = X_utd-lines.Quantity.
               if X_utd-lines.Quantity = X_utd-lines.qnty-scan then X_utd-lines.stts = "Проверен" .
               else X_utd-lines.stts = "Ожидает проверку" .
               recid_utd = recid (X_utd-lines) .
               br-utd :refresh() no-error.
               reposition br-utd to recid recid_utd no-error .
               apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
            end.
            find first buf_utd-marking-lines where buf_utd-marking-lines.doc-id = p-doc-id and
               buf_utd-marking-lines.db-num = p-db-num and
               buf_utd-marking-lines.lineNum = X_utd-lines.lineNum no-error .
            if available (buf_utd-marking-lines) then
            do:
               if X_utd-lines.qnty-scan = X_utd-lines.Quantity then
               do:
                  buf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB .
               end.
            end.
            if X_utd-lines.Quantity = X_utd-lines.qnty-scan then X_utd-lines.stts = "Проверен" .
            else X_utd-lines.stts = "Ожидает проверку" .
            find first ub.utd-lines-attr exclusive-lock where ub.utd-lines-attr.db-num = p-db-num
               and ub.utd-lines-attr.doc-id = p-doc-id
               and ub.utd-lines-attr.LineNum = X_utd-lines.lineNum
               and ub.utd-lines-attr.attr-code = "QuantityBarCode"
               no-error .
            if not available (ub.utd-lines-attr) then
            do:
               create ub.utd-lines-attr .
               assign
                  ub.utd-lines-attr.db-num    = p-db-num
                  ub.utd-lines-attr.doc-id    = p-doc-id
                  ub.utd-lines-attr.LineNum   = X_utd-lines.lineNum
                  ub.utd-lines-attr.attr-code = "QuantityBarCode"
                  .
            end.
            if dec(ub.utd-lines-attr.attr-value) ne X_utd-lines.qnty-scan
            then do:
               ub.utd-lines-attr.attr-value = string(X_utd-lines.qnty-scan) .
               if length(m-gds-code) eq 14
               then
                  setattrUtdlines(p-db-num, p-doc-id,X_utd-lines.lineNum, "ScanGtin",m-gds-code ).
               recid_utd = recid (X_utd-lines).
               run mark-temp (?).
               if m-gds-code ne ? and m-gds-code ne "" then do:    if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else    if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else                          OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. end. else do: if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else  if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else                        OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      end.
               br-utd :refresh() no-error.
               reposition br-utd to recid recid_utd no-error .
               apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
            end.
         end.
      end.
   END.
ON CHOOSE OF b_cleaggds IN FRAME d-utd
   DO:
      b_cleaggds:visible = no.
      m-gds-code:visible = no.
      m-gds-code = ?.
      if m-gds-code ne ? and m-gds-code ne "" then do:    if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else    if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else                          OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. end. else do: if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else  if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else                        OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      end.
      apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
   end.
ON CHOOSE OF b_back-check IN FRAME d-utd
   DO:
      if c-status = ObjSrv:Env:Utd:Sts:TH:LoadError:KeyIntDB then
      do:
         c-status = if CheckMarkUtd (p-db-num,p-doc-id)
            then ObjSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB
            else objSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB .
      end.
      else if c-status = ObjSrv:Env:Utd:Sts:TH:LackOfMarkingCodesInCirculation:KeyIntDB then
         do:
            c-status = ObjSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB .
         end.
         else
         do:
            c-status = ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB .
         end.
      buf_utd.sts = integer(c-status).
      buf_utd.comment = "" .
      f-comment:screen-value = "" .
      ReCheckload(p-db-num,p-doc-id,no).
      c-status = buf_utd.sts.
      display c-status with frame d-utd .
      display f-info c-status c-status-edi f-comment with frame d-utd .
      run enable_UI in this-procedure .
      run mark-temp (?).
      if m-gds-code ne ? and m-gds-code ne "" then do:    if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else    if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else                          OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. end. else do: if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else  if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else                        OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      end.
      disable
         b_recheck
         b_anul
         b_write-cancel
         b_finish
         b_prov-finish
         b_back-check
         b_deliv-cancel
         with frame d-utd .
      run enable_BUTTON in this-procedure .
   END.
ON CHOOSE OF b_correct IN FRAME d-utd
   DO:
      define variable v-ok            as logical no-undo .
      define variable v-write-correct as logical no-undo init false.
      define buffer cancel_utd-marking-lines for ub.utd-marking-lines .
      define buffer cancel_utd-lines         for x_utd-lines .
      define buffer cancel_marking           for ub.marking .
      block_utd-line:
      for each cancel_utd-lines where cancel_utd-lines.db-num eq p-db-num
         and cancel_utd-lines.doc-id eq p-doc-id
      no-lock:
         if not cancel_utd-lines.isMarking
         then do:
            define variable vqnty as decimal no-undo.
            vqnty = decimal(GetAttrUtdlines(cancel_utd-lines.db-num,cancel_utd-lines.doc-id,cancel_utd-lines.linenum,"QuantityBarCode")).
            if vqnty > 0
               then
            do:
               v-write-correct = true .
               leave block_utd-line.
            end.
         end.
         else do:
            for each cancel_utd-marking-lines no-lock where cancel_utd-marking-lines.doc-id = p-doc-id
                                                        and cancel_utd-marking-lines.db-num = p-db-num
                                                        and cancel_utd-marking-lines.sts <> Marking:MarkError:KeyIntDB
                                                        and cancel_utd-marking-lines.sts <> Marking:GrayZone:KeyIntDB:
               v-write-correct = true .
               leave block_utd-line.
         end.
         end.
      end.
      if not v-write-correct then
      do:
         message "Все марки УПД не прошли проверку в ГИС МТ, принять товары в соответствии с данным УПД невозможно." skip
                 " И " skip
                 "По всем штрих-кодам УПД не введено колличество принятого товара." skip
            "Нажмите Отказать в поставке"
            view-as alert-box.
      end.
      else
      do:
         run ref/dialog-upd.w (input buf_utd.comment, input buf_utd.db-num, input buf_utd.doc-id, output v-comment, output v-ok) no-error.
         if  error-status:error then
         do:
            return return-value .
         end.
         if v-ok then
         do:
            buf_utd.comment = replace ( buf_utd.comment,chr(6), ", ").
            if buf_utd.comment <> "" then buf_utd.comment = buf_utd.comment + ", " + v-comment .
            else  buf_utd.comment = v-comment .
            f-comment = buf_utd.comment .
            display f-comment with frame d-utd .
            if available (buf_utd) then
            do:
               if p-connect <> ? then
               do:
                  run Sendansver( buf_utd.db-num, buf_utd.doc-id, "CorrectionRequest", v-comment) no-error.
                  if  error-status:error then
                  do:
                     message return-value
                          view-as alert-box.
                     return return-value .
                  end.
               end.
               else
                  assign
                     buf_utd.sts     = ObjSrv:Env:Utd:Sts:TH:CorrectionRequested:KeyIntDB
                     buf_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:SignatureAdjustment:KeyIntDB
                     .
               c-status = buf_utd.sts.
               c-status-edi = buf_utd.sts-edi.
            end.
            display c-status c-status-edi with frame d-utd .
            run enable_UI in this-procedure .
            disable
               b_anul
               b_recheck
               b_write-cancel
               b_prov-finish
               b_finish
               b_prov-finish
               b_back-check
               b_deliv-cancel
               with frame d-utd .
         end.
      end.
   END.
ON CHOOSE OF b_anul IN FRAME d-utd
   DO:
      c-status = ObjSrv:Env:Utd:Sts:TH:Canceled:KeyIntDB .
      buf_utd.sts = integer(c-status).
            display f-info c-status c-status-edi f-comment with frame d-utd .
            run enable_UI in this-procedure .
            run mark-temp (?).
               if m-gds-code ne ? and m-gds-code ne "" then do:    if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else    if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else                          OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. end. else do: if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else  if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else                        OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      end.
      disable
         b_recheck
         b_anul
         b_write-cancel
         b_prov-finish
         b_finish
         b_back-check
         b_deliv-cancel
         with frame d-utd .
   END.
ON CHOOSE OF MENU-ITEM m_error-utd
   DO:
      define variable v-ok as logical no-undo .
      run ref/dialog-error.w (input buf_utd.db-num, input buf_utd.doc-id, input "" , input 0) .
      if  error-status:error then
      do:
         return return-value .
      end.
      run enable_UI in this-procedure .
   END.
ON CHOOSE OF MENU-ITEM m_error-lines
   DO:
      define variable v-ok as logical no-undo .
      run ref/dialog-error.w (input buf_utd.db-num, input buf_utd.doc-id, input mRecKey-line, input line-num-error ) .
      if  error-status:error then
      do:
         return return-value .
      end.
      run enable_UI in this-procedure .
   END.
ON CHOOSE OF b_finish IN FRAME d-utd
   DO:
      define variable Log-Res  as logical no-undo.
      define variable quest-ok as logical no-undo .
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_mark_befree':U
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
      if available (buf_utd) and log-res then
      do:
         message "Уверены, что продажи по продукции закрыты?"
               view-as alert-box question buttons yes-no update quest-ok.
         if quest-ok then
         do:
            run utl/utd-mark-introduce.p (input buf_utd.db-num, input buf_utd.doc-id) no-error.
            if  error-status:error then
            do:
               return return-value .
            end.
            assign
               c-status     = buf_utd.sts
               c-status-edi = buf_utd.sts-edi
               .
         end.
      end.
      run enable_UI in this-procedure .
      disable
         b_recheck
         b_anul
         b_write-cancel
         b_prov-finish
         b_finish
         b_prov-finish
         b_back-check
         b_deliv-cancel
         with frame d-utd .
   END.
ON CHOOSE OF menu-item m_marks-lines
   DO:
      apply "entry" to br-utd in frame d-utd.
      if available (X_utd-lines) then
      do:
         recid_utd = recid(X_utd-lines) .
         run temp-mark (input 1) .
         if available (tt-marking-lines) then
         do:
            run str/mark_browse.w (input parparentproc,
               input-output table tt-marking-lines by-reference,
               input p-mode,
               input "Марки по: " + EdoTypeName(buf_utd.EDocType) + " " + buf_utd.DocumentNumber + " по товару " + string(X_utd-lines.gds-code) + " " + GdsName(X_utd-lines.gds-code),
               input type_mark,
               input ""
               ) no-error .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-utd :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
            empty temp-table tt-marking-lines .
            run mark-temp (?).
            if m-gds-code ne ? and m-gds-code ne "" then do:    if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else    if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else                          OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. end. else do: if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else  if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else                        OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      end.
            run enable_BUTTON .
            if c-status = ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB then
            do:
               find first X_utd-lines no-lock where X_utd-lines.stts <> "Проверен" no-error .
               if available (X_utd-lines) then
               do:
                  F-text = "                      Просканируйте марку/штрих-код" .
                  f-text:screen-value = "" .
                  display F-text with frame d-utd .
               end.
               else
               do:
                  F-text = "" .
                  f-text:screen-value = "" .
                  display F-text with frame d-utd .
               end.
            end.
         end.
         else
         do:
            message "Нет марок"
               view-as alert-box.
         end.
         br-utd :refresh() no-error .
         apply "VALUE-CHANGED" to br-utd in frame d-utd.
         apply "entry" to br-utd in frame d-utd.
         reposition br-utd to recid recid_utd no-error .
      end.
      else message "Нет марок"
            view-as alert-box.
      return no-apply .
   END.
ON CHOOSE OF menu-item m_marks-utd
   DO:
      apply "entry" to br-utd in frame d-utd.
      recid_utd = recid (X_utd-lines) .
      run temp-mark (input 2) .
      if available (tt-marking-lines) then
      do:
         run str/mark_browse.w (input parparentproc,
            input-output table tt-marking-lines by-reference,
            input p-mode,
            input "Марки по документу: " + EdoTypeName(buf_utd.EDocType) + " " + buf_utd.DocumentNumber,
            input type_mark,
            input ""
            ) no-error .
         empty temp-table tt-marking-lines .
         run mark-temp (?).
         run enable_BUTTON .
         if c-status = ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB then
         do:
            find first X_utd-lines no-lock where X_utd-lines.stts <> "Проверен" no-error .
            if available (X_utd-lines) then
            do:
               F-text = "                    Просканируйте марку/штрих-код" .
               f-text:screen-value = "" .
               display F-text with frame d-utd .
            end.
            else
            do:
               F-text = "" .
               f-text:screen-value = "" .
               display F-text with frame d-utd .
            end.
         end.
         br-utd :refresh () no-error.
         apply "VALUE-CHANGED" to br-utd in frame d-utd.
         apply "entry" to br-utd in frame d-utd.
         reposition br-utd to recid recid_utd no-error .
      end.
      else
      do:
         message "Нет марок по документу УПД"
            view-as alert-box.
      end.
      run enable_UI in this-procedure .
   END.
ON CHOOSE OF b_prov-finish IN FRAME d-utd
   DO:
      define variable v-ok        as logical no-undo .
      define variable v-check     as logical no-undo .
      define variable v-qnty-mark as integer no-undo .
      define variable v-fact-qnty as integer no-undo .
      define buffer bf_utd-marking-lines for ub.utd-marking-lines .
      define buffer bf_utd-lines-attr    for ub.utd-lines-attr .
      define buffer bf_utd-lines         for X_utd-lines .
      define buffer bf_marking           for ub.marking .
      define variable v-not-mark as integer no-undo .
      define variable vPawd as character no-undo.
      run adm\ask-pswd.w ("Введите пароль пользователя, осуществляющего обработку электронного документа, с целью подтверждения соответствия фактически полученного от поставщика количества товара и количества указанного в системе.",output vPawd).
      if  vPawd eq ?
      then
         return no-apply.
      If vPawd ne encode(g#passwd)
         then
      do:
         message "Введен неправильный пароль"
            view-as alert-box.
         return no-apply.
      end.
      if c-type = objSrv:Env:Utd:EDocType:UTD:KeyIntDB or c-type = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB then
      do:
         define variable vFlagErrorMarkCheck as logical no-undo.
         find first buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd.db-num and
            buf_utd-marking-lines.doc-id = buf_utd.doc-id and buf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB no-error .
         if not available (buf_utd-marking-lines) then
         do:
            vFlagErrorMarkCheck = yes.
         end.
         define variable vFlagErrorBarCheck as logical no-undo.
         find first X_utd-lines no-lock where X_utd-lines.db-num = buf_utd.db-num and X_utd-lines.doc-id = buf_utd.doc-id and
            X_utd-lines.qnty-scan ne 0 no-error .
         if not available (X_utd-lines) then
         do:
            vFlagErrorBarCheck = yes.
         end.
         if      vFlagErrorMarkCheck
            and  vFlagErrorBarCheck
         then do:
            message "Ни одна марка не просканирована и ни один штрих-код не просканирован. Просканируйте штрих-коды/марки или откажите в поставке."
                  view-as alert-box.
               return no-apply .
         end.
      end.
      if c-status = ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB then
      do:
         run check_mol (output v-check).
         if not v-check then return no-apply .
         run save_mol.
      end.
      for first X_utd-lines no-lock where
                                           X_utd-lines.db-num     eq buf_utd.db-num
                                      and  X_utd-lines.doc-id     eq buf_utd.doc-id
                                      and  X_utd-lines.Quantity   ne X_utd-lines.qnty-scan
      :
         v-ok = yes .
      end.
      for each buf_utd-err where buf_utd-err.CodeErr = "NotMarkForLine" and
         buf_utd-err.db-num = p-db-num and
         buf_utd-err.doc-id = p-doc-id:
         v-ok = yes .
      end.
      if v-ok and (c-type = objSrv:Env:Utd:EDocType:UTD:KeyIntDB or c-type = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB) then
      do:
         run ref/dialog-ok.w (output v-comment
            ) no-error .
         if v-comment = "" then return NO-APPLY .
      end .
      if c-type = objSrv:Env:Utd:EDocType:UTD:KeyIntDB or c-type = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB then
      do:
         if v-ok then c-status = ObjSrv:Env:Utd:Sts:TH:DeliveryCodeMismatch:KeyIntDB .
         else c-status = ObjSrv:Env:Utd:Sts:TH:SignatureRequired:KeyIntDB .
         for each bf_utd-lines where bf_utd-lines.db-num eq buf_utd.db-num
                                 and bf_utd-lines.doc-id eq buf_utd.doc-id
         no-lock:
            if bf_utd-lines.isMarking
            then do:
               for each bf_utd-marking-lines no-lock where bf_utd-marking-lines.db-num  = bf_utd-lines.db-num
                                                       and bf_utd-marking-lines.doc-id  = bf_utd-lines.doc-id
                                                       and bf_utd-marking-lines.LineNum = bf_utd-lines.LineNum,
               first buf_marking exclusive-lock where buf_marking.mark = bf_utd-marking-lines.mark:
                  case bf_utd-marking-lines.sts:
                     when Marking:Checked_:KeyIntDB then
                        do:
                           if buf_marking.sts <> Marking:MarkError:KeyIntDB and buf_marking.sts <> Marking:Ungrouped:KeyIntDB and
                              not (can-do(Marking:Sale_Return_Wait,string(buf_marking.sts)) or
                                   can-do(Marking:Doc_Status,string(buf_marking.sts)))
                           then
                              buf_marking.sts = Marking:Checked_:KeyIntDB .
                        end.
                     when Marking:MarkError:KeyIntDB or
                     when Marking:SaleLock:KeyIntDB or
                     when Marking:SaleWaitLock:KeyIntDB or
                     when Marking:ReturnLock:KeyIntDB or
                     when Marking:ReturnWaitLock:KeyIntDB or
                     when Marking:Ungrouped:KeyIntDB then
                        do:
                        end.
                     otherwise
                     do:
                        if buf_marking.sts <> Marking:MarkError:KeyIntDB then
                           buf_marking.sts = Marking:NotAvailable:KeyIntDB .
                     end.
                  end.
               end.
            end.
            else do:
               if bf_utd-lines.Quantity <> bf_utd-lines.qnty-scan then
               do:
                  setattrUtdlines(p-db-num,p-doc-id,bf_utd-lines.LineNum,"NoQuantityBarCode",string(bf_utd-lines.Quantity - bf_utd-lines.qnty-scan)).
               end.
            end.
         end.
      end.
      else
      do:
         if c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
         then
         do:
            c-status = ObjSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB .
         end.
         if c-type =  objSrv:Env:Utd:EDocType:Introduce:KeyIntDB then
         do:
            c-status = ObjSrv:Env:Utd:Sts:TH:AwaitingConfirmation:KeyIntDB .
            for each bf_utd-lines no-lock where bf_utd-lines.doc-id = buf_utd.doc-id and
               bf_utd-lines.db-num = buf_utd.db-num:
               v-qnty-mark = 0 .
               v-fact-qnty = 0 .
               for each bf_utd-marking-lines no-lock where bf_utd-marking-lines.doc-id = bf_utd-lines.doc-id and
                  bf_utd-marking-lines.db-num = bf_utd-lines.db-num and
                  bf_utd-marking-lines.gds-code = bf_utd-lines.gds-code and
                  bf_utd-marking-lines.LineNum = bf_utd-lines.LineNum and
                  bf_utd-marking-lines.doc-level = 1,
                  first bf_marking no-lock where bf_marking.mark = bf_utd-marking-lines.mark:
                  v-qnty-mark = v-qnty-mark + bf_marking.box-qnty .
               end.
               for first bf_utd-lines-attr exclusive-lock where bf_utd-lines-attr.db-num = bf_utd-lines.db-num and
                  bf_utd-lines-attr.doc-id = bf_utd-lines.doc-id and
                  bf_utd-lines-attr.LineNum = bf_utd-lines.LineNum and
                  bf_utd-lines-attr.attr-code = "utd-fact-qnty":
                  v-fact-qnty = integer(bf_utd-lines-attr.attr-value) .
               end.
               v-not-mark = v-fact-qnty - v-qnty-mark .
               setattrUtdlines(bf_utd-lines.db-num,bf_utd-lines.doc-id,bf_utd-lines.LineNum,"NoMarking",string(v-not-mark)).
            end.
         end.
      end.
      buf_utd.sts = integer(c-status).
      do:
         define variable v-check-db-num  as integer   no-undo .
         define variable v-check-user-id as character no-undo .
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run getcurus in g#library2
  (output v-check-db-num
  ,output v-check-user-id
  ) no-error .
         run ibs\th\str\utd\adaputd.p
            (buf_utd.db-num,
            buf_utd.doc-id,
            v-check-user-id
            ) no-error .
         def var v-msg as char no-undo.
         if not error-status:error
            then
         do:
            v-msg = "".
            if return-value matches "*ошибка*"
               then v-msg = substitute ('Документ № &1 от &2. Сформирована ПН: &3. &4', buf_utd.DocumentNumber, string (buf_utd.DocumentDate) , buf_utd.doc-code, return-value).
            else do:
               if     buf_utd.sts ne objSrv:Env:Utd:Sts:TH:Confirmed           :KeyIntDB
               then    v-msg = substitute ('Получен УПД. Документ № &1 от &2. Сформирована ПН: &3. &5 &6 &4',
                                           buf_utd.DocumentNumber,
                                           string (buf_utd.DocumentDate) ,
                                           buf_utd.doc-code,
                                           return-value,
                                           if ChecknotMarkUtd(buf_utd.db-num,buf_utd.doc-id) then "Немаркированные товары можно продавать на кассе. " else "",
                                           if CheckMarkUtd(buf_utd.db-num,buf_utd.doc-id) then "Продажа маркированных товаров из данной поставки запрещена до получения дополнительного уведомления. " else "").
               else if     buf_utd.sts eq objSrv:Env:Utd:Sts:TH:Confirmed           :KeyIntDB
                       and CheckMarkUtd(buf_utd.db-num,buf_utd.doc-id)
               then    v-msg = substitute ('Получен УПД. Документ № &1 от &2. Сформирована ПН: &3. &5 &4', buf_utd.DocumentNumber, string (buf_utd.DocumentDate) , buf_utd.doc-code, return-value, "Маркированные товары данной поставки можно продавать на кассе").
            end.
         end.
         else v-msg = substitute ('Документ: &1 от &2. Ошибка при формировании ПН. &3. &4', buf_utd.DocumentNumber, string (buf_utd.DocumentDate), trim(return-value, ".")).
         if v-msg ne ""
         then
            message v-msg
               view-as alert-box.
      end.
      run enable_UI in this-procedure .
      buf_utd.comment = v-comment .
      f-comment = v-comment .
      display f-comment c-status with frame d-utd.
      apply "choose" to b-save in frame d-utd.
   END.
ON CHOOSE OF b_recheck IN FRAME d-utd
   DO:
      define variable Log-Res as logical no-undo.
      if available (buf_utd)
         then
      do:
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
         if log-res
            then
         do:
            Recheck(buf_utd.db-num, buf_utd.doc-id).
            assign
               c-status     = buf_utd.sts
               c-status-edi = buf_utd.sts-edi
               f-comment    = buf_utd.comment
               .
            display f-info c-status c-status-edi f-comment with frame d-utd .
            run enable_UI in this-procedure .
            run mark-temp (?).
               if m-gds-code ne ? and m-gds-code ne "" then do:    if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else    if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else                          OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. end. else do: if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else  if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else                        OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      end.
            run enable_BUTTON in this-procedure .
         end.
      end.
   end.
ON CHOOSE OF b_write-cancel IN FRAME d-utd
   DO:
      define variable v-ok as logical no-undo .
      if available (buf_utd) then
      do:
         run ref/dialog-upd.w (input buf_utd.comment, input buf_utd.db-num, input buf_utd.doc-id, output v-comment, output v-ok) no-error.
         if  error-status:error then
         do:
            return return-value .
         end.
         if v-ok then
         do:
            buf_utd.comment = replace ( buf_utd.comment,chr(6), ", ").
            if buf_utd.comment <> "" then buf_utd.comment = buf_utd.comment + ", " + v-comment .
            else  buf_utd.comment = v-comment .
            f-comment = buf_utd.comment .
            display f-comment with frame d-utd .
            if p-connect <> ? then
            do:
               run SendResponse( buf_utd.db-num, buf_utd.doc-id, no, no) no-error.
               if  error-status:error then
               do:
                  message return-value
                        view-as alert-box.
                  return return-value .
               end.
            end.
            else
            do:
               buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:RejectionUtd:KeyIntDB.
               buf_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:AutoRejected:KeyIntDB.
            end.
         end.
         assign
            c-status     = buf_utd.sts
            c-status-edi = buf_utd.sts-edi
            .
         display c-status c-status-edi with frame d-utd .
         disable
            b_recheck
            b_anul
            b_write-cancel
            b_prov-finish
            b_finish
            b_back-check
            b_deliv-cancel
            with frame d-utd .
      end.
   END.
ON CHOOSE OF b_deliv-cancel IN FRAME d-utd
   DO:
      define variable v-ok as logical no-undo .
      if available (buf_utd) then
      do:
         run ref/dialog-upd.w (input buf_utd.comment, input buf_utd.db-num, input buf_utd.doc-id, output v-comment, output v-ok) no-error.
         if  error-status:error then
         do:
            return return-value .
         end.
         if v-ok then
         do:
            if buf_utd.comment <> "" and buf_utd.comment <> ? then buf_utd.comment = buf_utd.comment + chr(6) + v-comment .
            else buf_utd.comment = v-comment .
            f-comment = buf_utd.comment .
            display f-comment with frame d-utd .
            if p-connect <> ? then
            do:
               run SendAnsver(buf_utd.db-num, buf_utd.doc-id,"AcceptDocumentNotAccepted", "") no-error.
               if  error-status:error then
               do:
                  message return-value
                     view-as alert-box.
                  return return-value .
               end.
            end.
            else
            do:
               buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:RejectionUtd:KeyIntDB.
               buf_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:SignatureNotAccepted:KeyIntDB.
            end.
            validate buf_utd no-error.
            assign
               c-status     = buf_utd.sts
               c-status-edi = buf_utd.sts-edi
               .
         end.
      end.
      display c-status c-status-edi with frame d-utd .
      disable
         b_recheck
         b_anul
         b_write-cancel
         b_prov-finish
         b_finish
         b_back-check
         b_deliv-cancel
         with frame d-utd .
   END.
ON VALUE-CHANGED OF c-status IN FRAME d-utd
   DO:
      assign c-status .
      if c-type = 0 then
      do:
         message "Укажите тип документа"
            view-as alert-box.
      end.
      buf_utd.sts = integer(c-status).
      validate buf_utd no-error.
      c-status = buf_utd.sts.
      c-status-edi = buf_utd.sts-edi.
      display c-status c-status-edi with frame d-utd .
      run enable_BUTTON .
   END.
ON VALUE-CHANGED OF c-status-edi IN FRAME d-utd
   DO:
      assign c-status-edi .
      if c-type = 0 then
      do:
         message "Укажите тип документа"
            view-as alert-box.
      end.
      buf_utd.sts-edi = integer(c-status-edi).
      validate buf_utd no-error.
      c-status = buf_utd.sts.
      c-status-edi = buf_utd.sts-edi.
      display c-status c-status-edi with frame d-utd .
      run enable_BUTTON .
   END.
ON VALUE-CHANGED OF c-type IN FRAME d-utd
   DO:
      assign c-type .
      if available (buf_utd) then buf_utd.EDocType = c-type .
      F-text = "                            Просканируйте марку/штрих-код" .
      display f-text with frame d-utd .
      run enable_UI .
   END.
ON leave OF f-agnt IN FRAME d-utd
   DO:
      define buffer buf_clients for ub.clients .
      assign f-agnt .
      find first buf_clients no-lock where buf_clients.obj-code = f-agnt and buf_clients.obj-type = 'чел':U no-error .
      IF NOT AVAILABLE buf_clients THEN
      do:
         f-agnt = ? .
      end.
      else
      do:
         ASSIGN
            f-agnt    = buf_clients.obj-code
            agnt-name = buf_clients.obj-name
            .
      end.
      display f-agnt agnt-name  with frame d-utd.
   END.
ON leave OF f-boss IN FRAME d-utd
   DO:
      define buffer buf_clients for ub.clients .
      assign f-boss .
      find first buf_clients no-lock where buf_clients.obj-code = f-boss and buf_clients.obj-type = 'чел':U no-error .
      IF NOT AVAILABLE buf_clients THEN
      do:
         f-boss = ? .
      end.
      else
      do:
         ASSIGN
            f-boss    = buf_clients.obj-code
            boss-name = buf_clients.obj-name
            .
      end.
      display f-boss boss-name  with frame d-utd.
   END.
ON leave OF f-wrkr IN FRAME d-utd
   DO:
      define buffer buf_clients for ub.clients .
      assign f-wrkr .
      find first buf_clients no-lock where buf_clients.obj-code = f-wrkr and buf_clients.obj-type = 'чел':U no-error .
      IF NOT AVAILABLE buf_clients THEN
      do:
         f-wrkr = ? .
      end.
      else
      do:
         ASSIGN
            f-wrkr    = buf_clients.obj-code
            wrkr-name = buf_clients.obj-name
            .
      end.
      display f-wrkr wrkr-name  with frame d-utd.
   END.
ON CHOOSE OF MENU-ITEM m_choose-status
   DO:
      enable c-status with frame d-utd .
      if c-type = objSrv:Env:Utd:EDocType:UTD:KeyIntDB or c-type = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB then enable c-status-edi with frame d-utd .
   END.
ON CHOOSE OF MENU-ITEM m_reset_row_data
   DO:
      define buffer cancel_utd-marking-lines for ub.utd-marking-lines .
      define buffer cancel_marking           for ub.marking .
      define buffer buf_utd-lines-attr       for ub.utd-lines-attr .
      define buffer buf_marking-attr         for ub.marking-attr .
      define buffer cancel_marking-attr         for ub.marking-attr .
      define buffer cancel_marking-lines-attr for ub.utd-marking-lines-attr.
      define variable v-gds-code as integer no-undo.
      if available (X_utd-lines) then
      do:
         for each cancel_utd-marking-lines exclusive-lock where cancel_utd-marking-lines.doc-id  = x_utd-lines.doc-id
              and cancel_utd-marking-lines.db-num  = x_utd-lines.db-num
              and cancel_utd-marking-lines.lineNum = x_utd-lines.lineNum
              and cancel_utd-marking-lines.doc-level = 1
              and cancel_utd-marking-lines.sts = Marking:Checked_:KeyIntDB,
            first cancel_marking exclusive-lock where
                  cancel_marking.mark = cancel_utd-marking-lines.mark
         :
            if cancel_marking.sts = Marking:ungrouped:KeyIntDB then
            do:
              if not isSaleMarkInUpak(cancel_utd-marking-lines.mark) then
                setStatusUpak (
                  cancel_utd-marking-lines.db-num,
                  cancel_utd-marking-lines.doc-id,
                  cancel_utd-marking-lines.lineNum,
                  cancel_utd-marking-lines.mark,
                  Marking:DeliveryControl:KeyIntDB
                ).
            end.
            else do:
              setStatusUpak (
                cancel_utd-marking-lines.db-num,
                cancel_utd-marking-lines.doc-id,
                cancel_utd-marking-lines.lineNum,
                cancel_utd-marking-lines.mark,
                Marking:DeliveryControl:KeyIntDB
              ).
            end.
         end.
         if x_utd-lines.isArtic and x_utd-lines.isWeight
         then do:
             for each cancel_utd-marking-lines exclusive-lock where
                      cancel_utd-marking-lines.doc-id  = x_utd-lines.doc-id
                  and cancel_utd-marking-lines.db-num  = x_utd-lines.db-num
                  and cancel_utd-marking-lines.lineNum = x_utd-lines.lineNum,
             first cancel_marking no-lock where
                   cancel_marking.mark = cancel_utd-marking-lines.mark:
                if not ChkAnotherUtd(x_utd-lines.doc-id, x_utd-lines.db-num, cancel_marking.mark) then do:
                    find first cancel_marking-attr exclusive-lock where
                               cancel_marking-attr.mark = cancel_utd-marking-lines.mark
                           and cancel_marking-attr.attr-code = "weight"
                           no-wait no-error.
                    if avail cancel_marking-attr then
                       delete cancel_marking-attr.
                end.
                delete cancel_utd-marking-lines.
             end.
         end.
         X_utd-lines.qnty-scan = 0 .
         setattrUtdlines(X_utd-lines.db-num, X_utd-lines.doc-id, X_utd-lines.LineNum, "QuantityBarCode", string(X_utd-lines.qnty-scan)).
         if not x_utd-lines.isMarking then
         do:
            if x_utd-lines.isArtic and x_utd-lines.isWeight then
            do:
               X_utd-lines.PieceFact = "" .
               setattrUtdlines(X_utd-lines.db-num, X_utd-lines.doc-id, X_utd-lines.LineNum, "QuantityPiece", X_utd-lines.PieceFact).
            end.
         end.
         run mark-temp in this-procedure (X_utd-lines.LineNum).
      end.
      if m-gds-code ne ? and m-gds-code ne "" then do:    if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else    if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else                          OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. end. else do: if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else  if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else                        OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      end.
   END.
ON CHOOSE OF MENU-ITEM m_check-akt
   DO:
      define buffer bf_utd for ub.utd .
      define variable v-rec-list as character  no-undo .
      define variable not-mark   as logical    no-undo .
      define variable mark-qnty  as integer    no-undo .
      define variable bar-qnty   as integer    no-undo .
      define variable LineNum    as integer    no-undo .
      define variable vconnect   as com-handle no-undo.
      define variable vmark      as character  no-undo.
      define buffer buf_utd-marking-lines for ub.utd-marking-lines .
      define buffer bf_utd-marking-lines  for ub.utd-marking-lines .
      define buffer bf_marking            for ub.marking .
      define buffer bf_utd-lines-attr     for ub.utd-lines-attr .
      define variable mark-qnty-gray      as integer   no-undo .
      define variable mark-qnty-check     as integer   no-undo .
      define variable bar-qnty-gray       as integer   no-undo .
      define variable bar-qnty-check      as integer   no-undo .
      do:
         find first bf_utd exclusive-lock where bf_utd.DocumentNumber = buf_utd.DocumentNumber and
            bf_utd.DocumentDate = buf_utd.DocumentDate and bf_utd.edoctype = objSrv:Env:Utd:EDocType:AKT:KeyIntDB no-error .
         if not available (bf_utd) then
         do:
            run str/UPD.w ( parparentproc, 'ВЫБОР':U, objSrv:Env:Utd:EDocType:AKT:KeyIntDB, "", input-output vconnect, output v-rec-list)  no-error .
            find first bf_utd exclusive-lock where recid(bf_utd) = integer(v-rec-list) no-error .
         end.
         if available (bf_utd) then
         do:
            mark-qnty-gray  = 0 .
            mark-qnty-check = 0 .
            bar-qnty-gray   = 0 .
            bar-qnty-check  = 0 .
            mark-qnty = 0 .
            bar-qnty = 0 .
            NEXT_:
            for each buf_utd-lines no-lock where buf_utd-lines.db-num = buf_utd.db-num and
               buf_utd-lines.doc-id = buf_utd.doc-id:
               LineNum = 0 .
               if logical(getAttrUtdLinesEx (buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum,"MarkUtdLine","yes"))
               then do:
                  for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd-lines.db-num
                     and buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id
                     and buf_utd-marking-lines.gds-code = buf_utd-lines.gds-code
                     and buf_utd-marking-lines.linenum = buf_utd-lines.linenum
                     and buf_utd-marking-lines.doc-level = 1:
                     vmark = getcodeident(buf_utd-marking-lines.mark).
                     find first bf_utd-marking-lines no-lock where bf_utd-marking-lines.db-num = bf_utd.db-num
                        and bf_utd-marking-lines.doc-id = bf_utd.doc-id
                        and bf_utd-marking-lines.gds-code = buf_utd-marking-lines.gds-code
                        and bf_utd-marking-lines.mark begins vmark no-error .
                     if not available (bf_utd-marking-lines) then
                     do:
                        not-mark = true .
                        next next_ .
                     end.
                     find first buf_marking exclusive-lock where buf_marking.mark = buf_utd-marking-lines.mark
                        and (buf_marking.sts = Marking:GrayZone:KeyIntDB
                        or buf_marking.sts = Marking:MarkError:KeyIntDB) no-error .
                     if available (buf_marking) then
                     do:
                        not-mark = true .
                        next next_ .
                     end.
                  end.
                  for each buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.db-num = buf_utd-lines.db-num
                     and buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id
                     and buf_utd-marking-lines.gds-code = buf_utd-lines.gds-code
                     and buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum,
                     first bf_utd-marking-lines exclusive-lock where bf_utd-marking-lines.db-num = bf_utd.db-num
                     and bf_utd-marking-lines.doc-id = bf_utd.doc-id
                     and bf_utd-marking-lines.gds-code = buf_utd-marking-lines.gds-code
                     and bf_utd-marking-lines.mark begins buf_utd-marking-lines.mark
                     and bf_utd-marking-lines.doc-level = 1:
                     if length (buf_utd-marking-lines.mark) > length(bf_utd-marking-lines.mark)
                        then
                     do:
                        find first bf_marking where bf_marking.mark eq buf_utd-marking-lines.mark
                           exclusive-lock no-error.
                        if available bf_marking
                           then
                        do:
                           find first bf_marking where bf_marking.mark eq bf_utd-marking-lines.mark
                              exclusive-lock no-error.
                           if available bf_marking
                              then
                           do:
                              g#auto = yes.
                              delete bf_marking.
                              g#auto = no.
                           end.
                        end.
                        bf_utd-marking-lines.mark = buf_utd-marking-lines.mark.
                     end.
                     if tree:LevelDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then
                     do:
                        tree:StatusDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num, Marking:Checked_:KeyIntDB) .
                     end.
                     for first buf_marking exclusive-lock where buf_marking.mark = buf_utd-marking-lines.mark:
                        mark-qnty-check = mark-qnty-check + buf_marking.box-qnty .
                        buf_marking.sts = Marking:Checked_:KeyIntDB.
                        buf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB.
                     end.
                  end.
               end.
               else do:
                  for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd-lines.db-num
                     and buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id
                     and buf_utd-marking-lines.gds-code = buf_utd-lines.gds-code
                     and buf_utd-marking-lines.linenum = buf_utd-lines.linenum
                     and buf_utd-marking-lines.doc-level = 1:
                     vmark = getcodeident(buf_utd-marking-lines.mark).
                     find first bf_utd-marking-lines no-lock where bf_utd-marking-lines.db-num = bf_utd.db-num
                        and bf_utd-marking-lines.doc-id = bf_utd.doc-id
                        and bf_utd-marking-lines.gds-code = buf_utd-marking-lines.gds-code
                        and bf_utd-marking-lines.mark = vmark no-error .
                     if not available (bf_utd-marking-lines) then
                     do:
                        not-mark = true .
                        next next_ .
                     end.
                  end.
                  for each buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.db-num = buf_utd-lines.db-num
                     and buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id
                     and buf_utd-marking-lines.gds-code = buf_utd-lines.gds-code
                     and buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum,
                     first bf_utd-marking-lines exclusive-lock where bf_utd-marking-lines.db-num = bf_utd.db-num
                     and bf_utd-marking-lines.doc-id = bf_utd.doc-id
                     and bf_utd-marking-lines.gds-code = buf_utd-marking-lines.gds-code
                     and bf_utd-marking-lines.mark = buf_utd-marking-lines.mark
                     and bf_utd-marking-lines.doc-level = 1:
                     for first bf_utd-lines-attr no-lock where bf_utd-lines-attr.attr-code = "QuantityBarCode" and
                        bf_utd-lines-attr.db-num = bf_utd-marking-lines.db-num and
                        bf_utd-lines-attr.doc-id = bf_utd-marking-lines.doc-id and
                        bf_utd-lines-attr.LineNum = bf_utd-lines-attr.LineNum:
                        bar-qnty-check = bar-qnty-check + integer(bf_utd-lines-attr.attr-value) .
                        if integer(bf_utd-lines-attr.attr-value) = bf_utd-lines.Quantity then
                        do:
                           bf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB.
                        end.
                     end.
                  end.
               end.
            end.
            if not-mark and mark-qnty-check + bar-qnty-check  = 0 then
            do:
               message "В документе неполный состав марок/штрих-кодов. Просканируйте марки/штрих-кодов вручную."
                  view-as alert-box.
            end.
            if not-mark and mark-qnty-check + bar-qnty-check <> 0 then
            do:
               for each buf_utd-lines no-lock where buf_utd-lines.db-num = buf_utd.db-num and
                                                    buf_utd-lines.doc-id = buf_utd.doc-id:
                  if logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","yes"))
                  then do:
                     for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num  = buf_utd-lines.db-num and
                                                                  buf_utd-marking-lines.doc-id  = buf_utd-lines.doc-id and
                                                                  buf_utd-marking-lines.lineNum = buf_utd-lines.lineNum and
                                                                  buf_utd-marking-lines.doc-level = 1,
                     first buf_marking where buf_marking.mark = buf_utd-marking-lines.mark
                     no-lock:
                        mark-qnty = mark-qnty + buf_marking.box-qnty .
                     end.
                  end.
                  else do:
                     for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num  = buf_utd-lines.db-num and
                                                                  buf_utd-marking-lines.doc-id  = buf_utd-lines.doc-id and
                                                                  buf_utd-marking-lines.lineNum = buf_utd-lines.lineNum and
                                                                  buf_utd-marking-lines.doc-level = 1:
                        for first bf_utd-lines-attr no-lock where bf_utd-lines-attr.attr-code = "QuantityBarCode" and
                           bf_utd-lines-attr.db-num = buf_utd-marking-lines.db-num and
                           bf_utd-lines-attr.doc-id = buf_utd-marking-lines.doc-id and
                           bf_utd-lines-attr.LineNum = buf_utd-marking-lines.LineNum:
                           bar-qnty = bar-qnty + integer(bf_utd-lines-attr.attr-value) .
                           if integer(bf_utd-lines-attr.attr-value) = bf_utd-lines.Quantity then
                           do:
                              buf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB.
                           end.
                        end.
                     end.
                  end.
               end.
               mark-qnty-gray = mark-qnty - mark-qnty-check .
               bar-qnty-gray = bar-qnty - bar-qnty-check .
               if mark-qnty-check + bar-qnty-check <> 0 then
                  bf_utd.doc-code = buf_utd.DocumentNumber .
               message "Проверка завершена" skip
                  "Успешно проверено марок - " + string (mark-qnty-check) skip
                  "Не проверено марок - " + string (mark-qnty-gray) skip
                  "Успешно проверено марок - " + string (bar-qnty-check) skip
                  "Не проверено марок - " + string (bar-qnty-gray) skip
                  view-as alert-box.
            end .
            if mark-qnty-gray + bar-qnty-gray <> 0 then
            do:
               F-text = "                     Просканируйте марку/штрих-кодов" .
               display F-text with frame d-utd .
            end.
         end.
      end.
      run mark-temp (?).
      if m-gds-code ne ? and m-gds-code ne "" then do:    if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else    if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else                          OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. end. else do: if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else  if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else                        OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      end.
   END.
ON CHOOSE OF r-agnt IN FRAME d-utd
   DO:
      run ref/cli-all.w (
         input parparentproc
         ,input "b-sel"
         ,input 'чел':U
         ,input 'все':U
         ,input 'текущие':U
         ,input ?
         ,input ",,,,,,NO,,"
         ,input ""
         ,output v-rid-list ) NO-ERROR.
      IF v-rid-list = '':U THEN RETURN NO-APPLY.
      FIND FIRST buf_clients NO-LOCK WHERE
         recid(buf_clients) = INTEGER(v-rid-list) NO-ERROR.
      IF NOT AVAILABLE buf_clients THEN RETURN NO-APPLY.
      ASSIGN
         f-agnt    = buf_clients.obj-code
         agnt-name = buf_clients.obj-name
         .
      display f-agnt agnt-name  with frame d-utd.
   END.
ON CHOOSE OF r-boss IN FRAME d-utd
   DO:
      run ref/cli-all.w (
         input parparentproc
         ,input "b-sel"
         ,input 'чел':U
         ,input 'все':U
         ,input 'текущие':U
         ,input ?
         ,input ",,,,,,NO,,"
         ,input ""
         ,output v-rid-list ) NO-ERROR.
      IF v-rid-list = '':U THEN RETURN NO-APPLY.
      FIND FIRST buf_clients NO-LOCK WHERE
         recid(buf_clients) = INTEGER(v-rid-list) NO-ERROR.
      IF NOT AVAILABLE buf_clients THEN RETURN NO-APPLY.
      ASSIGN
         f-boss    = buf_clients.obj-code
         boss-name = buf_clients.obj-name
         .
      display f-boss boss-name  with frame d-utd.
   END.
ON CHOOSE OF r-contr-TH IN FRAME d-utd
   DO:
      define buffer buf_contract for contract.
      define variable agnt-list as character no-undo .
      if f-supp-code-TH <> 0 then
      do:
         run str/cont-all.w ( input  parParentProc, input v-cntxt-host-code-obj, input "b-sel":U, input 'фирма':U, input f-supp-type-TH, input f-supp-code-TH, input  ?, input  ?, input  "current", input 'при':U , input-output agnt-list   ) no-error .
         find first buf_contract no-lock where RECID(buf_contract) = int (agnt-list) no-error.
         if not available buf_contract then
         do:
            assign
               f-contr-TH      = 0
               f-contr-name-TH = ""
               .
            display f-contr-TH f-contr-name-TH  with frame d-utd.
            return.
         end.
         if c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
         then
         do:
            define variable v-tth             as handle    no-undo .
            define variable v-value-character as character no-undo.
            define variable v-value-date      as date      no-undo.
            define variable v-value-decimal   as decimal   no-undo.
            define variable v-value-integer   as integer   no-undo.
            define variable v-param-type      as character no-undo.
            define variable v-FlagEdo         as logical   no-undo.
            run adm/shattri.p (
               input "get":U
               ,input  buf_utd.obj-type
               ,input  buf_utd.obj-code
               ,input  'marking':U
               ,input  'marking-EDO':U
               ,output v-value-character
               ,output v-value-date
               ,output v-value-decimal
               ,output v-value-integer
               ,output v-FlagEdo
               ,output v-param-type
               ,input-output table-handle v-tth
               ) no-error .
            if v-FlagEdo then
            do:
               if buf_contract.whole-send-news > 0 then
               do:
                  assign
                     f-contr-TH      = buf_contract.contract-code
                     f-contr-name-TH = buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date,"99/99/9999")
                     .
               end.
               else
               do:
                  message "У договора " + buf_contract.contract-prn-code + " нет признака - 'Поставки через ЭДО'"
                     view-as alert-box.
                  return no-apply .
               end.
            end.
            else
            do:
               assign
                  f-contr-TH      = buf_contract.contract-code
                  f-contr-name-TH = buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date,"99/99/9999")
                  .
            end.
         end.
         else
         do:
            assign
               f-contr-TH      = buf_contract.contract-code
               f-contr-name-TH = buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date,"99/99/9999")
               .
         end.
         display f-contr-TH f-contr-name-TH  with frame d-utd.
         if c-type <> objSrv:Env:Utd:EDocType:AKT:KeyIntDB
         then
            disable r-contr-TH with frame d-utd .
         run enable_BUTTON .
      end.
      else message "Поставщик договора не известен"
            view-as alert-box.
   END.
ON CHOOSE OF r-obj-TH IN FRAME d-utd
   DO:
      define variable v-tth             as handle    no-undo .
      define variable v-value-character as character no-undo.
      define variable v-value-date      as date      no-undo.
      define variable v-value-decimal   as decimal   no-undo.
      define variable v-value-integer   as integer   no-undo.
      define variable v-param-type      as character no-undo.
      define variable v-FlagEdo         as logical   no-undo.
      run ref/cli-all.w (
         input parparentproc
         ,input "b-sel"
         ,input 'маг':U
         ,input 'все':U
         ,input 'текущие':U
         ,input ?
         ,input ",,,,,,NO,,"
         ,input ""
         ,output v-rid-list ) NO-ERROR.
      IF v-rid-list = '':U THEN RETURN NO-APPLY.
      FIND FIRST buf_clients NO-LOCK WHERE
         recid(buf_clients) = INTEGER(v-rid-list) NO-ERROR.
      IF NOT AVAILABLE buf_clients THEN RETURN NO-APPLY.
      run adm/shattri.p (
         input "get":U
         ,input  buf_clients.obj-type
         ,input  buf_clients.obj-code
         ,input  'marking':U
         ,input  'marking-EDO':U
         ,output v-value-character
         ,output v-value-date
         ,output v-value-decimal
         ,output v-value-integer
         ,output v-FlagEdo
         ,output v-param-type
         ,input-output table-handle v-tth
         ) no-error .
      if not v-FlagEdo then
      do:
         message "Сформировать УПД для данного объекта невозможно." skip
            "Для объекта не включен электронный документооборот"
            view-as alert-box.
         return no-apply .
      end.
      ASSIGN
         f-obj-type-TH = buf_clients.obj-type
         f-obj-code-TH = buf_clients.obj-code
         f-obj-name-TH = buf_clients.obj-name
         .
      display f-obj-code-TH f-obj-type-TH f-obj-name-TH  with frame d-utd.
      disable r-obj-TH with frame d-utd .
      run enable_BUTTON .
   END.
ON CHOOSE OF r-supp-TH IN FRAME d-utd
   DO:
      run ref/cli-all.w (
         input parparentproc
         ,input "b-sel"
         ,input 'орг':U
         ,input 'все':U
         ,input 'текущие':U
         ,input ?
         ,input ",,,,,,NO,,"
         ,input ""
         ,output v-rid-list ) NO-ERROR.
      IF v-rid-list = '':U THEN RETURN NO-APPLY.
      FIND FIRST buf_clients NO-LOCK WHERE
         recid(buf_clients) = INTEGER(v-rid-list) NO-ERROR.
      IF NOT AVAILABLE buf_clients THEN RETURN NO-APPLY.
      ASSIGN
         f-supp-type-TH = buf_clients.obj-type
         f-supp-code-TH = buf_clients.obj-code
         f-supp-name-TH = buf_clients.obj-name
         .
      display f-supp-type-TH f-supp-code-TH f-supp-name-TH with frame d-utd .
      if c-type <> objSrv:Env:Utd:EDocType:AKT:KeyIntDB
      then
         disable r-supp-TH with frame d-utd .
      run enable_BUTTON .
   END.
ON value-changed OF R-error IN FRAME d-utd
   DO:
      assign R-error .
         if m-gds-code ne ? and m-gds-code ne "" then do:    if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else    if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else                          OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. end. else do: if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else  if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else                        OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      end.
   END.
ON value-changed OF R-error-2 IN FRAME d-utd
   DO:
      assign R-error-2 .
         if m-gds-code ne ? and m-gds-code ne "" then do:    if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else    if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else                          OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. end. else do: if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else  if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else                        OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      end.
   END.
ON value-changed OF f-num IN FRAME d-utd
   DO:
      assign f-num .
      display f-num with frame d-utd .
   END.
ON RETURN OF F-date IN FRAME d-utd
   DO:
      apply "TAB":U to self .
      return no-apply .
   END.
ON TAB OF F-date IN FRAME d-utd
   DO:
      assign f-date .
      display f-date with frame d-utd .
   END.
ON leave OF F-num IN FRAME d-utd
   DO:
      assign f-num .
      if f-date:SCREEN-VALUE <> "" and f-num:SCREEN-VALUE <> "" then
      do:
         find first ub.utd no-lock where ub.utd.DocumentNumber = f-num
            and ub.utd.DocumentDate = f-date
            and (   ub.utd.EDocType = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
                 or ub.utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                 )no-error .
         if AVAILABLE (ub.utd) then
         do:
            MESSAGE "Документ с № " + ub.utd.DocumentNumber + " от даты: " + string(ub.utd.DocumentDate) + " уже заведен в системе." skip
               VIEW-AS ALERT-BOX.
            return NO-APPLY .
         end.
      end.
      display f-num with frame d-utd .
   END.
ON leave OF F-date IN FRAME d-utd
   DO:
      assign f-date .
      if f-num:SCREEN-VALUE <> "" and f-num:SCREEN-VALUE <> ? then
      do:
         find first ub.utd no-lock where ub.utd.DocumentNumber = f-num
            and ub.utd.DocumentDate = f-date
            and (   ub.utd.EDocType = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
                 or ub.utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                 )no-error .
         if AVAILABLE (ub.utd) then
         do:
            MESSAGE "Документ с № " + ub.utd.DocumentNumber + " от даты: " + string(ub.utd.DocumentDate) + " уже заведен в системе." skip
               VIEW-AS ALERT-BOX.
            return NO-APPLY .
         end.
      end.
      display f-date with frame d-utd .
   END.
ON CHOOSE OF r-wrkr IN FRAME d-utd
   DO:
      run ref/cli-all.w (
         input parparentproc
         ,input "b-sel"
         ,input 'чел':U
         ,input 'все':U
         ,input 'текущие':U
         ,input ?
         ,input ",,,,,,NO,,"
         ,input ""
         ,output v-rid-list ) NO-ERROR.
      IF v-rid-list = '':U THEN RETURN NO-APPLY.
      FIND FIRST buf_clients NO-LOCK WHERE
         recid(buf_clients) = INTEGER(v-rid-list) NO-ERROR.
      IF NOT AVAILABLE buf_clients THEN RETURN NO-APPLY.
      ASSIGN
         f-wrkr    = buf_clients.obj-code
         wrkr-name = buf_clients.obj-name
         .
      display f-wrkr wrkr-name  with frame d-utd.
   END.
ON ENTRY OF v-mark IN FRAME d-utd
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
ON leave OF v-mark IN FRAME d-utd
   DO:
      v-mark = "" .
      if f-text <> "                       Просканируйте марку/штрих-код" then
      do:
         F-text = "" .
         f-text:screen-value = "" .
      end.
   END.
ON return OF v-mark IN FRAME d-utd
   DO:
      if  log-manager:logfile-name ne ?
      then do:
         def var speed as int64 no-undo.
         speed = etime.
         log-manager:write-message(substitute('Последовательность символов "&1" была просканирована за &2 мс',v-scan-str, speed), "ScanSpeed").
      end.
      if p-mode = 'ПРОСМОТР':U then
      do:
         v-mark:screen-value in frame d-utd = "" .
         v-mark = "" .
      end .
      if v-mark:screen-value in frame d-utd = ""
         then
      do:
         v-mark:screen-value in frame d-utd = v-scan-str.
      end.
      v-scan-str = "".
      assign
         v-mark = v-mark:screen-value in frame d-utd.
      if isMark(v-mark)
      then do:
         run save_mark .
      end.
      else do:
          run save_bar-code .
      end.
      IF  b_cleaggds:visible = yes
         THEN
      DO:
         apply "ENTRY" to br-utd IN FRAME d-utd.
         REturn no-apply.
      end.
   END.
ON any-printable OF v-mark IN FRAME d-utd
   do:
      run proc-any-key.
   end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-utd:PARENT eq ?
   THEN FRAME d-utd:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME d-utd
   do:
      APPLY "CLOSE":U TO THIS-PROCEDURE.
      if p-mode = 'ДОБАВЛЕНИЕ':U and available (buf_utd) then
      do:
         delete buf_utd .
      end.
   end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-utd :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
   mDiadocConnection = p-connect .
   Tree = ObjSrv:Lib:MarkingTree .
   Marking = ObjSrv:Env:Marking:Sts:Mark.
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
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_edi-doc_statchange':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output log-res-statch
    )  .
end.
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
    ,input  false
    ,output log-edi-doc_update
    )  .
end.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  'active=request'
  ,output v-obj-active
  )  .
   define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code).
   if EDOParSec:IsBarCode
      then v-barcode = yes .
   else v-barcode = no .
   run init-temp in this-procedure .
   if available (buf_utd) then
   do:
      assign
         frame d-utd:title = EdoTypeName(buf_utd.EDocType) + "_____№ " + string (buf_utd.DocumentNumber) + "_____" + p-mode.
   end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
   if EDOParSec:IsManual
   then v-manual = yes .
   else v-manual = no .
   run enable_UI in this-procedure .
   run enable_BUTTON in this-procedure .
   apply "entry" to v-mark in FRAME d-utd.
   on F9 of frame d-utd anywhere
      do:
         if not available X_utd-lines then  return no-apply.
         find first goods no-lock where goods.gds-code = X_utd-lines.gds-code .
         gds-rec = recid(goods) .
         run ref/gds-form.w
            (input  parParentProc
            ,input  'ПРОСМОТР':U
            ,input  v-cntxt-obj-type
            ,input  v-cntxt-obj-code
            ,input ?
            ,input-output gds-rec
            ).
         apply "entry" to br-utd in frame d-utd.
         return no-apply.
      end.
   b_cleaggds:visible in frame d-utd = no.
   m-gds-code:visible in frame d-utd = no.
   apply "VALUE-CHANGED" to br-utd IN frame d-utd.
   wait-for go of frame d-utd focus v-mark.
END.
run disable_UI in this-procedure .
PROCEDURE disable_UI :
   HIDE FRAME d-utd.
END PROCEDURE.
PROCEDURE enable_BUTTON :
   define buffer cancel_utd-marking-lines for ub.utd-marking-lines .
   define buffer cancel_utd-lines         for ub.utd-lines .
   define buffer x_utd-lines         for x_utd-lines .
   define buffer cancel_marking           for ub.marking .
   define variable v-write-cancel  as logical no-undo .
   define variable v-write-correct as logical no-undo .
   v-write-cancel = false .
   v-write-correct = false .
   for each x_utd-lines no-lock where x_utd-lines.doc-id = p-doc-id
                                               and x_utd-lines.db-num = p-db-num,
       each cancel_utd-marking-lines no-lock where cancel_utd-marking-lines.doc-id  = x_utd-lines.doc-id
                                               and cancel_utd-marking-lines.db-num  = x_utd-lines.db-num
                                               and cancel_utd-marking-lines.lineNum = x_utd-lines.lineNum,
      first cancel_marking no-lock where cancel_marking.mark = cancel_utd-marking-lines.mark
                                     and (    cancel_marking.sts = Marking:PendingVerification:KeyIntDB
                                           or cancel_marking.sts = Marking:DeliveryControl:KeyIntDB):
      v-write-cancel = true .
      leave .
   end.
   for each x_utd-lines no-lock where x_utd-lines.doc-id = p-doc-id
                                               and x_utd-lines.db-num = p-db-num,
       each cancel_utd-marking-lines no-lock where cancel_utd-marking-lines.doc-id  = x_utd-lines.doc-id
                                               and cancel_utd-marking-lines.db-num  = x_utd-lines.db-num
                                               and cancel_utd-marking-lines.lineNum = x_utd-lines.lineNum,
      first cancel_marking no-lock where cancel_marking.mark = cancel_utd-marking-lines.mark and cancel_marking.sts <> Marking:MarkError:KeyIntDB
      and cancel_marking.sts <> Marking:GrayZone:KeyIntDB:
      v-write-correct = true .
      leave .
   end.
   for each cancel_utd-lines where cancel_utd-lines.db-num eq p-db-num
      and cancel_utd-lines.doc-id eq p-doc-id
      no-lock:
      define variable vqnty as decimal no-undo.
      vqnty = decimal(GetAttrUtdlines(cancel_utd-lines.db-num,cancel_utd-lines.doc-id,cancel_utd-lines.linenum,"QuantityBarCode")).
      if vqnty > 0
         then
      do:
         v-write-correct = true .
         leave.
      end.
   end.
   if p-mode <> 'ПРОСМОТР':U then
   do:
      if (c-status < ObjSrv:Env:Utd:Sts:TH:SignatureRequired:KeyIntDB or
         c-status = ObjSrv:Env:Utd:Sts:TH:DeliveryCodeMismatch:KeyIntDB or
         c-status = ObjSrv:Env:Utd:Sts:TH:InconsistencyWithSupplyContract:KeyIntDB or
         c-status = ObjSrv:Env:Utd:Sts:TH:LinesInError:KeyIntDB or
         c-status = ObjSrv:Env:Utd:Sts:TH:LoadError:KeyIntDB )
         and
         (c-type = objSrv:Env:Utd:EDocType:UTD:KeyIntDB or
         c-type = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB)
         then
      do:
         enable
            b_deliv-cancel
            with frame d-utd .
      end.
      if c-status = ObjSrv:Env:Utd:Sts:TH:LoadError:KeyIntDB or
         c-status = ObjSrv:Env:Utd:Sts:TH:LackOfMarkingCodesInCirculation:KeyIntDB or
         c-status = ObjSrv:Env:Utd:Sts:TH:DeliveryCodeMismatch:KeyIntDB or
         c-status = ObjSrv:Env:Utd:Sts:TH:LinesInError:KeyIntDB or
         c-status = ObjSrv:Env:Utd:Sts:TH:InconsistencyWithSupplyContract:KeyIntDB then
      do:
         if f-contr-TH <> 0 and f-obj-code-TH <> 0 and f-supp-code-TH <> 0 then
         do:
            find first ub.utd-err-attr no-lock where ub.utd-err.db-num = p-db-num and ub.utd-err.doc-id = p-doc-id
               and (ub.utd-err.CodeErr = "NoSuppForId"
               or ub.utd-err.CodeErr = "NoFirmForId"
               or ub.utd-err.CodeErr = "NoContForFirmId"
               or ub.utd-err.CodeErr = "NoShopForKpp"
               or ub.utd-err.CodeErr = "NoEdoDoc"
               or ub.utd-err.CodeErr = "SpecifErr"
               or ub.utd-err.CodeErr = "ContrDate") no-error .
            if not available (ub.utd-err) then
            do:
               enable
                  b_back-check
                  with frame d-utd .
            end.
            else
            do:
               disable
                  b_back-check
                  with frame d-utd .
            end.
         end.
         else
         do:
            disable
               b_back-check
               with frame d-utd .
         end.
      end.
      case c-status:
         when ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB then
            do:
               enable
                  b_prov-finish
                  with frame d-utd .
            end.
         when ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB then
            do:
               enable
                  b_correct
                  b_write-cancel
                  b_prov-finish
                  with frame d-utd .
               if v-write-cancel then
               do:
                  DISABLE
                     b_correct
                     with frame d-utd .
               end.
            end.
         when ObjSrv:Env:Utd:Sts:TH:InconsistencyWithSupplyContract:KeyIntDB or
         when ObjSrv:Env:Utd:Sts:TH:LinesInError:KeyIntDB or
         when ObjSrv:Env:Utd:Sts:TH:LoadError:KeyIntDB then
            do:
               enable
                  b_correct
                  b_write-cancel
                  b_recheck
                  with frame d-utd .
               if v-write-cancel then
               do:
                  DISABLE
                     b_correct
                     with frame d-utd .
               end.
            end.
         when ObjSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB or
         when ObjSrv:Env:Utd:Sts:TH:RequiresAdjustment:KeyIntDB or
         when ObjSrv:Env:Utd:Sts:TH:LackOfMarkingCodesInCirculation:KeyIntDB or
         when ObjSrv:Env:Utd:Sts:TH:DeliveryCodeMismatch:KeyIntDB then
            do:
               enable
                  b_correct
                  b_write-cancel
                  with frame d-utd .
               if c-status = ObjSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB
               then
                  enable
                  b_recheck
                  with frame d-utd .
               if v-write-cancel then
               do:
                  DISABLE
                     b_correct
                     with frame d-utd .
               end.
            end.
         when ObjSrv:Env:Utd:Sts:TH:SignatureRequired:KeyIntDB then
            do:
               disable
                  b_write-cancel
                  with frame d-utd .
            end.
         otherwise
         do:
            display
               b_correct
               b_recheck
               b_write-cancel
               b_prov-finish
               with frame d-utd .
         end.
      end case .
      if c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
      then
      do:
         disable
            b_correct
            b_recheck
            b_write-cancel
            with frame d-utd .
      end.
      if c-type <> objSrv:Env:Utd:EDocType:Introduce:KeyIntDB then
      do:
         disable
            b_finish
            with frame d-utd .
      end.
      if c-type = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB then
      do:
         disable
            b_correct
            b_write-cancel
            with frame d-utd .
         if c-status <> ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB then
         do:
            enable
               b_finish
               with frame d-utd .
         end.
      end.
      if p-connect = ? then
      do:
         display
            b_correct
            b_recheck
            with frame d-utd .
      end.
      if not v-write-correct then
      do:
         disable
            b_correct
            with frame d-utd .
         enable
            b_deliv-cancel
         with frame d-utd .
      end.
   end.
   if v-cntxt-db-num <> 0 then
   do:
      disable
         b_write-cancel
         b_back-check
         b_correct
         with frame d-utd .
   end.
   if not v-obj-active then
   do:
      disable
         b_prov-finish
         with frame d-utd .
   end.
END PROCEDURE.
PROCEDURE enable_UI :
   p-type = c-type .
   display
      br-utd
      with frame d-utd .
      enable
         b_mark
         br-utd
         with frame d-utd .
   enable
      f-comment
      f-info
      a-n-c-name
      a-n-c
      b_error
      with frame d-utd .
   display
      f-comment-name
      f-info-name
      f-status-TH
      f-num-name
      f-date-name
      f-wrkr-name
      f-agnt-name
      f-boss-name
      with frame d-utd .
   if  p-type eq objSrv:Env:Utd:EDocType:returns:KeyIntDB
   then do:
      X_utd-lines.stts         :visible IN BROWSE br-utd = false.
      X_utd-lines.UnitCliQnty  :visible IN BROWSE br-utd = false.
   end.
   if mOrderItem <> "" then
   do:
     b-order:label = substitute("Заказ № &1", mOrderItem).
     enable
       b-order
       with frame d-utd .
   end.
   else
     hide
       b-order
       in frame d-utd .
   case p-mode:
      when 'ИЗМЕНЕНИЕ':U then
         do:
            if p-type <> objSrv:Env:Utd:EDocType:UTD:KeyIntDB and p-type <> objSrv:Env:Utd:EDocType:UCD:KeyIntDB and p-type <> objSrv:Env:Utd:EDocType:EDoc:KeyIntDB then
            do:
                  enable v-mark with frame d-utd.
                  display f-mark with frame d-utd .
               ENABLE
                  b-save
                  b-cancel
                  b-servis
                  f-obj-code-TH
                  f-obj-name-TH
                  f-obj-type-TH
                  R-TH
                  WITH FRAME d-utd.
               display
                  f-obj-name
                  with frame d-utd .
               hide
                  f-contr-TH
                  b-exit
                  f-contr-name
                  f-contr-name-TH
                  f-supp-code-TH
                  f-supp-name-TH
                  f-supp-type-TH
                  c-status-edi
                  r-contr-TH
                  r-supp-TH
                  RECT-1
                  in frame d-utd .
               display
                  c-type
                  with frame d-utd .
               if f-obj-type-TH <> "" then display r-obj-TH with frame d-utd .
               else enable r-obj-TH with frame d-utd .
            end.
            if p-type = objSrv:Env:Utd:EDocType:UTD:KeyIntDB or p-type = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB or p-type = objSrv:Env:UTD:EDocType:UCD:KeyIntDB then
            do:
               ENABLE
                  b-exit
                  b-save
                  b-servis
                  f-contr-TH
                  f-contr-name-TH
                  f-obj-code-TH
                  f-obj-name-TH
                  f-obj-type-TH
                  f-supp-code-TH
                  f-supp-name-TH
                  f-supp-type-TH
                  R-TH
                  WITH FRAME d-utd.
               hide
                  b-cancel
                  in frame d-utd .
               display
                  FILL-IN-1
                  c-type
                  FILL-IN-2
                  FILL-IN-3
                  c-status-edi
                  f-status-EDI
                  b_finish
                  with frame d-utd .
               if f-obj-type-TH <> "" then display r-obj-TH with frame d-utd .
               else enable r-obj-TH with frame d-utd .
               if f-supp-type-TH <> "" then display r-supp-TH with frame d-utd .
               else enable r-supp-TH with frame d-utd .
               if f-contr-TH <> ? and f-contr-TH <> 0 then display r-contr-TH with frame d-utd .
               else enable r-contr-TH with frame d-utd .
               if c-status = ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB then
               do:
                  for first X_utd-lines no-lock where X_utd-lines.stts <> "Проверен" :
                     F-text = "                        Просканируйте марку/штрих-код" .
                     f-text:screen-value = "" .
                     display F-text with frame d-utd .
                  end.
               end.
            end.
            if p-type = objSrv:Env:Utd:EDocType:returns:KeyIntDB then
            do:
               enable
                  b_anul
                  with frame d-utd .
            end.
            if p-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
            then
            do:
               ENABLE
                  b-save
                  b-cancel
                  b-servis
                  b_prov-finish
                  WITH FRAME d-utd.
               hide
                  b-exit
                  RECT-1
                  c-status-edi
                  f-status-edi
                  in frame d-utd .
               display
                  FILL-IN-1
                  FILL-IN-2
                  f-obj-code-TH
                  f-obj-name-TH
                  f-obj-type-TH
                  R-TH
                  c-type
                  f-contr-TH
                  f-contr-name-TH
                  f-supp-code-TH
                  f-supp-name-TH
                  f-supp-type-TH
                  r-contr-TH
                  f-num
                  f-num-name
                  f-date
                  f-date-name
                  r-supp-TH
                  with frame d-utd .
               disable
                  b_finish
                  b_correct
                  b_recheck
                  b_write-cancel
                  with frame d-utd .
            end.
            if p-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
            then
               menu-item m_check-akt:sensitive in menu POPUP-MENU-b-servis = no.
         end.
      when 'ПРОСМОТР':U then
         do:
            if p-type <> objSrv:Env:Utd:EDocType:UTD:KeyIntDB and  p-type <> objSrv:Env:Utd:EDocType:UCD:KeyIntDB and p-type <> objSrv:Env:Utd:EDocType:EDoc:KeyIntDB then
            do:
               ENABLE
                  b-cancel
                  WITH FRAME d-utd.
                  enable v-mark with frame d-utd.
                  display f-mark with frame d-utd .
               display
                  b_prov-finish
                  f-mark
                  b_correct
                  b_recheck
                  b_write-cancel
                  f-obj-code-TH
                  f-obj-name-TH
                  f-obj-type-TH
                  r-obj-TH
                  R-TH
                  b_finish
                  c-type
                  c-status
                  f-status-TH
                  b-servis
                  with frame d-utd .
               hide
                  f-contr-TH
                  b-exit
                  f-contr-name
                  f-contr-name-TH
                  f-supp-code-TH
                  f-supp-name-TH
                  f-supp-type-TH
                  r-contr-TH
                  b-save
                  r-supp-TH
                  c-status-edi
                  f-status-EDI
                  RECT-1
                  in frame d-utd .
            end.
            if p-type = objSrv:Env:Utd:EDocType:UTD:KeyIntDB or p-type = objSrv:Env:Utd:EDocType:UCD:KeyIntDB or p-type = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB then
            do:
               enable
                  b-exit
                  with frame d-utd .
                  enable v-mark with frame d-utd.
                  display f-mark with frame d-utd .
               display
                  b_prov-finish
                  b_correct
                  b_recheck
                  b_write-cancel
                  f-contr-TH
                  f-contr-name-TH
                  f-obj-code-TH
                  f-obj-name-TH
                  b_finish
                  f-obj-type-TH
                  f-supp-code-TH
                  f-supp-name-TH
                  b-save
                  f-supp-type-TH
                  c-status-edi
                  f-status-edi
                  r-contr-TH
                  r-obj-TH
                  r-supp-TH
                  R-TH
                  c-type
                  WITH FRAME d-utd.
               hide
                  b-save
                  b-cancel
                  in frame d-utd .
               display
                  FILL-IN-1
                  FILL-IN-2
                  FILL-IN-3
                  with frame d-utd .
            end.
            if p-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
            then
            do:
               ENABLE
                  b-save
                  b-cancel
                  b-servis
                  WITH FRAME d-utd.
               hide
                  b-exit
                  RECT-1
                  c-status-edi
                  f-status-edi
                  in frame d-utd .
               display
                  FILL-IN-1
                  FILL-IN-2
                  f-obj-code-TH
                  f-obj-name-TH
                  f-obj-type-TH
                  R-TH
                  c-type
                  f-contr-TH
                  f-contr-name-TH
                  f-supp-code-TH
                  f-supp-name-TH
                  f-supp-type-TH
                  r-contr-TH
                  f-num
                  f-num-name
                  f-date
                  f-date-name
                  r-supp-TH
                  with frame d-utd .
               disable
                  b_finish
                  b_correct
                  b_recheck
                  b_write-cancel
                  b_prov-finish
                  with frame d-utd .
            end.
         end.
      when 'ДОБАВЛЕНИЕ':U then
         do:
            if p-type = 0 then
            do:
               ENABLE
                  b-save
                  b-cancel
                  b-servis
                  f-obj-code-TH
                  f-obj-name-TH
                  f-obj-type-TH
                  R-TH
                  c-type
                  WITH FRAME d-utd.
               hide
                  f-contr-TH
                  b-exit
                  f-contr-name
                  f-contr-name-TH
                  f-supp-code-TH
                  f-supp-name-TH
                  f-supp-type-TH
                  r-contr-TH
                  r-supp-TH
                  v-mark
                  f-mark
                  RECT-1
                  c-status-edi
                  f-status-edi
                  in frame d-utd .
               if f-obj-type-TH <> "" then display r-obj-TH with frame d-utd .
               else enable r-obj-TH with frame d-utd .
            end.
            if p-type = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB then
            do:
                  enable v-mark with frame d-utd.
                  display f-mark with frame d-utd .
               ENABLE
                  b-save
                  b-cancel
                  b-servis
                  f-obj-code-TH
                  f-obj-name-TH
                  f-obj-type-TH
                  R-TH
                  c-type
                  WITH FRAME d-utd.
               hide
                  f-contr-TH
                  b-exit
                  f-contr-name
                  f-contr-name-TH
                  f-supp-code-TH
                  f-supp-name-TH
                  f-supp-type-TH
                  r-contr-TH
                  r-supp-TH
                  RECT-1
                  c-status-edi
                  f-status-edi
                  in frame d-utd .
               display f-mark with frame d-utd .
               if f-obj-type-TH <> "" then display r-obj-TH with frame d-utd .
               else enable r-obj-TH with frame d-utd .
            end.
            if p-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
            then
            do:
                  enable v-mark with frame d-utd.
                  display f-mark with frame d-utd .
               ENABLE
                  b-save
                  b-cancel
                  b-servis
                  f-obj-code-TH
                  f-obj-name-TH
                  f-obj-type-TH
                  R-TH
                  c-type
                  f-contr-TH
                  f-contr-name-TH
                  f-supp-code-TH
                  f-supp-name-TH
                  f-supp-type-TH
                  r-contr-TH
                  b_prov-finish
                  f-num
                  f-date
                  r-supp-TH
                  WITH FRAME d-utd.
               hide
                  b-exit
                  RECT-1
                  c-status-edi
                  f-status-edi
                  in frame d-utd .
               display
                  f-num-name
                  f-date-name
                  FILL-IN-1
                  FILL-IN-2
                  with frame d-utd .
               disable
                  b_finish
                  b_correct
                  b_recheck
                  b_write-cancel
                  with frame d-utd .
               if f-obj-type-TH <> "" then display r-obj-TH with frame d-utd .
               else enable r-obj-TH with frame d-utd .
            end.
         end.
   end case .
   if type_mark <> 1 then
   do:
      enable R-error-2 with frame d-utd .
      hide R-error in frame d-utd .
      if p-type <> objSrv:Env:Utd:EDocType:UTD:KeyIntDB then
      do:
         do:
            X_utd-lines.qnty-scan:visible IN BROWSE br-utd = false.
         end.
      end.
      hide
         v-mark
         in frame d-utd .
      if p-mode <> 'ПРОСМОТР':U and buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB and c-type <> 0 then
      do:
            enable v-mark with frame d-utd.
            display f-mark with frame d-utd .
      end.
      else
      do:
         hide
            v-mark
            f-mark
            in frame d-utd .
      end.
   end.
   else
   do:
      enable R-error with frame d-utd .
      hide R-error-2 in frame d-utd .
      if p-mode = 'ИЗМЕНЕНИЕ':U then
      do:
            enable v-mark with frame d-utd.
            display f-mark with frame d-utd .
         enable
            r-wrkr
            r-agnt
            r-boss
            f-wrkr
            f-agnt
            f-boss
            with frame d-utd .
         display
            f-wrkr-name
            f-agnt-name
            f-boss-name
            with frame d-utd .
      end.
   end.
   if p-type = objSrv:Env:Utd:EDocType:LK_RECEIPT:KeyIntDB
   then do :
      define variable brii as integer no-undo .
      do brii = 6 to 14 :
         browse br-utd:GET-BROWSE-COLUMN(brii):VISIBLE = no no-error.
      end .
      browse br-utd:GET-BROWSE-COLUMN(3):label = "GTIN" no-error .
      browse br-utd:GET-BROWSE-COLUMN(5):label = "Количество" no-error .
   end .
   if f-num-2 = "" then
   do:
      hide
         f-num-2
         f-num-name-2
         f-date-2
         f-date-name-2
         in frame d-utd .
   end.
   else
   do:
      display
         f-num-name-2
         f-date-name-2
         with frame d-utd .
   end.
   if f-total = 0 then
   do:
      hide
         f-total
         f-vat
         in frame d-utd .
   end.
   if log-res-statch then
   do:
      menu-item m_choose-status:sensitive in menu POPUP-MENU-b-servis = yes.
   end.
   else
   do:
      menu-item m_choose-status:sensitive in menu POPUP-MENU-b-servis = no.
   end.
   if log-edi-doc_update and c-status = ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB and g#db-num <> 0 then
   do:
      menu-item m_reset_row_data:sensitive in menu POPUP-MENU-b-servis = yes.
   end.
   else
   do:
      menu-item m_reset_row_data:sensitive in menu POPUP-MENU-b-servis = no.
   end.
   if not v-manual then
   do:
      v-mark:READ-ONLY IN FRAME d-utd        = TRUE .
   end.
   else do:
      v-mark:READ-ONLY IN FRAME d-utd        = false .
   end.
   apply "VALUE-CHANGED" to br-utd in frame d-utd.
END PROCEDURE.
PROCEDURE init-temp :
   define variable ii           as integer   no-undo .
   define variable Status_      as character no-undo .
   define variable StatusTH     as class     ibs.th.str.utd.sts.th   no-undo .
   define variable Status_EDI   as character no-undo .
   define variable StatusEDI    as class     ibs.th.str.utd.sts.edi  no-undo .
   define variable Type_        as character no-undo .
   define variable TypeTH       as class     ibs.th.str.utd.edoctype no-undo .
   define variable v-StatusName as character no-undo .
   Status_ = " " + chr(44) + '-1':U .
   StatusTH = ObjSrv:Env:Utd:Sts:TH.
   do ii = 1 to StatusTH:mapType:GetItemByLab(ii):
      Status_ = Status_ + chr(44) + StatusTH:CurrProp:Label_ + chr(44) + string(StatusTH:CurrProp:KeyIntDB) .
   end.
   ASSIGN
      c-status:LIST-ITEM-PAIRS  in frame d-utd = Status_ .
   Status_EDI = " " + chr(44) + '-1':U .
   StatusEDI = ObjSrv:Env:Utd:Sts:EDI.
   do ii = 1 to StatusEDI:mapType:GetItemByLab(ii):
      if StatusEDI:CurrProp:KeyIntDB = ObjSrv:Env:Utd:Sts:EDI:WithRecipientSignature:KeyIntDB then
      do:
         if available (buf_utd) then
         do:
            v-StatusName = StatusName(buf_utd.doc-id, buf_utd.db-num) .
            Status_EDI = Status_EDI + chr(44) + StatusEDI:CurrProp:Label_ + " " + v-StatusName + chr(44) + string(StatusEDI:CurrProp:KeyIntDB) .
         end.
         else
         do:
            Status_EDI = Status_EDI + chr(44) + StatusEDI:CurrProp:Label_ + chr(44) + string(StatusEDI:CurrProp:KeyIntDB) .
         end.
      end.
      else
      do:
         Status_EDI = Status_EDI + chr(44) + StatusEDI:CurrProp:Label_ + chr(44) + string(StatusEDI:CurrProp:KeyIntDB) .
      end.
   end.
   ASSIGN
      c-status-edi:LIST-ITEM-PAIRS  in frame d-utd = Status_EDI .
   Type_ = " " + chr(44) + '0':U .
   TypeTH = objSrv:Env:Utd:EDocType .
   do ii = 1 to TypeTH:mapType:GetItemByLab(ii):
      if p-mode = 'ДОБАВЛЕНИЕ':U then
      do:
         if TypeTH:CurrProp:KeyIntDB =  TypeTH:Introduce:KeyIntDB or TypeTH:CurrProp:KeyIntDB =  TypeTH:AKT:KeyIntDB then
         do:
            Type_ = Type_ + chr(44) + TypeTH:CurrProp:Label_ + chr(44) + string(TypeTH:CurrProp:KeyIntDB) .
         end.
      end.
      else
      do:
         Type_ = Type_ + chr(44) + TypeTH:CurrProp:Label_ + chr(44) + string(TypeTH:CurrProp:KeyIntDB) .
      end.
   end.
   ASSIGN
      c-type:LIST-ITEM-PAIRS  in frame d-utd = Type_ .
   if p-mode = 'ДОБАВЛЕНИЕ':U then
   do:
      if not available (buf_utd) then
      do:
         create buf_utd .
         assign
            buf_utd.DocumentDate = today
            buf_utd.sts          = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB
            buf_utd.obj-code     = v-cntxt-obj-code
            buf_utd.obj-type     = v-cntxt-obj-type
            buf_utd.host-code    = v-cntxt-host-code-obj
            .
         validate buf_utd .
      end.
   end.
   else
   do:
      if p-mode = 'ПРОСМОТР':U then find first buf_utd no-lock where buf_utd.doc-id = p-doc-id and buf_utd.db-num = p-db-num no-error .
      if p-mode = 'ИЗМЕНЕНИЕ':U then find first buf_utd exclusive-lock where buf_utd.doc-id = p-doc-id and buf_utd.db-num = p-db-num no-wait no-error .
      if  error-status:error then
      do:
         message "Документ занят другим пользователем"
            view-as alert-box.
         p-mode = 'ПРОСМОТР':U .
         find first buf_utd no-lock where buf_utd.doc-id = p-doc-id and buf_utd.db-num = p-db-num no-error .
      end.
   end.
   if available (buf_utd) then
   do:
      assign
         f-num           = buf_utd.DocumentNumber
         f-date          = buf_utd.DocumentDate
         f-contr-name    = buf_utd.BaseDocumentNumber
         f-contr-TH      = buf_utd.contract-code
         f-contr-name-TH = ContName(buf_utd.contract-code, buf_utd.host-code)
         c-status        = buf_utd.sts
         mflagscan       = yes
         .
      c-status-edi = buf_utd.sts-edi .
      assign
         f-obj-code-TH  = buf_utd.obj-code
         f-obj-type-TH  = buf_utd.obj-type
         f-obj-name-TH  = CliName(buf_utd.obj-code, buf_utd.obj-type)
         f-supp-code-TH = buf_utd.cli-code
         f-supp-type-TH = buf_utd.cli-type
         f-supp-name-TH = CliName(buf_utd.cli-code, buf_utd.cli-type)
         f-obj-name-2   = buf_utd.obj-info
         c-type         = buf_utd.EDocType
         f-total        = buf_utd.total
         f-vat          = buf_utd.vat
         v-pred-status  = buf_utd.sts
         f-comment      = buf_utd.comment
         .
      for first ub.utd no-lock where ub.utd.DocumentExt = buf_utd.parentDocumentExt and
         ub.utd.OrganizationExt = buf_utd.parentOrganizationExt and
         buf_utd.DocumentExt <> "" and buf_utd.parentDocumentExt <> "":
         if ub.utd.DocumentNumber <> buf_utd.documentNumber then
         do:
            f-num-2           = ub.utd.DocumentNumber .
            f-date-2          = ub.utd.DocumentDate .
            display
               f-num-2
               f-date-2
               with frame d-utd .
         end.
         else
         do:
            hide
               f-num-2
               f-date-2
               in frame d-utd .
         end.
      end.
      for each buf_utd-attr no-lock where buf_utd-attr.db-num = buf_utd.db-num and buf_utd-attr.doc-id = buf_utd.doc-id:
         case buf_utd-attr.attr-code:
            when "wrkr" then
               do:
                  f-wrkr = integer(buf_utd-attr.attr-value) .
                  wrkr-name = CliName(integer(buf_utd-attr.attr-value), 'чел':U) .
               end.
            when "agnt" then
               do:
                  f-agnt = integer(buf_utd-attr.attr-value) .
                  agnt-name = CliName(integer(buf_utd-attr.attr-value), 'чел':U) .
               end.
            when "boss" then
               do:
                  f-boss = integer(buf_utd-attr.attr-value) .
                  boss-name = CliName(integer(buf_utd-attr.attr-value), 'чел':U) .
               end.
            when "order-item" then
               do:
                  mOrderItem = buf_utd-attr.attr-value .
               end.
         end case .
      end.
      if buf_utd.sts-edi <> 0 then
      do:
      end.
      if buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB and (buf_utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB or buf_utd.EdocType = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB) then type_mark = 1 .
      else
      do:
         if c-status = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB then type_mark = 5 .
         else type_mark = 0 .
      end.
   end.
   if type_mark = 1 then
   do:
      R-error = 2 .
      display R-error with frame d-utd .
   end.
   display
      F-text
      f-num
      f-date
      f-contr-TH
      f-total
      f-vat
      f-contr-name-TH
      f-contr-name
      f-wrkr
      f-agnt
      f-boss
      wrkr-name
      agnt-name
      boss-name
      f-info
      c-type
      f-obj-name-2
      f-gruz
      c-status-edi
      c-status
      f-obj-code-TH
      f-obj-type-TH
      f-obj-name-TH
      f-supp-code-TH
      f-supp-type-TH
      f-supp-name-TH
      f-comment
      with frame d-utd.
   run mark-temp (?).
   if m-gds-code ne ? and m-gds-code ne "" then do:    if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else    if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else                          OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. end. else do: if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else  if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else                        OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      end.
END PROCEDURE.
PROCEDURE add-filter :
   define input  parameter idb-num   as integer no-undo.
   define input  parameter idoc-id   as integer no-undo.
   define input  parameter ilinenum  as integer no-undo.
   define input  parameter igds-code as character  no-undo.
   find first tt-utd-lines-filtr where tt-utd-lines-filtr.db-num   = idb-num
                                   and tt-utd-lines-filtr.doc-id   = idoc-id
                                   and tt-utd-lines-filtr.linenum  = ilinenum
                                   and tt-utd-lines-filtr.bar-code = igds-code
    no-lock no-error.
    if not available tt-utd-lines-filtr
    then do:
       create tt-utd-lines-filtr.
       assign
          tt-utd-lines-filtr.db-num   = idb-num
          tt-utd-lines-filtr.doc-id   = idoc-id
          tt-utd-lines-filtr.linenum  = ilinenum
          tt-utd-lines-filtr.bar-code = igds-code
       .
   end.
end.
PROCEDURE mark-temp :
   define input parameter iLine as integer no-undo.
   define buffer buf_marking           for ub.marking .
   define buffer buf_utd-marking-lines for ub.utd-marking-lines .
   define buffer buf_utd-lines-attr    for ub.utd-lines-attr .
   define buffer buf_goods             for ub.goods .
   define buffer buf_bar-code          for ub.bar-code .
   define buffer buf_marking-attr for ub.marking-attr.
   define variable v-db-num       as integer   no-undo .
   define variable v-doc-id       as integer   no-undo .
   define variable vType          as character no-undo .
   define variable vIsErrMark     as logical   no-undo .
   define variable vQntyScan      as decimal   no-undo .
   empty temp-table  tt-utd-lines-filtr.
   run add-filter(?  ,
                  ?  ,
                  ? ,
                  "нет товара").
   for each buf_utd-lines no-lock where
            buf_utd-lines.doc-id = buf_utd.doc-id and
            buf_utd-lines.db-num = buf_utd.db-num and
            (if iLine <> ? then buf_utd-lines.LineNum = iLine else true):
      find first X_utd-lines EXCLUSIVE-LOCK where buf_utd-lines.doc-id = X_utd-lines.doc-id and buf_utd-lines.db-num = X_utd-lines.db-num and buf_utd-lines.LineNum = X_utd-lines.LineNum no-error .
      buffer-copy buf_utd-lines to X_utd-lines .
      define variable vper as logical no-undo.
      getMarkUtdLine(buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum,
      output x_utd-lines.isMarking, output x_utd-lines.isArtic, output vper).
      X_utd-lines.isWeight = WeighedProd(X_utd-lines.gds-code).
      X_utd-lines.isVarWeight = WghProdVariable(buf_utd.obj-type, buf_utd.obj-code, X_utd-lines.gds-code).
      X_utd-lines.isSelect = logical(getAttrUtdLinesEx (buf_utd-lines.db-num,
                                                        buf_utd-lines.doc-id,
                                                        buf_utd-lines.LineNum,
                                                        "manual-selection",
                                                        "no")).
      if x_utd-lines.isMarking then
      do:
                         if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                    ( buf_utd-lines.gds-code,
                      'mark-type':U,
                       output x_utd-lines.markType,
                       output vtype
                    ).
      end.
      if not x_utd-lines.isArtic and not x_utd-lines.isMarking
      then do:
         run add-filter(buf_utd-lines.db-num  ,
                        buf_utd-lines.doc-id  ,
                        buf_utd-lines.LineNum ,
                        x_utd-lines.gds-code).
      end.
      else if x_utd-lines.isArtic
      then do:
         for each buf_utd-marking-lines  where buf_utd-marking-lines.db-num = buf_utd-lines.db-num and
                                               buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id and
                                               buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum
         no-lock:
            if  GetAttrUtdMarkingLinesEx
                    (buf_utd-marking-lines.db-num,
                     buf_utd-marking-lines.doc-id,
                     buf_utd-marking-lines.LineNum,
                     buf_utd-marking-lines.mark,
                     "AddMarkWeight",
                     "no") <> "yes"
            then do:
               run add-filter(buf_utd-marking-lines.db-num  ,
                              buf_utd-marking-lines.doc-id  ,
                              buf_utd-marking-lines.LineNum ,
                              getGtinBydm(buf_utd-marking-lines.mark)).
               if X_utd-lines.isWeight then X_utd-lines.PieceTTH = String(getQntyUTDByCodId(buf_utd-marking-lines.mark)).
            end.
         end.
      end.
      if buf_utd.EdocType = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB
      or (buf_utd.EdocType = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
          and not x_utd-lines.isMarking)
      then
      do:
         for first buf_utd-lines-attr no-lock where buf_utd-lines-attr.db-num = X_utd-lines.db-num and
            buf_utd-lines-attr.doc-id = X_utd-lines.doc-id and
            buf_utd-lines-attr.LineNum = X_utd-lines.LineNum and
            buf_utd-lines-attr.attr-code = "utd-fact-qnty":
            X_utd-lines.fact-qnty = integer(buf_utd-lines-attr.attr-value) .
         end.
      end.
      for first buf_utd-lines-attr no-lock where buf_utd-lines-attr.db-num = X_utd-lines.db-num and
         buf_utd-lines-attr.doc-id = X_utd-lines.doc-id and
         buf_utd-lines-attr.LineNum = X_utd-lines.LineNum and
         buf_utd-lines-attr.attr-code = "Quantity":
         X_utd-lines.UnitCliQnty = integer(buf_utd-lines-attr.attr-value) .
      end.
      if x_utd-lines.isMarking then do:
        for first buf_utd-lines-attr no-lock where buf_utd-lines-attr.db-num = X_utd-lines.db-num and
           buf_utd-lines-attr.doc-id = X_utd-lines.doc-id and
           buf_utd-lines-attr.LineNum = X_utd-lines.LineNum and
           buf_utd-lines-attr.attr-code = "QuantityBarCode":
           X_utd-lines.qnty-scan = decimal(buf_utd-lines-attr.attr-value) .
        end.
      end.
      else do:
        for first buf_utd-lines-attr no-lock where buf_utd-lines-attr.db-num = X_utd-lines.db-num and
           buf_utd-lines-attr.doc-id = X_utd-lines.doc-id and
           buf_utd-lines-attr.LineNum = X_utd-lines.LineNum and
           buf_utd-lines-attr.attr-code = "QuantityBarCode":
           X_utd-lines.qnty-scan = decimal(buf_utd-lines-attr.attr-value) .
        end.
        if X_utd-lines.isWeight then
        for first buf_utd-lines-attr no-lock where buf_utd-lines-attr.db-num = X_utd-lines.db-num and
           buf_utd-lines-attr.doc-id = X_utd-lines.doc-id and
           buf_utd-lines-attr.LineNum = X_utd-lines.LineNum and
           buf_utd-lines-attr.attr-code = "QuantityPiece":
           X_utd-lines.PieceFact = buf_utd-lines-attr.attr-value .
        end.
      end.
      for first buf_bar-code no-lock where buf_bar-code.gds-code = buf_utd-lines.gds-code and
         buf_bar-code.unit-cli = buf_utd-lines.UnitCode:
         X_utd-lines.Price = buf_utd-lines.Price / buf_bar-code.cli-base-rate .
      end.
      X_utd-lines.sts_err = CheckErrForLine(buffer X_utd-lines:handle).
      if not X_utd-lines.sts_err
      then do:
         X_utd-lines.DelivCodeMis = CheckErrForLineTypeCode (buffer X_utd-lines:handle,"CheckQnty","QntyMArk","warning",no).
         if not X_utd-lines.DelivCodeMis
         then do:
            block-war:
            for each buf_utd-marking-lines         where buf_utd-marking-lines.db-num = buf_utd-lines.db-num and
                                                         buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id and
                                                         buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum
            no-lock:
               X_utd-lines.DelivCodeMis = CheckTypeForMarkLineType(buffer utd-marking-lines:handle,"*","*","warning").
               if X_utd-lines.DelivCodeMis
               then
                  leave block-war.
            end.
         end.
      end.
      if x_utd-lines.isMarking then
      do:
         find first buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd-lines.db-num and
            buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id and
            buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum and
            buf_utd-marking-lines.sts = Marking:MarkError:KeyIntDB no-error .
         if available (buf_utd-marking-lines)
            then X_utd-lines.stts = "Ошибка статус марки" .
         else
         do:
            find first buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd-lines.db-num and
               buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id and
               buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum and
               buf_utd-marking-lines.doc-level = 1 and
               not can-do(Marking:EqualChecked,string(buf_utd-marking-lines.sts)) no-error .
            if available (buf_utd-marking-lines) then  X_utd-lines.stts = "Ожидает проверку" .
            else
            do:
               find first buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd-lines.db-num and
                  buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id and
                  buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum and
                  buf_utd-marking-lines.doc-level = 1 and
                  can-do(Marking:EqualChecked,string(buf_utd-marking-lines.sts)) no-error .
               if available (buf_utd-marking-lines) then do:
                   X_utd-lines.stts = "Проверен" .
               end.
            end.
         end.
         assign
           X_utd-lines.qnty-mark = 0
           X_utd-lines.qnty-scan = 0
         .
         for each buf_utd-marking-lines no-lock where
                  buf_utd-marking-lines.db-num  = buf_utd-lines.db-num
              and buf_utd-marking-lines.doc-id  = buf_utd-lines.doc-id
              and buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum
              and buf_utd-marking-lines.doc-level = 1
         :
           X_utd-lines.qnty-mark = X_utd-lines.qnty-mark + 1.
           if buf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB then
           do:
             find first buf_marking no-lock where
                        buf_marking.mark begins buf_utd-marking-lines.mark
             no-error.
             if available buf_marking then do:
                 if X_utd-lines.isWeight
                 then do:
                    X_utd-lines.qnty-scan = X_utd-lines.qnty-scan + MarkWeight(buf_marking.mark).
                 end.
                 else
                    X_utd-lines.qnty-scan = X_utd-lines.qnty-scan + buf_marking.box-qnty.
             end.
             else X_utd-lines.stts = "Ошибка статус марки" .
           end.
           else
           do:
              run calcQntyMarkByUnit in this-procedure(
                buf_utd-lines.db-num,
                buf_utd-lines.doc-id,
                buf_utd-lines.LineNum,
                buf_utd-marking-lines.mark,
                X_utd-lines.isWeight,
                output vQntyScan,
                output vIsErrMark).
              X_utd-lines.qnty-scan = X_utd-lines.qnty-scan + vQntyScan.
              if vIsErrMark then X_utd-lines.stts = "Ошибка статус марки" .
           end.
         end.
         find first buf_utd-lines-attr where
                    buf_utd-lines-attr.db-num = X_utd-lines.db-num and
                    buf_utd-lines-attr.doc-id = X_utd-lines.doc-id and
                    buf_utd-lines-attr.LineNum = X_utd-lines.LineNum and
                    buf_utd-lines-attr.attr-code = "QuantityBarCode"
              exclusive-lock no-error.
         if avail buf_utd-lines-attr then
         do:
            if X_utd-lines.qnty-scan <> 0 then
              buf_utd-lines-attr.attr-value = string(X_utd-lines.qnty-scan).
            else
              delete buf_utd-lines-attr.
         end.
         else do:
            if X_utd-lines.qnty-scan <> 0 then
            do:
               create buf_utd-lines-attr.
               assign
                  buf_utd-lines-attr.db-num     = X_utd-lines.db-num
                  buf_utd-lines-attr.doc-id     = X_utd-lines.doc-id
                  buf_utd-lines-attr.LineNum    = X_utd-lines.LineNum
                  buf_utd-lines-attr.attr-code  = "QuantityBarCode"
                  buf_utd-lines-attr.attr-value = string(X_utd-lines.qnty-scan) .
               .
            end.
         end.
      end.
      else
      do:
         if  not x_utd-lines.isMarking
         then do:
            if X_utd-lines.Quantity = X_utd-lines.qnty-scan
            then X_utd-lines.stts = "Проверен" .
            else X_utd-lines.stts = "Ожидает проверку" .
         end.
      end.
      X_utd-lines.gds-name = GdsName(X_utd-lines.gds-code) .
      X_utd-lines.taxRate_ = string(X_utd-lines.TaxRate) + " %" .
      if X_utd-lines.TaxRate = -1 then X_utd-lines.taxRate_ = "Без НДС" .
      if X_utd-lines.sts_err then X_utd-lines.stts = "Ошибка по строке" .
   end.
   for each X_utd-lines:
      if not CAN-FIND (ub.utd-lines where ub.utd-lines.db-num = X_utd-lines.db-num and ub.utd-lines.doc-id = X_utd-lines.doc-id and ub.utd-lines.LineNum = X_utd-lines.LineNum) then
         delete X_utd-lines .
   end.
END PROCEDURE.
PROCEDURE calcQntyMarkByUnit :
   define input  parameter iDbNum     as integer no-undo.
   define input  parameter iDocId     as integer no-undo.
   define input  parameter iLineNum   as integer no-undo.
   define input  parameter iMark      as character no-undo.
   define input  parameter iIsWeight  as logical no-undo.
   define output parameter oQntyScan  as decimal no-undo.
   define output parameter oIsErrMark as logical no-undo init false.
   define variable vIsErrMark     as logical   no-undo .
   define variable vQntyScan      as decimal   no-undo .
   define buffer buf_marking           for ub.marking.
   define buffer buf_utd-marking-lines for ub.utd-marking-lines .
   for each buf_marking no-lock where
            buf_marking.mark-parent begins iMark,
       first buf_utd-marking-lines no-lock where
             buf_utd-marking-lines.db-num  = iDbNum and
             buf_utd-marking-lines.doc-id  = iDocId and
             buf_utd-marking-lines.LineNum = iLineNum and
             buf_utd-marking-lines.mark    = buf_marking.mark
   :
     if buf_marking.unit-ext = "UNIT" then
     do:
       if     can-do(Marking:EqualChecked,string(buf_utd-marking-lines.sts))
       then do:
         if iIsWeight
         then do:
            oQntyScan = oQntyScan + MarkWeight(buf_marking.mark).
         end.
         else oQntyScan = oQntyScan + buf_marking.box-qnty.
       end.
     end .
     run calcQntyMarkByUnit in this-procedure(
         iDbNum,
         iDocId,
         iLineNum,
         buf_marking.mark,
         iIsWeight,
         output vQntyScan,
         output vIsErrMark).
     oQntyScan = oQntyScan + vQntyScan.
     if vIsErrMark then oIsErrMark = vIsErrMark.
   end.
END PROCEDURE.
PROCEDURE temp-mark :
   define input parameter p-id as integer no-undo .
   define buffer buf_marking for ub.marking .
   define buffer buf_marking-attr for ub.marking-attr.
   empty temp-table tt-marking-lines .
   define variable mQuery as handle    no-undo.
   define variable vqry   as character no-undo.
   create query mQuery.
   mQuery:set-buffers(buffer buf_utd-marking-lines:HANDLE).
   vqry = substitute("for each buf_utd-marking-lines no-lock where ~
                               buf_utd-marking-lines.db-num = &1 ~
                           and buf_utd-marking-lines.doc-id = &2 "
                           ,  p-db-num, p-doc-id).
   if p-id = 1
   then
      vqry = vqry + substitute (" and buf_utd-marking-lines.LineNum = &1",X_utd-lines.LineNum).
    mQuery:query-prepare(vqry).
    mQuery:query-open ().
    mQuery:get-first ().
    do while not mQuery:query-off-end:
       create tt-marking-lines .
       assign
          tt-marking-lines.gds-name  = GdsName(buf_utd-marking-lines.gds-code)
          tt-marking-lines.stts-utd  = StatusTHName(buf_utd-marking-lines.sts)
          tt-marking-lines.mark      = buf_utd-marking-lines.mark
          tt-marking-lines.gds-code  = buf_utd-marking-lines.gds-code
          tt-marking-lines.sts-utd   = buf_utd-marking-lines.sts
          tt-marking-lines.LineNum   = buf_utd-marking-lines.LineNum
          tt-marking-lines.db-num    = buf_utd-marking-lines.db-num
          tt-marking-lines.doc-id    = buf_utd-marking-lines.doc-id
          tt-marking-lines.doc-level = buf_utd-marking-lines.doc-level
          tt-marking-lines.site      = buf_utd-marking-lines.site
       .
       tt-marking-lines.isMark    = IsMark(tt-marking-lines.mark).
       tt-marking-lines.isWeight = WeighedProd(tt-marking-lines.gds-code).
       find first utd-marking-lines-attr where utd-marking-lines-attr.doc-id    eq buf_utd-marking-lines.doc-id
                                           and utd-marking-lines-attr.db-num    eq buf_utd-marking-lines.db-num
                                           and utd-marking-lines-attr.LineNum   eq buf_utd-marking-lines.LineNum
                                           and utd-marking-lines-attr.mark      eq buf_utd-marking-lines.mark
                                           and utd-marking-lines-attr.attr-code eq "box-qnty"
       no-lock no-error.
       if avail utd-marking-lines-attr
       then
          tt-marking-lines.box-qnty = dec(utd-marking-lines-attr.attr-value).
       if tt-marking-lines.isMark then
       do:
          for first buf_marking  where buf_marking.mark begins buf_utd-marking-lines.mark :
             assign
                tt-marking-lines.sts         = buf_marking.sts
                tt-marking-lines.unit        = buf_marking.unit
                tt-marking-lines.unit-ext    = buf_marking.unit-ext
                tt-marking-lines.box-qnty    = buf_marking.box-qnty  when tt-marking-lines.box-qnty eq 0 or tt-marking-lines.box-qnty eq ?
                tt-marking-lines.mark-parent = buf_marking.mark-parent
             .
             tt-marking-lines.stts        = StatusTHName(buf_marking.sts).
             tt-marking-lines.weight = if tt-marking-lines.isWeight then string(MarkWeight(buf_marking.mark)) else "".
          end.
       end.
       else
       do:
          tt-marking-lines.stts-utd = StatusTHName(Marking:Checked_:KeyIntDB) .
       end.
      mQuery:get-next ().
   end.
   delete object mQuery.
END PROCEDURE.
PROCEDURE check_mol :
   define output parameter p-ok as logical no-undo .
   define variable varchk-prs      as character no-undo .
   define variable varchk-prs-type as character no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'chk-prs'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output varchk-prs
  ,output varchk-prs-type
  ) no-error .
   if varchk-prs <> "no" then
   do:
      if f-agnt = 0 or f-agnt = ? then
      do:
         message "Не указан исполнитель " f-agnt view-as alert-box error.
         p-ok = false .
         return.
      end.
      if f-boss = 0 or f-boss = ? then
      do:
         message "Не указан менеджер " f-boss view-as alert-box error.
         p-ok = false .
         return.
      end.
      if f-wrkr = 0 or f-wrkr = ? then
      do:
         message "Не указан кладовщик " f-wrkr view-as alert-box error.
         p-ok = false .
         return.
      end.
      p-ok = true .
   end.
   else p-ok = true .
END PROCEDURE.
PROCEDURE save_mark :
   define variable v_list    as character no-undo .
   define variable ii        as integer   no-undo .
   define variable jj        as integer   no-undo .
   define variable v-marking as character no-undo .
   define buffer buf_parts                   for ub.parts .
   define buffer gray_marking                for ub.marking .
   define buffer bf_marking                  for ub.marking .
   define buffer gray_unit-marking           for ub.marking .
   define buffer gray_utd-marking-lines      for ub.utd-marking-lines .
   define buffer gray_unit_utd-marking-lines for ub.utd-marking-lines .
   define buffer buf_utd-lines-attr          for ub.utd-lines-attr .
   define buffer un_utd-marking-lines        for ub.utd-marking-lines .
   define buffer parent_marking              for ub.marking .
   define buffer parent_utd-marking-lines    for ub.utd-marking-lines .
   define buffer buf_goods-attr              for ub.goods-attr.
   define buffer buf_marking-attr            for ub.marking-attr.
   define VARIABLE v-qnty       as decimal   no-undo .
   define VARIABLE v-rowid      as rowid     no-undo .
   define VARIABLE v-tbl-name   as character no-undo .
   define variable v-ungroup_ok as logical   no-undo .
   define variable v-gds-code   as integer   no-undo.
   define variable vFlag        as logical   no-undo.
   define variable v-gds-fl-wt  as logical   no-undo.
   b_cleaggds:sensitive in frame d-utd = no.
   b_cleaggds:visible   in frame d-utd = no.
   m-gds-code:visible   in frame d-utd = no.
   F-text = "" .
   f-text:screen-value in frame d-utd = "" .
   v-GTIN = "" .
   m-gds-code = ? .
   ASSIGN
      v_list = 'Ё,Й,Ц,У,К,Е,Н,Г,Ш,Щ,З,Х,Ъ,Ф,Ы,В,А,П,Р,О,Л,Д,Ж,Э,Я,Ч,С,М,И,Т,Ь,Б,Ю':U .
   do ii = 1 to length (v-mark):
      if LOOKUP( SUBSTRING( v-mark, ii, 1 ), v_list )  > 1 then
      do:
         message "Не корректно считана акцизная марка, перед считыванием переключите клавиатуру на английскую раскладку."
            view-as alert-box.
         v-mark:screen-value in frame d-utd = "" .
         v-mark = "" .
         return no-apply.
      end.
   end.
   mMRCCode  = no.
   v-marking = GetCodeIdent(v-mark) .
  if v-mark <> v-marking then
  do:
    find first bf_marking exclusive-lock where bf_marking.mark begins v-marking no-error .
    if avail bf_marking and
       bf_marking.unit-ext = "LEVEL2" then
    do:
      v-marking = v-mark.
    end.
  end.
   if v-marking = "" or v-marking = ? then
   do:
      F-text = "Товар не найден. Если сканируете КМ транспортной или груп. упак., то просканировать КМ потребительской упак., или верните товар поставщику." .
      display F-text with frame d-utd.
      v-mark:screen-value = "" .
      v-mark = "" .
      return no-apply.
   end.
   if p-type = objSrv:Env:Utd:EDocType:UTD:KeyIntDB then
   do:
      find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark begins v-marking and buf_utd-marking-lines.db-num = p-db-num
         and buf_utd-marking-lines.doc-id = buf_utd.doc-id no-error .
      if available (buf_utd-marking-lines) then
      do:
         run checkEMRC(v-mark, output vFlag).
         if not vFlag
         then do:
            F-text = "МРЦ на упаковке меньше ЕМЦ. Приемка товара запрещена." .
            display F-text with frame d-utd.
            v-mark:screen-value = "" .
            v-mark = "" .
            return no-apply.
         end.
         if CheckErrForMarkLine(buffer buf_utd-marking-lines:handle)
         then do:
            F-text = "Товар не подлежит приемке, т.к. не прошел проверку на корректность" .
               display F-text with frame d-utd.
               v-mark:screen-value = "" .
               v-mark = "" .
               return no-apply.
         end.
         for first buf_marking no-lock where
                   buf_marking.mark = buf_utd-marking-lines.mark and buf_marking.sts = Marking:Ungrouped:KeyIntDB
         :
            if isSaleMarkInUpak(buf_marking.mark) then
              F-text = "Марка уже проверена, просканируйте другую.".
            else
              F-text = substitute(
                "&1 упаковка разгруппирована, просканируйте марку &2 упаковки.",
                if buf_marking.unit-ext = "LEVEL1" then "Групповая" else "Транспортная",
                if buf_marking.unit-ext = "LEVEL1" then "потребительской" else "групповой").
            display F-text with frame d-utd.
            v-mark:screen-value = "" .
            v-mark = "" .
            return no-apply.
         end.
         find first X_utd-lines exclusive-lock where X_utd-lines.LineNum = buf_utd-marking-lines.LineNum no-error .
         if available (X_utd-lines) then
         do:
            if X_utd-lines.sts_err then
            do:
               F-text = "Товар не подлежит приемке, т.к. не прошел проверку на корректность" .
               display F-text with frame d-utd.
               v-mark:screen-value = "" .
               v-mark = "" .
               return no-apply.
            end.
            if can-do(Marking:EqualChecked,string(buf_utd-marking-lines.sts)) then
            do:
               F-text = "Марка уже проверена, просканируйте следующую" .
               display F-text with frame d-utd.
               v-mark:screen-value = "" .
               v-mark = "" .
               return no-apply.
            end.
            else
            do:
               if can-find (buf_marking where buf_marking.mark = buf_utd-marking-lines.mark and buf_marking.sts = Marking:MarkError:KeyIntDB)
                  then
               do:
                  F-text = "Товар не подлежит приемке, т.к. не прошел проверку на корректность" .
                  display F-text with frame d-utd.
                  v-mark:screen-value = "" .
                  v-mark = "" .
                  return no-apply.
               end.
               if can-find (buf_marking where buf_marking.mark = buf_utd-marking-lines.mark and buf_marking.sts = Marking:GrayZone:KeyIntDB)
                  then
               do:
                  empty temp-table tt-marking-lines .
                  for first gray_utd-marking-lines no-lock where gray_utd-marking-lines.db-num = X_utd-lines.db-num and gray_utd-marking-lines.doc-id = X_utd-lines.doc-id
                     and gray_utd-marking-lines.LineNum = X_utd-lines.LineNum and gray_utd-marking-lines.mark = buf_utd-marking-lines.mark:
                     for first gray_marking no-lock where gray_marking.mark = buf_utd-marking-lines.mark :
                        create tt-marking-lines .
                        assign
                           tt-marking-lines.gds-name    = GdsName(gray_utd-marking-lines.gds-code)
                           tt-marking-lines.stts-utd    = StatusTHName(gray_utd-marking-lines.sts)
                           tt-marking-lines.stts        = StatusTHName(gray_marking.sts)
                           tt-marking-lines.mark        = gray_marking.mark
                           tt-marking-lines.mark-parent = gray_marking.mark-parent
                           tt-marking-lines.gds-code    = gray_utd-marking-lines.gds-code
                           tt-marking-lines.sts         = gray_marking.sts
                           tt-marking-lines.sts-utd     = gray_utd-marking-lines.sts
                           tt-marking-lines.unit        = gray_marking.unit
                           tt-marking-lines.box-qnty    = gray_marking.box-qnty
                           tt-marking-lines.LineNum     = gray_utd-marking-lines.LineNum
                           tt-marking-lines.db-num      = gray_utd-marking-lines.db-num
                           tt-marking-lines.doc-id      = gray_utd-marking-lines.doc-id
                           tt-marking-lines.doc-level   = gray_utd-marking-lines.doc-level
                           .
                     end.
                     for each gray_unit-marking no-lock where gray_unit-marking.mark-parent = gray_utd-marking-lines.mark:
                        for first gray_unit_utd-marking-lines no-lock where gray_unit_utd-marking-lines.db-num = X_utd-lines.db-num and gray_unit_utd-marking-lines.doc-id = X_utd-lines.doc-id
                           and gray_unit_utd-marking-lines.LineNum = X_utd-lines.LineNum and gray_unit_utd-marking-lines.mark = gray_unit-marking.mark:
                           create tt-marking-lines .
                           assign
                              tt-marking-lines.gds-name    = GdsName(gray_unit_utd-marking-lines.gds-code)
                              tt-marking-lines.stts-utd    = StatusTHName(gray_unit_utd-marking-lines.sts)
                              tt-marking-lines.stts        = StatusTHName(gray_unit-marking.sts)
                              tt-marking-lines.mark        = gray_unit-marking.mark
                              tt-marking-lines.mark-parent = gray_unit-marking.mark-parent
                              tt-marking-lines.gds-code    = gray_unit_utd-marking-lines.gds-code
                              tt-marking-lines.sts         = gray_unit-marking.sts
                              tt-marking-lines.sts-utd     = gray_unit_utd-marking-lines.sts
                              tt-marking-lines.unit        = gray_unit-marking.unit
                              tt-marking-lines.unit-ext    = gray_unit-marking.unit-ext
                              tt-marking-lines.box-qnty    = gray_unit-marking.box-qnty
                              tt-marking-lines.LineNum     = gray_unit_utd-marking-lines.LineNum
                              tt-marking-lines.db-num      = gray_unit_utd-marking-lines.db-num
                              tt-marking-lines.doc-id      = gray_unit_utd-marking-lines.doc-id
                              tt-marking-lines.doc-level   = gray_unit_utd-marking-lines.doc-level
                              .
                        end.
                     end.
                  end.
                  run str/mark_browse.w (input parparentproc,
                     input-output table tt-marking-lines by-reference,
                     input p-mode,
                     input "Марки по товару " + string(X_utd-lines.gds-code) + " " + GdsName(X_utd-lines.gds-code) + " со статусом: " + StatusTHName(Marking:GrayZone:KeyIntDB),
                     input 6,
                     input ""
                     ) no-error .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-utd :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
               end.
               else
               do:
                  if buf_utd-marking-lines.doc-level > 1 then
                  do:
                        find first ub.marking where ub.marking.mark = buf_utd-marking-lines.mark no-lock no-error.
                        if avail ub.marking and ub.marking.mark-parent <> "" then
                          find first parent_marking no-lock where
                                     parent_marking.mark = ub.marking.mark-parent no-error.
                        if not avail parent_marking or parent_marking.sts <> Marking:Ungrouped:KeyIntDB
                        then do:
                          F-text = "            Марка входит в состав упаковки, просканируйте марку упаковки" .
                          display F-text with frame d-utd.
                          v-mark:screen-value = "" .
                          v-mark = "" .
                          return no-apply.
                        end.
                  end.
                     if X_utd-lines.isMarking
                     then do:
                        define variable vCheck as logical no-undo init yes.
                        do:
                           for first bf_utd-marking-lines exclusive-lock where bf_utd-marking-lines.mark = buf_utd-marking-lines.mark and bf_utd-marking-lines.db-num = buf_utd-marking-lines.db-num and
                              bf_utd-marking-lines.doc-id = buf_utd-marking-lines.doc-id:
                                 find first buf_marking where buf_marking.mark eq bf_utd-marking-lines.mark no-lock no-error.
                              if     available buf_marking
                                 and buf_marking.sts ne ObjSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
                                 and buf_marking.sts ne ObjSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB
                                 and buf_marking.sts ne ObjSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB
                                 and buf_marking.sts ne ObjSrv:Env:Marking:Sts:Mark:SaleWaitLock:KeyIntDB
                              then do:
                                 if X_utd-lines.isWeight
                                 then do:
                                       find first buf_marking-attr where buf_marking-attr.mark eq buf_utd-marking-lines.mark
                                                                     and buf_marking-attr.attr-code eq "weight"
                                       no-lock no-error.
                                       if avail buf_marking-attr
                                       then
                                       MESSAGE "Масса товара равна "
                                          (if decimal(buf_marking-attr.attr-value) < 1  and decimal(buf_marking-attr.attr-value) >= 0
                                              then string(decimal(buf_marking-attr.attr-value),"9.999")
                                              else buf_marking-attr.attr-value)
                                          X_utd-lines.UnitCode "?"
                                          VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                                          TITLE "" UPDATE lChoice AS LOGICAL.
                                       if lChoice then do:
                                           bf_utd-marking-lines.sts   = Marking:Checked_:KeyIntDB .
                                           if tree:LevelDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then
                                           do:
                                              vCheck = tree:StatusDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num, Marking:Checked_:KeyIntDB) .
                                           end.
                                       end.
                                       else do:
                                           MESSAGE "Масса товара не совпадает с данными из ГИС МТ. Товар не подлежит приемке"
                                           VIEW-AS ALERT-BOX.
                                       end.
                                 end.
                                 else do:
                                     bf_utd-marking-lines.sts   = Marking:Checked_:KeyIntDB .
                                     if tree:LevelDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then
                                     do:
                                        vCheck = tree:StatusDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num, Marking:Checked_:KeyIntDB) .
                                     end.
                                 end.
                                 tree:StatusUpUTD(
                                    buf_marking.mark-parent,
                                    buf_utd-marking-lines.db-num,
                                    buf_utd-marking-lines.doc-id,
                                    Marking:Checked_:KeyIntDB
                                 ).
                              end.
                              else do:
                                 empty temp-table tt-marking-lines .
                                 for first gray_utd-marking-lines no-lock where gray_utd-marking-lines.db-num = X_utd-lines.db-num and gray_utd-marking-lines.doc-id = X_utd-lines.doc-id
                                    and gray_utd-marking-lines.LineNum = X_utd-lines.LineNum and gray_utd-marking-lines.mark = buf_utd-marking-lines.mark:
                                    for first gray_marking no-lock where gray_marking.mark = buf_utd-marking-lines.mark :
                                       create tt-marking-lines .
                                       assign
                                          tt-marking-lines.gds-name    = GdsName(gray_utd-marking-lines.gds-code)
                                          tt-marking-lines.stts-utd    = StatusTHName(gray_utd-marking-lines.sts)
                                          tt-marking-lines.stts        = StatusTHName(gray_marking.sts)
                                          tt-marking-lines.mark        = gray_marking.mark
                                          tt-marking-lines.mark-parent = gray_marking.mark-parent
                                          tt-marking-lines.gds-code    = gray_utd-marking-lines.gds-code
                                          tt-marking-lines.sts         = gray_marking.sts
                                          tt-marking-lines.sts-utd     = gray_utd-marking-lines.sts
                                          tt-marking-lines.unit        = gray_marking.unit
                                          tt-marking-lines.box-qnty    = gray_marking.box-qnty
                                          tt-marking-lines.LineNum     = gray_utd-marking-lines.LineNum
                                          tt-marking-lines.db-num      = gray_utd-marking-lines.db-num
                                          tt-marking-lines.doc-id      = gray_utd-marking-lines.doc-id
                                          tt-marking-lines.doc-level   = gray_utd-marking-lines.doc-level
                                          .
                                    end.
                                    for each gray_unit-marking no-lock where gray_unit-marking.mark-parent = gray_utd-marking-lines.mark:
                                       for first gray_unit_utd-marking-lines no-lock where gray_unit_utd-marking-lines.db-num = X_utd-lines.db-num and gray_unit_utd-marking-lines.doc-id = X_utd-lines.doc-id
                                          and gray_unit_utd-marking-lines.LineNum = X_utd-lines.LineNum and gray_unit_utd-marking-lines.mark = gray_unit-marking.mark:
                                          create tt-marking-lines .
                                          assign
                                             tt-marking-lines.gds-name    = GdsName(gray_unit_utd-marking-lines.gds-code)
                                             tt-marking-lines.stts-utd    = StatusTHName(gray_unit_utd-marking-lines.sts)
                                             tt-marking-lines.stts        = StatusTHName(gray_unit-marking.sts)
                                             tt-marking-lines.mark        = gray_unit-marking.mark
                                             tt-marking-lines.mark-parent = gray_unit-marking.mark-parent
                                             tt-marking-lines.gds-code    = gray_unit_utd-marking-lines.gds-code
                                             tt-marking-lines.sts         = gray_unit-marking.sts
                                             tt-marking-lines.sts-utd     = gray_unit_utd-marking-lines.sts
                                             tt-marking-lines.unit        = gray_unit-marking.unit
                                             tt-marking-lines.unit-ext    = gray_unit-marking.unit-ext
                                             tt-marking-lines.box-qnty    = gray_unit-marking.box-qnty
                                             tt-marking-lines.LineNum     = gray_unit_utd-marking-lines.LineNum
                                             tt-marking-lines.db-num      = gray_unit_utd-marking-lines.db-num
                                             tt-marking-lines.doc-id      = gray_unit_utd-marking-lines.doc-id
                                             tt-marking-lines.doc-level   = gray_unit_utd-marking-lines.doc-level
                                             .
                                       end.
                                    end.
                                 end.
                                 run str/mark_browse.w (input parparentproc,
                                    input-output table tt-marking-lines by-reference,
                                    input p-mode,
                                    input "Марки по товару " + string(X_utd-lines.gds-code) + " " + GdsName(X_utd-lines.gds-code) + " имеют ошибки. " ,
                                    input 7,
                                    input ""
                                    ) no-error .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-utd :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
                           end.
                           end.
                        end.
                        define variable v-q as decimal no-undo.
                        v-q = ObjSrv:Lib:MarkingTree:GetQntyCheckMark(buf_utd-marking-lines.db-num, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.LineNum).
                        SetAttrUtdlines(buf_utd-marking-lines.db-num,buf_utd-marking-lines.doc-id,buf_utd-marking-lines.linenum,"QuantityBarCode",string(v-q)).
                     end.
                     else if X_utd-lines.isArtic
                     then do:
                        b_cleaggds:sensitive = yes.
                        b_cleaggds:visible = yes.
                        m-gds-code:visible = yes.
                        F-text:screen-value = "               Введите количество или просканируйте другой штрих-код" .
                        m-gds-code = getGTINBydm(v-mark).
                        m-gds-code:screen-value = string(v-gds-code).
                        if m-gds-code ne ? and m-gds-code ne "" then do:    if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else    if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else                          OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. end. else do: if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else  if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else                        OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      end.
                        reposition br-utd to recid recid_utd no-error .
                        apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
                        v-mark:screen-value = "" .
                        v-mark = "" .
                     end.
                     else do:
                        b_cleaggds:sensitive = yes.
                        b_cleaggds:visible = yes.
                        m-gds-code:visible = yes.
                        F-text:screen-value = "               Введите количество или просканируйте другой штрих-код" .
                        m-gds-code = string(getgdscodeBydm(v-mark)).
                        m-gds-code:screen-value = string(v-gds-code).
                        if m-gds-code ne ? and m-gds-code ne "" then do:    if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else    if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else                          OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. end. else do: if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else  if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else                        OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      end.
                        reposition br-utd to recid recid_utd no-error .
                        apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
                        v-mark:screen-value = "" .
                        v-mark = "" .
                     end.
               end.
            end.
            run mark-temp (?).
            find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark begins v-marking and buf_utd-marking-lines.db-num = p-db-num
               and buf_utd-marking-lines.doc-id = buf_utd.doc-id
               no-error .
            if available (buf_utd-marking-lines) then
            do:
               find first X_utd-lines exclusive-lock where X_utd-lines.LineNum = buf_utd-marking-lines.LineNum no-error .
               if available (X_utd-lines) then
                  recid_utd = recid (X_utd-lines) .
            end.
            else
            do:
               find first X_utd-lines exclusive-lock where X_utd-lines.LineNum = 1 no-error .
               if available (X_utd-lines) then
                  recid_utd = recid (X_utd-lines) .
            end.
            br-utd :refresh() no-error.
            reposition br-utd to recid recid_utd no-error .
            v-mark:screen-value = "" .
            v-mark = "" .
         end.
      end.
      else
      do:
         find first buf_utd-marking-lines no-lock where
                buf_utd-marking-lines.mark   begins v-marking
            and buf_utd-marking-lines.db-num = p-db-num
            and buf_utd-marking-lines.doc-id <> p-doc-id no-error .
         if available buf_utd-marking-lines
         then
            find first buf_marking where buf_marking.mark eq buf_utd-marking-lines.mark no-lock no-error.
         if available (buf_utd-marking-lines)
            and available buf_marking
            and (    buf_marking.sts eq ObjSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB
                 or buf_marking.sts eq ObjSrv:Env:Marking:Sts:Mark:ReturnLock:KeyIntDB
                 or buf_marking.sts eq ObjSrv:Env:Marking:Sts:Mark:SaleWaitLock:KeyIntDB
                 or buf_marking.sts eq ObjSrv:Env:Marking:Sts:Mark:ReturnWaitLock:KeyIntDB
                 or buf_marking.sts eq ObjSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB)
         then
         do:
            F-text = "             Товар поставлен на АЗС ранее, верните его на склад" .
            display F-text with frame d-utd.
            v-mark:screen-value = "" .
            v-mark = "" .
            return no-apply.
         end.
         else
         do:
            m-gds-code = getgtinBydm(v-mark).
            find first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code
            no-lock no-error.
            if available tt-utd-lines-filtr
            then do:
               if WghProdVariable(buf_utd.obj-type, buf_utd.obj-code, getGdsCodeByGtin(m-gds-code))
               then do:
                  run add-mark-weight (v-mark,
                                       m-gds-code,
                                       buf_utd.doc-id,
                                       buf_utd.db-num,
                                       output recid_utd,
                                       output F-text) .
                  v-gds-code = ?.
                  m-gds-code = ?.
                  if recid_utd = ? then do:
                       display F-text with frame d-utd.
                       v-mark:screen-value = "" .
                       v-mark = "" .
                       return no-apply.
                  end.
               end.
               else do:
                   b_cleaggds:sensitive = yes.
                   b_cleaggds:visible = yes.
                   m-gds-code:visible = yes.
                   F-text:screen-value = "               Введите количество или просканируйте другой штрих-код" .
                   m-gds-code:screen-value = m-gds-code.
               end.
               if m-gds-code ne ? and m-gds-code ne "" then do:    if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else    if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else                          OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. end. else do: if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else  if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else                        OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      end.
               reposition br-utd to recid recid_utd no-error .
               apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
               v-mark:screen-value = "" .
               v-mark = "" .
               return no-apply.
            end.
            else do:
               v-gds-code = ?.
               m-gds-code = ?.
               F-text = "Товар не найден. Если сканируете КМ транспортной или груп. упак., то просканировать КМ потребительской упак., или верните товар поставщику." .
               display F-text with frame d-utd.
               v-mark:screen-value = "" .
               v-mark = "" .
               return no-apply.
            end.
         end.
      end.
   end.
   if
           p-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
       and buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB then
   do:
      if f-obj-type-th = "" then
      do:
         message "Не выбран объект"
            view-as alert-box.
         v-mark:screen-value = "" .
         v-mark = "" .
         return no-apply .
      end.
      if c-type = 0 then
      do:
         message "Не выбран тип документа"
            view-as alert-box.
         v-mark:screen-value = "" .
         v-mark = "" .
         return no-apply .
      end.
      if CAN-FIND (first buf_utd-marking-lines where buf_utd-marking-lines.mark begins v-marking and buf_utd-marking-lines.db-num = buf_utd.db-num
         and buf_utd-marking-lines.doc-id = buf_utd.doc-id ) then
      do:
         F-text = "                        Марка уже просканирована в этом документе " .
         display F-text with frame d-utd.
         v-mark:screen-value = "" .
         v-mark = "" .
         return.
      end.
      for first buf_marking no-lock where buf_marking.mark begins v-marking and buf_marking.sts > Marking:UnknowSts:KeyIntDB:
         if buf_marking.loc-key begins "utd" then
         do:
            run gen-row-keyr in this-procedure (
               input buf_marking.loc-key
               ,input ?
               ,input "ub"
               ,input ?
               ,input no-lock
               ,output v-rowid
               ,output v-tbl-name ) .
            if v-rowid <> ? then
            do:
               find first ub.utd no-lock where rowid(ub.utd) = v-rowid no-error .
               F-text = "               Найдено УПД " + string(ub.utd.DocumentNumber) + " на поставку данной марки. Марка не может быть принята по Акту" .
            end.
            else  F-text = "               Марка не может быть принята по Акту. Заблокирована" + buf_marking.loc-key .
            display F-text with frame d-utd.
            v-mark:screen-value = "" .
            v-mark = "" .
            return.
         end.
         if buf_marking.loc-key <> ""
            or buf_marking.sts = Marking:Reserved:KeyIntDB
            or buf_marking.sts = Marking:FreeZone:KeyIntDB
            or buf_marking.sts = Marking:Checked_:KeyIntDB
            or buf_marking.sts = Marking:Ungrouped:KeyIntDB then
         do:
            F-text = "        Марка зарегистрирована в системе. Статус марки " +  StatusTHName(buf_marking.sts).
            display F-text with frame d-utd.
            v-mark:screen-value = "" .
            v-mark = "" .
            return.
         end.
      end.
      v-GTIN = getGtinByDM(v-marking) .
      if v-GTIN <> "" or c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB then
      do:
         v-gds-code = getGdsCodeByGtin(v-GTIN) .
         find first buf_goods no-lock where buf_goods.gds-code = v-gds-code no-error .
         if available (buf_goods) or c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB then
         do:
            find first buf_utd-lines where buf_utd-lines.doc-id = buf_utd.doc-id and buf_utd-lines.db-num = buf_utd.db-num
               and buf_utd-lines.gds-code = int(v-gds-code) no-error .
            if not available (buf_utd-lines) then
            do:
               find last X_utd-lines no-lock no-error .
               if not available (X_utd-lines) then jj = 0 .
               else jj = X_utd-lines.LineNum .
               create buf_utd-lines .
               assign
                  buf_utd-lines.GdsName  = GdsName(v-gds-code)
                  buf_utd-lines.db-num   = buf_utd.db-num
                  buf_utd-lines.doc-id   = buf_utd.doc-id
                  buf_utd-lines.LineNum  = jj + 1
                  buf_utd-lines.gds-code = v-gds-code
                  buf_utd-lines.sts      = ObjSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB .
               buf_utd-lines.UnitCode = if available (buf_goods) then buf_goods.unit-base else ""
                  .
               create  X_utd-lines .
               buffer-copy buf_utd-lines to X_utd-lines .
               assign
                  X_utd-lines.stts = StatusTHName(buf_utd-lines.sts).
               X_utd-lines.gds-name = GdsName(v-gds-code).
               X_utd-lines.isMarking = CheckMarkUtdline(buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum).
               X_utd-lines.isArtic   = logical(getAttrUtdLinesEx (buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum,"ArticUtdLine","yes")).
               for each buf_parts no-lock where  buf_parts.artic = buf_goods.artic and
                  buf_parts.prod-code = buf_goods.prod-code and
                  buf_parts.prod-type = buf_goods.prod-type and
                  buf_parts.out-code = 'free-zone':U and
                  buf_parts.obj-code = buf_utd.obj-code and
                  buf_parts.obj-type = buf_utd.obj-type :
                  X_utd-lines.fact-qnty = X_utd-lines.fact-qnty + buf_parts.fact-qnty .
               end.
               find first buf_utd-lines-attr exclusive-lock where buf_utd-lines-attr.db-num = X_utd-lines.db-num and
                  buf_utd-lines-attr.doc-id = X_utd-lines.doc-id and
                  buf_utd-lines-attr.LineNum = X_utd-lines.LineNum and
                  buf_utd-lines-attr.attr-code = "utd-fact-qnty" no-error .
               if not available (buf_utd-lines-attr) then
               do:
                  create buf_utd-lines-attr .
                  assign
                     buf_utd-lines-attr.db-num    = X_utd-lines.db-num
                     buf_utd-lines-attr.doc-id    = X_utd-lines.doc-id
                     buf_utd-lines-attr.LineNum   = X_utd-lines.LineNum
                     buf_utd-lines-attr.attr-code = "utd-fact-qnty"
                     .
               end.
               buf_utd-lines-attr.attr-value = string(X_utd-lines.fact-qnty) .
            end.
            recid_utd = recid(X_utd-lines) .
            create buf_utd-marking-lines .
            assign
               buf_utd-marking-lines.db-num    = buf_utd.db-num
               buf_utd-marking-lines.doc-id    = buf_utd.doc-id
               buf_utd-marking-lines.gds-code  = buf_utd-lines.gds-code
               buf_utd-marking-lines.LineNum   = buf_utd-lines.LineNum
               buf_utd-marking-lines.mark      = v-marking
               buf_utd-marking-lines.sts       = ObjSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB
               buf_utd-marking-lines.doc-level = 1
               .
            find first buf_marking exclusive-lock where buf_marking.mark begins v-marking no-error .
            if not available (buf_marking) then
            do:
               create buf_marking .
               assign
                  buf_marking.gds-code   = buf_utd-marking-lines.gds-code
                  buf_marking.mark       = v-marking
                  buf_marking.sts        = Marking:UnknowSts:KeyIntDB
                  buf_marking.gds-ext-id = v-GTIN
                  buf_marking.obj-code   = buf_utd.obj-code
                  buf_marking.obj-type   = buf_utd.obj-type
                  .
               buf_marking.unit-ext  = getLevelMotpBycodid(v-marking) .
               buf_marking.box-qnty  = getQntyUTDBycodid(v-marking) .
               buf_marking.unit = getLevelUTDBycodid(v-marking) .
            end.
            else
            do:
               buf_marking.sts      = Marking:UnknowSts:KeyIntDB .
            end.
            if buf_marking.box-qnty = ? or buf_marking.box-qnty = 0 then
            do:
               v-qnty = 0 .
               run gbl/d-prompt.w (
                  'title=':u + "Ввод количества" + '\':u
                  + 'text1=':u + "Введите количество:" + '\':u
                  + 'format=' + ">>>>>9.99" + '\':u
                  + 'type=' + 'D':U + '\':u
                  + 'fillin_row=3\':u
                  + 'fillin_col=6\':u
                  + 'fillin_width=17\':u
                  + 'fillin_height=1\':u
                  + 'max-chars=17\':u
                  + 'readonly=no\':u
                  , input-output v-qnty
                  ).
               buf_marking.box-qnty = v-qnty .
               buf_marking.unit  = if available (buf_goods) then buf_goods.unit-base else "".
               buf_marking.unit-ext = "UNIT" .
            end.
            find first X_utd-lines exclusive-lock where X_utd-lines.gds-code = buf_utd-lines.gds-code and X_utd-lines.lineNum = buf_utd-lines.LineNum
               and X_utd-lines.db-num = buf_utd-lines.db-num and X_utd-lines.doc-id = buf_utd-lines.doc-id no-error .
            buf_utd-lines.Quantity  = buf_utd-lines.Quantity  + buf_marking.box-qnty .
            X_utd-lines.qnty-scan = X_utd-lines.qnty-scan + buf_marking.box-qnty .
            X_utd-lines.Quantity  = X_utd-lines.Quantity  + buf_marking.box-qnty .
            X_utd-lines.qnty-mark = X_utd-lines.qnty-mark + 1 .
            br-utd:refresh () no-error .
            reposition br-utd to recid recid_utd no-error .
            v-mark:screen-value = "" .
            v-mark = "" .
         end.
         else
         do:
            F-text = "                GTIN - " + v-GTIN + " не привязан к товару в базе".
            display F-text with frame d-utd.
            v-mark:screen-value = "" .
            v-mark = "" .
            return.
         end.
      end.
      else
      do:
         F-text = "                              Нет возможности получить GTIN " .
         display F-text with frame d-utd.
         v-mark:screen-value = "" .
         v-mark = "" .
         return.
      end.
   end.
   if c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB and buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB then
   do:
      if f-obj-type-th = "" then
      do:
         message "Не выбран объект"
            view-as alert-box.
         v-mark:screen-value = "" .
         v-mark = "" .
         return no-apply .
      end.
      if c-type = 0 then
      do:
         message "Не выбран тип документа"
            view-as alert-box.
         v-mark:screen-value = "" .
         v-mark = "" .
         return no-apply .
      end.
      v-GTIN = getGtinByDM(v-marking) .
      if v-GTIN <> "" or c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB then
      do:
         v-gds-code = getGdsCodeByGtin(v-GTIN) .
         find first buf_goods no-lock where buf_goods.gds-code = v-gds-code no-error .
         if available (buf_goods) or c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB then
         do:
            find first buf_utd-lines where buf_utd-lines.doc-id = buf_utd.doc-id and buf_utd-lines.db-num = buf_utd.db-num
               and buf_utd-lines.gds-code = v-gds-code no-error .
            if not available (buf_utd-lines) then
            do:
               find last X_utd-lines no-lock no-error .
               if not available (X_utd-lines) then jj = 0 .
               else jj = X_utd-lines.LineNum .
               create buf_utd-lines .
               assign
                  buf_utd-lines.GdsName  = GdsName(v-gds-code)
                  buf_utd-lines.db-num   = buf_utd.db-num
                  buf_utd-lines.doc-id   = buf_utd.doc-id
                  buf_utd-lines.LineNum  = jj + 1
                  buf_utd-lines.gds-code = v-gds-code
                  buf_utd-lines.sts      = ObjSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB .
               buf_utd-lines.UnitCode = if available (buf_goods) then buf_goods.unit-base else ""
                  .
               create  X_utd-lines .
               buffer-copy buf_utd-lines to X_utd-lines .
               assign
                  X_utd-lines.stts = StatusTHName(buf_utd-lines.sts).
               X_utd-lines.gds-name = GdsName(v-gds-code)
                  .
               X_utd-lines.isMarking = CheckMarkUtdline(buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum).
               X_utd-lines.isArtic = logical(getAttrUtdLinesEx (buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum,"ArticUtdLine","yes")).
               for each buf_parts no-lock where  buf_parts.artic = buf_goods.artic and
                  buf_parts.prod-code = buf_goods.prod-code and
                  buf_parts.prod-type = buf_goods.prod-type and
                  buf_parts.out-code = 'free-zone':U and
                  buf_parts.obj-code = buf_utd.obj-code and
                  buf_parts.obj-type = buf_utd.obj-type :
                  X_utd-lines.fact-qnty = X_utd-lines.fact-qnty + buf_parts.fact-qnty .
               end.
               find first buf_utd-lines-attr exclusive-lock where buf_utd-lines-attr.db-num = X_utd-lines.db-num and
                  buf_utd-lines-attr.doc-id = X_utd-lines.doc-id and
                  buf_utd-lines-attr.LineNum = X_utd-lines.LineNum and
                  buf_utd-lines-attr.attr-code = "utd-fact-qnty" no-error .
               if not available (buf_utd-lines-attr) then
               do:
                  create buf_utd-lines-attr .
                  assign
                     buf_utd-lines-attr.db-num    = X_utd-lines.db-num
                     buf_utd-lines-attr.doc-id    = X_utd-lines.doc-id
                     buf_utd-lines-attr.LineNum   = X_utd-lines.LineNum
                     buf_utd-lines-attr.attr-code = "utd-fact-qnty"
                     .
               end.
               buf_utd-lines-attr.attr-value = string(X_utd-lines.fact-qnty) .
            end.
            recid_utd = recid(X_utd-lines) .
            find first X_utd-lines exclusive-lock where X_utd-lines.gds-code = buf_utd-lines.gds-code and X_utd-lines.lineNum = buf_utd-lines.LineNum
               and X_utd-lines.db-num = buf_utd-lines.db-num and X_utd-lines.doc-id = buf_utd-lines.doc-id no-error .
            buf_utd-lines.Quantity  = buf_utd-lines.Quantity  + buf_marking.box-qnty .
            X_utd-lines.qnty-scan = X_utd-lines.qnty-scan .
            X_utd-lines.Quantity  = X_utd-lines.Quantity .
            br-utd:refresh () no-error .
            reposition br-utd to recid recid_utd no-error .
            v-mark:screen-value = "" .
            v-mark = "" .
         end.
         else
         do:
            F-text = "                GTIN - " + v-GTIN + " не привязан к товару в базе".
            display F-text with frame d-utd.
            v-mark:screen-value = "" .
            v-mark = "" .
            return.
         end.
      end.
      else
      do:
         F-text = "                              Нет возможности получить GTIN " .
         display F-text with frame d-utd.
         v-mark:screen-value = "" .
         v-mark = "" .
         return.
      end.
   end.
   if p-type = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB and buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB then
   do:
      mMRCCode  = no.
      v-marking = GetCodeIdent(v-mark) .
      if f-obj-type-th = "" then
      do:
         message "Не выбран объект"
            view-as alert-box.
         v-mark:screen-value = "" .
         v-mark = "" .
         return no-apply .
      end.
      if c-type = 0 then
      do:
         message "Не выбран тип документа"
            view-as alert-box.
         v-mark:screen-value = "" .
         v-mark = "" .
         return no-apply .
      end.
      find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark begins v-marking and buf_utd-marking-lines.db-num = buf_utd.db-num
         and buf_utd-marking-lines.doc-id = buf_utd.doc-id no-error .
      if available (buf_utd-marking-lines) then
      do:
         F-text = "                        Марка уже просканирована в этом документе " .
         display F-text with frame d-utd.
         v-mark:screen-value = "" .
         v-mark = "" .
         return.
      end.
      find first buf_marking no-lock where buf_marking.mark begins v-marking and buf_marking.sts >= Marking:OutZone:KeyIntDB no-error .
      if available (buf_marking) then
      do:
         if buf_marking.sts <> Marking:GrayZone:KeyIntDB then
         do:
            F-text = "                      Марка находится в обороте , статус марки –" + StatusTHName(buf_marking.sts) .
            display F-text with frame d-utd.
            v-mark:screen-value = "" .
            v-mark = "" .
            return.
         end.
      end.
      else
      do:
         find first buf_marking no-lock where buf_marking.mark begins v-marking no-error .
         if available (buf_marking) then
         do:
            if buf_marking.sts < Marking:Received:KeyIntDB and buf_marking.loc-key <> "" and c-type <> objSrv:Env:Utd:EDocType:AKT:KeyIntDB then
            do:
               F-text = "                                      Марка занята" .
               display F-text with frame d-utd.
               v-mark:screen-value = "" .
               v-mark = "" .
               return.
            end.
            if buf_marking.sts = Marking:MarkError:KeyIntDB and c-type <> objSrv:Env:Utd:EDocType:AKT:KeyIntDB then
            do:
               def variable v-error-mark as character no-undo .
               v-error-mark = "Marking" + chr(3) + buf_marking.mark .
               find first ub.utd-err no-lock where ub.utd-err.reckey = v-error-mark and
                  ub.utd-err.CodeErr = "MotpMarkErr" no-error .
               if not available (ub.utd-err) then
               do:
                  F-text = "                      Марка находится в статусе –" + StatusTHName(buf_marking.sts) .
                  display F-text with frame d-utd.
                  v-mark:screen-value = "" .
                  v-mark = "" .
                  return.
               end.
            end.
            if buf_marking.sts = Marking:DeliveryControl:KeyIntDB and c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB then
            do:
               F-text = "               Найдено УПД на поставку данной марки. Марка не может быть принята по Акту" .
               display F-text with frame d-utd.
               v-mark:screen-value = "" .
               v-mark = "" .
               return.
            end.
            if buf_marking.sts <> Marking:UnknowSts:KeyIntDB and c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB then
            do:
               F-text = "        Марка зарегистрирована в системе. Статус марки " +  StatusTHName(buf_marking.sts).
               display F-text with frame d-utd.
               v-mark:screen-value = "" .
               v-mark = "" .
               return.
            end.
         end.
      end.
      v-GTIN = getGtinByDM(v-marking) .
      if v-GTIN <> "" or c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB then
      do:
         v-gds-code = getGdsCodeByGtin(v-GTIN) .
         find first buf_goods no-lock where buf_goods.gds-code = v-gds-code no-error .
         if available (buf_goods) or c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB then
         do:
            find first buf_utd-lines where buf_utd-lines.doc-id = buf_utd.doc-id and buf_utd-lines.db-num = buf_utd.db-num
               and buf_utd-lines.gds-code = v-gds-code no-error .
            if not available (buf_utd-lines) then
            do:
               find last X_utd-lines no-lock no-error .
               if not available (X_utd-lines) then jj = 0 .
               else jj = X_utd-lines.LineNum .
               create buf_utd-lines .
               assign
                  buf_utd-lines.GdsName  = GdsName(v-gds-code)
                  buf_utd-lines.db-num   = buf_utd.db-num
                  buf_utd-lines.doc-id   = buf_utd.doc-id
                  buf_utd-lines.LineNum  = jj + 1
                  buf_utd-lines.gds-code = v-gds-code
                  buf_utd-lines.sts      = ObjSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB .
               buf_utd-lines.UnitCode = if available (buf_goods) then buf_goods.unit-base else ""
                  .
               create  X_utd-lines .
               buffer-copy buf_utd-lines to X_utd-lines .
               assign
                  X_utd-lines.stts = StatusTHName(buf_utd-lines.sts).
               X_utd-lines.gds-name = GdsName(v-gds-code)
                  .
               X_utd-lines.isMarking = CheckMarkUtdline(buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum).
               X_utd-lines.isArtic = logical(getAttrUtdLinesEx (buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum,"ArticUtdLine","yes")).
               for each buf_parts no-lock where  buf_parts.artic = buf_goods.artic and
                  buf_parts.prod-code = buf_goods.prod-code and
                  buf_parts.prod-type = buf_goods.prod-type and
                  buf_parts.out-code = 'free-zone':U and
                  buf_parts.obj-code = buf_utd.obj-code and
                  buf_parts.obj-type = buf_utd.obj-type :
                  X_utd-lines.fact-qnty = X_utd-lines.fact-qnty + buf_parts.fact-qnty .
               end.
               find first buf_utd-lines-attr exclusive-lock where buf_utd-lines-attr.db-num = X_utd-lines.db-num and
                  buf_utd-lines-attr.doc-id = X_utd-lines.doc-id and
                  buf_utd-lines-attr.LineNum = X_utd-lines.LineNum and
                  buf_utd-lines-attr.attr-code = "utd-fact-qnty" no-error .
               if not available (buf_utd-lines-attr) then
               do:
                  create buf_utd-lines-attr .
                  assign
                     buf_utd-lines-attr.db-num    = X_utd-lines.db-num
                     buf_utd-lines-attr.doc-id    = X_utd-lines.doc-id
                     buf_utd-lines-attr.LineNum   = X_utd-lines.LineNum
                     buf_utd-lines-attr.attr-code = "utd-fact-qnty"
                     .
               end.
               buf_utd-lines-attr.attr-value = string(X_utd-lines.fact-qnty) .
            end.
            recid_utd = recid(X_utd-lines) .
            create buf_utd-marking-lines .
            assign
               buf_utd-marking-lines.db-num    = buf_utd.db-num
               buf_utd-marking-lines.doc-id    = buf_utd.doc-id
               buf_utd-marking-lines.gds-code  = buf_utd-lines.gds-code
               buf_utd-marking-lines.LineNum   = buf_utd-lines.LineNum
               buf_utd-marking-lines.mark      = v-marking
               buf_utd-marking-lines.sts       = ObjSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB
               buf_utd-marking-lines.doc-level = 1
               .
            find first buf_marking exclusive-lock where buf_marking.mark begins v-marking no-error .
            if not available (buf_marking) then
            do:
               create buf_marking .
               assign
                  buf_marking.gds-code   = buf_utd-marking-lines.gds-code
                  buf_marking.mark       = v-marking
                  buf_marking.sts        = Marking:PendingVerification:KeyIntDB
                  buf_marking.gds-ext-id = v-GTIN
                  buf_marking.obj-code   = buf_utd.obj-code
                  buf_marking.obj-type   = buf_utd.obj-type
                  .
               buf_marking.unit-ext  = getLevelMotpBycodid(v-marking) .
               buf_marking.box-qnty  = getQntyUTDBycodid(v-marking) .
               buf_marking.unit = getLevelUTDBycodid(v-marking) .
            end.
            else
            do:
               buf_marking.sts      = Marking:PendingVerification:KeyIntDB .
            end.
            if buf_marking.box-qnty = ? or buf_marking.box-qnty = 0 then
            do:
               v-qnty = 0 .
               run gbl/d-prompt.w (
                  'title=':u + "Ввод количества" + '\':u
                  + 'text1=':u + "Введите количество:" + '\':u
                  + 'format=' + ">>>>>9.99" + '\':u
                  + 'type=' + 'D':U + '\':u
                  + 'fillin_row=3\':u
                  + 'fillin_col=6\':u
                  + 'fillin_width=17\':u
                  + 'fillin_height=1\':u
                  + 'max-chars=17\':u
                  + 'readonly=no\':u
                  , input-output v-qnty
                  ).
               buf_marking.box-qnty = v-qnty .
               buf_marking.unit  = if available (buf_goods) then buf_goods.unit-base else "".
               buf_marking.unit-ext = "UNIT" .
            end.
            find first X_utd-lines exclusive-lock where X_utd-lines.gds-code = buf_utd-lines.gds-code and X_utd-lines.lineNum = buf_utd-lines.LineNum
               and X_utd-lines.db-num = buf_utd-lines.db-num and X_utd-lines.doc-id = buf_utd-lines.doc-id no-error .
            buf_utd-lines.Quantity  = buf_utd-lines.Quantity  + buf_marking.box-qnty .
            X_utd-lines.qnty-scan = X_utd-lines.qnty-scan + buf_marking.box-qnty .
            X_utd-lines.Quantity  = X_utd-lines.Quantity  + buf_marking.box-qnty .
            X_utd-lines.qnty-mark = X_utd-lines.qnty-mark + 1 .
            br-utd:refresh () no-error .
            reposition br-utd to recid recid_utd no-error .
            v-mark:screen-value = "" .
            v-mark = "" .
         end.
         else
         do:
            F-text = "                GTIN - " + v-GTIN + " не привязан к товару в базе".
            display F-text with frame d-utd.
            v-mark:screen-value = "" .
            v-mark = "" .
            return.
         end.
      end.
      else
      do:
         F-text = "                              Нет возможности получить GTIN " .
         display F-text with frame d-utd.
         v-mark:screen-value = "" .
         v-mark = "" .
         return.
      end.
      for first buf_marking exclusive-lock where buf_marking.mark begins v-marking and buf_marking.sts = Marking:GrayZone:KeyIntDB:
         empty temp-table tt-marking-lines .
         for first gray_utd-marking-lines no-lock where gray_utd-marking-lines.db-num = X_utd-lines.db-num and gray_utd-marking-lines.doc-id = X_utd-lines.doc-id
            and gray_utd-marking-lines.LineNum = X_utd-lines.LineNum and gray_utd-marking-lines.mark = buf_utd-marking-lines.mark:
            for first gray_marking no-lock where gray_marking.mark = buf_utd-marking-lines.mark :
               create tt-marking-lines .
               assign
                  tt-marking-lines.gds-name    = GdsName(gray_utd-marking-lines.gds-code)
                  tt-marking-lines.stts-utd    = StatusTHName(gray_utd-marking-lines.sts)
                  tt-marking-lines.stts        = StatusTHName(gray_marking.sts)
                  tt-marking-lines.mark        = gray_marking.mark
                  tt-marking-lines.mark-parent = gray_marking.mark-parent
                  tt-marking-lines.gds-code    = gray_utd-marking-lines.gds-code
                  tt-marking-lines.sts         = gray_marking.sts
                  tt-marking-lines.sts-utd     = gray_utd-marking-lines.sts
                  tt-marking-lines.unit        = gray_marking.unit
                  tt-marking-lines.box-qnty    = gray_marking.box-qnty
                  tt-marking-lines.LineNum     = gray_utd-marking-lines.LineNum
                  tt-marking-lines.db-num      = gray_utd-marking-lines.db-num
                  tt-marking-lines.doc-id      = gray_utd-marking-lines.doc-id
                  tt-marking-lines.doc-level   = gray_utd-marking-lines.doc-level
                  .
            end.
            for each gray_unit-marking no-lock where gray_unit-marking.mark-parent = gray_utd-marking-lines.mark:
               for first gray_unit_utd-marking-lines no-lock where gray_unit_utd-marking-lines.mark = gray_unit-marking.mark:
                  create tt-marking-lines .
                  assign
                     tt-marking-lines.gds-name    = GdsName(gray_unit_utd-marking-lines.gds-code)
                     tt-marking-lines.stts-utd    = StatusTHName(gray_unit_utd-marking-lines.sts)
                     tt-marking-lines.stts        = StatusTHName(gray_unit-marking.sts)
                     tt-marking-lines.mark        = gray_unit-marking.mark
                     tt-marking-lines.mark-parent = gray_unit-marking.mark-parent
                     tt-marking-lines.gds-code    = gray_unit_utd-marking-lines.gds-code
                     tt-marking-lines.sts         = gray_unit-marking.sts
                     tt-marking-lines.sts-utd     = gray_unit_utd-marking-lines.sts
                     tt-marking-lines.unit        = gray_unit-marking.unit
                     tt-marking-lines.unit-ext    = gray_unit-marking.unit-ext
                     tt-marking-lines.box-qnty    = gray_unit-marking.box-qnty
                     tt-marking-lines.LineNum     = gray_unit_utd-marking-lines.LineNum
                     tt-marking-lines.db-num      = gray_unit_utd-marking-lines.db-num
                     tt-marking-lines.doc-id      = gray_unit_utd-marking-lines.doc-id
                     tt-marking-lines.doc-level   = gray_unit_utd-marking-lines.doc-level
                     .
               end.
            end.
         end.
         run str/mark_browse.w (input parparentproc,
            input-output table tt-marking-lines by-reference,
            input p-mode,
            input "Марки по товару " + string(X_utd-lines.gds-code) + " " + GdsName(X_utd-lines.gds-code) + " со статусом: " + StatusTHName(Marking:GrayZone:KeyIntDB),
            input 6,
            input ""
            ) no-error .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-utd :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
      end.
   end.
   if c-status = ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB then
   do:
      find first X_utd-lines no-lock where X_utd-lines.stts <> "Проверен" no-error .
      if available (X_utd-lines) then
      do:
         F-text = "                            Просканируйте марку" .
         f-text:screen-value = "" .
         display F-text with frame d-utd .
      end.
      else
      do:
         F-text = "" .
         f-text:screen-value = "" .
         display F-text with frame d-utd .
      end.
      find first X_utd-lines no-lock where recid (X_utd-lines) = recid_utd and X_utd-lines.stts = "Проверен" no-error .
      if available (X_utd-lines) then
      do:
         if m-gds-code ne ? and m-gds-code ne "" then do:    if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else    if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else                          OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. end. else do: if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else  if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else                        OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      end.
      end.
   end.
   display F-text with frame d-utd.
   v-mark:screen-value = "" .
   v-mark = "" .
END PROCEDURE.
PROCEDURE save_bar-code :
   define variable v_list    as character no-undo .
   define variable ii        as integer   no-undo .
   define variable jj        as integer   no-undo .
   define variable v-marking as character no-undo .
   define buffer buf_parts                   for ub.parts .
   define buffer gray_marking                for ub.marking .
   define buffer gray_unit-marking           for ub.marking .
   define buffer gray_utd-marking-lines      for ub.utd-marking-lines .
   define buffer gray_unit_utd-marking-lines for ub.utd-marking-lines .
   define buffer buf_utd-lines-attr          for ub.utd-lines-attr .
   define buffer un_utd-marking-lines        for ub.utd-marking-lines .
   define buffer buf_bar-code                for ub.bar-code .
   define buffer buf_prod-bc                 for ub.prod-bc .
   define VARIABLE v-qnty       as decimal   no-undo .
   define VARIABLE v-rowid      as rowid     no-undo .
   define VARIABLE v-tbl-name   as character no-undo .
   define variable v-ungroup_ok as logical   no-undo .
   define variable v-gds-code as integer no-undo.
   if p-mode = 'ПРОСМОТР':U then
   do:
      v-Mark:screen-value in frame d-utd = "" .
      v-Mark = "" .
   end .
   if v-Mark:screen-value in frame d-utd = ""
      then
   do:
      v-Mark:screen-value in frame d-utd = v-scan-str.
   end.
   v-scan-str = "".
   assign
      v-Mark = v-Mark:screen-value in frame d-utd.
   F-text = "" .
   f-text:screen-value = "" .
   v-GTIN = "" .
   m-gds-code = ? .
   v-gds-code = ?.
   ASSIGN
      v_list = 'Ё,Й,Ц,У,К,Е,Н,Г,Ш,Щ,З,Х,Ъ,Ф,Ы,В,А,П,Р,О,Л,Д,Ж,Э,Я,Ч,С,М,И,Т,Ь,Б,Ю':U .
   do ii = 1 to length (v-Mark):
      if LOOKUP( SUBSTRING( v-Mark, ii, 1 ), v_list )  > 1 then
      do:
         message "Не корректно считан штрих-код, перед считыванием переключите клавиатуру на английскую раскладку."
            view-as alert-box.
         v-Mark:screen-value = "" .
         v-Mark = "" .
         return no-apply.
      end.
   end.
   if v-Mark = "" or v-Mark = ? then
   do:
      F-text = "            Ошибка чтения штрих-кода" .
      display F-text with frame d-utd.
      v-Mark:screen-value = "" .
      v-Mark = "" .
      return no-apply.
   end.
   mMRCCode  = yes.
   do:
      for first buf_prod-bc no-lock where buf_prod-bc.b-str = v-Mark,
         first buf_bar-code no-lock where buf_bar-code.b-code = buf_prod-bc.b-code and
         buf_bar-code.stts_ = 0:
         define variable v-par-val  as character no-undo.
         define variable v-par-type as character no-undo.
                         if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                    ( buf_bar-code.gds-code,
                      'mark-type':U,
                       output v-par-val,
                       output v-par-type
                    ).
         if (  EDOParSec:GetIsEDOForType(v-par-val)
            or EDOParSec:GetIsArticForType(v-par-val))
          and IS-NeedMark(buf_prod-bc.b-code,buf_prod-bc.b-str)
         then do:
            F-text = "           Штрих-код подлежит обязательной маркировке. Просканируйте марку." .
            display F-text with frame d-utd.
            v-Mark:screen-value = "" .
            v-Mark = "" .
            return no-apply.
         end.
         else
            v-gds-code = buf_bar-code.gds-code .
      end.
      if v-gds-code eq ?
      then do:
         F-text = "   Просканированный код не найден. Просканируйте Data Matrix или верните товар поставщику." .
         display F-text with frame d-utd.
         v-Mark:screen-value = "" .
         v-Mark = "" .
         return no-apply.
      end.
   end.
   if p-type = objSrv:Env:Utd:EDocType:UTD:KeyIntDB then
   do:
      block-u-l:
      for each X_utd-lines no-lock where X_utd-lines.gds-code = v-gds-code :
         leave block-u-l.
      end.
      if available (X_utd-lines) then
      do:
         if X_utd-lines.sts_err then
         do:
            F-text = "Товар не подлежит приемке, т.к. не прошел проверку на корректность" .
            display F-text with frame d-utd.
            v-Mark:screen-value = "" .
            v-Mark = "" .
            return no-apply.
         end.
         X_utd-lines.qnty-scan:COLUMN-READ-ONLY IN BROWSE br-utd = FALSE.
         find first X_utd-lines exclusive-lock where X_utd-lines.gds-code = v-gds-code no-error .
         if available (X_utd-lines) then
            recid_utd = recid (X_utd-lines) .
         m-gds-code = string(v-gds-code).
         b_cleaggds:sensitive = yes.
         b_cleaggds:visible = yes.
         m-gds-code:visible = yes.
         F-text:screen-value = "               Введите количество или просканируйте другой штрих-код" .
         m-gds-code:screen-value = m-gds-code.
         if m-gds-code ne ? and m-gds-code ne "" then do:    if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else    if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else                          OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. end. else do: if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else  if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else                        OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      end.
         reposition br-utd to recid recid_utd no-error .
         apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
         v-mark:screen-value = "" .
         v-mark = "" .
         return no-apply .
      end.
      else
      do :
         F-text = "Просканированный код не найден. Просканируйте Data Matrix или верните товар поставщику." .
         display F-text with frame d-utd.
         v-Mark:screen-value = "" .
         v-Mark = "" .
         b_cleaggds:visible = no.
         m-gds-code:visible = no.
         m-gds-code = ?.
         if m-gds-code ne ? and m-gds-code ne "" then do:    if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else    if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else                          OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. end. else do: if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else  if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else                        OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      end.
         apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
          return no-apply .
      end.
   end.
   if p-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB and buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB then
   do:
      if f-obj-type-th = "" then
      do:
         message "Не выбран объект"
            view-as alert-box.
         v-Mark:screen-value = "" .
         v-mark = "" .
         return no-apply .
      end.
      if c-type = 0 then
      do:
         message "Не выбран тип документа"
            view-as alert-box.
         v-Mark:screen-value = "" .
         v-Mark = "" .
         return no-apply .
      end.
         find first buf_goods no-lock where buf_goods.gds-code = v-gds-code no-error .
         if available (buf_goods)
         then
         do:
            find first buf_utd-lines where buf_utd-lines.doc-id = buf_utd.doc-id and buf_utd-lines.db-num = buf_utd.db-num
               and buf_utd-lines.gds-code = v-gds-code no-error .
            if not available (buf_utd-lines) then
            do:
               find last X_utd-lines no-lock no-error .
               if not available (X_utd-lines) then jj = 0 .
               else jj = X_utd-lines.LineNum .
               create buf_utd-lines .
               assign
                  buf_utd-lines.GdsName  = GdsName(v-gds-code)
                  buf_utd-lines.db-num   = buf_utd.db-num
                  buf_utd-lines.doc-id   = buf_utd.doc-id
                  buf_utd-lines.LineNum  = jj + 1
                  buf_utd-lines.gds-code = v-gds-code
                  buf_utd-lines.sts      = ObjSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB .
               buf_utd-lines.UnitCode = if available (buf_goods) then buf_goods.unit-base else ""
                  .
               create  X_utd-lines .
               buffer-copy buf_utd-lines to X_utd-lines .
               assign
                  X_utd-lines.stts = StatusTHName(buf_utd-lines.sts).
               X_utd-lines.gds-name = GdsName(v-gds-code)
                  .
               X_utd-lines.ismarking = CheckMarkUtdline(buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum).
               X_utd-lines.isArtic = logical(getAttrUtdLinesEx (buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum,"ArticUtdLine","yes")).
               for each buf_parts no-lock where  buf_parts.artic = buf_goods.artic and
                  buf_parts.prod-code = buf_goods.prod-code and
                  buf_parts.prod-type = buf_goods.prod-type and
                  buf_parts.out-code = 'free-zone':U and
                  buf_parts.obj-code = buf_utd.obj-code and
                  buf_parts.obj-type = buf_utd.obj-type :
                  X_utd-lines.fact-qnty = X_utd-lines.fact-qnty + buf_parts.fact-qnty .
               end.
               find first buf_utd-lines-attr exclusive-lock where buf_utd-lines-attr.db-num = X_utd-lines.db-num and
                  buf_utd-lines-attr.doc-id = X_utd-lines.doc-id and
                  buf_utd-lines-attr.LineNum = X_utd-lines.LineNum and
                  buf_utd-lines-attr.attr-code = "utd-fact-qnty" no-error .
               if not available (buf_utd-lines-attr) then
               do:
                  create buf_utd-lines-attr .
                  assign
                     buf_utd-lines-attr.db-num    = X_utd-lines.db-num
                     buf_utd-lines-attr.doc-id    = X_utd-lines.doc-id
                     buf_utd-lines-attr.LineNum   = X_utd-lines.LineNum
                     buf_utd-lines-attr.attr-code = "utd-fact-qnty"
                     .
               end.
               buf_utd-lines-attr.attr-value = string(X_utd-lines.fact-qnty) .
            end.
            recid_utd = recid(X_utd-lines) .
            create buf_utd-marking-lines .
            assign
               buf_utd-marking-lines.db-num    = buf_utd.db-num
               buf_utd-marking-lines.doc-id    = buf_utd.doc-id
               buf_utd-marking-lines.gds-code  = buf_utd-lines.gds-code
               buf_utd-marking-lines.LineNum   = buf_utd-lines.LineNum
               buf_utd-marking-lines.mark      = v-mark
               buf_utd-marking-lines.sts       = ObjSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB
               buf_utd-marking-lines.doc-level = 1
               .
            br-utd:refresh () no-error .
            reposition br-utd to recid recid_utd no-error .
            v-mark:screen-value = "" .
            v-mark = "" .
         end.
         else
         do:
            F-text = "                Штрих-код - " + v-Mark + " не привязан к товару в базе".
            display F-text with frame d-utd.
            v-mark:screen-value = "" .
            v-mark = "" .
            return.
         end.
   end.
   if p-type = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB and buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB then
   do:
      mMRCCode  = no.
      if f-obj-type-th = "" then
      do:
         message "Не выбран объект"
            view-as alert-box.
         v-mark:screen-value = "" .
         v-mark = "" .
         return no-apply .
      end.
      if c-type = 0 then
      do:
         message "Не выбран тип документа"
            view-as alert-box.
         v-Mark:screen-value = "" .
         v-mark = "" .
         return no-apply .
      end.
      find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = v-mark and buf_utd-marking-lines.db-num = buf_utd.db-num
         and buf_utd-marking-lines.doc-id = buf_utd.doc-id no-error .
      if available (buf_utd-marking-lines) then
      do:
         F-text = "                        Штрих-код уже просканирован в этом документе " .
         display F-text with frame d-utd.
         v-mark:screen-value = "" .
         v-mark = "" .
         return.
      end.
   end.
   if c-status = ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB then
   do:
      find first X_utd-lines no-lock where X_utd-lines.stts <> "Проверен" no-error .
      if available (X_utd-lines) then
      do:
         if v-gds-code ne ?
            then
         do:
            assign
               F-text:screen-value = "               Введите количество или просканируйте другой штрих-код"
               F-text.
         end.
         else
         do:
            F-text = "                Приемка товара невозможна, передайте товар поставщику" .
            display F-text with frame d-utd .
         end.
      end.
      else
      do:
         F-text = "" .
         f-text:screen-value = "" .
         display F-text with frame d-utd .
      end.
      find first X_utd-lines no-lock where recid (X_utd-lines) = recid_utd and X_utd-lines.stts = "Проверен" no-error .
      if available (X_utd-lines) then
      do:
         if m-gds-code ne ? and m-gds-code ne "" then do:    if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else    if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else                          OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. end. else do: if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else  if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else                        OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      end.
      end.
   end.
   display F-text with frame d-utd.
   v-mark:screen-value = "" .
   v-mark = "" .
END PROCEDURE.
PROCEDURE save_mol :
   find first buf_utd-attr exclusive-lock where buf_utd-attr.db-num = buf_utd.db-num and buf_utd-attr.doc-id = buf_utd.doc-id and buf_utd-attr.attr-code = "wrkr" no-error .
   if not available (buf_utd-attr) then
   do:
      create buf_utd-attr .
      assign
         buf_utd-attr.db-num    = buf_utd.db-num
         buf_utd-attr.doc-id    = buf_utd.doc-id
         buf_utd-attr.attr-code = "wrkr"
         .
   end.
   buf_utd-attr.attr-value = string(f-wrkr) .
   find first buf_utd-attr exclusive-lock where buf_utd-attr.db-num = buf_utd.db-num and buf_utd-attr.doc-id = buf_utd.doc-id and buf_utd-attr.attr-code = "agnt" no-error .
   if not available (buf_utd-attr) then
   do:
      create buf_utd-attr .
      assign
         buf_utd-attr.db-num    = buf_utd.db-num
         buf_utd-attr.doc-id    = buf_utd.doc-id
         buf_utd-attr.attr-code = "agnt"
         .
   end.
   buf_utd-attr.attr-value = string(f-agnt) .
   find first buf_utd-attr exclusive-lock where buf_utd-attr.db-num = buf_utd.db-num and buf_utd-attr.doc-id = buf_utd.doc-id and buf_utd-attr.attr-code = "boss" no-error .
   if not available (buf_utd-attr) then
   do:
      create buf_utd-attr .
      assign
         buf_utd-attr.db-num    = buf_utd.db-num
         buf_utd-attr.doc-id    = buf_utd.doc-id
         buf_utd-attr.attr-code = "boss"
         .
   end.
   buf_utd-attr.attr-value = string(f-boss) .
END PROCEDURE.
procedure LoadKeyboardLayoutA external "user32" :
   define input  parameter P1 as char.
   define input  parameter P2 as LONG.
   define return parameter pret as LONG.
end procedure.
procedure ActivateKeyboardLayout external "user32" :
   define input parameter P1 as LONG.
   define input parameter P2 as LONG.
END PROCEDURE.
PROCEDURE proc-any-key :
   if v-scan-str = ""
   then etime(yes).
      if  not v-manual and v-scan-str ne ""
      then do:
         if etime > 2000
            then
         do:
            if  log-manager:logfile-name ne ?
            then do:
 def var speed as int64 no-undo.
               speed = etime.
               log-manager:write-message(substitute('Последовательность символов "&1" была сброшена после &2 мс',v-scan-str, speed), "ScanSpeed").
            end.
            v-scan-str = "".
            etime(yes).
         end.
     end.
   v-scan-str = v-scan-str + last-event:label.
end.
PROCEDURE add-mark-weight :
    define input  parameter iMark     as character no-undo.
    define input  parameter iGTIN     as character no-undo.
    define input  parameter iDocId    as integer   no-undo.
    define input  parameter iDbNum    as integer   no-undo.
    define output parameter oRecUtd as recid     no-undo.
    define output parameter oTxt    as character no-undo.
    define variable vWeight as decimal no-undo.
    define variable vFnd    as logical no-undo.
    define variable vChkWeight as logical no-undo.
    define variable vUnitCode  as character no-undo.
    define variable vMarkShort as character no-undo.
    define variable vGdsCode  as integer   no-undo.
    define buffer bX_utd-lines for X_utd-lines.
    define buffer buf_utd-marking-lines for ub.utd-marking-lines.
    define buffer buf_utd-marking-lines-attr for ub.utd-marking-lines-attr.
    define buffer tt-utd-lines-filtr for tt-utd-lines-filtr.
    define buffer buf_marking  for ub.marking .
    define buffer buf_marking-attr for ub.marking-attr.
    define buffer buf_utd-lines-attr for ub.utd-lines-attr.
    assign
        vChkWeight = no
        vMarkShort = GetCodeIdent(iMark)
        vGdsCode = getGdsCodeByGtin(m-gds-code)
        .
    find first buf_marking no-lock where buf_marking.mark begins vMarkShort no-error .
    if not avail buf_marking then .
    else if
       (buf_marking.sts eq ObjSrv:Env:Marking:Sts:Mark:DeliveryControl:KeyIntDB
         or buf_marking.sts eq ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
         or buf_marking.sts eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
         or buf_marking.sts eq ObjSrv:Env:Marking:Sts:Mark:Freezone:KeyIntDB
         or buf_marking.sts eq ObjSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB)
    then .
    else do:
       assign
          oRecUtd = ?
          oTxt = "Товар не подлежит приемке, т. к. не прошел проверку на корректность"
          .
          return "".
    end.
    if ChkAnotherUtd(iDocId, iDbNum, vMarkShort)
    then do:
       find first buf_marking-attr where buf_marking-attr.mark begins vMarkShort
                                     and buf_marking-attr.attr-code eq "weight"
          no-lock no-error.
       if avail buf_marking-attr
       then do:
          vWeight = decimal(buf_marking-attr.attr-value) no-error.
          if vWeight <> 0 and vWeight <> ? then do:
              vUnitCode = gdsunit (vGdsCode).
              MESSAGE "Масса товара равна "
                  (if vWeight < 1  and vWeight >= 0
                      then string(vWeight,"9.999")
                      else string(vWeight))
                  vUnitCode "?"
                  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                  TITLE "" UPDATE lChoice AS LOGICAL.
              if lChoice then do:
                  vChkWeight = yes.
              end.
              else do:
                  assign
                     oRecUtd = ?
                     oTxt = "Масса товара не совпадает с данными в системе. Товар не подлежит приемке."
                     .
                  return .
              end.
          end.
          else run str/add-weight.w (vGdsCode, output vWeight).
       end.
       else run str/add-weight.w (vGdsCode, output vWeight).
    end.
    else run str/add-weight.w (vGdsCode, output vWeight).
    if vWeight = 0 then do:
        MESSAGE "Вес товара обязательный"
        VIEW-AS ALERT-BOX.
        return "".
    end.
    assign
       oRecUtd = ?
       vFnd = no
       .
    utline:
    for each bX_utd-lines where
             bX_utd-lines.doc-id = iDocId
         and bX_utd-lines.db-num = iDbNum
         and bX_utd-lines.gds-code = vGdsCode
         and bX_utd-lines.isArtic = yes
         by bX_utd-lines.LineNum :
         vFnd = yes.
         if bX_utd-lines.PieceFact < bX_utd-lines.PieceTTH
         and bX_utd-lines.qnty-scan + vWeight <= bX_utd-lines.Quantity
         then do:
            oRecUtd = recid(bX_utd-lines) .
            create buf_utd-marking-lines .
            assign
               buf_utd-marking-lines.db-num    = bX_utd-lines.db-num
               buf_utd-marking-lines.doc-id    = bX_utd-lines.doc-id
               buf_utd-marking-lines.gds-code  = bX_utd-lines.gds-code
               buf_utd-marking-lines.LineNum   = bX_utd-lines.LineNum
               buf_utd-marking-lines.mark      = vMarkShort
               buf_utd-marking-lines.sts       = Marking:Checked_:KeyIntDB .
               buf_utd-marking-lines.doc-level = 1
               .
            setattrUtdMarkingLines(buf_utd-marking-lines.db-num,
                                   buf_utd-marking-lines.doc-id,
                                   buf_utd-marking-lines.LineNum,
                                   buf_utd-marking-lines.mark,
                                   "AddMarkWeight",
                                   "yes") .
            find first buf_marking exclusive-lock where buf_marking.mark begins vMarkShort no-error .
            if not available (buf_marking)
            and not locked buf_marking then
            do:
                 create buf_marking .
                 assign
                    buf_marking.gds-code   = buf_utd-marking-lines.gds-code
                    buf_marking.mark       = vMarkShort
                    buf_marking.sts        = Marking:DeliveryControl:KeyIntDB
                    buf_marking.gds-ext-id = iGTIN
                    buf_marking.obj-code   = buf_utd.obj-code
                    buf_marking.obj-type   = buf_utd.obj-type
                    buf_marking.box-qnty   = 1
                    buf_marking.unit       = getLevelUTDByCodId(iMark)
                    buf_marking.unit-ext   = "UNIT"
                    .
            end.
            if not vChkWeight then do:
                find first buf_marking-attr where
                           buf_marking-attr.attr-code eq "weight"
                       and buf_marking-attr.mark eq buf_marking.mark
                     exclusive-lock no-error.
                if not available buf_marking-attr
                   and not locked buf_marking-attr
                then
                do:
                  create buf_marking-attr.
                  assign
                    buf_marking-attr.mark = buf_marking.mark
                    buf_marking-attr.attr-code = "weight"
                  .
                end.
                if available buf_marking-attr
                then buf_marking-attr.attr-value = if vWeight < 1
                                                      then string(vWeight,"9.999")
                                                      else string(vWeight).
            end.
            assign
                bX_utd-lines.qnty-scan = bX_utd-lines.qnty-scan + vWeight
                bX_utd-lines.qnty-mark = bX_utd-lines.qnty-mark + 1
                bX_utd-lines.PieceFact = String(int(bX_utd-lines.PieceFact) + 1) no-error
                .
            setattrUtdlines(bX_utd-lines.db-num,
                            bX_utd-lines.doc-id,
                            bX_utd-lines.LineNum,
                            "QuantityBarCode",
                            string(bX_utd-lines.qnty-scan)).
            setattrUtdlines(bX_utd-lines.db-num,
                            bX_utd-lines.doc-id,
                            bX_utd-lines.LineNum,
                            "QuantityPiece",
                            bX_utd-lines.PieceFact).
            recid_utd = recid (bX_utd-lines) .
            run mark-temp (?).
            leave utline.
         end.
    end.
    if vFnd and oRecUtd = ? then
       oTxt = "Внимание! Масса/количество товара не может быть больше массы/количества, переданной в УПД." .
    else if not vFnd then
       oTxt = "Товар не найден. Если сканируете КМ транспортной или груп. упак., то просканировать КМ потребительской упак., или верните товар поставщику." .
end procedure.
FUNCTION CliName RETURNS CHARACTER
   (input p-cli-code as integer, input p-cli-type as character) :
   define variable v-cli-name as character no-undo .
   find first buf_clients no-lock where buf_clients.obj-code = p-cli-code
      and buf_clients.obj-type = p-cli-type no-error .
   if available (buf_clients) then v-cli-name = buf_clients.obj-name .
   RETURN v-cli-name.
END FUNCTION.
FUNCTION ContName RETURNS CHARACTER
   ( input p-contract-code as integer, input p-host-code as integer ) :
   define variable v-contract-name as character no-undo .
   find first buf_contract no-lock where buf_contract.contract-code = p-contract-code and buf_contract.host-code = p-host-code no-error .
   if available (buf_contract) then v-contract-name = buf_contract.contract-name .
   RETURN v-contract-name.
END FUNCTION.
FUNCTION GdsName RETURNS CHARACTER
   ( input p-gds-code as integer) :
   define variable v-gds-name as character no-undo .
   define buffer buf_goods for ub.goods .
   find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
   if available (buf_goods) then v-gds-name = buf_goods.gds-name .
   RETURN v-gds-name.
END FUNCTION.
FUNCTION GdsUnit RETURNS CHARACTER
   ( input p-gds-code as integer) :
   define variable v-gds-unit as character no-undo .
   define buffer buf_goods for ub.goods .
   find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
   if available (buf_goods) then v-gds-unit = buf_goods.unit-base .
   RETURN v-gds-unit.
END FUNCTION.
FUNCTION StatusName RETURNS CHARACTER
   ( input p-doc-id as integer,
   input p-db-num as integer) :
   define variable v-status-name as character no-undo .
   define buffer buf_utd-attr for ub.utd-attr .
   find first buf_utd-attr no-lock where buf_utd-attr.doc-id = p-doc-id and
      buf_utd-attr.db-num = p-db-num and
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
   else v-status-name = "" .
   RETURN v-status-name.
END FUNCTION.
FUNCTION ChkAnotherUtd RETURNS LOGICAL
   ( input p-doc-id as integer,
     input p-db-num as integer,
     input p-mark as character
     ) :
   define buffer buf_utd-marking-lines for ub.utd-marking-lines .
   define variable vAvail as logical no-undo.
   vAvail = no.
   uml:
   for each buf_utd-marking-lines no-lock where
            buf_utd-marking-lines.mark begins p-mark
        :
        if buf_utd-marking-lines.doc-id <> p-doc-id
           or buf_utd-marking-lines.db-num  <> p-db-num
        then do:
            vAvail = yes.
            leave uml.
        end.
   end.
   RETURN vAvail.
END FUNCTION.
