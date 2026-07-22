block-level on error undo, throw.
define input         parameter gen-dir       as character no-undo .
define input-output  parameter gen-file-list as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: b39224d84de3, 3188, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:26 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gen-imp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/gen-imp.p $":U .
define variable vss-description as character no-undo init "".
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
define variable oth-list1 as character no-undo .
define variable oth-list2 as character no-undo .
define variable v-old-sys-alert-box    as logical   no-undo .
define variable v-lib-handle-name   as character no-undo .
define variable file-name           as character no-undo .
define variable file-name-no-ext    as character no-undo .
define variable temp-file-name      as character no-undo .
define variable tn                  as character no-undo init "".
define variable counter-step        as integer   no-undo .
define variable v-str               as character no-undo .
define variable v-num-tbls          as integer   no-undo .
define variable v-ind-tbl           as integer   no-undo init 0.
define variable v-ind-tbl-ignor     as integer   no-undo init 0.
define variable v-ind-tbl-curr      as integer   no-undo init 0.
define variable v-ind-comp          as integer   no-undo init 0.
define variable v-proc-num          as integer   no-undo init 0.
define variable v-err-num           as integer   no-undo .
define variable v-err-size          as integer   no-undo .
define variable v-skip-proc         as integer   no-undo .
define variable v-skip-proc-max     as integer   no-undo .
define variable v-skip-proc-step    as integer   no-undo .
define variable v-skip-proc-min     as integer   no-undo .
define variable v-compile           as logical   no-undo .
define variable inc-avail           as logical   no-undo init no.
define variable inc-file-name       as character no-undo init "".
define variable def-ins-avail       as logical   no-undo init no.
define variable def-ins-file-name   as character no-undo init "".
define variable def-out-avail       as logical   no-undo init no.
define variable def-out-file-name   as character no-undo init "".
define variable v-err-cmp as character no-undo .
define variable v-tmp-str as character no-undo .
define stream ImpStream .
define stream ImpPckStream .
define stream errstream .
def frame ddd
  file-name format "x(32)" label "Файл" at row 1.5  col 17 colon-aligned
  fl as character format "x(32)" label "Таблица" at row 2.5  col 17 colon-aligned
  v-str format "x(35)" label "Обработано" at row 3.5  col 17 colon-aligned
  with view-as dialog-box side-labels three-d
  title "Генерация файлов " + program-name(1)
.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if trim( gen-dir ) = "":U then do:
  assign
    gen-dir = ".":U
  .
end.
assign
  file-info:file-name = gen-dir
.
if file-info :full-pathname = ""
or file-info :full-pathname = ?  then do:
  message
    vss-workfile vss-revision vss-description skip
    substitute( "Уазанный каталог (&1) не найден!", gen-dir ) skip
    view-as alert-box error .
  undo, return error .
end.
assign
  gen-dir = file-info:full-pathname + "/":U
.
  run gbl/dir-cre.p ( input gen-dir + "nws":U ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при создании каталога &1", gen-dir + "nws":U ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error.
  end.
view frame ddd.
assign
  v-skip-proc-max  = 30
  v-skip-proc-step = 2
  v-skip-proc-min  = 2
  v-skip-proc      = v-skip-proc-max
  counter-step     = 0
  file-name        = "nws/load-rec.p":U
  file-name-no-ext = "load-rec":U
  temp-file-name   = substitute( "&1.p0":U, file-name-no-ext )
  gen-file-list    = gen-file-list + "," + "nws/imp-pck1.i":U
                                   + "," + "nws/imp-pck2.i":U
                                   + "," + "nws/imp-pck3.i":U
.
OUTPUT STREAM ImpStream TO value( gen-dir + "nws/imp-pck1.i":U ) .
PUT STREAM ImpStream UNFORMATTED
  chr(47) + chr(42) + chr(10) + chr(10) + chr(36) + 'Revision: ':U + chr(36) + chr(10) + chr(36) + 'Author: ':U + chr(36) + chr(10) + chr(36) + 'Date: ':U + chr(36) + chr(10) + chr(36) + 'Workfile: ':U + chr(36) + chr(10) + chr(36) + 'Archive: ':U + chr(36) + chr(10) + chr(10) + 'ФАЙЛ ГЕНЕРИРУЕТСЯ ПРОЦЕДУРОЙ ' + program-name(1) + chr(10) + chr(10) + chr(10) + "Автор: Уханов Дмитрий Юрьевич":U + chr(10) + "Дата создания: 01/27/03":U + chr(10) + "Author: Dmitry Ukhanov":U + chr(10) + "Creation date: 01/27/03":U + chr(10) + chr(10) + chr(42) + chr(47) + chr(10) SKIP(1)
  '~&scoped-define vssseq ~{~&sequence~}             ' SKIP
  'define variable vss-include-info~{~&vssseq~} as character format "x(65)" no-undo initial "@(#)$Workfile: gen-imp.p $ $Revision: b39224d84de3, 3188, rls $".' SKIP(1)
  'define variable v-proc-name  as character no-undo .' SKIP
  'define variable v-proc-avail as logical   no-undo .' SKIP(1)
.
OUTPUT STREAM ImpStream CLOSE.
OUTPUT STREAM ImpStream TO value( gen-dir + "nws/imp-pck2.i":U ) .
PUT STREAM ImpStream UNFORMATTED
  chr(47) + chr(42) + chr(10) + chr(10) + chr(36) + 'Revision: ':U + chr(36) + chr(10) + chr(36) + 'Author: ':U + chr(36) + chr(10) + chr(36) + 'Date: ':U + chr(36) + chr(10) + chr(36) + 'Workfile: ':U + chr(36) + chr(10) + chr(36) + 'Archive: ':U + chr(36) + chr(10) + chr(10) + 'ФАЙЛ ГЕНЕРИРУЕТСЯ ПРОЦЕДУРОЙ ' + program-name(1) + chr(10) + chr(10) + chr(10) + "Автор: Уханов Дмитрий Юрьевич":U + chr(10) + "Дата создания: 01/27/03":U + chr(10) + "Author: Dmitry Ukhanov":U + chr(10) + "Creation date: 01/27/03":U + chr(10) + chr(10) + chr(42) + chr(47) + chr(10) SKIP(1)
  '~&scoped-define vssseq ~{~&sequence~}             ' SKIP
  'define variable vss-include-info~{~&vssseq~} as character format "x(65)" no-undo initial "@(#)$Workfile: gen-imp.p $ $Revision: b39224d84de3, 3188, rls $".' SKIP(1)
  'assign                                             ' SKIP
  '  v-proc-name = substitute( "proc-load-&1", ~{1} ) ' SKIP
  '  v-proc-avail = FALSE                             ' SKIP
  '.                                                  ' SKIP
.
OUTPUT STREAM ImpStream CLOSE.
OUTPUT STREAM ImpStream TO value( gen-dir + "nws/imp-pck3.i":U ) .
PUT STREAM ImpStream UNFORMATTED
  chr(47) + chr(42) + chr(10) + chr(10) + chr(36) + 'Revision: ':U + chr(36) + chr(10) + chr(36) + 'Author: ':U + chr(36) + chr(10) + chr(36) + 'Date: ':U + chr(36) + chr(10) + chr(36) + 'Workfile: ':U + chr(36) + chr(10) + chr(36) + 'Archive: ':U + chr(36) + chr(10) + chr(10) + 'ФАЙЛ ГЕНЕРИРУЕТСЯ ПРОЦЕДУРОЙ ' + program-name(1) + chr(10) + chr(10) + chr(10) + "Автор: Уханов Дмитрий Юрьевич":U + chr(10) + "Дата создания: 01/27/03":U + chr(10) + "Author: Dmitry Ukhanov":U + chr(10) + "Creation date: 01/27/03":U + chr(10) + chr(10) + chr(42) + chr(47) + chr(10) SKIP(1)
  '~&scoped-define vssseq ~{~&sequence~}             ' SKIP
  'define variable vss-include-info~{~&vssseq~} as character format "x(65)" no-undo initial "@(#)$Workfile: gen-imp.p $ $Revision: b39224d84de3, 3188, rls $".' SKIP(1)
.
OUTPUT STREAM ImpStream CLOSE.
assign
  v-ind-tbl  = 0
  v-proc-num = 0
  v-num-tbls = num-entries( news-list )
.
block_compile:
do while v-ind-tbl < v-num-tbls
:
  assign
    v-lib-handle-name = 'g#' + file-name-no-ext .
  .
  OUTPUT STREAM ImpStream TO value( gen-dir + "nws/imp-pck1.i":U ) APPEND.
  PUT STREAM ImpStream UNFORMATTED
    SPACE(0) 'define new global shared variable ' v-lib-handle-name '  as handle no-undo .' SKIP(1)
  .
  OUTPUT STREAM ImpStream CLOSE.
  OUTPUT STREAM ImpStream TO value( gen-dir + "nws/imp-pck2.i":U ) APPEND.
  PUT STREAM ImpStream UNFORMATTED
    SPACE(0) 'if (valid-handle(' v-lib-handle-name ') <> true) then do:                                           ' SKIP
    SPACE(0) '  run ' file-name ' persistent no-error .                                                           ' SKIP
    SPACE(0) '  if error-status :error or (valid-handle(' v-lib-handle-name ') <> true) then do:                  ' SKIP
    SPACE(0) '    message                                                                                         ' SKIP
    SPACE(0) '      "Error starting ' file-name '" skip                                                           ' SKIP
    SPACE(0) '      error-status :get-message(1) skip                                                             ' SKIP
    SPACE(0) '      return-value skip                                                                             ' SKIP
    SPACE(0) '      view-as alert-box error .                                                                     ' SKIP
    SPACE(0) '    stop .                                                                                          ' SKIP
    SPACE(0) '  end.                                                                                              ' SKIP
    SPACE(0) 'end.                                                                                                ' SKIP
    SPACE(0) 'if lookup( v-proc-name, ' v-lib-handle-name ':internal-entries ) > 0 then do:                       ' SKIP
    SPACE(0) '  if v-proc-avail = TRUE then do:                                                                   ' SKIP
    SPACE(0) '    return error substitute( "&1. Рассогласованы библиотеки приема новостей для таблицы &2"         ' SKIP
    SPACE(0) '                             ,vss-workfile                                                          ' SKIP
    SPACE(0) '                             ,~{1~}                                                                 ' SKIP
    SPACE(0) '                           ).                                                                       ' SKIP
    SPACE(0) '  end.                                                                                              ' SKIP
    SPACE(0) '  run value(v-proc-name) in ' v-lib-handle-name '                                                   ' SKIP
    SPACE(0) '      ( input this-procedure                                                                        ' SKIP
    SPACE(0) '       ,input ~{3~}                                                                                 ' SKIP
    SPACE(0) '       ,input ~{4~}                                                                                 ' SKIP
    SPACE(0) '      ).                                                                                            ' SKIP
    SPACE(0) '  assign                                                                                            ' SKIP
    SPACE(0) '    v-proc-avail = TRUE                                                                             ' SKIP
    SPACE(0) '  .                                                                                                 ' SKIP
    SPACE(0) 'end.                                                                                                ' SKIP(1)
  .
  OUTPUT STREAM ImpStream CLOSE.
  assign
    gen-file-list = gen-file-list + "," + file-name
  .
  OUTPUT STREAM ImpPckStream TO value( gen-dir + file-name ).
  PUT STREAM ImpPckStream UNFORMATTED
    chr(47) + chr(42) + chr(10) + chr(10) + chr(36) + 'Revision: ':U + chr(36) + chr(10) + chr(36) + 'Author: ':U + chr(36) + chr(10) + chr(36) + 'Date: ':U + chr(36) + chr(10) + chr(36) + 'Workfile: ':U + chr(36) + chr(10) + chr(36) + 'Archive: ':U + chr(36) + chr(10) + chr(10) + 'ФАЙЛ ГЕНЕРИРУЕТСЯ ПРОЦЕДУРОЙ ' + program-name(1) + chr(10) + chr(10) + chr(10) + "Автор: Уханов Дмитрий Юрьевич":U + chr(10) + "Дата создания: 01/27/03":U + chr(10) + "Author: Dmitry Ukhanov":U + chr(10) + "Creation date: 01/27/03":U + chr(10) + chr(10) + chr(42) + chr(47) + chr(10) SKIP
    chr(47) + chr(42) + ' Импорт строки из файла ' + chr(42) + chr(47) SKIP(2)
    'define variable vss-revision    as character no-undo init "$Revision: b39224d84de3, 3188, rls $":U .                    ' SKIP
    'define variable vss-author      as character no-undo init "$Author: EShklyar $":U .                 ' SKIP
    'define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:26 $":U .             ' SKIP
    'define variable vss-workfile    as character no-undo init "$Workfile: gen-imp.p $":U .             ' SKIP
    'define variable vss-archive     as character no-undo init "$Archive: utl/gen-imp.p $":U . ' SKIP
    'define variable vss-description as character no-undo init "загрузка в БД строки".                  ' SKIP
    '~{ cmp/vssrevis.i ~}                                                                               ' SKIP
    '~{ cmp/trg-def.i  ~}                                                                               ' SKIP
    '~{ nws/nws-def.i  ~}                                                                               ' SKIP
    '~{ gbl/key-rec.i  ~}                                                                               ' SKIP
    '~{ gbl/attr-lib.i  ~}                                                                              ' SKIP
    '~{ ' "nws/imp-pck1.i":U ' ~}                                                                              ' SKIP(1)
  .
  OUTPUT STREAM ImpPckStream close.
  os-copy value( gen-dir + file-name ) value( gen-dir + temp-file-name ) .
  assign
    v-compile       = true
    v-ind-comp      = 0
    v-ind-tbl-curr  = 0
    v-ind-tbl-ignor = 0
  .
bl-tn:
  do while v-compile = true
           and v-ind-tbl < v-num-tbls
  :
    assign
      v-ind-tbl = v-ind-tbl + 1
      tn        = entry( v-ind-tbl, news-list )
    .
    display
      file-name
      tn @ fl
      substitute( "&1 из &2", v-ind-tbl, v-num-tbls ) @ v-str
      with frame ddd .
    find ub._file no-lock
      where ub._file._file-name = tn  no-error.
      if not available  ub._file
      then do:
         message "Базе нет таблицы " tn
         view-as alert-box.
         next bl-tn.
      end.
    assign
      inc-file-name     = "nws/inc/imp/" + ub._File._Dump-name + ".i"
      inc-avail     = ( if search( inc-file-name ) <> ? then TRUE else FALSE )
      def-ins-file-name = "nws/inc/imp/def-ins/" + ub._File._Dump-name + ".i"
      def-ins-avail = ( if search( def-ins-file-name ) <> ? then TRUE else FALSE )
      def-out-file-name = "nws/inc/imp/def-out/" + ub._File._Dump-name + ".i"
      def-out-avail = ( if search( def-out-file-name ) <> ? then TRUE else FALSE )
      .
    if tn = "pck-rcvd":U
      or tn = "pck-sent":U
      or ( inc-avail = false
           and def-ins-avail = false
           and def-out-avail = false
         )
    then do:
      assign
        v-ind-tbl-ignor = v-ind-tbl-ignor + 1
      .
    end.
    else do:
      assign
        v-ind-tbl-curr = v-ind-tbl-curr + 1
        v-proc-num     = v-proc-num + 1
      .
      OUTPUT STREAM ImpPckStream TO value( gen-dir + file-name ) append.
      if v-ind-tbl-curr = 1 then do:
        PUT STREAM ImpPckStream UNFORMATTED
          SPACE(0) 'if valid-handle (' v-lib-handle-name ')                                 ' SKIP
          SPACE(0) 'and ' v-lib-handle-name ' <> this-procedure :handle                     ' SKIP
          SPACE(0) 'and lookup( "proc-load-' tn '":U, ' v-lib-handle-name ':internal-entries ) > 0 ' SKIP
          SPACE(0) 'then do:                                                                ' SKIP
          SPACE(0) '  message                                                               ' SKIP
          SPACE(0) '    vss-workfile vss-revision vss-description skip                      ' SKIP
          SPACE(0) '    "Попытка повторной загрузки библиотеки" skip                        ' SKIP
          SPACE(0) '    ' v-lib-handle-name ' skip                                          ' SKIP
          SPACE(0) '    ' v-lib-handle-name ' :type skip                                    ' SKIP
          SPACE(0) '    ' v-lib-handle-name ' :file-name skip                               ' SKIP
          SPACE(0) '    valid-handle(' v-lib-handle-name ') skip                            ' SKIP
          SPACE(0) '    this-procedure :handle skip                                         ' SKIP
          SPACE(0) '    this-procedure :type skip                                           ' SKIP
          SPACE(0) '    this-procedure :file-name skip                                      ' SKIP
          SPACE(0) '    valid-handle(this-procedure) skip                                   ' SKIP
          SPACE(0) '    view-as alert-box error .                                           ' SKIP
          SPACE(0) '  undo, return error return-value .                                     ' SKIP
          SPACE(0) 'end.                                                                    ' SKIP
          SPACE(0) 'else do:                                                                ' SKIP
          SPACE(0) '  assign                                                                ' SKIP
          SPACE(0) '    ' v-lib-handle-name ' = this-procedure :handle                      ' SKIP
          SPACE(0) '  .                                                                     ' SKIP
          SPACE(0) 'end.                                                                    ' SKIP
          SPACE(0) '                                                                        ' SKIP
          SPACE(0) 'if this-procedure :persistent <> true                                   ' SKIP
          SPACE(0) 'then do:                                                                ' SKIP
          SPACE(0) '  message                                                               ' SKIP
          SPACE(0) '    vss-workfile vss-revision vss-description skip                      ' SKIP
          SPACE(0) '    "Ошибка запуска библиотеки" program-name(1) skip                    ' SKIP
          SPACE(0) '    "Попытка запустить ее как обычную процедуру" skip                   ' SKIP
          SPACE(0) '    view-as alert-box error .                                           ' SKIP
          SPACE(0) 'end.                                                                    ' SKIP
          SPACE(0) '                                                                        ' SKIP
          SPACE(0) 'on delete of this-procedure do:                                         ' SKIP
          SPACE(0) '  assign                                                                ' SKIP
          SPACE(0) '    ' v-lib-handle-name ' = ?                                           ' SKIP
          SPACE(0) '  .                                                                     ' SKIP
          SPACE(0) 'end.                                                                    ' SKIP(1)
          .
      end.
      if def-out-avail then do:
        PUT STREAM ImpPckStream UNFORMATTED
          '~{ ' def-out-file-name ' }' SKIP
          .
      end.
      PUT STREAM ImpPckStream UNFORMATTED
        SPACE(0) 'define temp-table wt-' tn ' no-undo like ub.' tn '. ' SKIP
        SPACE(0) 'PROCEDURE proc-load-' tn ': ' chr(47) + chr(42) ' ' v-proc-num ' ' chr(42) + chr(47) SKIP
        SPACE(2) 'define input parameter p-imp-handle as handle  no-undo.' SKIP
        SPACE(2) 'define input parameter p-pck-num    as integer no-undo.' SKIP
        SPACE(2) 'define input parameter l-counter    as integer no-undo.' SKIP
        SPACE(2) 'do                                                  ' SKIP
        SPACE(2) 'on error  undo, return error substitute( "$proc-load-' tn '. &1&2&3", return-value, ~{&new-line~}, error-status :get-message ( error-status :num-messages ) ) ' SKIP
        SPACE(2) 'on stop   undo, return error substitute( "$proc-load-' tn '. stop" )   ' SKIP
        SPACE(2) 'on endkey undo, return error substitute( "$proc-load-' tn '. endkey" ) ' SKIP
        SPACE(2) ':                                                   ' SKIP
        SPACE(2) '  define buffer tb-' tn ' for ub.' tn '.            ' SKIP
        SPACE(2) '  define variable compare-log as logical no-undo.   ' SKIP
        .
      if def-ins-avail then do:
        PUT STREAM ImpPckStream UNFORMATTED
          SPACE(2) '  ~{ ' def-ins-file-name ' }' SKIP
          .
      end.
      PUT STREAM ImpPckStream UNFORMATTED
        SPACE(2) '  for each wt-' tn '  ' SKIP
        SPACE(2) '  on error undo, return error substitute( "$proc-load-' tn '(del-wt-). &1&2&3", return-value, ~{&new-line~}, error-status :get-message ( error-status :num-messages ) )  ' SKIP
        SPACE(2) '  :' SKIP
        SPACE(2) '    delete wt-' tn ' . ' SKIP
        SPACE(2) '  end. ' SKIP
        SPACE(2) '  create wt-' tn '.                    ' SKIP
        SPACE(2) '  run nws-impl in p-imp-handle         ' SKIP
        SPACE(2) '    ( input ~{&table_' tn '~}          ' SKIP
        SPACE(2) '     ,input (buffer wt-' tn ':handle)  ' SKIP
        SPACE(2) '    ) no-error.                        ' SKIP
        SPACE(2) '  if error-status :error then do:      ' SKIP
        SPACE(2) '    return error return-value .        ' SKIP
        SPACE(2) '  end.                                 ' SKIP
        SPACE(2) '  find first tb-' tn '                 ' SKIP
        SPACE(2) '    where '
        .
      find ub._index no-lock
        where recid( ub._index  ) = ub._file._prime-index.
      for each ub._index-field of ub._index  no-lock ,
          each ub._field of _index-field no-lock
          break by _index-seq:
        PUT STREAM ImpPckStream UNFORMATTED
          'tb-' tn '.' ub._field._field-name ' = wt-' tn '.' ub._field._field-name SKIP.
        if not last( _index-seq ) then do:
          PUT STREAM ImpPckStream UNFORMATTED  SPACE(8) 'and ' .
        end.
      end.
      PUT STREAM ImpPckStream UNFORMATTED
        SPACE(6) 'exclusive-lock no-error.' SKIP
        .
      if not inc-avail then do:
        PUT STREAM ImpPckStream UNFORMATTED
          SPACE(2) '  if l-counter <> 0 then do:                                                                                      ' SKIP
          SPACE(2) '    return error substitute( "&1 &2. Ошибка обработки записи &3", vss-workfile, vss-revision, ~{&table_' tn '~} ) ' SKIP
          SPACE(2) '                 + ~{&new-line~} + "Есть привязанные записи, а обработка идет для одной".                         ' SKIP
          SPACE(2) '  end.                                                                                                            ' SKIP
          SPACE(2) '  if not available tb-' tn ' then do:                                                                             ' SKIP
          SPACE(2) '    create tb-' tn '.                                                                                             ' SKIP
          SPACE(2) '    assign compare-log = no.                                                                                      ' SKIP
          SPACE(2) '  end.                                                                                                            ' SKIP
          SPACE(2) '  else do:                                                                                                        ' SKIP
          SPACE(2) '    buffer-compare tb-' tn ' TO wt-' tn ' case-sensitive save result in compare-log no-error.                     ' SKIP
          SPACE(2) '  end.                                                                                                            ' SKIP
          SPACE(2) '  if not compare-log then do:                                                                                     ' SKIP
          SPACE(2) '    buffer-copy wt-' tn ' TO tb-' tn '.                                                                           ' SKIP
          SPACE(2) '  end.                                                                                                            ' SKIP
          .
      end.
      else do:
        PUT STREAM ImpPckStream UNFORMATTED
          SPACE(2)  '  ~{ ' inc-file-name ' ~} ' SKIP
          .
      end.
      PUT STREAM ImpPckStream UNFORMATTED
        SPACE(2)  '  delete wt-' tn '.                                                                  ' SKIP
        SPACE(2)  'end.                                                                                 ' SKIP
        SPACE(0)  'END PROCEDURE. ' chr(47) + chr(42) ' proc-load-' tn ' ' v-proc-num ' ' chr(42) + chr(47) '' SKIP(1)
        .
      OUTPUT STREAM ImpPckStream close.
      assign
        v-ind-comp = v-ind-comp + 1
      .
    end.
    if v-ind-tbl = v-num-tbls then do:
      assign
        v-skip-proc = v-ind-comp
      .
    end.
    if v-ind-comp = v-skip-proc then do:
      assign
        v-ind-comp = 0
        v-old-sys-alert-box    = session :system-alert-boxes
        session :system-alert-boxes = false
      .
      output to value( gen-dir + "cmp-err.txt":U) .
      COMPILE value( gen-dir + file-name ) .
      assign
        v-err-num  = error-status :GET-NUMBER(1)
        v-err-size = seek(output)
      .
      output close .
      assign
        session :system-alert-boxes = v-old-sys-alert-box
      .
      if error-status :error
        or compiler :error
      then do:
        input stream errstream from value( gen-dir + "cmp-err.txt":U).
        repeat :
          import stream errstream unformatted v-tmp-str .
          if substring( v-tmp-str, length(v-tmp-str) - 5, 6)  = "(3307)" then do:
            assign
              v-err-num = 3307
            .
          end.
          assign
            v-err-cmp = v-err-cmp + chr(10) + v-tmp-str
          .
        end.
        input stream errstream close.
        if v-err-num <> 3307 then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute( "Ошибка компиляции файла &1 строка &2", COMPILER:FILENAME, COMPILER:ERROR-ROW ) skip
            v-err-cmp skip
            error-status :get-message(1) skip
            view-as alert-box error .
          return error.
        end.
        else do:
          assign
            v-err-size = 123
          .
        end.
      end.
      if compiler :warning
        or v-err-size <> 0
      then do:
        assign
          v-compile       = false
          v-proc-num      = v-proc-num - v-skip-proc
          v-ind-tbl       = v-ind-tbl - v-skip-proc - v-ind-tbl-ignor
        .
        if v-ind-tbl-curr > v-skip-proc
          or ( v-ind-tbl-curr <= v-skip-proc
               and v-skip-proc > v-skip-proc-min
             )
        then do:
          if v-skip-proc > v-skip-proc-min
            and v-skip-proc > v-skip-proc-step
          then do:
            assign
              v-ind-tbl-curr = v-ind-tbl-curr - v-skip-proc
              v-compile   = true
            .
            if v-skip-proc - v-skip-proc-step >= v-skip-proc-min then do:
              assign
                v-skip-proc = v-skip-proc - v-skip-proc-step
              .
            end.
            else do:
              assign
                v-skip-proc = v-skip-proc-min
              .
            end.
          end.
          else do:
            assign
              v-skip-proc = v-skip-proc-max
            .
          end.
          os-copy value( gen-dir + temp-file-name ) value( gen-dir + file-name ) .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            substitute( "&1 процедуры не помещаются в один генерируемый файл", v-skip-proc ) skip
            view-as alert-box error .
          leave block_compile.
        end.
      end.
      else do:
        os-copy value( gen-dir + file-name ) value( gen-dir + temp-file-name ) .
        if v-skip-proc = v-skip-proc-min then do:
          assign
            v-compile   = false
            v-skip-proc = v-skip-proc-max
          .
        end.
        else do:
          if v-skip-proc < v-skip-proc-max
            and v-skip-proc - v-skip-proc-step >= v-skip-proc-min
          then do:
            assign
              v-skip-proc = v-skip-proc - v-skip-proc-step
            .
          end.
        end.
      end.
      assign
        v-ind-tbl-ignor = 0
      .
    end.
  end.
  os-delete
    value( gen-dir + temp-file-name )
    value( gen-dir + "cmp-err.txt":U)
  .
  if v-ind-tbl < v-num-tbls then do:
    assign
      file-name        = substitute( "nws/l-rec-&1.p":U, string( counter-step + 1, "99" ) )
      file-name-no-ext = substitute( "l-rec-&1":U, string( counter-step + 1, "99" ) )
      temp-file-name   = substitute( "&1.p0":U, file-name-no-ext )
      counter-step     = counter-step + 1
    .
  end.
end.
OUTPUT STREAM ImpStream TO value( gen-dir + "nws/imp-pck2.i":U ) APPEND.
PUT STREAM ImpStream UNFORMATTED
  'if v-proc-avail = FALSE then do:                                                                    ' SKIP
  '  run proc-load-standart in this-procedure                                                          ' SKIP
  '      ( input ~{1~}                                                                                 ' SKIP
  '       ,input ~{2~}                                                                                 ' SKIP
  '       ,input ?                                                                                     ' SKIP
  '       ,input this-procedure                                                                        ' SKIP
  '       ,input ~{4~}                                                                                 ' SKIP
  '       ,output ~{5~}                                                                                ' SKIP
  '      ) .                                                                                           ' SKIP
  'end.                                                                                                ' SKIP
.
OUTPUT STREAM ImpStream CLOSE.
hide frame ddd no-pause.
RETURN.
