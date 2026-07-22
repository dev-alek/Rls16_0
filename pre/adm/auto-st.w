CREATE WIDGET-POOL.
define input  parameter p-db-info            as character no-undo .
define input  parameter p-hidden-mode        as logical   no-undo .
define input  parameter p-no-message         as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запуск авто сессий и отслеживание их работы".
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
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable g#auto-pid           as integer   no-undo .
define  shared variable conn-par             as character no-undo .
define  shared variable g#auto-user-id       as character no-undo .
define  shared variable g#auto-user-login    as character no-undo .
define  shared variable g#auto-user-password as character no-undo .
define  shared variable v-socket             as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable auto-window-h     as handle    no-undo .
define  shared variable auto-log-msg-h    as handle    no-undo .
define  shared variable hand-log-msg-h    as handle    no-undo .
define  shared variable log-file-name     as character no-undo initial ? .
define  shared variable add-log-file-name as character no-undo initial ? .
define  shared variable writelogvalue     as character no-undo initial ? .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define stream LogStream .
define variable mNoTime as logical no-undo.
procedure write-to-log-notime :
  define input param i-str as character no-undo .
  mNoTime = yes.
  run write-to-log (i-str).
  mNoTime = no.
end.
procedure write-to-log :
  define input param p-str as character no-undo .
  do
  on error  undo, return error substitute( "&1 (write-to-log). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (write-to-log). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (write-to-log). endkey", vss-workfile )
  :
    define variable log-res        as logical   no-undo .
    define variable v-jj           as integer   no-undo .
    if    mNoTime
       or writelogvalue eq "AsyncProc"
    then
       p-str = substitute( "&1 (pid: &2) &3&4"   , g#auto-user-id, g#auto-pid,                        p-str, chr(10) ).
    else
       p-str = substitute( "&1 (pid: &2) &3 &4&5", g#auto-user-id, g#auto-pid, cur-time-string-sec(), p-str, chr(10) ).
    if auto-log-msg-h <> ? then do:
      log-res = auto-log-msg-h:move-to-eof( ) .
      log-res = auto-log-msg-h:insert-string( p-str ).
    end.
    if hand-log-msg-h <> ? then do:
      log-res = hand-log-msg-h:move-to-eof( ) .
      log-res = hand-log-msg-h:insert-string( p-str ).
    end.
    assign
      p-str = replace(p-str, (chr(10) + chr(13)), chr(10) )
      p-str = replace(p-str, (chr(13) + chr(10)), chr(10) )
      p-str = replace(p-str, chr(10), (chr(13) + chr(10)) )
    .
    if add-log-file-name <> ? then do:
      do v-jj = 1 to num-entries(add-log-file-name, chr(1)):
        run gbl/fileapnd.p
          ( input entry(v-jj, add-log-file-name, chr(1) )
          ,input p-str
          ,input 20
          ) no-error .
        if error-status:error then do:
          return error return-value .
        end.
      end.
    end.
    if writelogvalue eq "AsyncProc"
    then do:
       p-str = trim(p-str, (chr(13) + chr(10)) )
    .
       Publish "WriteLogAsunc" (p-str,yes).
    end.
    else if writelogvalue <> "yes" then do:
      run gbl/fileapnd.p
        ( input log-file-name
        ,input p-str
        ,input 20
        ) no-error .
      if error-status:error then do:
        return error return-value .
      end.
    end.
  end.
end procedure.
procedure write-to-screen :
  define input param p-str as character no-undo .
  do
  on error  undo, return error substitute( "&1 (write-to-screen). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (write-to-screen). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (write-to-screen). endkey", vss-workfile )
  :
    define variable log-res as logical no-undo.
    assign
      p-str = substitute( "&1 (pid: &2) &3 &4&5", g#auto-user-id, g#auto-pid, cur-time-string-sec(), p-str, chr(10) )
    .
    if auto-log-msg-h <> ?
    then do:
      log-res = auto-log-msg-h:move-to-eof( ) .
      log-res = auto-log-msg-h:insert-string( p-str ).
    end.
    if hand-log-msg-h <> ?
    then do:
      log-res = hand-log-msg-h:move-to-eof( ) .
      log-res = hand-log-msg-h:insert-string( p-str ).
    end.
  end.
end procedure.
procedure send-msg-to-email :
  define input  parameter p-subject      as character no-undo .
  define input  parameter p-text-err     as character no-undo .
  define input  parameter p-attach-files as character no-undo .
  do
  on error  undo, return error substitute( "&1 (send-msg-to-email). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (send-msg-to-email). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (send-msg-to-email). endkey", vss-workfile )
  :
    define variable v-tth             as handle    no-undo .
    define variable v-value-character as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as integer   no-undo .
    define variable v-value-logical   as logical   no-undo .
    define variable v-param-type      as character no-undo .
    define variable v-email       as character no-undo .
    define variable v-tmp-str     as character no-undo .
    define variable v-tmp1-str    as character no-undo .
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    delete object v-tth no-error.
    run adm/shattri.p
      ( input "get":U
       ,input  "":U
       ,input  0
       ,input  'auto-task':U
       ,input  'send-msg-to-email':U
       ,output v-value-character
       ,output v-value-date
       ,output v-value-decimal
       ,output v-value-integer
       ,output v-value-logical
       ,output v-param-type
       ,input-output table-handle v-tth
      ) no-error .
    if not error-status :error  then do:
      assign
        v-tmp-str = v-value-character
      .
    end.
    delete object v-tth no-error.
    assign
      v-tmp-str     = replace(v-tmp-str, (chr(10) + chr(13)), chr(44) )
      v-tmp-str     = replace(v-tmp-str, (chr(13) + chr(10)), chr(44) )
      v-tmp-str     = replace(v-tmp-str, chr(10), chr(44) )
      v-num-entries = num-entries( v-tmp-str, chr(44) )
      v-email       = "":U
    .
    do v-ind = 1 to v-num-entries
    :
      assign
        v-tmp1-str = entry( v-ind, v-tmp-str, chr(44) )
      .
      if trim( v-tmp1-str ) <> "":U then do:
        if v-email = "":U then do:
          assign
            v-email = v-tmp1-str
          .
        end.
        else do:
          assign
            v-email = v-email + chr(44) + v-tmp1-str
          .
        end.
      end.
    end.
    if v-email <> "":U then do:
      run gbl/sendmail.p
        ( input v-email
        , input p-subject
        , input p-text-err
        , input p-attach-files
        ) no-error .
      if error-status :error
        or return-value <> "":U
      then do:
        return error substitute( "&1 (send-msg-to-email). &2", vss-workfile, return-value ) .
      end.
    end.
  end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   DEFINE NEW GLOBAL SHARED VARIABLE hpApi AS HANDLE NO-UNDO.
   IF NOT VALID-HANDLE(hpApi) THEN run gbl/windows.p PERSISTENT SET hpApi.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW GLOBAL SHARED VARIABLE hpWinFunc AS HANDLE NO-UNDO.
  IF NOT VALID-HANDLE(hpWinFunc) THEN run gbl/winfunc.p PERSISTENT SET hpWinFunc.
FUNCTION GetLastError
         RETURNS INTEGER
         ()
         IN hpWinFunc.
FUNCTION GetParent
         RETURNS INTEGER
         (input hwnd as INTEGER)
         IN hpWinFunc.
FUNCTION ShowLastError
         RETURNS INTEGER
         ()
         IN hpWinFunc.
FUNCTION CreateProcess
         RETURNS INTEGER
         (input CommandLine as CHAR,
          input CurrentDir  as CHAR,
          input wShowWindow as INTEGER)
         in hpWinFunc.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function IsProcessRunning return integer
  (PID AS INTEGER) :
  DEFINE VARIABLE IsRunning   AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE VARIABLE hProcess    AS INTEGER NO-UNDO.
  DEFINE VARIABLE ExitCode    AS INTEGER NO-UNDO.
  DEFINE VARIABLE ReturnValue AS INTEGER NO-UNDO.
  define variable rv          as integer no-undo .
  RUN OpenProcess in hpapi
                  ( 1024,
                    0,
                    PID,
                    OUTPUT hProcess).
  IF hProcess NE 0 THEN DO:
     RUN GetExitcodeProcess in hpapi
                  ( hProcess,
                    OUTPUT ExitCode,
                    OUTPUT ReturnValue).
     rv = (if (ExitCode=259) AND (ReturnValue NE 0)
          then  - 1
          else ReturnValue).
     RUN CloseHandle in hpapi (hProcess, OUTPUT ReturnValue).
  END.
  RETURN rv.
end.
define variable vss-include-info7 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable hAppRunningMutex as integer no-undo initial 0 .
FUNCTION ValidateProductSuite RETURN LOGICAL (SuitName AS CHARACTER):
   DEFINE VARIABLE key-hdl        AS INTEGER NO-UNDO.
   DEFINE VARIABLE lpBuffer       AS MEMPTR  NO-UNDO.
   DEFINE VARIABLE lth            AS INTEGER NO-UNDO.
   DEFINE VARIABLE datatype       AS INTEGER NO-UNDO.
   DEFINE VARIABLE ReturnValue    AS INTEGER NO-UNDO.
   DEFINE VARIABLE retval         AS LOGICAL NO-UNDO INITIAL FALSE.
   RUN RegOpenKeyA IN hpApi
                  ( -2147483646,
                    "System\CurrentControlSet\Control\ProductOptions",
                    OUTPUT key-hdl,
                    OUTPUT ReturnValue).
   IF ReturnValue NE 0 THEN
      RETURN FALSE.
   ASSIGN lth                = 260 + 1
          SET-SIZE(lpBuffer) = lth.
   RUN RegQueryValueExA IN hpApi
                       ( key-hdl,
                         "ProductSuite",
                         0,
                         OUTPUT datatype,
                         GET-POINTER-VALUE(lpBuffer),
                         INPUT-OUTPUT lth,
                         OUTPUT ReturnValue).
   IF ReturnValue = 0 THEN
       retval =  (GET-STRING(lpBuffer,1)=SuitName).
   SET-SIZE(lpBuffer)=0.
   IF key-hdl NE 0 THEN
      RUN RegCloseKey IN hpApi (key-hdl,OUTPUT ReturnValue).
   RETURN retval.
END FUNCTION.
FUNCTION IsAppAlreadyRunning RETURN LOGICAL
   (p-OnePerSystem AS LOGICAL, p-AppName AS CHARACTER):
  DEFINE VARIABLE ReturnValue AS INTEGER NO-UNDO.
  DEFINE VARIABLE MutexName   AS CHARACTER    NO-UNDO.
  MutexName = ''.
  IF p-OnePerSystem AND ValidateProductSuite("Terminal Server") THEN
     MutexName = MutexName + "Global\".
  MutexName = MutexName + p-AppName + ' is running'.
  RUN CreateMutexA IN hpApi(0,0,MutexName, OUTPUT hAppRunningMutex).
  IF hAppRunningMutex NE 0 THEN DO:
     RUN WaitForSingleObject IN hpApi (hAppRunningMutex,100, OUTPUT ReturnValue).
     IF NOT (ReturnValue=128 OR
             ReturnValue=0) THEN DO:
        RUN CloseHandle IN hpApi(hAppRunningMutex, OUTPUT ReturnValue).
        hAppRunningMutex = 0.
     END.
  END.
  RETURN (hAppRunningMutex = 0).
END.
PROCEDURE LetAnotherInstanceRun :
  DEFINE INPUT PARAMETER p-AppName AS CHARACTER NO-UNDO.
  DEFINE  VARIABLE ReturnValue AS INTEGER NO-UNDO.
  IF hAppRunningMutex NE 0 THEN DO:
        RUN CloseHandle IN hpApi(hAppRunningMutex, OUTPUT ReturnValue).
        hAppRunningMutex = 0.
  END.
END PROCEDURE.
define temp-table tt_auto-session no-undo
  field session-pid  as integer   initial 0
  field session-type as character
  field session-name as character
  field proc-name    as character
  field add-mode     as character
  index pi is unique primary session-pid session-type
  index i_proc proc-name
  index i_type session-type
  .
define buffer X_auto-session for tt_auto-session .
define variable v-rid-list as character no-undo .
define variable v-start-mode as character no-undo .
define variable v-exefile  as character no-undo .
define variable v-inifile  as character no-undo .
define variable v-work-dir as character no-undo .
define variable log-exit as logical   no-undo .
define stream VarStream .
define variable v-varstr   as character no-undo .
define variable v-varfile  as character no-undo .
define variable v-task-name as character no-undo .
define variable vDopParamSession as character no-undo .
get-key-value section "THAutoSessions"
                key "DopParamSession"
              value vDopParamSession.
if vDopParamSession = ? then
  vDopParamSession = "".
FUNCTION ATH-var-name RETURNS CHARACTER
  ( INPUT p-pid AS INTEGER )  FORWARD.
DEFINE VAR auto-st AS WIDGET-HANDLE NO-UNDO.
DEFINE MENU POPUP-MENU-b-start
       MENU-ITEM m_b-start-view LABEL "Сессия видна"
       MENU-ITEM m_b-start-hidden LABEL "Сессия не видна".
DEFINE BUTTON b-exit AUTO-GO DEFAULT
     LABEL "Вы&ход "
     SIZE 10 BY 1 TOOLTIP "Выход из автоматической системы"
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON b-start
     LABEL "&Выполнить"
     SIZE 10 BY 1.
DEFINE BUTTON b-stop
     LABEL "&Останов"
     SIZE 10 BY 1.
DEFINE BUTTON b-view-hide
     LABEL "По&казать/Скрыть"
     SIZE 16 BY 1.
DEFINE VARIABLE mark-num AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 10.5 BY .67
     FGCOLOR 7  NO-UNDO.
DEFINE QUERY br-auto-sessions FOR
      X_auto-session SCROLLING.
DEFINE BROWSE br-auto-sessions
  QUERY br-auto-sessions DISPLAY
      mark-string( input recid(X_auto-session), input v-rid-list) column-label "*" format "X(1)":U
X_auto-session.session-pid  column-label "PID"                    format ">>>>>>>>>9":U
X_auto-session.session-name column-label "Название задания"       format "X(40)":U
X_auto-session.add-mode     column-label "Доп. установки"         format "X(50)":U width-chars 14
X_auto-session.session-type column-label "Тип"                    format "X(10)":U
X_auto-session.proc-name    column-label "Запускающая процедура"  format "X(20)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 20.75.
DEFINE FRAME f-auto-start
     b-exit AT ROW 1 COL 2.5
     b-mark AT ROW 1 COL 17 WIDGET-ID 4
     b-start AT ROW 1 COL 20 WIDGET-ID 6
     b-stop AT ROW 1 COL 30 WIDGET-ID 10
     b-view-hide AT ROW 1 COL 40 WIDGET-ID 12
     B-Help AT ROW 1 COL 95 WIDGET-ID 2
     br-auto-sessions AT ROW 2.75 COL 2.5 WIDGET-ID 100
     mark-num AT ROW 2 COL 2 NO-LABEL WIDGET-ID 8
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 99.38 BY 22.54.
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW auto-st ASSIGN
         HIDDEN             = YES
         TITLE              = "Запуск автопроцессов и поддержание их работы"
         HEIGHT             = 22.88
         WIDTH              = 99.25
         MAX-HEIGHT         = 41.58
         MAX-WIDTH          = 160
         VIRTUAL-HEIGHT     = 41.58
         VIRTUAL-WIDTH      = 160
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE auto-st = CURRENT-WINDOW.
ASSIGN
       b-start:POPUP-MENU IN FRAME f-auto-start       = MENU POPUP-MENU-b-start:HANDLE.
ASSIGN
       br-auto-sessions:ALLOW-COLUMN-SEARCHING IN FRAME f-auto-start = TRUE
       br-auto-sessions:COLUMN-RESIZABLE IN FRAME f-auto-start       = TRUE
       br-auto-sessions:COLUMN-MOVABLE IN FRAME f-auto-start         = TRUE.
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(auto-st)
THEN auto-st:HIDDEN = yes.
ON END-ERROR OF auto-st
OR ENDKEY OF auto-st ANYWHERE DO:
  RETURN NO-APPLY.
END.
ON WINDOW-CLOSE OF auto-st
DO:
  RETURN NO-APPLY.
END.
ON CHOOSE OF b-exit IN FRAME f-auto-start
DO:
  define variable v-answer as logical   no-undo .
  run gbl/q-wait.w
    ( input substitute( "Вы хотите завершить работу авторежима?" )
     ,input false
     ,input 20
     ,output v-answer
    ) no-error .
  if error-status :error
    or v-answer = true
  then do:
    if error-status :error then do:
    end.
    for each tt_auto-session
    :
      if lookup( "H":U, tt_auto-session.add-mode, "+":U ) > 0 then do:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid10 as character no-undo .
define variable v-num-entry10 as integer   no-undo .
assign
  v-str-recid10 = trim( string( recid( tt_auto-session ) , "->>>>>>>>>>>9":U ) )
  v-num-entry10 = lookup( v-str-recid10 , v-rid-list )
.
if v-num-entry10 > 0 then do:
  assign
    entry( v-num-entry10, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid10
  .
end.
      end.
    end.
    run stop-sessions in this-procedure
      no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute("Ошибка при остановке сессий.") skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return no-apply .
    end.
    for each tt_auto-session
    :
      delete tt_auto-session .
    end.
    assign
      log-exit = yes
    .
  end.
END.
ON CHOOSE OF b-mark IN FRAME f-auto-start
DO:
  define variable loc#log as logical no-undo .
  if available X_auto-session then do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid12 as character no-undo .
define variable v-num-entry12 as integer   no-undo .
assign
  v-str-recid12 = trim( string( recid( X_auto-session ) , "->>>>>>>>>>>9":U ) )
  v-num-entry12 = lookup( v-str-recid12 , v-rid-list )
.
if v-num-entry12 > 0 then do:
  assign
    entry( v-num-entry12, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid12
  .
end.
    loc#log = br-auto-sessions:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-auto-sessions:select-next-row ().
        apply "VALUE-CHANGED" to br-auto-sessions in frame f-auto-start.
    end.
    if num-entries( v-rid-list ) = 0 then do:
      hide mark-num in frame f-auto-start.
    end.
    else do:
      display
        num-entries( v-rid-list ) @ mark-num
        with frame f-auto-start.
    end.
  end.
  apply "entry" to br-auto-sessions in frame f-auto-start.
END.
ON CHOOSE OF b-start IN FRAME f-auto-start
DO:
  define variable v-recid as recid no-undo initial ? .
  if trim( v-rid-list ) = "":U
    and available X_auto-session
    and X_auto-session.session-pid = 0
  then do:
    assign
      v-rid-list = string( recid ( X_auto-session ) )
    .
  end.
  if available X_auto-session then do:
    assign
      v-recid = recid( X_auto-session )
    .
  end.
  run start-sessions in this-procedure
    ( input v-start-mode
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при запуске сессий.") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.
  run my_refresh in this-procedure
    ( input v-recid
    ).
  apply "entry" to br-auto-sessions.
END.
ON CHOOSE OF b-stop IN FRAME f-auto-start
DO:
  if trim( v-rid-list ) = "":U
    and available X_auto-session
    and X_auto-session.session-pid > 0
  then do:
    assign
      v-rid-list = string( recid ( X_auto-session ) )
    .
  end.
  run stop-sessions in this-procedure
    no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при остановке сессий.") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.
  run my_refresh in this-procedure
    ( input ?
    ).
  apply "entry" to br-auto-sessions.
END.
ON CHOOSE OF b-view-hide IN FRAME f-auto-start
DO:
  define variable v-recid as recid no-undo initial ? .
  if available X_auto-session then do:
    assign
      v-recid = recid( X_auto-session )
    .
  end.
  if trim( v-rid-list ) = "":U
    and available X_auto-session
    and X_auto-session.session-pid > 0
  then do:
    assign
      v-rid-list = string( recid ( X_auto-session ) )
    .
  end.
  run view-hide-sessions in this-procedure
    no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при запуске сессий.") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.
  run my_refresh in this-procedure
    ( input v-recid
    ).
  apply "entry" to br-auto-sessions.
END.
ON CHOOSE OF MENU-ITEM m_b-start-hidden
DO:
  assign
    v-start-mode = "H":U
  .
  apply "choose" to b-start in frame f-auto-start.
END.
ON CHOOSE OF MENU-ITEM m_b-start-view
DO:
  if index(vDopParamSession,"-b") <> 0 then
  do:
    message "Запуск в режиме ~"Сессия видна~" не допустим с параметром -b" skip
            "в настройках ini-файла в параметра DopParamSession секции [THAutoSessions]."
            view-as alert-box.
    return no-apply.
  end.
  assign
    v-start-mode = "":U
  .
  apply "choose" to b-start in frame f-auto-start.
END.
ASSIGN CURRENT-WINDOW                = auto-st
      THIS-PROCEDURE:CURRENT-WINDOW = auto-st.
on close of this-procedure
do:
  apply "choose" to b-exit in frame f-auto-start.
  return no-apply.
end.
PAUSE 0 BEFORE-HIDE.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame f-auto-start
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame f-auto-start
do:
  apply "help":u to frame f-auto-start .
end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame f-auto-start:width - 0.3
                fh            = frame f-auto-start:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame f-auto-start anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame f-auto-start. END.
  return no-apply.
end.
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame f-auto-start anywhere do:
  if b-exit :sensitive then DO: apply "CHOOSE":U to b-exit in frame f-auto-start. END.
  return no-apply.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, retry MAIN-BLOCK
   ON STOP    UNDO MAIN-BLOCK, retry MAIN-BLOCK:
  define variable v-start-time      as int64     no-undo .
  define variable v-read-ini        as character no-undo .
  define variable v-num-sessions    as integer   no-undo .
  define variable v-ind             as integer   no-undo .
  define variable v-start-proc      as character no-undo .
  define variable v-add-mode        as character no-undo .
  define variable v-num-entries     as integer   no-undo .
  define variable v-ind1            as integer   no-undo .
  define variable v-curr-mode       as character no-undo .
  define variable v-curr-mode-name  as character no-undo .
  define variable v-new-add-mode    as character no-undo .
  define variable v-new-hidden-mode as logical   no-undo .
  define variable v-msg                as character no-undo .
  assign
    auto-st:title = substitute( "PID: &1. &2 для &3", g#auto-pid, auto-st:title, p-db-info )
    file-info:file-name = ".":U
    v-work-dir = file-info:full-pathname
    log-file-name = v-work-dir + chr(92) + "auto-st.log":U
  .
  run write-to-log in this-procedure
    ( substitute( "Запуск диспетчера автопроцессов." )
    ) .
  assign
    v-task-name = substitute( "OEApp TH 16_0 AutoTaskМanager &1", p-db-info )
  .
  if IsAppAlreadyRunning(true, v-task-name ) then do:
    assign
      v-msg = substitute("Диспетчер задач для &1 уже запущен!", p-db-info )
    .
    if p-no-message = false then do:
      message
        v-msg
        view-as alert-box information .
    end.
    else do:
      run write-to-log in this-procedure
        ( input v-msg
        ) .
    end.
    return .
  end.
  run gbl/getexini.p
    ( output v-exefile
     ,output v-inifile
    ) no-error .
  if error-status :error then do:
    assign
      v-msg = substitute( "&1. Ошибка при определении имени выполняемого файла и *.ini файла &2&3&2&4"
                          , vss-workfile
                          , chr(10)
                          , error-status :get-message(1)
                          , return-value
                        ) .
    if p-no-message = false then do:
      message
        v-msg
        view-as alert-box error .
    end.
    else do:
      run write-to-log in this-procedure
        ( input v-msg
        ) .
    end.
    undo, return error .
  end.
  assign
    b-start:menu-mouse in frame f-auto-start = 1
  .
  run init-session in this-procedure .
  get-key-value
    section "THAutoSessions"
    key "NumAutoSessions"
    value v-read-ini
  .
  assign
    v-num-sessions = integer( v-read-ini ) no-error
  .
  if v-num-sessions = ?
    or error-status :error
  then do:
    assign
      v-msg = substitute( "Не задано или задано неверно кол-во обрабатываемых автосессий.&1"
                         + "(секция THSessions ключ NumSession в .ini файле).&1"
                         + "NumSession в ini: &2&1"
                         , v-read-ini
                        ) .
    if p-no-message = false then do:
      message
        v-msg
        view-as alert-box information .
    end.
    else do:
      run write-to-log in this-procedure
        ( input v-msg
        ) .
    end.
  end.
  else do:
    do v-ind = 1 to v-num-sessions
    :
      v-msg = "".
      get-key-value
        section "THAutoSessions"
        key substitute( "AutoSession&1", v-ind )
        value v-read-ini
      .
      if v-read-ini <> ?
        and v-read-ini <> "":U
      then do:
        assign
          v-read-ini   = caps( v-read-ini )
          v-add-mode   = "":U
        .
        if num-entries( v-read-ini, "+":U ) > 1 then do:
          assign
            v-num-entries  = num-entries( v-read-ini, "+":U )
            v-new-add-mode = "":U
          .
          do v-ind1 = 1 to v-num-entries
          :
            assign
              v-curr-mode      = entry( v-ind1, v-read-ini, "+":U )
              v-curr-mode-name = entry( 1, v-curr-mode, ":":U )
            .
            if trim( v-curr-mode-name ) <> "":U then do:
              case v-curr-mode-name :
                when "SN" then do:
                  assign
                    v-start-proc = lc( entry( 2, v-curr-mode, ":":U ) )
                  .
                end.
                when "H":U
                or when "R":U
                or when "DB":U
                or when "ExtSys":U
                or when "Sock":U
                or when "ProcName":U
                then do:
                  assign
                    v-new-add-mode = v-new-add-mode + "+":U + v-curr-mode
                  .
                end.
                otherwise do:
                  run write-to-log ( substitute( "&1. Неизвестный ключ (&2) запуска автопроцесса (&3)! Ключ игнорируется", vss-workfile, v-curr-mode, v-start-proc ) ).
                end.
              end case.
            end.
          end.
          assign
            v-add-mode = left-trim( v-new-add-mode, "+":U )
          .
        end.
        if index(vDopParamSession,"-b") <> 0 and
           lookup( "H":U, v-add-mode, "+":U ) = 0 then
        do:
          v-msg = "Автопроцесс с ключом -b в параметре DopParamSession может быть запущен только в скрытом режиме".
          if p-no-message = false then do:
            message
              v-msg
              view-as alert-box error .
          end.
          else do:
            run write-to-log in this-procedure
              ( input v-msg
              ) .
          end.
          next.
        end.
        find first X_auto-session
          where X_auto-session.session-type = v-start-proc
            and X_auto-session.session-pid  = 0
          no-error .
        if available X_auto-session then do:
          assign
            v-rid-list = string( recid( X_auto-session ) )
          .
          run start-sessions in this-procedure
            ( input v-add-mode
            ) no-error .
          if error-status :error then do:
            assign
              v-msg = substitute( "&1. Ошибка при запуске автопроцесса с типом '&2' &3&4&3&5"
                                  , vss-workfile
                                  , v-start-proc
                                  , chr(10)
                                  , error-status :get-message(1)
                                  , return-value
                                ) .
            if p-no-message = false then do:
              message
                v-msg
                view-as alert-box error .
            end.
            else do:
              run write-to-log in this-procedure
                ( input v-msg
                ) .
            end.
          end.
        end.
        else do:
          assign
            v-msg = substitute( "&1. Отсутствует автопроцесс с типом '&2'"
                                , vss-workfile
                                , v-start-proc
                              ) .
          if p-no-message = false then do:
            message
              v-msg
              view-as alert-box error .
          end.
          else do:
            run write-to-log in this-procedure
              ( input v-msg
              ) .
          end.
        end.
      end.
    end.
  end.
  if p-hidden-mode = false then do:
    run myenable in this-procedure .
  end.
  main-cycl:
  do while not log-exit
  on error  undo, leave main-cycl
  on stop   undo, next
  on endkey undo, next
  :
    if p-hidden-mode = false then do:
      run my_refresh in this-procedure
        ( input (if available X_auto-session then recid( X_auto-session ) else ? )
        ).
    end.
    assign
      v-start-time = etime
    .
    do while not log-exit:
      if p-hidden-mode = false then do:
        wait-for
          go of frame f-auto-start
          or close of this-procedure
          or choose of b-start in frame f-auto-start
          or choose of b-help in frame f-auto-start
          focus frame f-auto-start
          pause 1
        .
      end.
      else do:
        wait-for
          go of frame f-auto-start
          or close of this-procedure
          pause 1
          .
      end.
      assign
        file-info:file-name = ATH-var-name( g#auto-pid )
        v-varfile           = file-info:full-pathname
      .
      if v-varfile <> ? then do:
        assign
          v-varstr = "":U
        .
        input stream VarStream from value( v-varfile ) .
        block_read-var:
        repeat :
          import stream VarStream unformatted v-varstr no-error .
          leave block_read-var .
        end.
        input stream VarStream close.
        if lookup( "H":U, v-varstr, "+":U ) = 0 then do:
          assign
            v-new-hidden-mode = false
          .
        end.
        else do:
          assign
            v-new-hidden-mode = true
          .
        end.
        os-delete value( v-varfile ) .
        if v-new-hidden-mode <> p-hidden-mode then do:
          assign
            p-hidden-mode = v-new-hidden-mode
          .
          run write-to-log ( substitute( "Смена статуса 'видимости' сессии. Теперь сессия &1видна.", (if p-hidden-mode = true then "не":U else "") ) ).
        end.
      end.
      if p-hidden-mode = false
        and frame f-auto-start:visible = false
      then do:
        run myenable in this-procedure .
      end.
      if p-hidden-mode = true
        and frame f-auto-start:visible = true
      then do:
        run myhide in this-procedure .
      end.
      if etime - v-start-time > 60000
      then do:
        leave .
      end.
    end.
    run restart-sessions in this-procedure .
  end.
  for each tt_auto-session
  :
    delete tt_auto-session .
  end.
  RUN disable_UI in this-procedure .
  run LetAnotherInstanceRun( v-task-name ) .
  run write-to-log in this-procedure
    ( substitute( "Завершение работы диспетчера автопроцессов." )
    ) .
END.
PROCEDURE disable_UI :
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(auto-st)
  THEN DELETE WIDGET auto-st.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY mark-num
      WITH FRAME f-auto-start IN WINDOW auto-st.
  ENABLE b-exit b-mark b-start b-stop b-view-hide b-help br-auto-sessions
         mark-num
      WITH FRAME f-auto-start IN WINDOW auto-st.
  OPEN QUERY br-auto-sessions FOR EACH X_auto-session .
  VIEW auto-st.
END PROCEDURE.
PROCEDURE init-session :
create X_auto-session .
  assign
    X_auto-session.session-type = 'autonws':U
    X_auto-session.session-name = "Новости"
    X_auto-session.proc-name    = "adm/l-i-nws.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = 'autoarh':U
    X_auto-session.session-name = "Архивы"
    X_auto-session.proc-name    = "adm/l-i-arc.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = 'autoexp':U
    X_auto-session.session-name = "Экспорт"
    X_auto-session.proc-name    = "adm/l-i-exp.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = 'autooxml':U
    X_auto-session.session-name = "OpenXML"
    X_auto-session.proc-name    = "adm/l-i-oxml.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = 'autogcd':U
    X_auto-session.session-name = "Прием инф. с касс"
    X_auto-session.proc-name    = "adm/l-igetcd.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = 'autosale':U
    X_auto-session.session-name = "Обработка продаж"
    X_auto-session.proc-name    = "adm/l-iasale.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = 'autosuz':U
    X_auto-session.session-name = "Отчеты"
    X_auto-session.proc-name    = "adm/l-i-suz.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = 'autocbnk':U
    X_auto-session.session-name = "Эксп/имп в КЛИЕНТ-БАНК"
    X_auto-session.proc-name    = "adm/l-iacbnk.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = 'autofree':U
    X_auto-session.session-name = "Произвольные задания"
    X_auto-session.proc-name    = "adm/l-i-free.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = 'sktsrv':U
    X_auto-session.session-name = "Сокет Сервер"
    X_auto-session.proc-name    = "adm/l-i-skt.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = 'mercury':U
    X_auto-session.session-name = "Меркурий"
    X_auto-session.proc-name    = "adm/l-i-merc.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = 'is_motp':U
    X_auto-session.session-name = "ИС МОТП"
    X_auto-session.proc-name    = "adm/l-i-motp.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = 'is_diadoc':U
    X_auto-session.session-name = "ИС Diadoc"
    X_auto-session.proc-name    = "adm/l-i-diadoc.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = 'hddtest':U
    X_auto-session.session-name = "Мониторинг HDD"
    X_auto-session.proc-name    = "adm/l-i-hddtest.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = 'is_PM':U
    X_auto-session.session-name = "Выгрузка в ИС Президентский Мониторинг"
    X_auto-session.proc-name    = "adm/l-i-is_PM.w":U
  .
END PROCEDURE.
PROCEDURE myenable :
  assign
    auto-st:HIDDEN = false
  .
  run enable_UI .
END PROCEDURE.
PROCEDURE myhide :
  disable all with frame f-auto-start .
  hide all no-pause in window auto-st .
  assign
    auto-st:HIDDEN = true
  .
END PROCEDURE.
PROCEDURE my_refresh :
define input  parameter p-recid as recid     no-undo .
  define variable v-ok as logical   no-undo .
  assign
    v-ok = browse br-auto-sessions :set-repositioned-row( browse br-auto-sessions :focused-row, 'CONDITIONAL':U)
  .
  OPEN QUERY br-auto-sessions FOR EACH X_auto-session .
  reposition br-auto-sessions to recid p-recid no-error.
  if num-entries( v-rid-list ) = 0 then do:
    hide mark-num in frame f-auto-start.
  end.
  else do:
    display
      num-entries( v-rid-list ) @ mark-num
      with frame f-auto-start.
  end.
END PROCEDURE.
PROCEDURE restart-sessions :
define buffer buf_auto-session for tt_auto-session .
  define buffer et_auto-session  for tt_auto-session .
  define buffer new_auto-session for tt_auto-session .
  define variable v-restart   as logical   no-undo .
  define variable v-pid       as integer   no-undo .
  define variable v-mode      as character no-undo .
  define variable v-proc-name as character no-undo .
  define variable v-sess-name as character no-undo .
  for each buf_auto-session
    where buf_auto-session.session-pid > 0
  on error undo, next
  :
    assign
      v-proc-name = buf_auto-session.proc-name
      v-mode      = buf_auto-session.add-mode
      v-sess-name = buf_auto-session.session-name
      v-restart   = false
      file-info:file-name = substitute( "./ATH&1.pid", buf_auto-session.session-pid )
    .
    if file-info:full-pathname <> ?
      and ( ( file-info:file-create-date = today
              and file-info:file-create-time < time + 60
            )
            or file-info:file-create-date < today
          )
    then do:
      os-delete value( file-info:full-pathname ) .
      assign
        v-restart = true
      .
    end.
    else do:
      if IsProcessRunning( buf_auto-session.session-pid ) <> -1 then do:
        if lookup( "H":U, v-mode, "+":U ) > 0
          or lookup( "R":U, v-mode, "+":U ) > 0
        then do:
          assign
            v-restart = true
          .
        end.
        else do:
          run write-to-log in this-procedure
            ( substitute( "Сессия '&1' (PID &2) завершила работу.", buf_auto-session.session-name, buf_auto-session.session-pid )
            ) .
          os-delete value( ATH-var-name( buf_auto-session.session-pid ) ) no-error .
          delete buf_auto-session .
        end.
      end.
    end.
    if v-restart = true then do:
      run gbl/termprc.p
        ( input buf_auto-session.session-pid
        ) .
      run write-to-log in this-procedure
        ( substitute( "Остановка сессии '&1' (PID &2) для перезапуска. ", buf_auto-session.session-name, buf_auto-session.session-pid )
        ) .
      os-delete value( ATH-var-name( buf_auto-session.session-pid ) ) no-error .
      delete buf_auto-session .
      run run-session in this-procedure
        ( input  v-sess-name
        , input  v-proc-name
        , input  v-mode
        , output v-pid
        ) no-error .
      if error-status :error
        or v-pid = 0
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при запуске сессии." skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        next .
      end.
      find first et_auto-session
        where et_auto-session.proc-name   = v-proc-name
          and et_auto-session.session-pid = 0
        no-error .
      if available et_auto-session then do:
        create new_auto-session .
        buffer-copy et_auto-session to new_auto-session
          assign
            new_auto-session.session-pid = v-pid
            new_auto-session.add-mode    = v-mode
        .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE run-session :
define input  parameter p-sess-name as character no-undo .
  define input  parameter p-proc-name as character no-undo .
  define input  parameter p-mode      as character no-undo .
  define output parameter p-pid       as integer   no-undo .
  do
  on error undo, return error return-value
  :
    define variable vDopParamSessionRandom     as int no-undo .
    define variable vDopParam                  as character no-undo .
    if vDopParamSession eq ?
    then
       vDopParam = "".
    else do:
       vDopParamSessionRandom = random(1,9999999).
       vDopParam = substitute (vDopParamSession,vDopParamSessionRandom).
    end.
    define variable v-command-line     as character no-undo .
    define variable v-command-line-log as character no-undo .
    assign
      v-command-line = substitute( '&1 -ininame &2 -basekey "INI" -p &3 -param "U:&4,P:&5,M:&6" &7'
                                   , v-exefile
                                   , v-inifile
                                   , p-proc-name
                                   , g#auto-user-login
                                   , g#auto-user-password
                                   , replace( p-mode, ",":U, chr(4) )
                                   , vDopParam
                                 )
      v-command-line-log = substitute( '&1 -ininame &2 -basekey "INI" -p &3 -param "U:&4,P:&5,M:&6" &7'
                                   , v-exefile
                                   , v-inifile
                                   , p-proc-name
                                   , g#auto-user-login
                                   , "***"
                                   , replace( p-mode, ",":U, chr(4) )
                                   , vDopParam
                                 )
    .
    run gbl/run-gpid.p
      ( input v-command-line
       ,input v-work-dir
       ,output p-pid
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1&2&3&2Параметры запуска сессии: &4", error-status :get-message(1), chr(10), return-value, v-command-line-log ) .
    end.
    run write-to-log in this-procedure
      ( substitute( "Запуск сессии '&1' (PID &2). Cтрока запуска: &3", p-sess-name, p-pid, v-command-line-log )
      ) .
 end.
END PROCEDURE.
PROCEDURE start-sessions :
define input  parameter p-mode as character no-undo .
  define buffer new_auto-session for tt_auto-session .
  define buffer buf_auto-session for tt_auto-session .
  define variable v-ok           as logical   no-undo .
  define variable v-pid          as integer   no-undo .
  define variable v-ind          as integer   no-undo .
  define variable v-num-entries  as integer   no-undo .
  define variable v-recid        as recid     no-undo .
  define variable v-rid-list-new as character no-undo .
  assign
    v-rid-list-new = v-rid-list
    v-rid-list     = "":U
    v-num-entries  = num-entries( v-rid-list-new )
  .
  block_cycl:
  do v-ind = 1 to v-num-entries
  on error undo, next block_cycl
  :
    assign
      v-ok    = false
      v-recid = integer( entry( v-ind, v-rid-list-new ) )
    .
    find first buf_auto-session
      where recid( buf_auto-session ) = v-recid
      no-error
    .
    if available buf_auto-session then do:
      if buf_auto-session.session-pid = 0 then do:
        run run-session in this-procedure
          ( input buf_auto-session.session-name
          , input buf_auto-session.proc-name
          , input p-mode
          , output v-pid
          ) no-error .
        if error-status :error
          or v-pid = 0
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при запуске сессии." skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          next block_cycl .
        end.
        create new_auto-session .
        buffer-copy buf_auto-session to new_auto-session
          assign
            new_auto-session.session-pid = v-pid
            new_auto-session.add-mode    = p-mode
        .
        assign
          v-ok = true
        .
      end.
      if v-ok <> true then do:
        assign
          v-rid-list = (if v-rid-list = "":U then "":U else chr(44)) + string( v-recid )
        .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE stop-sessions :
define buffer new_auto-session for tt_auto-session .
  define buffer buf_auto-session for tt_auto-session .
  define variable v-ok           as logical   no-undo .
  define variable v-pid          as integer   no-undo .
  define variable v-ind          as integer   no-undo .
  define variable v-num-entries  as integer   no-undo .
  define variable v-recid        as recid     no-undo .
  define variable v-rid-list-new as character no-undo .
  assign
    v-rid-list-new = v-rid-list
    v-rid-list     = "":U
    v-num-entries  = num-entries( v-rid-list-new )
  .
  block_cycl:
  do v-ind = 1 to v-num-entries
  on error undo, next block_cycl
  :
    assign
      v-ok    = false
      v-recid = integer( entry( v-ind, v-rid-list-new ) )
    .
    find first buf_auto-session
      where recid( buf_auto-session ) = v-recid
      no-error
    .
    if available buf_auto-session then do:
      if buf_auto-session.session-pid > 0 then do:
        run gbl/termprc.p
          ( input buf_auto-session.session-pid
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute( "Ошибка при остановке сессии : &1", buf_auto-session.session-pid ) skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          next block_cycl .
        end.
        run write-to-log in this-procedure
          ( substitute( "Остановка сессии '&1' (PID &2) пользователем. ", buf_auto-session.session-name, buf_auto-session.session-pid )
          ) .
        os-delete value( ATH-var-name( buf_auto-session.session-pid ) ) no-error .
        delete buf_auto-session .
        assign
          v-ok = true
        .
      end.
      if v-ok <> true then do:
        assign
          v-rid-list = (if v-rid-list = "":U then "":U else chr(44)) + string( v-recid )
        .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE view-hide-sessions :
  do
  on error undo, return error return-value
  :
    define buffer buf_auto-session for tt_auto-session .
    define variable v-ok           as logical   no-undo .
    define variable v-ind          as integer   no-undo .
    define variable v-num-entries  as integer   no-undo .
    define variable v-recid        as recid     no-undo .
    define variable v-rid-list-new as character no-undo .
    define variable v-ind1         as integer   no-undo .
    define variable v-num-entries1 as integer   no-undo .
    define variable v-add-mode     as character no-undo .
    define variable v-new-add-mode as character no-undo .
    assign
      v-rid-list-new = v-rid-list
      v-rid-list     = "":U
      v-num-entries  = num-entries( v-rid-list-new )
    .
    block_cycl:
    do v-ind = 1 to v-num-entries
    on error undo, next block_cycl
    :
      assign
        v-ok    = false
        v-recid = integer( entry( v-ind, v-rid-list-new ) )
      .
      find first buf_auto-session
        where recid( buf_auto-session ) = v-recid
        no-error
      .
      if available buf_auto-session then do:
        if buf_auto-session.session-pid > 0 then do:
          if lookup( "H":U, buf_auto-session.add-mode, "+":U ) = 0 then do:
            assign
              buf_auto-session.add-mode = buf_auto-session.add-mode + "+H":U
            .
          end.
          else do:
            assign
              v-num-entries1 = num-entries( buf_auto-session.add-mode, "+":U )
              v-new-add-mode = "":U
            .
            do v-ind1 = 1 to v-num-entries1
            on error undo, next block_cycl
            :
              assign
                v-add-mode = entry( v-ind1, buf_auto-session.add-mode, "+":U )
              .
              if v-add-mode <> "H":U then do:
                assign
                  v-new-add-mode = v-new-add-mode + "+":U + v-add-mode
                .
              end.
            end.
            assign
              buf_auto-session.add-mode = left-trim( v-new-add-mode, "+":U )
            .
          end.
          output stream VarStream to value( ATH-var-name( buf_auto-session.session-pid ) ) .
          put stream VarStream unformatted buf_auto-session.add-mode skip.
          output stream VarStream close.
          assign
            v-ok = true
          .
          run write-to-log in this-procedure
            ( substitute( "Сессия '&1' (PID &2) переведена в &3видимый режим ."
                          ,buf_auto-session.session-name
                          ,buf_auto-session.session-pid
                          ,( if lookup( "H":U, buf_auto-session.add-mode, "+":U ) = 0 then "" else "не" )
                        )
            ) .
          pause 2 no-message .
          assign
            file-info:file-name = ATH-var-name( buf_auto-session.session-pid )
          .
          if file-info:full-pathname <> ? then do:
            message
              substitute("Режим будет изменен как только сессия освободится.") skip
              view-as alert-box information .
          end.
        end.
        if v-ok <> true then do:
          assign
            v-rid-list = (if v-rid-list = "":U then "":U else chr(44)) + string( v-recid )
          .
        end.
      end.
    end.
 end.
END PROCEDURE.
FUNCTION ATH-var-name RETURNS CHARACTER
  ( INPUT p-pid AS INTEGER ) :
  RETURN substitute( "./ATH&1.var", p-pid ).
END FUNCTION.
