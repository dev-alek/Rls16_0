block-level on error undo, throw.
define input  parameter parparentproc as handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: 0100a4d3b790, 1441, test $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jun 29 18:00:05 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exp-doc2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/exp-doc2.p $":U .
define variable vss-description as character no-undo init "Выгрузка остатков в формате импорта ПН".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable g-log        as logical no-undo .
define variable v-dir-name   as character no-undo .
define variable v-type       as character no-undo .
define variable v-can-write  as logical   no-undo .
define variable c_shift-list as character no-undo .
define variable r_shift-obj  as recid no-undo .
define variable f-name       as character no-undo .
define variable v-shift-start-fact-order  as decimal no-undo .
define variable is-petrolium as logical   no-undo .
define variable is-pieces    as logical   no-undo .
define variable v-unit-base  as character no-undo .
define variable v-host-code  as integer   no-undo .
define variable v-vat-tax-value as decimal no-undo .
define variable v-sum-rubl   as decimal no-undo .
define variable v-fact-qnty  as decimal no-undo .
define variable v-wait-msg   as character no-undo .
define variable v-lines      as integer no-undo .
define variable v-ln-prev    as integer no-undo .
define variable v-tm-prev    as integer no-undo .
define buffer buf_shift-obj for ub.shift-obj .
define buffer buf_gds-obj   for ub.gds-obj .
define buffer buf_goods     for ub.goods .
define buffer buf-stk-line  for ub.stk-line .
define buffer buf_tax-rate-gds   for ub.tax-rate-gds .
define buffer buf_tax-rate-value for ub.tax-rate-value .
define stream f-txt .
g-log = no.
message "Выгрузка остатков в формате импорта ПН" skip (2)
        "Продолжать ?"
        view-as alert-box question buttons OK-Cancel update g-log.
if not g-log then return.
run gbl/dir-sel.p
     ( output v-dir-name
      ,output v-type
      ,output v-can-write
      ).
if NOT v-can-write THEN DO:
  message
      "Путь для сохранения файлов не указан."
      view-as alert-box error.
  return.
END.
  c_shift-list = "".
  run str/sht-all.w
    ( parparentproc
    , ?
    , ?
    , "b-sel"
    , "all"
    ,  v-cntxt-obj-type
    ,  v-cntxt-obj-code
    ,  ""
    ,  input-output c_shift-list
    ) no-error.
    if error-status:error then do:
      message
            vss-workfile vss-revision vss-description skip
            "Ошибка при выборе смены"  skip
            error-status :get-message( 1 ) skip
            return-value skip
            view-as alert-box error .
      return.
    end.
    if c_shift-list = "":U then do:
      message
        "Смена не выбрана"
      view-as alert-box error.
      return.
    end.
    r_shift-obj = integer(c_shift-list) no-error .
    find first buf_shift-obj no-lock where recid (buf_shift-obj) = r_shift-obj no-error .
    if available buf_shift-obj then
      f-name = substitute("&1\&2&3_&4&5&6_&7.adb", v-dir-name,
       buf_shift-obj.obj-type, buf_shift-obj.obj-code,
       year(buf_shift-obj.shift-date), month(buf_shift-obj.shift-date), day(buf_shift-obj.shift-date),
       buf_shift-obj.shift-num)
    no-error .
    if error-status:error then do:
      message
            vss-workfile vss-revision vss-description skip
            "Ошибка при поиске смены"  skip
            error-status :get-message( 1 ) skip
            return-value skip
            view-as alert-box error .
      return.
    end.
    define buffer buf_stk-tot for ub.stk-tot .
    find last buf_stk-tot no-lock
        where buf_stk-tot.obj-type = buf_shift-obj.obj-type
          and buf_stk-tot.obj-code = buf_shift-obj.obj-code
          and buf_stk-tot.shift-date = buf_shift-obj.shift-date
          and buf_stk-tot.shift-num  < buf_shift-obj.shift-num
          and buf_stk-tot.shift-num  > 0
          and buf_stk-tot.sum-type = 'crsa':U
          and buf_stk-tot.cat-id   = '##,##':U
    USE-INDEX Shift-num no-error .
    if not available buf_stk-tot then do:
    find last buf_stk-tot no-lock
        where buf_stk-tot.obj-type = buf_shift-obj.obj-type
          and buf_stk-tot.obj-code = buf_shift-obj.obj-code
          and buf_stk-tot.shift-date < buf_shift-obj.shift-date
          and buf_stk-tot.shift-num  > 0
          and buf_stk-tot.sum-type = 'crsa':U
          and buf_stk-tot.cat-id   = '##,##':U
      USE-INDEX Shift-num no-error .
    end.
    if available buf_stk-tot then v-shift-start-fact-order = buf_stk-tot.Fact-order .
    else do:
      message
        substitute( "Для смены &1 от &2 по объекту &3&4 отсуствуют предшествующие остатки"
                  , buf_shift-obj.shift-num
                  , buf_shift-obj.shift-date
                  , buf_shift-obj.obj-type, buf_shift-obj.obj-code
        )
      view-as alert-box error .
      return .
    end .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_shift-obj.obj-type
  ,input  buf_shift-obj.obj-code
  ,output v-host-code
  )  .
    assign
      v-wait-msg = "Выгрузка в файл " + f-name + " строк: &1"
      v-lines    = 0
      v-ln-prev  = v-lines + 100
      v-tm-prev  = time + 1
    .
    run waitfram-show in this-procedure (substitute(v-wait-msg, v-lines)) .
    output stream f-txt to value (f-name) .
    for each buf_gds-obj no-lock
       where buf_gds-obj.obj-type = buf_shift-obj.obj-type
         and buf_gds-obj.obj-code = buf_shift-obj.obj-code :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_gds-obj.artic
  ,  input buf_gds-obj.prod-type
  ,  input buf_gds-obj.prod-code
  , output is-petrolium
  , output is-pieces
  ) .
      if is-petrolium then next .
      v-lines = v-lines + 1 .
      if v-lines > v-ln-prev then do:
        v-ln-prev = v-lines + 100.
        if v-tm-prev < time then do:
          v-tm-prev  = time + 1 .
          run waitfram-show in this-procedure (substitute(v-wait-msg, v-lines)) .
        end .
      end.
      find last buf-stk-line no-lock
          where buf-stk-line.obj-type = buf_gds-obj.obj-type
            and buf-stk-line.obj-code = buf_gds-obj.obj-code
            and buf-stk-line.artic     = buf_gds-obj.artic
            and buf-stk-line.prod-type = buf_gds-obj.prod-type
            and buf-stk-line.prod-code = buf_gds-obj.prod-code
            and buf-stk-line.sum-type = 'cost':U
            and buf-stk-line.cat-id   = '##,##':U
            and buf-stk-line.fact-order <= v-shift-start-fact-order
            and buf-stk-line.shift-num  > 0
      use-index category no-error .
      if available buf-stk-line then assign
        v-sum-rubl  = buf-stk-line.sum-rubl
        v-fact-qnty = buf-stk-line.fact-qnty
      .
      else assign
        v-sum-rubl  = 0
        v-fact-qnty = 0
      .
      find last buf_tax-rate-gds no-lock
          where buf_tax-rate-gds.gds-code  = buf_gds-obj.gds-code
            and buf_tax-rate-gds.tax-code  = 1
            and buf_tax-rate-gds.host-code = v-host-code
            and buf_tax-rate-gds.obj-type  = buf_shift-obj.obj-type
            and buf_tax-rate-gds.obj-code  = buf_shift-obj.obj-code
            and buf_tax-rate-gds.fact-order <= v-shift-start-fact-order no-error .
      if not available buf_tax-rate-gds then
      find last buf_tax-rate-gds no-lock
          where buf_tax-rate-gds.gds-code  = buf_gds-obj.gds-code
            and buf_tax-rate-gds.tax-code  = 1
            and buf_tax-rate-gds.host-code = 0
            and buf_tax-rate-gds.obj-type  = ''
            and buf_tax-rate-gds.obj-code  = 0
            and buf_tax-rate-gds.fact-order <= v-shift-start-fact-order no-error.
      if available buf_tax-rate-gds then do:
        find last buf_tax-rate-value no-lock
            where buf_tax-rate-value.tax-code  = buf_tax-rate-gds.tax-code
              and buf_tax-rate-value.rate-code = buf_tax-rate-gds.rate-code
              and buf_tax-rate-value.host-code = v-host-code
              and buf_tax-rate-value.obj-type  = buf_shift-obj.obj-type
              and buf_tax-rate-value.obj-code  = buf_shift-obj.obj-code
              and buf_tax-rate-value.fact-order <= v-shift-start-fact-order
              and buf_tax-rate-value.status_   = 'тек':U no-error .
        if not available buf_tax-rate-value then
        find last buf_tax-rate-value no-lock
            where buf_tax-rate-value.tax-code  = buf_tax-rate-gds.tax-code
              and buf_tax-rate-value.rate-code = buf_tax-rate-gds.rate-code
              and buf_tax-rate-value.host-code = v-host-code
              and buf_tax-rate-value.obj-type  = ""
              and buf_tax-rate-value.obj-code  = 0
              and buf_tax-rate-value.fact-order <= v-shift-start-fact-order
              and buf_tax-rate-value.status_   = 'тек':U no-error .
        if not available buf_tax-rate-value then
        find last buf_tax-rate-value no-lock
            where buf_tax-rate-value.tax-code  = buf_tax-rate-gds.tax-code
              and buf_tax-rate-value.rate-code = buf_tax-rate-gds.rate-code
              and buf_tax-rate-value.host-code = 0
              and buf_tax-rate-value.obj-type  = ""
              and buf_tax-rate-value.obj-code  = 0
              and buf_tax-rate-value.fact-order <= v-shift-start-fact-order
              and buf_tax-rate-value.status_   = 'тек':U no-error .
        v-vat-tax-value = if available buf_tax-rate-value then buf_tax-rate-value.rate-value else 0 .
      end .
      else v-vat-tax-value = 0 .
      put stream f-txt unformatted
          substitute("ITEM:&1;", buf_gds-obj.artic)
           ";"
          ";"
          ";"
          buf_gds-obj.gds-code ";"
          (if v-fact-qnty <> 0 then v-sum-rubl / v-fact-qnty else v-sum-rubl) ";"
          v-fact-qnty ";"
           ";"
          ";"
          ";"
          v-vat-tax-value ";"
          ";"
          ";"
          ";"
          ";"
          "" skip
      .
    end .
    output stream f-txt close .
  run waitfram-hide in this-procedure .
message "Выгрузка закончена." view-as alert-box information buttons ok.
