DEFINE NEW SHARED BUFFER X_c-schet-fact-doc FOR ub.c-schet-fact-doc.
DEFINE BUFFER X_schet-fact-doc FOR ub.schet-fact-doc.
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-host-code    as integer   no-undo .
define input parameter p-doc-code as character no-undo .
define variable vss-revision    as character no-undo initial "$revision: 6 $":u.
define variable vss-author      as character no-undo initial "$author: mkochetkov $":u.
define variable vss-date        as character no-undo initial "$date: 12.04.06 14:35 $":u.
define variable vss-workfile    as character no-undo initial "$workfile: s-f-hist.w $":u.
define variable vss-archive     as character no-undo initial "$archive: /ver15_0/str/s-f-hist.w $":u.
define variable vss-description as character no-undo initial "Список истории счетов-фактур":u.
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
define variable  p-rid-list    as  character no-undo .
define variable  bttns  as character   no-undo .
define variable filter-point as character no-undo initial "Список истории счетов-фактур" .
define variable filter-point0 as character no-undo initial "Список истории счетов-фактур" .
define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable title0 as character no-undo.
define temp-table temp-changes no-undo
  field f_name as character
  field l_name as character
  field v_old as character
  field v_new as character
index pi is unique primary f_name.
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
DEFINE QUERY br-c-schet-fact-doc FOR X_c-schet-fact-doc SCROLLING.
DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.
DEFINE BROWSE br-c-schet-fact-doc
  QUERY br-c-schet-fact-doc DISPLAY
      (mark-string(recid(X_c-schet-fact-doc), p-rid-list)) COLUMN-LABEL "*" FORMAT "x(1)"
      X_c-schet-fact-doc.corr-date                    COLUMN-LABEL "Дата!изменения"  FORMAT "99/99/99"
      string(X_c-schet-fact-doc.corr-time,"HH:MM")    COLUMN-LABEL "Время!изменения" FORMAT "X(5)"
      usrfulnf(X_c-schet-fact-doc.corr-user-name)     COLUMN-LABEL "Оператор"        FORMAT "X(18)"
      X_c-schet-fact-doc.doc-code                     COLUMN-LABEL "Номер"           FORMAT "X(16)"
      X_c-schet-fact-doc.doc-date                     COLUMN-LABEL "Дата"  FORMAT "99/99/99"
      X_c-schet-fact-doc.status_                      COLUMN-LABEL "Статус"          FORMAT "X(4)"
      string( X_c-schet-fact-doc.cli-type + ' ' + string(X_c-schet-fact-doc.cli-code)) COLUMN-LABEL "Тип/код!контрагента" FORMAT "x(10)"
      X_c-schet-fact-doc.cli-name                     COLUMN-LABEL "Контрагент"      FORMAT "x(40)"
      X_c-schet-fact-doc.sum-rubl                     COLUMN-LABEL "Сумма"           FORMAT ">>>,>>>,>>>,>>>,>>>.<<"
      X_c-schet-fact-doc.ext-doc-type                 COLUMN-LABEL "Тип"    FORMAT "X(3)"
      X_c-schet-fact-doc.in-doc-code                  COLUMN-LABEL "По док-ту"  FORMAT "X(12)"
      X_c-schet-fact-doc.contract-code                COLUMN-LABEL "Вн.№ договора"  FORMAT ">>>>>>>>>>9"
    ENABLE
      X_c-schet-fact-doc.doc-code
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
     br-c-schet-fact-doc AT ROW 2 COL 1.38
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
       br-c-schet-fact-doc:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 1.
ON ENDKEY OF FRAME Dialog-Frame
DO:
    run gbl/markqwa.p ( input b-mark:sensitive, input p-rid-list) no-error.
    if error-status:error then return no-apply.
END.
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame
DO:
  define variable g-log  as logical   no-undo .
  if not available X_c-schet-fact-doc then return no-apply.
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_schet-fact-doc_update':U
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
  run str/s-f-doc.w (input parparentproc,input p-host-code, input X_c-schet-fact-doc.db-num, 'ПРОСМОТР':U, input X_c-schet-fact-doc.doc-code, input X_c-schet-fact-doc.chip-num) .
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo .
  if available X_c-schet-fact-doc then do:
      if can-do( p-rid-list, string( recid( X_c-schet-fact-doc ) ) ) then do:
          p-rid-list = replace( p-rid-list, chr(44) + string( recid( X_c-schet-fact-doc ) ), "") .
          p-rid-list = replace( p-rid-list, string( recid( X_c-schet-fact-doc ) ) + chr(44), "") .
          p-rid-list = replace( p-rid-list, string( recid( X_c-schet-fact-doc ) ), "") .
      end.
      else
      p-rid-list = p-rid-list + ( if p-rid-list = "" then "" else chr(44) ) + string( recid( X_c-schet-fact-doc ) ) .
      loc#log = br-c-schet-fact-doc:refresh() .
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          loc#log = br-c-schet-fact-doc:select-next-row ().
          apply "VALUE-CHANGED" to br-c-schet-fact-doc in frame Dialog-Frame.
      end.
      if num-entries( p-rid-list ) = 0 then hide mark-num in frame Dialog-Frame.
      else disp num-entries( p-rid-list ) @ mark-num with frame Dialog-Frame.
  end.
  apply "entry" to br-c-schet-fact-doc in frame Dialog-Frame.
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
  assign
    tbl = 'c-schet-fact-doc'
    join-tbl = 'X_c-schet-fact-doc'
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
  .
  run fltfield-add in this-procedure('doc-code', '', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('doc-date', '', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('host-code', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-code', 'Вн.Номер', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('doc-type', '', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('base-rate', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('base-scale', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('PS',         '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('book-code', 'Номер в книге', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-address', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-inn', '', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('own-name', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-address', 'Адрес поставщика', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-inn', 'ИНН  поставщика', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-type', 'Тип  поставщика', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-code', 'Код  поставщика', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-name', 'Имя  поставщика', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('Gruz-otprav', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('Gruz-poluch', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('ext-doc-type', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('gtd', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('country', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('in-date', 'Дата прихода', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('in-doc-code', 'Номер док-та прих.', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('in-doc-date', 'Дата док-та прих.', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('obj-code', '', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('obj-type', '', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('pay-date', 'Дата платежа', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('status_', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('user-db-num', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('user-name', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sys-date', 'Сист. дата', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sys-time', 'Сист. время', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-date', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-time', '', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-user-db-num', 'Польз. база факт', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-user-name', 'Польз. факт', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sum-rubl', 'сумма руб', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sum-base', 'сумма б.в.', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
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
  if ( available X_c-schet-fact-doc ) AND ( p-rid-list = "" ) then  p-rid-list = string( recid( X_c-schet-fact-doc ) ) .
END.
ON RETURN OF br-c-schet-fact-doc IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-c-schet-fact-doc IN FRAME Dialog-Frame
DO:
  if b-sel:sensitive in frame Dialog-Frame then
    if b-mark:sensitive then apply "choose" to b-mark in frame Dialog-Frame.
    else                     apply "choose" to b-sel in frame Dialog-Frame.
  else if b-lookup:sensitive then apply "choose" to b-lookup in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF br-c-schet-fact-doc IN FRAME Dialog-Frame
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
        v-diasize-browse-handle     = browse br-c-schet-fact-doc :handle
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
def var sort-labelbr-c-schet-fact-doc   as character no-undo .
def var sort-clmnbr-c-schet-fact-doc    as handle    no-undo .
def var cur-clmnbr-c-schet-fact-doc     as handle    no-undo .
def var cur-clmn-locbr-c-schet-fact-doc as integer   no-undo .
def var re-querybr-c-schet-fact-doc     as logical   initial no no-undo .
on start-search, ctrl-o of br-c-schet-fact-doc in frame Dialog-Frame do:
   run sort-brbr-c-schet-fact-doc
     (input (if available X_c-schet-fact-doc
             then recid(X_c-schet-fact-doc)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-c-schet-fact-doc :
  define input parameter p-recid as recid no-undo .
  if re-querybr-c-schet-fact-doc = no then do:
    assign
       cur-clmnbr-c-schet-fact-doc = br-c-schet-fact-doc:current-column in frame Dialog-Frame
    .
    if sort-clmnbr-c-schet-fact-doc <> ? then sort-clmnbr-c-schet-fact-doc:column-fgcolor = 0.
    if cur-clmnbr-c-schet-fact-doc = sort-clmnbr-c-schet-fact-doc then do:
      assign
         sort-labelbr-c-schet-fact-doc = ""
         sort-clmnbr-c-schet-fact-doc = ?
      .
     end.
     else do:
       assign
         sort-labelbr-c-schet-fact-doc = cur-clmnbr-c-schet-fact-doc:label
         sort-clmnbr-c-schet-fact-doc  = cur-clmnbr-c-schet-fact-doc
         sort-clmnbr-c-schet-fact-doc:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-c-schet-fact-doc = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-c-schet-fact-doc:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-c-schet-fact-doc then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-c-schet-fact-doc = cur-clmn-locbr-c-schet-fact-doc + 1
    .
  end.
  case sort-labelbr-c-schet-fact-doc:
        when X_c-schet-fact-doc.doc-code:label in browse br-c-schet-fact-doc then DO:    assign       sort-column-name = "X_c-schet-fact-doc.doc-code"     .     run OpenBr(yes, no, no).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr(yes, no, no).
      if sort-labelbr-c-schet-fact-doc <> "" then do:
        assign
          cur-clmnbr-c-schet-fact-doc:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-c-schet-fact-doc = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-c-schet-fact-doc to recid p-recid no-error.
    apply "value-changed" to br-c-schet-fact-doc in frame Dialog-Frame.
  end.
  apply "entry" to br-c-schet-fact-doc in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-c-schet-fact-doc:
if cur-clmnbr-c-schet-fact-doc = ? then do:
   run OpenBr(yes, no, no).
end.
else do:
   assign re-querybr-c-schet-fact-doc = yes.
   run sort-brbr-c-schet-fact-doc
     (input (if available X_c-schet-fact-doc
             then recid(X_c-schet-fact-doc)
             else ?
            )
     ).
   assign re-querybr-c-schet-fact-doc = no.
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
  find first X_schet-fact-doc no-lock  where X_schet-fact-doc.host-code = p-host-code and X_schet-fact-doc.doc-code = p-doc-code no-error .
  if not available X_schet-fact-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-host-code и/или p-doc-code"  p-host-code p-doc-code
    view-as alert-box ERROR.
    return.
  end.
  assign
    br-c-schet-fact-doc:num-locked-columns = 1
    X_c-schet-fact-doc.doc-code:read-only in browse br-c-schet-fact-doc = yes
  .
  find first ub.clients no-lock where ub.clients.obj-code = p-host-code and ub.clients.obj-type = 'орг':U .
  title0 = "Список истории счетов-фактур" + chr(32)  + substitute(" Фирма: (&1) &2 Cчет-фактура : &3 от &4", p-host-code, ub.clients.obj-name,  X_schet-fact-doc.doc-code, string(X_schet-fact-doc.doc-date,"99/99/9999")) .
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
  ENABLE b-quit b-sel B-lookup B-sch B-Help br-c-schet-fact-doc BR-changes mark-num    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
  DISPLAY mark-num WITH FRAME Dialog-Frame.
  ENABLE  b-quit  B-lookup  b-sel  B-mark  B-sch  B-Help  mark-num  br-c-schet-fact-doc  BR-changes WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE OpenBr :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  define variable l-query-was-opened as logical no-undo .
  define variable sort-column-phrase as character no-undo .
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
                              "FOR EACH X_c-schet-fact-doc"
      parameter-4-15 =
        (
          if (" X_c-schet-fact-doc.host-code = p-host-code AND X_c-schet-fact-doc.doc-code  = p-doc-code " + " " + where-phrase-15) <> ""
          then  substitute(' X_c-schet-fact-doc.host-code = &1 AND X_c-schet-fact-doc.doc-code = &3&2&3 ', p-host-code, p-doc-code, chr(34))  + " " + where-phrase-15
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
          (" X_c-schet-fact-doc.host-code = p-host-code AND X_c-schet-fact-doc.doc-code  = p-doc-code " + " " + where-phrase-15 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-c-schet-fact-doc:handle
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
    OPEN QUERY br-c-schet-fact-doc FOR EACH X_c-schet-fact-doc
      where  X_c-schet-fact-doc.host-code = p-host-code AND X_c-schet-fact-doc.doc-code  = p-doc-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_c-schet-fact-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-c-schet-fact-doc:handle:get-buffer-handle(1) = (buffer X_c-schet-fact-doc:handle) then do:
      assign
      parameter-2-15 = (if p-find-next then "true":u else "false":u )
      parameter-4-15 =
        "where ":u +  substitute(' X_c-schet-fact-doc.host-code = &1 AND X_c-schet-fact-doc.doc-code = &3&2&3 ', p-host-code, p-doc-code, chr(34))  + " ":u + where-phrase-15 + " ":u + p-find-condition + " " + ""
      parameter-5-15 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-c-schet-fact-doc:handle
                          ,input rowid(X_c-schet-fact-doc)
                          ,input logical(parameter-2-15)
                          ,input no-lock
                          ,input (buffer X_c-schet-fact-doc:handle)
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
      parameter-3-15 =  "FOR EACH X_c-schet-fact-doc"
      parameter-4-15 =
        (
          if (" X_c-schet-fact-doc.host-code = p-host-code AND X_c-schet-fact-doc.doc-code  = p-doc-code " + " " + where-phrase-15) <> ""
          then  substitute(' X_c-schet-fact-doc.host-code = &1 AND X_c-schet-fact-doc.doc-code = &3&2&3 ', p-host-code, p-doc-code, chr(34))  + " " + where-phrase-15
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
                          ,input query br-c-schet-fact-doc:handle
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
  REPOSITION br-c-schet-fact-doc to recid v-doc-rec No-ERROR.
  if error-status:error then REPOSITION br-c-schet-fact-doc to row 1 No-ERROR.
  else  REPOSITION br-c-schet-fact-doc to row 7 No-ERROR.
  run proc-view-changes in this-procedure no-error.
END PROCEDURE.
PROCEDURE proc-view-changes :
  define buffer new_c-schet-fact-doc for ub.c-schet-fact-doc.
  define buffer current_schet-fact-doc for ub.schet-fact-doc.
  define variable v-chg-fields as character no-undo.
  define variable v-old-fields as character no-undo.
  define variable v-new-fields as character no-undo.
  define variable ii as integer no-undo.
  for each temp-changes:  delete temp-changes.  END.
  find first new_c-schet-fact-doc no-lock
    where new_c-schet-fact-doc.host-code     = X_c-schet-fact-doc.host-code
      and new_c-schet-fact-doc.doc-code = X_c-schet-fact-doc.doc-code
      and new_c-schet-fact-doc.chip-num      > X_c-schet-fact-doc.chip-num
    no-error.
  if not available new_c-schet-fact-doc then do:
    find first current_schet-fact-doc no-lock
      where current_schet-fact-doc.host-code = X_c-schet-fact-doc.host-code
       and current_schet-fact-doc.doc-code = x_c-schet-fact-doc.doc-code
    no-error.
    if not available current_schet-fact-doc then return error.
    buffer-compare current_schet-fact-doc to X_c-schet-fact-doc save result in v-chg-fields.
  end.
  else do:
    buffer-compare new_c-schet-fact-doc except chip-num corr-date corr-time corr-user-name corr-user-db-num to X_c-schet-fact-doc save result in v-chg-fields.
  end.
    do ii = 1 to num-entries(v-chg-fields):
    CASE entry(ii, v-chg-fields):
                  when "doc-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "doc-code":U     temp-changes.l_name = "Номер"     temp-changes.v_old = string(X_c-schet-fact-doc.doc-code)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.doc-code)                               else string(current_schet-fact-doc.doc-code))     .     end.
                  when "contract-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "contract-code":U     temp-changes.l_name = "Код договора"     temp-changes.v_old = string(X_c-schet-fact-doc.contract-code)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.contract-code)                               else string(current_schet-fact-doc.contract-code))     .     end.
                  when "doc-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "doc-date":U     temp-changes.l_name = "Дата"     temp-changes.v_old = string(X_c-schet-fact-doc.doc-date)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.doc-date)                               else string(current_schet-fact-doc.doc-date))     .     end.
                  when "ext-doc-type":U then do:     create temp-changes.     assign     temp-changes.f_name = "ext-doc-type":U     temp-changes.l_name = "Тип"     temp-changes.v_old = string(X_c-schet-fact-doc.ext-doc-type)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.ext-doc-type)                               else string(current_schet-fact-doc.ext-doc-type))     .     end.
                  when "status_":U then do:     create temp-changes.     assign     temp-changes.f_name = "status_":U     temp-changes.l_name = "Статус"     temp-changes.v_old = string(X_c-schet-fact-doc.status_)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.status_)                               else string(current_schet-fact-doc.status_))     .     end.
                  when "curr-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "curr-code":U     temp-changes.l_name = "Код валюты"     temp-changes.v_old = string(X_c-schet-fact-doc.curr-code)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.curr-code)                               else string(current_schet-fact-doc.curr-code))     .     end.
                  when "own-name":U then do:     create temp-changes.     assign     temp-changes.f_name = "own-name":U     temp-changes.l_name = "Фирма"     temp-changes.v_old = string(X_c-schet-fact-doc.own-name)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.own-name)                               else string(current_schet-fact-doc.own-name))     .     end.
                  when "own-address":U then do:     create temp-changes.     assign     temp-changes.f_name = "own-address":U     temp-changes.l_name = "Фирма - Адрес"     temp-changes.v_old = string(X_c-schet-fact-doc.own-address)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.own-address)                               else string(current_schet-fact-doc.own-address))     .     end.
                  when "own-inn":U then do:     create temp-changes.     assign     temp-changes.f_name = "own-inn":U     temp-changes.l_name = "Фирма - ИНН"     temp-changes.v_old = string(X_c-schet-fact-doc.own-inn)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.own-inn)                               else string(current_schet-fact-doc.own-inn))     .     end.
                  when "cli-type":U then do:     create temp-changes.     assign     temp-changes.f_name = "cli-type":U     temp-changes.l_name = "Тип контрагента"     temp-changes.v_old = string(X_c-schet-fact-doc.cli-type)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.cli-type)                               else string(current_schet-fact-doc.cli-type))     .     end.
                  when "cli-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "cli-code":U     temp-changes.l_name = "Код контрагента"     temp-changes.v_old = string(X_c-schet-fact-doc.cli-code)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.cli-code)                               else string(current_schet-fact-doc.cli-code))     .     end.
                  when "cli-name":U then do:     create temp-changes.     assign     temp-changes.f_name = "cli-name":U     temp-changes.l_name = "Наименование контрагента"     temp-changes.v_old = string(X_c-schet-fact-doc.cli-name)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.cli-name)                               else string(current_schet-fact-doc.cli-name))     .     end.
                  when "cli-address":U then do:     create temp-changes.     assign     temp-changes.f_name = "cli-address":U     temp-changes.l_name = "Адрес контрагента"     temp-changes.v_old = string(X_c-schet-fact-doc.cli-address)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.cli-address)                               else string(current_schet-fact-doc.cli-address))     .     end.
                  when "cli-inn":U then do:     create temp-changes.     assign     temp-changes.f_name = "cli-inn":U     temp-changes.l_name = "ИНН контрагента"     temp-changes.v_old = string(X_c-schet-fact-doc.cli-inn)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.cli-inn)                               else string(current_schet-fact-doc.cli-inn))     .     end.
                  when "base-rate":U then do:     create temp-changes.     assign     temp-changes.f_name = "base-rate":U     temp-changes.l_name = "Курс валюты"     temp-changes.v_old = string(X_c-schet-fact-doc.base-rate)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.base-rate)                               else string(current_schet-fact-doc.base-rate))     .     end.
                  when "base-scale":U then do:     create temp-changes.     assign     temp-changes.f_name = "base-scale":U     temp-changes.l_name = "Масштаб валюты"     temp-changes.v_old = string(X_c-schet-fact-doc.base-scale)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.base-scale)                               else string(current_schet-fact-doc.base-scale))     .     end.
                  when "PS":U then do:     create temp-changes.     assign     temp-changes.f_name = "PS":U     temp-changes.l_name = "Примечания"     temp-changes.v_old = string(X_c-schet-fact-doc.PS)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.PS)                               else string(current_schet-fact-doc.PS))     .     end.
                  when "book-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "book-code":U     temp-changes.l_name = "Номер в книге"     temp-changes.v_old = string(X_c-schet-fact-doc.book-code)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.book-code)                               else string(current_schet-fact-doc.book-code))     .     end.
                  when "Gruz-otprav":U then do:     create temp-changes.     assign     temp-changes.f_name = "Gruz-otprav":U     temp-changes.l_name = "Грузоотправитель"     temp-changes.v_old = string(X_c-schet-fact-doc.Gruz-otprav)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.Gruz-otprav)                               else string(current_schet-fact-doc.Gruz-otprav))     .     end.
                  when "Gruz-poluch":U then do:     create temp-changes.     assign     temp-changes.f_name = "Gruz-poluch":U     temp-changes.l_name = "Грузополучатель"     temp-changes.v_old = string(X_c-schet-fact-doc.Gruz-poluch)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.Gruz-poluch)                               else string(current_schet-fact-doc.Gruz-poluch))     .     end.
                  when "gtd":U then do:     create temp-changes.     assign     temp-changes.f_name = "gtd":U     temp-changes.l_name = "ГТД"     temp-changes.v_old = string(X_c-schet-fact-doc.gtd)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.gtd)                               else string(current_schet-fact-doc.gtd))     .     end.
                  when "country":U then do:     create temp-changes.     assign     temp-changes.f_name = "country":U     temp-changes.l_name = "Страна"     temp-changes.v_old = string(X_c-schet-fact-doc.country)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.country)                               else string(current_schet-fact-doc.country))     .     end.
                  when "in-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "in-date":U     temp-changes.l_name = "Дата прихода"     temp-changes.v_old = string(X_c-schet-fact-doc.in-date)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.in-date)                               else string(current_schet-fact-doc.in-date))     .     end.
                  when "in-doc-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "in-doc-code":U     temp-changes.l_name = "Номер док-та прихода"     temp-changes.v_old = string(X_c-schet-fact-doc.in-doc-code)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.in-doc-code)                               else string(current_schet-fact-doc.in-doc-code))     .     end.
                  when "in-doc-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "in-doc-date":U     temp-changes.l_name = "Дата док-та прихода"     temp-changes.v_old = string(X_c-schet-fact-doc.in-doc-date)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.in-doc-date)                               else string(current_schet-fact-doc.in-doc-date))     .     end.
                  when "obj-type":U then do:     create temp-changes.     assign     temp-changes.f_name = "obj-type":U     temp-changes.l_name = "Тип объекта"     temp-changes.v_old = string(X_c-schet-fact-doc.obj-type)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.obj-type)                               else string(current_schet-fact-doc.obj-type))     .     end.
                  when "obj-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "obj-code":U     temp-changes.l_name = "Код объекта"     temp-changes.v_old = string(X_c-schet-fact-doc.obj-code)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.obj-code)                               else string(current_schet-fact-doc.obj-code))     .     end.
                  when "pay-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "pay-date":U     temp-changes.l_name = "Дата платежа"     temp-changes.v_old = string(X_c-schet-fact-doc.pay-date)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.pay-date)                               else string(current_schet-fact-doc.pay-date))     .     end.
                  when "user-db-num":U then do:     create temp-changes.     assign     temp-changes.f_name = "user-db-num":U     temp-changes.l_name = "База опер."     temp-changes.v_old = string(X_c-schet-fact-doc.user-db-num)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.user-db-num)                               else string(current_schet-fact-doc.user-db-num))     .     end.
                  when "user-name":U then do:     create temp-changes.     assign     temp-changes.f_name = "user-name":U     temp-changes.l_name = "Имя опер."     temp-changes.v_old = string(X_c-schet-fact-doc.user-name)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.user-name)                               else string(current_schet-fact-doc.user-name))     .     end.
                  when "sys-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "sys-date":U     temp-changes.l_name = "Сист. дата"     temp-changes.v_old = string(X_c-schet-fact-doc.sys-date)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.sys-date)                               else string(current_schet-fact-doc.sys-date))     .     end.
                  when "sys-time":U then do:     create temp-changes.     assign     temp-changes.f_name = "sys-time":U     temp-changes.l_name = "Сист. время"     temp-changes.v_old = string(X_c-schet-fact-doc.sys-time)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.sys-time)                               else string(current_schet-fact-doc.sys-time))     .     end.
                  when "fact-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "fact-date":U     temp-changes.l_name = "Факт. дата"     temp-changes.v_old = string(X_c-schet-fact-doc.fact-date)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.fact-date)                               else string(current_schet-fact-doc.fact-date))     .     end.
                  when "fact-time":U then do:     create temp-changes.     assign     temp-changes.f_name = "fact-time":U     temp-changes.l_name = "Факт. время"     temp-changes.v_old = string(X_c-schet-fact-doc.fact-time)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.fact-time)                               else string(current_schet-fact-doc.fact-time))     .     end.
                  when "fact-user-db-num":U then do:     create temp-changes.     assign     temp-changes.f_name = "fact-user-db-num":U     temp-changes.l_name = "Факт. база опер."     temp-changes.v_old = string(X_c-schet-fact-doc.fact-user-db-num)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.fact-user-db-num)                               else string(current_schet-fact-doc.fact-user-db-num))     .     end.
                  when "fact-user-name":U then do:     create temp-changes.     assign     temp-changes.f_name = "fact-user-name":U     temp-changes.l_name = "Факт. имя опер."     temp-changes.v_old = string(X_c-schet-fact-doc.fact-user-name)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.fact-user-name)                               else string(current_schet-fact-doc.fact-user-name))     .     end.
                  when "fact-order":U then do:     create temp-changes.     assign     temp-changes.f_name = "fact-order":U     temp-changes.l_name = "порядковый номер документа"     temp-changes.v_old = string(X_c-schet-fact-doc.fact-order)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.fact-order)                               else string(current_schet-fact-doc.fact-order))     .     end.
                  when "sum-rubl":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-rubl":U     temp-changes.l_name = "Сумма руб"     temp-changes.v_old = string(X_c-schet-fact-doc.sum-rubl)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.sum-rubl)                               else string(current_schet-fact-doc.sum-rubl))     .     end.
                  when "sum-base":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-base":U     temp-changes.l_name = "Сумма б.вал."     temp-changes.v_old = string(X_c-schet-fact-doc.sum-base)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.sum-base)                               else string(current_schet-fact-doc.sum-base))     .     end.
                  when "sum-VAT-no-rubl":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-VAT-no-rubl":U     temp-changes.l_name = "Сумма, не облагаемая НДС, руб"     temp-changes.v_old = string(X_c-schet-fact-doc.sum-VAT-no-rubl)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.sum-VAT-no-rubl)                               else string(current_schet-fact-doc.sum-VAT-no-rubl))     .     end.
                  when "sum-VAT-no-base":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-VAT-no-base":U     temp-changes.l_name = "Сумма, не облагаемая НДС, б.вал."     temp-changes.v_old = string(X_c-schet-fact-doc.sum-VAT-no-base)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.sum-VAT-no-base)                               else string(current_schet-fact-doc.sum-VAT-no-base))     .     end.
                  when "sum-VAT-0-rubl":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-VAT-0-rubl":U     temp-changes.l_name = "Сумма, облагаемая НДС 0%, руб"     temp-changes.v_old = string(X_c-schet-fact-doc.sum-VAT-0-rubl)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.sum-VAT-0-rubl)                               else string(current_schet-fact-doc.sum-VAT-0-rubl))     .     end.
                  when "sum-VAT-0-base":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-VAT-0-base":U     temp-changes.l_name = "Сумма, облагаемая НДС 0%, б.вал."     temp-changes.v_old = string(X_c-schet-fact-doc.sum-VAT-0-base)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.sum-VAT-0-base)                               else string(current_schet-fact-doc.sum-VAT-0-base))     .     end.
                  when "sum-VAT-10-rubl":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-VAT-10-rubl":U     temp-changes.l_name = "Сумма, облагаемая НДС 10%, руб"     temp-changes.v_old = string(X_c-schet-fact-doc.sum-VAT-10-rubl)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.sum-VAT-10-rubl)                               else string(current_schet-fact-doc.sum-VAT-10-rubl))     .     end.
                  when "sum-VAT-10-base":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-VAT-10-base":U     temp-changes.l_name = "Сумма, облагаемая НДС 10%, б.вал."     temp-changes.v_old = string(X_c-schet-fact-doc.sum-VAT-10-base)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.sum-VAT-10-base)                               else string(current_schet-fact-doc.sum-VAT-10-base))     .     end.
                  when "sum-VAT-10-rubl":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-VAT-10-rubl":U     temp-changes.l_name = "Сумма НДС 10%, руб"     temp-changes.v_old = string(X_c-schet-fact-doc.sum-VAT-10-rubl)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.sum-VAT-10-rubl)                               else string(current_schet-fact-doc.sum-VAT-10-rubl))     .     end.
                  when "sum-VAT-10-base":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-VAT-10-base":U     temp-changes.l_name = "Сумма НДС 10%, б.вал."     temp-changes.v_old = string(X_c-schet-fact-doc.sum-VAT-10-base)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.sum-VAT-10-base)                               else string(current_schet-fact-doc.sum-VAT-10-base))     .     end.
                  when "sum-VAT-20-rubl":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-VAT-20-rubl":U     temp-changes.l_name = "Сумма, облагаемая НДС 20%, руб"     temp-changes.v_old = string(X_c-schet-fact-doc.sum-VAT-20-rubl)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.sum-VAT-20-rubl)                               else string(current_schet-fact-doc.sum-VAT-20-rubl))     .     end.
                  when "sum-VAT-20-base":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-VAT-20-base":U     temp-changes.l_name = "Сумма, облагаемая НДС 20%, б.вал."     temp-changes.v_old = string(X_c-schet-fact-doc.sum-VAT-20-base)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.sum-VAT-20-base)                               else string(current_schet-fact-doc.sum-VAT-20-base))     .     end.
                  when "sum-VAT-20-rubl":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-VAT-20-rubl":U     temp-changes.l_name = "Сумма НДС 10%, руб"     temp-changes.v_old = string(X_c-schet-fact-doc.sum-VAT-20-rubl)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.sum-VAT-20-rubl)                               else string(current_schet-fact-doc.sum-VAT-20-rubl))     .     end.
                  when "sum-VAT-20-base":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-VAT-20-base":U     temp-changes.l_name = "Сумма НДС 10%, б.вал."     temp-changes.v_old = string(X_c-schet-fact-doc.sum-VAT-20-base)     temp-changes.v_new = (if available new_c-schet-fact-doc                               then string(new_c-schet-fact-doc.sum-VAT-20-base)                               else string(current_schet-fact-doc.sum-VAT-20-base))     .     end.
    END CASE.
  end.
  Open QUery br-changes for each temp-changes.
END PROCEDURE.
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid, input mark-list as character) :
RETURN ( IF LOOKUP( STRING( par-recid ), mark-list ) > 0 THEN "*" ELSE "":U ).
END FUNCTION.
