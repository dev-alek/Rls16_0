DEFINE BUFFER X_goods  FOR goods.
DEFINE BUFFER X_pl-gds FOR pl-gds.
DEFINE BUFFER X_place  FOR place.
define input  parameter parparentproc  as widget-handle no-undo .
define input  parameter bttns      as   character           no-undo .
define input  parameter p-obj-type like ub.clients.obj-type no-undo .
define input  parameter p-obj-code like ub.clients.obj-code no-undo .
define input  parameter p-mode     as character no-undo .
define input  parameter p-gds-rec   as recid      no-undo .
define input  parameter p-doc-rec   as recid      no-undo .
define output parameter p-rid-list   as   character           no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Товары на складских местах" .
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
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable filter-point  as character no-undo init "pl-gdss" .
define variable filter-point0 as character no-undo init "pl-gdss" .
define variable filter-label  as character no-undo init "Товар-Склд. место" .
define variable filter-label0 as character no-undo init "Товар-Склд. место" .
define buffer b-goods for goods.
define buffer b-place for place.
define VARIABLE shop-type           as char      no-undo .
define VARIABLE shop-code           as integer   no-undo .
define VARIABLE gdscode             as integer   no-undo .
define VARIABLE plcode              as integer   no-undo .
define variable sort-column-name    as character no-undo .
define variable v-rid-list          as character no-undo .
define variable v-ok-mode           as character no-undo .
define variable v-chk-act-host-code as integer   no-undo .
define variable glog                as logical   no-undo .
DEFINE BUTTON B-add
  LABEL "&Добавить"
  SIZE 10 BY 1.
DEFINE BUTTON B-chg
  LABEL "&Изменить"
  SIZE 10 BY 1.
DEFINE BUTTON B-del
  LABEL "&Удалить"
  SIZE 10 BY 1.
DEFINE BUTTON B-exit AUTO-GO
  LABEL "&Выход"
  SIZE 10 BY 1
  BGCOLOR 8 .
DEFINE BUTTON B-Help
  LABEL "Помо&щь"
  SIZE 3 BY 1
  BGCOLOR 8 .
DEFINE BUTTON B-hist
  LABEL "Ис&тория"
  SIZE 3 BY 1.
DEFINE BUTTON B-mark
  LABEL "*"
  SIZE 3 BY 1.
DEFINE BUTTON B-sch
  LABEL "&Фильтр"
  SIZE 3 BY 1.
DEFINE BUTTON B-sel AUTO-GO
  LABEL "Вы&бор"
  SIZE 10 BY 1.
DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0
  VIEW-AS TEXT
  SIZE 6.25 BY .67
  FGCOLOR 4 NO-UNDO.
DEFINE RECTANGLE RECT-tolerance
  EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
  SIZE 10.13 BY 1.13
  BGCOLOR 8 .
DEFINE QUERY BR-pl-gds FOR
  X_pl-gds,
  X_goods,
  X_place SCROLLING.
DEFINE BROWSE BR-pl-gds
  QUERY BR-pl-gds NO-LOCK DISPLAY
  mark-string(RECID(X_pl-gds), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
  X_pl-gds.pl-code COLUMN-LABEL "Склд.место" FORMAT ">>>>>>>>>>9":U
  X_place.pl-name FORMAT "X(40)":U
  X_place.loc1 FORMAT "X(8)":U
  X_place.loc2 FORMAT "X(8)":U
  X_place.loc3 FORMAT "X(8)":U
  X_place.loc4 FORMAT "X(8)":U
  X_pl-gds.gds-code FORMAT "99999999999":U
  X_goods.artic FORMAT "X(16)":U
  X_goods.gds-name FORMAT "X(48)":U
  X_goods.prod-type FORMAT "X(3)":U
  X_goods.prod-code FORMAT ">>>>>>>>9":U
  X_pl-gds.free-qnty FORMAT "->>,>>>,>>9.999":U
  X_pl-gds.fact-qnty FORMAT "->>,>>>,>>9.999":U
  X_pl-gds.cli-free-qnty FORMAT "->>,>>>,>>9.999":U
  X_pl-gds.cli-fact-qnty FORMAT "->>,>>>,>>9.999":U
  X_pl-gds.tolerance COLUMN-LABEL "Допуст.отклонение" FORMAT "->>,>>>,>>9.<<<":U
  X_pl-gds.status_ FORMAT "X(8)":U
ENABLE
X_pl-gds.tolerance
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.
DEFINE FRAME Dialog-Frame
  B-exit AT ROW 1 COL 1.13
  B-sel AT ROW 1 COL 11
  B-mark AT ROW 1 COL 21
  B-add AT ROW 1 COL 31
  B-chg AT ROW 1 COL 41
  B-del AT ROW 1 COL 51
  B-hist AT ROW 1 COL 89
  B-sch AT ROW 1 COL 92
  B-Help AT ROW 1 COL 95
  BR-pl-gds AT ROW 3.96 COL 1
  mark-num AT ROW 1.17 COL 22.5 COLON-ALIGNED NO-LABEL
  RECT-tolerance AT ROW 1 COL 41
  SPACE(47.87) SKIP(19.99)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
  TITLE "Товары на складских местах"
  DEFAULT-BUTTON B-exit.
ASSIGN
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.
ASSIGN
  BR-pl-gds:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 1.
ON GO OF FRAME Dialog-Frame
  DO:
    p-rid-list = v-rid-list.
  END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
  DO:
    APPLY "END-ERROR":U TO SELF.
  END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
  DO:
    if v-ok-mode <> "" then
    do:
      case v-ok-mode:
        when 'ДОБАВЛЕНИЕ':U then
          do:
            run trg/userlog.p (
              input 'create':U
              , input 'pl-gds':U
              , input ( buffer X_pl-gds :handle )
              , input ?
              , input ""
              ) no-error.
            if error-status :error
              then
            do:
              undo, return substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                , chr(10)
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
            end.
          end.
        when 'ИЗМЕНЕНИЕ':U then
          do:
            run trg/userlog.p (
              input 'update':U
              , input 'pl-gds':U
              , input ( buffer X_pl-gds :handle )
              , input ?
              , input ""
              ) no-error.
            if error-status :error
              then
            do:
              undo, return substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                , chr(10)
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
            end.
          end.
      end case.
    end.
  END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
  DO:
    define variable loc-rid-list as char    no-undo.
    define variable ii           as integer no-undo.
    define variable kk           as integer no-undo.
    define variable glog         as logical no-undo .
    define variable individ      as logical no-undo.
    define buffer buf_pl-gds for ub.pl-gds .
    define buffer buf_goods  for ub.goods.
    define buffer buf_units  for ub.units.
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_place-reference_work':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if NOT glog then return no-apply.
    run ref/gds-ref.p (
      input parparentproc
      ,input "b-sel,b-add"
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input p-obj-type
      ,input p-obj-code
      ,input ?
      ,output loc-rID-list).
    apply "entry" to br-pl-gds in frame Dialog-Frame.
    if loc-rid-list = "" then
      return no-apply.
    run waitfram-show in this-procedure ( input "Ждите...").
    _ii:
    do ii = 1 to num-entries(loc-rid-list):
      find buf_goods where recid (buf_goods) = integer (ENTRY(ii, loc-rid-list)) no-lock.
      if avail buf_goods then
      do:
        FIND FIRST buf_units No-LOCK where
          buf_units.unit-name = buf_goods.unit-base No-ERROR.
        if not avail buf_units then NEXT.
        if LOOKUP('топ':U, buf_units.type) > 0  and lookup('дро':U, buf_units.type) > 0
          then
          assign
            individ = yes.
        else
          assign
            individ = no.
        do transaction on error undo, next :
          find first buf_pl-gds no-lock
            where buf_pl-gds.obj-type = shop-type
            and buf_pl-gds.obj-code = shop-code
            and buf_pl-gds.pl-code  = plcode
            and buf_pl-gds.gds-code = buf_goods.gds-code no-error.
          if not available buf_pl-gds then
          do:
            if lookup('топ':U, buf_units.type) > 0
              and lookup('дро':U, buf_units.type) > 0 then
            do:
              run trg/plgdpmvc.p (
                input  shop-type,
                input  shop-code,
                input  plcode,
                input  buf_goods.gds-code,
                output glog) no-error.
              if error-status:error then
              do:
                message
                  "Ошибка при привязке товара к резервуару." skip
                  return-value skip
                  error-status:get-message(1)
                  view-as alert-box error.
                undo, next.
              end.
              if not glog then
              do:
                if return-value <> "" then
                  message return-value view-as alert-box ERROR.
                undo , next .
              end.
              if glog then kk = kk + 1.
            END.
            else
            do:
              run trg/plgdpmv0.p (
                input shop-type,
                input shop-code,
                input plcode,
                input buf_goods.gds-code,
                output glog) no-error.
              if error-status:error then
              do:
                undo, next.
              end.
              if not glog then
              do:
                if return-value <> "" then
                  message return-value view-as alert-box ERROR.
                undo , next .
              end.
              if glog then kk = kk + 1.
            end.
          end.
          else
          do:
            message
              "Уже есть привязка резервуара " buf_pl-gds.pl-code
              " с товаром " buf_goods.artic " " buf_goods.prod-type " " buf_goods.prod-code " " buf_goods.gds-name " ."
              view-as alert-box error.
            next.
          end.
        end.
      end.
    end.
    run waitfram-hide in this-procedure .
    if kk < num-entries(loc-rid-list) then
    do:
      message
        "Из выбранных " num-entries(loc-rid-list) " товаров " skip
        "к данному складскому месту удалось привязать "
        kk " товаров " view-as alert-box
        WARNING.
    end.
    v-ok-mode = 'ДОБАВЛЕНИЕ':U .
    run OpenBr in this-procedure ( input yes, input no, input '':U).
    APPLY "ENTRY" to br-pl-gds.
  END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
  DO:
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_place-reference_work':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if NOT glog then return no-apply.
    assign
      X_pl-gds.tolerance :read-only in browse BR-pl-gds = NOT
  X_pl-gds.tolerance :read-only in browse BR-pl-gds .
    APPLY "ENTRY" to browse BR-pl-gds.
    IF  X_pl-gds.tolerance :read-only in browse BR-pl-gds = FALSE THEN
    do:
      RECT-tolerance:BGCOLOR = GREEN_COLOR.
      APPLY "ENTRY" to X_pl-gds.tolerance in browse BR-pl-gds.
    end.
    else
    do:
      RECT-tolerance:BGCOLOR = GREY_COLOR.
    end.
    v-ok-mode = 'ИЗМЕНЕНИЕ':U .
  END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
  DO:
    define buffer b-pl-gds for pl-gds.
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_place-reference_work':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if NOT glog then return no-apply.
    if available X_pl-gds then
    do:
      _tr:
      do transaction
        on error undo, return no-apply :
        find first b-pl-gds exclusive-lock
          where rowid(b-pl-gds) = rowid(X_pl-gds) .
        delete b-pl-gds no-error.
        if error-status :error then
        do:
          message
            substitute("Ошибка при удалении привязки товара") skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          return no-apply.
        end.
      end.
      v-ok-mode = 'удаленные':U .
      run openbr in this-procedure ( input yes, input no, input '':U).
      apply "entry" to br-pl-gds.
    end.
  end.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
  DO:
    DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
    IF AVAILABLE X_pl-gds  THEN
    DO:
      run ref/cplchist.w (
        INPUT parParentProc
        , input p-obj-type
        , input p-obj-code
        , input "":U
        , input "subject":U
        , input X_pl-gds.obj-type
        , input X_pl-gds.obj-code
        , input X_pl-gds.pl-code
        , input X_pl-gds.gds-code
        , input 0
        , input 0
        , input 'pl-gds':U
        , input-output v-rid-list
        ) no-error .
    END.
  END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
  DO:
    define variable glog as logical no-undo .
    if available X_pl-gds then
    do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid12 as character no-undo .
define variable v-num-entry12 as integer   no-undo .
assign
  v-str-recid12 = trim( string( recid( X_pl-gds ) , "->>>>>>>>>>>9":U ) )
  v-num-entry12 = lookup( v-str-recid12 , v-rid-list )
.
if v-num-entry12 > 0 then do:
  assign
    entry( v-num-entry12, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid12
  .
end.
      br-pl-gds:refresh().
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then
      do:
        glog = br-pl-gds:select-next-row ().
        apply "iteration-changed" to br-pl-gds in frame Dialog-Frame.
      end.
      if num-entries( v-rid-list ) = 0 then
        hide mark-num in frame Dialog-Frame.
      else
        disp num-entries( v-rid-list ) @ mark-num with frame Dialog-Frame.
    end.
    apply "entry" to br-pl-gds in frame Dialog-Frame.
  END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
  DO:
    assign
      tbl      = 'pl-gds':U
      join-tbl = 'X_pl-gds':U
      fld      = '':U
      lab      = '':U
      spr      = '':U
      dim      = '0':U
      .
    run fltfield-add in this-procedure('gds-code', '', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('obj-code', '', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('obj-type', '', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('pl-code', '', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('status_', '', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('fact-qnty', '', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('free-qnty', '', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('cli-fact-qnty', '', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('cli-free-qnty', '', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    DO on stop undo, leave:
      run gbl/filter.w ( input parparentproc
        ,input (filter-point + chr(4) + filter-label)
        ,input tbl
        ,input join-tbl
        ,input fld
        ,input lab
        ,input spr
        ,input dim).
      RUN OpenBr in this-procedure ( input yes, input no, input '':U).
    END .
  END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
  DO:
    if ( available X_pl-gds AND v-rid-list = "" ) then
      v-rid-list = string( recid( X_pl-gds ) ) .
  END.
ON MOUSE-SELECT-DBLCLICK OF BR-pl-gds IN FRAME Dialog-Frame
  DO:
    if lookup("b-sel", bttns) > 0 then APPLY "CHOOSE" to b-sel.
  END.
ON RETURN OF BR-pl-gds IN FRAME Dialog-Frame
  DO:
    if lookup("b-sel", bttns) > 0 then APPLY "CHOOSE" to b-sel.
  END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
  THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-pl-gds :handle
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
def var sort-labelBR-pl-gds   as character no-undo .
def var sort-clmnBR-pl-gds    as handle    no-undo .
def var cur-clmnBR-pl-gds     as handle    no-undo .
def var cur-clmn-locBR-pl-gds as integer   no-undo .
def var re-queryBR-pl-gds     as logical   initial no no-undo .
on start-search, ctrl-o of BR-pl-gds in frame Dialog-Frame do:
   run sort-brBR-pl-gds
     (input (if available X_pl-gds
             then recid(X_pl-gds)
             else ?
            )
     ).
end.
PROCEDURE sort-brBR-pl-gds :
  define input parameter p-recid as recid no-undo .
  if re-queryBR-pl-gds = no then do:
    assign
       cur-clmnBR-pl-gds = BR-pl-gds:current-column in frame Dialog-Frame
    .
    if sort-clmnBR-pl-gds <> ? then sort-clmnBR-pl-gds:column-fgcolor = 0.
    if cur-clmnBR-pl-gds = sort-clmnBR-pl-gds then do:
      assign
         sort-labelBR-pl-gds = ""
         sort-clmnBR-pl-gds = ?
      .
     end.
     else do:
       assign
         sort-labelBR-pl-gds = cur-clmnBR-pl-gds:label
         sort-clmnBR-pl-gds  = cur-clmnBR-pl-gds
         sort-clmnBR-pl-gds:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locBR-pl-gds = 1
  .
  def var column-handle as handle no-undo .
  column-handle = BR-pl-gds:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnBR-pl-gds then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locBR-pl-gds = cur-clmn-locBR-pl-gds + 1
    .
  end.
  case sort-labelBR-pl-gds:
        when X_pl-gds.pl-code:label in browse BR-pl-gds then DO:    assign       sort-column-name = "X_pl-gds.pl-code"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when X_pl-gds.gds-code:label in browse BR-pl-gds then DO:    assign       sort-column-name = "X_pl-gds.gds-code"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when X_pl-gds.fact-qnty:label in browse BR-pl-gds then DO:    assign       sort-column-name = "X_pl-gds.fact-qnty"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when X_pl-gds.free-qnty:label in browse BR-pl-gds then DO:    assign       sort-column-name = "X_pl-gds.free-qnty"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when X_pl-gds.cli-fact-qnty:label in browse BR-pl-gds then DO:    assign       sort-column-name = "X_pl-gds.cli-fact-qnty"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when X_pl-gds.cli-free-qnty:label in browse BR-pl-gds then DO:    assign       sort-column-name = "X_pl-gds.cli-free-qnty"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure ( input yes, input no, input '':U).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultBR-pl-gds') then do:
          run mv-brw-defaultBR-pl-gds.
        end.
      if sort-labelBR-pl-gds <> "" then do:
        assign
          cur-clmnBR-pl-gds:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locBR-pl-gds = ?
      .
    end.
  end case.
    if cur-clmn-locBR-pl-gds <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnBR-pl-gds') then do:
        run ch-clmnBR-pl-gds in this-procedure (cur-clmn-locBR-pl-gds).
      end.
    end.
  if p-recid <> ? then do:
    reposition BR-pl-gds to recid p-recid no-error.
    apply "value-changed" to BR-pl-gds in frame Dialog-Frame.
  end.
  apply "entry" to BR-pl-gds in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnBR-pl-gds:
if cur-clmnBR-pl-gds = ? then do:
   run OpenBr in this-procedure ( input yes, input no, input '':U).
end.
else do:
   assign re-queryBR-pl-gds = yes.
   run sort-brBR-pl-gds
     (input (if available X_pl-gds
             then recid(X_pl-gds)
             else ?
            )
     ).
   assign re-queryBR-pl-gds = no.
end.
end.
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  v-rid-list = p-rid-list.
  assign
    X_pl-gds.tolerance:read-only in browse BR-pl-gds = true.
  RUN MyENable.
  RUN OpenBR in this-procedure  ( input yes, input no, input '':U).
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-pl-gds as INT EXTENT 18 no-undo.
DEF VAR varmvibr-pl-gds       as INT no-undo.
DEF VAR varmvjbr-pl-gds       as INT no-undo.
DEF VAR varmvkbr-pl-gds       as INT no-undo.
DEF VAR varmvlbr-pl-gds       as INT no-undo.
DEF VAR move-elementbr-pl-gds as INT no-undo.
def var jjbr-pl-gds           as int no-undo.
do varmvibr-pl-gds = 1 to EXTENT(cur-clmn-numbr-pl-gds):
  ASSIGN cur-clmn-numbr-pl-gds[varmvibr-pl-gds] = varmvibr-pl-gds.
END.
RUN start-mv-clmnbr-pl-gds.
PROCEDURE start-mv-clmnbr-pl-gds:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  p-mode = 'объект':U  THEN DO:
   DO jjbr-pl-gds = NUM-ENTRIES('1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18') TO 1 BY -1:
     RUN re-move-clmnbr-pl-gds ( cur-clmn-numbr-pl-gds[INTEGER(ENTRY (jjbr-pl-gds, '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18'))] , br-pl-gds:num-locked-columns in frame Dialog-Frame ).
   END.
       END.
       IF  p-mode = 'топ':U  THEN DO:
   DO jjbr-pl-gds = NUM-ENTRIES('1,2,3,4,13,14,15,16,17,18,8,9,10,11,12,5,6,7') TO 1 BY -1:
     RUN re-move-clmnbr-pl-gds ( cur-clmn-numbr-pl-gds[INTEGER(ENTRY (jjbr-pl-gds, '1,2,3,4,13,14,15,16,17,18,8,9,10,11,12,5,6,7'))] , br-pl-gds:num-locked-columns in frame Dialog-Frame ).
   END.
       END.
       IF  p-mode = 'склд.место':U  THEN DO:
   DO jjbr-pl-gds = NUM-ENTRIES('1,8,9,10,13,14,15,16,11,12,17,18,2,3,4,5,6,7') TO 1 BY -1:
     RUN re-move-clmnbr-pl-gds ( cur-clmn-numbr-pl-gds[INTEGER(ENTRY (jjbr-pl-gds, '1,8,9,10,13,14,15,16,11,12,17,18,2,3,4,5,6,7'))] , br-pl-gds:num-locked-columns in frame Dialog-Frame ).
   END.
       END.
       IF  p-mode = 'ТОВАР':U  THEN DO:
   DO jjbr-pl-gds = NUM-ENTRIES('1,2,3,4,13,14,15,16,5,6,7,17,18,8,9,10,11,12') TO 1 BY -1:
     RUN re-move-clmnbr-pl-gds ( cur-clmn-numbr-pl-gds[INTEGER(ENTRY (jjbr-pl-gds, '1,2,3,4,13,14,15,16,5,6,7,17,18,8,9,10,11,12'))] , br-pl-gds:num-locked-columns in frame Dialog-Frame ).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-pl-gds do:
  RUN re-move-clmnbr-pl-gds ( br-pl-gds:num-locked-columns in frame Dialog-Frame , 18).
END.
ON ctrl-cursor-left OF BROWSE br-pl-gds do:
  RUN re-move-clmnbr-pl-gds (18, br-pl-gds:num-locked-columns in frame Dialog-Frame ).
END.
PROCEDURE re-move-clmnbr-pl-gds:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-pl-gds = 1 TO EXTENT(cur-clmn-numbr-pl-gds):
    if cur-clmn-numbr-pl-gds[varmvibr-pl-gds] = source-column THEN cur-clmn-numbr-pl-gds[varmvibr-pl-gds] = -1.
  END.
  if br-pl-gds:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjbr-pl-gds = source-column - 1 to target-column BY -1:
    DO varmvibr-pl-gds = 1 TO EXTENT(cur-clmn-numbr-pl-gds):
        if cur-clmn-numbr-pl-gds[varmvibr-pl-gds] = varmvjbr-pl-gds THEN DO:
          cur-clmn-numbr-pl-gds[varmvibr-pl-gds] = cur-clmn-numbr-pl-gds[varmvibr-pl-gds] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-pl-gds = source-column + 1 to target-column:
    DO varmvibr-pl-gds = 1 TO EXTENT(cur-clmn-numbr-pl-gds):
      if cur-clmn-numbr-pl-gds[varmvibr-pl-gds] = varmvjbr-pl-gds THEN DO:
        cur-clmn-numbr-pl-gds[varmvibr-pl-gds] = cur-clmn-numbr-pl-gds[varmvibr-pl-gds] - 1.
      END.
    END.
  END.
  DO varmvibr-pl-gds = 1 TO EXTENT(cur-clmn-numbr-pl-gds):
    if cur-clmn-numbr-pl-gds[varmvibr-pl-gds] = -1 THEN cur-clmn-numbr-pl-gds[varmvibr-pl-gds] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-pl-gds:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= br-pl-gds:num-locked-columns in frame Dialog-Frame  then do:
    return .
  end.
  DO varmvibr-pl-gds = 1 TO EXTENT(cur-clmn-numbr-pl-gds):
    if cur-clmn-numbr-pl-gds[varmvibr-pl-gds] = cur-clmn-loc THEN move-elementbr-pl-gds = varmvibr-pl-gds.
  END.
  RUN re-move-clmnbr-pl-gds (cur-clmn-loc, br-pl-gds:num-locked-columns in frame Dialog-Frame ).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-pl-gds:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-pl-gds = br-pl-gds:num-locked-columns in frame Dialog-Frame  to EXTENT(cur-clmn-numbr-pl-gds):
    RUN re-move-clmnbr-pl-gds (cur-clmn-numbr-pl-gds[varmvlbr-pl-gds], varmvlbr-pl-gds).
  END.
  RUN start-mv-clmnbr-pl-gds.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
  APPLY "ENTRY" to br-pl-gds.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY mark-num
    WITH FRAME Dialog-Frame.
  ENABLE B-exit B-sel B-mark B-add B-chg B-del B-hist B-sch B-Help
    RECT-tolerance BR-pl-gds mark-num
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE Myenable :
  ASSIGN
    br-pl-gds:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 1.
  DISPLAY
    mark-num
    WITH FRAME Dialog-Frame.
  ENABLE
    B-exit
    B-sel
    when lookup("b-sel", bttns) > 0
    B-mark
    when lookup("b-mark", bttns) > 0
    b-add
    when lookup("b-add", bttns) > 0 and p-mode = 'склд.место':U
    b-del
    when lookup("b-add", bttns) > 0 and p-mode = 'склд.место':U
    b-chg
    when lookup("b-add", bttns) > 0 and p-mode = 'склд.место':U
    B-sch
    B-Help
    b-hist
    BR-pl-gds
    WITH FRAME Dialog-Frame .
  VIEW FRAME Dialog-Frame .
  HIDE mark-num IN FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE OpenBr :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  define variable sort-column-phrase as character no-undo .
  define variable l-query-was-opened as logical   no-undo .
  define buffer buf_clients for ub.clients.
  run waitfram-show in this-procedure ( input "Ждите...").
  case sort-column-name :
    when "" then
      do:
        assign
          sort-column-phrase = ""
          .
      end.
    otherwise
    do:
      assign
        sort-column-phrase = "by " + sort-column-name
        .
    end.
  end case.
  CASE p-mode:
    when 'объект':U then
      do:
        FIND FIRST buf_clients NO-LOCK WHERE
          BUF_clients.obj-type = p-obj-type
          AND BUF_clients.obj-code = p-obj-code NO-ERROR.
        ASSIGN
          frame
        Dialog-Frame:TITLE = substitute("Товары на складских местах &1", BUF_clients.obj-name)
          filter-point                       = filter-point0  + p-mode
          filter-label                       = substitute("&1", filter-label0)
          shop-type                          = p-obj-type
          shop-code                          = p-obj-code
          .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-20  as logical   no-undo .
define variable  l-filter-open-20    as logical   .
define variable  flt-rec-20       as recid     no-undo .
define variable  filter-name-20      as character no-undo .
define variable  where-phrase-20     as character no-undo .
define variable  sort-phrase-20      as character no-undo .
define variable  where-phrase-rus-20 as character no-undo .
define variable  sort-phrase-rus-20  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-20
  ,output filter-name-20
  ,output where-phrase-20
  ,output sort-phrase-20
  ,output where-phrase-rus-20
  ,output sort-phrase-rus-20
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-20
      ) no-error .
  assign
    l-filter-open-20 = false
  .
  if flt-rec-20 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-20 as character no-undo .
    define variable  parameter-3-20 as character no-undo .
    define variable  parameter-4-20 as character no-undo .
    define variable  parameter-5-20 as character no-undo .
    define variable  parameter-6-20 as character no-undo .
    define variable  parameter-7-20 as character no-undo .
      assign
      parameter-3-20 =
                              "FOR EACH X_pl-gds"
      parameter-4-20 =
        (
          if (" x_pl-gds.obj-type = shop-type AND X_pl-gds.obj-code = shop-code " + " " + where-phrase-20) <> ""
          then  substitute('x_pl-gds.obj-type = &1&2&1 AND X_pl-gds.obj-code = &3 ', chr(34), shop-type, shop-code) + " " + where-phrase-20
          else "true"
        )
      parameter-5-20 = (" " + "" + " " + ", EACH X_goods WHERE X_goods.gds-code = X_pl-gds.gds-code NO-LOCK,       EACH X_place WHERE X_place.obj-code = X_pl-gds.obj-code   AND X_place.obj-type = X_pl-gds.obj-type   AND X_place.pl-code = X_pl-gds.pl-code   and X_place.status_ <>  'удал':U NO-LOCK")
      parameter-6-20 = if sort-phrase-20 = ''
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
        " " + sort-phrase-20
        )
      parameter-7-20 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-20 =
          (" x_pl-gds.obj-type = shop-type AND X_pl-gds.obj-code = shop-code " + " " + where-phrase-20 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-pl-gds:handle
                          ,input parameter-3-20
                          ,input parameter-4-20
                          ,input parameter-5-20
                          ,input parameter-6-20
                          ,input parameter-7-20
                          )
      .
      assign
        l-filter-open-20 = true
      .
    end.
    if l-filter-open-20 = false then do:
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
  if l-filter-open-20 = false then do:
    OPEN QUERY br-pl-gds FOR EACH X_pl-gds
      where  x_pl-gds.obj-type = shop-type AND X_pl-gds.obj-code = shop-code
    , EACH X_goods WHERE X_goods.gds-code = X_pl-gds.gds-code NO-LOCK,       EACH X_place WHERE X_place.obj-code = X_pl-gds.obj-code   AND X_place.obj-type = X_pl-gds.obj-type   AND X_place.pl-code = X_pl-gds.pl-code   and X_place.status_ <>  'удал':U NO-LOCK
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
      end.
    when 'ТОВАР':U or
    when 'топ':U then
      do:
        FIND FIRST b-goods NO-LOCK WHERE recid(b-goods) = p-gds-rec No-ERROR.
        ASSIGN
          frame Dialog-Frame:TITLE = (if p-mode = 'ТОВАР':U
                                                                      then ("Товар "   +
                                                                               b-goods.artic + " " + b-goods.prod-type +
                                                                                " " + string(b-goods.prod-code) +
                                                                                " на складских местах: "
                                                                                )
                                                                      else ("Топливо " +
                                                                               b-goods.artic + " " + b-goods.prod-type +
                                                                                " " + string(b-goods.prod-code)  +
                                                                                " в танках:"
                                                                              )
                                                                      )
          filter-point              = filter-point0 + p-mode
          filter-label              = substitute("&1", filter-label0)
          shop-type                 = p-obj-type
          shop-code                 = p-obj-code
          gdscode                   = b-goods.gds-code.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-22  as logical   no-undo .
define variable  l-filter-open-22    as logical   .
define variable  flt-rec-22       as recid     no-undo .
define variable  filter-name-22      as character no-undo .
define variable  where-phrase-22     as character no-undo .
define variable  sort-phrase-22      as character no-undo .
define variable  where-phrase-rus-22 as character no-undo .
define variable  sort-phrase-rus-22  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-22
  ,output filter-name-22
  ,output where-phrase-22
  ,output sort-phrase-22
  ,output where-phrase-rus-22
  ,output sort-phrase-rus-22
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-22
      ) no-error .
  assign
    l-filter-open-22 = false
  .
  if flt-rec-22 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-22 as character no-undo .
    define variable  parameter-3-22 as character no-undo .
    define variable  parameter-4-22 as character no-undo .
    define variable  parameter-5-22 as character no-undo .
    define variable  parameter-6-22 as character no-undo .
    define variable  parameter-7-22 as character no-undo .
      assign
      parameter-3-22 =
                              "FOR EACH X_pl-gds"
      parameter-4-22 =
        (
          if (" X_pl-gds.obj-type = shop-type AND X_pl-gds.obj-code = shop-code AND X_pl-gds.gds-code = gdscode " + " " + where-phrase-22) <> ""
          then  substitute('X_pl-gds.obj-type = &1&2&1 AND X_pl-gds.obj-code = &3 AND X_pl-gds.gds-code = &4 ', chr(34), shop-type, shop-code, gdscode) + " " + where-phrase-22
          else "true"
        )
      parameter-5-22 = (" " + "" + " " + ", EACH X_goods WHERE X_goods.gds-code = X_pl-gds.gds-code NO-LOCK,       EACH X_place WHERE X_place.obj-code = X_pl-gds.obj-code   AND X_place.obj-type = X_pl-gds.obj-type   AND X_place.pl-code = X_pl-gds.pl-code   and X_place.status_ <>  'удал':U NO-LOCK")
      parameter-6-22 = if sort-phrase-22 = ''
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
        " " + sort-phrase-22
        )
      parameter-7-22 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-22 =
          (" X_pl-gds.obj-type = shop-type AND X_pl-gds.obj-code = shop-code AND X_pl-gds.gds-code = gdscode " + " " + where-phrase-22 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-pl-gds:handle
                          ,input parameter-3-22
                          ,input parameter-4-22
                          ,input parameter-5-22
                          ,input parameter-6-22
                          ,input parameter-7-22
                          )
      .
      assign
        l-filter-open-22 = true
      .
    end.
    if l-filter-open-22 = false then do:
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
  if l-filter-open-22 = false then do:
    OPEN QUERY br-pl-gds FOR EACH X_pl-gds
      where  X_pl-gds.obj-type = shop-type AND X_pl-gds.obj-code = shop-code AND X_pl-gds.gds-code = gdscode
    , EACH X_goods WHERE X_goods.gds-code = X_pl-gds.gds-code NO-LOCK,       EACH X_place WHERE X_place.obj-code = X_pl-gds.obj-code   AND X_place.obj-type = X_pl-gds.obj-type   AND X_place.pl-code = X_pl-gds.pl-code   and X_place.status_ <>  'удал':U NO-LOCK
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
      end.
    when 'склд.место':U then
      do:
        FIND FIRST b-place NO-LOCK WHERE recid(b-place) = p-doc-rec No-ERROR.
        ASSIGN
          frame Dialog-Frame:TITLE = "Товары на складском месте " +
                                            string(b-place.pl-code) + " " +
                                            b-place.pl-name
          filter-point              = "Товар-Склд. место " + p-mode
          filter-label              = substitute("&1", filter-label0)
          shop-type                 = p-obj-type
          shop-code                 = p-obj-code
          plcode                    = b-place.pl-code.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-24  as logical   no-undo .
define variable  l-filter-open-24    as logical   .
define variable  flt-rec-24       as recid     no-undo .
define variable  filter-name-24      as character no-undo .
define variable  where-phrase-24     as character no-undo .
define variable  sort-phrase-24      as character no-undo .
define variable  where-phrase-rus-24 as character no-undo .
define variable  sort-phrase-rus-24  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-24
  ,output filter-name-24
  ,output where-phrase-24
  ,output sort-phrase-24
  ,output where-phrase-rus-24
  ,output sort-phrase-rus-24
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-24
      ) no-error .
  assign
    l-filter-open-24 = false
  .
  if flt-rec-24 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-24 as character no-undo .
    define variable  parameter-3-24 as character no-undo .
    define variable  parameter-4-24 as character no-undo .
    define variable  parameter-5-24 as character no-undo .
    define variable  parameter-6-24 as character no-undo .
    define variable  parameter-7-24 as character no-undo .
      assign
      parameter-3-24 =
                              "FOR EACH X_pl-gds"
      parameter-4-24 =
        (
          if (" X_pl-gds.obj-type = shop-type AND X_pl-gds.obj-code = shop-code AND X_pl-gds.pl-code = plcode " + " " + where-phrase-24) <> ""
          then  substitute('X_pl-gds.obj-type = &1&2&1 AND X_pl-gds.obj-code = &3 AND X_pl-gds.pl-code = &4 ', chr(34), shop-type, shop-code, plcode) + " " + where-phrase-24
          else "true"
        )
      parameter-5-24 = (" " + "" + " " + ", EACH X_goods WHERE X_goods.gds-code = X_pl-gds.gds-code NO-LOCK,       EACH X_place WHERE X_place.obj-code = X_pl-gds.obj-code   AND X_place.obj-type = X_pl-gds.obj-type   AND X_place.pl-code = X_pl-gds.pl-code   and X_place.status_ <>  'удал':U NO-LOCK")
      parameter-6-24 = if sort-phrase-24 = ''
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
        " " + sort-phrase-24
        )
      parameter-7-24 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-24 =
          (" X_pl-gds.obj-type = shop-type AND X_pl-gds.obj-code = shop-code AND X_pl-gds.pl-code = plcode " + " " + where-phrase-24 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-pl-gds:handle
                          ,input parameter-3-24
                          ,input parameter-4-24
                          ,input parameter-5-24
                          ,input parameter-6-24
                          ,input parameter-7-24
                          )
      .
      assign
        l-filter-open-24 = true
      .
    end.
    if l-filter-open-24 = false then do:
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
  if l-filter-open-24 = false then do:
    OPEN QUERY br-pl-gds FOR EACH X_pl-gds
      where  X_pl-gds.obj-type = shop-type AND X_pl-gds.obj-code = shop-code AND X_pl-gds.pl-code = plcode
    , EACH X_goods WHERE X_goods.gds-code = X_pl-gds.gds-code NO-LOCK,       EACH X_place WHERE X_place.obj-code = X_pl-gds.obj-code   AND X_place.obj-type = X_pl-gds.obj-type   AND X_place.pl-code = X_pl-gds.pl-code   and X_place.status_ <>  'удал':U NO-LOCK
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
      end.
  END CASE.
  if avail X_pl-gds then
    APPLY "VALUE-CHANGED":U to br-pl-gds.
  run waitfram-hide in this-procedure .
END PROCEDURE.
