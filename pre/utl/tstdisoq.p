block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode      as character no-undo .
DEFINE INPUT PARAMETER test-number as integer no-undo.
DEFINE INPUT PARAMETER f-d-card as char no-undo.
DEFINE INPUT PARAMETER dctype as integer no-undo.
define input parameter p-view-mode as integer no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: tstdisoq.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/tstdisoq.p $":U .
define variable vss-description as character no-undo init "Проверки правильности архивов по дисконтным картам".
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
DEFINE SHARED STREAM TEST.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE vchk-pay NO-UNDO
FIELD d-card like ub.chk-doc.d-card
FIELD PAY-code like ub.chk-pay.pay-code
FIELD curr-code like ub.chk-pay.curr-code
FIELD doc-date like ub.chk-pay.chk-date
FIELD cre-pay as logical
FIELD exch-rate as decimal
FIELD base-rate as decimal
FIELD tot-sum like ub.chk-pay.tot-sum
FIELD tot-base like ub.chk-pay.tot-base
FIELD tot-rubl like ub.chk-pay.tot-rubl
FIELD pmnt-code like ub.payment.pmnt-code
field obj-type            like ub.clients.obj-type
field obj-code            like ub.clients.obj-code
INDEX PI IS PRIMARY UNIQUE
d-card pay-code curr-code doc-date cre-pay exch-rate base-rate
index iobj obj-type obj-code
.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  NEW SHARED  temp-table temp-d-card no-undo
field card-num as integer
field d-card as character
field dt-code as integer
field first-card as character
field first-main-card as character
field gds-dis-base as decimal
field gds-dis-rubl as decimal
field gds-tot-b0   as decimal
field gds-tot-base as decimal
field gds-tot-r0   as decimal
field gds-tot-rubl as decimal
field host-code as integer
field main-card as character
field num-chk as integer
field obj-code as integer
field obj-type as character
field pay-tot-base as decimal
field pay-tot-rubl as decimal
field sum-dis-base as decimal
field sum-dis-rubl as decimal
field sum-tot-base as decimal
field sum-tot-rubl as decimal
field sum-tot-r-b         as decimal
field gds-tot-r-b         as decimal
field gds-dis-r-b         as decimal
field cli-type            as character
field cli-code            as integer
field emitent-host-code   as integer
field type                as character
field exp-imp             as logical
field sale-doc            as character
field sale-type           as character
field doc-date            as date
field base-code           as integer
field smart-nws-log       as logical init ?
field action              as integer
index pi is unique primary
d-card
obj-type obj-code
index iobj obj-type obj-code
index itype type emitent-host-code
.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info3 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure r-sale :
  define input parameter  p-doc-code          like ub.doc-line.doc-code          no-undo .
  define input parameter  p-artic             like ub.doc-line.artic             no-undo .
  define input parameter  p-prod-type         like ub.doc-line.prod-type         no-undo .
  define input parameter  p-prod-code         like ub.doc-line.prod-code         no-undo .
  define output parameter p-fact-qnty         like ub.ot-line.fact-qnty       no-undo .
  define output parameter p-vat-pc            like ub.doc-line.vat-pc         no-undo .
  define output parameter p-slt-pc            like ub.doc-line.slt-pc         no-undo .
  define output parameter p-sum-base          like ub.ot-line.sum-base        no-undo .
  define output parameter p-sum-rubl          like ub.ot-line.sum-rubl        no-undo .
  define output parameter p-vat-base          like ub.ot-line.vat-base        no-undo .
  define output parameter p-vat-rubl          like ub.ot-line.vat-rubl        no-undo .
  define output parameter p-slt-base          like ub.ot-line.slt-base        no-undo .
  define output parameter p-slt-rubl          like ub.ot-line.slt-rubl        no-undo .
  define output parameter p-road-tax-base     like ub.ot-line.road-tax-base   no-undo .
  define output parameter p-road-tax-rubl     like ub.ot-line.road-tax-rubl   no-undo .
  define output parameter p-transport-base    like ub.ot-line.transport-base  no-undo .
  define output parameter p-transport-rubl    like ub.ot-line.transport-rubl  no-undo .
  define output parameter p-other-base        like ub.ot-line.other-base      no-undo .
  define output parameter p-other-rubl        like ub.ot-line.other-rubl      no-undo .
  define output parameter p-excise-base       like ub.ot-line.excise-base     no-undo .
  define output parameter p-excise-rubl       like ub.ot-line.excise-rubl     no-undo .
  define variable vss-description as character no-undo initial "r-sale-01: обработка продажных цен товара".
  do
  on error undo, return error
  :
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
    define variable v-gds-dtl-fact-qnty as decimal no-undo .
    define buffer buf_gds-dtl  for ub.gds-dtl .
    define buffer buf_goods    for ub.goods .
    define buffer buf_trn-doc  for ub.trn-doc .
    define buffer buf_doc-line for ub.doc-line .
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info4 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info4 skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
        and buf_gds-dtl.artic     = buf_doc-line.artic
        and buf_gds-dtl.prod-type = buf_doc-line.prod-type
        and buf_gds-dtl.prod-code = buf_doc-line.prod-code
    on error undo, return error
    :
        if buf_trn-doc.doc-type <> 'инв':U
        then do:
            if buf_trn-doc.doc-type = 'при':U
            or buf_trn-doc.doc-type = 'возврат':U
            then do:
                assign
                    v-gds-dtl-fact-qnty = buf_gds-dtl.fact-qnty
                .
            end.
            else do:
                assign
                    v-gds-dtl-fact-qnty = - buf_gds-dtl.fact-qnty
                .
            end.
        end.
        else do:
            assign
                v-gds-dtl-fact-qnty = buf_gds-dtl.doc-qnty
            .
        end.
        if v-gds-dtl-fact-qnty <> 0
        then do:
if buf_trn-doc.ext-doc-type = 'ot':U or
   buf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and out-vatp_doc-attr.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attr then do:
    assign
      out-vatp-have-vat-slt = yes.
  end.
  else do:
     out-vatp-have-vat-slt = no.
  end.
end.
find first out-vatp_goods where out-vatp_goods.artic     = buf_doc-line.artic     and
                                   out-vatp_goods.prod-type = buf_doc-line.prod-type and
                                   out-vatp_goods.prod-code = buf_doc-line.prod-code no-lock.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-node
  ,input  'empty-scale=request'
  ,output varempty-scale
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * buf_trn-doc.base-rate / buf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = buf_trn-doc.doc-code
       and out-vatp_doc-line.artic      = buf_doc-line.artic
       and out-vatp_doc-line.prod-type  = buf_doc-line.prod-type
       and out-vatp_doc-line.prod-code  = buf_doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = buf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = buf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = buf_trn-doc.obj-code
                               and out-vatp_parts.artic      = buf_doc-line.artic
                               and out-vatp_parts.prod-type  = buf_doc-line.prod-type
                               and out-vatp_parts.prod-code  = buf_doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbo
  )  .
  if out-vatp_parts.out-code = 'free-zone':U     or
     out-vatp_parts.out-code = 'out-zone':U   or
     out-vatp_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slto = yes.
  end.
  else do:
    find first in-vatp_doc-attro no-lock
      where in-vatp_doc-attro.doc-code  = out-vatp_parts.out-code
        and in-vatp_doc-attro.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attro then do:
      assign
        in-vatp-have-vat-slto = yes.
    end.
    else do:
         in-vatp-have-vat-slto = no.
    end.
  end.
  assign
   price-cli-with-tax-loco = out-vatp_parts.price-cli
   cli-base-rateo          = out-vatp_parts.cli-base-rate.
  ASSIGN   road-tax-base-loco  = (if out-vatp_parts.road-tax-base  = ? then 0 else out-vatp_parts.road-tax-base)
           road-tax-rubl-loco  = (if out-vatp_parts.road-tax-rubl  = ? then 0 else out-vatp_parts.road-tax-rubl).
  ASSIGN  transport-base-loco = (if out-vatp_parts.transport-base = ? then 0 else out-vatp_parts.transport-base)
          transport-rubl-loco = (if out-vatp_parts.transport-rubl = ? then 0 else out-vatp_parts.transport-rubl)
          other-base-loco     = (if out-vatp_parts.other-base     = ? then 0 else out-vatp_parts.other-base)
          other-rubl-loco     = (if out-vatp_parts.other-rubl     = ? then 0 else out-vatp_parts.other-rubl)
          vat-pc-loco         = (if out-vatp_parts.vat-pc         = ? then 0 else out-vatp_parts.vat-pc)
          slt-pc-loco         = (if out-vatp_parts.slt-pc         = ? then 0 else out-vatp_parts.slt-pc).
          ASSIGN   slt-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
    ASSIGN   slt-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
  assign
    exch-rate-cli-loco = (out-vatp_parts.price-rubl - transport-rubl-loco - other-rubl-loco - road-tax-rubl-loco - (if out-vatp_parts.vat-type <> 'в т. ч.':U then vat-rubl-loco else 0) - (if out-vatp_parts.slt-type <> 'в т. ч.':U then slt-rubl-loco else 0)) / out-vatp_parts.price-cli .
  assign
    slt-cli-loco        = slt-rubl-loco       / exch-rate-cli-loco
    vat-cli-loco        = vat-rubl-loco       / exch-rate-cli-loco
    road-tax-cli-loco   = road-tax-rubl-loco  / exch-rate-cli-loco
    transport-cli-loco  = 0
    other-cli-loco      = 0
  .
ASSIGN
          price-base-without-tax-loco = price-base-with-tax-loco - vat-base-loco - slt-base-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))
    price-rubl-without-tax-loco = price-rubl-with-tax-loco - vat-rubl-loco - slt-rubl-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))
.
      assign
        varprice-base-cons = varprice-base-cons + (price-base-with-tax-loco - (if road-tax-base-loco = ? then 0 else road-tax-base-loco))* out-vatp_parts.fact-qnty
        varprice-rubl-cons = varprice-rubl-cons + (price-rubl-with-tax-loco - (if road-tax-rubl-loco = ? then 0 else road-tax-rubl-loco))* out-vatp_parts.fact-qnty.
      assign
        varis-cons-parts-have = yes
        varcons-qnty          = varcons-qnty + out-vatp_parts.fact-qnty.
    end.
    assign
      varfact-qnty = varfact-qnty + out-vatp_parts.fact-qnty.
  end.
end.
assign
  varprice-base-cons = varprice-base-cons / varcons-qnty
  varprice-rubl-cons = varprice-rubl-cons / varcons-qnty.
if varprice-base-cons = ? then do:
  assign
    varprice-base-cons = 0.
end.
if varprice-rubl-cons = ? then do:
  assign
    varprice-rubl-cons = 0.
end.
assign
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-base-sale            = buf_gds-dtl.discnt-base
  price-base-with-tax-sale    = (buf_gds-dtl.price-base - buf_gds-dtl.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-rubl-sale            = buf_gds-dtl.discnt-rubl
  price-rubl-with-tax-sale    = (buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl)
  .
if buf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = buf_gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty = buf_gds-dtl.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc).
end.
else do:
  if buf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-base-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-rubl-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
            ASSIGN
                p-fact-qnty           = p-fact-qnty     + v-gds-dtl-fact-qnty
                p-sum-base            = p-sum-base      + price-base-with-tax-sale  * v-gds-dtl-fact-qnty
                p-sum-rubl            = p-sum-rubl      + price-rubl-with-tax-sale  * v-gds-dtl-fact-qnty
                p-vat-base            = p-vat-base      + vat-base-sale             * v-gds-dtl-fact-qnty
                p-vat-rubl            = p-vat-rubl      + vat-rubl-sale             * v-gds-dtl-fact-qnty
                p-slt-base            = p-slt-base      + slt-base-sale             * v-gds-dtl-fact-qnty
                p-slt-rubl            = p-slt-rubl      + slt-rubl-sale             * v-gds-dtl-fact-qnty
                p-road-tax-base       = p-road-tax-base + road-tax-base-sale        * v-gds-dtl-fact-qnty
                p-road-tax-rubl       = p-road-tax-rubl + road-tax-rubl-sale        * v-gds-dtl-fact-qnty
                p-excise-base         = p-excise-base   + excise-base-sale          * v-gds-dtl-fact-qnty
                p-excise-rubl         = p-excise-rubl   + excise-rubl-sale          * v-gds-dtl-fact-qnty
                p-other-base          = p-other-base    + discnt-base-sale          * v-gds-dtl-fact-qnty
                p-other-rubl          = p-other-rubl    + discnt-rubl-sale          * v-gds-dtl-fact-qnty
            .
        end.
    end.
    assign
        p-transport-base      = 0
        p-transport-rubl      = 0
        p-vat-pc              = buf_doc-line.vat-pc
        p-slt-pc              = buf_doc-line.slt-pc
    .
  end.
  if p-fact-qnty      = ?
  or p-vat-pc         = ?
  or p-slt-pc         = ?
  or p-sum-base       = ?
  or p-sum-rubl       = ?
  or p-vat-base       = ?
  or p-vat-rubl       = ?
  or p-slt-base       = ?
  or p-slt-rubl       = ?
  or p-road-tax-base  = ?
  or p-road-tax-rubl  = ?
  or p-transport-base = ?
  or p-transport-rubl = ?
  or p-other-base     = ?
  or p-other-rubl     = ?
  or p-excise-base    = ?
  or p-excise-rubl    = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      vss-include-info4 skip
      "Получены неопределенные значения" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "fact-qnty     " p-fact-qnty      skip
      "vat-pc        " p-vat-pc         skip
      "slt-pc        " p-slt-pc         skip
      "sum-base      " p-sum-base       skip
      "sum-rubl      " p-sum-rubl       skip
      "vat-base      " p-vat-base       skip
      "vat-rubl      " p-vat-rubl       skip
      "slt-base      " p-slt-base       skip
      "slt-rubl      " p-slt-rubl       skip
      "road-tax-base " p-road-tax-base  skip
      "road-tax-rubl " p-road-tax-rubl  skip
      "transport-base" p-transport-base skip
      "transport-rubl" p-transport-rubl skip
      "other-base    " p-other-base     skip
      "other-rubl    " p-other-rubl     skip
      "excise-base   " p-excise-base    skip
      "excise-rubl   " p-excise-rubl    skip
      view-as alert-box error .
    undo, return error .
  end.
end procedure.
define variable vss-include-info8 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
def var vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure r-cost :
  define input  parameter v-doc-code       like ub.doc-line.doc-code          no-undo .
  define input  parameter v-artic          like ub.doc-line.artic             no-undo .
  define input  parameter v-prod-type      like ub.doc-line.prod-type         no-undo .
  define input  parameter v-prod-code      like ub.doc-line.prod-code         no-undo .
  define output parameter v-fact-qnty      like ub.ot-line.fact-qnty       no-undo .
  define output parameter v-vat-pc         like ub.doc-line.vat-pc         no-undo .
  define output parameter v-slt-pc         like ub.doc-line.slt-pc         no-undo .
  define output parameter v-sum-base       like ub.ot-line.sum-base        no-undo .
  define output parameter v-sum-rubl       like ub.ot-line.sum-rubl        no-undo .
  define output parameter v-vat-base       like ub.ot-line.vat-base        no-undo .
  define output parameter v-vat-rubl       like ub.ot-line.vat-rubl        no-undo .
  define output parameter v-slt-base       like ub.ot-line.slt-base        no-undo .
  define output parameter v-slt-rubl       like ub.ot-line.slt-rubl        no-undo .
  define output parameter v-road-tax-base  like ub.ot-line.road-tax-base   no-undo .
  define output parameter v-road-tax-rubl  like ub.ot-line.road-tax-rubl   no-undo .
  define output parameter v-transport-base like ub.ot-line.transport-base  no-undo .
  define output parameter v-transport-rubl like ub.ot-line.transport-rubl  no-undo .
  define output parameter v-other-base     like ub.ot-line.other-base      no-undo .
  define output parameter v-other-rubl     like ub.ot-line.other-rubl      no-undo .
  define output parameter v-excise-base    like ub.ot-line.excise-base     no-undo .
  define output parameter v-excise-rubl    like ub.ot-line.excise-rubl     no-undo .
  do
  on error undo, return error
  :
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
    def var v-parts-fact-qnty as decimal   no-undo .
    define buffer buf_parts    for ub.parts    .
    define buffer buf_goods    for ub.goods    .
    define buffer buf_trn-doc  for ub.trn-doc  .
    define buffer buf_doc-line for ub.doc-line .
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = v-doc-code
        and buf_doc-line.artic     = v-artic
        and buf_doc-line.prod-type = v-prod-type
        and buf_doc-line.prod-code = v-prod-code
      no-error .
    if not available buf_doc-line then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа"  skip
        "Документ" v-doc-code skip
        "Артикул" v-artic v-prod-type v-prod-code skip
        view-as alert-box error .
      return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = v-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" v-doc-code skip
        "Артикул" v-artic v-prod-type v-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
    if not available buf_goods then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info9 skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Документ" v-doc-code skip
        "Артикул" v-artic v-prod-type v-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_goods.gds-type = 'т':U then do:
          for each buf_parts no-lock
            where buf_parts.out-code  = buf_trn-doc.doc-code
              and buf_parts.obj-type  = buf_trn-doc.obj-type
              and buf_parts.obj-code  = buf_trn-doc.obj-code
              and buf_parts.artic     = buf_doc-line.artic
              and buf_parts.prod-type = buf_doc-line.prod-type
              and buf_parts.prod-code = buf_doc-line.prod-code
          on error undo, return error
          :
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_parts.out-code = 'free-zone':U     or
     buf_parts.out-code = 'out-zone':U   or
     buf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = buf_parts.price-cli
   cli-base-rate          = buf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_parts.road-tax-base  = ? then 0 else buf_parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_parts.road-tax-rubl  = ? then 0 else buf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_parts.transport-base = ? then 0 else buf_parts.transport-base)
          transport-rubl-loc = (if buf_parts.transport-rubl = ? then 0 else buf_parts.transport-rubl)
          other-base-loc     = (if buf_parts.other-base     = ? then 0 else buf_parts.other-base)
          other-rubl-loc     = (if buf_parts.other-rubl     = ? then 0 else buf_parts.other-rubl)
          vat-pc-loc         = (if buf_parts.vat-pc         = ? then 0 else buf_parts.vat-pc)
          slt-pc-loc         = (if buf_parts.slt-pc         = ? then 0 else buf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
            assign
              v-parts-fact-qnty  = (if buf_trn-doc.doc-type = 'при':U
                                    or buf_trn-doc.doc-type = 'возврат':U
                                    or buf_trn-doc.doc-type = 'инв':U
                                    then buf_parts.fact-qnty
                                    else - buf_parts.fact-qnty
                                   )
            .
            assign
              v-fact-qnty           = v-fact-qnty      + v-parts-fact-qnty
              v-sum-base            = v-sum-base       +  ( price-base-with-tax-loc * v-parts-fact-qnty )
              v-sum-rubl            = v-sum-rubl       +  ( price-rubl-with-tax-loc * v-parts-fact-qnty )
              v-vat-base            = v-vat-base       +  ( vat-base-loc            * v-parts-fact-qnty )
              v-vat-rubl            = v-vat-rubl       +  ( vat-rubl-loc            * v-parts-fact-qnty )
              v-slt-base            = v-slt-base       +  ( slt-base-loc            * v-parts-fact-qnty )
              v-slt-rubl            = v-slt-rubl       +  ( slt-rubl-loc            * v-parts-fact-qnty )
              v-road-tax-base       = v-road-tax-base  +  ( road-tax-base-loc       * v-parts-fact-qnty )
              v-road-tax-rubl       = v-road-tax-rubl  +  ( road-tax-rubl-loc       * v-parts-fact-qnty )
              v-excise-base         =   0
              v-excise-rubl         =   0
              v-transport-base      = v-transport-base +   (transport-base-loc      * v-parts-fact-qnty )
              v-transport-rubl      = v-transport-rubl +   (transport-rubl-loc      * v-parts-fact-qnty )
              v-other-base          = v-other-base     +   (other-base-loc          * v-parts-fact-qnty )
              v-other-rubl          = v-other-rubl     +   (other-rubl-loc          * v-parts-fact-qnty )
            .
        end.
assign
  price-rubl-with-tax-loc = buf_doc-line.price-rubl
  price-base-with-tax-loc = buf_doc-line.price-base
.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = buf_doc-line.artic     and
                                     in-vatp-goods.prod-type = buf_doc-line.prod-type and
                                     in-vatp-goods.prod-code = buf_doc-line.prod-code no-lock.
   if (not buf_trn-doc.internal and
           buf_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = buf_doc-line.road-tax
          road-tax-rubl-loc = buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = buf_doc-line.road-tax
          road-tax-base-loc = buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if buf_doc-line.transport-base = ? then 0 else buf_doc-line.transport-base)
        transport-rubl-loc = (if buf_doc-line.transport-rubl = ? then 0 else buf_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if buf_doc-line.other-base     = ? then 0 else buf_doc-line.other-base)
        other-rubl-loc     = (if buf_doc-line.other-rubl     = ? then 0 else buf_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if buf_doc-line.vat-pc         = ? then 0 else buf_doc-line.vat-pc)
        slt-pc-loc         = (if buf_doc-line.slt-pc         = ? then 0 else buf_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = buf_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = buf_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = buf_doc-line.obj-code  and
                                      in-vatp-parts.artic     = buf_doc-line.artic     and
                                      in-vatp-parts.prod-type = buf_doc-line.prod-type and
                                      in-vatp-parts.prod-code = buf_doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-base-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-base-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-rubl-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
        assign
            v-vat-pc              = vat-pc-loc
            v-slt-pc              = slt-pc-loc
        .
    end.
    else do:
          assign
            v-parts-fact-qnty           = (if buf_trn-doc.doc-type = 'при':U
                                      or buf_trn-doc.doc-type = 'возврат':U
                                      or buf_trn-doc.doc-type = 'инв':U
                                      then buf_doc-line.fact-qnty
                                      else - buf_doc-line.fact-qnty
                                    )
          .
assign
  price-rubl-with-tax-loc = buf_doc-line.price-rubl
  price-base-with-tax-loc = buf_doc-line.price-base
.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = buf_doc-line.artic     and
                                     in-vatp-goods.prod-type = buf_doc-line.prod-type and
                                     in-vatp-goods.prod-code = buf_doc-line.prod-code no-lock.
   if (not buf_trn-doc.internal and
           buf_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = buf_doc-line.road-tax
          road-tax-rubl-loc = buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = buf_doc-line.road-tax
          road-tax-base-loc = buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if buf_doc-line.transport-base = ? then 0 else buf_doc-line.transport-base)
        transport-rubl-loc = (if buf_doc-line.transport-rubl = ? then 0 else buf_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if buf_doc-line.other-base     = ? then 0 else buf_doc-line.other-base)
        other-rubl-loc     = (if buf_doc-line.other-rubl     = ? then 0 else buf_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if buf_doc-line.vat-pc         = ? then 0 else buf_doc-line.vat-pc)
        slt-pc-loc         = (if buf_doc-line.slt-pc         = ? then 0 else buf_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = buf_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = buf_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = buf_doc-line.obj-code  and
                                      in-vatp-parts.artic     = buf_doc-line.artic     and
                                      in-vatp-parts.prod-type = buf_doc-line.prod-type and
                                      in-vatp-parts.prod-code = buf_doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-base-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-base-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-rubl-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
          assign
            v-fact-qnty           = v-fact-qnty      + v-parts-fact-qnty
            v-vat-pc              = vat-pc-loc
            v-slt-pc              = slt-pc-loc
            v-sum-base            = v-sum-base       + (price-base-with-tax-loc * v-parts-fact-qnty)
            v-sum-rubl            = v-sum-rubl       + (price-rubl-with-tax-loc * v-parts-fact-qnty)
            v-vat-base            = v-vat-base       + (vat-base-loc            * v-parts-fact-qnty)
            v-vat-rubl            = v-vat-rubl       + (vat-rubl-loc            * v-parts-fact-qnty)
            v-slt-base            = v-slt-base       + (slt-base-loc            * v-parts-fact-qnty)
            v-slt-rubl            = v-slt-rubl       + (slt-rubl-loc            * v-parts-fact-qnty)
            v-road-tax-base       =  0
            v-road-tax-rubl       =  0
            v-excise-base         =  0
            v-excise-rubl         =  0
            v-transport-base      =  0
            v-transport-rubl      =  0
            v-other-base          =  0
            v-other-rubl          =  0
          .
    end.
  end.
end procedure.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION calc-dcpc-1 RETURNS DECIMAL(input  for-sum as decimal,
                                   input  n-d-pcnt as decimal,
                                   input  sumdiscs as char,
                                   output new-d-pcnt     as decimal):
define variable ii as integer no-undo.
ii = 1.
new-d-pcnt = n-d-pcnt.
REPEAT while (ii <= num-entries(sumdiscs, ";")):
    IF for-sum >= DECIMAL(ENTRY(1,ENTRY(ii, sumdiscs, ";"), "=")) AND
        (ii = NUM-ENTRIES(sumdiscs,";") OR
        for-sum < DECIMAL(ENTRY(1,ENTRY(ii + 1, sumdiscs, ";"), "="))
          ) THEN do:
      assign
      new-d-pcnt = decimal(ENTRY(2,ENTRY(ii, sumdiscs, ";"), "=")) NO-ERROR.
        LEAVE.
    END.
    ii = ii + 1.
END.
RETURN new-d-pcnt.
END FUNCTION.
FUNCTION calc-dckat-1 RETURNS INTEGER(input  for-sum as decimal,
                                   input  n-kat as integer,
                                   input  sumdiscs as char,
                                   output new-kat  as integer):
define variable ii as integer no-undo.
ii = 1.
new-kat = n-kat.
REPEAT while (ii <= num-entries(sumdiscs, ";")):
    IF for-sum >= DECIMAL(ENTRY(1,ENTRY(ii, sumdiscs, ";"), "=")) AND
        (ii = NUM-ENTRIES(sumdiscs,";") OR
        for-sum < DECIMAL(ENTRY(1,ENTRY(ii + 1, sumdiscs, ";"), "="))
          ) THEN do:
      assign
      new-kat = integer(ENTRY(2,ENTRY(ii, sumdiscs, ";"), "=")) NO-ERROR.
        LEAVE.
    END.
    ii = ii + 1.
END.
RETURN new-kat.
END FUNCTION.
FUNCTION calc-dcpc-2 RETURNS DECIMAL(input  for-sum as decimal,
                                    input  n-d-pcnt as decimal,
                                   input  sumdiscs as char,
                                   output new-d-pcnt     as decimal):
define variable ii as integer no-undo.
define variable v-new-ii as integer no-undo init -1.
define variable v-old-ii as integer no-undo init -1.
define variable no-support as logical no-undo .
new-d-pcnt = 0.
if n-d-pcnt = ? then do:
  no-support = yes.
  n-d-pcnt = 0.
end.
ii = 1.
REPEAT while (ii <= num-entries(sumdiscs, ";")):
    if ii = 1 and
    for-sum < DECIMAL(ENTRY(1, ENTRY(ii, sumdiscs, ";"), "=")) then do:
       assign
       v-new-ii = 0.
    end.
    if ii = 1
    and  n-d-pcnt < DECIMAL(ENTRY(2, ENTRY(ii, sumdiscs, ";"), "=")) then do:
       assign
       v-old-ii = 0.
    end.
    IF for-sum >= DECIMAL(ENTRY(1, ENTRY(ii, sumdiscs, ";"), "=")) AND
        (ii = NUM-ENTRIES(sumdiscs, ";") OR
        for-sum < DECIMAL(ENTRY(1, ENTRY(ii + 1, sumdiscs, ";"), "="))
          ) THEN do:
      assign
      new-d-pcnt = decimal(ENTRY(2, ENTRY(ii, sumdiscs, ";"), "=")) NO-ERROR.
      v-new-ii = ii.
    END.
    IF n-d-pcnt >= DECIMAL(ENTRY(2, ENTRY(ii, sumdiscs, ";"), "=")) AND
        (ii = NUM-ENTRIES(sumdiscs, ";") OR
        n-d-pcnt < DECIMAL(ENTRY(2, ENTRY(ii + 1, sumdiscs, ";"), "="))
          ) THEN do:
      assign
      v-old-ii = ii.
    end.
    if (v-new-ii <> - 1
    AND V-OLD-II <>  -1)
    and ((v-old-ii - v-new-ii) >= 1
          or
          new-d-pcnt > n-d-pcnt
          or no-support
          )
    then leave.
    ii = ii + 1.
END.
if new-d-pcnt < n-d-pcnt then
new-d-pcnt = decimal(ENTRY(2, ENTRY(v-old-ii - 1, sumdiscs, ";"), "=")) no-error .
RETURN new-d-pcnt.
END FUNCTION.
FUNCTION calc-dckat-2 RETURNS INTEGER(input  for-sum as decimal,
                                   input  n-kat as integer,
                                   input  sumdiscs as char,
                                   output new-kat  as integer):
define variable ii as integer no-undo.
define variable v-new-ii as integer no-undo init -1.
define variable v-old-ii as integer no-undo init -1.
define variable no-support as logical no-undo .
if n-kat = ? then do:
  no-support = yes.
  n-kat = 0.
end.
ii = 1.
new-kat = 0.
REPEAT while (ii <= num-entries(sumdiscs, ";")):
    if ii = 1
    and for-sum < DECIMAL(ENTRY(1, ENTRY(ii, sumdiscs, ";"), "=")) then do:
       assign
       v-new-ii = 0.
    end.
    if ii = 1
    and n-kat < integer(ENTRY(2, ENTRY(ii, sumdiscs, ";"), "=")) then do:
       assign
       v-old-ii = 0.
    end.
    IF for-sum >= DECIMAL(ENTRY(1,ENTRY(ii, sumdiscs, ";"), "=")) AND
        (ii = NUM-ENTRIES(sumdiscs,";") OR
        for-sum < DECIMAL(ENTRY(1,ENTRY(ii + 1, sumdiscs, ";"), "="))
          ) THEN do:
      assign
      new-kat = integer(ENTRY(2,ENTRY(ii, sumdiscs, ";"), "=")) NO-ERROR.
      v-new-ii = ii.
    END.
    IF n-kat >= integer(ENTRY(2, ENTRY(ii, sumdiscs, ";"), "=")) AND
        (ii = NUM-ENTRIES(sumdiscs, ";") OR
        n-kat < integer(ENTRY(2, ENTRY(ii + 1, sumdiscs, ";"), "="))
          ) THEN do:
      assign
      v-old-ii = ii.
    END.
    if (v-new-ii <> - 1
    AND V-OLD-II <>  -1)
    and (abs(v-old-ii - v-new-ii) >= 1
         or
         no-support)
    then leave.
    ii = ii + 1.
END.
if v-new-ii < v-old-ii then
new-kat = integer(ENTRY(2, ENTRY(v-old-ii - 1, sumdiscs, ";"), "=")) no-error .
RETURN new-kat.
END FUNCTION.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
DEFINE VARiable rabota as logical no-undo.
define variable t-code like ub.doc-line.doc-code.
define variable ret-code like ub.doc-line.doc-code.
define variable ret-doc-code like ub.doc-line.doc-code.
define variable cre-pay   like ub.cash-pay.cdpay-code no-undo.
define variable cre-pay-base   like ub.dis-obj.pay-tot-base no-undo.
define variable cre-pay-rubl     like ub.dis-obj.pay-tot-rubl   no-undo.
define variable chk-exch as decimal no-undo.
define variable chk-exch-rubl as decimal no-undo.
define variable chk-exch-base as decimal no-undo.
define variable v-rate   as decimal no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo.
define variable do-obj-code as integer no-undo.
define variable do-chk-num as integer no-undo.
define variable do-gds-sum-rubl as decimal no-undo.
define variable do-disc-sum-rubl as decimal no-undo.
define variable do-pay-sum-rubl as decimal no-undo.
define variable do-gds-sum-base as decimal no-undo.
define variable do-disc-sum-base as decimal no-undo.
define variable do-pay-sum-base as decimal no-undo.
define variable dh-chk-num as integer no-undo.
define variable dh-gds-sum-rubl as decimal no-undo.
define variable dh-disc-sum-rubl as decimal no-undo.
define variable dh-pay-sum-rubl as decimal no-undo.
define variable dh-gds-sum-base as decimal no-undo.
define variable dh-disc-sum-base as decimal no-undo.
define variable dh-pay-sum-base as decimal no-undo.
define variable p-pay-sum-rubl as decimal no-undo.
define variable p-pay-sum-base as decimal no-undo.
define variable saldo-rubl as decimal no-undo.
define variable saldo-base as decimal no-undo.
define variable ii as integer no-undo.
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-curr-r-b as character no-undo .
define variable accum-tot-rubl     like ub.chk-pay.tot-rubl no-undo .
define variable accum-tot-base     like ub.chk-pay.tot-rubl no-undo .
define variable accum-cre-pay-base like ub.chk-pay.tot-rubl no-undo .
define variable accum-cre-pay-rubl like ub.chk-pay.tot-rubl no-undo .
define variable v-fact-qnty         like ub.ot-line.fact-qnty       no-undo .
define variable v-vat-pc            like ub.doc-line.vat-pc         no-undo .
define variable v-slt-pc            like ub.doc-line.slt-pc         no-undo .
define variable v-sum-base          like ub.ot-line.sum-base        no-undo .
define variable v-sum-rubl          like ub.ot-line.sum-rubl        no-undo .
define variable v-vat-base          like ub.ot-line.vat-base        no-undo .
define variable v-vat-rubl          like ub.ot-line.vat-rubl        no-undo .
define variable v-slt-base          like ub.ot-line.slt-base        no-undo .
define variable v-slt-rubl          like ub.ot-line.slt-rubl        no-undo .
define variable v-road-tax-base     like ub.ot-line.road-tax-base   no-undo .
define variable v-road-tax-rubl     like ub.ot-line.road-tax-rubl   no-undo .
define variable v-transport-base    like ub.ot-line.transport-base  no-undo .
define variable v-transport-rubl    like ub.ot-line.transport-rubl  no-undo .
define variable v-other-base        like ub.ot-line.other-base      no-undo .
define variable v-other-rubl        like ub.ot-line.other-rubl      no-undo .
define variable v-excise-base       like ub.ot-line.excise-base     no-undo .
define variable v-excise-rubl       like ub.ot-line.excise-rubl     no-undo .
define variable p-doc-code          as character no-undo .
define variable p-sign              as integer no-undo .
define variable p-direction         as integer no-undo .
define variable par-sign            as integer no-undo .
define variable sign                as integer no-undo init 1.
define variable par-direction       as integer no-undo .
define variable x_start-date        as date no-undo .
define variable x_end-date          as date no-undo .
define variable v-time              as integer no-undo .
define variable v-time2             as integer no-undo .
define variable v-ok                as logical no-undo .
define variable v-host-code         like ub.sysconf.host-code no-undo .
define variable new-d-pcnt           like ub.dis-card.d-pcnt no-undo .
define variable old-d-pcnt           like ub.dis-card.d-pcnt no-undo .
define variable for-sum             as decimal no-undo .
DEFINE VARIABLE from-card           as decimal no-undo.
define variable v-chk-num as integer no-undo .
define variable v-chk-num-do as integer no-undo .
define variable v-ref-list          as character no-undo .
define variable v-sum-id            as character no-undo .
define variable v-dt-code           as integer no-undo .
define variable v-chk-doc-sum-id    as character no-undo .
define variable v-algo-num          as character no-undo .
define variable v-for-what          as character no-undo .
define variable v-can-sum           as logical no-undo .
define variable v-can-calc          as logical no-undo .
define variable v-netto-sum         as decimal no-undo .
define variable v-netto-sum-do      as decimal no-undo .
define variable v-cond              as character no-undo .
define variable v-date-from         as date no-undo .
define variable v-date-to           as date no-undo .
define buffer buf_trn-doc for ub.trn-doc.
define buffer bf_trn-doc for ub.trn-doc.
define buffer buf_ret-doc for ub.trn-doc.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_dis-obj for ub.dis-obj.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_shop for ub.shop.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_inkas for ub.inkas .
define buffer buf_temp-d-card for temp-d-card.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_payment for ub.payment.
define buffer buf_curr-shop for ub.curr-shop.
define buffer buf_dis-card-type-attr for ub.dis-card-type-attr.
define buffer buf_clients for ub.clients.
define buffer buf_prop-ref for ub.prop-ref.
define temp-table temp-inkas no-undo like ub.inkas.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
if p-obj-code <> 0 then do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
_main:
do
on error undo, return error
:
if p-mode = "all" then do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CASE test-number:
  when 1 then do:
_chk-doc:
    for each buf_chk-doc no-lock where
            buf_chk-doc.obj-type = p-obj-type
        AND buf_chk-doc.obj-code = p-obj-code
        and buf_chk-doc.d-card   > "":U  ,
        first buf_dis-card NO-LOCK where
            buf_dis-card.d-card = buf_chk-doc.d-card
         AND buf_dis-card.emitent-host-code = dctype
        break by buf_chk-doc.obj-type
              by buf_chk-doc.obj-code
              by buf_chk-doc.d-card:
        ii = ii + 1.
        if ii MOD 100 = 0 then
        run waitfram-show in this-procedure ("Обработано " + string(ii) + " чеков по дисконтным картам").
        IF FIRST-OF(buf_chk-doc.obj-code) then do:
          find first buf_shop no-lock where
                    buf_shop.obj-code = buf_chk-doc.obj-code No-ERROR.
          if not avail buf_shop then do:
            run waitfram-hide in this-procedure .
            message "Не найдена запись о магазине номер " buf_chk-doc.obj-code view-as alert-box
            ERROR.
            return.
          end.
          find first buf_sysconf where
                      buf_sysconf.host-code = buf_shop.host-code no-lock No-ERROR.
          if not avail buf_sysconf then do:
            run waitfram-hide in this-procedure .
            message "Не найдена запись о фирме номер " buf_shop.host-code
            view-as alert-box
            ERROR.
            return.
          end.
          find first buf_Cash-pay no-lock where
                  buf_cash-pay.cdpay-code = buf_sysconf.credit-pay no-error.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'iscredit'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
          if error-status:error
          or not available buf_cash-pay
          or buf_cash-pay.is-credit = no
          or conf-par <> "yes"
          then do:
            assign
            cre-pay = 0
            .
          end.
          else do:
            assign
            cre-pay = buf_sysconf.credit-pay
            .
          end.
          assign
          v-base-code = buf_sysconf.base-code
          .
        end.
        if buf_chk-doc.out-code = ? then next.
        if LOOKUP(string(buf_chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,69,101,106,108,169,196,114,115,116,117,111,112,136,113,101,106,108,208,2,3,4,5,7,43,44':U) > 0 then NEXT.
        FIND FIRST buf_inkas No-LOCK WHERE
                    buf_inkas.inkas-code = buf_chk-doc.out-code No-ERROR.
        if not avail buf_inkas then next.
        find first temp-inkas no-lock where
                  temp-inkas.inkas-code = buf_Inkas.inkas-code no-error .
        find first buf_trn-doc no-lock where
                  buf_trn-doc.doc-code = buf_inkas.inkas-code no-error .
        if not available buf_trn-doc then do:
        end.
        find first buf_ret-doc no-lock where
                  buf_ret-doc.doc-code = buf_trn-doc.out-code no-error .
        if not available buf_ret-doc then do:
        end.
        if available buf_inkas
        and buf_inkas.status_ = 'факт':U
        and buf_inkas.obj-type = 'маг':U
        and not available temp-inkas
        then do:
          create temp-inkas.
          assign
          temp-inkas.inkas-code = buf_inkas.inkas-code
          rabota = yes.
        end.
        else do:
          rabota = no.
        end.
        if rabota then do:
            run waitfram-show in this-procedure ("Обработка отчета о продаже " + buf_inkas.inkas-code).
          par-sign = 1.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  _cards:
  for each ub.chk-doc no-lock
    where ub.chk-doc.obj-type = buf_inkas.obj-type
      AND ub.chk-doc.obj-code = buf_inkas.obj-code
      AND ub.chk-doc.out-code = buf_inkas.inkas-code
      and ub.chk-doc.d-card > ""
  on error undo _main, return error
  :
  if lookup(string(ub.chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,69,101,106,108,169,196,114,115,116,117,111,112,136,113,101,106,108,208,2,3,4,5,7,43,44':U) > 0 then next _cards.
    find first temp-d-card where
              temp-d-card.d-card = ub.chk-doc.d-card no-error .
    if not available temp-d-card then do:
      find first ub.dis-card no-lock
        where ub.dis-card.d-card = ub.chk-doc.d-card
        no-error .
      if not avail dis-card then do:
        next _cards.
      end.
      FIND FIRST ub.clients WHERE
                  ub.clients.obj-type = ub.dis-card.cli-type AND
                  ub.clients.obj-code = ub.dis-card.cli-code No-ERROR.
      if not avail ub.clients then do:
        undo _main, return error "Не найден клиент для дисконтной карты " + ub.dis-card.d-card.
      end.
      assign
        ub.clients.buy-gds = ub.clients.buy-gds OR ( NOT buf_inkas.office )
        ub.clients.buy-serv = ub.clients.buy-serv OR buf_inkas.office
      .
      create temp-d-card.
      assign
      temp-d-card.d-card = ub.chk-doc.d-card
      temp-d-card.pay-tot-base = 0
      temp-d-card.pay-tot-rubl = 0
      temp-d-card.gds-tot-b0 = 0
      temp-d-card.gds-tot-r0 = 0
      temp-d-card.first-main-card   = ub.dis-card.first-main-card
      temp-d-card.main-card         = ub.dis-card.main-card
      temp-d-card.first-card        = ub.dis-card.first-card
      temp-d-card.cli-type          = ub.dis-card.cli-type
      temp-d-card.cli-code          = ub.dis-card.cli-code
      temp-d-card.card-num          = ub.dis-card.card-num
      temp-d-card.emitent-host-code = ub.dis-card.emitent-host-code
      temp-d-card.type              = ub.dis-card.type
      temp-d-card.obj-type          = ub.chk-doc.obj-type
      temp-d-card.obj-code          = ub.chk-doc.obj-code
      temp-d-card.host-code         = buf_inkas.host-code
      temp-d-card.sale-doc          = buf_inkas.inkas-code
      temp-d-card.sale-type         = 'inkas':U
      temp-d-card.doc-date          = ub.chk-doc.chk-date
      temp-d-card.action            = sign
      .
    end.
    FOR EACH ub.chk-gds WHERE
              ub.chk-gds.doc-code = ub.chk-doc.doc-code AND
              ub.chk-gds.b-code <> 0 NO-LOCK ,
        FIRST ub.bar-code where
              ub.bar-code.b-code = ub.chk-gds.b-code No-LOCK,
        FIRST ub.goods where
              ub.goods.gds-code = ub.bar-code.gds-code No-LOCK,
        FIRST ub.doc-line WHERE
              ub.doc-line.doc-code = (if ub.chk-doc.netto >= 0 then buf_trn-doc.doc-code else ret-doc-code) AND
              ub.doc-line.prod-code = ub.goods.prod-code AND
              ub.doc-line.prod-type = ub.goods.prod-type AND
              ub.doc-line.artic = ub.goods.artic NO-LOCK
              On error undo _main, return error
              :
      if ub.chk-gds.write-off-code <> ?
      and ub.chk-gds.write-off-code > 0 then NEXT.
      assign
      temp-d-card.gds-tot-r0 = temp-d-card.gds-tot-r0 +  par-sign * ( ub.doc-line.price-rubl * ub.chk-gds.doc-qnty )
      temp-d-card.gds-tot-b0 = temp-d-card.gds-tot-b0 +  par-sign * ( ub.doc-line.price-base * ub.chk-gds.doc-qnty )
      .
    END.
    assign
    accum-tot-base = 0
    accum-tot-rubl = 0
    accum-cre-pay-base =0
    accum-cre-pay-rubl =0
    .
    FOR EACH ub.chk-pay WHERE
             ub.chk-pay.doc-code = ub.chk-doc.doc-code NO-LOCK
    On error undo _main, return error
    :
        if ub.chk-pay.pay-code = cre-pay
          then
        assign
        cre-pay-base = ub.chk-pay.tot-base
        cre-pay-rubl   = ub.chk-pay.tot-rubl .
          else
        assign
        cre-pay-base = 0
        cre-pay-rubl   = 0 .
        Assign
        accum-tot-rubl     = accum-tot-rubl +  ub.chk-pay.tot-rubl
        accum-tot-base     = accum-tot-base +  ub.chk-pay.tot-base
        accum-cre-pay-base = accum-cre-pay-base +  cre-pay-base
        accum-cre-pay-rubl = accum-cre-pay-rubl +  cre-pay-rubl
        .
        if v-cntxt-db-num = 0 and ub.chk-pay.pay-code <> cre-pay then do:
          FIND FIRST vchk-pay No-LOCK WHERE
                      vchk-pay.d-card = ub.chk-doc.d-card AND
                      vchk-pay.pay-code = ub.chk-pay.pay-code AND
                      vchk-pay.curr-code = ub.chk-pay.curr-code AND
                      vchk-pay.doc-date = ub.chk-pay.chk-date AND
                      vchk-pay.cre-pay = (ub.chk-pay.pay-code = cre-pay) AND
                      vchk-pay.exch-rate = (ub.chk-pay.tot-sum / chk-pay.tot-rubl) AND
                    vchk-pay.base-rate = (ub.chk-pay.tot-rubl / chk-pay.tot-base ) No-ERROR.
          IF NOT AVAIL vchk-pay then do:
            create vchk-pay.
            assign
            vchk-pay.d-card   = ub.chk-doc.d-card
            vchk-pay.doc-date = ub.chk-pay.chk-date
            vchk-pay.pay-code = ub.chk-pay.pay-code
            vchk-pay.curr-code = ub.chk-pay.curr-code
            vchk-pay.cre-pay = (ub.chk-pay.pay-code = cre-pay)
            vchk-pay.exch-rate =  (ub.chk-pay.tot-sum / ub.chk-pay.tot-rubl)
            vchk-pay.base-rate = (ub.chk-pay.tot-rubl / ub.chk-pay.tot-base)
            .
          end.
          assign
          vchk-pay.tot-sum  = vchk-pay.tot-sum  + ub.chk-pay.tot-sum
          vchk-pay.tot-base = vchk-pay.tot-base + ub.chk-pay.tot-base
          vchk-pay.tot-rubl = vchk-pay.tot-rubl + ub.chk-pay.tot-rubl
          .
      END.
    END .
    assign
    temp-d-card.pay-tot-base = temp-d-card.pay-tot-base + par-sign * (ACCUM-tot-base -  ACCUM-cre-pay-base)
    temp-d-card.pay-tot-rubl = temp-d-card.pay-tot-rubl + par-sign * (ACCUM-tot-rubl -  ACCUM-cre-pay-rubl)
    .
    if v-base-code = 0 then
    chk-exch =  1.
    else do:
      v-rate = ?.
      if v-curr-r-b = 'base':U then do:
        assign
        v-rate = ub.chk-doc.cash-rate / ub.chk-doc.cash-scale
        no-error
        .
        if v-rate <> 0
        and v-rate <> ? then do:
          chk-exch = v-rate.
        end.
        else do:
          assign
          v-rate = ACCUM-tot-rubl  / ACCUM-tot-base
          no-error
          .
          if v-rate <> ?
          and v-rate <> 0 then do:
            chk-exch = v-rate.
          end.
          else do:
              undo _main, return error substitute("&1&2 Невозможно определить курс базовой валюты для чека &3 по ДК &4"
                                                  , vss-description
                                                  , chr(10)
                                                  , chk-doc.doc-code
                                                  , chk-doc.d-card).
          end.
        end.
      end.
      else do:
        assign
        v-rate = ACCUM-tot-rubl  / ACCUM-tot-base
        no-error
        .
        if v-rate <> ?
        and v-rate <> 0 then do:
          chk-exch = v-rate.
        end.
        else do:
          FIND LAST buf_curr-shop NO-LOCK WHERE
                    buf_curr-shop.obj-type = ub.chk-doc.obj-type AND
                    buf_curr-shop.obj-code = ub.chk-doc.obj-code AND
                    buf_curr-shop.curr-code = v-base-code AND
                    ( ( buf_curr-shop.exch-date = ub.chk-doc.chk-date AND
                        buf_curr-shop.exch-time <= ub.chk-doc.chk-time ) OR
                        buf_curr-shop.exch-date < ub.chk-doc.chk-date ) NO-ERROR .
          if available buf_curr-shop then do:
            assign
            v-rate = buf_Curr-shop.exch-rate / buf_curr-shop.exch-scale
            no-error .
            if v-rate <> ?
            and v-rate <> 0 then do:
              chk-exch = v-rate.
            end.
            else do:
                undo _main, return error substitute("&1&2 Невозможно определить курс базовой валюты для чека &3 по ДК &4"
                                                    , vss-description
                                                    , chr(10)
                                                    , chk-doc.doc-code
                                                    , chk-doc.d-card).
            end.
          end.
        end.
      end.
    end.
    assign
    chk-exch-rubl = (if v-curr-r-b = 'rubl':U then 1 else chk-exch)
    chk-exch-base = (if v-curr-r-b = 'base':U then 1 else chk-exch )
    .
    Assign
    temp-d-card.sum-tot-r-b = temp-d-card.sum-tot-r-b + 0
    temp-d-card.sum-tot-rubl = temp-d-card.sum-tot-rubl + 0
    temp-d-card.sum-tot-base = temp-d-card.sum-tot-base + 0
    temp-d-card.gds-tot-r-b  = temp-d-card.gds-tot-r-b  + par-sign * ub.chk-doc.tot-doc
    temp-d-card.gds-tot-rubl = temp-d-card.gds-tot-rubl + par-sign * ub.chk-doc.tot-doc * chk-exch-rubl
    temp-d-card.gds-tot-base = temp-d-card.gds-tot-base + par-sign * ub.chk-doc.tot-doc / chk-exch-base
    temp-d-card.gds-dis-r-b  = temp-d-card.gds-dis-r-b  + par-sign * ub.chk-doc.discnt
    temp-d-card.gds-dis-rubl = temp-d-card.gds-dis-rubl + par-sign * ub.chk-doc.discnt * chk-exch-rubl
    temp-d-card.gds-dis-base = temp-d-card.gds-dis-base + par-sign * ub.chk-doc.discnt / chk-exch-base
    temp-d-card.num-chk      = temp-d-card.num-chk      + par-sign * 1
    .
    run ref/calctur4.p ( input ub.chk-doc.doc-code ) .
 END.
        end.
    END.
    for each buf_Dis-obj no-lock where
            buf_dis-obj.obj-type = p-obj-type
        AND buf_dis-obj.obj-code = p-obj-code
        and buf_dis-obj.dt-code = 0,
       first buf_dis-card no-lock where
            buf_dis-card.d-card = buf_dis-obj.d-card
    by buf_dis-obj.d-card
    by buf_dis-obj.dt-code
    by buf_dis-obj.obj-type
    by buf_dis-obj.obj-code:
      for each bf_trn-doc no-lock where
        bf_trn-doc.obj-type = p-obj-type
    AND bf_trn-doc.obj-code = p-obj-code
    AND bf_trn-doc.cli-type = buf_dis-card.cli-type
    AND bf_trn-doc.cli-code = buf_dis-card.cli-code:
      run waitfram-show in this-procedure ( substitute( "Обработка накладных по карте &1", buf_dis-obj.d-card )).
      if bf_trn-doc.d-card <> "":U then do:
        find first temp-d-card where
                  temp-d-card.d-card = bf_trn-doc.d-card
              no-error .
        if not available temp-d-card then do:
          create temp-d-card.
          assign
          temp-d-card.d-card            = buf_dis-card.d-card
          temp-d-card.card-num          = buf_dis-card.card-num
          temp-d-card.emitent-host-code = buf_dis-card.emitent-host-code
          temp-d-card.type              = buf_dis-card.type
          temp-d-card.cli-type          = buf_dis-card.cli-type
          temp-d-card.cli-code          = buf_dis-card.cli-code
          .
        end.
        assign
        p-doc-code = bf_trn-doc.doc-code
        .
        assign
        p-sign = 1
        p-direction =  if bf_trn-doc.ext-doc-type = 're':U
                      then -1
                      else  1
        par-sign = 1
        par-direction =  if bf_trn-doc.ext-doc-type = 're':U
                      then -1
                      else  1
        .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-cntxt-db-num = 0 then do:
  FOR EACH buf_doc-line no-lock where
          buf_doc-line.doc-code = p-doc-code
     On error undo _main, return error:
    run r-sale in this-procedure (
                                    input p-doc-code
                                   ,input buf_doc-line.artic
                                   ,input buf_doc-line.prod-type
                                   ,input buf_doc-line.prod-code
                                   ,output v-fact-qnty
                                   ,output v-vat-pc
                                   ,output v-slt-pc
                                   ,output v-sum-base
                                   ,output v-sum-rubl
                                   ,output v-vat-base
                                   ,output v-vat-rubl
                                   ,output v-slt-base
                                   ,output v-slt-rubl
                                   ,output v-road-tax-base
                                   ,output v-road-tax-rubl
                                   ,output v-transport-base
                                   ,output v-transport-rubl
                                   ,output v-other-base
                                   ,output v-other-rubl
                                   ,output v-excise-base
                                   ,output v-excise-rubl
                                    ) .
      assign
      temp-d-card.pay-tot-rubl = temp-d-card.pay-tot-rubl + par-direction * par-sign * abs( v-sum-rubl)
      temp-d-card.pay-tot-base = temp-d-card.pay-tot-base + par-direction * par-sign * abs( v-sum-base)
      temp-d-card.gds-tot-rubl = temp-d-card.gds-tot-rubl + par-direction * par-sign * abs( (v-sum-rubl + v-other-rubl))
      temp-d-card.gds-tot-base = temp-d-card.gds-tot-base + par-direction * par-sign * abs( (v-sum-base + v-other-base))
      temp-d-card.gds-dis-rubl = temp-d-card.gds-dis-rubl + par-direction * par-sign * abs( v-other-rubl)
      temp-d-card.gds-dis-base = temp-d-card.gds-dis-base + par-direction * par-sign * abs( v-other-base)
      .
      run r-cost in this-procedure (
                                    input p-doc-code
                                   ,input buf_doc-line.artic
                                   ,input buf_doc-line.prod-type
                                   ,input buf_doc-line.prod-code
                                   ,output v-fact-qnty
                                   ,output v-vat-pc
                                   ,output v-slt-pc
                                   ,output v-sum-base
                                   ,output v-sum-rubl
                                   ,output v-vat-base
                                   ,output v-vat-rubl
                                   ,output v-slt-base
                                   ,output v-slt-rubl
                                   ,output v-road-tax-base
                                   ,output v-road-tax-rubl
                                   ,output v-transport-base
                                   ,output v-transport-rubl
                                   ,output v-other-base
                                   ,output v-other-rubl
                                   ,output v-excise-base
                                   ,output v-excise-rubl
                                    ) .
    assign
    temp-d-card.gds-tot-r0 = temp-d-card.gds-tot-r0 + par-direction * par-sign * abs( v-sum-rubl)
    temp-d-card.gds-tot-b0 = temp-d-card.gds-tot-b0 + par-direction * par-sign * abs( v-sum-base)
    .
  END.
end.
if v-curr-r-b = 'base':U then
assign
temp-d-card.gds-tot-r-b = temp-d-card.gds-tot-base
temp-d-card.gds-dis-r-b = temp-d-card.gds-dis-base
temp-d-card.sum-tot-r-b = temp-d-card.sum-tot-base
.
else
assign
temp-d-card.gds-tot-r-b = temp-d-card.gds-tot-rubl
temp-d-card.gds-dis-r-b = temp-d-card.gds-dis-rubl
temp-d-card.sum-tot-r-b = temp-d-card.sum-tot-rubl
.
  find first vchk-pay no-lock where
            vchk-pay.d-card   = temp-d-card.d-card
        AND vchk-pay.pay-code = bf_trn-doc.pay-code
        AND vchk-pay.curr-code = bf_trn-doc.exch-code
        AND vchk-pay.doc-date  = 01/01/1990
        AND vchk-pay.cre-pay   = (cre-pay = bf_trn-doc.pay-code) no-error .
  if not available vchk-pay then do:
    create vchk-pay.
    assign
    vchk-pay.d-card   = temp-d-card.d-card
    vchk-pay.doc-date = bf_trn-doc.exch-date
    vchk-pay.pay-code = bf_trn-doc.pay-code
    vchk-pay.curr-code = bf_trn-doc.exch-code
    vchk-pay.cre-pay   =  no
    vchk-pay.exch-rate = bf_trn-doc.exch-rate
    vchk-pay.base-rate = bf_trn-doc.base-rate
    vchk-pay.tot-base =  temp-d-card.pay-tot-base
    vchk-pay.tot-rubl =  temp-d-card.pay-tot-rubl
    vchk-pay.tot-sum =  (if bf_trn-doc.exch-code = 0 then temp-d-card.pay-tot-rubl else temp-d-card.pay-tot-base)
    .
  end.
      end.
      end.
    end.
    for each temp-d-card
    break
    by temp-d-card.d-card
    by temp-d-card.obj-type
    by temp-d-card.obj-code:
      run waitfram-show in this-procedure ( substitute( "Окончательная обработка результатов и вывод в файл - карта &1", temp-d-card.d-card )).
      FIND FIRST buf_dis-obj No-LOCK WHERE
                  buf_dis-obj.d-card = temp-d-card.d-card
             AND  buf_dis-obj.obj-type = temp-d-card.obj-type
             AND  buf_dis-obj.obj-code = temp-d-card.obj-code
             AND  buf_dis-obj.dt-code = 0  No-ERROR.
      IF NOT AVAIL buf_dis-obj then do:
        assign
        do-obj-code = temp-d-card.obj-code
        do-chk-num = 0
        do-gds-sum-rubl = 0
        do-disc-sum-rubl = 0
        do-pay-sum-rubl = 0
        do-gds-sum-base = 0
        do-disc-sum-base = 0
        do-pay-sum-base = 0
        .
      end.
      else do:
        assign
        do-obj-code      = buf_dis-obj.obj-code
        do-chk-num       = buf_dis-obj.num-chk
        do-gds-sum-rubl  = buf_dis-obj.gds-tot-rubl - buf_dis-obj.sum-tot-rubl
        do-disc-sum-rubl = buf_dis-obj.gds-dis-rubl - buf_dis-obj.sum-dis-rubl
        do-pay-sum-rubl  = buf_dis-obj.pay-tot-rubl
        do-gds-sum-base  = buf_dis-obj.gds-tot-base - buf_dis-obj.sum-tot-base
        do-disc-sum-base = buf_dis-obj.gds-dis-base - buf_dis-obj.sum-dis-base
        do-pay-sum-base  = buf_dis-obj.pay-tot-base
        .
      end.
      if p-view-mode = 1
      or (do-chk-num <> temp-d-card.num-chk
      OR do-gds-sum-rubl <> temp-d-card.gds-tot-rubl
      OR do-disc-sum-rubl <> temp-d-card.gds-dis-rubl
      OR do-pay-sum-rubl <> temp-d-card.pay-tot-rubl
      OR do-gds-sum-base <> temp-d-card.gds-tot-base
      OR do-disc-sum-base <> temp-d-card.gds-dis-base
      OR do-pay-sum-base <> temp-d-card.pay-tot-base)
      then
      PUT STREAM TEST UNFORMATTED
      temp-d-card.d-card format "X(16)" space(1)
      do-obj-code format ">>>>9" space(1)
      do-chk-num format ">>>>>>>>>9" space(1)
      do-gds-sum-rubl format "->>>,>>>,>>9.99" space(1)
      do-disc-sum-rubl format "->>>,>>>,>>9.99" space(1)
      do-pay-sum-rubl format "->>>,>>>,>>9.99" space(1)
      do-gds-sum-base format "->>>,>>>,>>9.99" space(1)
      do-disc-sum-base format "->>>,>>>,>>9.99" space(1)
      do-pay-sum-base format "->>>,>>>,>>9.99" skip(0)
      "По чекам  и накладным"  format "X(22)" space(1)
      temp-d-card.num-chk  format ">>>>>>>>>9" space(1)
      temp-d-card.gds-tot-rubl format "->>>,>>>,>>9.99" space(1)
      temp-d-card.gds-dis-rubl format "->>>,>>>,>>9.99" space(1)
      temp-d-card.pay-tot-rubl format "->>>,>>>,>>9.99" space(1)
      temp-d-card.gds-tot-base format "->>>,>>>,>>9.99" space(1)
      temp-d-card.gds-dis-base format "->>>,>>>,>>9.99" space(1)
      temp-d-card.pay-tot-base format "->>>,>>>,>>9.99" space(1)
      skip(0)
      .
    end.
  end.
  when 6 then do:
    run gbl/get-per.w (
                    output v-ok
                   ,input-output x_start-date
                   ,input-output x_end-date
                                      ) no-error .
    if not v-ok then return.
    for each buf_sysconf,
       each buf_inkas no-lock where
            buf_Inkas.host-code = buf_sysconf.host-code
        AND buf_Inkas.obj-type = p-obj-type
        AND buf_Inkas.obj-code = p-obj-code
        AND buf_Inkas.doc-date >= x_start-date
        AND buf_Inkas.doc-date <= x_end-date
        AND buf_Inkas.status_ = 'факт':U
    break
    by buf_inkas.obj-type
    by buf_inkas.obj-code
    :
      IF FIRST-OF(buf_inkas.obj-code) then do:
        find first buf_shop no-lock where
                  buf_shop.obj-code = buf_inkas.obj-code No-ERROR.
        if not avail buf_shop then do:
          run waitfram-hide in this-procedure .
          message "Не найдена запись о магазине номер " buf_inkas.obj-code view-as alert-box
          ERROR.
          return.
        end.
        find first buf_Cash-pay no-lock where
                buf_cash-pay.cdpay-code = buf_sysconf.credit-pay no-error.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'iscredit'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
        if error-status:error
        or not available buf_cash-pay
        or buf_cash-pay.is-credit = no
        or conf-par <> "yes"
        then do:
          assign
          cre-pay = 0
          .
        end.
        else do:
          assign
          cre-pay = buf_sysconf.credit-pay
          .
        end.
        assign
        v-base-code = buf_sysconf.base-code
        .
      end.
      find first temp-inkas no-lock where
                temp-inkas.inkas-code = buf_Inkas.inkas-code no-error .
      find first buf_trn-doc no-lock where
                buf_trn-doc.doc-code = buf_inkas.inkas-code no-error .
      if not available buf_trn-doc
      or buf_trn-doc.status_ = 'запрос':U
      then do:
        nExt .
      end.
      find first buf_ret-doc no-lock where
                buf_ret-doc.doc-code = buf_trn-doc.out-code no-error .
      if not available buf_ret-doc then do:
        nExt .
      end.
      ii = ii + 1.
      run waitfram-show in this-procedure ("Обработано " + string(ii) + " продаж").
      for each temp-d-card:
        delete temp-d-card.
      end.
      for each vchk-pay:
        delete vchk-pay.
      end.
      run waitfram-show in this-procedure ("Обработка отчета о продаже " + buf_inkas.inkas-code).
      par-sign = 1.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  _cards:
  for each ub.chk-doc no-lock
    where ub.chk-doc.obj-type = buf_inkas.obj-type
      AND ub.chk-doc.obj-code = buf_inkas.obj-code
      AND ub.chk-doc.out-code = buf_inkas.inkas-code
      and ub.chk-doc.d-card > ""
  on error undo _main, return error
  :
  if lookup(string(ub.chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,69,101,106,108,169,196,114,115,116,117,111,112,136,113,101,106,108,208,2,3,4,5,7,43,44':U) > 0 then next _cards.
    find first temp-d-card where
              temp-d-card.d-card = ub.chk-doc.d-card
          AND temp-d-card.obj-type = ub.chk-doc.obj-type
          AND temp-d-card.obj-code = ub.chk-doc.obj-code  no-error .
    if not available temp-d-card then do:
      find first ub.dis-card no-lock
        where ub.dis-card.d-card = ub.chk-doc.d-card
        no-error .
      if not avail dis-card then do:
        next _cards.
      end.
      FIND FIRST ub.clients WHERE
                  ub.clients.obj-type = ub.dis-card.cli-type AND
                  ub.clients.obj-code = ub.dis-card.cli-code No-ERROR.
      if not avail ub.clients then do:
        undo _main, return error "Не найден клиент для дисконтной карты " + ub.dis-card.d-card.
      end.
      assign
        ub.clients.buy-gds = ub.clients.buy-gds OR ( NOT buf_inkas.office )
        ub.clients.buy-serv = ub.clients.buy-serv OR buf_inkas.office
      .
      create temp-d-card.
      assign
      temp-d-card.d-card = ub.chk-doc.d-card
      temp-d-card.pay-tot-base = 0
      temp-d-card.pay-tot-rubl = 0
      temp-d-card.gds-tot-b0 = 0
      temp-d-card.gds-tot-r0 = 0
      temp-d-card.first-main-card   = ub.dis-card.first-main-card
      temp-d-card.main-card         = ub.dis-card.main-card
      temp-d-card.first-card        = ub.dis-card.first-card
      temp-d-card.cli-type          = ub.dis-card.cli-type
      temp-d-card.cli-code          = ub.dis-card.cli-code
      temp-d-card.card-num          = ub.dis-card.card-num
      temp-d-card.emitent-host-code = ub.dis-card.emitent-host-code
      temp-d-card.type              = ub.dis-card.type
      temp-d-card.obj-type          = ub.chk-doc.obj-type
      temp-d-card.obj-code          = ub.chk-doc.obj-code
      temp-d-card.host-code         = buf_inkas.host-code
      temp-d-card.sale-doc          = buf_inkas.inkas-code
      temp-d-card.sale-type         = 'inkas':U
      temp-d-card.doc-date          = ub.chk-doc.chk-date
      temp-d-card.action            = sign
      .
    end.
    FOR EACH ub.chk-gds WHERE
              ub.chk-gds.doc-code = ub.chk-doc.doc-code AND
              ub.chk-gds.b-code <> 0 NO-LOCK ,
        FIRST ub.bar-code where
              ub.bar-code.b-code = ub.chk-gds.b-code No-LOCK,
        FIRST ub.goods where
              ub.goods.gds-code = ub.bar-code.gds-code No-LOCK,
        FIRST ub.doc-line WHERE
              ub.doc-line.doc-code = (if ub.chk-doc.netto >= 0 then buf_trn-doc.doc-code else ret-doc-code) AND
              ub.doc-line.prod-code = ub.goods.prod-code AND
              ub.doc-line.prod-type = ub.goods.prod-type AND
              ub.doc-line.artic = ub.goods.artic NO-LOCK
              On error undo _main, return error
              :
      if ub.chk-gds.write-off-code <> ?
      and ub.chk-gds.write-off-code > 0 then NEXT.
      assign
      temp-d-card.gds-tot-r0 = temp-d-card.gds-tot-r0 +  par-sign * ( ub.doc-line.price-rubl * ub.chk-gds.doc-qnty )
      temp-d-card.gds-tot-b0 = temp-d-card.gds-tot-b0 +  par-sign * ( ub.doc-line.price-base * ub.chk-gds.doc-qnty )
      .
    END.
    assign
    accum-tot-base = 0
    accum-tot-rubl = 0
    accum-cre-pay-base =0
    accum-cre-pay-rubl =0
    .
    FOR EACH ub.chk-pay WHERE
             ub.chk-pay.doc-code = ub.chk-doc.doc-code NO-LOCK
    On error undo _main, return error
    :
        if ub.chk-pay.pay-code = cre-pay
          then
        assign
        cre-pay-base = ub.chk-pay.tot-base
        cre-pay-rubl   = ub.chk-pay.tot-rubl .
          else
        assign
        cre-pay-base = 0
        cre-pay-rubl   = 0 .
        Assign
        accum-tot-rubl     = accum-tot-rubl +  ub.chk-pay.tot-rubl
        accum-tot-base     = accum-tot-base +  ub.chk-pay.tot-base
        accum-cre-pay-base = accum-cre-pay-base +  cre-pay-base
        accum-cre-pay-rubl = accum-cre-pay-rubl +  cre-pay-rubl
        .
        if v-cntxt-db-num = 0 and ub.chk-pay.pay-code <> cre-pay then do:
          FIND FIRST vchk-pay No-LOCK WHERE
                      vchk-pay.d-card = ub.chk-doc.d-card AND
                      vchk-pay.pay-code = ub.chk-pay.pay-code AND
                      vchk-pay.curr-code = ub.chk-pay.curr-code AND
                      vchk-pay.doc-date = ub.chk-pay.chk-date AND
                      vchk-pay.cre-pay = (ub.chk-pay.pay-code = cre-pay) AND
                      vchk-pay.exch-rate = (ub.chk-pay.tot-sum / chk-pay.tot-rubl) AND
                    vchk-pay.base-rate = (ub.chk-pay.tot-rubl / chk-pay.tot-base ) No-ERROR.
          IF NOT AVAIL vchk-pay then do:
            create vchk-pay.
            assign
            vchk-pay.d-card   = ub.chk-doc.d-card
            vchk-pay.doc-date = ub.chk-pay.chk-date
            vchk-pay.pay-code = ub.chk-pay.pay-code
            vchk-pay.curr-code = ub.chk-pay.curr-code
            vchk-pay.cre-pay = (ub.chk-pay.pay-code = cre-pay)
            vchk-pay.exch-rate =  (ub.chk-pay.tot-sum / ub.chk-pay.tot-rubl)
            vchk-pay.base-rate = (ub.chk-pay.tot-rubl / ub.chk-pay.tot-base)
            .
          end.
          assign
          vchk-pay.tot-sum  = vchk-pay.tot-sum  + ub.chk-pay.tot-sum
          vchk-pay.tot-base = vchk-pay.tot-base + ub.chk-pay.tot-base
          vchk-pay.tot-rubl = vchk-pay.tot-rubl + ub.chk-pay.tot-rubl
          .
      END.
    END .
    assign
    temp-d-card.pay-tot-base = temp-d-card.pay-tot-base + par-sign * (ACCUM-tot-base -  ACCUM-cre-pay-base)
    temp-d-card.pay-tot-rubl = temp-d-card.pay-tot-rubl + par-sign * (ACCUM-tot-rubl -  ACCUM-cre-pay-rubl)
    .
    if v-base-code = 0 then
    chk-exch =  1.
    else do:
      v-rate = ?.
      if v-curr-r-b = 'base':U then do:
        assign
        v-rate = ub.chk-doc.cash-rate / ub.chk-doc.cash-scale
        no-error
        .
        if v-rate <> 0
        and v-rate <> ? then do:
          chk-exch = v-rate.
        end.
        else do:
          assign
          v-rate = ACCUM-tot-rubl  / ACCUM-tot-base
          no-error
          .
          if v-rate <> ?
          and v-rate <> 0 then do:
            chk-exch = v-rate.
          end.
          else do:
              undo _main, return error substitute("&1&2 Невозможно определить курс базовой валюты для чека &3 по ДК &4"
                                                  , vss-description
                                                  , chr(10)
                                                  , chk-doc.doc-code
                                                  , chk-doc.d-card).
          end.
        end.
      end.
      else do:
        assign
        v-rate = ACCUM-tot-rubl  / ACCUM-tot-base
        no-error
        .
        if v-rate <> ?
        and v-rate <> 0 then do:
          chk-exch = v-rate.
        end.
        else do:
          FIND LAST buf_curr-shop NO-LOCK WHERE
                    buf_curr-shop.obj-type = ub.chk-doc.obj-type AND
                    buf_curr-shop.obj-code = ub.chk-doc.obj-code AND
                    buf_curr-shop.curr-code = v-base-code AND
                    ( ( buf_curr-shop.exch-date = ub.chk-doc.chk-date AND
                        buf_curr-shop.exch-time <= ub.chk-doc.chk-time ) OR
                        buf_curr-shop.exch-date < ub.chk-doc.chk-date ) NO-ERROR .
          if available buf_curr-shop then do:
            assign
            v-rate = buf_Curr-shop.exch-rate / buf_curr-shop.exch-scale
            no-error .
            if v-rate <> ?
            and v-rate <> 0 then do:
              chk-exch = v-rate.
            end.
            else do:
                undo _main, return error substitute("&1&2 Невозможно определить курс базовой валюты для чека &3 по ДК &4"
                                                    , vss-description
                                                    , chr(10)
                                                    , chk-doc.doc-code
                                                    , chk-doc.d-card).
            end.
          end.
        end.
      end.
    end.
    assign
    chk-exch-rubl = (if v-curr-r-b = 'rubl':U then 1 else chk-exch)
    chk-exch-base = (if v-curr-r-b = 'base':U then 1 else chk-exch )
    .
    Assign
    temp-d-card.sum-tot-r-b = temp-d-card.sum-tot-r-b + 0
    temp-d-card.sum-tot-rubl = temp-d-card.sum-tot-rubl + 0
    temp-d-card.sum-tot-base = temp-d-card.sum-tot-base + 0
    temp-d-card.gds-tot-r-b  = temp-d-card.gds-tot-r-b  + par-sign * ub.chk-doc.tot-doc
    temp-d-card.gds-tot-rubl = temp-d-card.gds-tot-rubl + par-sign * ub.chk-doc.tot-doc * chk-exch-rubl
    temp-d-card.gds-tot-base = temp-d-card.gds-tot-base + par-sign * ub.chk-doc.tot-doc / chk-exch-base
    temp-d-card.gds-dis-r-b  = temp-d-card.gds-dis-r-b  + par-sign * ub.chk-doc.discnt
    temp-d-card.gds-dis-rubl = temp-d-card.gds-dis-rubl + par-sign * ub.chk-doc.discnt * chk-exch-rubl
    temp-d-card.gds-dis-base = temp-d-card.gds-dis-base + par-sign * ub.chk-doc.discnt / chk-exch-base
    temp-d-card.num-chk      = temp-d-card.num-chk      + par-sign * 1
    .
    run ref/calctur4.p ( input ub.chk-doc.doc-code ) .
 END.
      FOR EACH buf_dis-card NO-LOCK where
              buf_dis-card.emitent-host-code = dctype,
        first temp-d-card no-lock where
            temp-d-card.d-card = buf_dis-card.d-card:
        assign
        p-pay-sum-rubl = 0
        p-pay-sum-base = 0
        .
        for each buf_payment no-lock where
                  buf_payment.host-code = buf_Inkas.host-code
              AND  buf_payment.d-card = temp-d-card.d-card
              and  buf_payment.status_ = 'факт':U
              and  buf_payment.source-type = 'касс':U
              and  buf_payment.source-ref = buf_inkas.inkas-code :
          assign
          p-pay-sum-rubl = p-pay-sum-rubl + buf_payment.tot-rubl
          p-pay-sum-base = p-pay-sum-base + buf_payment.tot-base
          .
        end.
        if p-view-mode = 1
        or (p-pay-sum-base <> temp-d-card.pay-tot-base
        or p-pay-sum-rubl <> temp-d-card.pay-tot-rubl) then
        PUT STREAM TEST UNFORMATTED
        temp-d-card.d-card format "X(16)" space(1)
        buf_inkas.inkas-code space(1)
        temp-d-card.pay-tot-rubl format "->>>,>>>,>>9.99" space(1)
        temp-d-card.pay-tot-base format "->>>,>>>,>>9.99" space(1)
        p-pay-sum-rubl  format "->>>,>>>,>>9.99" space(1)
        p-pay-sum-base  format "->>>,>>>,>>9.99" space(1)
        (temp-d-card.pay-tot-rubl - p-pay-sum-rubl) format "->>>,>>>,>>9.99" space(1)
        (temp-d-card.pay-tot-base - p-pay-sum-base) format "->>>,>>>,>>9.99" space(1)
        SKIP.
      END.
    end.
    for each buf_sysconf no-lock,
        each bf_trn-doc no-lock where
            bf_trn-doc.host-code = buf_sysconf.host-code
        AND bf_trn-doc.obj-type = p-obj-type
        AND bf_trn-doc.obj-code = p-obj-code
        AND bf_trn-doc.doc-date >= X_start-date
        AND bf_trn-doc.doc-date <= X_end-date:
      if bf_trn-doc.status_ <> 'факт':U then NEXT.
      if bf_trn-doc.d-card = "":U then NEXT.
      if bf_trn-doc.ext-doc-type = 'es':U then NEXT.
      if not can-find(first buf_dis-card NO-LOCK where
              buf_dis-card.emitent-host-code = dctype ) then NEXT.
      for each temp-d-card:
        delete temp-d-card.
      end.
      for each vchk-pay:
        delete vchk-pay.
      end.
      create temp-d-card.
      assign
      temp-d-card.d-card            = bf_trn-doc.d-card
      temp-d-card.card-num          = temp-d-card.card-num
      temp-d-card.emitent-host-code = temp-d-card.emitent-host-code
      temp-d-card.type              = temp-d-card.type
      temp-d-card.cli-type          = temp-d-card.cli-type
      temp-d-card.cli-code          = temp-d-card.cli-code
      .
      assign
      p-doc-code = bf_trn-doc.doc-code
      .
      assign
      par-sign = 1
      par-direction =  if bf_trn-doc.ext-doc-type = 're':U
                    then -1
                    else  1.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-cntxt-db-num = 0 then do:
  FOR EACH buf_doc-line no-lock where
          buf_doc-line.doc-code = p-doc-code
     On error undo _main, return error:
    run r-sale in this-procedure (
                                    input p-doc-code
                                   ,input buf_doc-line.artic
                                   ,input buf_doc-line.prod-type
                                   ,input buf_doc-line.prod-code
                                   ,output v-fact-qnty
                                   ,output v-vat-pc
                                   ,output v-slt-pc
                                   ,output v-sum-base
                                   ,output v-sum-rubl
                                   ,output v-vat-base
                                   ,output v-vat-rubl
                                   ,output v-slt-base
                                   ,output v-slt-rubl
                                   ,output v-road-tax-base
                                   ,output v-road-tax-rubl
                                   ,output v-transport-base
                                   ,output v-transport-rubl
                                   ,output v-other-base
                                   ,output v-other-rubl
                                   ,output v-excise-base
                                   ,output v-excise-rubl
                                    ) .
      assign
      temp-d-card.pay-tot-rubl = temp-d-card.pay-tot-rubl + par-direction * par-sign * abs( v-sum-rubl)
      temp-d-card.pay-tot-base = temp-d-card.pay-tot-base + par-direction * par-sign * abs( v-sum-base)
      temp-d-card.gds-tot-rubl = temp-d-card.gds-tot-rubl + par-direction * par-sign * abs( (v-sum-rubl + v-other-rubl))
      temp-d-card.gds-tot-base = temp-d-card.gds-tot-base + par-direction * par-sign * abs( (v-sum-base + v-other-base))
      temp-d-card.gds-dis-rubl = temp-d-card.gds-dis-rubl + par-direction * par-sign * abs( v-other-rubl)
      temp-d-card.gds-dis-base = temp-d-card.gds-dis-base + par-direction * par-sign * abs( v-other-base)
      .
      run r-cost in this-procedure (
                                    input p-doc-code
                                   ,input buf_doc-line.artic
                                   ,input buf_doc-line.prod-type
                                   ,input buf_doc-line.prod-code
                                   ,output v-fact-qnty
                                   ,output v-vat-pc
                                   ,output v-slt-pc
                                   ,output v-sum-base
                                   ,output v-sum-rubl
                                   ,output v-vat-base
                                   ,output v-vat-rubl
                                   ,output v-slt-base
                                   ,output v-slt-rubl
                                   ,output v-road-tax-base
                                   ,output v-road-tax-rubl
                                   ,output v-transport-base
                                   ,output v-transport-rubl
                                   ,output v-other-base
                                   ,output v-other-rubl
                                   ,output v-excise-base
                                   ,output v-excise-rubl
                                    ) .
    assign
    temp-d-card.gds-tot-r0 = temp-d-card.gds-tot-r0 + par-direction * par-sign * abs( v-sum-rubl)
    temp-d-card.gds-tot-b0 = temp-d-card.gds-tot-b0 + par-direction * par-sign * abs( v-sum-base)
    .
  END.
end.
if v-curr-r-b = 'base':U then
assign
temp-d-card.gds-tot-r-b = temp-d-card.gds-tot-base
temp-d-card.gds-dis-r-b = temp-d-card.gds-dis-base
temp-d-card.sum-tot-r-b = temp-d-card.sum-tot-base
.
else
assign
temp-d-card.gds-tot-r-b = temp-d-card.gds-tot-rubl
temp-d-card.gds-dis-r-b = temp-d-card.gds-dis-rubl
temp-d-card.sum-tot-r-b = temp-d-card.sum-tot-rubl
.
  find first vchk-pay no-lock where
            vchk-pay.d-card   = temp-d-card.d-card
        AND vchk-pay.pay-code = bf_trn-doc.pay-code
        AND vchk-pay.curr-code = bf_trn-doc.exch-code
        AND vchk-pay.doc-date  = 01/01/1990
        AND vchk-pay.cre-pay   = (cre-pay = bf_trn-doc.pay-code) no-error .
  if not available vchk-pay then do:
    create vchk-pay.
    assign
    vchk-pay.d-card   = temp-d-card.d-card
    vchk-pay.doc-date = bf_trn-doc.exch-date
    vchk-pay.pay-code = bf_trn-doc.pay-code
    vchk-pay.curr-code = bf_trn-doc.exch-code
    vchk-pay.cre-pay   =  no
    vchk-pay.exch-rate = bf_trn-doc.exch-rate
    vchk-pay.base-rate = bf_trn-doc.base-rate
    vchk-pay.tot-base =  temp-d-card.pay-tot-base
    vchk-pay.tot-rubl =  temp-d-card.pay-tot-rubl
    vchk-pay.tot-sum =  (if bf_trn-doc.exch-code = 0 then temp-d-card.pay-tot-rubl else temp-d-card.pay-tot-base)
    .
  end.
      assign
      p-pay-sum-rubl = 0
      p-pay-sum-base = 0
      .
      find first buf_payment no-lock where
                buf_payment.host-code = bf_trn-doc.host-code
          AND  buf_payment.d-card = temp-d-card.d-card
          and  buf_payment.status_ = 'факт':U
          and  buf_payment.source-type = 'накл':U
          and  buf_payment.source-ref = bf_trn-doc.doc-code  no-error .
      if available buf_payment then
      assign
      p-pay-sum-rubl = buf_payment.tot-rubl
      p-pay-sum-base = buf_payment.tot-base
      .
      if p-view-mode = 1
      OR (p-pay-sum-base <> temp-d-card.pay-tot-base
      or p-pay-sum-rubl <> temp-d-card.pay-tot-rubl) then
      PUT STREAM TEST UNFORMATTED
      temp-d-card.d-card format "X(16)" space(1)
      bf_trn-doc.doc-code space(1)
      temp-d-card.pay-tot-rubl format "->>>,>>>,>>9.99" space(1)
      temp-d-card.pay-tot-base format "->>>,>>>,>>9.99" space(1)
      p-pay-sum-rubl  format "->>>,>>>,>>9.99" space(1)
      p-pay-sum-base  format "->>>,>>>,>>9.99" space(1)
      (temp-d-card.pay-tot-rubl - p-pay-sum-rubl) format "->>>,>>>,>>9.99" space(1)
      (temp-d-card.pay-tot-base - p-pay-sum-base) format "->>>,>>>,>>9.99" space(1)
      SKIP.
    end.
  end.
  when 3 then do:
    FOR EACH ub.dis-host no-LOCK
      WHERE ub.dis-host.host-code = v-host-code
      AND ub.dis-host.host-code > 0
      and ub.dis-host.dt-code = 0
      BREAK
      by ub.dis-host.d-card
      by ub.dis-host.dt-code
      by ub.dis-host.host-code:
        assign
        do-chk-num = 0
        do-gds-sum-rubl = 0
        do-disc-sum-rubl = 0
        do-pay-sum-rubl = 0
        do-gds-sum-base = 0
        do-disc-sum-base = 0
        do-pay-sum-base = 0
        dh-chk-num = 0
        dh-gds-sum-rubl = 0
        dh-disc-sum-rubl = 0
        dh-pay-sum-rubl = 0
        dh-gds-sum-base = 0
        dh-disc-sum-base = 0
        dh-pay-sum-base = 0
        p-pay-sum-rubl = 0
        p-pay-sum-base = 0
        dh-chk-num = dis-host.num-chk
        dh-gds-sum-rubl = dis-host.gds-tot-rubl
        dh-disc-sum-rubl = dis-host.gds-dis-rubl
        dh-pay-sum-rubl = dis-host.pay-tot-rubl
        dh-gds-sum-base = dis-host.gds-tot-base
        dh-disc-sum-base =  dis-host.gds-dis-base
        dh-pay-sum-base = dis-host.pay-tot-base
        .
        FOR EACH ub.payment no-lock where
                 ub.payment.host-code = ub.dis-host.host-code AND
                 ub.payment.d-card = ub.dis-host.d-card and
                 ub.payment.status_ = 'факт':U:
        if ub.payment.source-type = 'касс':U
        or ub.payment.source-type = 'накл':U then next.
        ASSIGN
        p-pay-sum-rubl = p-pay-sum-rubl + ub.payment.tot-rubl
        p-pay-sum-base = p-pay-sum-base + ub.payment.tot-base
        .
      end.
      FOR  EACH ub.dis-obj no-lock where
             ub.dis-obj.host-code = ub.dis-host.host-code
         and ub.dis-obj.dt-code    = ub.dis-host.dt-code
         and ub.dis-obj.d-card   = ub.dis-host.d-card
         AND ub.dis-obj.obj-type = p-obj-type
         AND ub.dis-obj.obj-code = p-obj-code
         :
      ii = ii + 1.
      if ii MOD 100 = 0 then
      run waitfram-show in this-procedure ("Обработано " + string(ii) + " итогов по дисконтным картам на объекте").
      assign
      do-chk-num = do-chk-num + ub.dis-obj.num-chk
      do-gds-sum-rubl = do-gds-sum-rubl + ub.dis-obj.gds-tot-rubl + ub.dis-obj.sum-tot-rubl
      do-disc-sum-rubl = do-disc-sum-rubl + ub.dis-obj.gds-dis-rubl + ub.dis-obj.sum-dis-rubl
      do-pay-sum-rubl = do-pay-sum-rubl + ub.dis-obj.pay-tot-rubl
      do-gds-sum-base = do-gds-sum-base + ub.dis-obj.gds-tot-base + ub.dis-obj.sum-tot-base
      do-disc-sum-base = do-disc-sum-base + ub.dis-obj.gds-dis-base + ub.dis-obj.sum-dis-base
      do-pay-sum-base = do-pay-sum-base + ub.dis-obj.pay-tot-base
      .
    END.
    IF p-view-mode = 1
    or (abs(dh-pay-sum-rubl - (do-pay-sum-rubl + p-pay-sum-rubl)) > 0.005
    OR abs(dh-pay-sum-base - (do-pay-sum-base + p-pay-sum-base)) > 0.005)
    then
    PUT STREAM TEST UNFORMATTED
    dis-host.d-card format "X(16)" space(1)
    dis-host.host-code format "999999999" space(3)
    do-chk-num format "999999999" space(1)
    do-gds-sum-rubl format "->>>,>>>,>>9.99" space(1)
    do-gds-sum-base format "->>>,>>>,>>9.99" space(1)
    do-disc-sum-rubl format "->>>,>>>,>>9.99" space(1)
    do-disc-sum-base format "->>>,>>>,>>9.99" space(1)
    do-pay-sum-rubl format "->>>,>>>,>>9.99" space(1)
    do-pay-sum-base format "->>>,>>>,>>9.99" space(1)
    p-pay-sum-rubl  format "->>>,>>>,>>9.99" space(6)
    p-pay-sum-base  format "->>>,>>>,>>9.99" space(6)
    dh-chk-num format "999999999" space(1)
    dh-gds-sum-rubl format "->>>,>>>,>>9.99" space(1)
    dh-gds-sum-base format "->>>,>>>,>>9.99" space(1)
    dh-disc-sum-rubl format "->>>,>>>,>>9.99" space(1)
    dh-disc-sum-base format "->>>,>>>,>>9.99" space(1)
    dh-pay-sum-rubl format "->>>,>>>,>>9.99" space(1)
    dh-pay-sum-base format "->>>,>>>,>>9.99" space(1)
    dh-pay-sum-rubl - (do-pay-sum-rubl + p-pay-sum-rubl) format "->>>,>>>,>>9.99" space(1)
    dh-pay-sum-base - (do-pay-sum-base + p-pay-sum-base) format "->>>,>>>,>>9.99" space(1)
    skip.
  END.
end.
when 4 then do:
  FOR EACH ub.dis-obj No-LOCK
  BREAK
  by ub.dis-obj.host-code
  by ub.dis-obj.d-card:
    ii = ii + 1.
    if ii MOD 100 = 0 then
    run waitfram-show in this-procedure ("Обработано " + string(ii) + " итогов по дисконтным картам на объекте").
    IF FIRST-of(ub.dis-obj.d-card) then do:
      assign
      p-pay-sum-rubl = 0
      p-pay-sum-base = 0
      do-pay-sum-rubl = 0
      do-pay-sum-base = 0
      .
    END.
    if ub.dis-obj.dt-code = 0 then dO:
      assign
      do-pay-sum-rubl = do-pay-sum-rubl + ub.dis-obj.pay-tot-rubl
      do-pay-sum-base = do-pay-sum-base + ub.dis-obj.pay-tot-base
      .
    end.
    IF LAST-OF(ub.dis-obj.d-card) then do:
      FOR EACH ub.payment no-lock where
              ub.payment.host-code = ub.dis-obj.host-code AND
              ub.payment.d-card = entry(1, ub.dis-obj.d-card, chr(4)) and
              ub.payment.status_ = 'факт':U and
              ub.payment.source-type = 'касс':U:
        ASSIGN
        p-pay-sum-rubl = p-pay-sum-rubl + if ub.payment.tot-rubl = ? then 0 else ub.payment.tot-rubl
        p-pay-sum-base = p-pay-sum-base + if ub.payment.tot-base = ? then 0 else ub.payment.tot-base
        .
      end.
      FOR EACH ub.payment no-lock where
              ub.payment.host-code = ub.dis-obj.host-code AND
              ub.payment.d-card = entry(1, dis-obj.d-card, chr(4)) and
              ub.payment.status_ = 'факт':U and
              ub.payment.source-type = 'касс':U + chr(44) + "data-import"  :
        ASSIGN
        p-pay-sum-rubl = p-pay-sum-rubl + if ub.payment.tot-rubl = ? then 0 else ub.payment.tot-rubl
        p-pay-sum-base = p-pay-sum-base + if ub.payment.tot-base = ? then 0 else ub.payment.tot-base
        .
      end.
      FOR EACH ub.payment no-lock where
              ub.payment.host-code = ub.dis-obj.host-code AND
              ub.payment.d-card = entry(1, ub.dis-obj.d-card, chr(4)) and
              ub.payment.status_ = 'факт':U and
              ub.payment.source-type = 'накл':U:
        ASSIGN
        p-pay-sum-rubl = p-pay-sum-rubl + ub.payment.tot-rubl
        p-pay-sum-base = p-pay-sum-base + ub.payment.tot-base
        .
      end.
      FOR EACH ub.payment no-lock where
              ub.payment.host-code = ub.dis-obj.host-code AND
              ub.payment.d-card = entry(1, ub.dis-obj.d-card, chr(4)) and
              ub.payment.status_ = 'факт':U and
              ub.payment.source-type = 'накл':U + chr(44) + "data-import":U:
        ASSIGN
        p-pay-sum-rubl = p-pay-sum-rubl + ub.payment.tot-rubl
        p-pay-sum-base = p-pay-sum-base + ub.payment.tot-base
        .
      end.
      if p-view-mode = 1
      or ((do-pay-sum-rubl - p-pay-sum-rubl) <> 0
      or (do-pay-sum-base - p-pay-sum-base) <> 0) then
      PUT STREAM TEST UNFORMATTED
      ub.dis-obj.d-card format "X(16)" space(1)
      do-pay-sum-rubl format "->>>,>>>,>>9.99" space(1)
      do-pay-sum-base format "->>>,>>>,>>9.99" space(1)
      p-pay-sum-rubl  format "->>>,>>>,>>9.99" space(1)
      p-pay-sum-base  format "->>>,>>>,>>9.99" space(1)
      (do-pay-sum-rubl - p-pay-sum-rubl) format "->>>,>>>,>>9.99" space(1)
      (do-pay-sum-base - p-pay-sum-base) format "->>>,>>>,>>9.99" space(1)
      SKIP.
    END.
  end.
END.
WHEN 5 then do:
  FOR EACH ub.dis-card No-LOCK
  BREAK
  by ub.dis-card.d-card:
    ii = ii + 1.
    if ii MOD 100 = 0 then
    run waitfram-show in this-procedure ("Обработано " + string(ii) + " дисконтных карт").
    IF FIRST-of(dis-card.d-card) then do:
      assign
      dh-gds-sum-rubl = 0
      dh-disc-sum-rubl = 0
      dh-pay-sum-rubl = 0
      dh-gds-sum-base = 0
      dh-disc-sum-base = 0
      dh-pay-sum-base = 0
      .
      FOR EACH ub.dis-host No-LOCK
         WHERE ub.dis-host.d-card = ub.dis-card.d-card
             and ub.dis-host.host-code > 0
             and ub.dis-host.dt-code = 0
      break
      by ub.dis-host.host-code:
        assign
        dh-gds-sum-rubl = dh-gds-sum-rubl + dis-host.gds-tot-rubl
        dh-disc-sum-rubl = dh-disc-sum-rubl + dis-host.gds-dis-rubl
        dh-pay-sum-rubl = dh-pay-sum-rubl + dis-host.pay-tot-rubl
        dh-gds-sum-base = dh-gds-sum-base + dis-host.gds-tot-base
        dh-disc-sum-base = dh-disc-sum-base + dis-host.gds-dis-base
        dh-pay-sum-base = dh-pay-sum-base + dis-host.pay-tot-base
        .
        if dis-card.emitent-host-code = 0 and
        (abs((dis-host.gds-tot-rubl - dis-host.gds-dis-rubl) - dis-host.pay-tot-rubl ) > 0.001 OR
          abs((dis-host.gds-tot-base - dis-host.gds-dis-base) - dis-host.pay-tot-base) > 0.001
        ) then do:
          PUT stream test unformatted
          dis-card.d-card format "X(16)" space(1)
          dis-host.host-code format "999999999" space(3)
          dis-host.gds-tot-rubl format "->>>,>>>,>>9.99" space(1)
          dis-host.gds-tot-base format "->>>,>>>,>>9.99" space(1)
          dis-host.gds-dis-rubl format "->>>,>>>,>>9.99" space(1)
          dis-host.gds-dis-base format "->>>,>>>,>>9.99" space(1)
          dis-host.pay-tot-rubl format "->>>,>>>,>>9.99" space(1)
          dis-host.pay-tot-base format "->>>,>>>,>>9.99" space(3)
          ((dis-host.gds-tot-rubl - dis-host.gds-dis-rubl) - dis-host.pay-tot-rubl) format "->>>,>>>,>>9.99" space(1)
          ((dis-host.gds-tot-base - dis-host.gds-dis-base) - dis-host.pay-tot-base) format "->>>,>>>,>>9.99" space(1)
          "ОШИБКА глобкарта" format "X(15)" space(1)
          "!ненулевое сальдо" format "X(15)" space(3)
          SKIP.
        end.
      END.
      if p-view-mode = 1
      or (((dh-gds-sum-rubl - dh-disc-sum-rubl) - dh-pay-sum-rubl -  dis-card.saldo-rubl) <> 0
      OR ((dh-gds-sum-BASE - dh-disc-sum-base) - dh-pay-sum-base -  dis-card.saldo-base) <> 0)
      then
      PUT stream test unformatted
      dis-card.d-card format "X(16)" space(1)
      dis-card.emitent-host-code format "999999999" space(3)
      dh-gds-sum-rubl format "->>>,>>>,>>9.99" space(1)
      dh-gds-sum-base format "->>>,>>>,>>9.99" space(1)
      dh-disc-sum-rubl format "->>>,>>>,>>9.99" space(1)
      dh-disc-sum-base format "->>>,>>>,>>9.99" space(1)
      dh-pay-sum-rubl format "->>>,>>>,>>9.99" space(1)
      dh-pay-sum-base format "->>>,>>>,>>9.99" space(3)
      (dh-gds-sum-rubl - dh-disc-sum-rubl) - dh-pay-sum-rubl format "->>>,>>>,>>9.99" space(1)
      (dh-gds-sum-BASE - dh-disc-sum-base) - dh-pay-sum-base format "->>>,>>>,>>9.99" space(1)
      dis-card.saldo-rubl format "->>>,>>>,>>9.99" space(1)
      dis-card.saldo-base format "->>>,>>>,>>9.99" space(3)
      ((dh-gds-sum-rubl - dh-disc-sum-rubl) - dh-pay-sum-rubl -  dis-card.saldo-rubl) format "->>>,>>>,>>9.99" space(1)
      ((dh-gds-sum-BASE - dh-disc-sum-base) - dh-pay-sum-base -  dis-card.saldo-base) format "->>>,>>>,>>9.99" space(1)
      SKIP.
    END.
  END.
END.
when 7 then do:
  FOR EACH buf_dis-card No-LOCK where
    buf_Dis-card.emitent-host-code = dctype
,
   first buf_dis-card-type no-lock where
        buf_dis-card-type.type = buf_dis-card.type
    AND buf_dis-card-type.emitent-host-code = buf_dis-card.emitent-host-code
  :
      if NOT new-d-pcnt = old-d-pcnt
      or p-view-mode = 1 then do:
        PUT stream test unformatted
        buf_dis-card.d-card format "X(16)" space(1)
        buf_dis-card.type   format "X(8)" space(1)
        for-sum format "->>>,>>>,>>9.99" space(1)
        buf_dis-card.d-pcnt format "->,>>9.99" space(1)
        new-d-pcnt          format "->,>>9.99" space(1)
        skip.
      end.
    END.
  end.
 when 8 then do:
  run ref/proprefs.w (
                   input parparentproc
                  ,input 'b-sel'
                  ,input "dis-tot"
                  ,input 5
                  ,input '':U
                  ,input '':U
                  ,input-output  v-ref-list) no-error.
  if error-status:error or v-ref-list = '':u then do:
    return.
  end.
  find first buf_prop-ref no-lock where
           recid(buf_prop-ref) = integer(v-ref-list).
  assign
  v-dt-code = buf_prop-ref.dt-code
  v-sum-id =  buf_prop-ref.sum-id
  .
  assign
  v-date-from =  date(entry(1, buf_prop-ref.sum-id, "-"))
  v-date-to =  date(entry(2, buf_prop-ref.sum-id, "-"))
  .
  PUT stream test unformatted
  substitute("Идентификатор частного итога &1 Доп.идентификатор &2"
              ,v-sum-id
              ,buf_prop-ref.caller_id
              ) skip.
  FOR EACH buf_dis-card No-LOCK where
     true
     :
     for each buf_clients no-lock where
            buf_clients.obj-type = 'маг':U
       and buf_clients.obj-code = p-obj-code
       and  (v-cntxt-db-num = 0 or buf_clients.db-num = v-cntxt-db-num):
      assign
      v-chk-num = 0
      v-netto-sum = 0.
        _buf_chk-doc:
        for each buf_chk-doc no-lock where
          buf_chk-doc.d-card = buf_dis-card.d-card
          and buf_chk-doc.obj-type = buf_clients.obj-type
          and buf_chk-doc.obj-code = buf_clients.obj-code
          and buf_chk-doc.chk-date >= v-date-from
          and buf_chk-doc.chk-date <= v-date-to
          :
          assign
          v-chk-num = v-chk-num  + 1
          v-netto-sum  = v-netto-sum + buf_chk-doc.netto
          .
        end.
      find first buf_dis-obj no-lock where
                buf_dis-obj.obj-type = buf_clients.obj-type
            and buf_dis-obj.obj-code = buf_clients.obj-code
            and buf_dis-obj.d-card = buf_dis-card.d-card
            and buf_dis-obj.dt-code = v-dt-code no-error .
      if not available buf_dis-obj then do:
        assign
        v-chk-num-do = 0
        v-netto-sum-do = 0
        .
      end.
      else do:
        assign
        v-chk-num-do = buf_dis-obj.num-chk
        v-netto-sum-do = (if v-curr-r-b = 'rubl':U
                       then (buf_dis-obj.gds-tot-rubl - buf_dis-obj.gds-dis-rubl)
                       else (buf_dis-obj.gds-tot-base - buf_dis-obj.gds-dis-base)
                       )
        .
      end.
      if v-chk-num <> v-chk-num-do
      or p-view-mode = 1
      then do:
          PUT stream test unformatted
          string(p-obj-type + string(buf_clients.obj-code), "X(20)") space(1)
          buf_dis-card.d-card format "X(16)" space(1)
          v-chk-num   format ">>>>>>>>>" space(10)
          v-chk-num-do   format ">>>>>>>>>" space(10)
          v-netto-sum    format ">>>,>>>,>>>,>>9.999" space(1)
          v-netto-sum-do format ">>>,>>>,>>>,>>9.999" space(1)
          skip.
      end.
    end.
  end.
end.
  when 99 then do:
    FOR EACH buf_dis-card No-LOCK where
    buf_Dis-card.emitent-host-code = dctype
   AND buf_dis-card.d-card =  f-d-card
     :
      v-chk-num = 0.
     for each buf_clients no-lock where
            buf_clients.obj-type = 'маг':U
       and buf_clients.obj-code = p-obj-code
       and  (v-cntxt-db-num = 0 or buf_clients.db-num = v-cntxt-db-num):
      for each buf_chk-doc no-lock where
        buf_chk-doc.d-card = buf_dis-card.d-card
        and buf_chk-doc.obj-type = buf_clients.obj-type
        and buf_chk-doc.obj-code = buf_clients.obj-code:
        assign
        v-chk-num = v-chk-num  + 1
        .
      end.
        find first buf_dis-obj no-lock where
                  buf_dis-obj.obj-type = buf_clients.obj-type
              and buf_dis-obj.obj-code = buf_clients.obj-code
              and buf_dis-obj.d-card = buf_dis-card.d-card
              and buf_dis-obj.dt-code = 0  no-error .
        if not available buf_dis-obj then do:
          assign
          v-chk-num-do = 0.
        end.
        else do:
          assign
          v-chk-num-do = buf_dis-obj.num-chk.
        end.
        if v-chk-num <> v-chk-num-do
        or p-view-mode = 1
        then do:
          PUT stream test unformatted
          string(buf_clients.obj-type + string(buf_clients.obj-code), "X(20)") space(1)
          buf_dis-card.d-card format "X(16)" space(1)
          v-chk-num   format ">>>>>>>>>" space(10)
          v-chk-num-do   format ">>>>>>>>>" space(10)
          skip.
        end.
      end.
    end.
  end.
END CASE.
end.
else do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CASE test-number:
  when 1 then do:
_chk-doc:
    FOR EACH buf_dis-card NO-LOCK where
            buf_dis-card.d-card = f-d-card,
        EACH buf_shop no-lock,
        EACH buf_chk-doc NO-LOCK where
            buf_chk-doc.obj-type = 'маг':U AND
            buf_chk-doc.obj-code = buf_shop.obj-code AND
            buf_chk-doc.d-card = buf_dis-card.d-card
        break by buf_chk-doc.obj-type
              by buf_chk-doc.obj-code
              by buf_chk-doc.d-card:
        ii = ii + 1.
        if ii MOD 100 = 0 then
        run waitfram-show in this-procedure ("Обработано " + string(ii) + " чеков по дисконтным картам").
        IF FIRST-OF(buf_chk-doc.obj-code) then do:
          find first buf_sysconf where
                      buf_sysconf.host-code = buf_shop.host-code no-lock No-ERROR.
          if not avail buf_sysconf then do:
            run waitfram-hide in this-procedure .
            message "Не найдена запись о фирме номер " buf_shop.host-code
            view-as alert-box
            ERROR.
            return.
          end.
          find first buf_Cash-pay no-lock where
                  buf_cash-pay.cdpay-code = buf_sysconf.credit-pay no-error.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'iscredit'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
          if error-status:error
          or not available buf_cash-pay
          or buf_cash-pay.is-credit = no
          or conf-par <> "yes"
          then do:
            assign
            cre-pay = 0
            .
          end.
          else do:
            assign
            cre-pay = buf_sysconf.credit-pay
            .
          end.
          assign
          v-base-code = buf_sysconf.base-code
          .
        end.
        if buf_chk-doc.out-code = ? then next.
        if LOOKUP(string(buf_chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,69,101,106,108,169,196,114,115,116,117,111,112,136,113,101,106,108,208,2,3,4,5,7,43,44':U) > 0 then NEXT.
        FIND FIRST buf_inkas No-LOCK WHERE
                    buf_inkas.inkas-code = buf_chk-doc.out-code No-ERROR.
        if not avail buf_inkas then next.
        find first temp-inkas no-lock where
                  temp-inkas.inkas-code = buf_Inkas.inkas-code no-error .
        find first buf_trn-doc no-lock where
                  buf_trn-doc.doc-code = buf_inkas.inkas-code no-error .
        if not available buf_trn-doc then do:
        end.
        find first buf_ret-doc no-lock where
                  buf_ret-doc.doc-code = buf_trn-doc.out-code no-error .
        if not available buf_ret-doc then do:
        end.
        if available buf_inkas
        and buf_inkas.status_ = 'факт':U
        and buf_inkas.obj-type = 'маг':U
        and not available temp-inkas
        then do:
          create temp-inkas.
          assign
          temp-inkas.inkas-code = buf_inkas.inkas-code
          rabota = yes.
        end.
        else do:
          rabota = no.
        end.
        if rabota then do:
            run waitfram-show in this-procedure ("Обработка отчета о продаже " + buf_inkas.inkas-code).
          par-sign = 1.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  _cards:
  for each ub.chk-doc no-lock
    where ub.chk-doc.obj-type = buf_inkas.obj-type
      AND ub.chk-doc.obj-code = buf_inkas.obj-code
      AND ub.chk-doc.out-code = buf_inkas.inkas-code
      and ub.chk-doc.d-card > ""
  on error undo _main, return error
  :
  if lookup(string(ub.chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,69,101,106,108,169,196,114,115,116,117,111,112,136,113,101,106,108,208,2,3,4,5,7,43,44':U) > 0 then next _cards.
    find first temp-d-card where
              temp-d-card.d-card = ub.chk-doc.d-card
          AND temp-d-card.obj-type = ub.chk-doc.obj-type
          AND temp-d-card.obj-code = ub.chk-doc.obj-code  no-error .
    if not available temp-d-card then do:
      find first ub.dis-card no-lock
        where ub.dis-card.d-card = ub.chk-doc.d-card
        no-error .
      if not avail dis-card then do:
        next _cards.
      end.
      FIND FIRST ub.clients WHERE
                  ub.clients.obj-type = ub.dis-card.cli-type AND
                  ub.clients.obj-code = ub.dis-card.cli-code No-ERROR.
      if not avail ub.clients then do:
        undo _main, return error "Не найден клиент для дисконтной карты " + ub.dis-card.d-card.
      end.
      assign
        ub.clients.buy-gds = ub.clients.buy-gds OR ( NOT buf_inkas.office )
        ub.clients.buy-serv = ub.clients.buy-serv OR buf_inkas.office
      .
      create temp-d-card.
      assign
      temp-d-card.d-card = ub.chk-doc.d-card
      temp-d-card.pay-tot-base = 0
      temp-d-card.pay-tot-rubl = 0
      temp-d-card.gds-tot-b0 = 0
      temp-d-card.gds-tot-r0 = 0
      temp-d-card.first-main-card   = ub.dis-card.first-main-card
      temp-d-card.main-card         = ub.dis-card.main-card
      temp-d-card.first-card        = ub.dis-card.first-card
      temp-d-card.cli-type          = ub.dis-card.cli-type
      temp-d-card.cli-code          = ub.dis-card.cli-code
      temp-d-card.card-num          = ub.dis-card.card-num
      temp-d-card.emitent-host-code = ub.dis-card.emitent-host-code
      temp-d-card.type              = ub.dis-card.type
      temp-d-card.obj-type          = ub.chk-doc.obj-type
      temp-d-card.obj-code          = ub.chk-doc.obj-code
      temp-d-card.host-code         = buf_inkas.host-code
      temp-d-card.sale-doc          = buf_inkas.inkas-code
      temp-d-card.sale-type         = 'inkas':U
      temp-d-card.doc-date          = ub.chk-doc.chk-date
      temp-d-card.action            = sign
      .
    end.
    FOR EACH ub.chk-gds WHERE
              ub.chk-gds.doc-code = ub.chk-doc.doc-code AND
              ub.chk-gds.b-code <> 0 NO-LOCK ,
        FIRST ub.bar-code where
              ub.bar-code.b-code = ub.chk-gds.b-code No-LOCK,
        FIRST ub.goods where
              ub.goods.gds-code = ub.bar-code.gds-code No-LOCK,
        FIRST ub.doc-line WHERE
              ub.doc-line.doc-code = (if ub.chk-doc.netto >= 0 then buf_trn-doc.doc-code else ret-doc-code) AND
              ub.doc-line.prod-code = ub.goods.prod-code AND
              ub.doc-line.prod-type = ub.goods.prod-type AND
              ub.doc-line.artic = ub.goods.artic NO-LOCK
              On error undo _main, return error
              :
      if ub.chk-gds.write-off-code <> ?
      and ub.chk-gds.write-off-code > 0 then NEXT.
      assign
      temp-d-card.gds-tot-r0 = temp-d-card.gds-tot-r0 +  par-sign * ( ub.doc-line.price-rubl * ub.chk-gds.doc-qnty )
      temp-d-card.gds-tot-b0 = temp-d-card.gds-tot-b0 +  par-sign * ( ub.doc-line.price-base * ub.chk-gds.doc-qnty )
      .
    END.
    assign
    accum-tot-base = 0
    accum-tot-rubl = 0
    accum-cre-pay-base =0
    accum-cre-pay-rubl =0
    .
    FOR EACH ub.chk-pay WHERE
             ub.chk-pay.doc-code = ub.chk-doc.doc-code NO-LOCK
    On error undo _main, return error
    :
        if ub.chk-pay.pay-code = cre-pay
          then
        assign
        cre-pay-base = ub.chk-pay.tot-base
        cre-pay-rubl   = ub.chk-pay.tot-rubl .
          else
        assign
        cre-pay-base = 0
        cre-pay-rubl   = 0 .
        Assign
        accum-tot-rubl     = accum-tot-rubl +  ub.chk-pay.tot-rubl
        accum-tot-base     = accum-tot-base +  ub.chk-pay.tot-base
        accum-cre-pay-base = accum-cre-pay-base +  cre-pay-base
        accum-cre-pay-rubl = accum-cre-pay-rubl +  cre-pay-rubl
        .
        if v-cntxt-db-num = 0 and ub.chk-pay.pay-code <> cre-pay then do:
          FIND FIRST vchk-pay No-LOCK WHERE
                      vchk-pay.d-card = ub.chk-doc.d-card AND
                      vchk-pay.pay-code = ub.chk-pay.pay-code AND
                      vchk-pay.curr-code = ub.chk-pay.curr-code AND
                      vchk-pay.doc-date = ub.chk-pay.chk-date AND
                      vchk-pay.cre-pay = (ub.chk-pay.pay-code = cre-pay) AND
                      vchk-pay.exch-rate = (ub.chk-pay.tot-sum / chk-pay.tot-rubl) AND
                    vchk-pay.base-rate = (ub.chk-pay.tot-rubl / chk-pay.tot-base ) No-ERROR.
          IF NOT AVAIL vchk-pay then do:
            create vchk-pay.
            assign
            vchk-pay.d-card   = ub.chk-doc.d-card
            vchk-pay.doc-date = ub.chk-pay.chk-date
            vchk-pay.pay-code = ub.chk-pay.pay-code
            vchk-pay.curr-code = ub.chk-pay.curr-code
            vchk-pay.cre-pay = (ub.chk-pay.pay-code = cre-pay)
            vchk-pay.exch-rate =  (ub.chk-pay.tot-sum / ub.chk-pay.tot-rubl)
            vchk-pay.base-rate = (ub.chk-pay.tot-rubl / ub.chk-pay.tot-base)
            .
          end.
          assign
          vchk-pay.tot-sum  = vchk-pay.tot-sum  + ub.chk-pay.tot-sum
          vchk-pay.tot-base = vchk-pay.tot-base + ub.chk-pay.tot-base
          vchk-pay.tot-rubl = vchk-pay.tot-rubl + ub.chk-pay.tot-rubl
          .
      END.
    END .
    assign
    temp-d-card.pay-tot-base = temp-d-card.pay-tot-base + par-sign * (ACCUM-tot-base -  ACCUM-cre-pay-base)
    temp-d-card.pay-tot-rubl = temp-d-card.pay-tot-rubl + par-sign * (ACCUM-tot-rubl -  ACCUM-cre-pay-rubl)
    .
    if v-base-code = 0 then
    chk-exch =  1.
    else do:
      v-rate = ?.
      if v-curr-r-b = 'base':U then do:
        assign
        v-rate = ub.chk-doc.cash-rate / ub.chk-doc.cash-scale
        no-error
        .
        if v-rate <> 0
        and v-rate <> ? then do:
          chk-exch = v-rate.
        end.
        else do:
          assign
          v-rate = ACCUM-tot-rubl  / ACCUM-tot-base
          no-error
          .
          if v-rate <> ?
          and v-rate <> 0 then do:
            chk-exch = v-rate.
          end.
          else do:
              undo _main, return error substitute("&1&2 Невозможно определить курс базовой валюты для чека &3 по ДК &4"
                                                  , vss-description
                                                  , chr(10)
                                                  , chk-doc.doc-code
                                                  , chk-doc.d-card).
          end.
        end.
      end.
      else do:
        assign
        v-rate = ACCUM-tot-rubl  / ACCUM-tot-base
        no-error
        .
        if v-rate <> ?
        and v-rate <> 0 then do:
          chk-exch = v-rate.
        end.
        else do:
          FIND LAST buf_curr-shop NO-LOCK WHERE
                    buf_curr-shop.obj-type = ub.chk-doc.obj-type AND
                    buf_curr-shop.obj-code = ub.chk-doc.obj-code AND
                    buf_curr-shop.curr-code = v-base-code AND
                    ( ( buf_curr-shop.exch-date = ub.chk-doc.chk-date AND
                        buf_curr-shop.exch-time <= ub.chk-doc.chk-time ) OR
                        buf_curr-shop.exch-date < ub.chk-doc.chk-date ) NO-ERROR .
          if available buf_curr-shop then do:
            assign
            v-rate = buf_Curr-shop.exch-rate / buf_curr-shop.exch-scale
            no-error .
            if v-rate <> ?
            and v-rate <> 0 then do:
              chk-exch = v-rate.
            end.
            else do:
                undo _main, return error substitute("&1&2 Невозможно определить курс базовой валюты для чека &3 по ДК &4"
                                                    , vss-description
                                                    , chr(10)
                                                    , chk-doc.doc-code
                                                    , chk-doc.d-card).
            end.
          end.
        end.
      end.
    end.
    assign
    chk-exch-rubl = (if v-curr-r-b = 'rubl':U then 1 else chk-exch)
    chk-exch-base = (if v-curr-r-b = 'base':U then 1 else chk-exch )
    .
    Assign
    temp-d-card.sum-tot-r-b = temp-d-card.sum-tot-r-b + 0
    temp-d-card.sum-tot-rubl = temp-d-card.sum-tot-rubl + 0
    temp-d-card.sum-tot-base = temp-d-card.sum-tot-base + 0
    temp-d-card.gds-tot-r-b  = temp-d-card.gds-tot-r-b  + par-sign * ub.chk-doc.tot-doc
    temp-d-card.gds-tot-rubl = temp-d-card.gds-tot-rubl + par-sign * ub.chk-doc.tot-doc * chk-exch-rubl
    temp-d-card.gds-tot-base = temp-d-card.gds-tot-base + par-sign * ub.chk-doc.tot-doc / chk-exch-base
    temp-d-card.gds-dis-r-b  = temp-d-card.gds-dis-r-b  + par-sign * ub.chk-doc.discnt
    temp-d-card.gds-dis-rubl = temp-d-card.gds-dis-rubl + par-sign * ub.chk-doc.discnt * chk-exch-rubl
    temp-d-card.gds-dis-base = temp-d-card.gds-dis-base + par-sign * ub.chk-doc.discnt / chk-exch-base
    temp-d-card.num-chk      = temp-d-card.num-chk      + par-sign * 1
    .
    run ref/calctur4.p ( input ub.chk-doc.doc-code ) .
 END.
        end.
    END.
    for each buf_Dis-obj no-lock where
            buf_dis-obj.d-card = f-d-card
        and buf_dis-obj.dt-code = 0,
       first buf_dis-card no-lock where
            buf_dis-card.d-card = buf_dis-obj.d-card
    by buf_dis-obj.d-card
    by buf_dis-obj.dt-code
    by buf_dis-obj.obj-type
    by buf_dis-obj.obj-code:
      for each bf_trn-doc no-lock where
          bf_trn-doc.obj-type = buf_dis-obj.obj-type
      AND bf_trn-doc.obj-code = buf_dis-obj.obj-code
      AND bf_trn-doc.cli-type = buf_dis-card.cli-type
      AND bf_trn-doc.cli-code = buf_dis-card.cli-code:
      run waitfram-show in this-procedure ( substitute( "Обработка накладных по карте &1", buf_dis-obj.d-card )).
      if bf_trn-doc.d-card <> "":U then do:
        find first temp-d-card where
                  temp-d-card.d-card = bf_trn-doc.d-card
              AND temp-d-card.obj-type = bf_trn-doc.obj-type
              AND temp-d-card.obj-code = bf_trn-doc.obj-code
              no-error .
        if not available temp-d-card then do:
          create temp-d-card.
          assign
          temp-d-card.d-card            = buf_dis-card.d-card
          temp-d-card.card-num          = buf_dis-card.card-num
          temp-d-card.emitent-host-code = buf_dis-card.emitent-host-code
          temp-d-card.type              = buf_dis-card.type
          temp-d-card.cli-type          = buf_dis-card.cli-type
          temp-d-card.cli-code          = buf_dis-card.cli-code
          temp-d-card.obj-type = bf_trn-doc.obj-type
          temp-d-card.obj-code = bf_trn-doc.obj-code
          .
        end.
        assign
        p-doc-code = bf_trn-doc.doc-code
        .
        assign
        p-sign = 1
        p-direction =  if bf_trn-doc.ext-doc-type = 're':U
                      then -1
                      else  1
        par-sign = 1
        par-direction =  if bf_trn-doc.ext-doc-type = 're':U
                      then -1
                      else  1
        .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-cntxt-db-num = 0 then do:
  FOR EACH buf_doc-line no-lock where
          buf_doc-line.doc-code = p-doc-code
     On error undo _main, return error:
    run r-sale in this-procedure (
                                    input p-doc-code
                                   ,input buf_doc-line.artic
                                   ,input buf_doc-line.prod-type
                                   ,input buf_doc-line.prod-code
                                   ,output v-fact-qnty
                                   ,output v-vat-pc
                                   ,output v-slt-pc
                                   ,output v-sum-base
                                   ,output v-sum-rubl
                                   ,output v-vat-base
                                   ,output v-vat-rubl
                                   ,output v-slt-base
                                   ,output v-slt-rubl
                                   ,output v-road-tax-base
                                   ,output v-road-tax-rubl
                                   ,output v-transport-base
                                   ,output v-transport-rubl
                                   ,output v-other-base
                                   ,output v-other-rubl
                                   ,output v-excise-base
                                   ,output v-excise-rubl
                                    ) .
      assign
      temp-d-card.pay-tot-rubl = temp-d-card.pay-tot-rubl + par-direction * par-sign * abs( v-sum-rubl)
      temp-d-card.pay-tot-base = temp-d-card.pay-tot-base + par-direction * par-sign * abs( v-sum-base)
      temp-d-card.gds-tot-rubl = temp-d-card.gds-tot-rubl + par-direction * par-sign * abs( (v-sum-rubl + v-other-rubl))
      temp-d-card.gds-tot-base = temp-d-card.gds-tot-base + par-direction * par-sign * abs( (v-sum-base + v-other-base))
      temp-d-card.gds-dis-rubl = temp-d-card.gds-dis-rubl + par-direction * par-sign * abs( v-other-rubl)
      temp-d-card.gds-dis-base = temp-d-card.gds-dis-base + par-direction * par-sign * abs( v-other-base)
      .
      run r-cost in this-procedure (
                                    input p-doc-code
                                   ,input buf_doc-line.artic
                                   ,input buf_doc-line.prod-type
                                   ,input buf_doc-line.prod-code
                                   ,output v-fact-qnty
                                   ,output v-vat-pc
                                   ,output v-slt-pc
                                   ,output v-sum-base
                                   ,output v-sum-rubl
                                   ,output v-vat-base
                                   ,output v-vat-rubl
                                   ,output v-slt-base
                                   ,output v-slt-rubl
                                   ,output v-road-tax-base
                                   ,output v-road-tax-rubl
                                   ,output v-transport-base
                                   ,output v-transport-rubl
                                   ,output v-other-base
                                   ,output v-other-rubl
                                   ,output v-excise-base
                                   ,output v-excise-rubl
                                    ) .
    assign
    temp-d-card.gds-tot-r0 = temp-d-card.gds-tot-r0 + par-direction * par-sign * abs( v-sum-rubl)
    temp-d-card.gds-tot-b0 = temp-d-card.gds-tot-b0 + par-direction * par-sign * abs( v-sum-base)
    .
  END.
end.
if v-curr-r-b = 'base':U then
assign
temp-d-card.gds-tot-r-b = temp-d-card.gds-tot-base
temp-d-card.gds-dis-r-b = temp-d-card.gds-dis-base
temp-d-card.sum-tot-r-b = temp-d-card.sum-tot-base
.
else
assign
temp-d-card.gds-tot-r-b = temp-d-card.gds-tot-rubl
temp-d-card.gds-dis-r-b = temp-d-card.gds-dis-rubl
temp-d-card.sum-tot-r-b = temp-d-card.sum-tot-rubl
.
  find first vchk-pay no-lock where
            vchk-pay.d-card   = temp-d-card.d-card
        AND vchk-pay.pay-code = bf_trn-doc.pay-code
        AND vchk-pay.curr-code = bf_trn-doc.exch-code
        AND vchk-pay.doc-date  = 01/01/1990
        AND vchk-pay.cre-pay   = (cre-pay = bf_trn-doc.pay-code) no-error .
  if not available vchk-pay then do:
    create vchk-pay.
    assign
    vchk-pay.d-card   = temp-d-card.d-card
    vchk-pay.doc-date = bf_trn-doc.exch-date
    vchk-pay.pay-code = bf_trn-doc.pay-code
    vchk-pay.curr-code = bf_trn-doc.exch-code
    vchk-pay.cre-pay   =  no
    vchk-pay.exch-rate = bf_trn-doc.exch-rate
    vchk-pay.base-rate = bf_trn-doc.base-rate
    vchk-pay.tot-base =  temp-d-card.pay-tot-base
    vchk-pay.tot-rubl =  temp-d-card.pay-tot-rubl
    vchk-pay.tot-sum =  (if bf_trn-doc.exch-code = 0 then temp-d-card.pay-tot-rubl else temp-d-card.pay-tot-base)
    .
  end.
      end.
      end.
    end.
    for each temp-d-card
    where temp-d-card.d-card = f-d-card
    break
    by temp-d-card.d-card
    by temp-d-card.obj-type
    by temp-d-card.obj-code:
      run waitfram-show in this-procedure ( substitute( "Окончательная обработка результатов и вывод в файл - карта &1", temp-d-card.d-card )).
        assign
        do-obj-code = temp-d-card.obj-code
        do-chk-num = 0
        do-gds-sum-rubl = 0
        do-disc-sum-rubl = 0
        do-pay-sum-rubl = 0
        do-gds-sum-base = 0
        do-disc-sum-base = 0
        do-pay-sum-base = 0
        .
      For each buf_dis-obj No-LOCK WHERE
                  buf_dis-obj.d-card = temp-d-card.d-card
              AND buf_dis-obj.dt-code = 0
              and buf_dis-obj.obj-type = temp-d-card.obj-type
              and buf_dis-obj.obj-code = temp-d-card.obj-code:
        assign
        do-obj-code      = buf_dis-obj.obj-code
        do-chk-num       = buf_dis-obj.num-chk
        do-gds-sum-rubl  = buf_dis-obj.gds-tot-rubl - buf_dis-obj.sum-tot-rubl
        do-disc-sum-rubl = buf_dis-obj.gds-dis-rubl - buf_dis-obj.sum-dis-rubl
        do-pay-sum-rubl  = buf_dis-obj.pay-tot-rubl
        do-gds-sum-base  = buf_dis-obj.gds-tot-base - buf_dis-obj.sum-tot-base
        do-disc-sum-base = buf_dis-obj.gds-dis-base - buf_dis-obj.sum-dis-base
        do-pay-sum-base  = buf_dis-obj.pay-tot-base
        .
      end.
      if p-view-mode = 1
      or (do-chk-num <> temp-d-card.num-chk
      OR do-gds-sum-rubl <> temp-d-card.gds-tot-rubl
      OR do-disc-sum-rubl <> temp-d-card.gds-dis-rubl
      OR do-pay-sum-rubl <> temp-d-card.pay-tot-rubl
      OR do-gds-sum-base <> temp-d-card.gds-tot-base
      OR do-disc-sum-base <> temp-d-card.gds-dis-base
      OR do-pay-sum-base <> temp-d-card.pay-tot-base)
      then
      PUT STREAM TEST UNFORMATTED
      temp-d-card.d-card format "X(16)" space(1)
      do-obj-code format ">>>>9" space(1)
      do-chk-num format ">>>>>>>>>9" space(1)
      do-gds-sum-rubl format "->>>,>>>,>>9.99" space(1)
      do-disc-sum-rubl format "->>>,>>>,>>9.99" space(1)
      do-pay-sum-rubl format "->>>,>>>,>>9.99" space(1)
      do-gds-sum-base format "->>>,>>>,>>9.99" space(1)
      do-disc-sum-base format "->>>,>>>,>>9.99" space(1)
      do-pay-sum-base format "->>>,>>>,>>9.99" skip(0)
      "По чекам  и накладным"  format "X(22)" space(1)
      temp-d-card.num-chk  format ">>>>>>>>>9" space(1)
      temp-d-card.gds-tot-rubl format "->>>,>>>,>>9.99" space(1)
      temp-d-card.gds-dis-rubl format "->>>,>>>,>>9.99" space(1)
      temp-d-card.pay-tot-rubl format "->>>,>>>,>>9.99" space(1)
      temp-d-card.gds-tot-base format "->>>,>>>,>>9.99" space(1)
      temp-d-card.gds-dis-base format "->>>,>>>,>>9.99" space(1)
      temp-d-card.pay-tot-base format "->>>,>>>,>>9.99" space(1)
      skip(0)
      .
    end.
  end.
  when 6 then do:
    run gbl/get-per.w (
                    output v-ok
                   ,input-output x_start-date
                   ,input-output x_end-date
                                      ) no-error .
    if not v-ok then return.
    for each buf_sysconf,
       each buf_inkas no-lock where
            buf_Inkas.host-code = buf_sysconf.host-code
        AND buf_Inkas.doc-date >= x_start-date
        AND buf_Inkas.doc-date <= x_end-date
        AND buf_Inkas.status_ = 'факт':U
    break
    by buf_inkas.obj-type
    by buf_inkas.obj-code
    :
      IF FIRST-OF(buf_inkas.obj-code) then do:
        find first buf_shop no-lock where
                  buf_shop.obj-code = buf_inkas.obj-code No-ERROR.
        if not avail buf_shop then do:
          run waitfram-hide in this-procedure .
          message "Не найдена запись о магазине номер " buf_inkas.obj-code view-as alert-box
          ERROR.
          return.
        end.
        find first buf_Cash-pay no-lock where
                buf_cash-pay.cdpay-code = buf_sysconf.credit-pay no-error.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'iscredit'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
        if error-status:error
        or not available buf_cash-pay
        or buf_cash-pay.is-credit = no
        or conf-par <> "yes"
        then do:
          assign
          cre-pay = 0
          .
        end.
        else do:
          assign
          cre-pay = buf_sysconf.credit-pay
          .
        end.
        assign
        v-base-code = buf_sysconf.base-code
        .
      end.
      find first temp-inkas no-lock where
                temp-inkas.inkas-code = buf_Inkas.inkas-code no-error .
      find first buf_trn-doc no-lock where
                buf_trn-doc.doc-code = buf_inkas.inkas-code no-error .
      if not available buf_trn-doc
      or buf_trn-doc.status_ = 'запрос':U
      then do:
        nExt .
      end.
      find first buf_ret-doc no-lock where
                buf_ret-doc.doc-code = buf_trn-doc.out-code no-error .
      if not available buf_ret-doc then do:
        nExt .
      end.
      ii = ii + 1.
      run waitfram-show in this-procedure ("Обработано " + string(ii) + " продаж").
      for each temp-d-card:
        delete temp-d-card.
      end.
      for each vchk-pay:
        delete vchk-pay.
      end.
      run waitfram-show in this-procedure ("Обработка отчета о продаже " + buf_inkas.inkas-code).
      par-sign = 1.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  _cards:
  for each ub.chk-doc no-lock
    where ub.chk-doc.obj-type = buf_inkas.obj-type
      AND ub.chk-doc.obj-code = buf_inkas.obj-code
      AND ub.chk-doc.out-code = buf_inkas.inkas-code
      and ub.chk-doc.d-card > ""
  on error undo _main, return error
  :
  if lookup(string(ub.chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,69,101,106,108,169,196,114,115,116,117,111,112,136,113,101,106,108,208,2,3,4,5,7,43,44':U) > 0 then next _cards.
    find first temp-d-card where
              temp-d-card.d-card = ub.chk-doc.d-card
          AND temp-d-card.obj-type = ub.chk-doc.obj-type
          AND temp-d-card.obj-code = ub.chk-doc.obj-code  no-error .
    if not available temp-d-card then do:
      find first ub.dis-card no-lock
        where ub.dis-card.d-card = ub.chk-doc.d-card
        no-error .
      if not avail dis-card then do:
        next _cards.
      end.
      FIND FIRST ub.clients WHERE
                  ub.clients.obj-type = ub.dis-card.cli-type AND
                  ub.clients.obj-code = ub.dis-card.cli-code No-ERROR.
      if not avail ub.clients then do:
        undo _main, return error "Не найден клиент для дисконтной карты " + ub.dis-card.d-card.
      end.
      assign
        ub.clients.buy-gds = ub.clients.buy-gds OR ( NOT buf_inkas.office )
        ub.clients.buy-serv = ub.clients.buy-serv OR buf_inkas.office
      .
      create temp-d-card.
      assign
      temp-d-card.d-card = ub.chk-doc.d-card
      temp-d-card.pay-tot-base = 0
      temp-d-card.pay-tot-rubl = 0
      temp-d-card.gds-tot-b0 = 0
      temp-d-card.gds-tot-r0 = 0
      temp-d-card.first-main-card   = ub.dis-card.first-main-card
      temp-d-card.main-card         = ub.dis-card.main-card
      temp-d-card.first-card        = ub.dis-card.first-card
      temp-d-card.cli-type          = ub.dis-card.cli-type
      temp-d-card.cli-code          = ub.dis-card.cli-code
      temp-d-card.card-num          = ub.dis-card.card-num
      temp-d-card.emitent-host-code = ub.dis-card.emitent-host-code
      temp-d-card.type              = ub.dis-card.type
      temp-d-card.obj-type          = ub.chk-doc.obj-type
      temp-d-card.obj-code          = ub.chk-doc.obj-code
      temp-d-card.host-code         = buf_inkas.host-code
      temp-d-card.sale-doc          = buf_inkas.inkas-code
      temp-d-card.sale-type         = 'inkas':U
      temp-d-card.doc-date          = ub.chk-doc.chk-date
      temp-d-card.action            = sign
      .
    end.
    FOR EACH ub.chk-gds WHERE
              ub.chk-gds.doc-code = ub.chk-doc.doc-code AND
              ub.chk-gds.b-code <> 0 NO-LOCK ,
        FIRST ub.bar-code where
              ub.bar-code.b-code = ub.chk-gds.b-code No-LOCK,
        FIRST ub.goods where
              ub.goods.gds-code = ub.bar-code.gds-code No-LOCK,
        FIRST ub.doc-line WHERE
              ub.doc-line.doc-code = (if ub.chk-doc.netto >= 0 then buf_trn-doc.doc-code else ret-doc-code) AND
              ub.doc-line.prod-code = ub.goods.prod-code AND
              ub.doc-line.prod-type = ub.goods.prod-type AND
              ub.doc-line.artic = ub.goods.artic NO-LOCK
              On error undo _main, return error
              :
      if ub.chk-gds.write-off-code <> ?
      and ub.chk-gds.write-off-code > 0 then NEXT.
      assign
      temp-d-card.gds-tot-r0 = temp-d-card.gds-tot-r0 +  par-sign * ( ub.doc-line.price-rubl * ub.chk-gds.doc-qnty )
      temp-d-card.gds-tot-b0 = temp-d-card.gds-tot-b0 +  par-sign * ( ub.doc-line.price-base * ub.chk-gds.doc-qnty )
      .
    END.
    assign
    accum-tot-base = 0
    accum-tot-rubl = 0
    accum-cre-pay-base =0
    accum-cre-pay-rubl =0
    .
    FOR EACH ub.chk-pay WHERE
             ub.chk-pay.doc-code = ub.chk-doc.doc-code NO-LOCK
    On error undo _main, return error
    :
        if ub.chk-pay.pay-code = cre-pay
          then
        assign
        cre-pay-base = ub.chk-pay.tot-base
        cre-pay-rubl   = ub.chk-pay.tot-rubl .
          else
        assign
        cre-pay-base = 0
        cre-pay-rubl   = 0 .
        Assign
        accum-tot-rubl     = accum-tot-rubl +  ub.chk-pay.tot-rubl
        accum-tot-base     = accum-tot-base +  ub.chk-pay.tot-base
        accum-cre-pay-base = accum-cre-pay-base +  cre-pay-base
        accum-cre-pay-rubl = accum-cre-pay-rubl +  cre-pay-rubl
        .
        if v-cntxt-db-num = 0 and ub.chk-pay.pay-code <> cre-pay then do:
          FIND FIRST vchk-pay No-LOCK WHERE
                      vchk-pay.d-card = ub.chk-doc.d-card AND
                      vchk-pay.pay-code = ub.chk-pay.pay-code AND
                      vchk-pay.curr-code = ub.chk-pay.curr-code AND
                      vchk-pay.doc-date = ub.chk-pay.chk-date AND
                      vchk-pay.cre-pay = (ub.chk-pay.pay-code = cre-pay) AND
                      vchk-pay.exch-rate = (ub.chk-pay.tot-sum / chk-pay.tot-rubl) AND
                    vchk-pay.base-rate = (ub.chk-pay.tot-rubl / chk-pay.tot-base ) No-ERROR.
          IF NOT AVAIL vchk-pay then do:
            create vchk-pay.
            assign
            vchk-pay.d-card   = ub.chk-doc.d-card
            vchk-pay.doc-date = ub.chk-pay.chk-date
            vchk-pay.pay-code = ub.chk-pay.pay-code
            vchk-pay.curr-code = ub.chk-pay.curr-code
            vchk-pay.cre-pay = (ub.chk-pay.pay-code = cre-pay)
            vchk-pay.exch-rate =  (ub.chk-pay.tot-sum / ub.chk-pay.tot-rubl)
            vchk-pay.base-rate = (ub.chk-pay.tot-rubl / ub.chk-pay.tot-base)
            .
          end.
          assign
          vchk-pay.tot-sum  = vchk-pay.tot-sum  + ub.chk-pay.tot-sum
          vchk-pay.tot-base = vchk-pay.tot-base + ub.chk-pay.tot-base
          vchk-pay.tot-rubl = vchk-pay.tot-rubl + ub.chk-pay.tot-rubl
          .
      END.
    END .
    assign
    temp-d-card.pay-tot-base = temp-d-card.pay-tot-base + par-sign * (ACCUM-tot-base -  ACCUM-cre-pay-base)
    temp-d-card.pay-tot-rubl = temp-d-card.pay-tot-rubl + par-sign * (ACCUM-tot-rubl -  ACCUM-cre-pay-rubl)
    .
    if v-base-code = 0 then
    chk-exch =  1.
    else do:
      v-rate = ?.
      if v-curr-r-b = 'base':U then do:
        assign
        v-rate = ub.chk-doc.cash-rate / ub.chk-doc.cash-scale
        no-error
        .
        if v-rate <> 0
        and v-rate <> ? then do:
          chk-exch = v-rate.
        end.
        else do:
          assign
          v-rate = ACCUM-tot-rubl  / ACCUM-tot-base
          no-error
          .
          if v-rate <> ?
          and v-rate <> 0 then do:
            chk-exch = v-rate.
          end.
          else do:
              undo _main, return error substitute("&1&2 Невозможно определить курс базовой валюты для чека &3 по ДК &4"
                                                  , vss-description
                                                  , chr(10)
                                                  , chk-doc.doc-code
                                                  , chk-doc.d-card).
          end.
        end.
      end.
      else do:
        assign
        v-rate = ACCUM-tot-rubl  / ACCUM-tot-base
        no-error
        .
        if v-rate <> ?
        and v-rate <> 0 then do:
          chk-exch = v-rate.
        end.
        else do:
          FIND LAST buf_curr-shop NO-LOCK WHERE
                    buf_curr-shop.obj-type = ub.chk-doc.obj-type AND
                    buf_curr-shop.obj-code = ub.chk-doc.obj-code AND
                    buf_curr-shop.curr-code = v-base-code AND
                    ( ( buf_curr-shop.exch-date = ub.chk-doc.chk-date AND
                        buf_curr-shop.exch-time <= ub.chk-doc.chk-time ) OR
                        buf_curr-shop.exch-date < ub.chk-doc.chk-date ) NO-ERROR .
          if available buf_curr-shop then do:
            assign
            v-rate = buf_Curr-shop.exch-rate / buf_curr-shop.exch-scale
            no-error .
            if v-rate <> ?
            and v-rate <> 0 then do:
              chk-exch = v-rate.
            end.
            else do:
                undo _main, return error substitute("&1&2 Невозможно определить курс базовой валюты для чека &3 по ДК &4"
                                                    , vss-description
                                                    , chr(10)
                                                    , chk-doc.doc-code
                                                    , chk-doc.d-card).
            end.
          end.
        end.
      end.
    end.
    assign
    chk-exch-rubl = (if v-curr-r-b = 'rubl':U then 1 else chk-exch)
    chk-exch-base = (if v-curr-r-b = 'base':U then 1 else chk-exch )
    .
    Assign
    temp-d-card.sum-tot-r-b = temp-d-card.sum-tot-r-b + 0
    temp-d-card.sum-tot-rubl = temp-d-card.sum-tot-rubl + 0
    temp-d-card.sum-tot-base = temp-d-card.sum-tot-base + 0
    temp-d-card.gds-tot-r-b  = temp-d-card.gds-tot-r-b  + par-sign * ub.chk-doc.tot-doc
    temp-d-card.gds-tot-rubl = temp-d-card.gds-tot-rubl + par-sign * ub.chk-doc.tot-doc * chk-exch-rubl
    temp-d-card.gds-tot-base = temp-d-card.gds-tot-base + par-sign * ub.chk-doc.tot-doc / chk-exch-base
    temp-d-card.gds-dis-r-b  = temp-d-card.gds-dis-r-b  + par-sign * ub.chk-doc.discnt
    temp-d-card.gds-dis-rubl = temp-d-card.gds-dis-rubl + par-sign * ub.chk-doc.discnt * chk-exch-rubl
    temp-d-card.gds-dis-base = temp-d-card.gds-dis-base + par-sign * ub.chk-doc.discnt / chk-exch-base
    temp-d-card.num-chk      = temp-d-card.num-chk      + par-sign * 1
    .
    run ref/calctur4.p ( input ub.chk-doc.doc-code ) .
 END.
      FOR EACH buf_dis-card NO-LOCK where
              buf_dis-card.emitent-host-code = dctype AND
              buf_dis-card.d-card = f-d-card,
        first temp-d-card no-lock where
            temp-d-card.d-card = buf_dis-card.d-card:
        assign
        p-pay-sum-rubl = 0
        p-pay-sum-base = 0
        .
        for each buf_payment no-lock where
                  buf_payment.host-code = buf_Inkas.host-code
              AND  buf_payment.d-card = temp-d-card.d-card
              and  buf_payment.status_ = 'факт':U
              and  buf_payment.source-type = 'касс':U
              and  buf_payment.source-ref = buf_inkas.inkas-code :
          assign
          p-pay-sum-rubl = p-pay-sum-rubl + buf_payment.tot-rubl
          p-pay-sum-base = p-pay-sum-base + buf_payment.tot-base
          .
        end.
        if p-view-mode = 1
        or (p-pay-sum-base <> temp-d-card.pay-tot-base
        or p-pay-sum-rubl <> temp-d-card.pay-tot-rubl) then
        PUT STREAM TEST UNFORMATTED
        temp-d-card.d-card format "X(16)" space(1)
        buf_inkas.inkas-code space(1)
        temp-d-card.pay-tot-rubl format "->>>,>>>,>>9.99" space(1)
        temp-d-card.pay-tot-base format "->>>,>>>,>>9.99" space(1)
        p-pay-sum-rubl  format "->>>,>>>,>>9.99" space(1)
        p-pay-sum-base  format "->>>,>>>,>>9.99" space(1)
        (temp-d-card.pay-tot-rubl - p-pay-sum-rubl) format "->>>,>>>,>>9.99" space(1)
        (temp-d-card.pay-tot-base - p-pay-sum-base) format "->>>,>>>,>>9.99" space(1)
        SKIP.
      END.
    end.
    find first buf_Dis-card where buf_Dis-card.d-card = f-d-card no-error .
    if available buf_Dis-card then do:
    for each buf_sysconf no-lock,
        each bf_trn-doc no-lock where
            bf_trn-doc.host-code = buf_sysconf.host-code
        AND bf_trn-doc.cli-type = buf_Dis-card.cli-type
        AND bf_trn-doc.cli-code = buf_Dis-card.cli-code
        AND bf_trn-doc.doc-date >= X_start-date
        AND bf_trn-doc.doc-date <= X_end-date:
      if bf_trn-doc.status_ <> 'факт':U then NEXT.
      if bf_trn-doc.d-card = "":U then NEXT.
      if bf_trn-doc.d-card <> f-d-card then NEXT.
      if bf_trn-doc.ext-doc-type = 'es':U then NEXT.
      for each temp-d-card:
        delete temp-d-card.
      end.
      for each vchk-pay:
        delete vchk-pay.
      end.
      create temp-d-card.
      assign
      temp-d-card.d-card            = bf_trn-doc.d-card
      temp-d-card.card-num          = temp-d-card.card-num
      temp-d-card.emitent-host-code = temp-d-card.emitent-host-code
      temp-d-card.type              = temp-d-card.type
      temp-d-card.cli-type          = temp-d-card.cli-type
      temp-d-card.cli-code          = temp-d-card.cli-code
      .
      assign
      p-doc-code = bf_trn-doc.doc-code
      .
      assign
      par-sign = 1
      par-direction =  if bf_trn-doc.ext-doc-type = 're':U
                    then -1
                    else  1.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-cntxt-db-num = 0 then do:
  FOR EACH buf_doc-line no-lock where
          buf_doc-line.doc-code = p-doc-code
     On error undo _main, return error:
    run r-sale in this-procedure (
                                    input p-doc-code
                                   ,input buf_doc-line.artic
                                   ,input buf_doc-line.prod-type
                                   ,input buf_doc-line.prod-code
                                   ,output v-fact-qnty
                                   ,output v-vat-pc
                                   ,output v-slt-pc
                                   ,output v-sum-base
                                   ,output v-sum-rubl
                                   ,output v-vat-base
                                   ,output v-vat-rubl
                                   ,output v-slt-base
                                   ,output v-slt-rubl
                                   ,output v-road-tax-base
                                   ,output v-road-tax-rubl
                                   ,output v-transport-base
                                   ,output v-transport-rubl
                                   ,output v-other-base
                                   ,output v-other-rubl
                                   ,output v-excise-base
                                   ,output v-excise-rubl
                                    ) .
      assign
      temp-d-card.pay-tot-rubl = temp-d-card.pay-tot-rubl + par-direction * par-sign * abs( v-sum-rubl)
      temp-d-card.pay-tot-base = temp-d-card.pay-tot-base + par-direction * par-sign * abs( v-sum-base)
      temp-d-card.gds-tot-rubl = temp-d-card.gds-tot-rubl + par-direction * par-sign * abs( (v-sum-rubl + v-other-rubl))
      temp-d-card.gds-tot-base = temp-d-card.gds-tot-base + par-direction * par-sign * abs( (v-sum-base + v-other-base))
      temp-d-card.gds-dis-rubl = temp-d-card.gds-dis-rubl + par-direction * par-sign * abs( v-other-rubl)
      temp-d-card.gds-dis-base = temp-d-card.gds-dis-base + par-direction * par-sign * abs( v-other-base)
      .
      run r-cost in this-procedure (
                                    input p-doc-code
                                   ,input buf_doc-line.artic
                                   ,input buf_doc-line.prod-type
                                   ,input buf_doc-line.prod-code
                                   ,output v-fact-qnty
                                   ,output v-vat-pc
                                   ,output v-slt-pc
                                   ,output v-sum-base
                                   ,output v-sum-rubl
                                   ,output v-vat-base
                                   ,output v-vat-rubl
                                   ,output v-slt-base
                                   ,output v-slt-rubl
                                   ,output v-road-tax-base
                                   ,output v-road-tax-rubl
                                   ,output v-transport-base
                                   ,output v-transport-rubl
                                   ,output v-other-base
                                   ,output v-other-rubl
                                   ,output v-excise-base
                                   ,output v-excise-rubl
                                    ) .
    assign
    temp-d-card.gds-tot-r0 = temp-d-card.gds-tot-r0 + par-direction * par-sign * abs( v-sum-rubl)
    temp-d-card.gds-tot-b0 = temp-d-card.gds-tot-b0 + par-direction * par-sign * abs( v-sum-base)
    .
  END.
end.
if v-curr-r-b = 'base':U then
assign
temp-d-card.gds-tot-r-b = temp-d-card.gds-tot-base
temp-d-card.gds-dis-r-b = temp-d-card.gds-dis-base
temp-d-card.sum-tot-r-b = temp-d-card.sum-tot-base
.
else
assign
temp-d-card.gds-tot-r-b = temp-d-card.gds-tot-rubl
temp-d-card.gds-dis-r-b = temp-d-card.gds-dis-rubl
temp-d-card.sum-tot-r-b = temp-d-card.sum-tot-rubl
.
  find first vchk-pay no-lock where
            vchk-pay.d-card   = temp-d-card.d-card
        AND vchk-pay.pay-code = bf_trn-doc.pay-code
        AND vchk-pay.curr-code = bf_trn-doc.exch-code
        AND vchk-pay.doc-date  = 01/01/1990
        AND vchk-pay.cre-pay   = (cre-pay = bf_trn-doc.pay-code) no-error .
  if not available vchk-pay then do:
    create vchk-pay.
    assign
    vchk-pay.d-card   = temp-d-card.d-card
    vchk-pay.doc-date = bf_trn-doc.exch-date
    vchk-pay.pay-code = bf_trn-doc.pay-code
    vchk-pay.curr-code = bf_trn-doc.exch-code
    vchk-pay.cre-pay   =  no
    vchk-pay.exch-rate = bf_trn-doc.exch-rate
    vchk-pay.base-rate = bf_trn-doc.base-rate
    vchk-pay.tot-base =  temp-d-card.pay-tot-base
    vchk-pay.tot-rubl =  temp-d-card.pay-tot-rubl
    vchk-pay.tot-sum =  (if bf_trn-doc.exch-code = 0 then temp-d-card.pay-tot-rubl else temp-d-card.pay-tot-base)
    .
  end.
      assign
      p-pay-sum-rubl = 0
      p-pay-sum-base = 0
      .
      find first buf_payment no-lock where
                buf_payment.host-code = bf_trn-doc.host-code
          AND  buf_payment.d-card = temp-d-card.d-card
          and  buf_payment.status_ = 'факт':U
          and  buf_payment.source-type = 'накл':U
          and  buf_payment.source-ref = bf_trn-doc.doc-code  no-error .
      if available buf_payment then
      assign
      p-pay-sum-rubl = buf_payment.tot-rubl
      p-pay-sum-base = buf_payment.tot-base
      .
      if p-view-mode = 1
      OR (p-pay-sum-base <> temp-d-card.pay-tot-base
      or p-pay-sum-rubl <> temp-d-card.pay-tot-rubl) then
      PUT STREAM TEST UNFORMATTED
      temp-d-card.d-card format "X(16)" space(1)
      bf_trn-doc.doc-code space(1)
      temp-d-card.pay-tot-rubl format "->>>,>>>,>>9.99" space(1)
      temp-d-card.pay-tot-base format "->>>,>>>,>>9.99" space(1)
      p-pay-sum-rubl  format "->>>,>>>,>>9.99" space(1)
      p-pay-sum-base  format "->>>,>>>,>>9.99" space(1)
      (temp-d-card.pay-tot-rubl - p-pay-sum-rubl) format "->>>,>>>,>>9.99" space(1)
      (temp-d-card.pay-tot-base - p-pay-sum-base) format "->>>,>>>,>>9.99" space(1)
      SKIP.
    end.
      end.
  end.
  when 3 then do:
    FOR EACH ub.dis-host no-LOCK
      WHERE ub.dis-host.d-card =  f-d-card
      AND ub.dis-host.host-code > 0
      and ub.dis-host.dt-code = 0
      BREAK
      by ub.dis-host.d-card
      by ub.dis-host.dt-code
      by ub.dis-host.host-code:
        assign
        do-chk-num = 0
        do-gds-sum-rubl = 0
        do-disc-sum-rubl = 0
        do-pay-sum-rubl = 0
        do-gds-sum-base = 0
        do-disc-sum-base = 0
        do-pay-sum-base = 0
        dh-chk-num = 0
        dh-gds-sum-rubl = 0
        dh-disc-sum-rubl = 0
        dh-pay-sum-rubl = 0
        dh-gds-sum-base = 0
        dh-disc-sum-base = 0
        dh-pay-sum-base = 0
        p-pay-sum-rubl = 0
        p-pay-sum-base = 0
        dh-chk-num = dis-host.num-chk
        dh-gds-sum-rubl = dis-host.gds-tot-rubl
        dh-disc-sum-rubl = dis-host.gds-dis-rubl
        dh-pay-sum-rubl = dis-host.pay-tot-rubl
        dh-gds-sum-base = dis-host.gds-tot-base
        dh-disc-sum-base =  dis-host.gds-dis-base
        dh-pay-sum-base = dis-host.pay-tot-base
        .
        FOR EACH ub.payment no-lock where
                 ub.payment.host-code = ub.dis-host.host-code AND
                 ub.payment.d-card = ub.dis-host.d-card and
                 ub.payment.status_ = 'факт':U:
        if ub.payment.source-type = 'касс':U
        or ub.payment.source-type = 'накл':U then next.
        ASSIGN
        p-pay-sum-rubl = p-pay-sum-rubl + ub.payment.tot-rubl
        p-pay-sum-base = p-pay-sum-base + ub.payment.tot-base
        .
      end.
      FOR  EACH ub.dis-obj no-lock where
             ub.dis-obj.host-code = ub.dis-host.host-code
         and ub.dis-obj.dt-code    = ub.dis-host.dt-code
         and ub.dis-obj.d-card   = ub.dis-host.d-card
         :
      ii = ii + 1.
      if ii MOD 100 = 0 then
      run waitfram-show in this-procedure ("Обработано " + string(ii) + " итогов по дисконтным картам на объекте").
      assign
      do-chk-num = do-chk-num + ub.dis-obj.num-chk
      do-gds-sum-rubl = do-gds-sum-rubl + ub.dis-obj.gds-tot-rubl + ub.dis-obj.sum-tot-rubl
      do-disc-sum-rubl = do-disc-sum-rubl + ub.dis-obj.gds-dis-rubl + ub.dis-obj.sum-dis-rubl
      do-pay-sum-rubl = do-pay-sum-rubl + ub.dis-obj.pay-tot-rubl
      do-gds-sum-base = do-gds-sum-base + ub.dis-obj.gds-tot-base + ub.dis-obj.sum-tot-base
      do-disc-sum-base = do-disc-sum-base + ub.dis-obj.gds-dis-base + ub.dis-obj.sum-dis-base
      do-pay-sum-base = do-pay-sum-base + ub.dis-obj.pay-tot-base
      .
    END.
    IF p-view-mode = 1
    or (abs(dh-pay-sum-rubl - (do-pay-sum-rubl + p-pay-sum-rubl)) > 0.005
    OR abs(dh-pay-sum-base - (do-pay-sum-base + p-pay-sum-base)) > 0.005)
    then
    PUT STREAM TEST UNFORMATTED
    dis-host.d-card format "X(16)" space(1)
    dis-host.host-code format "999999999" space(3)
    do-chk-num format "999999999" space(1)
    do-gds-sum-rubl format "->>>,>>>,>>9.99" space(1)
    do-gds-sum-base format "->>>,>>>,>>9.99" space(1)
    do-disc-sum-rubl format "->>>,>>>,>>9.99" space(1)
    do-disc-sum-base format "->>>,>>>,>>9.99" space(1)
    do-pay-sum-rubl format "->>>,>>>,>>9.99" space(1)
    do-pay-sum-base format "->>>,>>>,>>9.99" space(1)
    p-pay-sum-rubl  format "->>>,>>>,>>9.99" space(6)
    p-pay-sum-base  format "->>>,>>>,>>9.99" space(6)
    dh-chk-num format "999999999" space(1)
    dh-gds-sum-rubl format "->>>,>>>,>>9.99" space(1)
    dh-gds-sum-base format "->>>,>>>,>>9.99" space(1)
    dh-disc-sum-rubl format "->>>,>>>,>>9.99" space(1)
    dh-disc-sum-base format "->>>,>>>,>>9.99" space(1)
    dh-pay-sum-rubl format "->>>,>>>,>>9.99" space(1)
    dh-pay-sum-base format "->>>,>>>,>>9.99" space(1)
    dh-pay-sum-rubl - (do-pay-sum-rubl + p-pay-sum-rubl) format "->>>,>>>,>>9.99" space(1)
    dh-pay-sum-base - (do-pay-sum-base + p-pay-sum-base) format "->>>,>>>,>>9.99" space(1)
    skip.
  END.
end.
when 4 then do:
  FOR EACH ub.dis-obj No-LOCK
     WHERE ub.dis-obj.d-card =  f-d-card
  BREAK
  by ub.dis-obj.host-code
  by ub.dis-obj.d-card:
    ii = ii + 1.
    if ii MOD 100 = 0 then
    run waitfram-show in this-procedure ("Обработано " + string(ii) + " итогов по дисконтным картам на объекте").
    IF FIRST-of(ub.dis-obj.d-card) then do:
      assign
      p-pay-sum-rubl = 0
      p-pay-sum-base = 0
      do-pay-sum-rubl = 0
      do-pay-sum-base = 0
      .
    END.
    if ub.dis-obj.dt-code = 0 then dO:
      assign
      do-pay-sum-rubl = do-pay-sum-rubl + ub.dis-obj.pay-tot-rubl
      do-pay-sum-base = do-pay-sum-base + ub.dis-obj.pay-tot-base
      .
    end.
    IF LAST-OF(ub.dis-obj.d-card) then do:
      FOR EACH ub.payment no-lock where
              ub.payment.host-code = ub.dis-obj.host-code AND
              ub.payment.d-card = entry(1, ub.dis-obj.d-card, chr(4)) and
              ub.payment.status_ = 'факт':U and
              ub.payment.source-type = 'касс':U:
        ASSIGN
        p-pay-sum-rubl = p-pay-sum-rubl + if ub.payment.tot-rubl = ? then 0 else ub.payment.tot-rubl
        p-pay-sum-base = p-pay-sum-base + if ub.payment.tot-base = ? then 0 else ub.payment.tot-base
        .
      end.
      FOR EACH ub.payment no-lock where
              ub.payment.host-code = ub.dis-obj.host-code AND
              ub.payment.d-card = entry(1, dis-obj.d-card, chr(4)) and
              ub.payment.status_ = 'факт':U and
              ub.payment.source-type = 'касс':U + chr(44) + "data-import"  :
        ASSIGN
        p-pay-sum-rubl = p-pay-sum-rubl + if ub.payment.tot-rubl = ? then 0 else ub.payment.tot-rubl
        p-pay-sum-base = p-pay-sum-base + if ub.payment.tot-base = ? then 0 else ub.payment.tot-base
        .
      end.
      FOR EACH ub.payment no-lock where
              ub.payment.host-code = ub.dis-obj.host-code AND
              ub.payment.d-card = entry(1, ub.dis-obj.d-card, chr(4)) and
              ub.payment.status_ = 'факт':U and
              ub.payment.source-type = 'накл':U:
        ASSIGN
        p-pay-sum-rubl = p-pay-sum-rubl + ub.payment.tot-rubl
        p-pay-sum-base = p-pay-sum-base + ub.payment.tot-base
        .
      end.
      FOR EACH ub.payment no-lock where
              ub.payment.host-code = ub.dis-obj.host-code AND
              ub.payment.d-card = entry(1, ub.dis-obj.d-card, chr(4)) and
              ub.payment.status_ = 'факт':U and
              ub.payment.source-type = 'накл':U + chr(44) + "data-import":U:
        ASSIGN
        p-pay-sum-rubl = p-pay-sum-rubl + ub.payment.tot-rubl
        p-pay-sum-base = p-pay-sum-base + ub.payment.tot-base
        .
      end.
      if p-view-mode = 1
      or ((do-pay-sum-rubl - p-pay-sum-rubl) <> 0
      or (do-pay-sum-base - p-pay-sum-base) <> 0) then
      PUT STREAM TEST UNFORMATTED
      ub.dis-obj.d-card format "X(16)" space(1)
      do-pay-sum-rubl format "->>>,>>>,>>9.99" space(1)
      do-pay-sum-base format "->>>,>>>,>>9.99" space(1)
      p-pay-sum-rubl  format "->>>,>>>,>>9.99" space(1)
      p-pay-sum-base  format "->>>,>>>,>>9.99" space(1)
      (do-pay-sum-rubl - p-pay-sum-rubl) format "->>>,>>>,>>9.99" space(1)
      (do-pay-sum-base - p-pay-sum-base) format "->>>,>>>,>>9.99" space(1)
      SKIP.
    END.
  end.
END.
WHEN 5 then do:
  FOR EACH ub.dis-card No-LOCK
     WHERE ub.dis-card.d-card =  f-d-card
  BREAK
  by ub.dis-card.d-card:
    ii = ii + 1.
    if ii MOD 100 = 0 then
    run waitfram-show in this-procedure ("Обработано " + string(ii) + " дисконтных карт").
    IF FIRST-of(dis-card.d-card) then do:
      assign
      dh-gds-sum-rubl = 0
      dh-disc-sum-rubl = 0
      dh-pay-sum-rubl = 0
      dh-gds-sum-base = 0
      dh-disc-sum-base = 0
      dh-pay-sum-base = 0
      .
      FOR EACH ub.dis-host No-LOCK
         WHERE ub.dis-host.d-card = ub.dis-card.d-card
             and ub.dis-host.host-code > 0
             and ub.dis-host.dt-code = 0
      break
      by ub.dis-host.host-code:
        assign
        dh-gds-sum-rubl = dh-gds-sum-rubl + dis-host.gds-tot-rubl
        dh-disc-sum-rubl = dh-disc-sum-rubl + dis-host.gds-dis-rubl
        dh-pay-sum-rubl = dh-pay-sum-rubl + dis-host.pay-tot-rubl
        dh-gds-sum-base = dh-gds-sum-base + dis-host.gds-tot-base
        dh-disc-sum-base = dh-disc-sum-base + dis-host.gds-dis-base
        dh-pay-sum-base = dh-pay-sum-base + dis-host.pay-tot-base
        .
        if dis-card.emitent-host-code = 0 and
        (abs((dis-host.gds-tot-rubl - dis-host.gds-dis-rubl) - dis-host.pay-tot-rubl ) > 0.001 OR
          abs((dis-host.gds-tot-base - dis-host.gds-dis-base) - dis-host.pay-tot-base) > 0.001
        ) then do:
          PUT stream test unformatted
          dis-card.d-card format "X(16)" space(1)
          dis-host.host-code format "999999999" space(3)
          dis-host.gds-tot-rubl format "->>>,>>>,>>9.99" space(1)
          dis-host.gds-tot-base format "->>>,>>>,>>9.99" space(1)
          dis-host.gds-dis-rubl format "->>>,>>>,>>9.99" space(1)
          dis-host.gds-dis-base format "->>>,>>>,>>9.99" space(1)
          dis-host.pay-tot-rubl format "->>>,>>>,>>9.99" space(1)
          dis-host.pay-tot-base format "->>>,>>>,>>9.99" space(3)
          ((dis-host.gds-tot-rubl - dis-host.gds-dis-rubl) - dis-host.pay-tot-rubl) format "->>>,>>>,>>9.99" space(1)
          ((dis-host.gds-tot-base - dis-host.gds-dis-base) - dis-host.pay-tot-base) format "->>>,>>>,>>9.99" space(1)
          "ОШИБКА глобкарта" format "X(15)" space(1)
          "!ненулевое сальдо" format "X(15)" space(3)
          SKIP.
        end.
      END.
      if p-view-mode = 1
      or (((dh-gds-sum-rubl - dh-disc-sum-rubl) - dh-pay-sum-rubl -  dis-card.saldo-rubl) <> 0
      OR ((dh-gds-sum-BASE - dh-disc-sum-base) - dh-pay-sum-base -  dis-card.saldo-base) <> 0)
      then
      PUT stream test unformatted
      dis-card.d-card format "X(16)" space(1)
      dis-card.emitent-host-code format "999999999" space(3)
      dh-gds-sum-rubl format "->>>,>>>,>>9.99" space(1)
      dh-gds-sum-base format "->>>,>>>,>>9.99" space(1)
      dh-disc-sum-rubl format "->>>,>>>,>>9.99" space(1)
      dh-disc-sum-base format "->>>,>>>,>>9.99" space(1)
      dh-pay-sum-rubl format "->>>,>>>,>>9.99" space(1)
      dh-pay-sum-base format "->>>,>>>,>>9.99" space(3)
      (dh-gds-sum-rubl - dh-disc-sum-rubl) - dh-pay-sum-rubl format "->>>,>>>,>>9.99" space(1)
      (dh-gds-sum-BASE - dh-disc-sum-base) - dh-pay-sum-base format "->>>,>>>,>>9.99" space(1)
      dis-card.saldo-rubl format "->>>,>>>,>>9.99" space(1)
      dis-card.saldo-base format "->>>,>>>,>>9.99" space(3)
      ((dh-gds-sum-rubl - dh-disc-sum-rubl) - dh-pay-sum-rubl -  dis-card.saldo-rubl) format "->>>,>>>,>>9.99" space(1)
      ((dh-gds-sum-BASE - dh-disc-sum-base) - dh-pay-sum-base -  dis-card.saldo-base) format "->>>,>>>,>>9.99" space(1)
      SKIP.
    END.
  END.
END.
when 7 then do:
  FOR EACH buf_dis-card No-LOCK where
    buf_Dis-card.emitent-host-code = dctype
     AND buf_dis-card.d-card =  f-d-card
,
   first buf_dis-card-type no-lock where
        buf_dis-card-type.type = buf_dis-card.type
    AND buf_dis-card-type.emitent-host-code = buf_dis-card.emitent-host-code
  :
      if NOT new-d-pcnt = old-d-pcnt
      or p-view-mode = 1 then do:
        PUT stream test unformatted
        buf_dis-card.d-card format "X(16)" space(1)
        buf_dis-card.type   format "X(8)" space(1)
        for-sum format "->>>,>>>,>>9.99" space(1)
        buf_dis-card.d-pcnt format "->,>>9.99" space(1)
        new-d-pcnt          format "->,>>9.99" space(1)
        skip.
      end.
    END.
  end.
 when 8 then do:
  run ref/proprefs.w (
                   input parparentproc
                  ,input 'b-sel'
                  ,input "dis-tot"
                  ,input 5
                  ,input '':U
                  ,input '':U
                  ,input-output  v-ref-list) no-error.
  if error-status:error or v-ref-list = '':u then do:
    return.
  end.
  find first buf_prop-ref no-lock where
           recid(buf_prop-ref) = integer(v-ref-list).
  assign
  v-dt-code = buf_prop-ref.dt-code
  v-sum-id =  buf_prop-ref.sum-id
  .
  assign
  v-date-from =  date(entry(1, buf_prop-ref.sum-id, "-"))
  v-date-to =  date(entry(2, buf_prop-ref.sum-id, "-"))
  .
  PUT stream test unformatted
  substitute("Идентификатор частного итога &1 Доп.идентификатор &2"
              ,v-sum-id
              ,buf_prop-ref.caller_id
              ) skip.
  FOR EACH buf_dis-card No-LOCK where
     buf_dis-card.d-card =  f-d-card
     :
     for each buf_clients no-lock where
            buf_clients.obj-type = 'маг':U
       and  (v-cntxt-db-num = 0 or buf_clients.db-num = v-cntxt-db-num):
      assign
      v-chk-num = 0
      v-netto-sum = 0.
        _buf_chk-doc:
        for each buf_chk-doc no-lock where
          buf_chk-doc.d-card = buf_dis-card.d-card
          and buf_chk-doc.obj-type = buf_clients.obj-type
          and buf_chk-doc.obj-code = buf_clients.obj-code
          and buf_chk-doc.chk-date >= v-date-from
          and buf_chk-doc.chk-date <= v-date-to
          :
          assign
          v-chk-num = v-chk-num  + 1
          v-netto-sum  = v-netto-sum + buf_chk-doc.netto
          .
        end.
      find first buf_dis-obj no-lock where
                buf_dis-obj.obj-type = buf_clients.obj-type
            and buf_dis-obj.obj-code = buf_clients.obj-code
            and buf_dis-obj.d-card = buf_dis-card.d-card
            and buf_dis-obj.dt-code = v-dt-code no-error .
      if not available buf_dis-obj then do:
        assign
        v-chk-num-do = 0
        v-netto-sum-do = 0
        .
      end.
      else do:
        assign
        v-chk-num-do = buf_dis-obj.num-chk
        v-netto-sum-do = (if v-curr-r-b = 'rubl':U
                       then (buf_dis-obj.gds-tot-rubl - buf_dis-obj.gds-dis-rubl)
                       else (buf_dis-obj.gds-tot-base - buf_dis-obj.gds-dis-base)
                       )
        .
      end.
      if v-chk-num <> v-chk-num-do
      or p-view-mode = 1
      then do:
          PUT stream test unformatted
          string(p-obj-type + string(buf_clients.obj-code), "X(20)") space(1)
          buf_dis-card.d-card format "X(16)" space(1)
          v-chk-num   format ">>>>>>>>>" space(10)
          v-chk-num-do   format ">>>>>>>>>" space(10)
          v-netto-sum    format ">>>,>>>,>>>,>>9.999" space(1)
          v-netto-sum-do format ">>>,>>>,>>>,>>9.999" space(1)
          skip.
      end.
    end.
  end.
end.
  when 99 then do:
    FOR EACH buf_dis-card No-LOCK where
    buf_Dis-card.emitent-host-code = dctype
     :
      v-chk-num = 0.
     for each buf_clients no-lock where
            buf_clients.obj-type = 'маг':U
       and  (v-cntxt-db-num = 0 or buf_clients.db-num = v-cntxt-db-num):
      for each buf_chk-doc no-lock where
        buf_chk-doc.d-card = buf_dis-card.d-card
        and buf_chk-doc.obj-type = buf_clients.obj-type
        and buf_chk-doc.obj-code = buf_clients.obj-code:
        assign
        v-chk-num = v-chk-num  + 1
        .
      end.
        find first buf_dis-obj no-lock where
                  buf_dis-obj.obj-type = buf_clients.obj-type
              and buf_dis-obj.obj-code = buf_clients.obj-code
              and buf_dis-obj.d-card = buf_dis-card.d-card
              and buf_dis-obj.dt-code = 0  no-error .
        if not available buf_dis-obj then do:
          assign
          v-chk-num-do = 0.
        end.
        else do:
          assign
          v-chk-num-do = buf_dis-obj.num-chk.
        end.
        if v-chk-num <> v-chk-num-do
        or p-view-mode = 1
        then do:
          PUT stream test unformatted
          string(buf_clients.obj-type + string(buf_clients.obj-code), "X(20)") space(1)
          buf_dis-card.d-card format "X(16)" space(1)
          v-chk-num   format ">>>>>>>>>" space(10)
          v-chk-num-do   format ">>>>>>>>>" space(10)
          skip.
        end.
      end.
    end.
  end.
END CASE.
end.
end.
