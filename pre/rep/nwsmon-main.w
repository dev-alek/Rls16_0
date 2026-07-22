define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Мониторинг СПН".
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure pck-attr-code :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pck-attr-code in g#attr-lib
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
procedure pck-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pck-attr-tooltip in g#attr-lib
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
procedure pck-attr-value :
  define input  parameter p-tbl-pck   as   character                   no-undo .
  define input  parameter p-db-num    like ub.pck-rcvd-attr.db-num     no-undo .
  define input  parameter p-pack-num  like ub.pck-rcvd-attr.pack-num   no-undo .
  define input  parameter p-code      like ub.pck-rcvd-attr.attr-code  no-undo .
  define output parameter p-value     like ub.pck-rcvd-attr.attr-value no-undo .
  define output parameter p-type      as   character                   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pck-attr-value in g#attr-lib
      ( input  p-tbl-pck
      , input  p-db-num
      , input  p-pack-num
      , input  p-code
      , output p-value
      , output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure pck-attr-write :
  define input parameter p-tbl-pck   as   character                   no-undo .
  define input parameter p-db-num    like ub.pck-rcvd-attr.db-num     no-undo .
  define input parameter p-pack-num  like ub.pck-rcvd-attr.pack-num   no-undo .
  define input parameter p-code      like ub.pck-rcvd-attr.attr-code  no-undo .
  define input parameter p-value     like ub.pck-rcvd-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pck-attr-write in g#attr-lib
      ( input p-tbl-pck
      , input p-db-num
      , input p-pack-num
      , input p-code
      , input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure pck-attr-exist :
  define input  parameter p-tbl-pck  as   character                   no-undo .
  define input  parameter p-db-num   like ub.pck-rcvd-attr.db-num     no-undo .
  define input  parameter p-pack-num like ub.pck-rcvd-attr.pack-num   no-undo .
  define input  parameter p-code     like ub.pck-rcvd-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pck-attr-exist in g#attr-lib
      ( input  p-tbl-pck
      , input  p-db-num
      , input  p-pack-num
      , input  p-code
      , output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure pck-attr-delete :
  define input  parameter p-tbl-pck  as   character                   no-undo .
  define input  parameter p-db-num   like ub.pck-rcvd-attr.db-num     no-undo .
  define input  parameter p-pack-num like ub.pck-rcvd-attr.pack-num   no-undo .
  define input  parameter p-code     like ub.pck-rcvd-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pck-attr-delete in g#attr-lib
      ( input  p-tbl-pck
      , input  p-db-num
      , input  p-pack-num
      , input  p-code
      , output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure pck-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pck-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure pck-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pck-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure pck-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pck-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
def temp-table tt-db-info no-undo
    field db-num as int
    field db-name as char
    field db-date as date
    field last-recv-pck-dt as datetime
    field last-sent-pck-dt as datetime
    field last-recv-pck-dt-str as char
    field last-sent-pck-dt-str as char
    field min-processing-int as int64
    field max-processing-int as int64
    field avg-processing-int as int64
    field min-processing-str as char
    field max-processing-str as char
    field avg-processing-str as char
    field pck-rcvd-count as int64
    field pck-sent-count as int64
    field avg-recs-in-rcvd-pck as int64
    field avg-wait-confirm-int as int64
    field avg-wait-confirm-str as char
    field pck-not-confirm-count as int64
    field avg-recs-in-sent-pck as int64
    index pi as primary unique db-num
    .
def temp-table tt-stat-info
    field db-num as int
    field table-name as char
    field rec-count as int64
    index pi as primary unique db-num table-name
    .
def buffer buf_db for ub.db.
def buffer buf_pck-rcvd for ub.pck-rcvd.
def buffer buf_pck-sent for ub.pck-sent.
def buffer buf_pck-rcvd-attr1 for ub.pck-rcvd-attr.
def buffer buf_pck-rcvd-attr2 for ub.pck-rcvd-attr.
def buffer buf_obj-date for ub.obj-date.
def buffer buf_route for ub.route.
def buffer buf_clients for ub.clients.
def var end-work-dt as int64 no-undo.
def var last-sort-column as char no-undo.
def var last-sort-desc as logical no-undo init false.
def var dt-interval as datetime no-undo.
def var dt-not-conf-interval as datetime no-undo.
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Выход"
     SIZE 7 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_print
     LABEL "Печать"
     SIZE 7 BY 1
     BGCOLOR 8 .
DEFINE BUTTON BUTTON-start
     LABEL "Запуск"
     SIZE 7 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE abs-time-pack AS INTEGER FORMAT ">>>>9":U INITIAL 6
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE avail-time AS INTEGER FORMAT ">>>>9":U INITIAL 6
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE period AS INTEGER FORMAT ">>>>9":U INITIAL 24
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE sel-dbs AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE dbs AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Активные", 1,
"Выборочно", 2
     SIZE 16 BY 1.62 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 36 BY 3.1.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 59 BY 3.1.
DEFINE QUERY BROWSE-dbs FOR
      tt-db-info SCROLLING.
DEFINE QUERY BROWSE-stat FOR
      tt-stat-info SCROLLING.
DEFINE BROWSE BROWSE-dbs
  QUERY BROWSE-dbs NO-LOCK DISPLAY
      tt-db-info.db-num COLUMN-LABEL "№" FORMAT ">>>>9"
        tt-db-info.db-name COLUMN-LABEL "Название БД" FORMAT "X(25)"
        tt-db-info.db-date COLUMN-LABEL "Дата БД" FORMAT "99/99/9999"
        tt-db-info.pck-rcvd-count COLUMN-LABEL "Принято!пакетов" FORMAT ">>>,>>>,>>9"
        tt-db-info.pck-sent-count COLUMN-LABEL "Отправлено!пакетов" FORMAT ">>>,>>>,>>9"
        tt-db-info.last-recv-pck-dt-str COLUMN-LABEL "Время приема!последнего пакета" FORMAT "X(20)"
        tt-db-info.last-sent-pck-dt-str COLUMN-LABEL "Время отправки!последнего пакета" FORMAT "X(20)"
        tt-db-info.min-processing-str COLUMN-LABEL "Миним. время!обработки пакетов" FORMAT "X(32)"
        tt-db-info.max-processing-str COLUMN-LABEL "Макс. время!обработки пакетов" FORMAT "X(32)"
        tt-db-info.avg-processing-str COLUMN-LABEL "Среднее время!обработки пакетов" FORMAT "X(32)"
        tt-db-info.avg-wait-confirm-str COLUMN-LABEL "Среднее время!ожидания подтверждения" FORMAT "X(32)"
        tt-db-info.avg-recs-in-rcvd-pck COLUMN-LABEL "Среднее кол-во записей!в полученном пакете" FORMAT ">>>,>>>,>>9"
        tt-db-info.pck-not-confirm-count COLUMN-LABEL "Кол-во не!подтвержденных пакетов" FORMAT ">>>,>>>,>>9"
        tt-db-info.avg-recs-in-sent-pck COLUMN-LABEL "Среднее кол-во записей!в передаваемом пакете" FORMAT ">>>,>>>,>>9"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 109 BY 13.1
         TITLE "Общая информация по работе СПН".
DEFINE BROWSE BROWSE-stat
  QUERY BROWSE-stat DISPLAY
      tt-stat-info.table-name COLUMN-LABEL "Таблица" FORMAT "X(80)"
        tt-stat-info.rec-count COLUMN-LABEL "Записей" FORMAT ">>>,>>>,>>9"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 109 BY 8.33
         TITLE "Статистика по исходящей информации" FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 2
     Btn_print AT ROW 1 COL 9 WIDGET-ID 2
     BUTTON-start AT ROW 1 COL 17 WIDGET-ID 12
     dbs AT ROW 2.33 COL 7 NO-LABEL WIDGET-ID 6
     sel-dbs AT ROW 2.43 COL 27 NO-LABEL WIDGET-ID 10
     abs-time-pack AT ROW 2.43 COL 84 COLON-ALIGNED NO-LABEL WIDGET-ID 42
     avail-time AT ROW 3.86 COL 84 COLON-ALIGNED NO-LABEL WIDGET-ID 44
     period AT ROW 3.95 COL 25 COLON-ALIGNED NO-LABEL WIDGET-ID 26
     BROWSE-dbs AT ROW 5.29 COL 2 WIDGET-ID 600
     BROWSE-stat AT ROW 18.38 COL 2 WIDGET-ID 700
     "Допустимое время отсутствия пакетов (в часах)" VIEW-AS TEXT
          SIZE 45 BY 1.1 AT ROW 2.43 COL 39 WIDGET-ID 46
     "БД:" VIEW-AS TEXT
          SIZE 4 BY 1.62 AT ROW 2.33 COL 2.4 WIDGET-ID 20
     "Период анализа в часах:" VIEW-AS TEXT
          SIZE 24 BY .81 AT ROW 4.1 COL 2.4 WIDGET-ID 38
     "Допустимое время цикла (в часах):" VIEW-AS TEXT
          SIZE 38 BY 1.1 AT ROW 3.62 COL 39 WIDGET-ID 48
     RECT-1 AT ROW 2.19 COL 2 WIDGET-ID 50
     RECT-2 AT ROW 2.19 COL 38 WIDGET-ID 52
     SPACE(15.19) SKIP(21.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Мониторинг СПН"
         DEFAULT-BUTTON Btn_OK WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       BROWSE-dbs:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1
       BROWSE-dbs:ALLOW-COLUMN-SEARCHING IN FRAME Dialog-Frame = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON ROW-DISPLAY OF BROWSE-dbs IN FRAME Dialog-Frame
DO:
    run highlight-dbs-rows.
END.
ON START-SEARCH OF BROWSE-dbs IN FRAME Dialog-Frame
DO:
    run do-sort.
END.
ON VALUE-CHANGED OF BROWSE-dbs IN FRAME Dialog-Frame
DO:
  run refresh-query(2).
END.
ON CHOOSE OF Btn_print IN FRAME Dialog-Frame
DO:
  message "Печать пока не предусмотрена!" view-as alert-box.
END.
ON CHOOSE OF BUTTON-start IN FRAME Dialog-Frame
DO:
    run fill-tables.
    run refresh-query(1).
    apply "VALUE-CHANGED" to BROWSE-dbs.
END.
ON VALUE-CHANGED OF dbs IN FRAME Dialog-Frame
DO:
  assign frame dialog-frame dbs.
  if dbs = 1 then disable sel-dbs with frame dialog-frame.
  else enable sel-dbs with frame dialog-frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
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
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
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
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
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
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
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
      v-field-group-handle = frame Dialog-Frame :first-child
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
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
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
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
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
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame Dialog-Frame :height)
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
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
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
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
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
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
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
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
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
      v-field-group-handle = frame Dialog-Frame :first-child
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
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
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
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
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
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame Dialog-Frame
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
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
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
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
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
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
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
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BROWSE-dbs :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
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
run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse BROWSE-stat :handle
  ) .
run diasize_init in this-procedure .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
procedure do-sort:
    def var h-col as handle no-undo.
    def var h-query as handle no-undo.
    def var qstr as char no-undo.
    do with frame dialog-frame:
        h-col = BROWSE-dbs:CURRENT-COLUMN.
        h-query = BROWSE-dbs:QUERY.
        qstr = "FOR EACH tt-db-info BY " + h-col:NAME.
        if last-sort-column = h-col:NAME then do:
            if last-sort-desc then
                qstr = qstr + " DESC".
            last-sort-desc = not last-sort-desc.
        end.
        else
            last-sort-desc = true.
        h-query:QUERY-CLOSE().
        h-query:QUERY-PREPARE(qstr).
        h-query:QUERY-OPEN().
        last-sort-column = h-col:NAME.
    end.
end.
function ticks-to-str returns char (ticks as int64):
    def var v-hour as int no-undo init 0 format ">9".
    def var v-min as int no-undo init 0 format "99".
    def var v-sec as int no-undo init 0 format "99".
    def var str as char no-undo init "".
    def var tmp as int64 no-undo format ">>9".
    tmp = ticks.
    def var hour-ticks as int no-undo.
    hour-ticks = 1000 * 60 * 60.
    def var min-ticks as int no-undo.
    min-ticks = 1000 * 60.
    if tmp >= hour-ticks then do:
        v-hour = tmp / hour-ticks.
        tmp = tmp mod hour-ticks.
    end.
    if tmp >= min-ticks then do:
        v-min = tmp / min-ticks.
        tmp = tmp mod min-ticks.
    end.
    if tmp >= 1000 then do:
        v-sec = tmp / 1000.
        tmp = tmp mod 1000.
    end.
    if tmp = ? then tmp = 0.
    return substitute("&1 ч. &2 мин. &3 сек. &4 мс.", v-hour, v-min, v-sec, tmp).
end.
procedure check-before-start:
    def var er-text as char no-undo init "".
    def var i as int no-undo.
    def var num as int no-undo.
    assign frame dialog-frame sel-dbs dbs.
    if dbs = 2 then do:
        num = num-entries(sel-dbs).
        if num < 1 then er-text = er-text + chr(10) + "Не указан ни один номер БД".
        else do:
            do i = 1 to num:
                integer(entry(i, sel-dbs)) no-error.
                if error-status:ERROR then er-text = er-text + chr(10) + "Номер БД на позиции " + string(i) + " не является числом".
            end.
        end.
    end.
    return er-text.
end.
function prev-send-pck returns logical(fflag as logical):
    if fflag then do:
        find last buf_pck-sent no-lock
            where buf_pck-sent.db-num = buf_db.db-num
            no-error.
        return avail buf_pck-sent.
    end.
    find prev buf_pck-sent no-lock
        where buf_pck-sent.db-num = buf_db.db-num
        no-error.
    return avail buf_pck-sent.
end.
function prev-rcvd-pck returns logical(fflag as logical):
    if fflag then do:
        find last buf_pck-rcvd no-lock
            where buf_pck-rcvd.db-num = buf_db.db-num
            no-error.
        return avail buf_pck-rcvd.
    end.
    find prev buf_pck-rcvd no-lock
        where buf_pck-rcvd.db-num = buf_db.db-num
        no-error.
    return avail buf_pck-rcvd.
end.
procedure fill-tables:
    def var ind as int no-undo.
    run check-before-start no-error.
    if return-value <> "" then do:
        message return-value + chr(10) + chr(10) + "Продолжение не возможно!" view-as alert-box.
        return.
    end.
    empty temp-table tt-db-info.
    empty temp-table tt-stat-info.
    assign frame dialog-frame period abs-time-pack avail-time.
    end-work-dt = avail-time * 60 * 60 * 1000.
    dt-interval = add-interval(now, -(period), "hours").
    dt-not-conf-interval = add-interval(now, -(abs-time-pack), "hours").
    if dbs = 1 then
        for each buf_db where buf_db.db-key <> "":
            run fill-record.
        end.
    else do:
        for each buf_db:
            ind = lookup(string(buf_db.db-num), sel-dbs).
            if ind > 0 then
                run fill-record.
        end.
    end.
    run waitfram-hide.
end.
procedure fill-record:
    def var i as int no-undo.
    def var num as int no-undo.
    def var flag as logical no-undo.
    def var beg-imp-dt as datetime no-undo.
    def var end-imp-dt as datetime no-undo.
    def var processing-int as int64 no-undo.
    def var first-flag as logical no-undo init true.
    def var cre-dt as datetime no-undo.
    def var sent-txt-dt as datetime no-undo.
    def var rcvd-dt as datetime no-undo.
    def var wait-confirm-int as int64 no-undo.
    def var atr-type as char no-undo.
    def var atr-val1 as char no-undo.
    def var atr-val2 as char no-undo.
    run waitfram-show("Анализ БД " + string(buf_db.db-num)).
    create tt-db-info.
    assign
        tt-db-info.db-num = buf_db.db-num
        tt-db-info.db-name = buf_db.db-name
        .
    for each buf_clients use-index db-num
        where buf_clients.db-num = buf_db.db-num no-lock:
            find last buf_obj-date no-lock use-index pi
                where buf_obj-date.obj-code = buf_clients.obj-code
                and buf_obj-date.obj-type = buf_clients.obj-type
                no-error.
            if avail buf_obj-date then do:
                if tt-db-info.db-date < buf_obj-date.sys-date or tt-db-info.db-date = ? then
                    tt-db-info.db-date = buf_obj-date.sys-date.
            end.
    end.
    first-flag = true.
    tt-db-info.pck-rcvd-count = 0.
    tt-db-info.min-processing-int = ?.
    do while prev-rcvd-pck(first-flag):
        first-flag = false.
        if buf_pck-rcvd.BegImpDate = ? or buf_pck-rcvd.BegImpTime = ? then next.
        beg-imp-dt = datetime(string(buf_pck-rcvd.BegImpDate) + " " + buf_pck-rcvd.BegImpTime) no-error.
        if error-status:ERROR then next.
        if tt-db-info.last-recv-pck-dt = ?
            or tt-db-info.last-recv-pck-dt < beg-imp-dt
                then
                    tt-db-info.last-recv-pck-dt = beg-imp-dt.
        if buf_pck-rcvd.EndImpDate = ? or buf_pck-rcvd.EndImpTime = ? then next.
        end-imp-dt = datetime(string(buf_pck-rcvd.EndImpDate) + " " + buf_pck-rcvd.EndImpTime) no-error.
        if error-status:ERROR then next.
        if beg-imp-dt < dt-interval then leave.
        processing-int = end-imp-dt - beg-imp-dt.
        if tt-db-info.min-processing-int = ?
            or tt-db-info.min-processing-int > processing-int
                then
                    tt-db-info.min-processing-int = processing-int.
        if tt-db-info.max-processing-int = ?
            or tt-db-info.max-processing-int < processing-int
                then
                    tt-db-info.max-processing-int = processing-int.
        tt-db-info.avg-processing-int = tt-db-info.avg-processing-int + processing-int.
        tt-db-info.avg-recs-in-rcvd-pck = tt-db-info.avg-recs-in-rcvd-pck + buf_pck-rcvd.total-recs.
        tt-db-info.pck-rcvd-count = tt-db-info.pck-rcvd-count + 1.
    end.
    tt-db-info.min-processing-str = ticks-to-str(tt-db-info.min-processing-int).
    tt-db-info.max-processing-str = ticks-to-str(tt-db-info.max-processing-int).
    tt-db-info.avg-processing-int = tt-db-info.avg-processing-int / tt-db-info.pck-rcvd-count.
    tt-db-info.avg-processing-str = ticks-to-str(tt-db-info.avg-processing-int).
    tt-db-info.avg-recs-in-rcvd-pck = tt-db-info.avg-recs-in-rcvd-pck / tt-db-info.pck-rcvd-count.
    if tt-db-info.avg-recs-in-rcvd-pck = ? then tt-db-info.avg-recs-in-rcvd-pck = 0.
    if tt-db-info.last-recv-pck-dt = ? then
        tt-db-info.last-recv-pck-dt-str = "-".
    else
        tt-db-info.last-recv-pck-dt-str = string(tt-db-info.last-recv-pck-dt, "99/99/9999 HH:MM:SS").
    first-flag = true.
    tt-db-info.avg-recs-in-sent-pck = 0.
    do while prev-send-pck(first-flag):
        first-flag = false.
        if buf_pck-sent.SendTxtDate = ? or buf_pck-sent.SendTxtTime = ? then next.
        sent-txt-dt = datetime(string(buf_pck-sent.SendTxtDate) + " " + buf_pck-sent.SendTxtTime) no-error.
        if error-status:ERROR then next.
        if tt-db-info.last-sent-pck-dt = ?
            or tt-db-info.last-sent-pck-dt < sent-txt-dt
                then
                    tt-db-info.last-sent-pck-dt = sent-txt-dt.
        if buf_pck-sent.CreDate = ? or buf_pck-sent.CreTime = ? then next.
        cre-dt = datetime(string(buf_pck-sent.CreDate) + " " + buf_pck-sent.CreTime) no-error.
        if error-status:ERROR then next.
        if buf_pck-sent.RcvdDate = ? or buf_pck-sent.RcvdTime = ? then next.
        if cre-dt < dt-interval then leave.
        rcvd-dt = datetime(string(buf_pck-sent.RcvdDate) + " " + buf_pck-sent.RcvdTime) no-error.
        if error-status:ERROR then next.
        wait-confirm-int = rcvd-dt - cre-dt.
        tt-db-info.avg-wait-confirm-int = tt-db-info.avg-wait-confirm-int + wait-confirm-int.
        if not buf_pck-sent.rcvd then
            tt-db-info.pck-not-confirm-count = tt-db-info.pck-not-confirm-count + 1.
        tt-db-info.avg-recs-in-sent-pck = tt-db-info.avg-recs-in-sent-pck + buf_pck-sent.total-recs.
        run fill-route-stat(buf_pck-sent.pack-num).
        tt-db-info.pck-sent-count = tt-db-info.pck-sent-count + 1.
    end.
    run fill-route-stat(-1).
    tt-db-info.avg-wait-confirm-int = tt-db-info.avg-wait-confirm-int / tt-db-info.pck-sent-count.
    tt-db-info.avg-wait-confirm-str = ticks-to-str(tt-db-info.avg-wait-confirm-int).
    tt-db-info.avg-recs-in-sent-pck = tt-db-info.avg-recs-in-sent-pck / tt-db-info.pck-sent-count.
    if tt-db-info.avg-recs-in-sent-pck = ? then tt-db-info.avg-recs-in-sent-pck = 0.
    if tt-db-info.last-sent-pck-dt = ? then
        tt-db-info.last-sent-pck-dt-str = "-".
    else
        tt-db-info.last-sent-pck-dt-str = string(tt-db-info.last-sent-pck-dt, "99/99/9999 HH:MM:SS").
end.
procedure fill-route-stat:
    def input param p-last-pck-num as int.
    def var route-dt as datetime no-undo.
    for each buf_route no-lock
        where buf_route.db-num = buf_db.db-num
        and buf_route.last-pack = p-last-pck-num:
            route-dt = datetime(string(buf_route.CreDate) + " " + buf_route.CreTime) no-error.
            if error-status:ERROR then next.
            find first tt-stat-info no-lock
                where tt-stat-info.table-name = buf_route.name-rec
                and tt-stat-info.db-num = buf_db.db-num
                no-error.
            if not avail tt-stat-info then do:
                create tt-stat-info.
                assign
                    tt-stat-info.db-num = buf_db.db-num
                    tt-stat-info.table-name = buf_route.name-rec
                    .
            end.
            tt-stat-info.rec-count = tt-stat-info.rec-count + 1.
    end.
end.
procedure highlight-dbs-rows:
    do with frame dialog-frame:
        if tt-db-info.last-recv-pck-dt < dt-not-conf-interval then
            tt-db-info.last-recv-pck-dt-str:FGCOLOR in browse BROWSE-dbs = 12.
        if tt-db-info.avg-wait-confirm-int > end-work-dt then
            tt-db-info.avg-wait-confirm-str:FGCOLOR in browse BROWSE-dbs = 12.
    end.
end.
procedure refresh-query:
    def input param p-query-num as int.
    do with frame frame-dbs:
        if p-query-num = 1 then
            OPEN QUERY BROWSE-dbs for each tt-db-info.
        if p-query-num = 2 then
            OPEN QUERY BROWSE-stat for each tt-stat-info
                where tt-stat-info.db-num = tt-db-info.db-num.
    end.
end.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY dbs abs-time-pack avail-time period
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 RECT-2 Btn_OK Btn_print BUTTON-start dbs abs-time-pack
         avail-time period BROWSE-dbs BROWSE-stat
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-dbs FOR EACH tt-db-info NO-LOCK INDEXED-REPOSITION.    OPEN QUERY BROWSE-stat FOR EACH tt-stat-info.
END PROCEDURE.
