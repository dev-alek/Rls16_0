define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-host-code    as integer   no-undo .
define input  parameter p-doc-type     as character no-undo .
define input  parameter p-doc          as character no-undo .
define input  parameter p-doc-num      as character no-undo .
def var vss-revision    as character no-undo init "$Revision$":u .
def var vss-author      as character no-undo init "$Author$":u .
def var vss-date        as character no-undo init "$Date$":u .
def var vss-workfile    as character no-undo init "$Workfile$":u .
def var vss-archive     as character no-undo init "$Archive$":u .
def var vss-description as character no-undo init "Связи фин. обязательств и платежей" .
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
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fltfield-clear :
  define output parameter loc-fld as character no-undo.
  define output parameter loc-lab as character no-undo .
  define output parameter loc-spr as character no-undo .
  define output parameter loc-dim as character no-undo .
  assign
    loc-fld = ""
    loc-lab = ""
    loc-spr = ""
    loc-dim = "0"
  .
end procedure .
procedure fltfield-add :
  define input        parameter par-fld as character no-undo.
  define input        parameter par-lab as character no-undo .
  define input        parameter par-spr as character no-undo .
  define input-output parameter loc-fld as character no-undo.
  define input-output parameter loc-lab as character no-undo .
  define input-output parameter loc-spr as character no-undo .
  define input-output parameter loc-dim as character no-undo .
  do
  on error undo, return error
  :
    assign
    loc-fld = if loc-dim = '0'
              then par-fld
              else (loc-fld + chr(44) + par-fld)
    loc-lab = if loc-dim = '0'
              then par-lab
              else (loc-lab + chr(44) + par-lab)
    loc-spr = if loc-dim = '0'
              then par-spr
              else (loc-spr + chr(44) + par-spr)
    loc-dim = (if num-entries(loc-dim) > 1 then (entry(1, loc-dim) + chr(44)) else "") +
              string(integer(if num-entries(loc-dim) > 1
                            then entry(2, loc-dim)
                            else entry(1, loc-dim)
                            ) + 1)
    no-error
    .
  end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
define variable v-fltopend-rowid as rowid extent 18 no-undo .
procedure fltopend_fltopend :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
  do
  on error undo, return error
  :
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
assign
v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                   p-where-cond + chr(32)  +
                   p-use-indFIRST-query-tail + chr(32) +
                   p-use-ind-sort-clmn-by + chr(32) +
                   p-indexed-reposition
.
assign
glog = p-qh:query-prepare(v-prepare-string) no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
assign
glog = p-qh:query-open no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
  end.
end procedure.
procedure fltopend_fltfindd :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-index-phrase as character no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-recid as recid no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  glog = p-bh:find-by-rowid( p-rowid, p-lock) no-error.
  create buffer v-bh for table p-bh buffer-name p-bh:name.
  create query v-qh.
  v-qh:set-buffers(v-bh).
  v-prepare-string = substitute("for each &1 &2 &3"
                                  ,v-bh:name
                                  ,p-where-cond
                                  ,p-use-index-phrase).
  glog = v-qh:query-prepare(v-prepare-string) no-error.
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  if p-next then do:
    v-qh:reposition-to-rowid(p-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  v-recid = v-bh:recid no-error .
  delete object v-qh.
  delete object v-bh.
  return string(v-recid) .
end.
end procedure.
procedure fltopend_fltfindq :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
define output parameter p-fltopend-rowid as rowid extent 18 no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo extent 18.
define variable v-rowid as rowid no-undo extent 18.
define variable v-ii as integer no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  create query v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    create buffer v-bh[v-ii] for table p-qh:get-buffer-handle(v-ii) buffer-name p-qh:get-buffer-handle(v-ii):name .
    assign
    v-rowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid
    no-error.
    v-qh:add-buffer(v-bh[v-ii]).
  end.
  assign
  v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                    p-where-cond + chr(32)  +
                    p-use-indFIRST-query-tail + chr(32) +
                    p-use-ind-sort-clmn-by + chr(32) +
                    p-indexed-reposition
  .
  glog = v-qh:query-prepare( v-prepare-string) no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  if p-next then do:
    glog = v-qh:reposition-to-rowid(v-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  do v-ii = 1 to p-qh:num-buffers:
    assign
    p-fltopend-rowid[v-ii] = v-bh[v-ii]:rowid
    no-error.
  end.
  delete object v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    delete object v-bh[v-ii].
  end.
end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  p-user-id
  ,output v-user-name
  ) no-error .
if error-status:error
or v-user-name = ""
then do:
  return p-user-id.
end.
else do:
  return v-user-name.
end.
end function.
  define buffer buf_fin-connect  for ub.fin-connect .
  define buffer buf_fin-ob       for ub.fin-ob .
  define buffer buf_fin-doc      for ub.fin-doc .
  define buffer buf_contract     for ub.contract .
  define variable cont-list        as character no-undo .
  define variable g-log            as logical   no-undo .
  define variable v-doc-rec        as recid no-undo .
  define variable sort-column-name as character no-undo .
  define variable filter-point as character no-undo init "Связи фин. обязательств и платежей" .
  define variable filter-point0 as character no-undo init "Связи фин. обязательств и платежей" .
  define variable num as integer initial 0 no-undo .
  DEFINE temp-table temp-conn no-undo
    field   ri             as  recid
    INDEX pi  IS PRIMARY   ri
  .
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid )  FORWARD.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 10 BY 1.
DEFINE BUTTON B-view-doc
     LABEL "&Платеж"
     SIZE 10 BY 1.
DEFINE BUTTON B-view-fo
     LABEL "Фин.о&бяз."
     SIZE 10 BY 1.
DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 7 BY 1 NO-UNDO.
DEFINE VARIABLE sch-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0
     LABEL "Вн. &номер"
     VIEW-AS FILL-IN
     SIZE 8.88 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sch-date AS DATE FORMAT "99/99/99"
     LABEL "&Дата связи"
     VIEW-AS FILL-IN
     SIZE 9.13 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sch-user AS CHARACTER FORMAT "X(14)"
     LABEL "&Польз."
     VIEW-AS FILL-IN
     SIZE 8.88 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE RADIO-find-doc AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Фин.обяз.", 1,
"Платеж", 2
     SIZE 23.25 BY 1 NO-UNDO.
DEFINE VARIABLE Sel-Contr AS CHARACTER INITIAL "all"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", "all",
"Выбор", "sel"
     SIZE 14 BY 1 NO-UNDO.
DEFINE QUERY Conn-List FOR buf_fin-connect, buf_fin-ob, buf_fin-doc, buf_contract SCROLLING.
DEFINE BROWSE Conn-List
  QUERY Conn-List DISPLAY
      mark-string(recid(buf_fin-connect))    COLUMN-LABEL '*'  FORMAT "x(1)"
     buf_fin-connect.fact-date    COLUMN-LABEL 'Дата'  Format "99/99/99"
     string(buf_fin-connect.fact-time,'HH:MM')    COLUMN-LABEL 'Время'  Format "x(5)"
     usrfulnf(buf_fin-connect.user-name)    COLUMN-LABEL 'Связал'  Format "x(8)"
     buf_fin-ob.prn-doc-code    COLUMN-LABEL '№ фин.об.'  format "x(12)"
     buf_fin-ob.pay-date    COLUMN-LABEL 'Дата ф.об.'  format "99/99/99"
     buf_fin-connect.fin-ob-code   COLUMN-LABEL 'вн.н. ф.об.'
     buf_fin-doc.prn-doc-code    COLUMN-LABEL '№ платежа'  Format "x(8)"
     buf_fin-doc.doc-date    COLUMN-LABEL 'Дата плат.'  Format "99/99/99"
     buf_fin-connect.fin-doc-code   COLUMN-LABEL 'вн.н. пл.'
     buf_fin-connect.sum-contr   COLUMN-LABEL 'Сумма в вал.дог.' Format "->,>>>,>>>,>>9.99"
     buf_fin-connect.sum-rubl    COLUMN-LABEL 'Сумма в рубл.'  Format "->,>>>,>>>,>>9.99"
     buf_fin-connect.sum-base    COLUMN-LABEL 'Сумма в Б.вал.'  format "->,>>>,>>>,>>9.99"
     buf_contract.contract-prn-code   COLUMN-LABEL 'Договор' Format "x(14)"
     buf_contract.contract-date   COLUMN-LABEL 'Дата дог.' Format "99/99/99"
     buf_fin-connect.connect-code   COLUMN-LABEL 'Вн.N'
     (if buf_fin-ob.obj-code = 0 then '' else (buf_fin-ob.obj-type + ' ' + string(buf_fin-ob.obj-code)))   COLUMN-LABEL 'Объект' Format "x(14)"
     enable buf_fin-connect.fact-date
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.13 BY 20.17.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-del AT ROW 1 COL 21
     b-sch AT ROW 1 COL 31
     B-view-fo AT ROW 1 COL 41
     B-view-doc AT ROW 1 COL 51
     Sel-Contr AT ROW 1 COL 72.38 NO-LABEL
     B-Help AT ROW 1 COL 88
     Conn-List AT ROW 2.08 COL 1.25
     sch-date AT ROW 22.42 COL 18.75 COLON-ALIGNED
     sch-user AT ROW 22.42 COL 36.25 COLON-ALIGNED
     sch-code AT ROW 22.42 COL 63.63 COLON-ALIGNED
     RADIO-find-doc AT ROW 22.42 COL 74.75 NO-LABEL
     mark-num AT ROW 1 COL 14 NO-LABEL
     "Договоры:" VIEW-AS TEXT
          SIZE 9.5 BY 1 AT ROW 1 COL 62.5
          FGCOLOR 4
     "Поиск:" VIEW-AS TEXT
          SIZE 6.63 BY 1 AT ROW 22.42 COL 1.25
          FGCOLOR 4
     SPACE(90.61) SKIP(0.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Связи фин. обязательств и платежей"
         DEFAULT-BUTTON b-quit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
  define variable is-con as logical   no-undo .
  if num < 1 then do:
    if available buf_fin-connect then do:
      message "Вы действительно хотите удалить выбранную связь?"  view-as alert-box QUESTION BUTTONS YES-NO UPDATE is-con .
      if is-con = no then return no-apply.
      do transaction :
        find first ub.fin-connect exclusive-lock where recid(ub.fin-connect) = recid(buf_fin-connect) .
        find first ub.fin-ob      exclusive-lock where ub.fin-ob.host-code = ub.fin-connect.host-code and ub.fin-ob.doc-code = ub.fin-connect.fin-ob-code .
        assign
          ub.fin-ob.con-sum-rubl  = ub.fin-ob.con-sum-rubl  - ub.fin-connect.sum-rubl
          ub.fin-ob.con-sum-base  = ub.fin-ob.con-sum-base  - ub.fin-connect.sum-base
          ub.fin-ob.con-sum-doc   = ub.fin-ob.con-sum-doc   - ub.fin-connect.sum-doc
          ub.fin-ob.con-sum-contr = ub.fin-ob.con-sum-contr - ub.fin-connect.sum-contr
        .
        if ub.fin-ob.con-sum-contr = 0 then assign ub.fin-ob.con-stat = 0 .
        else                             assign ub.fin-ob.con-stat = 1 .
        find first ub.fin-doc      exclusive-lock where ub.fin-doc.host-code = ub.fin-connect.host-code and ub.fin-doc.fin-doc-code = ub.fin-connect.fin-doc-code .
        if   ub.fin-doc.fin-doc-type = 'рпп':U
          or ub.fin-doc.fin-doc-type = 'рко':U
          or ub.fin-doc.fin-doc-type = 'апр':U then do:
          assign
            ub.fin-doc.con-sum-rubl  = ub.fin-doc.con-sum-rubl  - ub.fin-connect.sum-rubl
            ub.fin-doc.con-sum-base  = ub.fin-doc.con-sum-base  - ub.fin-connect.sum-base
            ub.fin-doc.con-sum-doc   = ub.fin-doc.con-sum-doc   - ub.fin-connect.sum-doc
            ub.fin-doc.con-sum-contr = ub.fin-doc.con-sum-contr - ub.fin-connect.sum-contr
          .
        end.
        else do:
          assign
            ub.fin-doc.con-sum-rubl  = ub.fin-doc.con-sum-rubl  + ub.fin-connect.sum-rubl
            ub.fin-doc.con-sum-base  = ub.fin-doc.con-sum-base  + ub.fin-connect.sum-base
            ub.fin-doc.con-sum-doc   = ub.fin-doc.con-sum-doc   + ub.fin-connect.sum-doc
            ub.fin-doc.con-sum-contr = ub.fin-doc.con-sum-contr + ub.fin-connect.sum-contr
          .
        end.
        if ub.fin-doc.con-sum-contr = 0 then assign ub.fin-doc.con-stat = 0 .
        else                              assign ub.fin-doc.con-stat = 1 .
        delete ub.fin-connect .
      end.
    end.
    else do:
      message  "Нет выбранных связей!"  view-as alert-box.
      return no-apply.
    end.
  end.
  else do:
    message "Вы действительно хотите удалить выбранные связи?"  view-as alert-box QUESTION BUTTONS YES-NO UPDATE is-con .
    if is-con = no then return no-apply.
    do transaction :
      for each temp-conn :
        find first ub.fin-connect exclusive-lock where recid(ub.fin-connect) = temp-conn.ri .
        find first ub.fin-ob      exclusive-lock where ub.fin-ob.host-code = ub.fin-connect.host-code and ub.fin-ob.doc-code = ub.fin-connect.fin-ob-code .
        assign
          ub.fin-ob.con-sum-rubl  = ub.fin-ob.con-sum-rubl  - ub.fin-connect.sum-rubl
          ub.fin-ob.con-sum-base  = ub.fin-ob.con-sum-base  - ub.fin-connect.sum-base
          ub.fin-ob.con-sum-doc   = ub.fin-ob.con-sum-doc   - ub.fin-connect.sum-doc
          ub.fin-ob.con-sum-contr = ub.fin-ob.con-sum-contr - ub.fin-connect.sum-contr
        .
        if ub.fin-ob.con-sum-contr = 0 then assign ub.fin-ob.con-stat = 0 .
        else                             assign ub.fin-ob.con-stat = 1 .
        find first ub.fin-doc      exclusive-lock where ub.fin-doc.host-code = ub.fin-connect.host-code and ub.fin-doc.fin-doc-code = ub.fin-connect.fin-doc-code .
        if   ub.fin-doc.fin-doc-type = 'рпп':U
          or ub.fin-doc.fin-doc-type = 'рко':U
          or ub.fin-doc.fin-doc-type = 'апр':U then do:
          assign
            ub.fin-doc.con-sum-rubl  = ub.fin-doc.con-sum-rubl  - ub.fin-connect.sum-rubl
            ub.fin-doc.con-sum-base  = ub.fin-doc.con-sum-base  - ub.fin-connect.sum-base
            ub.fin-doc.con-sum-doc   = ub.fin-doc.con-sum-doc   - ub.fin-connect.sum-doc
            ub.fin-doc.con-sum-contr = ub.fin-doc.con-sum-contr - ub.fin-connect.sum-contr
          .
        end.
        else do:
          assign
            ub.fin-doc.con-sum-rubl  = ub.fin-doc.con-sum-rubl  + ub.fin-connect.sum-rubl
            ub.fin-doc.con-sum-base  = ub.fin-doc.con-sum-base  + ub.fin-connect.sum-base
            ub.fin-doc.con-sum-doc   = ub.fin-doc.con-sum-doc   + ub.fin-connect.sum-doc
            ub.fin-doc.con-sum-contr = ub.fin-doc.con-sum-contr + ub.fin-connect.sum-contr
          .
        end.
        if ub.fin-doc.con-sum-contr = 0 then assign ub.fin-doc.con-stat = 0 .
        else                              assign ub.fin-doc.con-stat = 1 .
        delete ub.fin-connect .
        assign num = num - 1 .
        delete temp-conn .
      end.
    end.
  end.
  if num = 0 then hide mark-num in frame Dialog-Frame.
  else                   display num @ mark-num  with frame Dialog-Frame.
  RUN OpenBr(yes, no, '':U).
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
  if available buf_fin-connect then do:
    find first temp-conn where temp-conn.ri = recid( buf_fin-connect ) no-error  .
    if available temp-conn then do:
      delete temp-conn .
      assign num = num - 1 .
    end.
    else do:
      create temp-conn .
      assign
        temp-conn.ri = recid( buf_fin-connect )
        num = num + 1
      .
    end.
    g-log = Conn-List:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then  do:
      g-log = Conn-List:select-next-row ().
      apply "value-changed" to Conn-List in frame Dialog-Frame.
    end.
    if num = 0 then hide mark-num in frame Dialog-Frame.
    else                   display num @ mark-num  with frame Dialog-Frame.
  end.
  apply "entry" to Conn-List .
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
END.
ON CHOOSE OF b-sch IN FRAME Dialog-Frame
DO:
  assign
    tbl = 'fin-connect'
    join-tbl = 'buf_fin-connect'
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
  .
  run fltfield-add in this-procedure('host-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-date', 'Дата', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-time', 'Время', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('connect-code', 'Вн.Номер', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fin-ob-code', 'Вн.номер фин.об.', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fin-doc-code', 'Вн.номер платежа', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-code', 'Номер', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('status_', 'Статус', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('user-db-num', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('user-name', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('curr-code', 'Валюта док-та', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-curr', 'Валюта договора', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sum-rubl', 'Сумма в рубл.', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sum-base', 'Сумма в Б.вал.', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sum-doc', 'Сумма в вал. док-та', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sum-contr', 'Сумма в вал. договора', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('PS', 'Примечания', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  RUN OpenBr(yes, no, '':U).
END.
END.
ON CHOOSE OF B-view-doc IN FRAME Dialog-Frame
DO:
  if not available buf_fin-ob then return.
  run ref/showfind.p (
                       input parParentProc
                      ,input p-host-code
                      ,input buf_fin-doc.host-code
                      ,input buf_fin-doc.fin-doc-code
                      ).
END.
ON CHOOSE OF B-view-fo IN FRAME Dialog-Frame
DO:
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-liability_lookup':U
    ,input  'firm':U
    ,input  p-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
  if not g-log then  return .
  define variable rr as recid no-undo .
  if not available buf_fin-ob then return.
  run str/sh-finob.p ( input parParentProc, input p-host-code, input recid(buf_fin-ob)).
END.
ON RETURN OF Conn-List IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF Conn-List IN FRAME Dialog-Frame
DO:
    if b-mark:sensitive then apply "choose" to b-mark in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF RADIO-find-doc IN FRAME Dialog-Frame
DO:
  assign RADIO-find-doc .
  if sch-code <> ? and  sch-code <> 0 then apply "return" to sch-code in frame Dialog-Frame.
END.
ON CTRL-J OF sch-code IN FRAME Dialog-Frame
DO:
  run proc-find-code  in this-procedure(yes, input frame Dialog-Frame sch-code ) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-code IN FRAME Dialog-Frame
DO:
  run proc-find-code  in this-procedure(no, input frame Dialog-Frame sch-code ) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-date IN FRAME Dialog-Frame
DO:
  run proc-find-date in this-procedure(yes, input frame Dialog-Frame sch-date) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-date IN FRAME Dialog-Frame
DO:
  run proc-find-date in this-procedure(no, input frame Dialog-Frame sch-date) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-user IN FRAME Dialog-Frame
DO:
  run proc-find-user  in this-procedure(yes, input frame Dialog-Frame sch-user ) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-user IN FRAME Dialog-Frame
DO:
  run proc-find-user  in this-procedure(no, input frame Dialog-Frame sch-user ) no-error.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF Sel-Contr IN FRAME Dialog-Frame
DO:
  assign Sel-Contr .
  if Sel-Contr = "sel" then do:
    run str/cont-all.w ( parParentProc, p-host-code, "b-sel", 'фирма':U, ?, ?, ?, ?, "current":U, p-doc-type, input-output cont-list ) .
    if cont-list = "" then do:
      assign Sel-Contr = "all" .
      disp Sel-Contr with frame Dialog-Frame.
    end.
  end .
  RUN OpenBr(yes, no, '':U) .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
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
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse Conn-List :handle
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
    run diasize_init in this-procedure .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  Conn-List :SET-REPOSITIONED-ROW(15, "CONDITIONAL") .
end.
def var sort-labelConn-List   as character no-undo .
def var sort-clmnConn-List    as handle    no-undo .
def var cur-clmnConn-List     as handle    no-undo .
def var cur-clmn-locConn-List as integer   no-undo .
def var re-queryConn-List     as logical   initial no no-undo .
on start-search, ctrl-o of Conn-List in frame Dialog-Frame do:
   run sort-brConn-List
     (input (if available buf_fin-connect
             then recid(buf_fin-connect)
             else ?
            )
     ).
end.
PROCEDURE sort-brConn-List :
  define input parameter p-recid as recid no-undo .
  if re-queryConn-List = no then do:
    assign
       cur-clmnConn-List = Conn-List:current-column in frame Dialog-Frame
    .
    if sort-clmnConn-List <> ? then sort-clmnConn-List:column-fgcolor = 0.
    if cur-clmnConn-List = sort-clmnConn-List then do:
      assign
         sort-labelConn-List = ""
         sort-clmnConn-List = ?
      .
     end.
     else do:
       assign
         sort-labelConn-List = cur-clmnConn-List:label
         sort-clmnConn-List  = cur-clmnConn-List
         sort-clmnConn-List:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locConn-List = 1
  .
  def var column-handle as handle no-undo .
  column-handle = Conn-List:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnConn-List then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locConn-List = cur-clmn-locConn-List + 1
    .
  end.
  case sort-labelConn-List:
        when 'Дата'  then DO:    assign       sort-column-name = "buf_fin-connect.fact-date"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Время'  then DO:    assign       sort-column-name = "string(buf_fin-connect.fact-time,'HH:MM')"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Связал'  then DO:    assign       sort-column-name = "usrfulnf(buf_fin-connect.user-name)"     .     run OpenBr(yes, no, '':U).   . END.
        when '№ фин.об.'  then DO:    assign       sort-column-name = "buf_fin-ob.prn-doc-code"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Дата ф.об.'  then DO:    assign       sort-column-name = "buf_fin-ob.pay-date"     .     run OpenBr(yes, no, '':U).   . END.
        when '№ платежа'  then DO:    assign       sort-column-name = "buf_fin-doc.prn-doc-code"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Дата плат.'  then DO:    assign       sort-column-name = "buf_fin-doc.doc-date"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Сумма в рубл.'  then DO:    assign       sort-column-name = "buf_fin-connect.sum-rubl"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Сумма в Б.вал.'  then DO:    assign       sort-column-name = "buf_fin-connect.sum-base"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Договор'  then DO:    assign       sort-column-name = "buf_contract.contract-prn-code"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Дата дог.'  then DO:    assign       sort-column-name = "buf_contract.contract-date"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Вн.N'  then DO:    assign       sort-column-name = "buf_fin-connect.connect-code"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Объект'  then DO:    assign       sort-column-name = "(if buf_fin-ob.obj-code = 0 then '' else (buf_fin-ob.obj-type + ' ' + string(buf_fin-ob.obj-code)))"     .     run OpenBr(yes, no, '':U).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr(yes, no, '':U).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultConn-List') then do:
          run mv-brw-defaultConn-List.
        end.
      if sort-labelConn-List <> "" then do:
        assign
          cur-clmnConn-List:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locConn-List = ?
      .
    end.
  end case.
    if cur-clmn-locConn-List <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnConn-List') then do:
        run ch-clmnConn-List in this-procedure (cur-clmn-locConn-List).
      end.
    end.
  if p-recid <> ? then do:
    reposition Conn-List to recid p-recid no-error.
    apply "value-changed" to Conn-List in frame Dialog-Frame.
  end.
  apply "entry" to Conn-List in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnConn-List:
if cur-clmnConn-List = ? then do:
   run OpenBr(yes, no, '':U).
end.
else do:
   assign re-queryConn-List = yes.
   run sort-brConn-List
     (input (if available buf_fin-connect
             then recid(buf_fin-connect)
             else ?
            )
     ).
   assign re-queryConn-List = no.
end.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of sch-date in frame Dialog-Frame
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
on delete-character of sch-date in frame Dialog-Frame
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
on ctrl-d of sch-date in frame Dialog-Frame
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
on ctrl-b of sch-date in frame Dialog-Frame
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
on ctrl-e of sch-date in frame Dialog-Frame
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
on ctrl-f of sch-date in frame Dialog-Frame
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
  define MENU m-ed-date15
    MENU-ITEM m-ed-date15-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date15-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date15-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date15-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      sch-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date15 :HANDLE
      sch-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle15 as handle no-undo .
  assign
    v-label-handle15 = sch-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle15)
  then do:
    if v-label-handle15 :tooltip = ""
    or v-label-handle15 :tooltip = ?
    then do:
      assign
        v-label-handle15 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date15-1 in menu m-ed-date15 DO:
    apply "ctrl-b":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date15-2 in menu m-ed-date15 DO:
    apply "ctrl-d":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date15-3 in menu m-ed-date15 DO:
    apply "ctrl-e":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date15-4 in menu m-ed-date15 DO:
    apply "ctrl-f":U to sch-date in frame Dialog-Frame .
  END.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame Dialog-Frame:
    if p-filter-name > "" then do:
      assign
        frame Dialog-Frame:title
          = frame Dialog-Frame:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :tooltip = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :tooltip = ""
      .
    end.
  end.
end procedure.
  assign
    Conn-List:num-locked-columns = 1
    buf_fin-connect.fact-date:read-only in browse Conn-List = yes
  .
  if p-doc = "all" and p-doc-num <> "" then assign cont-list = string (p-doc-num) Sel-Contr = "sel" .
  RUN enable_UI.
  DISABLE  Sel-Contr  when (p-doc <> "all") WITH FRAME Dialog-Frame.
  if mark-num = 0   then hide mark-num   in frame Dialog-Frame.
  assign RADIO-find-doc .
  Run OpenBR(yes, no, '':U) .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numConn-List as INT EXTENT 12 no-undo.
DEF VAR varmviConn-List       as INT no-undo.
DEF VAR varmvjConn-List       as INT no-undo.
DEF VAR varmvkConn-List       as INT no-undo.
DEF VAR varmvlConn-List       as INT no-undo.
DEF VAR move-elementConn-List as INT no-undo.
def var jjConn-List           as int no-undo.
do varmviConn-List = 1 to EXTENT(cur-clmn-numConn-List):
  ASSIGN cur-clmn-numConn-List[varmviConn-List] = varmviConn-List.
END.
RUN start-mv-clmnConn-List.
PROCEDURE start-mv-clmnConn-List:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE Conn-List do:
  RUN re-move-clmnConn-List ( 1, 12).
END.
ON ctrl-cursor-left OF BROWSE Conn-List do:
  RUN re-move-clmnConn-List (12, 1).
END.
PROCEDURE re-move-clmnConn-List:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmviConn-List = 1 TO EXTENT(cur-clmn-numConn-List):
    if cur-clmn-numConn-List[varmviConn-List] = source-column THEN cur-clmn-numConn-List[varmviConn-List] = -1.
  END.
  if Conn-List:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjConn-List = source-column - 1 to target-column BY -1:
    DO varmviConn-List = 1 TO EXTENT(cur-clmn-numConn-List):
        if cur-clmn-numConn-List[varmviConn-List] = varmvjConn-List THEN DO:
          cur-clmn-numConn-List[varmviConn-List] = cur-clmn-numConn-List[varmviConn-List] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjConn-List = source-column + 1 to target-column:
    DO varmviConn-List = 1 TO EXTENT(cur-clmn-numConn-List):
      if cur-clmn-numConn-List[varmviConn-List] = varmvjConn-List THEN DO:
        cur-clmn-numConn-List[varmviConn-List] = cur-clmn-numConn-List[varmviConn-List] - 1.
      END.
    END.
  END.
  DO varmviConn-List = 1 TO EXTENT(cur-clmn-numConn-List):
    if cur-clmn-numConn-List[varmviConn-List] = -1 THEN cur-clmn-numConn-List[varmviConn-List] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnConn-List:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmviConn-List = 1 TO EXTENT(cur-clmn-numConn-List):
    if cur-clmn-numConn-List[varmviConn-List] = cur-clmn-loc THEN move-elementConn-List = varmviConn-List.
  END.
  RUN re-move-clmnConn-List (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultConn-List:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlConn-List = 1 to EXTENT(cur-clmn-numConn-List):
    RUN re-move-clmnConn-List (cur-clmn-numConn-List[varmvlConn-List], varmvlConn-List).
  END.
  RUN start-mv-clmnConn-List.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY Sel-Contr sch-date sch-user sch-code RADIO-find-doc mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-del b-sch B-view-fo B-view-doc Sel-Contr B-Help
         Conn-List sch-date sch-user sch-code RADIO-find-doc mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE OpenBr :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  define variable l-query-was-opened as logical no-undo .
  define variable title0 as character no-undo.
  define variable p-cont as integer   no-undo .
  title0 = "Связи фин. обязательств и платежей" + chr(32).
  define variable sort-column-phrase as character no-undo .
  case sort-column-name :
    when "" then assign  sort-column-phrase = ""  .
    otherwise    assign  sort-column-phrase = "by " + sort-column-name .
  end case.
  find first ub.clients no-lock where ub.clients.obj-type = 'орг':U and ub.clients.obj-code = p-host-code .
  ASSIGN title0  = title0 + " Фирма: (" + string(p-host-code) + ")":U + chr(32) + ub.clients.obj-name .
  define variable l-open-query as logical   no-undo .
  filter-point = filter-point0 .
  assign frame Dialog-Frame:title = title0 .
  if p-doc = "all" then do:
    if Sel-Contr = "all" then do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-19  as logical   no-undo .
define variable  l-filter-open-19    as logical   .
define variable  flt-rec-19       as recid     no-undo .
define variable  filter-name-19      as character no-undo .
define variable  where-phrase-19     as character no-undo .
define variable  sort-phrase-19      as character no-undo .
define variable  where-phrase-rus-19 as character no-undo .
define variable  sort-phrase-rus-19  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-19
  ,output filter-name-19
  ,output where-phrase-19
  ,output sort-phrase-19
  ,output where-phrase-rus-19
  ,output sort-phrase-rus-19
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-19
      ) no-error .
  assign
    l-filter-open-19 = false
  .
  if flt-rec-19 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-19 as character no-undo .
    define variable  parameter-3-19 as character no-undo .
    define variable  parameter-4-19 as character no-undo .
    define variable  parameter-5-19 as character no-undo .
    define variable  parameter-6-19 as character no-undo .
    define variable  parameter-7-19 as character no-undo .
      assign
      parameter-3-19 =
                              "FOR EACH buf_fin-connect"
      parameter-4-19 =
        (
          if (" buf_fin-connect.host-code = p-host-code " + " " + where-phrase-19) <> ""
          then  substitute(' buf_fin-connect.host-code = &1', p-host-code) + " " + where-phrase-19
          else "true"
        )
      parameter-5-19 = (" " + "" + " " + substitute(', first buf_fin-ob NO-LOCK                where buf_fin-ob.host-code = &1 and buf_fin-ob.doc-code = buf_fin-connect.fin-ob-code ,               first buf_fin-doc NO-LOCK where buf_fin-doc.host-code = &1 and buf_fin-doc.fin-doc-code = buf_fin-connect.fin-doc-code ,                 first buf_contract NO-LOCK where buf_contract.host-code = &1                  and buf_contract.contract-code = buf_fin-connect.contract-code', p-host-code))
      parameter-6-19 = if sort-phrase-19 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " +  substitute(' by &1 descending by &2 descending', buf_fin-connect.fact-date, buf_fin-connect.fact-time)
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-19
        )
      parameter-7-19 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-19 =
          (" buf_fin-connect.host-code = p-host-code " + " " + where-phrase-19 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Conn-List:handle
                          ,input parameter-3-19
                          ,input parameter-4-19
                          ,input parameter-5-19
                          ,input parameter-6-19
                          ,input parameter-7-19
                          )
      .
      assign
        l-filter-open-19 = true
      .
    end.
    if l-filter-open-19 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-19 = false then do:
    OPEN QUERY Conn-List FOR EACH buf_fin-connect NO-LOCK
      where  buf_fin-connect.host-code = p-host-code
    , first buf_fin-ob NO-LOCK                where buf_fin-ob.host-code = p-host-code                  and buf_fin-ob.doc-code = buf_fin-connect.fin-ob-code ,               first buf_fin-doc NO-LOCK                where buf_fin-doc.host-code = p-host-code                  and buf_fin-doc.fin-doc-code = buf_fin-connect.fin-doc-code ,                 first buf_contract NO-LOCK                 where buf_contract.host-code = p-host-code                  and buf_contract.contract-code = buf_fin-connect.contract-code
      by buf_fin-connect.fact-date descending by buf_fin-connect.fact-time descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( buf_fin-connect )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Conn-List:handle:get-buffer-handle(1) = (buffer buf_fin-connect:handle) then do:
      assign
      parameter-2-19 = (if p-find-next then "true":u else "false":u )
      parameter-4-19 =
        "where ":u +  substitute(' buf_fin-connect.host-code = &1', p-host-code) + " ":u + where-phrase-19 + " ":u + p-find-condition + " " + ""
      parameter-5-19 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Conn-List:handle
                          ,input rowid(buf_fin-connect)
                          ,input logical(parameter-2-19)
                          ,input no-lock
                          ,input (buffer buf_fin-connect:handle)
                          ,input parameter-4-19
                          ,input parameter-5-19
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-19 = (if p-find-next then "true":u else "false":u )
      parameter-3-19 =  "FOR EACH buf_fin-connect"
      parameter-4-19 =
        (
          if (" buf_fin-connect.host-code = p-host-code " + " " + where-phrase-19) <> ""
          then  substitute(' buf_fin-connect.host-code = &1', p-host-code) + " " + where-phrase-19
          else "true"
        )
      parameter-5-19 = (" " + "" + " " + substitute(', first buf_fin-ob NO-LOCK                where buf_fin-ob.host-code = &1 and buf_fin-ob.doc-code = buf_fin-connect.fin-ob-code ,               first buf_fin-doc NO-LOCK where buf_fin-doc.host-code = &1 and buf_fin-doc.fin-doc-code = buf_fin-connect.fin-doc-code ,                 first buf_contract NO-LOCK where buf_contract.host-code = &1                  and buf_contract.contract-code = buf_fin-connect.contract-code', p-host-code) + " " + p-find-condition)
      parameter-6-19 = if sort-phrase-19 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " +  substitute(' by &1 descending by &2 descending', buf_fin-connect.fact-date, buf_fin-connect.fact-time)
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-19
        )
      parameter-7-19 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Conn-List:handle
                          ,input logical(parameter-2-19)
                          ,input no-lock
                          ,input parameter-3-19
                          ,input parameter-4-19
                          ,input parameter-5-19
                          ,input parameter-6-19
                          ,input parameter-7-19
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
    else do:
      find first ub.contract no-lock where recid (ub.contract)  = int (cont-list) no-error .
      assign p-cont = ub.contract.contract-code .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-21  as logical   no-undo .
define variable  l-filter-open-21    as logical   .
define variable  flt-rec-21       as recid     no-undo .
define variable  filter-name-21      as character no-undo .
define variable  where-phrase-21     as character no-undo .
define variable  sort-phrase-21      as character no-undo .
define variable  where-phrase-rus-21 as character no-undo .
define variable  sort-phrase-rus-21  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-21
  ,output filter-name-21
  ,output where-phrase-21
  ,output sort-phrase-21
  ,output where-phrase-rus-21
  ,output sort-phrase-rus-21
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-21
      ) no-error .
  assign
    l-filter-open-21 = false
  .
  if flt-rec-21 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-21 as character no-undo .
    define variable  parameter-3-21 as character no-undo .
    define variable  parameter-4-21 as character no-undo .
    define variable  parameter-5-21 as character no-undo .
    define variable  parameter-6-21 as character no-undo .
    define variable  parameter-7-21 as character no-undo .
      assign
      parameter-3-21 =
                              "FOR EACH buf_fin-connect"
      parameter-4-21 =
        (
          if (" buf_fin-connect.host-code = p-host-code and buf_fin-connect.contract-code = p-cont " + " " + where-phrase-21) <> ""
          then  substitute(' buf_fin-connect.host-code = &1 and buf_fin-connect.contract-code = &2', p-host-code, p-cont) + " " + where-phrase-21
          else "true"
        )
      parameter-5-21 = (" " + "" + " " + substitute(', first buf_fin-ob NO-LOCK                where buf_fin-ob.host-code = &1 and buf_fin-ob.doc-code = buf_fin-connect.fin-ob-code ,               first buf_fin-doc NO-LOCK where buf_fin-doc.host-code = &1 and buf_fin-doc.fin-doc-code = buf_fin-connect.fin-doc-code ,                 first buf_contract NO-LOCK where buf_contract.host-code = &1                  and buf_contract.contract-code = buf_fin-connect.contract-code', p-host-code))
      parameter-6-21 = if sort-phrase-21 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " +  substitute(' by &1 descending by &2 descending', buf_fin-connect.fact-date, buf_fin-connect.fact-time)
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-21
        )
      parameter-7-21 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-21 =
          (" buf_fin-connect.host-code = p-host-code and buf_fin-connect.contract-code = p-cont " + " " + where-phrase-21 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Conn-List:handle
                          ,input parameter-3-21
                          ,input parameter-4-21
                          ,input parameter-5-21
                          ,input parameter-6-21
                          ,input parameter-7-21
                          )
      .
      assign
        l-filter-open-21 = true
      .
    end.
    if l-filter-open-21 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-21 = false then do:
    OPEN QUERY Conn-List FOR EACH buf_fin-connect NO-LOCK
      where  buf_fin-connect.host-code = p-host-code and buf_fin-connect.contract-code = p-cont
    , first buf_fin-ob NO-LOCK                where buf_fin-ob.host-code = p-host-code                  and buf_fin-ob.doc-code = buf_fin-connect.fin-ob-code ,               first buf_fin-doc NO-LOCK                where buf_fin-doc.host-code = p-host-code                  and buf_fin-doc.fin-doc-code = buf_fin-connect.fin-doc-code ,                 first buf_contract NO-LOCK                 where buf_contract.host-code = p-host-code                  and buf_contract.contract-code = buf_fin-connect.contract-code
      by buf_fin-connect.fact-date descending by buf_fin-connect.fact-time descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( buf_fin-connect )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Conn-List:handle:get-buffer-handle(1) = (buffer buf_fin-connect:handle) then do:
      assign
      parameter-2-21 = (if p-find-next then "true":u else "false":u )
      parameter-4-21 =
        "where ":u +  substitute(' buf_fin-connect.host-code = &1 and buf_fin-connect.contract-code = &2', p-host-code, p-cont) + " ":u + where-phrase-21 + " ":u + p-find-condition + " " + ""
      parameter-5-21 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Conn-List:handle
                          ,input rowid(buf_fin-connect)
                          ,input logical(parameter-2-21)
                          ,input no-lock
                          ,input (buffer buf_fin-connect:handle)
                          ,input parameter-4-21
                          ,input parameter-5-21
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-21 = (if p-find-next then "true":u else "false":u )
      parameter-3-21 =  "FOR EACH buf_fin-connect"
      parameter-4-21 =
        (
          if (" buf_fin-connect.host-code = p-host-code and buf_fin-connect.contract-code = p-cont " + " " + where-phrase-21) <> ""
          then  substitute(' buf_fin-connect.host-code = &1 and buf_fin-connect.contract-code = &2', p-host-code, p-cont) + " " + where-phrase-21
          else "true"
        )
      parameter-5-21 = (" " + "" + " " + substitute(', first buf_fin-ob NO-LOCK                where buf_fin-ob.host-code = &1 and buf_fin-ob.doc-code = buf_fin-connect.fin-ob-code ,               first buf_fin-doc NO-LOCK where buf_fin-doc.host-code = &1 and buf_fin-doc.fin-doc-code = buf_fin-connect.fin-doc-code ,                 first buf_contract NO-LOCK where buf_contract.host-code = &1                  and buf_contract.contract-code = buf_fin-connect.contract-code', p-host-code) + " " + p-find-condition)
      parameter-6-21 = if sort-phrase-21 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " +  substitute(' by &1 descending by &2 descending', buf_fin-connect.fact-date, buf_fin-connect.fact-time)
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-21
        )
      parameter-7-21 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Conn-List:handle
                          ,input logical(parameter-2-21)
                          ,input no-lock
                          ,input parameter-3-21
                          ,input parameter-4-21
                          ,input parameter-5-21
                          ,input parameter-6-21
                          ,input parameter-7-21
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
  end.
  else do:
    if p-doc = "fin-ob" then do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-23  as logical   no-undo .
define variable  l-filter-open-23    as logical   .
define variable  flt-rec-23       as recid     no-undo .
define variable  filter-name-23      as character no-undo .
define variable  where-phrase-23     as character no-undo .
define variable  sort-phrase-23      as character no-undo .
define variable  where-phrase-rus-23 as character no-undo .
define variable  sort-phrase-rus-23  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-23
  ,output filter-name-23
  ,output where-phrase-23
  ,output sort-phrase-23
  ,output where-phrase-rus-23
  ,output sort-phrase-rus-23
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-23
      ) no-error .
  assign
    l-filter-open-23 = false
  .
  if flt-rec-23 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-23 as character no-undo .
    define variable  parameter-3-23 as character no-undo .
    define variable  parameter-4-23 as character no-undo .
    define variable  parameter-5-23 as character no-undo .
    define variable  parameter-6-23 as character no-undo .
    define variable  parameter-7-23 as character no-undo .
      assign
      parameter-3-23 =
                              "FOR EACH buf_fin-connect"
      parameter-4-23 =
        (
          if (" buf_fin-connect.host-code = p-host-code and buf_fin-connect.fin-ob-code = p-doc-num " + " " + where-phrase-23) <> ""
          then  substitute(' buf_fin-connect.host-code = &1 and buf_fin-connect.contract-code = &2', p-host-code, p-doc-num) + " " + where-phrase-23
          else "true"
        )
      parameter-5-23 = (" " + "" + " " + substitute(', first buf_fin-ob NO-LOCK                where buf_fin-ob.host-code = &1 and buf_fin-ob.doc-code = buf_fin-connect.fin-ob-code ,               first buf_fin-doc NO-LOCK where buf_fin-doc.host-code = &1 and buf_fin-doc.fin-doc-code = buf_fin-connect.fin-doc-code ,                 first buf_contract NO-LOCK where buf_contract.host-code = &1                  and buf_contract.contract-code = buf_fin-connect.contract-code', p-host-code))
      parameter-6-23 = if sort-phrase-23 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " +  substitute(' by &1 descending by &2 descending', buf_fin-connect.fact-date, buf_fin-connect.fact-time)
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-23
        )
      parameter-7-23 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-23 =
          (" buf_fin-connect.host-code = p-host-code and buf_fin-connect.fin-ob-code = p-doc-num " + " " + where-phrase-23 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Conn-List:handle
                          ,input parameter-3-23
                          ,input parameter-4-23
                          ,input parameter-5-23
                          ,input parameter-6-23
                          ,input parameter-7-23
                          )
      .
      assign
        l-filter-open-23 = true
      .
    end.
    if l-filter-open-23 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-23 = false then do:
    OPEN QUERY Conn-List FOR EACH buf_fin-connect NO-LOCK
      where  buf_fin-connect.host-code = p-host-code and buf_fin-connect.fin-ob-code = p-doc-num
    , first buf_fin-ob NO-LOCK                where buf_fin-ob.host-code = p-host-code                  and buf_fin-ob.doc-code = buf_fin-connect.fin-ob-code ,               first buf_fin-doc NO-LOCK                where buf_fin-doc.host-code = p-host-code                  and buf_fin-doc.fin-doc-code = buf_fin-connect.fin-doc-code ,                 first buf_contract NO-LOCK                 where buf_contract.host-code = p-host-code                  and buf_contract.contract-code = buf_fin-connect.contract-code
      by buf_fin-connect.fact-date descending by buf_fin-connect.fact-time descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( buf_fin-connect )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Conn-List:handle:get-buffer-handle(1) = (buffer buf_fin-connect:handle) then do:
      assign
      parameter-2-23 = (if p-find-next then "true":u else "false":u )
      parameter-4-23 =
        "where ":u +  substitute(' buf_fin-connect.host-code = &1 and buf_fin-connect.contract-code = &2', p-host-code, p-doc-num) + " ":u + where-phrase-23 + " ":u + p-find-condition + " " + ""
      parameter-5-23 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Conn-List:handle
                          ,input rowid(buf_fin-connect)
                          ,input logical(parameter-2-23)
                          ,input no-lock
                          ,input (buffer buf_fin-connect:handle)
                          ,input parameter-4-23
                          ,input parameter-5-23
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-23 = (if p-find-next then "true":u else "false":u )
      parameter-3-23 =  "FOR EACH buf_fin-connect"
      parameter-4-23 =
        (
          if (" buf_fin-connect.host-code = p-host-code and buf_fin-connect.fin-ob-code = p-doc-num " + " " + where-phrase-23) <> ""
          then  substitute(' buf_fin-connect.host-code = &1 and buf_fin-connect.contract-code = &2', p-host-code, p-doc-num) + " " + where-phrase-23
          else "true"
        )
      parameter-5-23 = (" " + "" + " " + substitute(', first buf_fin-ob NO-LOCK                where buf_fin-ob.host-code = &1 and buf_fin-ob.doc-code = buf_fin-connect.fin-ob-code ,               first buf_fin-doc NO-LOCK where buf_fin-doc.host-code = &1 and buf_fin-doc.fin-doc-code = buf_fin-connect.fin-doc-code ,                 first buf_contract NO-LOCK where buf_contract.host-code = &1                  and buf_contract.contract-code = buf_fin-connect.contract-code', p-host-code) + " " + p-find-condition)
      parameter-6-23 = if sort-phrase-23 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " +  substitute(' by &1 descending by &2 descending', buf_fin-connect.fact-date, buf_fin-connect.fact-time)
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-23
        )
      parameter-7-23 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Conn-List:handle
                          ,input logical(parameter-2-23)
                          ,input no-lock
                          ,input parameter-3-23
                          ,input parameter-4-23
                          ,input parameter-5-23
                          ,input parameter-6-23
                          ,input parameter-7-23
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
    if p-doc = "fin-doc" then do:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-25  as logical   no-undo .
define variable  l-filter-open-25    as logical   .
define variable  flt-rec-25       as recid     no-undo .
define variable  filter-name-25      as character no-undo .
define variable  where-phrase-25     as character no-undo .
define variable  sort-phrase-25      as character no-undo .
define variable  where-phrase-rus-25 as character no-undo .
define variable  sort-phrase-rus-25  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-25
  ,output filter-name-25
  ,output where-phrase-25
  ,output sort-phrase-25
  ,output where-phrase-rus-25
  ,output sort-phrase-rus-25
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-25
      ) no-error .
  assign
    l-filter-open-25 = false
  .
  if flt-rec-25 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-25 as character no-undo .
    define variable  parameter-3-25 as character no-undo .
    define variable  parameter-4-25 as character no-undo .
    define variable  parameter-5-25 as character no-undo .
    define variable  parameter-6-25 as character no-undo .
    define variable  parameter-7-25 as character no-undo .
      assign
      parameter-3-25 =
                              "FOR EACH buf_fin-connect"
      parameter-4-25 =
        (
          if (" buf_fin-connect.host-code = p-host-code and buf_fin-connect.fin-doc-code = integer(p-doc-num) " + " " + where-phrase-25) <> ""
          then  substitute(' buf_fin-connect.host-code = &1 and buf_fin-connect.fin-doc-code = &2', p-host-code, integer(p-doc-num)) + " " + where-phrase-25
          else "true"
        )
      parameter-5-25 = (" " + "" + " " + substitute(', first buf_fin-ob NO-LOCK                where buf_fin-ob.host-code = &1 and buf_fin-ob.doc-code = buf_fin-connect.fin-ob-code ,               first buf_fin-doc NO-LOCK where buf_fin-doc.host-code = &1 and buf_fin-doc.fin-doc-code = buf_fin-connect.fin-doc-code ,                 first buf_contract NO-LOCK where buf_contract.host-code = &1                  and buf_contract.contract-code = buf_fin-connect.contract-code', p-host-code))
      parameter-6-25 = if sort-phrase-25 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " +  substitute(' by &1 descending by &2 descending', buf_fin-connect.fact-date, buf_fin-connect.fact-time)
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-25
        )
      parameter-7-25 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-25 =
          (" buf_fin-connect.host-code = p-host-code and buf_fin-connect.fin-doc-code = integer(p-doc-num) " + " " + where-phrase-25 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query Conn-List:handle
                          ,input parameter-3-25
                          ,input parameter-4-25
                          ,input parameter-5-25
                          ,input parameter-6-25
                          ,input parameter-7-25
                          )
      .
      assign
        l-filter-open-25 = true
      .
    end.
    if l-filter-open-25 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-25 = false then do:
    OPEN QUERY Conn-List FOR EACH buf_fin-connect NO-LOCK
      where  buf_fin-connect.host-code = p-host-code and buf_fin-connect.fin-doc-code = integer(p-doc-num)
    , first buf_fin-ob NO-LOCK                where buf_fin-ob.host-code = p-host-code                  and buf_fin-ob.doc-code = buf_fin-connect.fin-ob-code ,               first buf_fin-doc NO-LOCK                where buf_fin-doc.host-code = p-host-code                  and buf_fin-doc.fin-doc-code = buf_fin-connect.fin-doc-code ,                 first buf_contract NO-LOCK                 where buf_contract.host-code = p-host-code                  and buf_contract.contract-code = buf_fin-connect.contract-code
      by buf_fin-connect.fact-date descending by buf_fin-connect.fact-time descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( buf_fin-connect )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query Conn-List:handle:get-buffer-handle(1) = (buffer buf_fin-connect:handle) then do:
      assign
      parameter-2-25 = (if p-find-next then "true":u else "false":u )
      parameter-4-25 =
        "where ":u +  substitute(' buf_fin-connect.host-code = &1 and buf_fin-connect.fin-doc-code = &2', p-host-code, integer(p-doc-num)) + " ":u + where-phrase-25 + " ":u + p-find-condition + " " + ""
      parameter-5-25 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query Conn-List:handle
                          ,input rowid(buf_fin-connect)
                          ,input logical(parameter-2-25)
                          ,input no-lock
                          ,input (buffer buf_fin-connect:handle)
                          ,input parameter-4-25
                          ,input parameter-5-25
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-25 = (if p-find-next then "true":u else "false":u )
      parameter-3-25 =  "FOR EACH buf_fin-connect"
      parameter-4-25 =
        (
          if (" buf_fin-connect.host-code = p-host-code and buf_fin-connect.fin-doc-code = integer(p-doc-num) " + " " + where-phrase-25) <> ""
          then  substitute(' buf_fin-connect.host-code = &1 and buf_fin-connect.fin-doc-code = &2', p-host-code, integer(p-doc-num)) + " " + where-phrase-25
          else "true"
        )
      parameter-5-25 = (" " + "" + " " + substitute(', first buf_fin-ob NO-LOCK                where buf_fin-ob.host-code = &1 and buf_fin-ob.doc-code = buf_fin-connect.fin-ob-code ,               first buf_fin-doc NO-LOCK where buf_fin-doc.host-code = &1 and buf_fin-doc.fin-doc-code = buf_fin-connect.fin-doc-code ,                 first buf_contract NO-LOCK where buf_contract.host-code = &1                  and buf_contract.contract-code = buf_fin-connect.contract-code', p-host-code) + " " + p-find-condition)
      parameter-6-25 = if sort-phrase-25 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " +  substitute(' by &1 descending by &2 descending', buf_fin-connect.fact-date, buf_fin-connect.fact-time)
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-25
        )
      parameter-7-25 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query Conn-List:handle
                          ,input logical(parameter-2-25)
                          ,input no-lock
                          ,input parameter-3-25
                          ,input parameter-4-25
                          ,input parameter-5-25
                          ,input parameter-6-25
                          ,input parameter-7-25
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
  end.
  REPOSITION Conn-List to recid v-doc-rec No-ERROR.
END PROCEDURE.
PROCEDURE proc-find-code :
  define input parameter p-next as logical no-undo.
  define input parameter p-code as integer no-undo .
  display "  /  /":U @ sch-date  "":U @ sch-user  with frame Dialog-Frame.
  if RADIO-find-doc = 1 then run OpenBr in this-procedure (input false, input p-next, input substitute("and buf_fin-connect.fin-ob-code = &1 ", p-code)).
  else run OpenBr in this-procedure (input false, input p-next, input substitute("and buf_fin-connect.fin-doc-code = &1 ", p-code)).
  apply "entry":u to sch-code in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-date :
  define input parameter p-next as logical no-undo.
  define input parameter par-date as date    no-undo .
  display "":U @ sch-user  "":U @ sch-code  with frame Dialog-Frame.
  define variable var-datechr as character no-undo .
  assign var-datechr = string(day(par-date)) + chr(47) + string(month(par-date)) + chr(47) + string(year(par-date)) .
  run OpenBr  in this-procedure (input false, input p-next,input substitute("and buf_fin-connect.fact-date = &1 ", var-datechr)) .
  apply "entry":u to sch-date in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-user :
  define input parameter p-next as logical no-undo.
  define input parameter p-code as character no-undo .
  display  "  /  /":U @ sch-date   "":U @ sch-code  with frame Dialog-Frame.
  assign p-code = replace(p-code, chr(39), chr(39) + chr(39)) .
  run OpenBr in this-procedure (input false, input p-next, input substitute("and buf_fin-connect.user-name = '&1' ", p-code)).
  apply "entry":u to sch-user in frame Dialog-Frame .
END PROCEDURE.
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid ) :
  define variable ret as character no-undo .
  assign ret = "" .
  find first temp-conn where temp-conn.ri = par-recid no-error .
  if available temp-conn then assign ret = "*" .
  RETURN ret .
END FUNCTION.
