define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-host-code    as integer   no-undo .
define input  parameter bttns          as character no-undo .
define input  parameter p-mode         as character no-undo .
define input  parameter p-cli-type     as character no-undo .
define input  parameter p-cli-code     as integer   no-undo .
define input  parameter p-mngr-type    as character no-undo .
define input  parameter p-mngr-code    as integer   no-undo .
define input  parameter p-status       as character no-undo .
define input  parameter p-doc-type     as character no-undo .
define input  parameter p-attr-code    as character no-undo .
define input-output param p-rid-list   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Список договоров" .
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
procedure current-db :
 do
 on error undo, return error return-value
 :
define input parameter  p-host-code as integer no-undo .
define input parameter  c-host-code as integer no-undo .
define output parameter ret         as logical no-undo .
define buffer current_sysconf for ub.sysconf.
define variable v-current-db as integer no-undo .
find first current_sysconf where current_sysconf.host-code = c-host-code no-lock no-error .
if error-status :error then return error .
   v-current-db = current_sysconf.firm-db-num .
   ret = true .
find first ub.sysconf where ub.sysconf.host-code = p-host-code no-lock no-error .
if not( ub.sysconf.firm-db-num = v-current-db or
        ub.sysconf.firm-db-num = 0 )
  then do:
  ret = false .
  message "Нельзя добавлять запись в  справочнике  для фирмы с не главной БД !!!" view-as alert-box information .
  return .
end.
 end.
end procedure.
procedure ver-db :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter  c-host-code as integer no-undo .
define input parameter  par-ver-db  as integer no-undo .
define input parameter  p-mess as logical no-undo .
define output parameter ret         as logical no-undo .
define buffer current_sysconf for ub.sysconf.
define variable v-current-db as integer no-undo .
find first current_sysconf where current_sysconf.host-code = c-host-code no-lock no-error .
if error-status :error then return error .
   v-current-db = current_sysconf.firm-db-num .
   ret = true .
if not( par-ver-db = v-current-db or
        par-ver-db = 0 )
  then do:
  ret = false .
  if p-mess = true then message "База , на которой мы работаем не является главной базой данных текущей фирмы!!!" view-as alert-box information .
  return .
end.
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info8, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info8, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-S_CONTRACT               AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-S_CODE_LAST_MASTER_NUM   AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-DELIM_CHR_3              AS CHARACTER NO-UNDO INITIAL "".
ASSIGN
   v-S_CONTRACT                = "Contract":U
   v-S_CODE_LAST_MASTER_NUM    = "LastMasterNum":U
   v-DELIM_CHR_3               = ","
   .
DEFINE VARIABLE i-gl-Host-Code      AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Contract-Code  AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Extent3        AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
FUNCTION Can-Find-Spec RETURN LOGICAL (
   INPUT iHost-Code    AS INTEGER,
   INPUT iContract-Num AS INTEGER,
   INPUT iGds-Code     AS INTEGER ):
   DEFINE BUFFER buf_Spec FOR ub.Contract-Specif.
   DEFINE VARIABLE iTmp-Host-Code     AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Contract-Num  AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Extent3       AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
   DEFINE VARIABLE lRet               AS LOGICAL NO-UNDO INITIAL FALSE.
   RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
       INPUT  iHost-Code,
       INPUT  iContract-Num,
       OUTPUT iTmp-Extent3
       ).
   IF iTmp-Extent3[1] = 2 THEN DO:
      ASSIGN
         iTmp-Host-Code      = iTmp-Extent3[2]
         iTmp-Contract-Num   = iTmp-Extent3[3]
         .
   END. ELSE DO:
      ASSIGN
         iTmp-Host-Code      = iHost-Code
         iTmp-Contract-Num   = iContract-Num
         .
   END.
   IF iGds-Code = ? THEN DO:
      ASSIGN
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                        ).
   END. ELSE DO:
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                           AND buf_Spec.Gds-Code      = iGds-Code
                         ).
   END.
   RETURN (lRet).
END FUNCTION.
PROCEDURE MS-Contract-EXTENT-3:
   DEFINE INPUT  PARAMETER i-Host-Code     AS INTEGER NO-UNDO.
   DEFINE INPUT  PARAMETER i-Contract-Code AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER i-Ret           AS INTEGER NO-UNDO EXTENT 3 INITIAL 0.
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE BUFFER buf_Cont-2      FOR ub.Contract.
   FIND FIRST buf_Cont-2 WHERE
              buf_Cont-2.Host-Code      = i-Host-Code
          AND buf_Cont-2.Contract-Code  = i-Contract-Code
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_Cont-2 THEN DO:
      RETURN.
   END.
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                            STRING(i-Contract-code)
        AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          i-Ret[1] = 1
          i-Ret[2] = buf_Cont.Host-code
          i-Ret[3] = buf_Cont.Contract-code
          .
       LEAVE.
   END.
   IF i-Ret[1] <> 1 THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                               STRING(i-Contract-code)
           AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             i-Ret[1] = 2
             i-Ret[2] = buf_Cont.Host-code
             i-Ret[3] = buf_Cont.Contract-code
             .
          LEAVE.
      END.
   END.
   RETURN.
END PROCEDURE.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-gl-UVEDOMLENIE as CHARACTER NO-UNDO INITIAL "Uvedomlenie":U.
FUNCTION Get-Contract-Attr RETURN CHARACTER(
         INPUT iHost-Code AS INTEGER,
         INPUT iContract-Code  AS INTEGER,
         INPUT cAttr-code      AS CHARACTER):
   DEFINE BUFFER buf_Contract-Attr FOR ub.Contract-Attr.
   FIND FIRST buf_Contract-Attr WHERE
              buf_Contract-Attr.Host-code     = iHost-Code
          AND buf_Contract-Attr.Contract-code = iContract-Code
          AND buf_Contract-Attr.Attr-code     = cAttr-code
        NO-LOCK NO-ERROR.
   RETURN (IF AVAILABLE buf_Contract-Attr THEN buf_Contract-Attr.Attr-value ELSE ?).
END FUNCTION.
PROCEDURE Modify-Contract-Attr:
   DEFINE INPUT  PARAMETER iHost-Code      AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER iContract-Code  AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-code      AS CHARACTER NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-value     AS CHARACTER NO-UNDO.
   DEFINE OUTPUT PARAMETER cError          AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Contract-Attr FOR  ub.Contract-Attr.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции:":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      FIND FIRST buf_Contract-Attr WHERE
                 buf_Contract-Attr.Host-Code      = iHost-Code
             AND buf_Contract-Attr.Contract-Code  = iContract-Code
             AND buf_Contract-Attr.Attr-code      = cAttr-code
           NO-LOCK NO-ERROR.
      IF NOT AVAILABLE buf_Contract-Attr THEN DO:
         CREATE buf_Contract-Attr NO-ERROR.
         IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END. ELSE DO:
         FIND CURRENT buf_Contract-Attr EXCLUSIVE-LOCK NO-ERROR.
         IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END.
      ASSIGN
         buf_Contract-Attr.Host-Code      = iHost-Code
         buf_Contract-Attr.Contract-Code  = iContract-Code
         buf_Contract-Attr.Attr-code      = cAttr-code
         buf_Contract-Attr.Attr-value     = cAttr-value
         NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      RELEASE buf_Contract-Attr NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Create-Contract-Attr:
   DEFINE INPUT  PARAMETER iHost-Code      AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER iContract-Code  AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-code      AS CHARACTER NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-value     AS CHARACTER NO-UNDO.
   DEFINE OUTPUT PARAMETER cError          AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Contract-Attr FOR  ub.Contract-Attr.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции:":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      CREATE buf_Contract-Attr NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      ASSIGN
         buf_Contract-Attr.Host-Code      = iHost-Code
         buf_Contract-Attr.Contract-Code  = iContract-Code
         buf_Contract-Attr.Attr-code      = cAttr-code
         buf_Contract-Attr.Attr-value     = cAttr-value
         NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      RELEASE buf_Contract-Attr NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
   END.
   RETURN.
END PROCEDURE.
FUNCTION Is-MS-Contract RETURN LOGICAL(BUFFER buf_Master FOR ub.Contract, BUFFER buf_Slave  FOR ub.Contract) FORWARD.
FUNCTION Is-Master-Slave-Contract RETURN CHARACTER( BUFFER buf_Contract FOR ub.Contract) FORWARD.
FUNCTION Is-MS-Contract-Int RETURN INTEGER (BUFFER buf_Contract FOR ub.Contract) FORWARD.
PROCEDURE Delete-Contract-Specif:
   DEFINE PARAMETER BUFFER buf_Contract FOR ub.Contract.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Specif      FOR ub.Contract-Specif.
   DEFINE BUFFER buf_Specif-Attr FOR ub.Contract-Specif-Attr.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции ":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      FOR EACH buf_Specif-Attr WHERE
               buf_Specif-Attr.Host-code     = buf_Contract.Host-code
           AND buf_Specif-Attr.Contract-Num  = buf_Contract.Contract-code
          EXCLUSIVE-LOCK:
          DELETE buf_Specif-Attr NO-ERROR.
          IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END.
      FOR EACH buf_Specif WHERE
               buf_Specif.Host-code     = buf_Contract.Host-code
           AND buf_Specif.Contract-Num  = buf_Contract.Contract-code
          EXCLUSIVE-LOCK:
          DELETE buf_Specif NO-ERROR.
         IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Modify-Slave-Contract:
   DEFINE PARAMETER BUFFER buf_Master FOR ub.Contract.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   DEFINE BUFFER buf_Slave FOR ub.Contract.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции ":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      FOR EACH buf_Ext-Classif WHERE
               buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
           AND buf_Ext-Classif.DB-num       = buf_Master.Db-num
          NO-LOCK,
          FIRST buf_Slave WHERE
                buf_Slave.Host-Code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
            AND buf_Slave.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
          EXCLUSIVE-LOCK:
          BUFFER-COPY
            buf_Master
          EXCEPT
            Host-code                               Contract-code                           Own-name                                an-uchet-code-out                       cel-nazn-code-out                       cor-acc-out                             cor-acc1-out                            an-uchet-code-in                        cel-nazn-code-in                        cor-acc-in                              cor-acc1-in                             an-uchet-code-out-cash                  cel-nazn-code-out-cash                  cor-acc-out-cash                        cor-acc1-out-cash                       an-uchet-code-in-cash                   cel-nazn-code-in-cash                   cor-acc-in-cash                         cor-acc1-in-cash                        an-uchet-code-out-payoff                cel-nazn-code-out-payoff                cor-acc-out-payoff                      cor-acc1-out-payoff                     an-uchet-code-in-payoff                 cel-nazn-code-in-payoff                 cor-acc-in-payoff                       cor-acc1-in-payoff                      transport-cli-type                      transport-cli-code                      transport-host                          transport-contract                      transport-uslov                         transport-value                         own-code-schet-start                    own-sign-post                           own-sign                                contract-city                           fin-VAT-pc                              srok-opl                                gen-factur-srok                         own-addres                              own-inn                                 own-kpp
          TO buf_Slave
          NO-ERROR.
          IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
          RELEASE buf_Slave NO-ERROR.
          IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Change-Stat-Slave-Contract:
   DEFINE PARAMETER BUFFER buf_Master FOR ub.Contract.
   DEFINE INPUT PARAMETER cStatus  AS CHARACTER NO-UNDO.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   DEFINE BUFFER buf_Slave FOR ub.Contract.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции ":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      FOR EACH buf_Ext-Classif WHERE
               buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
           AND buf_Ext-Classif.DB-num       = buf_Master.Db-num
          NO-LOCK,
          FIRST buf_Slave WHERE
                buf_Slave.Host-Code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
            AND buf_Slave.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
          EXCLUSIVE-LOCK:
          ASSIGN
             buf_Slave.Status_ = cStatus
             NO-ERROR.
          IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
          RELEASE buf_Slave NO-ERROR.
          IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Delete-Ref-Master-Slave:
   DEFINE PARAMETER BUFFER buf_Master FOR ub.Contract.
   DEFINE PARAMETER BUFFER buf_Slave  FOR ub.Contract.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   IF NOT Is-MS-Contract(BUFFER buf_Master, BUFFER buf_Slave) THEN DO:
      cError = PROGRAM-NAME(1) + ":" + "Между договорами нет связи Master->Slave".
      RETURN.
   END.
   Tran:
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
         AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
         AND buf_Ext-Classif.CharKey_Two  = STRING(buf_Slave.Host-Code)  + v-DELIM_CHR_3 + STRING(buf_Slave.Contract-code)
         AND buf_Ext-Classif.DB-num       = buf_Master.Db-num
       EXCLUSIVE-LOCK
       TRANSACTION
       ON ENDKEY UNDO Tran, RETRY Tran
       ON ERROR  UNDO Tran, RETRY Tran
       ON QUIT   UNDO Tran, RETRY Tran
       ON STOP   UNDO Tran, RETRY Tran:
       IF RETRY THEN DO:       cError = "Ошибка транзакции ":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
       DELETE buf_Ext-Classif NO-ERROR.
       IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Create-Ref-Master-Slave:
   DEFINE PARAMETER BUFFER buf_Master FOR ub.Contract.
   DEFINE PARAMETER BUFFER buf_Slave  FOR ub.Contract.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   DEFINE VARIABLE cKeyRec AS CHARACTER NO-UNDO INITIAL "".
   IF Is-MS-Contract(BUFFER buf_Master, BUFFER buf_Slave) THEN DO:
      cError = PROGRAM-NAME(1) + ":" + "Между договорами  уже есть связь Master->Slave".
      RETURN.
   END.
   RUN gen-key-rec IN THIS-PROCEDURE(
       INPUT  v-S_CONTRACT,
       INPUT  BUFFER buf_Master:HANDLE,
       OUTPUT cKeyRec
       ) NO-ERROR.
   IF ERROR-STATUS:ERROR THEN DO:
      cError = PROGRAM-NAME(1) + ":" + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.
      RETURN.
   END.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции ":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      CREATE buf_Ext-Classif NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      ASSIGN
         buf_Ext-Classif.Classif-name    = v-S_CONTRACT
         buf_Ext-Classif.Classif-subject = v-S_CONTRACT
         buf_Ext-Classif.CharKey_One     = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
         buf_Ext-Classif.CharKey_Two     = STRING(buf_Slave.Host-Code)  + v-DELIM_CHR_3 + STRING(buf_Slave.Contract-code)
         buf_Ext-Classif.DB-num          = buf_Master.Db-num
         buf_Ext-Classif.Uniq-key-rec    = cKeyRec
         NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      RELEASE buf_Ext-Classif NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
   END.
   RETURN.
END PROCEDURE.
FUNCTION Is-MS-Contract-Int-2 RETURN INTEGER (
                              i-Host-Code AS INTEGER,
                              i-Contract-Code AS INTEGER):
   DEFINE BUFFER buf_Contract FOR ub.Contract.
   DEFINE VARIABLE iRet AS INTEGER NO-UNDO INITIAL 0.
   FIND FIRST buf_Contract WHERE
              buf_Contract.Host-Code      = i-Host-Code
          AND buf_Contract.Contract-code  = i-Contract-Code
        NO-LOCK NO-ERROR.
   IF AVAILABLE buf_Contract THEN DO:
      ASSIGN
         iRet = Is-MS-Contract-Int(BUFFER buf_Contract).
   END.
   RETURN (iRet).
END FUNCTION.
FUNCTION Is-MS-Contract-Int RETURN INTEGER (BUFFER buf_Contract FOR ub.Contract):
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE VARIABLE iRet AS INTEGER NO-UNDO INITIAL 0.
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(buf_Contract.Host-code) + v-DELIM_CHR_3 +
                                            STRING(buf_Contract.contract-code)
        AND  buf_Ext-classif.db-num       = buf_Contract.db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          iRet = 1.
       LEAVE.
   END.
   IF iRet <> 1 THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(buf_Contract.Host-code) + v-DELIM_CHR_3 +
                                               STRING(buf_Contract.contract-code)
           AND  buf_Ext-classif.db-num       = buf_Contract.db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             iRet = 2.
          LEAVE.
      END.
   END.
   RETURN (iRet).
END FUNCTION.
FUNCTION Is-Master-Slave-Contract RETURN CHARACTER( BUFFER buf_Contract FOR ub.Contract):
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE VARIABLE cRet AS CHARACTER NO-UNDO INITIAL "".
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(buf_Contract.Host-code) + v-DELIM_CHR_3 +
                                            STRING(buf_Contract.contract-code)
        AND  buf_Ext-classif.db-num       = buf_Contract.db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          cRet = "+".
       LEAVE.
   END.
   IF cRet = "" THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(buf_Contract.Host-code) + v-DELIM_CHR_3 +
                                               STRING(buf_Contract.contract-code)
           AND  buf_Ext-classif.db-num       = buf_Contract.db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             cRet = (IF buf_Cont.Contract-prn-code = "" THEN  STRING(buf_Cont.Contract-code) ELSE buf_Cont.Contract-prn-code).
          LEAVE.
      END.
   END.
   RETURN (cRet).
END FUNCTION.
FUNCTION Is-MS-Contract RETURN LOGICAL(
         BUFFER buf_Master FOR ub.Contract,
         BUFFER buf_Slave  FOR ub.Contract):
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   RETURN CAN-FIND ( FIRST buf_Ext-Classif WHERE
                       buf_Ext-Classif.Classif-name = v-S_CONTRACT
                   AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
                   AND buf_Ext-Classif.CharKey_Two  = STRING(buf_Slave.Host-Code)  + v-DELIM_CHR_3 + STRING(buf_Slave.Contract-code)
                   AND buf_Ext-Classif.DB-num       = buf_Master.Db-num
                 NO-LOCK).
END FUNCTION.
FUNCTION Get-Num-Slave-Contract RETURN CHARACTER(
         BUFFER buf_Master FOR ub.Contract,
         INPUT iSlave-Host-Code AS INTEGER
         ):
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   DEFINE BUFFER buf_Contract    FOR ub.Contract.
   DEFINE VARIABLE cRet AS CHARACTER NO-UNDO INITIAL "".
   FIND FIRST buf_Ext-Classif WHERE
              buf_Ext-Classif.Classif-name = v-S_CONTRACT
          AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code)  + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
          AND buf_Ext-Classif.CharKey_Two  BEGINS STRING(iSlave-Host-Code) + v-DELIM_CHR_3
          AND buf_Ext-Classif.DB-num       = buf_Master.Db-num
        NO-LOCK NO-ERROR.
   IF AVAILABLE buf_Ext-Classif THEN DO:
      IF CAN-FIND (FIRST buf_Contract WHERE
                         buf_Contract.Host-Code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
                     AND buf_Contract.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
                    NO-LOCK) THEN DO:
         ASSIGN
            cRet = ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3).
      END. ELSE DO:
         ASSIGN
            cRet = "ERROR:" + "Ошибка связи мастер договора " +
                   STRING(buf_Master.Host-Code) + "," + STRING(buf_Master.Contract-code) + " " +
                   "c Host-code=" + STRING(iSlave-Host-Code).
      END.
   END.
   RETURN (cRet).
END FUNCTION.
define NEW SHARED  buffer buf_contract for ub.contract.
define NEW shared  buffer buf_contract-attr for ub.contract-attr .
define new shared variable br-handle as handle  no-undo .
define new shared variable next-prev as logical no-undo .
define variable p-contr-type as character no-undo .
function fo return character ( input p-cr-fo as logical, input p-fo-date as date, input p-need-fo as integer ) .
 if p-cr-fo = yes then do:
   return string (p-fo-date, "99/99/99").
 end.
 else do:
   if p-need-fo = 0 then return "--------".
   if p-need-fo = 1 then return "".
   if p-need-fo = 2 then return "не опред".
 end.
end function.
define variable agnt-list as character no-undo .
define variable org-list  as character no-undo .
define variable g-log     as logical   no-undo .
define variable  p-sys-date     as date      no-undo .
define variable  p-sys-time     as character no-undo .
define variable  p-sys-time-int as integer   no-undo .
define variable v-type as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable filter-point as character no-undo init "Список договоров" .
define variable filter-point0 as character no-undo init "Список договоров" .
define variable sort-column-name as character no-undo .
define variable vari as integer   no-undo .
DEFINE VARIABLE v-Character   AS CHARACTER  NO-UNDO .
DEFINE VARIABLE v-Date        AS DATE       NO-UNDO .
DEFINE VARIABLE v-Decimal     AS DECIMAL    NO-UNDO .
DEFINE VARIABLE v-iMcMode     AS INTEGER    NO-UNDO .
DEFINE VARIABLE v-Logical     AS LOGICAL    NO-UNDO .
DEFINE VARIABLE v-Param-Type  AS CHARACTER  NO-UNDO .
DEFINE VARIABLE iTmp-Host-Code     AS INTEGER   NO-UNDO INITIAL 0.
DEFINE VARIABLE iTmp-Contract-Code AS INTEGER   NO-UNDO INITIAL 0.
DEFINE VARIABLE cTmp-Mode-W        AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE i-Cont-Ret         AS INTEGER   NO-UNDO INITIAL 0 EXTENT 3.
DEFINE VARIABLE iTmp               AS INTEGER   NO-UNDO INITIAL 0.
define variable v-contract-code    as integer   no-undo .
define temp-table t-imp-price no-undo
  field contract-code as integer
  field firm-code     as integer
  field gds-code      as integer
  field price-rubl    as decimal
  field vat-pc        as decimal
  field prc-up        as decimal
  field prc-dn        as decimal
  field gds-name      as character
  field firm-name     as character
  field line-num      as integer
.
define stream f-log-imp .
DEFINE VARIABLE v-MS-Can-Do-List as CHARACTER NO-UNDO INITIAL "".
ASSIGN
   v-MS-Can-Do-List  = (if NUM-ENTRIES(p-Mode, "|") >= 2 THEN  ENTRY(2, p-Mode, "|") ELSE "")
   p-Mode            = ENTRY(1, p-Mode, "|")
   .
RUN adm/shattri.p (
      INPUT  "get":U,
      INPUT  "",
      INPUT  0,
      INPUT  "fin-global",
      INPUT  "fo-mc-mode",
      OUTPUT v-Character,
      OUTPUT v-Date,
      OUTPUT v-Decimal,
      OUTPUT v-iMcMode,
      OUTPUT v-Logical,
      OUTPUT v-Param-Type,
      INPUT-OUTPUT TABLE thbjattr_thbj-attr
    ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
   MESSAGE
      "Ошибка определения глобалоного параметра fin-global/fo-mc-mode" SKIP
      PROGRAM-NAME(1) ERROR-STATUS:GET-MESSAGE(1) RETURN-VALUE
      VIEW-AS ALERT-BOX.
END.
FUNCTION get-agent RETURNS CHARACTER
  ( input agnt-code as integer )  FORWARD.
FUNCTION func-char-to-dec RETURNS DECIMAL
  ( input iCh AS CHARACTER) forward .
FUNCTION get-currency RETURNS CHARACTER
  ( input curr-code as integer )  FORWARD.
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid, input mark-list as character )  FORWARD.
DEFINE MENU POPUP-MENU-b-gen
       MENU-ITEM m_gen-1        LABEL "Фин. обязательство"
       MENU-ITEM m_gen-2        LABEL "Отказаться от генерации ФО"
       MENU-ITEM m_gen-3        LABEL "Снять признак - есть генерация ФО"
       MENU-ITEM m_gen-4        LABEL "Снять 'не опред'".
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON b-del
     LABEL "&Закрыть"
     SIZE 10 BY 1.
DEFINE BUTTON B-fin-doc
     LABEL "П&латежи"
     SIZE 10 BY 1.
DEFINE BUTTON B-exp
     LABEL "&Экспорт"
     SIZE 10 BY 1.
DEFINE BUTTON B-imp
     LABEL "Импорт"
     SIZE 10 BY 1.
DEFINE BUTTON B-fin-ob
     LABEL "Фи&н.обяз."
     SIZE 10 BY 1.
DEFINE BUTTON b-trn-doc
     LABEL "&Скл.док."
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.
DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON b-open
     LABEL "&Открыть"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit  AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 10 BY 1.
DEFINE BUTTON b-SlaveContract
     LABEL "Под&чДог"
     SIZE 10 BY 1.
DEFINE BUTTON b-spec
     LABEL "Спе&цификация"
     SIZE 15 BY 1.
DEFINE BUTTON b-specgrp
     LABEL "Специф&Груп"
     SIZE 15 BY 1.
DEFINE BUTTON b-order
     LABEL "&Заказы"
     SIZE 10 BY 1.
DEFINE BUTTON b-gen
     LABEL "&Генерация"
     SIZE 10 BY 1.
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.
DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 7 BY 1 NO-UNDO.
DEFINE VARIABLE user-name AS CHARACTER FORMAT "X(18)"
     LABEL "Опер"
      VIEW-AS TEXT
     SIZE 18 BY 1 NO-UNDO.
DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(14)"
     LABEL "&Начало номера"
     VIEW-AS FILL-IN
     SIZE 15 BY .92 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sch-date AS DATE FORMAT "99/99/9999"
     LABEL "Д&ата"
     VIEW-AS FILL-IN
     SIZE 11.5 BY .92 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE Agnt-Types AS CHARACTER INITIAL "all"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", "all",
"Выбор", "sel"
     SIZE 15 BY .79 NO-UNDO.
DEFINE VARIABLE Cli-Status AS CHARACTER INITIAL "current"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущие&+", "current",
"Все&!", "all",
"Закрытые&-", "deleted"
     SIZE 30 BY .79 NO-UNDO.
DEFINE VARIABLE Cli-Types AS CHARACTER INITIAL "all"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", "all",
"Выбор", "sel"
     SIZE 15.38 BY .79 NO-UNDO.
DEFINE RECTANGLE RECT-status
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98.8 BY 1.13.
DEFINE QUERY Contr-List FOR  buf_contract,buf_contract-attr SCROLLING.
DEFINE BROWSE Contr-List
  QUERY Contr-List DISPLAY mark-string(recid(buf_contract), p-rid-list)            column-label '*' format "x(1)"  buf_contract.status_            column-label 'Ста!тус' format "x(4)"  buf_contract.contract-prn-code            column-label 'Номер' format "x(48)"  buf_contract.contract-date            column-label 'Дата!договора' format "99/99/99"  buf_contract.contract-name            column-label 'Заголовок' format "x(20)"   (if buf_contract.cli-type = '' then '' else TRIM (buf_contract.cli-type + ' ' + STRING (buf_contract.cli-code) ))   @ v-type column-label 'Тип/код!контрагента' format "x(13)"  buf_contract.cli-name            column-label 'Контрагент'  buf_contract.contract-type            column-label 'Тип договора' format "x(23)"  buf_contract.usl-opl            column-label 'Условия!оплаты' format "X(32)"  (if buf_contract.srok-opl > 0 then string(buf_contract.srok-opl) else '')           column-label 'Отс-!роч.' format "X(4)"  buf_contract.contract-city           column-label 'Город' format "X(14)"  buf_contract.contract-date-beg           column-label 'Начало!действия' format "99/99/99"  buf_contract.contract-date-end           column-label 'Окончание!действия' format "99/99/99"  get-currency(buf_contract.curr-code)           column-label 'Вал' format "X(3)"  (if buf_contract.posr-type = '' then '' else TRIM (buf_contract.posr-type + ' ' + STRING (buf_contract.posr-code)))           column-label 'Тип/код!посредника' format "x(13)"  buf_contract.posr-name           column-label 'Посредник'  (if buf_contract.agnt-type = '' then '' else TRIM (buf_contract.agnt-type + ' ' + STRING (buf_contract.agnt-code)))           column-label 'Тип/код!агента' format "x(13)"  buf_contract.agnt-name           column-label 'Агент'  get-agent( buf_contract.mngr-code)           column-label 'Исполнитель' format "x(40)"  buf_contract.doc-type           column-label 'Вид'  buf_contract.contract-code           column-label 'Вн.н.' format ">>>>>>>>>9"   fo( buf_contract.cr-fo, buf_contract.fo-date, buf_contract.need-fo )           column-label 'Фин.об.' format "x(8)"  buf_contract.db-num           column-label 'БД'  Is-Master-Slave-Contract( BUFFER buf_Contract)           column-label 'Мастер!Договор' format "x(10)"
      enable buf_contract.contract-type
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.88 BY 17.79.
DEFINE FRAME Dialog-Frame
     b-quit    AT ROW 1 COL 1
     B-mark    AT ROW 1 COL 11
     B-sel     AT ROW 1 COL 21
     B-add     AT ROW 1 COL 31
     B-lkp     AT ROW 1 COL 41
     b-chg     AT ROW 1 COL 51
     b-open    AT ROW 1 COL 61
     b-del     AT ROW 1 COL 71
     b-gen     AT ROW 1 COL 81
     B-Help    AT ROW 1 COL 91
     b-spec    AT ROW 2 COL 1
     b-specgrp    AT ROW 2 COL 16
     b-trn-doc AT ROW 2 COL 31
     b-order   at row 2 col 41
     B-fin-ob  AT ROW 2 COL 51
     B-fin-doc AT ROW 2 COL 61
     b-exp     AT ROW 2 COL 71
     b-imp     AT ROW 2 COL 81
     b-sch     AT ROW 2 COL 91
     b-SlaveContract AT ROW 2 COL 91
     b-hist    AT ROW 2 COL 101
     Contr-List AT ROW 3 COL 1.25
     sch-code AT ROW 21 COL 23.25 COLON-ALIGNED
     sch-date AT ROW 21 COL 45.5 COLON-ALIGNED
     Cli-Types AT ROW 22.21 COL 14.13 NO-LABEL
     Agnt-Types AT ROW 22.21 COL 43.63 NO-LABEL
     Cli-Status AT ROW 22.21 COL 67.25 NO-LABEL
     mark-num AT ROW 1 COL 14 NO-LABEL
     user-name at row 21 col 80 COLON-ALIGNED LABEL "Опер" VIEW-AS FILL-IN SIZE 18 BY 1 fgcolor 4
     "Статус:" VIEW-AS TEXT
          SIZE 7.38 BY .79 AT ROW 22.21 COL 59.63
          FGCOLOR 4
     RECT-status AT ROW 22.13 COL 1
     "Поиск:" VIEW-AS TEXT
          SIZE 7.38 BY .92 AT ROW 21 COL 2.5
          FGCOLOR 4
     "Исполнители:" VIEW-AS TEXT
          SIZE 12.38 BY .79 AT ROW 22.21 COL 30.88
          FGCOLOR 4
     "Контрагенты:" VIEW-AS TEXT
          SIZE 12.13 BY .79 AT ROW 22.21 COL 1.88
          FGCOLOR 4
     SPACE(84.86) SKIP(0.37)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Договоры"
         DEFAULT-BUTTON b-quit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-gen:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-gen:HANDLE.
ON END-ERROR OF FRAME Dialog-Frame
DO:
  run gbl/markqwa.p (input b-mark:sensitive, input p-rid-list) no-error.
  if error-status:error then return no-apply.
END.
ON ENDKEY OF FRAME Dialog-Frame
DO:
  run gbl/markqwa.p (input b-mark:sensitive, input p-rid-list) no-error.
  if error-status:error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON VALUE-CHANGED OF Agnt-Types IN FRAME Dialog-Frame
DO:
  assign Agnt-Types .
  if Agnt-Types = "sel" then  do:
    run proc-sel-agent in this-procedure .
  end.
  RUN OpenBr(yes, no, '':U).
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-contract_add-def':U
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
  if not g-log then return no-apply .
  run run-contr in this-procedure ('ДОБАВЛЕНИЕ':U, no) .
END.
ON CHOOSE OF B-order IN FRAME Dialog-Frame
DO:
define variable v-list as character no-undo .
if not avail buf_contract then return no-apply.
  run cus/zakz-rcv.w (
   input   parparentproc
  ,input   "all":U
  ,input   "all":U
  ,input   "contract":U
  ,input   recid( buf_contract )
  ,input   "b-lkp,nob-exec,nob-copy"
  ,input   ""
  ,output  v-list )
  .
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
  if not avail buf_contract then return no-apply.
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-contract_update':U
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
  if not g-log then return no-apply .
  ASSIGN
     iTmp = Is-MS-Contract-Int (BUFFER buf_Contract).
  CASE iTmp:
       WHEN 1 THEN DO:
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fo-mc_master-modify':U
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
             if not g-log then return no-apply.
       END.
       WHEN 2 THEN DO:
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fo-mc_slave-modify':U
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
             if not g-log then return no-apply.
       END.
  END CASE.
  run run-contr in this-procedure ('ИЗМЕНЕНИЕ':U, no) .
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
  if not avail buf_contract then return no-apply.
  run proc-del in this-procedure no-error .
  if error-status:error then return no-apply.
  if Cli-Status = "current" then do:
    g-log = Contr-List:select-next-row().
    if not g-log then g-log = Contr-List:select-prev-row().
    v-doc-rec = recid( buf_contract ).
  end.
  RUN OpenBr(yes, no, '':U).
END.
ON CHOOSE OF B-fin-doc IN FRAME Dialog-Frame
DO:
  define variable ri as character no-undo .
  if available  buf_contract then do:
    run ref/findocs.w (input parParentProc, input p-host-code,  input "b-add,b-upd,b-del", input "contract-host":U, input 'все':U,
                  input p-host-code, input "":U, input 0, input ?, input ?, input ?, input ?, input ?, input ?, input ?, input ?, input ?,
                  input ?, input ?,  input ?, input ?, input ?, input ?, input buf_contract.contract-code,
                  input ?, input ?, input ?, input ?, input-output ri ) no-error .
  end.
END.
ON CHOOSE OF B-fin-ob IN FRAME Dialog-Frame
DO:
  define variable ri as character no-undo .
  if available buf_contract THEN do:
    run str/fin-liab.w ( input parParentProc, input "b-chg,b-del,b-mark", input "contract":U, input ?, input p-host-code,
                     input ?, input ?, string(buf_contract.contract-code), output ri) no-error .
  end.
END.
ON CHOOSE OF B-trn-doc IN FRAME Dialog-Frame
DO:
  define variable ri as character no-undo .
  if available buf_contract THEN do:
    run str/strncntr.w ( input buf_contract.host-code, input buf_contract.contract-code).
  end.
END.
ON CHOOSE OF B-exp IN FRAME Dialog-Frame
DO:
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-contract_export':U
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
  RUN proc-b-exp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-imp IN FRAME Dialog-Frame
DO:
  RUN proc-b-imp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-hist IN FRAME Dialog-Frame
DO:
  define variable v-ri as character initial "" no-undo .
  if available buf_contract then run str/contr-c.w (input parparentproc,input p-host-code, input buf_contract.contract-code,input "",input-output v-ri) .
END.
ON CHOOSE OF b-spec IN FRAME Dialog-Frame
DO:
  define variable v-rid-list as char no-undo.
  if available buf_contract then DO:
     ASSIGN
        iTmp-Host-Code       = p-host-code
        iTmp-Contract-Code   = buf_contract.contract-code
        cTmp-Mode-W          = (IF buf_contract.status_ = 'зкр':U THEN 'ПРОСМОТР':U ELSE 'ИЗМЕНЕНИЕ':U)
        .
     IF v-iMcMode = 1 OR v-iMcMode = 2 THEN DO:
        RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
            INPUT  p-Host-Code,
            INPUT  buf_contract.contract-code,
            OUTPUT i-Cont-Ret
            ).
        IF i-Cont-Ret[1] = 2 THEN DO:
           ASSIGN
              iTmp-Host-Code       = i-Cont-Ret[2]
              iTmp-Contract-Code   = i-Cont-Ret[3]
              cTmp-Mode-W          = 'ПРОСМОТР':U
              .
        END.
     END.
     RUN str/contspec.w (
         INPUT  parparentproc,
         INPUT  "b-mark",
         INPUT  cTmp-Mode-W,
         INPUT  iTmp-Host-Code,
         INPUT  iTmp-Contract-Code,
         OUTPUT v-rid-list
         ).
  END.
END.
ON CHOOSE OF b-specgrp IN FRAME Dialog-Frame
DO:
  define variable v-rid-list as char no-undo.
  if available buf_contract then do:
     ASSIGN
        iTmp-Host-Code       = p-host-code
        iTmp-Contract-Code   = buf_contract.contract-code
        cTmp-Mode-W          = 'ИЗМЕНЕНИЕ':U
        .
     IF v-iMcMode = 1 OR v-iMcMode = 2 THEN DO:
        RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
            INPUT  p-Host-Code,
            INPUT  buf_contract.contract-code,
            OUTPUT i-Cont-Ret
            ).
        IF i-Cont-Ret[1] = 2 THEN DO:
           ASSIGN
              iTmp-Host-Code       = i-Cont-Ret[2]
              iTmp-Contract-Code   = i-Cont-Ret[3]
              cTmp-Mode-W          = 'ПРОСМОТР':U
              .
        END.
     END.
     run str/specgrp.w
       ( input parparentproc,
         INPUT iTmp-Host-Code  ,
         INPUT iTmp-Contract-code   ,
         input "b-mark",
         input v-cntxt-obj-type,
         input v-cntxt-obj-code,
         input-output v-rid-list) .
    end.
END.
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame
DO:
  if not avail buf_contract then return no-apply.
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if not g-log then return no-apply .
  run run-contr in this-procedure ('ПРОСМОТР':U, yes) .
END.
ON CHOOSE OF MENU-ITEM m_gen-1
DO:
run proc-m_gen-1 no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_gen-2
DO:
run proc-m_gen-2 no-error .
  if error-status :error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m_gen-3
DO:
run proc-m_gen-3 no-error .
  if error-status :error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m_gen-4
DO:
run proc-m_gen-4 no-error .
  if error-status :error then return no-apply.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
  if available buf_contract then   do:
    if can-do( p-rid-list, string( recid( buf_contract ) ) ) then  do:
            p-rid-list = replace( p-rid-list, chr(44) + string( recid( buf_contract ) ), "") .
            p-rid-list = replace( p-rid-list, string( recid( buf_contract ) ) + chr(44), "") .
            p-rid-list = replace( p-rid-list, string( recid( buf_contract ) ), "") .
    end.
    else  p-rid-list = p-rid-list + ( if p-rid-list = "" then "" else chr(44) ) + string( recid( buf_contract ) ) .
    g-log = Contr-List:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then  do:
      g-log = Contr-List:select-next-row ().
      apply "value-changed" to Contr-List in frame Dialog-Frame.
    end.
    if num-entries( p-rid-list ) = 0 then hide mark-num in frame Dialog-Frame.
    else   display num-entries( p-rid-list ) @ mark-num  with frame Dialog-Frame.
  end.
  apply "entry" to Contr-List .
END.
ON CHOOSE OF b-open IN FRAME Dialog-Frame
DO:
  if not avail buf_contract then return no-apply.
  run proc-open in this-procedure no-error .
  if error-status:error then return no-apply.
  if Cli-Status = "deleted" then do:
    g-log = Contr-List:select-next-row().
    if not g-log then g-log = Contr-List:select-prev-row().
    v-doc-rec = recid( buf_contract ).
  end.
  RUN OpenBr(yes, no, '':U).
END.
ON ROW-DISPLAY OF  Contr-List IN FRAME Dialog-Frame
DO:
  if available buf_contract then do:
     if buf_contract.contract-date-end < today then do:
        buf_contract.contract-date-end:bgcolor  in browse Contr-List =  8.
        buf_contract.status_:bgcolor  in browse Contr-List =  8.
        buf_contract.contract-prn-code:bgcolor  in browse Contr-List =  8.
        buf_contract.contract-date:bgcolor  in browse Contr-List =  8.
        v-type:bgcolor  in browse Contr-List =  8.
        buf_contract.contract-name:bgcolor  in browse Contr-List =  8.
        buf_contract.cli-name:bgcolor  in browse Contr-List =  8.
     end.
     else do:
        buf_contract.contract-date-end:bgcolor  in browse Contr-List =  ?.
        buf_contract.status_:bgcolor  in browse Contr-List =  ?.
        buf_contract.contract-prn-code:bgcolor  in browse Contr-List =  ?.
        buf_contract.contract-date:bgcolor  in browse Contr-List =  ?.
        buf_contract.contract-name:bgcolor  in browse Contr-List =  ?.
        buf_contract.cli-name:bgcolor  in browse Contr-List =  ?.
        v-type:bgcolor  in browse Contr-List =  ?.
     end.
  end.
END.
PROCEDURE proc-m_gen-1 :
  do on error undo, return error return-value :
    if p-rid-list = "" then do:
      if available buf_contract then assign p-rid-list = string(recid(buf_contract)).
      else do:
        return error "Не выделено ни одного договора для генерации ФО !". .
      end.
    end.
    define buffer bf_contract for ub.contract.
    g-log = yes.
    message "Выбрано " + string( num-entries( p-rid-list)  ) + " договоров . Провести генерацию ФО ?" skip
    view-as alert-box question buttons OK-Cancel update g-log.
    if not g-log then return no-apply.
    define variable res as character no-undo .
    run str/gen-flsp.p ( INPUT parParentProc, input p-host-code, input ?, input 0, input p-rid-list, input-output res) no-error .
    if error-status:error then  message "Ошибка создания ФО " view-as alert-box.
    if  res <> "" then message res view-as alert-box information .
    assign p-rid-list = "" .
    RUN OpenBr(yes, no, '':U) .
  end.
end procedure.
PROCEDURE proc-m_gen-2 :
define buffer bf_contract for ub.contract.
do on error undo, return error return-value
:
    if p-rid-list = "" then do:
      if available buf_contract then assign p-rid-list = string(recid(buf_contract)).
    end.
vari-cycle:
  do vari = 1 to num-entries (p-rid-list):
    find first bf_contract where recid(bf_contract) = integer(entry (vari, p-rid-list)) exclusive-lock.
    if bf_contract.status_ <> 'тек':U then do:
      message "Договор " bf_contract.contract-prn-code " не в статусе " 'тек':U " . Пропускаем." view-as alert-box.
      next vari-cycle.
    end.
    if bf_contract.cr-fo = yes then do:
      message "По договору " bf_contract.contract-prn-code " уже создавалось ФО от " bf_contract.fo-date " числа." view-as alert-box.
      next vari-cycle.
    end.
    else do:
      if bf_contract.need-fo = 1 or bf_contract.need-fo = 2 then assign  bf_contract.need-fo = 0.
      else do:
        message "Данный договор не нуждался в генерации ФО." view-as alert-box.
        next vari-cycle.
      end.
      reposition Contr-List to recid recid(bf_contract) no-error.
      if not error-status:error then do:
      end.
    end.
  end.
  assign p-rid-list = "".
end.
end procedure.
PROCEDURE proc-m_gen-3 :
define buffer bf_contract for ub.contract.
define buffer buf_fin-ob-trn for ub.fin-ob-trn.
do on error undo, return error return-value
:
  if p-rid-list = "" then do:
    if available buf_contract then assign p-rid-list = string(recid(buf_contract)).
  end.
vari-cycle:
  do vari = 1 to num-entries (p-rid-list):
    find first bf_contract where recid(bf_contract) = integer(entry (vari, p-rid-list)) exclusive-lock.
    if bf_contract.status_ <> 'тек':U then do:
      message "Договор " bf_contract.contract-prn-code " не в статусе " 'тек':U " . Пропускаем." view-as alert-box.
      next vari-cycle.
    end.
    find first buf_fin-ob-trn no-lock
      where buf_fin-ob-trn.host-code      = p-host-code
        and buf_fin-ob-trn.doc-type       = "spc"
        and buf_fin-ob-trn.trn-doc-code   = string(bf_contract.contract-code)
    no-error .
    if bf_contract.cr-fo = yes or available buf_fin-ob-trn then do:
      assign g-log = no.
      message "По договору " bf_contract.contract-prn-code " было создано ФО от " bf_contract.fo-date " . Для правильной работы удалите его или создайте корректирующее ФО!" skip
                "Вы действительно хотите снять признак, что по этому договору было ФО?"
      view-as alert-box question buttons yes-no update g-log.
      if g-log <> yes then  next vari-cycle.
      assign
        bf_contract.cr-fo   = no
        bf_contract.fo-date = 01/01/1990
      .
      reposition Contr-List to recid recid(bf_contract) no-error.
    end.
    else do:
      message "По договору " bf_contract.contract-prn-code " не было генерации."
      view-as alert-box.
   end.
 end.
 assign p-rid-list = "".
end.
end procedure.
PROCEDURE proc-m_gen-4 :
  do on error undo, return error return-value :
    if p-rid-list = "" then do:
      if available buf_contract then assign p-rid-list = string(recid(buf_contract)).
    end.
    define buffer bf_contract for ub.contract.
vari-cycle:
    do vari = 1 to num-entries (p-rid-list):
      find first bf_contract where recid(bf_contract) = integer(entry (vari, p-rid-list)) exclusive-lock.
      if bf_contract.status_ <> 'тек':U then do:
        message "Договор " bf_contract.contract-prn-code " не в статусе " 'тек':U " . Пропускаем."  view-as alert-box.
        next.
      end.
      if bf_contract.need-fo = 2  then do:
        assign bf_contract.need-fo = 1  .
        reposition Contr-List to recid recid(bf_contract) no-error.
      end.
      else do:
        message "Договор " bf_contract.contract-prn-code "не имеет признака 'не опред' генерация ФО."
        view-as alert-box.
        next vari-cycle.
      end.
    end.
    assign p-rid-list = "" .
  end.
end procedure.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
  run gbl/markqwa.p (input b-mark:sensitive, input p-rid-list) no-error.
  if error-status:error then return no-apply.
  if can-do( bttns, "b-sel") then p-rid-list = "" .
END.
ON CHOOSE OF b-sch IN FRAME Dialog-Frame
DO:
  assign
    tbl = 'contract'
    join-tbl = 'buf_contract'
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
  .
  run fltfield-add in this-procedure('contract-code', 'Вн.Номер', '',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-date', 'Дата', '',       input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-prn-code', 'Номер', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-type', 'Тип', 'contract-type',   input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('usl-opl', 'Условия генерации ФО', 'usl-opl', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('str-uslov-oplat', 'Условия оплаты', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('srok-opl', 'Отсрочка', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-name', 'Заголовок', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-city', 'Город', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-date-beg', 'Дата начала договора', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-date-end', 'Дата конца договора', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('curr-code', 'Валюта', 'curr',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('user-name', 'Имя оператора', 'usr',                input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-type*cli-code'  , 'Контрагент' , 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('posr-type*posr-code'  , 'Посредник' , 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('agnt-type*agnt-code'  , 'Агент' , 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  RUN OpenBr(yes, no, '':U).
END.
END.
ON CHOOSE OF b-SlaveContract IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-cError AS CHARACTER NO-UNDO INITIAL "".
  DEFINE VARIABLE iTmp     AS INTEGER   NO-UNDO INITIAL 0.
  IF AVAILABLE buf_Contract THEN DO:
  ASSIGN
     iTmp = Is-MS-Contract-Int (BUFFER buf_Contract).
     IF iTmp = 2 THEN DO:
        MESSAGE
            "Текущий договор является подчиненным !" SKIP
            "Нельзя привязывать к подчиненному договору другие договора !" SKIP
            VIEW-AS ALERT-BOX INFO BUTTONS OK.
        RETURN NO-APPLY.
     END.
     IF iTmp = 0 AND buf_contract.status_ = 'зкр':U THEN DO:
        MESSAGE
            "Договор уже закрыт !"
            VIEW-AS ALERT-BOX INFO BUTTONS OK.
        RETURN NO-APPLY.
     END.
     RUN str/cont-slave.w  (
         input  parparentproc,
         "",
         ""  ,
         input  p-host-code,
         BUFFER buf_Contract,
         OUTPUT v-cError
         ) NO-ERROR.
     IF ERROR-STATUS:ERROR THEN DO:
        MESSAGE ERROR-STATUS:GET-MESSAGE(1) RETURN-VALUE VIEW-AS ALERT-BOX.
     END.
     IF v-cError <> "" THEN DO:
        MESSAGE v-cError VIEW-AS ALERT-BOX.
     END.
     Contr-list:REFRESH().
  END.
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
  if b-mark:sensitive = no or p-rid-list = "" then do:
    if available buf_contract then p-rid-list = string( recid( buf_contract ) ) .
  end.
END.
ON VALUE-CHANGED OF Cli-Status IN FRAME Dialog-Frame
DO:
  assign Cli-Status .
  case Cli-Status :
    when "all"     then assign p-status = ? .
    when "current" then assign p-status = 'тек':U .
    when "deleted" then assign p-status = 'зкр':U .
  end.
  RUN OpenBr(yes, no, '':U).
  apply "entry" to Contr-List .
END.
ON VALUE-CHANGED OF Cli-Types IN FRAME Dialog-Frame
DO:
  assign Cli-Types .
  if Cli-Types = "sel" then do:
    run ref/cli-all.w (parParentProc, "b-sel", 'орг':U, 'все':U, 'текущие':U, ?, ",,,,,,NO,,":u, "without-obj":U, output org-list ) .
    if org-list = "" then do:
      assign Cli-Types = "all" .
      disp Cli-Types with frame Dialog-Frame.
    end.
    else do:
      find first ub.clients no-lock where recid(ub.clients) = int(org-list) no-error .
      assign
        p-cli-type = ub.clients.obj-type
        p-cli-code = ub.clients.obj-code
      .
    end.
  end .
  RUN OpenBr(yes, no, '':U).
END.
ON value-changed OF Contr-List IN FRAME Dialog-Frame
DO:
  if available buf_contract then do:
    assign
      user-name = usrfulnf(buf_contract.user-name)
    .
    disp user-name with frame Dialog-Frame.
  end.
END.
ON RETURN OF Contr-List IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF Contr-List IN FRAME Dialog-Frame
DO:
  if b-sel:sensitive in frame Dialog-Frame then do:
    if b-mark:sensitive then apply "choose" to b-mark in frame Dialog-Frame.
    else                     apply "choose" to b-sel in frame Dialog-Frame.
  end.
  else if B-lkp:sensitive then apply "choose" to B-lkp in frame Dialog-Frame.
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
b-gen:menu-mouse = 1.
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame Dialog-Frame anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame Dialog-Frame. END.
  return no-apply.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse Contr-List :handle
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
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  Contr-List :SET-REPOSITIONED-ROW(15, "CONDITIONAL") .
end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define MENU m-ed-date30
    MENU-ITEM m-ed-date30-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date30-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date30-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date30-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      sch-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date30 :HANDLE
      sch-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle30 as handle no-undo .
  assign
    v-label-handle30 = sch-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle30)
  then do:
    if v-label-handle30 :tooltip = ""
    or v-label-handle30 :tooltip = ?
    then do:
      assign
        v-label-handle30 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date30-1 in menu m-ed-date30 DO:
    apply "ctrl-b":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date30-2 in menu m-ed-date30 DO:
    apply "ctrl-d":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date30-3 in menu m-ed-date30 DO:
    apply "ctrl-e":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date30-4 in menu m-ed-date30 DO:
    apply "ctrl-f":U to sch-date in frame Dialog-Frame .
  END.
def var sort-labelContr-List   as character no-undo .
def var sort-clmnContr-List    as handle    no-undo .
def var cur-clmnContr-List     as handle    no-undo .
def var cur-clmn-locContr-List as integer   no-undo .
def var re-queryContr-List     as logical   initial no no-undo .
on start-search, ctrl-o of Contr-List in frame Dialog-Frame do:
   run sort-brContr-List
     (input (if available buf_contract
             then recid(buf_contract)
             else ?
            )
     ).
end.
PROCEDURE sort-brContr-List :
  define input parameter p-recid as recid no-undo .
  if re-queryContr-List = no then do:
    assign
       cur-clmnContr-List = Contr-List:current-column in frame Dialog-Frame
    .
    if sort-clmnContr-List <> ? then sort-clmnContr-List:column-fgcolor = 0.
    if cur-clmnContr-List = sort-clmnContr-List then do:
      assign
         sort-labelContr-List = ""
         sort-clmnContr-List = ?
      .
     end.
     else do:
       assign
         sort-labelContr-List = cur-clmnContr-List:label
         sort-clmnContr-List  = cur-clmnContr-List
         sort-clmnContr-List:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locContr-List = 1
  .
  def var column-handle as handle no-undo .
  column-handle = Contr-List:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnContr-List then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locContr-List = cur-clmn-locContr-List + 1
    .
  end.
  case sort-labelContr-List:
        when 'Ста!тус'  then DO:    assign       sort-column-name = "buf_contract.status_"     .     run OpenBr(yes, no, no).   . END.
        when 'Номер'  then DO:    assign       sort-column-name = "buf_contract.contract-prn-code"     .     run OpenBr(yes, no, no).   . END.
        when 'Дата!договора'  then DO:    assign       sort-column-name = "buf_contract.contract-date"     .     run OpenBr(yes, no, no).   . END.
        when 'Заголовок'  then DO:    assign       sort-column-name = "buf_contract.contract-name"     .     run OpenBr(yes, no, no).   . END.
        when 'Тип/код!контрагента'  then DO:    assign       sort-column-name = "(if buf_contract.cli-type = '' then '' else TRIM (buf_contract.cli-type + ' ' + STRING (buf_contract.cli-code) ))"     .     run OpenBr(yes, no, no).   . END.
        when 'Контрагент'  then DO:    assign       sort-column-name = "buf_contract.cli-name"     .     run OpenBr(yes, no, no).   . END.
        when 'Тип договора'  then DO:    assign       sort-column-name = "buf_contract.contract-type"     .     run OpenBr(yes, no, no).   . END.
        when 'Условия!оплаты'  then DO:    assign       sort-column-name = "buf_contract.usl-opl"     .     run OpenBr(yes, no, no).   . END.
        when 'Отс-!роч.'  then DO:    assign       sort-column-name = "(if buf_contract.srok-opl > 0 then string(buf_contract.srok-opl) else '')"     .     run OpenBr(yes, no, no).   . END.
        when 'Город'  then DO:    assign       sort-column-name = "buf_contract.contract-city"     .     run OpenBr(yes, no, no).   . END.
        when 'Начало!действия'  then DO:    assign       sort-column-name = "buf_contract.contract-date-beg"     .     run OpenBr(yes, no, no).   . END.
        when 'Окончание!действия'  then DO:    assign       sort-column-name = "buf_contract.contract-date-end"     .     run OpenBr(yes, no, no).   . END.
        when 'Тип/код!посредника'  then DO:    assign       sort-column-name = "(if buf_contract.posr-type = '' then '' else TRIM (buf_contract.posr-type + ' ' + STRING (buf_contract.posr-code)))"     .     run OpenBr(yes, no, no).   . END.
        when 'Посредник'  then DO:    assign       sort-column-name = "buf_contract.posr-name"     .     run OpenBr(yes, no, no).   . END.
        when 'Тип/код!агента'  then DO:    assign       sort-column-name = "(if buf_contract.agnt-type = '' then '' else TRIM (buf_contract.agnt-type + ' ' + STRING (buf_contract.agnt-code)))"     .     run OpenBr(yes, no, no).   . END.
        when 'Агент'  then DO:    assign       sort-column-name = "buf_contract.agnt-name"     .     run OpenBr(yes, no, no).   . END.
        when 'Вид'  then DO:    assign       sort-column-name = "buf_contract.doc-type"     .     run OpenBr(yes, no, no).   . END.
        when 'Вн.н.'  then DO:    assign       sort-column-name = "buf_contract.contract-code"     .     run OpenBr(yes, no, no).   . END.
        when 'БД'  then DO:    assign       sort-column-name = "buf_contract.db-num"     .     run OpenBr(yes, no, no).   . END.
        when 'Вал'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1get-currency&1, &1&2&1)', chr(34), buf_contract.curr-code)     .     run OpenBr(yes, no, no).   . END.
        when 'Исполнитель'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1get-agent&1, &1&2&1)', chr(34), buf_contract.mngr-code)     .     run OpenBr(yes, no, no).   . END.
        when 'Фин.об.'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1fo&1, &1&2&1, &1&3&1, &1&4&1)', chr(34), buf_contract.cr-fo, buf_contract.fo-date, buf_contract.need-fo)     .     run OpenBr(yes, no, no).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr(yes, no, no).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultContr-List') then do:
          run mv-brw-defaultContr-List.
        end.
      if sort-labelContr-List <> "" then do:
        assign
          cur-clmnContr-List:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locContr-List = ?
      .
    end.
  end case.
    if cur-clmn-locContr-List <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnContr-List') then do:
        run ch-clmnContr-List in this-procedure (cur-clmn-locContr-List).
      end.
    end.
  if p-recid <> ? then do:
    reposition Contr-List to recid p-recid no-error.
    apply "value-changed" to Contr-List in frame Dialog-Frame.
  end.
  apply "entry" to Contr-List in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnContr-List:
if cur-clmnContr-List = ? then do:
   run OpenBr(yes, no, no).
end.
else do:
   assign re-queryContr-List = yes.
   run sort-brContr-List
     (input (if available buf_contract
             then recid(buf_contract)
             else ?
            )
     ).
   assign re-queryContr-List = no.
end.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if p-cli-code <> ? and p-cli-type <> ? then do:
    find first ub.clients no-lock where ub.clients.obj-type = p-cli-type and ub.clients.obj-code = p-cli-code no-error .
    if available ub.clients then assign Cli-Types  = "sel" .
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-cli-type " p-cli-type " и p-cli-code" p-cli-code
      view-as alert-box ERROR.
      return.
    end.
  end.
  if p-mngr-code <> ? and p-mngr-type <> ? then do:
    find first ub.clients no-lock where ub.clients.obj-type = p-mngr-type and ub.clients.obj-code = p-mngr-code no-error .
    if available ub.clients then assign Agnt-Types  = "sel" .
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-mngr-type " p-mngr-type " и p-mngr-code" p-mngr-code
      view-as alert-box ERROR.
      return.
    end.
  end.
  case p-doc-type :
    when "all" or when 'при':U or when 'рас':U  then .
    OTHERWISE do:
      message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-doc-type"  p-doc-type
      view-as alert-box ERROR.
      return.
    end.
  end.
  assign
    Contr-List:MAX-DATA-GUESS IN FRAME Dialog-Frame     = 200
    Contr-List:num-locked-columns = 4
    buf_contract.contract-type:read-only in browse Contr-List = yes
  .
  assign Cli-Status = p-status .
  case Cli-Status :
    when "all"     then assign p-status = ? .
    when "current" then assign p-status = 'тек':U .
    when "deleted" then assign p-status = 'зкр':U .
    OTHERWISE do:
      message
       vss-workfile vss-revision vss-description skip
       "Неверное значение параметра вызова p-status"  p-status
      view-as alert-box ERROR.
      return.
    end.
  end.
define variable v-right-supp as logical no-undo .
define variable v-right-buyer as logical   no-undo .
  v-right-supp = true .
  v-right-buyer = true .
  if p-doc-type = "all"  or p-doc-type =  'при':U then do:
define variable vss-include-info33 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-supp':U
    ,input  'firm':U
    ,input  p-host-code
    ,input  ''
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-right-supp
    ) no-error .
end.
   if error-status :error then v-right-supp = false .
  end.
  if p-doc-type = "all"  or p-doc-type =  'рас':U then do:
define variable vss-include-info34 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-buyer':U
    ,input  'firm':U
    ,input  p-host-code
    ,input  ''
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-right-buyer
    ) no-error .
end.
  if error-status :error then v-right-buyer = false .
  end.
  if v-right-supp = false or v-right-buyer = false  then return .
  RUN enable_UI in this-procedure .
  RUN StartProc in this-procedure.
  apply "entry" to Contr-List .
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numContr-List as INT EXTENT 20 no-undo.
DEF VAR varmviContr-List       as INT no-undo.
DEF VAR varmvjContr-List       as INT no-undo.
DEF VAR varmvkContr-List       as INT no-undo.
DEF VAR varmvlContr-List       as INT no-undo.
DEF VAR move-elementContr-List as INT no-undo.
def var jjContr-List           as int no-undo.
do varmviContr-List = 1 to EXTENT(cur-clmn-numContr-List):
  ASSIGN cur-clmn-numContr-List[varmviContr-List] = varmviContr-List.
END.
RUN start-mv-clmnContr-List.
PROCEDURE start-mv-clmnContr-List:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE Contr-List do:
  RUN re-move-clmnContr-List ( 5, 20).
END.
ON ctrl-cursor-left OF BROWSE Contr-List do:
  RUN re-move-clmnContr-List (20, 5).
END.
PROCEDURE re-move-clmnContr-List:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmviContr-List = 1 TO EXTENT(cur-clmn-numContr-List):
    if cur-clmn-numContr-List[varmviContr-List] = source-column THEN cur-clmn-numContr-List[varmviContr-List] = -1.
  END.
  if Contr-List:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjContr-List = source-column - 1 to target-column BY -1:
    DO varmviContr-List = 1 TO EXTENT(cur-clmn-numContr-List):
        if cur-clmn-numContr-List[varmviContr-List] = varmvjContr-List THEN DO:
          cur-clmn-numContr-List[varmviContr-List] = cur-clmn-numContr-List[varmviContr-List] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjContr-List = source-column + 1 to target-column:
    DO varmviContr-List = 1 TO EXTENT(cur-clmn-numContr-List):
      if cur-clmn-numContr-List[varmviContr-List] = varmvjContr-List THEN DO:
        cur-clmn-numContr-List[varmviContr-List] = cur-clmn-numContr-List[varmviContr-List] - 1.
      END.
    END.
  END.
  DO varmviContr-List = 1 TO EXTENT(cur-clmn-numContr-List):
    if cur-clmn-numContr-List[varmviContr-List] = -1 THEN cur-clmn-numContr-List[varmviContr-List] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnContr-List:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 5 then do:
    return .
  end.
  DO varmviContr-List = 1 TO EXTENT(cur-clmn-numContr-List):
    if cur-clmn-numContr-List[varmviContr-List] = cur-clmn-loc THEN move-elementContr-List = varmviContr-List.
  END.
  RUN re-move-clmnContr-List (cur-clmn-loc, 5).
END PROCEDURE.
PROCEDURE mv-brw-defaultContr-List:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlContr-List = 5 to EXTENT(cur-clmn-numContr-List):
    RUN re-move-clmnContr-List (cur-clmn-numContr-List[varmvlContr-List], varmvlContr-List).
  END.
  RUN start-mv-clmnContr-List.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY sch-code sch-date Cli-Types Agnt-Types Cli-Status mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit RECT-status B-mark B-sel b-gen b-sch b-SlaveContract b-spec b-specgrp B-Help B-lkp b-chg b-del
         b-open b-trn-doc B-fin-ob B-fin-doc b-hist b-exp b-imp B-add Contr-List sch-code sch-date
         Cli-Types Agnt-Types Cli-Status mark-num b-order
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE OpenBr :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  run OpenBr2 ( p-open-query, p-find-next, p-find-condition) .
END PROCEDURE.
PROCEDURE OpenBr2 :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  define variable l-query-was-opened as logical no-undo .
  define variable title0 as character no-undo.
  title0 = "Список договоров" + chr(32).
  if p-contr-type <> chr(1) then title0 = title0 + p-contr-type  + chr(32).
  define variable sort-column-phrase as character no-undo .
  case sort-column-name :
    when "" then assign  sort-column-phrase = ""  .
    otherwise    assign  sort-column-phrase = "by " + sort-column-name .
  end case.
  define variable l-open-query as logical   no-undo .
  filter-point = filter-point0 + p-mode.
  find first ub.clients no-lock where ub.clients.obj-type = 'орг':U and ub.clients.obj-code = p-host-code .
  if p-doc-type = 'при':U then ASSIGN title0  = title0 + "с поставщиками." + chr(32) .
  else                           ASSIGN title0  = title0 + "с покупателями." + chr(32) .
  ASSIGN title0  = title0 + " Фирма: (" + string(p-host-code) + ")":U + chr(32) + ub.clients.obj-name .
      if Agnt-Types = "all" and Cli-Types = "sel" then do:
        find first ub.clients no-lock where ub.clients.obj-type = p-cli-type and ub.clients.obj-code = p-cli-code .
        ASSIGN  frame Dialog-Frame:TITLE = title0 + " Контрагент: (" + p-cli-type + " " + string(p-cli-code) + ")":U + chr(32) + ub.clients.obj-name .
          OPEN QUERY Contr-List
              FOR EACH buf_contract no-lock
              where buf_contract.host-code  = p-host-code and buf_contract.doc-type = p-doc-type and buf_contract.status_ = p-status  and buf_contract.cli-type = p-cli-type
              and buf_contract.cli-code = p-cli-code and ( p-contr-type = chr(1) or buf_contract.contract-type = p-contr-type)
              and (buf_contract.contract-date-end >= today or buf_contract.contract-date-end = ?)
              and buf_contract.contract-date-beg <= today
              , first buf_contract-attr no-lock where buf_contract-attr.contract-code = buf_contract.contract-code and buf_contract-attr.attr-code = p-attr-code and
              buf_contract-attr.host-code = buf_contract.host-code and buf_contract-attr.attr-value = string(true)
            .
      end.
  if v-doc-rec = ? then do:
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  Contr-List :SET-REPOSITIONED-ROW(9, "CONDITIONAL") .
end.
  end.
  else do:
    REPOSITION Contr-List to recid v-doc-rec No-ERROR.
    if error-status:error then do:
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  Contr-List :SET-REPOSITIONED-ROW(9, "CONDITIONAL") .
end.
    end.
  end.
END PROCEDURE.
PROCEDURE proc-find-code :
  define input parameter p-next as logical no-undo.
  define input parameter p-code as character no-undo .
  display "  /  /":U @ sch-date with frame Dialog-Frame.
  assign p-code = chr(34) + p-code + chr(34).
  if p-code = '""' then do:
    run OpenBr in this-procedure
      (input false
      ,input p-next
      ,input substitute("and buf_contract.contract-prn-code = '' " )
    ).
  end.
  else do:
    run OpenBr in this-procedure
      (input false
      ,input p-next
      ,input substitute("and buf_contract.contract-prn-code  begins &1 "
      , p-code)
      ).
  end.
  apply "entry":u to sch-code in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-date :
  define input parameter p-next as logical no-undo.
  define input parameter par-date as date    no-undo .
  display "":U @ sch-code with frame Dialog-Frame.
  define variable var-datechr as character no-undo .
  assign var-datechr = string(day(par-date)) + chr(47) + string(month(par-date)) + chr(47) + string(year(par-date)) .
  run OpenBr in this-procedure (input false ,input p-next ,input substitute("and buf_contract.contract-date = &1 ", var-datechr)).
  apply "entry":u to sch-date in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE StartProc :
  DEFINE VARIABLE v-hdl AS HANDLE NO-UNDO .
  DISABLE
    b-sel   when  NOT can-do( bttns, "b-sel" )
    b-mark  when  NOT can-do( bttns, "b-mark")
    b-add   when (NOT can-do( bttns, "b-add" ) or p-doc-type = "all")
    b-chg   when  NOT can-do( bttns, "b-chg" )
    b-del   when  NOT can-do( bttns, "b-del" )
    b-open  when  NOT can-do( bttns, "b-open")
    b-SlaveContract when v-MS-Can-Do-List = "1"
  WITH FRAME Dialog-Frame.
  if p-doc-type <> 'при':U then DISABLE b-gen WITH FRAME Dialog-Frame.
  define variable v-db-num  as integer no-undo .
  define variable v-ret as logical no-undo .
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
  run ver-db (input p-host-code,  input v-db-num, input false, output v-ret ) no-error .
  if error-status :error or v-ret = false then do:
     disable   B-fin-ob    B-fin-doc  b-specgrp   with frame Dialog-Frame.
  end.
  if mark-num = 0 then hide mark-num in frame Dialog-Frame.
  if p-rid-list <> "":U then assign v-doc-rec = integer(entry(1, p-rid-list)) .
  p-contr-type = chr(1) .
  if num-entries(p-mode,"=") = 2 then do:
     if entry(1,p-mode,"=") = "contract-type" then do:
        p-contr-type = entry(2,p-mode,"=") .
     end.
  end.
  IF v-iMcMode = 0 THEN DO:
     v-hdl = Contr-list:FIRST-COLUMN .
     DO WHILE VALID-HANDLE(v-hdl):
         IF v-hdl:LABEL = 'Мастер!Договор':U THEN v-hdl:VISIBLE = NO.
            v-hdl = v-hdl:NEXT-COLUMN .
     END.
     ASSIGN
        b-SlaveContract:HIDDEN = TRUE.
  END.
  Run OpenBR in this-procedure (yes, no, '':U) no-error  .
END PROCEDURE.
PROCEDURE run-contr :
define input parameter p-stat as character no-undo .
define input parameter p-fict as logical   no-undo .
  define variable v-doc-tp as character no-undo .
  define variable ri as recid no-undo .
  if p-stat <> 'ДОБАВЛЕНИЕ':U then do:
    assign
      ri = recid( buf_contract )
      v-doc-tp = buf_contract.doc-type
    .
  end.
  else assign v-doc-tp = p-doc-type .
  if p-stat = 'ПРОСМОТР':U then do:
    br-handle = Contr-List:handle in frame Dialog-Frame .
    next-prev = no.
    do while next-prev <> ?:
      if not available buf_contract then do:
        message "Неправильный выбор документа.".
        return.
      end.
      run str/contr.w ( input parParentProc,input p-host-code, input p-stat, input v-doc-tp, input-output ri) no-error.
      if error-status:error then return no-apply.
      if br-handle = ? then reposition Contr-List to recid ri no-error.
    end.
  end.
  else do:
    if p-contr-type = chr(1) then
       run str/contr.w ( input parParentProc,input p-host-code, input p-stat, input v-doc-tp, input-output ri) no-error.
    else
       run str/contr.w ( input parParentProc,input p-host-code, input p-stat, input "contract-type=" + p-contr-type, input-output ri) no-error.
    if error-status:error then return no-apply.
  end.
  v-doc-rec = ri .
  run openbr in this-procedure (yes, no, '':u).
END PROCEDURE.
procedure proc-del :
  DEFINE VARIABLE v-cError as CHARACTER NO-UNDO INITIAL "".
  DEFINE VARIABLE iTmp        as INTEGER   NO-UNDO INITIAL 0.
  do on error undo, return error return-value :
    if buf_contract.status_ = 'зкр':U then do:
      message "Договор уже закрыт!" view-as alert-box.
      return .
    end.
    ASSIGN
       iTmp = Is-MS-Contract-Int (BUFFER buf_Contract).
    CASE iTmp:
         WHEN 1 THEN DO:
define variable vss-include-info39 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fo-mc_master-open-close':U
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
               if not g-log then return no-apply.
         END.
         WHEN 2 THEN DO:
define variable vss-include-info40 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fo-mc_slave-open-close':U
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
               if not g-log then return no-apply.
         END.
    END CASE.
    message
      "Закрыть договор №" buf_contract.contract-prn-code "от" buf_contract.contract-date "?"
      view-as alert-box QUESTION BUTTONS YES-NO update g-log .
    if g-log = no then return .
define variable vss-include-info41 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-contract_deletion':U
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
    if not g-log then return .
    v-doc-rec = recid( buf_contract ).
    do transaction :
       find first contract exclusive-lock where recid(contract) = recid(buf_contract) no-error .
       if available contract then do:
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdburt in g#library
  (output buf_contract.user-db-num
  ,output buf_contract.user-name
  ,output p-sys-date
  ,output p-sys-time
  ,output p-sys-time-int
  )  .
          ASSIGN
             contract.status_ = 'зкр':U
             .
       end.
       if Is-MS-Contract-Int (BUFFER buf_Contract) = 1 THEN DO:
          RUN Change-Stat-Slave-Contract in THIS-PROCEDURE(
              BUFFER buf_Contract,
              'зкр':U,
              OUTPUT v-cError
              ).
          if v-cError <> "" THEN DO:
             MESSAGE
                v-cError
                VIEW-AS ALERT-BOX INFO BUTTONS OK.
             RETURN ERROR v-cError.
          END.
       END.
    end.
  end.
end procedure.
procedure proc-sel-agent :
  do on error undo, return error return-value :
    run ref/cli-all.w ( parParentProc, "b-sel", 'чел':U, 'все':U, 'текущие':U, ?, ",,,,,,NO,,":u, "without-obj":U, output agnt-list ) .
    if agnt-list = "" then do:
      assign Agnt-Types = "all"  .
      DISPLAY Agnt-Types with frame Dialog-Frame .
    end.
    else do:
      find first ub.clients no-lock where recid(ub.clients) = int(agnt-list) no-error .
      assign
        p-mngr-code = ub.clients.obj-code
        p-mngr-type = ub.clients.obj-type
      .
    end.
  end.
end procedure.
procedure proc-open :
  DEFINE VARIABLE v-cError    as CHARACTER NO-UNDO INITIAL "".
  DEFINE VARIABLE iTmp        as INTEGER   NO-UNDO INITIAL 0.
  do on error undo, return error return-value :
    if buf_contract.status_ = 'тек':U then do:
      message "Договор уже открыт!" view-as alert-box.
      return no-apply.
    end.
    if can-find(first ub.contract no-lock where
                      ub.contract.host-code = buf_contract.host-code
                  AND ub.contract.cli-type = buf_contract.cli-type
                  AND ub.contract.cli-code = buf_contract.cli-code
                  and ub.contract.contract-type = 'Продажи через ТПСИ':U
                  and ub.contract.status_       = 'тек':U
                  ) then do:
        message
        "Нельзя открыть договор типа <Продажа через ТПСИ>," skip
        "уже есть действующий договор этого типа с фирмой" buf_contract.cli-code
        view-as alert-box error .
        return error .
    end.
    ASSIGN
       iTmp = Is-MS-Contract-Int (BUFFER buf_Contract).
    CASE iTmp:
         WHEN 1 THEN DO:
define variable vss-include-info43 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fo-mc_master-open-close':U
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
               if not g-log then return no-apply.
         END.
         WHEN 2 THEN DO:
define variable vss-include-info44 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fo-mc_slave-open-close':U
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
               if not g-log then return no-apply.
         END.
    END CASE.
    message
      "Открыть договор №" buf_contract.contract-prn-code "от" buf_contract.contract-date "?"
      view-as alert-box QUESTION BUTTONS YES-NO update g-log .
    if g-log = no then return no-apply.
define variable vss-include-info45 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-contract_deletion':U
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
    if not g-log then return no-apply.
    v-doc-rec = recid( buf_contract ).
    do transaction :
      find first contract exclusive-lock where recid(contract) = recid(buf_contract) no-error .
      if available contract then do:
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdburt in g#library
  (output buf_contract.user-db-num
  ,output buf_contract.user-name
  ,output p-sys-date
  ,output p-sys-time
  ,output p-sys-time-int
  )  .
         ASSIGN
            contract.status_ = 'тек':U
            .
       IF iTmp = 1 THEN DO:
          RUN Change-Stat-Slave-Contract in THIS-PROCEDURE(
              BUFFER buf_Contract,
              'тек':U,
              OUTPUT v-cError
              ).
          if v-cError <> "" THEN DO:
             MESSAGE
                v-cError
                VIEW-AS ALERT-BOX INFO BUTTONS OK.
             RETURN ERROR v-cError.
          END.
       END.
      end.
    end.
  end.
end procedure.
PROCEDURE proc-b-exp :
  define variable v-file-name as character no-undo .
  if not available buf_contract then return no-apply.
  define variable v-sys-key   as character         no-undo.
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currsysk in g#library
  (output v-sys-key
  ) no-error .
  assign  v-file-name =  ? .
  run str/xmlcontr.p (input buf_contract.host-code, buf_contract.contract-code, input-output v-file-name, yes, yes) no-error .
  if error-status:error then do:
    message   "Ошибка при выгрузке платежа в XML-формате"  view-as alert-box .
    return error .
  end.
  if search ("exmldoc.bat") <> ? then do:
    os-command silent value(search ("exmldoc.bat") + " " + v-file-name + " " + v-sys-key).
  end.
  else do:
    if search (v-file-name ) <> ? then message "Документ(-ы) выгружен(-ы) в файл " v-file-name view-as alert-box.
  end.
END PROCEDURE.
PROCEDURE proc-b-imp :
define variable mFileName         as character        no-undo.
define variable vFileName         as character no-undo.
define variable v-log-file-name   as character no-undo .
define variable v-last-slash-pos  as integer no-undo .
define variable varlog            as logical   no-undo.
define variable mExcelApplication as component-handle no-undo.
define variable mWorkBook         as component-handle no-undo.
define variable mWorkSheet        as component-handle no-undo.
define variable mRange            as component-handle no-undo .
  system-dialog get-file mFileName title "Выберите файл с ценами поставки"
    filters "MS Excel (*.xls,*.xlsx)" "*.xls,*.xlsx",
            "Все файлы" "*.*"
    initial-filter 1
    must-exist
    update varlog.
  if not varlog then return error "Отказ от импорта" .
  ASSIGN
    FILE-INFO:FILE-NAME = mFileName
    vFilename           = FILE-INFO:FULL-PATHNAME
  .
  IF LENGTH(vFileName) > 0 THEN .
  ELSE RETURN ERROR SUBSTITUTE("Не найден файл &1", mFileName).
  v-last-slash-pos = max (
    r-index(vFilename, "/"),
    r-index(vFilename, "\")
                         ) .
  v-log-file-name  = substitute("&1&2.log"
    , ibs.th.gbl.gbl-inipar:logDir
    , entry(1, substring(vFileName, v-last-slash-pos + 1), ".")
                                ) .
  empty temp-table t-imp-price .
  create "Excel.Application":U mExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
  assign
    mExcelApplication:DisplayAlerts = no
    mWorkbook                       = mExcelApplication:WorkBooks:Add(vFileName)
    mWorkSheet                      = mWorkbook:Sheets:Item(1)
  .
  define variable vLine   as integer   no-undo.
  define variable vsContractCode as character no-undo .
  define variable vContractCode  as integer no-undo .
  define variable vsFirmCode     as character no-undo .
  define variable vFirmCode      as integer no-undo .
  define variable vsGdsCode      as character no-undo .
  define variable vGdsCode       as integer no-undo .
  define variable vsPriceRubl    as character no-undo .
  define variable vPriceRubl     as decimal no-undo .
  define variable vsVatPc        as character no-undo .
  define variable vVatPc         as decimal no-undo .
  define variable vsPrcUp        as character no-undo .
  define variable vPrcUp         as decimal no-undo .
  define variable vsPrcDn        as character no-undo .
  define variable vPrcDn         as decimal no-undo .
  define variable vsGdsName      as character no-undo .
  define variable vsFirmName     as character no-undo .
  loopbl:
  do vLine = 2 to 1000000:
    mRange = mWorkSheet:Range(  substitute("A&1":U, vLine)  ) .
    vsContractCode = mRange:formula .
    mRange = mWorkSheet:Range(  substitute("B&1":U, vLine)  ) .
    vsFirmCode     = mRange:formula .
    mRange = mWorkSheet:Range(  substitute("C&1":U, vLine)  ) .
    vsGdsCode      = mRange:formula .
    assign
      vContractCode = integer (vsContractCode)
      vFirmCode     = integer (vsFirmCode)
      vGdsCode      = integer (vsGdsCode)
    no-error .
    if (not error-status:error) and (vContractCode > 0) and (vFirmCode > 0) and (vGdsCode > 0) then .
    else leave loopbl.
    mRange = mWorkSheet:Range(  substitute("D&1":U, vLine)  ) .
    vPriceRubl     = mRange:value no-error .
    if vPriceRubl = ? then assign
      vsPriceRubl = mRange:formula
      vPriceRubl  = func-char-to-dec( vsPriceRubl )
    .
    mRange = mWorkSheet:Range(  substitute("E&1":U, vLine)  ) .
    vVatPc         = mRange:value no-error .
    if vVatPc = ? then assign
      vsVatPc = mRange:formula
      vVatPc  = func-char-to-dec( vsVatPc )
    .
    mRange = mWorkSheet:Range(  substitute("F&1":U, vLine)  ) .
    vPrcUp         = mRange:value no-error .
    if vPrcUp = ? then assign
      vsPrcUp = mRange:formula
      vPrcUp  = func-char-to-dec( vsPrcUp )
    .
    mRange = mWorkSheet:Range(  substitute("G&1":U, vLine)  ) .
    vPrcDn         = mRange:value no-error .
    if vPrcDn = ? then assign
      vsPrcDn = mRange:formula
      vPrcDn  = func-char-to-dec( vsPrcDn )
    .
    mRange = mWorkSheet:Range(  substitute("H&1":U, vLine)  ) .
    vsGdsName = mRange:formula .
    mRange = mWorkSheet:Range(  substitute("I&1":U, vLine)  ) .
    vsFirmName = mRange:formula .
    create t-imp-price .
    assign
      t-imp-price.contract-code = vContractCode
      t-imp-price.firm-code     = vFirmCode
      t-imp-price.gds-code      = vGdsCode
      t-imp-price.price-rubl    = (if vPriceRubl > 0.00000000005 then vPriceRubl else 0)
      t-imp-price.vat-pc        = (if vVatPc     > 0.00000000005 then vVatPc     else 0)
      t-imp-price.prc-up        = (if vPrcUp     > 0.00000000005 then vPrcUp     else 0)
      t-imp-price.prc-dn        = (if vPrcDn     > 0.00000000005 then vPrcDn     else 0)
      t-imp-price.gds-name      = vsGdsName
      t-imp-price.firm-name     = vsFirmName
      t-imp-price.line-num      = vLine
    no-error .
    if error-status:error then leave loopbl.
  end.
  mWorkbook:Close(true) no-error.
  release object mWorkSheet no-error.
  release object mWorkbook no-error.
  mExcelApplication:QUIT() no-error.
  release object mExcelApplication no-error.
define variable v-today      as date no-undo .
define variable v-i-retry    as integer no-undo .
define variable v-prc-min    as decimal no-undo .
define variable v-num-passed as integer no-undo .
define variable v-num-count  as integer no-undo .
define variable v-has-errors as logical no-undo .
define variable v-is-firm    as logical no-undo .
define variable v-host-code  as integer no-undo .
define variable v-contract-code as integer no-undo .
define buffer imp_buf_contract             for ub.contract .
define buffer imp_buf_contract-specif      for ub.contract-specif .
define buffer imp_buf_contract-specif-attr for ub.contract-specif-attr .
define buffer imp_buf_goods                for ub.goods .
  assign
    v-today      = today
    v-num-passed = 0
    v-num-count  = 0
    v-has-errors = false
  .
  output stream f-log-imp to value (v-log-file-name) .
  for each t-imp-price by t-imp-price.line-num :
    v-num-count = v-num-count + 1 .
    if t-imp-price.price-rubl > 0 then . else do :
      put stream f-log-imp unformatted
         substitute("Ошибка в строке №&1. Не указана/ Равна нулю цена товара с НДС",
                     t-imp-price.line-num)
        skip
      .
      v-has-errors = true .
      next .
    end .
    if not can-find (first imp_buf_goods where imp_buf_goods.gds-code = t-imp-price.gds-code) then do :
      put stream f-log-imp unformatted
         substitute("Ошибка в строке №&1. В Системе отсутствует товар с кодом &2",
                   t-imp-price.line-num, t-imp-price.gds-code)
        skip
      .
      v-has-errors = true .
      next .
    end .
    find first imp_buf_contract no-lock
         where imp_buf_contract.host-code     = p-host-code
           and imp_buf_contract.contract-code = t-imp-price.contract-code no-error .
    if not available imp_buf_contract then do :
      put stream f-log-imp unformatted
         substitute("Ошибка в строке №&1. В Системе не найдено текущего договора с № &2",
                   t-imp-price.line-num, t-imp-price.contract-code)
        skip
      .
      v-has-errors = true .
      next .
    end .
    else do :
      v-host-code     = imp_buf_contract.host-code .
      v-contract-code = imp_buf_contract.contract-code .
    end .
    if not can-find (first clients where clients.obj-code = t-imp-price.firm-code) then do :
      put stream f-log-imp unformatted
         substitute("Ошибка в строке №&1. В Системе отсутствует контрагент с кодом &2",
                   t-imp-price.line-num, t-imp-price.firm-code)
        skip
      .
      v-has-errors = true .
      next .
    end .
    if imp_buf_contract.cli-code <> t-imp-price.firm-code then do :
      put stream f-log-imp unformatted
         substitute("Ошибка в строке №&1. Для договора &2 указан некорректный контрагент &3",
                   t-imp-price.line-num, t-imp-price.contract-code, t-imp-price.firm-code)
        skip
      .
      v-has-errors = true .
      next .
    end .
    if imp_buf_contract.status_ <> 'тек':U then do :
      put stream f-log-imp unformatted
         substitute("Ошибка в строке №&1. Договор &2 закрыт и не подлежит изменению.",
                   t-imp-price.line-num, t-imp-price.contract-code)
        skip
      .
      v-has-errors = true .
      next .
    end .
    if imp_buf_contract.contract-date-end < v-today then do :
      put stream f-log-imp unformatted
         substitute("Ошибка в строке №&1. У договора &2 истёк срок действия &3.",
                   t-imp-price.line-num, t-imp-price.contract-code, imp_buf_contract.contract-date-end)
        skip
      .
      v-has-errors = true .
      next .
    end .
    v-i-retry = 0 .
do transaction :
    repeat :
      find first imp_buf_contract-specif exclusive-lock
           where imp_buf_contract-specif.host-code    = v-host-code
             and imp_buf_contract-specif.contract-num = v-contract-code
             and imp_buf_contract-specif.gds-code     = t-imp-price.gds-code no-error no-wait .
      if available imp_buf_contract-specif then do :
        if (t-imp-price.prc-dn > 0) then do :
          find first imp_buf_contract-specif-attr exclusive-lock
               where imp_buf_contract-specif-attr.host-code    = v-host-code
                 and imp_buf_contract-specif-attr.contract-num = v-contract-code
                 and imp_buf_contract-specif-attr.gds-code     = t-imp-price.gds-code
                 and imp_buf_contract-specif-attr.attr-code    = 'prc-min':U no-error .
          if locked imp_buf_contract-specif-attr then do :
            v-i-retry = v-i-retry + 1 .
            if v-i-retry > 5 then leave .
            pause 1 no-message .
            next .
          end .
        end .
        if (t-imp-price.prc-up > 0) and (t-imp-price.prc-dn > 0) then . else do :
          put stream f-log-imp unformatted
             substitute("Ошибка в строке №&1. Допустимый % отклонения равен нулю и остается прежним в Системе.",
                       t-imp-price.line-num)
            skip
          .
          v-has-errors = true .
        end .
        if imp_buf_contract-specif.price-cli <> t-imp-price.price-rubl then assign
           imp_buf_contract-specif.price-cli  = t-imp-price.price-rubl
           imp_buf_contract-specif.sum-cli    = imp_buf_contract-specif.price-cli * imp_buf_contract-specif.qnty
        .
        assign
          imp_buf_contract-specif.VAT-pc      = t-imp-price.vat-pc
    when (imp_buf_contract-specif.VAT-pc     <> t-imp-price.vat-pc)
          imp_buf_contract-specif.prc         = t-imp-price.prc-up
    when (
         (t-imp-price.prc-up > 0) and
         (imp_buf_contract-specif.prc        <> t-imp-price.prc-up)
         )
          v-num-passed = v-num-passed + 1
        .
        if (t-imp-price.prc-dn > 0) and (available imp_buf_contract-specif-attr) then do :
          v-prc-min = decimal (imp_buf_contract-specif-attr.attr-value) no-error .
          assign
            imp_buf_contract-specif-attr.attr-value = string(t-imp-price.prc-dn)
              when ( v-prc-min <> t-imp-price.prc-dn )
          .
        end .
        leave .
      end .
      else if locked imp_buf_contract-specif then do :
        v-i-retry = v-i-retry + 1 .
        if v-i-retry > 5 then leave .
        pause 1 no-message .
        next .
      end .
      else do :
        put stream f-log-imp unformatted
           substitute("Ошибка в строке №&1. Товар &2 не привязан к договору &3",
                     t-imp-price.line-num, t-imp-price.gds-code, t-imp-price.contract-code)
          skip
        .
        v-has-errors = true .
        leave .
      end .
    end .
end .
  end .
  output stream f-log-imp close .
define variable v-user-action as character no-undo .
define variable v-printed     as logical no-undo .
define variable r-var1        as character no-undo initial "прочитайте" .
define variable r-var2        as character no-undo initial "!!!" .
define variable v-global-panic as character no-undo initial "" .
if (v-num-passed < v-num-count) or v-has-errors then do :
    case r-var1 :
      when "прочитайте" then do :
    v-global-panic = "При проверке информации произошли ошибки" + r-var2 + chr(10) +
            r-var2 + "Внимательно " + r-var1 + " Log-file" + r-var2 .
      end .
      when "съешьте" then do :
    v-global-panic = "При проверке информации произошли ошибки" + r-var2 + chr(10) +
            r-var2 + "Аккуратно " + r-var1 + " Log-file" + r-var2 .
      end .
      otherwise do :
      end .
    end case .
end .
message
 "Статус загрузки - завершена." skip
 substitute ("Обработанно &1 строк из файла импорта, загруженно в систему &2 строк.",
             v-num-count, v-num-passed) skip(1)
 v-global-panic
view-as alert-box .
if (v-num-passed < v-num-count) or v-has-errors then do :
    run gbl/prnfilen.w (
          input "Ошибки, возникшие при проверке импортируемого файла":U
        , input 7
        , input v-log-file-name
        , input 7
        , output v-user-action
        , output v-printed
    ).
end .
END PROCEDURE.
FUNCTION get-agent RETURNS CHARACTER
  ( input agnt-code as integer ) :
define variable var-cli-name as character no-undo.
define buffer buf_clients for ub.clients.
  find first buf_clients no-lock where buf_clients.obj-type = 'чел':U and buf_clients.obj-code = agnt-code no-error .
  if available buf_clients then assign var-cli-name = STRING (agnt-code) + "   " + TRIM (buf_clients.obj-name) .
RETURN var-cli-name.
END FUNCTION.
FUNCTION func-char-to-dec RETURNS DECIMAL (iCh AS CHARACTER):
    DEFINE VARIABLE vI       AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vCh      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vNumeric AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vResult  AS DECIMAL   NO-UNDO.
    IF LENGTH(iCh) > 0 THEN
    DO:
        DO vI = 1 TO LENGTH(iCh):
            vCh = SUBSTRING(iCh, vI, 1).
            IF INDEX("-+0123456789,.":U, vCh) > 0 THEN
                vNumeric = vNumeric + vCh.
        END.
        ASSIGN
            vNumeric = REPLACE(vNumeric,
                                SESSION:NUMERIC-SEPARATOR,
                                SESSION:NUMERIC-DECIMAL-POINT)
            vResult  = DECIMAL(vNumeric)
            NO-ERROR.
    END.
    ELSE vResult = 0.
    RETURN vResult.
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
  ( input par-recid as recid, input mark-list as character ) :
RETURN ( IF LOOKUP( STRING( par-recid ), mark-list ) > 0 THEN "*" ELSE "":U ).
END FUNCTION.
