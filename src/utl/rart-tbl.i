/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

список таблиц и процедура проверки списка переименования артикула

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/04/05
Author: Dmitry Ukhanov
Creation date: 10/04/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&glob TABLE-RART_IGNORE ~
"c-goods~
,c-order-line~
":U
&glob TABLE-RART_SPECIAL ~
"goods~
,ot-line~
,stk-line~
,order-line~
":U

&glob TABLE-RART_LIST ~
"cli-gds~
,cli-gds-attr~
,cli-art~
,cli-art-attr~
,contract-specif~
,c-contract-specif~
,doc-line~
,c-doc-line~
,fbr-line~
,c-fbr-line~
,fbr-recipe~
,fbr-recipe-gds~
,fbr-pln-line~
,c-fbr-pln-line~
,gds-dtl~
,c-gds-dtl~
,gds-dtl-attr~
,c-gds-dtl-attr~
,gds-obj~
,inv-line~
,inv-line-attr~
,c-inv-line~
,ot-supp-line~
,ot-supp-line-attr~
,ot-line-attr~
,ord-line~
,c-ord-line~
,ord-line-rcv~
,ord-dtl~
,c-ord-dtl~
,ord-dtl-attr~
,ord-dtl-rcv~
,ord-dtl-cons~
,ord-gds-cons~
,prt-obj~
,prt-obj-attr~
,parts~
,c-parts~
,parts-supp~
,parts-supp-attr~
,price-list~
,c-price-list~
,price-doc-forming-gds~
,c-price-doc-forming-gds~
,price-doc-forming-gds-qnty~
,c-price-doc-forming-gds-qnty~
,price-doc-forming-gds-sum~
,c-price-doc-forming-gds-sum~
,price-doc-forming-gds-tnv~
,c-price-doc-forming-gds-tnv~
,recipe~
,recipe-gds~
,c-recipe~
,c-recipe-gds~
,c-recipe-hist~
,stk-supp-line~
,stk-supp-line-attr~
,stk-line-attr~
,tmp-sale-dtl~
,tmp-sale-dtl-attr~
,tmp-sale-gds~
,tmp-sale-gds-attr~
":U

procedure valid-ren-art-tbl-list :

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-std-list        as character no-undo .
    define variable v-ignore-list     as character no-undo .
    define variable v-special-list    as character no-undo .
    assign
      v-std-list     = {&TABLE-RART_LIST}
      v-ignore-list  = {&TABLE-RART_IGNORE}
      v-special-list = {&TABLE-RART_SPECIAL}

    .
    { utl/ren-all.i
      &chk-field-name='"artic"':U
      &full-field-list='"artic, prod-type, prod-code"':U
    }
  end.

end procedure. /* valid-tbl-list */

/* $Workfile$ e n d */