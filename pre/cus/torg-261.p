block-level on error undo, throw.
define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter rec_id         as recid.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: torg-261.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/torg-261.p $":U .
define variable vss-description as character no-undo init "Формы печати поставки".
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
    def var t-addres        like ub.firm.addres1   no-undo.
    def var t-phone         like ub.firm.phone     no-undo.
    def var t-inn           like ub.firm.inn       no-undo.
    def var t-okpo          like ub.firm.okpo      no-undo.
    def var t-temp-address  like ub.firm.addres1   no-undo.
    define  variable price-rubl-with-tax-sale    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-sale    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-sale like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-sale like ub.doc-line.price-base no-undo.
    define  variable vat-base-sale               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyer              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyer              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-sale               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-sale          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-sale          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-sale            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-sale            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-sale            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-sale            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl for ub.gds-dtl.
    define buffer out-vatp_parts       for ub.parts.
    define buffer out-vatp_sysconf     for ub.sysconf.
    define buffer out-vatp_doc-line    for ub.doc-line.
    define buffer out-vatp_goods       for ub.goods.
    define buffer out-vatp_trn-doc     for ub.trn-doc.
    define buffer out-vatp_doc-attr    for ub.doc-attr.
    define variable varprice-base-cons      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type         as   character                           no-undo.
    define variable varfrm-cnsv              as   character                           no-undo.
    define variable varroot-node             as   integer                             no-undo.
    define variable varempty-scale           as   logical                             no-undo.
    define variable varis-cons-parts-have    as   logical                             no-undo.
    define variable varsum-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl        as   logical                             no-undo.
    define variable varcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb               as   character                           no-undo.
    define variable out-vatp-have-vat-slt    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-doco  for ub.trn-doc .
    define buffer   in-vatp-partso    for ub.parts   .
    define buffer   in-vatp-doco      for ub.trn-doc .
    define buffer   in-vatp-goodso    for ub.goods   .
    define buffer   in-vatp-sysconfo  for ub.sysconf .
    define buffer   in-vatp_doc-attro for ub.doc-attr.
    define variable in-vatp-have-vat-slto       as   logical initial yes    no-undo.
    define variable vat-pc-loco                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbo                  as   character              no-undo.
    define variable slt-pc-loco                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateo              as   decimal                no-undo.
    define variable price-rubl-with-tax-loco    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loco    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loco     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loco like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loco like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loco  like ub.doc-line.price-base no-undo.
    define variable vat-base-loco               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loco               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loco           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loco         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loco         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loco          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loco             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loco             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loco              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loco          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdo             as   character              no-undo.
    define variable varinvatp-typeo             as   character              no-undo.
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#gds-engl as logical   no-undo .
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
define variable v-cntxt-host-name-obj as character no-undo .
define variable v-rcv-num as character no-undo .
define variable v-ord-doc as character no-undo .
define buffer buf_rep_currency for ub.currency.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-cntxt-host-code-obj
  ,output v-cntxt-host-name-obj
  )  .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
find first buf_rep_currency no-lock
  where buf_rep_currency.curr-code = base-code
  no-error .
  if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
               else base-type = "б.в." .
run get-report-num in parParentProc ( output g#report-num ).
run get-gds-engl in parParentProc ( output g#gds-engl ) .
FUNCTION RedLine RETURNS CHARACTER ( INPUT i-str AS CHARACTER ) :
  DEFINE VARIABLE v-str AS CHARACTER NO-UNDO.
  RUN get-red-line IN THIS-PROCEDURE ( INPUT i-str, OUTPUT v-str ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN i-str ELSE v-str ).
END FUNCTION.
PROCEDURE get-red-line :
  DEFINE  INPUT PARAMETER p-str AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS CHARACTER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-res = CAPS( SUBSTRING( p-str, 1, 1 ) ) + LC( SUBSTRING( p-str, 2 ) ).
  END.
END PROCEDURE.
FUNCTION get-decade-word RETURNS CHARACTER ( INPUT i-dec AS INTEGER, INPUT i-num AS INTEGER ) :
  DEFINE VARIABLE v-grade AS CHARACTER NO-UNDO.
  RUN get-number-grade IN THIS-PROCEDURE ( INPUT i-dec, INPUT i-num, OUTPUT v-grade ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN "":U ELSE v-grade ).
END FUNCTION.
FUNCTION Word-Sum RETURNS CHARACTER ( INPUT i-sum AS DECIMAL ) :
  DEFINE VARIABLE OutSum AS CHARACTER NO-UNDO.
  RUN conv-sum-to-word IN THIS-PROCEDURE ( INPUT i-sum, OUTPUT OutSum ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE OutSum ).
END FUNCTION.
PROCEDURE get-number-grade :
  DEFINE  INPUT PARAMETER p-dec AS INTEGER   NO-UNDO.
  DEFINE  INPUT PARAMETER p-num AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-list AS CHARACTER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    IF      p-dec = 1 THEN DO: ASSIGN v-list = ",один,два,три,четыре,пять,шесть,семь,восемь,девять".    END.
    ELSE IF p-dec = 2 THEN DO: ASSIGN v-list = "десять,одиннадцать,двенадцать,тринадцать,четырнадцать,пятнадцать,шестнадцать,семнадцать,восемнадцать,девятнадцать".    END.
    ELSE IF p-dec = 3 THEN DO: ASSIGN v-list = ",,двадцать,тридцать,сорок,пятьдесят,шестьдесят,семьдесят,восемьдесят,девяносто".   END.
    ELSE IF p-dec = 4 THEN DO: ASSIGN v-list = ",сто,двести,триста,четыреста,пятьсот,шестьсот,семьсот,восемьсот,девятьсот".  END.
                      ELSE DO: ASSIGN v-list = ",,,,,,,,,". END.
    ASSIGN p-res = ENTRY( p-num + 1, v-list ).
  END.
END PROCEDURE.
PROCEDURE conv-sum-to-word :
  DEFINE  INPUT PARAMETER p-sum AS DECIMAL   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Formatted  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE Word       AS CHARACTER NO-UNDO.
  DEFINE VARIABLE OutSum     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE jj         AS INTEGER   NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN Formatted = STRING( ABS( p-sum ), "999999999999999.99":U ) NO-ERROR.
    IF ERROR-STATUS :ERROR THEN DO:
      ASSIGN p-res = ?.
      UNDO, RETURN ERROR.
    END.
    DO jj = ( LENGTH( Formatted ) - 3 ) TO 3 BY -3 :
      IF SUBSTRING( Formatted, jj - 2, 3 ) = "000" THEN DO: NEXT. END.
      IF jj < 15 THEN DO:
        ASSIGN Word = ENTRY( jj, ",,триллион,,,миллиард,,,миллион,,,тысяч" ).
        IF SUBSTRING( Formatted, jj,     1 )  = "1" AND
           SUBSTRING( Formatted, jj - 1, 1 ) <> "1" AND jj = 12 THEN DO: ASSIGN Word = TRIM( Word ) + "а". END.
        IF SUBSTRING( Formatted, jj, 1 ) = "2" OR
           SUBSTRING( Formatted, jj, 1 ) = "3" OR
           SUBSTRING( Formatted, jj, 1 ) = "4" THEN DO:
          IF jj = 12 THEN DO:
            IF SUBSTRING( Formatted, jj - 1, 1 ) <> "1" THEN DO: ASSIGN Word = TRIM( Word ) + "и". END.
          END.       ELSE DO:
            IF SUBSTRING( Formatted, jj - 1, 1 ) <> "1" THEN DO: ASSIGN Word = TRIM( Word ) + "а". END.
          END.
        END.
        IF ( SUBSTRING( Formatted, jj,     1 ) <> "1" AND
             SUBSTRING( Formatted, jj,     1 ) <> "2" AND
             SUBSTRING( Formatted, jj,     1 ) <> "3" AND
             SUBSTRING( Formatted, jj,     1 ) <> "4" AND jj <> 12 ) OR
           ( SUBSTRING( Formatted, jj - 1, 1 )  = "1" AND jj <  12 ) THEN DO: ASSIGN Word = TRIM( Word ) + "ов". END.
        IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
      END.
      IF SUBSTRING( Formatted, jj - 1, 1 ) <> "1" THEN DO:
        IF      jj = 12 AND SUBSTRING( Formatted, jj, 1 ) = "1" THEN DO: ASSIGN Word = "одна". END.
        ELSE IF jj = 12 AND SUBSTRING( Formatted, jj, 1 ) = "2" THEN DO: ASSIGN Word = "две".  END.
        ELSE DO: ASSIGN Word = get-decade-word( 1, INTEGER( SUBSTRING( Formatted, jj, 1 ) ) ). END.
        IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
        ASSIGN Word = get-decade-word( 3, INTEGER( SUBSTRING( Formatted, jj - 1, 1 ) ) ).
      END.                                        ELSE DO:
        ASSIGN Word = get-decade-word( 2, INTEGER( SUBSTRING( Formatted, jj,     1 ) ) ).
      END.
      IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
      ASSIGN Word = get-decade-word( 4, INTEGER( SUBSTRING( Formatted, jj - 2, 1 ) ) ).
      IF Word <> "":U THEN DO: ASSIGN OutSum = TRIM( Word ) + " ":U + TRIM( OutSum ). END.
    END.
    ASSIGN OutSum = CAPS( SUBSTRING( OutSum, 1, 1 ) ) + SUBSTRING( OutSum, 2 ).
    IF OutSum = "":U AND TRUNCATE( p-sum, 0 ) = 0 THEN DO: ASSIGN OutSum = "Ноль". END.
    ASSIGN p-res = TRIM( OutSum ).
  END.
END PROCEDURE.
FUNCTION Total-Word RETURNS CHARACTER ( INPUT i-sum AS DECIMAL, INPUT i-curr AS CHARACTER, INPUT i-part AS CHARACTER ) :
  DEFINE VARIABLE word_sum AS CHARACTER NO-UNDO.
  RUN get-total-word IN THIS-PROCEDURE ( INPUT i-sum, INPUT i-curr, INPUT i-part, OUTPUT word_sum ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE word_sum ).
END FUNCTION.
PROCEDURE get-total-word :
  DEFINE  INPUT PARAMETER p-sum  AS DECIMAL   NO-UNDO.
  DEFINE  INPUT PARAMETER p-curr AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-part AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-word AS CHARACTER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-word = Word-Sum( p-sum ).
               ASSIGN p-word = ( IF p-sum < 0 THEN "- " ELSE "":U ) + TRIM(
                      RedLine( p-word )
               ) +
                      " ":U + p-curr + " ":U +
                      SUBSTRING( STRING( ABS( p-sum ), "999999999999999999999999999999.99" ), 32, 2 ) +
                      " ":U + p-part + ".".
                        END.
END PROCEDURE.
define variable Sort-gr AS LOGICAL
     LABEL "Сортировать по группам товаров"
     VIEW-AS TOGGLE-BOX
     size 42.25 by 0.75 NO-UNDO
     init false .
define variable  print-graft AS LOGICAL
     LABEL "Отладочная печать"
     VIEW-AS TOGGLE-BOX
     size 42.25 by 0.75 NO-UNDO
     init true
     .
def stream OutStream.
define variable    NAme1   as character no-undo .
define variable    Adres1 as character no-undo .
define variable    NAme2   as character no-undo .
define variable    Adres2  as character no-undo .
define variable PrintScale as   logical     no-undo.
define variable CostPrice  as   logical     no-undo.
define buffer This_Object for ub.clients .
define buffer gds-prt-1   for ub.gds-prt .
define buffer bar-code-1  for ub.bar-code .
define variable LineBuf    as character    no-undo.
define variable Line       as character    no-undo.
define variable UndLine    as character    no-undo.
define variable     Lines_Counter as   int  init 0  no-undo.
define variable     Tmp_Counter   as   int  init 0  no-undo.
define variable     tdoc-date     like ub.ord-doc-rcv.doc-date no-undo.
define variable     tdoc-code     like ub.ord-doc-rcv.doc-code no-undo.
define variable     trcv-code     like ub.ord-doc-rcv.rcv-code no-undo.
define variable  Control_sUM       as  decimal no-undo.
define variable  Control_Qnty      as  decimal no-undo.
define variable  PgQnty            as  decimal no-undo.
define variable  PgSum             as  decimal no-undo.
define variable  PgQnty-b          as  decimal no-undo.
define variable  PgSum-b           as  decimal no-undo.
define variable  SQnty             as  decimal no-undo.
define variable  SSum              as  decimal no-undo.
define variable  SQnty-b           as  decimal no-undo.
define variable  SSum-b            as  decimal no-undo.
define variable  PropisQnty        as  character no-undo.
define variable  PropisSum         as  character no-undo.
define variable  PropisQnty-b      as  character no-undo.
define variable  PropisSum-b       as  character no-undo.
define variable B-Sum1             as decimal format ">>>>>>>>>>9.99" no-undo .
define variable B-Sum              as decimal no-undo .
define variable B-Sum-qnty         as decimal no-undo .
define variable B-adress like ub.firm.addres1 no-undo .
define variable B-phone  like ub.firm.phone no-undo .
define variable  Propiscount       as  character no-undo.
define variable  PropiscountP      as  character no-undo.
define variable  abbr              as  character no-undo.
define variable tt    as int no-undo.
define variable sym1 as character  init ":"   no-undo.
define variable sym2 as character  init ":"   no-undo.
define variable sym3 as character  init ":"   no-undo.
define variable sym4 as character  init ":"   no-undo.
define variable sym5 as character  init ":"   no-undo.
define variable sym6 as character  init ":"   no-undo.
define variable sym7 as character  init ":"   no-undo.
define variable sym8 as character  init ":"   no-undo.
define variable sym9 as character  init ":"   no-undo.
define variable sym10 as character init ":"   no-undo.
define variable sym11 as character init ":"   no-undo.
define variable sym12 as character init ":"   no-undo.
define variable sym13 as character init ":"   no-undo.
define variable sym14 as character init ":"   no-undo.
define variable tb-code       as character    no-undo.
define variable Price         as decimal no-undo.
define variable UBL           as decimal no-undo .
define variable b-qnty        as decimal no-undo.
define variable b-stoim       as character no-undo .
define variable b-price       as character no-undo .
define variable B-service     as decimal no-undo.
define variable B-ship        as decimal no-undo.
define variable OKEI          as character    no-undo.
define variable ProdName      as character    no-undo.
define variable pp as character no-undo .
define variable tord-date as date no-undo .
DEFINE FRAME sl
        sym1 column-label ":!:!:!:!:"  format "X(1)" space(0)
        Lines_Counter COLUMN-LABEL "N!п/п! ! ! " format ">>>>9" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.goods.artic COLUMN-LABEL "Артикул! ! ! ! " format "X(16)" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.goods.gds-name COLUMN-LABEL "Наименование товара! ! ! ! " format "X(39)" space(0)
        Sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        tb-code COLUMN-LABEL "Код товара! ! ! ! " format "X(10)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.goods.sort COLUMN-LABEL "Сорт! ! ! ! " format "X(4)" space(0)
        sym11 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.units.OKEI COLUMN-LABEL "Код!ед.!изм.!по!ОКЕИ" format ">>>>" space(0)
        sym6 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.units.unit-name COLUMN-LABEL "Наим!ед.!изм.! ! " format "X(4)" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        B-qnty COLUMN-LABEL "Количество ! ! ! ! " format "->>>>>>>9.<<<" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        B-PRICE COLUMN-LABEL "Цена           ! ! ! ! " format "x(14)" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        B-stoim COLUMN-LABEL "Сумма ! ! ! ! " format "x(15)" space(0)
        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
       HEADER
        string( cur-time-print() ) AT 5 format "X(35)"
        string( "Поставка N " + trcv-code + "  " + trim (v-rcv-num) + " от  " + string ( tdoc-date , "99/99/9999" ) ) AT 47 format "X(63)"
        string( pp ) AT 90 format "X(19)"
        string( " Лист " + string( PAGE-NUMBER(OutStream) , ">>9") ) format "X(13)" SKIP
        UndLine format "X(136)" AT 1
        with width 136 down stream-io use-text NO-BOX.
find first ub.ord-doc-rcv WHERE recid(ub.ord-doc-rcv) = rec_id NO-LOCK .
assign
    tdoc-date = (if ub.ord-doc-rcv.status_ <> 'факт':U then ub.ord-doc-rcv.doc-date else ub.ord-doc-rcv.fact-date )
    tdoc-code = ub.ord-doc-rcv.doc-code
    trcv-code = ub.ord-doc-rcv.rcv-code
    .
v-rcv-num = entry(1,ub.ord-doc-rcv.sub-par,chr(4)) .
if ub.ord-doc-rcv.doc-code <> ? and ub.ord-doc-rcv.doc-code <> "" then do:
   define buffer buf_ord-doc for ub.ord-doc  .
   find first buf_ord-doc no-lock where buf_ord-doc.doc-code = ub.ord-doc-rcv.doc-code no-error .
   if available buf_ord-doc then
      v-ord-doc = buf_ord-doc.doc-code + " " + entry(1, buf_ord-doc.cli-out-doc, chr(4)) + " от " + string(buf_ord-doc.doc-date , "99/99/9999") .
end.
if session:set-wait-state("compiler") then.
output STREAM OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(62) .
assign
  Line    = fill("-", 136)
  UndLine = fill("_", 136)
  LineBuf = fill("_", 136) .
  if  CostPrice then DO:
                   IF PrintRubl
                     THEN Assign PP = "Учетные цены ".
                     Else Assign PP = "Учетные цены (б.в.)" .
                   End.
   Else DO:
                IF PrintRubl
                     THEN Assign PP = "Цены док-та".
                     Else Assign PP = "Цены док-та (б.в.)" .
        End.
if ub.ord-doc-rcv.exch-code = 0 then
    assign
        PrintRubl = true
        pp = "руб"
    .
else do:
   FIND ub.currency NO-LOCK WHERE ub.currency.curr-code = ub.ord-doc-rcv.exch-code.
   assign
        PrintRubl = false
        pp = ub.currency.curr-abbr
        .
        end.
.
run waitfram-show in this-procedure ( 'Подождите ...' ) .
FIND This_Object  WHERE This_Object.obj-type = ub.ord-doc-rcv.obj-type
                    AND This_Object.obj-code = ub.ord-doc-rcv.obj-code NO-LOCK.
FIND ub.clients  WHERE ub.clients.obj-type = 'орг':U
                AND ub.clients.obj-code = ub.ord-doc-rcv.host-code NO-LOCK.
define buffer buf_cli for ub.clients  .
find first buf_cli no-lock where
           buf_cli.obj-code = ub.ord-doc-rcv.cli-code and
           buf_cli.obj-type = ub.ord-doc-rcv.cli-type no-error .
  case ub.ord-doc-rcv.obj-type :
    when  'маг':U then do :
        find ub.shop  where ub.shop.obj-code = ub.ord-doc-rcv.obj-code no-lock.
        assign
          b-adress = ub.shop.addres1
          b-phone  = ub.shop.phone .
    end.
    when  'скл':U then do :
        find ub.store  where ub.store.obj-code = ub.ord-doc-rcv.obj-code no-lock.
        assign
          b-adress = ub.store.addres1
          b-phone  = ub.store.phone .
    end.
  end case.
  assign
   name1   = "ИНН " + t-inn + " " + caps( ub.clients.obj-name ) + " (" + string(ub.clients.obj-code) + ")"
   adres1  = t-addres + " " + t-phone
   name2   = This_Object.obj-name
   adres2  = b-adress + '  ' + b-phone
   .
    case clients.obj-type:
       when 'орг':U
       then do:
            FIND ub.firm WHERE ub.firm.firm-code = clients.obj-code NO-LOCK .
            if available ub.firm
            then do:
                assign
                    t-addres = ( if ub.firm.ind = 0 or ub.firm.ind = ? then "" else string( ub.firm.ind ) )
                    t-addres = t-addres
                        + ( if ub.firm.city = ? or trim(ub.firm.city) = ""
                            then ""
                            else ( (if t-addres = "" then "" else ", ") + trim( ub.firm.city ) )
                          )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 1, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                        + ( if  ub.firm.addres2 = ? or trim(ub.firm.addres2) = "" then "" else ( ", " + trim( ub.firm.addres2 ) ) )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 51, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 101, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                    t-phone = ub.firm.phone
                    t-inn   = ub.firm.inn
                    t-okpo  = ub.firm.okpo
                .
            end.
       end.
       when 'маг':U
       then do:
            FIND ub.shop WHERE ub.shop.obj-code = clients.obj-code NO-LOCK .
            if available ub.shop
            then do:
                assign
                    t-addres = ( if trim( shop.addres1 ) <> "" then ( trim( shop.addres1 ) ) else "" )
                            + ( if trim( shop.addres2 ) <> "" then ( ", " + trim( shop.addres2 ) ) else "" )
                    t-phone = shop.phone
                    t-inn = ""
                    t-okpo = ""
                .
            end.
       end.
       when 'скл':U
       then do:
            FIND ub.store WHERE ub.store.obj-code = clients.obj-code NO-LOCK .
            if available ub.store
            then do:
                assign
                    t-addres = ( if trim( ub.store.addres1 ) <> "" then ( trim( ub.store.addres1 ) ) else "" )
                            + ( if trim( ub.store.addres2 ) <> "" then ( ", " + trim( ub.store.addres2 ) ) else "" )
                    t-phone = ub.store.phone
                    t-inn = ""
                    t-okpo = ""
                .
            end.
       end.
       when 'чел':U
       then do:
            find ub.person where ub.person.psn-code = clients.obj-code no-lock .
            if available ub.person
            then do:
                assign
                    t-addres = ( if ub.person.ind <> 0 and ub.person.ind <> ? then string( ub.person.ind ) else "" )
                                + ( if  ub.person.city <> ? and trim(ub.person.city) <> "" then ( ", " + trim( ub.person.city ) ) else "" )
                                + ( if  ub.person.address <> ? and trim(ub.person.address) <> "" then ( ", " + trim( ub.person.address ) ) else "" )
                    t-phone = ub.person.phone1
                    t-inn = ub.person.inn
                    t-okpo = ub.person.okpo
                .
            end.
       end.
    end case.
PUT STREAM OutStream
                                                                     space(5) Line format  "X(19)" AT 42 + 76 skip
    space(0)                                                        "| " AT 42 + 76 'код':U  AT 50 + 76   "|" AT 60 + 76 skip
    space(0) "Форма по ОКУД" format "X(14)"                  AT 66 + 38  "| " AT 42 + 76 "0330226"            "|" AT 60 + 76 skip
    space(0) string( Name1 + ' ' + Adres1 ) format "X(100)"
                                     "по ОКПО" format "X(7)" AT  72 + 38 "| " AT  42 + 76 t-okpo format "X(16)" "|" AT 60 + 76 skip
    space(0) string( CAPS( buf_cli.obj-name ) + " (" + string(buf_cli.obj-code) + ")" ) format "X(100)"
                                                                    "| " AT 42 + 76                        "|" AT 60 + 76 skip
    space(0) "Вид деятельности по ОКДП" format "X(25)" AT 55 + 38       "| " AT 42 + 76                        "|" AT 60 + 76 skip
    space(0) "" format "X(26)" AT 53 + 38                               "| " AT 42 + 76 ub.ord-doc-rcv.doc-date
                                                                           format "99/99/9999"        "|" AT 60 + 76 skip
    space(0) "" format "X(29)" AT 50 + 38                               "| " AT 42 + 76
                            (if ub.ord-doc-rcv.status_ <> 'факт':U then tdoc-date else ?) format "99/99/9999" "|" AT 60 + 76 skip
    space(0) "Вид операции" format "X(12)" AT 67 + 38                   "| " AT 42 + 76 "  " format "X(16)"    "|" AT 60 + 76 skip
                                                                     space(5) Line format  "X(19)" AT 42 + 76 skip(2)
                                       space(79) Line format "X(33)" skip
    space(56) string( "ПОСТАВКА") format "x(10)"
                                      " | " at 79
                                        ( string( trcv-code , "X(16)" ) + " | "
                                        + string( tdoc-date , "99/99/9999" )
                                    + " | "  + (if ub.ord-doc-rcv.status_ <> 'факт':U then string( "(" + CAPS(ub.ord-doc-rcv.status_) + ")" ) else ""))
                                    + trim (v-rcv-num)
                                         format "X(116)"
                                         skip
                                         space(79) Line format "X(33)" skip
    space(0) "Заказчик " name2  format "X(130)" skip(1)
    space(0) "Заказ " v-ord-doc  format "X(130)" skip(1)
    space(0) "Адрес " adres2 format "X(40)"  skip(1)
    space(0) "Поставку принял "
                UndLine format "X(25)" AT 25 UndLine format "X(50)" at 60 SKIP
                  "должность" format "X(25)" AT 25 "фамилия,имя,отчество" format "X(50)" AT 60 SKIP(1)
    "Заказ передал отборщику " UndLine format "X(25)" AT 25 UndLine format "X(50)" at 60 SKIP
    "должность" format "X(25)" AT 25 "фамилия,имя,отчество" format "X(50)"  AT 60 SKIP(1)
    space(0) "Подготовить и доставить на дом к "  String(ub.ord-doc-rcv.ship-time,"hh:mm")
                                                                String(ub.ord-doc-rcv.ship-date , "99/99/9999")
                                                                format "X(193)"  SKIP(2)
    .
 FORM with frame sl .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
form header
  line format "X(136)" at 1 skip
  "Продолжение - на следующей странице" at 30 skip
  with frame bottomframe width 232 page-bottom no-labels no-box .
view stream outstream frame bottomframe .
   run waitfram-show in this-procedure( 'Подождите ...' ) .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
for each ub.ord-line-rcv where
         ub.ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code and
         ub.ord-line-rcv.doc-code = ub.ord-doc-rcv.doc-code
         no-lock ,
      first ub.goods where ub.goods.prod-type = ub.ord-line-rcv.prod-type and
                        ub.goods.prod-code = ub.ord-line-rcv.prod-code and
                        ub.goods.artic = ub.ord-line-rcv.artic no-lock break by (if sort-gr then  ub.goods.grp-name else ub.goods.artic) by ub.goods.artic
                        :
    find first ub.units where ub.units.unit-name = ub.ord-line-rcv.unit-cli no-lock no-error .
    assign
        lines_counter = lines_counter + 1  .
    accumulate  (ub.ord-line-rcv.cli-qnty * ub.ord-line-rcv.price-cli) ( total )
                 ub.ord-line-rcv.cli-qnty ( total )
                 ub.goods.artic ( count ).
    if sort-gr = true  and first-of (if sort-gr then  ub.goods.grp-name else ub.goods.artic) then do:
      down stream outstream 1 with frame sl .
      put stream outstream unformatted
           string("_______________Группа : " + trim(caps(ub.goods.grp-name)) + undline)  format "X(136)"
           skip .
           end.
            b-price = if ub.ord-line-rcv.price-cli = ? then "" else string(ub.ord-line-rcv.price-cli) .
            b-qnty  = ub.ord-line-rcv.cli-qnty .
            b-stoim =  if b-price = "" then "" else string(decimal(b-price) * b-qnty) .
            b-service = ub.ord-doc-rcv.sum-service.
            b-ship    = ub.ord-doc-rcv.sum-ship   .
    display stream outstream
      sym1
      lines_counter
      sym2
      ub.goods.artic
      sym3
      ub.goods.gds-name
      sym4
      trim( string( ub.goods.gds-code )) @ tb-code
      sym5
      ub.units.okei
      sym6
      ub.units.unit-name
      sym7
      ub.goods.sort
      sym9
      b-price
      sym10
      b-qnty
      sym11
      b-stoim
      sym12   with frame sl.
      down stream outstream 1 with frame sl .
      if print-graft = false  then  put stream outstream linebuf format "X(136)" skip.
    if ( ( ( accum count ub.goods.artic ) modulo 10 ) = 0 ) and
         ( ( accum count ub.goods.artic ) >= 10 ) then
        run waitfram-show in this-procedure ( "Обработано строк : " + string( accum count ub.goods.artic ) ) .
end.
assign
b-sum1 = accum total (ub.ord-line-rcv.cli-qnty * ub.ord-line-rcv.price-cli)
b-sum-qnty = accum total (ub.ord-line-rcv.cli-qnty)
b-sum = b-service + b-ship   + b-sum1.
  if b-sum1 = ? then do:
    display stream outstream
      "Итого " @ ub.units.unit-name
      b-sum-qnty  @ b-qnty
      sym9  sym10  sym7 sym12
      with frame sl.
   end.
  else do:
    display stream outstream
      "Итого " @ ub.units.unit-name
      b-sum-qnty  @ b-qnty
      b-sum1  @ b-stoim
      sym9  sym10  sym7 sym12
      with frame sl.
  end.
   down stream outstream 1 with frame sl .
    if print-graft = false then put stream outstream linebuf format "X(136)" skip.
    put stream outstream
      "Стоимость обслуживания:" + string( b-service , "->>>,>>>,>>9.99" ) + sym12 at 98 format "x(38)"  skip
      "    Стоимость доставки:" + string( b-ship    , "->>>,>>>,>>9.99" ) + sym12 at 98 format "x(38)"  skip
      if b-sum = ? then "" else
      "                 Всего:" + string( b-sum     , "->>>,>>>,>>9.99" ) + sym12 at 98 format "x(38)"  skip.
      down stream outstream 1 with frame sl .
    if print-graft = false then put stream outstream linebuf at 101 format "x(40)" skip.
run rep/wp-qnty.p ( Lines_counter, output PropisCount).
run rep/wp-qnty.p ( B-Sum-qnty, output PropisQnty).
if NOT PrintRubl then
    ASSIGN
    PropisSum = Total-Word( B-Sum, ub.currency.curr-abbr, ub.currency.part-abbr )
    abbr = pp
    .
else
    run rep/wp-rub.p ( B-Sum , output PropisSum, output abbr).
 run on-same-page in this-procedure (input 23) .
 HIDE stream OutStream FRAME BottomFrame .
 PUT  STREAM OutStream
            "Итого по поставке :" Skip
              "а) количество порядковых номеров: " + string(Lines_Counter) + " (" + PropisCount + ")"  format "x(179)"                         at 18 SKIP
              "б) общее количество единиц : " + string(B-Sum-qnty ) + " (" + PropisQnty + ")"  format "x(179)"  at 18 SKIP
              if B-Sum = ? then "" else
              "в) на сумму : " + trim(string(B-Sum , "->,>>>,>>>,>>>,>>>,>>>,>>9.99")) + abbr +
                            " (" + PropisSum + ")"  format "x(179)"  at 18 SKIP(1)
            "Расчет проверил "
            LineBuf format "X(25)"     AT 18 LineBuf format "X(25)"   AT 48 LineBuf format "X(50)"               AT 78 SKIP
            "должность" format "X(25)" AT 18 "подпись" format "X(25)" AT 48 "расшифровка подписи" format "X(50)" AT 78 SKIP(1)
            "Отобранный товар проверил контролер-упаковщик : "  LineBuf format "X(25)" AT 48 LineBuf format "X(50)"               AT 78 SKIP
                                                              "подпись" format "X(25)" AT 48 "расшифровка подписи" format "X(50)" AT 78 SKIP(1)
            "Товар выдал"  Skip
            LineBuf format "X(25)"                              AT 18 LineBuf format "X(25)"   AT 48 LineBuf format "X(50)"               AT 78 SKIP
            "должность" format "X(25)" AT 18 "подпись" format "X(25)" AT 48 "расшифровка подписи" format "X(50)" AT 78 SKIP(2)
            "Заказчик стоимость поставки оплатил" format "X(35)"  LineBuf   AT 48 format "X(25)" skip
                                                                "подпись заказчика" AT 48 format "X(25)" SKIP
            "Деньги в сумме " +
            ( if B-Sum = ? then " " else
            trim(string(b-Sum, "->,>>>,>>>,>>>,>>>,>>>,>>9.99")) + abbr + " (" + PropisSum + ")"
            )         format "x(179)"  SKIP(1)
            "получил"
            LineBuf format "X(25)"                              AT 18 LineBuf format "X(25)"   AT 48 LineBuf format "X(50)"               AT 78 SKIP
            "должность" format "X(25)"                          AT 18 "подпись" format "X(25)" AT 48 "расшифровка подписи" format "X(50)" AT 78 SKIP
            .
output stream OutStream CLOSE .
run waitfram-hide in this-procedure  .
define variable v-user-action as character no-undo .
define variable v-printed as logical   no-undo .
define variable DisabledOptions as integer   no-undo .
DisabledOptions = 0 .
run gbl/prnfilen.w
  (input  ""
  ,input  DisabledOptions
  ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
  ,input  7
  ,output v-user-action
  ,output v-printed
  ) .
procedure calc-sl :
define input parameter tt as character no-undo .
if tt = "artic":U THEN DO:
End.
if tt = "scala":U THEN DO:
End.
end procedure.
PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( OutStream ) then do:
    return .
  end.
  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then do:
    page stream OutStream .
  end.
end procedure.
