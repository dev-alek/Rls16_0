block-level on error undo, throw.
define input parameter parParentProc     AS WIDGET-HANDLE NO-UNDO.
define input parameter p-trn-doc-recid      as recid    no-undo.
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: inv-akt.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/inv-akt.p $":U .
def var vss-description as character no-undo init "Пустографка".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable sym1  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym2  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym3  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym4  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym5  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym6  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym7  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym8  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym9  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym10 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym11 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym12 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym13 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym14 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym15 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym16 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym17 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym18 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym19 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym20 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym21 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym22 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym23 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym24 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym25 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym26 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym27 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable temp1 as integer   no-undo.
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
  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).
  define variable g#quest-print as logical   no-undo .
  run get-quest-print in parParentProc ( output g#quest-print ).
  define variable g#log as logical   no-undo .
define shared variable  sort-name    as logical  no-undo.
define shared variable  sort-gr      as logical  no-undo.
define buffer buf_doc-line  for doc-line.
define buffer buf_trn-doc   for trn-doc.
define buffer buf_goods     for goods.
define buffer This_Object   for clients .
define variable v-lines-counter as int no-undo.
def temp-table temp_goods no-undo
    field obj-type      as character
    field unit-base     as character
    field obj-code      as integer
    field gds-code      as integer
    field artic         as character
    field prod-type     as character
    field prod-code     as integer
    field gds-name      as character
    field full-grp-name as character
    field qnty          as decimal
    index byart is primary unique artic prod-type prod-code
    index byname gds-name artic
    index bygrp full-grp-name
.
define stream OutStream.
define variable v-line-string   as character            no-undo.
define variable UndLine         as character            no-undo.
define variable v-doc-string    as character no-undo .
define variable v-qnty          as decimal   no-undo .
 DEFINE FRAME zapas
        sym1                 column-label ":"            format "x(1)"                   space(0)
        v-lines-counter      column-label "№"            format ">>>>>>>9":C             space(0)
        sym2                 column-label ":"            format "x(1)"                   space(0)
        temp_goods.artic     column-label "Артикул"      format "X(17)"                  space(0)
        sym3                 column-label ":"            format "x(1)"                   space(0)
        temp_goods.gds-name  column-label "Наименование" format "X(70)"  space(0)
        sym4                 column-label ":"            format "x(1)"                   space(0)
        temp_goods.unit-base column-label "ед.изм"       format "X(6)"                   space(0)
        sym5                 column-label ":"            format "x(1)"                   space(0)
        temp_goods.qnty      column-label "Факт. кол-во" format "->>>>>>>>>>>.<<<"       space(0)
        sym6                 column-label ":"            format "x(1)"                   space(0)
    HEADER
        cur-time-print()                                                        at 5    format "X(35)"
        v-doc-string                                                            at 67   format "X(40)"
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>>>9") )    at 111  format "X(17)"
    skip
        v-line-string  format "X(120)"  with width 136 down stream-io use-text NO-BOX.
if session :set-wait-state( "compiler" ) then.
output stream OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size 62 .
    assign
      v-line-string = fill("-", 129)
      UndLine       = fill("_", 129)
    .
    find first buf_trn-doc no-lock where recid( buf_trn-doc ) = p-trn-doc-recid .
    assign v-doc-string = "По документу N " + buf_trn-doc.doc-code + " от " + string( buf_trn-doc.doc-date, "99/99/9999" ) .
  find first This_Object  WHERE This_Object.obj-type = buf_trn-doc.obj-type AND This_Object.obj-code = buf_trn-doc.obj-code  NO-LOCK.
  find first  clients      WHERE clients.obj-type     = 'орг':U           AND clients.obj-code     = buf_trn-doc.host-code NO-LOCK.
      PUT STREAM OutStream
         v-line-string format  "X(100)" skip
         "| "  "Предприятие, организация " format  "X(30)" AT 15 "| " AT 50  "Склад " format  "X(20)" AT 75 "|" AT 100 skip
         v-line-string format  "X(100)" skip
         "| "  CAPS( clients.obj-name ) + " (" + string(clients.obj-code) + ")" format  "X(47)"  "| " AT 50
         string(  This_Object.obj-name  + " (" + string(This_Object.obj-code) + ")" ) format  "X(47)"  "| " AT 100  skip
         v-line-string format  "X(100)" skip (2)
        space(15) string( "Акт приема-передачи товарно-материальных ценностей № "
                + buf_trn-doc.doc-code + string( buf_trn-doc.doc-date, "99/99/9999")
                + (if buf_trn-doc.status_ <> 'факт':U then string( "(" + CAPS(buf_trn-doc.status_) + ")" ) else "")
                                    ) format "X(100)" skip (2)
      .
    form with frame zapas .
    form header
        v-line-string format "X(120)" at 1 skip   "Продолжение - на следующей странице" at 30 skip
        with frame BottomFrame width 136 page-bottom no-labels no-box .
    view stream OutStream frame BottomFrame .
    for each buf_doc-line no-lock where buf_doc-line.doc-code =  buf_trn-doc.doc-code :
      find first buf_goods no-lock
        where buf_goods.artic      = buf_doc-line.artic
          and buf_goods.prod-type  = buf_doc-line.prod-type
          and buf_goods.prod-code  = buf_doc-line.prod-code
      no-error.
      create temp_goods no-error.
      assign
        temp_goods.obj-type         = buf_doc-line.obj-type
        temp_goods.obj-code         = buf_doc-line.obj-code
        temp_goods.artic            = buf_doc-line.artic
        temp_goods.prod-type        = buf_doc-line.prod-type
        temp_goods.prod-code        = buf_doc-line.prod-code
        temp_goods.qnty             = buf_doc-line.doc-qnty
        temp_goods.gds-code         = ( if available buf_goods then buf_goods.gds-code else 0 )
        temp_goods.gds-name         = ( if available buf_goods then buf_goods.gds-name else "" )
        temp_goods.full-grp-name    = ( if available buf_goods then trim( buf_goods.grp-name," /\" ) else "" )
        temp_goods.unit-base        = buf_goods.unit-base
      .
    end.
    if sort-gr = yes then do:
      if sort-name = no  then do:
        for each temp_goods
          break by temp_goods.full-grp-name
                by temp_goods.artic
                by temp_goods.prod-type
                by temp_goods.prod-code
        :
          if first-of( temp_goods.full-grp-name ) then do:
            run print-group-line in this-procedure ( input temp_goods.full-grp-name ).
          end.
          run print-line in this-procedure .
        end.
      end.
      else do:
        for each temp_goods
          break by temp_goods.full-grp-name
              by temp_goods.gds-name
        :
          if first-of( temp_goods.full-grp-name )  then  run print-group-line in this-procedure ( input temp_goods.full-grp-name ).
          run print-line in this-procedure .
        end.
      end.
    end.
    else do:
      if sort-name = no then do:
        for each temp_goods  use-index byart :
          run print-line in this-procedure .
        end.
      end.
      else do:
        for each temp_goods use-index byname :
          run print-line in this-procedure .
        end.
      end.
    end.
    put  stream outstream  v-line-string  format "X(120)" .
    display stream OutStream
      Sym1 Sym5 Sym6
      "Итого:" @ temp_goods.gds-name
      v-qnty @ temp_goods.qnty
    with frame zapas.
    down stream  OutStream 1 with frame zapas.
    put  stream outstream  v-line-string  format "X(120)" .
    put  stream outstream skip
              "   Все ценности, поименованные  в  настоящей  инвентаризационной  описи  с комиссией проверены в натуре в моем (нашем)" SKIP
              "личном присутствии  и внесены в опись, в связи с чем претензий к инвентаризационной комиссии не имею (не имеем). " SKIP
              "Товарно-материальные ценности, перечисленные в описи, находятся на моем (нашем) ответственном хранении." SKIP(1)
              "   Сдал: " "Принял: " at 70 SKIP(1)
              UndLine   format "X(25)" AT 1  UndLine   format "X(25)" AT 30 UndLine   format "X(25)" AT 60 UndLine   format "X(25)" AT 90 SKIP
              "Фамилия" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "Фамилия" format "X(25)" AT 70 "подпись" format "X(25)" AT 100  SKIP
              UndLine   format "X(25)" AT 1  UndLine   format "X(25)" AT 30 UndLine   format "X(25)" AT 60 UndLine   format "X(25)" AT 90 SKIP
              "Фамилия" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "Фамилия" format "X(25)" AT 70 "подпись" format "X(25)" AT 100  SKIP
              "Указанные в настоящей описи данные и расчеты проверил"
                  UndLine format "X(25)" AT 10 UndLine format "X(25)"   AT 40 UndLine format "X(50)"               AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              "<<       >> _________________        г. " .
    HIDE   stream OutStream FRAME BottomFrame .
    HIDE   STREAM OutStream FRAME ZAPAS .
    Output stream OutStream close.
if session :set-wait-state( "" ) then.
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 0 >= 8 then 2 else 0), 0, 0,
                                      OUTPUT g#log ).
end.
else do:
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + " " +
      string( session:temp-directory) +  "$" + string( g#report-num )
              ) .
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl" + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txl" + " " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl"
              ) .
end.
procedure print-line :
  do on error undo, return error :
    assign
      v-lines-counter = v-lines-counter + 1
      v-qnty = v-qnty + temp_goods.qnty
    .
If Integer(50) = 0 Then Temp1  = 100  .
                      Else Temp1 = Integer(50) .
     IF ( v-lines-counter modulo Temp1 = 0 ) AND ( v-lines-counter >= Temp1 ) then
         RUN waitfram-show( "Обработано строк : " + string( v-lines-counter )) .
    display stream OutStream
      Sym1  Sym2 Sym3 Sym4 Sym5 Sym6
      v-lines-counter
      temp_goods.artic
      temp_goods.gds-name
      temp_goods.unit-base
      temp_goods.qnty
    with frame zapas.
    down stream  OutStream 1 with frame zapas.
  end.
end procedure.
procedure print-group-line :
  define input parameter p-full-grp-name  as character        no-undo.
  do on error undo, return error :
   DOWN stream OutStream 1 with FRAME zapas .
   PUT stream OutStream UNFORMATTED String("_______________Группа : " + TRIM(CAPS(p-full-grp-name)) + UndLine)  FORMAT "X(120)" skip  .
  end.
end procedure.
