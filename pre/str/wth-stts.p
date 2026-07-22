block-level on error undo, throw.
define input parameter parparentproc  as widget-handle no-undo .
DEFINE       PARAM BUFFER buf_wth-doc  FOR ub.wth-doc .
DEFINE INPUT PARAMETER    par-mode AS  CHAR NO-UNDO .
DEFINE INPUT PARAMETER    par-talk AS  LOG  NO-UNDO .
define input parameter parobj-type like ub.clients.obj-type no-undo .
define input parameter parobj-code like ub.clients.obj-code no-undo .
define input parameter p-file-name-err    as   char         no-undo.
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author: expertek $":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile: wth-stts.p $":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive: str/wth-stts.p $":U.
define variable vss-description AS CHAR NO-UNDO INIT "изменение статуса (открытие/закрытие) документов МЦ":U.
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
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
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
procedure wth-lib_cur-stock-place:
define input  parameter parobj-type like ub.clients.obj-type   no-undo.
define input  parameter parobj-code like ub.clients.obj-code   no-undo.
define input  parameter parw-p-code like ub.wth-pobj.w-p-code  no-undo.
define input  parameter parwth-code like ub.wth-pobj.wth-code  no-undo.
define output parameter parstock    like ub.wth-pobj.income-pl no-undo.
define buffer bf_wth-pobj for ub.wth-pobj.
find first bf_wth-pobj where bf_wth-pobj.obj-type = parobj-type and
                             bf_wth-pobj.obj-code = parobj-code and
                             bf_wth-pobj.w-p-code = parw-p-code and
                             bf_wth-pobj.wth-code = parwth-code no-lock no-error.
if available bf_wth-pobj then assign parstock = bf_wth-pobj.income-pl - bf_wth-pobj.incass-pl.
                         else assign parstock = 0.
end procedure.
procedure wth-lib_cur-stock-obj:
define input  parameter parobj-type like ub.clients.obj-type   no-undo.
define input  parameter parobj-code like ub.clients.obj-code   no-undo.
define input  parameter parwth-code like ub.wth-obj.wth-code   no-undo.
define output parameter parstock    like ub.wth-obj.income     no-undo.
define buffer bf_wth-obj for ub.wth-obj.
find first bf_wth-obj where bf_wth-obj.obj-type = parobj-type and
                            bf_wth-obj.obj-code = parobj-code and
                            bf_wth-obj.wth-code = parwth-code no-lock no-error.
if available bf_wth-obj then assign parstock = bf_wth-obj.income - bf_wth-obj.incass.
                        else assign parstock = 0.
end.
FUNCTION wth-lib_cur-stock-obj-func RETURNS DECIMAL (INPUT parobj-type AS CHARACTER,
                                                     INPUT parobj-code AS INTEGER,
                                                     INPUT parwth-code AS INTEGER):
define buffer bf_wth-obj for ub.wth-obj.
find first bf_wth-obj where bf_wth-obj.obj-type = parobj-type and
                            bf_wth-obj.obj-code = parobj-code and
                            bf_wth-obj.wth-code = parwth-code no-lock no-error.
if available bf_wth-obj then return (bf_wth-obj.income - bf_wth-obj.incass).
                        else return 0.00.
end function.
FUNCTION wth-lib_cur-stock-host-func RETURNS DECIMAL (INPUT parhost-code AS INTEGER,
                                                      INPUT parwth-code  AS INTEGER):
define buffer bf_wth-obj for ub.wth-obj.
define variable v-stock like ub.wth-obj.income no-undo.
for each bf_wth-obj no-lock where bf_wth-obj.host-code = parhost-code and
                                  bf_wth-obj.wth-code = parwth-code :
  v-stock = v-stock +  bf_wth-obj.income - bf_wth-obj.incass.
end.
return v-stock.
end function.
procedure wth-lib_full-inf-shift:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num    like ub.shift-obj.shift-num   no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                                                                                       cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.shift-date = parshift-date and                        cur_wth-line.shift-num  = parshift-num  and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sdn no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                                                                             start_wth-line.wth-code   = parwth-code         and                                (start_wth-line.shift-date = parshift-date and                           start_wth-line.shift-num  < parshift-num  or                            start_wth-line.shift-date < parshift-date ) and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sdn no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income - cur_wth-line.incass              parincome        = cur_wth-line.income                     parincome-cassa  = cur_wth-line.income-cassa               parincome-other  = cur_wth-line.income-other               parincass        = cur_wth-line.incass                     parincass-bank   = cur_wth-line.incass-bank                parincass-other  = cur_wth-line.incass-other.              parincass-cassa  = cur_wth-line.incass-cassa.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income     - start_wth-line.incass               parstock-end     = cur_wth-line.income       - cur_wth-line.incass                 parincome        = cur_wth-line.income       - start_wth-line.income               parincome-cassa  = cur_wth-line.income-cassa - start_wth-line.income-cassa         parincome-other  = cur_wth-line.income-other - start_wth-line.income-other         parincass        = cur_wth-line.incass       - start_wth-line.incass               parincass-bank   = cur_wth-line.incass-bank  - start_wth-line.incass-bank          parincass-other  = cur_wth-line.incass-other - start_wth-line.incass-other.        parincass-cassa  = cur_wth-line.incass-cassa - start_wth-line.incass-cassa.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income - start_wth-line.incass                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-inter:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num    like ub.shift-obj.shift-num   no-undo.                        define input  parameter parshift-date1  like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num1   like ub.shift-obj.shift-num   no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                                                                                       cur_wth-line.wth-code   = parwth-code   and                                        ((cur_wth-line.shift-date = parshift-date1 and                           cur_wth-line.shift-num  <= parshift-num1)  or                            cur_wth-line.shift-date < parshift-date1 ) and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sdn no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                                                                             start_wth-line.wth-code   = parwth-code         and                                (start_wth-line.shift-date = parshift-date and                           start_wth-line.shift-num  < parshift-num  or                            start_wth-line.shift-date < parshift-date ) and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sdn no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income - cur_wth-line.incass              parincome        = cur_wth-line.income                     parincome-cassa  = cur_wth-line.income-cassa               parincome-other  = cur_wth-line.income-other               parincass        = cur_wth-line.incass                     parincass-bank   = cur_wth-line.incass-bank                parincass-other  = cur_wth-line.incass-other.              parincass-cassa  = cur_wth-line.incass-cassa.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income     - start_wth-line.incass               parstock-end     = cur_wth-line.income       - cur_wth-line.incass                 parincome        = cur_wth-line.income       - start_wth-line.income               parincome-cassa  = cur_wth-line.income-cassa - start_wth-line.income-cassa         parincome-other  = cur_wth-line.income-other - start_wth-line.income-other         parincass        = cur_wth-line.incass       - start_wth-line.incass               parincass-bank   = cur_wth-line.incass-bank  - start_wth-line.incass-bank          parincass-other  = cur_wth-line.incass-other - start_wth-line.incass-other.        parincass-cassa  = cur_wth-line.incass-cassa - start_wth-line.incass-cassa.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income - start_wth-line.incass                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-period-place:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parw-p-code     like ub.wth-pobj.w-p-code  no-undo.                        define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num    like ub.shift-obj.shift-num   no-undo.                        define input  parameter parshift-date1  like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num1   like ub.shift-obj.shift-num   no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                        cur_wth-line.w-p-code = parw-p-code and                                                               cur_wth-line.wth-code   = parwth-code   and                                        ((cur_wth-line.shift-date = parshift-date1 and                           cur_wth-line.shift-num  <= parshift-num1)  or                            cur_wth-line.shift-date < parshift-date1 ) and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sdn no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                start_wth-line.w-p-code = parw-p-code and                                                             start_wth-line.wth-code   = parwth-code         and                                (start_wth-line.shift-date = parshift-date and                           start_wth-line.shift-num  < parshift-num  or                            start_wth-line.shift-date < parshift-date ) and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sdn no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income-pl - cur_wth-line.incass-pl              parincome        = cur_wth-line.income-pl                     parincome-cassa  = cur_wth-line.income-cassa-pl               parincome-other  = cur_wth-line.income-other-pl               parincass        = cur_wth-line.incass-pl                     parincass-bank   = cur_wth-line.incass-bank-pl                parincass-other  = cur_wth-line.incass-other-pl.              parincass-cassa  = cur_wth-line.incass-cassa-pl.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income-pl     - start_wth-line.incass-pl               parstock-end     = cur_wth-line.income-pl       - cur_wth-line.incass-pl                 parincome        = cur_wth-line.income-pl       - start_wth-line.income-pl               parincome-cassa  = cur_wth-line.income-cassa-pl - start_wth-line.income-cassa-pl         parincome-other  = cur_wth-line.income-other-pl - start_wth-line.income-other-pl         parincass        = cur_wth-line.incass-pl       - start_wth-line.incass-pl               parincass-bank   = cur_wth-line.incass-bank-pl  - start_wth-line.incass-bank-pl          parincass-other  = cur_wth-line.incass-other-pl - start_wth-line.incass-other-pl.        parincass-cassa  = cur_wth-line.incass-cassa-pl - start_wth-line.incass-cassa-pl.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income-pl - start_wth-line.incass-pl                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-place:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input parameter parw-p-code   like ub.wth-line.w-p-code     no-undo.                        define input parameter parshift-date like ub.shift-obj.shift-date  no-undo.                        define input parameter parshift-num  like ub.shift-obj.shift-num   no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                        cur_wth-line.w-p-code   = parw-p-code and                                                               cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.shift-date = parshift-date and                        cur_wth-line.shift-num  = parshift-num  and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sdn-pl no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                start_wth-line.w-p-code = parw-p-code and                                                             start_wth-line.wth-code   = parwth-code         and                                (start_wth-line.shift-date = parshift-date and                           start_wth-line.shift-num  < parshift-num  or                            start_wth-line.shift-date < parshift-date ) and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sdn-pl no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income-pl - cur_wth-line.incass-pl              parincome        = cur_wth-line.income-pl                     parincome-cassa  = cur_wth-line.income-cassa-pl               parincome-other  = cur_wth-line.income-other-pl               parincass        = cur_wth-line.incass-pl                     parincass-bank   = cur_wth-line.incass-bank-pl                parincass-other  = cur_wth-line.incass-other-pl.              parincass-cassa  = cur_wth-line.incass-cassa-pl.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income-pl     - start_wth-line.incass-pl               parstock-end     = cur_wth-line.income-pl       - cur_wth-line.incass-pl                 parincome        = cur_wth-line.income-pl       - start_wth-line.income-pl               parincome-cassa  = cur_wth-line.income-cassa-pl - start_wth-line.income-cassa-pl         parincome-other  = cur_wth-line.income-other-pl - start_wth-line.income-other-pl         parincass        = cur_wth-line.incass-pl       - start_wth-line.incass-pl               parincass-bank   = cur_wth-line.incass-bank-pl  - start_wth-line.incass-bank-pl          parincass-other  = cur_wth-line.incass-other-pl - start_wth-line.incass-other-pl.        parincass-cassa  = cur_wth-line.incass-cassa-pl - start_wth-line.incass-cassa-pl.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income-pl - start_wth-line.incass-pl                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-date:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                                                                                       cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.shift-date = parshift-date   and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sd no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                                                                             start_wth-line.wth-code   = parwth-code         and                                start_wth-line.shift-date < parshift-date and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sd no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income - cur_wth-line.incass              parincome        = cur_wth-line.income                     parincome-cassa  = cur_wth-line.income-cassa               parincome-other  = cur_wth-line.income-other               parincass        = cur_wth-line.incass                     parincass-bank   = cur_wth-line.incass-bank                parincass-other  = cur_wth-line.incass-other.              parincass-cassa  = cur_wth-line.incass-cassa.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income     - start_wth-line.incass               parstock-end     = cur_wth-line.income       - cur_wth-line.incass                 parincome        = cur_wth-line.income       - start_wth-line.income               parincome-cassa  = cur_wth-line.income-cassa - start_wth-line.income-cassa         parincome-other  = cur_wth-line.income-other - start_wth-line.income-other         parincass        = cur_wth-line.incass       - start_wth-line.incass               parincass-bank   = cur_wth-line.incass-bank  - start_wth-line.incass-bank          parincass-other  = cur_wth-line.incass-other - start_wth-line.incass-other.        parincass-cassa  = cur_wth-line.incass-cassa - start_wth-line.incass-cassa.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income - start_wth-line.incass                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-date-place:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input parameter parw-p-code   like ub.wth-line.w-p-code     no-undo.                        define input parameter parshift-date like ub.shift-obj.shift-date  no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                        cur_wth-line.w-p-code   = parw-p-code and                                                               cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.shift-date = parshift-date   and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sd-pl no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                start_wth-line.w-p-code = parw-p-code and                                                             start_wth-line.wth-code   = parwth-code         and                                start_wth-line.shift-date < parshift-date and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sd-pl no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income-pl - cur_wth-line.incass-pl              parincome        = cur_wth-line.income-pl                     parincome-cassa  = cur_wth-line.income-cassa-pl               parincome-other  = cur_wth-line.income-other-pl               parincass        = cur_wth-line.incass-pl                     parincass-bank   = cur_wth-line.incass-bank-pl                parincass-other  = cur_wth-line.incass-other-pl.              parincass-cassa  = cur_wth-line.incass-cassa-pl.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income-pl     - start_wth-line.incass-pl               parstock-end     = cur_wth-line.income-pl       - cur_wth-line.incass-pl                 parincome        = cur_wth-line.income-pl       - start_wth-line.income-pl               parincome-cassa  = cur_wth-line.income-cassa-pl - start_wth-line.income-cassa-pl         parincome-other  = cur_wth-line.income-other-pl - start_wth-line.income-other-pl         parincass        = cur_wth-line.incass-pl       - start_wth-line.incass-pl               parincass-bank   = cur_wth-line.incass-bank-pl  - start_wth-line.incass-bank-pl          parincass-other  = cur_wth-line.incass-other-pl - start_wth-line.incass-other-pl.        parincass-cassa  = cur_wth-line.incass-cassa-pl - start_wth-line.incass-cassa-pl.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income-pl - start_wth-line.incass-pl                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-calend-date:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parfact-date    like ub.wth-line.fact-date    no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                                                                                       cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.fact-date  = parfact-date  and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-cld no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                                                                             start_wth-line.wth-code   = parwth-code         and                                start_wth-line.fact-date  < parfact-date   and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-cld no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income - cur_wth-line.incass              parincome        = cur_wth-line.income                     parincome-cassa  = cur_wth-line.income-cassa               parincome-other  = cur_wth-line.income-other               parincass        = cur_wth-line.incass                     parincass-bank   = cur_wth-line.incass-bank                parincass-other  = cur_wth-line.incass-other.              parincass-cassa  = cur_wth-line.incass-cassa.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income     - start_wth-line.incass               parstock-end     = cur_wth-line.income       - cur_wth-line.incass                 parincome        = cur_wth-line.income       - start_wth-line.income               parincome-cassa  = cur_wth-line.income-cassa - start_wth-line.income-cassa         parincome-other  = cur_wth-line.income-other - start_wth-line.income-other         parincass        = cur_wth-line.incass       - start_wth-line.incass               parincass-bank   = cur_wth-line.incass-bank  - start_wth-line.incass-bank          parincass-other  = cur_wth-line.incass-other - start_wth-line.incass-other.        parincass-cassa  = cur_wth-line.incass-cassa - start_wth-line.incass-cassa.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income - start_wth-line.incass                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-calend-date-place:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input parameter parw-p-code  like ub.wth-line.w-p-code  no-undo.                        define input parameter parfact-date like ub.wth-line.fact-date no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                        cur_wth-line.w-p-code   = parw-p-code and                                                               cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.fact-date  = parfact-date  and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-cld-pl no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                start_wth-line.w-p-code = parw-p-code and                                                             start_wth-line.wth-code   = parwth-code         and                                start_wth-line.fact-date  < parfact-date   and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-cld-pl no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income-pl - cur_wth-line.incass-pl              parincome        = cur_wth-line.income-pl                     parincome-cassa  = cur_wth-line.income-cassa-pl               parincome-other  = cur_wth-line.income-other-pl               parincass        = cur_wth-line.incass-pl                     parincass-bank   = cur_wth-line.incass-bank-pl                parincass-other  = cur_wth-line.incass-other-pl.              parincass-cassa  = cur_wth-line.incass-cassa-pl.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income-pl     - start_wth-line.incass-pl               parstock-end     = cur_wth-line.income-pl       - cur_wth-line.incass-pl                 parincome        = cur_wth-line.income-pl       - start_wth-line.income-pl               parincome-cassa  = cur_wth-line.income-cassa-pl - start_wth-line.income-cassa-pl         parincome-other  = cur_wth-line.income-other-pl - start_wth-line.income-other-pl         parincass        = cur_wth-line.incass-pl       - start_wth-line.incass-pl               parincass-bank   = cur_wth-line.incass-bank-pl  - start_wth-line.incass-bank-pl          parincass-other  = cur_wth-line.incass-other-pl - start_wth-line.incass-other-pl.        parincass-cassa  = cur_wth-line.incass-cassa-pl - start_wth-line.incass-cassa-pl.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income-pl - start_wth-line.incass-pl                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
FUNCTION get-curr RETURNS CHARACTER
  (buffer loc-wealth for ub.wealth ) :
define buffer buf_currency for ub.currency.
if loc-wealth.curr-code = ? or loc-wealth.is-money = no then
return loc-wealth.unit-base.
FIND FIRST buf_currency no-lock where
          buf_currency.curr-code = loc-wealth.curr-code No-ERROR.
if avail buf_currency then
  RETURN buf_currency.curr-abbr.
else return "".
END FUNCTION.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
DEFINE VARIABLE j_fact-num  LIKE ub.wth-doc.fact-num   NO-UNDO.
DEFINE VARIABLE j_fact-time LIKE ub.wth-doc.fact-time  NO-UNDO.
DEFINE VARIABLE d_fact-date LIKE ub.wth-doc.fact-date  NO-UNDO.
DEFINE VARIABLE d-fact-ord  LIKE ub.wth-doc.fact-order NO-UNDO.
DEFINE VARIABLE d-shift-ord LIKE ub.wth-doc.fact-order NO-UNDO.
DEFINE VARIABLE day-end-ord LIKE ub.wth-doc.fact-order NO-UNDO.
define variable v-obj-date  as date no-undo .
define variable v-obj-shift-date as date no-undo .
define variable v-obj-shift-num as integer no-undo .
define variable v-obj-shift-name as character no-undo .
DEFINE VARIABLE l-shift-on  AS   LOGICAL               NO-UNDO.
DEFINE VARIABLE var-mes as character no-undo .
DEFINE VARIABLE l-need-check-inv as logical no-undo init false .
DEFINE VARIABLE l-fact-close as logical no-undo .
DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE  not-all-doced as logical init no.
DEFINE VARIABLE not-all-normal as logical init no.
DEFINE VARIABLE  not-all-closed as logical no-undo init no.
DEFINE VARIABLE var-status_ like ub.wth-doc.status_ no-undo .
DEFINE VARIABLE varchk-doc-exist as logical no-undo .
define variable v-rec as recid no-undo .
define variable v-notes as character no-undo .
define variable v-vararh-mode  as integer      no-undo.
define variable v-warning    as logical      no-undo.
define variable v-is-back-date as logical no-undo .
define variable v-recalc-fact-ord as decimal no-undo .
define variable v-wth-doc-code as character no-undo .
define variable v-fact-date as date no-undo .
define variable var-log     as logical no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE vardoc-sum-dtl like ub.wth-dtl.doc-sum no-undo .
DEFINE VARIABLE varfact-sum-dtl like ub.wth-dtl.fact-sum no-undo .
DEFINE VARIABLE varbef-sum-dtl like ub.wth-dtl.bef-sum no-undo .
DEFINE VARIABLE varaft-sum-dtl like ub.wth-dtl.aft-sum no-undo .
DEFINE VARIABLE vardoc-sum-line like ub.wth-line.doc-sum no-undo .
DEFINE VARIABLE varfact-sum-line like ub.wth-line.fact-sum no-undo .
DEFINE VARIABLE varbef-sum-line like ub.wth-line.bef-sum no-undo .
DEFINE VARIABLE varaft-sum-line like ub.wth-line.aft-sum no-undo .
DEFINE VARIABLE varsum-gds-rubl-line  like ub.wth-line.sum-gds-rubl no-undo .
DEFINE VARIABLE varsum-gds-base-line  like ub.wth-line.sum-gds-base no-undo .
DEFINE VARIABLE varsum-gds-rubl-dtl   like ub.wth-dtl.sum-gds-rubl no-undo .
DEFINE VARIABLE varsum-gds-base-dtl   like ub.wth-dtl.sum-gds-base no-undo .
DEFINE VARIABLE varsum-gds-rubl-parts like ub.wth-dtl.sum-gds-rubl no-undo .
DEFINE VARIABLE varsum-gds-base-parts like ub.wth-dtl.sum-gds-base no-undo .
DEFINE VARIABLE varis-dtl as logical no-undo .
DEFINE VARIABLE varis-part as logical no-undo .
DEFINE VARIABLE varinst-sum like ub.chk-pay.tot-sum no-undo .
DEFINE VARIABLE varchk-type like ub.chk-doc.chk-type no-undo .
define buffer check_chk-pay for ub.chk-pay .
define buffer check_chk-doc for ub.chk-doc .
define buffer bufdsum_wealth   for ub.wealth.
define buffer buf_clients   FOR ub.clients.
define buffer buf_wth-line  FOR ub.wth-line.
define buffer buf_wth-dtl   FOR ub.wth-dtl.
define buffer buf_wth-obj   FOR ub.wth-obj.
define buffer buf_wth-parts for ub.wth-parts.
define buffer buf_wealth    for ub.wealth.
define buffer buf_sysconf   FOR ub.sysconf.
define buffer buf_out_wth-doc for ub.wth-doc.
IF NOT AVAIL buf_wth-doc THEN DO:
  var-mes = "Документ движения МЦ не найден!".
  IF par-talk
  then
  MESSAGE var-mes VIEW-AS ALERT-BOX ERROR.
  RETURN ERROR var-mes.
END.
ELSE DO:
  ASSIGN v-rec = RECID( buf_wth-doc ).
END.
assign
v-wth-doc-code = buf_wth-doc.doc-code.
IF buf_wth-doc.status_ = 'факт':U THEN DO:
  var-mes = "Документ " + buf_wth-doc.doc-code + " уже закрыт на ФАКТ!".
  IF par-talk
  then
  MESSAGE var-mes VIEW-AS ALERT-BOX ERROR.
  RETURN error var-mes.
END.
run waitfram-show in this-procedure ( Input "Ждите..." ).
if buf_wth-doc.doc-type = 'декл':U then
l-need-check-inv  = no.
if buf_wth-doc.doc-type = 'инв':U and
   buf_wth-doc.status_ = 'накл':U and
   par-mode = "+":U then
   l-need-check-inv  = yes
   .
if buf_wth-doc.doc-type = 'инв':U and
   buf_wth-doc.status_ = 'разрешен':U and
   par-mode = "+":U then
   l-need-check-inv  = no
   .
if buf_wth-doc.doc-type = 'инв':U and
   buf_wth-doc.status_ = 'разрешен':U and
   par-mode = "-":U then
   l-need-check-inv  = no
   .
if buf_wth-doc.auto-fill then do:
FIND FIRST buf_sysconf No-LOCK WHERE
           buf_sysconf.host-code = buf_wth-doc.host-code No-ERROR.
if not available buf_sysconf then return error.
if buf_wth-doc.cli-type = buf_sysconf.sale-type AND
   buf_wth-doc.cli-code = buf_sysconf.sale-code then
   varchk-doc-exist = no.
 else varchk-doc-exist = yes.
end.
find first ub.sys-ctrl No-LOCK.
Main-Block:
DO TRANSACTION ON ERROR UNDO Main-Block, RETURN ERROR :
  FIND buf_wth-doc EXCLUSIVE-LOCK WHERE
       RECID( buf_wth-doc ) = v-rec.
l-fact-close = (if (buf_wth-doc.status_ = 'разрешен':U or buf_wth-doc.auto-fill) and par-mode = "+":U
                then yes
                else no).
if l-fact-close and
   buf_wth-doc.auto-fill = yes and
   varchk-doc-exist then do:
    run str/chk-winf.p (
                input parparentproc
               ,input buf_wth-doc.host-code
               ,input buf_wth-doc.obj-type
               ,input buf_wth-doc.obj-code
               ,INPUT no
               ,INPUT yes
               ,INPUT recid(buf_wth-doc)
               ,output v-notes
               ,output not-all-doced
               ,output not-all-normal
               ,output not-all-closed) no-error.
    if error-status:error  then do:
       run waitfram-hide in this-procedure .
       return error.
    end.
    if par-talk then do:
      message
      v-notes skip
      "Закрытие автодокумента МЦ" +
      ( if ub.sys-ctrl.db-num <> 0 then " и отправка его в офис." else "." ) skip (2)
      "Вы уверены ?" skip (2)
      "Закрытый документ нельзя исправить или удалить." skip
      "Чтобы ПРОВЕРИТЬ ДОКУМЕНТ еще раз, выберите CANCEL."
      view-as alert-box question buttons OK-Cancel update loc#log.
      if NOT loc#log  then do:
          run waitfram-hide in this-procedure .
          return error.
      end.
    end.
 end.
  run trg/lock-wth.p
    (input buf_wth-doc.doc-code
    ,input l-need-check-inv
    ,input 0
    ,input l-fact-close
    ,input false
    ) no-error.
  if error-status :error then do:
    run waitfram-hide in this-procedure .
    undo Main-Block, return error .
  end.
  if buf_wth-doc.doc-type <> 'обмен':U then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
vardoc-sum-dtl = 0
varfact-sum-dtl = 0
varbef-sum-dtl = 0
varaft-sum-dtl = 0
vardoc-sum-line = 0
varfact-sum-line = 0
varbef-sum-line = 0
varaft-sum-line = 0
varinst-sum = 0
varsum-gds-rubl-line = 0
varsum-gds-base-line = 0
varsum-gds-rubl-dtl = 0
varsum-gds-base-dtl = 0
varsum-gds-rubl-parts = 0
varsum-gds-base-parts = 0
.
FOR EACH buf_wth-line No-LOCK WHERE
         buf_wth-line.doc-code = buf_wth-doc.doc-code:
  assign
  vardoc-sum-dtl = 0
  varfact-sum-dtl = 0
  varbef-sum-dtl = 0
  varaft-sum-dtl = 0
  varsum-gds-rubl-dtl = 0
  varsum-gds-base-dtl = 0
  varis-dtl = no
  .
  FOR EACH buf_wth-dtl No-LOCK WHERE
           buf_wth-dtl.doc-code = buf_wth-line.doc-code AND
           buf_wth-dtl.wth-code = buf_wth-line.wth-code AND
           buf_wth-dtl.w-p-code = buf_wth-line.w-p-code:
    assign
    varis-dtl = yes
    vardoc-sum-dtl = vardoc-sum-dtl + buf_wth-dtl.doc-sum
    varfact-sum-dtl = varfact-sum-dtl + buf_wth-dtl.fact-sum
    varbef-sum-dtl = varbef-sum-dtl + buf_wth-dtl.bef-sum
    varaft-sum-dtl = varaft-sum-dtl + buf_wth-dtl.aft-sum
    varsum-gds-rubl-dtl = varsum-gds-rubl-dtl + buf_wth-dtl.sum-gds-rubl
    varsum-gds-base-dtl = varsum-gds-base-dtl + buf_wth-dtl.sum-gds-base
    .
    assign varsum-gds-rubl-parts = 0
    varsum-gds-base-parts = 0
    varis-part = no.
    for each buf_wth-parts no-lock where
      buf_wth-parts.w-p-code = buf_wth-dtl.w-p-code and
      buf_wth-parts.wth-code = buf_wth-dtl.wth-code and
      buf_wth-parts.par-code = buf_wth-dtl.par-code and
      buf_wth-parts.out-code = buf_wth-dtl.doc-code and
      buf_wth-parts.stts = 0 :
      assign
      varis-part = yes
      varsum-gds-rubl-parts = varsum-gds-rubl-parts + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
      varsum-gds-base-parts = varsum-gds-base-parts + buf_wth-parts.fact-qnty * buf_wth-parts.price-base
      .
    end.
    if varis-part or can-find(first bufdsum_wealth where bufdsum_wealth.wth-code = buf_wth-dtl.wth-code and bufdsum_wealth.is-ser = 1 no-lock  ) then do:
      if varsum-gds-rubl-parts <> buf_wth-dtl.sum-gds-rubl then do:
        var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                  "Код МЦ" +  chr(32) +  string(buf_wth-dtl.wth-code) + chr(10) +
                  "Код МХ" + chr(32) + string(buf_wth-dtl.w-p-code) + chr(10) +
                  "Код номинала" + chr(32) + string(buf_wth-dtl.par-code) + chr(10) +
                  "Сумма по связанным товарам в рублях по партиям не равна сумме по номиналу" + chr(10) + chr(10) +
                  "Сумма по связанным товарам в рублях   по партиям=" + string(varsum-gds-rubl-parts) + chr(32) +
                  "Сумма по связанным товарам в рублях   по номиналу=" + string(buf_wth-dtl.sum-gds-rubl).
        if par-talk then
        message var-mes
        view-as alert-box error .
          return error var-mes.
      end.
      if varsum-gds-base-parts <> buf_wth-dtl.sum-gds-base then do:
        var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                  "Код МЦ" +  chr(32) +  string(buf_wth-dtl.wth-code) + chr(10) +
                  "Код МХ" + chr(32) + string(buf_wth-dtl.w-p-code) + chr(10) +
                  "Код номинала" + chr(32) + string(buf_wth-dtl.par-code) + chr(10) +
                  "Сумма по связанным товарам в базовой валюте по партиям не равна сумме по номиналу" + chr(32) +  chr(10) +
                  "Сумма по связанным товарам в базовой валюте по партиям=" + string(varsum-gds-base-parts) + chr(32) +
                  "Сумма по связанным товарам в базовой валюте по номиналу=" + string(buf_wth-dtl.sum-gds-base).
        if par-talk then
        message var-mes
        view-as alert-box error .
          return error var-mes.
      end.
    end.
  END.
  if varis-dtl then do:
    if vardoc-sum-dtl <> buf_wth-line.doc-sum then do:
      var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                "Код МЦ" +  chr(32) +  string(buf_wth-line.wth-code) + chr(10) +
                "Код МХ" + chr(32) + string(buf_wth-line.w-p-code) + chr(10) +
                "Сумма по номиналам не равна сумме по строке" + chr(32) +  chr(10) +
                "Сумма по документу по номиналам=" + string(vardoc-sum-dtl) + chr(32) +
                "Сумма по документу по строке=" + string(buf_wth-line.doc-sum).
      if par-talk then
      message var-mes
      view-as alert-box error .
        return error var-mes.
    end.
    if buf_wth-doc.status_ = 'факт':U then do:
      if varfact-sum-dtl <> buf_wth-line.fact-sum then do:
        var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                  "Код МЦ" +  chr(32) +  string(buf_wth-line.wth-code) + chr(10) +
                  "Код МХ" + chr(32) + string(buf_wth-line.w-p-code) + chr(10) +
                  "Сумма по номиналам не равна сумме по строке" + chr(32) +  chr(10) +
                  (if buf_wth-doc.doc-type = 'инв':U
                  then
                  string(
                  "Сумма расхождений по номиналам=" + string(varfact-sum-dtl) + chr(32) +
                  "Сумма расхождений по строке=" + string(buf_wth-line.fact-sum)
                  )
                  else
                  string(
                  "Сумма факт по номиналам=" + string(varfact-sum-dtl) + chr(32) +
                  "Сумма факт по строке=" + string(buf_wth-line.fact-sum))
                  ).
        if par-talk then
        message var-mes
        view-as alert-box error .
          return error var-mes.
      end.
    end.
    if varbef-sum-dtl <> buf_wth-line.bef-sum then do:
      var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                "Код МЦ" +  chr(32) +  string(buf_wth-line.wth-code) + chr(10) +
                "Код МХ" + chr(32) + string(buf_wth-line.w-p-code) + chr(10) +
                "Сумма по номиналам не равна сумме по строке" + chr(32) +  chr(10) +
                "Сумма план по номиналам=" + string(varbef-sum-dtl) + chr(32) +
                "Сумма план по строке=" + string(buf_wth-line.bef-sum).
      if par-talk then
      message var-mes
      view-as alert-box error .
        return error var-mes.
    end.
    if buf_wth-doc.doc-type = 'инв':U then do:
      if buf_wth-doc.status_ = 'факт':U then do:
        if varaft-sum-dtl <> buf_wth-line.aft-sum then do:
          var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                    "Код МЦ" +  chr(32) +  string(buf_wth-line.wth-code) + chr(10) +
                    "Код МХ" + chr(32) + string(buf_wth-line.w-p-code) + chr(10) +
                    "Сумма по номиналам не равна сумме по строке" + chr(32) +  chr(10) +
                    "Сумма факт по номиналам=" + string(varaft-sum-dtl) + chr(32) +
                    "Сумма факт по строке=" + string(buf_wth-line.aft-sum).
          if par-talk then
          message var-mes
          view-as alert-box error .
            return error var-mes.
        end.
      end.
    end.
    if varsum-gds-rubl-dtl <> buf_wth-line.sum-gds-rubl then do:
      var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                "Код МЦ" +  chr(32) +  string(buf_wth-line.wth-code) + chr(10) +
                "Код МХ" + chr(32) + string(buf_wth-line.w-p-code) + chr(10) +
                "Сумма по связанным товарам в рублях  по номиналам не равна сумме по строке" + chr(32) + chr(10) +
                "Сумма по связанным товарам в рублях  по номиналам=" + string(varsum-gds-rubl-dtl) + chr(32) +
                "Сумма по связанным товарам в рублях  по строке=" + string(buf_wth-line.sum-gds-rubl).
      if par-talk then
      message var-mes
      view-as alert-box error .
        return error var-mes.
    end.
    if varsum-gds-base-dtl <> buf_wth-line.sum-gds-base then do:
      var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                "Код МЦ" +  chr(32) +  string(buf_wth-line.wth-code) + chr(10) +
                "Код МХ" + chr(32) + string(buf_wth-line.w-p-code) + chr(10) +
                "Сумма по связанным товарам в базовой валюте по номиналам не равна сумме по строке" + chr(32) +  chr(10) +
                "Сумма по связанным товарам в базовой валюте по номиналам=" + string(varsum-gds-base-dtl) + chr(32) +
                "Сумма по связанным товарам в базовой валюте по строке=" + string(buf_wth-line.sum-gds-base).
      if par-talk then
      message var-mes
      view-as alert-box error .
        return error var-mes.
    end.
  end .
  assign
  vardoc-sum-line = vardoc-sum-line + buf_wth-line.doc-sum
  varfact-sum-line = varfact-sum-line + buf_wth-line.fact-sum
  varbef-sum-line = varbef-sum-line + buf_wth-line.bef-sum
  varaft-sum-line = varaft-sum-line + buf_wth-line.aft-sum
  varsum-gds-rubl-line = varsum-gds-rubl-line + buf_wth-line.sum-gds-rubl
  varsum-gds-base-line = varsum-gds-base-line + buf_wth-line.sum-gds-base
  .
END.
if vardoc-sum-line <> buf_wth-doc.doc-sum then do:
  var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
            "Сумма по строкам не равна сумме по шапке" + chr(32) + chr(10) +
            "Сумма по документу по строкам=" + string(vardoc-sum-line) + chr(32) +
            "Сумма по документу по шапке=" + string(buf_wth-doc.doc-sum).
  if par-talk then
  message var-mes
  view-as alert-box error .
    return error var-mes.
end.
if buf_wth-doc.status_ = 'факт':U then do:
  if varfact-sum-line <> buf_wth-doc.fact-sum then do:
    var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
              "Сумма по строкам не равна сумме по шапке" + chr(32) + chr(10) +
              (if buf_wth-doc.doc-type = 'инв':U
              then
                string(
                "Сумма расхождений по строкам=" + string(varfact-sum-line) + chr(32) +
                "Сумма расхождений по шапке=" + string(buf_wth-doc.fact-sum)
                )
              else
              string(
              "Сумма факт по строкам=" + string(varfact-sum-line) + chr(32) +
              "Сумма факт по шапке=" + string(buf_wth-doc.fact-sum))
              ).
    if par-talk then
    message var-mes
    view-as alert-box error .
      return error var-mes.
  end.
end.
if varbef-sum-line <> buf_wth-doc.bef-sum then do:
  var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
            "Сумма по строкам не равна сумме по шапке" + chr(32) + chr(10) +
            "Сумма план по строкам=" + string(varbef-sum-line) + chr(32) +
            "Сумма план по шапке=" + string(buf_wth-doc.bef-sum).
  if par-talk then
  message var-mes
  view-as alert-box error .
    return error var-mes.
end.
if buf_wth-doc.doc-type = 'инв':U then do:
  if varaft-sum-line <> buf_wth-doc.aft-sum then do:
    var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
              "Сумма по строкам не равна сумме по шапке" + chr(32) + chr(10) +
              "Сумма факт по строкам=" + string(varaft-sum-line) + chr(32) +
              "Сумма факт по шапке=" + string(buf_wth-doc.aft-sum).
    if par-talk then
    message var-mes
    view-as alert-box error .
      return error var-mes.
  end.
end.
if varsum-gds-rubl-line <> buf_wth-doc.sum-gds-rubl then do:
  var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
            "Сумма по связанным товарам в рублях  по строкам не равна сумме по шапке" + chr(32) + chr(10) +
            "Сумма по связанным товарам в рублях  по строкам=" + string(varsum-gds-rubl-line) + chr(32) +
            "Сумма по связанным товарам в рублях  по шапке=" + string(buf_wth-doc.sum-gds-rubl).
  if par-talk then
  message var-mes   varsum-gds-rubl-line  buf_wth-doc.sum-gds-rubl
  view-as alert-box error .
    return error var-mes.
end.
if varsum-gds-base-line <> buf_wth-doc.sum-gds-base then do:
  var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
            "Сумма по связанным товарам в базовой валюте по строкам не равна сумме по шапке" + chr(32) +   chr(10) +
            "Сумма по связанным товарам в базовой валюте по строкам=" + string(varsum-gds-base-line) + chr(32) +
            "Сумма по связанным товарам в базовой валюте по шапке=" + string(buf_wth-doc.sum-gds-base).
  if par-talk then
  message var-mes
  view-as alert-box error .
    return error var-mes.
end.
if buf_wth-doc.auto-fill and varchk-doc-exist then do:
  for each check_chk-doc WHERE
           check_chk-doc.out-code = buf_wth-doc.doc-code AND
           check_chk-doc.obj-type = buf_wth-doc.obj-type AND
           check_chk-doc.obj-code = buf_wth-doc.obj-code,
      EACH check_chk-pay No-LOCK WHERE
           check_chk-pay.doc-code = check_chk-doc.doc-code:
    varinst-sum = varinst-sum + check_chk-pay.tot-sum.
    varchk-type = check_chk-doc.chk-type.
  end.
  if buf_wth-doc.doc-type = 'рас':U then do:
    assign
    varinst-sum = - varinst-sum
    .
  end.
  if buf_wth-doc.doc-type = 'инв':U then do:
    if string(varchk-type) = '4':U then dO:
    end.
    else do:
      if varinst-sum <> buf_wth-doc.aft-sum then do:
        var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                  "Сумма по строкам чеков МЦ не равна сумме факт по шапке" + chr(32) + chr(10) +
                  "Сумма по строкам чеков МЦ=" + string(varinst-sum) + chr(32) +
                  "Сумма факт по шапке=" + string(buf_wth-doc.aft-sum).
        if par-talk then
        message var-mes
        view-as alert-box error .
          return error var-mes.
      end.
    end.
  end.
  else do:
    if varinst-sum <> buf_wth-doc.doc-sum then do:
      var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                "Сумма по строкам чеков МЦ не равна сумме документа по шапке" + chr(32) + chr(10) +
                "Сумма по строкам чеков МЦ=" + string(varinst-sum) + chr(32) +
                "Сумма документа по шапке=" + string(buf_wth-doc.doc-sum).
        if par-talk then
        message var-mes
        view-as alert-box error .
          return error var-mes.
    end.
    if varinst-sum <> buf_wth-doc.fact-sum
    and buf_wth-doc.doc-type <> 'декл':U
    then do:
      var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                "Сумма по строкам чеков МЦ не равна сумме факт по шапке" + chr(32) + chr(10) +
                "Сумма по строкам чеков МЦ=" + string(varinst-sum) + chr(32) +
                "Сумма факт по шапке=" + string(buf_wth-doc.fact-sum).
      if par-talk then
      message var-mes
      view-as alert-box error .
        return error var-mes.
    end.
    if buf_wth-doc.doc-type = 'декл':U
    and buf_wth-doc.fact-sum <> 0 then do:
      var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                "Тип" + chr(32) + buf_wth-doc.doc-type +
                "Сумма факт по шапке <> 0" .
      if par-talk then
      message var-mes
      view-as alert-box error .
        return error var-mes.
    end.
  end.
end.
  end.
  var-status_ = buf_wth-doc.status_.
  if var-status_ = 'накл':U and (buf_wth-doc.auto-fill or not buf_wth-doc.doc-type = 'инв':U) then var-status_ = "auto":U.
  IF par-mode = "+":U THEN DO:
      if var-status_ =  'накл':U or
         var-status_  = "auto":U THEN DO:
        FOR EACH buf_wth-line NO-LOCK WHERE
                 buf_wth-line.doc-code = buf_wth-doc.doc-code ON ERROR UNDO Main-Block, RETURN ERROR :
          FIND FIRST ub.wth-line EXCLUSIVE-LOCK WHERE
              RECID( ub.wth-line ) = RECID( buf_wth-line ).
          IF buf_wth-doc.doc-type = 'инв':U THEN DO:
            if buf_wth-doc.auto-fill and
               can-find(first ub.chk-doc No-LOCK WHERE
                              ub.chk-doc.obj-type = buf_wth-doc.obj-type AND
                              ub.chk-doc.obj-code = buf_wth-doc.obj-code AND
                              ub.chk-doc.out-code = buf_wth-doc.doc-code AND
                              ub.chk-doc.chk-type = integer('4':U)) then do:
              run wth-lib_cur-stock-place in this-procedure (
                                                               input  buf_wth-doc.obj-type
                                                              ,input  buf_wth-doc.obj-code
                                                              ,input  buf_wth-line.w-p-code
                                                              ,input  buf_wth-line.wth-code
                                                              ,output buf_wth-line.bef-sum
                                                              ) no-error.
              ASSIGN
              Buf_wth-line.aft-sum  = Buf_wth-line.bef-sum + buf_wth-line.fact-sum
              Buf_wth-line.doc-sum  = 0
              buf_wth-line.status_ = 'разрешен':U
              .
            end.
            else do:
              ASSIGN
              Buf_wth-line.aft-sum  = Buf_wth-line.bef-sum
              Buf_wth-line.doc-sum  = 0
              buf_wth-line.status_ = 'разрешен':U
              .
            end.
          END.
          ELSE DO:
          END.
          FOR EACH buf_wth-dtl NO-LOCK WHERE
                  buf_wth-dtl.doc-code = buf_wth-line.doc-code AND
                  buf_wth-dtl.wth-code = buf_wth-line.wth-code AND
                  buf_wth-dtl.w-p-code = buf_wth-line.w-p-code  ON ERROR UNDO Main-Block, RETURN ERROR :
            FIND FIRST ub.wth-dtl EXCLUSIVE-LOCK WHERE
                      RECID( ub.wth-dtl ) = RECID( buf_wth-dtl ).
            IF buf_wth-doc.doc-type = 'инв':U THEN DO:
              ASSIGN
              Buf_wth-dtl.aft-sum  = Buf_wth-dtl.bef-sum
              Buf_wth-dtl.doc-sum  = 0
              .
            END.
            ELSE DO:
            END.
          END.
        END.
        IF buf_wth-doc.doc-type = 'инв':U THEN DO:
          if buf_wth-doc.auto-fill and
               can-find(first ub.chk-doc No-LOCK WHERE
                              ub.chk-doc.obj-type = buf_wth-doc.obj-type AND
                              ub.chk-doc.obj-code = buf_wth-doc.obj-code AND
                              ub.chk-doc.out-code = buf_wth-doc.doc-code AND
                              ub.chk-doc.chk-type = integer('4':U)) then do:
            ASSIGN
            buf_wth-doc.aft-sum = buf_wth-doc.bef-sum + buf_wth-doc.fact-sum
            buf_wth-doc.doc-sum = 0
            .
          end.
          else do:
           ASSIGN
            buf_wth-doc.aft-sum = buf_wth-doc.bef-sum
            buf_wth-doc.doc-sum = 0
            .
          end.
        END.
        else do:
        end.
        ASSIGN buf_wth-doc.status_ = 'разрешен':U.
      END.
      if var-status_ = 'разрешен':U or
         var-status_ = "auto":U THEN DO:
        if not buf_wth-doc.status_ = 'разрешен':U then.
        else do:
        FIND FIRST buf_clients NO-LOCK WHERE
                  buf_clients.obj-type = parobj-type AND
                  buf_clients.obj-code = parobj-code NO-ERROR.
        IF NOT AVAIL buf_clients THEN DO:
          var-mes = "Нет объекта" + parobj-type + string(parobj-code) +  "в справочнике клиентов!".
          IF par-talk THEN DO:
            MESSAGE var-mes
            VIEW-AS ALERT-BOX ERROR.
          END.
          run waitfram-hide in this-procedure .
          UNDO Main-Block, RETURN ERROR var-mes.
        END.
        IF buf_wth-doc.obj-type <> parobj-type OR
           buf_wth-doc.obj-code <> parobj-code OR
           buf_clients.db-num <> g#db-num THEN DO:
          var-mes = "Закрыть на ФАКТ можно только на объекте!".
          IF par-talk THEN DO:
            MESSAGE var-mes
            VIEW-AS ALERT-BOX ERROR.
          END.
          run waitfram-hide in this-procedure .
          UNDO Main-Block, RETURN ERROR var-mes.
        END.
        FOR EACH buf_wth-line NO-LOCK WHERE
                buf_wth-line.doc-code = buf_wth-doc.doc-code ON ERROR UNDO Main-Block, RETURN ERROR :
          FIND FIRST ub.wth-line EXCLUSIVE-LOCK WHERE
              RECID( ub.wth-line ) = RECID( buf_wth-line ).
          IF buf_wth-doc.doc-type = 'инв':U THEN DO:
            if buf_wth-doc.auto-fill and
                can-find(first ub.chk-doc No-LOCK WHERE
                                ub.chk-doc.obj-type = buf_wth-doc.obj-type AND
                                ub.chk-doc.obj-code = buf_wth-doc.obj-code AND
                                ub.chk-doc.out-code = buf_wth-doc.doc-code AND
                                ub.chk-doc.chk-type = integer('4':U)) then do:
              run wth-lib_cur-stock-place in this-procedure (
                                                               input  buf_wth-doc.obj-type
                                                              ,input  buf_wth-doc.obj-code
                                                              ,input  buf_wth-line.w-p-code
                                                              ,input  buf_wth-line.wth-code
                                                              ,output buf_wth-line.bef-sum
                                                              ) no-error.
              ASSIGN
              Buf_wth-line.aft-sum  = Buf_wth-line.bef-sum + buf_wth-line.fact-sum
              buf_wth-line.status_ = 'факт':U
              .
            end.
            else do:
              ASSIGN
              Buf_wth-line.fact-sum  = Buf_wth-line.aft-sum - buf_wth-line.bef-sum
              buf_wth-line.status_ = 'факт':U
              .
            end.
          END.
          else do:
            ASSIGN
            buf_wth-line.status_ = 'факт':U
            .
          end.
          FOR EACH buf_wth-dtl NO-LOCK WHERE
                  buf_wth-dtl.doc-code = buf_wth-line.doc-code AND
                  buf_wth-dtl.wth-code = buf_wth-line.wth-code AND
                  buf_wth-dtl.w-p-code = buf_wth-line.w-p-code  ON ERROR UNDO Main-Block, RETURN ERROR :
            FIND FIRST ub.wth-dtl EXCLUSIVE-LOCK WHERE
                      RECID( ub.wth-dtl ) = RECID( buf_wth-dtl ).
            IF buf_wth-doc.doc-type = 'инв':U THEN DO:
              ASSIGN
              Buf_wth-dtl.fact-sum  = Buf_wth-dtl.aft-sum - buf_wth-dtl.bef-sum
              .
            END.
          END.
        END.
        IF buf_wth-doc.doc-type = 'инв':U THEN DO:
          if buf_wth-doc.auto-fill and
              can-find(first ub.chk-doc No-LOCK WHERE
                              ub.chk-doc.obj-type = buf_wth-doc.obj-type AND
                              ub.chk-doc.obj-code = buf_wth-doc.obj-code AND
                              ub.chk-doc.out-code = buf_wth-doc.doc-code AND
                              ub.chk-doc.chk-type = integer('4':U)) then do:
            ASSIGN
            buf_wth-doc.aft-sum = buf_wth-doc.bef-sum + buf_wth-doc.fact-sum
            .
           end.
           else do:
            ASSIGN
            buf_wth-doc.fact-sum = buf_wth-doc.aft-sum - buf_wth-doc.bef-sum
            .
           end.
        END.
        if buf_wth-doc.doc-type <> 'обмен':U then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
vardoc-sum-dtl = 0
varfact-sum-dtl = 0
varbef-sum-dtl = 0
varaft-sum-dtl = 0
vardoc-sum-line = 0
varfact-sum-line = 0
varbef-sum-line = 0
varaft-sum-line = 0
varinst-sum = 0
varsum-gds-rubl-line = 0
varsum-gds-base-line = 0
varsum-gds-rubl-dtl = 0
varsum-gds-base-dtl = 0
varsum-gds-rubl-parts = 0
varsum-gds-base-parts = 0
.
FOR EACH buf_wth-line No-LOCK WHERE
         buf_wth-line.doc-code = buf_wth-doc.doc-code:
  assign
  vardoc-sum-dtl = 0
  varfact-sum-dtl = 0
  varbef-sum-dtl = 0
  varaft-sum-dtl = 0
  varsum-gds-rubl-dtl = 0
  varsum-gds-base-dtl = 0
  varis-dtl = no
  .
  FOR EACH buf_wth-dtl No-LOCK WHERE
           buf_wth-dtl.doc-code = buf_wth-line.doc-code AND
           buf_wth-dtl.wth-code = buf_wth-line.wth-code AND
           buf_wth-dtl.w-p-code = buf_wth-line.w-p-code:
    assign
    varis-dtl = yes
    vardoc-sum-dtl = vardoc-sum-dtl + buf_wth-dtl.doc-sum
    varfact-sum-dtl = varfact-sum-dtl + buf_wth-dtl.fact-sum
    varbef-sum-dtl = varbef-sum-dtl + buf_wth-dtl.bef-sum
    varaft-sum-dtl = varaft-sum-dtl + buf_wth-dtl.aft-sum
    varsum-gds-rubl-dtl = varsum-gds-rubl-dtl + buf_wth-dtl.sum-gds-rubl
    varsum-gds-base-dtl = varsum-gds-base-dtl + buf_wth-dtl.sum-gds-base
    .
    assign varsum-gds-rubl-parts = 0
    varsum-gds-base-parts = 0
    varis-part = no.
    for each buf_wth-parts no-lock where
      buf_wth-parts.w-p-code = buf_wth-dtl.w-p-code and
      buf_wth-parts.wth-code = buf_wth-dtl.wth-code and
      buf_wth-parts.par-code = buf_wth-dtl.par-code and
      buf_wth-parts.out-code = buf_wth-dtl.doc-code and
      buf_wth-parts.stts = 0 :
      assign
      varis-part = yes
      varsum-gds-rubl-parts = varsum-gds-rubl-parts + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
      varsum-gds-base-parts = varsum-gds-base-parts + buf_wth-parts.fact-qnty * buf_wth-parts.price-base
      .
    end.
    if varis-part or can-find(first bufdsum_wealth where bufdsum_wealth.wth-code = buf_wth-dtl.wth-code and bufdsum_wealth.is-ser = 1 no-lock  ) then do:
      if varsum-gds-rubl-parts <> buf_wth-dtl.sum-gds-rubl then do:
        var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                  "Код МЦ" +  chr(32) +  string(buf_wth-dtl.wth-code) + chr(10) +
                  "Код МХ" + chr(32) + string(buf_wth-dtl.w-p-code) + chr(10) +
                  "Код номинала" + chr(32) + string(buf_wth-dtl.par-code) + chr(10) +
                  "Сумма по связанным товарам в рублях по партиям не равна сумме по номиналу" + chr(10) + chr(10) +
                  "Сумма по связанным товарам в рублях   по партиям=" + string(varsum-gds-rubl-parts) + chr(32) +
                  "Сумма по связанным товарам в рублях   по номиналу=" + string(buf_wth-dtl.sum-gds-rubl).
        if par-talk then
        message var-mes
        view-as alert-box error .
        UNDO Main-Block,  return error var-mes.
      end.
      if varsum-gds-base-parts <> buf_wth-dtl.sum-gds-base then do:
        var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                  "Код МЦ" +  chr(32) +  string(buf_wth-dtl.wth-code) + chr(10) +
                  "Код МХ" + chr(32) + string(buf_wth-dtl.w-p-code) + chr(10) +
                  "Код номинала" + chr(32) + string(buf_wth-dtl.par-code) + chr(10) +
                  "Сумма по связанным товарам в базовой валюте по партиям не равна сумме по номиналу" + chr(32) +  chr(10) +
                  "Сумма по связанным товарам в базовой валюте по партиям=" + string(varsum-gds-base-parts) + chr(32) +
                  "Сумма по связанным товарам в базовой валюте по номиналу=" + string(buf_wth-dtl.sum-gds-base).
        if par-talk then
        message var-mes
        view-as alert-box error .
        UNDO Main-Block,  return error var-mes.
      end.
    end.
  END.
  if varis-dtl then do:
    if vardoc-sum-dtl <> buf_wth-line.doc-sum then do:
      var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                "Код МЦ" +  chr(32) +  string(buf_wth-line.wth-code) + chr(10) +
                "Код МХ" + chr(32) + string(buf_wth-line.w-p-code) + chr(10) +
                "Сумма по номиналам не равна сумме по строке" + chr(32) +  chr(10) +
                "Сумма по документу по номиналам=" + string(vardoc-sum-dtl) + chr(32) +
                "Сумма по документу по строке=" + string(buf_wth-line.doc-sum).
      if par-talk then
      message var-mes
      view-as alert-box error .
      UNDO Main-Block,  return error var-mes.
    end.
    if buf_wth-doc.status_ = 'факт':U then do:
      if varfact-sum-dtl <> buf_wth-line.fact-sum then do:
        var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                  "Код МЦ" +  chr(32) +  string(buf_wth-line.wth-code) + chr(10) +
                  "Код МХ" + chr(32) + string(buf_wth-line.w-p-code) + chr(10) +
                  "Сумма по номиналам не равна сумме по строке" + chr(32) +  chr(10) +
                  (if buf_wth-doc.doc-type = 'инв':U
                  then
                  string(
                  "Сумма расхождений по номиналам=" + string(varfact-sum-dtl) + chr(32) +
                  "Сумма расхождений по строке=" + string(buf_wth-line.fact-sum)
                  )
                  else
                  string(
                  "Сумма факт по номиналам=" + string(varfact-sum-dtl) + chr(32) +
                  "Сумма факт по строке=" + string(buf_wth-line.fact-sum))
                  ).
        if par-talk then
        message var-mes
        view-as alert-box error .
        UNDO Main-Block,  return error var-mes.
      end.
    end.
    if varbef-sum-dtl <> buf_wth-line.bef-sum then do:
      var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                "Код МЦ" +  chr(32) +  string(buf_wth-line.wth-code) + chr(10) +
                "Код МХ" + chr(32) + string(buf_wth-line.w-p-code) + chr(10) +
                "Сумма по номиналам не равна сумме по строке" + chr(32) +  chr(10) +
                "Сумма план по номиналам=" + string(varbef-sum-dtl) + chr(32) +
                "Сумма план по строке=" + string(buf_wth-line.bef-sum).
      if par-talk then
      message var-mes
      view-as alert-box error .
      UNDO Main-Block,  return error var-mes.
    end.
    if buf_wth-doc.doc-type = 'инв':U then do:
      if buf_wth-doc.status_ = 'факт':U then do:
        if varaft-sum-dtl <> buf_wth-line.aft-sum then do:
          var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                    "Код МЦ" +  chr(32) +  string(buf_wth-line.wth-code) + chr(10) +
                    "Код МХ" + chr(32) + string(buf_wth-line.w-p-code) + chr(10) +
                    "Сумма по номиналам не равна сумме по строке" + chr(32) +  chr(10) +
                    "Сумма факт по номиналам=" + string(varaft-sum-dtl) + chr(32) +
                    "Сумма факт по строке=" + string(buf_wth-line.aft-sum).
          if par-talk then
          message var-mes
          view-as alert-box error .
          UNDO Main-Block,  return error var-mes.
        end.
      end.
    end.
    if varsum-gds-rubl-dtl <> buf_wth-line.sum-gds-rubl then do:
      var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                "Код МЦ" +  chr(32) +  string(buf_wth-line.wth-code) + chr(10) +
                "Код МХ" + chr(32) + string(buf_wth-line.w-p-code) + chr(10) +
                "Сумма по связанным товарам в рублях  по номиналам не равна сумме по строке" + chr(32) + chr(10) +
                "Сумма по связанным товарам в рублях  по номиналам=" + string(varsum-gds-rubl-dtl) + chr(32) +
                "Сумма по связанным товарам в рублях  по строке=" + string(buf_wth-line.sum-gds-rubl).
      if par-talk then
      message var-mes
      view-as alert-box error .
      UNDO Main-Block,  return error var-mes.
    end.
    if varsum-gds-base-dtl <> buf_wth-line.sum-gds-base then do:
      var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                "Код МЦ" +  chr(32) +  string(buf_wth-line.wth-code) + chr(10) +
                "Код МХ" + chr(32) + string(buf_wth-line.w-p-code) + chr(10) +
                "Сумма по связанным товарам в базовой валюте по номиналам не равна сумме по строке" + chr(32) +  chr(10) +
                "Сумма по связанным товарам в базовой валюте по номиналам=" + string(varsum-gds-base-dtl) + chr(32) +
                "Сумма по связанным товарам в базовой валюте по строке=" + string(buf_wth-line.sum-gds-base).
      if par-talk then
      message var-mes
      view-as alert-box error .
      UNDO Main-Block,  return error var-mes.
    end.
  end .
  assign
  vardoc-sum-line = vardoc-sum-line + buf_wth-line.doc-sum
  varfact-sum-line = varfact-sum-line + buf_wth-line.fact-sum
  varbef-sum-line = varbef-sum-line + buf_wth-line.bef-sum
  varaft-sum-line = varaft-sum-line + buf_wth-line.aft-sum
  varsum-gds-rubl-line = varsum-gds-rubl-line + buf_wth-line.sum-gds-rubl
  varsum-gds-base-line = varsum-gds-base-line + buf_wth-line.sum-gds-base
  .
END.
if vardoc-sum-line <> buf_wth-doc.doc-sum then do:
  var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
            "Сумма по строкам не равна сумме по шапке" + chr(32) + chr(10) +
            "Сумма по документу по строкам=" + string(vardoc-sum-line) + chr(32) +
            "Сумма по документу по шапке=" + string(buf_wth-doc.doc-sum).
  if par-talk then
  message var-mes
  view-as alert-box error .
  UNDO Main-Block,  return error var-mes.
end.
if buf_wth-doc.status_ = 'факт':U then do:
  if varfact-sum-line <> buf_wth-doc.fact-sum then do:
    var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
              "Сумма по строкам не равна сумме по шапке" + chr(32) + chr(10) +
              (if buf_wth-doc.doc-type = 'инв':U
              then
                string(
                "Сумма расхождений по строкам=" + string(varfact-sum-line) + chr(32) +
                "Сумма расхождений по шапке=" + string(buf_wth-doc.fact-sum)
                )
              else
              string(
              "Сумма факт по строкам=" + string(varfact-sum-line) + chr(32) +
              "Сумма факт по шапке=" + string(buf_wth-doc.fact-sum))
              ).
    if par-talk then
    message var-mes
    view-as alert-box error .
    UNDO Main-Block,  return error var-mes.
  end.
end.
if varbef-sum-line <> buf_wth-doc.bef-sum then do:
  var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
            "Сумма по строкам не равна сумме по шапке" + chr(32) + chr(10) +
            "Сумма план по строкам=" + string(varbef-sum-line) + chr(32) +
            "Сумма план по шапке=" + string(buf_wth-doc.bef-sum).
  if par-talk then
  message var-mes
  view-as alert-box error .
  UNDO Main-Block,  return error var-mes.
end.
if buf_wth-doc.doc-type = 'инв':U then do:
  if varaft-sum-line <> buf_wth-doc.aft-sum then do:
    var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
              "Сумма по строкам не равна сумме по шапке" + chr(32) + chr(10) +
              "Сумма факт по строкам=" + string(varaft-sum-line) + chr(32) +
              "Сумма факт по шапке=" + string(buf_wth-doc.aft-sum).
    if par-talk then
    message var-mes
    view-as alert-box error .
    UNDO Main-Block,  return error var-mes.
  end.
end.
if varsum-gds-rubl-line <> buf_wth-doc.sum-gds-rubl then do:
  var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
            "Сумма по связанным товарам в рублях  по строкам не равна сумме по шапке" + chr(32) + chr(10) +
            "Сумма по связанным товарам в рублях  по строкам=" + string(varsum-gds-rubl-line) + chr(32) +
            "Сумма по связанным товарам в рублях  по шапке=" + string(buf_wth-doc.sum-gds-rubl).
  if par-talk then
  message var-mes   varsum-gds-rubl-line  buf_wth-doc.sum-gds-rubl
  view-as alert-box error .
  UNDO Main-Block,  return error var-mes.
end.
if varsum-gds-base-line <> buf_wth-doc.sum-gds-base then do:
  var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
            "Сумма по связанным товарам в базовой валюте по строкам не равна сумме по шапке" + chr(32) +   chr(10) +
            "Сумма по связанным товарам в базовой валюте по строкам=" + string(varsum-gds-base-line) + chr(32) +
            "Сумма по связанным товарам в базовой валюте по шапке=" + string(buf_wth-doc.sum-gds-base).
  if par-talk then
  message var-mes
  view-as alert-box error .
  UNDO Main-Block,  return error var-mes.
end.
if buf_wth-doc.auto-fill and varchk-doc-exist then do:
  for each check_chk-doc WHERE
           check_chk-doc.out-code = buf_wth-doc.doc-code AND
           check_chk-doc.obj-type = buf_wth-doc.obj-type AND
           check_chk-doc.obj-code = buf_wth-doc.obj-code,
      EACH check_chk-pay No-LOCK WHERE
           check_chk-pay.doc-code = check_chk-doc.doc-code:
    varinst-sum = varinst-sum + check_chk-pay.tot-sum.
    varchk-type = check_chk-doc.chk-type.
  end.
  if buf_wth-doc.doc-type = 'рас':U then do:
    assign
    varinst-sum = - varinst-sum
    .
  end.
  if buf_wth-doc.doc-type = 'инв':U then do:
    if string(varchk-type) = '4':U then dO:
    end.
    else do:
      if varinst-sum <> buf_wth-doc.aft-sum then do:
        var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                  "Сумма по строкам чеков МЦ не равна сумме факт по шапке" + chr(32) + chr(10) +
                  "Сумма по строкам чеков МЦ=" + string(varinst-sum) + chr(32) +
                  "Сумма факт по шапке=" + string(buf_wth-doc.aft-sum).
        if par-talk then
        message var-mes
        view-as alert-box error .
        UNDO Main-Block,  return error var-mes.
      end.
    end.
  end.
  else do:
    if varinst-sum <> buf_wth-doc.doc-sum then do:
      var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                "Сумма по строкам чеков МЦ не равна сумме документа по шапке" + chr(32) + chr(10) +
                "Сумма по строкам чеков МЦ=" + string(varinst-sum) + chr(32) +
                "Сумма документа по шапке=" + string(buf_wth-doc.doc-sum).
        if par-talk then
        message var-mes
        view-as alert-box error .
        UNDO Main-Block,  return error var-mes.
    end.
    if varinst-sum <> buf_wth-doc.fact-sum
    and buf_wth-doc.doc-type <> 'декл':U
    then do:
      var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                "Сумма по строкам чеков МЦ не равна сумме факт по шапке" + chr(32) + chr(10) +
                "Сумма по строкам чеков МЦ=" + string(varinst-sum) + chr(32) +
                "Сумма факт по шапке=" + string(buf_wth-doc.fact-sum).
      if par-talk then
      message var-mes
      view-as alert-box error .
      UNDO Main-Block,  return error var-mes.
    end.
    if buf_wth-doc.doc-type = 'декл':U
    and buf_wth-doc.fact-sum <> 0 then do:
      var-mes = "Документ МЦ" + chr(32) + buf_wth-doc.doc-code + chr(10) +
                "Тип" + chr(32) + buf_wth-doc.doc-type +
                "Сумма факт по шапке <> 0" .
      if par-talk then
      message var-mes
      view-as alert-box error .
      UNDO Main-Block,  return error var-mes.
    end.
  end.
end.
        end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  buf_wth-doc.obj-type
  ,input  buf_wth-doc.obj-code
  ,output v-obj-date
  ) no-error .
        if error-status:error then do:
          var-mes =
          vss-workfile + chr(32) + vss-revision + chr(32) + vss-description + chr(10) +
          "Ошибка при определении даты на объекте" + chr(10) +
          ERROR-STATUS:GET-MESSAGE( 1 ) + chr(10) + RETURN-VALUE.
          if par-talk then
          MESSAGE
          var-mes
          VIEW-AS ALERT-BOX ERROR.
          run waitfram-hide in this-procedure .
          UNDO Main-Block, RETURN ERROR var-mes.
        end.
        if
          buf_wth-doc.fact-date = ?
        then do:
          d_fact-date = v-obj-date.
        end.
        else do:
          assign
          d_fact-date = buf_wth-doc.fact-date
          .
        end.
        ASSIGN
        j_fact-time = TIME
        j_fact-num  = NEXT-VALUE( s-wth-fact, ub )
        .
        run gbl/chk-date.p (
                        INPUT buf_wth-doc.obj-type,
                        INPUT buf_wth-doc.obj-code,
                        INPUT d_fact-date,
                        INPUT j_fact-time,
                        INPUT buf_wth-doc.shift-date,
                        INPUT buf_wth-doc.shift-num,
                        INPUT par-talk
                      ) NO-ERROR.
        IF ERROR-STATUS:ERROR THEN DO:
           run waitfram-hide in this-procedure .
          var-mes =
          vss-workfile + chr(32) + vss-revision + chr(32) + vss-description + chr(10) +
          "Ошибка при установке дат, времен, смен в документе МЦ!" + chr(10) +
          "fact-num  " + string(j_fact-num)  + chr(10) +
          "fact-date " + string(d_fact-date) + chr(10) +
          "fact-time " + string(j_fact-time, "HH:MM:SS") + chr(10) +
          "shift-date" + string(buf_wth-doc.shift-date)  + chr(10) +
          "shift-name" + string(buf_wth-doc.shift-name)  + chr(10) +
          "shift-num " + string(buf_wth-doc.shift-num)   + chr(10) +
          ERROR-STATUS:GET-MESSAGE( 1 ) + chr(10) + RETURN-VALUE.
          if par-talk then
          MESSAGE
          var-mes
          VIEW-AS ALERT-BOX ERROR.
          UNDO Main-Block, RETURN ERROR var-mes.
        END.
        run corr-date in this-procedure
            ( input buf_wth-doc.obj-type
            , input buf_wth-doc.obj-code
            , input buf_wth-doc.fact-date
            , input buf_wth-doc.shift-date
            , input buf_wth-doc.shift-num
            , input buf_wth-doc.shift-name
          ) no-error.
        IF ERROR-STATUS:ERROR THEN DO:
           run waitfram-hide in this-procedure .
          var-mes =
          vss-workfile + chr(32) + vss-revision + chr(32) + vss-description + chr(10) +
          "Ошибка при проверке корректности дат в документе МЦ!" + chr(10) +
          "fact-num  " + string(j_fact-num)  + chr(10) +
          "fact-date " + string(d_fact-date) + chr(10) +
          "fact-time " + string(j_fact-time, "HH:MM:SS") + chr(10) +
          "shift-date" + string(buf_wth-doc.shift-date)  + chr(10) +
          "shift-name" + string(buf_wth-doc.shift-name)  + chr(10) +
          "shift-num " + string(buf_wth-doc.shift-num)   + chr(10) +
          ERROR-STATUS:GET-MESSAGE( 1 ) + chr(10) + RETURN-VALUE.
          if par-talk then
          MESSAGE
          var-mes
          VIEW-AS ALERT-BOX ERROR.
          UNDO Main-Block, RETURN ERROR var-mes.
        END.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  buf_wth-doc.obj-type
  ,input  buf_wth-doc.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) NO-ERROR .
        IF ERROR-STATUS:ERROR THEN DO:
          run waitfram-hide in this-procedure .
          var-mes =
          vss-workfile + chr(32) + vss-revision + chr(32) + vss-description + chr(10) +
          "Ошибка при запуске процедуры objat!" + chr(10) +
          ERROR-STATUS:GET-MESSAGE( 1 )  +  chr(10) + RETURN-VALUE.
          if par-talk then
          MESSAGE
          var-mes
          VIEW-AS ALERT-BOX ERROR.
          UNDO Main-Block, RETURN ERROR var-mes.
        END.
        RUN factord IN THIS-PROCEDURE (
                                        INPUT d_fact-date,
                                        INPUT j_fact-time,
                                        INPUT j_fact-num,
                                        INPUT buf_wth-doc.shift-date,
                                        INPUT buf_wth-doc.shift-num,
                                        INPUT l-shift-on,
                                        OUTPUT d-fact-ord,
                                        OUTPUT d-shift-ord,
                                        OUTPUT day-end-ord
                                      ) NO-ERROR.
        IF ERROR-STATUS:ERROR OR
           d-fact-ord = ? OR
           d-fact-ord = 0 THEN DO:
           run waitfram-hide in this-procedure .
          var-mes =
          vss-workfile + chr(32) + vss-revision + chr(32) + vss-description + chr(10) +
          "Ошибка при определении фактического номера МЦ!" + chr(10) +
          "doc-code" + buf_wth-doc.doc-code + chr(10) +
          "fact-date" + string( d_fact-date) + chr(10) +
          "fact-time" + string(j_fact-time, "HH:MM:SS")  + chr(10) +
          "fact-num"  + string(j_fact-num)  + chr(10) +
          "shift-date" + string( buf_wth-doc.shift-date) + chr(10) +
          "shift-name" +  string(buf_wth-doc.shift-name) + chr(10) +
          "shift-num" +  string(buf_wth-doc.shift-num) + chr(10) +
          "d-fact-order" + string(d-fact-ord) + chr(10) +
          "d-shift-order" + string(d-shift-ord) + chr(10) +
          "day-end-order" + string(day-end-ord) + chr(10) +
          ERROR-STATUS:GET-MESSAGE( 1 )  +  chr(10) + RETURN-VALUE.
          if par-talk then
          MESSAGE
          var-mes
          VIEW-AS ALERT-BOX ERROR.
          UNDO Main-Block, RETURN ERROR var-mes.
        END.
        if buf_wth-doc.shift-num <> 0 and buf_wth-doc.shift-date <> d_fact-date and  can-find(first buf_wth-parts where buf_wth-parts.out-code = buf_wth-doc.doc-code no-lock) then do:
           run waitfram-hide in this-procedure .
          var-mes =
          vss-workfile + chr(32) + vss-revision + chr(32) + vss-description + chr(10) +    chr(10) +
          "Документ перемещения СЕРИЙНЫХ МЦ на сменном объекте должен закрываться с фактической датой равной дате смены!" +  chr(10) +     chr(10) +
          "fact-date" + string( d_fact-date) + chr(10) +
          "fact-time" + string(j_fact-time, "HH:MM:SS")  + chr(10) +
          "fact-num"  + string(j_fact-num)  + chr(10) +
          "shift-date" + string( buf_wth-doc.shift-date) + chr(10) +
          "shift-name" +  string(buf_wth-doc.shift-name) + chr(10) +
          "shift-num" +  string(buf_wth-doc.shift-num) + chr(10) +
          ERROR-STATUS:GET-MESSAGE( 1 )  +  chr(10) + RETURN-VALUE.
          if par-talk then
          MESSAGE
          var-mes
          VIEW-AS ALERT-BOX ERROR.
          UNDO Main-Block, RETURN ERROR var-mes.
        end.
        if d_fact-date < v-obj-date
        then do:
          assign
            v-is-back-date = yes.
        end.
        else do:
          if l-shift-on then do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  buf_wth-doc.obj-type
  ,input  buf_wth-doc.obj-code
  ,output v-obj-shift-date
  ,output v-obj-shift-num
  ,output v-obj-shift-name
  )  .
            if not (buf_wth-doc.shift-date = v-obj-shift-date and
                    buf_wth-doc.shift-num  = v-obj-shift-num  )   then do:
              assign
              v-is-back-date = yes.
            end.
          end.
        end.
        if  v-is-back-date = yes
        then do:
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  g#db-num
    ,input  g#userid
    ,input  0
    ,input  'actn_wth-doc_create-back-shift':U
    ,input  'object':U
    ,input  buf_wth-doc.host-code
    ,input  buf_wth-doc.obj-type
    ,input  buf_wth-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output var-log
    )  .
end.
          IF var-log <> YES THEN DO:
           UNDO Main-Block, RETURN ERROR .
          END.
        end.
        ASSIGN
        buf_wth-doc.status_    = 'факт':U
        buf_wth-doc.fact-date  = d_fact-date
        buf_wth-doc.fact-time  = j_fact-time
        buf_wth-doc.fact-num   = j_fact-num
        buf_wth-doc.fact-order = d-fact-ord
        buf_wth-doc.is-back-date = v-is-back-date
        v-fact-date = d_fact-date
        .
        v-recalc-fact-ord = d-fact-ord - 0.0000000001.
        if (buf_wth-doc.ext-doc-type = 'ie':U
          or buf_wth-doc.ext-doc-type = 'ee':U
          or buf_wth-doc.ext-doc-type = 'xc':U
          or buf_wth-doc.ext-doc-type = 'ps':U
          or v-is-back-date = yes)
          and (not g#news or (g#news and  g#db-num  = 0)) THEN DO:
          run str/chkwthcl.p ( input buf_wth-doc.doc-code
                              ,input p-file-name-err ) no-error.
          if error-status:error then do:
            run waitfram-hide in this-procedure .
            var-mes =
            vss-workfile + chr(32) + vss-revision + chr(32) + vss-description + chr(10) +
            "Ошибка при проверке корректности партий!" + chr(10) +
            ERROR-STATUS:GET-MESSAGE( 1 )  +  chr(10) + RETURN-VALUE.
            if par-talk then
            MESSAGE
            var-mes
            VIEW-AS ALERT-BOX ERROR.
            UNDO Main-Block, RETURN ERROR var-mes.
          end.
          else if return-value = 'warning':U then v-warning = yes.
        end.
        var-mes = vss-workfile + chr(32) + vss-revision + chr(32) + vss-description + chr(10) +
          "Ошибка при заполнении остатков и оборотов МЦ!"  + chr(10) .
        run str/stkotwth.p ( INPUT RECID( buf_wth-doc ),
                             INPUT YES,
                             input yes,
                             input 0 ) NO-ERROR.
        IF ERROR-STATUS:ERROR THEN DO:
          run waitfram-hide in this-procedure .
          var-mes = var-mes + ERROR-STATUS:GET-MESSAGE( 1 ) + chr(10) + RETURN-VALUE.
          if par-talk then
          MESSAGE
          var-mes
          VIEW-AS ALERT-BOX ERROR.
          UNDO Main-Block, RETURN ERROR var-mes.
        END.
        var-mes = vss-workfile + chr(32) + vss-revision + chr(32) + vss-description + chr(10) .
        if (buf_wth-doc.obj-type = buf_wth-doc.cli-type and
           buf_wth-doc.obj-code = buf_wth-doc.cli-code and
           buf_wth-doc.inter_ = yes)
           or lookup(buf_wth-doc.ext-doc-type,'ep,ip,ff,fj,ii,ei,pj,ef':U) > 0
        then do:
          run str/wth-out.p (buffer buf_wth-doc, buffer buf_out_wth-doc) no-error.
          if error-status:error then do:
            run waitfram-hide in this-procedure .
            var-mes =
            vss-workfile + chr(32) + vss-revision + chr(32) + vss-description + chr(10) +
            "Не удалось создать связанный документ к документу" + chr(32) + string(buf_wth-doc.doc-code).
            if par-talk then
            message
            var-mes  skip
            return-value
            view-as alert-box error .
            UNDO Main-Block, RETURN ERROR var-mes.
          end.
        end.
        if buf_wth-doc.obj-type = buf_wth-doc.cli-type and
           buf_wth-doc.obj-code = buf_wth-doc.cli-code and
           buf_wth-doc.inter_ = yes then do:
          j_fact-num  = NEXT-VALUE( s-wth-fact, ub ).
          RUN factord IN THIS-PROCEDURE (
                                          INPUT d_fact-date,
                                          INPUT j_fact-time,
                                          INPUT j_fact-num,
                                          INPUT buf_wth-doc.shift-date,
                                          INPUT buf_wth-doc.shift-num,
                                          INPUT l-shift-on,
                                          OUTPUT d-fact-ord,
                                          OUTPUT d-shift-ord,
                                          OUTPUT day-end-ord
                                        ) NO-ERROR.
          IF ERROR-STATUS:ERROR
          OR d-fact-ord = ?
          OR d-fact-ord = 0 THEN DO:
            run waitfram-hide in this-procedure .
            var-mes =
            vss-workfile + chr(32) + vss-revision + chr(32) + vss-description + chr(10) +
            "Ошибка при определении фактического номера МЦ!" + chr(10) +
            "doc-code"   + buf_out_wth-doc.doc-code + chr(10) +
            "fact-date"  + string( d_fact-date) + chr(10) +
            "fact-time"  + string(j_fact-time, "HH:MM:SS")  + chr(10) +
            "fact-num"   + string(j_fact-num) + chr(10) +
            "shift-date" + string( buf_out_wth-doc.shift-date) + chr(10) +
            "shift-name" +  string(buf_out_wth-doc.shift-name) + chr(10) +
            "shift-num"  +  string(buf_out_wth-doc.shift-num) + chr(10) +
            "d-fact-order" + string(d-fact-ord) + chr(10) +
            "d-shift-order" + string(d-shift-ord) + chr(10) +
            "day-end-order" + string(day-end-ord) + chr(10) +
            ERROR-STATUS:GET-MESSAGE( 1 ) + chr(10) + RETURN-VALUE.
            if par-talk then
            MESSAGE
            var-mes
            VIEW-AS ALERT-BOX ERROR.
            UNDO Main-Block, RETURN ERROR var-mes.
          END.
          ASSIGN
          buf_out_wth-doc.status_    = 'факт':U
          buf_out_wth-doc.fact-date  = d_fact-date
          buf_out_wth-doc.fact-time  = j_fact-time
          buf_out_wth-doc.fact-num   = j_fact-num
          buf_out_wth-doc.fact-order = d-fact-ord
          buf_out_wth-doc.is-back-date = buf_wth-doc.is-back-date
          .
          run str/stkotwth.p ( INPUT RECID( buf_out_wth-doc ),
                               INPUT YES,
                               input yes,
                               input 0 ) NO-ERROR.
          IF ERROR-STATUS:ERROR THEN DO:
            run waitfram-hide in this-procedure .
            var-mes = var-mes + ERROR-STATUS:GET-MESSAGE( 1 ) + chr(10) + RETURN-VALUE.
            if par-talk then
            MESSAGE
            var-mes
            VIEW-AS ALERT-BOX ERROR.
            UNDO Main-Block, RETURN ERROR var-mes.
          END.
        end.
        release buf_out_wth-doc no-error .
        if error-status:error then do:
            run waitfram-hide in this-procedure .
            var-mes = var-mes + ERROR-STATUS:GET-MESSAGE( 1 ) + chr(10) + RETURN-VALUE.
            if par-talk then
            MESSAGE
            var-mes
            VIEW-AS ALERT-BOX ERROR.
            UNDO Main-Block, RETURN ERROR var-mes.
        end.
        if v-is-back-date then do:
                    DEFINE VARIABLE v-today as date no-undo .
          DEFINE VARIABLE v-time as integer no-undo .
          run cur-time in this-procedure ( output v-today, output v-time).
          FOR EACH buf_wth-line NO-LOCK WHERE
          buf_wth-line.doc-code = buf_wth-doc.doc-code ON ERROR UNDO Main-Block, RETURN ERROR :
            run str/reclcwtl.p
              (input parobj-type
              ,input parobj-code
              ,input v-recalc-fact-ord
              ,input buf_wth-line.wth-code
              ,input no
              ,input 'close':U
              ,input v-wth-doc-code
              ,input d_fact-date
              ,input g#db-num
              ,input g#userid
              ,input v-today
              ,input v-time
              ,input string(v-time, "HH:MM:SS")
              ) no-error .
            if error-status :error then do:
              var-mes = substitute("&1 &2 &3&4" +
                                    "Ошибка при пересчете остатков при закрытии док-та МЦ &5 задним числом&4"  +
                                    "&6&4&7"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    ,error-status :get-message(1)
                                    , return-value ).
              if par-talk then
              MESSAGE
              var-mes
              VIEW-AS ALERT-BOX ERROR.
              UNDO Main-Block, RETURN ERROR var-mes.
            end.
          end.
        end.
        release buf_wth-doc no-error.
        if error-status:error then do:
            run waitfram-hide in this-procedure .
            var-mes = var-mes + ERROR-STATUS:GET-MESSAGE( 1 ) + chr(10) + RETURN-VALUE.
            if par-talk then
            MESSAGE
            var-mes
            VIEW-AS ALERT-BOX ERROR.
            UNDO Main-Block, RETURN ERROR var-mes.
        end.
        end.
      END.
      if var-status_ =  'факт':U THEN DO:
        run waitfram-hide in this-procedure .
        var-mes  = "Документ закрыт на ФАКТ! ".
        IF par-talk THEN DO:
          MESSAGE var-mes
          VIEW-AS ALERT-BOX ERROR.
        END.
        UNDO Main-Block, RETURN ERROR var-mes.
      END.
  END.
  ELSE IF par-mode = "-":U THEN DO:
    CASE buf_wth-doc.status_:
      when 'факт':U then do:
        var-mes = "Нельзя открыть документ в статусе" +  chr(32) + buf_wth-doc.status_.
        run waitfram-hide in this-procedure .
        IF par-talk THEN DO:
          MESSAGE var-mes
          VIEW-AS ALERT-BOX ERROR.
        END.
        UNDO Main-Block, RETURN ERROR var-mes.
      end.
      when 'разрешен':U THEN DO:
        ASSIGN
        buf_wth-doc.status_ = 'накл':U.
      END.
      when 'накл':U THEN DO:
        var-mes = "Документ открыт!".
        run waitfram-hide in this-procedure .
        IF par-talk THEN DO:
          MESSAGE var-mes
          VIEW-AS ALERT-BOX ERROR.
        END.
        run waitfram-hide in this-procedure .
        UNDO Main-Block, RETURN ERROR var-mes.
      end.
    END CASE.
  END.
  run waitfram-hide in this-procedure .
END.
procedure corr-date:
define input parameter parobj-type    like ub.trn-doc.obj-type   no-undo.
define input parameter parobj-code    like ub.trn-doc.obj-code   no-undo.
define input parameter parfact-date   like ub.trn-doc.fact-date  no-undo.
define input parameter parshift-date  like ub.trn-doc.shift-date no-undo.
define input parameter parshift-num   like ub.trn-doc.shift-num  no-undo.
define input parameter parshift-name  like ub.trn-doc.shift-name no-undo.
define variable l-shift-on as logical no-undo .
define buffer bf_shift-obj for ub.shift-obj.
do on error undo, return error return-value :
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  parobj-type
  ,input  parobj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
if l-shift-on = yes
then do:
  find first bf_shift-obj where bf_shift-obj.obj-type   = parobj-type   and
                                bf_shift-obj.obj-code   = parobj-code   and
                                bf_shift-obj.shift-date = parshift-date and
                                bf_shift-obj.shift-num  = parshift-num  no-lock no-error.
  if not available bf_shift-obj
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error substitute( "Нет смены &1 &2 на объекте &3 &4.", parshift-date, parshift-name + string(parshift-num), parobj-type, parobj-code).
  end.
  if bf_shift-obj.status_ <> 'зкр':U  and
     bf_shift-obj.status_ <> 'тек':U
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error substitute( "Смена &1 &2 на объекте &3 &4 имеет статус &5. Оформлять документы можно только в смене со статусом &6 или &7.",
                              bf_shift-obj.shift-date,
                              bf_shift-obj.shift-name + string(bf_shift-obj.shift-num),
                              bf_shift-obj.obj-type,
                              bf_shift-obj.obj-code,
                              bf_shift-obj.status_,
                              'зкр':U,
                              'тек':U).
  end.
  if parfact-date < bf_shift-obj.open-date
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error substitute( "Фактическая дата документа должна быть больше либо равна дате открытия смены. Фактическая дата: &1. Дата открытия смены &2 &3 на объекте &4 &5: &6.",
                             parfact-date,
                             bf_shift-obj.shift-date,
                             bf_shift-obj.shift-name + string(bf_shift-obj.shift-num),
                             bf_shift-obj.obj-type,
                             bf_shift-obj.obj-code,
                             bf_shift-obj.open-date).
  end.
  if bf_shift-obj.status_ = 'зкр':U
  then do:
    if parfact-date > bf_shift-obj.close-date
    then do:
      run waitfram-hide in this-procedure no-error.
      undo, return error substitute( "Фактическая дата документа должна быть меньше либо равна дате закрытия смены. Фактическая дата: &1. Дата закрытия смены &2 &3 на объекте &4 &5: &6.",
                               parfact-date,
                               bf_shift-obj.shift-date,
                               bf_shift-obj.shift-name + string(bf_shift-obj.shift-num),
                               bf_shift-obj.obj-type,
                               bf_shift-obj.obj-code,
                               bf_shift-obj.close-date).
    end.
  end.
end.
end.
end procedure.
if v-warning then return 'warning':U.
