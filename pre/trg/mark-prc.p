block-level on error undo, throw.
define input  parameter p-doc-code            as character no-undo .
define input  parameter p-fact-order          as decimal   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отметка переоценок, закрытых после указанного документа как требующих перерасчета".
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
      p-vss-parameters = substitute('&1|&2',p-doc-code,p-fact-order)
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
define buffer buf_trn-doc for ub.trn-doc .
define buffer buf_doc-line for ub.doc-line .
define buffer buf_price-list for ub.price-list .
define variable v-archive-recalc as logical   no-undo .
define temp-table temp-price-doc no-undo
  field doc-num as character
  index xpk is primary unique doc-num
.
define variable v-price-list-found as logical   no-undo .
do
on error undo, return error return-value
:
  assign
    v-archive-recalc = false
  .
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if not available buf_trn-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" p-doc-code skip
      view-as alert-box error .
    undo, return error .
  end.
  for each buf_doc-line
    where buf_doc-line.doc-code = p-doc-code
  on error undo, return error
  :
    run process-price-list in this-procedure
      (input  buf_doc-line.obj-type
      ,input  buf_doc-line.obj-code
      ,input  buf_doc-line.artic
      ,input  buf_doc-line.prod-type
      ,input  buf_doc-line.prod-code
      ,input  p-fact-order
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры process-price-list" skip
        "Документ" p-doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        "Фактический номер" p-fact-order skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
  find first temp-price-doc
    no-error .
  if available temp-price-doc
  then do:
    define variable v-message as character no-undo .
    define variable v-need-stop-arh as logical   no-undo .
    assign
      v-need-stop-arh = false
    .
    define buffer calc-arh-lock_batchprocess for ub.batchprocess .
    run gbl/lock-prc.p
      (input 'btpr':U
      ,input buf_trn-doc.obj-code
      ,input 0
      ,input 0
      ,input buf_trn-doc.obj-type
      ,input ""
      ,input ""
      ,input "Объект,,, ,,,Расчет складского архива по товарам"
      ,input false
      ,buffer calc-arh-lock_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры блокировки расчета складского архива по товарам" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error "Ошибка при вызове процедуры блокировки расчёта складского архива по товарам" .
      end.
      assign
        v-need-stop-arh = true
      .
    end.
    define buffer stop-arh-news-lock_btpr for batchprocess .
    if v-need-stop-arh = true
    then do:
      do transaction
      on error undo, return error return-value
      :
        create stop-arh-news-lock_btpr .
        assign
          stop-arh-news-lock_btpr.bp_type       = 'lock':U + 'rsrn':U
          stop-arh-news-lock_btpr.bp_status     = 'N':U
          stop-arh-news-lock_btpr.Key#_One      = buf_trn-doc.obj-code
          stop-arh-news-lock_btpr.Key#_Two      = 0
          stop-arh-news-lock_btpr.Key#_Three    = 0
          stop-arh-news-lock_btpr.CharKey_One   = buf_trn-doc.obj-type
          stop-arh-news-lock_btpr.CharKey_Two   = buf_trn-doc.doc-code
          stop-arh-news-lock_btpr.CharKey_Three = ""
        .
        define variable v-start-lock-time   as int64     no-undo .
        define variable v-start-lock-second as integer   no-undo .
        assign
          v-start-lock-time = etime
        .
        wait_block:
        do while true
        :
          assign
            v-start-lock-second = integer((etime - v-start-lock-time) / 1000)
          .
          run waitfram-show in this-procedure
            (input waitfram-join-function("Архив по товарам рассчитывается на другой машине"
                                         ,"Отправлено сообщение о необходимости остановки расчёта складского архива"
                                         ,substitute("Ожидание освобождение ресурса расчёта складского архива &1", string(v-start-lock-second, 'HH:MM:SS':U))
                                         )
            ) .
          run gbl/lock-prc.p
            (input 'btpr':U
            ,input buf_trn-doc.obj-code
            ,input 0
            ,input 0
            ,input buf_trn-doc.obj-type
            ,input ""
            ,input ""
            ,input "Объект,,, ,,,Расчет складского архива по товарам"
            ,input false
            ,buffer calc-arh-lock_batchprocess
            ) no-error .
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры блокировки расчета складского архива по товарам" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error "В данный момент рассчитывается складской архив по товарам" .
            end.
          end.
          else do:
            run waitfram-hide in this-procedure .
            leave wait_block .
          end.
          pause 1 no-message .
        end.
        delete stop-arh-news-lock_btpr .
        run waitfram-hide in this-procedure .
      end.
    end.
    define variable v-need-stop-ahsp as logical   no-undo .
    assign
      v-need-stop-ahsp = false
    .
    define buffer calc-supp-arh-lock_batchprocess for ub.batchprocess .
    run gbl/lock-prc.p
      (input 'ahsp':U
      ,input buf_trn-doc.obj-code
      ,input 0
      ,input 0
      ,input buf_trn-doc.obj-type
      ,input ""
      ,input ""
      ,input "Объект,,, ,,,Расчет складского складского архива по поставщикам"
      ,input false
      ,buffer calc-supp-arh-lock_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры блокировки расчета складского архива по поставщикам" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error "Ошибка при вызове процедуры блокировки расчёта складского архива по поставщикам" .
      end.
      assign
        v-need-stop-ahsp = true
      .
    end.
    define buffer stop-ahsp-news-lock_btpr for batchprocess .
    if v-need-stop-ahsp = true
    then do:
      do transaction
      on error undo, return error return-value
      :
        create stop-ahsp-news-lock_btpr .
        assign
          stop-ahsp-news-lock_btpr.bp_type       = 'lock':U + 'rssn':U
          stop-ahsp-news-lock_btpr.bp_status     = 'N':U
          stop-ahsp-news-lock_btpr.Key#_One      = buf_trn-doc.obj-code
          stop-ahsp-news-lock_btpr.Key#_Two      = 0
          stop-ahsp-news-lock_btpr.Key#_Three    = 0
          stop-ahsp-news-lock_btpr.CharKey_One   = buf_trn-doc.obj-type
          stop-ahsp-news-lock_btpr.CharKey_Two   = buf_trn-doc.doc-code
          stop-ahsp-news-lock_btpr.CharKey_Three = ""
        .
        assign
          v-start-lock-time = etime
        .
        wait_block:
        do while true
        :
          assign
            v-start-lock-second = integer((etime - v-start-lock-time) / 1000)
          .
          run waitfram-show in this-procedure
            (input waitfram-join-function("Архив по поставщикам рассчитывается на другой машине"
                                         ,"Отправлено сообщение о необходимости остановки расчёта складского архива"
                                         ,substitute("Ожидание освобождение ресурса расчёта складского архива &1", string(v-start-lock-second, 'HH:MM:SS':U))
                                         )
            ) .
          run gbl/lock-prc.p
            (input 'ahsp':U
            ,input buf_trn-doc.obj-code
            ,input 0
            ,input 0
            ,input buf_trn-doc.obj-type
            ,input ""
            ,input ""
            ,input "Объект,,, ,,,Расчет складского архива по поставщикам"
            ,input false
            ,buffer calc-supp-arh-lock_batchprocess
            ) no-error .
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры блокировки расчета архива по поставщикам" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error "Ошибка при вызове процедуры блокировки расчета архива по поставщикам" .
            end.
          end.
          else do:
            leave wait_block .
          end.
          pause 1 no-message .
        end.
        delete stop-ahsp-news-lock_btpr .
        run waitfram-hide in this-procedure .
      end.
    end.
    define variable v-need-stop-aht as logical   no-undo .
    assign
      v-need-stop-aht = false
    .
    define buffer calc-aht-lock_batchprocess for ub.batchprocess .
    run gbl/lock-prc.p
      (input 'ahtb':U
      ,input buf_trn-doc.obj-code
      ,input 0
      ,input 0
      ,input buf_trn-doc.obj-type
      ,input ""
      ,input ""
      ,input "Объект,,, ,,,Расчет складского архива по типам приобретения"
      ,input false
      ,buffer calc-aht-lock_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры блокировки расчета складского архива по поставщикам" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error "Ошибка при вызове процедуры блокировки расчёта складского архива по поставщикам" .
      end.
      assign
        v-need-stop-aht = true
      .
    end.
    define buffer stop-aht-news-lock_btpr for batchprocess .
    if v-need-stop-aht = true
    then do:
      do transaction
      on error undo, return error return-value
      :
        create stop-aht-news-lock_btpr .
        assign
          stop-aht-news-lock_btpr.bp_type       = 'lock':U + 'rstn':U
          stop-aht-news-lock_btpr.bp_status     = 'N':U
          stop-aht-news-lock_btpr.Key#_One      = buf_trn-doc.obj-code
          stop-aht-news-lock_btpr.Key#_Two      = 0
          stop-aht-news-lock_btpr.Key#_Three    = 0
          stop-aht-news-lock_btpr.CharKey_One   = buf_trn-doc.obj-type
          stop-aht-news-lock_btpr.CharKey_Two   = buf_trn-doc.doc-code
          stop-aht-news-lock_btpr.CharKey_Three = ""
        .
        assign
          v-start-lock-time = etime
        .
        wait_block:
        do while true
        :
          assign
            v-start-lock-second = integer((etime - v-start-lock-time) / 1000)
          .
          run waitfram-show in this-procedure
            (input waitfram-join-function("Архив по типам приобретения рассчитывается на другой машине"
                                         ,"Отправлено сообщение о необходимости остановки расчёта складского архива"
                                         ,substitute("Ожидание освобождение ресурса расчёта складского архива &1", string(v-start-lock-second, 'HH:MM:SS':U))
                                         )
            ) .
          run gbl/lock-prc.p
            (input 'ahtb':U
            ,input buf_trn-doc.obj-code
            ,input 0
            ,input 0
            ,input buf_trn-doc.obj-type
            ,input ""
            ,input ""
            ,input "Объект,,, ,,,Расчет складского архива по типам приобретения"
            ,input false
            ,buffer calc-aht-lock_batchprocess
            ) no-error .
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры блокировки расчета складского архива по типам приобретения" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error "В данный момент рассчитывается складской архив по типам приобретения" .
            end.
          end.
          else do:
            leave wait_block .
          end.
          pause 1 no-message .
        end.
        delete stop-aht-news-lock_btpr .
        run waitfram-hide in this-procedure .
      end.
    end.
    for each temp-price-doc
    on error undo, return error return-value
    :
      run trg/nu_prc.p
        (input temp-price-doc.doc-num
        ,input 'price-doc':U
        ,input buf_trn-doc.obj-type
        ,input buf_trn-doc.obj-code
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры nu_prc.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
  find first ub.batchprocess exclusive-lock
    where ub.batchprocess.bp_type   = 'arh':U
      and ub.batchprocess.bp_status = 'N':U
      and  ub.batchprocess.key#_one  = buf_trn-doc.obj-code
      and ub.batchprocess.charkey_one = temp-price-doc.doc-num
      and ub.batchprocess.charkey_two = 'price-doc':U
      and ub.batchprocess.charkey_three = buf_trn-doc.obj-type
  no-error .
      if not available ub.batchprocess
      then do:
        assign
          v-archive-recalc = true
        .
      end.
  find first ub.batchprocess exclusive-lock
    where ub.batchprocess.bp_type   = 'aht':U
      and ub.batchprocess.bp_status = 'N':U
      and  ub.batchprocess.key#_one  = buf_trn-doc.obj-code
      and ub.batchprocess.charkey_one = temp-price-doc.doc-num
      and ub.batchprocess.charkey_two = 'price-doc':U
      and ub.batchprocess.charkey_three = buf_trn-doc.obj-type
  no-error .
      if not available ub.batchprocess
      then do:
        assign
          v-archive-recalc = true
        .
      end.
    end.
    if v-archive-recalc = true
    then do:
      run trg/markarh.p
        (input buf_trn-doc.obj-type
        ,input buf_trn-doc.obj-code
        ,input buf_trn-doc.fact-date
        ,input p-doc-code
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Закрытие документа задним числом" skip
          "Ошибка при отметке складского архива по товару, что он требует перерасчета" skip
          "Документ" buf_trn-doc.doc-code skip
          "Расширенный тип документа" buf_trn-doc.ext-doc-type skip
          "Объект" buf_trn-doc.obj-type buf_trn-doc.obj-code skip
          "Дата" buf_trn-doc.fact-date skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      run trg/markahsp.p
        (input  buf_trn-doc.obj-type
        ,input  buf_trn-doc.obj-code
        ,input  buf_trn-doc.fact-date
        ,input  p-doc-code
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Закрытие документа задним числом" skip
          "Ошибка при отметке складского архива по поставщикам, что он требует перерасчета" skip
          "Документ" buf_trn-doc.doc-code skip
          "Расширенный тип документа" buf_trn-doc.ext-doc-type skip
          "Объект" buf_trn-doc.obj-type buf_trn-doc.obj-code skip
          "Дата" buf_trn-doc.fact-date skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      run trg/markaht.p
        (input  buf_trn-doc.obj-type
        ,input  buf_trn-doc.obj-code
        ,input  buf_trn-doc.fact-date
        ,input  p-doc-code
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Закрытие документа задним числом" skip
          "Ошибка при отметке складского архива по типам приобретения, что он требует перерасчета" skip
          "Документ" buf_trn-doc.doc-code skip
          "Расширенный тип документа" buf_trn-doc.ext-doc-type skip
          "Объект" buf_trn-doc.obj-type buf_trn-doc.obj-code skip
          "Дата" buf_trn-doc.fact-date skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end.
procedure process-price-list :
  define input  parameter p-obj-type         like ub.trn-doc.obj-type     no-undo.
  define input  parameter p-obj-code         like ub.trn-doc.obj-code     no-undo.
  define input  parameter p-artic            like ub.doc-line.artic       no-undo.
  define input  parameter p-prod-type        like ub.doc-line.prod-type   no-undo.
  define input  parameter p-prod-code        like ub.doc-line.prod-code   no-undo.
  define input  parameter p-fact-order       like ub.trn-doc.fact-order   no-undo.
  define variable vss-description as character no-undo init "process-price-list: поиск строк переоценок, подлежащих перерасчету".
  define variable v-is-new   as   logical              no-undo.
  define variable v-root-node like ub.bar-code.node-code no-undo.
  define buffer buf_price-list for ub.price-list.
  define buffer buf_goods      for ub.goods.
  define variable v-b-code like ub.bar-code.b-code no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      no-error .
    if not available buf_goods then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-b-code
  ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении основного бар-кода товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_price-list
      where buf_price-list.obj-type   = p-obj-type
        and buf_price-list.obj-code   = p-obj-code
        and buf_price-list.b-code     = v-b-code
        and buf_price-list.price-type = ""
        and buf_price-list.fact-order > p-fact-order
    on error undo, return error
    :
      run register-price-doc in this-procedure
        (input buf_price-list.doc-num
        ) .
    end.
  end.
end procedure.
procedure register-price-doc :
  define input  parameter p-doc-num as character no-undo .
  define buffer buf_temp-price-doc for temp-price-doc .
  do
  on error undo, return error return-value
  :
    find first buf_temp-price-doc
      where buf_temp-price-doc.doc-num = p-doc-num
      no-error .
    if not available buf_temp-price-doc
    then do:
      create buf_temp-price-doc .
      assign
        buf_temp-price-doc.doc-num = p-doc-num
      .
    end.
  end.
end procedure.
