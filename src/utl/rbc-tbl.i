/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

список таблиц и процедура проверки списка переименования бар-кода

Автор: Уханов Дмитрий Юрьевич
Дата создания: 12/04/07
Author: Dmitry Ukhanov
Creation date: 12/04/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&glob TABLE-RBC_IGNORE ~
"c-bar-code~
,c-prod-bc~
,c-gds-hist~
,rcs-retail1barcode~
":U

&glob TABLE-RBC_SPECIAL ~
"bar-code~
,prod-bc~
,price-list~
,price-list-attr~
,c-price-list-attr~
":U

&glob TABLE-RBC_LIST "~
bar-code-attr~
,c-bar-code-attr~
,bar-code-obj-attr~
,c-bar-code-obj-attr~
,chk-gds~
,c-chk-gds~
,chk-gds-pay~
,doc-prts~
,doc-prts-attr~
,cd-doc-line~
,c-cd-doc-line~
,cd-plu~
,c-cd-plu~
,c-doc-prts~
,c-price-list~
,prod-bc-attr~
,c-prod-bc-attr~
,prod-bc-db~
,prod-bc-db-attr~
,c-prod-bc-db-attr~
,price-all~
,price-doc-forming-gds~
,price-doc-forming-gdsattr~
,price-doc-forming-gds-tnv~
,price-doc-forming-gds-sum~
,price-doc-forming-gds-qnty~
,c-price-doc-forming-gds~
,c-price-doc-forming-gdsattr~
,c-price-doc-forming-gds-tnv~
,c-price-doc-forming-gds-sum~
,c-price-doc-forming-gds-qnty~
,scales-gds~
,c-scales-gds~
,sert-join~
,c-sert~
,sert-join-attr~
":U

procedure valid-ren-bcod-tbl-list :

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-std-list        as character no-undo .
    define variable v-ignore-list     as character no-undo .
    define variable v-special-list    as character no-undo .
    assign
      v-std-list     = {&TABLE-RBC_LIST}
      v-ignore-list  = {&TABLE-RBC_IGNORE}
      v-special-list = {&TABLE-RBC_SPECIAL}

    .
    { utl/ren-all.i
      &chk-field-name='"b-code"':U
      &full-field-list='"b-code"':U
    }

  end.

end procedure. /* valid-ren-bcod-tbl-list */


/* $Workfile$ e n d */