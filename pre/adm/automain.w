CREATE WIDGET-POOL.
define input parameter i-auto-type as character no-undo .
define input parameter i-mode      as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Главное окно запуска автоматических процедур по расписанию".
define variable mAsyncHelper as class ibs.th.file.AsyncHelperth  no-undo.
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
define new  shared variable g#auto as logical no-undo.
define new  shared variable g#news as logical no-undo.
define new  shared variable g#oxml as logical no-undo.
define new  shared variable g#esys as logical no-undo.
define new  shared variable g#news-source-db as integer no-undo.
define new  shared variable g#esys-source-esys as integer no-undo.
define new  shared variable g#db-num as integer   no-undo .
define new  shared variable g#userid as character no-undo .
define new  shared variable g#passwd as character no-undo .
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
define variable mLableText as character no-undo.
define variable mStartTime as datetime-tz no-undo init ?.
procedure addtask:
   define input  parameter ITask as character no-undo.
   define input  parameter iProc as character no-undo.
   define input  parameter iParam as character no-undo.
   subscribe "PutFileLogAsunc" anywhere run-procedure "WriteLogAsync".
   if mStartTime ne ?
   then
      mAsyncHelper:AddTask (ITask,iProc,iParam,mStartTime).
   else
      mAsyncHelper:AddTask (ITask,iProc,iParam).
   unsubscribe "PutFileLogAsunc".
end.
procedure addTaskTime:
   define input  parameter ITask      as character no-undo.
   define input  parameter iProc      as character no-undo.
   define input  parameter iParam     as character no-undo.
   define input  parameter iStartTime as datetime-tz no-undo.
   subscribe "PutFileLogAsunc" anywhere run-procedure "WriteLogAsync".
   mAsyncHelper:AddTask (ITask,iProc,iParam,iStartTime).
   unsubscribe "PutFileLogAsunc".
end.
procedure waitproc:
   define input  parameter itext  as character no-undo.
   subscribe "PutFileLogAsunc" anywhere run-procedure "WriteLogAsync".
   run ibs\th\file\waithelper.p (mAsyncHelper,?,1,itext + " " + mLableText).
   unsubscribe "PutFileLogAsunc".
end.
procedure waitProcLable:
   define input  parameter itext  as character no-undo.
   mLableText = itext.
end.
procedure waitProcShed:
   define input  parameter iSched as character no-undo.
   define input  parameter itext  as character no-undo.
   subscribe "PutFileLogAsunc" anywhere run-procedure "WriteLogAsync".
   run ibs\th\file\waithelper.p (mAsyncHelper,iSched,1,itext).
   unsubscribe "PutFileLogAsunc".
end.
procedure WriteLogAsync:
   define input  parameter iFile as character no-undo.
   define variable vText as character no-undo.
   define variable vFile as longchar  no-undo.
   define variable vfileName as character no-undo.
   define variable vi as int64 no-undo.
   define variable vStr  as character no-undo.
   vfileName = mAsyncHelper:objExists(iFile,"f").
   if vfileName ne ?
   then do:
      copy-lob from file vfileName to vFile no-error.
      if error-status:error
      then do:
         run write-to-log (substitute ("Не удалось прочесть файл &1",iFile)).
      end.
      else do:
          vFile = replace (vFile,chr(13) + chr(10),chr(10)).
          do vi = 1 to num-entries(vFile,chr(10)) - 1:
            run write-to-log-notime (entry(vi, vFile,chr(10))).
         end.
      end.
   end.
   else do:
       assign
           vtext = substitute ("Процедура обработки данных не завершена. &1",ifile).
       run write-to-log (vtext).
   end.
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    run hide-message in (this-procedure:handle) .
    process events.
end.
END PROCEDURE.
PROCEDURE write-counter :
do
on error undo, return error
:
define input parameter p-counter-string     as character    no-undo.
if v-counter-visible then
run write-message in (this-procedure:handle) ( input p-counter-string) .
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
run write-to-log in this-procedure( input ( fill( chr(32), 2  * p-tab-position)  +
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE get-db-num :
  define output parameter p-db-num as integer no-undo .
  do
  on error undo, return error return-value
  :
      run gbl/getdbnum.p (output p-db-num).
  end.
END PROCEDURE.
define variable v-cntxa-report-num as integer no-undo .
PROCEDURE get-report-num :
  define output parameter p-report-num as integer no-undo .
  do
  on error undo, return error
  :
    if v-cntxa-report-num = 0 then do:
      run gbl/getrpnum.p (output p-report-num).
      v-cntxa-report-num = p-report-num.
    end.
    else do:
      assign
      p-report-num = v-cntxa-report-num
      .
    end.
  end.
END PROCEDURE.
PROCEDURE get-userid :
do
on error undo, return error
:
define output parameter p-userid  as character    no-undo.
    assign
        p-userid = g#userid
    .
end.
END PROCEDURE.
PROCEDURE get-version-num :
define output parameter p-curr-version as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/getvern.p
      ( output p-curr-version
      ) .
  end.
END PROCEDURE.
procedure get-news :
define output parameter p-news as logical no-undo .
  do
  on error undo, return error
  :
     p-news = g#news.
  end.
end procedure.
procedure get-esys :
define output parameter p-esys as logical no-undo .
  do
  on error undo, return error
  :
     p-esys = g#esys.
  end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-uh6 as handle no-undo .
define variable v-found6 as logical no-undo .
v-uh6 = session:first-procedure no-error.
do while valid-handle(v-uh6):
  if v-uh6:type = "PROCEDURE" then do:
    if v-uh6:file-name = "gbl/mainproc.p" then do:
      v-found6 = yes.
      leave.
    end.
  end.
  v-uh6 = v-uh6:next-sibling no-error.
end.
if not v-found6 then do:
  run gbl/mainproc.p persistent.
end.
procedure mainhandle_parentproc_indicator :
return.
end procedure.
define variable mForExtsys as character no-undo.
define variable mHiddenMode as logical no-undo.
define variable mForDb as longchar no-undo.
define variable mForProc as character no-undo.
define variable mSessionBegin as logical no-undo init yes.
define variable mListDb       as character no-undo.
define variable mListDbAll    as character no-undo.
define variable mListKey      as character no-undo.
define variable mListKeyAll   as character no-undo.
define temp-table tt-db no-undo
   field db-num as integer
   index pi is unique primary
    db-num ascending
.
define temp-table tt-extsys no-undo
   field extsys_id as integer
   index pi is unique primary
      extsys_id ascending
.
define temp-table tt-BatchProcess
 field BP_Type as char
 field CharKey_One as char
 field CharKey_Two as char
 field CharKey_Three as char
 field BP_ExecSysDate as date
 field BP_ExecSysTimeInt as int
 index dt BP_ExecSysDate BP_ExecSysTimeInt.
function objExists return character
(input  ifolder as character,
 input  iType   as character  ):
    define variable vFileType as character no-undo init "D,F".
    define variable vi        as integer no-undo.
    define variable vtype as character no-undo.
    if iType ne ?
    then
       vFileType = iType.
    do vi = 1 to num-entries(vFileType):
       file-information:file-name = ".\" + right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index(vtype , entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
       file-information:file-name = right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if file-information:file-name <> "" and
          entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index( vtype, entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
    end.
    return ? .
end.
function SearchFile return character
(input  ifile as character):
   return objExists(ifile,?).
end.
function SearchPFile return character
(input inFile as char):
     define variable oFile       as character no-undo.
     define variable vFileSearch as character no-undo.
     define variable vNumEntry   as integer no-undo.
     if inFile = "" then return ?.
     vNumEntry = num-entries(inFile,".").
     vFileSearch = inFile.
     if    vNumEntry > 0
        and (   entry(vNumEntry,inFile,".") eq "p"
             or entry(vNumEntry,inFile,".") eq "w")
     then do:
        entry(vNumEntry,vFileSearch, ".") = "r".
        oFile = search(vFileSearch ).
        if oFile eq ?
        then
           oFile = search(inFile).
     end.
     else
        oFile = search(vFileSearch).
     return oFile.
  end.
procedure initProcMode:
   define input  parameter iAutoTypeList as character no-undo.
   define input  parameter iMode as character no-undo.
   define variable v-ind as integer no-undo.
   if lookup( "H":U, iMode, "+":U ) = 0
   then do:
      mHiddenMode = false.
      run myenable in this-procedure
         ( input iAutoTypeList
         ) .
   end.
   else do:
      mHiddenMode = true.
   end.
   assign
      mForDb      = "":U
      mForExtsys  = "":U
   .
   block_db-list:
   do v-ind = 1 to num-entries( iMode, "+":U )
   :
      if entry( 1, entry( v-ind, imode, "+":U), ":":U ) = "DB":U
      then do:
         mForDb = entry( 2, entry( v-ind, imode, "+":U), ":":U ).
         for each tt-db
         :
           delete tt-db .
         end.
         run gbl/prcs-lst.p
            ( input mForDb
            , input 0
            , input 99999
            , input false
            , input (buffer tt-db:handle)
            , input "db-num":U
            ) no-error .
         mForDb = "".
         for each tt-db
         :
            mForDb = mForDb + ",":U + string( tt-db.db-num ).
            delete tt-db .
         end.
         mForDb = substring( mForDb, 2 ).
         leave block_db-list .
      end.
      if entry( 1, entry( v-ind, iMode, "+":U), ":":U ) = "ExtSys":U
      then do:
         mForExtsys = entry( 2, entry( v-ind, iMode, "+":U), ":":U ).
         for each tt-extsys
         :
            delete tt-extsys .
         end.
         run gbl/prcs-lst.p
            ( input mForExtsys
            , input 0
            , input 99999
            , input false
            , input (buffer tt-extsys:handle)
            , input "extsys_id":U
            ) no-error .
         mForExtsys = "".
         for each tt-extsys
         :
            mForExtsys = mForExtsys + ";":U + string( tt-extsys.extsys_id ).
            delete tt-extsys .
         end.
         mForExtsys = substring( mForExtsys, 2 ).
         leave block_db-list .
      end.
      if entry( 1, entry( v-ind, iMode, "+":U), ":":U ) = "ProcName":U
      then do:
         mForProc = entry( 2, entry( v-ind, iMode, "+":U), ":":U ).
         leave block_db-list .
      end.
   end.
end.
define variable mAsyncProcRun as logical no-undo.
procedure startproc:
   define input  parameter iAutoType as character no-undo.
   define input  parameter iListDb as character no-undo.
   define input  parameter iListKey as character no-undo.
   define input  parameter iStart as datetime-tz no-undo.
   mStartTime = iStart.
 define variable v-db-num as integer no-undo.
 define variable v-ind as integer no-undo.
 define variable v-num-entries-db-list as integer no-undo.
 v-num-entries-db-list = num-entries(iListDb, chr(44))
            .
   case iAutoType :
      when 'autonws':U
      then do:
         define variable mreadini as character no-undo.
         define variable msesnws as integer no-undo.
         get-key-value section "THAutoSessions" key "NumAsyncSessionsNWS" value mreadini.
         assign
            msesnws = 1
            msesnws = integer (mreadini)
         no-error.
         if    mAsyncProcRun
            or msesnws > 1
         then do:
            mAsyncHelper:maxproc = msesnws.
            run bge/auto-nws.p
               (input iAutoType
               ,input this-procedure
               ,input iListDb
            ) no-error.
         end.
         else do:
            run nws/exch-nws.p
                  (input this-procedure
                  ,input g#auto-user-id
                  ,input g#auto-user-password
                  ,input iListDb
                  ) no-error.
         end.
          if error-status :error
            then do:
               run write-to-log in this-procedure
                  (input vss-workfile + chr(32)
                    + "Ошибка при запуске новостей" + chr(10)
                    + error-status :get-message(error-status :num-messages) + chr(10)
                    + return-value
               ) .
            end.
      end.
      when 'mercury':U
      then do:
         run bge/auto-merc-asunc.p
            (input iAutoType
            ,input this-procedure
            ,input iListDb
         ) no-error.
      end.
      when 'is_motp':U
      then do:
         if mAsyncProcRun
         then
            run addtask (iAutoType,"utl\proc-anyproc.p",substitute ("&2&1&3&1&4&1&5&1&6",
                                                chr(4),
                                                "bge/auto-motp.p",
                                                g#auto-user-id,
                                                g#auto-user-password,
                                                iListDb,
                                                no)).
         else
            run bge/auto-motp.p
               (input g#auto-user-id
               ,input g#auto-user-password
               ,input iListDb
               ,input no
            ) no-error.
      end.
      when 'is_diadoc':U
      then do:
         run bge/auto-diadoc.p
            (input iAutoType
            ,input this-procedure
            , input iListDb
            ) no-error.
      end.
      when 'hddtest':U
      then do:
         define variable Vdbinfo as char no-undo.
         run adm/db-info.p ( output v-db-num, output Vdbinfo ) no-error.
         if mAsyncProcRun
         then
            run addtask (iAutoType,"utl\proc-anyproc.p",substitute ("&2&1&3&1&4&1&5",
                                                chr(4),
                                                "bge/auto-hddtest.p",
                                                g#auto-user-id,
                                                g#auto-user-password,
                                                v-db-num)).
         else
            run bge/auto-hddtest.p
               (input g#auto-user-id
               ,input g#auto-user-password
               ,input v-db-num
            ) no-error.
      end.
      when 'autoarh':U
      then do:
         do v-ind = 1 to v-num-entries-db-list
         :
            define variable v-rec-key as character no-undo.
            define variable v-cre-db-num as integer no-undo.
            define variable v-task-type as character no-undo.
            define variable v-task-num as integer no-undo.
            assign
               v-db-num     = integer( entry( v-ind, iListDb, chr(44) ) )
               v-rec-key    =          entry( v-ind, iListKey, chr(1) )
               v-cre-db-num = integer( entry( 1, v-rec-key, chr(3) ) )
               v-task-type  =          entry( 2, v-rec-key, chr(3) )
               v-task-num   = integer( entry( 3, v-rec-key, chr(3) ) )
            .
             if mAsyncProcRun
             then
                run addtask (iAutoType,"utl\proc-anyproc.p",substitute ("&2&1&3&1&4&1&5&1&6",
                                                   chr(4),
                                                   "adm/calc-arc.p",
                                                   v-db-num,
                                                   v-cre-db-num,
                                                   v-task-type,
                                                   v-task-num)).
             else do:
               run adm/calc-arc.p
                  (input v-db-num
                  ,input v-cre-db-num
                  ,input v-task-type
                  ,input v-task-num
               ) no-error.
               if error-status :error
               then do:
               run write-to-log in this-procedure
                  (input vss-workfile + chr(32)
                       + "Ошибка при расчете архива" + chr(10)
                       + error-status :get-message(error-status :num-messages) + chr(10)
                       + return-value
                  ) .
               end.
            end.
         end.
      end.
      when 'autoexp':U
      then do:
         do v-ind = 1 to v-num-entries-db-list :
            assign
               v-db-num     = integer( entry( v-ind, iListDb, chr(44) ) )
               v-rec-key    =          entry( v-ind, iListKey, chr(1) )
               v-cre-db-num = integer( entry( 1, v-rec-key, chr(3) ) )
               v-task-type  =          entry( 2, v-rec-key, chr(3) )
               v-task-num   = integer( entry( 3, v-rec-key, chr(3) ) )
            .
            if mAsyncProcRun
             then
                run addtask (iAutoType,"utl\proc-anyproc.p",substitute ("&2&1&3&1&4&1&5&1&6",
                                                   chr(4),
                                                   "bge/bge-shd.p",
                                                   v-cre-db-num,
                                                   v-task-type,
                                                   v-task-num,
                                                   v-db-num)).
             else do:
               run bge/bge-shd.p
                  (input v-cre-db-num
                  ,input v-task-type
                  ,input v-task-num
                  ,input v-db-num
               ) no-error.
            end.
         end.
      end.
      when 'autooxml':U
      then do:
         do v-ind = 1 to v-num-entries-db-list :
            assign
               v-db-num     = integer( entry( v-ind, iListDb, chr(44) ) )
               v-rec-key    =          entry( v-ind, iListKey, chr(1) )
               v-cre-db-num = integer( entry( 1, v-rec-key, chr(3) ) )
               v-task-type  =          entry( 2, v-rec-key, chr(3) )
               v-task-num   = integer( entry( 3, v-rec-key, chr(3) ) )
            .
            run bge/oxmlshd.p
            (input this-procedure:handle
            ,input v-cre-db-num
            ,input v-task-type
            ,input v-task-num
            ,input v-db-num
            ,input mForExtsys
            ) no-error.
         end.
      end.
      when 'autogcd':U
      then do:
         do v-ind = 1 to v-num-entries-db-list :
            assign
               v-db-num     = integer( entry( v-ind, iListDb, chr(44) ) )
               v-rec-key    =          entry( v-ind, iListKey, chr(1) )
               v-cre-db-num = integer( entry( 1, v-rec-key, chr(3) ) )
               v-task-type  =          entry( 2, v-rec-key, chr(3) )
               v-task-num   = integer( entry( 3, v-rec-key, chr(3) ) )
            .
            run str/gcd-shd.p
               (input this-procedure:handle
               ,input v-cre-db-num
               ,input v-task-type
               ,input v-task-num
               ,input v-db-num
               ) no-error.
         end.
      end.
      when 'autosuz':U
      then do:
         do v-ind = 1 to v-num-entries-db-list
         :
            assign
               v-db-num     = integer( entry( v-ind, iListDb, chr(44) ) )
               v-rec-key    =          entry( v-ind, iListKey, chr(1) )
               v-cre-db-num = integer( entry( 1, v-rec-key, chr(3) ) )
               v-task-type  =          entry( 2, v-rec-key, chr(3) )
               v-task-num   = integer( entry( 3, v-rec-key, chr(3) ) )
            .
            run str/suz-shd.p
               (
               input this-procedure:handle
               ,input v-cre-db-num
               ,input v-task-type
               ,input v-task-num
               ,input v-db-num
            ) no-error.
            if error-status :error
            then do:
               run write-to-log in this-procedure
                  (input vss-workfile + chr(32)
                    + "Ошибка при запуске отчета" + chr(10)
                    + error-status :get-message(error-status :num-messages) + chr(10)
                    + return-value
               ) .
            end.
         end.
      end.
      when 'autosale':U
      then do:
         do v-ind = 1 to v-num-entries-db-list :
            assign
               v-db-num     = integer( entry( v-ind, iListDb, chr(44) ) )
               v-rec-key    =          entry( v-ind, iListKey, chr(1) )
               v-cre-db-num = integer( entry( 1, v-rec-key, chr(3) ) )
               v-task-type  =          entry( 2, v-rec-key, chr(3) )
               v-task-num   = integer( entry( 3, v-rec-key, chr(3) ) )
            .
            run str/sal-shd.p
               (input this-procedure:handle
               ,input v-cre-db-num
               ,input v-task-type
               ,input v-task-num
               ,input v-db-num
               ) no-error.
         end.
      end.
      when 'autocbnk':U
      then do:
         do v-ind = 1 to v-num-entries-db-list :
            assign
               v-db-num     = integer( entry( v-ind, iListDb, chr(44) ) )
               v-rec-key    =          entry( v-ind, iListKey, chr(1) )
               v-cre-db-num = integer( entry( 1, v-rec-key, chr(3) ) )
               v-task-type  =          entry( 2, v-rec-key, chr(3) )
               v-task-num   = integer( entry( 3, v-rec-key, chr(3) ) )
            .
            run bge/clb-shd.p
               (input this-procedure:handle
               ,input v-cre-db-num
               ,input v-task-type
               ,input v-task-num
               ,input v-db-num
            ) no-error.
         end.
      end.
      when 'autofree':U
      then do:
         do v-ind = 1 to v-num-entries-db-list :
            assign
               v-db-num     = integer( entry( v-ind, iListDb, chr(44) ) )
               v-rec-key    =          entry( v-ind, iListKey, chr(1) )
               v-cre-db-num = integer( entry( 1, v-rec-key, chr(3) ) )
               v-task-type  =          entry( 2, v-rec-key, chr(3) )
               v-task-num   = integer( entry( 3, v-rec-key, chr(3) ) )
            .
            run adm/freeshdr.p
               (input this-procedure:handle
               ,input v-cre-db-num
               ,input v-task-type
               ,input v-task-num
               ,input v-db-num
            ) no-error.
         end.
      end.
      when 'is_PM':U
      then do:
         do v-ind = 1 to v-num-entries-db-list :
            assign
               v-db-num     = integer( entry( v-ind, iListDb, chr(44) ) )
               v-rec-key    =          entry( v-ind, iListKey, chr(1) )
               v-cre-db-num = integer( entry( 1, v-rec-key, chr(3) ) )
               v-task-type  =          entry( 2, v-rec-key, chr(3) )
               v-task-num   = integer( entry( 3, v-rec-key, chr(3) ) )
            .
            run bge/auto-exp-is_PM.p
                       (input this-procedure:handle
                        ,input v-db-num
                        ,input v-cre-db-num
                        ,input v-task-type
                        ,input v-task-num
                        ) no-error.
         end.
      end.
   end case.
end.
define variable volddate as date no-undo init ?.
define stream sOutCash.
define variable mFileCashParLog as character no-undo.
procedure AddCashParam:
   define input  parameter p-auto-type-list as character no-undo.
   define input  parameter iToday as date no-undo.
   define input  parameter iTime as integer no-undo.
   if mFileCashParLog eq ""
   then do:
      mFileCashParLog = searchfile("cashparam.log").
      if mFileCashParLog eq ?
      then do:
         output stream sOutCash to "cashparam.log" append.
         output stream sOutCash close.
         mFileCashParLog = searchfile("cashparam.log").
         if mFileCashParLog eq ?
         then
            mFileCashParLog = "".
      end.
   end.
   if (    lookup ('autooxml':U  ,p-auto-type-list) > 0
      )
      and voldDate ne iToday
   then do:
      mAsyncHelper:setTimeOutTask("cashParam",600).
      voldDate = iToday.
      if iTime < 7200
      then
         run addTaskTime in this-procedure ("cashParam","utl/proc-send-all.p" , mFileCashParLog, datetime-tz (month (iToday),day (iToday), year (iToday),2,0 )).
      if iTime < 50400
      then
         run addTaskTime in this-procedure("cashParam","utl/proc-send-all.p" , mFileCashParLog, datetime-tz (month (iToday),day (iToday), year (iToday),14,0 )).
   end.
end.
procedure AddUtil:
   define input  parameter p-auto-type-list as character no-undo.
   define variable vRun as logical no-undo.
   if mFileCashParLog eq ""
   then do:
      mFileCashParLog = searchfile("utils.log").
      if mFileCashParLog eq ?
      then do:
         output stream sOutCash to "utils.log" append.
         output stream sOutCash close.
         mFileCashParLog = searchfile("utils.log").
         if mFileCashParLog eq ?
         then
            mFileCashParLog = "".
      end.
   end.
   if (    lookup ('autooxml':U  ,p-auto-type-list) > 0
      )
   then do:
      mAsyncHelper:setTimeOutTask("Utils",600).
      run utl/chknds22.p (output vRun).
      if vRun then
      do:
        run addTaskTime in this-procedure("Смена кода ставки НДС с 1 на 11.","utl/run_nds22.p" , mFileCashParLog, datetime-tz (1,1,2026,0,0 )).
      end.
   end.
end.
define variable mPrintNextMes as logical no-undo init yes.
procedure checkConect:
   define input  parameter iTitle  as character no-undo.
   define input  parameter iAutoType as character no-undo.
   define output parameter oDbNum  as integer   no-undo.
   define output parameter oDBInfo as character no-undo.
   define variable v-log as logical no-undo.
   run adm/chk-db.p no-error .
   if error-status :error then do:
      run write-to-log (  substitute( "&1. Проверка возможности работы сессии.&2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message(1) ) ).
      run gbl/dbdiscon.p no-error.
      if error-status :error then do:
         run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message(1) ) ).
      end.
      return error.
   end.
   if v-socket = false
   then do:
      if iAutoType = 'autonws':U
      then do:
         message
            vss-workfile vss-revision vss-description skip
            substitute( 'В параметрах соединения с БД отсутствуют параметры "-S" и "-1".' ) skip
            substitute( 'Работа СПН возможна только в ручном режиме.' ) skip
            substitute( 'Продолжить работу в ручном режиме?' ) skip
            view-as alert-box question buttons yes-no update v-log
         .
         if v-log = true
         then do:
            run gbl/dbdiscon.p no-error.
            if error-status :error then do:
               run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message(1) ) ).
            end.
            return error "HandMode".
         end.
      end.
      else do:
         message
            vss-workfile vss-revision vss-description skip
            substitute( 'В параметрах соединения с БД отсутствуют параметры "-S" и "-1".' ) skip
            substitute( '&1 работать не может.', ititle ) skip
            view-as alert-box error
         .
      end.
      return error.
   end.
   run adm/db-info.p ( output oDbNum, output oDBInfo ) no-error.
   if error-status :error
   then do:
      if mPrintNextMes = true then do:
         run write-to-log( vss-workfile + chr(32)
                         + "Ошибка при считывании информации о текущей БД." + chr(10)
                         + error-status :get-message(error-status :num-messages) + chr(10)
                         + return-value
                         ) .
         mPrintNextMes = false.
      end.
      return error "WaitOK".
   end.
   else do:
      mPrintNextMes = true.
   end.
end procedure.
procedure initAsyncProc:
   define input  parameter iTitle as character no-undo.
   define input  parameter iAutoTypeList as character no-undo.
   define input  parameter iWorkType     as character no-undo.
   define input  parameter iNextPeriod as logical no-undo.
   define output parameter oDbInfo as character no-undo.
   define variable vi as integer no-undo.
   define variable vAutoType as character  no-undo.
   define variable vError as logical no-undo.
   define variable vConect as logical no-undo.
   define variable vDbNum as integer no-undo.
   do vi = 1 to num-entries (iAutoTypeList):
      vAutoType = entry(vi,iAutoTypeList).
      if lookup(vAutoType, iWorkType) eq 0
      then do:
         if not vConect
         then do:
            run adm/autoconn.p no-error.
            if error-status :error
            then do:
               run write-to-log ( substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message(1) ) ).
            end.
            else do:
               vConect = yes.
               run checkConect (input  iTitle,
                             input  i-auto-type,
                             output vDbNum,
                             output oDbInfo) no-error.
               if error-status:error
               then do:
                  return error return-value.
               end.
            end.
         end.
         if iNextPeriod
         then do:
            run adm/chk-sch.p
            ( input  vAutoType
            , input  mForDb
            , output mListDb
            , output mListDbAll
            , output mListKey
            , output mListKeyAll
            , input mForExtsys
            , input mForProc
            , output table tt-BatchProcess
            ) no-error.
            run adm/wr-n-bp.p
                ( input this-procedure:handle
                ,input mSessionBegin
                ,input vAutoType
                ,input mListDb
                ,input mForExtsys
                ,input mForProc
                ) no-error.
            if error-status :error
            then do:
               vError = yes.
               run write-to-log( vss-workfile + chr(32)
                            + "Ошибка при анализе начала следующего сеанса" + chr(10)
                            + error-status :get-message(error-status :num-messages) + chr(10)
                            + return-value
                            ) no-error.
               if error-status:error
               then do:
                  run write-to-screen (return-value).
               end.
            end.
         end.
         run adm/chk-sch.p
            ( input  vAutoType
            , input  mForDb
            , output mListDb
            , output mListDbAll
            , output mListKey
            , output mListKeyAll
            , input mForExtsys
            , input mForProc
            , output table tt-BatchProcess
            ) no-error.
         if error-status :error
         then do:
            run write-to-log( vss-workfile + chr(32)
                            + "Ошибка при чтении расписания." + chr(10)
                            + error-status :get-message(error-status :num-messages) + chr(10)
                            + return-value
                            ) .
            return error.
         end.
         for each tt-BatchProcess:
            run startproc(tt-BatchProcess.BP_Type,
                          tt-BatchProcess.CharKey_One,
                          tt-BatchProcess.CharKey_Three,
                          datetime-tz (tt-BatchProcess.BP_ExecSysDate,tt-BatchProcess.BP_ExecSysTimeInt * 1000)).
         end.
      end.
   end.
   if iNextPeriod and not vError
   then
      mSessionBegin = false.
   if vConect
   then do:
      run gbl/dbdiscon.p no-error.
      if error-status :error then do:
         run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message(1) ) ) no-error.
         if error-status:error
         then do:
            run write-to-screen (return-value).
         end.
      end.
   end.
end procedure.
define stream VarStream.
procedure ReedFileContext:
   define variable v-varfile as character no-undo.
   define variable v-varstr as character no-undo.
   define variable mNewHiddenMode as logical no-undo.
   assign
      file-info:file-name = substitute( "./ATH&1.var", g#auto-pid )
      v-varfile           = file-info:full-pathname
   .
   if v-varfile <> ?
   then do:
      v-varstr = "".
      input stream VarStream from value( v-varfile ) .
      block_read-var:
      repeat :
         import stream VarStream unformatted v-varstr no-error .
         leave block_read-var .
      end.
      input stream VarStream close.
      if lookup( "H":U, v-varstr, "+":U ) = 0
      then do:
         mNewHiddenMode = false.
      end.
      else do:
         mNewHiddenMode = true.
      end.
      os-delete value( v-varfile ) .
      if mNewHiddenMode <> mHiddenMode
      then do:
         mHiddenMode = mNewHiddenMode.
         run write-to-log ( substitute( "Смена статуса 'видимости' сессии. Теперь сессия &1видна.", (if mHiddenMode = true then "не":U else "") ) ) no-error.
         if error-status:error
         then do:
            run write-to-screen (return-value).
         end.
      end.
   end.
end.
procedure CheckUpdate:
  define variable CheckUpd      as class ibs.th.adm.upd.CheckUpd no-undo.
  CheckUpd = new ibs.th.adm.upd.CheckUpd ().
  if CheckUpd:isStopWork
  then do:
     run write-to-log ("Идет установка r-кодов. Попробуйте через несколько минут.") .
     delete object CheckUpd no-error.
     return error "Идет установка r-кодов. Попробуйте через несколько минут.".
  end.
  if CheckUpd:isNeedUpd
  then do:
     run write-to-log ("Необходимо обновить базу. Запустите ТН") .
     delete object CheckUpd no-error.
     return error "Необходимо обновить базу. Запустите ТН".
  end.
  delete object CheckUpd no-error.
end.
define variable m-time          as integer   no-undo .
define variable mtoday         as date      no-undo .
define variable log-exit      as logical   no-undo .
define variable writelogtype  as character no-undo .
define variable mStart     as logical   no-undo .
define variable mtitle as character no-undo.
define variable mDbNum as integer no-undo.
define variable mDbInfo as character no-undo.
define variable vRun as logical no-undo.
define temp-table tt-proc no-undo
  field proc_id as integer
  index pi is unique primary
    proc_id ascending
.
DEFINE VAR automain AS WIDGET-HANDLE NO-UNDO.
DEFINE BUTTON b-exit AUTO-GO DEFAULT
     LABEL "Вы&ход "
     SIZE 10 BY 1 TOOLTIP "Выход из автоматической системы"
     BGCOLOR 8 .
DEFINE BUTTON b-hand DEFAULT
     LABEL "&РРежим"
     SIZE 10 BY 1 TOOLTIP "Ручной режим приема и отправки новостей"
     BGCOLOR 8 .
DEFINE BUTTON b-start DEFAULT
     LABEL "&Запуск"
     SIZE 10 BY 1 TOOLTIP "Запустить один цикл"
     BGCOLOR 8 .
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1 TOOLTIP "Помощь"
     BGCOLOR 8 .
DEFINE BUTTON b-prop DEFAULT
     LABEL "&Настройки"
     SIZE 10 BY 1 TOOLTIP "Настройка СПН"
     BGCOLOR 8 .
DEFINE VARIABLE auto-log AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL LARGE
     SIZE 96.88 BY 19.75 NO-UNDO.
DEFINE VARIABLE curr-date AS DATE FORMAT "99/99/9999":U
      VIEW-AS TEXT
     SIZE 11 BY .67 NO-UNDO.
DEFINE VARIABLE curr-time AS CHARACTER FORMAT "X(8)":U
      VIEW-AS TEXT
     SIZE 8 BY .67 NO-UNDO.
DEFINE VARIABLE f-msg AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 63 BY .67
     FGCOLOR 12  NO-UNDO.
DEFINE FRAME f-amain
     b-exit AT ROW 1.17 COL 2.25
     b-hand AT ROW 1.17 COL 12.25
     b-prop AT ROW 1.17 COL 22.25
     b-start AT ROW 1.17 COL 32.25
     b-help AT ROW 1.17 COL 89
     auto-log AT ROW 3.38 COL 2.25 NO-LABEL
     f-msg AT ROW 2.5 COL 13 COLON-ALIGNED NO-LABEL
     curr-date AT ROW 2.5 COL 79 NO-LABEL
     curr-time AT ROW 2.5 COL 90.5 NO-LABEL
     "Сообщения:" VIEW-AS TEXT
          SIZE 10.5 BY .67 AT ROW 2.5 COL 3
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 99.38 BY 22.42.
IF SESSION:DISPLAY-TYPE = "GUI":U and not session:batch-mode THEN
  CREATE WINDOW automain ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 22.75
         WIDTH              = 99.38
         MAX-HEIGHT         = 22.75
         MAX-WIDTH          = 99.38
         VIRTUAL-HEIGHT     = 22.75
         VIRTUAL-WIDTH      = 99.38
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE automain = CURRENT-WINDOW.
ASSIGN
       auto-log:READ-ONLY IN FRAME f-amain        = TRUE.
ASSIGN
       b-hand:HIDDEN IN FRAME f-amain           = TRUE.
ASSIGN
      b-start:HIDDEN IN FRAME f-amain           = TRUE.
ASSIGN
       b-prop:HIDDEN IN FRAME f-amain           = TRUE.
ASSIGN
       f-msg:READ-ONLY IN FRAME f-amain        = TRUE.
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(automain)
THEN automain:HIDDEN = yes.
if VALID-HANDLE(automain) then
do:
ON END-ERROR OF automain
OR ENDKEY OF automain ANYWHERE DO:
  RETURN NO-APPLY.
END.
ON WINDOW-CLOSE OF automain
DO:
  RETURN NO-APPLY.
END.
end.
ON CHOOSE OF b-exit IN FRAME f-amain
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
      run write-to-log ( substitute( "&1. Ошибка при завершении работы. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message(1) )
                      ).
    end.
    assign
      log-exit = yes
    .
  end.
END.
ON CHOOSE OF b-start IN FRAME f-amain
DO:
   mstart = yes.
end.
ON CHOOSE OF b-hand IN FRAME f-amain
DO:
  define variable v-auto-old as logical no-undo .
  case i-auto-type
  :
    when 'autonws':U
    then do:
        assign
            v-auto-old = g#auto
            g#auto       = FALSE
        .
        run write-to-log ( (if v-auto-old then string("Aвтоматический режим прерван." + chr(32) ) else "" )
                            + "Запущен ручной режим обмена новостями."
                        ).
        run adm/autoconn.p no-error.
        if error-status :error
        then do:
          run write-to-log (  substitute( "&1. &2&3&4"
                                          ,vss-workfile
                                          ,return-value
                                          ,chr(10)
                                          ,error-status:get-message(error-status:num-messages)
                                        )
                           ).
          message
            substitute( "&1. &2&3&4"
                        ,vss-workfile
                        ,return-value
                        ,chr(10)
                        ,error-status:get-message(error-status:num-messages)
                      )
            view-as alert-box .
        end.
        else do:
          run nws/nws-hand.w
            ( input this-procedure:handle
            , input g#auto-user-id
            , input g#auto-user-password
            ) no-error .
          if error-status :error then do:
            run write-to-log
              ( substitute( "&1. &2&3&4"
                            ,vss-workfile
                            ,return-value
                            ,chr(10)
                            ,error-status:get-message(error-status:num-messages)
                          )
              ).
            message
              substitute( "&1. &2&3&4"
                          ,vss-workfile
                          ,return-value
                          ,chr(10)
                          ,error-status:get-message(error-status:num-messages)
                        )
              view-as alert-box .
          end.
        end.
        assign
          g#auto = v-auto-old
          hand-log-msg-h = ?
        .
        run write-to-log ( "Закончена работа с ручным режимом обмена новостями."
                            + (if v-auto-old then string( chr(32) + "Запущен автоматический режим." ) else "")
                        ).
        run gbl/dbdiscon.p no-error.
        if error-status :error then do:
          run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message(1) ) ).
        end.
        apply "choose" to b-exit in frame f-amain.
        return no-apply.
    end.
    when 'autooxml':U
    then do:
        assign
            v-auto-old = g#auto
            g#auto       = FALSE
        .
        run write-to-log ( (if v-auto-old then string("Aвтоматический режим прерван." + chr(32) ) else "" )
                            + "Запущен ручной режим обмена данными."
                        ).
        run adm/autoconn.p no-error.
        if error-status :error
        then do:
          run write-to-log (  substitute( "&1. &2&3&4"
                                          ,vss-workfile
                                          ,return-value
                                          ,chr(10)
                                          ,error-status:get-message(error-status:num-messages)
                                        )
                           ).
          message
            substitute( "&1. &2&3&4"
                        ,vss-workfile
                        ,return-value
                        ,chr(10)
                        ,error-status:get-message(error-status:num-messages)
                      )
            view-as alert-box .
        end.
        else do:
          run bge/oxmlhand.w
            (
             input this-procedure:handle
            ,input this-procedure:handle
            ,input g#auto-user-id
            ,input g#auto-user-password
            ) no-error .
          if error-status :error then do:
            run write-to-log
              ( substitute( "&1. &2&3&4"
                            ,vss-workfile
                            ,return-value
                            ,chr(10)
                            ,error-status:get-message(error-status:num-messages)
                          )
              ).
            message
              substitute( "&1. &2&3&4"
                          ,vss-workfile
                          ,return-value
                          ,chr(10)
                          ,error-status:get-message(error-status:num-messages)
                        )
              view-as alert-box .
          end.
        end.
        assign
          g#auto = v-auto-old
          hand-log-msg-h = ?
        .
        run write-to-log ( "Закончена работа с ручным режимом обмена данными."
                            + (if v-auto-old then string( chr(32) + "Запущен автоматический режим." ) else "")
                        ).
        run gbl/dbdiscon.p no-error.
        if error-status :error then do:
          run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message(1) ) ).
        end.
        apply "choose" to b-exit in frame f-amain.
        return no-apply.
    end.
   end case.
END.
ON CHOOSE OF b-prop IN FRAME f-amain
DO:
    case i-auto-type
    :
        when 'autonws':U
        then do:
            define variable v-auto-old as logical no-undo .
            assign
                v-auto-old = g#auto
                g#auto       = FALSE
            .
            run write-to-log ( (if v-auto-old then string("Aвтоматический режим прерван." + chr(32) ) else "" )
                                + "Запущен режим настройки СПН."
                            ).
            run adm/autoconn.p no-error.
            if error-status :error
            then do:
                message vss-workfile skip return-value view-as alert-box .
                run write-to-log (  vss-workfile + chr(32)
                                    + return-value
                                ).
                assign
                g#auto = v-auto-old
                .
                return no-apply.
            end.
            run adm/autoprop.w no-error.
            run nws/nws-init.p no-error.
            if error-status :error
            then do:
                run write-to-log (  vss-workfile + chr(10)
                                    + "Ошибка инициализации переменных для системы передачи новостей" + chr(10)
                                    + return-value
                                ).
                assign
                g#auto = v-auto-old
                .
                return no-apply.
            end.
            run gbl/dbdiscon.p no-error.
            if error-status :error then do:
              run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message(1) ) ).
            end.
            run write-to-log ( "Закончена работа с режимом настройки СПН."
                                + (if v-auto-old then string( chr(32) + "Запущен автоматический режим." ) else "")
                            ).
            assign
                g#auto = v-auto-old
            .
        end.
        when 'autoexp':U
        then do:
            message
                "В разработке..."
                skip
            view-as alert-box information.
        end.
        when 'autooxml':U
        then do:
            assign
                v-auto-old = g#auto
                g#auto       = FALSE
            .
            run write-to-log ( (if v-auto-old then string("Aвтоматический режим прерван." + chr(32) ) else "" )
                                + "Запущен режим настройки OpenXML."
                            ).
            run adm/autoconn.p no-error.
            if error-status :error
            then do:
                message vss-workfile skip return-value view-as alert-box .
                run write-to-log (  vss-workfile + chr(32)
                                    + return-value
                                ).
                assign
                g#auto = v-auto-old
                .
                return no-apply.
            end.
            run adm/autoprop.w no-error.
            run bge/oxml-ini.p no-error.
            if error-status :error
            then do:
                run write-to-log (  vss-workfile + chr(10)
                                    + "Ошибка инициализации переменных для системы OpenXML" + chr(10)
                                    + return-value
                                ).
                assign
                g#auto = v-auto-old
                .
                return no-apply.
            end.
            run gbl/dbdiscon.p no-error.
            if error-status :error then do:
              run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message(1) ) ).
            end.
            run write-to-log ( "Закончена работа с режимом настройки OpenXML."
                                + (if v-auto-old then string( chr(32) + "Запущен автоматический режим." ) else "")
                            ).
            assign
                g#auto = v-auto-old
            .
        end.
    end case.
END.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame f-amain
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
on choose of b-help in frame f-amain
do:
  apply "help":u to frame f-amain .
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame f-amain:width - 0.3
                fh            = frame f-amain:first-child
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
if valid-handle(automain) then
ASSIGN CURRENT-WINDOW                = automain
       THIS-PROCEDURE:CURRENT-WINDOW = automain.
on close of this-procedure
do:
  apply "choose" to b-exit in frame f-amain.
  return no-apply.
end.
PAUSE 0 BEFORE-HIDE.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, retry MAIN-BLOCK
   ON STOP    UNDO MAIN-BLOCK, retry MAIN-BLOCK:
  define variable start-time            as int64     no-undo .
  run initProcMode (i-auto-type,i-mode).
  mAsyncHelper = new ibs.th.file.AsyncHelperth().
  mAsyncHelper:mProcPublish = this-procedure.
  mAsyncHelper:setCurrentUserPasswd().
  mAsyncHelper:MyBachMode = yes.
  mAsyncHelper:WritelogInter = 5.
  mAsyncHelper:MyBachMode = yes.
  mAsyncHelper:maxproc    = 1.
  run adm/autoconn.p no-error.
  if error-status :error then do:
    run write-to-log ( substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message(1) ) ).
  end.
  run CheckUpdate no-error.
  if error-status :error then do:
     return error return-value.
  end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'writelog'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output writelogvalue
  ,output writelogtype
  ) no-error .
  run adm/chk-db.p no-error .
  if error-status :error then do:
    run write-to-log (  substitute( "&1. Проверка возможности работы сессии.&2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message(1) ) ).
    run gbl/dbdiscon.p no-error.
    if error-status :error then do:
      run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message(1) ) ).
    end.
    assign
      log-exit = true
    .
  end.
  else do:
     define variable Vdbinfo as character no-undo.
    run AddUtil(i-auto-type).
    run adm/db-info.p ( output g#db-num, output Vdbinfo ) no-error.
    run gbl/dbdiscon.p no-error.
    if error-status :error then do:
      run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message(1) ) ).
    end.
    if i-auto-type = 'autonws':U
    or i-auto-type = 'autooxml':U
    or i-auto-type = 'is_motp':U
    or i-auto-type = 'is_diadoc':U
    then do:
      assign
        g#auto = false
      .
    end.
    else do:
      assign
        g#auto = true
      .
    end.
    assign
      auto-log-msg-h = auto-log:handle
      auto-window-h = this-procedure:handle
      hand-log-msg-h = ?
    .
    if valid-handle(automain) then
      automain:title = substitute( "PID: &1 &2", g#auto-pid, automain:title ).
    case i-auto-type :
      when 'autonws':U
      then do:
        if valid-handle(automain) then
          automain:title = automain:title + "Система передачи новостей.".
        g#auto = FALSE.
        run write-to-log ( "Запущена система передачи новостей" ) no-error.
        if error-status:error
        then do:
          run write-to-screen (return-value).
        end.
        if mHiddenMode = false then do:
          run write-to-log ( "Через 5 секунд будет запущен автоматический режим обмена новостями" ) no-error.
          wait-for
            go of frame f-amain
            or close of this-procedure
            or choose of b-hand in frame f-amain
            or choose of b-help in frame f-amain
            or choose of b-prop in frame f-amain
            or choose of b-start in frame f-amain
            focus frame f-amain
            pause 5
            .
          if error-status:error
          then do:
            run write-to-screen (return-value).
          end.
        end.
        if not log-exit
        then do:
          run write-to-log ( "Запущен автоматический режим обмена новостями" ) no-error.
          if error-status:error
          then do:
            run write-to-screen (return-value).
          end.
          assign
            g#auto = TRUE
          .
        end.
      end.
      when 'autoarh':U
      then do:
        if valid-handle(automain) then
        assign
          automain:title = automain:title + "Система автоматического расчета архивов."
        .
        run write-to-log ( "Запущена система автоматического расчета архивов" ).
      end.
      when 'autoexp':U
      then do:
        if valid-handle(automain) then
        assign
          automain:title = automain:title + "Система автоматического экспорта."
        .
        if mHiddenMode = false then do:
          run write-to-log ( "Через 5 секунд будет запущена система автоматического экспорта" ).
          wait-for
            go of frame f-amain
            or close of this-procedure
            or choose of b-hand in frame f-amain
            or choose of b-help in frame f-amain
            or choose of b-prop in frame f-amain
            or choose of b-start in frame f-amain
            focus frame f-amain
            pause 5
            .
        end.
        if not log-exit
        then do:
          run write-to-log ( "Запущена система автоматического экспорта" ).
        end.
      end.
      when 'autooxml':U
      then do:
        if valid-handle(automain) then
          automain:title = automain:title + "Система OpenXML.".
        g#auto = FALSE.
        .
        run write-to-log ( "Запущена система OpenXML" ).
        if mHiddenMode = false then do:
          run write-to-log ( "Через 5 секунд будет запущен автоматический режим обмена данными" ).
          wait-for
            go of frame f-amain
            or close of this-procedure
            or choose of b-hand in frame f-amain
            or choose of b-help in frame f-amain
            or choose of b-prop in frame f-amain
            or choose of b-start in frame f-amain
            focus frame f-amain
            pause 5
            .
        end.
        if not log-exit
        then do:
          run write-to-log ( "Запущен автоматический режим обмена данныи" ).
          assign
            g#auto = TRUE
          .
        end.
      end.
      when 'is_motp':U
   or when 'is_diadoc':U
      then do:
        define variable vTitle as character no-undo.
         vTitle = if i-auto-type eq  'is_diadoc':U
                  then "ИС Диадок"
                  else "ИС МОТП.".
        assign
          automain:title = automain:title + vTitle
        .
        run write-to-log ( "Запущен автоматический режим обмена данныи c " + vTitle).
      end.
      when 'autogcd':U
      then do:
        if valid-handle(automain) then
        assign
          automain:title = automain:title + "Система автоматического приема информации с касс."
        .
        run write-to-log ( "Запущена система автоматического приема информации с касс" ).
      end.
      when 'autosuz':U
      then do:
        if valid-handle(automain) then
        assign
          automain:title = automain:title + "Система автоматического запуска отчетов."
        .
        run write-to-log ( "Запущена система автоматического запуска отчетов" ).
      end.
      when 'autosale':U
      then do:
        if valid-handle(automain) then
        assign
          automain:title = automain:title + "Система автоматической работы с документами продажи."
        .
        run write-to-log ( "Запущена система автоматической работы с документами продажи" ).
      end.
      when 'autocbnk':U
      then do:
        if valid-handle(automain) then
        assign
          automain:title = automain:title + "Система автоматического эксп/имп в КЛИЕНТ-БАНК."
        .
        run write-to-log ( "Запущена система автоматического эксп/имп в КЛИЕНТ-БАНК" ).
      end.
      when 'autofree':U
      then do:
        if valid-handle(automain) then
        assign
          automain:title = automain:title + "Система автоматического выполнения произвольных заданий."
        .
        run write-to-log ( "Запущена система автоматического выполнения произвольных заданий" ).
      end.
      when 'sktsrv':U
      then do:
        if valid-handle(automain) then
        assign
          automain:title = automain:title + "Сокет-Сервер"
        .
        run write-to-log ( "Запущен Сокет-Сервер" ).
      end.
      when 'mercury':U
      then do:
        if valid-handle(automain) then
        assign
          automain:title = automain:title + "ФГИС Меркурий"
        .
        run write-to-log ( "Запущена система Меркурий" ).
      end.
      when 'is_motp':U
   or when 'is_diadoc':U
      then do:
        if valid-handle(automain) then
        assign
          automain:title = automain:title + vTitle
        .
        run write-to-log ( "Запущена система " + vTitle).
      end.
      when 'hddtest':U
      then do:
        if valid-handle(automain) then
        assign
          automain:title = automain:title + "Мониторинг HDD"
        .
        run write-to-log ( "Запущен мониторинг состояний HDD" ).
      end.
      when 'is_PM':U
      then do:
        if valid-handle(automain) then
        assign
          automain:title = automain:title + "Выгрузка в ИС Президентский Мониторинг"
        .
        run write-to-log ( "Запущена выгрузка в ИС Президентский Мониторинг" ).
      end.
      otherwise do:
        assign
          log-exit = yes
        .
      end.
    end case.
    if valid-handle(automain) then
    assign
      mtitle = automain:title
    .
    if mForDb <> "":U then do:
      if length(mForDb) > 32000
      then do :
        define variable tmp-str as character no-undo .
        tmp-str = entry(1, mForDb) + "-" + entry(num-entries(mForDb), mForDb) .
        run write-to-log ( substitute( "Сессия работает с БД &1", tmp-str ) ).
      end .
      else do :
        run write-to-log ( substitute( "Сессия работает с БД &1", mForDb ) ).
      end .
    end.
    if mForExtsys <> "":U then do:
      run write-to-log ( substitute( "Сессия работает с Внешними Системами &1", mForExtsys ) ).
    end.
    if mForProc <> "":U then do:
      run write-to-log ( substitute( "Сессия работает с Произвольными заданиями &1", mForProc ) ).
    end.
  end.
   main-cycl:
   do while not log-exit
   on error  undo, leave main-cycl
   on stop   undo, next
   on endkey undo, next
   :
      run cur-time( output mtoday
                   ,output m-time
                ) no-error.
      run AddCashParam(i-auto-type, mtoday, m-time).
      vRun = no.
      find first tt-BatchProcess no-lock
       where
         ( tt-BatchProcess.BP_ExecSysDate < mtoday
              or (tt-BatchProcess.BP_ExecSysDate = mtoday
                  and tt-BatchProcess.BP_ExecSysTimeInt < m-time
                )
            )
      no-error.
      if available tt-BatchProcess
      then
         vRun = yes.
      else do:
         find first tt-BatchProcess no-lock no-error.
         if not available tt-BatchProcess
         then
            vRun = yes.
      end.
      if    vRun
         or mstart
      then do:
         for each  tt-BatchProcess :
            delete tt-BatchProcess .
         end.
         run adm/autoconn.p no-error.
         if error-status :error
         then do:
            run write-to-log ( substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message(1) ) ).
            if valid-handle(automain) then
            assign
               automain:title = mtitle
            .
         end.
         else do:
            run checkConect (input  if valid-handle(automain) then automain:title else i-auto-type,
                             input  i-auto-type,
                             output mDbNum,
                             output mDbInfo) no-error.
            if error-status:error
            then do:
               if return-value = "WaitOK"
               then
                  next main-cycl .
               else if return-value eq "HandMode"
               then
                  apply "choose" to b-hand in frame f-amain.
               log-exit = true.
               leave main-cycl .
            end.
            run CheckUpdate no-error.
            if error-status :error then do:
               run write-to-log ( substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message(1) ) ).
               return error return-value.
            end.
           run adm/chk-sch.p
              ( input  i-auto-type
              , input  mfordb
              , output mlistdb
              , output mlistdball
              , output mlistkey
              , output mlistkeyall
              , input mforextsys
              , input mforproc
              , output table tt-BatchProcess
              ) no-error.
           if error-status :error
           then do:
              run write-to-log( vss-workfile + chr(32)
                              + "Ошибка при чтении расписания." + chr(10)
                              + error-status :get-message(error-status :num-messages) + chr(10)
                              + return-value
                             ) .
              run gbl/dbdiscon.p no-error.
              if error-status :error then do:
                 run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message(1) ) ).
              end.
              assign
                 log-exit = true
              .
              leave main-cycl .
           end.
           if valid-handle(automain) then
             automain:title = mtitle + chr(32) + mdbinfo.
           if mstart
           then
              assign
                 mlistdb  = mlistdball
                 mlistkey = mlistkeyall
              .
           if num-entries( mlistdb ) > 0
           then do:
              run write-to-log ( "Текущая" + chr(32) + mdbinfo ) no-error.
              if error-status:error
              then do:
                 run write-to-screen (return-value).
              end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-uh9 as handle no-undo .
define variable v-found9 as logical no-undo .
v-uh9 = session:first-procedure no-error.
do while valid-handle(v-uh9):
  if v-uh9:type = "PROCEDURE" then do:
    if v-uh9:file-name = "gbl/mainproc.p" then do:
      v-found9 = yes.
      leave.
    end.
  end.
  v-uh9 = v-uh9:next-sibling no-error.
end.
if not v-found9 then do:
  run gbl/mainproc.p persistent.
end.
              if lookup (i-auto-type , mAsyncHelper:getListTask()) eq 0
              then
                 run startproc (i-auto-type
                               ,mlistdb
                               ,mListKey
                               ,mAsyncHelper:getnowDay()
                             ).
           end.
         find first tt-BatchProcess no-lock
         where
         ( tt-BatchProcess.BP_ExecSysDate > mtoday
              or (tt-BatchProcess.BP_ExecSysDate = mtoday
                  and tt-BatchProcess.BP_ExecSysTimeInt > mtime
                )
            )
         no-error.
         if not available tt-BatchProcess
         then do:
            run adm/wr-n-bp.p
              ( input this-procedure:handle
               ,input mSessionBegin
               ,input i-auto-type
               ,input mListDb
               ,input mForExtsys
               ,input mForProc
              ) no-error.
            if error-status :error
            then do:
               run write-to-log( vss-workfile + chr(32)
                                + "Ошибка при анализе начала следующего сеанса" + chr(10)
                                + error-status :get-message(error-status :num-messages) + chr(10)
                                + return-value
                              ) no-error.
               if error-status:error
               then do:
                  run write-to-screen (return-value).
               end.
            end.
            else do:
               assign
                  mSessionBegin = false
               .
            end.
            run adm/chk-sch.p
               ( input  i-auto-type
               , input  mfordb
               , output mlistdb
               , output mlistdball
               , output mlistkey
               , output mlistkeyall
               , input mforextsys
               , input mforproc
               , output table tt-BatchProcess
               ) no-error.
            if error-status :error
            then do:
               run write-to-log( vss-workfile + chr(32)
                             + "Ошибка при чтении расписания." + chr(10)
                             + error-status :get-message(error-status :num-messages) + chr(10)
                             + return-value
                           ) .
           end.
         end.
         run gbl/dbdiscon.p no-error.
         if error-status :error then do:
           run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message(1) ) ) no-error.
           if error-status:error
           then do:
             run write-to-screen (return-value).
           end.
         end.
      end.
   end.
   if mAsyncHelper:isWorkShed()
   then do:
      define variable vListTask as character no-undo.
      vListTask = mAsyncHelper:getListWorkShed().
      run write-to-log ( substitute( "Ожидаем выполнение асихронных процессов: &1.", vListTask) ).
      run waitproc("Ожидаем получение данных").
      run write-to-log ( "Асихронные процессы выполнены .").
   end.
   assign
      start-time = etime
    .
    mStart = no.
    do while not log-exit:
      if mHiddenMode = false then do:
        wait-for
          go of frame f-amain
          or close of this-procedure
          or choose of b-hand in frame f-amain
          or choose of b-help in frame f-amain
          or choose of b-prop in frame f-amain
          or choose of b-start in frame f-amain
          focus frame f-amain
          pause 1
        .
        display
          string( time, "HH:MM:SS" ) @ curr-time
          today @ curr-date
          with frame f-amain
          no-error
        .
      end.
      else do:
        if not session:batch-mode then
          wait-for
            go of frame f-amain
            or close of this-procedure
            pause 1
          .
        else
          pause 1.
      end.
      if not session:batch-mode then
        run ReedFileContext.
      if mHiddenMode = false
        and frame f-amain:visible = false
      then do:
        run myenable in this-procedure
          ( input i-auto-type
          ) .
      end.
      if mHiddenMode = true
        and frame f-amain:visible = true
      then do:
        run myhide in this-procedure .
      end.
      if    mStart
         or etime - start-time > 60000
         or time mod 60 = 1
      then do:
        leave .
      end.
    end.
    if mHiddenMode = false then do:
      display
        "" @ curr-time
        "" @ curr-date
        with frame f-amain
        no-error
      .
    end.
  end.
  delete object mAsyncHelper.
  case i-auto-type :
    when 'autonws':U
    then do:
      run write-to-log ( "Закончен сеанс работы с системой передачи новостей" ) no-error.
      if error-status:error
      then do:
        run write-to-screen (return-value).
      end.
    end.
    when 'autoarh':U
    then do:
      run write-to-log ( "Закончен сеанс работы с системой автоматического расчета архивов" ).
    end.
    when 'autoexp':U
    then do:
      run write-to-log ( "Закончен сеанс работы с системой автоматического экспорта" ).
    end.
    when 'autooxml':U
    then do:
      run write-to-log ( "Закончен сеанс работы с системой OpenXML" ).
    end.
    when 'autogcd':U
    then do:
      run write-to-log ( "Закончен сеанс работы с системой автоматического приема информации с кассы" ).
    end.
    when 'autosuz':U
    then do:
      run write-to-log ( "Закончен сеанс работы с системой автоматического запуска отчетов" ).
    end.
    when 'autosale':U
    then do:
      run write-to-log ( "Закончен сеанс работы с системой автоматической обработки документов продаж" ).
    end.
    when 'autocbnk':U
    then do:
      run write-to-log ( "Закончен сеанс работы с системой автоматической эксп/имп в КЛИЕНТ-БАНК" ).
    end.
    when 'sktsrv':U
    then do:
      run write-to-log ( "Закончен сеанс работы Сокет-Сервера" ).
    end.
    when 'autofree':U
    then do:
      run write-to-log ( "Закончен сеанс работы с системой автоматической выполнения произвольных заданий" ).
    end.
    when 'mercury':U
    then do:
      run write-to-log ( "Закончен сеанс работы с ФГИС Меркурий" ).
    end.
    when 'is_motp':U
    then do:
      run write-to-log ( "Закончен сеанс работы с ИС МОТП" ).
    end.
    when 'is_diadoc':U
    then do:
      run write-to-log ( "Закончен сеанс работы с ИС Диадок" ).
    end.
    otherwise do:
      run write-to-log ( "Закончен сеанс работы с системой ....." ).
    end.
  end case.
  assign
    g#auto = FALSE
  .
  RUN disable_UI.
END.
PROCEDURE disable_UI :
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(automain)
  THEN DELETE WIDGET automain.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY auto-log curr-date curr-time
      WITH FRAME f-amain IN WINDOW automain.
  ENABLE b-exit b-help auto-log
      WITH FRAME f-amain IN WINDOW automain.
  VIEW automain.
END PROCEDURE.
PROCEDURE hide-message :
assign
    f-msg = "":U
  .
  if not session:batch-mode then
    hide f-msg in frame f-amain.
  return .
END PROCEDURE.
PROCEDURE myenable :
  define input  parameter pe-auto-type as character no-undo .
  IF VALID-HANDLE(automain) THEN
  DO:
  assign
    automain:HIDDEN = false
  .
  run enable_UI.
  if pe-auto-type = 'autonws':U
    or pe-auto-type = 'autooxml':U
  then do:
    enable b-hand b-prop with frame f-amain.
  end.
  if session:debug-alert
  then do:
    enable b-start b-prop with frame f-amain.
  end.
  END.
END PROCEDURE.
PROCEDURE myhide :
  disable all with frame f-amain .
  hide all no-pause in window automain .
  if VALID-HANDLE(automain) then
  assign
    automain:HIDDEN = true
  .
END PROCEDURE.
PROCEDURE write-message :
define input  parameter p-msg as character no-undo .
  assign
    f-msg = p-msg
  .
  if not session:batch-mode then
  do:
  enable f-msg with frame f-amain.
  if mHiddenMode = false then
  display
    f-msg
    with frame f-amain
    .
  end.
  return .
END PROCEDURE.
