DEFINE BUFFER X_c-contract FOR ub.c-contract.
DEFINE BUFFER X_contract FOR ub.contract.
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-host-code    as integer   no-undo .
define input parameter p-contract-code as integer   no-undo .
define input parameter bttns  as char   no-undo .
define input-output param p-rid-list    as  char no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список истории договоров".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable filter-point as character no-undo init "Список истории договоров" .
define variable filter-point0 as character no-undo init "Список истории договоров" .
define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable title0 as character no-undo.
define temp-table temp-changes no-undo
  field f_name as character
  field l_name as character
  field v_old as character
  field v_new as character
index pi is unique primary f_name.
FUNCTION get-agent RETURNS CHARACTER
  ( input agnt-type as character , input agnt-code as integer )  FORWARD.
FUNCTION get-currency RETURNS CHARACTER
  ( input curr-code as integer )  FORWARD.
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid, input mark-list as character)  FORWARD.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 10 BY 1.
DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE  QUERY brc-contract FOR X_c-contract SCROLLING.
DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.
DEFINE BROWSE brc-contract
  QUERY brc-contract DISPLAY
      (mark-string(recid(X_c-contract), p-rid-list)) COLUMN-LABEL "*" FORMAT "x(1)"
      X_c-contract.corr-date                    COLUMN-LABEL "Дата!изменения"  FORMAT "99/99/99"
      string(X_c-contract.corr-time,"HH:MM")    COLUMN-LABEL "Время!изменения" FORMAT "X(5)"
      usrfulnf(X_c-contract.corr-user-name)               COLUMN-LABEL "Оператор"        FORMAT "X(18)"
      X_c-contract.status_                      COLUMN-LABEL "Статус"          FORMAT "X(4)"
      X_c-contract.contract-prn-code            COLUMN-LABEL "Номер"           FORMAT "X(16)"
      X_c-contract.contract-date                COLUMN-LABEL "Дата!договора"  FORMAT "99/99/99"
      X_c-contract.contract-name                COLUMN-LABEL "Заголовок"       FORMAT "X(22)"
      if X_c-contract.cli-type = "" then "" else TRIM (X_c-contract.cli-type + " " + STRING (X_c-contract.cli-code)) COLUMN-LABEL "Тип/код!контрагента" FORMAT "x(10)"
      X_c-contract.cli-name                     COLUMN-LABEL "Контрагент"      FORMAT "x(40)"
      X_c-contract.contract-type                COLUMN-LABEL "Тип договора"    FORMAT "X(23)"
      X_c-contract.usl-opl                      COLUMN-LABEL "Условия!оплаты"  FORMAT "X(32)"
      if X_c-contract.srok-opl > 0 then string(X_c-contract.srok-opl) else ""    COLUMN-LABEL "Отс-!роч."    FORMAT "X(4)"
      X_c-contract.contract-city                COLUMN-LABEL "Город"  FORMAT "X(20)"
      X_c-contract.contract-date-beg            COLUMN-LABEL "Начало!действия"     FORMAT "99/99/99"
      X_c-contract.contract-date-end            COLUMN-LABEL "Окончание!действия"      FORMAT "99/99/99"
      (get-currency(X_c-contract.curr-code))    COLUMN-LABEL "вал" FORMAT "x(3)"
      if X_c-contract.posr-type = "" then "" else TRIM (X_c-contract.posr-type + " " + STRING (X_c-contract.posr-code)) COLUMN-LABEL "Тип/код!посредника" FORMAT "x(10)"
      X_c-contract.posr-name                    COLUMN-LABEL "Посредник"       FORMAT "x(40)"
      if X_c-contract.agnt-type = "" then "" else TRIM (X_c-contract.agnt-type + " " + STRING (X_c-contract.agnt-code)) COLUMN-LABEL "Тип/код!агента" FORMAT "x(10)"
      X_c-contract.agnt-name                    COLUMN-LABEL "Агент"           FORMAT "x(40)"
      (get-agent( 'чел':U ,X_c-contract.mngr-code))  COLUMN-LABEL "Исполнитель" FORMAT "x(50)"
      X_c-contract.doc-type
    ENABLE
      X_c-contract.contract-prn-code
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96 BY 13.71.
DEFINE BROWSE BR-changes
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(35)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(40)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(40)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 95.88 BY 5.83.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-lookup AT ROW 1 COL 31
     B-sch AT ROW 1 COL 41
     B-Help AT ROW 1 COL 86.25
     brc-contract AT ROW 2 COL 1.38
     BR-changes AT ROW 16.04 COL 1.38
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(77.49) SKIP(20.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список договоров"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       brc-contract:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 1.
ON ENDKEY OF FRAME Dialog-Frame
DO:
    run gbl/markqwa.p ( input b-mark:sensitive, input p-rid-list) no-error.
    if error-status:error then return no-apply.
END.
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame
DO:
  if not available X_c-contract then return no-apply.
  define variable g-log  as logical   no-undo .
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-contract_lookup':U
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
  define variable ri as recid no-undo .
  ri = recid( X_c-contract ).
  run str/contr.w ( input parParentProc,input p-host-code, input "history", input X_c-contract.doc-type, input-output ri) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo .
  if available X_c-contract then do:
      if can-do( p-rid-list, string( recid( X_c-contract ) ) ) then do:
          p-rid-list = replace( p-rid-list, chr(44) + string( recid( X_c-contract ) ), "") .
          p-rid-list = replace( p-rid-list, string( recid( X_c-contract ) ) + chr(44), "") .
          p-rid-list = replace( p-rid-list, string( recid( X_c-contract ) ), "") .
      end.
      else
      p-rid-list = p-rid-list + ( if p-rid-list = "" then "" else chr(44) ) + string( recid( X_c-contract ) ) .
      loc#log = brc-contract:refresh() .
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          loc#log = brc-contract:select-next-row ().
          apply "VALUE-CHANGED" to brc-contract in frame Dialog-Frame.
      end.
      if num-entries( p-rid-list ) = 0 then hide mark-num in frame Dialog-Frame.
      else disp num-entries( p-rid-list ) @ mark-num with frame Dialog-Frame.
  end.
  apply "entry" to brc-contract in frame Dialog-Frame.
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
  assign
    tbl = 'ub.c-contract'
    join-tbl = 'X_c-contract'
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
  .
  run fltfield-add in this-procedure('host-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-date', 'Дата', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-prn-code', 'Номер', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-type', 'Тип', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('usl-opl', 'Условия генерации', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('auto-pay', 'Статус генерации', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('str-uslov-oplat', 'Условия оплаты', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('srok-opl', 'Отсрочка', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('status_', 'Статус', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-name', 'Заголовок', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-city', 'Город', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-date-beg', 'Дата начала договора', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-date-end', 'Дата конца договора', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('curr-code', 'Валюта', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('user-db-num', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('user-name', 'Имя оператора', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-type', 'Тип контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-code', 'Код контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-name', 'Контрагент', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-addres', 'Адрес контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-inn', 'ИНН контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-kpp', 'КПП контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-bank-name', 'Банк контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-bik', 'БИК контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-r-schet', 'Рас.счет контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-c-schet', 'Кор.счет контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-sign-post', 'Должность контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-sign', 'Подпись контрагента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-name', 'Наименование фирмы', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-addres', 'Адрес', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-inn', 'ИНН', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-kpp', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-bank-name', 'Банк', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-bik', 'БИК', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-r-schet', 'Рас.счет', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-c-schet', 'Кор.счет', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-sign-post', 'Должность', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-sign', 'Подпись', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-type', 'Тип посредника', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-code', 'Код посредника', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-name', 'Посредник', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-addres', 'Адрес посредника', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-inn', ' посредника', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-kpp', 'КПП посредника', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-bank-name', 'Банк посредника', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-bik', 'БИК посредника', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-r-schet', 'Рас.счет посредника', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-c-schet', 'Кор.счет посредника', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-sign-post', 'Должность посредника', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-sign', 'Подпись посредника', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-type', 'Тип агента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-code', 'Код агента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-name', 'Агент', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-addres', 'Адрес агента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-inn', 'ИНН агента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-kpp', 'КПП агента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-bank-name', 'Банк агента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-bik', 'БИК агента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-r-schet', 'Рас.счет агента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-c-schet', 'Кор.счет агента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-sign-post', 'Должность агента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-sign', 'Подпись агента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('mngr-code', 'Код исполнителя', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc-out', 'Кор. счет РПП', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc1-out', 'Кор. счет касса РПП', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('an-uchet-code-out', 'Аналит. учет РПП', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cel-nazn-code-out', 'Целев. назн РПП', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc-in', 'Кор. счет ППП', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc1-in', 'Кор. счет касса ППП', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('an-uchet-code-in', 'Аналит. учет ППП', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cel-nazn-code-in', 'Целев. назн ППП', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc-out-cash', 'Кор. счет РКО', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc1-out-cash', 'Кор. счет касса РКО', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('an-uchet-code-out-cash', 'Аналит. учет РКО', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cel-nazn-code-out-cash', 'Целев. назн РКО', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc-in-cash', 'Кор. счет ПКО', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc1-in-cash', 'Кор. счет касса ПКО', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('an-uchet-code-in-cash', 'Аналит. учет ПКО', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cel-nazn-code-in-cash', 'Целев. назн ПКО', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc-out-payoff', 'Кор. счет Р.АПЗ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc1-out-payoff', 'Кор. счет касса Р.АПЗ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('an-uchet-code-out-payoff', 'Аналит. учет Р.АПЗ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cel-nazn-code-out-payoff', 'Целев. назн Р.АПЗ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc-in-payoff', 'Кор. счет П.АПЗ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cor-acc1-in-payoff', 'Кор. счет касса П.АПЗ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('an-uchet-code-in-payoff', 'Аналит. учет П.АПЗ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cel-nazn-code-in-payoff', 'Целев. назн П.АПЗ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
  DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
     ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
     ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
    run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
    RUN OpenBr(yes, no, '':U).
  end.
END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
DO:
  if ( available X_c-contract ) AND ( p-rid-list = "" ) then  p-rid-list = string( recid( X_c-contract ) ) .
END.
ON RETURN OF brc-contract IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF brc-contract IN FRAME Dialog-Frame
DO:
  if b-sel:sensitive in frame Dialog-Frame then
    if b-mark:sensitive then apply "choose" to b-mark in frame Dialog-Frame.
    else                     apply "choose" to b-sel in frame Dialog-Frame.
  else if b-lookup:sensitive then apply "choose" to b-lookup in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF brc-contract IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure no-error.
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
        v-diasize-browse-handle     = browse brc-contract :handle
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
def var sort-labelbrc-contract   as character no-undo .
def var sort-clmnbrc-contract    as handle    no-undo .
def var cur-clmnbrc-contract     as handle    no-undo .
def var cur-clmn-locbrc-contract as integer   no-undo .
def var re-querybrc-contract     as logical   initial no no-undo .
on start-search, ctrl-o of brc-contract in frame Dialog-Frame do:
   run sort-brbrc-contract
     (input (if available X_c-contract
             then recid(X_c-contract)
             else ?
            )
     ).
end.
PROCEDURE sort-brbrc-contract :
  define input parameter p-recid as recid no-undo .
  if re-querybrc-contract = no then do:
    assign
       cur-clmnbrc-contract = brc-contract:current-column in frame Dialog-Frame
    .
    if sort-clmnbrc-contract <> ? then sort-clmnbrc-contract:column-fgcolor = 0.
    if cur-clmnbrc-contract = sort-clmnbrc-contract then do:
      assign
         sort-labelbrc-contract = ""
         sort-clmnbrc-contract = ?
      .
     end.
     else do:
       assign
         sort-labelbrc-contract = cur-clmnbrc-contract:label
         sort-clmnbrc-contract  = cur-clmnbrc-contract
         sort-clmnbrc-contract:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbrc-contract = 1
  .
  def var column-handle as handle no-undo .
  column-handle = brc-contract:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbrc-contract then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbrc-contract = cur-clmn-locbrc-contract + 1
    .
  end.
  case sort-labelbrc-contract:
        when X_c-contract.contract-prn-code:label in browse brc-contract then DO:    assign       sort-column-name = "X_c-contract.contract-prn-code"     .     run OpenBr(yes, no, no).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr(yes, no, no).
      if sort-labelbrc-contract <> "" then do:
        assign
          cur-clmnbrc-contract:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbrc-contract = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition brc-contract to recid p-recid no-error.
    apply "value-changed" to brc-contract in frame Dialog-Frame.
  end.
  apply "entry" to brc-contract in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbrc-contract:
if cur-clmnbrc-contract = ? then do:
   run OpenBr(yes, no, no).
end.
else do:
   assign re-querybrc-contract = yes.
   run sort-brbrc-contract
     (input (if available X_c-contract
             then recid(X_c-contract)
             else ?
            )
     ).
   assign re-querybrc-contract = no.
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
  find first X_contract no-lock  where X_contract.host-code = p-host-code and X_contract.contract-code = p-contract-code no-error .
  if not available X_contract then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-host-code и/или p-contract-code"  p-host-code p-contract-code
    view-as alert-box ERROR.
    return.
  end.
  assign
    brc-contract:num-locked-columns = 1
    X_c-contract.contract-prn-code:read-only in browse brc-contract = yes
  .
  find first ub.clients no-lock where ub.clients.obj-code = p-host-code and ub.clients.obj-type = 'орг':U .
  title0 = "Список истории договоров" + chr(32)  + substitute(" Фирма: (&1) &2 Договор : &3 от &4", p-host-code, ub.clients.obj-name,  X_contract.contract-prn-code, string(X_contract.contract-date,"99/99/9999")) .
  RUN MyEnable.
  DISABLE
    b-sel   when  NOT can-do( bttns, "b-sel" )
    b-mark  when  NOT can-do( bttns, "b-mark")
  WITH FRAME Dialog-Frame.
  RUn OpenBR(yes, no, '':U).
  HIDE mark-num in frame Dialog-Frame .
  if p-rid-list <> "":U then assign v-doc-rec = integer(entry(1, p-rid-list)) .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY mark-num      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-sel B-lookup B-sch B-Help brc-contract BR-changes mark-num    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
  DISPLAY mark-num WITH FRAME Dialog-Frame.
  ENABLE  b-quit  B-lookup  b-sel  B-mark  B-sch  B-Help  mark-num  brc-contract  BR-changes WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE OpenBr :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  def var l-query-was-opened as logical no-undo .
  def var sort-column-phrase as character no-undo .
  case sort-column-name :
    when "" then assign sort-column-phrase = ""  .
    otherwise    assign sort-column-phrase = "by " + sort-column-name  .
  end case.
  define variable l-open-query as logical   no-undo .
  filter-point = filter-point0 .
  ASSIGN frame Dialog-Frame:TITLE = title0 .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-15  as logical   no-undo .
define variable  l-filter-open-15    as logical   .
define variable  flt-rec-15       as recid     no-undo .
define variable  filter-name-15      as character no-undo .
define variable  where-phrase-15     as character no-undo .
define variable  sort-phrase-15      as character no-undo .
define variable  where-phrase-rus-15 as character no-undo .
define variable  sort-phrase-rus-15  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-15
  ,output filter-name-15
  ,output where-phrase-15
  ,output sort-phrase-15
  ,output where-phrase-rus-15
  ,output sort-phrase-rus-15
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-15
      ) no-error .
  assign
    l-filter-open-15 = false
  .
  if flt-rec-15 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-15 as character no-undo .
    define variable  parameter-3-15 as character no-undo .
    define variable  parameter-4-15 as character no-undo .
    define variable  parameter-5-15 as character no-undo .
    define variable  parameter-6-15 as character no-undo .
    define variable  parameter-7-15 as character no-undo .
      assign
      parameter-3-15 =
                              "FOR EACH X_c-contract"
      parameter-4-15 =
        (
          if (" X_c-contract.host-code = p-host-code AND X_c-contract.contract-code  = p-contract-code " + " " + where-phrase-15) <> ""
          then  substitute(' X_c-contract.host-code = &1 and X_c-contract.contract-code = &2', p-host-code, p-contract-code) + " " + where-phrase-15
          else "true"
        )
      parameter-5-15 = (" " + "" + " " + "")
      parameter-6-15 = if sort-phrase-15 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-15
        )
      parameter-7-15 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-15 =
          (" X_c-contract.host-code = p-host-code AND X_c-contract.contract-code  = p-contract-code " + " " + where-phrase-15 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query brc-contract:handle
                          ,input parameter-3-15
                          ,input parameter-4-15
                          ,input parameter-5-15
                          ,input parameter-6-15
                          ,input parameter-7-15
                          )
      .
      assign
        l-filter-open-15 = true
      .
    end.
    if l-filter-open-15 = false then do:
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
  if l-filter-open-15 = false then do:
    OPEN QUERY brc-contract FOR EACH X_c-contract
      where  X_c-contract.host-code = p-host-code AND X_c-contract.contract-code  = p-contract-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_c-contract )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query brc-contract:handle:get-buffer-handle(1) = (buffer X_c-contract:handle) then do:
      assign
      parameter-2-15 = (if p-find-next then "true":u else "false":u )
      parameter-4-15 =
        "where ":u +  substitute(' X_c-contract.host-code = &1 and X_c-contract.contract-code = &2', p-host-code, p-contract-code) + " ":u + where-phrase-15 + " ":u + p-find-condition + " " + ""
      parameter-5-15 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query brc-contract:handle
                          ,input rowid(X_c-contract)
                          ,input logical(parameter-2-15)
                          ,input no-lock
                          ,input (buffer X_c-contract:handle)
                          ,input parameter-4-15
                          ,input parameter-5-15
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-15 = (if p-find-next then "true":u else "false":u )
      parameter-3-15 =  "FOR EACH X_c-contract"
      parameter-4-15 =
        (
          if (" X_c-contract.host-code = p-host-code AND X_c-contract.contract-code  = p-contract-code " + " " + where-phrase-15) <> ""
          then  substitute(' X_c-contract.host-code = &1 and X_c-contract.contract-code = &2', p-host-code, p-contract-code) + " " + where-phrase-15
          else "true"
        )
      parameter-5-15 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-15 = if sort-phrase-15 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-15
        )
      parameter-7-15 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query brc-contract:handle
                          ,input logical(parameter-2-15)
                          ,input no-lock
                          ,input parameter-3-15
                          ,input parameter-4-15
                          ,input parameter-5-15
                          ,input parameter-6-15
                          ,input parameter-7-15
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
  REPOSITION brc-contract to recid v-doc-rec No-ERROR.
  if error-status:error then REPOSITION brc-contract to row 1 No-ERROR.
  else  REPOSITION brc-contract to row 7 No-ERROR.
  run proc-view-changes in this-procedure no-error.
END PROCEDURE.
PROCEDURE proc-view-changes :
  define buffer new_c-contract for ub.c-contract.
  define buffer current_contract for ub.contract.
  define variable v-chg-fields as character no-undo.
  define variable v-old-fields as character no-undo.
  define variable v-new-fields as character no-undo.
  define variable ii as integer no-undo.
  for each temp-changes:  delete temp-changes.  END.
  find first new_c-contract no-lock
    where new_c-contract.host-code     = X_c-contract.host-code
      and new_c-contract.contract-code = X_c-contract.contract-code
      and new_c-contract.chip-num      > X_c-contract.chip-num
    no-error.
  if not available new_c-contract then do:
    find first current_contract no-lock
      where current_contract.host-code = X_c-contract.host-code
       and current_contract.contract-code = X_c-contract.contract-code
    no-error.
    if not available current_contract then return error.
    buffer-compare current_contract to X_c-contract save result in v-chg-fields.
  end.
  else do:
    buffer-compare new_c-contract except chip-num corr-date corr-time corr-doc-code corr-user-name corr-user-db-num to X_c-contract save result in v-chg-fields.
  end.
    do ii = 1 to num-entries(v-chg-fields):
    CASE entry(ii, v-chg-fields):
                  when "contract-prn-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "contract-prn-code":U     temp-changes.l_name = "Номер"     temp-changes.v_old = string(X_c-contract.contract-prn-code)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.contract-prn-code)                               else string(current_contract.contract-prn-code))     .     end.
                  when "contract-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "contract-date":U     temp-changes.l_name = "Дата договора"     temp-changes.v_old = string(X_c-contract.contract-date)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.contract-date)                               else string(current_contract.contract-date))     .     end.
                  when "contract-type":U then do:     create temp-changes.     assign     temp-changes.f_name = "contract-type":U     temp-changes.l_name = "Тип договора"     temp-changes.v_old = string(X_c-contract.contract-type)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.contract-type)                               else string(current_contract.contract-type))     .     end.
                  when "str-uslov-oplat":U then do:     create temp-changes.     assign     temp-changes.f_name = "str-uslov-oplat":U     temp-changes.l_name = "Условия оплаты"     temp-changes.v_old = string(X_c-contract.str-uslov-oplat)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.str-uslov-oplat)                               else string(current_contract.str-uslov-oplat))     .     end.
                  when "usl-opl":U then do:     create temp-changes.     assign     temp-changes.f_name = "usl-opl":U     temp-changes.l_name = "Условия генерации"     temp-changes.v_old = string(X_c-contract.usl-opl)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.usl-opl)                               else string(current_contract.usl-opl))     .     end.
                  when "auto-pay":U then do:     create temp-changes.     assign     temp-changes.f_name = "auto-pay":U     temp-changes.l_name = "Статус генерации"     temp-changes.v_old = string(X_c-contract.auto-pay)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.auto-pay)                               else string(current_contract.auto-pay))     .     end.
                  when "srok-opl":U then do:     create temp-changes.     assign     temp-changes.f_name = "srok-opl":U     temp-changes.l_name = "Срок оплаты"     temp-changes.v_old = string(X_c-contract.srok-opl)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.srok-opl)                               else string(current_contract.srok-opl))     .     end.
                  when "status_":U then do:     create temp-changes.     assign     temp-changes.f_name = "status_":U     temp-changes.l_name = "Статус"     temp-changes.v_old = string(X_c-contract.status_)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.status_)                               else string(current_contract.status_))     .     end.
                  when "contract-name":U then do:     create temp-changes.     assign     temp-changes.f_name = "contract-name":U     temp-changes.l_name = "Наименование договора"     temp-changes.v_old = string(X_c-contract.contract-name)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.contract-name)                               else string(current_contract.contract-name))     .     end.
                  when "contract-city":U then do:     create temp-changes.     assign     temp-changes.f_name = "contract-city":U     temp-changes.l_name = "Город"     temp-changes.v_old = string(X_c-contract.contract-city)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.contract-city)                               else string(current_contract.contract-city))     .     end.
                  when "contract-date-beg":U then do:     create temp-changes.     assign     temp-changes.f_name = "contract-date-beg":U     temp-changes.l_name = "Дата начала договора"     temp-changes.v_old = string(X_c-contract.contract-date-beg)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.contract-date-beg)                               else string(current_contract.contract-date-beg))     .     end.
                  when "contract-date-end":U then do:     create temp-changes.     assign     temp-changes.f_name = "contract-date-end":U     temp-changes.l_name = "Дата конца договора"     temp-changes.v_old = string(X_c-contract.contract-date-end)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.contract-date-end)                               else string(current_contract.contract-date-end))     .     end.
                  when "curr-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "curr-code":U     temp-changes.l_name = "Код валюты"     temp-changes.v_old = string(X_c-contract.curr-code)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.curr-code)                               else string(current_contract.curr-code))     .     end.
                  when "own-name":U then do:     create temp-changes.     assign     temp-changes.f_name = "own-name":U     temp-changes.l_name = "Фирма"     temp-changes.v_old = string(X_c-contract.own-name)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.own-name)                               else string(current_contract.own-name))     .     end.
                  when "own-addres":U then do:     create temp-changes.     assign     temp-changes.f_name = "own-addres":U     temp-changes.l_name = "Фирма - Адрес"     temp-changes.v_old = string(X_c-contract.own-addres)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.own-addres)                               else string(current_contract.own-addres))     .     end.
                  when "own-inn":U then do:     create temp-changes.     assign     temp-changes.f_name = "own-inn":U     temp-changes.l_name = "Фирма - ИНН"     temp-changes.v_old = string(X_c-contract.own-inn)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.own-inn)                               else string(current_contract.own-inn))     .     end.
                  when "own-kpp":U then do:     create temp-changes.     assign     temp-changes.f_name = "own-kpp":U     temp-changes.l_name = "Фирма - КПП"     temp-changes.v_old = string(X_c-contract.own-kpp)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.own-kpp)                               else string(current_contract.own-kpp))     .     end.
                  when "own-bank-name":U then do:     create temp-changes.     assign     temp-changes.f_name = "own-bank-name":U     temp-changes.l_name = "Фирма - Банк"     temp-changes.v_old = string(X_c-contract.own-bank-name)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.own-bank-name)                               else string(current_contract.own-bank-name))     .     end.
                  when "own-bik":U then do:     create temp-changes.     assign     temp-changes.f_name = "own-bik":U     temp-changes.l_name = "Фирма - БИК банка"     temp-changes.v_old = string(X_c-contract.own-bik)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.own-bik)                               else string(current_contract.own-bik))     .     end.
                  when "own-r-schet":U then do:     create temp-changes.     assign     temp-changes.f_name = "own-r-schet":U     temp-changes.l_name = "Фирма - Рас.счет"     temp-changes.v_old = string(X_c-contract.own-r-schet)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.own-r-schet)                               else string(current_contract.own-r-schet))     .     end.
                  when "own-c-schet":U then do:     create temp-changes.     assign     temp-changes.f_name = "own-c-schet":U     temp-changes.l_name = "Фирма - Кор.счет"     temp-changes.v_old = string(X_c-contract.own-c-schet)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.own-c-schet)                               else string(current_contract.own-c-schet))     .     end.
                  when "own-sign-post":U then do:     create temp-changes.     assign     temp-changes.f_name = "own-sign-post":U     temp-changes.l_name = "Фирма - должность подпис-го лица"     temp-changes.v_old = string(X_c-contract.own-sign-post)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.own-sign-post)                               else string(current_contract.own-sign-post))     .     end.
                  when "own-sign-post":U then do:     create temp-changes.     assign     temp-changes.f_name = "own-sign-post":U     temp-changes.l_name = "Фирма - ФИО подпис-го лица"     temp-changes.v_old = string(X_c-contract.own-sign-post)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.own-sign-post)                               else string(current_contract.own-sign-post))     .     end.
                  when "own-code-schet":U then do:     create temp-changes.     assign     temp-changes.f_name = "own-code-schet":U     temp-changes.l_name = "Внутр. номер текущего счета фирмы"     temp-changes.v_old = string(X_c-contract.own-code-schet)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.own-code-schet)                               else string(current_contract.own-code-schet))     .     end.
                  when "cli-type":U then do:     create temp-changes.     assign     temp-changes.f_name = "cli-type":U     temp-changes.l_name = "Тип контрагента"     temp-changes.v_old = string(X_c-contract.cli-type)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cli-type)                               else string(current_contract.cli-type))     .     end.
                  when "cli-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "cli-code":U     temp-changes.l_name = "Код контрагента"     temp-changes.v_old = string(X_c-contract.cli-code)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cli-code)                               else string(current_contract.cli-code))     .     end.
                  when "cli-name":U then do:     create temp-changes.     assign     temp-changes.f_name = "cli-name":U     temp-changes.l_name = "Наименование контрагента"     temp-changes.v_old = string(X_c-contract.cli-name)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cli-name)                               else string(current_contract.cli-name))     .     end.
                  when "cli-addres":U then do:     create temp-changes.     assign     temp-changes.f_name = "cli-addres":U     temp-changes.l_name = "Адрес контрагента"     temp-changes.v_old = string(X_c-contract.cli-addres)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cli-addres)                               else string(current_contract.cli-addres))     .     end.
                  when "cli-inn":U then do:     create temp-changes.     assign     temp-changes.f_name = "cli-inn":U     temp-changes.l_name = "ИНН контрагента"     temp-changes.v_old = string(X_c-contract.cli-inn)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cli-inn)                               else string(current_contract.cli-inn))     .     end.
                  when "cli-kpp":U then do:     create temp-changes.     assign     temp-changes.f_name = "cli-kpp":U     temp-changes.l_name = "КПП контрагента"     temp-changes.v_old = string(X_c-contract.cli-kpp)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cli-kpp)                               else string(current_contract.cli-kpp))     .     end.
                  when "cli-bank-name":U then do:     create temp-changes.     assign     temp-changes.f_name = "cli-bank-name":U     temp-changes.l_name = "Банк контрагента"     temp-changes.v_old = string(X_c-contract.cli-bank-name)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cli-bank-name)                               else string(current_contract.cli-bank-name))     .     end.
                  when "cli-bik":U then do:     create temp-changes.     assign     temp-changes.f_name = "cli-bik":U     temp-changes.l_name = "БИК банка контрагента"     temp-changes.v_old = string(X_c-contract.cli-bik)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cli-bik)                               else string(current_contract.cli-bik))     .     end.
                  when "cli-r-schet":U then do:     create temp-changes.     assign     temp-changes.f_name = "cli-r-schet":U     temp-changes.l_name = "Рас.счет контрагента"     temp-changes.v_old = string(X_c-contract.cli-r-schet)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cli-r-schet)                               else string(current_contract.cli-r-schet))     .     end.
                  when "cli-c-schet":U then do:     create temp-changes.     assign     temp-changes.f_name = "cli-c-schet":U     temp-changes.l_name = "Кор.счет контрагента"     temp-changes.v_old = string(X_c-contract.cli-c-schet)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cli-c-schet)                               else string(current_contract.cli-c-schet))     .     end.
                  when "cli-sign-post":U then do:     create temp-changes.     assign     temp-changes.f_name = "cli-sign-post":U     temp-changes.l_name = "Контрагент - должность подпис-го лица"     temp-changes.v_old = string(X_c-contract.cli-sign-post)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cli-sign-post)                               else string(current_contract.cli-sign-post))     .     end.
                  when "cli-sign-post":U then do:     create temp-changes.     assign     temp-changes.f_name = "cli-sign-post":U     temp-changes.l_name = "Контрагент - ФИО подпис-го лица"     temp-changes.v_old = string(X_c-contract.cli-sign-post)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cli-sign-post)                               else string(current_contract.cli-sign-post))     .     end.
                  when "cli-code-schet":U then do:     create temp-changes.     assign     temp-changes.f_name = "cli-code-schet":U     temp-changes.l_name = "Внутр. номер тек. счета контрагента"     temp-changes.v_old = string(X_c-contract.cli-code-schet)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cli-code-schet)                               else string(current_contract.cli-code-schet))     .     end.
                  when "posr-type":U then do:     create temp-changes.     assign     temp-changes.f_name = "posr-type":U     temp-changes.l_name = "Тип посредника"     temp-changes.v_old = string(X_c-contract.posr-type)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.posr-type)                               else string(current_contract.posr-type))     .     end.
                  when "posr-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "posr-code":U     temp-changes.l_name = "Код посредника"     temp-changes.v_old = string(X_c-contract.posr-code)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.posr-code)                               else string(current_contract.posr-code))     .     end.
                  when "posr-name":U then do:     create temp-changes.     assign     temp-changes.f_name = "posr-name":U     temp-changes.l_name = "Наименование посредника"     temp-changes.v_old = string(X_c-contract.posr-name)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.posr-name)                               else string(current_contract.posr-name))     .     end.
                  when "posr-addres":U then do:     create temp-changes.     assign     temp-changes.f_name = "posr-addres":U     temp-changes.l_name = "Адрес посредника"     temp-changes.v_old = string(X_c-contract.posr-addres)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.posr-addres)                               else string(current_contract.posr-addres))     .     end.
                  when "posr-inn":U then do:     create temp-changes.     assign     temp-changes.f_name = "posr-inn":U     temp-changes.l_name = "ИНН посредника"     temp-changes.v_old = string(X_c-contract.posr-inn)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.posr-inn)                               else string(current_contract.posr-inn))     .     end.
                  when "posr-kpp":U then do:     create temp-changes.     assign     temp-changes.f_name = "posr-kpp":U     temp-changes.l_name = "КПП посредника"     temp-changes.v_old = string(X_c-contract.posr-kpp)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.posr-kpp)                               else string(current_contract.posr-kpp))     .     end.
                  when "posr-bank-name":U then do:     create temp-changes.     assign     temp-changes.f_name = "posr-bank-name":U     temp-changes.l_name = "Банк посредника"     temp-changes.v_old = string(X_c-contract.posr-bank-name)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.posr-bank-name)                               else string(current_contract.posr-bank-name))     .     end.
                  when "posr-bik":U then do:     create temp-changes.     assign     temp-changes.f_name = "posr-bik":U     temp-changes.l_name = "БИК банка посредника"     temp-changes.v_old = string(X_c-contract.posr-bik)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.posr-bik)                               else string(current_contract.posr-bik))     .     end.
                  when "posr-r-schet":U then do:     create temp-changes.     assign     temp-changes.f_name = "posr-r-schet":U     temp-changes.l_name = "Рас.счет посредника"     temp-changes.v_old = string(X_c-contract.posr-r-schet)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.posr-r-schet)                               else string(current_contract.posr-r-schet))     .     end.
                  when "posr-c-schet":U then do:     create temp-changes.     assign     temp-changes.f_name = "posr-c-schet":U     temp-changes.l_name = "Кор.счет посредника"     temp-changes.v_old = string(X_c-contract.posr-c-schet)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.posr-c-schet)                               else string(current_contract.posr-c-schet))     .     end.
                  when "posr-sign-post":U then do:     create temp-changes.     assign     temp-changes.f_name = "posr-sign-post":U     temp-changes.l_name = "посредник - должность подпис-го лица"     temp-changes.v_old = string(X_c-contract.posr-sign-post)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.posr-sign-post)                               else string(current_contract.posr-sign-post))     .     end.
                  when "posr-sign-post":U then do:     create temp-changes.     assign     temp-changes.f_name = "posr-sign-post":U     temp-changes.l_name = "посредник - ФИО подпис-го лица"     temp-changes.v_old = string(X_c-contract.posr-sign-post)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.posr-sign-post)                               else string(current_contract.posr-sign-post))     .     end.
                  when "posr-code-schet":U then do:     create temp-changes.     assign     temp-changes.f_name = "posr-code-schet":U     temp-changes.l_name = "Внутр. номер тек. счета посредника"     temp-changes.v_old = string(X_c-contract.posr-code-schet)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.posr-code-schet)                               else string(current_contract.posr-code-schet))     .     end.
                  when "agnt-type":U then do:     create temp-changes.     assign     temp-changes.f_name = "agnt-type":U     temp-changes.l_name = "Тип агента"     temp-changes.v_old = string(X_c-contract.agnt-type)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.agnt-type)                               else string(current_contract.agnt-type))     .     end.
                  when "agnt-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "agnt-code":U     temp-changes.l_name = "Код агента"     temp-changes.v_old = string(X_c-contract.agnt-code)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.agnt-code)                               else string(current_contract.agnt-code))     .     end.
                  when "agnt-name":U then do:     create temp-changes.     assign     temp-changes.f_name = "agnt-name":U     temp-changes.l_name = "Наименование агента"     temp-changes.v_old = string(X_c-contract.agnt-name)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.agnt-name)                               else string(current_contract.agnt-name))     .     end.
                  when "agnt-addres":U then do:     create temp-changes.     assign     temp-changes.f_name = "agnt-addres":U     temp-changes.l_name = "Адрес агента"     temp-changes.v_old = string(X_c-contract.agnt-addres)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.agnt-addres)                               else string(current_contract.agnt-addres))     .     end.
                  when "agnt-inn":U then do:     create temp-changes.     assign     temp-changes.f_name = "agnt-inn":U     temp-changes.l_name = "ИНН агента"     temp-changes.v_old = string(X_c-contract.agnt-inn)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.agnt-inn)                               else string(current_contract.agnt-inn))     .     end.
                  when "agnt-kpp":U then do:     create temp-changes.     assign     temp-changes.f_name = "agnt-kpp":U     temp-changes.l_name = "КПП агента"     temp-changes.v_old = string(X_c-contract.agnt-kpp)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.agnt-kpp)                               else string(current_contract.agnt-kpp))     .     end.
                  when "agnt-bank-name":U then do:     create temp-changes.     assign     temp-changes.f_name = "agnt-bank-name":U     temp-changes.l_name = "Банк агента"     temp-changes.v_old = string(X_c-contract.agnt-bank-name)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.agnt-bank-name)                               else string(current_contract.agnt-bank-name))     .     end.
                  when "agnt-bik":U then do:     create temp-changes.     assign     temp-changes.f_name = "agnt-bik":U     temp-changes.l_name = "БИК банка агента"     temp-changes.v_old = string(X_c-contract.agnt-bik)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.agnt-bik)                               else string(current_contract.agnt-bik))     .     end.
                  when "agnt-r-schet":U then do:     create temp-changes.     assign     temp-changes.f_name = "agnt-r-schet":U     temp-changes.l_name = "Рас.счет агента"     temp-changes.v_old = string(X_c-contract.agnt-r-schet)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.agnt-r-schet)                               else string(current_contract.agnt-r-schet))     .     end.
                  when "agnt-c-schet":U then do:     create temp-changes.     assign     temp-changes.f_name = "agnt-c-schet":U     temp-changes.l_name = "Кор.счет агента"     temp-changes.v_old = string(X_c-contract.agnt-c-schet)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.agnt-c-schet)                               else string(current_contract.agnt-c-schet))     .     end.
                  when "agnt-sign-post":U then do:     create temp-changes.     assign     temp-changes.f_name = "agnt-sign-post":U     temp-changes.l_name = "агент - должность подпис-го лица"     temp-changes.v_old = string(X_c-contract.agnt-sign-post)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.agnt-sign-post)                               else string(current_contract.agnt-sign-post))     .     end.
                  when "agnt-sign-post":U then do:     create temp-changes.     assign     temp-changes.f_name = "agnt-sign-post":U     temp-changes.l_name = "агент - ФИО подпис-го лица"     temp-changes.v_old = string(X_c-contract.agnt-sign-post)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.agnt-sign-post)                               else string(current_contract.agnt-sign-post))     .     end.
                  when "agnt-code-schet":U then do:     create temp-changes.     assign     temp-changes.f_name = "agnt-code-schet":U     temp-changes.l_name = "Внутр. номер тек. счета агента"     temp-changes.v_old = string(X_c-contract.agnt-code-schet)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.agnt-code-schet)                               else string(current_contract.agnt-code-schet))     .     end.
                  when "mngr-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "mngr-code":U     temp-changes.l_name = "Код исполнителя"     temp-changes.v_old = string(X_c-contract.mngr-code)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.mngr-code)                               else string(current_contract.mngr-code))     .     end.
                  when "doc-type":U then do:     create temp-changes.     assign     temp-changes.f_name = "doc-type":U     temp-changes.l_name = "Вид договора"     temp-changes.v_old = string(X_c-contract.doc-type)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.doc-type)                               else string(current_contract.doc-type))     .     end.
                  when "fin-VAT-pc":U then do:     create temp-changes.     assign     temp-changes.f_name = "fin-VAT-pc":U     temp-changes.l_name = "НДС"     temp-changes.v_old = string(X_c-contract.fin-VAT-pc)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.fin-VAT-pc)                               else string(current_contract.fin-VAT-pc))     .     end.
                  when "kredit-limit":U then do:     create temp-changes.     assign     temp-changes.f_name = "kredit-limit":U     temp-changes.l_name = "Ограничение кредита"     temp-changes.v_old = string(X_c-contract.kredit-limit)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.kredit-limit)                               else string(current_contract.kredit-limit))     .     end.
                  when "kredit-sum":U then do:     create temp-changes.     assign     temp-changes.f_name = "kredit-sum":U     temp-changes.l_name = "Сумма кредита"     temp-changes.v_old = string(X_c-contract.kredit-sum)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.kredit-sum)                               else string(current_contract.kredit-sum))     .     end.
                  when "usl-opl":U then do:     create temp-changes.     assign     temp-changes.f_name = "usl-opl":U     temp-changes.l_name = "Условия оплаты ФО"     temp-changes.v_old = string(X_c-contract.usl-opl)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.usl-opl)                               else string(current_contract.usl-opl))     .     end.
                  when "srok-opl":U then do:     create temp-changes.     assign     temp-changes.f_name = "srok-opl":U     temp-changes.l_name = "Срок оплаты ФО"     temp-changes.v_old = string(X_c-contract.srok-opl)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.srok-opl)                               else string(current_contract.srok-opl))     .     end.
                  when "gen-factur-srok":U then do:     create temp-changes.     assign     temp-changes.f_name = "gen-factur-srok":U     temp-changes.l_name = "Срок генерации счет-фактур"     temp-changes.v_old = string(X_c-contract.gen-factur-srok)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.gen-factur-srok)                               else string(current_contract.gen-factur-srok))     .     end.
                  when "gen-factur-srok":U then do:     create temp-changes.     assign     temp-changes.f_name = "gen-factur-srok":U     temp-changes.l_name = "Конечный статус сгенеренного счета-фактуры"     temp-changes.v_old = string(X_c-contract.gen-factur-srok)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.gen-factur-srok)                               else string(current_contract.gen-factur-srok))     .     end.
                  when "fin-SLT-pc":U then do:     create temp-changes.     assign     temp-changes.f_name = "fin-SLT-pc":U     temp-changes.l_name = "НП"     temp-changes.v_old = string(X_c-contract.fin-SLT-pc)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.fin-SLT-pc)                               else string(current_contract.fin-SLT-pc))     .     end.
                  when "pay-nal":U then do:     create temp-changes.     assign     temp-changes.f_name = "pay-nal":U     temp-changes.l_name = "нал"     temp-changes.v_old = string(X_c-contract.pay-nal)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.pay-nal)                               else string(current_contract.pay-nal))     .     end.
                  when "cor-acc-out":U then do:     create temp-changes.     assign     temp-changes.f_name = "cor-acc-out":U     temp-changes.l_name = "Кор.счет РПП"     temp-changes.v_old = string(X_c-contract.cor-acc-out)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cor-acc-out)                               else string(current_contract.cor-acc-out))     .     end.
                  when "an-uchet-code-out":U then do:     create temp-changes.     assign     temp-changes.f_name = "an-uchet-code-out":U     temp-changes.l_name = "Код аналит. учета РПП"     temp-changes.v_old = string(X_c-contract.an-uchet-code-out)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.an-uchet-code-out)                               else string(current_contract.an-uchet-code-out))     .     end.
                  when "cel-nazn-code-out":U then do:     create temp-changes.     assign     temp-changes.f_name = "cel-nazn-code-out":U     temp-changes.l_name = "Код целев. назн. РПП"     temp-changes.v_old = string(X_c-contract.cel-nazn-code-out)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cel-nazn-code-out)                               else string(current_contract.cel-nazn-code-out))     .     end.
                  when "cor-acc1-out":U then do:     create temp-changes.     assign     temp-changes.f_name = "cor-acc1-out":U     temp-changes.l_name = "Касса РПП"     temp-changes.v_old = string(X_c-contract.cor-acc1-out)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cor-acc1-out)                               else string(current_contract.cor-acc1-out))     .     end.
                  when "cor-acc-in":U then do:     create temp-changes.     assign     temp-changes.f_name = "cor-acc-in":U     temp-changes.l_name = "Кор.счет ППП"     temp-changes.v_old = string(X_c-contract.cor-acc-in)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cor-acc-in)                               else string(current_contract.cor-acc-in))     .     end.
                  when "an-uchet-code-in":U then do:     create temp-changes.     assign     temp-changes.f_name = "an-uchet-code-in":U     temp-changes.l_name = "Код аналит. учета ППП"     temp-changes.v_old = string(X_c-contract.an-uchet-code-in)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.an-uchet-code-in)                               else string(current_contract.an-uchet-code-in))     .     end.
                  when "cel-nazn-code-in":U then do:     create temp-changes.     assign     temp-changes.f_name = "cel-nazn-code-in":U     temp-changes.l_name = "Код целев. назн. ППП"     temp-changes.v_old = string(X_c-contract.cel-nazn-code-in)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cel-nazn-code-in)                               else string(current_contract.cel-nazn-code-in))     .     end.
                  when "cor-acc1-in":U then do:     create temp-changes.     assign     temp-changes.f_name = "cor-acc1-in":U     temp-changes.l_name = "Касса ППП"     temp-changes.v_old = string(X_c-contract.cor-acc1-in)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cor-acc1-in)                               else string(current_contract.cor-acc1-in))     .     end.
                  when "cor-acc-out":U then do:     create temp-changes.     assign     temp-changes.f_name = "cor-acc-out":U     temp-changes.l_name = "Кор.счет РКО"     temp-changes.v_old = string(X_c-contract.cor-acc-out)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cor-acc-out)                               else string(current_contract.cor-acc-out))     .     end.
                  when "an-uchet-code-out":U then do:     create temp-changes.     assign     temp-changes.f_name = "an-uchet-code-out":U     temp-changes.l_name = "Код аналит. учета РКО"     temp-changes.v_old = string(X_c-contract.an-uchet-code-out)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.an-uchet-code-out)                               else string(current_contract.an-uchet-code-out))     .     end.
                  when "cel-nazn-code-out":U then do:     create temp-changes.     assign     temp-changes.f_name = "cel-nazn-code-out":U     temp-changes.l_name = "Код целев. назн. РКО"     temp-changes.v_old = string(X_c-contract.cel-nazn-code-out)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cel-nazn-code-out)                               else string(current_contract.cel-nazn-code-out))     .     end.
                  when "cor-acc1-out":U then do:     create temp-changes.     assign     temp-changes.f_name = "cor-acc1-out":U     temp-changes.l_name = "Касса РКО"     temp-changes.v_old = string(X_c-contract.cor-acc1-out)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cor-acc1-out)                               else string(current_contract.cor-acc1-out))     .     end.
                  when "cor-acc-in":U then do:     create temp-changes.     assign     temp-changes.f_name = "cor-acc-in":U     temp-changes.l_name = "Кор.счет ПКО"     temp-changes.v_old = string(X_c-contract.cor-acc-in)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cor-acc-in)                               else string(current_contract.cor-acc-in))     .     end.
                  when "an-uchet-code-in":U then do:     create temp-changes.     assign     temp-changes.f_name = "an-uchet-code-in":U     temp-changes.l_name = "Код аналит. учета ПКО"     temp-changes.v_old = string(X_c-contract.an-uchet-code-in)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.an-uchet-code-in)                               else string(current_contract.an-uchet-code-in))     .     end.
                  when "cel-nazn-code-in":U then do:     create temp-changes.     assign     temp-changes.f_name = "cel-nazn-code-in":U     temp-changes.l_name = "Код целев. назн. ПКО"     temp-changes.v_old = string(X_c-contract.cel-nazn-code-in)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cel-nazn-code-in)                               else string(current_contract.cel-nazn-code-in))     .     end.
                  when "cor-acc1-in":U then do:     create temp-changes.     assign     temp-changes.f_name = "cor-acc1-in":U     temp-changes.l_name = "Касса ПКО"     temp-changes.v_old = string(X_c-contract.cor-acc1-in)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cor-acc1-in)                               else string(current_contract.cor-acc1-in))     .     end.
                  when "cor-acc-out":U then do:     create temp-changes.     assign     temp-changes.f_name = "cor-acc-out":U     temp-changes.l_name = "Кор.счет Р.АПЗ"     temp-changes.v_old = string(X_c-contract.cor-acc-out)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cor-acc-out)                               else string(current_contract.cor-acc-out))     .     end.
                  when "an-uchet-code-out":U then do:     create temp-changes.     assign     temp-changes.f_name = "an-uchet-code-out":U     temp-changes.l_name = "Код аналит. учета Р.АПЗ"     temp-changes.v_old = string(X_c-contract.an-uchet-code-out)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.an-uchet-code-out)                               else string(current_contract.an-uchet-code-out))     .     end.
                  when "cel-nazn-code-out":U then do:     create temp-changes.     assign     temp-changes.f_name = "cel-nazn-code-out":U     temp-changes.l_name = "Код целев. назн. Р.АПЗ"     temp-changes.v_old = string(X_c-contract.cel-nazn-code-out)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cel-nazn-code-out)                               else string(current_contract.cel-nazn-code-out))     .     end.
                  when "cor-acc1-out":U then do:     create temp-changes.     assign     temp-changes.f_name = "cor-acc1-out":U     temp-changes.l_name = "Касса Р.АПЗ"     temp-changes.v_old = string(X_c-contract.cor-acc1-out)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cor-acc1-out)                               else string(current_contract.cor-acc1-out))     .     end.
                  when "cor-acc-in":U then do:     create temp-changes.     assign     temp-changes.f_name = "cor-acc-in":U     temp-changes.l_name = "Кор.счет П.АПЗ"     temp-changes.v_old = string(X_c-contract.cor-acc-in)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cor-acc-in)                               else string(current_contract.cor-acc-in))     .     end.
                  when "an-uchet-code-in":U then do:     create temp-changes.     assign     temp-changes.f_name = "an-uchet-code-in":U     temp-changes.l_name = "Код аналит. учета П.АПЗ"     temp-changes.v_old = string(X_c-contract.an-uchet-code-in)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.an-uchet-code-in)                               else string(current_contract.an-uchet-code-in))     .     end.
                  when "cel-nazn-code-in":U then do:     create temp-changes.     assign     temp-changes.f_name = "cel-nazn-code-in":U     temp-changes.l_name = "Код целев. назн. П.АПЗ"     temp-changes.v_old = string(X_c-contract.cel-nazn-code-in)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cel-nazn-code-in)                               else string(current_contract.cel-nazn-code-in))     .     end.
                  when "cor-acc1-in":U then do:     create temp-changes.     assign     temp-changes.f_name = "cor-acc1-in":U     temp-changes.l_name = "Касса П.АПЗ"     temp-changes.v_old = string(X_c-contract.cor-acc1-in)     temp-changes.v_new = (if available new_c-contract                               then string(new_c-contract.cor-acc1-in)                               else string(current_contract.cor-acc1-in))     .     end.
    END CASE.
  end.
  Open QUery br-changes for each temp-changes.
END PROCEDURE.
FUNCTION get-agent RETURNS CHARACTER
  ( input agnt-type as character , input agnt-code as integer ) :
define variable var-cli-name as character no-undo.
define buffer buf_clients for ub.clients.
  find first buf_clients no-lock where buf_clients.obj-type = agnt-type and buf_clients.obj-code = agnt-code no-error .
  if available buf_clients then assign var-cli-name = STRING (agnt-code) + "   " + TRIM (buf_clients.obj-name) .
  RETURN var-cli-name.
END FUNCTION.
FUNCTION get-currency RETURNS CHARACTER
  ( input curr-code as integer ) :
define variable var-curr-name as character no-undo.
define buffer buf_currency for ub.currency.
  find first buf_currency no-lock where buf_currency.curr-code = curr-code no-error .
  if available buf_currency then assign var-curr-name = buf_currency.curr-abbr .
RETURN var-curr-name.
END FUNCTION.
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid, input mark-list as character) :
RETURN ( IF LOOKUP( STRING( par-recid ), mark-list ) > 0 THEN "*" ELSE "":U ).
END FUNCTION.
