block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: 5918d4369f7a, 3506, rls $":U .
define variable vss-author      as character no-undo init "$Author: VSpiridonov $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:37 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send-all.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send-all.p $":U .
define variable vss-description as character no-undo init "Отсылка схемы интеграции ККТ".
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
define variable v-view-log as logical no-undo.
define variable log-file-name as character no-undo.
define variable out as character no-undo.
define variable v-xml-file-name as character no-undo.
define variable v-xml-file-name-path as character no-undo.
define variable v-log-file-name as character no-undo init "send-cd.txt".
define variable v-locked as logical no-undo.
procedure xml-cd-filename :
do
on error undo, return error
:
define input parameter  p-out               as character no-undo .
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-xml-file-name-path   as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-locked            as logical      no-undo.
define variable v-out as character     no-undo.
define variable loc#log as logical no-undo .
define variable BadFlag as logical no-undo .
define variable fq as integer no-undo .
define variable v-remote as character no-undo .
assign
p-xml-file-name = substring( string( next-value( s-spool, ub), '99999999999999999999'), 13, 8 )
p-xml-file-name-path = p-out + p-xml-file-name + ".":U
p-log-file-name = p-out + "actions.log"
p-locked = ( search ( p-xml-file-name-path + "lk" ) <> ? )
.
end.
end procedure.
define variable vss-revision0    as character no-undo init "$Revision:$":U .
define variable vss-author0      as character no-undo init "$Author:$":U .
define variable vss-date0        as character no-undo init "$Date:$":U .
define variable vss-workfile0    as character no-undo init "$Workfile:$":U .
define variable vss-archive0     as character no-undo init "$Archive:$":U .
define variable vss-description0 as character no-undo init "Работа С сокетом".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable mHSocket       as handle      no-undo.
define variable mWebRespHead   as longchar    no-undo.
define variable mWebResp       as longchar    no-undo.
define variable mWebRespMptr   as memptr      no-undo.
define variable OerrMsg        as character   no-undo.
define variable mFileLogSocet  as character   no-undo.
define variable mReturnHttp    as logical     no-undo.
define variable mAddTimeOut    as logical     no-undo init yes.
define variable mSocetBegTime  as datetime-tz no-undo.
define variable mSocetEndTime  as dec         no-undo.
define variable mWriteRespFile as character   no-undo.
define variable mTypeResponse  as character   no-undo init "POST".
publish "getSocetLog" (output mFileLogSocet).
if
   (   mFileLogSocet eq ""
    or mFileLogSocet eq ?)
   and session:debug-alert
then
   mFileLogSocet = "socet.log".
procedure ConectSocet:
   define input  parameter iHost       as character no-undo.
   define input  parameter iPort       as character no-undo.
   define input  parameter iUrl        as character no-undo.
   define input  parameter iPostData   as longchar  no-undo.
   define input  parameter iReturnType as character no-undo.
   define input  parameter iTimeOut    as decimal   no-undo.
   define input  parameter iSilent     as logical   no-undo.
   define input  parameter iTextWait   as character no-undo.
   mWaitFramTextBeg = iTextWait.
   run SendReqSocet (iHost, iPort, iUrl, iPostData, iReturnType, 'getResponse').
   if OerrMsg eq ""
   then
      run waitrespsocet (iTimeOut, iSilent, iTextWait).
   mSocetEndTime = (now - mSocetBegTime) / 1000.
end.
procedure SendReqSocet:
   define input  parameter iHost            as character no-undo.
   define input  parameter iPort            as character no-undo.
   define input  parameter iUrl             as character no-undo.
   define input  parameter iPostData        as longchar  no-undo.
   define input  parameter iReturnType      as character no-undo.
   define input  parameter iProcGetResponse as character no-undo.
   mSocetBegTime = now.
   run writeLogSocet in this-procedure (substitute("Подключаемся к адресу &1 по порту &2",iHost,iPort )).
   assign
      mWebResp         = ""
      mWebResphead     = ""
      OerrMsg          = ""
      mReturnHttp      = iReturnType eq "xml" or iReturnType eq "http" or iReturnType eq "yes"
      iProcGetResponse = "getResponse"  when iProcGetResponse eq ? or iProcGetResponse eq ""
   .
   define variable vPostData as longchar                       no-undo.
   if    iHost eq ""
      or iHost eq ?
   then do:
      oErrMsg = substitute("Не задан host &1 или port &2.", ihost ,iport).
      run writeLogSocet in this-procedure (oErrMsg).
      return oErrMsg.
   end.
   run waitfram-show (substitute("Подключаемся к адресу &1 по порту &2",iHost,iPort )).
   create socket mHSocket.
   mHSocket:connect('-H ' + iHost + ' -S ' + iPort) no-error.
   if mHSocket:connected() = false
   then do:
      run waitfram-hide .
      oErrMsg = substitute( "Не удалось установить соединение: &1" , error-status:get-message(1)).
      run writeLogSocet in this-procedure (oErrMsg).
      delete object mHSocket.
      return oErrMsg.
   end.
   run waitfram-show ("Отправка данных").
   mHSocket:set-read-response-procedure(iProcGetResponse).
   run PostRequest (
    input iUrl,
    input iHost + ":" + iPort,
    input iPostData
    ).
    run waitfram-hide .
end.
procedure WaitRespSocet:
   define input  parameter iTimeOut   as decimal   no-undo.
   define input  parameter iSilent    as logical   no-undo.
   define input  parameter iTextWait  as character no-undo.
   if    not valid-handle (mHSocket )
   then do:
      run writeLogSocet in this-procedure (substitute("Потерян объект соединения")).
      return "End connected".
   end.
   if mHSocket:connected() = false
   then do:
      run writeLogSocet in this-procedure (substitute("Соединение было разорвано другой стороной WaitRespSocet")).
      oErrMsg = "Not connected".
      return oErrMsg.
   end.
   mWaitFramView = if iSilent ne yes then yes else no.
   mWaitFramTextBeg = iTextWait.
   mWaitFramTimeOut = iTimeOut.
   mWaitFramTextEnd = "".
   mWaitFramStop = no.
   if mAddTimeOut
   then do:
      mWaitFramTimeOut = 300.
      run writeLogSocet in this-procedure (substitute ("Таймаут увеличен до &1 при уcтановке соодинения",mWaitFramTimeOut)).
   end.
   run writeLogSocet in this-procedure (substitute("Ожидаем ответ TimeOut &1 сек.",iTimeOut )).
   subscribe   to "WaitFramStop" anywhere run-procedure "WaitRespTestStop".
   run WaitFramWaitFor(1).
   unsubscribe "WaitFramStop".
   if mWaitFramStopUser
   then do:
      OerrMsg = substitute("Операция прервана пользователем." ).
      run writeLogSocet in this-procedure (OerrMsg).
   end.
   else if mWaitFramStopTimeOut
   then do:
      OerrMsg = substitute("Привышено время ожидания &1 сек. Ответ не получен.",iTimeOut ).
      run writeLogSocet in this-procedure (OerrMsg).
   end.
   run waitfram-hide .
   mHSocket:disconnect() no-error.
   delete object mHSocket.
end.
procedure WaitRespTestStop:
   if mWaitFramStopTimeOut
   then
      return.
   if     (mWebResp ne ""
       and mWebResp ne ?)
   then do:
      mWaitFramStop = yes.
      return.
   end.
   else if mHSocket:connected() = false
   then do:
      mWaitFramStop = yes.
      run writeLogSocet in this-procedure (substitute("Соединение было разорвано другой стороной WaitRespTestStop")).
      oErrMsg = "Not connected".
      return oErrMsg.
   end.
   wait-for read-response of mHSocket pause 0.001.
end.
procedure PostRequest:
   define input parameter iPostUrl  as char.
   define input parameter iPostHost as char.
   define input parameter iPostData as longchar.
   define variable vCRequest      as longchar.
   define variable vMRequest       as memptr.
   if iPostUrl ne ?
   then do:
      vCRequest =substitute(
      '&5 /&2 HTTP/1.1&1'                                   +
      'Host: &4&1'                                           +
      'User-Agent: Apache-HttpClient/4.1.1 (java 1.5)&1'    +
      'Accept: */*&1' +
      'Content-Type: text/xml&1'               +
      'Content-Length: &3&1'                                  +
      '&1'
      ,
      chr(13) + chr(10),
      iPostUrl,
      length(iPostData),
      iPostHost,
      mTypeResponse) + iPostData.
   end.
   else
      vCRequest = iPostData.
   run writeLogSocet in this-procedure (substitute("Отправляем запрос &1.",chr(13) + chr(10) )).
   run writeLogSocet in this-procedure (vCRequest).
   SET-SIZE(vMRequest)            = 0.
   SET-SIZE(vMRequest)            = length(vCRequest) + 1.
   SET-BYTE-ORDER(vMRequest)      = big-endian.
   PUT-STRING(vMRequest,1)        = vCRequest .
   if mHSocket:connected() = false then
   do:
      run writeLogSocet in this-procedure ("Соединение было разорвано другой стороной getResponse").
      oErrMsg = "Not connected".
      delete object mHSocket no-error.
      return oErrMsg.
   end.
   mHSocket:write(vMRequest, 1, length(vCRequest)).
   run writeLogSocet in this-procedure ("Запрос отправлен.").
end procedure.
function hex-to-int returns integer (
  input p-hex-code  as character  ).
  define variable v-int-code as integer   no-undo .
  define variable v-ind      as integer   no-undo .
  define variable v-digit    as integer   no-undo .
  define variable v-letter   as character no-undo .
  do v-ind = 1 to length(p-hex-code)
  :
    assign
      v-letter = caps(substring(p-hex-code, v-ind, 1))
    .
    assign
      v-digit = index('123456789ABCDEF':u, v-letter)
    .
    assign
      v-int-code = v-int-code * 16 + v-digit
    .
  end.
  return v-int-code .
end function .
procedure getResponse:
   define variable vFlagTag     as logical          no-undo init no.
   define variable vResponse    as memptr           no-undo.
   define variable vCnt         as int64            no-undo.
   define variable vMessage     as longchar         no-undo.
   define variable v-cont-length as int64 no-undo.
   define variable vi           as integer no-undo.
   define variable v-hd-line    as character no-undo.
   define variable level        as integer no-undo initial 2.
   repeat while program-name(level) <> ?:
     if program-name(level) = program-name(1) then do:
       run writeLogSocet in this-procedure (substitute("Повторный вызов getResponse.")).
       return "".
     end.
     level = level + 1.
   end.
   if mHSocket:connected() = false then
   do:
      run writeLogSocet in this-procedure (substitute("Соединение было разорвано другой стороной getResponse")).
      oErrMsg = "Not connected".
      return oErrMsg.
   end.
   if mAddTimeOut
   then do:
      mWaitFramTimeOut = 1000.
      run writeLogSocet in this-procedure (substitute ("Таймаут увеличен до &1 при получении ответа",mWaitFramTimeOut)).
   end.
   run writeLogSocet in this-procedure (substitute("Получаем ответ")).
   mWaitFramTextEnd = "Получаем ответ".
   define variable vWaitProcEvent as logical no-undo.
   vWaitProcEvent = mWaitProcEvent.
   mWaitProcEvent = no.
   run WaitFramRunPause (?).
   define variable vByte as int64 no-undo.
   define variable vNextMese as int64 no-undo init 100000.
   define variable VFlag as logical no-undo init ? .
   mWaitFramStop = no.
   mWaitFramStopTimeOut = no.
   block-wait:
   do while mHSocket:get-bytes-available() > 0:
      VFlag = no.
      define variable vNumByte as integer no-undo.
      vNumByte =   mHSocket:get-bytes-available().
      if vNumByte > 30000 then vNumByte = 30000.
      SET-SIZE(vResponse) = vNumByte + 1.
      SET-BYTE-ORDER(vResponse) = big-endian.
      mHSocket:read(vResponse,1,vNumByte).
      vMessage = vMessage + GET-STRING(vResponse,1).
      if  mReturnHTTp
      then do:
         vCnt = index(vMessage,chr(13) + chr(10) + chr(13) + chr(10)).
         if vCnt > 0
         then do:
            mReturnHttp = no.
            mWebResphead = substring (vMessage,1,vCnt).
            vMessage     = substring (vMessage,vCnt + 4).
            mWebResphead = replace (mWebResphead,";",chr(13) + chr(10)).
            do vi = 1 to num-entries(mWebResphead,chr(13) + chr(10)):
               v-hd-line = trim(entry(vi,mWebResphead,chr(13) + chr(10))).
               if  v-hd-line  begins "Content-Length"  then  do:
                  v-cont-length = INT(trim(substring(v-hd-line,16,length(v-hd-line)))).
               end.
               else if v-hd-line  begins "Transfer-Encoding"
               then do :
                  define variable vChunked as logical no-undo.
                  vchunked = index(v-hd-line,"chunked",19) > 0.
               end.
            end.
         end.
      end.
      vByte = vByte + vNumByte.
      SET-SIZE(vResponse) = 0.
      if v-cont-length > 0 and length (vMessage) >= v-cont-length
      then
         leave block-wait.
      if not mHSocket:get-bytes-available() > 0
      then do:
         VFlag = yes.
         run WaitFramRunPause (?).
         run gbl/pause.p (1000) .
      end.
      else if vByte > vNextMese
      then do:
         vNextMese = vNextMese + 100000.
         mWaitFramTextEnd = substitute ("Получаем ответ прочитано &1 байт ",vByte) .
         run WaitFramRunPause (?).
      end.
      if mWaitFramStopTimeOut
      then do:
         mWebResp = "".
         leave block-wait.
      end.
   end.
   if VFlag ne false
   then
      run writeLogSocet in this-procedure (substitute ("Завершена обработка &1",If VFlag eq  yes then " 0 байт за последнию секунду" else " пустой ответ(((")).
   mWaitFramStop = yes.
   run writeLogSocet         in this-procedure ("Получен ответ").
   run writeLogSocetOnlyText in this-procedure (mWebResphead).
   run writeLogSocetOnlyText in this-procedure (substitute("&1&2&1&2",chr(13) , chr(10) )).
   run writeLogSocetOnlyText in this-procedure (vMessage).
   run writeLogSocetOnlyText in this-procedure (substitute("&1&2",chr(13) , chr(10) )).
   mHSocket:disconnect() no-error.
   if v-cont-length > 0
   then
      mWebResp = substring (vMessage,1,v-cont-length).
   else if vChunked
   then do:
      define variable vByteCopy as int64 no-undo init 1.
      Block-Copy:
      do while length(vMessage) > 0:
         vByteCopy = 1.
         vCnt = index (vMessage,chr(13) + chr(10)) - 1.
         vByteCopy = vByteCopy +  vCnt + 2.
         v-cont-length = hex-to-int(string(substring (vMessage,1,vCnt))).
         if v-cont-length eq 0
         then
            leave Block-copy.
         mWebResp = mWebResp + substring (vMessage,vByteCopy,  v-cont-length).
         vByteCopy = vByteCopy + v-cont-length + 2.
         vMessage = substring  (vMessage,vByteCopy).
      end.
      run writeLogSocet         in this-procedure ("Заголовок").
      run writeLogSocetOnlyText in this-procedure (mWebResphead).
      run writeLogSocet         in this-procedure ("Тело ответа").
      run writeLogSocetOnlyText in this-procedure (mWebResp).
     run writeLogSocetOnlyText in this-procedure (substitute("&1&2",chr(13) , chr(10) )).
   end.
   else
      mWebResp = vMessage.
   mWaitProcEvent = vWaitProcEvent.
   mSocetEndTime = (now - mSocetBegTime) / 1000.
   copy-lob mWebResp to mWebRespMptr.
   if     mWriteRespFile ne ""
      and mWriteRespFile ne ?
   then
        run gbl/fileapnd.p
             ( mWriteRespFile
             , mWebResp + chr(13) + chr(10)
             ,input 10
             ) no-error .
end procedure.
procedure writeLogSocet:
   define input  parameter itext as longchar no-undo.
   if mFileLogSocet eq "Async"
   then
      run PutMesAsunc(itext).
   else if     mFileLogSocet ne ?
           and mFileLogSocet ne ""
   then do:
      run gbl/fileapnd.p
          ( mFileLogSocet
          , substitute("&1 &2 ", string(today), string(time, "HH:MM:SS"))
          ,input 10
          ) no-error .
      run writeLogSocetOnlyText(itext).
      run gbl/fileapnd.p
          ( mFileLogSocet
          , substitute(" &1&2", chr(13) , chr(10))
          ,input 10
          ) no-error .
   end.
end.
procedure writeLogSocetOnlyText:
   define input  parameter itext as longchar no-undo.
   if mFileLogSocet eq "Async"
   then
      run PutMesAsunc(itext).
   else if     mFileLogSocet ne ?
           and mFileLogSocet ne ""
   then do:
      if length(itext) > 32000
      then
         copy-lob
   from object itext
   to file mFileLogSocet append
   no-error
   .
      else
      run gbl/fileapnd.p
          ( mFileLogSocet
          , string(itext)
          ,input 10
          ) no-error .
   end.
end.
procedure Disconect:
   mHSocket:disconnect() no-error.
   delete object mHSocket no-error.
end.
run get-view-log in p-log-handle(output v-view-log)  no-error.
define variable i-obj-type as character no-undo .
define variable i-obj-code as integer   no-undo .
define variable i-action   as character no-undo init 'U':U.
define variable i-type     as character no-undo .
define variable i-title     as character no-undo .
define variable i-value    as character no-undo .
if num-entries (p-parameter,chr(4)) < 4
then do:
   run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!'Send-all' Список параметров должен состоять минимум из 4 элементов "
                        )
                        ).
   run set-view-log in p-log-handle(yes)  no-error.
   return.
end.
else do:
   define variable vi as integer no-undo.
   i-Type    = entry(4, p-parameter, chr(4)).
   vi = num-entries (i-Type).
   if vi eq 0
   then do:
      run write-log-and-file in p-log-handle (
           input 1
         , input log-file-name
         , input 1
         , input substitute( "!!!'Send-all' В список параметров 4 элемент не может быть пустым "
                           )
                                 ).
      run set-view-log in p-log-handle(yes)  no-error.
      return.
   end.
   else if vi > 1
   then do:
      do vi = 1 to num-entries (i-type):
         entry(4, p-parameter, chr(4)) = entry(vi,i-type).
         run str/send-all.p(parparentproc,
                            p-parent-handle,
                            p-log-handle,
                            p-parameter
         ).
      end.
      return.
   end.
end.
assign
i-obj-type = entry(1, p-parameter, chr(4))
i-obj-code = integer(entry(2, p-parameter, chr(4)))
i-action     = entry(3, p-parameter, chr(4))
i-Type    = entry(4, p-parameter, chr(4))
i-Title    = entry(5, p-parameter, chr(4))
i-value    = entry(6, p-parameter, chr(4))
no-error
.
if i-Type eq "?"
then
   return error "Не задан тип для send-all.p".
define variable mValue   as character no-undo.
define variable mNumPar  as integer no-undo.
define variable mSendAll as logical no-undo.
define variable mCashNum as integer no-undo init ?.
define variable mCashAll as logical no-undo.
define variable mNumCashAll as integer no-undo.
mValue = replace(i-value,",","=").
mNumPar = lookup("cash-send",mValue,"=").
if mNumPar > 0
then do:
   mSendAll = entry(mNumPar + 1,mValue,"=") eq "all" no-error.
   mCashNum = int(entry(mNumPar + 1,mValue,"=")) no-error.
   if mCashNum <> ? and not mSendAll then do:
      mNumCashAll = lookup("cash-all",mValue,"=").
      if mNumCashAll > 0 then do:
          mCashAll = entry(mNumCashAll + 1,mValue,"=") eq "all" no-error.
          if mCashNum <> ? and mCashNum <> 0 and mCashAll
          then mSendAll = yes.
      end.
   end.
end.
mNumPar = lookup("SocetLog",mValue,"=").
if mNumPar > 0
then
   mFileLogSocet = entry(mNumPar + 1,mValue,"=") no-error.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure   for-cash-cycle:
   define variable v-cash-types as character no-undo init 'IBM-XML':U.
   define variable V-root-teg   as character no-undo init "data".
   define variable v-xml-encoding as character no-undo init "windows-1251".
   define variable v-tag-from   as character no-undo.
   define variable v-tag-to     as character no-undo.
   define variable v-work-handle as handle no-undo .
   if     search("str/send-all-work-" + i-type + ".p") eq ?
      and search("str/send-all-work-" + i-type + ".r") eq ?
   then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Не найдена str/send-all-work-&1.r"
                                ,i-type
                            )
                                            ).
      v-view-log = yes.
      return.
   end.
   run value ( "str/send-all-work-" + i-type + ".p") persistent set v-work-handle no-error .
   if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Ошибка при выполнение процедуры str/send-all&1.r (&2) : &3 &4"
                                ,i-type
                                ,search("str/send-all" + i-type + ".p")
                                ,return-value
                                ,error-status:get-message (1)
                            )
                                            ).
      v-view-log = yes.
      return.
   end.
   if lookup("get-xml-encoding", v-work-handle:internal-entries) >  0
   then do:
      run get-xml-encoding  in v-work-handle (output v-xml-encoding) no-error.
      if error-status:error then do:
         run write-log-and-file in p-log-handle (
               input 1
             , input log-file-name
             , input 1
             , input substitute( "!!!Ошибка при выполнение процедуры &1 (str/send-all&4.r) : &2 &3"
                                   ,"get-xml-encoding"
                                   ,return-value
                                   ,error-status:get-message (1)
                                   , i-type
                               )
                                               ).
         v-view-log = yes.
         return.
      end.
   end.
   if lookup("get-tag-from", v-work-handle:internal-entries) >  0
   then do:
      run get-tag-from in v-work-handle (output v-tag-from) no-error.
      if error-status:error then do:
         run write-log-and-file in p-log-handle (
               input 1
             , input log-file-name
             , input 1
             , input substitute( "!!!Ошибка при выполнение процедуры &1 (str/send-all&4.r) : &2 &3"
                                   ,"get-teg-from"
                                   ,return-value
                                   ,error-status:get-message (1)
                                   , i-type
                               )
                                               ).
         v-view-log = yes.
         return.
      end.
   end.
   if lookup("get-tag-to", v-work-handle:internal-entries) >  0
   then do:
      run get-tag-to in v-work-handle (output v-tag-to) no-error.
      if error-status:error then do:
         run write-log-and-file in p-log-handle (
               input 1
             , input log-file-name
             , input 1
             , input substitute( "!!!Ошибка при выполнение процедуры &1 (str/send-all&4.r) : &2 &3"
                                   ,"get-teg-to"
                                   ,return-value
                                   ,error-status:get-message (1)
                                   , i-type
                               )
                                               ).
         v-view-log = yes.
         return.
      end.
   end.
   if lookup("get-cash-types", v-work-handle:internal-entries) >  0
   then do:
      run get-cash-types  in v-work-handle (output v-cash-types) no-error.
      if error-status:error then do:
         run write-log-and-file in p-log-handle (
               input 1
             , input log-file-name
             , input 1
             , input substitute( "!!!Ошибка при выполнение процедуры &1 (str/send-all&4.r) : &2 &3"
                                   ,"get-cash-types"
                                   ,return-value
                                   ,error-status:get-message (1)
                                   , i-type
                               )
                                               ).
         v-view-log = yes.
         return.
      end.
   end.
   if lookup(ub.cash-desk.pos-type,v-cash-types) ne 0
   then do:
      if lookup("get-root-teg", v-work-handle:internal-entries) >  0
      then do:
         run get-root-teg in v-work-handle (output V-root-teg) no-error.
         if error-status:error then do:
            run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute( "!!!Ошибка при выполнение процедуры &1 (str/send-all&4.r) : &2 &3"
                                      ,"get-roor-teg"
                                      ,return-value
                                      ,error-status:get-message (1)
                                      ,i-type
                                  )
                                                  ).
            v-view-log = yes.
            return.
         end.
      end.
      define variable vProcInfo as character no-undo.
      if lookup("set-context", v-work-handle:internal-entries) >  0
      then do:
         run set-context in v-work-handle (parparentproc,
                                           p-log-handle,
                                           log-file-name,
                                           output vProcInfo) no-error.
         if error-status:error then do:
            run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute( "!!!Ошибка при выполнение процедуры &1 (str/send-all&4.r) : &2 &3"
                                      ,"set-context"
                                      ,return-value
                                      ,error-status:get-message (1)
                                      ,i-type
                                  )
                                                  ).
            v-view-log = yes.
            return.
         end.
      end.
      run write-log-and-file in p-log-handle (
                        input 1
                      , input log-file-name
                      , input 1
                      , input substitute( 'Обработка запроса &1 на кассы магазина &2 начата'
                                            ,if vProcInfo ne "" then '"' + vProcInfo + '"' else ""
                                            ,i-obj-code
                                        )
                                                        ).
      define buffer for-cash-desk for ub.cash-desk.
      define variable mQuery as handle    no-undo.
      define variable vqry   as character no-undo.
      create query mQuery.
      mQuery:set-buffers(buffer for-cash-desk:HANDLE).
      vqry = substitute("for each for-cash-desk no-lock where
                                  for-cash-desk.db-num   eq &1 
                              and for-cash-desk.pos-type eq '&2'      
                              and for-cash-desk.obj-code eq &3 "
                           ,  g#db-num, ub.cash-desk.pos-type,i-obj-code).
      if mCashNum ne ?
      then
         vqry = vqry + substitute(" and for-cash-desk.cash-num eq &1", mCashNum).
      else
         vqry = vqry + " and for-cash-desk.is-del   ne  true
                         and for-cash-desk.autonomy ne 1".
      if not mSendAll
      then
         vqry = vqry + " and for-cash-desk.cash-on  eq yes".
      vqry = vqry + "   
 by for-cash-desk.db-num
 by for-cash-desk.obj-code
 by for-cash-desk.pos-type
 by for-cash-desk.cash-on ".
      mQuery:query-prepare(vqry).
      mQuery:query-open ().
      mQuery:get-first ().
      do while not mQuery:query-off-end:
        if lookup("set-cash-info", v-work-handle:internal-entries) >  0
        then do:
            run set-cash-info in v-work-handle (for-cash-desk.db-num,
                                                'маг':U,
                                                for-cash-desk.obj-code,
                                                for-cash-desk.pos-type,
                                                for-cash-desk.cash-num) no-error.
            if error-status:error then do:
               run write-log-and-file in p-log-handle (
                     input 1
                   , input log-file-name
                   , input 1
                   , input substitute( "!!!Ошибка при выполнение процедуры &1 (str/send-all&4.r) : &2 &3"
                                         ,"set-cash-info"
                                         ,return-value
                                         ,error-status:get-message (1)
                                         ,i-type
                                     )
                                                     ).
              v-view-log = yes.
              return.
           end.
        end.
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "Пересылка - касса &1", for-cash-desk.cash-num
                              )
                                              ).
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable hSAXWriter as handle no-undo.
define variable Mreq as longchar no-undo.
define variable mData as memptr no-undo.
run xml-cd-filename in this-procedure (
      input out
    , output v-xml-file-name
    , output v-xml-file-name-path
    , output v-log-file-name
    , output v-locked
).
create sax-writer hSAXWriter.
hSAXWriter:set-output-destination("memptr", mData) no-error.
hSAXWriter:formatted = true.
hSAXWriter:encoding = v-xml-encoding.
hSAXWriter:start-document() no-error.
define variable OS-time as character  no-undo.
OS-time =  string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" ).
hSAXWriter:start-element(V-root-teg) no-error.
hSAXWriter:insert-attribute("type",   "REQUEST")       no-error.
hSAXWriter:insert-attribute("id",     v-xml-file-name) no-error.
hSAXWriter:insert-attribute("from",   if v-tag-from <> "empty" then substitute ("маг&1", for-cash-desk.cash-num) else "")      no-error.
hSAXWriter:insert-attribute("to",     if v-tag-to = "" then substitute ("маг&1_касса", for-cash-desk.cash-num) else v-tag-to) no-error.
hSAXWriter:insert-attribute("tstamp", string(OS-time))     no-error.
        define variable vOk as logical no-undo.
        run putc in v-work-handle
                     ( input hSAXWriter
                      ,i-action
                      ,input i-value
                      ,output vOk
                      ) no-error.
        if error-status:error then do:
               run write-log-and-file in p-log-handle (
                     input 1
                   , input log-file-name
                   , input 1
                   , input substitute( "!!!Ошибка при выполнение процедуры &1 (str/send-all&4.r) : &2 &3"
                                         ,"putc"
                                         ,return-value
                                         ,error-status:get-message (1)
                                         ,i-type
                                     )
                                                     ).
              v-view-log = yes.
              return.
        end.
        if not vOk
        then
           run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "Запрос данных с кассы не требуется - касса &1", for-cash-desk.cash-num
                              )
                                              ).
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
hSAXWriter:end-element(V-root-teg) no-error.
if error-status:num-messages > 0
then do:
   define variable vnummes as integer no-undo.
   do vnummes = 1 to error-status:num-messages:
      run write-log-and-file in p-log-handle (
                                  input 1
                                , input log-file-name
                                , input 1
                                , input substitute('Ошибка формироваания запроса &1:'
                                              ,error-status:get-message (vnummes)
                                            )).
   end.
end.
hSAXWriter:end-document() no-error.
if hSAXWriter:write-status = 7
then do:
   delete object hSAXWriter no-error.
   return error.
end.
delete object hSAXWriter no-error.
if v-xml-encoding = "Windows-1251" then
   copy-lob from mData to mReq.
else
   copy-lob from mData to mReq convert target codepage v-xml-encoding.
if session:debug-alert then
    copy-lob from mReq to file i-Type + "2kassa.xml".
if
   vOk
then do:
  if (for-cash-desk.pos-type = 'IBM-XML':U
  and for-cash-desk.autonomy = integer('0':U))
  or (for-cash-desk.pos-type = 'Autotank':U
  and for-cash-desk.autonomy = integer('2':U))
  then do:
     run write-log-and-file in p-log-handle (
                               input 1
                             , input log-file-name
                             , input 1
                             , input substitute('Отправка данных на кассы &1 &2'
                                           ,for-cash-desk.cash-num
                                           ,for-cash-desk.obj-code
                                         )).
     run ConectSocet (entry(1,entry(2, for-cash-desk.addr-path, chr(4)),":"),
                      entry(2,entry(2, for-cash-desk.addr-path, chr(4)),":"),
                      "",
                      Mreq,
                      "xml",
                      30,
                      no,
                      substitute ("Отправка данных на кассы &1. ",entry(2, for-cash-desk.addr-path, chr(4)))
                                         ).
     if mWebResp eq ""
     then do:
        run write-log-and-file in p-log-handle (
             input 1
           , input log-file-name
           , input 1
           , input substitute( "!!!Касса &1 маг&2 не ответила:&3&4 &5"
                                 ,for-cash-desk.cash-num
                                 ,for-cash-desk.obj-code
                                 , chr(10)
                                 , OerrMsg
                                 , return-value
                             )
                                             ).
        v-view-log = yes.
     end.
     else do:
        run write-log-and-file in p-log-handle (
                               input 1
                             , input log-file-name
                             , input 1
                             , input substitute('Время ожидания выполнения задания на кассе - &1 c',
                                           mSocetEndTime
                                         )
                                                               ).
        if lookup("parse-result", v-work-handle:internal-entries) >  0
        then do:
           run parse-result in v-work-handle(
                          input mWebRespMptr
                         ,input-output v-view-log
                         ) no-error .
           if error-status:error then do:
              run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute( "!!!Не удалось получить ответ с маг&1 касса &2 об успешной доставке данных"
                                      ,for-cash-desk.obj-code
                                      ,for-cash-desk.cash-num
                                  )
                                                  ).
              v-view-log = yes.
           end.
        end.
     end.
  end.
end.
         mQuery:get-next ().
      end .
      delete object mQuery.
   end.
   run write-log-and-file in p-log-handle (
                     input 1
                   , input log-file-name
                   , input 1
                   , input substitute( 'Обработка запроса &1 на кассы магазина &2 завершена'
                                         ,'"' + vProcInfo + '"'
                                         ,i-obj-code
                                     )
                                                     ).
   if valid-handle(v-work-handle) then do:
      delete procedure v-work-handle  .
    end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure SENDING:
_cash-desk:
for each ub.cash-desk no-lock where
         ub.cash-desk.db-num = g#db-num and
         ub.cash-desk.obj-code = i-obj-code and
        (ub.cash-desk.cash-on  = yes or mSendAll)
break
by ub.cash-desk.pos-type :
  if first-of(ub.cash-desk.pos-type) then do:
    run for-cash-cycle no-error.
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("&1 &2", error-status:get-message(1), return-value)
                                              ).
      assign
      v-view-log = yes
      .
    end.
  end.
end.
end procedure.
RUN SENDING no-error.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки при отсылке '&3' на кассы &1&2"
                         , i-obj-type, i-obj-code, i-Title
                        )
                                        ).
   v-view-log = yes.
end.
run set-view-log in p-log-handle(v-view-log) no-error.
