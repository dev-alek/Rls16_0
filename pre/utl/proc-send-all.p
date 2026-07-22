block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
define variable mError as logical no-undo.
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
define variable mAsyncProc as class ibs.th.file.AsyncProc.
run ibs\th\file\getasyncproc.p (output mAsyncProc).
define variable mstopAsunc as logical no-undo.
function StopCheck returns logical:
   define variable oFlag as logical no-undo.
   run StopCheckAsync (output oFlag).
   return oFlag.
end.
procedure StopCheckAsync:
    define output  parameter oFlag as logical no-undo.
    if mstopAsunc
    then
       oFlag = mstopAsunc.
    else do:
       oFlag = mAsyncProc:CheckStop().
       mstopAsunc = oFlag.
    end.
end.
function GetParamAsunc returns character
(input iNumPar as integer  ):
   return mAsyncProc:GetPARAM(iNumPar).
end.
function GetParamAsuncStr returns ibs.th.file.asyncparam
(input iParamName as character ):
   return mAsyncProc:GetPARAM(iParamName).
end.
procedure PutMesAsunc:
    define input  parameter Itext as character no-undo.
    define variable vflag as logical no-undo.
    Publish "WriteLogAsunc" (Itext, yes)  .
end.
procedure PutMesAsuncNoTime:
    define input  parameter Itext as character no-undo.
    define variable vflag as logical no-undo.
    Publish "WriteLogAsunc" (Itext,no)  .
end.
procedure PutStatAsunc:
    define input  parameter Itext as character no-undo.
    Publish "PutStatAsunc" (Itext,no) .
     run
    PutMesAsunc (itext).
end.
procedure PutStatAsuncNoTime:
    define input  parameter Itext as character no-undo.
    Publish "PutStatAsunc" (Itext,no)  .
     run
    PutMesAsuncNoTime (itext).
end.
procedure PutStatAsuncAdd:
    define input  parameter Itext as character no-undo.
    Publish "PutStatAsunc" (Itext,yes)  .
end.
procedure PutFileLogAsunc:
    define input  parameter IFile as character no-undo.
    Publish "PutFileLogAsunc" (ifile)  .
end.
       mAsyncProc:mProcPublish = this-procedure.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable g#auto-pid           as integer   no-undo .
define  shared variable conn-par             as character no-undo .
define  shared variable g#auto-user-id       as character no-undo .
define  shared variable g#auto-user-login    as character no-undo .
define  shared variable g#auto-user-password as character no-undo .
define  shared variable v-socket             as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable auto-window-h     as handle    no-undo .
define  shared variable auto-log-msg-h    as handle    no-undo .
define  shared variable hand-log-msg-h    as handle    no-undo .
define  shared variable log-file-name     as character no-undo initial ? .
define  shared variable add-log-file-name as character no-undo initial ? .
define  shared variable writelogvalue     as character no-undo initial ? .
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-loc-counter as integer no-undo .
define variable v-counter-visible as logical no-undo .
define variable v-view-log as logical no-undo .
define stream auto2dia.
PROCEDURE write-log-and-file :
do
on error undo, return error
:
  define input parameter p-tab-position   as integer   no-undo.
  define input parameter p-file-name      as character no-undo .
  define input parameter p-log-level      as integer   no-undo .
  define input parameter p-log-string     AS CHARacter NO-UNDO.
  define variable v-jj as integer   no-undo .
  run write-to-screen in this-procedure( input ( fill( chr(32), p-tab-position) + p-log-string)) .
  if p-file-name <> '':U then do:
    do v-jj = 1 to num-entries(p-file-name, chr(1)):
      run  auto2dia-writefile in this-procedure (
                                      input entry(v-jj, p-file-name, chr(1))
                                      ,input p-log-level
                                      ,input (p-log-string + chr(10))
                                    ) no-error .
    end.
  end.
  if writelogvalue eq "AsyncProc"
  then
     run write-to-log in this-procedure( p-log-string) .
end.
END PROCEDURE.
PROCEDURE get-title :
do
on error undo, return error
:
define output parameter p-title     as character    no-undo.
end.
END PROCEDURE.
PROCEDURE set-title :
do
on error undo, return error
:
define input parameter p-title     as character    no-undo.
run write-to-log in this-procedure( input ( fill( chr(32), 15) + p-title)) .
end.
END PROCEDURE.
PROCEDURE get-counter-value :
do
on error undo, return error
:
define output parameter p-counter     as integer    no-undo.
    assign
    p-counter  = v-loc-counter
    .
end.
END PROCEDURE.
PROCEDURE set-counter-value :
do
on error undo, return error
:
define input parameter p-counter     as integer    no-undo.
    assign
    v-loc-counter = p-counter
    .
end.
END PROCEDURE.
PROCEDURE show-counter :
do
on error undo, return error
:
    assign
    v-counter-visible = true
    .
    process events.
end.
END PROCEDURE.
PROCEDURE hide-counter :
do
on error undo, return error
:
    assign
    v-counter-visible = false
    .
    run hide-message in this-procedure .
    process events.
end.
END PROCEDURE.
PROCEDURE write-counter :
do
on error undo, return error
:
define input parameter p-counter-string     as character    no-undo.
if v-counter-visible then
run write-message in this-procedure ( input p-counter-string) .
process events.
end.
END PROCEDURE.
PROCEDURE get-stop-state :
do
on error undo, return error
:
define output parameter p-stop-state    as logical      no-undo.
end.
END PROCEDURE.
PROCEDURE set-view-log :
do
on error undo, return error
:
define input parameter p-view-log     as logical    no-undo.
    assign
    v-view-log = p-view-log
    .
end.
END PROCEDURE.
PROCEDURE get-view-log :
do
on error undo, return error
:
define output parameter p-view-log     as logical    no-undo.
    assign
    p-view-log = v-view-log
    .
end.
END PROCEDURE.
PROCEDURE write-log :
do
on error undo, return error
:
define input parameter p-tab-position   as integer      no-undo.
define input parameter p-log-string     as character    no-undo.
run write-to-log in this-procedure( input ( fill( chr(32), 1  * p-tab-position)  +
                                    (IF p-log-string = "&Line" THEN FILL("-", 80)
                                    ELSE IF p-log-string = "&DLine" THEN FILL("=", 80)
                                    ELSE p-log-string))).
end.
END PROCEDURE.
procedure writelog :
do
on error undo, return error
:
define input parameter p-file-name AS CHAR     NO-UNDO.
define input parameter p-log-level AS INTEGER  NO-UNDO.
define input parameter p-log-string  AS CHAR     NO-UNDO.
  if p-file-name <> "" then
  run  auto2dia-Writefile in this-procedure (
                                    input p-file-name
                                  ,input p-log-level
                                  ,input p-log-string
                                ) no-error .
   process events.
end.
end procedure.
PROCEDURE auto2dia-writefile:
  define input parameter sFileName AS CHAR     NO-UNDO.
  define input parameter iLogLevel AS INTEGER  NO-UNDO.
  define input parameter sToWrite  AS CHAR     NO-UNDO.
  define variable v-SlashPos  as integer no-undo .
  define variable v-lDirName  as character no-undo .
  define variable v-lDirName2 as character no-undo .
  v-SlashPos  = maximum (  r-index(sFileName, "\"),  r-index(sFileName, "/")  ) .
  v-lDirName  = if v-SlashPos > 0 then substring (sFileName, 1, v-SlashPos - 1) else "".
  FILE-INFO:FILE-NAME = v-lDirName .
  v-lDirName2 = FILE-INFO:FULL-PATHNAME .
  if v-lDirName2 <> ? then do :
OUTPUT STREAM auto2dia TO VALUE(sFileName) APPEND.
    PUT STREAM auto2dia UNFORMATTED chr(10).
    PUT STREAM auto2dia UNFORMATTED (IF (iLogLevel = 0 OR sToWrite = "&DLine"
                                      OR sToWrite = "&Line") THEN "" ELSE
                                      cur-time-string-sec() + " ").
    PUT STREAM auto2dia UNFORMATTED
            (IF sToWrite = "&Line" THEN FILL("-", 80)
             ELSE IF sToWrite = "&DLine" THEN FILL("=", 80)
             ELSE sToWrite).
OUTPUT STREAM auto2dia CLOSE.
  end .
END PROCEDURE.
FUNCTION BinaryXOR RETURNS INT64(INPUT intOperand1 AS INT64,
                                 INPUT intOperand2 AS INT64)
                                 forward .
FUNCTION ShiftRight RETURNS INT64(INPUT in_Operand_A AS INT64,
                                  INPUT in_Operand_B AS INTEGER)
                                  forward .
FUNCTION BinaryAND RETURNS INTEGER (INPUT in_Operand_A AS INT64,
                                    INPUT in_Operand_B AS INT64)
                                    forward .
FUNCTION intToHex RETURNS CHARACTER (i_iint AS INT64) forward .
FUNCTION crc32Table RETURNS INT64 EXTENT 256  () forward .
FUNCTION CRC32 RETURNS INT64 (INPUT mpData AS MEMPTR) forward .
FUNCTION BinaryXOR RETURNS INT64
(INPUT intOperand1 AS INT64,
 INPUT intOperand2 AS INT64):
    DEFINE VARIABLE iByteLoop  AS INTEGER NO-UNDO.
    DEFINE VARIABLE iXOResult  AS INT64 NO-UNDO.
    DEFINE VARIABLE lFirstBit  AS LOGICAL NO-UNDO.
    DEFINE VARIABLE lSecondBit AS LOGICAL NO-UNDO.
    iXOResult = 0.
    DO iByteLoop = 1 TO 64:
        ASSIGN
        lFirstBit  = LOGICAL(GET-BITS(intOperand1,iByteLoop  ,1))
        lSecondBit = LOGICAL(GET-BITS(intOperand2,iByteLoop , 1)).
        IF (lFirstBit  AND NOT lSecondBit) OR
           (lSecondBit AND NOT lFirstBit) THEN
            iXOResult = iXOResult + EXP(2, iByteLoop - 1).
    END.
    RETURN iXOResult.
END .
FUNCTION ShiftRight RETURNS INT64
(INPUT in_Operand_A AS INT64,
 INPUT in_Operand_B AS INTEGER):
   RETURN INT64( TRUNCATE( in_Operand_A / EXP(2,in_Operand_B), 0 ) ).
END .
FUNCTION BinaryAND RETURNS INTEGER
(INPUT in_Operand_A AS INT64,
 INPUT in_Operand_B AS INT64):
   DEFINE VARIABLE in_cbit     AS INTEGER     NO-UNDO.
   DEFINE VARIABLE in_result   AS INT64     NO-UNDO.
   DO in_cbit = 1 TO 64:
      IF LOGICAL( GET-BITS( in_Operand_A, in_cbit, 1 ) ) AND
         LOGICAL( GET-BITS( in_Operand_B, in_cbit, 1 ) )
      THEN
         PUT-BITS( in_result, in_cbit, 1 ) = 1.
  END.
  RETURN in_result.
END .
FUNCTION intToHex RETURNS CHARACTER
(i_iint AS INT64):
   DEF VAR chex  AS CHAR NO-UNDO.
   DEF VAR rbyte AS RAW  NO-UNDO.
   DO WHILE i_iint > 0:
      PUT-BYTE( rbyte, 1 ) = i_iint MODULO 256.
      chex = STRING( HEX-ENCODE( rbyte ) ) + chex.
      i_iint = TRUNCATE( i_iint / 256, 0 ).
   END.
   RETURN chex.
END .
FUNCTION crc32Table RETURNS INT64 EXTENT 256
():
    DEFINE VARIABLE crc32_tab       AS INT64     NO-UNDO EXTENT 256 INITIAL
        [0x00000000, 0x77073096, 0xEE0E612C, 0x990951BA, 0x076DC419, 0x706AF48F,
        0xE963A535, 0x9E6495A3, 0x0EDB8832, 0x79DCB8A4, 0xE0D5E91E, 0x97D2D988,
        0x09B64C2B, 0x7EB17CBD, 0xE7B82D07, 0x90BF1D91, 0x1DB71064, 0x6AB020F2,
        0xF3B97148, 0x84BE41DE, 0x1ADAD47D, 0x6DDDE4EB, 0xF4D4B551, 0x83D385C7,
        0x136C9856, 0x646BA8C0, 0xFD62F97A, 0x8A65C9EC, 0x14015C4F, 0x63066CD9,
        0xFA0F3D63, 0x8D080DF5, 0x3B6E20C8, 0x4C69105E, 0xD56041E4, 0xA2677172,
        0x3C03E4D1, 0x4B04D447, 0xD20D85FD, 0xA50AB56B, 0x35B5A8FA, 0x42B2986C,
        0xDBBBC9D6, 0xACBCF940, 0x32D86CE3, 0x45DF5C75, 0xDCD60DCF, 0xABD13D59,
        0x26D930AC, 0x51DE003A, 0xC8D75180, 0xBFD06116, 0x21B4F4B5, 0x56B3C423,
        0xCFBA9599, 0xB8BDA50F, 0x2802B89E, 0x5F058808, 0xC60CD9B2, 0xB10BE924,
        0x2F6F7C87, 0x58684C11, 0xC1611DAB, 0xB6662D3D, 0x76DC4190, 0x01DB7106,
        0x98D220BC, 0xEFD5102A, 0x71B18589, 0x06B6B51F, 0x9FBFE4A5, 0xE8B8D433,
        0x7807C9A2, 0x0F00F934, 0x9609A88E, 0xE10E9818, 0x7F6A0DBB, 0x086D3D2D,
        0x91646C97, 0xE6635C01, 0x6B6B51F4, 0x1C6C6162, 0x856530D8, 0xF262004E,
        0x6C0695ED, 0x1B01A57B, 0x8208F4C1, 0xF50FC457, 0x65B0D9C6, 0x12B7E950,
        0x8BBEB8EA, 0xFCB9887C, 0x62DD1DDF, 0x15DA2D49, 0x8CD37CF3, 0xFBD44C65,
        0x4DB26158, 0x3AB551CE, 0xA3BC0074, 0xD4BB30E2, 0x4ADFA541, 0x3DD895D7,
        0xA4D1C46D, 0xD3D6F4FB, 0x4369E96A, 0x346ED9FC, 0xAD678846, 0xDA60B8D0,
        0x44042D73, 0x33031DE5, 0xAA0A4C5F, 0xDD0D7CC9, 0x5005713C, 0x270241AA,
        0xBE0B1010, 0xC90C2086, 0x5768B525, 0x206F85B3, 0xB966D409, 0xCE61E49F,
        0x5EDEF90E, 0x29D9C998, 0xB0D09822, 0xC7D7A8B4, 0x59B33D17, 0x2EB40D81,
        0xB7BD5C3B, 0xC0BA6CAD, 0xEDB88320, 0x9ABFB3B6, 0x03B6E20C, 0x74B1D29A,
        0xEAD54739, 0x9DD277AF, 0x04DB2615, 0x73DC1683, 0xE3630B12, 0x94643B84,
        0x0D6D6A3E, 0x7A6A5AA8, 0xE40ECF0B, 0x9309FF9D, 0x0A00AE27, 0x7D079EB1,
        0xF00F9344, 0x8708A3D2, 0x1E01F268, 0x6906C2FE, 0xF762575D, 0x806567CB,
        0x196C3671, 0x6E6B06E7, 0xFED41B76, 0x89D32BE0, 0x10DA7A5A, 0x67DD4ACC,
        0xF9B9DF6F, 0x8EBEEFF9, 0x17B7BE43, 0x60B08ED5, 0xD6D6A3E8, 0xA1D1937E,
        0x38D8C2C4, 0x4FDFF252, 0xD1BB67F1, 0xA6BC5767, 0x3FB506DD, 0x48B2364B,
        0xD80D2BDA, 0xAF0A1B4C, 0x36034AF6, 0x41047A60, 0xDF60EFC3, 0xA867DF55,
        0x316E8EEF, 0x4669BE79, 0xCB61B38C, 0xBC66831A, 0x256FD2A0, 0x5268E236,
        0xCC0C7795, 0xBB0B4703, 0x220216B9, 0x5505262F, 0xC5BA3BBE, 0xB2BD0B28,
        0x2BB45A92, 0x5CB36A04, 0xC2D7FFA7, 0xB5D0CF31, 0x2CD99E8B, 0x5BDEAE1D,
        0x9B64C2B0, 0xEC63F226, 0x756AA39C, 0x026D930A, 0x9C0906A9, 0xEB0E363F,
        0x72076785, 0x05005713, 0x95BF4A82, 0xE2B87A14, 0x7BB12BAE, 0x0CB61B38,
        0x92D28E9B, 0xE5D5BE0D, 0x7CDCEFB7, 0x0BDBDF21, 0x86D3D2D4, 0xF1D4E242,
        0x68DDB3F8, 0x1FDA836E, 0x81BE16CD, 0xF6B9265B, 0x6FB077E1, 0x18B74777,
        0x88085AE6, 0xFF0F6A70, 0x66063BCA, 0x11010B5C, 0x8F659EFF, 0xF862AE69,
        0x616BFFD3, 0x166CCF45, 0xA00AE278, 0xD70DD2EE, 0x4E048354, 0x3903B3C2,
        0xA7672661, 0xD06016F7, 0x4969474D, 0x3E6E77DB, 0xAED16A4A, 0xD9D65ADC,
        0x40DF0B66, 0x37D83BF0, 0xA9BCAE53, 0xDEBB9EC5, 0x47B2CF7F, 0x30B5FFE9,
        0xBDBDF21C, 0xCABAC28A, 0x53B39330, 0x24B4A3A6, 0xBAD03605, 0xCDD70693,
        0x54DE5729, 0x23D967BF, 0xB3667A2E, 0xC4614AB8, 0x5D681B02, 0x2A6F2B94,
        0xB40BBE37, 0xC30C8EA1, 0x5A05DF1B, 0x2D02EF8D].
    RETURN crc32_tab.
END .
FUNCTION CRC32 RETURNS INT64
(INPUT mpData AS MEMPTR):
    DEFINE VARIABLE IN_BYtes_Size   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE in_byte         AS INTEGER   NO-UNDO.
    DEFINE VARIABLE crc_value       AS INT64     NO-UNDO.
    DEFINE VARIABLE tmp             AS INT64     NO-UNDO.
    DEFINE VARIABLE crc32_tab       AS INT64     NO-UNDO EXTENT 256.
    DEFINE VARIABLE in_loop         AS INTEGER     NO-UNDO.
    crc32_tab = crc32Table().
    crc_value = 0xffffffff.
    In_Bytes_Size = GET-SIZE(mpData).
    DO in_loop = 1 TO In_Bytes_Size:
        tmp = BinaryXOR(crc_value, GET-BYTE(mpData,in_loop )).
        crc_value = BinaryXOR( ShiftRight(crc_value, 8), crc32_tab[BinaryAND(tmp,0x00ff) + 1 ] ).
    END.
    crc_value = BinaryXOR(crc_value, 0xffffffff).
    RETURN crc_value.
END .
define temp-table tt-code like code.
function getCashparamHash returns character ():
    define variable exp as ibs.th.bge.xmlimpexp no-undo.
    define variable hQuery   as handle  no-undo .
    define buffer Buf_code for tt-code.
    define buffer     code for    code.
    FOR EACH code where code.parent begins 'cash-param'
                    and num-entries(code.parent,chr(4)) eq 4
    no-lock:
       create Buf_code.
       buffer-copy code except export_ nwsgbd procview procedit to Buf_code.
    end.
    create query hQuery.
    hQuery:set-buffers(buffer Buf_code :HANDLE).
    hQuery:query-prepare("FOR EACH Buf_code").
    hQuery:query-open ().
    exp = new ibs.th.bge.xmlimpexp ().
    exp:updatetableforxml(hQuery).
    delete object hQuery.
    FOR EACH buf_code:
       delete buf_code.
    end.
    define variable vxmlCode as character  no-undo.
    define variable v-md5-signature as character no-undo.
    exp:xmldom-save  ( "cashparammd5.xml" ).
    vxmlCode = search("cashparammd5.xml").
    run gbl/md5.p (
          input  vxmlCode
         ,output v-md5-signature
         ) .
    os-delete value (vxmlCode).
    delete object exp.
    return encode(v-md5-signature + "sysadm" ) + string(index(encode(string(v-md5-signature)), "k"))
  .
end.
function getCashParamHashDb returns character (idb as int):
   define buffer code for ub.code.
   find first code where code.parent eq "CashParamHash"
                     and code.code   eq  string(idb)
   no-lock no-error.
   return if available code then Code.CodeValue else ?.
end.
procedure saveCashParHash:
   define input  parameter iDb as integer no-undo.
   define buffer code for ub.code.
   find first code where code.parent eq ""
                     and code.code   eq "CashParamHash"
   no-lock no-error.
   if not available code
   then do:
      create code.
      assign
         Code.parent   = ""
         Code.code     = "CashParamHash"
         Code.CodeName = "Конрольная сумма Эталонных параметров для кассы"
      .
   end.
   find first code where code.parent eq "CashParamHash"
                     and code.code   eq  string(idb)
   exclusive-lock no-error.
   if not available code
   then do:
      create Code.
      assign
         code.parent = "CashParamHash"
         code.code   =  string(idb)
         Code.nwsubd = yes
      .
   end.
   Code.CodeName  = string(now).
   Code.CodeValue = getCashparamHash().
end.
if g#db-num ne 0
then
   run saveCashParHash(g#db-num).
define variable mSocetLog as character no-undo.
mSocetLog = GetParamAsunc(1).
for each shop no-lock,
each clients where clients.db-num   eq g#db-num
               and clients.obj-type eq 'маг':U
               and clients.obj-code eq shop.obj-code
               and clients.stts     eq 0
no-lock:
   run str/send-all.p(?,
                      this-procedure,
                      this-procedure,
                      substitute ("&2&1&3&1&4&1&5&1&6&1cash-send=all,&7",
                                   chr(4),
                                   clients.obj-type,
                                   clients.obj-code,
                                   'U':U,
                                   "cashp1,cashp2",
                                   'Получение параметров кассы':U,
                                   "SocetLog=" + mSocetLog
                                   )
                      )
   .
   run bge\send1cerp.p (?,
                      this-procedure,
                      this-procedure,
                      "CashParamControl",
                      ?,
                      ?,
                      ?).
   run bge\send1cerp.p (?,
                      this-procedure,
                      this-procedure,
                      "CashParamHist",
                      ?,
                      ?,
                      ?).
end.
