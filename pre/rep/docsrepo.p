block-level on error undo, throw.
define input  parameter p-title             as character no-undo .
define input  parameter pVal-BruttoSaleSum  as logical   no-undo .
define input  parameter pRubl-BruttoSaleSum as logical   no-undo .
define input  parameter pVal-NettoSaleSum   as logical   no-undo .
define input  parameter pRubl-NettoSaleSum  as logical   no-undo .
define input  parameter pVal-DiscntSum      as logical   no-undo .
define input  parameter pRubl-DiscntSum     as logical   no-undo .
define input  parameter pVal-CostSum        as logical   no-undo .
define input  parameter pRubl-CostSum       as logical   no-undo .
define input  parameter pVal-Effect         as logical   no-undo .
define input  parameter pRubl-Effect        as logical   no-undo .
define input  parameter pDiscnt-PC          as logical   no-undo .
define input  parameter pTorgPred           as logical   no-undo .
define input  parameter pUp-PC              as logical   no-undo .
define input  parameter pOperator           as logical   no-undo .
define input  parameter pPayType            as logical   no-undo .
define input  parameter pKurs               as logical   no-undo .
define input  parameter pOur-Obj            as logical   no-undo .
define input  parameter pKladov             as logical   no-undo .
define input  parameter pIspName            as logical   no-undo .
define input  parameter pPayWaitDate        as logical   no-undo .
define input  parameter pNDS-Val            as logical   no-undo .
define input  parameter pNDS-Rubl           as logical   no-undo .
define input  parameter pNums               as logical   no-undo .
define input  parameter p-continue          as logical   no-undo .
define input  parameter g#report-num        as integer   no-undo .
define output parameter p-frame-width       as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: docsrepo.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/docsrepo.p $":U .
define variable vss-description as character no-undo init " Печать документов из списка документов стара     ".
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
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
DEFINE  shared TEMP-TABLE wt-docs no-undo
  field ext-doc-type as character
  FIELD acc-date    AS DATE      COLUMN-LABEL "Дата проводки"
  FIELD agnt        AS INTEGER   FORMAT "99999" COLUMN-LABEL "Исполнитель"
  FIELD base-rate   AS DECIMAL   FORMAT ">>,>>9.99" COLUMN-LABEL "Курс"
  FIELD base-scale  AS INTEGER   FORMAT ">>9" COLUMN-LABEL "Масштаб"
  FIELD boss        AS INTEGER   FORMAT "99999" COLUMN-LABEL "Менеджер"
  FIELD cli-code    AS INTEGER   FORMAT "99999" COLUMN-LABEL "Код"
  FIELD cli-name    AS CHARACTER FORMAT "X(40)" COLUMN-LABEL "Контрагент"
  FIELD cli-type    AS CHARACTER FORMAT "X(8)" COLUMN-LABEL "Контрагент"
  FIELD creid       AS CHARACTER FORMAT "X(8)" COLUMN-LABEL "Создал"
  FIELD ctr-num     AS CHARACTER FORMAT "X(8)" COLUMN-LABEL "Контрагент! !"
  FIELD discnt-pc   AS DECIMAL   FORMAT "->9.9%" COLUMN-LABEL "Скидка"
  FIELD discnt-rubl AS DECIMAL   FORMAT "->,>>>,>>>,>>>,>>9.99" COLUMN-LABEL "Скидка"
  FIELD discnt-type AS CHARACTER FORMAT "X(8)" COLUMN-LABEL "Скидка"
  FIELD doc-code    AS CHARACTER FORMAT "X(14)" COLUMN-LABEL "Номер"
  FIELD doc-date    AS DATE      COLUMN-LABEL "Дата"
  FIELD doc-qnty    AS DECIMAL   FORMAT "->>,>>>,>>9.<<<" COLUMN-LABEL "Заявлено"
  FIELD doc-type    AS CHARACTER FORMAT "X(8)" COLUMN-LABEL "Тип"
  FIELD exch-code   AS INTEGER   FORMAT ">>9" COLUMN-LABEL "Валюта"
  FIELD exch-date   AS DATE      COLUMN-LABEL "Таможня"
  FIELD exch-rate   AS DECIMAL   FORMAT ">>,>>9.99"
  COLUMN-LABEL "Курс"
  FIELD exch-scale  AS INTEGER   FORMAT ">>9"
  COLUMN-LABEL "Масштаб"
  FIELD fact-base   AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "факт"
  FIELD fact-date   AS DATE
  COLUMN-LABEL "факт"
  FIELD fact-num    AS INTEGER
  FIELD fact-qnty   AS DECIMAL   FORMAT "->>,>>>,>>9.<<<"
  COLUMN-LABEL "Фактически"
  FIELD fact-rubl   AS DECIMAL   FORMAT "->,>>>,>>>,>>>,>>9.99"
  COLUMN-LABEL "По накл."
  FIELD flag_       AS LOGICAL   COLUMN-LABEL "Закр"
  FIELD internal    AS LOGICAL   COLUMN-LABEL "Внутр"
  FIELD inv-num     AS CHARACTER FORMAT "X(8)"
  COLUMN-LABEL "Инвойс"
  FIELD obj-code    AS INTEGER   FORMAT "99999"
  COLUMN-LABEL "Код"
  FIELD obj-type    AS CHARACTER FORMAT "X(8)"
  COLUMN-LABEL "ПО ОБЪЕКТАМ"
  FIELD office      AS LOGICAL
  FIELD ord-num     AS CHAR FORMAT "x(14)"
  COLUMN-LABEL "заказ"
  FIELD out-code    AS CHARACTER FORMAT "X(8)"
  COLUMN-LABEL "Номер РН"
  FIELD ov          AS LOGICAL   FORMAT "+/-"
  COLUMN-LABEL "Акт переоценки"
  FIELD pay-code    AS INTEGER   FORMAT "99999"
  COLUMN-LABEL "Оплата"
  FIELD print-rubl  AS LOGICAL
  COLUMN-LABEL "Рублевая"
  FIELD PS          AS CHARACTER FORMAT "X(50)"
  COLUMN-LABEL "Примечание"
  FIELD ship-date   AS DATE      COLUMN-LABEL "Дата"
  FIELD ship-num    AS CHARACTER FORMAT "X(8)"
  COLUMN-LABEL "Отгрузка"
  FIELD status_     AS CHARACTER FORMAT "X(8)"
  COLUMN-LABEL "статус"
  FIELD tot-calc    AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "Расчет"
  FIELD tot-cli     AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "По ТТН"
  FIELD tot-doc     AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "По накл."
  FIELD tot-fact    AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "факт"
  FIELD tot-ov      AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "По акту"
  FIELD tot-rubl    AS DECIMAL   FORMAT "->,>>>,>>>,>>>,>>9.99"
  COLUMN-LABEL "По накл."
  FIELD tot-sale    AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99"
  COLUMN-LABEL "факт"
  FIELD wrkr        AS INTEGER   FORMAT "99999"
  COLUMN-LABEL "Кладовщик"
  FIELD host-code AS INTEGER   FORMAT "99999" COLUMN-LABEL "Фирма"
    field vat-type      as character
    field vat-base      as decimal
    field vat-rubl      as decimal
    field vat18-base    as decimal
    field vat18-rubl    as decimal
    field vat10-base    as decimal
    field vat10-rubl    as decimal
    field vat-on        as logical
    field doc-attr      as character
    field OurObjectName like ub.clients.obj-name
    field pay-name      like ub.pay-type.obj-name
    field Oper_Name     as character
    field Mngr_Name     as character
    field Wrkr_name     as character
    field Course        as decimal
    field pay-waitdate  as date
    field Isp-Name      as character
    field SLT-base      like ub.trn-doc.SLT-base
    field SLT-rubl      like ub.trn-doc.SLT-rubl
    .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable gdsgrp_recids      as character no-undo.
define new shared variable fin-schet-recid    as character no-undo.
define new shared variable v-d-report-handle  as handle    no-undo .
define new shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table tmp#grp no-undo
    field node-code like ub.gds-grp.node-code
    field grp-name like ub.gds-grp.node-name
    field lvl-num  like ub.gds-grp.lvl-num
    field is-term  like ub.gds-grp.is-term
    index pi is unique primary grp-name node-code
    index i-node-code    node-code
    index level-num   lvl-num  grp-name
    index is-term is-term  grp-name
    .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
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
define  new shared  temp-table gds-list-hist no-undo
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
new shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
define new shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define new shared variable str1   as character  no-undo.
define new shared variable str2   as character  no-undo.
define new shared variable str3   as character  no-undo.
define new shared variable str4   as character  no-undo.
define new shared variable ReportNAme   as character  no-undo.
define new shared variable ReportProc   as character  no-undo.
define new shared variable ReportHeader as character  no-undo.
define new shared variable ReportPageWidth  as integer no-undo.
define new shared variable ReportPageHeight as integer no-undo.
define new shared variable ReportFontNum    as integer no-undo.
define new shared variable my-request as logical  init false no-undo.
define new shared variable v-delim as character no-undo .
define new shared variable v-sdate as character no-undo initial "/":U.
define new shared variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
define new shared variable my-handle  as handle no-undo .
define new shared variable parent-handle  as handle no-undo .
define new shared variable v-show-all-goods as logical  no-undo .
define new shared variable params-only      as logical   no-undo .
define new shared variable params-only-mode as character no-undo .
define new shared variable place-call       as character no-undo .
define new shared variable x-Goods-Editor   as character  no-undo .
define new shared variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-End       as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-Start     as date format "99/99/9999":u   no-undo .
define new shared variable x-Shift-Alone    as integer format ">9":u         no-undo .
define new shared variable x-Shift-End      as integer format ">9":u         no-undo .
define new shared variable x-Shift-Start    as integer format ">9":u         no-undo .
define new shared variable x-SelectGood     as integer                      no-undo .
define new shared variable x-SelectObject   as character                          no-undo .
define new shared variable x-SET_PAY_TYPE   as integer  no-undo .
define new shared variable x-SET_val_TYPE   as integer  no-undo .
define new shared variable x-TOG-Shift      as logical  no-undo .
define new shared variable x-Radio-Task     as integer  no-undo .
define new shared variable x-TOG-Excel      as logical  no-undo .
define new shared variable x-TOG-list-hist  as logical  no-undo .
define new shared variable x-text-1 as character  no-undo .
define new shared variable x-text-2 as character  no-undo .
define new shared variable x-text-3 as character  no-undo .
define new shared variable x-text-4 as character  no-undo .
define new shared variable init-date-start  like x-date-start  no-undo .
define new shared variable init-date-end    like x-date-end    no-undo .
define new shared variable init-date-alone  like x-date-alone  no-undo .
define new shared variable init-shift-alone like x-shift-alone no-undo .
define new shared variable init-shift-start like x-shift-start no-undo .
define new shared variable init-shift-end   like x-shift-end   no-undo .
define new shared variable init-set_pay_type like x-set_pay_type   no-undo .
define new shared variable init-set_val_type like x-set_val_type   no-undo .
define new shared variable ref_date-start    as character   no-undo .
define new shared variable ref_date-end      as character   no-undo .
define new shared variable ref_date-alone    as character   no-undo .
define new shared work-table TDEDT  no-undo
  field id as char
  field name as character  format "x(40)"
  field n as character
  .
define variable tempstr as character  no-undo.
define variable b1-name as character  no-undo.
define variable b2-name as character  no-undo.
define variable source-str   as character no-undo .
define variable I#           as integer    no-undo.
define variable p-price-med  as decimal init 0 no-undo .
define new shared variable str-obj-type as character  no-undo.
define new shared variable str-obj-code as character  no-undo.
define new shared variable str-obj-name as character  no-undo.
define new shared variable str-obj      as character  no-undo.
define new shared variable link#        as logical  no-undo init false.
define new shared variable  Verify-Arc-ot      as logical  no-undo init false.
define new shared variable  Verify-Arc-stk     as logical  no-undo init false.
define new shared variable  Verify-Arc-supp    as logical  no-undo init false.
define new shared variable  Verify-Arc-hold    as logical  no-undo init false.
define new shared variable  Verify-Arc-aht     as logical  no-undo init false.
define new shared variable  Verify-send-check  as logical  no-undo init false.
define new shared variable  Verify-Arc-fin     as logical  no-undo init false.
define new shared variable  Verify-Arc-strong  as logical  no-undo init false.
define new shared variable  Show-Crsa         as logical  no-undo init false.
define new shared variable  Show-Cost         as logical  no-undo init false.
define new shared variable  Show-Sale         as logical  no-undo init false.
define new shared variable  Name-Sale-price   as character no-undo .
define new shared variable  Format-Folder     as logical no-undo .
define new shared variable  Print-List-Hist   as logical no-undo init false.
define new shared variable Make-Excel     as logical  no-undo init false.
define new shared variable Make-Excel-com as logical  no-undo init false.
define new shared stream ForExcel.
define new shared variable Use-column   as logical extent 256 no-undo .
define new shared variable right-column as logical extent 256 no-undo .
define new shared temp-table Sheetf no-undo
field Excel-Column-Lable as character
field Excel-Row-Heder    as integer
field Excel-Row-Title    as integer
field Sizes              as character
field Make-correct       as character
field Rights-column      as character
field MergeCellsH        as character
field MergeCellsV        as character
field sheet-num          as integer
field ColFormat          as character
field Bas-FIle           as character
field Bas-Params         as character
field Bas-Param-Add      as logical
field File-name          as character
field Silent-save        as logical
index pi as primary unique
      sheet-num
.
  create Sheetf.
  assign
  sheetf.sheet-num = 1.
define variable l-stroka as character no-undo .
define new shared  variable ch#ExcelApplication as com-handle no-undo .
define new shared  variable ch#Workbook         as com-handle no-undo .
define new shared  variable ch#Worksheet        as com-handle no-undo .
define new shared  variable Num#Str#            as integer no-undo.
define new shared  variable Number-List         as integer no-undo init 1.
define new shared  variable v-excel-file        as character no-undo .
define variable Col-name as character  extent 256.
define variable Col-format as character  extent 256.
define variable Col-Post-format as character  extent 256.
run proc-page0-assign in this-procedure .
define variable v-del-1 as character no-undo .
if  v-delim = " " or v-delim = ? or v-delim = ""  then do:
    run gbl/getlocal.p ( output v-delim  , output v-del-1, output v-sdate, output v-shortdate ) no-error .
    if error-status :error then do:
      message error-status :error error-status :get-message(1)
              v-delim v-del-1.
        v-delim = ','  .
    end.
end.
procedure proc-page0-assign :
 do
 on error undo, return error return-value
 :
Assign
  Col-name[1] = 'A':U
  Col-name[2] = 'B':U
  Col-name[3] = 'C':U
  Col-name[4] = 'D':U
  Col-name[5] = 'E':U
  Col-name[6] = 'F':U
  Col-name[7] = 'G':U
  Col-name[8] = 'H':U
  Col-name[9] = 'I':U
  Col-name[10]= 'J':U
  Col-name[11]= 'K':U
  Col-name[12]= 'L':U
  Col-name[13]= 'M':U
  Col-name[14]= 'N':U
  Col-name[15]= 'O':U
  Col-name[16]= 'P':U
  Col-name[17]= 'Q':U
  Col-name[18]= 'R':U
  Col-name[19]= 'S':U
  Col-name[20]= 'T':U
  Col-name[21]= 'U':U
  Col-name[22]= 'V':U
  Col-name[23]= 'W':U
  Col-name[24]= 'X':U
  Col-name[25]= 'Y':U
  Col-name[26]= 'Z':U
  Col-name[27]= 'AA':U
  Col-name[28]= 'AB':U
  Col-name[29]= 'AC':U
  Col-name[30]= 'AD':U
  Col-name[31]= 'AE':U
  Col-name[32]= 'AF':U
  Col-name[33]= 'AG':U
  Col-name[34]= 'AH':U
  Col-name[35]= 'AI':U
  Col-name[36]= 'AJ':U
  Col-name[37]= 'AK':U
  Col-name[38]= 'AL':U
  Col-name[39]= 'AM':U
  Col-name[40]= 'AN':U
  Col-name[41]= 'AO':U
  Col-name[42]= 'AP':U
  Col-name[43]= 'AQ':U
  Col-name[44]= 'AR':U
  Col-name[45]= 'AS':U
  Col-name[46]= 'AT':U
  Col-name[47]= 'AU':U
  Col-name[48]= 'AV':U
  Col-name[49]= 'AW':U
  Col-name[50]= 'AX':U
  Col-name[51]= 'AY':U
  Col-name[52]= 'AZ':U
  Col-name[53]= 'BA':U
  Col-name[54]= 'BB':U
  Col-name[55]= 'BC':U
  Col-name[56]= 'BD':U
  Col-name[57]= 'BE':U
  Col-name[58]= 'BF':U
  Col-name[59]= 'BG':U
  Col-name[60]= 'BH':U
  Col-name[61]= 'BI':U
  Col-name[62]= 'BJ':U
  Col-name[63]= 'BK':U
  Col-name[64]= 'BL':U
  Col-name[65]= 'BM':U
  Col-name[66]= 'BN':U
  Col-name[67]= 'BO':U
  Col-name[68]= 'BP':U
  Col-name[69]= 'BQ':U
  Col-name[70]= 'BR':U
  Col-name[71]= 'BS':U
  Col-name[72]= 'BT':U
  Col-name[73]= 'BU':U
  Col-name[74]= 'BV':U
  Col-name[75]= 'BW':U
  Col-name[76]= 'BX':U
  Col-name[77]= 'BY':U
  Col-name[78]= 'BZ':U
  Col-name[79]= 'CA':U
  Col-name[80]= 'CB':U
  Col-name[81]= 'CC':U
  Col-name[82]= 'CD':U
  Col-name[83]= 'CE':U
  Col-name[84]= 'CF':U
  Col-name[85]= 'CG':U
  Col-name[86]= 'CH':U
  Col-name[87]= 'CI':U
  Col-name[88]= 'CJ':U
  Col-name[89]= 'CK':U
  Col-name[90]= 'CL':U
  Col-name[91]= 'CM':U
  Col-name[92]= 'CN':U
  Col-name[93]= 'CO':U
  Col-name[94]= 'CP':U
  Col-name[95]= 'CQ':U
  Col-name[96]= 'CR':U
  Col-name[97]= 'CS':U
  Col-name[98]= 'CT':U
  Col-name[99]= 'CU':U
  Col-name[100]= 'CV':U
Col-name[101]= 'CW':U
Col-name[102]= 'CX':U
Col-name[103]= 'CY':U
Col-name[104]= 'CZ':U
Col-name[105]= 'DA':U
Col-name[106]= 'DB':U
Col-name[107]= 'DC':U
Col-name[108]= 'DD':U
Col-name[109]= 'DE':U
Col-name[110]= 'DF':U
Col-name[111]= 'DG':U
Col-name[112]= 'DH':U
Col-name[113]= 'DI':U
Col-name[114]= 'DJ':U
Col-name[115]= 'DK':U
Col-name[116]= 'DL':U
Col-name[117]= 'DM':U
Col-name[118]= 'DN':U
Col-name[119]= 'DO':U
Col-name[120]= 'DP':U
Col-name[121]= 'DQ':U
Col-name[122]= 'DR':U
Col-name[123]= 'DS':U
Col-name[124]= 'DT':U
Col-name[125]= 'DU':U
Col-name[126]= 'DV':U
Col-name[127]= 'DW':U
Col-name[128]= 'DX':U
Col-name[129]= 'DY':U
Col-name[130]= 'DZ':U
Col-name[131]= 'EA':U
Col-name[132]= 'EB':U
Col-name[133]= 'EC':U
Col-name[134]= 'ED':U
Col-name[135]= 'EE':U
Col-name[136]= 'EF':U
Col-name[137]= 'EG':U
Col-name[138]= 'EH':U
Col-name[139]= 'EI':U
Col-name[140]= 'EJ':U
Col-name[141]= 'EK':U
Col-name[142]= 'EL':U
Col-name[143]= 'EM':U
Col-name[144]= 'EN':U
Col-name[145]= 'EO':U
Col-name[146]= 'EP':U
Col-name[147]= 'EQ':U
Col-name[148]= 'ER':U
Col-name[149]= 'ES':U
Col-name[150]= 'ET':U
Col-name[151]= 'EU':U
Col-name[152]= 'EV':U
Col-name[153]= 'EW':U
Col-name[154]= 'EX':U
Col-name[155]= 'EY':U
Col-name[156]= 'EZ':U
Col-name[157]= 'FA':U
.
assign
  Col-name[158]= 'FB':U
  Col-name[159]= 'FC':U
  Col-name[160]= 'FD':U
  Col-name[161]= 'FE':U
  Col-name[162]= 'FF':U
  Col-name[163]= 'FG':U
  Col-name[164]= 'FH':U
  Col-name[165]= 'FI':U
  Col-name[166]= 'FJ':U
  Col-name[167]= 'FK':U
  Col-name[168]= 'FL':U
  Col-name[169]= 'FM':U
  Col-name[170]= 'FN':U
  Col-name[171]= 'FO':U
  Col-name[172]= 'FP':U
  Col-name[173]= 'FQ':U
  Col-name[174]= 'FR':U
  Col-name[175]= 'FS':U
  Col-name[176]= 'FT':U
  Col-name[177]= 'FU':U
  Col-name[178]= 'FV':U
  Col-name[179]= 'FW':U
  Col-name[180]= 'FX':U
  Col-name[181]= 'FY':U
  Col-name[182]= 'FZ':U
  Col-name[183]= 'GA':U
  Col-name[184]= 'GB':U
  Col-name[185]= 'GC':U
  Col-name[186]= 'GD':U
  Col-name[187]= 'GE':U
  Col-name[188]= 'GF':U
  Col-name[189]= 'GG':U
  Col-name[190]= 'GH':U
  Col-name[191]= 'GI':U
  Col-name[192]= 'GJ':U
  Col-name[193]= 'GK':U
  Col-name[194]= 'GL':U
  Col-name[195]= 'GM':U
  Col-name[196]= 'GN':U
  Col-name[197]= 'GO':U
  Col-name[198]= 'GP':U
  Col-name[199]= 'GQ':U
  Col-name[200]=   'GR':U
  Col-name[201]=   'GS':U
  Col-name[202]=   'GT':U
  Col-name[203]=   'GU':U
  Col-name[204]=   'GV':U
  Col-name[205]=   'GW':U
  Col-name[206]=   'GX':U
  Col-name[207]=   'GY':U
  Col-name[208]=   'GZ':U
  Col-name[209]=   'HA':U
  Col-name[210]=   'HB':U
  Col-name[211]=   'HC':U
  Col-name[212]=   'HD':U
  Col-name[213]=   'HE':U
  Col-name[214]=   'HF':U
  Col-name[215]=   'HG':U
  Col-name[216]=   'HH':U
  Col-name[217]=   'HI':U
  Col-name[218]=   'HJ':U
  Col-name[219]=   'HK':U
  Col-name[220]=   'HL':U
  Col-name[221]=   'HM':U
  Col-name[222]=   'HN':U
  Col-name[223]=   'HO':U
  Col-name[224]=   'HP':U
  Col-name[225]=   'HQ':U
  Col-name[226]=   'HR':U
  Col-name[227]=   'HS':U
  Col-name[228]=   'HT':U
  Col-name[229]=   'HU':U
  Col-name[230]=   'HV':U
  Col-name[231]=   'HW':U
  Col-name[232]=   'HX':U
  Col-name[233]=   'HY':U
  Col-name[234]=   'HZ':U
  Col-name[235]=   'IA':U
  Col-name[236]=   'IB':U
  Col-name[237]=   'IC':U
  Col-name[238]=   'ID':U
  Col-name[239]=   'IE':U
  Col-name[240]=   'IF':U
  Col-name[241]=   'IG':U
  Col-name[242]=   'IH':U
  Col-name[243]=   'II':U
  Col-name[244]=   'IJ':U
  Col-name[245]=   'IK':U
  Col-name[246]=   'IL':U
  Col-name[247]=   'IM':U
  Col-name[248]=   'IN':U
  Col-name[249]=   'IO':U
  Col-name[250]=   'IP':U
  Col-name[251]=   'IQ':U
  Col-name[252]=   'IR':U
  Col-name[253]=   'IS':U
  Col-name[254]=   'IT':U
  Col-name[255]=   'IU':U
  Col-name[256]=   'IV':U
  .
 end.
end procedure.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable var-report-r-b as character no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable l-col-type         as character no-undo .
define variable l-col-pos          as integer no-undo .
define variable l-col-len          as integer no-undo .
define variable l-col-format       as character no-undo .
define variable l-col-lable        as character no-undo .
define variable v-dec-sep          as character no-undo init ? .
define variable v-th-sep           as character no-undo init ? .
define variable v-r-col-num        as integer no-undo .
define variable v-reg-replace      as logical no-undo .
define variable v-date-col-format  as character no-undo .
DEFINE VARIABLE last-col-num as integer no-undo.
run gbl/getlocal.p (
                  output v-dec-sep
                 ,output v-th-sep
                 ,output v-sdate
                 ,output v-shortdate
                 ) no-error .
assign
v-reg-replace = NOT (v-dec-sep = ".":U and v-th-sep = chr(44))
                AND (v-dec-sep <> ? and v-th-sep <> ?)
.
  FUNCTION supress-null RETURNS CHARACTER ( INPUT p-string  AS CHARACTER,
                                            INPUT p-dec-sep AS CHARACTER  ) :
    DEFINE VARIABLE v-string AS CHARACTER NO-UNDO.
    IF TRIM( p-string ) = "0"                    OR
       TRIM( p-string ) = "0" + p-dec-sep + "00" OR
       TRIM( p-string ) =       p-dec-sep + "00" OR
       TRIM( p-string ) =       p-dec-sep + "0"  OR
       TRIM( p-string ) = "0" + p-dec-sep + "0"  THEN DO: ASSIGN v-string = "":U.     END.
                                                 ELSE DO: ASSIGN v-string = p-string. END.
    RETURN ( TRIM( v-string ) ).
  END FUNCTION.
FUNCTION reg-output returns character( input p-string as character
                                      ,input p-private-data as character
                                      ,input p-replace as logical
                                      ,input p-supress as logical
                                      ,input p-dec-sep as character
                                      ,input p-th-sep as character
                                      ):
DEFINE VARIABLE v-reg-output as character no-undo .
DEFINE VARIABLE v-data-type as character no-undo .
DEFINE VARIABLE v-progress-format as character no-undo .
assign
v-progress-format = entry(1, p-private-data, chr(4))
v-data-type = entry(2, p-private-data, chr(4))
.
if p-string = ? then return chr(63).
if (v-data-type = "INTEGER"
    OR v-data-type = "DECIMAL" ) THEN DO:
  IF p-replace THEN DO:
    assign
      v-reg-output = replace( p-string
                                      ,chr(44)
                                      ,"":U
                                    )
      v-reg-output = trim(v-reg-output)
    .
  END.
  else do:
    v-reg-output = p-string.
  end.
  IF p-supress THEN DO: ASSIGN v-reg-output = supress-null( TRIM( v-reg-output ), p-dec-sep ). END.
  return v-reg-output.
end.
  return p-string.
END FUNCTION.
procedure OpenForExcel :
   define variable v-ch#ExcelApplication as com-handle no-undo .
   define variable v-ch#Workbook         as com-handle no-undo .
   define variable v-ch#Worksheet        as com-handle no-undo .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( g#report-num ) + ".txt":U ) .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( g#report-num ) + ".frm":U ) .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( g#report-num ) + ".txl":U ) .
   if Make-Excel
   then do:
      output stream ForExcel to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) + ".txt":U ) ) .
      assign
         v-excel-file = string( session:temp-directory + "rpt" + string( g#report-num ) )
         number-list = 1
      .
      if make-excel-com
      then do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#WorkSheet) then
RELEASE OBJECT ch#WorkSheet no-error.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Workbook) then
RELEASE OBJECT ch#Workbook no-error.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#ExcelApplication) then
RELEASE OBJECT ch#ExcelApplication no-error.
         create "Excel.Application" ch#excelApplication connect no-error.
         if error-status:error
         then do :
        create "Excel.Application" ch#excelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
         end.
         assign
            num#str#  = 0.
            v-ch#excelApplication  = ch#excelApplication.
            v-ch#excelApplication:Interactive = false.
            v-ch#excelApplication:ScreenUpdating = false.
            v-ch#excelApplication:Visible = false.
            ch#Workbook  = v-ch#excelApplication:Workbooks:add ().
            ch#WorkSheet = v-ch#excelApplication:Sheets:Item (1).
            v-ch#Worksheet = ch#WorkSheet.
            v-ch#Worksheet:Range ("A1"):Font:Bold = true.
            v-ch#Worksheet:Range ("A1"):Font:Size = 14.
            v-ch#Worksheet:Range ("A1"):HorizontalAlignment = -4131.
            v-ch#Worksheet:Range ("A1"):VerticalAlignment   = -4160
         no-error .
         if error-status:error
         then do:
            Make-Excel-com = false .
            Make-Excel = false .
            output Stream  ForExcel close.
            os-delete value( string( session:temp-directory ) +
                           "rpt" + string( g#report-num ) + ".txt":U ) .
            os-delete value( string( session:temp-directory ) +
                           "rpt" + string( g#report-num ) + ".frm":U ) .
            return.
         end.
      end.
   end.
end.
procedure CloseForExcel :
   define variable ii as integer no-undo .
   define variable vsheet-num as integer no-undo.
   if Make-Excel
   then  do:
      output Stream  ForExcel close.
      os-delete value( string( session:temp-directory ) +
                             "rpt" + string( g#report-num ) + ".txt":U ) .
      os-delete value( string( session:temp-directory ) +
                             "rpt" + string( g#report-num ) + ".frm":U ) .
      define buffer buf_sheetf for sheetf.
      find last buf_sheetf no-error .
      if available buf_sheetf
      then
         vsheet-num = buf_sheetf.sheet-num.
      if vsheet-num > 1
      then do:
         do ii = 2 to vsheet-num:
            os-delete value( string( session:temp-directory ) +
                                  "rpt" + string( g#report-num ) + ".":U  + string(ii)) .
         end.
      end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#WorkSheet) then
RELEASE OBJECT ch#WorkSheet no-error.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Workbook) then
RELEASE OBJECT ch#Workbook no-error.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#ExcelApplication) then
RELEASE OBJECT ch#ExcelApplication no-error.
   end.
end.
DEFINE stream DocsStream .
define buffer  b-wt-docs           for     wt-docs .
define variable DifferentTypes      as logical   no-undo .
define variable Line                as character no-undo .
define variable By-Opt              as character no-undo .
define variable sym1                as character no-undo init ":" .
define variable sym10               as character no-undo init ":" .
define variable i                   as integer   no-undo .
define variable Qnty                as decimal   no-undo .
define variable Val-BruttoSaleSum   as decimal   no-undo .
define variable Rubl-BruttoSaleSum  as decimal   no-undo .
define variable Val-NettoSaleSum    as decimal   no-undo .
define variable Rubl-NettoSaleSum   as decimal   no-undo .
define variable Val-DiscntSum       as decimal   no-undo .
define variable Rubl-DiscntSum      as decimal   no-undo .
define variable Val-CostSum         as decimal   no-undo .
define variable Rubl-CostSum        as decimal   no-undo .
define variable Val-Effect          as decimal   no-undo .
define variable Rubl-Effect         as decimal   no-undo .
define variable Discnt-PC           as character no-undo .
define variable TorgPred            as character no-undo .
define variable Up-PC               as character no-undo .
define variable Operator            as character no-undo .
define variable PayType             as character no-undo .
define variable Kurs                as decimal   no-undo .
define variable Our-Obj             as character no-undo .
define variable KladovName          as character no-undo .
define variable IspName             as character no-undo .
define variable PayWaitDate         as date      no-undo .
define variable NDS-Val             as decimal   no-undo .
define variable NDS-Rubl            as decimal   no-undo .
define variable v-ind               as integer   no-undo .
DEFINE VARIABLE for-doc-attr like   wt-docs.doc-attr no-undo .
DEFINE VARIABLE for-doc-date like   wt-docs.doc-date no-undo .
DEFINE VARIABLE for-fact-date like  wt-docs.fact-date no-undo .
DEFINE VARIABLE for-doc-code like   wt-docs.doc-code no-undo .
DEFINE VARIABLE for-cli-name like   wt-docs.cli-name no-undo .
DEFINE VARIABLE fill8               as character no-undo .
DEFINE VARIABLE fill11              as character no-undo .
DEFINE VARIABLE fill12              as character no-undo .
DEFINE VARIABLE fill15              as character no-undo .
DEFINE VARIABLE fill18              as character no-undo .
DEFINE VARIABLE fill19              as character no-undo .
DEFINE VARIABLE fill21              as character no-undo .
DEFINE VARIABLE t-1 AS CHARACTER INITIAL "||||"
     VIEW-AS EDITOR
     SIZE 1 BY 5 NO-UNDO.
DEFINE FRAME top-frame
t-1       AT ROW 1 COL 1 no-label
HEADER
cur-time-print() AT 5 format "x(35)"
string( "Страница" ) AT 45 PAGE-NUMBER( DOcsStream ) AT 55 FORMAT ">>>,>>9" SKIP
    with width 232 down stream-io use-text NO-BOX.
DEFINE FRAME x1
with width 232 down stream-io use-text NO-BOX.
assign
  use-column[1] =  yes
  use-column[2] =  yes
  use-column[3] =  yes
  use-column[4] =  yes
  use-column[5] =  yes
  use-column[6] =  pNums
  use-column[7] =  pVal-BruttoSaleSum
  use-column[8] =  pRubl-BruttoSaleSum
  use-column[9] =  pVal-NettoSaleSum
  use-column[10] = pRubl-NettoSaleSum
  use-column[11] = pVal-DiscntSum
  use-column[12] = pRubl-DiscntSum
  use-column[13] = pVal-CostSum
  use-column[14] = pRubl-CostSum
  use-column[15] = pVal-Effect
  use-column[16] = pRubl-Effect
  use-column[17] = pNDS-VAL
  use-column[18] = pNDs-RUbl
  use-column[19] = PDiscnt-PC
  use-column[20] = pUP-pc
  use-column[21] = pTOrgPred
  use-column[22] = pOperator
  use-column[23] = PKladov
  use-column[24] = pIspName
  use-column[25] = pPayType
  use-column[26] = pKurs
  use-column[27] = pOur-Obj
  use-column[28] = pPayWaitDate
.
assign
  fill8  = fill("-", 8)
  fill11 = fill("-", 11)
  fill12 = fill("-", 12)
  fill15 = fill("-", 15)
  fill18 = fill("-", 18)
  fill19 = fill("-", 19)
  fill21 = fill("-", 21)
.
FOR EACH sheetf where sheetf.sheet-num > 1:
  delete sheetf.
end.
FIND FIRST sheetf where
           sheetf.sheet-num = 1 No-ERROR.
assign
ReportName = p-title
sheetf.Excel-Column-Lable =  ""
sheetf.sizes = ""
Make-Excel = yes.
.
CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .
l-col-pos = 1.
Assign l-col-type="CHARACTER" l-col-len=4 l-col-format= "x(4)"            l-col-lable="Док. атр.".
  define variable ed1 as handle no-undo.
  define variable l-1 as handle no-undo.
  define variable ll-1 as handle no-undo.
  define variable c-for-doc-attr as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[1] = true then DO:
        CREATE EDITOR LL-1 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed1 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-1 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-for-doc-attr IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[1] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 1
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DATE" l-col-len=10 l-col-format= "99/99/9999"            l-col-lable="Дата создания".
  define variable ed2 as handle no-undo.
  define variable l-2 as handle no-undo.
  define variable ll-2 as handle no-undo.
  define variable c-for-doc-date as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[2] = true then DO:
        CREATE EDITOR LL-2 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed2 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-2 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-for-doc-date IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[2] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 2
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DATE" l-col-len=10 l-col-format= "99/99/9999"            l-col-lable="Дата закрытия".
  define variable ed3 as handle no-undo.
  define variable l-3 as handle no-undo.
  define variable ll-3 as handle no-undo.
  define variable c-for-fact-date as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[3] = true then DO:
        CREATE EDITOR LL-3 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed3 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-3 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-for-fact-date IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[3] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 3
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "x(10)"            l-col-lable="Номер документа".
  define variable ed4 as handle no-undo.
  define variable l-4 as handle no-undo.
  define variable ll-4 as handle no-undo.
  define variable c-for-doc-code as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[4] = true then DO:
        CREATE EDITOR LL-4 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed4 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-4 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-for-doc-code IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[4] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 4
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="CHARACTER" l-col-len=40 l-col-format= "x(40)"            l-col-lable="Контрагент".
  define variable ed5 as handle no-undo.
  define variable l-5 as handle no-undo.
  define variable ll-5 as handle no-undo.
  define variable c-for-cli-name as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[5] = true then DO:
        CREATE EDITOR LL-5 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed5 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-5 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-for-cli-name IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[5] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 5
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=12 l-col-format= "->>>>,>>9.99"            l-col-lable="Количество".
  define variable ed6 as handle no-undo.
  define variable l-6 as handle no-undo.
  define variable ll-6 as handle no-undo.
  define variable c-Qnty as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[6] = true then DO:
        CREATE EDITOR LL-6 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed6 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-6 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Qnty IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[6] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 6
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Сумма док. цен (без скидки) (б.вал.)".
  define variable ed7 as handle no-undo.
  define variable l-7 as handle no-undo.
  define variable ll-7 as handle no-undo.
  define variable c-Val-BruttoSaleSum as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[7] = true then DO:
        CREATE EDITOR LL-7 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed7 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-7 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Val-BruttoSaleSum IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[7] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 7
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=21 l-col-format= "->,>>>,>>>,>>>,>>9.99"   l-col-lable="Сумма док. цен (без скидки) (РУБ)".
  define variable ed8 as handle no-undo.
  define variable l-8 as handle no-undo.
  define variable ll-8 as handle no-undo.
  define variable c-Rubl-BruttoSaleSum as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[8] = true then DO:
        CREATE EDITOR LL-8 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed8 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-8 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Rubl-BruttoSaleSum IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[8] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 8
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Сумма док. цен (со скидкой) (б.вал.)".
  define variable ed9 as handle no-undo.
  define variable l-9 as handle no-undo.
  define variable ll-9 as handle no-undo.
  define variable c-Val-NettoSaleSum as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[9] = true then DO:
        CREATE EDITOR LL-9 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed9 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-9 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Val-NettoSaleSum IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[9] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 9
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=21 l-col-format= "->,>>>,>>>,>>>,>>9.99"   l-col-lable="Сумма док. цен (со скидкой) (РУБ)".
  define variable ed10 as handle no-undo.
  define variable l-10 as handle no-undo.
  define variable ll-10 as handle no-undo.
  define variable c-Rubl-NettoSaleSum as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[10] = true then DO:
        CREATE EDITOR LL-10 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed10 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-10 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Rubl-NettoSaleSum IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[10] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 10
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Сумма скидок (б.вал.)".
  define variable ed11 as handle no-undo.
  define variable l-11 as handle no-undo.
  define variable ll-11 as handle no-undo.
  define variable c-Val-DiscntSum as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[11] = true then DO:
        CREATE EDITOR LL-11 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed11 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-11 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Val-DiscntSum IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[11] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 11
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Сумма скидок (РУБ)".
  define variable ed12 as handle no-undo.
  define variable l-12 as handle no-undo.
  define variable ll-12 as handle no-undo.
  define variable c-Rubl-DiscntSum as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[12] = true then DO:
        CREATE EDITOR LL-12 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed12 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-12 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Rubl-DiscntSum IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[12] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 12
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Сумма учетных цен (б.вал.)".
  define variable ed13 as handle no-undo.
  define variable l-13 as handle no-undo.
  define variable ll-13 as handle no-undo.
  define variable c-Val-CostSum as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[13] = true then DO:
        CREATE EDITOR LL-13 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed13 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-13 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Val-CostSum IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[13] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 13
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=19 l-col-format= "->>>,>>>,>>>,>>9.99"     l-col-lable="Сумма учетных цен (РУБ)".
  define variable ed14 as handle no-undo.
  define variable l-14 as handle no-undo.
  define variable ll-14 as handle no-undo.
  define variable c-Rubl-CostSum as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[14] = true then DO:
        CREATE EDITOR LL-14 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed14 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-14 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Rubl-CostSum IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[14] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 14
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Эффективность (б.вал.)".
  define variable ed15 as handle no-undo.
  define variable l-15 as handle no-undo.
  define variable ll-15 as handle no-undo.
  define variable c-Val-Effect as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[15] = true then DO:
        CREATE EDITOR LL-15 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed15 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-15 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Val-Effect IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[15] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 15
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Эффективность (РУБ)".
  define variable ed16 as handle no-undo.
  define variable l-16 as handle no-undo.
  define variable ll-16 as handle no-undo.
  define variable c-Rubl-Effect as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[16] = true then DO:
        CREATE EDITOR LL-16 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed16 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-16 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Rubl-Effect IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[16] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 16
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="НДС (б.вал.)".
  define variable ed17 as handle no-undo.
  define variable l-17 as handle no-undo.
  define variable ll-17 as handle no-undo.
  define variable c-NDS-val as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[17] = true then DO:
        CREATE EDITOR LL-17 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed17 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-17 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-NDS-val IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[17] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 17
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="НДС (РУБ)".
  define variable ed18 as handle no-undo.
  define variable l-18 as handle no-undo.
  define variable ll-18 as handle no-undo.
  define variable c-NDS-Rubl as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[18] = true then DO:
        CREATE EDITOR LL-18 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed18 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-18 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-NDS-Rubl IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[18] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 18
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="CHARACTER" l-col-len=8 l-col-format= "x(8)"                   l-col-lable="Процент скидки".
  define variable ed19 as handle no-undo.
  define variable l-19 as handle no-undo.
  define variable ll-19 as handle no-undo.
  define variable c-Discnt-Pc as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[19] = true then DO:
        CREATE EDITOR LL-19 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed19 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-19 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Discnt-Pc IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[19] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 19
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="CHARACTER" l-col-len=8 l-col-format= "x(8)"                   l-col-lable="Процент фактич. наценки".
  define variable ed20 as handle no-undo.
  define variable l-20 as handle no-undo.
  define variable ll-20 as handle no-undo.
  define variable c-Up-Pc as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[20] = true then DO:
        CREATE EDITOR LL-20 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed20 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-20 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Up-Pc IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[20] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 20
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="CHARACTER" l-col-len=15 l-col-format= "x(15)"                 l-col-lable="Торговый представитель".
  define variable ed21 as handle no-undo.
  define variable l-21 as handle no-undo.
  define variable ll-21 as handle no-undo.
  define variable c-TorgPred as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[21] = true then DO:
        CREATE EDITOR LL-21 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed21 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-21 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-TorgPred IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[21] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 21
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="CHARACTER" l-col-len=15 l-col-format= "x(15)"                 l-col-lable="Оператор".
  define variable ed22 as handle no-undo.
  define variable l-22 as handle no-undo.
  define variable ll-22 as handle no-undo.
  define variable c-Operator as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[22] = true then DO:
        CREATE EDITOR LL-22 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed22 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-22 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Operator IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[22] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 22
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="CHARACTER" l-col-len=15 l-col-format= "x(15)"                 l-col-lable="Кладовщик".
  define variable ed23 as handle no-undo.
  define variable l-23 as handle no-undo.
  define variable ll-23 as handle no-undo.
  define variable c-KladovName as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[23] = true then DO:
        CREATE EDITOR LL-23 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed23 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-23 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-KladovName IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[23] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 23
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="CHARACTER" l-col-len=15 l-col-format= "x(15)"                 l-col-lable="Исполнитель".
  define variable ed24 as handle no-undo.
  define variable l-24 as handle no-undo.
  define variable ll-24 as handle no-undo.
  define variable c-IspName as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[24] = true then DO:
        CREATE EDITOR LL-24 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed24 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-24 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-IspName IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[24] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 24
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="CHARACTER" l-col-len=15 l-col-format= "x(15)"                 l-col-lable="Вид оплаты".
  define variable ed25 as handle no-undo.
  define variable l-25 as handle no-undo.
  define variable ll-25 as handle no-undo.
  define variable c-PayType as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[25] = true then DO:
        CREATE EDITOR LL-25 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed25 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-25 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-PayType IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[25] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 25
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DECIMAL" l-col-len=11 l-col-format= "->>>,>>9.<<"             l-col-lable="Курс".
  define variable ed26 as handle no-undo.
  define variable l-26 as handle no-undo.
  define variable ll-26 as handle no-undo.
  define variable c-Kurs as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[26] = true then DO:
        CREATE EDITOR LL-26 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed26 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-26 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Kurs IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[26] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 26
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="CHARACTER" l-col-len=18 l-col-format= "x(18)"                 l-col-lable="Свой объект".
  define variable ed27 as handle no-undo.
  define variable l-27 as handle no-undo.
  define variable ll-27 as handle no-undo.
  define variable c-Our-Obj as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[27] = true then DO:
        CREATE EDITOR LL-27 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed27 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-27 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-Our-Obj IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[27] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 27
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
Assign l-col-type="DATE" l-col-len=10 l-col-format= "99/99/9999"                 l-col-lable="Дата ожид-мой оплаты".
  define variable ed28 as handle no-undo.
  define variable l-28 as handle no-undo.
  define variable ll-28 as handle no-undo.
  define variable c-PayWaitDate as widget-handle no-undo.
   if l-col-pos > 320 then l-col-pos = 320 .
  if use-column[28] = true then DO:
        CREATE EDITOR LL-28 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR ed28 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 2
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE EDITOR L-28 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = 4 + 1
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 4
        .
        CREATE FILL-IN C-PayWaitDate IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME x1:HANDLE
            DATA-TYPE = "CHARACTER"
            FORMAT = "X(":U + string(l-col-len) + ")":U
            PRIVATE-DATA =  l-col-format + chr(4) + l-col-type
            ROW = 1
            COLUMN = l-col-pos
        .
     assign
     l-col-pos =  l-col-pos + l-col-len + 1
     v-r-col-num = v-r-col-num + 1
     .
  end.
if use-column[28] then
assign
sheetf.Excel-Column-Lable =  (if sheetf.Excel-Column-Lable = ""
                              then (sheetf.Excel-Column-Lable + l-col-lable )
                              else (sheetf.Excel-Column-Lable + chr(44) + l-col-lable )
                             )
sheetf.sizes =  (if sheetf.sizes = ""
                 then (sheetf.sizes + string(l-col-len))
                 else (sheetf.sizes + chr(44) + string(l-col-len))
                )
last-col-num = 28
entry(1, sheetf.colformat, chr(4)) = entry(1, sheetf.colformat, chr(4)) +
                                           (if l-col-type = "DATE"
                                            then (
                                                  (if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                   then ";":U
                                                   else "":U) +
                                                   string(v-r-col-num) + "=":U + "dd/mm/yyyy":U
                                                  )
                                            else (if l-col-type = "CHARACTER"
                                                  then ((if entry(1, sheetf.colformat, chr(4)) <> "":U
                                                        then ";":U
                                                        else "":U) + (string(v-r-col-num) + "=":U + "@":U))
                                                  else "":U)
                                            )
.
assign
p-frame-width = l-col-pos - 1
Line = fill("-", p-frame-width)
.
if p-frame-width > 137 and p-frame-width <= 232  then do:
output stream DocsStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
end.
else do:
output stream DocsStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size 62 .
end.
if Make-Excel then
run openforexcel in this-procedure .
FORM with FRAME x1 .
FORM HEADER
Line format "X(76)" AT 1 SKIP
"Продолжение на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW stream DocsStream FRAME BottomFrame .
PUT stream DocsStream SPACE(10) p-title format "X(125)" SKIP(2).
display STREAM DOcsStream
with frame top-Frame .
run rep/extitle.p ( 1 ).
FIND FIRST wt-docs NO-LOCK .
if can-find( first b-wt-docs where b-wt-docs.doc-type <> wt-docs.doc-type ) then do:
  assign
    DifferentTypes = TRUE
  .
end.
run waitfram-show in this-procedure ( "Печать списка документов " ) .
assign
  v-ind = 0
.
FOR EACH wt-docs with frame x1
:
  assign
    v-ind = v-ind + 1
  .
  if v-ind modulo 10 = 0
  then do:
    run waitfram-show ( "Печать списка документов " + string( v-ind ) ) .
  end.
  if wt-docs.status_ <> 'факт':U then do:
    for each doc-line no-lock
      where doc-line.doc-code = wt-docs.doc-code
    :
        accumulate
          doc-line.doc-qnty * doc-line.price-base ( total )
          doc-line.doc-qnty * doc-line.price-rubl ( total )
        .
    end.
  end.
  assign
                Qnty = ( if can-do( 'факт':U, wt-docs.status_ )
                             then wt-docs.fact-qnty else wt-docs.doc-qnty )
                Val-BruttoSaleSum =
                    ( if can-do( 'инв':U, wt-docs.doc-type )
                      then ( if can-do( 'факт':U, wt-docs.status_ )
                                then wt-docs.tot-doc
                                else 0 )
                      else ( if can-do( 'при':U, wt-docs.doc-type ) AND ( NOT wt-docs.internal )
                                then ( if can-do( 'факт':U, wt-docs.status_ )
                                          then wt-docs.fact-base
                                          else ( ACCUM TOTAL doc-line.doc-qnty * doc-line.price-base ) )
                                else ( if can-do( 'факт':U, wt-docs.status_ )
                                          then ( wt-docs.tot-fact  )
                                          else wt-docs.tot-doc ) ) )
                Rubl-BruttoSaleSum =
                    ( if can-do( 'инв':U, wt-docs.doc-type )
                      then 0
                      else ( if can-do( 'при':U, wt-docs.doc-type ) AND ( NOT wt-docs.internal )
                                then ( if can-do( 'факт':U, wt-docs.status_ )
                                          then wt-docs.fact-rubl
                                          else ( ACCUM TOTAL doc-line.doc-qnty * doc-line.price-rubl ) )
                                else ( if can-do( 'факт':U, wt-docs.status_ )
                                          then wt-docs.tot-sale
                                          else wt-docs.tot-rubl ) ) )
                Val-NettoSaleSum =
                    ( if can-do( 'инв':U, wt-docs.doc-type )
                      then ( if can-do( 'факт':U, wt-docs.status_ )
                                then wt-docs.tot-doc
                                else 0 )
                      else ( if can-do( 'при':U, wt-docs.doc-type ) AND ( NOT wt-docs.internal )
                                then ( if can-do( 'факт':U, wt-docs.status_ )
                                          then wt-docs.fact-base
                                          else ( ACCUM TOTAL doc-line.doc-qnty * doc-line.price-base ) )
                                else ( wt-docs.tot-fact - wt-docs.tot-calc ) ) )
                Rubl-NettoSaleSum =
                    ( if can-do( 'инв':U, wt-docs.doc-type )
                      then ( if can-do( 'факт':U, wt-docs.status_ )
                                then wt-docs.tot-rubl
                                else 0 )
                      else ( if can-do( 'при':U, wt-docs.doc-type ) AND ( NOT wt-docs.internal )
                                then ( if can-do( 'факт':U, wt-docs.status_ )
                                          then wt-docs.fact-rubl
                                          else ( ACCUM TOTAL doc-line.doc-qnty * doc-line.price-rubl ) )
                                else ( wt-docs.tot-sale - wt-docs.discnt-rubl ) ) )
                Val-DiscntSum = ( if can-do( 'инв':U, wt-docs.doc-type ) OR
                                                ( can-do( 'при':U, wt-docs.doc-type ) AND ( NOT wt-docs.internal ) )
                                             then 0    else wt-docs.tot-calc )
                Rubl-DiscntSum = ( if can-do( 'инв':U, wt-docs.doc-type ) OR
                                                ( can-do( 'при':U, wt-docs.doc-type ) AND ( NOT wt-docs.internal ) )
                                                then 0     else wt-docs.discnt-rubl )
                Val-CostSum = ( if can-do( 'инв':U, wt-docs.doc-type )
                                          then ( if can-do( 'факт':U, wt-docs.status_ )
                                                    then wt-docs.fact-base     else 0 )
                                          else ( if can-do( 'факт':U, wt-docs.status_ )
                                                    then wt-docs.fact-base
                                                    else ( ACCUM TOTAL doc-line.doc-qnty * doc-line.price-base ) ) )
                Rubl-CostSum =
                    ( if can-do( 'инв':U, wt-docs.doc-type )
                      then ( if can-do( 'факт':U, wt-docs.status_ )
                                then wt-docs.fact-rubl
                                else 0 )
                      else ( if can-do( 'факт':U, wt-docs.status_ )
                                then wt-docs.fact-rubl
                                else ( ACCUM TOTAL doc-line.doc-qnty * doc-line.price-rubl ) ) )
                NDS-Val = wt-docs.VAT-base
                NDS-Rubl = wt-docs.VAT-rubl
                TorgPred = wt-docs.Mngr_Name
                Operator = wt-docs.Oper_Name
                PayType = wt-docs.pay-name
                Kurs = wt-docs.Course
                Our-Obj = wt-docs.OurObjectName
                KladovName = wt-docs.Wrkr_name
                IspName = wt-docs.Isp-Name
                PayWaitDate = wt-docs.pay-waitdate
                .
        if Qnty = ? then Qnty = 0 .
        if Val-BruttoSaleSum = ? then Val-BruttoSaleSum = 0 .
        if Rubl-BruttoSaleSum = ? then Rubl-BruttoSaleSum = 0 .
        if Val-NettoSaleSum = ? then Val-NettoSaleSum = 0 .
        if Rubl-NettoSaleSum = ? then Rubl-NettoSaleSum = 0 .
        if Val-DiscntSum = ? then Val-DiscntSum = 0 .
        if Rubl-DiscntSum = ? then Rubl-DiscntSum = 0 .
        if Val-CostSum = ? then Val-CostSum = 0 .
        if Rubl-CostSum = ? then Rubl-CostSum = 0 .
        if NDS-Val = ? then NDS-Val = 0 .
        if NDS-Rubl = ? then NDS-Rubl = 0 .
        if DifferentTypes AND can-do( 'рас,спи':U, wt-docs.doc-type ) then do:
            assign
                Qnty = - Qnty
                Val-BruttoSaleSum = - Val-BruttoSaleSum
                Rubl-BruttoSaleSum = - Rubl-BruttoSaleSum
                Val-NettoSaleSum = - Val-NettoSaleSum
                Rubl-NettoSaleSum = - Rubl-NettoSaleSum
                Val-DiscntSum = - Val-DiscntSum
                Rubl-DiscntSum = - Rubl-DiscntSum
                Val-CostSum = - Val-CostSum
                Rubl-CostSum = - Rubl-CostSum
                NDS-Val = - NDS-Val
                NDS-Rubl = - NDS-Rubl .
        end.
        if DifferentTypes then do:
            if NOT wt-docs.internal then
                CASE wt-docs.doc-type :
                    when 'рас':U OR when 'возврат':U then
                        assign
                            Val-Effect = - ( Val-NettoSaleSum - Val-CostSum )
                            Rubl-Effect = - ( Rubl-NettoSaleSum - Rubl-CostSum ) .
                    when 'спи':U then
                        assign
                            Val-Effect = Val-CostSum
                            Rubl-Effect = Rubl-CostSum .
                    when 'инв':U then
                        if can-do( 'факт':U, wt-docs.status_ ) AND ( wt-docs.tot-doc <> 0 ) then
                            assign
                                Val-Effect = ( Val-NettoSaleSum - Val-CostSum )
                                Rubl-Effect = ( Rubl-NettoSaleSum - Rubl-CostSum ) .
                        else
                            assign     Val-Effect = 0    Rubl-Effect = 0 .
                    otherwise
                        assign     Val-Effect = 0    Rubl-Effect = 0 .
                END CASE .
            else
                assign      Val-Effect = 0    Rubl-Effect = 0 .
        end.
        else do:
            if NOT wt-docs.internal then
                CASE wt-docs.doc-type :
                    when 'рас':U then
                        assign
                            Val-Effect = ( Val-NettoSaleSum - Val-CostSum )
                            Rubl-Effect = ( Rubl-NettoSaleSum - Rubl-CostSum ) .
                        when 'спи':U then
                            assign
                                Val-Effect = - Val-CostSum
                                Rubl-Effect = - Rubl-CostSum .
                        when 'возврат':U then
                            assign
                                Val-Effect = - ( Val-NettoSaleSum - Val-CostSum )
                                Rubl-Effect = - ( Rubl-NettoSaleSum - Rubl-CostSum ) .
                        when 'инв':U then
                            if can-do( 'факт':U, wt-docs.status_ ) AND ( wt-docs.tot-doc <> 0 ) then
                                assign
                                    Val-Effect = ( Val-NettoSaleSum - Val-CostSum )
                                    Rubl-Effect = ( Rubl-NettoSaleSum - Rubl-CostSum ) .
                            else
                                assign     Val-Effect = 0    Rubl-Effect = 0 .
                        otherwise
                            assign     Val-Effect = 0    Rubl-Effect = 0 .
                    END CASE .
            else
                assign      Val-Effect = 0    Rubl-Effect = 0 .
        end.
        if Val-BruttoSaleSum <> 0 then do:
            if ( ( Val-DiscntSum / Val-BruttoSaleSum ) < 100 ) AND
               ( ( Val-DiscntSum / Val-BruttoSaleSum ) > -100 ) then
                Discnt-PC =
                    string( Val-DiscntSum / Val-BruttoSaleSum * 100 , "->>>9.9" ) + "%" .
            else
                if ( Val-DiscntSum / Val-BruttoSaleSum < -99.99 ) then
                    Discnt-PC = string( -9999.9 , "->>>9.9" ) + "%" .
                else
                    Discnt-PC = string( 9999.9 , "->>>9.9" ) + "%" .
        end.
        else do:
            Discnt-PC = string( 0, "->>>9.9" ) + "%" .
        end.
        if Val-CostSum <> 0 then do:
          if  ( Val-Effect / abs( Val-CostSum ) ) < 100
          AND ( Val-Effect / abs( Val-CostSum ) ) > -100 then do:
            assign
              Up-PC = string( Val-Effect / abs( Val-CostSum ) * 100 , "->>>9.9" ) + "%"
            .
          end.
          else do:
            if ( Val-Effect / abs( Val-CostSum ) ) < -99.99 then do:
              assign
                Up-PC = string( -9999.9 , "->>>9.9" ) + "%"
              .
            end.
            else do:
              assign
                Up-PC = string( 9999.9 , "->>>9.9" ) + "%"
              .
            end.
          end.
        end.
        else do:
          assign
            Up-PC = string( 0 , "->>>9.9" ) + "%"
          .
        end.
        ACCUMULATE
          Qnty               ( TOTAL )
          Val-BruttoSaleSum  ( TOTAL )
          Rubl-BruttoSaleSum ( TOTAL )
          Val-NettoSaleSum   ( TOTAL )
          Rubl-NettoSaleSum  ( TOTAL )
          Val-DiscntSum      ( TOTAL )
          Rubl-DiscntSum     ( TOTAL )
          Val-CostSum        ( TOTAL )
          Rubl-CostSum       ( TOTAL )
          NDS-Val            ( TOTAL )
          NDS-Rubl           ( TOTAL )
          Val-Effect         ( TOTAL )
          Rubl-Effect        ( TOTAL )
          for-doc-code       ( count )
          .
  if use-column[1]
  then  C-for-doc-attr:screen-value = string(wt-docs.doc-attr, entry(1, c-for-doc-attr:private-data, chr(4))).
  if use-column[2]
  then  C-for-doc-date:screen-value = string(wt-docs.doc-date, entry(1, c-for-doc-date:private-data, chr(4))).
  if use-column[3]
  then  C-for-fact-date:screen-value = string(wt-docs.fact-date, entry(1, c-for-fact-date:private-data, chr(4))).
  if use-column[4]
  then  C-for-doc-code:screen-value = string(wt-docs.doc-code, entry(1, c-for-doc-code:private-data, chr(4))).
  if use-column[5]
  then  C-for-cli-name:screen-value = string(wt-docs.cli-name, entry(1, c-for-cli-name:private-data, chr(4))).
  if use-column[6]
  then  C-Qnty:screen-value = string(Qnty, entry(1, c-Qnty:private-data, chr(4))).
  if use-column[7]
  then  C-Val-BruttoSaleSum:screen-value = string(Val-BruttoSaleSum, entry(1, c-Val-BruttoSaleSum:private-data, chr(4))).
  if use-column[8]
  then  C-Rubl-BruttoSaleSum:screen-value = string(Rubl-BruttoSaleSum, entry(1, c-Rubl-BruttoSaleSum:private-data, chr(4))).
  if use-column[9]
  then  C-Val-NettoSaleSum:screen-value = string(Val-NettoSaleSum, entry(1, c-Val-NettoSaleSum:private-data, chr(4))).
  if use-column[10]
  then  C-Rubl-NettoSaleSum:screen-value = string(Rubl-NettoSaleSum, entry(1, c-Rubl-NettoSaleSum:private-data, chr(4))).
  if use-column[11]
  then  C-Val-DiscntSum:screen-value = string(Val-DiscntSum, entry(1, c-Val-DiscntSum:private-data, chr(4))).
  if use-column[12]
  then  C-RUbl-DiscntSum:screen-value = string(Rubl-DiscntSum, entry(1, c-RUbl-DiscntSum:private-data, chr(4))).
  if use-column[13]
  then  C-Val-CostSum:screen-value = string(Val-CostSum, entry(1, c-Val-CostSum:private-data, chr(4))).
  if use-column[14]
  then  C-RUbl-CostSum:screen-value = string(Rubl-CostSum, entry(1, c-RUbl-CostSum:private-data, chr(4))).
  if use-column[15]
  then  C-Val-Effect:screen-value = string(Val-Effect, entry(1, c-Val-Effect:private-data, chr(4))).
  if use-column[16]
  then  C-RUbl-Effect:screen-value = string(Rubl-Effect, entry(1, c-RUbl-Effect:private-data, chr(4))).
  if use-column[17]
  then  C-Nds-Val:screen-value = string(Nds-Val, entry(1, c-Nds-Val:private-data, chr(4))).
  if use-column[18]
  then  C-Nds-Rubl:screen-value = string(Nds-Rubl, entry(1, c-Nds-Rubl:private-data, chr(4))).
  if use-column[19]
  then  C-Discnt-PC:screen-value = string((if Val-DiscntSum <> 0 AND Val-BruttoSaleSum <> 0 then Discnt-Pc else '' ), entry(1, c-Discnt-PC:private-data, chr(4))).
  if use-column[20]
  then  C-Up-Pc:screen-value = string((if Val-Effect <> 0 AND Val-CostSum <> 0 then UP-PC else '' ), entry(1, c-Up-Pc:private-data, chr(4))).
  if use-column[21]
  then  C-TorgPred:screen-value = string(TorgPred, entry(1, c-TorgPred:private-data, chr(4))).
  if use-column[22]
  then  C-Operator:screen-value = string(Operator, entry(1, c-Operator:private-data, chr(4))).
  if use-column[23]
  then  C-KladovName:screen-value = string(KladovName, entry(1, c-KladovName:private-data, chr(4))).
  if use-column[24]
  then  C-IspName:screen-value = string(IspName, entry(1, c-IspName:private-data, chr(4))).
  if use-column[25]
  then  C-PayType:screen-value = string(PayType, entry(1, c-PayType:private-data, chr(4))).
  if use-column[26]
  then  C-Kurs:screen-value = string(Kurs, entry(1, c-Kurs:private-data, chr(4))).
  if use-column[27]
  then  C-Our-Obj:screen-value = string(Our-Obj, entry(1, c-Our-Obj:private-data, chr(4))).
  if use-column[28]
  then  C-PayWaitDAte:screen-value = string(PayWaitDate, entry(1, c-PayWaitDAte:private-data, chr(4))).
  IF (line-counter(DocsStream)  modulo page-size(DocsStream)= 0) AND
     (line-counter(DocsStream) >= page-size(DocsStream)) then DO:
      display STREAM DocsStream    with frame top-frame .
  End.
  DISPLAY stream  DOcsStream                                     with frame x1.                                     DOWN 1 stream   DOcsStream                                     with frame x1.
  if Make-Excel then  put   stream ForExcel unformatted
  if use-column[1]
  then (reg-output(
                    string(wt-docs.doc-attr, entry(1, c-for-doc-attr:private-data, chr(4)))
                   ,c-for-doc-attr:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 1 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[2]
  then (reg-output(
                    string(wt-docs.doc-date, entry(1, c-for-doc-date:private-data, chr(4)))
                   ,c-for-doc-date:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 2 < last-col-num
         then CHR(9)
         else ""))
  else "":U
   if wt-docs.fact-date <> ?
    then
     (
  if use-column[3]
  then (reg-output(
                    string(wt-docs.fact-date, entry(1, c-for-fact-date:private-data, chr(4)))
                   ,c-for-fact-date:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 3 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  )
    else
     (
  if use-column[3]
  then (reg-output(
                    string('', entry(1, c-for-fact-date:private-data, chr(4)))
                   ,c-for-fact-date:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 3 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  )
  if use-column[4]
  then (reg-output(
                    string(wt-docs.doc-code, entry(1, c-for-doc-code:private-data, chr(4)))
                   ,c-for-doc-code:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 4 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[5]
  then (reg-output(
                    string(wt-docs.cli-name, entry(1, c-for-cli-name:private-data, chr(4)))
                   ,c-for-cli-name:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 5 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[6]
  then (reg-output(
                    string(Qnty, entry(1, c-Qnty:private-data, chr(4)))
                   ,c-Qnty:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 6 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[7]
  then (reg-output(
                    string(Val-BruttoSaleSum, entry(1, c-Val-BruttoSaleSum:private-data, chr(4)))
                   ,c-Val-BruttoSaleSum:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 7 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[8]
  then (reg-output(
                    string(Rubl-BruttoSaleSum, entry(1, c-Rubl-BruttoSaleSum:private-data, chr(4)))
                   ,c-Rubl-BruttoSaleSum:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 8 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[9]
  then (reg-output(
                    string(Val-NettoSaleSum, entry(1, c-Val-NettoSaleSum:private-data, chr(4)))
                   ,c-Val-NettoSaleSum:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 9 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[10]
  then (reg-output(
                    string(Rubl-NettoSaleSum, entry(1, c-Rubl-NettoSaleSum:private-data, chr(4)))
                   ,c-Rubl-NettoSaleSum:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 10 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[11]
  then (reg-output(
                    string(Val-DiscntSum, entry(1, c-Val-DiscntSum:private-data, chr(4)))
                   ,c-Val-DiscntSum:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 11 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[12]
  then (reg-output(
                    string(Rubl-DiscntSum, entry(1, c-RUbl-DiscntSum:private-data, chr(4)))
                   ,c-RUbl-DiscntSum:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 12 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[13]
  then (reg-output(
                    string(Val-CostSum, entry(1, c-Val-CostSum:private-data, chr(4)))
                   ,c-Val-CostSum:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 13 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[14]
  then (reg-output(
                    string(Rubl-CostSum, entry(1, c-RUbl-CostSum:private-data, chr(4)))
                   ,c-RUbl-CostSum:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 14 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[15]
  then (reg-output(
                    string(Val-Effect, entry(1, c-Val-Effect:private-data, chr(4)))
                   ,c-Val-Effect:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 15 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[16]
  then (reg-output(
                    string(Rubl-Effect, entry(1, c-RUbl-Effect:private-data, chr(4)))
                   ,c-RUbl-Effect:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 16 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[17]
  then (reg-output(
                    string(Nds-Val, entry(1, c-Nds-Val:private-data, chr(4)))
                   ,c-Nds-Val:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 17 < last-col-num
         then CHR(9)
         else ""))
  else "":U
                   .
  if Make-Excel then  put   stream ForExcel unformatted
  if use-column[18]
  then (reg-output(
                    string(Nds-Rubl, entry(1, c-Nds-Rubl:private-data, chr(4)))
                   ,c-Nds-Rubl:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 18 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[19]
  then (reg-output(
                    string(if Val-DiscntSum <> 0  AND Val-BruttoSaleSum <> 0  then Discnt-Pc else '' , entry(1, c-Discnt-PC:private-data, chr(4)))
                   ,c-Discnt-PC:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 19 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[20]
  then (reg-output(
                    string(if Val-Effect <> 0 AND Val-CostSum <> 0 then UP-PC else '' , entry(1, c-Up-Pc:private-data, chr(4)))
                   ,c-Up-Pc:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 20 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[21]
  then (reg-output(
                    string(TorgPred, entry(1, c-TorgPred:private-data, chr(4)))
                   ,c-TorgPred:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 21 < last-col-num
         then CHR(9)
         else ""))
  else "":U
                  .
  if Make-Excel then  put   stream ForExcel unformatted
  if use-column[22]
  then (reg-output(
                    string(Operator, entry(1, c-Operator:private-data, chr(4)))
                   ,c-Operator:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 22 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[23]
  then (reg-output(
                    string(KladovName, entry(1, c-KladovName:private-data, chr(4)))
                   ,c-KladovName:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 23 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[24]
  then (reg-output(
                    string(IspName, entry(1, c-IspName:private-data, chr(4)))
                   ,c-IspName:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 24 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[25]
  then (reg-output(
                    string(PayType, entry(1, c-PayType:private-data, chr(4)))
                   ,c-PayType:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 25 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[26]
  then (reg-output(
                    string(Kurs, entry(1, c-Kurs:private-data, chr(4)))
                   ,c-Kurs:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 26 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[27]
  then (reg-output(
                    string(Our-Obj, entry(1, c-Our-Obj:private-data, chr(4)))
                   ,c-Our-Obj:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 27 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[28]
  then (reg-output(
                    string(PayWaitDate, entry(1, c-PayWaitDAte:private-data, chr(4)))
                   ,c-PayWaitDAte:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 28 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  skip.
END.
c-for-cli-name:screen-value =  line .
if use-column[6]  then  C-Qnty:screen-value = line .
if use-column[7]  then  C-Val-BruttoSaleSum:screen-value = line .
if use-column[8]  then  C-Rubl-BruttoSaleSum:screen-value = line .
if use-column[9]  then  C-Val-NettoSaleSum:screen-value = line .
if use-column[10]  then  C-Rubl-NettoSaleSum:screen-value = line .
if use-column[11]  then  C-Val-DiscntSum:screen-value = line .
if use-column[12]  then  C-Rubl-DiscntSum:screen-value = line .
if use-column[13]  then  C-Val-CostSum:screen-value = line .
if use-column[14]  then  C-Rubl-CostSum:screen-value = line .
if use-column[15]  then  C-Val-Effect:screen-value = line .
if use-column[16]  then  C-Rubl-Effect:screen-value = line .
if use-column[17]  then  C-NDS-Val:screen-value = line .
if use-column[18]  then  C-NDS-Rubl:screen-value = line .
  DISPLAY stream  DOcsStream                                     with frame x1.                                     DOWN 1 stream   DOcsStream                                     with frame x1.
  c-for-cli-name:screen-value =  "ИТОГО " + trim(string( ACCUM COUNT for-doc-code )) + " по док-м " .
  if use-column[6]
  then  C-Qnty:screen-value = string(ACCUM TOTAL Qnty, entry(1, c-Qnty:private-data, chr(4))).
  if use-column[7]
  then  C-Val-BruttoSaleSum:screen-value = string(ACCUM TOTAL Val-BruttoSaleSum , entry(1, c-Val-BruttoSaleSum:private-data, chr(4))).
  if use-column[8]
  then  C-Rubl-BruttoSaleSum:screen-value = string(ACCUM TOTAL Rubl-BruttoSaleSum , entry(1, c-Rubl-BruttoSaleSum:private-data, chr(4))).
  if use-column[9]
  then  C-Val-NettoSaleSum:screen-value = string(ACCUM TOTAL Val-NettoSaleSum  , entry(1, c-Val-NettoSaleSum:private-data, chr(4))).
  if use-column[10]
  then  C-Rubl-NettoSaleSum:screen-value = string(ACCUM TOTAL Rubl-NettoSaleSum , entry(1, c-Rubl-NettoSaleSum:private-data, chr(4))).
  if use-column[11]
  then  C-Val-DiscntSum:screen-value = string(ACCUM TOTAL Val-DiscntSum     , entry(1, c-Val-DiscntSum:private-data, chr(4))).
  if use-column[12]
  then  C-Rubl-DiscntSum:screen-value = string(ACCUM TOTAL Rubl-DiscntSum    , entry(1, c-Rubl-DiscntSum:private-data, chr(4))).
  if use-column[13]
  then  C-Val-CostSum:screen-value = string(ACCUM TOTAL Val-CostSum       , entry(1, c-Val-CostSum:private-data, chr(4))).
  if use-column[14]
  then  C-Rubl-CostSum:screen-value = string(ACCUM TOTAL Rubl-CostSum      , entry(1, c-Rubl-CostSum:private-data, chr(4))).
  if use-column[15]
  then  C-Val-Effect:screen-value = string(ACCUM TOTAL Val-Effect        , entry(1, c-Val-Effect:private-data, chr(4))).
  if use-column[16]
  then  C-Rubl-Effect:screen-value = string(ACCUM TOTAL Rubl-Effect       , entry(1, c-Rubl-Effect:private-data, chr(4))).
  if use-column[17]
  then  C-NDS-Val:screen-value = string(ACCUM TOTAL NDS-Val           , entry(1, c-NDS-Val:private-data, chr(4))).
  if use-column[18]
  then  C-NDS-Rubl:screen-value = string(ACCUM TOTAL NDS-Rubl          , entry(1, c-NDS-Rubl:private-data, chr(4))).
  DISPLAY stream  DOcsStream                                     with frame x1.                                     DOWN 1 stream   DOcsStream                                     with frame x1.
 if Make-Excel then  put   stream ForExcel unformatted
  CHR(9) CHR(9) CHR(9) CHR(9)
  if use-column[5]
  then (reg-output(
                    string('ИТОГО ' + trim(string( ACCUM COUNT for-doc-code )) + ' по док-м ', entry(1, c-for-cli-name:private-data, chr(4)))
                   ,c-for-cli-name:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 5 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[6]
  then (reg-output(
                    string(ACCUM TOTAL Qnty, entry(1, c-Qnty:private-data, chr(4)))
                   ,c-Qnty:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 6 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[7]
  then (reg-output(
                    string(ACCUM TOTAL Val-BruttoSaleSum , entry(1, c-Val-BruttoSaleSum:private-data, chr(4)))
                   ,c-Val-BruttoSaleSum:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 7 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[8]
  then (reg-output(
                    string(ACCUM TOTAL Rubl-BruttoSaleSum, entry(1, c-Rubl-BruttoSaleSum:private-data, chr(4)))
                   ,c-Rubl-BruttoSaleSum:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 8 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[9]
  then (reg-output(
                    string(ACCUM TOTAL Val-NettoSaleSum  , entry(1, c-Val-NettoSaleSum:private-data, chr(4)))
                   ,c-Val-NettoSaleSum:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 9 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[10]
  then (reg-output(
                    string(ACCUM TOTAL Rubl-NettoSaleSum , entry(1, c-Rubl-NettoSaleSum:private-data, chr(4)))
                   ,c-Rubl-NettoSaleSum:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 10 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[11]
  then (reg-output(
                    string(ACCUM TOTAL Val-DiscntSum     , entry(1, c-Val-DiscntSum:private-data, chr(4)))
                   ,c-Val-DiscntSum:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 11 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[12]
  then (reg-output(
                    string(ACCUM TOTAL Rubl-DiscntSum    , entry(1, c-Rubl-DiscntSum:private-data, chr(4)))
                   ,c-Rubl-DiscntSum:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 12 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[13]
  then (reg-output(
                    string(ACCUM TOTAL Val-CostSum       , entry(1, c-Val-CostSum:private-data, chr(4)))
                   ,c-Val-CostSum:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 13 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[14]
  then (reg-output(
                    string(ACCUM TOTAL Rubl-CostSum      , entry(1, c-Rubl-CostSum:private-data, chr(4)))
                   ,c-Rubl-CostSum:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 14 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[15]
  then (reg-output(
                    string(ACCUM TOTAL Val-Effect        , entry(1, c-Val-Effect:private-data, chr(4)))
                   ,c-Val-Effect:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 15 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[16]
  then (reg-output(
                    string(ACCUM TOTAL Rubl-Effect       , entry(1, c-Rubl-Effect:private-data, chr(4)))
                   ,c-Rubl-Effect:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 16 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[17]
  then (reg-output(
                    string(ACCUM TOTAL NDS-Val           , entry(1, c-NDS-Val:private-data, chr(4)))
                   ,c-NDS-Val:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 17 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  if use-column[18]
  then (reg-output(
                    string(ACCUM TOTAL NDS-Rubl          , entry(1, c-NDS-Rubl:private-data, chr(4)))
                   ,c-NDS-Rubl:private-data
                   ,v-reg-replace
                   ,no
                   ,v-dec-sep
                   ,v-th-sep)  +
        (if 18 < last-col-num
         then CHR(9)
         else ""))
  else "":U
  .
run waitfram-hide in this-procedure  .
HIDE stream DocsStream FRAME BottomFrame .
HIDE stream DocsStream FRAME x1 .
HIDE stream DocsStream FRAME top-frame .
delete widget-pool "My-pool".
output stream DocsStream CLOSE.
if Make-Excel then output stream ForExcel close.
run waitfram-hide in this-procedure .
define variable v-user-action as character no-undo .
define variable v-printed as logical   no-undo .
define variable DisabledOptions as integer   no-undo .
DisabledOptions = if p-frame-width > 137 AND  p-frame-width <= 232  then 8
                  else (if p-frame-width > 232
                            then 9
                            else 0 ) .
run gbl/prnfilen.w
  (input  ""
  ,input  DisabledOptions
  ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
  ,input  7
  ,output v-user-action
  ,output v-printed
  ) .
