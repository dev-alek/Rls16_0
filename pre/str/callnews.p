block-level on error undo, throw.
using ibs.th.adm.upd.*.
define input parameter p-tbl-name   like ub.route.name-rec no-undo .
define input parameter p-tbl-handle as   handle            no-undo .
define variable vss-revision    as character no-undo initial "$Revision: 3c72df46e096, 3170, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: 2022/12/27 12:54:23 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: callnews.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/callnews.p $":U .
define variable vss-description as character no-undo initial "Маршрутизация новостей":U .
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
      p-vss-parameters = substitute('&1|&2',p-tbl-name,p-tbl-handle)
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
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
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
:
  define variable v-tbl-row as rowid no-undo .
  define variable v-routing as character no-undo .
  define variable v-obj-type as character no-undo .
  define variable v-obj-code as integer no-undo .
  define variable v-host-code as integer no-undo .
  define variable v-is-news as logical no-undo .
  define variable v-found as logical no-undo .
  define variable v-corr-user-name as character no-undo .
  define variable v-is-c-route as logical no-undo .
  define variable v-global-only-0 as logical no-undo .
  define variable v-corr-user-db-num as integer no-undo .
  define variable v-tbl-name as character no-undo .
  define variable v-tbl-handle as handle no-undo .
  define variable v-lob-send-non-data as logical no-undo .
  define variable v-lob-type as character no-undo .
  define variable v-full-tbl-name as character no-undo .
  define variable v-routing-type as character no-undo .
  define variable v-on-gbl    as logical      no-undo.
  define variable conf-par as character no-undo.
  define variable mode-erprn as logical no-undo.
  define variable par-type as character no-undo.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-erpRN'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  NO
  ,output conf-par
  ,output par-type
  ) no-error .
    IF not error-status:error and conf-par = "yes":U then mode-erprn = yes.
    else mode-erprn = no.
  if mode-erprn
  then
    assign
      v-custom-except-list = v-custom-except-list-erprn
      v-custom-0-rdb-not-news = v-custom-0-rdb-not-news-erprn
    .
  define buffer buf_db                          for ub.db.
  define buffer buf_clients                     for ub.clients.
  define buffer buf_sysconf                     for ub.sysconf.
  define buffer buf_trn-doc                     for ub.trn-doc.
  define buffer buf_price-doc                   for ub.price-doc  .
  define buffer buf_ord-doc                     for ub.ord-doc.
  define buffer buf_c-ord-doc                   for ub.c-ord-doc.
  define buffer buf_ord-doc-rcv                 for ub.ord-doc-rcv.
  define buffer buf_ord-cons                    for ub.ord-cons.
  define buffer buf_c-trn-doc                   for ub.c-trn-doc.
  define buffer buf_doc-attr                    for ub.doc-attr.
  define buffer buf_staff                       for ub.staff.
  define buffer buf_c-staff                     for ub.c-staff.
  define buffer buf_schet-fact-doc              for ub.schet-fact-doc.
  define buffer buf_c-schet-fact-doc            for ub.c-schet-fact-doc.
  define buffer buf_wth-doc                     for ub.wth-doc.
  define buffer buf_wth-doc-attr                for ub.wth-doc-attr.
  define buffer buf_wth-parts                   for ub.wth-parts.
  define buffer buf_blob-data                   for ub.blob-data.
  define buffer buf_clob-data                   for ub.clob-data.
  define buffer buf_blob-bind                   for ub.blob-bind.
  define buffer buf_clob-bind                   for ub.clob-bind.
  define buffer buf_price-all                   for ub.price-all  .
  define buffer buf_price-doc-forming           for ub.price-doc-forming  .
  define buffer buf_gds-grp-obj-attr            for ub.gds-grp-obj-attr .
  define buffer buf_assortment-matrix           for ub.assortment-matrix  .
  define variable list-remote-db-wsd as character no-undo.
  define variable list-remote-db     as character no-undo.
  define variable list-remote-stock  as character no-undo.
  define variable  list-db-for-send  as character no-undo.
  define buffer buf_hist-nws-option for ub.hist-nws-option.
  if not p-tbl-handle:available then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Передана ссылка на не доступный буффер" skip
      "Программа вызвана из" program-name(2)  skip
      "" program-name(3)  skip
      "" program-name(4)  skip
      "Неизвестное имя таблицы" skip
      "Имя таблицы" p-tbl-name  skip
      view-as alert-box error .
    undo, return error .
  end.
  else do:
    assign
      v-tbl-row = p-tbl-handle:rowid
    .
  end.
  if p-tbl-name = 'blob-data':U
  or p-tbl-name = 'clob-data':U
  or p-tbl-name = 'blob-bind':U
  or p-tbl-name = 'clob-bind':U
  then do:
    case p-tbl-name:
      when 'blob-data':U then do:
        v-routing-type = "lob".
        if p-tbl-handle::resource-type = 'data':U then do:
          for each  buf_blob-bind no-lock where
                    buf_blob-bind.db-num = p-tbl-handle::db-num
                and buf_blob-bind.int64-id = p-tbl-handle::int64-id
          on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
          on stop   undo, return error substitute( "&1. stop", vss-workfile )
          on endkey undo, return error substitute( "&1. endkey", vss-workfile )
          :
            assign
            v-tbl-row = ?
            v-tbl-name = '':U
            .
            run gen-row-keyr in this-procedure ( input buf_blob-bind.uniq-key-rec
                                                ,input ?
                                                ,input "ub"
                                                ,input ?
                                                ,input SHARE-LOCK
                                                ,output v-tbl-row
                                                ,output v-tbl-name ) no-error.
            if v-tbl-row <> ? then do:
              leave.
            end.
          end.
        end.
        if p-tbl-handle::resource-type = 'gate':U then do:
          if g#news then do:
            undo, return error substitute('Попытка отсылки lob через СПН при включенном g#news&1&2', buf_blob-bind.uniq-key-rec).
          end.
          assign
          v-lob-send-non-data = yes
          v-tbl-name = p-tbl-name
          v-tbl-handle = p-tbl-handle
          .
        end.
      end.
      when 'clob-data':U then do:
        assign
        v-routing-type = "lob"
        .
        if p-tbl-handle::resource-type = 'data':U then do:
          for each  buf_clob-bind no-lock where
                    buf_clob-bind.db-num = p-tbl-handle::db-num
                and buf_clob-bind.int64-id = p-tbl-handle::int64-id
          on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
          on stop   undo, return error substitute( "&1. stop", vss-workfile )
          on endkey undo, return error substitute( "&1. endkey", vss-workfile )
          :
            assign
            v-tbl-row = ?
            v-tbl-name = '':U
            .
            run gen-row-keyr in this-procedure ( input buf_clob-bind.uniq-key-rec
                                                ,input ?
                                                ,input "ub"
                                                ,input ?
                                                ,input SHARE-LOCK
                                                ,output v-tbl-row
                                                ,output v-tbl-name ) no-error.
            if v-tbl-row <> ? then do:
              leave.
            end.
          end.
        end.
        if p-tbl-handle::resource-type = 'report':U
        or p-tbl-handle::resource-type = 'report-xml':U
        or p-tbl-handle::resource-type = 'list':U
        or p-tbl-handle::resource-type = 'list-macro':U
        or p-tbl-handle::resource-type = 'ref':U
        or p-tbl-handle::resource-type = 'egais-wb':U
        or p-tbl-handle::resource-type = 'egais-ref-b':U
        or p-tbl-handle::resource-type = 'egais-wb-act':U
        or p-tbl-handle::resource-type = 'egais-ticket':U
        or p-tbl-handle::resource-type = 'egais-wb-ticket':U
                or p-tbl-handle::resource-type = 'egais-ab':U
        or p-tbl-handle::resource-type = 'egais-awo':U
        or p-tbl-handle::resource-type = 'egais-ab_shop':U
        or p-tbl-handle::resource-type = 'egais-awo_shop':U
        or p-tbl-handle::resource-type = 'egais-tts':U
        or p-tbl-handle::resource-type = 'egais-tfs':U
        or p-tbl-handle::resource-type = 'egais-qb':U
        then do:
          assign
          v-lob-type = p-tbl-handle::resource-type
          v-lob-send-non-data = yes
          v-tbl-name = p-tbl-name
          v-tbl-handle = p-tbl-handle
          .
        end.
        if p-tbl-handle::resource-type = 'gate':U then do:
         if g#news then do:
            undo, return error substitute('Попытка отсылки lob через СПН при включенном g#news&1&2', buf_clob-bind.uniq-key-rec).
          end.
          assign
          v-lob-send-non-data = yes
          v-tbl-name = p-tbl-name
          v-tbl-handle = p-tbl-handle
          .
        end.
      end.
      when 'blob-bind':U then do:
        if p-tbl-handle::resource-type = 'data':U then do:
          assign
          v-tbl-row = ?
          v-tbl-name = '':U
          .
          run gen-row-keyr in this-procedure ( input p-tbl-handle::uniq-key-rec
                                              ,input ?
                                              ,input "ub"
                                              ,input ?
                                              ,input SHARE-LOCK
                                              ,output v-tbl-row
                                              ,output v-tbl-name ) no-error.
        end.
        else do:
          if g#news then do:
            undo, return error substitute('Попытка отсылки lob через СПН при включенном g#news&1&2', buf_blob-bind.uniq-key-rec).
          end.
          assign
          v-lob-send-non-data = yes
          v-tbl-name = p-tbl-name
          v-tbl-handle = p-tbl-handle
          .
        end.
      end.
      when 'clob-bind':U then do:
        if p-tbl-handle::resource-type = 'data':U then do:
          assign
          v-tbl-row = ?
          v-tbl-name = '':U
          .
          run gen-row-keyr in this-procedure ( input p-tbl-handle::uniq-key-rec
                                              ,input ?
                                              ,input "ub"
                                              ,input ?
                                              ,input SHARE-LOCK
                                              ,output v-tbl-row
                                              ,output v-tbl-name ) no-error.
        end.
        else do:
          if p-tbl-handle::resource-type = 'report':U
          or p-tbl-handle::resource-type = 'report-xml':U
          or p-tbl-handle::resource-type = 'list':U
          or p-tbl-handle::resource-type = 'list-macro':U
          or p-tbl-handle::resource-type = 'ref':U
          or p-tbl-handle::resource-type = 'egais-wb':U
          or p-tbl-handle::resource-type = 'egais-ref-b':U
          or p-tbl-handle::resource-type = 'egais-wb-act':U
          or p-tbl-handle::resource-type = 'egais-ticket':U
          or p-tbl-handle::resource-type = 'egais-wb-ticket':U
          or p-tbl-handle::resource-type = 'egais-ab':U
          or p-tbl-handle::resource-type = 'egais-awo':U
          or p-tbl-handle::resource-type = 'egais-ab_shop':U
          or p-tbl-handle::resource-type = 'egais-awo_shop':U
          or p-tbl-handle::resource-type = 'egais-tts':U
          or p-tbl-handle::resource-type = 'egais-tfs':U
          or p-tbl-handle::resource-type = 'egais-qb':U
          then do:
            assign
            v-lob-send-non-data = yes
            v-tbl-name = p-tbl-name
            v-tbl-handle = p-tbl-handle
            .
          end.
          else do:
            if g#news then do:
              undo, return error substitute('Попытка отсылки lob через СПН при включенном g#news&1&2', buf_clob-bind.uniq-key-rec).
            end.
            assign
            v-lob-send-non-data = yes
            v-tbl-name = p-tbl-name
            v-tbl-handle = p-tbl-handle
            .
          end.
        end.
      end.
    end case.
    if not v-lob-send-non-data then do:
      if v-tbl-name = '':U
      or v-tbl-row = ? then do:
        undo, return error substitute("Не удалось определить связь с записью-владельцем для маршрутизации LOB:&1&2"
                                      ,chr(10)
                                      , p-tbl-handle::db-num
                                      , p-tbl-handle::int64-id).
      end.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, "ub", v-tbl-name )
      .
      create buffer v-tbl-handle for table v-full-tbl-name .
      v-tbl-handle:find-by-rowid( v-tbl-row, share-lock )  .
    end.
  end.
  else do:
    assign
    v-tbl-name = p-tbl-name
    v-tbl-handle = p-tbl-handle
    .
  end.
  if v-tbl-name begins "c-":U then do:
    define variable v-send as integer no-undo .
    define variable v-tbl-name-prim as character no-undo .
    define variable v-has-subject as logical no-undo .
    define variable v-is-c as logical no-undo .
    assign
    v-corr-user-db-num = v-tbl-handle:buffer-field("corr-user-db-num"):buffer-value
    v-is-c = yes
    .
    if (g#db-num > 0
    and v-corr-user-db-num  <> g#db-num )
    or
    (g#news
     and  g#db-num = 0
     and v-corr-user-db-num <> g#news-source-db
     )
    then do:
      return '':U.
    end.
    assign
    v-has-subject = valid-handle(v-tbl-handle:buffer-field("subject")) no-error.
    if v-has-subject then do:
      v-tbl-name-prim = v-tbl-handle:buffer-field("subject"):buffer-value.
    end.
    else do:
      v-tbl-name-prim = substring( v-tbl-name, 3 ).
    end.
    if (
       (not g#news and g#db-num = 0)
        OR (g#news
            and g#db-num = 0
            and v-corr-user-db-num  = g#news-source-db
            )
        )
    then do:
      v-send = integer('0':U).
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  v-tbl-name-prim
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  0
  ,input  0
  ,input  'hist-to-nws'
  ,output v-send
  ) no-error .
      if v-send < 0 then return '':U.
    end.
    if v-has-subject
    and v-tbl-name-prim <> ''
    and lookup("c-" + v-tbl-name-prim, v-custom-list) = 0
    then do:
      v-tbl-name = "c-" + v-tbl-name-prim.
    end.
  end.
  assign
    list-remote-db-wsd = ""
    list-remote-db     = ""
    list-remote-stock  = ""
    list-db-for-send   = ""
    .
  if g#db-num = 0 then do:
    if v-is-c then do:
      for each buf_hist-nws-option no-lock
        where buf_hist-nws-option.db-num > 0
          and buf_hist-nws-option.table-name = v-tbl-name-prim
          and buf_hist-nws-option.get-hist-from-nws >= 0
          and buf_hist-nws-option.charkey_one = '':U
          and buf_hist-nws-option.key#_one = 0
      on error  undo,  return  error :
        assign list-remote-db-wsd = list-remote-db-wsd + chr(1) + string(buf_hist-nws-option.db-num).
        if buf_hist-nws-option.db-num <> g#news-source-db then
        do on error undo, return error return-value :
          assign list-remote-db = list-remote-db + chr(1) + string(buf_hist-nws-option.db-num).
        end.
      end.
    end.
    else do:
      for each buf_db where buf_db.db-num > 0 no-lock
      on error  undo,  return  error :
        assign list-remote-db-wsd = list-remote-db-wsd + chr(1) + string(buf_db.db-num).
        if buf_db.db-num <> g#news-source-db then
        do on error undo, return error return-value :
          assign list-remote-db = list-remote-db + chr(1) + string(buf_db.db-num).
          if buf_db.remote-stock = yes then
          do on error undo, return error return-value :
            assign list-remote-stock = list-remote-stock + chr(1) + string(buf_db.db-num).
          end.
        end.
      end.
    end.
    assign
      list-remote-db-wsd = substring( list-remote-db-wsd, 2, length( list-remote-db-wsd ) )
      list-remote-db     = substring( list-remote-db,     2, length( list-remote-db ) )
      list-remote-stock  = substring( list-remote-stock,  2, length( list-remote-stock ) )
      .
   end.
if p-tbl-name = 'db':U and g#db-num = 0 and not g#news then do:
   assign list-db-for-send = string(p-tbl-handle:buffer-field("db-num"):buffer-value).
   if list-db-for-send = "0" then assign list-db-for-send = "".
   assign v-found = yes.
end.
if p-tbl-name = 'thbj-attr':U and g#db-num = 0 then do:
   v-obj-type = p-tbl-handle:buffer-field("obj-type"):buffer-value.
   v-obj-code = p-tbl-handle:buffer-field("obj-code"):buffer-value.
   if (v-obj-type = "" and v-obj-code = 0) or v-obj-type = 'регион':U then do:
       assign list-db-for-send = list-remote-db-wsd.
   end.
   else do:
       if v-obj-type = 'БД':U then do:
           if v-obj-code > 0 then
               assign list-db-for-send = string(v-obj-code).
           else
               assign list-db-for-send = "".
       end.
       else do:
           find first buf_clients no-lock
               where buf_clients.obj-type = v-obj-type
                 and buf_clients.obj-code = v-obj-code no-error.
           if available buf_clients then do:
               assign list-db-for-send = string(buf_clients.db-num).
               if list-db-for-send = "0" then assign list-db-for-send = "".
           end.
           else do:
               assign list-db-for-send = "".
           end.
       end.
   end.
   assign v-found = yes.
end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-0-rdb-and-from-news) > 0 then do:
    if g#db-num = 0 then do:
      assign list-db-for-send = list-remote-db-wsd.
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and (lookup(v-tbl-name, v-custom-0-rdb-not-news) > 0 or (not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-0-rdb-not-news) > 0))
  then do:
    if g#db-num = 0 and not g#news then do:
      assign list-db-for-send = list-remote-db-wsd .
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-0-rdb_rbd-0-not-news) > 0 then do:
    if g#db-num = 0 then do:
      assign list-db-for-send = list-remote-db-wsd .
    end.
    if  g#db-num <> 0 and not g#news then do:
      assign list-db-for-send = "0" .
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-0-remote-stock) > 0 then do:
    if g#db-num = 0 then do:
      assign list-db-for-send = list-remote-stock .
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-rdb-0-not-news) > 0 then do:
    if  g#db-num <> 0 and not g#news then do :
      assign list-db-for-send = "0" .
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-0-rdb-no-src_rdb-0-no-news) > 0 then do:
    if g#db-num = 0 then do:
      assign list-db-for-send = list-remote-db .
    end.
    if  g#db-num <> 0 and not g#news then do:
      assign list-db-for-send = "0" .
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-route-c-glob-context) > 0 then do:
    assign
    v-obj-type = '':U
    v-obj-code = 0
    v-is-news = (v-tbl-handle:buffer-field("corr-user-name"):buffer-value begins (chr(4) +  'СПН':U) )
    v-corr-user-name = v-tbl-handle:buffer-field("corr-user-db-num"):buffer-value
    v-is-c-route = yes
    .
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-route-c-shapka-context) > 0 then do:
    assign
    v-obj-type = v-tbl-handle:buffer-field("obj-type"):buffer-value
    v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value
    v-is-news = (v-tbl-handle:buffer-field("is-news"):buffer-value = yes )
    v-corr-user-name = v-tbl-handle:buffer-field("corr-user-db-num"):buffer-value
    v-is-c-route = yes
    .
    if v-tbl-handle:buffer-field("subject"):buffer-value = 'tax-rate-gds':U then do:
      assign
      v-obj-type = '':U
      v-obj-code = 0
      .
    end.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-route-c-quest-context) > 0 then do:
    assign
    v-obj-type = v-tbl-handle:buffer-field("obj-type"):buffer-value
    v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value
    v-is-news = (v-tbl-handle:buffer-field("corr-user-name"):buffer-value begins (chr(4) +  'СПН':U) )
    v-corr-user-name = v-tbl-handle:buffer-field("corr-user-db-num"):buffer-value
    v-is-c-route = yes
    .
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-c-quest-context-global-only-0) > 0 then do:
    assign
    v-obj-type = v-tbl-handle:buffer-field("obj-type"):buffer-value
    v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value
    v-is-news = (v-tbl-handle:buffer-field("corr-user-name"):buffer-value begins (chr(4) +  'СПН':U) )
    v-corr-user-name = v-tbl-handle:buffer-field("corr-user-db-num"):buffer-value
    v-is-c-route = yes
    v-global-only-0 = yes
    .
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and v-is-c-route then do:
    if (v-obj-type = '':U
    and v-obj-code = 0)
    or (v-obj-type <> 'маг':U and v-obj-type <> 'скл':U)
    or v-obj-type = 'БД':U
    then do:
      if v-obj-type = 'БД':U then do:
        if g#db-num = 0 then do:
          if not g#news then do:
            if v-obj-code > 0 then
            assign list-db-for-send = string(v-obj-code) .
          end.
          else do:
          end.
        end.
        if g#db-num <> 0 then do:
          if not g#news then do:
            assign list-db-for-send = "0" .
          end.
          else do:
            if v-corr-user-db-num = g#db-num
            and v-is-news
            then do:
              assign list-db-for-send = "0".
            end.
          end.
        end.
      end.
      else do:
        if g#db-num = 0 then do:
          if not g#news then do:
            assign list-db-for-send = list-remote-db-wsd .
          end.
          else do:
            if v-is-news
            and not v-global-only-0
            then do:
              assign list-db-for-send = list-remote-db.
            end.
          end.
        end.
        if g#db-num <> 0 then do:
          if not g#news then do:
            assign list-db-for-send = "0" .
          end.
          else do:
            if v-corr-user-db-num = g#db-num
            and v-is-news
            then do:
              assign list-db-for-send = "0".
            end.
          end.
        end.
      end.
    end.
    else do:
      find buf_clients where
          buf_clients.obj-code = v-obj-code
      and buf_clients.obj-type = v-obj-type  no-lock .
      if g#db-num = 0
      and buf_clients.db-num <> 0
      and (not v-is-news
            or
            v-global-only-0)
      then do:
        assign list-db-for-send = string( buf_clients.db-num ) .
      end.
      if g#db-num <> 0
      and ((not g#news or v-is-news)
            or
            v-global-only-0)
      then do:
        assign list-db-for-send = "0" .
      end.
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-route-c-only-0) > 0 then do:
    if g#db-num = 0 then do:
      assign list-db-for-send = list-remote-db-wsd .
    end.
    if g#db-num > 0 then do:
      assign list-db-for-send = "0" .
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-reply-through-news) > 0 then do:
    if g#news then do:
      assign list-db-for-send = string(g#news-source-db).
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-obj-tables) > 0 then do:
    if g#db-num <> 0 then do:
      assign list-db-for-send = "0" .
    end.
    if g#db-num = 0 then do:
      assign
      v-obj-type = v-tbl-handle:buffer-field("obj-type"):buffer-value
      v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value
      .
      find first buf_clients where
                  buf_clients.obj-type = v-obj-type
              and buf_clients.obj-code = v-obj-code  no-lock.
      if buf_clients.db-num <> 0  then do:
        assign list-db-for-send = string( buf_clients.db-num ) .
      end.
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-c-obj-tables) > 0 then do:
    v-is-news = ( v-tbl-handle:buffer-field("corr-user-name"):buffer-value begins (chr(4) +  'СПН':U))
    .
    if g#db-num = 0 then do:
      assign
      v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value
      v-obj-type = v-tbl-handle:buffer-field("obj-type"):buffer-value
      .
      find first buf_clients where
          buf_clients.obj-code = v-obj-code
      and buf_clients.obj-type = v-obj-type  no-lock.
      if buf_clients.db-num <> 0
      and not v-is-news then do:
        assign list-db-for-send = string( buf_clients.db-num ) .
      end.
    end.
    if g#db-num <> 0
    and (not g#news or  v-is-news) then do:
      assign list-db-for-send = "0" .
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-c-obj-tables-todo) > 0 then do:
    v-is-news = ( v-tbl-handle:buffer-field("corr-user-name"):buffer-value begins (chr(4) +  'СПН':U))
    .
    if g#db-num = 0 then do:
      assign
      v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value
      v-obj-type = v-tbl-handle:buffer-field("obj-type"):buffer-value
      .
      find buf_clients where
          buf_clients.obj-code = v-obj-code
      and buf_clients.obj-type = v-obj-type  no-lock .
      if buf_clients.db-num <> 0 then do:
        assign list-db-for-send = string( buf_clients.db-num ) .
      end.
    end.
    if g#db-num <> 0
    then do:
      assign list-db-for-send = "0" .
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-quest-context) > 0 then do:
    assign
    v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value
    v-obj-type = v-tbl-handle:buffer-field("obj-type"):buffer-value
    .
    if v-obj-type = "":U
    and v-obj-code = 0 then do:
      if g#db-num = 0 then do:
        assign list-db-for-send = list-remote-db-wsd .
      end.
      if  g#db-num <> 0 and not g#news then do:
        assign list-db-for-send = "0" .
      end.
    end.
    else do:
      if g#db-num = 0 then do:
        find buf_clients where
            buf_clients.obj-code = v-obj-code
        and buf_clients.obj-type = v-obj-type  no-lock.
        if buf_clients.db-num <> 0  then do:
          assign list-db-for-send = string( buf_clients.db-num ) .
        end.
      end.
      if g#db-num <> 0 and not g#news then do:
        assign list-db-for-send = "0" .
      end.
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-quest-context-todo) > 0 then do:
    assign
    v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value
    v-obj-type = v-tbl-handle:buffer-field("obj-type"):buffer-value
    .
    if v-obj-type = "":U
    and v-obj-code = 0 then do:
      if g#db-num = 0 then do:
        assign list-db-for-send = list-remote-db-wsd .
      end.
      if  g#db-num <> 0 and not g#news then do:
        assign list-db-for-send = "0" .
      end.
    end.
    else do:
      if g#db-num = 0 then do:
        find buf_clients where
            buf_clients.obj-code = v-obj-code
        and buf_clients.obj-type = v-obj-type  no-lock.
        if buf_clients.db-num <> 0  then do:
          assign list-db-for-send = string( buf_clients.db-num ) .
        end.
      end.
      if g#db-num <> 0 then do:
        assign list-db-for-send = "0" .
      end.
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-quest-context-global-only-0) > 0 then do:
    assign
    v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value
    v-obj-type = v-tbl-handle:buffer-field("obj-type"):buffer-value
    .
    if (v-obj-type = "":U
    and v-obj-code = 0)
    then do:
      if g#db-num = 0 then do:
        assign list-db-for-send = list-remote-db-wsd .
      end.
    end.
    else do:
      if v-obj-type = 'БД':U then do:
        if g#db-num = 0 then do:
          if v-obj-code > 0 then
          assign list-db-for-send = string(v-obj-code) .
        end.
        else do:
          assign list-db-for-send = string(0) .
        end.
      end.
      else do:
        if g#db-num = 0 then do:
          find buf_clients where
              buf_clients.obj-code = v-obj-code
          and buf_clients.obj-type = v-obj-type  no-lock.
          if buf_clients.db-num <> 0  then do:
            assign list-db-for-send = string( buf_clients.db-num ) .
          end.
        end.
        if g#db-num <> 0
        and not g#news
        then do:
          assign list-db-for-send = "0" .
        end.
      end.
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-quest-context-glob-nosend) > 0 then do:
    assign
    v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value
    v-obj-type = v-tbl-handle:buffer-field("obj-type"):buffer-value
    .
    if v-obj-type = "":U
    and v-obj-code = 0 then do:
    end.
    else do:
      if g#db-num = 0 then do:
        find buf_clients where
            buf_clients.obj-code = v-obj-code
        and buf_clients.obj-type = v-obj-type  no-lock.
        if buf_clients.db-num <> 0  then do:
          assign list-db-for-send = string( buf_clients.db-num ) .
        end.
      end.
      if g#db-num <> 0
      and not g#news
      then do:
        assign list-db-for-send = "0" .
      end.
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name,  v-main-firm-db-0-not-news) > 0 then do:
    if not g#news then do:
      if g#db-num = 0 then do:
      end.
      else do:
        assign
        v-host-code = v-tbl-handle:buffer-field("host-code"):buffer-value
        .
        find first buf_sysconf no-lock where
                  buf_sysconf.host-code = v-host-code no-error.
        if available buf_sysconf
        and buf_sysconf.firm-db-num = g#db-num then do:
          assign list-db-for-send = "0" .
        end.
      end.
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-0-rdb-not-news_rbd-0) > 0 then do:
    if g#db-num = 0 and not g#news then do:
      assign list-db-for-send = list-remote-db-wsd .
    end.
    if g#db-num <> 0 then do:
      assign list-db-for-send = "0" .
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-rbd-0) > 0 then do:
    if g#db-num <> 0 then do:
      assign list-db-for-send = "0" .
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-db-num-tables) > 0 then do:
    if g#db-num > 0
      and g#news = false
    then do:
      assign list-db-for-send = "0" .
    end.
    if g#db-num = 0 then do:
      assign
      list-db-for-send = string(v-tbl-handle:buffer-field("db-num"):buffer-value)
      .
      if integer( list-db-for-send ) = 0 then do:
        assign
        list-db-for-send = "":U
        .
      end.
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-c-db-num-tables) > 0 then do:
    if g#db-num > 0
      and g#news = false
    then do:
      assign list-db-for-send = "0" .
    end.
    if g#db-num = 0 then do:
      assign
      list-db-for-send = string(v-tbl-handle:buffer-field("db-num"):buffer-value)
      .
      if integer( list-db-for-send ) = 0 then do:
        assign
        list-db-for-send = "":U
        .
      end.
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-shop-tables) > 0 then do:
    if g#db-num <> 0 and not g#news then do:
      assign list-db-for-send = "0" .
    end.
    if g#db-num = 0 then do:
      assign
      v-obj-type = 'маг':U
      v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value.
      find buf_clients where
          buf_clients.obj-code = v-obj-code
      and buf_clients.obj-type = v-obj-type  no-lock.
      if buf_clients.db-num <> 0  then do:
        assign list-db-for-send = string( buf_clients.db-num ) .
      end.
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and lookup(v-tbl-name, v-c-shop-tables) > 0 then do:
    assign
    v-is-news = (v-tbl-handle:buffer-field("corr-user-name"):buffer-value begins (chr(4) +  'СПН':U))
    .
    if g#db-num <> 0
    and (not g#news or  v-is-news) then do:
      assign list-db-for-send = "0" .
    end.
    if g#db-num = 0 then do:
      assign
      v-obj-type = 'маг':U
      v-obj-code = v-tbl-handle:buffer-field("obj-code"):buffer-value.
      find buf_clients where
          buf_clients.obj-code = v-obj-code
      and buf_clients.obj-type = v-obj-type  no-lock .
      if buf_clients.db-num <> 0
      and not v-is-news
      then do:
        assign list-db-for-send = string( buf_clients.db-num ) .
      end.
    end.
    v-found = yes.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
    and lookup(v-tbl-name, v-custom-list) > 0
  then do:
    CASE v-tbl-name:
      when 'doc-attr':U then do:
        find buf_doc-attr where rowid( buf_doc-attr )  = v-tbl-row no-lock.
        find buf_trn-doc where  buf_trn-doc.doc-code  = buf_doc-attr.doc-code no-lock no-error .
        find buf_price-doc where  buf_price-doc.doc-num  = buf_doc-attr.doc-code no-lock no-error .
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0" .
        end.
        else do:
          if available buf_trn-doc then do:
              if buf_trn-doc.status_  = 'запрос':U and
                buf_trn-doc.flag_    = true       and
                buf_trn-doc.doc-type = 'при':U  and
                buf_trn-doc.internal = true       then do:
                find buf_clients where buf_clients.obj-code = buf_trn-doc.cli-code
                                  and buf_clients.obj-type = buf_trn-doc.cli-type no-lock.
              end.
              else do:
                find buf_clients where buf_clients.obj-code = buf_trn-doc.obj-code
                                  and buf_clients.obj-type = buf_trn-doc.obj-type no-lock.
              end.
          end.
          if available buf_price-doc then do:
                find buf_clients where buf_clients.obj-code = buf_price-doc.obj-code
                                   and buf_clients.obj-type = buf_price-doc.obj-type no-lock.
          end.
          if buf_clients.db-num <> 0  then do:
            assign list-db-for-send = string( buf_clients.db-num ) .
          end.
        end.
        v-found = yes.
      end.
      when 'trn-doc':U then do:
        find buf_trn-doc where rowid( buf_trn-doc )  = v-tbl-row no-lock.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0" .
        end.
        else do:
          if buf_trn-doc.status_  = 'запрос':U and
            buf_trn-doc.flag_    = true       and
            buf_trn-doc.doc-type = 'при':U  and
            buf_trn-doc.internal = true       then do:
            find buf_clients where buf_clients.obj-code = buf_trn-doc.cli-code
                              and buf_clients.obj-type = buf_trn-doc.cli-type no-lock.
          end.
          else do:
            find buf_clients where buf_clients.obj-code = buf_trn-doc.obj-code
                              and buf_clients.obj-type = buf_trn-doc.obj-type no-lock.
          end.
          if buf_clients.db-num <> 0  then do:
            assign list-db-for-send = string( buf_clients.db-num ) .
          end.
        end.
        v-found = yes.
      end.
      when 'wth-doc':U then do:
        find buf_wth-doc where rowid( buf_wth-doc )  = v-tbl-row no-lock.
        if g#news and  g#db-num <> 0 then.
        else if buf_wth-doc.status_ = 'факт':U then do:
          if  g#db-num <> 0 then  assign list-db-for-send = '0'.
          else if can-find(first buf_wth-parts where buf_wth-parts.out-code = buf_wth-doc.doc-code) then
          assign list-db-for-send = list-remote-db.
        end.
        else do:
          if (buf_wth-doc.doc-type = 'при':U or buf_wth-doc.doc-type = 'возврат':U)  and
             buf_wth-doc.inter_ = no and
             buf_wth-doc.exter_ = no  and
             g#db-num = 0
             then do:
             find buf_clients where buf_clients.obj-code = buf_wth-doc.obj-code
                                and buf_clients.obj-type = buf_wth-doc.obj-type no-lock.
             if buf_clients.db-num <> g#db-num then assign list-db-for-send = string( buf_clients.db-num ).
          end.
        end.
        v-found = yes.
      end.
      when 'wth-doc-attr':U then do:
        find buf_wth-doc-attr where rowid( buf_wth-doc-attr )  = v-tbl-row no-lock.
        find buf_wth-doc where  buf_wth-doc.doc-code  = buf_wth-doc-attr.doc-code no-lock.
        if g#news and  g#db-num <> 0 then.
        else if buf_wth-doc.status_ = 'факт':U then do:
          if  g#db-num <> 0 then  assign list-db-for-send = '0'.
          else if can-find(first buf_wth-parts where buf_wth-parts.out-code = buf_wth-doc.doc-code) then
          assign list-db-for-send = list-remote-db.
        end.
        else do:
          if (buf_wth-doc.doc-type = 'при':U or buf_wth-doc.doc-type = 'возврат':U)  and
             buf_wth-doc.inter_ = no and
             buf_wth-doc.exter_ = no  and
             g#db-num = 0
             then do:
             find buf_clients where buf_clients.obj-code = buf_wth-doc.obj-code
                                and buf_clients.obj-type = buf_wth-doc.obj-type no-lock.
             if buf_clients.db-num <> g#db-num then assign list-db-for-send = string( buf_clients.db-num ).
          end.
        end.
        v-found = yes.
      end.
      when 'schet-fact-doc':U then do:
        find buf_schet-fact-doc where rowid( buf_schet-fact-doc )  = v-tbl-row no-lock.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0" .
        end.
        else do:
          if buf_schet-fact-doc.db-num <> 0 then assign list-db-for-send = string(buf_schet-fact-doc.db-num) .
          else assign list-db-for-send = "" .
        end.
        v-found = yes.
      end.
      when 'c-schet-fact-doc':U then do:
        find buf_c-schet-fact-doc where rowid( buf_c-schet-fact-doc )  = v-tbl-row no-lock.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0" .
        end.
        else do:
          if buf_c-schet-fact-doc.db-num <> 0 then assign list-db-for-send = string(buf_c-schet-fact-doc.db-num) .
          else assign list-db-for-send = "" .
        end.
        v-found = yes.
      end.
      when 'ord-doc':U then do:
        find buf_ord-doc where rowid( buf_ord-doc ) = v-tbl-row no-lock.
        if buf_ord-doc.doc-type = 'ОР':U then do:
            run cus/ord-db.p ( input buf_ord-doc.doc-code
                              ,output list-db-for-send
                              ).
        end.
        else do:
            find buf_clients where buf_clients.obj-code = buf_ord-doc.obj-code
                              and buf_clients.obj-type = buf_ord-doc.obj-type
                            no-lock.
            if g#db-num = 0 and buf_clients.db-num <> 0  then do :
              assign list-db-for-send = string( buf_clients.db-num ) .
            end.
            if g#db-num <> 0 then do :
              assign list-db-for-send = "0" .
            end.
        end.
        v-found = yes.
      end.
      when 'c-ord-doc':U then do:
        find buf_c-ord-doc where rowid( buf_c-ord-doc ) = v-tbl-row no-lock.
        find buf_clients where buf_clients.obj-code = buf_c-ord-doc.obj-code
                          and buf_clients.obj-type = buf_c-ord-doc.obj-type
                        no-lock no-error .
        if available  buf_clients then do:
            if g#db-num = 0 and buf_clients.db-num <> 0  then do :
              assign list-db-for-send = string( buf_clients.db-num ) .
            end.
            if g#db-num <> 0 then do :
              assign list-db-for-send = "0" .
            end.
        end.
        else assign list-db-for-send = "0" .
        v-found = yes.
      end.
      when 'ord-doc-rcv':U then do:
        find buf_ord-doc-rcv where rowid( buf_ord-doc-rcv ) = v-tbl-row no-lock no-error .
        if available buf_ord-doc-rcv then do:
        run cus/rcv-db.p ( input buf_ord-doc-rcv.doc-code
                          ,input buf_ord-doc-rcv.rcv-code
                          ,output list-db-for-send
                            ).
        end.
        v-found = yes.
      end.
      when 'ord-cons':U then do:
        find buf_ord-cons where rowid( buf_ord-cons ) = v-tbl-row no-lock.
        run cus/cons-db.p ( input buf_ord-cons.cons-code
                      ,output list-db-for-send
                    ).
        v-found = yes.
      end.
      when 'price-all':U then do:
        find buf_price-all where rowid( buf_price-all ) = v-tbl-row no-lock.
            run trg/pal-db.p ( input  v-tbl-row ,
                               output list-db-for-send
                              ).
        v-found = yes.
      end.
      when 'price-doc-forming':U then do:
        find buf_price-doc-forming where rowid( buf_price-doc-forming ) = v-tbl-row no-lock.
            run trg/pdf-db.p ( input  buf_price-doc-forming.plt-db ,
                               input  buf_price-doc-forming.plt-id ,
                               output list-db-for-send
                              ).
            v-found = yes.
      end.
      when 'staff':U then do:
        if g#news = no then do:
          find buf_staff where rowid( buf_staff ) = v-tbl-row no-lock.
          if available buf_staff then do:
            run trg/staffrou.p  (
                                  input buf_staff.db-num
                                  ,input buf_staff.host-code
                                  ,input buf_staff.obj-type
                                  ,input buf_staff.obj-code
                                  ,input buf_staff.work-place
                                  ,output list-db-for-send
                                  ,output v-routing ).
            if v-routing = 'wsd' then do:
              assign
              list-db-for-send = list-remote-db-wsd
              .
            end.
          end.
        end.
        v-found = yes.
      end.
      when 'c-staff':U then do:
        if g#news = no then do:
          find buf_c-staff where rowid( buf_c-staff ) = v-tbl-row no-lock.
          if available buf_c-staff then do:
            run trg/staffrou.p  (
                                  input buf_c-staff.db-num
                                  ,input buf_c-staff.host-code
                                  ,input buf_c-staff.obj-type
                                  ,input buf_c-staff.obj-code
                                  ,input buf_c-staff.work-place
                                  ,output list-db-for-send
                                  ,output v-routing ).
            if v-routing = 'wsd' then do:
              assign
              list-db-for-send = list-remote-db-wsd
              .
            end.
          end.
        end.
        v-found = yes.
      end.
      when 'clob-bind':U then do:
        if v-tbl-handle:buffer-field("resource-type"):buffer-value = 'gate':U then do:
          if g#db-num = 0 then do:
            assign
            list-db-for-send = list-remote-db
            .
          end.
          v-found = yes.
        end.
        if v-tbl-handle:buffer-field("resource-type"):buffer-value = 'report':U
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'report-xml':U
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'list':U
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'list-macro':U
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'ref':U
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-wb':U
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-ref-b':U
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-wb-act':U
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-ticket':U
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-wb-ticket':U
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-ab':U
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-awo':U
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-ab_shop':U
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-awo_shop':U
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-tts':U
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-tfs':U
        or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-qb':U
        then do:
          if g#db-num = 0 and
          not (v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-wb':U
          or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-ref-b':U
          or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-wb-act':U
          or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-ticket':U
          or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-wb-ticket':U
          or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-ab':U
          or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-awo':U
          or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-ab_shop':U
          or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-awo_shop':U
          or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-tts':U
          or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-tfs':U
          or v-tbl-handle:buffer-field("resource-type"):buffer-value = 'egais-qb':U)
          then do:
            assign
              list-db-for-send = list-remote-db
            .
          end.
          if g#db-num > 0 then do:
            assign
              list-db-for-send = string(0)
            .
          end.
          v-found = yes.
        end.
      end.
      when 'clob-data':U then do:
        if v-lob-type = 'report':U
        or v-lob-type = 'report-xml':U
        or v-lob-type = 'list':U
        or v-lob-type = 'list-macro':U
        or v-lob-type = 'ref':U
        or v-lob-type = 'egais-wb':U
        or v-lob-type = 'egais-ref-b':U
        or v-lob-type = 'egais-wb-act':U
        or v-lob-type = 'egais-ticket':U
        or v-lob-type = 'egais-wb-ticket':U
        or v-lob-type = 'egais-ab':U
        or v-lob-type = 'egais-awo':U
        or v-lob-type = 'egais-ab_shop':U
        or v-lob-type = 'egais-awo_shop':U
        or v-lob-type = 'egais-tts':U
        or v-lob-type = 'egais-tfs':U
        or v-lob-type = 'egais-qb':U
        then do:
          if g#db-num = 0 and
            not (v-lob-type = 'egais-wb':U
            or v-lob-type = 'egais-ref-b':U
            or v-lob-type = 'egais-wb-act':U
            or v-lob-type = 'egais-ticket':U
            or v-lob-type = 'egais-wb-ticket':U
            or v-lob-type = 'egais-ab':U
            or v-lob-type = 'egais-awo':U
            or v-lob-type = 'egais-ab_shop':U
            or v-lob-type = 'egais-awo_shop':U
            or v-lob-type = 'egais-tts':U
            or v-lob-type = 'egais-tfs':U
            or v-lob-type = 'egais-qb':U)
          then do:
            assign
              list-db-for-send = list-remote-db
            .
          end.
          if g#db-num > 0 then do:
            assign
              list-db-for-send = string(0)
            .
          end.
          v-found = yes.
        end.
      end.
      when 'gds-grp-obj-attr':U then do:
        find buf_gds-grp-obj-attr no-lock
          where rowid( buf_gds-grp-obj-attr ) = v-tbl-row
        .
        if g#db-num <> 0
          and g#news = false
        then do:
          assign
            list-db-for-send = "0"
          .
        end.
        if g#db-num = 0 then do:
          if buf_gds-grp-obj-attr.attr-code = 'LimAssMat':U
          then do:
            find first buf_assortment-matrix no-lock
              where buf_assortment-matrix.asmt-id = integer(buf_gds-grp-obj-attr.obj-type)
                and buf_assortment-matrix.db-num  = buf_gds-grp-obj-attr.obj-code
              no-error .
            if available buf_assortment-matrix then do:
              if buf_assortment-matrix.obj-code = 0 then do:
                assign
                  list-db-for-send = list-remote-db
                .
              end.
              else do:
                find first buf_clients no-lock
                  where buf_clients.obj-code = buf_assortment-matrix.obj-code
                    and buf_clients.obj-type = buf_assortment-matrix.obj-type
                  no-error .
                if available buf_clients then do:
                  if buf_clients.db-num <> 0 then do:
                    assign
                      list-db-for-send = string( buf_clients.db-num )
                    .
                  end.
                end.
              end.
            end.
          end.
          else do:
            if  buf_gds-grp-obj-attr.attr-code  <> 'QntyAssMat':U then do:
                if buf_gds-grp-obj-attr.obj-type = "" then do:
                    assign
                      list-db-for-send = list-remote-db
                    .
                end.
                else do:
                    find first buf_clients no-lock
                      where buf_clients.obj-code = buf_gds-grp-obj-attr.obj-code
                        and buf_clients.obj-type = buf_gds-grp-obj-attr.obj-type
                      no-error .
                    if available buf_clients then do:
                      if buf_clients.db-num <> 0 then do:
                        assign
                          list-db-for-send = string( buf_clients.db-num )
                        .
                      end.
                    end.
                end.
              end.
        end.
        end.
        assign
          v-found = true
        .
      end.
      when 'edi-status':U then do:
        find first ub.edi-status no-lock where rowid (ub.edi-status) = v-tbl-row.
        find first ub.ord-doc no-lock where ub.edi-status.doc-code = ub.ord-doc.doc-code.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else do:
          assign list-db-for-send = string (ub.ord-doc.user-db-num).
        end.
        v-found = true.
      end.
      when 'user-login':U then do:
        find first ub.user-login no-lock where rowid (ub.user-login) = v-tbl-row.
        find first ub.sys-ctrl no-lock .
        if ub.sys-ctrl.db-num <> 0 and not g#news then do:
          assign list-db-for-send = "0".
        end.
        else do:
          if     ub.user-login.db-num <> 0
             and ub.user-login.db-num <> g#news-source-db
             and ub.user-login.db-num <> g#db-num
          then do:
          assign list-db-for-send = string (ub.user-login.db-num).
          end.
        end.
        v-found = true.
      end.
      when 'c-user-login':U then do:
        find first ub.c-user-login no-lock where rowid (ub.c-user-login) = v-tbl-row.
        if g#db-num <> 0 and not g#news then do:
          assign list-db-for-send = "0".
        end.
        else do:
          if ub.c-user-login.db-num <> 0 and not g#news then do:
          assign list-db-for-send = string (ub.c-user-login.db-num).
          end.
        end.
        v-found = true.
      end.
      when 'user-menu-group':U then do:
        find first ub.user-menu-group no-lock where rowid (ub.user-menu-group) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else do:
          if ub.user-menu-group.db-num <> 0 then do:
          assign list-db-for-send = string (ub.user-menu-group.db-num).
          end.
        end.
        v-found = true.
      end.
      when 'user-login-action-item':U then do:
        find first ub.user-login-action-item no-lock where rowid (ub.user-login-action-item) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else do:
          if ub.user-login-action-item.db-num <> 0 then do:
          assign list-db-for-send = string (ub.user-login-action-item.db-num).
          end.
        end.
        v-found = true.
      end.
      when 'user-login-action-role':U then do:
        find first ub.user-login-action-role no-lock where rowid (ub.user-login-action-role) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else do:
          if ub.user-login-action-role.db-num <> 0 then do:
          assign list-db-for-send = string (ub.user-login-action-role.db-num).
          end.
        end.
        v-found = true.
      end.
      when 'user-login-attr':U then do:
        find first ub.user-login-attr no-lock where rowid (ub.user-login-attr) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else do:
          if ub.user-login-attr.db-num <> 0 then do:
          assign list-db-for-send = string (ub.user-login-attr.db-num).
          end.
        end.
        v-found = true.
      end.
      when 'user-obj':U then do:
        find first ub.user-obj no-lock where rowid (ub.user-obj) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else do:
          if ub.user-obj.db-num <> 0 then do:
          assign list-db-for-send = string (ub.user-obj.db-num).
          end.
        end.
        v-found = true.
      end.
      when 'user-host':U then do:
        find first ub.user-host no-lock where rowid (ub.user-host) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else do:
          if ub.user-host.db-num <> 0 then do:
          assign list-db-for-send = string (ub.user-host.db-num).
          end.
        end.
        v-found = true.
      end.
      when 'action-role':U then do:
define variable vss-include-info3 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run actn-gbl in g#library2
    ( output v-on-gbl
    ) no-error .
end.
        find first ub.action-role no-lock where rowid (ub.action-role) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else if v-on-gbl then do:
            list-db-for-send = list-remote-db.
        end.
        else do:
          if ub.action-role.db-num <> 0 then do:
          assign list-db-for-send = string (ub.action-role.db-num).
          end.
        end.
        v-found = true.
      end.
      when 'action-role-item':U then do:
define variable vss-include-info4 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run actn-gbl in g#library2
    ( output v-on-gbl
    ) no-error .
end.
        find first ub.action-role-item no-lock where rowid (ub.action-role-item) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else if v-on-gbl then do:
            list-db-for-send = list-remote-db.
        end.
        else do:
          if ub.action-role-item.db-num <> 0 then do:
          assign list-db-for-send = string (ub.action-role-item.db-num).
          end.
        end.
        v-found = true.
      end.
      when 'action-role-item-gds':U then do:
define variable vss-include-info5 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run actn-gbl in g#library2
    ( output v-on-gbl
    ) no-error .
end.
        find first ub.action-role-item-gds no-lock where rowid (ub.action-role-item-gds) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else if v-on-gbl then do:
            list-db-for-send = list-remote-db.
        end.
        else do:
          if ub.action-role-item-gds.db-num <> 0 then do:
          assign list-db-for-send = string (ub.action-role-item-gds.db-num).
          end.
        end.
        v-found = true.
      end.
      when 'action-role-item-gds-grp':U then do:
define variable vss-include-info6 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run actn-gbl in g#library2
    ( output v-on-gbl
    ) no-error .
end.
        find first ub.action-role-item-gds-grp no-lock where rowid (ub.action-role-item-gds-grp) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else if v-on-gbl then do:
            list-db-for-send = list-remote-db.
        end.
        else do:
          if ub.action-role-item-gds-grp.db-num <> 0  then do:
          assign list-db-for-send = string (ub.action-role-item-gds-grp.db-num).
          end.
        end.
        v-found = true.
      end.
      when 'season':U then do:
        find first ub.season no-lock where rowid (ub.season) = v-tbl-row.
        find first ub.season-attr no-lock where ub.season-attr.sea-code = ub.season.sea-code
          and ub.season-attr.db-num = ub.season.db-num and ub.season-attr.attr-code = 'sea-obj':U no-error.
        if available ub.season-attr then do:
          if g#db-num = 0 and not g#news then do:
            find first buf_clients no-lock where buf_clients.obj-type = substring (ub.season-attr.attr-value, 1, 3)
              and buf_clients.obj-code = integer(substring (ub.season-attr.attr-value, 4)).
            if buf_clients.db-num <> 0  then do:
              assign list-db-for-send = string (buf_clients.db-num).
            end.
          end.
          if g#db-num <> 0 and not g#news then do:
            assign list-db-for-send = "0".
          end.
        end.
        else do:
          if not g#news then do:
            assign list-db-for-send = list-remote-db .
         end.
        end.
        v-found = true.
      end.
      when 'season-attr':U then do:
        find first ub.season-attr no-lock where rowid (ub.season-attr) = v-tbl-row.
        if ub.season-attr.attr-code = 'sea-obj':U then do:
          if g#db-num = 0 and not g#news then do:
            find first buf_clients no-lock where buf_clients.obj-type = substring (ub.season-attr.attr-value, 1, 3)
              and buf_clients.obj-code = integer(substring (ub.season-attr.attr-value, 4)).
            if buf_clients.db-num <> 0  then do:
              assign list-db-for-send = string (buf_clients.db-num).
            end.
          end.
          if g#db-num <> 0 and not g#news then do:
            assign list-db-for-send = "0".
          end.
        end.
        else do:
         if g#db-num = 0 then do:
           assign list-db-for-send = list-remote-db .
         end.
         if g#db-num <> 0 and not g#news then do:
           assign list-db-for-send = "0" .
         end.
        end.
        v-found = true.
      end.
      when 'gds-season':U then do:
        find first ub.gds-season no-lock where rowid (ub.gds-season) = v-tbl-row.
        find first ub.season no-lock where ub.gds-season.sea-code = ub.season.sea-code
          and ub.gds-season.db-num = ub.season.db-num.
        find first ub.season-attr no-lock where ub.season-attr.sea-code = ub.season.sea-code
          and ub.season-attr.db-num = ub.season.db-num and ub.season-attr.attr-code = 'sea-obj':U no-error.
        if available ub.season-attr then do:
          if g#db-num = 0 and not g#news then do:
            find first buf_clients no-lock where buf_clients.obj-type = substring (ub.season-attr.attr-value, 1, 3)
              and buf_clients.obj-code = integer(substring (ub.season-attr.attr-value, 4)).
            if buf_clients.db-num <> 0  then do:
              assign list-db-for-send = string (buf_clients.db-num).
            end.
          end.
          if g#db-num <> 0 and not g#news then do:
            assign list-db-for-send = "0".
          end.
        end.
        else do:
          if not g#news then do:
            assign list-db-for-send = list-remote-db .
         end.
        end.
        v-found = true.
      end.
      when 'gds-season-attr':U then do:
        find first ub.gds-season-attr no-lock where rowid (ub.gds-season-attr) = v-tbl-row.
        find first ub.season no-lock where ub.gds-season-attr.sea-code = ub.season.sea-code
          and ub.gds-season-attr.db-num = ub.season.db-num.
        find first ub.season-attr no-lock where ub.season-attr.sea-code = ub.season.sea-code
          and ub.season-attr.db-num = ub.season.db-num and ub.season-attr.attr-code = 'sea-obj':U no-error.
        if available ub.season-attr then do:
          if g#db-num = 0 and not g#news then do:
            find first buf_clients no-lock where buf_clients.obj-type = substring (ub.season-attr.attr-value, 1, 3)
              and buf_clients.obj-code = integer(substring (ub.season-attr.attr-value, 4)).
            if buf_clients.db-num <> 0  then do:
              assign list-db-for-send = string (buf_clients.db-num).
            end.
          end.
          if g#db-num <> 0 and not g#news then do:
            assign list-db-for-send = "0".
          end.
        end.
        else do:
          if not g#news then do:
            assign list-db-for-send = list-remote-db .
         end.
        end.
        v-found = true.
      end.
      when 'vsd':U then do:
        find first ub.vsd no-lock where rowid (ub.vsd) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else do:
          find first buf_clients where buf_clients.obj-type = ub.vsd.obj-type and buf_clients.obj-code = ub.vsd.obj-code no-error.
          if available (buf_clients) and not buf_clients.db-num = 0
            then assign list-db-for-send = string (buf_clients.db-num).
        end.
        v-found = true.
      end.
      when 'vsd-attr':U then do:
        find first ub.vsd-attr no-lock where rowid (ub.vsd-attr) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else do:
          find first ub.vsd no-lock where ub.vsd.ID = ub.vsd-attr.ID and ub.vsd.db-num = ub.vsd-attr.db-num.
          find first buf_clients where buf_clients.obj-type = ub.vsd.obj-type and buf_clients.obj-code = ub.vsd.obj-code no-error.
          if available (buf_clients) and not buf_clients.db-num = 0
            then assign list-db-for-send = string (buf_clients.db-num).
        end.
        v-found = true.
      end.
      when 'utd':U then do:
        find first ub.utd no-lock where rowid (ub.utd) = v-tbl-row.
        if g#db-num <> 0 then do:
          assign list-db-for-send = "0".
        end.
        else do:
          find first buf_clients where buf_clients.obj-type = ub.utd.obj-type and buf_clients.obj-code = ub.utd.obj-code no-error.
          if available (buf_clients) and not buf_clients.db-num = 0
            then assign list-db-for-send = string (buf_clients.db-num).
        end.
        v-found = true.
      end.
      otherwise do:
        assign
          v-found = false
        .
      end.
    end case.
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and v-routing-type <> "LOB"
  and not (v-has-subject
          and v-tbl-name-prim <> '')
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Программа вызвана из" program-name(2)  skip
      "" program-name(3)  skip
      "" program-name(4)  skip
      "Неизвестное имя таблицы" skip
      "Имя таблицы" p-tbl-name  skip
      "Код записи (rowid)" string(v-tbl-row)   skip
      view-as alert-box error .
    undo, return error .
  end.
  if v-found <> TRUE and not can-do(v-custom-except-list, v-tbl-name)
  and (v-has-subject
     and v-tbl-name-prim <> '') then do:
    return ''.
  end.
  if v-routing-type = 'LOB':U
  then do:
    if valid-handle(v-tbl-handle) then do:
      delete object v-tbl-handle.
    end.
    if v-lob-send-non-data then do:
      run nws/lob-e.p (
        input p-tbl-handle
        ,input '':U
        ) no-error .
    end.
    else do:
      if list-db-for-send <> '':U then do:
        run nws/lob-e.p (
          input p-tbl-handle
        ,input list-db-for-send
          ) no-error .
      end.
    end.
  end.
  else do:
    if list-db-for-send <> "":U then do:
      run nws/cr-route.p ( input 'send-tbl':U, input p-tbl-name, input p-tbl-handle, input list-db-for-send ) no-error.
      if error-status :error then do:
        return error return-value.
      end.
    end.
  end.
end.
