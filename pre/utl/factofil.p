block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-install as logical no-undo init no .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: factofil.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/factofil.p $":U .
define variable vss-description as character no-undo init "Заполнение поля fact-order".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
on write of trn-doc   override do: end.
on write of price-doc override do: end.
on write of rvs-doc   override do: end.
on write of icnt-doc  override do: end.
on write of wth-doc   override do: end.
define stream slog .
define variable v-fix-count   as integer no-undo .
define variable v-error-count as integer   no-undo .
define variable v-num as integer no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if p-install then do:
  assign
    v-num = 1
  .
end.
else do:
  run gbl/d-askw.w
    (input "Вопрос"
    ,input "Простановка фактического номера для всех документов системы." + chr(10)
    ,input "|^"
    ,input "Все объекты^confirm|Все сменные объекты^confirm|Выбрать объекты|Отмена"
    ,input "|"
        + "|"
        + "|"
        + ""
    ,input 1
    ,input 4
    ,output v-num
    ).
end.
if p-install = false then do:
  run waitfram-show in this-procedure (input "Простановка фактического номера"
    ).
end.
case v-num :
  when 1 then do:
    for each ub.db no-lock
    ,each ub.clients no-lock
      where ub.clients.db-num = ub.db.db-num
    on error undo, return error
    :
      run process-object in this-procedure
        (input ub.clients.obj-type
        ,input ub.clients.obj-code
        ).
    end.
  end.
  when 2 then do:
    for each ub.db no-lock
    ,each ub.clients no-lock
      where ub.clients.db-num = ub.db.db-num
    on error undo, return error
    :
      define variable l-shift-on as logical no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  ub.clients.obj-type
  ,input  ub.clients.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при запуске процедуры objat" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      if l-shift-on = true then do:
        run process-object in this-procedure
          (input ub.clients.obj-type
          ,input ub.clients.obj-code
          ).
      end.
    end.
  end.
  when 3 then do:
    define variable v-user-select as logical   no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
    if v-user-select <> true
    then do:
      message
        "Объект не выбран"
        view-as alert-box information .
      return .
    end.
    define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run process-object in this-procedure
        (input buf_userobjs_temp-user-obj.obj-type
        ,input buf_userobjs_temp-user-obj.obj-code
        ).
    end.
  end.
  when 4 then do:
    return .
  end.
end case .
if p-install = false then do:
  run waitfram-hide in this-procedure .
end.
if p-install = false then do:
  message
    "Закончена утилита инициализации поля fact-order" skip
    "Исправлено документов" v-fix-count skip
    view-as alert-box information .
end.
if v-error-count > 0 then do:
  return
    "При заполнении поля было обнаружено " + string(v-error-count) + chr(10)
    + "Информация об ошибочных документах находится в файле factofil.err. " + chr(10)
    .
end.
return .
procedure process-object :
  define input parameter p-obj-type like ub.price-list.obj-type no-undo .
  define input parameter p-obj-code like ub.price-list.obj-code no-undo .
  do
  on error undo, return error
  :
    define variable l-shift-on as logical no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при запуске процедуры objat" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    run process-trn-doc in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input l-shift-on
      ) .
    run process-price-doc in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input l-shift-on
      ) .
    run process-wth-doc in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input l-shift-on
      ) .
    run process-rvs-doc in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input l-shift-on
      ) .
    run process-icnt-doc in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input l-shift-on
      ) .
    run process-stk-archive in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input l-shift-on
      ) .
    run process-shift-obj in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input l-shift-on
      ) .
  end.
end.
procedure process-trn-doc :
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer   no-undo .
  define input parameter p-shift-on as logical   no-undo .
  define buffer buf_trn-doc for ub.trn-doc .
  do
  on error undo, return error
  :
    if p-install = false then do:
      run waitfram-show in this-procedure (input substitute("Обработка складских документов. Объект &1 &2", p-obj-type, p-obj-code)
        ).
    end.
    for each buf_trn-doc exclusive-lock
      where buf_trn-doc.obj-type = p-obj-type
        and buf_trn-doc.obj-code = p-obj-code
        and buf_trn-doc.status_  = 'факт':U
    on error undo, return error
    :
      define variable v-fact-order           as decimal no-undo .
      define variable v-shift-end-fact-order as decimal no-undo .
      define variable v-day-end-fact-order   as decimal no-undo .
      run factord in this-procedure
        (input  buf_trn-doc.fact-date
        ,input  buf_trn-doc.fact-time
        ,input  buf_trn-doc.fact-num
        ,input  buf_trn-doc.shift-date
        ,input  buf_trn-doc.shift-num
        ,input  p-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error then do:
        output stream slog to factofil.err append .
        export stream slog
          "err-trn-doc"
          buf_trn-doc.obj-type buf_trn-doc.obj-code
          buf_trn-doc.doc-code buf_trn-doc.fact-date buf_trn-doc.fact-time
          buf_trn-doc.fact-num buf_trn-doc.shift-date buf_trn-doc.shift-num
          buf_trn-doc.fact-order
          return-value .
        output stream slog close .
        assign
          v-error-count = v-error-count + 1
        .
      end.
      else do:
        if buf_trn-doc.fact-order <> v-fact-order then do:
          output stream slog to factofil.fix append .
          export stream slog
            "fix-trn-doc"
            buf_trn-doc.doc-code buf_trn-doc.fact-date buf_trn-doc.fact-time
            buf_trn-doc.fact-num buf_trn-doc.shift-date buf_trn-doc.shift-num
            buf_trn-doc.fact-order v-fact-order
            .
          output stream slog close .
          assign
            v-fix-count = v-fix-count + 1
          .
          assign
            buf_trn-doc.fact-order = v-fact-order
          .
        end.
      end.
      define buffer buf_doc-line for ub.doc-line .
      for each buf_doc-line exclusive-lock
        where buf_doc-line.doc-code = buf_trn-doc.doc-code
          and buf_doc-line.fact-order <> buf_trn-doc.fact-order
      on error undo, return error
      :
        assign
          buf_doc-line.fact-order = buf_trn-doc.fact-order
        .
      end.
      run process-ot-archive in this-procedure
        (input buf_trn-doc.doc-code
        ,input buf_trn-doc.fact-order
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при обработке архивов по документу" skip
          "Документ" buf_trn-doc.doc-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
end procedure.
procedure process-price-doc :
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer   no-undo .
  define input parameter p-shift-on as logical   no-undo .
  define buffer buf_price-doc for ub.price-doc .
  define buffer update_price-doc for ub.price-doc .
  do
  on error undo, return error
  :
    if p-install = false then do:
      run waitfram-show in this-procedure (input substitute("Обработка переоценок. Объект &1 &2", p-obj-type, p-obj-code)
        ).
    end.
    for each buf_price-doc exclusive-lock
      where buf_price-doc.obj-type = p-obj-type
        and buf_price-doc.obj-code = p-obj-code
        and buf_price-doc.status_  = 'акт':U
    on error undo, return error
    :
      define variable v-fact-order           as decimal no-undo .
      define variable v-shift-end-fact-order as decimal no-undo .
      define variable v-day-end-fact-order   as decimal no-undo .
      run factord in this-procedure
        (input  buf_price-doc.fact-date
        ,input  buf_price-doc.fact-time
        ,input  buf_price-doc.fact-num
        ,input  buf_price-doc.shift-date
        ,input  buf_price-doc.shift-num
        ,input  p-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error then do:
        output stream slog to factofil.err append .
        export stream slog
          "err-price-doc"
          buf_price-doc.obj-type buf_price-doc.obj-code
          buf_price-doc.doc-num buf_price-doc.fact-date buf_price-doc.fact-time
          buf_price-doc.fact-num buf_price-doc.shift-date buf_price-doc.shift-num
          buf_price-doc.fact-order
          return-value .
        output stream slog close .
        assign
          v-error-count = v-error-count + 1
        .
      end.
      else do:
        if buf_price-doc.fact-order <> v-fact-order then do:
          output stream slog to factofil.fix append .
          export stream slog
            "fix-price-doc"
            buf_price-doc.doc-num buf_price-doc.fact-date buf_price-doc.fact-time
            buf_price-doc.fact-num buf_price-doc.shift-date buf_price-doc.shift-num
            buf_price-doc.fact-order v-fact-order
            .
          output stream slog close .
          assign
            v-fix-count = v-fix-count + 1
          .
          assign
            buf_price-doc.fact-order = v-fact-order
          .
        end.
      end.
      define buffer buf_price-list for ub.price-list .
      for each buf_price-list exclusive-lock
        where buf_price-list.doc-num = buf_price-doc.doc-num
          and buf_price-list.fact-order <> buf_price-doc.fact-order
      on error undo, return error return-value
      :
        assign
          buf_price-list.fact-order = buf_price-doc.fact-order
        .
      end.
      run process-ot-archive in this-procedure
        (input buf_price-doc.doc-num
        ,input buf_price-doc.fact-order
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при обработке архивов по документу" skip
          "Документ" buf_price-doc.doc-num skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
end procedure.
procedure process-ot-archive :
  do
  on error undo, return error
  :
    define input  parameter p-doc-code   as character no-undo .
    define input  parameter p-fact-order as decimal   no-undo .
    define buffer buf_ot-tot for ub.ot-tot .
    define buffer buf_ot-line for ub.ot-line .
    define buffer buf_ot-supp-tot for ub.ot-supp-tot .
    define buffer buf_ot-supp-line for ub.ot-supp-line .
    for each buf_ot-tot exclusive-lock
      where buf_ot-tot.doc-code = p-doc-code
        and buf_ot-tot.fact-order <> p-fact-order
    on error undo, return error return-value
    :
      assign
        buf_ot-tot.fact-order = p-fact-order
      .
    end.
    for each buf_ot-line exclusive-lock
      where buf_ot-line.doc-code = p-doc-code
        and buf_ot-line.fact-order <> p-fact-order
    on error undo, return error return-value
    :
      assign
        buf_ot-line.fact-order = p-fact-order
      .
    end.
    for each buf_ot-supp-tot exclusive-lock
      where buf_ot-supp-tot.doc-code = p-doc-code
        and buf_ot-supp-tot.fact-order <> p-fact-order
    on error undo, return error return-value
    :
      assign
        buf_ot-supp-tot.fact-order = p-fact-order
      .
    end.
    for each buf_ot-supp-line exclusive-lock
      where buf_ot-supp-line.doc-code = p-doc-code
        and buf_ot-supp-line.fact-order <> p-fact-order
    on error undo, return error return-value
    :
      assign
        buf_ot-supp-line.fact-order = p-fact-order
      .
    end.
  end.
end procedure.
procedure process-wth-doc :
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer   no-undo .
  define input parameter p-shift-on as logical   no-undo .
  do
  on error undo, return error
  :
    if p-install = false then do:
      run waitfram-show in this-procedure (input substitute("Обработка документов мат.ценностей. Объект &1 &2", p-obj-type, p-obj-code)
        ).
    end.
    define buffer buf_wth-doc for ub.wth-doc .
    for each buf_wth-doc exclusive-lock
      where buf_wth-doc.obj-type = p-obj-type
        and buf_wth-doc.obj-code = p-obj-code
        and buf_wth-doc.status_  = 'факт':U
    on error undo, return error
    :
      define variable v-fact-order           as decimal no-undo .
      define variable v-shift-end-fact-order as decimal no-undo .
      define variable v-day-end-fact-order   as decimal no-undo .
      run factord in this-procedure
        (input  buf_wth-doc.fact-date
        ,input  buf_wth-doc.fact-time
        ,input  buf_wth-doc.fact-num
        ,input  buf_wth-doc.shift-date
        ,input  buf_wth-doc.shift-num
        ,input  p-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error then do:
        output stream slog to factofil.err append .
        export stream slog
          "err-wth-doc"
          buf_wth-doc.obj-type buf_wth-doc.obj-code
          buf_wth-doc.doc-code buf_wth-doc.fact-date buf_wth-doc.fact-time
          buf_wth-doc.fact-num buf_wth-doc.shift-date buf_wth-doc.shift-num
          buf_wth-doc.fact-order
          return-value .
        output stream slog close .
        assign
          v-error-count = v-error-count + 1
        .
      end.
      else do:
        if buf_wth-doc.fact-order <> v-fact-order then do:
          output stream slog to factofil.fix append .
          export stream slog
            "fix-wth-doc"
            buf_wth-doc.doc-code buf_wth-doc.fact-date buf_wth-doc.fact-time
            buf_wth-doc.fact-num buf_wth-doc.shift-date buf_wth-doc.shift-num
            buf_wth-doc.fact-order v-fact-order
            .
          output stream slog close .
          assign
            v-fix-count = v-fix-count + 1
          .
          assign
            buf_wth-doc.fact-order = v-fact-order
          .
        end.
      end.
      define buffer buf_wth-line for ub.wth-line .
      for each buf_wth-line exclusive-lock
        where buf_wth-line.doc-code = buf_wth-doc.doc-code
          and buf_wth-line.fact-order <> buf_wth-doc.fact-order
      on error undo, return error return-value
      :
        assign
          buf_wth-line.fact-order = buf_wth-doc.fact-order
        .
      end.
    end.
  end.
end procedure.
procedure process-rvs-doc :
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer   no-undo .
  define input parameter p-shift-on as logical   no-undo .
  do
  on error undo, return error
  :
    if p-install = false then do:
      run waitfram-show in this-procedure (input substitute("Обработка документов сверки. Объект &1 &2", p-obj-type, p-obj-code)
        ).
    end.
    define buffer buf_rvs-doc for ub.rvs-doc .
    for each buf_rvs-doc exclusive-lock
      where buf_rvs-doc.obj-type = p-obj-type
        and buf_rvs-doc.obj-code = p-obj-code
        and buf_rvs-doc.status_  = 'факт':U
    on error undo, return error
    :
      define variable v-fact-num as integer   no-undo .
      assign
        v-fact-num = (buf_rvs-doc.fact-order * 100
                      - truncate(buf_rvs-doc.fact-order * 100, 0) )
                      * 100000000
      .
      define variable v-fact-order           as decimal no-undo .
      define variable v-shift-end-fact-order as decimal no-undo .
      define variable v-day-end-fact-order   as decimal no-undo .
      run factord in this-procedure
        (input  buf_rvs-doc.fact-date
        ,input  buf_rvs-doc.fact-time
        ,input  v-fact-num
        ,input  buf_rvs-doc.shift-date
        ,input  buf_rvs-doc.shift-num
        ,input  p-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error then do:
        output stream slog to factofil.err append .
        export stream slog
          "err-rvs-doc"
          buf_rvs-doc.obj-type buf_rvs-doc.obj-code
          buf_rvs-doc.rvs-code buf_rvs-doc.fact-date buf_rvs-doc.fact-time
          v-fact-num buf_rvs-doc.shift-date buf_rvs-doc.shift-num
          buf_rvs-doc.fact-order
          return-value .
        output stream slog close .
        assign
          v-error-count = v-error-count + 1
        .
      end.
      else do:
        if buf_rvs-doc.fact-order <> v-fact-order then do:
          output stream slog to factofil.fix append .
          export stream slog
            "fix-rvs-doc"
            buf_rvs-doc.rvs-code buf_rvs-doc.fact-date buf_rvs-doc.fact-time
            v-fact-num buf_rvs-doc.shift-date buf_rvs-doc.shift-num
            buf_rvs-doc.fact-order v-fact-order
            .
          output stream slog close .
          assign
            v-fix-count = v-fix-count + 1
          .
          assign
            buf_rvs-doc.fact-order = v-fact-order
          .
        end.
      end.
    end.
  end.
end procedure.
procedure process-icnt-doc :
  define input parameter p-obj-type like ub.price-list.obj-type no-undo .
  define input parameter p-obj-code like ub.price-list.obj-code no-undo .
  define input parameter p-shift-on as logical no-undo .
  do
  on error undo, return error
  :
    if p-install = false then do:
      run waitfram-show in this-procedure (input substitute("Обработка документов счетчиков ТРК. Объект &1 &2", p-obj-type, p-obj-code)
        ).
    end.
    define buffer buf_icnt-doc for ub.icnt-doc .
    for each buf_icnt-doc exclusive-lock
      where buf_icnt-doc.obj-type = p-obj-type
        and buf_icnt-doc.obj-code = p-obj-code
        and buf_icnt-doc.status_  = 'факт':U
    on error undo, return error
    :
      define variable v-fact-num as integer   no-undo .
      assign
        v-fact-num = (buf_icnt-doc.fact-order * 100
                      - truncate(buf_icnt-doc.fact-order * 100, 0) )
                      * 100000000
      .
      define variable v-fact-order           as decimal no-undo .
      define variable v-shift-end-fact-order as decimal no-undo .
      define variable v-day-end-fact-order   as decimal no-undo .
      run factord in this-procedure
        (input  buf_icnt-doc.fact-date
        ,input  buf_icnt-doc.fact-time
        ,input  v-fact-num
        ,input  buf_icnt-doc.shift-date
        ,input  buf_icnt-doc.shift-num
        ,input  p-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error then do:
        output stream slog to factofil.err append .
        export stream slog
          "err-icnt-doc"
          buf_icnt-doc.obj-type buf_icnt-doc.obj-code
          buf_icnt-doc.doc-code buf_icnt-doc.fact-date buf_icnt-doc.fact-time
          buf_icnt-doc.fact-num buf_icnt-doc.shift-date buf_icnt-doc.shift-num
          buf_icnt-doc.fact-order
          return-value .
        output stream slog close .
        assign
          v-error-count = v-error-count + 1
        .
      end.
      else do:
        if buf_icnt-doc.fact-order <> v-fact-order then do:
          output stream slog to factofil.fix append .
          export stream slog
            "fix-icnt-doc"
            buf_icnt-doc.doc-code buf_icnt-doc.fact-date buf_icnt-doc.fact-time
            buf_icnt-doc.fact-num buf_icnt-doc.shift-date buf_icnt-doc.shift-num
            buf_icnt-doc.fact-order v-fact-order
            .
          output stream slog close .
          assign
            v-fix-count = v-fix-count + 1
          .
          assign
            buf_icnt-doc.fact-order = v-fact-order
          .
        end.
      end.
    end.
  end.
end procedure.
procedure process-stk-archive :
  define input parameter p-obj-type like ub.price-list.obj-type no-undo .
  define input parameter p-obj-code like ub.price-list.obj-code no-undo .
  define input parameter p-shift-on as logical no-undo .
  do
  on error undo, return error
  :
    if p-install = false then do:
      run waitfram-show in this-procedure (input substitute("Обработка архивов по товарам. Объект &1 &2", p-obj-type, p-obj-code)
        ).
    end.
    define buffer buf_stk-tot for ub.stk-tot .
    for each buf_stk-tot exclusive-lock
      where buf_stk-tot.obj-type   = p-obj-type
        and buf_stk-tot.obj-code   = p-obj-code
        and buf_stk-tot.shift-date <> ?
    on error undo, return error
    :
      define variable v-fact-order           as decimal no-undo .
      define variable v-shift-end-fact-order as decimal no-undo .
      define variable v-day-end-fact-order   as decimal no-undo .
      run factord in this-procedure
        (input  buf_stk-tot.fact-date
        ,input  0
        ,input  1
        ,input  buf_stk-tot.shift-date
        ,input  buf_stk-tot.shift-num
        ,input  p-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error then do:
        output stream slog to factofil.err append .
        export stream slog
          "err-stk-tot"
          buf_stk-tot.obj-type buf_stk-tot.obj-code
          buf_stk-tot.fact-date
          buf_stk-tot.shift-date buf_stk-tot.shift-num
          buf_stk-tot.fact-order
          return-value .
        output stream slog close .
        assign
          v-error-count = v-error-count + 1
        .
      end.
      else do:
        if buf_stk-tot.fact-order <> v-shift-end-fact-order then do:
          output stream slog to factofil.fix append .
          export stream slog
            "fix-stk-tot"
            buf_stk-tot.obj-type buf_stk-tot.obj-code buf_stk-tot.fact-date
            buf_stk-tot.shift-date buf_stk-tot.shift-num
            buf_stk-tot.fact-order
            .
          output stream slog close .
          assign
            v-fix-count = v-fix-count + 1
          .
          assign
            buf_stk-tot.fact-order = v-shift-end-fact-order
          .
        end.
      end.
    end.
    define buffer buf_stk-line for ub.stk-line .
    for each buf_stk-line exclusive-lock
      where buf_stk-line.obj-type   = p-obj-type
        and buf_stk-line.obj-code   = p-obj-code
        and buf_stk-line.shift-date <> ?
    on error undo, return error
    :
      run factord in this-procedure
        (input  buf_stk-line.fact-date
        ,input  0
        ,input  1
        ,input  buf_stk-line.shift-date
        ,input  buf_stk-line.shift-num
        ,input  p-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error then do:
        output stream slog to factofil.err append .
        export stream slog
          "err-stk-line"
          buf_stk-line.obj-type buf_stk-line.obj-code buf_stk-line.fact-date
          buf_stk-line.shift-date buf_stk-line.shift-num
          buf_stk-line.fact-order
          return-value .
        output stream slog close .
        assign
          v-error-count = v-error-count + 1
        .
      end.
      else do:
        if buf_stk-line.fact-order <> v-shift-end-fact-order then do:
          output stream slog to factofil.fix append .
          export stream slog
            "fix-stk-line"
            buf_stk-line.obj-type buf_stk-line.obj-code buf_stk-line.fact-date
            buf_stk-line.shift-date buf_stk-line.shift-num
            buf_stk-line.fact-order
            .
          output stream slog close .
          assign
            v-fix-count = v-fix-count + 1
          .
          assign
            buf_stk-line.fact-order = v-shift-end-fact-order
          .
        end.
      end.
    end.
    if p-install = false then do:
      run waitfram-show in this-procedure (input substitute("Обработка архивов по поставщикам. Объект &1 &2", p-obj-type, p-obj-code)
        ).
    end.
    define buffer buf_stk-supp-tot for ub.stk-supp-tot .
    for each buf_stk-supp-tot exclusive-lock
      where buf_stk-supp-tot.obj-type   = p-obj-type
        and buf_stk-supp-tot.obj-code   = p-obj-code
        and buf_stk-supp-tot.shift-date <> ?
    on error undo, return error
    :
      run factord in this-procedure
        (input  buf_stk-supp-tot.fact-date
        ,input  0
        ,input  1
        ,input  buf_stk-supp-tot.shift-date
        ,input  buf_stk-supp-tot.shift-num
        ,input  p-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error then do:
        output stream slog to factofil.err append .
        export stream slog
          "err-stk-supp-tot"
          buf_stk-supp-tot.obj-type buf_stk-supp-tot.obj-code buf_stk-supp-tot.fact-date
          buf_stk-supp-tot.shift-date buf_stk-supp-tot.shift-num
          buf_stk-supp-tot.fact-order
          return-value .
        output stream slog close .
        assign
          v-error-count = v-error-count + 1
        .
      end.
      else do:
        if buf_stk-supp-tot.fact-order <> v-shift-end-fact-order then do:
          output stream slog to factofil.fix append .
          export stream slog
            "fix-stk-supp-tot"
            buf_stk-supp-tot.obj-type buf_stk-supp-tot.obj-code buf_stk-supp-tot.fact-date
            buf_stk-supp-tot.shift-date buf_stk-supp-tot.shift-num
            buf_stk-supp-tot.fact-order
            .
          output stream slog close .
          assign
            v-fix-count = v-fix-count + 1
          .
          assign
            buf_stk-supp-tot.fact-order = v-shift-end-fact-order
          .
        end.
      end.
    end.
    define buffer buf_stk-supp-line for ub.stk-supp-line .
    for each buf_stk-supp-line exclusive-lock
      where buf_stk-supp-line.obj-type   = p-obj-type
        and buf_stk-supp-line.obj-code   = p-obj-code
        and buf_stk-supp-line.shift-date <> ?
    on error undo, return error
    :
      run factord in this-procedure
        (input  buf_stk-supp-line.fact-date
        ,input  0
        ,input  1
        ,input  buf_stk-supp-line.shift-date
        ,input  buf_stk-supp-line.shift-num
        ,input  p-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error then do:
        output stream slog to factofil.err append .
        export stream slog
          "err-stk-supp-line"
          buf_stk-supp-line.obj-type buf_stk-supp-line.obj-code buf_stk-supp-line.fact-date
          buf_stk-supp-line.shift-date buf_stk-supp-line.shift-num
          buf_stk-supp-line.fact-order
          return-value .
        output stream slog close .
        assign
          v-error-count = v-error-count + 1
        .
      end.
      else do:
        if buf_stk-supp-line.fact-order <> v-shift-end-fact-order then do:
          output stream slog to factofil.fix append .
          export stream slog
            "fix-stk-supp-line"
            buf_stk-supp-line.obj-type buf_stk-supp-line.obj-code buf_stk-supp-line.fact-date
            buf_stk-supp-line.shift-date buf_stk-supp-line.shift-num
            buf_stk-supp-line.fact-order
            .
          output stream slog close .
          assign
            v-fix-count = v-fix-count + 1
          .
          assign
            buf_stk-supp-line.fact-order = v-shift-end-fact-order
          .
        end.
      end.
    end.
  end.
end procedure.
procedure process-shift-obj :
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer   no-undo .
  define input parameter p-shift-on as logical   no-undo .
  do
  on error undo, return error
  :
    define buffer buf_shift-obj for ub.shift-obj .
    for each buf_shift-obj exclusive-lock
      where buf_shift-obj.obj-type = p-obj-type
        and buf_shift-obj.obj-code = p-obj-code
        and buf_shift-obj.status_  = 'факт':U
    on error undo, return error
    :
      define variable v-fact-order           as decimal no-undo .
      define variable v-shift-end-fact-order as decimal no-undo .
      define variable v-day-end-fact-order   as decimal no-undo .
      run factord in this-procedure
        (input  buf_shift-obj.close-date
        ,input  buf_shift-obj.close-time
        ,input  1
        ,input  buf_shift-obj.shift-date
        ,input  buf_shift-obj.shift-num
        ,input  p-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error then do:
        output stream slog to factofil.err append .
        export stream slog
          "err-shift-obj"
          buf_shift-obj.obj-type buf_shift-obj.obj-code
          buf_shift-obj.close-date buf_shift-obj.close-time
          buf_shift-obj.shift-date buf_shift-obj.shift-num
          buf_shift-obj.fact-order
          return-value .
        output stream slog close .
        assign
          v-error-count = v-error-count + 1
        .
      end.
      else do:
        if buf_shift-obj.fact-order <> v-shift-end-fact-order then do:
          output stream slog to factofil.fix append .
          export stream slog
            "fix-shift-obj"
            buf_shift-obj.obj-type buf_shift-obj.obj-code
            buf_shift-obj.close-date buf_shift-obj.close-time
            buf_shift-obj.shift-date buf_shift-obj.shift-num
            buf_shift-obj.fact-order
            .
          output stream slog close .
          assign
            v-fix-count = v-fix-count + 1
          .
          assign
            buf_shift-obj.fact-order = v-shift-end-fact-order
          .
        end.
      end.
    end.
  end.
end procedure.
