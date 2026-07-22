block-level on error undo, throw.
define input parameter p-act-name   as character no-undo .
define input parameter p-tbl-name   as character no-undo .
define input parameter p-tbl-handle as handle    no-undo.
define input parameter p-send-list  as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: f63859adafce, 2420, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:46 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cr-route.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/cr-route.p $":U .
define variable vss-description as character no-undo init "Создание записи маршрутизации (route)".
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
      p-vss-parameters = substitute('&1|&2|&3|&4':u,p-act-name,p-tbl-name,p-tbl-handle,p-send-list)
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
define new global shared variable g#lib-nws as handle no-undo .
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
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info1 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info1, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info1, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info1, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info1, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info1 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info1, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info1 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info1, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info1, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info1, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info1, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info1, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info1, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info1 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info1 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info1, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info1, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info1, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info1 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info1 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info1, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info1, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table t-raw no-undo
  field t-raw-field as raw
.
procedure cre-raw :
  define input  parameter p-tbl-name   as character no-undo.
  define input  parameter p-tbl-handle as handle    no-undo.
  define output parameter p-raw        as raw       no-undo.
  define variable bh_t-raw        as handle    no-undo .
  define variable v-ok            as logical   no-undo .
  define variable v-msg           as character no-undo .
    define variable tth             as handle    no-undo .
    define variable tt-name         as character no-undo .
    define variable bh_tt           as handle    no-undo .
  do
  on error  undo, throw
  :
    create temp-table tth.
    assign
      tth:undo = false
      tt-name  = "tt_" + p-tbl-handle:table
    .
    v-ok = tth:create-like( p-tbl-handle ) .
    v-ok = tth:temp-table-prepare( tt-name ) .
    bh_tt = tth:default-buffer-handle .
    v-ok = bh_tt:buffer-create .
    v-ok = bh_tt:buffer-copy( p-tbl-handle ) .
    empty temp-table t-raw .
    create t-raw.
    bh_t-raw = buffer t-raw:handle .
    v-ok =        bh_tt:raw-transfer ( true, bh_t-raw:buffer-field("t-raw-field":U) ) .
    p-raw = t-raw.t-raw-field .
  catch exAppErrors as class Progress.Lang.AppError :
    v-msg = substitute( "&1 (cre-raw). raw-transfer не прошел для таблицы &2&3&4&3&5",
      vss-include-info2,
      p-tbl-name,
      chr(10),
      error-status:get-message (error-status:num-messages),
      exAppErrors:CallStack
    ) .
    undo, throw new Progress.Lang.AppError(v-msg)  .
  end catch .
  catch exProErrors as class Progress.Lang.ProError :
    undo, throw exProErrors .
  end catch .
  catch exAnyErrors as class Progress.Lang.Error:
    undo, throw exAnyErrors .
  end catch .
  finally :
    empty temp-table t-raw .
    v-ok = tth:clear() no-error .
    delete object tth.
  end finally .
  end.
end procedure.
procedure cre-raw-delta :
  define input  parameter p-tbl-name       as character no-undo.
  define input  parameter p-old-raw        as raw       no-undo.
  define input  parameter p-new-buf-handle as handle    no-undo.
  define output parameter p-raw            as raw       no-undo.
  do
  on error  undo, return error substitute( "&1 (cre-raw-delta). &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-raw-delta). stop", vss-include-info2 )
  on endkey undo, return error substitute( "&1 (cre-raw-delta). endkey", vss-include-info2 )
  :
    define variable tt-name         as character no-undo .
    define variable tth             as handle    no-undo .
    define variable bh-dlt_tt       as handle    no-undo .
    define variable bh-old_tt       as handle    no-undo .
    define variable bh_t-raw        as handle    no-undo .
    define variable v-num-fields    as integer   no-undo .
    define variable v-ind           as integer   no-undo .
    define variable v-name-field    as character no-undo .
    define variable v-fh-tt         as handle    no-undo .
    define variable v-fh-old        as handle    no-undo .
    define variable v-fh-new        as handle    no-undo .
    define variable v-ok            as logical   no-undo .
    if not p-new-buf-handle:available then do:
      return error substitute( "&1 (cre-raw-delta). Переданый буфер с новым значением таблицы &2 не доступен", vss-include-info2, p-tbl-name ).
    end.
    if p-old-raw = ?
    then do:
      return error substitute( "&1 (cre-raw-delta). Переданый буфер со старым значением таблицы &2 не доступен", vss-include-info2, p-tbl-name ).
    end.
    create temp-table tth.
    assign
      tth:undo = false
      tt-name  = "tt_" + p-tbl-name
    .
    assign
      v-ok = tth:create-like( p-new-buf-handle ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (cre-raw-delta). Ошибка при создании временной таблицы &2 (1)", vss-include-info2, tt-name ) .
    end.
    assign
      v-ok = tth:temp-table-prepare( tt-name ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (cre-raw-delta). Ошибка при создании временной таблицы &2 (2)", vss-include-info2, tt-name ) .
    end.
    assign
      bh-dlt_tt = tth:default-buffer-handle
    .
    assign
      v-ok = bh-dlt_tt:buffer-create no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (cre-raw-delta). Ошибка при создании буфера временной таблицы для новых значений.", vss-include-info2, p-tbl-name ).
    end.
    create buffer bh-old_tt for table tth.
    assign
      v-ok = bh-old_tt:buffer-create no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (cre-raw-delta). Ошибка при создании буфера временной таблицы для старых значений.", vss-include-info2, p-tbl-name ).
    end.
    create t-raw.
    assign
      t-raw.t-raw-field = p-old-raw
      bh_t-raw          = buffer t-raw:handle
    .
    assign
      v-ok = bh-old_tt:raw-transfer ( false, bh_t-raw:buffer-field("t-raw-field":U) ) no-error
    .
    delete t-raw.
    if v-ok <> true then do:
      return error substitute( "&1 (cre-raw-delta). raw-transfer не прошел для таблицы &2 со старыми значениями", vss-include-info2, p-tbl-name ).
    end.
    assign
      v-num-fields = p-new-buf-handle:num-fields
    .
    do v-ind = 1 to v-num-fields
    on error undo, return error substitute( "&1 (cre-raw-delta). &2", vss-include-info2, error-status :get-message ( 1 ) )
    :
      assign
        v-fh-new     = p-new-buf-handle:buffer-field( v-ind )
        v-name-field = v-fh-new:name
        v-fh-old     = bh-old_tt:buffer-field( v-name-field )
        v-fh-tt      = bh-dlt_tt:buffer-field( v-name-field )
      .
      if v-fh-new:buffer-value <> v-fh-old:buffer-value then do:
        assign
          bh-dlt_tt:buffer-field( v-name-field ):buffer-value = v-fh-new:buffer-value
        .
      end.
    end.
    create t-raw.
    assign
      bh_t-raw = buffer t-raw:handle
    .
    assign
      v-ok = bh-dlt_tt:raw-transfer ( true, bh_t-raw:buffer-field("t-raw-field":U) ) no-error
    .
    assign
      p-raw = t-raw.t-raw-field
    .
    delete t-raw.
    if v-ok <> true then do:
      return error substitute( "&1. raw-transfer не прошел для таблицы &2", vss-include-info2, p-tbl-name ).
    end.
    assign
      v-ok = tth:clear() no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1. Ошибка при очистке временной таблицы &2", vss-include-info2, tt-name ) .
    end.
    delete object bh-old_tt no-error .
    if error-status:error then do:
      return error substitute( "&1. Ошибка при удалении ссылки на буфер временной таблицы &2", vss-include-info2, tt-name ).
    end.
    delete object tth no-error .
    if error-status:error then do:
      return error substitute( "&1. Ошибка при удалении временной таблицы для &2", vss-include-info2, tt-name ).
    end.
  end.
end procedure.
PROCEDURE cre-route-dump :
  define input        parameter p-act-name   as character           no-undo .
  define input        parameter p-tbl-name   as character           no-undo.
  define input        parameter p-tbl-handle as handle              no-undo.
  define input        parameter p-dmp-ord    like ub.route.dump-ord no-undo.
  define input-output parameter p-rc-ord     as integer             no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-route-dump). &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-route-dump). stop", vss-include-info2 )
  on endkey undo, return error substitute( "&1 (cre-route-dump). endkey", vss-include-info2 )
  :
    define variable loc-key-rec like ub.route.uniq-key-rec   no-undo .
    define variable v-value-rec like ub.route-dump.value-rec no-undo .
    define variable bh_tbl-name  as handle    no-undo .
    define variable fh_tbl-name  as handle    no-undo .
    define variable v-ok         as logical   no-undo .
    define buffer buf_sys-ctrl for ub.sys-ctrl .
    if not p-tbl-handle:available then do:
      return error substitute( "&1. Переданый буфер таблицы &2 не доступен", vss-include-info2, p-tbl-name ).
    end.
    assign
      p-rc-ord = p-rc-ord + 1
    .
    run gen-key-rec in this-procedure
      ( input p-tbl-name
       ,input p-tbl-handle
       ,output loc-key-rec
      ) no-error.
    if error-status :error then do:
      return error substitute( "&1. Ошибка при генерации уникального ключа по таблице &2. &3"
                               ,vss-include-info2
                               ,p-tbl-name
                               ,return-value
                             ).
    end.
    run cre-raw in this-procedure
      ( input p-tbl-name
       ,input p-tbl-handle
       ,output v-value-rec
      ) no-error.
    if error-status :error then do:
      return error substitute( "&1. Ошибка при сжатии записи по таблице &2. &3"
                               ,vss-include-info2
                               ,p-tbl-name
                               ,return-value
                             ).
    end.
    case p-act-name :
      when 'send-tbl':U then do:
        create buffer bh_tbl-name for table "ub.route-dump":U .
      end.
      when 'send-tbl-oxml':U
      then do:
        create buffer bh_tbl-name for table "ub.esys-route-dump":U .
      end.
    end case.
    assign
      v-ok = bh_tbl-name:buffer-create no-error
    .
    if v-ok <> true
      or error-status :error
    then do:
      return error substitute( "&1. Ошибка при создании буфера таблицы маршрутизации &2&3&4.", vss-include-info2, p-tbl-name, chr(10), error-status :get-message(1) ).
    end.
    case p-act-name :
      when 'send-tbl':U then do:
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("dump-name":U)
          fh_tbl-name:buffer-value = p-tbl-name
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("dump-ord":U)
          fh_tbl-name:buffer-value = p-dmp-ord
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("rec-ord":U)
          fh_tbl-name:buffer-value = p-rc-ord
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("uniq-key-rec":U)
          fh_tbl-name:buffer-value = loc-key-rec
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("value-rec":U)
          fh_tbl-name:buffer-value = v-value-rec
        .
define variable vss-include-info3 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_route-dump-write in g#lib-nws
  ( input p-tbl-name
  , input bh_tbl-name
  , input p-tbl-handle
  , input p-dmp-ord
  , input p-rc-ord
  ) no-error .
        if error-status :error then do:
          return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ).
        end.
      end.
      when 'send-tbl-oxml':U
      then do:
        find first buf_sys-ctrl no-lock .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("esrd-cr-db-num":U)
          fh_tbl-name:buffer-value = buf_sys-ctrl.db-num
          .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("esrd-dump-name":U)
          fh_tbl-name:buffer-value = p-tbl-name
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("esrd-dump-ord":U)
          fh_tbl-name:buffer-value = p-dmp-ord
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("esrd-rec-ord":U)
          fh_tbl-name:buffer-value = p-rc-ord
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("esrd-uniq-key-rec":U)
          fh_tbl-name:buffer-value = loc-key-rec
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("esrd-value-rec":U)
          fh_tbl-name:buffer-value = v-value-rec
        .
      end.
    end case.
    delete object bh_tbl-name.
  end.
END PROCEDURE.
define variable vss-include-info4 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
v-custom-except-list = v-custom-except-list-erprn.
PROCEDURE cre-dump-goods:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-goods). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-goods). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-goods). endkey", vss-include-info4 )
  :
    define buffer buf_goods        for ub.goods.
    define buffer buf_tax-rate-gds      for ub.tax-rate-gds.
    define buffer buf_bar-code     for ub.bar-code.
    define buffer buf_prod-bc      for ub.prod-bc.
    define variable prod-bc-gl as logical no-undo .
    find buf_goods where rowid( buf_goods ) = tbl-row.
    if new(buf_goods) then do:
      for each buf_tax-rate-gds where buf_tax-rate-gds.gds-code     = buf_goods.gds-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'tax-rate-gds':U, (buffer buf_tax-rate-gds:handle), dmp-ord, input-output rc-ord ).
      end.
      for each buf_bar-code where buf_bar-code.unit-cli  = buf_goods.unit-base
                            and buf_bar-code.gds-code  = buf_goods.gds-code
                            and buf_bar-code.part-code = ""
                            and buf_bar-code.in-code   = ""
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'bar-code':U, (buffer buf_bar-code:handle), dmp-ord, input-output rc-ord ).
        for each buf_prod-bc where buf_prod-bc.b-code = buf_bar-code.b-code
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer buf_prod-bc
  ,input  'global=request':u
  ,output prod-bc-gl
  ) no-error .
          if error-status :error then do:
            return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) .
          end.
          if prod-bc-gl then
          do on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
            run cre-route-dump( p-act-name, 'prod-bc':U, (buffer buf_prod-bc:handle), dmp-ord, input-output rc-ord ).
          end.
        end.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-price-doc:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-price-doc). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-price-doc). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-price-doc). endkey", vss-include-info4 )
  :
    define buffer buf_price-doc  for ub.price-doc.
    define buffer buf_price-list for ub.price-list.
    define buffer buf_price-list-attr for ub.price-list-attr.
    define buffer buf_doc-attr   for ub.doc-attr.
    find buf_price-doc where rowid(buf_price-doc) = tbl-row.
    for each buf_price-list where buf_price-list.doc-num = buf_price-doc.doc-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, 'price-list':U, (buffer buf_price-list:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_doc-attr where buf_doc-attr.doc-code = buf_price-doc.doc-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'doc-attr':U, (buffer buf_doc-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_price-list-attr where buf_price-list-attr.doc-num = buf_price-doc.doc-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'price-list-attr':U, (buffer buf_price-list-attr:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-c-price-doc:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-price-doc). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-price-doc). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-c-price-doc). endkey", vss-include-info4 )
  :
    define buffer buf_c-price-doc  for ub.c-price-doc.
    define buffer buf_c-price-list for ub.c-price-list.
    define buffer buf_c-price-list-attr for ub.c-price-list-attr.
    define buffer buf_c-doc-attr   for ub.c-doc-attr.
    find buf_c-price-doc where rowid(buf_c-price-doc) = tbl-row.
    for each buf_c-price-list where
             buf_c-price-list.chip-num         = buf_c-price-doc.chip-num and
             buf_c-price-list.corr-user-db-num = buf_c-price-doc.corr-user-db-num and
             buf_c-price-list.doc-num          = buf_c-price-doc.doc-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, 'c-price-list':U, (buffer buf_c-price-list:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-doc-attr where
             buf_c-doc-attr.chip-num         = buf_c-price-doc.chip-num and
             buf_c-doc-attr.corr-user-db-num = buf_c-price-doc.corr-user-db-num and
             buf_c-doc-attr.doc-code         = buf_c-price-doc.doc-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'c-doc-attr':U, (buffer buf_c-doc-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-price-list-attr where
             buf_c-price-list-attr.chip-num         = buf_c-price-doc.chip-num and
             buf_c-price-list-attr.corr-user-db-num = buf_c-price-doc.corr-user-db-num and
             buf_c-price-list-attr.doc-num         = buf_c-price-doc.doc-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'c-price-list-attr':U, (buffer buf_c-price-list-attr:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-fbr-doc:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-fbr-doc). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-fbr-doc). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-fbr-doc). endkey", vss-include-info4 )
  :
    define buffer buf_fbr-doc  for ub.fbr-doc.
    define buffer buf_fbr-line for ub.fbr-line.
    define buffer buf_fbr-recipe for ub.fbr-recipe.
    define buffer buf_fbr-recipe-gds for ub.fbr-recipe-gds.
    find buf_fbr-doc where rowid(buf_fbr-doc) = tbl-row.
    for each buf_fbr-line where buf_fbr-line.doc-code = buf_fbr-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'fbr-line':U, (buffer buf_fbr-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_fbr-recipe where buf_fbr-recipe.doc-code = buf_fbr-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
       run cre-route-dump( p-act-name, 'fbr-recipe':U, (buffer buf_fbr-recipe:handle), dmp-ord, input-output rc-ord ).
       for each  buf_fbr-recipe-gds where buf_fbr-recipe-gds.doc-code = buf_fbr-recipe.doc-code
                                      and buf_fbr-recipe-gds.recipe-code = buf_fbr-recipe.recipe-code
       on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, 'fbr-recipe-gds':U, (buffer buf_fbr-recipe-gds:handle), dmp-ord, input-output rc-ord ).
       end.
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-contract:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-contract). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-contract). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-contract). endkey", vss-include-info4 )
  :
    define buffer buf_contract  for ub.contract.
    define buffer buf_contract-line for ub.contract-line.
    find buf_contract where rowid(buf_contract) = tbl-row.
    for each buf_contract-line where buf_contract-line.contract-num = buf_contract.contract-code  and
                                       buf_contract-line.host-code = buf_contract.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'contract-line':U, (buffer buf_contract-line:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-c-contract:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-contract). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-contract). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-c-contract). endkey", vss-include-info4 )
  :
    define buffer buf_c-contract  for ub.c-contract.
    define buffer buf_c-contract-line for ub.c-contract-line.
    find buf_c-contract where rowid(buf_c-contract) = tbl-row.
    for each buf_c-contract-line where buf_c-contract-line.contract-num = buf_c-contract.contract-code and
                               buf_c-contract-line.host-code = buf_c-contract.host-code  and
                               buf_c-contract-line.corr-user-db-num  = buf_c-contract.corr-user-db-num  and
                               buf_c-contract-line.chip-num = buf_c-contract.chip-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'c-contract-line':U, (buffer buf_c-contract-line:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-contract-specif:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-contract-specif). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-contract-specif). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-contract-specif). endkey", vss-include-info4 )
  :
    define buffer buf_contract-specif      for ub.contract-specif.
    define buffer buf_contract-specif-attr for ub.contract-specif-attr.
    find first buf_contract-specif where rowid(buf_contract-specif) = tbl-row.
    for each buf_contract-specif-attr
      where buf_contract-specif-attr.contract-num = buf_contract-specif.contract-num
        and buf_contract-specif-attr.host-code    = buf_contract-specif.host-code
        and buf_contract-specif-attr.gds-code     = buf_contract-specif.gds-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'contract-specif-attr':U, (buffer buf_contract-specif-attr:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-fbr-pln:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-fbr-pln). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-fbr-pln). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-fbr-pln). endkey", vss-include-info4 )
  :
    define buffer buf_fbr-pln       for ub.fbr-pln.
    define buffer buf_fbr-pln-line  for ub.fbr-pln-line.
    find buf_fbr-pln where rowid(buf_fbr-pln) = tbl-row.
    for each buf_fbr-pln-line where buf_fbr-pln-line.doc-code = buf_fbr-pln.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'fbr-pln-line':U, (buffer buf_fbr-pln-line:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-c-fbr-doc:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-fbr-doc). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-fbr-doc). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-c-fbr-doc). endkey", vss-include-info4 )
  :
    define buffer buf_c-fbr-doc  for ub.c-fbr-doc.
    define buffer buf_c-fbr-line for ub.c-fbr-line.
    find buf_c-fbr-doc where rowid(buf_c-fbr-doc) = tbl-row.
    for each buf_c-fbr-line where buf_c-fbr-line.doc-code = buf_c-fbr-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'c-fbr-line':U, (buffer buf_c-fbr-line:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-c-fbr-pln:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-fbr-pln). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-fbr-pln). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-c-fbr-pln). endkey", vss-include-info4 )
  :
    define buffer buf_c-fbr-pln       for ub.c-fbr-pln.
    define buffer buf_c-fbr-pln-line  for ub.c-fbr-pln-line.
    find buf_c-fbr-pln where rowid(buf_c-fbr-pln) = tbl-row.
    for each buf_c-fbr-pln-line where buf_c-fbr-pln-line.doc-code = buf_c-fbr-pln.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'c-fbr-pln-line':U, (buffer buf_c-fbr-pln-line:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-recipe:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-recipe). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-recipe). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-recipe). endkey", vss-include-info4 )
  :
    define buffer buf_recipe        for ub.recipe.
    define buffer buf_recipe-gds    for ub.recipe-gds.
    find buf_recipe where rowid(buf_recipe) = tbl-row.
    for each buf_recipe-gds where buf_recipe-gds.recipe-code = buf_recipe.recipe-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'recipe-gds':U, (buffer buf_recipe-gds:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-c-recipe:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-recipe). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-recipe). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-c-recipe). endkey", vss-include-info4 )
  :
    define buffer buf_c-recipe        for ub.c-recipe.
    define buffer buf_c-recipe-gds    for ub.c-recipe-gds.
    find buf_c-recipe where rowid(buf_c-recipe) = tbl-row.
    for each buf_c-recipe-gds where buf_c-recipe-gds.recipe-code = buf_c-recipe.recipe-code and
         buf_c-recipe-gds.corr-user-db-num  = buf_c-recipe.corr-user-db-num  and
                               buf_c-recipe-gds.chip-num = buf_c-recipe.chip-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'c-recipe-gds':U, (buffer buf_c-recipe-gds:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-rvs-doc :
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-rvs-doc). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-rvs-doc). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-rvs-doc). endkey", vss-include-info4 )
  :
    define buffer buf_rvs-doc       for ub.rvs-doc.
    define buffer buf_rvs-line      for ub.rvs-line.
    define buffer buf_rvs-line-attr for ub.rvs-line-attr.
    define buffer buf_rvs-line-pump for ub.rvs-line-pump.
    define buffer buf_rvs-pump      for ub.rvs-pump.
    define buffer buf_doc-attr      for ub.doc-attr.
    define buffer buf_doc-line-attr for ub.doc-line-attr.
    find first buf_rvs-doc
      where rowid( buf_rvs-doc ) = tbl-row
    .
    for each buf_rvs-line
      where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
    on error undo, return error return-value
    :
      run cre-route-dump( p-act-name, 'rvs-line':U, (buffer buf_rvs-line:handle), dmp-ord, input-output rc-ord ) .
    end.
    for each buf_rvs-line-pump
      where buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
    on error undo, return error return-value
    :
      run cre-route-dump( p-act-name, 'rvs-line-pump':U, (buffer buf_rvs-line-pump:handle), dmp-ord, input-output rc-ord ) .
    end.
    for each buf_rvs-pump
      where buf_rvs-pump.rvs-code = buf_rvs-doc.rvs-code
    on error undo, return error return-value
    :
      run cre-route-dump( p-act-name, 'rvs-pump':U, (buffer buf_rvs-pump:handle), dmp-ord, input-output rc-ord ) .
    end.
    for each buf_doc-attr
      where buf_doc-attr.doc-code = buf_rvs-doc.rvs-code
    on error undo, return error return-value
    :
      run cre-route-dump( p-act-name, 'doc-attr':U, (buffer buf_doc-attr:handle), dmp-ord, input-output rc-ord ) .
    end.
    for each buf_doc-line-attr
      where buf_doc-line-attr.doc-code = buf_rvs-doc.rvs-code
    on error undo, return error return-value :
      run cre-route-dump( p-act-name, 'doc-line-attr':U, ( buffer buf_doc-line-attr:handle ), dmp-ord, input-output rc-ord ) .
    end.
    for each buf_rvs-line-attr
      where buf_rvs-line-attr.rvs-code = buf_rvs-doc.rvs-code
    on error undo, return error return-value
    :
      run cre-route-dump( p-act-name, 'rvs-line-attr':U, (buffer buf_rvs-line-attr:handle), dmp-ord, input-output rc-ord ) .
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-c-rvs-doc :
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-rvs-doc). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-rvs-doc). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-c-rvs-doc). endkey", vss-include-info4 )
  :
    define buffer buf_c-rvs-doc       for ub.c-rvs-doc.
    define buffer buf_c-rvs-line      for ub.c-rvs-line.
    define buffer buf_c-rvs-line-pump for ub.c-rvs-line-pump.
    define buffer buf_c-doc-attr      for ub.c-doc-attr.
    find buf_c-rvs-doc
      where rowid( buf_c-rvs-doc ) = tbl-row
    .
    for each buf_c-rvs-line
      where buf_c-rvs-line.rvs-code = buf_c-rvs-doc.rvs-code
    on error undo, return error return-value
    :
      run cre-route-dump( p-act-name, 'c-rvs-line':U, (buffer buf_c-rvs-line:handle), dmp-ord, input-output rc-ord ) .
    end.
    for each buf_c-doc-attr
      where buf_c-doc-attr.doc-code = buf_c-rvs-doc.rvs-code
    on error undo, return error return-value
    :
      run cre-route-dump( p-act-name, 'c-doc-attr':U, (buffer buf_c-doc-attr:handle), dmp-ord, input-output rc-ord ) .
    end.
    for each buf_c-rvs-line-pump
      where buf_c-rvs-line-pump.rvs-code = buf_c-rvs-doc.rvs-code
    on error undo, return error return-value
    :
      run cre-route-dump( p-act-name, 'c-rvs-line-pump':U, (buffer buf_c-rvs-line-pump:handle), dmp-ord, input-output rc-ord ) .
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-icnt-doc:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-icnt-doc). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-icnt-doc). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-icnt-doc). endkey", vss-include-info4 )
  :
    define buffer buf_icnt-doc  for ub.icnt-doc.
    define buffer buf_icnt-line for ub.icnt-line.
    define buffer buf_doc-attr  for ub.doc-attr.
    find buf_icnt-doc where rowid(buf_icnt-doc) = tbl-row.
    for each buf_icnt-line where buf_icnt-line.doc-code = buf_icnt-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'icnt-line':U, (buffer buf_icnt-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_doc-attr where buf_doc-attr.doc-code = buf_icnt-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'doc-attr':U, (buffer buf_doc-attr:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-wth-doc:
  define input        parameter p-act-name   as   character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.
  define input        parameter chk-go-news  as   logical                no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-wth-doc). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-wth-doc). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-wth-doc). endkey", vss-include-info4 )
  :
    define buffer buf_wth-doc       for ub.wth-doc.
    define buffer buf_wth-line      for ub.wth-line.
    define buffer buf_wth-dtl       for ub.wth-dtl.
    define buffer buf_wth-parts     for ub.wth-parts.
    define buffer buf_chk-doc     for ub.chk-doc.
    define buffer buf_chk-pay      for ub.chk-pay.
    define buffer buf_c-chk-doc   for ub.c-chk-doc.
    define buffer buf_c-chk-pay    for ub.c-chk-pay.
    define buffer buf_c-wth-doc     for ub.c-wth-doc.
    define buffer buf_c-wth-line    for ub.c-wth-line.
    define buffer buf_c-wth-dtl     for ub.c-wth-dtl.
    define buffer buf_c-wth-parts   for ub.c-wth-parts.
    define buffer buf_wth-doc-attr  for ub.wth-doc-attr.
    define buffer buf_inkas-pay-wth for ub.inkas-pay-wth.
    define buffer buf_c-inkas-pay-wth for ub.c-inkas-pay-wth.
    find buf_wth-doc where rowid(buf_wth-doc) = tbl-row.
    for each buf_wth-doc-attr where buf_wth-doc-attr.doc-code = buf_wth-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'wth-doc-attr':U, (buffer buf_wth-doc-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_wth-line where buf_wth-line.doc-code = buf_wth-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'wth-line':U, (buffer buf_wth-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_wth-dtl where buf_wth-dtl.doc-code = buf_wth-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'wth-dtl':U, (buffer buf_wth-dtl:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_wth-parts where buf_wth-parts.out-code = buf_wth-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'wth-parts':U, (buffer buf_wth-parts:handle), dmp-ord, input-output rc-ord ).
    end.
    if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-wth-doc") then
    do:
      for each buf_c-wth-doc where buf_c-wth-doc.doc-code = buf_wth-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'c-wth-doc':U, (buffer buf_c-wth-doc:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
    if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-wth-line") then
    do:
      for each buf_c-wth-line where buf_c-wth-line.doc-code = buf_wth-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'c-wth-line':U, (buffer buf_c-wth-line:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
    if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-wth-dtl") then
    do:
      for each buf_c-wth-dtl where buf_c-wth-dtl.doc-code = buf_wth-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'c-wth-dtl':U, (buffer buf_c-wth-dtl:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
    if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-wth-parts") then
    do:
      for each buf_c-wth-parts where buf_c-wth-parts.out-code = buf_wth-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'c-wth-parts':U, (buffer buf_c-wth-parts:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
    if chk-go-news then do:
      for each buf_chk-doc where buf_chk-doc.out-code = buf_wth-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        for each buf_chk-pay where buf_chk-pay.doc-code = buf_chk-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, 'chk-pay':U, (buffer buf_chk-pay:handle), dmp-ord, input-output rc-ord ).
        end.
        if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-chk-doc") then
        do:
          for each buf_c-chk-doc where buf_c-chk-doc.doc-code = buf_chk-doc.doc-code
          on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
            run cre-route-dump( p-act-name, 'c-chk-doc':U, (buffer buf_c-chk-doc:handle), dmp-ord, input-output rc-ord ).
          end.
        end.
        if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-chk-pay") then
        do:
          for each buf_c-chk-pay where buf_c-chk-pay.doc-code = buf_chk-doc.doc-code
          on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
            run cre-route-dump( p-act-name, 'c-chk-pay':U, (buffer buf_c-chk-pay:handle), dmp-ord, input-output rc-ord ).
          end.
        end.
        run cre-route-dump( p-act-name, 'chk-doc':U, (buffer buf_chk-doc:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
    for each buf_inkas-pay-wth where buf_inkas-pay-wth.inkas-code = buf_wth-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'inkas-pay-wth':U, (buffer buf_inkas-pay-wth:handle), dmp-ord, input-output rc-ord ).
    end.
    if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-inkas-pay-wth") then
    do:
      for each buf_c-inkas-pay-wth where buf_c-inkas-pay-wth.inkas-code = buf_wth-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'c-inkas-pay-wth':U, (buffer buf_c-inkas-pay-wth:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-c-wth-doc:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  define input        parameter chk-go-news as   logical                no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-wth-doc). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-wth-doc). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-c-wth-doc). endkey", vss-include-info4 )
  :
    define buffer buf_c-wth-doc       for ub.c-wth-doc.
    define buffer buf_c-wth-line      for ub.c-wth-line.
    define buffer buf_c-wth-dtl       for ub.c-wth-dtl.
    define buffer buf_c-wth-parts     for ub.c-wth-parts.
    define buffer buf_c-inkas-pay-wth for ub.c-inkas-pay-wth.
    find buf_c-wth-doc where rowid(buf_c-wth-doc) = tbl-row.
    for each buf_c-wth-line where buf_c-wth-line.doc-code = buf_c-wth-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'c-wth-line':U, (buffer buf_c-wth-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-wth-dtl where buf_c-wth-dtl.doc-code = buf_c-wth-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'c-wth-dtl':U, (buffer buf_c-wth-dtl:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-wth-parts where buf_c-wth-parts.out-code = buf_c-wth-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'c-wth-parts':U, (buffer buf_c-wth-parts:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-inkas-pay-wth where
              buf_c-inkas-pay-wth.inkas-code = buf_c-wth-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'c-inkas-pay-wth':U, (buffer buf_c-inkas-pay-wth:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-trn-doc:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  define input        parameter chk-go-news as   logical                no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-trn-doc). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-trn-doc). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-trn-doc). endkey", vss-include-info4 )
  :
    define buffer buf_trn-doc              for ub.trn-doc.
    define buffer buf_doc-line             for ub.doc-line.
    define buffer buf_doc-line-attr        for ub.doc-line-attr.
    define buffer buf_inv-line             for ub.inv-line.
    define buffer buf_doc-line-sum         for ub.doc-line-sum.
    define buffer buf_inv-doc              for ub.inv-doc.
    define buffer buf_trn-doc-sum          for ub.trn-doc-sum.
    define buffer buf_gds-dtl              for ub.gds-dtl.
    define buffer buf_parts                for ub.parts.
    define buffer buf_parts-root           for ub.parts-root.
    define buffer buf_doc-prts             for ub.doc-prts.
    define buffer buf_doc-pl               for ub.doc-pl.
    define buffer buf_doc-pl-attr          for ub.doc-pl-attr.
    define buffer buf_doc-pl-pump          for ub.doc-pl-pump.
    define buffer buf_parts-attr           for ub.parts-attr.
    define buffer buf_marking-lines        for ub.marking-lines.
    define buffer buf_gen-attr             for ub.gen-attr.
    define buffer buf_doc-attr             for ub.doc-attr.
    define buffer buf_doc-fbr-gds          for ub.doc-fbr-gds.
    define buffer buf_arh-trn-doc-contract for ub.arh-trn-doc-contract.
    define buffer buf-rc_arh-trn-doc-contract  for ub.arh-trn-doc-contract.
    define buffer buf_chk-doc              for ub.chk-doc.
    define buffer buf_chk-gds              for ub.chk-gds.
    define buffer buf_chk-gds-attr         for ub.chk-gds-attr.
    define buffer buf_marking-chk          for ub.marking-chk.
    define buffer buf_chk-doc-attr         for ub.chk-doc-attr.
    define buffer buf_c-chk-doc            for ub.c-chk-doc.
    define buffer buf_c-chk-gds            for ub.c-chk-gds.
    define buffer buf_c-chk-doc-attr       for ub.c-chk-doc-attr.
    define buffer buf_ord-chain            for ub.ord-chain.
    define variable v-parts-uniq-key-rec as character no-undo .
    find buf_trn-doc where rowid(buf_trn-doc) = tbl-row.
    for each  buf_ord-chain where buf_ord-chain.rel-doc-code = buf_trn-doc.doc-code and buf_ord-chain.rel-doc-type = 'trn'
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'ord-chain':U, (buffer buf_ord-chain:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'doc-line':U, (buffer buf_doc-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_doc-line-attr where buf_doc-line-attr.doc-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'doc-line-attr':U, (buffer buf_doc-line-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_inv-doc where buf_inv-doc.doc-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'inv-doc':U, (buffer buf_inv-doc:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_inv-line where buf_inv-line.doc-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'inv-line':U, (buffer buf_inv-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_trn-doc-sum where buf_trn-doc-sum.doc-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'trn-doc-sum':U, (buffer buf_trn-doc-sum:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_doc-line-sum where buf_doc-line-sum.doc-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'doc-line-sum':U, (buffer buf_doc-line-sum:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_gds-dtl where buf_gds-dtl.doc-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'gds-dtl':U, (buffer buf_gds-dtl:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_parts where buf_parts.out-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'parts':U, (buffer buf_parts:handle), dmp-ord, input-output rc-ord ).
      define variable v-gds-code as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pargocod in g#library
  (input  recid(buf_parts)
  ,output v-gds-code
  )  .
      for each buf_parts-attr
        where buf_parts-attr.in-code   = buf_parts.in-code
          and buf_parts-attr.gds-code  = v-gds-code
          and buf_parts-attr.part-code = buf_parts.part-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'parts-attr':U, (buffer buf_parts-attr:handle), dmp-ord, input-output rc-ord ).
      end.
      run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer buf_parts:handle)
                                        ,output v-parts-uniq-key-rec).
      for each buf_gen-attr
         where buf_gen-attr.table-name = 'excise-mark':U
           and buf_gen-attr.p-key = v-parts-uniq-key-rec
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'gen-attr':U, (buffer buf_gen-attr:handle), dmp-ord, input-output rc-ord ).
      end.
      for each buf_marking-lines where
            buf_marking-lines.obj-type = buf_parts.obj-type
        and buf_marking-lines.obj-code = buf_parts.obj-code
        and buf_marking-lines.in-code = buf_parts.in-code
        and buf_marking-lines.out-code = buf_parts.out-code
        and buf_marking-lines.part-code = buf_parts.part-code
        and buf_marking-lines.prt-code = buf_parts.prt-code
        and buf_marking-lines.gds-code = v-gds-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'marking-lines':U, (buffer buf_marking-lines:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
    for each  buf_parts-root where buf_parts-root.doc-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'parts-root':U, (buffer buf_parts-root:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_doc-attr where buf_doc-attr.doc-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'doc-attr':U, (buffer buf_doc-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_doc-prts where buf_doc-prts.out-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'doc-prts':U, (buffer buf_doc-prts:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_doc-pl where buf_doc-pl.out-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'doc-pl':U, (buffer buf_doc-pl:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_doc-pl-attr where buf_doc-pl-attr.out-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'doc-pl-attr':U, (buffer buf_doc-pl-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_doc-pl-pump where buf_doc-pl-pump.out-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'doc-pl-pump':U, (buffer buf_doc-pl-pump:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_doc-fbr-gds where buf_doc-fbr-gds.out-code = buf_trn-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'doc-fbr-gds':U, (buffer buf_doc-fbr-gds:handle), dmp-ord, input-output rc-ord ).
    end.
   for each buf_arh-trn-doc-contract where buf_arh-trn-doc-contract.doc-code  = buf_trn-doc.doc-code
   on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )  :
     for each buf-rc_arh-trn-doc-contract where buf-rc_arh-trn-doc-contract.host-code     = buf_arh-trn-doc-contract.host-code     and
                                                buf-rc_arh-trn-doc-contract.contract-code = buf_arh-trn-doc-contract.contract-code and
                                                buf-rc_arh-trn-doc-contract.cli-type      = buf_arh-trn-doc-contract.cli-type      and
                                                buf-rc_arh-trn-doc-contract.cli-code      = buf_arh-trn-doc-contract.cli-code      and
                                                buf-rc_arh-trn-doc-contract.obj-type      = buf_arh-trn-doc-contract.obj-type      and
                                                buf-rc_arh-trn-doc-contract.obj-code      = buf_arh-trn-doc-contract.obj-code      and
                                                buf-rc_arh-trn-doc-contract.ext-doc-type  = buf_arh-trn-doc-contract.ext-doc-type  and
                                                buf-rc_arh-trn-doc-contract.sum-type      = buf_arh-trn-doc-contract.sum-type      and
                                                buf-rc_arh-trn-doc-contract.fact-order    > buf_arh-trn-doc-contract.fact-order
     on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
       run cre-route-dump( p-act-name, 'arh-trn-doc-contract':U, (buffer buf-rc_arh-trn-doc-contract:handle), dmp-ord, input-output rc-ord ).
     end.
     run cre-route-dump( p-act-name, 'arh-trn-doc-contract':U, (buffer buf_arh-trn-doc-contract:handle), dmp-ord, input-output rc-ord ).
   end.
   if buf_trn-doc.ext-doc-type = 'vt':U
   and buf_trn-doc.status_ = 'факт':U
   and chk-go-news
   then do:
      for each  buf_chk-doc where buf_chk-doc.out-code = buf_trn-doc.doc-code
      on error undo, return error return-value :
        run cre-route-dump( p-act-name, 'chk-doc':U, (buffer buf_chk-doc:handle), dmp-ord, input-output rc-ord ).
        for each  buf_chk-gds where buf_chk-gds.doc-code = buf_chk-doc.doc-code
        on error undo, return error return-value :
          run cre-route-dump( p-act-name, 'chk-gds':U, (buffer buf_chk-gds:handle), dmp-ord, input-output rc-ord ).
        end.
        for each  buf_chk-doc-attr where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
        on error undo, return error return-value :
          run cre-route-dump( p-act-name, 'chk-doc-attr':U, (buffer buf_chk-doc-attr:handle), dmp-ord, input-output rc-ord ).
        end.
        if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-chk-doc-attr") then
        do:
          for each  buf_c-chk-doc-attr where buf_c-chk-doc-attr.doc-code = buf_chk-doc.doc-code
          on error undo, return error return-value :
            run cre-route-dump( p-act-name, 'c-chk-doc-attr':U, (buffer buf_c-chk-doc-attr:handle), dmp-ord, input-output rc-ord ).
          end.
        end.
        if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-chk-doc") then
        do:
          for each  buf_c-chk-doc where buf_c-chk-doc.doc-code = buf_chk-doc.doc-code
          on error undo, return error return-value :
            run cre-route-dump( p-act-name, 'c-chk-doc':U, (buffer buf_c-chk-doc:handle), dmp-ord, input-output rc-ord ).
          end.
        end.
        if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-chk-gds") then
        do:
          for each  buf_c-chk-gds where buf_c-chk-gds.doc-code = buf_chk-doc.doc-code
          on error undo, return error return-value :
            run cre-route-dump( p-act-name, 'c-chk-gds':U, (buffer buf_c-chk-gds:handle), dmp-ord, input-output rc-ord ).
          end.
        end.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-c-trn-doc:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-trn-doc). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-trn-doc). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-c-trn-doc). endkey", vss-include-info4 )
  :
  end.
END PROCEDURE.
PROCEDURE cre-dump-inkas:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  define input        parameter chk-go-news as   logical                no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-inkas). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-inkas). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-inkas). endkey", vss-include-info4 )
  :
    define buffer buf_inkas-pay      for ub.inkas-pay.
    define buffer buf_inkas-pay-desk for ub.inkas-pay-desk.
    define buffer buf_inkas-pay-wth  for ub.inkas-pay-wth.
    define buffer buf_sale-doc       for ub.sale-doc.
    define buffer buf_c-sale-doc     for ub.c-sale-doc.
    define buffer buf_inkas          for ub.inkas.
    define buffer buf_chk-doc        for ub.chk-doc.
    define buffer buf_chk-gds        for ub.chk-gds.
    define buffer buf_chk-gds-attr   for ub.chk-gds-attr.
    define buffer buf_chk-pay        for ub.chk-pay.
    define buffer buf_chk-pay-attr   for ub.chk-pay-attr .
    define buffer buf_chk-discnt     for ub.chk-discnt.
    define buffer buf_chk-discnt-attr     for ub.chk-discnt-attr.
    define buffer buf_chk-doc-attr   for ub.chk-doc-attr.
    define buffer buf_chk-gds-pay      for ub.chk-gds-pay.
    define buffer buf_c-chk-doc        for ub.c-chk-doc.
    define buffer buf_c-chk-gds        for ub.c-chk-gds.
    define buffer buf_c-chk-pay        for ub.c-chk-pay.
    define buffer buf_c-chk-discnt     for ub.c-chk-discnt.
    define buffer buf_c-chk-doc-attr   for ub.c-chk-doc-attr.
    define buffer buf_marking-chk      for ub.marking-chk .
    find buf_inkas where rowid(buf_inkas) = tbl-row.
    for each  buf_inkas-pay where buf_inkas-pay.inkas-code = buf_inkas.inkas-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'inkas-pay':U, (buffer buf_inkas-pay:handle), dmp-ord, input-output rc-ord ).
      for each buf_inkas-pay-desk where
               buf_inkas-pay-desk.inkas-code = buf_inkas-pay.inkas-code AND
               buf_inkas-pay-desk.pay-code   = buf_inkas-pay.pay-code   AND
               buf_inkas-pay-desk.curr-code  = buf_inkas-pay.curr-code
       on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
         run cre-route-dump( p-act-name, 'inkas-pay-desk':U, (buffer buf_inkas-pay-desk:handle), dmp-ord, input-output rc-ord ).
       end.
      for each buf_inkas-pay-wth where
               buf_inkas-pay-wth.inkas-code = buf_inkas-pay.inkas-code AND
               buf_inkas-pay-wth.pay-code   = buf_inkas-pay.pay-code   AND
               buf_inkas-pay-wth.curr-code  = buf_inkas-pay.curr-code
       on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
         run cre-route-dump( p-act-name, 'inkas-pay-wth':U, (buffer buf_inkas-pay-wth:handle), dmp-ord, input-output rc-ord ).
       end.
    end.
    for each  buf_sale-doc where buf_sale-doc.inkas-code = buf_inkas.inkas-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'sale-doc':U, (buffer buf_sale-doc:handle), dmp-ord, input-output rc-ord ).
      if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-sale-doc") then
      do:
        for each buf_c-sale-doc where
                 buf_c-sale-doc.inkas-code = buf_sale-doc.inkas-code
             AND buf_c-sale-doc.doc-code   = buf_sale-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, 'c-sale-doc':U, (buffer buf_c-sale-doc:handle), dmp-ord, input-output rc-ord ).
        end.
      end.
    end.
    for each  buf_chk-doc where buf_chk-doc.out-code = buf_inkas.inkas-code
                          and ( chk-go-news = TRUE
                                or buf_chk-doc.d-card <> ""
                              )
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'chk-doc':U, (buffer buf_chk-doc:handle), dmp-ord, input-output rc-ord ).
      for each  buf_chk-gds where buf_chk-gds.doc-code = buf_chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'chk-gds':U, (buffer buf_chk-gds:handle), dmp-ord, input-output rc-ord ).
      end.
      for each  buf_chk-gds-attr where buf_chk-gds-attr.doc-code = buf_chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'chk-gds-attr':U, (buffer buf_chk-gds-attr:handle), dmp-ord, input-output rc-ord ).
      end.
      for each buf_marking-chk where buf_marking-chk.doc-code = buf_chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'marking-chk':U, (buffer buf_marking-chk:handle), dmp-ord, input-output rc-ord ).
      end.
      for each  buf_chk-pay where buf_chk-pay.doc-code = buf_chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'chk-pay':U, (buffer buf_chk-pay:handle), dmp-ord, input-output rc-ord ).
      end.
      for each  buf_chk-pay-attr where buf_chk-pay-attr.doc-code = buf_chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'chk-pay-attr':U, (buffer buf_chk-pay-attr:handle), dmp-ord, input-output rc-ord ).
      end.
      for each  buf_chk-discnt where buf_chk-discnt.doc-code = buf_chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'chk-discnt':U, (buffer buf_chk-discnt:handle), dmp-ord, input-output rc-ord ).
      end.
      for each  buf_chk-discnt-attr where buf_chk-discnt-attr.doc-code = buf_chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'chk-discnt-attr':U, (buffer buf_chk-discnt-attr:handle), dmp-ord, input-output rc-ord ).
      end.
      for each  buf_chk-doc-attr where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'chk-doc-attr':U, (buffer buf_chk-doc-attr:handle), dmp-ord, input-output rc-ord ).
      end.
      if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-chk-doc") then
      do:
        for each  buf_c-chk-doc where buf_c-chk-doc.doc-code = buf_chk-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, 'c-chk-doc':U, (buffer buf_c-chk-doc:handle), dmp-ord, input-output rc-ord ).
        end.
      end.
      if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-chk-gds") then
      do:
        for each  buf_c-chk-gds where buf_c-chk-gds.doc-code = buf_chk-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, 'c-chk-gds':U, (buffer buf_c-chk-gds:handle), dmp-ord, input-output rc-ord ).
        end.
      end.
      if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-chk-pay") then
      do:
        for each  buf_c-chk-pay where buf_c-chk-pay.doc-code = buf_chk-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, 'c-chk-pay':U, (buffer buf_c-chk-pay:handle), dmp-ord, input-output rc-ord ).
        end.
      end.
      if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-chk-discnt") then
      do:
        for each  buf_c-chk-discnt where buf_c-chk-discnt.doc-code = buf_chk-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, 'c-chk-discnt':U, (buffer buf_c-chk-discnt:handle), dmp-ord, input-output rc-ord ).
        end.
      end.
      if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-chk-doc-attr") then
      do:
        for each  buf_c-chk-doc-attr where buf_c-chk-doc-attr.doc-code = buf_chk-doc.doc-code
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, 'c-chk-doc-attr':U, (buffer buf_c-chk-doc-attr:handle), dmp-ord, input-output rc-ord ).
        end.
      end.
    end.
    if chk-go-news = TRUE then do:
      for each  buf_chk-gds-pay where buf_chk-gds-pay.out-code = buf_inkas.inkas-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'chk-gds-pay':U, (buffer buf_chk-gds-pay:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-c-inkas:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  define input        parameter chk-go-news as   logical                no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-inkas). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-inkas). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-c-inkas). endkey", vss-include-info4 )
  :
    define buffer buf_c-inkas-pay      for ub.c-inkas-pay.
    define buffer buf_c-inkas-pay-desk for ub.c-inkas-pay-desk.
    define buffer buf_c-inkas-pay-wth  for ub.c-inkas-pay-wth.
    define buffer buf_c-inkas          for ub.c-inkas.
    define buffer buf_c-sale-doc       for ub.c-sale-doc.
    find buf_c-inkas where rowid(buf_c-inkas) = tbl-row.
    for each  buf_c-inkas-pay where buf_c-inkas-pay.inkas-code = buf_c-inkas.inkas-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'c-inkas-pay':U, (buffer buf_c-inkas-pay:handle), dmp-ord, input-output rc-ord ).
      for each buf_c-inkas-pay-desk where
               buf_c-inkas-pay-desk.inkas-code = buf_c-inkas-pay.inkas-code AND
               buf_c-inkas-pay-desk.pay-code   = buf_c-inkas-pay.pay-code   AND
               buf_c-inkas-pay-desk.curr-code  = buf_c-inkas-pay.curr-code
       on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
         run cre-route-dump( p-act-name, 'c-inkas-pay-desk':U, (buffer buf_c-inkas-pay-desk:handle), dmp-ord, input-output rc-ord ).
       end.
      for each buf_c-inkas-pay-wth where
               buf_c-inkas-pay-wth.inkas-code = buf_c-inkas-pay.inkas-code AND
               buf_c-inkas-pay-wth.pay-code   = buf_c-inkas-pay.pay-code   AND
               buf_c-inkas-pay-wth.curr-code  = buf_c-inkas-pay.curr-code
       on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
         run cre-route-dump( p-act-name, 'c-inkas-pay-wth':U, (buffer buf_c-inkas-pay-wth:handle), dmp-ord, input-output rc-ord ).
       end.
    end.
    for each  buf_c-sale-doc where buf_c-sale-doc.inkas-code = buf_c-inkas.inkas-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'c-sale-doc':U, (buffer buf_c-sale-doc:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-c-chk-doc:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  define input        parameter chk-go-news as   logical                no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-chk-doc). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-chk-doc). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-c-chk-doc). endkey", vss-include-info4 )
  :
    define buffer buf_c-chk-doc        for ub.c-chk-doc.
    define buffer buf_c-chk-gds        for ub.c-chk-gds.
    define buffer buf_c-chk-pay        for ub.c-chk-pay.
    define buffer buf_c-chk-discnt     for ub.c-chk-discnt.
    define buffer buf_c-chk-doc-attr   for ub.c-chk-doc-attr.
    find buf_c-chk-doc where rowid(buf_c-chk-doc) = tbl-row.
    for each  buf_c-chk-gds where buf_c-chk-gds.doc-code = buf_c-chk-doc.doc-code
                             AND  buf_c-chk-gds.chip-num = buf_c-chk-doc.chip-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'c-chk-gds':U, (buffer buf_c-chk-gds:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_c-chk-pay where buf_c-chk-pay.doc-code = buf_c-chk-doc.doc-code
                             AND  buf_c-chk-pay.chip-num = buf_c-chk-doc.chip-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'c-chk-pay':U, (buffer buf_c-chk-pay:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_c-chk-discnt where buf_c-chk-discnt.doc-code = buf_c-chk-doc.doc-code
                                AND  buf_c-chk-discnt.chip-num = buf_c-chk-doc.chip-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'c-chk-discnt':U, (buffer buf_c-chk-discnt:handle), dmp-ord, input-output rc-ord ).
    end.
    for each  buf_c-chk-doc-attr where buf_c-chk-doc-attr.doc-code = buf_c-chk-doc.doc-code
                                  AND  buf_c-chk-doc-attr.chip-num = buf_c-chk-doc.chip-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'c-chk-doc-attr':U, (buffer buf_c-chk-doc-attr:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-shift-obj:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-shift-obj). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-shift-obj). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-shift-obj). endkey", vss-include-info4 )
  :
    define buffer buf_shift-obj   for ub.shift-obj.
    define buffer buf_shift-staff for ub.shift-staff.
    define buffer buf_shift-cash  for ub.shift-cash.
    define buffer buf_c-shift-staff for ub.c-shift-staff.
    define buffer buf_c-sht-hist for ub.c-sht-hist.
    define buffer buf_c-shift-obj   for ub.c-shift-obj.
    find buf_shift-obj where rowid(buf_shift-obj) = tbl-row.
    for each buf_shift-staff where buf_shift-staff.obj-type   = buf_shift-obj.obj-type
                             and buf_shift-staff.obj-code   = buf_shift-obj.obj-code
                             and buf_shift-staff.shift-date = buf_shift-obj.shift-date
                             and buf_shift-staff.shift-num  = buf_shift-obj.shift-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'shift-staff':U, (buffer buf_shift-staff:handle), dmp-ord, input-output rc-ord ).
    end.
    if buf_shift-obj.status_ = 'зкр':U then do:
      for each buf_shift-cash where buf_shift-cash.obj-type   = buf_shift-obj.obj-type
                              and buf_shift-cash.obj-code   = buf_shift-obj.obj-code
                              and buf_shift-cash.shift-date = buf_shift-obj.shift-date
                              and buf_shift-cash.shift-num  = buf_shift-obj.shift-num
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'shift-cash':U, (buffer buf_shift-cash:handle), dmp-ord, input-output rc-ord ).
      end.
      if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-shift-staff") then
      do:
        for each buf_c-shift-staff where buf_c-shift-staff.obj-type   = buf_shift-obj.obj-type
                                and buf_c-shift-staff.obj-code   = buf_shift-obj.obj-code
                                and buf_c-shift-staff.shift-date = buf_shift-obj.shift-date
                                and buf_c-shift-staff.shift-num  = buf_shift-obj.shift-num
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, 'c-shift-staff':U, (buffer buf_c-shift-staff:handle), dmp-ord, input-output rc-ord ).
        end.
      end.
      if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-sht-hist") then
      do:
        for each buf_c-sht-hist where buf_c-sht-hist.obj-type   = buf_shift-obj.obj-type
                                and buf_c-sht-hist.obj-code   = buf_shift-obj.obj-code
                                and buf_c-sht-hist.shift-date = buf_shift-obj.shift-date
                                and buf_c-sht-hist.shift-num  = buf_shift-obj.shift-num
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, 'c-sht-hist':U, (buffer buf_c-sht-hist:handle), dmp-ord, input-output rc-ord ).
        end.
      end.
      if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-shift-obj") then
      do:
        for each buf_c-shift-obj where buf_c-shift-obj.obj-type   = buf_shift-obj.obj-type
                                and buf_c-shift-obj.obj-code   = buf_shift-obj.obj-code
                                and buf_c-shift-obj.shift-date = buf_shift-obj.shift-date
                                and buf_c-shift-obj.shift-num  = buf_shift-obj.shift-num
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, 'c-shift-obj':U, (buffer buf_c-shift-obj:handle), dmp-ord, input-output rc-ord ).
        end.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-c-shift-obj:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-shift-obj). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-shift-obj). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-c-shift-obj). endkey", vss-include-info4 )
  :
    define buffer buf_c-shift-obj   for ub.c-shift-obj.
    define buffer buf_c-shift-staff for ub.c-shift-staff.
    define buffer buf_shift-cash  for ub.shift-cash.
    define buffer buf_c-sht-hist for ub.c-sht-hist.
    define buffer buf_old_c-shift-obj   for ub.c-shift-obj.
    find buf_c-shift-obj where rowid(buf_c-shift-obj) = tbl-row.
    for each buf_shift-cash where buf_shift-cash.obj-type   = buf_c-shift-obj.obj-type
                            and buf_shift-cash.obj-code   = buf_c-shift-obj.obj-code
                            and buf_shift-cash.shift-date = buf_c-shift-obj.shift-date
                            and buf_shift-cash.shift-num  = buf_c-shift-obj.shift-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'shift-cash':U, (buffer buf_shift-cash:handle), dmp-ord, input-output rc-ord ).
    end.
    _buf_c-sht-hist:
    for each buf_c-sht-hist where buf_c-sht-hist.obj-type   = buf_c-shift-obj.obj-type
                            and buf_c-sht-hist.obj-code   = buf_c-shift-obj.obj-code
                            and buf_c-sht-hist.shift-date = buf_c-shift-obj.shift-date
                            and buf_c-sht-hist.shift-num  = buf_c-shift-obj.shift-num
                            and buf_c-sht-hist.corr-user-db-num  = buf_c-shift-obj.corr-user-db-num
                            and buf_c-sht-hist.chip-num  <= buf_c-shift-obj.chip-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      CASE buf_c-sht-hist.subject:
        when 'shift-staff':U then do:
          if buf_c-sht-hist.chip-num = buf_c-shift-obj.chip-num then next _buf_c-sht-hist.
          find first buf_c-shift-staff where buf_c-shift-staff.obj-type   = buf_c-sht-hist.obj-type
                              and buf_c-shift-staff.obj-code   = buf_c-sht-hist.obj-code
                              and buf_c-shift-staff.shift-date = buf_c-sht-hist.shift-date
                              and buf_c-shift-staff.shift-num  = buf_c-sht-hist.shift-num
                              and buf_c-shift-staff.corr-user-db-num  = buf_c-sht-hist.corr-user-db-num
                              and buf_c-shift-staff.chip-num  = buf_c-sht-hist.chip-num no-error .
          if not available buf_c-shift-staff then do:
              undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ).
          end.
          run cre-route-dump( p-act-name, 'c-shift-staff':U, (buffer buf_c-shift-staff:handle), dmp-ord, input-output rc-ord ).
        end.
        when 'shift-obj':U then do:
          find first buf_old_c-shift-obj where buf_old_c-shift-obj.obj-type   = buf_c-sht-hist.obj-type
                              and buf_old_c-shift-obj.obj-code   = buf_c-sht-hist.obj-code
                              and buf_old_c-shift-obj.shift-date = buf_c-sht-hist.shift-date
                              and buf_old_c-shift-obj.shift-num  = buf_c-sht-hist.shift-num
                              and buf_old_c-shift-obj.corr-user-db-num  = buf_c-sht-hist.corr-user-db-num
                              and buf_old_c-shift-obj.chip-num  = buf_c-sht-hist.chip-num no-error .
          if not available buf_old_c-shift-obj then do:
              undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ).
          end.
          run cre-route-dump( p-act-name, 'c-shift-obj':U, (buffer buf_old_c-shift-obj:handle), dmp-ord, input-output rc-ord ).
        end.
      END CASE.
      run cre-route-dump( p-act-name, 'c-sht-hist':U, (buffer buf_c-sht-hist:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-ord-doc:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-ord-doc). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-ord-doc). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-ord-doc). endkey", vss-include-info4 )
  :
    define buffer buf_ord-doc  for ub.ord-doc.
    define buffer buf_ord-line for ub.ord-line.
    define buffer buf_ord-dtl  for ub.ord-dtl.
    define buffer buf_ord-doc-attr  for ub.ord-doc-attr.
    define buffer buf_ord-line-attr for ub.ord-line-attr.
    find buf_ord-doc where rowid(buf_ord-doc) = tbl-row.
    for each buf_ord-line where buf_ord-line.doc-code = buf_ord-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'ord-line':U, (buffer buf_ord-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-line-attr where buf_ord-line-attr.doc-code = buf_ord-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'ord-line-attr':U, (buffer buf_ord-line-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-doc-attr where buf_ord-doc-attr.doc-code = buf_ord-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'ord-doc-attr':U, (buffer buf_ord-doc-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-dtl where buf_ord-dtl.doc-code = buf_ord-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'ord-dtl':U, (buffer buf_ord-dtl:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-ord-doc-rcv:
  define input        parameter p-act-name as   character no-undo .
  define input        parameter tbl-row    as   rowid                  no-undo.
  define input        parameter dmp-ord    like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord     like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-ord-doc-rcv). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-ord-doc-rcv). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-ord-doc-rcv). endkey", vss-include-info4 )
  :
    define buffer buf_ord-doc-rcv  for ub.ord-doc-rcv.
    define buffer buf_ord-line-rcv for ub.ord-line-rcv.
    define buffer buf_ord-rcv-attr  for ub.ord-rcv-attr.
    define buffer buf_ord-rcv-line-attr for ub.ord-rcv-line-attr.
    define buffer buf_ord-dtl-rcv  for ub.ord-dtl-rcv.
    define buffer buf_ord-doc      for ub.ord-doc.
    define buffer buf_ord-line     for ub.ord-line.
    define buffer buf_ord-dtl      for ub.ord-dtl.
    define buffer buf_ord-doc-attr  for ub.ord-doc-attr.
    define buffer buf_ord-line-attr for ub.ord-line-attr.
    find buf_ord-doc-rcv where rowid(buf_ord-doc-rcv) = tbl-row.
    for each buf_ord-line-rcv
       where buf_ord-line-rcv.doc-code = buf_ord-doc-rcv.doc-code
         and buf_ord-line-rcv.rcv-code = buf_ord-doc-rcv.rcv-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'ord-line-rcv':U, (buffer buf_ord-line-rcv:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-dtl-rcv
       where buf_ord-dtl-rcv.doc-code = buf_ord-doc-rcv.doc-code
         and buf_ord-dtl-rcv.rcv-code = buf_ord-doc-rcv.rcv-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'ord-dtl-rcv':U, (buffer buf_ord-dtl-rcv:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-line where buf_ord-line.doc-code = buf_ord-doc-rcv.doc-code ,
        first buf_ord-doc no-lock where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code
                                    and buf_ord-doc.doc-type <> 'ОР':U
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'ord-line':U, (buffer buf_ord-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-dtl
       where buf_ord-dtl.doc-code = buf_ord-doc-rcv.doc-code ,
        first buf_ord-doc no-lock where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code
                                    and buf_ord-doc.doc-type <> 'ОР':U
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'ord-dtl':U, (buffer buf_ord-dtl:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-doc
       where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code
         and buf_ord-doc.doc-type <> 'ОР':U
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'ord-doc':U, (buffer buf_ord-doc:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-line-attr where buf_ord-line-attr.doc-code = buf_ord-doc-rcv.doc-code ,
        first buf_ord-doc no-lock where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code
                                    and buf_ord-doc.doc-type <> 'ОР':U
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'ord-line-attr':U, (buffer buf_ord-line-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-doc-attr where buf_ord-doc-attr.doc-code = buf_ord-doc-rcv.doc-code  ,
        first buf_ord-doc no-lock where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code
                                    and buf_ord-doc.doc-type <> 'ОР':U
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'ord-doc-attr':U, (buffer buf_ord-doc-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-rcv-line-attr
       where buf_ord-rcv-line-attr.doc-code = buf_ord-doc-rcv.doc-code
         and buf_ord-rcv-line-attr.rcv-code = buf_ord-doc-rcv.rcv-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'ord-rcv-line-attr':U, (buffer buf_ord-rcv-line-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-rcv-attr
       where buf_ord-rcv-attr.doc-code = buf_ord-doc-rcv.doc-code
         and buf_ord-rcv-attr.rcv-code = buf_ord-doc-rcv.rcv-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'ord-rcv-attr':U, (buffer buf_ord-rcv-attr:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-ord-cons:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-ord-cons). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-ord-cons). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-ord-cons). endkey", vss-include-info4 )
  :
    define buffer buf_ord-cons     for ub.ord-cons.
    define buffer buf_ord-gds-cons for ub.ord-gds-cons.
    define buffer buf_ord-dtl-cons for ub.ord-dtl-cons.
    find buf_ord-cons where rowid(buf_ord-cons) = tbl-row.
    for each buf_ord-gds-cons
       where buf_ord-gds-cons.cons-code = buf_ord-cons.cons-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'ord-gds-cons':U, (buffer buf_ord-gds-cons:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_ord-dtl-cons
       where buf_ord-dtl-cons.cons-code = buf_ord-cons.cons-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'ord-dtl-cons':U, (buffer buf_ord-dtl-cons:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-fin-ob:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-fin-ob). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-fin-ob). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-fin-ob). endkey", vss-include-info4 )
  :
    define buffer buf_fin-ob     for ub.fin-ob.
    define buffer buf_fin-ob-tax for ub.fin-ob-tax.
    define buffer buf_fin-ob-trn for ub.fin-ob-trn.
    define buffer buf_fin-gds-part for ub.fin-gds-part.
    find buf_fin-ob where rowid(buf_fin-ob) = tbl-row.
    for each buf_fin-ob-tax
       where buf_fin-ob-tax.doc-code = buf_fin-ob.doc-code and buf_fin-ob-tax.host-code = buf_fin-ob.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'fin-ob-tax':U, (buffer buf_fin-ob-tax:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_fin-ob-trn
       where buf_fin-ob-trn.doc-code = buf_fin-ob.doc-code and buf_fin-ob-trn.host-code = buf_fin-ob.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'fin-ob-trn':U, (buffer buf_fin-ob-trn:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_fin-gds-part
       where buf_fin-gds-part.fin-ob-code = buf_fin-ob.doc-code and buf_fin-gds-part.host-code = buf_fin-ob.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'fin-gds-part':U, (buffer buf_fin-gds-part:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-c-fin-ob:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-fin-ob). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-fin-ob). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-c-fin-ob). endkey", vss-include-info4 )
  :
    define buffer buf_c-fin-ob     for ub.c-fin-ob.
    define buffer buf_c-fin-ob-tax for ub.c-fin-ob-tax.
    find buf_c-fin-ob where rowid(buf_c-fin-ob) = tbl-row.
    for each buf_c-fin-ob-tax
       where buf_c-fin-ob-tax.doc-code = buf_c-fin-ob.doc-code and buf_c-fin-ob-tax.host-code = buf_c-fin-ob.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'c-fin-ob-tax':U, (buffer buf_c-fin-ob-tax:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-fin-doc:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-fin-doc). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-fin-doc). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-fin-doc). endkey", vss-include-info4 )
  :
    define buffer buf_fin-doc     for ub.fin-doc.
    define buffer buf_fin-doc-tax for ub.fin-doc-tax.
    define buffer buf_fin-doc-attr for ub.fin-doc-attr.
    find buf_fin-doc where rowid(buf_fin-doc) = tbl-row.
    for each buf_fin-doc-tax
       where buf_fin-doc-tax.fin-doc-code = buf_fin-doc.fin-doc-code and buf_fin-doc-tax.host-code = buf_fin-doc.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'fin-doc-tax':U, (buffer buf_fin-doc-tax:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_fin-doc-attr
       where buf_fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code and buf_fin-doc-attr.host-code = buf_fin-doc.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'fin-doc-attr':U, (buffer buf_fin-doc-attr:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-c-fin-doc:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-fin-doc). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-fin-doc). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-c-fin-doc). endkey", vss-include-info4 )
  :
    define buffer buf_c-fin-doc     for ub.c-fin-doc.
    define buffer buf_c-fin-doc-tax for ub.c-fin-doc-tax.
    define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
    find buf_c-fin-doc where rowid(buf_c-fin-doc) = tbl-row.
    for each buf_c-fin-doc-tax
       where buf_c-fin-doc-tax.fin-doc-code = buf_c-fin-doc.fin-doc-code and buf_c-fin-doc-tax.host-code = buf_c-fin-doc.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'c-fin-doc-tax':U, (buffer buf_c-fin-doc-tax:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-fin-doc-attr
       where buf_c-fin-doc-attr.fin-doc-code = buf_c-fin-doc.fin-doc-code and buf_c-fin-doc-attr.host-code = buf_c-fin-doc.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'c-fin-doc-attr':U, (buffer buf_c-fin-doc-attr:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-drt-prop no-undo like ub.drt-prop.
procedure disrules-fill-properties:
define input  parameter p-templ-rl-root as integer   no-undo .
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_temp-drt-prop for temp-drt-prop.
do
on error undo, return error return-value
:
  for each buf_temp-drt-prop:
    delete buf_temp-drt-prop.
  end.
  for each buf_drt-prop where buf_drt-prop.templ-rl-root = p-templ-rl-root:
    create buf_temp-drt-prop.
    buffer-copy buf_drt-prop to buf_temp-drt-prop.
  end.
end.
end procedure.
~
PROCEDURE cre-dump-dis-rule:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-dis-rule). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-dis-rule). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-dis-rule). endkey", vss-include-info4 )
  :
    define buffer buf_dis-rule     for ub.dis-rule.
    define buffer buf2_dis-rule     for ub.dis-rule.
    find buf_dis-rule where rowid(buf_dis-rule) = tbl-row.
    if buf_dis-rule.rule-num > 99999 then do:
    for each buf2_dis-rule
       where buf2_dis-rule.upper-rule-num = buf_dis-rule.rule-num
    on error undo, return error return-value :
      run cre-route-dump( p-act-name, 'dis-rule':U, (buffer buf2_dis-rule:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-dis-time-rule:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-dis-time-rule). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-dis-time-rule). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-dis-time-rule). endkey", vss-include-info4 )
  :
    define buffer buf_dis-time-rule     for ub.dis-time-rule.
    define buffer buf2_dis-time-rule     for ub.dis-time-rule.
    find buf_dis-time-rule where rowid(buf_dis-time-rule) = tbl-row.
    if buf_dis-time-rule.time-rule-num > 99999 then do:
    for each buf2_dis-time-rule
       where buf2_dis-time-rule.upper-time-rule-num = buf_dis-time-rule.time-rule-num
    on error undo, return error return-value :
      run cre-route-dump( p-act-name, 'dis-time-rule':U, (buffer buf2_dis-time-rule:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-abc-analysis:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-abc-analysis). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-abc-analysis). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-abc-analysis). endkey", vss-include-info4 )
  :
    define buffer buf_abc-analysis         for ub.abc-analysis        .
    define buffer buf_abc-analysis-obj     for ub.abc-analysis-obj      .
    define buffer buf_abc-analysis-doc     for ub.abc-analysis-doc      .
    define buffer buf_abc-analysis-period  for ub.abc-analysis-period      .
    define buffer buf_abc-analysis-attr    for ub.abc-analysis-attr     .
    define buffer buf_abc-analysis-goods   for ub.abc-analysis-goods  .
    define buffer buf_abc-analysis-goods-attr     for ub.abc-analysis-goods-attr.
    define buffer buf_abc-analysis-gds-obj        for ub.abc-analysis-gds-obj  .
    define buffer buf_abc-analysis-gds-obj-attr   for ub.abc-analysis-gds-obj-attr.
    find buf_abc-analysis where rowid(buf_abc-analysis) = tbl-row.
    for each buf_abc-analysis-obj
       where buf_abc-analysis-obj.abc-id  = buf_abc-analysis.abc-id and
             buf_abc-analysis-obj.db-num  = buf_abc-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'abc-analysis-obj':U, (buffer buf_abc-analysis-obj:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_abc-analysis-doc
       where buf_abc-analysis-doc.abc-id  = buf_abc-analysis.abc-id and
             buf_abc-analysis-doc.db-num  = buf_abc-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'abc-analysis-doc':U, (buffer buf_abc-analysis-doc:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_abc-analysis-period
       where buf_abc-analysis-period.abc-id  = buf_abc-analysis.abc-id and
             buf_abc-analysis-period.db-num  = buf_abc-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'abc-analysis-period':U, (buffer buf_abc-analysis-period:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_abc-analysis-attr
       where buf_abc-analysis-attr.abc-id  = buf_abc-analysis.abc-id and
             buf_abc-analysis-attr.db-num  = buf_abc-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'abc-analysis-attr':U, (buffer buf_abc-analysis-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_abc-analysis-goods-attr
       where buf_abc-analysis-goods-attr.abc-id  = buf_abc-analysis.abc-id and
             buf_abc-analysis-goods-attr.db-num  = buf_abc-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'abc-analysis-goods-attr':U, (buffer buf_abc-analysis-goods-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_abc-analysis-goods
       where buf_abc-analysis-goods.abc-id  = buf_abc-analysis.abc-id and
             buf_abc-analysis-goods.db-num  = buf_abc-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'abc-analysis-goods':U, (buffer buf_abc-analysis-goods:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_abc-analysis-gds-obj-attr
       where buf_abc-analysis-gds-obj-attr.abc-id  = buf_abc-analysis.abc-id and
             buf_abc-analysis-gds-obj-attr.db-num  = buf_abc-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'abc-analysis-gds-obj-attr':U, (buffer buf_abc-analysis-gds-obj-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_abc-analysis-gds-obj
       where buf_abc-analysis-gds-obj.abc-id  = buf_abc-analysis.abc-id and
             buf_abc-analysis-gds-obj.db-num  = buf_abc-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'abc-analysis-gds-obj':U, (buffer buf_abc-analysis-gds-obj:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-xyz-analysis:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-xyz-analysis). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-xyz-analysis). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-xyz-analysis). endkey", vss-include-info4 )
  :
    define buffer buf_xyz-analysis         for ub.xyz-analysis        .
    define buffer buf_xyz-analysis-obj     for ub.xyz-analysis-obj      .
    define buffer buf_xyz-analysis-doc     for ub.xyz-analysis-doc      .
    define buffer buf_xyz-analysis-period  for ub.xyz-analysis-period      .
    define buffer buf_xyz-analysis-attr    for ub.xyz-analysis-attr     .
    define buffer buf_xyz-analysis-goods   for ub.xyz-analysis-goods  .
    define buffer buf_xyz-analysis-goods-attr     for ub.xyz-analysis-goods-attr.
    define buffer buf_xyz-analysis-gds-obj        for ub.xyz-analysis-gds-obj  .
    define buffer buf_xyz-analysis-gds-obj-attr   for ub.xyz-analysis-gds-obj-attr.
    find buf_xyz-analysis where rowid(buf_xyz-analysis) = tbl-row.
    for each buf_xyz-analysis-obj
       where buf_xyz-analysis-obj.xyz-id  = buf_xyz-analysis.xyz-id and
             buf_xyz-analysis-obj.db-num  = buf_xyz-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'xyz-analysis-obj':U, (buffer buf_xyz-analysis-obj:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_xyz-analysis-doc
       where buf_xyz-analysis-doc.xyz-id  = buf_xyz-analysis.xyz-id and
             buf_xyz-analysis-doc.db-num  = buf_xyz-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'xyz-analysis-doc':U, (buffer buf_xyz-analysis-doc:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_xyz-analysis-period
       where buf_xyz-analysis-period.xyz-id  = buf_xyz-analysis.xyz-id and
             buf_xyz-analysis-period.db-num  = buf_xyz-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'xyz-analysis-period':U, (buffer buf_xyz-analysis-period:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_xyz-analysis-attr
       where buf_xyz-analysis-attr.xyz-id  = buf_xyz-analysis.xyz-id and
             buf_xyz-analysis-attr.db-num  = buf_xyz-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'xyz-analysis-attr':U, (buffer buf_xyz-analysis-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_xyz-analysis-goods-attr
       where buf_xyz-analysis-goods-attr.xyz-id  = buf_xyz-analysis.xyz-id and
             buf_xyz-analysis-goods-attr.db-num  = buf_xyz-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'xyz-analysis-goods-attr':U, (buffer buf_xyz-analysis-goods-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_xyz-analysis-goods
       where buf_xyz-analysis-goods.xyz-id  = buf_xyz-analysis.xyz-id and
             buf_xyz-analysis-goods.db-num  = buf_xyz-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'xyz-analysis-goods':U, (buffer buf_xyz-analysis-goods:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_xyz-analysis-gds-obj-attr
       where buf_xyz-analysis-gds-obj-attr.xyz-id  = buf_xyz-analysis.xyz-id and
             buf_xyz-analysis-gds-obj-attr.db-num  = buf_xyz-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'xyz-analysis-gds-obj-attr':U, (buffer buf_xyz-analysis-gds-obj-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_xyz-analysis-gds-obj
       where buf_xyz-analysis-gds-obj.xyz-id  = buf_xyz-analysis.xyz-id and
             buf_xyz-analysis-gds-obj.db-num  = buf_xyz-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'xyz-analysis-gds-obj':U, (buffer buf_xyz-analysis-gds-obj:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-abcxyz-analysis:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-abcxyz-analysis). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-abcxyz-analysis). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-abcxyz-analysis). endkey", vss-include-info4 )
  :
    define buffer buf_abcxyz-analysis         for ub.abcxyz-analysis        .
    define buffer buf_abcxyz-analysis-goods   for ub.abcxyz-analysis-goods  .
    define buffer buf_abcxyz-analysis-goods-attr     for ub.abcxyz-analysis-goods-attr.
    find buf_abcxyz-analysis where rowid(buf_abcxyz-analysis) = tbl-row.
    for each buf_abcxyz-analysis-goods-attr
       where buf_abcxyz-analysis-goods-attr.abcx-id  = buf_abcxyz-analysis.abcx-id and
             buf_abcxyz-analysis-goods-attr.db-num  = buf_abcxyz-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'abcxyz-analysis-goods-attr':U, (buffer buf_abcxyz-analysis-goods-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_abcxyz-analysis-goods
       where buf_abcxyz-analysis-goods.abcx-id  = buf_abcxyz-analysis.abcx-id and
             buf_abcxyz-analysis-goods.db-num  = buf_abcxyz-analysis.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'abcxyz-analysis-goods':U, (buffer buf_abcxyz-analysis-goods:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-rang-abc-def:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-rang-abc-def). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-rang-abc-def). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-rang-abc-def). endkey", vss-include-info4 )
  :
    define buffer buf_rang-abc-def         for ub.rang-abc-def        .
    define buffer buf_rang-abc-def-obj     for ub.rang-abc-def-obj     .
    find buf_rang-abc-def where rowid(buf_rang-abc-def) = tbl-row.
    for each buf_rang-abc-def-obj
       where buf_rang-abc-def-obj.raad-id    = buf_rang-abc-def.raad-id and
             buf_rang-abc-def-obj.db-num     = buf_rang-abc-def.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'rang-abc-def-obj':U, (buffer buf_rang-abc-def-obj:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-doc-abc-def:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-doc-abc-def). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-doc-abc-def). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-doc-abc-def). endkey", vss-include-info4 )
  :
    define buffer buf_doc-abc-def         for ub.doc-abc-def        .
    define buffer buf_doc-abc-def-obj     for ub.doc-abc-def-obj     .
    define buffer buf_doc-abc-def-doc     for ub.doc-abc-def-doc     .
    find buf_doc-abc-def where rowid(buf_doc-abc-def) = tbl-row.
    for each buf_doc-abc-def-obj
       where buf_doc-abc-def-obj.doad-id    = buf_doc-abc-def.doad-id and
             buf_doc-abc-def-obj.db-num     = buf_doc-abc-def.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'doc-abc-def-obj':U, (buffer buf_doc-abc-def-obj:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_doc-abc-def-doc
       where buf_doc-abc-def-doc.doad-id    = buf_doc-abc-def.doad-id and
             buf_doc-abc-def-doc.db-num     = buf_doc-abc-def.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'doc-abc-def-doc':U, (buffer buf_doc-abc-def-doc:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-rang-xyz-def:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-rang-xyz-def). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-rang-xyz-def). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-rang-xyz-def). endkey", vss-include-info4 )
  :
    define buffer buf_rang-xyz-def         for ub.rang-xyz-def        .
    define buffer buf_rang-xyz-def-obj     for ub.rang-xyz-def-obj     .
    find buf_rang-xyz-def where rowid(buf_rang-xyz-def) = tbl-row.
    for each buf_rang-xyz-def-obj
       where buf_rang-xyz-def-obj.raxd-id    = buf_rang-xyz-def.raxd-id and
             buf_rang-xyz-def-obj.db-num     = buf_rang-xyz-def.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'rang-xyz-def-obj':U, (buffer buf_rang-xyz-def-obj:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-doc-xyz-def:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-doc-xyz-def). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-doc-xyz-def). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-doc-xyz-def). endkey", vss-include-info4 )
  :
    define buffer buf_doc-xyz-def         for ub.doc-xyz-def        .
    define buffer buf_doc-xyz-def-obj     for ub.doc-xyz-def-obj     .
    define buffer buf_doc-xyz-def-doc     for ub.doc-xyz-def-doc     .
    find buf_doc-xyz-def where rowid(buf_doc-xyz-def) = tbl-row.
    for each buf_doc-xyz-def-obj
       where buf_doc-xyz-def-obj.doxd-id    = buf_doc-xyz-def.doxd-id and
             buf_doc-xyz-def-obj.db-num     = buf_doc-xyz-def.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'doc-xyz-def-obj':U, (buffer buf_doc-xyz-def-obj:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_doc-xyz-def-doc
       where buf_doc-xyz-def-doc.doxd-id    = buf_doc-xyz-def.doxd-id and
             buf_doc-xyz-def-doc.db-num     = buf_doc-xyz-def.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'doc-xyz-def-doc':U, (buffer buf_doc-xyz-def-doc:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-fin-statement:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-fin-statement). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-fin-statement). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-fin-statement). endkey", vss-include-info4 )
  :
    define buffer buf_fin-statement     for ub.fin-statement.
    define buffer buf_fin-statement-line for ub.fin-statement-line.
    define buffer buf_fin-statement-attr for ub.fin-statement-attr.
    find buf_fin-statement where rowid(buf_fin-statement) = tbl-row.
    for each buf_fin-statement-line
       where buf_fin-statement-line.sttm-code = buf_fin-statement.sttm-code and buf_fin-statement-line.host-code = buf_fin-statement.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'fin-statement-line':U, (buffer buf_fin-statement-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_fin-statement-attr
       where buf_fin-statement-attr.sttm-code = buf_fin-statement.sttm-code and buf_fin-statement-attr.host-code = buf_fin-statement.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'fin-statement-attr':U, (buffer buf_fin-statement-attr:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-c-fin-statement:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-fin-statement). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-fin-statement). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-c-fin-statement). endkey", vss-include-info4 )
  :
    define buffer buf_c-fin-statement     for ub.c-fin-statement.
    define buffer buf_c-fin-statement-line for ub.c-fin-statement-line.
    define buffer buf_c-fin-statement-attr for ub.c-fin-statement-attr.
    find buf_c-fin-statement where rowid(buf_c-fin-statement) = tbl-row.
    for each buf_c-fin-statement-line
       where buf_c-fin-statement-line.sttm-code = buf_c-fin-statement.sttm-code and buf_c-fin-statement-line.host-code = buf_c-fin-statement.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'c-fin-statement-line':U, (buffer buf_c-fin-statement-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-fin-statement-attr
       where buf_c-fin-statement-attr.sttm-code = buf_c-fin-statement.sttm-code and buf_c-fin-statement-attr.host-code = buf_c-fin-statement.host-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'c-fin-statement-attr':U, (buffer buf_c-fin-statement-attr:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-schet-fact-doc:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-schet-fact-doc). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-schet-fact-doc). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-schet-fact-doc). endkey", vss-include-info4 )
  :
    define buffer buf_schet-fact-doc  for ub.schet-fact-doc.
    define buffer buf_schet-fact-line for ub.schet-fact-line.
    find buf_schet-fact-doc where rowid(buf_schet-fact-doc) = tbl-row.
    for each buf_schet-fact-line where buf_schet-fact-line.doc-code = buf_schet-fact-doc.doc-code  and
                                       buf_schet-fact-line.db-num   = buf_schet-fact-doc.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'schet-fact-line':U, (buffer buf_schet-fact-line:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-c-schet-fact-doc:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-schet-fact-doc). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-schet-fact-doc). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-c-schet-fact-doc). endkey", vss-include-info4 )
  :
    define buffer buf_c-schet-fact-doc  for ub.c-schet-fact-doc.
    define buffer buf_c-schet-fact-line for ub.c-schet-fact-line.
    find buf_c-schet-fact-doc where rowid(buf_c-schet-fact-doc) = tbl-row.
    for each buf_c-schet-fact-line where buf_c-schet-fact-line.doc-code  = buf_c-schet-fact-doc.doc-code   and
                                         buf_c-schet-fact-line.db-num = buf_c-schet-fact-doc.db-num  and
                                         buf_c-schet-fact-line.chip-num  = buf_c-schet-fact-doc.chip-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'c-schet-fact-line':U, (buffer buf_c-schet-fact-line:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-factur-connect:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-factur-connect). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-factur-connect). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-factur-connect). endkey", vss-include-info4 )
  :
    define buffer buf_factur-connect  for ub.factur-connect.
    define buffer buf_factur-connect-line for ub.factur-connect-line.
    find buf_factur-connect where rowid(buf_factur-connect) = tbl-row.
    for each buf_factur-connect-line where buf_factur-connect-line.connect-code  = buf_factur-connect.connect-code  and
                                           buf_factur-connect-line.db-num     = buf_factur-connect.db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'factur-connect-line':U, (buffer buf_factur-connect-line:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-global-state  :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-global-state). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-global-state). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-global-state). endkey", vss-include-info4 )
  :
    define buffer buf_global-state  for ub.global-state.
    define buffer buf_global-state-attr   for ub.global-state-attr.
    define buffer buf_c-global-state  for ub.c-global-state.
    define buffer buf_c-global-state-attr   for ub.c-global-state-attr.
    find buf_global-state where rowid(buf_global-state) = tbl-row.
    for each buf_global-state-attr where buf_global-state-attr.gls-id = buf_global-state.gls-id
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'global-state-attr':U, (buffer buf_global-state-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-global-state-attr") then
    do:
      for each buf_c-global-state-attr where buf_c-global-state-attr.gls-id = buf_global-state.gls-id
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'c-global-state-attr':U, (buffer buf_c-global-state-attr:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
    if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-global-state") then
    do:
      for each buf_c-global-state where buf_c-global-state.gls-id = buf_global-state.gls-id
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'c-global-state':U, (buffer buf_c-global-state:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-sum-group :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-sum-group). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-sum-group). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-sum-group). endkey", vss-include-info4 )
  :
    define buffer buf_sum-group  for ub.sum-group.
    define buffer buf_c-sum-group  for ub.c-sum-group.
    define buffer buf_c-sum-in-sum-group   for ub.c-sum-in-sum-group.
    define buffer buf_sum-in-sum-group   for ub.sum-in-sum-group.
    find buf_sum-group where rowid(buf_sum-group) = tbl-row.
    if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-sum-group") then
    do:
      for each buf_c-sum-group where
               buf_c-sum-group.sgr-id     = buf_sum-group.sgr-id and
               buf_c-sum-group.sgr-db-num = buf_sum-group.sgr-db-num
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'c-sum-group':U, (buffer buf_c-sum-group:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
    if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-sum-in-sum-group") then
    do:
      for each buf_c-sum-in-sum-group where
               buf_c-sum-in-sum-group.sgr-id     = buf_sum-group.sgr-id and
               buf_c-sum-in-sum-group.sgr-db-num = buf_sum-group.sgr-db-num
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'c-sum-in-sum-group':U, (buffer buf_c-sum-in-sum-group:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
    for each buf_sum-in-sum-group where
             buf_sum-in-sum-group.sgr-id     = buf_sum-group.sgr-id and
             buf_sum-in-sum-group.sgr-db-num = buf_sum-group.sgr-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'sum-in-sum-group':U, (buffer buf_sum-in-sum-group:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-qnty-group :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-qnty-group). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-qnty-group). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-qnty-group). endkey", vss-include-info4 )
  :
    define buffer buf_qnty-group  for ub.qnty-group.
    define buffer buf_c-qnty-group  for ub.c-qnty-group.
    define buffer buf_c-qnty-in-qnty-group   for ub.c-qnty-in-qnty-group.
    define buffer buf_qnty-in-qnty-group   for ub.qnty-in-qnty-group.
    find buf_qnty-group where rowid(buf_qnty-group) = tbl-row.
    if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-qnty-group") then
    do:
      for each buf_c-qnty-group where
               buf_c-qnty-group.qgr-id     = buf_qnty-group.qgr-id and
               buf_c-qnty-group.qgr-db-num = buf_qnty-group.qgr-db-num
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'c-qnty-group':U, (buffer buf_c-qnty-group:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
    if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-qnty-in-qnty-group") then
    do:
      for each buf_c-qnty-in-qnty-group where
               buf_c-qnty-in-qnty-group.qgr-id     = buf_qnty-group.qgr-id and
               buf_c-qnty-in-qnty-group.qgr-db-num = buf_qnty-group.qgr-db-num
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'c-qnty-in-qnty-group':U, (buffer buf_c-qnty-in-qnty-group:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
    for each buf_qnty-in-qnty-group where
             buf_qnty-in-qnty-group.qgr-id     = buf_qnty-group.qgr-id and
             buf_qnty-in-qnty-group.qgr-db-num = buf_qnty-group.qgr-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'qnty-in-qnty-group':U, (buffer buf_qnty-in-qnty-group:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-turnover-group :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-turnover-group). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-turnover-group). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-turnover-group). endkey", vss-include-info4 )
  :
    define buffer buf_turnover-group  for ub.turnover-group.
    define buffer buf_c-turnover-group  for ub.c-turnover-group.
    define buffer buf_c-tnv-in-turnover-group for ub.c-tnv-in-turnover-group.
    define buffer buf_tnv-in-turnover-group   for ub.tnv-in-turnover-group.
    find buf_turnover-group where rowid(buf_turnover-group) = tbl-row.
    if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-turnover-group") then
    do:
      for each buf_c-turnover-group where
               buf_c-turnover-group.tog-id     = buf_turnover-group.tog-id and
               buf_c-turnover-group.tog-db-num = buf_turnover-group.tog-db-num
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'c-turnover-group':U, (buffer buf_c-turnover-group:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
    if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-tnv-in-turnover-group") then
    do:
      for each buf_c-tnv-in-turnover-group where
               buf_c-tnv-in-turnover-group.tog-id     = buf_turnover-group.tog-id and
               buf_c-tnv-in-turnover-group.tog-db-num = buf_turnover-group.tog-db-num
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'c-tnv-in-turnover-group':U, (buffer buf_c-tnv-in-turnover-group:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
    for each buf_tnv-in-turnover-group where
             buf_tnv-in-turnover-group.tog-id     = buf_turnover-group.tog-id and
             buf_tnv-in-turnover-group.tog-db-num = buf_turnover-group.tog-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'tnv-in-turnover-group':U, (buffer buf_tnv-in-turnover-group:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-buyer-group    :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-buyer-group). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-buyer-group). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-buyer-group). endkey", vss-include-info4 )
  :
    define buffer buf_buyer-group  for ub.buyer-group.
    define buffer buf_c-buyer-group  for ub.c-buyer-group.
    find buf_buyer-group where rowid(buf_buyer-group) = tbl-row.
    if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-buyer-group") then
    do:
      for each buf_c-buyer-group where
               buf_c-buyer-group.bgr-id     = buf_buyer-group.bgr-id and
               buf_c-buyer-group.bgr-db-num = buf_buyer-group.bgr-db-num
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'c-buyer-group':U, (buffer buf_c-buyer-group:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-buyer-in-buyer-group    :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-buyer-in-dump-buyer-group). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-buyer-in-dump-buyer-group). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-buyer-in-dump-buyer-group). endkey", vss-include-info4 )
  :
    define buffer buf_buyer-in-buyer-group  for ub.buyer-in-buyer-group.
    define buffer buf_c-buyer-in-buyer-group  for ub.c-buyer-in-buyer-group.
    find buf_buyer-in-buyer-group where rowid(buf_buyer-in-buyer-group) = tbl-row.
    if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-buyer-in-buyer-group") then
    do:
      for each buf_c-buyer-in-buyer-group where
               buf_c-buyer-in-buyer-group.bgr-id       = buf_buyer-in-buyer-group.bgr-id and
               buf_c-buyer-in-buyer-group.bgr-db-num   = buf_buyer-in-buyer-group.bgr-db-num and
               buf_c-buyer-in-buyer-group.bbg-obj-type = buf_buyer-in-buyer-group.bbg-obj-type and
               buf_c-buyer-in-buyer-group.bbg-obj-code = buf_buyer-in-buyer-group.bbg-obj-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'c-buyer-in-buyer-group':U, (buffer buf_c-buyer-in-buyer-group:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-grp-obj-price  :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-grp-obj-price). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-grp-obj-price). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-grp-obj-price). endkey", vss-include-info4 )
  :
  define buffer buf_grp-obj-price       for ub.grp-obj-price     .
  define buffer buf_db-grp-obj-price    for ub.db-grp-obj-price  .
  define buffer buf_host-grp-obj-price  for ub.host-grp-obj-price.
  define buffer buf_obj-grp-obj-price   for ub.obj-grp-obj-price .
    find buf_grp-obj-price where rowid (buf_grp-obj-price) = tbl-row.
    for each buf_db-grp-obj-price where
             buf_db-grp-obj-price.gop-id       = buf_grp-obj-price.gop-id      and
             buf_db-grp-obj-price.gop-db-num   = buf_grp-obj-price.gop-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, 'db-grp-obj-price':U, (buffer buf_db-grp-obj-price:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_host-grp-obj-price where
             buf_host-grp-obj-price.gop-id       = buf_grp-obj-price.gop-id      and
             buf_host-grp-obj-price.gop-db-num   = buf_grp-obj-price.gop-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, 'host-grp-obj-price':U, (buffer buf_host-grp-obj-price:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_obj-grp-obj-price where
             buf_obj-grp-obj-price.gop-id       = buf_grp-obj-price.gop-id      and
             buf_obj-grp-obj-price.gop-db-num   = buf_grp-obj-price.gop-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, 'obj-grp-obj-price':U, (buffer buf_obj-grp-obj-price:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-turnover-buyer-main :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-turnover-buyer-main). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-turnover-buyer-main). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-turnover-buyer-main). endkey", vss-include-info4 )
  :
  end.
END PROCEDURE.
PROCEDURE cre-dump-price-list-type     :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-price-list-type). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-price-list-type). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-price-list-type). endkey", vss-include-info4 )
  :
    define buffer buf_price-list-type                 for ub.price-list-type               .
    define buffer buf_price-list-type-pay-type        for ub.price-list-type-pay-type      .
    define buffer buf_price-list-type-cassa           for ub.price-list-type-cassa         .
    define buffer buf_price-list-type-gds-grp         for ub.price-list-type-gds-grp       .
    define buffer buf_price-list-type-attr            for ub.price-list-type-attr          .
    define buffer buf_price-list-type-cash-pay        for ub.price-list-type-cash-pay      .
    find buf_price-list-type where rowid (buf_price-list-type) = tbl-row.
    for each buf_price-list-type-attr where
             buf_price-list-type-attr.plt-id       = buf_price-list-type.plt-id      and
             buf_price-list-type-attr.plt-db-num   = buf_price-list-type.plt-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, 'price-list-type-attr':U, (buffer buf_price-list-type-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_price-list-type-pay-type where
             buf_price-list-type-pay-type.plt-id       = buf_price-list-type.plt-id      and
             buf_price-list-type-pay-type.plt-db-num   = buf_price-list-type.plt-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, 'price-list-type-pay-type':U, (buffer buf_price-list-type-pay-type:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_price-list-type-cassa where
             buf_price-list-type-cassa.plt-id       = buf_price-list-type.plt-id      and
             buf_price-list-type-cassa.plt-db-num   = buf_price-list-type.plt-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, 'price-list-type-cassa':U, (buffer buf_price-list-type-cassa:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_price-list-type-gds-grp where
             buf_price-list-type-gds-grp.plt-id       = buf_price-list-type.plt-id      and
             buf_price-list-type-gds-grp.plt-db-num   = buf_price-list-type.plt-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, 'price-list-type-gds-grp':U, (buffer buf_price-list-type-gds-grp:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_price-list-type-cash-pay where
             buf_price-list-type-cash-pay.plt-id       = buf_price-list-type.plt-id      and
             buf_price-list-type-cash-pay.plt-db-num   = buf_price-list-type.plt-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, 'price-list-type-cash-pay':U, (buffer buf_price-list-type-cash-pay:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-c-price-list-type     :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-price-list-type). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-price-list-type). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-c-price-list-type). endkey", vss-include-info4 )
  :
    define buffer buf_c-price-list-type                 for ub.c-price-list-type               .
    define buffer buf_c-price-list-type-pay-type        for ub.c-price-list-type-pay-type      .
    define buffer buf_c-price-list-type-cassa           for ub.c-price-list-type-cassa         .
    define buffer buf_c-price-list-type-gds-grp         for ub.c-price-list-type-gds-grp       .
    define buffer buf_c-price-list-type-attr            for ub.c-price-list-type-attr          .
    define buffer buf_c-price-list-type-cash-pay        for ub.c-price-list-type-cash-pay      .
    find buf_c-price-list-type where rowid (buf_c-price-list-type) = tbl-row.
    for each buf_c-price-list-type-attr where
             buf_c-price-list-type-attr.chip-num         = buf_c-price-list-type.chip-num and
             buf_c-price-list-type-attr.corr-user-db-num = buf_c-price-list-type.corr-user-db-num and
             buf_c-price-list-type-attr.plt-id           = buf_c-price-list-type.plt-id      and
             buf_c-price-list-type-attr.plt-db-num       = buf_c-price-list-type.plt-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, 'c-price-list-type-attr':U, (buffer buf_c-price-list-type-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-price-list-type-pay-type where
             buf_c-price-list-type-pay-type.chip-num         = buf_c-price-list-type.chip-num and
             buf_c-price-list-type-pay-type.corr-user-db-num = buf_c-price-list-type.corr-user-db-num and
             buf_c-price-list-type-pay-type.plt-id       = buf_c-price-list-type.plt-id      and
             buf_c-price-list-type-pay-type.plt-db-num   = buf_c-price-list-type.plt-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, 'c-price-list-type-pay-type':U, (buffer buf_c-price-list-type-pay-type:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-price-list-type-cassa where
             buf_c-price-list-type-cassa.chip-num         = buf_c-price-list-type.chip-num and
             buf_c-price-list-type-cassa.corr-user-db-num = buf_c-price-list-type.corr-user-db-num and
             buf_c-price-list-type-cassa.plt-id       = buf_c-price-list-type.plt-id      and
             buf_c-price-list-type-cassa.plt-db-num   = buf_c-price-list-type.plt-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, 'c-price-list-type-cassa':U, (buffer buf_c-price-list-type-cassa:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-price-list-type-gds-grp where
             buf_c-price-list-type-gds-grp.chip-num         = buf_c-price-list-type.chip-num and
             buf_c-price-list-type-gds-grp.corr-user-db-num = buf_c-price-list-type.corr-user-db-num and
             buf_c-price-list-type-gds-grp.plt-id       = buf_c-price-list-type.plt-id      and
             buf_c-price-list-type-gds-grp.plt-db-num   = buf_c-price-list-type.plt-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, 'c-price-list-type-gds-grp':U, (buffer buf_c-price-list-type-gds-grp:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-price-list-type-cash-pay where
             buf_c-price-list-type-cash-pay.chip-num         = buf_c-price-list-type.chip-num and
             buf_c-price-list-type-cash-pay.corr-user-db-num = buf_c-price-list-type.corr-user-db-num and
             buf_c-price-list-type-cash-pay.plt-id       = buf_c-price-list-type.plt-id      and
             buf_c-price-list-type-cash-pay.plt-db-num   = buf_c-price-list-type.plt-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump (p-act-name, 'c-price-list-type-cash-pay':U, (buffer buf_c-price-list-type-cash-pay:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-price-doc-forming   :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-price-doc-forming). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-price-doc-forming). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-price-doc-forming). endkey", vss-include-info4 )
  :
define buffer buf_price-doc-forming            for ub.price-doc-forming            .
define buffer buf_price-doc-forming-attr       for ub.price-doc-forming-attr       .
define buffer buf_price-doc-forming-gds        for ub.price-doc-forming-gds        .
define buffer buf_price-doc-forming-gds-qnty   for ub.price-doc-forming-gds-qnty   .
define buffer buf_price-doc-forming-gds-sum    for ub.price-doc-forming-gds-sum    .
define buffer buf_price-doc-forming-gds-tnv    for ub.price-doc-forming-gds-tnv    .
    find buf_price-doc-forming where rowid (buf_price-doc-forming) = tbl-row.
    for each buf_price-doc-forming-attr where
             buf_price-doc-forming-attr.plt-id       = buf_price-doc-forming.plt-id      and
             buf_price-doc-forming-attr.plt-db-num   = buf_price-doc-forming.plt-db-num  and
             buf_price-doc-forming-attr.pdf-id       = buf_price-doc-forming.pdf-id      and
             buf_price-doc-forming-attr.pdf-db       = buf_price-doc-forming.pdf-db
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, 'price-doc-forming-attr':U, (buffer buf_price-doc-forming-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_price-doc-forming-gds where
             buf_price-doc-forming-gds.plt-id       = buf_price-doc-forming.plt-id      and
             buf_price-doc-forming-gds.plt-db-num   = buf_price-doc-forming.plt-db-num  and
             buf_price-doc-forming-gds.pdf-id       = buf_price-doc-forming.pdf-id      and
             buf_price-doc-forming-gds.pdf-db       = buf_price-doc-forming.pdf-db
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, 'price-doc-forming-gds':U, (buffer buf_price-doc-forming-gds:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_price-doc-forming-gds-qnty where
             buf_price-doc-forming-gds-qnty.plt-id       = buf_price-doc-forming.plt-id      and
             buf_price-doc-forming-gds-qnty.plt-db-num   = buf_price-doc-forming.plt-db-num  and
             buf_price-doc-forming-gds-qnty.pdf-id       = buf_price-doc-forming.pdf-id      and
             buf_price-doc-forming-gds-qnty.pdf-db       = buf_price-doc-forming.pdf-db
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, 'price-doc-forming-gds-qnty':U, (buffer buf_price-doc-forming-gds-qnty:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_price-doc-forming-gds-sum where
             buf_price-doc-forming-gds-sum.plt-id       = buf_price-doc-forming.plt-id      and
             buf_price-doc-forming-gds-sum.plt-db-num   = buf_price-doc-forming.plt-db-num  and
             buf_price-doc-forming-gds-sum.pdf-id       = buf_price-doc-forming.pdf-id      and
             buf_price-doc-forming-gds-sum.pdf-db       = buf_price-doc-forming.pdf-db
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, 'price-doc-forming-gds-sum':U, (buffer buf_price-doc-forming-gds-sum:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_price-doc-forming-gds-tnv where
             buf_price-doc-forming-gds-tnv.plt-id       = buf_price-doc-forming.plt-id      and
             buf_price-doc-forming-gds-tnv.plt-db-num   = buf_price-doc-forming.plt-db-num  and
             buf_price-doc-forming-gds-tnv.pdf-id       = buf_price-doc-forming.pdf-id      and
             buf_price-doc-forming-gds-tnv.pdf-db       = buf_price-doc-forming.pdf-db
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, 'price-doc-forming-gds-tnv':U, (buffer buf_price-doc-forming-gds-tnv:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-c-price-doc-forming   :
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-c-price-doc-forming). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-c-price-doc-forming). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-c-price-doc-forming). endkey", vss-include-info4 )
  :
define buffer buf_c-price-doc-forming          for ub.c-price-doc-forming          .
define buffer buf_c-price-doc-forming-attr     for ub.c-price-doc-forming-attr     .
define buffer buf_c-price-doc-forming-gds      for ub.c-price-doc-forming-gds      .
define buffer buf_c-price-doc-forming-gds-qnty for ub.c-price-doc-forming-gds-qnty .
define buffer buf_c-price-doc-forming-gds-sum  for ub.c-price-doc-forming-gds-sum  .
define buffer buf_c-price-doc-forming-gds-tnv  for ub.c-price-doc-forming-gds-tnv  .
    find buf_c-price-doc-forming where rowid (buf_c-price-doc-forming) = tbl-row.
    for each buf_c-price-doc-forming-attr where
             buf_c-price-doc-forming-attr.chip-num         = buf_c-price-doc-forming.chip-num and
             buf_c-price-doc-forming-attr.corr-user-db-num = buf_c-price-doc-forming.corr-user-db-num and
             buf_c-price-doc-forming-attr.plt-id           = buf_c-price-doc-forming.plt-id      and
             buf_c-price-doc-forming-attr.plt-db-num       = buf_c-price-doc-forming.plt-db-num  and
             buf_c-price-doc-forming-attr.pdf-id           = buf_c-price-doc-forming.pdf-id      and
             buf_c-price-doc-forming-attr.pdf-db           = buf_c-price-doc-forming.pdf-db
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, 'c-price-doc-forming-attr':U, (buffer buf_c-price-doc-forming-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-price-doc-forming-gds where
             buf_c-price-doc-forming-gds.chip-num         = buf_c-price-doc-forming.chip-num and
             buf_c-price-doc-forming-gds.corr-user-db-num = buf_c-price-doc-forming.corr-user-db-num and
             buf_c-price-doc-forming-gds.plt-id       = buf_c-price-doc-forming.plt-id      and
             buf_c-price-doc-forming-gds.plt-db-num   = buf_c-price-doc-forming.plt-db-num  and
             buf_c-price-doc-forming-gds.pdf-id       = buf_c-price-doc-forming.pdf-id      and
             buf_c-price-doc-forming-gds.pdf-db       = buf_c-price-doc-forming.pdf-db
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, 'c-price-doc-forming-gds':U, (buffer buf_c-price-doc-forming-gds:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-price-doc-forming-gds-qnty where
             buf_c-price-doc-forming-gds-qnty.chip-num         = buf_c-price-doc-forming.chip-num and
             buf_c-price-doc-forming-gds-qnty.corr-user-db-num = buf_c-price-doc-forming.corr-user-db-num and
             buf_c-price-doc-forming-gds-qnty.plt-id       = buf_c-price-doc-forming.plt-id      and
             buf_c-price-doc-forming-gds-qnty.plt-db-num   = buf_c-price-doc-forming.plt-db-num  and
             buf_c-price-doc-forming-gds-qnty.pdf-id       = buf_c-price-doc-forming.pdf-id      and
             buf_c-price-doc-forming-gds-qnty.pdf-db       = buf_c-price-doc-forming.pdf-db
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, 'c-price-doc-forming-gds-qnty':U, (buffer buf_c-price-doc-forming-gds-qnty:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-price-doc-forming-gds-sum where
             buf_c-price-doc-forming-gds-sum.chip-num         = buf_c-price-doc-forming.chip-num and
             buf_c-price-doc-forming-gds-sum.corr-user-db-num = buf_c-price-doc-forming.corr-user-db-num and
             buf_c-price-doc-forming-gds-sum.plt-id       = buf_c-price-doc-forming.plt-id      and
             buf_c-price-doc-forming-gds-sum.plt-db-num   = buf_c-price-doc-forming.plt-db-num  and
             buf_c-price-doc-forming-gds-sum.pdf-id       = buf_c-price-doc-forming.pdf-id      and
             buf_c-price-doc-forming-gds-sum.pdf-db       = buf_c-price-doc-forming.pdf-db
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, 'c-price-doc-forming-gds-sum':U, (buffer buf_c-price-doc-forming-gds-sum:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_c-price-doc-forming-gds-tnv where
             buf_c-price-doc-forming-gds-tnv.chip-num         = buf_c-price-doc-forming.chip-num and
             buf_c-price-doc-forming-gds-tnv.corr-user-db-num = buf_c-price-doc-forming.corr-user-db-num and
             buf_c-price-doc-forming-gds-tnv.plt-id       = buf_c-price-doc-forming.plt-id      and
             buf_c-price-doc-forming-gds-tnv.plt-db-num   = buf_c-price-doc-forming.plt-db-num  and
             buf_c-price-doc-forming-gds-tnv.pdf-id       = buf_c-price-doc-forming.pdf-id      and
             buf_c-price-doc-forming-gds-tnv.pdf-db       = buf_c-price-doc-forming.pdf-db
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump(  p-act-name, 'c-price-doc-forming-gds-tnv':U, (buffer buf_c-price-doc-forming-gds-tnv:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-rule:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  define input        parameter chk-go-news as   logical                no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-rule). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-rule). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-rule). endkey", vss-include-info4 )
  :
    define buffer buf_rule            for ub.rule.
    define buffer buf_rule-script     for ub.rule-script.
    define buffer buf_rule-i-script   for ub.rule-i-script.
    find buf_rule where rowid(buf_rule) = tbl-row.
    for each  buf_rule-script where buf_rule-script.rule_id = buf_rule.rule_id
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'rule-script':U, (buffer buf_rule-script:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_rule-i-script where
              buf_rule-i-script.root_rule_id = buf_rule-script.rule_id
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'rule-i-script':U, (buffer buf_rule-i-script:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-stop-list:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-stop-list). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-stop-list). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-stop-list). endkey", vss-include-info4 )
  :
    define buffer buf_stop-list            for ub.stop-list.
    define buffer buf_stop-list-line       for ub.stop-list-line.
    define buffer buf_c-stop-list          for ub.c-stop-list.
    define buffer buf_c-stop-list-line     for ub.c-stop-list-line.
    find buf_stop-list where rowid(buf_stop-list) = tbl-row.
    for each  buf_stop-list-line where
             buf_stop-list-line.classif-type = buf_stop-list.classif-type
         and buf_stop-list-line.stop-list-code = buf_stop-list.stop-list-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'stop-list-line':U, (buffer buf_stop-list-line:handle), dmp-ord, input-output rc-ord ).
    end.
    if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-stop-list-line") then
    do:
      for each buf_c-stop-list-line where
               buf_c-stop-list-line.classif-type = buf_stop-list.classif-type
           and buf_c-stop-list-line.stop-list-code = buf_stop-list.stop-list-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'c-stop-list-line':U, (buffer buf_c-stop-list-line:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
    if p-act-name <> 'send-tbl':U or g#db-num = 0 or not can-do(v-custom-except-list,"c-stop-list") then
    do:
      for each  buf_c-stop-list where
               buf_c-stop-list.classif-type = buf_stop-list.classif-type
           and buf_c-stop-list.stop-list-code = buf_stop-list.stop-list-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'c-stop-list':U, (buffer buf_c-stop-list:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-add-doc:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-add-doc). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-add-doc). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-add-doc). endkey", vss-include-info4 )
  :
    define buffer buf_add-doc  for ub.add-doc.
    define buffer buf_add-line for ub.add-line.
    define buffer buf_add-trn  for ub.add-trn.
    define buffer buf_add-trn-attr  for ub.add-trn-attr.
    define buffer buf_doc-line-attr for ub.doc-line-attr.
    find buf_add-doc where rowid(buf_add-doc) = tbl-row.
    for each buf_add-line where buf_add-line.doc-code = buf_add-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'add-line':U, (buffer buf_add-line:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_add-trn where buf_add-trn.doc-code = buf_add-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'add-trn':U, (buffer buf_add-trn:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_add-trn-attr where buf_add-trn-attr.doc-code = buf_add-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'add-trn-attr':U, (buffer buf_add-trn-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_doc-line-attr where buf_doc-line-attr.doc-code = buf_add-doc.doc-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'doc-line-attr':U, (buffer buf_doc-line-attr:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-esys-route:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-esys-route). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-esys-route). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-esys-route). endkey", vss-include-info4 )
  :
    define buffer buf_esys-route  for ub.esys-route.
    define buffer buf_esys-route-dump for ub.esys-route-dump.
    find buf_esys-route where rowid(buf_esys-route) = tbl-row.
    for each buf_esys-route-dump where
            buf_esys-route-dump.esrd-dump-ord = buf_esys-route.esr-dump-ord
        and buf_esys-route-dump.esrd-cr-db-num = buf_esys-route.esr-cr-db-num
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'esys-route-dump':U, (buffer buf_esys-route-dump:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-layout:
  define input        parameter p-act-name   as character no-undo .
  define input        parameter tbl-row      as   rowid                  no-undo.
  define input        parameter dmp-ord      like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord       like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-layout). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-layout). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-layout). endkey", vss-include-info4 )
  :
    define buffer buf_layout  for ub.layout.
    define buffer buf_layout-elem-rule for ub.layout-elem-rule.
    define buffer buf_rule-call-param for ub.rule-call-param.
    define buffer buf_rule-by-call for ub.rule-by-call.
    find buf_layout where rowid(buf_layout) = tbl-row.
    for each buf_layout-elem-rule where buf_layout-elem-rule.layout-id = buf_layout.layout-id
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'layout-elem-rule':U, (buffer buf_layout-elem-rule:handle), dmp-ord, input-output rc-ord ).
      for each buf_rule-call-param where buf_rule-call-param.call_id = buf_layout-elem-rule.uniq-key-rec:
        run cre-route-dump( p-act-name, 'rule-call-param':U, (buffer buf_rule-call-param:handle), dmp-ord, input-output rc-ord ).
      end.
      for each buf_rule-by-call where buf_rule-by-call.call_id = buf_layout-elem-rule.uniq-key-rec:
        run cre-route-dump( p-act-name, 'rule-by-call':U, (buffer buf_rule-by-call:handle), dmp-ord, input-output rc-ord ).
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE cre-dump-utd:
  define input        parameter p-act-name  as   character no-undo .
  define input        parameter tbl-row     as   rowid                  no-undo.
  define input        parameter dmp-ord     like ub.route-dump.dump-ord no-undo.
  define input-output parameter rc-ord      like ub.route-dump.rec-ord  no-undo.
  do transaction
  on error  undo, return error substitute( "&1 (cre-dump-utd). &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-dump-utd). stop", vss-include-info4 )
  on endkey undo, return error substitute( "&1 (cre-dump-utd). endkey", vss-include-info4 )
  :
    define buffer buf_utd for ub.utd.
    define buffer buf_utd-attr for ub.utd-attr.
    define buffer buf_utd-lines for ub.utd-lines.
    define buffer buf_utd-lines-attr for ub.utd-lines-attr.
    define buffer buf_utd-marking-lines for ub.utd-marking-lines.
    define buffer buf_utd-marking-lines-attr for ub.utd-marking-lines-attr.
    define buffer buf_utd-err for ub.utd-err.
    define buffer buf_utd-err-attr for ub.utd-err-attr.
    define buffer buf_marking for ub.marking.
    define buffer buf_marking-attr for ub.marking-attr.
    find buf_utd where rowid(buf_utd) = tbl-row.
    for each buf_utd-attr where buf_utd-attr.db-num = buf_utd.db-num and buf_utd-attr.doc-id = buf_utd.doc-id
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'utd-attr':U, (buffer buf_utd-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_utd-lines where buf_utd-lines.db-num = buf_utd.db-num and buf_utd-lines.doc-id = buf_utd.doc-id
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'utd-lines':U, (buffer buf_utd-lines:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_utd-lines-attr where buf_utd-lines-attr.db-num = buf_utd.db-num and buf_utd-lines-attr.doc-id = buf_utd.doc-id
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'utd-lines-attr':U, (buffer buf_utd-lines-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_utd-marking-lines where buf_utd-marking-lines.db-num = buf_utd.db-num and buf_utd-marking-lines.doc-id = buf_utd.doc-id
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'utd-marking-lines':U, (buffer buf_utd-marking-lines:handle), dmp-ord, input-output rc-ord ).
      for first buf_marking where buf_marking.mark = buf_utd-marking-lines.mark
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
        run cre-route-dump( p-act-name, 'marking':U, (buffer buf_marking:handle), dmp-ord, input-output rc-ord ).
        for each buf_marking-attr where buf_marking-attr.mark = buf_marking.mark
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
          run cre-route-dump( p-act-name, 'marking-attr':U, (buffer buf_marking-attr:handle), dmp-ord, input-output rc-ord ).
        end.
      end.
    end.
    for each buf_utd-marking-lines-attr where buf_utd-marking-lines-attr.db-num = buf_utd.db-num and buf_utd-marking-lines-attr.doc-id = buf_utd.doc-id
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'utd-marking-lines-attr':U, (buffer buf_utd-marking-lines-attr:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_utd-err where buf_utd-err.db-num = buf_utd.db-num and buf_utd-err.doc-id = buf_utd.doc-id
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'utd-err':U, (buffer buf_utd-err:handle), dmp-ord, input-output rc-ord ).
    end.
    for each buf_utd-err-attr where buf_utd-err-attr.db-num = buf_utd.db-num and buf_utd-err-attr.doc-id = buf_utd.doc-id
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message ( error-status :num-messages ) ) :
      run cre-route-dump( p-act-name, 'utd-err-attr':U, (buffer buf_utd-err-attr:handle), dmp-ord, input-output rc-ord ).
    end.
  end.
END PROCEDURE.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
block_cre-route:
do
on error  undo block_cre-route, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
on stop   undo block_cre-route, return error substitute( "&1. stop", vss-workfile )
on endkey undo block_cre-route, return error substitute( "&1. endkey", vss-workfile )
:
  define variable v-tbl-row      as rowid               no-undo.
  define variable v-dmp-ord      like ub.route.dump-ord no-undo .
  define variable v-rc-ord       as integer             no-undo .
  define variable v-ind          as integer             no-undo .
  define variable v-loc-key-rec  as character           no-undo .
  define variable v-send-checks  as logical             no-undo .
  define variable v-param-checks as logical             no-undo .
  define variable v-bush-rec     as logical             no-undo .
  define variable v-cre-time     as integer             no-undo .
  define variable v-cre-date     as date                no-undo .
  define variable v-cre-user     as character           no-undo .
  define variable v-act-name     as character           no-undo.
  define variable v-esr-act-name as character           no-undo.
  define variable v-send-list    as character no-undo .
  define variable v-rt-count     as integer   no-undo .
  define buffer buf_sys-ctrl for ub.sys-ctrl .
  define buffer buf_db       for ub.db .
  if p-act-name = 'send-tbl':U
  or p-act-name = 'send-cmd':U
  then do:
    assign
        v-act-name = p-act-name
    .
  end.
  else do:
    if num-entries( p-act-name ) < 2
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Передано неверное действие OXML"   skip
        "Действие"         p-act-name        skip
        "Таблица"          p-tbl-name        skip
        "Список рассылки"  p-send-list       skip
        view-as alert-box error .
      undo block_cre-route, return error return-value .
    end.
    else do:
        assign
            v-act-name      = entry( 1, p-act-name )
            v-esr-act-name  = entry( 2, p-act-name )
        .
        if v-esr-act-name <> 'update':U
        and v-esr-act-name <> 'delete':U
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка задания входных параметров" skip
                "Передано неверное действие OXML"   skip
                "Действие"         p-act-name        skip
                "Таблица"          p-tbl-name        skip
                "Список рассылки"  p-send-list       skip
                view-as alert-box error .
            undo block_cre-route, return error return-value .
        end.
    end.
  end.
  if v-act-name = 'send-tbl':U
    or v-act-name = 'send-tbl-oxml':U
  then do:
    if not p-tbl-handle:available then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Передана ссылка на не доступный буффер" skip
        "Действие"         p-act-name        skip
        "Таблица"          p-tbl-name        skip
        "Список рассылки"  p-send-list       skip
        view-as alert-box error .
      undo block_cre-route, return error return-value .
    end.
    else do:
      assign
        v-tbl-row       = p-tbl-handle :rowid
      .
    end.
  end.
  if v-act-name <> 'send-tbl':U
    and v-act-name <> 'send-cmd':U
    and v-act-name <> 'send-tbl-oxml':U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестное значение параметра Действие" skip
      "Действие"         p-act-name        skip
      "Таблица"          p-tbl-name        skip
      "Код записи"       string(v-tbl-row) skip
      "Список рассылки"  p-send-list       skip
      view-as alert-box error .
    undo block_cre-route, return error return-value .
  end.
  if p-tbl-name = ?
  or p-tbl-name = "":U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не задан параметр таблица" skip
      "Действие"         p-act-name        skip
      "Таблица"          p-tbl-name        skip
      "Код записи"       string(v-tbl-row) skip
      "Список рассылки"  p-send-list       skip
      view-as alert-box error .
    undo block_cre-route, return error return-value .
  end.
  if trim( p-send-list ) = "":U
    or p-send-list = ?
  then do:
    if v-act-name = 'send-tbl-oxml':U
      or v-act-name = 'send-cmd-oxml':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задан список рассылки" skip
        "Действие"         p-act-name        skip
        "Таблица"          p-tbl-name        skip
        "Код записи"       string(v-tbl-row) skip
        "Список рассылки"  p-send-list       skip
        view-as alert-box error .
      undo block_cre-route, return error return-value .
    end.
    else do:
      assign
        v-send-list = "":U
      .
      find first buf_sys-ctrl no-lock .
      if buf_sys-ctrl.db-num = 0 then do:
        for each buf_db no-lock
          where buf_db.db-num > 0
            and buf_db.db-num <> g#news-source-db
      on error undo block_cre-route, return error
        :
          assign
            v-send-list = v-send-list + chr(1) + string( buf_db.db-num )
          .
        end.
        assign
          v-send-list = left-trim( v-send-list, chr(1) )
        .
      end.
      else do:
        assign
          v-send-list = "0":U
        .
      end.
    end.
  end.
  else do:
    assign
      v-send-list = p-send-list
    .
  end.
  if v-act-name = 'send-tbl':U
    or v-act-name = 'send-cmd':U
  then do:
    assign
      v-send-checks = false
    .
    if g#db-num = 0 then do:
      do v-ind = 1 to num-entries( v-send-list, chr(1) )
      on error  undo block_cre-route, return error substitute( "&1. (send-checks) &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
      on stop   undo block_cre-route, return error substitute( "&1. (send-checks) stop", vss-workfile )
      on endkey undo block_cre-route, return error substitute( "&1. (send-checks) endkey", vss-workfile )
      :
        find buf_db no-lock
          where buf_db.db-num = integer( entry( v-ind, v-send-list, chr(1) ) )
        .
        if buf_db.send-check = true then do:
          assign
            v-send-checks = buf_db.send-check
          .
        end.
      end.
    end.
    else do:
      find buf_db no-lock
        where buf_db.db-num = g#db-num
      .
      assign
        v-send-checks = buf_db.send-check
      .
    end.
  end.
  else do:
    assign
      v-send-checks = true
    .
  end.
  assign
    v-dmp-ord = next-value( s-news-dord, ub )
  .
  case p-act-name :
    when 'send-tbl':U
    or when substitute( "&1,&2", 'send-tbl-oxml':U, 'update':U )
    then do:
      assign
        v-rc-ord  = -1
      .
      RUN gen-key-rec in this-procedure
        ( input p-tbl-name
         ,input p-tbl-handle
         ,output v-loc-key-rec
        ) no-error.
      if error-status :error then do:
        undo  block_cre-route, return error substitute( "&1. Ошибка при генерации уникального ключа. &2. Имя таблицы &3. Код таблицы &4.", vss-workfile, return-value, p-tbl-name, string(v-tbl-row) ).
      end.
      if v-loc-key-rec = ?
        or v-loc-key-rec = ""
      then do:
        undo  block_cre-route, return error substitute( "&1. Уникальный ключ имеет неопределенное значение. Имя таблицы &2. Код таблицы &3.", vss-workfile, p-tbl-name, string(v-tbl-row) ).
      end.
      case p-tbl-name:
        when 'c-trn-doc':U
        or when 'add-doc':U
        or when 'price-doc':U
        or when 'c-price-doc':U
        or when 'contract':U
        or when 'contract-specif':U
        or when 'c-contract':U
        or when 'fbr-doc':U
        or when 'fbr-pln':U
        or when 'recipe':U
        or when 'c-fbr-doc':U
        or when 'c-recipe':U
        or when 'c-fbr-pln':U
        or when 'rvs-doc':U
        or when 'c-rvs-doc':U
        or when 'icnt-doc':U
        or when 'ord-doc':U
        or when 'ord-doc-rcv':U
        or when 'ord-cons':U
        or when 'goods':U
        or when 'shift-obj':U
        or when 'c-shift-obj':U
        or when 'fin-ob':U
        or when 'c-fin-ob':U
        or when 'fin-ob-before':U
        or when 'fin-doc':U
        or when 'c-fin-doc':U
        or when 'dis-rule':U
        or when 'dis-time-rule':U
        or when 'abc-analysis':U
        or when 'abcxyz-analysis':U
        or when 'xyz-analysis':U
        or when 'rang-abc-def':U
        or when 'rang-xyz-def':U
        or when 'doc-abc-def':U
        or when 'doc-xyz-def':U
        or when 'fin-statement':U
        or when 'c-fin-statement':U
        or when 'schet-fact-doc':U
        or when 'c-schet-fact-doc':U
        or when 'factur-connect':U
        or when 'global-state':U
        or when 'sum-group':U
        or when 'qnty-group':U
        or when 'turnover-group':U
        or when 'buyer-group':U
        or when 'buyer-in-buyer-group':U
        or when 'grp-obj-price':U
        or when 'turnover-buyer-main':U
        or when 'price-list-type':U
        or when 'price-doc-forming':U
        or when 'c-price-list-type':U
        or when 'c-price-doc-forming':U
        or when 'stop-list':U
        or when 'esys-route':U
        or when 'layout':U
        or when 'utd':U
        then do:
          assign
            v-bush-rec     = true
            v-param-checks = false
          .
        end.
        when 'trn-doc':U
        or when 'wth-doc':U
        or when 'c-wth-doc':U
        or when 'inkas':U
        or when 'c-inkas':U
        or when 'c-chk-doc':U
        then do:
          assign
            v-bush-rec     = true
            v-param-checks = true
          .
        end.
        otherwise do:
          assign
            v-bush-rec     = false
            v-param-checks = false
          .
        end.
      end case.
      run cre-route-dump in this-procedure
        ( input v-act-name
         ,input p-tbl-name
         ,input p-tbl-handle
         ,input v-dmp-ord
         ,input-output v-rc-ord
        ).
      if v-bush-rec = true then do:
        if v-param-checks = true then do:
          run value("cre-dump-":U + p-tbl-name) in this-procedure
            ( input v-act-name
             ,input v-tbl-row
             ,input v-dmp-ord
             ,input-output v-rc-ord
             ,input v-send-checks
            ).
        end.
        else do:
          run value("cre-dump-":U + p-tbl-name) in this-procedure
            ( input v-act-name
             ,input v-tbl-row
             ,input v-dmp-ord
             ,input-output v-rc-ord
            ).
        end.
      end.
    end.
    when substitute( "&1,&2", 'send-tbl-oxml':U, 'delete':U )
    then do:
      assign
        v-rc-ord  = -1
      .
      RUN gen-key-rec in this-procedure
        ( input p-tbl-name
         ,input p-tbl-handle
         ,output v-loc-key-rec
        ) no-error.
      if error-status :error then do:
        undo  block_cre-route, return error substitute( "&1. Ошибка при генерации уникального ключа. &2. Имя таблицы &3. Код таблицы &4.", vss-workfile, return-value, p-tbl-name, string(v-tbl-row) ).
      end.
      if v-loc-key-rec = ?
        or v-loc-key-rec = ""
      then do:
        undo  block_cre-route, return error substitute( "&1. Уникальный ключ имеет неопределенное значение. Имя таблицы &2. Код таблицы &3.", vss-workfile, p-tbl-name, string(v-tbl-row) ).
      end.
      run cre-route-dump in this-procedure
         ( input v-act-name
          ,input p-tbl-name
          ,input p-tbl-handle
          ,input v-dmp-ord
          ,input-output v-rc-ord
         ).
    end.
    when 'send-cmd':U
    then do:
      assign
        v-rc-ord  = 0
        v-loc-key-rec = "":U
      .
    end.
  end case.
  run cur-time in this-procedure
    ( output v-cre-date
     ,output v-cre-time
    ) no-error.
  if error-status :error then do:
    undo block_cre-route, return error substitute( "&1. Ошибка при определении текущего времени", vss-workfile ) .
  end.
  if g#news then do:
    assign
      v-cre-user = substitute( "News (&1)":U, g#userid )
    .
    if g#news-source-db > 0 then do:
      assign
        v-cre-user = substitute( "&1 from BD &2":U, v-cre-user, g#news-source-db )
      .
    end.
  end.
  else do:
    assign
      v-cre-user = g#userid
    .
  end.
  if v-act-name = 'send-tbl':U
    or v-act-name = 'send-cmd':U
  then do:
    assign
      v-rt-count = 0
    .
    do v-ind = 1 to num-entries( v-send-list, chr(1) )
    on error  undo block_cre-route, return error substitute( "&1. (cr-rt) &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on stop   undo block_cre-route, return error substitute( "&1. (cr-rt) stop", vss-workfile )
    on endkey undo block_cre-route, return error substitute( "&1. (cr-rt) endkey", vss-workfile )
    :
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf8_db    for ub.db .
define buffer buf8_route for ub.route .
define variable v-msg#8    as character no-undo .
define variable v-lock#8   as logical   no-undo .
define variable v-ok#8     as logical   no-undo .
find first buf8_db no-lock
  where buf8_db.db-num = integer(entry(v-ind,v-send-list,chr(1)))
  no-error
.
if not available buf8_db then do:
  message
    vss-include-info8 skip
    vss-workfile vss-revision vss-description skip
    substitute( "Попытка создать маршрутизацию на несуществующую БД &1", integer(entry(v-ind,v-send-list,chr(1))) ) skip
    return-value skip
    error-status :get-message ( error-status :num-messages )
    view-as alert-box error
  .
end.
if "ub":U <> "ub":U
   or ( trim( buf8_db.db-key ) <> "":U
        and buf8_db.db-key <> ?
      )
then do:
  create buf8_route .
  assign
    buf8_route.last-pack    = -1
    buf8_route.name-rec     = p-tbl-name
    buf8_route.db-num       = integer(entry(v-ind,v-send-list,chr(1)))
    buf8_route.uniq-key-rec = v-loc-key-rec
    buf8_route.num-dump     = v-rc-ord
    buf8_route.tbl-ord      = dynamic-next-value( "s-news-ord":U, "ub":U )
    .
    assign
      buf8_route.dump-ord = v-dmp-ord
    .
    assign
      buf8_route.CreDate      = v-cre-date
    .
    assign
      buf8_route.CreTimeInt   = v-cre-time
      buf8_route.CreTime      = string(v-cre-time,"HH:MM:SS":U)
    .
    assign
      buf8_route.CreUserName  = v-cre-user
    .
    assign
      v-rt-count = v-rt-count + 1
    .
end.
else do:
define variable vss-include-info9 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_lock-route in g#lib-nws
  ( input  'check'
  , input  integer(entry(v-ind,v-send-list,chr(1)))
  , input  0
  , input  ''
  , output v-msg#8
  , output v-lock#8
  , output v-ok#8
  ) no-error .
  if error-status :error
    or v-lock#8 = true
    or v-ok#8   = false
  then do:
    return error substitute( "&1. Маршрутизация записи &2.&3Ключ записи: &4&3&3"
                             ,vss-include-info8
                             ,p-tbl-name
                             ,chr(10)
                             ,v-loc-key-rec
                           )
                + substitute( "&1&2&2&3&2&2&4"
                              ,v-msg#8
                              ,chr(10)
                              ,return-value
                              ,error-status :get-message( error-status :num-messages )
                            ) .
  end.
end.
    end.
    if v-rt-count = 0 then do:
      do v-ind = 1 to num-entries( v-send-list, chr(1) )
      on error  undo block_cre-route, return error substitute( "&1. (check-db-list) &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
      on stop   undo block_cre-route, return error substitute( "&1. (check-db-list) stop", vss-workfile )
      on endkey undo block_cre-route, return error substitute( "&1. (check-db-list) endkey", vss-workfile )
      :
        find buf_db no-lock
          where buf_db.db-num = integer( entry( v-ind, v-send-list, chr(1) ) )
        .
        if buf_db.db-key <> ?
          and buf_db.db-key <> "":U
        then do:
          undo block_cre-route, return error substitute( "&1. Есть список БД для отправки, но ни одна запись не маршрутизировалась!!!", vss-workfile ) .
        end.
      end.
      undo block_cre-route, return .
    end.
  end.
  if v-act-name = 'send-tbl-oxml':U then do:
    do v-ind = 1 to num-entries( v-send-list, chr(1) )
    on error  undo block_cre-route, return error substitute( "&1. (cr-rto) &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on stop   undo block_cre-route, return error substitute( "&1. (cr-rto) stop", vss-workfile )
    on endkey undo block_cre-route, return error substitute( "&1. (cr-rto) endkey", vss-workfile )
    :
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-msg#10         as character no-undo .
define variable v-lock#10        as logical   no-undo .
define variable v-ok#10          as logical   no-undo .
define variable v-cur-db-num#10  as integer      no-undo.
define buffer buf10_ext-system for ub.ext-system .
find first buf10_ext-system no-lock
  where buf10_ext-system.esys-id = integer(entry(v-ind,v-send-list,chr(1)))
    and buf10_ext-system.db-num = g#db-num
  no-error
.
if not available buf10_ext-system then do:
  message
    vss-include-info10 skip
    vss-workfile vss-revision vss-description skip
    substitute( "Попытка создать маршрутизацию на несуществующую внешнюю систему &1 для БД &2", integer(entry(v-ind,v-send-list,chr(1))), g#db-num ) skip
    return-value skip
    error-status :get-message ( error-status :num-messages )
    view-as alert-box error
  .
end.
if g#db-num <> buf10_ext-system.esys-db-num-exp and buf10_ext-system.esys-db-num-exp <> 0 then do:
  message
    vss-include-info10 skip
    vss-workfile vss-revision vss-description skip
    substitute( "Попытка создать маршрутизацию на ВС &1 для БД &2,&3" +
                "в БД &4,&3" +
                "как БД экспорта указана БД &5"
                , integer(entry(v-ind,v-send-list,chr(1)))
                , g#db-num
                , chr(10)
                , g#db-num
                , buf10_ext-system.esys-db-num-exp
                ) skip
    return-value skip
    error-status :get-message ( error-status :num-messages )
    view-as alert-box error
  .
end.
  create ub.esys-route .
  assign
    ub.esys-route.esr-name-rec     = p-tbl-name
      ub.esys-route.esr-tbl-ord = next-value( s-news-ord, ub )
    ub.esys-route.esr-last-pack    = -1
    ub.esys-route.esys-id          = integer(entry(v-ind,v-send-list,chr(1)))
    ub.esys-route.db-num           = g#db-num
    ub.esys-route.esr-status       = 0
    ub.esys-route.esr-cr-db-num    = g#db-num
    ub.esys-route.esr-dump-ord     = v-dmp-ord
    ub.esys-route.esr-uniq-key-rec = v-loc-key-rec
    ub.esys-route.uniq-gate-rec    = ''
    ub.esys-route.esr-num-dump     = v-rc-ord
    ub.esys-route.esr-action       = v-esr-act-name
    ub.esys-route.esr-oper         = ''
    .
    assign
      ub.esys-route.esr-CreDate      = v-cre-date
    .
    assign
      ub.esys-route.esr-CreTimeInt   = v-cre-time
      ub.esys-route.esr-CreTime      = string(v-cre-time,"HH:MM:SS":U)
    .
    assign
      ub.esys-route.esr-CreUserName  = v-cre-user
    .
    end.
  end.
end.
