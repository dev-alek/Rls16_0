block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: d3f7ea4aa09e, 3307, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/05/19 13:37:07 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chkdd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/chkdd.p $":U .
define variable vss-description as character no-undo init "Проверка словаря БД".
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
define variable v-0-rdb-not-news as character no-undo initial
"sysconf~
,dis-card-type~
,dis-card-type-attr~
,prop-ref~
,prop-ref-call~
,prop-head~
,c-prop-head~
,prop-ruleset~
,prop-map~
,dis-card-mask~
,dis-card-mask-attr~
,curr-accnt~
,curr-bank~
,c-curr-bank~
,currency~
,c-currency~
,pay-type~
,c-pay-type~
,shop~
,store~
,tare~
,c-tare~
,units~
,c-units~
,cli-grp~
,c-cli-grp~
,gds-prt~
,c-gds-prt~
,gds-grp~
,c-gds-grp~
,c-gds-grp-hist~
,cash-pay~
,c-cash-pay~
,cash-pay-attr~
,c-cash-pay-attr~
,wealth~
,wth-par~
,wth-gds~
,country~
,c-country~
,tax~
,c-tax~
,tax-rate~
,c-tax-rate~
,tax-rate-attr~
,tax-rate-gds-grp~
,c-tax-rate-gds-grp~
,gds-grp-attr~
,c-gds-grp-attr~
,gds-grp-obj~
,c-gds-grp-obj~
,tax-units~
,c-tax-units~
,sum-grp-attr~
,sum-grp~
,c-sum-grp~
,auto-tank~
,auto-section~
,auto-section-table~
,auto-tank-meas~
,c-auto-tank~
,c-auto-section~
,c-auto-section-table~
,sr-izmerenia~
,c-sr-izmerenia~
,parts-attr~
,group-period-validity~
,c-group-period-validity~
,condition-keeping~
,c-condition-keeping~
,delivery-type~
,c-delivery-type~
,delivery-subject~
,c-delivery-subject~
,delivery-type-subject~
,c-delivery-type-subject~
,deliv-type-cond-keep~
,c-deliv-type-cond-keep~
,variant-delivery~
,c-variant-delivery~
,var-deliv-gr-per-val~
,c-var-deliv-gr-per-val~
,trn-reason~
,trn-rsn-attr~
,trn-reason-obj~
,trn-reason-host~
,global-state~
,rule~
,ruleset~
,ruledict~
,c-ruledict~
,ruledict-param~
,rule-profile~
,profile-by-profile~
,rule-process~
,rp-rule-param~
,rule-by-profile~
,rp-by-call~
,rule-by-set~
,rule-call-param~
,prop-script~
,pscript-ruleset~
,rule-by-call~
,dis-cfg-rule~
,drt-prop~
,attr-prop~
,alc-type~
,c-alc-type~
,alc-type-attr~
,c-alc-type-attr~
,custom-labels~
,stop-list~
,layout-elem~
,wi-mode~
,cd-events~
,cd-events-attr~
,cd-video-link~
,cd-video-link-attr~
,gds-mercury~
,gds-mercury-attr~
,units-attr~
,operserv~
,operservattr~
,cashbook~
,cashbookattr~
,c-marking~
":U.
define variable v-0-rdb-and-from-news as character no-undo initial
"code-range~
,dis-card~
,dis-host":U
.
define variable v-rdb-0-not-news as character no-undo initial
"db-info~
,fbr-doc
,c-fbr-doc~
,fin-ob~
,c-fin-ob~
,fin-ob-before~
,fin-connect~
,fin-statement~
,c-fin-statement~
,fin-statement-attr~
,c-fin-statement-attr~
,esys-pck-sent~
,esys-pck-rcvd~
,pump~
,c-pmp-hist~
,c-pump~
,pump-attr~
,c-pump-attr~
,place~
,place-attr~
,place-imp~
,place-imp-attr~
,c-place-attr~
,c-plc-hist~
,c-place~
,wth-place~
,c-wth-place~
,pl-gds~
,c-pl-gds~
,pl-gds-attr~
,c-pl-gds-attr~
,pl-pump~
,c-pl-pump~
,pl-gds-pump~
,c-pl-gds-pump~
,nozzle~
,c-nzl-hist~
,c-nozzle~
,nozzle-attr~
,c-nozzle-attr~
,pump-nozzle~
,c-pump-nozzle~
,pl-pump-nozzle~
,c-pl-pump-nozzle~
,obj-date~
,shift-obj~
,c-shift-obj~
,shift-period~
,sum-grp-obj~
,c-sum-grp-obj~
,cshr-month~
,cash-desk~
,c-cash-desk~
,nws-doc-hist~
,fbr-prn~
,c-fbr-prn~
,fbr-prn-grp~
,c-fbr-prn-grp~
,fbr-prn-gds~
,c-fbr-prn-gds~
,fbr-gds-grp~
,fbr-gds-grp-attr~
,c-fbr-gds-grp-hist~
,c-fbr-gds-grp~
,c-fbr-gds-grp-attr~
,arh-fin-doc-an~
,arh-fin-doc-an-nal~
,arh-fin-doc-contr-schet~
,arh-fin-doc-contr-schet-nal~
,arh-fin-doc-contr-schet-tax~
,arh-fin-doc-c-schet-tax-nal~
,arh-fin-doc-schet~
,arh-fin-doc-schet-nal~
,arh-fin-doc-schet-tax~
,arh-fin-doc-schet-tax-nal~
,arh-fin-ob-contr~
,c-chk-doc~
,scales~
,scales-attr~
,scales-grp~
,scales-gds~
,c-scales-attr~
,c-scales~
,c-scales-grp~
,c-scales-gds~
,factur-connect~
,pl-level~
,c-pl-level~
,pl-level-imp~
,pl-level-mm~
,pl-level-mm-imp~
,prod-bc-db~
,cd-clu~
,c-cd-clu~
,cd-doc~
,c-cd-doc~
,cd-dlu~
,c-cd-dlu~
,cd-grp~
,c-cd-grp~
,cd-plu~
,c-cd-plu~
,user-context-history~
,action-post~
,action-post-user-login~
,action-post-host~
,action-post-role~
,menu-user~
,menu-user-call~
,action-post-menu-group~
,action-post-obj~
,user-window-attr~
,rpt-option~
,c-wth-ser~
,cd-trans~
,cd-event-log~
,cd-event-log-attr~
,c-assortment-matrix-goods~
,c-gds-obj-prop~
,upgrade~
,upgrade-attr~
,devisPC~
,devisPC-attr~
,c-user-log~
,marking-lines~
,marking~
,tran-fuel~
,chk-slip-head~
,chk-slip-string~
,cash-param-hist~
":U.
define variable v-0-rdb_rbd-0-not-news as character no-undo initial
"clients~
,clients-attr~
,db~
,c-db~
,firm~
,person~
,goods~
,goods-attr~
,auto-tank-attr~
,auto-section-attr~
,bar-code~
,bar-code-attr~
,prod-bc~
,prod-bc-attr~
,sert~
,c-sert~
,tax-rate-gds~
,tax-rate-value~
,sert-join~
,gds-host-attr~
,dis-time-rule~
,c-dis-time-rule~
,gds-add-charges~
,ext-system~
,ext-system-attr~
,abc-analysis~
,xyz-analysis~
,abcxyz-analysis~
,rang-abc-def~
,rang-xyz-def~
,doc-abc-def~
,doc-xyz-def~
,c-table-bind~
,criterion-analysis~
,ext-artic~
,c-ext-artic~
,ext-artic-attr~
,c-ext-artic-attr~
,ex-mark~
,c-ex-mark~
,place-io~
,c-place-io~
,point-io~
,c-point-io~
,point-place-rel~
,c-point-place-rel~
,point-point-rel~
,c-point-point-rel~
,schedule~
,schedule-attr~
,ext-classif~
,ext-classif-attr~
,dis-thbj-rule~
,user-account~
,alc-sale-lic~
,c-alc-sale-lic~
,alc-sale-lic-attr~
,c-alc-sale-lic-attr~
,alc-sale-lic-type~
,c-alc-sale-lic-type~
,alc-supp-lic~
,c-alc-supp-lic~
,alc-supp-lic-attr~
,c-alc-supp-lic-attr~
,alc-supp-lic-type~
,c-alc-supp-lic-type~
,alc-type-gds~
,c-alc-type-gds~
,contract~
,c-contract~
,contract-attr~
,contract-specif~
,c-contract-specif~
,some-lk~
,who-lk~
,egais-gds~
,c-egais-gds~
,egais-clients~
,c-egais-clients~
,layout~
,assortment-matrix~
,assortment-matrix-attr~
,assortment-matrix-goods~
,c-assortment-matrix~
,gds-obj-prop~
,fin-code-cel-nazn~
,fin-code-an-uchet~
,fin-code-cor-acc~
,thbj-attr~
,edi-status~
,counter~
,cashbookrule~
,cashbookruleattr~
,PromoAction~
,PromoCriterion~
,PromoGift~
,PromoGoods~
,PromoObject~
,PromoAttr~
,promo-schedule-week~
,promo-schedule~
,marking~
,marking-attr~
,code~
,c-code~
":U.
define variable v-0-remote-stock as character no-undo initial
"prt-obj~
,db-status":U.
define variable v-0-rdb-no-src_rdb-0-no-news as character no-undo initial
"fin-bank~
,c-fin-bank~
,fin-schet~
,c-fin-schet~
,dis-obj~
,add-doc~
,buyer-group~
,buyer-in-buyer-group~
,sum-group~
,qnty-group~
,turnover-group~
,grp-obj-price~
,c-grp-obj-price~
,turnover-buyer-main~
,price-list-type~
,upgrade~
,wth-ser~
,recipe~
,recipe-gds~
,c-recipe~
,c-recipe-gds~
,c-recipe-hist
":U.
define variable v-route-c-glob-context as character no-undo initial
"c-goods~
,c-goods-attr~
,c-prod-bc~
,c-bar-code~
,c-bar-code-attr~
,c-gds-host-attr~
,c-clients~
,c-clients-attr~
,c-firm~
,c-person~
,c-shop~
,c-store~
,c-gds-season~
,c-gds-add-charges~
,c-wth-hist~
,c-season~
,c-wealth~
,c-wth-par~
,c-wth-gds~
,c-trn-reason~
,c-trn-rsn-attr~
,c-trn-reason-obj~
,c-trn-reason-host~
,c-ext-classif~
,c-dis-thbj-rule~
,c-cli-hist~
,c-dis-cfg-rule~
,c-drt-prop~
,c-user-account~
,c-usr-hist~
,c-hist-nws-option~
":U.
define variable v-route-c-quest-context as character no-undo initial
"c-dis-card-property":U.
define variable v-route-c-shapka-context as character no-undo initial
"c-gds-hist~
,c-tax-hist~
,c-dc-hist":U.
define variable v-route-c-only-0 as character no-undo initial
"c-dis-card~
,c-dis-host~
,c-sysconf~
,c-trn-reason-host~
,c-curr-accnt":U.
define variable v-reply-through-news as character no-undo initial
"ext-file-par":U.
define variable v-obj-tables as character no-undo  initial
"gds-obj~
,dis-obj~
,gds-obj-attr~
,gds-obj-prop-attr~
,fbr-gds-obj~
,varianty-delivery-gds-obj~
,curr-shop~
,price-doc~
,fbr-pln~
,rvs-doc~
,rvs-line~
,icnt-doc~
,inkas":U.
define variable v-c-obj-tables as character no-undo  initial
"c-gds-obj-attr~
,c-gds-obj-ref~
,c-fbr-gds-obj~
,c-varianty-delivery-gds-obj~
,c-dis-obj":U.
define variable v-c-obj-tables-todo as character no-undo  initial
"c-fbr-gds-obj~
,c-varianty-delivery-gds-obj~
,c-dis-obj~
,c-inkas~
,c-trn-doc~
,c-price-doc~
,c-fbr-pln~
,c-rvs-doc~
,c-rvs-line~
,c-wth-doc":U.
define variable v-c-quest-context-global-only-0 as character no-undo initial
"c-bar-code-obj-attr~
,c-dis-rule~
,c-s-coeff~
,c-dis-dct-rule~
,c-dis-dc-rule~
,c-dis-cp-rule~
,c-dis-gds-rule~
,c-dis-grp-rule~
,c-dis-some-rule~
,c-thbj-attr":U.
define variable v-quest-context as character no-undo initial
"s-coeff":U.
define variable v-quest-context-todo as character no-undo initial
"":U.
define variable v-quest-context-global-only-0 as character no-undo initial
"bar-code-obj-attr~
,dis-card-property~
,dis-rule~
,dis-dc-rule~
,dis-cp-rule~
,dis-dct-rule~
,dis-gds-rule~
,dis-grp-rule
,dis-some-rule~
,dis-gds-rule-attr~
":U.
define variable v-quest-context-glob-nosend as character no-undo initial
"~
fin-doc~
,c-fin-doc~
":U.
define variable v-main-firm-db-0-not-news as character no-undo initial
"~
arh-fin-doc-contr-schet-obj~
,arh-fin-doc-contr-s-nal-obj~
,arh-fin-doc-contr-s-tax-obj~
,arh-fin-doc-c-s-tax-nal-obj~
,arh-fin-doc-schet-obj~
,arh-fin-doc-schet-nal-obj~
":U.
define variable v-0-rdb-not-news_rbd-0 as character no-undo initial
"db-attr~
,hist-nws-option~
,c-dis-card-type~
,c-dis-card-type-attr~
,c-dis-dct-rule~
,c-dis-card-mask~
,c-prop-ref~
,c-rp-by-call~
,c-rule-by-call~
,c-rule-call-param~
,c-layout~
,c-layout-elem~
":U.
define variable v-rbd-0 as character no-undo initial
"esys-route~
,esys-all-attr~
":U.
define variable v-db-num-tables as character no-undo initial
"config":U.
define variable v-c-db-num-tables as character no-undo initial
"c-config":U.
define variable v-shop-tables as character no-undo  initial
"cash-desk-attr":U.
define variable v-c-shop-tables as character no-undo initial
"c-cash-desk-attr":U.
define variable v-custom-list as character no-undo initial
"blob-bind~
,blob-data~
,c-ord-doc~
,c-staff~
,c-schet-fact-doc~
,clob-bind~
,clob-data~
,doc-attr~
,gds-grp-obj-attr~
,ord-cons~
,ord-doc~
,ord-doc-rcv~
,price-all~
,price-doc-forming~
,schet-fact-doc~
,staff~
,trn-doc~
,wth-doc~
,wth-doc-attr~
,c-dis-grp-rule~
,season~
,season-attr~
,gds-season~
,gds-season-attr~
,user-host~
,user-obj~
,user-login-attr~
,user-login-action-role~
,user-login-action-item~
,action-role~
,action-role-item~
,action-role-item-gds~
,action-role-item-gds-grp~
,c-user-login~
,user-menu-group~
,user-login~
,vsd~
,vsd-attr~
,utd~
":U.
define variable v-custom-except-list as character no-undo initial "".
define variable v-custom-0-rdb-not-news as character no-undo initial "".
define variable v-custom-except-list-erprn as character no-undo.
v-custom-except-list-erprn =
"c-*
,add-doc~
,add-line~
,add-trn~
,add-trn-attr~
,assortment-matrix~
,assortment-matrix-attr~
,assortment-matrix-goods~
,assortment-matrix-goods-attr~
,auto-tank~
,auto-section~
,auto-tank-attr~
,auto-section-attr~
,auto-tank-meas~
,auto-tank-meas-attr~
,bar-code~
,bar-code-attr~
,bar-code-obj-attr~
,cash-pay~
,cash-pay-attr~
,chk-discnt~
,chk-discnt-attr~
,chk-doc~
,chk-doc-attr~
,chk-gds~
,chk-gds-attr~
,chk-gds-pay~
,chk-pay~
,chk-pay-attr~
,clients~
,clients-attr~
,contract~
,contract-attr~
,contract-line~
,contract-line-attr~
,contract-specif~
,contract-specif-attr~
,country~
,country-attr~
,currency~
,currency-attr~
,doc-attr~
,doc-fbr-gds~
,doc-fbr-gds-attr~
,doc-line~
,doc-line-attr~
,doc-line-sum~
,doc-pl~
,doc-pl-attr~
,doc-pl-pump~
,doc-pl-pump-attr~
,fbr-doc~
,fbr-gds-grp~
,fbr-gds-grp-attr~
,fbr-gds-obj~
,fbr-gds-obj-attr~
,fbr-history~
,fbr-line~
,fbr-pln~
,fbr-pln-line~
,fbr-prn~
,fbr-prn-attr~
,fbr-prn-gds~
,fbr-prn-gds-attr~
,fbr-prn-grp~
,fbr-prn-grp-attr~
,fbr-recipe~
,fbr-recipe-gds~
,fin-bank~
,fin-bank-attr~
,fin-code-an-uchet~
,fin-code-an-uchet-attr~
,fin-code-cel-nazn~
,fin-code-cel-nazn-attr~
,fin-code-cor-acc~
,fin-code-cor-acc-attr~
,fin-connect~
,fin-connect-attr~
,fin-doc~
,fin-doc-attr~
,fin-doc-cor-acc-lk~
,fin-doc-cor-acc-lk-attr~
,fin-doc-obj~
,fin-doc-obj-attr~
,fin-doc-schet-lk~
,fin-doc-schet-lk-attr~
,fin-doc-tax~
,fin-doc-tax-attr~
,fin-gds-part~
,fin-gds-part-attr~
,fin-ob~
,fin-ob-attr~
,fin-ob-before~
,fin-ob-cor-acc-lk~
,fin-ob-cor-acc-lk-attr~
,fin-ob-schet-lk~
,fin-ob-schet-lk-attr~
,fin-ob-tax~
,fin-ob-tax-attr~
,fin-ob-tax-before~
,fin-ob-trn~
,fin-ob-trn-attr~
,fin-schet~
,fin-schet-attr~
,fin-statement~
,fin-statement-attr~
,fin-statement-line~
,fin-statement-line-attr~
,firm~
,gds-add-charges~
,gds-add-charges-attr~
,gds-dtl~
,gds-dtl-attr~
,gds-grp~
,gds-grp-attr~
,gds-grp-obj~
,gds-grp-obj-attr~
,gds-host-attr~
,gds-obj~
,gds-obj-attr~
,gds-obj-flag~
,gds-obj-flag-attr~
,gds-obj-prop~
,gds-obj-prop-attr~
,gds-prt~
,gds-prt-attr~
,gds-season~
,gds-season-attr~
,goods~
,goods-attr~
,icnt-doc~
,icnt-line~
,inkas~
,inkas-pay~
,inkas-pay-attr~
,inkas-pay-desk~
,inkas-pay-desk-attr~
,inkas-pay-wth~
,inv-doc~
,inv-doc-attr~
,inv-line~
,inv-line-attr~
,nozzle~
,nozzle-attr~
,ot-line~
,ot-line-attr~
,ot-supp-line~
,ot-supp-line-attr~
,ot-supp-tot~
,ot-supp-tot-attr~
,ot-tot~
,ot-tot-attr~
,parts~
,parts-add~
,parts-add-attr~
,parts-attr~
,parts-obj-attr~
,parts-root~
,parts-root-attr~
,parts-supp~
,parts-supp-attr~
,pay-type~
,pay-type-attr~
,payment~
,payment-attr~
,person~
,pl-gds~
,pl-gds-attr~
,pl-gds-pump~
,pl-gds-pump-attr~
,pl-level~
,pl-level-attr~
,pl-level-imp~
,pl-level-mm~
,pl-level-mm-imp~
,pl-pump~
,pl-pump-attr~
,pl-pump-nozzle~
,pl-pump-nozzle-attr~
,place~
,place-attr~
,place-imp~
,place-imp-attr~
,place-io~
,place-io-attr~
,price-all~
,price-all-attr~
,price-doc~
,price-doc-forming~
,price-doc-forming-attr~
,price-doc-forming-gds~
,price-doc-forming-gds-qnty~
,price-doc-forming-gds-sum~
,price-doc-forming-gds-tnv~
,price-doc-forming-gdsattr~
,price-list~
,price-list-attr~
,price-list-type~
,price-list-type-attr~
,price-list-type-cash-pay~
,price-list-type-cassa~
,price-list-type-cassa-attr~
,price-list-type-gds-grp~
,price-list-type-gds-grp-attr~
,price-list-type-pay-type~
,prod-bc~
,prod-bc-attr~
,prod-bc-db~
,prod-bc-db-attr~
,profile-by-profile~
,prt-obj~
,prt-obj-attr~
,pump~
,pump-attr~
,pump-nozzle~
,pump-nozzle-attr~
,recipe~
,recipe-develop~
,recipe-gds~
,regions~
,regions-attr~
,norm-loss~
,rvs-doc~
,rvs-doc-attr~
,rvs-line~
,rvs-line-attr~
,rvs-line-pump~
,rvs-line-pump-attr~
,rvs-pump~
,rvs-pump-attr~
,s-coeff~
,s-coeff-attr~
,sale-doc~
,sale-doc-attr~
,sert~
,sert-attr~
,sert-join~
,sert-join-attr~
,shift-cash~
,shift-cash-attr~
,shift-staff~
,shift-staff-attr~
,shop~
,sr-izmerenia~
,staff~
,staff-attr~
,stk-line~
,stk-line-attr~
,stk-supp-line~
,stk-supp-line-attr~
,stk-supp-tot~
,stk-supp-tot-attr~
,stk-tot~
,stk-tot-attr~
,store~
,trn-doc~
,trn-doc-sum~
,trn-reason~
,trn-reason-host~
,trn-reason-obj~
,trn-rsn-attr~
,units~
,units-attr~
,tax-rate-gds~
,tax-rate-gds-attr~
,tax-rate-gds-grp~
,tax-rate-gds-grp-attr~
,dis-card~
,dis-card-long~
,dis-card-long-attr~
,dis-card-mask~
,dis-card-mask-attr~
,dis-card-property~
,dis-card-type~
,dis-card-type-attr~
,dis-cfg-rule~
,dis-cfg-rule-attr~
,dis-cp-rule~
,dis-cp-rule-attr~
,dis-dc-rule~
,dis-dc-rule-attr~
,dis-dct-rule~
,dis-dct-rule-attr~
,dis-gds-rule~
,dis-gds-rule-attr~
,dis-grp-rule~
,dis-grp-rule-attr~
,dis-host~
,dis-obj~
,dis-rule~
,dis-rule-attr~
,dis-some-rule~
,dis-some-rule-attr~
,dis-thbj-rule~
,dis-thbj-rule-attr~
,dis-time-rule~
,dis-time-rule-attr~
,vsd~
,vsd-attr~
,operserv~
,operservattr~
,cashbook~
,cashbookattr~
,cashbookrule~
,cashbookruleattr~
,PromoAction~
,PromoCriterion~
,PromoGift~
,PromoGoods~
,PromoObject~
,PromoAttr~
,promo-schedule~
,promo-schedule-week~
,marking~
,marking-attr~
,marking-chk~
,marking-lines~
,utd~
,utd-attr~
,utd-err~
,utd-err-attr~
,utd-lines~
,utd-lines-attr~
,utd-marking-lines~
,utd-marking-lines-attr~
,tran-fuel~
,chk-slip-head~
,chk-slip-string~
,order-doc~
,order-line~
,order-doc-attr~
,order-line-attr~
":U.
define variable v-custom-0-rdb-not-news-erprn as character no-undo initial
"c-shop~
,c-store~
,c-firm~
,shop~
,store~
,firm~
,clients~
,clients-attr~
,clients~
,clients-attr~
,c-currency~
,c-currency-attr~
,currency~
,currency-attr~
,c-country~
,c-country-attr~
,country~
,country-attr~
,regions~
,regions-attr~
,c-regions~
,norm-loss~
,c-norm-loss~
,c-pay-type~
,c-pay-type-attr~
,pay-type~
,pay-type-attr~
,c-dis-card~
,c-dis-card-long~
,c-dis-card-long-attr~
,c-dis-card-mask~
,c-dis-card-mask-attr~
,c-dis-card-property~
,c-dis-card-type~
,c-dis-card-type-attr~
,c-dis-cfg-rule~
,c-dis-cp-rule~
,c-dis-dc-rule~
,c-dis-dct-rule~
,c-dis-gds-rule~
,c-dis-grp-rule~
,c-dis-host~
,c-dis-obj~
,c-dis-rule~
,c-dis-rule-attr~
,c-dis-some-rule~
,c-dis-thbj-rule~
,c-dis-time-rule~
,dis-card~
,dis-card-long~
,dis-card-long-attr~
,dis-card-mask~
,dis-card-mask-attr~
,dis-card-property~
,dis-card-type~
,dis-card-type-attr~
,dis-cfg-rule~
,dis-cfg-rule-attr~
,dis-cp-rule~
,dis-cp-rule-attr~
,dis-dc-rule~
,dis-dc-rule-attr~
,dis-dct-rule~
,dis-dct-rule-attr~
,dis-gds-rule~
,dis-gds-rule-attr~
,dis-grp-rule~
,dis-grp-rule-attr~
,dis-host~
,dis-obj~
,dis-rule~
,dis-rule-attr~
,dis-some-rule~
,dis-some-rule-attr~
,dis-thbj-rule~
,dis-thbj-rule-attr~
,dis-time-rule~
,dis-time-rule-attr~
,c-fin-code-an-uchet~
,c-fin-code-cel-nazn~
,c-fin-code-cor-acc~
,c-fin-schet~
,c-fin-schet-attr~
,fin-schet~
,fin-schet-attr~
,fin-code-an-uchet~
,fin-code-an-uchet-attr~
,fin-code-cel-nazn~
,fin-code-cel-nazn-attr~
,fin-code-cor-acc~
,fin-code-cor-acc-attr~
,c-trn-reason~
,c-trn-reason-host~
,c-trn-reason-obj~
,c-trn-rsn-attr~
,trn-reason~
,trn-reason-host~
,trn-reason-obj~
,trn-rsn-attr~
,pay-type~
,pay-type-attr~
,c-pay-type~
,c-pay-type-attr~
,cash-pay~
,c-cash-pay~
,cash-pay-attr~
,c-cash-pay-attr~
,auto-tank~
,auto-section~
,auto-section-table~
,auto-tank-meas~
,c-auto-tank~
,c-auto-tank-attr~
,c-auto-section~
,c-auto-section-attr~
,c-auto-section-table~
,auto-tank-attr~
,auto-section-attr~
,c-auto-tank-meas-attr~
,gds-mercury~
,gds-mercury-attr~
":U.
procedure call-nws_get-variable-names :
define output parameter p-variable-names as character no-undo .
  do
  on error undo, return error
  :
     assign
     p-variable-names = 'v-0-rdb-not-news
,v-0-rdb-and-from-news~
,v-rdb-0-not-news~
,v-0-rdb_rbd-0-not-news~
,v-0-remote-stock~
,v-0-rdb-no-src_rdb-0-no-news~
,v-route-c-glob-context~
,v-route-c-quest-context~
,v-route-c-shapka-context~
,v-route-c-only-0~
,v-reply-through-news~
,v-obj-tables~
,v-c-obj-tables~
,v-c-obj-tables-todo~
,v-c-quest-context-global-only-0~
,v-quest-context~
,v-quest-context-todo~
,v-quest-context-global-only-0~
,v-0-rdb-not-news_rbd-0~
,v-rbd-0~
,v-db-num-tables~
,v-c-db-num-tables~
,v-shop-tables~
,v-c-shop-tables~
,v-custom-list~
':U.
  end.
end procedure.
procedure call-nws_get-variable-value :
define input parameter p-variable-name as character no-undo .
define output parameter p-variable-value as character no-undo .
  do
  on error undo, return error
  :
    case p-variable-name:
      when 'v-0-rdb-not-news':U then do:
         assign
         p-variable-value = v-0-rdb-not-news
         .
      end.
      when 'v-0-rdb-and-from-news':U then do:
         assign
         p-variable-value = v-0-rdb-and-from-news
         .
      end.
      when 'v-rdb-0-not-news':U then do:
         assign
         p-variable-value = v-rdb-0-not-news
         .
      end.
      when 'v-0-rdb_rbd-0-not-news':U then do:
         assign
         p-variable-value = v-0-rdb_rbd-0-not-news
         .
      end.
      when 'v-0-remote-stock':U then do:
         assign
         p-variable-value = v-0-remote-stock
         .
      end.
      when 'v-0-rdb-no-src_rdb-0-no-news':U then do:
         assign
         p-variable-value = v-0-rdb-no-src_rdb-0-no-news
         .
      end.
      when 'v-route-c-glob-context':U then do:
         assign
         p-variable-value = v-route-c-glob-context
         .
      end.
      when 'v-route-c-quest-context':U then do:
         assign
         p-variable-value = v-route-c-quest-context
         .
      end.
      when 'v-route-c-shapka-context':U then do:
         assign
         p-variable-value = v-route-c-shapka-context
         .
      end.
      when 'v-route-c-only-0':U then do:
         assign
         p-variable-value = v-route-c-only-0
         .
      end.
      when 'v-reply-through-news':U then do:
         assign
         p-variable-value = v-reply-through-news
         .
      end.
      when 'v-obj-tables':U then do:
         assign
         p-variable-value = v-obj-tables
         .
      end.
      when 'v-c-obj-tables':U then do:
         assign
         p-variable-value = v-c-obj-tables
         .
       end.
      when 'v-c-obj-tables-todo':U then do:
         assign
         p-variable-value = v-c-obj-tables-todo
         .
      end.
      when 'v-c-quest-context-global-only-0':U then do:
         assign
         p-variable-value = v-c-quest-context-global-only-0
         .
      end.
      when 'v-quest-context':U then do:
         assign
         p-variable-value = v-quest-context
         .
      end.
      when 'v-quest-context-todo':U then do:
         assign
         p-variable-value = v-quest-context-todo
         .
      end.
      when 'v-quest-context-global-only-0':u then do:
         assign
         p-variable-value = v-quest-context-global-only-0
         .
      end.
      when 'v-0-rdb-not-news_rbd-0':U then do:
         assign
         p-variable-value = v-0-rdb-not-news_rbd-0
         .
      end.
      when 'v-rbd-0':U then do:
         assign
         p-variable-value = v-rbd-0
         .
      end.
      when 'v-db-num-tables':U then do:
         assign
         p-variable-value = v-db-num-tables
         .
      end.
      when 'v-c-db-num-tables':U then do:
         assign
         p-variable-value = v-c-db-num-tables
         .
      end.
      when 'v-shop-tables':u then do:
         assign
         p-variable-value = v-shop-tables
         .
      end.
      when 'v-c-shop-tables':U then do:
         assign
         p-variable-value = v-c-shop-tables
         .
      end.
      when 'v-custom-list':U then do:
         assign
         p-variable-value = v-custom-list
         .
      end.
    end case.
  end.
end procedure.
define variable attach-list as character no-undo initial '~
abc-analysis-attr~
,abc-analysis-doc~
,abc-analysis-gds-obj~
,abc-analysis-gds-obj-attr~
,abc-analysis-goods~
,abc-analysis-goods-attr~
,abc-analysis-grp~
,abc-analysis-obj~
,abc-analysis-period~
,abc-analysis-prod~
,abcxyz-analysis-attr~
,abcxyz-analysis-goods~
,abcxyz-analysis-goods-attr~
,add-line~
,add-trn~
,add-trn-attr~
,arh-trn-doc-contract~
,c-buyer-in-buyer-group~
,c-buyer-group~
,c-pl-gds-obj~
,c-sht-hist~
,cd-doc-line~
,c-cd-doc-line~
,chk-discnt~
,chk-discnt-attr~
,c-chk-discnt~
,chk-doc~
,chk-doc-attr~
,c-chk-doc-attr~
,chk-gds~
,chk-gds-attr~
,marking-chk~
,c-marking-chk~
,c-marking-attr~
,c-chk-gds~
,chk-pay~
,chk-gds-attr~
,chk-pay-attr~
,c-chk-pay~
,contract-line~
,contract-specif-attr~
,c-contract-line~
,db-grp-obj-price~
,c-db-grp-obj-price~
,doc-abc-def-doc~
,doc-abc-def-obj~
,c-doc-attr~
,doc-fbr-gds~
,c-doc-fbr-gds~
,doc-line~
,c-doc-line~
,doc-line-attr~
,c-doc-line-attr~
,doc-line-sum~
,c-doc-line-sum~
,doc-pl~
,c-doc-pl~
,doc-pl-pump~
,c-doc-pl-pump~
,doc-prts~
,c-doc-prts~
,doc-xyz-def-doc~
,doc-xyz-def-obj~
,esys-route-dump~
,factur-connect-line~
,fbr-line~
,c-fbr-line~
,fbr-pln-line~
,c-fbr-pln-line~
,c-fin-code-an-uchet~
,c-fin-code-cel-nazn~
,c-fin-code-cor-acc~
,fin-doc-attr~
,c-fin-doc-attr~
,fin-doc-tax~
,c-fin-doc-tax~
,fin-gds-part~
,c-fin-gds-part~
,fin-ob-attr~
,c-fin-ob-attr~
,fin-ob-tax~
,c-fin-ob-tax~
,fin-ob-tax-before~
,fin-ob-trn~
,fin-statement-attr~
,c-fin-statement-attr~
,fin-statement-line~
,c-fin-statement-line~
,gds-dtl~
,c-gds-dtl~
,c-global-state~
,global-state-attr~
,c-global-state-attr~
,host-grp-obj-price~
,c-host-grp-obj-price~
,icnt-line~
,inkas-pay~
,c-inkas-pay~
,inkas-pay-desk~
,c-inkas-pay-desk~
,inkas-pay-wth~
,c-inkas-pay-wth~
,inv-doc~
,inv-line~
,c-inv-line~
,layout-elem-rule~
,obj-grp-obj-price~
,c-obj-grp-obj-price~
,ord-cons-attr~
,ord-cons-line-attr~
,ord-doc-attr~
,c-ord-doc-attr~
,ord-dtl~
,c-ord-dtl~
,ord-dtl-cons~
,ord-dtl-rcv~
,ord-gds-cons~
,ord-line~
,c-ord-line~
,ord-line-attr~
,c-ord-line-attr~
,ord-line-rcv~
,ord-rcv-attr~
,ord-rcv-line-attr~
,c-parts~
,c-parts-attr~
,parts-root~
,c-parts-root~
,esys-pck-keys~
,c-price-doc-forming~
,price-doc-forming-attr~
,c-price-doc-forming-attr~
,price-doc-forming-gds~
,c-price-doc-forming-gds~
,price-doc-forming-gdsattr~
,c-price-doc-forming-gdsattr~
,price-doc-forming-gds-qnty~
,c-price-doc-forming-gds-qnty~
,price-doc-forming-gds-sum~
,c-price-doc-forming-gds-sum~
,price-doc-forming-gds-tnv~
,c-price-doc-forming-gds-tnv~
,price-list~
,c-price-list~
,price-list-attr~
,c-price-list-attr~
,price-list-type-attr~
,c-price-list-type-attr~
,price-list-type-cash-pay~
,c-price-list-type-cash-pay~
,price-list-type-cassa~
,c-price-list-type-cassa~
,price-list-type-gds-grp~
,c-price-list-type-gds-grp~
,price-list-type-pay-type~
,c-price-list-type-pay-type~
,c-qnty-group~
,qnty-in-qnty-group~
,c-qnty-in-qnty-group~
,rang-abc-def-obj~
,rang-xyz-def-obj~
,rule-i-script~
,rule-script~
,rule-trans-memo~
,rvs-line~
,rvs-line-attr~
,c-rvs-line~
,rvs-line-pump~
,c-rvs-line-pump~
,rvs-pump~
,sale-doc~
,c-sale-doc~
,schet-fact-line~
,c-schet-fact-line~
,shift-cash~
,c-shift-obj~
,shift-staff~
,c-shift-staff~
,shift-attr~
,c-shift-attr~
,stop-list-line~
,c-sum-group~
,sum-in-sum-group~
,c-sum-in-sum-group~
,c-turnover-group~
,tnv-in-turnover-group~
,c-tnv-in-turnover-group~
,trn-doc-sum~
,c-trn-doc-sum~
,c-trn-reason~
,trn-reason-host~
,c-trn-reason-host~
,trn-reason-obj~
,c-trn-reason-obj~
,trn-rsn-attr~
,c-trn-rsn-attr~
,turnover-buyer~
,turnover-buyer-attr~
,turnover-buyer-gds~
,turnover-buyer-gds-attr~
,wi-mode~
,wth-dtl~
,c-wth-dtl~
,wth-line~
,c-wth-line~
,wth-parts~
,c-wth-parts~
,xyz-analysis-attr~
,xyz-analysis-doc~
,xyz-analysis-gds-obj~
,xyz-analysis-gds-obj-attr~
,xyz-analysis-goods~
,xyz-analysis-goods-attr~
,xyz-analysis-obj~
,xyz-analysis-period~
,utd-lines~
,utd-marking-lines~
,utd-err~
,utd-attr~
,utd-lines-attr~
,utd-marking-lines-attr~
,utd-err-attr~
,marking~
,marking-lines~
,order-doc~
,order-line~
,reportShift~
,shift-param~
,susp-chk~
':U .
define variable news-list as character no-undo initial '~
abc-analysis~
,abcxyz-analysis~
,add-doc~
,action-post~
,action-post-host~
,action-post-menu-group~
,action-post-obj~
,action-post-role~
,action-post-user-login~
,action-role~
,c-action-role~
,action-role-item~
,c-action-role-item~
,action-role-item-gds~
,action-role-item-gds-grp~
,alc-sale-lic~
,c-alc-sale-lic~
,alc-sale-lic-attr~
,c-alc-sale-lic-attr~
,alc-sale-lic-type~
,c-alc-sale-lic-type~
,alc-supp-lic~
,c-alc-supp-lic~
,alc-supp-lic-attr~
,c-alc-supp-lic-attr~
,alc-supp-lic-type~
,c-alc-supp-lic-type~
,alc-type~
,c-alc-type~
,alc-type-attr~
,c-alc-type-attr~
,alc-type-gds~
,c-alc-type-gds~
,arh-fin-doc-an~
,arh-fin-doc-an-nal~
,arh-fin-doc-c-schet-tax-nal~
,arh-fin-doc-contr-schet~
,arh-fin-doc-contr-schet-nal~
,arh-fin-doc-contr-schet-tax~
,arh-fin-doc-schet~
,arh-fin-doc-schet-nal~
,arh-fin-doc-schet-tax~
,arh-fin-doc-schet-tax-nal~
,arh-fin-doc-contr-schet-obj~
,arh-fin-doc-contr-s-nal-obj~
,arh-fin-doc-contr-s-tax-obj~
,arh-fin-doc-c-s-tax-nal-obj~
,arh-fin-doc-schet-obj~
,arh-fin-doc-schet-nal-obj~
,arh-fin-ob-contr~
,attr-prop~
,auto-tank~
,c-auto-tank~
,auto-tank-meas~
,auto-tank-attr~
,auto-section~
,c-auto-section~
,auto-section-attr~
,c-auto-section-attr~
,auto-section-table~
,c-auto-section-table~
,bar-code~
,c-bar-code~
,bar-code-attr~
,c-bar-code-attr~
,bar-code-obj-attr~
,c-bar-code-obj-attr~
,blob-bind~
,buyer-group~
,buyer-in-buyer-group~
,c-cli-hist~
,c-dc-hist~
,c-fbr-gds-grp-hist~
,c-gds-grp-hist~
,c-gds-hist~
,c-nzl-hist~
,c-plc-hist~
,c-pmp-hist~
,c-recipe-hist~
,c-table-bind~
,c-tax-hist~
,c-usr-hist~
,c-wth-hist~
,cash-desk~
,c-cash-desk~
,cash-desk-attr~
,c-cash-desk-attr~
,cash-pay~
,c-cash-pay~
,cash-pay-attr~
,c-cash-pay-attr~
,cd-clu~
,c-cd-clu~
,cd-dlu~
,c-cd-dlu~
,cd-doc~
,c-cd-doc~
,cd-events~
,cd-events-attr~
,cd-event-log~
,cd-event-log-attr~
,cd-grp~
,c-cd-grp~
,cd-plu~
,c-cd-plu~
,c-chk-doc~
,cd-trans~
,cd-video-link~
,cd-video-link-attr~
,cli-art~
,cli-gds~
,cli-grp~
,c-cli-grp~
,clients~
,c-clients~
,clients-attr~
,c-clients-attr~
,clob-bind~
,code-range~
,condition-keeping~
,c-condition-keeping~
,config~
,c-config~
,contract~
,c-contract~
,contract-attr~
,contract-specif~
,c-contract-specif~
,country~
,c-country~
,criterion-analysis~
,cshr-month~
,curr-accnt~
,c-curr-accnt~
,curr-bank~
,c-curr-bank~
,curr-shop~
,currency~
,custom-labels~
,datatype-exp~
,datatype-exp-attr~
,datatype-imp~
,datatype-imp-attr~
,datatype-table~
,datatype-table-exp~
,datatype-table-field~
,datatype-table-field-exp~
,datatype-table-field-imp~
,datatype-table-imp~
,db~
,c-db~
,db-attr~
,db-info~
,db-status~
,deliv-type-cond-keep~
,c-deliv-type-cond-keep~
,delivery-subject~
,c-delivery-subject~
,delivery-type~
,c-delivery-type~
,delivery-type-subject~
,c-delivery-type-subject~
,dis-card~
,c-dis-card~
,dis-card-long~
,c-dis-card-long~
,dis-card-mask~
,c-dis-card-mask~
,dis-card-mask-attr~
,c-dis-card-mask-attr~
,dis-card-property~
,c-dis-card-property~
,dis-card-type~
,c-dis-card-type~
,dis-card-type-attr~
,c-dis-card-type-attr~
,dis-cfg-rule~
,c-dis-cfg-rule~
,dis-cp-rule~
,c-dis-cp-rule~
,dis-dc-rule~
,c-dis-dc-rule~
,dis-dct-rule~
,c-dis-dct-rule~
,dis-gds-rule~
,c-dis-gds-rule~
,dis-gds-rule-attr~
,dis-grp-rule~
,c-dis-grp-rule~
,dis-host~
,c-dis-host~
,dis-obj~
,c-dis-obj~
,dis-rule~
,c-dis-rule~
,dis-some-rule~
,c-dis-some-rule~
,dis-thbj-rule~
,c-dis-thbj-rule~
,dis-time-rule~
,c-dis-time-rule~
,doc-abc-def~
,doc-attr~
,doc-xyz-def~
,drt-prop~
,c-drt-prop~
,edi-status~
,esys-all-attr~
,esys-datatype-exp~
,c-esys-datatype-exp~
,esys-datatype-imp~
,c-esys-datatype-imp~
,esys-pck-rcvd~
,esys-pck-rcvd-err~
,esys-pck-sent~
,esys-route~
,ex-mark~
,c-ex-mark~
,ext-artic~
,c-ext-artic~
,ext-artic-attr~
,c-ext-artic-attr~
,ext-classif~
,c-ext-classif~
,ext-file~
,ext-file-line~
,ext-file-par~
,ext-system~
,c-ext-system~
,ext-system-attr~
,factur-connect~
,fbr-doc~
,c-fbr-doc~
,fbr-gds-grp~
,c-fbr-gds-grp~
,fbr-gds-grp-attr~
,c-fbr-gds-grp-attr~
,fbr-gds-obj~
,c-fbr-gds-obj~
,fbr-history~
,fbr-pln~
,c-fbr-pln~
,fbr-prn~
,c-fbr-prn~
,fbr-prn-gds~
,c-fbr-prn-gds~
,fbr-prn-grp~
,c-fbr-prn-grp~
,fbr-recipe~
,fbr-recipe-gds~
,fin-bank~
,c-fin-bank~
,fin-code-an-uchet~
,fin-code-cel-nazn~
,fin-code-cor-acc~
,fin-connect~
,fin-doc~
,c-fin-doc~
,fin-ob~
,c-fin-ob~
,fin-ob-before~
,fin-schet~
,c-fin-schet~
,fin-statement~
,c-fin-statement~
,firm~
,c-firm~
,gds-grp~
,c-gds-grp~
,gds-grp-attr~
,c-gds-grp-attr~
,gds-grp-obj~
,c-gds-grp-obj~
,gds-host-attr~
,c-gds-host-attr~
,gds-obj~
,gds-obj-attr~
,c-gds-obj-attr~
,gds-obj-prop~
,c-gds-obj-prop~
,gds-obj-prop-attr~
,assortment-matrix~
,assortment-matrix-attr~
,c-assortment-matrix~
,assortment-matrix-goods~
,c-assortment-matrix-goods~
,gds-prt~
,c-gds-prt~
,gds-season~
,c-gds-season~
,gds-add-charges~
,c-gds-add-charges~
,gds-grp-obj-attr~
,c-gds-obj-ref~
,global-state~
,goods~
,c-goods~
,goods-attr~
,c-goods-attr~
,group-period-validity~
,c-group-period-validity~
,grp-obj-price~
,c-grp-obj-price~
,hist-nws-option~
,c-hist-nws-option~
,icnt-doc~
,inkas~
,c-inkas~
,layout~
,c-layout~
,layout-elem~
,layout-elem-rule~
,c-layout-elem-rule~
,lvl-name~
,menu-user~
,menu-user-call~
,marking~
,marking-lines~
,nozzle~
,c-nozzle~
,nozzle-attr~
,c-nozzle-attr~
,nws-doc-hist~
,nws-outline~
,obj-date~
,ord-cons~
,ord-doc~
,c-ord-doc~
,ord-doc-rcv~
,ord-chain~
,parts~
,parts-attr~
,pay-type~
,c-pay-type~
,pck-rcvd~
,pck-sent~
,person~
,c-person~
,pl-gds~
,c-pl-gds~
,pl-gds-attr~
,c-pl-gds-attr~
,pl-gds-pump~
,c-pl-gds-pump~
,pl-level~
,pl-level-imp~
,c-pl-level~
,pl-level-mm~
,pl-level-mm-imp~
,pl-pump~
,c-pl-pump~
,pl-pump-nozzle~
,c-pl-pump-nozzle~
,place~
,c-place~
,place-attr~
,c-place-attr~
,place-imp~
,place-imp-attr~
,place-io~
,c-place-io~
,point-io~
,c-point-io~
,point-place-rel~
,c-point-place-rel~
,point-point-rel~
,c-point-point-rel~
,price-all~
,price-doc~
,c-price-doc~
,price-doc-forming~
,c-price-doc-forming~
,price-list-type~
,c-price-list-type~
,prod-bc~
,c-prod-bc~
,prod-bc-db~
,profile-by-profile~
,c-profile-by-profile~
,prop-head~
,c-prop-head~
,prop-map~
,prop-ref~
,c-prop-ref~
,prop-ref-call~
,prop-ruleset~
,prop-script~
,prt-obj~
,pscript-ruleset~
,pump~
,c-pump~
,pump-attr~
,c-pump-attr~
,pump-nozzle~
,c-pump-nozzle~
,qnty-group~
,rang-abc-def~
,rang-xyz-def~
,recipe~
,c-recipe~
,recipe-develop~
,c-recipe-develop~
,recipe-gds~
,c-recipe-gds~
,regions~
,c-regions~
,norm-loss~
,c-norm-loss~
,rp-by-call~
,c-rp-by-call~
,rp-rule-param~
,rpt-option~
,rule~
,rule-by-call~
,c-rule-by-call~
,rule-by-profile~
,rule-by-set~
,rule-call-param~
,c-rule-call-param~
,rule-profile~
,rule-process~
,ruledict~
,c-ruledict~
,ruledict-param~
,ruleset~
,rvs-doc~
,c-rvs-doc~
,s-coeff~
,c-s-coeff~
,scales~
,c-scales~
,scales-attr~
,c-scales-attr~
,scales-gds~
,c-scales-gds~
,scales-grp~
,c-scales-grp~
,schedule~
,schedule-attr~
,schet-fact-doc~
,c-schet-fact-doc~
,season~
,c-season~
,sert~
,c-sert~
,sert-join~
,shift-obj~
,c-shift-obj~
,shift-period~
,shop~
,c-shop~
,some-lk~
,sr-izmerenia~
,c-sr-izmerenia~
,sr-izmerenia-attr~
,c-sr-izmerenia-attr~
,staff~
,c-staff~
,stop-list~
,store~
,c-store~
,sum-group~
,sum-grp~
,c-sum-grp~
,sum-grp-obj~
,c-sum-grp-obj~
,sysconf~
,c-sysconf~
,tare~
,c-tare~
,tax~
,c-tax~
,tax-rate~
,c-tax-rate~
,tax-rate-gds~
,tax-rate-gds-grp~
,c-tax-rate-gds-grp~
,tax-rate-value~
,tax-units~
,c-tax-units~
,thbj-attr~
,c-thbj-attr~
,trn-doc~
,c-trn-doc~
,trn-reason~
,turnover-buyer-main~
,turnover-group~
,units~
,c-units~
,upgrade~
,user-account~
,c-user-account~
,user-context-history~
,user-host~
,user-login~
,c-user-login~
,user-login-action-item~
,user-login-action-role~
,user-login-attr~
,user-menu-group~
,user-obj~
,user-window-attr~
,var-deliv-gr-per-val~
,c-var-deliv-gr-per-val~
,variant-delivery~
,c-variant-delivery~
,varianty-delivery-gds-obj~
,c-varianty-delivery-gds-obj~
,wealth~
,c-wealth~
,who-lk~
,wth-doc~
,c-wth-doc~
,wth-doc-attr
,wth-gds~
,c-wth-gds~
,wth-ser~
,c-wth-ser~
,wth-par~
,c-wth-par~
,wth-place~
,c-wth-place~
,xyz-analysis~
,c-user-log~
,egais-clients~
,c-egais-clients~
,egais-gds~
,c-egais-gds~
,c-vsd~
,c-gds-mercury
,vsd~
,vsd-attr~
,c-gds-mercury~
,gds-mercury~
,gds-mercury-attr~
,units-attr~
,c-promo-schedule~
,c-promo-schedule-week~
,c-PromoAction~
,c-PromoAttr~
,c-PromoCriterion~
,c-PromoGift~
,c-PromoGoods~
,c-PromoObject~
,promo-schedule~
,promo-schedule-week~
,PromoAction~
,PromoAttr~
,PromoCriterion~
,PromoGift~
,PromoGoods~
,PromoObject~
,tech-prol-pwd~
,c-tech-prol-pwd~
,c-CashBook~
,c-CashBookAttr~
,c-CashBookRule~
,c-CashBookRuleAttr~
,c-OperServ~
,c-operServAttr~
,CashBook~
,CashBookAttr~
,CashBookRule~
,CashBookRuleAttr~
,OperServ~
,OperServAttr~
,c-counter~
,counter~
,c-cashbook-head~
,c-goods-attr-any~
,c-promo-head~
,code~
,c-code~
,devisPc~
,devisPc-attr~
,utd~
,c-utd-head~
,c-utd~
,c-utd-head~
,c-utd-lines~
,c-utd-marking-lines~
,c-utd-err~
,c-utd-attr~
,c-utd-lines-attr~
,c-utd-marking-lines-attr~
,c-utd-err-attr~
,marking-attr
,Xattr~
,xGroupObj~
,xstatus~
,c-contract-specif-attr~
,tran-fuel~
,chk-slip-head~
,chk-slip-string~
,c-marking
,order-doc~
,order-line~
,order-doc-attr~
,order-line-attr~
,c-order-head~
,c-order-doc~
,c-order-line~
,c-order-doc-attr~
,c-order-line-attr~
,reportShift~
,shift-param~
,susp-chk~
':U .
define variable oth-list1 as character no-undo initial '~
action-group~
,action-head~
,action-item~
,aht-doc~
,aht-gds~
,aht-ot-line~
,aht-ot-tot~
,aht-stk~
,aht-stk-line~
,aht-stk-tot~
,aht-time~
,archive-history~
,arh-fin-doc-an-nal-obj~
,arh-fin-doc-an-obj~
,arh-fin-doc-s-tax-nal-obj~
,arh-fin-doc-schet-tax-obj~
,arh-fin-ob-contr-obj~
,arh-wth-cli~
,arh-wth-cli-tot~
,arh-wth-cli-doc~
,arh-wth-tot~
,arh-wth-w-p~
,BatchProcess~
,cbr-bank~
,c-cbr-bank~
,chk-gds-pay~
,c-currency~
,db-filter~
,db-rec-attr~
,db-usr-flt~
,dish-grp~
,doc-fact-num~
,doc-filter~
,doc-filter-head~
,ext-artic-db~
,ext-artic-host~
,ext-artic-obj~
,feature~
,feature-scale~
,filter~
,c-fin-connect~
,fin-doc-cor-acc-lk~
,fin-doc-obj~
,fin-doc-schet-lk~
,fin-ob-cor-acc-lk~
,fin-ob-schet-lk~
,c-gds-obj~
,gds-obj-flag~
,gen-attr~
,h-route~
,h-route-dump~
,hold-attr~
,hold-gds-grp~
,hold-goods~
,hold-purch~
,hold-purch-grp~
,hold-purch-supp~
,hold-purch-supp-gds~
,hold-sale~
,hold-sale-grp~
,hold-time~
,hold-time-attr~
,hold-trn~
,host-lk~
,lang~
,c-layout-elem~
,menu-group~
,menu-head~
,menu-item~
,menu-item-group~
,nws-last-rec~
,ord-blank~
,ot-line~
,ot-supp-line~
,ot-supp-tot~
,ot-tot~
,parts-supp~
,payment~
,pck-keys~
,prod-bc-attr~
,c-prod-bc-attr~
,prog-message~
,prog-message-lang~
,rcs-attr~
,rcs-chkbody~
,rcs-chkhead~
,rcs-city~
,rcs-clients~
,rcs-country~
,rcs-destn~
,rcs-docbody~
,rcs-dochead~
,rcs-mark~
,rcs-pack~
,rcs-place~
,rcs-retail1action~
,rcs-retail1attr~
,rcs-retail1bank~
,rcs-retail1barcode~
,rcs-retail1bill~
,rcs-retail1billitem~
,rcs-retail1convolution~
,rcs-retail1delete~
,rcs-retail1fortuneproduct~
,rcs-retail1price~
,rcs-retail1priceitem~
,rcs-retail1product~
,rcs-retail1subject~
,rcs-shops~
,rename-fld~
,rep~
,rep-line~
,res-lang~
,resource~
,route~
,route-dump~
,route-dump-link~
,stk-line~
,stk-supp-line~
,stk-supp-tot~
,stk-tot~
,c-stop-list~
,c-stop-list-line~
,sys-ctrl~
,tmp-sale~
,tmp-sale-dtl~
,tmp-sale-gds~
,tnved-head~
,tnved-item~
,user-conn~
,usr-flt~
,usr-stko~
,whole-send-news~
,c-wi-mode~
,wth-obj~
,c-wth-obj~
,wth-pobj~
,c-wth-pobj~
,wth-gds-attr~
,c-wth-gds-attr~
,wth-ser-attr~
,c-wth-ser-attr~
,c-add-doc~
,c-add-line~
,c-parts-add~
,parts-add~
,gds-add-charges-attr~
,c-gds-add-charges-attr~
':U .
define variable oth-list2 as character no-undo initial '~
abc-analysis-doc-attr~
,abc-analysis-grp-attr~
,abc-analysis-obj-attr~
,abc-analysis-period-attr~
,abc-analysis-prod-attr~
,abc-analysis-cli~
,abc-analysis-cli-attr~
,action-group-attr~
,action-head-attr~
,action-item-attr~
,action-post-attr~
,action-post-host-attr~
,action-post-menu-group-attr~
,action-post-obj-attr~
,action-post-role-attr~
,action-post-user-login-attr~
,action-role-attr~
,action-role-item-attr~
,aht-doc-attr~
,aht-gds-attr~
,aht-ot-line-attr~
,aht-ot-tot-attr~
,aht-stk-attr~
,aht-stk-line-attr~
,aht-stk-tot-attr~
,aht-time-attr~
,alc-sale-lic-type-attr~
,alc-supp-lic-type-attr~
,alc-type-gds-attr~
,archive-history-attr~
,arh-fin-doc-an-attr~
,arh-fin-doc-an-nal-attr~
,arh-fin-doc-an-nal-obj-attr~
,arh-fin-doc-an-obj-attr~
,arh-fin-doc-contr-schet-attr~
,arh-fin-doc-schet-attr~
,arh-fin-doc-schet-nal-attr~
,arh-fin-doc-schet-obj-attr~
,arh-fin-doc-schet-tax-attr~
,arh-fin-ob-contr-attr~
,arh-fin-ob-contr-obj-attr~
,arh-trn-doc-contract-attr~
,arh-wth-cli-attr~
,arh-wth-cli-doc-attr~
,arh-wth-cli-tot-attr~
,arh-wth-tot-attr~
,arh-wth-w-p-attr~
,assortment-matrix-goods-attr~
,auto-tank-meas-attr~
,blob-data~
,buyer-group-attr~
,buyer-in-buyer-group-attr~
,c-auto-tank-attr~
,c-auto-tank-meas-attr~
,c-cbr-bank-attr~
,c-cli-grp-attr~
,c-condition-keeping-attr~
,c-country-attr~
,c-currency-attr~
,c-deliv-type-cond-keep-attr~
,c-delivery-subject-attr~
,c-delivery-type-attr~
,c-delivery-type-subject-attr~
,c-dis-card-long-attr~
,c-dis-rule-attr~
,c-fbr-gds-obj-attr~
,c-fin-bank-attr~
,c-fin-schet-attr~
,c-gds-dtl-attr~
,c-gds-prt-attr~
,c-group-period-validity-attr~
,c-hist-nws-option-attr~
,c-layout-attr~
,c-wi-mode-attr~
,c-layout-elem-attr~
,c-parts-obj-attr~
,c-pay-type-attr~
,c-payment-attr~
,c-pl-gds-pump-attr~
,c-pl-level-attr~
,c-pl-pump-attr~
,c-pl-pump-nozzle-attr~
,c-prod-bc-db-attr~
,c-prop-ruleset~
,c-prop-script~
,c-pscript-ruleset~
,c-pump-nozzle-attr~
,c-rp-rule-param~
,c-rule~
,c-ruledict-param~
,c-rule-by-profile~
,c-rule-by-set~
,c-rule-profile~
,c-rule-process~
,c-ruleset~
,cbr-bank-attr~
,cd-clu-attr~
,cd-dlu-attr~
,cd-doc-attr~
,cd-doc-line-attr~
,cd-grp-attr~
,cd-plu-attr~
,cd-trans-attr~

,cli-art-attr~
,cli-gds-attr~
,cli-grp-attr~
,clob-data~
,condition-keeping-attr~
,contract-line-attr~
,country-attr~
,criterion-analysis-attr~
,cshr-month-attr~
,curr-accnt-attr~
,curr-bank-attr~
,curr-shop-attr~
,currency-attr~
,db-filter-attr~
,db-grp-obj-price-attr~
,db-status-attr~
,db-usr-flt-attr~
,deliv-type-cond-keep-attr~
,delivery-subject-attr~
,delivery-type-attr~
,delivery-type-subject-attr~
,dis-card-long-attr~
,dis-cfg-rule-attr~
,dis-cp-rule-attr~
,dis-dc-rule-attr~
,dis-dct-rule-attr~
,dis-grp-rule-attr~
,dis-rule-attr~
,dis-some-rule-attr~
,dis-thbj-rule-attr~
,dis-time-rule-attr~
,dish-grp-attr~
,doc-abc-def-attr~
,doc-abc-def-doc-attr~
,doc-abc-def-obj-attr~
,doc-fact-num-attr~
,doc-fbr-gds-attr~
,doc-filter-attr~
,doc-filter-head-attr~
,doc-pl-attr~
,doc-pl-pump-attr~
,doc-prts-attr~
,doc-xyz-def-attr~
,doc-xyz-def-doc-attr~
,doc-xyz-def-obj-attr~
,ex-mark-attr~
,ext-artic-db-attr~
,ext-artic-host-attr~
,ext-artic-obj-attr~
,ext-classif-attr~
,ext-file-attr~
,ext-file-line-attr~
,ext-file-par-attr~
,factur-connect-attr~
,factur-connect-line-attr~
,fbr-gds-obj-attr~
,fbr-prn-attr~
,fbr-prn-gds-attr~
,fbr-prn-grp-attr~
,feature-attr~
,feature-scale-attr~
,Filter-attr~
,fin-bank-attr~
,fin-code-an-uchet-attr~
,fin-code-cel-nazn-attr~
,fin-code-cor-acc-attr~
,fin-connect-attr~
,fin-doc-cor-acc-lk-attr~
,fin-doc-obj-attr~
,fin-doc-schet-lk-attr~
,fin-doc-tax-attr~
,fin-gds-part-attr~
,fin-ob-cor-acc-lk-attr~
,fin-ob-schet-lk-attr~
,fin-ob-tax-attr~
,fin-ob-trn-attr~
,fin-schet-attr~
,fin-statement-line-attr~
,gds-dtl-attr~
,gds-obj-flag-attr~
,gds-prt-attr~
,gds-season-attr~
,group-period-validity-attr~
,grp-obj-price-attr~
,hist-nws-option-attr~
,hold-gds-grp-attr~
,hold-goods-attr~
,hold-purch-attr~
,hold-purch-grp-attr~
,hold-purch-supp-attr~
,hold-purch-supp-gds-attr~
,hold-sale-attr~
,hold-sale-grp-attr~
,hold-trn-attr~
,host-grp-obj-price-attr~
,host-lk-attr~
,inkas-pay-attr~
,inkas-pay-desk-attr~
,inv-doc-attr~
,inv-line-attr~
,lang-attr~
,layout-attr~
,layout-elem-attr~
,lvl-name-attr~
,layout-elem-rule-attr~
,c-layout-elem-rule-attr~
,menu-group-attr~
,menu-head-attr~
,menu-item-attr~
,menu-item-group-attr~
,menu-user-attr~
,menu-user-call-attr~
,nws-doc-hist-attr~
,nws-last-rec-attr~
,obj-grp-obj-price-attr~
,ord-blank-attr~
,ord-chain-attr~
,ord-dtl-attr~
,ot-line-attr~
,ot-supp-line-attr~
,ot-supp-tot-attr~
,ot-tot-attr~
,parts-add-attr~
,parts-obj-attr~
,parts-root-attr~
,parts-supp-attr~
,pay-type-attr~
,payment-attr~
,pck-rcvd-attr~
,pck-sent-attr~
,pl-gds-pump-attr~
,pl-level-attr~
,pl-pump-attr~
,pl-pump-nozzle-attr~
,place-io-attr~
,point-io-attr~
,price-all-attr~
,price-list-type-cassa-attr~
,price-list-type-gds-grp-attr~
,prod-bc-db-attr~
,prog-message-attr~
,prog-message-lang-attr~
,prop-head-attr~
,prop-map-attr~
,prop-ref-attr~
,prop-ref-call-attr~
,prop-ruleset-attr~
,prop-script-attr~
,prt-obj-attr~
,pscript-ruleset-attr~
,pump-nozzle-attr~
,qnty-group-attr~
,qnty-in-qnty-group-attr~
,rang-abc-def-attr~
,rang-abc-def-obj-attr~
,rang-xyz-def-attr~
,rang-xyz-def-obj-attr~
,regions-attr~
,rename-fld-attr~
,res-lang-attr~
,resource-attr~
,route-attr~
,route-dump-attr~
,rp-by-call-attr~
,rp-rule-param-attr~
,rpt-option-attr~
,rule-attr~
,rule-by-call-attr~
,rule-by-profile-attr~
,rule-by-set-attr~
,rule-call-param-attr~
,rule-i-script-attr~
,rule-profile-attr~
,rule-script-attr~
,rule-trans-memo-attr~
,ruledict-attr~
,ruledict-param-attr~
,ruleset-attr~
,rvs-doc-attr~
,rvs-line-pump-attr~
,rvs-pump-attr~
,s-coeff-attr~
,sale-doc-attr~
,scales-gds-attr~
,scales-grp-attr~
,schet-fact-doc-attr~
,schet-fact-line-attr~
,season-attr~
,sert-attr~
,sert-join-attr~
,shift-cash-attr~
,shift-obj-attr~
,shift-staff-attr~
,some-lk-attr~
,staff-attr~
,stk-line-attr~
,stk-supp-line-attr~
,stk-supp-tot-attr~
,stk-tot-attr~
,stop-list-attr~
,stop-list-line-attr~
,sum-group-attr~
,sum-grp-attr~
,sum-grp-obj-attr~
,sum-in-sum-group-attr~
,sys-ctrl-attr~
,sysconf-attr~
,tax-attr~
,tax-rate-attr~
,tax-rate-gds-attr~
,tax-rate-gds-grp-attr~
,tax-rate-value-attr~
,tax-units-attr~
,tmp-sale-attr~
,tmp-sale-dtl-attr~
,tmp-sale-gds-attr~
,tnv-in-turnover-group-attr~
,tnved-head-attr~
,tnved-item-attr~
,turnover-buyer-main-attr~
,turnover-group-attr~
,upgrade-attr~
,user-account-attr~
,user-conn-attr~
,user-context-history-attr~
,user-host-attr~
,user-login-action-item-attr~
,user-login-action-role-attr~
,user-obj-attr~
,user-menu-group-attr~
,usr-flt-attr~
,usr-stko-attr~
,var-deliv-gr-per-val-attr~
,variant-delivery-attr~
,wealth-attr~
,who-lk-attr~
,wi-mode-attr~
,wth-dtl-attr~
,wth-line-attr~
,wth-obj-attr~
,wth-par-attr~
,wth-parts-attr~
,wth-place-attr~
,wth-pobj-attr~
,xyz-analysis-cli~
,xyz-analysis-cli-attr~
,xyz-analysis-grp~
,xyz-analysis-grp-attr~
,xyz-analysis-doc-attr~
,xyz-analysis-obj-attr~
,xyz-analysis-period-attr~
,xyz-analysis-prod~
,xyz-analysis-prod-attr~
,cash-param-hist~
':U .
procedure nws-tabs_get-variable-names :
define output parameter p-variable-names as character no-undo .
  do
  on error undo, return error
  :
   assign
     p-variable-names = '~
attach-list~
,news-list~
,oth-list1~
,oth-list2~
':U
.
  end.
end procedure.
procedure nws-tabs_get-variable-value :
define input parameter p-variable-name as character no-undo .
define output parameter p-variable-value as character no-undo .
  do
  on error undo, return error
  :
    case p-variable-name:
      when 'attach-list':U then do:
        assign
        p-variable-value = attach-list.
      end.
      when 'news-list':U then do:
        assign
        p-variable-value = news-list.
      end.
      when 'oth-list1':U then do:
        assign
        p-variable-value = oth-list1.
      end.
      when 'oth-list2':U then do:
        assign
        p-variable-value = oth-list2.
      end.
    end case.
  end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure valid-ren-art-tbl-list :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-std-list        as character no-undo .
    define variable v-ignore-list     as character no-undo .
    define variable v-special-list    as character no-undo .
    assign
      v-std-list     = "cli-gds,cli-gds-attr,cli-art,cli-art-attr,contract-specif,c-contract-specif,doc-line,c-doc-line,fbr-line,c-fbr-line,fbr-recipe,fbr-recipe-gds,fbr-pln-line,c-fbr-pln-line,gds-dtl,c-gds-dtl,gds-dtl-attr,c-gds-dtl-attr,gds-obj,inv-line,inv-line-attr,c-inv-line,ot-supp-line,ot-supp-line-attr,ot-line-attr,ord-line,c-ord-line,ord-line-rcv,ord-dtl,c-ord-dtl,ord-dtl-attr,ord-dtl-rcv,ord-dtl-cons,ord-gds-cons,prt-obj,prt-obj-attr,parts,c-parts,parts-supp,parts-supp-attr,price-list,c-price-list,price-doc-forming-gds,c-price-doc-forming-gds,price-doc-forming-gds-qnty,c-price-doc-forming-gds-qnty,price-doc-forming-gds-sum,c-price-doc-forming-gds-sum,price-doc-forming-gds-tnv,c-price-doc-forming-gds-tnv,recipe,recipe-gds,c-recipe,c-recipe-gds,c-recipe-hist,stk-supp-line,stk-supp-line-attr,stk-line-attr,tmp-sale-dtl,tmp-sale-dtl-attr,tmp-sale-gds,tmp-sale-gds-attr":U
      v-ignore-list  = "c-goods,c-order-line":U
      v-special-list = "goods,ot-line,stk-line,order-line":U
    .
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-inform      as character no-undo .
    define variable bh_tbl-name   as handle    no-undo .
    define variable v-tbl-not-idx as character no-undo .
    define variable v-idx-avail   as logical   no-undo .
    define variable new-tbl-list  as character no-undo .
    define variable old-tbl-list  as character no-undo .
    define variable old-tbl-avail as logical   no-undo .
    define variable v-double-tbl  as character no-undo .
    define variable v-tbl-name    as character no-undo .
    define variable v-msg         as character no-undo .
    assign
      v-msg         = "":U
      v-tbl-not-idx = "":U
      new-tbl-list  = "":U
    .
    for each ub._Field no-lock
      where ub._Field._Field-Name = 'artic':U
    ,first ub._File of ub._Field
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      if  lookup( ub._File._File-Name, v-std-list     ) = 0
      and lookup( ub._File._File-Name, v-ignore-list  ) = 0
      and lookup( ub._File._File-Name, v-special-list ) = 0
      then do:
        assign
          new-tbl-list = new-tbl-list + chr(10) + ub._File._File-Name
        .
      end.
      if lookup( ub._File._File-Name, v-std-list ) <> 0
        or lookup( ub._File._File-Name, new-tbl-list, chr(10) ) <> 0
      then do:
        create buffer bh_tbl-name for table substitute( "ub.&1":U, ub._File._File-Name ) .
        assign
          v-idx-avail = false
          v-inform    = bh_tbl-name:index-information(1)
          v-ind       = 2
        .
        block_chk-idx:
        do while v-inform <> ?
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          if v-inform <> ?
              and lookup( entry( 5, v-inform, ",":U ), "artic,prod-type,prod-code":U ) > 0
              and lookup( entry( 7, v-inform, ",":U ), "artic,prod-type,prod-code":U ) > 0
              and lookup( entry( 9, v-inform, ",":U ), "artic,prod-type,prod-code":U ) > 0
          then do:
            assign
              v-idx-avail = true
            .
            leave block_chk-idx.
          end.
          assign
            v-inform = bh_tbl-name:index-information( v-ind )
            v-ind    = v-ind + 1
          .
        end.
        if v-idx-avail = false then do:
          if lookup( ub._File._File-Name, new-tbl-list, chr(10) ) <> 0 then do:
            assign
              new-tbl-list = new-tbl-list + " (индекса нет)"
            .
          end.
          else do:
            assign
              v-tbl-not-idx = v-tbl-not-idx + chr(10) + ub._File._File-Name
            .
          end.
        end.
        delete object bh_tbl-name.
      end.
    end.
    assign
      old-tbl-list  = "":U
      v-double-tbl  = "":U
      v-num-entries = num-entries( v-std-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name    = entry( v-ind, v-std-list )
        old-tbl-avail = false
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if not available ub._File then do:
        assign
          old-tbl-avail = true
        .
      end.
      else do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'artic':U
          no-error .
        if not available ub._Field then do:
          assign
            old-tbl-avail = true
          .
        end.
          find first ub._Field no-lock
            where ub._Field._File-recid = recid( ub._File )
              and ub._Field._Field-Name = "prod-type"
            no-error .
          if not available ub._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
          find first ub._Field no-lock
            where ub._Field._File-recid = recid( ub._File )
              and ub._Field._Field-Name = "prod-code"
            no-error .
          if not available ub._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
      end.
      if old-tbl-avail = true then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > v-ind
           or lookup( v-tbl-name, v-ignore-list ) > 0
           or lookup( v-tbl-name, v-special-list ) > 0
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    assign
      v-num-entries = num-entries( v-ignore-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name = entry( v-ind, v-ignore-list )
        old-tbl-avail = false
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if not available ub._File then do:
        assign
          old-tbl-avail = true
        .
      end.
      else do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'artic':U
          no-error .
        if not available ub._Field then do:
          assign
            old-tbl-avail = true
          .
        end.
          find first ub._Field no-lock
            where ub._Field._File-recid = recid( ub._File )
              and ub._Field._Field-Name = "prod-type"
            no-error .
          if not available ub._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
          find first ub._Field no-lock
            where ub._Field._File-recid = recid( ub._File )
              and ub._Field._Field-Name = "prod-code"
            no-error .
          if not available ub._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
      end.
      if old-tbl-avail = true then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > 0
           or lookup( v-tbl-name, v-ignore-list ) > v-ind
           or lookup( v-tbl-name, v-special-list ) > 0
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    assign
      v-num-entries = num-entries( v-special-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name = entry( v-ind, v-special-list )
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if available ub._File then do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'artic':U
          no-error .
      end.
      if not available ub._File
        or ( available ub._File
             and not available ub._Field
           )
      then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > 0
           or lookup( v-tbl-name, v-ignore-list ) > 0
           or lookup( v-tbl-name, v-special-list ) > v-ind
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    if v-tbl-not-idx <> "" then do:
      assign
        v-msg = v-msg + substitute( "Таблицы не имеют индекса с полями &3 на первом месте и нет спецобработки: &2&1&1", chr(10), v-tbl-not-idx, 'artic, prod-type, prod-code':U )
      .
    end.
    if new-tbl-list <> "":U then do:
      assign
        v-msg = v-msg + substitute( "Нет обработки таблиц: &2&1&1", chr(10), new-tbl-list )
      .
    end.
    if v-double-tbl <> "":U then do:
      assign
        v-msg = v-msg + substitute( "В списках есть задублированные таблицы: &2&1&1", chr(10), v-double-tbl )
      .
    end.
    if old-tbl-list <> "":U then do:
      assign
        v-msg = v-msg + substitute( "В списках есть несуществующие таблицы или таблицы в которых отсутствуют переименовываемые поля: &2&1&1", chr(10), old-tbl-list )
      .
    end.
    if v-msg <> "":U then do:
      return error substitute( "Утилита переименования &3 не корректна.&1&1&2", chr(10), v-msg, 'artic, prod-type, prod-code':U ) .
    end.
  end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure valid-ren-bcod-tbl-list :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-std-list        as character no-undo .
    define variable v-ignore-list     as character no-undo .
    define variable v-special-list    as character no-undo .
    assign
      v-std-list     = "bar-code-attr,c-bar-code-attr,bar-code-obj-attr,c-bar-code-obj-attr,chk-gds,c-chk-gds,chk-gds-pay,doc-prts,doc-prts-attr,cd-doc-line,c-cd-doc-line,cd-plu,c-cd-plu,c-doc-prts,c-price-list,prod-bc-attr,c-prod-bc-attr,prod-bc-db,prod-bc-db-attr,c-prod-bc-db-attr,price-all,price-doc-forming-gds,price-doc-forming-gdsattr,price-doc-forming-gds-tnv,price-doc-forming-gds-sum,price-doc-forming-gds-qnty,c-price-doc-forming-gds,c-price-doc-forming-gdsattr,c-price-doc-forming-gds-tnv,c-price-doc-forming-gds-sum,c-price-doc-forming-gds-qnty,scales-gds,c-scales-gds,sert-join,c-sert,sert-join-attr":U
      v-ignore-list  = "c-bar-code,c-prod-bc,c-gds-hist,rcs-retail1barcode":U
      v-special-list = "bar-code,prod-bc,price-list,price-list-attr,c-price-list-attr":U
    .
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-inform      as character no-undo .
    define variable bh_tbl-name   as handle    no-undo .
    define variable v-tbl-not-idx as character no-undo .
    define variable v-idx-avail   as logical   no-undo .
    define variable new-tbl-list  as character no-undo .
    define variable old-tbl-list  as character no-undo .
    define variable old-tbl-avail as logical   no-undo .
    define variable v-double-tbl  as character no-undo .
    define variable v-tbl-name    as character no-undo .
    define variable v-msg         as character no-undo .
    assign
      v-msg         = "":U
      v-tbl-not-idx = "":U
      new-tbl-list  = "":U
    .
    for each ub._Field no-lock
      where ub._Field._Field-Name = 'b-code':U
    ,first ub._File of ub._Field
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      if  lookup( ub._File._File-Name, v-std-list     ) = 0
      and lookup( ub._File._File-Name, v-ignore-list  ) = 0
      and lookup( ub._File._File-Name, v-special-list ) = 0
      then do:
        assign
          new-tbl-list = new-tbl-list + chr(10) + ub._File._File-Name
        .
      end.
      if lookup( ub._File._File-Name, v-std-list ) <> 0
        or lookup( ub._File._File-Name, new-tbl-list, chr(10) ) <> 0
      then do:
        create buffer bh_tbl-name for table substitute( "ub.&1":U, ub._File._File-Name ) .
        assign
          v-idx-avail = false
          v-inform    = bh_tbl-name:index-information(1)
          v-ind       = 2
        .
        block_chk-idx:
        do while v-inform <> ?
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          if v-inform <> ?
              and lookup( entry( 5, v-inform, ",":U ), 'b-code':U ) > 0
          then do:
            assign
              v-idx-avail = true
            .
            leave block_chk-idx.
          end.
          assign
            v-inform = bh_tbl-name:index-information( v-ind )
            v-ind    = v-ind + 1
          .
        end.
        if v-idx-avail = false then do:
          if lookup( ub._File._File-Name, new-tbl-list, chr(10) ) <> 0 then do:
            assign
              new-tbl-list = new-tbl-list + " (индекса нет)"
            .
          end.
          else do:
            assign
              v-tbl-not-idx = v-tbl-not-idx + chr(10) + ub._File._File-Name
            .
          end.
        end.
        delete object bh_tbl-name.
      end.
    end.
    assign
      old-tbl-list  = "":U
      v-double-tbl  = "":U
      v-num-entries = num-entries( v-std-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name    = entry( v-ind, v-std-list )
        old-tbl-avail = false
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if not available ub._File then do:
        assign
          old-tbl-avail = true
        .
      end.
      else do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'b-code':U
          no-error .
        if not available ub._Field then do:
          assign
            old-tbl-avail = true
          .
        end.
      end.
      if old-tbl-avail = true then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > v-ind
           or lookup( v-tbl-name, v-ignore-list ) > 0
           or lookup( v-tbl-name, v-special-list ) > 0
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    assign
      v-num-entries = num-entries( v-ignore-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name = entry( v-ind, v-ignore-list )
        old-tbl-avail = false
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if not available ub._File then do:
        assign
          old-tbl-avail = true
        .
      end.
      else do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'b-code':U
          no-error .
        if not available ub._Field then do:
          assign
            old-tbl-avail = true
          .
        end.
      end.
      if old-tbl-avail = true then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > 0
           or lookup( v-tbl-name, v-ignore-list ) > v-ind
           or lookup( v-tbl-name, v-special-list ) > 0
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    assign
      v-num-entries = num-entries( v-special-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name = entry( v-ind, v-special-list )
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if available ub._File then do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'b-code':U
          no-error .
      end.
      if not available ub._File
        or ( available ub._File
             and not available ub._Field
           )
      then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > 0
           or lookup( v-tbl-name, v-ignore-list ) > 0
           or lookup( v-tbl-name, v-special-list ) > v-ind
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    if v-tbl-not-idx <> "" then do:
      assign
        v-msg = v-msg + substitute( "Таблицы не имеют индекса с полями &3 на первом месте и нет спецобработки: &2&1&1", chr(10), v-tbl-not-idx, 'b-code':U )
      .
    end.
    if new-tbl-list <> "":U then do:
      assign
        v-msg = v-msg + substitute( "Нет обработки таблиц: &2&1&1", chr(10), new-tbl-list )
      .
    end.
    if v-double-tbl <> "":U then do:
      assign
        v-msg = v-msg + substitute( "В списках есть задублированные таблицы: &2&1&1", chr(10), v-double-tbl )
      .
    end.
    if old-tbl-list <> "":U then do:
      assign
        v-msg = v-msg + substitute( "В списках есть несуществующие таблицы или таблицы в которых отсутствуют переименовываемые поля: &2&1&1", chr(10), old-tbl-list )
      .
    end.
    if v-msg <> "":U then do:
      return error substitute( "Утилита переименования &3 не корректна.&1&1&2", chr(10), v-msg, 'b-code':U ) .
    end.
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure valid-ren-gdsc-tbl-list :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-std-list        as character no-undo .
    define variable v-ignore-list     as character no-undo .
    define variable v-special-list    as character no-undo .
    assign
      v-std-list     = "abc-analysis-gds-obj,abc-analysis-gds-obj-attr,abc-analysis-goods,abc-analysis-goods-attr,abcxyz-analysis-goods,abcxyz-analysis-goods-attr,action-post-role,action-role-item-gds,add-line,c-add-line,aht-gds,aht-gds-attr,aht-ot-line,aht-ot-line-attr,aht-stk-line,aht-stk-line-attr,alc-type-gds,c-alc-type-gds,alc-type-gds-attr,arh-wth-cli,arh-wth-cli-attr,arh-wth-cli-doc,arh-wth-cli-doc-attr,arh-wth-tot,arh-wth-w-p,assortment-matrix-goods,assortment-matrix-goods-attr,c-assortment-matrix-goods,bar-code,bar-code-attr,bar-code-obj-attr,c-bar-code,c-bar-code-attr,c-bar-code-obj-attr,cd-doc-line,c-cd-doc-line,cd-event-log,cd-plu,c-cd-plu,chk-gds-pay,contract-specif,c-contract-specif,contract-specif-attr,dis-gds-rule,c-dis-gds-rule,dis-gds-rule-attr,doc-fbr-gds,c-doc-fbr-gds,doc-fbr-gds-attr,doc-line-attr,c-doc-line-attr,doc-line-sum,c-doc-line-sum,doc-pl,doc-pl-attr,c-doc-pl,doc-pl-pump,doc-pl-pump-attr,c-doc-pl-pump,doc-prts,c-doc-prts,ext-artic,c-ext-artic,ext-artic-attr,c-ext-artic-attr,ext-artic-db,ext-artic-db-attr,ext-artic-host,ext-artic-host-attr,ext-artic-obj,ext-artic-obj-attr,factur-connect-line,fbr-history,fbr-gds-obj,c-fbr-gds-obj,fbr-gds-obj-attr,c-fbr-gds-obj-attr,fbr-pln-line,c-fbr-pln-line,c-fbr-prn,fbr-prn-gds,c-fbr-prn-gds,fbr-prn-gds-attr,fbr-recipe,fbr-recipe-gds,fin-gds-part,fin-gds-part-attr,c-fin-gds-part,c-gds-hist,gds-add-charges,gds-add-charges-attr,c-gds-add-charges,c-gds-add-charges-attr,gds-host-attr,c-gds-host-attr,gds-obj,c-gds-obj,c-gds-obj-ref,gds-obj-attr,c-gds-obj-attr,gds-obj-flag,gds-obj-flag-attr,gds-obj-prop,gds-obj-prop-attr,c-gds-obj-prop,gds-season,gds-season-attr,c-gds-season,c-goods,goods-attr,c-goods-attr,hold-sale,hold-goods,hold-purch,hold-purch-supp-gds,hold-sale-attr,hold-goods-attr,hold-purch-attr,hold-purch-supp-gds-attr,icnt-line,ord-cons-line-attr,ord-dtl,c-ord-dtl,ord-line,c-ord-line,c-ord-line-attr,ord-line-attr,ord-line-rcv,ord-rcv-line-attr,parts-attr,parts-add,c-parts-add,parts-add-attr,c-parts-attr,parts-obj-attr,c-parts-obj-attr,parts-root,parts-root-attr,c-parts-root,pl-gds,c-pl-gds,c-pl-gds-obj,pl-gds-attr,c-pl-gds-attr,c-plc-hist,c-pmp-hist,pl-gds-pump,c-pl-gds-pump,pl-gds-pump-attr,c-pl-gds-pump-attr,price-all,rcs-retail1product,recipe,c-recipe,c-recipe-gds,recipe-gds,recipe-develop,c-recipe-develop,c-recipe-hist,rvs-line,rvs-line-attr,c-rvs-line,rvs-pump,rvs-line-pump,rvs-line-pump-attr,c-rvs-line-pump,s-coeff,c-s-coeff,s-coeff-attr,schet-fact-line,c-schet-fact-line,tax-rate-gds,tax-rate-gds-attr,turnover-buyer-gds,turnover-buyer-gds-attr,user-login-action-item,user-login-action-role,varianty-delivery-gds-obj,c-varianty-delivery-gds-obj,wth-dtl,c-wth-dtl,wth-gds,c-wth-gds,wth-gds-attr,c-wth-gds-attr,wth-dtl,c-wth-dtl,wth-parts,c-wth-parts,xyz-analysis-gds-obj,xyz-analysis-gds-obj-attr,xyz-analysis-goods,xyz-analysis-goods-attr,egais-gds,c-egais-gds,vsd,c-vsd,gds-mercury,c-gds-mercury,PromoGift,PromoGoods,c-PromoGift,c-PromoGoods,OperServ,c-OperServ,c-goods-attr-any,utd-lines,c-utd-marking-lines,c-utd-lines,marking-lines,utd-marking-lines,marking,c-contract-specif-attr,c-marking,order-line,c-order-line,shift-param":U
      v-ignore-list  = "shift-period":U
      v-special-list = "goods":U
    .
def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-inform      as character no-undo .
    define variable bh_tbl-name   as handle    no-undo .
    define variable v-tbl-not-idx as character no-undo .
    define variable v-idx-avail   as logical   no-undo .
    define variable new-tbl-list  as character no-undo .
    define variable old-tbl-list  as character no-undo .
    define variable old-tbl-avail as logical   no-undo .
    define variable v-double-tbl  as character no-undo .
    define variable v-tbl-name    as character no-undo .
    define variable v-msg         as character no-undo .
    assign
      v-msg         = "":U
      v-tbl-not-idx = "":U
      new-tbl-list  = "":U
    .
    for each ub._Field no-lock
      where ub._Field._Field-Name = 'gds-code':U
    ,first ub._File of ub._Field
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      if  lookup( ub._File._File-Name, v-std-list     ) = 0
      and lookup( ub._File._File-Name, v-ignore-list  ) = 0
      and lookup( ub._File._File-Name, v-special-list ) = 0
      then do:
        assign
          new-tbl-list = new-tbl-list + chr(10) + ub._File._File-Name
        .
      end.
      if lookup( ub._File._File-Name, v-std-list ) <> 0
        or lookup( ub._File._File-Name, new-tbl-list, chr(10) ) <> 0
      then do:
        create buffer bh_tbl-name for table substitute( "ub.&1":U, ub._File._File-Name ) .
        assign
          v-idx-avail = false
          v-inform    = bh_tbl-name:index-information(1)
          v-ind       = 2
        .
        block_chk-idx:
        do while v-inform <> ?
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          if v-inform <> ?
              and lookup( entry( 5, v-inform, ",":U ), 'gds-code':U ) > 0
          then do:
            assign
              v-idx-avail = true
            .
            leave block_chk-idx.
          end.
          assign
            v-inform = bh_tbl-name:index-information( v-ind )
            v-ind    = v-ind + 1
          .
        end.
        if v-idx-avail = false then do:
          if lookup( ub._File._File-Name, new-tbl-list, chr(10) ) <> 0 then do:
            assign
              new-tbl-list = new-tbl-list + " (индекса нет)"
            .
          end.
          else do:
            assign
              v-tbl-not-idx = v-tbl-not-idx + chr(10) + ub._File._File-Name
            .
          end.
        end.
        delete object bh_tbl-name.
      end.
    end.
    assign
      old-tbl-list  = "":U
      v-double-tbl  = "":U
      v-num-entries = num-entries( v-std-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name    = entry( v-ind, v-std-list )
        old-tbl-avail = false
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if not available ub._File then do:
        assign
          old-tbl-avail = true
        .
      end.
      else do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'gds-code':U
          no-error .
        if not available ub._Field then do:
          assign
            old-tbl-avail = true
          .
        end.
      end.
      if old-tbl-avail = true then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > v-ind
           or lookup( v-tbl-name, v-ignore-list ) > 0
           or lookup( v-tbl-name, v-special-list ) > 0
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    assign
      v-num-entries = num-entries( v-ignore-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name = entry( v-ind, v-ignore-list )
        old-tbl-avail = false
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if not available ub._File then do:
        assign
          old-tbl-avail = true
        .
      end.
      else do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'gds-code':U
          no-error .
        if not available ub._Field then do:
          assign
            old-tbl-avail = true
          .
        end.
      end.
      if old-tbl-avail = true then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > 0
           or lookup( v-tbl-name, v-ignore-list ) > v-ind
           or lookup( v-tbl-name, v-special-list ) > 0
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    assign
      v-num-entries = num-entries( v-special-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name = entry( v-ind, v-special-list )
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if available ub._File then do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'gds-code':U
          no-error .
      end.
      if not available ub._File
        or ( available ub._File
             and not available ub._Field
           )
      then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > 0
           or lookup( v-tbl-name, v-ignore-list ) > 0
           or lookup( v-tbl-name, v-special-list ) > v-ind
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    if v-tbl-not-idx <> "" then do:
      assign
        v-msg = v-msg + substitute( "Таблицы не имеют индекса с полями &3 на первом месте и нет спецобработки: &2&1&1", chr(10), v-tbl-not-idx, 'gds-code':U )
      .
    end.
    if new-tbl-list <> "":U then do:
      assign
        v-msg = v-msg + substitute( "Нет обработки таблиц: &2&1&1", chr(10), new-tbl-list )
      .
    end.
    if v-double-tbl <> "":U then do:
      assign
        v-msg = v-msg + substitute( "В списках есть задублированные таблицы: &2&1&1", chr(10), v-double-tbl )
      .
    end.
    if old-tbl-list <> "":U then do:
      assign
        v-msg = v-msg + substitute( "В списках есть несуществующие таблицы или таблицы в которых отсутствуют переименовываемые поля: &2&1&1", chr(10), old-tbl-list )
      .
    end.
    if v-msg <> "":U then do:
      return error substitute( "Утилита переименования &3 не корректна.&1&1&2", chr(10), v-msg, 'gds-code':U ) .
    end.
  end.
end procedure.
define variable v-db-utl        as character no-undo .
define variable v-error-db      as logical   no-undo .
define variable v-error-utl     as logical   no-undo .
define variable v-log-file-name as character no-undo .
define variable vartable-name   as character no-undo
   initial "abcdefghijklmnopqrstuvwxyz-1"            .
define variable varfield-name   as character no-undo
   initial "abcdefghijklmnopqrstuvwxyz-_#0123456789" .
define variable varindex-name   as character no-undo
   initial "abcdefghijklmnopqrstuvwxyz-_0123456789"  .
define variable vartrigger-name as character no-undo
   initial "abcdefghijklmnopqrstuvwxyz-_0123456789"            .
define stream sout .
assign
  v-log-file-name = 'chkdd.txt':u
.
define variable v-variable-names as character no-undo .
define variable v-variable-value as character no-undo .
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define temp-table temp-description no-undo
  field field-description as character
  field field-name        as character
  index xpk is primary unique field-description .
define temp-table temp-trigger-proc no-undo
field file-name_ as character
field trigger-event_ as character
field trigger-proc_ as character
index pi is unique primary
file-name_
trigger-event_
trigger-proc_
index iproc trigger-proc_
.
define buffer buf_temp-trigger-proc for temp-trigger-proc.
define stream IdxStream .
do
on error undo, return error return-value
:
  define variable v-df-file-name        as character no-undo .
  define variable v-pro-file-name       as character no-undo .
  define variable v-file-length         as integer   no-undo .
  os-delete value(v-log-file-name) .
  assign
    v-df-file-name       = "add-idx.df":U
    v-pro-file-name      = "add-idx.pro":U
    file-info :file-name = ".":U
    v-df-file-name       = file-info :full-pathname + chr(92) + v-df-file-name
    v-pro-file-name      = file-info :full-pathname + chr(92) + v-pro-file-name
  .
  os-delete value( v-df-file-name ) .
  os-delete value( v-pro-file-name ) .
  assign
    v-db-utl = "db":U
  .
  for each buf_temp-trigger-proc:
    delete buf_temp-trigger-proc.
  end.
  define variable mTextHead as character no-undo.
  for each dictdb._file no-lock
    where dictdb._file._hidden = false
  on error undo, return error return-value
  :
    run waitfram-show in this-procedure
      (input substitute("Проверка словаря БД. Таблица &1", dictdb._file._file-name)
      ) .
    mTextHead = substitute ("Таблица &1",dictdb._file._file-name).
    run validate-name in this-procedure
      (input mTextHead
      ,input "таблицы"
      ,input dictdb._file._file-name
      ,input vartable-name
      ) .
    if length(dictdb._file._file-name) > 28
    then do:
      run write-log-item in this-procedure
        (input mTextHead,
         input "Длина имени таблицы превышает 28 символов"
        ) .
    end.
    if dictdb._file._CAN-CREATE ne "!,!odbc,*"
    then do:
      run write-log-item in this-procedure
        (input mTextHead ,
         input 'Права на создание должны быть "!,!odbc,*" сейчас права "' + dictdb._file._CAN-CREATE + '"'
        ) .
    end.
    if dictdb._file._CAN-DELETE ne "!,!odbc,*"
    then do:
      run write-log-item in this-procedure
        (input mTextHead ,
         input 'Права на удаление должны быть "!,!odbc,*" сейчас права "' + dictdb._file._CAN-DELETE + '"'
        ) .
    end.
    if dictdb._file._CAN-READ ne "!,*"
    then do:
      run write-log-item in this-procedure
        (input mTextHead ,
         input 'Права на чтение должны быть "!,*" сейчас права "' + dictdb._file._CAN-READ + '"'
        ) .
    end.
    if dictdb._file._CAN-WRITE ne "!,!odbc,*"
    then do:
      run write-log-item in this-procedure
        (input mTextHead,
         input 'Права на запись должны быть "!,!odbc,*" сейчас права "' + dictdb._file._CAN-WRITE + '"'
        ) .
    end.
    if     dictdb._file._CAN-DUMP ne "!,!odbc,*"
       and dictdb._file._CAN-DUMP ne   "!odbc,*"
    then do:
      run write-log-item in this-procedure
        (input mTextHead ,
         input 'Права на выгрузку должны быть "!,!odbc,*" сейчас права "' + dictdb._file._CAN-DUMP + '"'
        ) .
    end.
    if     dictdb._file._CAN-LOAD ne "!,!odbc,*"
       and dictdb._file._CAN-LOAD ne   "!odbc,*"
    then do:
      run write-log-item in this-procedure
        (input mTextHead ,
         input 'Права на загрузку должны быть "!,!odbc,*" сейчас права "' + dictdb._file._CAN-LOAD + '"'
        ) .
    end.
    run validate-pi-idx in this-procedure
      (  input mTextHead,
         input dictdb._file._file-name
      ).
    run validate-other-idx in this-procedure
      ( input v-df-file-name
      , input v-pro-file-name
      , input dictdb._file._file-name
      ).
    for each temp-description
    on error undo, return error return-value
    :
      delete temp-description .
    end.
    define variable v-description as character no-undo .
    for each dictdb._field of dictdb._file no-lock
    on error undo, return error return-value
    :
      assign
        v-description = substring(dictdb._field._desc, 1, 100)
      .
      define variable v-check-description as logical   no-undo .
      assign
        v-check-description = false
      .
      if v-check-description = true
      then do:
        if v-description = ""
        or v-description = ?
        then do:
          run write-log-item in this-procedure
            (  input mTextHead,
               input "Поле " + dictdb._field._field-name    + "Не задано описание поля"
            ) .
        end.
        else do:
          find first temp-description
            where temp-description.field-description = v-description
            no-error .
          if not available temp-description
          then do:
            create temp-description .
            assign
              temp-description.field-description = v-description
              temp-description.field-name        = _field._field-name
            .
          end.
          else do:
            run write-log-item in this-procedure
              (input mTextHead,
               input "Поле " + dictdb._field._field-name
                             + substitute(" Описание совпадает с описание поля &1", temp-description.field-name)
                             + substitute(' "&1"', v-description)
              ) .
          end.
        end.
      end.
      run validate-name in this-procedure
        (input mTextHead
        ,input "поля"
        ,input dictdb._field._field-name
        ,input varfield-name
        ) .
      if _field._data-type = 'decimal':u
      then do:
        if _field._decimals = ?
        then do:
          run write-log-item in this-procedure
            ( input mTextHead,
             input "Поле " + dictdb._field._field-name
              + substitute("Не задано количество знаков после запятой (decimals = ?)")
            ) .
        end.
      end.
    end.
    for each dictdb._index of dictdb._file no-lock
    on error undo, return error return-value
    :
      run validate-name in this-procedure
        (input mTextHead
        ,input "индекса"
        ,input dictdb._index._index-name
        ,input varindex-name
        ) .
    end.
    define variable v-create-trigger as character no-undo .
    define variable v-write-trigger  as character no-undo .
    define variable v-delete-trigger as character no-undo .
    assign
      v-create-trigger = ''
      v-write-trigger  = ''
      v-delete-trigger = ''
    .
    for each dictdb._file-trig of dictdb._file no-lock
    on error undo, return error
    :
      case dictdb._file-trig._event :
        when 'create':u
        then do:
          assign
            v-create-trigger = dictdb._file-trig._proc-name
          .
        end.
        when 'write':u
        then do:
          assign
            v-write-trigger = dictdb._file-trig._proc-name
          .
        end.
        when 'delete':u
        then do:
          assign
            v-delete-trigger = dictdb._file-trig._proc-name
          .
        end.
        otherwise do:
          run write-log-item in this-procedure
            (input mTextHead,
             input substitute("Триггер &1 ", dictdb._file-trig._proc-name)
                 + substitute("Неизвестный тип триггера &1", dictdb._file-trig._event)
            ) .
        end.
      end.
      find first buf_temp-trigger-proc where
                buf_temp-trigger-proc.trigger-proc_ = dictdb._file-trig._proc-name no-error .
      if available buf_temp-trigger-proc then do:
          run write-log-item in this-procedure
            (input mTextHead,
                  substitute("Триггер &1", dictdb._file-trig._proc-name) + chr(10)
                + substitute("Тип триггера &1", dictdb._file-trig._event) + chr(10)
                + "Уже была определена процедура-триггер с таким же именем файла:" + chr(10)
                + substitute("Таблица &1", buf_temp-trigger-proc.file-name_) + chr(10)
                + substitute("Триггер &1", buf_temp-trigger-proc.trigger-proc_) + chr(10)
                + substitute("Тип триггера &1", buf_temp-trigger-proc.trigger-event_) + chr(10)
            ) .
      end.
      create buf_temp-trigger-proc .
      assign
      buf_temp-trigger-proc.file-name_  = dictdb._file._file-name
      buf_temp-trigger-proc.trigger-event_ = dictdb._file-trig._event
      buf_temp-trigger-proc.trigger-proc_ = dictdb._file-trig._proc-name
      .
      define variable v-override-property as logical   no-undo .
      assign
        v-override-property = true
      .
      if dictdb._file-trig._override <> v-override-property
      then do:
        run write-log-item in this-procedure
          (input mTextHead,
           input substitute("Триггер &1 ", dictdb._file-trig._proc-name)
               + substitute("Имеет неправильное свойство override = &1", dictdb._file-trig._override)
          ) .
      end.
      if dictdb._file-trig._trig-crc <> ?
      then do:
        run write-log-item in this-procedure
          (input mTextHead,
                substitute("Триггер &1 ", dictdb._file-trig._proc-name)
              + substitute("Задана контрольная сумма триггера CRC = &1", dictdb._file-trig._trig-crc)
          ) .
      end.
      run validate-filename in this-procedure
        (input mTextHead,
         input substitute("Триггер &1."
                        ,dictdb._file-trig._event
                        )
        ,input dictdb._file-trig._proc-name
        ) .
    end.
    if  v-write-trigger  <> ''
    and v-delete-trigger <> ''
    and v-write-trigger  = v-delete-trigger
    then do:
      run write-log-item in this-procedure
        (input mTextHead,
               substitute("Триггеры ссылаются на один файл ")
             + substitute("Триггер на запись &1 ", v-write-trigger)
             + substitute("Триггер на удаление &1 ", v-delete-trigger)
        ) .
    end.
    if  v-create-trigger <> ''
    and v-delete-trigger <> ''
    and v-create-trigger = v-delete-trigger
    then do:
      run write-log-item in this-procedure
        (input mTextHead,
         input substitute("Триггеры ссылаются на один файл ")
             + substitute("Триггер на создание &1 ", v-create-trigger)
             + substitute("Триггер на удаление &1", v-delete-trigger)
        ) .
    end.
    if  v-create-trigger <> ''
    and v-write-trigger  <> ''
    and v-create-trigger = v-write-trigger
    then do:
      run write-log-item in this-procedure
        (input mTextHead,
         input substitute("Триггеры ссылаются на один файл ")
             + substitute("Триггер на создание &1 ", v-create-trigger)
             + substitute("Триггер на запись &1", v-write-trigger)
        ) .
    end.
    define buffer buf_file for dictdb._file.
    define buffer buf_ubflt_file for ubflt._file.
    define buffer buf_field for dictdb._field.
    define variable v-no-check-c-table as character no-undo initial "gds-obj,wth-obj":U.
    define variable v-no-attr-primary-table as character no-undo init
    "doc-attr,thbj-attr,shift-attr,gen-attr,db-rec-attr,rcs-attr,gds-host-attr,hold-attr,ord-cons-line-attr,ord-rcv-attr,~
ord-rcv-line-attr,user-window-attr,esys-all-attr,trn-rsn-attr,bar-code-obj-attr,parts-obj-attr".
    define variable v-no-primary-table as character no-undo initial
    "c-order-head,c-utd-head,c-pl-gds-obj,c-gds-hist,c-cli-hist,c-dc-hist,c-tax-hist,c-gds-grp-hist,c-wth-hist,c-fbr-gds-grp-hist,c-plc-hist,~
c-pmp-hist,c-nzl-hist,c-sht-hist,c-table-bind,c-recipe-hist,c-usr-hist,c-user-log,c-gds-obj-ref,c-cashbook-head,c-goods-attr-any,c-promo-head":U.
    define variable v-no-check-corr-user-name as character no-undo .
    define variable v-no-check-corr-user-db-num as character no-undo .
    define variable v-cmp as character no-undo .
    define variable v-found-corr-user-name as logical no-undo .
    define variable v-found-corr-user-db-num as logical no-undo .
    define variable v-found-subject as logical no-undo .
    define variable v-no-check-subject as character no-undo initial "c-pl-gds-obj,c-user-log,c-gds-obj-ref,c-goods-attr-any".
    v-no-check-corr-user-name =
    "c-chk-gds,c-chk-doc-attr,c-chk-pay,c-chk-discnt,c-fin-doc-tax,c-fin-statement-line," +
    "c-inkas-pay,c-inkas-pay-desk,c-inkas-pay-wth,c-wth-dtl,c-wth-line,c-rvs-line,c-rvs-line-pump".
    if  dictdb._file._file-name begins "c-":u then do:
      if lookup(dictdb._file._file-name, v-no-primary-table) = 0
      then do:
        find first buf_file no-lock
          where buf_file._file-name = substr(dictdb._file._file-name, 3 )
          no-error .
        if not available buf_file then do:
          run write-log-item in this-procedure
            (input mTextHead,
             input substitute("Таблица должна быть таблицей истории для &1 Отсутствует основная таблица"
                              ,substr(dictdb._file._file-name, 3)
                            )
            ) .
        end.
        else do:
          if lookup(buf_file._file-name, v-no-check-c-table) = 0
          then do:
            for each buf_field no-lock
              where buf_field._file-recid = recid(buf_file)
            :
              find first dictdb._field no-lock
                where dictdb._field._field-name = buf_field._field-name
                  and dictdb._field._file-recid = recid(_file) no-error.
              if not available dictdb._field
              then do:
                run write-log-item in this-procedure
                  (input mTextHead,
                   input substitute("Таблица истории для &1 Отсутствует поле &2, имеющееся в основной таблице"
                                    ,buf_file._file-name
                                    ,buf_field._field-name
                                  )
                  ) .
              end.
              else do:
                buffer-compare Dictdb._field
                using _data-type _format _decimals
                to buf_field
                save result in v-cmp.
                if v-cmp <> "":U
                then do:
                  run write-log-item in this-procedure
                    (input mTextHead,
                     input substitute( "Таблица истории для &1 Поле &2 отличается от поля в основной таблице: &3"
                                      ,buf_file._file-name
                                      ,buf_field._field-name
                                      ,v-cmp
                                    )
                    ) .
                end.
              end.
            end.
        end.
      end.
      end.
      else do:
        v-found-subject = no.
        for each buf_field no-lock
          where buf_field._file-recid = recid(dictdb._file)
        :
          if buf_field._field-name = "subject" then do:
            assign
            v-found-subject = yes.
            leave.
          end.
        end.
        if v-found-subject = no
         and lookup(dictdb._file._file-name, v-no-check-subject) = 0 then do:
            run write-log-item in this-procedure
              (input mTextHead,
               input substitute("Таблица истории остутствует поле <subject> и таблица не задана в списке исключений для таблиц без &1"
                                , "<subject>"
                              )
              ) .
        end.
      end.
      v-found-corr-user-db-num = no.
      v-found-corr-user-name = no.
      for each buf_field no-lock
        where buf_field._file-recid = recid(dictdb._file)
      :
        if buf_field._field-name = "corr-user-name" then do:
          assign
          v-found-corr-user-name = yes.
        end.
        if buf_field._field-name = "corr-user-db-num" then do:
          assign
          v-found-corr-user-db-num = yes.
        end.
        if v-found-corr-user-name
        and v-found-corr-user-db-num then do:
           leave.
        end.
      end.
      if v-found-corr-user-name = no
      and lookup(dictdb._file._file-name, v-no-check-corr-user-name) = 0 then do:
        run write-log-item in this-procedure
          (input mTextHead,
           input substitute("Таблица истории " +
                            "остутствует поле <corr-user-name> и таблица не задана в списке исключений для таблиц без &1"
                            , "<corr-user-name>"
                          )
          ) .
      end.
      if v-found-corr-user-db-num = no
      and lookup(dictdb._file._file-name, v-no-check-corr-user-db-num) = 0 then do:
        run write-log-item in this-procedure
          (input mTextHead,
           input substitute("Таблица истории " +
                            "остутствует поле <corr-user-db-num> и таблица не задана в списке исключений для таблиц без &1"
                            , "<corr-user-db-num>"
                          )
          ) .
      end.
    end.
    else do:
      if  r-index(dictdb._file._file-name, "-attr") = length(dictdb._file._file-name) - length("-attr") + 1
      then do:
        if lookup(dictdb._file._file-name, v-no-attr-primary-table) = 0
        then do:
          find first buf_file no-lock
            where buf_file._file-name = substring(dictdb._file._file-name, 1, length(dictdb._file._file-name) - length("-attr") )
            no-error .
          if not available buf_file then do:
            run write-log-item in this-procedure
              (input mTextHead,
               input substitute("Должна быть таблицей атрибутов для &1 Отсутствует основная таблица"
                                ,substring(dictdb._file._file-name, 1, length(dictdb._file._file-name) - length("-attr") )
                              )
              ) .
          end.
        end.
      end.
    end.
    run write-log-item in this-procedure
              (input mTextHead,
               input ""
              ) .
  end.
  for each dictdb._file no-lock
    where dictdb._file._hidden = false
  on error undo, return error return-value
  :
    run waitfram-show in this-procedure
      (input substitute("Проверка СПН. Таблица &1", dictdb._file._file-name)
      ) .
    if  dictdb._file._file-name begins "c-":u
    and lookup(dictdb._file._file-name, v-no-primary-table) = 0
    then do:
      find first buf_file no-lock
        where buf_file._file-name = substr(dictdb._file._file-name, 3 )
        no-error .
      if not available buf_file then do:
        run write-log in this-procedure
          (input substitute(("Таблица &1 должна быть таблицей истории для &2" + chr(10) +
                            "Отсутствует основная таблица" + chr(10))
                            ,dictdb._file._file-name
                            ,substring(dictdb._file._file-name, 3)
                           )
          ) .
      end.
      else do:
        if lookup(buf_file._file-name, v-no-check-c-table) = 0
        then do:
          run validate-pi-idx-hist in this-procedure
            ( input dictdb._file._file-name
            ,input buf_file._file-name
            ).
        end.
      end.
    end.
    run nws-tabs_get-variable-names in this-procedure ( output v-variable-names).
    v-jj = 0.
    _nws-tabs:
    do v-ii = 1 to num-entries( v-variable-names):
      v-variable-value = '':U.
      run nws-tabs_get-variable-value in this-procedure ( input entry(v-ii, v-variable-names)
                                                        ,output v-variable-value) no-error .
      if lookup(dictdb._file._file-name, v-variable-value) > 0 then do:
        if entry(v-ii, v-variable-names) <> 'oth-list1':U
          and entry(v-ii, v-variable-names) <> 'oth-list2':U
        then do:
          assign
          v-jj = v-jj + 1.
        end.
        else do:
          if v-jj > 0 then do:
            run write-log in this-procedure
              (input substitute("В инклюде списка маршрутизируемых таблиц nws/nws-tabs.i &1определение таблицы &2 присутствует в списке маршрутизируемых и НЕмаршрутизируемых ОДНОВРЕМЕННО"
                                ,chr(10)
                                ,dictdb._file._file-name
                              )
              ) .
          end.
          v-jj = v-jj + 1.
        end.
      end.
    end.
    if v-jj = 0 then do:
      run write-log in this-procedure
        (input substitute("В инклюде списка маршрутизируемых таблиц nws/nws-tabs.i отсутствует&1определение таблицы &2"
                          ,chr(10)
                          ,dictdb._file._file-name
                        )
        ) .
    end.
  end.
  run call-nws_get-variable-names in this-procedure ( output v-variable-names).
  do v-ii = 1 to num-entries( v-variable-names):
    assign
    v-variable-value = '':U
    .
    run call-nws_get-variable-value in this-procedure ( input entry(v-ii, v-variable-names)
                                                       ,output v-variable-value) no-error .
    do v-jj = 1 to num-entries(v-variable-value):
      find first buf_file no-lock
        where buf_file._file-name = entry(v-jj, v-variable-value)
        no-error .
      if not available buf_file then do:
        find first buf_ubflt_file no-lock
           where buf_ubflt_file._file-name = entry(v-jj, v-variable-value)
           no-error.
        if not available buf_ubflt_file then do:
          run write-log in this-procedure
            (input substitute("В инклюде списка маршрутизируемых таблиц nws/call-nws.i присутствует&1определение неизвестной таблицы &2, переменная &3"
                              ,chr(10)
                              ,entry(v-jj, v-variable-value)
                              ,entry(v-ii, v-variable-names)
                            )
            ) .
        end.
      end.
    end.
  end.
  run nws-tabs_get-variable-names in this-procedure ( output v-variable-names).
  do v-ii = 1 to num-entries( v-variable-names):
    assign
    v-variable-value = '':U
    .
    run nws-tabs_get-variable-value in this-procedure ( input entry(v-ii, v-variable-names)
                                                       ,output v-variable-value) no-error .
    do v-jj = 1 to num-entries(v-variable-value):
      find first buf_file no-lock
        where buf_file._file-name = entry(v-jj, v-variable-value)
        no-error .
      if not available buf_file then do:
        find first buf_ubflt_file no-lock
           where buf_ubflt_file._file-name = entry(v-jj, v-variable-value)
           no-error.
        if not available buf_ubflt_file then do:
          run write-log in this-procedure
            (input substitute("В инклюде списка маршрутизируемых таблиц nws/nws-tabs.i присутствует&1определение неизвестной таблицы &2, переменная &3"
                              ,chr(10)
                              ,entry(v-jj, v-variable-value)
                              ,entry(v-ii, v-variable-names)
                            )
            ) .
        end.
      end.
    end.
  end.
  run waitfram-show in this-procedure
    (input substitute("Проверка утилит переименования.")
    ) .
  assign
    v-db-utl = "utl":U
  .
  run valid-ren-art-tbl-list in this-procedure
    no-error .
  if error-status :error then do:
    run write-log in this-procedure
      (input substitute( "&1&2", chr(10), return-value )
      ) .
  end.
  run valid-ren-bcod-tbl-list in this-procedure
    no-error .
  if error-status :error then do:
    run write-log in this-procedure
      (input substitute( "&1&2", chr(10), return-value )
      ) .
  end.
  run valid-ren-gdsc-tbl-list in this-procedure
    no-error .
  if error-status :error then do:
    run write-log in this-procedure
      (input substitute( "&1&2", chr(10), return-value )
      ) .
  end.
  run waitfram-show in this-procedure
    (input substitute("Проверка на изменение первичного ключа у таблиц с uniq-key-rec и подобными полями.")
    ) .
  run valid-rename-pi-uniq-key-rec in this-procedure
    no-error .
  if error-status :error then do:
    run write-log in this-procedure
      (input substitute( "&1&2", chr(10), return-value )
      ) .
  end.
  output stream IdxStream to value( v-df-file-name ) append.
  assign
    v-file-length = seek( IdxStream )
  .
  put stream IdxStream unformatted
    substitute( '.') skip
    substitute( 'PSC') skip
    substitute( 'cpstream=&1', session :stream ) skip
    substitute( '.') skip
    substitute( '&1', string(v-file-length, "9999999999")) skip
    .
  output stream IdxStream close.
run waitfram-show in this-procedure
    (input substitute("Проверка сохранности динамически используемых полей.")
    ) .
  if v-error-db = true
    or v-error-utl = true
  then do:
    run gbl/open_url.p
      (input search('.':u + '/':u + v-log-file-name)
      ) .
    undo, return error return-value .
  end.
end.
procedure validate-name :
  define input  parameter p-obj-name   as character no-undo .
  define input  parameter p-obj-type   as character no-undo .
  define input  parameter p-check-name as character no-undo .
  define input  parameter p-valid-char as character no-undo .
  define variable v-ind          as integer   no-undo .
  define variable v-check-symbol as character no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-str-length as integer   no-undo .
    assign
      v-str-length = length(p-check-name)
    .
    do v-ind = 1 to v-str-length
    :
      assign
        v-check-symbol = substring (p-check-name, v-ind, 1)
      .
      if index (p-valid-char, v-check-symbol) = 0
      then do:
        run write-log-item in this-procedure
          (input p-obj-name ,
           input substitute("Неверный символ: &1 в имени &2 &3", v-check-symbol,p-obj-type,p-check-name )
          ) .
      end.
    end.
  end.
end procedure.
procedure validate-filename :
  define input  parameter p-object-head as character no-undo .
  define input  parameter p-object-name as character no-undo .
  define input  parameter p-file-name   as character no-undo .
  do
  on error undo, return error return-value
  :
    if p-file-name = ""
    or p-file-name = ?
    then do:
      run write-log-item in this-procedure
        (input p-object-head,
         input p-object-name
             + substitute(" Имя файла &1 ", p-file-name)
             + "Не задано имя файла"
        ) .
      return .
    end.
    if num-entries(dictdb._file-trig._proc-name, '/':u) <> 2
    or entry(1, dictdb._file-trig._proc-name, '/':u) <> 'trg':u
    then do:
      run write-log-item in this-procedure
        (input p-object-head,
         input substitute("Триггер &1 ", dictdb._file-trig._proc-name)
             + substitute("Имя триггера должно быть задано в виде trg/<имя_файла>.p)")
        ) .
      return .
    end.
    define variable v-search-file-name as character no-undo .
    assign
      v-search-file-name = search(p-file-name)
    .
    if v-search-file-name = ""
    or v-search-file-name = ?
    then do:
      run write-log-item in this-procedure
        (input p-object-head,
         input p-object-name
             + substitute(" Не найден файл &1", p-file-name)
        ) .
    end.
    if num-entries(p-file-name, '.':u) <> 2
    then do:
      run write-log-item in this-procedure
        (input p-object-head,
         input p-object-name
             + substitute(" Имя файла &1", p-file-name)
             + " Имя файла должно содержать ровно одну точку"
        ) .
      return .
    end.
    define variable v-file-name-no-ext as character no-undo .
    define variable v-file-name-ext    as character no-undo .
    assign
      v-file-name-no-ext = entry(1, entry(2, p-file-name, '/':u), '.':u)
      v-file-name-ext    = entry(2, entry(2, p-file-name, '/':u), '.':u)
    .
    if v-file-name-ext <> "p"
    then do:
      run write-log-item in this-procedure
        (input p-object-head,
         input p-object-name
             + substitute(" Имя файла &1", p-file-name)
             + substitute(" Расширение файла должно равняться символу &1", "p")
        ) .
    end.
    if length(v-file-name-no-ext) > 8
    then do:
      run write-log-item in this-procedure
        (input p-object-head,
         input p-object-name
             + substitute(" Имя файла &1", p-file-name)
             + substitute(" Количество символов не может быть больше 8")
        ) .
    end.
    run validate-name in this-procedure
      (input p-object-head
      ,input p-object-name
           + substitute(" Имя файла &1", p-file-name) + chr(10)
      ,input v-file-name-no-ext
      ,input vartrigger-name
      ) .
  end.
end procedure.
procedure validate-pi-idx :
  define input parameter i-head     as character no-undo.
  define input parameter p-tbl-name as character no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-inform              as character no-undo .
    define variable v-ind                 as integer   no-undo .
    define variable v-idx-field-qnty      as integer   no-undo .
    define variable v-th                  as handle    no-undo .
    define variable v-fh                  as handle    no-undo .
    create buffer v-th for table p-tbl-name .
    assign
      v-inform = v-th:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ?
      and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = v-th:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      run write-log-item in this-procedure
        (input i-head,
         input substitute("Не имеет первичного ключа в БД"
                          ,v-th:name
                         )
        ) .
      return .
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      run write-log-item in this-procedure
        (input i-head,
         input substitute("Первичный индекс (&1) не содержит списка полей."
                          ,v-inform
                         )
        ) .
      return .
    end.
    if entry( 2, v-inform, ",":U ) <> "1":U
    then do:
      run write-log-item in this-procedure
        (input i-head,
         input substitute("Имеет неуникальный первичный ключ &1 в БД"
                          ,entry( 1, v-inform, ",":U )
                         )
        ) .
    end.
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-fh = v-th:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) )
      .
      if v-fh:mandatory = false then do:
        run write-log-item in this-procedure
          (input i-head,
           input substitute("Поле &1 входящее в состав первичного индекса не mandatory."
                            ,v-fh:name
                          )
          ) .
      end.
    end.
    delete object v-th .
    assign
      v-th = ?
      v-fh = ?
    .
  end.
  return.
end procedure.
define temp-table tt_field-check no-undo
  field field-list as character
  field idx-av     as logical
  field idx-name   as character
  index pi is primary unique field-list idx-name
  index i-av idx-av
  .
procedure validate-other-idx :
  define input parameter p-df-file-name  as character no-undo .
  define input parameter p-pro-file-name as character no-undo .
  define input parameter p-tbl-name      as character no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-th                  as handle    no-undo .
    define variable v-fh                  as handle    no-undo .
    define variable v-ind-fld             as integer   no-undo .
    define variable v-fld-name            as character no-undo .
    define variable v-tmp-name            as character no-undo .
    define variable v-inform              as character no-undo .
    define variable v-ind                 as integer   no-undo .
    define variable v-num-entries         as integer   no-undo .
    define variable v-field-qnty          as integer   no-undo .
    define variable v-idx-name-list       as character no-undo .
    define variable v-first-pro           as logical   no-undo .
    for each tt_field-check
    :
      delete tt_field-check .
    end.
    assign
      v-first-pro = true
    .
    create buffer v-th for table p-tbl-name .
    do v-ind-fld = 1 to v-th:num-fields
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    :
      assign
        v-fh       = v-th :buffer-field( v-ind-fld )
        v-fld-name = v-fh :name
      .
      if v-fld-name matches "*obj-type*":U
        or v-fld-name matches "*obj-code*":U
      then do:
        assign
          v-tmp-name = replace ( v-fld-name, "obj-code":U, "obj-type":U )
        .
        if v-fld-name = v-tmp-name then do:
          assign
            v-tmp-name = replace ( v-fld-name, "obj-type":U, "obj-code":U )
          .
        end.
        find first tt_field-check
          where tt_field-check.field-list = v-tmp-name
          no-error .
        if not available tt_field-check then do:
          create tt_field-check .
          assign
            tt_field-check.field-list = v-fld-name
            tt_field-check.idx-av     = false
            tt_field-check.idx-name   = "auto_":U + replace ( replace ( replace ( v-fld-name, "obj-code":U, "object":U ), "obj-type":U, "object":U ), "object":U, "obj":U )
          .
        end.
        else do:
          assign
            tt_field-check.field-list = tt_field-check.field-list + chr(44) + v-fld-name
          .
          if entry( 1, tt_field-check.field-list, chr(44) ) matches "*obj-code*":U
            and entry( 2, tt_field-check.field-list, chr(44) ) matches "*obj-type*":U
          then do:
            assign
              tt_field-check.field-list = entry( 2, tt_field-check.field-list, chr(44) ) + chr(44) + entry( 1, tt_field-check.field-list, chr(44) )
            .
          end.
        end.
      end.
      if v-fld-name matches "*host-code*":U then do:
        find first tt_field-check
          where tt_field-check.field-list = v-fld-name
          no-error .
        if not available tt_field-check then do:
          create tt_field-check .
          assign
            tt_field-check.field-list = v-fld-name
            tt_field-check.idx-av     = false
            tt_field-check.idx-name   = "auto_":U + replace ( v-fld-name, "host-code":U, "host":U )
          .
        end.
      end.
      if v-fld-name matches "*db-num*":U then do:
        find first tt_field-check
          where tt_field-check.field-list = v-fld-name
          no-error .
        if not available tt_field-check then do:
          create tt_field-check .
          assign
            tt_field-check.field-list = v-fld-name
            tt_field-check.idx-av     = false
            tt_field-check.idx-name   = "auto_":U + replace ( v-fld-name, "db-num":U, "db":U )
          .
        end.
      end.
      if v-th:name begins "c-":U
        and ( v-fld-name = "corr-user-name":U
              or v-fld-name = "corr-user-db-num":U
            )
      then do:
        assign
          v-tmp-name = replace ( v-fld-name, "corr-user-name":U, "corr-user-db-num":U )
        .
        if v-fld-name = v-tmp-name then do:
          assign
            v-tmp-name = replace ( v-fld-name, "corr-user-db-num":U, "corr-user-name":U )
          .
        end.
        find first tt_field-check
          where tt_field-check.field-list = v-tmp-name
          no-error .
        if not available tt_field-check then do:
          create tt_field-check .
          assign
            tt_field-check.field-list = v-fld-name
            tt_field-check.idx-av     = false
            tt_field-check.idx-name   = "auto_corr-user":U
          .
        end.
        else do:
          assign
            tt_field-check.field-list = tt_field-check.field-list + chr(44) + v-fld-name
          .
          if entry( 1, tt_field-check.field-list, chr(44) ) = "corr-user-db-num":U
            and entry( 2, tt_field-check.field-list, chr(44) ) = "corr-user-name":U
          then do:
            assign
              tt_field-check.field-list = "corr-user-name":U + chr(44) + "corr-user-db-num":U
            .
          end.
        end.
      end.
    end.
    for each tt_field-check
      where tt_field-check.idx-name = "auto_corr-user":U
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    :
      if num-entries( tt_field-check.field-list ) = 1
        and tt_field-check.field-list = "corr-user-db-num":U
      then do:
        delete tt_field-check .
      end.
    end.
    for each tt_field-check
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    :
      assign
        v-field-qnty    = num-entries( tt_field-check.field-list )
        v-inform        = v-th:index-information(1)
        v-idx-name-list = entry( 1, v-inform, ",":U )
        v-ind           = 2
      .
      block_chk-idx:
      do while v-inform <> ?
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
      :
        if v-inform <> ?
          and ( ( v-field-qnty = 1
                  and lookup( entry( 5, v-inform, ",":U ), tt_field-check.field-list ) > 0
                )
                or
                ( v-field-qnty = 2
                  and ( ( lookup( "corr-user-name":U, tt_field-check.field-list ) = 0
                          and num-entries( v-inform, ",":U ) >= 7
                          and lookup( entry( 5, v-inform, ",":U ), tt_field-check.field-list ) > 0
                          and lookup( entry( 7, v-inform, ",":U ), tt_field-check.field-list ) > 0
                        )
                        or
                        ( lookup( "corr-user-name":U, tt_field-check.field-list ) > 0
                          and num-entries( v-inform, ",":U ) >= 7
                          and entry( 5, v-inform, ",":U ) = "corr-user-name":U
                          and entry( 7, v-inform, ",":U ) = "corr-user-db-num":U
                        )
                     )
                )
                or
                ( v-field-qnty = 3
                  and num-entries( v-inform, ",":U ) >= 9
                  and lookup( entry( 5, v-inform, ",":U ), tt_field-check.field-list ) > 0
                  and lookup( entry( 7, v-inform, ",":U ), tt_field-check.field-list ) > 0
                  and lookup( entry( 9, v-inform, ",":U ), tt_field-check.field-list ) > 0
                )
              )
        then do:
          assign
            tt_field-check.idx-av   = true
            tt_field-check.idx-name = entry( 1, v-inform, ",":U )
          .
          leave block_chk-idx.
        end.
        assign
          v-inform        = v-th:index-information( v-ind )
          v-idx-name-list = v-idx-name-list + chr(44) + entry( 1, v-inform, ",":U )
          v-ind           = v-ind + 1
        .
      end.
      if tt_field-check.idx-av = true
        or num-entries( tt_field-check.field-list, chr(44) ) <= 0
      then do:
        delete tt_field-check .
      end.
    end.
    find first tt_field-check
      no-error .
    if available tt_field-check then do:
      run write-log in this-procedure
        ( input substitute("Таблица &2 &1", chr(10) , v-th:name )
        ) .
      for each tt_field-check
        where tt_field-check.idx-av <> true
      :
        run write-log in this-procedure
          ( input substitute("--- не имеет ключа по полю(-ям) &2 в БД&1", chr(10) , tt_field-check.field-list )
          ) .
        if lookup( v-idx-name-list , tt_field-check.idx-name, chr(44) ) > 0 then do:
          message
            substitute( "такое имя индекса (&1) уже есть в таблице &2", tt_field-check.idx-name, v-th:name )
            view-as alert-box.
        end.
        assign
          v-num-entries = num-entries( tt_field-check.field-list, chr(44) )
        .
        if v-num-entries > 0 then do:
          output stream IdxStream to value( p-df-file-name ) append.
          put stream IdxStream unformatted
            substitute( 'ADD INDEX "&1" ON "&2"', tt_field-check.idx-name, v-th:name ) skip
            substitute( 'AREA "Schema Area"') skip
            substitute( 'INACTIVE') skip
            .
          do v-ind = 1 to v-num-entries
          on error undo, return error return-value
          :
            put stream IdxStream unformatted
              substitute( 'INDEX-FIELD "&1" ASCENDING', entry( v-ind, tt_field-check.field-list, chr(44) ) ) skip
              .
          end.
          put stream IdxStream unformatted
            skip(1)
            .
          output stream IdxStream close.
          output stream IdxStream to value( p-pro-file-name ) append.
          if v-first-pro = true then do:
            if seek( IdxStream ) > 0 then do:
              put stream IdxStream unformatted
                skip(1)
                .
            end.
            put stream IdxStream unformatted
              substitute( 'idxbuild|&1:&2', v-th:name, tt_field-check.idx-name )
              .
            assign
              v-first-pro = false
            .
          end.
          else do:
            put stream IdxStream unformatted
              substitute( ',&1', tt_field-check.idx-name )
              .
          end.
          output stream IdxStream close.
        end.
        delete tt_field-check .
      end.
    end.
    delete object v-th .
    assign
      v-th = ?
      v-fh = ?
    .
  end.
  return.
end procedure.
procedure validate-pi-idx-hist :
  define input parameter p-tbl-name-hist as character no-undo .
  define input parameter p-tbl-name-main as character no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-inform-hist         as character no-undo .
    define variable v-inform-main         as character no-undo .
    define variable v-ind                 as integer   no-undo .
    define variable v-idx-field-qnty-hist as integer   no-undo .
    define variable v-idx-field-qnty-main as integer   no-undo .
    define variable v-th-hist             as handle    no-undo .
    define variable v-fh-hist             as handle    no-undo .
    define variable v-th-main             as handle    no-undo .
    define variable v-fh-main             as handle    no-undo .
    define variable v-valid               as logical   no-undo .
    define variable v-flst-hist           as character no-undo .
    define variable v-flst-main           as character no-undo .
    create buffer v-th-main for table p-tbl-name-main .
    create buffer v-th-hist for table p-tbl-name-hist .
    assign
      v-flst-hist   = "":U
      v-flst-main   = "":U
      v-inform-main = v-th-main:index-information(1)
      v-inform-hist = v-th-hist:index-information(1)
      v-ind         = 2
    .
    do while v-inform-main <> ?
      and entry( 3, v-inform-main, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform-main = v-th-main:index-information( v-ind )
        v-ind         = v-ind + 1
      .
    end.
    assign
      v-ind = 2
    .
    do while v-inform-hist <> ?
      and entry( 3, v-inform-hist, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform-hist = v-th-hist:index-information( v-ind )
        v-ind         = v-ind + 1
      .
    end.
    if v-inform-main = ?
      or LC( entry( 1, v-inform-main, ",":U ) ) = "default":U
      or entry( 3, v-inform-main, ",":U ) <> "1":U
      or v-inform-hist = ?
      or LC( entry( 1, v-inform-hist, ",":U ) ) = "default":U
      or entry( 3, v-inform-hist, ",":U ) <> "1":U
    then do:
      return .
    end.
    assign
      v-idx-field-qnty-main = num-entries( v-inform-main ) - 4
      v-idx-field-qnty-hist = num-entries( v-inform-hist ) - 4
    .
    if v-idx-field-qnty-main < 2
      or v-idx-field-qnty-hist < 2
    then do:
      return .
    end.
    do v-ind = 1 to v-idx-field-qnty-hist by 2
    on error undo, return error
    :
      assign
        v-flst-hist = v-flst-hist + chr(32) + entry( 4 + v-ind, v-inform-hist, ",":U )
      .
      if entry( 4 + v-ind, v-inform-hist, ",":U ) <> "corr-user-db-num":U
        and entry( 4 + v-ind, v-inform-hist, ",":U ) <> "chip-num":U
      then do:
        assign
          v-flst-hist = v-flst-hist + substitute( "(&1)", (if entry( 4 + v-ind + 1, v-inform-hist, ",":U ) = "0" then "ASC" else "DESC" ) )
        .
      end.
    end.
    do v-ind = 1 to v-idx-field-qnty-main by 2
    on error undo, return error
    :
      assign
        v-flst-main = v-flst-main + chr(32) + substitute( "&1(&2)"
                                                                ,entry( 4 + v-ind, v-inform-main, ",":U )
                                                                ,(if entry( 4 + v-ind + 1, v-inform-main, ",":U ) = "0" then "ASC" else "DESC")
                                                               )
      .
    end.
    assign
      v-flst-main = v-flst-main + chr(32) + "corr-user-db-num":U + chr(32) + "chip-num":U
      v-valid = true
    .
    if v-idx-field-qnty-main > v-idx-field-qnty-hist then do:
      assign
        v-valid = false
      .
    end.
    else do:
      do v-ind = 1 to v-idx-field-qnty-main by 2
      on error undo, return error
      :
        assign
          v-fh-main   = v-th-main:buffer-field( entry( 4 + v-ind, v-inform-main, ",":U ) )
          v-fh-hist   = v-th-hist:buffer-field( entry( 4 + v-ind, v-inform-hist, ",":U ) )
        .
        if v-fh-hist:name <> v-fh-main:name
          or entry( 4 + v-ind + 1, v-inform-main, ",":U ) <> entry( 4 + v-ind + 1, v-inform-hist, ",":U )
        then do:
          assign
            v-valid = false
          .
        end.
      end.
      if v-idx-field-qnty-hist >= v-idx-field-qnty-main + 2 then do:
        if v-th-hist:buffer-field( entry( 4 + v-ind, v-inform-hist, ",":U ) ):name <> "corr-user-db-num":U
        then do:
          assign
            v-valid = false
          .
        end.
        else do:
          if v-idx-field-qnty-hist >= v-idx-field-qnty-main + 4 then do:
            if v-th-hist:buffer-field( entry( 4 + v-ind + 2, v-inform-hist, ",":U ) ):name <> "chip-num":U
            then do:
              assign
                v-valid = false
              .
            end.
          end.
          else do:
            assign
              v-valid = false
            .
          end.
        end.
      end.
      else do:
        assign
          v-valid = false
        .
      end.
      if v-idx-field-qnty-hist > v-idx-field-qnty-main + 4 then do:
        assign
          v-valid = false
        .
      end.
    end.
    if v-valid = false then do:
      run write-log in this-procedure
        (input substitute("Таблица &1, неверный первичный индекс &2.&3Существующий:&4&3Должен быть:&5&3&3"
                          ,v-th-hist:name
                          ,entry( 1, v-inform-hist, ",":U )
                          ,chr(10)
                          ,v-flst-hist
                          ,v-flst-main
                         )
        ) .
    end.
    delete object v-th-hist .
    delete object v-th-main .
    assign
      v-th-main = ?
      v-fh-main = ?
      v-th-hist = ?
      v-fh-hist = ?
    .
  end.
  return.
end procedure.
procedure valid-rename-pi-uniq-key-rec :
define variable v-list as character no-undo .
define variable v-uniq-key-rec-tables as character no-undo .
define variable v-uniq-key-rec-tables-2 as character no-undo .
define variable v-call_id-tables as character no-undo .
define variable v-resource_id-tables as character no-undo .
define variable v-jj as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-tbl-name as character no-undo .
define variable v-holder-tbl-name as character no-undo .
define variable v-dop as character no-undo .
define variable v-dop-2 as character no-undo .
define variable v-field-name as character no-undo .
define variable v-bh as handle no-undo .
define variable v-keys as character no-undo .
assign
v-uniq-key-rec-tables =
'dis-card-type=emitent-host-code,type,host-code,obj-type,obj-code' + ";" +
'ext-classif=classif-subject,classif-name,db-num,Key#_One,Key#_Two,Key#_Three,CharKey_One,CharKey_Two,CharKey_Three,nonunique'  + ';' +
'prop-head=dtm-code' + ';' +
'prop-map=dtm-code,node-code' + ';' +
'prop-ref=dt-code' + ';' +
'prop-script=dtm-code,language,script-name,revis_id' + ';' +
'rule=rule_id' + ';' +
'rule-by-call=call#_id,codex_id,ruleset_id,order_id' + ';' +
'ruledict=entry-id' + ';'+
'layout-elem-rule=layout-id,mode-id,widget-id' + ';'+
'layout-elem-rule-attr=layout-id,mode-id,widget-id,attr-code'
v-uniq-key-rec-tables-2 =
'blob-bind=uniq-key-rec/trn-doc/doc-code' + ";" +
'clob-bind=uniq-key-rec' + ";" +
'c-user-log=uniq-key-rec/c-fbr-doc/doc-code,corr-user-db-num,chip-num' + ";" +
'c-user-log=uniq-key-rec/c-trn-doc/doc-code,corr-user-db-num,chip-num' + ";" +
'ruledict=entry-id/prop-head/dtm-code' + ";" +
'ruledict=entry-id/prop-map/dtm-code,node-code' + ";" +
'ruledict=entry-id/prop-ref/dt-code' + ";" +
'ruledict=entry-id/prop-script/dtm-code,language,script-name,revis_id' + ";" +
'ruledict=entry-id/rule/rule_id' + ";" +
'ruledict=entry-id/rule-profile/profile_id' + ";" +
'ruledict=entry-id/ruledict/entry-id'
v-call_id-tables =
'prop-ref-call=call_id/dis-card-type/emitent-host-code,type,host-code,obj-type,obj-code' + ';' +
'rp-by-call=call_id/dis-card-type/emitent-host-code,type,host-code,obj-type,obj-code' + ';' +
'rp-by-call=call_id/thbj-attr/obj-type,obj-code,upper-prop-code,prop-code' + ';' +
'rp-by-call=call_id/schedule/cre-db-num,task-type,task-num' + ';' +
'rule-by-call=call_id/dis-card-type/emitent-host-code,type,host-code,obj-type,obj-code' + ';' +
'rule-by-call=call_id/thbj-attr/obj-type,obj-code,upper-prop-code,prop-code' + ';' +
'rule-by-call=call_id/schedule/cre-db-num,task-type,task-num' + ';' +
'rule-call-param=call_id/dis-card-type/emitent-host-code,type,host-code,obj-type,obj-code' + ';' +
'rule-call-param=call_id/thbj-attr/obj-type,obj-code,upper-prop-code,prop-code' + ';' +
'rule-call-param=call_id/schedule/cre-db-num,task-type,task-num' + ';' +
'rule-trans-memo=call_id/dis-card-type/emitent-host-code,type,host-code,obj-type,obj-code' + ';' +
'who-lk=call_id/dis-card-type/emitent-host-code,type,host-code,obj-type,obj-code'
v-resource_id-tables =
'dis-some-rule=' + ';' +
'some-lk=resource_id/ext-system/esys-id,db-num' + ';' +
'stop-list-line=resource_id/clients/obj-type,obj-code' +  ';' +
'stop-list-line=resource_id/dis-card/d-card' +  ';' +
'who-lk=resource_id/ext-system/esys-id,db-num'
.
  do
  on error undo, return error
  :
    do v-ii = 1 to num-entries(v-uniq-key-rec-tables, ';'):
       assign
       v-dop = entry(v-ii, v-uniq-key-rec-tables, ';')
       v-tbl-name = entry(1, v-dop, '=')
       v-keys = entry(2, v-dop, '=')
       .
       create buffer v-bh for table v-tbl-name.
       if v-bh:keys <> v-keys then do:
          run write-log in this-procedure
            (input substitute("Таблица &1, изменился первичный ключ:&2раньше был &3&2сейчас &4&2необходимо перезаполнить UNIQ-KEY-REC"
                              ,v-tbl-name
                              ,chr(10)
                              ,v-keys
                              ,v-bh:keys
                            )
            ) .
      end.
      delete object v-bh.
    end.
    do v-jj = 1 to 3:
       if v-jj = 1 then do:
         v-list = v-uniq-key-rec-tables-2.
       end.
       if v-jj = 2 then do:
         v-list = v-call_id-tables.
       end.
       if v-jj = 3 then do:
         v-list = v-resource_id-tables.
       end.
       do v-ii = 1 to num-entries(v-list, ';'):
        assign
        v-tbl-name = ''
        v-keys = ''
        .
        assign
        v-dop = entry(v-ii, v-list, ';')
        v-holder-tbl-name = entry(1, v-dop, '=')
        v-dop-2 = entry(2, v-dop, '=')
        v-field-name = entry(1, v-dop-2, chr(47))
        v-tbl-name = (if num-entries(v-dop-2, chr(47)) > 1
                      then entry(2, v-dop-2, chr(47))
                      else '')
        v-keys = (if num-entries(v-dop-2, chr(47)) > 1
                  then entry(3, v-dop-2, chr(47))
                  else '')
        .
        if v-tbl-name  <> '':U then do:
          create buffer v-bh for table v-tbl-name.
          if v-bh:keys <> v-keys then do:
              run write-log in this-procedure
                (input substitute("Таблица &1, изменился первичный ключ:&2раньше был &3&2сейчас &4&2необходимо перезаполнить &5 в &6"
                                  ,v-tbl-name
                                  ,chr(10)
                                  ,v-keys
                                  ,v-bh:keys
                                  ,v-field-name
                                  ,v-holder-tbl-name
                                )
                ) .
          end.
          delete object v-bh.
        end.
      end.
    end.
  end.
end procedure.
procedure valid-rename-field-dyn-use :
define variable v-field-list as character no-undo .
v-field-list =
"bar-code,b-code,integer;" +
"bar-code,cli-base-rate,decimal;" +
"bar-code,gds-code,integer;" +
"bar-code,in-code,character;" +
"bar-code,unit-cli,character;" +
"blob-bind,resource-type,character;" +
"blob-data,bdata,blob;" +
"blob-data,db-num,integer;" +
"blob-data,int64-id,int64;" +
"chk-doc,discnt,decimal;" +
"chk-doc,netto,decimal;" +
"chk-doc,tot-doc,decimal;" +
"chk-title,discnt,decimal;" +
"clients,obj-code,integer;" +
"clients,obj-name,character;" +
"clients,obj-type,character;" +
"clients,trg-param,character;" +
"clob-bind,resource-type,character;" +
"clob-data,cdata,clob;" +
"clob-data,db-num,integer;" +
"clob-data,int64-id,int64;" +
"country,alpha1,character;" +
"country,short-name,character;" +
"dis-card,trg-param,character;" +
"dis-cfg-rule,discnt-role,character;" +
"dis-cfg-rule,pos-type,character;" +
"dis-cfg-rule,nonunique,character;" +
"dis-cfg-rule,self-nonunique,character;" +
"dis-cp-rule,discnt-role,character;" +
"dis-cp-rule,nonunique,character;" +
"dis-cp-rule,pos-type,character;" +
"dis-dc-rule,discnt-role,character;" +
"dis-dc-rule,nonunique,character;" +
"dis-dc-rule,pos-type,character;" +
"dis-dct-rule,discnt-role,character;" +
"dis-dct-rule,nonunique,character;" +
"dis-dct-rule,pos-type,character;" +
"dis-host,whole-send-news,integer;" +
"dis-gds-rule,discnt-role,character;" +
"dis-gds-rule,nonunique,character;" +
"dis-gds-rule,pos-type,character;" +
"dis-grp-rule,classif-type,character;" +
"dis-grp-rule,discnt-role,character;" +
"dis-grp-rule,nonunique,character;" +
"dis-grp-rule,pos-type,character;"  +
"dis-some-rule,classif-type,character;" +
"dis-some-rule,nonunique,character;" +
"dis-some-rule,pos-type,character;" +
"dis-thbj-rule,discnt-role,character;" +
"dis-thbj-rule,nonunique,character;"  +
"dis-thbj-rule,pos-type,character;"  +
"dis-rule,charkey_one,character;" +
"dis-rule,charkey_two,character;" +
"dis-rule,charkey_three,character;" +
"dis-rule,deckey_one,decimal;" +
"dis-rule,deckey_two,decimal;" +
"dis-rule,deckey_three,decimal;" +
"dis-rule,dis-kat,integer;" +
"dis-rule,discnt-value,decimal;" +
"dis-rule,doc-qnty,decimal;" +
"dis-rule,key#_one,integer;" +
"dis-rule,key#_two,integer;" +
"dis-rule,key#_three,integer;" +
"dis-rule,time-rule-num,integer;" +
"dis-rule,tot-sum,decimal;" +
"dis-time-rule,week-day-0,logical;" +
"dis-time-rule,week-day-1,logical;" +
"dis-time-rule,week-day-2,logical;" +
"dis-time-rule,week-day-3,logical;" +
"dis-time-rule,week-day-4,logical;" +
"dis-time-rule,week-day-5,logical;" +
"dis-time-rule,week-day-6,logical;" +
"dis-time-rule,week-day-7,logical;" +
"esys-route-dump,esrd-cr-db-num,integer;" +
"esys-route-dump,esrd-dump-name,character;" +
"esys-route-dump,esrd-dump-ord,int64;" +
"esys-route-dump,esrd-rec-ord,integer;" +
"esys-route-dump,esrd-uniq-key-rec,character;" +
"esys-route-dump,esrd-value-rec,raw;" +
"fin-doc,curr-code,integer;" +
"fin-doc,fin-ext-doc-type,character;" +
"fin-doc,host-code,integer;" +
"fin-doc,naznach-plat,character;" +
"fin-doc,payer-bik,character;" +
"fin-doc,payer-code,integer;" +
"fin-doc,payer-code-schet,integer;" +
"fin-doc,payer-inn,character;" +
"fin-doc,payer-name,character;" +
"fin-doc,payer-r-schet,character;" +
"fin-doc,payer-type,character;" +
"fin-doc,receiver-bik,character;" +
"fin-doc,receiver-code,integer;" +
"fin-doc,receiver-code-schet,integer;" +
"fin-doc,receiver-inn,character;" +
"fin-doc,receiver-name,character;" +
"fin-doc,receiver-r-schet,character;" +
"fin-doc,receiver-type,character;" +
"fin-doc,sttm-code,integer;" +
"fin-statement,bank-city,character;" +
"fin-statement,bank-name,character;" +
"fin-statement,bik,character;" +
"fin-statement,cl-bank,character;" +
"fin-statement,cli-name,character;" +
"fin-statement,code-bank,integer;" +
"fin-statement,code-schet,integer;" +
"fin-statement,end-date,date;" +
"fin-statement,end-sum-doc,decimal;" +
"fin-statement,in-sum-doc,decimal;" +
"fin-statement,out-sum-doc,decimal;" +
"fin-statement,start-date,date;" +
"fin-statement,start-sum-doc,decimal;" +
"fin-statement,r-schet,character;" +
"firm,firm-code,integer;" +
"hist-nws-option,charkey_one,character;" +
"hist-nws-option,charkey_two,character;" +
"hist-nws-option,charkey_three,character;" +
"hist-nws-option,host-code,integer;" +
"hist-nws-option,key#_one,integer;" +
"hist-nws-option,key#_two,integer;" +
"hist-nws-option,key#_three,integer;" +
"hist-nws-option,obj-code,integer;" +
"hist-nws-option,obj-type,character;" +
"hist-nws-option,smart-nws,integer;" +
"hist-nws-option,table-name,character;" +
"goods,alpha1,character;" +
"goods,gds-code,integer;" +
"goods,gds-name,character;" +
"goods,unit-base,character;" +
"ord-doc,obj-type,character;" +
"ord-doc,obj-code,integer;" +
"ord-doc-rcv,obj-type,character;" +
"ord-doc-rcv,obj-code,integer;" +
"person,psn-code,integer;" +
"price-list,b-code,integer;" +
"price-list,price-sale,decimal;" +
"prod-bc,b-code,integer;" +
"prod-bc,bc-on,logical;" +
"prod-bc,b-str,character;" +
"route-dump,dump-name,character;" +
"route-dump,dump-ord,int64;" +
"route-dump,rec-ord,integer;"  +
"route-dump,uniq-key-rec,character;" +
"route-dump,value-rec,raw;" +
"thbj-attr,property-value-character,character;" +
"thbj-attr,property-value-date,date;" +
"thbj-attr,property-value-decimal,decimal;" +
"thbj-attr,property-value-integer,integer;" +
"thbj-attr,property-value-logical,logical;" +
"trn-doc,cli-type,character;" +
"trn-doc,ext-doc-type,character;" +
"trn-doc,flag_,logical;" +
"trn-doc,obj-type,character;" +
"trn-doc,obj-code,integer;" +
"trn-doc,status_,character;"
.
define variable v-ii as integer no-undo .
define variable v-table as character no-undo .
define variable v-field as character no-undo .
define variable v-dt as character no-undo .
define variable v-entry as character no-undo .
define variable v-ok as logical no-undo .
define buffer buf_field for ub._field.
define buffer buf_file for ub._file.
do v-ii = 1 to num-entries(v-field-list, ";"):
  v-entry = entry(v-ii, v-field-list, ";").
  if v-entry = '' then leave.
  v-table = entrY(1, v-entry).
  v-field = entrY(2, v-entry).
  v-dt = entrY(3, v-entry).
  v-ok = no.
  find first buf_file no-lock where
            buf_file._file-name = v-table no-error.
  if available buf_file then do:
    find first buf_field no-lock where
          buf_field._field-name = v-field
      and buf_field._file-recid = recid(buf_file) no-error.
   if available buf_field then do:
     if buf_field._data-type = v-dt then do:
       v-ok = yes.
     end.
   end.
  end.
  if not v-ok then do:
    run write-log in this-procedure
      (input substitute("Таблица &1, изменилось поле &2 используемое динамически (раньше был тип &3)&4" +
                         "&5 &6 &7"
                        ,v-table
                        ,v-field
                        ,v-dt
                        ,chr(10)
                        ,(if available buf_file then "Таблица есть" else "Таблицы нет")
                        ,(if available buf_field then "Поле есть" else "Поля нет")
                        , (if available buf_field then substitute("Тип поля: &1", buf_field._data-type) else "Тип неизсвестен")
                      )
      ) .
  end.
end.
end procedure.
procedure clear-log :
  do
  on error undo, return error return-value
  :
    output stream sout to value(v-log-file-name) .
    output stream sout close .
  end.
end procedure.
define variable molditem as character no-undo.
define variable mError   as integer no-undo.
procedure write-log-item :
  define input  parameter i-item as character no-undo .
  define input  parameter i-mes  as character no-undo .
  if molditem eq i-item
  then
     if i-mes eq ""
     then
        run write-log in this-procedure (i-mes).
     else do:
        mError = mError + 1.
        run write-log in this-procedure (substitute ("&1) &2",mError, i-mes)).
     end.
  else do:
     if i-mes ne ""
     then do:
        molditem =i-item.
        mError = 1.
        run write-log in this-procedure (substitute ("&1&2&3) &4" ,i-item, chr(10), mError, i-mes)).
     end.
  end.
end.
procedure write-log :
  define input  parameter p-msg as character no-undo .
  do
  on error undo, return error return-value
  :
    output stream sout to value(v-log-file-name) append .
    if v-db-utl = "db":U then do:
      if v-error-db <> true
      then do:
        put stream sout unformatted "Обнаружены ошибки в структуре БД" + chr(10) .
      end.
      assign
        v-error-db  = true
      .
    end.
    else do:
      if v-error-utl <> true
      then do:
        put stream sout unformatted "Обнаружены ошибки в утилитах" + chr(10) .
      end.
      assign
        v-error-utl = true
      .
    end.
    put stream sout unformatted p-msg + chr(10) .
    output stream sout close .
  end.
end procedure.
