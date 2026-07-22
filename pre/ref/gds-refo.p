block-level on error undo, throw.
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define input  parameter a-n-c       as character no-undo .
define input  parameter NameContext as character no-undo .
define input  parameter rs-sort     as character no-undo .
define input  parameter g-cond      as character no-undo .
define input  parameter g-list      as character no-undo .
define input  parameter g-stat      as character no-undo .
define input  parameter g-grp       like ub.goods.grp-name no-undo.
define input  parameter pobj-type   like ub.clients.obj-type no-undo.
define input  parameter pobj-code   like ub.clients.obj-code no-undo.
define parameter buffer g-producer for ub.clients.
define parameter buffer cur-obj for ub.clients.
define output parameter for-title as character no-undo .
define input  parameter filter-point as character no-undo .
define input  parameter filter-point0 as character no-undo .
define input  parameter sort-column-name as character no-undo .
define output parameter p-filter-name   as character  no-undo .
define input-output parameter v-doc-rec as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gds-refo.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gds-refo.p $":U .
define variable vss-description as character no-undo init "Открытие запроса в справочнике товаров".
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
    assign
      p-vss-parameters = substitute('&1|&2':u,substitute('&1|&2|&3|&4|&5':u,a-n-c,NameContext,rs-sort,g-cond,g-list),substitute('&1|&2|&3|&4':u,g-stat,g-grp,pobj-type,pobj-code))
    .
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
DEFINE SHARED buffer gob-doc FOR ub.gds-obj.
DEFINE SHARED buffer goo-doc FOR ub.goods.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gds-attr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
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
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
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
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable l-query-was-opened as logical no-undo .
define variable sort-column-phrase as character no-undo .
PROCEDURE Set-filter-name :
define input parameter v-filter-name as character no-undo .
  assign
  p-filter-name = v-filter-name
  .
END PROCEDURE.
DEFINE SHARED QUERY br-gds FOR goo-doc  SCROLLING.
define variable l-open-query as logical   no-undo .
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
define variable v-list-unit-name as character no-undo.
define variable v-list-gds-code-lgas as character no-undo.
define variable v-attr-type as character no-undo.
define variable v-attr-value as character no-undo.
CASE g-list :
  when "ptrl" then do:
    if a-n-c <> "context" OR NameContext = "" then do:
      for-title = "ВСЕ товары".
    for each ub.units no-lock where lookup( 'топ':U, ub.units.type) > 0:
      v-list-unit-name = v-list-unit-name + ub.units.unit-name + chr(4).
    end.
    for each ub.goods no-lock where lookup (ub.goods.unit-base, v-list-unit-name, chr(4)) > 0:
      run gds-attr-value in this-procedure
        (  input ub.goods.gds-code
          ,input 'fuel-type':U
          ,output v-attr-value
          ,output v-attr-type
         ) .
      if v-attr-value = "lgas" then
      do:
        v-list-gds-code-lgas = v-list-gds-code-lgas + string (ub.goods.gds-code) + chr(4).
      end.
    end.
    v-list-unit-name = right-trim(v-list-unit-name,chr(4)).
    v-list-gds-code-lgas = right-trim(v-list-gds-code-lgas,chr(4)).
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-6  as logical   no-undo .
define variable  l-filter-open-6    as logical   .
define variable  flt-rec-6       as recid     no-undo .
define variable  filter-name-6      as character no-undo .
define variable  where-phrase-6     as character no-undo .
define variable  sort-phrase-6      as character no-undo .
define variable  where-phrase-rus-6 as character no-undo .
define variable  sort-phrase-rus-6  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-6
  ,output filter-name-6
  ,output where-phrase-6
  ,output sort-phrase-6
  ,output where-phrase-rus-6
  ,output sort-phrase-rus-6
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-6
      ) no-error .
  assign
    l-filter-open-6 = false
  .
  if flt-rec-6 <> ?
  then do:
    define variable  parameter-2-6 as character no-undo .
    define variable  parameter-3-6 as character no-undo .
    define variable  parameter-4-6 as character no-undo .
    define variable  parameter-5-6 as character no-undo .
    define variable  parameter-6-6 as character no-undo .
    define variable  parameter-7-6 as character no-undo .
      assign
      parameter-3-6 =
                              "FOR EACH goo-doc no-lock"
      parameter-4-6 =
        (
          if (" goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " " + where-phrase-6) <> ""
          then " goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " " + where-phrase-6
          else "true"
        )
      parameter-5-6 = (" " + "" + " " + "")
      parameter-6-6 = if sort-phrase-6 = ''
                           then
        (
        " " + "  " +
        " " + " by goo-doc.artic                       BY GOO-DOC.PROD-TYPE                       BY goo-doc.prod-code "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-6
        )
      parameter-7-6 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-6 =
          (" goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " " + where-phrase-6 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-6
                          ,input parameter-4-6
                          ,input parameter-5-6
                          ,input parameter-6-6
                          ,input parameter-7-6
                          )
      .
      assign
        l-filter-open-6 = true
      .
    end.
    if l-filter-open-6 = false then do:
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
  if l-filter-open-6 = false then do:
    OPEN QUERY br-gds FOR EACH goo-doc no-lock
      where  goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0
       by goo-doc.artic                       BY GOO-DOC.PROD-TYPE                       BY goo-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( goo-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer goo-doc:handle) then do:
      assign
      parameter-2-6 = (if p-find-next then "true":u else "false":u )
      parameter-4-6 =
        "where ":u + " goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " ":u + where-phrase-6 + " ":u + p-find-condition + " " + ""
      parameter-5-6 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(goo-doc)
                          ,input logical(parameter-2-6)
                          ,input no-lock
                          ,input (buffer goo-doc:handle)
                          ,input parameter-4-6
                          ,input parameter-5-6
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-6 = (if p-find-next then "true":u else "false":u )
      parameter-3-6 =  "FOR EACH goo-doc no-lock"
      parameter-4-6 =
        (
          if (" goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " " + where-phrase-6) <> ""
          then " goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " " + where-phrase-6
          else "true"
        )
      parameter-5-6 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-6 = if sort-phrase-6 = ''
                           then
        (
        " " + "  " +
        " " + " by goo-doc.artic                       BY GOO-DOC.PROD-TYPE                       BY goo-doc.prod-code "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-6
        )
      parameter-7-6 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-6)
                          ,input no-lock
                          ,input parameter-3-6
                          ,input parameter-4-6
                          ,input parameter-5-6
                          ,input parameter-6-6
                          ,input parameter-7-6
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
  when "lgas" then do:
    if a-n-c <> "context" OR NameContext = "" then do:
      for-title = "ВСЕ товары".
    for each ub.units no-lock where lookup( 'топ':U, ub.units.type) > 0:
      v-list-unit-name = v-list-unit-name + ub.units.unit-name + chr(4).
    end.
    for each ub.goods no-lock where lookup (ub.goods.unit-base, v-list-unit-name, chr(4)) > 0:
      run gds-attr-value in this-procedure
        (  input ub.goods.gds-code
          ,input 'fuel-type':U
          ,output v-attr-value
          ,output v-attr-type
         ) .
      if v-attr-value = "lgas" then
      do:
        v-list-gds-code-lgas = v-list-gds-code-lgas + string (ub.goods.gds-code) + chr(4).
      end.
    end.
    v-list-unit-name = right-trim(v-list-unit-name,chr(4)).
    v-list-gds-code-lgas = right-trim(v-list-gds-code-lgas,chr(4)).
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-8  as logical   no-undo .
define variable  l-filter-open-8    as logical   .
define variable  flt-rec-8       as recid     no-undo .
define variable  filter-name-8      as character no-undo .
define variable  where-phrase-8     as character no-undo .
define variable  sort-phrase-8      as character no-undo .
define variable  where-phrase-rus-8 as character no-undo .
define variable  sort-phrase-rus-8  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-8
  ,output filter-name-8
  ,output where-phrase-8
  ,output sort-phrase-8
  ,output where-phrase-rus-8
  ,output sort-phrase-rus-8
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-8
      ) no-error .
  assign
    l-filter-open-8 = false
  .
  if flt-rec-8 <> ?
  then do:
    define variable  parameter-2-8 as character no-undo .
    define variable  parameter-3-8 as character no-undo .
    define variable  parameter-4-8 as character no-undo .
    define variable  parameter-5-8 as character no-undo .
    define variable  parameter-6-8 as character no-undo .
    define variable  parameter-7-8 as character no-undo .
      assign
      parameter-3-8 =
                              "FOR EACH goo-doc no-lock"
      parameter-4-8 =
        (
          if (" goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " " + where-phrase-8) <> ""
          then " goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " " + where-phrase-8
          else "true"
        )
      parameter-5-8 = (" " + "" + " " + "")
      parameter-6-8 = if sort-phrase-8 = ''
                           then
        (
        " " + "  " +
        " " + " by goo-doc.artic                       BY GOO-DOC.PROD-TYPE                       BY goo-doc.prod-code "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-8
        )
      parameter-7-8 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-8 =
          (" goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " " + where-phrase-8 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-8
                          ,input parameter-4-8
                          ,input parameter-5-8
                          ,input parameter-6-8
                          ,input parameter-7-8
                          )
      .
      assign
        l-filter-open-8 = true
      .
    end.
    if l-filter-open-8 = false then do:
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
  if l-filter-open-8 = false then do:
    OPEN QUERY br-gds FOR EACH goo-doc no-lock
      where  goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0
       by goo-doc.artic                       BY GOO-DOC.PROD-TYPE                       BY goo-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( goo-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer goo-doc:handle) then do:
      assign
      parameter-2-8 = (if p-find-next then "true":u else "false":u )
      parameter-4-8 =
        "where ":u + " goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " ":u + where-phrase-8 + " ":u + p-find-condition + " " + ""
      parameter-5-8 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(goo-doc)
                          ,input logical(parameter-2-8)
                          ,input no-lock
                          ,input (buffer goo-doc:handle)
                          ,input parameter-4-8
                          ,input parameter-5-8
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-8 = (if p-find-next then "true":u else "false":u )
      parameter-3-8 =  "FOR EACH goo-doc no-lock"
      parameter-4-8 =
        (
          if (" goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " " + where-phrase-8) <> ""
          then " goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " " + where-phrase-8
          else "true"
        )
      parameter-5-8 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-8 = if sort-phrase-8 = ''
                           then
        (
        " " + "  " +
        " " + " by goo-doc.artic                       BY GOO-DOC.PROD-TYPE                       BY goo-doc.prod-code "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-8
        )
      parameter-7-8 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-8)
                          ,input no-lock
                          ,input parameter-3-8
                          ,input parameter-4-8
                          ,input parameter-5-8
                          ,input parameter-6-8
                          ,input parameter-7-8
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
  when "ptrlsug" then do:
    if a-n-c <> "context" OR NameContext = "" then do:
      for-title = "ВСЕ товары".
    for each ub.units no-lock where lookup( 'топ':U, ub.units.type) > 0:
      v-list-unit-name = v-list-unit-name + ub.units.unit-name + chr(4).
    end.
    for each ub.goods no-lock where lookup (ub.goods.unit-base, v-list-unit-name, chr(4)) > 0:
      run gds-attr-value in this-procedure
        (  input ub.goods.gds-code
          ,input 'fuel-type':U
          ,output v-attr-value
          ,output v-attr-type
         ) .
      if v-attr-value = "metan" then
      do:
        v-list-gds-code-lgas = v-list-gds-code-lgas + string (ub.goods.gds-code) + chr(4).
      end.
    end.
    v-list-unit-name = right-trim(v-list-unit-name,chr(4)).
    v-list-gds-code-lgas = right-trim(v-list-gds-code-lgas,chr(4)).
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-10  as logical   no-undo .
define variable  l-filter-open-10    as logical   .
define variable  flt-rec-10       as recid     no-undo .
define variable  filter-name-10      as character no-undo .
define variable  where-phrase-10     as character no-undo .
define variable  sort-phrase-10      as character no-undo .
define variable  where-phrase-rus-10 as character no-undo .
define variable  sort-phrase-rus-10  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-10
  ,output filter-name-10
  ,output where-phrase-10
  ,output sort-phrase-10
  ,output where-phrase-rus-10
  ,output sort-phrase-rus-10
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-10
      ) no-error .
  assign
    l-filter-open-10 = false
  .
  if flt-rec-10 <> ?
  then do:
    define variable  parameter-2-10 as character no-undo .
    define variable  parameter-3-10 as character no-undo .
    define variable  parameter-4-10 as character no-undo .
    define variable  parameter-5-10 as character no-undo .
    define variable  parameter-6-10 as character no-undo .
    define variable  parameter-7-10 as character no-undo .
      assign
      parameter-3-10 =
                              "FOR EACH goo-doc no-lock"
      parameter-4-10 =
        (
          if (" goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " " + where-phrase-10) <> ""
          then " goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " " + where-phrase-10
          else "true"
        )
      parameter-5-10 = (" " + "" + " " + "")
      parameter-6-10 = if sort-phrase-10 = ''
                           then
        (
        " " + "  " +
        " " + " by goo-doc.artic                       BY GOO-DOC.PROD-TYPE                       BY goo-doc.prod-code "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-10
        )
      parameter-7-10 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-10 =
          (" goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " " + where-phrase-10 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-10
                          ,input parameter-4-10
                          ,input parameter-5-10
                          ,input parameter-6-10
                          ,input parameter-7-10
                          )
      .
      assign
        l-filter-open-10 = true
      .
    end.
    if l-filter-open-10 = false then do:
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
  if l-filter-open-10 = false then do:
    OPEN QUERY br-gds FOR EACH goo-doc no-lock
      where  goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0
       by goo-doc.artic                       BY GOO-DOC.PROD-TYPE                       BY goo-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( goo-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer goo-doc:handle) then do:
      assign
      parameter-2-10 = (if p-find-next then "true":u else "false":u )
      parameter-4-10 =
        "where ":u + " goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " ":u + where-phrase-10 + " ":u + p-find-condition + " " + ""
      parameter-5-10 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(goo-doc)
                          ,input logical(parameter-2-10)
                          ,input no-lock
                          ,input (buffer goo-doc:handle)
                          ,input parameter-4-10
                          ,input parameter-5-10
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-10 = (if p-find-next then "true":u else "false":u )
      parameter-3-10 =  "FOR EACH goo-doc no-lock"
      parameter-4-10 =
        (
          if (" goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " " + where-phrase-10) <> ""
          then " goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " " + where-phrase-10
          else "true"
        )
      parameter-5-10 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-10 = if sort-phrase-10 = ''
                           then
        (
        " " + "  " +
        " " + " by goo-doc.artic                       BY GOO-DOC.PROD-TYPE                       BY goo-doc.prod-code "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-10
        )
      parameter-7-10 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-10)
                          ,input no-lock
                          ,input parameter-3-10
                          ,input parameter-4-10
                          ,input parameter-5-10
                          ,input parameter-6-10
                          ,input parameter-7-10
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
  when "only-np" then do:
    if a-n-c <> "context" OR NameContext = "" then do:
      for-title = "ВСЕ товары".
    for each ub.units no-lock where lookup( 'топ':U, ub.units.type) > 0:
      v-list-unit-name = v-list-unit-name + ub.units.unit-name + chr(4).
    end.
    for each ub.goods no-lock where lookup (ub.goods.unit-base, v-list-unit-name, chr(4)) > 0:
      run gds-attr-value in this-procedure
        (  input ub.goods.gds-code
          ,input 'fuel-type':U
          ,output v-attr-value
          ,output v-attr-type
         ) .
      if v-attr-value = "lgas"
      or v-attr-value = "metan"
      or v-attr-value = "propan"
      then do:
        v-list-gds-code-lgas = v-list-gds-code-lgas + string (ub.goods.gds-code) + chr(4).
      end.
    end.
    v-list-unit-name = right-trim(v-list-unit-name,chr(4)).
    v-list-gds-code-lgas = right-trim(v-list-gds-code-lgas,chr(4)).
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-12  as logical   no-undo .
define variable  l-filter-open-12    as logical   .
define variable  flt-rec-12       as recid     no-undo .
define variable  filter-name-12      as character no-undo .
define variable  where-phrase-12     as character no-undo .
define variable  sort-phrase-12      as character no-undo .
define variable  where-phrase-rus-12 as character no-undo .
define variable  sort-phrase-rus-12  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-12
  ,output filter-name-12
  ,output where-phrase-12
  ,output sort-phrase-12
  ,output where-phrase-rus-12
  ,output sort-phrase-rus-12
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-12
      ) no-error .
  assign
    l-filter-open-12 = false
  .
  if flt-rec-12 <> ?
  then do:
    define variable  parameter-2-12 as character no-undo .
    define variable  parameter-3-12 as character no-undo .
    define variable  parameter-4-12 as character no-undo .
    define variable  parameter-5-12 as character no-undo .
    define variable  parameter-6-12 as character no-undo .
    define variable  parameter-7-12 as character no-undo .
      assign
      parameter-3-12 =
                              "FOR EACH goo-doc no-lock"
      parameter-4-12 =
        (
          if (" goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " " + where-phrase-12) <> ""
          then " goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " " + where-phrase-12
          else "true"
        )
      parameter-5-12 = (" " + "" + " " + "")
      parameter-6-12 = if sort-phrase-12 = ''
                           then
        (
        " " + "  " +
        " " + " by goo-doc.artic                       BY GOO-DOC.PROD-TYPE                       BY goo-doc.prod-code "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-12
        )
      parameter-7-12 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-12 =
          (" goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " " + where-phrase-12 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-12
                          ,input parameter-4-12
                          ,input parameter-5-12
                          ,input parameter-6-12
                          ,input parameter-7-12
                          )
      .
      assign
        l-filter-open-12 = true
      .
    end.
    if l-filter-open-12 = false then do:
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
  if l-filter-open-12 = false then do:
    OPEN QUERY br-gds FOR EACH goo-doc no-lock
      where  goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0
       by goo-doc.artic                       BY GOO-DOC.PROD-TYPE                       BY goo-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( goo-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer goo-doc:handle) then do:
      assign
      parameter-2-12 = (if p-find-next then "true":u else "false":u )
      parameter-4-12 =
        "where ":u + " goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " ":u + where-phrase-12 + " ":u + p-find-condition + " " + ""
      parameter-5-12 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(goo-doc)
                          ,input logical(parameter-2-12)
                          ,input no-lock
                          ,input (buffer goo-doc:handle)
                          ,input parameter-4-12
                          ,input parameter-5-12
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-12 = (if p-find-next then "true":u else "false":u )
      parameter-3-12 =  "FOR EACH goo-doc no-lock"
      parameter-4-12 =
        (
          if (" goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " " + where-phrase-12) <> ""
          then " goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " " + where-phrase-12
          else "true"
        )
      parameter-5-12 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-12 = if sort-phrase-12 = ''
                           then
        (
        " " + "  " +
        " " + " by goo-doc.artic                       BY GOO-DOC.PROD-TYPE                       BY goo-doc.prod-code "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-12
        )
      parameter-7-12 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-12)
                          ,input no-lock
                          ,input parameter-3-12
                          ,input parameter-4-12
                          ,input parameter-5-12
                          ,input parameter-6-12
                          ,input parameter-7-12
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
  when 'все':U then do:
      CASE g-stat :
        when 'текущие':U then do:
          if a-n-c <> "context" OR NameContext = "" then do:
            for-title = "Все текущие товары".
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-14  as logical   no-undo .
define variable  l-filter-open-14    as logical   .
define variable  flt-rec-14       as recid     no-undo .
define variable  filter-name-14      as character no-undo .
define variable  where-phrase-14     as character no-undo .
define variable  sort-phrase-14      as character no-undo .
define variable  where-phrase-rus-14 as character no-undo .
define variable  sort-phrase-rus-14  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-14
  ,output filter-name-14
  ,output where-phrase-14
  ,output sort-phrase-14
  ,output where-phrase-rus-14
  ,output sort-phrase-rus-14
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-14
      ) no-error .
  assign
    l-filter-open-14 = false
  .
  if flt-rec-14 <> ?
  then do:
    define variable  parameter-2-14 as character no-undo .
    define variable  parameter-3-14 as character no-undo .
    define variable  parameter-4-14 as character no-undo .
    define variable  parameter-5-14 as character no-undo .
    define variable  parameter-6-14 as character no-undo .
    define variable  parameter-7-14 as character no-undo .
      assign
      parameter-3-14 =
                              "FOR EACH goo-doc no-lock"
      parameter-4-14 =
        (
          if (" goo-doc.stts = 0 " + " " + where-phrase-14) <> ""
          then " goo-doc.stts = 0 " + " " + where-phrase-14
          else "true"
        )
      parameter-5-14 = (" " + "" + " " + "")
      parameter-6-14 = if sort-phrase-14 = ''
                           then
        (
        " " + "  " +
        " " + " by goo-doc.artic                             BY GOO-DOC.PROD-TYPE                             BY goo-doc.prod-code "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-14
        )
      parameter-7-14 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-14 =
          (" goo-doc.stts = 0 " + " " + where-phrase-14 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-14
                          ,input parameter-4-14
                          ,input parameter-5-14
                          ,input parameter-6-14
                          ,input parameter-7-14
                          )
      .
      assign
        l-filter-open-14 = true
      .
    end.
    if l-filter-open-14 = false then do:
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
  if l-filter-open-14 = false then do:
    OPEN QUERY br-gds FOR EACH goo-doc no-lock
      where  goo-doc.stts = 0
       by goo-doc.artic                             BY GOO-DOC.PROD-TYPE                             BY goo-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( goo-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer goo-doc:handle) then do:
      assign
      parameter-2-14 = (if p-find-next then "true":u else "false":u )
      parameter-4-14 =
        "where ":u + " goo-doc.stts = 0 " + " ":u + where-phrase-14 + " ":u + p-find-condition + " " + ""
      parameter-5-14 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(goo-doc)
                          ,input logical(parameter-2-14)
                          ,input no-lock
                          ,input (buffer goo-doc:handle)
                          ,input parameter-4-14
                          ,input parameter-5-14
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-14 = (if p-find-next then "true":u else "false":u )
      parameter-3-14 =  "FOR EACH goo-doc no-lock"
      parameter-4-14 =
        (
          if (" goo-doc.stts = 0 " + " " + where-phrase-14) <> ""
          then " goo-doc.stts = 0 " + " " + where-phrase-14
          else "true"
        )
      parameter-5-14 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-14 = if sort-phrase-14 = ''
                           then
        (
        " " + "  " +
        " " + " by goo-doc.artic                             BY GOO-DOC.PROD-TYPE                             BY goo-doc.prod-code "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-14
        )
      parameter-7-14 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-14)
                          ,input no-lock
                          ,input parameter-3-14
                          ,input parameter-4-14
                          ,input parameter-5-14
                          ,input parameter-6-14
                          ,input parameter-7-14
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
            for-title = substitute("Вce ТЕКУЩИЕ товары, содержащие в названии &1"
                                   , trim( NameContext, "*" ) ).
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
  then do:
    define variable  parameter-2-16 as character no-undo .
    define variable  parameter-3-16 as character no-undo .
    define variable  parameter-4-16 as character no-undo .
    define variable  parameter-5-16 as character no-undo .
    define variable  parameter-6-16 as character no-undo .
    define variable  parameter-7-16 as character no-undo .
      assign
      parameter-3-16 =
                              "FOR EACH goo-doc no-lock"
      parameter-4-16 =
        (
          if (" goo-doc.stts = 0  and goo-doc.gds-name contains NameContext " + " " + where-phrase-16) <> ""
          then  substitute('goo-doc.stts = 0  and goo-doc.gds-name contains &1&2&1', chr(34), NameContext ) + " " + where-phrase-16
          else "true"
        )
      parameter-5-16 = (" " + "" + " " + "")
      parameter-6-16 = if sort-phrase-16 = ''
                           then
        (
        " " + "  " +
        " " + " by goo-doc.artic                             BY GOO-DOC.PROD-TYPE                             BY goo-doc.prod-code "
        )
                           else
        (
        " " + "  " +
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
          (" goo-doc.stts = 0  and goo-doc.gds-name contains NameContext " + " " + where-phrase-16 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
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
    OPEN QUERY br-gds FOR EACH goo-doc no-lock
      where  goo-doc.stts = 0  and goo-doc.gds-name contains NameContext
       by goo-doc.artic                             BY GOO-DOC.PROD-TYPE                             BY goo-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( goo-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer goo-doc:handle) then do:
      assign
      parameter-2-16 = (if p-find-next then "true":u else "false":u )
      parameter-4-16 =
        "where ":u +  substitute('goo-doc.stts = 0  and goo-doc.gds-name contains &1&2&1', chr(34), NameContext ) + " ":u + where-phrase-16 + " ":u + p-find-condition + " " + ""
      parameter-5-16 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(goo-doc)
                          ,input logical(parameter-2-16)
                          ,input no-lock
                          ,input (buffer goo-doc:handle)
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
      parameter-3-16 =  "FOR EACH goo-doc no-lock"
      parameter-4-16 =
        (
          if (" goo-doc.stts = 0  and goo-doc.gds-name contains NameContext " + " " + where-phrase-16) <> ""
          then  substitute('goo-doc.stts = 0  and goo-doc.gds-name contains &1&2&1', chr(34), NameContext ) + " " + where-phrase-16
          else "true"
        )
      parameter-5-16 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-16 = if sort-phrase-16 = ''
                           then
        (
        " " + "  " +
        " " + " by goo-doc.artic                             BY GOO-DOC.PROD-TYPE                             BY goo-doc.prod-code "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-16
        )
      parameter-7-16 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
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
          end.
        end.
        when 'все':U then do:
          if a-n-c <> "context" OR NameContext = "" then do:
            for-title = "ВСЕ товары".
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
  then do:
    define variable  parameter-2-18 as character no-undo .
    define variable  parameter-3-18 as character no-undo .
    define variable  parameter-4-18 as character no-undo .
    define variable  parameter-5-18 as character no-undo .
    define variable  parameter-6-18 as character no-undo .
    define variable  parameter-7-18 as character no-undo .
      assign
      parameter-3-18 =
                              "FOR EACH goo-doc no-lock"
      parameter-4-18 =
        (
          if (" true " + " " + where-phrase-18) <> ""
          then " true " + " " + where-phrase-18
          else "true"
        )
      parameter-5-18 = (" " + "" + " " + "")
      parameter-6-18 = if sort-phrase-18 = ''
                           then
        (
        " " + "  " +
        " " + " by goo-doc.artic                             BY GOO-DOC.PROD-TYPE                             BY goo-doc.prod-code "
        )
                           else
        (
        " " + "  " +
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
          (" true " + " " + where-phrase-18 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
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
    OPEN QUERY br-gds FOR EACH goo-doc no-lock
      where  true
       by goo-doc.artic                             BY GOO-DOC.PROD-TYPE                             BY goo-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( goo-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer goo-doc:handle) then do:
      assign
      parameter-2-18 = (if p-find-next then "true":u else "false":u )
      parameter-4-18 =
        "where ":u + " true " + " ":u + where-phrase-18 + " ":u + p-find-condition + " " + ""
      parameter-5-18 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(goo-doc)
                          ,input logical(parameter-2-18)
                          ,input no-lock
                          ,input (buffer goo-doc:handle)
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
      parameter-3-18 =  "FOR EACH goo-doc no-lock"
      parameter-4-18 =
        (
          if (" true " + " " + where-phrase-18) <> ""
          then " true " + " " + where-phrase-18
          else "true"
        )
      parameter-5-18 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-18 = if sort-phrase-18 = ''
                           then
        (
        " " + "  " +
        " " + " by goo-doc.artic                             BY GOO-DOC.PROD-TYPE                             BY goo-doc.prod-code "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-18
        )
      parameter-7-18 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
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
          end.
          else do:
            for-title = substitute("ВСЕ товары, содержащие в названии &1"
                                  , trim( NameContext, "*" ) ).
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
  then do:
    define variable  parameter-2-20 as character no-undo .
    define variable  parameter-3-20 as character no-undo .
    define variable  parameter-4-20 as character no-undo .
    define variable  parameter-5-20 as character no-undo .
    define variable  parameter-6-20 as character no-undo .
    define variable  parameter-7-20 as character no-undo .
      assign
      parameter-3-20 =
                              "FOR EACH goo-doc no-lock"
      parameter-4-20 =
        (
          if (" goo-doc.gds-name contains NameContext " + " " + where-phrase-20) <> ""
          then  substitute('goo-doc.gds-name contains &1&2&1', chr(34), NameContext ) + " " + where-phrase-20
          else "true"
        )
      parameter-5-20 = (" " + "" + " " + "")
      parameter-6-20 = if sort-phrase-20 = ''
                           then
        (
        " " + "  " +
        " " + " by goo-doc.artic                             BY GOO-DOC.PROD-TYPE                             BY goo-doc.prod-code "
        )
                           else
        (
        " " + "  " +
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
          (" goo-doc.gds-name contains NameContext " + " " + where-phrase-20 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
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
    OPEN QUERY br-gds FOR EACH goo-doc no-lock
      where  goo-doc.gds-name contains NameContext
       by goo-doc.artic                             BY GOO-DOC.PROD-TYPE                             BY goo-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( goo-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer goo-doc:handle) then do:
      assign
      parameter-2-20 = (if p-find-next then "true":u else "false":u )
      parameter-4-20 =
        "where ":u +  substitute('goo-doc.gds-name contains &1&2&1', chr(34), NameContext ) + " ":u + where-phrase-20 + " ":u + p-find-condition + " " + ""
      parameter-5-20 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(goo-doc)
                          ,input logical(parameter-2-20)
                          ,input no-lock
                          ,input (buffer goo-doc:handle)
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
      parameter-3-20 =  "FOR EACH goo-doc no-lock"
      parameter-4-20 =
        (
          if (" goo-doc.gds-name contains NameContext " + " " + where-phrase-20) <> ""
          then  substitute('goo-doc.gds-name contains &1&2&1', chr(34), NameContext ) + " " + where-phrase-20
          else "true"
        )
      parameter-5-20 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-20 = if sort-phrase-20 = ''
                           then
        (
        " " + "  " +
        " " + " by goo-doc.artic                             BY GOO-DOC.PROD-TYPE                             BY goo-doc.prod-code "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-20
        )
      parameter-7-20 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
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
          end.
        end.
        when 'удаленные':U then do:
          if a-n-c <> "context" OR NameContext = "" then do:
            for-title = "Все неактивные товары".
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
  then do:
    define variable  parameter-2-22 as character no-undo .
    define variable  parameter-3-22 as character no-undo .
    define variable  parameter-4-22 as character no-undo .
    define variable  parameter-5-22 as character no-undo .
    define variable  parameter-6-22 as character no-undo .
    define variable  parameter-7-22 as character no-undo .
      assign
      parameter-3-22 =
                              "FOR EACH goo-doc no-lock"
      parameter-4-22 =
        (
          if (" goo-doc.stts <> 0 " + " " + where-phrase-22) <> ""
          then " goo-doc.stts <> 0 " + " " + where-phrase-22
          else "true"
        )
      parameter-5-22 = (" " + "" + " " + "")
      parameter-6-22 = if sort-phrase-22 = ''
                           then
        (
        " " + "  " +
        " " + " by goo-doc.artic                             BY GOO-DOC.PROD-TYPE                             BY goo-doc.prod-code "
        )
                           else
        (
        " " + "  " +
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
          (" goo-doc.stts <> 0 " + " " + where-phrase-22 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
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
    OPEN QUERY br-gds FOR EACH goo-doc no-lock
      where  goo-doc.stts <> 0
       by goo-doc.artic                             BY GOO-DOC.PROD-TYPE                             BY goo-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( goo-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer goo-doc:handle) then do:
      assign
      parameter-2-22 = (if p-find-next then "true":u else "false":u )
      parameter-4-22 =
        "where ":u + " goo-doc.stts <> 0 " + " ":u + where-phrase-22 + " ":u + p-find-condition + " " + ""
      parameter-5-22 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(goo-doc)
                          ,input logical(parameter-2-22)
                          ,input no-lock
                          ,input (buffer goo-doc:handle)
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
      parameter-3-22 =  "FOR EACH goo-doc no-lock"
      parameter-4-22 =
        (
          if (" goo-doc.stts <> 0 " + " " + where-phrase-22) <> ""
          then " goo-doc.stts <> 0 " + " " + where-phrase-22
          else "true"
        )
      parameter-5-22 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-22 = if sort-phrase-22 = ''
                           then
        (
        " " + "  " +
        " " + " by goo-doc.artic                             BY GOO-DOC.PROD-TYPE                             BY goo-doc.prod-code "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-22
        )
      parameter-7-22 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
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
          end.
          else do:
            for-title = substitute("Все НЕАКТИВНЫЕ товары, содержащие в названии &1"
                                   , trim( NameContext, "*" )) .
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
  then do:
    define variable  parameter-2-24 as character no-undo .
    define variable  parameter-3-24 as character no-undo .
    define variable  parameter-4-24 as character no-undo .
    define variable  parameter-5-24 as character no-undo .
    define variable  parameter-6-24 as character no-undo .
    define variable  parameter-7-24 as character no-undo .
      assign
      parameter-3-24 =
                              "FOR EACH goo-doc no-lock"
      parameter-4-24 =
        (
          if (" goo-doc.stts <> 0 AND goo-doc.gds-name contains NameContext " + " " + where-phrase-24) <> ""
          then  substitute(' goo-doc.stts <> 0 AND goo-doc.gds-name contains &1&2&1', chr(34), NameContext ) + " " + where-phrase-24
          else "true"
        )
      parameter-5-24 = (" " + "" + " " + "")
      parameter-6-24 = if sort-phrase-24 = ''
                           then
        (
        " " + "  " +
        " " + " by goo-doc.artic                             BY GOO-DOC.PROD-TYPE                             BY goo-doc.prod-code "
        )
                           else
        (
        " " + "  " +
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
          (" goo-doc.stts <> 0 AND goo-doc.gds-name contains NameContext " + " " + where-phrase-24 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
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
    OPEN QUERY br-gds FOR EACH goo-doc no-lock
      where  goo-doc.stts <> 0 AND goo-doc.gds-name contains NameContext
       by goo-doc.artic                             BY GOO-DOC.PROD-TYPE                             BY goo-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( goo-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer goo-doc:handle) then do:
      assign
      parameter-2-24 = (if p-find-next then "true":u else "false":u )
      parameter-4-24 =
        "where ":u +  substitute(' goo-doc.stts <> 0 AND goo-doc.gds-name contains &1&2&1', chr(34), NameContext ) + " ":u + where-phrase-24 + " ":u + p-find-condition + " " + ""
      parameter-5-24 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(goo-doc)
                          ,input logical(parameter-2-24)
                          ,input no-lock
                          ,input (buffer goo-doc:handle)
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
      parameter-3-24 =  "FOR EACH goo-doc no-lock"
      parameter-4-24 =
        (
          if (" goo-doc.stts <> 0 AND goo-doc.gds-name contains NameContext " + " " + where-phrase-24) <> ""
          then  substitute(' goo-doc.stts <> 0 AND goo-doc.gds-name contains &1&2&1', chr(34), NameContext ) + " " + where-phrase-24
          else "true"
        )
      parameter-5-24 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-24 = if sort-phrase-24 = ''
                           then
        (
        " " + "  " +
        " " + " by goo-doc.artic                             BY GOO-DOC.PROD-TYPE                             BY goo-doc.prod-code "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-24
        )
      parameter-7-24 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
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
          end.
        end.
      END CASE.
  end.
  when 'Производитель':U then do:
      CASE g-stat :
        when 'текущие':U then do:
          if a-n-c <> "context" OR NameContext = "" then do:
            for-title = substitute("ТЕКУЩИЕ товары с производителем : &1"
                                       , g-producer.obj-name).
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
  then do:
    define variable  parameter-2-26 as character no-undo .
    define variable  parameter-3-26 as character no-undo .
    define variable  parameter-4-26 as character no-undo .
    define variable  parameter-5-26 as character no-undo .
    define variable  parameter-6-26 as character no-undo .
    define variable  parameter-7-26 as character no-undo .
      assign
      parameter-3-26 =
                              "FOR EACH goo-doc no-lock"
      parameter-4-26 =
        (
          if (" goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code and goo-doc.stts = 0 " + " " + where-phrase-26) <> ""
          then  substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3 and goo-doc.stts = 0 '                            , chr(34), g-producer.obj-type, g-producer.obj-code) + " " + where-phrase-26
          else "true"
        )
      parameter-5-26 = (" " + "" + " " + "")
      parameter-6-26 = if sort-phrase-26 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic "
        )
                           else
        (
        " " + " " +
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
          (" goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code and goo-doc.stts = 0 " + " " + where-phrase-26 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
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
    OPEN QUERY br-gds FOR EACH goo-doc no-lock
      where  goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code and goo-doc.stts = 0
       by goo-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( goo-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer goo-doc:handle) then do:
      assign
      parameter-2-26 = (if p-find-next then "true":u else "false":u )
      parameter-4-26 =
        "where ":u +  substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3 and goo-doc.stts = 0 '                            , chr(34), g-producer.obj-type, g-producer.obj-code) + " ":u + where-phrase-26 + " ":u + p-find-condition + " " + ""
      parameter-5-26 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(goo-doc)
                          ,input logical(parameter-2-26)
                          ,input no-lock
                          ,input (buffer goo-doc:handle)
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
      parameter-3-26 =  "FOR EACH goo-doc no-lock"
      parameter-4-26 =
        (
          if (" goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code and goo-doc.stts = 0 " + " " + where-phrase-26) <> ""
          then  substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3 and goo-doc.stts = 0 '                            , chr(34), g-producer.obj-type, g-producer.obj-code) + " " + where-phrase-26
          else "true"
        )
      parameter-5-26 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-26 = if sort-phrase-26 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-26
        )
      parameter-7-26 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
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
          end.
          else do:
            for-title = substitute("ТЕКУЩИЕ товары с производителем : &1, содержащие в названии &2"
                                        ,g-producer.obj-name
                                        ,trim( NameContext, "*" ) ).
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
  then do:
    define variable  parameter-2-28 as character no-undo .
    define variable  parameter-3-28 as character no-undo .
    define variable  parameter-4-28 as character no-undo .
    define variable  parameter-5-28 as character no-undo .
    define variable  parameter-6-28 as character no-undo .
    define variable  parameter-7-28 as character no-undo .
      assign
      parameter-3-28 =
                              "FOR EACH goo-doc no-lock"
      parameter-4-28 =
        (
          if (" goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code and goo-doc.stts = 0                             and goo-doc.gds-name contains NameContext" + " " + where-phrase-28) <> ""
          then  substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3 and goo-doc.stts = 0                             and goo-doc.gds-name contains &1&4&1'                            , chr(34), g-producer.obj-type, g-producer.obj-code, NameContext) + " " + where-phrase-28
          else "true"
        )
      parameter-5-28 = (" " + "" + " " + "")
      parameter-6-28 = if sort-phrase-28 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic "
        )
                           else
        (
        " " + " " +
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
          (" goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code and goo-doc.stts = 0                             and goo-doc.gds-name contains NameContext" + " " + where-phrase-28 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
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
    OPEN QUERY br-gds FOR EACH goo-doc no-lock
      where  goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code and goo-doc.stts = 0                             and goo-doc.gds-name contains NameContext
       by goo-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( goo-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer goo-doc:handle) then do:
      assign
      parameter-2-28 = (if p-find-next then "true":u else "false":u )
      parameter-4-28 =
        "where ":u +  substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3 and goo-doc.stts = 0                             and goo-doc.gds-name contains &1&4&1'                            , chr(34), g-producer.obj-type, g-producer.obj-code, NameContext) + " ":u + where-phrase-28 + " ":u + p-find-condition + " " + ""
      parameter-5-28 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(goo-doc)
                          ,input logical(parameter-2-28)
                          ,input no-lock
                          ,input (buffer goo-doc:handle)
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
      parameter-3-28 =  "FOR EACH goo-doc no-lock"
      parameter-4-28 =
        (
          if (" goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code and goo-doc.stts = 0                             and goo-doc.gds-name contains NameContext" + " " + where-phrase-28) <> ""
          then  substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3 and goo-doc.stts = 0                             and goo-doc.gds-name contains &1&4&1'                            , chr(34), g-producer.obj-type, g-producer.obj-code, NameContext) + " " + where-phrase-28
          else "true"
        )
      parameter-5-28 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-28 = if sort-phrase-28 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-28
        )
      parameter-7-28 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
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
          end.
        end.
        when 'все':U then do:
          if a-n-c <> "context" OR NameContext = "" then do:
            for-title = substitute("ВСЕ товары с производителем : &1"
                                       , g-producer.obj-name).
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
  then do:
    define variable  parameter-2-30 as character no-undo .
    define variable  parameter-3-30 as character no-undo .
    define variable  parameter-4-30 as character no-undo .
    define variable  parameter-5-30 as character no-undo .
    define variable  parameter-6-30 as character no-undo .
    define variable  parameter-7-30 as character no-undo .
      assign
      parameter-3-30 =
                              "FOR EACH goo-doc no-lock"
      parameter-4-30 =
        (
          if (" goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code " + " " + where-phrase-30) <> ""
          then  substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3 '                            , chr(34), g-producer.obj-type, g-producer.obj-code) + " " + where-phrase-30
          else "true"
        )
      parameter-5-30 = (" " + "" + " " + "")
      parameter-6-30 = if sort-phrase-30 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic "
        )
                           else
        (
        " " + " " +
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
          (" goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code " + " " + where-phrase-30 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
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
    OPEN QUERY br-gds FOR EACH goo-doc no-lock
      where  goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code
       by goo-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( goo-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer goo-doc:handle) then do:
      assign
      parameter-2-30 = (if p-find-next then "true":u else "false":u )
      parameter-4-30 =
        "where ":u +  substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3 '                            , chr(34), g-producer.obj-type, g-producer.obj-code) + " ":u + where-phrase-30 + " ":u + p-find-condition + " " + ""
      parameter-5-30 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(goo-doc)
                          ,input logical(parameter-2-30)
                          ,input no-lock
                          ,input (buffer goo-doc:handle)
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
      parameter-3-30 =  "FOR EACH goo-doc no-lock"
      parameter-4-30 =
        (
          if (" goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code " + " " + where-phrase-30) <> ""
          then  substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3 '                            , chr(34), g-producer.obj-type, g-producer.obj-code) + " " + where-phrase-30
          else "true"
        )
      parameter-5-30 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-30 = if sort-phrase-30 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-30
        )
      parameter-7-30 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
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
          end.
          else do:
            for-title = substitute("ВСЕ товары с производителем : &1, содержащие в названии &2"
                                   , g-producer.obj-name
                                   , trim( NameContext, "*" ) ).
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
  then do:
    define variable  parameter-2-32 as character no-undo .
    define variable  parameter-3-32 as character no-undo .
    define variable  parameter-4-32 as character no-undo .
    define variable  parameter-5-32 as character no-undo .
    define variable  parameter-6-32 as character no-undo .
    define variable  parameter-7-32 as character no-undo .
      assign
      parameter-3-32 =
                              "FOR EACH goo-doc no-lock"
      parameter-4-32 =
        (
          if (" goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code                              and goo-doc.gds-name contains NameContext" + " " + where-phrase-32) <> ""
          then  substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3                             and goo-doc.gds-name contains &1&4&1'                            , chr(34), g-producer.obj-type, g-producer.obj-code, NameContext) + " " + where-phrase-32
          else "true"
        )
      parameter-5-32 = (" " + "" + " " + "")
      parameter-6-32 = if sort-phrase-32 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic "
        )
                           else
        (
        " " + " " +
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
          (" goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code                              and goo-doc.gds-name contains NameContext" + " " + where-phrase-32 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
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
    OPEN QUERY br-gds FOR EACH goo-doc no-lock
      where  goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code                              and goo-doc.gds-name contains NameContext
       by goo-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( goo-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer goo-doc:handle) then do:
      assign
      parameter-2-32 = (if p-find-next then "true":u else "false":u )
      parameter-4-32 =
        "where ":u +  substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3                             and goo-doc.gds-name contains &1&4&1'                            , chr(34), g-producer.obj-type, g-producer.obj-code, NameContext) + " ":u + where-phrase-32 + " ":u + p-find-condition + " " + ""
      parameter-5-32 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(goo-doc)
                          ,input logical(parameter-2-32)
                          ,input no-lock
                          ,input (buffer goo-doc:handle)
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
      parameter-3-32 =  "FOR EACH goo-doc no-lock"
      parameter-4-32 =
        (
          if (" goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code                              and goo-doc.gds-name contains NameContext" + " " + where-phrase-32) <> ""
          then  substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3                             and goo-doc.gds-name contains &1&4&1'                            , chr(34), g-producer.obj-type, g-producer.obj-code, NameContext) + " " + where-phrase-32
          else "true"
        )
      parameter-5-32 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-32 = if sort-phrase-32 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-32
        )
      parameter-7-32 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
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
          end.
        end.
        when 'удаленные':U then do:
          if a-n-c <> "context" OR NameContext = "" then do:
            for-title = substitute("НЕАКТИВНЫЕ товары с производителем : &1"
                                , g-producer.obj-name).
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
  then do:
    define variable  parameter-2-34 as character no-undo .
    define variable  parameter-3-34 as character no-undo .
    define variable  parameter-4-34 as character no-undo .
    define variable  parameter-5-34 as character no-undo .
    define variable  parameter-6-34 as character no-undo .
    define variable  parameter-7-34 as character no-undo .
      assign
      parameter-3-34 =
                              "FOR EACH goo-doc no-lock"
      parameter-4-34 =
        (
          if (" goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code and goo-doc.stts <> 0 " + " " + where-phrase-34) <> ""
          then  substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3 and goo-doc.stts <> 0 '                            , chr(34), g-producer.obj-type, g-producer.obj-code) + " " + where-phrase-34
          else "true"
        )
      parameter-5-34 = (" " + "" + " " + "")
      parameter-6-34 = if sort-phrase-34 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic "
        )
                           else
        (
        " " + " " +
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
          (" goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code and goo-doc.stts <> 0 " + " " + where-phrase-34 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
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
    OPEN QUERY br-gds FOR EACH goo-doc no-lock
      where  goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code and goo-doc.stts <> 0
       by goo-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( goo-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer goo-doc:handle) then do:
      assign
      parameter-2-34 = (if p-find-next then "true":u else "false":u )
      parameter-4-34 =
        "where ":u +  substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3 and goo-doc.stts <> 0 '                            , chr(34), g-producer.obj-type, g-producer.obj-code) + " ":u + where-phrase-34 + " ":u + p-find-condition + " " + ""
      parameter-5-34 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(goo-doc)
                          ,input logical(parameter-2-34)
                          ,input no-lock
                          ,input (buffer goo-doc:handle)
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
      parameter-3-34 =  "FOR EACH goo-doc no-lock"
      parameter-4-34 =
        (
          if (" goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code and goo-doc.stts <> 0 " + " " + where-phrase-34) <> ""
          then  substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3 and goo-doc.stts <> 0 '                            , chr(34), g-producer.obj-type, g-producer.obj-code) + " " + where-phrase-34
          else "true"
        )
      parameter-5-34 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-34 = if sort-phrase-34 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-34
        )
      parameter-7-34 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
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
          end.
          else do:
            for-title = substitute("НЕАКТИВНЫЕ товары с производителем : &1, содержащии в названии &2"
                                  , g-producer.obj-name
                                  , trim( NameContext, "*" ) ).
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
  then do:
    define variable  parameter-2-36 as character no-undo .
    define variable  parameter-3-36 as character no-undo .
    define variable  parameter-4-36 as character no-undo .
    define variable  parameter-5-36 as character no-undo .
    define variable  parameter-6-36 as character no-undo .
    define variable  parameter-7-36 as character no-undo .
      assign
      parameter-3-36 =
                              "FOR EACH goo-doc no-lock"
      parameter-4-36 =
        (
          if (" goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code and goo-doc.stts <> 0                             and goo-doc.gds-name contains NameContext" + " " + where-phrase-36) <> ""
          then  substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3 and goo-doc.stts <> 0                             and goo-doc.gds-name contains &1&4&1'                            , chr(34), g-producer.obj-type, g-producer.obj-code, NameContext) + " " + where-phrase-36
          else "true"
        )
      parameter-5-36 = (" " + "" + " " + "")
      parameter-6-36 = if sort-phrase-36 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic "
        )
                           else
        (
        " " + " " +
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
          (" goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code and goo-doc.stts <> 0                             and goo-doc.gds-name contains NameContext" + " " + where-phrase-36 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
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
    OPEN QUERY br-gds FOR EACH goo-doc no-lock
      where  goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code and goo-doc.stts <> 0                             and goo-doc.gds-name contains NameContext
       by goo-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( goo-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer goo-doc:handle) then do:
      assign
      parameter-2-36 = (if p-find-next then "true":u else "false":u )
      parameter-4-36 =
        "where ":u +  substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3 and goo-doc.stts <> 0                             and goo-doc.gds-name contains &1&4&1'                            , chr(34), g-producer.obj-type, g-producer.obj-code, NameContext) + " ":u + where-phrase-36 + " ":u + p-find-condition + " " + ""
      parameter-5-36 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(goo-doc)
                          ,input logical(parameter-2-36)
                          ,input no-lock
                          ,input (buffer goo-doc:handle)
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
      parameter-3-36 =  "FOR EACH goo-doc no-lock"
      parameter-4-36 =
        (
          if (" goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code and goo-doc.stts <> 0                             and goo-doc.gds-name contains NameContext" + " " + where-phrase-36) <> ""
          then  substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3 and goo-doc.stts <> 0                             and goo-doc.gds-name contains &1&4&1'                            , chr(34), g-producer.obj-type, g-producer.obj-code, NameContext) + " " + where-phrase-36
          else "true"
        )
      parameter-5-36 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-36 = if sort-phrase-36 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-36
        )
      parameter-7-36 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
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
          end.
        end.
      END CASE.
  end.
  when 'группа':U then dO:
    CASE g-stat :
      when 'текущие':U then do:
        if a-n-c <> "context" OR NameContext = "" then do:
          for-title = substitute("ТЕКУЩИЕ товары группы : &1", g-grp).
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-38  as logical   no-undo .
define variable  l-filter-open-38    as logical   .
define variable  flt-rec-38       as recid     no-undo .
define variable  filter-name-38      as character no-undo .
define variable  where-phrase-38     as character no-undo .
define variable  sort-phrase-38      as character no-undo .
define variable  where-phrase-rus-38 as character no-undo .
define variable  sort-phrase-rus-38  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-38
  ,output filter-name-38
  ,output where-phrase-38
  ,output sort-phrase-38
  ,output where-phrase-rus-38
  ,output sort-phrase-rus-38
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-38
      ) no-error .
  assign
    l-filter-open-38 = false
  .
  if flt-rec-38 <> ?
  then do:
    define variable  parameter-2-38 as character no-undo .
    define variable  parameter-3-38 as character no-undo .
    define variable  parameter-4-38 as character no-undo .
    define variable  parameter-5-38 as character no-undo .
    define variable  parameter-6-38 as character no-undo .
    define variable  parameter-7-38 as character no-undo .
      assign
      parameter-3-38 =
                              "FOR EACH goo-doc no-lock"
      parameter-4-38 =
        (
          if (" goo-doc.grp-name begins g-grp and goo-doc.stts = 0 " + " " + where-phrase-38) <> ""
          then  substitute('goo-doc.grp-name begins &1&2&1  and goo-doc.stts = 0 ', chr(34), g-grp) + " " + where-phrase-38
          else "true"
        )
      parameter-5-38 = (" " + "" + " " + "")
      parameter-6-38 = if sort-phrase-38 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic                           by goo-doc.prod-type                           by goo-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-38
        )
      parameter-7-38 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-38 =
          (" goo-doc.grp-name begins g-grp and goo-doc.stts = 0 " + " " + where-phrase-38 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-38
                          ,input parameter-4-38
                          ,input parameter-5-38
                          ,input parameter-6-38
                          ,input parameter-7-38
                          )
      .
      assign
        l-filter-open-38 = true
      .
    end.
    if l-filter-open-38 = false then do:
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
  if l-filter-open-38 = false then do:
    OPEN QUERY br-gds FOR EACH goo-doc no-lock
      where  goo-doc.grp-name begins g-grp and goo-doc.stts = 0
       by goo-doc.artic                           by goo-doc.prod-type                           by goo-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( goo-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer goo-doc:handle) then do:
      assign
      parameter-2-38 = (if p-find-next then "true":u else "false":u )
      parameter-4-38 =
        "where ":u +  substitute('goo-doc.grp-name begins &1&2&1  and goo-doc.stts = 0 ', chr(34), g-grp) + " ":u + where-phrase-38 + " ":u + p-find-condition + " " + ""
      parameter-5-38 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(goo-doc)
                          ,input logical(parameter-2-38)
                          ,input no-lock
                          ,input (buffer goo-doc:handle)
                          ,input parameter-4-38
                          ,input parameter-5-38
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-38 = (if p-find-next then "true":u else "false":u )
      parameter-3-38 =  "FOR EACH goo-doc no-lock"
      parameter-4-38 =
        (
          if (" goo-doc.grp-name begins g-grp and goo-doc.stts = 0 " + " " + where-phrase-38) <> ""
          then  substitute('goo-doc.grp-name begins &1&2&1  and goo-doc.stts = 0 ', chr(34), g-grp) + " " + where-phrase-38
          else "true"
        )
      parameter-5-38 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-38 = if sort-phrase-38 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic                           by goo-doc.prod-type                           by goo-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-38
        )
      parameter-7-38 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-38)
                          ,input no-lock
                          ,input parameter-3-38
                          ,input parameter-4-38
                          ,input parameter-5-38
                          ,input parameter-6-38
                          ,input parameter-7-38
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
          for-title = substitute("ТЕКУЩИЕ товары группы : &1, содержащие в названии &2"
                                , g-grp
                                , trim( NameContext, "*" )).
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-40  as logical   no-undo .
define variable  l-filter-open-40    as logical   .
define variable  flt-rec-40       as recid     no-undo .
define variable  filter-name-40      as character no-undo .
define variable  where-phrase-40     as character no-undo .
define variable  sort-phrase-40      as character no-undo .
define variable  where-phrase-rus-40 as character no-undo .
define variable  sort-phrase-rus-40  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-40
  ,output filter-name-40
  ,output where-phrase-40
  ,output sort-phrase-40
  ,output where-phrase-rus-40
  ,output sort-phrase-rus-40
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-40
      ) no-error .
  assign
    l-filter-open-40 = false
  .
  if flt-rec-40 <> ?
  then do:
    define variable  parameter-2-40 as character no-undo .
    define variable  parameter-3-40 as character no-undo .
    define variable  parameter-4-40 as character no-undo .
    define variable  parameter-5-40 as character no-undo .
    define variable  parameter-6-40 as character no-undo .
    define variable  parameter-7-40 as character no-undo .
      assign
      parameter-3-40 =
                              "FOR EACH goo-doc no-lock"
      parameter-4-40 =
        (
          if (" goo-doc.grp-name begins g-grp and goo-doc.stts = 0 and goo-doc.gds-name contains NameContext " + " " + where-phrase-40) <> ""
          then  substitute('goo-doc.grp-name begins &1&2&1  and goo-doc.stts = 0 and goo-doc.gds-name contains &1&3&1 ', chr(34), g-grp, NameContext) + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + "")
      parameter-6-40 = if sort-phrase-40 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic                           by goo-doc.prod-type                           by goo-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-40
        )
      parameter-7-40 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-40 =
          (" goo-doc.grp-name begins g-grp and goo-doc.stts = 0 and goo-doc.gds-name contains NameContext " + " " + where-phrase-40 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-40
                          ,input parameter-4-40
                          ,input parameter-5-40
                          ,input parameter-6-40
                          ,input parameter-7-40
                          )
      .
      assign
        l-filter-open-40 = true
      .
    end.
    if l-filter-open-40 = false then do:
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
  if l-filter-open-40 = false then do:
    OPEN QUERY br-gds FOR EACH goo-doc no-lock
      where  goo-doc.grp-name begins g-grp and goo-doc.stts = 0 and goo-doc.gds-name contains NameContext
       by goo-doc.artic                           by goo-doc.prod-type                           by goo-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( goo-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer goo-doc:handle) then do:
      assign
      parameter-2-40 = (if p-find-next then "true":u else "false":u )
      parameter-4-40 =
        "where ":u +  substitute('goo-doc.grp-name begins &1&2&1  and goo-doc.stts = 0 and goo-doc.gds-name contains &1&3&1 ', chr(34), g-grp, NameContext) + " ":u + where-phrase-40 + " ":u + p-find-condition + " " + ""
      parameter-5-40 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(goo-doc)
                          ,input logical(parameter-2-40)
                          ,input no-lock
                          ,input (buffer goo-doc:handle)
                          ,input parameter-4-40
                          ,input parameter-5-40
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-40 = (if p-find-next then "true":u else "false":u )
      parameter-3-40 =  "FOR EACH goo-doc no-lock"
      parameter-4-40 =
        (
          if (" goo-doc.grp-name begins g-grp and goo-doc.stts = 0 and goo-doc.gds-name contains NameContext " + " " + where-phrase-40) <> ""
          then  substitute('goo-doc.grp-name begins &1&2&1  and goo-doc.stts = 0 and goo-doc.gds-name contains &1&3&1 ', chr(34), g-grp, NameContext) + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-40 = if sort-phrase-40 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic                           by goo-doc.prod-type                           by goo-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-40
        )
      parameter-7-40 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-40)
                          ,input no-lock
                          ,input parameter-3-40
                          ,input parameter-4-40
                          ,input parameter-5-40
                          ,input parameter-6-40
                          ,input parameter-7-40
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
      when 'все':U then do:
        if a-n-c <> "context" OR NameContext = "" then do:
          for-title = substitute("ВСЕ товары группы : &1", g-grp).
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-42  as logical   no-undo .
define variable  l-filter-open-42    as logical   .
define variable  flt-rec-42       as recid     no-undo .
define variable  filter-name-42      as character no-undo .
define variable  where-phrase-42     as character no-undo .
define variable  sort-phrase-42      as character no-undo .
define variable  where-phrase-rus-42 as character no-undo .
define variable  sort-phrase-rus-42  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-42
  ,output filter-name-42
  ,output where-phrase-42
  ,output sort-phrase-42
  ,output where-phrase-rus-42
  ,output sort-phrase-rus-42
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-42
      ) no-error .
  assign
    l-filter-open-42 = false
  .
  if flt-rec-42 <> ?
  then do:
    define variable  parameter-2-42 as character no-undo .
    define variable  parameter-3-42 as character no-undo .
    define variable  parameter-4-42 as character no-undo .
    define variable  parameter-5-42 as character no-undo .
    define variable  parameter-6-42 as character no-undo .
    define variable  parameter-7-42 as character no-undo .
      assign
      parameter-3-42 =
                              "FOR EACH goo-doc no-lock"
      parameter-4-42 =
        (
          if (" goo-doc.grp-name begins g-grp " + " " + where-phrase-42) <> ""
          then  substitute('goo-doc.grp-name begins &1&2&1 ', chr(34), g-grp) + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + "")
      parameter-6-42 = if sort-phrase-42 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic                           by goo-doc.prod-type                           by goo-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-42
        )
      parameter-7-42 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-42 =
          (" goo-doc.grp-name begins g-grp " + " " + where-phrase-42 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-42
                          ,input parameter-4-42
                          ,input parameter-5-42
                          ,input parameter-6-42
                          ,input parameter-7-42
                          )
      .
      assign
        l-filter-open-42 = true
      .
    end.
    if l-filter-open-42 = false then do:
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
  if l-filter-open-42 = false then do:
    OPEN QUERY br-gds FOR EACH goo-doc no-lock
      where  goo-doc.grp-name begins g-grp
       by goo-doc.artic                           by goo-doc.prod-type                           by goo-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( goo-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer goo-doc:handle) then do:
      assign
      parameter-2-42 = (if p-find-next then "true":u else "false":u )
      parameter-4-42 =
        "where ":u +  substitute('goo-doc.grp-name begins &1&2&1 ', chr(34), g-grp) + " ":u + where-phrase-42 + " ":u + p-find-condition + " " + ""
      parameter-5-42 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(goo-doc)
                          ,input logical(parameter-2-42)
                          ,input no-lock
                          ,input (buffer goo-doc:handle)
                          ,input parameter-4-42
                          ,input parameter-5-42
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-42 = (if p-find-next then "true":u else "false":u )
      parameter-3-42 =  "FOR EACH goo-doc no-lock"
      parameter-4-42 =
        (
          if (" goo-doc.grp-name begins g-grp " + " " + where-phrase-42) <> ""
          then  substitute('goo-doc.grp-name begins &1&2&1 ', chr(34), g-grp) + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-42 = if sort-phrase-42 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic                           by goo-doc.prod-type                           by goo-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-42
        )
      parameter-7-42 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-42)
                          ,input no-lock
                          ,input parameter-3-42
                          ,input parameter-4-42
                          ,input parameter-5-42
                          ,input parameter-6-42
                          ,input parameter-7-42
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
          for-title = substitute("ВСЕ товары группы : &1, содержащие в названии &2"
                                 , g-grp
                                 , trim( NameContext, "*" )).
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-44  as logical   no-undo .
define variable  l-filter-open-44    as logical   .
define variable  flt-rec-44       as recid     no-undo .
define variable  filter-name-44      as character no-undo .
define variable  where-phrase-44     as character no-undo .
define variable  sort-phrase-44      as character no-undo .
define variable  where-phrase-rus-44 as character no-undo .
define variable  sort-phrase-rus-44  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-44
  ,output filter-name-44
  ,output where-phrase-44
  ,output sort-phrase-44
  ,output where-phrase-rus-44
  ,output sort-phrase-rus-44
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-44
      ) no-error .
  assign
    l-filter-open-44 = false
  .
  if flt-rec-44 <> ?
  then do:
    define variable  parameter-2-44 as character no-undo .
    define variable  parameter-3-44 as character no-undo .
    define variable  parameter-4-44 as character no-undo .
    define variable  parameter-5-44 as character no-undo .
    define variable  parameter-6-44 as character no-undo .
    define variable  parameter-7-44 as character no-undo .
      assign
      parameter-3-44 =
                              "FOR EACH goo-doc no-lock"
      parameter-4-44 =
        (
          if (" goo-doc.grp-name begins g-grp and goo-doc.gds-name contains NameContext " + " " + where-phrase-44) <> ""
          then  substitute('goo-doc.grp-name begins &1&2&1  and goo-doc.gds-name contains &1&3&1 ', chr(34), g-grp, NameContext) + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + "")
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic                           by goo-doc.prod-type                           by goo-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-44
        )
      parameter-7-44 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-44 =
          (" goo-doc.grp-name begins g-grp and goo-doc.gds-name contains NameContext " + " " + where-phrase-44 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-44
                          ,input parameter-4-44
                          ,input parameter-5-44
                          ,input parameter-6-44
                          ,input parameter-7-44
                          )
      .
      assign
        l-filter-open-44 = true
      .
    end.
    if l-filter-open-44 = false then do:
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
  if l-filter-open-44 = false then do:
    OPEN QUERY br-gds FOR EACH goo-doc no-lock
      where  goo-doc.grp-name begins g-grp and goo-doc.gds-name contains NameContext
       by goo-doc.artic                           by goo-doc.prod-type                           by goo-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( goo-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer goo-doc:handle) then do:
      assign
      parameter-2-44 = (if p-find-next then "true":u else "false":u )
      parameter-4-44 =
        "where ":u +  substitute('goo-doc.grp-name begins &1&2&1  and goo-doc.gds-name contains &1&3&1 ', chr(34), g-grp, NameContext) + " ":u + where-phrase-44 + " ":u + p-find-condition + " " + ""
      parameter-5-44 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(goo-doc)
                          ,input logical(parameter-2-44)
                          ,input no-lock
                          ,input (buffer goo-doc:handle)
                          ,input parameter-4-44
                          ,input parameter-5-44
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-44 = (if p-find-next then "true":u else "false":u )
      parameter-3-44 =  "FOR EACH goo-doc no-lock"
      parameter-4-44 =
        (
          if (" goo-doc.grp-name begins g-grp and goo-doc.gds-name contains NameContext " + " " + where-phrase-44) <> ""
          then  substitute('goo-doc.grp-name begins &1&2&1  and goo-doc.gds-name contains &1&3&1 ', chr(34), g-grp, NameContext) + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic                           by goo-doc.prod-type                           by goo-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-44
        )
      parameter-7-44 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-44)
                          ,input no-lock
                          ,input parameter-3-44
                          ,input parameter-4-44
                          ,input parameter-5-44
                          ,input parameter-6-44
                          ,input parameter-7-44
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
      when 'удаленные':U then do:
        if a-n-c <> "context" OR NameContext = "" then do:
          for-title = substitute("НЕАКТИВНЫЕ товары группы : &1", g-grp).
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-46  as logical   no-undo .
define variable  l-filter-open-46    as logical   .
define variable  flt-rec-46       as recid     no-undo .
define variable  filter-name-46      as character no-undo .
define variable  where-phrase-46     as character no-undo .
define variable  sort-phrase-46      as character no-undo .
define variable  where-phrase-rus-46 as character no-undo .
define variable  sort-phrase-rus-46  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-46
  ,output filter-name-46
  ,output where-phrase-46
  ,output sort-phrase-46
  ,output where-phrase-rus-46
  ,output sort-phrase-rus-46
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-46
      ) no-error .
  assign
    l-filter-open-46 = false
  .
  if flt-rec-46 <> ?
  then do:
    define variable  parameter-2-46 as character no-undo .
    define variable  parameter-3-46 as character no-undo .
    define variable  parameter-4-46 as character no-undo .
    define variable  parameter-5-46 as character no-undo .
    define variable  parameter-6-46 as character no-undo .
    define variable  parameter-7-46 as character no-undo .
      assign
      parameter-3-46 =
                              "FOR EACH goo-doc no-lock"
      parameter-4-46 =
        (
          if (" goo-doc.grp-name begins g-grp and goo-doc.stts <> 0  " + " " + where-phrase-46) <> ""
          then  substitute('goo-doc.grp-name begins &1&2&1  and goo-doc.stts <> 0 ', chr(34), g-grp) + " " + where-phrase-46
          else "true"
        )
      parameter-5-46 = (" " + "" + " " + "")
      parameter-6-46 = if sort-phrase-46 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic                           by goo-doc.prod-type                           by goo-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-46
        )
      parameter-7-46 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-46 =
          (" goo-doc.grp-name begins g-grp and goo-doc.stts <> 0  " + " " + where-phrase-46 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-46
                          ,input parameter-4-46
                          ,input parameter-5-46
                          ,input parameter-6-46
                          ,input parameter-7-46
                          )
      .
      assign
        l-filter-open-46 = true
      .
    end.
    if l-filter-open-46 = false then do:
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
  if l-filter-open-46 = false then do:
    OPEN QUERY br-gds FOR EACH goo-doc no-lock
      where  goo-doc.grp-name begins g-grp and goo-doc.stts <> 0
       by goo-doc.artic                           by goo-doc.prod-type                           by goo-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( goo-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer goo-doc:handle) then do:
      assign
      parameter-2-46 = (if p-find-next then "true":u else "false":u )
      parameter-4-46 =
        "where ":u +  substitute('goo-doc.grp-name begins &1&2&1  and goo-doc.stts <> 0 ', chr(34), g-grp) + " ":u + where-phrase-46 + " ":u + p-find-condition + " " + ""
      parameter-5-46 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(goo-doc)
                          ,input logical(parameter-2-46)
                          ,input no-lock
                          ,input (buffer goo-doc:handle)
                          ,input parameter-4-46
                          ,input parameter-5-46
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-46 = (if p-find-next then "true":u else "false":u )
      parameter-3-46 =  "FOR EACH goo-doc no-lock"
      parameter-4-46 =
        (
          if (" goo-doc.grp-name begins g-grp and goo-doc.stts <> 0  " + " " + where-phrase-46) <> ""
          then  substitute('goo-doc.grp-name begins &1&2&1  and goo-doc.stts <> 0 ', chr(34), g-grp) + " " + where-phrase-46
          else "true"
        )
      parameter-5-46 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-46 = if sort-phrase-46 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic                           by goo-doc.prod-type                           by goo-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-46
        )
      parameter-7-46 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-46)
                          ,input no-lock
                          ,input parameter-3-46
                          ,input parameter-4-46
                          ,input parameter-5-46
                          ,input parameter-6-46
                          ,input parameter-7-46
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
          for-title = substitute("НЕАКТИВНЫЕ товары группы : &1, содержащие в названии &2"
                      , g-grp
                      , trim( NameContext, "*" )).
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-48  as logical   no-undo .
define variable  l-filter-open-48    as logical   .
define variable  flt-rec-48       as recid     no-undo .
define variable  filter-name-48      as character no-undo .
define variable  where-phrase-48     as character no-undo .
define variable  sort-phrase-48      as character no-undo .
define variable  where-phrase-rus-48 as character no-undo .
define variable  sort-phrase-rus-48  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-48
  ,output filter-name-48
  ,output where-phrase-48
  ,output sort-phrase-48
  ,output where-phrase-rus-48
  ,output sort-phrase-rus-48
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-48
      ) no-error .
  assign
    l-filter-open-48 = false
  .
  if flt-rec-48 <> ?
  then do:
    define variable  parameter-2-48 as character no-undo .
    define variable  parameter-3-48 as character no-undo .
    define variable  parameter-4-48 as character no-undo .
    define variable  parameter-5-48 as character no-undo .
    define variable  parameter-6-48 as character no-undo .
    define variable  parameter-7-48 as character no-undo .
      assign
      parameter-3-48 =
                              "FOR EACH goo-doc no-lock"
      parameter-4-48 =
        (
          if (" goo-doc.grp-name begins g-grp and goo-doc.stts <> 0 and goo-doc.gds-name contains NameContext " + " " + where-phrase-48) <> ""
          then  substitute('goo-doc.grp-name begins &1&2&1  and goo-doc.stts <> 0 and goo-doc.gds-name contains &1&3&1 ', chr(34), g-grp, NameContext) + " " + where-phrase-48
          else "true"
        )
      parameter-5-48 = (" " + "" + " " + "")
      parameter-6-48 = if sort-phrase-48 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic                           by goo-doc.prod-type                           by goo-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-48
        )
      parameter-7-48 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-48 =
          (" goo-doc.grp-name begins g-grp and goo-doc.stts <> 0 and goo-doc.gds-name contains NameContext " + " " + where-phrase-48 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-48
                          ,input parameter-4-48
                          ,input parameter-5-48
                          ,input parameter-6-48
                          ,input parameter-7-48
                          )
      .
      assign
        l-filter-open-48 = true
      .
    end.
    if l-filter-open-48 = false then do:
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
  if l-filter-open-48 = false then do:
    OPEN QUERY br-gds FOR EACH goo-doc no-lock
      where  goo-doc.grp-name begins g-grp and goo-doc.stts <> 0 and goo-doc.gds-name contains NameContext
       by goo-doc.artic                           by goo-doc.prod-type                           by goo-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( goo-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer goo-doc:handle) then do:
      assign
      parameter-2-48 = (if p-find-next then "true":u else "false":u )
      parameter-4-48 =
        "where ":u +  substitute('goo-doc.grp-name begins &1&2&1  and goo-doc.stts <> 0 and goo-doc.gds-name contains &1&3&1 ', chr(34), g-grp, NameContext) + " ":u + where-phrase-48 + " ":u + p-find-condition + " " + ""
      parameter-5-48 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(goo-doc)
                          ,input logical(parameter-2-48)
                          ,input no-lock
                          ,input (buffer goo-doc:handle)
                          ,input parameter-4-48
                          ,input parameter-5-48
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-48 = (if p-find-next then "true":u else "false":u )
      parameter-3-48 =  "FOR EACH goo-doc no-lock"
      parameter-4-48 =
        (
          if (" goo-doc.grp-name begins g-grp and goo-doc.stts <> 0 and goo-doc.gds-name contains NameContext " + " " + where-phrase-48) <> ""
          then  substitute('goo-doc.grp-name begins &1&2&1  and goo-doc.stts <> 0 and goo-doc.gds-name contains &1&3&1 ', chr(34), g-grp, NameContext) + " " + where-phrase-48
          else "true"
        )
      parameter-5-48 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-48 = if sort-phrase-48 = ''
                           then
        (
        " " + " " +
        " " + " by goo-doc.artic                           by goo-doc.prod-type                           by goo-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-48
        )
      parameter-7-48 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-48)
                          ,input no-lock
                          ,input parameter-3-48
                          ,input parameter-4-48
                          ,input parameter-5-48
                          ,input parameter-6-48
                          ,input parameter-7-48
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
    END CASE.
END .
END CASE.
return.
