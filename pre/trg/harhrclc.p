block-level on error undo, throw.
define input  parameter p-cat-code       like ub.hold-time.cat-code no-undo .
define input  parameter p-lock-code      as character no-undo .
define input  parameter p-btpr-type-code as character no-undo .
define input  parameter p-start-date     like ub.hold-time.start-date no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Перерасчет межфирменных архивов".
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
      p-vss-parameters = substitute('&1|&2|&3|&4':u,p-cat-code,p-lock-code,p-btpr-type-code,p-start-date)
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
PROCEDURE LastDate:
    def input parameter in-date as date no-undo.
    def output parameter LastDate as date no-undo.
    LastDate = ((DATE(MONTH(in-date),28,YEAR(in-date)) + 4) - DAY(DATE(MONTH(in-date),28,YEAR(in-date)) + 4)).
END PROCEDURE.
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure create-hold-time :
define input parameter p-cat-code like ub.hold-time.cat-code no-undo .
define input parameter p-start-date like ub.hold-time.start-date no-undo .
DEFINE VARIABLE v-end-date like ub.hold-time.end-date no-undo .
define buffer buf_hold-time for ub.hold-time .
define buffer last_hold-time for ub.hold-time .
  do
  on error undo, return error
  :
    find last last_hold-time no-lock
      where last_hold-time.cat-code = p-cat-code
      use-index pi
      no-error .
    run gbl/lastdate.p
      (input p-start-date
      ,output v-end-date)
      no-error .
    if error-status :error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка поиска последней даты периода" skip
      "Дата начала периода" p-start-date
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
      undo, return error.
    end.
    create buf_hold-time.
    assign
      buf_hold-time.cat-code       = p-cat-code
      buf_hold-time.time-code      = (if available last_hold-time
                                      then (last_hold-time.time-code + 1)
                                      else 1)
      buf_hold-time.time-type      = 'мес':U
      buf_hold-time.start-date     = p-start-date
      buf_hold-time.end-date       = v-end-date
      buf_hold-time.create-date    = today
      buf_hold-time.update-date    = today
      buf_hold-time.grpupdate-date = today
    .
  end.
end procedure.
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
define buffer del_hold-time           for ub.hold-time .
define buffer del_hold-trn            for ub.hold-trn .
define buffer del_hold-goods          for ub.hold-goods .
define buffer del_hold-gds-grp        for ub.hold-gds-grp .
define buffer del_hold-purch          for ub.hold-purch .
define buffer del_hold-purch-grp      for ub.hold-purch-grp .
define buffer del_hold-purch-supp     for ub.hold-purch-supp .
define buffer del_hold-purch-supp-gds for ub.hold-purch-supp-gds .
define buffer del_hold-sale           for ub.hold-sale .
define buffer del_hold-sale-grp       for ub.hold-sale-grp .
define buffer buf_trn-doc for ub.trn-doc .
define buffer buf_db      for ub.db .
define buffer buf_clients for ub.clients .
do
on error undo, return error
:
  find first del_hold-time exclusive-lock
    where del_hold-time.cat-code   = p-cat-code
      and del_hold-time.time-type  = 'мес':U
      and del_hold-time.start-date = p-start-date
    no-error .
  if not available del_hold-time
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись межфирменного архива" skip
      "cat-code" p-cat-code skip
      "time-type" 'мес':U skip
      "start-date" p-start-date skip
      view-as alert-box error .
    undo, return error.
  end.
  assign
    del_hold-time.status_        = 'удаленные':U
    del_hold-time.grpupdate-date = today
    del_hold-time.update-date    = today
  .
  define variable v-ind as integer   no-undo .
  assign
    v-ind = 0
  .
  for each del_hold-trn
    where del_hold-trn.cat-code  = del_hold-time.cat-code
      and del_hold-trn.time-code = del_hold-time.time-code
  on error undo, return error
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Перерасчет межфирменных архивов. Удаление списка документов за период. Удалено &1."
                          ,v-ind
                          )
        ) .
    end.
    delete del_hold-trn .
  end.
  assign
    v-ind = 0
  .
  for each del_hold-goods
    where del_hold-goods.cat-code  = del_hold-time.cat-code
      and del_hold-goods.time-code = del_hold-time.time-code
  on error undo, return error
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Перерасчет межфирменных архивов. Удаление списка товаров за период. Удалено &1."
                          ,v-ind
                          )
        ) .
    end.
    delete del_hold-goods .
  end.
  assign
    v-ind = 0
  .
  for each del_hold-gds-grp
    where del_hold-gds-grp.cat-code  = del_hold-time.cat-code
      and del_hold-gds-grp.time-code = del_hold-time.time-code
  on error undo, return error
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Перерасчет межфирменных архивов. Удаление списка групп товаров за период. Удалено &1."
                          ,v-ind
                          )
        ) .
    end.
    delete del_hold-gds-grp .
  end.
  assign
    v-ind = 0
  .
  for each del_hold-purch
    where del_hold-purch.cat-code  = del_hold-time.cat-code
      and del_hold-purch.time-code = del_hold-time.time-code
  on error undo, return error
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Перерасчет межфирменных архивов. Удаление списка приходов за период. Удалено &1."
                          ,v-ind
                          )
        ) .
    end.
    delete del_hold-purch .
  end.
  assign
    v-ind = 0
  .
  for each del_hold-purch-grp
    where del_hold-purch-grp.cat-code  = del_hold-time.cat-code
      and del_hold-purch-grp.time-code = del_hold-time.time-code
  on error undo, return error
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Перерасчет межфирменных архивов. Удаление списка приходов по группам за период. Удалено &1."
                          ,v-ind
                          )
        ) .
    end.
    delete del_hold-purch-grp .
  end.
  assign
    v-ind = 0
  .
  for each del_hold-purch-supp
    where del_hold-purch-supp.cat-code  = del_hold-time.cat-code
      and del_hold-purch-supp.time-code = del_hold-time.time-code
  on error undo, return error
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Перерасчет межфирменных архивов. Удаление списка приходов по поставщикам за период. Удалено &1."
                          ,v-ind
                          )
        ) .
    end.
    delete del_hold-purch-supp .
  end.
  assign
    v-ind = 0
  .
  for each del_hold-purch-supp-gds
    where del_hold-purch-supp-gds.cat-code  = del_hold-time.cat-code
      and del_hold-purch-supp-gds.time-code = del_hold-time.time-code
  on error undo, return error
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Перерасчет межфирменных архивов. Удаление списка приходов по поставщикам по товарам за период. Удалено &1."
                          ,v-ind
                          )
        ) .
    end.
    delete del_hold-purch-supp-gds .
  end.
  assign
    v-ind = 0
  .
  for each del_hold-sale
    where del_hold-sale.cat-code  = del_hold-time.cat-code
      and del_hold-sale.time-code = del_hold-time.time-code
  on error undo, return error
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Перерасчет межфирменных архивов. Удаление списка продаж за период. Удалено &1."
                          ,v-ind
                          )
        ) .
    end.
    delete del_hold-sale .
  end.
  assign
    v-ind = 0
  .
  for each del_hold-sale-grp
    where del_hold-sale-grp.cat-code  = del_hold-time.cat-code
      AND del_hold-sale-grp.time-code = del_hold-time.time-code
  on error undo, return error
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Перерасчет межфирменных архивов. Удаление списка продаж по группам за период. Удалено &1."
                          ,v-ind
                          )
        ) .
    end.
    delete del_hold-sale-grp .
  end.
  for each buf_db no-lock
  ,each buf_clients no-lock
    where buf_clients.db-num = buf_db.db-num
  ,each buf_trn-doc no-lock
    where buf_trn-doc.obj-type = buf_clients.obj-type
      and buf_trn-doc.obj-code = buf_clients.obj-code
      and buf_trn-doc.status_ = 'факт':U
      and buf_trn-doc.fact-date >= del_hold-time.start-date
      and buf_trn-doc.fact-date <= del_hold-time.end-date
  on error undo, return error
  :
    run waitfram-show in this-procedure
      (input substitute("Перерасчет межфирменных архивов. Документ &1. Дата &2"
                        ,buf_trn-doc.doc-code
                        ,buf_trn-doc.fact-date
                        )
      ) .
    define buffer buf_BatchProcess for ub.BatchProcess .
    find first buf_BatchProcess exclusive-lock
      where buf_BatchProcess.bp_type     = p-btpr-type-code
        and buf_BatchProcess.bp_status   = 'N':U
        and buf_batchprocess.charkey_one = buf_trn-doc.doc-code
      no-error .
    if available buf_BatchProcess
    then do:
      delete buf_BatchProcess .
    end.
    run trg/harhtclc.p
      (input p-cat-code
      ,input p-lock-code
      ,input p-btpr-type-code
      ,input buf_trn-doc.doc-code
      ) no-error .
    if error-status :error
    then do:
      undo,
      return error ("Ошибка при расчете межфирменного архива:" + chr(10) +
                    "cat-code:" + chr(32) + string(p-cat-code) + chr(10) +
                    "time-code:" + chr(32) + string(del_hold-time.time-code) + chr(10) +
                    "документ:" + chr(32) + buf_trn-doc.doc-code + chr(10)
                    ).
    end.
  end.
  assign
    del_hold-time.status_ = 'текущие':U
  .
  run waitfram-hide in this-procedure .
end.
