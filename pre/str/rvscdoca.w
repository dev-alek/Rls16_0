define input        parameter p-parent-proc as widget-handle no-undo.
define input        parameter p-mode        as character     no-undo.
define input-output parameter p-rid         as recid         no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Просмотр карточки истории изменения сверки":U.
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame fr-D-doca0:
    if p-filter-name > "" then do:
      assign
        frame fr-D-doca0:title
          = frame fr-D-doca0:title + "   ФИЛЬТР: " + p-filter-name.
      .
    end.
    else do:
    end.
  end.
end procedure.
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
define variable ParParentProc as widget-handle no-undo.
define variable gds-rec       as recid         no-undo.
define variable doc-rec       as recid         no-undo.
define variable v-ref-rec       as recid         no-undo.
define new shared buffer r-line for ub.c-rvs-line.
define new shared buffer r-pump for ub.c-rvs-line-pump.
define new shared buffer   r-goods    for ub.goods.
define new shared buffer   r-place    for ub.place.
function deviation-fact returns decimal (
      input p-state-measure-qnty as decimal
    , input p-state-add-qnty     as decimal
    , input p-system-qnty        as decimal
):
    define variable dev-fact-qty as decimal no-undo.
    run get-dev-fact in this-procedure (
          input p-state-measure-qnty
        , input p-state-add-qnty
        , input p-system-qnty
        , output dev-fact-qty
    ).
    return ( dev-fact-qty ).
end function.
function deviation-measure returns decimal (
      input p-state-measure-qnty as decimal
    , input p-state-add-qnty     as decimal
    , input p-system-qnty        as decimal
) :
  define variable dev-meas-qty as decimal no-undo.
    run get-dev-fact in this-procedure (
          input p-state-measure-qnty
        , input p-state-add-qnty
        , input p-system-qnty
        , output dev-meas-qty
    ).
    return ( dev-meas-qty ).
end function.
define buffer cli-buf for ub.clients.
define variable rvs-line-rec     as recid     no-undo.
define variable rvs-pump-rec     as recid     no-undo.
define variable filter-point     as character no-undo initial "":U.
define variable filter-point0    as character no-undo initial "":U.
define variable sort-column-line as character no-undo.
define variable sort-column-pump as character no-undo.
define button   Btn_Exit  label "Вы&ход"      size-chars 10.00 BY 1.00 default auto-end-key.
define button   Btn_OK    label "&Ввод "      size-chars 10.00 BY 1.00 default auto-go.
define button b-lkp label "&Просмотр"   size-chars 12.00 by 1.00 default.
define button   Btn_Pump  label "Просм. ТР&К" size-chars 12.00 by 1.00 default.
define button   Btn_Notes label "При&мечание" size-chars 12.00 by 1.00 default.
define button b-help label "Помо&щь"     size-chars 10.00 BY 1.00 default.
define variable agnt-name as character no-undo format "x(256)":U view-as text    size-chars 14.00 by 1.00.
define variable boss-name as character no-undo format "x(256)":U view-as text    size-chars 14.00 by 1.00.
define variable wrkr-name as character no-undo format "x(256)":U view-as text    size-chars 14.00 by 1.00.
define rectangle r-rect-1 edge-pixels 3 graphic-edge no-fill size-chars 98.25 by 1.50.
define new shared query br-line for r-line, r-goods, r-place scrolling.
define browse br-line query br-line no-lock display
  r-goods.artic  column-label 'Артикул'  format 'x(16)':U
  r-goods.gds-name  column-label 'Название'  format 'x(15)':U
  r-line.pl-code  column-label 'Скл.место'  format '999999999':U
  r-place.loc1  column-label 'Номер резервуара'  format 'x(8)':U
  r-line.state-measure-qnty  column-label 'Факт остаток'  format '->>,>>>,>>9.<<<':U
  r-line.measure-qnty  column-label 'Измер. остаток'  format '->>,>>>,>>9.<<<':U
  r-line.system-qnty  column-label 'Учет'  format '->>,>>>,>>9.<<<':U
  r-line.orig-system-qnty  column-label 'Первонач.учет'  format '->>,>>>,>>9.<<<':U
  r-line.state-add-qnty  column-label 'Факт в!трубопроводе'  format '->>,>>>,>>9.<<<':U
  deviation-fact( r-line.state-measure-qnty, r-line.state-add-qnty, r-line.system-qnty ) column-label 'Отклонение(факт)' format '->>,>>>,>>>.<<<':U
  deviation-measure( r-line.state-measure-qnty, r-line.state-add-qnty, r-line.system-qnty ) column-label 'Отклонение(измер)' format '->>,>>>,>>>.<<<':U
  r-line.tolerance column-label 'Допустимое!отклонение' format '->>,>>>,>>9.<<<':U
  r-line.state-brutto-qnty column-label 'Факт брутто' format '->>,>>>,>>9.<<<':U
  r-line.brutto-qnty column-label 'Измер. брутто' format '->>,>>>,>>9.<<<':U
  r-line.state-density column-label 'Плотность' format '>9.999':U
  r-line.density column-label 'Измер.!пл-ть' format '>9.999':U
  r-line.state-measure-cli-qnty column-label 'Факт!(ед. пост.)' format '->>,>>>,>>9.<<<':U
  r-line.measure-cli-qnty column-label 'Измер.!(ед. пост.)' format '->>,>>>,>>9.<<<':U
  r-line.system-cli-qnty column-label 'Учет (ед.пост.)' format '->>,>>>,>>9.<<<':U
  r-line.orig-system-cli-qnty column-label 'Нач.учет(е.п.)' format '->>,>>>,>>9.<<<':U
  r-line.state-brutto-cli-qnty column-label 'Факт брутто!(ед.пост.)' format '->>,>>>,>>9.<<<':U
  r-line.brutto-cli-qnty column-label 'Измер. брутто! (ед.пост)' format '->>,>>>,>>9.<<<':U
  r-line.state-mh-qnty column-label 'Факт оборот' format '->>>,>>>,>>9.999':U
  r-line.meas-mh-qnty column-label 'Измер. оборот' format '->>>,>>>,>>9.999':U
  r-line.state-am-qnty column-label 'Факт сумма!оборота' format '->>>,>>>,>>9.99':U
  r-line.meas-am-qnty column-label 'Измер. сумма!оборота' format '->>>,>>>,>>9.99':U
  r-line.state-cf-qnty column-label 'Факт!кол-во наливов' format '->,>>>,>>9':U
  r-line.meas-cf-qnty column-label 'Измер.!кол-во наливов' format '->,>>>,>>9':U
  r-line.state-level-total column-label 'Факт!общий уровень' format '->>,>>9.999':U
  r-line.level-total column-label 'Измер.!общий уровень' format '->>,>>9.999':U
  r-line.state-level-petrol column-label 'Факт!уровень топлива' format '->>,>>9.999':U
  r-line.level-petrol column-label 'Измер.!уровень топлива' format '->>,>>9.999':U
  r-line.state-level-water column-label 'Факт!уровень воды' format '->>,>>9.999':U
  r-line.level-water column-label 'Измер.!уровень воды' format '->>,>>9.999':U
  r-line.state-temperature column-label 'Температура' format '->>9.999':U
  r-line.temperature column-label 'Измер.!темп.' format '->>9.999':U
  enable
  r-line.temperature
with no-row-markers separators size-chars 98.25 by 6.00.
define new shared query br-pump for r-pump scrolling.
define browse br-pump query br-pump no-lock display
  r-pump.pump-code  column-label 'ТРК'  format '>9':U
  r-pump.nozzle-code  column-label 'П'  format '>':U
  r-pump.state-mh-qnty  column-label 'Факт оборот'  format '->>>,>>>,>>9.999':U
  r-pump.meas-mh-qnty  column-label 'Измер. оборот'  format '->>>,>>>,>>9.999':U
  r-pump.state-am-qnty  column-label 'Факт сумма!оборота'  format '->>>,>>>,>>9.99':U
  r-pump.meas-am-qnty  column-label 'Измер. сумма!оборота'  format '->>>,>>>,>>9.99':U
  r-pump.state-cf-qnty  column-label 'Факт!кол-во наливов'  format '->,>>>,>>9':U
  r-pump.meas-cf-qnty  column-label 'Измер.!кол-во наливов'  format '->,>>>,>>9':U
  r-pump.state-mh-cnt  column-label 'Показ. механического!счетчика'  format '->,>>>,>>>,>>>,>>9.999':U
  r-pump.meas-mh-cnt column-label 'Измер. механического! счетчика' format '->,>>>,>>>,>>>,>>9.999':U
  r-pump.state-el-cnt column-label 'Показ. электронного!счетчика' format '->,>>>,>>>,>>>,>>9.999':U
  r-pump.meas-el-cnt column-label 'Измер. электронного!счетчика' format '->,>>>,>>>,>>>,>>9.999':U
  r-pump.state-am-cnt column-label 'Сумма по показ.!счетчика' format '->,>>>,>>>,>>>,>>9.999':U
  r-pump.meas-am-cnt column-label 'Сумма по измер.!счетчика' format '->,>>>,>>>,>>>,>>9.999':U
  r-pump.state-cf-cnt column-label 'Кол-во наливов!по показ. счетчика' format '->,>>>,>>>,>>>,>>9':U
  r-pump.meas-cf-cnt column-label 'Кол-во наливов!по  измер. счетчика' format '->,>>>,>>>,>>>,>>9':U
  r-pump.icnt-code column-label 'Номер док-та!инвент. счетчика' format 'x(16)':U
  r-pump.rvs-prev-code column-label 'Сверка на начало' format 'x(16)':U
  enable
  r-pump.rvs-prev-code
with no-row-markers separators size-chars 98.25 by 6.00.
define frame fr-D-doca0
  "Объект:"                            at row  1.50 col 10.00
  ub.c-rvs-doc.obj-code               at row  1.50 col 16.00 colon-aligned no-label                       view-as text    size-chars    10.00 by 1.00
  ub.c-rvs-doc.obj-type               at row  1.50 col 26.00 colon-aligned no-label                       view-as text    size-chars     4.13 by 1.00
     ub.clients.obj-name               at row  1.50 col 33.00 colon-aligned no-label fgcolor 4             view-as text    size-chars    40.00 by 1.00
  ub.c-rvs-doc.out-code               at row  2.50 col 20.00 colon-aligned    label "На основе документа" view-as text
  ub.c-rvs-doc.doc-date               at row  2.50 col 41.00 colon-aligned                                view-as text
  ub.c-rvs-doc.agnt                   at row  5.00 col  4.50 colon-aligned   format "999999999":U         view-as fill-in size-chars 10.00 by 1.00
    agnt-name                          at row  5.00 col 15.00 colon-aligned no-label fgcolor 4
  ub.c-rvs-doc.wrkr                   at row  4.00 col  4.50 colon-aligned   format "999999999":U         view-as fill-in size-chars 10.00 by 1.00
    wrkr-name                          at row  4.00 col 15.00 colon-aligned no-label fgcolor 4
  ub.c-rvs-doc.boss                   at row  6.00 col  4.50 colon-aligned   format "999999999":U         view-as fill-in size-chars 10.00 by 1.00
    boss-name                          at row  6.00 col 15.00 colon-aligned no-label fgcolor 4
  ub.c-rvs-doc.state-measure-qnty     at row  3.25 col 38.00 colon-aligned    label "Факт"                view-as text
  ub.c-rvs-doc.measure-qnty           at row  3.25 col 62.00 colon-aligned    label "Измер"               view-as text
  ub.c-rvs-doc.system-qnty            at row  3.25 col 86.00 colon-aligned                                view-as text
  ub.c-rvs-doc.state-measure-cli-qnty at row  4.00 col 50.00 colon-aligned    label "Вес"                 view-as text
  ub.c-rvs-doc.measure-cli-qnty       at row  4.00 col 80.00 colon-aligned    label "Измер.вес"           view-as text
  ub.c-rvs-doc.system-cli-qnty        at row  5.00 col 50.00 colon-aligned    label "Учет вес"            view-as text
  ub.c-rvs-doc.system-cli-avrg-qnty   at row  5.00 col 80.00 colon-aligned    label "Вес по ср.пл-ти"     view-as text
  ub.c-rvs-doc.state-mh-qnty          at row  6.00 col 38.00 colon-aligned    label "Оборот"              view-as text
  ub.c-rvs-doc.state-am-qnty          at row  6.00 col 62.50 colon-aligned    label "Сумма"               view-as text
  ub.c-rvs-doc.state-cf-qnty          at row  6.00 col 87.75 colon-aligned    label "Наливы"              view-as text
  ub.c-rvs-doc.state-measure-tc-qnty  at row  7.00 col  1.00             label "tc: Факт"            view-as text
  ub.c-rvs-doc.measure-tc-qnty        at row  7.00 col 25.00             label "Измер"               view-as text
  ub.c-rvs-doc.state-brutto-tc-qnty   at row  7.00 col 46.00             label "Факт брутто"         view-as text
  ub.c-rvs-doc.brutto-tc-qnty         at row  7.00 col 72.00             label "Измер брутто"        view-as text
  br-line                       at row  8.00 col  1.50
  br-pump                       at row 14.00 col  1.50
  r-rect-1                             at row 20.25 col  1.50
    Btn_Exit                           at row 20.50 col  2.50
  b-lkp                          at row 20.50 col 37.00
    Btn_Pump                           at row 20.50 col 50.00
    Btn_Notes                          at row 20.50 col 63.00
    Btn_OK                             at row 20.50 col 76.25
  b-help                          at row 20.50 col 88.75
with view-as dialog-box keep-tab-order side-labels no-underline three-d scrollable
     default-button Btn_OK cancel-button Btn_Exit.
assign frame fr-D-doca0 :scrollable = no.
assign br-line          :num-locked-columns in frame  fr-D-doca0  = 4
       br-pump          :num-locked-columns in frame  fr-D-doca0  = 2
       r-line.temperature :read-only          in browse br-line = yes
       r-pump.rvs-prev-code :read-only          in browse br-pump = yes.
on end-error, stop of frame fr-D-doca0 do:
  apply "CHOOSE":U to Btn_Exit in frame fr-D-doca0.
  return no-apply.
end.
on choose of Btn_OK in frame fr-D-doca0 do:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  apply "GO":U to frame fr-D-doca0.
end.
on choose of Btn_Exit in frame fr-D-doca0 do:
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
end.
on choose of b-lkp in frame fr-D-doca0 do:
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
  if not available r-line then do:
    message "Неправильно выбрана строка сверки." view-as alert-box error.
    return no-apply.
  end.
  run proc-lookup-line in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of Btn_Pump in frame fr-D-doca0 do:
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
  if not available r-pump then do:
    message "Неправильно выбрана строка." view-as alert-box error.
    return no-apply.
  end.
  run proc-lookup-pump in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of Btn_Notes in frame fr-D-doca0 do:
  define variable v-note as character no-undo.
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
  assign v-note = ub.c-rvs-doc.PS.
  run gbl/notes.w ( input 'ПРОСМОТР':U, input-output v-note ).
end.
on value-changed of br-line in frame fr-D-doca0 do:
  if available r-line then do:
    run open-br-pump in this-procedure ( input yes,
                                                input no,
                                                input '':U,
                                                input r-line.pl-code,
                                                input r-line.gds-code ).
  end.
end.
assign ParParentProc = p-parent-proc.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame fr-D-doca0 anywhere do:
  if not available ub.goods then
    return no-apply.
  gds-rec = recid (ub.goods).
  run ref/gds-form.w ( input ParParentProc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br-line in frame fr-D-doca0.
  return no-apply.
end.
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F1 of frame fr-D-doca0 anywhere do:
  if b-help :sensitive then DO: apply "CHOOSE":U to b-help in frame fr-D-doca0. END.
  return no-apply.
end.
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame fr-D-doca0 anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame fr-D-doca0. END.
  return no-apply.
end.
if current-window :window-state = window-minimized then do: current-window :window-state = window-normal. end.
if valid-handle( active-window ) and frame fr-D-doca0 :parent = ? then frame fr-D-doca0 :parent = active-window.
on window-close of frame fr-D-doca0 do: apply "END-ERROR":U to self. end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame fr-D-doca0
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
on choose of b-help in frame fr-D-doca0
do:
  apply "help":u to frame fr-D-doca0 .
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame fr-D-doca0:width - 0.3
                fh            = frame fr-D-doca0:first-child
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-line as INT EXTENT 36 no-undo.
DEF VAR varmvibr-line       as INT no-undo.
DEF VAR varmvjbr-line       as INT no-undo.
DEF VAR varmvkbr-line       as INT no-undo.
DEF VAR varmvlbr-line       as INT no-undo.
DEF VAR move-elementbr-line as INT no-undo.
def var jjbr-line           as int no-undo.
do varmvibr-line = 1 to EXTENT(cur-clmn-numbr-line):
  ASSIGN cur-clmn-numbr-line[varmvibr-line] = varmvibr-line.
END.
RUN start-mv-clmnbr-line.
PROCEDURE start-mv-clmnbr-line:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-line do:
  RUN re-move-clmnbr-line ( 5, 36).
END.
ON ctrl-cursor-left OF BROWSE br-line do:
  RUN re-move-clmnbr-line (36, 5).
END.
PROCEDURE re-move-clmnbr-line:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-line = 1 TO EXTENT(cur-clmn-numbr-line):
    if cur-clmn-numbr-line[varmvibr-line] = source-column THEN cur-clmn-numbr-line[varmvibr-line] = -1.
  END.
  if br-line:MOVE-COLUMN(source-column, target-column) IN FRAME fr-D-doca0 then.
  if source-column > target-column THEN
  DO varmvjbr-line = source-column - 1 to target-column BY -1:
    DO varmvibr-line = 1 TO EXTENT(cur-clmn-numbr-line):
        if cur-clmn-numbr-line[varmvibr-line] = varmvjbr-line THEN DO:
          cur-clmn-numbr-line[varmvibr-line] = cur-clmn-numbr-line[varmvibr-line] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-line = source-column + 1 to target-column:
    DO varmvibr-line = 1 TO EXTENT(cur-clmn-numbr-line):
      if cur-clmn-numbr-line[varmvibr-line] = varmvjbr-line THEN DO:
        cur-clmn-numbr-line[varmvibr-line] = cur-clmn-numbr-line[varmvibr-line] - 1.
      END.
    END.
  END.
  DO varmvibr-line = 1 TO EXTENT(cur-clmn-numbr-line):
    if cur-clmn-numbr-line[varmvibr-line] = -1 THEN cur-clmn-numbr-line[varmvibr-line] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-line:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 5 then do:
    return .
  end.
  DO varmvibr-line = 1 TO EXTENT(cur-clmn-numbr-line):
    if cur-clmn-numbr-line[varmvibr-line] = cur-clmn-loc THEN move-elementbr-line = varmvibr-line.
  END.
  RUN re-move-clmnbr-line (cur-clmn-loc, 5).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-line:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-line = 5 to EXTENT(cur-clmn-numbr-line):
    RUN re-move-clmnbr-line (cur-clmn-numbr-line[varmvlbr-line], varmvlbr-line).
  END.
  RUN start-mv-clmnbr-line.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
def var sort-labelbr-line   as character no-undo .
def var sort-clmnbr-line    as handle    no-undo .
def var cur-clmnbr-line     as handle    no-undo .
def var cur-clmn-locbr-line as integer   no-undo .
def var re-querybr-line     as logical   initial no no-undo .
on start-search, ctrl-o of br-line in frame fr-D-doca0 do:
   run sort-brbr-line
     (input (if available r-line
             then recid(r-line)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-line :
  define input parameter p-recid as recid no-undo .
  if re-querybr-line = no then do:
    assign
       cur-clmnbr-line = br-line:current-column in frame fr-D-doca0
    .
    if sort-clmnbr-line <> ? then sort-clmnbr-line:column-fgcolor = 0.
    if cur-clmnbr-line = sort-clmnbr-line then do:
      assign
         sort-labelbr-line = ""
         sort-clmnbr-line = ?
      .
     end.
     else do:
       assign
         sort-labelbr-line = cur-clmnbr-line:label
         sort-clmnbr-line  = cur-clmnbr-line
         sort-clmnbr-line:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-line = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-line:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-line then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-line = cur-clmn-locbr-line + 1
    .
  end.
  case sort-labelbr-line:
        when 'Артикул'  then DO:    assign       sort-column-line = "r-goods.artic"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Название'  then DO:    assign       sort-column-line = "r-goods.gds-name"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Скл.место'  then DO:    assign       sort-column-line = "r-line.pl-code"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Номер резервуара'  then DO:    assign       sort-column-line = "r-place.loc1"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Факт остаток'  then DO:    assign       sort-column-line = "r-line.state-measure-qnty"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Измер. остаток'  then DO:    assign       sort-column-line = "r-line.measure-qnty"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Учет'  then DO:    assign       sort-column-line = "r-line.system-qnty"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Первонач.учет'  then DO:    assign       sort-column-line = "r-line.orig-system-qnty"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Факт в!трубопроводе'  then DO:    assign       sort-column-line = "r-line.state-add-qnty"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Отклонение(факт)'  then DO:   assign       sort-column-line = substitute('dynamic-function(&1deviation-fact&1, &1&2&1, &1&3&1, &1&4&1)', chr(34), r-line.state-measure-qnty, r-line.state-add-qnty, r-line.system-qnty )     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Отклонение(измер)'  then DO:   assign       sort-column-line = substitute('dynamic-function(&1deviation-measure&1, &1&2&1, &1&3&1, &1&4&1)', chr(34), r-line.state-measure-qnty, r-line.state-add-qnty, r-line.system-qnty )     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Допустимое!отклонение'  then DO:    assign       sort-column-line = "r-line.tolerance"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Факт брутто'  then DO:    assign       sort-column-line = "r-line.state-brutto-qnty"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Измер. брутто'  then DO:    assign       sort-column-line = "r-line.brutto-qnty"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Плотность'  then DO:    assign       sort-column-line = "r-line.state-density"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Измер.!пл-ть'  then DO:    assign       sort-column-line = "r-line.density"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Факт!(ед. пост.)'  then DO:    assign       sort-column-line = "r-line.state-measure-cli-qnty"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Измер.!(ед. пост.)'  then DO:    assign       sort-column-line = "r-line.measure-cli-qnty"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Учет (ед.пост.)'  then DO:    assign       sort-column-line = "r-line.system-cli-qnty"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Нач.учет(е.п.)'  then DO:    assign       sort-column-line = "r-line.orig-system-cli-qnty"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Факт брутто!(ед.пост.)'  then DO:    assign       sort-column-line = "r-line.state-brutto-cli-qnty"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Измер. брутто! (ед.пост)'  then DO:    assign       sort-column-line = "r-line.brutto-cli-qnty"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Факт оборот'  then DO:    assign       sort-column-line = "r-line.state-mh-qnty"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Измер. оборот'  then DO:    assign       sort-column-line = "r-line.meas-mh-qnty"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Факт сумма!оборота'  then DO:    assign       sort-column-line = "r-line.state-am-qnty"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Измер. сумма!оборота'  then DO:    assign       sort-column-line = "r-line.meas-am-qnty"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Факт!кол-во наливов'  then DO:    assign       sort-column-line = "r-line.state-cf-qnty"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Измер.!кол-во наливов'  then DO:    assign       sort-column-line = "r-line.meas-cf-qnty"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Факт!общий уровень'  then DO:    assign       sort-column-line = "r-line.state-level-total"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Измер.!общий уровень'  then DO:    assign       sort-column-line = "r-line.level-total"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Факт!уровень топлива'  then DO:    assign       sort-column-line = "r-line.state-level-petrol"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Измер.!уровень топлива'  then DO:    assign       sort-column-line = "r-line.level-petrol"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Факт!уровень воды'  then DO:    assign       sort-column-line = "r-line.state-level-water"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Измер.!уровень воды'  then DO:    assign       sort-column-line = "r-line.level-water"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Температура'  then DO:    assign       sort-column-line = "r-line.state-temperature"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Измер.!темп.'  then DO:    assign       sort-column-line = "r-line.temperature"     .     run open-br-line in this-procedure ( input yes, input no, input '':U ).   . END.
    otherwise do:
      assign
        sort-column-line = ""
      .
      run open-br-line in this-procedure ( input yes, input no, input '':U ).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-line') then do:
          run mv-brw-defaultbr-line.
        end.
      if sort-labelbr-line <> "" then do:
        assign
          cur-clmnbr-line:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-line = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-line to recid p-recid no-error.
    apply "value-changed" to br-line in frame fr-D-doca0.
  end.
  apply "entry" to br-line in frame fr-D-doca0.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-line:
if cur-clmnbr-line = ? then do:
   run open-br-line in this-procedure ( input yes, input no, input '':U ).
end.
else do:
   assign re-querybr-line = yes.
   run sort-brbr-line
     (input (if available r-line
             then recid(r-line)
             else ?
            )
     ).
   assign re-querybr-line = no.
end.
end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-pump as INT EXTENT 18 no-undo.
DEF VAR varmvibr-pump       as INT no-undo.
DEF VAR varmvjbr-pump       as INT no-undo.
DEF VAR varmvkbr-pump       as INT no-undo.
DEF VAR varmvlbr-pump       as INT no-undo.
DEF VAR move-elementbr-pump as INT no-undo.
def var jjbr-pump           as int no-undo.
do varmvibr-pump = 1 to EXTENT(cur-clmn-numbr-pump):
  ASSIGN cur-clmn-numbr-pump[varmvibr-pump] = varmvibr-pump.
END.
RUN start-mv-clmnbr-pump.
PROCEDURE start-mv-clmnbr-pump:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-pump do:
  RUN re-move-clmnbr-pump ( 3, 18).
END.
ON ctrl-cursor-left OF BROWSE br-pump do:
  RUN re-move-clmnbr-pump (18, 3).
END.
PROCEDURE re-move-clmnbr-pump:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-pump = 1 TO EXTENT(cur-clmn-numbr-pump):
    if cur-clmn-numbr-pump[varmvibr-pump] = source-column THEN cur-clmn-numbr-pump[varmvibr-pump] = -1.
  END.
  if br-pump:MOVE-COLUMN(source-column, target-column) IN FRAME fr-D-doca0 then.
  if source-column > target-column THEN
  DO varmvjbr-pump = source-column - 1 to target-column BY -1:
    DO varmvibr-pump = 1 TO EXTENT(cur-clmn-numbr-pump):
        if cur-clmn-numbr-pump[varmvibr-pump] = varmvjbr-pump THEN DO:
          cur-clmn-numbr-pump[varmvibr-pump] = cur-clmn-numbr-pump[varmvibr-pump] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-pump = source-column + 1 to target-column:
    DO varmvibr-pump = 1 TO EXTENT(cur-clmn-numbr-pump):
      if cur-clmn-numbr-pump[varmvibr-pump] = varmvjbr-pump THEN DO:
        cur-clmn-numbr-pump[varmvibr-pump] = cur-clmn-numbr-pump[varmvibr-pump] - 1.
      END.
    END.
  END.
  DO varmvibr-pump = 1 TO EXTENT(cur-clmn-numbr-pump):
    if cur-clmn-numbr-pump[varmvibr-pump] = -1 THEN cur-clmn-numbr-pump[varmvibr-pump] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-pump:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 3 then do:
    return .
  end.
  DO varmvibr-pump = 1 TO EXTENT(cur-clmn-numbr-pump):
    if cur-clmn-numbr-pump[varmvibr-pump] = cur-clmn-loc THEN move-elementbr-pump = varmvibr-pump.
  END.
  RUN re-move-clmnbr-pump (cur-clmn-loc, 3).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-pump:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-pump = 3 to EXTENT(cur-clmn-numbr-pump):
    RUN re-move-clmnbr-pump (cur-clmn-numbr-pump[varmvlbr-pump], varmvlbr-pump).
  END.
  RUN start-mv-clmnbr-pump.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
def var sort-labelbr-pump   as character no-undo .
def var sort-clmnbr-pump    as handle    no-undo .
def var cur-clmnbr-pump     as handle    no-undo .
def var cur-clmn-locbr-pump as integer   no-undo .
def var re-querybr-pump     as logical   initial no no-undo .
on start-search, ctrl-o of br-pump in frame fr-D-doca0 do:
   run sort-brbr-pump
     (input (if available r-pump
             then recid(r-pump)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-pump :
  define input parameter p-recid as recid no-undo .
  if re-querybr-pump = no then do:
    assign
       cur-clmnbr-pump = br-pump:current-column in frame fr-D-doca0
    .
    if sort-clmnbr-pump <> ? then sort-clmnbr-pump:column-fgcolor = 0.
    if cur-clmnbr-pump = sort-clmnbr-pump then do:
      assign
         sort-labelbr-pump = ""
         sort-clmnbr-pump = ?
      .
     end.
     else do:
       assign
         sort-labelbr-pump = cur-clmnbr-pump:label
         sort-clmnbr-pump  = cur-clmnbr-pump
         sort-clmnbr-pump:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-pump = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-pump:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-pump then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-pump = cur-clmn-locbr-pump + 1
    .
  end.
  case sort-labelbr-pump:
        when 'ТРК'  then DO:    assign       sort-column-line = "r-pump.pump-code"     .     run open-br-pump in this-procedure ( input yes,                                                                          input no,                                                                          input '':U,                                                                          input r-line.pl-code,                                                                          input r-line.gds-code ).                                . END.
        when 'П'  then DO:    assign       sort-column-line = "r-pump.nozzle-code"     .     run open-br-pump in this-procedure ( input yes,                                                                          input no,                                                                          input '':U,                                                                          input r-line.pl-code,                                                                          input r-line.gds-code ).                                . END.
        when 'Факт оборот'  then DO:    assign       sort-column-line = "r-pump.state-mh-qnty"     .     run open-br-pump in this-procedure ( input yes,                                                                          input no,                                                                          input '':U,                                                                          input r-line.pl-code,                                                                          input r-line.gds-code ).                                . END.
        when 'Измер. оборот'  then DO:    assign       sort-column-line = "r-pump.meas-mh-qnty"     .     run open-br-pump in this-procedure ( input yes,                                                                          input no,                                                                          input '':U,                                                                          input r-line.pl-code,                                                                          input r-line.gds-code ).                                . END.
        when 'Факт сумма!оборота'  then DO:    assign       sort-column-line = "r-pump.state-am-qnty"     .     run open-br-pump in this-procedure ( input yes,                                                                          input no,                                                                          input '':U,                                                                          input r-line.pl-code,                                                                          input r-line.gds-code ).                                . END.
        when 'Измер. сумма!оборота'  then DO:    assign       sort-column-line = "r-pump.meas-am-qnty"     .     run open-br-pump in this-procedure ( input yes,                                                                          input no,                                                                          input '':U,                                                                          input r-line.pl-code,                                                                          input r-line.gds-code ).                                . END.
        when 'Факт!кол-во наливов'  then DO:    assign       sort-column-line = "r-pump.state-cf-qnty"     .     run open-br-pump in this-procedure ( input yes,                                                                          input no,                                                                          input '':U,                                                                          input r-line.pl-code,                                                                          input r-line.gds-code ).                                . END.
        when 'Измер.!кол-во наливов'  then DO:    assign       sort-column-line = "r-pump.meas-cf-qnty"     .     run open-br-pump in this-procedure ( input yes,                                                                          input no,                                                                          input '':U,                                                                          input r-line.pl-code,                                                                          input r-line.gds-code ).                                . END.
        when 'Показ. механического!счетчика'  then DO:    assign       sort-column-line = "r-pump.state-mh-cnt"     .     run open-br-pump in this-procedure ( input yes,                                                                          input no,                                                                          input '':U,                                                                          input r-line.pl-code,                                                                          input r-line.gds-code ).                                . END.
        when 'Измер. механического! счетчика'  then DO:    assign       sort-column-line = "r-pump.meas-mh-cnt"     .     run open-br-pump in this-procedure ( input yes,                                                                          input no,                                                                          input '':U,                                                                          input r-line.pl-code,                                                                          input r-line.gds-code ).                                . END.
        when 'Показ. электронного!счетчика'  then DO:    assign       sort-column-line = "r-pump.state-el-cnt"     .     run open-br-pump in this-procedure ( input yes,                                                                          input no,                                                                          input '':U,                                                                          input r-line.pl-code,                                                                          input r-line.gds-code ).                                . END.
        when 'Измер. электронного!счетчика'  then DO:    assign       sort-column-line = "r-pump.meas-el-cnt"     .     run open-br-pump in this-procedure ( input yes,                                                                          input no,                                                                          input '':U,                                                                          input r-line.pl-code,                                                                          input r-line.gds-code ).                                . END.
        when 'Сумма по показ.!счетчика'  then DO:    assign       sort-column-line = "r-pump.state-am-cnt"     .     run open-br-pump in this-procedure ( input yes,                                                                          input no,                                                                          input '':U,                                                                          input r-line.pl-code,                                                                          input r-line.gds-code ).                                . END.
        when 'Сумма по измер.!счетчика'  then DO:    assign       sort-column-line = "r-pump.meas-am-cnt"     .     run open-br-pump in this-procedure ( input yes,                                                                          input no,                                                                          input '':U,                                                                          input r-line.pl-code,                                                                          input r-line.gds-code ).                                . END.
        when 'Кол-во наливов!по показ. счетчика'  then DO:    assign       sort-column-line = "r-pump.state-cf-cnt"     .     run open-br-pump in this-procedure ( input yes,                                                                          input no,                                                                          input '':U,                                                                          input r-line.pl-code,                                                                          input r-line.gds-code ).                                . END.
        when 'Кол-во наливов!по  измер. счетчика'  then DO:    assign       sort-column-line = "r-pump.meas-cf-cnt"     .     run open-br-pump in this-procedure ( input yes,                                                                          input no,                                                                          input '':U,                                                                          input r-line.pl-code,                                                                          input r-line.gds-code ).                                . END.
        when 'Номер док-та!инвент. счетчика'  then DO:    assign       sort-column-line = "r-pump.icnt-code"     .     run open-br-pump in this-procedure ( input yes,                                                                          input no,                                                                          input '':U,                                                                          input r-line.pl-code,                                                                          input r-line.gds-code ).                                . END.
        when 'Сверка на начало'  then DO:    assign       sort-column-line = "r-pump.rvs-prev-code"     .     run open-br-pump in this-procedure ( input yes,                                                                          input no,                                                                          input '':U,                                                                          input r-line.pl-code,                                                                          input r-line.gds-code ).                                . END.
    otherwise do:
      assign
        sort-column-line = ""
      .
                                    run open-br-pump in this-procedure ( input yes,                                                                          input no,                                                                          input '':U,                                                                          input r-line.pl-code,                                                                          input r-line.gds-code ).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-pump') then do:
          run mv-brw-defaultbr-pump.
        end.
      if sort-labelbr-pump <> "" then do:
        assign
          cur-clmnbr-pump:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-pump = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-pump to recid p-recid no-error.
    apply "value-changed" to br-pump in frame fr-D-doca0.
  end.
  apply "entry" to br-pump in frame fr-D-doca0.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-pump:
if cur-clmnbr-pump = ? then do:
                                 run open-br-pump in this-procedure ( input yes,                                                                          input no,                                                                          input '':U,                                                                          input r-line.pl-code,                                                                          input r-line.gds-code ).
end.
else do:
   assign re-querybr-pump = yes.
   run sort-brbr-pump
     (input (if available r-pump
             then recid(r-pump)
             else ?
            )
     ).
   assign re-querybr-pump = no.
end.
end.
Main-Block:
do on error   undo Main-Block, leave Main-Block
   on end-key undo Main-Block, leave Main-Block :
  if p-mode <> 'ПРОСМОТР':U then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Неверное значение параметра вызова p-mode:" p-mode
    view-as alert-box error.
    undo Main-Block, return error.
  end.
  find ub.c-rvs-doc no-lock where recid( ub.c-rvs-doc ) = p-rid no-error.
  if not available ub.c-rvs-doc then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Не найдена КАРТОЧКА ИСТОРИИ СВЕРКИ."
    view-as alert-box error.
    undo Main-Block, return error.
  end.
  find ub.clients no-lock where
       ub.clients.obj-type = ub.c-rvs-doc.obj-type and
       ub.clients.obj-code = ub.c-rvs-doc.obj-code no-error.
  assign frame fr-D-doca0 :title =
    ( if available ub.clients then substring( ub.clients.obj-name, 1, 35 ) else (
      ub.c-rvs-doc.obj-type + " ":U + string( ub.c-rvs-doc.obj-code ) ) ) +
    ":   КАРТОЧКА ИСТОРИИ ИЗМЕНЕНИЯ ДОКУМЕНТА СВЕРКИ - " +
      ub.c-rvs-doc.status_  + " № " + ub.c-rvs-doc.rvs-code + "      - " + p-mode.
  if available ub.clients then do:
    display     ub.clients.obj-name with frame fr-D-doca0.
  end.
  else do:
    display ? @ ub.clients.obj-name with frame fr-D-doca0.
  end.
  disable all with frame fr-D-doca0.
  assign r-line.temperature :read-only in browse br-line = yes
         r-pump.rvs-prev-code :read-only in browse br-pump = yes.
  display ub.c-rvs-doc.obj-code
          ub.c-rvs-doc.obj-type
          ub.c-rvs-doc.doc-date
          ub.c-rvs-doc.state-measure-qnty
          ub.c-rvs-doc.measure-qnty
          ub.c-rvs-doc.system-qnty
          ub.c-rvs-doc.state-measure-cli-qnty
          ub.c-rvs-doc.measure-cli-qnty
          ub.c-rvs-doc.system-cli-qnty
          ub.c-rvs-doc.system-cli-avrg-qnty
          ub.c-rvs-doc.state-mh-qnty
          ub.c-rvs-doc.state-am-qnty
          ub.c-rvs-doc.state-cf-qnty
          ub.c-rvs-doc.out-code
          ub.c-rvs-doc.state-measure-tc-qnty
          ub.c-rvs-doc.measure-tc-qnty
          ub.c-rvs-doc.state-brutto-tc-qnty
          ub.c-rvs-doc.brutto-tc-qnty
  with frame fr-D-doca0.
  enable Btn_Exit b-help b-lkp Btn_Pump Btn_Notes br-line br-pump with frame fr-D-doca0.
  if p-mode = 'ПРОСМОТР':U then do: hide Btn_OK in frame fr-D-doca0. end.
  define variable v-ref-rec18   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame fr-D-doca0 ub.c-rvs-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display ub.c-rvs-doc.wrkr with frame fr-D-doca0.
  find cli-buf no-lock where cli-buf.obj-code = input frame fr-D-doca0 ub.c-rvs-doc.wrkr
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ ub.c-rvs-doc.wrkr cli-buf.obj-name @ wrkr-name with frame fr-D-doca0.
  end.
  else display ? @ ub.c-rvs-doc.wrkr ? @ wrkr-name with frame fr-D-doca0.
  define variable v-ref-rec19   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame fr-D-doca0 ub.c-rvs-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display ub.c-rvs-doc.agnt with frame fr-D-doca0.
  find cli-buf no-lock where cli-buf.obj-code = input frame fr-D-doca0 ub.c-rvs-doc.agnt
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ ub.c-rvs-doc.agnt cli-buf.obj-name @ agnt-name with frame fr-D-doca0.
  end.
  else display ? @ ub.c-rvs-doc.agnt ? @ agnt-name with frame fr-D-doca0.
  define variable v-ref-rec20   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame fr-D-doca0 ub.c-rvs-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display ub.c-rvs-doc.boss with frame fr-D-doca0.
  find cli-buf no-lock where cli-buf.obj-code = input frame fr-D-doca0 ub.c-rvs-doc.boss
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ ub.c-rvs-doc.boss cli-buf.obj-name @ boss-name with frame fr-D-doca0.
  end.
  else display ? @ ub.c-rvs-doc.boss ? @ boss-name with frame fr-D-doca0.
  run open-br-line in this-procedure ( input yes, input no, input '':U ).
  apply "VALUE-CHANGED":U to br-line in frame fr-D-doca0.
  if num-results( "br-line" ) > 0 then do: if br-line :refresh( ) then. end.
  wait-for go of frame fr-D-doca0.
end.
hide frame fr-D-doca0 no-pause.
procedure open-br-line :
  define input parameter p-open-query     as logical   no-undo.
  define input parameter p-find-next      as logical   no-undo.
  define input parameter p-find-condition as character no-undo.
  define variable l-query-was-opened as logical   no-undo.
  define variable sort-column-phrase as character no-undo.
  define variable p-proc-hand as handle    no-undo.
  define variable p-rvs-code  as character no-undo.
  define variable p-chip-num  as integer   no-undo.
  assign p-rvs-code  = ub.c-rvs-doc.rvs-code
         p-chip-num  = ub.c-rvs-doc.chip-num
         p-proc-hand = this-procedure :handle.
  case sort-column-line :
    when "":U then do: assign sort-column-phrase = "":U. end.
    otherwise      do: assign sort-column-phrase = "by " + sort-column-line. end.
  end case.
  define variable l-open-query as logical no-undo.
  find ub.clients no-lock where
       ub.clients.obj-type = ub.c-rvs-doc.obj-type and
       ub.clients.obj-code = ub.c-rvs-doc.obj-code no-error.
  assign frame fr-D-doca0 :title = ( if available ub.clients then substring( ub.clients.obj-name, 1, 35 )
                                        else ( ub.c-rvs-doc.obj-type + " ":U + string( ub.c-rvs-doc.obj-code ) ) ) +
     ":   КАРТОЧКА ИСТОРИИ ИЗМЕНЕНИЯ ДОКУМЕНТА СВЕРКИ - " + ub.c-rvs-doc.status_  + " № " + ub.c-rvs-doc.rvs-code +
     "      - " + p-mode.
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
                              "for each r-line no-lock"
      parameter-4-22 =
        (
          if ("                       r-line.rvs-code = p-rvs-code and                       r-line.chip-num = p-chip-num                     " + " " + where-phrase-22) <> ""
          then  substitute('r-line.rvs-code = &1&2&1 and r-line.chip-num = &3', chr(34), p-rvs-code, p-chip-num ) + " " + where-phrase-22
          else "true"
        )
      parameter-5-22 = (" " + "" + " " + ", first r-goods     no-lock where r-goods.gds-code = r-line.gds-code                                     , first r-place     no-lock where r-place.obj-type = r-line.obj-type and                                                                       r-place.obj-code = r-line.obj-code and                                                                       r-place.pl-code  = r-line.pl-code")
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
          ("                       r-line.rvs-code = p-rvs-code and                       r-line.chip-num = p-chip-num                     " + " " + where-phrase-22 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-line:handle
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
    open query br-line for each r-line no-lock
      where                        r-line.rvs-code = p-rvs-code and                       r-line.chip-num = p-chip-num
    , first r-goods     no-lock where r-goods.gds-code = r-line.gds-code                                     , first r-place     no-lock where r-place.obj-type = r-line.obj-type and                                                                       r-place.obj-code = r-line.obj-code and                                                                       r-place.pl-code  = r-line.pl-code
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( r-line )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-line:handle:get-buffer-handle(1) = (buffer r-line:handle) then do:
      assign
      parameter-2-22 = (if p-find-next then "true":u else "false":u )
      parameter-4-22 =
        "where ":u +  substitute('r-line.rvs-code = &1&2&1 and r-line.chip-num = &3', chr(34), p-rvs-code, p-chip-num ) + " ":u + where-phrase-22 + " ":u + p-find-condition + " " + ""
      parameter-5-22 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-line:handle
                          ,input rowid(r-line)
                          ,input logical(parameter-2-22)
                          ,input no-lock
                          ,input (buffer r-line:handle)
                          ,input parameter-4-22
                          ,input parameter-5-22
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-22 = (if p-find-next then "true":u else "false":u )
      parameter-3-22 =  "for each r-line no-lock"
      parameter-4-22 =
        (
          if ("                       r-line.rvs-code = p-rvs-code and                       r-line.chip-num = p-chip-num                     " + " " + where-phrase-22) <> ""
          then  substitute('r-line.rvs-code = &1&2&1 and r-line.chip-num = &3', chr(34), p-rvs-code, p-chip-num ) + " " + where-phrase-22
          else "true"
        )
      parameter-5-22 = (" " + "" + " " + ", first r-goods     no-lock where r-goods.gds-code = r-line.gds-code                                     , first r-place     no-lock where r-place.obj-type = r-line.obj-type and                                                                       r-place.obj-code = r-line.obj-code and                                                                       r-place.pl-code  = r-line.pl-code" + " " + p-find-condition)
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
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-line:handle
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
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  if p-open-query <> yes then do: reposition br-line to recid doc-rec no-error. end.
  apply "VALUE-CHANGED":U to br-line in frame fr-D-doca0.
  apply "ENTRY":U         to br-line in frame fr-D-doca0.
end procedure.
procedure open-br-pump :
  define input parameter p-open-query     as logical   no-undo.
  define input parameter p-find-next      as logical   no-undo.
  define input parameter p-find-condition as character no-undo.
  define input parameter p-pl-code        as integer   no-undo.
  define input parameter p-gds-code       as integer   no-undo.
  define variable l-query-was-opened as logical   no-undo.
  define variable sort-column-phrase as character no-undo.
  define variable p-proc-hand as handle    no-undo.
  define variable p-rvs-code  as character no-undo.
  define variable p-chip-num  as integer   no-undo.
  define variable p-obj-type  as character no-undo.
  define variable p-obj-code  as integer   no-undo.
  assign p-rvs-code  = ub.c-rvs-doc.rvs-code
         p-chip-num  = ub.c-rvs-doc.chip-num
         p-obj-type  = ub.c-rvs-doc.obj-type
         p-obj-code  = ub.c-rvs-doc.obj-code
         p-proc-hand = this-procedure :handle.
  case sort-column-pump :
    when "":U then do: assign sort-column-phrase = "":U. end.
    otherwise      do: assign sort-column-phrase = "by " + sort-column-pump. end.
  end case.
  define variable l-open-query as logical no-undo.
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
  (input filter-point0
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
                              "for each r-pump"
      parameter-4-24 =
        (
          if ("                       r-pump.rvs-code = p-rvs-code and                       r-pump.chip-num = p-chip-num and                       r-pump.obj-type = p-obj-type and                       r-pump.obj-code = p-obj-code and                       r-pump.pl-code  = p-pl-code  and                       r-pump.gds-code = p-gds-code                     " + " " + where-phrase-24) <> ""
          then  substitute('                      r-pump.rvs-code = &1&2&1 and                       r-pump.chip-num = &3 and                       r-pump.obj-type = &1&4&1 and                       r-pump.obj-code = &5 and                       r-pump.pl-code  = &6 and                       r-pump.gds-code = &7', chr(34), p-rvs-code, p-chip-num, p-obj-type, p-obj-code, p-pl-code, p-gds-code)                      + " " + where-phrase-24
          else "true"
        )
      parameter-5-24 = (" " + "" + " " + "")
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
          ("                       r-pump.rvs-code = p-rvs-code and                       r-pump.chip-num = p-chip-num and                       r-pump.obj-type = p-obj-type and                       r-pump.obj-code = p-obj-code and                       r-pump.pl-code  = p-pl-code  and                       r-pump.gds-code = p-gds-code                     " + " " + where-phrase-24 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-pump:handle
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
    open query br-pump for each r-pump
      where                        r-pump.rvs-code = p-rvs-code and                       r-pump.chip-num = p-chip-num and                       r-pump.obj-type = p-obj-type and                       r-pump.obj-code = p-obj-code and                       r-pump.pl-code  = p-pl-code  and                       r-pump.gds-code = p-gds-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( r-pump )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-pump:handle:get-buffer-handle(1) = (buffer r-pump:handle) then do:
      assign
      parameter-2-24 = (if p-find-next then "true":u else "false":u )
      parameter-4-24 =
        "where ":u +  substitute('                      r-pump.rvs-code = &1&2&1 and                       r-pump.chip-num = &3 and                       r-pump.obj-type = &1&4&1 and                       r-pump.obj-code = &5 and                       r-pump.pl-code  = &6 and                       r-pump.gds-code = &7', chr(34), p-rvs-code, p-chip-num, p-obj-type, p-obj-code, p-pl-code, p-gds-code)                      + " ":u + where-phrase-24 + " ":u + p-find-condition + " " + ""
      parameter-5-24 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-pump:handle
                          ,input rowid(r-pump)
                          ,input logical(parameter-2-24)
                          ,input no-lock
                          ,input (buffer r-pump:handle)
                          ,input parameter-4-24
                          ,input parameter-5-24
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-24 = (if p-find-next then "true":u else "false":u )
      parameter-3-24 =  "for each r-pump"
      parameter-4-24 =
        (
          if ("                       r-pump.rvs-code = p-rvs-code and                       r-pump.chip-num = p-chip-num and                       r-pump.obj-type = p-obj-type and                       r-pump.obj-code = p-obj-code and                       r-pump.pl-code  = p-pl-code  and                       r-pump.gds-code = p-gds-code                     " + " " + where-phrase-24) <> ""
          then  substitute('                      r-pump.rvs-code = &1&2&1 and                       r-pump.chip-num = &3 and                       r-pump.obj-type = &1&4&1 and                       r-pump.obj-code = &5 and                       r-pump.pl-code  = &6 and                       r-pump.gds-code = &7', chr(34), p-rvs-code, p-chip-num, p-obj-type, p-obj-code, p-pl-code, p-gds-code)                      + " " + where-phrase-24
          else "true"
        )
      parameter-5-24 = (" " + "" + " " + "" + " " + p-find-condition)
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
                          ,input query br-pump:handle
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
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  if p-open-query <> yes then do: reposition br-pump to recid doc-rec no-error. end.
  apply "VALUE-CHANGED":U to br-pump in frame fr-D-doca0.
end procedure.
procedure get-dev-fact :
    define input parameter p-state-measure-qnty as decimal          no-undo.
    define input parameter p-state-add-qnty     as decimal          no-undo.
    define input parameter p-system-qnty        as decimal          no-undo.
    define output parameter p-qty               as decimal          no-undo.
  assign p-qty = p-state-measure-qnty + p-state-add-qnty - p-system-qnty.
end procedure.
procedure get-dev-meas :
  define        parameter buffer loc-buf for ub.c-rvs-line.
  define output parameter        p-qty   as  decimal no-undo.
  assign p-qty = loc-buf.measure-qnty + loc-buf.state-add-qnty - loc-buf.system-qnty.
end procedure.
procedure proc-lookup-pump :
  define buffer buf_goods for ub.goods.
  if not available r-pump then do:
    message "Неправильный выбор строки." view-as alert-box error.
    return error.
  end.
  assign rvs-line-rec = ( if available r-line then recid( r-line ) else ? )
         rvs-pump-rec = recid( r-pump ).
  find first buf_goods where buf_goods.gds-code = r-pump.gds-code no-lock.
  run str/rvscpump.w ( input 'ПРОСМОТР':U, input-output rvs-pump-rec ).
  find ub.c-rvs-doc where recid( ub.c-rvs-doc ) = p-rid.
end procedure.
procedure proc-lookup-line :
  define buffer buf_goods for ub.goods.
  if not available r-line then do:
    message "Неправильный выбор строки." view-as alert-box error.
    return error.
  end.
  assign rvs-line-rec = recid( r-line )
         rvs-pump-rec = ( if available r-pump then recid( r-pump ) else ? ).
  find first buf_goods no-lock where buf_goods.gds-code = r-line.gds-code.
  run str/rvscline.w ( input 'ПРОСМОТР':U, input-output rvs-line-rec ).
  find ub.c-rvs-doc no-lock where recid( ub.c-rvs-doc ) = p-rid.
end procedure.
