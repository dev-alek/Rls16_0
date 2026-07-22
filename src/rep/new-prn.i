/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение переменных для программ для печати ценников (этикеток).

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/98
Author: Dmitry Ukhanov
Creation date: 03/22/98

*/
{ gbl/getsect.i def }
/* путь к программе печати ценников */
define  {1} shared variable     lbc-path                     as  char        no-undo.
/* путь к temp дирректории программы печати ценников */
define  {1} shared variable     lbc-tmp                      as  char        no-undo.

/* название шаблона ценника */
define {1} shared variable TicketName  as character   init ""    no-undo.
/* масштаб цены */
define {1} shared variable ScalePrice    as decimal init 0     no-undo.
/* тип кодовой страницы промежуточного файла */
define {1} shared variable TitleCP    as character   init ""    no-undo.
/* тип ценника (на упаковку - уп, простой - "" */
define {1} shared variable TicketType    as character   init ""    no-undo.
/* тип баркода на ценнике (основной, партии, доп.бк.) */
define {1} shared variable BCodeType    as character   init ""    no-undo.
/* ед. изм. для доп.бк. */
define {1} shared variable UnitName    as character   init ""    no-undo.
/* в т.ч. нулевыми ценами */
define {1} shared variable TickOnN       as logical   init no   no-undo.
/* в т.ч. на весовой товар */
define {1} shared variable TickOnW       as logical   init no   no-undo.
/* детально (по признакам) */
define {1} shared variable TickOnS         as logical  init no    no-undo.
/* Печатать только если изменилась цена */
define {1} shared variable OnlyChgPr    as logical     init no    no-undo.
/* кол-во ценников (из документа, остатки, ...) */
define {1} shared variable QntyType     as character   init ""    no-undo.
/* цена на этикетке (из прайс-листа, из документа) */
define {1} shared variable PriceType    as character   init ""    no-undo.
/* печатать ценники на весовой товар из всех точек вызова? */
define {1} shared variable tick-w       as logical     init no    no-undo.
/* PS выводимое на всех этикетках данной сессии печати */
define {1} shared variable TickPS       as character   init ""    no-undo.

/* наименование товара  */
define  {1} shared variable     GdsName   as character   no-undo.
/* дата курса */
define  {1} shared variable     curr-date                      as  date      no-undo.
/* курс на дату */
define  {1} shared variable     curr-rate                      as  decimal      no-undo.
/*  тип этикетки  (описаны в str-glbl.i) */
define  {1} shared variable     bc-type   as character   no-undo.
/* наименование текущего объекта  */
define  {1} shared variable     obj_name  as character   no-undo.
/*сортировка вывода на печать*/
define  {1} shared variable     list-sort      as character no-undo .

define variable Artic as char no-undo.
define variable i-art as int no-undo.
define variable i as int no-undo.

/* исп-ся в    b c - c y c l e . i     */
define variable pr-doc-rubl like ub.price-list.price-sale no-undo.
define variable pr-doc-rb like ub.price-list.price-sale no-undo.
define variable pr-doc-rubl-old like ub.price-list.price-sale no-undo.
define variable pr-doc-rb-old like ub.price-list.price-sale no-undo.
define variable upper as integer no-undo.
define variable nakl-qnty like ub.gds-dtl.fact-qnty no-undo.
define variable list-qnty like ub.gds-dtl.fact-qnty no-undo.

define variable rootnode_code as integer no-undo.
define variable tmp-var as char no-undo.
define variable type-par as char no-undo.


&if "{1}" = "new" &then
    GET-KEY-VALUE section "REP-SETS" key "lbc_path" value lbc-path .
    GET-KEY-VALUE section "REP-SETS" key "lbc_tmp" value lbc-tmp .
    assign TitleCP = "".
    GET-KEY-VALUE section "REP-SETS" key "TitleCodePage" value TitleCP .
    if TitleCP = "" OR TitleCP = ? then
        assign TitleCP = "ibm866".
    { str/bc-gnrt.i new bc}
    { str/bc-gnrt.i new pl}

    define variable new-prn-host-code like ub.sysconf.host-code no-undo .
    { gbl/hostcode.i p-obj-type p-obj-code new-prn-host-code}

  { gbl/getsect.i run {&cmp} new-prn-host-code {&attr-prt-firm} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'tick-w'  then tick-w  = thbjattr_thbj-attr.property-value-logical .
  end.
    { gbl/conf-rd.i "'is-prt'" 0 "''" 0 "''" "''" "''" yes tmp-var type-par no-error }
&else
    { str/bc-gnrt.i " " bc}
    { str/bc-gnrt.i " " pl}
&endif
define variable v-cntxp-doc-prt as logical no-undo .
define buffer new-prn_shop for ub.shop.
define buffer new-prn_store for ub.store.
{ gbl/conf-rd.i "'is-prt'" 0 "''" 0 "''" "''" "''" yes tmp-var type-par no-error }
case p-obj-type :
  when {&stock} then do:
    find first new-prn_store where new-prn_store.obj-code = p-obj-code no-lock.
    assign
      v-cntxp-doc-prt         = (tmp-var = "yes") and new-prn_store.doc-prt
      .
  end.
  when {&shop} then do:
    find first new-prn_shop where new-prn_shop.obj-code = p-obj-code no-lock.
    assign
      v-cntxp-doc-prt         = (tmp-var = "yes") and new-prn_shop.doc-prt
      .
/*      message tmp-var  '\' new-prn_shop.doc-prt  '\' v-cntxp-doc-prt '123' view-as alert-box. */
  end.
end case.


define variable curr_cass as dec no-undo.
define variable dob-curr as char no-undo.

define variable Term_Node as logical no-undo.
define variable ListProdBc as char no-undo.

define variable counter as int init 1 no-undo.
define variable Rubl_Coeff as decimal init 0 no-undo.

define variable v-doc-code as character initial "":U no-undo .
define variable v-part-code as character initial "":U no-undo .
define variable v-promo-code as character no-undo .
define variable v-ActionId as int64 no-undo .
define variable v-db-num as integer no-undo .
/* $Workfile$ e n d */