block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter interface as logical no-undo.
define input parameter from-ink as logical no-undo.
define input parameter p-doc-rec as recid no-undo .
define output parameter v-notes as character no-undo .
define output parameter not-all-saled-chk as logical init no.
define output parameter not-all-normal-chk as logical init no.
define output parameter not-all-inkas-closed as logical no-undo init no.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chk-inf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chk-inf.p $":U .
define variable vss-description as character no-undo init "Информация по чекам и продажам".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
function shift-name-no-err return char (
                                        buffer loc-inkas for ub.inkas
 ).
define variable varshift-name as character no-undo.
define variable varshift-name-num as character no-undo.
  varshift-name = loc-inkas.shift-name.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_shiftnme in g#lib-trn3 ( input  loc-inkas.obj-type,
                       input  loc-inkas.obj-code,
                       input  loc-inkas.shift-date,
                       input  loc-inkas.shift-num,
                       input-output varshift-name,
                       output varshift-name-num
                       ) no-error .
  if error-status:error then do:
    return "":u.
  end.
  return varshift-name-num.
end function.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable not-saled as char no-undo.
define variable not-saled-err as char no-undo.
define variable inkas-ch as char no-undo.
define variable current-store-type like ub.inkas.obj-type no-undo.
define variable current-store-code like ub.inkas.obj-code no-undo.
define variable cas-shft as logical no-undo init no.
define variable l-shift-on as logical no-undo init no.
define variable conf-attr as char no-undo.
define variable conf-par as char no-undo.
define variable par-type as char no-undo.
define variable chk-inf as logical no-undo init yes.
define variable v-shift-str as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if v-cntxt-db-num-obj <> v-cntxt-db-num then do:
  message
  substitute("Нельзя получить информацию по чекам в чужой БД&1" +
              "№ БД объекта &2, № текущей БД &3"
              , chr(10)
              , v-cntxt-db-num-obj
              , v-cntxt-db-num)
  view-as alert-box error .
  return.
end.
run adm/shattri.p (
    input "get":U
    ,input  p-curr-obj-type
    ,input  p-curr-obj-code
    ,input  'chk-view':U
    ,input  'chk-inf':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF not error-status:error then
assign
chk-inf = v-value-logical.
delete object v-tth.
if not chk-inf and not interface and not from-ink then return.
run waitfram-show in this-procedure ( input "Поиск ошибочных и неучтенных чеков. ЖДИТЕ...").
v-notes = "".
if from-ink then do:
    FIND FIRST ub.inkas No-LOCK WHERE recid(ub.inkas) = p-doc-rec No-ERROR.
    if not avail ub.inkas then do:
      message vss-workfile vss-revision vss-description skip
      "Не найдена запись inkas"
      view-as alert-box error .
      return error.
    end.
    assign
    current-store-type = ub.inkas.obj-type
    current-store-code = ub.inkas.obj-code
    .
    FIND FIRST ub.shop NO-LOCK WHERE
               ub.shop.obj-code = ub.inkas.obj-code NO-ERROR.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type5 as character no-undo .
define variable v-value-character5 as character no-undo .
define variable v-value-date5 as date no-undo .
define variable v-value-decimal5 as decimal no-undo .
define variable v-value-integer5 as INTEGER no-undo .
define variable v-tth5 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  ub.inkas.obj-type
    ,input  ub.inkas.obj-code
    ,input  'get-chk':U
    ,input  'cas-shft':U
    ,output v-value-character5
    ,output v-value-date5
    ,output v-value-decimal5
    ,output v-value-integer5
    ,output cas-shft
    ,output v-param-type5
    ,INPUT-OUTPUT table-handle v-tth5
    )  .
delete object v-tth5.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  ub.inkas.obj-type
  ,input  ub.inkas.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
end.
cas-shft = cas-shft OR l-shift-on.
if from-ink then do:
  assign
  v-shift-str = substitute("&1 &2"
                          ,string(inkas.shift-date, "99/99/9999")
                          ,(if cas-shft
                            then (" СМЕНА " + shift-name-no-err(buffer inkas))
                            else "")).
  assign
  not-saled = substitute("НЕУЧТЕННЫХ ЧЕКОВ ЗА &1 НЕТ&2"
                         , v-shift-str
                         , chr(10))
  not-saled-err = substitute("ОШИБОЧНЫX чеков ЗА &1 НЕТ&2"
                              ,v-shift-str
                              ,chr(10))
  inkas-ch = "Нет НЕЗАКРЫТЫХ продаж" + CHr(10)
  .
  if chk-inf then do:
    For each  ub.chk-doc where
              ub.chk-doc.obj-type = current-store-type and
              ub.chk-doc.obj-code = current-store-code and
              ub.chk-doc.out-code = ?
    by ub.chk-doc.chk-date descending
    by ub.chk-doc.chk-time descending:
    if ((NOT cas-shft)  AND ub.shop.day-only AND ub.chk-doc.shift-date = ub.inkas.shift-date) OR
      (( cas-shft and ub.shop.day-only) AND
        ub.chk-doc.shift-date = ub.inkas.shift-date AND
        ub.chk-doc.shift-num = ub.inkas.shift-num) OR
      (NOT ub.shop.day-only AND NOT cas-shft)
    then do:
      assign
      not-saled =  substitute("Есть НЕУЧТЕННЫЙ чек за &1&2"
                                    ,string (chk-doc.shift-date, "99/99/9999")
                                    ,chr(10))
      not-all-saled-chk = yes.
    end.
    if NOT ub.chk-doc.correct then do:
      assign
      not-saled-err =   substitute("Есть ОШИБОЧНЫЙ чек за &1&2"
                                  ,string (chk-doc.shift-date, "99/99/9999")
                                  ,chr(10))
      not-all-normal-chk = yes
      .
    end.
    not-saled = substitute("Есть НЕУЧТЕННЫЙ чек за &1&2&2"
                          ,string (chk-doc.shift-date, "99/99/9999")
                          ,chr(10))
    .
    end.
  end.
end.
else do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type7 as character no-undo .
define variable v-value-character7 as character no-undo .
define variable v-value-date7 as date no-undo .
define variable v-value-decimal7 as decimal no-undo .
define variable v-value-integer7 as INTEGER no-undo .
define variable v-tth7 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-curr-obj-type
    ,input  p-curr-obj-code
    ,input  'get-chk':U
    ,input  'cas-shft':U
    ,output v-value-character7
    ,output v-value-date7
    ,output v-value-decimal7
    ,output v-value-integer7
    ,output cas-shft
    ,output v-param-type7
    ,INPUT-OUTPUT table-handle v-tth7
    ) no-error .
delete object v-tth7.
  IF not error-status:error then
  assign
  cas-shft = (conf-par = "yes").
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
cas-shft = cas-shft OR l-shift-on.
  find first ub.inkas no-lock where
          ub.inkas.obj-type = p-curr-obj-type AND
          ub.inkas.obj-code = p-curr-obj-code AND
          ub.inkas.status_ = 'новый':U use-index obj-stat no-error.
  if available ub.inkas then do:
        not-all-inkas-closed = yes.
      end.
  assign
  not-saled = "НЕУЧТЕННЫХ ЧЕКОВ НЕТ" + chr(10)
  not-saled-err =   "ОШИБОЧНЫX чеков НЕТ " + chr (10)
  inkas-ch = "Нет НЕЗАКРЫТЫХ продаж" + CHr(10)
  .
  FIND FIRST ub.shop NO-LOCK WHERE
             ub.shop.obj-code = p-curr-obj-code NO-ERROR.
  For each  ub.chk-doc no-lock  where
            ub.chk-doc.obj-type = p-curr-obj-type AND
            ub.chk-doc.obj-code = p-curr-obj-code AND
            ub.chk-doc.out-code = ?
      by ub.chk-doc.chk-date
      by ub.chk-doc.chk-time :
    if NOT not-all-saled-chk  AND
      (
        NOT not-all-inkas-closed OR
        (NOT cas-shft AND
          (  (not-all-inkas-closed AND shop.day-only AND chk-doc.shift-date = inkas.shift-date) OR
              (not-all-inkas-closed AND (NOT shop.day-only)  )
          )
        )  OR
        (cas-shft AND (not-all-inkas-closed AND inkas.shift-date = chk-doc.shift-date)
        )
      ) then do:
      assign
      not-all-saled-chk = yes
      not-saled = substitute("Самый старый НЕУЧТЕННЫЙ чек за : &1&2"
                                ,string (chk-doc.shift-date, "99/99/9999")
                                ,chr(10))
      .
    end.
    if NOT not-all-normal-chk
    AND chk-doc.correct <> yes then do:
      assign
      not-all-normal-chk = yes
      not-saled-err = substitute("Самый старый ОШИБОЧНЫЙ чек за : &1&2&2"
                                ,string (chk-doc.shift-date, "99/99/9999")
                                ,chr(10))
     .
    end.
    not-saled = substitute("Самый старый НЕУЧТЕННЫЙ чек за : &1&2&2"
                          ,string (chk-doc.shift-date, "99/99/9999")
                          ,chr(10))
    .
  end.
end.
for each inkas No-LOCK WHERE
         inkas.obj-type = p-curr-obj-type AND
         inkas.obj-code = p-curr-obj-code AND
         inkas.status_ = 'факт':U
by inkas.doc-date descending:
  if inkas.status_ = 'факт':U then do:
    inkas-ch = substitute("Дата последней закрытой продажи : &1&2&2"
                            ,string (inkas.fact-date, "99/99/9999")
                           , chr(10)).
    leave.
  end.
end.
v-notes = v-notes + not-saled +
        (if not-all-normal-chk then not-saled-err else "") +
        (if not-all-saled-chk then not-saled else "") + inkas-ch.
run waitfram-hide in this-procedure .
if interface then
run gbl/showtext.p (
                 input "Неучтенные и ошибочные чеки, последние закрытые продажи"
                ,input 60
                ,input 15
                ,input v-notes
                ).
