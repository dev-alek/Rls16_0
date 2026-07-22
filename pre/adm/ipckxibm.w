DEFINE BUFFER X_db FOR ub.db.
DEFINE BUFFER X_ext-file FOR ub.ext-file.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input-output parameter p-rid-list AS CHARACTER NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Работа с файлами для IBM-XML, сохраненными в БД".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table tt-ext-file-par no-undo like ub.ext-file-par.
procedure ext-file-par-clear-temp :
  define buffer buf_tt-ext-file-par for tt-ext-file-par .
  do
  on error undo, return error return-value
  :
    for each buf_tt-ext-file-par
    on error undo, return error
    :
      delete buf_tt-ext-file-par .
    end.
  end.
end procedure.
procedure ext-file-par-write-temp :
  define input  parameter p-db-num      as integer no-undo .
  define input  parameter p-from-db-num      as integer no-undo .
  define input  parameter p-file-num      as integer no-undo .
  define input  parameter p-param-num      as integer no-undo .
  define input  parameter p-value-type as character no-undo .
  define input  parameter p-value-name as character no-undo .
  define input  parameter p-value-char as character no-undo .
  define input  parameter p-value-date as date      no-undo .
  define input  parameter p-value-integer as integer      no-undo .
  define input  parameter p-value-decimal as decimal      no-undo .
  define input  parameter p-value-logical as logical      no-undo .
  define buffer buf_tt-ext-file-par for tt-ext-file-par .
  do
  on error undo, return error return-value
  :
    find first buf_tt-ext-file-par
      where buf_tt-ext-file-par.db-num        = p-db-num
        and buf_tt-ext-file-par.file-num      = p-file-num
        and buf_tt-ext-file-par.from-db-num   = p-from-db-num
        and buf_tt-ext-file-par.param-type    = p-value-type
        and buf_tt-ext-file-par.param-name    = p-value-name
      no-error .
    if not available buf_tt-ext-file-par then do:
      create buf_tt-ext-file-par .
      assign
        buf_tt-ext-file-par.db-num         = p-db-num
        buf_tt-ext-file-par.from-db-num    = p-from-db-num
        buf_tt-ext-file-par.file-num       = p-file-num
        buf_tt-ext-file-par.param-num      = p-param-num
        buf_tt-ext-file-par.param-type     = p-value-type
        buf_tt-ext-file-par.user-db-num    = p-db-num
              .
    end.
    CASE p-value-type:
      when 'C':U
      or when 'uniq-key-rec':U
      then do:
        assign
        buf_tt-ext-file-par.param-name = p-value-name
        buf_tt-ext-file-par.param-value = p-value-char
        .
      end.
      when 'T':U then do:
        assign
        buf_tt-ext-file-par.param-date-name = p-value-name
        buf_tt-ext-file-par.param-date-value = p-value-date
        .
      end.
      when 'I':U then do:
        assign
        buf_tt-ext-file-par.param-int-name = p-value-name
        buf_tt-ext-file-par.param-int-value = p-value-integer
        .
      end.
      when 'L':U then do:
        assign
        buf_tt-ext-file-par.param-log-name = p-value-name
        buf_tt-ext-file-par.param-log-value = p-value-logical
        .
      end.
      when 'D':U then do:
        assign
        buf_tt-ext-file-par.param-decimal-name = p-value-name
        buf_tt-ext-file-par.param-decimal-value = p-value-decimal
        .
      end.
    END CASE.
  end.
end procedure.
procedure ext-file-par-write-and-send :
  define input  parameter p-db-num      as integer no-undo .
  define input  parameter p-from-db-num      as integer no-undo .
  define input  parameter p-file-num      as integer no-undo .
  define input  parameter p-param-num      as integer no-undo .
  define input  parameter p-value-type as character no-undo .
  define input  parameter p-value-name as character no-undo .
  define input  parameter p-value-char as character no-undo .
  define input  parameter p-value-date as date      no-undo .
  define input  parameter p-value-integer as integer      no-undo .
  define input  parameter p-value-decimal as decimal      no-undo .
  define input  parameter p-value-logical as logical      no-undo .
  define input  parameter p-send        as logical no-undo .
  define input  parameter p-list-db-num as character no-undo .
  define buffer buf_ext-file-par for ub.ext-file-par .
  do
  on error undo, return error return-value
  :
    find first buf_ext-file-par
      where buf_ext-file-par.db-num         = p-db-num
        and buf_ext-file-par.from-db-num    = p-from-db-num
        and buf_ext-file-par.file-num       = p-file-num
        and buf_ext-file-par.param-num      = p-param-num
      no-error .
    if not available buf_ext-file-par then do:
      create buf_ext-file-par .
      assign
        buf_ext-file-par.db-num    = p-db-num
        buf_ext-file-par.from-db-num    = p-from-db-num
        buf_ext-file-par.file-num    = p-file-num
        buf_ext-file-par.param-num    = p-param-num
        buf_ext-file-par.param-type   = p-value-type
        buf_ext-file-par.user-db-num    = p-db-num
      .
    end.
    CASE p-value-type:
      when 'C':U
      or when ''
      or when 'uniq-key-rec':U
      then do:
        assign
        buf_ext-file-par.param-name = p-value-name
        buf_ext-file-par.param-value = p-value-char
        .
        if p-value-type = ''
        and p-param-num = 0 then do:
          buf_ext-file-par.param-log-value = p-value-logical.
        end.
      end.
      when 'T':U then do:
        assign
        buf_ext-file-par.param-date-name = p-value-name
        buf_ext-file-par.param-date-value = p-value-date
        .
      end.
      when 'I':U then do:
        assign
        buf_ext-file-par.param-int-name = p-value-name
        buf_ext-file-par.param-int-value = p-value-integer
        .
      end.
      when 'D':U then do:
        assign
        buf_ext-file-par.param-decimal-name = p-value-name
        buf_ext-file-par.param-decimal-value = p-value-decimal
        .
      end.
      when 'L':U then do:
        assign
        buf_ext-file-par.param-log-name = p-value-name
        buf_ext-file-par.param-log-value = p-value-logical
        .
      end.
    END CASE.
    if p-send then do:
      run nws/cr-route.p (
                      input 'send-tbl':U
                    , input 'ext-file-par':U
                    , input buffer buf_ext-file-par:handle
                    , input p-list-db-num) no-error.
    end.
  end.
end procedure.
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
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info10 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info10, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info10, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info10, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info10, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info10 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info10, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info10 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info10, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info10, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info10, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info10, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info10, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info10, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info10 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info10 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info10, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info10, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info10, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info10 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info10 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info10, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info10, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
DEFINE VARIABLE del-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable sort-column-name as character no-undo .
define variable filter-point-name as character no-undo .
define variable filter-point as character no-undo init "ipckxibm" .
define variable filter-point0 as character no-undo init "ipckxibm" .
DEFINE variable p-db-num AS INTEGER NO-UNDO.
DEFINE variable p-file-type AS character NO-UNDO.
define variable p-obj-type as character no-undo .
define variable p-obj-code as integer no-undo .
define variable p-pos-type as character no-undo .
define variable p-cash-num as integer no-undo .
DEFINE VARIABLE v-cd-db-num AS INTEGER NO-UNDO.
DEFINE VARIABLE v-cd-obj-code AS INTEGER NO-UNDO.
DEFINE VARIABLE v-cd-cash-num AS INTEGER NO-UNDO.
DEFINE VARIABLE v-ch-db AS WIDGET-HANDLE NO-UNDO.
FUNCTION get-cd RETURNS INTEGER
  ( INPUT p-db-num AS integer
  , INPUT p-from-db-num AS integer
  , INPUT p-file-num AS INTEGER )  FORWARD.
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-db
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "&БД"
     SIZE 4 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр".
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 4 BY 1.
DEFINE BUTTON b-output-params
     LABEL "&Рез.вып."
     SIZE 10 BY 1.
DEFINE BUTTON b-params
     LABEL "Пар-тры"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-save
     LABEL "&Сохр."
     SIZE 10 BY 1 TOOLTIP "Сохранить на диск".
DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.
DEFINE VARIABLE f-db-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "БД"
      VIEW-AS TEXT
     SIZE 6 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE mark-num AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 10.5 BY .67
     FGCOLOR 10  NO-UNDO.
DEFINE VARIABLE rs-file-type AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "На кассу", "request",
"С кассы", "reply"
     SIZE 21 BY 1 NO-UNDO.
DEFINE QUERY br-ipck FOR
      X_db, X_ext-file SCROLLING.
DEFINE BROWSE br-ipck
  QUERY br-ipck NO-LOCK DISPLAY
      mark-string ( input recid(x_ext-file), input v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
    WIDTH 2
get-cd(X_ext-file.db-num, X_ext-file.from-db-num, X_ext-file.file-num) COLUMN-LABEL 'БД' FORMAT ">>>>9"
v-cd-obj-code COLUMN-LABEL "Маг" FORMAT ">>>>9"
v-cd-cash-num COLUMN-LABEL "Касса" FORMAT ">>>>9"
X_ext-file.file-name-exec COLUMN-LABEL "Файл манифеста" FORMAT "X(255)":U WIDTH 40
X_ext-file.update-sys-date COLUMN-LABEL "Дата устан." FORMAT "99/99/9999":U
X_ext-file.update-sys-time COLUMN-LABEL "Время устан." FORMAT "X(8)":U
usrfulnf(X_ext-file.update-user-name) column-label 'Установил' FORMAT "X(12)":U
X_ext-file.file-num COLUMN-LABEL "№ файла" FORMAT "->>>>>>>>9":U
X_ext-file.db-num column-label 'Для БД' FORMAT "->>>>9":U
X_ext-file.from-db-num COLUMN-LABEL "Из Бд" FORMAT ">>>>>>>>9":U
X_ext-file.file-size COLUMN-LABEL "Размер" FORMAT ">>>>>>>>9":U
X_ext-file.create-sys-time COLUMN-LABEL "Дата файла" FORMAT "X(5)":U
X_ext-file.create-sys-date COLUMN-LABEL "Время файла" FORMAT "99/99/9999":U
ENABLE
X_ext-file.create-sys-time
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16
         TITLE "" FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 17
     B-add AT ROW 1 COL 21
     B-del AT ROW 1 COL 31
     b-params AT ROW 1 COL 41
     b-output-params AT ROW 1 COL 51
     b-save AT ROW 1 COL 61
     b-lkp AT ROW 1 COL 71 WIDGET-ID 2
     b-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     b-db AT ROW 2 COL 25 WIDGET-ID 6
     rs-file-type AT ROW 2 COL 32 NO-LABEL WIDGET-ID 8
     br-ipck AT ROW 3 COL 1
     mark-num AT ROW 2 COL 2 NO-LABEL
     f-db-num AT ROW 2 COL 15 COLON-ALIGNED WIDGET-ID 4
     SPACE(76.24) SKIP(16.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Зарегистрированные пакеты обновлений"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       f-db-num:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
  run proc-b-add in this-procedure  no-error.
  if error-status:error then do:
    return no-apply.
  end.
  APPLY "ENTRY" to br-ipck.
END.
ON CHOOSE OF b-db IN FRAME Dialog-Frame
DO:
 define variable ri as recid no-undo.
 define buffer buf_db for ub.db.
  run adm/dbs.w (
                input parparentproc
               ,input 'ПРОСМОТР':U
               ,output ri) no-error.
  if ri <> ?
  then do:
    find buf_db where recid (buf_db) = ri .
    display
    buf_db.db-num @ f-db-num
    with frame Dialog-Frame.
    p-db-num = buf_db.db-num.
  end.
  else do:
    p-db-num = ?.
    display
    ? @ f-db-num
    with frame Dialog-Frame.
  end.
  RUN manage-rs-file-type IN THIS-PROCEDURE.
  run OpenBr IN THIS-PROCEDURE ( input yes, input no, input no).
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE del-option AS CHARACTER NO-UNDO.
  IF NOT AVAILABLE X_ext-file THEN RETURN NO-APPLY.
  IF LOOKUP('auto':U, X_ext-file.STATUS_) > 0 THEN do:
    del-option = 'auto':U.
  END.
  ELSE do:
    del-option = 'manual':U.
  END.
  run proc-b-del in this-procedure ( input del-option) no-error.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  APPLY "ENTRY" to br-ipck.
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE X_ext-file THEN RETURN NO-APPLY.
  run proc-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
DO:
    define variable loc#log as logical no-undo .
    if available X_ext-file then do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid12 as character no-undo .
define variable v-num-entry12 as integer   no-undo .
assign
  v-str-recid12 = trim( string( recid( X_ext-file ) , "->>>>>>>>>>>9":U ) )
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
      loc#log = br-ipck:refresh() .
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          loc#log = br-ipck:select-next-row ().
          apply "VALUE-CHANGED" to br-ipck in frame Dialog-Frame.
      end.
      if num-entries( v-rid-list ) = 0
      then
          hide mark-num in frame Dialog-Frame.
      else
          DISPLAY
           num-entries( v-rid-list ) @ mark-num with frame Dialog-Frame.
    end.
    apply "entry" to br-ipck in frame Dialog-Frame.
END.
ON CHOOSE OF b-output-params IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE X_ext-file THEN RETURN NO-APPLY.
  if NOT (ENTRY(1, X_ext-file.STATUS_, chr(4))  = 'save-disk-and-run':U
          OR entry(1, X_ext-file.STATUS_, chr(4))  = 'save-db-and-run':U
          OR X_ext-file.file-type begins ('cash-desk':U  + chr(3))
          )
          THEN DO:
      MESSAGE
      substitute("Просмотр результатов выполнения доступен только для файлов, переданных в режиме &1 и &2"
                 , 'save-db-and-run':U
                 , 'save-disk-and-run':U)
      VIEW-AS ALERT-BOX.
      RETURN NO-APPLY.
  END.
  run nws/sndfnwp.w ( INPUT parparentproc
                  ,INPUT 'ПРОСМОТР':U
                  ,INPUT "output"
                  ,INPUT X_ext-file.db-num
                  ,INPUT X_ext-file.from-db-num
                  ,INPUT X_ext-file.file-num
                  ).
END.
ON CHOOSE OF b-params IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE X_ext-file THEN RETURN NO-APPLY.
  IF not (entry(1, X_ext-file.STATUS_, chr(4)) = 'save-disk-and-run':U
  or      entry(1, X_ext-file.STATUS_, chr(4)) <> 'save-db-and-run':U
  or X_ext-file.file-type begins ('cash-desk':U + chr(3) ))
  THEN DO:
     MESSAGE
     substitute("Просмотр параметров доступен только для файлов, переданных в режиме &1 и &2"
                , 'save-db-and-run':U
                , 'save-disk-and-run':U)
     VIEW-AS ALERT-BOX.
     RETURN NO-APPLY.
  END.
  run nws/sndfnwp.w ( INPUT parparentproc
                  ,INPUT 'ПРОСМОТР':U
                  ,INPUT "input"
                  ,INPUT X_ext-file.db-num
                  ,INPUT X_ext-file.from-db-num
                  ,INPUT X_ext-file.file-num).
END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE X_ext-file THEN RETURN NO-APPLY.
  run proc-save-disk IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-sch IN FRAME Dialog-Frame
DO:
  run proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON VALUE-CHANGED OF br-ipck IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE X_ext-file then do:
    DISABLE
    b-output-params
    b-params
    WITH FRAME Dialog-Frame.
  END.
  ELSE DO:
    ENABLE
    b-output-params when rs-file-type = "request"
    b-params
    WITH FRAME Dialog-Frame.
  END.
END.
ON VALUE-CHANGED OF rs-file-type IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-file-type.
  RUN manage-rs-file-type IN THIS-PROCEDURE.
  run OpenBr IN THIS-PROCEDURE ( input yes, input no, input no).
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
        v-diasize-browse-handle     = browse br-ipck :handle
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
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-quit :sensitive then DO: apply "CHOOSE":U to b-quit in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var sort-labelbr-ipck   as character no-undo .
def var sort-clmnbr-ipck    as handle    no-undo .
def var cur-clmnbr-ipck     as handle    no-undo .
def var cur-clmn-locbr-ipck as integer   no-undo .
def var re-querybr-ipck     as logical   initial no no-undo .
on start-search, ctrl-o of br-ipck in frame Dialog-Frame do:
   run sort-brbr-ipck
     (input (if available X_db
             then recid(X_db)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-ipck :
  define input parameter p-recid as recid no-undo .
  if re-querybr-ipck = no then do:
    assign
       cur-clmnbr-ipck = br-ipck:current-column in frame Dialog-Frame
    .
    if sort-clmnbr-ipck <> ? then sort-clmnbr-ipck:column-fgcolor = 0.
    if cur-clmnbr-ipck = sort-clmnbr-ipck then do:
      assign
         sort-labelbr-ipck = ""
         sort-clmnbr-ipck = ?
      .
     end.
     else do:
       assign
         sort-labelbr-ipck = cur-clmnbr-ipck:label
         sort-clmnbr-ipck  = cur-clmnbr-ipck
         sort-clmnbr-ipck:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-ipck = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-ipck:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-ipck then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-ipck = cur-clmn-locbr-ipck + 1
    .
  end.
  case sort-labelbr-ipck:
        when 'Для БД'  then DO:    assign       sort-column-name = "X_ext-file.db-num"     .     run OpenBr in this-procedure ( input yes, input no, input no) .   . END.
        when 'Установил'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1usrfulnf&1, X_ext-file.update-user-name)', chr(34))     .     run OpenBr in this-procedure ( input yes, input no, input no) .   . END.
        when 'Для БД'  then DO:    assign       sort-column-name = "X_ext-file.file-num"     .     run OpenBr in this-procedure ( input yes, input no, input no) .   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure ( input yes, input no, input no).
      if sort-labelbr-ipck <> "" then do:
        assign
          cur-clmnbr-ipck:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-ipck = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-ipck to recid p-recid no-error.
    apply "value-changed" to br-ipck in frame Dialog-Frame.
  end.
  apply "entry" to br-ipck in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-ipck:
if cur-clmnbr-ipck = ? then do:
   run OpenBr in this-procedure ( input yes, input no, input no).
end.
else do:
   assign re-querybr-ipck = yes.
   run sort-brbr-ipck
     (input (if available X_db
             then recid(X_db)
             else ?
            )
     ).
   assign re-querybr-ipck = no.
end.
end.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-ipck :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
   assign v-doc-rec = ?. if available X_ext-file then v-doc-rec = recid(X_ext-file).              run OpenBr in this-procedure (input yes, input no, input no) no-error. reposition br-ipck to recid v-doc-rec no-error.              APPLY 'Entry' TO br-ipck.
    apply "VALUE-CHANGED" to br-ipck.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  ASSIGN
  v-rid-list = p-rid-list.
  if v-cntxt-db-num = 0 then do:
    p-db-num = ?.
  end.
  else do:
    p-db-num = v-cntxt-db-num.
  end.
  run Myenable in this-procedure .
  IF  v-rid-list = '':U THEN
  HIDE mark-num in frame Dialog-Frame .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY rs-file-type mark-num f-db-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark B-add B-del b-params b-output-params b-save b-lkp b-sch
         B-Help b-db rs-file-type br-ipck mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-ipck FOR EACH X_db no-lock,        each X_ext-file NO-LOCK WHERE X_ext-file.file-num < 2147483647      INDEXED-REPOSITION .
END PROCEDURE.
PROCEDURE manage-rs-file-type :
CASE rs-file-type:
    WHEN "request" THEN DO:
      p-file-type = 'cash-desk':U + chr(3).
      assign
      b-params:label in frame Dialog-Frame = "Лог"
      b-output-params:label = "Ответ"
      .
      assign
      v-ch-db:VISIBLE = NO
      v-cd-obj-code:VISIBLE IN BROWSE br-ipck = NO
      v-cd-cash-num:VISIBLE IN BROWSE br-ipck = NO
      .
      enable
      b-output-params
      b-add
      with frame Dialog-Frame .
    END.
    WHEN "reply" THEN DO:
      assign
      v-ch-db:VISIBLE = YES
      v-cd-obj-code:VISIBLE IN BROWSE br-ipck = YES
      v-cd-cash-num:VISIBLE IN BROWSE br-ipck = YES
      .
      p-file-type = 'cash-desk':U + chr(3) + chr(3).
      assign
      b-params:label = "Запрос"
      b-output-params:label = ""
      .
      disable
      b-output-params
      b-add
      with frame Dialog-Frame .
      b-output-params:visible in frame Dialog-Frame = no.
    END.
  END CASE.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-ch0 AS WIDGET-HANDLE NO-UNDO.
ASSIGN
v-ch0 = br-ipck:FIRST-COLUMN IN FRAME Dialog-Frame.
REPEAT WHILE valid-handle(v-ch0):
   IF v-ch0:LABEL = 'БД' THEN DO:
     v-ch-db = v-ch0.
     LEAVE.
   END.
   v-ch0 = v-ch0:NEXT-COLUMN.
END.
ASSIGN
X_ext-file.create-sys-time:READ-ONLY IN BROWSE br-ipck = YES
X_ext-file.file-name-exec:RESIZABLE IN BROWSE br-ipck = YES
.
f-db-num = p-db-num.
display
f-db-num
with frame Dialog-Frame .
ENABLE
b-quit
b-mark
b-add
B-del
b-sch
B-Help
b-save
b-lkp
br-ipck
b-params
b-output-params
rs-file-type
b-db when v-cntxt-db-num = 0
WITH FRAME Dialog-Frame .
ASSIGN
X_ext-file.file-name-exec:LABEL IN BROWSE br-ipck = "Файл"
X_ext-file.FILE-NAME-exec:resizable IN BROWSE br-ipck = YES
.
VIEW FRAME Dialog-Frame .
APPLY "VALUE-CHANGED" TO rs-file-type IN FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE Openbr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
DEFINE VARIABLE l-query-was-opened as logical no-undo .
define variable title00 as character no-undo.
define variable title01 as character no-undo.
assign
title00 = substitute("Файлы и ссылки на файлы для IBM-XML, принадлежащих БД &1", p-db-num).
.
run waitfram-show in this-procedure ( INPUT "Ждите...").
DEFINE VARIABLE sort-column-phrase as character no-undo .
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
  IF p-db-num = ? THEN DO:
      assign
     filter-point-name = substitute("Работа с файлами IBM-XML") .
      ASSIGN
      frame Dialog-Frame:TITLE = SUBSTITUTE("&1", title00).
      CASE p-file-type:
         WHEN 'cash-desk':U + chr(3) THEN DO:
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
                              "FOR EACH X_db NO-LOCK, EACH X_ext-file"
      parameter-4-26 =
        (
          if (" X_ext-file.file-num < 2147483647 and            ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type = p-file-type)              or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type = p-file-type)) " + " " + where-phrase-26) <> ""
          then  substitute('X_ext-file.file-num < 2147483647 and            ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type = &1&2&1)             or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type = &1&2&1))                ',  chr(34), p-file-type)  + " " + where-phrase-26
          else "true"
        )
      parameter-5-26 = (" " + "" + " " + "")
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
          (" X_ext-file.file-num < 2147483647 and            ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type = p-file-type)              or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type = p-file-type)) " + " " + where-phrase-26 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-ipck:handle
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
    output to kkk.txt .
    put unformatted
      "glog = query br-ipck:handle:query-prepare (" skip
      parameter-3-26
      "where"            skip
      parameter-4-26 skip
      parameter-5-26 skip
      parameter-6-26 skip
      parameter-7-26 skip
      ")"                skip
      .
    output close .
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
    OPEN QUERY br-ipck FOR EACH X_db NO-LOCK, EACH  X_ext-file
      where  X_ext-file.file-num < 2147483647 and            ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type = p-file-type)              or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type = p-file-type))
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_db )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-ipck:handle:get-buffer-handle(1) = (buffer X_ext-file:handle) then do:
      assign
      parameter-2-26 = (if p-find-next then "true":u else "false":u )
      parameter-4-26 =
        "where ":u +  substitute('X_ext-file.file-num < 2147483647 and            ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type = &1&2&1)             or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type = &1&2&1))                ',  chr(34), p-file-type)  + " ":u + where-phrase-26 + " ":u + p-find-condition + " " + ""
      parameter-5-26 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-ipck:handle
                          ,input rowid(X_db)
                          ,input logical(parameter-2-26)
                          ,input no-lock
                          ,input (buffer X_db:handle)
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
      parameter-3-26 =  "FOR EACH X_db NO-LOCK, EACH X_ext-file"
      parameter-4-26 =
        (
          if (" X_ext-file.file-num < 2147483647 and            ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type = p-file-type)              or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type = p-file-type)) " + " " + where-phrase-26) <> ""
          then  substitute('X_ext-file.file-num < 2147483647 and            ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type = &1&2&1)             or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type = &1&2&1))                ',  chr(34), p-file-type)  + " " + where-phrase-26
          else "true"
        )
      parameter-5-26 = (" " + "" + " " + "" + " " + p-find-condition)
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
                          ,input query br-ipck:handle
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
         OTHERWISE DO:
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
                              "FOR EACH X_db NO-LOCK, EACH X_ext-file"
      parameter-4-28 =
        (
          if (" X_ext-file.file-num < 2147483647 and          ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type >  p-file-type)            or (X_db.db-num = 0 and X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type >  p-file-type))  " + " " + where-phrase-28) <> ""
          then  substitute('X_ext-file.file-num < 2147483647 and            ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type > &1&2&1)            or (X_db.db-num = 0 and  X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and  X_ext-file.file-type > &1&2&1))            ',  chr(34), p-file-type)  + " " + where-phrase-28
          else "true"
        )
      parameter-5-28 = (" " + "" + " " + "")
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
          (" X_ext-file.file-num < 2147483647 and          ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type >  p-file-type)            or (X_db.db-num = 0 and X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type >  p-file-type))  " + " " + where-phrase-28 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-ipck:handle
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
    output to kkk.txt .
    put unformatted
      "glog = query br-ipck:handle:query-prepare (" skip
      parameter-3-28
      "where"            skip
      parameter-4-28 skip
      parameter-5-28 skip
      parameter-6-28 skip
      parameter-7-28 skip
      ")"                skip
      .
    output close .
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
    OPEN QUERY br-ipck FOR EACH X_db NO-LOCK, EACH  X_ext-file
      where  X_ext-file.file-num < 2147483647 and          ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type >  p-file-type)            or (X_db.db-num = 0 and X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type >  p-file-type))
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_db )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-ipck:handle:get-buffer-handle(1) = (buffer X_ext-file:handle) then do:
      assign
      parameter-2-28 = (if p-find-next then "true":u else "false":u )
      parameter-4-28 =
        "where ":u +  substitute('X_ext-file.file-num < 2147483647 and            ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type > &1&2&1)            or (X_db.db-num = 0 and  X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and  X_ext-file.file-type > &1&2&1))            ',  chr(34), p-file-type)  + " ":u + where-phrase-28 + " ":u + p-find-condition + " " + ""
      parameter-5-28 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-ipck:handle
                          ,input rowid(X_db)
                          ,input logical(parameter-2-28)
                          ,input no-lock
                          ,input (buffer X_db:handle)
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
      parameter-3-28 =  "FOR EACH X_db NO-LOCK, EACH X_ext-file"
      parameter-4-28 =
        (
          if (" X_ext-file.file-num < 2147483647 and          ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type >  p-file-type)            or (X_db.db-num = 0 and X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type >  p-file-type))  " + " " + where-phrase-28) <> ""
          then  substitute('X_ext-file.file-num < 2147483647 and            ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type > &1&2&1)            or (X_db.db-num = 0 and  X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and  X_ext-file.file-type > &1&2&1))            ',  chr(34), p-file-type)  + " " + where-phrase-28
          else "true"
        )
      parameter-5-28 = (" " + "" + " " + "" + " " + p-find-condition)
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
                          ,input query br-ipck:handle
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
     END CASE.
  END.
  ELSE DO:
      assign
     filter-point-name = substitute("Работа с файлами IBM-XML БД &2", p-db-num) .
      ASSIGN
      frame Dialog-Frame:TITLE = SUBSTITUTE("&1", title00).
      ASSIGN
 frame Dialog-Frame:TITLE = SUBSTITUTE("&1", title00).
 CASE p-file-type:
    WHEN 'cash-desk':U + chr(3) THEN DO:
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
                              "FOR EACH X_db NO-LOCK, EACH X_ext-file"
      parameter-4-30 =
        (
          if (" X_ext-file.file-num < 2147483647 and       ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type = p-file-type)         or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type = p-file-type)) " + " " + where-phrase-30) <> ""
          then  substitute('X_ext-file.file-num < 2147483647 and       ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type = &1&2&1)        or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type = &1&2&1))       ',  chr(34), p-file-type)  + " " + where-phrase-30
          else "true"
        )
      parameter-5-30 = (" " + "" + " " + "")
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
          (" X_ext-file.file-num < 2147483647 and       ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type = p-file-type)         or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type = p-file-type)) " + " " + where-phrase-30 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-ipck:handle
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
    output to kkk.txt .
    put unformatted
      "glog = query br-ipck:handle:query-prepare (" skip
      parameter-3-30
      "where"            skip
      parameter-4-30 skip
      parameter-5-30 skip
      parameter-6-30 skip
      parameter-7-30 skip
      ")"                skip
      .
    output close .
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
    OPEN QUERY br-ipck FOR EACH X_db NO-LOCK WHERE X_db.db-num = p-db-num, EACH  X_ext-file no-lock
      where  X_ext-file.file-num < 2147483647 and       ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type = p-file-type)         or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type = p-file-type))
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_db )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-ipck:handle:get-buffer-handle(1) = (buffer X_ext-file:handle) then do:
      assign
      parameter-2-30 = (if p-find-next then "true":u else "false":u )
      parameter-4-30 =
        "where ":u +  substitute('X_ext-file.file-num < 2147483647 and       ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type = &1&2&1)        or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type = &1&2&1))       ',  chr(34), p-file-type)  + " ":u + where-phrase-30 + " ":u + p-find-condition + " " + ""
      parameter-5-30 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-ipck:handle
                          ,input rowid(X_db)
                          ,input logical(parameter-2-30)
                          ,input no-lock
                          ,input (buffer X_db:handle)
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
      parameter-3-30 =  "FOR EACH X_db NO-LOCK, EACH X_ext-file"
      parameter-4-30 =
        (
          if (" X_ext-file.file-num < 2147483647 and       ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type = p-file-type)         or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type = p-file-type)) " + " " + where-phrase-30) <> ""
          then  substitute('X_ext-file.file-num < 2147483647 and       ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type = &1&2&1)        or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type = &1&2&1))       ',  chr(34), p-file-type)  + " " + where-phrase-30
          else "true"
        )
      parameter-5-30 = (" " + "" + " " + "" + " " + p-find-condition)
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
                          ,input query br-ipck:handle
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
    OTHERWISE DO:
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
                              "FOR EACH X_db NO-LOCK, EACH X_ext-file"
      parameter-4-32 =
        (
          if (" X_ext-file.file-num < 2147483647 and     ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type >  p-file-type)       or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type >  p-file-type))  " + " " + where-phrase-32) <> ""
          then  substitute('X_ext-file.file-num < 2147483647 and       ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type > &1&2&1)       or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and  X_ext-file.file-type > &1&2&1))       ',  chr(34), p-file-type)  + " " + where-phrase-32
          else "true"
        )
      parameter-5-32 = (" " + "" + " " + "")
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
          (" X_ext-file.file-num < 2147483647 and     ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type >  p-file-type)       or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type >  p-file-type))  " + " " + where-phrase-32 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-ipck:handle
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
    output to kkk.txt .
    put unformatted
      "glog = query br-ipck:handle:query-prepare (" skip
      parameter-3-32
      "where"            skip
      parameter-4-32 skip
      parameter-5-32 skip
      parameter-6-32 skip
      parameter-7-32 skip
      ")"                skip
      .
    output close .
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
    OPEN QUERY br-ipck FOR EACH X_db NO-LOCK WHERE X_db.db-num = p-db-num, EACH  X_ext-file no-lock
      where  X_ext-file.file-num < 2147483647 and     ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type >  p-file-type)       or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type >  p-file-type))
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_db )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-ipck:handle:get-buffer-handle(1) = (buffer X_ext-file:handle) then do:
      assign
      parameter-2-32 = (if p-find-next then "true":u else "false":u )
      parameter-4-32 =
        "where ":u +  substitute('X_ext-file.file-num < 2147483647 and       ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type > &1&2&1)       or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and  X_ext-file.file-type > &1&2&1))       ',  chr(34), p-file-type)  + " ":u + where-phrase-32 + " ":u + p-find-condition + " " + ""
      parameter-5-32 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-ipck:handle
                          ,input rowid(X_db)
                          ,input logical(parameter-2-32)
                          ,input no-lock
                          ,input (buffer X_db:handle)
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
      parameter-3-32 =  "FOR EACH X_db NO-LOCK, EACH X_ext-file"
      parameter-4-32 =
        (
          if (" X_ext-file.file-num < 2147483647 and     ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type >  p-file-type)       or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and X_ext-file.file-type >  p-file-type))  " + " " + where-phrase-32) <> ""
          then  substitute('X_ext-file.file-num < 2147483647 and       ((X_ext-file.db-num = X_db.db-num and X_ext-file.file-type > &1&2&1)       or (X_ext-file.db-num = 0 and X_ext-file.from-db-num = X_db.db-num and  X_ext-file.file-type > &1&2&1))       ',  chr(34), p-file-type)  + " " + where-phrase-32
          else "true"
        )
      parameter-5-32 = (" " + "" + " " + "" + " " + p-find-condition)
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
                          ,input query br-ipck:handle
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
  END CASE.
END.
if not p-open-query then
REPOSITION br-ipck to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-ipck:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-ipck in frame Dialog-Frame.
APPLY "ENTRY" TO br-ipck.
END PROCEDURE.
PROCEDURE proc-b-add :
define variable v-recid as recid no-undo .
run utl/sendxprw.w ( input parparentproc) no-error.
run OpenBr in this-procedure ( input yes, input no, input no) .
END PROCEDURE.
PROCEDURE proc-b-del :
DEFINE INPUT PARAMETER p-del-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE glog AS logical NO-UNDO.
define variable v-loc-rid-list as character no-undo .
define variable v-entry as character no-undo .
DEFINE BUFFER buf_exT-FILE FOR UB.EXT-FILE.
if v-rid-list = '':U then do:
  MESSAGE
  "Вы действительно хотите удалить запись о выделенном файле?" skip
  "(с диска файла не удаляется)" skip
  VIEW-AS ALERT-BOX QUESTION buttons YES-NO UPDATE glog.
  IF NOT glog THEN RETURN.
  v-loc-rid-list = string(recid(X_ext-file)).
end.
else  do:
  MESSAGE
  "Вы действительно хотите удалить записи о выделенных файлах?" skip
  "(с диска файлы не удаляются)" skip
  VIEW-AS ALERT-BOX QUESTION buttons YES-NO UPDATE glog.
  IF NOT glog THEN RETURN.
  v-loc-rid-list = v-rid-list.
end.
DO ii = 1 TO NUM-ENTRIES(v-loc-rid-list):
  FIND FIRST BUF_EXT-FILE NO-LOCK WHERE
            RECID(BUF_eXT-FILE) = INTEGER( ENTRY(II, V-loc-RID-LIST)) NO-ERROR.
    IF AVAILABLE BUF_eXT-FILE  THEN DO:
      v-entry = string(recid(buf_ext-file)).
      run adm/extf-del.p ( BUFFER BUF_eXT-FILE
                          , input no
                          , INPUT buf_ext-file.status_) no-error .
      if error-status:error then do:
        message
        substitute("Ошибка при удалении файла БД&1&2№ файла &3&2&4&2&5&2&6"
                    , buf_ext-file.db-num
                    , chr(10)
                    , buf_Ext-file.file-num
                    , buf_ext-file.file-name-exec
                    , error-status:get-message(1)
                    , return-value )
        view-as alert-box error.
      end.
      else do:
        if lookup(v-entry, v-rid-list) <> 0 then do:
          entry(lookup(v-entry, v-rid-list), v-rid-list) = ''.
          v-rid-list = replace(v-rid-list, chr(44) + chr(44), chr(44)).
          v-rid-list = trim(v-rid-list, chr(44)).
        end.
      end.
      if num-entries( v-rid-list ) > 0 then do:
        DISPLAY
        num-entries( v-rid-list ) @ mark-num
        with frame Dialog-Frame.
      end.
      else do:
        hide
        mark-num
        in frame Dialog-Frame .
      end.
    END.
END.
run OpenBr in this-procedure ( input yes, input no, input no) .
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
  tbl = 'ext-file'
  join-tbl = 'X_ext-file'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('db-num', 'для БД', 'db',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('from-db-num', 'из БД', 'db',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('file-size', 'Размер', 'db',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('file-name-exec', 'Файл манифеста', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('update-sys-date', 'Дата установки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('update-user-name', 'Установил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                    , INPUT (filter-point + chr(4) +
                            filter-point-name)
                    , INPUT tbl
                    , INPUT join-tbl
                    , INPUT fld
                    , INPUT lab
                    , INPUT spr
                    , INPUT dim ).
  run OpenBr in this-procedure ( input yes, input no, input '':U).
END.
END PROCEDURE.
PROCEDURE proc-lkp :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-override AS INTEGER no-UNDO.
DEFINE VARIABLE v-printed AS logical no-UNDO.
DEFINE VARIABLE v-temp-file-name AS CHARACTER NO-UNDO.
run gbl/_tmpfile.p (
       input  't':U
      ,input  "." + entry( num-entries(X_ext-file.file-name-exec, "."), X_ext-file.FILE-NAME-exec, ".")
      ,output v-temp-file-name
      ) .
run adm/extfsavd.p (
             INPUT X_ext-file.db-num
            ,INPUT X_ext-file.from-db-num
            ,INPUT X_ext-file.file-num
            ,INPUT v-temp-file-name
            ,INPUT-OUTPUT v-override) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
  MESSAGE
  SUBSTITUTE("Ошибка при сохранении файла &1 на диск во временный файл&2&3&2&4&2"
          , X_ext-file.FILE-NAME-exec
          , chr(10)
          ,error-status:get-message(1)
          , RETURN-VALUE)
  VIEW-AS ALERT-BOX ERROR.
  RETURN ERROR.
END.
os-command  value ('start /wait /b ' + v-temp-file-name).
OS-DELETE VALUE(v-temp-file-name).
END PROCEDURE.
PROCEDURE proc-save-disk :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-override AS INTEGER no-UNDO.
DEFINE VARIABLE v-dir-path AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dir-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-can-write AS logical NO-UNDO.
DEFINE VARIABLE v-num-files AS integer NO-UNDO.
DEFINE VARIABLE v-ok AS integer NO-UNDO.
DEFINE VARIABLE ii AS integer NO-UNDO.
DEFINE VARIABLE v-loc-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_Ext-file FOR ub.ext-file.
MESSAGE
"Вы действительно хотите сохранить на диск выбранный файл/файлы?"
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
IF NOT glog THEN RETURN.
 run gbl/dir-sel.p (
                  output v-dir-path
                , output v-dir-type
                , output v-can-write
                      )
.
if not v-can-write then do:
    message
    substitute("Вы не имеет прав на запись в выбранный каталог &1", v-dir-path)
    view-as alert-box error .
    return error.
end.
IF v-rid-list = '':U THEN DO:
  v-loc-rid-list = STRING(RECID(X_ext-file)).
END.
ELSE DO:
  v-loc-rid-list = v-rid-list.
END.
v-num-files = NUM-ENTRIES(v-loc-rid-list).
_ii:
DO ii = 1 TO v-NUM-files
on stop UNDO _ii, NEXT _ii:
  FIND FIRST buf_ext-file NO-LOCK WHERE
           recid(buf_Ext-file) = INTEGER(ENTRY(ii, v-loc-rid-list)) NO-ERROR.
  IF NOT AVAILABLE buf_ext-file THEN NEXT _ii.
  run adm/extfsavd.p (
                 INPUT buf_ext-file.db-num
                ,INPUT buf_ext-file.from-db-num
                ,INPUT buf_ext-file.file-num
                ,INPUT v-dir-path
                ,INPUT-OUTPUT v-override) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE
    SUBSTITUTE("Ошибка при сохранении файла &1 на диск&2&3&2&4&2"
              , buf_ext-file.FILE-NAME-exec
              , chr(10)
              ,error-status:get-message(1)
              , RETURN-VALUE)
    VIEW-AS ALERT-BOX ERROR.
    RETURN ERROR.
  END.
  ELSE DO:
      v-ok = v-ok + 1.
  END.
END.
IF v-ok <> v-NUM-files THEN DO:
   MESSAGE
   SUBSTITUTE("Выбрано файлов &1, удалось сохранить на диск &2"
              , v-num-files
              , v-ok)
   VIEW-AS ALERT-BOX.
END.
END PROCEDURE.
FUNCTION get-cd RETURNS INTEGER
  ( INPUT p-db-num AS integer
  , INPUT p-from-db-num AS integer
  , INPUT p-file-num AS INTEGER ) :
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo.
DEFINE BUFFER buf_ext-file-par FOR ub.ext-file-par.
FIND FIRST buf_ext-file-par NO-LOCK WHERE
        buf_ext-file-par.db-num = p-db-num
    AND buf_ext-file-par.from-db-num = p-from-db-num
    AND buf_ext-file-par.file-num = p-file-num
    AND buf_ext-file-par.param-num = 1 NO-ERROR.
IF AVAILABLE buf_ext-file-par
AND buf_ext-file-par.param-type = 'uniq-key-rec':U THEN DO:
    run gen-key-fv in this-procedure ( input buf_ext-file-par.param-name
                                      ,output v-field-list
                                      ,output v-value-list) .
    ASSIGN
    v-cd-db-num = INTEGER(entry(lookup("db-num", v-field-list, chr(3)), v-value-list, chr(3)))
    v-cd-obj-code = INTEGER(entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3)))
    v-cd-cash-num = INTEGER(entry(lookup("cash-num", v-field-list, chr(3)), v-value-list, chr(3)))
    .
    RETURN v-cd-db-num.
END.
ELSE DO:
    ASSIGN
    v-cd-db-num = ?
    v-cd-obj-code = 0
    v-cd-cash-num = 0
    .
   RETURN v-cd-db-num.
END.
END FUNCTION.
