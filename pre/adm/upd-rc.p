block-level on error undo, throw.
define stream mProt.
output stream mProt to "upd-rc.txt" convert target "ibm866".
define input parameter p0-source-dir as character no-undo .
define variable vss-revision    as character no-undo init "$revision: 9 $":u .
define variable vss-author      as character no-undo init "$author: rumyantsev $":u .
define variable vss-date        as character no-undo init "$date: 23.03.07 13:37 $":u .
define variable vss-workfile    as character no-undo init "$workfile: upd-rc.p $":u .
define variable vss-archive     as character no-undo init "$archive: /ver14_0/adm/upd-rc.p $":u .
define variable vss-description as character no-undo init "Обновление r-кодов, обновления должны лежать передаваемом в каталоге".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
define variable CheckUpd      as class ibs.th.adm.upd.CheckUpd no-undo.
procedure write-log:
   define input  parameter iTabPosition as integer   no-undo.
   define input parameter i-message    as character no-undo.
   run write-to-log in this-procedure( i-message).
end.
procedure write-log-and-file:
   define input parameter iTabPosition  as integer   no-undo.
   define input parameter iFile         as character no-undo.
   define input parameter ilog-level    as integer   no-undo.
   define input parameter i-message     as character no-undo.
   run write-to-log in this-procedure( i-message).
end.
procedure writelog :
   define input parameter p-file-name AS CHAR     NO-UNDO.
   define input parameter p-log-level AS INTEGER  NO-UNDO.
   define input parameter p-log-string  AS CHAR     NO-UNDO.
   run write-to-log in this-procedure( p-log-string).
end procedure.
define variable p0-pathrc as character no-undo .
define variable v-pathrc         as character no-undo .
define variable v-filename         as character no-undo .
define variable v-fullfilename     as character no-undo .
define variable v-rc-filename     as character no-undo .
define variable v-filetype         as character no-undo .
define variable v-copy-err         as logical no-undo .
define variable v-delfile as char no-undo.
define variable v-date   as date no-undo .
define variable v-type   as character no-undo .
define variable v-txt   as char no-undo .
define variable v-arc   as char no-undo .
define variable oldg#news as logical no-undo .
define variable oldg#esys as logical no-undo .
define stream flstream.
define temp-table upgfile-tbl no-undo
  field nameupgfile  as char
  field fullnameupgfile  as char
  field dateupg as date
  field type as character
  index dupg is unique primary dateupg
.
define variable v-version           as character no-undo .
define variable v-locale            as character no-undo .
define variable v-SVNRev            as integer   no-undo .
define variable v-compilerVersion   as character no-undo .
define variable v-compile-date      as date      no-undo .
define variable v-time              as integer   no-undo .
define variable v-comment           as character no-undo .
define variable v-file-date         as date      no-undo .
define variable v-file-time         as integer   no-undo .
define variable v-releace           as integer   no-undo.
define variable v-patch             as integer   no-undo.
define variable v-branch            as integer   no-undo.
define variable mFileLog            as character no-undo.
define variable mDirLog             as character no-undo.
define variable mIsError            as logical   no-undo.
define variable v-program-tag     as character no-undo .
define new shared variable oxml-exch-dir as character no-undo .
define new shared variable oxml-heap-dir as character no-undo .
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable parparentproc as handle no-undo.
parparentproc = this-procedure.
run gbl/vertag.p (
      output v-version
    , output v-locale
    , output v-SVNRev
    , output v-compilerVersion
    , output v-compile-date
    , output v-time
    , output v-comment
    , output v-file-date
    , output v-file-time
    , output v-releace
    , output v-patch
    , output v-branch
) .
if v-compile-date = ? then v-compile-date = 01/01/1970.
define variable mRunFile as character no-undo.
CheckUpd = new ibs.th.adm.upd.CheckUpd ().
CheckUpd:workStop ().
run waitfram-show in this-procedure ( input "Идет обновление программ ТН. Ждите..." ).
put stream mProt unformatted "Каталог обновлений: " p0-source-dir skip.
assign
  p0-pathrc = search( "adm/upd-rc.r":U )
.
if p0-pathrc = ? then do:
  assign
    p0-pathrc = search( "adm/upd-rc.p":U )
  .
  if p0-pathrc = ? then do:
    put stream mProt unformatted "Не найден путь на программы ТН" skip.
    return error "Не найден путь на программы ТН".
  end.
end.
put stream mProt unformatted "Путь к программам: " p0-pathrc skip.
assign
  v-arc = search( "exe/7za.exe":U )
.
if v-arc = ? then do:
assign
  v-arc = search( "exe/7z.exe":U )
.
end.
if v-arc = ? then do:
  put stream mProt unformatted "Не найдена программа 7z.exe" skip.
  return error "Не найдена программа 7z.exe, раскрыть обновления невозможно" .
end.
put stream mProt unformatted "Архиватор: " v-arc skip.
assign
  v-pathrc = substring(p0-pathrc, 1, r-index(p0-pathrc, "\") - 1 )
  v-pathrc = substring(v-pathrc, 1, r-index(v-pathrc, "\") - 1 )
  p0-pathrc = substring(v-pathrc, 1, r-index(v-pathrc, "\") - 1 )
  mFileLog  = substitute(
                "&1update&2&3&4_th.log",
                ibs.th.gbl.gbl-inipar:logDir,
                year(today),
                string(month(today),"99"),
                string(day(today),"99"))
  add-log-file-name = mFileLog
.
put stream mProt unformatted "путь к rc: " v-pathrc skip.
put stream mProt unformatted "v-pathrc: " v-pathrc skip.
put stream mProt unformatted "p0-pathrc: " p0-pathrc skip.
put stream mProt unformatted "mFileLog: " mFileLog skip.
input stream flstream from os-dir ( p0-source-dir ) .
put stream mProt unformatted " " skip.
put stream mProt unformatted "обработка файлов из " p0-source-dir " " skip.
repeat
on error undo, return error
:
  import stream flstream v-filename v-fullfilename v-filetype.
  if v-filetype begins "f" and num-entries( v-filename, "." ) > 1
    and ( ( v-filename begins "rc_20")
          or ( v-filename begins "update_")
        )
  then do:
    assign
      file-info:file-name = v-fullfilename
      v-txt = substring (v-filename,  index(v-filename, "_") + 1, 8)
      v-type = substring (v-filename,  index(v-filename, "_") + 10, 2)
      v-rc-filename       = p0-pathrc + "\" + v-filename
    .
    put stream mProt unformatted "найден файл: " v-filename skip.
    put stream mProt unformatted "копирование " v-fullfilename " " v-rc-filename skip.
    os-command silent
      value( "copy" )
      value( v-fullfilename )
      value( v-rc-filename )
    .
    if os-error <> 0 or search(v-rc-filename) = ? then do:
      put stream mProt unformatted "Невозможно скопировать файл: " v-fullfilename "в каталог" p0-pathrc skip.
      return error substitute("Невозможно скопировать файл &1 в каталог &2", v-fullfilename, p0-pathrc) .
    end.
    put stream mProt unformatted "Скопирован: " v-filename " в " v-rc-filename skip.
    v-date = date( integer(substring(v-txt,5,2)), integer(substring(v-txt,7,2)), integer(substring(v-filename, index(v-filename, "_") + 1, 4)) ) no-error.
    if error-status:error or v-date < 01/01/2000 then
    do:
       run write-to-log (substitute(
           "&1Имя файла &2 не соответствует шаблону update_20YYMMDD. Обновление не установлено.",
           substitute("БД&1 ", g#db-num),
           v-filename
       )).
       put stream mProt unformatted "Имя файла не соответствует шаблону update_20YYMMDD" v-filename skip.
    end.
    else
    do:
       find first upgfile-tbl no-lock
          where upgfile-tbl.dateupg = v-date
          no-error.
       if not available upgfile-tbl then do:
          create upgfile-tbl.
          assign
            upgfile-tbl.dateupg         = v-date
            upgfile-tbl.nameupgfile     = v-filename
            upgfile-tbl.fullnameupgfile = v-rc-filename
            upgfile-tbl.type            = v-type
          .
          put stream mProt unformatted "Добавлен в таблицу обновлений: " v-filename " дата: " v-date skip.
       end.
    end.
    os-delete value ( v-fullfilename ) recursive.
    put stream mProt unformatted "Удален  файл: " v-fullfilename skip.
  end.
  if v-filetype begins "f" and num-entries( v-filename, "." ) > 1
  and ( v-filename begins "UFO-")
  then do:
      put stream mProt unformatted "Найден UFO файл: " v-filename skip.
      os-command silent
        value( "copy" )
        value( v-fullfilename )
        value( p0-pathrc )
      .
      if os-error <> 0  or search(p0-pathrc + "/" + v-filename) = ? then do:
        put stream mProt unformatted "Невозможно скопировать: " v-fullfilename " в каталог" p0-pathrc  skip.
        return error substitute("Невозможно скопировать файл &1 в каталог &2", v-fullfilename, p0-pathrc) .
      end.
      put stream mProt unformatted "Скопирован UFO: " v-filename skip.
      if search (p0-pathrc + "/" + v-filename) = ?
      then
      v-copy-err = true .
      assign
        file-info:file-name = p0-pathrc + "\ufo_update"
      .
      if file-info:file-type = ? then do:
          os-create-dir value( p0-pathrc  + "\ufo_update" ).
          if os-error <> 0 then do:
              put stream mProt unformatted "Невозможно создать папку: " p0-pathrc + "\ufo_update" skip.
              return error string ( "Невозможно создать папку " + p0-pathrc  + "\ufo_update" ).
          end.
          put stream mProt unformatted "Создана папка: " p0-pathrc + "\ufo_update" skip.
      end.
      else do :
          assign
            file-info:file-name = p0-pathrc + "\ufo_update-old"
          .
          if file-info:file-type <> ? then do:
              os-delete value ( p0-pathrc + "\ufo_update-old" ) recursive.
              if os-error <> 0 then do:
                  os-rename  value ( p0-pathrc + "\ufo_update-old" ) value ( p0-pathrc + "\ufo_update-old1" ).
                  if os-error <> 0 then do:
                      put stream mProt unformatted "Невозможно удалить папку " skip.
                      return error string ( "Невозможно удалить папку " + p0-pathrc + "\ufo_update-old, удалите ее сами" ).
                  end.
              end.
          end.
          os-rename  value ( p0-pathrc + "\ufo_update" ) value ( p0-pathrc + "\ufo_update-old" ).
          if os-error <> 0 then do:
              put stream mProt unformatted "Невозможно переименовать папку "  p0-pathrc skip.
              return error string(( "Невозможно переименовать папку " + p0-pathrc + "\ufo_update для сохранности" )).
          end.
          put stream mProt unformatted "Папка переименована: " p0-pathrc + "\ufo_update -> " p0-pathrc + "\ufo_update-old" skip.
          put stream mProt unformatted "создаем rc папку " p0-pathrc  "\ufo_update" skip.
          os-create-dir value( p0-pathrc  + "\ufo_update" ).
          if os-error <> 0 then do:
              os-rename  value ( p0-pathrc  + "\ufo_update-old") value ( p0-pathrc  + "\ufo_update" ).
              put stream mProt unformatted "Невозможно создать папку " p0-pathrc  "\ufo_update" skip.
              return error string ( "Невозможно создать папку " + p0-pathrc  + "\ufo_update" ).
          end.
          put stream mProt unformatted "Создана новая папка: " p0-pathrc + "\ufo_update" skip.
      end.
      if not v-copy-err
      then do :
        v-txt = p0-pathrc + "\rc\exe\7z.exe" + " x -y -o" + p0-pathrc + "\ufo_update " +  p0-pathrc + "/" + v-filename.
      end.
      else do :
        FILE-INFO:FILE-NAME = ".".
        v-txt = v-pathrc + "\exe\7z.exe" + " x -y -o" + p0-pathrc + "\ufo_update " +  FILE-INFO:FULL-PATHNAME + "/" + v-filename.
      end.
      put stream mProt unformatted "разархивирование UFO: " v-txt skip.
      os-command silent value ( v-txt ) .
      v-pathrc = search( p0-source-dir + "/" + v-filename ).
      os-delete value ( v-pathrc ) recursive.
      put stream mProt unformatted "Удален UFO файл: " v-pathrc skip.
  end.
end.
input stream flstream close.
put stream mProt unformatted "обраб. файлы из " p0-source-dir skip.
put stream mProt unformatted " " skip.
UPDATE_CYCLE:
for each upgfile-tbl no-lock
on error undo, return error return-value
:
    put stream mProt unformatted "начало процесса обновления: " UpgFile-tbl.NameUpgFile " " skip.
    run write-to-log (substitute("&1начало процесса обновления &2", substitute("БД&1 ", g#db-num), UpgFile-tbl.NameUpgFile)).
    mIsError = upgfile-tbl.dateupg <= v-compile-date.
    run write-to-log (substitute(
                        "&1Сравнение даты обновления – &2",
                        substitute("БД&1 ", g#db-num),
                        if mIsError
                          then "ошибка, дата обновления равна или меньше текущей версии r-кодов"
                          else "успешно")
                      ).
    if mIsError then
    do:
      put stream mProt unformatted "Пропуск дата <= текущей: " UpgFile-tbl.NameUpgFile skip.
      delete upgfile-tbl.
      next UPDATE_CYCLE.
    end.
    mRunFile = SearchFile ("!beforeTH.bat").
    if SearchFile (mRunFile) <> ?
      then os-delete value ( mRunFile ).
    mRunFile = SearchFile ("!upd-rc-before.bat").
    if SearchFile (mRunFile) <> ?
      then os-delete value ( mRunFile ).
    mRunFile = SearchFile ("!upd-rc-after.bat").
    if SearchFile (mRunFile) <> ?
      then os-delete value ( mRunFile ).
    v-txt = substitute('&1\exe\7z.exe x -y -o&1 &2 *.bat'
                      , v-PathRC
                      , UpgFile-tbl.FullNameUpgFile
                      ) .
    put stream mProt unformatted "распаковка BAT: " v-txt skip.
    os-command silent value ( v-txt ) .
    mIsError = os-error <> 0
             or SearchFile ("!beforeTH.bat") = ?
             or SearchFile ("!upd-rc-before.bat") = ?
             or SearchFile ("!upd-rc-after.bat") = ?.
    run write-to-log (substitute(
                        "&1Копирование bat-файлов – &2",
                        substitute("БД&1 ", g#db-num),
                        if mIsError
                          then "ошибка"
                          else "успешно")
                      ).
    if mIsError then do:
      put stream mProt unformatted "ошибка распаковки BAT " skip.
      next UPDATE_CYCLE.
    end.
    put stream mProt unformatted "BAT файлы распакованы " skip.
    mRunFile = SearchFile ("!beforeTH.bat").
    if mRunFile ne ?
    then do:
       put stream mProt unformatted "Запуск !beforeTH.bat" skip.
       run waitfram-show in this-procedure ("Выполнение " + mRunFile ).
       os-command value (substitute ("&2 &1 exit" ,chr(38), mRunFile)).
       mIsError = os-error <> 0 .
       os-delete value ( mRunFile ).
       run write-to-log (substitute(
                           "&1Запуск !beforeTH.bat – &2",
                           substitute("БД&1 ", g#db-num),
                           if mIsError
                             then "ошибка"
                             else "успешно")
                         ).
       put stream mProt unformatted "Результат !beforeTH.bat: " (if mIsError then "ошибка" else "успешно") skip.
       if mIsError then next UPDATE_CYCLE.
    end.
    run upload1C in this-procedure.
        run nws/nws-init.p no-error.
    mRunFile = SearchFile ("!upd-rc-before.bat").
    if mRunFile ne ?
    then do:
       put stream mProt unformatted "Выполнение !upd-rc-before.bat" skip.
       run waitfram-show in this-procedure ("Выполнение " + mRunFile ).
       os-command value (substitute ("&2 &1 exit" ,chr(38), mRunFile)).
       mIsError = os-error <> 0.
       os-delete value ( mRunFile ).
       run write-to-log (substitute(
                           "&1Запуск !upd-rc-before.bat – &2",
                           substitute("БД&1 ", g#db-num),
                           if mIsError
                             then "ошибка"
                             else "успешно")
                         ).
       put stream mProt unformatted "Результат !upd-rc-before.bat: " (if mIsError then "ошибка" else "успешно") skip.
       if mIsError then next UPDATE_CYCLE.
    end.
    if v-filename begins "rc_20" then do:
      assign
        file-info:file-name = v-pathrc + "-old"
      .
      if file-info:file-type <> ? then do:
          os-delete value ( v-pathrc + "-old" ) recursive.
          if os-error <> 0 then do:
              os-rename  value ( v-pathrc + "-old" ) value ( v-pathrc + "-old1" ).
              if os-error <> 0 then do:
                  put stream mProt unformatted "ошибка удаления папки rc-old" skip.
                  return error string ( "Невозможно удалить папку " + v-pathrc + "-old, удалите ее сами" ).
              end.
          end.
      end.
      os-rename  value ( v-pathrc ) value ( v-pathrc + "-old" ).
      if os-error <> 0 then do:
          put stream mProt unformatted "ошибка переименования rc" skip.
          return error string(( "Невозможно переименовать папку " + v-pathrc + " для сохранности" )).
      end.
      put stream mProt unformatted "Папка переименована: " v-pathrc " -> " v-pathrc + "-old" skip.
      os-create-dir value( v-pathrc ).
      if os-error <> 0 then do:
          os-rename  value ( v-pathrc  + "-old") value ( v-pathrc ).
          put stream mProt unformatted "ошибка создания папки rc" skip.
          return error string ( "Невозможно создать папку " + v-pathrc ).
      end.
      put stream mProt unformatted "Создана папка: " v-pathrc skip.
      v-txt = "".
      v-txt =  v-PathRC + "-old\exe\7z.exe" + " x -y -o" + v-PathRC + " " +  UpgFile-tbl.FullNameUpgFile.
      put stream mProt unformatted "Команда распаковки RC: " v-txt skip.
      os-command silent value ( v-txt ) .
      put stream mProt unformatted "Распаковка RC выполнена, код ошибки: " STRING(os-error) skip.
    end.
    v-delfile = search( "!delfile.bat" ).
    if v-delfile <> ? then do:
        put stream mProt unformatted "Найден !delfile.bat, выполнение удаления" skip.
        input from value ( v-delfile ) .
        repeat :
           import unformatted v-txt.
           if trim (v-txt) = "" then next.
           v-txt = trim(substring ( v-txt, r-index(v-txt, " ") )).
           if trim (v-txt) = "" then next.
           v-txt = search( v-txt ).
           put stream mProt unformatted "Удаление файла: " v-txt skip.
           os-delete value ( v-txt ) recursive.
        end.
        input close.
    end.
    os-delete value ( v-delfile ) recursive.
    put stream mProt unformatted "Удален !delfile.bat" skip.
end.
put stream mProt unformatted "запуск code-updck.p " skip.
run waitfram-show in this-procedure ("Выполнение xml-файлов обновления" ).
run gbl/code-updck.p(input  this-procedure)  no-error .
if error-status:error then
do:
   put stream mProt unformatted "ошибка запуска code-updck.p: " return-value skip.
   run write-to-log (substitute(
                       "&1&2",
                       substitute("БД&1 ", g#db-num),
                       return-value)
                     ).
end.
else do:
   put stream mProt unformatted "code-updck.p выполнен " skip.
end.
def var v-file-name as character no-undo.
def var v-msg       as character no-undo.
mRunFile = SearchFile ("!upd-rc-after.bat").
if mRunFile ne ?
then do:
   put stream mProt unformatted "Выполнение !upd-rc-after.bat" skip.
   run waitfram-show in this-procedure ("Выполнение " + mRunFile ).
   os-command value (substitute ("&2 &1 exit" ,chr(38), mRunFile)).
   mIsError = os-error <> 0.
   os-delete value ( mRunFile ).
   run write-to-log (substitute(
                       "&1Запуск !upd-rc-after.bat – &2",
                       substitute("БД&1 ", g#db-num),
                       if mIsError
                         then "ошибка"
                         else "успешно")
                     ).
   put stream mProt unformatted "Результат !upd-rc-after.bat: " (if mIsError then "ошибка" else "успешно") skip.
end.
assign
  mDirLog = substring(p0-source-dir, r-index(p0-source-dir, "\") + 1).
  mDirLog = substitute("&1-&2",entry(2,mDirLog,"-"),entry(1,mDirLog,"-")).
  mDirLog = substring(p0-source-dir, 1, r-index(p0-source-dir, "\")) + mDirLog
.
os-command silent
  value( "copy" )
  value( mFileLog )
  value( mDirLog + substring(mFileLog, r-index(mFileLog, "\")) )
.
add-log-file-name = ?.
CheckUpd:workStart ().
for each upgfile-tbl :
    delete upgfile-tbl.
end.
put stream mProt unformatted (if can-find(first upgfile-tbl) then
         "Установлены обновления Тrade Нouse. Для их применения необходимо закрыть все программы TH и запустить их снова."
       else "Новых обновлений нет.") skip.
run waitfram-hide in this-procedure .
return if can-find(first upgfile-tbl) then
         "Установлены обновления Тrade Нouse. Для их применения необходимо закрыть все программы TH и запустить их снова."
       else "Новых обновлений нет.".
procedure upload1C:
    oldg#news = g#news .
    oldg#esys = g#esys .
   g#news = false .
   g#esys = true .
   run bge/oxml-ini.p no-error.
   run write-to-log (substitute(
                        "&1инициализация переменных для системы OpenXML - &2",
                        substitute("БД&1 ", g#db-num),
                        if error-status:error
                          then substitute("ошибка&1&2&3&4",
                                          if return-value <> "" then chr(10) else "",
                                          return-value,
                                          if error-status :get-message( error-status :num-messages ) <> "" then chr(10) else "",
                                          error-status :get-message( error-status :num-messages ))
                          else "успешно")
                    ).
   define variable m-db-num as int no-undo.
   define variable m-extsys as character no-undo.
   find first sys-ctrl no-error.
   m-db-num = sys-ctrl.db-num.
   run bge/oxmlinx.p (
          input parparentproc
        , input this-procedure
        , input this-procedure
        , input substitute("&1,&2,&3,&4"
                          , "take+analys"
                          , m-db-num
                          , m-extsys
                          , 0)
    ) no-error.
    run write-to-log (substitute(
                        "&1загрузка OpenXML – &2",
                        substitute("БД&1 ", g#db-num),
                        if error-status :error
                          then substitute("ошибка&1&2&3&4",
                                          if return-value <> "" then chr(10) else "",
                                          return-value,
                                          if error-status :get-message( error-status :num-messages ) <> "" then chr(10) else "",
                                          error-status :get-message( error-status :num-messages ))
                          else "успешно")
                      ).
    define variable m-err-code as character no-undo.
    define variable m-message as character no-undo.
    run bge/cnewxpck.p (
                      input  m-extsys
                    , output m-err-code
    ) no-error .
    run write-to-log (substitute(
                        "&1подготовка новых пакетов – &2",
                        substitute("БД&1 ", g#db-num),
                        if error-status :error
                          then substitute("ошибка&1&2&3&4",
                                          if return-value <> "" then chr(10) else "",
                                          return-value,
                                          if error-status :get-message( error-status :num-messages ) <> "" then chr(10) else "",
                                          error-status :get-message( error-status :num-messages ))
                          else substitute("успешно&1&2",
                                          if return-value <> "" then chr(10) else "",
                                          return-value))
                      ).
    run bge/oxmloutx.p (
            input parparentproc
          , input this-procedure
          , input this-procedure
          , input substitute("all,&1", m-db-num )
      ) no-error.
    run write-to-log (substitute(
                        "&1выгрузка OpenXML – &2",
                        substitute("БД&1 ", g#db-num),
                        if error-status :error
                          then substitute("ошибка&1&2&3&4",
                                          if return-value <> "" then chr(10) else "",
                                          return-value,
                                          if error-status :get-message( error-status :num-messages ) <> "" then chr(10) else "",
                                          error-status :get-message( error-status :num-messages ))
                          else "успешно")
                      ).
   g#news = oldg#news.
   g#esys = oldg#esys.
end procedure.
FINALLY:
        OUTPUT CLOSE.
    END.
