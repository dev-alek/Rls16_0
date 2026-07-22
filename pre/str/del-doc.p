block-level on error undo, throw.
define  input parameter parparentproc      as   widget-handle                no-undo.
define  input parameter pardoc-code        like ub.trn-doc.doc-code          no-undo.
define  input parameter pardb-num          like ub.db.db-num                 no-undo.
define  input parameter parfilename        as   character                    no-undo.
define  input parameter parcorr-inkas-code like ub.c-trn-doc.corr-inkas-code no-undo.
define  input parameter parcorr-fbr-code   like ub.c-trn-doc.corr-fbr-code   no-undo.
define  input parameter paruserid          as   character                    no-undo.
define  input parameter parphdoc-code      like ub.trn-doc.doc-code          no-undo.
define  input parameter parphchip-num      as   integer                      no-undo.
define output parameter parchip-num        as   integer                      no-undo.
define variable vss-revision    as character no-undo initial "$Revision: f9f9d1396dd0, 1038, rls $":U.
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U.
define variable vss-date        as character no-undo initial "$Date: Fri Oct 06 18:30:18 2017 +0300 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: del-doc.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: str/del-doc.p $":U.
define variable vss-description as character no-undo initial "Удаление документов + вывод информации о ходе процесса":U.
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define variable v-vid-action as integer  no-undo .
define variable v-vid-param  as longchar no-undo .
define variable v-initiator  as character no-undo.
case true:
  when g#auto then v-initiator = "Auto".
  when g#news then v-initiator = "Nws".
  when g#esys then v-initiator = "Esys".
  otherwise v-initiator = "User".
end case.
define variable varshift-date as date      no-undo.
define variable varshift-num  as integer   no-undo.
define variable varshift-name as character no-undo.
define variable v-mess        as character no-undo.
define variable v-boss        as character no-undo.
define variable v-contr       as character no-undo.
define variable v-status      as character no-undo.
define variable v-flag        as logical   no-undo.
find first ub.trn-doc no-lock where ub.trn-doc.doc-code = pardoc-code no-error.
if ub.trn-doc.status_ = 'факт':U
then do:
  v-vid-action = 59.
  find first ub.clients no-lock where ub.clients.obj-type = 'чел':U and ub.clients.obj-code = ub.trn-doc.boss no-error.
  v-boss = if available (ub.clients) then ub.clients.obj-name else "".
  v-contr = ub.trn-doc.cli-name.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  ub.trn-doc.obj-type
  ,input  ub.trn-doc.obj-code
  ,output varshift-date
  ,output varshift-num
  ,output varshift-name
  ) no-error .
end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_del-doc in g#lib-trn
  (
     input parparentproc
  ,  input pardoc-code
  ,  input pardb-num
  ,  input parfilename
  ,  input parcorr-inkas-code
  ,  input parcorr-fbr-code
  ,  input paruserid
  ,  input parphdoc-code
  ,  input parphchip-num
  , output parchip-num
  ,  input this-procedure
  ) no-error.
  if error-status :error then do:
    if ub.trn-doc.status_ = 'факт':U
    then do:
      v-mess = return-value.
      v-vid-param = "Initiator=" + "User" + chr(4) +
                    "ResponsiblePerson=" + v-boss + chr(4) +
                    "SHOP_NUM=" + string(ub.trn-doc.obj-code) + chr(4) +
                    "Contractor=" + v-contr + chr(4) +
                    "DocNum=" + string(ub.trn-doc.doc-code) + chr(4) +
                    "FactDate=" + (if string(ub.trn-doc.fact-date) = ? then '' else string(ub.trn-doc.fact-date)) + chr(4) +
                    "DocType=" + string(ub.trn-doc.doc-type) + chr(4) +
                    "SHIFT_NUM_DOC=" + (if string(ub.trn-doc.shift-num) = ? then '' else string(ub.trn-doc.shift-num)) + (if string(ub.trn-doc.shift-date) = ? then '' else string(ub.trn-doc.shift-date, "99999999")) + chr(4) +
                    "SHIFT_NUM=" + (if string(varshift-num) = ? then '' else string(varshift-num)) + (if string(varshift-date) = ? then '' else string(varshift-date, "99999999")) + chr(4) +
                    "Status=" + string(ub.trn-doc.status_) + (if ub.trn-doc.flag then "+" else "-" ) + chr(4) +
                    "RESULT=" + string( 1 ) + chr(4) +
                    "Description=" + v-mess no-error.
      run trg/userlog.p (
            input 'delete_err':U
          , input 'trn-doc':U
          , input ( buffer ub.trn-doc :handle )
          , input v-vid-action
          , input v-vid-param
      ) no-error.
    end.
    run waitfram-hide in this-procedure no-error.
    return error substitute( "&1 &2", v-mess, error-status :get-message( 1 ) ).
  end.
  find last ub.c-trn-doc no-lock where ub.c-trn-doc.doc-code = pardoc-code and ub.c-trn-doc.corr-user-db-num = pardb-num no-error.
  if available (ub.c-trn-doc) and ub.c-trn-doc.status_ = 'факт':U
  then do:
    v-vid-param = "Initiator=" + "User" + chr(4) +
                  "ResponsiblePerson=" + v-boss + chr(4) +
                  "SHOP_NUM=" + string(c-trn-doc.obj-code) + chr(4) +
                  "Contractor=" + v-contr + chr(4) +
                  "DocNum=" + string(c-trn-doc.doc-code) + chr(4) +
                  "FactDate=" + (if string(c-trn-doc.fact-date) = ? then '' else string(c-trn-doc.fact-date)) + chr(4) +
                  "DocType=" + string(c-trn-doc.doc-type) + chr(4) +
                  "SHIFT_NUM_DOC=" + (if string(c-trn-doc.shift-num) = ? then '' else string(c-trn-doc.shift-num)) + (if string(c-trn-doc.shift-date) = ? then '' else string(c-trn-doc.shift-date, "99999999")) + chr(4) +
                  "SHIFT_NUM=" + (if string(varshift-num) = ? then '' else string(varshift-num)) + (if string(varshift-date) = ? then '' else string(varshift-date, "99999999")) + chr(4) +
                  "Status=" + string(c-trn-doc.status_) + (if c-trn-doc.flag then "+" else "-" ) + chr(4) +
                  "RESULT=" + string( 0 ) + chr(4) +
                  "Description=" no-error.
    run trg/userlog.p (
          input 'delete':U
        , input 'c-trn-doc':U
        , input ( buffer ub.c-trn-doc :handle )
        , input v-vid-action
        , input v-vid-param
    ) no-error.
  end.
  run waitfram-hide in this-procedure no-error.
