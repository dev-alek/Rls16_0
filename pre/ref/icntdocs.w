DEFINE BUFFER X_icnt-doc FOR ub.icnt-doc.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER bttns AS character NO-UNDO.
DEFINE INPUT PARAMETER p-list-mode AS character NO-UNDO.
DEFINE INPUT PARAMETER p-status_ AS character NO-UNDO.
DEFINE INPUT PARAMETER p-doc-type AS character NO-UNDO.
define input parameter p-host-code as integer no-undo .
DEFINE INPUT PARAMETER p-obj-type AS character NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rid-list AS character NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список документов по счетчикам ТРК".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
function shift-name return character ( buffer loc-icnt-doc for ub.icnt-doc ) :
  if loc-icnt-doc.shift-date = ? then do:
    return "":u.
  end.
  else do:
    if loc-icnt-doc.shift-num = integer(loc-icnt-doc.shift-name) then do:
      return loc-icnt-doc.shift-name.
    end.
    else do:
      return loc-icnt-doc.shift-name + "(" + string(loc-icnt-doc.shift-num) + ")".
    end.
  end.
end function.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable sort-column-name as character no-undo.
define variable filter-point     as character NO-UNDO INIT "inctdocs".
define variable filter-label     as character NO-UNDO INIT "Список документов по счетчикам ТРК".
define variable filter-point0     as character NO-UNDO INIT "inctdocs".
define variable filter-label0     as character NO-UNDO INIT "Список документов по счетчикам ТРК".
DEFINE VARIABLE v-icnt-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_clients FOR ub.clients.
define buffer buf_sysconf for ub.sysconf.
FUNCTION fine-time RETURN CHARACTER (buffer bf_i-doc for ub.icnt-doc).
   return string(bf_i-doc.fact-time,"hh:mm:ss").
END FUNCTION.
FUNCTION func-delta RETURN DECIMAL (buffer bf_i-doc for ub.icnt-doc).
   return (bf_i-doc.state-el-cnt - bf_i-doc.state-mh-cnt).
END FUNCTION.
define variable varfunc-obj         as character format "x(9)" no-undo.
define variable varshort-doc-date   as character format "x(5)" no-undo.
define variable varshort-shift-date as character format "x(5)" no-undo.
define variable varfine-time        as character format "x(8)" no-undo.
define variable varfunc-delta       like ub.icnt-doc.state-el-cnt no-undo.
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON b-close
     LABEL "Закрыть"
     SIZE 10 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON b-print
     LABEL "&Печать"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sch
     LABEL "Фильтр"
     SIZE 3 BY 1.
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.
DEFINE VARIABLE ED-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2.33 NO-UNDO.
DEFINE VARIABLE agnt-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Исп"
      VIEW-AS TEXT
     SIZE 14.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE boss-name AS CHARACTER FORMAT "X(256)":U
     LABEL "М-р"
      VIEW-AS TEXT
     SIZE 14.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE obj-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Объект"
      VIEW-AS TEXT
     SIZE 34 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE wrkr-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Кл-к"
      VIEW-AS TEXT
     SIZE 14.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY BR-i-docs FOR
      X_icnt-doc SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      X_icnt-doc SCROLLING.
DEFINE BROWSE BR-i-docs
  QUERY BR-i-docs NO-LOCK DISPLAY
      mark-string(recid(X_icnt-doc), v-rid-list)                     COLUMN-LABEL '*' format "x(2)"
X_icnt-doc.status_                           COLUMN-LABEL 'Статус' format "x(6)"
X_icnt-doc.doc-code                           COLUMN-LABEL 'Документ'
X_icnt-doc.doc-date                           COLUMN-LABEL 'Дата'
X_icnt-doc.fact-date                           column-label 'Факт'
string(X_icnt-doc.fact-time, 'HH:MM:SS')                           column-label 'Время'
X_icnt-doc.shift-date                           COLUMN-LABEL 'Смена'
shift-name (buffer X_icnt-doc)                           COLUMN-LABEL '№' format "x(6)"
(X_icnt-doc.obj-type + STRING(X_icnt-doc.obj-code))                           COLUMN-LABEL 'Объект'
X_icnt-doc.state-el-cnt                           column-label 'Количество!по счетчику' FORMAT "->>>,>>>,>>>,>>>,>>9.999"
X_icnt-doc.state-mh-cnt                          column-label 'Количество!по мернику' FORMAT "->>>,>>>,>>>,>>>,>>9.999"
(X_icnt-doc.state-el-cnt - X_icnt-doc.state-mh-cnt)                          column-label 'Разница' FORMAT "->>>,>>>,>>>,>>>,>>9.999"
X_icnt-doc.meas-el-cnt                          column-label 'Измерения!электронных!счетчиков' FORMAT "->>>,>>>,>>>,>>>,>>9.999"
ENABLE
X_icnt-doc.meas-el-cnt
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.5 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     b-add AT ROW 1 COL 31
     b-chg AT ROW 1 COL 41
     b-del AT ROW 1 COL 51
     b-lkp AT ROW 1 COL 61
     b-print AT ROW 1 COL 89
     b-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     b-close AT ROW 2 COL 31
     BR-i-docs AT ROW 3 COL 1
     ED-notes AT ROW 21 COL 1 NO-LABEL
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     obj-name AT ROW 19 COL 52
     boss-name AT ROW 20 COL 1
     agnt-name AT ROW 20 COL 25
     wrkr-name AT ROW 20 COL 49
     X_icnt-doc.creid AT ROW 20 COL 71.75
          LABEL "Опер"
           VIEW-AS TEXT
          SIZE 21.5 BY .67
          FGCOLOR 4
     SPACE(0.00) SKIP(2.79)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  p-rid-list = v-rid-list.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
  run proc-b-add IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
  run proc-b-chg IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-close IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-icnt-rec AS RECID NO-UNDO.
  DEFINE VARIABLE glog AS LOGICAL no-undo.
  IF X_icnt-doc.status_ = 'факт':U THEN DO:
      message
      "Данный документ закрыт на факт."
      VIEW-AS ALERT-BOX .
    RETURN NO-APPLY.
  END.
  IF NOT AVAILABLE X_icnt-doc THEN RETURN NO-APPLY.
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_icnt-doc_fact':U
    ,input  'object':U
    ,input  X_icnt-doc.host-code
    ,input  X_icnt-doc.obj-type
    ,input  X_icnt-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  IF NOT glog THEN RETURN NO-APPLY.
  MESSAGE
  SUBSTITUTE("Вы действительно хотите закрыть документ счетчиков ТРК &1?", X_icnt-doc.doc-code)
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  IF NOT glog THEN RETURN NO-APPLY.
  v-icnt-rec = RECID(X_icnt-doc).
  run str/icntdoc2.p ( INPUT RECID(X_icnt-doc)
                 ,INPUT NO
                 ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  run Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
  REPOSITION br-i-docs TO RECID v-icnt-rec NO-ERROR.
  APPLY "ENtRY" TO br-i-docs.
  APPLY "value-changed" TO br-i-docs.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO INIT YES.
  IF NOT AVAILABLE X_icnt-doc THEN RETURN NO-APPLY.
  message
  substitute("Удалить документ  счетчиков ТРК № &1?   Вы уверены ?"
             , X_icnt-doc.doc-code)
  view-as alert-box question buttons OK-Cancel update glog.
  IF NOT glog THEN RETURN NO-APPLY.
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_icnt-doc_preparation':U
    ,input  'object':U
    ,input  X_icnt-doc.host-code
    ,input  X_icnt-doc.obj-type
    ,input  X_icnt-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  v-icnt-rec = RECID(X_icnt-doc).
  glog = br-i-docs:select-next-row().
  if not glog then glog = br-i-docs:select-prev-row().
  run str/icntdoc3.p ( INPUT v-icnt-rec
                 ,INPUT NO
                 ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  run Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
  REPOSITION br-i-docs TO RECID v-icnt-rec NO-ERROR.
  APPLY "ENtRY" TO br-i-docs.
  APPLY "value-changed" TO br-i-docs.
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
  run proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
  define variable loc#log as logical no-undo .
  if available X_icnt-doc then do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid12 as character no-undo .
define variable v-num-entry12 as integer   no-undo .
assign
  v-str-recid12 = trim( string( recid( X_icnt-doc ) , "->>>>>>>>>>>9":U ) )
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
    loc#log = br-i-docs:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-i-docs:select-next-row ().
        apply "VALUE-CHANGED" to br-i-docs in frame Dialog-Frame.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame Dialog-Frame.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame Dialog-Frame.
  end.
  apply "entry" to br-i-docs in frame Dialog-Frame.
END.
ON CHOOSE OF b-print IN FRAME Dialog-Frame
DO:
  run proc-b-print IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-sch IN FRAME Dialog-Frame
DO:
  run proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
    if ( available X_icnt-doc ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_icnt-doc ) ) .
  end.
END.
ON RETURN OF BR-i-docs IN FRAME Dialog-Frame
OR MOUSE-SELECT-DBLCLICK OF BR-i-docs IN FRAME Dialog-Frame DO:
  apply "choose" to b-lkp in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF BR-i-docs IN FRAME Dialog-Frame
DO:
DEFINE BUFFER buf_clients FOR ub.clients.
    if available X_icnt-doc then do:
    find FIRST buf_clients NO-LOCK where
        buf_clients.obj-type = 'чел':U
    and buf_clients.obj-code = X_icnt-doc.boss no-error.
    if available buf_clients  then  DO:
      boss-name = buf_clients.obj-name.
    END.
    else do:
      boss-name = ?.
    END.
    find FIRST buf_clients NO-LOCK where
             buf_clients.obj-type = 'чел':U
          and buf_clients.obj-code = X_icnt-doc.agnt no-error.
    if available buf_clients then do:
        agnt-name = buf_clients.obj-name.
     end.
    else do:
        agnt-name = ?.
    END.
    find FIRST buf_clients NO-LOCK where
              buf_clients.obj-type = 'чел':U
           and buf_clients.obj-code = X_icnt-doc.wrkr no-error.
    if available buf_clients then do:
        wrkr-name = buf_clients.obj-name.
    end.
    else do:
        wrkr-name = ?.
    END.
    find FIRST buf_clients NO-LOCK where
              buf_clients.obj-type = X_icnt-doc.obj-type
          and buf_clients.obj-code = X_icnt-doc.obj-code no-error.
    if available buf_clients then do:
       obj-name  = buf_clients.obj-name.
    end.
    else do:
        obj-name = ?.
    END.
    ASSIGN ed-notes = X_icnt-doc.PS.
    DISPLAY
    ed-notes
    obj-name
    boss-name
    agnt-name
    wrkr-name
    X_icnt-doc.creid
    with frame Dialog-Frame.
  end.
END.
ON ENTRY OF ED-notes IN FRAME Dialog-Frame
DO:
if not available X_icnt-doc then RETURN NO-APPLY.
assign
v-icnt-rec = recid (X_icnt-doc).
if X_icnt-doc.status_ <> 'факт':U
and substring (X_icnt-doc.PS, 1, 1) = "@" THEN DO:
  message
  "Чтобы программа не могла заново переписать Ваше примечание, удалите знак @."
  VIEW-AS ALERT-BOX .
END.
END.
ON LEAVE OF ED-notes IN FRAME Dialog-Frame
DO:
define buffer buf_icnt-doc for ub.icnt-doc.
do on stop  undo, return no-apply
   on error undo, return no-apply :
  find first buf_icnt-doc where
       recid (buf_icnt-doc) = v-icnt-rec exclusive .
  buf_icnt-doc.PS = input frame Dialog-Frame ed-notes.
end.
END.
ON RETURN OF ED-notes IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF ed-notes IN FRAME Dialog-Frame DO:
  apply "entry" to BR-i-docs in frame Dialog-Frame.
return no-apply.
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
        v-diasize-browse-handle     = browse BR-i-docs :handle
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
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame Dialog-Frame anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame Dialog-Frame anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-F7 of frame Dialog-Frame anywhere do:
  if b-close :sensitive then DO: apply "CHOOSE":U to b-close in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
   v-icnt-rec = ?. if available X_icnt-doc then v-icnt-rec = recid(X_icnt-doc).                run openbr in this-procedure ( input yes, input no, input '':U) no-error.                REPOSITION br-i-docs to recid v-icnt-rec No-ERROR.
    apply "VALUE-CHANGED" to BR-i-docs.
end.
def var sort-labelBR-i-docs   as character no-undo .
def var sort-clmnBR-i-docs    as handle    no-undo .
def var cur-clmnBR-i-docs     as handle    no-undo .
def var cur-clmn-locBR-i-docs as integer   no-undo .
def var re-queryBR-i-docs     as logical   initial no no-undo .
on start-search, ctrl-o of BR-i-docs in frame Dialog-Frame do:
   run sort-brBR-i-docs
     (input (if available X_icnt-doc
             then recid(X_icnt-doc)
             else ?
            )
     ).
end.
PROCEDURE sort-brBR-i-docs :
  define input parameter p-recid as recid no-undo .
  if re-queryBR-i-docs = no then do:
    assign
       cur-clmnBR-i-docs = BR-i-docs:current-column in frame Dialog-Frame
    .
    if sort-clmnBR-i-docs <> ? then sort-clmnBR-i-docs:column-fgcolor = 0.
    if cur-clmnBR-i-docs = sort-clmnBR-i-docs then do:
      assign
         sort-labelBR-i-docs = ""
         sort-clmnBR-i-docs = ?
      .
     end.
     else do:
       assign
         sort-labelBR-i-docs = cur-clmnBR-i-docs:label
         sort-clmnBR-i-docs  = cur-clmnBR-i-docs
         sort-clmnBR-i-docs:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locBR-i-docs = 1
  .
  def var column-handle as handle no-undo .
  column-handle = BR-i-docs:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnBR-i-docs then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locBR-i-docs = cur-clmn-locBR-i-docs + 1
    .
  end.
  case sort-labelBR-i-docs:
        when 'Статус'  then DO:    assign       sort-column-name = "X_icnt-doc.status_"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when 'Документ'  then DO:    assign       sort-column-name = "X_icnt-doc.doc-code"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when 'Дата'  then DO:    assign       sort-column-name = "X_icnt-doc.doc-date"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when 'Факт'  then DO:    assign       sort-column-name = "X_icnt-doc.fact-date"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when 'Время'  then DO:    assign       sort-column-name = "string(X_icnt-doc.fact-time, 'HH:MM:SS')"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when 'Смена'  then DO:    assign       sort-column-name = "X_icnt-doc.shift-date"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when '№'  then DO:    assign       sort-column-name = "shift-name (buffer X_icnt-doc)"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when 'Объект'  then DO:    assign       sort-column-name = "(X_icnt-doc.obj-type + STRING(X_icnt-doc.obj-code))"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when 'Количество!по счетчику'  then DO:    assign       sort-column-name = "X_icnt-doc.state-el-cnt"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when 'Количество!по мернику'  then DO:    assign       sort-column-name = "X_icnt-doc.state-mh-cnt"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when 'Разница'  then DO:    assign       sort-column-name = "(X_icnt-doc.state-el-cnt - X_icnt-doc.state-mh-cnt)"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when 'Измерения!электронных!счетчиков'  then DO:    assign       sort-column-name = "X_icnt-doc.meas-el-cnt"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure ( input yes, input no, input '':U).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultBR-i-docs') then do:
          run mv-brw-defaultBR-i-docs.
        end.
      if sort-labelBR-i-docs <> "" then do:
        assign
          cur-clmnBR-i-docs:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locBR-i-docs = ?
      .
    end.
  end case.
    if cur-clmn-locBR-i-docs <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnBR-i-docs') then do:
        run ch-clmnBR-i-docs in this-procedure (cur-clmn-locBR-i-docs).
      end.
    end.
  if p-recid <> ? then do:
    reposition BR-i-docs to recid p-recid no-error.
    apply "value-changed" to BR-i-docs in frame Dialog-Frame.
  end.
  apply "entry" to BR-i-docs in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnBR-i-docs:
if cur-clmnBR-i-docs = ? then do:
   run OpenBr in this-procedure ( input yes, input no, input '':U).
end.
else do:
   assign re-queryBR-i-docs = yes.
   run sort-brBR-i-docs
     (input (if available X_icnt-doc
             then recid(X_icnt-doc)
             else ?
            )
     ).
   assign re-queryBR-i-docs = no.
end.
end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numBR-i-docs as INT EXTENT 13 no-undo.
DEF VAR varmviBR-i-docs       as INT no-undo.
DEF VAR varmvjBR-i-docs       as INT no-undo.
DEF VAR varmvkBR-i-docs       as INT no-undo.
DEF VAR varmvlBR-i-docs       as INT no-undo.
DEF VAR move-elementBR-i-docs as INT no-undo.
def var jjBR-i-docs           as int no-undo.
do varmviBR-i-docs = 1 to EXTENT(cur-clmn-numBR-i-docs):
  ASSIGN cur-clmn-numBR-i-docs[varmviBR-i-docs] = varmviBR-i-docs.
END.
RUN start-mv-clmnBR-i-docs.
PROCEDURE start-mv-clmnBR-i-docs:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE BR-i-docs do:
  RUN re-move-clmnBR-i-docs ( 4, 13).
END.
ON ctrl-cursor-left OF BROWSE BR-i-docs do:
  RUN re-move-clmnBR-i-docs (13, 4).
END.
PROCEDURE re-move-clmnBR-i-docs:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmviBR-i-docs = 1 TO EXTENT(cur-clmn-numBR-i-docs):
    if cur-clmn-numBR-i-docs[varmviBR-i-docs] = source-column THEN cur-clmn-numBR-i-docs[varmviBR-i-docs] = -1.
  END.
  if BR-i-docs:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjBR-i-docs = source-column - 1 to target-column BY -1:
    DO varmviBR-i-docs = 1 TO EXTENT(cur-clmn-numBR-i-docs):
        if cur-clmn-numBR-i-docs[varmviBR-i-docs] = varmvjBR-i-docs THEN DO:
          cur-clmn-numBR-i-docs[varmviBR-i-docs] = cur-clmn-numBR-i-docs[varmviBR-i-docs] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjBR-i-docs = source-column + 1 to target-column:
    DO varmviBR-i-docs = 1 TO EXTENT(cur-clmn-numBR-i-docs):
      if cur-clmn-numBR-i-docs[varmviBR-i-docs] = varmvjBR-i-docs THEN DO:
        cur-clmn-numBR-i-docs[varmviBR-i-docs] = cur-clmn-numBR-i-docs[varmviBR-i-docs] - 1.
      END.
    END.
  END.
  DO varmviBR-i-docs = 1 TO EXTENT(cur-clmn-numBR-i-docs):
    if cur-clmn-numBR-i-docs[varmviBR-i-docs] = -1 THEN cur-clmn-numBR-i-docs[varmviBR-i-docs] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnBR-i-docs:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 4 then do:
    return .
  end.
  DO varmviBR-i-docs = 1 TO EXTENT(cur-clmn-numBR-i-docs):
    if cur-clmn-numBR-i-docs[varmviBR-i-docs] = cur-clmn-loc THEN move-elementBR-i-docs = varmviBR-i-docs.
  END.
  RUN re-move-clmnBR-i-docs (cur-clmn-loc, 4).
END PROCEDURE.
PROCEDURE mv-brw-defaultBR-i-docs:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlBR-i-docs = 4 to EXTENT(cur-clmn-numBR-i-docs):
    RUN re-move-clmnBR-i-docs (cur-clmn-numBR-i-docs[varmvlBR-i-docs], varmvlBR-i-docs).
  END.
  RUN start-mv-clmnBR-i-docs.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  IF lookup(p-list-mode, 'все':U + chr(4) +
                         'объект':U + chr(4) +
                         'статус':U + chr(4) +
                         'фирма':U, chr(4) ) = 0 THEN DO:
    MESSAGE
    substitute("Неверное значение параметра p-list-mode=&1", p-list-mode)
    VIEW-AS ALERT-BOX error.
    undo, RETURN ERROR.
  END.
  if p-list-mode = 'объект':U
  or p-list-mode = 'статус':U then do:
    find first buf_clients no-lock where
              buf_clients.obj-type = p-obj-type
          and buf_clients.obj-code = p-obj-code no-error.
    if not available buf_clients
    or not (buf_clients.obj-type = 'маг':U)
    then do:
      MESSAGE
      substitute("Неверное значение параметров p-obj-type=&1 и/или p-obj-code= &2"
               , p-obj-type
               , p-obj-code)
      VIEW-AS ALERT-BOX error.
      undo, RETURN ERROR.
    end.
  end.
  if p-list-mode = 'фирма':U then do:
    find first buf_sysconf no-lock where
              buf_sysconf.host-code = p-host-code no-error.
   if not available buf_sysconf then do:
      MESSAGE
      substitute("Неверное значение параметра p-host-codee=&1"
               , p-host-code)
      VIEW-AS ALERT-BOX error.
      undo, RETURN ERROR.
   end.
  end.
  IF LOOKUP(p-doc-type, 'инв-сч-трк,сч-трк-погр':U ) = 0 THEN DO:
    MESSAGE
    substitute("Неверное значение параметра p-doc-type=&1", p-doc-type)
    VIEW-AS ALERT-BOX error.
    undo, RETURN ERROR.
  END.
  v-rid-list = p-rid-list.
  run Myenable IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH X_icnt-doc SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY ED-notes mark-num obj-name boss-name agnt-name wrkr-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_icnt-doc THEN
    DISPLAY X_icnt-doc.creid
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel b-add b-chg b-del b-lkp b-print b-sch B-Help
         b-close BR-i-docs ED-notes mark-num obj-name boss-name agnt-name
         wrkr-name X_icnt-doc.creid
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
ASSIGN
br-i-docs:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 4
X_icnt-doc.meas-el-cnt:READ-ONLY in browse br-i-docs = YES
.
enable
b-quit
b-help
b-print
b-lkp
b-sch
b-sel WHEN lookup("b-sel", bttns) > 0
b-mark WHEN lookup("b-mark", bttns) > 0
b-add WHEN ((p-list-mode = 'объект':U
            OR p-list-mode = 'статус':U)
            AND v-cntxt-db-num = buf_clients.db-num
            AND lookup("b-add", bttns) > 0 AND NOT TRANSACTION)
b-chg WHEN ((p-list-mode = 'объект':U
            OR p-list-mode = 'статус':U)
            AND v-cntxt-db-num = buf_clients.db-num
            AND lookup("b-add", bttns) > 0 AND NOT TRANSACTION)
b-del WHEN ((p-list-mode = 'объект':U
            OR p-list-mode = 'статус':U)
            AND v-cntxt-db-num = buf_clients.db-num
            AND lookup("b-add", bttns) > 0 AND NOT TRANSACTION)
b-close WHEN ((p-list-mode = 'объект':U
            OR (p-list-mode = 'статус':U AND p-status_ <> 'факт':U)
              )
            AND v-cntxt-db-num = buf_clients.db-num
            AND lookup("b-add", bttns) > 0 AND NOT TRANSACTION)
br-i-docs
with frame Dialog-Frame.
run OpenBr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
apply "entry" to br-i-docs in frame Dialog-Frame.
apply "value-changed" to br-i-docs in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE Openbr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo .
define buffer buf_clients for ub.clients.
case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.
filter-point = filter-point0 + p-list-mode .
if p-doc-type = 'инв-сч-трк':U then do:
  title0 = "ДОКУМЕНТЫ ИНВЕНТАРИЗАЦИИ СЧЕТЧИКОВ ТРК".
end.
if p-doc-type = 'сч-трк-погр':U then do:
  title0 = "ДОКУМЕНТЫ ИЗМЕРЕНИЯ ПОГРЕШНОСТИ СЧЕТЧИКОВ ТРК".
end.
CASE p-list-mode:
  when 'все':U then do:
    ASSIGN
    frame Dialog-Frame:title = substitute("&1: ВСЕ", title0)
    filter-label = SUBSTITUTE("&1"
                              , frame Dialog-Frame:title
                              )
    .
    if p-doc-type = 'инв-сч-трк':U then do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-27  as logical   no-undo .
define variable  l-filter-open-27    as logical   .
define variable  flt-rec-27       as recid     no-undo .
define variable  filter-name-27      as character no-undo .
define variable  where-phrase-27     as character no-undo .
define variable  sort-phrase-27      as character no-undo .
define variable  where-phrase-rus-27 as character no-undo .
define variable  sort-phrase-rus-27  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-27
  ,output filter-name-27
  ,output where-phrase-27
  ,output sort-phrase-27
  ,output where-phrase-rus-27
  ,output sort-phrase-rus-27
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-27
      ) no-error .
  assign
    l-filter-open-27 = false
  .
  if flt-rec-27 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-27 as character no-undo .
    define variable  parameter-3-27 as character no-undo .
    define variable  parameter-4-27 as character no-undo .
    define variable  parameter-5-27 as character no-undo .
    define variable  parameter-6-27 as character no-undo .
    define variable  parameter-7-27 as character no-undo .
      assign
      parameter-3-27 =
                              "FOR EACH X_icnt-doc"
      parameter-4-27 =
        (
          if (" X_icnt-doc.doc-type = p-doc-type " + " " + where-phrase-27) <> ""
          then  substitute('X_icnt-doc.doc-type = &1&2&1', chr(34), p-doc-type ) + " " + where-phrase-27
          else "true"
        )
      parameter-5-27 = (" " + "" + " " + "")
      parameter-6-27 = if sort-phrase-27 = ''
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
        " " + sort-phrase-27
        )
      parameter-7-27 =
        " INDEXED-REPOSITION  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-27 =
          (" X_icnt-doc.doc-type = p-doc-type " + " " + where-phrase-27 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-i-docs:handle
                          ,input parameter-3-27
                          ,input parameter-4-27
                          ,input parameter-5-27
                          ,input parameter-6-27
                          ,input parameter-7-27
                          )
      .
      assign
        l-filter-open-27 = true
      .
    end.
    if l-filter-open-27 = false then do:
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
  if l-filter-open-27 = false then do:
    OPEN QUERY br-i-docs FOR EACH X_icnt-doc
      where  X_icnt-doc.doc-type = p-doc-type
      INDEXED-REPOSITION
  .
      assign
        l-query-was-opened = true
      .
  end.
    end.
    if p-doc-type = 'сч-трк-погр':U then do:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-29  as logical   no-undo .
define variable  l-filter-open-29    as logical   .
define variable  flt-rec-29       as recid     no-undo .
define variable  filter-name-29      as character no-undo .
define variable  where-phrase-29     as character no-undo .
define variable  sort-phrase-29      as character no-undo .
define variable  where-phrase-rus-29 as character no-undo .
define variable  sort-phrase-rus-29  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-29
  ,output filter-name-29
  ,output where-phrase-29
  ,output sort-phrase-29
  ,output where-phrase-rus-29
  ,output sort-phrase-rus-29
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-29
      ) no-error .
  assign
    l-filter-open-29 = false
  .
  if flt-rec-29 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-29 as character no-undo .
    define variable  parameter-3-29 as character no-undo .
    define variable  parameter-4-29 as character no-undo .
    define variable  parameter-5-29 as character no-undo .
    define variable  parameter-6-29 as character no-undo .
    define variable  parameter-7-29 as character no-undo .
      assign
      parameter-3-29 =
                              "FOR EACH X_icnt-doc"
      parameter-4-29 =
        (
          if (" X_icnt-doc.doc-type = p-doc-type " + " " + where-phrase-29) <> ""
          then  substitute('X_icnt-doc.doc-type = &1&2&1', chr(34), p-doc-type ) + " " + where-phrase-29
          else "true"
        )
      parameter-5-29 = (" " + "" + " " + "")
      parameter-6-29 = if sort-phrase-29 = ''
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
        " " + sort-phrase-29
        )
      parameter-7-29 =
        " INDEXED-REPOSITION  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-29 =
          (" X_icnt-doc.doc-type = p-doc-type " + " " + where-phrase-29 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-i-docs:handle
                          ,input parameter-3-29
                          ,input parameter-4-29
                          ,input parameter-5-29
                          ,input parameter-6-29
                          ,input parameter-7-29
                          )
      .
      assign
        l-filter-open-29 = true
      .
    end.
    if l-filter-open-29 = false then do:
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
  if l-filter-open-29 = false then do:
    OPEN QUERY br-i-docs FOR EACH X_icnt-doc
      where  X_icnt-doc.doc-type = p-doc-type
      INDEXED-REPOSITION
  .
      assign
        l-query-was-opened = true
      .
  end.
    end.
  end.
  when 'фирма':U then do:
    ASSIGN
    frame Dialog-Frame:title = substitute("&1: Фирма &2"
                                          , title0
                                          , p-host-code)
    filter-label = SUBSTITUTE("&1"
                              , frame Dialog-Frame:title
                              )
    .
    if p-doc-type = 'инв-сч-трк':U then do:
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-31  as logical   no-undo .
define variable  l-filter-open-31    as logical   .
define variable  flt-rec-31       as recid     no-undo .
define variable  filter-name-31      as character no-undo .
define variable  where-phrase-31     as character no-undo .
define variable  sort-phrase-31      as character no-undo .
define variable  where-phrase-rus-31 as character no-undo .
define variable  sort-phrase-rus-31  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-31
  ,output filter-name-31
  ,output where-phrase-31
  ,output sort-phrase-31
  ,output where-phrase-rus-31
  ,output sort-phrase-rus-31
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-31
      ) no-error .
  assign
    l-filter-open-31 = false
  .
  if flt-rec-31 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-31 as character no-undo .
    define variable  parameter-3-31 as character no-undo .
    define variable  parameter-4-31 as character no-undo .
    define variable  parameter-5-31 as character no-undo .
    define variable  parameter-6-31 as character no-undo .
    define variable  parameter-7-31 as character no-undo .
      assign
      parameter-3-31 =
                              "FOR EACH X_icnt-doc"
      parameter-4-31 =
        (
          if (" X_icnt-doc.host-code = p-host-code                         and X_icnt-doc.doc-type = p-doc-type " + " " + where-phrase-31) <> ""
          then  substitute('X_icnt-doc.host-code = &1                         and X_icnt-doc.doc-type = &2&3&2 ', p-host-code, chr(34), p-doc-type) + " " + where-phrase-31
          else "true"
        )
      parameter-5-31 = (" " + "" + " " + "")
      parameter-6-31 = if sort-phrase-31 = ''
                           then
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-31
        )
      parameter-7-31 =
        " INDEXED-REPOSITION  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-31 =
          (" X_icnt-doc.host-code = p-host-code                         and X_icnt-doc.doc-type = p-doc-type " + " " + where-phrase-31 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-i-docs:handle
                          ,input parameter-3-31
                          ,input parameter-4-31
                          ,input parameter-5-31
                          ,input parameter-6-31
                          ,input parameter-7-31
                          )
      .
      assign
        l-filter-open-31 = true
      .
    end.
    if l-filter-open-31 = false then do:
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
  if l-filter-open-31 = false then do:
    OPEN QUERY br-i-docs FOR EACH X_icnt-doc
      where  X_icnt-doc.host-code = p-host-code                         and X_icnt-doc.doc-type = p-doc-type
       use-index host-date
      INDEXED-REPOSITION
  .
      assign
        l-query-was-opened = true
      .
  end.
    end.
    if p-doc-type = 'сч-трк-погр':U then do:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-33  as logical   no-undo .
define variable  l-filter-open-33    as logical   .
define variable  flt-rec-33       as recid     no-undo .
define variable  filter-name-33      as character no-undo .
define variable  where-phrase-33     as character no-undo .
define variable  sort-phrase-33      as character no-undo .
define variable  where-phrase-rus-33 as character no-undo .
define variable  sort-phrase-rus-33  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-33
  ,output filter-name-33
  ,output where-phrase-33
  ,output sort-phrase-33
  ,output where-phrase-rus-33
  ,output sort-phrase-rus-33
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-33
      ) no-error .
  assign
    l-filter-open-33 = false
  .
  if flt-rec-33 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-33 as character no-undo .
    define variable  parameter-3-33 as character no-undo .
    define variable  parameter-4-33 as character no-undo .
    define variable  parameter-5-33 as character no-undo .
    define variable  parameter-6-33 as character no-undo .
    define variable  parameter-7-33 as character no-undo .
      assign
      parameter-3-33 =
                              "FOR EACH X_icnt-doc"
      parameter-4-33 =
        (
          if (" X_icnt-doc.host-code = p-host-code                         and X_icnt-doc.doc-type = p-doc-type " + " " + where-phrase-33) <> ""
          then  substitute('X_icnt-doc.host-code = &1                         and X_icnt-doc.doc-type = &2&3&2 ', p-host-code, chr(34), p-doc-type) + " " + where-phrase-33
          else "true"
        )
      parameter-5-33 = (" " + "" + " " + "")
      parameter-6-33 = if sort-phrase-33 = ''
                           then
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index host-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-33
        )
      parameter-7-33 =
        " INDEXED-REPOSITION  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-33 =
          (" X_icnt-doc.host-code = p-host-code                         and X_icnt-doc.doc-type = p-doc-type " + " " + where-phrase-33 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-i-docs:handle
                          ,input parameter-3-33
                          ,input parameter-4-33
                          ,input parameter-5-33
                          ,input parameter-6-33
                          ,input parameter-7-33
                          )
      .
      assign
        l-filter-open-33 = true
      .
    end.
    if l-filter-open-33 = false then do:
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
  if l-filter-open-33 = false then do:
    OPEN QUERY br-i-docs FOR EACH X_icnt-doc
      where  X_icnt-doc.host-code = p-host-code                         and X_icnt-doc.doc-type = p-doc-type
       use-index host-date
      INDEXED-REPOSITION
  .
      assign
        l-query-was-opened = true
      .
  end.
    end.
  end.
  when 'объект':U then do:
    ASSIGN
    frame Dialog-Frame:title = substitute("&1: &2&3"
                                          , title0
                                          , p-obj-type
                                          , p-obj-code)
    filter-label = SUBSTITUTE("&1"
                              , frame Dialog-Frame:title
                              )
    .
    if p-doc-type = 'инв-сч-трк':U then do:
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-35  as logical   no-undo .
define variable  l-filter-open-35    as logical   .
define variable  flt-rec-35       as recid     no-undo .
define variable  filter-name-35      as character no-undo .
define variable  where-phrase-35     as character no-undo .
define variable  sort-phrase-35      as character no-undo .
define variable  where-phrase-rus-35 as character no-undo .
define variable  sort-phrase-rus-35  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-35
  ,output filter-name-35
  ,output where-phrase-35
  ,output sort-phrase-35
  ,output where-phrase-rus-35
  ,output sort-phrase-rus-35
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-35
      ) no-error .
  assign
    l-filter-open-35 = false
  .
  if flt-rec-35 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-35 as character no-undo .
    define variable  parameter-3-35 as character no-undo .
    define variable  parameter-4-35 as character no-undo .
    define variable  parameter-5-35 as character no-undo .
    define variable  parameter-6-35 as character no-undo .
    define variable  parameter-7-35 as character no-undo .
      assign
      parameter-3-35 =
                              "FOR EACH X_icnt-doc"
      parameter-4-35 =
        (
          if (" X_icnt-doc.obj-type = p-obj-type                         and X_icnt-doc.obj-code = p-obj-code                         and X_icnt-doc.doc-type = p-doc-type " + " " + where-phrase-35) <> ""
          then  substitute('X_icnt-doc.obj-type = &1&2&1                         and X_icnt-doc.obj-code = &3                         and X_icnt-doc.doc-type = &1&4&1 ', chr(34), p-obj-type, p-obj-code, p-doc-type) + " " + where-phrase-35
          else "true"
        )
      parameter-5-35 = (" " + "" + " " + "")
      parameter-6-35 = if sort-phrase-35 = ''
                           then
        (
        " " + "use-index obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "use-index obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-35
        )
      parameter-7-35 =
        " INDEXED-REPOSITION  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-35 =
          (" X_icnt-doc.obj-type = p-obj-type                         and X_icnt-doc.obj-code = p-obj-code                         and X_icnt-doc.doc-type = p-doc-type " + " " + where-phrase-35 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-i-docs:handle
                          ,input parameter-3-35
                          ,input parameter-4-35
                          ,input parameter-5-35
                          ,input parameter-6-35
                          ,input parameter-7-35
                          )
      .
      assign
        l-filter-open-35 = true
      .
    end.
    if l-filter-open-35 = false then do:
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
  if l-filter-open-35 = false then do:
    OPEN QUERY br-i-docs FOR EACH X_icnt-doc
      where  X_icnt-doc.obj-type = p-obj-type                         and X_icnt-doc.obj-code = p-obj-code                         and X_icnt-doc.doc-type = p-doc-type
      use-index obj-date
      INDEXED-REPOSITION
  .
      assign
        l-query-was-opened = true
      .
  end.
    end.
    if p-doc-type = 'сч-трк-погр':U then do:
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-37  as logical   no-undo .
define variable  l-filter-open-37    as logical   .
define variable  flt-rec-37       as recid     no-undo .
define variable  filter-name-37      as character no-undo .
define variable  where-phrase-37     as character no-undo .
define variable  sort-phrase-37      as character no-undo .
define variable  where-phrase-rus-37 as character no-undo .
define variable  sort-phrase-rus-37  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-37
  ,output filter-name-37
  ,output where-phrase-37
  ,output sort-phrase-37
  ,output where-phrase-rus-37
  ,output sort-phrase-rus-37
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-37
      ) no-error .
  assign
    l-filter-open-37 = false
  .
  if flt-rec-37 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-37 as character no-undo .
    define variable  parameter-3-37 as character no-undo .
    define variable  parameter-4-37 as character no-undo .
    define variable  parameter-5-37 as character no-undo .
    define variable  parameter-6-37 as character no-undo .
    define variable  parameter-7-37 as character no-undo .
      assign
      parameter-3-37 =
                              "FOR EACH X_icnt-doc"
      parameter-4-37 =
        (
          if (" X_icnt-doc.obj-type = p-obj-type                         and X_icnt-doc.obj-code = p-obj-code                         and X_icnt-doc.doc-type = p-doc-type  " + " " + where-phrase-37) <> ""
          then  substitute('X_icnt-doc.obj-type = &1&2&1                         and X_icnt-doc.obj-code = &3                         and X_icnt-doc.doc-type = &1&4&1 ', chr(34), p-obj-type, p-obj-code, p-doc-type) + " " + where-phrase-37
          else "true"
        )
      parameter-5-37 = (" " + "" + " " + "")
      parameter-6-37 = if sort-phrase-37 = ''
                           then
        (
        " " + "use-index obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "use-index obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-37
        )
      parameter-7-37 =
        " INDEXED-REPOSITION  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-37 =
          (" X_icnt-doc.obj-type = p-obj-type                         and X_icnt-doc.obj-code = p-obj-code                         and X_icnt-doc.doc-type = p-doc-type  " + " " + where-phrase-37 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-i-docs:handle
                          ,input parameter-3-37
                          ,input parameter-4-37
                          ,input parameter-5-37
                          ,input parameter-6-37
                          ,input parameter-7-37
                          )
      .
      assign
        l-filter-open-37 = true
      .
    end.
    if l-filter-open-37 = false then do:
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
  if l-filter-open-37 = false then do:
    OPEN QUERY br-i-docs FOR EACH X_icnt-doc
      where  X_icnt-doc.obj-type = p-obj-type                         and X_icnt-doc.obj-code = p-obj-code                         and X_icnt-doc.doc-type = p-doc-type
      use-index obj-date
      INDEXED-REPOSITION
  .
      assign
        l-query-was-opened = true
      .
  end.
    end.
  end.
  when 'статус':U then do:
    ASSIGN
    frame Dialog-Frame:title = substitute("&1: &2&3 статус &4"
                                          , title0
                                          , p-obj-type
                                          , p-obj-code
                                          , p-status_)
    filter-label = SUBSTITUTE("&1"
                              , frame Dialog-Frame:title
                              )
    .
    if p-doc-type = 'инв-сч-трк':U then do:
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-39  as logical   no-undo .
define variable  l-filter-open-39    as logical   .
define variable  flt-rec-39       as recid     no-undo .
define variable  filter-name-39      as character no-undo .
define variable  where-phrase-39     as character no-undo .
define variable  sort-phrase-39      as character no-undo .
define variable  where-phrase-rus-39 as character no-undo .
define variable  sort-phrase-rus-39  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-39
  ,output filter-name-39
  ,output where-phrase-39
  ,output sort-phrase-39
  ,output where-phrase-rus-39
  ,output sort-phrase-rus-39
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-39
      ) no-error .
  assign
    l-filter-open-39 = false
  .
  if flt-rec-39 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-39 as character no-undo .
    define variable  parameter-3-39 as character no-undo .
    define variable  parameter-4-39 as character no-undo .
    define variable  parameter-5-39 as character no-undo .
    define variable  parameter-6-39 as character no-undo .
    define variable  parameter-7-39 as character no-undo .
      assign
      parameter-3-39 =
                              "FOR EACH X_icnt-doc"
      parameter-4-39 =
        (
          if ("X_icnt-doc.obj-type = p-obj-type                       AND X_icnt-doc.obj-code = p-obj-code                       AND X_icnt-doc.status_  = p-status_
                      and X_icnt-doc.doc-type = p-doc-type " + " " + where-phrase-39) <> ""
          then  substitute(' X_icnt-doc.obj-type = &1&2&1                       AND X_icnt-doc.obj-code = &3                       AND X_icnt-doc.status_  = &1&4&1
                      and X_icnt-doc.doc-type = &1&5&1 ', chr(34), p-obj-type, p-obj-code, p-status_, p-doc-type) + " " + where-phrase-39
          else "true"
        )
      parameter-5-39 = (" " + "" + " " + "")
      parameter-6-39 = if sort-phrase-39 = ''
                           then
        (
        " " + "use-index stat-date" +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "use-index stat-date" +
          " " + sort-column-phrase +
        " " + sort-phrase-39
        )
      parameter-7-39 =
        " INDEXED-REPOSITION  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-39 =
          ("X_icnt-doc.obj-type = p-obj-type                       AND X_icnt-doc.obj-code = p-obj-code                       AND X_icnt-doc.status_  = p-status_
                      and X_icnt-doc.doc-type = p-doc-type " + " " + where-phrase-39 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-i-docs:handle
                          ,input parameter-3-39
                          ,input parameter-4-39
                          ,input parameter-5-39
                          ,input parameter-6-39
                          ,input parameter-7-39
                          )
      .
      assign
        l-filter-open-39 = true
      .
    end.
    if l-filter-open-39 = false then do:
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
  if l-filter-open-39 = false then do:
    OPEN QUERY br-i-docs FOR EACH X_icnt-doc
      where X_icnt-doc.obj-type = p-obj-type                       AND X_icnt-doc.obj-code = p-obj-code                       AND X_icnt-doc.status_  = p-status_
                      and X_icnt-doc.doc-type = p-doc-type
      use-index stat-date
      INDEXED-REPOSITION
  .
      assign
        l-query-was-opened = true
      .
  end.
    end.
    if p-doc-type = 'сч-трк-погр':U then do:
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-41  as logical   no-undo .
define variable  l-filter-open-41    as logical   .
define variable  flt-rec-41       as recid     no-undo .
define variable  filter-name-41      as character no-undo .
define variable  where-phrase-41     as character no-undo .
define variable  sort-phrase-41      as character no-undo .
define variable  where-phrase-rus-41 as character no-undo .
define variable  sort-phrase-rus-41  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-41
  ,output filter-name-41
  ,output where-phrase-41
  ,output sort-phrase-41
  ,output where-phrase-rus-41
  ,output sort-phrase-rus-41
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-41
      ) no-error .
  assign
    l-filter-open-41 = false
  .
  if flt-rec-41 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-41 as character no-undo .
    define variable  parameter-3-41 as character no-undo .
    define variable  parameter-4-41 as character no-undo .
    define variable  parameter-5-41 as character no-undo .
    define variable  parameter-6-41 as character no-undo .
    define variable  parameter-7-41 as character no-undo .
      assign
      parameter-3-41 =
                              "FOR EACH X_icnt-doc"
      parameter-4-41 =
        (
          if ("X_icnt-doc.obj-type = p-obj-type                       AND X_icnt-doc.obj-code = p-obj-code                       AND X_icnt-doc.status_  = p-status_
                      and X_icnt-doc.doc-type = p-doc-type  " + " " + where-phrase-41) <> ""
          then  substitute(' X_icnt-doc.obj-type = &1&2&1                       AND X_icnt-doc.obj-code = &3                       AND X_icnt-doc.status_  = &1&4&1
                      and X_icnt-doc.doc-type = &1&5&1 ', chr(34), p-obj-type, p-obj-code, p-status_, p-doc-type) + " " + where-phrase-41
          else "true"
        )
      parameter-5-41 = (" " + "" + " " + "")
      parameter-6-41 = if sort-phrase-41 = ''
                           then
        (
        " " + "use-index stat-date" +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "use-index stat-date" +
          " " + sort-column-phrase +
        " " + sort-phrase-41
        )
      parameter-7-41 =
        " INDEXED-REPOSITION  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-41 =
          ("X_icnt-doc.obj-type = p-obj-type                       AND X_icnt-doc.obj-code = p-obj-code                       AND X_icnt-doc.status_  = p-status_
                      and X_icnt-doc.doc-type = p-doc-type  " + " " + where-phrase-41 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-i-docs:handle
                          ,input parameter-3-41
                          ,input parameter-4-41
                          ,input parameter-5-41
                          ,input parameter-6-41
                          ,input parameter-7-41
                          )
      .
      assign
        l-filter-open-41 = true
      .
    end.
    if l-filter-open-41 = false then do:
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
  if l-filter-open-41 = false then do:
    OPEN QUERY br-i-docs FOR EACH X_icnt-doc
      where X_icnt-doc.obj-type = p-obj-type                       AND X_icnt-doc.obj-code = p-obj-code                       AND X_icnt-doc.status_  = p-status_
                      and X_icnt-doc.doc-type = p-doc-type
      use-index stat-date
      INDEXED-REPOSITION
  .
      assign
        l-query-was-opened = true
      .
  end.
    end.
  end.
END CASE.
APPLY "entry" TO br-i-docs.
if available X_icnt-doc then do:
    APPLY "VALUE-CHANGED":U to BR-i-docs.
END.
END PROCEDURE.
PROCEDURE proc-b-add :
define variable v-icnt-line-rec as recid no-undo .
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
define variable next-prev as character no-undo .
define variable v-host-code as integer no-undo .
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info43 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_icnt-doc_preparation':U
    ,input  'object':U
    ,input  v-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
if not glog then return no-apply.
do on stop undo, return no-apply:
  case p-doc-type:
    when 'инв-сч-трк':U then do:
      run ref/icntdoci.w ( INPUT parparentproc
                      ,INPUT 'ДОБАВЛЕНИЕ':U
                      ,INPUT v-cntxt-obj-type
                      ,INPUT v-cntxt-obj-code
                      ,INPUT-output v-icnt-rec
                      ,input-output v-icnt-line-rec
                      ,input this-procedure:handle
                      ,input-output next-prev
                      ) no-error.
    end.
    when 'сч-трк-погр':U then do:
      run ref/icntdoce.w ( INPUT parparentproc
                      ,INPUT 'ДОБАВЛЕНИЕ':U
                      ,INPUT v-cntxt-obj-type
                      ,INPUT v-cntxt-obj-code
                      ,INPUT-output v-icnt-rec
                      ,input-output v-icnt-line-rec
                      ,input this-procedure:handle
                      ,input-output next-prev
                      ) no-error.
    end.
  end case.
  if error-status:error then undo, return no-apply.
end.
if v-icnt-rec = ? then undo, return error.
run Openbr IN THIS-PROCEDURE ( INPUT yes, INPUT no, INPUT '':U).
REPOSITION br-i-docs TO RECID v-icnt-rec NO-ERROR.
APPLY "ENTRY" to br-i-docs in frame Dialog-Frame .
APPLY "value-changed" TO br-i-docs.
message
"Новый документ счетчиков ТРК добавлен в Базу Данных."
VIEW-AS ALERT-BOX.
END PROCEDURE.
PROCEDURE proc-b-chg :
DEFINE VARIABLE glog AS LOGICAL no-undo.
define variable v-icnt-line-rec as recid no-undo .
define variable next-prev as character no-undo .
define variable vss-include-info44 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_icnt-doc_preparation':U
    ,input  'object':U
    ,input  X_icnt-doc.host-code
    ,input  X_icnt-doc.obj-type
    ,input  X_icnt-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
if not glog then return no-apply.
assign v-icnt-rec = recid(X_icnt-doc).
do on stop undo, return no-apply:
  case p-doc-type:
    when 'инв-сч-трк':U then do:
      run ref/icntdoci.w ( INPUT parparentproc
                      ,INPUT 'ИЗМЕНЕНИЕ':U
                      ,INPUT X_icnt-doc.obj-type
                      ,INPUT X_icnt-doc.obj-code
                      ,input-output v-icnt-rec
                      ,input-output v-icnt-line-rec
                      ,input this-procedure:handle
                      ,input-output next-prev
                      ) no-error.
    end.
    when 'сч-трк-погр':U then do:
      run ref/icntdoce.w ( INPUT parparentproc
                      ,INPUT 'ИЗМЕНЕНИЕ':U
                      ,INPUT X_icnt-doc.obj-type
                      ,INPUT X_icnt-doc.obj-code
                      ,input-output v-icnt-rec
                      ,input-output v-icnt-line-rec
                      ,input this-procedure:handle
                      ,input-output next-prev
                      ) no-error.
    end.
  end case.
  if error-status:error then undo, return no-apply.
end.
if error-status:error then do:
  UNDO, RETURN ERROR.
end.
apply "entry" to BR-i-docs in frame Dialog-Frame.
run Openbr IN THIS-PROCEDURE ( INPUT yes, INPUT no, INPUT '':U).
REPOSITION br-i-docs TO RECID v-icnt-rec NO-ERROR.
APPLY "ENTRY" to br-i-docs.
APPLY "value-changed" TO br-i-docs.
END PROCEDURE.
PROCEDURE proc-b-lkp :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
define variable next-prev as character no-undo .
define variable v-icnt-line-rec as recid no-undo .
IF NOT AVAILABLE X_icnt-doc THEN UNDO, RETURN ERROR.
define variable vss-include-info45 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_icnt-doc_lookup':U
    ,input  'object':U
    ,input  X_icnt-doc.host-code
    ,input  X_icnt-doc.obj-type
    ,input  X_icnt-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
if not glog then
  return no-apply.
if not glog then  undo, RETURN no-apply.
assign
  v-icnt-rec = recid (X_icnt-doc)
  .
do on stop undo, return no-apply:
  case p-doc-type:
    when 'инв-сч-трк':U then do:
      run ref/icntdoci.w ( INPUT parparentproc
                      ,INPUT 'ПРОСМОТР':U
                      ,INPUT X_icnt-doc.obj-type
                      ,INPUT X_icnt-doc.obj-code
                      ,input-output v-icnt-rec
                      ,input-output v-icnt-line-rec
                      ,input this-procedure:handle
                      ,input-output next-prev
                      ) no-error .
   end.
   when 'сч-трк-погр':U then do:
      run ref/icntdoce.w ( INPUT parparentproc
                      ,INPUT 'ПРОСМОТР':U
                      ,INPUT X_icnt-doc.obj-type
                      ,INPUT X_icnt-doc.obj-code
                      ,input-output v-icnt-rec
                      ,input-output v-icnt-line-rec
                      ,input this-procedure:handle
                      ,input-output next-prev
                      ) no-error .
    end.
  end case.
  if error-status:error then return no-apply.
end.
if v-icnt-rec <> ? then reposition br-i-docs to recid v-icnt-rec no-error.
apply "entry" to br-i-docs in frame Dialog-Frame.
apply "value-changed" to br-i-docs in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-print :
DEFINE VARIABLE v-icnt-rec AS RECID no-undo.
DEFINE VARIABLE glog AS logical no-undo.
IF NOT AVAILABLE X_icnt-doc THEN RETURN ERROR.
ASSIGN
v-icnt-rec = recid (X_icnt-doc).
define variable vss-include-info46 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_icnt-doc_print':U
    ,input  'object':U
    ,input  X_icnt-doc.host-code
    ,input  X_icnt-doc.obj-type
    ,input  X_icnt-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
if not glog then return no-apply.
case  X_icnt-doc.doc-type:
  when 'инв-сч-трк':U then do:
    run rep/r-apump.p ( input parparentproc
                  ,input v-icnt-rec) no-error .
  end.
  when 'сч-трк-погр':U then do:
    run rep/r-epump.p ( input parparentproc
                  ,input v-icnt-rec) no-error .
  end.
end case.
apply "entry" to br-i-docs in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-sch :
define variable v-ri as recid no-undo .
assign
v-ri = (if avail X_icnt-doc then recid(X_icnt-doc) else ?)
.
assign
tbl = 'icnt-doc'
join-tbl = 'X_icnt-doc'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('host-code', 'Фирма', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type*obj-code', 'Объект', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-code', 'Номер документа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', 'Дата_факт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-date', 'Дата_смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', 'Порядок_смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
DO on stop undo, leave:
    run gbl/filter.w ( INPUT parparentproc
                 ,INPUT filter-point + chr(4) + filter-label
                 ,INPUT tbl
                 ,INPUT join-tbl
                 ,INPUT fld
                 ,INput lab
                 ,INPUT spr
                 ,INPUT  dim).
    run OpenBr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
    if v-ri <> ? then do:
      reposition br-i-docs to recid v-ri no-error.
    end.
    APPLY "ENTRY" to br-i-docs in frame Dialog-Frame .
    APPLY "VALUE-CHANGED" to br-i-docs.
END .
END PROCEDURE.
PROCEDURE reopen-query :
if available X_icnt-doc then v-icnt-rec = recid(X_icnt-doc).
run OpenBr in THIS-PROCEDURE ( INPUT yes, INPUT no, INPUT '':U).
reposition br-i-docs to recid v-icnt-rec no-error.
apply "entry" to br-i-docs in frame Dialog-Frame .
apply "value-changed" to br-i-docs in frame Dialog-Frame .
END PROCEDUR.
PROCEDURE reposition-icnt-doc :
define input  parameter p-direction   as character no-undo .
define output parameter p-icnt-doc-recid as recid no-undo .
  case p-direction :
    when "first":U
    then do:
      get first br-i-docs.
    end.
    when "last":U
    then do:
      get last br-i-docs.
    end.
    when "prev":U
    then do:
      get prev br-i-docs.
      if not available X_icnt-doc then do:
        message
        "Это первый документ списка"
        view-as alert-box.
      end.
    end.
    when "next":U
    then do:
      get next br-i-docs.
      if not available X_icnt-doc then do:
        message
        "Это последний документ списка"
        view-as alert-box.
      end.
    end.
  end case .
  assign
  p-icnt-doc-recid = recid(X_icnt-doc)
  .
  run reposition-query in this-procedure
    (input p-icnt-doc-recid
    ).
END PROCEDURE.
PROCEDURE reposition-query :
define input parameter p-recid as recid no-undo .
  if p-recid <> ?
  then do:
    reposition br-i-docs to recid p-recid no-error.
  end.
  do with frame Dialog-Frame:
    apply "entry":u to browse br-i-docs .
    apply "VALUE-CHANGED":u to browse br-i-docs .
  end.
END PROCEDURE.
