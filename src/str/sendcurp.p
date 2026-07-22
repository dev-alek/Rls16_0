block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sendcurp.p $
$Archive: str/sendcurp.p $

Пересылка справочника валют-оплат - для АРМ ресторан

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/04/03
Author: Bakhtadze Natalya
Creation date: 12/04/03

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-db-num like ub.db.db-num no-undo .

/*эти параметры нужны чтобы отбирать только те объекты которые имеют ту же фирму что и заданный объект*/
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter action     as character no-undo .
DEFINE INPUT PARAMETER p-selective as logical no-undo.
/*по оплатам выборочно или все!*/
DEFINE INPUT PARAMETER p-rid-list as char no-undo.
/*список recid cash-pay если selective = yes*/
define input parameter p-log-file-name as character no-undo .
define input-output parameter p-view-log as logical no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: sendcurp.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/sendcurp.p $":U .
def var vss-description as character no-undo init "Пересылка справочника валют-оплат - для АРМ ресторан".
{ cmp/vssrevis.i }


{ cmp/trg-def.i }
{ bge/bgelib.i }
&glob xml-cd-doc-name 'data'
{ str/cd-xml.i }
{ str/cdsnddef.i }
{ ref/cp-attr.i }
{ gbl/thbj-def.i }

define variable v-cashless-code as integer no-undo .
define variable v-no-pay-code as integer no-undo .
define variable v-VIP-pay-code as integer no-undo .
/*некий виртуально сконструированный код баз вал*/
define variable v-mag-base-code like ub.cash-pay.cdpay-code no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-r-b-code  like ub.sysconf.base-code no-undo .
define variable v-r-b        as character no-undo .
/*вспомогат*/
define variable conf-attr as character no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-cp-is-use as logical no-undo .

define buffer base_currency for ub.currency.

assign
log-file-name = p-log-file-name
.

{ gbl/hostcode.i {&shop} p-obj-code v-host-code }
{ gbl/r-b-curr.i v-host-code v-r-b-code }

for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
run adm/shattri.p (
      input "get":U
      ,input  {&shop}
      ,input  p-obj-code
      ,input  {&attr-cd-type-magia-xml}
      ,input  '':U /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
IF error-status:error then return error return-value .
for each thbjattr_thbj-attr where
        thbjattr_thbj-attr.obj-type = {&shop}
    and thbjattr_thbj-attr.obj-code = p-obj-code
    and thbjattr_thbj-attr.upper-prop-code = {&attr-cd-type-magia-xml}
on error undo, return error :
  case thbjattr_thbj-attr.prop-code:
     when {&attr-cd-type-magia-Xml_mag-bnal} then do:
       v-cashless-code = thbjattr_thbj-attr.property-value-integer.
     end.
     when {&attr-cd-type-magia-Xml_magnopay} then do:
       v-no-pay-code = thbjattr_thbj-attr.property-value-integer.
     end.
     when {&attr-cd-type-magia-Xml_mag-vip} then do:
       v-vip-pay-code = thbjattr_thbj-attr.property-value-integer.
     end.
  end case.
end.
if action = 'D':U then do:
  assign
  v-cp-is-use = no.
end.
if action <> 'D':U then do:
  run adm/shattri.p (
      input "get":U
      ,input  {&shop}
      ,input  p-obj-code
      ,input  {&attr-cd-inf-send}
      ,input  {&attr-cd-inf-send_cp-is-use} /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  IF not error-status:error
  then v-cp-is-use = v-value-logical.
  else return error return-value .
end.

find first base_currency no-lock where
         base_currency.curr-code = v-r-b-code .
if base_currency.okv-code = 0 then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Для валюты &1 с кодом &2 не задан код ОКВ"
                            , base_currency.curr-abbr
                            , v-r-b-code
                          )
                                          ).
  assign
  p-view-log = yes
  .
  undo, return.
end.
assign
v-mag-base-code = (if base_currency.curr-code = 0
                   then 1
                   else base_currency.okv-code)
.


/*PROCEDURE putc-curp.*/
/*разнящийся вывод для разных типов касс*/
{ str/putc-31.i }


/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/
{ str/cd-cyc31.i }

/*PROCEDURE SENDING.*/
{ str/cd-sen31.i }


if action = "D" then do:
  message
  "Вы действительно хотите удалить с кассы записи от типах кассовых платежей?"
  view-as alert-box QUESTION buttons YES-NO update glog.
  if not glog then return.
end.


RUN SENDING no-error.
if error-status:error then return error.