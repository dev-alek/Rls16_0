DEFINE BUFFER X_prop-head FOR ub.prop-head.
DEFINE BUFFER X_prop-script FOR ub.prop-script.
DEFINE BUFFER X_pscript-ruleset FOR ub.pscript-ruleset.
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns as character no-undo.
DEFINE INPUT PARAMETER p-list-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-codex-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-ruleset-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-dtm-code AS INTEGER NO-UNDO.
define input parameter p-language as character no-undo .
define input parameter p-script-name as character no-undo .
define input-output parameter p-rid-list as character no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список pscript-ruleset".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable sort-column-name as character no-undo .
define variable filter-point-label as character no-undo init "Привязка скриптов к наборам правил" .
define variable filter-point0 as character no-undo init "pscript-ruleset-s" .
define variable filter-point as character no-undo init "pscript-ruleset-s" .
DEFINE VARIABLE p-word-script-name AS CHARACTER NO-UNDO.
define variable v-rid-list as character no-undo .
FUNCTION get-translation RETURNS CHARACTER
  ( INPUT p-uniq-key-rec AS character )  FORWARD.
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-chg
     LABEL "&Изменить"
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
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 4 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.
DEFINE BUTTON b-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1.
DEFINE VARIABLE cb-pscript-ruleset AS CHARACTER FORMAT "X(256)":U
     LABEL "Объект-операнд"
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 80.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-script-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 73.5 BY 1 NO-UNDO.
DEFINE VARIABLE mark-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9 BY .67
     FGCOLOR 10  NO-UNDO.
DEFINE VARIABLE rs-find AS CHARACTER INITIAL "begins"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Нач.назв.", "begins",
"Нач.слова", "contains"
     SIZE 23 BY 1 NO-UNDO.
DEFINE VARIABLE rs-language AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2"
     SIZE 24 BY 1 NO-UNDO.
DEFINE QUERY br-pscript-ruleset FOR
      X_pscript-ruleset,
      X_prop-script,
      X_prop-head SCROLLING.
DEFINE BROWSE br-pscript-ruleset
  QUERY br-pscript-ruleset NO-LOCK DISPLAY
      mark-string(recid(X_pscript-ruleset), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
X_pscript-ruleset.codex_id COLUMN-LABEL "Кодекс!правил" FORMAT ">>>>>>>>9"
X_pscript-ruleset.ruleset_id COLUMN-LABEL "Набор!правил" FORMAT ">>>>>>>>9"
X_pscript-ruleset.dtm-code COLUMN-LABEL "Код!объекта" FORMAT ">>>>>>>>9"
X_pscript-ruleset.revis_id COLUMN-LABEL "Версия" FORMAT ">>>>>>9"
X_pscript-ruleset.script-name COLUMN-LABEL "Имя скрипта" format "X(255)"
      width 45
get-translation(X_prop-script.uniq-key-rec) COLUMN-LABEL "Перевод" FORMAT "X(255)":U
        WIDTH 40
X_prop-head.prop-name COLUMN-LABEL "Имя объекта" format "X(32)"
X_prop-head.prop-label COLUMN-LABEL "Лейбл объекта" format "X(255)"
    width 45
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 17.53 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 24 WIDGET-ID 12
     b-sel AT ROW 1 COL 28 WIDGET-ID 10
     b-add AT ROW 1 COL 38 WIDGET-ID 2
     b-chg AT ROW 1 COL 48 WIDGET-ID 4
     b-del AT ROW 1 COL 58 WIDGET-ID 8
     b-lkp AT ROW 1 COL 68 WIDGET-ID 6
     b-sch AT ROW 1 COL 92 WIDGET-ID 48
     B-Help AT ROW 1 COL 95
     rs-language AT ROW 2 COL 21 NO-LABEL WIDGET-ID 52
     cb-pscript-ruleset AT ROW 3 COL 2 WIDGET-ID 46
     rs-find AT ROW 4 COL 1.5 NO-LABEL WIDGET-ID 56
     f-script-name AT ROW 4 COL 23 COLON-ALIGNED NO-LABEL WIDGET-ID 50
     br-pscript-ruleset AT ROW 5 COL 1.5 WIDGET-ID 100
     mark-num AT ROW 1 COL 13 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     SPACE(74.50) SKIP(21.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Привязка скриптов объектов-операндов к наборам правил"
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
  run proc-b-add-chg in this-procedure ( input yes) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
  define variable v-rec as recid no-undo.
  define variable glog as logical no-undo.
  if not available X_pscript-ruleset then return no-apply.
  v-rec = recid(X_pscript-ruleset).
  message "Вы уверены, что хотите удалить привязку скрипта к набору правил?"
  view-as alert-box question buttons yes-no  update glog.
  if not glog then return no-apply.
  run rul/pscript-ruleset3.p ( input no
                               ,input v-rec
                                ) no-error.
  if error-status:error then return no-apply.
  Run Openbr in this-procedure ( input yes, input no, input '':U).
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
  define variable v-rec as recid no-undo.
  if not available X_pscript-ruleset then return no-apply.
  v-rec = recid(X_pscript-ruleset).
  run rul/prop-script-i.w ( input parparentproc
                       ,input 'ПРОСМОТР':U
                       ,input X_pscript-ruleset.dtm-code
                       ,input X_pscript-ruleset.language
                       ,input X_pscript-ruleset.script-name
                       ,input X_pscript-ruleset.revis_id
                       ,input-output v-rec) no-error.
END.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
DO:
    define variable glog as logical no-undo .
  if available X_pscript-ruleset then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid8 as character no-undo .
define variable v-num-entry8 as integer   no-undo .
assign
  v-str-recid8 = trim( string( recid( X_pscript-ruleset ) , "->>>>>>>>>>>9":U ) )
  v-num-entry8 = lookup( v-str-recid8 , v-rid-list )
.
if v-num-entry8 > 0 then do:
  assign
    entry( v-num-entry8, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid8
  .
end.
  glog = br-pscript-ruleset:refresh() .
  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-pscript-ruleset:select-next-row ().
      apply "VALUE-CHANGED" to br-pscript-ruleset in frame Dialog-Frame.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame Dialog-Frame.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame Dialog-Frame.
end.
apply "entry" to br-pscript-ruleset in frame Dialog-Frame.
END.
ON CHOOSE OF b-sch IN FRAME Dialog-Frame
DO:
  RUN proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
DO:
  if available X_pscript-ruleset then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_pscript-ruleset ) ) .
  end.
END.
ON VALUE-CHANGED OF cb-pscript-ruleset IN FRAME Dialog-Frame
DO:
  ASSIGN cb-pscript-ruleset.
  RUN Openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
END.
ON CTRL-J OF f-script-name IN FRAME Dialog-Frame
DO:
    run proc-find-script-name in this-procedure ( input YES
                                                 ,input frame Dialog-Frame f-script-name
                                                 ,INPUT rs-find) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF f-script-name IN FRAME Dialog-Frame
DO:
  run proc-find-script-name in this-procedure ( input NO
                                              , input frame Dialog-Frame f-script-name
                                              , INPUT rs-find) no-error.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF rs-find IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-find.
  apply "ENTRY" to f-script-name.
END.
ON VALUE-CHANGED OF rs-language IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-language.
  CASE rs-language:
    WHEN "ABL" THEN DO:
      X_pscript-ruleset.script-name:VISIBLE IN browse br-pscript-ruleset = YES.
    END.
    WHEN "rus" THEN DO:
      X_pscript-ruleset.script-name:VISIBLE IN browse br-pscript-ruleset = NO.
    END.
  END CASE.
END.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
   v-doc-rec = recid(X_pscript-ruleset).    RUn OpenBR in this-procedure ( input yes, input no, input '':U).  REPOSITION br-pscript-ruleset to recid v-doc-rec No-ERROR.   apply 'value-changed' to br-pscript-ruleset.
    apply "VALUE-CHANGED" to br-pscript-ruleset.
end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse br-pscript-ruleset :handle
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  v-rid-list = p-rid-list.
  run Myenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY rs-language cb-pscript-ruleset rs-find f-script-name mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel b-add b-chg b-del b-lkp b-sch B-Help rs-language
         cb-pscript-ruleset rs-find f-script-name br-pscript-ruleset mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-pscript-ruleset FOR EACH X_pscript-ruleset NO-LOCK,        FIRST X_prop-script no-lock,        FIRST X_prop-head NO-LOCK.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-dtm-label AS CHARACTER no-undo.
DEFINE VARIABLE v-h AS handle NO-UNDO.
DEFINE BUFFER buf_prop-ruleset FOR ub.prop-ruleset.
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
ASSIGN
v-h = br-pscript-ruleset:FIRST-COLUMN IN FRAME Dialog-Frame
cb-pscript-ruleset:DELIMITER in FRAME Dialog-Frame = "|"
cb-pscript-ruleset:LIST-ITEM-PAIRS  = "|-1":U
rs-language:RADIO-BUTTONS IN FRAME Dialog-Frame = "ABL" + chr(44) + "ABL" + chr(44) +
                                                 "rus" + chr(44) + "rus"
rs-find = "contains"
.
DO while valid-handle(v-h) :
  if v-h:LABEL = "Перевод" then do:
    v-h:RESIZABLE = YES.
    leave.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.
if not (p-list-mode = "dtm-code" or p-list-mode = "script-name") then do:
  _prop-ruleset:
  FOR EACH buf_prop-ruleset NO-LOCK WHERE
          buf_prop-ruleset.codex_id = p-codex-id
  BREAK BY buf_prop-ruleset.dtm-code:
    IF first-of(buf_prop-ruleset.dtm-CODE) THEN DO:
      FIND FIRST buf_prop-head NO-LOCK WHERE
                  buf_prop-head.dtm-code = buf_prop-ruleset.dtm-code NO-ERROR.
      IF NOT AVAILABLE buf_prop-head THEN DO:
          NEXT _prop-ruleset.
      END.
      v-dtm-label = replace(buf_prop-head.prop-label, "|", chr(32)).
      cb-pscript-ruleset:ADD-LAST(v-dtm-label, string(buf_prop-ruleset.dtm-code)) IN FRAME Dialog-Frame.
    END.
  END.
  ASSIGN
  cb-pscript-ruleset = "-1".
end.
assign
X_prop-head.prop-name :resizable in browse br-pscript-ruleset = yes
X_prop-head.prop-label:resizable in browse br-pscript-ruleset = yes
X_pscript-ruleset.script-name:resizable in browse br-pscript-ruleset = yes.
ENABLE
b-quit
b-add when ((p-list-mode = "ruleset"
             or p-list-mode = "dtm-code"
             or p-list-mode = "script-name"
             ) and v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-del when (v-cntxt-db-num = 0  and lookup("b-add", bttns) > 0)
b-lkp
B-Help
b-sch
b-mark when lookup("b-mark", bttns) > 0
b-sel when lookup("b-sel", bttns) > 0
br-pscript-ruleset
cb-pscript-ruleset when not (p-list-mode = "dtm-code" or p-list-mode = "script-name")
f-script-name
rs-find
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
if (p-list-mode = "dtm-code" or p-list-mode = "script-name") then do:
  hide
  cb-pscript-ruleset
  in frame Dialog-Frame .
end.
if (p-list-mode = "script-name") then do:
  hide
  f-script-name
  in frame Dialog-Frame .
end.
run Openbr in this-procedure ( input yes, input no, input '':U).
END PROCEDURE.
PROCEDURE Openbr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ("Ждите...").
define variable sort-column-phrase as character no-undo .
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
define variable l-open-query as logical   no-undo .
filter-point = filter-point0 + p-list-mode.
CASE p-list-mode :
  WHEN 'все':U        THEN DO:
    if cb-pscript-ruleset = string(-1) then do:
      assign
      filter-point-label = substitute("Все связи СКРИПТ-НАБОРЫ ПРАВИЛ")
      .
      if p-open-query then do:
        frame Dialog-Frame:title = filter-point-label
        .
      end.
      IF p-word-script-name = '':U THEN DO:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-16  as logical   no-undo .
define variable  l-filter-open-16    as logical   .
define variable  flt-rec-16       as recid     no-undo .
define variable  filter-name-16      as character no-undo .
define variable  where-phrase-16     as character no-undo .
define variable  sort-phrase-16      as character no-undo .
define variable  where-phrase-rus-16 as character no-undo .
define variable  sort-phrase-rus-16  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-16
  ,output filter-name-16
  ,output where-phrase-16
  ,output sort-phrase-16
  ,output where-phrase-rus-16
  ,output sort-phrase-rus-16
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-16
      ) no-error .
  assign
    l-filter-open-16 = false
  .
  if flt-rec-16 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-16 as character no-undo .
    define variable  parameter-3-16 as character no-undo .
    define variable  parameter-4-16 as character no-undo .
    define variable  parameter-5-16 as character no-undo .
    define variable  parameter-6-16 as character no-undo .
    define variable  parameter-7-16 as character no-undo .
      assign
      parameter-3-16 =
                              "FOR EACH X_pscript-ruleset"
      parameter-4-16 =
        (
          if (" true " + " " + where-phrase-16) <> ""
          then " true " + " " + where-phrase-16
          else "true"
        )
      parameter-5-16 = (" " + "" + " " + ", FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code")
      parameter-6-16 = if sort-phrase-16 = ''
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
        " " + sort-phrase-16
        )
      parameter-7-16 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-16 =
          (" true " + " " + where-phrase-16 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input parameter-3-16
                          ,input parameter-4-16
                          ,input parameter-5-16
                          ,input parameter-6-16
                          ,input parameter-7-16
                          )
      .
      assign
        l-filter-open-16 = true
      .
    end.
    if l-filter-open-16 = false then do:
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
  if l-filter-open-16 = false then do:
    OPEN QUERY br-pscript-ruleset FOR EACH X_pscript-ruleset
      where  true
    , FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_pscript-ruleset )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-pscript-ruleset:handle:get-buffer-handle(1) = (buffer X_pscript-ruleset:handle) then do:
      assign
      parameter-2-16 = (if p-find-next then "true":u else "false":u )
      parameter-4-16 =
        "where ":u + " true " + " ":u + where-phrase-16 + " ":u + p-find-condition + " " + ""
      parameter-5-16 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input rowid(X_pscript-ruleset)
                          ,input logical(parameter-2-16)
                          ,input no-lock
                          ,input (buffer X_pscript-ruleset:handle)
                          ,input parameter-4-16
                          ,input parameter-5-16
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-16 = (if p-find-next then "true":u else "false":u )
      parameter-3-16 =  "FOR EACH X_pscript-ruleset"
      parameter-4-16 =
        (
          if (" true " + " " + where-phrase-16) <> ""
          then " true " + " " + where-phrase-16
          else "true"
        )
      parameter-5-16 = (" " + "" + " " + ", FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code" + " " + p-find-condition)
      parameter-6-16 = if sort-phrase-16 = ''
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
        " " + sort-phrase-16
        )
      parameter-7-16 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input logical(parameter-2-16)
                          ,input no-lock
                          ,input parameter-3-16
                          ,input parameter-4-16
                          ,input parameter-5-16
                          ,input parameter-6-16
                          ,input parameter-7-16
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
      END.
      ELSE DO:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-18  as logical   no-undo .
define variable  l-filter-open-18    as logical   .
define variable  flt-rec-18       as recid     no-undo .
define variable  filter-name-18      as character no-undo .
define variable  where-phrase-18     as character no-undo .
define variable  sort-phrase-18      as character no-undo .
define variable  where-phrase-rus-18 as character no-undo .
define variable  sort-phrase-rus-18  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-18
  ,output filter-name-18
  ,output where-phrase-18
  ,output sort-phrase-18
  ,output where-phrase-rus-18
  ,output sort-phrase-rus-18
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-18
      ) no-error .
  assign
    l-filter-open-18 = false
  .
  if flt-rec-18 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-18 as character no-undo .
    define variable  parameter-3-18 as character no-undo .
    define variable  parameter-4-18 as character no-undo .
    define variable  parameter-5-18 as character no-undo .
    define variable  parameter-6-18 as character no-undo .
    define variable  parameter-7-18 as character no-undo .
      assign
      parameter-3-18 =
                              "FOR EACH X_pscript-ruleset"
      parameter-4-18 =
        (
          if (" X_pscript-ruleset.script-name contains p-word-script-name " + " " + where-phrase-18) <> ""
          then  substitute('X_pscript-ruleset.script-name contains &1&2&1', chr(34), p-word-script-name ) + " " + where-phrase-18
          else "true"
        )
      parameter-5-18 = (" " + "" + " " + ", FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code")
      parameter-6-18 = if sort-phrase-18 = ''
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
        " " + sort-phrase-18
        )
      parameter-7-18 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-18 =
          (" X_pscript-ruleset.script-name contains p-word-script-name " + " " + where-phrase-18 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input parameter-3-18
                          ,input parameter-4-18
                          ,input parameter-5-18
                          ,input parameter-6-18
                          ,input parameter-7-18
                          )
      .
      assign
        l-filter-open-18 = true
      .
    end.
    if l-filter-open-18 = false then do:
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
  if l-filter-open-18 = false then do:
    OPEN QUERY br-pscript-ruleset FOR EACH X_pscript-ruleset
      where  X_pscript-ruleset.script-name contains p-word-script-name
    , FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_pscript-ruleset )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-pscript-ruleset:handle:get-buffer-handle(1) = (buffer X_pscript-ruleset:handle) then do:
      assign
      parameter-2-18 = (if p-find-next then "true":u else "false":u )
      parameter-4-18 =
        "where ":u +  substitute('X_pscript-ruleset.script-name contains &1&2&1', chr(34), p-word-script-name ) + " ":u + where-phrase-18 + " ":u + p-find-condition + " " + ""
      parameter-5-18 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input rowid(X_pscript-ruleset)
                          ,input logical(parameter-2-18)
                          ,input no-lock
                          ,input (buffer X_pscript-ruleset:handle)
                          ,input parameter-4-18
                          ,input parameter-5-18
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-18 = (if p-find-next then "true":u else "false":u )
      parameter-3-18 =  "FOR EACH X_pscript-ruleset"
      parameter-4-18 =
        (
          if (" X_pscript-ruleset.script-name contains p-word-script-name " + " " + where-phrase-18) <> ""
          then  substitute('X_pscript-ruleset.script-name contains &1&2&1', chr(34), p-word-script-name ) + " " + where-phrase-18
          else "true"
        )
      parameter-5-18 = (" " + "" + " " + ", FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code" + " " + p-find-condition)
      parameter-6-18 = if sort-phrase-18 = ''
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
        " " + sort-phrase-18
        )
      parameter-7-18 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input logical(parameter-2-18)
                          ,input no-lock
                          ,input parameter-3-18
                          ,input parameter-4-18
                          ,input parameter-5-18
                          ,input parameter-6-18
                          ,input parameter-7-18
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
      END.
    end.
    else do:
      assign
      filter-point-label =  substitute("Все связи СКРИПТ-НАБОРЫ ПРАВИЛ - с кодом объекта-операнда &1", cb-pscript-ruleset)
      .
      if p-open-query then do:
        frame Dialog-Frame:title = filter-point-label
        .
      end.
      IF p-word-script-name = '':U THEN DO:
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
if p-open-query then do:
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
                              "FOR EACH X_pscript-ruleset"
      parameter-4-20 =
        (
          if (" X_pscript-ruleset.dtm-code =    integer(cb-pscript-ruleset) " + " " + where-phrase-20) <> ""
          then  substitute('X_pscript-ruleset.dtm-code = integer(&1&2&1) ', chr(34), cb-pscript-ruleset) + " " + where-phrase-20
          else "true"
        )
      parameter-5-20 = (" " + "" + " " + ", FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code")
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
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-20 =
          (" X_pscript-ruleset.dtm-code =    integer(cb-pscript-ruleset) " + " " + where-phrase-20 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
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
    OPEN QUERY br-pscript-ruleset FOR EACH X_pscript-ruleset
      where  X_pscript-ruleset.dtm-code =    integer(cb-pscript-ruleset)
    , FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_pscript-ruleset )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-pscript-ruleset:handle:get-buffer-handle(1) = (buffer X_pscript-ruleset:handle) then do:
      assign
      parameter-2-20 = (if p-find-next then "true":u else "false":u )
      parameter-4-20 =
        "where ":u +  substitute('X_pscript-ruleset.dtm-code = integer(&1&2&1) ', chr(34), cb-pscript-ruleset) + " ":u + where-phrase-20 + " ":u + p-find-condition + " " + ""
      parameter-5-20 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input rowid(X_pscript-ruleset)
                          ,input logical(parameter-2-20)
                          ,input no-lock
                          ,input (buffer X_pscript-ruleset:handle)
                          ,input parameter-4-20
                          ,input parameter-5-20
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-20 = (if p-find-next then "true":u else "false":u )
      parameter-3-20 =  "FOR EACH X_pscript-ruleset"
      parameter-4-20 =
        (
          if (" X_pscript-ruleset.dtm-code =    integer(cb-pscript-ruleset) " + " " + where-phrase-20) <> ""
          then  substitute('X_pscript-ruleset.dtm-code = integer(&1&2&1) ', chr(34), cb-pscript-ruleset) + " " + where-phrase-20
          else "true"
        )
      parameter-5-20 = (" " + "" + " " + ", FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code" + " " + p-find-condition)
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
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input logical(parameter-2-20)
                          ,input no-lock
                          ,input parameter-3-20
                          ,input parameter-4-20
                          ,input parameter-5-20
                          ,input parameter-6-20
                          ,input parameter-7-20
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
      END.
      ELSE DO:
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
if p-open-query then do:
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
                              "FOR EACH X_pscript-ruleset"
      parameter-4-22 =
        (
          if (" X_pscript-ruleset.dtm-code = integer(cb-pscript-ruleset)                           and X_pscript-ruleset.script-name contains p-word-script-name " + " " + where-phrase-22) <> ""
          then  substitute('X_pscript-ruleset.dtm-code = integer(&1&2&1)                           and X_pscript-ruleset.script-name contains &1&3&1 ', chr(34), cb-pscript-ruleset, p-word-script-name) + " " + where-phrase-22
          else "true"
        )
      parameter-5-22 = (" " + "" + " " + ", FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code")
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
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-22 =
          (" X_pscript-ruleset.dtm-code = integer(cb-pscript-ruleset)                           and X_pscript-ruleset.script-name contains p-word-script-name " + " " + where-phrase-22 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
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
    OPEN QUERY br-pscript-ruleset FOR EACH X_pscript-ruleset
      where  X_pscript-ruleset.dtm-code = integer(cb-pscript-ruleset)                           and X_pscript-ruleset.script-name contains p-word-script-name
    , FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_pscript-ruleset )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-pscript-ruleset:handle:get-buffer-handle(1) = (buffer X_pscript-ruleset:handle) then do:
      assign
      parameter-2-22 = (if p-find-next then "true":u else "false":u )
      parameter-4-22 =
        "where ":u +  substitute('X_pscript-ruleset.dtm-code = integer(&1&2&1)                           and X_pscript-ruleset.script-name contains &1&3&1 ', chr(34), cb-pscript-ruleset, p-word-script-name) + " ":u + where-phrase-22 + " ":u + p-find-condition + " " + ""
      parameter-5-22 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input rowid(X_pscript-ruleset)
                          ,input logical(parameter-2-22)
                          ,input no-lock
                          ,input (buffer X_pscript-ruleset:handle)
                          ,input parameter-4-22
                          ,input parameter-5-22
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-22 = (if p-find-next then "true":u else "false":u )
      parameter-3-22 =  "FOR EACH X_pscript-ruleset"
      parameter-4-22 =
        (
          if (" X_pscript-ruleset.dtm-code = integer(cb-pscript-ruleset)                           and X_pscript-ruleset.script-name contains p-word-script-name " + " " + where-phrase-22) <> ""
          then  substitute('X_pscript-ruleset.dtm-code = integer(&1&2&1)                           and X_pscript-ruleset.script-name contains &1&3&1 ', chr(34), cb-pscript-ruleset, p-word-script-name) + " " + where-phrase-22
          else "true"
        )
      parameter-5-22 = (" " + "" + " " + ", FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code" + " " + p-find-condition)
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
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input logical(parameter-2-22)
                          ,input no-lock
                          ,input parameter-3-22
                          ,input parameter-4-22
                          ,input parameter-5-22
                          ,input parameter-6-22
                          ,input parameter-7-22
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
      END.
    end.
  END.
  WHEN "ruleset"       THEN DO:
    if cb-pscript-ruleset = string(-1) then do:
      assign
      filter-point-label = substitute("Скрипты для кодекса &1, набора правил &2"
                                            , p-codex-id
                                            , p-ruleset-id
                                            )
      .
      if p-open-query then do:
        frame Dialog-Frame:title = filter-point-label
        .
      end.
      IF p-word-script-name = '':U THEN DO:
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
if p-open-query then do:
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
                              "FOR EACH X_pscript-ruleset"
      parameter-4-24 =
        (
          if (" X_pscript-ruleset.codex_id = p-codex-id                     AND X_pscript-ruleset.ruleset_id = p-ruleset-id                         " + " " + where-phrase-24) <> ""
          then  substitute('X_pscript-ruleset.codex_id = &1                     AND X_pscript-ruleset.ruleset_id = &2 ', p-codex-id, p-ruleset-id)   + " " + where-phrase-24
          else "true"
        )
      parameter-5-24 = (" " + "" + " " + ", FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code")
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
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-24 =
          (" X_pscript-ruleset.codex_id = p-codex-id                     AND X_pscript-ruleset.ruleset_id = p-ruleset-id                         " + " " + where-phrase-24 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
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
    OPEN QUERY br-pscript-ruleset FOR EACH X_pscript-ruleset
      where  X_pscript-ruleset.codex_id = p-codex-id                     AND X_pscript-ruleset.ruleset_id = p-ruleset-id
    , FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_pscript-ruleset )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-pscript-ruleset:handle:get-buffer-handle(1) = (buffer X_pscript-ruleset:handle) then do:
      assign
      parameter-2-24 = (if p-find-next then "true":u else "false":u )
      parameter-4-24 =
        "where ":u +  substitute('X_pscript-ruleset.codex_id = &1                     AND X_pscript-ruleset.ruleset_id = &2 ', p-codex-id, p-ruleset-id)   + " ":u + where-phrase-24 + " ":u + p-find-condition + " " + ""
      parameter-5-24 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input rowid(X_pscript-ruleset)
                          ,input logical(parameter-2-24)
                          ,input no-lock
                          ,input (buffer X_pscript-ruleset:handle)
                          ,input parameter-4-24
                          ,input parameter-5-24
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-24 = (if p-find-next then "true":u else "false":u )
      parameter-3-24 =  "FOR EACH X_pscript-ruleset"
      parameter-4-24 =
        (
          if (" X_pscript-ruleset.codex_id = p-codex-id                     AND X_pscript-ruleset.ruleset_id = p-ruleset-id                         " + " " + where-phrase-24) <> ""
          then  substitute('X_pscript-ruleset.codex_id = &1                     AND X_pscript-ruleset.ruleset_id = &2 ', p-codex-id, p-ruleset-id)   + " " + where-phrase-24
          else "true"
        )
      parameter-5-24 = (" " + "" + " " + ", FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code" + " " + p-find-condition)
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
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input logical(parameter-2-24)
                          ,input no-lock
                          ,input parameter-3-24
                          ,input parameter-4-24
                          ,input parameter-5-24
                          ,input parameter-6-24
                          ,input parameter-7-24
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
      END.
      ELSE DO:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-26  as logical   no-undo .
define variable  l-filter-open-26    as logical   .
define variable  flt-rec-26       as recid     no-undo .
define variable  filter-name-26      as character no-undo .
define variable  where-phrase-26     as character no-undo .
define variable  sort-phrase-26      as character no-undo .
define variable  where-phrase-rus-26 as character no-undo .
define variable  sort-phrase-rus-26  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-26
  ,output filter-name-26
  ,output where-phrase-26
  ,output sort-phrase-26
  ,output where-phrase-rus-26
  ,output sort-phrase-rus-26
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-26
      ) no-error .
  assign
    l-filter-open-26 = false
  .
  if flt-rec-26 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-26 as character no-undo .
    define variable  parameter-3-26 as character no-undo .
    define variable  parameter-4-26 as character no-undo .
    define variable  parameter-5-26 as character no-undo .
    define variable  parameter-6-26 as character no-undo .
    define variable  parameter-7-26 as character no-undo .
      assign
      parameter-3-26 =
                              "FOR EACH X_pscript-ruleset"
      parameter-4-26 =
        (
          if (" X_pscript-ruleset.codex_id = p-codex-id                         AND X_pscript-ruleset.ruleset_id = p-ruleset-id                         and X_pscript-ruleset.script-name contains p-word-script-name                             " + " " + where-phrase-26) <> ""
          then  substitute('X_pscript-ruleset.codex_id = &1                         AND X_pscript-ruleset.ruleset_id = &2                         and X_pscript-ruleset.script-name contains &3&4&3 ', p-codex-id, p-ruleset-id, chr(34), p-word-script-name)  + " " + where-phrase-26
          else "true"
        )
      parameter-5-26 = (" " + "" + " " + ", FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code")
      parameter-6-26 = if sort-phrase-26 = ''
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
        " " + sort-phrase-26
        )
      parameter-7-26 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-26 =
          (" X_pscript-ruleset.codex_id = p-codex-id                         AND X_pscript-ruleset.ruleset_id = p-ruleset-id                         and X_pscript-ruleset.script-name contains p-word-script-name                             " + " " + where-phrase-26 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input parameter-3-26
                          ,input parameter-4-26
                          ,input parameter-5-26
                          ,input parameter-6-26
                          ,input parameter-7-26
                          )
      .
      assign
        l-filter-open-26 = true
      .
    end.
    if l-filter-open-26 = false then do:
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
  if l-filter-open-26 = false then do:
    OPEN QUERY br-pscript-ruleset FOR EACH X_pscript-ruleset
      where  X_pscript-ruleset.codex_id = p-codex-id                         AND X_pscript-ruleset.ruleset_id = p-ruleset-id                         and X_pscript-ruleset.script-name contains p-word-script-name
    , FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_pscript-ruleset )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-pscript-ruleset:handle:get-buffer-handle(1) = (buffer X_pscript-ruleset:handle) then do:
      assign
      parameter-2-26 = (if p-find-next then "true":u else "false":u )
      parameter-4-26 =
        "where ":u +  substitute('X_pscript-ruleset.codex_id = &1                         AND X_pscript-ruleset.ruleset_id = &2                         and X_pscript-ruleset.script-name contains &3&4&3 ', p-codex-id, p-ruleset-id, chr(34), p-word-script-name)  + " ":u + where-phrase-26 + " ":u + p-find-condition + " " + ""
      parameter-5-26 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input rowid(X_pscript-ruleset)
                          ,input logical(parameter-2-26)
                          ,input no-lock
                          ,input (buffer X_pscript-ruleset:handle)
                          ,input parameter-4-26
                          ,input parameter-5-26
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-26 = (if p-find-next then "true":u else "false":u )
      parameter-3-26 =  "FOR EACH X_pscript-ruleset"
      parameter-4-26 =
        (
          if (" X_pscript-ruleset.codex_id = p-codex-id                         AND X_pscript-ruleset.ruleset_id = p-ruleset-id                         and X_pscript-ruleset.script-name contains p-word-script-name                             " + " " + where-phrase-26) <> ""
          then  substitute('X_pscript-ruleset.codex_id = &1                         AND X_pscript-ruleset.ruleset_id = &2                         and X_pscript-ruleset.script-name contains &3&4&3 ', p-codex-id, p-ruleset-id, chr(34), p-word-script-name)  + " " + where-phrase-26
          else "true"
        )
      parameter-5-26 = (" " + "" + " " + ", FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code" + " " + p-find-condition)
      parameter-6-26 = if sort-phrase-26 = ''
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
        " " + sort-phrase-26
        )
      parameter-7-26 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input logical(parameter-2-26)
                          ,input no-lock
                          ,input parameter-3-26
                          ,input parameter-4-26
                          ,input parameter-5-26
                          ,input parameter-6-26
                          ,input parameter-7-26
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
      END.
    end.
    else do:
      assign
      filter-point-label = substitute("Скрипты для кодекса &1, набора правил &2 - с кодом объекта-операнда &3"
                                            , p-codex-id
                                            , p-ruleset-id
                                            ,cb-pscript-ruleset
                                            ).
      if p-open-query then do:
        frame Dialog-Frame:title = filter-point-label
        .
      end.
      IF p-word-script-name = '':U THEN DO:
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-28  as logical   no-undo .
define variable  l-filter-open-28    as logical   .
define variable  flt-rec-28       as recid     no-undo .
define variable  filter-name-28      as character no-undo .
define variable  where-phrase-28     as character no-undo .
define variable  sort-phrase-28      as character no-undo .
define variable  where-phrase-rus-28 as character no-undo .
define variable  sort-phrase-rus-28  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-28
  ,output filter-name-28
  ,output where-phrase-28
  ,output sort-phrase-28
  ,output where-phrase-rus-28
  ,output sort-phrase-rus-28
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-28
      ) no-error .
  assign
    l-filter-open-28 = false
  .
  if flt-rec-28 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-28 as character no-undo .
    define variable  parameter-3-28 as character no-undo .
    define variable  parameter-4-28 as character no-undo .
    define variable  parameter-5-28 as character no-undo .
    define variable  parameter-6-28 as character no-undo .
    define variable  parameter-7-28 as character no-undo .
      assign
      parameter-3-28 =
                              "FOR EACH X_pscript-ruleset"
      parameter-4-28 =
        (
          if (" X_pscript-ruleset.codex_id = p-codex-id                     AND X_pscript-ruleset.ruleset_id = p-ruleset-id                     AND X_pscript-ruleset.dtm-code = integer(cb-pscript-ruleset)                         " + " " + where-phrase-28) <> ""
          then  substitute('X_pscript-ruleset.codex_id = &1                     AND X_pscript-ruleset.ruleset_id = &2                     AND X_pscript-ruleset.dtm-code = integer(&3&4&3) ', p-codex-id, p-ruleset-id, chr(34), cb-pscript-ruleset)  + " " + where-phrase-28
          else "true"
        )
      parameter-5-28 = (" " + "" + " " + ", FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code")
      parameter-6-28 = if sort-phrase-28 = ''
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
        " " + sort-phrase-28
        )
      parameter-7-28 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-28 =
          (" X_pscript-ruleset.codex_id = p-codex-id                     AND X_pscript-ruleset.ruleset_id = p-ruleset-id                     AND X_pscript-ruleset.dtm-code = integer(cb-pscript-ruleset)                         " + " " + where-phrase-28 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input parameter-3-28
                          ,input parameter-4-28
                          ,input parameter-5-28
                          ,input parameter-6-28
                          ,input parameter-7-28
                          )
      .
      assign
        l-filter-open-28 = true
      .
    end.
    if l-filter-open-28 = false then do:
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
  if l-filter-open-28 = false then do:
    OPEN QUERY br-pscript-ruleset FOR EACH X_pscript-ruleset
      where  X_pscript-ruleset.codex_id = p-codex-id                     AND X_pscript-ruleset.ruleset_id = p-ruleset-id                     AND X_pscript-ruleset.dtm-code = integer(cb-pscript-ruleset)
    , FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_pscript-ruleset )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-pscript-ruleset:handle:get-buffer-handle(1) = (buffer X_pscript-ruleset:handle) then do:
      assign
      parameter-2-28 = (if p-find-next then "true":u else "false":u )
      parameter-4-28 =
        "where ":u +  substitute('X_pscript-ruleset.codex_id = &1                     AND X_pscript-ruleset.ruleset_id = &2                     AND X_pscript-ruleset.dtm-code = integer(&3&4&3) ', p-codex-id, p-ruleset-id, chr(34), cb-pscript-ruleset)  + " ":u + where-phrase-28 + " ":u + p-find-condition + " " + ""
      parameter-5-28 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input rowid(X_pscript-ruleset)
                          ,input logical(parameter-2-28)
                          ,input no-lock
                          ,input (buffer X_pscript-ruleset:handle)
                          ,input parameter-4-28
                          ,input parameter-5-28
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-28 = (if p-find-next then "true":u else "false":u )
      parameter-3-28 =  "FOR EACH X_pscript-ruleset"
      parameter-4-28 =
        (
          if (" X_pscript-ruleset.codex_id = p-codex-id                     AND X_pscript-ruleset.ruleset_id = p-ruleset-id                     AND X_pscript-ruleset.dtm-code = integer(cb-pscript-ruleset)                         " + " " + where-phrase-28) <> ""
          then  substitute('X_pscript-ruleset.codex_id = &1                     AND X_pscript-ruleset.ruleset_id = &2                     AND X_pscript-ruleset.dtm-code = integer(&3&4&3) ', p-codex-id, p-ruleset-id, chr(34), cb-pscript-ruleset)  + " " + where-phrase-28
          else "true"
        )
      parameter-5-28 = (" " + "" + " " + ", FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code" + " " + p-find-condition)
      parameter-6-28 = if sort-phrase-28 = ''
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
        " " + sort-phrase-28
        )
      parameter-7-28 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input logical(parameter-2-28)
                          ,input no-lock
                          ,input parameter-3-28
                          ,input parameter-4-28
                          ,input parameter-5-28
                          ,input parameter-6-28
                          ,input parameter-7-28
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
      END.
      ELSE DO:
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-30  as logical   no-undo .
define variable  l-filter-open-30    as logical   .
define variable  flt-rec-30       as recid     no-undo .
define variable  filter-name-30      as character no-undo .
define variable  where-phrase-30     as character no-undo .
define variable  sort-phrase-30      as character no-undo .
define variable  where-phrase-rus-30 as character no-undo .
define variable  sort-phrase-rus-30  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-30
  ,output filter-name-30
  ,output where-phrase-30
  ,output sort-phrase-30
  ,output where-phrase-rus-30
  ,output sort-phrase-rus-30
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-30
      ) no-error .
  assign
    l-filter-open-30 = false
  .
  if flt-rec-30 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-30 as character no-undo .
    define variable  parameter-3-30 as character no-undo .
    define variable  parameter-4-30 as character no-undo .
    define variable  parameter-5-30 as character no-undo .
    define variable  parameter-6-30 as character no-undo .
    define variable  parameter-7-30 as character no-undo .
      assign
      parameter-3-30 =
                              "FOR EACH X_pscript-ruleset"
      parameter-4-30 =
        (
          if (" X_pscript-ruleset.codex_id = p-codex-id               AND X_pscript-ruleset.ruleset_id = p-ruleset-id               AND X_pscript-ruleset.dtm-code = integer(cb-pscript-ruleset)            and X_pscript-ruleset.script-name contains p-word-script-name                   " + " " + where-phrase-30) <> ""
          then  substitute('X_pscript-ruleset.codex_id = &1               AND X_pscript-ruleset.ruleset_id = &2               AND X_pscript-ruleset.dtm-code = integer(&3&4&3)            and X_pscript-ruleset.script-name contains &3&5&3 ', p-codex-id, p-ruleset-id, chr(34), cb-pscript-ruleset, p-word-script-name)  + " " + where-phrase-30
          else "true"
        )
      parameter-5-30 = (" " + "" + " " + ", FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code")
      parameter-6-30 = if sort-phrase-30 = ''
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
        " " + sort-phrase-30
        )
      parameter-7-30 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-30 =
          (" X_pscript-ruleset.codex_id = p-codex-id               AND X_pscript-ruleset.ruleset_id = p-ruleset-id               AND X_pscript-ruleset.dtm-code = integer(cb-pscript-ruleset)            and X_pscript-ruleset.script-name contains p-word-script-name                   " + " " + where-phrase-30 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input parameter-3-30
                          ,input parameter-4-30
                          ,input parameter-5-30
                          ,input parameter-6-30
                          ,input parameter-7-30
                          )
      .
      assign
        l-filter-open-30 = true
      .
    end.
    if l-filter-open-30 = false then do:
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
  if l-filter-open-30 = false then do:
    OPEN QUERY br-pscript-ruleset FOR EACH X_pscript-ruleset
      where  X_pscript-ruleset.codex_id = p-codex-id               AND X_pscript-ruleset.ruleset_id = p-ruleset-id               AND X_pscript-ruleset.dtm-code = integer(cb-pscript-ruleset)            and X_pscript-ruleset.script-name contains p-word-script-name
    , FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_pscript-ruleset )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-pscript-ruleset:handle:get-buffer-handle(1) = (buffer X_pscript-ruleset:handle) then do:
      assign
      parameter-2-30 = (if p-find-next then "true":u else "false":u )
      parameter-4-30 =
        "where ":u +  substitute('X_pscript-ruleset.codex_id = &1               AND X_pscript-ruleset.ruleset_id = &2               AND X_pscript-ruleset.dtm-code = integer(&3&4&3)            and X_pscript-ruleset.script-name contains &3&5&3 ', p-codex-id, p-ruleset-id, chr(34), cb-pscript-ruleset, p-word-script-name)  + " ":u + where-phrase-30 + " ":u + p-find-condition + " " + ""
      parameter-5-30 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input rowid(X_pscript-ruleset)
                          ,input logical(parameter-2-30)
                          ,input no-lock
                          ,input (buffer X_pscript-ruleset:handle)
                          ,input parameter-4-30
                          ,input parameter-5-30
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-30 = (if p-find-next then "true":u else "false":u )
      parameter-3-30 =  "FOR EACH X_pscript-ruleset"
      parameter-4-30 =
        (
          if (" X_pscript-ruleset.codex_id = p-codex-id               AND X_pscript-ruleset.ruleset_id = p-ruleset-id               AND X_pscript-ruleset.dtm-code = integer(cb-pscript-ruleset)            and X_pscript-ruleset.script-name contains p-word-script-name                   " + " " + where-phrase-30) <> ""
          then  substitute('X_pscript-ruleset.codex_id = &1               AND X_pscript-ruleset.ruleset_id = &2               AND X_pscript-ruleset.dtm-code = integer(&3&4&3)            and X_pscript-ruleset.script-name contains &3&5&3 ', p-codex-id, p-ruleset-id, chr(34), cb-pscript-ruleset, p-word-script-name)  + " " + where-phrase-30
          else "true"
        )
      parameter-5-30 = (" " + "" + " " + ", FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code" + " " + p-find-condition)
      parameter-6-30 = if sort-phrase-30 = ''
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
        " " + sort-phrase-30
        )
      parameter-7-30 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input logical(parameter-2-30)
                          ,input no-lock
                          ,input parameter-3-30
                          ,input parameter-4-30
                          ,input parameter-5-30
                          ,input parameter-6-30
                          ,input parameter-7-30
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
      END.
    end.
  END.
  WHEN "dtm-code"       THEN DO:
    assign
    filter-point-label = substitute("Связи скриптов объекта &1 с наборами правил", p-dtm-code)
    .
    if p-open-query then do:
      frame Dialog-Frame:title = filter-point-label
      .
    end.
    IF p-word-script-name = '':U THEN DO:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-32  as logical   no-undo .
define variable  l-filter-open-32    as logical   .
define variable  flt-rec-32       as recid     no-undo .
define variable  filter-name-32      as character no-undo .
define variable  where-phrase-32     as character no-undo .
define variable  sort-phrase-32      as character no-undo .
define variable  where-phrase-rus-32 as character no-undo .
define variable  sort-phrase-rus-32  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-32
  ,output filter-name-32
  ,output where-phrase-32
  ,output sort-phrase-32
  ,output where-phrase-rus-32
  ,output sort-phrase-rus-32
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-32
      ) no-error .
  assign
    l-filter-open-32 = false
  .
  if flt-rec-32 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-32 as character no-undo .
    define variable  parameter-3-32 as character no-undo .
    define variable  parameter-4-32 as character no-undo .
    define variable  parameter-5-32 as character no-undo .
    define variable  parameter-6-32 as character no-undo .
    define variable  parameter-7-32 as character no-undo .
      assign
      parameter-3-32 =
                              "FOR EACH X_pscript-ruleset"
      parameter-4-32 =
        (
          if (" X_pscript-ruleset.dtm-code = p-dtm-code                       " + " " + where-phrase-32) <> ""
          then  substitute('X_pscript-ruleset.dtm-code = &1', p-dtm-code ) + " " + where-phrase-32
          else "true"
        )
      parameter-5-32 = (" " + "" + " " + ", FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code")
      parameter-6-32 = if sort-phrase-32 = ''
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
        " " + sort-phrase-32
        )
      parameter-7-32 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-32 =
          (" X_pscript-ruleset.dtm-code = p-dtm-code                       " + " " + where-phrase-32 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input parameter-3-32
                          ,input parameter-4-32
                          ,input parameter-5-32
                          ,input parameter-6-32
                          ,input parameter-7-32
                          )
      .
      assign
        l-filter-open-32 = true
      .
    end.
    if l-filter-open-32 = false then do:
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
  if l-filter-open-32 = false then do:
    OPEN QUERY br-pscript-ruleset FOR EACH X_pscript-ruleset
      where  X_pscript-ruleset.dtm-code = p-dtm-code
    , FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_pscript-ruleset )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-pscript-ruleset:handle:get-buffer-handle(1) = (buffer X_pscript-ruleset:handle) then do:
      assign
      parameter-2-32 = (if p-find-next then "true":u else "false":u )
      parameter-4-32 =
        "where ":u +  substitute('X_pscript-ruleset.dtm-code = &1', p-dtm-code ) + " ":u + where-phrase-32 + " ":u + p-find-condition + " " + ""
      parameter-5-32 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input rowid(X_pscript-ruleset)
                          ,input logical(parameter-2-32)
                          ,input no-lock
                          ,input (buffer X_pscript-ruleset:handle)
                          ,input parameter-4-32
                          ,input parameter-5-32
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-32 = (if p-find-next then "true":u else "false":u )
      parameter-3-32 =  "FOR EACH X_pscript-ruleset"
      parameter-4-32 =
        (
          if (" X_pscript-ruleset.dtm-code = p-dtm-code                       " + " " + where-phrase-32) <> ""
          then  substitute('X_pscript-ruleset.dtm-code = &1', p-dtm-code ) + " " + where-phrase-32
          else "true"
        )
      parameter-5-32 = (" " + "" + " " + ", FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code" + " " + p-find-condition)
      parameter-6-32 = if sort-phrase-32 = ''
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
        " " + sort-phrase-32
        )
      parameter-7-32 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input logical(parameter-2-32)
                          ,input no-lock
                          ,input parameter-3-32
                          ,input parameter-4-32
                          ,input parameter-5-32
                          ,input parameter-6-32
                          ,input parameter-7-32
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
    END.
    ELSE DO:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-34  as logical   no-undo .
define variable  l-filter-open-34    as logical   .
define variable  flt-rec-34       as recid     no-undo .
define variable  filter-name-34      as character no-undo .
define variable  where-phrase-34     as character no-undo .
define variable  sort-phrase-34      as character no-undo .
define variable  where-phrase-rus-34 as character no-undo .
define variable  sort-phrase-rus-34  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-34
  ,output filter-name-34
  ,output where-phrase-34
  ,output sort-phrase-34
  ,output where-phrase-rus-34
  ,output sort-phrase-rus-34
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-34
      ) no-error .
  assign
    l-filter-open-34 = false
  .
  if flt-rec-34 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-34 as character no-undo .
    define variable  parameter-3-34 as character no-undo .
    define variable  parameter-4-34 as character no-undo .
    define variable  parameter-5-34 as character no-undo .
    define variable  parameter-6-34 as character no-undo .
    define variable  parameter-7-34 as character no-undo .
      assign
      parameter-3-34 =
                              "FOR EACH X_pscript-ruleset"
      parameter-4-34 =
        (
          if (" X_pscript-ruleset.dtm-code = p-dtm-code                         and X_pscript-ruleset.script-name contains p-word-script-name                           " + " " + where-phrase-34) <> ""
          then  substitute('X_pscript-ruleset.dtm-code = &1                         and X_pscript-ruleset.script-name contains &2&3&2 ', p-dtm-code, chr(34), p-word-script-name)  + " " + where-phrase-34
          else "true"
        )
      parameter-5-34 = (" " + "" + " " + ", FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code")
      parameter-6-34 = if sort-phrase-34 = ''
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
        " " + sort-phrase-34
        )
      parameter-7-34 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-34 =
          (" X_pscript-ruleset.dtm-code = p-dtm-code                         and X_pscript-ruleset.script-name contains p-word-script-name                           " + " " + where-phrase-34 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input parameter-3-34
                          ,input parameter-4-34
                          ,input parameter-5-34
                          ,input parameter-6-34
                          ,input parameter-7-34
                          )
      .
      assign
        l-filter-open-34 = true
      .
    end.
    if l-filter-open-34 = false then do:
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
  if l-filter-open-34 = false then do:
    OPEN QUERY br-pscript-ruleset FOR EACH X_pscript-ruleset
      where  X_pscript-ruleset.dtm-code = p-dtm-code                         and X_pscript-ruleset.script-name contains p-word-script-name
    , FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_pscript-ruleset )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-pscript-ruleset:handle:get-buffer-handle(1) = (buffer X_pscript-ruleset:handle) then do:
      assign
      parameter-2-34 = (if p-find-next then "true":u else "false":u )
      parameter-4-34 =
        "where ":u +  substitute('X_pscript-ruleset.dtm-code = &1                         and X_pscript-ruleset.script-name contains &2&3&2 ', p-dtm-code, chr(34), p-word-script-name)  + " ":u + where-phrase-34 + " ":u + p-find-condition + " " + ""
      parameter-5-34 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input rowid(X_pscript-ruleset)
                          ,input logical(parameter-2-34)
                          ,input no-lock
                          ,input (buffer X_pscript-ruleset:handle)
                          ,input parameter-4-34
                          ,input parameter-5-34
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-34 = (if p-find-next then "true":u else "false":u )
      parameter-3-34 =  "FOR EACH X_pscript-ruleset"
      parameter-4-34 =
        (
          if (" X_pscript-ruleset.dtm-code = p-dtm-code                         and X_pscript-ruleset.script-name contains p-word-script-name                           " + " " + where-phrase-34) <> ""
          then  substitute('X_pscript-ruleset.dtm-code = &1                         and X_pscript-ruleset.script-name contains &2&3&2 ', p-dtm-code, chr(34), p-word-script-name)  + " " + where-phrase-34
          else "true"
        )
      parameter-5-34 = (" " + "" + " " + ", FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code" + " " + p-find-condition)
      parameter-6-34 = if sort-phrase-34 = ''
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
        " " + sort-phrase-34
        )
      parameter-7-34 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input logical(parameter-2-34)
                          ,input no-lock
                          ,input parameter-3-34
                          ,input parameter-4-34
                          ,input parameter-5-34
                          ,input parameter-6-34
                          ,input parameter-7-34
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
    END.
  END.
  WHEN "script-name"       THEN DO:
    assign
    filter-point-label = substitute("Связи скрипта &1 объекта-операнда &2 с наборами правил"
                                           , p-script-name
                                           , p-dtm-code)
    .
    if p-open-query then do:
      frame Dialog-Frame:title = filter-point-label
      .
    end.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-36  as logical   no-undo .
define variable  l-filter-open-36    as logical   .
define variable  flt-rec-36       as recid     no-undo .
define variable  filter-name-36      as character no-undo .
define variable  where-phrase-36     as character no-undo .
define variable  sort-phrase-36      as character no-undo .
define variable  where-phrase-rus-36 as character no-undo .
define variable  sort-phrase-rus-36  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-36
  ,output filter-name-36
  ,output where-phrase-36
  ,output sort-phrase-36
  ,output where-phrase-rus-36
  ,output sort-phrase-rus-36
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-36
      ) no-error .
  assign
    l-filter-open-36 = false
  .
  if flt-rec-36 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-36 as character no-undo .
    define variable  parameter-3-36 as character no-undo .
    define variable  parameter-4-36 as character no-undo .
    define variable  parameter-5-36 as character no-undo .
    define variable  parameter-6-36 as character no-undo .
    define variable  parameter-7-36 as character no-undo .
      assign
      parameter-3-36 =
                              "FOR EACH X_pscript-ruleset"
      parameter-4-36 =
        (
          if (" X_pscript-ruleset.dtm-code = p-dtm-code                     and X_pscript-ruleset.language = p-language                     and X_pscript-ruleset.script-name = p-script-name                       " + " " + where-phrase-36) <> ""
          then  substitute('X_pscript-ruleset.dtm-code = &1                     and X_pscript-ruleset.language = &2&3&2                     and X_pscript-ruleset.script-name = &2&4&2 ', p-dtm-code, chr(34), p-language, p-script-name )  + " " + where-phrase-36
          else "true"
        )
      parameter-5-36 = (" " + "" + " " + ", FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code")
      parameter-6-36 = if sort-phrase-36 = ''
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
        " " + sort-phrase-36
        )
      parameter-7-36 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-36 =
          (" X_pscript-ruleset.dtm-code = p-dtm-code                     and X_pscript-ruleset.language = p-language                     and X_pscript-ruleset.script-name = p-script-name                       " + " " + where-phrase-36 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input parameter-3-36
                          ,input parameter-4-36
                          ,input parameter-5-36
                          ,input parameter-6-36
                          ,input parameter-7-36
                          )
      .
      assign
        l-filter-open-36 = true
      .
    end.
    if l-filter-open-36 = false then do:
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
  if l-filter-open-36 = false then do:
    OPEN QUERY br-pscript-ruleset FOR EACH X_pscript-ruleset
      where  X_pscript-ruleset.dtm-code = p-dtm-code                     and X_pscript-ruleset.language = p-language                     and X_pscript-ruleset.script-name = p-script-name
    , FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_pscript-ruleset )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-pscript-ruleset:handle:get-buffer-handle(1) = (buffer X_pscript-ruleset:handle) then do:
      assign
      parameter-2-36 = (if p-find-next then "true":u else "false":u )
      parameter-4-36 =
        "where ":u +  substitute('X_pscript-ruleset.dtm-code = &1                     and X_pscript-ruleset.language = &2&3&2                     and X_pscript-ruleset.script-name = &2&4&2 ', p-dtm-code, chr(34), p-language, p-script-name )  + " ":u + where-phrase-36 + " ":u + p-find-condition + " " + ""
      parameter-5-36 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input rowid(X_pscript-ruleset)
                          ,input logical(parameter-2-36)
                          ,input no-lock
                          ,input (buffer X_pscript-ruleset:handle)
                          ,input parameter-4-36
                          ,input parameter-5-36
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-36 = (if p-find-next then "true":u else "false":u )
      parameter-3-36 =  "FOR EACH X_pscript-ruleset"
      parameter-4-36 =
        (
          if (" X_pscript-ruleset.dtm-code = p-dtm-code                     and X_pscript-ruleset.language = p-language                     and X_pscript-ruleset.script-name = p-script-name                       " + " " + where-phrase-36) <> ""
          then  substitute('X_pscript-ruleset.dtm-code = &1                     and X_pscript-ruleset.language = &2&3&2                     and X_pscript-ruleset.script-name = &2&4&2 ', p-dtm-code, chr(34), p-language, p-script-name )  + " " + where-phrase-36
          else "true"
        )
      parameter-5-36 = (" " + "" + " " + ", FIRST X_prop-script NO-LOCK WHERE X_prop-script.dtm-code = X_pscript-ruleset.dtm-code  AND X_prop-script.language = X_pscript-ruleset.LANGUAGE AND X_prop-script.script-name = X_pscript-ruleset.script-name AND X_prop-script.revis_id = X_pscript-ruleset.revis_id ,first X_prop-head NO-LOCK OUTER-JOIN WHERE X_prop-head.dtm-code = X_pscript-ruleset.dtm-code" + " " + p-find-condition)
      parameter-6-36 = if sort-phrase-36 = ''
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
        " " + sort-phrase-36
        )
      parameter-7-36 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-pscript-ruleset:handle
                          ,input logical(parameter-2-36)
                          ,input no-lock
                          ,input parameter-3-36
                          ,input parameter-4-36
                          ,input parameter-5-36
                          ,input parameter-6-36
                          ,input parameter-7-36
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
  END.
END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-pscript-ruleset to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-pscript-ruleset:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-pscript-ruleset in frame Dialog-Frame.
APPLY "ENTRY" TO br-pscript-ruleset.
END PROCEDURE.
PROCEDURE proc-b-add-chg :
define input parameter p-add as logical no-undo .
define variable v-rid-list as character no-undo .
define variable v-rec as recid no-undo .
define variable v-ok as logical no-undo .
define variable v-is-dynamic as logical no-undo .
define variable v-ii as integer no-undo .
define buffer buf_prop-script for dictdb.prop-script.
define buffer buf_prop-ruleset for dictdb.prop-ruleset.
CASE p-add:
  when yes then do:
    if p-list-mode = "ruleset" then do:
      run rul/prop-ruleset-s.w ( input parparentproc
                            ,input "b-sel"
                            ,input "ruleset"
                            ,input p-codex-id
                            ,input p-ruleset-id
                            ,input 0
                            ,input-output v-rid-list
                            ) no-error.
      if v-rid-list = '':U then do:
        return.
      end.
      find first buf_prop-ruleset no-lock where
                recid(buf_prop-ruleset) = integer(v-rid-list).
      run rul/prop-script-s.w ( input parparentproc
                            ,input "b-sel"
                            ,input "dtm-code"
                            ,input '':U
                            ,input buf_prop-ruleset.dtm-code
                            ,input '':U
                            ,input '':U
                            ,input-output v-rid-list) no-error.
      if v-rid-list = '':U then do:
        return.
      end.
      do v-ii = 1 to num-entries( v-rid-list):
        find first buf_prop-script no-lock where
                  recid(buf_prop-script) = integer(entry(v-ii, v-rid-list)).
        run rul/pscript-ruleset1.p ( input 'ДОБАВЛЕНИЕ':U
                                  ,input no
                                  ,input-output v-rec
                                  ,input  p-codex-id
                                  ,input  p-ruleset-id
                                  ,input buf_prop-script.dtm-code
                                  ,input buf_prop-script.language
                                  ,input buf_prop-script.script-name
                                  ,input buf_prop-script.revis_id
                                  ) no-error.
        if error-status:error then do:
          undo, return error .
        end.
      end.
    end.
    if p-list-mode = "dtm-code" then do:
      run rul/prop-ruleset-s.w ( input parparentproc
                            ,input "b-sel"
                            ,input "dtm-code"
                            ,input 0
                            ,input 0
                            ,input p-dtm-code
                            ,input-output v-rid-list
                            ) no-error.
      if v-rid-list = '':U then do:
        return.
      end.
      find first buf_prop-ruleset no-lock where
                recid(buf_prop-ruleset) = integer(v-rid-list).
      run rul/prop-script-s.w ( input parparentproc
                            ,input "b-sel,b-mark"
                            ,input "dtm-code"
                            ,input '':U
                            ,input buf_prop-ruleset.dtm-code
                            ,input '':U
                            ,input '':U
                            ,input-output v-rid-list) no-error.
      if v-rid-list = '':U then do:
        return.
      end.
      do v-ii = 1 to num-entries( v-rid-list):
        find first buf_prop-script no-lock where
                  recid(buf_prop-script) = integer(entry(v-ii, v-rid-list)).
        run rul/pscript-ruleset1.p ( input 'ДОБАВЛЕНИЕ':U
                                  ,input no
                                  ,input-output v-rec
                                  ,input  buf_prop-ruleset.codex_id
                                  ,input  buf_prop-ruleset.ruleset_id
                                  ,input  buf_prop-script.dtm-code
                                  ,input buf_prop-script.language
                                  ,input buf_prop-script.script-name
                                  ,input buf_prop-script.revis_id
                                  ) no-error.
        if error-status:error then do:
          undo, return error .
        end.
      end.
    end.
    if p-list-mode = "script-name" then do:
      run rul/prop-ruleset-s.w ( input parparentproc
                            ,input "b-sel,b-mark"
                            ,input "dtm-code"
                            ,input 0
                            ,input 0
                            ,input p-dtm-code
                            ,input-output v-rid-list
                            ) no-error.
      if v-rid-list = '':U then do:
        return.
      end.
      find first buf_prop-script no-lock where
                buf_prop-script.dtm-code = p-dtm-code
           and  buf_prop-script.language = p-language
           and  buf_prop-script.script-name = p-script-name.
      do v-ii = 1 to num-entries( v-rid-list):
        find first buf_prop-ruleset no-lock where
                  recid(buf_prop-ruleset) = integer(entry(v-ii, v-rid-list)).
        run rul/pscript-ruleset1.p ( input 'ДОБАВЛЕНИЕ':U
                                  ,input no
                                  ,input-output v-rec
                                  ,input buf_prop-ruleset.codex_id
                                  ,input buf_prop-ruleset.ruleset_id
                                  ,input buf_prop-script.dtm-code
                                  ,input buf_prop-script.language
                                  ,input buf_prop-script.script-name
                                  ,input buf_prop-script.revis_id
                                  ) no-error.
        if error-status:error then do:
          undo, return error .
        end.
      end.
    end.
    run openbr in this-procedure ( input yes, input no, input '':U).
    reposition br-pscript-ruleset to recid v-rec no-error.
    APPLY "ENTRY" to browse br-pscript-ruleset.
  end.
end.
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
  tbl = 'pscript-ruleset'
  join-tbl = 'X_pscript-ruleset'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('codex_id', 'Кодекс правил', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ruleset_id', 'Набор правил', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('language', 'Язык', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('dtm-code', 'Код объекта-операнда', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('script-name', 'Скрипт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('revis_id', 'Версия скрипта', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                   , INPUT filter-point + chr(4) + filter-point-label
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  RUN OpenBr IN THIS-PROCEDURE (INPUT yes
                               ,INPUT no
                               ,INPUT '':U).
end.
END PROCEDURE.
PROCEDURE proc-find-script-name :
define input parameter p-next as logical no-undo.
define input parameter p-script-name AS CHARACTER no-undo.
define input parameter p-find-option AS CHARACTER no-undo.
define variable old-word-script-name as character no-undo .
define variable v-w-script-name as character no-undo .
assign
frame Dialog-Frame f-script-name.
assign
p-script-name = replace(p-script-name, chr(34), "":U)
p-script-name = replace(p-script-name, chr(39), chr(39) + chr(39))
v-w-script-name = p-script-name
p-script-name = chr(34) + p-script-name + chr(34).
CASE p-find-option:
  WHEN "begins" THEN DO:
    old-word-script-name = p-word-script-name.
    p-word-script-name = '':U.
    v-doc-rec = ?.
    if old-word-script-name <> p-word-script-name then do:
      run OpenBr in this-procedure
          (input yes
          ,input no
          ,input '':U
          ).
    end.
    run OpenBr in this-procedure
        (input false
        ,input p-next
        ,input substitute("and X_pscript-ruleset.script-name contains &1 "
          , p-script-name)
        ).
  END.
  WHEN "contains":U  THEN DO:
    p-word-script-name = p-script-name.
    run OpenBr in this-procedure
        (input yes
        ,input no
        ,input '':U
        ).
  END.
END CASE.
apply "entry":u to f-script-name in frame Dialog-Frame .
END PROCEDURE.
FUNCTION get-translation RETURNS CHARACTER
  ( INPUT p-uniq-key-rec AS character ) :
DEFINE BUFFER buf_ruledict FOR ub.ruledict.
FIND FIRST buf_ruledict NO-LOCK WHERE
          buf_ruledict.entry-type = 'prop-script':U
    AND   buf_ruledict.uniq-key-rec = p-uniq-key-rec NO-ERROR.
IF AVAILABLE buf_ruledict THEN DO:
   RETURN buf_ruledict.script-nl.
END.
ELSE DO:
    RETURN '':U.
END.
END FUNCTION.
