DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE BUFFER locked_icnt-doc FOR ub.icnt-doc.
DEFINE BUFFER locked_icnt-line FOR ub.icnt-line.
DEFINE TEMP-TABLE tt-icnt-doc NO-UNDO LIKE ub.icnt-doc.
DEFINE TEMP-TABLE tt-icnt-line NO-UNDO LIKE ub.icnt-line.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS character NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type AS character NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-recid AS recid NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-icnt-line-rec AS recid NO-UNDO.
define input parameter p-call-prog as handle no-undo .
define input-output parameter p-next-prev as CHARACTER no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма редактирования документа измерения погрешности счетчиков ТРК".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure findtank:
  define input  parameter p-obj-type     as character no-undo.
  define input  parameter p-obj-code     as integer   no-undo.
  define input  parameter p-pump-code    as integer   no-undo.
  define input  parameter p-nozzle-code  as integer   no-undo .
  define input  parameter p-from-pl-code as integer   no-undo .
  define input  parameter p-gds-code     as integer   no-undo.
  define output parameter p-pl-code      as integer   no-undo .
  define variable v-pl-code            like ub.place.pl-code no-undo .
  define variable v-dopstr             as character no-undo .
  define buffer buf_place for ub.place.
  define buffer buf_pl-gds-pump for ub.pl-gds-pump.
  define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
  define buffer buf_pl-gds for ub.pl-gds.
  do
  on error undo, return error return-value
  :
    assign
      v-pl-code = 0
      p-pl-code = ?
    .
    if p-from-pl-code <> ?
      and p-from-pl-code <> 0
    then do:
      find first buf_pl-gds no-lock
        where buf_pl-gds.obj-type  = p-obj-type
          and buf_pl-gds.obj-code  = p-obj-code
          and buf_pl-gds.pl-code   = p-from-pl-code
          and buf_pl-gds.gds-code  = p-gds-code
        no-error.
      if available buf_pl-gds then do:
        assign
          v-pl-code = buf_pl-gds.pl-code
        .
      end.
    end.
    if v-pl-code <> 0
      and p-nozzle-code <> ?
      and p-nozzle-code <> 0
    then do:
      find first buf_pl-pump-nozzle no-lock
        where buf_pl-pump-nozzle.obj-type    = p-obj-type
          and buf_pl-pump-nozzle.obj-code    = p-obj-code
          and buf_pl-pump-nozzle.pl-code     = v-pl-code
          and buf_pl-pump-nozzle.pump-code   = p-pump-code
          and buf_pl-pump-nozzle.nozzle-code = p-nozzle-code
        no-error .
      if not available buf_pl-pump-nozzle then do:
        return.
      end.
    end.
    if v-pl-code = 0 then do:
      if p-nozzle-code = 0 then do:
        find first buf_pl-gds-pump no-lock
          where buf_pl-gds-pump.obj-type  = p-obj-type
            and buf_pl-gds-pump.obj-code  = p-obj-code
            and buf_pl-gds-pump.pump-code = p-pump-code
            and buf_pl-gds-pump.gds-code  = p-gds-code
            and buf_pl-gds-pump.status_   = 'тек':U
          no-error.
        if available buf_pl-gds-pump then do:
          assign
            v-pl-code = buf_pl-gds-pump.pl-code
          .
        end.
      end.
      else do:
        _ppnz:
        for each buf_pl-pump-nozzle no-lock
          where buf_pl-pump-nozzle.obj-type = p-obj-type
            and buf_pl-pump-nozzle.obj-code = p-obj-code
            and buf_pl-pump-nozzle.pump-code = p-pump-code
            and buf_pl-pump-nozzle.nozzle-code = p-nozzle-code
          ,first buf_pl-gds-pump no-lock
          where buf_pl-gds-pump.obj-type  = p-obj-type
            and buf_pl-gds-pump.obj-code  = p-obj-code
            and buf_pl-gds-pump.pump-code = p-pump-code
            and buf_pl-gds-pump.gds-code  = p-gds-code
            and buf_pl-gds-pump.status_   = 'тек':U
            and buf_pl-gds-pump.pl-code   = buf_pl-pump-nozzle.pl-code
        on error undo, return error return-value
        :
          assign
            v-pl-code = buf_pl-pump-nozzle.pl-code
          .
          leave _ppnz.
        end.
      end.
    end.
    if v-pl-code <> 0 then do:
      assign
        p-pl-code = v-pl-code
      .
    end.
  end.
end procedure.
procedure find-nzl:
define input  parameter p-obj-type   as character no-undo.
define input  parameter p-obj-code   as integer   no-undo.
define input  parameter p-pump-code  as integer   no-undo.
define input  parameter p-gds-code   as integer   no-undo.
define input  parameter p-pl-code    as integer no-undo .
define output parameter p-nozzle-code    as integer   no-undo.
define variable v-nozzle-code        like ub.nozzle.nozzle-code no-undo .
define variable v-pl-code            like ub.place.pl-code no-undo .
define variable v-pump-code          like ub.pump.pump-code no-undo .
define variable v-loc1-code          like ub.place.loc1 no-undo .
define variable v-dopstr             as character no-undo .
define buffer buf_place for ub.place.
define buffer buf_pl-gds-pump for ub.pl-gds-pump.
define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
define buffer buf_pl-gds for ub.pl-gds.
do on error undo, return error return-value :
  v-pump-code = p-pump-code.
  find first buf_pl-pump-nozzle no-lock where
                buf_pl-pump-nozzle.obj-type = p-obj-type
            and buf_pl-pump-nozzle.obj-code = p-obj-code
            and buf_pl-pump-nozzle.pump-code = p-pump-code
            and buf_pl-pump-nozzle.pl-code = p-pl-code no-error.
  if not available buf_pl-pump-nozzle then do:
    assign
    p-nozzle-code = ?.
    return .
  end.
  assign
  p-nozzle-code = buf_pl-pump-nozzle.nozzle-code.
  return.
  .
end.
end procedure.
procedure find-nzl-without-pl:
define input  parameter p-obj-type   as character no-undo.
define input  parameter p-obj-code   as integer   no-undo.
define input  parameter p-pump-code  as integer   no-undo.
define input  parameter p-gds-code   as integer   no-undo.
define output parameter p-nozzle-code    as integer   no-undo.
define buffer buf_pl-gds-pump for ub.pl-gds-pump.
define buffer buf_pl-gds for ub.pl-gds.
define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
do on error undo, return error return-value :
  for each buf_pl-gds-pump no-lock where
            buf_pl-gds-pump.obj-type  = p-obj-type
        and buf_pl-gds-pump.obj-code  = p-obj-code
        and buf_pl-gds-pump.pump-code = p-pump-code
        and buf_pl-gds-pump.gds-code  = p-gds-code
        and buf_pl-gds-pump.status_   = 'тек':U,
      first buf_pl-gds no-lock where
                buf_pl-gds.obj-type = p-obj-type
            AND buf_pl-gds.obj-code = p-obj-code
            AND buf_pl-gds.pl-code = buf_pl-gds-pump.pl-code
            AND buf_pl-gds.gds-code = p-gds-code
            AND buf_pl-gds.status_ = 'тек':U,
     first buf_pl-pump-nozzle no-lock where
              buf_pl-pump-nozzle.obj-type = p-obj-type
          and buf_pl-pump-nozzle.obj-code = p-obj-code
          and buf_pl-pump-nozzle.pl-code = buf_pl-gds.pl-code
          and buf_pl-pump-nozzle.pump-code = p-pump-code:
    assign
    p-nozzle-code = buf_pl-pump-nozzle.nozzle-code.
    return .
  end.
  assign
  p-nozzle-code = ?.
  return.
  .
end.
end procedure.
procedure add-icnt-line-err :
define input parameter p-mode as character no-undo .
define input parameter p-chk-doc-code as character no-undo .
define input parameter p-icnt-doc-code as character no-undo .
define input parameter p-doc-date as date no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input-output parameter p-ptrlcheck as character no-undo .
define parameter buffer buf_tt-icnt-line for tt-icnt-line.
define variable v-pump-code as integer no-undo .
define variable v-nozzle-code as integer no-undo .
define variable v-pl-code as integer no-undo .
define variable v-loc1-code as character no-undo .
define variable v-gds-code as integer no-undo .
define variable v-recid-list as character no-undo .
define variable v-ii as integer no-undo .
define variable v-type as character no-undo .
define variable v-value as character no-undo .
define variable v-exist as logical no-undo .
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_icnt-doc for ub.icnt-doc.
define buffer buf_bar-code for ub.bar-code.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
    find first buf_icnt-doc exclusive-lock where
              buf_icnt-doc.doc-code = p-icnt-doc-code no-error.
    if not available buf_icnt-doc then do:
      undo main-block, return error
      substitute( "Не найден документ измерения погрешности счетчиков ТРК с номером &1"
                    , p-icnt-doc-code
                    ).
    end.
    if buf_icnt-doc.doc-type <> 'сч-трк-погр':U then do:
      undo main-block, return error
      substitute( "Документ измерения погрешности счетчиков ТРК с номером &2 имеет неверный тип &3"
                    , p-icnt-doc-code
                    , buf_icnt-doc.doc-type
                    ).
    end.
    for each buf_chk-doc no-lock where
            buf_chk-doc.out-2-code = p-icnt-doc-code:
      p-ptrlcheck = p-ptrlcheck + (if p-ptrlcheck = '':U then '':U else chr(44)) + buf_chk-doc.doc-code.
    end.
  end.
  find first buf_chk-doc exclusive-lock where
            buf_chk-doc.doc-code = p-chk-doc-code no-error.
  if not available buf_chk-doc then do:
    undo main-block, return error
    substitute( "Не найден чек техпролива с номером &1"
                  , p-chk-doc-code
                  ).
  end.
  if buf_chk-doc.chk-type <> integer('17':U) then do:
    undo main-block, return error
    substitute( "Чек с номером &1 имеет тип отличный от типа ТЕХПРОЛИВ"
                  , p-chk-doc-code
                  ) .
  end.
  if buf_chk-doc.office <> 'т':U
  and buf_chk-doc.office <> 'у':U then do:
    undo main-block, return error
    substitute( "Чек с номером &1 - ошибочный - нельзя создать по нему строку док-та измерения погрешности ТРК"
                  , p-chk-doc-code
                  ).
  end.
  if (p-mode = 'ДОБАВЛЕНИЕ':U
      and not (buf_chk-doc.obj-type = p-obj-type
              and
              buf_chk-doc.obj-code = p-obj-code))
  or (p-mode = 'ИЗМЕНЕНИЕ':U
      and not (buf_chk-doc.obj-type = buf_icnt-doc.obj-type
              and
              buf_chk-doc.obj-code = buf_icnt-doc.obj-code)) then do:
    undo main-block, return error
    substitute( "Чек с номером &1 принадлежит &2&3, а док-нт измерения погрешности ТРК &4 - &5&6"
                  , p-chk-doc-code
                  , buf_chk-doc.obj-type
                  , buf_chk-doc.obj-code
                  , p-icnt-doc-code
                  , (if p-mode = 'ДОБАВЛЕНИЕ':U then p-obj-type else buf_icnt-doc.obj-type)
                  , (if p-mode = 'ДОБАВЛЕНИЕ':U then p-obj-code else buf_icnt-doc.obj-code)
                  ).
  end.
  if (p-mode = 'ДОБАВЛЕНИЕ':U
      and not buf_chk-doc.chk-date = p-doc-date)
  or (p-mode = 'ИЗМЕНЕНИЕ':U
      and not buf_chk-doc.chk-date = buf_icnt-doc.doc-date)
  then do:
    undo main-block, return error
    substitute( "Чек с номером &1 от &2, а док-нт измерения погрешности ТРК &3 - от &4"
                  , p-chk-doc-code
                  , buf_chk-doc.chk-date
                  , p-icnt-doc-code
                  , (if p-mode = 'ДОБАВЛЕНИЕ':U then p-doc-date else buf_icnt-doc.doc-date)
                  ).
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U
  and buf_chk-doc.doc-code = p-icnt-doc-code then do:
    undo main-block, return error
    substitute( "Чек с номером &1 уже используется данным док-нтом измерения погрешности ТРК &2"
                  , p-chk-doc-code
                  , p-icnt-doc-code
                  ).
  end.
  if buf_chk-doc.out-2-code <> ? then do:
    undo main-block, return error
    substitute( "Чек с номером &1 уже используется док-нтом измерения погрешности ТРК &2"
                  , buf_chk-doc.doc-code
                  , buf_chk-doc.out-2-code
                  ).
  end.
  for each buf_chk-gds no-lock where
        buf_chk-gds.doc-code = buf_chk-doc.doc-code
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    assign
    v-pump-code =  buf_chk-gds.pump
    v-nozzle-code = buf_chk-gds.nozzle-code
    v-loc1-code = buf_chk-gds.loc1
    .
    find first buf_bar-code no-lock where
              buf_bar-code.b-code = buf_chk-gds.b-code no-error.
    if not available buf_bar-code then do:
      do v-ii = 1 to num-entries(v-recid-list):         find first buf_tt-icnt-line where                   recid(buf_tt-icnt-line) = integer(entry(v-ii, v-recid-list)) .         delete buf_tt-icnt-line.       end.
      undo main-block, return error
      substitute( "Чек с номером &1 - ошибочный - не удалось определить товар по бар-коду &2 в строке &3"
                    , p-chk-doc-code
                    , buf_chk-gds.b-code
                    , buf_chk-gds.line-num
                    ).
    end.
    v-gds-code = buf_bar-code.gds-code.
    if v-nozzle-code = 0 then do:
      run findtank in this-procedure ( input buf_chk-doc.obj-type
                                      ,input buf_chk-doc.obj-code
                                      ,input v-pump-code
                                      ,input v-nozzle-code
                                      ,input buf_chk-gds.pl-code
                                      ,input v-gds-code
                                      ,output v-pl-code ) no-error.
      if error-status:error
        or v-pl-code = ?
      then do:
        do v-ii = 1 to num-entries(v-recid-list):         find first buf_tt-icnt-line where                   recid(buf_tt-icnt-line) = integer(entry(v-ii, v-recid-list)) .         delete buf_tt-icnt-line.       end.
        undo main-block, return error
        substitute( "Чек с номером &1 - ошибочный - не удалось определить резервуар для ТРК &2 для товара по бар-коду &3 в строке &4"
                      , p-chk-doc-code
                      , v-pump-code
                      , buf_chk-gds.b-code
                      , buf_chk-gds.line-num
                      ).
      end.
      run find-nzl in this-procedure ( input buf_chk-doc.obj-type
                                      ,input buf_chk-doc.obj-code
                                      ,input v-pump-code
                                      ,input v-gds-code
                                      ,input v-pl-code
                                      ,output v-nozzle-code) no-error.
      if error-status:error then do:
        do v-ii = 1 to num-entries(v-recid-list):         find first buf_tt-icnt-line where                   recid(buf_tt-icnt-line) = integer(entry(v-ii, v-recid-list)) .         delete buf_tt-icnt-line.       end.
        undo main-block, return error
        substitute( "Чек с номером &1 - ошибочный - не удалось определить пистолет на ТРК &2 для товара по бар-коду &3 в строке &4"
                      , p-chk-doc-code
                      , v-pump-code
                      , buf_chk-gds.b-code
                      , buf_chk-gds.line-num
                      ).
      end.
    end.
    find first buf_tt-icnt-line where
              buf_tt-icnt-line.doc-code = p-icnt-doc-code
          and buf_tt-icnt-line.obj-type = p-obj-type
          and buf_tt-icnt-line.obj-code = p-obj-code
          and buf_tt-icnt-line.pump-code = v-pump-code
          and buf_tt-icnt-line.nozzle-code = v-nozzle-code no-error.
    if available buf_tt-icnt-line then do:
      do v-ii = 1 to num-entries(v-recid-list):         find first buf_tt-icnt-line where                   recid(buf_tt-icnt-line) = integer(entry(v-ii, v-recid-list)) .         delete buf_tt-icnt-line.       end.
      undo main-block, return error
      substitute( "Уже есть строка док-та измерения погрешности для ТРК &1, пистолет &2 - нельзя добавить строки из чека &3"
                    , v-pump-code
                    , v-nozzle-code
                    , p-chk-doc-code
                    ).
    end.
    create buf_tt-icnt-line.
    assign
    buf_tt-icnt-line.doc-code = p-icnt-doc-code
    buf_tt-icnt-line.obj-type = p-obj-type
    buf_tt-icnt-line.obj-code = p-obj-code
    buf_tt-icnt-line.pump-code = v-pump-code
    buf_tt-icnt-line.nozzle-code = v-nozzle-code
    buf_tt-icnt-line.gds-code = v-gds-code
    buf_tt-icnt-line.state-el-cnt = buf_chk-gds.doc-qnty
    buf_tt-icnt-line.state-mh-cnt = buf_chk-gds.doc-qnty
    v-recid-list = v-recid-list + (if v-recid-list = '':U
                                   then '':u
                                   else chr(44)) +
                   string(recid(buf_tt-icnt-line))
    .
  end.
  p-ptrlcheck = p-ptrlcheck + (if p-ptrlcheck = '':U then '':U else chr(44)) + buf_chk-doc.doc-code.
  buf_chk-doc.out-2-code = '':U.
end.
end procedure.
define variable v-delta-line like ub.icnt-line.state-el-cnt  no-undo.
DEFINE VARIABLE new-opened AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-mode AS CHARACTER NO-UNDO.
define variable v-host-code as integer no-undo .
define variable v-ptrlcheck as character no-undo .
define variable v-ref-rec  as recid no-undo .
DEFINE VARIABLE wrkr AS INTEGER NO-UNDO.
DEFINE VARIABLE agnt AS INTEGER NO-UNDO.
DEFINE VARIABLE boss AS INTEGER NO-UNDO.
define variable gds-rec as recid no-undo .
DEFINE BUFFER cli-buf FOR ub.clients .
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-chk
     LABEL "&Чеки"
     SIZE 10 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.
DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>"
     SIZE 4 BY 1.
DEFINE BUTTON B-notes
     LABEL "При&мечания"
     SIZE 10 BY 1.
DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<"
     SIZE 4 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON r-agnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.
DEFINE BUTTON r-boss
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.
DEFINE BUTTON r-wrkr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.
DEFINE VARIABLE agnt-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE boss-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-delta AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Разница"
      VIEW-AS TEXT
     SIZE 19 BY .67 NO-UNDO.
DEFINE VARIABLE wrkr-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY br-line FOR
      tt-icnt-line,
      buf_goods SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      tt-icnt-doc,
      buf_clients SCROLLING.
DEFINE BROWSE br-line
  QUERY br-line NO-LOCK DISPLAY
      tt-icnt-line.pump-code                 COLUMN-LABEL 'ТРК'
tt-icnt-line.nozzle-code                 COLUMN-LABEL 'Пис!то!лет'
buf_goods.artic                 COLUMN-LABEL 'Артикул'
tt-icnt-line.state-el-cnt                 COLUMN-LABEL 'Кол-во!по!счетчику'
tt-icnt-line.state-mh-cnt                 COLUMN-LABEL 'Кол-во!по!мернику'
(tt-icnt-line.state-el-cnt - tt-icnt-line.state-mh-cnt)  @ v-delta-line COLUMN-LABEL 'Разница' format "->>>,>>>,>>9.999"
buf_goods.gds-name                 COLUMN-LABEL 'Название товара'
tt-icnt-line.pl-code                 COLUMN-LABEL 'Резервуар'
ENABLE
tt-icnt-line.state-mh-cnt
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 14 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-prev AT ROW 1 COL 24
     b-next AT ROW 1 COL 28
     b-chk AT ROW 1 COL 58 WIDGET-ID 2
     B-notes AT ROW 1 COL 68
     B-hist AT ROW 1 COL 78
     B-Help AT ROW 1 COL 88
     tt-icnt-doc.doc-date AT ROW 3 COL 20 COLON-ALIGNED
          LABEL "Дата" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-icnt-doc.fact-date AT ROW 3 COL 39 COLON-ALIGNED
          LABEL "Факт" FORMAT "99/99/99"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-icnt-doc.shift-date AT ROW 3 COL 58 COLON-ALIGNED
          LABEL "Смена" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-icnt-doc.shift-num AT ROW 3 COL 72 COLON-ALIGNED
          LABEL "П" FORMAT ">9"
          VIEW-AS FILL-IN
          SIZE 3 BY 1
     tt-icnt-doc.shift-name AT ROW 3 COL 82 COLON-ALIGNED
          LABEL "№"
          VIEW-AS FILL-IN
          SIZE 3 BY 1
     tt-icnt-doc.wrkr AT ROW 4 COL 5 COLON-ALIGNED
          LABEL "К&л-к" FORMAT "999999999"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     r-wrkr AT ROW 4 COL 33.13
     tt-icnt-doc.agnt AT ROW 5 COL 5 COLON-ALIGNED
          LABEL "И&сп" FORMAT "999999999"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     r-agnt AT ROW 5.33 COL 33
     tt-icnt-doc.boss AT ROW 6 COL 5 COLON-ALIGNED
          LABEL "&М-р" FORMAT "999999999"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     r-boss AT ROW 6.33 COL 33
     B-add AT ROW 7 COL 41
     b-del AT ROW 7 COL 51
     br-line AT ROW 8 COL 1
     tt-icnt-doc.obj-code AT ROW 2 COL 16 COLON-ALIGNED
          LABEL "Объект" FORMAT "99999"
           VIEW-AS TEXT
          SIZE 7 BY .67
     tt-icnt-doc.obj-type AT ROW 2 COL 23.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY .67
     buf_clients.obj-name AT ROW 2 COL 33 COLON-ALIGNED NO-LABEL FORMAT "X(40)"
           VIEW-AS TEXT
          SIZE 40 BY .67
          FGCOLOR 4
     wrkr-name AT ROW 4 COL 16 COLON-ALIGNED NO-LABEL
     tt-icnt-doc.state-el-cnt AT ROW 4 COL 75 COLON-ALIGNED
          LABEL "Кол-во по счетчику"
           VIEW-AS TEXT
          SIZE 19 BY .67
     agnt-name AT ROW 5 COL 16 COLON-ALIGNED NO-LABEL
     tt-icnt-doc.state-mh-cnt AT ROW 5 COL 75 COLON-ALIGNED
          LABEL "Кол-во по мернику"
           VIEW-AS TEXT
          SIZE 19 BY .67
     boss-name AT ROW 6 COL 16 COLON-ALIGNED NO-LABEL
     v-delta AT ROW 6 COL 75 COLON-ALIGNED
     SPACE(3.89) SKIP(15.59)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON END-ERROR OF FRAME Dialog-Frame
OR STOP OF FRAME Dialog-Frame DO:
  apply "choose" to b-quit in frame Dialog-Frame.
  return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON LEAVE OF tt-icnt-doc.agnt IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-icnt-doc.agnt <> tt-icnt-doc.agnt then do:
     run local-psn-chk in this-procedure ( input "agnt"
                                          ,input "leave").
  end.
END.
ON MOUSE-SELECT-DBLCLICK OF tt-icnt-doc.agnt IN FRAME Dialog-Frame
OR RETURN OF tt-icnt-doc.agnt IN FRAME Dialog-Frame DO:
  run local-psn-chk in this-procedure ( input "agnt"
                                       ,input "ret-mouse").
  apply "entry" to tt-icnt-doc.agnt in frame Dialog-Frame.
  return no-apply.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
   run get-pump-from-chk-doc IN THIS-PROCEDURE NO-ERROR.
   IF ERROR-STATUS:ERROR THEN DO:
     message
     "Ошибка при добавлении строки из чека техпролива" skip
     error-status:get-message(1) skip
     return-value view-as alert-box  error.
     return no-apply.
   END.
   run OpenBr IN THIS-PROCEDURE NO-ERROR.
END.
ON CHOOSE OF b-chk IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
run str/chk-docs.w (
                 input parparentproc
                ,INPUT  '':U
                ,INPUT 'сч-трк-погр':U
                ,INPUT ?
                ,INPUT tt-icnt-doc.obj-type
                ,INPUT tt-icnt-doc.obj-code
                ,INPUT tt-icnt-doc.doc-code
                ,INPUT '':U
                ,input 0
                ,INPUT tt-icnt-doc.doc-date
                ,INPUT ?
                ,input 0
                ,output v-rid-list) no-error.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if p-mode = 'ПРОСМОТР':U then.
  else do:
    if p-mode = 'ИЗМЕНЕНИЕ':U  OR
    p-mode = 'ДОБАВЛЕНИЕ':U then do:
    if not can-find (first tt-icnt-line where tt-icnt-line.doc-code = tt-icnt-doc.doc-code no-lock) then do:
      glog = yes.
      message
      "В документе нет строк, поэтому он удаляется."
      view-as alert-box
      question buttons OK-Cancel update glog.
      if glog then do:
        if p-mode = 'ИЗМЕНЕНИЕ':U then do:
          delete LOCKED_icnt-doc.
          assign p-recid = ?.
          return.
        end.
        else do:
          assign p-recid = ?.
          return.
        end.
      end.
      else return no-apply.
    end.
    run proc-save IN THIS-PROCEDURE NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  end.
end.
END.
ON CHOOSE OF b-next IN FRAME Dialog-Frame
DO:
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
  run reposition-icnt-doc in this-procedure
  (input 'next':U
  ).
END.
ON CHOOSE OF B-notes IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-notes AS CHARACTER NO-UNDO.
v-notes = tt-icnt-doc.PS.
run gbl/notes.w ( input p-mode, input-output v-notes ).
if tt-icnt-doc.PS <> v-notes then do:
   tt-icnt-doc.PS = v-notes.
end.
END.
ON CHOOSE OF b-prev IN FRAME Dialog-Frame
DO:
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
  run reposition-icnt-doc in this-procedure
  (input 'prev':U
  ).
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
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
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  define variable v-ii as integer no-undo .
  define buffer buf_chk-doc for ub.chk-doc.
  case p-mode:
    when 'ДОБАВЛЕНИЕ':U then do:
      MESSAGE
      "Выйти не сохранив все сделанные изменения?"
       VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
       IF NOT glog THEN RETURN NO-APPLY.
      do v-ii = 1 to num-entries(v-ptrlcheck):
        find first buf_chk-doc where
                 buf_chk-doc.doc-code = entry(v-ii, v-ptrlcheck) exclusive-lock.
        assign
        buf_chk-doc.out-2-code = ?
        .
      end.
      if available locked_icnt-doc then
       delete locked_icnt-doc.
       p-recid = ?.
    end.
    WHEN 'ИЗМЕНЕНИЕ':U THEN DO:
      MESSAGE
      "Выйти не сохранив все сделанные изменения?"
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
      IF NOT glog THEN RETURN NO-APPLY.
      do v-ii = 1 to num-entries(v-ptrlcheck):
        find first buf_chk-doc where
                 buf_chk-doc.doc-code = entry(v-ii, v-ptrlcheck) exclusive-lock.
        if buf_chk-doc.out-2-code = '':U then do:
          assign
          buf_chk-doc.out-2-code = ?
          .
        end.
      end.
    END.
  END CASE.
  p-next-prev = "quit".
END.
ON LEAVE OF tt-icnt-doc.boss IN FRAME Dialog-Frame
DO:
    if input frame Dialog-Frame tt-icnt-doc.boss <> tt-icnt-doc.boss then do:
    run local-psn-chk in this-procedure ( input "boss", input "leave").
  end.
END.
ON MOUSE-SELECT-DBLCLICK OF tt-icnt-doc.boss IN FRAME Dialog-Frame
OR RETURN OF tt-icnt-doc.boss IN FRAME Dialog-Frame DO:
  run local-psn-chk in this-procedure ( input "boss", input "ret-mouse").
  apply "entry" to tt-icnt-doc.boss in frame Dialog-Frame.
  return no-apply.
END.
ON CHOOSE OF r-agnt IN FRAME Dialog-Frame
DO:
  run local-psn-chk in this-procedure ( input "agnt", input "button").
  apply "entry" to tt-icnt-doc.agnt in FRAME Dialog-Frame.
  return no-apply.
END.
ON CHOOSE OF r-boss IN FRAME Dialog-Frame
DO:
  run local-psn-chk in this-procedure ( input "boss", input "button").
  apply "entry" to tt-icnt-doc.boss in FRAME Dialog-Frame.
  return no-apply.
END.
ON CHOOSE OF r-wrkr IN FRAME Dialog-Frame
DO:
  run local-psn-chk in this-procedure ( input "wrkr", input "button").
  apply "entry" to tt-icnt-doc.wrkr in FRAME Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-icnt-doc.wrkr IN FRAME Dialog-Frame
DO:
    if input frame Dialog-Frame tt-icnt-doc.wrkr <> tt-icnt-doc.wrkr then do:
    run local-psn-chk in this-procedure ( input "wrkr", input "leave").
  end.
END.
ON MOUSE-SELECT-DBLCLICK OF tt-icnt-doc.wrkr IN FRAME Dialog-Frame
OR RETURN OF tt-icnt-doc.wrkr IN FRAME Dialog-Frame DO:
  run local-psn-chk in this-procedure ( input "wrkr", input "ret-mouse").
  apply "entry" to tt-icnt-doc.wrkr in frame Dialog-Frame.
  return no-apply.
END.
ON value-changed OF br-line do:
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
end.
ON RETURN OF tt-icnt-line.state-mh-cnt IN BROWSE br-line,
            tt-icnt-line.state-el-cnt IN BROWSE br-line do:
  APPLY "LEAVE" to self.
end.
ON LEAVE OF tt-icnt-line.state-mh-cnt IN BROWSE br-line DO:
define buffer buf_tt-icnt-line for tt-icnt-line.
if tt-icnt-line.state-mh-cnt <> DECIMAL(tt-icnt-line.state-mh-cnt:SCREEN-VALUE IN BROWSE br-line) then do transaction:
   find first buf_tt-icnt-line exclusive-lock where
              recid(buf_tt-icnt-line) = recid(tt-icnt-line).
   ASSIGN
   buf_tt-icnt-line.state-mh-cnt = DECIMAL(tt-icnt-line.state-mh-cnt:SCREEN-VALUE IN BROWSE br-line).
   display
   (tt-icnt-line.state-el-cnt - tt-icnt-line.state-mh-cnt) @ v-delta-line
   with  browse br-line.
   run recalc-icnt in this-procedure .
end.
run display-value in this-procedure .
END.
ON LEAVE OF tt-icnt-line.state-el-cnt IN BROWSE br-line DO:
define buffer buf_tt-icnt-line for tt-icnt-line.
if tt-icnt-line.state-el-cnt <> DECIMAL(tt-icnt-line.state-el-cnt:SCREEN-VALUE IN BROWSE br-line) then do transaction:
  find first buf_tt-icnt-line  exclusive-lock where
          recid(buf_tt-icnt-line) = recid(tt-icnt-line).
  ASSIGN
  buf_tt-icnt-line.state-el-cnt = DECIMAL(tt-icnt-line.state-el-cnt:SCREEN-VALUE IN BROWSE br-line).
  display
  (tt-icnt-line.state-el-cnt - tt-icnt-line.state-mh-cnt) @ v-delta-line
  with  browse br-line.
  run recalc-icnt in this-procedure .
end.
run display-value in this-procedure .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse br-line :handle
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
def var sort-labelbr-line   as character no-undo .
def var sort-clmnbr-line    as handle    no-undo .
def var cur-clmnbr-line     as handle    no-undo .
def var cur-clmn-locbr-line as integer   no-undo .
def var re-querybr-line     as logical   initial no no-undo .
on start-search, ctrl-o of br-line in frame Dialog-Frame do:
   run sort-brbr-line
     (input (if available tt-icnt-line
             then recid(tt-icnt-line)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-line :
  define input parameter p-recid as recid no-undo .
  if re-querybr-line = no then do:
    assign
       cur-clmnbr-line = br-line:current-column in frame Dialog-Frame
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
        when 'ТРК'  then DO:   OPEN QUERY br-line                                             FOR EACH tt-icnt-line WHERE tt-icnt-line.doc-code = tt-icnt-doc.doc-code NO-LOCK,              FIRST buf_goods OUTER-JOIN NO-LOCK WHERE buf_goods.gds-code  = tt-icnt-line.gds-code BY tt-icnt-line.pump-code .   . END.
        when 'Пис!то!лет'  then DO:   OPEN QUERY br-line                                             FOR EACH tt-icnt-line WHERE tt-icnt-line.doc-code = tt-icnt-doc.doc-code NO-LOCK,              FIRST buf_goods OUTER-JOIN NO-LOCK WHERE buf_goods.gds-code  = tt-icnt-line.gds-code BY tt-icnt-line.nozzle-code .   . END.
        when 'Артикул'  then DO:   OPEN QUERY br-line                                             FOR EACH tt-icnt-line WHERE tt-icnt-line.doc-code = tt-icnt-doc.doc-code NO-LOCK,              FIRST buf_goods OUTER-JOIN NO-LOCK WHERE buf_goods.gds-code  = tt-icnt-line.gds-code BY buf_goods.artic .   . END.
        when 'Кол-во!по!счетчику'  then DO:   OPEN QUERY br-line                                             FOR EACH tt-icnt-line WHERE tt-icnt-line.doc-code = tt-icnt-doc.doc-code NO-LOCK,              FIRST buf_goods OUTER-JOIN NO-LOCK WHERE buf_goods.gds-code  = tt-icnt-line.gds-code BY tt-icnt-line.state-el-cnt .   . END.
        when 'Кол-во!по!мернику'  then DO:   OPEN QUERY br-line                                             FOR EACH tt-icnt-line WHERE tt-icnt-line.doc-code = tt-icnt-doc.doc-code NO-LOCK,              FIRST buf_goods OUTER-JOIN NO-LOCK WHERE buf_goods.gds-code  = tt-icnt-line.gds-code BY tt-icnt-line.state-mh-cnt .   . END.
        when 'Разница'  then DO:   OPEN QUERY br-line                                             FOR EACH tt-icnt-line WHERE tt-icnt-line.doc-code = tt-icnt-doc.doc-code NO-LOCK,              FIRST buf_goods OUTER-JOIN NO-LOCK WHERE buf_goods.gds-code  = tt-icnt-line.gds-code BY (tt-icnt-line.state-el-cnt - tt-icnt-line.state-mh-cnt) .   . END.
        when 'Название товара'  then DO:   OPEN QUERY br-line                                             FOR EACH tt-icnt-line WHERE tt-icnt-line.doc-code = tt-icnt-doc.doc-code NO-LOCK,              FIRST buf_goods OUTER-JOIN NO-LOCK WHERE buf_goods.gds-code  = tt-icnt-line.gds-code BY buf_goods.gds-name .   . END.
        when 'Резервуар'  then DO:   OPEN QUERY br-line                                             FOR EACH tt-icnt-line WHERE tt-icnt-line.doc-code = tt-icnt-doc.doc-code NO-LOCK,              FIRST buf_goods OUTER-JOIN NO-LOCK WHERE buf_goods.gds-code  = tt-icnt-line.gds-code BY tt-icnt-line.pl-code .   . END.
    otherwise do:
      run Openbr in this-procedure .
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
    if cur-clmn-locbr-line <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr-line') then do:
        run ch-clmnbr-line in this-procedure (cur-clmn-locbr-line).
      end.
    end.
  if p-recid <> ? then do:
    reposition br-line to recid p-recid no-error.
    apply "value-changed" to br-line in frame Dialog-Frame.
  end.
  apply "entry" to br-line in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-line:
if cur-clmnbr-line = ? then do:
   run Openbr in this-procedure .
end.
else do:
   assign re-querybr-line = yes.
   run sort-brbr-line
     (input (if available tt-icnt-line
             then recid(tt-icnt-line)
             else ?
            )
     ).
   assign re-querybr-line = no.
end.
end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame Dialog-Frame anywhere do:
  run get-gds-rec.
  if gds-rec = ? then
    return no-apply.
  run ref/gds-form.w ( input parparentproc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br-line in frame Dialog-Frame.
  return no-apply.
end.
p-next-prev = '':U.
v-mode = p-mode.
n-p:
do while p-next-prev = '':U :
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
     if LOOKUP(p-mode, ('ИЗМЕНЕНИЕ':U  + chr(4) + 'ДОБАВЛЕНИЕ':U + chr(4) + 'ПРОСМОТР':U), chr(4) ) = 0 then do:
          message
          vss-workfile vss-revision vss-description skip
          substitute("Неверный параметр вызова p-mode=&1", p-mode)
          view-as alert-box ERROR.
          undo, return error.
      end.
      if p-obj-type <> 'маг':U then DO:
          message
          vss-workfile vss-revision vss-description skip
          substitute("Неверный параметр вызова p-obj-type=&1", p-obj-type)
          view-as alert-box ERROR.
          undo, return error.
      end.
      FIND FIRST buf_clients NO-LOCK WHERE
                buf_Clients.obj-type = p-obj-type
           AND buf_clients.obj-code = p-obj-code NO-ERROR.
      IF NOT AVAILABLE buf_clients THEN DO:
        MESSAGE
        substitute("Неверное значение параметров p-obj-type = &1 и/или p-obj-code=&2"
                  , p-obj-type
                  , p-obj-code)
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
      END.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
      if not p-mode = 'ПРОСМОТР':U THEN DO:
         p-next-prev = '':U.
        IF buf_clients.db-num <> v-cntxt-db-num THEN DO:
            MESSAGE
            substitute("Неверное значение параметров p-obj-type = &1 и/или p-obj-code=&2&3" +
                      "Добавление и изменение документа счетчиков ТРК возможно только в БД объекта&3" +
                      "БД для &1&2 - &4, текущая БД - &5"
                      , p-obj-type
                      , p-obj-code
                      , chr(10)
                      , buf_clients.db-num
                      , v-cntxt-db-num)
            VIEW-AS ALERT-BOX ERROR.
            UNDO, RETURN ERROR.
        END.
      END.
      if p-mode <> 'ПРОСМОТР':U then do:
        p-next-prev = "quit".
      end.
      run fill-tables in this-procedure no-error.
      if error-status:error then return error.
      RUN Myenable IN THIS-PROCEDURE.
      IF new-opened THEN DO:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-line as INT EXTENT 9 no-undo.
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
  RUN re-move-clmnbr-line ( 4, 9).
END.
ON ctrl-cursor-left OF BROWSE br-line do:
  RUN re-move-clmnbr-line (9, 4).
END.
PROCEDURE re-move-clmnbr-line:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-line = 1 TO EXTENT(cur-clmn-numbr-line):
    if cur-clmn-numbr-line[varmvibr-line] = source-column THEN cur-clmn-numbr-line[varmvibr-line] = -1.
  END.
  if br-line:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
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
  if cur-clmn-loc <= 4 then do:
    return .
  end.
  DO varmvibr-line = 1 TO EXTENT(cur-clmn-numbr-line):
    if cur-clmn-numbr-line[varmvibr-line] = cur-clmn-loc THEN move-elementbr-line = varmvibr-line.
  END.
  RUN re-move-clmnbr-line (cur-clmn-loc, 4).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-line:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-line = 4 to EXTENT(cur-clmn-numbr-line):
    RUN re-move-clmnbr-line (cur-clmn-numbr-line[varmvlbr-line], varmvlbr-line).
  END.
  RUN start-mv-clmnbr-line.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
        new-opened = no.
      END.
      WAIT-FOR GO OF FRAME Dialog-Frame.
    END.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE display-value :
display
tt-icnt-doc.state-el-cnt
tt-icnt-doc.state-mh-cnt
(tt-icnt-doc.state-el-cnt - tt-icnt-doc.state-mh-cnt) @ v-delta
with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY wrkr-name agnt-name boss-name v-delta
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_clients THEN
    DISPLAY buf_clients.obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-icnt-doc THEN
    DISPLAY tt-icnt-doc.doc-date tt-icnt-doc.fact-date tt-icnt-doc.shift-date
          tt-icnt-doc.shift-num tt-icnt-doc.shift-name tt-icnt-doc.wrkr
          tt-icnt-doc.agnt tt-icnt-doc.boss tt-icnt-doc.obj-code
          tt-icnt-doc.obj-type tt-icnt-doc.state-el-cnt tt-icnt-doc.state-mh-cnt
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-prev b-next b-chk B-notes B-hist B-Help
         tt-icnt-doc.doc-date tt-icnt-doc.fact-date tt-icnt-doc.shift-date
         tt-icnt-doc.shift-num tt-icnt-doc.shift-name tt-icnt-doc.wrkr r-wrkr
         tt-icnt-doc.agnt r-agnt tt-icnt-doc.boss r-boss B-add b-del br-line
         tt-icnt-doc.obj-code tt-icnt-doc.obj-type buf_clients.obj-name
         wrkr-name tt-icnt-doc.state-el-cnt agnt-name tt-icnt-doc.state-mh-cnt
         boss-name v-delta
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-line FOR EACH tt-icnt-line NO-LOCK WHERE     tt-icnt-line.doc-code = tt-icnt-doc.doc-code ,                     FIRST buf_goods OUTER-JOIN WHERE             buf_goods.gds-code        = tt-icnt-line.gds-code NO-LOCK.
END PROCEDURE.
PROCEDURE fill-tables :
define variable v-today as date      no-undo.
FOR EACH tt-icnt-line:
    DELETE tt-icnt-line.
END.
FOR EACH tt-icnt-doc:
    DELETE tt-icnt-doc.
END.
IF p-mode = 'ДОБАВЛЕНИЕ':U then do:
    tr:
    do transaction on error undo tr, return error return-value
                   on stop  undo tr, return error return-value
                   on quit  undo tr, return error return-value :
       run waitfram-show in this-procedure ( INPUT "Создаем документ." ).
       create tt-icnt-doc.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-today
  )  .
       assign
       tt-icnt-doc.ext-doc-type = 'em':U
       tt-icnt-doc.doc-type  = 'сч-трк-погр':U
       tt-icnt-doc.host-code = v-host-code
       tt-icnt-doc.obj-type  = p-obj-type
       tt-icnt-doc.obj-code  = p-obj-code
       tt-icnt-doc.status_   = 'новый':U
       tt-icnt-doc.flag_     = no
       tt-icnt-doc.creid     = v-cntxt-userid
       tt-icnt-doc.PS        = "@"
       tt-icnt-doc.doc-date  = v-today
       .
       run waitfram-hide in this-procedure .
   end.
   run get-pump-from-chk-doc IN THIS-PROCEDURE NO-ERROR.
   IF ERROR-STATUS:ERROR  THEN undo, RETURN ERROR.
END.
ELSE DO:
  if p-mode = 'ПРОСМОТР':U then do:
    FIND FIRST locked_icnt-doc NO-LOCK WHERE
                recid(locked_icnt-doc) = p-recid.
  end.
  ELSE do:
    DO TRANSACTION
      ON ERROR UNDO, RETURN ERROR:
      FIND FIRST locked_icnt-doc EXCLUSIVE-LOCK WHERE
                 recid(locked_icnt-doc) = p-recid.
    END.
  END.
  IF NOT AVAIL locked_icnt-doc THEN return error.
  if locked_icnt-doc.status_ = 'факт':U and p-mode <> 'ПРОСМОТР':U then do:
     message
     substitute("Документ счетчиков ТРК &1 закрыт до статуса &2&3Изменения не допускаются"
                ,locked_icnt-doc.doc-code
                ,LOCKED_icnt-doc.STATUS_
                , chr(10)
                )
     view-as alert-box error.
     return error.
  end.
  CREATE tt-icnt-doc.
  BUFFER-COPY LOCKED_icnt-doc TO tt-icnt-doc.
  FOR EACH LOCKED_icnt-line NO-LOCK WHERE
          LOCKED_icnt-line.doc-code = LOCKED_icnt-doc.doc-code:
     CREATE tt-icnt-line.
     BUFFER-COPY LOCKED_icnt-line TO tt-icnt-line.
  END.
END.
END PROCEDURE.
PROCEDURE get-gds-rec :
IF AVAILABLE buf_goods then
gds-rec = recid(buf_goods).
ELSE BELL.
END PROCEDURE.
PROCEDURE get-pump-from-chk-doc :
define buffer buf_tt-icnt-line for tt-icnt-line.
define variable varcur-pump as logical no-undo.
define variable varnum      as integer no-undo.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
define variable v-loc-ptrlcheck as character no-undo .
define buffer buf_chk-doc for ub.chk-doc.
ASSIGN
v-rid-list = "":U.
run str/chk-docs.w (
                 input parparentproc
                ,INPUT  'b-sel,b-mark':U
                ,INPUT "to-" + 'сч-трк-погр':U
                ,INPUT ?
                ,INPUT tt-icnt-doc.obj-type
                ,INPUT tt-icnt-doc.obj-code
                ,INPUT tt-icnt-doc.doc-code
                ,INPUT '':U
                ,input 0
                ,INPUT tt-icnt-doc.doc-date
                ,INPUT ?
                ,input 0
                ,output v-rid-list) no-error.
 IF v-rid-list = "":U  THEN DO:
   RETURN error.
 END.
_ii:
DO v-ii = 1 TO NUM-ENTRIES(v-rid-list)
on error undo _ii, next _ii
:
  FIND FIRST buf_chk-doc no-LOCK WHERE
         RECID(buf_chk-doc) = INTEGER(ENTRY(v-ii, v-rid-list)) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
  END.
  v-loc-ptrlcheck = v-ptrlcheck.
  run add-icnt-line-err IN THIS-PROCEDURE (
                                             input p-mode
                                            ,input buf_chk-doc.doc-code
                                            ,input tt-icnt-doc.doc-code
                                            ,INPuT tt-icnt-doc.doc-date
                                            ,INPUT tt-icnt-doc.obj-type
                                            ,INPUT tt-icnt-doc.obj-code
                                            ,input-output v-loc-ptrlcheck
                                            ,BUFFER buf_tt-icnt-line) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     MESSAGE
     "Ошибка при добавлении строки в документ" SKIP
     ERROR-STATUS:GET-MESSAGE(1) SKIP
     RETURN-VALUE SKIP
     VIEW-AS ALERT-BOX ERROR.
     UNDO _ii, next _ii.
  END.
  v-ptrlcheck = v-loc-ptrlcheck.
END.
do transaction on error undo, return error :
  RUN recalc-icnt IN THIS-PROCEDURE NO-ERROR.
end.
END PROCEDURE.
PROCEDURE local-psn-chk :
define input parameter p-man    as character no-undo.
define input parameter p-action as character no-undo.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
if p-man = "wrkr" and p-action = "ret-mouse" then do:
  define variable v-ref-rec18   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-icnt-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame Dialog-Frame tt-icnt-doc.wrkr <> ""
       and input frame Dialog-Frame tt-icnt-doc.wrkr <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec18 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-icnt-doc.wrkr
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-icnt-doc.wrkr
            cli-buf.obj-name @ wrkr-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-icnt-doc.wrkr.
  end.
  else display ? @ tt-icnt-doc.wrkr
               ? @ wrkr-name with frame Dialog-Frame.
  apply "entry" to tt-icnt-doc.agnt in frame Dialog-Frame.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-icnt-doc.wrkr cli-buf.obj-name @ wrkr-name with frame Dialog-Frame.
  end.
  else display ? @ tt-icnt-doc.wrkr ? @ wrkr-name with frame Dialog-Frame.
      return no-apply.
end.
if p-man = "wrkr" and p-action = "button" then do:
  define variable v-ref-rec19   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-icnt-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec19 = ( if available cli-buf then recid( cli-buf ) else ? ).
  v-ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec19 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-icnt-doc.wrkr
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-icnt-doc.wrkr
            cli-buf.obj-name @ wrkr-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-icnt-doc.wrkr.
  end.
  else display ? @ tt-icnt-doc.wrkr
               ? @ wrkr-name with frame Dialog-Frame.
  apply "entry" to tt-icnt-doc.agnt in frame Dialog-Frame.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-icnt-doc.wrkr cli-buf.obj-name @ wrkr-name with frame Dialog-Frame.
  end.
  else display ? @ tt-icnt-doc.wrkr ? @ wrkr-name with frame Dialog-Frame.
      return no-apply.
end.
if p-man = "wrkr" and p-action = "leave" then do:
  define variable v-ref-rec20   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-icnt-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-icnt-doc.wrkr cli-buf.obj-name @ wrkr-name with frame Dialog-Frame.
          assign frame Dialog-Frame tt-icnt-doc.wrkr.
  end.
  else display ? @ tt-icnt-doc.wrkr ? @ wrkr-name with frame Dialog-Frame.
end.
if p-man = "agnt" and p-action = "ret-mouse" then do:
  define variable v-ref-rec21   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-icnt-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame Dialog-Frame tt-icnt-doc.agnt <> ""
       and input frame Dialog-Frame tt-icnt-doc.agnt <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec21 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-icnt-doc.agnt
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-icnt-doc.agnt
            cli-buf.obj-name @ agnt-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-icnt-doc.agnt.
  end.
  else display ? @ tt-icnt-doc.agnt
               ? @ agnt-name with frame Dialog-Frame.
  apply "entry" to tt-icnt-doc.boss
                            in frame Dialog-Frame.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-icnt-doc.agnt cli-buf.obj-name @ agnt-name with frame Dialog-Frame.
  end.
  else display ? @ tt-icnt-doc.agnt ? @ agnt-name with frame Dialog-Frame.
      return no-apply.
end.
if p-man = "agnt" and p-action = "button" then do:
  define variable v-ref-rec22   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-icnt-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec22 = ( if available cli-buf then recid( cli-buf ) else ? ).
  v-ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec22 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-icnt-doc.agnt
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-icnt-doc.agnt
            cli-buf.obj-name @ agnt-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-icnt-doc.agnt.
  end.
  else display ? @ tt-icnt-doc.agnt
               ? @ agnt-name with frame Dialog-Frame.
  apply "entry" to tt-icnt-doc.boss
                            in frame Dialog-Frame.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-icnt-doc.agnt cli-buf.obj-name @ agnt-name with frame Dialog-Frame.
  end.
  else display ? @ tt-icnt-doc.agnt ? @ agnt-name with frame Dialog-Frame.
      return no-apply.
end.
if p-man = "agnt" and p-action = "leave" then do:
  define variable v-ref-rec23   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-icnt-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-icnt-doc.agnt cli-buf.obj-name @ agnt-name with frame Dialog-Frame.
          assign frame Dialog-Frame tt-icnt-doc.agnt.
  end.
  else display ? @ tt-icnt-doc.agnt ? @ agnt-name with frame Dialog-Frame.
end.
if p-man = "boss" and p-action = "ret-mouse" then do:
  define variable v-ref-rec24   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-icnt-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame Dialog-Frame tt-icnt-doc.boss <> ""
       and input frame Dialog-Frame tt-icnt-doc.boss <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec24 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-icnt-doc.boss
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-icnt-doc.boss
            cli-buf.obj-name @ boss-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-icnt-doc.boss.
  end.
  else display ? @ tt-icnt-doc.boss
               ? @ boss-name with frame Dialog-Frame.
  apply "entry" to  b-exit in frame Dialog-Frame.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-icnt-doc.boss cli-buf.obj-name @ boss-name with frame Dialog-Frame.
  end.
  else display ? @ tt-icnt-doc.boss ? @ boss-name with frame Dialog-Frame.
      return no-apply.
end.
if p-man = "boss" and p-action = "button" then do:
  define variable v-ref-rec25   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-icnt-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec25 = ( if available cli-buf then recid( cli-buf ) else ? ).
  v-ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec25 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-icnt-doc.boss
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-icnt-doc.boss
            cli-buf.obj-name @ boss-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-icnt-doc.boss.
  end.
  else display ? @ tt-icnt-doc.boss
               ? @ boss-name with frame Dialog-Frame.
  apply "entry" to  b-exit in frame Dialog-Frame.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-icnt-doc.boss cli-buf.obj-name @ boss-name with frame Dialog-Frame.
  end.
  else display ? @ tt-icnt-doc.boss ? @ boss-name with frame Dialog-Frame.
      return no-apply.
end.
if p-man = "boss" and p-action = "leave" then do:
  define variable v-ref-rec26   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-icnt-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-icnt-doc.boss cli-buf.obj-name @ boss-name with frame Dialog-Frame.
          assign frame Dialog-Frame tt-icnt-doc.boss.
  end.
  else display ? @ tt-icnt-doc.boss ? @ boss-name with frame Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
ASSIGN
br-line:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 3
frame Dialog-Frame:title = substitute("(&1) :   ДОКУМЕНТ ИЗМЕРЕНИЯ ПОГРЕШНОСТИ СЧЕТЧИКОВ ТРК - &2 № &3 - &4"
                                       , substring (buf_clients.obj-name, 1, 35)
                                       , tt-icnt-doc.STATUS_
                                       , tt-icnt-doc.doc-code
                                       , p-mode).
disable
all with frame Dialog-Frame.
enable
b-exit WHEN p-mode <> 'ПРОСМОТР':U
b-quit
b-help
br-line
b-hist
b-notes
b-chk
b-next WHEN p-mode = 'ПРОСМОТР':U
b-prev WHEN p-mode = 'ПРОСМОТР':U
tt-icnt-doc.wrkr WHEN (p-mode <> 'ПРОСМОТР':U AND tt-icnt-doc.STATUS_ = 'новый':U)
tt-icnt-doc.agnt WHEN (p-mode <> 'ПРОСМОТР':U AND tt-icnt-doc.STATUS_ = 'новый':U)
tt-icnt-doc.boss WHEN (p-mode <> 'ПРОСМОТР':U AND tt-icnt-doc.STATUS_ = 'новый':U)
r-wrkr WHEN (p-mode <> 'ПРОСМОТР':U AND tt-icnt-doc.STATUS_ = 'новый':U)
r-agnt WHEN (p-mode <> 'ПРОСМОТР':U AND tt-icnt-doc.STATUS_ = 'новый':U)
r-boss WHEN (p-mode <> 'ПРОСМОТР':U AND tt-icnt-doc.STATUS_ = 'новый':U)
WITH frame Dialog-Frame.
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_icnt-doc_upd-el-cnt':U
    ,input  'object':U
    ,input  buf_clients.host-code
    ,input  buf_clients.obj-type
    ,input  buf_clients.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output glog
    )  .
end.
if p-mode = 'ПРОСМОТР':U then do:
   ASSIGN
   tt-icnt-line.state-mh-cnt:READ-ONLY in browse br-line = YES
   .
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
  hide b-exit in frame Dialog-Frame .
end.
DISPLAY
tt-icnt-doc.obj-code
tt-icnt-doc.obj-type
tt-icnt-doc.fact-date
tt-icnt-doc.doc-date
tt-icnt-doc.shift-date
tt-icnt-doc.shift-num
tt-icnt-doc.shift-name
with frame Dialog-Frame.
HIDE
b-add b-del IN FRAME Dialog-Frame.
run display-value in this-procedure .
  define variable v-ref-rec28   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-icnt-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display tt-icnt-doc.wrkr with frame Dialog-Frame.
  find cli-buf no-lock where cli-buf.obj-code = input frame Dialog-Frame tt-icnt-doc.wrkr
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-icnt-doc.wrkr cli-buf.obj-name @ wrkr-name with frame Dialog-Frame.
  end.
  else display ? @ tt-icnt-doc.wrkr ? @ wrkr-name with frame Dialog-Frame.
  define variable v-ref-rec29   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-icnt-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display tt-icnt-doc.agnt with frame Dialog-Frame.
  find cli-buf no-lock where cli-buf.obj-code = input frame Dialog-Frame tt-icnt-doc.agnt
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-icnt-doc.agnt cli-buf.obj-name @ agnt-name with frame Dialog-Frame.
  end.
  else display ? @ tt-icnt-doc.agnt ? @ agnt-name with frame Dialog-Frame.
  define variable v-ref-rec30   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-icnt-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display tt-icnt-doc.boss with frame Dialog-Frame.
  find cli-buf no-lock where cli-buf.obj-code = input frame Dialog-Frame tt-icnt-doc.boss
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-icnt-doc.boss cli-buf.obj-name @ boss-name with frame Dialog-Frame.
  end.
  else display ? @ tt-icnt-doc.boss ? @ boss-name with frame Dialog-Frame.
RUN Openbr IN THIS-PROCEDURE .
if p-mode = 'ПРОСМОТР':U then do:
if p-icnt-line-rec <> ? then reposition br-line to recid p-icnt-line-rec no-error.
  apply "entry" to br-line in frame Dialog-Frame.
end.
if p-mode = 'ИЗМЕНЕНИЕ':U then do:
  apply "entry" to br-line in frame Dialog-Frame.
end.
if num-results("br-line") > 0 then do:
   if br-line:refresh() then.
end.
hide
b-hist
in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE OpenBr :
OPEN QUERY br-line                                             FOR EACH tt-icnt-line WHERE tt-icnt-line.doc-code = tt-icnt-doc.doc-code NO-LOCK,              FIRST buf_goods OUTER-JOIN NO-LOCK WHERE buf_goods.gds-code  = tt-icnt-line.gds-code.
END PROCEDURE.
PROCEDURE proc-save :
define variable v-recid as recid no-undo .
if p-mode = 'ПРОСМОТР':U then return .
assign
frame Dialog-Frame
tt-icnt-doc.wrkr
tt-icnt-doc.agnt
tt-icnt-doc.boss.
if p-mode = 'ИЗМЕНЕНИЕ':U then do:
  v-recid = recid(locked_icnt-doc).
end.
run str/icntdoc1.p (
                 INPUT p-mode
                ,input no
                ,input-output v-recid
                ,INPUT tt-icnt-doc.doc-code
                ,input tt-icnt-doc.obj-type
                ,input tt-icnt-doc.obj-code
                ,input tt-icnt-doc.host-code
                ,input 'сч-трк-погр':U
                ,input 'em':U
                ,INPUT tt-icnt-doc.wrkr
                ,INPUT tt-icnt-doc.agnt
                ,INPUT tt-icnt-doc.boss
                ,INPUT tt-icnt-doc.doc-date
                ,input tt-icnt-doc.meas-el-cnt
                ,input tt-icnt-doc.state-el-cnt
                ,input tt-icnt-doc.state-mh-cnt
                ,input tt-icnt-doc.PS
                ,input tt-icnt-doc.creid
                ,input v-ptrlcheck
                ,input table tt-icnt-line
                 ) NO-ERROR.
if error-status:error then do:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
  undo, return error.
end.
p-recid = v-recid.
END PROCEDURE.
PROCEDURE recalc-icnt :
DEFINE VARIABLE v-meas-el-cnt AS DECIMAL NO-UNDO.
DEFINE VARIABLE v-state-el-cnt AS DECIMAL NO-UNDO.
DEFINE VARIABLE v-state-mh-cnt AS DECIMAL NO-UNDO.
define buffer buf_tt-icnt-line for tt-icnt-line.
for each buf_tt-icnt-line where buf_tt-icnt-line.doc-code = tt-icnt-doc.doc-code:
  ASSIGN
  v-meas-el-cnt = v-meas-el-cnt + buf_tt-icnt-line.meas-el-cnt
  v-state-el-cnt = v-state-el-cnt + buf_tt-icnt-line.state-el-cnt
  v-state-mh-cnt = v-state-mh-cnt + buf_tt-icnt-line.state-mh-cnt
  .
end.
assign
tt-icnt-doc.meas-el-cnt  = v-meas-el-cnt
tt-icnt-doc.state-el-cnt = v-state-el-cnt
tt-icnt-doc.state-mh-cnt = v-state-mh-cnt
.
END PROCEDURE.
PROCEDURE reposition-icnt-doc :
define input parameter p-direction as character no-undo .
define variable v-new-icnt-doc-recid as recid no-undo .
do
on error undo, return error
:
  if valid-handle(p-call-prog)
  then do:
    run reposition-icnt-doc in p-call-prog
      (input  p-direction
      ,output v-new-icnt-doc-recid
      ).
    if v-new-icnt-doc-recid <> ?
    then do:
      define buffer buf_icnt-doc for ub.icnt-doc .
      find first buf_icnt-doc no-lock
        where recid(buf_icnt-doc) = v-new-icnt-doc-recid
        no-error .
      assign
      p-recid = v-new-icnt-doc-recid
      p-next-prev = '':U
      .
    end.
  end.
  else do:
    message "Список документов не определен." view-as alert-box INFORMATION .
    return no-apply.
  end.
  END.
END PROCEDURE.
