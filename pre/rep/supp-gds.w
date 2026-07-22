define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input param p-r-parts as character      no-undo.
define input param p-one-all as character      no-undo.
define input param p-supp-type as character    no-undo.
define input param p-supp-code as integer      no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Текущие остатки товаров по партиям по поставщику".
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
define new global shared variable g#libbcrcn as handle no-undo .
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
procedure alc-lib_mark-name :
  define input  parameter p-mark-db-num   as integer   no-undo .
  define input  parameter p-mark-code     as integer   no-undo .
  define output parameter p-mark-name     as character no-undo .
  define buffer buf_ex-mark for ub.ex-mark .
  do
  on error undo, return error return-value
  :
    if p-mark-db-num = ?
    or p-mark-code   = ?
    then do:
      assign
        p-mark-name = '?':u
      .
      return .
    end.
    if  p-mark-db-num = 0
    and p-mark-code   = 0
    then do:
      assign
        p-mark-name = ""
      .
      return .
    end.
    find first buf_ex-mark no-lock
      where buf_ex-mark.db-num    = p-mark-db-num
        and buf_ex-mark.mark-code = p-mark-code
      no-error .
    if available buf_ex-mark
    then do:
      assign
        p-mark-name = substitute('&1':u
                                ,buf_ex-mark.mark-name
                                )
      .
    end.
  end.
end procedure.
procedure alc-lib_get-new-part-code :
  define input  parameter p-obj-type       as character no-undo .
  define input  parameter p-obj-code       as integer   no-undo .
  define input  parameter p-prod-type      as character no-undo .
  define input  parameter p-prod-code      as integer   no-undo .
  define input  parameter p-artic          as character no-undo .
  define input  parameter p-doc-code       as character no-undo .
  define output parameter p-new-part-code  as character no-undo .
  define variable v-cur-part-code as integer no-undo.
  define variable v-max-part-code as integer no-undo.
  define variable i               as integer no-undo.
  define buffer bf_parts for ub.parts .
  do
  on error undo, return error return-value
  :
    assign
      v-max-part-code = 0
    .
    for each bf_parts no-lock
          where bf_parts.obj-type  = p-obj-type  and
                bf_parts.obj-code  = p-obj-code  and
                bf_parts.prod-type = p-prod-type and
                bf_parts.prod-code = p-prod-code and
                bf_parts.artic     = p-artic     and
                bf_parts.out-code  = p-doc-code
      :
      assign
        v-cur-part-code = integer(bf_parts.part-code)
        no-error.
      if error-status:error = no and v-cur-part-code > v-max-part-code then do:
        assign
          v-max-part-code = v-cur-part-code
        .
      end.
    end.
    assign
      p-new-part-code = string (v-max-part-code + 1)
    .
  end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-parts-part-code RETURNS CHARACTER
  ( BUFFER buf_parts FOR ub.parts
  , INPUT p-goods-alcohol-prod AS LOGICAL
  ) :
  define variable v-show-part-code as character no-undo .
  if (p-goods-alcohol-prod = false) and (buf_parts.part-code = '':u)
  then do:
    return '------':u .
  end.
  run partsfnc_get-parts-show-code in this-procedure
    (input  buf_parts.part-code
    ,input  buf_parts.mark-db-num
    ,input  buf_parts.mark-code
    ,input  buf_parts.alc-bottling-date
    ,input  p-goods-alcohol-prod
    ,output v-show-part-code
    ) .
  return v-show-part-code .
END FUNCTION.
procedure partsfnc_get-parts-show-code :
  define input  parameter p-part-code          as character no-undo .
  define input  parameter p-mark-db-num        as integer   no-undo .
  define input  parameter p-mark-code          as integer   no-undo .
  define input  parameter p-alc-bottling-date  as date      no-undo .
  define input  parameter p-goods-alcohol-prod as logical   no-undo .
  define output parameter p-show-code          as character no-undo .
  define variable v-alc-mark-name as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-show-code = '':u
    .
    if p-goods-alcohol-prod = true
    then do:
      run alc-lib_mark-name in this-procedure
        (input  p-mark-db-num
        ,input  p-mark-code
        ,output v-alc-mark-name
        ) .
      assign
        p-show-code = substitute('&1,&2':u
                                ,v-alc-mark-name
                                ,string(p-alc-bottling-date,'99/99/9999':u)
                                )
      .
    end.
    else do:
      assign
        p-show-code = p-part-code
      .
    end.
    return '':u .
  end.
end procedure.
FUNCTION get-parts-out-code RETURNS CHARACTER
  ( BUFFER buf_parts FOR ub.parts ) :
  case buf_parts.out-code :
    when 'free-zone':U then do:
      return "свободно" .
    end.
    when 'out-zone':U then do:
      return "расход" .
    end.
    otherwise do:
      if buf_parts.doc-type = 'акт':U then do:
        return caps("ЦН") + " № " + buf_parts.out-code .
      end.
      else do:
        define variable v-ext-name       as character no-undo .
        define variable v-trn-doc-status as character no-undo .
        define buffer buf_trn-doc for ub.trn-doc .
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_parts.out-code
          no-error .
        if available buf_trn-doc then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run docextnm in g#library
  (input  buf_parts.out-code
  ,output v-ext-name
  )  .
          assign
            v-trn-doc-status = (if buf_trn-doc.status_ = 'факт':U then 'факт':U else "")
          .
        end.
        else do:
          assign
            v-ext-name       = caps(substring(buf_parts.doc-type, 1, 1))
            v-trn-doc-status = (if buf_parts.status_ = ? then 'факт':U else "")
          .
        end.
        return substitute("&1 № &2 &3"
           ,v-ext-name
           ,buf_parts.out-code
           ,v-trn-doc-status
           ) .
      end.
    end.
  end case .
  return "".
END FUNCTION.
FUNCTION get-parts-cli-qnty RETURNS DECIMAL
  ( BUFFER buf_parts FOR ub.parts
  , INPUT p-goods-twounit AS LOGICAL
  ) :
  if p-goods-twounit then do:
    RETURN buf_parts.cli-qnty .
  end.
  else do:
    RETURN buf_parts.fact-qnty / buf_parts.cli-base-rate .
  end.
  RETURN ? .
END FUNCTION.
FUNCTION get-parts-cli-base-rate RETURNS DECIMAL
  ( BUFFER buf_parts FOR ub.parts
  , INPUT p-goods-twounit AS LOGICAL
  ) :
  if p-goods-twounit then do:
    RETURN buf_parts.fact-qnty / buf_parts.cli-qnty .
  end.
  else do:
    RETURN buf_parts.cli-base-rate .
  end.
  RETURN ? .
END FUNCTION.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable filter-point as character no-undo init "supp-gds" .
define variable filter-point0 as character no-undo init "supp-gds" .
define variable filter-label0 as character no-undo init "Поставщик-партии-остатки" .
define variable filter-label as character no-undo init "Поставщик-партии-остатки" .
define variable sort-column-name as character no-undo .
define new shared buffer s-parts for ub.parts.
define new shared buffer s-goods for ub.goods.
define variable conf-par as char             no-undo.
define variable par-type as char             no-undo.
define variable v-doc-rec as recid no-undo .
define variable v-prt-rec as recid no-undo .
define variable p-curr-host-code like ub.sysconf.host-code no-undo .
define buffer supp_clients for ub.clients.
define buffer supp_currency for ub.currency.
define buffer buf_bar-code for ub.bar-code .
define buffer supp_pay-type for ub.pay-type.
def BUTTON b-doc
     LABEL "Д&окум"
     size 10 BY 1.
def BUTTON b-exit AUTO-GO
     LABEL "&Выход "
     size 10 BY 1.
def BUTTON b-sch
     LABEL "&Фильтр"
     size 10 BY 1.
def BUTTON b-gds
     LABEL "&Товар"
     size 10 BY 1.
def BUTTON b-print
     LABEL "Пе&чать"
     size 10 BY 1.
def BUTTON b-help
     LABEL "Помо&щь"
     size 10 BY 1.
def BUTTON b-in
     LABEL "П&Н"
     size 10 BY 1.
def BUTTON b-alt
     LABEL "Доп.&БК"
     size 10 BY 1.
def BUTTON b-pl
     LABEL "&Место"
     size 10 BY 1.
DEFINE VARIABLE rs-one-all AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущий объект", "current",
          "Все объекты фирмы",    "all"
     SIZE 40 BY .83
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE rs-parts AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
         "Приходы",      "input",
         "Все партии",   "all",
         "Факт остатки", "stock",
         "Свободно",     "free"
     SIZE 55.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE sh-code AS INTEGER FORMAT "999999999":U INITIAL 0
     LABEL "Поиск"
     VIEW-AS FILL-IN
     SIZE 10 BY .79 NO-UNDO.
DEFINE VARIABLE fi-b-code AS INTEGER FORMAT "999999999":U INITIAL 0
     LABEL "Бар-код"
     VIEW-AS FILL-IN
     SIZE 10 BY .79
     FGCOLOR 4  NO-UNDO.
def buffer p-b for ub.parts.
define variable ed-notes AS CHARACTER
     VIEW-AS EDITOR
     SIZE 49.5 BY 2.5 NO-UNDO.
DEF RECTANGLE rect-in EDGE-PIXELS 1 GRAPHIC-EDGE SIZE 77.5 BY 3.5  BGCOLOR 8.
def new shared QUERY br-parts FOR s-parts, s-goods SCROLLING.
define BROWSE br-parts QUERY br-parts NO-LOCK DISPLAY
      s-parts.artic     COLUMN-LABEL "Артикул"
      s-goods.gds-name  COLUMN-LABEL "Название"    FORMAT "x(30)"
      s-parts.fact-qnty COLUMN-LABEL "Факт"        FORMAT "->>>,>>9.<<<"
      s-parts.price-base
      (s-parts.price-base * s-parts.fact-qnty)
                        column-label "Сумма (вал)" format "->,>>>,>>>,>>9.99"
      s-parts.price-rubl
      (s-parts.price-rubl * s-parts.fact-qnty)
                        column-label "Сумма (руб)" format "->,>>>,>>>,>>9.99"
      get-parts-out-code (buffer s-parts)  COLUMN-LABEL 'статус':U     FORMAT "x(16)"
      (if s-parts.part-code = "" then
         "------"
       else
         s-parts.part-code)
                        COLUMN-LABEL "Партия"      FORMAT "x(14)"
      (s-parts.obj-type + " " + STRING (s-parts.obj-code))
                        COLUMN-LABEL "Объект"      FORMAT "x(13)"
    WITH SIZE 98 BY 9.5 SEPARATORS.
def FRAME dialog-frame
     b-exit             AT ROW 1  COL 1
     b-gds              AT ROW 1  COL 19
     b-in               AT ROW 1  COL 29
     b-doc              AT ROW 1  COL 39
     b-sch              AT ROW 1  COL 49
     b-alt              AT ROW 1  COL 59
     b-pl               AT ROW 1  COL 69
     b-print            AT ROW 1  COL 79
     b-help             AT ROW 1  COL 89
     rs-parts           AT ROW 2  COL 1                  NO-LABEL
     rs-one-all         AT ROW 3 COL 11.5 NO-LABEL
     sh-code            AT ROW 4 COL 10 COLON-ALIGNED HELP   "Поиск по бар-коду"
     fi-b-code          AT ROW 4 COL 31 COLON-ALIGNED
     br-parts           AT ROW 5   COL 1.5
     rect-in            at row 15.2  col 1.5
     "  Информация из ПН" VIEW-AS TEXT SIZE 18 BY 0.7
                        AT ROW 14.5  COL 30
     s-parts.in-code    AT ROW 15.5  COL 8    COLON-ALIGNED LABEL "Номер"        VIEW-AS FILL-IN SIZE 15    BY 1 FGCOLOR 4
     s-parts.fact-date  AT ROW 15.5  COL 28   COLON-ALIGNED LABEL "Дата"         VIEW-AS FILL-IN SIZE 10    BY 1 FGCOLOR 4
     supp_clients.obj-name   AT ROW 15.5  COL 48   COLON-ALIGNED LABEL "Пост-к"       VIEW-AS FILL-IN SIZE 25    BY 1 FGCOLOR 4
     supp_pay-type.obj-name  AT ROW 16.5  COL 9   COLON-ALIGNED LABEL "Оплата"       VIEW-AS FILL-IN SIZE 29.25 BY 1 FGCOLOR 4
     s-parts.vat-type   AT ROW 16.5  COL 48   COLON-ALIGNED LABEL "НДС"          VIEW-AS FILL-IN SIZE 10    BY 1 FGCOLOR 4
     s-parts.vat-pc     AT ROW 16.5  COL 68   COLON-ALIGNED LABEL "% НДС"        VIEW-AS FILL-IN SIZE 8     BY 1 FGCOLOR 4
     s-parts.price-cli  AT ROW 17.5  COL 28   COLON-ALIGNED LABEL "Цена пост-ка" VIEW-AS FILL-IN SIZE 29.25 BY 1 FGCOLOR 4
     supp_currency.curr-abbr AT ROW 17.5  COL 48   COLON-ALIGNED no-LABEL             VIEW-AS FILL-IN SIZE 10    BY 1 FGCOLOR 4
     ed-notes           AT ROW 19    COL 29.5               no-label                                             bgcolor 8 fgcolor 4
     SPACE(0.49) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
         TITLE "Партии".
ASSIGN
       FRAME dialog-frame:SCROLLABLE       = FALSE.
on choose of b-print in frame dialog-frame do:
apply "entry" to br-parts in frame dialog-frame.
run rep/r-supgds.p (input parparentproc, input p-curr-obj-type, input p-curr-obj-code,  frame dialog-frame:title).
end.
ON entry OF ed-notes IN FRAME dialog-frame DO:
if not available s-parts then do:
  message
    "Неправильный выбор партии."
    view-as alert-box.
  return no-apply.
end.
v-prt-rec = recid (s-parts).
END.
ON leave OF ed-notes IN FRAME dialog-frame DO:
do on stop undo, return no-apply:
  find p-b where recid (p-b) = v-prt-rec exclusive.
  p-b.PS = input frame dialog-frame ed-notes.
end.
END.
ON RETURN, MOUSE-SELECT-DBLCLICK OF ed-notes IN FRAME dialog-frame DO:
apply "entry" to br-parts in frame dialog-frame.
return no-apply.
END.
ON RETURN, MOUSE-SELECT-DBLCLICK OF br-parts IN FRAME dialog-frame DO:
END.
on value-changed of br-parts do:
define buffer s-prt for ub.gds-prt.
  if available s-parts then do:
    v-doc-rec = recid(s-parts).
    find first s-prt no-lock where
               s-prt.upper-code = s-goods.prt-root.
    find  first buf_bar-code no-lock where
          buf_bar-code.gds-code  = s-goods.gds-code
      and buf_bar-code.node-code = s-prt.node-code
     and buf_bar-code.in-code   = s-parts.in-code
     and buf_bar-code.part-code = s-parts.part-code
     and buf_bar-code.unit-cli  = s-goods.unit-base no-error.
    if available buf_bar-code then do:
      fi-b-code = buf_bar-code.b-code.
      display
      fi-b-code with frame dialog-frame.
    end.
    else
      display
      ? @ fi-b-code with frame dialog-frame.
    find first supp_pay-type no-lock where
         supp_pay-type.obj-code = s-parts.pay-code no-error.
    if available supp_pay-type then
      display
      supp_pay-type.obj-name
      with frame dialog-frame.
    else
      display
      ? @ supp_pay-type.obj-name with frame dialog-frame.
    find first supp_currency no-lock where
         supp_currency.curr-code = s-parts.exch-code no-error.
    if available supp_currency then do:
      display
      supp_currency.curr-abbr with frame dialog-frame.
    end.
    else do:
      display
      ? @ supp_currency.curr-abbr
      with frame dialog-frame.
    end.
    ed-notes = s-parts.PS.
    display
    s-parts.vat-pc
    s-parts.vat-type
    s-parts.price-cli
    s-parts.in-code
    s-parts.fact-date
    supp_clients.obj-name
    ed-notes with frame dialog-frame.
  end.
  else do:
    V-DOC-REC = ?.
  END.
end.
ON CTRL-J OF sh-code IN FRAME Dialog-Frame
DO:
  run proc-find-sh-code in this-procedure(yes, input frame dialog-frame sh-code) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sh-code IN FRAME Dialog-Frame
DO:
  run proc-find-sh-code in this-procedure(no, input frame dialog-frame sh-code) no-error.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF rs-parts IN FRAME dialog-frame
DO:
define variable v-prt-rec as recid no-undo .
if available s-parts then v-prt-rec = recid (s-parts).
assign rs-parts.
run OpenBr in this-procedure ( input yes, input no, input '':U).
apply "entry" to br-parts.
reposition br-parts to recid v-prt-rec no-error.
return no-apply.
END.
ON VALUE-CHANGED OF rs-one-all IN FRAME dialog-frame
DO:
define variable v-prt-rec as recid no-undo .
if available s-parts then v-prt-rec = recid (s-parts).
assign rs-one-all.
run OpenBr in this-procedure ( input yes, input no, input '':U).
apply "entry" to br-parts.
reposition br-parts to recid v-prt-rec no-error.
return no-apply.
END.
on choose of b-sch in frame dialog-frame do:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
end.
on choose of b-gds in frame dialog-frame do:
if not available s-parts then do:
  message "Неправильный выбор партии.".
  return no-apply.
end.
find s-goods where s-goods.artic = s-parts.artic
                      and s-goods.prod-type = s-parts.prod-type
                      and s-goods.prod-code = s-parts.prod-code no-lock.
run str/showgds.p ( input parparentproc
                   ,input ?
                   ,input s-goods.gds-code
                   ,input 'ПРОСМОТР':U).
apply "entry" to br-parts in frame dialog-frame.
end.
on choose of b-doc in frame dialog-frame do:
if not available s-parts then do:
  message "Неправильный выбор партии.".
  return no-apply.
end.
find ub.trn-doc where ub.trn-doc.doc-code = s-parts.out-code no-lock no-error.
if not available trn-doc then do:
  message "Документ не найден.".
  return no-apply.
end.
find ub.doc-line where ub.doc-line.doc-code = ub.trn-doc.doc-code
                        and ub.doc-line.artic = s-parts.artic
                        and ub.doc-line.prod-type = s-parts.prod-type
                        and ub.doc-line.prod-code = s-parts.prod-code no-lock.
run str/trn-lkp.p (parparentproc, recid (ub.trn-doc), recid(ub.doc-line)).
apply "entry" to br-parts in frame dialog-frame.
end.
on choose of b-in in frame dialog-frame do:
if not available s-parts then do:
  message "Неправильный выбор партии.".
  return no-apply.
end.
find ub.trn-doc where ub.trn-doc.doc-code = s-parts.in-code no-lock no-error.
if not available ub.trn-doc then do:
  message "Документ не найден.".
  return no-apply.
end.
find ub.doc-line where ub.doc-line.doc-code = ub.trn-doc.doc-code
                        and ub.doc-line.artic = s-parts.artic
                        and ub.doc-line.prod-type = s-parts.prod-type
                        and ub.doc-line.prod-code = s-parts.prod-code no-lock.
run str/trn-lkp.p (parparentproc, recid (ub.trn-doc), recid(ub.doc-line)).
apply "entry" to br-parts in frame dialog-frame.
end.
ON CHOOSE OF b-alt IN FRAME dialog-frame  DO:
def buffer s-code for ub.bar-code.
def buffer s-prt  for ub.gds-prt.
if not available s-parts then do:
  message "Неправильный выбор партии.".
  return no-apply.
end.
find s-goods no-lock where
     s-goods.artic = s-parts.artic and
     s-goods.prod-type = s-parts.prod-type and
     s-goods.prod-code = s-parts.prod-code.
find first s-prt no-lock where
           s-prt.upper-code = s-goods.prt-root.
find s-code no-lock where
     s-code.gds-code  = s-goods.gds-code and
     s-code.node-code = s-prt.node-code and
     s-code.in-code   = s-parts.in-code and
     s-code.part-code = s-parts.part-code and
     s-code.unit-cli  = s-goods.unit-base no-error.
if available s-code then
  run ref/alt-bc.w (parparentproc, p-curr-obj-type, p-curr-obj-code, s-code.b-code).
END.
ON CHOOSE OF b-pl IN FRAME dialog-frame  DO:
if not available s-parts then do:
  message "Неправильный выбор партии.".
  return no-apply.
end.
run str/pl-lkp.w
  (
    input parparentproc
   ,input recid(s-parts)
  ).
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME dialog-frame:PARENT eq ?
THEN FRAME dialog-frame:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME dialog-frame APPLY "END-ERROR":U TO SELF.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame dialog-frame
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
on choose of b-help in frame dialog-frame
do:
  apply "help":u to frame dialog-frame .
end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame dialog-frame:width - 0.3
                fh            = frame dialog-frame:first-child
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame dialog-frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame dialog-frame :height-chars)
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
    if frame dialog-frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame dialog-frame :height-chars)
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
            frame dialog-frame :height = v-frame-height
          .
          if frame dialog-frame :scrollable = true
          then do:
            assign
              frame dialog-frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame dialog-frame :scrollable = true
          then do:
            assign
              frame dialog-frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame dialog-frame :height = v-frame-height
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
      v-frame-height = frame dialog-frame :height
      v-frame-virtual-height = frame dialog-frame :virtual-height
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
      v-field-group-handle = frame dialog-frame :first-child
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
    do with frame dialog-frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame dialog-frame :scrollable = true
      then do:
        assign
          frame dialog-frame :virtual-height = frame dialog-frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame dialog-frame :height = frame dialog-frame :height + p-change-value
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
        frame dialog-frame :height = frame dialog-frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame dialog-frame :scrollable = true
      then do:
        assign
          frame dialog-frame :virtual-height = frame dialog-frame :virtual-height + p-change-value
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
          ,input  string(frame dialog-frame :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame dialog-frame :height)
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
    if frame dialog-frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame dialog-frame :width
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
    if frame dialog-frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame dialog-frame :width
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
            frame dialog-frame :width = v-frame-width
          .
          if frame dialog-frame :scrollable = true
          then do:
            assign
              frame dialog-frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame dialog-frame :scrollable = true
          then do:
            assign
              frame dialog-frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame dialog-frame :width = v-frame-width
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
      v-frame-width = frame dialog-frame :width
      v-frame-virtual-width = frame dialog-frame :virtual-width
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
      v-field-group-handle = frame dialog-frame :first-child
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
    do with frame dialog-frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame dialog-frame :scrollable = true
      then do:
        assign
          frame dialog-frame :virtual-width = frame dialog-frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame dialog-frame :width = v-frame-width + p-change-value
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
        frame dialog-frame :width = frame dialog-frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame dialog-frame :scrollable = true
      then do:
        assign
          frame dialog-frame :virtual-width = frame dialog-frame :virtual-width + p-change-value
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
          ,input  string(frame dialog-frame :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame dialog-frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame dialog-frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame dialog-frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame dialog-frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame dialog-frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame dialog-frame :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame dialog-frame
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
      v-row-delta = v-new-row - frame dialog-frame :height
      v-col-delta = v-new-col - frame dialog-frame :width
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
            - frame dialog-frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame dialog-frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame dialog-frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame dialog-frame :height-chars
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
      v-diasize-current-frame-width  = frame dialog-frame :width
      v-diasize-current-frame-height = frame dialog-frame :height
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
    do with frame dialog-frame
    :
      assign
        v-diasize-orig-frame-height = frame dialog-frame :height
        v-diasize-orig-frame-width  = frame dialog-frame :width
        v-diasize-browse-handle     = browse br-parts :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame dialog-frame :first-child
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame dialog-frame:
    if p-filter-name > "" then do:
      assign
        frame dialog-frame:title
          = frame dialog-frame:title + "   ФИЛЬТР: " + p-filter-name.
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-parts :SET-REPOSITIONED-ROW(3, "CONDITIONAL") .
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output p-curr-host-code
  )  .
  assign
  rs-parts = p-r-parts
  rs-one-all = p-one-all
  .
  find first supp_clients where
             supp_clients.obj-type = p-supp-type
         and supp_clients.obj-code = p-supp-code no-lock.
  dispLAY
  rs-parts
  rs-one-all
  with frame dialog-frame.
  ENABLE
  b-exit
  b-gds
  b-alt
  b-pl
  b-help
  b-print
  sh-code
  br-parts
  b-in
  b-doc
  b-sch
  rs-parts
  ed-notes
  rs-one-all
  WITH FRAME dialog-frame.
  v-doc-rec = ?.
  run OpenBr in this-procedure ( input yes, input no, input no).
  WAIT-FOR GO OF FRAME dialog-frame focus br-parts.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME dialog-frame.
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Поставщик-партии-остатки" + chr(32).
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
CASE rs-one-all :
  WHEN "all"        THEN DO:
    disable sh-code with frame dialog-frame.
    case rs-parts :
      when "input" then do:
        ASSIGN
        filter-point = filter-point0 + rs-one-all + rs-parts
        filter-label = substitute("&1 Приходы по фирме", filter-label0)
        .
        if p-open-query then do:
        frame dialog-frame:title = substitute("Поставщик: &1&2 &3 ПРИХОДЫ по фирме &4"
                                              , supp_clients.obj-type
                                              , supp_clients.obj-code
                                              , string(supp_clients.obj-name, "X(45)")
                                              , p-curr-host-code).
        end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-15  as logical   no-undo .
define variable  l-filter-open-15    as logical   .
define variable  flt-rec-15       as recid     no-undo .
define variable  filter-name-15      as character no-undo .
define variable  where-phrase-15     as character no-undo .
define variable  sort-phrase-15      as character no-undo .
define variable  where-phrase-rus-15 as character no-undo .
define variable  sort-phrase-rus-15  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
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
                              "FOR EACH s-parts"
      parameter-4-15 =
        (
          if (" s-parts.supp-type = p-supp-type                       and s-parts.supp-code = p-supp-code                       and s-parts.host-code = p-curr-host-code                       and s-parts.status_ = yes                       and s-parts.in-code = s-parts.out-code " + " " + where-phrase-15) <> ""
          then  substitute('s-parts.supp-type = &1&2&1                       and s-parts.supp-code = &3                       and s-parts.host-code = &4                       and s-parts.status_ = yes                       and s-parts.in-code = &1&5&1 ', chr(34), p-supp-type, p-supp-code, p-curr-host-code, s-parts.out-code) + " " + where-phrase-15
          else "true"
        )
      parameter-5-15 = (" " + "" + " " + ", first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code")
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
          (" s-parts.supp-type = p-supp-type                       and s-parts.supp-code = p-supp-code                       and s-parts.host-code = p-curr-host-code                       and s-parts.status_ = yes                       and s-parts.in-code = s-parts.out-code " + " " + where-phrase-15 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-parts:handle
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
    OPEN QUERY br-parts FOR EACH s-parts
      where  s-parts.supp-type = p-supp-type                       and s-parts.supp-code = p-supp-code                       and s-parts.host-code = p-curr-host-code                       and s-parts.status_ = yes                       and s-parts.in-code = s-parts.out-code
    , first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( s-parts )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-parts:handle:get-buffer-handle(1) = (buffer s-parts:handle) then do:
      assign
      parameter-2-15 = (if p-find-next then "true":u else "false":u )
      parameter-4-15 =
        "where ":u +  substitute('s-parts.supp-type = &1&2&1                       and s-parts.supp-code = &3                       and s-parts.host-code = &4                       and s-parts.status_ = yes                       and s-parts.in-code = &1&5&1 ', chr(34), p-supp-type, p-supp-code, p-curr-host-code, s-parts.out-code) + " ":u + where-phrase-15 + " ":u + p-find-condition + " " + ""
      parameter-5-15 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-parts:handle
                          ,input rowid(s-parts)
                          ,input logical(parameter-2-15)
                          ,input no-lock
                          ,input (buffer s-parts:handle)
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
      parameter-3-15 =  "FOR EACH s-parts"
      parameter-4-15 =
        (
          if (" s-parts.supp-type = p-supp-type                       and s-parts.supp-code = p-supp-code                       and s-parts.host-code = p-curr-host-code                       and s-parts.status_ = yes                       and s-parts.in-code = s-parts.out-code " + " " + where-phrase-15) <> ""
          then  substitute('s-parts.supp-type = &1&2&1                       and s-parts.supp-code = &3                       and s-parts.host-code = &4                       and s-parts.status_ = yes                       and s-parts.in-code = &1&5&1 ', chr(34), p-supp-type, p-supp-code, p-curr-host-code, s-parts.out-code) + " " + where-phrase-15
          else "true"
        )
      parameter-5-15 = (" " + "" + " " + ", first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code" + " " + p-find-condition)
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
                          ,input QUERY br-parts:handle
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
  run waitfram-hide in this-procedure .
      end.
      when "all":U then do:
        if p-open-query then do:
        frame dialog-frame:title = substitute("Поставщик: &1&2 &3 ВСЕ ПАРТИИ по фирме &4"
                                                , supp_clients.obj-type
                                                , supp_clients.obj-code
                                                , string(supp_clients.obj-name, "X(45)")
                                                , p-curr-host-code).
        end.
        assign
        filter-point = filter-point0 + rs-one-all + rs-parts
        filter-label = substitute("&1 Партии по фирме", filter-label0).
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-17  as logical   no-undo .
define variable  l-filter-open-17    as logical   .
define variable  flt-rec-17       as recid     no-undo .
define variable  filter-name-17      as character no-undo .
define variable  where-phrase-17     as character no-undo .
define variable  sort-phrase-17      as character no-undo .
define variable  where-phrase-rus-17 as character no-undo .
define variable  sort-phrase-rus-17  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-17
  ,output filter-name-17
  ,output where-phrase-17
  ,output sort-phrase-17
  ,output where-phrase-rus-17
  ,output sort-phrase-rus-17
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-17
      ) no-error .
  assign
    l-filter-open-17 = false
  .
  if flt-rec-17 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-17 as character no-undo .
    define variable  parameter-3-17 as character no-undo .
    define variable  parameter-4-17 as character no-undo .
    define variable  parameter-5-17 as character no-undo .
    define variable  parameter-6-17 as character no-undo .
    define variable  parameter-7-17 as character no-undo .
      assign
      parameter-3-17 =
                              "FOR EACH s-parts"
      parameter-4-17 =
        (
          if (" s-parts.supp-type = p-supp-type                       and s-parts.supp-code = p-supp-code                       and s-parts.host-code = p-curr-host-code                       and s-parts.status_ = no " + " " + where-phrase-17) <> ""
          then  substitute('s-parts.supp-type = &1&2&1                       and s-parts.supp-code = &3                       and s-parts.host-code = &4                       and s-parts.status_ = no ', chr(34), p-supp-type, p-supp-code, p-curr-host-code) + " " + where-phrase-17
          else "true"
        )
      parameter-5-17 = (" " + "" + " " + ", first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code")
      parameter-6-17 = if sort-phrase-17 = ''
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
        " " + sort-phrase-17
        )
      parameter-7-17 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-17 =
          (" s-parts.supp-type = p-supp-type                       and s-parts.supp-code = p-supp-code                       and s-parts.host-code = p-curr-host-code                       and s-parts.status_ = no " + " " + where-phrase-17 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-parts:handle
                          ,input parameter-3-17
                          ,input parameter-4-17
                          ,input parameter-5-17
                          ,input parameter-6-17
                          ,input parameter-7-17
                          )
      .
      assign
        l-filter-open-17 = true
      .
    end.
    if l-filter-open-17 = false then do:
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
  if l-filter-open-17 = false then do:
    OPEN QUERY br-parts FOR EACH s-parts
      where  s-parts.supp-type = p-supp-type                       and s-parts.supp-code = p-supp-code                       and s-parts.host-code = p-curr-host-code                       and s-parts.status_ = no
    , first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( s-parts )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-parts:handle:get-buffer-handle(1) = (buffer s-parts:handle) then do:
      assign
      parameter-2-17 = (if p-find-next then "true":u else "false":u )
      parameter-4-17 =
        "where ":u +  substitute('s-parts.supp-type = &1&2&1                       and s-parts.supp-code = &3                       and s-parts.host-code = &4                       and s-parts.status_ = no ', chr(34), p-supp-type, p-supp-code, p-curr-host-code) + " ":u + where-phrase-17 + " ":u + p-find-condition + " " + ""
      parameter-5-17 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-parts:handle
                          ,input rowid(s-parts)
                          ,input logical(parameter-2-17)
                          ,input no-lock
                          ,input (buffer s-parts:handle)
                          ,input parameter-4-17
                          ,input parameter-5-17
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-17 = (if p-find-next then "true":u else "false":u )
      parameter-3-17 =  "FOR EACH s-parts"
      parameter-4-17 =
        (
          if (" s-parts.supp-type = p-supp-type                       and s-parts.supp-code = p-supp-code                       and s-parts.host-code = p-curr-host-code                       and s-parts.status_ = no " + " " + where-phrase-17) <> ""
          then  substitute('s-parts.supp-type = &1&2&1                       and s-parts.supp-code = &3                       and s-parts.host-code = &4                       and s-parts.status_ = no ', chr(34), p-supp-type, p-supp-code, p-curr-host-code) + " " + where-phrase-17
          else "true"
        )
      parameter-5-17 = (" " + "" + " " + ", first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code" + " " + p-find-condition)
      parameter-6-17 = if sort-phrase-17 = ''
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
        " " + sort-phrase-17
        )
      parameter-7-17 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-parts:handle
                          ,input logical(parameter-2-17)
                          ,input no-lock
                          ,input parameter-3-17
                          ,input parameter-4-17
                          ,input parameter-5-17
                          ,input parameter-6-17
                          ,input parameter-7-17
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
      when "stock" then do:
        if p-open-query then do:
          frame dialog-frame:title = substitute("Поставщик : &1&2 &3 ФАКТ ОСТАТКИ по фирме &4"
                                                , supp_clients.obj-type
                                                , supp_clients.obj-code
                                                , string(supp_clients.obj-name, "X(45)")
                                                , p-curr-host-code ).
        end.
        assign
        filter-point = filter-point0 + rs-one-all + rs-parts
        filter-label = substitute("&1 остатки по фирме", filter-label0).
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-19  as logical   no-undo .
define variable  l-filter-open-19    as logical   .
define variable  flt-rec-19       as recid     no-undo .
define variable  filter-name-19      as character no-undo .
define variable  where-phrase-19     as character no-undo .
define variable  sort-phrase-19      as character no-undo .
define variable  where-phrase-rus-19 as character no-undo .
define variable  sort-phrase-rus-19  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-19
  ,output filter-name-19
  ,output where-phrase-19
  ,output sort-phrase-19
  ,output where-phrase-rus-19
  ,output sort-phrase-rus-19
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-19
      ) no-error .
  assign
    l-filter-open-19 = false
  .
  if flt-rec-19 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-19 as character no-undo .
    define variable  parameter-3-19 as character no-undo .
    define variable  parameter-4-19 as character no-undo .
    define variable  parameter-5-19 as character no-undo .
    define variable  parameter-6-19 as character no-undo .
    define variable  parameter-7-19 as character no-undo .
      assign
      parameter-3-19 =
                              "FOR EACH s-parts"
      parameter-4-19 =
        (
          if (" s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = no                         and s-parts.rsrv-free = yes " + " " + where-phrase-19) <> ""
          then  substitute('s-parts.supp-type = &1&2&1                         and s-parts.supp-code = &3                         and s-parts.host-code = &4                         and s-parts.status_ = no                         and s-parts.rsrv-free = yes ', chr(34), p-supp-type, p-supp-code, p-curr-host-code) + " " + where-phrase-19
          else "true"
        )
      parameter-5-19 = (" " + "" + " " + ", first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code")
      parameter-6-19 = if sort-phrase-19 = ''
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
        " " + sort-phrase-19
        )
      parameter-7-19 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-19 =
          (" s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = no                         and s-parts.rsrv-free = yes " + " " + where-phrase-19 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-parts:handle
                          ,input parameter-3-19
                          ,input parameter-4-19
                          ,input parameter-5-19
                          ,input parameter-6-19
                          ,input parameter-7-19
                          )
      .
      assign
        l-filter-open-19 = true
      .
    end.
    if l-filter-open-19 = false then do:
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
  if l-filter-open-19 = false then do:
    OPEN QUERY br-parts FOR EACH s-parts
      where  s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = no                         and s-parts.rsrv-free = yes
    , first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( s-parts )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-parts:handle:get-buffer-handle(1) = (buffer s-parts:handle) then do:
      assign
      parameter-2-19 = (if p-find-next then "true":u else "false":u )
      parameter-4-19 =
        "where ":u +  substitute('s-parts.supp-type = &1&2&1                         and s-parts.supp-code = &3                         and s-parts.host-code = &4                         and s-parts.status_ = no                         and s-parts.rsrv-free = yes ', chr(34), p-supp-type, p-supp-code, p-curr-host-code) + " ":u + where-phrase-19 + " ":u + p-find-condition + " " + ""
      parameter-5-19 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-parts:handle
                          ,input rowid(s-parts)
                          ,input logical(parameter-2-19)
                          ,input no-lock
                          ,input (buffer s-parts:handle)
                          ,input parameter-4-19
                          ,input parameter-5-19
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-19 = (if p-find-next then "true":u else "false":u )
      parameter-3-19 =  "FOR EACH s-parts"
      parameter-4-19 =
        (
          if (" s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = no                         and s-parts.rsrv-free = yes " + " " + where-phrase-19) <> ""
          then  substitute('s-parts.supp-type = &1&2&1                         and s-parts.supp-code = &3                         and s-parts.host-code = &4                         and s-parts.status_ = no                         and s-parts.rsrv-free = yes ', chr(34), p-supp-type, p-supp-code, p-curr-host-code) + " " + where-phrase-19
          else "true"
        )
      parameter-5-19 = (" " + "" + " " + ", first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code" + " " + p-find-condition)
      parameter-6-19 = if sort-phrase-19 = ''
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
        " " + sort-phrase-19
        )
      parameter-7-19 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-parts:handle
                          ,input logical(parameter-2-19)
                          ,input no-lock
                          ,input parameter-3-19
                          ,input parameter-4-19
                          ,input parameter-5-19
                          ,input parameter-6-19
                          ,input parameter-7-19
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
      when "free" then do:
        if p-open-query then do:
          assign
          frame dialog-frame:title = substitute("Поставщик : &1&2 &3 СВОБОДНО по фирме &4"
                                                , supp_clients.obj-type
                                                , supp_clients.obj-code
                                                , string(supp_clients.obj-name, "X(45)")
                                                , p-curr-host-code ).
        end.
        assign
        filter-point = filter-point0 + rs-one-all + rs-parts
        filter-label = substitute("&1 свободно по фирме", filter-label0).
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-21  as logical   no-undo .
define variable  l-filter-open-21    as logical   .
define variable  flt-rec-21       as recid     no-undo .
define variable  filter-name-21      as character no-undo .
define variable  where-phrase-21     as character no-undo .
define variable  sort-phrase-21      as character no-undo .
define variable  where-phrase-rus-21 as character no-undo .
define variable  sort-phrase-rus-21  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-21
  ,output filter-name-21
  ,output where-phrase-21
  ,output sort-phrase-21
  ,output where-phrase-rus-21
  ,output sort-phrase-rus-21
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-21
      ) no-error .
  assign
    l-filter-open-21 = false
  .
  if flt-rec-21 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-21 as character no-undo .
    define variable  parameter-3-21 as character no-undo .
    define variable  parameter-4-21 as character no-undo .
    define variable  parameter-5-21 as character no-undo .
    define variable  parameter-6-21 as character no-undo .
    define variable  parameter-7-21 as character no-undo .
      assign
      parameter-3-21 =
                              "FOR EACH s-parts"
      parameter-4-21 =
        (
          if (" s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = no                         and s-parts.out-code = 'free-zone':U " + " " + where-phrase-21) <> ""
          then  substitute('s-parts.supp-type = &1&2&1                         and s-parts.supp-code = &3                         and s-parts.host-code = &4                         and s-parts.status_ = no                         and s-parts.out-code = &1&5&1 ', chr(34), p-supp-type, p-supp-code, p-curr-host-code, 'free-zone':U) + " " + where-phrase-21
          else "true"
        )
      parameter-5-21 = (" " + "" + " " + ", first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code")
      parameter-6-21 = if sort-phrase-21 = ''
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
        " " + sort-phrase-21
        )
      parameter-7-21 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-21 =
          (" s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = no                         and s-parts.out-code = 'free-zone':U " + " " + where-phrase-21 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-parts:handle
                          ,input parameter-3-21
                          ,input parameter-4-21
                          ,input parameter-5-21
                          ,input parameter-6-21
                          ,input parameter-7-21
                          )
      .
      assign
        l-filter-open-21 = true
      .
    end.
    if l-filter-open-21 = false then do:
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
  if l-filter-open-21 = false then do:
    OPEN QUERY br-parts FOR EACH s-parts
      where  s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = no                         and s-parts.out-code = 'free-zone':U
    , first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( s-parts )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-parts:handle:get-buffer-handle(1) = (buffer s-parts:handle) then do:
      assign
      parameter-2-21 = (if p-find-next then "true":u else "false":u )
      parameter-4-21 =
        "where ":u +  substitute('s-parts.supp-type = &1&2&1                         and s-parts.supp-code = &3                         and s-parts.host-code = &4                         and s-parts.status_ = no                         and s-parts.out-code = &1&5&1 ', chr(34), p-supp-type, p-supp-code, p-curr-host-code, 'free-zone':U) + " ":u + where-phrase-21 + " ":u + p-find-condition + " " + ""
      parameter-5-21 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-parts:handle
                          ,input rowid(s-parts)
                          ,input logical(parameter-2-21)
                          ,input no-lock
                          ,input (buffer s-parts:handle)
                          ,input parameter-4-21
                          ,input parameter-5-21
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-21 = (if p-find-next then "true":u else "false":u )
      parameter-3-21 =  "FOR EACH s-parts"
      parameter-4-21 =
        (
          if (" s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = no                         and s-parts.out-code = 'free-zone':U " + " " + where-phrase-21) <> ""
          then  substitute('s-parts.supp-type = &1&2&1                         and s-parts.supp-code = &3                         and s-parts.host-code = &4                         and s-parts.status_ = no                         and s-parts.out-code = &1&5&1 ', chr(34), p-supp-type, p-supp-code, p-curr-host-code, 'free-zone':U) + " " + where-phrase-21
          else "true"
        )
      parameter-5-21 = (" " + "" + " " + ", first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code" + " " + p-find-condition)
      parameter-6-21 = if sort-phrase-21 = ''
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
        " " + sort-phrase-21
        )
      parameter-7-21 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-parts:handle
                          ,input logical(parameter-2-21)
                          ,input no-lock
                          ,input parameter-3-21
                          ,input parameter-4-21
                          ,input parameter-5-21
                          ,input parameter-6-21
                          ,input parameter-7-21
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
    END CASE.
  end.
  when "current" then do:
    enable sh-code with frame dialog-frame.
    case rs-parts :
       when "input" then do:
         if p-open-query then do:
          frame dialog-frame:title = substitute("Поставщик: &1&2 &3 Объект: &4&5 Приходы"
                                                , supp_clients.obj-type
                                                , supp_clients.obj-code
                                                , string(supp_clients.obj-name, "X(45)")
                                                , p-curr-obj-type
                                                , p-curr-obj-code).
        end.
        assign
        filter-point = filter-point0 + rs-one-all + rs-parts
        filter-label = substitute("&1 Приходы", filter-label0).
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-23  as logical   no-undo .
define variable  l-filter-open-23    as logical   .
define variable  flt-rec-23       as recid     no-undo .
define variable  filter-name-23      as character no-undo .
define variable  where-phrase-23     as character no-undo .
define variable  sort-phrase-23      as character no-undo .
define variable  where-phrase-rus-23 as character no-undo .
define variable  sort-phrase-rus-23  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-23
  ,output filter-name-23
  ,output where-phrase-23
  ,output sort-phrase-23
  ,output where-phrase-rus-23
  ,output sort-phrase-rus-23
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-23
      ) no-error .
  assign
    l-filter-open-23 = false
  .
  if flt-rec-23 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-23 as character no-undo .
    define variable  parameter-3-23 as character no-undo .
    define variable  parameter-4-23 as character no-undo .
    define variable  parameter-5-23 as character no-undo .
    define variable  parameter-6-23 as character no-undo .
    define variable  parameter-7-23 as character no-undo .
      assign
      parameter-3-23 =
                              "FOR EACH s-parts"
      parameter-4-23 =
        (
          if (" s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = yes                         and s-parts.in-code = s-parts.out-code                         and s-parts.obj-type = p-curr-obj-type                         and s-parts.obj-code = p-curr-obj-code " + " " + where-phrase-23) <> ""
          then  substitute('s-parts.supp-type = &1&2&1                         and s-parts.supp-code = &3                         and s-parts.host-code = &4                         and s-parts.status_ = yes                         and s-parts.in-code = &1&5&1                         and s-parts.obj-type = &1&6&1                         and s-parts.obj-code = &7 ', chr(34), p-supp-type, p-supp-code, p-curr-host-code, s-parts.out-code, p-curr-obj-type, p-curr-obj-code) + " " + where-phrase-23
          else "true"
        )
      parameter-5-23 = (" " + "" + " " + ", first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code")
      parameter-6-23 = if sort-phrase-23 = ''
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
        " " + sort-phrase-23
        )
      parameter-7-23 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-23 =
          (" s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = yes                         and s-parts.in-code = s-parts.out-code                         and s-parts.obj-type = p-curr-obj-type                         and s-parts.obj-code = p-curr-obj-code " + " " + where-phrase-23 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-parts:handle
                          ,input parameter-3-23
                          ,input parameter-4-23
                          ,input parameter-5-23
                          ,input parameter-6-23
                          ,input parameter-7-23
                          )
      .
      assign
        l-filter-open-23 = true
      .
    end.
    if l-filter-open-23 = false then do:
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
  if l-filter-open-23 = false then do:
    OPEN QUERY br-parts FOR EACH s-parts
      where  s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = yes                         and s-parts.in-code = s-parts.out-code                         and s-parts.obj-type = p-curr-obj-type                         and s-parts.obj-code = p-curr-obj-code
    , first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( s-parts )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-parts:handle:get-buffer-handle(1) = (buffer s-parts:handle) then do:
      assign
      parameter-2-23 = (if p-find-next then "true":u else "false":u )
      parameter-4-23 =
        "where ":u +  substitute('s-parts.supp-type = &1&2&1                         and s-parts.supp-code = &3                         and s-parts.host-code = &4                         and s-parts.status_ = yes                         and s-parts.in-code = &1&5&1                         and s-parts.obj-type = &1&6&1                         and s-parts.obj-code = &7 ', chr(34), p-supp-type, p-supp-code, p-curr-host-code, s-parts.out-code, p-curr-obj-type, p-curr-obj-code) + " ":u + where-phrase-23 + " ":u + p-find-condition + " " + ""
      parameter-5-23 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-parts:handle
                          ,input rowid(s-parts)
                          ,input logical(parameter-2-23)
                          ,input no-lock
                          ,input (buffer s-parts:handle)
                          ,input parameter-4-23
                          ,input parameter-5-23
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-23 = (if p-find-next then "true":u else "false":u )
      parameter-3-23 =  "FOR EACH s-parts"
      parameter-4-23 =
        (
          if (" s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = yes                         and s-parts.in-code = s-parts.out-code                         and s-parts.obj-type = p-curr-obj-type                         and s-parts.obj-code = p-curr-obj-code " + " " + where-phrase-23) <> ""
          then  substitute('s-parts.supp-type = &1&2&1                         and s-parts.supp-code = &3                         and s-parts.host-code = &4                         and s-parts.status_ = yes                         and s-parts.in-code = &1&5&1                         and s-parts.obj-type = &1&6&1                         and s-parts.obj-code = &7 ', chr(34), p-supp-type, p-supp-code, p-curr-host-code, s-parts.out-code, p-curr-obj-type, p-curr-obj-code) + " " + where-phrase-23
          else "true"
        )
      parameter-5-23 = (" " + "" + " " + ", first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code" + " " + p-find-condition)
      parameter-6-23 = if sort-phrase-23 = ''
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
        " " + sort-phrase-23
        )
      parameter-7-23 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-parts:handle
                          ,input logical(parameter-2-23)
                          ,input no-lock
                          ,input parameter-3-23
                          ,input parameter-4-23
                          ,input parameter-5-23
                          ,input parameter-6-23
                          ,input parameter-7-23
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
       when  "all":U then do:
         if p-open-query then do:
          frame dialog-frame:title = substitute("Поставщик : &1&2 &3 Объект &4&5 ВСЕ ПАРТИИ"
                                                ,supp_clients.obj-type
                                                ,supp_clients.obj-code
                                                ,string(supp_clients.obj-name, "X(45)")
                                                ,p-curr-obj-type
                                                ,p-curr-obj-code).
        end.
        assign
        filter-point = filter-point0 + rs-one-all + rs-parts
        .
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
                              "FOR EACH s-parts"
      parameter-4-25 =
        (
          if (" s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = no                         and s-parts.obj-type = p-curr-obj-type                         and s-parts.obj-code = p-curr-obj-code " + " " + where-phrase-25) <> ""
          then  substitute('s-parts.supp-type = &1&2&1                         and s-parts.supp-code = &3                         and s-parts.host-code = &4                         and s-parts.status_ = no                         and s-parts.obj-type = &1&5&1                         and s-parts.obj-code = &6 ', chr(34), p-supp-type, p-supp-code, p-curr-host-code, p-curr-obj-type, p-curr-obj-code) + " " + where-phrase-25
          else "true"
        )
      parameter-5-25 = (" " + "" + " " + ", first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code")
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
          (" s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = no                         and s-parts.obj-type = p-curr-obj-type                         and s-parts.obj-code = p-curr-obj-code " + " " + where-phrase-25 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-parts:handle
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
    OPEN QUERY br-parts FOR EACH s-parts
      where  s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = no                         and s-parts.obj-type = p-curr-obj-type                         and s-parts.obj-code = p-curr-obj-code
    , first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( s-parts )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-parts:handle:get-buffer-handle(1) = (buffer s-parts:handle) then do:
      assign
      parameter-2-25 = (if p-find-next then "true":u else "false":u )
      parameter-4-25 =
        "where ":u +  substitute('s-parts.supp-type = &1&2&1                         and s-parts.supp-code = &3                         and s-parts.host-code = &4                         and s-parts.status_ = no                         and s-parts.obj-type = &1&5&1                         and s-parts.obj-code = &6 ', chr(34), p-supp-type, p-supp-code, p-curr-host-code, p-curr-obj-type, p-curr-obj-code) + " ":u + where-phrase-25 + " ":u + p-find-condition + " " + ""
      parameter-5-25 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-parts:handle
                          ,input rowid(s-parts)
                          ,input logical(parameter-2-25)
                          ,input no-lock
                          ,input (buffer s-parts:handle)
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
      parameter-3-25 =  "FOR EACH s-parts"
      parameter-4-25 =
        (
          if (" s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = no                         and s-parts.obj-type = p-curr-obj-type                         and s-parts.obj-code = p-curr-obj-code " + " " + where-phrase-25) <> ""
          then  substitute('s-parts.supp-type = &1&2&1                         and s-parts.supp-code = &3                         and s-parts.host-code = &4                         and s-parts.status_ = no                         and s-parts.obj-type = &1&5&1                         and s-parts.obj-code = &6 ', chr(34), p-supp-type, p-supp-code, p-curr-host-code, p-curr-obj-type, p-curr-obj-code) + " " + where-phrase-25
          else "true"
        )
      parameter-5-25 = (" " + "" + " " + ", first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code" + " " + p-find-condition)
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
                          ,input QUERY br-parts:handle
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
       end.
       when "stock" then do:
         if p-open-query then do:
          frame dialog-frame:title = substitute("Поставщик : &1&2 &3 Объект &4&5 ФАКТ ОСТАТКИ"
                                                ,supp_clients.obj-type
                                                ,supp_clients.obj-code
                                                ,string(supp_clients.obj-name, "X(45)")
                                                ,p-curr-obj-type
                                                ,p-curr-obj-code).
         end.
         assign
         filter-point = filter-point0 + rs-one-all + rs-parts
         filter-label = substitute("&1 остатки по объекту", filter-label0).
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-27  as logical   no-undo .
define variable  l-filter-open-27    as logical   .
define variable  flt-rec-27       as recid     no-undo .
define variable  filter-name-27      as character no-undo .
define variable  where-phrase-27     as character no-undo .
define variable  sort-phrase-27      as character no-undo .
define variable  where-phrase-rus-27 as character no-undo .
define variable  sort-phrase-rus-27  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-27
  ,output filter-name-27
  ,output where-phrase-27
  ,output sort-phrase-27
  ,output where-phrase-rus-27
  ,output sort-phrase-rus-27
  ).
if p-open-query then do:
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
                              "FOR EACH s-parts"
      parameter-4-27 =
        (
          if (" s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = no                         and s-parts.obj-type = p-curr-obj-type                         and s-parts.obj-code = p-curr-obj-code                         and s-parts.rsrv-free = yes " + " " + where-phrase-27) <> ""
          then  substitute('s-parts.supp-type = &1&2&1                         and s-parts.supp-code = &3                         and s-parts.host-code = &4                         and s-parts.status_ = no                         and s-parts.obj-type = &1&5&1                         and s-parts.obj-code = &6                         and s-parts.rsrv-free = yes ', chr(34), p-supp-type, p-supp-code, p-curr-host-code, p-curr-obj-type, p-curr-obj-code) + " " + where-phrase-27
          else "true"
        )
      parameter-5-27 = (" " + "" + " " + ", first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code")
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
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-27 =
          (" s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = no                         and s-parts.obj-type = p-curr-obj-type                         and s-parts.obj-code = p-curr-obj-code                         and s-parts.rsrv-free = yes " + " " + where-phrase-27 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-parts:handle
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
    OPEN QUERY br-parts FOR EACH s-parts
      where  s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = no                         and s-parts.obj-type = p-curr-obj-type                         and s-parts.obj-code = p-curr-obj-code                         and s-parts.rsrv-free = yes
    , first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( s-parts )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-parts:handle:get-buffer-handle(1) = (buffer s-parts:handle) then do:
      assign
      parameter-2-27 = (if p-find-next then "true":u else "false":u )
      parameter-4-27 =
        "where ":u +  substitute('s-parts.supp-type = &1&2&1                         and s-parts.supp-code = &3                         and s-parts.host-code = &4                         and s-parts.status_ = no                         and s-parts.obj-type = &1&5&1                         and s-parts.obj-code = &6                         and s-parts.rsrv-free = yes ', chr(34), p-supp-type, p-supp-code, p-curr-host-code, p-curr-obj-type, p-curr-obj-code) + " ":u + where-phrase-27 + " ":u + p-find-condition + " " + ""
      parameter-5-27 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-parts:handle
                          ,input rowid(s-parts)
                          ,input logical(parameter-2-27)
                          ,input no-lock
                          ,input (buffer s-parts:handle)
                          ,input parameter-4-27
                          ,input parameter-5-27
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-27 = (if p-find-next then "true":u else "false":u )
      parameter-3-27 =  "FOR EACH s-parts"
      parameter-4-27 =
        (
          if (" s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = no                         and s-parts.obj-type = p-curr-obj-type                         and s-parts.obj-code = p-curr-obj-code                         and s-parts.rsrv-free = yes " + " " + where-phrase-27) <> ""
          then  substitute('s-parts.supp-type = &1&2&1                         and s-parts.supp-code = &3                         and s-parts.host-code = &4                         and s-parts.status_ = no                         and s-parts.obj-type = &1&5&1                         and s-parts.obj-code = &6                         and s-parts.rsrv-free = yes ', chr(34), p-supp-type, p-supp-code, p-curr-host-code, p-curr-obj-type, p-curr-obj-code) + " " + where-phrase-27
          else "true"
        )
      parameter-5-27 = (" " + "" + " " + ", first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code" + " " + p-find-condition)
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
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-parts:handle
                          ,input logical(parameter-2-27)
                          ,input no-lock
                          ,input parameter-3-27
                          ,input parameter-4-27
                          ,input parameter-5-27
                          ,input parameter-6-27
                          ,input parameter-7-27
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
      when "free" then do:
        if p-open-query then do:
          frame dialog-frame:title = substitute("Поставщик : &1&2 &3 Объект &4&5 СВОБОДНО"
                                                , supp_clients.obj-type
                                                , supp_clients.obj-code
                                                , string(supp_clients.obj-name, "X(45)")
                                                , p-curr-obj-type
                                                , p-curr-obj-code).
         end.
         assign
         filter-point = filter-point0 + rs-one-all + rs-parts
         filter-label = substitute("&1 свободно по объекту", filter-label0).
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-29  as logical   no-undo .
define variable  l-filter-open-29    as logical   .
define variable  flt-rec-29       as recid     no-undo .
define variable  filter-name-29      as character no-undo .
define variable  where-phrase-29     as character no-undo .
define variable  sort-phrase-29      as character no-undo .
define variable  where-phrase-rus-29 as character no-undo .
define variable  sort-phrase-rus-29  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-29
  ,output filter-name-29
  ,output where-phrase-29
  ,output sort-phrase-29
  ,output where-phrase-rus-29
  ,output sort-phrase-rus-29
  ).
if p-open-query then do:
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
                              "FOR EACH s-parts"
      parameter-4-29 =
        (
          if (" s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = no                         and s-parts.obj-type = p-curr-obj-type                         and s-parts.obj-code = p-curr-obj-code                         and s-parts.out-code = 'free-zone':U " + " " + where-phrase-29) <> ""
          then  substitute('s-parts.supp-type = &1&2&1                         and s-parts.supp-code = &3                         and s-parts.host-code = &4                         and s-parts.status_ = no                         and s-parts.obj-type = &1&5&1                         and s-parts.obj-code = &6                         and s-parts.out-code = &1&7&1 ', chr(34), p-supp-type, p-supp-code, p-curr-host-code, p-curr-obj-type, p-curr-obj-code, 'free-zone':U) + " " + where-phrase-29
          else "true"
        )
      parameter-5-29 = (" " + "" + " " + ", first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code")
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
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-29 =
          (" s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = no                         and s-parts.obj-type = p-curr-obj-type                         and s-parts.obj-code = p-curr-obj-code                         and s-parts.out-code = 'free-zone':U " + " " + where-phrase-29 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-parts:handle
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
    OPEN QUERY br-parts FOR EACH s-parts
      where  s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = no                         and s-parts.obj-type = p-curr-obj-type                         and s-parts.obj-code = p-curr-obj-code                         and s-parts.out-code = 'free-zone':U
    , first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( s-parts )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-parts:handle:get-buffer-handle(1) = (buffer s-parts:handle) then do:
      assign
      parameter-2-29 = (if p-find-next then "true":u else "false":u )
      parameter-4-29 =
        "where ":u +  substitute('s-parts.supp-type = &1&2&1                         and s-parts.supp-code = &3                         and s-parts.host-code = &4                         and s-parts.status_ = no                         and s-parts.obj-type = &1&5&1                         and s-parts.obj-code = &6                         and s-parts.out-code = &1&7&1 ', chr(34), p-supp-type, p-supp-code, p-curr-host-code, p-curr-obj-type, p-curr-obj-code, 'free-zone':U) + " ":u + where-phrase-29 + " ":u + p-find-condition + " " + ""
      parameter-5-29 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-parts:handle
                          ,input rowid(s-parts)
                          ,input logical(parameter-2-29)
                          ,input no-lock
                          ,input (buffer s-parts:handle)
                          ,input parameter-4-29
                          ,input parameter-5-29
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-29 = (if p-find-next then "true":u else "false":u )
      parameter-3-29 =  "FOR EACH s-parts"
      parameter-4-29 =
        (
          if (" s-parts.supp-type = p-supp-type                         and s-parts.supp-code = p-supp-code                         and s-parts.host-code = p-curr-host-code                         and s-parts.status_ = no                         and s-parts.obj-type = p-curr-obj-type                         and s-parts.obj-code = p-curr-obj-code                         and s-parts.out-code = 'free-zone':U " + " " + where-phrase-29) <> ""
          then  substitute('s-parts.supp-type = &1&2&1                         and s-parts.supp-code = &3                         and s-parts.host-code = &4                         and s-parts.status_ = no                         and s-parts.obj-type = &1&5&1                         and s-parts.obj-code = &6                         and s-parts.out-code = &1&7&1 ', chr(34), p-supp-type, p-supp-code, p-curr-host-code, p-curr-obj-type, p-curr-obj-code, 'free-zone':U) + " " + where-phrase-29
          else "true"
        )
      parameter-5-29 = (" " + "" + " " + ", first s-goods no-lock where s-goods.artic = s-parts.artic                                  and s-goods.prod-type = s-parts.prod-type                                  and s-goods.prod-code = s-parts.prod-code" + " " + p-find-condition)
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
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-parts:handle
                          ,input logical(parameter-2-29)
                          ,input no-lock
                          ,input parameter-3-29
                          ,input parameter-4-29
                          ,input parameter-5-29
                          ,input parameter-6-29
                          ,input parameter-7-29
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
    END CASE.
  end.
END CASE.
if v-doc-rec <> ? then
REPOSITION br-parts to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-parts:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
if error-status:error
or (v-doc-rec = ? and v-fltopend-rowid[1] = ?)
then do:
  reposition br-parts to row 1 no-error.
end.
run waitfram-hide in this-procedure .
APPLY "ENTRY" TO br-parts.
APPLY "VALUE-CHANGED" TO br-parts in frame dialog-frame.
END PROCEDURE.
procedure proc-find-sh-code :
define input parameter p-next as logical no-undo.
define input parameter p-sh-code as character no-undo .
define variable v-search-code as char no-undo.
define variable varresult   as character                no-undo.
define variable vartype-bc  as character                no-undo.
define variable varweight   as decimal                  no-undo.
define buffer search-goods for ub.goods.
do
on error undo, return error
:
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type30 as character no-undo.
varscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref
  ,output varscales-pref-type30
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type30 as character no-undo.
varpgscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref
  ,output varpgscales-pref-type30
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
  assign
  v-search-code = string(p-sh-code).
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  v-search-code
,input  ?
,input  p-curr-obj-type
,input  p-curr-obj-code
,input  yes
,input  no
,input  varscales-pref
,input  varpgscales-pref
,output varresult
,output vartype-bc
,output varweight
,buffer ub.bar-code
,buffer ub.prod-bc
,buffer ub.place
) no-error.
  if available bar-code then do:
    find search-goods no-lock where
        search-goods.gds-code = bar-code.gds-code no-error.
  end.
  else do:
    message
    "Бар-код не найден!"
    view-as alert-box.
    apply "entry" to sh-code in frame dialog-frame .
    undo, return error .
  end.
  run OpenBr in this-procedure
      (input false
      ,input p-next
      ,input substitute("and s-parts.artic = &1 and s-parts.prod-type = &2 and s-parts.prod-code = &3 " +
                        "and s-parts.in-code = &4 and s-parts.part-code = &5 "
        , search-goods.artic
        , search-goods.prod-type
        , search-goods.prod-code
        , bar-code.in-code
        , bar-code.part-code
        )
      ).
  apply "entry":u to sh-code in frame dialog-frame .
end.
end procedure.
procedure proc-b-sch :
  do
  on error undo, return error
  :
    assign
    tbl = 'parts'
    join-tbl = 's-parts'
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
    .
    run fltfield-add in this-procedure('artic', 'Артикул', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('prod-type*prod-code', 'Производитель', 'cli',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('price-base', 'Цена-бв', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('price-rubl', 'Цена-', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('in-code', 'Номер ПН', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('out-code', 'Статус', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('obj-type*obj-code', 'Объект', 'cli',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('part-code', 'Номер-партии', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('status_', 'Закр', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('qnty', 'Кол.док.', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('fact-qnty', 'Факт.кол.', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('doc-type', 'Тип-док', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('fact-date', 'Дата-факт', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('pay-code', 'Код-оплаты', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('pl-code', 'Код-места', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    Filter-Block:
    DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
        ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
        ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
      run gbl/filter.w ( INPUT parparentproc
                       , INPUT (filter-point + chr(4) + filter-label)
                       , INPUT tbl
                       , INPUT join-tbl
                       , INPUT fld
                       , INPUT lab
                       , INPUT spr
                       , INPUT dim ).
      RUN OpenBr in this-procedure ( input yes, input no, input '':U).
    END.
  end.
end procedure.
