define input        parameter parParentProc as widget-handle no-undo.
define input        parameter p-mode        as character     no-undo.
define input-output parameter p-code        as integer       no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Список оснований (причин) создания документа":U.
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
define temp-table one-empty-record NO-UNDO
       field somthing as logical
       .
define buffer X_trn-reason for ub.trn-reason.
define buffer buf_trn-rsn-attr      for ub.trn-rsn-attr .
define variable filter-point     as character no-undo initial 'trn-reason':U.
define variable filter-point0    as character no-undo initial 'trn-reason':U.
define variable filter-label     as character no-undo initial 'Список оснований (причин) создания документа':U.
define variable filter-label0    as character no-undo initial 'Список оснований (причин) создания документа':U.
define variable sort-column-name as character no-undo.
define variable sch-field        as character no-undo.
define variable FoundRec         as recid     no-undo.
define variable v-doc-rec          as recid     no-undo.
define variable ref-rec          as recid     no-undo.
define button b-help label "Помо&щь"   size-chars 10.00 by 1.00 default.
define button b-quit label "Вы&ход"    size-chars 10.00 by 1.00 default auto-end-key.
define button b-add  label "&Добавить" size-chars 10.00 by 1.00 default.
define button b-chg  label "&Изменить" size-chars 10.00 by 1.00 default.
define button b-lkp  label "&Просмотр" size-chars 10.00 by 1.00 default.
define button b-del  label "&Удалить"  size-chars 10.00 by 1.00 default.
define button b-sch  label "&Фильтр"   size-chars 10.00 by 1.00 default.
define button b-sel  label "Вы&бор"    size-chars 10.00 by 1.00 default auto-go.
define button b-History label "Истори&я"  size-chars 10.00 by 1.00 default.
DEFINE variable tb-deleted AS LOGICAL NO-UNDO label "Показывать удаленные"  view-as TOGGLE-BOX size-chars 22.63 BY .79 .
define variable sch-code as integer   no-undo view-as fill-in size-chars 15.50 by 1.00 format "->,>>>,>>>,>>>":U.
define variable sch-name as character no-undo view-as fill-in size-chars 45.50 by 1.00 format "x(60)":U.
define variable sch-num  as integer   no-undo view-as fill-in size-chars  4.50 by 1.00 format ">>>":U.
define variable PS-notes as character no-undo view-as editor  no-word-wrap scrollbar-vertical scrollbar-horizontal
                                                              size-chars 98.25 by 3.00 format "x(512)":U fgcolor 4.
define query br-reas for X_trn-reason, buf_trn-rsn-attr, one-empty-record scrolling.
define browse br-reas query br-reas display
X_trn-reason.reason-code column-label 'Код основания' format "->,>>>,>>>,>>9":U
X_trn-reason.reason-name column-label 'Основание (причина) создания документа' format "x(79)":U
AVAILABLE buf_trn-rsn-attr column-label 'А' format "+/ ":U
X_trn-reason.PS column-label 'Примечание' format "x(95)":U
enable
X_trn-reason.PS
with no-row-markers separators size-chars 98.25 by 15.13.
define frame fr-D-reason-0
b-quit   at row  1 col  1
b-sel    at row  1 col 11
b-add    at row  1 col 21
b-lkp    at row  1 col 31
b-chg    at row  1 col 41
b-del    at row  1 col 51
b-History  at row  1 col 61
b-sch      at row  1 col 71
b-help     at row  1 col 91
tb-deleted at row  1.1 col 62
br-reas at row  3.00 col  1.50
"          ":U at row 18.50 col  1.62 view-as text size-chars 98.00 by 1.00
"ПОИСК ПО:"    at row 18.50 col  2.00 view-as text size-chars  9.00 by 1.00 bgcolor 3 fgcolor 15
sch-code       at row 18.50 col 11.50    label "&Коду"
sch-name       at row 18.50 col 36.00    label "П&ричине"
sch-num        at row 18.50 col 94.75 no-label                              fgcolor 4
PS-notes       at row 20.00 col  1.50 no-label                              fgcolor 4 bgcolor  8
with view-as dialog-box keep-tab-order side-labels no-underline three-d scrollable
title 'Список оснований (причин) создания документа':U
default-button b-quit cancel-button b-quit.
assign frame fr-D-reason-0 :scrollable = no.
assign X_trn-reason.PS :read-only in browse br-reas = yes.
assign   b-quit     :tooltip in frame fr-D-reason-0 = "Вернуться в окно вызова"
       b-sch  :tooltip in frame fr-D-reason-0 = "Установить/снять фильтр"
       b-help    :tooltip in frame fr-D-reason-0 = "Интерактивная помощь в формате *.html"
       b-add     :tooltip in frame fr-D-reason-0 = "Добавить новую запись"
       b-chg    :tooltip in frame fr-D-reason-0 = "Изменить текущую запись"
       b-lkp    :tooltip in frame fr-D-reason-0 = "Просмотреть текущую запись"
       b-del  :tooltip in frame fr-D-reason-0 = "Удалить текущую запись"
       b-sel  :tooltip in frame fr-D-reason-0 = "Выбрать текущую запись"
         b-History  :tooltip in frame fr-D-reason-0 = "История основания (причины)"
       br-reas :tooltip in frame fr-D-reason-0 = "Список оснований (причин) создания документа"
         PS-notes     :tooltip in frame fr-D-reason-0 = "Примечание к основанию (причине) создания документа"
         sch-code     :tooltip in frame fr-D-reason-0 = "Код основания (причины)" + " для поиска. Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>"
         sch-name     :tooltip in frame fr-D-reason-0 = "Основание (причина) создания документа" + " для поиска. Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>"
         sch-num      :tooltip in frame fr-D-reason-0 = "Количество найденных записей".
on insert-mode of br-reas in frame fr-D-reason-0 do:
  if b-sel :sensitive in frame fr-D-reason-0 then do:
    apply "CHOOSE":U to b-sel in frame fr-D-reason-0.
  end.
end.
on choose of b-sch in frame fr-D-reason-0 do:
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run proc-filter in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-History in frame fr-D-reason-0 do:
  define variable v-list as character no-undo.
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if not available X_trn-reason then do:
    message
    "Неправильно выбрана строка."
    view-as alert-box error.
    return no-apply.
  end.
  run str/trncrsns.w ( input parParentProc
                     , input "":U
                     , input "one"
                     , input X_trn-reason.reason-code
                     , input-output v-list ).
  apply "ENTRY":U to br-reas in frame fr-D-reason-0.
end.
on choose of b-sel in frame fr-D-reason-0 do:
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if not available X_trn-reason then do:
    return no-apply.
  end.
  assign p-code = X_trn-reason.reason-code.
end.
on choose of b-add in frame fr-D-reason-0 do:
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run str/trn-rsna.w ( input parParentProc
                     , input 'ДОБАВЛЕНИЕ':U
                     , input-output v-doc-rec ) no-error.
  if not error-status :error
  and v-doc-rec <> ? then do:
    run OpenBr in this-procedure ( input yes, input no, input '':U ).
  end.
end.
on choose of b-chg in frame fr-D-reason-0 do:
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if not available X_trn-reason then do:
    message
    "Неправильно выбрана строка."
    view-as alert-box error.
    return no-apply.
  end.
  else do:
    assign v-doc-rec = recid( X_trn-reason ).
  end.
  run str/trn-rsna.w ( input parParentProc
                     , input 'ИЗМЕНЕНИЕ':U
                     , input-output v-doc-rec ).
  reposition br-reas to recid v-doc-rec no-error.
  if error-status :error then do:
    reposition br-reas to row 1 no-error.
  end.
  apply "ENTRY":U         to br-reas in frame fr-D-reason-0.
  apply "VALUE-CHANGED":U to br-reas in frame fr-D-reason-0.
end.
on choose of b-lkp in frame fr-D-reason-0 do:
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if not available X_trn-reason then do:
    message
    "Неправильно выбрана строка." view-as alert-box error.
    return no-apply.
  end.
  else do:
    assign v-doc-rec = recid( X_trn-reason ).
  end.
  run str/trn-rsna.w ( input parParentProc
                     , input 'ПРОСМОТР':U
                     , input-output v-doc-rec ).
  apply "ENTRY":U         to br-reas in frame fr-D-reason-0.
  apply "VALUE-CHANGED":U to br-reas in frame fr-D-reason-0.
end.
on choose of b-del in frame fr-D-reason-0 do:
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if not available X_trn-reason then do:
    message
    "Неправильно выбрана строка."
    view-as alert-box error.
    return no-apply.
  end.
  else do:
    assign v-doc-rec = recid( X_trn-reason ).
  end.
  run proc-delete in this-procedure no-error.
  if not error-status :error then do:
    run OpenBr in this-procedure ( input yes, input no, input '':U ).
  end.
end.
on return                of br-reas in frame fr-D-reason-0 or
   mouse-select-dblclick of br-reas in frame fr-D-reason-0 do:
  if b-sel :sensitive in frame fr-D-reason-0 then do:
    apply "CHOOSE":U to b-sel in frame fr-D-reason-0.
  end.
end.
on value-changed of br-reas in frame fr-D-reason-0 do:
  assign
  PS-notes = ( if available X_trn-reason then X_trn-reason.PS else "":U ).
  display
  PS-notes
  with frame fr-D-reason-0.
end.
on leave of PS-notes in frame fr-D-reason-0 do:
  define variable v-nota_bene as character no-undo.
  define buffer PS_doc for ub.trn-reason.
  assign v-nota_bene = ( input frame fr-D-reason-0 PS-notes ).
  if available X_trn-reason then
  do on error undo, return no-apply :
    find PS_doc exclusive-lock where
       recid( PS_doc ) = recid( X_trn-reason ).
    if PS_doc.PS <> v-nota_bene then do:
      assign PS_doc.PS = v-nota_bene.
    end.
    find PS_doc        no-lock where
         recid( PS_doc ) = recid( X_trn-reason ).
  end.
  else do:
    assign
    PS-notes :screen-value in frame fr-D-reason-0 = "":U.
  end.
end.
on entry of sch-code in frame fr-D-reason-0 do:
  assign sch-name :screen-value in frame fr-D-reason-0 = "":U.
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  display sch-code  with frame fr-D-reason-0.
end.
on entry of sch-name in frame fr-D-reason-0 do:
  assign sch-code :screen-value in frame fr-D-reason-0 = "":U.
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  display sch-name  with frame fr-D-reason-0.
end.
on leave of sch-code in frame fr-D-reason-0 do:
  if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,RETURN" ) = 0 and last-event :label <> "CTRL-J" then do:
    assign FoundRec = ?
           sch-num  = 0.
  end.
  hide sch-num in frame fr-D-reason-0.
end.
on leave of sch-name in frame fr-D-reason-0 do:
  if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,RETURN" ) = 0 and last-event :label <> "CTRL-J" then do:
    assign FoundRec = ?
           sch-num  = 0.
  end.
  hide sch-num in frame fr-D-reason-0.
end.
on CTRL-J of sch-code in frame fr-D-reason-0 do:
  if input frame fr-D-reason-0 sch-code <> sch-code then do:
    assign sch-code.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame fr-D-reason-0.
  end.
  run proc-find-code in this-procedure ( input yes, input sch-code ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on return of sch-code in frame fr-D-reason-0 do:
  assign sch-code.
  assign FoundRec = ?
         sch-num  = 0.
  hide   sch-num  in frame fr-D-reason-0.
  run proc-find-code in this-procedure ( input no,  input sch-code ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on mouse-select-dblclick of sch-code in frame fr-D-reason-0 do:
  if input frame fr-D-reason-0 sch-code <> sch-code then do:
    assign sch-code.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame fr-D-reason-0.
  end.
  run proc-find-code in this-procedure ( input yes, input sch-code ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on CTRL-J of sch-name in frame fr-D-reason-0 do:
  if input frame fr-D-reason-0 sch-name <> sch-name then do:
    assign sch-name.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame fr-D-reason-0.
  end.
  run proc-find-name in this-procedure ( input yes, input sch-name ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on return of sch-name in frame fr-D-reason-0 do:
  assign sch-name.
  assign FoundRec = ?
         sch-num  = 0.
  hide   sch-num  in frame fr-D-reason-0.
  run proc-find-name in this-procedure ( input no,  input sch-name ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on mouse-select-dblclick of sch-name in frame fr-D-reason-0 do:
  if input frame fr-D-reason-0 sch-name <> sch-name then do:
    assign sch-name.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame fr-D-reason-0.
  end.
  run proc-find-name in this-procedure ( input yes, input sch-name ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on value-changed of tb-deleted DO:
    assign tb-deleted.
    run OpenBr in this-procedure ( input yes, input no, input '':U ).
END.
on value-changed of br-reas DO:
    run my-enable in this-procedure.
END.
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F1 of frame fr-D-reason-0 anywhere do:
  if b-help :sensitive then DO: apply "CHOOSE":U to b-help in frame fr-D-reason-0. END.
  return no-apply.
end.
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame fr-D-reason-0 anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame fr-D-reason-0. END.
  return no-apply.
end.
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame fr-D-reason-0 anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame fr-D-reason-0. END.
  return no-apply.
end.
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame fr-D-reason-0 anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame fr-D-reason-0. END.
  return no-apply.
end.
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame fr-D-reason-0 anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame fr-D-reason-0. END.
  return no-apply.
end.
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame fr-D-reason-0 anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame fr-D-reason-0. END.
  return no-apply.
end.
if valid-handle( active-window ) and frame fr-D-reason-0 :parent = ? then frame fr-D-reason-0 :parent = active-window.
if current-window :window-state = window-minimized then do: current-window :window-state = window-normal. end.
on window-close of frame fr-D-reason-0 do: apply "END-ERROR":U to self. end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame fr-D-reason-0
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
on choose of b-help in frame fr-D-reason-0
do:
  apply "help":u to frame fr-D-reason-0 .
end.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame fr-D-reason-0:width - 0.3
                fh            = frame fr-D-reason-0:first-child
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
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame fr-D-reason-0 :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame fr-D-reason-0 :height-chars)
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
    if frame fr-D-reason-0 :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame fr-D-reason-0 :height-chars)
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
            frame fr-D-reason-0 :height = v-frame-height
          .
          if frame fr-D-reason-0 :scrollable = true
          then do:
            assign
              frame fr-D-reason-0 :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame fr-D-reason-0 :scrollable = true
          then do:
            assign
              frame fr-D-reason-0 :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame fr-D-reason-0 :height = v-frame-height
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
      v-frame-height = frame fr-D-reason-0 :height
      v-frame-virtual-height = frame fr-D-reason-0 :virtual-height
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
      v-field-group-handle = frame fr-D-reason-0 :first-child
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
    do with frame fr-D-reason-0
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame fr-D-reason-0 :scrollable = true
      then do:
        assign
          frame fr-D-reason-0 :virtual-height = frame fr-D-reason-0 :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame fr-D-reason-0 :height = frame fr-D-reason-0 :height + p-change-value
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
        frame fr-D-reason-0 :height = frame fr-D-reason-0 :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame fr-D-reason-0 :scrollable = true
      then do:
        assign
          frame fr-D-reason-0 :virtual-height = frame fr-D-reason-0 :virtual-height + p-change-value
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
          ,input  string(frame fr-D-reason-0 :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame fr-D-reason-0 :height)
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
    if frame fr-D-reason-0 :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame fr-D-reason-0 :width
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
    if frame fr-D-reason-0 :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame fr-D-reason-0 :width
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
            frame fr-D-reason-0 :width = v-frame-width
          .
          if frame fr-D-reason-0 :scrollable = true
          then do:
            assign
              frame fr-D-reason-0 :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame fr-D-reason-0 :scrollable = true
          then do:
            assign
              frame fr-D-reason-0 :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame fr-D-reason-0 :width = v-frame-width
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
      v-frame-width = frame fr-D-reason-0 :width
      v-frame-virtual-width = frame fr-D-reason-0 :virtual-width
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
      v-field-group-handle = frame fr-D-reason-0 :first-child
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
    do with frame fr-D-reason-0
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame fr-D-reason-0 :scrollable = true
      then do:
        assign
          frame fr-D-reason-0 :virtual-width = frame fr-D-reason-0 :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame fr-D-reason-0 :width = v-frame-width + p-change-value
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
        frame fr-D-reason-0 :width = frame fr-D-reason-0 :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame fr-D-reason-0 :scrollable = true
      then do:
        assign
          frame fr-D-reason-0 :virtual-width = frame fr-D-reason-0 :virtual-width + p-change-value
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
          ,input  string(frame fr-D-reason-0 :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame fr-D-reason-0 :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame fr-D-reason-0
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame fr-D-reason-0 :height - v-diasize-resize-button :height
                  - 1
                  - (frame fr-D-reason-0 :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame fr-D-reason-0 :width - v-diasize-resize-button :width
                  - 1
                  - (frame fr-D-reason-0 :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame fr-D-reason-0
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
      v-row-delta = v-new-row - frame fr-D-reason-0 :height
      v-col-delta = v-new-col - frame fr-D-reason-0 :width
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
            - frame fr-D-reason-0 :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame fr-D-reason-0 :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame fr-D-reason-0 :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame fr-D-reason-0 :height-chars
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
      v-diasize-current-frame-width  = frame fr-D-reason-0 :width
      v-diasize-current-frame-height = frame fr-D-reason-0 :height
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
    do with frame fr-D-reason-0
    :
      assign
        v-diasize-orig-frame-height = frame fr-D-reason-0 :height
        v-diasize-orig-frame-width  = frame fr-D-reason-0 :width
        v-diasize-browse-handle     = browse br-reas :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame fr-D-reason-0 :first-child
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
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-reas as INT EXTENT 4 no-undo.
DEF VAR varmvibr-reas       as INT no-undo.
DEF VAR varmvjbr-reas       as INT no-undo.
DEF VAR varmvkbr-reas       as INT no-undo.
DEF VAR varmvlbr-reas       as INT no-undo.
DEF VAR move-elementbr-reas as INT no-undo.
def var jjbr-reas           as int no-undo.
do varmvibr-reas = 1 to EXTENT(cur-clmn-numbr-reas):
  ASSIGN cur-clmn-numbr-reas[varmvibr-reas] = varmvibr-reas.
END.
RUN start-mv-clmnbr-reas.
PROCEDURE start-mv-clmnbr-reas:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-reas do:
  RUN re-move-clmnbr-reas ( 1, 4).
END.
ON ctrl-cursor-left OF BROWSE br-reas do:
  RUN re-move-clmnbr-reas (4, 1).
END.
PROCEDURE re-move-clmnbr-reas:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-reas = 1 TO EXTENT(cur-clmn-numbr-reas):
    if cur-clmn-numbr-reas[varmvibr-reas] = source-column THEN cur-clmn-numbr-reas[varmvibr-reas] = -1.
  END.
  if br-reas:MOVE-COLUMN(source-column, target-column) IN FRAME fr-D-reason-0 then.
  if source-column > target-column THEN
  DO varmvjbr-reas = source-column - 1 to target-column BY -1:
    DO varmvibr-reas = 1 TO EXTENT(cur-clmn-numbr-reas):
        if cur-clmn-numbr-reas[varmvibr-reas] = varmvjbr-reas THEN DO:
          cur-clmn-numbr-reas[varmvibr-reas] = cur-clmn-numbr-reas[varmvibr-reas] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-reas = source-column + 1 to target-column:
    DO varmvibr-reas = 1 TO EXTENT(cur-clmn-numbr-reas):
      if cur-clmn-numbr-reas[varmvibr-reas] = varmvjbr-reas THEN DO:
        cur-clmn-numbr-reas[varmvibr-reas] = cur-clmn-numbr-reas[varmvibr-reas] - 1.
      END.
    END.
  END.
  DO varmvibr-reas = 1 TO EXTENT(cur-clmn-numbr-reas):
    if cur-clmn-numbr-reas[varmvibr-reas] = -1 THEN cur-clmn-numbr-reas[varmvibr-reas] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-reas:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibr-reas = 1 TO EXTENT(cur-clmn-numbr-reas):
    if cur-clmn-numbr-reas[varmvibr-reas] = cur-clmn-loc THEN move-elementbr-reas = varmvibr-reas.
  END.
  RUN re-move-clmnbr-reas (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-reas:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-reas = 1 to EXTENT(cur-clmn-numbr-reas):
    RUN re-move-clmnbr-reas (cur-clmn-numbr-reas[varmvlbr-reas], varmvlbr-reas).
  END.
  RUN start-mv-clmnbr-reas.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
def var sort-labelbr-reas   as character no-undo .
def var sort-clmnbr-reas    as handle    no-undo .
def var cur-clmnbr-reas     as handle    no-undo .
def var cur-clmn-locbr-reas as integer   no-undo .
def var re-querybr-reas     as logical   initial no no-undo .
on start-search, ctrl-o of br-reas in frame fr-D-reason-0 do:
   run sort-brbr-reas
     (input (if available X_trn-reason
             then recid(X_trn-reason)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-reas :
  define input parameter p-recid as recid no-undo .
  if re-querybr-reas = no then do:
    assign
       cur-clmnbr-reas = br-reas:current-column in frame fr-D-reason-0
    .
    if sort-clmnbr-reas <> ? then sort-clmnbr-reas:column-fgcolor = 0.
    if cur-clmnbr-reas = sort-clmnbr-reas then do:
      assign
         sort-labelbr-reas = ""
         sort-clmnbr-reas = ?
      .
     end.
     else do:
       assign
         sort-labelbr-reas = cur-clmnbr-reas:label
         sort-clmnbr-reas  = cur-clmnbr-reas
         sort-clmnbr-reas:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-reas = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-reas:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-reas then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-reas = cur-clmn-locbr-reas + 1
    .
  end.
  case sort-labelbr-reas:
        when 'Код основания'  then DO:    assign       sort-column-name = "X_trn-reason.reason-code"     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Основание (причина) создания документа'  then DO:    assign       sort-column-name = "X_trn-reason.reason-name"     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Примечание'  then DO:    assign       sort-column-name = "X_trn-reason.PS"     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure ( input yes, input no, input '':U ).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-reas') then do:
          run mv-brw-defaultbr-reas.
        end.
      if sort-labelbr-reas <> "" then do:
        assign
          cur-clmnbr-reas:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-reas = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-reas to recid p-recid no-error.
    apply "value-changed" to br-reas in frame fr-D-reason-0.
  end.
  apply "entry" to br-reas in frame fr-D-reason-0.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-reas:
if cur-clmnbr-reas = ? then do:
   run OpenBr in this-procedure ( input yes, input no, input '':U ).
end.
else do:
   assign re-querybr-reas = yes.
   run sort-brbr-reas
     (input (if available X_trn-reason
             then recid(X_trn-reason)
             else ?
            )
     ).
   assign re-querybr-reas = no.
end.
end.
Main-Block:
do on error   undo Main-Block, leave Main-Block
   on end-key undo Main-Block, leave Main-Block :
  create one-empty-record.
  display   PS-notes     with frame fr-D-reason-0.
  enable  b-sch  b-help b-History b-quit b-lkp
          tb-deleted
          br-reas   sch-code  sch-name    PS-notes
  with frame fr-D-reason-0.
  if p-mode = 'справочник':U then do:
    if v-cntxt-db-num = 0 then do:
      enable
      b-add b-chg b-del
      with frame fr-D-reason-0.
    end.
    else do:
      disable
      b-add b-chg b-del tb-deleted
      with frame fr-D-reason-0.
    end.
    disable
    b-sel with frame fr-D-reason-0.
  end.
  else if p-mode = 'выбор':U then do:
    enable
    b-sel with frame fr-D-reason-0.
    disable
    b-add b-chg b-del tb-deleted
    with frame fr-D-reason-0.
  end.
  find first X_trn-reason no-lock where
             X_trn-reason.reason-code = p-code no-error.
  assign
  ref-rec = ( if available X_trn-reason then recid( X_trn-reason ) else ? ).
  run OpenBr in this-procedure ( input yes, input no, input '':U ).
  RUN my-enable IN THIS-PROCEDURE .
  hide sch-num in frame fr-D-reason-0.
  br-reas :set-repositioned-row( 5, "CONDITIONAL":U ).
  if ref-rec <> ? then do:
    reposition br-reas to recid ref-rec no-error.
    if error-status :error then do: reposition br-reas to row 1 no-error. end.
                           else do: assign v-doc-rec = ref-rec. end.
  end.
  wait-for go of frame fr-D-reason-0.
end.
hide frame fr-D-reason-0 no-pause.
procedure OpenBr :
  define input parameter p-open-query     as logical   no-undo.
  define input parameter p-find-next      as logical   no-undo.
  define input parameter p-find-condition as character no-undo.
  define variable l-query-was-opened as logical   no-undo.
  define variable sort-column-phrase as character no-undo.
  define variable p-proc-hand        as handle    no-undo.
  define variable l-open-query       as logical   no-undo.
  assign
   p-proc-hand = this-procedure :handle
  .
  case sort-column-name :
    when "":U                    then do:
      assign sort-column-phrase = "":U.
    end.
    when "X_trn-reason.reason-name" then do:
      assign sort-column-phrase = "by substring( X_trn-reason.reason-name, 1, 79 )".
    end.
    when "X_trn-reason.PS"          then do:
      assign sort-column-phrase = "by substring( X_trn-reason.PS,          1, 95 )".
    end.
    otherwise                         do:
      assign sort-column-phrase = "by " + sort-column-name.
    end.
  end case.
  assign
  frame fr-D-reason-0 :title = substitute("&1 &2", 'Список оснований (причин) создания документа':U, p-mode).
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
                              "for each X_trn-reason"
      parameter-4-25 =
        (
          if (" YES " + " " + where-phrase-25) <> ""
          then " YES " + " " + where-phrase-25
          else "true"
        )
      parameter-5-25 = (" " + "" + " " + SUBSTITUTE(', first buf_trn-rsn-attr outer-join of X_trn-reason no-lock, first one-empty-record no-lock WHERE YES AND ((NOT AVAILABLE buf_trn-rsn-attr) OR (&1 = TRUE))', tb-deleted))
      parameter-6-25 = if sort-phrase-25 = ''
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
        " " + sort-phrase-25
        )
      parameter-7-25 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-25 =
          (" YES " + " " + where-phrase-25 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-reas:handle
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
    open query br-reas for each X_trn-reason no-lock
      where  YES
    , first buf_trn-rsn-attr outer-join of X_trn-reason no-lock, first one-empty-record no-lock WHERE YES AND ((NOT AVAILABLE buf_trn-rsn-attr) OR (tb-deleted = TRUE))
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_trn-reason )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-reas:handle:get-buffer-handle(1) = (buffer X_trn-reason:handle) then do:
      assign
      parameter-2-25 = (if p-find-next then "true":u else "false":u )
      parameter-4-25 =
        "where ":u + " YES " + " ":u + where-phrase-25 + " ":u + p-find-condition + " " + ""
      parameter-5-25 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-reas:handle
                          ,input rowid(X_trn-reason)
                          ,input logical(parameter-2-25)
                          ,input no-lock
                          ,input (buffer X_trn-reason:handle)
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
      parameter-3-25 =  "for each X_trn-reason"
      parameter-4-25 =
        (
          if (" YES " + " " + where-phrase-25) <> ""
          then " YES " + " " + where-phrase-25
          else "true"
        )
      parameter-5-25 = (" " + "" + " " + SUBSTITUTE(', first buf_trn-rsn-attr outer-join of X_trn-reason no-lock, first one-empty-record no-lock WHERE YES AND ((NOT AVAILABLE buf_trn-rsn-attr) OR (&1 = TRUE))', tb-deleted) + " " + p-find-condition)
      parameter-6-25 = if sort-phrase-25 = ''
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
        " " + sort-phrase-25
        )
      parameter-7-25 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-reas:handle
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
if p-open-query <> yes and v-doc-rec <> ? then
reposition br-reas to recid v-doc-rec no-error.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-reas:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
apply "VALUE-CHANGED":U to br-reas in frame fr-D-reason-0.
apply "ENTRY":U         to br-reas in frame fr-D-reason-0.
end procedure.
procedure proc-filter :
  assign tbl      = 'trn-reason'
         join-tbl = 'X_trn-reason'
         fld      = '':U
         lab      = '':U
         spr      = '':U
         dim      = '0'.
    run fltfield-add in this-procedure ( input 'reason-code', input 'Код причины',         input '':U, input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'reason-name', input 'Основание (причина)', input '':U, input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'PS',          input 'Примечание',          input '':U, input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  Filter-Block:
  do on error   undo Filter-Block, leave Filter-Block
     on end-key undo Filter-Block, leave Filter-Block :
    run gbl/filter.w ( input parParentProc
                   ,input filter-point + chr(4) + filter-label
                   ,input tbl
                   ,input join-tbl
                   ,input fld
                   ,input lab
                   ,input spr
                   ,input dim            ).
    if return-value = 'undo':U then do:
      apply "ENTRY":U to browse br-reas.
      return no-apply.
    end.
    assign sch-num = 0.
    hide   sch-num in frame fr-D-reason-0.
    run OpenBr in this-procedure ( input yes, input no, input '':U ).
  end.
end procedure.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame fr-D-reason-0:
    if p-filter-name > "" then do:
      assign
        frame fr-D-reason-0:title
          = frame fr-D-reason-0:title + "   ФИЛЬТР: " + p-filter-name.
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
procedure proc-find-code :
  define input parameter p-next as logical no-undo.
  define input parameter p-code as integer no-undo.
  run OpenBr in this-procedure ( input no, input p-next, input substitute( ' AND X_trn-reason.reason-code = &1 ', p-code ) ).
  if v-doc-rec <> ? then do:
    if FoundRec = ? then do:
      assign FoundRec = v-doc-rec.
    end.
    if FoundRec = v-doc-rec then do:
      assign sch-num = 0.
    end.
    assign  sch-num = sch-num + 1.
    display
    sch-num with frame fr-D-reason-0.
  end.
  else do:
    assign  sch-num = 0.
    hide    sch-num
    in frame fr-D-reason-0.
  end.
  apply "ENTRY":U to sch-code in frame fr-D-reason-0.
end procedure.
procedure proc-find-name :
  define input parameter p-next as logical   no-undo.
  define input parameter p-name as character no-undo.
  assign p-name = replace( p-name, chr(34), chr(34) + chr(34) )
         p-name = replace( p-name, chr(39), chr(39) + chr(39) )
         p-name = chr(34) + p-name + chr(34).
  run OpenBr in this-procedure ( input no,
                                 input p-next,
                                 input substitute( ' AND X_trn-reason.reason-name begins &1 ', p-name ) ).
  if v-doc-rec <> ? then do:
    if FoundRec = ? then do:
      assign FoundRec = v-doc-rec.
    end.
    if FoundRec = v-doc-rec then do:
      assign sch-num = 0.
    end.
    assign  sch-num = sch-num + 1.
    display sch-num
    with frame fr-D-reason-0.
  end.
  else do:
    assign  sch-num = 0.
    hide    sch-num
    in frame fr-D-reason-0.
  end.
  apply "ENTRY":U to sch-name in frame fr-D-reason-0.
end procedure.
procedure proc-delete :
  define variable l_log as logical no-undo.
  run ref/trn-rsn1.p
    ( input-output v-doc-rec
    , input 'удаление':U
    , input false
    , input "":U
    , input "":U
    , input "":U
    ) no-error.
  if error-status:error then do:
    message
      substitute("Ошибка при удалении основания (причины)") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  get prev br-reas no-lock.
  if not available X_trn-reason then do:
    get prev br-reas no-lock.
  end.
  if not available X_trn-reason then do:
    get next br-reas no-lock.
  end.
  assign
    v-doc-rec = ( if available X_trn-reason then recid( X_trn-reason ) else ? )
  .
  reposition br-reas to recid v-doc-rec no-error.
  if error-status :error then do:
    reposition br-reas to row 1 no-error.
  end.
  apply "ENTRY":U         to br-reas in frame fr-D-reason-0.
  apply "VALUE-CHANGED":U to br-reas in frame fr-D-reason-0.
end procedure.
procedure get-attr-sign :
  define  input parameter p-code as integer   no-undo.
  define output parameter p-attr as character no-undo.
  define buffer buf_attr for ub.trn-rsn-attr.
  do on error   undo, leave
     on end-key undo, leave :
    find first buf_attr no-lock where
               buf_attr.reason-code = p-code no-error.
    assign p-attr = ( if available buf_attr then "+":U else " ":U ).
  end.
end procedure.
procedure my-enable :
do
on error undo, return error
:
   define buffer buf_trn-rsn-attr      for ub.trn-rsn-attr .
   IF CAN-FIND(first buf_trn-rsn-attr
               where buf_trn-rsn-attr.reason-code = X_trn-reason.reason-code
                 and buf_trn-rsn-attr.attr-code   = "del":U
            no-lock)
   THEN DO:
      disable
         b-chg b-del
      with frame fr-D-reason-0.
   END.
   ELSE DO:
     if   p-mode = 'справочник':U
     AND  v-cntxt-db-num = 0 then do:
      enable
         b-chg b-del
      with frame fr-D-reason-0.
      END.
   END.
end.
end procedure.
