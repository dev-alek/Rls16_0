block-level on error undo, throw.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input parameter par-date as date no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rclarhwth.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/rclarhwth.p $":U .
define variable vss-description as character no-undo init "Пересчет архивов МЦ".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
define temp-table tt-parts-cli    no-undo like ub.arh-wth-cli
 .
define temp-table tt-parts-cli-tot    no-undo like ub.arh-wth-cli-tot
 .
define temp-table tt-parts-cli-doc no-undo like ub.arh-wth-cli-doc
.
define temp-table tt-parts-tot    no-undo like ub.arh-wth-tot.
define temp-table tt-parts-wp     no-undo like ub.arh-wth-w-p.
define buffer buf-prev_arh-wth-cli   for ub.arh-wth-cli.
define buffer buf-arh-wth-cli        for ub.arh-wth-cli.
define buffer buf-recalc-cli         for ub.arh-wth-cli.
define buffer buf-prev_arh-wth-cli-doc   for ub.arh-wth-cli-doc.
define buffer buf-arh-wth-cli-doc    for ub.arh-wth-cli-doc.
define buffer buf-recalc-cli-doc     for ub.arh-wth-cli-doc.
define buffer buf-prev_arh-wth-tot   for ub.arh-wth-tot.
define buffer buf-arh-wth-tot        for ub.arh-wth-tot.
define buffer buf-recalc-tot         for ub.arh-wth-tot.
define buffer buf-prev_arh-wth-wp    for ub.arh-wth-w-p.
define buffer buf-arh-wth-wp         for ub.arh-wth-w-p.
define buffer buf-recalc-wp          for ub.arh-wth-w-p.
define buffer buf-arh_wth-doc        for ub.wth-doc.
define buffer buf-prev_arh-wth-cli-tot   for ub.arh-wth-cli-tot.
define buffer buf-arh-wth-cli-tot        for ub.arh-wth-cli-tot.
define buffer buf-recalc-cli-tot         for ub.arh-wth-cli-tot.
procedure wth-arh-mode:
  define input  parameter parext-doc-type like ub.wth-doc.ext-doc-type no-undo.
  define input  parameter pardoc-code like ub.wth-doc.doc-code no-undo.
  define output parameter parinc-exp      as   integer                 no-undo.
  define buffer buf_wth-parts   for ub.wth-parts.
  case parext-doc-type:
    when 'ee':U
    or when 'pc':U
    or when 'ps':U
    or when 'pz':U
    or when 'dc':U
    or when 'xc':U
    then do:
      if can-find(first buf_wth-parts where buf_wth-parts.out-code = pardoc-code)
      then parinc-exp = 1.
      else parinc-exp = 0.
    end.
  end case.
end procedure.
 procedure wth-arh-calctt-loc:
  define input parameter pardoc-code as char no-undo.
  define input parameter par-lock as log no-undo.
  define var vararh-mode as int no-undo.
  define buffer buf_wth-parts   for ub.wth-parts.
  define variable v-cli-type    as character    no-undo.
  define variable v-cli-code    as integer      no-undo.
  define variable v-zone        as character    no-undo.
  do on error undo, return error substitute ("Создание архивов по документу &4 &1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2),pardoc-code) :
  find first buf-arh_wth-doc where buf-arh_wth-doc.doc-code = pardoc-code no-lock no-error.
  if not available buf-arh_wth-doc then do:
    return error substitute ("Не найден документ МЦ с номером &1.", pardoc-code).
  end.
  run wth-arh-mode(input buf-arh_wth-doc.ext-doc-type
          ,input buf-arh_wth-doc.doc-code
          ,output vararh-mode).
  empty temp-table tt-parts-cli.
  empty temp-table tt-parts-cli-tot.
  empty temp-table tt-parts-wp.
  empty temp-table tt-parts-cli-doc.
  empty temp-table tt-parts-tot   .
  for each buf_wth-parts no-lock where
           buf_wth-parts.out-code = pardoc-code
       and buf_wth-parts.stts = 0 :
   if  not g#news
       or (g#news and  g#db-num  = 0)
   then do:
      find first tt-parts-tot where
                tt-parts-tot.wth-code = buf_wth-parts.wth-code
            and tt-parts-tot.par-code = buf_wth-parts.par-code
            and tt-parts-tot.obj-type = buf_wth-parts.obj-type
            and tt-parts-tot.obj-code = buf_wth-parts.obj-code
            and tt-parts-tot.ext-doc-type = buf_wth-parts.ext-doc-type
            and tt-parts-tot.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
            no-error.
      if not available tt-parts-tot then do:
        create tt-parts-tot.
        assign tt-parts-tot.wth-code = buf_wth-parts.wth-code
              tt-parts-tot.par-code = buf_wth-parts.par-code
              tt-parts-tot.gds-code = buf_wth-parts.gds-code
              tt-parts-tot.w-p-code = buf_wth-parts.w-p-code
              tt-parts-tot.obj-type = buf_wth-parts.obj-type
              tt-parts-tot.obj-code = buf_wth-parts.obj-code
              tt-parts-tot.ext-doc-type = buf_wth-parts.ext-doc-type
              tt-parts-tot.doc-code = buf_wth-parts.out-code
              tt-parts-tot.host-code = buf_wth-parts.host-code
              tt-parts-tot.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
        .
      end.
      if buf-arh_wth-doc.doc-type = 'при':U or (buf-arh_wth-doc.doc-type = 'обмен':U and  buf_wth-parts.type = 'при':U) or  buf_wth-parts.type = 'возврат':U then      assign tt-parts-tot.in-qnty     = tt-parts-tot.in-qnty     + buf_wth-parts.fact-qnty            tt-parts-tot.in-sum-rubl = tt-parts-tot.in-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl           tt-parts-tot.in-sum-base = tt-parts-tot.in-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base .    else   assign tt-parts-tot.out-qnty  = tt-parts-tot.out-qnty + buf_wth-parts.fact-qnty                               tt-parts-tot.out-sum-rubl = tt-parts-tot.out-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl            tt-parts-tot.out-sum-base = tt-parts-tot.out-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base  .
      if lookup(buf-arh_wth-doc.ext-doc-type,'ie,ff,rf':U) > 0
      or (buf-arh_wth-doc.ext-doc-type = 'xc':U  and buf_wth-parts.type = 'рас':U)
      or lookup (buf-arh_wth-doc.ext-doc-type,'ee,ef,df':u) > 0 then
      v-zone = 'free-zone':U.
      else if lookup(buf-arh_wth-doc.ext-doc-type,'ip,pc,ps,pz,rp':u) > 0
      or (buf-arh_wth-doc.ext-doc-type = 'xc':U  and buf_wth-parts.type = 'при':U)
      or lookup (buf-arh_wth-doc.ext-doc-type,'ep,dp':u) > 0 then
      v-zone = 'put-zone':U.
      if v-zone = 'free-zone':U or  v-zone = 'put-zone':U then do:
        find first tt-parts-wp where
                  tt-parts-wp.obj-type = buf_wth-parts.obj-type
              and tt-parts-wp.obj-code = buf_wth-parts.obj-code
              and tt-parts-wp.w-p-code = buf_wth-parts.w-p-code
              and tt-parts-wp.wth-code = buf_wth-parts.wth-code
              and tt-parts-wp.par-code = buf_wth-parts.par-code
              and tt-parts-wp.out-code = v-zone
              no-error.
        if not available tt-parts-wp then do:
          create tt-parts-wp.
          assign tt-parts-wp.wth-code = buf_wth-parts.wth-code
                tt-parts-wp.par-code = buf_wth-parts.par-code
                tt-parts-wp.gds-code = buf_wth-parts.gds-code
                tt-parts-wp.w-p-code = buf_wth-parts.w-p-code
                tt-parts-wp.obj-type = buf_wth-parts.obj-type
                tt-parts-wp.obj-code = buf_wth-parts.obj-code
                tt-parts-wp.out-code = v-zone
                tt-parts-wp.ext-doc-type = buf_wth-parts.ext-doc-type
                tt-parts-wp.doc-code = buf_wth-parts.out-code
                tt-parts-wp.host-code = buf_wth-parts.host-code
          .
        end.
        if buf-arh_wth-doc.doc-type = 'при':U or (buf-arh_wth-doc.doc-type = 'обмен':U and  buf_wth-parts.type = 'при':U) then
    assign tt-parts-wp.in-qnty     = tt-parts-wp.in-qnty     + buf_wth-parts.fact-qnty
           tt-parts-wp.in-sum-rubl = tt-parts-wp.in-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
           tt-parts-wp.in-sum-base = tt-parts-wp.in-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base .
    else   assign tt-parts-wp.out-qnty  = tt-parts-wp.out-qnty + buf_wth-parts.fact-qnty
           tt-parts-wp.out-sum-rubl = tt-parts-wp.out-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
           tt-parts-wp.out-sum-base = tt-parts-wp.out-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base  .
      end.
    end.
    if vararh-mode = 1 then do:
      if buf_wth-parts.in-code = 'фальшивый':U then
      assign v-cli-type = '':U
             v-cli-code = 0.
      else assign v-cli-type = buf_wth-parts.cli-type
             v-cli-code = buf_wth-parts.cli-code.
      find first tt-parts-cli where
                tt-parts-cli.wth-code = buf_wth-parts.wth-code
            and tt-parts-cli.par-code = buf_wth-parts.par-code
            and tt-parts-cli.ser-code = buf_wth-parts.ser-code
            and tt-parts-cli.db-num   = buf_wth-parts.db-num
            and tt-parts-cli.cli-type = v-cli-type
            and tt-parts-cli.cli-code = v-cli-code
            and tt-parts-cli.obj-type = buf_wth-parts.obj-type
            and tt-parts-cli.obj-code = buf_wth-parts.obj-code
            and tt-parts-cli.ext-doc-type = buf_wth-parts.ext-doc-type
            and tt-parts-cli.gds-code = buf_wth-parts.gds-code
            and tt-parts-cli.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
            no-error.
      if not available tt-parts-cli then do:
        create tt-parts-cli.
        assign tt-parts-cli.wth-code = buf_wth-parts.wth-code
              tt-parts-cli.par-code = buf_wth-parts.par-code
              tt-parts-cli.ser-code = buf_wth-parts.ser-code
              tt-parts-cli.db-num   = buf_wth-parts.db-num
              tt-parts-cli.cli-type = v-cli-type
              tt-parts-cli.cli-code = v-cli-code
              tt-parts-cli.obj-type = buf_wth-parts.obj-type
              tt-parts-cli.obj-code = buf_wth-parts.obj-code
              tt-parts-cli.doc-code  = buf_wth-parts.out-code
              tt-parts-cli.ext-doc-type = buf_wth-parts.ext-doc-type
              tt-parts-cli.gds-code = buf_wth-parts.gds-code
              tt-parts-cli.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
        .
      end.
    if buf-arh_wth-doc.doc-type = 'при':U
    or buf-arh_wth-doc.doc-type = 'возврат':U
    or (buf-arh_wth-doc.doc-type = 'обмен':U and buf_wth-parts.type = 'при':U)
    then
    assign tt-parts-cli.in-qnty     = tt-parts-cli.in-qnty     + buf_wth-parts.fact-qnty
           tt-parts-cli.in-sum-rubl = tt-parts-cli.in-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
           tt-parts-cli.in-sum-base = tt-parts-cli.in-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base .
    else   assign tt-parts-cli.out-qnty  = tt-parts-cli.out-qnty + buf_wth-parts.fact-qnty
           tt-parts-cli.out-sum-rubl = tt-parts-cli.out-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
           tt-parts-cli.out-sum-base = tt-parts-cli.out-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base  .
      find first tt-parts-cli-doc where
                tt-parts-cli-doc.wth-code = buf_wth-parts.wth-code
            and tt-parts-cli-doc.par-code = buf_wth-parts.par-code
            and tt-parts-cli-doc.cli-type = v-cli-type
            and tt-parts-cli-doc.cli-code = v-cli-code
            and tt-parts-cli-doc.host-code = buf_wth-parts.host-code
            and tt-parts-cli-doc.contract-code = buf_wth-parts.contract-code
            and tt-parts-cli-doc.gds-code = buf_wth-parts.gds-code
            and tt-parts-cli-doc.obj-type = buf_wth-parts.obj-type
            and tt-parts-cli-doc.obj-code = buf_wth-parts.obj-code
            and tt-parts-cli-doc.w-p-code = buf_wth-parts.w-p-code
            and tt-parts-cli-doc.ext-doc-type = buf_wth-parts.ext-doc-type
            and tt-parts-cli-doc.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
            no-error.
      if not available tt-parts-cli-doc then do:
        create tt-parts-cli-doc.
        buffer-copy buf_wth-parts using wth-code
                                        par-code
                                        host-code
                                        contract-code
                                        gds-code
                                        obj-type
                                        obj-code
                                        w-p-code
                                        ext-doc-type
                    to tt-parts-cli-doc.
        assign tt-parts-cli-doc.doc-code = buf_wth-parts.out-code
               tt-parts-cli-doc.cli-code = v-cli-code
               tt-parts-cli-doc.cli-type = v-cli-type
               tt-parts-cli-doc.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
        .
      end.
      if buf-arh_wth-doc.doc-type = 'при':U
      or buf-arh_wth-doc.doc-type = 'возврат':U
      or (buf-arh_wth-doc.doc-type = 'обмен':U and buf_wth-parts.type = 'при':U )
      then
    assign tt-parts-cli-doc.in-qnty     = tt-parts-cli-doc.in-qnty     + buf_wth-parts.fact-qnty
           tt-parts-cli-doc.in-sum-rubl = tt-parts-cli-doc.in-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
           tt-parts-cli-doc.in-sum-base = tt-parts-cli-doc.in-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base .
    else   assign tt-parts-cli-doc.out-qnty  = tt-parts-cli-doc.out-qnty + buf_wth-parts.fact-qnty
           tt-parts-cli-doc.out-sum-rubl = tt-parts-cli-doc.out-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
           tt-parts-cli-doc.out-sum-base = tt-parts-cli-doc.out-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base  .
      find first tt-parts-cli-tot where
                tt-parts-cli-tot.cli-type = v-cli-type
            and tt-parts-cli-tot.cli-code = v-cli-code
            and tt-parts-cli-tot.obj-type = buf_wth-parts.obj-type
            and tt-parts-cli-tot.obj-code = buf_wth-parts.obj-code
            and tt-parts-cli-tot.ext-doc-type = buf_wth-parts.ext-doc-type
            and tt-parts-cli-tot.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
      no-error.
      if not available tt-parts-cli-tot then do:
        create tt-parts-cli-tot.
        assign tt-parts-cli-tot.cli-type = v-cli-type
              tt-parts-cli-tot.cli-code  = v-cli-code
              tt-parts-cli-tot.obj-type  = buf_wth-parts.obj-type
              tt-parts-cli-tot.obj-code  = buf_wth-parts.obj-code
              tt-parts-cli-tot.doc-code  = buf_wth-parts.out-code
              tt-parts-cli-tot.host-code = buf_wth-parts.host-code
              tt-parts-cli-tot.ext-doc-type = buf_wth-parts.ext-doc-type
              tt-parts-cli-tot.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
        .
      end.
      if buf-arh_wth-doc.doc-type = 'при':U
      or buf-arh_wth-doc.doc-type = 'возврат':U
      or (buf-arh_wth-doc.doc-type = 'обмен':U and buf_wth-parts.type = 'при':U )
      then
      assign tt-parts-cli-tot.in-qnty     = tt-parts-cli-tot.in-qnty     + buf_wth-parts.fact-qnty
            tt-parts-cli-tot.in-sum-rubl = tt-parts-cli-tot.in-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
            tt-parts-cli-tot.in-sum-base = tt-parts-cli-tot.in-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base .
      else   assign tt-parts-cli-tot.out-qnty = tt-parts-cli-tot.out-qnty  + buf_wth-parts.fact-qnty
            tt-parts-cli-tot.out-sum-rubl = tt-parts-cli-tot.out-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
            tt-parts-cli-tot.out-sum-base = tt-parts-cli-tot.out-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base  .
    end.
  end.
  if par-lock then do:
    for each tt-parts-tot:
      find last   buf-arh-wth-tot exclusive-lock  where
                  buf-arh-wth-tot.wth-code =  tt-parts-tot.wth-code
              and buf-arh-wth-tot.par-code =  tt-parts-tot.par-code
              and buf-arh-wth-tot.obj-type = tt-parts-tot.obj-type
              and buf-arh-wth-tot.obj-code = tt-parts-tot.obj-code
              and buf-arh-wth-tot.ext-doc-type = tt-parts-tot.ext-doc-type
              and buf-arh-wth-tot.sum-type = tt-parts-tot.sum-type     no-error.
      if not available buf-arh-wth-tot then do:
        create buf-arh-wth-tot.
        buffer-copy tt-parts-tot using
                    wth-code
                    par-code
                    gds-code
                    obj-type
                    obj-code
                    w-p-code
                    sum-type
                    ext-doc-type
        to buf-arh-wth-tot.
      end.
    end.
    for each tt-parts-wp:
      find last   buf-arh-wth-wp exclusive-lock  where
                  buf-arh-wth-wp.wth-code =  tt-parts-wp.wth-code
              and buf-arh-wth-wp.par-code =  tt-parts-wp.par-code
              and buf-arh-wth-wp.obj-type = tt-parts-wp.obj-type
              and buf-arh-wth-wp.obj-code = tt-parts-wp.obj-code
              and buf-arh-wth-wp.w-p-code = tt-parts-wp.w-p-code
              and buf-arh-wth-wp.out-code = tt-parts-wp.out-code     no-error.
      if not available buf-arh-wth-wp then do:
        create buf-arh-wth-wp.
        buffer-copy tt-parts-wp using
                    wth-code
                    par-code
                    gds-code
                    obj-type
                    obj-code
                    w-p-code
                    doc-code
                    out-code
                    ext-doc-type
        to buf-arh-wth-wp.
      end.
    end.
    for each tt-parts-cli:
      find last  buf-arh-wth-cli exclusive-lock where
                 buf-arh-wth-cli.wth-code =  tt-parts-cli.wth-code
            and  buf-arh-wth-cli.par-code =  tt-parts-cli.par-code
            and  buf-arh-wth-cli.ser-code =  tt-parts-cli.ser-code
            and  buf-arh-wth-cli.db-num   =  tt-parts-cli.db-num
            and  buf-arh-wth-cli.cli-type =  tt-parts-cli.cli-type
            and  buf-arh-wth-cli.cli-code =  tt-parts-cli.cli-code
            and  buf-arh-wth-cli.obj-type =  tt-parts-cli.obj-type
            and  buf-arh-wth-cli.obj-code =  tt-parts-cli.obj-code
            and  buf-arh-wth-cli.sum-type = tt-parts-cli.sum-type
            and  buf-arh-wth-cli.ext-doc-type =  tt-parts-cli.ext-doc-type
            and  buf-arh-wth-cli.gds-code =  tt-parts-cli.gds-code
             no-error.
      if not available buf-arh-wth-cli then do:
        create buf-arh-wth-cli.
        buffer-copy tt-parts-cli using wth-code
                                       sum-type
                                       par-code
                                       ser-code
                                       db-num
                                       cli-type
                                       cli-code
                                       obj-type
                                       obj-code
                                       ext-doc-type
                                       gds-code to buf-arh-wth-cli.
      end.
    end.
    for each tt-parts-cli-doc:
      find last buf-arh-wth-cli-doc exclusive-lock  where
                 buf-arh-wth-cli-doc.wth-code = tt-parts-cli-doc.wth-code
            and  buf-arh-wth-cli-doc.par-code = tt-parts-cli-doc.par-code
            and  buf-arh-wth-cli-doc.cli-type = tt-parts-cli-doc.cli-type
            and  buf-arh-wth-cli-doc.cli-code = tt-parts-cli-doc.cli-code
            and  buf-arh-wth-cli-doc.host-code     = tt-parts-cli-doc.host-code
            and  buf-arh-wth-cli-doc.contract-code = tt-parts-cli-doc.contract-code
            and  buf-arh-wth-cli-doc.gds-code      = tt-parts-cli-doc.gds-code
            and  buf-arh-wth-cli-doc.obj-type      = tt-parts-cli-doc.obj-type
            and  buf-arh-wth-cli-doc.obj-code      = tt-parts-cli-doc.obj-code
            and  buf-arh-wth-cli-doc.w-p-code      = tt-parts-cli-doc.w-p-code
            and  buf-arh-wth-cli-doc.sum-type      = tt-parts-cli-doc.sum-type
            and  buf-arh-wth-cli-doc.ext-doc-type  = tt-parts-cli-doc.ext-doc-type
            no-error.
      if not available buf-arh-wth-cli-doc then do:
        create buf-arh-wth-cli-doc.
        buffer-copy tt-parts-cli-doc using
                    wth-code
                    par-code
                    cli-type
                    cli-code
                    host-code
                    contract-code
                    gds-code
                    obj-type
                    obj-code
                    w-p-code
                    ext-doc-type
                    sum-type
                    to buf-arh-wth-cli-doc.
      end.
    end.
    for each tt-parts-cli-tot:
      find last  buf-arh-wth-cli-tot exclusive-lock where
                 buf-arh-wth-cli-tot.cli-type =  tt-parts-cli-tot.cli-type
            and  buf-arh-wth-cli-tot.cli-code =  tt-parts-cli-tot.cli-code
            and  buf-arh-wth-cli-tot.obj-type =  tt-parts-cli-tot.obj-type
            and  buf-arh-wth-cli-tot.obj-code =  tt-parts-cli-tot.obj-code
            and  buf-arh-wth-cli-tot.sum-type = tt-parts-cli-tot.sum-type
            and  buf-arh-wth-cli-tot.ext-doc-type =  tt-parts-cli-tot.ext-doc-type
      no-error.
      if not available buf-arh-wth-cli-tot then do:
        create buf-arh-wth-cli-tot.
        buffer-copy tt-parts-cli-tot using cli-type sum-type cli-code obj-type obj-code ext-doc-type host-code to buf-arh-wth-cli-tot.
      end.
    end.
  end.
  end.
 end procedure.
 procedure wth-arhdoc-close:
 define input parameter pardoc-code as char no-undo.
 define variable vararh-mode  as integer      no-undo.
  do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
  find first buf-arh_wth-doc where buf-arh_wth-doc.doc-code = pardoc-code no-lock no-error.
  if not available buf-arh_wth-doc then do:
    return error substitute ("Не найден документ МЦ с номером &1.", pardoc-code).
  end.
  run wth-arh-mode(input buf-arh_wth-doc.ext-doc-type
          ,input buf-arh_wth-doc.doc-code
          ,output vararh-mode).
  if buf-arh_wth-doc.status_ <> 'факт':U then do:
    return error substitute ("Документ МЦ с номером &1 не в статусе факт. Создание архивов невозможно.", pardoc-code).
  end.
  if buf-arh_wth-doc.fact-order = 0 or
    buf-arh_wth-doc.fact-order = ? then do:
    return error substitute ("В документе МЦ с номером &1 не проставлен fact-order.", buf-arh_wth-doc.doc-code).
  end.
  if  not g#news
       or (g#news and  g#db-num  = 0)
  then do:
    for each  tt-parts-tot on error undo, return error:
        find last  buf-prev_arh-wth-tot where buf-prev_arh-wth-tot.wth-code =  tt-parts-tot.wth-code
                                          and buf-prev_arh-wth-tot.par-code =  tt-parts-tot.par-code
                                          and buf-prev_arh-wth-tot.obj-type = tt-parts-tot.obj-type
                                          and buf-prev_arh-wth-tot.obj-code = tt-parts-tot.obj-code
                                          and buf-prev_arh-wth-tot.ext-doc-type = tt-parts-tot.ext-doc-type
                                          and buf-prev_arh-wth-tot.sum-type = tt-parts-tot.sum-type
                                          and buf-prev_arh-wth-tot.fact-order < buf-arh_wth-doc.fact-order
                                          no-error.
        if available buf-prev_arh-wth-tot and buf-prev_arh-wth-tot.fact-order = 0 then do:
            find first buf-arh-wth-tot where recid(buf-arh-wth-tot) = recid(buf-prev_arh-wth-tot) exclusive-lock.
        end.
        else do:
          create buf-arh-wth-tot.
          buffer-copy tt-parts-tot to buf-arh-wth-tot .
        end.
        assign  buf-arh-wth-tot.doc-code = buf-arh_wth-doc.doc-code
                buf-arh-wth-tot.fact-order = buf-arh_wth-doc.fact-order
                buf-arh-wth-tot.in-qnty     = (if available buf-prev_arh-wth-tot then buf-prev_arh-wth-tot.in-qnty  else 0)    + tt-parts-tot.in-qnty
                buf-arh-wth-tot.in-sum-rubl = (if available buf-prev_arh-wth-tot then buf-prev_arh-wth-tot.in-sum-rubl else 0) + tt-parts-tot.in-sum-rubl
                buf-arh-wth-tot.in-sum-base = (if available buf-prev_arh-wth-tot then buf-prev_arh-wth-tot.in-sum-base else 0) + tt-parts-tot.in-sum-base
                buf-arh-wth-tot.out-qnty    = (if available buf-prev_arh-wth-tot then buf-prev_arh-wth-tot.out-qnty else 0)    + tt-parts-tot.out-qnty
                buf-arh-wth-tot.out-sum-rubl = (if available buf-prev_arh-wth-tot then buf-prev_arh-wth-tot.out-sum-rubl else 0) + tt-parts-tot.out-sum-rubl
                buf-arh-wth-tot.out-sum-base = (if available buf-prev_arh-wth-tot then buf-prev_arh-wth-tot.out-sum-base else 0) + tt-parts-tot.out-sum-base
                .
        for each buf-recalc-tot where buf-recalc-tot.fact-order > buf-arh_wth-doc.fact-order
              and buf-recalc-tot.wth-code = tt-parts-tot.wth-code
              and buf-recalc-tot.par-code = tt-parts-tot.par-code
              and buf-recalc-tot.obj-type = tt-parts-tot.obj-type
              and buf-recalc-tot.obj-code = tt-parts-tot.obj-code
              and buf-recalc-tot.ext-doc-type = tt-parts-tot.ext-doc-type
              and buf-recalc-tot.sum-type = tt-parts-tot.sum-type
              on error undo, return error :
              assign buf-recalc-tot.out-qnty    = buf-recalc-tot.out-qnty     + tt-parts-tot.out-qnty
                    buf-recalc-tot.out-sum-rubl = buf-recalc-tot.out-sum-rubl + tt-parts-tot.out-sum-rubl
                    buf-recalc-tot.out-sum-base = buf-recalc-tot.out-sum-base + tt-parts-tot.out-sum-base
                    buf-recalc-tot.in-qnty      = buf-recalc-tot.in-qnty    + tt-parts-tot.in-qnty
                    buf-recalc-tot.in-sum-rubl = buf-recalc-tot.in-sum-rubl + tt-parts-tot.in-sum-rubl
                    buf-recalc-tot.in-sum-base = buf-recalc-tot.in-sum-base + tt-parts-tot.in-sum-base
                    .
        end.
     end.
     for each  tt-parts-wp on error undo, return error:
        find last  buf-prev_arh-wth-wp where buf-prev_arh-wth-wp.wth-code  = tt-parts-wp.wth-code
                                          and buf-prev_arh-wth-wp.par-code = tt-parts-wp.par-code
                                          and buf-prev_arh-wth-wp.obj-type = tt-parts-wp.obj-type
                                          and buf-prev_arh-wth-wp.obj-code = tt-parts-wp.obj-code
                                          and buf-prev_arh-wth-wp.out-code = tt-parts-wp.out-code
                                          and buf-prev_arh-wth-wp.w-p-code = tt-parts-wp.w-p-code
                                          and buf-prev_arh-wth-wp.fact-order < buf-arh_wth-doc.fact-order
                                          no-error.
        if available buf-prev_arh-wth-wp and buf-prev_arh-wth-wp.fact-order = 0 then do:
            find first buf-arh-wth-wp where recid(buf-arh-wth-wp) = recid(buf-prev_arh-wth-wp) exclusive-lock.
        end.
        else do:
          create buf-arh-wth-wp.
          buffer-copy tt-parts-wp to buf-arh-wth-wp .
        end.
        assign  buf-arh-wth-wp.doc-code = buf-arh_wth-doc.doc-code
                buf-arh-wth-wp.fact-order = buf-arh_wth-doc.fact-order
                buf-arh-wth-wp.ext-doc-type = buf-arh_wth-doc.ext-doc-type
                buf-arh-wth-wp.in-qnty     = (if available buf-prev_arh-wth-wp then buf-prev_arh-wth-wp.in-qnty  else 0)    + tt-parts-wp.in-qnty
                buf-arh-wth-wp.in-sum-rubl = (if available buf-prev_arh-wth-wp then buf-prev_arh-wth-wp.in-sum-rubl else 0) + tt-parts-wp.in-sum-rubl
                buf-arh-wth-wp.in-sum-base = (if available buf-prev_arh-wth-wp then buf-prev_arh-wth-wp.in-sum-base else 0) + tt-parts-wp.in-sum-base
                buf-arh-wth-wp.out-qnty    = (if available buf-prev_arh-wth-wp then buf-prev_arh-wth-wp.out-qnty else 0)    + tt-parts-wp.out-qnty
                buf-arh-wth-wp.out-sum-rubl = (if available buf-prev_arh-wth-wp then buf-prev_arh-wth-wp.out-sum-rubl else 0) + tt-parts-wp.out-sum-rubl
                buf-arh-wth-wp.out-sum-base = (if available buf-prev_arh-wth-wp then buf-prev_arh-wth-wp.out-sum-base else 0) + tt-parts-wp.out-sum-base
                .
        for each buf-recalc-wp where buf-recalc-wp.fact-order > buf-arh_wth-doc.fact-order
              and buf-recalc-wp.wth-code = tt-parts-wp.wth-code
              and buf-recalc-wp.par-code = tt-parts-wp.par-code
              and buf-recalc-wp.obj-type = tt-parts-wp.obj-type
              and buf-recalc-wp.obj-code = tt-parts-wp.obj-code
              and buf-recalc-wp.out-code = tt-parts-wp.out-code
              and buf-recalc-wp.w-p-code = tt-parts-wp.w-p-code
              and buf-recalc-wp.sum-type = tt-parts-wp.sum-type
              on error undo, return error :
              assign buf-recalc-wp.out-qnty    = buf-recalc-wp.out-qnty     + tt-parts-wp.out-qnty
                    buf-recalc-wp.out-sum-rubl = buf-recalc-wp.out-sum-rubl + tt-parts-wp.out-sum-rubl
                    buf-recalc-wp.out-sum-base = buf-recalc-wp.out-sum-base + tt-parts-wp.out-sum-base
                    buf-recalc-wp.in-qnty      = buf-recalc-wp.in-qnty    + tt-parts-wp.in-qnty
                    buf-recalc-wp.in-sum-rubl = buf-recalc-wp.in-sum-rubl + tt-parts-wp.in-sum-rubl
                    buf-recalc-wp.in-sum-base = buf-recalc-wp.in-sum-base + tt-parts-wp.in-sum-base
                    .
        end.
     end.
  end.
  if vararh-mode = 1 then do:
    for each  tt-parts-cli on error undo, return error:
      find last  buf-prev_arh-wth-cli where  buf-prev_arh-wth-cli.wth-code =  tt-parts-cli.wth-code
                                        and  buf-prev_arh-wth-cli.par-code =  tt-parts-cli.par-code
                                        and  buf-prev_arh-wth-cli.ser-code =  tt-parts-cli.ser-code
                                        and  buf-prev_arh-wth-cli.db-num   =  tt-parts-cli.db-num
                                        and  buf-prev_arh-wth-cli.cli-type =  tt-parts-cli.cli-type
                                        and  buf-prev_arh-wth-cli.cli-code =  tt-parts-cli.cli-code
                                        and  buf-prev_arh-wth-cli.obj-type =  tt-parts-cli.obj-type
                                        and  buf-prev_arh-wth-cli.obj-code =  tt-parts-cli.obj-code
                                        and  buf-prev_arh-wth-cli.ext-doc-type =  tt-parts-cli.ext-doc-type
                                        and  buf-prev_arh-wth-cli.gds-code =  tt-parts-cli.gds-code
                                        and  buf-prev_arh-wth-cli.sum-type = tt-parts-cli.sum-type
                                        and  buf-prev_arh-wth-cli.fact-order < buf-arh_wth-doc.fact-order
                                        no-error.
      if available buf-prev_arh-wth-cli and buf-prev_arh-wth-cli.fact-order = 0 then do:
          find first buf-arh-wth-cli where recid(buf-arh-wth-cli) = recid(buf-prev_arh-wth-cli) exclusive-lock.
      end.
      else do:
        create buf-arh-wth-cli.
        buffer-copy tt-parts-cli to buf-arh-wth-cli .
      end.
      assign  buf-arh-wth-cli.doc-code   = buf-arh_wth-doc.doc-code
              buf-arh-wth-cli.fact-order = buf-arh_wth-doc.fact-order
      .
      if available buf-prev_arh-wth-cli then do:
        assign buf-arh-wth-cli.out-qnty =  buf-prev_arh-wth-cli.out-qnty  + tt-parts-cli.out-qnty
               buf-arh-wth-cli.out-sum-rubl = buf-prev_arh-wth-cli.out-sum-rubl + tt-parts-cli.out-sum-rubl
               buf-arh-wth-cli.out-sum-base = buf-prev_arh-wth-cli.out-sum-base + tt-parts-cli.out-sum-base
               buf-arh-wth-cli.in-qnty = buf-prev_arh-wth-cli.in-qnty + tt-parts-cli.in-qnty
               buf-arh-wth-cli.in-sum-rubl = buf-prev_arh-wth-cli.in-sum-rubl + tt-parts-cli.in-sum-rubl
               buf-arh-wth-cli.in-sum-base = buf-prev_arh-wth-cli.in-sum-base + tt-parts-cli.in-sum-base
               .
      end.
      else do:
        assign buf-arh-wth-cli.out-qnty =  tt-parts-cli.out-qnty
               buf-arh-wth-cli.out-sum-rubl = tt-parts-cli.out-sum-rubl
               buf-arh-wth-cli.out-sum-base = tt-parts-cli.out-sum-base
               buf-arh-wth-cli.in-qnty =  tt-parts-cli.in-qnty
               buf-arh-wth-cli.in-sum-rubl =  tt-parts-cli.in-sum-rubl
               buf-arh-wth-cli.in-sum-base =  tt-parts-cli.in-sum-base
               .
      end.
      for each buf-recalc-cli where buf-recalc-cli.fact-order > buf-arh_wth-doc.fact-order
            and buf-recalc-cli.wth-code = tt-parts-cli.wth-code
            and buf-recalc-cli.par-code = tt-parts-cli.par-code
            and buf-recalc-cli.ser-code = tt-parts-cli.ser-code
            and buf-recalc-cli.db-num   = tt-parts-cli.db-num
            and buf-recalc-cli.cli-type = tt-parts-cli.cli-type
            and buf-recalc-cli.cli-code = tt-parts-cli.cli-code
            and buf-recalc-cli.obj-type = tt-parts-cli.obj-type
            and buf-recalc-cli.obj-code = tt-parts-cli.obj-code
            and buf-recalc-cli.ext-doc-type = tt-parts-cli.ext-doc-type
            and buf-recalc-cli.sum-type = tt-parts-cli.sum-type
            and buf-recalc-cli.gds-code = tt-parts-cli.gds-code
            on error undo, return error:
            assign buf-recalc-cli.out-qnty     = buf-recalc-cli.out-qnty + tt-parts-cli.out-qnty
                  buf-recalc-cli.out-sum-rubl = buf-recalc-cli.out-sum-rubl + tt-parts-cli.out-sum-rubl
                  buf-recalc-cli.out-sum-base = buf-recalc-cli.out-sum-base + tt-parts-cli.out-sum-base
                  buf-recalc-cli.in-qnty       = buf-recalc-cli.in-qnty + tt-parts-cli.in-qnty
                  buf-recalc-cli.in-sum-rubl  = buf-recalc-cli.in-sum-rubl + tt-parts-cli.in-sum-rubl
                  buf-recalc-cli.in-sum-base  = buf-recalc-cli.in-sum-base + tt-parts-cli.in-sum-base
              .
      end.
    end.
    for each  tt-parts-cli-doc on error undo, return error:
      find last buf-prev_arh-wth-cli-doc where buf-prev_arh-wth-cli-doc.wth-code =  tt-parts-cli-doc.wth-code
                                        and  buf-prev_arh-wth-cli-doc.par-code = tt-parts-cli-doc.par-code
                                        and  buf-prev_arh-wth-cli-doc.cli-type = tt-parts-cli-doc.cli-type
                                        and  buf-prev_arh-wth-cli-doc.cli-code = tt-parts-cli-doc.cli-code
                                        and  buf-prev_arh-wth-cli-doc.host-code     = tt-parts-cli-doc.host-code
                                        and  buf-prev_arh-wth-cli-doc.contract-code = tt-parts-cli-doc.contract-code
                                        and  buf-prev_arh-wth-cli-doc.gds-code      = tt-parts-cli-doc.gds-code
                                        and  buf-prev_arh-wth-cli-doc.obj-type      = tt-parts-cli-doc.obj-type
                                        and  buf-prev_arh-wth-cli-doc.obj-code      = tt-parts-cli-doc.obj-code
                                        and  buf-prev_arh-wth-cli-doc.w-p-code      = tt-parts-cli-doc.w-p-code
                                        and  buf-prev_arh-wth-cli-doc.ext-doc-type  = tt-parts-cli-doc.ext-doc-type
                                        and  buf-prev_arh-wth-cli-doc.sum-type = tt-parts-cli-doc.sum-type
                                        and  buf-prev_arh-wth-cli-doc.fact-order < buf-arh_wth-doc.fact-order
                                        no-error.
      if available buf-prev_arh-wth-cli-doc and buf-prev_arh-wth-cli-doc.fact-order = 0 then do:
          find first buf-arh-wth-cli-doc where recid(buf-arh-wth-cli-doc) = recid(buf-prev_arh-wth-cli-doc) exclusive-lock.
      end.
      else do:
        create buf-arh-wth-cli-doc.
        buffer-copy tt-parts-cli-doc to buf-arh-wth-cli-doc .
      end.
      assign  buf-arh-wth-cli-doc.doc-code = buf-arh_wth-doc.doc-code
              buf-arh-wth-cli-doc.fact-order = buf-arh_wth-doc.fact-order
      .
      if available buf-prev_arh-wth-cli-doc then
        assign buf-arh-wth-cli-doc.out-qnty = buf-prev_arh-wth-cli-doc.out-qnty + tt-parts-cli-doc.out-qnty
               buf-arh-wth-cli-doc.out-sum-rubl = buf-prev_arh-wth-cli-doc.out-sum-rubl + tt-parts-cli-doc.out-sum-rubl
               buf-arh-wth-cli-doc.out-sum-base = buf-prev_arh-wth-cli-doc.out-sum-base + tt-parts-cli-doc.out-sum-base
               buf-arh-wth-cli-doc.in-qnty = buf-prev_arh-wth-cli-doc.in-qnty + tt-parts-cli-doc.in-qnty
               buf-arh-wth-cli-doc.in-sum-rubl = buf-prev_arh-wth-cli-doc.in-sum-rubl + tt-parts-cli-doc.in-sum-rubl
               buf-arh-wth-cli-doc.in-sum-base = buf-prev_arh-wth-cli-doc.in-sum-base + tt-parts-cli-doc.in-sum-base
               .
      else  assign buf-arh-wth-cli-doc.out-qnty =  tt-parts-cli-doc.out-qnty
               buf-arh-wth-cli-doc.out-sum-rubl =  tt-parts-cli-doc.out-sum-rubl
               buf-arh-wth-cli-doc.out-sum-base =  tt-parts-cli-doc.out-sum-base
               buf-arh-wth-cli-doc.in-qnty =  tt-parts-cli-doc.in-qnty
               buf-arh-wth-cli-doc.in-sum-rubl =  tt-parts-cli-doc.in-sum-rubl
               buf-arh-wth-cli-doc.in-sum-base =  tt-parts-cli-doc.in-sum-base
               .
      for each  buf-recalc-cli-doc where buf-recalc-cli-doc.fact-order > buf-arh_wth-doc.fact-order
            and buf-recalc-cli-doc.wth-code = tt-parts-cli-doc.wth-code
            and buf-recalc-cli-doc.par-code = tt-parts-cli-doc.par-code
            and buf-recalc-cli-doc.cli-type = tt-parts-cli-doc.cli-type
            and buf-recalc-cli-doc.cli-code = tt-parts-cli-doc.cli-code
            and buf-recalc-cli-doc.host-code     = tt-parts-cli-doc.host-code
            and buf-recalc-cli-doc.contract-code = tt-parts-cli-doc.contract-code
            and buf-recalc-cli-doc.gds-code      = tt-parts-cli-doc.gds-code
            and buf-recalc-cli-doc.obj-type      = tt-parts-cli-doc.obj-type
            and buf-recalc-cli-doc.obj-code      = tt-parts-cli-doc.obj-code
            and buf-recalc-cli-doc.w-p-code      = tt-parts-cli-doc.w-p-code
            and buf-recalc-cli-doc.sum-type      = tt-parts-cli-doc.sum-type
            and buf-recalc-cli-doc.ext-doc-type  = tt-parts-cli-doc.ext-doc-type
            on error undo, return error:
            assign buf-recalc-cli-doc.out-qnty     = buf-recalc-cli-doc.out-qnty + tt-parts-cli-doc.out-qnty
                  buf-recalc-cli-doc.out-sum-rubl = buf-recalc-cli-doc.out-sum-rubl + tt-parts-cli-doc.out-sum-rubl
                  buf-recalc-cli-doc.out-sum-base = buf-recalc-cli-doc.out-sum-base + tt-parts-cli-doc.out-sum-base
                  buf-recalc-cli-doc.in-qnty       = buf-recalc-cli-doc.in-qnty + tt-parts-cli-doc.in-qnty
                  buf-recalc-cli-doc.in-sum-rubl = buf-recalc-cli-doc.in-sum-rubl + tt-parts-cli-doc.in-sum-rubl
                  buf-recalc-cli-doc.in-sum-base = buf-recalc-cli-doc.in-sum-base + tt-parts-cli-doc.in-sum-base
                  .
      end.
    end.
    for each  tt-parts-cli-tot on error undo, return error:
      find last  buf-prev_arh-wth-cli-tot where buf-prev_arh-wth-cli-tot.cli-type =  tt-parts-cli-tot.cli-type
                                        and  buf-prev_arh-wth-cli-tot.cli-code =  tt-parts-cli-tot.cli-code
                                        and  buf-prev_arh-wth-cli-tot.obj-type =  tt-parts-cli-tot.obj-type
                                        and  buf-prev_arh-wth-cli-tot.obj-code =  tt-parts-cli-tot.obj-code
                                        and  buf-prev_arh-wth-cli-tot.ext-doc-type =  tt-parts-cli-tot.ext-doc-type
                                        and  buf-prev_arh-wth-cli-tot.sum-type     = tt-parts-cli-tot.sum-type
                                        and  buf-prev_arh-wth-cli-tot.fact-order < buf-arh_wth-doc.fact-order
                                        no-error.
      if available buf-prev_arh-wth-cli-tot and buf-prev_arh-wth-cli-tot.fact-order = 0 then do:
          find first buf-arh-wth-cli-tot where recid(buf-arh-wth-cli-tot) = recid(buf-prev_arh-wth-cli-tot) exclusive-lock.
      end.
      else do:
        create buf-arh-wth-cli-tot.
        buffer-copy tt-parts-cli-tot to buf-arh-wth-cli-tot .
      end.
      assign  buf-arh-wth-cli-tot.doc-code   = buf-arh_wth-doc.doc-code
              buf-arh-wth-cli-tot.fact-order = buf-arh_wth-doc.fact-order
      .
      if available buf-prev_arh-wth-cli-tot then
        assign buf-arh-wth-cli-tot.out-qnty = buf-prev_arh-wth-cli-tot.out-qnty + tt-parts-cli-tot.out-qnty
               buf-arh-wth-cli-tot.out-sum-rubl = buf-prev_arh-wth-cli-tot.out-sum-rubl + tt-parts-cli-tot.out-sum-rubl
               buf-arh-wth-cli-tot.out-sum-base = buf-prev_arh-wth-cli-tot.out-sum-base + tt-parts-cli-tot.out-sum-base
               buf-arh-wth-cli-tot.in-qnty = buf-prev_arh-wth-cli-tot.in-qnty + tt-parts-cli-tot.in-qnty
               buf-arh-wth-cli-tot.in-sum-rubl = buf-prev_arh-wth-cli-tot.in-sum-rubl + tt-parts-cli-tot.in-sum-rubl
               buf-arh-wth-cli-tot.in-sum-base = buf-prev_arh-wth-cli-tot.in-sum-base + tt-parts-cli-tot.in-sum-base
               .
      else  assign buf-arh-wth-cli-tot.out-qnty =  tt-parts-cli-tot.out-qnty
               buf-arh-wth-cli-tot.out-sum-rubl =  tt-parts-cli-tot.out-sum-rubl
               buf-arh-wth-cli-tot.out-sum-base =  tt-parts-cli-tot.out-sum-base
               buf-arh-wth-cli-tot.in-qnty =  tt-parts-cli-tot.in-qnty
               buf-arh-wth-cli-tot.in-sum-rubl =  tt-parts-cli-tot.in-sum-rubl
               buf-arh-wth-cli-tot.in-sum-base =  tt-parts-cli-tot.in-sum-base
               .
      for each buf-recalc-cli-tot where buf-recalc-cli-tot.fact-order > buf-arh_wth-doc.fact-order
            and buf-recalc-cli-tot.cli-type = tt-parts-cli-tot.cli-type
            and buf-recalc-cli-tot.cli-code = tt-parts-cli-tot.cli-code
            and buf-recalc-cli-tot.obj-type = tt-parts-cli-tot.obj-type
            and buf-recalc-cli-tot.obj-code = tt-parts-cli-tot.obj-code
            and buf-recalc-cli-tot.ext-doc-type = tt-parts-cli-tot.ext-doc-type
            and buf-recalc-cli-tot.sum-type     = tt-parts-cli-tot.sum-type
            on error undo, return error
            :
            assign buf-recalc-cli-tot.out-qnty     = buf-recalc-cli-tot.out-qnty + tt-parts-cli-tot.out-qnty
                  buf-recalc-cli-tot.out-sum-rubl = buf-recalc-cli-tot.out-sum-rubl + tt-parts-cli-tot.out-sum-rubl
                  buf-recalc-cli-tot.out-sum-base = buf-recalc-cli-tot.out-sum-base + tt-parts-cli-tot.out-sum-base
                  buf-recalc-cli-tot.in-qnty       = buf-recalc-cli-tot.in-qnty + tt-parts-cli-tot.in-qnty
                  buf-recalc-cli-tot.in-sum-rubl = buf-recalc-cli-tot.in-sum-rubl + tt-parts-cli-tot.in-sum-rubl
                  buf-recalc-cli-tot.in-sum-base = buf-recalc-cli-tot.in-sum-base + tt-parts-cli-tot.in-sum-base
                  .
      end.
    end.
  end.
  end.
 end.
procedure wth-arhdoc-delete:
 define input parameter pardoc-code as char no-undo.
  do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
  find first buf-arh_wth-doc where buf-arh_wth-doc.doc-code = pardoc-code no-lock no-error.
  if not available buf-arh_wth-doc then do:
    return error substitute ("Не найден документ МЦ с номером &1.", pardoc-code).
  end.
  if buf-arh_wth-doc.status_ <> 'факт':U then do:
    return error substitute ("Документ МЦ с номером &1 не в статусе факт. Создание архивов невозможно.", pardoc-code).
  end.
  if buf-arh_wth-doc.fact-order = 0 or
    buf-arh_wth-doc.fact-order = ? then do:
    return error substitute ("В документе МЦ с номером &1 не проставлен fact-order.", buf-arh_wth-doc.doc-code).
  end.
  run wth-arh-calctt-loc(input buf-arh_wth-doc.doc-code
                        ,input no) no-error.
  if error-status:error then  return error return-value + error-status:get-message(1).
  for each  tt-parts-tot on error undo, return error return-value:
      find first  buf-arh-wth-tot where buf-arh-wth-tot.wth-code =  tt-parts-tot.wth-code
                                        and buf-arh-wth-tot.par-code =  tt-parts-tot.par-code
                                        and buf-arh-wth-tot.obj-type = tt-parts-tot.obj-type
                                        and buf-arh-wth-tot.obj-code = tt-parts-tot.obj-code
                                        and buf-arh-wth-tot.ext-doc-type = tt-parts-tot.ext-doc-type
                                        and buf-arh-wth-tot.sum-type = tt-parts-tot.sum-type
                                        and buf-arh-wth-tot.fact-order = buf-arh_wth-doc.fact-order
                                        no-error.
      if available buf-arh-wth-tot then do:
          delete buf-arh-wth-tot.
      end.
      for each buf-recalc-tot where buf-recalc-tot.fact-order > buf-arh_wth-doc.fact-order
            and buf-recalc-tot.wth-code = tt-parts-tot.wth-code
            and buf-recalc-tot.par-code = tt-parts-tot.par-code
            and buf-recalc-tot.obj-type = tt-parts-tot.obj-type
            and buf-recalc-tot.obj-code = tt-parts-tot.obj-code
            and buf-recalc-tot.ext-doc-type = tt-parts-tot.ext-doc-type
            and buf-recalc-tot.sum-type = tt-parts-tot.sum-type
             :
            assign buf-recalc-tot.out-qnty     = buf-recalc-tot.out-qnty - tt-parts-tot.out-qnty
                  buf-recalc-tot.out-sum-rubl = buf-recalc-tot.out-sum-rubl - tt-parts-tot.out-sum-rubl
                  buf-recalc-tot.out-sum-base = buf-recalc-tot.out-sum-base - tt-parts-tot.out-sum-base
                  buf-recalc-tot.in-qnty       = buf-recalc-tot.in-qnty - tt-parts-tot.in-qnty
                  buf-recalc-tot.in-sum-rubl = buf-recalc-tot.in-sum-rubl - tt-parts-tot.in-sum-rubl
                  buf-recalc-tot.in-sum-base = buf-recalc-tot.in-sum-base - tt-parts-tot.in-sum-base
                  .
      end.
  end.
  for each  tt-parts-wp on error undo, return error return-value:
      find first  buf-arh-wth-wp where buf-arh-wth-wp.wth-code =  tt-parts-wp.wth-code
                                        and buf-arh-wth-wp.par-code =  tt-parts-wp.par-code
                                        and buf-arh-wth-wp.obj-type = tt-parts-wp.obj-type
                                        and buf-arh-wth-wp.obj-code = tt-parts-wp.obj-code
                                        and buf-arh-wth-wp.out-code = tt-parts-wp.out-code
                                        and buf-arh-wth-wp.w-p-code = tt-parts-wp.w-p-code
                                        and buf-arh-wth-wp.sum-type = tt-parts-wp.sum-type
                                        and buf-arh-wth-wp.fact-order = buf-arh_wth-doc.fact-order
                                        no-error.
      if available buf-arh-wth-wp then do:
          delete buf-arh-wth-wp.
      end.
      for each buf-recalc-wp where buf-recalc-wp.fact-order > buf-arh_wth-doc.fact-order
            and buf-recalc-wp.wth-code = tt-parts-wp.wth-code
            and buf-recalc-wp.par-code = tt-parts-wp.par-code
            and buf-recalc-wp.obj-type = tt-parts-wp.obj-type
            and buf-recalc-wp.obj-code = tt-parts-wp.obj-code
            and buf-recalc-wp.out-code = tt-parts-wp.out-code
            and buf-recalc-wp.w-p-code = tt-parts-wp.w-p-code
            and buf-recalc-wp.sum-type = tt-parts-wp.sum-type
             :
            assign buf-recalc-wp.out-qnty     = buf-recalc-wp.out-qnty - tt-parts-wp.out-qnty
                  buf-recalc-wp.out-sum-rubl = buf-recalc-wp.out-sum-rubl - tt-parts-wp.out-sum-rubl
                  buf-recalc-wp.out-sum-base = buf-recalc-wp.out-sum-base - tt-parts-wp.out-sum-base
                  buf-recalc-wp.in-qnty       = buf-recalc-wp.in-qnty - tt-parts-wp.in-qnty
                  buf-recalc-wp.in-sum-rubl = buf-recalc-wp.in-sum-rubl - tt-parts-wp.in-sum-rubl
                  buf-recalc-wp.in-sum-base = buf-recalc-wp.in-sum-base - tt-parts-wp.in-sum-base
                  .
      end.
  end.
  for each  tt-parts-cli:
    find last  buf-arh-wth-cli where  buf-arh-wth-cli.wth-code =  tt-parts-cli.wth-code
                                      and  buf-arh-wth-cli.par-code =  tt-parts-cli.par-code
                                      and  buf-arh-wth-cli.cli-type =  tt-parts-cli.cli-type
                                      and  buf-arh-wth-cli.ser-code =  tt-parts-cli.ser-code
                                      and  buf-arh-wth-cli.db-num   =  tt-parts-cli.db-num
                                      and  buf-arh-wth-cli.cli-code =  tt-parts-cli.cli-code
                                      and  buf-arh-wth-cli.obj-type =  tt-parts-cli.obj-type
                                      and  buf-arh-wth-cli.obj-code =  tt-parts-cli.obj-code
                                      and  buf-arh-wth-cli.ext-doc-type =  tt-parts-cli.ext-doc-type
                                      and buf-arh-wth-cli.sum-type = tt-parts-cli.sum-type
                                      and  buf-arh-wth-cli.gds-code =  tt-parts-cli.gds-code
                                      and  buf-arh-wth-cli.fact-order = buf-arh_wth-doc.fact-order
                                      no-error.
    if available buf-arh-wth-cli then do:
        delete buf-arh-wth-cli.
    end.
    for each buf-recalc-cli where buf-recalc-cli.fact-order > buf-arh_wth-doc.fact-order
          and buf-recalc-cli.wth-code = tt-parts-cli.wth-code
          and buf-recalc-cli.par-code = tt-parts-cli.par-code
          and buf-recalc-cli.ser-code = tt-parts-cli.ser-code
          and buf-recalc-cli.db-num   = tt-parts-cli.db-num
          and buf-recalc-cli.cli-type = tt-parts-cli.cli-type
          and buf-recalc-cli.cli-code = tt-parts-cli.cli-code
          and buf-recalc-cli.obj-type = tt-parts-cli.obj-type
          and buf-recalc-cli.obj-code = tt-parts-cli.obj-code
          and buf-recalc-cli.ext-doc-type = tt-parts-cli.ext-doc-type
          and buf-recalc-cli.sum-type = tt-parts-cli.sum-type
          and buf-recalc-cli.gds-code = tt-parts-cli.gds-code:
          assign buf-recalc-cli.out-qnty     = buf-recalc-cli.out-qnty - tt-parts-cli.out-qnty
                buf-recalc-cli.out-sum-rubl = buf-recalc-cli.out-sum-rubl - tt-parts-cli.out-sum-rubl
                buf-recalc-cli.out-sum-base = buf-recalc-cli.out-sum-base - tt-parts-cli.out-sum-base
                buf-recalc-cli.in-qnty       = buf-recalc-cli.in-qnty - tt-parts-cli.in-qnty
                buf-recalc-cli.in-sum-rubl = buf-recalc-cli.in-sum-rubl - tt-parts-cli.in-sum-rubl
                buf-recalc-cli.in-sum-base = buf-recalc-cli.in-sum-base - tt-parts-cli.in-sum-base
                .
    end.
  end.
  for each  tt-parts-cli-doc:
    find last  buf-arh-wth-cli-doc where  buf-arh-wth-cli-doc.wth-code =  tt-parts-cli-doc.wth-code
                                      and  buf-arh-wth-cli-doc.par-code = tt-parts-cli-doc.par-code
                                      and  buf-arh-wth-cli-doc.cli-type = tt-parts-cli-doc.cli-type
                                      and  buf-arh-wth-cli-doc.cli-code = tt-parts-cli-doc.cli-code
                                      and  buf-arh-wth-cli-doc.host-code     = tt-parts-cli-doc.host-code
                                      and  buf-arh-wth-cli-doc.contract-code = tt-parts-cli-doc.contract-code
                                      and  buf-arh-wth-cli-doc.gds-code      = tt-parts-cli-doc.gds-code
                                      and  buf-arh-wth-cli-doc.obj-type      = tt-parts-cli-doc.obj-type
                                      and  buf-arh-wth-cli-doc.obj-code      = tt-parts-cli-doc.obj-code
                                      and  buf-arh-wth-cli-doc.w-p-code      = tt-parts-cli-doc.w-p-code
                                      and  buf-arh-wth-cli-doc.ext-doc-type  = tt-parts-cli-doc.ext-doc-type
                                      and buf-arh-wth-cli-doc.sum-type = tt-parts-cli-doc.sum-type
                                      and  buf-arh-wth-cli-doc.fact-order < buf-arh_wth-doc.fact-order
                                      no-error.
    if available  buf-arh-wth-cli-doc then do:
      delete buf-arh-wth-cli-doc.
    end.
    for each  buf-recalc-cli-doc where buf-recalc-cli-doc.fact-order > buf-arh_wth-doc.fact-order
          and buf-recalc-cli-doc.wth-code = tt-parts-cli-doc.wth-code
          and buf-recalc-cli-doc.par-code = tt-parts-cli-doc.par-code
          and buf-recalc-cli-doc.cli-type = tt-parts-cli-doc.cli-type
          and buf-recalc-cli-doc.cli-code = tt-parts-cli-doc.cli-code
          and buf-recalc-cli-doc.host-code     = tt-parts-cli-doc.host-code
          and buf-recalc-cli-doc.contract-code = tt-parts-cli-doc.contract-code
          and buf-recalc-cli-doc.gds-code      = tt-parts-cli-doc.gds-code
          and buf-recalc-cli-doc.obj-type      = tt-parts-cli-doc.obj-type
          and buf-recalc-cli-doc.obj-code      = tt-parts-cli-doc.obj-code
          and buf-recalc-cli-doc.w-p-code      = tt-parts-cli-doc.w-p-code
          and buf-recalc-cli-doc.sum-type      = tt-parts-cli-doc.sum-type
          and buf-recalc-cli-doc.ext-doc-type  = tt-parts-cli-doc.ext-doc-type:
          assign buf-recalc-cli-doc.out-qnty     = buf-recalc-cli-doc.out-qnty - tt-parts-cli-doc.out-qnty
                buf-recalc-cli-doc.out-sum-rubl = buf-recalc-cli-doc.out-sum-rubl - tt-parts-cli-doc.out-sum-rubl
                buf-recalc-cli-doc.out-sum-base = buf-recalc-cli-doc.out-sum-base - tt-parts-cli-doc.out-sum-base
                buf-recalc-cli-doc.in-qnty       = buf-recalc-cli-doc.in-qnty - tt-parts-cli-doc.in-qnty
                buf-recalc-cli-doc.in-sum-rubl  = buf-recalc-cli-doc.in-sum-rubl - tt-parts-cli-doc.in-sum-rubl
                buf-recalc-cli-doc.in-sum-base  = buf-recalc-cli-doc.in-sum-base - tt-parts-cli-doc.in-sum-base
                .
    end.
  end.
  for each  tt-parts-cli-tot:
    find last  buf-arh-wth-cli-tot where   buf-arh-wth-cli-tot.cli-type =  tt-parts-cli-tot.cli-type
                                      and  buf-arh-wth-cli-tot.cli-code =  tt-parts-cli-tot.cli-code
                                      and  buf-arh-wth-cli-tot.obj-type =  tt-parts-cli-tot.obj-type
                                      and  buf-arh-wth-cli-tot.obj-code =  tt-parts-cli-tot.obj-code
                                      and  buf-arh-wth-cli-tot.ext-doc-type =  tt-parts-cli-tot.ext-doc-type
                                      and  buf-arh-wth-cli-tot.sum-type = tt-parts-cli-tot.sum-type
                                      and  buf-arh-wth-cli-tot.fact-order = buf-arh_wth-doc.fact-order
                                      no-error.
    if available buf-arh-wth-cli-tot then do:
        delete buf-arh-wth-cli-tot.
    end.
    for each buf-recalc-cli-tot where buf-recalc-cli-tot.fact-order > buf-arh_wth-doc.fact-order
          and buf-recalc-cli-tot.cli-type = tt-parts-cli-tot.cli-type
          and buf-recalc-cli-tot.cli-code = tt-parts-cli-tot.cli-code
          and buf-recalc-cli-tot.obj-type = tt-parts-cli-tot.obj-type
          and buf-recalc-cli-tot.obj-code = tt-parts-cli-tot.obj-code
          and buf-recalc-cli-tot.sum-type = tt-parts-cli-tot.sum-type
          and buf-recalc-cli-tot.ext-doc-type = tt-parts-cli-tot.ext-doc-type
          :
          assign buf-recalc-cli-tot.out-qnty     = buf-recalc-cli-tot.out-qnty - tt-parts-cli-tot.out-qnty
                buf-recalc-cli-tot.out-sum-rubl = buf-recalc-cli-tot.out-sum-rubl - tt-parts-cli-tot.out-sum-rubl
                buf-recalc-cli-tot.out-sum-base = buf-recalc-cli-tot.out-sum-base - tt-parts-cli-tot.out-sum-base
                buf-recalc-cli-tot.in-qnty       = buf-recalc-cli-tot.in-qnty - tt-parts-cli-tot.in-qnty
                buf-recalc-cli-tot.in-sum-rubl = buf-recalc-cli-tot.in-sum-rubl - tt-parts-cli-tot.in-sum-rubl
                buf-recalc-cli-tot.in-sum-base = buf-recalc-cli-tot.in-sum-base - tt-parts-cli-tot.in-sum-base
                .
    end.
  end.
end.
end procedure.
define variable varhost-code like ub.store.host-code no-undo.
def var i as int.
def buffer buf_wth-doc for ub.wth-doc.
def var fact-order-from like ub.wth-doc.fact-order.
find first ub.clients where ub.clients.obj-type = parobj-type and
                         ub.clients.obj-code = parobj-code no-lock no-error.
if not available ub.clients then do:
   message "Нет такого объекта " ub.clients.obj-type " " ub.clients.obj-code
   view-as alert-box error.
   return error.
end.
if ub.clients.obj-type = 'скл':U then do:
   find first ub.store where ub.store.obj-code = ub.clients.obj-code no-lock.
   assign varhost-code = ub.store.host-code.
end.
else do:
   if ub.clients.obj-type = 'маг':U then do:
      find first ub.shop where ub.shop.obj-code = ub.clients.obj-code no-lock.
      assign varhost-code = ub.shop.host-code.
   end.
   else do:
        message "Недопустимый тип объекта пересчета " ub.clients.obj-type
        view-as alert-box error.
        return error.
   end.
end.
run waitfram-show in this-procedure ("").
tr:
do transaction on error undo tr, return error:
run waitfram-show in this-procedure ("Очищаем остатки").
for each        buf_wth-doc where
buf_wth-doc.obj-type = parobj-type and
buf_wth-doc.obj-code = parobj-code and
buf_wth-doc.fact-date <   par-date by buf_wth-doc.fact-order desc:
    fact-order-from =   buf_wth-doc.fact-order.
    leave.
end.
if fact-order-from = 0 then
for each        buf_wth-doc where
buf_wth-doc.obj-type = parobj-type and
buf_wth-doc.obj-code = parobj-code and
buf_wth-doc.fact-date >=   par-date by buf_wth-doc.fact-order:
    fact-order-from =   buf_wth-doc.fact-order.
    leave.
end.
for each ub.arh-wth-tot where ub.arh-wth-tot.obj-type = parobj-type and
  ub.arh-wth-tot.obj-code = parobj-code and
  ub.arh-wth-tot.fact-order >  fact-order-from:
   delete ub.arh-wth-tot.
end.
for each ub.arh-wth-cli where ub.arh-wth-cli.obj-type = parobj-type and
  ub.arh-wth-cli.obj-code = parobj-code and
  ub.arh-wth-cli.fact-order >  fact-order-from:
   delete ub.arh-wth-cli.
end.
for each ub.arh-wth-cli-doc where ub.arh-wth-cli-doc.obj-type = parobj-type and
  ub.arh-wth-cli-doc.obj-code = parobj-code and
  ub.arh-wth-cli-doc.fact-order >  fact-order-from:
   delete ub.arh-wth-cli-doc.
end.
for each ub.arh-wth-cli-tot where ub.arh-wth-cli-tot.obj-type = parobj-type and
  ub.arh-wth-cli-tot.obj-code = parobj-code and
  ub.arh-wth-cli-tot.fact-order >  fact-order-from:
   delete ub.arh-wth-cli-tot.
end.
for each ub.arh-wth-w-p where ub.arh-wth-w-p.obj-type = parobj-type and
  ub.arh-wth-w-p.obj-code = parobj-code and
  ub.arh-wth-w-p.fact-order >  fact-order-from:
   delete ub.arh-wth-w-p.
end.
for each ub.arh-wth-tot-attr where ub.arh-wth-tot-attr.obj-type = parobj-type and
  ub.arh-wth-tot-attr.obj-code = parobj-code and
  ub.arh-wth-tot-attr.fact-order >  fact-order-from:
   delete ub.arh-wth-tot-attr.
end.
for each ub.arh-wth-cli-attr where ub.arh-wth-cli-attr.obj-type = parobj-type and
  ub.arh-wth-cli-attr.obj-code = parobj-code and
  ub.arh-wth-cli-attr.fact-order >  fact-order-from:
   delete ub.arh-wth-cli-attr.
end.
for each ub.arh-wth-cli-doc-attr where ub.arh-wth-cli-doc-attr.obj-type = parobj-type and
  ub.arh-wth-cli-doc-attr.obj-code = parobj-code and
  ub.arh-wth-cli-doc-attr.fact-order >  fact-order-from:
   delete ub.arh-wth-cli-doc-attr.
end.
for each ub.arh-wth-cli-tot-attr where ub.arh-wth-cli-tot-attr.obj-type = parobj-type and
  ub.arh-wth-cli-tot-attr.obj-code = parobj-code and
  ub.arh-wth-cli-tot-attr.fact-order >  fact-order-from:
   delete ub.arh-wth-cli-tot-attr.
end.
for each ub.arh-wth-w-p-attr where ub.arh-wth-w-p-attr.obj-type = parobj-type and
  ub.arh-wth-w-p-attr.obj-code = parobj-code and
  ub.arh-wth-w-p-attr.fact-order >  fact-order-from:
   delete ub.arh-wth-w-p-attr.
end.
for each ub.wth-doc where ub.wth-doc.host-code = varhost-code and
                       ub.wth-doc.obj-type  = parobj-type  and
                       ub.wth-doc.obj-code  = parobj-code  and
                       ub.wth-doc.status_   = 'факт':U  and
                       ub.wth-doc.fact-order > fact-order-from
                       USE-INDEX stat-fact:
    run waitfram-show in this-procedure ("Пересчитываем архивы по документу " + ub.wth-doc.doc-code + " .").
        run wth-arh-calctt-loc(input ub.wth-doc.doc-code
                          ,input yes) no-error.
        if error-status:error then undo tr, return error return-value + error-status:get-message(1).
    run wth-arhdoc-close(input ub.wth-doc.doc-code) no-error.
        if error-status:error then undo tr, return error return-value + error-status:get-message(1).
end.
end.
