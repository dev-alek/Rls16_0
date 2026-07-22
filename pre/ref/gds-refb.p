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
define variable vss-workfile    as character no-undo init "$Workfile: gds-refb.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gds-refb.p $":U .
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
DEFINE SHARED QUERY br-gds FOR gob-doc  SCROLLING.
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
                              "FOR EACH gob-doc no-lock"
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
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
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
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-6 = (if p-find-next then "true":u else "false":u )
      parameter-4-6 =
        "where ":u + " goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " ":u + where-phrase-6 + " ":u + p-find-condition + " " + ""
      parameter-5-6 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-6)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
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
      parameter-3-6 =  "FOR EACH gob-doc no-lock"
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
                              "FOR EACH gob-doc no-lock"
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
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
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
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-8 = (if p-find-next then "true":u else "false":u )
      parameter-4-8 =
        "where ":u + " goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " ":u + where-phrase-8 + " ":u + p-find-condition + " " + ""
      parameter-5-8 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-8)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
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
      parameter-3-8 =  "FOR EACH gob-doc no-lock"
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
                              "FOR EACH gob-doc no-lock"
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
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
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
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-10 = (if p-find-next then "true":u else "false":u )
      parameter-4-10 =
        "where ":u + " goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " ":u + where-phrase-10 + " ":u + p-find-condition + " " + ""
      parameter-5-10 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-10)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
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
      parameter-3-10 =  "FOR EACH gob-doc no-lock"
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
                              "FOR EACH gob-doc no-lock"
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
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
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
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-12 = (if p-find-next then "true":u else "false":u )
      parameter-4-12 =
        "where ":u + " goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, chr(4)) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, chr(4)) > 0" + " ":u + where-phrase-12 + " ":u + p-find-condition + " " + ""
      parameter-5-12 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-12)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
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
      parameter-3-12 =  "FOR EACH gob-doc no-lock"
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
      CASE g-cond :
        when 'объект':U then do:
           CASE g-stat :
            when 'текущие':U then do:
              for-title = substitute("ТЕКУЩИЕ товары по объекту : &1&2 &3"
                                     , pobj-type
                                     , pobj-code
                                     , cur-obj.obj-name).
              CASE rs-sort :
                when 'Артикул':U then do:
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
                              "FOR EACH gob-doc no-lock"
      parameter-4-14 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts = 0 " + " " + where-phrase-14) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0 ', chr(34), pobj-type, pobj-code) + " " + where-phrase-14
          else "true"
        )
      parameter-5-14 = (" " + "" + " " + "")
      parameter-6-14 = if sort-phrase-14 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.artic                                   BY gob-doc.PROD-TYPE                                   BY gob-doc.prod-code "
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
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts = 0 " + " " + where-phrase-14 = "")
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
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts = 0
       by gob-doc.artic                                   BY gob-doc.PROD-TYPE                                   BY gob-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-14 = (if p-find-next then "true":u else "false":u )
      parameter-4-14 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0 ', chr(34), pobj-type, pobj-code) + " ":u + where-phrase-14 + " ":u + p-find-condition + " " + ""
      parameter-5-14 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-14)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
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
      parameter-3-14 =  "FOR EACH gob-doc no-lock"
      parameter-4-14 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts = 0 " + " " + where-phrase-14) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0 ', chr(34), pobj-type, pobj-code) + " " + where-phrase-14
          else "true"
        )
      parameter-5-14 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-14 = if sort-phrase-14 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.artic                                   BY gob-doc.PROD-TYPE                                   BY gob-doc.prod-code "
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
                when 'цена':U then do:
                   RUN obj-price0 in this-procedure .
                end.
              END CASE .
            end.
            when 'все':U then do:
              for-title = substitute("ВСЕ товары по объекту : &1&2 &3"
                                     , pobj-type
                                     , pobj-code
                                     , cur-obj.obj-name).
              CASE rs-sort :
                when 'Артикул':U then dO:
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
                              "FOR EACH gob-doc no-lock"
      parameter-4-16 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-16) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 ', chr(34), pobj-type, pobj-code) + " " + where-phrase-16
          else "true"
        )
      parameter-5-16 = (" " + "" + " " + "")
      parameter-6-16 = if sort-phrase-16 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.artic                                     BY gob-doc.PROD-TYPE                                     BY gob-doc.prod-code "
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
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-16 = "")
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
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code
       by gob-doc.artic                                     BY gob-doc.PROD-TYPE                                     BY gob-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-16 = (if p-find-next then "true":u else "false":u )
      parameter-4-16 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 ', chr(34), pobj-type, pobj-code) + " ":u + where-phrase-16 + " ":u + p-find-condition + " " + ""
      parameter-5-16 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-16)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
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
      parameter-3-16 =  "FOR EACH gob-doc no-lock"
      parameter-4-16 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-16) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 ', chr(34), pobj-type, pobj-code) + " " + where-phrase-16
          else "true"
        )
      parameter-5-16 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-16 = if sort-phrase-16 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.artic                                     BY gob-doc.PROD-TYPE                                     BY gob-doc.prod-code "
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
                when 'цена':U then do:
                  RUN obj-price in this-procedure .
                end.
              END CASE .
            end.
            when 'удаленные':U then do:
              for-title = substitute("НЕАКТИВНЫЕ товары по объекту &1&2 &3"
                                      , pobj-type
                                      , pobj-code
                                      , cur-obj.obj-name).
              CASE rs-sort :
                when 'Артикул':U then do:
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
                              "FOR EACH gob-doc no-lock"
      parameter-4-18 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 " + " " + where-phrase-18) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0' , chr(34), pobj-type, pobj-code) + " " + where-phrase-18
          else "true"
        )
      parameter-5-18 = (" " + "" + " " + "")
      parameter-6-18 = if sort-phrase-18 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.artic                                     BY gob-doc.PROD-TYPE                                     BY gob-doc.prod-code "
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
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 " + " " + where-phrase-18 = "")
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
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0
       by gob-doc.artic                                     BY gob-doc.PROD-TYPE                                     BY gob-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-18 = (if p-find-next then "true":u else "false":u )
      parameter-4-18 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0' , chr(34), pobj-type, pobj-code) + " ":u + where-phrase-18 + " ":u + p-find-condition + " " + ""
      parameter-5-18 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-18)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
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
      parameter-3-18 =  "FOR EACH gob-doc no-lock"
      parameter-4-18 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 " + " " + where-phrase-18) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0' , chr(34), pobj-type, pobj-code) + " " + where-phrase-18
          else "true"
        )
      parameter-5-18 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-18 = if sort-phrase-18 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.artic                                     BY gob-doc.PROD-TYPE                                     BY gob-doc.prod-code "
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
                when 'цена':U then do:
                  RUN obj-price-0.
                end.
              END CASE .
            end.
          END CASE .
        end.
        when 'факт':U then dO:
          CASE g-stat :
            when 'текущие':U then do:
              for-title = substitute("ТЕКУЩИЕ товары, имеющиеся в наличии по объекту &1&2 (факт остаток > 0)"
                                      , pobj-type
                                      , pobj-code).
              CASE rs-sort :
                when 'Артикул':U then do:
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
                              "FOR EACH gob-doc no-lock"
      parameter-4-20 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.fact-qnty > 0 " + " " + where-phrase-20) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.fact-qnty > 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-20
          else "true"
        )
      parameter-5-20 = (" " + "" + " " + "")
      parameter-6-20 = if sort-phrase-20 = ''
                           then
        (
        " " + " use-index pi " +
        " " + "  "
        )
                           else
        (
        " " + " use-index pi " +
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
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.fact-qnty > 0 " + " " + where-phrase-20 = "")
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
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.fact-qnty > 0
       use-index pi
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-20 = (if p-find-next then "true":u else "false":u )
      parameter-4-20 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.fact-qnty > 0 ' , chr(34), pobj-type, pobj-code) + " ":u + where-phrase-20 + " ":u + p-find-condition + " " + ""
      parameter-5-20 = " use-index pi "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-20)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
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
      parameter-3-20 =  "FOR EACH gob-doc no-lock"
      parameter-4-20 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.fact-qnty > 0 " + " " + where-phrase-20) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.fact-qnty > 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-20
          else "true"
        )
      parameter-5-20 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-20 = if sort-phrase-20 = ''
                           then
        (
        " " + " use-index pi " +
        " " + "  "
        )
                           else
        (
        " " + " use-index pi " +
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
                when 'цена':U then do:
                  RUN fact-price0 in this-procedure .
                end.
                when 'Количество':U then dO:
                  RUN fact-qnty0 in this-procedure .
                end.
              END CASE .
            end.
            when 'все':U then do:
              for-title = substitute("ВСЕ товары, имеющиеся в наличии по объекту &1&2 (факт остаток > 0)"
                                     , pobj-type
                                     , pobj-code).
              CASE rs-sort :
                when 'Артикул':U then dO:
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
                              "FOR EACH gob-doc no-lock"
      parameter-4-22 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty > 0 " + " " + where-phrase-22) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.fact-qnty > 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-22
          else "true"
        )
      parameter-5-22 = (" " + "" + " " + "")
      parameter-6-22 = if sort-phrase-22 = ''
                           then
        (
        " " + " use-index pi  " +
        " " + " "
        )
                           else
        (
        " " + " use-index pi  " +
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
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty > 0 " + " " + where-phrase-22 = "")
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
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty > 0
       use-index pi
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-22 = (if p-find-next then "true":u else "false":u )
      parameter-4-22 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.fact-qnty > 0 ' , chr(34), pobj-type, pobj-code) + " ":u + where-phrase-22 + " ":u + p-find-condition + " " + ""
      parameter-5-22 = " use-index pi  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-22)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
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
      parameter-3-22 =  "FOR EACH gob-doc no-lock"
      parameter-4-22 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty > 0 " + " " + where-phrase-22) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.fact-qnty > 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-22
          else "true"
        )
      parameter-5-22 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-22 = if sort-phrase-22 = ''
                           then
        (
        " " + " use-index pi  " +
        " " + " "
        )
                           else
        (
        " " + " use-index pi  " +
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
                when 'цена':U then dO:
                  RUN fact-price in this-procedure .
                end.
                when 'Количество':U then do:
                  RUN fact-qnty in this-procedure .
                end.
              END CASE .
            end.
            when 'удаленные':U then do:
              for-title = substitute("НЕАКТИВНЫЕ товары, имеющиеся в наличии по объекту &1&2 (факт остаток > 0)"
                                     , pobj-type
                                     , pobj-code).
              CASE rs-sort :
                when 'Артикул':U then dO:
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
                              "FOR EACH gob-doc no-lock"
      parameter-4-24 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.fact-qnty > 0 " + " " + where-phrase-24) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0  and gob-doc.fact-qnty > 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-24
          else "true"
        )
      parameter-5-24 = (" " + "" + " " + "")
      parameter-6-24 = if sort-phrase-24 = ''
                           then
        (
        " " + " use-index pi  " +
        " " + " "
        )
                           else
        (
        " " + " use-index pi  " +
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
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.fact-qnty > 0 " + " " + where-phrase-24 = "")
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
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.fact-qnty > 0
       use-index pi
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-24 = (if p-find-next then "true":u else "false":u )
      parameter-4-24 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0  and gob-doc.fact-qnty > 0 ' , chr(34), pobj-type, pobj-code) + " ":u + where-phrase-24 + " ":u + p-find-condition + " " + ""
      parameter-5-24 = " use-index pi  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-24)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
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
      parameter-3-24 =  "FOR EACH gob-doc no-lock"
      parameter-4-24 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.fact-qnty > 0 " + " " + where-phrase-24) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0  and gob-doc.fact-qnty > 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-24
          else "true"
        )
      parameter-5-24 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-24 = if sort-phrase-24 = ''
                           then
        (
        " " + " use-index pi  " +
        " " + " "
        )
                           else
        (
        " " + " use-index pi  " +
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
                when 'цена':U then dO:
                  RUN fact-price-0 in this-procedure .
                end.
                when 'Количество':U then dO:
                  RUN fact-qnty-0 in this-procedure .
                end.
              END CASE .
            end.
          END CASE .
        end.
        when 'свободно':U then dO:
          CASE g-stat :
            when 'текущие':U then do:
              for-title =  substitute("ТЕКУЩИЕ свободные товары по объекту &1&2 (свободный остаток > 0)"
                                       , pobj-type
                                       , pobj-code).
              CASE rs-sort :
                when 'Артикул':U then do:
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
                              "FOR EACH gob-doc no-lock"
      parameter-4-26 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.free-qnty > 0 " + " " + where-phrase-26) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.free-qnty > 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-26
          else "true"
        )
      parameter-5-26 = (" " + "" + " " + "")
      parameter-6-26 = if sort-phrase-26 = ''
                           then
        (
        " " + " use-index pi  " +
        " " + " "
        )
                           else
        (
        " " + " use-index pi  " +
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
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.free-qnty > 0 " + " " + where-phrase-26 = "")
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
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.free-qnty > 0
       use-index pi
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-26 = (if p-find-next then "true":u else "false":u )
      parameter-4-26 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.free-qnty > 0 ' , chr(34), pobj-type, pobj-code) + " ":u + where-phrase-26 + " ":u + p-find-condition + " " + ""
      parameter-5-26 = " use-index pi  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-26)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
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
      parameter-3-26 =  "FOR EACH gob-doc no-lock"
      parameter-4-26 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.free-qnty > 0 " + " " + where-phrase-26) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.free-qnty > 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-26
          else "true"
        )
      parameter-5-26 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-26 = if sort-phrase-26 = ''
                           then
        (
        " " + " use-index pi  " +
        " " + " "
        )
                           else
        (
        " " + " use-index pi  " +
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
                when 'цена':U then do:
                  RUN free-price0 in this-procedure .
                end.
                when 'Количество':U then do:
                  RUN free-qnty0 in this-procedure .
                end.
              END CASE .
            end.
            when 'все':U then do:
              for-title =  substitute("ВСЕ свободные товары по объекту &1&2 (свободный остаток > 0)"
                                     , pobj-type
                                     , pobj-code).
              CASE rs-sort :
                when 'Артикул':U then do:
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
                              "FOR EACH gob-doc no-lock"
      parameter-4-28 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0 " + " " + where-phrase-28) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.free-qnty > 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-28
          else "true"
        )
      parameter-5-28 = (" " + "" + " " + "")
      parameter-6-28 = if sort-phrase-28 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic                                     by gob-doc.prod-type                                     by gob-doc.prod-code "
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
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0 " + " " + where-phrase-28 = "")
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
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0
       by gob-doc.artic                                     by gob-doc.prod-type                                     by gob-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-28 = (if p-find-next then "true":u else "false":u )
      parameter-4-28 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.free-qnty > 0 ' , chr(34), pobj-type, pobj-code) + " ":u + where-phrase-28 + " ":u + p-find-condition + " " + ""
      parameter-5-28 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-28)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
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
      parameter-3-28 =  "FOR EACH gob-doc no-lock"
      parameter-4-28 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0 " + " " + where-phrase-28) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.free-qnty > 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-28
          else "true"
        )
      parameter-5-28 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-28 = if sort-phrase-28 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic                                     by gob-doc.prod-type                                     by gob-doc.prod-code "
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
                when 'цена':U then dO:
                  RUN free-price in this-procedure .
                end.
                when 'Количество':U then do:
                  RUN free-qnty in this-procedure .
                end.
              END CASE .
            end.
            when 'удаленные':U then do:
              for-title = substitute("НЕАКТИВНЫЕ свободные товары по объекту &1&2 (свободный остаток > 0)"
                                      , pobj-type
                                      , pobj-code).
            CASE rs-sort :
                when 'Артикул':U then do:
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
                              "FOR EACH gob-doc no-lock"
      parameter-4-30 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0 and gob-doc.stts <> 0 " + " " + where-phrase-30) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.free-qnty > 0 and gob-doc.stts <> 0  ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-30
          else "true"
        )
      parameter-5-30 = (" " + "" + " " + "")
      parameter-6-30 = if sort-phrase-30 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic                                     by gob-doc.prod-type                                     by gob-doc.prod-code "
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
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0 and gob-doc.stts <> 0 " + " " + where-phrase-30 = "")
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
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0 and gob-doc.stts <> 0
       by gob-doc.artic                                     by gob-doc.prod-type                                     by gob-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-30 = (if p-find-next then "true":u else "false":u )
      parameter-4-30 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.free-qnty > 0 and gob-doc.stts <> 0  ' , chr(34), pobj-type, pobj-code) + " ":u + where-phrase-30 + " ":u + p-find-condition + " " + ""
      parameter-5-30 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-30)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
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
      parameter-3-30 =  "FOR EACH gob-doc no-lock"
      parameter-4-30 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0 and gob-doc.stts <> 0 " + " " + where-phrase-30) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.free-qnty > 0 and gob-doc.stts <> 0  ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-30
          else "true"
        )
      parameter-5-30 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-30 = if sort-phrase-30 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic                                     by gob-doc.prod-type                                     by gob-doc.prod-code "
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
                when 'цена':U then do:
                  RUN free-price-0 in this-procedure .
                end.
                when 'Количество':U then do:
                  RUN free-qnty-0 in this-procedure .
                end.
              END CASE .
            end.
          END CASE .
        end.
      END CASE .
  end.
  when 'Производитель':U then do:
      CASE g-cond :
        when 'объект':U then do:
          CASE g-stat :
            when 'текущие':U then do:
              for-title = substitute("ТЕКУЩИЕ товары по объекту &1&2 с производителем : &3"
                                          , pobj-type
                                          , pobj-code
                                          , g-producer.obj-name).
              CASE rs-sort :
                when 'Артикул':U then do:
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
                              "FOR EACH gob-doc no-lock"
      parameter-4-32 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-32) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5'                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-32
          else "true"
        )
      parameter-5-32 = (" " + "" + " " + "")
      parameter-6-32 = if sort-phrase-32 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic "
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
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-32 = "")
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
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code
       by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-32 = (if p-find-next then "true":u else "false":u )
      parameter-4-32 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5'                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-32 + " ":u + p-find-condition + " " + ""
      parameter-5-32 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-32)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
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
      parameter-3-32 =  "FOR EACH gob-doc no-lock"
      parameter-4-32 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-32) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5'                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-32
          else "true"
        )
      parameter-5-32 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-32 = if sort-phrase-32 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic "
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
                when 'цена':U then do:
                  RUN prod-obj-price0 in this-procedure .
                end.
              END CASE .
            end.
            when 'все':U then do:
              for-title = substitute("ВСЕ товары по объекту &1&2 с производителем : &3"
                                      , pobj-type
                                      , pobj-code
                                      , g-producer.obj-name).
              CASE rs-sort :
                when 'Артикул':U then do:
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
                              "FOR EACH gob-doc no-lock"
      parameter-4-34 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-34) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5'                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-34
          else "true"
        )
      parameter-5-34 = (" " + "" + " " + "")
      parameter-6-34 = if sort-phrase-34 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic "
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
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-34 = "")
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
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code
       by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-34 = (if p-find-next then "true":u else "false":u )
      parameter-4-34 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5'                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-34 + " ":u + p-find-condition + " " + ""
      parameter-5-34 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-34)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
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
      parameter-3-34 =  "FOR EACH gob-doc no-lock"
      parameter-4-34 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-34) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5'                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-34
          else "true"
        )
      parameter-5-34 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-34 = if sort-phrase-34 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic "
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
                when 'цена':U then do:
                  RUN prod-obj-price in this-procedure .
                end.
              END CASE .
            end.
            when 'удаленные':U then do:
              for-title = substitute("НЕАКТИВНЫЕ товары по объекту &1&2 с производителем : &3"
                                      , pobj-type
                                      , pobj-code
                                      , g-producer.obj-name).
              CASE rs-sort :
                when 'Артикул':U then do:
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
                              "FOR EACH gob-doc no-lock"
      parameter-4-36 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-36) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5'                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-36
          else "true"
        )
      parameter-5-36 = (" " + "" + " " + "")
      parameter-6-36 = if sort-phrase-36 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic "
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
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-36 = "")
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
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code
       by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-36 = (if p-find-next then "true":u else "false":u )
      parameter-4-36 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5'                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-36 + " ":u + p-find-condition + " " + ""
      parameter-5-36 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-36)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
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
      parameter-3-36 =  "FOR EACH gob-doc no-lock"
      parameter-4-36 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-36) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5'                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-36
          else "true"
        )
      parameter-5-36 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-36 = if sort-phrase-36 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic "
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
                when 'цена':U then dO:
                  RUN prod-obj-price-0 in this-procedure .
                end.
              END CASE .
            end.
          END CASE .
        end.
        when 'факт':U then do:
          CASE g-stat :
            when 'текущие':U then do:
              for-title = substitute("ТЕКУЩИЕ товары по объекту &1&2 с производителем : &3 (факт остаток > 0)"
                                      , pobj-type
                                      , pobj-code
                                      , g-producer.obj-name).
              CASE rs-sort :
                when 'Артикул':U then do:
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
                              "FOR EACH gob-doc no-lock"
      parameter-4-38 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty > 0" + " " + where-phrase-38) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty > 0 '                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-38
          else "true"
        )
      parameter-5-38 = (" " + "" + " " + "")
      parameter-6-38 = if sort-phrase-38 = ''
                           then
        (
        " " + " use-index pi" +
        " " + " "
        )
                           else
        (
        " " + " use-index pi" +
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
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty > 0" + " " + where-phrase-38 = "")
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
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty > 0
       use-index pi
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-38 = (if p-find-next then "true":u else "false":u )
      parameter-4-38 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty > 0 '                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-38 + " ":u + p-find-condition + " " + ""
      parameter-5-38 = " use-index pi"
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-38)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
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
      parameter-3-38 =  "FOR EACH gob-doc no-lock"
      parameter-4-38 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty > 0" + " " + where-phrase-38) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty > 0 '                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-38
          else "true"
        )
      parameter-5-38 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-38 = if sort-phrase-38 = ''
                           then
        (
        " " + " use-index pi" +
        " " + " "
        )
                           else
        (
        " " + " use-index pi" +
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
                when 'цена':U then dO:
                  RUN prod-fact-price0 in this-procedure .
                end.
                when 'Количество':U then do:
                  RUN prod-fact-qnty0 in this-procedure .
                end.
              END CASE .
            end.
            when 'все':U then do:
              for-title = substitute("ВСЕ товары по объекту &1&2 с производителем : &3 (факт остаток > 0)"
                                        , pobj-type
                                        , pobj-code
                                        , g-producer.obj-name ).
              CASE rs-sort :
                when 'Артикул':U then do:
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
                              "FOR EACH gob-doc no-lock"
      parameter-4-40 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                                    and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty > 0" + " " + where-phrase-40) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                                    and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty > 0 '                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + "")
      parameter-6-40 = if sort-phrase-40 = ''
                           then
        (
        " " + " use-index pi" +
        " " + " "
        )
                           else
        (
        " " + " use-index pi" +
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
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                                    and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty > 0" + " " + where-phrase-40 = "")
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
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                                    and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty > 0
       use-index pi
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-40 = (if p-find-next then "true":u else "false":u )
      parameter-4-40 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                                    and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty > 0 '                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-40 + " ":u + p-find-condition + " " + ""
      parameter-5-40 = " use-index pi"
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-40)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
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
      parameter-3-40 =  "FOR EACH gob-doc no-lock"
      parameter-4-40 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                                    and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty > 0" + " " + where-phrase-40) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                                    and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty > 0 '                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-40 = if sort-phrase-40 = ''
                           then
        (
        " " + " use-index pi" +
        " " + " "
        )
                           else
        (
        " " + " use-index pi" +
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
                when 'цена':U then dO:
                  RUN prod-fact-price in this-procedure .
                end.
                when 'Количество':U then dO:
                  RUN prod-fact-qnty in this-procedure .
                end.
              END CASE .
            end.
            when 'удаленные':U then do:
              for-title = substitute("НЕАКТИВНЫЕ товары по объекту &1&2 с производителем : &3 (факт остаток > 0)"
                                      , pobj-type
                                      , pobj-code
                                      , g-producer.obj-name).
              CASE rs-sort :
                when 'Артикул':U then dO:
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
                              "FOR EACH gob-doc no-lock"
      parameter-4-42 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty > 0" + " " + where-phrase-42) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty > 0 '                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + "")
      parameter-6-42 = if sort-phrase-42 = ''
                           then
        (
        " " + " use-index pi" +
        " " + " "
        )
                           else
        (
        " " + " use-index pi" +
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
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty > 0" + " " + where-phrase-42 = "")
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
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty > 0
       use-index pi
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-42 = (if p-find-next then "true":u else "false":u )
      parameter-4-42 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty > 0 '                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-42 + " ":u + p-find-condition + " " + ""
      parameter-5-42 = " use-index pi"
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-42)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
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
      parameter-3-42 =  "FOR EACH gob-doc no-lock"
      parameter-4-42 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty > 0" + " " + where-phrase-42) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty > 0 '                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-42 = if sort-phrase-42 = ''
                           then
        (
        " " + " use-index pi" +
        " " + " "
        )
                           else
        (
        " " + " use-index pi" +
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
                when 'цена':U then do:
                  RUN prod-fact-price-0 in this-procedure .
                end.
                when 'Количество':U then dO:
                  RUN prod-fact-qnty-0 in this-procedure .
                end.
            END CASE .
          end.
        END CASE .
      end.
      when 'свободно':U then dO:
        CASE g-stat :
          when 'текущие':U then do:
            for-title = substitute("ТЕКУЩИЕ свободные товары по объекту &1&2 с производителем : &3"
                                        , pobj-type
                                        , pobj-code
                                        , g-producer.obj-name).
            CASE rs-sort :
              when 'Артикул':U then do:
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
                              "FOR EACH gob-doc no-lock"
      parameter-4-44 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0" + " " + where-phrase-44) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty > 0 '                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + "")
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic "
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
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0" + " " + where-phrase-44 = "")
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
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0
       by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-44 = (if p-find-next then "true":u else "false":u )
      parameter-4-44 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty > 0 '                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-44 + " ":u + p-find-condition + " " + ""
      parameter-5-44 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-44)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
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
      parameter-3-44 =  "FOR EACH gob-doc no-lock"
      parameter-4-44 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0" + " " + where-phrase-44) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty > 0 '                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic "
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
              when 'цена':U then do:
                RUN prod-free-price0 in this-procedure .
              end.
              when 'Количество':U then dO:
                RUN prod-free-qnty0 in this-procedure .
              end.
            END CASE .
          end.
          when 'все':U then do:
            for-title = substitute("ВСЕ свободные товары по объекту &1&2 с производителем : &3"
                                       , pobj-type
                                       , pobj-code
                                       , g-producer.obj-name).
            CASE rs-sort :
              when 'Артикул':U then do:
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
                              "FOR EACH gob-doc no-lock"
      parameter-4-46 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0" + " " + where-phrase-46) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                                    and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty > 0 '                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-46
          else "true"
        )
      parameter-5-46 = (" " + "" + " " + "")
      parameter-6-46 = if sort-phrase-46 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic "
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
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0" + " " + where-phrase-46 = "")
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
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0
       by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-46 = (if p-find-next then "true":u else "false":u )
      parameter-4-46 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                                    and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty > 0 '                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-46 + " ":u + p-find-condition + " " + ""
      parameter-5-46 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-46)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
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
      parameter-3-46 =  "FOR EACH gob-doc no-lock"
      parameter-4-46 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0" + " " + where-phrase-46) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                                    and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty > 0 '                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-46
          else "true"
        )
      parameter-5-46 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-46 = if sort-phrase-46 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic "
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
              when 'цена':U then do:
                RUN prod-free-price in this-procedure .
              end.
              when 'Количество':U then do:
                RUN prod-free-qnty in this-procedure .
              end.
            END CASE .
          end.
          when 'удаленные':U then do:
            for-title = substitute("НЕАКТИВНЫЕ свободные товары по объекту &1&2 с производителем : "
                                   , pobj-type
                                   , pobj-code
                                   , g-producer.obj-name).
            CASE rs-sort :
              when 'Артикул':U then do:
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
                              "FOR EACH gob-doc no-lock"
      parameter-4-48 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0" + " " + where-phrase-48) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty > 0 '                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-48
          else "true"
        )
      parameter-5-48 = (" " + "" + " " + "")
      parameter-6-48 = if sort-phrase-48 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic "
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
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0" + " " + where-phrase-48 = "")
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
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0
       by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-48 = (if p-find-next then "true":u else "false":u )
      parameter-4-48 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty > 0 '                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-48 + " ":u + p-find-condition + " " + ""
      parameter-5-48 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-48)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
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
      parameter-3-48 =  "FOR EACH gob-doc no-lock"
      parameter-4-48 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0" + " " + where-phrase-48) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty > 0 '                                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-48
          else "true"
        )
      parameter-5-48 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-48 = if sort-phrase-48 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic "
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
                when 'цена':U then do:
                  RUN prod-free-price-0 in this-procedure .
                end.
                when 'Количество':U then do:
                  RUN prod-free-qnty-0 in this-procedure .
                end.
              END CASE .
            end.
          END CASE .
        end.
      END .
  end.
  when 'группа':U then dO:
    CASE g-cond :
      when 'объект':U then do:
        CASE g-stat :
          when 'текущие':U then do:
            for-title = substitute("ТЕКУЩИЕ товары по объекту : &1&2 , группа : &3"
                                    , pobj-type
                                    , pobj-code
                                    , g-grp).
            CASE rs-sort :
              when 'Артикул':U then dO:
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-50  as logical   no-undo .
define variable  l-filter-open-50    as logical   .
define variable  flt-rec-50       as recid     no-undo .
define variable  filter-name-50      as character no-undo .
define variable  where-phrase-50     as character no-undo .
define variable  sort-phrase-50      as character no-undo .
define variable  where-phrase-rus-50 as character no-undo .
define variable  sort-phrase-rus-50  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-50
  ,output filter-name-50
  ,output where-phrase-50
  ,output sort-phrase-50
  ,output where-phrase-rus-50
  ,output sort-phrase-rus-50
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-50
      ) no-error .
  assign
    l-filter-open-50 = false
  .
  if flt-rec-50 <> ?
  then do:
    define variable  parameter-2-50 as character no-undo .
    define variable  parameter-3-50 as character no-undo .
    define variable  parameter-4-50 as character no-undo .
    define variable  parameter-5-50 as character no-undo .
    define variable  parameter-6-50 as character no-undo .
    define variable  parameter-7-50 as character no-undo .
      assign
      parameter-3-50 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-50 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts = 0 " + " " + where-phrase-50) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 and gob-doc.stts = 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " " + where-phrase-50
          else "true"
        )
      parameter-5-50 = (" " + "" + " " + "")
      parameter-6-50 = if sort-phrase-50 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic                                 by gob-doc.prod-type                                 by gob-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-50
        )
      parameter-7-50 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-50 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts = 0 " + " " + where-phrase-50 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-50
                          ,input parameter-4-50
                          ,input parameter-5-50
                          ,input parameter-6-50
                          ,input parameter-7-50
                          )
      .
      assign
        l-filter-open-50 = true
      .
    end.
    if l-filter-open-50 = false then do:
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
  if l-filter-open-50 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts = 0
       by gob-doc.artic                                 by gob-doc.prod-type                                 by gob-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-50 = (if p-find-next then "true":u else "false":u )
      parameter-4-50 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 and gob-doc.stts = 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " ":u + where-phrase-50 + " ":u + p-find-condition + " " + ""
      parameter-5-50 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-50)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-50
                          ,input parameter-5-50
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-50 = (if p-find-next then "true":u else "false":u )
      parameter-3-50 =  "FOR EACH gob-doc no-lock"
      parameter-4-50 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts = 0 " + " " + where-phrase-50) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 and gob-doc.stts = 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " " + where-phrase-50
          else "true"
        )
      parameter-5-50 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-50 = if sort-phrase-50 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic                                 by gob-doc.prod-type                                 by gob-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-50
        )
      parameter-7-50 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-50)
                          ,input no-lock
                          ,input parameter-3-50
                          ,input parameter-4-50
                          ,input parameter-5-50
                          ,input parameter-6-50
                          ,input parameter-7-50
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
              when 'цена':U then do:
                RUN grp-obj-price0 in this-procedure .
              end.
            END CASE .
          end.
          when 'все':U then do:
            for-title = substitute("ВСЕ товары по объекту &1&2 , группа : "
                                     , pobj-type
                                     , pobj-code
                                     , g-grp).
            CASE rs-sort :
              when 'Артикул':U then do:
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-52  as logical   no-undo .
define variable  l-filter-open-52    as logical   .
define variable  flt-rec-52       as recid     no-undo .
define variable  filter-name-52      as character no-undo .
define variable  where-phrase-52     as character no-undo .
define variable  sort-phrase-52      as character no-undo .
define variable  where-phrase-rus-52 as character no-undo .
define variable  sort-phrase-rus-52  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-52
  ,output filter-name-52
  ,output where-phrase-52
  ,output sort-phrase-52
  ,output where-phrase-rus-52
  ,output sort-phrase-rus-52
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-52
      ) no-error .
  assign
    l-filter-open-52 = false
  .
  if flt-rec-52 <> ?
  then do:
    define variable  parameter-2-52 as character no-undo .
    define variable  parameter-3-52 as character no-undo .
    define variable  parameter-4-52 as character no-undo .
    define variable  parameter-5-52 as character no-undo .
    define variable  parameter-6-52 as character no-undo .
    define variable  parameter-7-52 as character no-undo .
      assign
      parameter-3-52 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-52 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-52) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " " + where-phrase-52
          else "true"
        )
      parameter-5-52 = (" " + "" + " " + "")
      parameter-6-52 = if sort-phrase-52 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic                                 by gob-doc.prod-type                                 by gob-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-52
        )
      parameter-7-52 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-52 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-52 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-52
                          ,input parameter-4-52
                          ,input parameter-5-52
                          ,input parameter-6-52
                          ,input parameter-7-52
                          )
      .
      assign
        l-filter-open-52 = true
      .
    end.
    if l-filter-open-52 = false then do:
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
  if l-filter-open-52 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code
       by gob-doc.artic                                 by gob-doc.prod-type                                 by gob-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-52 = (if p-find-next then "true":u else "false":u )
      parameter-4-52 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " ":u + where-phrase-52 + " ":u + p-find-condition + " " + ""
      parameter-5-52 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-52)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-52
                          ,input parameter-5-52
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-52 = (if p-find-next then "true":u else "false":u )
      parameter-3-52 =  "FOR EACH gob-doc no-lock"
      parameter-4-52 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-52) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " " + where-phrase-52
          else "true"
        )
      parameter-5-52 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-52 = if sort-phrase-52 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic                                 by gob-doc.prod-type                                 by gob-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-52
        )
      parameter-7-52 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-52)
                          ,input no-lock
                          ,input parameter-3-52
                          ,input parameter-4-52
                          ,input parameter-5-52
                          ,input parameter-6-52
                          ,input parameter-7-52
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
              when 'цена':U then do:
                RUN grp-obj-price in this-procedure .
              end.
            END CASE .
          end.
          when 'удаленные':U then do:
            for-title = substitute("НЕАКТИВНЫЕ товары по объекту &1&2 , группа : "
                                       , pobj-type
                                       , pobj-code
                                       , g-grp).
            CASE rs-sort :
              when 'Артикул':U then do:
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-54  as logical   no-undo .
define variable  l-filter-open-54    as logical   .
define variable  flt-rec-54       as recid     no-undo .
define variable  filter-name-54      as character no-undo .
define variable  where-phrase-54     as character no-undo .
define variable  sort-phrase-54      as character no-undo .
define variable  where-phrase-rus-54 as character no-undo .
define variable  sort-phrase-rus-54  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-54
  ,output filter-name-54
  ,output where-phrase-54
  ,output sort-phrase-54
  ,output where-phrase-rus-54
  ,output sort-phrase-rus-54
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-54
      ) no-error .
  assign
    l-filter-open-54 = false
  .
  if flt-rec-54 <> ?
  then do:
    define variable  parameter-2-54 as character no-undo .
    define variable  parameter-3-54 as character no-undo .
    define variable  parameter-4-54 as character no-undo .
    define variable  parameter-5-54 as character no-undo .
    define variable  parameter-6-54 as character no-undo .
    define variable  parameter-7-54 as character no-undo .
      assign
      parameter-3-54 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-54 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts <> 0 " + " " + where-phrase-54) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 and gob-doc.stts <> 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " " + where-phrase-54
          else "true"
        )
      parameter-5-54 = (" " + "" + " " + "")
      parameter-6-54 = if sort-phrase-54 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic                                 by gob-doc.prod-type                                 by gob-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-54
        )
      parameter-7-54 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-54 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts <> 0 " + " " + where-phrase-54 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-54
                          ,input parameter-4-54
                          ,input parameter-5-54
                          ,input parameter-6-54
                          ,input parameter-7-54
                          )
      .
      assign
        l-filter-open-54 = true
      .
    end.
    if l-filter-open-54 = false then do:
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
  if l-filter-open-54 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts <> 0
       by gob-doc.artic                                 by gob-doc.prod-type                                 by gob-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-54 = (if p-find-next then "true":u else "false":u )
      parameter-4-54 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 and gob-doc.stts <> 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " ":u + where-phrase-54 + " ":u + p-find-condition + " " + ""
      parameter-5-54 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-54)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-54
                          ,input parameter-5-54
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-54 = (if p-find-next then "true":u else "false":u )
      parameter-3-54 =  "FOR EACH gob-doc no-lock"
      parameter-4-54 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts <> 0 " + " " + where-phrase-54) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 and gob-doc.stts <> 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " " + where-phrase-54
          else "true"
        )
      parameter-5-54 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-54 = if sort-phrase-54 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic                                 by gob-doc.prod-type                                 by gob-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-54
        )
      parameter-7-54 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-54)
                          ,input no-lock
                          ,input parameter-3-54
                          ,input parameter-4-54
                          ,input parameter-5-54
                          ,input parameter-6-54
                          ,input parameter-7-54
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
              when 'цена':U then do:
                RUN grp-obj-price-0 in this-procedure .
              end.
            END CASE .
          end.
        END CASE .
      end.
      when 'факт':U then dO:
        CASE g-stat :
          when 'текущие':U then do:
            for-title = substitute("ТЕКУЩИЕ товары по объекту &1&2, группа : &3 (факт остаток > 0)"
                                        , pobj-type
                                        , pobj-code
                                        , g-grp).
            CASE rs-sort :
              when 'Артикул':U then do:
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-56  as logical   no-undo .
define variable  l-filter-open-56    as logical   .
define variable  flt-rec-56       as recid     no-undo .
define variable  filter-name-56      as character no-undo .
define variable  where-phrase-56     as character no-undo .
define variable  sort-phrase-56      as character no-undo .
define variable  where-phrase-rus-56 as character no-undo .
define variable  sort-phrase-rus-56  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-56
  ,output filter-name-56
  ,output where-phrase-56
  ,output sort-phrase-56
  ,output where-phrase-rus-56
  ,output sort-phrase-rus-56
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-56
      ) no-error .
  assign
    l-filter-open-56 = false
  .
  if flt-rec-56 <> ?
  then do:
    define variable  parameter-2-56 as character no-undo .
    define variable  parameter-3-56 as character no-undo .
    define variable  parameter-4-56 as character no-undo .
    define variable  parameter-5-56 as character no-undo .
    define variable  parameter-6-56 as character no-undo .
    define variable  parameter-7-56 as character no-undo .
      assign
      parameter-3-56 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-56 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.fact-qnty > 0 and gob-doc.stts = 0 " + " " + where-phrase-56) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                                 and gob-doc.fact-qnty > 0 and gob-doc.stts = 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " " + where-phrase-56
          else "true"
        )
      parameter-5-56 = (" " + "" + " " + "")
      parameter-6-56 = if sort-phrase-56 = ''
                           then
        (
        " " + " use-index pi" +
        " " + " "
        )
                           else
        (
        " " + " use-index pi" +
        " " + sort-phrase-56
        )
      parameter-7-56 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-56 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.fact-qnty > 0 and gob-doc.stts = 0 " + " " + where-phrase-56 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-56
                          ,input parameter-4-56
                          ,input parameter-5-56
                          ,input parameter-6-56
                          ,input parameter-7-56
                          )
      .
      assign
        l-filter-open-56 = true
      .
    end.
    if l-filter-open-56 = false then do:
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
  if l-filter-open-56 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.fact-qnty > 0 and gob-doc.stts = 0
       use-index pi
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-56 = (if p-find-next then "true":u else "false":u )
      parameter-4-56 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                                 and gob-doc.fact-qnty > 0 and gob-doc.stts = 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " ":u + where-phrase-56 + " ":u + p-find-condition + " " + ""
      parameter-5-56 = " use-index pi"
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-56)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-56
                          ,input parameter-5-56
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-56 = (if p-find-next then "true":u else "false":u )
      parameter-3-56 =  "FOR EACH gob-doc no-lock"
      parameter-4-56 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.fact-qnty > 0 and gob-doc.stts = 0 " + " " + where-phrase-56) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                                 and gob-doc.fact-qnty > 0 and gob-doc.stts = 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " " + where-phrase-56
          else "true"
        )
      parameter-5-56 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-56 = if sort-phrase-56 = ''
                           then
        (
        " " + " use-index pi" +
        " " + " "
        )
                           else
        (
        " " + " use-index pi" +
        " " + sort-phrase-56
        )
      parameter-7-56 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-56)
                          ,input no-lock
                          ,input parameter-3-56
                          ,input parameter-4-56
                          ,input parameter-5-56
                          ,input parameter-6-56
                          ,input parameter-7-56
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
              when 'цена':U then do:
                RUN grp-fact-price0 in this-procedure .
              end.
              when 'Количество':U then do:
                RUN grp-fact-qnty0 in this-procedure .
              end.
            END CASE .
          end.
          when 'все':U then do:
            for-title = substitute("ВСЕ товары по объекту &1&2 , группа : &3 (факт остаток > 0)"
                                        , pobj-type
                                        , pobj-code
                                        , g-grp).
            CASE rs-sort :
              when 'Артикул':U then do:
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-58  as logical   no-undo .
define variable  l-filter-open-58    as logical   .
define variable  flt-rec-58       as recid     no-undo .
define variable  filter-name-58      as character no-undo .
define variable  where-phrase-58     as character no-undo .
define variable  sort-phrase-58      as character no-undo .
define variable  where-phrase-rus-58 as character no-undo .
define variable  sort-phrase-rus-58  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-58
  ,output filter-name-58
  ,output where-phrase-58
  ,output sort-phrase-58
  ,output where-phrase-rus-58
  ,output sort-phrase-rus-58
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-58
      ) no-error .
  assign
    l-filter-open-58 = false
  .
  if flt-rec-58 <> ?
  then do:
    define variable  parameter-2-58 as character no-undo .
    define variable  parameter-3-58 as character no-undo .
    define variable  parameter-4-58 as character no-undo .
    define variable  parameter-5-58 as character no-undo .
    define variable  parameter-6-58 as character no-undo .
    define variable  parameter-7-58 as character no-undo .
      assign
      parameter-3-58 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-58 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.fact-qnty > 0 " + " " + where-phrase-58) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                                 and gob-doc.fact-qnty > 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " " + where-phrase-58
          else "true"
        )
      parameter-5-58 = (" " + "" + " " + "")
      parameter-6-58 = if sort-phrase-58 = ''
                           then
        (
        " " + " use-index pi" +
        " " + " "
        )
                           else
        (
        " " + " use-index pi" +
        " " + sort-phrase-58
        )
      parameter-7-58 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-58 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.fact-qnty > 0 " + " " + where-phrase-58 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-58
                          ,input parameter-4-58
                          ,input parameter-5-58
                          ,input parameter-6-58
                          ,input parameter-7-58
                          )
      .
      assign
        l-filter-open-58 = true
      .
    end.
    if l-filter-open-58 = false then do:
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
  if l-filter-open-58 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.fact-qnty > 0
       use-index pi
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-58 = (if p-find-next then "true":u else "false":u )
      parameter-4-58 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                                 and gob-doc.fact-qnty > 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " ":u + where-phrase-58 + " ":u + p-find-condition + " " + ""
      parameter-5-58 = " use-index pi"
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-58)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-58
                          ,input parameter-5-58
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-58 = (if p-find-next then "true":u else "false":u )
      parameter-3-58 =  "FOR EACH gob-doc no-lock"
      parameter-4-58 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.fact-qnty > 0 " + " " + where-phrase-58) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                                 and gob-doc.fact-qnty > 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " " + where-phrase-58
          else "true"
        )
      parameter-5-58 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-58 = if sort-phrase-58 = ''
                           then
        (
        " " + " use-index pi" +
        " " + " "
        )
                           else
        (
        " " + " use-index pi" +
        " " + sort-phrase-58
        )
      parameter-7-58 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-58)
                          ,input no-lock
                          ,input parameter-3-58
                          ,input parameter-4-58
                          ,input parameter-5-58
                          ,input parameter-6-58
                          ,input parameter-7-58
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
              when 'цена':U then do:
                RUN grp-fact-price in this-procedure .
              end.
              when 'Количество':U then do:
                RUN grp-fact-qnty in this-procedure .
              end.
            END CASE .
          end.
          when 'удаленные':U then do:
            for-title = substitute("НЕАКТИВНЫЕ товары по объекту &1&2, группа : &3 (факт остаток > 0)"
                                        , pobj-type
                                        , pobj-code
                                        , g-grp).
            CASE rs-sort :
              when 'Артикул':U then do:
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-60  as logical   no-undo .
define variable  l-filter-open-60    as logical   .
define variable  flt-rec-60       as recid     no-undo .
define variable  filter-name-60      as character no-undo .
define variable  where-phrase-60     as character no-undo .
define variable  sort-phrase-60      as character no-undo .
define variable  where-phrase-rus-60 as character no-undo .
define variable  sort-phrase-rus-60  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-60
  ,output filter-name-60
  ,output where-phrase-60
  ,output sort-phrase-60
  ,output where-phrase-rus-60
  ,output sort-phrase-rus-60
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-60
      ) no-error .
  assign
    l-filter-open-60 = false
  .
  if flt-rec-60 <> ?
  then do:
    define variable  parameter-2-60 as character no-undo .
    define variable  parameter-3-60 as character no-undo .
    define variable  parameter-4-60 as character no-undo .
    define variable  parameter-5-60 as character no-undo .
    define variable  parameter-6-60 as character no-undo .
    define variable  parameter-7-60 as character no-undo .
      assign
      parameter-3-60 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-60 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.fact-qnty > 0 and gob-doc.stts <> 0 " + " " + where-phrase-60) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                                 and gob-doc.fact-qnty > 0 and gob-doc.stts <> 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " " + where-phrase-60
          else "true"
        )
      parameter-5-60 = (" " + "" + " " + "")
      parameter-6-60 = if sort-phrase-60 = ''
                           then
        (
        " " + " use-index pi" +
        " " + " "
        )
                           else
        (
        " " + " use-index pi" +
        " " + sort-phrase-60
        )
      parameter-7-60 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-60 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.fact-qnty > 0 and gob-doc.stts <> 0 " + " " + where-phrase-60 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-60
                          ,input parameter-4-60
                          ,input parameter-5-60
                          ,input parameter-6-60
                          ,input parameter-7-60
                          )
      .
      assign
        l-filter-open-60 = true
      .
    end.
    if l-filter-open-60 = false then do:
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
  if l-filter-open-60 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.fact-qnty > 0 and gob-doc.stts <> 0
       use-index pi
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-60 = (if p-find-next then "true":u else "false":u )
      parameter-4-60 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                                 and gob-doc.fact-qnty > 0 and gob-doc.stts <> 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " ":u + where-phrase-60 + " ":u + p-find-condition + " " + ""
      parameter-5-60 = " use-index pi"
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-60)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-60
                          ,input parameter-5-60
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-60 = (if p-find-next then "true":u else "false":u )
      parameter-3-60 =  "FOR EACH gob-doc no-lock"
      parameter-4-60 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.fact-qnty > 0 and gob-doc.stts <> 0 " + " " + where-phrase-60) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                                 and gob-doc.fact-qnty > 0 and gob-doc.stts <> 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " " + where-phrase-60
          else "true"
        )
      parameter-5-60 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-60 = if sort-phrase-60 = ''
                           then
        (
        " " + " use-index pi" +
        " " + " "
        )
                           else
        (
        " " + " use-index pi" +
        " " + sort-phrase-60
        )
      parameter-7-60 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-60)
                          ,input no-lock
                          ,input parameter-3-60
                          ,input parameter-4-60
                          ,input parameter-5-60
                          ,input parameter-6-60
                          ,input parameter-7-60
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
              when 'цена':U then do:
                RUN grp-fact-price-0 in this-procedure .
              end.
              when 'Количество':U then do:
                RUN grp-fact-qnty-0 in this-procedure .
              end.
            END CASE .
          end.
        END CASE .
      end.
      when 'свободно':U then dO:
        CASE g-stat :
          when 'текущие':U then do:
            for-title = substitute("ТЕКУЩИЕ свободные товары на объекте : &1&2, группа : &3"
                                        , pobj-type
                                        , pobj-code
                                        , g-grp).
            CASE rs-sort :
              when 'Артикул':U then dO:
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-62  as logical   no-undo .
define variable  l-filter-open-62    as logical   .
define variable  flt-rec-62       as recid     no-undo .
define variable  filter-name-62      as character no-undo .
define variable  where-phrase-62     as character no-undo .
define variable  sort-phrase-62      as character no-undo .
define variable  where-phrase-rus-62 as character no-undo .
define variable  sort-phrase-rus-62  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-62
  ,output filter-name-62
  ,output where-phrase-62
  ,output sort-phrase-62
  ,output where-phrase-rus-62
  ,output sort-phrase-rus-62
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-62
      ) no-error .
  assign
    l-filter-open-62 = false
  .
  if flt-rec-62 <> ?
  then do:
    define variable  parameter-2-62 as character no-undo .
    define variable  parameter-3-62 as character no-undo .
    define variable  parameter-4-62 as character no-undo .
    define variable  parameter-5-62 as character no-undo .
    define variable  parameter-6-62 as character no-undo .
    define variable  parameter-7-62 as character no-undo .
      assign
      parameter-3-62 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-62 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.free-qnty > 0 and gob-doc.stts = 0 " + " " + where-phrase-62) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                                 and gob-doc.free-qnty > 0 and gob-doc.stts = 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " " + where-phrase-62
          else "true"
        )
      parameter-5-62 = (" " + "" + " " + "")
      parameter-6-62 = if sort-phrase-62 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic                                by gob-doc.prod-type                                by gob-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-62
        )
      parameter-7-62 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-62 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.free-qnty > 0 and gob-doc.stts = 0 " + " " + where-phrase-62 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-62
                          ,input parameter-4-62
                          ,input parameter-5-62
                          ,input parameter-6-62
                          ,input parameter-7-62
                          )
      .
      assign
        l-filter-open-62 = true
      .
    end.
    if l-filter-open-62 = false then do:
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
  if l-filter-open-62 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.free-qnty > 0 and gob-doc.stts = 0
       by gob-doc.artic                                by gob-doc.prod-type                                by gob-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-62 = (if p-find-next then "true":u else "false":u )
      parameter-4-62 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                                 and gob-doc.free-qnty > 0 and gob-doc.stts = 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " ":u + where-phrase-62 + " ":u + p-find-condition + " " + ""
      parameter-5-62 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-62)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-62
                          ,input parameter-5-62
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-62 = (if p-find-next then "true":u else "false":u )
      parameter-3-62 =  "FOR EACH gob-doc no-lock"
      parameter-4-62 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.free-qnty > 0 and gob-doc.stts = 0 " + " " + where-phrase-62) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                                 and gob-doc.free-qnty > 0 and gob-doc.stts = 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " " + where-phrase-62
          else "true"
        )
      parameter-5-62 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-62 = if sort-phrase-62 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic                                by gob-doc.prod-type                                by gob-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-62
        )
      parameter-7-62 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-62)
                          ,input no-lock
                          ,input parameter-3-62
                          ,input parameter-4-62
                          ,input parameter-5-62
                          ,input parameter-6-62
                          ,input parameter-7-62
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
              when 'цена':U then do:
                RUN grp-free-price0 in this-procedure .
              end.
              when 'Количество':U then do:
                RUN grp-free-qnty0 in this-procedure .
              end.
            END CASE .
          end.
          when 'все':U then do:
            for-title =  substitute("ВСЕ свободные товары на объекте : &1&2, группа : &3"
                                         , pobj-type
                                         , pobj-code
                                         , g-grp).
            CASE rs-sort :
              when 'Артикул':U then do:
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-64  as logical   no-undo .
define variable  l-filter-open-64    as logical   .
define variable  flt-rec-64       as recid     no-undo .
define variable  filter-name-64      as character no-undo .
define variable  where-phrase-64     as character no-undo .
define variable  sort-phrase-64      as character no-undo .
define variable  where-phrase-rus-64 as character no-undo .
define variable  sort-phrase-rus-64  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-64
  ,output filter-name-64
  ,output where-phrase-64
  ,output sort-phrase-64
  ,output where-phrase-rus-64
  ,output sort-phrase-rus-64
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-64
      ) no-error .
  assign
    l-filter-open-64 = false
  .
  if flt-rec-64 <> ?
  then do:
    define variable  parameter-2-64 as character no-undo .
    define variable  parameter-3-64 as character no-undo .
    define variable  parameter-4-64 as character no-undo .
    define variable  parameter-5-64 as character no-undo .
    define variable  parameter-6-64 as character no-undo .
    define variable  parameter-7-64 as character no-undo .
      assign
      parameter-3-64 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-64 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.free-qnty > 0 " + " " + where-phrase-64) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                                 and gob-doc.free-qnty > 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " " + where-phrase-64
          else "true"
        )
      parameter-5-64 = (" " + "" + " " + "")
      parameter-6-64 = if sort-phrase-64 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic                                by gob-doc.prod-type                                by gob-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-64
        )
      parameter-7-64 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-64 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.free-qnty > 0 " + " " + where-phrase-64 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-64
                          ,input parameter-4-64
                          ,input parameter-5-64
                          ,input parameter-6-64
                          ,input parameter-7-64
                          )
      .
      assign
        l-filter-open-64 = true
      .
    end.
    if l-filter-open-64 = false then do:
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
  if l-filter-open-64 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.free-qnty > 0
       by gob-doc.artic                                by gob-doc.prod-type                                by gob-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-64 = (if p-find-next then "true":u else "false":u )
      parameter-4-64 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                                 and gob-doc.free-qnty > 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " ":u + where-phrase-64 + " ":u + p-find-condition + " " + ""
      parameter-5-64 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-64)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-64
                          ,input parameter-5-64
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-64 = (if p-find-next then "true":u else "false":u )
      parameter-3-64 =  "FOR EACH gob-doc no-lock"
      parameter-4-64 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.free-qnty > 0 " + " " + where-phrase-64) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                                 and gob-doc.free-qnty > 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " " + where-phrase-64
          else "true"
        )
      parameter-5-64 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-64 = if sort-phrase-64 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic                                by gob-doc.prod-type                                by gob-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-64
        )
      parameter-7-64 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-64)
                          ,input no-lock
                          ,input parameter-3-64
                          ,input parameter-4-64
                          ,input parameter-5-64
                          ,input parameter-6-64
                          ,input parameter-7-64
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
              when 'цена':U then do:
                RUN grp-free-price in this-procedure .
              end.
              when 'Количество':U then do:
                RUN grp-free-qnty in this-procedure .
              end.
            END CASE .
          end.
          when 'удаленные':U then do:
            for-title =  substitute("НЕАКТИВНЫЕ свободные товары на объекте : &1&2, группа : &3"
                                         , pobj-type
                                         , pobj-code
                                         , g-grp).
            CASE rs-sort :
              when 'Артикул':U then do:
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-66  as logical   no-undo .
define variable  l-filter-open-66    as logical   .
define variable  flt-rec-66       as recid     no-undo .
define variable  filter-name-66      as character no-undo .
define variable  where-phrase-66     as character no-undo .
define variable  sort-phrase-66      as character no-undo .
define variable  where-phrase-rus-66 as character no-undo .
define variable  sort-phrase-rus-66  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-66
  ,output filter-name-66
  ,output where-phrase-66
  ,output sort-phrase-66
  ,output where-phrase-rus-66
  ,output sort-phrase-rus-66
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-66
      ) no-error .
  assign
    l-filter-open-66 = false
  .
  if flt-rec-66 <> ?
  then do:
    define variable  parameter-2-66 as character no-undo .
    define variable  parameter-3-66 as character no-undo .
    define variable  parameter-4-66 as character no-undo .
    define variable  parameter-5-66 as character no-undo .
    define variable  parameter-6-66 as character no-undo .
    define variable  parameter-7-66 as character no-undo .
      assign
      parameter-3-66 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-66 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.free-qnty > 0 and gob-doc.stts <> 0 " + " " + where-phrase-66) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                                 and gob-doc.free-qnty > 0 and gob-doc.stts <> 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " " + where-phrase-66
          else "true"
        )
      parameter-5-66 = (" " + "" + " " + "")
      parameter-6-66 = if sort-phrase-66 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic                                by gob-doc.prod-type                                by gob-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-66
        )
      parameter-7-66 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-66 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.free-qnty > 0 and gob-doc.stts <> 0 " + " " + where-phrase-66 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-66
                          ,input parameter-4-66
                          ,input parameter-5-66
                          ,input parameter-6-66
                          ,input parameter-7-66
                          )
      .
      assign
        l-filter-open-66 = true
      .
    end.
    if l-filter-open-66 = false then do:
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
  if l-filter-open-66 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.free-qnty > 0 and gob-doc.stts <> 0
       by gob-doc.artic                                by gob-doc.prod-type                                by gob-doc.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-66 = (if p-find-next then "true":u else "false":u )
      parameter-4-66 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                                 and gob-doc.free-qnty > 0 and gob-doc.stts <> 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " ":u + where-phrase-66 + " ":u + p-find-condition + " " + ""
      parameter-5-66 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-66)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-66
                          ,input parameter-5-66
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-66 = (if p-find-next then "true":u else "false":u )
      parameter-3-66 =  "FOR EACH gob-doc no-lock"
      parameter-4-66 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                                and gob-doc.free-qnty > 0 and gob-doc.stts <> 0 " + " " + where-phrase-66) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                                 and gob-doc.free-qnty > 0 and gob-doc.stts <> 0 '                                  , chr(34), g-grp, pobj-type, pobj-code) + " " + where-phrase-66
          else "true"
        )
      parameter-5-66 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-66 = if sort-phrase-66 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.artic                                by gob-doc.prod-type                                by gob-doc.prod-code "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-66
        )
      parameter-7-66 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-66)
                          ,input no-lock
                          ,input parameter-3-66
                          ,input parameter-4-66
                          ,input parameter-5-66
                          ,input parameter-6-66
                          ,input parameter-7-66
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
              when 'цена':U then do:
                RUN grp-free-price-0 in this-procedure .
              end.
              when 'Количество':U then do:
                RUN grp-free-qnty-0 in this-procedure .
              end.
            END CASE .
          end.
        END CASE .
      end.
    END CASE.
END .
END CASE.
return.
PROCEDURE obj-price0.
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-68  as logical   no-undo .
define variable  l-filter-open-68    as logical   .
define variable  flt-rec-68       as recid     no-undo .
define variable  filter-name-68      as character no-undo .
define variable  where-phrase-68     as character no-undo .
define variable  sort-phrase-68      as character no-undo .
define variable  where-phrase-rus-68 as character no-undo .
define variable  sort-phrase-rus-68  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-68
  ,output filter-name-68
  ,output where-phrase-68
  ,output sort-phrase-68
  ,output where-phrase-rus-68
  ,output sort-phrase-rus-68
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-68
      ) no-error .
  assign
    l-filter-open-68 = false
  .
  if flt-rec-68 <> ?
  then do:
    define variable  parameter-2-68 as character no-undo .
    define variable  parameter-3-68 as character no-undo .
    define variable  parameter-4-68 as character no-undo .
    define variable  parameter-5-68 as character no-undo .
    define variable  parameter-6-68 as character no-undo .
    define variable  parameter-7-68 as character no-undo .
      assign
      parameter-3-68 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-68 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts = 0 " + " " + where-phrase-68) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0 ', chr(34), pobj-type, pobj-code) + " " + where-phrase-68
          else "true"
        )
      parameter-5-68 = (" " + "" + " " + "")
      parameter-6-68 = if sort-phrase-68 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.price-sale                     BY gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-68
        )
      parameter-7-68 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-68 =
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts = 0 " + " " + where-phrase-68 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-68
                          ,input parameter-4-68
                          ,input parameter-5-68
                          ,input parameter-6-68
                          ,input parameter-7-68
                          )
      .
      assign
        l-filter-open-68 = true
      .
    end.
    if l-filter-open-68 = false then do:
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
  if l-filter-open-68 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts = 0
       by gob-doc.price-sale                     BY gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-68 = (if p-find-next then "true":u else "false":u )
      parameter-4-68 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0 ', chr(34), pobj-type, pobj-code) + " ":u + where-phrase-68 + " ":u + p-find-condition + " " + ""
      parameter-5-68 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-68)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-68
                          ,input parameter-5-68
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-68 = (if p-find-next then "true":u else "false":u )
      parameter-3-68 =  "FOR EACH gob-doc no-lock"
      parameter-4-68 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts = 0 " + " " + where-phrase-68) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0 ', chr(34), pobj-type, pobj-code) + " " + where-phrase-68
          else "true"
        )
      parameter-5-68 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-68 = if sort-phrase-68 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.price-sale                     BY gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-68
        )
      parameter-7-68 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-68)
                          ,input no-lock
                          ,input parameter-3-68
                          ,input parameter-4-68
                          ,input parameter-5-68
                          ,input parameter-6-68
                          ,input parameter-7-68
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
END PROCEDURE.
PROCEDURE obj-price.
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-70  as logical   no-undo .
define variable  l-filter-open-70    as logical   .
define variable  flt-rec-70       as recid     no-undo .
define variable  filter-name-70      as character no-undo .
define variable  where-phrase-70     as character no-undo .
define variable  sort-phrase-70      as character no-undo .
define variable  where-phrase-rus-70 as character no-undo .
define variable  sort-phrase-rus-70  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-70
  ,output filter-name-70
  ,output where-phrase-70
  ,output sort-phrase-70
  ,output where-phrase-rus-70
  ,output sort-phrase-rus-70
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-70
      ) no-error .
  assign
    l-filter-open-70 = false
  .
  if flt-rec-70 <> ?
  then do:
    define variable  parameter-2-70 as character no-undo .
    define variable  parameter-3-70 as character no-undo .
    define variable  parameter-4-70 as character no-undo .
    define variable  parameter-5-70 as character no-undo .
    define variable  parameter-6-70 as character no-undo .
    define variable  parameter-7-70 as character no-undo .
      assign
      parameter-3-70 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-70 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  " + " " + where-phrase-70) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 ', chr(34), pobj-type, pobj-code) + " " + where-phrase-70
          else "true"
        )
      parameter-5-70 = (" " + "" + " " + "")
      parameter-6-70 = if sort-phrase-70 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.price-sale                     BY gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-70
        )
      parameter-7-70 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-70 =
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  " + " " + where-phrase-70 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-70
                          ,input parameter-4-70
                          ,input parameter-5-70
                          ,input parameter-6-70
                          ,input parameter-7-70
                          )
      .
      assign
        l-filter-open-70 = true
      .
    end.
    if l-filter-open-70 = false then do:
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
  if l-filter-open-70 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code
       by gob-doc.price-sale                     BY gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-70 = (if p-find-next then "true":u else "false":u )
      parameter-4-70 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 ', chr(34), pobj-type, pobj-code) + " ":u + where-phrase-70 + " ":u + p-find-condition + " " + ""
      parameter-5-70 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-70)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-70
                          ,input parameter-5-70
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-70 = (if p-find-next then "true":u else "false":u )
      parameter-3-70 =  "FOR EACH gob-doc no-lock"
      parameter-4-70 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  " + " " + where-phrase-70) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 ', chr(34), pobj-type, pobj-code) + " " + where-phrase-70
          else "true"
        )
      parameter-5-70 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-70 = if sort-phrase-70 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.price-sale                     BY gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-70
        )
      parameter-7-70 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-70)
                          ,input no-lock
                          ,input parameter-3-70
                          ,input parameter-4-70
                          ,input parameter-5-70
                          ,input parameter-6-70
                          ,input parameter-7-70
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
END PROCEDURE.
PROCEDURE obj-price-0.
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-72  as logical   no-undo .
define variable  l-filter-open-72    as logical   .
define variable  flt-rec-72       as recid     no-undo .
define variable  filter-name-72      as character no-undo .
define variable  where-phrase-72     as character no-undo .
define variable  sort-phrase-72      as character no-undo .
define variable  where-phrase-rus-72 as character no-undo .
define variable  sort-phrase-rus-72  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-72
  ,output filter-name-72
  ,output where-phrase-72
  ,output sort-phrase-72
  ,output where-phrase-rus-72
  ,output sort-phrase-rus-72
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-72
      ) no-error .
  assign
    l-filter-open-72 = false
  .
  if flt-rec-72 <> ?
  then do:
    define variable  parameter-2-72 as character no-undo .
    define variable  parameter-3-72 as character no-undo .
    define variable  parameter-4-72 as character no-undo .
    define variable  parameter-5-72 as character no-undo .
    define variable  parameter-6-72 as character no-undo .
    define variable  parameter-7-72 as character no-undo .
      assign
      parameter-3-72 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-72 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts <> 0 " + " " + where-phrase-72) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0 ', chr(34), pobj-type, pobj-code) + " " + where-phrase-72
          else "true"
        )
      parameter-5-72 = (" " + "" + " " + "")
      parameter-6-72 = if sort-phrase-72 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.price-sale                     BY gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-72
        )
      parameter-7-72 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-72 =
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts <> 0 " + " " + where-phrase-72 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-72
                          ,input parameter-4-72
                          ,input parameter-5-72
                          ,input parameter-6-72
                          ,input parameter-7-72
                          )
      .
      assign
        l-filter-open-72 = true
      .
    end.
    if l-filter-open-72 = false then do:
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
  if l-filter-open-72 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts <> 0
       by gob-doc.price-sale                     BY gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-72 = (if p-find-next then "true":u else "false":u )
      parameter-4-72 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0 ', chr(34), pobj-type, pobj-code) + " ":u + where-phrase-72 + " ":u + p-find-condition + " " + ""
      parameter-5-72 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-72)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-72
                          ,input parameter-5-72
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-72 = (if p-find-next then "true":u else "false":u )
      parameter-3-72 =  "FOR EACH gob-doc no-lock"
      parameter-4-72 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts <> 0 " + " " + where-phrase-72) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0 ', chr(34), pobj-type, pobj-code) + " " + where-phrase-72
          else "true"
        )
      parameter-5-72 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-72 = if sort-phrase-72 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.price-sale                     BY gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-72
        )
      parameter-7-72 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-72)
                          ,input no-lock
                          ,input parameter-3-72
                          ,input parameter-4-72
                          ,input parameter-5-72
                          ,input parameter-6-72
                          ,input parameter-7-72
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
END PROCEDURE.
PROCEDURE fact-price0.
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-74  as logical   no-undo .
define variable  l-filter-open-74    as logical   .
define variable  flt-rec-74       as recid     no-undo .
define variable  filter-name-74      as character no-undo .
define variable  where-phrase-74     as character no-undo .
define variable  sort-phrase-74      as character no-undo .
define variable  where-phrase-rus-74 as character no-undo .
define variable  sort-phrase-rus-74  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-74
  ,output filter-name-74
  ,output where-phrase-74
  ,output sort-phrase-74
  ,output where-phrase-rus-74
  ,output sort-phrase-rus-74
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-74
      ) no-error .
  assign
    l-filter-open-74 = false
  .
  if flt-rec-74 <> ?
  then do:
    define variable  parameter-2-74 as character no-undo .
    define variable  parameter-3-74 as character no-undo .
    define variable  parameter-4-74 as character no-undo .
    define variable  parameter-5-74 as character no-undo .
    define variable  parameter-6-74 as character no-undo .
    define variable  parameter-7-74 as character no-undo .
      assign
      parameter-3-74 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-74 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.fact-qnty <> 0 " + " " + where-phrase-74) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.fact-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-74
          else "true"
        )
      parameter-5-74 = (" " + " use-index obj-price " + " " + "")
      parameter-6-74 = if sort-phrase-74 = ''
                           then
        (
        " " + "" +
        " " + "  "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-74
        )
      parameter-7-74 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-74 =
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.fact-qnty <> 0 " + " " + where-phrase-74 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-74
                          ,input parameter-4-74
                          ,input parameter-5-74
                          ,input parameter-6-74
                          ,input parameter-7-74
                          )
      .
      assign
        l-filter-open-74 = true
      .
    end.
    if l-filter-open-74 = false then do:
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
  if l-filter-open-74 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.fact-qnty <> 0
     use-index obj-price
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-74 = (if p-find-next then "true":u else "false":u )
      parameter-4-74 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.fact-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " ":u + where-phrase-74 + " ":u + p-find-condition + " " + " use-index obj-price "
      parameter-5-74 = ""
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-74)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-74
                          ,input parameter-5-74
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-74 = (if p-find-next then "true":u else "false":u )
      parameter-3-74 =  "FOR EACH gob-doc no-lock"
      parameter-4-74 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.fact-qnty <> 0 " + " " + where-phrase-74) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.fact-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-74
          else "true"
        )
      parameter-5-74 = (" " + " use-index obj-price " + " " + "" + " " + p-find-condition)
      parameter-6-74 = if sort-phrase-74 = ''
                           then
        (
        " " + "" +
        " " + "  "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-74
        )
      parameter-7-74 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-74)
                          ,input no-lock
                          ,input parameter-3-74
                          ,input parameter-4-74
                          ,input parameter-5-74
                          ,input parameter-6-74
                          ,input parameter-7-74
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
END PROCEDURE.
PROCEDURE fact-qnty0.
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-76  as logical   no-undo .
define variable  l-filter-open-76    as logical   .
define variable  flt-rec-76       as recid     no-undo .
define variable  filter-name-76      as character no-undo .
define variable  where-phrase-76     as character no-undo .
define variable  sort-phrase-76      as character no-undo .
define variable  where-phrase-rus-76 as character no-undo .
define variable  sort-phrase-rus-76  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-76
  ,output filter-name-76
  ,output where-phrase-76
  ,output sort-phrase-76
  ,output where-phrase-rus-76
  ,output sort-phrase-rus-76
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-76
      ) no-error .
  assign
    l-filter-open-76 = false
  .
  if flt-rec-76 <> ?
  then do:
    define variable  parameter-2-76 as character no-undo .
    define variable  parameter-3-76 as character no-undo .
    define variable  parameter-4-76 as character no-undo .
    define variable  parameter-5-76 as character no-undo .
    define variable  parameter-6-76 as character no-undo .
    define variable  parameter-7-76 as character no-undo .
      assign
      parameter-3-76 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-76 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.fact-qnty <> 0 " + " " + where-phrase-76) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.fact-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-76
          else "true"
        )
      parameter-5-76 = (" " + " use-index obj-qnty " + " " + "")
      parameter-6-76 = if sort-phrase-76 = ''
                           then
        (
        " " + "" +
        " " + "  "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-76
        )
      parameter-7-76 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-76 =
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.fact-qnty <> 0 " + " " + where-phrase-76 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-76
                          ,input parameter-4-76
                          ,input parameter-5-76
                          ,input parameter-6-76
                          ,input parameter-7-76
                          )
      .
      assign
        l-filter-open-76 = true
      .
    end.
    if l-filter-open-76 = false then do:
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
  if l-filter-open-76 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.fact-qnty <> 0
     use-index obj-qnty
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-76 = (if p-find-next then "true":u else "false":u )
      parameter-4-76 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.fact-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " ":u + where-phrase-76 + " ":u + p-find-condition + " " + " use-index obj-qnty "
      parameter-5-76 = ""
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-76)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-76
                          ,input parameter-5-76
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-76 = (if p-find-next then "true":u else "false":u )
      parameter-3-76 =  "FOR EACH gob-doc no-lock"
      parameter-4-76 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.fact-qnty <> 0 " + " " + where-phrase-76) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.fact-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-76
          else "true"
        )
      parameter-5-76 = (" " + " use-index obj-qnty " + " " + "" + " " + p-find-condition)
      parameter-6-76 = if sort-phrase-76 = ''
                           then
        (
        " " + "" +
        " " + "  "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-76
        )
      parameter-7-76 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-76)
                          ,input no-lock
                          ,input parameter-3-76
                          ,input parameter-4-76
                          ,input parameter-5-76
                          ,input parameter-6-76
                          ,input parameter-7-76
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
END PROCEDURE.
PROCEDURE fact-price.
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-78  as logical   no-undo .
define variable  l-filter-open-78    as logical   .
define variable  flt-rec-78       as recid     no-undo .
define variable  filter-name-78      as character no-undo .
define variable  where-phrase-78     as character no-undo .
define variable  sort-phrase-78      as character no-undo .
define variable  where-phrase-rus-78 as character no-undo .
define variable  sort-phrase-rus-78  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-78
  ,output filter-name-78
  ,output where-phrase-78
  ,output sort-phrase-78
  ,output where-phrase-rus-78
  ,output sort-phrase-rus-78
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-78
      ) no-error .
  assign
    l-filter-open-78 = false
  .
  if flt-rec-78 <> ?
  then do:
    define variable  parameter-2-78 as character no-undo .
    define variable  parameter-3-78 as character no-undo .
    define variable  parameter-4-78 as character no-undo .
    define variable  parameter-5-78 as character no-undo .
    define variable  parameter-6-78 as character no-undo .
    define variable  parameter-7-78 as character no-undo .
      assign
      parameter-3-78 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-78 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0 " + " " + where-phrase-78) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.fact-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-78
          else "true"
        )
      parameter-5-78 = (" " + "" + " " + "")
      parameter-6-78 = if sort-phrase-78 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.price-sale                     by gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-78
        )
      parameter-7-78 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-78 =
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0 " + " " + where-phrase-78 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-78
                          ,input parameter-4-78
                          ,input parameter-5-78
                          ,input parameter-6-78
                          ,input parameter-7-78
                          )
      .
      assign
        l-filter-open-78 = true
      .
    end.
    if l-filter-open-78 = false then do:
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
  if l-filter-open-78 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0
       by gob-doc.price-sale                     by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-78 = (if p-find-next then "true":u else "false":u )
      parameter-4-78 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.fact-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " ":u + where-phrase-78 + " ":u + p-find-condition + " " + ""
      parameter-5-78 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-78)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-78
                          ,input parameter-5-78
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-78 = (if p-find-next then "true":u else "false":u )
      parameter-3-78 =  "FOR EACH gob-doc no-lock"
      parameter-4-78 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0 " + " " + where-phrase-78) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.fact-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-78
          else "true"
        )
      parameter-5-78 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-78 = if sort-phrase-78 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.price-sale                     by gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-78
        )
      parameter-7-78 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-78)
                          ,input no-lock
                          ,input parameter-3-78
                          ,input parameter-4-78
                          ,input parameter-5-78
                          ,input parameter-6-78
                          ,input parameter-7-78
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
END PROCEDURE.
PROCEDURE fact-qnty.
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-80  as logical   no-undo .
define variable  l-filter-open-80    as logical   .
define variable  flt-rec-80       as recid     no-undo .
define variable  filter-name-80      as character no-undo .
define variable  where-phrase-80     as character no-undo .
define variable  sort-phrase-80      as character no-undo .
define variable  where-phrase-rus-80 as character no-undo .
define variable  sort-phrase-rus-80  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-80
  ,output filter-name-80
  ,output where-phrase-80
  ,output sort-phrase-80
  ,output where-phrase-rus-80
  ,output sort-phrase-rus-80
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-80
      ) no-error .
  assign
    l-filter-open-80 = false
  .
  if flt-rec-80 <> ?
  then do:
    define variable  parameter-2-80 as character no-undo .
    define variable  parameter-3-80 as character no-undo .
    define variable  parameter-4-80 as character no-undo .
    define variable  parameter-5-80 as character no-undo .
    define variable  parameter-6-80 as character no-undo .
    define variable  parameter-7-80 as character no-undo .
      assign
      parameter-3-80 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-80 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.fact-qnty <> 0 " + " " + where-phrase-80) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.fact-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-80
          else "true"
        )
      parameter-5-80 = (" " + "" + " " + "")
      parameter-6-80 = if sort-phrase-80 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.fact-qnty                     by gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-80
        )
      parameter-7-80 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-80 =
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.fact-qnty <> 0 " + " " + where-phrase-80 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-80
                          ,input parameter-4-80
                          ,input parameter-5-80
                          ,input parameter-6-80
                          ,input parameter-7-80
                          )
      .
      assign
        l-filter-open-80 = true
      .
    end.
    if l-filter-open-80 = false then do:
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
  if l-filter-open-80 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.fact-qnty <> 0
       by gob-doc.fact-qnty                     by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-80 = (if p-find-next then "true":u else "false":u )
      parameter-4-80 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.fact-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " ":u + where-phrase-80 + " ":u + p-find-condition + " " + ""
      parameter-5-80 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-80)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-80
                          ,input parameter-5-80
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-80 = (if p-find-next then "true":u else "false":u )
      parameter-3-80 =  "FOR EACH gob-doc no-lock"
      parameter-4-80 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.fact-qnty <> 0 " + " " + where-phrase-80) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.fact-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-80
          else "true"
        )
      parameter-5-80 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-80 = if sort-phrase-80 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.fact-qnty                     by gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-80
        )
      parameter-7-80 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-80)
                          ,input no-lock
                          ,input parameter-3-80
                          ,input parameter-4-80
                          ,input parameter-5-80
                          ,input parameter-6-80
                          ,input parameter-7-80
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
END PROCEDURE.
PROCEDURE fact-price-0.
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-82  as logical   no-undo .
define variable  l-filter-open-82    as logical   .
define variable  flt-rec-82       as recid     no-undo .
define variable  filter-name-82      as character no-undo .
define variable  where-phrase-82     as character no-undo .
define variable  sort-phrase-82      as character no-undo .
define variable  where-phrase-rus-82 as character no-undo .
define variable  sort-phrase-rus-82  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-82
  ,output filter-name-82
  ,output where-phrase-82
  ,output sort-phrase-82
  ,output where-phrase-rus-82
  ,output sort-phrase-rus-82
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-82
      ) no-error .
  assign
    l-filter-open-82 = false
  .
  if flt-rec-82 <> ?
  then do:
    define variable  parameter-2-82 as character no-undo .
    define variable  parameter-3-82 as character no-undo .
    define variable  parameter-4-82 as character no-undo .
    define variable  parameter-5-82 as character no-undo .
    define variable  parameter-6-82 as character no-undo .
    define variable  parameter-7-82 as character no-undo .
      assign
      parameter-3-82 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-82 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.fact-qnty <> 0 " + " " + where-phrase-82) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0  and gob-doc.fact-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-82
          else "true"
        )
      parameter-5-82 = (" " + "" + " " + "")
      parameter-6-82 = if sort-phrase-82 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.price-sale                     by gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-82
        )
      parameter-7-82 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-82 =
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.fact-qnty <> 0 " + " " + where-phrase-82 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-82
                          ,input parameter-4-82
                          ,input parameter-5-82
                          ,input parameter-6-82
                          ,input parameter-7-82
                          )
      .
      assign
        l-filter-open-82 = true
      .
    end.
    if l-filter-open-82 = false then do:
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
  if l-filter-open-82 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.fact-qnty <> 0
       by gob-doc.price-sale                     by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-82 = (if p-find-next then "true":u else "false":u )
      parameter-4-82 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0  and gob-doc.fact-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " ":u + where-phrase-82 + " ":u + p-find-condition + " " + ""
      parameter-5-82 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-82)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-82
                          ,input parameter-5-82
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-82 = (if p-find-next then "true":u else "false":u )
      parameter-3-82 =  "FOR EACH gob-doc no-lock"
      parameter-4-82 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.fact-qnty <> 0 " + " " + where-phrase-82) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0  and gob-doc.fact-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-82
          else "true"
        )
      parameter-5-82 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-82 = if sort-phrase-82 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.price-sale                     by gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-82
        )
      parameter-7-82 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-82)
                          ,input no-lock
                          ,input parameter-3-82
                          ,input parameter-4-82
                          ,input parameter-5-82
                          ,input parameter-6-82
                          ,input parameter-7-82
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
END PROCEDURE.
PROCEDURE fact-qnty-0.
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-84  as logical   no-undo .
define variable  l-filter-open-84    as logical   .
define variable  flt-rec-84       as recid     no-undo .
define variable  filter-name-84      as character no-undo .
define variable  where-phrase-84     as character no-undo .
define variable  sort-phrase-84      as character no-undo .
define variable  where-phrase-rus-84 as character no-undo .
define variable  sort-phrase-rus-84  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-84
  ,output filter-name-84
  ,output where-phrase-84
  ,output sort-phrase-84
  ,output where-phrase-rus-84
  ,output sort-phrase-rus-84
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-84
      ) no-error .
  assign
    l-filter-open-84 = false
  .
  if flt-rec-84 <> ?
  then do:
    define variable  parameter-2-84 as character no-undo .
    define variable  parameter-3-84 as character no-undo .
    define variable  parameter-4-84 as character no-undo .
    define variable  parameter-5-84 as character no-undo .
    define variable  parameter-6-84 as character no-undo .
    define variable  parameter-7-84 as character no-undo .
      assign
      parameter-3-84 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-84 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.fact-qnty <> 0 " + " " + where-phrase-84) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0  and gob-doc.fact-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-84
          else "true"
        )
      parameter-5-84 = (" " + "" + " " + "")
      parameter-6-84 = if sort-phrase-84 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.fact-qnty                     by gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-84
        )
      parameter-7-84 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-84 =
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.fact-qnty <> 0 " + " " + where-phrase-84 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-84
                          ,input parameter-4-84
                          ,input parameter-5-84
                          ,input parameter-6-84
                          ,input parameter-7-84
                          )
      .
      assign
        l-filter-open-84 = true
      .
    end.
    if l-filter-open-84 = false then do:
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
  if l-filter-open-84 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.fact-qnty <> 0
       by gob-doc.fact-qnty                     by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-84 = (if p-find-next then "true":u else "false":u )
      parameter-4-84 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0  and gob-doc.fact-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " ":u + where-phrase-84 + " ":u + p-find-condition + " " + ""
      parameter-5-84 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-84)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-84
                          ,input parameter-5-84
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-84 = (if p-find-next then "true":u else "false":u )
      parameter-3-84 =  "FOR EACH gob-doc no-lock"
      parameter-4-84 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.fact-qnty <> 0 " + " " + where-phrase-84) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0  and gob-doc.fact-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-84
          else "true"
        )
      parameter-5-84 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-84 = if sort-phrase-84 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.fact-qnty                     by gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-84
        )
      parameter-7-84 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-84)
                          ,input no-lock
                          ,input parameter-3-84
                          ,input parameter-4-84
                          ,input parameter-5-84
                          ,input parameter-6-84
                          ,input parameter-7-84
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
END PROCEDURE.
PROCEDURE free-price0.
define variable vss-include-info85 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-86  as logical   no-undo .
define variable  l-filter-open-86    as logical   .
define variable  flt-rec-86       as recid     no-undo .
define variable  filter-name-86      as character no-undo .
define variable  where-phrase-86     as character no-undo .
define variable  sort-phrase-86      as character no-undo .
define variable  where-phrase-rus-86 as character no-undo .
define variable  sort-phrase-rus-86  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-86
  ,output filter-name-86
  ,output where-phrase-86
  ,output sort-phrase-86
  ,output where-phrase-rus-86
  ,output sort-phrase-rus-86
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-86
      ) no-error .
  assign
    l-filter-open-86 = false
  .
  if flt-rec-86 <> ?
  then do:
    define variable  parameter-2-86 as character no-undo .
    define variable  parameter-3-86 as character no-undo .
    define variable  parameter-4-86 as character no-undo .
    define variable  parameter-5-86 as character no-undo .
    define variable  parameter-6-86 as character no-undo .
    define variable  parameter-7-86 as character no-undo .
      assign
      parameter-3-86 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-86 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.free-qnty <> 0 " + " " + where-phrase-86) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.free-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-86
          else "true"
        )
      parameter-5-86 = (" " + "" + " " + "")
      parameter-6-86 = if sort-phrase-86 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.price-sale                     by gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-86
        )
      parameter-7-86 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-86 =
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.free-qnty <> 0 " + " " + where-phrase-86 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-86
                          ,input parameter-4-86
                          ,input parameter-5-86
                          ,input parameter-6-86
                          ,input parameter-7-86
                          )
      .
      assign
        l-filter-open-86 = true
      .
    end.
    if l-filter-open-86 = false then do:
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
  if l-filter-open-86 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.free-qnty <> 0
       by gob-doc.price-sale                     by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-86 = (if p-find-next then "true":u else "false":u )
      parameter-4-86 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.free-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " ":u + where-phrase-86 + " ":u + p-find-condition + " " + ""
      parameter-5-86 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-86)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-86
                          ,input parameter-5-86
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-86 = (if p-find-next then "true":u else "false":u )
      parameter-3-86 =  "FOR EACH gob-doc no-lock"
      parameter-4-86 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.free-qnty <> 0 " + " " + where-phrase-86) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.free-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-86
          else "true"
        )
      parameter-5-86 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-86 = if sort-phrase-86 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.price-sale                     by gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-86
        )
      parameter-7-86 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-86)
                          ,input no-lock
                          ,input parameter-3-86
                          ,input parameter-4-86
                          ,input parameter-5-86
                          ,input parameter-6-86
                          ,input parameter-7-86
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
END PROCEDURE.
PROCEDURE free-qnty0.
define variable vss-include-info87 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-88  as logical   no-undo .
define variable  l-filter-open-88    as logical   .
define variable  flt-rec-88       as recid     no-undo .
define variable  filter-name-88      as character no-undo .
define variable  where-phrase-88     as character no-undo .
define variable  sort-phrase-88      as character no-undo .
define variable  where-phrase-rus-88 as character no-undo .
define variable  sort-phrase-rus-88  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-88
  ,output filter-name-88
  ,output where-phrase-88
  ,output sort-phrase-88
  ,output where-phrase-rus-88
  ,output sort-phrase-rus-88
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-88
      ) no-error .
  assign
    l-filter-open-88 = false
  .
  if flt-rec-88 <> ?
  then do:
    define variable  parameter-2-88 as character no-undo .
    define variable  parameter-3-88 as character no-undo .
    define variable  parameter-4-88 as character no-undo .
    define variable  parameter-5-88 as character no-undo .
    define variable  parameter-6-88 as character no-undo .
    define variable  parameter-7-88 as character no-undo .
      assign
      parameter-3-88 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-88 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.free-qnty <> 0 " + " " + where-phrase-88) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.free-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-88
          else "true"
        )
      parameter-5-88 = (" " + "" + " " + "")
      parameter-6-88 = if sort-phrase-88 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.free-qnty                     by gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-88
        )
      parameter-7-88 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-88 =
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.free-qnty <> 0 " + " " + where-phrase-88 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-88
                          ,input parameter-4-88
                          ,input parameter-5-88
                          ,input parameter-6-88
                          ,input parameter-7-88
                          )
      .
      assign
        l-filter-open-88 = true
      .
    end.
    if l-filter-open-88 = false then do:
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
  if l-filter-open-88 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.free-qnty <> 0
       by gob-doc.free-qnty                     by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-88 = (if p-find-next then "true":u else "false":u )
      parameter-4-88 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.free-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " ":u + where-phrase-88 + " ":u + p-find-condition + " " + ""
      parameter-5-88 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-88)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-88
                          ,input parameter-5-88
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-88 = (if p-find-next then "true":u else "false":u )
      parameter-3-88 =  "FOR EACH gob-doc no-lock"
      parameter-4-88 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.free-qnty <> 0 " + " " + where-phrase-88) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.free-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-88
          else "true"
        )
      parameter-5-88 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-88 = if sort-phrase-88 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.free-qnty                     by gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-88
        )
      parameter-7-88 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-88)
                          ,input no-lock
                          ,input parameter-3-88
                          ,input parameter-4-88
                          ,input parameter-5-88
                          ,input parameter-6-88
                          ,input parameter-7-88
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
END PROCEDURE.
PROCEDURE free-price.
define variable vss-include-info89 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-90  as logical   no-undo .
define variable  l-filter-open-90    as logical   .
define variable  flt-rec-90       as recid     no-undo .
define variable  filter-name-90      as character no-undo .
define variable  where-phrase-90     as character no-undo .
define variable  sort-phrase-90      as character no-undo .
define variable  where-phrase-rus-90 as character no-undo .
define variable  sort-phrase-rus-90  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-90
  ,output filter-name-90
  ,output where-phrase-90
  ,output sort-phrase-90
  ,output where-phrase-rus-90
  ,output sort-phrase-rus-90
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-90
      ) no-error .
  assign
    l-filter-open-90 = false
  .
  if flt-rec-90 <> ?
  then do:
    define variable  parameter-2-90 as character no-undo .
    define variable  parameter-3-90 as character no-undo .
    define variable  parameter-4-90 as character no-undo .
    define variable  parameter-5-90 as character no-undo .
    define variable  parameter-6-90 as character no-undo .
    define variable  parameter-7-90 as character no-undo .
      assign
      parameter-3-90 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-90 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0 " + " " + where-phrase-90) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3  and gob-doc.free-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-90
          else "true"
        )
      parameter-5-90 = (" " + "" + " " + "")
      parameter-6-90 = if sort-phrase-90 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.price-sale                     by gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-90
        )
      parameter-7-90 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-90 =
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0 " + " " + where-phrase-90 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-90
                          ,input parameter-4-90
                          ,input parameter-5-90
                          ,input parameter-6-90
                          ,input parameter-7-90
                          )
      .
      assign
        l-filter-open-90 = true
      .
    end.
    if l-filter-open-90 = false then do:
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
  if l-filter-open-90 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0
       by gob-doc.price-sale                     by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-90 = (if p-find-next then "true":u else "false":u )
      parameter-4-90 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3  and gob-doc.free-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " ":u + where-phrase-90 + " ":u + p-find-condition + " " + ""
      parameter-5-90 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-90)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-90
                          ,input parameter-5-90
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-90 = (if p-find-next then "true":u else "false":u )
      parameter-3-90 =  "FOR EACH gob-doc no-lock"
      parameter-4-90 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0 " + " " + where-phrase-90) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3  and gob-doc.free-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-90
          else "true"
        )
      parameter-5-90 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-90 = if sort-phrase-90 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.price-sale                     by gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-90
        )
      parameter-7-90 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-90)
                          ,input no-lock
                          ,input parameter-3-90
                          ,input parameter-4-90
                          ,input parameter-5-90
                          ,input parameter-6-90
                          ,input parameter-7-90
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
END PROCEDURE.
PROCEDURE free-qnty.
define variable vss-include-info91 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-92  as logical   no-undo .
define variable  l-filter-open-92    as logical   .
define variable  flt-rec-92       as recid     no-undo .
define variable  filter-name-92      as character no-undo .
define variable  where-phrase-92     as character no-undo .
define variable  sort-phrase-92      as character no-undo .
define variable  where-phrase-rus-92 as character no-undo .
define variable  sort-phrase-rus-92  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-92
  ,output filter-name-92
  ,output where-phrase-92
  ,output sort-phrase-92
  ,output where-phrase-rus-92
  ,output sort-phrase-rus-92
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-92
      ) no-error .
  assign
    l-filter-open-92 = false
  .
  if flt-rec-92 <> ?
  then do:
    define variable  parameter-2-92 as character no-undo .
    define variable  parameter-3-92 as character no-undo .
    define variable  parameter-4-92 as character no-undo .
    define variable  parameter-5-92 as character no-undo .
    define variable  parameter-6-92 as character no-undo .
    define variable  parameter-7-92 as character no-undo .
      assign
      parameter-3-92 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-92 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0 " + " " + where-phrase-92) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.free-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-92
          else "true"
        )
      parameter-5-92 = (" " + "" + " " + "")
      parameter-6-92 = if sort-phrase-92 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.free-qnty                     by gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-92
        )
      parameter-7-92 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-92 =
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0 " + " " + where-phrase-92 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-92
                          ,input parameter-4-92
                          ,input parameter-5-92
                          ,input parameter-6-92
                          ,input parameter-7-92
                          )
      .
      assign
        l-filter-open-92 = true
      .
    end.
    if l-filter-open-92 = false then do:
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
  if l-filter-open-92 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0
       by gob-doc.free-qnty                     by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-92 = (if p-find-next then "true":u else "false":u )
      parameter-4-92 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.free-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " ":u + where-phrase-92 + " ":u + p-find-condition + " " + ""
      parameter-5-92 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-92)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-92
                          ,input parameter-5-92
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-92 = (if p-find-next then "true":u else "false":u )
      parameter-3-92 =  "FOR EACH gob-doc no-lock"
      parameter-4-92 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0 " + " " + where-phrase-92) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.free-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-92
          else "true"
        )
      parameter-5-92 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-92 = if sort-phrase-92 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.free-qnty                     by gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-92
        )
      parameter-7-92 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-92)
                          ,input no-lock
                          ,input parameter-3-92
                          ,input parameter-4-92
                          ,input parameter-5-92
                          ,input parameter-6-92
                          ,input parameter-7-92
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
END PROCEDURE.
PROCEDURE free-price-0.
define variable vss-include-info93 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-94  as logical   no-undo .
define variable  l-filter-open-94    as logical   .
define variable  flt-rec-94       as recid     no-undo .
define variable  filter-name-94      as character no-undo .
define variable  where-phrase-94     as character no-undo .
define variable  sort-phrase-94      as character no-undo .
define variable  where-phrase-rus-94 as character no-undo .
define variable  sort-phrase-rus-94  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-94
  ,output filter-name-94
  ,output where-phrase-94
  ,output sort-phrase-94
  ,output where-phrase-rus-94
  ,output sort-phrase-rus-94
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-94
      ) no-error .
  assign
    l-filter-open-94 = false
  .
  if flt-rec-94 <> ?
  then do:
    define variable  parameter-2-94 as character no-undo .
    define variable  parameter-3-94 as character no-undo .
    define variable  parameter-4-94 as character no-undo .
    define variable  parameter-5-94 as character no-undo .
    define variable  parameter-6-94 as character no-undo .
    define variable  parameter-7-94 as character no-undo .
      assign
      parameter-3-94 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-94 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.free-qnty <> 0 " + " " + where-phrase-94) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0  and gob-doc.free-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-94
          else "true"
        )
      parameter-5-94 = (" " + "" + " " + "")
      parameter-6-94 = if sort-phrase-94 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.price-sale                     by gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-94
        )
      parameter-7-94 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-94 =
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.free-qnty <> 0 " + " " + where-phrase-94 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-94
                          ,input parameter-4-94
                          ,input parameter-5-94
                          ,input parameter-6-94
                          ,input parameter-7-94
                          )
      .
      assign
        l-filter-open-94 = true
      .
    end.
    if l-filter-open-94 = false then do:
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
  if l-filter-open-94 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.free-qnty <> 0
       by gob-doc.price-sale                     by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-94 = (if p-find-next then "true":u else "false":u )
      parameter-4-94 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0  and gob-doc.free-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " ":u + where-phrase-94 + " ":u + p-find-condition + " " + ""
      parameter-5-94 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-94)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-94
                          ,input parameter-5-94
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-94 = (if p-find-next then "true":u else "false":u )
      parameter-3-94 =  "FOR EACH gob-doc no-lock"
      parameter-4-94 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.free-qnty <> 0 " + " " + where-phrase-94) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0  and gob-doc.free-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-94
          else "true"
        )
      parameter-5-94 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-94 = if sort-phrase-94 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.price-sale                     by gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-94
        )
      parameter-7-94 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-94)
                          ,input no-lock
                          ,input parameter-3-94
                          ,input parameter-4-94
                          ,input parameter-5-94
                          ,input parameter-6-94
                          ,input parameter-7-94
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
END PROCEDURE.
PROCEDURE free-qnty-0.
define variable vss-include-info95 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-96  as logical   no-undo .
define variable  l-filter-open-96    as logical   .
define variable  flt-rec-96       as recid     no-undo .
define variable  filter-name-96      as character no-undo .
define variable  where-phrase-96     as character no-undo .
define variable  sort-phrase-96      as character no-undo .
define variable  where-phrase-rus-96 as character no-undo .
define variable  sort-phrase-rus-96  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-96
  ,output filter-name-96
  ,output where-phrase-96
  ,output sort-phrase-96
  ,output where-phrase-rus-96
  ,output sort-phrase-rus-96
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-96
      ) no-error .
  assign
    l-filter-open-96 = false
  .
  if flt-rec-96 <> ?
  then do:
    define variable  parameter-2-96 as character no-undo .
    define variable  parameter-3-96 as character no-undo .
    define variable  parameter-4-96 as character no-undo .
    define variable  parameter-5-96 as character no-undo .
    define variable  parameter-6-96 as character no-undo .
    define variable  parameter-7-96 as character no-undo .
      assign
      parameter-3-96 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-96 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.free-qnty <> 0 " + " " + where-phrase-96) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0  and gob-doc.free-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-96
          else "true"
        )
      parameter-5-96 = (" " + "" + " " + "")
      parameter-6-96 = if sort-phrase-96 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.free-qnty                     by gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-96
        )
      parameter-7-96 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-96 =
          (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.free-qnty <> 0 " + " " + where-phrase-96 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-96
                          ,input parameter-4-96
                          ,input parameter-5-96
                          ,input parameter-6-96
                          ,input parameter-7-96
                          )
      .
      assign
        l-filter-open-96 = true
      .
    end.
    if l-filter-open-96 = false then do:
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
  if l-filter-open-96 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.free-qnty <> 0
       by gob-doc.free-qnty                     by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-96 = (if p-find-next then "true":u else "false":u )
      parameter-4-96 =
        "where ":u +  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0  and gob-doc.free-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " ":u + where-phrase-96 + " ":u + p-find-condition + " " + ""
      parameter-5-96 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-96)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-96
                          ,input parameter-5-96
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-96 = (if p-find-next then "true":u else "false":u )
      parameter-3-96 =  "FOR EACH gob-doc no-lock"
      parameter-4-96 =
        (
          if (" gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.free-qnty <> 0 " + " " + where-phrase-96) <> ""
          then  substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0  and gob-doc.free-qnty <> 0 ' , chr(34), pobj-type, pobj-code) + " " + where-phrase-96
          else "true"
        )
      parameter-5-96 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-96 = if sort-phrase-96 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.free-qnty                     by gob-doc.artic  "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-96
        )
      parameter-7-96 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-96)
                          ,input no-lock
                          ,input parameter-3-96
                          ,input parameter-4-96
                          ,input parameter-5-96
                          ,input parameter-6-96
                          ,input parameter-7-96
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
END PROCEDURE.
PROCEDURE prod-obj-price0 .
define variable vss-include-info97 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-98  as logical   no-undo .
define variable  l-filter-open-98    as logical   .
define variable  flt-rec-98       as recid     no-undo .
define variable  filter-name-98      as character no-undo .
define variable  where-phrase-98     as character no-undo .
define variable  sort-phrase-98      as character no-undo .
define variable  where-phrase-rus-98 as character no-undo .
define variable  sort-phrase-rus-98  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-98
  ,output filter-name-98
  ,output where-phrase-98
  ,output sort-phrase-98
  ,output where-phrase-rus-98
  ,output sort-phrase-rus-98
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-98
      ) no-error .
  assign
    l-filter-open-98 = false
  .
  if flt-rec-98 <> ?
  then do:
    define variable  parameter-2-98 as character no-undo .
    define variable  parameter-3-98 as character no-undo .
    define variable  parameter-4-98 as character no-undo .
    define variable  parameter-5-98 as character no-undo .
    define variable  parameter-6-98 as character no-undo .
    define variable  parameter-7-98 as character no-undo .
      assign
      parameter-3-98 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-98 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-98) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5'                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-98
          else "true"
        )
      parameter-5-98 = (" " + "" + " " + "")
      parameter-6-98 = if sort-phrase-98 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.price-sale                   by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-98
        )
      parameter-7-98 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-98 =
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-98 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-98
                          ,input parameter-4-98
                          ,input parameter-5-98
                          ,input parameter-6-98
                          ,input parameter-7-98
                          )
      .
      assign
        l-filter-open-98 = true
      .
    end.
    if l-filter-open-98 = false then do:
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
  if l-filter-open-98 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code
       by gob-doc.price-sale                   by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-98 = (if p-find-next then "true":u else "false":u )
      parameter-4-98 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5'                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-98 + " ":u + p-find-condition + " " + ""
      parameter-5-98 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-98)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-98
                          ,input parameter-5-98
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-98 = (if p-find-next then "true":u else "false":u )
      parameter-3-98 =  "FOR EACH gob-doc no-lock"
      parameter-4-98 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-98) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5'                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-98
          else "true"
        )
      parameter-5-98 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-98 = if sort-phrase-98 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.price-sale                   by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-98
        )
      parameter-7-98 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-98)
                          ,input no-lock
                          ,input parameter-3-98
                          ,input parameter-4-98
                          ,input parameter-5-98
                          ,input parameter-6-98
                          ,input parameter-7-98
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
END PROCEDURE.
PROCEDURE prod-obj-price.
define variable vss-include-info99 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-100  as logical   no-undo .
define variable  l-filter-open-100    as logical   .
define variable  flt-rec-100       as recid     no-undo .
define variable  filter-name-100      as character no-undo .
define variable  where-phrase-100     as character no-undo .
define variable  sort-phrase-100      as character no-undo .
define variable  where-phrase-rus-100 as character no-undo .
define variable  sort-phrase-rus-100  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-100
  ,output filter-name-100
  ,output where-phrase-100
  ,output sort-phrase-100
  ,output where-phrase-rus-100
  ,output sort-phrase-rus-100
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-100
      ) no-error .
  assign
    l-filter-open-100 = false
  .
  if flt-rec-100 <> ?
  then do:
    define variable  parameter-2-100 as character no-undo .
    define variable  parameter-3-100 as character no-undo .
    define variable  parameter-4-100 as character no-undo .
    define variable  parameter-5-100 as character no-undo .
    define variable  parameter-6-100 as character no-undo .
    define variable  parameter-7-100 as character no-undo .
      assign
      parameter-3-100 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-100 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                    and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-100) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5'                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-100
          else "true"
        )
      parameter-5-100 = (" " + "" + " " + "")
      parameter-6-100 = if sort-phrase-100 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.price-sale                   by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-100
        )
      parameter-7-100 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-100 =
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                    and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-100 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-100
                          ,input parameter-4-100
                          ,input parameter-5-100
                          ,input parameter-6-100
                          ,input parameter-7-100
                          )
      .
      assign
        l-filter-open-100 = true
      .
    end.
    if l-filter-open-100 = false then do:
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
  if l-filter-open-100 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                    and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code
       by gob-doc.price-sale                   by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-100 = (if p-find-next then "true":u else "false":u )
      parameter-4-100 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5'                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-100 + " ":u + p-find-condition + " " + ""
      parameter-5-100 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-100)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-100
                          ,input parameter-5-100
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-100 = (if p-find-next then "true":u else "false":u )
      parameter-3-100 =  "FOR EACH gob-doc no-lock"
      parameter-4-100 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                    and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-100) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5'                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-100
          else "true"
        )
      parameter-5-100 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-100 = if sort-phrase-100 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.price-sale                   by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-100
        )
      parameter-7-100 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-100)
                          ,input no-lock
                          ,input parameter-3-100
                          ,input parameter-4-100
                          ,input parameter-5-100
                          ,input parameter-6-100
                          ,input parameter-7-100
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
END PROCEDURE.
PROCEDURE prod-obj-price-0 .
define variable vss-include-info101 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-102  as logical   no-undo .
define variable  l-filter-open-102    as logical   .
define variable  flt-rec-102       as recid     no-undo .
define variable  filter-name-102      as character no-undo .
define variable  where-phrase-102     as character no-undo .
define variable  sort-phrase-102      as character no-undo .
define variable  where-phrase-rus-102 as character no-undo .
define variable  sort-phrase-rus-102  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-102
  ,output filter-name-102
  ,output where-phrase-102
  ,output sort-phrase-102
  ,output where-phrase-rus-102
  ,output sort-phrase-rus-102
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-102
      ) no-error .
  assign
    l-filter-open-102 = false
  .
  if flt-rec-102 <> ?
  then do:
    define variable  parameter-2-102 as character no-undo .
    define variable  parameter-3-102 as character no-undo .
    define variable  parameter-4-102 as character no-undo .
    define variable  parameter-5-102 as character no-undo .
    define variable  parameter-6-102 as character no-undo .
    define variable  parameter-7-102 as character no-undo .
      assign
      parameter-3-102 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-102 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-102) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5'                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-102
          else "true"
        )
      parameter-5-102 = (" " + "" + " " + "")
      parameter-6-102 = if sort-phrase-102 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.price-sale                   by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-102
        )
      parameter-7-102 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-102 =
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-102 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-102
                          ,input parameter-4-102
                          ,input parameter-5-102
                          ,input parameter-6-102
                          ,input parameter-7-102
                          )
      .
      assign
        l-filter-open-102 = true
      .
    end.
    if l-filter-open-102 = false then do:
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
  if l-filter-open-102 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code
       by gob-doc.price-sale                   by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-102 = (if p-find-next then "true":u else "false":u )
      parameter-4-102 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5'                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-102 + " ":u + p-find-condition + " " + ""
      parameter-5-102 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-102)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-102
                          ,input parameter-5-102
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-102 = (if p-find-next then "true":u else "false":u )
      parameter-3-102 =  "FOR EACH gob-doc no-lock"
      parameter-4-102 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-102) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5'                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-102
          else "true"
        )
      parameter-5-102 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-102 = if sort-phrase-102 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.price-sale                   by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-102
        )
      parameter-7-102 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-102)
                          ,input no-lock
                          ,input parameter-3-102
                          ,input parameter-4-102
                          ,input parameter-5-102
                          ,input parameter-6-102
                          ,input parameter-7-102
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
END PROCEDURE.
PROCEDURE prod-fact-price0 .
define variable vss-include-info103 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-104  as logical   no-undo .
define variable  l-filter-open-104    as logical   .
define variable  flt-rec-104       as recid     no-undo .
define variable  filter-name-104      as character no-undo .
define variable  where-phrase-104     as character no-undo .
define variable  sort-phrase-104      as character no-undo .
define variable  where-phrase-rus-104 as character no-undo .
define variable  sort-phrase-rus-104  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-104
  ,output filter-name-104
  ,output where-phrase-104
  ,output sort-phrase-104
  ,output where-phrase-rus-104
  ,output sort-phrase-rus-104
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-104
      ) no-error .
  assign
    l-filter-open-104 = false
  .
  if flt-rec-104 <> ?
  then do:
    define variable  parameter-2-104 as character no-undo .
    define variable  parameter-3-104 as character no-undo .
    define variable  parameter-4-104 as character no-undo .
    define variable  parameter-5-104 as character no-undo .
    define variable  parameter-6-104 as character no-undo .
    define variable  parameter-7-104 as character no-undo .
      assign
      parameter-3-104 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-104 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0" + " " + where-phrase-104) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-104
          else "true"
        )
      parameter-5-104 = (" " + " use-index obj-price" + " " + "")
      parameter-6-104 = if sort-phrase-104 = ''
                           then
        (
        " " + "" +
        " " + " "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-104
        )
      parameter-7-104 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-104 =
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0" + " " + where-phrase-104 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-104
                          ,input parameter-4-104
                          ,input parameter-5-104
                          ,input parameter-6-104
                          ,input parameter-7-104
                          )
      .
      assign
        l-filter-open-104 = true
      .
    end.
    if l-filter-open-104 = false then do:
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
  if l-filter-open-104 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0
     use-index obj-price
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-104 = (if p-find-next then "true":u else "false":u )
      parameter-4-104 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-104 + " ":u + p-find-condition + " " + " use-index obj-price"
      parameter-5-104 = ""
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-104)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-104
                          ,input parameter-5-104
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-104 = (if p-find-next then "true":u else "false":u )
      parameter-3-104 =  "FOR EACH gob-doc no-lock"
      parameter-4-104 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0" + " " + where-phrase-104) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-104
          else "true"
        )
      parameter-5-104 = (" " + " use-index obj-price" + " " + "" + " " + p-find-condition)
      parameter-6-104 = if sort-phrase-104 = ''
                           then
        (
        " " + "" +
        " " + " "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-104
        )
      parameter-7-104 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-104)
                          ,input no-lock
                          ,input parameter-3-104
                          ,input parameter-4-104
                          ,input parameter-5-104
                          ,input parameter-6-104
                          ,input parameter-7-104
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
END PROCEDURE.
PROCEDURE prod-fact-qnty0 .
define variable vss-include-info105 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-106  as logical   no-undo .
define variable  l-filter-open-106    as logical   .
define variable  flt-rec-106       as recid     no-undo .
define variable  filter-name-106      as character no-undo .
define variable  where-phrase-106     as character no-undo .
define variable  sort-phrase-106      as character no-undo .
define variable  where-phrase-rus-106 as character no-undo .
define variable  sort-phrase-rus-106  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-106
  ,output filter-name-106
  ,output where-phrase-106
  ,output sort-phrase-106
  ,output where-phrase-rus-106
  ,output sort-phrase-rus-106
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-106
      ) no-error .
  assign
    l-filter-open-106 = false
  .
  if flt-rec-106 <> ?
  then do:
    define variable  parameter-2-106 as character no-undo .
    define variable  parameter-3-106 as character no-undo .
    define variable  parameter-4-106 as character no-undo .
    define variable  parameter-5-106 as character no-undo .
    define variable  parameter-6-106 as character no-undo .
    define variable  parameter-7-106 as character no-undo .
      assign
      parameter-3-106 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-106 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0" + " " + where-phrase-106) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-106
          else "true"
        )
      parameter-5-106 = (" " + " use-index obj-qnty" + " " + "")
      parameter-6-106 = if sort-phrase-106 = ''
                           then
        (
        " " + "" +
        " " + " "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-106
        )
      parameter-7-106 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-106 =
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0" + " " + where-phrase-106 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-106
                          ,input parameter-4-106
                          ,input parameter-5-106
                          ,input parameter-6-106
                          ,input parameter-7-106
                          )
      .
      assign
        l-filter-open-106 = true
      .
    end.
    if l-filter-open-106 = false then do:
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
  if l-filter-open-106 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0
     use-index obj-qnty
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-106 = (if p-find-next then "true":u else "false":u )
      parameter-4-106 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-106 + " ":u + p-find-condition + " " + " use-index obj-qnty"
      parameter-5-106 = ""
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-106)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-106
                          ,input parameter-5-106
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-106 = (if p-find-next then "true":u else "false":u )
      parameter-3-106 =  "FOR EACH gob-doc no-lock"
      parameter-4-106 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0" + " " + where-phrase-106) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-106
          else "true"
        )
      parameter-5-106 = (" " + " use-index obj-qnty" + " " + "" + " " + p-find-condition)
      parameter-6-106 = if sort-phrase-106 = ''
                           then
        (
        " " + "" +
        " " + " "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-106
        )
      parameter-7-106 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-106)
                          ,input no-lock
                          ,input parameter-3-106
                          ,input parameter-4-106
                          ,input parameter-5-106
                          ,input parameter-6-106
                          ,input parameter-7-106
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
END PROCEDURE.
PROCEDURE prod-fact-price .
define variable vss-include-info107 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-108  as logical   no-undo .
define variable  l-filter-open-108    as logical   .
define variable  flt-rec-108       as recid     no-undo .
define variable  filter-name-108      as character no-undo .
define variable  where-phrase-108     as character no-undo .
define variable  sort-phrase-108      as character no-undo .
define variable  where-phrase-rus-108 as character no-undo .
define variable  sort-phrase-rus-108  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-108
  ,output filter-name-108
  ,output where-phrase-108
  ,output sort-phrase-108
  ,output where-phrase-rus-108
  ,output sort-phrase-rus-108
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-108
      ) no-error .
  assign
    l-filter-open-108 = false
  .
  if flt-rec-108 <> ?
  then do:
    define variable  parameter-2-108 as character no-undo .
    define variable  parameter-3-108 as character no-undo .
    define variable  parameter-4-108 as character no-undo .
    define variable  parameter-5-108 as character no-undo .
    define variable  parameter-6-108 as character no-undo .
    define variable  parameter-7-108 as character no-undo .
      assign
      parameter-3-108 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-108 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                    and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0" + " " + where-phrase-108) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                    and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-108
          else "true"
        )
      parameter-5-108 = (" " + " use-index obj-price" + " " + "")
      parameter-6-108 = if sort-phrase-108 = ''
                           then
        (
        " " + "" +
        " " + " "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-108
        )
      parameter-7-108 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-108 =
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                    and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0" + " " + where-phrase-108 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-108
                          ,input parameter-4-108
                          ,input parameter-5-108
                          ,input parameter-6-108
                          ,input parameter-7-108
                          )
      .
      assign
        l-filter-open-108 = true
      .
    end.
    if l-filter-open-108 = false then do:
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
  if l-filter-open-108 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                    and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0
     use-index obj-price
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-108 = (if p-find-next then "true":u else "false":u )
      parameter-4-108 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                    and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-108 + " ":u + p-find-condition + " " + " use-index obj-price"
      parameter-5-108 = ""
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-108)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-108
                          ,input parameter-5-108
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-108 = (if p-find-next then "true":u else "false":u )
      parameter-3-108 =  "FOR EACH gob-doc no-lock"
      parameter-4-108 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                    and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0" + " " + where-phrase-108) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                    and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-108
          else "true"
        )
      parameter-5-108 = (" " + " use-index obj-price" + " " + "" + " " + p-find-condition)
      parameter-6-108 = if sort-phrase-108 = ''
                           then
        (
        " " + "" +
        " " + " "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-108
        )
      parameter-7-108 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-108)
                          ,input no-lock
                          ,input parameter-3-108
                          ,input parameter-4-108
                          ,input parameter-5-108
                          ,input parameter-6-108
                          ,input parameter-7-108
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
END PROCEDURE.
PROCEDURE prod-fact-qnty .
define variable vss-include-info109 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-110  as logical   no-undo .
define variable  l-filter-open-110    as logical   .
define variable  flt-rec-110       as recid     no-undo .
define variable  filter-name-110      as character no-undo .
define variable  where-phrase-110     as character no-undo .
define variable  sort-phrase-110      as character no-undo .
define variable  where-phrase-rus-110 as character no-undo .
define variable  sort-phrase-rus-110  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-110
  ,output filter-name-110
  ,output where-phrase-110
  ,output sort-phrase-110
  ,output where-phrase-rus-110
  ,output sort-phrase-rus-110
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-110
      ) no-error .
  assign
    l-filter-open-110 = false
  .
  if flt-rec-110 <> ?
  then do:
    define variable  parameter-2-110 as character no-undo .
    define variable  parameter-3-110 as character no-undo .
    define variable  parameter-4-110 as character no-undo .
    define variable  parameter-5-110 as character no-undo .
    define variable  parameter-6-110 as character no-undo .
    define variable  parameter-7-110 as character no-undo .
      assign
      parameter-3-110 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-110 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0" + " " + where-phrase-110) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-110
          else "true"
        )
      parameter-5-110 = (" " + " use-index obj-qnty" + " " + "")
      parameter-6-110 = if sort-phrase-110 = ''
                           then
        (
        " " + "" +
        " " + " "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-110
        )
      parameter-7-110 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-110 =
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0" + " " + where-phrase-110 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-110
                          ,input parameter-4-110
                          ,input parameter-5-110
                          ,input parameter-6-110
                          ,input parameter-7-110
                          )
      .
      assign
        l-filter-open-110 = true
      .
    end.
    if l-filter-open-110 = false then do:
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
  if l-filter-open-110 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0
     use-index obj-qnty
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-110 = (if p-find-next then "true":u else "false":u )
      parameter-4-110 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-110 + " ":u + p-find-condition + " " + " use-index obj-qnty"
      parameter-5-110 = ""
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-110)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-110
                          ,input parameter-5-110
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-110 = (if p-find-next then "true":u else "false":u )
      parameter-3-110 =  "FOR EACH gob-doc no-lock"
      parameter-4-110 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0" + " " + where-phrase-110) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-110
          else "true"
        )
      parameter-5-110 = (" " + " use-index obj-qnty" + " " + "" + " " + p-find-condition)
      parameter-6-110 = if sort-phrase-110 = ''
                           then
        (
        " " + "" +
        " " + " "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-110
        )
      parameter-7-110 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-110)
                          ,input no-lock
                          ,input parameter-3-110
                          ,input parameter-4-110
                          ,input parameter-5-110
                          ,input parameter-6-110
                          ,input parameter-7-110
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
END PROCEDURE.
PROCEDURE prod-fact-price-0 .
define variable vss-include-info111 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-112  as logical   no-undo .
define variable  l-filter-open-112    as logical   .
define variable  flt-rec-112       as recid     no-undo .
define variable  filter-name-112      as character no-undo .
define variable  where-phrase-112     as character no-undo .
define variable  sort-phrase-112      as character no-undo .
define variable  where-phrase-rus-112 as character no-undo .
define variable  sort-phrase-rus-112  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-112
  ,output filter-name-112
  ,output where-phrase-112
  ,output sort-phrase-112
  ,output where-phrase-rus-112
  ,output sort-phrase-rus-112
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-112
      ) no-error .
  assign
    l-filter-open-112 = false
  .
  if flt-rec-112 <> ?
  then do:
    define variable  parameter-2-112 as character no-undo .
    define variable  parameter-3-112 as character no-undo .
    define variable  parameter-4-112 as character no-undo .
    define variable  parameter-5-112 as character no-undo .
    define variable  parameter-6-112 as character no-undo .
    define variable  parameter-7-112 as character no-undo .
      assign
      parameter-3-112 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-112 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0" + " " + where-phrase-112) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-112
          else "true"
        )
      parameter-5-112 = (" " + " use-index obj-price" + " " + "")
      parameter-6-112 = if sort-phrase-112 = ''
                           then
        (
        " " + "" +
        " " + " "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-112
        )
      parameter-7-112 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-112 =
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0" + " " + where-phrase-112 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-112
                          ,input parameter-4-112
                          ,input parameter-5-112
                          ,input parameter-6-112
                          ,input parameter-7-112
                          )
      .
      assign
        l-filter-open-112 = true
      .
    end.
    if l-filter-open-112 = false then do:
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
  if l-filter-open-112 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0
     use-index obj-price
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-112 = (if p-find-next then "true":u else "false":u )
      parameter-4-112 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-112 + " ":u + p-find-condition + " " + " use-index obj-price"
      parameter-5-112 = ""
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-112)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-112
                          ,input parameter-5-112
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-112 = (if p-find-next then "true":u else "false":u )
      parameter-3-112 =  "FOR EACH gob-doc no-lock"
      parameter-4-112 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0" + " " + where-phrase-112) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-112
          else "true"
        )
      parameter-5-112 = (" " + " use-index obj-price" + " " + "" + " " + p-find-condition)
      parameter-6-112 = if sort-phrase-112 = ''
                           then
        (
        " " + "" +
        " " + " "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-112
        )
      parameter-7-112 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-112)
                          ,input no-lock
                          ,input parameter-3-112
                          ,input parameter-4-112
                          ,input parameter-5-112
                          ,input parameter-6-112
                          ,input parameter-7-112
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
END PROCEDURE.
PROCEDURE prod-fact-qnty-0.
define variable vss-include-info113 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-114  as logical   no-undo .
define variable  l-filter-open-114    as logical   .
define variable  flt-rec-114       as recid     no-undo .
define variable  filter-name-114      as character no-undo .
define variable  where-phrase-114     as character no-undo .
define variable  sort-phrase-114      as character no-undo .
define variable  where-phrase-rus-114 as character no-undo .
define variable  sort-phrase-rus-114  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-114
  ,output filter-name-114
  ,output where-phrase-114
  ,output sort-phrase-114
  ,output where-phrase-rus-114
  ,output sort-phrase-rus-114
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-114
      ) no-error .
  assign
    l-filter-open-114 = false
  .
  if flt-rec-114 <> ?
  then do:
    define variable  parameter-2-114 as character no-undo .
    define variable  parameter-3-114 as character no-undo .
    define variable  parameter-4-114 as character no-undo .
    define variable  parameter-5-114 as character no-undo .
    define variable  parameter-6-114 as character no-undo .
    define variable  parameter-7-114 as character no-undo .
      assign
      parameter-3-114 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-114 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0" + " " + where-phrase-114) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-114
          else "true"
        )
      parameter-5-114 = (" " + " use-index obj-qnty" + " " + "")
      parameter-6-114 = if sort-phrase-114 = ''
                           then
        (
        " " + "" +
        " " + " "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-114
        )
      parameter-7-114 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-114 =
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0" + " " + where-phrase-114 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-114
                          ,input parameter-4-114
                          ,input parameter-5-114
                          ,input parameter-6-114
                          ,input parameter-7-114
                          )
      .
      assign
        l-filter-open-114 = true
      .
    end.
    if l-filter-open-114 = false then do:
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
  if l-filter-open-114 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0
     use-index obj-qnty
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-114 = (if p-find-next then "true":u else "false":u )
      parameter-4-114 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-114 + " ":u + p-find-condition + " " + " use-index obj-qnty"
      parameter-5-114 = ""
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-114)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-114
                          ,input parameter-5-114
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-114 = (if p-find-next then "true":u else "false":u )
      parameter-3-114 =  "FOR EACH gob-doc no-lock"
      parameter-4-114 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0" + " " + where-phrase-114) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-114
          else "true"
        )
      parameter-5-114 = (" " + " use-index obj-qnty" + " " + "" + " " + p-find-condition)
      parameter-6-114 = if sort-phrase-114 = ''
                           then
        (
        " " + "" +
        " " + " "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-114
        )
      parameter-7-114 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-114)
                          ,input no-lock
                          ,input parameter-3-114
                          ,input parameter-4-114
                          ,input parameter-5-114
                          ,input parameter-6-114
                          ,input parameter-7-114
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
END PROCEDURE.
PROCEDURE prod-free-price0.
define variable vss-include-info115 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-116  as logical   no-undo .
define variable  l-filter-open-116    as logical   .
define variable  flt-rec-116       as recid     no-undo .
define variable  filter-name-116      as character no-undo .
define variable  where-phrase-116     as character no-undo .
define variable  sort-phrase-116      as character no-undo .
define variable  where-phrase-rus-116 as character no-undo .
define variable  sort-phrase-rus-116  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-116
  ,output filter-name-116
  ,output where-phrase-116
  ,output sort-phrase-116
  ,output where-phrase-rus-116
  ,output sort-phrase-rus-116
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-116
      ) no-error .
  assign
    l-filter-open-116 = false
  .
  if flt-rec-116 <> ?
  then do:
    define variable  parameter-2-116 as character no-undo .
    define variable  parameter-3-116 as character no-undo .
    define variable  parameter-4-116 as character no-undo .
    define variable  parameter-5-116 as character no-undo .
    define variable  parameter-6-116 as character no-undo .
    define variable  parameter-7-116 as character no-undo .
      assign
      parameter-3-116 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-116 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0" + " " + where-phrase-116) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-116
          else "true"
        )
      parameter-5-116 = (" " + "" + " " + "")
      parameter-6-116 = if sort-phrase-116 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.price-sale                   by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-116
        )
      parameter-7-116 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-116 =
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0" + " " + where-phrase-116 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-116
                          ,input parameter-4-116
                          ,input parameter-5-116
                          ,input parameter-6-116
                          ,input parameter-7-116
                          )
      .
      assign
        l-filter-open-116 = true
      .
    end.
    if l-filter-open-116 = false then do:
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
  if l-filter-open-116 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0
       by gob-doc.price-sale                   by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-116 = (if p-find-next then "true":u else "false":u )
      parameter-4-116 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-116 + " ":u + p-find-condition + " " + ""
      parameter-5-116 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-116)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-116
                          ,input parameter-5-116
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-116 = (if p-find-next then "true":u else "false":u )
      parameter-3-116 =  "FOR EACH gob-doc no-lock"
      parameter-4-116 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0" + " " + where-phrase-116) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-116
          else "true"
        )
      parameter-5-116 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-116 = if sort-phrase-116 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.price-sale                   by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-116
        )
      parameter-7-116 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-116)
                          ,input no-lock
                          ,input parameter-3-116
                          ,input parameter-4-116
                          ,input parameter-5-116
                          ,input parameter-6-116
                          ,input parameter-7-116
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
END PROCEDURE.
PROCEDURE prod-free-qnty0.
define variable vss-include-info117 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-118  as logical   no-undo .
define variable  l-filter-open-118    as logical   .
define variable  flt-rec-118       as recid     no-undo .
define variable  filter-name-118      as character no-undo .
define variable  where-phrase-118     as character no-undo .
define variable  sort-phrase-118      as character no-undo .
define variable  where-phrase-rus-118 as character no-undo .
define variable  sort-phrase-rus-118  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-118
  ,output filter-name-118
  ,output where-phrase-118
  ,output sort-phrase-118
  ,output where-phrase-rus-118
  ,output sort-phrase-rus-118
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-118
      ) no-error .
  assign
    l-filter-open-118 = false
  .
  if flt-rec-118 <> ?
  then do:
    define variable  parameter-2-118 as character no-undo .
    define variable  parameter-3-118 as character no-undo .
    define variable  parameter-4-118 as character no-undo .
    define variable  parameter-5-118 as character no-undo .
    define variable  parameter-6-118 as character no-undo .
    define variable  parameter-7-118 as character no-undo .
      assign
      parameter-3-118 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-118 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0" + " " + where-phrase-118) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-118
          else "true"
        )
      parameter-5-118 = (" " + "" + " " + "")
      parameter-6-118 = if sort-phrase-118 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.free-qnty                   by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-118
        )
      parameter-7-118 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-118 =
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0" + " " + where-phrase-118 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-118
                          ,input parameter-4-118
                          ,input parameter-5-118
                          ,input parameter-6-118
                          ,input parameter-7-118
                          )
      .
      assign
        l-filter-open-118 = true
      .
    end.
    if l-filter-open-118 = false then do:
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
  if l-filter-open-118 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0
       by gob-doc.free-qnty                   by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-118 = (if p-find-next then "true":u else "false":u )
      parameter-4-118 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-118 + " ":u + p-find-condition + " " + ""
      parameter-5-118 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-118)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-118
                          ,input parameter-5-118
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-118 = (if p-find-next then "true":u else "false":u )
      parameter-3-118 =  "FOR EACH gob-doc no-lock"
      parameter-4-118 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0" + " " + where-phrase-118) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-118
          else "true"
        )
      parameter-5-118 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-118 = if sort-phrase-118 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.free-qnty                   by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-118
        )
      parameter-7-118 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-118)
                          ,input no-lock
                          ,input parameter-3-118
                          ,input parameter-4-118
                          ,input parameter-5-118
                          ,input parameter-6-118
                          ,input parameter-7-118
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
END PROCEDURE.
PROCEDURE prod-free-price.
define variable vss-include-info119 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-120  as logical   no-undo .
define variable  l-filter-open-120    as logical   .
define variable  flt-rec-120       as recid     no-undo .
define variable  filter-name-120      as character no-undo .
define variable  where-phrase-120     as character no-undo .
define variable  sort-phrase-120      as character no-undo .
define variable  where-phrase-rus-120 as character no-undo .
define variable  sort-phrase-rus-120  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-120
  ,output filter-name-120
  ,output where-phrase-120
  ,output sort-phrase-120
  ,output where-phrase-rus-120
  ,output sort-phrase-rus-120
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-120
      ) no-error .
  assign
    l-filter-open-120 = false
  .
  if flt-rec-120 <> ?
  then do:
    define variable  parameter-2-120 as character no-undo .
    define variable  parameter-3-120 as character no-undo .
    define variable  parameter-4-120 as character no-undo .
    define variable  parameter-5-120 as character no-undo .
    define variable  parameter-6-120 as character no-undo .
    define variable  parameter-7-120 as character no-undo .
      assign
      parameter-3-120 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-120 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                    and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0" + " " + where-phrase-120) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                    and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-120
          else "true"
        )
      parameter-5-120 = (" " + "" + " " + "")
      parameter-6-120 = if sort-phrase-120 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.price-sale                   by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-120
        )
      parameter-7-120 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-120 =
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                    and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0" + " " + where-phrase-120 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-120
                          ,input parameter-4-120
                          ,input parameter-5-120
                          ,input parameter-6-120
                          ,input parameter-7-120
                          )
      .
      assign
        l-filter-open-120 = true
      .
    end.
    if l-filter-open-120 = false then do:
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
  if l-filter-open-120 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                    and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0
       by gob-doc.price-sale                   by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-120 = (if p-find-next then "true":u else "false":u )
      parameter-4-120 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                    and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-120 + " ":u + p-find-condition + " " + ""
      parameter-5-120 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-120)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-120
                          ,input parameter-5-120
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-120 = (if p-find-next then "true":u else "false":u )
      parameter-3-120 =  "FOR EACH gob-doc no-lock"
      parameter-4-120 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                    and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0" + " " + where-phrase-120) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                    and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-120
          else "true"
        )
      parameter-5-120 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-120 = if sort-phrase-120 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.price-sale                   by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-120
        )
      parameter-7-120 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-120)
                          ,input no-lock
                          ,input parameter-3-120
                          ,input parameter-4-120
                          ,input parameter-5-120
                          ,input parameter-6-120
                          ,input parameter-7-120
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
END PROCEDURE.
PROCEDURE prod-free-qnty.
define variable vss-include-info121 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-122  as logical   no-undo .
define variable  l-filter-open-122    as logical   .
define variable  flt-rec-122       as recid     no-undo .
define variable  filter-name-122      as character no-undo .
define variable  where-phrase-122     as character no-undo .
define variable  sort-phrase-122      as character no-undo .
define variable  where-phrase-rus-122 as character no-undo .
define variable  sort-phrase-rus-122  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-122
  ,output filter-name-122
  ,output where-phrase-122
  ,output sort-phrase-122
  ,output where-phrase-rus-122
  ,output sort-phrase-rus-122
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-122
      ) no-error .
  assign
    l-filter-open-122 = false
  .
  if flt-rec-122 <> ?
  then do:
    define variable  parameter-2-122 as character no-undo .
    define variable  parameter-3-122 as character no-undo .
    define variable  parameter-4-122 as character no-undo .
    define variable  parameter-5-122 as character no-undo .
    define variable  parameter-6-122 as character no-undo .
    define variable  parameter-7-122 as character no-undo .
      assign
      parameter-3-122 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-122 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                    and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0" + " " + where-phrase-122) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                    and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-122
          else "true"
        )
      parameter-5-122 = (" " + "" + " " + "")
      parameter-6-122 = if sort-phrase-122 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.free-qnty                   by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-122
        )
      parameter-7-122 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-122 =
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                    and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0" + " " + where-phrase-122 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-122
                          ,input parameter-4-122
                          ,input parameter-5-122
                          ,input parameter-6-122
                          ,input parameter-7-122
                          )
      .
      assign
        l-filter-open-122 = true
      .
    end.
    if l-filter-open-122 = false then do:
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
  if l-filter-open-122 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                    and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0
       by gob-doc.free-qnty                   by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-122 = (if p-find-next then "true":u else "false":u )
      parameter-4-122 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                    and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-122 + " ":u + p-find-condition + " " + ""
      parameter-5-122 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-122)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-122
                          ,input parameter-5-122
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-122 = (if p-find-next then "true":u else "false":u )
      parameter-3-122 =  "FOR EACH gob-doc no-lock"
      parameter-4-122 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code                    and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0" + " " + where-phrase-122) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3                    and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-122
          else "true"
        )
      parameter-5-122 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-122 = if sort-phrase-122 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.free-qnty                   by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-122
        )
      parameter-7-122 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-122)
                          ,input no-lock
                          ,input parameter-3-122
                          ,input parameter-4-122
                          ,input parameter-5-122
                          ,input parameter-6-122
                          ,input parameter-7-122
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
END PROCEDURE.
PROCEDURE prod-free-price-0.
define variable vss-include-info123 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-124  as logical   no-undo .
define variable  l-filter-open-124    as logical   .
define variable  flt-rec-124       as recid     no-undo .
define variable  filter-name-124      as character no-undo .
define variable  where-phrase-124     as character no-undo .
define variable  sort-phrase-124      as character no-undo .
define variable  where-phrase-rus-124 as character no-undo .
define variable  sort-phrase-rus-124  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-124
  ,output filter-name-124
  ,output where-phrase-124
  ,output sort-phrase-124
  ,output where-phrase-rus-124
  ,output sort-phrase-rus-124
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-124
      ) no-error .
  assign
    l-filter-open-124 = false
  .
  if flt-rec-124 <> ?
  then do:
    define variable  parameter-2-124 as character no-undo .
    define variable  parameter-3-124 as character no-undo .
    define variable  parameter-4-124 as character no-undo .
    define variable  parameter-5-124 as character no-undo .
    define variable  parameter-6-124 as character no-undo .
    define variable  parameter-7-124 as character no-undo .
      assign
      parameter-3-124 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-124 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0" + " " + where-phrase-124) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-124
          else "true"
        )
      parameter-5-124 = (" " + "" + " " + "")
      parameter-6-124 = if sort-phrase-124 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.price-sale                   by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-124
        )
      parameter-7-124 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-124 =
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0" + " " + where-phrase-124 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-124
                          ,input parameter-4-124
                          ,input parameter-5-124
                          ,input parameter-6-124
                          ,input parameter-7-124
                          )
      .
      assign
        l-filter-open-124 = true
      .
    end.
    if l-filter-open-124 = false then do:
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
  if l-filter-open-124 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0
       by gob-doc.price-sale                   by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-124 = (if p-find-next then "true":u else "false":u )
      parameter-4-124 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-124 + " ":u + p-find-condition + " " + ""
      parameter-5-124 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-124)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-124
                          ,input parameter-5-124
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-124 = (if p-find-next then "true":u else "false":u )
      parameter-3-124 =  "FOR EACH gob-doc no-lock"
      parameter-4-124 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0" + " " + where-phrase-124) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-124
          else "true"
        )
      parameter-5-124 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-124 = if sort-phrase-124 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.price-sale                   by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-124
        )
      parameter-7-124 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-124)
                          ,input no-lock
                          ,input parameter-3-124
                          ,input parameter-4-124
                          ,input parameter-5-124
                          ,input parameter-6-124
                          ,input parameter-7-124
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
END PROCEDURE.
PROCEDURE prod-free-qnty-0.
define variable vss-include-info125 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-126  as logical   no-undo .
define variable  l-filter-open-126    as logical   .
define variable  flt-rec-126       as recid     no-undo .
define variable  filter-name-126      as character no-undo .
define variable  where-phrase-126     as character no-undo .
define variable  sort-phrase-126      as character no-undo .
define variable  where-phrase-rus-126 as character no-undo .
define variable  sort-phrase-rus-126  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-126
  ,output filter-name-126
  ,output where-phrase-126
  ,output sort-phrase-126
  ,output where-phrase-rus-126
  ,output sort-phrase-rus-126
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-126
      ) no-error .
  assign
    l-filter-open-126 = false
  .
  if flt-rec-126 <> ?
  then do:
    define variable  parameter-2-126 as character no-undo .
    define variable  parameter-3-126 as character no-undo .
    define variable  parameter-4-126 as character no-undo .
    define variable  parameter-5-126 as character no-undo .
    define variable  parameter-6-126 as character no-undo .
    define variable  parameter-7-126 as character no-undo .
      assign
      parameter-3-126 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-126 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0" + " " + where-phrase-126) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-126
          else "true"
        )
      parameter-5-126 = (" " + "" + " " + "")
      parameter-6-126 = if sort-phrase-126 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.free-qnty                   by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-126
        )
      parameter-7-126 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-126 =
          (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0" + " " + where-phrase-126 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-126
                          ,input parameter-4-126
                          ,input parameter-5-126
                          ,input parameter-6-126
                          ,input parameter-7-126
                          )
      .
      assign
        l-filter-open-126 = true
      .
    end.
    if l-filter-open-126 = false then do:
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
  if l-filter-open-126 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0
       by gob-doc.free-qnty                   by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-126 = (if p-find-next then "true":u else "false":u )
      parameter-4-126 =
        "where ":u +  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " ":u + where-phrase-126 + " ":u + p-find-condition + " " + ""
      parameter-5-126 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-126)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-126
                          ,input parameter-5-126
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-126 = (if p-find-next then "true":u else "false":u )
      parameter-3-126 =  "FOR EACH gob-doc no-lock"
      parameter-4-126 =
        (
          if (" gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0                   and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0" + " " + where-phrase-126) <> ""
          then  substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0                   and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 '                 , chr(34), g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code) + " " + where-phrase-126
          else "true"
        )
      parameter-5-126 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-126 = if sort-phrase-126 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.free-qnty                   by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-126
        )
      parameter-7-126 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-126)
                          ,input no-lock
                          ,input parameter-3-126
                          ,input parameter-4-126
                          ,input parameter-5-126
                          ,input parameter-6-126
                          ,input parameter-7-126
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
END PROCEDURE.
PROCEDURE grp-obj-price0.
define variable vss-include-info127 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-128  as logical   no-undo .
define variable  l-filter-open-128    as logical   .
define variable  flt-rec-128       as recid     no-undo .
define variable  filter-name-128      as character no-undo .
define variable  where-phrase-128     as character no-undo .
define variable  sort-phrase-128      as character no-undo .
define variable  where-phrase-rus-128 as character no-undo .
define variable  sort-phrase-rus-128  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-128
  ,output filter-name-128
  ,output where-phrase-128
  ,output sort-phrase-128
  ,output where-phrase-rus-128
  ,output sort-phrase-rus-128
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-128
      ) no-error .
  assign
    l-filter-open-128 = false
  .
  if flt-rec-128 <> ?
  then do:
    define variable  parameter-2-128 as character no-undo .
    define variable  parameter-3-128 as character no-undo .
    define variable  parameter-4-128 as character no-undo .
    define variable  parameter-5-128 as character no-undo .
    define variable  parameter-6-128 as character no-undo .
    define variable  parameter-7-128 as character no-undo .
      assign
      parameter-3-128 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-128 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.stts = 0 " + " " + where-phrase-128) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.stts = 0 '                       , chr(34), g-grp, pobj-type, pobj-code) + " " + where-phrase-128
          else "true"
        )
      parameter-5-128 = (" " + "" + " " + "")
      parameter-6-128 = if sort-phrase-128 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.price-sale                     by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-128
        )
      parameter-7-128 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-128 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.stts = 0 " + " " + where-phrase-128 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-128
                          ,input parameter-4-128
                          ,input parameter-5-128
                          ,input parameter-6-128
                          ,input parameter-7-128
                          )
      .
      assign
        l-filter-open-128 = true
      .
    end.
    if l-filter-open-128 = false then do:
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
  if l-filter-open-128 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.stts = 0
       by gob-doc.price-sale                     by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-128 = (if p-find-next then "true":u else "false":u )
      parameter-4-128 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.stts = 0 '                       , chr(34), g-grp, pobj-type, pobj-code) + " ":u + where-phrase-128 + " ":u + p-find-condition + " " + ""
      parameter-5-128 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-128)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-128
                          ,input parameter-5-128
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-128 = (if p-find-next then "true":u else "false":u )
      parameter-3-128 =  "FOR EACH gob-doc no-lock"
      parameter-4-128 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.stts = 0 " + " " + where-phrase-128) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.stts = 0 '                       , chr(34), g-grp, pobj-type, pobj-code) + " " + where-phrase-128
          else "true"
        )
      parameter-5-128 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-128 = if sort-phrase-128 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.price-sale                     by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-128
        )
      parameter-7-128 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-128)
                          ,input no-lock
                          ,input parameter-3-128
                          ,input parameter-4-128
                          ,input parameter-5-128
                          ,input parameter-6-128
                          ,input parameter-7-128
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
END PROCEDURE.
PROCEDURE grp-obj-price.
define variable vss-include-info129 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-130  as logical   no-undo .
define variable  l-filter-open-130    as logical   .
define variable  flt-rec-130       as recid     no-undo .
define variable  filter-name-130      as character no-undo .
define variable  where-phrase-130     as character no-undo .
define variable  sort-phrase-130      as character no-undo .
define variable  where-phrase-rus-130 as character no-undo .
define variable  sort-phrase-rus-130  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-130
  ,output filter-name-130
  ,output where-phrase-130
  ,output sort-phrase-130
  ,output where-phrase-rus-130
  ,output sort-phrase-rus-130
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-130
      ) no-error .
  assign
    l-filter-open-130 = false
  .
  if flt-rec-130 <> ?
  then do:
    define variable  parameter-2-130 as character no-undo .
    define variable  parameter-3-130 as character no-undo .
    define variable  parameter-4-130 as character no-undo .
    define variable  parameter-5-130 as character no-undo .
    define variable  parameter-6-130 as character no-undo .
    define variable  parameter-7-130 as character no-undo .
      assign
      parameter-3-130 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-130 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-130) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-130
          else "true"
        )
      parameter-5-130 = (" " + "" + " " + "")
      parameter-6-130 = if sort-phrase-130 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.price-sale                     by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-130
        )
      parameter-7-130 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-130 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-130 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-130
                          ,input parameter-4-130
                          ,input parameter-5-130
                          ,input parameter-6-130
                          ,input parameter-7-130
                          )
      .
      assign
        l-filter-open-130 = true
      .
    end.
    if l-filter-open-130 = false then do:
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
  if l-filter-open-130 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code
       by gob-doc.price-sale                     by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-130 = (if p-find-next then "true":u else "false":u )
      parameter-4-130 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " ":u + where-phrase-130 + " ":u + p-find-condition + " " + ""
      parameter-5-130 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-130)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-130
                          ,input parameter-5-130
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-130 = (if p-find-next then "true":u else "false":u )
      parameter-3-130 =  "FOR EACH gob-doc no-lock"
      parameter-4-130 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code " + " " + where-phrase-130) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-130
          else "true"
        )
      parameter-5-130 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-130 = if sort-phrase-130 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.price-sale                     by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-130
        )
      parameter-7-130 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-130)
                          ,input no-lock
                          ,input parameter-3-130
                          ,input parameter-4-130
                          ,input parameter-5-130
                          ,input parameter-6-130
                          ,input parameter-7-130
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
END PROCEDURE.
PROCEDURE grp-obj-price-0.
define variable vss-include-info131 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-132  as logical   no-undo .
define variable  l-filter-open-132    as logical   .
define variable  flt-rec-132       as recid     no-undo .
define variable  filter-name-132      as character no-undo .
define variable  where-phrase-132     as character no-undo .
define variable  sort-phrase-132      as character no-undo .
define variable  where-phrase-rus-132 as character no-undo .
define variable  sort-phrase-rus-132  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-132
  ,output filter-name-132
  ,output where-phrase-132
  ,output sort-phrase-132
  ,output where-phrase-rus-132
  ,output sort-phrase-rus-132
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-132
      ) no-error .
  assign
    l-filter-open-132 = false
  .
  if flt-rec-132 <> ?
  then do:
    define variable  parameter-2-132 as character no-undo .
    define variable  parameter-3-132 as character no-undo .
    define variable  parameter-4-132 as character no-undo .
    define variable  parameter-5-132 as character no-undo .
    define variable  parameter-6-132 as character no-undo .
    define variable  parameter-7-132 as character no-undo .
      assign
      parameter-3-132 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-132 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.stts <> 0 " + " " + where-phrase-132) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.stts <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-132
          else "true"
        )
      parameter-5-132 = (" " + "" + " " + "")
      parameter-6-132 = if sort-phrase-132 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.price-sale                     by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-132
        )
      parameter-7-132 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-132 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.stts <> 0 " + " " + where-phrase-132 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-132
                          ,input parameter-4-132
                          ,input parameter-5-132
                          ,input parameter-6-132
                          ,input parameter-7-132
                          )
      .
      assign
        l-filter-open-132 = true
      .
    end.
    if l-filter-open-132 = false then do:
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
  if l-filter-open-132 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.stts <> 0
       by gob-doc.price-sale                     by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-132 = (if p-find-next then "true":u else "false":u )
      parameter-4-132 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.stts <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " ":u + where-phrase-132 + " ":u + p-find-condition + " " + ""
      parameter-5-132 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-132)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-132
                          ,input parameter-5-132
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-132 = (if p-find-next then "true":u else "false":u )
      parameter-3-132 =  "FOR EACH gob-doc no-lock"
      parameter-4-132 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.stts <> 0 " + " " + where-phrase-132) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.stts <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-132
          else "true"
        )
      parameter-5-132 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-132 = if sort-phrase-132 = ''
                           then
        (
        " " + " " +
        " " + " by gob-doc.price-sale                     by gob-doc.artic "
        )
                           else
        (
        " " + " " +
        " " + sort-phrase-132
        )
      parameter-7-132 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-132)
                          ,input no-lock
                          ,input parameter-3-132
                          ,input parameter-4-132
                          ,input parameter-5-132
                          ,input parameter-6-132
                          ,input parameter-7-132
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
END PROCEDURE.
PROCEDURE grp-fact-price0.
define variable vss-include-info133 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-134  as logical   no-undo .
define variable  l-filter-open-134    as logical   .
define variable  flt-rec-134       as recid     no-undo .
define variable  filter-name-134      as character no-undo .
define variable  where-phrase-134     as character no-undo .
define variable  sort-phrase-134      as character no-undo .
define variable  where-phrase-rus-134 as character no-undo .
define variable  sort-phrase-rus-134  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-134
  ,output filter-name-134
  ,output where-phrase-134
  ,output sort-phrase-134
  ,output where-phrase-rus-134
  ,output sort-phrase-rus-134
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-134
      ) no-error .
  assign
    l-filter-open-134 = false
  .
  if flt-rec-134 <> ?
  then do:
    define variable  parameter-2-134 as character no-undo .
    define variable  parameter-3-134 as character no-undo .
    define variable  parameter-4-134 as character no-undo .
    define variable  parameter-5-134 as character no-undo .
    define variable  parameter-6-134 as character no-undo .
    define variable  parameter-7-134 as character no-undo .
      assign
      parameter-3-134 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-134 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty <> 0 and gob-doc.stts = 0 " + " " + where-phrase-134) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.fact-qnty <> 0 and gob-doc.stts = 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-134
          else "true"
        )
      parameter-5-134 = (" " + " use-index obj-price" + " " + "")
      parameter-6-134 = if sort-phrase-134 = ''
                           then
        (
        " " + "" +
        " " + "  "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-134
        )
      parameter-7-134 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-134 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty <> 0 and gob-doc.stts = 0 " + " " + where-phrase-134 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-134
                          ,input parameter-4-134
                          ,input parameter-5-134
                          ,input parameter-6-134
                          ,input parameter-7-134
                          )
      .
      assign
        l-filter-open-134 = true
      .
    end.
    if l-filter-open-134 = false then do:
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
  if l-filter-open-134 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty <> 0 and gob-doc.stts = 0
     use-index obj-price
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-134 = (if p-find-next then "true":u else "false":u )
      parameter-4-134 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.fact-qnty <> 0 and gob-doc.stts = 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " ":u + where-phrase-134 + " ":u + p-find-condition + " " + " use-index obj-price"
      parameter-5-134 = ""
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-134)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-134
                          ,input parameter-5-134
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-134 = (if p-find-next then "true":u else "false":u )
      parameter-3-134 =  "FOR EACH gob-doc no-lock"
      parameter-4-134 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty <> 0 and gob-doc.stts = 0 " + " " + where-phrase-134) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.fact-qnty <> 0 and gob-doc.stts = 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-134
          else "true"
        )
      parameter-5-134 = (" " + " use-index obj-price" + " " + "" + " " + p-find-condition)
      parameter-6-134 = if sort-phrase-134 = ''
                           then
        (
        " " + "" +
        " " + "  "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-134
        )
      parameter-7-134 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-134)
                          ,input no-lock
                          ,input parameter-3-134
                          ,input parameter-4-134
                          ,input parameter-5-134
                          ,input parameter-6-134
                          ,input parameter-7-134
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
END PROCEDURE.
PROCEDURE grp-fact-qnty0.
define variable vss-include-info135 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-136  as logical   no-undo .
define variable  l-filter-open-136    as logical   .
define variable  flt-rec-136       as recid     no-undo .
define variable  filter-name-136      as character no-undo .
define variable  where-phrase-136     as character no-undo .
define variable  sort-phrase-136      as character no-undo .
define variable  where-phrase-rus-136 as character no-undo .
define variable  sort-phrase-rus-136  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-136
  ,output filter-name-136
  ,output where-phrase-136
  ,output sort-phrase-136
  ,output where-phrase-rus-136
  ,output sort-phrase-rus-136
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-136
      ) no-error .
  assign
    l-filter-open-136 = false
  .
  if flt-rec-136 <> ?
  then do:
    define variable  parameter-2-136 as character no-undo .
    define variable  parameter-3-136 as character no-undo .
    define variable  parameter-4-136 as character no-undo .
    define variable  parameter-5-136 as character no-undo .
    define variable  parameter-6-136 as character no-undo .
    define variable  parameter-7-136 as character no-undo .
      assign
      parameter-3-136 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-136 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty > 0 and gob-doc.stts = 0 " + " " + where-phrase-136) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.fact-qnty > 0 and gob-doc.stts = 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-136
          else "true"
        )
      parameter-5-136 = (" " + " use-index obj-qnty " + " " + "")
      parameter-6-136 = if sort-phrase-136 = ''
                           then
        (
        " " + "" +
        " " + "  "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-136
        )
      parameter-7-136 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-136 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty > 0 and gob-doc.stts = 0 " + " " + where-phrase-136 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-136
                          ,input parameter-4-136
                          ,input parameter-5-136
                          ,input parameter-6-136
                          ,input parameter-7-136
                          )
      .
      assign
        l-filter-open-136 = true
      .
    end.
    if l-filter-open-136 = false then do:
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
  if l-filter-open-136 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty > 0 and gob-doc.stts = 0
     use-index obj-qnty
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-136 = (if p-find-next then "true":u else "false":u )
      parameter-4-136 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.fact-qnty > 0 and gob-doc.stts = 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " ":u + where-phrase-136 + " ":u + p-find-condition + " " + " use-index obj-qnty "
      parameter-5-136 = ""
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-136)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-136
                          ,input parameter-5-136
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-136 = (if p-find-next then "true":u else "false":u )
      parameter-3-136 =  "FOR EACH gob-doc no-lock"
      parameter-4-136 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty > 0 and gob-doc.stts = 0 " + " " + where-phrase-136) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.fact-qnty > 0 and gob-doc.stts = 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-136
          else "true"
        )
      parameter-5-136 = (" " + " use-index obj-qnty " + " " + "" + " " + p-find-condition)
      parameter-6-136 = if sort-phrase-136 = ''
                           then
        (
        " " + "" +
        " " + "  "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-136
        )
      parameter-7-136 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-136)
                          ,input no-lock
                          ,input parameter-3-136
                          ,input parameter-4-136
                          ,input parameter-5-136
                          ,input parameter-6-136
                          ,input parameter-7-136
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
END PROCEDURE.
PROCEDURE grp-fact-price.
define variable vss-include-info137 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-138  as logical   no-undo .
define variable  l-filter-open-138    as logical   .
define variable  flt-rec-138       as recid     no-undo .
define variable  filter-name-138      as character no-undo .
define variable  where-phrase-138     as character no-undo .
define variable  sort-phrase-138      as character no-undo .
define variable  where-phrase-rus-138 as character no-undo .
define variable  sort-phrase-rus-138  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-138
  ,output filter-name-138
  ,output where-phrase-138
  ,output sort-phrase-138
  ,output where-phrase-rus-138
  ,output sort-phrase-rus-138
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-138
      ) no-error .
  assign
    l-filter-open-138 = false
  .
  if flt-rec-138 <> ?
  then do:
    define variable  parameter-2-138 as character no-undo .
    define variable  parameter-3-138 as character no-undo .
    define variable  parameter-4-138 as character no-undo .
    define variable  parameter-5-138 as character no-undo .
    define variable  parameter-6-138 as character no-undo .
    define variable  parameter-7-138 as character no-undo .
      assign
      parameter-3-138 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-138 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty > 0 " + " " + where-phrase-138) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.fact-qnty > 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-138
          else "true"
        )
      parameter-5-138 = (" " + " use-index obj-price" + " " + "")
      parameter-6-138 = if sort-phrase-138 = ''
                           then
        (
        " " + "" +
        " " + "  "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-138
        )
      parameter-7-138 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-138 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty > 0 " + " " + where-phrase-138 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-138
                          ,input parameter-4-138
                          ,input parameter-5-138
                          ,input parameter-6-138
                          ,input parameter-7-138
                          )
      .
      assign
        l-filter-open-138 = true
      .
    end.
    if l-filter-open-138 = false then do:
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
  if l-filter-open-138 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty > 0
     use-index obj-price
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-138 = (if p-find-next then "true":u else "false":u )
      parameter-4-138 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.fact-qnty > 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " ":u + where-phrase-138 + " ":u + p-find-condition + " " + " use-index obj-price"
      parameter-5-138 = ""
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-138)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-138
                          ,input parameter-5-138
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-138 = (if p-find-next then "true":u else "false":u )
      parameter-3-138 =  "FOR EACH gob-doc no-lock"
      parameter-4-138 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty > 0 " + " " + where-phrase-138) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.fact-qnty > 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-138
          else "true"
        )
      parameter-5-138 = (" " + " use-index obj-price" + " " + "" + " " + p-find-condition)
      parameter-6-138 = if sort-phrase-138 = ''
                           then
        (
        " " + "" +
        " " + "  "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-138
        )
      parameter-7-138 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-138)
                          ,input no-lock
                          ,input parameter-3-138
                          ,input parameter-4-138
                          ,input parameter-5-138
                          ,input parameter-6-138
                          ,input parameter-7-138
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
END PROCEDURE.
PROCEDURE grp-fact-qnty.
define variable vss-include-info139 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-140  as logical   no-undo .
define variable  l-filter-open-140    as logical   .
define variable  flt-rec-140       as recid     no-undo .
define variable  filter-name-140      as character no-undo .
define variable  where-phrase-140     as character no-undo .
define variable  sort-phrase-140      as character no-undo .
define variable  where-phrase-rus-140 as character no-undo .
define variable  sort-phrase-rus-140  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-140
  ,output filter-name-140
  ,output where-phrase-140
  ,output sort-phrase-140
  ,output where-phrase-rus-140
  ,output sort-phrase-rus-140
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-140
      ) no-error .
  assign
    l-filter-open-140 = false
  .
  if flt-rec-140 <> ?
  then do:
    define variable  parameter-2-140 as character no-undo .
    define variable  parameter-3-140 as character no-undo .
    define variable  parameter-4-140 as character no-undo .
    define variable  parameter-5-140 as character no-undo .
    define variable  parameter-6-140 as character no-undo .
    define variable  parameter-7-140 as character no-undo .
      assign
      parameter-3-140 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-140 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty <> 0 " + " " + where-phrase-140) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.fact-qnty <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-140
          else "true"
        )
      parameter-5-140 = (" " + " use-index obj-qnty" + " " + "")
      parameter-6-140 = if sort-phrase-140 = ''
                           then
        (
        " " + "" +
        " " + "  "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-140
        )
      parameter-7-140 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-140 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty <> 0 " + " " + where-phrase-140 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-140
                          ,input parameter-4-140
                          ,input parameter-5-140
                          ,input parameter-6-140
                          ,input parameter-7-140
                          )
      .
      assign
        l-filter-open-140 = true
      .
    end.
    if l-filter-open-140 = false then do:
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
  if l-filter-open-140 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty <> 0
     use-index obj-qnty
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-140 = (if p-find-next then "true":u else "false":u )
      parameter-4-140 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.fact-qnty <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " ":u + where-phrase-140 + " ":u + p-find-condition + " " + " use-index obj-qnty"
      parameter-5-140 = ""
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-140)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-140
                          ,input parameter-5-140
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-140 = (if p-find-next then "true":u else "false":u )
      parameter-3-140 =  "FOR EACH gob-doc no-lock"
      parameter-4-140 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty <> 0 " + " " + where-phrase-140) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.fact-qnty <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-140
          else "true"
        )
      parameter-5-140 = (" " + " use-index obj-qnty" + " " + "" + " " + p-find-condition)
      parameter-6-140 = if sort-phrase-140 = ''
                           then
        (
        " " + "" +
        " " + "  "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-140
        )
      parameter-7-140 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-140)
                          ,input no-lock
                          ,input parameter-3-140
                          ,input parameter-4-140
                          ,input parameter-5-140
                          ,input parameter-6-140
                          ,input parameter-7-140
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
END PROCEDURE.
PROCEDURE grp-fact-price-0.
define variable vss-include-info141 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-142  as logical   no-undo .
define variable  l-filter-open-142    as logical   .
define variable  flt-rec-142       as recid     no-undo .
define variable  filter-name-142      as character no-undo .
define variable  where-phrase-142     as character no-undo .
define variable  sort-phrase-142      as character no-undo .
define variable  where-phrase-rus-142 as character no-undo .
define variable  sort-phrase-rus-142  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-142
  ,output filter-name-142
  ,output where-phrase-142
  ,output sort-phrase-142
  ,output where-phrase-rus-142
  ,output sort-phrase-rus-142
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-142
      ) no-error .
  assign
    l-filter-open-142 = false
  .
  if flt-rec-142 <> ?
  then do:
    define variable  parameter-2-142 as character no-undo .
    define variable  parameter-3-142 as character no-undo .
    define variable  parameter-4-142 as character no-undo .
    define variable  parameter-5-142 as character no-undo .
    define variable  parameter-6-142 as character no-undo .
    define variable  parameter-7-142 as character no-undo .
      assign
      parameter-3-142 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-142 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty <> 0 and gob-doc.stts <> 0 " + " " + where-phrase-142) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.fact-qnty <> 0 and gob-doc.stts <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-142
          else "true"
        )
      parameter-5-142 = (" " + " use-index obj-price" + " " + "")
      parameter-6-142 = if sort-phrase-142 = ''
                           then
        (
        " " + "" +
        " " + "  "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-142
        )
      parameter-7-142 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-142 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty <> 0 and gob-doc.stts <> 0 " + " " + where-phrase-142 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-142
                          ,input parameter-4-142
                          ,input parameter-5-142
                          ,input parameter-6-142
                          ,input parameter-7-142
                          )
      .
      assign
        l-filter-open-142 = true
      .
    end.
    if l-filter-open-142 = false then do:
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
  if l-filter-open-142 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty <> 0 and gob-doc.stts <> 0
     use-index obj-price
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-142 = (if p-find-next then "true":u else "false":u )
      parameter-4-142 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.fact-qnty <> 0 and gob-doc.stts <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " ":u + where-phrase-142 + " ":u + p-find-condition + " " + " use-index obj-price"
      parameter-5-142 = ""
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-142)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-142
                          ,input parameter-5-142
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-142 = (if p-find-next then "true":u else "false":u )
      parameter-3-142 =  "FOR EACH gob-doc no-lock"
      parameter-4-142 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty <> 0 and gob-doc.stts <> 0 " + " " + where-phrase-142) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.fact-qnty <> 0 and gob-doc.stts <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-142
          else "true"
        )
      parameter-5-142 = (" " + " use-index obj-price" + " " + "" + " " + p-find-condition)
      parameter-6-142 = if sort-phrase-142 = ''
                           then
        (
        " " + "" +
        " " + "  "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-142
        )
      parameter-7-142 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-142)
                          ,input no-lock
                          ,input parameter-3-142
                          ,input parameter-4-142
                          ,input parameter-5-142
                          ,input parameter-6-142
                          ,input parameter-7-142
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
END PROCEDURE.
PROCEDURE grp-fact-qnty-0.
define variable vss-include-info143 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-144  as logical   no-undo .
define variable  l-filter-open-144    as logical   .
define variable  flt-rec-144       as recid     no-undo .
define variable  filter-name-144      as character no-undo .
define variable  where-phrase-144     as character no-undo .
define variable  sort-phrase-144      as character no-undo .
define variable  where-phrase-rus-144 as character no-undo .
define variable  sort-phrase-rus-144  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-144
  ,output filter-name-144
  ,output where-phrase-144
  ,output sort-phrase-144
  ,output where-phrase-rus-144
  ,output sort-phrase-rus-144
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-144
      ) no-error .
  assign
    l-filter-open-144 = false
  .
  if flt-rec-144 <> ?
  then do:
    define variable  parameter-2-144 as character no-undo .
    define variable  parameter-3-144 as character no-undo .
    define variable  parameter-4-144 as character no-undo .
    define variable  parameter-5-144 as character no-undo .
    define variable  parameter-6-144 as character no-undo .
    define variable  parameter-7-144 as character no-undo .
      assign
      parameter-3-144 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-144 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty > 0 and gob-doc.stts <> 0 " + " " + where-phrase-144) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.fact-qnty > 0 and gob-doc.stts <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-144
          else "true"
        )
      parameter-5-144 = (" " + " use-index obj-qnty" + " " + "")
      parameter-6-144 = if sort-phrase-144 = ''
                           then
        (
        " " + "" +
        " " + "  "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-144
        )
      parameter-7-144 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-144 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty > 0 and gob-doc.stts <> 0 " + " " + where-phrase-144 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-144
                          ,input parameter-4-144
                          ,input parameter-5-144
                          ,input parameter-6-144
                          ,input parameter-7-144
                          )
      .
      assign
        l-filter-open-144 = true
      .
    end.
    if l-filter-open-144 = false then do:
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
  if l-filter-open-144 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty > 0 and gob-doc.stts <> 0
     use-index obj-qnty
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-144 = (if p-find-next then "true":u else "false":u )
      parameter-4-144 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.fact-qnty > 0 and gob-doc.stts <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " ":u + where-phrase-144 + " ":u + p-find-condition + " " + " use-index obj-qnty"
      parameter-5-144 = ""
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-144)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-144
                          ,input parameter-5-144
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-144 = (if p-find-next then "true":u else "false":u )
      parameter-3-144 =  "FOR EACH gob-doc no-lock"
      parameter-4-144 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.fact-qnty > 0 and gob-doc.stts <> 0 " + " " + where-phrase-144) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.fact-qnty > 0 and gob-doc.stts <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-144
          else "true"
        )
      parameter-5-144 = (" " + " use-index obj-qnty" + " " + "" + " " + p-find-condition)
      parameter-6-144 = if sort-phrase-144 = ''
                           then
        (
        " " + "" +
        " " + "  "
        )
                           else
        (
        " " + "" +
        " " + sort-phrase-144
        )
      parameter-7-144 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-144)
                          ,input no-lock
                          ,input parameter-3-144
                          ,input parameter-4-144
                          ,input parameter-5-144
                          ,input parameter-6-144
                          ,input parameter-7-144
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
END PROCEDURE.
PROCEDURE grp-free-price0.
define variable vss-include-info145 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-146  as logical   no-undo .
define variable  l-filter-open-146    as logical   .
define variable  flt-rec-146       as recid     no-undo .
define variable  filter-name-146      as character no-undo .
define variable  where-phrase-146     as character no-undo .
define variable  sort-phrase-146      as character no-undo .
define variable  where-phrase-rus-146 as character no-undo .
define variable  sort-phrase-rus-146  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-146
  ,output filter-name-146
  ,output where-phrase-146
  ,output sort-phrase-146
  ,output where-phrase-rus-146
  ,output sort-phrase-rus-146
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-146
      ) no-error .
  assign
    l-filter-open-146 = false
  .
  if flt-rec-146 <> ?
  then do:
    define variable  parameter-2-146 as character no-undo .
    define variable  parameter-3-146 as character no-undo .
    define variable  parameter-4-146 as character no-undo .
    define variable  parameter-5-146 as character no-undo .
    define variable  parameter-6-146 as character no-undo .
    define variable  parameter-7-146 as character no-undo .
      assign
      parameter-3-146 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-146 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0 and gob-doc.stts = 0 " + " " + where-phrase-146) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.free-qnty <> 0 and gob-doc.stts = 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-146
          else "true"
        )
      parameter-5-146 = (" " + "" + " " + "")
      parameter-6-146 = if sort-phrase-146 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.price-sale                     by gob-doc.artic                     "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-146
        )
      parameter-7-146 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-146 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0 and gob-doc.stts = 0 " + " " + where-phrase-146 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-146
                          ,input parameter-4-146
                          ,input parameter-5-146
                          ,input parameter-6-146
                          ,input parameter-7-146
                          )
      .
      assign
        l-filter-open-146 = true
      .
    end.
    if l-filter-open-146 = false then do:
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
  if l-filter-open-146 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0 and gob-doc.stts = 0
       by gob-doc.price-sale                     by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-146 = (if p-find-next then "true":u else "false":u )
      parameter-4-146 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.free-qnty <> 0 and gob-doc.stts = 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " ":u + where-phrase-146 + " ":u + p-find-condition + " " + ""
      parameter-5-146 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-146)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-146
                          ,input parameter-5-146
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-146 = (if p-find-next then "true":u else "false":u )
      parameter-3-146 =  "FOR EACH gob-doc no-lock"
      parameter-4-146 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0 and gob-doc.stts = 0 " + " " + where-phrase-146) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.free-qnty <> 0 and gob-doc.stts = 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-146
          else "true"
        )
      parameter-5-146 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-146 = if sort-phrase-146 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.price-sale                     by gob-doc.artic                     "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-146
        )
      parameter-7-146 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-146)
                          ,input no-lock
                          ,input parameter-3-146
                          ,input parameter-4-146
                          ,input parameter-5-146
                          ,input parameter-6-146
                          ,input parameter-7-146
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
END PROCEDURE.
PROCEDURE grp-free-qnty0.
define variable vss-include-info147 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-148  as logical   no-undo .
define variable  l-filter-open-148    as logical   .
define variable  flt-rec-148       as recid     no-undo .
define variable  filter-name-148      as character no-undo .
define variable  where-phrase-148     as character no-undo .
define variable  sort-phrase-148      as character no-undo .
define variable  where-phrase-rus-148 as character no-undo .
define variable  sort-phrase-rus-148  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-148
  ,output filter-name-148
  ,output where-phrase-148
  ,output sort-phrase-148
  ,output where-phrase-rus-148
  ,output sort-phrase-rus-148
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-148
      ) no-error .
  assign
    l-filter-open-148 = false
  .
  if flt-rec-148 <> ?
  then do:
    define variable  parameter-2-148 as character no-undo .
    define variable  parameter-3-148 as character no-undo .
    define variable  parameter-4-148 as character no-undo .
    define variable  parameter-5-148 as character no-undo .
    define variable  parameter-6-148 as character no-undo .
    define variable  parameter-7-148 as character no-undo .
      assign
      parameter-3-148 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-148 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0 and gob-doc.stts = 0 " + " " + where-phrase-148) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.free-qnty <> 0 and gob-doc.stts = 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-148
          else "true"
        )
      parameter-5-148 = (" " + "" + " " + "")
      parameter-6-148 = if sort-phrase-148 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.free-qnty                     by gob-doc.artic                     "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-148
        )
      parameter-7-148 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-148 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0 and gob-doc.stts = 0 " + " " + where-phrase-148 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-148
                          ,input parameter-4-148
                          ,input parameter-5-148
                          ,input parameter-6-148
                          ,input parameter-7-148
                          )
      .
      assign
        l-filter-open-148 = true
      .
    end.
    if l-filter-open-148 = false then do:
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
  if l-filter-open-148 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0 and gob-doc.stts = 0
       by gob-doc.free-qnty                     by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-148 = (if p-find-next then "true":u else "false":u )
      parameter-4-148 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.free-qnty <> 0 and gob-doc.stts = 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " ":u + where-phrase-148 + " ":u + p-find-condition + " " + ""
      parameter-5-148 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-148)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-148
                          ,input parameter-5-148
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-148 = (if p-find-next then "true":u else "false":u )
      parameter-3-148 =  "FOR EACH gob-doc no-lock"
      parameter-4-148 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0 and gob-doc.stts = 0 " + " " + where-phrase-148) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.free-qnty <> 0 and gob-doc.stts = 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-148
          else "true"
        )
      parameter-5-148 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-148 = if sort-phrase-148 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.free-qnty                     by gob-doc.artic                     "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-148
        )
      parameter-7-148 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-148)
                          ,input no-lock
                          ,input parameter-3-148
                          ,input parameter-4-148
                          ,input parameter-5-148
                          ,input parameter-6-148
                          ,input parameter-7-148
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
END PROCEDURE.
PROCEDURE grp-free-price.
define variable vss-include-info149 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-150  as logical   no-undo .
define variable  l-filter-open-150    as logical   .
define variable  flt-rec-150       as recid     no-undo .
define variable  filter-name-150      as character no-undo .
define variable  where-phrase-150     as character no-undo .
define variable  sort-phrase-150      as character no-undo .
define variable  where-phrase-rus-150 as character no-undo .
define variable  sort-phrase-rus-150  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-150
  ,output filter-name-150
  ,output where-phrase-150
  ,output sort-phrase-150
  ,output where-phrase-rus-150
  ,output sort-phrase-rus-150
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-150
      ) no-error .
  assign
    l-filter-open-150 = false
  .
  if flt-rec-150 <> ?
  then do:
    define variable  parameter-2-150 as character no-undo .
    define variable  parameter-3-150 as character no-undo .
    define variable  parameter-4-150 as character no-undo .
    define variable  parameter-5-150 as character no-undo .
    define variable  parameter-6-150 as character no-undo .
    define variable  parameter-7-150 as character no-undo .
      assign
      parameter-3-150 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-150 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0  " + " " + where-phrase-150) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.free-qnty <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-150
          else "true"
        )
      parameter-5-150 = (" " + "" + " " + "")
      parameter-6-150 = if sort-phrase-150 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.price-sale                     by gob-doc.artic                     "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-150
        )
      parameter-7-150 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-150 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0  " + " " + where-phrase-150 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-150
                          ,input parameter-4-150
                          ,input parameter-5-150
                          ,input parameter-6-150
                          ,input parameter-7-150
                          )
      .
      assign
        l-filter-open-150 = true
      .
    end.
    if l-filter-open-150 = false then do:
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
  if l-filter-open-150 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0
       by gob-doc.price-sale                     by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-150 = (if p-find-next then "true":u else "false":u )
      parameter-4-150 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.free-qnty <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " ":u + where-phrase-150 + " ":u + p-find-condition + " " + ""
      parameter-5-150 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-150)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-150
                          ,input parameter-5-150
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-150 = (if p-find-next then "true":u else "false":u )
      parameter-3-150 =  "FOR EACH gob-doc no-lock"
      parameter-4-150 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0  " + " " + where-phrase-150) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.free-qnty <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-150
          else "true"
        )
      parameter-5-150 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-150 = if sort-phrase-150 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.price-sale                     by gob-doc.artic                     "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-150
        )
      parameter-7-150 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-150)
                          ,input no-lock
                          ,input parameter-3-150
                          ,input parameter-4-150
                          ,input parameter-5-150
                          ,input parameter-6-150
                          ,input parameter-7-150
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
END PROCEDURE.
PROCEDURE grp-free-qnty.
define variable vss-include-info151 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-152  as logical   no-undo .
define variable  l-filter-open-152    as logical   .
define variable  flt-rec-152       as recid     no-undo .
define variable  filter-name-152      as character no-undo .
define variable  where-phrase-152     as character no-undo .
define variable  sort-phrase-152      as character no-undo .
define variable  where-phrase-rus-152 as character no-undo .
define variable  sort-phrase-rus-152  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-152
  ,output filter-name-152
  ,output where-phrase-152
  ,output sort-phrase-152
  ,output where-phrase-rus-152
  ,output sort-phrase-rus-152
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-152
      ) no-error .
  assign
    l-filter-open-152 = false
  .
  if flt-rec-152 <> ?
  then do:
    define variable  parameter-2-152 as character no-undo .
    define variable  parameter-3-152 as character no-undo .
    define variable  parameter-4-152 as character no-undo .
    define variable  parameter-5-152 as character no-undo .
    define variable  parameter-6-152 as character no-undo .
    define variable  parameter-7-152 as character no-undo .
      assign
      parameter-3-152 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-152 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0 " + " " + where-phrase-152) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.free-qnty <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-152
          else "true"
        )
      parameter-5-152 = (" " + "" + " " + "")
      parameter-6-152 = if sort-phrase-152 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.free-qnty                     by gob-doc.artic                     "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-152
        )
      parameter-7-152 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-152 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0 " + " " + where-phrase-152 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-152
                          ,input parameter-4-152
                          ,input parameter-5-152
                          ,input parameter-6-152
                          ,input parameter-7-152
                          )
      .
      assign
        l-filter-open-152 = true
      .
    end.
    if l-filter-open-152 = false then do:
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
  if l-filter-open-152 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0
       by gob-doc.free-qnty                     by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-152 = (if p-find-next then "true":u else "false":u )
      parameter-4-152 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.free-qnty <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " ":u + where-phrase-152 + " ":u + p-find-condition + " " + ""
      parameter-5-152 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-152)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-152
                          ,input parameter-5-152
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-152 = (if p-find-next then "true":u else "false":u )
      parameter-3-152 =  "FOR EACH gob-doc no-lock"
      parameter-4-152 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0 " + " " + where-phrase-152) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.free-qnty <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-152
          else "true"
        )
      parameter-5-152 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-152 = if sort-phrase-152 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.free-qnty                     by gob-doc.artic                     "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-152
        )
      parameter-7-152 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-152)
                          ,input no-lock
                          ,input parameter-3-152
                          ,input parameter-4-152
                          ,input parameter-5-152
                          ,input parameter-6-152
                          ,input parameter-7-152
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
END PROCEDURE.
PROCEDURE grp-free-price-0.
define variable vss-include-info153 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-154  as logical   no-undo .
define variable  l-filter-open-154    as logical   .
define variable  flt-rec-154       as recid     no-undo .
define variable  filter-name-154      as character no-undo .
define variable  where-phrase-154     as character no-undo .
define variable  sort-phrase-154      as character no-undo .
define variable  where-phrase-rus-154 as character no-undo .
define variable  sort-phrase-rus-154  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-154
  ,output filter-name-154
  ,output where-phrase-154
  ,output sort-phrase-154
  ,output where-phrase-rus-154
  ,output sort-phrase-rus-154
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-154
      ) no-error .
  assign
    l-filter-open-154 = false
  .
  if flt-rec-154 <> ?
  then do:
    define variable  parameter-2-154 as character no-undo .
    define variable  parameter-3-154 as character no-undo .
    define variable  parameter-4-154 as character no-undo .
    define variable  parameter-5-154 as character no-undo .
    define variable  parameter-6-154 as character no-undo .
    define variable  parameter-7-154 as character no-undo .
      assign
      parameter-3-154 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-154 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0 and gob-doc.stts <> 0 " + " " + where-phrase-154) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.free-qnty <> 0 and gob-doc.stts <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-154
          else "true"
        )
      parameter-5-154 = (" " + "" + " " + "")
      parameter-6-154 = if sort-phrase-154 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.price-sale                     by gob-doc.artic                     "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-154
        )
      parameter-7-154 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-154 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0 and gob-doc.stts <> 0 " + " " + where-phrase-154 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-154
                          ,input parameter-4-154
                          ,input parameter-5-154
                          ,input parameter-6-154
                          ,input parameter-7-154
                          )
      .
      assign
        l-filter-open-154 = true
      .
    end.
    if l-filter-open-154 = false then do:
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
  if l-filter-open-154 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0 and gob-doc.stts <> 0
       by gob-doc.price-sale                     by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-154 = (if p-find-next then "true":u else "false":u )
      parameter-4-154 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.free-qnty <> 0 and gob-doc.stts <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " ":u + where-phrase-154 + " ":u + p-find-condition + " " + ""
      parameter-5-154 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-154)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-154
                          ,input parameter-5-154
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-154 = (if p-find-next then "true":u else "false":u )
      parameter-3-154 =  "FOR EACH gob-doc no-lock"
      parameter-4-154 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0 and gob-doc.stts <> 0 " + " " + where-phrase-154) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.free-qnty <> 0 and gob-doc.stts <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-154
          else "true"
        )
      parameter-5-154 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-154 = if sort-phrase-154 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.price-sale                     by gob-doc.artic                     "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-154
        )
      parameter-7-154 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-154)
                          ,input no-lock
                          ,input parameter-3-154
                          ,input parameter-4-154
                          ,input parameter-5-154
                          ,input parameter-6-154
                          ,input parameter-7-154
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
END PROCEDURE.
PROCEDURE grp-free-qnty-0.
define variable vss-include-info155 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-156  as logical   no-undo .
define variable  l-filter-open-156    as logical   .
define variable  flt-rec-156       as recid     no-undo .
define variable  filter-name-156      as character no-undo .
define variable  where-phrase-156     as character no-undo .
define variable  sort-phrase-156      as character no-undo .
define variable  where-phrase-rus-156 as character no-undo .
define variable  sort-phrase-rus-156  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-156
  ,output filter-name-156
  ,output where-phrase-156
  ,output sort-phrase-156
  ,output where-phrase-rus-156
  ,output sort-phrase-rus-156
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-156
      ) no-error .
  assign
    l-filter-open-156 = false
  .
  if flt-rec-156 <> ?
  then do:
    define variable  parameter-2-156 as character no-undo .
    define variable  parameter-3-156 as character no-undo .
    define variable  parameter-4-156 as character no-undo .
    define variable  parameter-5-156 as character no-undo .
    define variable  parameter-6-156 as character no-undo .
    define variable  parameter-7-156 as character no-undo .
      assign
      parameter-3-156 =
                              "FOR EACH gob-doc no-lock"
      parameter-4-156 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0 and gob-doc.stts <> 0 " + " " + where-phrase-156) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.free-qnty <> 0 and gob-doc.stts <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-156
          else "true"
        )
      parameter-5-156 = (" " + "" + " " + "")
      parameter-6-156 = if sort-phrase-156 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.free-qnty                     by gob-doc.artic                     "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-156
        )
      parameter-7-156 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-156 =
          (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0 and gob-doc.stts <> 0 " + " " + where-phrase-156 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds:handle
                          ,input parameter-3-156
                          ,input parameter-4-156
                          ,input parameter-5-156
                          ,input parameter-6-156
                          ,input parameter-7-156
                          )
      .
      assign
        l-filter-open-156 = true
      .
    end.
    if l-filter-open-156 = false then do:
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
  if l-filter-open-156 = false then do:
    OPEN QUERY br-gds FOR EACH gob-doc no-lock
      where  gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0 and gob-doc.stts <> 0
       by gob-doc.free-qnty                     by gob-doc.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( gob-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds:handle:get-buffer-handle(1) = (buffer gob-doc:handle) then do:
      assign
      parameter-2-156 = (if p-find-next then "true":u else "false":u )
      parameter-4-156 =
        "where ":u +  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.free-qnty <> 0 and gob-doc.stts <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " ":u + where-phrase-156 + " ":u + p-find-condition + " " + ""
      parameter-5-156 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input rowid(gob-doc)
                          ,input logical(parameter-2-156)
                          ,input no-lock
                          ,input (buffer gob-doc:handle)
                          ,input parameter-4-156
                          ,input parameter-5-156
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-156 = (if p-find-next then "true":u else "false":u )
      parameter-3-156 =  "FOR EACH gob-doc no-lock"
      parameter-4-156 =
        (
          if (" gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code                     and gob-doc.free-qnty <> 0 and gob-doc.stts <> 0 " + " " + where-phrase-156) <> ""
          then  substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4                     and gob-doc.free-qnty <> 0 and gob-doc.stts <> 0 '                       , chr(34),                   g-grp, pobj-type, pobj-code) + " " + where-phrase-156
          else "true"
        )
      parameter-5-156 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-156 = if sort-phrase-156 = ''
                           then
        (
        " " + "  " +
        " " + " by gob-doc.free-qnty                     by gob-doc.artic                     "
        )
                           else
        (
        " " + "  " +
        " " + sort-phrase-156
        )
      parameter-7-156 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds:handle
                          ,input logical(parameter-2-156)
                          ,input no-lock
                          ,input parameter-3-156
                          ,input parameter-4-156
                          ,input parameter-5-156
                          ,input parameter-6-156
                          ,input parameter-7-156
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
END PROCEDURE.
