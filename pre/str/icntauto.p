block-level on error undo, throw.
define input parameter parparentproc   as widget-handle no-undo.
define input parameter p-rvs-doc-rowid as rowid         no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: icntauto.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/icntauto.p $":U .
define variable vss-description as character no-undo init "Автоматическое создание инвентаризации счетчиков ТРК по документу сверки".
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
  define new global shared variable g#lib-rvs as handle no-undo.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define temp-table tt-icnt-doc   no-undo like ub.icnt-doc.
define temp-table tt-icnt-line  no-undo like ub.icnt-line.
define buffer cur_rvs-doc         for ub.rvs-doc.
define buffer prev_rvs-doc        for ub.rvs-doc.
define buffer cur_shift-obj       for ub.shift-obj.
define buffer prev_shift-obj      for ub.shift-obj.
define buffer cur_rvs-line-pump   for ub.rvs-line-pump.
define buffer prev_rvs-line-pump  for ub.rvs-line-pump.
define buffer prev_icnt-line      for ub.icnt-line.
define buffer buf_icnt-doc        for ub.icnt-doc.
define buffer buf_rvs-line        for ub.rvs-line.
define buffer bf_pl-gds-pump      for ub.pl-gds-pump.
define variable v-log           as logical    no-undo .
define variable v-today         as date       no-undo .
define variable v-recid         as recid      no-undo .
define variable v-meas-el-cnt   as decimal    no-undo .
define variable v-state-el-cnt  as decimal    no-undo .
define variable v-state-mh-cnt  as decimal    no-undo .
function get-overflow return decimal ( input p-val as decimal ) forward.
_main-block:
do
on error  undo _main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first cur_rvs-doc no-lock
    where rowid(cur_rvs-doc) = p-rvs-doc-rowid
  no-error .
  if not available cur_rvs-doc then do:
    undo _main-block , return error "Не найден документ сверки":U.
  end.
  find first cur_shift-obj no-lock
    where cur_shift-obj.obj-type = cur_rvs-doc.obj-type
      and cur_shift-obj.obj-code = cur_rvs-doc.obj-code
      and cur_shift-obj.status_  = 'тек':U
  no-error.
  if not available cur_shift-obj then do:
    undo _main-block , return error substitute( 'Нет открытой смены на объекте &1 &2'
                                              , cur_rvs-doc.obj-type
                                              , cur_rvs-doc.obj-code
                                              ).
  end.
  find last prev_shift-obj no-lock
    where prev_shift-obj.obj-type   = cur_shift-obj.obj-type
      and prev_shift-obj.obj-code   = cur_shift-obj.obj-code
      and prev_shift-obj.status_    = 'зкр':U
      and ( prev_shift-obj.shift-date < cur_shift-obj.shift-date
          or
            prev_shift-obj.shift-date = cur_shift-obj.shift-date
          and
            prev_shift-obj.shift-num  < cur_shift-obj.shift-num
          )
    use-index stts no-error.
  if available prev_shift-obj then do:
    find last prev_rvs-doc no-lock
      where prev_rvs-doc.obj-type   = prev_shift-obj.obj-type
        and prev_rvs-doc.obj-code   = prev_shift-obj.obj-code
        and prev_rvs-doc.shift-date = prev_shift-obj.shift-date
        and prev_rvs-doc.shift-num  = prev_shift-obj.shift-num
        and prev_rvs-doc.status_    = 'факт':U
        and prev_rvs-doc.rvs-type   = 'смена':U
      no-error.
  end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  cur_rvs-doc.obj-type
  ,input  cur_rvs-doc.obj-code
  ,output v-today
  )  .
  run clear-temp in this-procedure .
  create tt-icnt-doc.
  assign
    tt-icnt-doc.doc-code      = "":U
    tt-icnt-doc.obj-type      = cur_rvs-doc.obj-type
    tt-icnt-doc.obj-code      = cur_rvs-doc.obj-code
    tt-icnt-doc.host-code     = cur_rvs-doc.host-code
    tt-icnt-doc.wrkr          = cur_rvs-doc.wrkr
    tt-icnt-doc.agnt          = cur_rvs-doc.agnt
    tt-icnt-doc.boss          = cur_rvs-doc.boss
    tt-icnt-doc.doc-date      = v-today
    tt-icnt-doc.meas-el-cnt   = 0
    tt-icnt-doc.state-el-cnt  = 0
    tt-icnt-doc.state-mh-cnt  = 0
    tt-icnt-doc.PS            = cur_rvs-doc.rvs-code
    tt-icnt-doc.creid         = v-cntxt-userid
  .
  for each cur_rvs-line-pump exclusive-lock
    where cur_rvs-line-pump.rvs-code = cur_rvs-doc.rvs-code
  on error  undo _main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo _main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first prev_rvs-line-pump no-lock
      where prev_rvs-line-pump.rvs-code     = prev_rvs-doc.rvs-code
        and prev_rvs-line-pump.obj-type     = prev_rvs-doc.obj-type
        and prev_rvs-line-pump.obj-code     = prev_rvs-doc.obj-code
        and prev_rvs-line-pump.pl-code      = cur_rvs-line-pump.pl-code
        and prev_rvs-line-pump.gds-code     = cur_rvs-line-pump.gds-code
        and prev_rvs-line-pump.pump-code    = cur_rvs-line-pump.pump-code
        and prev_rvs-line-pump.nozzle-code  = cur_rvs-line-pump.nozzle-code
    no-error .
    find first tt-icnt-line no-lock
      where tt-icnt-line.doc-code    = tt-icnt-doc.doc-code
        and tt-icnt-line.obj-code    = tt-icnt-doc.obj-code
        and tt-icnt-line.obj-type    = tt-icnt-doc.obj-type
        and tt-icnt-line.pump-code   = cur_rvs-line-pump.pump-code
        and tt-icnt-line.nozzle-code = cur_rvs-line-pump.nozzle-code
      no-error .
    if not available tt-icnt-line then do:
      create tt-icnt-line.
      assign
        tt-icnt-line.doc-code     = tt-icnt-doc.doc-code
        tt-icnt-line.obj-code     = cur_rvs-line-pump.obj-code
        tt-icnt-line.obj-type     = cur_rvs-line-pump.obj-type
        tt-icnt-line.pl-code      = cur_rvs-line-pump.pl-code
        tt-icnt-line.gds-code     = cur_rvs-line-pump.gds-code
        tt-icnt-line.pump-code    = cur_rvs-line-pump.pump-code
        tt-icnt-line.nozzle-code  = cur_rvs-line-pump.nozzle-code
        tt-icnt-line.state-el-cnt = cur_rvs-line-pump.state-el-cnt
        tt-icnt-line.meas-el-cnt  = cur_rvs-line-pump.meas-el-cnt
        tt-icnt-line.state-mh-cnt = cur_rvs-line-pump.state-mh-cnt
      .
    end.
    if available prev_rvs-line-pump
    and cur_rvs-line-pump.state-el-cnt < prev_rvs-line-pump.state-el-cnt
    then do:
      find first bf_pl-gds-pump no-lock where bf_pl-gds-pump.obj-type = cur_rvs-line-pump.obj-type
                                          and bf_pl-gds-pump.obj-code = cur_rvs-line-pump.obj-code
                                          and bf_pl-gds-pump.gds-code = cur_rvs-line-pump.gds-code
                                          and bf_pl-gds-pump.pl-code  = cur_rvs-line-pump.pl-code
                                          and bf_pl-gds-pump.pump-code = cur_rvs-line-pump.pump-code
                                          no-error.
      if available bf_pl-gds-pump
      and bf_pl-gds-pump.status_ = 'блок':U
      then do : end .
      else
      assign
        tt-icnt-line.state-mh-cnt = tt-icnt-line.state-mh-cnt + get-overflow( prev_rvs-line-pump.state-el-cnt )
      .
      assign
        cur_rvs-line-pump.state-mh-cnt  = tt-icnt-line.state-mh-cnt
        cur_rvs-line-pump.state-mh-qnty = cur_rvs-line-pump.state-mh-cnt - prev_rvs-line-pump.state-mh-cnt
        cur_rvs-line-pump.meas-mh-cnt   = cur_rvs-line-pump.state-mh-cnt
        cur_rvs-line-pump.meas-mh-qnty  = cur_rvs-line-pump.state-mh-qnty
      .
      end.
    end.
  for each tt-icnt-line
    where tt-icnt-line.doc-code = tt-icnt-doc.doc-code
      and tt-icnt-line.obj-code = tt-icnt-doc.obj-code
      and tt-icnt-line.obj-type = tt-icnt-doc.obj-type
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    assign
      v-meas-el-cnt  = v-meas-el-cnt  + tt-icnt-line.meas-el-cnt
      v-state-el-cnt = v-state-el-cnt + tt-icnt-line.state-el-cnt
      v-state-mh-cnt = v-state-mh-cnt + tt-icnt-line.state-mh-cnt
    .
  end.
  for each buf_rvs-line no-lock
  on error  undo _main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo _main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main-block, return error substitute( "&1. endkey", vss-workfile )
  :
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_rvsclcln in g#lib-rvs ( input recid(buf_rvs-line) ) no-error .
    if error-status :error then do:
      undo _main-block , return error substitute( "Ошибка пересчета количества по резервуарам.&1&2&1&3":U, chr(10), return-value, error-status :get-message(1) ).
    end.
  end.
  assign
    tt-icnt-doc.meas-el-cnt  = v-meas-el-cnt
    tt-icnt-doc.state-el-cnt = v-state-el-cnt
    tt-icnt-doc.state-mh-cnt = v-state-mh-cnt
  .
  run waitfram-show in this-procedure ( "Создание документа инвентаризации счетчиков ТРК":U ) .
  run str/icntdoc1.p
    ( input 'ДОБАВЛЕНИЕ':U
     ,input no
     ,input-output v-recid
     ,INPUT tt-icnt-doc.doc-code
     ,input tt-icnt-doc.obj-type
     ,input tt-icnt-doc.obj-code
     ,input tt-icnt-doc.host-code
     ,input 'инв-сч-трк':U
     ,input 'ip':U
     ,input tt-icnt-doc.wrkr
     ,input tt-icnt-doc.agnt
     ,input tt-icnt-doc.boss
     ,input tt-icnt-doc.doc-date
     ,input tt-icnt-doc.meas-el-cnt
     ,input tt-icnt-doc.state-el-cnt
     ,input tt-icnt-doc.state-mh-cnt
     ,input tt-icnt-doc.PS
     ,input tt-icnt-doc.creid
     ,input '':U
     ,input table tt-icnt-line
    ) no-error.
  if error-status:error then do:
    undo _main-block , return error return-value .
  end.
  find first buf_icnt-doc exclusive-lock
    where recid(buf_icnt-doc) = v-recid
  no-error .
  if not available buf_icnt-doc then do:
    undo _main-block , return error "Не найден документ автоматической инвентаризации":U.
  end.
  assign
    buf_icnt-doc.PS = "@":U
  .
  release buf_icnt-doc .
  run waitfram-show in this-procedure ( "Закрытие документа инвентаризации счетчиков ТРК":U ) .
  run str/icntdoc2.p
    ( input v-recid
     ,input no
    ) no-error.
  if error-status:error then do:
    undo _main-block , return error return-value .
  end.
  run clear-temp in this-procedure .
  run waitfram-hide in this-procedure .
end.
procedure clear-temp :
do
on error undo, return error return-value
:
  for each tt-icnt-doc
  on error undo, return error return-value
  :
    delete tt-icnt-doc .
  end.
  for each tt-icnt-line
  on error undo, return error return-value
  :
    delete tt-icnt-line .
  end.
end.
end procedure.
function get-overflow return decimal ( input p-val as decimal ).
  define variable v-val       as decimal   no-undo .
  define variable v-overflow  as decimal   no-undo .
  assign
    v-val       = p-val
    v-overflow  = 1
  .
  do while v-val > 1 :
    assign
      v-val       = v-val / 10
      v-overflow  = v-overflow * 10
    .
  end.
  return v-overflow.
end function.
