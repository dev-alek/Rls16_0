/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Уханов Дмитрий Юрьевич
Дата создания: 12/04/07
Author: Dmitry Ukhanov
Creation date: 12/04/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&glob TABLE-RGDS_IGNORE "~
shift-period~
":U

&glob TABLE-RGDS_SPECIAL "~
goods~
":U

&glob TABLE-RGDS_LIST "~
abc-analysis-gds-obj~
,abc-analysis-gds-obj-attr~
,abc-analysis-goods~
,abc-analysis-goods-attr~
,abcxyz-analysis-goods~
,abcxyz-analysis-goods-attr~
,action-post-role~
,action-role-item-gds~
,add-line~
,c-add-line~
,aht-gds~
,aht-gds-attr~
,aht-ot-line~
,aht-ot-line-attr~
,aht-stk-line~
,aht-stk-line-attr~
,alc-type-gds~
,c-alc-type-gds~
,alc-type-gds-attr~
,arh-wth-cli~
,arh-wth-cli-attr~
,arh-wth-cli-doc~
,arh-wth-cli-doc-attr~
,arh-wth-tot~
,arh-wth-w-p~
,assortment-matrix-goods~
,assortment-matrix-goods-attr~
,c-assortment-matrix-goods~
,bar-code~
,bar-code-attr~
,bar-code-obj-attr~
,c-bar-code~
,c-bar-code-attr~
,c-bar-code-obj-attr~
,cd-doc-line~
,c-cd-doc-line~
,cd-event-log~
,cd-plu~
,c-cd-plu~
,chk-gds-pay~
,contract-specif~
,c-contract-specif~
,contract-specif-attr~
,dis-gds-rule~
,c-dis-gds-rule~
,dis-gds-rule-attr~
,doc-fbr-gds~
,c-doc-fbr-gds~
,doc-fbr-gds-attr~
,doc-line-attr~
,c-doc-line-attr~
,doc-line-sum~
,c-doc-line-sum~
,doc-pl~
,doc-pl-attr~
,c-doc-pl~
,doc-pl-pump~
,doc-pl-pump-attr~
,c-doc-pl-pump~
,doc-prts~
,c-doc-prts~
,ext-artic~
,c-ext-artic~
,ext-artic-attr~
,c-ext-artic-attr~
,ext-artic-db~
,ext-artic-db-attr~
,ext-artic-host~
,ext-artic-host-attr~
,ext-artic-obj~
,ext-artic-obj-attr~
,factur-connect-line~
,fbr-history~
,fbr-gds-obj~
,c-fbr-gds-obj~
,fbr-gds-obj-attr~
,c-fbr-gds-obj-attr~
,fbr-pln-line~
,c-fbr-pln-line~
,c-fbr-prn~
,fbr-prn-gds~
,c-fbr-prn-gds~
,fbr-prn-gds-attr~
,fbr-recipe~
,fbr-recipe-gds~
,fin-gds-part~
,fin-gds-part-attr~
,c-fin-gds-part~
,c-gds-hist~
,gds-add-charges~
,gds-add-charges-attr~
,c-gds-add-charges~
,c-gds-add-charges-attr~
,gds-host-attr~
,c-gds-host-attr~
,gds-obj~
,c-gds-obj~
,c-gds-obj-ref~
,gds-obj-attr~
,c-gds-obj-attr~
,gds-obj-flag~
,gds-obj-flag-attr~
,gds-obj-prop~
,gds-obj-prop-attr~
,c-gds-obj-prop~
,gds-season~
,gds-season-attr~
,c-gds-season~
,c-goods~
,goods-attr~
,c-goods-attr~
,hold-sale~
,hold-goods~
,hold-purch~
,hold-purch-supp-gds~
,hold-sale-attr~
,hold-goods-attr~
,hold-purch-attr~
,hold-purch-supp-gds-attr~
,icnt-line~
,ord-cons-line-attr~
,ord-dtl~
,c-ord-dtl~
,ord-line~
,c-ord-line~
,c-ord-line-attr~
,ord-line-attr~
,ord-line-rcv~
,ord-rcv-line-attr~
,parts-attr~
,parts-add~
,c-parts-add~
,parts-add-attr~
,c-parts-attr~
,parts-obj-attr~
,c-parts-obj-attr~
,parts-root~
,parts-root-attr~
,c-parts-root~
,pl-gds~
,c-pl-gds~
,c-pl-gds-obj~
,pl-gds-attr~
,c-pl-gds-attr~
,c-plc-hist~
,c-pmp-hist~
,pl-gds-pump~
,c-pl-gds-pump~
,pl-gds-pump-attr~
,c-pl-gds-pump-attr~
,price-all~
,rcs-retail1product~
,recipe~
,c-recipe~
,c-recipe-gds~
,recipe-gds~
,recipe-develop~
,c-recipe-develop~
,c-recipe-hist~
,rvs-line~
,rvs-line-attr~
,c-rvs-line~
,rvs-pump~
,rvs-line-pump~
,rvs-line-pump-attr~
,c-rvs-line-pump~
,s-coeff~
,c-s-coeff~
,s-coeff-attr~
,schet-fact-line~
,c-schet-fact-line~
,tax-rate-gds~
,tax-rate-gds-attr~
,turnover-buyer-gds~
,turnover-buyer-gds-attr~
,user-login-action-item~
,user-login-action-role~
,varianty-delivery-gds-obj~
,c-varianty-delivery-gds-obj~
,wth-dtl~
,c-wth-dtl~
,wth-gds~
,c-wth-gds~
,wth-gds-attr~
,c-wth-gds-attr~
,wth-dtl~
,c-wth-dtl~
,wth-parts~
,c-wth-parts~
,xyz-analysis-gds-obj~
,xyz-analysis-gds-obj-attr~
,xyz-analysis-goods~
,xyz-analysis-goods-attr~
,egais-gds~
,c-egais-gds~
,vsd~
,c-vsd~
,gds-mercury~
,c-gds-mercury~
,PromoGift~
,PromoGoods~
,c-PromoGift~
,c-PromoGoods~
,OperServ~
,c-OperServ~
,c-goods-attr-any~
,utd-lines~
,c-utd-marking-lines~
,c-utd-lines~
,marking-lines~
,utd-marking-lines~
,marking~
,c-contract-specif-attr~
,c-marking~
,order-line~
,c-order-line~
,shift-param~
":U

procedure valid-ren-gdsc-tbl-list :

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-std-list        as character no-undo .
    define variable v-ignore-list     as character no-undo .
    define variable v-special-list    as character no-undo .
    assign
      v-std-list     = {&TABLE-RGDS_LIST}
      v-ignore-list  = {&TABLE-RGDS_IGNORE}
      v-special-list = {&TABLE-RGDS_SPECIAL}

    .
    { utl/ren-all.i
      &chk-field-name='"gds-code"':U
      &full-field-list='"gds-code"':U
    }
  end.

end procedure. /* valid-ren-gdsc-tbl-list */
/* $Workfile$ e n d */