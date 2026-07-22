block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: abc-a.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/abc-a.p $":U .
define variable vss-description as character no-undo init "Формирование таблицы с оборотами и прибылями для ABC XYZ анализов".
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
define temp-table temp-oborot no-undo
field gds-code       as integer
field obj-type       as char
field obj-code       as integer
field sum-crit       as decimal
field qnty           as decimal
field price-crc      as decimal
field price-cost     as decimal
field reserve-day    as integer
field stock-qnty     as decimal
field sum-acc        as decimal
field sum-cur        as decimal
field sum-doc        as decimal
field vat-acc        as decimal
field vat-cur        as decimal
field vat-doc        as decimal
field transport-acc  as decimal
field transport-cur  as decimal
field transport-doc  as decimal
field other-acc      as decimal
field other-cur      as decimal
field other-doc      as decimal
field road-tax-acc   as decimal
field road-tax-cur   as decimal
field road-tax-doc   as decimal
field slt-acc        as decimal
field slt-cur        as decimal
field slt-doc        as decimal
field order-qnty     as decimal
field temp-sale-goods  as decimal
index pi as unique primary  gds-code obj-type obj-code
.
define temp-table temp-goods no-undo
field gds-code       as integer
field sum-crit       as decimal
field crit-pr        as decimal
field crit           as char
field kol-period     as int
field average-qnty   as decimal
field sigma          as decimal
field K_V            as decimal
field qnty           as decimal
field price-crc      as decimal
field reserve-day    as integer
field sum-acc        as decimal
field sum-cur        as decimal
field sum-doc        as decimal
field vat-acc        as decimal
field vat-cur        as decimal
field vat-doc        as decimal
field transport-acc  as decimal
field transport-cur  as decimal
field transport-doc  as decimal
field other-acc      as decimal
field other-cur      as decimal
field other-doc      as decimal
field road-tax-acc   as decimal
field road-tax-cur   as decimal
field road-tax-doc   as decimal
field slt-acc        as decimal
field slt-cur        as decimal
field slt-doc        as decimal
field order-qnty       as decimal
field stock-price-acc  as decimal
field stock-price-sale as decimal
field stock-qnty       as decimal
field temp-sale-goods  as decimal
field prcnt-account as decimal
index pi as UNIQUE primary  gds-code
index pi-1 crit-pr desc
.
define temp-table temp-xyz no-undo
field gds-code       as integer
field num-per        as integer
field sum-crit-p     as decimal
index pi2 as UNIQUE primary   gds-code num-per
.
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
define shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
DEFINE TEMP-TABLE x-analysis        no-undo  LIKE ub.abc-analysis.
DEFINE TEMP-TABLE x-analysis-doc    no-undo  LIKE ub.abc-analysis-doc.
DEFINE TEMP-TABLE x-analysis-obj    no-undo  LIKE ub.abc-analysis-obj.
DEFINE TEMP-TABLE x-analysis-period no-undo  LIKE ub.abc-analysis-period.
define temp-table tt-aht-ot-line no-undo like ub.aht-ot-line .
define input  parameter parparentproc as widget-handle no-undo.
define input  parameter p-type as character no-undo .
define input  parameter p-id     as integer   no-undo .
define input  parameter p-db-num as integer   no-undo .
define input  PARAMETER TABLE FOR    x-analysis.
define input  PARAMETER TABLE FOR    x-analysis-doc.
define input  PARAMETER TABLE FOR    x-analysis-obj.
define input  PARAMETER TABLE FOR    x-analysis-period.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define temp-table temp-oborot1 no-undo like temp-oborot .
define temp-table temp-oborot2 no-undo like temp-oborot .
define temp-table temp-goods1  no-undo like temp-goods .
define temp-table temp-goods2  no-undo like temp-goods .
define temp-table temp-tt no-undo
field id        as recid
field summa     as decimal
field proc      as decimal
field proc-2    as decimal
field proc-acc1 as decimal
field proc-acc2 as decimal
field ABC-1     as character
field ABC       as character
index pi proc desc
index pi1 proc-acc1 desc
index pi2 proc-acc2 desc
index pi3 id
.
define variable p-ver-aht as logical   no-undo .
define variable i as integer   no-undo .
define variable v-i as character no-undo EXTENT 5.
define variable v-day as integer   no-undo .
define variable v-date-1  as date   no-undo .
define variable v-date-2  as date   no-undo .
run ver-aht in this-procedure (output p-ver-aht) no-error .
 for each temp-oborot  : delete temp-oborot . end.
 for each temp-oborot1 : delete temp-oborot1 . end.
 for each temp-oborot2 : delete temp-oborot2 . end.
 find first x-analysis no-error .
assign
  v-i[1] = 'r':U
  v-i[2] = 'c':U
  v-i[3] = 'b':U
  v-i[4] = 's':U
  v-i[5] = 'o':U
.
  run make-tt in this-procedure  .
  run ref/func-abc.p
      ( input table x-analysis
      , input-output table temp-oborot
      , output table temp-goods )
  .
 for each temp-tt : delete temp-tt . end.
 for each temp-goods :
     create temp-tt.
     assign
       temp-tt.id = recid(temp-goods)
       temp-tt.summa = temp-goods.sum-crit
     .
 end.
  run ref/tt-abc.p
      ( input table x-analysis
      , input-output table temp-tt )
  .
 for each temp-goods :
     find first temp-tt where  temp-tt.id = recid(temp-goods) .
     temp-goods.crit = temp-tt.abc .
     if x-analysis.abc-type = "2"  then do:
       temp-goods.prcnt-account = temp-tt.proc-acc2.
     end.
     else do:
       temp-goods.prcnt-account = temp-tt.proc-acc1.
     end.
 end.
 run save-table in this-procedure .
 run make-other-table in this-procedure .
procedure make-tt :
  do
  on error undo, return error return-value
  :
define buffer buf_gds-obj for ub.gds-obj.
define variable v-sum-crit      as decimal   no-undo .
define variable v-sum-qnty      as decimal   no-undo .
define variable v-price-crc     as decimal   no-undo .
define variable v-reserve-day   as decimal   no-undo .
define variable v-stock-qnty    as decimal   no-undo .
define variable v-sum-acc       as decimal   no-undo .
define variable v-sum-cur       as decimal   no-undo .
define variable v-sum-doc       as decimal   no-undo .
define variable v-vat-acc       as decimal   no-undo .
define variable v-vat-cur       as decimal   no-undo .
define variable v-vat-doc       as decimal   no-undo .
define variable v-transport-acc as decimal   no-undo .
define variable v-transport-cur as decimal   no-undo .
define variable v-transport-doc as decimal   no-undo .
define variable v-other-acc     as decimal   no-undo .
define variable v-other-cur     as decimal   no-undo .
define variable v-other-doc     as decimal   no-undo .
define variable v-road-tax-acc  as decimal   no-undo .
define variable v-road-tax-cur  as decimal   no-undo .
define variable v-road-tax-doc  as decimal   no-undo .
define variable v-slt-acc       as decimal   no-undo .
define variable v-slt-cur       as decimal   no-undo .
define variable v-slt-doc       as decimal   no-undo .
define variable v-exist         as logical   no-undo .
run waitfram-show in this-procedure ("Формирование таблицы оборотов...").
    for each x-analysis-obj :
      run waitfram-show in this-procedure ("Формирование таблицы оборотов...По объекту " + x-analysis-obj.obj-type + " " + string(x-analysis-obj.obj-code)).
            for each buf_gds-obj no-lock where
                buf_gds-obj.obj-type = x-analysis-obj.obj-type and
                buf_gds-obj.obj-code = x-analysis-obj.obj-code
                :
                if x-analysis.r-goods = 2 then do:
                   if not can-find( first gds-list where buf_gds-obj.gds-code = gds-list.gds-code) then next .
                end.
                run def-sum in this-procedure (
                   input  x-analysis-obj.obj-type
                  ,input  x-analysis-obj.obj-code
                  ,input  buf_gds-obj.gds-code
                  ,output v-sum-crit
                  ,output v-sum-qnty
                  ,output v-price-crc
                  ,output v-reserve-day
                  ,output v-stock-qnty
                  ,output v-sum-acc
                  ,output v-sum-cur
                  ,output v-sum-doc
                  ,output v-vat-acc
                  ,output v-vat-cur
                  ,output v-vat-doc
                  ,output v-transport-acc
                  ,output v-transport-cur
                  ,output v-transport-doc
                  ,output v-other-acc
                  ,output v-other-cur
                  ,output v-other-doc
                  ,output v-road-tax-acc
                  ,output v-road-tax-cur
                  ,output v-road-tax-doc
                  ,output v-slt-acc
                  ,output v-slt-cur
                  ,output v-slt-doc
                  ,output v-exist
                  ) .
                  if v-exist  = true then do:
                  find first  temp-oborot where
                      temp-oborot.obj-type = buf_gds-obj.obj-type and
                      temp-oborot.obj-code = buf_gds-obj.obj-code and
                      temp-oborot.gds-code = buf_gds-obj.gds-code
                      no-error .
                      if not available temp-oborot then do:
                        create temp-oborot.
                      end.
                      assign
                          temp-oborot.obj-type      = buf_gds-obj.obj-type
                          temp-oborot.obj-code      = buf_gds-obj.obj-code
                          temp-oborot.gds-code      = buf_gds-obj.gds-code
                          temp-oborot.sum-crit      = v-sum-crit
                          temp-oborot.qnty          = v-sum-qnty
                          temp-oborot.price-crc     = buf_gds-obj.price-sale
                          temp-oborot.reserve-day   = v-reserve-day
                          temp-oborot.stock-qnty    = buf_gds-obj.fact-qnty
                          temp-oborot.sum-acc       = v-sum-acc
                          temp-oborot.sum-cur       = v-sum-cur
                          temp-oborot.sum-doc       = v-sum-doc
                          temp-oborot.vat-acc       = v-vat-acc
                          temp-oborot.vat-cur       = v-vat-cur
                          temp-oborot.vat-doc       = v-vat-doc
                          temp-oborot.transport-acc = v-transport-acc
                          temp-oborot.transport-cur = v-transport-cur
                          temp-oborot.transport-doc = v-transport-doc
                          temp-oborot.other-acc     = v-other-acc
                          temp-oborot.other-cur     = v-other-cur
                          temp-oborot.other-doc     = v-other-doc
                          temp-oborot.road-tax-acc  = v-road-tax-acc
                          temp-oborot.road-tax-cur  = v-road-tax-cur
                          temp-oborot.road-tax-doc  = v-road-tax-doc
                          temp-oborot.slt-acc       = v-slt-acc
                          temp-oborot.slt-cur       = v-slt-cur
                          temp-oborot.slt-doc       = v-slt-doc
                      .
                    if lookup(string(x-analysis.cral-id) ,"5,6,7,9,11,13,15") = 0 then
                              temp-oborot.price-cost    = buf_gds-obj.fact-rubl .
                        else temp-oborot.price-cost    = buf_gds-obj.fact-base .
                      run def-order in this-procedure (
                          input  buf_gds-obj.obj-type
                          ,input  buf_gds-obj.obj-code
                          ,input  buf_gds-obj.artic
                          ,input  buf_gds-obj.prod-type
                          ,input  buf_gds-obj.prod-code
                          ,output temp-oborot.order-qnty  ) .
                  end.
        end.
    end.
  end.
end procedure.
procedure def-sum :
do
on error undo, return error return-value
:
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-gds-code as integer   no-undo .
define output parameter v-sum-crit       as decimal   no-undo .
define output parameter v-sum-qnty       as decimal   no-undo .
define output parameter v-price-crc      as decimal   no-undo .
define output parameter v-reserve-day    as decimal   no-undo .
define output parameter v-stock-qnty     as decimal   no-undo .
define output parameter v-sum-acc        as decimal   no-undo .
define output parameter v-sum-cur        as decimal   no-undo .
define output parameter v-sum-doc        as decimal   no-undo .
define output parameter v-vat-acc        as decimal   no-undo .
define output parameter v-vat-cur        as decimal   no-undo .
define output parameter v-vat-doc        as decimal   no-undo .
define output parameter v-transport-acc  as decimal   no-undo .
define output parameter v-transport-cur  as decimal   no-undo .
define output parameter v-transport-doc  as decimal   no-undo .
define output parameter v-other-acc      as decimal   no-undo .
define output parameter v-other-cur      as decimal   no-undo .
define output parameter v-other-doc      as decimal   no-undo .
define output parameter v-road-tax-acc   as decimal   no-undo .
define output parameter v-road-tax-cur   as decimal   no-undo .
define output parameter v-road-tax-doc   as decimal   no-undo .
define output parameter v-slt-acc        as decimal   no-undo .
define output parameter v-slt-cur        as decimal   no-undo .
define output parameter v-slt-doc        as decimal   no-undo .
define output parameter p-exist          as logical   no-undo .
define variable  p-date-1 as date   no-undo .
define variable  p-date-2 as date   no-undo .
define variable v-fact-order-1 as decimal   no-undo .
define variable v-fact-order-2 as decimal   no-undo .
define variable v-sum          as decimal   no-undo .
define buffer buf_aht-ot-line for ub.aht-ot-line.
p-exist = false .
find first x-analysis no-error .
if error-status :error then message error-status :get-message(1) "7770" view-as alert-box information .
for each tt-aht-ot-line : delete tt-aht-ot-line . end.
    for each x-analysis-period :
      assign
        p-date-1 = x-analysis-period.abcp-start
        p-date-2 = x-analysis-period.abcp-end
      .
      run day-begin-fact-order in this-procedure (input p-date-1 , output  v-fact-order-1).
      run factord-end-day in this-procedure       (input p-date-2 , output  v-fact-order-2).
      for each x-analysis-doc :
        repeat i = 1 to 5 :
            for each buf_aht-ot-line no-lock where
                    buf_aht-ot-line.ext-doc-type = x-analysis-doc.abcd-ext-doc-type and
                    buf_aht-ot-line.gds-code     = p-gds-code                       and
                    buf_aht-ot-line.obj-code     = p-obj-code                       and
                    buf_aht-ot-line.obj-type     = p-obj-type                       and
                    buf_aht-ot-line.sum-type     = v-i[i]                           and
                    buf_aht-ot-line.fact-order   >= v-fact-order-1                  and
                    buf_aht-ot-line.fact-order   <= v-fact-order-2
            :
                create tt-aht-ot-line.
                buffer-copy buf_aht-ot-line to tt-aht-ot-line .
                if buf_aht-ot-line.sum-type = 'b':U then do:
                   tt-aht-ot-line.fact-qnty  = 0 .
                end.
            end.
        end.
      end.
    end.
    define buffer buf_aht-stk-line for ub.aht-stk-line  .
    repeat i = 1 to 5 :
        find last buf_aht-stk-line no-lock where
                        buf_aht-stk-line.gds-code     = p-gds-code and
                        buf_aht-stk-line.obj-code     = p-obj-code and
                        buf_aht-stk-line.obj-type     = p-obj-type and
                        buf_aht-stk-line.sum-type     = v-i[i]     and
                        buf_aht-stk-line.fact-order   <= v-fact-order-2  use-index category no-error .
        if  available buf_aht-stk-line and buf_aht-stk-line.fact-qnty <> 0 then do:
            p-exist = true  .
            leave.
        end.
    end.
assign
  v-sum-crit        = 0
  v-sum-qnty        = 0
  v-price-crc       = 0
  v-reserve-day     = 0
  v-stock-qnty      = 0
  v-sum-acc         = 0
  v-sum-cur         = 0
  v-sum-doc         = 0
  v-vat-acc         = 0
  v-vat-cur         = 0
  v-vat-doc         = 0
  v-transport-acc   = 0
  v-transport-cur   = 0
  v-transport-doc   = 0
  v-other-acc       = 0
  v-other-cur       = 0
  v-other-doc       = 0
  v-road-tax-acc    = 0
  v-road-tax-cur    = 0
  v-road-tax-doc    = 0
  v-slt-acc         = 0
  v-slt-cur         = 0
  v-slt-doc         = 0
.
for each tt-aht-ot-line :
    p-exist = true  .
    v-sum-qnty          = v-sum-qnty         + tt-aht-ot-line.fact-qnty .
    if lookup(string(x-analysis.cral-id) ,"5,6,7,9,11,13,15") = 0 then
    assign
      v-sum-acc         = v-sum-acc         + tt-aht-ot-line.cost-sum-rubl
      v-sum-cur         = v-sum-cur         + tt-aht-ot-line.crsa-sum-rubl
      v-sum-doc         = v-sum-doc         + tt-aht-ot-line.sale-sum-rubl
      v-vat-acc         = v-vat-acc         + tt-aht-ot-line.cost-vat-rubl
      v-vat-cur         = v-vat-cur         + tt-aht-ot-line.crsa-vat-rubl
      v-vat-doc         = v-vat-doc         + tt-aht-ot-line.sale-vat-rubl
      v-transport-acc   = v-transport-acc   + tt-aht-ot-line.cost-transport-rubl
      v-transport-cur   = v-transport-cur   + tt-aht-ot-line.crsa-transport-rubl
      v-transport-doc   = v-transport-doc   + tt-aht-ot-line.sale-transport-rubl
      v-other-acc       = v-other-acc       + tt-aht-ot-line.cost-other-rubl
      v-other-cur       = v-other-cur       + tt-aht-ot-line.crsa-other-rubl
      v-other-doc       = v-other-doc       + tt-aht-ot-line.sale-other-rubl
      v-road-tax-acc    = v-road-tax-acc    + tt-aht-ot-line.cost-road-tax-rubl
      v-road-tax-cur    = v-road-tax-cur    + tt-aht-ot-line.crsa-road-tax-rubl
      v-road-tax-doc    = v-road-tax-doc    + tt-aht-ot-line.sale-road-tax-rubl
      v-slt-acc         = v-slt-acc         + tt-aht-ot-line.cost-slt-rubl
      v-slt-cur         = v-slt-cur         + tt-aht-ot-line.crsa-slt-rubl
      v-slt-doc         = v-slt-doc         + tt-aht-ot-line.sale-slt-rubl
    .
    else
    assign
      v-sum-acc         = v-sum-acc         + tt-aht-ot-line.cost-sum-base
      v-sum-cur         = v-sum-cur         + tt-aht-ot-line.crsa-sum-base
      v-sum-doc         = v-sum-doc         + tt-aht-ot-line.sale-sum-base
      v-vat-acc         = v-vat-acc         + tt-aht-ot-line.cost-vat-base
      v-vat-cur         = v-vat-cur         + tt-aht-ot-line.crsa-vat-base
      v-vat-doc         = v-vat-doc         + tt-aht-ot-line.sale-vat-base
      v-transport-acc   = v-transport-acc   + tt-aht-ot-line.cost-transport-base
      v-transport-cur   = v-transport-cur   + tt-aht-ot-line.crsa-transport-base
      v-transport-doc   = v-transport-doc   + tt-aht-ot-line.sale-transport-base
      v-other-acc       = v-other-acc       + tt-aht-ot-line.cost-other-base
      v-other-cur       = v-other-cur       + tt-aht-ot-line.crsa-other-base
      v-other-doc       = v-other-doc       + tt-aht-ot-line.sale-other-base
      v-road-tax-acc    = v-road-tax-acc    + tt-aht-ot-line.cost-road-tax-base
      v-road-tax-cur    = v-road-tax-cur    + tt-aht-ot-line.crsa-road-tax-base
      v-road-tax-doc    = v-road-tax-doc    + tt-aht-ot-line.sale-road-tax-base
      v-slt-acc         = v-slt-acc         + tt-aht-ot-line.cost-slt-base
      v-slt-cur         = v-slt-cur         + tt-aht-ot-line.crsa-slt-base
      v-slt-doc         = v-slt-doc         + tt-aht-ot-line.sale-slt-base
    .
      case x-analysis.cral-id :
        when 1
        then do:
            run calc-qnty in this-procedure (output v-sum).
        end.
        when 2
        then do:
            run calc-str-oborot in this-procedure ( "rubl" , "cost" , "with-vat" , output v-sum).
        end.
        when 3
        then do:
            run calc-str-oborot in this-procedure  ( "rubl" , "sale" , "with-vat" , output v-sum).
        end.
        when 4
        then do:
            run calc-str-oborot in this-procedure  ( "rubl" , "crsa" , "with-vat" , output v-sum).
        end.
        when 5
        then do:
          run calc-str-oborot in this-procedure  ( "base" , "cost" , "with-vat" , output v-sum).
        end.
        when 6
        then do:
            run calc-str-oborot in this-procedure  ( "base" , "sale" , "with-vat" , output v-sum).
        end.
        when 7
        then do:
            run calc-str-oborot in this-procedure  ( "base" , "crsa" , "with-vat" , output v-sum).
        end.
        when 8
        then do:
          run calc-str-prib in this-procedure  ( "rubl" , "sale" , "cost" , "without-vat" , output v-sum).
        end.
        when 9
        then do:
            run calc-str-prib in this-procedure  ( "base" , "sale" , "cost" , "without-vat" , output v-sum).
        end.
        when 10
        then do:
              run calc-str-prib in this-procedure  ( "rubl" , "sale" , "cost" , "with-vat" , output v-sum).
        end.
        when 11
        then do:
              run calc-str-prib in this-procedure  ( "base" , "sale" , "cost" , "with-vat" , output v-sum).
        end.
        when 12
        then do:
              run calc-str-prib in this-procedure  ( "rubl" , "crsa" , "cost" , "without-vat" , output v-sum).
        end.
        when 13
        then do:
              run calc-str-prib in this-procedure  ( "base" , "crsa" , "cost" , "without-vat" , output v-sum).
        end.
        when 14
        then do:
              run calc-str-prib in this-procedure  ( "rubl" , "crsa" , "cost" , "with-vat" , output v-sum).
        end.
        when 15
        then do:
                run calc-str-prib in this-procedure  ( "base" , "crsa" , "cost" , "with-vat" , output v-sum).
        end.
      end case.
     v-sum-crit = v-sum-crit + v-sum .
end.
assign
  v-sum-crit      = (-1) * v-sum-crit
  v-sum-qnty      = (-1) * v-sum-qnty
  v-sum-acc       = (-1) * v-sum-acc
  v-sum-cur       = (-1) * v-sum-cur
  v-sum-doc       = (-1) * v-sum-doc
  v-vat-acc       = (-1) * v-vat-acc
  v-vat-cur       = (-1) * v-vat-cur
  v-vat-doc       = (-1) * v-vat-doc
  v-transport-acc = (-1) * v-transport-acc
  v-transport-cur = (-1) * v-transport-cur
  v-transport-doc = (-1) * v-transport-doc
  v-other-acc     = (-1) * v-other-acc
  v-other-cur     = (-1) * v-other-cur
  v-other-doc     = (-1) * v-other-doc
  v-road-tax-acc  = (-1) * v-road-tax-acc
  v-road-tax-cur  = (-1) * v-road-tax-cur
  v-road-tax-doc  = (-1) * v-road-tax-doc
  v-slt-acc       = (-1) * v-slt-acc
  v-slt-cur       = (-1) * v-slt-cur
  v-slt-doc       = (-1) * v-slt-doc
.
end.
end procedure.
procedure calc-str-oborot :
  do
  on error undo, return error return-value
  :
define input  parameter p-val as character no-undo .
define input  parameter p-sum-type as character no-undo .
define input  parameter p-vat as character no-undo .
define output parameter p-sum as decimal   no-undo .
  case p-val :
     when "rubl" then do:
            case p-sum-type :
              when "crsa" then do:
                    p-sum = tt-aht-ot-line.crsa-sum-rubl.
              end.
              when "cost" then do:
                    p-sum = tt-aht-ot-line.cost-sum-rubl.
              end.
              when "sale" then do:
                    p-sum = tt-aht-ot-line.sale-sum-rubl.
              end.
            end case.
     end.
     when "base" then do:
            case p-sum-type :
              when "crsa" then do:
                    p-sum = tt-aht-ot-line.crsa-sum-base.
              end.
              when "cost" then do:
                    p-sum = tt-aht-ot-line.cost-sum-base.
              end.
              when "sale" then do:
                    p-sum = tt-aht-ot-line.sale-sum-base.
              end.
            end case.
     end.
  end case.
  end.
end procedure.
procedure calc-str-prib :
  do
  on error undo, return error return-value
  :
define input  parameter p-val as character no-undo .
define input  parameter p-sum-type1 as character no-undo .
define input  parameter p-sum-type2 as character no-undo .
define input  parameter p-vat as character no-undo .
define output parameter p-sum as decimal   no-undo .
      if p-vat = "with-vat" then do:
        case p-val :
          when "rubl" then do:
                  case p-sum-type1 :
                    when "crsa" then do:
                          p-sum = tt-aht-ot-line.crsa-sum-rubl - tt-aht-ot-line.cost-sum-rubl.
                    end.
                    when "sale" then do:
                          p-sum = tt-aht-ot-line.sale-sum-rubl - tt-aht-ot-line.cost-sum-rubl.
                    end.
                  end case.
          end.
          when "base" then do:
                  case p-sum-type1 :
                    when "crsa" then do:
                          p-sum = tt-aht-ot-line.crsa-sum-base - tt-aht-ot-line.cost-sum-base.
                    end.
                    when "sale" then do:
                          p-sum = tt-aht-ot-line.sale-sum-base - tt-aht-ot-line.cost-sum-base.
                    end.
                  end case.
          end.
        end case.
      end.
      else do:
        case p-val :
          when "rubl" then do:
                  case p-sum-type1 :
                    when "crsa" then do:
                          p-sum = (tt-aht-ot-line.crsa-sum-rubl - tt-aht-ot-line.crsa-vat-rubl - tt-aht-ot-line.crsa-slt-rubl ) -
                                  (tt-aht-ot-line.cost-sum-rubl - tt-aht-ot-line.cost-vat-rubl - tt-aht-ot-line.cost-slt-rubl ) .
                    end.
                    when "sale" then do:
                          p-sum = ( tt-aht-ot-line.sale-sum-rubl - tt-aht-ot-line.sale-vat-rubl - tt-aht-ot-line.sale-slt-rubl ) -
                                  ( tt-aht-ot-line.cost-sum-rubl - tt-aht-ot-line.cost-vat-rubl - tt-aht-ot-line.cost-slt-rubl ).
                    end.
                  end case.
          end.
          when "base" then do:
                  case p-sum-type1 :
                    when "crsa" then do:
                          p-sum = (tt-aht-ot-line.crsa-sum-base - tt-aht-ot-line.crsa-vat-base - tt-aht-ot-line.crsa-slt-base ) -
                                  (tt-aht-ot-line.cost-sum-base - tt-aht-ot-line.cost-vat-base - tt-aht-ot-line.cost-slt-base ) .
                    end.
                    when "sale" then do:
                          p-sum = ( tt-aht-ot-line.sale-sum-base - tt-aht-ot-line.sale-vat-base - tt-aht-ot-line.sale-slt-base ) -
                                  ( tt-aht-ot-line.cost-sum-base - tt-aht-ot-line.cost-vat-base - tt-aht-ot-line.cost-slt-base ).
                    end.
                  end case.
          end.
        end case.
      end.
  end.
end procedure.
procedure calc-qnty :
do
on error undo, return error return-value
:
define output parameter p-sum as decimal   no-undo .
  p-sum = tt-aht-ot-line.fact-qnty.
end.
end procedure.
procedure ver-aht :
  do
  on error undo, return error return-value
  :
define output parameter v-total-archive-ok as logical   no-undo  .
define variable  v-archive-ok  as logical   no-undo .
define variable  v-comment    as character no-undo .
define variable  v-can-print  as logical   no-undo .
for each x-analysis-period break by x-analysis-period.abcp-start desc :
 v-date-1 = x-analysis-period.abcp-start.
end.
for each x-analysis-period break by x-analysis-period.abcp-end  :
 v-date-2 = x-analysis-period.abcp-end.
end.
for each x-analysis-period break by x-analysis-period.abcp-start desc :
 v-day = v-day + ( x-analysis-period.abcp-end -  x-analysis-period.abcp-start + 1) .
end.
if v-day = 0 or v-day = ? then v-day = 1.
v-total-archive-ok =  true .
    for each x-analysis-obj :
      run rep/chk-ahz.p
        (input        x-analysis-obj.obj-type
        ,input        x-analysis-obj.obj-code
        ,input        false
        ,input        false
        ,input        false
        ,input        true
        ,input        true
        ,input        v-cntxt-db-num
        ,input        v-cntxt-userid
        ,input-output v-date-1
        ,input-output v-date-2
        ,output       v-archive-ok
        ,output       v-comment
        ,output       v-can-print
        ) .
      if v-archive-ok = false  then
      do:
            if v-can-print = false
            then do:
              message
                "ВНИМАНИЕ !!!" skip
                "Анализ не может быть сформирован!" skip
                "На запрошенную дату нет архивов или они сжаты" skip
                v-date-1 v-date-2 skip
                v-comment skip
                view-as alert-box information .
                return error return-value .
            end.
            else do:
              assign
                v-total-archive-ok = false
              .
              leave .
            end.
      end.
    end.
    if v-total-archive-ok = false
    then do:
      define variable v-period-description as character no-undo .
        assign
          v-period-description = substitute("с начала дня &1 по конец дня &2"
                                           ,string(v-date-1, '99/99/9999':u)
                                           ,string(v-date-2,   '99/99/9999':u)
                                           )
        .
      message
        "ВНИМАНИЕ!" skip
        v-comment skip
        "" skip
        "Данные по выбранному периоду" v-period-description "могут быть неполными или некорректными." skip
        "Продолжить формирование анализа?" skip
        view-as alert-box question buttons yes-no update choice as logical  .
          if choice = false
          then do:
            assign
              v-archive-ok = false
            .
            return.
          end.
          else do:
            assign
              v-total-archive-ok = true
            .
          end.
    end.
  end.
end procedure.
procedure save-table :
  do
  on error undo, return error return-value
  :
define buffer buf_goods for ub.goods  .
define variable ii as integer   no-undo .
run waitfram-show in this-procedure ("Сохранение результатов анализа по объектам в БД...").
for each temp-oborot ,
    first temp-goods where
          temp-goods.gds-code = temp-oborot.gds-code
        :
        create ub.abc-analysis-gds-obj.
        assign
          ub.abc-analysis-gds-obj.abc-id = p-id
          ub.abc-analysis-gds-obj.db-num = p-db-num
          ub.abc-analysis-gds-obj.gds-code     = temp-oborot.gds-code
          ub.abc-analysis-gds-obj.obj-code     = temp-oborot.obj-code
          ub.abc-analysis-gds-obj.obj-type     = temp-oborot.obj-type
          ub.abc-analysis-gds-obj.abog-other-acc      =temp-oborot.other-acc
          ub.abc-analysis-gds-obj.abog-other-cur      =temp-oborot.other-cur
          ub.abc-analysis-gds-obj.abog-other-doc      =temp-oborot.other-doc
          ub.abc-analysis-gds-obj.abog-qnty           =temp-oborot.qnty
          ub.abc-analysis-gds-obj.abog-price-crc      =temp-oborot.price-crc
          ub.abc-analysis-gds-obj.abog-reserve-day    =temp-oborot.reserve-day
          ub.abc-analysis-gds-obj.abog-road-tax-acc   =temp-oborot.road-tax-acc
          ub.abc-analysis-gds-obj.abog-road-tax-cur   =temp-oborot.road-tax-cur
          ub.abc-analysis-gds-obj.abog-road-tax-doc   =temp-oborot.road-tax-doc
          ub.abc-analysis-gds-obj.abog-slt-acc        =temp-oborot.slt-acc
          ub.abc-analysis-gds-obj.abog-slt-cur        =temp-oborot.slt-cur
          ub.abc-analysis-gds-obj.abog-slt-doc        =temp-oborot.slt-doc
          ub.abc-analysis-gds-obj.abog-stock-qnty     =temp-oborot.stock-qnty
          ub.abc-analysis-gds-obj.abog-sum-acc        =temp-oborot.sum-acc
          ub.abc-analysis-gds-obj.abog-sum-cur        =temp-oborot.sum-cur
          ub.abc-analysis-gds-obj.abog-sum-doc        =temp-oborot.sum-doc
          ub.abc-analysis-gds-obj.abog-transport-acc  =temp-oborot.transport-acc
          ub.abc-analysis-gds-obj.abog-transport-cur   =temp-oborot.transport-cur
          ub.abc-analysis-gds-obj.abog-transport-doc   =temp-oborot.transport-doc
          ub.abc-analysis-gds-obj.abog-vat-acc     =temp-oborot.vat-acc
          ub.abc-analysis-gds-obj.abog-vat-cur     =temp-oborot.vat-cur
          ub.abc-analysis-gds-obj.abog-vat-doc     =temp-oborot.vat-doc
          ub.abc-analysis-gds-obj.abog-temp-sale-goods   = temp-oborot.qnty / v-day
        .
end.
run waitfram-show in this-procedure ("Сохранение результатов анализа по товарам в БД...").
define variable v-all-sum as decimal   no-undo .
define variable v-all-qnty as decimal   no-undo .
define variable v-a-sum  as decimal   no-undo .
define variable v-a-qnty as decimal   no-undo .
define variable v-b-sum  as decimal   no-undo .
define variable v-b-qnty as decimal   no-undo .
define variable v-c-sum  as decimal   no-undo .
define variable v-c-qnty as decimal   no-undo .
define variable v-d-sum  as decimal   no-undo .
define variable v-d-qnty as decimal   no-undo .
define variable v-e-sum  as decimal   no-undo .
define variable v-e-qnty as decimal   no-undo .
define variable v-f-sum  as decimal   no-undo .
define variable v-f-qnty as decimal   no-undo .
for each temp-goods :
    v-all-sum  = v-all-sum  + temp-goods.sum-crit .
    v-all-qnty = v-all-qnty + 1.
    case temp-goods.crit :
       when "A"
       then do:
            v-a-sum  = v-a-sum  + temp-goods.sum-crit .
            v-a-qnty = v-a-qnty + 1.
       end.
       when "B"
       then do:
            v-b-sum  = v-b-sum  + temp-goods.sum-crit .
            v-b-qnty = v-b-qnty + 1.
       end.
       when "C"
       then do:
            v-c-sum  = v-c-sum  + temp-goods.sum-crit .
            v-c-qnty = v-c-qnty + 1.
       end.
       when "D"
       then do:
            v-d-sum  = v-d-sum  + temp-goods.sum-crit .
            v-d-qnty = v-d-qnty + 1.
       end.
       when "E"
       then do:
            v-e-sum  = v-e-sum  + temp-goods.sum-crit .
            v-e-qnty = v-e-qnty + 1.
       end.
       when "F"
       then do:
            v-f-sum  = v-f-sum  + temp-goods.sum-crit .
            v-f-qnty = v-f-qnty + 1.
       end.
    end case.
    find first buf_goods no-lock  where  buf_goods.gds-code = temp-goods.gds-code no-error .
    create ub.abc-analysis-goods.
    assign
      ub.abc-analysis-goods.abc-id                 = p-id
      ub.abc-analysis-goods.db-num                 = p-db-num
      ub.abc-analysis-goods.gds-code               = temp-goods.gds-code
      ub.abc-analysis-goods.grp-code               = buf_goods.grp-code
      ub.abc-analysis-goods.prod-type              = buf_goods.prod-type
      ub.abc-analysis-goods.prod-code              = buf_goods.prod-code
      ub.abc-analysis-goods.abcg-abc               = temp-goods.crit
      ub.abc-analysis-goods.abcg-order-qnty        = temp-goods.order-qnty
      ub.abc-analysis-goods.abcg-other-acc         = temp-goods.other-acc
      ub.abc-analysis-goods.abcg-other-cur         = temp-goods.other-cur
      ub.abc-analysis-goods.abcg-other-doc         = temp-goods.other-doc
      ub.abc-analysis-goods.abcg-prcnt-for-estimate = temp-goods.crit-pr
      ub.abc-analysis-goods.abcg-prcnt-account     = temp-goods.prcnt-account
      ub.abc-analysis-goods.abcg-qnty              = temp-goods.qnty
      ub.abc-analysis-goods.abcg-road-tax-acc      = temp-goods.road-tax-acc
      ub.abc-analysis-goods.abcg-road-tax-cur      = temp-goods.road-tax-cur
      ub.abc-analysis-goods.abcg-road-tax-doc      = temp-goods.road-tax-doc
      ub.abc-analysis-goods.abcg-slt-acc           = temp-goods.slt-acc
      ub.abc-analysis-goods.abcg-slt-cur           = temp-goods.slt-cur
      ub.abc-analysis-goods.abcg-slt-doc           = temp-goods.slt-doc
      ub.abc-analysis-goods.abcg-stock-qnty        = temp-goods.stock-qnty
      ub.abc-analysis-goods.abcg-stock-price-acc   = temp-goods.stock-price-acc
      ub.abc-analysis-goods.abcg-stock-price-sale  = temp-goods.stock-price-sale
      ub.abc-analysis-goods.abcg-sum-acc           = temp-goods.sum-acc
      ub.abc-analysis-goods.abcg-sum-cur           = temp-goods.sum-cur
      ub.abc-analysis-goods.abcg-sum-doc           = temp-goods.sum-doc
      ub.abc-analysis-goods.abcg-sum-for-estimate  = temp-goods.sum-crit
      ub.abc-analysis-goods.abcg-temp-sale-goods   = temp-goods.qnty / v-day
      ub.abc-analysis-goods.abcg-transport-acc     = temp-goods.transport-acc
      ub.abc-analysis-goods.abcg-transport-cur     = temp-goods.transport-cur
      ub.abc-analysis-goods.abcg-transport-doc     = temp-goods.transport-doc
      ub.abc-analysis-goods.abcg-vat-acc           = temp-goods.vat-acc
      ub.abc-analysis-goods.abcg-vat-cur           = temp-goods.vat-cur
      ub.abc-analysis-goods.abcg-vat-doc           = temp-goods.vat-doc
      .
end.
for each ub.abc-analysis-goods  exclusive-lock where
      ub.abc-analysis-goods.abc-id  = p-id and
      ub.abc-analysis-goods.db-num  = p-db-num  break
        by ub.abc-analysis-goods.abcg-abc
        by ub.abc-analysis-goods.abcg-prcnt-for-estimate desc :
 if first-of (ub.abc-analysis-goods.abcg-abc ) then do:
    ii = 0 .
 end.
 ii = ii + 1.
 ub.abc-analysis-goods.proc-from-all =  ub.abc-analysis-goods.abcg-sum-for-estimate  * 100 / v-all-sum .
 ub.abc-analysis-goods.rating = ii .
end.
find current x-analysis  no-error .
assign
x-analysis.abc-a-prc-qnty   = v-a-qnty * 100 / v-all-qnty
x-analysis.abc-a-qnty       = v-a-qnty
x-analysis.abc-a-sum-prc    = v-a-sum * 100 / v-all-sum
x-analysis.abc-a-sum        = v-a-sum
x-analysis.abc-b-prc-qnty   = v-b-qnty * 100 / v-all-qnty
x-analysis.abc-b-qnty       = v-b-qnty
x-analysis.abc-b-sum-prc    = v-b-sum * 100 / v-all-sum
x-analysis.abc-b-sum        = v-b-sum
x-analysis.abc-c-prc-qnty   = v-c-qnty * 100 / v-all-qnty
x-analysis.abc-c-qnty       = v-c-qnty
x-analysis.abc-c-sum-prc    = v-c-sum * 100 / v-all-sum
x-analysis.abc-c-sum        = v-c-sum
x-analysis.abc-d-prc-qnty   = v-d-qnty * 100 / v-all-qnty
x-analysis.abc-d-qnty       = v-d-qnty
x-analysis.abc-d-sum-prc    = v-d-sum * 100 / v-all-sum
x-analysis.abc-d-sum        = v-d-sum
x-analysis.abc-e-prc-qnty   = v-e-qnty * 100 / v-all-qnty
x-analysis.abc-e-qnty       = v-e-qnty
x-analysis.abc-e-sum-prc    = v-e-sum * 100 / v-all-sum
x-analysis.abc-e-sum        = v-e-sum
x-analysis.abc-f-prc-qnty   = v-f-qnty * 100 / v-all-qnty
x-analysis.abc-f-qnty       = v-f-qnty
x-analysis.abc-f-sum-prc    = v-f-sum * 100 / v-all-sum
x-analysis.abc-f-sum        = v-f-sum
.
define variable v-doc-rec as recid no-undo .
define buffer buf_abc-analysis for ub.abc-analysis.
find first buf_abc-analysis no-lock where
            buf_abc-analysis.abc-id                 = p-id and
            buf_abc-analysis.db-num                 = p-db-num no-error .
 v-doc-rec = recid(buf_abc-analysis) .
 run ref/abcanal1.p
              (  input-output v-doc-rec
                ,'ИЗМЕНЕНИЕ':U
                ,table x-analysis
                ,table x-analysis-doc
                ,table x-analysis-obj
                ,table x-analysis-period
                ) no-error .
if error-status :error then message
return-value
error-status :get-message(1)
222
.
run waitfram-hide in this-procedure .
  end.
end procedure.
procedure def-order :
  do
  on error undo, return error return-value
  :
define input  parameter p-obj-type  as character no-undo .
define input  parameter p-obj-code  as integer   no-undo .
define input  parameter p-artic     as char   no-undo .
define input  parameter p-prod-type as character no-undo .
define input  parameter p-prod-code as integer   no-undo .
define output parameter v-qnty       as decimal   no-undo .
define buffer buf-ord-line for ub.ord-line.
define buffer buf-ord-doc  for ub.ord-doc.
      for each buf-ord-line no-lock where
              buf-ord-line.artic    =   p-artic              and
              buf-ord-line.prod-type          =   p-prod-type and
              buf-ord-line.prod-code          =   p-prod-code  ,
          first buf-ord-doc no-lock where
                buf-ord-doc.doc-code          =   buf-ord-line.doc-code and
                buf-ord-doc.obj-type          =   p-obj-type and
                buf-ord-doc.obj-code          =   p-obj-code and
                buf-ord-doc.status_           <>   'факт':U    and
                buf-ord-doc.status_           <>   'новый':U  and
                buf-ord-doc.doc-date         <=  v-date-2   and
                buf-ord-doc.doc-date         >=  v-date-1
                :
          for each x-analysis-period :
            if buf-ord-doc.doc-date >= x-analysis-period.abcp-start and
               buf-ord-doc.doc-date <= x-analysis-period.abcp-end
                then do:
                  v-qnty =  v-qnty + buf-ord-line.qnty .
                end.
          end.
      end.
  end.
end procedure.
procedure save-table-duble :
define buffer buf_goods for ub.goods  .
  do
  on error undo, return error return-value
  :
run waitfram-show in this-procedure ( "Сохранение результатов анализа по объектам в БД...").
for each temp-oborot1 ,
    first temp-goods1 where
          temp-goods1.gds-code = temp-oborot1.gds-code
        :
        create ub.abc-analysis-gds-obj.
        assign
          ub.abc-analysis-gds-obj.abc-id              = p-id
          ub.abc-analysis-gds-obj.db-num              = p-db-num
          ub.abc-analysis-gds-obj.gds-code            = temp-oborot1.gds-code
          ub.abc-analysis-gds-obj.obj-code            = temp-oborot1.obj-code
          ub.abc-analysis-gds-obj.obj-type            = temp-oborot1.obj-type
          ub.abc-analysis-gds-obj.abog-other-acc      =temp-oborot1.other-acc
          ub.abc-analysis-gds-obj.abog-other-cur      =temp-oborot1.other-cur
          ub.abc-analysis-gds-obj.abog-other-doc      =temp-oborot1.other-doc
          ub.abc-analysis-gds-obj.abog-qnty           =temp-oborot1.qnty
          ub.abc-analysis-gds-obj.abog-price-crc      =temp-oborot1.price-crc
          ub.abc-analysis-gds-obj.abog-reserve-day    =temp-oborot1.reserve-day
          ub.abc-analysis-gds-obj.abog-road-tax-acc   =temp-oborot1.road-tax-acc
          ub.abc-analysis-gds-obj.abog-road-tax-cur   =temp-oborot1.road-tax-cur
          ub.abc-analysis-gds-obj.abog-road-tax-doc   =temp-oborot1.road-tax-doc
          ub.abc-analysis-gds-obj.abog-slt-acc        =temp-oborot1.slt-acc
          ub.abc-analysis-gds-obj.abog-slt-cur        =temp-oborot1.slt-cur
          ub.abc-analysis-gds-obj.abog-slt-doc        =temp-oborot1.slt-doc
          ub.abc-analysis-gds-obj.abog-stock-qnty     =temp-oborot1.stock-qnty
          ub.abc-analysis-gds-obj.abog-sum-acc        =temp-oborot1.sum-acc
          ub.abc-analysis-gds-obj.abog-sum-cur        =temp-oborot1.sum-cur
          ub.abc-analysis-gds-obj.abog-sum-doc        =temp-oborot1.sum-doc
          ub.abc-analysis-gds-obj.abog-transport-acc  =temp-oborot1.transport-acc
          ub.abc-analysis-gds-obj.abog-transport-cur   =temp-oborot1.transport-cur
          ub.abc-analysis-gds-obj.abog-transport-doc   =temp-oborot1.transport-doc
          ub.abc-analysis-gds-obj.abog-vat-acc     =temp-oborot1.vat-acc
          ub.abc-analysis-gds-obj.abog-vat-cur     =temp-oborot1.vat-cur
          ub.abc-analysis-gds-obj.abog-vat-doc     =temp-oborot1.vat-doc
          ub.abc-analysis-gds-obj.abog-temp-sale-goods   = temp-oborot1.qnty / v-day
        .
end.
for each temp-oborot2 ,
    first temp-goods2 where
          temp-goods2.gds-code = temp-oborot2.gds-code
        :
        create ub.abc-analysis-gds-obj.
        assign
          ub.abc-analysis-gds-obj.abc-id = p-id
          ub.abc-analysis-gds-obj.db-num = p-db-num
          ub.abc-analysis-gds-obj.gds-code     = temp-oborot2.gds-code
          ub.abc-analysis-gds-obj.obj-code     = temp-oborot2.obj-code
          ub.abc-analysis-gds-obj.obj-type     = temp-oborot2.obj-type
          ub.abc-analysis-gds-obj.abog-other-acc      =temp-oborot2.other-acc
          ub.abc-analysis-gds-obj.abog-other-cur      =temp-oborot2.other-cur
          ub.abc-analysis-gds-obj.abog-other-doc      =temp-oborot2.other-doc
          ub.abc-analysis-gds-obj.abog-qnty           =temp-oborot2.qnty
          ub.abc-analysis-gds-obj.abog-price-crc      =temp-oborot2.price-crc
          ub.abc-analysis-gds-obj.abog-reserve-day    =temp-oborot2.reserve-day
          ub.abc-analysis-gds-obj.abog-road-tax-acc   =temp-oborot2.road-tax-acc
          ub.abc-analysis-gds-obj.abog-road-tax-cur   =temp-oborot2.road-tax-cur
          ub.abc-analysis-gds-obj.abog-road-tax-doc   =temp-oborot2.road-tax-doc
          ub.abc-analysis-gds-obj.abog-slt-acc        =temp-oborot2.slt-acc
          ub.abc-analysis-gds-obj.abog-slt-cur        =temp-oborot2.slt-cur
          ub.abc-analysis-gds-obj.abog-slt-doc        =temp-oborot2.slt-doc
          ub.abc-analysis-gds-obj.abog-stock-qnty     =temp-oborot2.stock-qnty
          ub.abc-analysis-gds-obj.abog-sum-acc        =temp-oborot2.sum-acc
          ub.abc-analysis-gds-obj.abog-sum-cur        =temp-oborot2.sum-cur
          ub.abc-analysis-gds-obj.abog-sum-doc        =temp-oborot2.sum-doc
          ub.abc-analysis-gds-obj.abog-transport-acc  =temp-oborot2.transport-acc
          ub.abc-analysis-gds-obj.abog-transport-cur   =temp-oborot2.transport-cur
          ub.abc-analysis-gds-obj.abog-transport-doc   =temp-oborot2.transport-doc
          ub.abc-analysis-gds-obj.abog-vat-acc     =temp-oborot2.vat-acc
          ub.abc-analysis-gds-obj.abog-vat-cur     =temp-oborot2.vat-cur
          ub.abc-analysis-gds-obj.abog-vat-doc     =temp-oborot2.vat-doc
          ub.abc-analysis-gds-obj.abog-temp-sale-goods   = temp-oborot2.qnty / v-day
        .
end.
run waitfram-show in this-procedure  ("Сохранение результатов анализа по товарам в БД...").
define variable v-all-sum as decimal   no-undo .
define variable v-all-qnty as decimal   no-undo .
define variable v-a-sum  as decimal   no-undo .
define variable v-a-qnty as decimal   no-undo .
define variable v-b-sum  as decimal   no-undo .
define variable v-b-qnty as decimal   no-undo .
define variable v-c-sum  as decimal   no-undo .
define variable v-c-qnty as decimal   no-undo .
define variable v-d-sum  as decimal   no-undo .
define variable v-d-qnty as decimal   no-undo .
define variable v-e-sum  as decimal   no-undo .
define variable v-e-qnty as decimal   no-undo .
define variable v-f-sum  as decimal   no-undo .
define variable v-f-qnty as decimal   no-undo .
for each temp-goods1  :
    v-all-sum  = v-all-sum  + temp-goods1.sum-crit .
    v-all-qnty = v-all-qnty + 1.
    case temp-goods1.crit :
       when "A"
       then do:
            v-a-sum  = v-a-sum  + temp-goods1.sum-crit .
            v-a-qnty = v-a-qnty + 1.
       end.
       when "B"
       then do:
            v-b-sum  = v-b-sum  + temp-goods1.sum-crit .
            v-b-qnty = v-b-qnty + 1.
       end.
       when "C"
       then do:
            v-c-sum  = v-c-sum  + temp-goods1.sum-crit .
            v-c-qnty = v-c-qnty + 1.
       end.
       when "D"
       then do:
            v-d-sum  = v-d-sum  + temp-goods1.sum-crit .
            v-d-qnty = v-d-qnty + 1.
       end.
       when "E"
       then do:
            v-e-sum  = v-e-sum  + temp-goods1.sum-crit .
            v-e-qnty = v-e-qnty + 1.
       end.
       when "F"
       then do:
            v-f-sum  = v-f-sum  + temp-goods1.sum-crit .
            v-f-qnty = v-f-qnty + 1.
       end.
    end case.
    find first buf_goods no-lock  where  buf_goods.gds-code = temp-goods1.gds-code no-error .
    create ub.abc-analysis-goods.
    assign
      ub.abc-analysis-goods.abc-id                 = p-id
      ub.abc-analysis-goods.db-num                 = p-db-num
      ub.abc-analysis-goods.gds-code               = temp-goods1.gds-code
      ub.abc-analysis-goods.grp-code               = buf_goods.grp-code
      ub.abc-analysis-goods.prod-type              = buf_goods.prod-type
      ub.abc-analysis-goods.prod-code              = buf_goods.prod-code
      ub.abc-analysis-goods.abcg-abc               = temp-goods1.crit
      ub.abc-analysis-goods.abcg-order-qnty        = temp-goods1.order-qnty
      ub.abc-analysis-goods.abcg-other-acc         = temp-goods1.other-acc
      ub.abc-analysis-goods.abcg-other-cur         = temp-goods1.other-cur
      ub.abc-analysis-goods.abcg-other-doc         = temp-goods1.other-doc
      ub.abc-analysis-goods.abcg-prcnt-for-estimate = temp-goods1.crit-pr
      ub.abc-analysis-goods.abcg-prcnt-account     = temp-goods1.prcnt-account
      ub.abc-analysis-goods.abcg-qnty              = temp-goods1.qnty
      ub.abc-analysis-goods.abcg-road-tax-acc      = temp-goods1.road-tax-acc
      ub.abc-analysis-goods.abcg-road-tax-cur      = temp-goods1.road-tax-cur
      ub.abc-analysis-goods.abcg-road-tax-doc      = temp-goods1.road-tax-doc
      ub.abc-analysis-goods.abcg-slt-acc           = temp-goods1.slt-acc
      ub.abc-analysis-goods.abcg-slt-cur           = temp-goods1.slt-cur
      ub.abc-analysis-goods.abcg-slt-doc           = temp-goods1.slt-doc
      ub.abc-analysis-goods.abcg-stock-qnty        = temp-goods1.stock-qnty
      ub.abc-analysis-goods.abcg-stock-price-acc   = temp-goods1.stock-price-acc
      ub.abc-analysis-goods.abcg-stock-price-sale  = temp-goods1.stock-price-sale
      ub.abc-analysis-goods.abcg-sum-acc           = temp-goods1.sum-acc
      ub.abc-analysis-goods.abcg-sum-cur           = temp-goods1.sum-cur
      ub.abc-analysis-goods.abcg-sum-doc           = temp-goods1.sum-doc
      ub.abc-analysis-goods.abcg-sum-for-estimate  = temp-goods1.sum-crit
      ub.abc-analysis-goods.abcg-temp-sale-goods   = temp-goods1.qnty / v-day
      ub.abc-analysis-goods.abcg-transport-acc     = temp-goods1.transport-acc
      ub.abc-analysis-goods.abcg-transport-cur     = temp-goods1.transport-cur
      ub.abc-analysis-goods.abcg-transport-doc     = temp-goods1.transport-doc
      ub.abc-analysis-goods.abcg-vat-acc           = temp-goods1.vat-acc
      ub.abc-analysis-goods.abcg-vat-cur           = temp-goods1.vat-cur
      ub.abc-analysis-goods.abcg-vat-doc           = temp-goods1.vat-doc
      .
end.
for each temp-goods2  :
    v-all-sum  = v-all-sum  + temp-goods2.sum-crit .
    v-all-qnty = v-all-qnty + 1.
    case temp-goods2.crit :
       when "A"
       then do:
            v-a-sum  = v-a-sum  + temp-goods2.sum-crit .
            v-a-qnty = v-a-qnty + 1.
       end.
       when "B"
       then do:
            v-b-sum  = v-b-sum  + temp-goods2.sum-crit .
            v-b-qnty = v-b-qnty + 1.
       end.
       when "C"
       then do:
            v-c-sum  = v-c-sum  + temp-goods2.sum-crit .
            v-c-qnty = v-c-qnty + 1.
       end.
       when "D"
       then do:
            v-d-sum  = v-d-sum  + temp-goods2.sum-crit .
            v-d-qnty = v-d-qnty + 1.
       end.
       when "E"
       then do:
            v-e-sum  = v-e-sum  + temp-goods2.sum-crit .
            v-e-qnty = v-e-qnty + 1.
       end.
       when "F"
       then do:
            v-f-sum  = v-f-sum  + temp-goods2.sum-crit .
            v-f-qnty = v-f-qnty + 1.
       end.
    end case.
    find first buf_goods no-lock  where  buf_goods.gds-code = temp-goods2.gds-code no-error .
    create ub.abc-analysis-goods.
    assign
      ub.abc-analysis-goods.abc-id                 = p-id
      ub.abc-analysis-goods.db-num                 = p-db-num
      ub.abc-analysis-goods.gds-code               = temp-goods2.gds-code
      ub.abc-analysis-goods.grp-code               = buf_goods.grp-code
      ub.abc-analysis-goods.prod-type              = buf_goods.prod-type
      ub.abc-analysis-goods.prod-code              = buf_goods.prod-code
      ub.abc-analysis-goods.abcg-abc               = temp-goods2.crit
      ub.abc-analysis-goods.abcg-order-qnty        = temp-goods2.order-qnty
      ub.abc-analysis-goods.abcg-other-acc         = temp-goods2.other-acc
      ub.abc-analysis-goods.abcg-other-cur         = temp-goods2.other-cur
      ub.abc-analysis-goods.abcg-other-doc         = temp-goods2.other-doc
      ub.abc-analysis-goods.abcg-prcnt-for-estimate = temp-goods2.crit-pr
      ub.abc-analysis-goods.abcg-prcnt-account     = temp-goods2.prcnt-account
      ub.abc-analysis-goods.abcg-qnty              = temp-goods2.qnty
      ub.abc-analysis-goods.abcg-road-tax-acc      = temp-goods2.road-tax-acc
      ub.abc-analysis-goods.abcg-road-tax-cur      = temp-goods2.road-tax-cur
      ub.abc-analysis-goods.abcg-road-tax-doc      = temp-goods2.road-tax-doc
      ub.abc-analysis-goods.abcg-slt-acc           = temp-goods2.slt-acc
      ub.abc-analysis-goods.abcg-slt-cur           = temp-goods2.slt-cur
      ub.abc-analysis-goods.abcg-slt-doc           = temp-goods2.slt-doc
      ub.abc-analysis-goods.abcg-stock-qnty        = temp-goods2.stock-qnty
      ub.abc-analysis-goods.abcg-stock-price-acc   = temp-goods2.stock-price-acc
      ub.abc-analysis-goods.abcg-stock-price-sale  = temp-goods2.stock-price-sale
      ub.abc-analysis-goods.abcg-sum-acc           = temp-goods2.sum-acc
      ub.abc-analysis-goods.abcg-sum-cur           = temp-goods2.sum-cur
      ub.abc-analysis-goods.abcg-sum-doc           = temp-goods2.sum-doc
      ub.abc-analysis-goods.abcg-sum-for-estimate  = temp-goods2.sum-crit
      ub.abc-analysis-goods.abcg-temp-sale-goods   = temp-goods2.qnty / v-day
      ub.abc-analysis-goods.abcg-transport-acc     = temp-goods2.transport-acc
      ub.abc-analysis-goods.abcg-transport-cur     = temp-goods2.transport-cur
      ub.abc-analysis-goods.abcg-transport-doc     = temp-goods2.transport-doc
      ub.abc-analysis-goods.abcg-vat-acc           = temp-goods2.vat-acc
      ub.abc-analysis-goods.abcg-vat-cur           = temp-goods2.vat-cur
      ub.abc-analysis-goods.abcg-vat-doc           = temp-goods2.vat-doc
      .
end.
find current x-analysis  no-error .
assign
x-analysis.abc-a-prc-qnty   = v-a-qnty * 100 / v-all-qnty
x-analysis.abc-a-qnty       = v-a-qnty
x-analysis.abc-a-sum-prc    = v-a-sum * 100 / v-all-sum
x-analysis.abc-a-sum        = v-a-sum
x-analysis.abc-b-prc-qnty   = v-b-qnty * 100 / v-all-qnty
x-analysis.abc-b-qnty       = v-b-qnty
x-analysis.abc-b-sum-prc    = v-b-sum * 100 / v-all-sum
x-analysis.abc-b-sum        = v-b-sum
x-analysis.abc-c-prc-qnty   = v-c-qnty * 100 / v-all-qnty
x-analysis.abc-c-qnty       = v-c-qnty
x-analysis.abc-c-sum-prc    = v-c-sum * 100 / v-all-sum
x-analysis.abc-c-sum        = v-c-sum
x-analysis.abc-d-prc-qnty   = v-d-qnty * 100 / v-all-qnty
x-analysis.abc-d-qnty       = v-d-qnty
x-analysis.abc-d-sum-prc    = v-d-sum * 100 / v-all-sum
x-analysis.abc-d-sum        = v-d-sum
x-analysis.abc-e-prc-qnty   = v-e-qnty * 100 / v-all-qnty
x-analysis.abc-e-qnty       = v-e-qnty
x-analysis.abc-e-sum-prc    = v-e-sum * 100 / v-all-sum
x-analysis.abc-e-sum        = v-e-sum
x-analysis.abc-f-prc-qnty   = v-f-qnty * 100 / v-all-qnty
x-analysis.abc-f-qnty       = v-f-qnty
x-analysis.abc-f-sum-prc    = v-f-sum * 100 / v-all-sum
x-analysis.abc-f-sum        = v-f-sum
.
define variable ii as integer   no-undo .
for each ub.abc-analysis-goods  exclusive-lock where
      ub.abc-analysis-goods.abc-id  = p-id and
      ub.abc-analysis-goods.db-num  = p-db-num  break
        by ub.abc-analysis-goods.abcg-abc
        by ub.abc-analysis-goods.abcg-prcnt-for-estimate desc :
 if first-of (ub.abc-analysis-goods.abcg-abc ) then do:
    ii = 0 .
 end.
 ii = ii + 1.
 ub.abc-analysis-goods.proc-from-all =  ub.abc-analysis-goods.abcg-sum-for-estimate  * 100 / v-all-sum .
 ub.abc-analysis-goods.rating = ii .
end.
define variable v-doc-rec as recid no-undo .
define buffer buf_abc-analysis for ub.abc-analysis.
find first buf_abc-analysis no-lock where
            buf_abc-analysis.abc-id                 = p-id and
            buf_abc-analysis.db-num                 = p-db-num no-error .
 v-doc-rec = recid(buf_abc-analysis) .
 run ref/abcanal1.p
 (              input-output v-doc-rec
                ,'ИЗМЕНЕНИЕ':U
                ,table x-analysis
                ,table x-analysis-doc
                ,table x-analysis-obj
                ,table x-analysis-period
                ) no-error .
if error-status :error then message
return-value
error-status :get-message(1)
222
.
run waitfram-hide in this-procedure .
  end.
end procedure.
procedure make-other-table :
  do
  on error undo, return error return-value
  :
run waitfram-show in this-procedure ("Разбивка по группам и по производителям...").
define buffer buf_goods for ub.goods  .
define buffer buf_abc-analysis-goods for ub.abc-analysis-goods  .
define variable v-all-sum as decimal   no-undo init 0.
  for each buf_abc-analysis-goods no-lock where
      buf_abc-analysis-goods.abc-id  = p-id and
      buf_abc-analysis-goods.db-num  = p-db-num
      :
      find first buf_goods no-lock WHERE buf_goods.gds-code = buf_abc-analysis-goods.gds-code no-error  .
      if error-status :error then do:
        message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "Не найден товар с кодом " buf_abc-analysis-goods.gds-code
            view-as alert-box error
        .
        next.
      end.
       find first ub.abc-analysis-prod exclusive-lock where
                  ub.abc-analysis-prod.abc-id =  p-id     and
                  ub.abc-analysis-prod.db-num =  p-db-num and
                  ub.abc-analysis-prod.prod-type =  buf_goods.prod-type and
                  ub.abc-analysis-prod.prod-code =  buf_goods.prod-code no-error .
             if not available ub.abc-analysis-prod then do:
                create ub.abc-analysis-prod.
             end.
             assign
                  ub.abc-analysis-prod.abc-id =  p-id
                  ub.abc-analysis-prod.db-num =  p-db-num
                  ub.abc-analysis-prod.prod-type =  buf_goods.prod-type
                  ub.abc-analysis-prod.prod-code =  buf_goods.prod-code
                  ub.abc-analysis-prod.abcg-other-acc            =  ub.abc-analysis-prod.abcg-other-acc           + buf_abc-analysis-goods.abcg-other-acc
                  ub.abc-analysis-prod.abcg-other-cur            =  ub.abc-analysis-prod.abcg-other-cur           + buf_abc-analysis-goods.abcg-other-cur
                  ub.abc-analysis-prod.abcg-other-doc            =  ub.abc-analysis-prod.abcg-other-doc           + buf_abc-analysis-goods.abcg-other-doc
                  ub.abc-analysis-prod.abcg-prcnt-for-estimate   =  ub.abc-analysis-prod.abcg-prcnt-for-estimate  + buf_abc-analysis-goods.abcg-prcnt-for-estimate
                  ub.abc-analysis-prod.abcg-qnty                 =  ub.abc-analysis-prod.abcg-qnty                + buf_abc-analysis-goods.abcg-qnty
                  ub.abc-analysis-prod.abcg-road-tax-acc         =  ub.abc-analysis-prod.abcg-road-tax-acc        + buf_abc-analysis-goods.abcg-road-tax-acc
                  ub.abc-analysis-prod.abcg-road-tax-cur         =  ub.abc-analysis-prod.abcg-road-tax-cur        + buf_abc-analysis-goods.abcg-road-tax-cur
                  ub.abc-analysis-prod.abcg-road-tax-doc         =  ub.abc-analysis-prod.abcg-road-tax-doc        + buf_abc-analysis-goods.abcg-road-tax-doc
                  ub.abc-analysis-prod.abcg-slt-acc              =  ub.abc-analysis-prod.abcg-slt-acc             + buf_abc-analysis-goods.abcg-slt-acc
                  ub.abc-analysis-prod.abcg-slt-cur              =  ub.abc-analysis-prod.abcg-slt-cur             + buf_abc-analysis-goods.abcg-slt-cur
                  ub.abc-analysis-prod.abcg-slt-doc              =  ub.abc-analysis-prod.abcg-slt-doc             + buf_abc-analysis-goods.abcg-slt-doc
                  ub.abc-analysis-prod.abcg-stock-price-acc      =  ub.abc-analysis-prod.abcg-stock-price-acc     + buf_abc-analysis-goods.abcg-stock-price-acc
                  ub.abc-analysis-prod.abcg-stock-price-sale     =  ub.abc-analysis-prod.abcg-stock-price-sale    + buf_abc-analysis-goods.abcg-stock-price-sale
                  ub.abc-analysis-prod.abcg-stock-qnty           =  ub.abc-analysis-prod.abcg-stock-qnty          + buf_abc-analysis-goods.abcg-stock-qnty
                  ub.abc-analysis-prod.abcg-sum-acc              =  ub.abc-analysis-prod.abcg-sum-acc             + buf_abc-analysis-goods.abcg-sum-acc
                  ub.abc-analysis-prod.abcg-sum-cur              =  ub.abc-analysis-prod.abcg-sum-cur             + buf_abc-analysis-goods.abcg-sum-cur
                  ub.abc-analysis-prod.abcg-sum-doc              =  ub.abc-analysis-prod.abcg-sum-doc             + buf_abc-analysis-goods.abcg-sum-doc
                  ub.abc-analysis-prod.abcg-sum-for-estimate     =  ub.abc-analysis-prod.abcg-sum-for-estimate    + buf_abc-analysis-goods.abcg-sum-for-estimate
                  ub.abc-analysis-prod.abcg-transport-acc        =  ub.abc-analysis-prod.abcg-transport-acc       + buf_abc-analysis-goods.abcg-transport-acc
                  ub.abc-analysis-prod.abcg-transport-cur        =  ub.abc-analysis-prod.abcg-transport-cur       + buf_abc-analysis-goods.abcg-transport-cur
                  ub.abc-analysis-prod.abcg-transport-doc        =  ub.abc-analysis-prod.abcg-transport-doc       + buf_abc-analysis-goods.abcg-transport-doc
                  ub.abc-analysis-prod.abcg-vat-acc              =  ub.abc-analysis-prod.abcg-vat-acc             + buf_abc-analysis-goods.abcg-vat-acc
                  ub.abc-analysis-prod.abcg-vat-cur              =  ub.abc-analysis-prod.abcg-vat-cur             + buf_abc-analysis-goods.abcg-vat-cur
                  ub.abc-analysis-prod.abcg-vat-doc              =  ub.abc-analysis-prod.abcg-vat-doc             + buf_abc-analysis-goods.abcg-vat-doc
             .
       find first ub.abc-analysis-grp exclusive-lock where
                  ub.abc-analysis-grp.abc-id =  p-id and
                  ub.abc-analysis-grp.db-num =  p-db-num and
                  ub.abc-analysis-grp.grp-code =  buf_goods.grp-code no-error .
             if not available ub.abc-analysis-grp then do:
                create ub.abc-analysis-grp.
             end.
             assign
                  ub.abc-analysis-grp.abc-id =  p-id
                  ub.abc-analysis-grp.db-num =  p-db-num
                  ub.abc-analysis-grp.grp-code =  buf_goods.grp-code
                  ub.abc-analysis-grp.abcg-other-acc            =  ub.abc-analysis-grp.abcg-other-acc           + buf_abc-analysis-goods.abcg-other-acc
                  ub.abc-analysis-grp.abcg-other-cur            =  ub.abc-analysis-grp.abcg-other-cur           + buf_abc-analysis-goods.abcg-other-cur
                  ub.abc-analysis-grp.abcg-other-doc            =  ub.abc-analysis-grp.abcg-other-doc           + buf_abc-analysis-goods.abcg-other-doc
                  ub.abc-analysis-grp.abcg-prcnt-for-estimate   =  ub.abc-analysis-grp.abcg-prcnt-for-estimate  + buf_abc-analysis-goods.abcg-prcnt-for-estimate
                  ub.abc-analysis-grp.abcg-qnty                 =  ub.abc-analysis-grp.abcg-qnty                + buf_abc-analysis-goods.abcg-qnty
                  ub.abc-analysis-grp.abcg-road-tax-acc         =  ub.abc-analysis-grp.abcg-road-tax-acc        + buf_abc-analysis-goods.abcg-road-tax-acc
                  ub.abc-analysis-grp.abcg-road-tax-cur         =  ub.abc-analysis-grp.abcg-road-tax-cur        + buf_abc-analysis-goods.abcg-road-tax-cur
                  ub.abc-analysis-grp.abcg-road-tax-doc         =  ub.abc-analysis-grp.abcg-road-tax-doc        + buf_abc-analysis-goods.abcg-road-tax-doc
                  ub.abc-analysis-grp.abcg-slt-acc              =  ub.abc-analysis-grp.abcg-slt-acc             + buf_abc-analysis-goods.abcg-slt-acc
                  ub.abc-analysis-grp.abcg-slt-cur              =  ub.abc-analysis-grp.abcg-slt-cur             + buf_abc-analysis-goods.abcg-slt-cur
                  ub.abc-analysis-grp.abcg-slt-doc              =  ub.abc-analysis-grp.abcg-slt-doc             + buf_abc-analysis-goods.abcg-slt-doc
                  ub.abc-analysis-grp.abcg-stock-price-acc      =  ub.abc-analysis-grp.abcg-stock-price-acc     + buf_abc-analysis-goods.abcg-stock-price-acc
                  ub.abc-analysis-grp.abcg-stock-price-sale     =  ub.abc-analysis-grp.abcg-stock-price-sale    + buf_abc-analysis-goods.abcg-stock-price-sale
                  ub.abc-analysis-grp.abcg-stock-qnty           =  ub.abc-analysis-grp.abcg-stock-qnty          + buf_abc-analysis-goods.abcg-stock-qnty
                  ub.abc-analysis-grp.abcg-sum-acc              =  ub.abc-analysis-grp.abcg-sum-acc             + buf_abc-analysis-goods.abcg-sum-acc
                  ub.abc-analysis-grp.abcg-sum-cur              =  ub.abc-analysis-grp.abcg-sum-cur             + buf_abc-analysis-goods.abcg-sum-cur
                  ub.abc-analysis-grp.abcg-sum-doc              =  ub.abc-analysis-grp.abcg-sum-doc             + buf_abc-analysis-goods.abcg-sum-doc
                  ub.abc-analysis-grp.abcg-sum-for-estimate     =  ub.abc-analysis-grp.abcg-sum-for-estimate    + buf_abc-analysis-goods.abcg-sum-for-estimate
                  ub.abc-analysis-grp.abcg-transport-acc        =  ub.abc-analysis-grp.abcg-transport-acc       + buf_abc-analysis-goods.abcg-transport-acc
                  ub.abc-analysis-grp.abcg-transport-cur        =  ub.abc-analysis-grp.abcg-transport-cur       + buf_abc-analysis-goods.abcg-transport-cur
                  ub.abc-analysis-grp.abcg-transport-doc        =  ub.abc-analysis-grp.abcg-transport-doc       + buf_abc-analysis-goods.abcg-transport-doc
                  ub.abc-analysis-grp.abcg-vat-acc              =  ub.abc-analysis-grp.abcg-vat-acc             + buf_abc-analysis-goods.abcg-vat-acc
                  ub.abc-analysis-grp.abcg-vat-cur              =  ub.abc-analysis-grp.abcg-vat-cur             + buf_abc-analysis-goods.abcg-vat-cur
                  ub.abc-analysis-grp.abcg-vat-doc              =  ub.abc-analysis-grp.abcg-vat-doc             + buf_abc-analysis-goods.abcg-vat-doc
                  .
  end.
for each temp-goods :
    v-all-sum  = v-all-sum  + temp-goods.sum-crit .
end.
define variable ii as integer   no-undo .
 for each temp-tt : delete temp-tt . end.
 for each ub.abc-analysis-grp  no-lock where
      ub.abc-analysis-grp.abc-id  = p-id and
      ub.abc-analysis-grp.db-num  = p-db-num :
     create temp-tt.
     assign
       temp-tt.id = recid(ub.abc-analysis-grp)
       temp-tt.summa = ub.abc-analysis-grp.abcg-sum-for-estimate
     .
 end.
 run ref/tt-abc.p
      ( input table x-analysis
      , input-output table temp-tt )
  .
for each temp-tt  break
        by temp-tt.abc
        by temp-tt.proc desc :
      if first-of (temp-tt.abc ) then do:
          ii = 0 .
      end.
      ii = ii + 1.
      find first ub.abc-analysis-grp  exclusive-lock where  recid (ub.abc-analysis-grp) = temp-tt.id no-error .
          if available ub.abc-analysis-grp then do:
              ub.abc-analysis-grp.abcg-abc      =  temp-tt.abc.
              ub.abc-analysis-grp.proc-from-all =  ub.abc-analysis-grp.abcg-sum-for-estimate  * 100 / v-all-sum .
              ub.abc-analysis-grp.rating        = ii .
          end.
end.
 for each temp-tt : delete temp-tt . end.
 for each ub.abc-analysis-prod  no-lock where
      ub.abc-analysis-prod.abc-id  = p-id and
      ub.abc-analysis-prod.db-num  = p-db-num :
     create temp-tt.
     assign
       temp-tt.id = recid(ub.abc-analysis-prod)
       temp-tt.summa = ub.abc-analysis-prod.abcg-sum-for-estimate
     .
 end.
 run ref/tt-abc.p
      ( input table x-analysis
      , input-output table temp-tt )
  .
for each temp-tt  break
        by temp-tt.abc
        by temp-tt.proc desc :
      if first-of (temp-tt.abc ) then do:
          ii = 0 .
      end.
      ii = ii + 1.
      find first ub.abc-analysis-prod  exclusive-lock where  recid (ub.abc-analysis-prod) = temp-tt.id no-error .
          if available ub.abc-analysis-prod then do:
              ub.abc-analysis-prod.abcg-abc      =  temp-tt.abc.
              ub.abc-analysis-prod.proc-from-all =  ub.abc-analysis-prod.abcg-sum-for-estimate  * 100 / v-all-sum .
              ub.abc-analysis-prod.rating        = ii .
          end.
end.
  run waitfram-hide in this-procedure .
  end.
end procedure.
